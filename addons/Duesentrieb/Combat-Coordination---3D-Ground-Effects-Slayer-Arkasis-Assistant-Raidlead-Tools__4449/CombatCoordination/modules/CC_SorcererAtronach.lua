local CC = CombatCoordination
local LUT = CC.LUT.SORCERER

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SorcererAtronach",
    menuName  = "SORCERER ATRONACH",
    iconPath  = "/esoui/art/icons/ability_sorcerer_endless_atronachs.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["Storm Atronach"]         = { 23634, },
        ["Greater Storm Atronach"] = { 23492, },
        ["Charged Atronach"]       = { 23495, },
    },
    Broadcast = {
        ["Storm Atronach"]         = LUT.STORM_ATRONACH,
        ["Greater Storm Atronach"] = LUT.GREATER_STORM_ATRONACH,
        ["Charged Atronach"]       = LUT.CHARGED_ATRONACH,
    },
    SkillBlocker = {
        ["Storm Atronach"]         = { 80459, 61745, }, -- 80459, 80463, 80468: ATRO SPAWNED "STANDING IN AREA" BUFFS
        ["Greater Storm Atronach"] = { 80463, }, -- 61745: BERSERK FROM E.G. DK CLASS MASTERY
        ["Charged Atronach"]       = { 80468, },
    },
    SkillData = {
        ["Storm Atronach"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 15,
            offsetOlorime = 0,
        },
        ["Greater Storm Atronach"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 12, height = 12, durationSec = 15,
            offsetOlorime = 0,
        },
        ["Charged Atronach"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 15,
            offsetOlorime = 0,
        },
    },
    Default = {
        timer = 2,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.5, 1, 1, 0.5 },
        ColorGroup = { 0.5, 1, 1, 0.5 },
        texture = "/textures/circle_4_clean.dds",
        enableSkillBlocker = true,
    },
    ---@type table|any
    SV = {},
}

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.HandleBroadcast = CC.Broadcast.HandleBroadcast
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)