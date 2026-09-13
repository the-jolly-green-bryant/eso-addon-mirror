TetsuArcanistCrux = TetsuArcanistCrux or {}
local T = TetsuArcanistCrux

local ADDON = "TetsuArcanistCruxUI"

-- Official in-game spender names (eso-hub localized pages / RAWR / DMM / tesowiki).
-- Generators (Flail, Destiny chakram, Cruxweaver, Runemend, Runeblades) are NOT listed.
local SPEND_NEEDLE = {
    -- Fatecarver + morphs
    "fatecarver",
    "schicksalsschnitzer",
    "sculpte-destin",
    "forjador del destino",
    "tallador del destino",
    "резчик судеб", "резчик судьбы", "ослабляющий резчик", "прагматичный резчик",
    "運命の彫刻家",
    "命运雕刻",
    -- Tentacular Dread only
    "tentacular dread",
    "tentakelschrecken",
    "effroi tentaculaire",
    "pavor tentacular",
    "ужасное щупальце", "ужас щупалец",
    "触手の恐怖",
    "触手之",
    -- Remedy Cascade + morphs
    "remedy cascade", "cascading fortune", "curative surge",
    "arzneikaskade", "kaskadierendes geschick", "kurative woge",
    "cascade curative", "fortune en cascade", "surtension curatrice",
    "cascada del remedio", "fortuna en cascada", "oleada curativa",
    "животворный каскад", "неумолимая судьба", "лечебный прилив",
    "救済のカスケード", "連なる幸運",
    -- Tidal Chakram only (not Destiny / base shields)
    "tidal chakram",
    "gezeitenchakra",
    "chakrams des marées",
    "chakram de la marea",
    "чакры приливов",
    "潮のチャクラム",
    -- Unbreakable Fate
    "unbreakable fate",
    "unumstößliches schicksal", "unumstossliches schicksal",
    "destin inévitable",
    "destino inquebrantable",
    "нерушимая судьба",
    -- Runespite Ward family
    "runespite", "impervious runeward", "spiteward",
    "runentrotzschutz", "undurchdringlicher runenschutz",
    "geisterschutz des brillanten",
    "garde-rancœur", "garde rancoeur", "garde runique implacable",
    "custodia de rencor",
    "щит рунной злобы", "непроницаемый рунный щит", "оберег ясного ума", "оберег рунной злобы",
    "ルーンの反撃結界",
}

local SPEND_IDS = {
    [185805] = true, [183122] = true, [183123] = true, [183124] = true,
    [186361] = true, [186366] = true, [186367] = true, [186368] = true,
    [185809] = true, [185811] = true,
    [183537] = true, [185817] = true, [198309] = true,
}

local root
local iconRoot
local numRoot
local icons = {}
local iconHolders = {}
local numLab
local barOverlays = {}
local built = false

local COL_IDLE = { 0.82, 0.86, 0.78, 0.38 }
-- 1 stack: saturated arcanist green, not the pale mint from Crux Counter.
local COL_ONE  = { 0.04, 0.78, 0.10, 1 }
local TEX_RUNES = {
    "/art/fx/texture/arcanist_trianglerune_01.dds",
    "art/fx/texture/arcanist_trianglerune_01.dds",
}
local TEX_TRI_FB = "TetsuArcanistCrux/textures/triangle.dds"
local runePathReady = nil

local function Vars()
    return T.savedVars
end

local function Lower(s)
    if type(s) ~= "string" then return "" end
    if zo_strlower then return zo_strlower(s) end
    return string.lower(s)
end

local function SceneIsShowing(scene)
    if not scene or not scene.IsShowing then return false end
    local ok, showing = pcall(function()
        return scene:IsShowing()
    end)
    return ok and showing and true or false
end

local function WorldHudOpen()
    if HUD_SCENE or HUD_UI_SCENE then
        return SceneIsShowing(HUD_SCENE) or SceneIsShowing(HUD_UI_SCENE)
    end
    return true
end

local function Previewing(kind)
    return T.IsPreviewing and T.IsPreviewing(kind)
end

local function InCombat()
    if not IsUnitInCombat then return false end
    local ok, v = pcall(IsUnitInCombat, "player")
    return ok and v and true or false
end

local function CombatGateOpen()
    if Previewing("all") or Previewing("icons") or Previewing("number") or Previewing("bar") then
        return true
    end
    local v = Vars()
    if v and v.combatOnly == false then
        return true
    end
    return InCombat()
end

local function ClampPct(p, fallback)
    p = tonumber(p)
    if p == nil then p = fallback end
    if p < 0 then p = 0 end
    if p > 100 then p = 100 end
    return p / 100
end

local function IconAlphaOf(count)
    local v = Vars()
    if count >= 3 then
        return ClampPct(v and v.iconAlpha3, 100)
    end
    return ClampPct(v and v.iconAlpha12, 50)
end

local function NumAlphaOf(count)
    local v = Vars()
    if count >= 3 then
        return ClampPct(v and v.numAlpha3, 100)
    end
    return ClampPct(v and v.numAlpha12, 50)
end

local function ApplyIconBlend(ic)
    if not ic or not ic.SetBlendMode then return end
    local mode = TEX_BLEND_MODE_ALPHA
    if mode then
        pcall(ic.SetBlendMode, ic, mode)
    end
end

local function SetRuneTexture(ic)
    if not ic or not ic.SetTexture then return end
    if runePathReady then
        pcall(ic.SetTexture, ic, runePathReady)
        return
    end
    for i = 1, #TEX_RUNES do
        if pcall(ic.SetTexture, ic, TEX_RUNES[i]) then
            runePathReady = TEX_RUNES[i]
            return
        end
    end
    pcall(ic.SetTexture, ic, TEX_TRI_FB)
    runePathReady = TEX_TRI_FB
end

local function IconsOn()
    local v = Vars()
    return v and v.showIcons ~= false
end

local function NumberOn()
    local v = Vars()
    return v and v.showNumber == true
end

local function BarOn()
    local v = Vars()
    return v and v.showBar ~= false
end

local function ColorOf(count)
    local v = Vars()
    if count >= 3 and v and type(v.color3) == "table" then
        return v.color3
    end
    if count >= 2 and v and type(v.color2) == "table" then
        return v.color2
    end
    if count >= 1 then
        return COL_ONE
    end
    return COL_IDLE
end

local function Unpack(c, aOverride)
    if type(c) ~= "table" then
        return 1, 1, 1, aOverride or 1
    end
    return tonumber(c[1]) or 1, tonumber(c[2]) or 1, tonumber(c[3]) or 1, aOverride or tonumber(c[4]) or 1
end

local function NameLooksLikeSpender(name)
    local n = Lower(name)
    if n == "" then return false end
    for i = 1, #SPEND_NEEDLE do
        if n:find(SPEND_NEEDLE[i], 1, true) then
            return true
        end
    end
    return false
end

local function ActiveHotbar()
    if GetActiveHotbarCategory then
        local ok, cat = pcall(GetActiveHotbarCategory)
        if ok and cat ~= nil then return cat end
    end
    return HOTBAR_CATEGORY_PRIMARY or 0
end

local function BackupHotbar()
    local a = ActiveHotbar()
    if HOTBAR_CATEGORY_BACKUP and a == (HOTBAR_CATEGORY_PRIMARY or 0) then
        return HOTBAR_CATEGORY_BACKUP
    end
    if HOTBAR_CATEGORY_PRIMARY and a == HOTBAR_CATEGORY_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    return HOTBAR_CATEGORY_BACKUP or 1
end

local function ResolveSlotId(slot, cat)
    local bound = 0
    if GetSlotBoundId then
        if cat ~= nil then
            local ok, id = pcall(GetSlotBoundId, slot, cat)
            if ok then bound = tonumber(id) or 0 end
        end
        if bound == 0 then
            local ok, id = pcall(GetSlotBoundId, slot)
            if ok then bound = tonumber(id) or 0 end
        end
        if bound == 0 and cat == nil then
            local ok2, ac = pcall(GetActiveHotbarCategory)
            if ok2 then
                local ok3, id2 = pcall(GetSlotBoundId, slot, ac)
                if ok3 then bound = tonumber(id2) or bound end
            end
        end
    end
    local st = nil
    if GetSlotType then
        local ok, t = pcall(GetSlotType, slot)
        if ok then st = t end
    end
    if bound ~= 0 and ACTION_TYPE_CRAFTED_ABILITY and st == ACTION_TYPE_CRAFTED_ABILITY then
        if GetAbilityIdForCraftedAbilityId then
            local ok, real = pcall(GetAbilityIdForCraftedAbilityId, bound)
            if ok and tonumber(real) and tonumber(real) > 0 then
                return tonumber(real)
            end
        end
    end
    return bound
end

local function SlotIsSpender(slot, cat)
    local id = ResolveSlotId(slot, cat)
    if id ~= 0 and SPEND_IDS[id] then return true, id end
    if id ~= 0 and GetAbilityName then
        local ok, name = pcall(GetAbilityName, id)
        if ok and NameLooksLikeSpender(name) then
            SPEND_IDS[id] = true
            return true, id
        end
    end
    if GetSlotName then
        local ok2, name2 = pcall(GetSlotName, slot, cat)
        if not ok2 then
            ok2, name2 = pcall(GetSlotName, slot)
        end
        if ok2 and NameLooksLikeSpender(name2) then
            return true, id
        end
    end
    return false, id
end

-- Each entry: { slot = 3..8, back = false|true }
-- back = FancyActionBar+ inactive row (buttons[slot+20]).
local function CollectSpenderTargets()
    local out = {}
    local frontCat = ActiveHotbar()
    local backCat = BackupHotbar()
    for slot = 3, 8 do
        if SlotIsSpender(slot, frontCat) or SlotIsSpender(slot) then
            out[#out + 1] = { slot = slot, back = false }
        end
        if SlotIsSpender(slot, backCat) then
            out[#out + 1] = { slot = slot, back = true }
        end
    end
    return out
end

local function OverlayKey(slot, back)
    if back then return slot + 20 end
    return slot
end

local function HideAllBars()
    for k, ov in pairs(barOverlays) do
        if ov then ov:SetHidden(true) end
    end
end

local function BarAlphaOf(count)
    local v = Vars()
    local a
    if count >= 3 then
        a = tonumber(v and v.barAlpha3) or 40
    else
        a = tonumber(v and v.barAlpha2) or 20
    end
    if a < 10 then a = 10 end
    if a > 90 then a = 90 end
    return a
end

local function ControlFromFabButton(btn)
    if not btn then return nil end
    if btn.slot then return btn.slot end
    if btn.GetNamedChild then
        local ic = btn:GetNamedChild("Button") or btn:GetNamedChild("Icon")
        if ic then return ic end
    end
    return btn
end

local function ActionButtonControl(slot, back)
    if not slot or slot < 1 then return nil end
    local FAB = _G.FancyActionBar
    if back then
        if FAB and FAB.buttons and FAB.buttons[slot + 20] then
            local c = ControlFromFabButton(FAB.buttons[slot + 20])
            if c then return c end
        end
        if FAB and FAB.GetActionButton then
            local ok, btn = pcall(FAB.GetActionButton, slot + 20)
            if ok then
                local c = ControlFromFabButton(btn)
                if c then return c end
            end
        end
        return nil
    end
    if FAB and FAB.GetActionButton then
        local ok, btn = pcall(FAB.GetActionButton, slot)
        if ok then
            local c = ControlFromFabButton(btn)
            if c then return c end
        end
    end
    if ZO_ActionBar_GetButton then
        local ok, btn = pcall(ZO_ActionBar_GetButton, slot)
        if ok and btn then
            local c = ControlFromFabButton(btn)
            if c then return c end
        end
    end
    local names = {
        "ActionButton" .. slot,
        "ZO_ActionBar1Button" .. slot,
    }
    for i = 1, #names do
        local c = _G[names[i]]
        if c then return c end
    end
    if GetControl then
        local c = GetControl("ActionButton" .. slot)
        if c then return c end
    end
    local bar = _G.ZO_ActionBar1
    if bar and bar.GetNamedChild then
        local child = bar:GetNamedChild("Button" .. slot)
            or bar:GetNamedChild("ActionButton" .. slot)
        if child then return child end
    end
    return nil
end

local function LayoutIcons(count)
    if not iconRoot then return end
    local v = Vars()
    local size = tonumber(v and v.iconSize) or 30
    if size < 24 then size = 24 end
    if size > 96 then size = 96 end
    local ox = tonumber(v and v.iconX) or 0
    local oy = tonumber(v and v.iconY) or 0
    local layout = v and v.iconLayout or "triangle"
    local radius = tonumber(v and v.iconRadius) or 50
    if radius < 24 then radius = 24 end
    if radius > 180 then radius = 180 end
    count = tonumber(count) or 0
    if count < 0 then count = 0 end
    if count > 3 then count = 3 end

    iconRoot:ClearAnchors()
    iconRoot:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)

    local gap = math.floor(size * 0.12 + 0.5)
    local step = size + gap
    for i = 1, 3 do
        local hold = iconHolders[i] or icons[i]
        local ic = icons[i]
        if hold then
            hold:SetDimensions(size, size)
            hold:ClearAnchors()
            if ic and ic ~= hold then
                ic:ClearAnchors()
                ic:SetAnchor(TOPLEFT, hold, TOPLEFT, 0, 0)
                ic:SetAnchor(BOTTOMRIGHT, hold, BOTTOMRIGHT, 0, 0)
            end
            if layout == "triangle" then
                -- Same three vertices for 1/2/3 so a single rune sits on the
                -- bottom point (radius from origin), not on the reticle.
                local pos = {
                    { 0, radius * 0.78 },
                    { -radius * 0.78, -radius * 0.42 },
                    {  radius * 0.78, -radius * 0.42 },
                }
                local slot
                if count <= 1 then
                    slot = pos[1]
                elseif count == 2 then
                    slot = pos[i + 1]
                else
                    slot = pos[i]
                end
                if slot then
                    hold:SetAnchor(CENTER, iconRoot, CENTER, slot[1], slot[2])
                end
            elseif layout == "rowV" then
                local y = (i - (count + 1) / 2) * step
                hold:SetAnchor(CENTER, iconRoot, CENTER, 0, y)
            else
                local x = (i - (count + 1) / 2) * step
                hold:SetAnchor(CENTER, iconRoot, CENTER, x, 0)
            end
        end
    end
end

local function LayoutNumber()
    if not numRoot or not numLab then return end
    local v = Vars()
    local size = tonumber(v and v.numberSize) or 42
    if size < 18 then size = 18 end
    if size > 96 then size = 96 end
    local ox = tonumber(v and v.numberX) or 0
    local oy = tonumber(v and v.numberY) or 0
    numRoot:ClearAnchors()
    numRoot:SetAnchor(CENTER, GuiRoot, CENTER, ox, oy)
    numLab:SetFont("$(GAMEPAD_MEDIUM_FONT)|" .. size .. "|soft-shadow-thick")
    numLab:ClearAnchors()
    numLab:SetAnchor(CENTER, numRoot, CENTER, 0, 0)
    numLab:SetDimensions(size * 2, size + 8)
end

local function PlaceBarOverlay(ov, slot, back)
    if not ov then return false end
    local host = ActionButtonControl(slot, back)
    ov:ClearAnchors()
    if host then
        ov:SetAnchor(TOPLEFT, host, TOPLEFT, -3, -3)
        ov:SetAnchor(BOTTOMRIGHT, host, BOTTOMRIGHT, 3, 3)
        return true
    end
    -- No host (settings scene / hidden bar): do not park a stray plate on GuiRoot.
    ov:SetHidden(true)
    return false
end

local function UpdateBarOverlay(count)
    HideAllBars()
    count = tonumber(count) or 0
    -- Tint only exists at 2 and 3. Preview must follow the same rule,
    -- otherwise step 0/1 already paints the 3-crux color.
    local previewBar = Previewing("bar") or Previewing("all")
    local show = (BarOn() or previewBar) and count >= 2
    if not show then return end
    local targets = CollectSpenderTargets()
    if #targets < 1 and previewBar then
        targets = { { slot = 3, back = false } }
    end
    if #targets < 1 then return end
    local a = BarAlphaOf(count)
    local col = ColorOf(count)
    local r, g, b = Unpack(col)
    for i = 1, #targets do
        local slot = targets[i].slot
        local back = targets[i].back and true or false
        local key = OverlayKey(slot, back)
        local ov = barOverlays[key]
        if ov and PlaceBarOverlay(ov, slot, back) then
            ov:SetCenterColor(r, g, b, a / 100)
            ov:SetEdgeColor(r, g, b, math.min(1, a / 70))
            ov:SetHidden(false)
        end
    end
end

local function UpdateIcons(count)
    if not iconRoot then return end
    local show = IconsOn() or Previewing("icons") or Previewing("all")
    if not show or count < 1 then
        iconRoot:SetHidden(true)
        for i = 1, 3 do
            if iconHolders[i] then iconHolders[i]:SetHidden(true) end
            if icons[i] then icons[i]:SetHidden(true) end
        end
        return
    end
    iconRoot:SetHidden(false)
    local colAll = ColorOf(count)
    local a = IconAlphaOf(count)
    local r, g, b = Unpack(colAll)
    for i = 1, 3 do
        local ic = icons[i]
        local hold = iconHolders[i]
        if ic then
            if i <= count then
                SetRuneTexture(ic)
                ApplyIconBlend(ic)
                -- Color stays fully opaque; opacity lives on the holder.
                -- FX textures often ignore SetAlpha on the texture itself.
                ic:SetColor(r, g, b, 1)
                ic:SetAlpha(1)
                ic:SetHidden(false)
                if hold then
                    hold:SetAlpha(a)
                    hold:SetHidden(false)
                end
            else
                ic:SetHidden(true)
                if hold then hold:SetHidden(true) end
            end
        end
    end
end

local function UpdateNumber(count)
    if not numRoot or not numLab then return end
    local show = NumberOn() or Previewing("number") or Previewing("all")
    if not show or count < 1 then
        numRoot:SetHidden(true)
        return
    end
    numRoot:SetHidden(false)
    local r, g, b = Unpack(ColorOf(count))
    numLab:SetText(tostring(count or 0))
    numLab:SetColor(r, g, b, 1)
    numLab:SetAlpha(NumAlphaOf(count))
end

local function ShouldShowHud()
    if Previewing("all") or Previewing("icons") or Previewing("number") or Previewing("bar") then
        return true
    end
    if not WorldHudOpen() then return false end
    if not CombatGateOpen() then return false end
    return IconsOn() or NumberOn() or BarOn()
end

function T.UIRefresh()
    if not built then return end
    local count = 0
    if T.GetDisplayStacks then
        count = T.GetDisplayStacks() or 0
    end
    local vis = ShouldShowHud()
    if root then root:SetHidden(not vis) end
    LayoutIcons(count)
    LayoutNumber()
    UpdateIcons(count)
    UpdateNumber(count)
    UpdateBarOverlay(count)
    if not vis then
        if iconRoot then iconRoot:SetHidden(true) end
        if numRoot then numRoot:SetHidden(true) end
        HideAllBars()
    end
end

function T.UIPulse()
    if BarOn() or Previewing("bar") or Previewing("all") then
        local count = T.GetDisplayStacks and T.GetDisplayStacks() or 0
        UpdateBarOverlay(count)
    end
end

function T.EnsureVisible()
    if root then root:SetHidden(false) end
    T.UIRefresh()
end

local function OnSlotUpdated()
    T.UIRefresh()
end

local function Build()
    if built then return end
    local wm = GetWindowManager()
    if not wm then return end

    root = wm:CreateTopLevelWindow(ADDON .. "Root")
    if not root then
        root = wm:CreateControl(ADDON .. "Root", GuiRoot, CT_TOPLEVELCONTROL)
    end
    if not root then return end
    root:SetParent(GuiRoot)
    root:SetHidden(true)
    root:SetMouseEnabled(false)
    root:SetMovable(false)
    root:SetClampedToScreen(false)
    root:SetDrawLayer(DL_CONTROLS)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLevel(4)
    root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 0, 0)
    root:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, 0)

    iconRoot = wm:CreateControl(ADDON .. "Icons", root, CT_CONTROL)
    iconRoot:SetDimensions(1, 1)
    iconRoot:SetHidden(true)
    iconRoot:SetMouseEnabled(false)

    for i = 1, 3 do
        local hold = wm:CreateControl(ADDON .. "IconHold" .. i, iconRoot, CT_CONTROL)
        hold:SetDimensions(30, 30)
        hold:SetHidden(true)
        hold:SetMouseEnabled(false)
        hold:SetAlpha(1)
        local ic = wm:CreateControl(ADDON .. "Icon" .. i, hold, CT_TEXTURE)
        ic:SetAnchor(TOPLEFT, hold, TOPLEFT, 0, 0)
        ic:SetAnchor(BOTTOMRIGHT, hold, BOTTOMRIGHT, 0, 0)
        SetRuneTexture(ic)
        ic:SetHidden(true)
        ic:SetMouseEnabled(false)
        ApplyIconBlend(ic)
        iconHolders[i] = hold
        icons[i] = ic
    end

    numRoot = wm:CreateControl(ADDON .. "Num", root, CT_CONTROL)
    numRoot:SetDimensions(80, 80)
    numRoot:SetHidden(true)
    numRoot:SetMouseEnabled(false)
    numLab = wm:CreateControl(ADDON .. "NumLab", numRoot, CT_LABEL)
    numLab:SetFont("$(GAMEPAD_MEDIUM_FONT)|42|soft-shadow-thick")
    numLab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    numLab:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    numLab:SetColor(1, 1, 1, 1)
    numLab:SetText("0")
    numLab:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    numLab:SetMouseEnabled(false)

    local function MakeBarPlate(key)
        local ov = wm:CreateControl(ADDON .. "Bar" .. key, root, CT_BACKDROP)
        ov:SetCenterColor(1, 0.85, 0.15, 0.30)
        ov:SetEdgeColor(1, 0.85, 0.15, 0.7)
        ov:SetEdgeTexture("", 2, 2, 3)
        ov:SetInsets(2, 2, 2, 2)
        ov:SetHidden(true)
        ov:SetMouseEnabled(false)
        ov:SetDrawLevel(6)
        barOverlays[key] = ov
    end
    for slot = 3, 8 do
        MakeBarPlate(slot)
        MakeBarPlate(slot + 20) -- FancyActionBar+ inactive row
    end

    built = true
end

function T.UIStart()
    Build()
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ACTION_SLOT_UPDATED, OnSlotUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnSlotUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnSlotUpdated)
    EVENT_MANAGER:RegisterForEvent(ADDON, EVENT_PLAYER_ACTIVATED, function()
        T.UIRefresh()
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON .. "Combat", EVENT_PLAYER_COMBAT_STATE, function()
        T.UIRefresh()
    end)
    if SCENE_MANAGER and SCENE_MANAGER.RegisterCallback then
        pcall(function()
            SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
                T.UIRefresh()
            end)
        end)
    end
    T.UIRefresh()
end
