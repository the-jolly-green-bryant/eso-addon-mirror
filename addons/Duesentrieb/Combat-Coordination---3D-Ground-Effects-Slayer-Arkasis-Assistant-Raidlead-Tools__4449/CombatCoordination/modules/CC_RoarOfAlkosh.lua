local CC = CombatCoordination
local LUT = CC.LUT.ROAR_OF_ALKOSH

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "RoarOfAlkosh",
    menuName  = "ROAR OF ALKOSH",
    iconPath  = "/esoui/art/icons/gear_dromathra_medium_head_a.dds",
    menuLayer = 1,

    TextureChoices = CC.SQUARE_CHOICES,
    TextureValues  = CC.SQUARE_VALUES,

    CombatEvent = {
        ["Roar of Alkosh"] = { 76667, },
    },
    Broadcast = {
        ["Roar of Alkosh"] = LUT.EFFECT_GAINED,
    },
    -- TODO: SYNERGYBLOCKER.. SKILLBLOCKER DOES NOT WORK HERE
    -- Synergyblocker = {}, -- DOES NOT YET EXIST
    SkillData = {
        ["Roar of Alkosh"] = {
            type = 0, offsetPlayer = 7.5, maxRange = 0, width = 10, height = 15, durationSec = 10,
        },
    },
    Default = {
        timer = 1,
        enableDrawSelf = true,
        enableDrawGroup = false,
        enableGameAoeFriendlyColor = false,
        ColorSelf = { 0, 1, 1, 0.5 },
        ColorGroup = { 0, 1, 1, 0.5 },
        texture = "/textures/square_8_clean.dds",
        --enableSynergyblocker = true, -- DOES NOT YET EXIST BUT MAYBE AT SOME DAY
    },
    ---@type table|any
    SV = {},
}

-- TODO: MISSING A TARGET PROCS SET AND COOLDOWN BUT NOT A COMBAT EVENT.. SHOULD GET THAT FIGURED OUT SOMEHOW!
function Module:HandleCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result ~= ACTION_RESULT_EFFECT_GAINED then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    CC.Events:RefreshLastCast(abilityId)

    local LastCastData = CC.SkillData[CC.LastCast.abilityId]

    if not LastCastData then
        CC.Debug("RoarOfAlkosh:HandleCombatEvent; if not LastCastData then return end")
        return
    end

    CC.Events.HandleCombatEvent(self, eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

Module.HandleBroadcast = CC.Broadcast.HandleBroadcast
Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)