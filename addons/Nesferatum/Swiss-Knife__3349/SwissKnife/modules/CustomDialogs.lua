-- Local instances of Global tables
local SK = SwissKnife
local SKA = SK.Automation
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common
local SKDE = SK.Data.equipmentData
local SKDI = SK.Data.itemsData
local SKDA = SK.Data.abilities
local TRUE, FALSE = SK.TRUE, SK.FALSE
local WM, EM, SM = WINDOW_MANAGER, EVENT_MANAGER, SCENE_MANAGER

local isFirstLoadUpdate = true

-- ----------------------------------------------------
-- Base dialogs
-- ----------------------------------------------------
local function InitInfoDialogue()
    ZO_Dialogs_RegisterCustomDialog("SK_INFO_DIALOGUE",
{
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = SI_SK_DIALOG_INFO_HEADER,
        },
        mainText =
        {
            text = SI_SK_DIALOG_INFO_TEXT,
        },
        buttons =
        {
            {
                text = SI_SK_DIALOG_CLOSE,
                callback = function(dialog)
                    ZO_Dialogs_ReleaseDialogOnButtonPress("SK_INFO_DIALOGUE")
                end
            },
        },
    })

end

local function InputLineDialogSetup(dialog, data)
    local control = GetControl(dialog, "InputEdit")
    if data and data.inputLine then
        control:SetText(zo_strformat("<<1>>", data.inputLine))
    else
        control:SetText("")
    end
    control:TakeFocus()
end

local function InitInputLineDialogue(self, data)
    ZO_Dialogs_RegisterCustomDialog(data.name,
    {
        customControl = self,
        setup = InputLineDialogSetup,

        title =
        {
            text = SI_SK_DIALOG_INFO_HEADER,
        },

        buttons =
        {
            [1] =
            {
                control = GetControl(self, "Apply"),
                text = SI_SK_DIALOG_SAVE,
                callback = function(dialog)
                    local inputLine = GetControl(dialog, "InputEdit"):GetText()
                    if inputLine ~= "" then
                        data.callback(inputLine)
                        ZO_Dialogs_ReleaseDialog(data.name)
                        if not IsGameCameraUIModeActive() then SetGameCameraUIMode(true) end
                    end
                end,
            },
            [2] =
            {
                control = GetControl(self, "Cancel"),
                text = SI_SK_DIALOG_CANCEL,
                callback = function(dialog)
                    ZO_Dialogs_ReleaseDialogOnButtonPress(data.name)
                    if not IsGameCameraUIModeActive() then SetGameCameraUIMode(true) end
                end
            }
        }
    })
    local requiredFields = ZO_RequiredTextFields:New()
    requiredFields:AddButton(GetControl(self, "Apply"))
    requiredFields:AddTextField(GetControl(self, "InputEdit"))
end

-- ----------------------------------------------------
-- UD_SortFilterList
-- ----------------------------------------------------
local SK_BASE_DATA_TYPE = 1

UD_SortFilterList = ZO_SortFilterList:Subclass()
function UD_SortFilterList:New(control, ...)
	local list = ZO_SortFilterList.New(self, control, ...)
    return list
end

function UD_SortFilterList:Initialize(control, dialogue, emptyText,
                                      sortHeaderKey, rowTemplateName,
                                      sortKeys, rowHeight, filters)
    if rowHeight ~= nil then self.rowHeight = rowHeight else self.rowHeight = 32 end
	ZO_SortFilterList.Initialize(self, control)
    self.defaults = {}
    self.items = {}
    self.masterList = {}
    self.dialogue = dialogue
    self.sortHeaderKey = sortHeaderKey
    self.sortKeys = sortKeys
    self.sortHeaderGroup:SelectHeaderByKey(self.sortHeaderKey)
    local headersName = control:GetNamedChild("HeadersName")
    ZO_SortHeader_OnMouseExit(headersName)
    self:SetEmptyText(GetString(emptyText))
	ZO_ScrollList_AddDataType(self.list, SK_BASE_DATA_TYPE, rowTemplateName, self.rowHeight,
            function(control, data) self:SetupRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_TallListHighlight")
	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(
            listEntry1.data, listEntry2.data, self.currentSortKey, self.sortKeys, self.currentSortOrder) end
    self.filtersControl = control:GetNamedChild("Filters")
    self.filters = {}
    local nextRowsFilters = {}
    local filtersRowWidth, maxFiltersRowWidth, filtersRowsCount, previousRowControl = -3, 0, 1, self.filtersControl
    if self.filtersControl ~= nil and filters ~= nil then
        self.filterHeight = 32
        local anchorControl = self.filtersControl
        for index, data in pairs(filters) do
            local name, choices, brackets = data.name, data.choices, data.brackets
            self.filters[name] = {}
            self.filters[name].default = choices[1]
            self.filters[name].brackets = brackets
            self.filters[name].control = WM:CreateControlFromVirtual("$(parent)"..name, self.filtersControl, "SK_ComboBox")
            self.filters[name].filterComboBox = ZO_ComboBox_ObjectFromContainer(self.filters[name].control)
            self.filters[name].filterComboBox:SetDropdownFont("ZoFontEditChat")
            self.filters[name].filterComboBox:SetSpacing(4)
            local maxCharsLen = 0
            for key, item in pairs(choices) do
                local entry = ZO_ComboBox:CreateItemEntry(item, function()
                    self:RefreshSubFilters(data.sub)
                    self:RefreshFilters()
                end)
                entry.index = key
                self.filters[name].filterComboBox:AddItem(entry)
                if item == self.filters[name].default then
                    self.filters[name].filterComboBox:SetSelectedItemText(item)
                elseif string.len(item) > maxCharsLen then
                    maxCharsLen = string.len(item)
                end
            end
            local widthFilter = math.min(math.max(9 * maxCharsLen + 16, data.minWidth), data.maxWidth)
            self.filters[name].control:SetDimensions(widthFilter, self.filterHeight)
            local a1, a2, o1, o2 = BOTTOMRIGHT, BOTTOMLEFT, -3, 0
            if index == 1 then
                o1 = 0
                a2 = BOTTOMRIGHT
                previousRowControl = self.filters[name].control
            end
            filtersRowWidth = filtersRowWidth + widthFilter + 3
            if filtersRowWidth > SK.MAIN_DIALOGUE_DATA.DEFAULT.FILTER_MAX_WIDTH then
                anchorControl = previousRowControl
                previousRowControl = self.filters[name].control
                maxFiltersRowWidth = math.max(maxFiltersRowWidth, filtersRowWidth - widthFilter - 3)
                filtersRowWidth = widthFilter - 3
                filtersRowsCount = filtersRowsCount + 1
                table.insert(nextRowsFilters, self.filters[name].control)
                a1, a2, o1, o2 = BOTTOMRIGHT, TOPRIGHT, 0, -3
            end
            self.filters[name].control:SetAnchor(a1, anchorControl, a2, o1, o2)
            anchorControl = self.filters[name].control
            if #nextRowsFilters > 0 then table.insert(nextRowsFilters, self.filters[name].control) end
        end
        local heightDelta = 12
        local filtersControlHeight = (self.filterHeight + 3) * filtersRowsCount - 3
        local filtersControlExpand = self.filtersControl:GetNamedChild("Expand")
        local filtersControlCollapse = self.filtersControl:GetNamedChild("Collapse")
        local filterHeight = self.filterHeight
        local filtersControl = self.filtersControl
        filtersControlExpand:SetHidden(true)
        filtersControlCollapse:SetHidden(true)
        if filtersRowsCount > 1 then
            filtersControlCollapse:SetHidden(false)
            filtersControl:SetDimensions(maxFiltersRowWidth, filtersControlHeight + heightDelta)
            filtersControlExpand:SetHandler("OnMouseDown", function(self)
                ZO_Tooltips_HideTextTooltip()
                filtersControlExpand:SetHidden(true)
                filtersControlCollapse:SetHidden(false)
                filtersControl:SetDimensions(maxFiltersRowWidth, filtersControlHeight + heightDelta)
                for _, control in ipairs(nextRowsFilters) do control:SetHidden(false) end
            end)
            filtersControlCollapse:SetHandler("OnMouseDown", function(self)
                ZO_Tooltips_HideTextTooltip()
                filtersControlExpand:SetHidden(false)
                filtersControlCollapse:SetHidden(true)
                filtersControl:SetDimensions(maxFiltersRowWidth, filterHeight + 1)
                for _, control in ipairs(nextRowsFilters) do control:SetHidden(true) end
            end)
            filtersControlExpand:SetHandler("OnMouseEnter", function(self)
                InitializeTooltip(InformationTooltip, self)
                SetTooltipText(InformationTooltip, GetString(SI_SK_DIALOG_EXPAND))
            end)
            filtersControlExpand:SetHandler("OnMouseExit", function(self)
                ZO_Tooltips_HideTextTooltip()
            end)
            filtersControlCollapse:SetHandler("OnMouseEnter", function(self)
                InitializeTooltip(InformationTooltip, self)
                SetTooltipText(InformationTooltip, GetString(SI_SK_DIALOG_COLLAPSE))
            end)
            filtersControlCollapse:SetHandler("OnMouseExit", function(self)
                ZO_Tooltips_HideTextTooltip()
            end)
        else
            filtersControl:SetDimensions(maxFiltersRowWidth, filtersControlHeight)
        end
    end
    self.searchProcessor = ZO_StringSearch:New()
    self.searchBox = control:GetNamedChild("SearchBox")
    if self.searchBox then
        self.searchClean = control:GetNamedChild("SearchClean")
        self.searchPlaceholder = control:GetNamedChild("SearchPlaceholder")
        self.searchBox:SetHandler("OnTextChanged", function() self:RefreshFilters() end)
        self.searchProcessor:AddProcessor(SK_BASE_DATA_TYPE,
            function(stringSearch, data, searchTerm, cache)
                return self:ProcessItemEntry(stringSearch, data, searchTerm, cache)
            end
        )
    end
    self.countControl = control:GetNamedChild("Counter")
    if self.countControl then
        local r, g, b = SK.COLOR.LIGHT_BLUE:UnpackRGB()
        self.countControl:SetColor(r, g, b)
    end
	self:RefreshData()
end

function UD_SortFilterList:BuildMasterList()
    self.masterList = {}
	for k, v in pairs(self.items) do
		local data = v
		table.insert(self.masterList, data)
	end
end

function UD_SortFilterList:ProcessItemEntry(stringSearch, data, searchTerm, cache )
    local isMatch = false
    if data == nil then
        SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKW, SI_SK_AUT_FILTER_ERROR)
    else
        for sortKey, _ in pairs(self.sortKeys) do
            if data[sortKey] then
                isMatch = zo_plainstrfind(data[sortKey]:lower(), searchTerm)
            --else
            --    d("filtering debug: sortKey, searchTerm")
            --    d(sortKey)
            --    d(searchTerm)
            end
            if isMatch then break end
        end
    end
    return isMatch
end

function UD_SortFilterList:FilterMatch(data)
    if self.searchBox == nil then return true end
    local searchTerm = self.searchBox:GetText()
    local filterTerm = ""
    if self.filtersControl ~= nil and self.filters ~= nil then
        for _, filterData in pairs(self.filters) do
            local filterText = filterData.control.m_comboBox.m_selectedItemText:GetText()
            if filterText ~= nil and filterData.default ~= filterText then
                if filterData.brackets ~= nil then filterText = "["..filterText.."] " end
                if filterTerm ~= "" then filterTerm = filterTerm.." " end
                filterTerm = filterTerm..filterText
            end
        end
    end
    if searchTerm == "" then
        self.searchClean:SetHidden(true)
        self.searchPlaceholder:SetHidden(false)
    else
        self.searchClean:SetHidden(false)
        self.searchPlaceholder:SetHidden(true)
    end
    if searchTerm ~= "" or filterTerm ~= "" then
        searchTerm = searchTerm.." "..filterTerm
    end
    return (searchTerm == "" and filterTerm == "") or self.searchProcessor:IsMatch(searchTerm, data)
end

function UD_SortFilterList:RefreshSubFilters(subName)
    if self.filters ~= nil and subName ~= nil then
        for filterName, filterData in pairs(self.filters) do
            if filterName == subName then filterData.filterComboBox:SetSelectedItemText(filterData.default) end
        end
    end
end

function UD_SortFilterList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)
	for _, data in ipairs(self.masterList) do
        if self:FilterMatch(data) then
            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(SK_BASE_DATA_TYPE, data))
        end
	end
    if self.countControl then
        if (#scrollData ~= #self.masterList) then
            self.countControl:SetText(
                "|t20:20:SwissKnife/textures/gui/abacus.dds|t"..string.format(" %d / %d",
                    #scrollData, #self.masterList
                )
            )
        else
            self.countControl:SetText(
                "|t20:20:SwissKnife/textures/gui/abacus.dds|t"..string.format(" %d", #self.masterList)
            )
        end
    end
end

function UD_SortFilterList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

-- ----------------------------------------------------
-- UnwantedSetsList UnwantedItemsList SetsItemsList
-- ----------------------------------------------------
UnwantedSetsList = UD_SortFilterList:Subclass()
SetsItemsList = UD_SortFilterList:Subclass()
UnwantedItemsList = UD_SortFilterList:Subclass()
NotBindItemsList = UD_SortFilterList:Subclass()
WatchedAbilitiesList = UD_SortFilterList:Subclass()
TrackedAbilitiesList = UD_SortFilterList:Subclass()

function UnwantedSetsList:SetupRow(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        SKH.onRowMouseToggle(self.dialogue.setsList, rowControl, {"DelButton", "EditButton"}, true)
    end

    local function onRowMouseExit(rowControl)
        SKH.onRowMouseToggle(self.dialogue.setsList, rowControl, {"DelButton", "EditButton"}, false)
    end

    local function onSetNameMouseEnter(setNameControl)
        SKH.unwantedTooltip(setNameControl)
        onRowMouseEnter(setNameControl:GetParent())
    end

    local function onSetNameMouseExit(setNameControl)
        ClearTooltip(InformationTooltip)
        onRowMouseExit(setNameControl:GetParent())
    end

    local function onDeleteButtonMouseEnter(deleteButtonControl)
        ZO_Tooltips_ShowTextTooltip(deleteButtonControl, TOP, GetString(SI_SK_AUT_UNWANTED_LIST_DELETE_BUTTON))
        onRowMouseEnter(deleteButtonControl:GetParent())
    end

    local function onDeleteButtonMouseExit(deleteButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(deleteButtonControl:GetParent())
    end

    local function onEditButtonMouseEnter(editButtonControl)
        ZO_Tooltips_ShowTextTooltip(editButtonControl, TOP, GetString(SI_SK_AUT_UNWANTED_LIST_EDIT_BUTTON))
        onRowMouseEnter(editButtonControl:GetParent())
    end

    local function onEditButtonMouseExit(editButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(editButtonControl:GetParent())
    end

    rowControl.data = rowData

    local deconstructControl = rowControl:GetNamedChild("Deconstruct")
    if rowData.setQuality and rowData.deconstructQuality and rowData.deconstructQuality > rowData.setQuality then
        deconstructControl:SetText(SK.QUALITY_MAP[rowData.deconstructQuality]:Colorize(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_DECONSTRUCT_QUALITY_MARK)))
        deconstructControl:SetHidden(false)
        deconstructControl:SetHandler("OnMouseEnter", function(self)
            local text = SK.COLOR.LIGHT_YELLOW:Colorize(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_EQUIPMENT_LABEL)) ..
                "\n" .. GetString(SI_SK_AUT_UNWANTED_EDIT_SET_DECONSTRUCT_QUALITY_TOOLTIP)
            ZO_Tooltips_ShowTextTooltip(deconstructControl, TOP, text)
        end)
        deconstructControl:SetHandler("OnMouseExit", function(self)
            ZO_Tooltips_HideTextTooltip()
        end)
    else
        deconstructControl:SetHidden(true)
    end

    local deconstructJewelryControl = rowControl:GetNamedChild("DeconstructJewelry")
    if rowData.junkQualityJewelry and rowData.deconstructQualityJewelry and rowData.deconstructQualityJewelry > rowData.junkQualityJewelry then
        deconstructJewelryControl:SetText(SK.QUALITY_MAP[rowData.deconstructQualityJewelry]:Colorize(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_DECONSTRUCT_QUALITY_MARK)))
        deconstructJewelryControl:SetHidden(false)
        deconstructJewelryControl:SetHandler("OnMouseEnter", function(self)
            local text = SK.COLOR.LIGHT_YELLOW:Colorize(GetString(SI_SK_AUT_UNWANTED_EDIT_SET_JUNK_JEWELRY_LABEL)) ..
                "\n" .. GetString(SI_SK_AUT_UNWANTED_EDIT_SET_DECONSTRUCT_QUALITY_TOOLTIP)
            ZO_Tooltips_ShowTextTooltip(deconstructJewelryControl, TOP, text)
        end)
        deconstructJewelryControl:SetHandler("OnMouseExit", function(self)
            ZO_Tooltips_HideTextTooltip()
        end)
    else
        deconstructJewelryControl:SetHidden(true)
    end

    local setNameControl = rowControl:GetNamedChild("SetName")
    setNameControl:SetHandler("OnMouseEnter", onSetNameMouseEnter)
    setNameControl:SetHandler("OnMouseExit", onSetNameMouseExit)
    setNameControl:SetHandler("OnMouseUp", SKH.onItemNameMouseUp)
    if rowData.setQuality then
        setNameControl:SetText(SK.QUALITY_MAP[rowData.setQuality]:Colorize(rowData.setName))
    else
        setNameControl:SetText(rowData.setName)
    end
    setNameControl.setName = rowData.setName
    setNameControl.itemLink = rowData.itemLink
    setNameControl.setQuality = rowData.setQuality
    setNameControl.deconstructQuality = rowData.deconstructQuality
    setNameControl.junkQualityJewelry = rowData.junkQualityJewelry
    setNameControl.deconstructQualityJewelry = rowData.deconstructQualityJewelry

    local editButtonControl = rowControl:GetNamedChild("EditButton")
    editButtonControl:SetHandler("OnMouseEnter", onEditButtonMouseEnter)
    editButtonControl:SetHandler("OnMouseExit", onEditButtonMouseExit)
    editButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKEUS:Open(rowControl.data.itemLink)
    end)

    local delButtonControl = rowControl:GetNamedChild("DelButton")
    delButtonControl:SetHandler("OnMouseEnter", onDeleteButtonMouseEnter)
    delButtonControl:SetHandler("OnMouseExit", onDeleteButtonMouseExit)
    delButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKA.removeSetFromPermanentUnwanted(rowControl.data.itemLink)
    end)

    rowControl:SetHandler("OnMouseExit", onRowMouseExit)
    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function SetsItemsList:SetupRow(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        SKH.onRowMouseToggle(self.dialogue.setsItemsList, rowControl, {}, true)
    end

    local function onRowMouseExit(rowControl)
        SKH.onRowMouseToggle(self.dialogue.setsItemsList, rowControl, {}, false)
    end

    local function onBagIconMouseEnter(bagIconControl)
        ZO_Tooltips_ShowTextTooltip(bagIconControl, TOP, rowData.bagName)
        onRowMouseEnter(bagIconControl:GetParent())
    end

    local function onBagIconMouseExit(bagIconControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(bagIconControl:GetParent())
    end

    local function onItemIconMouseEnter(itemIconControl)
        ZO_Tooltips_ShowTextTooltip(itemIconControl, TOP, rowData.itemTypeName)
        onRowMouseEnter(itemIconControl:GetParent())
    end

    local function onItemIconMouseExit(itemIconControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(itemIconControl:GetParent())
    end

    local function onItemNameMouseEnter(itemNameControl)
        InitializeTooltip(ItemTooltip, itemNameControl, TOPRIGHT, -24, 0, TOPLEFT)
        ItemTooltip:SetLink(itemNameControl.itemLink)
        onRowMouseEnter(itemNameControl:GetParent())
    end

    local function onItemNameMouseExit(itemNameControl)
        ClearTooltip(ItemTooltip)
        onRowMouseExit(itemNameControl:GetParent())
    end

    local function onMouseEnter(control)
        onRowMouseEnter(control:GetParent())
    end

    local function onMouseExit(control)
        onRowMouseExit(control:GetParent())
    end

    rowControl.data = rowData

    local itemIconControl = rowControl:GetNamedChild("ItemIcon")
    itemIconControl:SetHandler("OnMouseEnter", onItemIconMouseEnter)
    itemIconControl:SetHandler("OnMouseExit", onItemIconMouseExit)
    itemIconControl:SetTexture(rowData.itemIcon)

    local newTextControl = rowControl:GetNamedChild("ItemType")
    newTextControl:SetText(rowData.armorType)
    newTextControl:SetFont(SK.savedVars.trackSetsItemsFont)

    local itemNameControl = rowControl:GetNamedChild("ItemName")
    itemNameControl:SetHandler("OnMouseEnter", onItemNameMouseEnter)
    itemNameControl:SetHandler("OnMouseExit", onItemNameMouseExit)
    itemNameControl:SetHandler("OnMouseUp", SKH.onItemNameMouseUp)
    itemNameControl.itemLink = rowData.itemLink
    itemNameControl:SetText(rowData.itemName)
    itemNameControl:SetFont(SK.savedVars.trackSetsItemsFont)

    local itemTraitControl = rowControl:GetNamedChild("ItemTrait")
    itemTraitControl:SetHandler("OnMouseEnter", onMouseEnter)
    itemTraitControl:SetHandler("OnMouseExit", onMouseExit)
    itemTraitControl:SetText(rowData.trait)
    itemTraitControl:SetFont(SK.savedVars.trackSetsItemsFont)

    local bagIconControl = rowControl:GetNamedChild("BagIcon")
    bagIconControl:SetHandler("OnMouseEnter", onBagIconMouseEnter)
    bagIconControl:SetHandler("OnMouseExit", onBagIconMouseExit)
    bagIconControl:SetTexture(rowData.bagIcon)

    local ownerNameControl = rowControl:GetNamedChild("OwnerName")
    ownerNameControl:SetHandler("OnMouseEnter", onMouseEnter)
    ownerNameControl:SetHandler("OnMouseExit", onMouseExit)
    ownerNameControl:SetText(rowData.ownerName)
    ownerNameControl:SetFont(SK.savedVars.trackSetsItemsFont)

    local accNameControl = rowControl:GetNamedChild("AccName")
    accNameControl:SetHandler("OnMouseEnter", onMouseEnter)
    accNameControl:SetHandler("OnMouseExit", onMouseExit)
    accNameControl:SetText(rowData.accName)
    accNameControl:SetFont(SK.savedVars.trackSetsItemsFont)

    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function UnwantedItemsList:SetupRow(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        SKH.onRowMouseToggle(self.dialogue.itemsList, rowControl, {"DelButton"}, true)
    end

    local function onRowMouseExit(rowControl)
        SKH.onRowMouseToggle(self.dialogue.itemsList, rowControl, {"DelButton"}, false)
    end

    local function onItemNameMouseEnter(itemNameControl)
        InitializeTooltip(ItemTooltip, itemNameControl, TOPRIGHT, -40, 0, TOPLEFT)
        ItemTooltip:SetLink(itemNameControl.itemLink)
        onRowMouseEnter(itemNameControl:GetParent())
    end

    local function onItemNameMouseExit(itemNameControl)
        ClearTooltip(ItemTooltip)
        onRowMouseExit(itemNameControl:GetParent())
    end

    local function onDeleteButtonMouseEnter(deleteButtonControl)
        ZO_Tooltips_ShowTextTooltip(deleteButtonControl, TOP, GetString(SI_SK_AUT_UNWANTED_LIST_DELETE_BUTTON))
        onRowMouseEnter(deleteButtonControl:GetParent())
    end

    local function onDeleteButtonMouseExit(deleteButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(deleteButtonControl:GetParent())
    end

    rowControl.data = rowData

    local itemIconControl = rowControl:GetNamedChild("ItemIcon")
    itemIconControl:SetTexture(rowData.itemIcon)

    local itemNameControl = rowControl:GetNamedChild("ItemName")
    itemNameControl:SetHandler("OnMouseEnter", onItemNameMouseEnter)
    itemNameControl:SetHandler("OnMouseExit", onItemNameMouseExit)
    itemNameControl.itemLink = rowData.itemLink
    itemNameControl:SetText(rowData.itemName)

    local actionNameControl = rowControl:GetNamedChild("ActionName")
    actionNameControl:SetText(SKDC.UNWANTED_ACTIONS_NAMES[rowData.action])

    local delButtonControl = rowControl:GetNamedChild("DelButton")
    delButtonControl:SetHandler("OnMouseEnter", onDeleteButtonMouseEnter)
    delButtonControl:SetHandler("OnMouseExit", onDeleteButtonMouseExit)
    delButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKA.removeItemFromPermanentUnwanted(rowControl.data.itemLink)
    end)

    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function NotBindItemsList:SetupRow(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        SKH.onRowMouseToggle(self.dialogue.notBindItemsList, rowControl, {"DelButton"}, true)
    end

    local function onRowMouseExit(rowControl)
        SKH.onRowMouseToggle(self.dialogue.notBindItemsList, rowControl, {"DelButton"}, false)
    end

    local function onItemNameMouseEnter(itemNameControl)
        InitializeTooltip(ItemTooltip, itemNameControl, TOPRIGHT, -40, 0, TOPLEFT)
        ItemTooltip:SetLink(itemNameControl.itemLink)
        onRowMouseEnter(itemNameControl:GetParent())
    end

    local function onItemNameMouseExit(itemNameControl)
        ClearTooltip(ItemTooltip)
        onRowMouseExit(itemNameControl:GetParent())
    end

    local function onDeleteButtonMouseEnter(deleteButtonControl)
        ZO_Tooltips_ShowTextTooltip(deleteButtonControl, TOP, GetString(SI_SK_AUT_UNWANTED_LIST_DELETE_BUTTON))
        onRowMouseEnter(deleteButtonControl:GetParent())
    end

    local function onDeleteButtonMouseExit(deleteButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(deleteButtonControl:GetParent())
    end

    rowControl.data = rowData

    local itemIconControl = rowControl:GetNamedChild("ItemIcon")
    itemIconControl:SetTexture(rowData.itemIcon)

    local itemNameControl = rowControl:GetNamedChild("ItemName")
    itemNameControl:SetHandler("OnMouseEnter", onItemNameMouseEnter)
    itemNameControl:SetHandler("OnMouseExit", onItemNameMouseExit)
    itemNameControl.itemLink = rowData.itemLink
    itemNameControl:SetText(rowData.itemName)

    local delButtonControl = rowControl:GetNamedChild("DelButton")
    delButtonControl:SetHandler("OnMouseEnter", onDeleteButtonMouseEnter)
    delButtonControl:SetHandler("OnMouseExit", onDeleteButtonMouseExit)
    delButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKA.removeItemFromNotBind(rowControl.data.itemLink, rowControl.data.itemId)
    end)

    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function WatchedAbilitiesList:SetupRow(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        SKH.onRowMouseToggle(self.dialogue.watchedAbilitiesList, rowControl, {"EditButton", "ToggleControlButton"}, true)
    end

    local function onRowMouseExit(rowControl)
        SKH.onRowMouseToggle(self.dialogue.watchedAbilitiesList, rowControl, {"EditButton", "ToggleControlButton"}, false)
    end

    local function onAbilityNameMouseEnter(abilityNameControl)
        local skillType, skillLineIndex, skillIndex, morphChoice = GetSpecificSkillAbilityKeysByAbilityId(abilityNameControl.abilityId)
        InitializeTooltip(SkillTooltip, abilityNameControl, TOPRIGHT, -48, 0, TOPLEFT)
        SkillTooltip:SetSkillLineAbilityId(abilityNameControl.abilityId, skillType, skillLineIndex, skillIndex, morphChoice)
        local r, g, b = SK.COLOR.ORANGE_RED:UnpackRGB()
        local help = rowControl.data.help
        if help ~= nil then
            SkillTooltip:AddLine(help, "ZoFontWinT2", r, g, b, LEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
        end

        onRowMouseEnter(abilityNameControl:GetParent())
    end

    local function onAbilityNameMouseExit(abilityNameControl)
        ClearTooltip(SkillTooltip)
        onRowMouseExit(abilityNameControl:GetParent())
    end

    local function onSkillLineNameMouseEnter(skillLineNameControl)
        onRowMouseEnter(skillLineNameControl:GetParent())
    end

    local function onCorrectionIntervalMouseEnter(correctionIntervalControl)
        if rowControl.data.correctionInterval ~= nil then
            ZO_Tooltips_ShowTextTooltip(correctionIntervalControl, TOP, GetString(SI_SK_BATTLE_AC_BLOCK_CORRECTION_INTERVAL_TOOLTIP))
        end
        onRowMouseEnter(correctionIntervalControl:GetParent())
    end

    local function onHPMouseEnter(hpControl)
        if rowControl.data.hp ~= nil then
            ZO_Tooltips_ShowTextTooltip(hpControl, TOP, GetString(SI_SK_BATTLE_AC_BLOCK_HP_TOOLTIP))
        end
        onRowMouseEnter(hpControl:GetParent())
    end

    local function onToggleControlButtonMouseEnter(toggleControlButtonControl)
        ZO_Tooltips_ShowTextTooltip(toggleControlButtonControl, TOP, GetString(SI_SK_AUT_ABILITY_LIST_TOGGLE_CONTROL_BUTTON))
        onRowMouseEnter(toggleControlButtonControl:GetParent())
    end

    local function onEditButtonMouseEnter(editButtonControl)
        ZO_Tooltips_ShowTextTooltip(editButtonControl, TOP, GetString(SI_SK_AUT_UNWANTED_LIST_EDIT_BUTTON))
        onRowMouseEnter(editButtonControl:GetParent())
    end

    local function onModeIconMouseEnter(modeIconControl)
        ZO_Tooltips_ShowTextTooltip(modeIconControl, TOP, GetString("SI_SK_AUT_ABILITY_LIST_MODE_ICON_TOOLTIP", rowControl.data.mode))
        onRowMouseEnter(modeIconControl:GetParent())
    end

    local function onTypeIconMouseEnter(typeIconControl)
        ZO_Tooltips_ShowTextTooltip(typeIconControl, TOP, GetString("SI_SK_AUT_ABILITY_LIST_TYPE_ICON_TOOLTIP", rowControl.data.abilityType))
        onRowMouseEnter(typeIconControl:GetParent())
    end

    local function onSwapTimeIconMouseEnter(swapTimeIconControl)
        ZO_Tooltips_ShowTextTooltip(swapTimeIconControl, TOP, GetString(SI_SK_AUT_ABILITY_LIST_SWAP_TIME_ICON_TOOLTIP))
        onRowMouseEnter(swapTimeIconControl:GetParent())
    end

    local function onSelfIconMouseEnter(selfIconControl)
        ZO_Tooltips_ShowTextTooltip(selfIconControl, TOP, GetString(SI_SK_AUT_ABILITY_LIST_SELF_ICON_TOOLTIP))
        onRowMouseEnter(selfIconControl:GetParent())
    end

    local function onDisabledIconMouseEnter(disabledIconControl)
        ZO_Tooltips_ShowTextTooltip(disabledIconControl, TOP, GetString(SI_SK_AUT_ABILITY_LIST_DISABLE_ICON_TOOLTIP))
        onRowMouseEnter(disabledIconControl:GetParent())
    end

    local function onControlMouseExit(control)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(control:GetParent())
    end

    rowControl.data = rowData

    local abilityIconControl = rowControl:GetNamedChild("AbilityIcon")
    abilityIconControl:SetTexture(rowData.abilityIcon)

    local abilityNameControl = rowControl:GetNamedChild("AbilityName")
    abilityNameControl:SetHandler("OnMouseEnter", onAbilityNameMouseEnter)
    abilityNameControl:SetHandler("OnMouseExit", onAbilityNameMouseExit)
    abilityNameControl.abilityId = rowData.abilityId
    abilityNameControl:SetText(rowData.abilityName)

    local skillLineNameControl = rowControl:GetNamedChild("SkillLineName")
    skillLineNameControl:SetHandler("OnMouseEnter", onSkillLineNameMouseEnter)
    skillLineNameControl:SetHandler("OnMouseExit", onControlMouseExit)
    skillLineNameControl:SetText(rowData.skillLineName)

    local correctionIntervalControl = rowControl:GetNamedChild("CorrectionInterval")
    correctionIntervalControl:SetHandler("OnMouseEnter", onCorrectionIntervalMouseEnter)
    correctionIntervalControl:SetHandler("OnMouseExit", onControlMouseExit)
    if rowData.correctionInterval ~= nil then
        correctionIntervalControl:SetText(SK.COLOR.WHITE:Colorize(rowData.correctionInterval))
    else
        correctionIntervalControl:SetText("")
    end

    local hpControl = rowControl:GetNamedChild("HP")
    hpControl:SetHandler("OnMouseEnter", onHPMouseEnter)
    hpControl:SetHandler("OnMouseExit", onControlMouseExit)
    if rowData.hp ~= nil then
        hpControl:SetText(SK.COLOR.WHITE:Colorize(rowData.hp))
    else
        hpControl:SetText("")
    end

    local optionalIconControl = rowControl:GetNamedChild("OptionalIcon")
    optionalIconControl:SetHandler("OnMouseExit", onControlMouseExit)
    if rowControl.data.castByPlayer ~= SK.TRUE then
        optionalIconControl:SetHandler("OnMouseEnter", onSwapTimeIconMouseEnter)
        optionalIconControl:SetTexture("SwissKnife/textures/abilities/swap_time.dds")
        optionalIconControl:SetHidden(not(rowData.isFT ~= nil and rowData.isFT == SK.FALSE))
    else
        optionalIconControl:SetHandler("OnMouseEnter", onSelfIconMouseEnter)
        optionalIconControl:SetTexture("SwissKnife/textures/abilities/self.dds")
        optionalIconControl:SetHidden(false)
    end

    local modeIconControl = rowControl:GetNamedChild("ModeIcon")
    modeIconControl:SetHandler("OnMouseEnter", onModeIconMouseEnter)
    modeIconControl:SetHandler("OnMouseExit", onControlMouseExit)
    modeIconControl:SetTexture(SKDA.MODES_ICONS[rowData.mode])

    local typeIconControl = rowControl:GetNamedChild("TypeIcon")
    if rowControl.data.abilityType ~= nil then
        typeIconControl:SetHidden(false)
        typeIconControl:SetTexture(SKDA.TYPES_ICONS[rowControl.data.abilityType])
        typeIconControl:SetHandler("OnMouseEnter", onTypeIconMouseEnter)
        typeIconControl:SetHandler("OnMouseExit", onControlMouseExit)
    else
        typeIconControl:SetHidden(true)
    end

    local disabledIconControl = rowControl:GetNamedChild("DisabledIcon")
    disabledIconControl:SetHandler("OnMouseEnter", onDisabledIconMouseEnter)
    disabledIconControl:SetHandler("OnMouseExit", onControlMouseExit)
    disabledIconControl:SetTexture("SwissKnife/textures/abilities/disabled.dds")
    disabledIconControl:SetHidden(rowData.disabled == SK.FALSE)

    local editButtonControl = rowControl:GetNamedChild("EditButton")
    editButtonControl:SetHandler("OnMouseEnter", onEditButtonMouseEnter)
    editButtonControl:SetHandler("OnMouseExit", onControlMouseExit)
    editButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKEA:Open(rowControl.data.id)
    end)

    local toggleControlButtonControl = rowControl:GetNamedChild("ToggleControlButton")
    toggleControlButtonControl:SetHandler("OnMouseEnter", onToggleControlButtonMouseEnter)
    toggleControlButtonControl:SetHandler("OnMouseExit", onControlMouseExit)
    toggleControlButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        if rowControl.data.disabled == FALSE then
            rowData.disabled = TRUE
            SK.globalSV.automationBlockAbilities[rowData.id].disabled = TRUE
        else
            rowControl.data.disabled = FALSE
            SK.globalSV.automationBlockAbilities[rowData.id].disabled = FALSE
        end
        disabledIconControl:SetHidden(rowData.disabled == FALSE)
    end)

    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function TrackedAbilitiesList:SetupRow(rowControl, rowData)
    local function onRowMouseEnter(rowControl)
        SKH.onRowMouseToggle(self.dialogue.trackedAbilitiesList, rowControl, {"ExportButton", "ApplyButton", "DelButton"}, true)
    end

    local function onRowMouseExit(rowControl)
        SKH.onRowMouseToggle(self.dialogue.trackedAbilitiesList, rowControl, {"ExportButton", "ApplyButton", "DelButton"}, false)
    end

    local function onApplyButtonMouseEnter(applyButtonControl)
        ZO_Tooltips_ShowTextTooltip(applyButtonControl, TOP, GetString(SI_SK_AUT_ABILITY_LIST_SET_HOTBAR_BUTTON))
        onRowMouseEnter(applyButtonControl:GetParent())
    end

    local function onApplyButtonMouseExit(applyButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(applyButtonControl:GetParent())
    end

    local function onExportButtonMouseEnter(exportButtonControl)
        ZO_Tooltips_ShowTextTooltip(exportButtonControl, TOP, GetString(SI_SK_AUT_ABILITY_LIST_EXPORT_HOTBAR_BUTTON))
        onRowMouseEnter(exportButtonControl:GetParent())
    end

    local function onExportButtonMouseExit(exportButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(exportButtonControl:GetParent())
    end

    local function onAccNameMouseEnter(accNameControl)
        onRowMouseEnter(accNameControl:GetParent())
    end

    local function onAccNameMouseExit(accNameControl)
        onRowMouseExit(accNameControl:GetParent())
    end

    local function onCharNameMouseEnter(accNameControl)
        onRowMouseEnter(accNameControl:GetParent())
    end

    local function onCharNameMouseExit(accNameControl)
        onRowMouseExit(accNameControl:GetParent())
    end

    local function onAbilityMouseEnter(abilityControl)
        if abilityControl.skillProgressionData then
            InitializeTooltip(SkillTooltip, abilityControl, TOPRIGHT, 0, 0, TOPLEFT)
            abilityControl.skillProgressionData:SetKeyboardTooltip(SkillTooltip)
        end
    end

    local function onAbilityMouseExit(abilityControl)
        ClearTooltip(SkillTooltip)
    end

    local function onDeleteButtonMouseEnter(deleteButtonControl)
        ZO_Tooltips_ShowTextTooltip(deleteButtonControl, TOP, GetString(SI_SK_AUT_UNWANTED_LIST_DELETE_BUTTON))
        onRowMouseEnter(deleteButtonControl:GetParent())
    end

    local function onDeleteButtonMouseExit(deleteButtonControl)
        ZO_Tooltips_HideTextTooltip()
        onRowMouseExit(deleteButtonControl:GetParent())
    end

    rowControl.data = rowData
    rowControl:SetDimensions(771, self.rowHeight)

    local skillsControl = rowControl:GetNamedChild("Skills")
    for barIndex, data in pairs(rowData.skillsData) do
        for skillIndex, skillId in pairs(data) do
            local controlName = "Skills_Control_"..barIndex.."_Slot"..skillIndex
            local skillControlSlot = skillsControl:GetNamedChild(controlName)
            if skillControlSlot == nil then
    		    skillControlSlot = WM:CreateControlFromVirtual("$(parent)"..controlName, skillsControl, "SK_Skill_Slot")
                local offsetX = (skillIndex - 1) * 36 + (skillIndex - 1) * 3
                local offsetY = barIndex * 36 + barIndex * 3
                if skillIndex == #data then offsetX = offsetX + 5 end
                skillControlSlot:SetAnchor(TOPLEFT, skillsControl, TOPLEFT, offsetX, offsetY)
                skillControlSlot:SetHandler("OnMouseEnter", onAbilityMouseEnter)
                skillControlSlot:SetHandler("OnMouseExit", onAbilityMouseExit)
                skillControlSlot:SetHidden(false)
            end
            local abilityIcon = nil
            local controlIcon = skillControlSlot:GetNamedChild("Icon")
            if skillId ~= 0 then
                abilityIcon = GetAbilityIcon(skillId)
                controlIcon.skillProgressionData = SKILLS_DATA_MANAGER:GetProgressionDataByAbilityId(skillId)
                controlIcon.abilityId = skillId
                controlIcon:SetHandler("OnMouseEnter", onAbilityMouseEnter)
                controlIcon:SetHandler("OnMouseExit", onAbilityMouseExit)
                controlIcon:SetHidden(false)
            else
                controlIcon:SetHidden(true)
            end
            controlIcon:SetTexture(abilityIcon)
        end
    end

    local ownerNameControl = rowControl:GetNamedChild("OwnerName")
    ownerNameControl:SetHandler("OnMouseEnter", onCharNameMouseEnter)
    ownerNameControl:SetHandler("OnMouseExit", onCharNameMouseExit)
    ownerNameControl:SetText(rowData.ownerName)
    ownerNameControl:SetDimensions(177, self.rowHeight)

    local classNameControl = rowControl:GetNamedChild("ClassName")
    classNameControl:SetHandler("OnMouseEnter", onCharNameMouseEnter)
    classNameControl:SetHandler("OnMouseExit", onCharNameMouseExit)
    local className = SK.COLOR.LIGHT_BLUE:Colorize(rowData.className)
    if GetUnitClassId("player") == tonumber(rowData.classId) then className = className.." "..SK.COLOR.GREEN:Colorize("*") end
    classNameControl:SetText(className)

    local presetNameControl = rowControl:GetNamedChild("PresetName")
    presetNameControl:SetHandler("OnMouseEnter", onCharNameMouseEnter)
    presetNameControl:SetHandler("OnMouseExit", onCharNameMouseExit)
    local presetName = SK.COLOR.LIGHT_YELLOW:Colorize(rowData.presetName)
    presetNameControl:SetText(presetName)

    local accNameControl = rowControl:GetNamedChild("AccName")
    accNameControl:SetHandler("OnMouseEnter", onAccNameMouseEnter)
    accNameControl:SetHandler("OnMouseExit", onAccNameMouseExit)
    accNameControl:SetText(rowData.accName)
    accNameControl:SetDimensions(180, self.rowHeight)

    local applyButtonControl = rowControl:GetNamedChild("ApplyButton")
    applyButtonControl:SetHandler("OnMouseEnter", onApplyButtonMouseEnter)
    applyButtonControl:SetHandler("OnMouseExit", onApplyButtonMouseExit)
    applyButtonControl:SetHandler("OnMouseDown", function(self)
        for hotbarIndex, data in pairs(rowData.skillsData) do
            for skillIndex, skillId in pairs(data) do
                local slotIndex = skillIndex + ACTION_BAR_FIRST_NORMAL_SLOT_INDEX
                SKH.setAbilitySlot(hotbarIndex, slotIndex, skillId)
            end
        end
        ZO_Tooltips_HideTextTooltip()
    end)

    local exportButtonControl = rowControl:GetNamedChild("ExportButton")
    exportButtonControl:SetHandler("OnMouseEnter", onExportButtonMouseEnter)
    exportButtonControl:SetHandler("OnMouseExit", onExportButtonMouseExit)
    exportButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKH.exportAbilityPreset(rowData)
    end)

    local delButtonControl = rowControl:GetNamedChild("DelButton")
    delButtonControl:SetHandler("OnMouseEnter", onDeleteButtonMouseEnter)
    delButtonControl:SetHandler("OnMouseExit", onDeleteButtonMouseExit)
    delButtonControl:SetHandler("OnMouseDown", function(self)
        ZO_Tooltips_HideTextTooltip()
        SKH.removeAbilityPreset("@"..rowData.accName, rowData.ownerName, rowData.presetName)
    end)

    rowControl:SetHandler("OnMouseEnter", onRowMouseEnter)
    rowControl:SetHandler("OnMouseExit", onRowMouseExit)

    ZO_SortFilterList.SetupRow(self, rowControl, rowData)
end

function UnwantedSetsList:Refresh()
    self.items = {}
    local count = 0
	for k, v in pairs(SK.globalSV.permanentUnwantedSetIds) do
        local itemLink = SKH.decompressItemLink(v.itemLink)
        local hasSet, setName
        if SK.savedVars.showEnSetNameToo then
            setName = SKH.getSetName(itemLink)
        else
        	hasSet, setName = GetItemLinkSetInfo(itemLink)
        end
		self.items[k] = {
    		type = SK_BASE_DATA_TYPE,
            setId = k,
			setName = setName,
            itemLink = itemLink,
            setQuality = v.quality,
            deconstructQuality = v.deconstructQuality,
            junkQualityJewelry = v.qualityJewelry,
            deconstructQualityJewelry = v.deconstructQualityJewelry
		}
        count = count + 1
	end
    self:RefreshData()
end

function SetsItemsList:Refresh()
	--[<set id>] = {
	--	[<account name>] = {
	--		[<character name>] = {
	--			[<bag id>] = {
	--				[<slot_id>] = "|H0:item:53430:370:50:45869:370:50:0:0:0:0:0:0:0:0:1:24:1:1:0:379:0|h|h",
	--				...
	--			},
	--		},
	--		[SK.storageName] = {
	--			[<bag id>] = {
	--				[<slot id>] = "|H0:item:53430:370:50:45869:370:50:0:0:0:0:0:0:0:0:1:24:1:1:0:379:0|h|h",
	--				...
	--			},
	--		},
	--	},
	--}
    self.items = {}
    local counter = 0
    if SK.globalSV.trackedSetsItems then
        for setId, setData in pairs(SK.globalSV.trackedSetsItems) do
            if setData then
                for accName, accData in pairs(setData) do
                    if accData then
                        for ownerId, bagsData in pairs(accData) do
                            if bagsData then
                                for bagId, bagData in pairs(bagsData) do
                                    if bagData then
                                        for _, compressedItemLink in pairs(bagData) do
                                            local itemLink = SKH.decompressItemLink(compressedItemLink)
                                            local bagName = SKH.getBagName(bagId)
                                            local setName = SKH.getSetName(itemLink)
                                            local ownerName, ownerType = SKH.getOwnerName(ownerId, bagId)
                                            local itemTypeName, itemTypePreset = SKH.getItemTypeName(itemLink)
                                            local armorType, armorTypeName = SKH.getTrackedSetItemArmorType(itemLink)
                                            local itemName = SK.QUALITY_MAP[GetItemLinkFunctionalQuality(itemLink)]:Colorize(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, GetItemLinkName(itemLink)))
                                            local whereIsIt = "["..bagName.."] ["..ownerName.."] "..setName.." ["..
                                                    itemTypePreset.."] ["..itemTypeName.."]"
                                            if armorTypeName ~= nil then
                                                itemTypeName = itemTypeName.." ["..armorType.."]"
                                                whereIsIt = whereIsIt.." ["..armorTypeName.."]"
                                            end
                                            if ownerType ~= nil then whereIsIt = whereIsIt.." ["..ownerType.."]" end
                                            if string.find(ownerId, SK.companionOwnerNamePrefix) then
                                                ownerName = ownerName.." "..SK.COLOR.DARK_SLATE_BLUE:Colorize("*")
                                            end
                                            counter = counter + 1
                                            self.items[counter] = {
                                                type = SK_BASE_DATA_TYPE,
                                                whereIsIt = whereIsIt,
                                                whatIsIt = ""..itemTypePreset.." "..itemTypeName,
                                                itemTypeName = itemTypeName,
                                                bagIcon = SKH.getTrackedSetBagIcon(ownerId, bagId),
                                                itemIcon = SKH.getItemTypeIcon(itemLink),
                                                itemName = itemName,
                                                armorType = armorType,
                                                bagName = bagName,
                                                accName = string.gsub(accName, "@", "", 1),
                                                ownerName = ownerName,
                                                itemLink = itemLink,
                                                setId = setId,
                                                trait = SKH.getTraitName(itemLink),
                                                bagId = bagId,
                                                ownerID = ownerId,
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        self:RefreshData()
    end
end

function UnwantedItemsList:Refresh()
    self.items = {}
	for k, v in pairs(SK.globalSV.permanentUnwantedItemIds) do
        local itemLink = SKH.decompressItemLink(v.itemLink)
        local action = v.action
        if action == nil then action = SK.destroyAction end
        local itemName = SK.QUALITY_MAP[GetItemLinkFunctionalQuality(itemLink)]:Colorize(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, GetItemLinkName(itemLink)))
		self.items[k] = {
    		type = SK_BASE_DATA_TYPE,
			itemIcon = GetItemLinkInfo(itemLink),
			itemLink = itemLink,
            action = action,
			itemName = itemName,
		}
	end
    self:RefreshData()
end

function NotBindItemsList:Refresh()
    self.items = {}
	for itemId, v in pairs(SK.globalSV.notBindItems) do
        local itemLink = SKH.decompressItemLink(v.itemLink)
        local itemName = SK.QUALITY_MAP[GetItemLinkFunctionalQuality(itemLink)]:Colorize(zo_strformat(SI_MARKET_PRODUCT_NAME_FORMATTER, GetItemLinkName(itemLink)))
		self.items[itemId] = {
    		type = SK_BASE_DATA_TYPE,
			itemIcon = GetItemLinkInfo(itemLink),
			itemId = itemId,
			itemLink = itemLink,
			itemName = itemName,
		}
	end
    self:RefreshData()
end

function WatchedAbilitiesList:Refresh()
    self.items = {}
	for id, data in pairs(SK.globalSV.automationBlockAbilities) do
        local cache = SK.automationBlockAbilitiesCache[id]
        local key = string.format("%02d", cache.skillLineIndex)..string.format("%02d", cache.skillIndex)..string.format("%02d", cache.morphChoice)
        local help = ""
        if SK.savedVars.debugMode then
            local abilityList = {}
            if data.allBuffs ~= nil then
                abilityList = data.allBuffs
            elseif data.allDebuffs ~= nil then
                abilityList = data.allDebuffs
            elseif data.buff ~= nil then
                abilityList = {data.buff,}
            elseif data.debuff ~= nil then
                abilityList = {data.debuff,}
            end
            for _, aid in ipairs(abilityList) do
                if SKDA.ABILITY_NAMES[aid] ~= nil then
                    help = help..'\n'..SKDA.ABILITY_NAMES[aid]
                else
                    help = help..'\n'..tostring(aid)
                end
            end
        end
        self.items[cache.abilityId] = {
    		type = SK_BASE_DATA_TYPE,
            id = id,
            orderKey = cache.skillLineName..key,
			abilityId = cache.abilityId,
			abilityIcon = cache.abilityIcon,
			abilityName = cache.abilityName,
			skillLineName = cache.skillLineName,
            modeName = cache.modeName,
            abilityType = cache.abilityType,
            castByPlayer = cache.castByPlayer,
            isFT = data.isFT,
            correctionInterval = data.correctionInterval,
            hp = data.hp,
            time = data.time,
            mode = data.mode,
            help = help,
            disabled = data.disabled
		}
	end
    self:RefreshData()
end

function TrackedAbilitiesList:Refresh()
    self.items = {}
	for accName, data in pairs(SK.globalSV.trackedAccountsHotbarAbilities) do
        for ownerName, charData in pairs(data) do
            if charData.skills ~= nil then
                for presetName, hotbarData in pairs(charData.skills) do
                    self.items[accName..ownerName..presetName] = {
                        type = SK_BASE_DATA_TYPE,
                        accName = string.gsub(accName, "@", "", 1),
                        ownerName = ownerName,
                        skillsData = hotbarData,
                        className = GetClassName(charData.gender, charData.classId),
                        classId = charData.classId,
                        gender = charData.gender,
                        presetName = presetName
                    }
                end
            end
    	end
	end
    self:RefreshData()
end

function TrackedAbilitiesList:AddPreset()
    local dialogName = "SI_SK_INPUT_PRESET_NAME"
    local data = {
        name = dialogName,
        inputLineTitle = "SI_SK_AUT_TRACKED_ABILITIES_INPUT_PRESET_NAME",
        callback = function(inputLine)
            SKH.addAbilityPreset(inputLine)
        end
    }
    local control = WM:GetControlByName("InputAbilitiyPresetDialog")
    InitInputLineDialogue(control, data)
    ZO_Dialogs_ShowDialog(dialogName)
end

-- ----------------------------------------------------
-- MainDialogue
-- ----------------------------------------------------
MainDialogue = ZO_Object:Subclass()
function MainDialogue:New()
    local object = ZO_Object.New(self)
    return object
end

function MainDialogue:Initialize(control)
    self.isVisible = false
    self.needRefreshAfterOpen = false
    self.cameraUIMode = false
    self.control = control
    self.guiRoot = WM:GetControlByName("GuiRoot")
    self.lists = {}
    self.dock = self.control:GetNamedChild("HeaderDock")
    self.lock = self.control:GetNamedChild("HeaderLock")
    self.lockIcon = self.control:GetNamedChild("HeaderIcon")
    self.navBar = self.control:GetNamedChild("NavBar")
    self.toggleSize = self.navBar:GetNamedChild("ToggleSize")
    self.modeBar = self.navBar:GetNamedChild("Mode")
    self.modeHeaderTitle = self.control:GetNamedChild("HeaderTitle")
    self.setsControl = self.control:GetNamedChild("Sets")
    self.setsItemsControl = self.control:GetNamedChild("SetsItems")
    self.itemsControl = self.control:GetNamedChild("Items")
    self.notBindItemsControl = self.control:GetNamedChild("NotBindItems")
    self.abilitiesControlControl = self.control:GetNamedChild("AbilitiesControl")
    self.trackedAbilitiesControl = self.control:GetNamedChild("AbilitiesTracker")
    self.listsControls = {
        self.setsControl,
        self.setsItemsControl,
        self.itemsControl,
        self.notBindItemsControl,
        self.abilitiesControlControl,
        self.trackedAbilitiesControl
    }
    self.setsList = UnwantedSetsList:New(self.setsControl, self, SI_SK_LIST_NO_ITEMS,
            "setName", "UnwantedSetsListRowTemplate", {["setName"] = {caseInsensitive=true},})
    local baseAccountsFilters = {}
    table.insert(baseAccountsFilters, {
        name = "AccountFilter",
        choices = SK.FilterAccountsNames,
        minWidth = 170,
        maxWidth = 210,
        sub = "ServerFilter"
    })
    if not SK.HasOneServer then
        table.insert(baseAccountsFilters, 1, {
            name = "ServerFilter",
            choices = SK.FilterServersNames,
            minWidth = 70,
            maxWidth = 110,
            sub = "AccountFilter"
        })
    end
    local setsItemsListFilters = {}
    SKH.objectsDeepCopy(baseAccountsFilters, setsItemsListFilters)
    table.insert(setsItemsListFilters, {
        name = "PersonTypeFilter",
        brackets = 1,
        choices = {
            GetString(SI_SK_ALL_PERSONS_TEXT),
            GetString(SI_SK_CHARACTER_TEXT),
            GetString(SI_SK_COMPANION_TEXT)
        },
        minWidth = 110,
        maxWidth = 130,
    })
    table.insert(setsItemsListFilters, {
        name = "StorageTypeFilter",
        brackets = 1,
        choices = {
            GetString(SI_SK_ALL_PLACES_TEXT),
            GetString(SI_SK_INFO_LOCATION_EQUIPPED),
            GetString(SI_SK_INFO_LOCATION_INVENTORY),
            GetString(SI_SK_INFO_LOCATION_BANK),
            GetString(SI_SK_INFO_LOCATION_HOUSE_BANK)
        },
        minWidth = 70,
        maxWidth = 110,
        sub = "PersonTypeFilter"
    })
    table.insert(setsItemsListFilters,{
        name = "ArmorTypeFilter",
        brackets = 1,
        choices = {
            GetString(SI_SK_ALL_ARMOR_TYPES_TEXT),
            GetString(SI_SK_INFO_ARMOR_LIGHT),
            GetString(SI_SK_INFO_ARMOR_MEDIUM),
            GetString(SI_SK_INFO_ARMOR_HEAVY),
        },
        minWidth = 90,
        maxWidth = 110,
    })
    table.insert(setsItemsListFilters, {
        name = "ItemTypeFilter",
        brackets = 1,
        choices = SK.FilterItemTypeNames,
        minWidth = 150,
        maxWidth = 190,
        sub = "ArmorTypeFilter"
    })
    table.insert(self.lists, self.setsList)
    self.setsItemsList = SetsItemsList:New(self.setsItemsControl, self, SI_SK_LIST_NO_ITEMS,
        "whatIsIt", "SetsItemsListRowTemplate", {
            ["whereIsIt"] = {caseInsensitive=true},
            ["whatIsIt"] = {caseInsensitive=true, tiebreaker = "whereIsIt"},
            ["itemName"] = {caseInsensitive=true, tiebreaker = "whatIsIt"},
            ["accName"] = {caseInsensitive=true, tiebreaker = "itemName"},
            ["ownerName"] = {caseInsensitive=true, tiebreaker = "accName"},
            ["trait"] = {caseInsensitive=true, tiebreaker = "ownerName"},
        }, nil, setsItemsListFilters
    )
    table.insert(self.lists, self.setsItemsList)
    self.itemsList = UnwantedItemsList:New(self.itemsControl, self, SI_SK_LIST_NO_ITEMS,
            "itemName", "UnwantedItemsListRowTemplate", {["itemName"] = {},})
    table.insert(self.lists, self.itemsList)
    self.notBindItemsList = NotBindItemsList:New(self.notBindItemsControl, self, SI_SK_LIST_NO_ITEMS,
            "itemName", "NotBindItemsListRowTemplate", {["itemName"] = {},})
    table.insert(self.lists, self.notBindItemsList)
    self.watchedAbilitiesList = WatchedAbilitiesList:New(self.abilitiesControlControl, self, SI_SK_LIST_NO_ITEMS,
            "orderKey", "WatchedAbilitiesListRowTemplate", {
                ["abilityName"] = {caseInsensitive=true},
                ["orderKey"] = {caseInsensitive=true, tiebreaker = "abilityName"},
                ["modeName"] = {caseInsensitive=true, tiebreaker = "orderKey"},
            }, 48, {
                {
                    name = "skillLineName",
                    choices = SK.FilterAbilitySkillLines,
                    minWidth = 120,
                    maxWidth = 170,
                },
                {
                    name = "modeName",
                    choices = SK.FilterAbilityModes,
                    minWidth = 70,
                    maxWidth = 130,
                }
            })
    table.insert(self.lists, self.watchedAbilitiesList)
    self.trackedAbilitiesList = TrackedAbilitiesList:New(self.trackedAbilitiesControl, self, SI_SK_LIST_NO_ITEMS,
            "className", "TrackedAbilitiesListRowTemplate", {
                ["className"] = {caseInsensitive=true},
                ["presetName"] = {caseInsensitive=true},
                ["accName"] = {caseInsensitive=true, tiebreaker = "className"},
                ["ownerName"] = {caseInsensitive=true, tiebreaker = "accName"},
            }, 86, baseAccountsFilters)
    table.insert(self.lists, self.trackedAbilitiesList)
    self.editSet = nil
    if SK.savedVars.mainDialogueData.lastMode then
        self.mode = SK.savedVars.mainDialogueData.lastMode
    end
    if self.mode == SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE and not SK.savedVars.trackSetsItems then
        self.mode = SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE
    elseif self.mode == nil then
        self.mode = SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE
    end
    self:InitializeWindowParams()
    self:InitializeNavBar()
    self.watchedAbilitiesList:Refresh()
end

function MainDialogue:InitializeWindowParams()
    local movable = SK.savedVars.mainDialogueData.lockState == SK.MAIN_DIALOGUE_DATA.LOCK_STATE.UNLOCKED
    self:Lock(movable)
    local function onLockButtonMouseEnter()
        if self.movable then
            ZO_Tooltips_ShowTextTooltip(self.lock, TOP, GetString(SI_SK_DIALOG_LOCK))
        else
            ZO_Tooltips_ShowTextTooltip(self.lock, TOP, GetString(SI_SK_DIALOG_UNLOCK))
        end
    end
    self.lock:SetHandler("OnMouseEnter", onLockButtonMouseEnter)
    self:SetSize()
    self.control:ClearAnchors()
    self.control:SetAnchor(SK.savedVars.mainDialogueData.point, self.guiRoot, SK.savedVars.mainDialogueData.relativePoint,
            SK.savedVars.mainDialogueData.offsetX, SK.savedVars.mainDialogueData.offsetY)
end

function MainDialogue:InitializeNavBar()
    local function CreateButtonData(name, tooltip, mode, normal, pressed, highlight, disabled)
        return {
            activeTabText = name,
            tooltip = tooltip,
            descriptor = mode,
            normal = normal,
            pressed = pressed,
            highlight = highlight,
            disabled = disabled,
            callback = function(data)
                self.mode = mode
                self:OnModeUpdated()
            end,
        }
    end

    local barData = {
        buttonPadding = 0,
        orientation = "vertical",
        normalSize = 36,
        downSize = 39,
        animationDuration = DEFAULT_SCENE_TRANSITION_TIME,
        buttonTemplate = "MainDialogueNavBarButtonTemplate",
    }
    SKH.setMenuBarData(self.modeBar, barData)

    local tabsData = {
        CreateButtonData(
            SI_SK_AUT_TRACKED_SET_ITEMS_HEADER,
            SI_SK_AUT_TRACKED_SET_ITEMS_TOOLTIP,
            SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE,
            "SwissKnife/textures/dialogues/nav/set_tracker_tabicon_up.dds",
            "SwissKnife/textures/dialogues/nav/set_tracker_tabicon_down.dds",
            "SwissKnife/textures/dialogues/nav/set_tracker_tabicon_over.dds",
            "SwissKnife/textures/dialogues/nav/set_tracker_tabicon_up.dds"
        ),
        CreateButtonData(
            SI_SK_AUT_UNWANTED_LIST_SETS_HEADER,
            SI_SK_AUT_UNWANTED_LIST_SETS_TOOLTIP,
            SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE,
            "SwissKnife/textures/dialogues/nav/sets_tabicon_up.dds",
            "SwissKnife/textures/dialogues/nav/sets_tabicon_down.dds",
            "SwissKnife/textures/dialogues/nav/sets_tabicon_over.dds",
            "SwissKnife/textures/dialogues/nav/sets_tabicon_up.dds"
        ),
        CreateButtonData(
            SI_SK_AUT_UNWANTED_LIST_ITEMS_HEADER,
            SI_SK_AUT_UNWANTED_LIST_ITEMS_TOOLTIP,
            SKDC.MAIN_DIALOGUE_UNWANTED_ITEMS_MODE,
            "SwissKnife/textures/dialogues/nav/broken_pottery_tabicon_up.dds",
            "SwissKnife/textures/dialogues/nav/broken_pottery_tabicon_down.dds",
            "SwissKnife/textures/dialogues/nav/broken_pottery_tabicon_over.dds",
            "SwissKnife/textures/dialogues/nav/broken_pottery_tabicon_up.dds"
        ),
        CreateButtonData(
            SI_SK_AUT_NOT_BIND_LIST_ITEMS_HEADER,
            SI_SK_AUT_NOT_BIND_LIST_ITEMS_TOOLTIP,
            SKDC.MAIN_DIALOGUE_NOT_BIND_ITEMS_MODE,
            "SwissKnife/textures/dialogues/nav/locked_box_tabicon_up.dds",
            "SwissKnife/textures/dialogues/nav/locked_box_tabicon_down.dds",
            "SwissKnife/textures/dialogues/nav/locked_box_tabicon_over.dds",
            "SwissKnife/textures/dialogues/nav/locked_box_tabicon_up.dds"
        ),
        CreateButtonData(
            SI_SK_AUT_WATCHED_ABILITIES_HEADER,
            SI_SK_AUT_WATCHED_ABILITIES_TOOLTIP,
            SKDC.MAIN_DIALOGUE_WATCHED_ABILITIES_MODE,
            "SwissKnife/textures/dialogues/nav/wizard_tabicon_up.dds",
            "SwissKnife/textures/dialogues/nav/wizard_tabicon_down.dds",
            "SwissKnife/textures/dialogues/nav/wizard_tabicon_over.dds",
            "SwissKnife/textures/dialogues/nav/wizard_tabicon_up.dds"
        ),
        CreateButtonData(
            SI_SK_AUT_TRACKED_ABILITIES_HEADER,
            SI_SK_AUT_TRACKED_ABILITIES_TOOLTIP,
            SKDC.MAIN_DIALOGUE_TRACKED_ABILITIES_MODE,
            "SwissKnife/textures/dialogues/nav/spellbook_tabicon_up.dds",
            "SwissKnife/textures/dialogues/nav/spellbook_tabicon_down.dds",
            "SwissKnife/textures/dialogues/nav/spellbook_tabicon_over.dds",
            "SwissKnife/textures/dialogues/nav/spellbook_tabicon_up.dds"
        ),
        --CreateButtonData(
        --    "Favorites",
        --    nil,
        --    SKDC.MAIN_DIALOGUE_FAVORITES_MODE,
        --    "SwissKnife/textures/dialogues/nav/favorites_tabicon_up.dds",
        --    "SwissKnife/textures/dialogues/nav/favorites_tabicon_down.dds",
        --    "SwissKnife/textures/dialogues/nav/favorites_tabicon_over.dds",
        --    "SwissKnife/textures/dialogues/nav/favorites_tabicon_up.dds"
        --)
    }
    for _, tabData in ipairs(tabsData) do
        if not (tabData.descriptor == SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE and not SK.savedVars.trackSetsItems) then
            ZO_MenuBar_AddButton(self.modeBar, tabData)
        end
    end
    ZO_MenuBar_SelectDescriptor(self.modeBar, self.mode)
end

function MainDialogue:showListControl(control)
    if control:IsControlHidden() then
        for _, listControl in ipairs(self.listsControls) do listControl:SetHidden(true) end
        control:SetHidden(false)
    end
end

function MainDialogue:OnModeUpdated()
    SK.savedVars.mainDialogueData.lastMode = self.mode
    if self.mode == SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE then
        self.modeHeaderTitle:SetText(SK.COLORED_PREFIXES.SKA..LocaleAwareToLower(GetString(SI_SK_AUT_UNWANTED_LIST_SETS_HEADER)))
        self:showListControl(self.setsControl)
    elseif self.mode == SKDC.MAIN_DIALOGUE_UNWANTED_ITEMS_MODE then
        self.modeHeaderTitle:SetText(SK.COLORED_PREFIXES.SKA..LocaleAwareToLower(GetString(SI_SK_AUT_UNWANTED_LIST_ITEMS_HEADER)))
        self:showListControl(self.itemsControl)
    elseif self.mode == SKDC.MAIN_DIALOGUE_NOT_BIND_ITEMS_MODE then
        self.modeHeaderTitle:SetText(SK.COLORED_PREFIXES.SKA..LocaleAwareToLower(GetString(SI_SK_AUT_NOT_BIND_LIST_ITEMS_HEADER)))
        self:showListControl(self.notBindItemsControl)
    elseif self.mode == SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE then
        self.modeHeaderTitle:SetText(SK.COLORED_PREFIXES.SKW..LocaleAwareToLower(GetString(SI_SK_AUT_TRACKED_SET_ITEMS_HEADER)))
        self:showListControl(self.setsItemsControl)
    elseif self.mode == SKDC.MAIN_DIALOGUE_WATCHED_ABILITIES_MODE then
        self.modeHeaderTitle:SetText(SK.COLORED_PREFIXES.SKW..LocaleAwareToLower(GetString(SI_SK_AUT_WATCHED_ABILITIES_HEADER)))
        self:showListControl(self.abilitiesControlControl)
    elseif self.mode == SKDC.MAIN_DIALOGUE_TRACKED_ABILITIES_MODE then
        self.modeHeaderTitle:SetText(SK.COLORED_PREFIXES.SKW..LocaleAwareToLower(GetString(SI_SK_AUT_TRACKED_ABILITIES_HEADER)))
        self:showListControl(self.trackedAbilitiesControl)
    elseif self.mode == SKDC.MAIN_DIALOGUE_FAVORITES_MODE then
        d("MAIN_DIALOGUE_FAVORITES_MODE")
    end
end

function MainDialogue:SetSize()
    local size = SK.savedVars.mainDialogueData.size
    local defaultHeight = SK.MAIN_DIALOGUE_DATA.DEFAULT.HEIGHT
    local defaultWidth = SK.MAIN_DIALOGUE_DATA.DEFAULT.WIDTH
    local defaultPadding = SK.MAIN_DIALOGUE_DATA.DEFAULT.PADDING
    local _, guiHeight = self.guiRoot:GetDimensions()
    local height = defaultHeight
    if size == SK.MAIN_DIALOGUE_DATA.SIZES.CONDENSED then
        self.control:SetDimensions(defaultWidth, defaultHeight)
    elseif size == SK.MAIN_DIALOGUE_DATA.SIZES.MEDIUM then
        height = defaultHeight + (guiHeight - defaultHeight) / 2 - defaultPadding
        self.control:SetDimensions(defaultWidth, height)
    elseif size == SK.MAIN_DIALOGUE_DATA.SIZES.EXPAND then
        height = guiHeight - defaultPadding * 2
        self.control:SetDimensions(defaultWidth, height)
    end
    local abilitiesTracker = self.control:GetNamedChild("AbilitiesTracker")
    if abilitiesTracker ~= nil then
        local _, headerHeight = self.control:GetNamedChild("Header"):GetDimensions()
        local plus = abilitiesTracker:GetNamedChild("AddButton")
        if plus ~= nil then
            local modeData = SK.MAIN_DIALOGUE_DATA.NAVBAR_MODE_SIZE
            local plusWidth, plusHeight = plus:GetDimensions()
            local plusOffsetX = (modeData.WIDTH - plusWidth) / 2
            local plusOffsetY = plusHeight / 4 - (modeData.EXTRA_PADDING + (height - headerHeight - modeData.HEIGHT -
                    modeData.EXTRA_PADDING - plusHeight) / 2)
            plus:SetAnchor(BOTTOMLEFT, self.control, BOTTOMLEFT, plusOffsetX, plusOffsetY)
        end
    end
end

function MainDialogue:ToggleSize()
    local size = SK.savedVars.mainDialogueData.size
    if size == SK.MAIN_DIALOGUE_DATA.SIZES.CONDENSED then
        SK.savedVars.mainDialogueData.size = SK.MAIN_DIALOGUE_DATA.SIZES.MEDIUM
        self:SetSize()
    elseif size == SK.MAIN_DIALOGUE_DATA.SIZES.MEDIUM then
        SK.savedVars.mainDialogueData.size = SK.MAIN_DIALOGUE_DATA.SIZES.EXPAND
        self:SetSize()
    elseif size == SK.MAIN_DIALOGUE_DATA.SIZES.EXPAND then
        SK.savedVars.mainDialogueData.size = SK.MAIN_DIALOGUE_DATA.SIZES.CONDENSED
        self:SetSize()
    end
    for _, list in ipairs(self.lists) do list:Refresh() end
    SetGameCameraUIMode(true)
end

function MainDialogue:OpenSettings()
    if SK.LAM and SK.OptionsPanel then
        self:Close()
        SK.LAM:OpenToPanel(SK.OptionsPanel)
    end
end

function MainDialogue:Open(mode, searchString)
    self.isVisible = true
    if self.control:IsControlHidden() then
        self.cameraUIMode = IsGameCameraUIModeActive()
		self.control:SetHidden(false)
        if not SKEUS.control:IsControlHidden() then SKEUS:Close() end
        if not SKEA.control:IsControlHidden() then SKEA:Close() end
    end
    if self.needRefreshAfterOpen then
        self.setsItemsList:Refresh()
        self.watchedAbilitiesList:Refresh()
        self.needRefreshAfterOpen = false
    end
    if mode then
        self.mode = mode
        if mode == SKDC.MAIN_DIALOGUE_TRACKED_SET_ITEMS_MODE and searchString and self.setsItemsList.filters ~= nil then
            for filterName, filterData in pairs(self.setsItemsList.filters) do
                if filterName == "AccountFilter" then
                    if SK.savedVars.filterCurrentAccountTrackSetsItems then
                        filterData.filterComboBox:SetSelectedItemText(
                            string.gsub(SK.AccName, "@", "", 1)
                        )
                    else
                        filterData.filterComboBox:SetSelectedItemText(filterData.default)
                    end
                elseif filterName == "ServerFilter" and not SK.HasOneServer then
                    if SK.savedVars.filterCurrentServerTrackSetsItems then
                        filterData.filterComboBox:SetSelectedItemText(SK.ServerName)
                    else
                        filterData.filterComboBox:SetSelectedItemText(filterData.default)
                    end
                end
            end
            self.setsItemsList.searchBox:SetText(searchString)
        end
        ZO_MenuBar_SelectDescriptor(self.modeBar, self.mode)
    end
    if not self.cameraUIMode then
        --SM:SetInUIMode(true)
        SetGameCameraUIMode(true)
    end
end

function MainDialogue:Close()
    self.isVisible = false
    if not self.control:IsControlHidden() then
        self.control:SetHidden(true)
        for _, list in ipairs(self.lists) do
            local needRefresh = false
            if list.filters ~= nil then
                for _, filterData in pairs(list.filters) do
                    local filterText = filterData.control.m_comboBox.m_selectedItemText:GetText()
                    if filterText ~= nil and filterData.default ~= filterText then
                        filterData.filterComboBox:SetSelectedItemText(filterData.default)
                        needRefresh = true
                    end
                end
            end
            if list.searchBox ~= nil then
                local searchText = list.searchBox:GetText()
                if searchText ~= nil and searchText ~= "" then
                    list.searchBox:SetText("")
                elseif needRefresh then
                    list:RefreshFilters()
                end
            end
        end
        _, SK.savedVars.mainDialogueData.point, _, SK.savedVars.mainDialogueData.relativePoint,
        SK.savedVars.mainDialogueData.offsetX, SK.savedVars.mainDialogueData.offsetY = self.control:GetAnchor(0)
        SetGameCameraUIMode(self.cameraUIMode)
    end
end

function MainDialogue:Lock(movable)
    self.movable = movable
    if movable then
        self.lockIcon:SetTexture("SwissKnife/textures/dialogues/icons/lock_down.dds")
    else
        self.lockIcon:SetTexture("SwissKnife/textures/dialogues/icons/lock_over.dds")
    end
    self.control:SetMovable(movable)
    self.dock:SetHidden(not movable)
end

function MainDialogue:LockToggle()
    local movable = SK.savedVars.mainDialogueData.lockState == SK.MAIN_DIALOGUE_DATA.LOCK_STATE.UNLOCKED
    if movable then
        SK.savedVars.mainDialogueData.lockState = SK.MAIN_DIALOGUE_DATA.LOCK_STATE.LOCKED
        movable = false
    else
        SK.savedVars.mainDialogueData.lockState = SK.MAIN_DIALOGUE_DATA.LOCK_STATE.UNLOCKED
        movable = true
    end
    self:Lock(movable)
end

function MainDialogue:Dock()
    self.control:ClearAnchors()
    self.control:SetAnchor(SK.defaultSavedVars.mainDialogueData.point, self.guiRoot,
        SK.defaultSavedVars.mainDialogueData.relativePoint, SK.defaultSavedVars.mainDialogueData.offsetX,
        SK.defaultSavedVars.mainDialogueData.offsetY
    )
    self:LockToggle()
end

function MainDialogue:Toggle()
	if not self.isVisible then self:Open() else self:Close() end
end

-- ----------------------------------------------------
-- EditSetDialogue
-- ----------------------------------------------------
EditSetDialogue = ZO_Object:Subclass()
function EditSetDialogue:New()
    local object = ZO_Object.New(self)
    return object
end

function EditSetDialogue:Initialize(control)
    self.control = control
    self.isVisible = false
    self.isNew = false
    self.needShowPermanentUnwanted = false
    self.setParts = {}
    self.currentSet = nil
    self.setNameControl = self.control:GetNamedChild("HeaderTitle")
    self.optionsControl = self.control:GetNamedChild("BodyMainOptions")
    self.equipmentJunkQualityControl = self.control:GetNamedChild("BodyTopEquipmentJunkQuality")
    self.equipmentJunkQualityComboBox = ZO_ComboBox_ObjectFromContainer(self.equipmentJunkQualityControl)
    self.equipmentDeconstructQualityControl = self.control:GetNamedChild("BodyTopEquipmentDeconstructQuality")
    self.equipmentDeconstructQualityComboBox = ZO_ComboBox_ObjectFromContainer(self.equipmentDeconstructQualityControl)
    self.jewelryJunkQualityControl = self.control:GetNamedChild("BodyTopJewelryJunkQuality")
    self.jewelryJunkQualityComboBox = ZO_ComboBox_ObjectFromContainer(self.jewelryJunkQualityControl)
    self.jewelryDeconstructQualityControl = self.control:GetNamedChild("BodyTopJewelryDeconstructQuality")
    self.jewelryDeconstructQualityComboBox = ZO_ComboBox_ObjectFromContainer(self.jewelryDeconstructQualityControl)
    self:makeDefaultOptions()
    self:initQualityCombobox(
        self.equipmentJunkQualityComboBox, self.setNameControl, self.equipmentDeconstructQualityComboBox,
        1, self.equipmentJunkQuality
    )
    self:initQualityCombobox(
        self.equipmentDeconstructQualityComboBox, nil, nil,
        self.equipmentJunkQuality + 1, self.equipmentDeconstructQuality
    )
    self:initQualityCombobox(
        self.jewelryJunkQualityComboBox, self.setNameControl, self.jewelryDeconstructQualityComboBox,
        1, self.jewelryJunkQuality
    )
    self:initQualityCombobox(
        self.jewelryDeconstructQualityComboBox, nil, nil,
        self.jewelryJunkQuality + 1, self.jewelryDeconstructQuality
    )
    function self.equipmentDeconstructQualityComboBox:OnClearItems()
        SKEUS.equipmentDeconstructQuality = SKEUS:OnQualityComboBoxClearItems(self,
            SKEUS.equipmentDeconstructQuality, SKEUS.equipmentJunkQuality
        )
    end
    function self.jewelryDeconstructQualityComboBox:OnClearItems()
        SKEUS.jewelryDeconstructQuality = SKEUS:OnQualityComboBoxClearItems(self,
            SKEUS.jewelryDeconstructQuality, SKEUS.jewelryJunkQuality
        )
    end
    for _, data in ipairs(SKDE.SETS_DEFAULTS) do
        self:createSetPartCheckbox(data)
	end
end

function EditSetDialogue:makeDefaultOptions()
    self.equipmentJunkQuality = SK.UNWANTED_QUALITY.JUNK.EQUIPMENT
    self.equipmentDeconstructQuality = SK.UNWANTED_QUALITY.DECONSTRUCT.EQUIPMENT
    self.jewelryJunkQuality = SK.UNWANTED_QUALITY.JUNK.JEWELRY
    self.jewelryDeconstructQuality = SK.UNWANTED_QUALITY.DECONSTRUCT.JEWELRY
    self.setParts = {[ITEMTYPE_ARMOR] = {}, [ITEMTYPE_WEAPON] = {}}
	for _, data in ipairs(SKDE.SETS_DEFAULTS) do
        local itemType, equipType, _, checked, _, _ = unpack(data)
        self.setParts[itemType][equipType] = checked
    end
end

function EditSetDialogue:OnQualityComboBoxClearItems(comboBoxControl, quality, relatedQuality)
    local leftEdge = relatedQuality + 1
    if quality < leftEdge and quality ~= 0 then
        if leftEdge > 5 then
            quality = 0
        else
            quality = leftEdge
        end
    end
    SKEUS:initQualityCombobox(comboBoxControl, nil, nil, leftEdge, quality)
    return quality
end

function EditSetDialogue:createComboboxEntry(comboBox, text, quality, selectedValue, nameControl, clearedCombobox)
    local item = SK.QUALITY_MAP[quality]:Colorize(text)
    local isJewelry = string.find(comboBox.m_name, "Jewelry")
    local entry = ZO_ComboBox:CreateItemEntry(item, function()
        if clearedCombobox ~= nil then
            if isJewelry then
                self.jewelryJunkQuality = quality
            else
                self.equipmentJunkQuality = quality
                nameControl:SetColor(SKH.getQualityByValue(quality, 1))
            end
            clearedCombobox:ClearItems()
        else
            if isJewelry then
                self.jewelryDeconstructQuality = quality
            else
                self.equipmentDeconstructQuality = quality
            end
        end
    end)
    entry.index = quality
    comboBox:AddItem(entry)
    if selectedValue == quality then
        comboBox:SetSelectedItemText(item)
    end
end

function EditSetDialogue:initQualityCombobox(comboBox, nameControl, clearedCombobox, leftEdge, selectedValue)
    comboBox:SetSortsItems(false)
    comboBox:SetFont("ZoFontWinT1")
    comboBox:SetSpacing(3)
    local isDeconstruct = string.find(comboBox.m_name, "Deconstruct")
    if leftEdge > 5 then selectedValue = 0 end
    local text = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_NOT_JUNKED_QUALITY)
    if isDeconstruct then
        text = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_NOT_DECONSTRUCT_QUALITY)
    end
    self:createComboboxEntry(comboBox, text, 0, selectedValue, nameControl, clearedCombobox)
    if leftEdge <= 5 then
        for i = leftEdge, 5 do
            self:createComboboxEntry(comboBox, GetString("SI_ITEMQUALITY", i), i, selectedValue, nameControl, clearedCombobox)
        end
    end
    function comboBox:SelectDefault()
        comboBox.m_comboBox:SelectItem(selectedValue)
    end
end

function EditSetDialogue:createSetPartCheckbox(options)
    local itemType, equipType, name, checked, _, offsets = unpack(options)
    local itemBox = WM:CreateControlFromVirtual("$(parent)CB_"..itemType.."_"..equipType, self.optionsControl, "ItemOfSetTemplate")
    local checkBox = itemBox:GetNamedChild("CheckBox")
    itemBox:GetNamedChild("ItemName"):SetText(name)
    itemBox:SetAnchor(TOPLEFT, self.optionsControl, TOPLEFT, offsets[1], offsets[2])
    self.setParts[itemType][equipType] = checked
    if checked == TRUE then ZO_CheckButton_SetChecked(checkBox) else ZO_CheckButton_SetUnchecked(checkBox) end
    ZO_CheckButton_SetToggleFunction(checkBox, function()
        if ZO_CheckButton_IsChecked(checkBox) then
            self.setParts[itemType][equipType] = TRUE
        else
            self.setParts[itemType][equipType] = FALSE
        end
    end)
    return itemBox
end

function EditSetDialogue:ToggleCheckBoxes(preset)
    for _, equipType in ipairs(SKDE.ITEM_PRESETS[preset].equipTypes) do
        local itemType = SKDE.ITEM_PRESETS[preset].itemType
        local itemBox = self.optionsControl:GetNamedChild("CB_"..itemType.."_"..equipType)
        local checkBox = itemBox:GetNamedChild("CheckBox")
        if ZO_CheckButton_IsChecked(checkBox) then
            ZO_CheckButton_SetUnchecked(checkBox)
            self.setParts[itemType][equipType] = FALSE
        else
            ZO_CheckButton_SetChecked(checkBox)
            self.setParts[itemType][equipType] = TRUE
        end
    end
end

function EditSetDialogue:Refresh()
    self.setNameControl:SetColor(SKH.getQualityByValue(self.equipmentJunkQuality, 1))
    local itemEquipment, itemJewelry, textEquipment, textJewelry
    if self.equipmentJunkQuality == 0 then
        textEquipment = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_NOT_JUNKED_QUALITY)
    else
        textEquipment = GetString("SI_ITEMQUALITY", self.equipmentJunkQuality)
    end
    itemEquipment = SK.QUALITY_MAP[self.equipmentJunkQuality]:Colorize(textEquipment)
    self.equipmentJunkQualityComboBox:SetSelectedItemText(itemEquipment)
    self.equipmentDeconstructQualityComboBox:ClearItems()
    if self.jewelryJunkQuality == 0 then
        textJewelry = GetString(SI_SK_AUT_UNWANTED_EDIT_SET_NOT_JUNKED_QUALITY)
    else
        textJewelry = GetString("SI_ITEMQUALITY", self.jewelryJunkQuality)
    end
    itemJewelry = SK.QUALITY_MAP[self.jewelryJunkQuality]:Colorize(textJewelry)
    self.jewelryJunkQualityComboBox:SetSelectedItemText(itemJewelry)
    self.jewelryDeconstructQualityComboBox:ClearItems()
    for itemType, data in pairs(self.setParts) do
        for equipType, checked in pairs(data) do
            local itemBox = self.optionsControl:GetNamedChild("CB_"..itemType.."_"..equipType)
            local checkBox = itemBox:GetNamedChild("CheckBox")
            if checked == TRUE then
                ZO_CheckButton_SetChecked(checkBox)
            else
                ZO_CheckButton_SetUnchecked(checkBox)
            end
        end
    end
end

function EditSetDialogue:Save()
    local _, setName, _, _, _, setId = GetItemLinkSetInfo(self.currentSet)
    if not SKH.isKeyInTable(SK.globalSV.permanentUnwantedSetIds, setId) then
        SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKA, SI_SK_AUT_LOOT_UNWANTED_SETS_ADD, setName)
    end
    local setParts = {}
    local itemLink = SKH.compressItemLink(self.currentSet)
    SKH.objectsDeepCopy(self.setParts, setParts)
    SK.globalSV.permanentUnwantedSetIds[setId] = {
        itemLink = itemLink,
        setParts = setParts,
        quality = self.equipmentJunkQuality,
        deconstructQuality = self.equipmentDeconstructQuality,
        qualityJewelry = self.jewelryJunkQuality,
        deconstructQualityJewelry = self.jewelryDeconstructQuality
    }
    self.currentSet = nil
    if self.isNew then
        self.isNew = false
        SKH.filterAllBackpackJunkSetsParts(SK.globalSV.permanentUnwantedSetIds, SK.savedVars.junkDeconstructedToo)
    end
    SKMD.setsList:Refresh()
    ZO_MenuBar_SelectDescriptor(SKMD.modeBar, SKDC.MAIN_DIALOGUE_UNWANTED_SETS_MODE)
    self:Close()
end

function EditSetDialogue:Close()
    self.control:SetHidden(true)
    self.currentSet = nil
    self.isNew = false
    self.isVisible = false
    if self.needShowPermanentUnwanted then
        self.needShowPermanentUnwanted = false
        SKMD:Open()
    end
end

function EditSetDialogue:Open(itemLink)
	local _, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink)
    local isSetExists = SKH.isKeyInTable(SK.globalSV.permanentUnwantedSetIds, setId)
    if SK.savedVars.showEnSetNameToo then
        setName = SKH.getSetName(itemLink)
    end
    self.setNameControl:SetText(setName)
    self.currentSet = itemLink
    if not isSetExists then
        self.isNew = true
        self:makeDefaultOptions()
    else
        local setParts = SK.globalSV.permanentUnwantedSetIds[setId].setParts
        if setParts then
            self.equipmentJunkQuality = SK.globalSV.permanentUnwantedSetIds[setId].quality
            self.equipmentDeconstructQuality = SK.globalSV.permanentUnwantedSetIds[setId].deconstructQuality
            self.jewelryJunkQuality = SK.globalSV.permanentUnwantedSetIds[setId].qualityJewelry
            self.jewelryDeconstructQuality = SK.globalSV.permanentUnwantedSetIds[setId].deconstructQualityJewelry
            self.setParts = {}
            SKH.objectsDeepCopy(setParts, self.setParts)
        else
            self:makeDefaultOptions()
        end
    end
    self:Refresh()
    self.needShowPermanentUnwanted = SKMD.isVisible
    if self.needShowPermanentUnwanted then SKMD:Close() end

    self.control:ClearAnchors()
    self.control:SetAnchor(TOP, SKMD.control, TOP, 0, 0)
    self.control:SetAnchor(BOTTOM, SKMD.control, BOTTOM, 0, 0)

    self.control:SetHidden(false)
    SetGameCameraUIMode(true)
end

-- ----------------------------------------------------
-- EditAbilityDialogue
-- ----------------------------------------------------
EditAbilityDialogue = ZO_Object:Subclass()
function EditAbilityDialogue:New()
    local object = ZO_Object.New(self)
    return object
end

function EditAbilityDialogue:Initialize(control)
    self.control = control
    self.isVisible = false
    self.currentAbility = nil
    self.needShowWatchedAbility = False
    self.abilityNameControl = self.control:GetNamedChild("HeaderTitle")
    self.abilityIconControl = self.control:GetNamedChild("BodyAbilityIcon")
    self.optionsControl = self.control:GetNamedChild("BodyOptions")
    self.optionsCorrectionIntervalControl = self.optionsControl:GetNamedChild("CorrectionInterval")
    self.optionsDisabledControl = self.optionsControl:GetNamedChild("Disabled")
    self.optionsIsFTControl = self.optionsControl:GetNamedChild("IsFT")
    self.optionsHPControl = self.optionsControl:GetNamedChild("HP")
    self.descriptionControl = self.control:GetNamedChild("BodyDescription")

    local function onCorrectionIntervalEnter(correctionIntervalControl)
        ZO_Tooltips_ShowTextTooltip(correctionIntervalControl, RIGHT, GetString(SI_SK_BATTLE_AC_BLOCK_CORRECTION_INTERVAL_TOOLTIP))
    end
    local function onHPEnter(hpControl)
        ZO_Tooltips_ShowTextTooltip(hpControl, RIGHT, GetString(SI_SK_BATTLE_AC_BLOCK_HP_TOOLTIP))
    end
    local function onDisabledEnter(disabledControl)
        ZO_Tooltips_ShowTextTooltip(disabledControl, RIGHT, GetString(SI_SK_AUT_ABILITY_EDIT_DISABLE_CONTROL_TOOLTIP))
    end
    local function onIsFTEnter(isFTControl)
        ZO_Tooltips_ShowTextTooltip(isFTControl, RIGHT, GetString(SI_SK_AUT_ABILITY_EDIT_FULL_TIME_CONTROL_TOOLTIP))
    end
    local function onControlExit(control)
        ZO_Tooltips_HideTextTooltip()
    end

    local function onAbilityMouseEnter(abilityIconControl)
        local abilityId = SKEA.currentAbility
        local abilityData = SK.globalSV.automationBlockAbilities[abilityId]
        if abilityData.ability ~= nil then abilityId = abilityData.ability end
        local skillType, skillLineIndex, skillIndex, morphChoice = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
        InitializeTooltip(SkillTooltip, abilityIconControl, TOPRIGHT, 0, 0, TOPLEFT)
        SkillTooltip:SetSkillLineAbilityId(abilityId, skillType, skillLineIndex, skillIndex, morphChoice)
    end

    local function onAbilityMouseExit(...)
        ClearTooltip(SkillTooltip)
    end

    self.abilityIconControl:SetHandler("OnMouseEnter", onAbilityMouseEnter)
    self.abilityIconControl:SetHandler("OnMouseExit", onAbilityMouseExit)

    local correctionIntervalControl = self.optionsCorrectionIntervalControl:GetNamedChild("Label")
    correctionIntervalControl:SetHandler("OnMouseEnter", onCorrectionIntervalEnter)
    correctionIntervalControl:SetHandler("OnMouseExit", onControlExit)
    correctionIntervalControl:SetText(GetString(SI_SK_BATTLE_AC_BLOCK_CORRECTION_INTERVAL_NAME))

    local hpControl = self.optionsHPControl:GetNamedChild("Label")
    hpControl:SetHandler("OnMouseEnter", onHPEnter)
    hpControl:SetHandler("OnMouseExit", onControlExit)
    hpControl:SetText(GetString(SI_SK_BATTLE_AC_BLOCK_HP_NAME))

    local disabledControl = self.optionsDisabledControl:GetNamedChild("Label")
    disabledControl:SetHandler("OnMouseEnter", onDisabledEnter)
    disabledControl:SetHandler("OnMouseExit", onControlExit)
    disabledControl:SetText(GetString(SI_SK_AUT_ABILITY_EDIT_DISABLE_CONTROL_NAME))

    local isFTControl = self.optionsIsFTControl:GetNamedChild("Label")
    isFTControl:SetHandler("OnMouseEnter", onIsFTEnter)
    isFTControl:SetHandler("OnMouseExit", onControlExit)
    isFTControl:SetText(GetString(SI_SK_AUT_ABILITY_EDIT_FULL_TIME_CONTROL_NAME))
end

function EditAbilityDialogue:Close()
    self.control:SetHidden(true)
    self.currentAbility = nil
    self.isVisible = false
    if self.needShowWatchedAbility then
        self.needShowWatchedAbility = false
        SKMD:Open()
    end
    local r, g, b = SK.COLOR.WHITE:UnpackRGB()
    self.optionsHPControl:GetNamedChild("Label"):SetColor(r, g ,b, 0.9)
end

function EditAbilityDialogue:Save()
    local success = true
    if self.currentAbilityData.mode == SKDA.CAST_MODES.PHASE then
        local hp = tonumber(self.optionsHPControl:GetNamedChild("Box"):GetText())
        if hp ~= nil and hp <= 100 then
            self.currentAbilityData.hp = hp
            local r, g, b = SK.COLOR.WHITE:UnpackRGB()
            self.optionsHPControl:GetNamedChild("Label"):SetColor(r, g ,b, 0.9)
        else
            success = false
            local r, g, b = SK.COLOR.RED:UnpackRGB()
            self.optionsHPControl:GetNamedChild("Label"):SetColor(r, g ,b, 0.9)
        end
    end
    if success then
        local isChanged = false
        self.currentAbilityData.correctionInterval = tonumber(self.optionsCorrectionIntervalControl:GetNamedChild("Box"):GetText())
        for key, val in pairs(self.currentAbilityData) do
            if SK.globalSV.automationBlockAbilities[self.currentAbility][key] ~= val then
                SK.globalSV.automationBlockAbilities[self.currentAbility][key] = val
                isChanged = true
            end
        end
        for key, _ in pairs(SK.globalSV.automationBlockAbilities[self.currentAbility]) do
            if self.currentAbilityData[key] == nil then
                SK.globalSV.automationBlockAbilities[self.currentAbility][key] = nil
                isChanged = true
            end
        end
        if isChanged then
            SKMD.watchedAbilitiesList:Refresh()
        end
        self:Close()
    end
end

function EditAbilityDialogue:Open(abilityId)
    local isAbilityExists = SKH.isKeyInTable(SK.globalSV.automationBlockAbilities, abilityId)
    if not isAbilityExists then return end
    self.currentAbility = abilityId
    self.currentAbilityData = {}
    local id = abilityId
    SKH.objectsDeepCopy(SK.globalSV.automationBlockAbilities[id], self.currentAbilityData)
    self.control:GetNamedChild("HeaderIcon"):SetTexture(SKDA.MODES_ICONS[self.currentAbilityData.mode])
    if self.currentAbilityData.ability ~= nil then id = self.currentAbilityData.ability end
    local abilityIcon = GetAbilityIcon(id)
    local abilityName = GetAbilityName(id)
    local correctionInterval = self.currentAbilityData.correctionInterval
    local isFT = self.currentAbilityData.isFT
    local hp = self.currentAbilityData.hp
    local disabled = self.currentAbilityData.disabled
    local optionsHeight = 104
    self.abilityNameControl:SetText(abilityName)
    if isFT == nil and hp == nil then optionsHeight = optionsHeight - 28 end
    if hp == nil then
        self.optionsHPControl:SetHidden(true)
    else
        self.optionsHPControl:SetHidden(false)
    end
    if isFT == nil then
        self.optionsIsFTControl:SetHidden(true)
    else
        self.optionsIsFTControl:SetHidden(false)
        local isFTCheckBox = self.optionsIsFTControl:GetNamedChild("CheckBox")
        if isFT == TRUE then ZO_CheckButton_SetChecked(isFTCheckBox) else ZO_CheckButton_SetUnchecked(isFTCheckBox) end
        ZO_CheckButton_SetToggleFunction(isFTCheckBox, function()
            if ZO_CheckButton_IsChecked(isFTCheckBox) then
                self.currentAbilityData.isFT = TRUE
            else
                self.currentAbilityData.isFT = FALSE
            end
        end)
    end
    local isDisabledCheckBox = self.optionsDisabledControl:GetNamedChild("CheckBox")
    if disabled == TRUE then
        ZO_CheckButton_SetChecked(isDisabledCheckBox)
    else
        ZO_CheckButton_SetUnchecked(isDisabledCheckBox)
    end
    ZO_CheckButton_SetToggleFunction(isDisabledCheckBox, function()
        if ZO_CheckButton_IsChecked(isDisabledCheckBox) then
            self.currentAbilityData.disabled = TRUE
        else
            self.currentAbilityData.disabled = FALSE
        end
    end)
    self.abilityIconControl:SetTexture(abilityIcon)
    self.optionsCorrectionIntervalControl:GetNamedChild("Box"):SetText(correctionInterval)
    self.optionsHPControl:GetNamedChild("Box"):SetText(hp)
    self.descriptionControl:SetText(GetAbilityDescription(id))
    local r, g, b = SK.COLOR.LIGHT_YELLOW:UnpackRGB()
    self.descriptionControl:SetColor(r, g ,b, 0.9)
    local _, descriptionHeight = self.descriptionControl:GetDimensions()
    self.optionsControl:SetDimensions(620, optionsHeight)
    self.control:GetNamedChild("Body"):SetDimensions(720, descriptionHeight + optionsHeight + 70)

    self.control:ClearAnchors()
    self.control:SetAnchor(TOP, SKMD.control, TOP, 0, 0)
    self.control:SetAnchor(BOTTOM, SKMD.control, BOTTOM, 0, 0)

    self.control:SetHidden(false)
    self.needShowWatchedAbility = SKMD.isVisible
    if self.needShowWatchedAbility then SKMD:Close() end
    SetGameCameraUIMode(true)
end


-- ----------------------------------------------------
-- BankTransferDialogue
-- ----------------------------------------------------
BankTransferDialogue = ZO_Object:Subclass()
function BankTransferDialogue:New()
    local object = ZO_Object.New(self)
    return object
end

function BankTransferDialogue:Initialize(control)
    self.control = control
    self.isGuildBankOpened = false
    self.isEventRegistered = false
    self.isVisible = false
    self.denyTransfer = true
    self.transferTimeoutMultiplier = 1
    self.progress = 0
    self.maxProgress = 450
    self.transferQueue = {}
    self.uncompressQueue = {}
    self.rawMaterialsList = {}
    self.dataIndex = 0
    self.guildBankControl = WM:GetControlByName("ZO_GuildBank")
    self.guildBankMenuControl = WM:GetControlByName("ZO_GuildBankMenu")
    self.guildBankControls = {
        self.guildBankControl:GetNamedChild("Tabs"),
        self.guildBankControl:GetNamedChild("SearchFilters"),
        self.guildBankControl:GetNamedChild("SortBy"),
        self.guildBankControl:GetNamedChild("Backpack"),
    }
    self.guildBankIsVisible = false
    self.playerInventoryControl = WM:GetControlByName("ZO_PlayerInventory")
    self.playerInventoryControls = {
        self.playerInventoryControl:GetNamedChild("Tabs"),
        self.playerInventoryControl:GetNamedChild("SearchFilters"),
        self.playerInventoryControl:GetNamedChild("SortBy"),
        self.playerInventoryControl:GetNamedChild("List"),
    }
    self.nameControl = self.control:GetNamedChild("HeaderTitle")
    self.nameControl:SetText(GetString(SI_BINDING_NAME_SK_BANK))
    self.mainControl = self.control:GetNamedChild("Main")
    self.emptyLabel = self.mainControl:GetNamedChild("Status")
    self.statusBar = self.mainControl:GetNamedChild("StatusBar")
    self.transferTitle = self.mainControl:GetNamedChild("Title")
    self.columns = {
        [1] = self.mainControl:GetNamedChild("FirstColumn"),
        [2] = self.mainControl:GetNamedChild("SecondColumn")
    }
    self.buttonControls = {
        self.mainControl:GetNamedChild("Deposit"),
        self.mainControl:GetNamedChild("Compress"),
        self.mainControl:GetNamedChild("Withdraw")
    }
    self.stopControl = self.mainControl:GetNamedChild("Stop")
    self:createTransferCheckboxes()
    ZO_StatusBar_SetGradientColor(self.statusBar, ZO_SKILL_XP_BAR_GRADIENT_COLORS)
    self.statusBar:SetWidth(self.maxProgress)
end

function BankTransferDialogue:createTransferCheckbox(parentControl, key)
    local checkBoxControl = WM:CreateControlFromVirtual("sk_bank_"..key, parentControl, "SK_Checkbox")
    local checkBox = checkBoxControl:GetNamedChild("CheckBox")
    local r, g, b = SK.COLOR.LIGHT_BLUE:UnpackRGB()
    local parentLabel = parentControl:GetNamedChild("Label")
    local parentWidth, parentHeight, parentOffsetX = nil, 10, -8
    if parentLabel ~= nil then
        parentOffsetX = 0
        parentWidth, parentHeight = parentLabel:GetDimensions()
    end
    local name = SKDI.BANK_TRANSFER_OPTIONS.names[key]
    if SKH.isValueInList(SKDI.BANK_TRANSFER_OPTIONS.withdraw, key) then
        name = name.." "..SK.COLOR.LIGHT_YELLOW:Colorize("*")
    end
    checkBoxControl:GetNamedChild("Label"):SetText(name)
    checkBoxControl:GetNamedChild("Label"):SetColor(r, g, b, 0.9)
    checkBoxControl:SetAnchor(TOPLEFT, parentControl, BOTTOMLEFT, parentOffsetX, parentHeight + 10)
    if SK.savedVars.bankTransferOptions[key] then
        ZO_CheckButton_SetChecked(checkBox)
    else
        ZO_CheckButton_SetUnchecked(checkBox)
    end
    ZO_CheckButton_SetToggleFunction(checkBox, function()
        SK.savedVars.bankTransferOptions[key] = ZO_CheckButton_IsChecked(checkBox)
    end)
    return checkBoxControl
end

function BankTransferDialogue:createTransferCheckboxes()
    local parentControl = self.columns[1]
    local cutter = math.floor(#SKDI.BANK_TRANSFER_OPTIONS.order / 2) + 2
    for id, key in pairs(SKDI.BANK_TRANSFER_OPTIONS.order) do
        if id == cutter then parentControl = self.columns[2] end
        parentControl = self:createTransferCheckbox(parentControl, key)
    end
    local helpTextControl = self.mainControl:GetNamedChild("HelpText")
    helpTextControl:SetText(SK.COLOR.LIGHT_YELLOW:Colorize("*")..' '..GetString(SI_SK_BANK_TRANSFER_HELP))
    local parentLabel = parentControl:GetNamedChild("Label")
    local _, parentHeight = parentLabel:GetDimensions()
    helpTextControl:SetAnchor(TOPLEFT, parentControl, BOTTOMLEFT, 10, parentHeight + 10)
    helpTextControl:SetHidden(false)
end

function BankTransferDialogue:Open()
    if not self.isGuildBankOpened then return end
    if self.control:IsControlHidden() then
        self.isVisible = true
        self.denyTransfer = false
        self.progress = 0
        self.dataIndex = 0
        self.guildBankMenuControl:SetHidden(true)
        if not self.guildBankControl:IsControlHidden() then
            self.guildBankIsVisible = true
            for _, control in ipairs(self.guildBankControls) do
                if not control:IsControlHidden() then control:SetHidden(true) end
            end
        else
            self.guildBankIsVisible = false
            for _, control in ipairs(self.playerInventoryControls) do
                if not control:IsControlHidden() then control:SetHidden(true) end
            end
        end
        self.control:SetHidden(false)
    end
end

function BankTransferDialogue:calcTransferDelay()
    local calcLatency = math.floor((GetLatency() + SK.savedVars.minTransferLatency) / 2)
    local latency = math.max(GetLatency() - 50, SK.savedVars.minTransferLatency)
    SK.savedVars.minTransferLatency = calcLatency
    return self.transferTimeoutMultiplier * latency
end

function BankTransferDialogue:updateTimeoutMultiplier(isError)
    if isError then
        if self.transferTimeoutMultiplier < 10 then
            self.transferTimeoutMultiplier = self.transferTimeoutMultiplier + 1
        end
    elseif self.transferTimeoutMultiplier > 1 then
        self.transferTimeoutMultiplier = self.transferTimeoutMultiplier - 1
    end
end

function BankTransferDialogue:setProgress(value)
    if value ~= nil and value > 0 then
        if not self.emptyLabel:IsControlHidden() then self.emptyLabel:SetHidden(true) end
        if self.statusBar:IsControlHidden() then self.statusBar:SetHidden(false) end
        self.statusBar:GetNamedChild("Progress"):SetText(string.format("%.1f", (value / self.maxProgress) * 100) .. "%")
        ZO_StatusBar_SmoothTransition(self.statusBar, value, self.maxProgress)
    else
        ZO_StatusBar_SmoothTransition(self.statusBar, 0, self.maxProgress)
        if not self.statusBar:IsControlHidden() then self.statusBar:SetHidden(true) end
        if self.emptyLabel:IsControlHidden() then self.emptyLabel:SetHidden(false) end
    end
end

function BankTransferDialogue:blockButtons(flag)
    for _, control in ipairs(self.buttonControls) do
        control:SetHidden(flag)
    end
    self.stopControl:SetHidden(not flag)
end

function BankTransferDialogue:writeResultMessage(message, isError)
    self.progress = 0
    self.dataIndex = 0
    self:setProgress()
    if isError then message = SK.COLOR.RED:Colorize(message) end
    self.emptyLabel:SetText(message)
    self.transferTitle:SetText("")
    self:blockButtons(false)
end

function BankTransferDialogue:unregisterForEvents()
    if self.isEventRegistered then
        EM:UnregisterForEvent("SK_BANK", EVENT_GUILD_BANK_TRANSFER_ERROR)
        EM:UnregisterForEvent("SK_BANK", EVENT_GUILD_BANK_ITEM_ADDED)
        EM:UnregisterForEvent("SK_BANK", EVENT_GUILD_BANK_ITEM_REMOVED)
        self.isEventRegistered = false
    end
end

function BankTransferDialogue:transferOneSlot(data)
    local message, soundCategory
    local slotIndex = data.slotIndex
    local transferDirection = data.direction
    if transferDirection == SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK then
        TransferToGuildBank(BAG_BACKPACK, slotIndex)
        soundCategory = GetItemSoundCategory(BAG_BACKPACK, slotIndex)
        message = GetString(SI_SK_AUT_TRANSFER_MESSAGE)
    elseif transferDirection == SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK then
        TransferFromGuildBank(slotIndex)
        soundCategory = GetItemSoundCategory(BAG_GUILDBANK, slotIndex)
        message = GetString(SI_SK_AUT_TRANSFER_BACK_MESSAGE)
    end
    self.transferTitle:SetText(SKH.getFormattedText(message, data.itemLink:gsub("%|H0", "|H1")))
    PlayItemSound(soundCategory, ITEM_SOUND_ACTION_PICKUP)
    ClearCursor()
end

function BankTransferDialogue:startTransferQueue(transferDirection)
    if self.denyTransfer then return end
    if transferDirection == SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK and GetNumBagFreeSlots(BAG_GUILDBANK) == 0 then
        self:unregisterForEvents()
        self:writeResultMessage(GetString(SI_SK_AUT_NO_SPACE_IN_BANK), true)
        return
    end
    if transferDirection == SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK and GetNumBagFreeSlots(BAG_BACKPACK) == 0 then
        self:unregisterForEvents()
        self:writeResultMessage(GetString(SI_SK_AUT_NO_SPACE_IN_BAG), true)
        return
    end
    for idx, data in pairs(self.transferQueue) do
        if not data.complete then
            self.dataIndex = idx
            self:transferOneSlot(data)
            break
        end
    end
end

function BankTransferDialogue:isBothDirectionItem(transferOptions, itemLink, itemType, itemQuality, traitType, specializedItemType)
    local itemTypesGlyphs = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.GLYPHS]
    local itemTypesIntricate = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.INTRICATE]
    local itemTypesResources = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.RESOURCES]
    local _, _, _, _, itemStyle = GetItemLinkInfo(itemLink)
    local res = (transferOptions.glyphs and SKH.isValueInList(itemTypesGlyphs, itemType)) or
        (transferOptions.intricate and SKH.isValueInList(itemTypesIntricate, traitType)) or
        (transferOptions.resources and SKH.isValueInList(itemTypesResources, itemType)) or
        (transferOptions.non_gold_resources and SKH.isValueInList(itemTypesResources, itemType) and itemQuality < 5) or
        (transferOptions.gold_resources and SKH.isValueInList(itemTypesResources, itemType) and itemQuality == 5) or
        (transferOptions.recipe and itemType == ITEMTYPE_RECIPE) or
        (transferOptions.master_writs and itemType == ITEMTYPE_MASTER_WRIT) or
        (transferOptions.style_motifs and itemType == ITEMTYPE_RACIAL_STYLE_MOTIF) or
        (transferOptions.style_pages and (specializedItemType == 82 or specializedItemType == 852)) or
        (transferOptions.crafted_white and IsItemLinkCrafted(itemLink) and itemQuality <= 1 and
            (itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON)) or
        (transferOptions.worth_stylish and itemType == ITEMTYPE_STYLE_MATERIAL and
            SKH.isValueInList(SKDI.ITEM_WORTHLESS_RACIAL, itemStyle))
    return res
end

function BankTransferDialogue:isWithdrawItem(transferOptions, itemLink, itemType, itemQuality, traitType, bagId, slotIndex, minimalStackSize)
    local itemTypesGlyphs = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.GLYPHS]
    local itemTypesIntricate = SKDI.ITEM_TYPES[SK.ATTACHMENT_TYPES.INTRICATE]
    local itemTypesRawMaterials = SKDI.RAW_MATERIALS
    local stackSize = GetSlotStackSize(bagId, slotIndex)
    local itemId = GetItemInstanceId(bagId, slotIndex)
    local res = (transferOptions.training_craft and (SKH.isValueInList(itemTypesIntricate, traitType) or
            (SKH.isValueInList(itemTypesGlyphs, itemType) and itemQuality <= SK.savedVars.useGlyphsForCraftTrainingQuality)) and
            SKH.canBeUseForCraftTraining(bagId, slotIndex)) or
        (transferOptions.raw_materials and SKH.isValueInList(itemTypesRawMaterials, itemType) and
            ((self.rawMaterialsList[itemId] ~= nil and self.rawMaterialsList[itemId].quantity ~= nil and
                self.rawMaterialsList[itemId].quantity + stackSize >= minimalStackSize) or (
                self.rawMaterialsList[itemId] == nil and stackSize >= minimalStackSize))) or
        (transferOptions.unknown_style_motifs and itemType == ITEMTYPE_RACIAL_STYLE_MOTIF and
            not IsItemLinkBookKnown(itemLink)) or
        (transferOptions.unknown_style_pages and (specializedItemType == 82 or specializedItemType == 852) and
            not IsItemLinkBookKnown(itemLink)) or
        (transferOptions.unknown_recipe and itemType == ITEMTYPE_RECIPE and not IsItemLinkRecipeKnown(itemLink))
    return res
end

function BankTransferDialogue:fillTransferQueue(transferDirection)
    local idx = 1
    self.uncompressQueue = {}
    self.transferQueue = {}
    if transferDirection == SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK then
        local transferOptions = SK.savedVars.bankTransferOptions
        local transferToCache = {}
        local bagId = BAG_BACKPACK
        local slotsCount = GetBagSize(bagId)
        for slotIndex = 0, slotsCount - 1 do
            if not IsItemStolen(bagId, slotIndex) and not IsItemBound(bagId, slotIndex) then
                local itemId = GetItemInstanceId(bagId, slotIndex)
                local itemLink = GetItemLink(bagId, slotIndex)
                local itemType, specializedItemType = GetItemLinkItemType(itemLink)
                local itemQuality = GetItemLinkFunctionalQuality(itemLink)
                local traitType = GetItemLinkTraitInfo(itemLink)
                if itemType ~= ITEMTYPE_NONE and self:isBothDirectionItem(transferOptions, itemLink, itemType, itemQuality, traitType, specializedItemType) then
                    self.transferQueue[idx] = {
                        slotIndex = slotIndex,
                        itemLink = itemLink,
                        itemId = itemId,
                        direction = transferDirection,
                        complete = false
                    }
                    local stackSize, maxStackSize = GetSlotStackSize(bagId, slotIndex)
                    if stackSize < maxStackSize then transferToCache[itemId] = idx end
                    idx = idx + 1
                end
            end
        end
        if idx > 1 then
            local withCompress = false
    		local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
            for _, slot in pairs(bagToScan) do
                local stackSize, maxStackSize = GetSlotStackSize(slot.bagId, slot.slotIndex)
                if stackSize < maxStackSize then
                    idx = transferToCache[slot.itemInstanceId]
                    if idx ~= nil then
                        if self.transferQueue[idx].slotsGB == nil then self.transferQueue[idx].slotsGB = {} end
                        SKH.setTableChild(self.transferQueue, {idx, "slotsGB", slot.slotIndex}, false)
                        withCompress = true
                    end
                end
            end
            if withCompress then
                for i, data in pairs(self.transferQueue) do
                    self.uncompressQueue[i] = data
                    if data.slotsGB ~= nil then
                        self.uncompressQueue[i].direction = SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK
                    else
                        self.uncompressQueue[i].slotsBP = {[data.slotIndex] = false}
                    end
                    self.uncompressQueue[i].slotIndex = nil
                end
                if SK.savedVars.debugMode then
                    d("uncompress queue start ========")
                    d(self.uncompressQueue)
                    d("uncompress queue end ==========")
                end
                self.transferQueue = {}
            end
        end
    elseif transferDirection == SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK then
        local transferOptions = SK.savedVars.bankTransferOptions
        if transferOptions.raw_materials then self.rawMaterialsList = SKH.getPotentialRefineMaterials() end
        local minimalStackSize = GetRequiredSmithingRefinementStackSize()
        local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
        for _, slot in pairs(bagToScan) do
            local bagId = slot.bagId
            local slotIndex = slot.slotIndex
            local itemLink = GetItemLink(bagId, slotIndex)
            local itemType, specializedItemType = GetItemLinkItemType(itemLink)
            local itemQuality = GetItemLinkFunctionalQuality(itemLink)
            local traitType = GetItemLinkTraitInfo(itemLink)
            if itemType ~= ITEMTYPE_NONE and itemType ~= ITEMTYPE_NONE and self:isBothDirectionItem(transferOptions, itemLink, itemType, itemQuality, traitType, specializedItemType) or
                self:isWithdrawItem(transferOptions, itemLink, itemType, itemQuality, traitType, bagId, slotIndex, minimalStackSize)
            then
                self.transferQueue[idx] = {
                    slotIndex = slotIndex,
                    itemLink = itemLink,
                    direction = transferDirection,
                    complete = false
                }
                idx = idx + 1
		    end
        end
    end
    if SK.savedVars.debugMode then
        d("transfer queue start ========")
        d(self.transferQueue)
        d("transfer queue end ==========")
    end
end

function BankTransferDialogue:checkTransferPermission(transferDirection)
    local res = true
    local guildId = GetSelectedGuildBankId()
    if transferDirection == SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK then
        if not DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT) then
            res = false
            self:writeResultMessage(GetString(SI_SK_AUT_NO_DEPOSIT_PERMISSION), true)
        end
    elseif transferDirection == SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK then
		if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_BANK_WITHDRAW) then
            res = false
            self:writeResultMessage(GetString(SI_SK_AUT_NO_WITHDRAW_PERMISSION), true)
        end
    end
    return res
end

function BankTransferDialogue:startTransfer(transferDirection)
    if not self:checkTransferPermission(transferDirection) then return end
    self:fillTransferQueue(transferDirection)
    self.maxProgress = #self.transferQueue
    if self.maxProgress > 0 then
        if SK.savedVars.debugMode then d("start transfer queue") end
        self:setProgress(self.progress)
        local function onSlotUpdateError(...)
            self:updateTimeoutMultiplier(true)
            zo_callLater(function() self:startTransferQueue(transferDirection) end, self:calcTransferDelay())
        end
        local function onSlotUpdated(...)
            self.progress = self.dataIndex
            self:setProgress(self.progress)
            self.transferQueue[self.dataIndex].complete = true
            if self.progress == self.maxProgress then
                self.transferTimeoutMultiplier = 1
                self:unregisterForEvents()
                self:writeResultMessage(GetString(SI_SK_AUT_TRANSFER_COMPLETE))
                return
            elseif self.transferTimeoutMultiplier > 1 then
                self:updateTimeoutMultiplier(false)
            end
            zo_callLater(function() self:startTransferQueue(transferDirection) end, self:calcTransferDelay())
        end
        if not self.isEventRegistered then
            self.isEventRegistered = true
            EM:RegisterForEvent("SK_BANK", EVENT_GUILD_BANK_TRANSFER_ERROR, onSlotUpdateError)
            EM:RegisterForEvent("SK_BANK", EVENT_GUILD_BANK_ITEM_ADDED, onSlotUpdated)
            EM:RegisterForEvent("SK_BANK", EVENT_GUILD_BANK_ITEM_REMOVED, onSlotUpdated)
        end
        self:startTransferQueue(transferDirection)
    else
        self.maxProgress = #self.uncompressQueue
        if self.maxProgress > 0 then
            if SK.savedVars.debugMode then d('start transfer compress queue') d(self.uncompressQueue) end
            self:compressGuildBank(GetString(SI_SK_AUT_TRANSFER_COMPLETE))
        else
            self:writeResultMessage(GetString(SI_SK_AUT_NO_TRANSFER_ITEM))
        end
    end
end

function BankTransferDialogue:fillUncompressQueue()
    if not (self:checkTransferPermission(SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK) or
        self:checkTransferPermission(SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK)
    ) then return end
    local guildBankNonFullStackItems = {}
    local bagToScan = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_GUILDBANK)
    for _, slot in pairs(bagToScan) do
        local stackSize, maxStackSize = GetSlotStackSize(slot.bagId, slot.slotIndex)
        if stackSize ~= maxStackSize then
            local itemLink = GetItemLink(slot.bagId, slot.slotIndex)
            SKH.setTableChild(guildBankNonFullStackItems, {slot.itemInstanceId, "itemLink"}, itemLink)
            SKH.createTableChild(guildBankNonFullStackItems, {slot.itemInstanceId, "slots"})
            guildBankNonFullStackItems[slot.itemInstanceId].slots[slot.slotIndex] = false
            local slotsCount = guildBankNonFullStackItems[slot.itemInstanceId].slotsCount
            if slotsCount == nil then slotsCount = 0 end
            guildBankNonFullStackItems[slot.itemInstanceId].slotsCount = slotsCount + 1
        end
    end
    self.uncompressQueue = {}
    local idx = 1
    for itemId, data in pairs(guildBankNonFullStackItems) do
        if data.slotsCount > 1 then
            self.uncompressQueue[idx] = {
                itemId = itemId,
                itemLink = data.itemLink,
                slotsGB = data.slots,
                direction = SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK,
                complete = false
            }
            idx = idx + 1
        end
    end
end

function BankTransferDialogue:compressItemsForRollback(itemId)
    local res = {}
    local bagId = BAG_BACKPACK
    local toSlot, toSlotQuantity, toSlotMaxStack
    local slotsCount = GetBagSize(bagId)
    for i = 0, slotsCount - 1 do
        if GetItemInstanceId(bagId, i) == itemId and not IsItemStolen(bagId, i) and not IsItemBound(bagId, i) then
            if toSlot == nil then
                toSlotQuantity, toSlotMaxStack = GetSlotStackSize(bagId, i)
                if toSlotQuantity < toSlotMaxStack then toSlot = i end
                res[i] = false
            else
                local fromSlotQuantity = GetSlotStackSize(bagId, i)
                local transferQuantity
                if fromSlotQuantity + toSlotQuantity <= toSlotMaxStack then
                    transferQuantity = fromSlotQuantity
                    CallSecureProtected("RequestMoveItem", bagId, i, bagId, toSlot, transferQuantity)
                    toSlotQuantity = toSlotQuantity + transferQuantity
                    res[toSlot] = false
                else
                    transferQuantity = toSlotMaxStack - toSlotQuantity
                    CallSecureProtected("RequestMoveItem", bagId, i, bagId, toSlot, transferQuantity)
                    toSlotQuantity = fromSlotQuantity - transferQuantity
                    toSlot = i
                    res[i] = false
                end
            end
        end
    end
    return res
end

function BankTransferDialogue:transferCompressQueue(message)
    if self.denyTransfer then return end
    for idx, data in pairs(self.uncompressQueue) do
        if not data.complete then
            local transferSlotIndex
            if data.direction == SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK then
                for slotIndex, flag in pairs(data.slotsGB) do
                    if not flag then
                        transferSlotIndex = slotIndex
                        break
                    end
                end
            end
            if not transferSlotIndex and data.slotsBP == nil then
                self.transferTitle:SetText(SKH.getFormattedText(GetString(SI_SK_AUT_COMPRESS_MESSAGE), data.itemLink:gsub("%|H0", "|H1")))
                self.uncompressQueue[idx].slotsBP = self:compressItemsForRollback(data.itemId)
                self.uncompressQueue[idx].direction = SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK
                zo_callLater(function() self:transferCompressQueue(message) end, self:calcTransferDelay())
                break
            end
            if data.direction == SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK then
                for slotIndex, flag in pairs(data.slotsBP) do
                    if not flag then
                        transferSlotIndex = slotIndex
                        break
                    end
                end
            end
            if transferSlotIndex then
                self.dataIndex = idx
                self:transferOneSlot(
                    {
                        slotIndex = transferSlotIndex,
                        direction = data.direction,
                        itemLink = data.itemLink
                    }
                )
                break
            else
                self.uncompressQueue[idx].complete = true
                if self.progress == self.maxProgress then
                    self.transferTimeoutMultiplier = 1
                    self.dataIndex = 0
                    self:unregisterForEvents()
                    if message == nil then message = GetString(SI_SK_AUT_COMPRESS_COMPLETE) end
                    self:writeResultMessage(message)
                end
            end
        end
    end
end

function BankTransferDialogue:transferToGuildBank()
    self:blockButtons(true)
    self:startTransfer(SK.TRANSFER_DIRECTIONS.TO_GUILD_BANK)
end

function BankTransferDialogue:compressGuildBank(message)
    self:blockButtons(true)
    if message == nil then self:fillUncompressQueue() end
    if #self.uncompressQueue > 0 then
        self.maxProgress = #self.uncompressQueue * 2
        self:setProgress(self.progress)
        local function onSlotUpdateError(text, errorCode)
            self:updateTimeoutMultiplier(true)
            zo_callLater(function() self:transferCompressQueue(message) end, self:calcTransferDelay())
        end
        local function onSlotUpdated(_, slotIndex, _, _, _)
            if self.uncompressQueue[self.dataIndex].direction == SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK then
                self.uncompressQueue[self.dataIndex].slotsGB[slotIndex] = true
                self.progress = self.dataIndex * 2 - 1
            else
                for idx, flag in pairs(self.uncompressQueue[self.dataIndex].slotsBP) do
                    if not flag then
                        self.uncompressQueue[self.dataIndex].slotsBP[idx] = true
                        self.progress = self.dataIndex * 2
                        break
                    end
                end
            end
            self:updateTimeoutMultiplier(false)
            self:setProgress(self.progress)
            zo_callLater(function() self:transferCompressQueue(message) end, self:calcTransferDelay())
        end
        if not self.isEventRegistered then
            self.isEventRegistered = true
            EM:RegisterForEvent("SK_BANK", EVENT_GUILD_BANK_TRANSFER_ERROR, onSlotUpdateError)
            EM:RegisterForEvent("SK_BANK", EVENT_GUILD_BANK_ITEM_ADDED, onSlotUpdated)
            EM:RegisterForEvent("SK_BANK", EVENT_GUILD_BANK_ITEM_REMOVED, onSlotUpdated)
        end
        self:transferCompressQueue(message)
    else
        self:writeResultMessage(GetString(SI_SK_AUT_NO_COMPRESS_NEED))
    end
end

function BankTransferDialogue:transferFromGuildBank()
    self:blockButtons(true)
    self:startTransfer(SK.TRANSFER_DIRECTIONS.FROM_GUILD_BANK)
end

function BankTransferDialogue:stopAll()
    self.transferQueue = {}
    self.uncompressQueue = {}
    self:unregisterForEvents()
    self:writeResultMessage(GetString(SI_SK_BANK_NOTHING_TODO_MESSAGE))
end

function BankTransferDialogue:Close()
    self.denyTransfer = true
    self:stopAll()
    if not self.control:IsControlHidden() then
        if self.guildBankIsVisible then
            for _, control in ipairs(self.guildBankControls) do
                if control:IsControlHidden() then control:SetHidden(false) end
            end
            PLAYER_INVENTORY:RefreshAllGuildBankItems()
        else
            for _, control in ipairs(self.playerInventoryControls) do
                if control:IsControlHidden() then control:SetHidden(false) end
            end
            PLAYER_INVENTORY:RefreshAllInventorySlots(INVENTORY_BACKPACK)
        end
        self.guildBankMenuControl:SetHidden(not self.isGuildBankOpened)
        self.control:SetHidden(true)
    end
    self.isVisible = false
end

function BankTransferDialogue:Toggle()
    if self.control:IsControlHidden() then
        self:Open()
    else
        self:Close()
    end
end

-- ----------------------------------------------------
-- MainDialogue external API
-- ----------------------------------------------------

local function refreshTrackedSetItems(isCallLater)
    if isCallLater and not isFirstLoadUpdate then return end
    SKH.updateTrackedSetItems()
    SKH.conditionalRefreshSetsItemsList()
    SKH.sendMessageToChat(SK.COLORED_PREFIXES.SKW, SI_SK_AUT_UPDATE_TRACKED_ITEMS_COMPLETE)
    isFirstLoadUpdate = false
end

local function InitMainDialogue()
    if SKMD == nil then
        SKMD = MainDialogue:New()
        SKMD:Initialize(MainDialogueWindow)
        SKMD.needRefreshAfterOpen = true
        SKMD.setsList:Refresh()
        SKMD.itemsList:Refresh()
        SKMD.notBindItemsList:Refresh()
        if SK.savedVars.trackSetsItems then
            zo_callLater(function() refreshTrackedSetItems(true) end,
                    SK.timeoutTrackedSetsItemsDataLoad
            )
        end
        SKMD.watchedAbilitiesList:Refresh()
        SKMD.trackedAbilitiesList:Refresh()
        if SKEUS == nil then
            SKEUS = EditSetDialogue:New()
            SKEUS:Initialize(UnwantedSetEdit)
        end
        if SKEA == nil then
            SKEA = EditAbilityDialogue:New()
            SKEA:Initialize(AbilityEdit)
        end
        if SKBT == nil then
            SKBT = BankTransferDialogue:New()
            SKBT:Initialize(BankTransfer)
        end
    end
end

-- Export
SK.CustomDialogs = SK.CustomDialogs or {}
SK.CustomDialogs.refreshTrackedSetItems = refreshTrackedSetItems
SK.CustomDialogs.InitMainDialogue = InitMainDialogue
SK.CustomDialogs.InitInfoDialogue = InitInfoDialogue
