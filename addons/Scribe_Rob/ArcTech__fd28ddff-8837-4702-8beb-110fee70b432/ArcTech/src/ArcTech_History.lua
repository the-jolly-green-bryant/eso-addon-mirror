function SumBankDepositsThisMonth(guildId, displayName)

    if not LibHistoire then
        return -1 -- no lib
    end

    local listener = LibHistoire:GetListener(ArcTech.guild_id, GUILD_HISTORY_BANK)

    if not listener then
        return -2 -- no listener
    end

    -- Has history finished syncing?
    if not listener:IsFullyLinked() then
        return -3 -- not synced yet
    end

    local monthStart = GetStartOfCurrentMonthTimestamp()
    local total = 0
    local me = string.lower(displayName or "")

    -- Iterate history
    for event in listener:IterateEvents() do

        if event.eventType == GUILD_EVENT_GUILD_BANK_GOLD_ADDED then

            if event.timeStamp >= monthStart then

                local actor = event.displayName
                    and string.lower(event.displayName)
                    or ""

                if actor == me then
                    total = total + (event.goldAmount or 0)
                end

            end
        end
    end

    return total
end

function GetStartOfCurrentMonthTimestamp()
    local now = GetTimeStamp() -- seconds
    local t = os.date("*t", now)
    t.day = 1
    t.hour = 0
    t.min = 0
    t.sec = 0
    return os.time(t)
end