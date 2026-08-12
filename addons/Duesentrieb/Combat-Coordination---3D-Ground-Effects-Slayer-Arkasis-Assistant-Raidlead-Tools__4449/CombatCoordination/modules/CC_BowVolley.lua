local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "BowVolley",
    menuName  = "BOW VOLLEY",
    iconPath  = "/esoui/art/icons/ability_bow_003_a.dds",
    menuLayer = 2,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["Volley"]        = { 28876, },
        ["Endless Hail"]  = { 38689, },
        ["Arrow Barrage"] = { 38695, },
    },
    SkillData = {
        ["Volley"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 10, height = 10, durationSec = 10,
            offsetOlorime = 0,
        },
        ["Endless Hail"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 10, height = 10, durationSec = 15,
            offsetOlorime = 0,
        },
        ["Arrow Barrage"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 14, height = 14, durationSec = 10,
            offsetOlorime = 0,
        },
    },
    Default = {
        timer = 0,
        enableDrawSelf = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.75, 0.75, 0.5, 0.5 },
        texture = "/textures/circle_4_clean.dds",
    },
    ---@type table|any
    SV = {},
}

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)