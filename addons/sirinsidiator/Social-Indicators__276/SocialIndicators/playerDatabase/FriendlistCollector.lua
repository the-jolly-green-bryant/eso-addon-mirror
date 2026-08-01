local RegisterForEvent = SocialIndicators.RegisterForEvent
local LogDebug = SocialIndicators.LogDebug
local GetFriendIndexFromCharacterOrDisplayName = SocialIndicators.GetFriendIndexFromCharacterOrDisplayName

local FriendlistCollector = ZO_Object:Subclass()
SocialIndicators.FriendlistCollector = FriendlistCollector

function FriendlistCollector:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function FriendlistCollector:Initialize(database)
	self.database = database

	local function FindFriendIndexAndCall(displayName, func)
		local friendIndex = GetFriendIndexFromCharacterOrDisplayName(displayName)
		if(friendIndex) then
			func(self, friendIndex)
		end
	end

	self:DoFullUpdate()
	RegisterForEvent(EVENT_SOCIAL_DATA_LOADED, function() self:DoFullUpdate() end)
	RegisterForEvent(EVENT_FRIEND_ADDED, function(_, displayName) FindFriendIndexAndCall(displayName, self.UpdateAllPlayerData) end)
	--RegisterForEvent(EVENT_FRIEND_REMOVED, function(_, displayName) end) -- nothing to do here
	RegisterForEvent(EVENT_FRIEND_CHARACTER_UPDATED, function(_, displayName) FindFriendIndexAndCall(displayName, self.UpdateAllPlayerData) end)
	RegisterForEvent(EVENT_FRIEND_CHARACTER_ZONE_CHANGED, function(_, displayName, characterName, zone) self:UpdateZone(characterName, zone) end)
	RegisterForEvent(EVENT_FRIEND_CHARACTER_LEVEL_CHANGED, function(_, displayName, characterName, level) self:UpdateLevel(characterName, level) end)
	RegisterForEvent(EVENT_FRIEND_CHARACTER_CHAMPION_POINTS_CHANGED, function(_, displayName, characterName, championPoints) self:UpdateChampionPoints(characterName, championPoints) end)
	RegisterForEvent(EVENT_FRIEND_NOTE_UPDATED, function(_, displayName, note) self:UpdateNote(displayName, note) end)
	RegisterForEvent(EVENT_FRIEND_PLAYER_STATUS_CHANGED, function(_, displayName, characterName, oldStatus, newStatus) FindFriendIndexAndCall(displayName, self.UpdateStatus) end)
end

function FriendlistCollector:DoFullUpdate()
	for i = 1, GetNumFriends() do
		self:UpdateAllPlayerData(i)
	end
end

function FriendlistCollector:UpdateAllPlayerData(friendlistIndex)
	local db = self.database

	local displayName, note, playerStatus, secsSinceLogoff = GetFriendInfo(friendlistIndex)
	local player = db:GetPlayer(displayName)
	player:UpdateFriendNote(note)
	player:UpdateStatus(playerStatus, secsSinceLogoff)
	player:Save()

	local hasCharacter, characterName, zoneName, classType, alliance, level, championPoints = GetFriendCharacterInfo(friendlistIndex)
	if(hasCharacter) then
		local character = db:GetCharacter(characterName)
		character:SetGender(GetGenderFromNameDescriptor(characterName))
		character:SetClass(classType)
		character:SetAlliance(alliance)
		character:UpdateLevel(level)
		character:UpdateZone(zoneName)
		if(not character:GetPlayer()) then
			character:SetPlayer(displayName)
		end
		character:UpdateChampionPoints(championPoints)
		character:UpdateLastSeen()
		character:Save()
	end
end

function FriendlistCollector:UpdateZone(characterName, zoneName)
	local character = self.database:GetCharacter(characterName)
	character:UpdateZone(zoneName)
	character:UpdateLastSeen()
	character:Save()
end

function FriendlistCollector:UpdateLevel(characterName, level)
	local character = self.database:GetCharacter(characterName)
	character:UpdateLevel(level)
	character:UpdateLastSeen()
	character:Save()
end

function FriendlistCollector:UpdateChampionPoints(characterName, championPoints)
	local character = self.database:GetCharacter(characterName)
	character:UpdateChampionPoints(championPoints)
	character:UpdateLastSeen()
	character:Save()
end

function FriendlistCollector:UpdateNote(displayName, note)
	local player = self.database:GetPlayer(displayName)
	player:UpdateFriendNote(note)
end

function FriendlistCollector:UpdateStatus(friendlistIndex)
	local displayName, _, playerStatus, secsSinceLogoff = GetFriendInfo(friendlistIndex)
	local player = self.database:GetPlayer(displayName)
	player:UpdateStatus(playerStatus, secsSinceLogoff)
	player:Save()
end
