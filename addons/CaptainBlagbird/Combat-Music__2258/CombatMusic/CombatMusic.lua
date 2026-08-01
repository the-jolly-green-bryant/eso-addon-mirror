--[[

Combat Music
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddonName = "CombatMusic"


local function OnCombatStateChange(eventCode, inCombat)
    -- Don't change music when player is still mounted
    if IsMounted() then return end
    
    local newSetting = inCombat and "1" or "0"
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, newSetting)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChange)


local function OnMountedStateChanged(eventCode, isMounted)
    -- Don't change music when player is not in combat
    if not IsUnitInCombat("player") then return end
    
    if isMounted then
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, "0")
    else
        -- Wait some time before applying the setting --> Compatibility with Travel Music add-on
        zo_callLater(function() SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, "1") end, 100)
    end
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)