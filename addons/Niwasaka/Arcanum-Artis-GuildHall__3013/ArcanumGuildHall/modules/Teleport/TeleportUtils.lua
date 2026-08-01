local ArcanumGuildHall = _G["ArcanumGuildHall"]
local res = ArcanumGuildHallMediaRes

ArcanumGuildHallTeleportUI = ArcanumGuildHallTeleportUI or {}
local UI = ArcanumGuildHallTeleportUI

ArcanumGuildHall.Teleport = ArcanumGuildHall.Teleport or {}
local Teleport = ArcanumGuildHall.Teleport

UI.activeTab = UI.activeTab or "network"
UI.initialized = UI.initialized or false
UI.searchText = UI.searchText or ""
UI.pendingSearchText = UI.pendingSearchText or ""
UI.filters = UI.filters or {}
UI.filters.category = UI.filters.category or "all"
UI.filters.house = UI.filters.house or "all"
UI.filters.favoriteOnly = UI.filters.favoriteOnly or false

UI.cache = UI.cache or {}
UI.cache.dirtyNodes = UI.cache.dirtyNodes ~= false
UI.cache.dirtyPlayers = UI.cache.dirtyPlayers ~= false

Teleport.EVENT_NAMESPACE = "ArcanumGuildHallTeleportWindow"
Teleport.pendingNodeRefreshAfterTravel = Teleport.pendingNodeRefreshAfterTravel or false
Teleport.eventsRegistered = Teleport.eventsRegistered or false

Teleport.CATEGORY = Teleport.CATEGORY or {
    ZONE = 1,
    DUNGEON = 2,
    TRIAL = 3,
    ARENA = 4,
    HOUSE = 5,
}

Teleport.CATEGORY_KEY_BY_ID = Teleport.CATEGORY_KEY_BY_ID or {
    [Teleport.CATEGORY.ZONE] = "zone",
    [Teleport.CATEGORY.DUNGEON] = "dungeon",
    [Teleport.CATEGORY.TRIAL] = "trial",
    [Teleport.CATEGORY.ARENA] = "arena",
    [Teleport.CATEGORY.HOUSE] = "house",
}

Teleport.CATEGORY_ID_BY_KEY = Teleport.CATEGORY_ID_BY_KEY or {
    zone = Teleport.CATEGORY.ZONE,
    dungeon = Teleport.CATEGORY.DUNGEON,
    trial = Teleport.CATEGORY.TRIAL,
    arena = Teleport.CATEGORY.ARENA,
    house = Teleport.CATEGORY.HOUSE,
}

function Teleport.Trim(text)
    if not text or text == "" then
        return ""
    end

    return (text:gsub("^%s*(.-)%s*$", "%1"))
end

function Teleport.UppercaseFirst(text)
    if not text or text == "" then
        return ""
    end

    return (text:gsub("^%l", string.upper))
end

function Teleport.CleanText(text)
    if not text or text == "" then
        return ""
    end

    text = zo_strformat("<<1>>", text)
    text = text:gsub("%^%a", "")
    text = Teleport.Trim(text)
    text = Teleport.UppercaseFirst(text)
    return text
end

function Teleport.NormalizeKey(text)
    return zo_strlower(Teleport.CleanText(text))
end

function Teleport.NormalizeZoneMatchKey(text)
    text = Teleport.NormalizeKey(text)
    text = text:gsub("[%[%]%(%)%,%.%!%?%-%_]", " ")
    text = text:gsub("%s+", " ")
    text = text:gsub("^the%s+", "")
    text = text:gsub("%s+wayshrine$", "")
    text = Teleport.Trim(text)
    return text
end

local WAYSHRINE_ARTICLE_RULES = {
    { pattern = "^Der%s+(Wegschrein.*)$", replacement = "%1" },
    { pattern = "^The%s+(Wayshrine.*)$", replacement = "%1" },
}

local ARTICLE_PATTERNS = {
    "^Der%s+",
    "^Die%s+",
    "^Das%s+",
    "^The%s+",
}

local function stripWayshrineArticle(text)
    for i = 1, #WAYSHRINE_ARTICLE_RULES do
        local rule = WAYSHRINE_ARTICLE_RULES[i]
        local stripped, count = text:gsub(rule.pattern, rule.replacement, 1)

        if count > 0 then
            stripped = Teleport.Trim(stripped)
            if stripped ~= "" then
                return stripped
            end
        end
    end

    return text
end

local function stripArticle(text)
    for i = 1, #ARTICLE_PATTERNS do
        local stripped, count = text:gsub(ARTICLE_PATTERNS[i], "", 1)

        if count > 0 then
            stripped = Teleport.Trim(stripped)
            if stripped ~= "" then
                return stripped
            end
        end
    end

    return text
end

local function addSuffix(text, suffix)
    if not suffix or suffix == "" then
        return text
    end

    if text == "" then
        return ""
    end

    if string.find(text, "%[" .. suffix .. "%]$", 1, false) then
        return text
    end

    return string.format("%s [%s]", text, suffix)
end

function Teleport.PrintTravelMessage(targetName, goldCost)
    targetName = Teleport.CleanText(targetName)
    if targetName == "" then
        return
    end

    local prefix = (res.IconAA or "") .. " "
    local primary = res.Ccolor1 or ""
    local accent = res.Ccolor8 or ""
    local reset = "|r"

    local coloredTarget = accent .. targetName .. primary
    local message

    if goldCost and goldCost > 0 then
        local coloredCost = accent .. tostring(goldCost) .. primary
        message = zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CHAT_TRAVEL_COST"),
                coloredTarget,
                coloredCost
        )
    else
        message = zo_strformat(
                ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CHAT_TRAVEL"),
                coloredTarget
        )
    end

    CHAT_ROUTER:AddSystemMessage(prefix .. primary .. message .. reset)
end

function Teleport.PrintInvalidTargetMessage()
    CHAT_ROUTER:AddSystemMessage(
            (res.IconAA or "") .. " "
                    .. (res.Ccolor3 or "")
                    .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CHAT_INVALID_TARGET")
                    .. "|r"
    )
end

function Teleport.PrintWayshrineUnknownMessage()
    CHAT_ROUTER:AddSystemMessage(
            (res.IconAA or "") .. " "
                    .. (res.Ccolor3 or "")
                    .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CHAT_WAYSHRINE_UNKNOWN")
                    .. "|r"
    )
end

function Teleport.PrintCantRecallAvAMessage()
    CHAT_ROUTER:AddSystemMessage(
            (res.IconAA or "") .. " "
                    .. (res.Ccolor3 or "")
                    .. ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CHAT_CANT_RECALL_AVA")
                    .. "|r"
    )
end

function Teleport.IsBlockedByAvA()
    return IsInAvAZone and IsInAvAZone() or false
end

function Teleport.CheckAvARestriction()
    if Teleport.IsBlockedByAvA() then
        Teleport.PrintCantRecallAvAMessage()
        return true
    end

    return false
end

function Teleport.GetCategoryDisplayName(categoryId)
    if categoryId == Teleport.CATEGORY.ZONE then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CATEGORY_ZONE")
    end

    if categoryId == Teleport.CATEGORY.DUNGEON then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CATEGORY_DUNGEON")
    end

    if categoryId == Teleport.CATEGORY.TRIAL then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CATEGORY_TRIAL")
    end

    if categoryId == Teleport.CATEGORY.ARENA then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CATEGORY_ARENA")
    end

    if categoryId == Teleport.CATEGORY.HOUSE then
        return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_CATEGORY_HOUSE")
    end

    return ArcanumGuildHall.GetDefaultLocaleString("TELEPORT_VALUE_EMPTY")
end

function Teleport.CleanTrialDisplayName(text)
    text = Teleport.CleanText(text)
    if text == "" then
        return ""
    end

    text = text:gsub("%s*%(%s*[Pp]rüfung%s*%)%s*$", "")
    text = text:gsub("%s*%(%s*[Tt]rial%s*%)%s*$", "")
    text = Teleport.Trim(text)

    if text == "" then
        return ""
    end

    return Teleport.UppercaseFirst(text)
end

function Teleport.CleanDisplayNameByCategory(text, categoryId)
    text = Teleport.CleanText(text)
    if text == "" then
        return ""
    end

    if categoryId == Teleport.CATEGORY.TRIAL then
        text = Teleport.CleanTrialDisplayName(text)
    elseif categoryId == Teleport.CATEGORY.DUNGEON then
        text = text:gsub("%s*%(%s*[Vv]erlies%s*%)%s*$", "")
        text = text:gsub("%s*%(%s*[Dd]ungeon%s*%)%s*$", "")
        text = Teleport.Trim(text)
    end

    if categoryId == Teleport.CATEGORY.TRIAL
            or categoryId == Teleport.CATEGORY.ARENA
            or categoryId == Teleport.CATEGORY.DUNGEON
            or categoryId == Teleport.CATEGORY.HOUSE then
        text = stripArticle(text)
    end

    text = Teleport.Trim(text)

    if text == "" then
        return ""
    end

    return Teleport.UppercaseFirst(text)
end

function Teleport.CleanWayshrineDisplayName(text, categoryId)
    text = Teleport.CleanText(text)
    if text == "" then
        return ""
    end

    text = stripWayshrineArticle(text)
    text = Teleport.Trim(text)

    if text == "" then
        return ""
    end

    text = Teleport.CleanDisplayNameByCategory(text, categoryId)

    if text == "" then
        return ""
    end

    return Teleport.UppercaseFirst(text)
end

function Teleport.GetTrialAbbreviation(text, zoneId, nodeIndex)
    if zoneId and Teleport.GetZoneEntry then
        local entry = Teleport.GetZoneEntry(zoneId)
        if entry and entry.category == Teleport.CATEGORY.TRIAL and entry.abbreviation and entry.abbreviation ~= "" then
            return entry.abbreviation
        end
    end

    if nodeIndex and Teleport.GetTrialAbbreviationByNodeIndex then
        local abbreviation = Teleport.GetTrialAbbreviationByNodeIndex(nodeIndex)
        if abbreviation and abbreviation ~= "" then
            return abbreviation
        end
    end

    local cleanName = Teleport.CleanTrialDisplayName(text)
    local nameKey = Teleport.NormalizeKey(cleanName)
    local zoneKey = Teleport.NormalizeZoneMatchKey(cleanName)

    if Teleport.GetTrialAbbreviationByNameKey then
        local abbreviation = Teleport.GetTrialAbbreviationByNameKey(nameKey)
        if abbreviation and abbreviation ~= "" then
            return abbreviation
        end
    end

    if Teleport.GetTrialAbbreviationByZoneKey then
        local abbreviation = Teleport.GetTrialAbbreviationByZoneKey(zoneKey)
        if abbreviation and abbreviation ~= "" then
            return abbreviation
        end
    end

    return nil
end

function Teleport.FormatTargetDisplayName(text, categoryId, zoneId, nodeIndex)
    local displayName = Teleport.CleanWayshrineDisplayName(text, categoryId)

    if categoryId == Teleport.CATEGORY.TRIAL then
        displayName = addSuffix(displayName, Teleport.GetTrialAbbreviation(displayName, zoneId, nodeIndex))
    end

    return displayName
end

function Teleport.ContainsSearch(haystack, needle)
    if not needle or needle == "" then
        return true
    end

    if not haystack or haystack == "" then
        return false
    end

    return string.find(haystack, needle, 1, true) ~= nil
end

function Teleport.SameDisplayName(a, b)
    if not a or not b then
        return false
    end

    return zo_strlower(a) == zo_strlower(b)
end

function Teleport.GetPlayerDisplayName()
    return GetUnitDisplayName("player") or GetDisplayName()
end

function Teleport.GetRecallCostSafe(nodeId)
    if not nodeId then
        return 0
    end

    return GetRecallCost(nodeId) or 0
end

function Teleport.GetCostText(nodeId)
    return tostring(Teleport.GetRecallCostSafe(nodeId)) .. "g"
end

function Teleport.GetCategoryIdByKey(key)
    return Teleport.CATEGORY_ID_BY_KEY[key] or Teleport.CATEGORY.ZONE
end

function Teleport.GetCategoryKeyById(categoryId)
    return Teleport.CATEGORY_KEY_BY_ID[categoryId] or "zone"
end

function Teleport.CreateDividerEntry(text)
    return {
        entryType = "divider",
        text = text or "----------------",
    }
end

function Teleport.CreateActionEntry(text, tooltipText, callback, details)
    return {
        entryType = "action",
        text = text or "",
        tooltip = tooltipText or text or "",
        callback = callback,
        details = details or {},
    }
end

function Teleport.FillSearchData(details)
    details = details or {}
    details.searchTarget = Teleport.NormalizeKey(details.target or "")
    details.searchDisplayName = Teleport.NormalizeKey(details.displayName or "")
    details.searchSource = Teleport.NormalizeKey(details.source or "")
    details.searchZone = Teleport.NormalizeKey(details.zone or "")
    return details
end

function Teleport.CreateSearchEntry(text, tooltipText, callback, details)
    return Teleport.CreateActionEntry(text, tooltipText, callback, Teleport.FillSearchData(details))
end

function Teleport.CanFavoriteEntry(entry)
    if not entry or entry.entryType ~= "action" then
        return false
    end

    local details = entry.details or {}

    if details.isUnknown then
        return false
    end

    if details.isGuildHouse then
        return false
    end

    if entry.callback == nil then
        return false
    end

    return true
end

function Teleport.GetFavoritesStore()
    if not ArcanumGuildHall.db then
        return nil
    end

    ArcanumGuildHall.db.teleportFavorites = ArcanumGuildHall.db.teleportFavorites or {}
    return ArcanumGuildHall.db.teleportFavorites
end

function Teleport.MigrateFavoriteKeys()
    if not ArcanumGuildHall.db then
        return
    end

    if (ArcanumGuildHall.db.teleportFavoritesVersion or 0) >= 2 then
        return
    end

    local store = Teleport.GetFavoritesStore()
    if not store then
        ArcanumGuildHall.db.teleportFavoritesVersion = 2
        return
    end

    local keysToRemove = {}

    for key, value in pairs(store) do
        if value then
            local categoryKey, targetKey = string.match(key, "^text:([^:]+):([^:]+):")

            if categoryKey and targetKey and targetKey ~= "" then
                local newKey = table.concat({
                    "target",
                    categoryKey,
                    targetKey,
                }, ":")

                store[newKey] = true
                keysToRemove[#keysToRemove + 1] = key
            end
        end
    end

    for i = 1, #keysToRemove do
        store[keysToRemove[i]] = nil
    end

    ArcanumGuildHall.db.teleportFavoritesVersion = 2
end

function Teleport.GetFavoriteKey(entry)
    if not Teleport.CanFavoriteEntry(entry) then
        return nil
    end

    local details = entry.details or {}

    if details.houseId and details.houseId > 0 then
        return "house:" .. tostring(details.houseId)
    end

    if details.nodeId and details.nodeId > 0 then
        return "node:" .. tostring(details.nodeId)
    end

    if details.zoneId and details.zoneId > 0 then
        return table.concat({
            "zone",
            tostring(details.category or 0),
            tostring(details.zoneId),
        }, ":")
    end

    local targetKey = Teleport.NormalizeKey(details.target or entry.text or "")
    if targetKey == "" then
        return nil
    end

    return table.concat({
        "target",
        tostring(details.category or 0),
        targetKey,
    }, ":")
end

function Teleport.IsFavorite(entry)
    if not Teleport.CanFavoriteEntry(entry) then
        return false
    end

    local store = Teleport.GetFavoritesStore()
    local key = Teleport.GetFavoriteKey(entry)

    if not store or not key then
        return false
    end

    return store[key] and true or false
end

function Teleport.SetFavorite(entry, isFavorite)
    if not Teleport.CanFavoriteEntry(entry) then
        return false
    end

    local store = Teleport.GetFavoritesStore()
    local key = Teleport.GetFavoriteKey(entry)

    if not store or not key then
        return false
    end

    if isFavorite then
        store[key] = true
    else
        store[key] = nil
    end

    return true
end

function Teleport.ToggleFavorite(entry)
    if not Teleport.CanFavoriteEntry(entry) then
        return false
    end

    local newState = not Teleport.IsFavorite(entry)
    Teleport.SetFavorite(entry, newState)
    return newState
end

function Teleport.GetPrimaryHouseId()
    if GetHousingPrimaryHouse then
        return GetHousingPrimaryHouse() or 0
    end

    return 0
end

function Teleport.TravelToKnownHouse(houseId, travelOutside, houseName)
    if Teleport.CheckAvARestriction() then
        return false
    end

    if not houseId or houseId <= 0 then
        Teleport.PrintInvalidTargetMessage()
        return false
    end

    Teleport.pendingNodeRefreshAfterTravel = true
    RequestJumpToHouse(houseId, travelOutside == true)
    Teleport.PrintTravelMessage(houseName or "")
    return true
end

function Teleport.TravelToPrimaryHouse(travelOutside, houseName)
    if Teleport.CheckAvARestriction() then
        return false
    end

    local primaryHouseId = Teleport.GetPrimaryHouseId()
    if not primaryHouseId or primaryHouseId <= 0 then
        Teleport.PrintInvalidTargetMessage()
        return false
    end

    Teleport.pendingNodeRefreshAfterTravel = true
    RequestJumpToHouse(primaryHouseId, travelOutside == true)
    Teleport.PrintTravelMessage(houseName or "")
    return true
end

function Teleport.PreviewUnownedHouse(houseId, houseName)
    if Teleport.CheckAvARestriction() then
        return false
    end

    if not houseId or houseId <= 0 then
        Teleport.PrintInvalidTargetMessage()
        return false
    end

    Teleport.pendingNodeRefreshAfterTravel = true
    RequestJumpToHouse(houseId, false)
    Teleport.PrintTravelMessage(houseName or "")
    return true
end