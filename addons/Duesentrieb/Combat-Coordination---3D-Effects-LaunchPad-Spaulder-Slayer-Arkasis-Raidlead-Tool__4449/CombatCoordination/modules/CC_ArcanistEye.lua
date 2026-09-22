local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "ArcanistEye",
    menuName  = "ARCANIST EYE",
    iconPath  = "/esoui/art/icons/ability_arcanist_006_b.dds",
    menuLayer = 3,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["The Unblinking Eye"] = { 189791, },
        ["The Languid Eye"]    = { 189867, },
    },
    SkillData = {
        ["The Unblinking Eye"] = {
            type = 1, offsetPlayer = 0, maxRange = 15, width = 10, height = 10, durationSec = 6, isRecast = true,
            offsetOlorime = 0,
        },
        ["The Languid Eye"] = {
            type = 1, offsetPlayer = 0, maxRange = 15, width = 10, height = 10, durationSec = 6, isRecast = true,
            offsetOlorime = 0,
        },
    },
    Default = {
        enableModule = true,
        timerModeSelf = 0,
        timerModeGroup = 0,
        enableDrawSelf = true,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.75, 1, 0.25, 0.5 },
        texture = "/textures/circle_8_clean.dds",
    },
    ---@type table|any
    SV = {},
}

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)