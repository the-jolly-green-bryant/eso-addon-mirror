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

    Skills = {
        ["Healing Seed"]      = { 85578, },
        ["Corrupting Pollen"] = { 85845, },
        ["Budding Seeds"]     = { 85840, },
        ["Instant Bloom"]     = { 85922, },
    },
    Broadcast = {
        ["Healing Seed"]      = LUT.HEALING_SEED,
        ["Corrupting Pollen"] = LUT.CORRUPTING_POLLEN,
        ["Budding Seeds"]     = LUT.BUDDING_SEEDS,
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

----------------------------------------------------------------------------------------------------
-- BLOOM CAST
----------------------------------------------------------------------------------------------------
function Module:HandleActionSlotAbilityUsed(abilityId)
    if abilityId == 85922 then
        CC.ClearCombatVisuals(self, true, "player")
    end
end

Module.HandleCombatEvent = CC.Events.HandleCombatEvent
Module.HandleBroadcast = CC.Broadcast.HandleBroadcast
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)