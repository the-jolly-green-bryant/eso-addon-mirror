local SlashCommands = {}

local function createToggleHandler(addon)
    return function()
        if addon.UI and addon.UI.Toggle and type(addon.UI.Toggle) == "function" then
            local success, err = pcall(addon.UI.Toggle, addon.UI)
            if not success then
                addon:Err(GetString(NMGH_ERROR_UI_TOGGLE), {error = tostring(err)})
            end
        else
            addon:Warn(GetString(NMGH_ERROR_UI_NOT_READY))
        end
    end
end

local function getZoneId(addon)
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneId = GetZoneId(zoneIndex)
    local zoneName = GetZoneNameById(zoneId)
    local teleportZoneId = nil
    if NMGuildHallTeleportData and NMGuildHallTeleportData.TeleportList then
        for _, zone in ipairs(NMGuildHallTeleportData.TeleportList) do
            if zone.id == zoneId then
                teleportZoneId = zone.id
                break
            end
        end
    end
    addon:Msg(GetString(NMGH_DEBUG_CURRENT_ZONE), {id = zoneId, name = zoneName})
    if teleportZoneId then
        addon:Msg(GetString(NMGH_DEBUG_TELEPORT_ZONE_MATCH), {
            id = teleportZoneId,
            match = (teleportZoneId == zoneId and "YES" or "NO")
        })
    else
        addon:Msg(GetString(NMGH_DEBUG_ZONE_NOT_FOUND))
    end
end

local function getCollectibleId(addon)
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneId = GetZoneId(zoneIndex)
    local zoneName = GetZoneNameById(zoneId)

    -- Try to get collectible ID from the game API
    local gameCollectibleId = 0
    if GetCollectibleIdForZone then
        gameCollectibleId = GetCollectibleIdForZone(zoneIndex)
    end
    
    if gameCollectibleId and gameCollectibleId > 0 then
         addon:Msg(GetString(NMGH_DEBUG_GAME_COLLECTIBLE_FOUND), {
            cid = gameCollectibleId,
            name = zoneName,
            id = zoneId
         })
    else
         addon:Msg(GetString(NMGH_DEBUG_GAME_COLLECTIBLE_NOT_FOUND), {
            name = zoneName,
            id = zoneId
         })
    end

    local foundCollectibleId = nil
    if NMGuildHallTeleportData and NMGuildHallTeleportData.TeleportList then
        for _, zone in ipairs(NMGuildHallTeleportData.TeleportList) do
            if zone.id == zoneId and zone.collectibleId then
                foundCollectibleId = zone.collectibleId
                break
            end
        end
    end
    if foundCollectibleId then
        addon:Msg(GetString(NMGH_DEBUG_COLLECTIBLE_FOUND), {
            name = zoneName,
            id = zoneId,
            cid = foundCollectibleId
        })
    else
        addon:Msg(GetString(NMGH_DEBUG_COLLECTIBLE_NOT_FOUND), {
            name = zoneName,
            id = zoneId
        })
    end
end

local function registerImportCommand(addon, constants)
    local importCmd = constants and constants.SLASH and constants.SLASH.IMPORT or "/nmgh_import"
    
    SLASH_COMMANDS[importCmd] = function(args)
        if not args or args == "" then
            if addon.Message then
                addon.Message:Info(GetString(NMGH_CMD_IMPORT_USAGE))
            end
            return
        end
        if addon.Settings and addon.Settings.ImportSettings then
            local success, err = pcall(addon.Settings.ImportSettings, addon.Settings, args)
            if not success then
                addon:Err(GetString(NMGH_ERR_SETTINGS_IMPORT_FAILED), {error = tostring(err)})
            end
        else
            if addon.Message then
                addon.Message:Error(GetString(NMGH_ERROR_IMPORT_NOT_AVAILABLE))
            end
        end
    end
end

local function registerIconDebugCommand(addon, constants)
    local command = (constants and constants.SLASH and constants.SLASH.DEBUG_ICONS) or "/nmghicons"
    SLASH_COMMANDS[command] = function()
        local icons = constants and constants.MEDIA and constants.MEDIA.ICONS
        if not icons then
            addon:Err(GetString(NMGH_ERR_MEDIA_ICONS_NOT_FOUND))
            return
        end
        
        addon:Msg(GetString(NMGH_DEBUG_AVAILABLE_ICONS))
        for name, path in pairs(icons) do
            addon:Msg(string.format(" - %s: |t24:24:%s|t", name, path))
        end
        
        local colors = constants and constants.MEDIA and constants.MEDIA.COLORS
        if colors and colors.CRIMSON_TEXT then
            addon:Msg(GetString(NMGH_DEBUG_COLOR_TEST), {color = colors.CRIMSON_TEXT})
        end
        
        if icons.Ald then
            addon:Msg(GetString(NMGH_DEBUG_ICON_RENDER_TEST), {icon = icons.Ald})
        end
    end
end

local function registerCampaignDebugCommand(addon, constants)
    local main = (constants and constants.SLASH and constants.SLASH.CAMPAIGNS) or "/nmghcampaigns"
    local short = (constants and constants.SLASH and constants.SLASH.CAMPAIGNS_SHORT) or "/caid"
    local full = (constants and constants.SLASH and constants.SLASH.CAMPAIGNS_FULL) or "/campaignID"
    
    local handler = function()
        if addon.Campaign and addon.Campaign.DebugListCampaigns then
            local success, err = pcall(addon.Campaign.DebugListCampaigns, addon.Campaign)
            if not success then
                addon:Err(GetString(NMGH_ERR_API_CALL_FAILED), {error = tostring(err)})
            end
        else
            addon:Warn(GetString(NMGH_WARN_CAMPAIGN_DEBUG_NOT_AVAIL))
        end
    end
    
    SLASH_COMMANDS[main] = handler
    SLASH_COMMANDS[short] = handler
    SLASH_COMMANDS[full] = handler
end

local function registerExportCommand(addon, constants)
    local command = constants and constants.SLASH and constants.SLASH.EXPORT or "/nmgh_export"
    
    SLASH_COMMANDS[command] = function()
        if addon.Settings and addon.Settings.ExportSettings then
            local settingsString = addon.Settings:ExportSettings()
            if settingsString then
                addon:Msg(GetString(NMGH_MSG_SETTINGS_EXPORTED_FEEDBACK))
                addon:Msg(settingsString)
            end
        end
    end
end

local function registerResetCommand(addon, constants)
    local command = constants and constants.SLASH and constants.SLASH.RESET or "/nmgh_reset"
    
    SLASH_COMMANDS[command] = function()
        if addon.Settings and addon.Settings.ResetToDefaults then
            addon.Settings:ResetToDefaults()
            addon:Msg(GetString(NMGH_MSG_SETTINGS_RESET_DONE))
        else
            addon:Err(GetString(NMGH_ERR_SETTINGS_RESET_FAILED))
        end
    end
end

local function registerDialogTestCommand(addon)
    local command = "/nmgh_dialog_test"

    SLASH_COMMANDS[command] = function()
        if not (addon and addon.UI and addon.UI.ShowDialog) then
            if addon and addon.Warn then
                addon:Warn(GetString(NMGH_ERROR_UI_NOT_READY))
            end
            return
        end

        addon.UI:ShowDialog(
            GetString(NMGH_DIALOG_TEST_TITLE),
            GetString(NMGH_DIALOG_TEST_BODY),
            {
                {
                    text = GetString(NMGH_DIALOG_TEST_PRIMARY),
                    callback = function()
                        addon:Msg(GetString(NMGH_DIALOG_TEST_FIRED_PRIMARY))
                    end
                },
                {
                    text = GetString(NMGH_DIALOG_TEST_SECONDARY),
                    callback = function()
                        addon:Msg(GetString(NMGH_DIALOG_TEST_FIRED_SECONDARY))
                    end
                },
                {
                    text = GetString(NMGH_DIALOG_TEST_TERTIARY),
                    callback = function()
                        addon:Msg(GetString(NMGH_DIALOG_TEST_FIRED_TERTIARY))
                    end
                },
                {
                    text = GetString(NMGH_DIALOG_TEST_QUATERNARY),
                    callback = function()
                        addon:Msg(GetString(NMGH_DIALOG_TEST_FIRED_QUATERNARY))
                    end
                },
            }
        , {
            -- Example manual sizing override for the test dialog
            dialogWidth = 920,
        })
    end
end

local function registerHelpCommand(addon, constants)
    local command = constants and constants.SLASH and constants.SLASH.HELP or "/nmgh_help"
    
    SLASH_COMMANDS[command] = function()
        addon:Msg(GetString(NMGH_HELP_HEADER))
        addon:Msg(GetString(NMGH_HELP_MAIN))
        addon:Msg(GetString(NMGH_HELP_ZONE))
        addon:Msg(GetString(NMGH_HELP_CID))
        addon:Msg(GetString(NMGH_HELP_API))
        addon:Msg(GetString(NMGH_HELP_IMPORT))
        addon:Msg(GetString(NMGH_HELP_EXPORT))
        addon:Msg(GetString(NMGH_HELP_RESET))
        addon:Msg(GetString(NMGH_HELP_ICONS))
        addon:Msg(GetString(NMGH_HELP_CAMPAIGNS))
        addon:Msg(GetString(NMGH_HELP_HELP))
    end
end

local function registerApiVersionCommand(addon, constants)
    local short = constants and constants.SLASH and constants.SLASH.API_VERSION_SHORT or "/apiver"
    local full = constants and constants.SLASH and constants.SLASH.API_VERSION_FULL or "/apiversion"

    local handler = function()
        local current = nil
        if GetAPIVersion then
            local ok, v = pcall(GetAPIVersion)
            if ok then
                current = v
            end
        end

        if not current then
            addon:Warn(GetString(NMGH_ERR_API_VERSION_UNAVAILABLE))
            return
        end

        local required = constants and constants.COMPATIBILITY and constants.COMPATIBILITY.REQUIRED_API_VERSION or ""
        addon:Msg(GetString(NMGH_MSG_API_VERSION), { current = tostring(current), required = tostring(required) })
    end

    SLASH_COMMANDS[short] = handler
    SLASH_COMMANDS[full] = handler
end

function SlashCommands:Register()
    local addon = NMGuildHall
    local constants = addon and addon.Constants

    -- Guard against missing global
    if not SLASH_COMMANDS then
        if addon and addon.Warn then
            addon:Warn(GetString(NMGH_WARN_SLASH_COMMANDS_NOT_AVAIL))
        end
        return
    end

    -- Main command
    local mainCommand = constants and constants.SLASH and constants.SLASH.MAIN or "/nmgh"
    local altCommand = constants and constants.SLASH and constants.SLASH.ALT or "/misfit"

    local handler = createToggleHandler(addon)
    SLASH_COMMANDS[mainCommand] = handler
    SLASH_COMMANDS[altCommand] = handler

    -- Debug commands
    local zoneCommand = constants and constants.SLASH and constants.SLASH.ZONE_ID_SHORT or "/zid"
    local zoneFull = constants and constants.SLASH and constants.SLASH.ZONE_ID_FULL or "/zoneID"
    
    local cidCommand = constants and constants.SLASH and constants.SLASH.COLLECTIBLE_ID_SHORT or "/cid"
    local cidFull = constants and constants.SLASH and constants.SLASH.COLLECTIBLE_ID_FULL or "/collectionID"
    
    local zoneHandler = function() getZoneId(addon) end
    SLASH_COMMANDS[zoneCommand] = zoneHandler
    SLASH_COMMANDS[zoneFull] = zoneHandler
    
    local cidHandler = function() getCollectibleId(addon) end
    SLASH_COMMANDS[cidCommand] = cidHandler
    SLASH_COMMANDS[cidFull] = cidHandler
    
    -- Feature commands
    registerImportCommand(addon, constants)
    registerExportCommand(addon, constants)
    registerResetCommand(addon, constants)
    registerIconDebugCommand(addon, constants)
    registerCampaignDebugCommand(addon, constants)
    registerApiVersionCommand(addon, constants)
    registerDialogTestCommand(addon)
    registerHelpCommand(addon, constants)
end

NMGuildHall = NMGuildHall or {}
NMGuildHall.SlashCommands = SlashCommands
NMGuildHall.RegisterSlashCommands = function(self)
    SlashCommands:Register()
end

return SlashCommands
