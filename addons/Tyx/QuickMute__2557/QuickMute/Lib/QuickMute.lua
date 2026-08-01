--[[----------------------------------------------
    Project:    QuickMute
    Author:     Arne Rantzen (Tyx)
    Created:    2020-03-08
    Updated:    020-03-08
    License:    GPL-3.0
----------------------------------------------]]--
local d = function() end
local p = function(...) CHAT_SYSTEM:AddMessage(...) end
if LibDebugLogger then
    local l = LibDebugLogger("QuickMute")
    d = function(...) l:Debug(...) end
    p = function(...) l:Info(...) end
end
-- -----------------------------------------
-- Bindings
-- -----------------------------------------
local values = {}

--- Function to set a setting to a value
--- @param setting number of global setting
--- @param name string of value
--- @return string new value
local function SetAudio(setting, name)
    local value
    if values[name] then
        value = values[name]
        values[name] = nil
    else
        values[name] = GetSetting(SETTING_TYPE_AUDIO, setting)
        value = values[name]
        if value == '1' then
            value = '0'
        else
            value = '1'
        end
    end
    SetSetting(SETTING_TYPE_AUDIO, setting, value, DO_NOT_SAVE_TO_PERSISTED_DATA)
    d(zo_strformat(QuickMute.i18n.change, QuickMute.i18n[name], value))
    return value
end

--- Function to toggle the in-game sound
--- @return string new value
function QUICK_MUTE_TOGGLE_SOUND()
    return SetAudio(AUDIO_SETTING_SOUND_ENABLED, "sound")
end

--- Function to toggle the in-game music
--- @return string new value
function QUICK_MUTE_TOGGLE_MUSIC()
    return SetAudio(AUDIO_SETTING_MUSIC_ENABLED, "music")
end

--- Function to toggle the in-game audio
--- @return string new value
function QUICK_MUTE_TOGGLE_AUDIO()
    return SetAudio(AUDIO_SETTING_AUDIO_ENABLED, "audio")
end

--- Register the slash command /mute
SLASH_COMMANDS["/mute"] = function(...)
    local command = string.lower(select(1, ...))
    local str = "enabled"
    local value
    -- Patterns are not perfect. They should work because music is tested before sound though.
    if command == "" or string.find(command, "[aA]%S*") then
        value = QUICK_MUTE_TOGGLE_AUDIO()
        command = "audio"
    elseif string.find(command, "[mM]%S*") then
        value = QUICK_MUTE_TOGGLE_MUSIC()
        command = "music"
    elseif string.find(command, "[sS]%S*") then
        value = QUICK_MUTE_TOGGLE_SOUND()
        command = "sound"
    else
        p(QuickMute.i18n.error)
        return
    end
    if value == '0' then
        str = 'disabled'
    end
    p(zo_strformat(QuickMute.i18n.output, QuickMute.i18n[command], str))
end
