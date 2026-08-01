local ArcanumGuildHall = _G["ArcanumGuildHall"]

local function cleanText(text)
    return ArcanumGuildHall.Teleport.CleanText(text or "")
end

local function normalizeText(text)
    local value = cleanText(text)
    if value == "" then
        return ""
    end

    return ArcanumGuildHall.Teleport.NormalizeKey(value)
end

local function stripTextureText(text)
    text = (text or ""):gsub("|t.-|t", "")
    return cleanText(text)
end

local function getGuildHouseSearchText(title, linkText)
    local text = table.concat({
        stripTextureText(title),
        stripTextureText(linkText),
    }, " ")

    text = ArcanumGuildHall.Teleport.NormalizeKey(text)
    text = text:gsub("%s+", " ")
    return ArcanumGuildHall.Teleport.Trim(text)
end

local function getGuildHouseType(title, linkText)
    local text = getGuildHouseSearchText(title, linkText)

    if text == "" then
        return "other"
    end

    if string.find(text, "handwerk", 1, true) then
        return "craft"
    end

    if string.find(text, "auktion", 1, true) or string.find(text, "gildenladen", 1, true) then
        return "auction"
    end

    if string.find(text, "gildenhaus", 1, true) then
        return "guild"
    end

    return "other"
end

local function getGuildHouseIcon(title, linkText)
    local res = ArcanumGuildHallMediaRes
    local houseType = getGuildHouseType(title, linkText)

    if houseType == "craft" then
        return res.IconPortGuildHouseCraft
    end

    if houseType == "auction" then
        return res.IconPortGuildHouseAuction
    end

    if houseType == "guild" then
        return res.IconPortGuildHouseGuild
    end

    return res.IconPortGuildHouseFallback
end

local function getFallbackName()
    return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_TARGET_GUILD_HOUSE")
end

local function getSourceName()
    return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_SOURCE_ADDON")
end

local function buildGuildHouseCallback(houseId, ownerName, targetName)
    if not houseId or houseId <= 0 then
        return nil
    end

    return function()
        local Teleport = ArcanumGuildHall.Teleport

        if Teleport.CheckAvARestriction() then
            return
        end

        local playerName = Teleport.GetPlayerDisplayName()
        local isOwnHouse = ownerName ~= "" and Teleport.SameDisplayName(ownerName, playerName)

        Teleport.pendingNodeRefreshAfterTravel = true

        if isOwnHouse or ownerName == "" then
            RequestJumpToHouse(houseId, false)
        else
            JumpToSpecificHouse(ownerName, houseId, false)
        end

        Teleport.PrintTravelMessage(targetName)
    end
end

function ArcanumGuildHall:IsInArcanumGuild()
    if not self.guildId then
        return false
    end

    for i = 1, GetNumGuilds() do
        if GetGuildId(i) == self.guildId then
            return true
        end
    end

    return false
end

function ArcanumGuildHall:GetGuildHouseData()
    local houses = {}

    if not self.guildId then
        self.guildHouseDataCache = nil
        return houses
    end

    local guildDesc = GetGuildDescription(self.guildId)
    if not guildDesc or guildDesc == "" then
        self.guildHouseDataCache = nil
        return houses
    end

    local cache = self.guildHouseDataCache
    if cache
            and cache.guildId == self.guildId
            and cache.guildDesc == guildDesc
            and cache.houses then
        return cache.houses
    end

    local seen = {}
    local searchIndex = 1

    while true do
        local linkStart, linkEnd, houseIdText, ownerText, linkText = string.find(
                guildDesc,
                "|H%d+:housing:(%d+):([^|]+)|h(.-)|h",
                searchIndex
        )

        if not linkStart then
            break
        end

        local textBeforeLink = guildDesc:sub(1, linkStart - 1)
        local linePrefix = textBeforeLink:match("([^\r\n]*)$") or ""
        linePrefix = linePrefix:gsub("[%s:%-–—]+$", "")

        local houseId = tonumber(houseIdText)
        local ownerName = cleanText(ownerText)
        local title = cleanText(linePrefix)
        local visibleLinkText = cleanText(linkText)
        local dedupeKey = tostring(houseId or 0) .. "|" .. normalizeText(ownerName) .. "|" .. normalizeText(title)

        if houseId and houseId > 0 and not seen[dedupeKey] then
            seen[dedupeKey] = true

            houses[#houses + 1] = {
                title = title,
                houseId = houseId,
                name = ownerName,
                linkText = visibleLinkText,
            }
        end

        searchIndex = linkEnd + 1
    end

    self.guildHouseDataCache = {
        guildId = self.guildId,
        guildDesc = guildDesc,
        houses = houses,
    }

    return houses
end

function ArcanumGuildHall:BuildGuildHouseMenuEntries()
    local entries = {}
    local houses = self:GetGuildHouseData()
    local fallbackName = getFallbackName()

    for i = 1, #houses do
        local house = houses[i]
        local label = house.title

        if label == "" then
            label = house.linkText ~= "" and house.linkText or fallbackName
        end

        if i > 1 then
            entries[#entries + 1] = { label = "-" }
        end

        entries[#entries + 1] = {
            label = label,
            callback = function()
                self:PortToHouse(house.name, house.houseId)
            end,
        }
    end

    return entries
end

-- function ArcanumGuildHall:GetGuildHouseTargets()
--     local houses = self:GetGuildHouseData()
--     local results = {}
--     local fallbackName = getFallbackName()
--     local sourceName = getSourceName()
--
--     for i = 1, #houses do
--         local house = houses[i]
--         local targetName = house.title ~= "" and house.title or house.linkText
--
--         results[#results + 1] = {
--             target = targetName ~= "" and targetName or fallbackName,
--             houseName = house.name or "",
--             houseId = house.houseId,
--             source = sourceName,
--             linkText = house.linkText or "",
--         }
--     end
--
--     table.sort(results, function(a, b)
--         return zo_strlower(a.target or "") < zo_strlower(b.target or "")
--     end)
--
--     return results
-- end

function ArcanumGuildHall:GetGuildHouseEntries()
    local Teleport = self.Teleport
    local sourceData = self:GetGuildHouseData()

--     if #sourceData == 0 then
--         sourceData = self:GetGuildHouseTargets()
--     end

    if #sourceData == 0 then
        return {
            Teleport.CreateDividerEntry(self.GetDefaultLocaleString("TELEPORT_EMPTY_ENTRIES"))
        }
    end

    local entries = {}
    local fallbackName = getFallbackName()
    local sourceName = getSourceName()

    for i = 1, #sourceData do
        local house = sourceData[i]
        local rawTitle = house.title or house.target or ""
        local rawLinkText = house.linkText or ""

        local targetName = stripTextureText(rawTitle)
        if targetName == "" then
            targetName = stripTextureText(rawLinkText)
        end
        if targetName == "" then
            targetName = fallbackName
        end

        local ownerName = house.ownerDisplayName or house.name or house.houseName or ""
        if ownerName ~= "" then
            ownerName = Teleport.Trim(zo_strformat("<<1>>", ownerName))
        end

        entries[#entries + 1] = Teleport.CreateSearchEntry(
                targetName,
                "",
                buildGuildHouseCallback(house.houseId or 0, ownerName, targetName),
                {
                    target = targetName,
                    displayName = "",
                    source = cleanText(house.source or sourceName),
                    zone = ownerName,
                    cost = "",
                    category = Teleport.CATEGORY.HOUSE,
                    wayshrine = targetName,
                    customIcon = getGuildHouseIcon(rawTitle, rawLinkText),
                    guildHouseType = getGuildHouseType(rawTitle, rawLinkText),
                    houseId = house.houseId or 0,
                    ownerDisplayName = ownerName,
                    isOwnedHouse = false,
                    isPreviewHouse = false,
                    isGuildHouse = true,
                }
        )
    end

    return entries
end