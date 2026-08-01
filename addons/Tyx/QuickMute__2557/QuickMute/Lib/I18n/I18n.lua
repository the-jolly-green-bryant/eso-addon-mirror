--[[----------------------------------------------
    Project:    QuickMute
    Author:     Arne Rantzen (Tyx)
    Created:    2020-03-08
    Updated:    020-03-08
    License:    GPL-3.0
----------------------------------------------]]--
QuickMute = QuickMute or {}

local i18n = QuickMute.i18n
local toggle_audio = zo_strformat(i18n.menu, i18n.toggle, i18n.audio)
local toggle_music = zo_strformat(i18n.menu, i18n.toggle, i18n.music)
local toggle_sound = zo_strformat(i18n.menu, i18n.toggle, i18n.sound)

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_QUICK_MUTE", "QuickMute")
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MUTE_TOGGLE_AUDIO", toggle_audio)
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MUTE_TOGGLE_MUSIC", toggle_music)
ZO_CreateStringId("SI_BINDING_NAME_QUICK_MUTE_TOGGLE_SOUND", toggle_sound)