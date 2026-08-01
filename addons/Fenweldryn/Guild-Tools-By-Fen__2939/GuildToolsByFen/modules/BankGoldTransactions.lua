GuildToolsByFenInternals.BankGoldTransactions = {}
local BankGoldTransactions = GuildToolsByFenInternals.BankGoldTransactions
local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang

function BankGoldTransactions.store(guildId, user, gold, event, eventTime)  
    -- if (user == nil) then return end  
    -- if (guildId == nil) then return end  

    local eventDate = os.date("*t", eventTime)
    local today = os.date("*t")
    local lastTradeWeekStart = 0
    local lastTradeWeekEnd = 0
    _, today.tradeWeekStart, today.tradeWeekEnd = LibDateTime:GetTraderWeek()
    _, lastTradeWeekStart, lastTradeWeekEnd = LibDateTime:GetTraderWeek(-1)

    if(today.tradeWeekStart == nil or lastTradeWeekStart == nil) then return end    
    if(eventDate.year ~= os.date('*t', os.time()).year) then return end
    if(eventTime < (os.time() - 60*60*24*30)) then return end
    
    -- last 30 days
    if(eventTime >= (os.time() - 60*60*24*30)) then 
        GuildToolsByFen.history[guildId][user][event].last30Days = gold + GuildToolsByFen.history[guildId][user][event].last30Days
    end
   
    -- last week

    if(eventTime >= lastTradeWeekStart and eventTime <= lastTradeWeekEnd ) then
        GuildToolsByFen.history[guildId][user][event].lastWeek = gold + GuildToolsByFen.history[guildId][user][event].lastWeek        
    end
    
    -- this week
    if (eventTime >= today.tradeWeekStart and eventTime <= today.tradeWeekEnd) then
        GuildToolsByFen.history[guildId][user][event].thisWeek = gold + GuildToolsByFen.history[guildId][user][event].thisWeek
    end
    
    -- today
    if (eventDate.day == today.day and eventDate.month == today.month) then
        GuildToolsByFen.history[guildId][user][event].today = gold + GuildToolsByFen.history[guildId][user][event].today
    end
end

function BankGoldTransactions.resetUserTransactions(guildId)
    if (GuildToolsByFen.history[guildId] ~= nil) then
        for index, value in pairs(GuildToolsByFen.history[guildId]) do    
            if(string.sub(index, 1, 1) == '@') then
                GuildToolsByFen.history[guildId][index].deposits = {
                    last30Days = 0,
                    lastWeek = 0,
                    thisWeek = 0,
                    today = 0
                }
                GuildToolsByFen.history[guildId][index].withdrawals = {
                    last30Days = 0,
                    lastWeek = 0,
                    thisWeek = 0,
                    today = 0
                }
            end
        end
    end
end

function BankGoldTransactions.createTooltipString(guildId, displayName, timeStamp, operationName)
    local tooltip = {}
    local operation = GuildToolsByFen.history[guildId][displayName][operationName]
    local operationNameUpperCase = operationName:gsub("^%l", string.upper)
    
    table.insert(tooltip, langStrings[lang]['bankGold' .. operationNameUpperCase])
    
    if (operation.last30Days == 0
        and operation.lastWeek == 0
        and operation.thisWeek == 0
        and operation.today == 0) then
        table.insert(tooltip, langStrings[lang].noRecords)
    else
        table.insert(tooltip, string.format(langStrings[lang].last30Days, ZO_CommaDelimitNumber(operation.last30Days)))
        table.insert(tooltip, string.format(langStrings[lang].lastWeek, ZO_CommaDelimitNumber(operation.lastWeek)))
        table.insert(tooltip, string.format(langStrings[lang].thisWeek, ZO_CommaDelimitNumber(operation.thisWeek)))
        table.insert(tooltip, string.format(langStrings[lang].today, ZO_CommaDelimitNumber(operation.today)))
    end

    return table.concat(tooltip, "\n")
end