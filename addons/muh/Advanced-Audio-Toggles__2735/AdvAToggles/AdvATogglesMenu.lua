if AdvAToggles == nil then AdvAToggles = { } end
local AdvAToggles = _G['AdvAToggles']
--local L = AdvAToggle:GetLocale()
AdvAToggles.Menu = { }

local L = {
    menu = {
        --header = "Settings",
        description = "This addon exposes mute/unmute toggles for every audio setting in the game.\nEither through this menu, by using the /advat command or through key bindings.",

        master = "Master", 
        master_tooltip = "Mutes/unmutes everything. This does NOT change any of the other settings. If you have everything muted individually, this will not unmute it.",
        music = "Music",
        music_tooltip = "Mutes/unmutes the in-game music.",
        sound = "Sound",
        sound_tooltip = "Mutes/unmutes everything but music. Same switch as in ZOS's audio options.",
        ambient = "Ambient",
        ambient_tooltip = "Mutes/unmutes ambient sounds, like rivers, wind, birds, etc.",
        effects = "Effects",
        effects_tooltip = "Mutes/unmutes sound from all ability effects, collectibles like Pure Water, etc.",
        footsteps = "Footsteps",
        footsteps_tooltip = "Mutes/unmutes footsteps from players and mounts.",
        dialogue = "Dialogue",
        dialogue_tooltip = "Mutes/unmutes NPC dialogue. Including idle chatter.\nDo you know how long I've been looking for you?",
        interface = "Interface",
        interface_tooltip = "Mutes/unmutes every sound produced by the user interface.",
    },
}

function AdvAToggles.Menu:initialize()
    local LAM = LibAddonMenu2
    if not LAM then return end
  
    local panel_data = {
        type = "panel",
        name = AdvAToggles.title,
        displayName = AdvAToggles.title,
        author = AdvAToggles.author,
        version = AdvAToggles.version,
        registerForDefaults = true,
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel(AdvAToggles.name, panel_data)

    local options_table = { }
    --[[
    options_table[#options_table+1] =
    {
        type = "header",
        name = L.menu.header,
    }
    --]]
    options_table[#options_table+1] =
    {
        type = "description",
        text = L.menu.description,
    }
    options_table[#options_table+1] =
    {
        type = "divider",
    }
    --[[
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.accountwide,
        tooltip = L.menu.accountwide_tooltip,
        getFunc = function() return AdvAToggles_SavedVars.Default[GetDisplayName()]['$AccountWide']["account_wide"] end,
        setFunc = function(value) AdvAToggles_SavedVars.Default[GetDisplayName()]['$AccountWide']["account_wide"] = value end,
        requiresReload = true,
        default = AdvAToggles.defaults.account_wide,
    }
    --]]
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.master,
        tooltip = L.menu.master_tooltip,
        getFunc = function() return AdvAToggles.settings.master == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.master, value)
            AdvAToggles.settings.master = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.master,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.music,
        tooltip = L.menu.music_tooltip,
        getFunc = function() return AdvAToggles.settings.music == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.music, value)
            AdvAToggles.settings.music = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.music,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.sound,
        tooltip = L.menu.sound_tooltip,
        getFunc = function() return AdvAToggles.settings.sound == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.sound, value)
            AdvAToggles.settings.sound = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.sound,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.ambient,
        tooltip = L.menu.ambient_tooltip,
        getFunc = function() return AdvAToggles.settings.ambient == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.ambient, value)
            AdvAToggles.settings.ambient = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.ambient,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.effects,
        tooltip = L.menu.effects_tooltip,
        getFunc = function() return AdvAToggles.settings.effects == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.effects, value)
            AdvAToggles.settings.effects = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.effects,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.footsteps,
        tooltip = L.menu.footsteps_tooltip,
        getFunc = function() return AdvAToggles.settings.footsteps == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.footsteps, value)
            AdvAToggles.settings.footsteps = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.footsteps,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.dialogue,
        tooltip = L.menu.dialogue_tooltip,
        getFunc = function() return AdvAToggles.settings.dialogue == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.dialogue, value)
            AdvAToggles.settings.dialogue = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.dialogue,
    }
    options_table[#options_table+1] =
    {
        type = "checkbox",
        name = L.menu.interface,
        tooltip = L.menu.interface_tooltip,
        getFunc = function() return AdvAToggles.settings.interface == 1 end,
        setFunc = function(value)
            value = value == true and 1 or 0
            SetSetting(SETTING_TYPE_AUDIO, AdvAToggles.audio_settings.interface, value)
            AdvAToggles.settings.interface = value
        end,
        requiresReload = false,
        default = AdvAToggles.defaults.interface,
    }

    LAM:RegisterOptionControls(AdvAToggles.name, options_table)
end
