-- GuildUtils.lua: Pure functions for guild data operations
-- No state mutation, all functions take data as parameters

local GuildUtils = {}

-- Constants for trader rotation times (Every Tuesday)
local TRADER_FLIP_TIMES = {
    EU = 14 * 60 * 60, -- 14:00 UTC
    NA = 19 * 60 * 60, -- 19:00 UTC
}

---Get the next trader flip timestamp
---@param megaserver string
---@param currentTime number
---@return number
function GuildUtils.GetNextTraderFlipTime(megaserver, currentTime)
    local flipTimeOfDay = TRADER_FLIP_TIMES.NA
    if megaserver and string.find(megaserver, "EU", 1, true) then
        flipTimeOfDay = TRADER_FLIP_TIMES.EU
    end

    -- Calculate day of week from Unix timestamp (UTC)
    -- Unix epoch (Jan 1, 1970) was a Thursday (day 5)
    local daysSinceEpoch = math.floor(currentTime / (24 * 60 * 60))
    local currentDayOfWeek = ((daysSinceEpoch + 4) % 7) + 1 -- Sunday=1, Monday=2, ..., Saturday=7

    local secondsSinceMidnight = currentTime % (24 * 60 * 60)

    local TUESDAY = 3
    local daysUntilTuesday = (TUESDAY - currentDayOfWeek + 7) % 7

    if daysUntilTuesday == 0 and secondsSinceMidnight < flipTimeOfDay then
        -- It's Tuesday but before flip time
        return currentTime - secondsSinceMidnight + flipTimeOfDay
    end

    if daysUntilTuesday == 0 then
        -- It's Tuesday but after flip time, next flip is in 7 days
        daysUntilTuesday = 7
    end

    local secondsUntilNextTuesdayMidnight = (daysUntilTuesday * 24 * 60 * 60) - secondsSinceMidnight
    return currentTime + secondsUntilNextTuesdayMidnight + flipTimeOfDay
end

---Parse kiosk attribute to extract trader name and city
---@param kioskAttribute string|nil Format: "TraderName in City"
---@return string|nil traderName
---@return string|nil city
function GuildUtils.ParseKioskAttribute(kioskAttribute)
    if not kioskAttribute or kioskAttribute == "" then
        return nil, nil
    end

    local function NormalizeWhitespace(text)
        if not text or text == "" then
            return nil
        end
        text = tostring(text)
        text = text:gsub("%s+", " ")
        text = text:gsub("^%s+", "")
        text = text:gsub("%s+$", "")
        if text == "" then
            return nil
        end
        return text
    end

    ---Find the last plain occurrence of a token (no Lua patterns).
    ---@param haystack string
    ---@param needle string
    ---@return integer|nil
    local function FindLastPlain(haystack, needle)
        local lastPos = nil
        local searchPos = 1
        while true do
            local found = string.find(haystack, needle, searchPos, true)
            if not found then
                break
            end
            lastPos = found
            searchPos = found + 1
        end
        return lastPos
    end

    local function Trim(text)
        return NormalizeWhitespace(text)
    end

    local raw = NormalizeWhitespace(kioskAttribute)
    if not raw then
        return nil, nil
    end

    -- Handle common formats:
    -- - "TraderName in City"
    -- - "TraderName on Zone"
    -- - "TraderName near Landmark, Zone" (zone trader)
    -- - "TraderName, Zone" (fallback)
    local separators = {
        { token = " in ", preferTrailingCommaSegment = false },
        { token = " on ", preferTrailingCommaSegment = false },
        { token = " near ", preferTrailingCommaSegment = true },
        { token = " at ", preferTrailingCommaSegment = true },
    }

    for i = 1, #separators do
        local sep = separators[i]
        local pos = FindLastPlain(raw, sep.token)
        if pos then
            local left = Trim(string.sub(raw, 1, pos - 1))
            local right = Trim(string.sub(raw, pos + #sep.token))
            if not left then
                return nil, right
            end

            if not right then
                return left, nil
            end

            if sep.preferTrailingCommaSegment then
                local lastComma = FindLastPlain(right, ",")
                if lastComma then
                    local trailing = Trim(string.sub(right, lastComma + 1))
                    if trailing then
                        return left, trailing
                    end
                end
            end

            return left, right
        end
    end

    -- Fallback: if it contains a comma, assume "TraderName, Location"
    local commaPos = FindLastPlain(raw, ",")
    if commaPos then
        local left = Trim(string.sub(raw, 1, commaPos - 1))
        local right = Trim(string.sub(raw, commaPos + 1))
        return left, right
    end

    -- Unknown format - return whole as trader name so we at least cache something.
    return raw, nil
end

---Convert member count to size category
---@param memberCount number
---@return number
function GuildUtils.ConvertMemberCountToSize(memberCount)
    if memberCount < 50 then
        return GUILD_SIZE_ATTRIBUTE_VALUE_SMALL
    elseif memberCount < 150 then
        return GUILD_SIZE_ATTRIBUTE_VALUE_MEDIUM
    elseif memberCount < 300 then
        return GUILD_SIZE_ATTRIBUTE_VALUE_LARGE
    else
        return GUILD_SIZE_ATTRIBUTE_VALUE_GIGANTIC
    end
end

---Get color code based on guild size (derived from member count)
---@param guildSize number
---@return string
function GuildUtils.GetColorCodeForSize(guildSize)
    if guildSize == GUILD_SIZE_ATTRIBUTE_VALUE_SMALL or guildSize == GUILD_SIZE_ATTRIBUTE_VALUE_MEDIUM then
        return "|cFF6666" -- Red
    elseif guildSize == GUILD_SIZE_ATTRIBUTE_VALUE_LARGE then
        return "|cFFFF66" -- Yellow
    elseif guildSize == GUILD_SIZE_ATTRIBUTE_VALUE_GIGANTIC then
        return "|c66FF66" -- Green
    else
        return "|cFFFFFF" -- White
    end
end

---Format display text for guild data (used by reticle + map)
---@param cachedData CachedGuildData|nil
---@param fallbackText string|nil The caller-determined fallback text if we don't have enough guild data
---@return string|nil
function GuildUtils.FormatGuildDisplayText(cachedData, fallbackText)
    if cachedData and cachedData.guildName and cachedData.guildName ~= "" then
        local memberCount = cachedData.memberCount
        if type(memberCount) == "number" and memberCount > 0 then
            local size = cachedData.size
            if type(size) ~= "number" or size == 0 then
                size = GuildUtils.ConvertMemberCountToSize(memberCount)
            end

            local colorCode = GuildUtils.GetColorCodeForSize(size)
            local displayText = cachedData.guildName .. " - " .. memberCount
            return colorCode .. displayText .. "|r"
        end

        return cachedData.guildName
    end

    if fallbackText and fallbackText ~= "" then
        return fallbackText
    end

    return nil
end

---Check if guild has valid finder data
---@param guildId number
---@return boolean
function GuildUtils.HasValidGuildFinderData(guildId)
    if not DoesGuildDataHaveInitializedAttributes(guildId, GUILD_META_DATA_ATTRIBUTE_SIZE) then
        return false
    end

    local name = GetGuildNameAttribute(guildId)
    local size = GetGuildSizeAttribute(guildId)

    if (not name or name == "") and (not size or size == 0) then
        return false
    end

    return true
end

---Get guild details from finder
---@param guildId number
---@return string|nil guildName
---@return string|nil kioskName
---@return number|nil memberCount
function GuildUtils.GetDetailsFromFinder(guildId)
    if not GuildUtils.HasValidGuildFinderData(guildId) then
        return nil, nil, nil
    end

    return GetGuildNameAttribute(guildId),
        GetGuildKioskAttribute(guildId),
        GetGuildSizeAttribute(guildId)
end

---Get cached guild data
---@param guildDataById table<number, CachedGuildData>
---@param guildId number
---@return CachedGuildData|nil
function GuildUtils.GetCachedData(guildDataById, guildId)
    return guildDataById[guildId]
end

---Create cached guild data entry
---@param guildId number
---@param guildName string|nil
---@param kioskName string|nil
---@param memberCount number|nil
---@param traderName string|nil NPC name of the trader
---@param city string|nil Zone/city where trader is located
---@return CachedGuildData
function GuildUtils.CreateCacheEntry(guildId, guildName, kioskName, memberCount, traderName, city)
    local size = nil
    if memberCount and memberCount > 0 then
        size = GuildUtils.ConvertMemberCountToSize(memberCount)
    end

    return {
        guildId = guildId,
        size = size,
        memberCount = memberCount,
        guildName = guildName,
        kioskName = kioskName,
        traderName = traderName,
        city = city
    }
end

---Count cached guilds
---@param guildDataById table<number, CachedGuildData>
---@return number
function GuildUtils.GetCachedCount(guildDataById)
    local count = 0
    for _ in pairs(guildDataById) do
        count = count + 1
    end
    return count
end

---Count cached guilds by size
---@param guildDataById table<number, CachedGuildData>
---@return number[] sizeCounts [small, medium, large, gigantic]
function GuildUtils.GetCachedCountBySize(guildDataById)
    local sizeCounts = { 0, 0, 0, 0 }

    for _, data in pairs(guildDataById) do
        if data.size and data.size >= 1 and data.size <= 4 then
            sizeCounts[data.size] = sizeCounts[data.size] + 1
        end
    end

    return sizeCounts
end

SmartTrader.GuildUtils = GuildUtils
