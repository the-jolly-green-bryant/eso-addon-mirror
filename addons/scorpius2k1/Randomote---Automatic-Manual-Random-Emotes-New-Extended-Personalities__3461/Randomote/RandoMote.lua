--[[ Sharlikran	Dolgubon sirinsidiator IsJustaGhostm Azure_Fang	** Thank you for your help & suggestions ** ]]--

EVENT_MANAGER:RegisterForEvent(
	RANDOMOTE.name.."_OnAddonLoaded", EVENT_ADD_ON_LOADED,
	function(_, addOnName)
		RANDOMOTE.Initialize()
		EVENT_MANAGER:UnregisterForEvent(RANDOMOTE.name.."_OnAddonLoaded", EVENT_ADD_ON_LOADED)
	end
)

EVENT_MANAGER:RegisterForEvent(
	RANDOMOTE.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED,
	function ()
		RANDOMOTE.Loop()
		EVENT_MANAGER:UnregisterForEvent(RANDOMOTE.name.."_OnPlayerActivated", EVENT_PLAYER_ACTIVATED)
	end
)
EVENT_MANAGER:RegisterForEvent(RANDOMOTE.name, EVENT_ZONE_CHANGED, function(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId) RANDOMOTE.ResetData() end)
EVENT_MANAGER:RegisterForEvent(RANDOMOTE.name, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode, nodeIndex) RANDOMOTE.ResetData() end)
SLASH_COMMANDS[RANDOMOTE.slashCommand.emote] = function () RANDOMOTE.ResetData() RANDOMOTE.playRandomEmote() end
--SLASH_COMMANDS[RANDOMOTE.slashCommand.list] = function () RANDOMOTE.DisplayEmoteInfo() end