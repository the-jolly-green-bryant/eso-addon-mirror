local CC = CombatCoordination
local LUT = CC.LUT.ASSAULT

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "AssaultWarHorn",
    menuName  = "ASSAULT WAR HORN",
    iconPath  = "/esoui/art/icons/ability_ava_003_a.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["War Horn"]        = { 38563, }, -- SKILL IDS
        ["Aggressive Horn"] = { 40223, },
        ["Sturdy Horn"]     = { 40220, },
    },
    Buffs = {
        ["War Horn"]        = { 38564, }, -- BUFF IDS
        ["Aggressive Horn"] = { 40224, },
        ["Sturdy Horn"]     = { 40221, },
    },
    Broadcast = {
        ["War Horn"]        = LUT.WAR_HORN,
        ["Aggressive Horn"] = LUT.AGGRESSIVE_HORN,
        ["Sturdy Horn"]     = LUT.STURDY_HORN,
    },
    SkillBlocker = {
        ["War Horn"]        = { 38564 },
        ["Aggressive Horn"] = { 40224 },
        ["Sturdy Horn"]     = { 40221 },
    },
    SkillData = {
        ["War Horn"] = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 40, height = 40, durationSec = 2.5,
        },
        ["Aggressive Horn"] = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 40, height = 40, durationSec = 2.5,
        },
        ["Sturdy Horn"] = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 40, height = 40, durationSec = 2.5,
        },
    },
    Default = {
        timer = 0,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 1, 0.5, 0.25, 0.25 },
        ColorGroup = { 1, 0.5, 0.25, 0.25 },
        texture = "/textures/circle_4_clean.dds",
        enableSkillBlocker = true,
    },
    ---@type table|any
    SV = {},
}

Module.HandleEffectChanged = CC.Events.HandleEffectChanged
Module.HandleBroadcast = CC.Broadcast.HandleBroadcast
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)