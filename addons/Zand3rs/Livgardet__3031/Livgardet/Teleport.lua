local res = LivgardetMediaRes
local data = LivgardetTeleportData

local function isCollectibleUnlocked(collectibleId)
    if (collectibleId == nil) then
        return true
    end

    local _, _, _, _, unlocked = GetCollectibleInfo(collectibleId)
    return unlocked
end

local function getZoneLabel(zone)
    if (zone and zone.name and zone.label) then
        return zone.label .. zone.name .. "|r"
    elseif zone.label then
        return zone.label
    else
        return ""
    end
end

function Livgardet:CreateTeleportEntryList()
    local entryList = {}
    for _, zone in pairs(data.TeleportList) do

        if (isCollectibleUnlocked(zone.collectibleId)) then
            entryList[#entryList + 1] = {
                label = getZoneLabel(zone),
                callback = function()
                    Livgardet:Teleport(zone)
                end,
            }
        end
    end
    return entryList
end

function Livgardet:CreateTeleportNodeEntryList()
    local entryList = {}
    for _, node in pairs(data.TeleportNodeList) do

        if (isCollectibleUnlocked(node.collectibleId) and HasCompletedFastTravelNodePOI(node.id)) then
            entryList[#entryList + 1] = {
                label = getZoneLabel(node),
                callback = function()
                    Livgardet:CityTeleport(node)
                end,
            }
        end
    end

    return entryList
end

function Livgardet:Teleport(zone)
    local porting = false

    if IsInAvAZone() then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA) .. "|r") -- Can't travel to a wayshrine in Cyrodiil
    else

        for p = 1, GetGroupSize() do
            local pTag = GetGroupUnitTagByIndex(p)
            if GetUnitZoneIndex(pTag) == zone.id and CanJumpToGroupMember(pTag) and porting == false and GetUnitDisplayName(pTag) ~= GetUnitDisplayName("player") then
                JumpToGroupMember(GetUnitName(pTag))
                CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetUnitDisplayName(pTag) .. GetString(LIVGARDET_PORT_CHATTEXT) .. zone.name .. "|r")
                porting = true
                break
            end
        end

        if porting == false then
            for f = 1, GetNumFriends() do
                local CharInfo = {}
                CharInfo.displayName, CharInfo.Note, CharInfo.status, CharInfo.secsSinceLogoff = GetFriendInfo(f)
                CharInfo.hasCharacter, CharInfo.characterName, CharInfo.zoneName, CharInfo.classType, CharInfo.alliance, CharInfo.level, CharInfo.championRank, CharInfo.zoneId = GetFriendCharacterInfo(f)
                if CharInfo.status ~= PLAYER_STATUS_OFFLINE and GetZoneIndex(CharInfo.zoneId) == zone.id and porting == false and CharInfo.displayName ~= GetUnitDisplayName("player") then
                    JumpToFriend(CharInfo.displayName)
                    CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_PORT_CHATTEXT) .. zone.name .. "|r")
                    porting = true
                    break
                end
            end
        end

        if porting == false then
            for g = 1, GetNumGuilds() do
                for m = 1, GetNumGuildMembers(GetGuildId(g)) do
                    local CharInfo = {}
                    CharInfo.displayName, CharInfo.Note, CharInfo.GuildMemberRankIndex, CharInfo.status, CharInfo.secsSinceLogoff = GetGuildMemberInfo(GetGuildId(g), m)
                    CharInfo.hasCharacter, CharInfo.characterName, CharInfo.zoneName, CharInfo.classType, CharInfo.alliance, CharInfo.level, CharInfo.championRank, CharInfo.zoneId = GetGuildMemberCharacterInfo(GetGuildId(g), m)
                    CharInfo.guildIndex = g
                    if CharInfo.status ~= PLAYER_STATUS_OFFLINE and GetZoneIndex(CharInfo.zoneId) == zone.id and porting == false and CharInfo.displayName ~= GetUnitDisplayName("player") then
                        JumpToGuildMember(CharInfo.displayName)
                        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_PORT_CHATTEXT) .. zone.name .. "|r")
                        porting = true
                        break
                    end
                end
            end
        end

        if porting == false then
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(LIVGARDET_PORT_CHATTEXT_FALSE) .. "|r")
        end
    end

end

function Livgardet:CityTeleport(node)
    local porting = false

    if IsInAvAZone() then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA) .. "|r") -- Can't travel to a wayshrine in Cyrodiil
    else

        if HasCompletedFastTravelNodePOI(node.id) then
            FastTravelToNode(node.id)
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor1 .. " " .. GetString(LIVGARDET_PORT_CHATTEXT_NODE) .. node.name .. " " .. GetString(LIVGARDET_PORT_CHATTEXT_NODE_COST) .. GetRecallCost(node.id) .. res.IconGold .. "|r")
            porting = true

        end

        if not HasCompletedFastTravelNodePOI(node.id) then
            CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(LIVGARDET_PORT_CHATTEXT_NODE_FALSE) .. "|r")
        end
    end

end

function Livgardet:PortToHouse(name, houseId, message)
    if IsInAvAZone() then
        CHAT_ROUTER:AddSystemMessage(res.IconAA .. res.Ccolor3 .. " " .. GetString(SI_TOOLTIP_WAYSHRINE_CANT_RECALL_AVA) .. "|r") -- Can't travel to a wayshrine in Cyrodiil

    elseif (GetDisplayName() == name) then
        RequestJumpToHouse(houseId)
    else
        JumpToSpecificHouse(name, houseId)
    end
    CHAT_ROUTER:AddSystemMessage(message)
end
