LPEmoteHandler = {}

EVENT_ACTIVE_EMOTE = "EVENT_ACTIVE_EMOTE"
EVENT_ON_SMART_EMOTE = "EVENT_ON_SMART_EMOTE"
EVENT_ON_IDLE_EMOTE = "EVENT_ON_IDLE_EMOTE"

local performedSmartEmote
local performedIdleEmote
local didMove


local function CheckPlayerMovementWhileEmoting(x, y)
	_, _, didMove = LPUtilities.DidPlayerMove(x, y)
	if didMove then
		EVENT_MANAGER:UnregisterForUpdate("PlayerMovement")
		LPEventHandler:FireEvent(EVENT_ACTIVE_EMOTE, false, false)
	end
	return didMove
end


local function ResolveLoopingEmote()
	local x, y = GetMapPlayerPosition(LorePlay.player)
	EVENT_MANAGER:RegisterForUpdate("PlayerMovement", 1500, function() 
		CheckPlayerMovementWhileEmoting(x, y)
		end)
end


local function ResolveEmote()
	local x, y = GetMapPlayerPosition(LorePlay.player)
	EVENT_MANAGER:RegisterForUpdate("EmoteTimeReached", 5000, function()
		LPEventHandler:FireEvent(EVENT_ACTIVE_EMOTE, 250, false)
		EVENT_MANAGER:UnregisterForUpdate("EmoteTimeReached")
		EVENT_MANAGER:UnregisterForUpdate("PlayerMovement")
		end)
	EVENT_MANAGER:RegisterForUpdate("PlayerMovement", 1500, function() 
			if CheckPlayerMovementWhileEmoting(x, y) then
				EVENT_MANAGER:UnregisterForUpdate("EmoteTimeReached")
			end
		end)
end


local function UpdateIsEmoting(index)
	local slashName = GetEmoteSlashNameByIndex(index)
	if LPEmotesTable.allEmotesTable[slashName]["doesLoop"] then
		ResolveLoopingEmote()
	else
		ResolveEmote()
	end
end


local function OnIdleEmote(eventCode)
	if eventCode ~= EVENT_ON_IDLE_EMOTE then return end
	performedIdleEmote = true
	zo_callLater(function() performedIdleEmote = false end, 500)
end


local function OnSmartEmote(eventCode, index)
	if eventCode ~= EVENT_ON_SMART_EMOTE then return end
	performedSmartEmote = true
	zo_callLater(function() performedSmartEmote = false end, 500)
end


--returns false to confirm this didn't handle the original ESO action,
--thus firing ESO's PlayEmoteByIndex
local function OnPlayEmoteByIndex(index)
	if performedSmartEmote or not performedIdleEmote then
		EVENT_MANAGER:UnregisterForUpdate("PlayerMovement")
		EVENT_MANAGER:UnregisterForUpdate("EmoteTimeReached")
		UpdateIsEmoting(index)
		LPEventHandler:FireEvent(EVENT_ACTIVE_EMOTE, 10, true)
	end
	return false
end


function LPEmoteHandler.InitializeEmoteHandler()
	ZO_PreHook("PlayEmoteByIndex", OnPlayEmoteByIndex)
	LPEventHandler:RegisterForLocalEvent(EVENT_ON_SMART_EMOTE, OnSmartEmote)
	LPEventHandler:RegisterForLocalEvent(EVENT_ON_IDLE_EMOTE, OnIdleEmote)
end