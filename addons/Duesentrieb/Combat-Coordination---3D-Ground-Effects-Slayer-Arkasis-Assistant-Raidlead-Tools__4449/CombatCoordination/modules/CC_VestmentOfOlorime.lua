local CC = CombatCoordination
local LUT = CC.LUT.VESTMENT_OF_OLORIME

----------------------------------------------------------------------------------------------------
-- MODULE VARS AND SVARS
----------------------------------------------------------------------------------------------------
local Module = {
    name      = "VestmentOfOlorime",
    menuName  = "VESTMENT OF OLORIME",
    iconPath  = "/esoui/art/icons/ability_templar_rune_focus.dds",
    menuLayer = 1,

    TextureChoices = CC.CIRCLE_CHOICES,
    TextureValues  = CC.CIRCLE_VALUES,

    Skills = {
        ["Vestment Of Olorime"] = { 107141, },
    },
    Broadcast = {
        ["Vestment Of Olorime"] = LUT.EFFECT_GAINED,
    },
    SkillData = {
        ["Vestment Of Olorime"] = {
            type = 0, offsetPlayer = 0, maxRange = 0, width = 8, height = 8, durationSec = 5,
            offsetOlorime = 0,
        },
    },
    Default = {
        timer = 2,
        enableDrawSelf = true,
        enableDrawGroup = true,
        enableGameAoeFriendlyColor = false,

        enableNotification = true,
        volumeNotification = 0,

        ColorSelf = { 1, 0.75, 0, 0.75 },
        ColorGroup = { 1, 0.75, 0, 0.75 },
        texture = "/textures/circle_64_clean.dds",
    },
    ---@type table|any
    SV = {},
}

----------------------------------------------------------------------------------------------------
-- CENTER SCREEN NOTIFICATION
----------------------------------------------------------------------------------------------------
function Module:PlayNotification()
    if not self.SV.enableNotification then return end

    local durationSec = 1.0
    local colorHex = ""

    if self.SV.enableGameAoeFriendlyColor then
        colorHex = CC.GetHexColorFromArray(CC.GetGameAoeFriendlyColor())
    else
        colorHex = CC.GetHexColorFromArray(self.SV.ColorSelf)
    end

    -- TODO: ARROW POINTING TOWARS OLORIME
    local line1, line2 = colorHex .. "OLORIME!|r", ""

    if self.SV.volumeNotification > 0 then
        CC.PlaySound(SOUNDS.ABILITY_ULTIMATE_READY, self.SV.volumeNotification)
    end

    CC.DisplayNotification:TriggerCustom(durationSec, line1, line2, false)
end

----------------------------------------------------------------------------------------------------
-- WRAPPER COMBAT EVENT
----------------------------------------------------------------------------------------------------
function Module:HandleCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result ~= ACTION_RESULT_EFFECT_GAINED then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    local LastCastData = CC.SkillData[CC.LastCast.abilityId]

    if not LastCastData then
        CC.Debug("VestmentOfOlorime:HandleCombatEvent; if not LastCastData then return end")
        return
    end
    if LastCastData.offsetOlorime == nil then
        CC.Debug("VestmentOfOlorime:HandleCombatEvent; if LastCastData.offsetOlorime == nil then return end")
        return
    end

    -- LOCAL EFFECTS LIKE ALTAR ETC -> INJECTING OFFSET.. LOOKING AT YOU, WALL OF ELEMENTS!
    if LastCastData.type == CC.SKILL_TYPE_FIXED then
        local offsetOlorime = LastCastData.offsetOlorime * 100

        CC.LastCast.playerX = CC.LastCast.playerX - offsetOlorime * math.sin(CC.LastCast.heading)
        CC.LastCast.playerZ = CC.LastCast.playerZ - offsetOlorime * math.cos(CC.LastCast.heading)

    -- RANGE EFFECTS LIKE CALTROPS -> INJECTING CAMERA POSITION INTO PLAYER POS.. NICE, HUH?
    elseif LastCastData.type == CC.SKILL_TYPE_RANGED then
        if CC.LastCast.cameraX == 0 and CC.LastCast.cameraZ == 0 then return end
        CC.LastCast.playerX = CC.LastCast.cameraX
        CC.LastCast.playerY = CC.LastCast.cameraY
        CC.LastCast.playerZ = CC.LastCast.cameraZ
    end

    self:PlayNotification()

    -- USING DOT HERE ON PURPOSE.. WRAPPER
    CC.Events.HandleCombatEvent(self, eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

----------------------------------------------------------------------------------------------------
-- WRAPPER BROADCAST
----------------------------------------------------------------------------------------------------
function Module:HandleBroadcast(unitTag, Data)
    self:PlayNotification()
    -- USING DOT HERE ON PURPOSE.. WRAPPER
    CC.Broadcast.HandleBroadcast(self, unitTag, Data)
end

Module.GetMenuOptions = function(self) return CC.CreateModuleSettings(self, self.menuName, self.iconPath) end

CC[Module.name] = Module
table.insert(CC.Modules, Module)