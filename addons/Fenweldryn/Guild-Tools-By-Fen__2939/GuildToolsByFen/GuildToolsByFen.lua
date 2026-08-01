-------------------------------------------------------------------------------
-- Guild Tools By Fen
-------------------------------------------------------------------------------
-- Author: Fenweldryn
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media
-- Inc. or its affiliates. The Elder Scrolls® and related logos are registered
-- trademarks or trademarks of ZeniMax Media Inc. in the United States and/or
-- other countries.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------

local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang
local BankGoldTransactions = GuildToolsByFenInternals.BankGoldTransactions
local TimeJoined = GuildToolsByFenInternals.TimeJoined
local GuildInvite = GuildToolsByFenInternals.GuildInvite
local SettingsMenu = GuildToolsByFenInternals.SettingsMenu
local SlashCommands = GuildToolsByFenInternals.SlashCommands

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
    -- org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
    
    local parent = control:GetParent()
    local data = ZO_ScrollList_GetData(parent)
    local guildId = GUILD_SELECTOR.guildId
    local displayName = data.displayName
    local timeStamp = GetTimeStamp()
    
    local tooltip = {}
    table.insert(tooltip, data.characterName)
    
    if (GuildToolsByFen.history[guildId] == nil) then return end
    
    if (GuildToolsByFen.history[guildId][displayName] == nil) then
        --  NO PLAYER RECORD FOUND
        timeString = tostring(ZO_FormatTime(timeStamp - GuildToolsByFen.history[guildId].oldestEvent,TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE,TIME_FORMAT_PRECISION_SECONDS))
        table.insert(tooltip, langStrings[lang].member .. "> " .. timeString)
        table.insert(tooltip, langStrings[lang].bankGoldDeposits .. '\n' .. langStrings[lang].noRecords)
        table.insert(tooltip, langStrings[lang].bankGoldWithdrawals .. '\n' .. langStrings[lang].noRecords)
    else
        table.insert(tooltip, TimeJoined.createTooltipString(guildId, displayName, timeStamp))
        table.insert(tooltip, GuildToolsByFenInternals.BankGoldTransactions.createTooltipString(guildId, displayName, timeStamp, 'deposits'))        
        table.insert(tooltip, GuildToolsByFenInternals.BankGoldTransactions.createTooltipString(guildId, displayName, timeStamp, 'withdrawals'))        
    end
    
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
    SetTooltipText(InformationTooltip, table.concat(tooltip, "\n\n"))
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
    ClearTooltip(InformationTooltip)
    
    -- org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end

local function SetUpLibHistoireListener(guildId, category, startTime, endTime)
    local listener = LibHistoire:CreateGuildHistoryListener(guildId, category)    

    listener:SetEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)              
        if( eventType == GUILD_EVENT_GUILD_JOIN 
            or eventType == GUILD_EVENT_BANKGOLD_ADDED
            or eventType == GUILD_EVENT_BANKGOLD_REMOVED ) then
            GuildToolsByFenInternals.createGuild(guildId)   
            GuildToolsByFenInternals.createUser(param1, guildId)         
        end        
        
        if(eventType == GUILD_EVENT_BANKGOLD_ADDED and category == GUILD_HISTORY_BANK) then                
            BankGoldTransactions.store(guildId, param1, param2, 'deposits', eventTime)                          
        end
        
        if(eventType == GUILD_EVENT_BANKGOLD_REMOVED and category == GUILD_HISTORY_BANK) then
            BankGoldTransactions.store(guildId, param1, param2, 'withdrawals', eventTime)                          
        end
        
        if(eventType == GUILD_EVENT_GUILD_JOIN and category == GUILD_HISTORY_GENERAL) then  
            TimeJoined.storeGuildJoins(guildId, param1, eventTime)
            if( GuildToolsByFen.history[guildId].oldestEvent == nil 
                or GuildToolsByFen.history[guildId].oldestEvent >= eventTime) then
                GuildToolsByFen.history[guildId].oldestEvent = eventTime                    
            end
        end
end)
listener:Start()
end

function onAddOnLoaded(eventCode, addonName)
    if (addonName ~= GuildToolsByFenInternals.name) then
        return
    end
    
    EVENT_MANAGER:UnregisterForEvent(GuildToolsByFenInternals.name, EVENT_ADD_ON_LOADED)
    SettingsMenu.InitAddonMenu()    
    
    startTime = os.time() - 30*24*60*60
    endTime = os.time()
    
    for i = 1, GetNumGuilds() do
        SetUpLibHistoireListener(GetGuildId(i), GUILD_HISTORY_GENERAL)
        BankGoldTransactions.resetUserTransactions(GetGuildId(i))
        SetUpLibHistoireListener(GetGuildId(i), GUILD_HISTORY_BANK, startTime, endTime)
    end
end

EVENT_MANAGER:RegisterForEvent(GuildToolsByFenInternals.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)
