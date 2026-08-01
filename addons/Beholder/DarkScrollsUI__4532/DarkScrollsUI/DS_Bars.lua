-----------------------------------------------------------
-- DarkScrollsUI - DS_Bars.lua
-- Attribute bars, skill icons, quickslot, and buff trackers.
-----------------------------------------------------------

local DarkScrollsUI_MaximumTrackerBuffsCount = 20

-----------------------------------------------------------
-- VISUAL CONFIGURATION
-----------------------------------------------------------
local AttributeBarVisualConfiguration = {
    -- Time (ms) the orange damage trail stays visible before fading
    DRAIN_LINGER_MS    = 500,
    -- Fill animation speed (bar width units per second, as a fraction)
    FILL_SPEED         = 0.8,
    TEX_DIRTY          = "DarkScrollsUI/Images/bar_dirty.dds",
    TEX_EDGE           = "DarkScrollsUI/Images/bar_edge.dds",
    EDGE_WIDTH         = 12,
    BG_COLOR           = {0.06, 0.06, 0.06, 0.95},
    BORDER_COLOR       = {0.45, 0.45, 0.45, 1},
    DRAIN_COLOR        = {0.85, 0.45, 0.05, 0.85},
    DIRTY_ALPHA        = 0.55,
    -- Dirty texture UV scroll speed (cycles per second)
    DIRTY_SCROLL_SPEED = 0.05,
    TEX_NO_ICON        = "DarkScrollsUI/Images/no_icon.dds",
}

-----------------------------------------------------------
-- SKILL GRAYSCALE
-----------------------------------------------------------
local GRAY_SAT_DEFAULT     = 0.15
local GRAY_ULT_SAT_DEFAULT = 0.90

local function GetGraySaturation()
    if DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables.graySaturation ~= nil then return DarkScrollsUI.SavedVariables.graySaturation end
    return GRAY_SAT_DEFAULT
end

local function GetGrayUltSaturation()
    if DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables.grayUltSaturation ~= nil then return DarkScrollsUI.SavedVariables.grayUltSaturation end
    return GRAY_ULT_SAT_DEFAULT
end

local function ApplyIconDesaturation(iconTex, saturation)
    iconTex:SetDesaturation(1 - saturation)
end

-----------------------------------------------------------
-- ANIMATION STATE
-- bar.bbState = {
--   displayPct : float  -- current visual fill (0..1), animates toward targetPct
--   targetPct  : float  -- real resource percentage
--   drainPct   : float  -- orange trail percentage (value before damage)
--   drainTimer : number -- timestamp (GetFrameTimeSeconds) when the trail expires
-- }
-----------------------------------------------------------
local function GetAttributeBarAnimationState(bar)
    if not bar.DarkScrollsUI_AnimationState then
        bar.DarkScrollsUI_AnimationState = { displayPct = 1, targetPct = 1, drainPct = 0, drainTimer = 0 }
    end
    return bar.DarkScrollsUI_AnimationState
end

-----------------------------------------------------------
-- PER-FRAME BAR TICK
-----------------------------------------------------------
local function UpdateAttributeBarAnimation(bar, dt)
    local st   = GetAttributeBarAnimationState(bar)
    local barW = bar:GetWidth()
    if barW <= 0 then return end

    -- Smooth fill (rises gradually)
    if st.displayPct < st.targetPct then
        st.displayPct = math.min(st.targetPct, st.displayPct + AttributeBarVisualConfiguration.FILL_SPEED * dt)
    elseif st.displayPct > st.targetPct then
        -- Damage drop is immediate; the trail handles the visual
        st.displayPct = st.targetPct
    end

    -- Orange damage trail
    local now = GetFrameTimeSeconds()
    if st.drainPct > st.displayPct and now < st.drainTimer then
        bar.fillDrain:SetWidth(st.drainPct * barW)
        bar.fillDrain:SetHidden(false)
    else
        st.drainPct = st.displayPct
        bar.fillDrain:SetHidden(true)
    end

    local fillW = math.max(0, st.displayPct * barW)
    bar.fillMain:SetWidth(fillW)
    bar.fillTop:SetWidth(fillW)
    bar.fillBottom:SetWidth(fillW)

    -- Bright edge tip at the fill boundary
    if fillW > AttributeBarVisualConfiguration.EDGE_WIDTH then
        bar.fillEdge:SetWidth(AttributeBarVisualConfiguration.EDGE_WIDTH)
        bar.fillEdge:ClearAnchors()
        bar.fillEdge:SetAnchor(RIGHT, bar.fillMain, RIGHT, 0, 0)
        bar.fillEdge:SetHidden(false)
    else
        bar.fillEdge:SetHidden(true)
    end
end

-----------------------------------------------------------
-- SHIELD QUERY
-----------------------------------------------------------
local function GetCurrentShield(unitTag)
    return GetUnitAttributeVisualizerEffectInfo(
        unitTag,
        ATTRIBUTE_VISUAL_POWER_SHIELDING,
        STAT_MITIGATION,
        ATTRIBUTE_HEALTH,
        COMBAT_MECHANIC_FLAGS_HEALTH
    ) or 0
end

-----------------------------------------------------------
-- BAR VALUE UPDATE
-----------------------------------------------------------
function DarkScrollsUI.UpdateAttributeBarFillValue(bar, attr, eventCur, eventMax)
    if not bar or not bar.fillMain then return end

    local cur, max = 0, 1
    local savedData = DarkScrollsUI.SavedVariables[bar:GetName()]

    if attr == "SHIELD" then
        cur = GetCurrentShield("player")
        local _, _, effMax = GetUnitPower("player", POWERTYPE_HEALTH)
        max = (effMax and effMax > 0) and effMax or 1
        bar:SetHidden(false)
    else
        if eventCur and eventMax then
            cur = eventCur
            max = eventMax
        else
            local current, _, effMax = GetUnitPower("player", attr)
            cur = current
            max = effMax
        end
        if not max or max == 0 then max = 1 end
    end

    local isEditing = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive
    if isEditing then
        cur = max
        if attr == POWERTYPE_MOUNT_STAMINA then bar:SetHidden(false) end
    end

    bar:SetAlpha(savedData and savedData.a or 1)

    local newPct = math.max(0, math.min(1, cur / max))
    local st     = GetAttributeBarAnimationState(bar)

    -- Shield has no gradual drain, suppress the orange trail
    if attr ~= "SHIELD" and newPct < st.targetPct and not isEditing then
        st.drainPct   = st.targetPct
        st.drainTimer = GetFrameTimeSeconds() + (AttributeBarVisualConfiguration.DRAIN_LINGER_MS / 1000)
    end

    st.targetPct = newPct

    if attr == POWERTYPE_HEALTH then
        DarkScrollsUI.lastStoredPlayerHealth = cur
    end
end

-----------------------------------------------------------
-- BAR CREATION
-----------------------------------------------------------
function DarkScrollsUI.CreateAttributeResourceBar(name, colorMain, colorLight, attr, defaultPos)
    local wm  = WINDOW_MANAGER
    local bar = _G[name] or wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    bar:SetDrawLayer(DL_BACKGROUND)
    bar:SetDrawTier(DT_HIGH)
    bar:SetClampedToScreen(true)
    bar:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    bar:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    bar.colorMain  = colorMain
    bar.colorLight = colorLight
    bar.powerType  = attr

    -- Dark background
    bar.bg = bar.bg or wm:CreateControl(name.."BG", bar, CT_BACKDROP)
    bar.bg:SetAnchorFill()
    bar.bg:SetCenterColor(unpack(AttributeBarVisualConfiguration.BG_COLOR))
    bar.bg:SetEdgeColor(unpack(AttributeBarVisualConfiguration.BORDER_COLOR))
    bar.bg:SetEdgeTexture("", 1, 2, 1)

    -- Orange damage trail (behind main fill)
    bar.fillDrain = bar.fillDrain or wm:CreateControl(name.."FillDrain", bar, CT_TEXTURE)
    bar.fillDrain:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
    bar.fillDrain:SetHeight(0)
    bar.fillDrain:SetColor(AttributeBarVisualConfiguration.DRAIN_COLOR[1], AttributeBarVisualConfiguration.DRAIN_COLOR[2], AttributeBarVisualConfiguration.DRAIN_COLOR[3], AttributeBarVisualConfiguration.DRAIN_COLOR[4])
    bar.fillDrain:SetDrawLayer(DL_BACKGROUND)
    bar.fillDrain:SetHidden(true)

    -- Main fill (gradient wrapper)
    bar.fillMain = bar.fillMain or wm:CreateControl(name.."FillMain", bar, CT_CONTROL)
    bar.fillMain:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)

    -- Bottom half: dark color
    bar.fillBottom = bar.fillBottom or wm:CreateControl(name.."FillBottom", bar.fillMain, CT_BACKDROP)
    bar.fillBottom:SetAnchor(BOTTOMLEFT, bar.fillMain, BOTTOMLEFT, 0, 0)
    bar.fillBottom:SetCenterColor(unpack(colorMain))
    bar.fillBottom:SetEdgeColor(0, 0, 0, 0)

    -- Top half: bright color
    bar.fillTop = bar.fillTop or wm:CreateControl(name.."FillTop", bar.fillMain, CT_BACKDROP)
    bar.fillTop:SetAnchor(TOPLEFT, bar.fillMain, TOPLEFT, 0, 0)
    bar.fillTop:SetCenterColor(unpack(colorLight))
    bar.fillTop:SetEdgeColor(0, 0, 0, 0)

    -- Bright edge tip
    bar.fillEdge = bar.fillEdge or wm:CreateControl(name.."FillEdge", bar, CT_TEXTURE)
    bar.fillEdge:SetTexture(AttributeBarVisualConfiguration.TEX_EDGE)
    bar.fillEdge:SetHidden(true)

    -- Dirty scrolling overlay
    bar.fillDirty = bar.fillDirty or wm:CreateControl(name.."FillDirty", bar.fillMain, CT_TEXTURE)
    bar.fillDirty:SetParent(bar.fillMain)
    bar.fillDirty:SetAnchorFill()
    bar.fillDirty:SetTexture(AttributeBarVisualConfiguration.TEX_DIRTY)
    bar.fillDirty:SetAddressMode(TEX_MODE_WRAP)
    bar.fillDirty:SetAlpha(AttributeBarVisualConfiguration.DIRTY_ALPHA)

    if not DarkScrollsUI.SavedVariables[name] then DarkScrollsUI.SavedVariables[name] = defaultPos end
    local s = DarkScrollsUI.SavedVariables[name]
    bar:ClearAnchors()
    bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    bar:SetDimensions(s.w, s.h)

    local h = s.h
    bar.fillMain:SetDimensions(s.w, h)
    bar.fillTop:SetDimensions(s.w, h / 2)
    bar.fillBottom:SetDimensions(s.w, h / 2)
    bar.fillDrain:SetHeight(h)
    bar.fillEdge:SetHeight(h)

    bar:SetAlpha(s.a or 1)

    DarkScrollsUI.SetupCommonInterfaceHandlers(bar)

    if attr == "SHIELD" then
        local function onShield(_, unit)
            if unit == "player" then DarkScrollsUI.UpdateAttributeBarFillValue(bar, "SHIELD") end
        end
        bar:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED,   onShield)
        bar:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED,  onShield)
        bar:RegisterForEvent(EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED,  onShield)
    else
        bar:RegisterForEvent(EVENT_POWER_UPDATE, function(_, unit, _, pType, pool, _, effMax)
            if unit == "player" and pType == attr then
                DarkScrollsUI.UpdateAttributeBarFillValue(bar, attr, pool, effMax)
            end
        end)
    end

    if attr == POWERTYPE_MOUNT_STAMINA then
        bar:SetHidden(not IsMounted() and DarkScrollsUI.isInterfaceLocked and not DarkScrollsUI.isGlobalEditModeActive)
        bar:RegisterForEvent(EVENT_MOUNTED_STATE_CHANGED, function(_, mounted)
            if DarkScrollsUI.isInterfaceLocked and not DarkScrollsUI.isGlobalEditModeActive then 
                bar:SetHidden(not mounted) 
                if mounted then DarkScrollsUI.UpdateAttributeBarFillValue(bar, POWERTYPE_MOUNT_STAMINA) end
            end
        end)
    end

    local st = GetAttributeBarAnimationState(bar)
    st.displayPct = 1
    st.targetPct  = 1

    DarkScrollsUI.UpdateAttributeBarFillValue(bar, attr)
end

-----------------------------------------------------------
-- GLOBAL TICK (registered per-frame in DS_Init.lua)
-----------------------------------------------------------
local DarkScrollsUI_LastAttributeUpdateTickTime  = 0
local DarkScrollsUI_DirtyTextureUVOffset = 0

function DarkScrollsUI.TickAllAttributeBars()
    local now = GetFrameTimeSeconds()
    local dt  = now - DarkScrollsUI_LastAttributeUpdateTickTime
    DarkScrollsUI_LastAttributeUpdateTickTime = now

    dt = math.min(dt, 0.1)

    DarkScrollsUI_DirtyTextureUVOffset = (DarkScrollsUI_DirtyTextureUVOffset + AttributeBarVisualConfiguration.DIRTY_SCROLL_SPEED * dt) % 1.0

    local barNames = {"DarkScrollsUI_PlayerHealthBar", "DarkScrollsUI_PlayerMagickaBar", "DarkScrollsUI_PlayerStaminaBar", "DarkScrollsUI_PlayerShieldBar", "DarkScrollsUI_PlayerMountStaminaBar"}
    for _, bname in ipairs(barNames) do
        local bar = _G[bname]
        if bar and bar.fillMain and not bar:IsHidden() then
            local h = bar:GetHeight()
            local w = bar:GetWidth()

            if not bar.lastW or bar.lastW ~= w or bar.lastH ~= h then
                bar.lastW = w
                bar.lastH = h
                bar.fillMain:SetHeight(h)
                bar.fillTop:SetHeight(h / 2)
                bar.fillBottom:SetHeight(h / 2)
                bar.fillDrain:SetHeight(h)
                bar.fillEdge:SetHeight(h)
            end

            UpdateAttributeBarAnimation(bar, dt)

            if bar.fillDirty then
                bar.fillDirty:SetTextureCoords(DarkScrollsUI_DirtyTextureUVOffset, DarkScrollsUI_DirtyTextureUVOffset + 1.0, 0, 1)
            end
        end
    end

    if DarkScrollsUI.TickWeaponSwapAnimation then DarkScrollsUI.TickWeaponSwapAnimation(dt) end
    if DarkScrollsUI.TickCustomBossBar    then DarkScrollsUI.TickCustomBossBar(dt)    end
    if DarkScrollsUI.TickTargetBar        then DarkScrollsUI.TickTargetBar(dt)        end
end

-----------------------------------------------------------
-- SKILL BUFF DETECTION
-----------------------------------------------------------
local function GetBuffDuration(slotId)
    local abilityId = GetSlotBoundId(slotId)
    if abilityId == 0 then return 0 end
    local slotName    = GetAbilityName(abilityId):lower()
    local slotIcon    = GetSlotTexture(slotId):lower()
    local mappedBuffs = DarkScrollsUI.SkillToBuffMapping[slotName]

    local function CheckMatch(effectName, effectIcon, effectId)
        effectName, effectIcon = effectName:lower(), effectIcon:lower()
        if effectId == abilityId or effectIcon == slotIcon then return true end
        if mappedBuffs then
            for _, targetName in ipairs(mappedBuffs) do
                if effectName == targetName:lower() then return true end
            end
        end
        return effectName:find(slotName) or slotName:find(effectName)
    end

    local unitsToScan = {"player", "reticleover"}
    if GetGroupSize() > 0 then
        for i = 1, GetGroupSize() do table.insert(unitsToScan, "group"..i) end
    end

    local maxRemain = 0
    for _, unitTag in ipairs(unitsToScan) do
        for i = 1, GetNumBuffs(unitTag) do
            local bName, _, bFinish, _, _, bIcon, _, _, _, _, bId = GetUnitBuffInfo(unitTag, i)
            local remain = bFinish - GetFrameTimeSeconds()
            if remain > 0 and CheckMatch(bName, bIcon, bId) then
                if remain > maxRemain then maxRemain = remain end
            end
        end
    end
    return maxRemain
end

-----------------------------------------------------------
-- SKILL ICON UPDATE
-----------------------------------------------------------
function DarkScrollsUI.UpdateSkillIconVisualStatus(control, slotId)
    local tex = GetSlotTexture(slotId)
    if not tex or tex == "" or tex == "/esoui/art/icons/icon_missing.dds" then
        tex = AttributeBarVisualConfiguration.TEX_NO_ICON
    end
    control.icon:SetTexture(tex)
    local durationLeft = GetBuffDuration(slotId)
    local savedData    = DarkScrollsUI.SavedVariables[control:GetName()]
    local baseAlpha    = (savedData and savedData.a) or 1
    local isEditing    = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive
    local grayEnabled  = DarkScrollsUI.SavedVariables and DarkScrollsUI.SavedVariables.graySkillsEnabled

    if isEditing then
        control:SetAlpha(baseAlpha)
        ApplyIconDesaturation(control.icon, 1.0)
        control.timer:SetHidden(false)
        control.timer:SetText("9.9")
        control.timer:SetColor(1, 1, 1, 1)
        if slotId == 8 and control.ultPercent then
            control.ultPercent:SetText("100%")
            control.ultPercent:SetColor(1, 0.8, 0, 1)
            control.ultPercent:SetHidden(false)
        end
        return
    end

    local isUltReady = false
    if slotId == 8 then
        local curU   = GetUnitPower("player", POWERTYPE_ULTIMATE)
        local cost   = GetSlotAbilityCost(slotId)
        local ultPct = (cost > 0) and (curU / cost) or 0
        isUltReady   = ultPct >= 1

        if control.ultPercent then
            local ultText = isUltReady and "100%" or string.format("%d%%", math.floor(ultPct * 100))
            control.ultPercent:SetText(ultText)
            control.ultPercent:SetColor(isUltReady and 1 or 1, isUltReady and 0.8 or 1, isUltReady and 0 or 1, 1)
            control.ultPercent:SetHidden(durationLeft > 0)
        end
    end

    local buffActive    = durationLeft > 0
    local timeSinceUsed = GetFrameTimeSeconds() - (control.lastUsedTime or 0)
    local justUsed      = (timeSinceUsed < 0.5)

    if grayEnabled then
        if buffActive or justUsed then
            ApplyIconDesaturation(control.icon, 1.0)
        elseif slotId == 8 and isUltReady then
            ApplyIconDesaturation(control.icon, GetGrayUltSaturation())
        else
            ApplyIconDesaturation(control.icon, GetGraySaturation())
        end
    else
        ApplyIconDesaturation(control.icon, 1.0)
    end

    if buffActive then
        control:SetAlpha(1)
        control.timer:SetHidden(false)
        control.timer:SetText(
            durationLeft < 5
            and string.format("%.1f", durationLeft)
            or  string.format("%d", math.floor(durationLeft + 0.5))
        )
    else
        control.timer:SetHidden(true)
        if slotId == 8 and isUltReady then
            local cycle    = (GetFrameTimeSeconds() % DarkScrollsUI.ULTIMATE_PULSE_DURATION) / DarkScrollsUI.ULTIMATE_PULSE_DURATION
            local pulse    = (math.sin(cycle * math.pi * 2) + 1) / 2
            local newAlpha = DarkScrollsUI.ULTIMATE_PULSE_MIN_ALPHA_VALUE + ((DarkScrollsUI.ULTIMATE_PULSE_MAX_ALPHA_VALUE - DarkScrollsUI.ULTIMATE_PULSE_MIN_ALPHA_VALUE) * pulse)
            control:SetAlpha(newAlpha)
        else
            control:SetAlpha(justUsed and 1 or baseAlpha)
        end
    end

    local remainCD, durationCD = GetSlotCooldownInfo(slotId)
    control.cd:SetHidden(not (durationCD > 0 and remainCD > 0))
    if durationCD > 0 and remainCD > 0 then
        control.cd:StartCooldown(remainCD, durationCD, CD_TYPE_VERTICAL, CD_TIME_TYPE_TIME_REMAINING, false)
    end
end

-----------------------------------------------------------
-- QUICKSLOT UPDATE
-----------------------------------------------------------
function DarkScrollsUI.UpdateQuickslotIconVisualStatus(control)
    local quickslot = GetCurrentQuickslot()
    local savedData = DarkScrollsUI.SavedVariables[control:GetName()]
    local baseAlpha = (savedData and savedData.a) or 1
    local isEditing = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive

    if not quickslot or quickslot == 0 then
        if control.count then control.count:SetHidden(true) end
        control.icon:SetTexture(AttributeBarVisualConfiguration.TEX_NO_ICON)
        control.icon:SetDesaturation(0)
        control:SetAlpha(baseAlpha)
        control.timer:SetHidden(not isEditing)
        if isEditing then control.timer:SetText("9.9") end
        control.cd:SetHidden(true)
        return
    end

    if control.count then
        if isEditing then
            control.count:SetText("99")
            control.count:SetHidden(false)
        else
            local itemCount = GetSlotItemCount(quickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
            control.count:SetHidden(not (itemCount and itemCount > 0))
            if itemCount and itemCount > 0 then control.count:SetText(tostring(itemCount)) end
        end
    end

    local texture = GetSlotTexture(quickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if not texture or texture == "" or texture == "/esoui/art/icons/icon_missing.dds" then
        texture = AttributeBarVisualConfiguration.TEX_NO_ICON
    end
    control.icon:SetTexture(texture)
    control.icon:SetDesaturation(0)

    if isEditing then
        control:SetAlpha(baseAlpha)
        control.timer:SetHidden(false)
        control.timer:SetText("9.9")
        control.timer:SetColor(1, 1, 1, 1)
    else
        local remain, duration = GetSlotCooldownInfo(quickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        if remain and remain > 0 then
            control:SetAlpha(baseAlpha * 0.4)
            control.cd:SetHidden(false)
            control.cd:StartCooldown(remain, duration, CD_TYPE_VERTICAL, CD_TIME_TYPE_TIME_REMAINING, false)
            local seconds = remain / 1000
            control.timer:SetHidden(false)
            control.timer:SetText(seconds > 10 and string.format("%d", seconds) or string.format("%.1f", seconds))
            control.timer:SetColor(seconds < 3 and 1 or 1, seconds < 3 and 0 or 1, seconds < 3 and 0 or 1, 1)
        else
            control:SetAlpha(baseAlpha)
            control.timer:SetText("")
            control.timer:SetHidden(true)
            control.cd:SetHidden(true)
        end
    end
end

-----------------------------------------------------------
-- ICON BUTTON CREATION
-----------------------------------------------------------
function DarkScrollsUI.CreateActionButtonIcon(slotId, name, defaultPos)
    local wm  = WINDOW_MANAGER
    local btn = _G[name] or wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    btn:SetDrawLayer(DL_BACKGROUND)
    btn:SetDrawTier(DT_HIGH)
    btn:SetClampedToScreen(true)
    btn:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    btn:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    local ICON_PADDING = 6

    btn.bgTex = btn.bgTex or wm:CreateControl(name.."BgTex", btn, CT_TEXTURE)
    btn.bgTex:SetAnchorFill()
    btn.bgTex:SetTexture("DarkScrollsUI/Images/icon_background.dds")

    btn.icon = btn.icon or wm:CreateControl(name.."Icon", btn, CT_TEXTURE)
    btn.icon:ClearAnchors()
    btn.icon:SetAnchor(TOPLEFT, btn, TOPLEFT, ICON_PADDING, ICON_PADDING)
    btn.icon:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, -ICON_PADDING, -ICON_PADDING)

    btn.cd = btn.cd or wm:CreateControl(name.."CD", btn, CT_COOLDOWN)
    btn.cd:ClearAnchors()
    btn.cd:SetAnchor(TOPLEFT, btn.icon, TOPLEFT, 0, 0)
    btn.cd:SetAnchor(BOTTOMRIGHT, btn.icon, BOTTOMRIGHT, 0, 0)
    btn.cd:SetFillColor(0, 0, 0, 0.6)
    btn.cd:SetHidden(true)

    btn.timer = btn.timer or wm:CreateControl(name.."Timer", btn, CT_LABEL)
    btn.timer:SetAnchor(CENTER, btn, CENTER, 0, 0)
    btn.timer:SetFont("ZoFontWinH1")

    if slotId == 8 then
        btn.ultPercent = btn.ultPercent or wm:CreateControl(name.."UltPct", btn, CT_LABEL)
        btn.ultPercent:SetAnchor(CENTER, btn, CENTER, 0, 0)
        btn.ultPercent:SetFont("ZoFontWinH4")
    end

    if name == "DarkScrollsUI_QuickslotItemSlot" then
        btn.count = btn.count or wm:CreateControl(name.."Count", btn, CT_LABEL)
        btn.count:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, -ICON_PADDING, -ICON_PADDING)
        btn.count:SetFont("ZoFontWinH5")
        btn.count:SetColor(1, 1, 1, 1)
        btn.count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end

    if not DarkScrollsUI.SavedVariables[name] then DarkScrollsUI.SavedVariables[name] = defaultPos end
    local s = DarkScrollsUI.SavedVariables[name]
    btn:ClearAnchors()
    btn:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    btn:SetDimensions(s.w, s.h)
    btn:SetAlpha(s.a or 1)

    btn.rotation = s.r or 0
    btn.icon:SetTextureRotation(btn.rotation)
    btn.bgTex:SetTextureRotation(btn.rotation)

    DarkScrollsUI.SetupCommonInterfaceHandlers(btn)
    DarkScrollsUI.UpdateElementTextScaleValue(btn)
end

-----------------------------------------------------------
-- BUFF / DEBUFF TRACKER
-----------------------------------------------------------
function DarkScrollsUI.CreateBuffTrackerUserInterface(trackerName, defaultPos)
    local wm    = WINDOW_MANAGER
    local frame = wm:CreateControl(trackerName, GuiRoot, CT_TOPLEVELCONTROL)
    frame:SetDrawLayer(DL_BACKGROUND)
    frame:SetDrawTier(DT_HIGH)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    frame:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    frame.bg = wm:CreateControl(trackerName.."BG", frame, CT_BACKDROP)
    frame.bg:SetAnchorFill()
    frame.bg:SetCenterColor(0, 1, 0, 0)
    frame.bg:SetEdgeColor(0, 1, 0, 0)

    if not DarkScrollsUI.SavedVariables[trackerName] then DarkScrollsUI.SavedVariables[trackerName] = defaultPos end
    local s = DarkScrollsUI.SavedVariables[trackerName]
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    frame:SetDimensions(s.w, s.h)

    DarkScrollsUI.SetupCommonInterfaceHandlers(frame)

    frame.iconPool = {}
    for i = 1, DarkScrollsUI_MaximumTrackerBuffsCount do
        local iconName = trackerName.."Icon"..i
        local iconCtrl = wm:CreateControl(iconName, frame, CT_CONTROL)

        local tex = wm:CreateControl(iconName.."Tex", iconCtrl, CT_TEXTURE)
        tex:SetAnchorFill()
        iconCtrl.texture = tex

        local border = wm:CreateControl(iconName.."Border", iconCtrl, CT_BACKDROP)
        border:SetAnchorFill()
        border:SetCenterColor(0, 0, 0, 0)
        border:SetEdgeTexture("", 1, 1, 2)
        iconCtrl.border = border

        local timer = wm:CreateControl(iconName.."Timer", iconCtrl, CT_LABEL)
        timer:SetAnchor(BOTTOM, iconCtrl, BOTTOM, 0, 2)
        timer:SetFont("ZoFontWinH5")
        timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        iconCtrl.timer = timer

        iconCtrl:SetHidden(true)
        table.insert(frame.iconPool, iconCtrl)
    end

    return frame
end

function DarkScrollsUI.UpdateBuffTrackerInformation(frame, unitTag)
    if not frame then return end

    local iconSize  = math.max(8, frame:GetHeight())
    local padding   = 4
    local isEditing = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive
    local savedData = DarkScrollsUI.SavedVariables[frame:GetName()]
    local baseAlpha = (savedData and savedData.a) or 1

    frame:SetAlpha(baseAlpha)

    local activeEffects = {}
    for i = 1, GetNumBuffs(unitTag) do
        local bName, _, bFinish, _, _, bIcon, _, effectType = GetUnitBuffInfo(unitTag, i)
        local remain = bFinish - GetFrameTimeSeconds()
        if bIcon and bIcon ~= "" and (remain > 0 or bFinish == 0) then
            table.insert(activeEffects, {
                icon     = bIcon,
                remain   = remain,
                finish   = bFinish,
                isDebuff = (effectType == BUFF_EFFECT_TYPE_DEBUFF),
            })
        end
    end

    if isEditing then
        frame.bg:SetCenterColor(0, 1, 0, 0.3)
        frame.bg:SetEdgeColor(0, 1, 0, 0.8)
        if #activeEffects == 0 then
            local fitCount = math.floor(frame:GetWidth() / (iconSize + padding))
            for i = 1, math.max(1, fitCount) do
                table.insert(activeEffects, {
                    icon     = "/esoui/art/icons/icon_missing.dds",
                    remain   = 9.9,
                    finish   = 10,
                    isDebuff = (i % 2 == 0),
                })
            end
        end
    else
        frame.bg:SetCenterColor(0, 0, 0, 0)
        frame.bg:SetEdgeColor(0, 0, 0, 0)
    end

    for i, iconCtrl in ipairs(frame.iconPool) do
        local effect   = activeEffects[i]
        local currentX = (i - 1) * (iconSize + padding)
        local canFit   = currentX + iconSize <= frame:GetWidth()

        if effect and canFit then
            iconCtrl:SetHidden(false)
            iconCtrl:SetDimensions(iconSize, iconSize)
            iconCtrl:ClearAnchors()
            iconCtrl:SetAnchor(LEFT, frame, LEFT, currentX, 0)
            iconCtrl.texture:SetTexture(effect.icon)
            iconCtrl.border:SetEdgeColor(effect.isDebuff and 1 or 0, effect.isDebuff and 0 or 1, 0, 1)
            iconCtrl.timer:SetText(
                effect.finish == 0 and ""
                or (effect.remain > 10 and string.format("%d", effect.remain) or string.format("%.1f", effect.remain))
            )
        else
            iconCtrl:SetHidden(true)
        end
    end
end

-----------------------------------------------------------
-- WEAPON ICONS (Main / Backup) with Swap Animation
-----------------------------------------------------------
local WEAPON_ANIM_SPEED = 12.0

local function GetWeaponTexture(equipSlot)
    local icon = GetItemInfo(BAG_WORN, equipSlot)
    if not icon or icon == "" or icon == "/esoui/art/icons/icon_missing.dds" then
        return AttributeBarVisualConfiguration.TEX_NO_ICON
    end
    return icon
end

function DarkScrollsUI.CreateWeaponIndicatorIcon(name, defaultPos)
    local wm  = WINDOW_MANAGER
    local btn = _G[name] or wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)
    btn:SetDrawLayer(DL_OVERLAY)
    btn:SetDrawTier(DT_TOP)
    btn:SetClampedToScreen(true)
    btn:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    btn:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    local ICON_PADDING = 6

    btn.bgTex = btn.bgTex or wm:CreateControl(name.."BgTex", btn, CT_TEXTURE)
    btn.bgTex:SetAnchorFill()
    btn.bgTex:SetTexture("DarkScrollsUI/Images/icon_background.dds")
    btn.bgTex:SetDrawLayer(DL_BACKGROUND)

    btn.icon = btn.icon or wm:CreateControl(name.."Icon", btn, CT_TEXTURE)
    btn.icon:ClearAnchors()
    btn.icon:SetAnchor(TOPLEFT, btn, TOPLEFT, ICON_PADDING, ICON_PADDING)
    btn.icon:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, -ICON_PADDING, -ICON_PADDING)
    btn.icon:SetDrawLayer(DL_CONTROLS)

    btn.numberLabel = btn.numberLabel or wm:CreateControl(name.."Number", btn, CT_LABEL)
    btn.numberLabel:SetAnchor(BOTTOMRIGHT, btn, BOTTOMRIGHT, -ICON_PADDING, -ICON_PADDING)
    btn.numberLabel:SetFont("ZoFontWinH4")
    btn.numberLabel:SetColor(1, 1, 1, 1)
    btn.numberLabel:SetDrawLayer(DL_OVERLAY)
    btn.numberLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

if name == "DarkScrollsUI_PrimaryWeaponIndicator" then
        btn.numberLabel:SetText("1")
    elseif name == "DarkScrollsUI_SecondaryWeaponIndicator" then
        btn.numberLabel:SetText("2")
    end

    if not DarkScrollsUI.SavedVariables[name] then DarkScrollsUI.SavedVariables[name] = defaultPos end
    local s = DarkScrollsUI.SavedVariables[name]

    btn.currentX = s.l
    btn.currentY = s.t
    btn.targetX  = s.l
    btn.targetY  = s.t

    btn:ClearAnchors()
    btn:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    btn:SetDimensions(s.w, s.h)

    btn.rotation = s.r or 0
    btn.icon:SetTextureRotation(btn.rotation)
    btn.bgTex:SetTextureRotation(btn.rotation)
    btn:SetAlpha(s.a or 1)

    DarkScrollsUI.SetupCommonInterfaceHandlers(btn)
    DarkScrollsUI.UpdateElementTextScaleValue(btn)
end

function DarkScrollsUI.UpdateWeaponIndicatorIcons()
    local prim = _G["DarkScrollsUI_PrimaryWeaponIndicator"]
    local sec  = _G["DarkScrollsUI_SecondaryWeaponIndicator"]
    if not prim or not sec then return end

    local activePair = GetActiveWeaponPairInfo()
    local isEditing  = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive

    prim.icon:SetTexture(GetWeaponTexture(EQUIP_SLOT_MAIN_HAND))
    sec.icon:SetTexture(GetWeaponTexture(EQUIP_SLOT_BACKUP_MAIN))

    local baseAlphaP = (DarkScrollsUI.SavedVariables["DarkScrollsUI_PrimaryWeaponIndicator"] and DarkScrollsUI.SavedVariables["DarkScrollsUI_PrimaryWeaponIndicator"].a) or 1
    local baseAlphaS = (DarkScrollsUI.SavedVariables["DarkScrollsUI_SecondaryWeaponIndicator"] and DarkScrollsUI.SavedVariables["DarkScrollsUI_SecondaryWeaponIndicator"].a) or 1

    local posA_X, posA_Y = DarkScrollsUI.SavedVariables["DarkScrollsUI_PrimaryWeaponIndicator"].l, DarkScrollsUI.SavedVariables["DarkScrollsUI_PrimaryWeaponIndicator"].t
    local posB_X, posB_Y = DarkScrollsUI.SavedVariables["DarkScrollsUI_SecondaryWeaponIndicator"].l, DarkScrollsUI.SavedVariables["DarkScrollsUI_SecondaryWeaponIndicator"].t
    local sizeA_W, sizeA_H = DarkScrollsUI.SavedVariables["DarkScrollsUI_PrimaryWeaponIndicator"].w, DarkScrollsUI.SavedVariables["DarkScrollsUI_PrimaryWeaponIndicator"].h
    local sizeB_W, sizeB_H = DarkScrollsUI.SavedVariables["DarkScrollsUI_SecondaryWeaponIndicator"].w, DarkScrollsUI.SavedVariables["DarkScrollsUI_SecondaryWeaponIndicator"].h

    if isEditing then
        prim:ClearAnchors()
        prim:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posA_X, posA_Y)
        prim:SetDimensions(sizeA_W, sizeA_H)
        sec:ClearAnchors()
        sec:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posB_X, posB_Y)
        sec:SetDimensions(sizeB_W, sizeB_H)

        prim.currentX, prim.currentY, prim.currentW, prim.currentH = posA_X, posA_Y, sizeA_W, sizeA_H
        sec.currentX, sec.currentY, sec.currentW, sec.currentH     = posB_X, posB_Y, sizeB_W, sizeB_H

        prim:SetDrawLevel(2)
        sec:SetDrawLevel(2)
        prim:SetAlpha(baseAlphaP)
        sec:SetAlpha(baseAlphaS)
        prim.icon:SetDesaturation(0)
        sec.icon:SetDesaturation(0)
        return
    end

    if activePair == ACTIVE_WEAPON_PAIR_MAIN then
        prim.targetX, prim.targetY, prim.targetW, prim.targetH = posA_X, posA_Y, sizeA_W, sizeA_H
        sec.targetX,  sec.targetY,  sec.targetW,  sec.targetH  = posB_X, posB_Y, sizeB_W, sizeB_H
        
        -- Garante que a arma principal sobreponha a secundária
        prim:SetDrawLevel(2)
        sec:SetDrawLevel(1)
        prim:BringWindowToTop()
        
        prim:SetAlpha(baseAlphaP)
        prim.icon:SetDesaturation(0)
        sec:SetAlpha(baseAlphaS * 0.5)
        sec.icon:SetDesaturation(0.7)
    else
        prim.targetX, prim.targetY, prim.targetW, prim.targetH = posB_X, posB_Y, sizeB_W, sizeB_H
        sec.targetX,  sec.targetY,  sec.targetW,  sec.targetH  = posA_X, posA_Y, sizeA_W, sizeA_H
        
        -- Garante que a arma secundária sobreponha a principal
        sec:SetDrawLevel(2)
        prim:SetDrawLevel(1)
        sec:BringWindowToTop()
        
        sec:SetAlpha(baseAlphaS)
        sec.icon:SetDesaturation(0)
        prim:SetAlpha(baseAlphaP * 0.5)
        prim.icon:SetDesaturation(0.7)
    end
end

function DarkScrollsUI.TickWeaponSwapAnimation(dt)
    local isEditing = not DarkScrollsUI.isInterfaceLocked or DarkScrollsUI.isGlobalEditModeActive

    for _, name in ipairs({"DarkScrollsUI_PrimaryWeaponIndicator", "DarkScrollsUI_SecondaryWeaponIndicator"}) do
        local btn = _G[name]
        if btn then
            if isEditing then
                btn.currentX = btn:GetLeft()
                btn.currentY = btn:GetTop()
                btn.currentW = btn:GetWidth()
                btn.currentH = btn:GetHeight()
            else
                if btn.targetX and btn.targetY then
                    btn.currentX = btn.currentX + (btn.targetX - btn.currentX) * math.min(1, WEAPON_ANIM_SPEED * dt)
                    btn.currentY = btn.currentY + (btn.targetY - btn.currentY) * math.min(1, WEAPON_ANIM_SPEED * dt)

                    if math.abs(btn.targetX - btn.currentX) < 0.5 then btn.currentX = btn.targetX end
                    if math.abs(btn.targetY - btn.currentY) < 0.5 then btn.currentY = btn.targetY end

                    if btn.targetW and btn.targetH then
                        btn.currentW = btn.currentW or btn:GetWidth()
                        btn.currentH = btn.currentH or btn:GetHeight()
                        btn.currentW = btn.currentW + (btn.targetW - btn.currentW) * math.min(1, WEAPON_ANIM_SPEED * dt)
                        btn.currentH = btn.currentH + (btn.targetH - btn.currentH) * math.min(1, WEAPON_ANIM_SPEED * dt)
                        if math.abs(btn.targetW - btn.currentW) < 0.5 then btn.currentW = btn.targetW end
                        if math.abs(btn.targetH - btn.currentH) < 0.5 then btn.currentH = btn.targetH end
                        btn:SetDimensions(btn.currentW, btn.currentH)
                    end

                    btn:ClearAnchors()
                    btn:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, btn.currentX, btn.currentY)
                end
            end
        end
    end
end

-----------------------------------------------------------
-- COMPASS (hijack of native ZO_CompassFrame)
-----------------------------------------------------------

-- ZO_CompassFrame is a C userdata, not a Lua table, so rawget/rawset cannot
-- be used on it. We store the original anchor functions in a plain Lua table
-- before anything (including this addon) can override them on the object.
local CompassRealAnchors = {}

local function ApplyCompassAnchor(ctrl)
    if not ZO_CompassFrame or not ZO_CompassContainer then return end
    -- Fall back to whatever is on the object if we somehow missed saving them.
    local clearFn = CompassRealAnchors.ClearAnchors or ZO_CompassFrame.ClearAnchors
    local setFn   = CompassRealAnchors.SetAnchor    or ZO_CompassFrame.SetAnchor
    clearFn(ZO_CompassFrame)
    setFn(ZO_CompassFrame, CENTER, ctrl, CENTER, 0, 0)
    ZO_CompassFrame:SetWidth(600)
    ZO_CompassContainer:SetWidth(600)
    ZO_CompassFrame:SetScale(math.max(0.1, ctrl:GetWidth() / 600))
end

function DarkScrollsUI.CreateCompassUserInterface(name, defaultPos)
    local wm   = WINDOW_MANAGER
    local ctrl = _G[name] or wm:CreateControl(name, GuiRoot, CT_TOPLEVELCONTROL)

    ctrl:SetDrawLayer(DL_BACKGROUND)
    ctrl:SetDrawTier(DT_HIGH)
    ctrl:SetClampedToScreen(true)
    ctrl:SetMouseEnabled(not DarkScrollsUI.isInterfaceLocked)
    ctrl:SetMovable(not DarkScrollsUI.isInterfaceLocked)

    if not DarkScrollsUI.SavedVariables[name] then DarkScrollsUI.SavedVariables[name] = defaultPos end
    local s = DarkScrollsUI.SavedVariables[name]

    ctrl:ClearAnchors()
    ctrl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.l, s.t)
    ctrl:SetDimensions(s.w or 400, s.h or 40)
    ctrl:SetAlpha(s.a or 1)

    ctrl.bg = ctrl.bg or wm:CreateControl(name.."BG", ctrl, CT_BACKDROP)
    ctrl.bg:SetAnchorFill()
    ctrl.bg:SetCenterColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.4)
    ctrl.bg:SetEdgeColor(0, 1, 0, DarkScrollsUI.isInterfaceLocked and 0 or 0.8)
    ctrl.bg:SetEdgeTexture("", 1, 1, 2)

    -- Capture the real anchor functions into our Lua table before any override.
    -- This runs once; subsequent calls to CreateCompassUserInterface are no-ops
    -- for this block because the table is already populated.
    if ZO_CompassFrame and not CompassRealAnchors.ClearAnchors then
        CompassRealAnchors.ClearAnchors = ZO_CompassFrame.ClearAnchors
        CompassRealAnchors.SetAnchor    = ZO_CompassFrame.SetAnchor
    end

    -- Per-frame OnUpdate: re-anchors ZO_CompassFrame every frame so that any
    -- engine-level reset (zone change, loading screen, scene transition) is
    -- corrected within one frame, making the saved position effectively permanent.
    ctrl:SetHandler("OnUpdate", function(self)
        ApplyCompassAnchor(self)
    end)

    ctrl:SetHandler("OnMoveStop", function(self)
        if DarkScrollsUI.SaveElementControlChanges then DarkScrollsUI.SaveElementControlChanges(self, false) end
        if DarkScrollsUI.UpdateElementTextScaleValue then DarkScrollsUI.UpdateElementTextScaleValue(self) end
    end)

    ctrl:SetHandler("OnMouseWheel", function(self, delta)
        if DarkScrollsUI.OnMouseWheelInteractionEvent then DarkScrollsUI.OnMouseWheelInteractionEvent(self, delta) end
    end)

    if DarkScrollsUI.UpdateElementTextScaleValue then DarkScrollsUI.UpdateElementTextScaleValue(ctrl) end
end

-- Kept for backward compatibility (called from DS_Init.lua on EVENT_PLAYER_ACTIVATED).
-- The OnUpdate already handles continuous correction; this just forces an instant apply.
function DarkScrollsUI.UpdateCompassElementAnchors()
    local ctrl = _G["DarkScrollsUI_CompassNavigationFrame"]
    if ctrl then ApplyCompassAnchor(ctrl) end
end
