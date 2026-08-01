if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

--Read the game settings of the visible mount enhancements
function FCOMounty.GetGameSettingsMountVisibleEnhancements()
    local gameSettingsShowMountEnhancement = FCOMounty.gameSettings
    local settingsCategory = gameSettingsShowMountEnhancement.settingsCategories
    local settingsId = gameSettingsShowMountEnhancement.settingsIDs
    local gameSettingsShowMountEnhancementData = {}
    gameSettingsShowMountEnhancementData[RIDING_TRAIN_SPEED]             = FCOMounty.getGameSettings(settingsCategory[RIDING_TRAIN_SPEED], settingsId[RIDING_TRAIN_SPEED])
    gameSettingsShowMountEnhancementData[RIDING_TRAIN_STAMINA]           = FCOMounty.getGameSettings(settingsCategory[RIDING_TRAIN_STAMINA], settingsId[RIDING_TRAIN_STAMINA])
    gameSettingsShowMountEnhancementData[RIDING_TRAIN_CARRYING_CAPACITY] = FCOMounty.getGameSettings(settingsCategory[RIDING_TRAIN_CARRYING_CAPACITY], settingsId[RIDING_TRAIN_CARRYING_CAPACITY])
    return gameSettingsShowMountEnhancementData
end

--Build the default zone to mount table for default values
function FCOMounty.buildDefaultZone2MountTable()
    if FCOMounty.MountData == nil or FCOMounty.ZoneData == nil then return false end
    local defaultVars = FCOMounty.settingsVars.defaults
    --Get the default mount ID
    local defaultMount = 0
    for mountId, mountName in ipairs(FCOMounty.MountData) do
        if defaultMount == 0 then
            defaultMount = mountId
        end
    end
    --Get the game settings for "show mount enhancements stamina, speed and inventory space"
    local gameSettingsShowMountEnhancement = FCOMounty.GetGameSettingsMountVisibleEnhancements()
    --Set the entries for no zone or no subzone
    defaultVars.zone2Mount[FCOM_NONE_ENTRIES] = {}
    defaultVars.zone2Mount[FCOM_NONE_ENTRIES].mountId = defaultMount
    defaultVars.zone2Mount[FCOM_NONE_ENTRIES].mountEnhancements = gameSettingsShowMountEnhancement
    defaultVars.zone2Mount[FCOM_NONE_ENTRIES][FCOM_NONE_ENTRIES] = {}
    defaultVars.zone2Mount[FCOM_NONE_ENTRIES][FCOM_NONE_ENTRIES].mountId = defaultMount
    defaultVars.zone2Mount[FCOM_NONE_ENTRIES][FCOM_NONE_ENTRIES].mountEnhancements = gameSettingsShowMountEnhancement
    --Add each zone to the list
    local zoneData = FCOMounty.ZoneData
    if zoneData ~= nil then
        FCOMounty.gameSettingsShowMountEnhancement = gameSettingsShowMountEnhancement
        for zone, subZones in pairs(zoneData) do
            if zone ~= FCOM_ZONE_ID_STRING then
                defaultVars.zone2Mount[zone] = {}
                defaultVars.zone2Mount[zone].mountId = defaultMount
                defaultVars.zone2Mount[zone].mountEnhancements = {}
                defaultVars.zone2Mount[zone].mountEnhancements = gameSettingsShowMountEnhancement
                --Add the subzone -NONE- once
                defaultVars.zone2Mount[zone][FCOM_NONE_ENTRIES] = {}
                defaultVars.zone2Mount[zone][FCOM_NONE_ENTRIES].mountId = defaultMount
                defaultVars.zone2Mount[zone][FCOM_NONE_ENTRIES].mountEnhancements = {}
                defaultVars.zone2Mount[zone][FCOM_NONE_ENTRIES].mountEnhancements = gameSettingsShowMountEnhancement
                --Add the all entry as subzone once
                defaultVars.zone2Mount[zone][FCOM_ALL_ENTRIES] = {}
                defaultVars.zone2Mount[zone][FCOM_ALL_ENTRIES].mountId = defaultMount
                defaultVars.zone2Mount[zone][FCOM_ALL_ENTRIES].mountEnhancements = {}
                defaultVars.zone2Mount[zone][FCOM_ALL_ENTRIES].mountEnhancements = gameSettingsShowMountEnhancement
                --Add all other subzones
                for subZone, value in pairs(subZones) do
                    --Subzone is a boolean or subzone is an alternative/mapping name string?
                    if subZone ~= FCOM_ZONE_ID_STRING and (type(value) == "boolean" and value == true) or (type(value) == "string" and value ~= "") or (type(value) == "number" and value ~= 0) then
                        if defaultVars.zone2Mount[zone][subZone] == nil then
                            defaultVars.zone2Mount[zone][subZone] = {}
                        end
                        --Add all other subzones
                        defaultVars.zone2Mount[zone][subZone].mountId = defaultMount
                        defaultVars.zone2Mount[zone][subZone].mountEnhancements = {}
                        defaultVars.zone2Mount[zone][subZone].mountEnhancements = gameSettingsShowMountEnhancement
                    end
                end
            end
        end
    end
end

--Read the SavedVariables
function FCOMounty.getSettings()
    local addonVars = FCOMounty.addonVars
    local svName    = addonVars.addonSavedVariablesName
    local svNameNewZoneData  = addonVars.addonSavedVariablesNameNewZoneData
    local svVersion = addonVars.addonSavedVarsVersion
    local svProfile = "Settings"

    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    local defaults = {
        debug                             = false,
        alwaysUseClientLanguage           = true,
        stableFeedSettings                = {
            [RIDING_TRAIN_SPEED]             = false,
            [RIDING_TRAIN_STAMINA]           = false,
            [RIDING_TRAIN_CARRYING_CAPACITY] = false,
        },
        zone2Mount                        = {},
        zone2RandomMounts                 = {},
        autoPresetForZoneOnNewMount       = false,
        autoPresetForSubZoneALLOnNewMount = false,
        useSubzoneALLMountInAllSubzones   = false,
        randomizeMountsForZoneAndSubzone  = false,
    }
    FCOMounty.settingsVars.defaults = defaults
    --Build the default values for the addon settings
    FCOMounty.buildDefaultZone2MountTable()

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOMounty.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(svName, 999, "SettingsForAll", defaultsSettings)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (FCOMounty.settingsVars.defaultSettings.saveMode == 1) then
        FCOMounty.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(svName, svVersion , svProfile, defaults)
    else
        FCOMounty.settingsVars.settings = ZO_SavedVars:NewAccountWide(svName, svVersion, svProfile, defaults)
    end

    --Manually/Automatically added new zonedata
    --savedVariableTable, version, namespace, defaults, profile, displayName
    _G[svNameNewZoneData] = _G[svNameNewZoneData] or {}
    FCOMounty.settingsVars.manuallyAddedZones = _G[svNameNewZoneData]

    --=============================================================================================================

    --Load zoneData from the global SV table FCOMounty_NewZoneData and transfer them to the zoneData table.
    --If the zoneData table contains a same zone + subzone the data within teh SV table FCOMounty_NewZoneData will be
    --removed!
    local manuallyAddedZones = FCOMounty.settingsVars.manuallyAddedZones
    if manuallyAddedZones ~= nil then
        for zoneName, zoneDataOfZone in pairs(manuallyAddedZones) do
            if zoneName ~= "" then
                if FCOMounty.ZoneData[zoneName] == nil then
                    --Add zone from SV "not yet in the preloaded data" table
                    FCOMounty.ZoneData[zoneName] = {}
                end
                for subZoneName, subZoneIdOrStr in pairs(zoneDataOfZone) do
                    if subZoneName ~= "" then
                        if FCOMounty.ZoneData[zoneName][subZoneName] == nil then
                            --Add subZone of zone from SV "not yet in the preloaded data" table
                            FCOMounty.ZoneData[zoneName][subZoneName] = subZoneIdOrStr
                        else
                            --Remove subZone from SV "not yet in the preloaded data" table as it is in the preloaded
                            --data table already
                            FCOMounty.settingsVars.manuallyAddedZones[zoneName][subZoneName] = nil
                            --Only 1 subzone left at the zone?
                            if manuallyAddedZones[zoneName] ~= nil and NonContiguousCount(manuallyAddedZones[zoneName]) == 1 then
                                --is the 1 subzone the _zoneId entry?
                                if manuallyAddedZones[zoneName][FCOM_ZONE_ID_STRING] ~= nil then
                                    --Delete the zone from the "not yet in the preloaded data" table now
                                    FCOMounty.settingsVars.manuallyAddedZones[zoneName] = nil
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

--Save the chosen mount number mountId from the LAM settings to the SavedVariables. The booelan parameter activateMount
--will activate the chosen mount directly
function FCOMounty.SaveMountIdToSettings(mountId, activateMount, zone, subZone, mountEnhancements)
    activateMount = activateMount or false
--d("FCOMounty.SaveMountIdToSettings - mountId: " ..tostring(mountId)  .. " (" .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(mountId)) .. "), activateMount: " .. tostring(activateMount) .. ", zone: " ..tostring(zone) .. ", subZone: " .. tostring(subZone))
    local settings = FCOMounty.settingsVars.settings
    local doCheckIfActivateMountNow = false
    local subZoneToUse
    -- Is the zone and the subzone given, and is the subzone a special subzone, and not any (all in the zone = -ALL-) or none (-NONE-)
    if zone ~= nil and zone ~= "" and (subZone ~= nil and subZone ~= "" and subZone ~= FCOM_NONE_ENTRIES and subZone ~= FCOM_ALL_ENTRIES) then
--d(">zone & subZone saving, zone: " ..tostring(zone) .. ", subZone: " .. tostring(subZone) ..", mountId: " .. tostring(mountId) .. " (" .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(mountId)) .. ")")

        settings.zone2Mount = settings.zone2Mount or {}
        settings.zone2Mount[zone] = settings.zone2Mount[zone] or {}
        settings.zone2Mount[zone][subZone] = settings.zone2Mount[zone][subZone] or {}
        settings.zone2Mount[zone][subZone].mountId = mountId
        if mountId ~= 0 and mountEnhancements ~= nil then
            if settings.zone2Mount[zone][subZone].mountEnhancements == nil then settings.zone2Mount[zone][subZone].mountEnhancements = {} end
            settings.zone2Mount[zone][subZone].mountEnhancements = mountEnhancements
        end
        subZoneToUse = subZone
        doCheckIfActivateMountNow = true

    -- Is the zone given, and is the zone not -NONE-, and is no subzone given or the subzone is -ALL-
    elseif zone ~= nil and zone ~= "" and zone ~= FCOM_NONE_ENTRIES then
        --Subzone is given but -ALL-)?
        if      (FCOMounty.subZone ~= nil and subZone == FCOM_ALL_ENTRIES)
            or  (FCOMounty.subZone == nil) then
--d(">zone saving, zone: " ..tostring(zone) .. ", mountId: " .. tostring(mountId) .. " (" .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(mountId)) .. ")")
            settings.zone2Mount = settings.zone2Mount or {}
            settings.zone2Mount[zone] = settings.zone2Mount[zone] or {}
            settings.zone2Mount[zone].mountId = mountId
            if mountId ~= 0 and mountEnhancements ~= nil then
                if settings.zone2Mount[zone].mountEnhancements == nil then settings.zone2Mount[zone].mountEnhancements = {} end
                settings.zone2Mount[zone].mountEnhancements = mountEnhancements
            end
            doCheckIfActivateMountNow = true
        end
    end
    --Activate the mount for the current zone & subzone
    if doCheckIfActivateMountNow and activateMount and not IsMounted() then
--d(">Activating mount now")
        FCOMounty.ActivateMountForZone(zone, subZoneToUse)
    end

end

--Load the mount number from the SavedVariables
function FCOMounty.LoadMountIdFromSettings(zone, subZone)
    local settings = FCOMounty.settingsVars.settings
    local chosenMountId = 0
    if zone ~= FCOM_NONE_ENTRIES and subZone ~= FCOM_NONE_ENTRIES then
        if settings.zone2Mount[zone] ~= nil then
            if subZone ~= FCOM_ALL_ENTRIES then
                if settings.zone2Mount[zone][subZone] ~= nil then
                    if settings.zone2Mount[zone][subZone].mountId ~= nil then
                        chosenMountId = settings.zone2Mount[zone][subZone].mountId
                    elseif settings.zone2Mount[zone].mountId then
                        chosenMountId = settings.zone2Mount[zone].mountId
                    end
                end
            elseif settings.zone2Mount[zone].mountId then
                chosenMountId = settings.zone2Mount[zone].mountId
            end
        end
    end
    return chosenMountId
end

--Load the mount number from the SavedVariables
function FCOMounty.LoadRandomMountIdFromSettings(zone, subZone)
    local settings = FCOMounty.settingsVars.settings
    local chosenMountId = 0
    if zone ~= FCOM_NONE_ENTRIES and subZone ~= FCOM_NONE_ENTRIES then
        if settings.zone2RandomMounts[zone] ~= nil then
            if subZone ~= FCOM_ALL_ENTRIES then
                if settings.zone2RandomMounts[zone][subZone] ~= nil then
                    if settings.zone2RandomMounts[zone][subZone].mountId ~= nil then
                        chosenMountId = settings.zone2RandomMounts[zone][subZone].mountId
                    elseif settings.zone2RandomMounts[zone].mountId then
                        chosenMountId = settings.zone2RandomMounts[zone].mountId
                    end
                end
            elseif settings.zone2RandomMounts[zone].mountId then
                chosenMountId = settings.zone2RandomMounts[zone].mountId
            end
        end
    end
    return chosenMountId
end

--Get the settings e.g. "Show mount enchancements" from the game settings
function FCOMounty.getGameSettings(settingsCategory, settingsId)
    if settingsCategory == nil or settingsId == nil then return nil end
    local value = GetSetting(settingsCategory, settingsId)
    if value == "0" then value = false end
    if value == "1" then value = true end
    return value
end

--Set the settings e.g. "Show mount enchancements" to the game settings
function FCOMounty.setGameSettings(settingsCategory, settingsId, value)
    if settingsCategory == nil or settingsId == nil or value == nil then return nil end
    if value == false then value = "0" end
    if value == true then value = "1" end
    SetSetting(settingsCategory, settingsId, value)
end
