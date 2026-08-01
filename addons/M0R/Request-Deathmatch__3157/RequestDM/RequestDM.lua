RequestDM = {}
local RDM = RequestDM
-- Written by M0R_Gaming

RDM.name = "RequestDM"

local teamNames = {
	[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] = 'Fire Drakes',
	[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] = 'Pit Daemons',
	[BATTLEGROUND_ALLIANCE_STORM_LORDS] = 'Storm Lords'
}

--local message = "Good luck!"
local message = "Hello, would you be interested in treating this Battleground as a Group Deathmatch? Due to ZOS removing specific queues, a large portion of the premade BG community treats every gamemode as a deathmatch and avoids completing the objective. We would love to have your team participate with us."
RDM.backlog = {}

function RDM.requestDM()
	if GetCurrentBattlegroundState() == BATTLEGROUND_STATE_NONE then
		d("You are not currently in a battleground!")
		return
	end
	local amt = GetNumScoreboardEntries()
	local alliances = {}
	for i=1,amt do
		local char, acc, alliance, user = GetScoreboardEntryInfo(i)
		if alliances[alliance] == nil then
			alliances[alliance] = acc
		end
	end
	local backlog = RDM.backlog

	if alliances[BATTLEGROUND_ALLIANCE_FIRE_DRAKES] ~= nil then
		backlog[#backlog+1] = {alliances[BATTLEGROUND_ALLIANCE_FIRE_DRAKES],message}
	end
	if alliances[BATTLEGROUND_ALLIANCE_PIT_DAEMONS] ~= nil then
		backlog[#backlog+1] = {alliances[BATTLEGROUND_ALLIANCE_PIT_DAEMONS],message}
	end
	if alliances[BATTLEGROUND_ALLIANCE_STORM_LORDS] ~= nil then
		backlog[#backlog+1] = {alliances[BATTLEGROUND_ALLIANCE_STORM_LORDS],message}
	end
	if #backlog > 0 then
		d("Sending messages, press Enter "..#backlog.." times!")
		local sendctx = table.remove(backlog, 1)
		RDM.sendMessage(sendctx[1], sendctx[2]) 
		EVENT_MANAGER:RegisterForEvent("Request Deathmatch Message Callback", EVENT_CHAT_MESSAGE_CHANNEL, RDM.handleMessageSent)
	end
end



function RDM.handleMessageSent(eventCode,channelType,fromName,text,isCustomerService,fromDisplayName)
	local backlog = RDM.backlog
	if channelType == CHAT_CHANNEL_WHISPER_SENT then
		local sendctx = table.remove(backlog, 1)
		RDM.sendMessage(sendctx[1], sendctx[2])
	end

	if #backlog == 0 then
		EVENT_MANAGER:UnregisterForEvent("Request Deathmatch Message Callback", EVENT_CHAT_MESSAGE_CHANNEL)
	end
end


function RDM.sendMessage(player, message) 
	local channel = CHAT_CHANNEL_WHISPER
	CHAT_SYSTEM:StartTextEntry(message, channel, player)
end



function RDM.gg()
	if GetCurrentBattlegroundState() == BATTLEGROUND_STATE_NONE then
		d("You are not currently in a battleground!")
		return
	end
	local amt = GetNumScoreboardEntries()
	local backlog = RDM.backlog
	for i=1,amt do
		local char, acc, alliance, user = GetScoreboardEntryInfo(i)
		backlog[#backlog+1] = {acc, "GG!"}
	end
	if #backlog > 0 then
		d("Sending messages, press Enter "..#backlog.." times! (Though wait for a bit between each message, as you may be kicked for spam)")
		local sendctx = table.remove(backlog, 1)
		RDM.sendMessage(sendctx[1], sendctx[2])
		EVENT_MANAGER:RegisterForEvent("Request Deathmatch Message Callback", EVENT_CHAT_MESSAGE_CHANNEL, RDM.handleMessageSent)
	end
end

-- Setting up Keybinds and Commands --

SLASH_COMMANDS["/requestdm"] = RDM.requestDM
SLASH_COMMANDS["/gg"] = RDM.gg
--[[ -- Init code (none that needs to be done for now)


-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function RDM.OnAddOnLoaded(event, addonName)
	if addonName ~= RDM.name then return end

	--RDM:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function RDM:Initialize()
	EVENT_MANAGER:UnregisterForEvent(RDM.name, EVENT_ADD_ON_LOADED)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(RDM.name, EVENT_ADD_ON_LOADED, RDM.OnAddOnLoaded)
]]