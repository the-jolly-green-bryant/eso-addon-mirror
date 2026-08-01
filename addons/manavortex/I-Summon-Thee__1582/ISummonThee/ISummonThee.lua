ISummonThee = {}
IST = ISummonThee

local chatMessage 		= ""
local fromName 			= nil
local fromDisplayName 	= nil

local defaults = {
	active = true, 
	delay = 3000, 
	maxTries = 3,
	trigger = "I serve",
}

ISummonThee.active		= true
ISummonThee.tempLocked	= false

local function hasCooldown()
	return ((not ISummonThee.GetActive()) or ISummonThee.tempLocked)
end

local function toggleActive()
	ISummonThee.SetActive(not ISummonThee.GetActive())	
end

local function escapeString(text)
	if nil == text then return "" end
	-- escape brackets
	text = text:gsub('%(', ''):gsub('%)', '')
	-- escape dots
	text = text:gsub('%.', '%%.')
	-- escape %
	text = text:gsub("%%", "%%%%")
	-- escape []
	text = text:gsub('%[', ''):gsub('%]', '')
	return string.lower(text)
 end

 local function tryPassGroupLead()
	if fromDisplayName == zo_strformat(GetUnitDisplayName('player')) then return end
	if not IsUnitGroupLeader('player') then return end
	local groupsize = GetGroupSize() 
	local playerTag = nil
	for i = 1, groupsize do
		playerTag = zo_strformat(GetUnitDisplayName("group"..i))
	
		if string.match(playerTag, fromDisplayName) then
			GroupPromote("group"..i)
		end
	end
 end
 
 local function travelToGroupMember()	
	return JumpToGroupMember(fromDisplayName)
 end
 
 
 local maxTries = 0
 local success = false
 local function tryHeedSummoning()
	if success then return end
	if fromDisplayName == zo_strformat(GetUnitDisplayName('player')) then return end
	if maxTries < 0 then 
		maxTries = IST.GetMaxTries()
		return 
	end
	local first, last = string.match( chatMessage, "(.-)%s(%S+)$" )
	last = zo_strformat(last)	
	
	if (nil ~= string.match(last, "thee"))
	or (nil ~= string.match(zo_strformat(GetUnitName('player')), chatMessage))
	or (nil ~= string.match(zo_strformat(GetUnitDisplayName('player')), last))
	then
		success = travelToGroupMember()
		if success then 
			
			ISummonThee.tempLocked = true
			zo_callLater(function() 
				ISummonThee.HideText()
				ISummonThee.tempLocked = false 
			end, 10000)
			return 
		else
			
			IST.ShowText(fromDisplayName .. " has tried to summon you. Please hold still... ")
			maxTries = maxTries - 1
			-- d("about to call tryHeedSummoning, tries remaining: " .. tostring(maxTries))
			return zo_callLater(function() tryHeedSummoning() end, IST.GetDelay() * 1000 + 500)	
		end		
		
	end

end
 
 local function getGroupLeaderName()
 
 end
 
 local function tryInvite(name)
	if fromDisplayName == zo_strformat(GetUnitDisplayName('player')) then return end
	if IsUnitGrouped('player') and (not IsUnitGroupLeader('player')) then return end
		
	if nil == name then
		
		name = zo_strformat(last)
	end
	GroupInviteByName(name)
 end


local function onChatMessage(eventCode, channelType, messageFromName, text, isCustomerService, messageFromDisplayName)
	if hasCooldown() then return end
	if not ((channelType == CHAT_CHANNEL_PARTY) or (channelType == CHAT_CHANNEL_WHISPER)) then return end
	local first, last = string.match( chatMessage, "(.-)%s(%S+)$" )
	last 			= zo_strformat(last)
	first 			= zo_strformat(first)
	maxTries 		= IST.GetMaxTries()
	chatMessage 	= string.lower(zo_strformat(text))
	fromDisplayName = zo_strformat(messageFromDisplayName)
	fromName 		= zo_strformat(messageFromName)
	if string.match(chatMessage, "i summon thee") then
		tryHeedSummoning()
	elseif (string.match(chatMessage, "thy master")) then
		tryPassGroupLead()
	elseif string.match(chatMessage, IST.GetTrigger()) then
		if (channelType == CHAT_CHANNEL_WHISPER) then 
			tryInvite(messageFromDisplayName)
		else
			tryInvite()
		end		
	end	
end

local function onLoad()
	ISummonThee.HideText()
end

function ISummonThee_Initialized(eventCode, addonName)

	if addonName ~= "ISummonThee" then return end
	SLASH_COMMANDS['/togglesummon'] = function() toggleActive() end
	EVENT_MANAGER:RegisterForEvent("ISummonThee_Initialized", EVENT_CHAT_MESSAGE_CHANNEL, 	onChatMessage)
	EVENT_MANAGER:RegisterForEvent("ISummonThee_Initialized", EVENT_PLAYER_INITIALISED, 	onLoad)
	
	IST.settings = ZO_SavedVars:NewAccountWide("ISummonThee_Settings", 0.2, nil, defaults)
	IST.CreateMenu(ISummonThee.settings, defaults)
	
end

EVENT_MANAGER:RegisterForEvent("ISummonThee_Initialized", EVENT_ADD_ON_LOADED, ISummonThee_Initialized)