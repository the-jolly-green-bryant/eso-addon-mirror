local ET = EasyTravel
local internal = ET.internal

local RegisterForEvent = internal.RegisterForEvent

local PlayerList = ZO_InitializingCallbackObject:Subclass()
ET.class.PlayerList = PlayerList

PlayerList.TYPE_GROUP = 1
PlayerList.TYPE_FRIEND = 2
PlayerList.TYPE_GUILD = 3
PlayerList.TYPE_LEADER = 4
PlayerList.TYPE_HOUSE = 5

PlayerList.SET_DIRTY = "SET_DIRTY"

function PlayerList:Initialize(zoneList)
    self.zoneList = zoneList
    self.displayName = GetDisplayName()
    self.playersInZone = {}
    self.players = {}
    self.characters = {}
    self.autocompleteList = {}

    local function SetDirty()
        self.dirty = true
        self:FireCallbacks(PlayerList.SET_DIRTY)
    end

    SetDirty()

    -- friend events
    RegisterForEvent(EVENT_FRIEND_ADDED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_REMOVED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_DISPLAY_NAME_CHANGED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_CHARACTER_UPDATED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_CHARACTER_ZONE_CHANGED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_CHARACTER_LEVEL_CHANGED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_CHARACTER_CHAMPION_POINTS_CHANGED, SetDirty)
    RegisterForEvent(EVENT_FRIEND_PLAYER_STATUS_CHANGED, SetDirty)

    -- group events
    local function SetDirtyIfIsGroupMember(eventCode, unitTag)
        if ZO_Group_IsGroupUnitTag(unitTag) then
            SetDirty()
        end
    end

    RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, SetDirty)
    RegisterForEvent(EVENT_GROUP_MEMBER_LEFT, SetDirty)
    RegisterForEvent(EVENT_LEVEL_UPDATE, SetDirtyIfIsGroupMember)
    RegisterForEvent(EVENT_CHAMPION_POINT_UPDATE, SetDirtyIfIsGroupMember)
    RegisterForEvent(EVENT_ZONE_UPDATE, SetDirtyIfIsGroupMember)
    RegisterForEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS, SetDirtyIfIsGroupMember)
    RegisterForEvent(EVENT_GROUP_MEMBER_ACCOUNT_NAME_UPDATED, SetDirtyIfIsGroupMember)

    -- guild events
    RegisterForEvent(EVENT_GUILD_MEMBER_ADDED, SetDirty)
    RegisterForEvent(EVENT_GUILD_SELF_JOINED_GUILD, SetDirty)
    RegisterForEvent(EVENT_GUILD_MEMBER_REMOVED, SetDirty)
    RegisterForEvent(EVENT_GUILD_SELF_LEFT_GUILD, SetDirty)
    RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_UPDATED, SetDirty)
    RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, SetDirty)
    RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED, SetDirty)
    RegisterForEvent(EVENT_GUILD_MEMBER_CHARACTER_CHAMPION_POINTS_CHANGED, SetDirty)
    RegisterForEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, SetDirty)
end

function PlayerList:Rebuild()
    if(self.dirty) then
        self:Clear()
        self:CollectGroupMembers()
        self:CollectFriends()
        self:CollectGuildMembers()
        self.dirty = false
    end
end

function PlayerList:Clear()
    for zone, players in pairs(self.playersInZone) do
        ZO_ClearTable(players)
    end
    ZO_ClearTable(self.players)
    ZO_ClearTable(self.characters)
    ZO_ClearTable(self.autocompleteList)
end

function PlayerList:AddPlayer(displayName, characterName, level, cp, zoneName, type, zone)
    if(not zone) then
        zone = self.zoneList:GetZoneByZoneName(zoneName)
    end
    local lowerDisplayName = zo_strlower(displayName)
    -- can't jump to players without a zone and we also don't want to overwrite already collected players
    if(not zone or self.players[lowerDisplayName]) then return end

    characterName = zo_strformat("<<1>>", characterName)
    local playerData = {
        displayName = displayName,
        characterName = characterName,
        level = level,
        cp = cp,
        zone = zone,
        type = type
    }

    if(not self.playersInZone[zone.id]) then
        self.playersInZone[zone.id] = {}
    end

    local lowerCharacterName = zo_strlower(characterName)
    self.playersInZone[zone.id][lowerDisplayName] = playerData
    self.players[lowerDisplayName] = playerData
    self.characters[lowerCharacterName] = playerData
    self.autocompleteList[lowerDisplayName] = displayName
    self.autocompleteList[lowerCharacterName] = displayName
end

function PlayerList:CollectGroupMembers()
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local displayName = GetUnitDisplayName(unitTag)
        if((not self:HasDisplayName(displayName)) and displayName ~= self.displayName and IsUnitOnline(unitTag)) then
            local characterName = GetUnitName(unitTag)
            local level = GetUnitLevel(unitTag)
            local cp = GetUnitChampionPoints(unitTag)
            local zoneName = GetUnitZone(unitTag)
            local zone = self.zoneList:GetZoneForGroupMember(unitTag)
            self:AddPlayer(displayName, characterName, level, cp, zoneName, PlayerList.TYPE_GROUP, zone)
        end
    end
end

function PlayerList:CollectFriends()
    for i = 1, GetNumFriends() do
        local displayName, _, status = GetFriendInfo(i)
        local hasChar, characterName, zoneName, _, _, level, cp = GetFriendCharacterInfo(i)
        if(hasChar and (not self:HasDisplayName(displayName)) and displayName ~= self.displayName and status ~= PLAYER_STATUS_OFFLINE) then
            self:AddPlayer(displayName, characterName, level, cp, zoneName, PlayerList.TYPE_FRIEND)
        end
    end
end

function PlayerList:CollectGuildMembers()
    for g = 1, GetNumGuilds() do
        local guildId = GetGuildId(g)
        for i = 1, GetNumGuildMembers(guildId) do
            local displayName, _, _, status = GetGuildMemberInfo(guildId, i)
            local hasChar, characterName, zoneName, _, _, level, cp = GetGuildMemberCharacterInfo(guildId, i)
            if(hasChar and (not self:HasDisplayName(displayName)) and displayName ~= self.displayName and status ~= PLAYER_STATUS_OFFLINE) then
                self:AddPlayer(displayName, characterName, level, cp, zoneName, PlayerList.TYPE_GUILD)
            end
        end
    end
end

function PlayerList.ByTypeCpAndLevel(a, b)
    if(a.type == b.type) then
        if(a.cp > 0 or b.cp > 0) then
            return b.cp < a.cp
        else
            return b.level < a.level
        end
    end

    return a.type < b.type
end

function PlayerList:GetSortedPlayersInZone(zone)
    self:Rebuild()
    local sorted = {}
    local players = self.playersInZone[zone.id]
    if(players) then
        for _, player in pairs(players) do
            sorted[#sorted + 1] = player
        end
        table.sort(sorted, self.ByTypeCpAndLevel)
    end

    return sorted
end

function PlayerList:GetPlayerCountForZone(zone)
    self:Rebuild()
    local count = 0
    local players = self.playersInZone[zone.id]
    if(players) then
        count = NonContiguousCount(players)
    end

    return count
end

function PlayerList:GetPlayerList()
    self:Rebuild()
    return self.players
end

function PlayerList:GetPlayerByDisplayName(displayName)
    return self.players[zo_strlower(displayName)]
end

function PlayerList:GetPlayerByCharacterName(characterName)
    return self.characters[zo_strlower(characterName)]
end

function PlayerList:HasDisplayName(displayName)
    return self.players[zo_strlower(displayName)] ~= nil
end

function PlayerList:HasCharacterName(characterName)
    return self.characters[zo_strlower(characterName)] ~= nil
end

function PlayerList:GetPlayerFromPartialName(partialName)
    local results = GetTopMatchesByLevenshteinSubStringScore(self.autocompleteList, partialName, 1, 1)
    if(#results == 0) then return end
    local name = results[1]
    return self:GetPlayerByDisplayName(name) or self:GetPlayerByCharacterName(name)
end
