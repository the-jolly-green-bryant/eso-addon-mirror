AddonCategory = AddonCategory or {}
local AddonCategory = AddonCategory
local MAJOR = AddonCategory.name

local LAM2 = LibAddonMenu2
local LSM = LibScrollableMenu

local GetAddonCategories = AddonCategory.GetAddonCategories
local ChangeAddonCategoryName = AddonCategory.ChangeAddonCategoryName


local arrayLength = {}
local addonsList = {}
local categoryList = {}
local categoryListIndex = {}

local function GetAddonsByList()
    local l_addonsList = {}
    for _, value in pairs(AddonCategory.listAddons) do
        table.insert(l_addonsList, value)
    end
    table.sort(l_addonsList, function (a, b) return string.lower(a) < string.lower(b) end)
    return l_addonsList
end

local function getArrayCategoriesLength()
    arrayLength = {}
    for i=1, #AddonCategory.savedVariables.listCategory do
        table.insert(arrayLength, i)
    end
end

local function updateNeededTables()
    addonsList = GetAddonsByList()
    getArrayCategoriesLength()
    categoryList = GetAddonCategories(false)
    categoryListIndex = GetAddonCategories(true)
end

local function updateComboBoxChoices(lamDropdownControl)
    local choices, choicesValues
    if lamDropdownControl == AddonCategory_Addon_dropdown then
        choices = addonsList
    elseif lamDropdownControl == AddonCategory_Categories_dropdown then
        choices = categoryList
        choicesValues = categoryListIndex
    elseif lamDropdownControl == AddonCategory_CategoriesName_dropdown then
        choices = categoryList
        choicesValues = categoryListIndex
    end
    lamDropdownControl:UpdateChoices(choices, choicesValues, nil)
    local comboBox = lamDropdownControl.combobox.m_comboBox
    if comboBox == nil then return end
    comboBox:SetSelectedItemText("")
    comboBox.m_selectedItemData = nil
end

local function UpdateAllChoices()
    updateNeededTables()
    updateComboBoxChoices(AddonCategory_Addon_dropdown)
    updateComboBoxChoices(AddonCategory_Categories_dropdown)
    updateComboBoxChoices(AddonCategory_CategoriesName_dropdown)
    --CategoriesOrder_dropdown:UpdateChoices()
    --NewOrder_dropdown:UpdateChoices()
end

function AddonCategory.OpenLAMSettingsMenu()
    if AddonCategory.LAMsettingsPanel == nil then return end
    LAM2:OpenToPanel(AddonCategory.LAMsettingsPanel)
    UpdateAllChoices()
end

local function UpdateDisabledStateOfLinkCategoryButtons()
    AddonCategory_AddonNonAssigned_button:UpdateDisabled()
    AddonCategory_AddonLink_button:UpdateDisabled()
end

local firstOpenOfLAMPanel = true
function AddonCategory.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "AddonCategory",
		displayName = "AddonCategory",
		author = AddonCategory.author,
		version = AddonCategory.version,
		slashCommand = "/addoncategory",
		registerForRefresh = true,
		registerForDefaults = false,
	}
    local addonCategoryLAMPanelName = "AddonCategory_Settings"

	AddonCategory.LAMsettingsPanel = LAM2:RegisterAddonPanel(addonCategoryLAMPanelName, panelData)
    local sV = AddonCategory.savedVariables

    local addon, category, newCategory, categoryName, newCategoryName, categoryOrder, newOrder, categoryIndex, categoryToChangeIndex
    --Call once here to init the tables
    updateNeededTables()


	local optionsData = {
		{
			type = "header",
			name = "Categories",
		},
        {
            type    = "orderlistbox",
            name    = "Categories - Add/Remove/Order",
            tooltip = "Add, remove and change the order of the addon categories",
            listEntries = sV.listCategory,
            getFunc = function() return sV.listCategory end,
            setFunc = function(orderedList)
                sV.listCategory = orderedList
            end,
            minHeight = 100,
            maxHeight = 300,
            width = "full",
            isExtraWide = true,
            showPosition = true,
            disabled = function() return false end,
            default = AddonCategory.defaultSV.listCategory,
            addEntryDialog = {
                title="Add new category",
                text="Enter new category name here",
                textType=TEXT_TYPE_ALL,
                --buttonTexture="/esoui/art/buttons/minus_up.dds",
                --maxInputCharacters=3,
                --specialCharacters={"a", "b", "c"},
                --defaultText = "Default text",
                --instructions = ZO_ValidNameInstructions:New(GetControl(self, "NameInstructions"), nil, { NAME_RULE_TOO_SHORT, NAME_RULE_CANNOT_START_WITH_SPACE, NAME_RULE_MUST_END_WITH_LETTER })
                validatesText = true,
                validator = function(text) return text ~= nil and text ~= "" end
            },
            showRemoveEntryButton = true,
            askBeforeRemoveEntry = function() return true end,
            removeEntryCheckFunction = function(orderListBox, selectedIndex, orderListBoxData)
                return AddonCategory.DeleteCategoryCheckFunction(selectedIndex)
            end,
            removeEntryCallbackFunction = function(orderListBox, selectedEntry, orderListBoxData)
                if selectedEntry == nil then return false end
                --local selectedEntryIndex = selectedEntry.uniqueKey
                local selectedEntryCategoryName = selectedEntry.text
                AddonCategory.indexCategories[selectedEntryCategoryName] = nil

                categoryIndex         = nil
                categoryToChangeIndex = nil
                categoryName          = nil
                newCategoryName       = nil

                UpdateAllChoices()
                UpdateDisabledStateOfLinkCategoryButtons()
            end,
            addEntryCallbackFunction = function(orderListBox, newEntry, orderListBoxData)
                if newEntry == nil then return false end

                categoryIndex         = nil
                categoryToChangeIndex = nil
                categoryName          = nil
                newCategoryName       = nil

                --local newEntryIndex = newEntry.uniqueKey
                UpdateAllChoices()
                UpdateDisabledStateOfLinkCategoryButtons()
            end,
        },


		{
			type = "header",
			name = "Link Addon to Category",
		},
        --[[
        {
            type = "editbox",
            name = "Create New Category",
            tooltip = "Enter here the new category's name you want.",
            getFunc = function() return nil end,
            setFunc = function(newValue) 
                if newValue ~= nil and newValue ~= "" then
                    newCategory = newValue
                end
            end,
        },
        {
            type = "button",
            name = "Add Category",
            tooltip = "Add a new category with the name you typed above.",
            func = function()
                if newCategory ~= nil and newCategory ~= "" then
                    for key, value in pairs(sV.listCategory) do
                        if value == newCategory then 
                            d("Category's name |cFFFFFF" .. value .. "|r already present.\nUnable to add...")
                            newCategory = nil
                            return 
                        end
                    end

                    table.insert(sV.listCategory, newCategory)
                    UpdateAllChoices()
                end
            end,
        },

        {
            type = "button",
            name = "Delete Category",
            tooltip = "Delete the selected category below.",
            func = function()
                if category ~= nil then
                    for _, name in pairs(AddonCategory.baseCategories) do
                        if name == category then
                            d("You can't delete category |cFFFFFF" .. category .. "|r.\nThis is a base category...")
                            return
                        end
                    end     
                    for key, value in pairs(AddonCategory.listAddons) do
                        if sV[value] == category then 
                            d("Addons are present in the category |cFFFFFF" .. category .. "|r.\nUnable to delete...")
                            return 
                        end
                    end               

                    for i, v in ipairs(sV.listCategory) do
                        if v == category then
                            table.remove(sV.listCategory, i)
                            break
                        end
                    end

                    UpdateAllChoices()
                end
            end,
        },
        ]]

        {
            type = "dropdown",
            name = "List Addons",
            tooltip = "List of all of your non-library addons.",
            choices = addonsList,
            default = function() return addonsList ~= nil and addonsList[1] or nil end,
            getFunc = function() return addon end,
            setFunc = function(selected)
                for _, name in ipairs(addonsList) do
                    if name == selected then
                        addon = name
                        return
                    end
                end
            end,
            scrollable = true,
            width = "half",
            reference = "AddonCategory_Addon_dropdown",
        },
        {
            type = "dropdown",
            name = "List Categories",
            tooltip = "List of the categories of addons you have.",
            choices = categoryList,
            choicesValues = categoryListIndex,
            default = 1,
            getFunc = function() return categoryIndex end,
            setFunc = function(selectedIndex)
                categoryIndex = selectedIndex
                categoryToChangeIndex = nil
            end,
            scrollable = true,
            width = "half",
            reference = "AddonCategory_Categories_dropdown",
        },
        {
            type = "button",
            name = "Select Non Assigned",
            tooltip = "Select first addon installed non assigned to a category.",
            func = function()
                for _, v in ipairs(AddonCategory.listNonAssigned) do
                    addon = v
                    break
                end
                AddonCategory_Addon_dropdown:UpdateValue()
            end,
            disabled = function() return #AddonCategory.listNonAssigned <= 0 end,
			width = "half",
            reference = "AddonCategory_AddonNonAssigned_button",
        },
        {
            type = "button",
            name = "Link Between",
            tooltip = "Link the selected addon with the selected category.",
            func = function()
                if addon ~= nil and categoryIndex ~= nil then
                    local l_categoryName = sV.listCategory[categoryIndex] ~= nil and sV.listCategory[categoryIndex].text or nil

                    categoryIndex         = nil
                    categoryToChangeIndex = nil
                    categoryName          = nil
                    newCategoryName       = nil

                    if l_categoryName ~= nil then
                        sV[addon] = l_categoryName
                        d("Addon |cFFFFFF" .. addon .. "|r linked to |cFFFFFF" .. l_categoryName .. "|r category.")

                        for i, v in ipairs(AddonCategory.listNonAssigned) do
                            if v == addon then
                                table.remove(AddonCategory.listNonAssigned, i)
                                addon = nil
                                AddonCategory_Addon_dropdown:UpdateValue()
                                break
                            end
                        end
                        --AddonCategory_AddonNonAssigned_button:UpdateDisabled() --Should auto update disabled state due to panel registerForRefresh = true
                    end
                end
            end,
			width = "half",
            disabled = function() return addon == nil or categoryIndex == nil end,
            reference = "AddonCategory_AddonLink_button"
        },
		{
			type = "header",
			name = "Edit Categories",
		},
        {
            type = "dropdown",
			name = "Choose Category",
			tooltip = "Choose a category to edit it's name.",
            choices = categoryList,
            choicesValues = categoryListIndex,
			default = 1,
			getFunc = function() return categoryToChangeIndex end,
			setFunc = function(indexToChange)
                categoryToChangeIndex = indexToChange
                categoryName = sV.listCategory[categoryToChangeIndex].text

                categoryIndex = nil
			end,
            scrollable = true,
			width = "half",
            reference = "AddonCategory_CategoriesName_dropdown",
        },
        {
            type = "editbox",
            name = "Category New Name",
            tooltip = "Enter here the new category's name you want.",
            getFunc = function() return nil end,
            setFunc = function(newValue)
                newCategoryName = nil
                if newValue ~= nil and newValue ~= "" then
                    newCategoryName = newValue
                end
            end,
            disabled = function() return categoryToChangeIndex == nil end,
			width = "half",
        },
        {
            type = "button",
            name = "Change Name",
            tooltip = "Change the name of the selected category to the new one.",
            func = function()
                if categoryToChangeIndex ~= nil and categoryName ~= nil and newCategoryName ~= nil then
                    ChangeAddonCategoryName(categoryToChangeIndex, categoryName, newCategoryName)

                    categoryName = nil
                    newCategoryName = nil
                    categoryToChangeIndex = nil

                    UpdateAllChoices()
                end
            end,
            disabled = function() return categoryToChangeIndex == nil or categoryName == nil or categoryName == "" or newCategoryName == nil or newCategoryName == "" end,
        },

        --[[
        {
            type = "dropdown",
			name = "Choose Category",
			tooltip = "Choose a category to change it order.",
			choices = sV.listCategory,
			default = sV.listCategory[1],
			getFunc = function() return categoryOrder end,
			setFunc = function(selected)
				for index, name in ipairs(sV.listCategory) do
					if name == selected then
						categoryOrder = name
                        break
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "AddonCategory_CategoriesOrder_dropdown",
        },
        {
            type = "dropdown",
			name = "New Order",
			tooltip = "Choose a new order for the selected category.",
			choices = arrayLength,
			default = arrayLength[1],
			getFunc = function() return newOrder end,
			setFunc = function(selected)
				for index, name in ipairs(arrayLength) do
					if name == selected then
						newOrder = name
                        break
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "AddonCategory_NewOrder_dropdown",
        },
        {
            type = "button",
            name = "Change Order",
            tooltip = "Change the order of the selected category to the new one.",
            func = function()
                if categoryOrder ~= nil and newOrder ~= nil then
                    local oldOrder, oldCategory
                    for key, value in pairs(sV.listCategory) do
                        if value == categoryOrder then
                            oldOrder = key
                        end
                        if key == newOrder then
                            oldCategory = value
                        end
                    end

                    for key, value in pairs(sV.listCategory) do
                        if key == oldOrder then
                            sV.listCategory[key] = oldCategory
                        end
                        if key == newOrder then
                            sV.listCategory[key] = categoryOrder
                        end
                    end

                    UpdateAllChoices()
                end
            end,
        },
        ]]
    }

	LAM2:RegisterOptionControls(addonCategoryLAMPanelName, optionsData)

    local function openedPanel(panel)
        if panel ~= AddonCategory.LAMsettingsPanel then return end
        if firstOpenOfLAMPanel == true then
            firstOpenOfLAMPanel = false
            return
        end
        UpdateAllChoices()
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", openedPanel)
end