-- BuildTracker_SlotOptionsUI.lua
--
-- Small popup for optionally tagging a build slot's assigned piece with
-- extra display notes - currently a desired trait (Divines, Precise,
-- Infused, etc.) and a desired enchantment (Weapon Damage, Health,
-- Reduce Spell Cost, etc.) - opened via right-click on an assigned slot in
-- the paperdoll (BuildTracker_PaperdollUI.lua). Renamed from the original
-- BuildTracker_TraitPickerUI.lua (trait-only) once enchantment support was
-- added, per user request, to a general per-slot options window designed
-- to have more rows added later without another rename.
--
-- Both notes are purely display metadata: neither trait nor enchantment
-- changes which itemId a slot needs (you retrait/re-enchant an existing
-- physical piece rather than needing a different item), so neither ever
-- touches Sets.GetItemIdForSlot or any resolution logic - see
-- Data.SetBuildSlotTrait/SetBuildSlotEnchant.
--
-- Built from raw control types, same singleton-window pattern as
-- BuildTracker_SetPickerUI.lua - plain ZO_ComboBoxes are enough here too
-- (max ~20 entries per category, well under the ~12-entry threshold where
-- that file's own weapon-type combo already decided LibScrollableMenu
-- wasn't worth it - though the jewelry enchant list is a bit past that,
-- kept simple/consistent anyway since these are opened rarely compared to
-- the set picker).

BuildTracker = BuildTracker or {}
BuildTracker.UI = BuildTracker.UI or {}

local UI = BuildTracker.UI
local window -- lazily created singleton popup

local WINDOW_WIDTH = 300
local WINDOW_HEIGHT = 190

-- Real ITEM_TRAIT_TYPE_* constants per category, sourced from LibSets' own
-- internal trait lists (LibSets_ConstantsLibraryInternal.lua) - the
-- authoritative, currently-maintained source since LibSets is already a
-- hard dependency, rather than re-deriving this by hand. Several names
-- (Infused/Training/Nirnhoned/Intricate/Ornate) exist for more than one
-- category under DIFFERENT constants, which is why these are three
-- separate tables rather than one shared name->constant map. Resolved off
-- the real global table at runtime (defensive against a future ZOS rename
-- dropping the entry instead of erroring), same pattern as the set
-- picker's own WEAPON_TYPES table.
local ARMOR_TRAITS_RAW = {
    { name = "Divines",      global = "ITEM_TRAIT_TYPE_ARMOR_DIVINES" },
    { name = "Impenetrable", global = "ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE" },
    { name = "Infused",      global = "ITEM_TRAIT_TYPE_ARMOR_INFUSED" },
    { name = "Intricate",    global = "ITEM_TRAIT_TYPE_ARMOR_INTRICATE" },
    { name = "Nirnhoned",    global = "ITEM_TRAIT_TYPE_ARMOR_NIRNHONED" },
    { name = "Ornate",       global = "ITEM_TRAIT_TYPE_ARMOR_ORNATE" },
    { name = "Prosperous",   global = "ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS" },
    { name = "Reinforced",   global = "ITEM_TRAIT_TYPE_ARMOR_REINFORCED" },
    { name = "Sturdy",       global = "ITEM_TRAIT_TYPE_ARMOR_STURDY" },
    { name = "Training",     global = "ITEM_TRAIT_TYPE_ARMOR_TRAINING" },
    { name = "Well-Fitted",  global = "ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED" },
}
local WEAPON_TRAITS_RAW = {
    { name = "Powered",   global = "ITEM_TRAIT_TYPE_WEAPON_POWERED" },
    { name = "Charged",   global = "ITEM_TRAIT_TYPE_WEAPON_CHARGED" },
    { name = "Precise",   global = "ITEM_TRAIT_TYPE_WEAPON_PRECISE" },
    { name = "Infused",   global = "ITEM_TRAIT_TYPE_WEAPON_INFUSED" },
    { name = "Defending", global = "ITEM_TRAIT_TYPE_WEAPON_DEFENDING" },
    { name = "Training",  global = "ITEM_TRAIT_TYPE_WEAPON_TRAINING" },
    { name = "Sharpened", global = "ITEM_TRAIT_TYPE_WEAPON_SHARPENED" },
    { name = "Decisive",  global = "ITEM_TRAIT_TYPE_WEAPON_DECISIVE" },
    { name = "Nirnhoned", global = "ITEM_TRAIT_TYPE_WEAPON_NIRNHONED" },
    { name = "Intricate", global = "ITEM_TRAIT_TYPE_WEAPON_INTRICATE" },
    { name = "Ornate",    global = "ITEM_TRAIT_TYPE_WEAPON_ORNATE" },
}
local JEWELRY_TRAITS_RAW = {
    { name = "Arcane",       global = "ITEM_TRAIT_TYPE_JEWELRY_ARCANE" },
    { name = "Healthy",      global = "ITEM_TRAIT_TYPE_JEWELRY_HEALTHY" },
    { name = "Robust",       global = "ITEM_TRAIT_TYPE_JEWELRY_ROBUST" },
    { name = "Triune",       global = "ITEM_TRAIT_TYPE_JEWELRY_TRIUNE" },
    { name = "Infused",      global = "ITEM_TRAIT_TYPE_JEWELRY_INFUSED" },
    { name = "Protective",   global = "ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE" },
    { name = "Swift",        global = "ITEM_TRAIT_TYPE_JEWELRY_SWIFT" },
    { name = "Harmony",      global = "ITEM_TRAIT_TYPE_JEWELRY_HARMONY" },
    { name = "Bloodthirsty", global = "ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY" },
    { name = "Intricate",    global = "ITEM_TRAIT_TYPE_JEWELRY_INTRICATE" },
    { name = "Ornate",       global = "ITEM_TRAIT_TYPE_JEWELRY_ORNATE" },
}

-- Enchantment (glyph effect) name -> enchantId per category. Unlike traits,
-- ESO doesn't expose these as named global constants - the numeric IDs
-- below are adapted (with attribution, not as a new dependency) from
-- LibLazyCrafting's own hand-curated glyphInfo table
-- (LibLazyCrafting/Enchanting.lua:133-154), the one real reference found
-- anywhere for these values.
--
-- IMPORTANT: these are that table's GLYPH ITEM IDs (columns 3/4 - "the
-- actual craftable glyph item, e.g. itemId of 'Glyph of Absorb Health'"),
-- NOT its columns 1/2 (labeled "enchantId" in that table's own comment, but
-- actually some other internal recipe/ability index unrelated to what an
-- item link's EnchantId field expects). First attempt used columns 1/2 and
-- failed to verify in-game (GetItemLinkAppliedEnchantId never matched) -
-- confirmed the real field wants columns 3/4 by re-reading exactly how
-- LibLazyCrafting builds its OWN working preview links
-- (`fillOutFromParticulars`/Smithing.lua's `internalGetItemLinkFromParticulars`):
-- it looks up `essence[i][4]`/`essence[i][3]` (the glyph itemId columns),
-- never `essence[i][1]`/`[2]`. These glyph itemIds are real base-game items
-- so should be stable data. Best-effort/not guaranteed exhaustive - if a
-- specific enchant a tester wants is missing, it's a one-line addition
-- here once its glyph itemId is known, not a redesign.
local WEAPON_ENCHANTS_RAW = {
    { name = "Absorb Health",  id = 43573 },
    { name = "Absorb Magicka", id = 45868 },
    { name = "Absorb Stamina", id = 45867 },
    { name = "Decrease Health", id = 45869 },
    { name = "Poison",    id = 26587 },
    { name = "Flame",     id = 26848 },
    { name = "Frost",     id = 5365 },
    { name = "Shock",     id = 26844 },
    { name = "Foulness",  id = 26841 },
    { name = "Crushing",  id = 26845 },
    { name = "Hardening", id = 5366 },
    { name = "Weakening", id = 26591 },
    { name = "Weapon Damage", id = 54484 },
    { name = "Prismatic Onslaught", id = 68344 },
}
local ARMOR_ENCHANTS_RAW = {
    { name = "Health",  id = 26580 },
    { name = "Magicka", id = 26582 },
    { name = "Stamina", id = 26588 },
    { name = "Prismatic Defense", id = 68343 },
}
local JEWELRY_ENCHANTS_RAW = {
    { name = "Health Recovery",   id = 26581 },
    { name = "Magicka Recovery",  id = 26583 },
    { name = "Stamina Recovery",  id = 26589 },
    { name = "Reduce Spell Cost", id = 45870 },
    { name = "Reduce Feat Cost",  id = 45871 },
    { name = "Reduce Skill Cost", id = 166046 },
    { name = "Poison Resist",  id = 26586 },
    { name = "Flame Resist",   id = 26849 },
    { name = "Frost Resist",   id = 5364 },
    { name = "Shock Resist",   id = 43570 },
    { name = "Disease Resist", id = 26847 },
    { name = "Potion Speed",   id = 45875 },
    { name = "Potion Boost",   id = 45874 },
    { name = "Shielding", id = 45873 },
    { name = "Bashing",   id = 45872 },
    { name = "Decrease Physical Harm", id = 45885 },
    { name = "Increase Physical Harm", id = 45883 },
    { name = "Decrease Spell Harm",    id = 45886 },
    { name = "Increase Magical Harm",  id = 45884 },
    { name = "Prismatic Recovery",     id = 166047 },
}

-- Only Neck/Ring1/Ring2 are jewelry - everything that isn't a weapon slot
-- (BuildTracker.IsWeaponSlot) and isn't jewelry is a body-armor slot.
local JEWELRY_SLOTS = {
    [EQUIP_SLOT_NECK]  = true,
    [EQUIP_SLOT_RING1] = true,
    [EQUIP_SLOT_RING2] = true,
}

-- Resolves each trait category's raw {name, global} list into {name, value}
-- pairs once at load time, and builds a flat value->name reverse map for
-- tooltip display (BuildTracker.UI.GetTraitName) - ITEM_TRAIT_TYPE_* is one
-- shared flat enum across all categories, so a single reverse map is safe
-- despite the three separate forward tables above.
local ARMOR_TRAITS, WEAPON_TRAITS, JEWELRY_TRAITS = {}, {}, {}
local TRAIT_NAME_BY_VALUE = {}
local function ResolveTraits(raw, resolved)
    for _, t in ipairs(raw) do
        local value = _G[t.global]
        if value then
            table.insert(resolved, { name = t.name, value = value })
            TRAIT_NAME_BY_VALUE[value] = t.name
        end
    end
end
ResolveTraits(ARMOR_TRAITS_RAW, ARMOR_TRAITS)
ResolveTraits(WEAPON_TRAITS_RAW, WEAPON_TRAITS)
ResolveTraits(JEWELRY_TRAITS_RAW, JEWELRY_TRAITS)

-- Enchant reverse map for tooltip display - enchantIds are plain numbers
-- (no _G resolution needed, unlike traits) and don't overlap between
-- categories in practice (LibLazyCrafting's own table treats them as one
-- flat id space), so one shared reverse map is fine here too.
local ENCHANT_NAME_BY_ID = {}
local function IndexEnchants(raw)
    for _, e in ipairs(raw) do
        ENCHANT_NAME_BY_ID[e.id] = e.name
    end
end
IndexEnchants(WEAPON_ENCHANTS_RAW)
IndexEnchants(ARMOR_ENCHANTS_RAW)
IndexEnchants(JEWELRY_ENCHANTS_RAW)

-- Public accessors so the paperdoll's tooltip code can show names without
-- needing its own copy of these reverse maps.
function UI.GetTraitName(traitType)
    return traitType and TRAIT_NAME_BY_VALUE[traitType]
end
function UI.GetEnchantName(enchantId)
    return enchantId and ENCHANT_NAME_BY_ID[enchantId]
end

-- Same reasoning as the set picker's own SetWindowShown: this only ever
-- turns UI camera mode ON, never OFF, since it's opened from the
-- still-open paperdoll window, which still needs the cursor after this closes.
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

-- Creates one "label above combobox" row, returning the combobox's
-- container control (so the next row can anchor below it) and the
-- comboBox object itself - used identically for the trait row and the
-- enchant row below, and for any future row (that's the whole point of
-- this being a helper instead of copy-pasted twice).
--
-- Deliberately uses a single TOPLEFT anchor plus an explicit fixed width
-- (WINDOW_WIDTH - 20) rather than a TOPLEFT+TOPRIGHT anchor pair to span
-- the window - a first attempt at the latter anchored TOPRIGHT to the
-- window while TOPLEFT anchored to the label below dragHandle, two
-- different Y references that would have produced a skewed/broken control
-- instead of a normal rectangle. The set picker's own combobox row proves
-- the two-anchor approach works, but only because both its anchors share
-- the exact same reference and Y offset - not the case here since each
-- row's Y position varies with the previous row's actual rendered height.
local ROW_PADDING = 16 -- left/right inset from the window edge - the first pass anchored flush at 0, which read as "too far left"

-- xOffset: ROW_PADDING when anchorTo is dragHandle (which spans flush to
-- the window's own edges, so it needs the padding applied here), but 0
-- when anchorTo is a PREVIOUS row's comboBoxContainer (which is already
-- sitting at windowLeft + ROW_PADDING - adding ROW_PADDING again there
-- doubled the indent, which is why the enchantment row didn't line up
-- with the trait row above it).
local function CreateOptionRow(parent, anchorTo, xOffset, labelText, namePrefix)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, anchorTo, BOTTOMLEFT, xOffset, 12)
    label:SetFont("ZoFontGame")
    label:SetText(labelText)

    local comboBoxContainer = WINDOW_MANAGER:CreateControlFromVirtual(namePrefix .. "Combo", parent, "ZO_ComboBox")
    comboBoxContainer:SetAnchor(TOPLEFT, label, BOTTOMLEFT, 0, 4)
    comboBoxContainer:SetDimensions(WINDOW_WIDTH - (ROW_PADDING * 2), 26)
    local comboBox = ZO_ComboBox_ObjectFromContainer(comboBoxContainer)
    comboBox:SetSortsItems(false)

    return comboBoxContainer, comboBox
end

local function EnsureWindow()
    if window then return window end

    window = WINDOW_MANAGER:CreateTopLevelWindow("BuildTracker_SlotOptionsWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(10) -- same tie-breaker reasoning as the set picker's own window

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
    title:SetAnchor(TOPLEFT, dragHandle, TOPLEFT, ROW_PADDING, 6)
    title:SetFont("ZoFontWinH4")
    window.title = title

    local traitContainer, traitCombo = CreateOptionRow(window, dragHandle, ROW_PADDING, "Desired Trait", "BuildTracker_SlotOptionsTrait")
    window.traitCombo = traitCombo

    local _, enchantCombo = CreateOptionRow(window, traitContainer, 0, "Desired Enchantment", "BuildTracker_SlotOptionsEnchant")
    window.enchantCombo = enchantCombo

    local closeBtn = CreateTextButton(window, "Close")
    closeBtn:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -10, -10)
    closeBtn:SetHandler("OnMouseUp", function(_, _, upInside)
        if upInside then SetWindowShown(false) end
    end)

    return window
end

-- Populates one combobox with a "(No trait/enchantment set)" clear option
-- plus every {name, value/id} entry in `list`, calling setFunc(chosenValue)
-- when an entry is picked (nil for the clear option).
local function PopulateOptionCombo(comboBox, list, valueKey, setFunc)
    comboBox:ClearItems()
    local clearEntry = comboBox:CreateItemEntry("(None)", function()
        setFunc(nil)
    end)
    comboBox:AddItem(clearEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)
    for _, entry in ipairs(list) do
        local item = comboBox:CreateItemEntry(entry.name, function()
            setFunc(entry[valueKey])
        end)
        comboBox:AddItem(item, ZO_COMBOBOX_SUPPRESS_UPDATE)
    end
    comboBox:UpdateItems()
end

-- Public entry point - opens the options window scoped to one build's slot.
-- Caller (BuildTracker_PaperdollUI.lua) is responsible for only calling
-- this when the slot already has an assigned set - there's nothing to tag
-- a trait/enchantment onto otherwise.
function UI.ShowSlotOptions(buildId, slotId)
    local w = EnsureWindow()
    w.title:SetText("Slot Options - " .. (BuildTracker.SLOT_NAMES[slotId] or ""))

    local isWeaponSlot = BuildTracker.IsWeaponSlot(slotId)
    local isJewelrySlot = JEWELRY_SLOTS[slotId]
    local traitList = isWeaponSlot and WEAPON_TRAITS or (isJewelrySlot and JEWELRY_TRAITS or ARMOR_TRAITS)
    local enchantList = isWeaponSlot and WEAPON_ENCHANTS_RAW or (isJewelrySlot and JEWELRY_ENCHANTS_RAW or ARMOR_ENCHANTS_RAW)

    PopulateOptionCombo(w.traitCombo, traitList, "value", function(traitType)
        BuildTracker.Data.SetBuildSlotTrait(buildId, slotId, traitType)
    end)
    PopulateOptionCombo(w.enchantCombo, enchantList, "id", function(enchantId)
        BuildTracker.Data.SetBuildSlotEnchant(buildId, slotId, enchantId)
    end)

    -- Closed-box text: shows this slot's CURRENT trait/enchantment name if
    -- one is already set (accurate here, unlike the set picker's own
    -- placeholder - this window is always scoped to one specific slot, so
    -- there's no risk of confusingly showing a value picked for a
    -- DIFFERENT slot), otherwise a generic prompt so the box is never
    -- blank/confusing on first use. Set after population in case
    -- ClearItems/UpdateItems resets it internally.
    local build = BuildTracker.Data.GetBuild(buildId)
    local slotData = build and build.slots[slotId]
    local currentTraitName = slotData and UI.GetTraitName(slotData.traitType)
    local currentEnchantName = slotData and UI.GetEnchantName(slotData.enchantId)
    w.traitCombo:SetSelectedItemText(currentTraitName or "Select trait")
    w.enchantCombo:SetSelectedItemText(currentEnchantName or "Select enchantment")

    SetWindowShown(true)
end
