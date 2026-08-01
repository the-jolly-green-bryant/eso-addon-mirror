local MuteyPacrooti = {}
MuteyPacrooti.name = "MuteyPacrooti"
MuteyPacrooti.callback = nil

-- restore the volume to its original level
local function EnableDialogAudio()
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, MuteyPacrooti.savedVars.volume)
end

-- disable the audio
local function DisableDialogAudio()

    local volume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)
    -- audio already disabled, don't update saved vars
    if tonumber(volume) == 0 then return end

    MuteyPacrooti.savedVars.volume = volume
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME, 0)
end

local function ClearDelayedAudioMute()
    if MuteyPacrooti.callback == nil then return end

    zo_removeCallLater(MuteyPacrooti.callback)
end

local function sceneStateChange(oldState, newState)
    if (newState == SCENE_SHOWN) then
        DisableDialogAudio()
        ClearDelayedAudioMute()
    elseif (newState == SCENE_HIDDEN) then
        ClearDelayedAudioMute()
        MuteyPacrooti.callback = zo_callLater(EnableDialogAudio, 3000)
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= MuteyPacrooti.name then return end

    MuteyPacrooti.savedVars = ZO_SavedVars:NewAccountWide("MuteyPacrootiSavedVars", 1, GetWorldName(), { volume = 100.0 })
    MuteyPacrooti.savedVars.volume = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_VO_VOLUME)

    EVENT_MANAGER:UnregisterForEvent(MuteyPacrooti.name, EVENT_ADD_ON_LOADED)

    local scenesToCheck = { "crownCrateKeyboard", "crownCrateGamepad" }
    for _, sceneName in ipairs(scenesToCheck) do
    local scene = SCENE_MANAGER:GetScene(sceneName )
        if scene  then
            scene:RegisterCallback("StateChange", sceneStateChange)
        end
    end
end

EVENT_MANAGER:RegisterForEvent(MuteyPacrooti.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)