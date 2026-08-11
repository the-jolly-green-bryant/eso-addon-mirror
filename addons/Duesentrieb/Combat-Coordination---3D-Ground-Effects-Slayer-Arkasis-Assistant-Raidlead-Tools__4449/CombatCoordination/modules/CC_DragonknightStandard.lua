local CC = CombatCoordination
local LUT = CC.LUT.DRAGONKNIGHT

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "DragonknightStandard",
    menuName  = "DRAGONKNIGHT STANDARD",
    iconPath  = "/esoui/art/icons/ability_dragonknight_006_b.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    CombatEvent = {
        ["Dragonknight Standard"] = { 28988, },
        ["Standard of Might"]     = { 32947, },
        ["Shifting Standard"]     = { 32958, 32963, },
        --["Test"]                  = { 17878, },
    },
    Broadcast = {
        ["Dragonknight Standard"] = LUT.DRAGONKNIGHT_STANDARD,
        ["Standard of Might"]     = LUT.STANDARD_OF_MIGHT,
    },
    SkillBlocker = {
        ["Dragonknight Standard"] = { 29230, },
        ["Standard of Might"]     = { 32948, },
        --["Test"]                  = { 61694, }, -- TEST WITH RESOLVE.. BLOCKS ALL SKILLS IN SkillBlocker. SUCCESS
    },
    SkillData = {
        ["Dragonknight Standard"] = {
            type = 0, offsetPlayer = 1.5, maxRange = 0, width = 16, height = 16, durationSec = 15,
            offsetOlorime = 1.5,
        },
        ["Standard of Might"] = {
            type = 0, offsetPlayer = 1.5, maxRange = 0, width = 16, height = 16, durationSec = 15,
            offsetOlorime = 1.5,
        },
        ["Shifting Standard"] = {
            type = 0, offsetPlayer = 1.5, maxRange = 0, width = 16, height = 16, durationSec = 25, isRecast = true,
            offsetOlorime = 1.5,
        },
        -- ["Test"] = {
        --     type = 0, offsetPlayer = 1.5, maxRange = 0, width = 16, height = 16, durationSec = 15,
        --     offsetOlorime = 1.5,
        -- },
    },
    Default = {
        timer = 1,
        enableDrawSelf = true,
        enableDrawGroup = true,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 1, 0.5, 0, 0.5 },
        ColorGroup = { 1, 0.5, 0, 0.5 },
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