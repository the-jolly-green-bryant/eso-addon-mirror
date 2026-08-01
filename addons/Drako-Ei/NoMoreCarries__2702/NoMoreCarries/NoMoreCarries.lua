-- NAMESPACE
NoMoreCarries = {}

-- PROPERTIES
NoMoreCarries.name = 'NoMoreCarries'
NoMoreCarries.offMsg = '|cFFFFFF[NoMoreCarries]|cFF6666 Disabled... type |cFFFF66/togglecarries|cFF6666 to enable'
NoMoreCarries.onMsg = '|cFFFFFF[NoMoreCarries]|c66FF66 Enabled... type |cFFFF66/togglecarries|c66FF66 to disable'
NoMoreCarries.active = true
NoMoreCarries.threshold = 3

-- UTILS

local function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- EVEVNTS
function NoMoreCarries.OnAddOnLoaded(event, addonName)
	if addonName == NoMoreCarries.name then
		NoMoreCarries:Initialize()
	end
end

function NoMoreCarries.OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent(NoMoreCarries.name, EVENT_PLAYER_ACTIVATED)
	NoMoreCarries.active = true
	d(NoMoreCarries.onMsg)
end


function NoMoreCarries.OnChat(self, eventKey, ...)
	if eventKey == EVENT_CHAT_MESSAGE_CHANNEL then
			local messageType, _, rawMessageText, _, fromDisplayName = select(1, ...)
			if NoMoreCarries.active then
				local messageLower = string.lower(rawMessageText)
				local _, achievementScore = string.gsub(messageLower, 'h1:achievement:', '')
				local _, collectibleScore = string.gsub(messageLower, 'h1:collectible:', '')
				local carryScore = achievementScore + collectibleScore
				return carryScore >= NoMoreCarries.threshold;
			end
		end
	return false
end


function NoMoreCarries:Initialize()
	-- INITIALIZE ADDON
	ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", NoMoreCarries.OnChat)
end

-- COMMANDS

SLASH_COMMANDS["/togglecarries"] = function(args)
	if NoMoreCarries.active then
		NoMoreCarries.active = false
		d(NoMoreCarries.offMsg)
	else
		NoMoreCarries.active = true
		d(NoMoreCarries.onMsg)
	end
	
end


-- CALL ENTRY POINT
EVENT_MANAGER:RegisterForEvent(NoMoreCarries.name, EVENT_ADD_ON_LOADED, NoMoreCarries.OnAddOnLoaded)	
EVENT_MANAGER:RegisterForEvent(NoMoreCarries.name, EVENT_PLAYER_ACTIVATED, NoMoreCarries.OnPlayerActivated)