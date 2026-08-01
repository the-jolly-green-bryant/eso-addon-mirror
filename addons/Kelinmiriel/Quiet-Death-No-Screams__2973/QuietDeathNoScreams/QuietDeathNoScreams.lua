-------------------------------------
-- Addon data.
-------------------------------------
QuietDeathNoScreams = {}
QuietDeathNoScreams.name = "QuietDeathNoScreams"

QuietDeathNoScreams.variableVersion = 1
QuietDeathNoScreams.Default = {
    volumeInCombat = 0,
    volumeOutOfCombat = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME)
}


-------------------------------------
-- Initialize the addon.
-------------------------------------
function QuietDeathNoScreams.OnAddOnLoaded(_, addonName)
    if addonName == QuietDeathNoScreams.name then
        QuietDeathNoScreams:Initialize()
        EVENT_MANAGER:UnregisterForEvent(QuietDeathNoScreams.name, EVENT_ADD_ON_LOADED)
    end
end


-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function QuietDeathNoScreams:Initialize()
    QuietDeathNoScreams.vars = ZO_SavedVars:NewAccountWide("QuietDeathNoScreamsVars", QuietDeathNoScreams.variableVersion, GetWorldName(), QuietDeathNoScreams.Default)
    EVENT_MANAGER:RegisterForEvent(QuietDeathNoScreams.name, EVENT_PLAYER_COMBAT_STATE, QuietDeathNoScreams.updateSFXVolumeValue)
end


-------------------------------------
-- Callback to restore volume.
-------------------------------------
function QuietDeathNoScreams.restoreSFXVolumeValue()
    if not IsUnitInCombat("player") then
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, QuietDeathNoScreams.vars.volumeOutOfCombat, nil)
    end
end

-------------------------------------
-- Updates the SFX volume value.
-------------------------------------
function QuietDeathNoScreams.updateSFXVolumeValue(_, inCombat)
    if inCombat == nil then inCombat = IsUnitInCombat("player") end

    if inCombat then
        QuietDeathNoScreams.vars.volumeOutOfCombat = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME)
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_SFX_VOLUME, QuietDeathNoScreams.vars.volumeInCombat, nil)
    else
        zo_callLater(QuietDeathNoScreams.restoreSFXVolumeValue, 5000) -- Wait 5 seconds to restore sfx volume
    end

    Options_Audio_SFXVolumeSlider:SetEnabled(not inCombat) -- Disable changes to the official audio setting slider when in combat
end

-------------------------------------
-- Initialization Register.
------------------------------------
EVENT_MANAGER:RegisterForEvent(QuietDeathNoScreams.name, EVENT_ADD_ON_LOADED, QuietDeathNoScreams.OnAddOnLoaded)