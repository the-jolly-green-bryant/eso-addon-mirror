local CC = CombatCoordination

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "AssaultCaltrops",
    menuName  = "ASSAULT CALTROPS",
    iconPath  = "/esoui/art/icons/ability_ava_001_a.dds",
    menuLayer = 2,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    CombatEvent = {
        ["Caltrops"]              = { 33376, },
        ["Anti-Cavalry Caltrops"] = { 40255, },
        ["Razor Caltrops"]        = { 40242, },
    },
    -- SkillBlocker = {
    --     ["Caltrops"]              = {},
    --     ["Anti-Cavalry Caltrops"] = {},
    --     ["Razor Caltrops"]        = {},
    -- },
    SkillData = {
        ["Caltrops"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 10,
            offsetOlorime = 0,
        },
        ["Anti-Cavalry Caltrops"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 15,
            offsetOlorime = 0,
        },
        ["Razor Caltrops"] = {
            type = 1, offsetPlayer = 0, maxRange = 28, width = 16, height = 16, durationSec = 10,
            offsetOlorime = 0,
        },
    },
    Default = {
        timer = 0,
        enableDrawSelf = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.75, 0.75, 0.75, 0.5 },
        texture = "/textures/circle_4_clean.dds",
        -- enableSkillBlocker = false, -- ONLY FOR DEBUGGING!
    },
    ---@type table|any
    SV = {},
}

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)