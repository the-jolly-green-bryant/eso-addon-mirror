AddonCategory = AddonCategory or {}
local AddonCategory = AddonCategory

AddonCategory.name = "AddonCategory"
AddonCategory.version = "1.5.3"

local sV

local ADDON_DATA = 1
local SECTION_HEADER_DATA = 2

local IS_LIBRARY = true
local IS_ADDON = false

local AddOnManager = GetAddOnManager()

local expandedAddons = {}

local g_uniqueNamesByCharacterName = {}
local function CreateAddOnFilter(characterName)
    local uniqueName = g_uniqueNamesByCharacterName[characterName]
    if not uniqueName then
        uniqueName = GetUniqueNameForCharacter(characterName)
        g_uniqueNamesByCharacterName[characterName] = uniqueName
    end
    return uniqueName
end

local function StripText(text)
    return text:gsub("|c%x%x%x%x%x%x", "")
end

local function BuildMasterList(self)
    self.addonTypes = {}
    self.addonTypes[IS_LIBRARY] = {}
    self.addonTypes[IS_ADDON] = {}
    for key, value in pairs(sV.listCategory) do
        self.addonTypes[value] = {}
    end

    if self.selectedCharacterEntry and not self.selectedCharacterEntry.allCharacters then
        self.isAllFilterSelected = false
        AddOnManager:SetAddOnFilter(CreateAddOnFilter(self.selectedCharacterEntry.name))
    else
        self.isAllFilterSelected = true
        AddOnManager:RemoveAddOnFilter()
    end

    AddonCategory.listAddons = {}
    AddonCategory.listLibraries = {}
    AddonCategory.listNonAssigned = {}
    for i = 1, AddOnManager:GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = AddOnManager:GetAddOnInfo(i)
        if isLibrary ~= IS_LIBRARY then
            AddonCategory.listAddons[i] = name
        else
            AddonCategory.listLibraries[i] = name
        end

        local entryData = {
            index = i,
            addOnFileName = name,
            addOnName = title,
            strippedAddOnName = StripText(title),
            addOnDescription = description,
            addOnEnabled = enabled,
            addOnState = state,
            isOutOfDate = isOutOfDate,
            isLibrary = isLibrary,
            isCustomCategory = false,
            dependsOn = {}
        }
		
		if sV[name] ~= nil then
			entryData.isCustomCategory = true
        elseif isLibrary ~= IS_LIBRARY then
            table.insert(AddonCategory.listNonAssigned, name)
		end

        if author ~= "" then
            local strippedAuthor = StripText(author)
            entryData.addOnAuthorByLine = zo_strformat(SI_ADD_ON_AUTHOR_LINE, author)
            entryData.strippedAddOnAuthorByLine = zo_strformat(SI_ADD_ON_AUTHOR_LINE, strippedAuthor)
        else
            entryData.addOnAuthorByLine = ""
            entryData.strippedAddOnAuthorByLine = ""
        end

        local dependencyText = ""
        for j = 1, AddOnManager:GetAddOnNumDependencies(i) do
            local dependencyName, dependencyExists, dependencyActive, dependencyMinVersion, dependencyVersion = AddOnManager:GetAddOnDependencyInfo(i, j)
            local dependencyTooLowVersion = dependencyVersion < dependencyMinVersion        
            
            local dependencyInfoLine = dependencyName
            if not self.isAllFilterSelected and (not dependencyActive or not dependencyExists or dependencyTooLowVersion) then
                entryData.hasDependencyError = true
                if not dependencyExists then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_MISSING, dependencyName)
                elseif not dependencyActive then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_DISABLED, dependencyName)
                elseif dependencyTooLowVersion then
                    dependencyInfoLine = zo_strformat(SI_ADDON_MANAGER_DEPENDENCY_TOO_LOW_VERSION, dependencyName)
                end
                dependencyInfoLine = ZO_ERROR_COLOR:Colorize(dependencyInfoLine)
            end
            dependencyText = string.format("%s\n    %s  %s", dependencyText, GetString(SI_BULLET), dependencyInfoLine)
        end
        entryData.addOnDependencyText = dependencyText

        entryData.expandable = (description ~= "") or (dependencyText ~= "")

        if entryData.isCustomCategory == true then
            table.insert(self.addonTypes[sV[name]], entryData)
        else
            table.insert(self.addonTypes[isLibrary], entryData)
        end
    end
end

local libraryText = nil
local _AddAddonTypeSection = ADD_ON_MANAGER.AddAddonTypeSection
local function AddAddonTypeSection(self, isLibrary, sectionTitleText)

    local customCategory = false

    for key, value in pairs(sV.listCategory) do
        if value == isLibrary then 
            customCategory = true
            break
        end
    end

    if customCategory == true or isLibrary == true then
        local addonEntries = self.addonTypes[isLibrary]
        table.sort(addonEntries, self.sortCallback)

        local scrollData = ZO_ScrollList_GetDataList(self.list)
        local titleText = isLibrary
        if isLibrary == true then
            titleText = sectionTitleText
            libraryText = sectionTitleText
        end
        scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(SECTION_HEADER_DATA, { isLibrary = isLibrary, text = titleText })
        for _, entryData in ipairs(addonEntries) do
            if sV.sectionsOpen[sectionTitleText] == nil or sV.sectionsOpen[sectionTitleText] == true then
                if entryData.expandable and expandedAddons[entryData.index] then
                    entryData.expanded = true

                    local useHeight, typeId = self:SetupTypeId(entryData.addOnDescription, entryData.addOnDependencyText)

                    entryData.height = useHeight
                    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(typeId, entryData)
                else
                    entryData.height = ZO_ADDON_ROW_HEIGHT
                    scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(ADDON_DATA, entryData)
                end
            end
        end
    else
        _AddAddonTypeSection(self, isLibrary, sectionTitleText)
    end
end

local cptToolbar = 0
local sectionsHeader = {}
local sectionsEnable = {}
local _SetupSectionHeaderRow = ADD_ON_MANAGER.SetupSectionHeaderRow
local function SetupSectionHeaderRow(self, control, data)
    local customCategory = false

    for key, value in pairs(sV.listCategory) do
        if value == data.isLibrary then 
            customCategory = true
            break
        end
    end

    if customCategory == true or data.isLibrary == true then
        local previousText = control.textControl:GetText()
        control.textControl:SetText(data.text)
        control.checkboxControl:SetHidden(true)

        cptToolbar = cptToolbar + 1
        control.toolBar = CreateControlFromVirtual("$(parent)ToolBar" .. cptToolbar, control, "ZO_MenuBarTemplate")
        control.toolBar:ClearAnchors()
        control.toolBar:SetAnchor(BOTTOMRIGHT, control.textControl, BOTTOMRIGHT, 65, 4)
    
        ZO_MenuBar_OnInitialized(control.toolBar)
        local barData = {
            buttonPadding = -4,
            normalSize = 28,
            downSize = 28,
            animationDuration = DEFAULT_SCENE_TRANSITION_TIME,
            buttonTemplate = "ZO_MenuBarTooltipButton"
        }
        ZO_MenuBar_SetData(control.toolBar, barData)
        ZO_MenuBar_SetClickSound(control.toolBar, "DEFAULT_CLICK")


        local function CreateButtonData(tooltipString, nb, icon, functionCallback)
            return {
                activeTabText = data.text,
                categoryName = data.text,
                CustomTooltipFunction = function(tooltip)
                    SetTooltipText(tooltip, tooltipString .. " all addons of " .. data.text)
                end,
                tooltip = "tooltip",
                alwaysShowTooltip = true,
                descriptor = nb,
                normal = "esoui/art/buttons/" .. icon .. "_up.dds",
                pressed = "esoui/art/buttons/" .. icon .. "_up.dds",
                highlight = "esoui/art/buttons/" .. icon .. "_over.dds",
                disabled = "esoui/art/buttons/" .. icon .. "_down.dds",
                callback = function(tabData)
                    functionCallback(tabData)

                    control.toolBar:SetHidden(true)
                    ADD_ON_MANAGER:RefreshData()
                    ZO_MenuBar_ClearSelection(control.toolBar)
                    PlaySound(SOUNDS.DEFAULT_CLICK)
                end
            }
        end

        local function callbackEnableDisable(tabData)
            if sectionsEnable[data.text] == nil then
                sectionsEnable[data.text] = false
            end
            local textTrueFalse = "false"
            if sectionsEnable[data.text] == true then
                textTrueFalse = "true"
            end
            if data.text == libraryText then 
                for key, value in pairs(AddonCategory.listLibraries) do
                    AddOnManager:SetAddOnEnabled(key, sectionsEnable[data.text])
                end
            else 
                for key, value in pairs(AddonCategory.listAddons) do
                    if sV[value] == data.text then
                        AddOnManager:SetAddOnEnabled(key, sectionsEnable[data.text])
                    end
                end
            end
            sectionsEnable[data.text] = not sectionsEnable[data.text]
            ADD_ON_MANAGER.isDirty = true
            --ADD_ON_MANAGER:RefreshMultiButton()
        end
        local function callbackShowHide(tabData)
            if sV.sectionsOpen[data.text] == nil then
                sV.sectionsOpen[data.text] = true
            end
            sV.sectionsOpen[data.text] = not sV.sectionsOpen[data.text]
        end
    
        local iconEnableDisable = "edit_cancel"
        local stringEnableDisable = "Disable"
        if sectionsEnable[data.text] == true then
            iconEnableDisable = "accept"
            stringEnableDisable = "Enable"
        end
        local iconShowHide = "large_rightarrow"
        local stringShowHide = "Hide"
        if sV.sectionsOpen[data.text] == false then
            iconShowHide = "large_downarrow"
            stringShowHide = "Show"
        end
        ZO_MenuBar_AddButton(control.toolBar, CreateButtonData(stringShowHide, 1, iconShowHide, callbackShowHide))
        ZO_MenuBar_AddButton(control.toolBar, CreateButtonData(stringEnableDisable, 2, iconEnableDisable, callbackEnableDisable))

        control.toolBar:SetHidden(false)
        local rowNb = control:GetName():gsub("ZO_AddOnsList2Row", "")
        if sectionsHeader[rowNb] ~= nil then
            sectionsHeader[rowNb]:SetHidden(true)
        end
        sectionsHeader[rowNb] = control.toolBar

        ZO_MenuBar_ClearSelection(control.toolBar)
    else
        if control.toolBar then
            control.toolBar:SetHidden(true)
        end
        _SetupSectionHeaderRow(self, control, data)
    end
end

AddonCategory.indexCategories = {}
local function SortScrollList(self)
    self:ResetDataTypes()
    local scrollData = ZO_ScrollList_GetDataList(self.list)        
    ZO_ClearNumericallyIndexedTable(scrollData)

    self:AddAddonTypeSection(IS_ADDON, GetString(SI_WINDOW_TITLE_ADDON_MANAGER))
    for i=1, #sV.listCategory do
        for key, value in pairs(AddonCategory.listAddons) do
            if sV[value] == sV.listCategory[i] then 
                self:AddAddonTypeSection(sV.listCategory[i], sV.listCategory[i])
                break
            end
        end
    end
    self:AddAddonTypeSection(IS_LIBRARY, GetString(SI_ADDON_MANAGER_SECTION_LIBRARIES))

    local newScrollData = ZO_ScrollList_GetDataList(self.list)
    for key, value in pairs(newScrollData) do
        for i=1, #sV.listCategory do
            if sV.listCategory[i] == value.data.isLibrary then 
                AddonCategory.indexCategories[sV.listCategory[i]] = key
            end
        end
        if value.data.isLibrary == IS_LIBRARY then
            AddonCategory.indexCategories[GetString(SI_ADDON_MANAGER_SECTION_LIBRARIES)] = key
        end
    end
end

local function OnExpandButtonClicked(self, row)
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    local data = ZO_ScrollList_GetData(row)

    if expandedAddons[data.index] then
        expandedAddons[data.index] = false

        data.expanded = false
        data.height = ZO_ADDON_ROW_HEIGHT
        scrollData[data.sortIndex] = ZO_ScrollList_CreateDataEntry(ADDON_DATA, data)
    else
        expandedAddons[data.index] = true

        local useHeight, typeId = self:SetupTypeId(data.addOnDescription, data.addOnDependencyText)

        data.expanded = true
        data.height = useHeight
        scrollData[data.sortIndex] = ZO_ScrollList_CreateDataEntry(typeId, data)
    end

    self:CommitScrollList()
end

ADD_ON_MANAGER.BuildMasterList = BuildMasterList
ADD_ON_MANAGER.AddAddonTypeSection = AddAddonTypeSection
ADD_ON_MANAGER.SetupSectionHeaderRow = SetupSectionHeaderRow
ADD_ON_MANAGER.SortScrollList = SortScrollList
ADD_ON_MANAGER.OnExpandButtonClicked = OnExpandButtonClicked

function AddonCategory.AssignAddonToCategory(addonName, categoryName)
    for _, name in pairs(AddonCategory.baseCategories) do
        if name == categoryName then
            if not sV then
                zo_callLater(function() 
                    if sV[addonName] == nil then
                        sV[addonName] = categoryName
                    end
                end, 3 * 1000)
            else
                if sV[addonName] == nil then
                    sV[addonName] = categoryName
                end
            end
        end
    end
end

function AddonCategory.getIndexOfCategory(categoryName)
    return AddonCategory.indexCategories[categoryName]
end

----------
-- INIT --
----------
function AddonCategory:Initialize()
	--Saved Variables
	AddonCategory.savedVariables = ZO_SavedVars:NewAccountWide("AddonCategoryVariables", 1, nil, AddonCategory.defaultSV)
	sV = AddonCategory.savedVariables

	--Settings
    ADD_ON_MANAGER.BuildMasterList(self)
	AddonCategory.CreateSettingsWindow()

	EVENT_MANAGER:UnregisterForEvent(AddonCategory.name, EVENT_ADD_ON_LOADED)
end

function AddonCategory.OnAddOnLoaded(event, addonName)
	if addonName ~= AddonCategory.name then return end
    AddonCategory:Initialize()
end

EVENT_MANAGER:RegisterForEvent(AddonCategory.name, EVENT_ADD_ON_LOADED, AddonCategory.OnAddOnLoaded)