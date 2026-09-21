------------------------------------------------------------
-- RYTICTANK RESOURCE HUD v2
-- Event-driven resource tracking
--
-- Health:   bottom -> top (one continuous bar)
-- Health center notch: visual 50% marker only
-- Stamina:  center -> top
-- Magicka:  center -> bottom
------------------------------------------------------------

RyticTank.Resources = {}

local TEX = "RyticTankTools/textures/"

local THEME_TEXTURES = {
    FEMALE = {
        TEX.."wifey/floral_tl.dds",
        TEX.."wifey/floral_bl.dds",
        TEX.."wifey/floral_tr.dds",
        TEX.."wifey/floral_br.dds",
    },
    MALE = {
        TEX.."male/male_tl.dds",
        TEX.."male/male_bl.dds",
        TEX.."male/male_tr.dds",
        TEX.."male/male_br.dds",
    },
}

local function NormalizeTheme(v)
    v=string.upper(tostring(v or "REGULAR"))
    if v~="MALE" and v~="FEMALE" then v="REGULAR" end
    return v
end


local ARC_W  = 128
local ARC_H  = 512
local HALF_H = 256

local HEALTH = {0.90, 0.05, 0.05}
local STAM   = {0.10, 0.90, 0.12}
local MAG    = {0.08, 0.32, 1.00}
local WARN   = {0.72, 0.18, 1.00}
local SHIELD = {1.00, 0.70, 0.70}

local function Clamp01(v)
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

function RyticTank.Resources.GetPercent(powerType)
    -- ESO exposes current and maximum power from GetUnitPower.
    -- GetUnitPowerMax is not a valid function in this client/API.
    local current, maximum = GetUnitPower("player", powerType)
    current = tonumber(current) or 0
    maximum = tonumber(maximum) or 0
    if maximum <= 0 then return 0 end
    return (current / maximum) * 100
end

local function CommaNumber(value)
    local n = math.floor(tonumber(value) or 0)
    local s = tostring(n)
    local sign = ""
    if string.sub(s, 1, 1) == "-" then
        sign = "-"
        s = string.sub(s, 2)
    end
    while true do
        local changed
        s, changed = string.gsub(s, "^(%d+)(%d%d%d)", "%1,%2")
        if changed == 0 then break end
    end
    return sign .. s
end

local function ResourceText(powerType, pct)
    local current = GetUnitPower("player", powerType) or 0
    return string.format("%s (%.0f%%)", CommaNumber(current), pct or 0)
end

local function MakeTexture(parent, path)
    local c = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    c:SetTexture(path)
    return c
end

local function SetColor(control, rgb)
    control:SetColor(rgb[1], rgb[2], rgb[3], 1)
end

-- Crop the ORIGINAL artwork instead of scaling the whole curve.
-- Bottom-up: bottom remains fixed and top moves down as resource is spent.
local function CropBottomUp(control, pct, width, fullHeight)
    local p = Clamp01(pct / 100)
    local h = math.max(1, fullHeight * p)
    control:SetDimensions(width, h)
    control:SetTextureCoords(0, 1, 1 - p, 1)
end

-- Top-down: top remains fixed and bottom moves up as resource is spent.
local function CropTopDown(control, pct, width, fullHeight)
    local p = Clamp01(pct / 100)
    local h = math.max(1, fullHeight * p)
    control:SetDimensions(width, h)
    control:SetTextureCoords(0, 1, 0, p)
end

-- Draw only the portion of the original curved health artwork between two
-- percentages. Used for the live shield segment above the current HP fill.
local function CropBottomSegment(control, startPct, endPct, width, fullHeight)
    local a = Clamp01((startPct or 0) / 100)
    local b = Clamp01((endPct or 0) / 100)

    if b <= a then
        control:SetHidden(true)
        return
    end

    local h = math.max(1, fullHeight * (b - a))
    control:SetDimensions(width, h)
    control:SetTextureCoords(0, 1, 1 - b, 1 - a)
    control:ClearAnchors()
    control:SetAnchor(BOTTOM, RyticTank.Resources.healthBack, BOTTOM, 0, -(fullHeight * a))
    control:SetHidden(false)
end

function RyticTank.Resources.CreateHUD()
    local wm = WINDOW_MANAGER

    local hud = wm:CreateTopLevelWindow("RyticTankResourceHUD")
    RyticTank.Resources.window = hud
    -- ESOUI HUD fragment: automatically hide this HUD when menus open.
    local hudFragment = ZO_HUDFadeSceneFragment:New(hud, nil, 0)
    HUD_SCENE:AddFragment(hudFragment)
    HUD_UI_SCENE:AddFragment(hudFragment)
    RyticTank.Resources.hudFragment = hudFragment
    hud:SetDimensions(620, 560)
    hud:ClearAnchors()
    hud:SetAnchor(
        TOPLEFT, GuiRoot, TOPLEFT,
        RyticTank.saved.resources.position.x,
        RyticTank.saved.resources.position.y
    )
    hud:SetClampedToScreen(true)

    -- Robust edit mode. This does not depend on LibAddonMenu refreshing the lock state.
    RyticTank.Resources.editMode = false
    hud:SetMouseEnabled(true)
    hud:SetMovable(true)

    local function SaveHUDPosition()
        local left, top = hud:GetLeft(), hud:GetTop()
        if left and top then
            RyticTank.saved.resources.position.x = left
            RyticTank.saved.resources.position.y = top
        end
    end

    hud:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and RyticTank.Resources.editMode then
            hud:StartMoving()
        end
    end)
    hud:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and RyticTank.Resources.editMode then
            hud:StopMovingOrResizing()
            SaveHUDPosition()
        end
    end)


    -- HEALTH BACKGROUND
    local healthBack = MakeTexture(hud, TEX.."health_arc.dds")
    healthBack:SetDimensions(ARC_W, ARC_H)
    healthBack:SetAnchor(CENTER, hud, CENTER, -220, 0)
    healthBack:SetColor(0.03,0.03,0.035,0.78)
    RyticTank.Resources.healthBack = healthBack

    -- HEALTH FILL: bottom -> top
    local health = MakeTexture(hud, TEX.."health_arc.dds")
    health:SetDimensions(ARC_W, ARC_H)
    health:SetAnchor(BOTTOM, healthBack, BOTTOM, 0, 0)
    SetColor(health, HEALTH)
    RyticTank.Resources.healthBar = health

    -- DAMAGE SHIELD OVERLAY.
    -- Hyperioxes method: shield is its own max-health-scaled bar layered over health.
    local shield = MakeTexture(hud, TEX.."health_arc.dds")
    shield:SetDimensions(ARC_W, ARC_H)
    shield:SetAnchor(BOTTOM, healthBack, BOTTOM, 0, 0)
    shield:SetColor(SHIELD[1],SHIELD[2],SHIELD[3],0.60)
    shield:SetDrawLayer(DL_OVERLAY)
    shield:SetHidden(true)
    RyticTank.Resources.shieldBar = shield

    -- HEALTH 50% MARKER
    local hpMarker = wm:CreateControl(nil, hud, CT_BACKDROP)
    hpMarker:SetDimensions(22, 4)
    hpMarker:SetAnchor(CENTER, healthBack, CENTER, 12, 0)
    hpMarker:SetCenterColor(0.95,0.95,0.95,0.9)
    hpMarker:SetEdgeColor(0,0,0,0.9)
    RyticTank.Resources.healthMarker = hpMarker

    -- STAMINA BACKGROUND: upper right half
    local stamBack = MakeTexture(hud, TEX.."stamina_arc.dds")
    stamBack:SetDimensions(ARC_W, HALF_H)
    stamBack:SetAnchor(BOTTOM, hud, CENTER, 220, 0)
    stamBack:SetColor(0.03,0.03,0.035,0.78)
    RyticTank.Resources.staminaBack = stamBack

    -- STAMINA FILL: center -> top
    local stamina = MakeTexture(hud, TEX.."stamina_arc.dds")
    stamina:SetDimensions(ARC_W, HALF_H)
    stamina:SetAnchor(BOTTOM, stamBack, BOTTOM, 0, 0)
    SetColor(stamina, STAM)
    RyticTank.Resources.staminaBar = stamina

    -- MAGICKA BACKGROUND: lower right half
    local magBack = MakeTexture(hud, TEX.."magicka_arc.dds")
    magBack:SetDimensions(ARC_W, HALF_H)
    magBack:SetAnchor(TOP, hud, CENTER, 220, 0)
    magBack:SetColor(0.03,0.03,0.035,0.78)
    RyticTank.Resources.magickaBack = magBack

    -- MAGICKA FILL: center -> bottom
    local magicka = MakeTexture(hud, TEX.."magicka_arc.dds")
    magicka:SetDimensions(ARC_W, HALF_H)
    magicka:SetAnchor(TOP, magBack, TOP, 0, 0)
    SetColor(magicka, MAG)
    RyticTank.Resources.magickaBar = magicka

    -- RIGHT CENTER JOIN MARKER
    local join = wm:CreateControl(nil, hud, CT_BACKDROP)
    join:SetDimensions(22,4)
    join:SetAnchor(CENTER, hud, CENTER, 208, 0)
    join:SetCenterColor(0.95,0.95,0.95,0.9)
    join:SetEdgeColor(0,0,0,0.9)

    -- TEXT
    local hpText = wm:CreateControl(nil,hud,CT_LABEL)
    hpText:SetFont("ZoFontGameBold")
    hpText:SetDimensions(180,28)
    hpText:SetAnchor(CENTER,hud,CENTER,-125,0)
    hpText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    RyticTank.Resources.healthText=hpText

    local stamText = wm:CreateControl(nil,hud,CT_LABEL)
    stamText:SetFont("ZoFontGameBold")
    stamText:SetDimensions(180,28)
    stamText:SetAnchor(CENTER,hud,CENTER,145,-60)
    stamText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    RyticTank.Resources.staminaText=stamText

    local magText = wm:CreateControl(nil,hud,CT_LABEL)
    magText:SetFont("ZoFontGameBold")
    magText:SetDimensions(180,28)
    magText:SetAnchor(CENTER,hud,CENTER,145,60)
    magText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    RyticTank.Resources.magickaText=magText

    local potion = wm:CreateControl(nil,hud,CT_LABEL)
    potion:SetFont("ZoFontWinH3")
    potion:SetDimensions(180,32)
    potion:SetAnchor(CENTER,hud,CENTER,0,95)
    potion:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    potion:SetText("")
    RyticTank.Resources.potionText=potion

    hud:SetHandler("OnMoveStop",function()
        local left,top=hud:GetLeft(),hud:GetTop()
        if left and top then
            RyticTank.saved.resources.position.x=left
            RyticTank.saved.resources.position.y=top
        end
    end)

    -- Cosmetic HUD themes.
    -- FEMALE uses Ash's exact four-file floral setup proven in-game.
    -- MALE uses the same proven placement with one corner texture mirrored.
    local corners={}
    local anchors={
        {CENTER, healthBack, TOP,    -28,  18, false,false},
        {CENTER, healthBack, BOTTOM, -28, -18, false,true },
        {CENTER, stamBack,   TOP,     28,  18, true, false},
        {CENTER, magBack,    BOTTOM,  28, -18, true, true },
    }

    for i,a in ipairs(anchors) do
        local t=MakeTexture(hud,TEX.."wifey/floral_tl.dds")
        t:SetDimensions(165,175)
        t:SetAnchor(a[1],a[2],a[3],a[4],a[5])
        t:SetDrawLayer(DL_OVERLAY)
        t:SetDrawTier(DT_HIGH)
        t:SetMouseEnabled(false)
        t:SetHidden(true)
        corners[i]=t
    end
    RyticTank.Resources.themeCorners=corners

    RyticTank.Resources.ApplyLock()
    RyticTank.Resources.ApplyTheme()
end

function RyticTank.Resources.SetEditMode(enabled)
    local hud=RyticTank.Resources.window
    if not hud then return end

    enabled = enabled and true or false
    RyticTank.Resources.editMode = enabled
    RyticTank.saved.resources.locked = not enabled

    hud:SetMovable(enabled)
    hud:SetMouseEnabled(enabled)

    -- Full-HUD drag catcher so curved textures/labels cannot swallow the drag.
    if not RyticTank.Resources.moveOverlay then
        local overlay=WINDOW_MANAGER:CreateControl(nil,hud,CT_BACKDROP)
        overlay:SetAnchorFill(hud)
        overlay:SetCenterColor(0,0,0,0.06)
        overlay:SetEdgeColor(0.72,0.18,1,0.90)
        overlay:SetEdgeTexture("",1,1,2,0)
        overlay:SetDrawLayer(DL_OVERLAY)
        overlay:SetDrawTier(DT_HIGH)
        overlay:SetMouseEnabled(true)

        overlay:SetHandler("OnMouseDown",function(_,button)
            if button==MOUSE_BUTTON_INDEX_LEFT and RyticTank.Resources.editMode then
                hud:StartMoving()
            end
        end)

        overlay:SetHandler("OnMouseUp",function(_,button)
            if button==MOUSE_BUTTON_INDEX_LEFT and RyticTank.Resources.editMode then
                hud:StopMovingOrResizing()
                local left,top=hud:GetLeft(),hud:GetTop()
                if left and top then
                    RyticTank.saved.resources.position.x=left
                    RyticTank.saved.resources.position.y=top
                end
            end
        end)

        RyticTank.Resources.moveOverlay=overlay
    end

    if not RyticTank.Resources.moveLabel then
        local label=WINDOW_MANAGER:CreateControl(nil,hud,CT_LABEL)
        label:SetFont("ZoFontWinH2")
        label:SetAnchor(TOP,hud,TOP,0,10)
        label:SetText("|cB82EFFRSS HUD UNLOCKED - DRAG ANYWHERE|r")
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawTier(DT_HIGH)
        RyticTank.Resources.moveLabel=label
    end

    RyticTank.Resources.moveOverlay:SetHidden(not enabled)
    RyticTank.Resources.moveLabel:SetHidden(not enabled)

    if enabled then
        -- Edit mode must override hide-out-of-combat.
        hud:SetHidden(false)
    end
end

function RyticTank.Resources.ApplyLock()
    local locked=RyticTank.saved.resources.locked
    if locked == nil then
        locked = true
        RyticTank.saved.resources.locked = true
    end
    RyticTank.Resources.SetEditMode(not locked)
end

function RyticTank.Resources.ResetPosition()
    local hud=RyticTank.Resources.window
    if not hud then return end

    -- Known visible default location.
    local x,y=650,250
    RyticTank.saved.resources.position.x=x
    RyticTank.saved.resources.position.y=y
    hud:ClearAnchors()
    hud:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,x,y)
    hud:SetHidden(false)
end

function RyticTank.Resources.ApplyTheme()
    local corners=RyticTank.Resources.themeCorners
    if not corners then return end

    local theme=NormalizeTheme(RyticTank.saved.resources.theme)
    RyticTank.saved.resources.theme=theme
    local textures=THEME_TEXTURES[theme]

    for i,t in ipairs(corners) do
        if textures then
            t:SetTexture(textures[i])
            -- Both Male and Female use four pre-oriented DDS files.
            -- Keep ESO texture coordinates standard; no runtime mirroring.
            t:SetTextureCoords(0,1,0,1)
            t:SetAlpha(1)
            t:SetHidden(false)
        else
            t:SetHidden(true)
        end
    end
end

-- Apply the saved Resource HUD scale to the entire curved RSS window.
function RyticTank.Resources.ApplyScale()
    local hud = RyticTank.Resources.window
    if not hud then return end
    local scale = tonumber(RyticTank.saved.resources.scale) or 1.0
    hud:SetScale(scale)
end

local function UpdateVisibility()
    local hud=RyticTank.Resources.window
    if not hud then return false end

    local s=RyticTank.saved.resources

    -- Never hide the HUD while the user is positioning it.
    if RyticTank.Resources.editMode then
        hud:SetHidden(false)
        return true
    end

    if not s.enabled then
        hud:SetHidden(true)
        return false
    end

    local combat=IsUnitInCombat("player")
    if s.preview then
        hud:SetHidden(false)
    elseif s.hideOutOfCombat and not combat then
        hud:SetHidden(true)
        return false
    else
        hud:SetHidden(false)
    end
    return true
end

local function SetTrackedShield(value)
    value=math.max(0,tonumber(value) or 0)
    RyticTank.Resources.currentShield=value
    RyticTank.Resources.shieldTracked=true
end

local function OnShieldVisual(eventCode,unitTag,unitAttributeVisual,statType,attributeType,powerType,v1,v2,v3,v4)
    if unitTag~="player"
        or unitAttributeVisual~=ATTRIBUTE_VISUAL_POWER_SHIELDING
        or attributeType~=ATTRIBUTE_HEALTH
        or powerType~=POWERTYPE_HEALTH then
        return
    end

    local current=math.max(0,tonumber(RyticTank.Resources.currentShield) or 0)

    if eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
        current=current+math.max(0,tonumber(v1) or 0)
    elseif eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED then
        current=current-math.max(0,tonumber(v1) or 0)
    elseif eventCode==EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED then
        -- UPDATED supplies oldValue,newValue,oldMaxValue,newMaxValue.
        current=current+((tonumber(v2) or 0)-(tonumber(v1) or 0))
    end

    SetTrackedShield(current)
    RyticTank.Resources.UpdateShield()
end

function RyticTank.Resources.UpdateShield()
    local bar=RyticTank.Resources.shieldBar
    if not bar then return end

    local currentHealth,maxHealth=GetUnitPower("player",POWERTYPE_HEALTH)
    currentHealth=tonumber(currentHealth) or 0
    maxHealth=tonumber(maxHealth) or 0

    local shield
    if RyticTank.Resources.shieldTracked then
        shield=math.max(0,tonumber(RyticTank.Resources.currentShield) or 0)
    elseif GetUnitAttributeVisualizerEffectInfo then
        shield=GetUnitAttributeVisualizerEffectInfo(
            "player",
            ATTRIBUTE_VISUAL_POWER_SHIELDING,
            STAT_MITIGATION,
            ATTRIBUTE_HEALTH,
            POWERTYPE_HEALTH
        )
        shield=math.max(0,tonumber(shield) or 0)
        SetTrackedShield(shield)
    else
        shield=0
    end

    if maxHealth<=0 or shield<=0 then
        SetTrackedShield(0)
        bar:SetHidden(true)
        return
    end

    local hpPct=(currentHealth/maxHealth)*100
    local shieldPct=(shield/maxHealth)*100
    local startPct=math.max(0,hpPct-shieldPct)

    CropBottomSegment(bar,startPct,hpPct,ARC_W,ARC_H)
    bar:SetColor(SHIELD[1],SHIELD[2],SHIELD[3],0.88)
end

function RyticTank.Resources.UpdateHealth(pct)
    if not RyticTank.Resources.healthBar then return end
    local s=RyticTank.saved.resources

    RyticTank.Resources.healthBar:ClearAnchors()
    RyticTank.Resources.healthBar:SetAnchor(
        BOTTOM,RyticTank.Resources.healthBack,BOTTOM,0,0)
    CropBottomUp(RyticTank.Resources.healthBar,pct,ARC_W,ARC_H)

    local threshold = tonumber(s.potionHealthThreshold) or tonumber(s.potionThreshold) or tonumber(s.warningHealth) or 30
    if pct <= threshold then SetColor(RyticTank.Resources.healthBar,WARN)
    else SetColor(RyticTank.Resources.healthBar,HEALTH) end

    RyticTank.Resources.UpdateShield()
    local current=GetUnitPower("player",POWERTYPE_HEALTH) or 0
    local shield=math.max(0,tonumber(RyticTank.Resources.currentShield) or 0)
    if shield>0 then
        RyticTank.Resources.healthText:SetText(
            string.format("%s +%s (%.0f%%)",CommaNumber(current),CommaNumber(shield),pct or 0))
    else
        RyticTank.Resources.healthText:SetText(ResourceText(POWERTYPE_HEALTH,pct))
    end
end

function RyticTank.Resources.UpdateStamina(pct)
    if not RyticTank.Resources.staminaBar then return end
    local s=RyticTank.saved.resources

    RyticTank.Resources.staminaBar:ClearAnchors()
    RyticTank.Resources.staminaBar:SetAnchor(
        BOTTOM,RyticTank.Resources.staminaBack,BOTTOM,0,0)
    CropBottomUp(RyticTank.Resources.staminaBar,pct,ARC_W,HALF_H)

    local threshold = tonumber(s.potionResourceThreshold) or tonumber(s.potionThreshold) or tonumber(s.warningStamina) or 30
    if pct <= threshold then SetColor(RyticTank.Resources.staminaBar,WARN)
    else SetColor(RyticTank.Resources.staminaBar,STAM) end

    RyticTank.Resources.staminaText:SetText(ResourceText(POWERTYPE_STAMINA, pct))
end

function RyticTank.Resources.UpdateMagicka(pct)
    if not RyticTank.Resources.magickaBar then return end
    local s=RyticTank.saved.resources

    RyticTank.Resources.magickaBar:ClearAnchors()
    RyticTank.Resources.magickaBar:SetAnchor(
        TOP,RyticTank.Resources.magickaBack,TOP,0,0)
    CropTopDown(RyticTank.Resources.magickaBar,pct,ARC_W,HALF_H)

    local threshold = tonumber(s.potionResourceThreshold) or tonumber(s.potionThreshold) or tonumber(s.warningMagicka) or 30
    if pct <= threshold then SetColor(RyticTank.Resources.magickaBar,WARN)
    else SetColor(RyticTank.Resources.magickaBar,MAG) end

    RyticTank.Resources.magickaText:SetText(ResourceText(POWERTYPE_MAGICKA, pct))
end

function RyticTank.Resources.GetPotionCooldown()
    if not GetCurrentQuickslot or not GetSlotCooldownInfo then return 0,true end
    local quickslot=GetCurrentQuickslot()
    if not quickslot then return 0,true end
    local remaining,duration,globalCooldown,isUsable =
        GetSlotCooldownInfo(quickslot,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    return remaining or 0,isUsable
end

function RyticTank.Resources.UpdatePotion()
    if not RyticTank.Resources.potionText then return end
    local s=RyticTank.saved.resources
    local combat=IsUnitInCombat("player")

    RyticTank.Resources.potionText:SetText("")
    if not s.potionAlert then return end
    if s.potionCombatOnly and not combat then return end

    local hp=RyticTank.Resources.GetPercent(POWERTYPE_HEALTH)
    local stam=RyticTank.Resources.GetPercent(POWERTYPE_STAMINA)
    local mag=RyticTank.Resources.GetPercent(POWERTYPE_MAGICKA)

    local healthThreshold = tonumber(s.potionHealthThreshold) or tonumber(s.potionThreshold) or 30
    local resourceThreshold = tonumber(s.potionResourceThreshold) or tonumber(s.potionThreshold) or 30

    local trigger =
        (s.potionHealth and hp <= healthThreshold) or
        (s.potionStamina and stam <= resourceThreshold) or
        (s.potionMagicka and mag <= resourceThreshold)

    if not trigger then return end

    local cooldown,usable=RyticTank.Resources.GetPotionCooldown()
    if cooldown <= 0 and usable ~= false then
        RyticTank.Resources.potionText:SetText("|cFF3300TRI-POT|r")
    elseif not s.potionReadyOnly then
        RyticTank.Resources.potionText:SetText(
            string.format("|cFFAA00POTION %.1fs|r",cooldown/1000))
    end
end

local function EnsureArcTextures()
    local R=RyticTank.Resources
    if not R.window then return end

    -- Reassert the three shipped RSS textures and their base geometry.
    -- This makes the curved bars self-healing if another UI state/addon leaves
    -- one of the texture controls hidden or with stale texture coordinates.
    if R.healthBack then
        R.healthBack:SetTexture(TEX.."health_arc.dds")
        R.healthBack:SetDimensions(ARC_W,ARC_H)
        R.healthBack:SetTextureCoords(0,1,0,1)
        R.healthBack:SetHidden(false)
        R.healthBack:SetColor(0.03,0.03,0.035,0.78)
    end
    if R.healthBar then
        R.healthBar:SetTexture(TEX.."health_arc.dds")
        R.healthBar:SetHidden(false)
    end
    if R.staminaBack then
        R.staminaBack:SetTexture(TEX.."stamina_arc.dds")
        R.staminaBack:SetDimensions(ARC_W,HALF_H)
        R.staminaBack:SetTextureCoords(0,1,0,1)
        R.staminaBack:SetHidden(false)
        R.staminaBack:SetColor(0.03,0.03,0.035,0.78)
    end
    if R.staminaBar then
        R.staminaBar:SetTexture(TEX.."stamina_arc.dds")
        R.staminaBar:SetHidden(false)
    end
    if R.magickaBack then
        R.magickaBack:SetTexture(TEX.."magicka_arc.dds")
        R.magickaBack:SetDimensions(ARC_W,HALF_H)
        R.magickaBack:SetTextureCoords(0,1,0,1)
        R.magickaBack:SetHidden(false)
        R.magickaBack:SetColor(0.03,0.03,0.035,0.78)
    end
    if R.magickaBar then
        R.magickaBar:SetTexture(TEX.."magicka_arc.dds")
        R.magickaBar:SetHidden(false)
    end
end

function RyticTank.Resources.RefreshAll()
    if not UpdateVisibility() then return end
    EnsureArcTextures()
    RyticTank.Resources.ApplyTheme()
    RyticTank.Resources.UpdateHealth(
        RyticTank.Resources.GetPercent(POWERTYPE_HEALTH))
    RyticTank.Resources.UpdateStamina(
        RyticTank.Resources.GetPercent(POWERTYPE_STAMINA))
    RyticTank.Resources.UpdateMagicka(
        RyticTank.Resources.GetPercent(POWERTYPE_MAGICKA))
    RyticTank.Resources.UpdateShield()
    RyticTank.Resources.UpdatePotion()
end

-- Kept for compatibility with the current RyticTank.lua update loop.
function RyticTank.Resources.Update()
    UpdateVisibility()
    RyticTank.Resources.UpdatePotion()
    RyticTank.Resources.UpdateShield()

    -- Shield expiration does not necessarily fire a health power update.
    -- Refresh the HP label here so +Shield disappears immediately.
    if RyticTank.Resources.healthText then
        local current,maxHealth=GetUnitPower("player",POWERTYPE_HEALTH)
        current=tonumber(current) or 0
        maxHealth=tonumber(maxHealth) or 0
        local pct=(maxHealth>0) and ((current/maxHealth)*100) or 0
        local shield=math.max(0,tonumber(RyticTank.Resources.currentShield) or 0)

        if shield>0 then
            RyticTank.Resources.healthText:SetText(
                string.format("%s +%s (%.0f%%)",CommaNumber(current),CommaNumber(shield),pct))
        else
            RyticTank.Resources.healthText:SetText(ResourceText(POWERTYPE_HEALTH,pct))
        end
    end
end

local function OnPowerUpdate(
    eventCode, unitTag, powerIndex, powerType,
    powerValue, powerMax, powerEffectiveMax
)
    if unitTag ~= "player" then return end
    local maxValue = powerEffectiveMax or powerMax
    if not maxValue or maxValue <= 0 then return end

    local pct=(powerValue/maxValue)*100

    if powerType == POWERTYPE_HEALTH then
        RyticTank.Resources.UpdateHealth(pct)
    elseif powerType == POWERTYPE_STAMINA then
        RyticTank.Resources.UpdateStamina(pct)
    elseif powerType == POWERTYPE_MAGICKA then
        RyticTank.Resources.UpdateMagicka(pct)
    end

    RyticTank.Resources.UpdatePotion()
    RyticTank.Resources.UpdateShield()
end

local function OnCombatState()
    RyticTank.Resources.RefreshAll()
end

function RyticTank.Resources.Initialize()
    if not RyticTank.saved.resources then
        RyticTank.saved.resources=ZO_DeepTableCopy(RyticTank.defaults.resources)
    end
    if not RyticTank.saved.resources.position then
        RyticTank.saved.resources.position={x=650,y=250}
    end
    if RyticTank.saved.resources.theme==nil then
        RyticTank.saved.resources.theme="REGULAR"
    end

    RyticTank.Resources.CreateHUD()
    RyticTank.Resources.ApplyScale()
    RyticTank.Resources.ApplyLock()

    SLASH_COMMANDS["/rssrepair"] = function()
        EnsureArcTextures()
        RyticTank.Resources.ApplyTheme()
        RyticTank.Resources.RefreshAll()
        d("|c00FF00RyticTankTools RSS textures refreshed.|r")
    end

    SLASH_COMMANDS["/rssmove"] = function()
        local nextState = not RyticTank.Resources.editMode
        RyticTank.Resources.SetEditMode(nextState)
        if nextState then
            d("|cB82EFFRyticTank Resource HUD MOVE MODE ON - drag anywhere in the HUD. Type /rssmove again when finished.|r")
        else
            d("|c00FF00RyticTank Resource HUD position saved. MOVE MODE OFF.|r")
        end
    end

    EVENT_MANAGER:RegisterForEvent(
        "RyticTankResourcePower",
        EVENT_POWER_UPDATE,
        OnPowerUpdate
    )
    EVENT_MANAGER:AddFilterForEvent(
        "RyticTankResourcePower",
        EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG,
        "player"
    )

    EVENT_MANAGER:RegisterForEvent(
        "RyticTankResourceCombat",
        EVENT_PLAYER_COMBAT_STATE,
        OnCombatState
    )

    -- Maintain shield amount from the same attribute-visual events ESO uses.
    -- This prevents a stale GetUnitAttributeVisualizerEffectInfo value from
    -- leaving +Shield text behind after the shield has actually expired.
    if EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED then
        EVENT_MANAGER:RegisterForEvent("RyticTankShieldAdded",EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,OnShieldVisual)
        EVENT_MANAGER:RegisterForEvent("RyticTankShieldUpdated",EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,OnShieldVisual)
        EVENT_MANAGER:RegisterForEvent("RyticTankShieldRemoved",EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,OnShieldVisual)
    end

    RyticTank.Resources.RefreshAll()
end
