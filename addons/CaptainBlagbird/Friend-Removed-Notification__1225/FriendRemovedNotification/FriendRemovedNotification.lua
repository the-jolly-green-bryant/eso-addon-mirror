--[[

Friend Removed Notification
by CaptainBlagbird

- server separation by AssemblerManiac (2020-5-27)
- bugfix 2020-5-28
https://github.com/CaptainBlagbird

--]]

-- Libraries
local LN = _G["LibNotifications"]

LN_provider = LN:CreateProvider()

-- Addon info
local AddonName = "FriendRemovedNotification"
-- Local variables
local SavedVars = {}

local friendsInWorld = {}

-- Function to set up the friends list in the SavedVars
local function InitSavedVarsFriends()
	local worldName = GetWorldName():gsub(" Megaserver", "")
	if type(SavedVars.friends) == "table" and SavedVars.friends[worldName] == nil then
		SavedVars.friends = nil
	end

	if type(SavedVars.friends) ~= "table" or type(SavedVars.friends[worldName]) ~= "table" then
		SavedVars.friends = {}
		SavedVars.friends[worldName] = {}
	end
	friendsInWorld = SavedVars.friends[worldName]
	for i=1, GetNumFriends() do
		local DisplayName = GetFriendInfo(i)
		if not friendsInWorld[DisplayName] then
			friendsInWorld[DisplayName] = 0
		end
	end
end

-- Event handler function for EVENT_FRIEND_ADDED
local function OnFriendAdded(eventCode, DisplayName)
	friendsInWorld[DisplayName] = GetTimeStamp()
end

-- Event handler function for EVENT_FRIEND_REMOVED
local function OnFriendRemoved(eventCode, DisplayName)
	-- Function to remove custom notification
	local function removeNotification(provider, data)
		t = provider.notifications
		j = data.notificationId
		-- Loop through table starting at index
		for i = j, #t do
			-- Replace current element with next element
			t[i] = t[i+1]
			-- Update index in data
			if i < #t then
				t[i].notificationId = i
			end
		end
		provider:UpdateNotifications()
	end
	-- Callback functions
	local function acceptCallback(data)
		StartChatInput("", CHAT_CHANNEL_WHISPER, DisplayName)
		removeNotification(LN_provider, data)

		-- Remove from SavedVars friends list
		friendsInWorld[DisplayName] = nil
	end
	local function declineCallback(data)
		removeNotification(LN_provider, data)

		-- Remove from SavedVars friends list
		friendsInWorld[DisplayName] = nil
	end
	-- Custom notification info
	local msg = {
		dataType				= NOTIFICATIONS_REQUEST_DATA,
		secsSinceRequest		= ZO_NormalizeSecondsSince(0),
		note					= GetString(SI_FRN_MSG_NOTE),
		message				 	= zo_strformat(GetString(SI_FRN_MSG_MESSAGE), DisplayName).." "..GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER).."?",
		heading				 	= GetString(SI_FRN_MSG_HEADING),
		texture				 	= "EsoUI/Art/Notifications/notificationIcon_friend.dds",
		shortDisplayText		= DisplayName,
		controlsOwnSounds		= false,
		keyboardAcceptCallback  = acceptCallback,
		keybaordDeclineCallback = declineCallback,
		gamepadAcceptCallback   = acceptCallback,
		gamepadDeclineCallback  = declineCallback,
		-- Custom keys
		notificationId		  	= #LN_provider.notifications + 1,
		}
	-- Add custom notification
	table.insert(LN_provider.notifications, msg)
	LN_provider:UpdateNotifications()
end

-- Event handler function for EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
	-- Set up SavedVariables table
	SavedVars = ZO_SavedVars:NewAccountWide(AddonName .. "_SavedVariables", 1)
	InitSavedVarsFriends()

	-- Compare friends list with list in SavedVars
	for DisplayName, _ in pairs(friendsInWorld) do
		if not IsFriend(DisplayName) then
			-- Call event handler function directly
			OnFriendRemoved(EVENT_FRIEND_REMOVED, DisplayName)
		end
	end

	-- Register events that use saved variables
	EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_FRIEND_ADDED, OnFriendAdded)
	EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_FRIEND_REMOVED, OnFriendRemoved)

	EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
