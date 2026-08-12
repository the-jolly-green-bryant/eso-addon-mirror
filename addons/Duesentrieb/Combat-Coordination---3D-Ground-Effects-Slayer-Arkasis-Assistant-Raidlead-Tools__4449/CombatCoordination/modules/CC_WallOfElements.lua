local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "WallOfElements",
    menuName  = "WALL OF ELEMENTS",
    iconPath  = "/esoui/art/icons/ability_destructionstaff_002a.dds",
    menuLayer = 2,

    TextureChoices = CC.SQUARE_CHOICES,
    TextureValues  = CC.SQUARE_VALUES,

    Skills = {
        ["Wall of Element"]           = { 28849, 28807, 28854, },
        ["Unstable Wall of Elements"] = { 39067, 39053, 39073, },
        ["Elemental Blockade"]        = { 39028, 39012, 39018, },
    },
    SkillData = {
        ["Wall of Element"] = {
            type = 0, offsetPlayer = 9, maxRange = 0, width = 8,  height = 18, durationSec = 10,
            offsetOlorime = 4,
        },
        ["Unstable Wall of Elements"] = {
            type = 0, offsetPlayer = 9, maxRange = 0, width = 8,  height = 18, durationSec = 10,
            offsetOlorime = 4,
        },
        ["Elemental Blockade"] = {
            type = 0, offsetPlayer = 9, maxRange = 0, width = 12, height = 18, durationSec = 15,
            offsetOlorime = 4,
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