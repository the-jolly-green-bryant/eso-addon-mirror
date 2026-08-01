WingsOfWindGuildhall = WingsOfWindGuildhall or {}

WingsOfWindGuildhall.Util = {}

local Util = WingsOfWindGuildhall.Util

function Util.GetOwnedHouseNames()
    local houseNames = {}

    --[[
    for _, houseData in pairs(COLLECTIONS_BOOK_SINGLETON:GetOwnedHouses()) do
        table.insert(houseNames, GetCollectibleName(GetCollectibleIdForHouse(houseData.houseId)))
    end
    ]]--

    WORLD_MAP_HOUSES_DATA:RefreshHouseList()
    local houses = WORLD_MAP_HOUSES_DATA:GetHouseList()

    for i = 1, #houses do
        if houses[i].unlocked then
            table.insert(houseNames, houses[i].houseName)
        end
    end

    return houseNames
end

function Util.GetHouseIdByName(name)
    WORLD_MAP_HOUSES_DATA:RefreshHouseList()
    local houses = WORLD_MAP_HOUSES_DATA:GetHouseList()

    for i = 1, #houses do
        if houses[i].houseName == name then
            return houses[i].houseId
        end
    end
end

function Util.GetHouseNameById(houseId)
    return GetCollectibleName(GetCollectibleIdForHouse(houseId))
end

function Util.IsPlayerInGuild(guildId)
    for i = 1, GetNumGuilds() do
        if GetGuildId(i) == guildId then
            return true
        end
    end

    return false
end

function Util.GetPlayerRankNameInGuild(guildId)
    if not Util.IsPlayerInGuild(guildId) then
        return
    end

    local _, _, rankIndex = GetGuildMemberInfo(guildId, GetPlayerGuildMemberIndex(guildId))

    return GetFinalGuildRankName(guildId, rankIndex)
end

function Util.GetPlayerZoneId()
    return GetZoneId(GetUnitZoneIndex("player"))
end

function Util.GetUnitTagZoneId(unitTag)
    return GetZoneId(GetUnitZoneIndex(unitTag))
end

function Util.GetRankNameInGuild(guildId, displayName)
    local _, _, rankIndex = GetGuildMemberInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, displayName))

    return GetFinalGuildRankName(guildId, rankIndex)
end

function Util.GetGroupUnitTags()
    local allUnitTags = {}

    for index = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(index)

        if unitTag then
            table.insert(allUnitTags, unitTag)
        end
    end

    return allUnitTags
end

function Util.IsTableEmpty(obj)
    return next(obj) == nil
end
