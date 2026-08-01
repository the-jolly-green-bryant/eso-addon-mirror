-- BuildTracker_SetPickerUI.lua
--
-- A small popup for picking a set to assign to one build slot. The set list
-- is 600+ entries, so a plain unfiltered dropdown is unusable - this wraps
-- a stock ZO_ComboBox with LibScrollableMenu's AddCustomScrollableComboBoxDropdownMenu
-- (enableFilter = true) for type-to-search, the same widget LibSets' own
-- SearchUI uses for its filter dropdowns (LibSets_SearchUI_Keyboard.lua:536).
--
-- If the chosen set has multiple current pieces for this slot's equipType
-- (an armor-weight or weapon-type ambiguity - see PROJECT_STATUS.md gotchas
-- #5 and #10), a small disambiguation row appears instead of closing
-- immediately.
--
-- Built from raw control types, same as BuildTracker_ExportImportUI.lua -
-- the ZO_ComboBox container is the one exception, created via
-- CreateControlFromVirtual since "ZO_ComboBox" is a base-game virtual
-- template (confirmed by LibAddonMenu-2.0's own dropdown.lua doing the same
-- thing with zero XML), not something requiring an addon-authored XML file.

BuildTracker = BuildTracker or {}
BuildTracker.UI = BuildTracker.UI or {}

local UI = BuildTracker.UI
local window -- lazily created singleton popup

-- Tracks whether ANY set has ever been picked this session (across every
-- slot/build) - used to switch the combobox's closed-state placeholder from
-- a first-time "click here" hint to a neutral re-prompt afterward, per user
-- feedback that a blank box was confusing. Deliberately does NOT touch
-- LibScrollableMenu's own filter/search text, which keeps whatever the user
-- last typed - that persistence (pick a set for one slot, then quickly
-- reuse the same search for another) was explicitly asked to be kept.
local hasEverPicked = false

local WINDOW_WIDTH = 380
local WINDOW_HEIGHT = 220

local ARMOR_WEIGHTS = {
    { name = "Light",  value = ARMORTYPE_LIGHT },
    { name = "Medium", value = ARMORTYPE_MEDIUM },
    { name = "Heavy",  value = ARMORTYPE_HEAVY },
}

-- Common weapon types a set piece might resolve to. There's no "list all
-- WEAPONTYPE_ constants" API, so this is a curated list of names rather than
-- an exhaustive enumeration. Names are resolved off the real global constant
-- table at runtime (_G["WEAPONTYPE_" .. name:upper()]) as a safety net
-- against a typo'd suffix crashing outright, but that alone doesn't catch a
-- WRONG-but-real-looking guess: "Mace" -> "MACE" silently produced no button
-- at all for a long time, because ESO's actual one-handed mace constant is
-- WEAPONTYPE_HAMMER - there is no WEAPONTYPE_MACE. Confirmed correct names
-- (including the two-handed variants, which are their own separate
-- constants, not the same weaponType with a different equip type) via
-- multiple real call sites in other installed addons. Built once at load
-- time below; any name that still doesn't resolve is dropped defensively.
local WEAPON_TYPE_NAMES = {
    "Sword", "Axe", "Mace", "Dagger", "Bow",
    "Fire Staff", "Frost Staff", "Shock Staff", "Healing Staff",
    "Greatsword", "Battle Axe", "Maul",
}
local WEAPON_TYPE_GLOBAL_SUFFIX = {
    ["Sword"] = "SWORD", ["Axe"] = "AXE", ["Mace"] = "HAMMER", ["Dagger"] = "DAGGER", ["Bow"] = "BOW",
    ["Fire Staff"] = "FIRE_STAFF", ["Frost Staff"] = "FROST_STAFF", ["Shock Staff"] = "LIGHTNING_STAFF", ["Healing Staff"] = "HEALING_STAFF",
    ["Greatsword"] = "TWO_HANDED_SWORD", ["Battle Axe"] = "TWO_HANDED_AXE", ["Maul"] = "TWO_HANDED_HAMMER",
}
local WEAPON_TYPES = {}
for _, name in ipairs(WEAPON_TYPE_NAMES) do
    local value = _G["WEAPONTYPE_" .. WEAPON_TYPE_GLOBAL_SUFFIX[name]]
    if value then
        table.insert(WEAPON_TYPES, { name = name, value = value })
    end
end

-- This popup is always opened from the still-open paperdoll window, which
-- still needs the mouse cursor after this closes - so unlike the paperdoll's
-- own SetWindowShown, this only turns UI camera mode ON when showing, never
-- OFF when hiding (that was the actual bug: picking a set closed this popup
-- via SetGameCameraUIMode(false), which killed the cursor even though the
-- paperdoll behind it was still open and needed it).
local function SetWindowShown(shown)
    window:SetHidden(not shown)
    if shown then
        SetGameCameraUIMode(true)
    end
end

local function CreateTextButton(parent, text, width)
    local btn = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    btn:SetFont("ZoFontGameBold")
    btn:SetText("[ " .. text .. " ]")
    btn:SetColor(unpack(BuildTracker.UI_GOLD_TEXT))
    btn:SetMouseEnabled(true)
    btn:SetDimensions(width or 90, 24)
    btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    btn:SetHandler("OnMouseEnter", function(self) self:SetColor(1, 1, 1, 1) end)
    btn:SetHandler("OnMouseExit", function(self) self:SetColor(unpack(BuildTracker.UI_GOLD_TEXT)) end)
    return btn
end

-- Builds a row of disambiguation buttons once (used for armor weight only -
-- weapon type uses a combobox instead, see EnsureWindow); TrySetSlot below
-- decides which one is visible per slot.
local function CreateDisambigButtons(parent, choices, onPick)
    local buttons = {}
    local prev
    for _, choice in ipairs(choices) do
        local btn = CreateTextButton(parent, choice.name, 70)
        if prev then
            btn:SetAnchor(LEFT, prev, RIGHT, 6, 0)
        else
            btn:SetAnchor(LEFT, parent, LEFT, 0, 0)
        end
        btn:SetHandler("OnMouseUp", function(_, _, upInside)
            if upInside then onPick(choice.value) end
        end)
        table.insert(buttons, btn)
        prev = btn
    end
    return buttons
end

local function EnsureWindow()
    if window then return window end

    window = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_SetPickerWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    -- Same tier as the paperdoll window it opens from isn't enough to
    -- guarantee stacking above it - confirmed on the paperdoll's own rename
    -- popup opening behind the main window under this exact same tier tie.
    -- A higher DrawLevel within that tier breaks the tie.
    window:SetDrawLevel(10)

    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetCenterColor(0.05, 0.05, 0.08, 0.95)
    BuildTracker.ApplyWindowBorder(bg, window)

    local dragHandle = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    dragHandle:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    dragHandle:SetHeight(28)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnDragStart", function() window:StartMoving() end)
    dragHandle:SetHandler("OnMouseUp", function() window:StopMovingOrResizing() end)

    local title = WINDOW_MANAGER:CreateControl(nil, dragHandle, CT_LABEL)
    title:SetAnchor(TOPLEFT, dragHandle, TOPLEFT, 10, 6)
    title:SetFont("ZoFontWinH4")
    window.title = title

    -- The ZO_ComboBox container is a base-game virtual template; no XML
    -- needed to instantiate it (confirmed via LibAddonMenu-2.0's dropdown.lua).
    local comboBoxContainer = WINDOW_MANAGER:CreateControlFromVirtual("BuildTracker_SetPickerCombo", window, "ZO_ComboBox")
    comboBoxContainer:SetAnchor(TOPLEFT, dragHandle, BOTTOMLEFT, 10, 14)
    comboBoxContainer:SetAnchor(TOPRIGHT, dragHandle, BOTTOMRIGHT, -10, 14)
    comboBoxContainer:SetHeight(26)
    local comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxContainer)
    comboBox:SetSortsItems(false) -- we feed it already-sorted setIds
    AddCustomScrollableComboBoxDropdownMenu(window, comboBoxContainer, {
        enableFilter = true,
        visibleRowsDropdown = 12,
        maxDropdownHeight = 400,
    })
    window.comboBox = comboBox

    local disambigLabel = WINDOW_MANAGER:CreateControl(nil, window, CT_LABEL)
    disambigLabel:SetAnchor(TOPLEFT, comboBoxContainer, BOTTOMLEFT, 0, 16)
    disambigLabel:SetFont("ZoFontGame")
    disambigLabel:SetText("This set has multiple pieces for this slot - pick one:")
    disambigLabel:SetHidden(true)
    window.disambigLabel = disambigLabel

    local disambigRow = WINDOW_MANAGER:CreateControl(nil, window, CT_CONTROL)
    disambigRow:SetAnchor(TOPLEFT, disambigLabel, BOTTOMLEFT, 0, 8)
    disambigRow:SetDimensions(WINDOW_WIDTH - 20, 28)
    disambigRow:SetHidden(true)
    window.disambigRow = disambigRow

    -- Armor weight only ever has 3 choices - a button row fits comfortably.
    -- Created once and shown/hidden rather than rebuilt per open, since the
    -- choice list is static.
    window.armorWeightButtons = CreateDisambigButtons(disambigRow, ARMOR_WEIGHTS, function(armorType)
        UI.SetPickerConfirmSet(window.buildId, window.slotId, window.selectedSetId, armorType, nil)
    end)

    -- Weapon type has up to 12 possible choices (one/two-handed variants) -
    -- a button row of that many wouldn't fit this window's width, so this is
    -- a plain ZO_ComboBox instead (no LibScrollableMenu/search needed for a
    -- list this short, same as the paperdoll's own build switcher).
    -- Repopulated fresh each time disambiguation triggers (see TrySetSlot)
    -- with only the weapon types the specific ambiguous set actually offers,
    -- not the full generic list - most of the generic list would just fail
    -- to resolve if picked for a given set.
    local weaponTypeComboContainer = WINDOW_MANAGER:CreateControlFromVirtual("BuildTracker_SetPickerWeaponTypeCombo", disambigRow, "ZO_ComboBox")
    weaponTypeComboContainer:SetAnchor(LEFT, disambigRow, LEFT, 0, 0)
    weaponTypeComboContainer:SetDimensions(220, 26)
    local weaponTypeCombo = ZO_ComboBox_ObjectFromContainer(weaponTypeComboContainer)
    weaponTypeCombo:SetSortsItems(false)
    weaponTypeComboContainer:SetHidden(true)
    window.weaponTypeComboContainer = weaponTypeComboContainer
    window.weaponTypeCombo = weaponTypeCombo

    local closeBtn = CreateTextButton(window, "Close")
    closeBtn:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    closeBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then SetWindowShown(false) end
    end)

    return window
end

-- Attempts SetBuildSlot; on success closes the picker (the paperdoll
-- repaints via its own SLOT_SET callback), on the known ambiguity failure
-- reveals the matching disambiguation row instead of surfacing an error.
local function TrySetSlot(buildId, slotId, setId, armorType, weaponType)
    local equipType = BuildTracker.SLOT_TO_EQUIP_TYPE[slotId]
    local ok, err = BuildTracker.Data.SetBuildSlot(buildId, slotId, setId, equipType, armorType, weaponType)
    if ok then
        hasEverPicked = true
        SetWindowShown(false)
        return true
    end

    if not armorType and not weaponType then
        window.selectedSetId = setId
        window.disambigLabel:SetHidden(false)
        window.disambigRow:SetHidden(false)
        local isWeaponSlot = BuildTracker.IsWeaponSlot(slotId)
        for _, btn in ipairs(window.armorWeightButtons) do btn:SetHidden(isWeaponSlot) end
        window.weaponTypeComboContainer:SetHidden(not isWeaponSlot)
        if isWeaponSlot then
            -- Filtered to only what this specific set actually offers - see
            -- the comment where weaponTypeCombo is created for why. Off
            -- Hand/Backup Off additionally never offer two-handed choices,
            -- since neither can ever hold one (BuildTracker.CAN_BE_TWO_HANDED_SLOTS) -
            -- Sets.GetItemIdForSlot would just reject them anyway, so don't
            -- offer a choice that's guaranteed to fail.
            local canBeTwoHanded = BuildTracker.CAN_BE_TWO_HANDED_SLOTS[slotId]
            local availableTypes = BuildTracker.Sets.GetSetWeaponTypes(setId)
            window.weaponTypeCombo:ClearItems()
            for _, choice in ipairs(WEAPON_TYPES) do
                local allowedHere = canBeTwoHanded or not BuildTracker.Sets.IsTwoHandedWeaponType(choice.value)
                if availableTypes[choice.value] and allowedHere then
                    local entry = window.weaponTypeCombo:CreateItemEntry(choice.name, function()
                        UI.SetPickerConfirmSet(buildId, slotId, setId, nil, choice.value)
                    end)
                    window.weaponTypeCombo:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
                end
            end
            window.weaponTypeCombo:UpdateItems()
        end
    else
        d("|cFFA500[BT]|r Error: " .. tostring(err))
    end
    return false
end

-- Called by the disambiguation buttons above once the player narrows down
-- the ambiguous set to a specific weight/weapon type.
function UI.SetPickerConfirmSet(buildId, slotId, setId, armorType, weaponType)
    TrySetSlot(buildId, slotId, setId, armorType, weaponType)
end

-- Public entry point - opens the picker scoped to one build's slot.
function UI.ShowSetPicker(buildId, slotId)
    local w = EnsureWindow()
    w.buildId = buildId
    w.slotId = slotId
    w.selectedSetId = nil
    w.title:SetText("Pick a set - " .. (BuildTracker.SLOT_NAMES[slotId] or ""))
    w.disambigLabel:SetHidden(true)
    w.disambigRow:SetHidden(true)

    -- Only list sets that actually have an item for this slot (e.g. most
    -- overland/dungeon sets have no neck/ring piece at all; weapon slots
    -- accept either one- or two-handed pieces - see Sets.SetSupportsSlot).
    w.comboBox:ClearItems()
    for _, setId in ipairs(BuildTracker.Sets.GetAllSetIdsSorted()) do
        local name = BuildTracker.Sets.GetSetName(setId)
        if name and name ~= "" and BuildTracker.Sets.SetSupportsSlot(setId, slotId) then
            local entry = w.comboBox:CreateItemEntry(BuildTracker.SanitizeDisplayText(name), function()
                TrySetSlot(buildId, slotId, setId)
            end)
            entry.buildTrackerSetId = setId
            w.comboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
        end
    end
    w.comboBox:UpdateItems()

    -- Closed-box placeholder text - set after ClearItems/UpdateItems in
    -- case either resets it internally. Never shows the actual name of a
    -- set picked for a DIFFERENT slot (that would wrongly imply this slot
    -- already has it); just a neutral re-prompt once the user has picked
    -- anything at all, versus a first-time hint before they ever have.
    w.comboBox:SetSelectedItemText(hasEverPicked and "Select set" or "Click to select set")

    SetWindowShown(true)
end
