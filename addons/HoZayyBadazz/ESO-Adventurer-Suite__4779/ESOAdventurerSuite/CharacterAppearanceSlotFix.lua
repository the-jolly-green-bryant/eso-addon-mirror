-- ESO Adventurer Suite
-- v0.29.682 - Restore ESO's native Appearance / Disguise equipment slot.
-- The customized Character Gear layout previously hid ZO_CharacterEquipmentSlotsCostume
-- and replaced it with a Collections-only button.  That removed ESO's native path
-- for interacting with an equipped disguise.  Keep the Suite layout, but mount the
-- real native slot inside the Suite Appearance utility cell so normal ESO click,
-- tooltip and unequip/context behavior remain authoritative.

local EPC = ESOProgressionCoach
if not EPC or not EPC.CharacterGearScreen or not WINDOW_MANAGER then return end
local G = EPC.CharacterGearScreen
local wm = WINDOW_MANAGER
local NS = (EPC.name or "ESOAdventurerSuite") .. "_CharacterAppearanceSlot029682"

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d
end

local function raise(control, level)
    if not control then return end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then
        pcall(control.SetDrawTier, control, DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" then
        local layer = rawget(_G, "DL_OVERLAY") or rawget(_G, "DL_CONTROLS")
        if layer ~= nil then pcall(control.SetDrawLayer, control, layer) end
    end
    if type(control.SetDrawLevel) == "function" then
        pcall(control.SetDrawLevel, control, tonumber(level) or 850)
    end
end

local function ensureLabel(cell)
    if not cell then return nil end
    if cell.easNativeAppearanceLabel029682 then return cell.easNativeAppearanceLabel029682 end

    local label = wm:CreateControl(NS .. "Label", cell, CT_LABEL)
    label:SetAnchor(TOP, cell, BOTTOM, 0, 2)
    label:SetDimensions(150, 20)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("ZoFontGameSmall")
    label:SetColor(1, 0.82, 0.26, 1)
    label:SetText("Appearance")
    label:SetMouseEnabled(false)
    raise(label, 860)
    cell.easNativeAppearanceLabel029682 = label
    return label
end

local function restoreNativeAppearanceSlot()
    local cell = G.weaponUtilityCells and G.weaponUtilityCells.Appearance
    local slot = rawget(_G, "ZO_CharacterEquipmentSlotsCostume")
    if not cell or not slot then return false end

    -- The Suite shell becomes presentation-only.  The native ESO slot owns all
    -- mouse interaction so disguises can be removed exactly as they can with the
    -- addon disabled.  Never synthesize an unequip action here.
    if type(cell.SetMouseEnabled) == "function" then pcall(cell.SetMouseEnabled, cell, false) end
    if cell.icon and type(cell.icon.SetHidden) == "function" then pcall(cell.icon.SetHidden, cell.icon, true) end
    if cell.bg then
        if type(cell.bg.SetCenterColor) == "function" then pcall(cell.bg.SetCenterColor, cell.bg, 0.025, 0.030, 0.040, 0.90) end
        if type(cell.bg.SetEdgeColor) == "function" then pcall(cell.bg.SetEdgeColor, cell.bg, 0.72, 0.64, 0.40, 0.88) end
    end

    local width = tonumber(safeCall(cell.GetWidth, cell)) or 68
    local height = tonumber(safeCall(cell.GetHeight, cell)) or width
    local size = math.max(48, math.min(128, math.min(width, height)))

    if type(slot.SetScale) == "function" then pcall(slot.SetScale, slot, 1) end
    if type(slot.ClearAnchors) == "function" then pcall(slot.ClearAnchors, slot) end
    if type(slot.SetAnchor) == "function" then pcall(slot.SetAnchor, slot, CENTER, cell, CENTER, 0, 0) end
    if type(slot.SetDimensions) == "function" then pcall(slot.SetDimensions, slot, size, size) end
    if type(slot.SetMouseEnabled) == "function" then pcall(slot.SetMouseEnabled, slot, true) end
    if type(slot.SetHidden) == "function" then pcall(slot.SetHidden, slot, false) end
    raise(slot, 855)

    -- Keep the old "Equipped Apparel Hidden" status text suppressed as requested
    -- by the custom Character Gear design.  A small Suite label identifies the
    -- restored native slot without resurrecting that unwanted native message.
    local apparelText = rawget(_G, "ZO_CharacterApparelSectionText")
    if apparelText and type(apparelText.SetHidden) == "function" then pcall(apparelText.SetHidden, apparelText, true) end
    local label = ensureLabel(cell)
    if label then
        label:SetHidden(false)
        raise(label, 860)
    end

    G.nativeAppearanceSlot029682 = slot
    return true
end

if type(G.LayoutWeaponUtilityCells) == "function" and not G._nativeAppearanceSlotFix029682 then
    local baseLayoutWeaponUtilityCells = G.LayoutWeaponUtilityCells
    function G:LayoutWeaponUtilityCells(...)
        local result = baseLayoutWeaponUtilityCells(self, ...)
        restoreNativeAppearanceSlot()
        return result
    end
    G._nativeAppearanceSlotFix029682 = true
end

-- Hide the detached native slot whenever the Suite utility cells are hidden.
-- RestorePlayerState() immediately restores ESO's original geometry/state when
-- the Character scene closes or the feature is disabled.
if type(G.HideWeaponUtilityCells) == "function" and not G._nativeAppearanceHideFix029682 then
    local baseHideWeaponUtilityCells = G.HideWeaponUtilityCells
    function G:HideWeaponUtilityCells(...)
        local result = baseHideWeaponUtilityCells(self, ...)
        local slot = rawget(_G, "ZO_CharacterEquipmentSlotsCostume")
        if slot and type(slot.SetHidden) == "function" then pcall(slot.SetHidden, slot, true) end
        local cell = self.weaponUtilityCells and self.weaponUtilityCells.Appearance
        local label = cell and cell.easNativeAppearanceLabel029682
        if label and type(label.SetHidden) == "function" then pcall(label.SetHidden, label, true) end
        return result
    end
    G._nativeAppearanceHideFix029682 = true
end

-- Apply immediately if the Character/Inventory equipment scene is already open.
restoreNativeAppearanceSlot()
if G.IsPlayerSceneShowing and G:IsPlayerSceneShowing() and G.RequestRefresh then
    G:RequestRefresh(0)
end

EPC.characterAppearanceSlotFix029682 = true
