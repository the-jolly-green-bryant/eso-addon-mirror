if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

local addonVars = FCOMounty.addonVars
local addonName = addonVars.addonName
local CM = CALLBACK_MANAGER

local updateMountsAndZonesDropdowns

function FCOMounty.buildAddonMenu()
    local lang = FCOMounty.lang or GetCVar("language.2")

    local settings = FCOMounty.settingsVars.settings
    if not settings or not FCOMounty.LAM then return false end
    local defaults = FCOMounty.settingsVars.defaults

    local panelData = {
        type 				= 'panel',
        name 				= addonVars.addonNameMenu,
        displayName 		= addonVars.addonNameMenuDisplay,
        author 				= addonVars.addonAuthor,
        version 			= tostring(addonVars.addonVersion),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/fcoms",
        website             = addonVars.addonWebsite,
        feedback            = addonVars.addonFeedback,
        donation            = addonVars.addonDonation,
    }

    local savedVariablesOptions = {
        [1] = 'Each character',
        [2] = 'Account wide'
    }

    --Build the LAM dropdown boxes for the mounts
    local function BuildMountDropdown()
--d("[FCOMounty]BuildMountDropdown")
        local mountValues = {}
        local mountNames = {}
        table.insert(mountNames, FCOM_NONE_ENTRIES)
        table.insert(mountValues, 0)
        settings.defaultMount = 0
        local mountData = FCOMounty.MountData
        if mountData ~= nil then
            local cnt = 0
            for mountId, mountName in pairs(mountData) do
                table.insert(mountValues, mountId)
                table.insert(mountNames, mountName)
                cnt = cnt + 1
            end
        end
        FCOMounty.DropdownMountNames  = mountNames
        FCOMounty.DropdownMountValues = mountValues
    end
    BuildMountDropdown()

    --Build the LAM dropdown boxes for the zones
    local function BuildZoneDropdown()
--d("[FCOMounty]BuildZoneDropdown")
        local zoneNameDropDownBoxes = {}
        local zoneValueDropDownBoxes = {}
        local subZoneNameDropdownBoxes = {}
        local subZoneValueDropdownBoxes = {}
        local zoneData = FCOMounty.ZoneData
        if zoneData ~= nil then
            table.insert(zoneNameDropDownBoxes, FCOM_NONE_ENTRIES)
            table.insert(zoneValueDropDownBoxes, FCOM_NONE_ENTRIES)
            for zone, subZones in pairs(zoneData) do
                local zoneNameOverwriteId = 0
                local zoneNameOverwrite = ""
                for subZone, value in pairs(subZones) do
                    --Got a zoneId for the zone, then get this entry and buiold the name of the zone via LibZone localized data!
                    if subZone == FCOM_ZONE_ID_STRING then
                        if FCOMounty.libZone ~= nil and tonumber(value) ~= 0 then
                            zoneNameOverwriteId = tonumber(value)
                            zoneNameOverwrite = FCOMounty.libZone:GetZoneName(tonumber(value), lang)
                        end
                    end
                    --Exclude subzone ""_mappedZoneName" as it is only a mapped name for the zone!
                    if subZone ~= FCOM_ZONE_ID_STRING and subZone ~= FCOM_ZONE_MAPPING_STRING then
                        --Subzone is a boolean or subzone is an alternative/mapping name string?
                        local valueIsSubZoneName = (type(value) == "string" and value ~= "")
                        local valueIsZoneId = not valueIsSubZoneName and (type(value) == "number")
                        if (type(value) == "boolean" and value == true) or valueIsSubZoneName or valueIsZoneId then
                            if subZoneValueDropdownBoxes[zone] == nil then
                                subZoneValueDropdownBoxes[zone] = {}
                                subZoneNameDropdownBoxes[zone] = {}
                            end
                            subZoneValueDropdownBoxes[zone][subZone] = subZone
                            local subZoneName = string.gsub(subZone, '_base', '')
                            if valueIsSubZoneName then
                                subZoneName = value
                            else
                                --subZoneId was provided?
                                if valueIsZoneId then
                                    subZoneName = FCOMounty.libZone:GetZoneName(tonumber(value), lang)
                                else
                                    subZoneName = string.gsub(subZone, '_base', '')
                                end
                            end
                            subZoneName = zo_strformat('<<C:1>>', subZoneName)
                            subZoneNameDropdownBoxes[zone][subZone] = subZoneName
                        end
                    end
                end -- for subZone, value
                --Add the zone table entry now
                local zoneName, subZoneName
                if zoneNameOverwrite ~= "" then
                    zoneName = zoneNameOverwrite
                else
                    zoneName, subZoneName = FCOMounty.MapZoneAndSubZoneNames(zone, nil, zoneNameOverwrite)
                end
                zoneName = zo_strformat('<<C:1>>', zoneName)
                table.insert(zoneNameDropDownBoxes, zoneName)
                table.insert(zoneValueDropDownBoxes, zone)
            end -- for zone, subZones
        end
        FCOMounty.DropdownZoneNames     = zoneNameDropDownBoxes
        FCOMounty.DropdownZoneValues    = zoneValueDropDownBoxes
        FCOMounty.DropdownSubZoneNames  = subZoneNameDropdownBoxes
        FCOMounty.DropdownSubZoneValues = subZoneValueDropdownBoxes
    end
    BuildZoneDropdown()

    --Create function to update the data as LAM re-opens
    updateMountsAndZonesDropdowns = function()
--d("[FCOMounty]updateMountsAndZonesDropdowns")
        BuildMountDropdown()
        if FCOMounty_LAM_Dropdown_Mounts_For_Mount ~= nil then
            FCOMounty_LAM_Dropdown_Mounts_For_Mount:UpdateChoices(FCOMounty.DropdownMountNames, FCOMounty.DropdownMountValues)
        end
        if FCOMounty.preventerVars.ZoneDataWasUpdatedNowUpdateLAMDropdowns == true then
            FCOMounty.preventerVars.ZoneDataWasUpdatedNowUpdateLAMDropdowns = false
            BuildZoneDropdown()
            if FCOMounty_LAM_Dropdown_Zones_For_Mount ~= nil then
                FCOMounty_LAM_Dropdown_Zones_For_Mount:UpdateChoices(FCOMounty.DropdownZoneNames, FCOMounty.DropdownZoneValues)
            end
            if FCOMounty_LAM_Dropdown_SubZones_For_Mount ~= nil then
                FCOMounty_LAM_Dropdown_SubZones_For_Mount:UpdateChoices(FCOMounty.DropdownSubZoneNames, FCOMounty.DropdownSubZoneValues)
            end
        end
    end

    --Hide the mount selection dropdown
    local function SetMountSelectDropdownBoxState(state)
        state = state or false
        if FCOMounty_LAM_Dropdown_Mounts_For_Mount ~= nil then
            FCOMounty_LAM_Dropdown_Mounts_For_Mount:SetHidden(not state)
        end
    end

    --Change the entries of the LAM subZone dropdownbox
    local function ChangeSubZoneEntries(zone)
--d("ChangeSubZoneEntries - zone: " .. tostring(zone))
        if zone == nil then return false end
        FCOMounty.LAMDropdownSubZoneNames = {}
        FCOMounty.LAMDropdownSubZoneValues = {}
        --Is the subzone dropdownbox there?
        if FCOMounty_LAM_Dropdown_SubZones_For_Mount ~= nil then
            --Hide the mount selection dropdown box
            SetMountSelectDropdownBoxState(false)
            --Is the zone name "-NONE-"?
            if zone == FCOM_NONE_ENTRIES then

                table.insert(FCOMounty.LAMDropdownSubZoneNames, FCOM_NONE_ENTRIES)
                table.insert(FCOMounty.LAMDropdownSubZoneValues, FCOM_NONE_ENTRIES)

            else
                --Loop over subzone array with the given zone name
                for zoneName, subZoneData in pairs(FCOMounty.DropdownSubZoneNames) do
                    if zoneName == zone then
                        table.insert(FCOMounty.LAMDropdownSubZoneNames, FCOM_ALL_ENTRIES)
                        table.insert(FCOMounty.LAMDropdownSubZoneValues, FCOM_ALL_ENTRIES)
                        for subZoneValue, subZoneName in pairs(subZoneData) do
                            table.insert(FCOMounty.LAMDropdownSubZoneNames, subZoneName)
                            table.insert(FCOMounty.LAMDropdownSubZoneValues, subZoneValue)
                        end
                    end
                end
            end
            local numEntries = #FCOMounty.LAMDropdownSubZoneNames
            if numEntries > 0 then
--d(">updateChoices of SUBZONES")
                FCOMounty_LAM_Dropdown_SubZones_For_Mount:UpdateChoices(FCOMounty.LAMDropdownSubZoneNames, FCOMounty.LAMDropdownSubZoneValues)
                if not FCOM.preventerVars.doNotUpdateSubZoneValue then
                    local firstEntry = FCOMounty.LAMDropdownSubZoneValues[1]
                    FCOMounty.LAMSelectedSubZone = firstEntry
                    --And now select the default entry of the subZones
--d(">updateValue of SUBZONES to: " ..tostring(firstEntry))
                    FCOMounty_LAM_Dropdown_SubZones_For_Mount:UpdateValue(false, firstEntry)
                end
            end
        else
            d(">LAM dropdown not found: FCOMounty_LAM_Dropdown_SubZones_For_Mount")
        end
        FCOM.preventerVars.doNotUpdateSubZoneValue = false
    end

    --Change the entries of the LAM random mounts dropdownbox
    local randomMountsForZoneAndSubZoneNames = {}
    local randomMountsForZoneAndSubZone = {}
    local function ChangeRandomMountEntries(zone, subzone)
        FCOM.preventerVars.doNotUpdateRandomMountsValue = true
        --Is the subzone dropdownbox there?
        if FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone ~= nil then
            randomMountsForZoneAndSubZone = {}
            randomMountsForZoneAndSubZoneNames = {}
            --Hide the mount selection dropdown box
            --SetMountSelectDropdownBoxState(false)
            --Is the zone name "-NONE-"?
            if zone ~= nil and subzone ~= nil and zone ~= FCOM_NONE_ENTRIES and subzone ~= FCOM_NONE_ENTRIES then
                local randomMountsOfZone = settings.zone2RandomMounts[zone]
                if randomMountsOfZone ~= nil then
                    local randomMountsOfSubZone = randomMountsOfZone[subzone]
                    if randomMountsOfSubZone ~= nil then
                        local mountData = FCOMounty.MountData
                        for mountId, _ in pairs(randomMountsOfSubZone) do
                            table.insert(randomMountsForZoneAndSubZone, mountId)
                            if mountData ~= nil then
                                local mountName = mountData[mountId]
                                if mountName and mountName ~= "" then
                                    table.insert(randomMountsForZoneAndSubZoneNames, mountName)
                                end
                            end
                        end
                    end
                end
            end
            FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone:UpdateChoices(randomMountsForZoneAndSubZoneNames, randomMountsForZoneAndSubZone)
        else
            d(">LAM dropdown not found: FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone")
        end
        FCOM.preventerVars.doNotUpdateRandomMountsValue = false
    end

    --Change the settings and add/remove the currently selected mount from zone & subzones random mounts entries
    local function changeRandomMountInSettings(doAddEntry)
--d("[FCOMounty]changeRandomMountInSettings - doAddEntry: "..tostring(doAddEntry))
        local zone = FCOMounty.LAMSelectedZone
        local subzone = FCOMounty.LAMSelectedSubZone
        --Zone and subzone are given and not "NONE"?
        if not settings.randomizeMountsForZoneAndSubzone
                or zone == nil or zone == FCOM_NONE_ENTRIES
                or subzone == nil or subzone == FCOM_NONE_ENTRIES then
            return false
        end
        --Is a mount selected?
        local mountId
        local entryChanged = false
        --Add an entry to settings
        if doAddEntry == true then
            mountId = FCOMounty.LoadMountIdFromSettings(zone, subzone)
            if mountId == nil or mountId == 0 then return end
            settings.zone2RandomMounts[zone] = settings.zone2RandomMounts[zone] or {}
            settings.zone2RandomMounts[zone][subzone] = settings.zone2RandomMounts[zone][subzone] or {}
            if settings.zone2RandomMounts[zone][subzone][mountId] == nil then
                FCOMounty.settingsVars.settings.zone2RandomMounts[zone][subzone][mountId] = true
                entryChanged = true
            end
        else
            --Remove entry
            if FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone == nil then return false end
            local selectedItemData = FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone.combobox.m_comboBox:GetSelectedItemData()
            if not selectedItemData then return false end
            mountId = selectedItemData.value
            if mountId == nil or mountId == 0 then return end
            if settings.zone2RandomMounts[zone] and settings.zone2RandomMounts[zone][subzone] and
                    settings.zone2RandomMounts[zone][subzone][mountId] ~= nil then
                FCOMounty.settingsVars.settings.zone2RandomMounts[zone][subzone][mountId] = nil
                entryChanged = true
            end
        end
        --Update the LAM dropdown box of random mounts now
        if entryChanged == true then
            ChangeRandomMountEntries(zone, subzone)
        end
    end

    --Get the current zone and subzone and update the LAM drodpwons to these values
    local function GetCurrentZoneAndUpdateLAMDropdowns()
        --Get the chosen mount for this zone and subzone
        local zone, subZone = FCOMounty.GetZoneAndSubzone()
--d(">GetCurrentZoneAndUpdateLAMDropdowns - zone: " .. tostring(zone) .. ", subZone: " .. tostring(subZone))
        local firstEntry = FCOMounty.LAMDropdownSubZoneValues[1]
        FCOMounty.LAMSelectedSubZone = firstEntry
        FCOM.preventerVars.doNotUpdateSubZoneValue = true
        if zone ~= nil then
            --Set the zone to the current one
            FCOMounty.LAMSelectedZone = zone
            FCOMounty_LAM_Dropdown_Zones_For_Mount:UpdateValue(false, zone)
            if subZone ~= nil then
                --Set the subZone to the current one
                FCOMounty.LAMSelectedSubZone = subZone
                FCOMounty_LAM_Dropdown_SubZones_For_Mount:UpdateValue(false, subZone)
            else
                --Set the subZone to -ALL-
                FCOMounty_LAM_Dropdown_SubZones_For_Mount:UpdateValue(false, firstEntry)
            end
        else
            --Set the zone to -NONE-
            FCOMounty_LAM_Dropdown_Zones_For_Mount:UpdateValue(false, FCOMounty.DropdownZoneValues[1])
            --Set the subZone to -NONE-
            FCOMounty_LAM_Dropdown_SubZones_For_Mount:UpdateValue(false, firstEntry)
        end
    end

    --Get the currently selected mount visible enhancement settings form the LAM settings panel of current zone and subzone
    local function getLAMMountVisibleEnhancementSettings(zone, subZone)
        local mountVisibleEnhancementData = {}
        if settings.zone2Mount[zone] == nil then return end
        if settings.zone2Mount[zone][subZone] == nil then return end
        mountVisibleEnhancementData[RIDING_TRAIN_SPEED] = settings.zone2Mount[zone][subZone].mountEnhancements[RIDING_TRAIN_SPEED]
        mountVisibleEnhancementData[RIDING_TRAIN_STAMINA] = settings.zone2Mount[zone][subZone].mountEnhancements[RIDING_TRAIN_STAMINA]
        mountVisibleEnhancementData[RIDING_TRAIN_CARRYING_CAPACITY] = settings.zone2Mount[zone][subZone].mountEnhancements[RIDING_TRAIN_CARRYING_CAPACITY]
        return mountVisibleEnhancementData
    end

    --Check if the mount for the current zone is changed and set it to the new one, but only if not mounted
    local function checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone(zoneInSettings, subZoneInSettings, onlyUpdateMountVisibleEnhancements, updateMountVisibleEnhancements)
        onlyUpdateMountVisibleEnhancements = onlyUpdateMountVisibleEnhancements or false
        updateMountVisibleEnhancements = updateMountVisibleEnhancements or false
        local isCharMounted = IsMounted()
--d("[FCOMounty]checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone - isMounted: " .. tostring(isCharMounted) .. ", zone: " ..tostring(zoneInSettings) .. ", subZone: " ..tostring(subZoneInSettings) .. ", updateMountEnhancements: " ..tostring(updateMountVisibleEnhancements) .. ", onlyUpdateMountEnh: " ..tostring(onlyUpdateMountVisibleEnhancements))
        --Are we currently mounted? Then do not change anything
        --if not isCharMounted or onlyUpdateMountVisibleEnhancements or updateMountVisibleEnhancements then
        local zone, subZone = FCOMounty.GetZoneAndSubzone()
        if ((isCharMounted and zoneInSettings == zone and (subZoneInSettings == subZone or subZoneInSettings == FCOM_ALL_ENTRIES))
            or not isCharMounted) or onlyUpdateMountVisibleEnhancements or updateMountVisibleEnhancements then
            --Shall the subZone's -ALL- mount be used for all subzones of this zone?
            if settings.useSubzoneALLMountInAllSubzones then
                subZone = FCOM_ALL_ENTRIES
                zoneInSettings = zone
                onlyUpdateMountVisibleEnhancements = false
            end
--d(">>>Zone: " ..tostring(zone) .. "/" .. tostring(zoneInSettings) .. ", subZone: " ..tostring(subZone).."/" ..tostring(subZoneInSettings))
            if zone == zoneInSettings and subZone == subZoneInSettings then
                --d(">>>Activate mount")
                FCOMounty.ActivateMountForZone(zone, subZone, true, onlyUpdateMountVisibleEnhancements, updateMountVisibleEnhancements)
            end
        end
    end

    FCOMounty.FCOSettingsPanel = FCOMounty.LAM:RegisterAddonPanel(addonName .. "_LAM", panelData)
    local gameSettingsShowMountEnhancement = {}

    --LAM 2.0 callback function if the panel was created
    local FCOMLAMPanelCreated = function(panel)
        if panel == FCOMounty.FCOSettingsPanel then
--d("FCOMLAMPanelCreated")
            --Build the standard subzone entries with the "-NONE-" entry
            ChangeSubZoneEntries(FCOM_NONE_ENTRIES)
            --Get the game settings for "show mount enhancements stamina, speed and inventory space"
            gameSettingsShowMountEnhancement = FCOMounty.GetGameSettingsMountVisibleEnhancements()
            --Preset the table as "empty". Will be updated on subZone change!
            ChangeRandomMountEntries(nil, nil)
        end
    end
    local function FCOMLAMPanelOpened(panel)
        if panel == FCOMounty.FCOSettingsPanel then
            updateMountsAndZonesDropdowns()
        end

    end

    CM:RegisterCallback("LAM-PanelControlsCreated", FCOMLAMPanelCreated)
    CM:RegisterCallback("LAM-PanelOpened", FCOMLAMPanelOpened)

    local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

        {
            type = 'description',
            text = 'Advance your mount',
        },
        {
            type = 'dropdown',
            name = 'Settings save type',
            tooltip = 'Use account wide settings for all your characters, or save them seperatley for each character?',
            choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[FCOMounty.settingsVars.defaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        FCOMounty.settingsVars.defaultSettings.saveMode = i
                    end
                end
            end,
            requiresReload = true,
        },
        --==============================================================================
        {
            type = 'header',
            name = 'Stable',
        },
        {
            type = "checkbox",
            name = 'Hide feed button: Speed',
            tooltip = 'Hide the stable\'s feed for speed button so you do not accidantly click it',
            getFunc = function() return settings.stableFeedSettings[RIDING_TRAIN_SPEED] end,
            setFunc = function(value) settings.stableFeedSettings[RIDING_TRAIN_SPEED] = value
            end,
            default = defaults.stableFeedSettings[RIDING_TRAIN_SPEED],
            disabled = function() return FCOMounty.stableSkills[RIDING_TRAIN_SPEED].maxed or FCOMounty.checkIfOtherStableButtonsAreMaxedOut(RIDING_TRAIN_SPEED) end,
            width="full",
            --requiresReload = true,
        },
        {
            type = "checkbox",
            name = 'Hide feed button: Stamina',
            tooltip = 'Hide the stable\'s feed for stamina button so you do not accidantly click it',
            getFunc = function() return settings.stableFeedSettings[RIDING_TRAIN_STAMINA] end,
            setFunc = function(value) settings.stableFeedSettings[RIDING_TRAIN_STAMINA] = value
            end,
            default = defaults.stableFeedSettings[RIDING_TRAIN_STAMINA],
            disabled = function() return FCOMounty.stableSkills[RIDING_TRAIN_STAMINA].maxed or FCOMounty.checkIfOtherStableButtonsAreMaxedOut(RIDING_TRAIN_STAMINA) end,
            width="full",
            --requiresReload = true,
        },
        {
            type = "checkbox",
            name = 'Hide feed button: Carry',
            tooltip = 'Hide the stable\'s feed for carry button so you do not accidantly click it',
            getFunc = function() return settings.stableFeedSettings[RIDING_TRAIN_CARRYING_CAPACITY] end,
            setFunc = function(value) settings.stableFeedSettings[RIDING_TRAIN_CARRYING_CAPACITY] = value
            end,
            default = defaults.stableFeedSettings[RIDING_TRAIN_CARRYING_CAPACITY],
            disabled = function() return FCOMounty.stableSkills[RIDING_TRAIN_CARRYING_CAPACITY].maxed or FCOMounty.checkIfOtherStableButtonsAreMaxedOut(RIDING_TRAIN_CARRYING_CAPACITY) end,
            width="full",
            --requiresReload = true,
        },
        --==============================================================================
        {
            type = 'header',
            name = 'Mount settings',
        },
        {
            type = "checkbox",
            name = 'Change mount: Preset for zone',
            tooltip = 'If you change the mount manually by help of the collectibles e.g.: Preset this mount as the current zone\'s & subzone\'s mount.\nDoes not work if randomized mounts are enabled!',
            getFunc = function() return settings.autoPresetForZoneOnNewMount end,
            setFunc = function(value) settings.autoPresetForZoneOnNewMount = value
            end,
            disabled = function() return settings.randomizeMountsForZoneAndSubzone end,
            default = defaults.autoPresetForZoneOnNewMount,
            width="full",
        },
        {
            type = "checkbox",
            name = 'Change mount: Preset for ALL sub zones',
            tooltip = 'If you change the mount manually by help of the collectibles e.g.: Preset this mount as the current zone\'s mount & for ALL subzones of the zone.\nDoes not work if randomized mounts are enabled!',
            getFunc = function() return settings.autoPresetForSubZoneALLOnNewMount end,
            setFunc = function(value) settings.autoPresetForSubZoneALLOnNewMount = value
            end,
            disabled = function() return settings.randomizeMountsForZoneAndSubzone or not settings.autoPresetForZoneOnNewMount end,
            default = defaults.autoPresetForSubZoneALLOnNewMount,
            width="full",
        },
        {
            type = "checkbox",
            name = FCOM_ALL_ENTRIES .. ": Use this mount for all subzones",
            tooltip = "If you set a mount for the subzone " .. FCOM_ALL_ENTRIES .. " and enable this setting, the selected mount will be used for all subzones, even if you have specified another mount for the different subzones.\nAttention: If you have enabled the randomized mounts the subZone entry \'" .. FCOM_ALL_ENTRIES .. "\' will be used to detect the random mount for the zone!",
            getFunc = function() return settings.useSubzoneALLMountInAllSubzones end,
            setFunc = function(value)
                settings.useSubzoneALLMountInAllSubzones = value
                local zoneToUse, subZoneToUse = FCOMounty.GetZoneAndSubzone()
                local onlyUpdateMountEnh        = false
                local doUpdateMountEnhancements = true
                if value == true then
                    subZoneToUse = FCOM_ALL_ENTRIES
                end
                if zoneToUse ~= nil and zoneToUse ~= "" and subZoneToUse ~= nil and subZoneToUse ~= "" then
                    --Check if the mount for the current zone is changed and set it to the new one, but only if not mounted
                    checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone(zoneToUse, subZoneToUse, onlyUpdateMountEnh, doUpdateMountEnhancements)
                end
            end,
            disabled = function() return false end, --return settings.randomizeMountsForZoneAndSubzone end,
            default = defaults.useSubzoneALLMountInAllSubzones,
            width="full",
        },

        --ZONEs
        {
            type = 'header',
            name = 'Mounts - Zone & subzone',
        },
        {
            type = "description",
            text = "First choose a zone, then a subzone (except " .. FCOM_NONE_ENTRIES .. ")\nA new dropdownbox containing your available mounts will get visible. Select the mount you want to use for the selected combination of zone & subZone.\nMounts will ONLY change a few seconds after you unmount or if you switch a zone.",
            title = "Mounts Zone & subzone - How does it work?",
        },
        {
            type = "dropdown",
            name = "Zone", -- or string id or function returning a string
            tooltip = "Choose the zone for the mount", -- or string id or function returning a string (optional)
            choices = FCOMounty.DropdownZoneNames,
            choicesValues = FCOMounty.DropdownZoneValues, -- if specified, these values will get passed to setFunc instead (optional)
            getFunc = function()
                local getVar = FCOM_NONE_ENTRIES
                if FCOMounty.LAMSelectedZone ~= nil then
                    getVar = FCOMounty.LAMSelectedZone
                end
--d("ZONE DROPDOWN: GetFunc - getVar: " .. tostring(getVar))
                return getVar
            end,
            setFunc = function(zoneName)
                if zoneName ~= nil and zoneName ~= "" and zoneName ~= FCOM_NONE_ENTRIES then
                    FCOMounty.LAMSelectedZone = zoneName
                    --Enable the mount dropdown box now
                    SetMountSelectDropdownBoxState(true)
                else
                    FCOMounty.LAMSelectedZone = nil
                    --Disable the mount dropdown box now
                    SetMountSelectDropdownBoxState(false)
                end
                --FCOMounty.LAMSelectedSubZone = nil
                --If zone is changed, update the subZone dropdown accordingly
--d("ZONE DROPDOWN: SetFunc - zoneName: " .. tostring(zoneName) .. ", LAMselectedZone: " .. tostring(FCOMounty.LAMSelectedZone))
                ChangeSubZoneEntries(zoneName)
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
            width = "half", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            --disabled = function() return 1 == 2 end, --or boolean (optional)
            default = function()
                --Choose first entry of the dropdown: "All zones"
                --ChangeSubZoneEntries(FCOM_NONE_ENTRIES)
                return FCOMounty.DropdownZoneValues[1]
            end, -- default value or function that returns the default value (optional)
            reference = "FCOMounty_LAM_Dropdown_Zones_For_Mount" -- unique global reference to control (optional)
        },
        --SUB ZONEs
        {
            type = "dropdown",
            name = "Subzone", -- or string id or function returning a string
            tooltip = "Choose the subzone of the currently chosen zone for the mount", -- or string id or function returning a string (optional)
            choices = FCOMounty.LAMDropdownSubZoneNames,
            choicesValues = FCOMounty.LAMDropdownSubZoneValues, -- if specified, these values will get passed to setFunc instead (optional)
            getFunc = function()
                local getVar = FCOM_NONE_ENTRIES
                if FCOMounty.LAMSelectedSubZone ~= nil then
                    getVar = FCOMounty.LAMSelectedSubZone
                end
--d("SUBZONE DROPDOWN: GetFunc - getVar: " .. tostring(getVar))
                return getVar
            end,
            setFunc = function(subZoneName)
                if subZoneName ~= nil and subZoneName ~= "" and subZoneName ~= FCOM_NONE_ENTRIES then
                    FCOMounty.LAMSelectedSubZone = subZoneName
                    --Enable the mount dropdown box now
                    SetMountSelectDropdownBoxState(true)
                    --Update the dropdown for the random mounts of each zone & subZone
                    ChangeRandomMountEntries(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone)
                else
                    FCOMounty.LAMSelectedSubZone = nil
                    --Disable the mount dropdown box now
                    SetMountSelectDropdownBoxState(false)
                    --Update the dropdown for the random mounts of the zone & subZone -> Clear it!
                    ChangeRandomMountEntries(nil, nil)
                end
--d("SUBZONE DROPDOWN: SetFunc - subZoneName: " .. tostring(subZoneName) .. ", LAMselectedSubZone: " .. tostring(FCOMounty.LAMSelectedSubZone))
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
            width = "half", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            --disabled = function() return 1 == 2 end, --or boolean (optional)
            default = function()
                return FCOMounty.DropdownSubZoneValues[1]
            end, -- default value or function that returns the default value (optional)
            reference = "FCOMounty_LAM_Dropdown_SubZones_For_Mount" -- unique global reference to control (optional)
        },
        --MOUNTs
        {
            type = "dropdown",
            name = "Mount for zone & subzone", -- or string id or function returning a string
            tooltip = "Choose the mount for the selected zone and subzone", -- or string id or function returning a string (optional)
            choices = FCOMounty.DropdownMountNames,
            choicesValues = FCOMounty.DropdownMountValues, -- if specified, these values will get passed to setFunc instead (optional)
            getFunc = function()
                --Get the chosen mount for the zone and subzone from the settings
                local chosenMountId = FCOMounty.LoadMountIdFromSettings(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone) or settings.defaultMount
                return chosenMountId
            end,
            setFunc = function(mountId)
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil then
                    --Get the visible mount enhancement settings of the zone and subzone
                    local mountVisibleEnhancementSettings = getLAMMountVisibleEnhancementSettings(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone)
                    --Save the chosen mount to the settings
                    FCOMounty.SaveMountIdToSettings(mountId, true, FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone, mountVisibleEnhancementSettings) --save the mountId to the settings and activate it now (change collectible in the background)
                    --Check if the mount for the current zone is changed and set it to the new one, but only if not mounted
                    checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone, false, false)
                end
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
            width = "full", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            disabled = function() return FCOMounty.LAMSelectedZone == nil or FCOMounty.LAMSelectedSubZone == nil end, --or boolean (optional)
            --default = function() return   end, -- default value or function that returns the default value (optional)
            reference = "FCOMounty_LAM_Dropdown_Mounts_For_Mount" -- unique global reference to control (optional)
        },
        {
            type = "button",
            name = "Current zone", -- string id or function returning a string
            func = function()
                GetCurrentZoneAndUpdateLAMDropdowns()
            end,
            tooltip = "Select the current zone & subzone", -- string id or function returning a string (optional)
            width = "full", --or "half" (optional)
            reference = "FCOMounty_LAM_Button_GetCurrentZone", -- unique global reference to control (optional)
        },

        --Randomized MOUNTs for a zone & subzone
        {
            type = "checkbox",
            name = 'Randomize mounts zone & subzone',
            tooltip = 'Add mounts to the selected zone & subzone combination and randomize the usage of these selected mounts each time you change a zone, or unmount.\nIf the \'Use this mount for all subzones\' checkbox is enabled the mounts mzst be added at zone (any) + subzone = \'' .. FCOM_ALL_ENTRIES .. '\'',
            getFunc = function()
                return settings.randomizeMountsForZoneAndSubzone
            end,
            setFunc = function(value)
                settings.randomizeMountsForZoneAndSubzone = value
            end,
            default = defaults.randomizeMountsForZoneAndSubzone,
            width="half",
        },
        {
            type = "description",
            text = "Add & remove: First choose a zone & subzone above (except " .. FCOM_NONE_ENTRIES .. ")\n-Add: Select a mount from the dropdown \"Mount for zone & subzone\" and click on the \"+\" button.\n-Remove: Select a mount in the dropdown \"Randomized mounts for zone & subzone\" and click on the \"-\" button.",
            title = "Randomized mounts - How does it work?",
        },
        {
            type = "button",
            name = "+", -- string id or function returning a string
            func = function()
                --Add the chosen mount to the random mounts of the current zone & subzone selection
                changeRandomMountInSettings(true)
            end,
            tooltip = "Add mount to randomized for zone & subzone", -- string id or function returning a string (optional)
            width = "half", --or "half" (optional)
            disabled = function()
                if not settings.randomizeMountsForZoneAndSubzone then return true end
                if FCOMounty_LAM_Dropdown_Mounts_For_Mount and FCOMounty_LAM_Dropdown_Mounts_For_Mount.combobox then
                    local cbox = FCOMounty_LAM_Dropdown_Mounts_For_Mount.combobox
                    if cbox.m_comboBox and cbox.m_comboBox.m_selectedItemText then
                        local cboxText = cbox.m_comboBox.m_selectedItemText
                        if cboxText.GetText then
                            if cboxText:GetText() == FCOM_NONE_ENTRIES then
                                return true
                            end
                        end
                    end
                end
            end, --or boolean (optional)
            reference = "FCOMounty_LAM_Button_Add_To_Randomized", -- unique global reference to control (optional)
        },
        {
            type = "button",
            name = "-", -- string id or function returning a string
            func = function()
                --Remove the chosen mount from the random mounts of the current zone & subzone selection
                changeRandomMountInSettings(false)
            end,
            tooltip = "Remove mount from randomized for zone & subzone", -- string id or function returning a string (optional)
            width = "half", --or "half" (optional)
            disabled = function()
                if not settings.randomizeMountsForZoneAndSubzone
                        or FCOMounty.LAMSelectedZone == nil or FCOMounty.LAMSelectedZone == FCOM_NONE_ENTRIES
                        or FCOMounty.LAMSelectedSubZone == nil or FCOMounty.LAMSelectedSubZone == FCOM_NONE_ENTRIES
                then return true end
                if FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone then
                    local choices = FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone.choices
                    if choices then
                        local selectedItemData = FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone.combobox.m_comboBox.m_selectedItemData
                        if selectedItemData ~= nil then return false end
                    end
                    return true
                end
            end, --or boolean (optional)
            reference = "FCOMounty_LAM_Button_Remove_From_Randomized", -- unique global reference to control (optional)
        },
        {
            type = "dropdown",
            name = "Randomized mounts for zone & subzone", -- or string id or function returning a string
            tooltip = "Add mounts for the zone & subzone which can be chosen from by the randomizer", -- or string id or function returning a string (optional)
            choices = randomMountsForZoneAndSubZoneNames,
            choicesValues = randomMountsForZoneAndSubZone,
            getFunc = function()
            end,
            setFunc = function(mountId)
            end,
            --choicesTooltips = {"tooltip 1", "tooltip 2", "tooltip 3"}, -- or array of string ids or array of functions returning a string (optional)
            sort = "name-up", --or "name-down", "numeric-up", "numeric-down", "value-up", "value-down", "numericvalue-up", "numericvalue-down" (optional) - if not provided, list will not be sorted
            width = "full", --or "half" (optional)
            scrollable = true, -- boolean or number, if set the dropdown will feature a scroll bar if there are a large amount of choices and limit the visible lines to the specified number or 10 if true is used (optional)
            disabled = function()
                return not settings.randomizeMountsForZoneAndSubzone
                        or FCOMounty.LAMSelectedZone == nil or FCOMounty.LAMSelectedZone == FCOM_NONE_ENTRIES
                        or FCOMounty.LAMSelectedSubZone == nil or FCOMounty.LAMSelectedSubZone == FCOM_NONE_ENTRIES
            end, --or boolean (optional)
            reference = "FCOMounty_LAM_Dropdown_Randomized_Mounts_For_Zone_And_Subzone" -- unique global reference to control (optional)
        },

        --Mount visible enhancements
        {
            type = "header",
            name = "Mount visible enhancements",
        },
        {
            type = "description",
            text = "First choose a zone & subzone above (except " .. FCOM_NONE_ENTRIES .. ")\nThen select which enhancement should be hidden at the selected zone & subZone.",
            title = "Mount visible enhancements - How does it work?",
        },
        --Mount visible enhancements speed
        {
            type = "checkbox",
            name = 'Hide speed enhancements',
            tooltip = 'Hide the trained speed enhancements of the mount at the chosen zone and subzone?',
            getFunc = function()
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil and settings.zone2Mount[FCOMounty.LAMSelectedZone] ~= nil and settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] ~= nil then
                    return settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_SPEED]
                else
                    return gameSettingsShowMountEnhancement[RIDING_TRAIN_SPEED]
                end
            end,
            setFunc = function(value)
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil then
                    settings.zone2Mount[FCOMounty.LAMSelectedZone] = settings.zone2Mount[FCOMounty.LAMSelectedZone] or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] = settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements = settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_SPEED] = value
                    --Check if the mount for the current zone is changed and set it to the new one, but only if not mounted
                    checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone, true, true)
                end
            end,
            default = defaults.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_SPEED],
            width="half",
            reference = "FCOMounty_LAM_CB_Mount_Enhancement_Speed", -- unique global reference to control (optional)
        },
        --Mount visible enhancements stamina
        {
            type = "checkbox",
            name = 'Hide stamina enhancements',
            tooltip = 'Hide the trained stamina enhancements of the mount at the chosen zone and subzone?',
            getFunc = function()
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil and settings.zone2Mount[FCOMounty.LAMSelectedZone] ~= nil and settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] ~= nil then
                    return settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_STAMINA]
                else
                    return gameSettingsShowMountEnhancement[RIDING_TRAIN_STAMINA]
                end
            end,
            setFunc = function(value)
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil then
                    settings.zone2Mount[FCOMounty.LAMSelectedZone] = settings.zone2Mount[FCOMounty.LAMSelectedZone] or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] = settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements = settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_STAMINA] = value
                    --Check if the mount for the current zone is changed and set it to the new one, but only if not mounted
                    checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone, true, true)
                end
            end,
            default = defaults.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_STAMINA],
            width="half",
            reference = "FCOMounty_LAM_CB_Mount_Enhancement_Stamina", -- unique global reference to control (optional)
        },
        --Mount visible enhancements inventory
        {
            type = "checkbox",
            name = 'Hide inventory enhancements',
            tooltip = 'Hide the trained inventory enhancements of the mount at the chosen zone and subzone?',
            getFunc = function()
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil and settings.zone2Mount[FCOMounty.LAMSelectedZone] ~= nil and settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] ~= nil then
                    return settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_CARRYING_CAPACITY]
                else
                    return gameSettingsShowMountEnhancement[RIDING_TRAIN_CARRYING_CAPACITY]
                end
            end,
            setFunc = function(value)
                if FCOMounty.LAMSelectedZone ~= nil and FCOMounty.LAMSelectedSubZone ~= nil then
                    settings.zone2Mount[FCOMounty.LAMSelectedZone] = settings.zone2Mount[FCOMounty.LAMSelectedZone] or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] = settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone] or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements = settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements or {}
                    settings.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_CARRYING_CAPACITY] = value
                    --Check if the mount for the current zone is changed and set it to the new one, but only if not mounted
                    checkIfNotIsMountedAndUpdateMountSettingsForCurrentZoneAndSubzone(FCOMounty.LAMSelectedZone, FCOMounty.LAMSelectedSubZone, true, true)
                end
            end,
            default = defaults.zone2Mount[FCOMounty.LAMSelectedZone][FCOMounty.LAMSelectedSubZone].mountEnhancements[RIDING_TRAIN_CARRYING_CAPACITY],
            width="half",
            reference = "FCOMounty_LAM_CB_Mount_Enhancement_Inventory", -- unique global reference to control (optional)
        },

------------------------------------------------------------------------------------------------------------------------
        {
            type = "header",
            name = "Debug"
        },
        {
            type = "checkbox",
            name = 'Debug',
            tooltip = 'If enabled: FCOMounty will show debug messages in chat helping you/me to add new or missing zone data, etc.\nPlease do not ignore these messages and contact me with the relevant data so I can add it to the addon.\nMany thanks.',
            getFunc = function()
                return settings.debug
            end,
            setFunc = function(value)
                settings.debug = value
            end,
            default = defaults.debug,
            width="full",
        },


    } -- optionsTable
    -- END OF OPTIONS TABLE
    FCOMounty.LAM:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end