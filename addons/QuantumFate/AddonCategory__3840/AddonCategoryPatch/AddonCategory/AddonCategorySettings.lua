AddonCategory = AddonCategory or {}
local AddonCategory = AddonCategory

local LAM2 = LibAddonMenu2

local arrayLength = {}

local function getArrayCategoriesLength()
    arrayLength = {}
    for i=1, #AddonCategory.savedVariables.listCategory do
        table.insert(arrayLength, i)
    end
end


local function UpdateAllChoices()
    getArrayCategoriesLength()

    Categories_dropdown:UpdateChoices()
    CategoriesName_dropdown:UpdateChoices()
    CategoriesOrder_dropdown:UpdateChoices()
    NewOrder_dropdown:UpdateChoices()
end

function AddonCategory.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "AddonCategory",
		displayName = "AddonCategory",
		author = "Floliroy",
		version = AddonCategory.version,
		slashCommand = "/addoncategory",
		registerForRefresh = true,
		registerForDefaults = false,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("AddonCategory_Settings", panelData)
    local sV = AddonCategory.savedVariables

    local addon, category, newCategory, categoryName, newCategoryName, categoryOrder, newOrder

    local addonsList = {}
    for key, value in pairs(AddonCategory.listAddons) do
        table.insert(addonsList, value)
    end
    table.sort(addonsList, function (a, b) return a < b end)
    getArrayCategoriesLength()
	
	local optionsData = {
		{
			type = "header",
			name = "Link Addon to Category",
		},
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
        {
            type = "dropdown",
			name = "List Addons",
			tooltip = "List of all of your non librairies addons.",
			choices = addonsList,
			default = addonsList[1],
			getFunc = function() return addon end,
			setFunc = function(selected)
				for index, name in ipairs(addonsList) do
					if name == selected then
						addon = name
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "Addon_dropdown",
        },
        {
            type = "dropdown",
			name = "List Categories",
			tooltip = "List of the categories of addons you have.",
			choices = sV.listCategory,
			default = sV.listCategory[1],
			getFunc = function() return category end,
			setFunc = function(selected)
				for index, name in ipairs(sV.listCategory) do
					if name == selected then
						category = name
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "Categories_dropdown",
        },
        {
            type = "button",
            name = "Select Non Assigned",
            tooltip = "Select first addon installed non assigned to a category.",
            func = function()
                for i, v in ipairs(AddonCategory.listNonAssigned) do
                    addon = v
                    break
                end
                Addon_dropdown:UpdateValue()
            end,
            disabled = function() return #AddonCategory.listNonAssigned <= 0 end,
			width = "half",
            reference = "AddonNonAssigned_button",
        },
        {
            type = "button",
            name = "Link Between",
            tooltip = "Link the selected addon with the selected category.",
            func = function()
                if addon ~= nil and category ~= nil then
                    sV[addon] = category
                    d("Addon |cFFFFFF" .. addon .. "|r linked to |cFFFFFF" .. category .. "|r category.")

                    for i, v in ipairs(AddonCategory.listNonAssigned) do
                        if v == addon then
                            table.remove(AddonCategory.listNonAssigned, i)
                            addon = nil
                            Addon_dropdown:UpdateValue()
                            break
                        end
                    end
                    AddonNonAssigned_button:UpdateDisabled()
                end
            end,
			width = "half",
        },
		{
			type = "header",
			name = "Edit Categories",
		},
        {
            type = "dropdown",
			name = "Choose Category",
			tooltip = "Choose a Category to edit it name.",
			choices = sV.listCategory,
			default = sV.listCategory[1],
			getFunc = function() return categoryName end,
			setFunc = function(selected)
				for index, name in ipairs(sV.listCategory) do
					if name == selected then
						categoryName = name
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "CategoriesName_dropdown",
        },
        {
            type = "editbox",
            name = "Category New Name",
            tooltip = "Enter here the new category's name you want.",
            getFunc = function() return nil end,
            setFunc = function(newValue) 
                if newValue ~= nil and newValue ~= "" then
                    newCategoryName = newValue
                end
            end,
			width = "half",
        },
        {
            type = "button",
            name = "Change Name",
            tooltip = "Change the name of the selected category to the new one.",
            func = function()
                if categoryName ~= nil and newCategoryName ~= nil then
                    for key, value in pairs(sV.listCategory) do
                        if value == newCategoryName then 
                            d("Category's name |cFFFFFF" .. newCategoryName .. "|r already present.\nUnable to edit...")
                            newCategoryName = nil
                            return 
                        end
                    end

                    for key, value in pairs(sV.listCategory) do
                        if value == categoryName then 
                            sV.listCategory[key] = newCategoryName
                            break
                        end
                    end
                    for key, value in pairs(AddonCategory.listAddons) do
                        if sV[value] == categoryName then 
                            sV[value] = newCategoryName
                        end
                    end
                    
                    UpdateAllChoices()
                end
            end,
        },
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
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "CategoriesOrder_dropdown",
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
					end
				end
			end,
            scrollable = true,
			width = "half",
            reference = "NewOrder_dropdown",
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
	}
	
	LAM2:RegisterOptionControls("AddonCategory_Settings", optionsData)
end