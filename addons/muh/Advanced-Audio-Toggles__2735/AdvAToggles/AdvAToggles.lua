if AdvAToggles == nil then AdvAToggles = { } end
local AdvAToggles = _G['AdvAToggles']
--local L = AdvAToggle:GetLocale()
local L = {
    slash_options   = "Advanced Audio Toggles - Options:",
    master          = GetString(SI_AUDIO_OPTIONS_MASTER_VOLUME)    ~= "" and GetString(SI_AUDIO_OPTIONS_MASTER_VOLUME)    or "Master Volume",
    music           = GetString(SI_AUDIO_OPTIONS_MUSIC_VOLUME)     ~= "" and GetString(SI_AUDIO_OPTIONS_MUSIC_VOLUME)     or "Music Volume",
    sound           = GetString(SI_AUDIO_OPTIONS_SOUND_VOLUME)     ~= "" and GetString(SI_AUDIO_OPTIONS_SOUND_VOLUME)     or "Sound Volume",
    ambient         = GetString(SI_AUDIO_OPTIONS_AMBIENT_VOLUME)   ~= "" and GetString(SI_AUDIO_OPTIONS_AMBIENT_VOLUME)   or "Ambient Volume",
    effects         = GetString(SI_AUDIO_OPTIONS_SFX_VOLUME)       ~= "" and GetString(SI_AUDIO_OPTIONS_SFX_VOLUME)       or "Effects Volume",
    footsteps       = GetString(SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME) ~= "" and GetString(SI_AUDIO_OPTIONS_FOOTSTEPS_VOLUME) or "Footsteps Volume",
    dialogue        = GetString(SI_AUDIO_OPTIONS_VO_VOLUME)        ~= "" and GetString(SI_AUDIO_OPTIONS_VO_VOLUME)        or "Dialogue Volume",
    interface       = GetString(SI_AUDIO_OPTIONS_UI_VOLUME)        ~= "" and GetString(SI_AUDIO_OPTIONS_UI_VOLUME)        or "Interface Volume",
}

local kb = { }
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_MASTER    = "Toggle Master Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_MUSIC     = "Toggle Music Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_SOUND     = "Toggle Sound Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_AMBIENT   = "Toggle Ambient Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_EFFECTS   = "Toggle Effects Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_FOOTSTEPS = "Toggle Footsteps Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_DIALOGUE  = "Toggle Dialogue Volume"
kb.SI_BINDING_NAME_ADVATOGGLES_TOGGLE_INTERFACE = "Toggle Interface Volume"

for i, v in pairs(kb) do
    ZO_CreateStringId(i, v)
end


AdvAToggles.name         = "AdvAToggles"
AdvAToggles.title        = "Advanced Audio Toggles"
AdvAToggles.slash        = "/advat"
AdvAToggles.author       = "muh"
AdvAToggles.version      = "1.0"
AdvAToggles.var_version  = 1

AdvAToggles.audio_settings = {
    master    = AUDIO_SETTING_MASTER_VOLUME,
    music     = AUDIO_SETTING_MUSIC_ENABLED,
    sound     = AUDIO_SETTING_SOUND_ENABLED,
    ambient   = AUDIO_SETTING_AMBIENT_ENABLED,
    effects   = AUDIO_SETTING_SFX_ENABLED,
    footsteps = AUDIO_SETTING_FOOTSTEPS_ENABLED,
    dialogue  = AUDIO_SETTING_VO_ENABLED,
    interface = AUDIO_SETTING_UI_ENABLED,
}

AdvAToggles.defaults = {
    account_wide = true,

    master    = 1,
    music     = 1,
    sound     = 1,
    ambient   = 1,
    effects   = 1,
    footsteps = 1,
    dialogue  = 1,
    interface = 1,
}

local function slash_help()
    CHAT_SYSTEM:AddMessage(L.slash_options)
    CHAT_SYSTEM:AddMessage(string.format("   %-13s - %s", "master"   , L.master))
    CHAT_SYSTEM:AddMessage(string.format("   %-13s - %s", "music"    , L.music))
    CHAT_SYSTEM:AddMessage(string.format("   %-13s - %s", "sound"    , L.sound))
    CHAT_SYSTEM:AddMessage(string.format("   %-12s - %s", "ambient"  , L.ambient))
    CHAT_SYSTEM:AddMessage(string.format("   %-15s - %s", "effects"  , L.effects))
    CHAT_SYSTEM:AddMessage(string.format("   %-13s - %s", "footsteps", L.footsteps))
    CHAT_SYSTEM:AddMessage(string.format("   %-12s - %s", "dialogue" , L.dialogue))
    CHAT_SYSTEM:AddMessage(string.format("   %-13s - %s", "interface", L.interface))
end

local function toggle_setting(db, setting)
    local toggle = GetSetting(SETTING_TYPE_AUDIO, setting)
    toggle = toggle == "1" and 0 or 1
    SetSetting(SETTING_TYPE_AUDIO, setting, toggle)
    AdvAToggles.settings[db] = toggle
end

function AdvAToggles_keybind_set(arg)
    AdvAToggles.set(arg)
end

function AdvAToggles.set(arg)
    arg = zo_strlower(arg)

    --[[ pepega fix for "master" not showing up in the table using pairs() ]]
    if arg == "master" then
        toggle_setting(arg, AdvAToggles.audio_settings.master)
        return
    end

    for k,v in pairs(AdvAToggles.audio_settings) do
        if k == arg then
            toggle_setting(k, v)
            return
        end
    end

    slash_help()
end

function AdvAToggles:initialize()
    SLASH_COMMANDS[AdvAToggles.slash] = AdvAToggles.set

    SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.master, AdvAToggles.settings.master)
    for k,v in pairs(AdvAToggles.audio_settings) do
        SetSetting(SETTING_TYPE_AUDIO, v, AdvAToggles.settings[k])
    end

    AdvAToggles.Menu:initialize()
end

local function on_addon_loaded(event, name)
    if name ~= AdvAToggles.name then return end
    EVENT_MANAGER:UnregisterForEvent(AdvAToggles.name, EVENT_ADD_ON_LOADED)

    local var_file = "AdvATogglesDB"
    AdvAToggles.settings = ZO_SavedVars:NewAccountWide(var_file, AdvAToggles.var_version, nil, AdvAToggles.defaults)
    if not AdvAToggles.settings.account_wide then AdvAToggles.settings = ZO_SavedVars:NewCharacterIdSettings(var_file, AdvAToggles.var_version, nil, AdvAToggles.defaults) end

    AdvAToggles:initialize()
end

EVENT_MANAGER:RegisterForEvent(AdvAToggles.name, EVENT_ADD_ON_LOADED, on_addon_loaded)