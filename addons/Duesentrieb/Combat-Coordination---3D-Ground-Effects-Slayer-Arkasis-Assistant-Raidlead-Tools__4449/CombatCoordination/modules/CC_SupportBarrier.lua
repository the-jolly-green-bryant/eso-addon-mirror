local CC = CombatCoordination
local LUT = CC.LUT.SUPPORT

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "SupportBarrier",
    menuName  = "SUPPORT BARRIER",
    iconPath  = "/esoui/art/icons/ability_ava_006_b.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    CombatEvent = {
        ["Barrier"]              = { 38573, },
        ["Reviving Barrier"]     = { 40237, },
        ["Replenishing Barrier"] = { 40239, },
    },
    Broadcast = {
        ["Barrier"]              = LUT.BARRIER,
        ["Reviving Barrier"]     = LUT.REVIVING_BARRIER,
        ["Replenishing Barrier"] = LUT.REPLENISHING_BARRIER,
    },
    -- TODO: SKILL BLOCKER DOES NOT WORK ATM.. WHY? DONT KNOW.. KINDA SHOULD BUT DONT..?
    -- TODO: THIS NEEDS TO BE DECOUPLED FROM THE BUFF..
    -- SkillBlocker = {
    --     ["Barrier"]              = { 38573, },
    --     ["Reviving Barrier"]     = { 40237, },
    --     ["Replenishing Barrier"] = { 40239, },
    -- },
    SkillData = {
        ["Barrier"] = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 24, height = 24, durationSec = 2.5,
        },
        ["Reviving Barrier"] = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 24, height = 24, durationSec = 2.5,
        },
        ["Replenishing Barrier"]   = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 24, height = 24, durationSec = 2.5,
        },
    },
    Default = {
        timer = 0,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0.5, 1, 0.25, 0.25 },
        ColorGroup = { 0.5, 1, 0.25, 0.25 },
        texture = "/textures/circle_4_clean.dds",
        --enableSkillBlocker = true,
    },
    ---@type table|any
    SV = {},
}

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.HandleBroadcast = CC.Broadcast.HandleBroadcast
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)