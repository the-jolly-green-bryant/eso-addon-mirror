local CC = CombatCoordination
local LUT = CC.LUT.WARDEN

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "WardenHealingSeed",
    menuName  = "WARDEN HEALING SEED",
    iconPath  = "/esoui/art/icons/ability_warden_007_b.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    CombatEvent = {
        ["Healing Seed"]      = { 85578, },
        ["Corrupting Pollen"] = { 85845, },
        ["Budding Seeds"]     = { 85840, },
    },
    Broadcast = {
        ["Healing Seed"]      = LUT.VITALIZING_GLYPHIC,
        ["Corrupting Pollen"] = LUT.GLYPHIC_OF_THE_TIDED,
        ["Budding Seeds"]     = LUT.RESONATING_GLYPHIC,
    },
    SkillData = {
        ["Healing Seed"]   = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 6,
            offsetOlorime = 0,
        },
        ["Corrupting Pollen"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 6,
            offsetOlorime = 0,
        },
        ["Budding Seeds"]   = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 6,
            offsetOlorime = 0,
        },
    },
    -- SHOUTOUT TO LUKAS @AEROCO FOR THE IDEA TO BLOCK INSTANT BLOOM!
    SkillBlocker = {
        ["Budding Seeds"] = { 85922, }, -- INSTANT BLOOM ID 85922
    },
    Default = {
        timer = 0,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0, 1, 1, 0.25 },
        ColorGroup = { 0, 1, 1, 0.25 },
        texture = "/textures/circle_8_clean.dds",
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