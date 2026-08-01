local RegisterForEvent = SocialIndicators.RegisterForEvent

local initialized = false
local friendIndex = {}
local friendIndexDirty = true

local function SetFriendIndexDirty()
	friendIndexDirty = true
end

local function RebuildFriendIndex()
	friendIndex = {}
	for index = 1, GetNumFriends() do
		local displayName = GetFriendInfo(index)
		friendIndex[displayName] = index

		local hasCharacter, characterName = GetFriendCharacterInfo(index)
		if(hasCharacter) then
			friendIndex[characterName:gsub("%^.*x$","")] = index
		end
	end
	friendIndexDirty = false
end

local function GetFriendIndexFromCharacterOrDisplayName(name)
	if(not name or name == "") then return nil end
	if(friendIndexDirty) then RebuildFriendIndex() end
	return friendIndex[name:gsub("%^.*x$","")]
end

local function InitFriendIndex()
	if(initialized) then return end
	local eventList = {
		EVENT_SOCIAL_DATA_LOADED,
		EVENT_FRIEND_ADDED,
		EVENT_FRIEND_REMOVED,
		EVENT_FRIEND_CHARACTER_UPDATED,
	}
	for _, event in ipairs(eventList) do RegisterForEvent(event, SetFriendIndexDirty) end
	initialized = true
end

SocialIndicators.SetFriendIndexDirty = SetFriendIndexDirty
SocialIndicators.GetFriendIndexFromCharacterOrDisplayName = GetFriendIndexFromCharacterOrDisplayName
SocialIndicators.InitFriendIndex = InitFriendIndex
