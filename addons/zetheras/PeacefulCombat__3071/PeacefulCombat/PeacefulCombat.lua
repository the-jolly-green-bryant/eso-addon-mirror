local function CombatMusic(eventCode, CombatStatus)
    local InCombat = CombatStatus and "0" or "1"
    local MusicDelay = InCombat == "0" and "0" or "6000"
    zo_callLater(function() 
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, InCombat)
    end,MusicDelay)
end

EVENT_MANAGER:RegisterForEvent("PeacefulCombat", EVENT_PLAYER_COMBAT_STATE, CombatMusic)
