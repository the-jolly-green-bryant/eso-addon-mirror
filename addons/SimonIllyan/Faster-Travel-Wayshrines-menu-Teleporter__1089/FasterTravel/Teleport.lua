local Teleport = FasterTravel.Teleport or {}
local Utils = FasterTravel.Utils
local LocationData = FasterTravel.Location.Data
local libZone = LibZone

local majorZones = {}
for i, v in ipairs(LocationData.GetList()) do
    majorZones[string.lower(v.name)] = true    
end

local reasonsToDeclineTeleporting = {
    SI_JUMPRESULT16,         -- You must be level 50 to enter a veteran instance.
    SI_SOCIALACTIONRESULT37, -- You cannot jump while in combat. 				
    SI_SOCIALACTIONRESULT38, -- Not in same group. 								
    SI_SOCIALACTIONRESULT48, -- Cannot jump out of this area. 					
    SI_SOCIALACTIONRESULT53, -- You must be level 50 to travel to that location. 
    SI_SOCIALACTIONRESULT54, -- Your destination does not allow Travel to Player.
}
local messageString
local reasonsToDeclineTeleportingLookup = {}
for i, code in ipairs(reasonsToDeclineTeleporting) do
    messageString = GetString(code)
    reasonsToDeclineTeleportingLookup[messageString] = true
end

-- cache for formatted zone names
local _zoneNameCache = {}
local function GetZoneName(zoneName)
    if Utils.stringIsEmpty(zoneName) then return zoneName end
    local localeName = _zoneNameCache[zoneName]
    if localeName == nil then
        localeName = Utils.FormatStringCurrentLanguage(zoneName)
        _zoneNameCache[zoneName] = localeName
    end
    return localeName
end

local function GetGuildPlayers(guildId)
    if guildId == nil then return {} end

    local tbl = {}

    local playerIndex = GetPlayerGuildMemberIndex(guildId)
    for i = 1, GetNumGuildMembers(guildId) do
        if i ~= playerIndex then
            local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, i)
            if playerStatus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 then
                local hasChar, charName, zoneName, classtype, alliance, level, rank, zoneId = GetGuildMemberCharacterInfo(guildId, i)
                if hasChar and CanJumpToPlayerInZone(zoneId) then
                    table.insert(tbl, {
                        tag = name,
                        zoneName = GetZoneName(zoneName),
                        name = charName
                    })
                end
            end
        end
    end

    -- table.sort(tbl, function(x, y) return x.name < y.name end)
    return tbl
end

-- get a table of zoneName-> array of {tag, name, zoneName, alliance} from guilds
local function GetZonesGuildLookup()
    local returnValue = {}
    local gCount = GetNumGuilds()
    local pCount = 0
    local cCount = 0
    -- local pAlliance = GetUnitAlliance("player")
    local pName = string.lower(GetDisplayName())
    local id
    for g = 1, gCount do
        id = GetGuildId(g)
        pCount = GetNumGuildMembers(id)
        for p = 1, pCount do
            local playerName, note, rankindex, playerStatus, secsSinceLogoff =
                GetGuildMemberInfo(id, p)
            -- only get players that are online >_<
            if playerStatus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 and
                pName ~= string.lower(playerName) then
                local hasChar, charName, zoneName, classtype, alliance, level, rank, zoneId =
                    GetGuildMemberCharacterInfo(id, p)
                if hasChar and CanJumpToPlayerInZone(zoneId) then
                    local lowerZoneName = string.lower(Utils.FormatStringCurrentLanguage(zoneName))
                    returnValue[lowerZoneName] = returnValue[lowerZoneName] or {}
                    table.insert(returnValue[lowerZoneName],
                        {
                            tag = playerName,
                            zoneName = GetZoneName(zoneName), -- uses locale
                            lowerZoneName = lowerZoneName,
                            alliance = alliance,
                            name = charName
                        })
                end
            end
        end
    end
    return returnValue
end

-- get a table of {displayName,zoneName,alliance} from friends list
local function GetFriendsInfo()
    local returnValue = {}
    local fCount = GetNumFriends()

    for i = 1, fCount do
		local displayName, note, playerstatus, secsSinceLogoff = GetFriendInfo(i)

        -- only get players that are online >_<
		if playerstatus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 then
            local hasChar, charName, zoneName, classtype, alliance, level, rank, zoneId =
                GetFriendCharacterInfo(i)
            if hasChar and CanJumpToPlayerInZone(zoneId) then
                zoneName = GetZoneName(zoneName)
                table.insert(returnValue, { tag = displayName, name = charName, zoneName = zoneName, alliance = alliance })
            end
        end
    end
    return returnValue
end


-- get a table of {playerName?,zoneName,alliance,groupLeader} from group list
local function GetGroupInfo()
    local returnValue = {}

    local gCount = GetGroupSize()

    local pChar = string.lower(GetUnitName("player"))

    for i = 1, gCount do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then 
            local unitName = GetUnitName(unitTag)
            local zoneId = GetZoneId(GetUnitZoneIndex(unitTag))
            -- only get players that are online >_<
            if CanJumpToPlayerInZone(zoneId) and IsUnitOnline(unitTag) and string.lower(unitName) ~= pChar then
                table.insert(returnValue, {
                    name = unitName, -- Character nickname
                    zoneName = GetZoneName(GetUnitZone(unitTag)),
                    alliance = GetUnitAlliance(unitTag),
                    isLeader = IsUnitGroupLeader(unitTag),
                    charName = GetUniqueNameForCharacter(unitName),
                    tag = unitTag, -- Format: group{index}
                })
            end
        end
    end

    return returnValue
end

local function IsPlayerReallyInGroup(playerName)
    local gCount = GetGroupSize()
    local pName = string.lower(playerName)

    for i = 1, gCount do
        local unitTag = GetGroupUnitTagByIndex(i)
        -- only get players that are online >_<
        if unitTag ~= nil and string.lower(GetUnitName(unitTag)) == pName then
            return true
        end
    end
    return IsPlayerInGroup(playerName)
end

-- search all guilds for playerName
local function IsPlayerInGuild(playerName)
    local gCount = GetNumGuilds()

    local pCount = 0
    local id
    for g = 1, gCount do

        id = GetGuildId(g)
        pCount = GetNumGuildMembers(id)

        for p = 1, pCount do
            local name = GetGuildMemberInfo(id, p)
            if string.lower(playerName) == string.lower(name) then
                return true
            end
        end
    end
    return false
end

local function IsCurrentPlayerName(playerName)
    local unitName = GetUnitName("player")
    return string.lower(playerName) == string.lower(unitName)
end

local function IsPlayerTeleportable(destination)
    if destination == nil then return false end
    local unitName = GetUnitName(string.lower(destination))
    Utils.chat(3, "Check teleportable: %s, %s", destination, unitName)
    if not Utils.stringIsEmpty(unitName) then
        return not IsCurrentPlayerName(destination) and 
            (IsPlayerReallyInGroup(unitName) or IsFriend(unitName) or IsPlayerInGuild(unitName))
    else
        -- Not a player with recognizable tag.
        return false
    end
end

-- Tries to teleport to player by his login. For guildmate or friend name.
local function TeleportToPlayerByLogin(login)
    Utils.chat(3, "Trying player named %s", login or "(nil)")
    if login then
        local jumpFunction
        if IsFriend(login) then
            jumpFunction = JumpToFriend
        elseif IsPlayerInGuild(login) then
            jumpFunction = JumpToGuildMember
        else
            return false, login
        end
        Utils.chat(2, "Teleporting to player %s", Utils.bold(login))
        jumpFunction(login)
        return true, login
    else
		return false 
	end

end

local function TeleportToPlayer(tag)
    if tag == nil then
        Utils.chat(3, "Empty player tag")
        return false, nil
    end
    local mateName = GetUnitName(tag)
	if mateName ~= "" and GetGroupIndexByUnitTag(tag) then
        Utils.chat(2, "Teleporting to player %s", Utils.bold(mateName))
        JumpToGroupMember(mateName)
        return true, mateName
    else
        return TeleportToPlayerByLogin(tag)
    end
end

local function TeleportToGroup()
    local target = nil
    local leaderTag = GetGroupLeaderUnitTag()
	if leaderTag == "" then
		Utils.chat(1, "Not in group")
		return false, nil
	elseif IsCurrentPlayerName(GetUnitName(leaderTag)) then
		-- you're the leader
        local groupInfo = GetGroupInfo()
		for _, player in ipairs(groupInfo) do
			if player and not IsCurrentPlayerName(player.name) then
				Utils.chat(3, "Player: %s Tag: %s CanJump: %s", player.name, player.tag,
					(CanJumpToGroupMember(player.tag) and "yes" or "no"))
				target = player.tag
				break
			end
		end
        if Utils.stringIsEmpty(target) then
			Utils.chat(2, "Failed to find group member")
		end
	else
        -- Another player is a leader.
        target = leaderTag
    end
    Utils.chat(3, "group target %s", target)
	return TeleportToPlayer(target)
end

local function IsPartialMatch(lowerZoneName, lowerKey)

    local strippedKey = lowerKey:gsub('%W', '')
    -- matches without punctuation
    if lowerZoneName == strippedKey then return true end
    --  key starts with string
    return string.sub(strippedKey, 1, string.len(lowerZoneName)) == lowerZoneName
end

local function checkPartialMatch(partialKey, name)
    if name then
        local index = string.find(string.lower(name), partialKey)
        Utils.chat(4, "Name: %s Key: %s Match found: %s", name, partialKey, (index or "false"))
		if index ~= nil then
			return true
		end
    end
    Utils.chat(4, "Name empty, no match.")
    return false
end

local function ExpandZoneName(zoneName)
    -- gets any part of zonename, returns full zonename in lowercase
    if not zoneName then return nil end
	local zonesList = LocationData.GetList()
	local lowerZoneName = string.lower(zoneName)
	for k, v in pairs(zonesList) do
		if string.lower(v.name) == lowerZoneName then 
			return lowerZoneName
		end
	end
	for k, v in pairs(zonesList) do
		if checkPartialMatch(lowerZoneName, v.name) then 
            Utils.chat(2, "%s expanded to %s", Utils.bold(zoneName), Utils.bold(v.name))
			return string.lower(v.name)
		end
	end
	return lowerZoneName
end

local function GetClosestGuildLookup(expandedZoneName)
    local lookups = GetZonesGuildLookup()
	return lookups[expandedZoneName]
end

local function GetGuildMembersLookup()
    local lookups = GetZonesGuildLookup()
    local k, v
    local result = {}
    for k, v in pairs(lookups)  do
        if #v > 0 then -- there are guildies in this zone
            Utils.copy(v, result)
        end
    end
    return result
end

local function GetParentZone(lowerZoneName)
    if libZone then
		local zoneId = LocationData.GetZoneIdByName(lowerZoneName)
        if zoneId then
            local parentZone, subZone = libZone:GetZoneDataBySubZone(zoneId)
            return Utils.FormatStringCurrentLanguage(parentZone[zoneId].name)
        else 
            return nil
        end
    else
        Utils.chat(3, "LibZone not found")
        return nil
    end
end

local function GetTeleportIterator(expandedZoneName, parent)
    Utils.chat(3, "expandedZoneName='%s', parent='%s'",
        expandedZoneName or "(nil)",
        parent or "(nil)")
	
	local function checkTargetZone(item)
        Utils.chat(4, "item.zoneName=%s", item.zoneName)
		return expandedZoneName == string.lower(item.zoneName)
	end
    
    local function isZoneMajor(zone)
        return ( majorZones[zone.lowerZoneName] and
			-- Cyrodiil is not teleportable despite being a major zone!
			zone.lowerZoneName ~= "cyrodiil" )
    end
	
	local randomizeTable = {}
    local locTable = {}
    
    if expandedZoneName then -- specific zone
        Utils.copy(Utils.where(GetGroupInfo(), checkTargetZone), randomizeTable)
        -- not in same group, might be impossible to jump
        Utils.copy(Utils.where(GetFriendsInfo(), checkTargetZone), randomizeTable)
        Utils.copy(GetClosestGuildLookup(expandedZoneName), randomizeTable)
    else -- random jump
        -- allow either a group member…
        Utils.copy(GetGroupInfo(), randomizeTable)
        -- …or someone in a major zone (not dungeon etc.) AND not Cyrodiil
        Utils.copy(Utils.where(GetGuildMembersLookup(), isZoneMajor), randomizeTable)
        Utils.copy(Utils.where(GetFriendsInfo(), isZoneMajor), randomizeTable)
        -- parent zone has priority
        if parent then
            Utils.shuffle(GetClosestGuildLookup(string.lower(parent)), locTable)
        end
    end
    
    -- append randomized part to fixed part
	--[[
	local rrr = {}
	for i, v in ipairs(randomizeTable) do
		table.insert(rrr, v.tag)
	end
	Utils.chat(3, "GetTeleportIterator - shuffling [%s]", table.concat(rrr, ' '))
	]]--
	Utils.shuffle(randomizeTable, locTable)
    
    local count = #locTable
    Utils.chat(3, "GetTeleportIterator has %d items", count)
    if count == 0 then
        return nil
    end

    local cur = 0

    return function()
        while cur < count do
			cur = cur + 1
			local player = locTable[cur]
			if player then
				return player
			end
		end
        return nil
    end
    
end

local ZoneTeleporter = FasterTravel.class()

function ZoneTeleporter:init()

    local _teleportIter
    local _teleportCallback

    local _result
    local _delayTime = 3500
    local _expiryTime = 3500
    
    local _parent
	local _forced_jump

    local function Reset()
        _teleportIter = nil
        _result = nil
    end
    
    local TryNextPlayer
    
    local function TargetZoneInaccessible(message)
        local result = reasonsToDeclineTeleportingLookup[message]
        Utils.chat(3, "TargetZoneInaccessible %s '%s'", tostring(result), message or '(nil)')
        return result
    end
    
    local function NoPlayersFound(zoneName)
        Reset()
        local lowerZoneName = string.lower(zoneName)
        if zoneName and zoneName ~= "" then
            Utils.chat(2, "No eligible players in zone %s.", zoneName)
            -- set _parent only if different from zoneName
            local parent = GetParentZone(lowerZoneName)
            Utils.chat(3, "From GetParentZone(%s): parent = %s", lowerZoneName, parent or "(nil)")
            if parent and lowerZoneName ~= string.lower(parent) then
                _parent = parent
            else
                _parent = nil
            end
			Utils.chat(3, "_forced_jump = %s", tostring(_forced_jump))
            if _forced_jump == nil and FasterTravel.settings.jumpHereBehaviour == FasterTravel.Options.JumpHereBehaviour.ASK then
                ZO_Dialogs_ShowDialog(
                    Utils.UniqueDialogName("RandomJumpConfirmation"),
                    nil,
                    { mainTextParams = { zoneName } }
                )
            elseif _forced_jump or FasterTravel.settings.jumpHereBehaviour == FasterTravel.Options.JumpHereBehaviour.ALWAYS then
                Utils.chat(1, "Attempting jump to random zone, %s", _forced_jump and "as required" or "as per Settings")
                _teleportIter = GetTeleportIterator(nil, _parent)
                TryNextPlayer()
			else
				Utils.chat(1, "No players found in zone, abandoning jump as per Settings")
            end
        else
            Utils.chat(2, "Don't you have any friends in this game?!")
        end
    end

    local _waiting = false

    local function DelayedNext()
        _waiting = false
        if _result then
            if _result.success then
                Utils.chat(1, "Teleporting to zone %s", 
                    Utils.bold(_result.player.zoneName))
                Reset()
            elseif TargetZoneInaccessible(_result.reason) and
                _result.zoneName then
                Utils.chat(3, "Stop checking further.")
                NoPlayersFound(_result.zoneName)
            else
                TryNextPlayer(_result.zoneName)
            end        
        end
    end
    
    local function DelayCheck(delay)
        Utils.chat(3, "DelayCheck waiting %s", _waiting)
        if not _waiting then 
            _waiting = true
            zo_callLater(DelayedNext, delay)
        end
    end

    TryNextPlayer = function(zoneName)
        Utils.chat(3, "in TryNextPlayer(%s)", zoneName or "nil")
        if _teleportIter then
            local player = _teleportIter()
            if player then
                _result = { reason = "attempt", 
                            player = player,
                            zoneName = zoneName,
                            success = true,
                            expiry = GetGameTimeMilliseconds() + _expiryTime }
				
                Utils.chat(3, "Try player %s character %s zone %s",
                    Utils.bold(player.tag),
                    Utils.bold(zo_strformat("<<1>>", player.name)),
                    Utils.bold(player.zoneName))
                local success, playerName = TeleportToPlayerByLogin(player.tag)
                if success then
                    Utils.chat(3, "Alleged success, reason=%s", _result.reason)
                    DelayCheck(_delayTime)
                    return
                end
            else
                Utils.chat(3, "player is nil - iterator exhausted")        
            end
        else
            Utils.chat(3, "_teleportIter is nil")
        end
        NoPlayersFound(zoneName)
    end

    local function AlertHookFunction(base, alert, sound, message, ...)
        Utils.chat(3, "in hook: %s %s", alert, message)
        local t = GetGameTimeMilliseconds()
        if _result then
            if alert == 0 and t <= _result.expiry then
                _result.success = false
                _result.reason = message
                Utils.chat(3, "Alert message '%s'", message)
                if not TargetZoneInaccessible(message) then
                    -- maybe it is possible to teleport to another player in this zone?
                    DelayCheck(_delayTime)
                end
            end
        end
        base(alert, sound, message, ...)
    end

    ZO_Alert = FasterTravel.hook(ZO_Alert, AlertHookFunction)
    
    FasterTravel.addEvent(EVENT_PLAYER_ACTIVATED, function(eventCode)
        Reset()
    end)

    self.TeleportToZone = function(self, zoneName, parent, forced_jump)
		local destination = ExpandZoneName(zoneName)
		Utils.chat(3, "TeleportToZone: expanded zoneName = %s", destination)
		Utils.chat(3, "TeleportToZone: forced_jump = %s", tostring(forced_jump))
        if parent then
            _parent = parent
        elseif destination then
            _parent = GetParentZone(destination)
        end
		if forced_jump then
			_forced_jump = forced_jump
			--[[
			Special cases - have a parent despite containing wayshrines: 
			Apocrypha -> Telvanni Peninsula
			Artaeum -> Summerset
			Brass Fortress -> Clockwork City
			Tideholm -> Southern Elsweyr
			For all other zones, change destination to their parent zone,
			which is the same zone for all major zones except the above,
			and containing zone for delves, dungeons etc.,
			therefore is guaranteed to contain a wayshrine
			]]--
			local change_destination = true
			for _, z in ipairs({ 1413, 1146, 981, 1027 }) do
				if destination == string.lower(GetZoneNameById(z)) then
					change_destination = false
					break
				end
			end
			if change_destination then
				destination = parent
			end
		else
			_forced_jump = nil
		end
        if destination then            
            Utils.chat(3, "TeleportToZone: Attempting teleport to zone %s", destination)
        else
            Utils.chat(3, "TeleportToZone: Will try to jump to random destination, %s preferred", _parent or "(nil)")
        end
        _teleportIter = GetTeleportIterator(destination, _parent)
        TryNextPlayer(zoneName)
    end
	
end

local _zoneTeleporter = ZoneTeleporter()

local function TeleportToZone(destination, parent, forced_jump)
	if destination == "zone" then
		-- the zone being displayed on the map or the current zone if no map shown
		destination = GetZoneNameByIndex(GetCurrentMapZoneIndex())
		if destination == '' then 
			destination = GetZoneNameByIndex(GetUnitZoneIndex("player"))
		end
	end
    _zoneTeleporter:TeleportToZone(destination, parent, forced_jump)
end

Teleport.GetGuildPlayers = GetGuildPlayers
Teleport.GetZonesGuildLookup = GetZonesGuildLookup
Teleport.GetFriendsInfo = GetFriendsInfo
Teleport.GetGroupInfo = GetGroupInfo
Teleport.GetParentZone = GetParentZone
Teleport.IsPlayerReallyInGroup = IsPlayerReallyInGroup
Teleport.IsPlayerInGuild = IsPlayerInGuild
Teleport.IsPlayerTeleportable = IsPlayerTeleportable
Teleport.TeleportToPlayerByLogin = TeleportToPlayerByLogin
Teleport.TeleportToPlayer = TeleportToPlayer
Teleport.TeleportToGroup = TeleportToGroup
Teleport.TeleportToZone = TeleportToZone
FasterTravel.Teleport = Teleport
