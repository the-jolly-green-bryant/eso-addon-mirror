local CC = CombatCoordination
local LUT = CC.LUT.NECROMANCER

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "NecromancerColossus",
    menuName  = "NECROMANCER COLOSSUS",
    iconPath  = "/esoui/art/icons/ability_necromancer_006_a.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["Frozen Colossus"]    = { 122174, },
        ["Pestilent Colossus"] = { 122395, },
        ["Glacial Colossus"]   = { 122388, },
    },
    Broadcast = {
        ["Frozen Colossus"]    = LUT.FROZEN_COLOSSUS,
        ["Pestilent Colossus"] = LUT.PESTILENT_COLOSSUS,
        ["Glacial Colossus"]   = LUT.GLACIAL_COLOSSUS,
    },
    -- TODO: BOSS HAS VULN? CAST ON BOSS? --> ALSO BLOCK? NEED POSITION OF BOSS FIRST..
    -- MAYBE THATS JUST TOO MUCH.. WOULD BE COOL THOUGH
    SkillBlocker = {
        ["Frozen Colossus"]    = {},
        ["Pestilent Colossus"] = {},
        ["Glacial Colossus"]   = {},
    },
    SkillData = {
        ["Frozen Colossus"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 12,
            offsetOlorime = 0,
        },
        ["Pestilent Colossus"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 12,
            offsetOlorime = 0,
        },
        ["Glacial Colossus"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 17,
            offsetOlorime = 0,
        },
    },
    Default = {
        timer = 1,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.5, 0.25, 0.75, 0.5 },
        ColorGroup = { 0.5, 0.25, 0.75, 0.5 },
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