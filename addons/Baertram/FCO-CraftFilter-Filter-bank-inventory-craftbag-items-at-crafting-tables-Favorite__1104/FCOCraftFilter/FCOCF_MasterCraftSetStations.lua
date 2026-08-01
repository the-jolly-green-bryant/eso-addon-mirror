------------------------------------------------------------------
------------------------------------------------------------------
--FCOCF_MasterCraftSetStations.lua
--Author: Baertram
--[[
Master crafter set creation stations
]]
local FCOCF = FCOCF
--local addonName = FCOCF.addonVars.gAddonName

--local controlsForChecks = FCOCF.controlsForChecks
local zoVars = FCOCF.zoVars
local smith     = zoVars.CRAFTSTATION_SMITHING_VAR

--Libraries
local LSM = LibScrollableMenu
local libSets = LibSets

--Textures
local textures = FCOCF.textures
local favoriteIcon = textures.favoriteIcon
local favIconStr = textures.favIconStr
local emptyTexture = textures.emptyIcon
local savedInCategoryTexture = textures.savedInCategoryTexture
local savedInCategoryTextureText = "|c33FF00" .. zo_iconTextFormatNoSpace(savedInCategoryTexture, 20, 20, "", true) .. "|r"
local notSavedInCategoryTexture = textures.notSavedInCategoryTexture

------------------------------------------------------------------------------------------------------------------------
--MasterCrafter tables - New data favorite category ID
local FAVORITES_TANK_CATEGORY_ID = FCOCF.FAVORITES_TANK_CATEGORY_ID
local FAVORITES_STAM_HEAL_CATEGORY_ID = FCOCF.FAVORITES_STAM_HEAL_CATEGORY_ID
local FAVORITES_MAG_HEAL_CATEGORY_ID = FCOCF.FAVORITES_MAG_HEAL_CATEGORY_ID
local FAVORITES_STAM_DD_CATEGORY_ID = FCOCF.FAVORITES_STAM_DD_CATEGORY_ID
local FAVORITES_MAG_DD_CATEGORY_ID = FCOCF.FAVORITES_MAG_DD_CATEGORY_ID
local FAVORITES_HYBRID_DD_CATEGORY_ID = FCOCF.FAVORITES_HYBRID_DD_CATEGORY_ID
local FAVORITES_FCOCF_CATEGORY_ID_LibSets = 99100 --LibSets starts at 99100

local customMasterCrafterSetStationFavoriteIds = FCOCF.customMasterCrafterSetStationFavoriteIds
local customMasterCrafterSetStationFavoriteOfLibSets = {}

local customMasterCrafterSetStationFavoriteIdToNameDefaults = {
    [FAVORITES_TANK_CATEGORY_ID] = "Tank",
    [FAVORITES_STAM_HEAL_CATEGORY_ID] = "Stam Heal",
    [FAVORITES_MAG_HEAL_CATEGORY_ID] = "Mag Heal",
    [FAVORITES_STAM_DD_CATEGORY_ID] = "Stam DD",
    [FAVORITES_MAG_DD_CATEGORY_ID] = "Mag DD",
    [FAVORITES_HYBRID_DD_CATEGORY_ID] = "Hybrid DD",
}
local customMasterCrafterSetStationFavoriteIdToName = {}
local customMasterCrafterSetStationNameToFavoriteId = {}
local defaultFavIconCategoryTexturs = { up = favoriteIcon, down = favoriteIcon, over = favoriteIcon }
local customMasterCrafterSetStationFavoriteIdToTexture = {
    [FAVORITES_TANK_CATEGORY_ID] = defaultFavIconCategoryTexturs,
    [FAVORITES_STAM_HEAL_CATEGORY_ID] = defaultFavIconCategoryTexturs,
    [FAVORITES_MAG_HEAL_CATEGORY_ID] = defaultFavIconCategoryTexturs,
    [FAVORITES_STAM_DD_CATEGORY_ID] = defaultFavIconCategoryTexturs,
    [FAVORITES_MAG_DD_CATEGORY_ID] = defaultFavIconCategoryTexturs,
    [FAVORITES_HYBRID_DD_CATEGORY_ID] = defaultFavIconCategoryTexturs,
}
FCOCF.customMasterCrafterSetStationFavoriteIds = customMasterCrafterSetStationFavoriteIds
FCOCF.customMasterCrafterSetStationFavoriteIdToNameDefaults = customMasterCrafterSetStationFavoriteIdToNameDefaults
FCOCF.customMasterCrafterSetStationFavoriteIdToName = customMasterCrafterSetStationFavoriteIdToName
FCOCF.customMasterCrafterSetStationNameToFavoriteId = customMasterCrafterSetStationNameToFavoriteId
FCOCF.customMasterCrafterSetStationFavoriteIdToTexture = customMasterCrafterSetStationFavoriteIdToTexture

local customMasterCrafterSetStationFavoriteDividerTextures = { up = emptyTexture, down = emptyTexture, over = emptyTexture }
local dividerTexture = "EsoUI/Art/Miscellaneous/horizontalDivider.dds"
local dividerStr = zo_iconTextFormatNoSpace(dividerTexture, 180, 8, "", nil)
------------------------------------------------------------------------------------------------------------------------

local setFavoriteLSMOptions = {
    enableFilter = true,
    headerCollapsible = true,
    sortEntries = true,
}


--===================== CLASSES ==============================================

------------------------------------
-- Consolidated Smithing Set Favorite Data --
------------------------------------
local FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS = {}
--FCOCF.FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS = FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS

local FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_DIVIDER = nil

local function isAnyMasterCrafterStationSetUnlocked()
    if GetNumConsolidatedSmithingSets() > 0 and GetNumUnlockedConsolidatedSmithingSets() > 0 then
        return true
    end
    return false
end

local function refreshSmithingCreationTree()
    --d("REFRESHING NOW!")
    smith:RefreshSetCategories()
end

local function areMasterCrafterSetsFavoritesEmpty()
    local settings = FCOCF.settingsVars.settings
    local masterCrafterSetsFavorites = settings.masterCrafterSetsFavorites
    local countTotal = 0
    for _, data in pairs(masterCrafterSetsFavorites) do
        countTotal = countTotal + NonContiguousCount(data)
        if countTotal > 0 then return false end
    end
    return countTotal == 0
end

local function doClearMasterCrafterSetFavoritesNow(customFavoriteId, clearAllCategories)
    if customFavoriteId == nil and clearAllCategories == nil then return end
    local doRefreshNow = false
    if customFavoriteId ~= nil and not clearAllCategories then
        FCOCF.settingsVars.settings.masterCrafterSetsFavorites[customFavoriteId] = {}
        doRefreshNow = true
    elseif customFavoriteId == nil and clearAllCategories == true then
        for l_customFavoriteId, _ in pairs(FCOCF.settingsVars.settings.masterCrafterSetsFavorites) do
            FCOCF.settingsVars.settings.masterCrafterSetsFavorites[l_customFavoriteId] = {}
        end
        doRefreshNow = true
    end
    if doRefreshNow then
        refreshSmithingCreationTree()
    end
end

local function getCustomSetFavoriteCategoryName(customFavoriteCategoryId, isLibSets)
    if customFavoriteCategoryId == nil then return "" end
    if not isLibSets then
        local masterCrafterSetsFavoritesNames = FCOCF.settingsVars.settings.masterCrafterSetsFavoritesNames
        return masterCrafterSetsFavoritesNames[customFavoriteCategoryId] or customMasterCrafterSetStationFavoriteIdToNameDefaults[customFavoriteCategoryId] or ""
    else
        return customMasterCrafterSetStationFavoriteIdToNameDefaults[customFavoriteCategoryId] or ""
    end
end
FCOCF.GetCustomSetFavoriteCategoryName = getCustomSetFavoriteCategoryName

local masterCrafterSetFavoritesClearDialogInitialized = false
local function initializeClearMasterCrafterSetFavoritesDialog()
    ZO_Dialogs_RegisterCustomDialog("FCOCF_MASTERCRAFTER_CLEAR_ALL_SET_FAV_DIALOG", {
        canQueue = true,
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = favIconStr .. " " .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1),
        },
        mainText = function(dialog)
            local customFavoriteId = dialog.data.customFavoriteId
            local  customFavoriteTexture = (customFavoriteId ~= nil and customMasterCrafterSetStationFavoriteIdToTexture[customFavoriteId] and zo_iconFormat(customMasterCrafterSetStationFavoriteIdToTexture[customFavoriteId].up, 24, 24)) or ""
            local mainText = customFavoriteId ~= nil and favIconStr .. " " .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1) .. " " .. GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER) .. "?\n" .. GetString(SI_CUSTOMER_SERVICE_CATEGORY) .. " \'" .. customFavoriteTexture .. getCustomSetFavoriteCategoryName(customFavoriteId) .. "\'"
                or favIconStr .. " " .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1) .. " " .. GetString(SI_COLLECTIONS_FAVORITES_CATEGORY_HEADER) .. "?\n" .. FCOCF.localizationVars.FCOCF_loc["favorites_remove_all_categories"]
            return { text = mainText }
        end,
        buttons =
        {
             -- Confirm Button
            {
                keybind = "DIALOG_PRIMARY",
                text = GetString(SI_DIALOG_CONFIRM),
                callback = function(dialog, data)
                    local dialogData = dialog.data
                    doClearMasterCrafterSetFavoritesNow(dialogData.customFavoriteId, dialogData.clearAllCategories)
                end,
            },

            -- Cancel Button
            {
                keybind = "DIALOG_NEGATIVE",
                text = GetString(SI_DIALOG_CANCEL),
            },
        },
        --[[
        noChoiceCallback = function()
        end,
        ]]
    })
    masterCrafterSetFavoritesClearDialogInitialized = true
end

local function changeMasterCrafterSetFavorites(setId, setData, customFavoriteId, doAddOrDelete, clearAll, clearAllCategories)
    local somethingDone = false
    local masterCrafterSetsFavorites = FCOCF.settingsVars.settings.masterCrafterSetsFavorites
    if masterCrafterSetsFavorites == nil then return end

    if setId == nil and setData == nil and customFavoriteId ~= nil and doAddOrDelete == false and clearAll == true and not clearAllCategories then
        --Reset all favorites of the category!
        if masterCrafterSetsFavorites == nil or ZO_IsTableEmpty(masterCrafterSetsFavorites[customFavoriteId]) then return end
        --Add a dialog asking if this is really correct
        if masterCrafterSetFavoritesClearDialogInitialized == false then
            initializeClearMasterCrafterSetFavoritesDialog()
        end
        ZO_Dialogs_ShowPlatformDialog("FCOCF_MASTERCRAFTER_CLEAR_ALL_SET_FAV_DIALOG", { customFavoriteId = customFavoriteId })
        somethingDone = false
    elseif setId == nil and setData == nil and customFavoriteId == nil and doAddOrDelete == false and clearAll == true and clearAllCategories == true then
        --Reset all categories of favorites!
        --Add a dialog asking if this is really correct
        if masterCrafterSetFavoritesClearDialogInitialized == false then
            initializeClearMasterCrafterSetFavoritesDialog()
        end
        ZO_Dialogs_ShowPlatformDialog("FCOCF_MASTERCRAFTER_CLEAR_ALL_SET_FAV_DIALOG", { customFavoriteId = nil, clearAllCategories = true })
    else
        if setId == nil or setId <= 0 then return end
        if doAddOrDelete == nil then return end
        if customFavoriteId == nil then return end
        if isAnyMasterCrafterStationSetUnlocked() == false then return end

        local masterCrafterSetsFavoritesEnabled = FCOCF.settingsVars.settings.masterCrafterSetsFavoritesEnabled
        if not masterCrafterSetsFavoritesEnabled[customFavoriteId] then return end

        if doAddOrDelete == true then
            local dataSource = setData.dataSource
            masterCrafterSetsFavorites[customFavoriteId] = masterCrafterSetsFavorites[customFavoriteId] or {}
            masterCrafterSetsFavorites[customFavoriteId][setId] = {
                setId = setId,
                setIndex = dataSource.setIndex,
                categoryId = dataSource.parentCategoryData ~= nil and dataSource.parentCategoryData.categoryId,
                customFavoriteId = customFavoriteId,
            }
            somethingDone = true
        else
            if masterCrafterSetsFavorites[customFavoriteId][setId] ~= nil then
                masterCrafterSetsFavorites[customFavoriteId][setId] = nil
                somethingDone = true
            end
        end
    end

    if somethingDone == false then return end

    --Update the smithing set categories ZO_Tree list. This will make the list popuate new and any selection is gone,
    --so we should check if the current category was the favorites, and then reoepn them again automatically
    local currentlySelectedNode = smith.categoryTree:GetSelectedNode()
    if currentlySelectedNode ~= nil then
        refreshSmithingCreationTree()
    end
end

local FCOCS_ConsolidatedSmithingSetFavoriteData = ZO_ConsolidatedSmithingSetCategoryData:Subclass()

function FCOCS_ConsolidatedSmithingSetFavoriteData:Initialize(customFavoriteId, isLibSets, isDivider)
    self.sets = {}
    self.categoryId = customFavoriteId
    self.isLibSets = isLibSets
    self.isDivider = isDivider
    return self
end

function FCOCS_ConsolidatedSmithingSetFavoriteData:GetName()
    if self.isDivider then return dividerStr end
    local customFavoriteId = self:GetId()
    local setsSavedToThisCategory = NonContiguousCount(FCOCF.settingsVars.settings.masterCrafterSetsFavorites[customFavoriteId]) or ""
    if setsSavedToThisCategory ~= "" and setsSavedToThisCategory > 0 then
        setsSavedToThisCategory = " (" .. setsSavedToThisCategory .. ")"
    else
        setsSavedToThisCategory = ""
    end
    return getCustomSetFavoriteCategoryName(customFavoriteId, self.isLibSets) .. setsSavedToThisCategory
end

function FCOCS_ConsolidatedSmithingSetFavoriteData:GetKeyboardIcons()
    if self.isDivider then return customMasterCrafterSetStationFavoriteDividerTextures.up, customMasterCrafterSetStationFavoriteDividerTextures.down, customMasterCrafterSetStationFavoriteDividerTextures.over end
    local textureData = customMasterCrafterSetStationFavoriteIdToTexture[self:GetId()]
    return textureData.up, textureData.down, textureData.over
end

function FCOCS_ConsolidatedSmithingSetFavoriteData:GetGamepadIcon()
    if self.isDivider then return customMasterCrafterSetStationFavoriteDividerTextures.up, customMasterCrafterSetStationFavoriteDividerTextures.down, customMasterCrafterSetStationFavoriteDividerTextures.over end
    local textureData = customMasterCrafterSetStationFavoriteIdToTexture[self:GetId()]
    return textureData.up
end

function FCOCS_ConsolidatedSmithingSetFavoriteData:AnyChildPassesFilters(filterFunctions)
    --Ensure that the Favorites category appears in the list despite having no valid children.
    return true
end

--LibSets - helper functions
local function getLibSetsFavorites(favoriteCategoryIdCurrentlyMax)
    libSets = libSets or LibSets
    if not libSets then return end
    local customMasterCrafterSetStationLibSetsFavoriteIdsSorted = libSets.GetSetSearchFavoriteCategories()
    --[[
        customMasterCrafterSetStationLibSetsFavoriteIdsSorted[index] = {
            category = setSearchFavoriteCategory,
            categoryName = clientLocalization[setSearchFavoriteCategory],
            texture = possibleSetSearchFavoriteCategoriesUnsorted[setSearchFavoriteCategory],
        }
    ]]
    favoriteCategoryIdCurrentlyMax = favoriteCategoryIdCurrentlyMax or FAVORITES_FCOCF_CATEGORY_ID_LibSets

    local customMasterCrafterSetStationLibSetsFavoriteIds
    if not ZO_IsTableEmpty(customMasterCrafterSetStationLibSetsFavoriteIdsSorted) then
        customMasterCrafterSetStationLibSetsFavoriteIds = {}
        for idx, libSetsCategoryData in ipairs(customMasterCrafterSetStationLibSetsFavoriteIdsSorted) do
            local libSetsCategoryId = favoriteCategoryIdCurrentlyMax + idx
            customMasterCrafterSetStationLibSetsFavoriteIds[libSetsCategoryId] = true

            --Add the texture and names too
            local texturePath = libSetsCategoryData.texture
            customMasterCrafterSetStationFavoriteIdToTexture[libSetsCategoryId] = { up = texturePath, down = texturePath, over = texturePath }
            customMasterCrafterSetStationFavoriteIdToNameDefaults[libSetsCategoryId] = libSetsCategoryData.categoryName
        end
    end
    return customMasterCrafterSetStationLibSetsFavoriteIds
end


local function rebuildEnabledSmithingCreateMasterCrafterCustomFavoriteCategories()
    local settings = FCOCF.settingsVars.settings
    local masterCrafterSetsFavorites = settings.masterCrafterSetsFavorites
    local masterCrafterSetsFavoritesEnabled = settings.masterCrafterSetsFavoritesEnabled

    libSets = libSets or LibSets
    local isSetFavoriteCategoriesEnabledForLibSets = (libSets ~= nil and settings.enableMasterCrafterSetsLibSetsFavorites) or false
    local isSetFavoriteCategoriesEnabledForLibSetsOnly = (isSetFavoriteCategoriesEnabledForLibSets and settings.enableMasterCrafterSetsLibSetsFavoritesOnly) or false

    --The divider header row
    FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_DIVIDER = FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_DIVIDER or FCOCS_ConsolidatedSmithingSetFavoriteData:New(99999, false, true)

    --FCOCF Favorites
    if not isSetFavoriteCategoriesEnabledForLibSetsOnly then
        for customFavoriteId, isEnabled in pairs(customMasterCrafterSetStationFavoriteIds) do
            FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId] = nil
            if isEnabled == true then
                --Enabled in settings too?
                if masterCrafterSetsFavoritesEnabled[customFavoriteId] == true then
                    FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId] = FCOCS_ConsolidatedSmithingSetFavoriteData:New(customFavoriteId)
                end
            end
        end
    else
        customMasterCrafterSetStationFavoriteIds = {}
    end

    --LibSets favorites
    if isSetFavoriteCategoriesEnabledForLibSets then
        local customMasterCrafterSetStationLibSetsFavoriteIds = getLibSetsFavorites(FAVORITES_FCOCF_CATEGORY_ID_LibSets)
        if not ZO_IsTableEmpty(customMasterCrafterSetStationLibSetsFavoriteIds) then
            for customFavoriteId, isEnabled in pairs(customMasterCrafterSetStationLibSetsFavoriteIds) do
                customMasterCrafterSetStationFavoriteIds[customFavoriteId] = true

                FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId] = nil
                if isEnabled == true then
                    if masterCrafterSetsFavorites[customFavoriteId] == nil then
                        masterCrafterSetsFavorites[customFavoriteId] = {}
                    end
                    if masterCrafterSetsFavoritesEnabled[customFavoriteId] == nil then
                        masterCrafterSetsFavoritesEnabled[customFavoriteId] = true
                    end
                    --Enabled in settings too?
                    if masterCrafterSetsFavoritesEnabled[customFavoriteId] == true then
                        FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId] = FCOCS_ConsolidatedSmithingSetFavoriteData:New(customFavoriteId, true)
                        customMasterCrafterSetStationFavoriteOfLibSets[customFavoriteId] = true
                    end
                end
            end
        end
    end
end


--Sort the favorite sets into this new category
local function buildFavoriteSetsDataAndAddToFavoritesCategory()
    if isAnyMasterCrafterStationSetUnlocked() == false then return end

    local masterCrafterSetsFavorites = FCOCF.settingsVars.settings.masterCrafterSetsFavorites
    if masterCrafterSetsFavorites == nil then return end

    for customFavoriteId, _ in pairs(FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS) do
        ZO_ClearTable(FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId].sets)

        for setId, savedFavoritesSetData in pairs(masterCrafterSetsFavorites[customFavoriteId]) do
            local setIndex = savedFavoritesSetData.setIndex
            local setData = ZO_ConsolidatedSmithingSetData:New(setIndex)
            if setData ~= nil then
                --Get the original categoryId of the set
                --local categoryId = savedFavoritesSetData.categoryId or setData:GetCategoryId()
                --Do not use self:GetOrCreateConsolidatedSmithingSetCategoryData(categoryId) here, else the set would be automatically sorted below the wrong category (original one)
                FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId]:AddSetData(setData)
            end
        end
        FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteId]:SortSets()
    end
end

local function buildCustomSetFavoriteCategoryNames()
    local localizationVars = FCOCF.localizationVars.FCOCF_loc
    customMasterCrafterSetStationFavoriteIdToNameDefaults = {}
    customMasterCrafterSetStationFavoriteIdToName = {}
    customMasterCrafterSetStationNameToFavoriteId = {}

    for customMasterCrafterSetStationFavoriteId, isEnabled in pairs(customMasterCrafterSetStationFavoriteIds) do
        local defName = localizationVars["options_multisets_create_fav_" .. tostring(customMasterCrafterSetStationFavoriteId)]
        customMasterCrafterSetStationFavoriteIdToNameDefaults[customMasterCrafterSetStationFavoriteId] = defName
        local name = getCustomSetFavoriteCategoryName(customMasterCrafterSetStationFavoriteId)
        customMasterCrafterSetStationFavoriteIdToName[customMasterCrafterSetStationFavoriteId] = name
        customMasterCrafterSetStationNameToFavoriteId[name] = customMasterCrafterSetStationFavoriteId
    end
end
FCOCF.BuildCustomSetFavoriteCategoryNames = buildCustomSetFavoriteCategoryNames


--======================================================================================================================

function FCOCF.HookCrafting_MasterSetCrafterTables_Create()
    --LibCustomMenu is loaded?
    LSM = LSM or LibScrollableMenu
    libSets = libSets or LibSets

    if not LSM then return end

    local settings = FCOCF.settingsVars.settings
    local isSetFavoriteCategoriesEnabledInTotal = settings.enableMasterCrafterSetsFavorites


    if isSetFavoriteCategoriesEnabledInTotal then
        rebuildEnabledSmithingCreateMasterCrafterCustomFavoriteCategories()

        --Master Crafter set tables -> ZO_Tree -> AddTemplate function for the XML set entry (each node/child) -> See smithing_keyboard.lua
        ---> smithing_keyboard.lua, AddTemplate("ZO_ConsolidatedSmithingSetNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, SetEqualityFunction)
        --[[
                local origSmithingCreateTreeListHeaderWithStatusIconAndChildrenEntryData = ZO_ShallowTableCopy(smith.categoryTree.templateInfo["ZO_StatusIconHeader"])
                smith.categoryTree.templateInfo["ZO_StatusIconHeader"].selectionFunction = function(...)
                    if origSmithingCreateTreeListHeaderWithStatusIconAndChildrenEntryData.selectionFunction ~= nil then
                        origSmithingCreateTreeListHeaderWithStatusIconAndChildrenEntryData.selectionFunction(...)
                    end
                end
                local origSmithingCreateTreeListHeaderWithStatusIconWithoutChildrenEntryData = ZO_ShallowTableCopy(smith.categoryTree.templateInfo["ZO_StatusIconChildlessHeader"])
                smith.categoryTree.templateInfo["ZO_StatusIconChildlessHeader"].selectionFunction = function(...)
                    if origSmithingCreateTreeListHeaderWithStatusIconWithoutChildrenEntryData.selectionFunction ~= nil then
                        origSmithingCreateTreeListHeaderWithStatusIconWithoutChildrenEntryData.selectionFunction(...)
                    end
        d("Childless header was selected")
                end
        ]]

--[[
        local origSmithingCreateTreeListHeader = smith.categoryTree.templateInfo["ZO_StatusIconHeader"]
        SecurePostHook(origSmithingCreateTreeListHeader, "setupFunction", function(node, control, setData, open, userRequested, enabled)
            local textCtrl = control:GetNamedChild("Text")
--d("[FCOCF]ZO_StatusIconHeader posthook - " ..tostring(textCtrl and textCtrl:GetText() or "n/a"))
            if not control.statusIcon then
                control.statusIcon = control:GetNamedChild("StatusIcon")
            end
            control.statusIcon:SetDimensions(18, 18)
        end)
]]

        local origSmithingCreateTreeListChildlessHeader = smith.categoryTree.templateInfo["ZO_StatusIconChildlessHeader"]
        SecurePostHook(origSmithingCreateTreeListChildlessHeader, "setupFunction", function(node, control, setData, open, userRequested, enabled)
            if setData and setData.isDivider then
                local textCtrl = control:GetNamedChild("Text")
--d("[FCOCF]ZO_StatusIconChildlessHeader posthook - " ..tostring(textCtrl and textCtrl:GetText() or "n/a"))
                --Set the control's text, icon and statusicon controls "non clickable"
                for i=1, control:GetNumChildren(), 1 do
                    local childCtrl = control:GetChild(i)
                    childCtrl:SetMouseEnabled(false)
                end
            end
        end)

        local origSmithingCreateTreeListSetEntryData = smith.categoryTree.templateInfo["ZO_ConsolidatedSmithingSetNavigationEntry"]
        --Add the context menu to the setup functions
        --SET IITEM
        --smith.categoryTree.templateInfo["ZO_ConsolidatedSmithingSetNavigationEntry"].setupFunction = newSmithingCreateTreeListSetEntrySetupFunc
        SecurePostHook(origSmithingCreateTreeListSetEntryData, "setupFunction", function(node, control, setData, open, userRequested, enabled)
            control:SetHandler("OnMouseUp", function(ctrl, mouseButton, upInside)
                if upInside then
                    if setData.isDivider then
                        return
                    end

                    if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
                        if setData:IsUnlocked() == true then
                            --ClearMenu()
                            ClearCustomScrollableMenu()

                            local setId = setData:GetItemSetId()
                            --d(">setId: " .. tos(setId))
                            if setId == nil then return end

                            settings = FCOCF.settingsVars.settings
                            isSetFavoriteCategoriesEnabledInTotal = settings.enableMasterCrafterSetsFavorites
                            if not isSetFavoriteCategoriesEnabledInTotal then return end
                            --local isSetFavoriteCategoriesEnabledForLibSets = (libSets ~= nil and settings.enableMasterCrafterSetsLibSetsFavorites) or false
                            --local isSetFavoriteCategoriesEnabledForLibSetsOnly = (isSetFavoriteCategoriesEnabledForLibSets and settings.enableMasterCrafterSetsLibSetsFavoritesOnly) or false

                            local masterCrafterSetsFavorites = settings.masterCrafterSetsFavorites
                            if masterCrafterSetsFavorites == nil then return end
                            local masterCrafterSetsFavoritesEnabled = settings.masterCrafterSetsFavoritesEnabled
                            if masterCrafterSetsFavoritesEnabled == nil then return end

                            --Show FCOCF and LibSets favorites
                            --[[
                            if not isSetFavoriteCategoriesEnabledForLibSetsOnly then

                            else
                                --Show only LibSets favorites -> Handled in buildUp tables
                            end
                            ]]

                            local wasAddedToRemoveCount = 0
                            for customFavoriteId, isEnabled in pairs(customMasterCrafterSetStationFavoriteIds) do --Contains either FCOCF, FCOCF and LibSets or only LibSets favorites
                                if isEnabled == true and masterCrafterSetsFavoritesEnabled[customFavoriteId] == true then
                                    if masterCrafterSetsFavorites[customFavoriteId] == nil then return end
                                    local savedFavoritesCount = NonContiguousCount(masterCrafterSetsFavorites[customFavoriteId])
                                    local isSavedFavoritesEmpty = savedFavoritesCount <= 0

                                    --local isLibSetsFavorityCategory = customMasterCrafterSetStationFavoriteOfLibSets[customFavoriteId] or false

                                    local categoryName = GetString(SI_CUSTOMER_SERVICE_CATEGORY) .. ": " .. getCustomSetFavoriteCategoryName(customFavoriteId)
                                    local categoryStr = " " .. categoryName

                                    local favoriteCategoryTexture = customMasterCrafterSetStationFavoriteIdToTexture[customFavoriteId] and zo_iconFormat(customMasterCrafterSetStationFavoriteIdToTexture[customFavoriteId].up, 24, 24) or favIconStr

                                    local subMenuEntries = {}

                                    local isCurrentSetSavedInFavoriteCategory = masterCrafterSetsFavorites[customFavoriteId][setId] ~= nil
                                    local isCurrentSetSavedInFavoriteCategoryTexture = ""
                                    if not isCurrentSetSavedInFavoriteCategory then
                                        subMenuEntries[#subMenuEntries + 1] = {
                                            name = "|c00FF00+|r" .. favoriteCategoryTexture .. categoryStr,
                                            tooltip = GetString(SI_COLLECTIBLE_ACTION_ADD_FAVORITE) .. categoryStr .. favoriteCategoryTexture,
                                            callback = function()
                                                changeMasterCrafterSetFavorites(setId, setData, customFavoriteId, true)
                                            end
                                        }
                                        --isCurrentSetSavedInFavoriteCategoryTexture = notSavedInCategoryTexture
                                    else
                                        subMenuEntries[#subMenuEntries + 1] = {
                                            name = "|cFF0000-|r" .. favoriteCategoryTexture .. categoryStr,
                                            tooltip =  GetString(SI_COLLECTIBLE_ACTION_REMOVE_FAVORITE) .. categoryStr .. favoriteCategoryTexture,
                                            callback = function()
                                                changeMasterCrafterSetFavorites(setId, setData, customFavoriteId, false)
                                            end
                                        }
                                        isCurrentSetSavedInFavoriteCategoryTexture = savedInCategoryTextureText
                                        wasAddedToRemoveCount = wasAddedToRemoveCount + 1
                                    end
                                    if not isSavedFavoritesEmpty then
                                        subMenuEntries[#subMenuEntries + 1] = {
                                            name = "|cFF0000" .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1) .. "|r"  .. categoryStr .. favoriteCategoryTexture,
                                            tooltip = "|cFF0000" .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1) .. "|r" .. categoryStr .. favoriteCategoryTexture,
                                            callback = function()
                                                changeMasterCrafterSetFavorites(nil, nil, customFavoriteId, false, true)
                                            end
                                        }
                                    end

                                    if not ZO_IsTableEmpty(subMenuEntries) then
                                        AddCustomScrollableSubMenuEntry(isSavedFavoritesEmpty and categoryName or categoryName .. " |c33FF00(#" .. savedFavoritesCount .. ")|r" .. isCurrentSetSavedInFavoriteCategoryTexture, subMenuEntries)
                                    end
                                end
                            end
                            if wasAddedToRemoveCount > 0 or not areMasterCrafterSetsFavoritesEmpty() then
                                AddCustomScrollableMenuEntry(" - |cFF0000" .. GetString(SI_ATTRIBUTEPOINTALLOCATIONMODE_CLEARKEYBIND1) .." - |r", function()
                                    changeMasterCrafterSetFavorites(nil, nil, nil, false, true, true)
                                end)
                            end
                            ShowCustomScrollableMenu(ctrl, setFavoriteLSMOptions)
                        end
                    end
                end
            end, "FCOChangeStuff_Smithing_Create_SetEntry_ContextMenu")
        end)


        --local origSmithingRefreshSetCategories = smith.RefreshSetCategories
        function smith.RefreshSetCategories()
            --function zo_smith:RefreshSetCategories()
            --d("[FCOCS]SMITHING:RefreshSetCategories")
            local self = smith
            self.categoryTree:Reset()
            ZO_ClearTable(self.setNodeLookupData)

            if self.mode == SMITHING_MODE_CREATION and ZO_Smithing_IsConsolidatedStationCraftingMode() then
                --Maybe created bug with LibLazyCrafting as self.setNodeLookupData was cleared and LLC tried to access it!
                --if isAnyMasterCrafterStationSetUnlocked() == false then return end
                self.setContainer:SetHidden(false)

                ---v- FCOCraftFilter inserted code -v-
                --Add the special set favorites category first
                rebuildEnabledSmithingCreateMasterCrafterCustomFavoriteCategories()
                buildFavoriteSetsDataAndAddToFavoritesCategory()

                settings = FCOCF.settingsVars.settings
                local masterCrafterSetsFavoritesEnabled = settings.masterCrafterSetsFavoritesEnabled
                local sortedCustomCategoryData = {}
                for customFavoriteId, customFavoriteCategoryData in pairs(FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS) do
                    if masterCrafterSetsFavoritesEnabled[customFavoriteId] then
                        table.insert(sortedCustomCategoryData, customFavoriteCategoryData)
                    end
                end
                table.sort(sortedCustomCategoryData, ZO_ConsolidatedSmithingSetCategoryData.CompareTo)
                for _, customFavoriteCategoryData in ipairs(sortedCustomCategoryData) do
                    self:AddSetCategory(FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_OBJECTS[customFavoriteCategoryData:GetId()])
                end

                --Add 1 category entry which only shows a divider row
                self:AddSetCategory(FCOCS_SMITHING_FAVORITES_CATEGORY_DATA_DIVIDER)
                ---^- FCOCraftFilter inserted code -^-


                --After that add special default category
                self:AddSetCategory(CONSOLIDATED_SMITHING_DEFAULT_CATEGORY_DATA)

                local categoryList = CONSOLIDATED_SMITHING_SET_DATA_MANAGER:GetSortedCategories()
                for _, categoryData in ipairs(categoryList) do
                    --Only add categories that have at least one child that passes the current filters
                    if categoryData:AnyChildPassesFilters(self.setFilters) then
                        self:AddSetCategory(categoryData, self.setFilters)
                    end
                end

                local nodeToSelect = nil
                if self.selectedConsolidatedSetData and not self.selectedConsolidatedSetData:IsInstanceOf(ZO_ConsolidatedSmithingDefaultCategoryData)
                        -- -v- Added by FCOCraftFilter -v-
                        and not self.selectedConsolidatedSetData.isDivider
                        and self.setNodeLookupData ~= nil and self.selectedConsolidatedSetData.GetItemSetId ~= nil and self.selectedConsolidatedSetData:GetItemSetId() ~= nil
                        -- -^- Added by FCOCraftFilter -^-
                then
                    nodeToSelect = self.setNodeLookupData[self.selectedConsolidatedSetData:GetItemSetId()]
                end

                self.categoryTree:Commit(nodeToSelect)
                CRAFTING_RESULTS:SetContextualAnimationControl(CRAFTING_PROCESS_CONTEXT_CONSUME_ATTUNABLE_STATIONS, self.setContainer)

                self.setCategoriesDirty = false
            else
                self.setContainer:SetHidden(true)
            end
        end

        ZO_PreHook(smith, "RefreshActiveConsolidatedSmithingSet", function()
            --d("[FCOCS]PreHook - SMITHING:RefreshActiveConsolidatedSmithingSet")
            if isAnyMasterCrafterStationSetUnlocked() == false then
                --d("<abort 1")
                return false
            end
            settings = FCOCF.settingsVars.settings
            isSetFavoriteCategoriesEnabledInTotal = settings.enableMasterCrafterSetsFavorites
            if not isSetFavoriteCategoriesEnabledInTotal then
                --d("<abort NOT ENABLED AT ALL")
                return false
            end
            --If this is a consolidated crafting station, make sure the active set matches the current selection
            if ZO_Smithing_IsConsolidatedStationCraftingMode() then
                local self = smith
                local selectedData = self.categoryTree:GetSelectedData()
                if selectedData and selectedData.GetSetIndex == nil then
                    --Special new added favorite categories?
                    if selectedData:IsInstanceOf(FCOCS_ConsolidatedSmithingSetFavoriteData) then
                        SetActiveConsolidatedSmithingSetByIndex(nil)
                        self.creationPanel:DirtyAllLists()
                        self.creationPanel:RefreshAvailableFilters()
                        return true
                    end
                end
            end
            return false
        end)
    end --if isSetFavoriteCategoriesEnabledInTotal then
end