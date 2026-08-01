MuteBards = {}
MuteBards.Name = "Mute Bards"
MuteBards.Version = "1.01"

function MuteBards_CombatState(event_id, inCombat)
	if inCombat then
		MuteBards_EnableEffects()
	end
end

function MuteBards_MuteEffects()
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, 0)
end

function MuteBards_EnableEffects()
	SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, 70)
end

-- Known locations with bards in them (currently EP only).
-- In future, we might want to define exact coords for bards
-- or find some other common attribute the bastards share.

local bardZones = { "Ebonheart", "Nimalten", "Kragenmoor", "Davon's Watch", "Stormhold", "Riften", "Velyn Harbor" }

function MuteBards_AreaChange(eventCode, zoneName, subZoneName, newSubzone)
	for _,v in pairs(bardZones) do
	  if v == subZoneName then
	    zo_callLater(MuteBards_MuteEffects, 3000)
	  else
	  	MuteBards_EnableEffects()
	  end
	end
end

-- Handle cases where you're interacting with an object?

EVENT_MANAGER:RegisterForEvent("MuteBardsCombatState", EVENT_PLAYER_COMBAT_STATE, MuteBards_CombatState )
EVENT_MANAGER:RegisterForEvent("MuteBardsAreaChange", EVENT_ZONE_CHANGED, MuteBards_AreaChange )
