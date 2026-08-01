-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2

-------------------------------------
-- Addon data.
-------------------------------------
MusicVolumeInCombat = {}
MusicVolumeInCombat.name = "MusicVolumeInCombat"

MusicVolumeInCombat.variableVersion = 1
MusicVolumeInCombat.Default = {
    volumeInCombat = 30,
    delayToRestore = 10
}


-------------------------------------
-- Initialize the addon.
-------------------------------------
function MusicVolumeInCombat.OnAddOnLoaded(_, addonName)
    if addonName == MusicVolumeInCombat.name then
        MusicVolumeInCombat:Initialize()
        EVENT_MANAGER:UnregisterForEvent(MusicVolumeInCombat.name, EVENT_ADD_ON_LOADED)
    end
end


-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function MusicVolumeInCombat:Initialize()
    MusicVolumeInCombat.savedVariables = ZO_SavedVars:NewAccountWide("MusicVolumeInCombatVars", MusicVolumeInCombat.variableVersion, nil, MusicVolumeInCombat.Default)
    MusicVolumeInCombat.volumeOutOfCombat = GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME)
    MusicVolumeInCombat.CreateSettingsWindow()
    EVENT_MANAGER:RegisterForEvent(MusicVolumeInCombat.name, EVENT_PLAYER_COMBAT_STATE, MusicVolumeInCombat.updateMusicVolumeValue)

    -- Handle the changes on the Audio Setting Slider
    Options_Audio_MusicVolumeSlider:SetHandler('OnSliderReleased',function(_, volume)
        MusicVolumeInCombat.volumeOutOfCombat = volume
        MusicVolumeInCombat.updateMusicVolumeValue()
        if MVIC_out_combat_slider ~= nil then
            MVIC_out_combat_slider:UpdateValue()
        end
        end)

    -- Set the warning that you can't change this setting when in combat
    SafeAddString(SI_AUDIO_OPTIONS_MUSIC_VOLUME_TOOLTIP, GetString(SI_AUDIO_OPTIONS_MUSIC_VOLUME_TOOLTIP) .. "\n|cFF0000Disabled in Combat|r", 1)
end


-------------------------------------------------------------------------------------------------
--  Settings menu creation.
-------------------------------------------------------------------------------------------------
function MusicVolumeInCombat.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Music Volume In Combat",
        displayName = "Music Volume In Combat",
        author = "@Kafeijao (EU)",
        version = MusicVolumeInCombat.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel("Music_Volume_In_Combat", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "Music Volume In Combat Settings"
        },
        [2] = {
            type = "description",
            text = "Here you can adjust the Music Volume In Combat settings."
        },
        [3] = {
            type = "slider",
            name = "Target Music Volume When IN Combat",
            tooltip = "Adjusts the music volume to this value when in combat.",
            getFunc = function() return MusicVolumeInCombat.savedVariables.volumeInCombat end,
            setFunc = function(newValue)
                MusicVolumeInCombat.savedVariables.volumeInCombat = newValue
                MusicVolumeInCombat.updateMusicVolumeValue()
            end,
            min = 0,
            max = 100,
            step = 5,
            width = "full",
            default = MusicVolumeInCombat.Default.volumeInCombat,
        },
        [4] = {
            type = "slider",
            name = "Target Music Volume When OUT of Combat",
            tooltip = "Adjusts the music volume to this value when it's out of combat.",
            getFunc = function() return MusicVolumeInCombat.volumeOutOfCombat end,
            setFunc = function(newValue)
                MusicVolumeInCombat.volumeOutOfCombat = newValue
                MusicVolumeInCombat.updateMusicVolumeValue()
            end,
            min = 0,
            max = 100,
            step = 5,
            width = "full",
            reference ="MVIC_out_combat_slider",
            default = MusicVolumeInCombat.volumeOutOfCombat,
        },
        [5] = {
            type = "slider",
            name = "Wait delay to restore the Volume after Combat (secs)",
            tooltip = "Sets the wait delay to restore the volume after exiting combat in seconds.",
            getFunc = function() return MusicVolumeInCombat.savedVariables.delayToRestore end,
            setFunc = function(newValue)
                MusicVolumeInCombat.savedVariables.delayToRestore = newValue
            end,
            min = 0,
            max = 15,
            step = 1,
            width = "full",
            default = MusicVolumeInCombat.Default.delayToRestore,
        }
    }

    LAM2:RegisterOptionControls("Music_Volume_In_Combat", optionsData)
end

-------------------------------------
-- Callback to restore volume.
-------------------------------------
function MusicVolumeInCombat.restoreMusicVolumeValue()
    if not IsUnitInCombat("player") then
        --d("restored volume")
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, MusicVolumeInCombat.volumeOutOfCombat, nil)
    end
end

-------------------------------------
-- Updates the music volume value.
-------------------------------------
function MusicVolumeInCombat.updateMusicVolumeValue(_, inCombat)
    if inCombat == nil then inCombat = IsUnitInCombat("player") end

    if inCombat then
        SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_MUSIC_VOLUME, MusicVolumeInCombat.savedVariables.volumeInCombat, nil)
    else
        if MusicVolumeInCombat.savedVariables.delayToRestore == 0 then
            --d("Restoring volume right away");
            MusicVolumeInCombat.restoreMusicVolumeValue() -- Restore volume imideatly
        else
            --d("Restoring volume in " .. MusicVolumeInCombat.savedVariables.delayToRestore * 1000);
            zo_callLater(MusicVolumeInCombat.restoreMusicVolumeValue, MusicVolumeInCombat.savedVariables.delayToRestore * 1000) -- Wait x seconds to restore music volume
        end
    end

    Options_Audio_MusicVolumeSlider:SetEnabled(not inCombat) -- Disable changes to the official audio setting slider when in combat
end

-------------------------------------
-- Initialization Register.
------------------------------------
EVENT_MANAGER:RegisterForEvent(MusicVolumeInCombat.name, EVENT_ADD_ON_LOADED, MusicVolumeInCombat.OnAddOnLoaded)