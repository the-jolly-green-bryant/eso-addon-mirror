WishList = WishList or {}
local WL = WishList

local currentSettingsGearId --the currently selected gearId at the settings menu
WL.currentSettingsGearId = currentSettingsGearId
local nextFreeGearId
local addNewGearEnabled = false
local setupGearLAMControlsDone = false
local editExistingGearEnabled = false
local deleteExistingGearWasDone = false

local gearsChoices = {}
local gearsChoicesValues = {}
local gearsChoicesTooltips = {}
local gearMarkerTextures = WL.gearMarkerTextures
local gearMarkerTexturesLookup = WL.gearMarkerTexturesLookup
local gearMarkerTexturesValues = {}
local gearMarkerTexturesTooltips = {}

------------------------------------------------------------------------------------------------------------
-- LibAddonMenu (LAM) Settings panel
------------------------------------------------------------------------------------------------------------

--Function to create a LAM control
local function CreateControl(ref, name, tooltip, data, disabledChecks, getFunc, setFunc, defaultSettings, warning, scrollable)
    scrollable = scrollable or false
    if ref ~= nil then
        if string.find(ref, GetString(WISHLIST_TITLE) .. "_LAM_", 1)  ~= 1 then
            data.reference = GetString(WISHLIST_TITLE) .. "_LAM_" .. ref
        else
            data.reference = ref
        end
    end
    if data.type ~= "description" then
        data.name = name
        if data.type ~= "header" and data.type ~= "submenu" then
            data.tooltip = tooltip
            if data.type ~= "button" then
                data.getFunc = getFunc
                data.setFunc = setFunc
                data.default = defaultSettings
            else
                data.func = setFunc
            end
            if disabledChecks ~= nil then
                data.disabled = disabledChecks
            end
            data.scrollable = scrollable
            data.warning = warning
        end
    end
    return data
end

local function buildGearsTexturesIconPickerEntries()
    gearMarkerTexturesValues = {}
    gearMarkerTexturesTooltips = {}

    for iconId, iconTexturePath in ipairs(gearMarkerTextures) do
        gearMarkerTexturesValues[iconId] = iconId
        gearMarkerTexturesTooltips[iconId] = tostring(iconId)
    end
end

local function buildGearsDropdownEntries(updateLAMDropdown)
    updateLAMDropdown = updateLAMDropdown or false

    gearsChoices = {}
    gearsChoicesValues = {}
    gearsChoicesTooltips = {}
    local settings = WL.data
    local gears = settings.gears
    if not gears then return end

    for gearId, gearData in pairs(gears) do
        if gearData ~= nil then
            local gearName = gearData.name
            if gearName ~= nil and gearName ~= "" then
                local newIndex = #gearsChoices + 1
                local gearIcon = gearData.gearMarkerTextureId
                local gearColor = gearData.gearMarkerTextureColor
                local gearColorDef = ZO_ColorDef:New(gearColor.r,gearColor.g,gearColor.b,gearColor.a)
                --local gearNameColored = gearColorDef:Colorize(gearName)
                local gearNameTextureStr = gearColorDef:Colorize(zo_iconFormatInheritColor(gearMarkerTextures[gearIcon], 28, 28)) .. " " .. gearName
                gearsChoices[newIndex] = gearNameTextureStr
                gearsChoicesValues[newIndex] = gearId
                if gearData.comment ~= nil and gearData.comment ~= "" then
                    gearsChoicesTooltips[newIndex] = gearNameTextureStr .."\n" .. gearData.comment
                else
                    gearsChoicesTooltips[newIndex] = gearNameTextureStr
                end
            end
        end
    end

    if updateLAMDropdown == true then
        local gearsDropdownCtrl = GetControl("WishList_Settings_GearsDropdownControl")
        if gearsDropdownCtrl ~= nil and gearsDropdownCtrl.UpdateChoices ~= nil then
            gearsDropdownCtrl:UpdateChoices(gearsChoices, gearsChoicesValues, gearsChoicesTooltips)
        end
    end
end

local function updateGearLAMControls(doClear, gearId)
    doClear = doClear or false
--d("[WL]updateGearLAMControls-doClear: " ..tostring(doClear) .. ", gearId: " ..tostring(gearId) .. ", useTheControlsCurrentValue: " ..tostring(useTheControlsCurrentValue))

    local gearIconCtrl = GetControl("WishList_Settings_GearIconPickerControl")
    if gearIconCtrl ~= nil and gearIconCtrl.UpdateValue then
--d(">>update icon")
        if doClear == true or gearId == nil then
            gearIconCtrl:UpdateValue(true, nil)
        else
            gearIconCtrl:UpdateValue(false, gearMarkerTextures[gearId])
        end
    end

    local gearColorCtrl = GetControl("WishList_Settings_GearColorPickerControl")
    if gearColorCtrl ~= nil and gearColorCtrl.UpdateValue then
--d(">>update color")
        if doClear == true or gearId == nil then
            gearColorCtrl:UpdateValue(true, nil, nil, nil, nil)
        else
            gearColorCtrl:UpdateValue(false, 0, 0, 1, 1) --blue
        end

    end

    local gearNameEditCtrl = GetControl("WishList_Settings_GearNameEditControl")
    if gearNameEditCtrl ~= nil and gearNameEditCtrl.SetText then
--d(">>update name")
        if doClear == true or gearId == nil then
            gearNameEditCtrl:UpdateValue(true, nil)
        else
            gearNameEditCtrl:UpdateValue(false, "Gear #" .. tostring(gearId))
            gearNameEditCtrl.editBox:TakeFocus()
        end
    end

    local gearCommentCtrl = GetControl("WishList_Settings_GearCommentEditControl")
    if gearCommentCtrl ~= nil and gearCommentCtrl.SetText then
--d(">>update comment")
        if doClear == true or gearId == nil then
            gearCommentCtrl:UpdateValue(true, nil)
        else
            gearCommentCtrl:UpdateValue(false, "")
        end
    end
end

local function saveCurrentGear()
    if currentSettingsGearId == nil then return end
    if WL.data.gears[currentSettingsGearId] == nil then
        --Create the settings table entry for the gearId
        WL.data.gears[currentSettingsGearId] = {}
    end

    --Enabling saving of the LAM data to the SV
    -->Icon and color will be default values from the getFunc
    local name =        WishList_Settings_GearNameEditControl.editbox:GetText()
    local comment =     WishList_Settings_GearCommentEditControl.editbox:GetText()
    local icon =        WishList_Settings_GearIconPickerControl.data:getFunc()
    local iconId = gearMarkerTexturesLookup[icon]
    local iconColor =   {WishList_Settings_GearColorPickerControl.data:getFunc()}
    local iconColorForSV = {r=iconColor[1], g=iconColor[2], b=iconColor[3], a=iconColor[4]}

    --Update the SavedVariables with the data of the current LAM controls
    WL.data.gears[currentSettingsGearId].name = name
    WL.data.gears[currentSettingsGearId].comment = comment
    WL.data.gears[currentSettingsGearId].gearMarkerTextureId = iconId
    WL.data.gears[currentSettingsGearId].gearMarkerTextureColor = iconColorForSV

    --Reset the currently selected gearId
    currentSettingsGearId = nil
    WL.currentSettingsGearId = nil

    --Create a new dropdown entry for the "available gears" by updating the total dropdown
    buildGearsDropdownEntries(true)

    --Unselect the selected entry at the gears dropdown and clear all LAM controls again
    updateGearLAMControls(true, nil)

    --Reset the "add" variable so the getFunc wont update the editbox texts with default values!
    addNewGearEnabled = false
end

local function getNextFreeGearId()
    --Get the next free gearId
    nextFreeGearId = nil

    local settings = WL.data
    local gears = settings.gears
    if not gears then return end

    if ZO_IsTableEmpty(gears) then
        nextFreeGearId = 1
    else
        local lastGearId
        local numChoices = #gearsChoicesValues
        if numChoices == 0 then
            nextFreeGearId = 1
        else
            if numChoices == 1 then
                if gearsChoicesValues[1] > 1 then
                    nextFreeGearId = 1
                else
                    nextFreeGearId = 2
                end
            else
                local maxGearId
                local sortedGearIdsASC = {}
                --gearsChoicesValues could be in order [1]=2, [2]=1, so sort it first
                for _, gearId in ipairs(gearsChoicesValues) do
                    table.insert(sortedGearIdsASC, gearId)
                end
                table.sort(sortedGearIdsASC)


                for _, gearId in ipairs(sortedGearIdsASC) do
                    if nextFreeGearId == nil then
                        if lastGearId == nil then
                            lastGearId = gearId
                        end
                        if gearId > (lastGearId+1) then
                            nextFreeGearId = lastGearId+1
                            break
                        end
                        lastGearId = gearId
                        if maxGearId == nil or gearId > maxGearId then
                            maxGearId = gearId
                        end
                    end
                end
                if nextFreeGearId == nil and maxGearId ~= nil then
                            nextFreeGearId = maxGearId+1
                end
            end
        end
    end
end

local function resetGearAddAndDeleteVariables()
    --Reset some variables
    currentSettingsGearId    = nil
    WL.currentSettingsGearId = nil
    addNewGearEnabled = false
    editExistingGearEnabled = false
    deleteExistingGearWasDone = false

    nextFreeGearId = nil
end

local function addNewGear()
    --Reset some variables
    resetGearAddAndDeleteVariables()

    --Get the next free gear id at the SV
    getNextFreeGearId()

    --Place the cursor into the name editbox and put the gear ID in there
    if nextFreeGearId ~= nil then
        addNewGearEnabled = true
        -->Allows to change the name/comment etc. fields now
        -->Changing the name field to a value ~= "" will enable the save button as the currentSettingsGearId will be set then!
        editExistingGearEnabled = false

        if WishList_Settings_GearNameEditControl ~= nil then
            WishList_Settings_GearNameEditControl.editbox:TakeFocus()
            if WishList_Settings_GearSaveButton ~= nil then
                WishList_Settings_GearSaveButton.button:SetEnabled(true)
            end
        end
    end
end

local function deleteGear(gearId)
    --Reset some variables
    resetGearAddAndDeleteVariables()

    local settings = WL.data
    local gears = settings.gears
    if not gears then return end
    if gears[gearId] == nil then return end

    WL.data.gears[gearId] = nil

    deleteExistingGearWasDone = true

    updateGearLAMControls(true, nil)
    --Update the LAM dropdown with the gears so that the removed entry will be removed there too
    buildGearsDropdownEntries(true)
end

local function updateGearMarkerIconPreviewColor(r,g,b,a)
--d("[WL]updateGearMarkerIconPreviewColor")
    if WishList_Settings_GearIconPickerControl ~= nil then
        WishList_Settings_GearIconPickerControl.icon:SetColor(r,g,b,a)
    end
end

local function updateWishListGearsWithFCOISGearMarkerIcons()
    if FCOIS == nil then return end

    --Reset some variables
    resetGearAddAndDeleteVariables()

    local settings = WL.data
    local gears = settings.gears
    if not gears then return end

    local textureVars = FCOIS.textureVars.MARKER_TEXTURES
    if textureVars == nil then return end
    if FCOIS.settingsVars == nil or FCOIS.settingsVars.settings == nil then return end
    local settingsIcon = FCOIS.settingsVars.settings.icon
    if settingsIcon == nil then return end

    local anyFCOISgearWasAdded = false
    --Get the FCOIS static and dynamic gear markers info, name, texture etc.
    local gearSetIconsTable = FCOIS.GetGearIcons(false)
    for gearIconId, isGear in pairs(gearSetIconsTable) do
        if isGear == true and gearIconId ~= nil then
            --Get the FCOIS gear name
            local gearNameStr = FCOIS.GetIconText(gearIconId, false, false, false)
            if gearNameStr ~= nil and gearNameStr ~= "" then
                --Add the FCOIS gear to the SavedVariables gears table
                --Get the next free gear id at the SV
                getNextFreeGearId()
                if nextFreeGearId ~= nil then
                    local iconSettings = settingsIcon[gearIconId]
                    if iconSettings ~= nil then
                        local iconColorForSV = iconSettings.color
                        local textureId = iconSettings.texture
                        if textureId ~= nil then
                            local iconTextureString = textureVars[textureId]
                            if iconTextureString ~= nil and iconTextureString ~= ""
                                    and iconColorForSV ~= nil and iconColorForSV.r ~= nil and iconColorForSV.g ~= nil and iconColorForSV.b ~= nil and iconColorForSV.a ~= nil then
                                local timeStamp = GetTimeStamp()
                                local addedDateStr = os.date("%c", timeStamp)
                                --Create the SV table entry
                                WL.data.gears[nextFreeGearId] = {
                                    name = gearNameStr,
                                    comment = "Added from FCOIS: " .. addedDateStr,
                                    gearMarkerTextureId = textureId, --icon/texture Ids need to be the same within WL and FCOIS!
                                    gearMarkerTextureColor = iconColorForSV,
                                    ------------------------
                                    copiedFromFCOIS = true,
                                    copiedFromFCOISTimestamp = timeStamp,
                                }
                                anyFCOISgearWasAdded = true
                                nextFreeGearId = nil
                                buildGearsDropdownEntries(false)
                            end
                        end
                    end
                end
            end
        end
        nextFreeGearId = nil
    end
    --if any FCOIS gear was added to the SV: Rebuild the dropdown with available gears now
    if anyFCOISgearWasAdded == true then
        buildGearsDropdownEntries(true)
    end
end

--[[
local function panelControlsCreated(panel)
    if WL.addonMenuPanel == nil or panel ~= WL.addonMenuPanel then return end
    --updateGearMarkerIconPreviewColor()
end

local firstOpen = true
local function panelOpened(panel)
    if WL.addonMenuPanel == nil or panel ~= WL.addonMenuPanel then return end
    if firstOpen == true then
        firstOpen = false
        return
    end
    --Rebuild the gear marker icons dropdown entries
    updateWishListGearsWithFCOISGearMarkerIcons()
    buildGearsDropdownEntries(true)
end
]]

function WL.buildAddonMenu()
    if WL.addonMenu == nil then return nil end
    --Local "speed up arrays/tables" variables
    local addonVars =       WL.addonVars
    local settings =        WL.data
    local defaults =        WL.defaultSettings
    local defaultSettings = WL.defaultAccSettings
    local accSettings =     WL.accData

    --FCOItemSaver variables
    local FCOISenabled = false
    local fcoisMarkerIconsList = {}
    local fcoisMarkerIconsListValues = {}
    if FCOIS ~= nil and FCOIS.GetLAMMarkerIconsDropdown ~= nil then
        fcoisMarkerIconsList, fcoisMarkerIconsListValues = FCOIS.GetLAMMarkerIconsDropdown("standard", true)
        FCOISenabled = true
    end
    --The sort header tiebraker (2nd sort group) columns and the values for the settings
    local sortTiebrakerChoices = WL.sortTiebrakerChoices
    local sortTiebrakerChoicesValues = WL.sortTiebrakerChoicesValues

    --Set the variable to true to load the default values once, then set it to false again at the end of this function
    -->Will be set to true once the gear lam controls have been build properly -> At the last gear LAM control's 1st getFunc call
    setupGearLAMControlsDone = false

    --The LAM panel data
    local panelData    = {
        type                = "panel",
        name                = addonVars.settingsName,
        displayName         = addonVars.settingsDisplayName,
        author              = addonVars.addonAuthor,
        version             = tostring(addonVars.addonRealVersion),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/wls",
        website             = addonVars.addonWebsite
    }

    --The saved variables save types
    local savedVariablesOptions = {
        [1] = GetString(WISHLIST_LAM_SV_EACH_CHAR),
        [2] = GetString(WISHLIST_LAM_SV_ACCOUNT_WIDE),
    }

    --Build the submenu controls (checkboxes) for each LibSets supported language
    local function buildLibSetsSetNameLanguagesCheckboxes()
        local retTable = {}
        local libSets = WL.LibSets
        if libSets and libSets.supportedLanguages then
            local langVars = {}
            for langStr, isEnabled in pairs(libSets.supportedLanguages) do
                if isEnabled then
                    table.insert(langVars, langStr)
                end
            end
            table.sort(langVars)
            --Get the client language
            local clientLang = WL.clientLang
            local clientLangIsSupportedInLibSets = libSets.supportedLanguages[clientLang]
            --If the client language is not supported within LibSets use EN (English) as default
            --Add all other languages now
            for _, langStrVarSorted in ipairs(langVars) do
                --Add the checkbox now
                local name = langStrVarSorted
                local tooltip = tostring(langStrVarSorted)
                local data = { type = "checkbox", width = "half" }
                local disabledFunc = function() return false end
                local getFunc
                local setFunc
                local defaultSettingsCB
                getFunc = function() return settings.useLanguageForSetNames[langStrVarSorted] end
                setFunc = function(value) WL.data.useLanguageForSetNames[langStrVarSorted] = value
                    WL.preventerVars.runSetNameLanguageChecks = true
                end
                defaultSettingsCB     = function()
                    local defValue
                    if defaultSettings.useLanguageForSetNames[langStrVarSorted] then
                        defValue = defaultSettings.useLanguageForSetNames[langStrVarSorted]
                    end
                    --No default value found for the actual language
                    if defValue == nil then
                        --Is the current language the client language?
                        if langStrVarSorted == clientLang then
                            --Is the current language supported within LibSets?
                            if clientLangIsSupportedInLibSets then
                                defValue = true
                            else
                                defValue = false
                            end
                        else
                            defValue = false
                        end
                    end
                    return defValue
                end
                --Create the checkbox now
                local createdTraitCB = CreateControl(nil, name, tooltip, data, disabledFunc, getFunc, setFunc, defaultSettingsCB, nil)
                if createdTraitCB then
                    table.insert(retTable, createdTraitCB)
                end
            end
        end
        return retTable
    end
    local libSetsSetNameLanguages = buildLibSetsSetNameLanguagesCheckboxes()

    --Create the needed dropdown entries and icon picker entries
    --Gear
    buildGearsTexturesIconPickerEntries()
    buildGearsDropdownEntries(false)

    --The options panel data for the LAM settings of this addon
    local optionsData  = {
        {
            type              = "description",
            text              = GetString(WISHLIST_LAM_ADDON_DESC),
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_SAVEDVARIABLES),
        },
        {
            type = 'dropdown',
            name = GetString(WISHLIST_LAM_SV),
            tooltip = GetString(WISHLIST_LAM_SV_TT),
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[accSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        accSettings.saveMode = i
                    end
                end
            end,
            default = function() return defaultSettings.saveMode end,
            --warning = GetString(WISHLIST_WARNING_RELOADUI),
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_ADD_MAIN_MENU_BUTTON),
            tooltip = GetString(WISHLIST_LAM_ADD_MAIN_MENU_BUTTON_TT),
            getFunc = function() return settings.showMainMenuButton end,
            setFunc = function(value)
                settings.showMainMenuButton = value
            end,
            default = defaults.showMainMenuButton,
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_FORMAT_OPTIONS),
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_USE_24h_FORMAT),
            tooltip = GetString(WISHLIST_LAM_USE_24h_FORMAT_TT),
            getFunc = function() return accSettings.use24hFormat end,
            setFunc = function(value)
                accSettings.use24hFormat = value
            end,
            default = defaultSettings.use24hFormat,
            disabled = function() return accSettings.useCustomDateFormat ~= "" end
        },
        {
            type = "editbox",
            name = GetString(WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT),
            tooltip = GetString(WISHLIST_LAM_USE_CUSTOM_DATETIME_FORMAT_TT),
            getFunc = function() return accSettings.useCustomDateFormat end,
            setFunc = function(value)
                accSettings.useCustomDateFormat = value
            end,
            default = defaultSettings.useCustomDateFormat,
        },

        {
            type = "submenu",
            name = GetString(WISHLIST_LAM_SETNAME_LANGUAGES),
            tooltip = GetString(WISHLIST_LAM_SETNAME_LANGUAGES_TT),
            controls = libSetsSetNameLanguages,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_SCAN),
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_SCAN_ALL_CHARS),
            tooltip = GetString(WISHLIST_LAM_SCAN_ALL_CHARS_TT),
            getFunc = function() return settings.scanAllChars end,
            setFunc = function(value)
                settings.scanAllChars = value
            end,
            default = defaults.scanAllChars,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_ADD_ITEM),
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD),
            tooltip = GetString(WISHLIST_LAM_PRESELECT_CHAR_ON_ITEM_ADD_TT),
            getFunc = function() return settings.preSelectLoggedinCharAtItemAddDialog end,
            setFunc = function(value)
                settings.preSelectLoggedinCharAtItemAddDialog = value
            end,
            default = defaults.preSelectLoggedinCharAtItemAddDialog,
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_SORT),
        },
        {
            type = "dropdown",
            choices         = sortTiebrakerChoices,
            choicesValues   = sortTiebrakerChoicesValues,
            name = GetString(WISHLIST_LAM_SORT_USE_TIEBRAKER),
            tooltip = GetString(WISHLIST_LAM_SORT_USE_TIEBRAKER_TT),
            getFunc = function() return settings.useSortTiebraker end,
            setFunc = function(value)
                settings.useSortTiebraker = value
                --Rebuild the sortKeys now
                WL.sortKeys =  WL.getSortKeysWithTiebrakerFromSettings()
                --ReloadUI()
            end,
            default = defaults.useSortTiebraker,
            --requiresReload = true,
        },
        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_ITEM_FOUND),
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_ONLY_MAX_CP_TT),
            getFunc = function() return settings.notifyOnFoundItemsOnlyMaxCP end,
            setFunc = function(value)
                settings.notifyOnFoundItemsOnlyMaxCP = value
            end,
            default = defaults.notifyOnFoundItemsOnlyMaxCP,
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_ONLY_IN_DUNGEONS_TT),
            getFunc = function() return settings.notifyOnFoundItemsOnlyInDungeons end,
            setFunc = function(value)
                settings.notifyOnFoundItemsOnlyInDungeons = value
            end,
            default = defaults.notifyOnFoundItemsOnlyInDungeons,
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_USE_CHARACTERNAME_TT),
            getFunc = function() return settings.useItemFoundCharacterName end,
            setFunc = function(value)
                settings.useItemFoundCharacterName = value
            end,
            default = defaults.useItemFoundCharacterName,
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_USE_CSA),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_USE_CSA_TT),
            getFunc = function() return settings.useItemFoundCSA end,
            setFunc = function(value)
                settings.useItemFoundCSA = value
            end,
            default = defaults.useItemFoundCSA,
        },
        {
            type = "editbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_TEXT),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_TEXT_TT),
            isMultiline = false,
            isExtraWide = true,
            getFunc = function() return settings.itemFoundText end,
            setFunc = function(value)
                if value == "" then value = GetString(WISHLIST_LOOT_MSG_STANDARD) end
                settings.itemFoundText = value
            end,
            default = defaults.itemFoundText,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_SHOW_HISTORY_CHAT_OUTPUT_TT),
            getFunc = function() return settings.showItemFoundHistoryChatOutput end,
            setFunc = function(value)
                settings.showItemFoundHistoryChatOutput = value
            end,
            default = defaults.showItemFoundHistoryChatOutput,
        },
        {
            type = "editbox",
            name = GetString(WISHLIST_LAM_ITEM_FOUND_WHISPER_TEXT),
            tooltip = GetString(WISHLIST_LAM_ITEM_FOUND_WHISPER_TEXT_TT),
            isMultiline = false,
            isExtraWide = true,
            getFunc = function() return settings.askForItemWhisperText end,
            setFunc = function(value)
                if value == "" then value = GetString(WISHLIST_WHISPER_RECEIVER_QUESTION ) end
                settings.askForItemWhisperText = value
            end,
            default = defaults.askForItemWhisperText,
            width = "full",
        },

        --==============================================================================
        --Gear - Added 2022-09-27
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_GEAR),
        },
        {
            type = 'description',
            title = GetString(WISHLIST_LAM_GEAR_DESC),
        },
        {
            type = 'dropdown',
            name = GetString(WISHLIST_LAM_GEARS_DROPDOWN),
            tooltip = GetString(WISHLIST_LAM_GEARS_DROPDOWN_TT),
            choices =           gearsChoices,
            choicesValues =     gearsChoicesValues,
            choicesTooltips =   gearsChoicesTooltips,
            getFunc = function()
                --d("gears dropdown - GearId: " ..tostring(currentSettingsGearId))
                if currentSettingsGearId == nil then return end
                return currentSettingsGearId
            end,
            setFunc = function(value)
                --d("gears dropdown - GearId: " ..tostring(currentSettingsGearId) .. ", value: " ..tostring(value))
                currentSettingsGearId = nil
                WL.currentSettingsGearId = nil
                addNewGearEnabled = false
                editExistingGearEnabled = false
                deleteExistingGearWasDone = false
                if value == nil then return end

                editExistingGearEnabled = true
                currentSettingsGearId = value
                WL.currentSettingsGearId = currentSettingsGearId
            end,
            default = function() return 1 end,
            disabled = function() return #gearsChoices == 0 end,
            reference = "WishList_Settings_GearsDropdownControl",
        },
        {
            type = "button",
            name = GetString(WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS),
            tooltip = GetString(WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS_TT),
            func = function()
                updateWishListGearsWithFCOISGearMarkerIcons()
            end,
            isDangerous = true,
            disabled = function() return not FCOISenabled end,
            warning = GetString(WISHLIST_LAM_GEAR_MARKER_ICON_ADD_FCOIS_WARN),
            width="full",
        },

        {
            type = "button",
            name = GetString(WISHLIST_LAM_GEARS_BUTTON_ADD),
            tooltip = GetString(WISHLIST_LAM_GEARS_BUTTON_ADD_TT),
            func = function()
                --d("gear add - GearId: " ..tostring(currentSettingsGearId))
                addNewGear()
            end,
            isDangerous = false,
            disabled = function() return false end,
            --warning = GetString(WISHLIST_LAM_GEARS_BUTTON_ADD_WARN),
            width="half",
        },
        {
            type = "button",
            name = GetString(WISHLIST_LAM_GEARS_BUTTON_SAVE),
            tooltip = GetString(WISHLIST_LAM_GEARS_BUTTON_SAVE_TT),
            func = function()
                --d("gear save - addNewGearEnabled: " ..tostring(addNewGearEnabled) ..", nextFreeGearId: " ..tostring(nextFreeGearId).. ", currentGearId: " ..tostring(currentSettingsGearId))
                --currentSettingsGearId will be set at the setFunc of the "name" editBox control, if addNewGearEnabled was enabled.
                --Else it will be set as the dropdown box selected an exisitng entry and editExistingGearEnabled was set to true there.
                if addNewGearEnabled == true and currentSettingsGearId ~= nil then
                    saveCurrentGear()
                end
            end,
            isDangerous = false,
            disabled = function() return not addNewGearEnabled
                    or (currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil))
            end,
            --warning = GetString(WISHLIST_LAM_GEARS_BUTTON_ADD_WARN),
            width="half",
            reference = "WishList_Settings_GearSaveButton"
        },
        {
            type = "button",
            name = GetString(WISHLIST_LAM_GEARS_BUTTON_DELETE),
            tooltip = GetString(WISHLIST_LAM_GEARS_BUTTON_DELETE_TT),
            func = function()
                --d("gear delete - GearId: " ..tostring(currentSettingsGearId))
                if currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil) then return end
                deleteGear(currentSettingsGearId)
            end,
            isDangerous = true,
            disabled = function() return addNewGearEnabled or (currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil)) end,
            warning = GetString(WISHLIST_LAM_GEARS_BUTTON_DELETE_WARN),
            width="half",
        },
        {
            type = "editbox",
            name = GetString(WISHLIST_LAM_GEARS_NAME_EDIT),
            tooltip = GetString(WISHLIST_LAM_GEARS_NAME_EDIT_TT),
            isMultiline = false,
            isExtraWide = true,
            getFunc = function()
                --d("gear name - get func - GearId: " ..tostring(currentSettingsGearId) ..", editExistingGearEnabled: " ..tostring(editExistingGearEnabled) ..", deleteExistingGearWasDone: " ..tostring(deleteExistingGearWasDone) ..", addNewGearEnabled: " ..tostring(addNewGearEnabled) .. ", nextFreeGearId: " ..tostring(nextFreeGearId))
                if (not setupGearLAMControlsDone or editExistingGearEnabled or deleteExistingGearWasDone) and (currentSettingsGearId == nil or settings.gears[currentSettingsGearId] == nil or settings.gears[currentSettingsGearId].name == nil) then return "" end
                if addNewGearEnabled and nextFreeGearId ~= nil then return "Gear #" ..tostring(nextFreeGearId) end
                if not currentSettingsGearId then return "" end
                return settings.gears[currentSettingsGearId].name
            end,
            setFunc = function(value)
                --d("gear name - Set func - GearId: " ..tostring(currentSettingsGearId))
                if ((addNewGearEnabled and nextFreeGearId ~= nil) or (editExistingGearEnabled and currentSettingsGearId ~= nil)) then
                    if (value ~= nil and value ~= "") then
                        currentSettingsGearId = (addNewGearEnabled == true and nextFreeGearId) or currentSettingsGearId
                        WL.currentSettingsGearId = currentSettingsGearId
                        --d(">gear name - Set func - GearId: " ..tostring(currentSettingsGearId))
                        settings.gears[currentSettingsGearId] = settings.gears[currentSettingsGearId] or {}
                    else
                        currentSettingsGearId = nil
                        WL.currentSettingsGearId = currentSettingsGearId
                    end
                end
                if not editExistingGearEnabled or currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil) then return end
                if value ~= "" then
                    settings.gears[currentSettingsGearId].name = value
                    buildGearsDropdownEntries(true)
                end
            end,
            default = "",
            width = "full",
            disabled = function()
                if addNewGearEnabled or editExistingGearEnabled then return false end
                return true
            end,
            reference = "WishList_Settings_GearNameEditControl",
        },
        {
            type = "editbox",
            name = GetString(WISHLIST_LAM_GEARS_COMMENT_EDIT),
            tooltip = GetString(WISHLIST_LAM_GEARS_COMMENT_EDIT_TT),
            isMultiline = true,
            isExtraWide = true,
            getFunc = function()
                --d("gear comment - get func - GearId: " ..tostring(currentSettingsGearId))
                if (not setupGearLAMControlsDone or editExistingGearEnabled or deleteExistingGearWasDone) and (currentSettingsGearId == nil or settings.gears[currentSettingsGearId] == nil or settings.gears[currentSettingsGearId].comment == nil) then return "" end
                if addNewGearEnabled and nextFreeGearId ~= nil then return "" end
                if not currentSettingsGearId then return "" end
                return settings.gears[currentSettingsGearId].comment
            end,
            setFunc = function(value)
                --d("gear comment - Set func - GearId: " ..tostring(currentSettingsGearId))
                if not editExistingGearEnabled or currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil) then return end
                if currentSettingsGearId == nil then return end
                if value ~= nil then
                    settings.gears[currentSettingsGearId].comment = value
                    buildGearsDropdownEntries(true)
                end
            end,
            default = "",
            width = "full",
            disabled = function()
                return (addNewGearEnabled or not editExistingGearEnabled)
            end,
            reference = "WishList_Settings_GearCommentEditControl",
        },
        {
            type = "iconpicker",
            name = GetString(WISHLIST_LAM_GEAR_MARKER_ICON),
            tooltip = GetString(WISHLIST_LAM_GEAR_MARKER_ICON_TT),
            choices = gearMarkerTextures,
            --choicesValues = gearMarkerTexturesValues, --does not exist yet in LAM 2.0 r34! 2022-09-27
            choicesTooltips = gearMarkerTexturesTooltips,
            getFunc = function()
                --d("gear icon - get func - GearId: " ..tostring(currentSettingsGearId))
                if (not setupGearLAMControlsDone or editExistingGearEnabled or deleteExistingGearWasDone) and (currentSettingsGearId == nil or settings.gears[currentSettingsGearId] == nil or settings.gears[currentSettingsGearId].gearMarkerTextureId == nil) then return gearMarkerTextures[1] end
                if addNewGearEnabled and nextFreeGearId ~= nil then return gearMarkerTextures[1] end
                if not currentSettingsGearId then return gearMarkerTextures[1] end
                local textureId = settings.gears[currentSettingsGearId].gearMarkerTextureId
                return gearMarkerTextures[textureId]
            end,
            setFunc = function(texturePath)
                 --d("gear icon - Set func - GearId: " ..tostring(currentSettingsGearId))
                if not editExistingGearEnabled or currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil) then return end
                local textureId = gearMarkerTexturesLookup[texturePath]
                if textureId ~= nil then
                    settings.gears[currentSettingsGearId].gearMarkerTextureId = textureId
                    buildGearsDropdownEntries(true)
                end
            end,
            maxColumns = 5,
            visibleRows = 4,
            iconSize = 48,
            width = "half",
            default = gearMarkerTextures[1],
            disabled = function()
                return (addNewGearEnabled or not editExistingGearEnabled)
            end,
            reference = "WishList_Settings_GearIconPickerControl",
        },
        {
            type = "colorpicker",
            name = GetString(WISHLIST_LAM_GEAR_MARKER_ICON_COLOR),
            tooltip = GetString(WISHLIST_LAM_GEAR_MARKER_ICON_COLOR_TT),
            getFunc = function()
                --d("gear color - get func - GearId: " ..tostring(currentSettingsGearId))
                if (not setupGearLAMControlsDone or editExistingGearEnabled or deleteExistingGearWasDone) and (currentSettingsGearId == nil  or settings.gears[currentSettingsGearId] == nil or settings.gears[currentSettingsGearId].gearMarkerTextureColor == nil) then
                    setupGearLAMControlsDone = true
                    updateGearMarkerIconPreviewColor(1,1,1,1)

                    --Reset the deleteWasDone flag here as it is the last LAM control of the gear controls, and the refresh
                    --should reach it as last one
                    if deleteExistingGearWasDone == true then deleteExistingGearWasDone = false end

                    return 1, 1, 1, 1
                end
                if addNewGearEnabled and nextFreeGearId ~= nil then return 1, 1, 1, 1 end
                if not currentSettingsGearId then return 1, 1, 1, 1 end
                local currentColor = settings.gears[currentSettingsGearId].gearMarkerTextureColor
                updateGearMarkerIconPreviewColor(currentColor.r, currentColor.g, currentColor.b, currentColor.a)
                return currentColor.r, currentColor.g, currentColor.b, currentColor.a
            end,
            setFunc = function(r,g,b,a)
                --d("gear color - Set func - GearId: " ..tostring(currentSettingsGearId))
                setupGearLAMControlsDone = true
                if not editExistingGearEnabled or currentSettingsGearId == nil or (currentSettingsGearId ~= nil and settings.gears[currentSettingsGearId] == nil) then return end
                if currentSettingsGearId == nil then return end
                settings.gears[currentSettingsGearId].gearMarkerTextureColor = { ["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                buildGearsDropdownEntries(true)
                zo_callLater(function()
                    updateGearMarkerIconPreviewColor(r,g,b,a)
                end, 5)

            end,
            width="half",
            default = {1, 1, 1, 1},
            disabled = function()
                return (addNewGearEnabled or not editExistingGearEnabled)
            end,
            reference = "WishList_Settings_GearColorPickerControl",
        },

        --==============================================================================
        {
            type = 'header',
            name = GetString(WISHLIST_LAM_FCOIS),
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO),
            tooltip = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_TT),
            getFunc = function() return settings.fcoisMarkerIconAutoMarkLootedSetPart end,
            setFunc = function(value)
                settings.fcoisMarkerIconAutoMarkLootedSetPart = value
            end,
            default = defaults.fcoisMarkerIconAutoMarkLootedSetPart,
            disabled = function() return not FCOISenabled or settings.fcoisMarkerIconAutoMarkLootedSetPartPerChar end,
            width = "half",
        },
        {
            type = 'dropdown',
            name = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_ICON),
            tooltip = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_ICON),
            choices = fcoisMarkerIconsList,
            choicesValues = fcoisMarkerIconsListValues,
            scrollable = true,
            getFunc = function() return settings.fcoisMarkerIconLootedSetPart end,
            setFunc = function(value)
                settings.fcoisMarkerIconLootedSetPart = value
            end,
            default = defaults.fcoisMarkerIconLootedSetPart,
            disabled = function() return (not FCOISenabled or not settings.fcoisMarkerIconAutoMarkLootedSetPart) or settings.fcoisMarkerIconAutoMarkLootedSetPartPerChar end,
            width = "half",
        },
        {
            type = "description",
            text = GetString(WISHLIST_LAM_FCOIS_MARKER_ICONS_PER_CHAR),
        },
        {
            type = "checkbox",
            name = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR),
            tooltip = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_AUTO_PER_CHAR_TT),
            getFunc = function() return settings.fcoisMarkerIconAutoMarkLootedSetPartPerChar end,
            setFunc = function(value)
                settings.fcoisMarkerIconAutoMarkLootedSetPartPerChar = value
            end,
            default = defaults.fcoisMarkerIconAutoMarkLootedSetPartPerChar,
            disabled = function() return not FCOISenabled or settings.fcoisMarkerIconAutoMarkLootedSetPart end,
            width = "full",
        },
    } -- optionsData
    --For each character: Add a FCOIS marker icon dropdown
    WL.checkCharsData()
    local charsOfAccount = WL.charsData
    for _, charsData in ipairs(charsOfAccount) do
        if charsData and charsData.nameClean and charsData.id then
            local lamDropdownTable = {
                type = 'dropdown',
                name = charsData.nameClean,
                tooltip = GetString(WISHLIST_LAM_FCOIS_MARK_ITEM_ICON),
                choices = fcoisMarkerIconsList,
                choicesValues = fcoisMarkerIconsListValues,
                scrollable = true,
                getFunc = function() return settings.fcoisMarkerIconLootedSetPartPerChar[charsData.id] end,
                setFunc = function(value)
                    settings.fcoisMarkerIconLootedSetPartPerChar[charsData.id] = value
                end,
                default = defaults.fcoisMarkerIconLootedSetPart,
                disabled = function() return (not FCOISenabled or not settings.fcoisMarkerIconAutoMarkLootedSetPartPerChar) or settings.fcoisMarkerIconAutoMarkLootedSetPart end,
                width = "half",
            }
            table.insert(optionsData, lamDropdownTable)
        end
    end
    --Register the addon panel
    WL.addonMenuPanel = WL.addonMenu:RegisterAddonPanel(addonVars.addonName .. "_SettingsMenu", panelData)
    WL.addonMenu:RegisterOptionControls(addonVars.addonName .. "_SettingsMenu", optionsData)
    --CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", panelControlsCreated)
    --CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", panelOpened)
    WL.preventerVars.addonMenuBuild = true
end

--Open the WishList LAM settings
function WL.ShowLAMSettings()
    if WL.addonMenu == nil or WL.addonMenuPanel == nil then return nil end
    WL.addonMenu:OpenToPanel(WL.addonMenuPanel)
end