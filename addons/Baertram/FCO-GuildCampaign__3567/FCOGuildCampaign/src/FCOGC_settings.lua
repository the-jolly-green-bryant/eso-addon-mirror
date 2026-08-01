FCOGC = FCOGC or  {}
local FCOGuildCampaign              = FCOGC
------------------------------------------------------------------------------------------------------------------------


local addonVars = FCOGuildCampaign.addonVars

------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
------------------------------------------------------------------------------------------------------------------------
--Read the SavedVariables
function FCOGuildCampaign.getSettings()
    local serverName    = GetWorldName()
    local svName        = addonVars.addonSavedVariablesName
    local svVersion     = addonVars.addonSavedVarsVersion
    local svForAllTable = addonVars.addonSavedVarsForAllTable
    local svNormalTable = addonVars.addonSavedVarsNormalTable

    --The default values for the language and save mode
    local defaultsSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    --Pre-set the deafult values
    local defaults = {
        alwaysUseClientLanguage			    = true,

        isGuildEnabled = {},
        reserveLast5CharsAtGuildMemberNote = true,
        lastGuildMemberNoteUpdates = {},
    }
    local numGuilds = GetNumGuilds()
    for guildIndex = 1, MAX_GUILDS, 1 do
        if guildIndex <= numGuilds then
            local guildId = GetGuildId(guildIndex)
            if guildId ~= nil and guildId > 0 then
                defaults.isGuildEnabled[guildId] = false
            end
        end
    end
    FCOGuildCampaign.settingsVars.defaults = defaults

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOGuildCampaign.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide( svName, 999, svForAllTable, defaultsSettings, serverName )

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (FCOGuildCampaign.settingsVars.defaultSettings.saveMode == 1) then
        FCOGuildCampaign.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings( svName, svVersion , svNormalTable, defaults, serverName )
    else
        FCOGuildCampaign.settingsVars.settings = ZO_SavedVars:NewAccountWide( svName, svVersion, svNormalTable, defaults, serverName )
    end
    --=============================================================================================================

    --Prepare the settings table for the last guild member note updates, per guildId: Will save a timestamp for each @displayName
    --and prepare the lookup tables for the last update of a @displayName at any guildId
    local settingsToUpdate = FCOGuildCampaign.settingsVars.settings
    FCOGuildCampaign.lastGuildMemberNoteUpdateByDisplayName = {}
    local helperTable = {}
    for guildIndex = 1, MAX_GUILDS, 1 do
        local guildId = GetGuildId(guildIndex)
        if guildId ~= nil then
            if settingsToUpdate.lastGuildMemberNoteUpdates[guildId] == nil then
                settingsToUpdate.lastGuildMemberNoteUpdates[guildId] = {}
            else
                for displayName, lastUpdateDoneTimestamp in pairs(settingsToUpdate.lastGuildMemberNoteUpdates[guildId]) do
                    if helperTable[displayName] == nil then
                        helperTable[displayName] = {}
                    end
                    table.insert(helperTable[displayName], {
                        guildId =           guildId,
                        lastUpdateDone =    lastUpdateDoneTimestamp,
                    })
                end
            end
        end
    end
    --Any helper table entries were created? Sort by "latest" (highest) timestamp now
    if NonContiguousCount(helperTable) > 0 then
        table.sort(helperTable) --sort by @displayName
        table.sort(helperTable, function(a, b) --sort by lastUpdateDone DESC
            return a.lastUpdateDone > b.lastUpdateDone
        end)

        for displayName, lastUpdatesDoneTable in pairs(helperTable) do
            for idx, lastUpdatesDoneTableData in ipairs(lastUpdatesDoneTable) do
                --Only add the first entry of each displayName
                if idx == 1 and FCOGuildCampaign.lastGuildMemberNoteUpdateByDisplayName[displayName] == nil then
                    FCOGuildCampaign.lastGuildMemberNoteUpdateByDisplayName[displayName] = lastUpdatesDoneTableData
                end
            end
        end
    end
end