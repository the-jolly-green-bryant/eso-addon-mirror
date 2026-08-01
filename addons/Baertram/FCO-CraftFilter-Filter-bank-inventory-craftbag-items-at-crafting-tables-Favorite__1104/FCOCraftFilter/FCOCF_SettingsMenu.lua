local FCOCF = FCOCF

------------------------------------------------------------------------------------------------------------------------
--Local reference variables etc.
------------------------------------------------------------------------------------------------------------------------
--Libraries
local LAM = LibAddonMenu2
local libSets = LibSets
local LSM = LibScrollableMenu

local tos = tostring

local buildCustomSetFavoriteCategoryNames = FCOCF.BuildCustomSetFavoriteCategoryNames
local getCustomSetFavoriteCategoryName = FCOCF.GetCustomSetFavoriteCategoryName

------------------------------------------------------------------------------------------------------------------------
--Local helper functions
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- FCOCraftFilter - LAM settings menu
------------------------------------------------------------------------------------------------------------------------

-- Build the options menu
local function BuildAddonMenu()
    local addonVars = FCOCF.addonVars
    local settings = FCOCF.settingsVars.settings
    local defaults = FCOCF.settingsVars.defaults
    local localizationVars = FCOCF.localizationVars.FCOCF_loc

    local possibleCraftingTypeTabDropdownEntries = FCOCF.possibleCraftingTypeTabDropdownEntries
    local possibleCraftingTypeTabDropdownEntriesValues = FCOCF.possibleCraftingTypeTabDropdownEntriesValues

    local customMasterCrafterSetStationFavoriteIds = FCOCF.customMasterCrafterSetStationFavoriteIds
    --local customMasterCrafterSetStationFavoriteIdToNameDefaults = FCOCF.customMasterCrafterSetStationFavoriteIdToNameDefaults
    local customMasterCrafterSetStationFavoriteIdToName = FCOCF.customMasterCrafterSetStationFavoriteIdToName
    local customMasterCrafterSetStationNameToFavoriteId = FCOCF.customMasterCrafterSetStationNameToFavoriteId
    --local customMasterCrafterSetStationFavoriteIdToTexture = FCOCF.customMasterCrafterSetStationFavoriteIdToTexture


    libSets = libSets or LibSets
    LSM = LSM or LibScrollableMenu


    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= addonVars.addonVersionOptions,
        website             = addonVars.addonWebsite,
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand = "/fcocfs",
    }

-- !!! RU Patch Section START
--  Add english language description behind language descriptions in other languages
	local function nvl(val) if val == nil then return "..." end return val end
	local LV_Cur = localizationVars
	local LV_Eng = FCOCF.localizationVars.localizationAll[1]
	local languageOptions = {}
	for i=1, FCOCF.numVars.languageCount do
		local s="options_language_dropdown_selection"..i
		if LV_Cur==LV_Eng then
			languageOptions[i] = nvl(LV_Cur[s])
		else
			languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
		end
	end
-- !!! RU Patch Section END
    --Create "Master Crafter Tables" set favorites
    buildCustomSetFavoriteCategoryNames()

    local savedVariablesOptions = {
        [1] = localizationVars["options_savedVariables_dropdown_selection1"],
        [2] = localizationVars["options_savedVariables_dropdown_selection2"],
    }



    --The LAM settings panel
    FCOCF.LAMSettingsPanel = LAM:RegisterAddonPanel(addonVars.gAddonName .. "_LAMPanel", panelData)

    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'description',
            text = localizationVars["options_description"],
        },

        --==============================================================================
        {
            type = 'header',
            name = localizationVars["options_header1"],
        },
        {
            type = 'dropdown',
            name = localizationVars["options_language"],
            tooltip = localizationVars["options_language_tooltip"],
            choices = languageOptions,
            getFunc = function() return languageOptions[FCOCF.settingsVars.defaultSettings.language] end,
            setFunc = function(value)
                for i,v in pairs(languageOptions) do
                    if v == value then
                        FCOCF.settingsVars.defaultSettings.language = i
                        --Tell the settings that you have manually chosen the language and want to keep it
                        --Read in function Localization() after ReloadUI()
                        settings.languageChoosen = true
                        --localizationVars			  	 = localizationVars[i]
                        --ReloadUI()
                    end
                end
            end,
           disabled = function() return settings.alwaysUseClientLanguage end,
           warning = localizationVars["options_language_description1"],
           requiresReload = true,
        },
		{
			type = "checkbox",
			name = localizationVars["options_language_use_client"],
			tooltip = localizationVars["options_language_use_client_tooltip"],
			getFunc = function() return settings.alwaysUseClientLanguage end,
			setFunc = function(value)
				settings.alwaysUseClientLanguage = value
                      --ReloadUI()
		            end,
            default = defaults.alwaysUseClientLanguage,
            warning = localizationVars["options_language_description1"],
            requiresReload = true,
		},
        {
            type = 'dropdown',
            name = localizationVars["options_savedvariables"],
            tooltip = localizationVars["options_savedvariables_tooltip"],
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[FCOCF.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        FCOCF.settingsVars.defaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
            end,
            warning = localizationVars["options_language_description1"],
        },
        --==============================================================================
        {
            type = 'header',
            name = localizationVars["options_header_crafting_stations"],
        },
        {
            type = "checkbox",
            name = localizationVars["options_enable_medium_filter"],
            tooltip = localizationVars["options_enable_medium_filter_tooltip"],
            getFunc = function() return settings.enableMediumFilters end,
            setFunc = function(value) settings.enableMediumFilters = value
            end,
            default = defaults.enableMediumFilters,
            width="full",
        },
        {
            type = "checkbox",
            name = localizationVars["options_enable_only_worn_filter"],
            tooltip = localizationVars["options_enable_only_worn_filter_TT"],
            getFunc = function() return settings.enableOnlyWornFilters end,
            setFunc = function(value) settings.enableOnlyWornFilters = value
            end,
            default = defaults.enableOnlyWornFilters,
            width="full",
        },
        {
            type = "checkbox",
            name = localizationVars["options_show_only_worn_at_only_invetory"],
            tooltip = localizationVars["options_show_only_worn_at_only_invetory_TT"],
            getFunc = function() return settings.showWornItemsAtOnlyInventory end,
            setFunc = function(value) settings.showWornItemsAtOnlyInventory = value
            end,
            default = defaults.showWornItemsAtOnlyInventory,
            width="full",
        },
        {
            type = 'header',
            name = localizationVars["options_header_research"],
        },
        {
            type = "checkbox",
            name = localizationVars["options_enable_button_only_currently_researched"],
            tooltip = localizationVars["options_enable_button_only_currently_researched_tooltip"],
            getFunc = function() return settings.showButtonResearchOnlyCurrentlyResearched end,
            setFunc = function(value) settings.showButtonResearchOnlyCurrentlyResearched = value
            end,
            default = defaults.showButtonResearchOnlyCurrentlyResearched,
            width="full",
        },
        {
            type = 'header',
            name = localizationVars["options_header_defaultCraftTab"],
        },
        {
            type = "checkbox",
            name = localizationVars["options_defaultCraftTab_enable"],
            tooltip = localizationVars["options_defaultCraftTab_enable_TT"],
            getFunc = function() return settings.defaultCraftTabDescriptorEnabled end,
            setFunc = function(value) settings.defaultCraftTabDescriptorEnabled = value
            end,
            default = defaults.defaultCraftTabDescriptorEnabled,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_ALCHEMY]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_ALCHEMY],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_ALCHEMY],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_ALCHEMY] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_ALCHEMY] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_ALCHEMY],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_PROVISIONING]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_PROVISIONING],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_PROVISIONING],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_PROVISIONING] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_PROVISIONING] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_PROVISIONING],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_ENCHANTING]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_ENCHANTING],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_ENCHANTING],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_ENCHANTING] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_ENCHANTING] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_ENCHANTING],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_BLACKSMITHING]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_BLACKSMITHING],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_BLACKSMITHING],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_BLACKSMITHING] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_BLACKSMITHING] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_BLACKSMITHING],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_CLOTHIER]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_CLOTHIER],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_CLOTHIER],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_CLOTHIER] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_CLOTHIER] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_CLOTHIER],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_WOODWORKING]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_WOODWORKING],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_WOODWORKING],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_WOODWORKING] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_WOODWORKING] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_WOODWORKING],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(_G["SI_TRADESKILLTYPE" .. CRAFTING_TYPE_JEWELRYCRAFTING]),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries[CRAFTING_TYPE_JEWELRYCRAFTING],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues[CRAFTING_TYPE_JEWELRYCRAFTING],
            getFunc = function() return settings.defaultCraftTabDescriptor[CRAFTING_TYPE_JEWELRYCRAFTING] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor[CRAFTING_TYPE_JEWELRYCRAFTING] = value
            end,
            default = defaults.defaultCraftTabDescriptor[CRAFTING_TYPE_JEWELRYCRAFTING],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = GetString(SI_RETRAIT_STATION_HEADER),
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries["retrait"],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues["retrait"],
            getFunc = function() return settings.defaultCraftTabDescriptor["retrait"] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor["retrait"] = value
                --[[
                retraitStationTabs = retraitStationTabs or retraitStation.tabs
                if retraitStationTabs ~= nil then
                    retraitStationTabs:SetStartingFragment(retraitStation[value].categoryName)
                end
                ]]
            end,
            default = defaults.defaultCraftTabDescriptor["retrait"],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        {
            type = "dropdown",
            name = "Universal Deconstruction",
            --tooltip = GetString(),
            choices = possibleCraftingTypeTabDropdownEntries["universalDeconstruction"],
            choicesValues = possibleCraftingTypeTabDropdownEntriesValues["universalDeconstruction"],
            getFunc = function() return settings.defaultCraftTabDescriptor["universalDeconstruction"] end,
            setFunc = function(value) settings.defaultCraftTabDescriptor["universalDeconstruction"] = value
            end,
            default = defaults.defaultCraftTabDescriptor["universalDeconstruction"],
            disabled = function() return not settings.defaultCraftTabDescriptorEnabled end,
            width="full",
        },
        --==============================================================================
        {
            type = 'header',
            name = localizationVars["options_header_grandmaster_crafting"],
        },
        {
            type = "checkbox",
            name = localizationVars["options_multisets_create_enable_favorites"],
            tooltip = localizationVars["options_multisets_create_enable_favorites"],
            getFunc = function() return settings.enableMasterCrafterSetsFavorites end,
            setFunc = function(value) settings.enableMasterCrafterSetsFavorites = value
            end,
            default = defaults.enableMasterCrafterSetsFavorites,
            width="full",
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = localizationVars["options_multisets_LibSets_favorites"],
            tooltip = localizationVars["options_multisets_LibSets_favorites"],
            getFunc = function() return settings.enableMasterCrafterSetsLibSetsFavorites end,
            setFunc = function(value) settings.enableMasterCrafterSetsLibSetsFavorites = value
            end,
            default = defaults.enableMasterCrafterSetsLibSetsFavorites,
            width="half",
            disabled = function() return not settings.enableMasterCrafterSetsFavorites or not LSM or not libSets end,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = localizationVars["options_multisets_LibSets_favorites_only"],
            tooltip = localizationVars["options_multisets_LibSets_favorites_only"],
            getFunc = function() return settings.enableMasterCrafterSetsLibSetsFavoritesOnly end,
            setFunc = function(value) settings.enableMasterCrafterSetsLibSetsFavoritesOnly = value
            end,
            default = defaults.enableMasterCrafterSetsLibSetsFavoritesOnly,
            width="half",
            disabled = function() return not settings.enableMasterCrafterSetsLibSetsFavorites or not LSM or not libSets end,
            requiresReload = true,
        },
    }
    --Custom Grand Master crafting stations set craete favorite categories, sorted by name
    local sortedCustomMasterCrafterSetStationFavoriteIds = {}
    for customFavoriteCategoryId, isEnabled in pairs(customMasterCrafterSetStationFavoriteIds) do
        if isEnabled == true then
            table.insert(sortedCustomMasterCrafterSetStationFavoriteIds, getCustomSetFavoriteCategoryName(customFavoriteCategoryId))
        end
    end
    if not ZO_IsTableEmpty(sortedCustomMasterCrafterSetStationFavoriteIds) then
        table.sort(sortedCustomMasterCrafterSetStationFavoriteIds)
--d(">sorted names of custom category IDs")
        for favCounter, name in ipairs(sortedCustomMasterCrafterSetStationFavoriteIds) do
            local customFavoriteCategoryId = customMasterCrafterSetStationNameToFavoriteId[name]
--d(">name: " ..tos(name) .. "; ID: " ..tos(customFavoriteCategoryId))
            if customFavoriteCategoryId ~= nil then
                optionsTable[#optionsTable + 1] = {
                    type = "checkbox",
                    name = localizationVars["options_multisets_create_enable_favorite"],
                    tooltip = localizationVars["options_multisets_create_enable_favorite_TT"],
                    getFunc = function() return settings.masterCrafterSetsFavoritesEnabled[customFavoriteCategoryId] end,
                    setFunc = function(value) settings.masterCrafterSetsFavoritesEnabled[customFavoriteCategoryId] = value
                    end,
                    default = defaults.masterCrafterSetsFavoritesEnabled[customFavoriteCategoryId],
                    disabled = function() return not settings.enableMasterCrafterSetsFavorites end,
                    width="half",
                }
                optionsTable[#optionsTable + 1] = {
                    type = "editbox",
                    name = GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER) .. "#" .. tos(favCounter),
                    tooltip = GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER) .. "#" .. tos(favCounter),
                    getFunc = function() return getCustomSetFavoriteCategoryName(customFavoriteCategoryId) end,
                    setFunc = function(value) settings.masterCrafterSetsFavoritesNames[customFavoriteCategoryId] = value
                    end,
                    default = customMasterCrafterSetStationFavoriteIdToName[customFavoriteCategoryId],
                    disabled = function() return not settings.enableMasterCrafterSetsFavorites or not settings.masterCrafterSetsFavoritesEnabled[customFavoriteCategoryId] end,
                    width="half",
                }
            end
        end
    end

    -- END OF OPTIONS TABLE
    LAM:RegisterOptionControls(addonVars.gAddonName .. "_LAMPanel", optionsTable)

end
FCOCF.BuildAddonMenu = BuildAddonMenu