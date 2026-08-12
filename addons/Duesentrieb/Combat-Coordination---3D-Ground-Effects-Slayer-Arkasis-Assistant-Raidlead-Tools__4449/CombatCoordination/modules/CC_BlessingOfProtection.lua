local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "BlessingOfProtection",
    menuName  = "BLESSING OF PROTECTION",
    iconPath  = "/esoui/art/icons/ability_restorationstaff_003_b.dds",
    menuLayer = 2,

    TextureChoices = CC.SQUARE_CHOICES,
    TextureValues  = CC.SQUARE_VALUES,

    Skills = {
        ["Blessing of Protection"]  = { 37243, },
        ["Combat Prayer"]           = { 40094, },
        ["Blessing of Restoration"] = { 40103, },
    },
    SkillData = {
        ["Blessing of Protection"] = {
            type = 0, offsetPlayer = 10, maxRange = 0, width = 8,  height = 20, durationSec = 2.5,
        },
        ["Combat Prayer"] = {
            type = 0, offsetPlayer = 10, maxRange = 0, width = 8,  height = 20, durationSec = 2.5,
        },
        ["Blessing of Restoration"] = {
            type = 0, offsetPlayer = 10, maxRange = 0, width = 10,  height = 20, durationSec = 2.5,
        },
    },
    Default = {
        timer = 0,
        enableDrawSelf = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.75, 0.75, 0.75, 0.5 },
        texture = "/textures/square_4_clean.dds",
    },
    ---@type table|any
    SV = {},
}

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)