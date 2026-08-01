Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local Internal = Greed.Internal
local GreedData = Greed_Addon.Data
local libSets = Internal.libSets
local T = Internal.T
local NormalizeClientLanguageCode = Internal.NormalizeClientLanguageCode
local GetClientLanguageCode = Internal.GetClientLanguageCode
local DEFAULT_PAGE_NAME = Internal.DEFAULT_PAGE_NAME
local GetCachedAllSetNames = Internal.GetCachedAllSetNames
local GetLibSetsSearchCache = Internal.GetLibSetsSearchCache
local GetLiveSetNameCache = Internal.GetLiveSetNameCache
local SortAddSetResultsByBaseName = Internal.SortAddSetResultsByBaseName
local ADD_SET_RESULT_LIMIT = Internal.ADD_SET_RESULT_LIMIT
local SETS_OVERVIEW_MAX_ROWS = Internal.SETS_OVERVIEW_MAX_ROWS
local SOURCES_TO_FARM_MAX_ROWS = Internal.SOURCES_TO_FARM_MAX_ROWS
local SOURCES_TO_FARM_ROW_HEIGHT = Internal.SOURCES_TO_FARM_ROW_HEIGHT
local COLORS = Internal.COLORS
local WEAPON_ITEMS = Internal.WEAPON_ITEMS
local WEAPON_ITEM_GROUPS = Internal.WEAPON_ITEM_GROUPS
local LIVE_SET_NAME_ITEM_FILTERS = Internal.LIVE_SET_NAME_ITEM_FILTERS
local WEAPON_ITEM_BY_KEY = Internal.WEAPON_ITEM_BY_KEY
local MONSTER_ARMOR_SLOT_KEYS = Internal.MONSTER_ARMOR_SLOT_KEYS
local MONSTER_ARMOR_WEIGHT_OPTIONS = Internal.MONSTER_ARMOR_WEIGHT_OPTIONS
local FARM_WEAPON_LABELS = Internal.FARM_WEAPON_LABELS
local FARM_SLOT_LABELS = Internal.FARM_SLOT_LABELS
local CallControlMethod = Internal.CallControlMethod
local GetControlDimension = Internal.GetControlDimension
local AllowMultilineLabelText = Internal.AllowMultilineLabelText
local SetBackdropStyle = Internal.SetBackdropStyle
local SetButtonText = Internal.SetButtonText
local SetSimpleTooltip = Internal.SetSimpleTooltip
local SafeAnnounce = Internal.SafeAnnounce
local TrimText = Internal.TrimText
local StyleTransparentTextButton = Internal.StyleTransparentTextButton
local AddResizeGripIcon = Internal.AddResizeGripIcon

local SOURCES_TO_FARM_DEFAULT_WIDTH = 880
local SOURCES_TO_FARM_DEFAULT_HEIGHT = 520
local SOURCES_TO_FARM_MIN_WIDTH = 860
local SOURCES_TO_FARM_MAX_WIDTH = 1280
local SOURCES_TO_FARM_MIN_VISIBLE_ROWS = 6
local SOURCES_TO_FARM_HEADER_Y = 82
local SOURCES_TO_FARM_ROW_START_Y = 104
local SOURCES_TO_FARM_BOTTOM_INSET = 56
local SOURCES_TO_FARM_LEFT_INSET = 18
local SOURCES_TO_FARM_RIGHT_INSET = 46
local SOURCES_TO_FARM_COLUMN_GAP = 8
local SOURCES_TO_FARM_SCROLLBAR_RIGHT_INSET = 16
local SOURCES_TO_FARM_RESIZE_GRIP_SIZE = 32
local SOURCES_TO_FARM_MIN_HEIGHT = SOURCES_TO_FARM_ROW_START_Y + (SOURCES_TO_FARM_MIN_VISIBLE_ROWS * SOURCES_TO_FARM_ROW_HEIGHT) + SOURCES_TO_FARM_BOTTOM_INSET
local SOURCES_TO_FARM_MAX_HEIGHT = 900
local SOURCES_TO_FARM_SOURCE_TYPE_TRIAL = "trial"
local SOURCES_TO_FARM_SOURCE_TYPE_DUNGEON = "dungeon"
local LIBSETS_SETTYPE_DUNGEON = LIBSETS_SETTYPE_DUNGEON
local LIBSETS_SETTYPE_MONSTER = LIBSETS_SETTYPE_MONSTER
local LIBSETS_SETTYPE_TRIAL = LIBSETS_SETTYPE_TRIAL
local PIECE_PICKER_CHECKBOX_INDICATOR_SUFFIXES = { "Check", "Checked", "Unchecked", "Icon", "Texture" }

local function ClampSourcesToFarmNumber(value, fallback, minValue, maxValue)
    local number = tonumber(value) or fallback
    return math.max(minValue, math.min(maxValue, number))
end

local function CleanSourcesToFarmSortText(value)
    local text = tostring(value or "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return string.lower(text)
end

local function GetPickerCheckboxNamedChild(checkbox, suffix)
    if not checkbox or type(suffix) ~= "string" then return nil end

    if type(checkbox.GetNamedChild) == "function" then
        local ok, child = pcall(function()
            return checkbox:GetNamedChild(suffix)
        end)
        if ok and child then return child end
    end

    if type(GetControl) == "function" then
        local ok, child = pcall(GetControl, checkbox, suffix)
        if ok and child then return child end
    end

    if _G and type(checkbox.GetName) == "function" then
        local ok, name = pcall(function()
            return checkbox:GetName()
        end)
        if ok and type(name) == "string" then
            return _G[name .. suffix]
        end
    end

    return nil
end

local function GetPickerCheckboxLabel(checkbox)
    if not checkbox then return nil end
    if checkbox.greedLabel then return checkbox.greedLabel end

    local label = checkbox.label or GetPickerCheckboxNamedChild(checkbox, "Label")
    if label then
        checkbox.greedLabel = label
    end

    return label
end

local function SetPickerControlColor(control, color)
    if control and color and type(control.SetColor) == "function" then
        control:SetColor(color[1], color[2], color[3], color[4])
    end
end

local function SetPickerCheckboxText(checkbox, text)
    if not checkbox then return end

    if ZO_CheckButton_SetLabelText then
        ZO_CheckButton_SetLabelText(checkbox, text)
    end

    local label = GetPickerCheckboxLabel(checkbox)
    if label and type(label.SetText) == "function" then
        label:SetText(text)
    end
end

local function SetPickerCheckboxColor(checkbox, color)
    if not checkbox then return end

    SetPickerControlColor(checkbox, color)
    for _, suffix in ipairs(PIECE_PICKER_CHECKBOX_INDICATOR_SUFFIXES) do
        SetPickerControlColor(GetPickerCheckboxNamedChild(checkbox, suffix), color)
    end

    local label = GetPickerCheckboxLabel(checkbox)
    SetPickerControlColor(label, color)
end

local function BuildPiecePickerArmorColumn(slot)
    return {
        kind = "armor",
        key = slot.key,
        label = slot.label,
        shortLabel = slot.shortLabel,
        equipType = slot.equipType,
        fallbackIcon = slot.fallbackIcon,
        total = slot.total,
    }
end

local function BuildPiecePickerWeaponColumn(weapon)
    return {
        kind = "weapon",
        key = weapon.key,
        label = weapon.label,
        shortLabel = weapon.shortLabel,
        weaponType = weapon.weaponType,
        fallbackIcon = weapon.fallbackIcon or GreedData.placeholderIcons.weapon,
    }
end

local function BuildSourcesToFarmColumnDefs(windowWidth)
    local contentWidth = math.max(720, math.floor((tonumber(windowWidth) or SOURCES_TO_FARM_DEFAULT_WIDTH) - SOURCES_TO_FARM_LEFT_INSET - SOURCES_TO_FARM_RIGHT_INSET))
    local typeWidth = 110
    local difficultyWidth = 106
    local flexibleWidth = math.max(480, contentWidth - typeWidth - difficultyWidth - (SOURCES_TO_FARM_COLUMN_GAP * 4))
    local nameWidth = math.floor(flexibleWidth * 0.31)
    local setWidth = math.floor(flexibleWidth * 0.32)
    local itemsWidth = flexibleWidth - nameWidth - setWidth

    local columns = {
        { key = "source", label = T("Name"), width = nameWidth, sortable = true },
        { key = "sourceType", label = T("Type"), width = typeWidth, sortable = true },
        { key = "difficulty", label = T("Difficulty"), width = difficultyWidth, sortable = true },
        { key = "setName", label = T("Set"), width = setWidth, sortable = true },
        { key = "items", label = T("Items Greeded"), width = itemsWidth, sortable = false },
    }

    local x = SOURCES_TO_FARM_LEFT_INSET
    for _, column in ipairs(columns) do
        column.x = x
        x = x + column.width + SOURCES_TO_FARM_COLUMN_GAP
    end

    return columns, contentWidth
end

function Greed:CreateWeaponItemPickerControls(prefix, parent, anchorControl, offsetX, offsetY)
    local container = WINDOW_MANAGER:CreateControl(prefix .. "WeaponItems", parent, CT_CONTROL)
    container:SetDimensions(410, 270)
    container:SetAnchor(TOPLEFT, anchorControl, BOTTOMLEFT, offsetX or 0, offsetY or 8)

    local checks = {}
    local colWidth = 190
    local rowHeight = 24

    for _, group in ipairs(WEAPON_ITEM_GROUPS) do
        local groupX = (group.column or 0) * colWidth
        local groupLabel = WINDOW_MANAGER:CreateControl(prefix .. "WeaponGroup" .. group.label:gsub("%W", ""), container, CT_LABEL)
        groupLabel:SetDimensions(180, 18)
        groupLabel:SetAnchor(TOPLEFT, container, TOPLEFT, groupX, group.y)
        groupLabel:SetFont("ZoFontGameSmall")
        groupLabel:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
        groupLabel:SetText(group.label)

        for index, weaponKey in ipairs(group.keys) do
            local weapon = WEAPON_ITEM_BY_KEY[weaponKey]
            local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(prefix .. "Weapon" .. weapon.key, container, "ZO_CheckButton")
            checkbox:SetAnchor(TOPLEFT, groupLabel, BOTTOMLEFT, 0, 3 + (index - 1) * rowHeight)
            if ZO_CheckButton_SetLabelText then
                ZO_CheckButton_SetLabelText(checkbox, weapon.label)
            end
            if ZO_CheckButton_SetToggleFunction then
                ZO_CheckButton_SetToggleFunction(checkbox, function(control, checked)
                    control.greedChecked = checked == true
                    self:RefreshPiecePickerCheckboxVisual(control)
                end)
            end
            checkbox.greedBaseLabel = weapon.label
            checks[weapon.key] = checkbox
        end
    end

    return container, checks
end

function Greed:SetWeaponItemCheckboxes(weaponChecks, weapons)
    local trackedWeapons = self:NormalizeWeaponTrackingTable(weapons)

    for _, weapon in ipairs(WEAPON_ITEMS) do
        self:SetEditCheckboxState(weaponChecks and weaponChecks[weapon.key], trackedWeapons[weapon.key] == true)
    end
end

function Greed:ReadWeaponItemCheckboxes(weaponChecks)
    local weapons = {}
    local hasTrackedWeapon = false

    for _, weapon in ipairs(WEAPON_ITEMS) do
        local checked = self:IsEditCheckboxChecked(weaponChecks and weaponChecks[weapon.key])
        weapons[weapon.key] = checked
        hasTrackedWeapon = hasTrackedWeapon or checked
    end

    return weapons, hasTrackedWeapon
end

function Greed:IsMonsterSetData(setData)
    return setData and setData.isMonsterSet == true
end

function Greed:NormalizeMonsterArmorWeights(weights)
    local normalized = {
        light = false,
        medium = false,
        heavy = false,
    }

    local function enableWeight(value)
        if type(value) ~= "string" then return end
        local lowerValue = string.lower(value)
        if lowerValue == "any" or lowerValue == "" then return end
        if lowerValue:find("light", 1, true) then normalized.light = true end
        if lowerValue:find("medium", 1, true) then normalized.medium = true end
        if lowerValue:find("heavy", 1, true) then normalized.heavy = true end
    end

    if type(weights) == "table" then
        for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
            normalized[option.key] = weights[option.key] == true
        end
        for _, value in pairs(weights) do
            enableWeight(value)
        end
    else
        enableWeight(weights)
    end

    return normalized
end

function Greed:GetSelectedMonsterArmorWeightCount(weights)
    local normalized = self:NormalizeMonsterArmorWeights(weights)
    local count = 0
    for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
        if normalized[option.key] == true then
            count = count + 1
        end
    end
    return count
end

function Greed:GetMonsterWeightPreferenceText(setData)
    local weights = self:NormalizeMonsterArmorWeights(setData and (setData.armorWeights or setData.armorWeight or setData.weightPreference))
    local selected = {}

    for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
        if weights[option.key] == true then
            table.insert(selected, option.label)
        end
    end

    if #selected == 0 or #selected == #MONSTER_ARMOR_WEIGHT_OPTIONS then
        return T("Any")
    end

    return table.concat(selected, "/")
end

function Greed:GetMonsterWeightNeedsText(setData)
    local weights = self:NormalizeMonsterArmorWeights(setData and (setData.armorWeights or setData.armorWeight or setData.weightPreference))
    local selected = {}
    local orderedWeights = {
        { key = "heavy", label = "Heavy" },
        { key = "medium", label = "Medium" },
        { key = "light", label = "Light" },
    }

    for _, option in ipairs(orderedWeights) do
        if weights[option.key] == true then
            table.insert(selected, option.label)
        end
    end

    if #selected == 0 or #selected == #orderedWeights then
        return T("Any Weight")
    end

    return table.concat(selected, ", ")
end

function Greed:MonsterWeightAllowsArmorType(weights, armorType)
    if armorType == nil then return true end

    local normalized = self:NormalizeMonsterArmorWeights(weights)
    local selectedCount = self:GetSelectedMonsterArmorWeightCount(normalized)
    if selectedCount == 0 or selectedCount == #MONSTER_ARMOR_WEIGHT_OPTIONS then
        return true
    end

    local canCompare = false
    for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
        if normalized[option.key] == true and option.armorType ~= nil then
            canCompare = true
            if option.armorType == armorType then
                return true
            end
        end
    end

    -- If this client does not expose the armor-type constants, do not block the row.
    return not canCompare
end

function Greed:GetArmorTypeFromItemLink(itemLink)
    if not itemLink or type(GetItemLinkArmorType) ~= "function" then return nil end

    local ok, armorType = pcall(GetItemLinkArmorType, itemLink)
    if ok then
        return armorType
    end

    return nil
end

function Greed:CreateMonsterWeightPickerControls(prefix, parent, anchorControl, offsetX, offsetY)
    local container = WINDOW_MANAGER:CreateControl(prefix .. "MonsterWeights", parent, CT_CONTROL)
    container:SetDimensions(170, 112)
    container:SetAnchor(TOPLEFT, anchorControl, TOPLEFT, offsetX or 0, offsetY or 0)
    container:SetHidden(true)
    container:SetMouseEnabled(false)

    local header = WINDOW_MANAGER:CreateControl(prefix .. "MonsterWeightsHeader", container, CT_LABEL)
    header:SetDimensions(160, 18)
    header:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    header:SetFont("ZoFontGameSmall")
    header:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    header:SetText(T("Monster Weight"))

    local checks = {}
    for index, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
        local checkbox = WINDOW_MANAGER:CreateControlFromVirtual(prefix .. "MonsterWeight" .. option.key, container, "ZO_CheckButton")
        checkbox:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 5 + (index - 1) * 26)
        if ZO_CheckButton_SetLabelText then
            ZO_CheckButton_SetLabelText(checkbox, option.label)
        end
        if ZO_CheckButton_SetToggleFunction then
            ZO_CheckButton_SetToggleFunction(checkbox, function(control, checked)
                control.greedChecked = checked == true
            end)
        end
        checks[option.key] = checkbox
    end

    return container, checks
end

function Greed:SetMonsterWeightCheckboxes(weightChecks, weights)
    local normalized = self:NormalizeMonsterArmorWeights(weights)
    for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
        self:SetEditCheckboxState(weightChecks and weightChecks[option.key], normalized[option.key] == true)
    end
end

function Greed:ReadMonsterWeightCheckboxes(weightChecks)
    local weights = self:NormalizeMonsterArmorWeights(nil)
    for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
        weights[option.key] = self:IsEditCheckboxChecked(weightChecks and weightChecks[option.key])
    end
    return weights
end

function Greed:SetControlTreeHiddenAndMouse(control, hidden)
    if not control then return end
    control:SetHidden(hidden == true)
    control:SetMouseEnabled(hidden ~= true)
end

function Greed:ApplyMonsterControlsMode(controls, isMonsterSet)
    if not controls then return end

    local monsterMode = isMonsterSet == true
    for _, slot in ipairs(GreedData.armorSlots or {}) do
        local checkbox = controls.armorChecks and controls.armorChecks[slot.key]
        local allowed = (not monsterMode) or MONSTER_ARMOR_SLOT_KEYS[slot.key] == true
        if checkbox then
            checkbox:SetHidden(not allowed)
            checkbox:SetMouseEnabled(allowed)
            if not allowed then
                self:SetEditCheckboxState(checkbox, false)
            end
        end
    end

    self:SetControlTreeHiddenAndMouse(controls.weaponHeader, monsterMode)
    self:SetControlTreeHiddenAndMouse(controls.weaponContainer, monsterMode)
    for _, weapon in ipairs(WEAPON_ITEMS) do
        local checkbox = controls.weaponChecks and controls.weaponChecks[weapon.key]
        if checkbox then
            checkbox:SetMouseEnabled(not monsterMode)
            if monsterMode then
                self:SetEditCheckboxState(checkbox, false)
            end
        end
    end

    self:SetControlTreeHiddenAndMouse(controls.monsterWeightContainer, not monsterMode)
end

function Greed:CreateEditWindow()
    if self.editControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(600, 620)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 250)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(600, 44)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesTitle", window, CT_LABEL)
    title:SetDimensions(480, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetMouseEnabled(true)

    local source = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesSource", window, CT_LABEL)
    source:SetDimensions(480, 22)
    source:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
    source:SetFont("ZoFontGameSmall")
    source:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    local armorHeader = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesArmorHeader", window, CT_LABEL)
    armorHeader:SetDimensions(220, 22)
    armorHeader:SetAnchor(TOPLEFT, source, BOTTOMLEFT, 0, 16)
    armorHeader:SetFont("ZoFontGame")
    armorHeader:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    armorHeader:SetText(T("Armor / Jewelry"))

    local armorChecks = {}
    for index, slot in ipairs(GreedData.armorSlots) do
        local checkbox = WINDOW_MANAGER:CreateControlFromVirtual("GreedEditTrackedPiecesArmor" .. slot.key, window, "ZO_CheckButton")
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        checkbox:SetAnchor(TOPLEFT, armorHeader, BOTTOMLEFT, col * 190, 8 + row * 30)
        if ZO_CheckButton_SetLabelText then
            ZO_CheckButton_SetLabelText(checkbox, slot.label)
        end
        if ZO_CheckButton_SetToggleFunction then
            ZO_CheckButton_SetToggleFunction(checkbox, function(control, checked)
                control.greedChecked = checked == true
                self:RefreshPiecePickerCheckboxVisual(control)
            end)
        end
        checkbox.greedBaseLabel = slot.label
        armorChecks[slot.key] = checkbox
    end

    local weaponHeader = WINDOW_MANAGER:CreateControl("GreedEditTrackedPiecesWeaponHeader", window, CT_LABEL)
    weaponHeader:SetDimensions(220, 22)
    weaponHeader:SetAnchor(TOPLEFT, armorHeader, BOTTOMLEFT, 0, 166)
    weaponHeader:SetFont("ZoFontGame")
    weaponHeader:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    weaponHeader:SetText(T("Weapon Items"))

    local weaponContainer, weaponChecks = self:CreateWeaponItemPickerControls("GreedEditTrackedPieces", window, weaponHeader, 0, 8)
    local monsterWeightContainer, monsterWeightChecks = self:CreateMonsterWeightPickerControls("GreedEditTrackedPieces", window, armorHeader, 380, 0)

    local saveButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedEditTrackedPiecesSave", window, "ZO_DefaultButton")
    saveButton:SetDimensions(100, 30)
    saveButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    SetButtonText(saveButton, T("Save"))
    saveButton:SetHandler("OnClicked", function()
        self:SaveEditTrackedPieces()
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedEditTrackedPiecesCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HideEditTrackedPiecesWindow()
    end)

    self.editControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        source = source,
        armorHeader = armorHeader,
        armorChecks = armorChecks,
        weaponHeader = weaponHeader,
        weaponContainer = weaponContainer,
        weaponChecks = weaponChecks,
        monsterWeightContainer = monsterWeightContainer,
        monsterWeightChecks = monsterWeightChecks,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "editTrackedPieces")
end

function Greed:SetEditCheckboxState(checkbox, checked)
    if not checkbox then return end

    checkbox.greedChecked = checked == true
    if ZO_CheckButton_SetCheckState then
        ZO_CheckButton_SetCheckState(checkbox, checkbox.greedChecked)
    elseif checkbox.greedChecked and ZO_CheckButton_SetChecked then
        ZO_CheckButton_SetChecked(checkbox)
    elseif ZO_CheckButton_SetUnchecked then
        ZO_CheckButton_SetUnchecked(checkbox)
    end

    self:RefreshPiecePickerCheckboxVisual(checkbox)
end

function Greed:IsEditCheckboxChecked(checkbox)
    if not checkbox then return false end

    if ZO_CheckButton_IsChecked then
        return ZO_CheckButton_IsChecked(checkbox) == true
    end

    return checkbox.greedChecked == true
end

function Greed:ShowEditTrackedPiecesWindow(setData)
    if not setData then return end

    self:CreateEditWindow()
    self.editingSetData = setData

    local controls = self.editControls
    controls.title:SetText(T("Edit Tracked Pieces - %s", setData.name or T("Unknown Set")))
    controls.source:SetText(setData.source or "")

    for _, slot in ipairs(GreedData.armorSlots) do
        self:SetEditCheckboxState(controls.armorChecks[slot.key], setData.pieces and setData.pieces[slot.key] ~= nil)
    end

    self:SetWeaponItemCheckboxes(controls.weaponChecks, setData.weapons)
    self:SetMonsterWeightCheckboxes(controls.monsterWeightChecks, setData.armorWeights or setData.armorWeight or setData.weightPreference)
    self:ApplyMonsterControlsMode(controls, self:IsMonsterSetData(setData))

    controls.window:SetHidden(false)
    self:RefreshEditTrackedPiecesOwnershipStyles()
end

function Greed:HideEditTrackedPiecesWindow()
    if self.editControls and self.editControls.window then
        self.editControls.window:SetHidden(true)
    end
    self.editingSetData = nil
end

function Greed:SaveEditTrackedPieces()
    local setData = self.editingSetData
    if not setData or not setData.rowKey then return end

    local controls = self.editControls
    local existingOverride = self:GetSavedSetOverride(setData.rowKey) or {}
    local override = {
        userAdded = existingOverride.userAdded == true or setData.userAdded == true,
        baseName = setData.baseName,
        lookupName = setData.lookupName,
        source = setData.source,
        setId = setData.setId,
        normalSetId = existingOverride.normalSetId or setData.normalSetId,
        perfectedSetId = existingOverride.perfectedSetId or setData.perfectedSetId,
        perfected = setData.isPerfectedRow == true,
        isMonsterSet = self:IsMonsterSetData(setData),
        pieces = {},
        weapons = {},
    }

    if override.isMonsterSet then
        override.armorWeights = self:ReadMonsterWeightCheckboxes(controls.monsterWeightChecks)
        for _, slot in ipairs(GreedData.armorSlots) do
            override.pieces[slot.key] = MONSTER_ARMOR_SLOT_KEYS[slot.key] == true and self:IsEditCheckboxChecked(controls.armorChecks[slot.key]) or false
        end
        override.weapons = self:CreateEmptyWeaponTrackingTable()
    else
        for _, slot in ipairs(GreedData.armorSlots) do
            override.pieces[slot.key] = self:IsEditCheckboxChecked(controls.armorChecks[slot.key])
        end

        override.weapons = self:ReadWeaponItemCheckboxes(controls.weaponChecks)
    end

    self:GetSavedSets()[setData.rowKey] = override
    self:HideEditTrackedPiecesWindow()
    self:RefreshGridFromSaved()
end

function Greed:CreateAddSetWindow()
    if self.addControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedAddSetWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(800, 640)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 260)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedAddSetBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedAddSetTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(800, 50)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedAddSetTitle", window, CT_LABEL)
    title:SetDimensions(640, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Add Set to Greed"))
    title:SetMouseEnabled(true)

    local searchBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("GreedAddSetSearchBackdrop", window, "ZO_EditBackdrop")
    searchBackdrop:SetDimensions(420, 30)
    searchBackdrop:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)

    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("GreedAddSetSearchBox", searchBackdrop, "ZO_DefaultEditForBackdrop")
    searchBox:SetAnchorFill(searchBackdrop)
    searchBox:SetMaxInputChars(80)
    if searchBox.SetDefaultText then
        searchBox:SetDefaultText(T("Search set name"))
    end
    searchBox:SetHandler("OnTextChanged", function(control)
        self:SearchAddSet(control:GetText())
    end)

    local resultsHeader = WINDOW_MANAGER:CreateControl("GreedAddSetResultsHeader", window, CT_LABEL)
    resultsHeader:SetDimensions(260, 22)
    resultsHeader:SetAnchor(TOPLEFT, searchBackdrop, BOTTOMLEFT, 0, 14)
    resultsHeader:SetFont("ZoFontGame")
    resultsHeader:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    resultsHeader:SetText(T("Results"))

    local emptyLabel = WINDOW_MANAGER:CreateControl("GreedAddSetEmpty", window, CT_LABEL)
    emptyLabel:SetDimensions(300, 24)
    emptyLabel:SetAnchor(TOPLEFT, resultsHeader, BOTTOMLEFT, 0, 10)
    emptyLabel:SetFont("ZoFontGameSmall")
    AllowMultilineLabelText(emptyLabel, 2)
    emptyLabel:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    local resultRows = {}
    for index = 1, ADD_SET_RESULT_LIMIT do
        local row = WINDOW_MANAGER:CreateControl("GreedAddSetResult" .. index, window, CT_CONTROL)
        row:SetDimensions(300, 42)
        row:SetAnchor(TOPLEFT, resultsHeader, BOTTOMLEFT, 0, 6 + (index - 1) * 46)
        row:SetMouseEnabled(true)
        row:SetHidden(true)

        local rowBg = WINDOW_MANAGER:CreateControl("GreedAddSetResult" .. index .. "Bg", row, CT_BACKDROP)
        rowBg:SetAnchorFill(row)
        SetBackdropStyle(rowBg, COLORS.row, COLORS.mutedEdge)

        local name = WINDOW_MANAGER:CreateControl("GreedAddSetResult" .. index .. "Name", row, CT_LABEL)
        name:SetDimensions(286, 18)
        name:SetAnchor(TOPLEFT, row, TOPLEFT, 8, 4)
        name:SetFont("ZoFontGameSmall")
        name:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

        local source = WINDOW_MANAGER:CreateControl("GreedAddSetResult" .. index .. "Source", row, CT_LABEL)
        source:SetDimensions(210, 16)
        source:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, 0)
        source:SetFont("ZoFontGameSmall")
        source:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

        local perfected = WINDOW_MANAGER:CreateControl("GreedAddSetResult" .. index .. "Perfected", row, CT_LABEL)
        perfected:SetDimensions(82, 16)
        perfected:SetAnchor(RIGHT, row, RIGHT, -8, 9)
        perfected:SetFont("ZoFontGameSmall")
        perfected:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        perfected:SetColor(COLORS.perfectedText[1], COLORS.perfectedText[2], COLORS.perfectedText[3], COLORS.perfectedText[4])

        row:SetHandler("OnMouseUp", function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                self:SelectAddSetResult(index)
            end
        end)

        resultRows[index] = {
            row = row,
            name = name,
            source = source,
            perfected = perfected,
        }
    end

    local picker = WINDOW_MANAGER:CreateControl("GreedAddSetPicker", window, CT_CONTROL)
    picker:SetDimensions(430, 500)
    picker:SetAnchor(TOPLEFT, searchBackdrop, TOPRIGHT, 28, -42)
    picker:SetHidden(true)

    local selectedName = WINDOW_MANAGER:CreateControl("GreedAddSetSelectedName", picker, CT_LABEL)
    selectedName:SetDimensions(310, 22)
    selectedName:SetAnchor(TOPLEFT, picker, TOPLEFT, 0, 0)
    selectedName:SetFont("ZoFontGameBold")
    selectedName:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

    local selectedSource = WINDOW_MANAGER:CreateControl("GreedAddSetSelectedSource", picker, CT_LABEL)
    selectedSource:SetDimensions(310, 20)
    selectedSource:SetAnchor(TOPLEFT, selectedName, BOTTOMLEFT, 0, 0)
    selectedSource:SetFont("ZoFontGameSmall")
    selectedSource:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    local armorHeader = WINDOW_MANAGER:CreateControl("GreedAddSetArmorHeader", picker, CT_LABEL)
    armorHeader:SetDimensions(220, 22)
    armorHeader:SetAnchor(TOPLEFT, selectedSource, BOTTOMLEFT, 0, 16)
    armorHeader:SetFont("ZoFontGame")
    armorHeader:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    armorHeader:SetText(T("Armor / Jewelry"))

    local armorChecks = {}
    for index, slot in ipairs(GreedData.armorSlots) do
        local checkbox = WINDOW_MANAGER:CreateControlFromVirtual("GreedAddSetArmor" .. slot.key, picker, "ZO_CheckButton")
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        checkbox:SetAnchor(TOPLEFT, armorHeader, BOTTOMLEFT, col * 150, 8 + row * 28)
        if ZO_CheckButton_SetLabelText then
            ZO_CheckButton_SetLabelText(checkbox, slot.label)
        end
        if ZO_CheckButton_SetToggleFunction then
            ZO_CheckButton_SetToggleFunction(checkbox, function(control, checked)
                control.greedChecked = checked == true
                self:RefreshPiecePickerCheckboxVisual(control)
            end)
        end
        checkbox.greedBaseLabel = slot.label
        armorChecks[slot.key] = checkbox
    end

    local weaponHeader = WINDOW_MANAGER:CreateControl("GreedAddSetWeaponHeader", picker, CT_LABEL)
    weaponHeader:SetDimensions(220, 22)
    weaponHeader:SetAnchor(TOPLEFT, armorHeader, BOTTOMLEFT, 0, 158)
    weaponHeader:SetFont("ZoFontGame")
    weaponHeader:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    weaponHeader:SetText(T("Weapon Items"))

    local weaponContainer, weaponChecks = self:CreateWeaponItemPickerControls("GreedAddSet", picker, weaponHeader, 0, 8)
    local monsterWeightContainer, monsterWeightChecks = self:CreateMonsterWeightPickerControls("GreedAddSet", picker, armorHeader, 250, 0)

    local saveButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedAddSetSave", window, "ZO_DefaultButton")
    saveButton:SetDimensions(100, 30)
    saveButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    SetButtonText(saveButton, T("Save"))
    saveButton:SetHandler("OnClicked", function()
        self:SaveAddSet()
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedAddSetCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HideAddSetWindow()
    end)

    self.addControls = {
        window = window,
        titleBar = titleBar,
        searchBox = searchBox,
        emptyLabel = emptyLabel,
        resultRows = resultRows,
        picker = picker,
        selectedName = selectedName,
        selectedSource = selectedSource,
        saveButton = saveButton,
        armorHeader = armorHeader,
        armorChecks = armorChecks,
        weaponHeader = weaponHeader,
        weaponContainer = weaponContainer,
        weaponChecks = weaponChecks,
        monsterWeightContainer = monsterWeightContainer,
        monsterWeightChecks = monsterWeightChecks,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "addSet")
end

function Greed:ShowAddSetWindow()
    self:CreateAddSetWindow()
    self.addState = {
        results = {},
        selected = nil,
        selectedSetId = nil,
        selectedIsPerfected = false,
        normalSetId = nil,
        perfectedSetId = nil,
        searchMessage = T("Type at least two characters."),
    }

    local controls = self.addControls
    self:ResetAddPicker()
    self:UpdateAddResults({})
    controls.window:SetHidden(false)

    if controls.searchBox then
        controls.searchBox:SetText("")
        -- Do not auto-focus the search box. The user can click it when ready.
    end
end

function Greed:HideAddSetWindow()
    if self.addControls and self.addControls.window then
        self.addControls.window:SetHidden(true)
    end
    self.addState = nil
end

function Greed:ToggleAddSetWindow()
    if self.addControls and self.addControls.window and not self.addControls.window:IsHidden() then
        self:HideAddSetWindow()
        return
    end

    self:ShowAddSetWindow()
end

function Greed:ResetAddPicker()
    local controls = self.addControls
    if not controls then return end

    controls.picker:SetHidden(true)
    controls.selectedName:SetText("")
    controls.selectedSource:SetText("")
    if controls.saveButton then
        SetButtonText(controls.saveButton, T("Save"))
    end
    if self.addState then
        self.addState.selectedSetId = nil
        self.addState.selectedIsPerfected = false
        self.addState.normalSetId = nil
        self.addState.perfectedSetId = nil
    end

    for _, slot in ipairs(GreedData.armorSlots) do
        self:SetEditCheckboxState(controls.armorChecks[slot.key], false)
    end

    self:SetWeaponItemCheckboxes(controls.weaponChecks, {})
    self:SetMonsterWeightCheckboxes(controls.monsterWeightChecks, nil)
    self:ApplyMonsterControlsMode(controls, false)
    self:ResetPiecePickerOwnershipStyles(controls)
end

function Greed:SearchAddSet(query)
    if not self.addState then return end

    self.addState.selected = nil
    self.addState.selectedSetId = nil
    self.addState.selectedIsPerfected = false
    self.addState.normalSetId = nil
    self.addState.perfectedSetId = nil
    self:ResetAddPicker()

    local results = self:SearchLibSetsSets(query)
    self.addState.results = results
    self:UpdateAddResults(results)
end

function Greed:UpdateAddResults(results)
    local controls = self.addControls
    if not controls then return end

    local resultCount = results and #results or 0
    for index, rowData in ipairs(controls.resultRows) do
        local result = results and results[index]
        rowData.row:SetHidden(result == nil)
        if result then
            rowData.name:SetText(result.baseName or T("Unknown Set"))
            rowData.source:SetText(result.source or "LibSets")
            rowData.perfected:SetText(result.defaultVersion == "perfected" and T("Perfected") or "")
        end
    end

    controls.emptyLabel:SetHidden(resultCount > 0)
    if resultCount == 0 then
        controls.emptyLabel:SetText((self.addState and self.addState.searchMessage) or T("No matching sets or sources."))
    end
end

function Greed:SelectAddSetResult(index)
    local result = self.addState and self.addState.results and self.addState.results[index]
    if not result then return end

    self.addState.selected = result
    self.addState.selectedIsPerfected = result.defaultVersion == "perfected" and result.perfectedSetId ~= nil
    self.addState.normalSetId = result.normalSetId or result.setId
    self.addState.perfectedSetId = result.perfectedSetId
    self.addState.selectedSetId = self.addState.selectedIsPerfected
        and (result.selectedSetId or result.perfectedSetId)
        or (result.normalSetId or result.setId)

    local controls = self.addControls
    controls.picker:SetHidden(false)
    controls.selectedName:SetText(result.baseName or T("Unknown Set"))
    controls.selectedSource:SetText(result.source or "LibSets")

    self:RefreshAddSetPickerForCurrentSelection()
end

function Greed:GetCurrentAddSetRowKey()
    local state = self.addState
    local result = state and state.selected
    if not result then return nil end

    local isPerfected = state.selectedIsPerfected == true
    return self:GetSetRowKey(result.baseName, isPerfected), isPerfected
end

function Greed:GetExistingAddSetTracking(rowKey)
    if not rowKey or self:IsRowRemoved(rowKey) then return nil end

    local saved = self:GetSavedSetOverride(rowKey)
    if type(saved) == "table" then
        return saved
    end

    for _, row in ipairs(self.displayFavorites or {}) do
        if row.rowKey == rowKey then
            return row
        end
    end

    return nil
end

function Greed:IsTrackingValueEnabled(value)
    if value == true then return true end
    if type(value) == "table" then return true end
    return false
end

function Greed:ApplyAddSetTrackingToPicker(existingTracking)
    local controls = self.addControls
    if not controls then return end

    for _, slot in ipairs(GreedData.armorSlots) do
        local value = existingTracking and existingTracking.pieces and existingTracking.pieces[slot.key]
        self:SetEditCheckboxState(controls.armorChecks[slot.key], self:IsTrackingValueEnabled(value))
    end

    for _, weapon in ipairs(WEAPON_ITEMS) do
        local value = existingTracking and existingTracking.weapons and existingTracking.weapons[weapon.key]
        self:SetEditCheckboxState(controls.weaponChecks and controls.weaponChecks[weapon.key], self:IsTrackingValueEnabled(value))
    end

    self:SetMonsterWeightCheckboxes(controls.monsterWeightChecks, existingTracking and (existingTracking.armorWeights or existingTracking.armorWeight or existingTracking.weightPreference))
end

function Greed:RefreshAddSetPickerForCurrentSelection()
    local controls = self.addControls
    local state = self.addState
    local result = state and state.selected
    if not controls or not result then return end

    local rowKey = self:GetCurrentAddSetRowKey()
    local existingTracking = self:GetExistingAddSetTracking(rowKey)

    self:ApplyAddSetTrackingToPicker(existingTracking)
    self:ApplyMonsterControlsMode(controls, result.isMonsterSet == true)
    self:RefreshAddSetPickerOwnershipStyles()

    if controls.saveButton then
        SetButtonText(controls.saveButton, existingTracking and T("Update") or T("Save"))
    end

    local sourceText = result.source or "LibSets"
    if existingTracking then
        sourceText = sourceText .. T("  |  Already on this page, editing tracked pieces")
    end
    controls.selectedSource:SetText(sourceText)
end

function Greed:BuildPiecePickerSetData(source, isPerfected, selectedSetId)
    if not source then return nil end

    local baseName = source.baseName or source.name or source.lookupName
    local normalSetId = source.normalSetId or source.setId
    local perfectedSetId = source.perfectedSetId
    local setId = selectedSetId or (isPerfected and perfectedSetId) or normalSetId or source.setId

    return {
        name = source.name or baseName,
        baseName = baseName,
        lookupName = source.lookupName or baseName,
        source = source.source,
        setId = setId,
        normalSetId = normalSetId,
        perfectedSetId = perfectedSetId,
        isPerfectedRow = isPerfected == true,
        isMonsterSet = source.isMonsterSet == true,
        armorWeights = source.armorWeights or source.armorWeight or source.weightPreference,
        pieces = type(source.pieces) == "table" and source.pieces or {},
        weapons = type(source.weapons) == "table" and source.weapons or {},
    }
end

function Greed:RefreshPiecePickerCheckboxVisual(checkbox)
    if not checkbox or not checkbox.greedBaseLabel then return end

    SetPickerCheckboxText(checkbox, checkbox.greedOwnershipLabel or checkbox.greedBaseLabel)
    SetPickerCheckboxColor(checkbox, checkbox.greedOwnershipColor or COLORS.text)
end

function Greed:ApplyPiecePickerOwnershipStyle(checkbox, setData, column, piece, ownedItemIndex)
    if not checkbox or not setData or not column or not piece then return end

    local collectedCount, neededCount = self:GetPieceCounts(column, piece, setData, ownedItemIndex)
    local stickerBookUnlocked = self:IsPieceUnlockedInStickerbook(setData, column, piece) == true
    local baseLabel = checkbox.greedBaseLabel or self:GetColumnDisplayLabel(column, piece)
    local color = COLORS.text
    local labelText = baseLabel

    if (collectedCount or 0) > 0 then
        color = COLORS.collected
        if column.key == "ring" then
            labelText = string.format("%s %d/2", baseLabel, math.min(collectedCount or 0, 2))
        end
    elseif stickerBookUnlocked then
        color = COLORS.stickerBook
    end

    checkbox.greedOwnershipColor = color
    checkbox.greedOwnershipLabel = labelText
    self:RefreshPiecePickerCheckboxVisual(checkbox)
end

function Greed:ResetPiecePickerOwnershipStyles(controls)
    if not controls then return end

    for _, slot in ipairs(GreedData.armorSlots or {}) do
        local checkbox = controls.armorChecks and controls.armorChecks[slot.key]
        if checkbox then
            checkbox.greedOwnershipColor = nil
            checkbox.greedOwnershipLabel = nil
            self:RefreshPiecePickerCheckboxVisual(checkbox)
        end
    end

    for _, weapon in ipairs(WEAPON_ITEMS) do
        local checkbox = controls.weaponChecks and controls.weaponChecks[weapon.key]
        if checkbox then
            checkbox.greedOwnershipColor = nil
            checkbox.greedOwnershipLabel = nil
            self:RefreshPiecePickerCheckboxVisual(checkbox)
        end
    end
end

function Greed:RefreshPiecePickerControlsOwnershipStyles(controls, setData, ownedItemIndex)
    if not controls or not setData then return end

    ownedItemIndex = ownedItemIndex or self:BuildOwnedItemIndex()
    for _, slot in ipairs(GreedData.armorSlots or {}) do
        local checkbox = controls.armorChecks and controls.armorChecks[slot.key]
        if checkbox then
            local column = BuildPiecePickerArmorColumn(slot)
            local piece = self:CreatePieceForSlot(setData, slot.key, setData.isPerfectedRow == true)
            self:ApplyPiecePickerOwnershipStyle(checkbox, setData, column, piece, ownedItemIndex)
        end
    end

    for _, weapon in ipairs(WEAPON_ITEMS) do
        local checkbox = controls.weaponChecks and controls.weaponChecks[weapon.key]
        if checkbox then
            local column = BuildPiecePickerWeaponColumn(weapon)
            local sourcePiece = self:GetDefaultWeaponPiece(setData, setData.isPerfectedRow == true, weapon.key)
            local piece = self:CreateWeaponPiece(sourcePiece, weapon.key, setData.isPerfectedRow == true)
            self:ApplyPiecePickerOwnershipStyle(checkbox, setData, column, piece, ownedItemIndex)
        end
    end
end

function Greed:IsPiecePickerWindowVisible(controls)
    return controls and controls.window and controls.window:IsHidden() == false
end

function Greed:HasVisiblePiecePickerWindow()
    return self:IsPiecePickerWindowVisible(self.editControls)
        or (self:IsPiecePickerWindowVisible(self.addControls) and self.addControls.picker and self.addControls.picker:IsHidden() == false)
end

function Greed:RefreshEditTrackedPiecesOwnershipStyles(ownedItemIndex)
    if not self:IsPiecePickerWindowVisible(self.editControls) or not self.editingSetData then return end

    local setData = self:BuildPiecePickerSetData(self.editingSetData, self.editingSetData.isPerfectedRow == true)
    self:RefreshPiecePickerControlsOwnershipStyles(self.editControls, setData, ownedItemIndex)
end

function Greed:GetAddSetPickerOwnershipSetData()
    local state = self.addState
    local result = state and state.selected
    if not result then return nil end

    local isPerfected = state.selectedIsPerfected == true
    local selectedSetId = state.selectedSetId
        or (isPerfected and result.perfectedSetId)
        or (state.normalSetId or result.normalSetId or result.setId)

    return self:BuildPiecePickerSetData(result, isPerfected, selectedSetId)
end

function Greed:RefreshAddSetPickerOwnershipStyles(ownedItemIndex)
    local controls = self.addControls
    if not self:IsPiecePickerWindowVisible(controls) or not controls.picker or controls.picker:IsHidden() then return end

    local setData = self:GetAddSetPickerOwnershipSetData()
    self:RefreshPiecePickerControlsOwnershipStyles(controls, setData, ownedItemIndex)
end

function Greed:RefreshPiecePickerOwnershipStyles(ownedItemIndex)
    if not self:HasVisiblePiecePickerWindow() then return end

    ownedItemIndex = ownedItemIndex or self:BuildOwnedItemIndex()
    self:RefreshEditTrackedPiecesOwnershipStyles(ownedItemIndex)
    self:RefreshAddSetPickerOwnershipStyles(ownedItemIndex)
end

function Greed:SaveAddSet()
    local controls = self.addControls
    local state = self.addState
    local result = state and state.selected
    if not controls or not result then
        SafeAnnounce(T("Greed: Select a set first."))
        return
    end

    local isPerfected = state.selectedIsPerfected == true
    local rowKey = self:GetSetRowKey(result.baseName, isPerfected)
    local wasRemoved = self:IsRowRemoved(rowKey)
    local wasAlreadyOnPage = (not wasRemoved) and self:IsSetAlreadyOnPage(rowKey)
    local selectedSetId = state.selectedSetId
        or (isPerfected and result.perfectedSetId)
        or (state.normalSetId or result.normalSetId or result.setId)
    local normalSetId = state.normalSetId or result.normalSetId or result.setId
    local perfectedSetId = state.perfectedSetId or result.perfectedSetId

    local pieces = {}
    local weapons = {}
    local hasTrackedPiece = false
    local isMonsterSet = result.isMonsterSet == true
    local armorWeights

    if isMonsterSet then
        armorWeights = self:ReadMonsterWeightCheckboxes(controls.monsterWeightChecks)
        for _, slot in ipairs(GreedData.armorSlots) do
            local checked = MONSTER_ARMOR_SLOT_KEYS[slot.key] == true and self:IsEditCheckboxChecked(controls.armorChecks[slot.key])
            pieces[slot.key] = checked == true
            hasTrackedPiece = hasTrackedPiece or checked == true
        end
        weapons = self:CreateEmptyWeaponTrackingTable()
    else
        for _, slot in ipairs(GreedData.armorSlots) do
            local checked = self:IsEditCheckboxChecked(controls.armorChecks[slot.key])
            pieces[slot.key] = checked
            hasTrackedPiece = hasTrackedPiece or checked
        end

        local hasTrackedWeapon
        weapons, hasTrackedWeapon = self:ReadWeaponItemCheckboxes(controls.weaponChecks)
        hasTrackedPiece = hasTrackedPiece or hasTrackedWeapon
    end

    if not hasTrackedPiece then
        SafeAnnounce(T("Greed: Select at least one piece to track."))
        return
    end

    self:SetRowRemoved(rowKey, false)
    self:GetSavedSets()[rowKey] = {
        userAdded = not (self:CurrentPageUsesDefaults() and self:IsDefaultRowKey(rowKey)),
        baseName = result.baseName,
        lookupName = result.lookupName or result.baseName,
        source = result.source or "LibSets",
        setId = selectedSetId,
        normalSetId = normalSetId,
        perfectedSetId = perfectedSetId,
        perfected = isPerfected,
        isMonsterSet = isMonsterSet,
        armorWeights = armorWeights,
        pieces = pieces,
        weapons = weapons,
    }

    self:HideAddSetWindow()
    self:RefreshGridFromSaved()

    if wasAlreadyOnPage then
        SafeAnnounce(T("Greed: Updated tracked pieces."))
    else
        SafeAnnounce(T("Greed: Added set to page."))
    end
end

function Greed:IsSetAlreadyOnPage(rowKey)
    if self:IsRowRemoved(rowKey) then
        return false
    end

    if self:GetSavedSetOverride(rowKey) then
        return true
    end

    for _, row in ipairs(self.displayFavorites or {}) do
        if row.rowKey == rowKey then
            return true
        end
    end

    return false
end

function Greed:GetPageCount()
    local count = 0
    local profile = self:GetCurrentTrackingProfile()

    for _, _ in pairs(profile.pages or {}) do
        count = count + 1
    end

    return count
end

function Greed:CreateEmptyPageData(usesDefaults)
    return {
        sets = {},
        removedSets = {},
        usesDefaults = usesDefaults == true,
    }
end

function Greed:ValidatePageName(pageName, oldPageName)
    local trimmedName = TrimText(pageName)
    if trimmedName == "" then
        SafeAnnounce(T("Greed: Enter a page name."))
        return nil
    end

    local lowerName = string.lower(trimmedName)
    local lowerOldName = oldPageName and string.lower(oldPageName) or nil
    local profile = self:GetCurrentTrackingProfile()
    for existingName, _ in pairs(profile.pages or {}) do
        if type(existingName) == "string" and string.lower(existingName) == lowerName and string.lower(existingName) ~= lowerOldName then
            SafeAnnounce(T("Greed: That page already exists."))
            return nil
        end
    end

    return trimmedName
end

function Greed:CreatePageNameDialog()
    if self.pageNameControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedPageNameWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(430, 180)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 275)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedPageNameBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedPageNameTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(430, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedPageNameTitle", window, CT_LABEL)
    title:SetDimensions(390, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetMouseEnabled(true)

    local editBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("GreedPageNameEditBackdrop", window, "ZO_EditBackdrop")
    editBackdrop:SetDimensions(390, 30)
    editBackdrop:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 18)

    local editBox = WINDOW_MANAGER:CreateControlFromVirtual("GreedPageNameEditBox", editBackdrop, "ZO_DefaultEditForBackdrop")
    editBox:SetAnchorFill(editBackdrop)
    editBox:SetMaxInputChars(80)
    if editBox.SetDefaultText then
        editBox:SetDefaultText(T("Page name"))
    end

    local confirmButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedPageNameConfirm", window, "ZO_DefaultButton")
    confirmButton:SetDimensions(100, 30)
    confirmButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    confirmButton:SetHandler("OnClicked", function()
        self:ConfirmPageNameDialog()
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedPageNameCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HidePageNameDialog()
    end)

    self.pageNameControls = {
        window = window,
        title = title,
        editBox = editBox,
        confirmButton = confirmButton,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "pageNameDialog")
end

function Greed:ShowPageNameDialog(mode)
    self:CreatePageNameDialog()

    self.pageNameMode = mode
    local controls = self.pageNameControls
    if mode == "rename" then
        controls.title:SetText(T("Rename Page"))
        SetButtonText(controls.confirmButton, T("Rename"))
        controls.editBox:SetText(self:GetCurrentPageName())
    else
        controls.title:SetText(T("New Page"))
        SetButtonText(controls.confirmButton, T("Create"))
        controls.editBox:SetText("")
    end

    controls.window:SetHidden(false)
    -- Do not auto-focus the page name box. The user can click it when ready.
end

function Greed:HidePageNameDialog()
    if self.pageNameControls and self.pageNameControls.window then
        self.pageNameControls.window:SetHidden(true)
    end
    self.pageNameMode = nil
end

function Greed:ConfirmPageNameDialog()
    local controls = self.pageNameControls
    if not controls then return end

    if self.pageNameMode == "rename" then
        self:RenameCurrentPage(controls.editBox:GetText())
    else
        self:CreateNewPage(controls.editBox:GetText())
    end
end

function Greed:CreateNewPage(pageName)
    local newPageName = self:ValidatePageName(pageName)
    if not newPageName then return end

    local profile = self:GetCurrentTrackingProfile()
    profile.pages[newPageName] = self:CreateEmptyPageData(false)
    self:SyncPageOrder()
    if not self:GetPageOrderIndex(newPageName) then
        table.insert(profile.pageOrder, newPageName)
    end
    profile.currentPage = newPageName

    self:HidePageNameDialog()
    self:BuildPageDropdown()
    self:RefreshGridFromSaved()
end

function Greed:RenameCurrentPage(pageName)
    local oldPageName = self:GetCurrentPageName()
    local newPageName = self:ValidatePageName(pageName, oldPageName)
    if not newPageName then return end

    if newPageName == oldPageName then
        self:HidePageNameDialog()
        return
    end

    local profile = self:GetCurrentTrackingProfile()
    profile.pages[newPageName] = profile.pages[oldPageName]
    profile.pages[oldPageName] = nil
    self:SetPageOrderName(oldPageName, newPageName)
    self:SyncPageOrder()
    profile.currentPage = newPageName

    self:HidePageNameDialog()
    self:BuildPageDropdown()
    self:RefreshGridFromSaved()
end

function Greed:CreateDeletePageDialog()
    if self.deletePageControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedDeletePageWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(450, 180)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 275)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedDeletePageBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedDeletePageTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(450, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedDeletePageTitle", window, CT_LABEL)
    title:SetDimensions(410, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Delete Page"))
    title:SetMouseEnabled(true)

    local message = WINDOW_MANAGER:CreateControl("GreedDeletePageMessage", window, CT_LABEL)
    message:SetDimensions(410, 48)
    message:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 14)
    message:SetFont("ZoFontGame")
    AllowMultilineLabelText(message, 3)
    message:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

    local deleteButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDeletePageConfirm", window, "ZO_DefaultButton")
    deleteButton:SetDimensions(100, 30)
    deleteButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    SetButtonText(deleteButton, T("Delete"))
    deleteButton:SetHandler("OnClicked", function()
        self:ConfirmDeletePage()
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedDeletePageCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HideDeletePageDialog()
    end)

    self.deletePageControls = {
        window = window,
        message = message,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "deletePageDialog")
end

function Greed:ShowDeletePageDialog()
    if self:GetPageCount() <= 1 then
        SafeAnnounce(T("Greed: You must keep at least one page."))
        return
    end

    self:CreateDeletePageDialog()
    local pageName = self:GetCurrentPageName()
    self.deletePageControls.message:SetText(T("Delete page \"%s\" and all rows on it?", pageName))
    self.deletePageControls.window:SetHidden(false)
end

function Greed:HideDeletePageDialog()
    if self.deletePageControls and self.deletePageControls.window then
        self.deletePageControls.window:SetHidden(true)
    end
end

function Greed:ConfirmDeletePage()
    if self:GetPageCount() <= 1 then
        SafeAnnounce(T("Greed: You must keep at least one page."))
        self:HideDeletePageDialog()
        return
    end

    local pageName = self:GetCurrentPageName()
    local profile = self:GetCurrentTrackingProfile()
    profile.pages[pageName] = nil
    self:RemovePageFromOrder(pageName)
    self:SyncPageOrder()
    profile.currentPage = self:GetFallbackPageName()

    self:HideDeletePageDialog()
    self:BuildPageDropdown()
    self:RefreshGridFromSaved()
end


function Greed:GetPageDataByName(pageName)
    self:InitializeSavedPages()
    local profile = self:GetCurrentTrackingProfile()
    return pageName and profile.pages[pageName] or nil
end

function Greed:PageUsesDefaults(pageName)
    local pageData = self:GetPageDataByName(pageName)
    return pageData and pageData.usesDefaults == true
end

function Greed:IsRowRemovedOnPage(pageName, rowKey)
    local pageData = self:GetPageDataByName(pageName)
    return pageData and pageData.removedSets and pageData.removedSets[rowKey] == true
end

function Greed:GetSavedSetOnPage(pageName, rowKey)
    local pageData = self:GetPageDataByName(pageName)
    return pageData and pageData.sets and pageData.sets[rowKey] or nil
end

function Greed:IsRowVisibleOnPage(pageName, rowKey)
    local pageData = self:GetPageDataByName(pageName)
    if not pageData or not rowKey then return false end
    if pageData.removedSets and pageData.removedSets[rowKey] == true then return false end
    if pageData.sets and pageData.sets[rowKey] then return true end
    if pageData.usesDefaults == true and self:IsDefaultRowKey(rowKey) then return true end

    return false
end

function Greed:CreateSavedOverrideFromDisplayRow(setData, destinationPageName)
    local destinationUsesDefaults = self:PageUsesDefaults(destinationPageName)
    local existingOverride = self:GetSavedSetOnPage(self:GetCurrentPageName(), setData.rowKey) or {}
    local pieces = {}
    local weapons = self:CreateEmptyWeaponTrackingTable()

    for _, slot in ipairs(GreedData.armorSlots) do
        pieces[slot.key] = setData.pieces and setData.pieces[slot.key] ~= nil or false
    end

    for _, weapon in ipairs(WEAPON_ITEMS) do
        weapons[weapon.key] = setData.weapons and setData.weapons[weapon.key] ~= nil or false
    end

    return {
        userAdded = not (destinationUsesDefaults and self:IsDefaultRowKey(setData.rowKey)),
        baseName = setData.baseName,
        lookupName = setData.lookupName,
        source = setData.source,
        setId = setData.setId,
        normalSetId = existingOverride.normalSetId or setData.normalSetId,
        perfectedSetId = existingOverride.perfectedSetId or setData.perfectedSetId,
        perfected = setData.isPerfectedRow == true,
        isMonsterSet = self:IsMonsterSetData(setData),
        armorWeights = self:IsMonsterSetData(setData) and self:NormalizeMonsterArmorWeights(setData.armorWeights or setData.armorWeight or setData.weightPreference) or nil,
        pieces = pieces,
        weapons = weapons,
    }
end

function Greed:CreateMovePageWindow()
    if self.movePageControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedMovePageWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(520, 310)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 275)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedMovePageBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedMovePageTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(520, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedMovePageTitle", window, CT_LABEL)
    title:SetDimensions(480, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Move to Another Page"))
    title:SetMouseEnabled(true)

    local message = WINDOW_MANAGER:CreateControl("GreedMovePageMessage", window, CT_LABEL)
    message:SetDimensions(480, 58)
    message:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    message:SetFont("ZoFontGame")
    AllowMultilineLabelText(message, 3)
    message:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

    local destinationHeader = WINDOW_MANAGER:CreateControl("GreedMovePageDestinationHeader", window, CT_LABEL)
    destinationHeader:SetDimensions(240, 20)
    destinationHeader:SetAnchor(TOPLEFT, message, BOTTOMLEFT, 0, 8)
    destinationHeader:SetFont("ZoFontGameSmall")
    destinationHeader:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    destinationHeader:SetText(T("Destination page"))

    local editBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("GreedMovePageEditBackdrop", window, "ZO_EditBackdrop")
    editBackdrop:SetDimensions(310, 30)
    editBackdrop:SetAnchor(TOPLEFT, destinationHeader, BOTTOMLEFT, 0, 4)

    local editBox = WINDOW_MANAGER:CreateControlFromVirtual("GreedMovePageEditBox", editBackdrop, "ZO_DefaultEditForBackdrop")
    editBox:SetAnchorFill(editBackdrop)
    editBox:SetMaxInputChars(80)
    if editBox.SetDefaultText then
        editBox:SetDefaultText(T("Type or click a page name"))
    end

    local optionsHeader = WINDOW_MANAGER:CreateControl("GreedMovePageOptionsHeader", window, CT_LABEL)
    optionsHeader:SetDimensions(240, 20)
    optionsHeader:SetAnchor(TOPLEFT, editBackdrop, BOTTOMLEFT, 0, 10)
    optionsHeader:SetFont("ZoFontGameSmall")
    optionsHeader:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    optionsHeader:SetText(T("Existing pages"))

    local pageButtons = {}
    for index = 1, 8 do
        local button = WINDOW_MANAGER:CreateControlFromVirtual("GreedMovePageOption" .. index, window, "ZO_DefaultButton")
        button:SetDimensions(150, 26)
        local col = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        button:SetAnchor(TOPLEFT, optionsHeader, BOTTOMLEFT, col * 158, 4 + row * 30)
        button:SetHidden(true)
        pageButtons[index] = button
    end

    local moveButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedMovePageConfirm", window, "ZO_DefaultButton")
    moveButton:SetDimensions(100, 30)
    moveButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    SetButtonText(moveButton, T("Move"))
    moveButton:SetHandler("OnClicked", function()
        self:ConfirmMoveToPage()
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedMovePageCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HideMovePageDialog()
    end)

    self.movePageControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        message = message,
        editBox = editBox,
        pageButtons = pageButtons,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "movePageDialog")
end

function Greed:BuildMovePageOptions()
    local controls = self.movePageControls
    if not controls then return end

    local currentPage = self:GetCurrentPageName()
    local destinations = {}
    for _, pageName in ipairs(self:GetPageNames()) do
        if pageName ~= currentPage then
            table.insert(destinations, pageName)
        end
    end

    for index, button in ipairs(controls.pageButtons or {}) do
        local pageName = destinations[index]
        button:SetHidden(pageName == nil)
        if pageName then
            SetButtonText(button, pageName)
            button:SetHandler("OnClicked", function()
                controls.editBox:SetText(pageName)
            end)
        end
    end

    if destinations[1] then
        controls.editBox:SetText(destinations[1])
    else
        controls.editBox:SetText("")
    end
end

function Greed:ShowMovePageDialog(setData)
    if not setData or not setData.rowKey then return end

    if self:GetPageCount() <= 1 then
        SafeAnnounce(T("Greed: Create another page first."))
        return
    end

    self:CreateMovePageWindow()
    self.pendingMoveSetData = setData

    local baseName = setData.baseName or setData.name or T("Unknown Set")
    local versionText = setData.isPerfectedRow and T("Perfected") or T("Normal")
    self.movePageControls.message:SetText(T("Set: %s\nVersion: %s\nCurrent page: %s", baseName, versionText, self:GetCurrentPageName()))
    self:BuildMovePageOptions()
    self.movePageControls.window:SetHidden(false)

    -- Do not auto-focus the destination box. The user can click it when ready.
end

function Greed:HideMovePageDialog()
    if self.movePageControls and self.movePageControls.window then
        self.movePageControls.window:SetHidden(true)
    end
    self.pendingMoveSetData = nil
end

function Greed:RemoveMovedRowFromSourcePage(pageName, setData)
    local pageData = self:GetPageDataByName(pageName)
    if not pageData or not setData or not setData.rowKey then return end

    local savedRow = pageData.sets and pageData.sets[setData.rowKey]
    local isDefaultRowOnDefaultsPage = pageData.usesDefaults == true and self:IsDefaultRowKey(setData.rowKey)
    local savedRowIsUserAdded = savedRow and savedRow.userAdded == true

    if isDefaultRowOnDefaultsPage and not savedRowIsUserAdded then
        pageData.removedSets = pageData.removedSets or {}
        pageData.removedSets[setData.rowKey] = true
    else
        pageData.sets = pageData.sets or {}
        pageData.sets[setData.rowKey] = nil
        if pageData.removedSets then
            pageData.removedSets[setData.rowKey] = nil
        end
    end
end

function Greed:ConfirmMoveToPage()
    local controls = self.movePageControls
    local setData = self.pendingMoveSetData
    if not controls or not setData or not setData.rowKey then
        self:HideMovePageDialog()
        return
    end

    local destinationName = TrimText(controls.editBox:GetText())
    if destinationName == "" then
        SafeAnnounce(T("Greed: Enter a destination page."))
        return
    end

    local currentPage = self:GetCurrentPageName()
    if string.lower(destinationName) == string.lower(currentPage) then
        SafeAnnounce(T("Greed: Choose a different page."))
        return
    end

    local destinationPage = self:GetPageDataByName(destinationName)
    if not destinationPage then
        SafeAnnounce(T("Greed: That page does not exist."))
        return
    end

    if self:IsRowVisibleOnPage(destinationName, setData.rowKey) then
        SafeAnnounce(T("Greed: That set is already on the destination page."))
        return
    end

    local movedRow = self:CreateSavedOverrideFromDisplayRow(setData, destinationName)
    destinationPage.sets = destinationPage.sets or {}
    destinationPage.removedSets = destinationPage.removedSets or {}
    destinationPage.removedSets[setData.rowKey] = nil
    destinationPage.sets[setData.rowKey] = movedRow

    self:RemoveMovedRowFromSourcePage(currentPage, setData)
    self:HideMovePageDialog()
    self:RefreshGridFromSaved()
    SafeAnnounce(T("Greed: Moved %s to %s.", setData.name or setData.baseName or T("set"), destinationName))
end

function Greed:SearchLibSetsSets(query)
    local searchText = string.lower(TrimText(query))
    if #searchText < 2 then
        if self.addState then
            self.addState.searchMessage = T("Type at least two characters.")
        end
        return {}
    end

    local language = self:GetClientLanguage()
    local allNames = GetCachedAllSetNames()
    local searchCache = GetLibSetsSearchCache(language)
    local results = {}
    local seen = {}

    for setId, names in pairs(allNames or {}) do
        local nameEntry = self:GetLibSetsSearchNameEntry(setId, names, language, searchCache)
        local displayName = nameEntry and nameEntry.displayName
        if displayName then
            local result
            if string.find(nameEntry.searchName or "", searchText, 1, true) then
                result = self:GetCachedLibSetsSearchResult(setId, displayName, language, searchCache)
            elseif nameEntry.result then
                if string.find(nameEntry.result.searchText or "", searchText, 1, true) then
                    result = nameEntry.result
                end
            else
                local candidate = self:GetCachedLibSetsSearchResult(setId, displayName, language, searchCache)
                if string.find(candidate.searchText or "", searchText, 1, true) then
                    result = candidate
                end
            end

            if result then
                local resultVersion = result.defaultVersion == "perfected" and "perfected" or "normal"
                local resultKey = string.lower((result.baseName or displayName) .. "|" .. resultVersion)
                if not seen[resultKey] then
                    seen[resultKey] = true
                    table.insert(results, result)
                elseif result.hasPerfected then
                    for _, existing in ipairs(results) do
                        local existingVersion = existing.defaultVersion == "perfected" and "perfected" or "normal"
                        local existingKey = string.lower((existing.baseName or "") .. "|" .. existingVersion)
                        if existingKey == resultKey then
                            existing.hasPerfected = true
                            existing.normalSetId = existing.normalSetId or result.normalSetId or result.setId
                            existing.perfectedSetId = existing.perfectedSetId or result.perfectedSetId
                            break
                        end
                    end
                end
            end
        end
    end

    table.sort(results, SortAddSetResultsByBaseName)

    while #results > ADD_SET_RESULT_LIMIT do
        table.remove(results)
    end

    if self.addState then
        self.addState.searchMessage = #results == 0 and T("No matching sets found.") or ""
    end

    return results
end

function Greed:GetClientLanguage()
    return GetClientLanguageCode()
end

function Greed:GetLocalizedLibSetsNameForLanguage(names, lang, allowFallback)
    if type(names) == "string" then
        return names
    end
    if type(names) ~= "table" then
        return nil
    end

    lang = lang or self:GetClientLanguage()
    if names[lang] and names[lang] ~= "" then
        return names[lang]
    end
    if allowFallback == false then
        return nil
    end
    if names.en and names.en ~= "" then
        return names.en
    end

    for _, name in pairs(names) do
        if type(name) == "string" and name ~= "" then
            return name
        end
    end

    return nil
end

function Greed:GetLocalizedLibSetsName(names)
    return self:GetLocalizedLibSetsNameForLanguage(names, self:GetClientLanguage())
end

function Greed:GetRepresentativeSetItemId(setId)
    local numericSetId = tonumber(setId)
    if not numericSetId then return nil end

    local itemId = libSets.GetSetItemId(numericSetId)
    if itemId then return itemId end

    for _, filters in ipairs(LIVE_SET_NAME_ITEM_FILTERS) do
        itemId = libSets.GetSetItemId(numericSetId, nil, filters.equipType, nil, nil, nil, filters.weaponType)
        if itemId then return itemId end
    end

    return nil
end

function Greed:GetLiveClientSetName(setId, language)
    local numericSetId = tonumber(setId)
    if not numericSetId then return nil end

    language = NormalizeClientLanguageCode(language or self:GetClientLanguage())
    local cache = GetLiveSetNameCache(language)
    local cachedName = cache[numericSetId]
    if cachedName ~= nil then
        return cachedName ~= false and cachedName or nil
    end
    if language == "en" then
        cache[numericSetId] = false
        return nil
    end

    local itemId = self:GetRepresentativeSetItemId(numericSetId)
    local itemLink = itemId and self:BuildItemLinkFromItemId(itemId) or nil
    if itemLink and type(GetItemLinkSetInfo) == "function" then
        local ok, hasSet, setName = pcall(function()
            return GetItemLinkSetInfo(itemLink, false)
        end)
        if ok and hasSet == true and type(setName) == "string" and setName ~= "" then
            local cleanName = self:CleanEsoDisplayText(setName)
            if cleanName ~= "" then
                cache[numericSetId] = cleanName
                return cleanName
            end
        end
    end

    cache[numericSetId] = false
    return nil
end

function Greed:GetLibSetsSearchNameEntry(setId, names, language, searchCache)
    local numericSetId = tonumber(setId)
    local cacheKey = tostring(numericSetId or setId)
    language = NormalizeClientLanguageCode(language or self:GetClientLanguage())
    searchCache = searchCache or GetLibSetsSearchCache(language)
    local entry = searchCache[cacheKey]
    if not entry then
        entry = {
            setId = numericSetId or setId,
        }
        searchCache[cacheKey] = entry
    end

    if entry.names ~= names then
        local liveName = self:GetLiveClientSetName(numericSetId or setId, language)
        local localizedName = self:GetLocalizedLibSetsNameForLanguage(names, language, false)
        local englishName = self:GetLocalizedLibSetsNameForLanguage(names, "en", false)
        local displayName = liveName or localizedName or englishName or self:GetLocalizedLibSetsNameForLanguage(names, language)
        entry.names = names
        entry.displayName = displayName
        entry.searchName = string.lower(table.concat({
            liveName or "",
            localizedName or "",
            englishName or "",
            displayName or "",
        }, " "))
    end

    return entry
end

function Greed:GetCachedLibSetsSearchResult(setId, matchedName, language, searchCache)
    local numericSetId = tonumber(setId)
    local cacheKey = tostring(numericSetId or setId)
    searchCache = searchCache or GetLibSetsSearchCache(language)
    local entry = searchCache[cacheKey] or {
        setId = numericSetId or setId,
        displayName = matchedName,
        searchName = string.lower(matchedName or ""),
    }
    searchCache[cacheKey] = entry

    if not entry.result then
        entry.result = self:BuildLibSetsSearchResult(setId, matchedName, language)
        entry.result.searchText = string.lower(table.concat({
            matchedName or "",
            entry.result.baseName or "",
            entry.result.source or "",
        }, " "))
    end

    return entry.result
end

function Greed:GetLibSetsSetName(setId)
    local numericSetId = tonumber(setId)
    local liveName = self:GetLiveClientSetName(numericSetId or setId, self:GetClientLanguage())
    if liveName then return liveName end

    local allNames = GetCachedAllSetNames()
    local names = allNames[numericSetId or setId]

    if names == nil and numericSetId ~= nil then
        names = allNames[tostring(numericSetId)]
    end

    return self:GetLocalizedLibSetsName(names)
end

function Greed:IsLibSetsMonsterSet(setId, sourceText, lang)
    if libSets.IsMonsterSet(setId) == true then
        return true
    end

    local setInfo = libSets.GetSetInfo(setId, true, lang or self:GetClientLanguage())
    if type(setInfo) == "table" then
        local typeName = setInfo.setTypeName or setInfo.typeName or setInfo.categoryName
        if type(typeName) == "string" and string.lower(typeName):find("monster", 1, true) then
            return true
        end
    end

    return type(sourceText) == "string" and string.lower(sourceText):find("monster", 1, true) ~= nil
end

function Greed:BuildLibSetsSearchResult(setId, matchedName, lang)
    local numericSetId = tonumber(setId) or setId
    local _, normalSetId, perfectedSetId, isPerfected = self:ResolveTrackedRowIdentity({ setId = numericSetId })
    normalSetId = normalSetId or numericSetId

    local baseName = self:GetLibSetsSetName(normalSetId) or matchedName or T("Unknown Set")

    local source = self:GetLibSetsSourceText(normalSetId, lang)
    local isMonsterSet = self:IsLibSetsMonsterSet(normalSetId, source, lang)
    local hasPerfected = perfectedSetId ~= nil

    return {
        setId = normalSetId,
        normalSetId = normalSetId,
        perfectedSetId = perfectedSetId,
        selectedSetId = numericSetId,
        baseName = baseName,
        lookupName = baseName,
        source = source or "LibSets",
        hasPerfected = hasPerfected,
        isMonsterSet = isMonsterSet,
        defaultVersion = isPerfected and hasPerfected and "perfected" or "normal",
        searchText = string.lower(table.concat({ matchedName or "", baseName or "", source or "" }, " ")),
    }
end

function Greed:GetLibSetsSourceText(setId, lang)
    lang = lang or self:GetClientLanguage()
    local setInfo = libSets.GetSetInfo(setId, true, lang)
    local setType = setInfo and setInfo.setType or libSets.GetSetType(setId)

    local typeName
    if setType then
        typeName = libSets.GetSetTypeName(setType, lang) or libSets.GetSetTypeName(setType, "en")
    end

    local zoneName
    local zoneIds = setInfo and setInfo.zoneIds or libSets.GetZoneIds(setId)

    if type(zoneIds) == "table" then
        for _, zoneId in pairs(zoneIds) do
            if type(zoneId) == "number" and zoneId > 0 then
                zoneName = libSets.GetZoneName(zoneId, lang) or libSets.GetZoneName(zoneId, "en")
                break
            end
        end
    end

    if typeName and zoneName and zoneName ~= "" then
        return typeName .. " - " .. zoneName
    end
    if typeName and typeName ~= "" then
        return typeName
    end

    return "LibSets"
end

function Greed:GetMainRowsScrollOffset()
    return self.rowsScroll and self.rowsScroll.offset or 0
end

function Greed:RestoreMainRowsScrollOffset(offset)
    if not self.rowsScroll then return end

    local maxOffset = self.rowsScroll.maxOffset or 0
    self:SetRowsScrollOffset(math.min(tonumber(offset) or 0, maxOffset))
end

function Greed:RefreshGridFromSaved(ownedItemIndex)
    local scrollOffset = self:GetMainRowsScrollOffset()

    self.displayFavorites = self:BuildDisplayFavorites()
    self:BuildVisibleColumns()
    self:UpdateMainWindowLayout()
    self:BuildSlotHeader()
    self:BuildFavorites(ownedItemIndex)
    self:RestoreMainRowsScrollOffset(scrollOffset)
    self:LiftMainTopControls()
    if type(self.RefreshDropListWindow) == "function" then
        self:RefreshDropListWindow()
    end
end



function Greed:BuildTrackedSetIndex(query)
    local entries = {}
    local filter = TrimText(query or ""):lower()

    for _, pageName in ipairs(self:GetPageNames()) do
        local rows = self:GetDisplayFavoritesForPage(pageName) or {}
        for _, row in ipairs(rows) do
            if row and self:DisplaySetHasTrackedPieces(row) then
                local setName = row.baseName or row.name or T("Unknown Set")
                local versionText = row.isPerfectedRow and T("Perfected") or T("Normal")
                local sourceText = row.source or ""
                local haystack = (pageName .. " " .. setName .. " " .. versionText .. " " .. sourceText):lower()
                if filter == "" or haystack:find(filter, 1, true) then
                    table.insert(entries, {
                        pageName = pageName,
                        setName = setName,
                        versionText = versionText,
                        sourceText = sourceText,
                    })
                end
            end
        end
    end

    table.sort(entries, function(a, b)
        local left = (a.setName or "") .. (a.versionText or "") .. (a.pageName or "")
        local right = (b.setName or "") .. (b.versionText or "") .. (b.pageName or "")
        return left < right
    end)

    return entries
end

function Greed:CreateSetsOverviewWindow()
    if self.setsOverviewControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedSetsOverviewWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(720, 500)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 275)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedSetsOverviewBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedSetsOverviewTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(720, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedSetsOverviewTitle", window, CT_LABEL)
    title:SetDimensions(560, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Tracked Sets"))
    title:SetMouseEnabled(true)

    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedSetsOverviewClose", window, "ZO_DefaultButton")
    closeButton:SetDimensions(32, 28)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -16, 12)
    SetButtonText(closeButton, "X")
    closeButton:SetHandler("OnClicked", function()
        self:HideSetsOverviewWindow()
    end)

    local searchBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("GreedSetsOverviewSearchBackdrop", window, "ZO_EditBackdrop")
    searchBackdrop:SetDimensions(480, 32)
    searchBackdrop:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 58)

    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("GreedSetsOverviewSearchEdit", searchBackdrop, "ZO_DefaultEditForBackdrop")
    searchBox:SetAnchorFill(searchBackdrop)
    searchBox:SetMaxInputChars(80)
    searchBox:SetText("")

    local searchButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedSetsOverviewSearchButton", window, "ZO_DefaultButton")
    searchButton:SetDimensions(90, 30)
    searchButton:SetAnchor(LEFT, searchBackdrop, RIGHT, 8, 0)
    SetButtonText(searchButton, T("Search"))
    searchButton:SetHandler("OnClicked", function()
        self:RefreshSetsOverviewWindow()
    end)

    local clearButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedSetsOverviewClearButton", window, "ZO_DefaultButton")
    clearButton:SetDimensions(72, 30)
    clearButton:SetAnchor(LEFT, searchButton, RIGHT, 8, 0)
    SetButtonText(clearButton, T("Clear"))
    clearButton:SetHandler("OnClicked", function()
        searchBox:SetText("")
        self:RefreshSetsOverviewWindow()
    end)

    local countLabel = WINDOW_MANAGER:CreateControl("GreedSetsOverviewCount", window, CT_LABEL)
    countLabel:SetDimensions(660, 20)
    countLabel:SetAnchor(TOPLEFT, searchBackdrop, BOTTOMLEFT, 0, 8)
    countLabel:SetFont("ZoFontGameSmall")
    countLabel:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    local rows = {}
    for index = 1, SETS_OVERVIEW_MAX_ROWS do
        local row = WINDOW_MANAGER:CreateControl("GreedSetsOverviewRow" .. index, window, CT_CONTROL)
        row:SetDimensions(684, 30)
        row:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 118 + ((index - 1) * 32))
        row:SetHidden(true)

        local bg = WINDOW_MANAGER:CreateControl("GreedSetsOverviewRow" .. index .. "Bg", row, CT_BACKDROP)
        bg:SetAnchorFill(row)
        SetBackdropStyle(bg, index % 2 == 0 and COLORS.rowAlt or COLORS.row, COLORS.mutedEdge)

        local text = WINDOW_MANAGER:CreateControl("GreedSetsOverviewRow" .. index .. "Text", row, CT_LABEL)
        text:SetDimensions(590, 24)
        text:SetAnchor(LEFT, row, LEFT, 8, 0)
        text:SetFont("ZoFontGame")
        text:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

        local goButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedSetsOverviewRow" .. index .. "Go", row, "ZO_DefaultButton")
        goButton:SetDimensions(58, 24)
        goButton:SetAnchor(RIGHT, row, RIGHT, -6, 0)
        SetButtonText(goButton, T("Go"))

        rows[index] = {
            row = row,
            text = text,
            goButton = goButton,
        }
    end

    self.setsOverviewControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        searchBox = searchBox,
        countLabel = countLabel,
        rows = rows,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "setsOverview")
end

function Greed:ShowSetsOverviewWindow()
    self:CreateSetsOverviewWindow()
    self:RefreshSetsOverviewWindow()
    self.setsOverviewControls.window:SetHidden(false)
end

function Greed:HideSetsOverviewWindow()
    if self.setsOverviewControls and self.setsOverviewControls.window then
        self.setsOverviewControls.window:SetHidden(true)
    end
end

function Greed:RefreshSetsOverviewWindow()
    local controls = self.setsOverviewControls
    if not controls then return end

    local query = controls.searchBox and controls.searchBox:GetText() or ""
    local entries = self:BuildTrackedSetIndex(query)
    controls.countLabel:SetText(T("%d tracked rows across all pages. Use Search to filter, then Go to jump to the page.", #entries))

    for index, rowControl in ipairs(controls.rows or {}) do
        local entry = entries[index]
        rowControl.row:SetHidden(entry == nil)
        if entry then
            local sourceText = entry.sourceText and entry.sourceText ~= "" and (" - " .. entry.sourceText) or ""
            rowControl.text:SetText((entry.setName or T("Unknown Set")) .. " (" .. (entry.versionText or T("Normal")) .. ")  |  " .. (entry.pageName or T("Unknown Page")) .. sourceText)
            rowControl.goButton:SetHandler("OnClicked", function()
                self:JumpToTrackedSetPage(entry.pageName)
            end)
        end
    end
end

function Greed:JumpToTrackedSetPage(pageName)
    if not pageName then return end
    self:SelectPage(pageName)
    self.activeTab = "grid"
    for key, button in pairs(self.controls.tabs) do
        local color = key == self.activeTab and COLORS.activeTab or COLORS.inactiveTab
        button:SetNormalFontColor(color[1], color[2], color[3], color[4])
    end
    self:HideSetsOverviewWindow()
    self:ShowWindow()
end

function Greed:GetSourcesToFarmSizeBounds()
    local screenWidth = GetControlDimension(GuiRoot, "GetWidth", SOURCES_TO_FARM_MAX_WIDTH + 20)
    local screenHeight = GetControlDimension(GuiRoot, "GetHeight", SOURCES_TO_FARM_MAX_HEIGHT + 20)
    local maxWidth = math.max(SOURCES_TO_FARM_MIN_WIDTH, math.min(SOURCES_TO_FARM_MAX_WIDTH, math.max(SOURCES_TO_FARM_MIN_WIDTH, screenWidth - 20)))
    local maxHeight = math.max(SOURCES_TO_FARM_MIN_HEIGHT, math.min(SOURCES_TO_FARM_MAX_HEIGHT, math.max(SOURCES_TO_FARM_MIN_HEIGHT, screenHeight - 20)))

    return SOURCES_TO_FARM_MIN_WIDTH, maxWidth, SOURCES_TO_FARM_MIN_HEIGHT, maxHeight
end

function Greed:GetSourcesToFarmContentFitHeight(rowCount)
    local rows = math.max(0, tonumber(rowCount) or 0)
    return SOURCES_TO_FARM_ROW_START_Y + (rows * SOURCES_TO_FARM_ROW_HEIGHT) + SOURCES_TO_FARM_BOTTOM_INSET
end

function Greed:GetSourcesToFarmContentMaxHeight(rowCount)
    local _, _, minHeight, screenMaxHeight = self:GetSourcesToFarmSizeBounds()
    local contentFitHeight = self:GetSourcesToFarmContentFitHeight(rowCount)
    return math.max(minHeight, math.min(screenMaxHeight, contentFitHeight))
end

function Greed:GetSourcesToFarmCurrentContentMaxHeight()
    local controls = self.sourcesToFarmControls
    return self:GetSourcesToFarmContentMaxHeight(#(controls and controls.entries or {}))
end

function Greed:GetSourcesToFarmSavedSize()
    local minWidth, maxWidth, minHeight, maxHeight = self:GetSourcesToFarmSizeBounds()
    local saved = self.savedVars and self.savedVars.windowPositions and self.savedVars.windowPositions.sourcesToFarm
    local width = saved and saved.width or SOURCES_TO_FARM_DEFAULT_WIDTH
    local height = saved and saved.height or SOURCES_TO_FARM_DEFAULT_HEIGHT

    return ClampSourcesToFarmNumber(width, SOURCES_TO_FARM_DEFAULT_WIDTH, minWidth, maxWidth),
        ClampSourcesToFarmNumber(height, SOURCES_TO_FARM_DEFAULT_HEIGHT, minHeight, maxHeight)
end

function Greed:GetSourcesToFarmVisibleRowCount(height, rowCount)
    local windowHeight = tonumber(height)
    if not windowHeight and self.sourcesToFarmControls and self.sourcesToFarmControls.window then
        windowHeight = GetControlDimension(self.sourcesToFarmControls.window, "GetHeight", SOURCES_TO_FARM_DEFAULT_HEIGHT)
    end

    local available = (windowHeight or SOURCES_TO_FARM_DEFAULT_HEIGHT) - SOURCES_TO_FARM_ROW_START_Y - SOURCES_TO_FARM_BOTTOM_INSET
    local visibleRows = math.max(SOURCES_TO_FARM_MIN_VISIBLE_ROWS, math.floor(available / SOURCES_TO_FARM_ROW_HEIGHT))
    if type(rowCount) == "number" then
        return math.min(visibleRows, math.max(SOURCES_TO_FARM_MIN_VISIBLE_ROWS, rowCount))
    end

    return visibleRows
end

function Greed:CreateSourcesToFarmWindow()
    if self.sourcesToFarmControls then return end

    local width, height = self:GetSourcesToFarmSavedSize()
    local window = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(width, height)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 285)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(width, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmTitle", window, CT_LABEL)
    title:SetDimensions(560, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Sources to Farm"))
    title:SetMouseEnabled(true)

    local refreshButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedSourcesToFarmRefresh", window, "ZO_DefaultButton")
    refreshButton:SetDimensions(82, 28)
    refreshButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -58, 12)
    SetButtonText(refreshButton, T("Refresh"))
    StyleTransparentTextButton(refreshButton)
    refreshButton:SetHandler("OnClicked", function()
        self:RefreshSourcesToFarmWindow()
    end)
    SetSimpleTooltip(refreshButton, T("Refresh Sources"))

    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedSourcesToFarmClose", window, "ZO_DefaultButton")
    closeButton:SetDimensions(32, 28)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -16, 12)
    SetButtonText(closeButton, "X")
    StyleTransparentTextButton(closeButton)
    closeButton:SetHandler("OnClicked", function()
        self:HideSourcesToFarmWindow()
    end)
    SetSimpleTooltip(closeButton, T("Close Sources"))

    local countLabel = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmCount", window, CT_LABEL)
    countLabel:SetDimensions(width - 36, 20)
    countLabel:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    countLabel:SetFont("ZoFontGameSmall")
    countLabel:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])

    local track = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmScrollTrack", window, CT_BACKDROP)
    track:SetDimensions(12, SOURCES_TO_FARM_MAX_ROWS * SOURCES_TO_FARM_ROW_HEIGHT)
    track:SetAnchor(TOPRIGHT, window, TOPRIGHT, -SOURCES_TO_FARM_SCROLLBAR_RIGHT_INSET, SOURCES_TO_FARM_ROW_START_Y)
    track:SetMouseEnabled(false)
    SetBackdropStyle(track, COLORS.scrollTrack, COLORS.edge)

    local thumb = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmScrollThumb", track, CT_BACKDROP)
    thumb:SetDimensions(8, 42)
    thumb:SetAnchor(TOP, track, TOP, 0, 2)
    thumb:SetMouseEnabled(false)
    SetBackdropStyle(thumb, COLORS.scrollThumb, COLORS.edge)

    window:SetHandler("OnMouseWheel", function(_, delta)
        self:ScrollSourcesToFarm(delta)
    end)

    self.sourcesToFarmControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        refreshButton = refreshButton,
        closeButton = closeButton,
        countLabel = countLabel,
        headers = {},
        rows = {},
        track = track,
        thumb = thumb,
        entries = {},
        scrollOffset = 0,
        sortKey = "source",
        sortAscending = true,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "sourcesToFarm")
    self:CreateSourcesToFarmResizeControls()
    self:LayoutSourcesToFarmWindow()
end

function Greed:EnsureSourcesToFarmHeaderControls(columnDefs)
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window then return end

    controls.headers = controls.headers or {}
    for _, column in ipairs(columnDefs or {}) do
        local header = controls.headers[column.key]
        if not header then
            header = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmHeader" .. column.key, controls.window, CT_LABEL)
            header:SetFont("ZoFontGameSmall")
            header:SetColor(COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], COLORS.gold[4])
            if column.sortable then
                local sortKey = column.key
                header:SetMouseEnabled(true)
                header:SetHandler("OnMouseUp", function(_, button)
                    if button == MOUSE_BUTTON_INDEX_LEFT then
                        self:SetSourcesToFarmSort(sortKey)
                    end
                end)
            else
                header:SetMouseEnabled(false)
                header:SetHandler("OnMouseUp", nil)
            end
            controls.headers[column.key] = header
        end

        header:SetDimensions(column.width, 18)
        header:ClearAnchors()
        header:SetAnchor(TOPLEFT, controls.window, TOPLEFT, column.x, SOURCES_TO_FARM_HEADER_Y)
        header:SetText(column.label)
    end
end

function Greed:EnsureSourcesToFarmRows(rowCount, columnDefs)
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window then return end

    controls.rows = controls.rows or {}
    for index = 1, rowCount do
        local rowControl = controls.rows[index]
        if not rowControl then
            local row = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmRow" .. index, controls.window, CT_CONTROL)
            row:SetHidden(true)
            row:SetMouseEnabled(true)
            row:SetHandler("OnMouseWheel", function(_, delta)
                self:ScrollSourcesToFarm(delta)
            end)

            local bg = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmRow" .. index .. "Bg", row, CT_BACKDROP)
            bg:SetAnchorFill(row)
            SetBackdropStyle(bg, index % 2 == 0 and COLORS.rowAlt or COLORS.row, COLORS.mutedEdge)

            rowControl = {
                row = row,
                labels = {},
            }
            controls.rows[index] = rowControl
        end

        for _, column in ipairs(columnDefs or {}) do
            if not rowControl.labels[column.key] then
                local label = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmRow" .. index .. column.key, rowControl.row, CT_LABEL)
                label:SetFont("ZoFontGameSmall")
                label:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
                rowControl.labels[column.key] = label
            end
        end
    end
end

function Greed:LayoutSourcesToFarmResizeControls()
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window then return end

    if controls.resizeLeftGrip then
        controls.resizeLeftGrip:ClearAnchors()
        controls.resizeLeftGrip:SetAnchor(BOTTOMLEFT, controls.window, BOTTOMLEFT, 4, -4)
        controls.resizeLeftGrip:SetHidden(false)
        controls.resizeLeftGrip:SetMouseEnabled(true)
    end

    if controls.resizeRightGrip then
        controls.resizeRightGrip:ClearAnchors()
        controls.resizeRightGrip:SetAnchor(BOTTOMRIGHT, controls.window, BOTTOMRIGHT, -4, -4)
        controls.resizeRightGrip:SetHidden(false)
        controls.resizeRightGrip:SetMouseEnabled(true)
    end
end

function Greed:CreateSourcesToFarmResizeControls()
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window or controls.resizeLeftGrip then return end

    local window = controls.window
    local leftGrip = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmResizeLeftGrip", window, CT_LABEL)
    leftGrip:SetDimensions(SOURCES_TO_FARM_RESIZE_GRIP_SIZE, 28)
    leftGrip:SetText("")
    if AddResizeGripIcon then
        AddResizeGripIcon(leftGrip, "GreedSourcesToFarmResizeLeftGrip", "left")
    end
    CallControlMethod(leftGrip, "SetDrawLayer", DL_TEXT)
    CallControlMethod(leftGrip, "SetDrawTier", DT_HIGH)
    CallControlMethod(leftGrip, "SetDrawLevel", 240)
    leftGrip:SetMouseEnabled(true)
    leftGrip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartSourcesToFarmResize("left")
        end
    end)
    leftGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopSourcesToFarmResize()
        end
    end)

    local rightGrip = WINDOW_MANAGER:CreateControl("GreedSourcesToFarmResizeRightGrip", window, CT_LABEL)
    rightGrip:SetDimensions(SOURCES_TO_FARM_RESIZE_GRIP_SIZE, 28)
    rightGrip:SetText("")
    if AddResizeGripIcon then
        AddResizeGripIcon(rightGrip, "GreedSourcesToFarmResizeRightGrip", "right")
    end
    CallControlMethod(rightGrip, "SetDrawLayer", DL_TEXT)
    CallControlMethod(rightGrip, "SetDrawTier", DT_HIGH)
    CallControlMethod(rightGrip, "SetDrawLevel", 240)
    rightGrip:SetMouseEnabled(true)
    rightGrip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartSourcesToFarmResize("right")
        end
    end)
    rightGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopSourcesToFarmResize()
        end
    end)

    window:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self.sourcesToFarmResize then
            self:StopSourcesToFarmResize()
        end
    end)

    controls.resizeLeftGrip = leftGrip
    controls.resizeRightGrip = rightGrip
    self:LayoutSourcesToFarmResizeControls()
end

function Greed:StartSourcesToFarmResize(side)
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window or not GetUIMousePosition then return end

    local window = controls.window
    local mouseX, mouseY = GetUIMousePosition()
    self.sourcesToFarmResize = {
        side = side or "right",
        startMouseX = mouseX or 0,
        startMouseY = mouseY or 0,
        startWidth = GetControlDimension(window, "GetWidth", SOURCES_TO_FARM_DEFAULT_WIDTH),
        startHeight = GetControlDimension(window, "GetHeight", SOURCES_TO_FARM_DEFAULT_HEIGHT),
        startLeft = window:GetLeft() or 0,
        startTop = window:GetTop() or 0,
    }

    window:SetHandler("OnUpdate", function()
        self:UpdateSourcesToFarmResize()
    end)
end

function Greed:UpdateSourcesToFarmResize()
    local controls = self.sourcesToFarmControls
    local resize = self.sourcesToFarmResize
    if not controls or not controls.window or not resize or not GetUIMousePosition then return end

    local mouseX, mouseY = GetUIMousePosition()
    local deltaX = (mouseX or resize.startMouseX) - resize.startMouseX
    local deltaY = (mouseY or resize.startMouseY) - resize.startMouseY
    local minWidth, maxWidth, minHeight = self:GetSourcesToFarmSizeBounds()
    local maxHeight = self:GetSourcesToFarmCurrentContentMaxHeight()
    local nextWidth
    local nextLeft = resize.startLeft

    if resize.side == "left" then
        nextWidth = math.max(minWidth, math.min(maxWidth, resize.startWidth - deltaX))
        nextLeft = resize.startLeft + (resize.startWidth - nextWidth)
    else
        nextWidth = math.max(minWidth, math.min(maxWidth, resize.startWidth + deltaX))
    end

    local nextHeight = math.max(minHeight, math.min(maxHeight, resize.startHeight + deltaY))
    local screenWidth = GetControlDimension(GuiRoot, "GetWidth", 1920)
    local screenHeight = GetControlDimension(GuiRoot, "GetHeight", 1080)
    nextLeft = math.max(0, math.min(nextLeft, math.max(0, screenWidth - nextWidth)))
    local nextTop = math.max(0, math.min(resize.startTop, math.max(0, screenHeight - nextHeight)))

    controls.window:ClearAnchors()
    controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, nextLeft, nextTop)
    controls.window:SetDimensions(nextWidth, nextHeight)
    self:LayoutSourcesToFarmWindow()
    self:UpdateSourcesToFarmRows()
end

function Greed:StopSourcesToFarmResize()
    local controls = self.sourcesToFarmControls
    if controls and controls.window then
        controls.window:SetHandler("OnUpdate", nil)
    end

    self.sourcesToFarmResize = nil
    self:SaveSourcesToFarmWindowSize()
    self:LayoutSourcesToFarmWindow()
    self:UpdateSourcesToFarmRows()
end

function Greed:SaveSourcesToFarmWindowSize()
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window then return end

    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions.sourcesToFarm = self.savedVars.windowPositions.sourcesToFarm or {}
    self:SaveWindowPosition(controls.window, "sourcesToFarm")

    local width = GetControlDimension(controls.window, "GetWidth", SOURCES_TO_FARM_DEFAULT_WIDTH)
    local height = GetControlDimension(controls.window, "GetHeight", SOURCES_TO_FARM_DEFAULT_HEIGHT)
    local minWidth, maxWidth, minHeight = self:GetSourcesToFarmSizeBounds()
    local maxHeight = self:GetSourcesToFarmCurrentContentMaxHeight()
    self.savedVars.windowPositions.sourcesToFarm.width = math.max(minWidth, math.min(maxWidth, width))
    self.savedVars.windowPositions.sourcesToFarm.height = math.max(minHeight, math.min(maxHeight, height))
end

function Greed:ClampSourcesToFarmWindowHeightToContent()
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window then return end

    local window = controls.window
    local width = GetControlDimension(window, "GetWidth", SOURCES_TO_FARM_DEFAULT_WIDTH)
    local height = GetControlDimension(window, "GetHeight", SOURCES_TO_FARM_DEFAULT_HEIGHT)
    local _, _, minHeight = self:GetSourcesToFarmSizeBounds()
    local maxHeight = self:GetSourcesToFarmCurrentContentMaxHeight()
    local nextHeight = math.max(minHeight, math.min(maxHeight, height))
    if nextHeight == height then return end

    local left = window:GetLeft()
    local top = window:GetTop()
    local nextLeft
    local nextTop
    window:SetDimensions(width, nextHeight)
    if left and top then
        local screenWidth = GetControlDimension(GuiRoot, "GetWidth", 1920)
        local screenHeight = GetControlDimension(GuiRoot, "GetHeight", 1080)
        nextLeft = math.max(0, math.min(left, math.max(0, screenWidth - width)))
        nextTop = math.max(0, math.min(top, math.max(0, screenHeight - nextHeight)))
        window:ClearAnchors()
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, nextLeft, nextTop)
    end

    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions.sourcesToFarm = self.savedVars.windowPositions.sourcesToFarm or {}
    self.savedVars.windowPositions.sourcesToFarm.height = nextHeight
    if nextLeft and nextTop then
        self.savedVars.windowPositions.sourcesToFarm.x = nextLeft
        self.savedVars.windowPositions.sourcesToFarm.y = nextTop
    end
end

function Greed:LayoutSourcesToFarmWindow()
    local controls = self.sourcesToFarmControls
    if not controls or not controls.window then return end

    local window = controls.window
    local width = GetControlDimension(window, "GetWidth", SOURCES_TO_FARM_DEFAULT_WIDTH)
    local height = GetControlDimension(window, "GetHeight", SOURCES_TO_FARM_DEFAULT_HEIGHT)
    local columnDefs, contentWidth = BuildSourcesToFarmColumnDefs(width)
    local visibleRows = self:GetSourcesToFarmVisibleRowCount(height, #(controls.entries or {}))
    controls.columnDefs = columnDefs
    controls.visibleRows = visibleRows

    controls.titleBar:SetDimensions(width, 48)
    controls.title:SetDimensions(math.max(300, width - 180), 28)

    controls.refreshButton:ClearAnchors()
    controls.refreshButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -58, 12)
    controls.closeButton:ClearAnchors()
    controls.closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -16, 12)
    controls.countLabel:SetDimensions(width - 36, 20)

    self:EnsureSourcesToFarmHeaderControls(columnDefs)
    self:EnsureSourcesToFarmRows(visibleRows, columnDefs)

    for index, rowControl in ipairs(controls.rows or {}) do
        if index <= visibleRows then
            rowControl.row:SetDimensions(contentWidth, SOURCES_TO_FARM_ROW_HEIGHT)
            rowControl.row:ClearAnchors()
            rowControl.row:SetAnchor(TOPLEFT, window, TOPLEFT, SOURCES_TO_FARM_LEFT_INSET, SOURCES_TO_FARM_ROW_START_Y + ((index - 1) * SOURCES_TO_FARM_ROW_HEIGHT))

            for _, column in ipairs(columnDefs) do
                local label = rowControl.labels[column.key]
                if label then
                    label:SetDimensions(column.width, 22)
                    label:ClearAnchors()
                    label:SetAnchor(LEFT, rowControl.row, LEFT, column.x - SOURCES_TO_FARM_LEFT_INSET, 0)
                end
            end
        else
            rowControl.row:SetHidden(true)
            rowControl.row:SetMouseEnabled(false)
        end
    end

    controls.track:SetDimensions(12, visibleRows * SOURCES_TO_FARM_ROW_HEIGHT)
    controls.track:ClearAnchors()
    controls.track:SetAnchor(TOPRIGHT, window, TOPRIGHT, -SOURCES_TO_FARM_SCROLLBAR_RIGHT_INSET, SOURCES_TO_FARM_ROW_START_Y)

    self:LayoutSourcesToFarmResizeControls()
end

function Greed:ShowSourcesToFarmWindow()
    self:CreateSourcesToFarmWindow()
    self:RefreshSourcesToFarmWindow()
    self.sourcesToFarmControls.window:SetHidden(false)
end

function Greed:HideSourcesToFarmWindow()
    if self.sourcesToFarmControls and self.sourcesToFarmControls.window then
        self.sourcesToFarmControls.window:SetHidden(true)
    end
end

function Greed:ToggleSourcesToFarmWindow()
    if self.sourcesToFarmControls and self.sourcesToFarmControls.window and not self.sourcesToFarmControls.window:IsHidden() then
        self:HideSourcesToFarmWindow()
        return
    end

    self:ShowSourcesToFarmWindow()
end

function Greed:ScrollSourcesToFarm(delta)
    local controls = self.sourcesToFarmControls
    if not controls then return end

    local visible = controls.visibleRows or self:GetSourcesToFarmVisibleRowCount()
    local maxOffset = math.max(0, #(controls.entries or {}) - visible)
    local nextOffset = (controls.scrollOffset or 0) - (delta or 0)
    controls.scrollOffset = math.max(0, math.min(maxOffset, nextOffset))
    self:UpdateSourcesToFarmRows()
end

function Greed:RefreshSourcesToFarmWindow()
    local controls = self.sourcesToFarmControls
    if not controls then return end

    controls.entries = self:BuildSourcesToFarmRows()
    self:ClampSourcesToFarmWindowHeightToContent()
    self:LayoutSourcesToFarmWindow()

    local visible = controls.visibleRows or self:GetSourcesToFarmVisibleRowCount()
    local maxOffset = math.max(0, #(controls.entries or {}) - visible)
    controls.scrollOffset = math.max(0, math.min(maxOffset, controls.scrollOffset or 0))

    local pageName = self:GetCurrentPageName()
    controls.countLabel:SetText(T("%d source rows on %s.", #(controls.entries or {}), pageName or DEFAULT_PAGE_NAME))
    self:UpdateSourcesToFarmRows()
end

function Greed:UpdateSourcesToFarmRows()
    local controls = self.sourcesToFarmControls
    if not controls then return end

    local entries = controls.entries or {}
    local offset = controls.scrollOffset or 0
    local visible = controls.visibleRows or self:GetSourcesToFarmVisibleRowCount()

    for index, rowControl in ipairs(controls.rows or {}) do
        local entry = index <= visible and entries[offset + index] or nil
        rowControl.row:SetHidden(entry == nil)
        rowControl.row:SetMouseEnabled(entry ~= nil)
        if entry then
            rowControl.labels.source:SetText(entry.source or "")
            rowControl.labels.sourceType:SetText(entry.sourceTypeText or "")
            rowControl.labels.difficulty:SetText(entry.difficulty or "")
            rowControl.labels.setName:SetText(entry.setName or "")
            rowControl.labels.items:SetText(entry.itemsText or "")
        end
    end

    self:UpdateSourcesToFarmScrollbar()
end

function Greed:UpdateSourcesToFarmScrollbar()
    local controls = self.sourcesToFarmControls
    if not controls or not controls.track or not controls.thumb then return end

    local total = #(controls.entries or {})
    local visible = controls.visibleRows or self:GetSourcesToFarmVisibleRowCount()
    if total <= visible then
        controls.track:SetHidden(true)
        controls.thumb:SetHidden(true)
        self:LayoutSourcesToFarmResizeControls()
        return
    end

    controls.track:SetHidden(false)
    controls.thumb:SetHidden(false)
    self:LayoutSourcesToFarmResizeControls()

    local trackHeight = GetControlDimension(controls.track, "GetHeight", visible * SOURCES_TO_FARM_ROW_HEIGHT)
    local thumbHeight = math.max(34, math.floor(trackHeight * visible / total))
    local available = math.max(0, trackHeight - thumbHeight - 4)
    local maxOffset = math.max(1, total - visible)
    local thumbY = 2 + math.floor(((controls.scrollOffset or 0) / maxOffset) * available)

    controls.thumb:SetDimensions(8, thumbHeight)
    controls.thumb:ClearAnchors()
    controls.thumb:SetAnchor(TOP, controls.track, TOP, 0, thumbY)
end

function Greed:SetSourcesToFarmSort(columnKey)
    if columnKey == "items" then return end

    local controls = self.sourcesToFarmControls
    if not controls then return end

    if controls.sortKey == columnKey then
        controls.sortAscending = controls.sortAscending == false
    else
        controls.sortKey = columnKey
        controls.sortAscending = true
    end

    self:SortSourcesToFarmEntries(controls.entries or {})
    controls.scrollOffset = 0
    self:UpdateSourcesToFarmRows()
end

function Greed:SortSourcesToFarmEntries(entries)
    local controls = self.sourcesToFarmControls
    local sortKey = (controls and controls.sortKey) or "source"
    local ascending = not controls or controls.sortAscending ~= false
    local tieBreakers = { "source", "difficulty", "setName" }

    table.sort(entries or {}, function(a, b)
        local aSort = a and a.sortValues and a.sortValues[sortKey] or ""
        local bSort = b and b.sortValues and b.sortValues[sortKey] or ""
        if aSort ~= bSort then
            if ascending then
                return aSort < bSort
            end
            return aSort > bSort
        end

        for _, key in ipairs(tieBreakers) do
            local left = a and a.sortValues and a.sortValues[key] or ""
            local right = b and b.sortValues and b.sortValues[key] or ""
            if left ~= right then
                return left < right
            end
        end

        return (a and a.stableIndex or 0) < (b and b.stableIndex or 0)
    end)
end

function Greed:BuildSourcesToFarmRows()
    local grouped = {}
    local groupOrder = {}
    local rows = self.displayFavorites or self:BuildDisplayFavorites()

    for _, setData in ipairs(rows or {}) do
        if setData and self:DisplaySetHasTrackedPieces(setData) then
            local itemLabels = self:GetTrackedItemLabelsForFarmList(setData)
            if #itemLabels > 0 then
                local sourceName, difficulty = self:GetFarmSourceInfo(setData)
                local sourceType = self:GetFarmSourceType(setData)
                local sourceTypeText = self:GetFarmSourceTypeDisplayText(sourceType)
                local baseName = setData.baseName or setData.name or T("Unknown Set")
                local setName = setData.isPerfectedRow and self:GetPerfectedDisplayName(baseName, setData.perfectedSetId or setData.setId) or baseName
                local key = table.concat({ sourceType or "", sourceName, difficulty, setName }, "|")

                if not grouped[key] then
                    table.insert(groupOrder, key)
                    grouped[key] = {
                        source = sourceName,
                        sourceType = sourceType,
                        sourceTypeText = sourceTypeText,
                        difficulty = difficulty,
                        setName = setName,
                        itemLabels = {},
                        itemSeen = {},
                        stableIndex = #groupOrder,
                    }
                end

                for _, label in ipairs(itemLabels) do
                    if not grouped[key].itemSeen[label] then
                        grouped[key].itemSeen[label] = true
                        table.insert(grouped[key].itemLabels, label)
                    end
                end
            end
        end
    end

    local entries = {}
    for _, key in ipairs(groupOrder) do
        local entry = grouped[key]
        entry.itemsText = table.concat(entry.itemLabels or {}, ", ")
        entry.sortValues = {
            source = CleanSourcesToFarmSortText(entry.source),
            sourceType = CleanSourcesToFarmSortText(entry.sourceTypeText),
            difficulty = CleanSourcesToFarmSortText(entry.difficulty),
            setName = CleanSourcesToFarmSortText(entry.setName),
        }
        table.insert(entries, entry)
    end

    self:SortSourcesToFarmEntries(entries)

    return entries
end

function Greed:GetFarmSourceType(setData)
    if type(setData and setData.sourceType) == "string" then
        if setData.sourceType == SOURCES_TO_FARM_SOURCE_TYPE_TRIAL or setData.sourceType == SOURCES_TO_FARM_SOURCE_TYPE_DUNGEON then
            return setData.sourceType
        end
    end

    local setId = tonumber(setData and (setData.normalSetId or setData.setId))
    local setType
    if setId then
        local setInfo = libSets.GetSetInfo(setId, true, self:GetClientLanguage())
        setType = setInfo and setInfo.setType or libSets.GetSetType(setId)
    end

    if setType == LIBSETS_SETTYPE_TRIAL then
        return SOURCES_TO_FARM_SOURCE_TYPE_TRIAL
    end

    if setType == LIBSETS_SETTYPE_DUNGEON or setType == LIBSETS_SETTYPE_MONSTER or (setData and setData.isMonsterSet == true) then
        return SOURCES_TO_FARM_SOURCE_TYPE_DUNGEON
    end

    return nil
end

function Greed:GetFarmSourceTypeDisplayText(sourceType)
    if sourceType == SOURCES_TO_FARM_SOURCE_TYPE_TRIAL then
        return T("Trial")
    end

    if sourceType == SOURCES_TO_FARM_SOURCE_TYPE_DUNGEON then
        return T("Dungeon")
    end

    return ""
end

function Greed:GetFarmSourceInfo(setData)
    local source = tostring(setData and setData.source or "")
    local sourceLower = string.lower(source or "")
    local difficulty = ((setData and setData.isPerfectedRow) or sourceLower:find("veteran", 1, true)) and T("Veteran") or T("Normal")
    local sourceName = source

    sourceName = sourceName:gsub("^%s*Trial%s*%-%s*Veteran%s+", "")
    sourceName = sourceName:gsub("^%s*Dungeon%s*%-%s*Veteran%s+", "")
    sourceName = sourceName:gsub("^%s*Arena%s*%-%s*Veteran%s+", "")
    sourceName = sourceName:gsub("^%s*Trial%s*%-%s*", "")
    sourceName = sourceName:gsub("^%s*Dungeon%s*%-%s*", "")
    sourceName = sourceName:gsub("^%s*Arena%s*%-%s*", "")
    sourceName = sourceName:gsub("^%s*Overland%s*%-%s*", "")
    sourceName = sourceName:gsub("^%s+", ""):gsub("%s+$", "")

    if sourceName == "" then
        sourceName = source ~= "" and source or T("Unknown")
    end

    return sourceName, difficulty
end

function Greed:GetMonsterWeightSuffix(setData, slotKey)
    if not setData then return "" end

    local weight = self:GetMonsterWeightPreferenceText(setData)
    if type(weight) ~= "string" or weight == "" or string.lower(weight) == "any" then
        return ""
    end

    return " (" .. weight .. ")"
end

function Greed:GetTrackedItemLabelsForFarmList(setData)
    local labels = {}

    for _, slot in ipairs(GreedData.armorSlots or {}) do
        if setData.pieces and setData.pieces[slot.key] then
            local isMonsterSlot = slot.key == "head" or slot.key == "shoulders"
            if setData.isMonsterSet ~= true or isMonsterSlot then
                local label = FARM_SLOT_LABELS[slot.key] or slot.label
                if setData.isMonsterSet == true then
                    label = label .. self:GetMonsterWeightSuffix(setData, slot.key)
                end
                table.insert(labels, label)
            end
        end
    end

    for _, weapon in ipairs(WEAPON_ITEMS) do
        if setData.weapons and setData.weapons[weapon.key] then
            table.insert(labels, FARM_WEAPON_LABELS[weapon.key] or weapon.label)
        end
    end

    return labels
end
