--[[

Loading Music
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddonName = "LoadingMusic"


local function OnPlayerActivatedOrDeactivated(eventCode)
    local newSetting
    if eventCode == EVENT_PLAYER_ACTIVATED then
        newSetting = "0"
    elseif eventCode == EVENT_PLAYER_DEACTIVATED then
        newSetting = "1"
    else
        return
    end
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_ENABLED, newSetting)
    
    -- EVENT_MANAGER:UnregisterForEvent(AddonName, eventCode)
end
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, OnPlayerActivatedOrDeactivated)
EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_DEACTIVATED, OnPlayerActivatedOrDeactivated)