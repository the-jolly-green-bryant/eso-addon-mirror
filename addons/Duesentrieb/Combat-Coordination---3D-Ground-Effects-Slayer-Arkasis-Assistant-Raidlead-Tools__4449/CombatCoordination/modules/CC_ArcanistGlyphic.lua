local CC = CombatCoordination
local LUT = CC.LUT.ARCANIST

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "ArcanistGlyphic",
    menuName  = "ARCANIST GLYPHIC",
    iconPath  = "/esoui/art/icons/ability_arcanist_012.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["Vitalizing Glyphic"]   = { 183709, },
        ["Glyphic of the Tides"] = { 193794, },
        ["Resonating Glyphic"]   = { 193558, },
    },
    Broadcast = {
        ["Vitalizing Glyphic"]   = LUT.VITALIZING_GLYPHIC,
        ["Glyphic of the Tides"] = LUT.GLYPHIC_OF_THE_TIDED,
        ["Resonating Glyphic"]   = LUT.RESONATING_GLYPHIC,
    },
    SkillBlocker = {
        ["Vitalizing Glyphic"]   = {},
        ["Glyphic of the Tides"] = {},
        ["Resonating Glyphic"]   = {},
    },
    SkillData = {
        ["Vitalizing Glyphic"]   = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 30, height = 30, durationSec = 15,
            offsetOlorime = 0,
        },
        ["Glyphic of the Tides"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 30, height = 30, durationSec = 15,
            offsetOlorime = 0,
        },
        ["Resonating Glyphic"]   = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 30, height = 30, durationSec = 15,
            offsetOlorime = 0,
        },
    },
    Default = {
        timer = 2,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.75, 1, 0.25, 0.25 },
        ColorGroup = { 0.75, 1, 0.25, 0.25 },
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