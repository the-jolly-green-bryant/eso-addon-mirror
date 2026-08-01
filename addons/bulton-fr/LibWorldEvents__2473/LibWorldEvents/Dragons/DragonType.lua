LibWorldEvents.Dragons.DragonType = {}

-- @var table list The list of all existing dragons in Elsweyr, with data to identify them
LibWorldEvents.Dragons.DragonType.list = {
    [1] = {
        colorTxt = GetString(SI_LIB_WORLD_EVENTS_DRAGON_COLOR_RED),
        colorRGB  = {r=1, g=0, b=0},
        abilityId = 122559,
        maxHP     = 14713494
    },
    [2] = {
        colorTxt  = GetString(SI_LIB_WORLD_EVENTS_DRAGON_COLOR_GREY),
        colorRGB  = {r=0.48235, g=0.47059, b=0.45098},
        abilityId = 122559,
        maxHP     = 16184844
    },
    [3] = {
        colorTxt  = GetString(SI_LIB_WORLD_EVENTS_DRAGON_COLOR_BLACK),
        colorRGB  = {r=0, g=0, b=0},
        abilityId = 122562,
        maxHP     = 14713494
    },
    [4] = {
        colorTxt  = GetString(SI_LIB_WORLD_EVENTS_DRAGON_COLOR_WHITE),
        colorRGB  = {r=1, g=1, b=1},
        abilityId = 122561,
        maxHP     = 14713494
    },
}

--[[
-- Return info from a dragon buff
--
-- @param string unitTag The dragon unitTag
-- @param number buffIdx Index of the buff
--
-- @return table
--]]
function LibWorldEvents.Dragons.DragonType:obtainInfo(unitTag, buffIdx)
    local
        buffName,
        timeStarted,
        timeEnding,
        buffSlot,
        stackCount,
        iconFilename,
        buffType,
        effectType,
        abilityType,
        statusEffectType,
        abilityId,
        canClickOff,
        castByPlayer
    = GetUnitBuffInfo(unitTag, buffIdx)

    return {
        buffName         = buffName,
        timeStarted      = timeStarted,
        timeEnding       = timeEnding,
        buffSlot         = buffSlot,
        stackCount       = stackCount,
        iconFilename     = iconFilename,
        buffType         = buffType,
        effectType       = effectType,
        abilityType      = abilityType,
        statusEffectType = statusEffectType,
        abilityId        = abilityId,
        canClickOff      = canClickOff,
        castByPlayer     = castByPlayer
    }
end

--[[
-- Obtain info about a dragon type from buff
--
-- @param Dragon dragon The dragon for which we want to determine the type
--
-- @return table|nil
--]]
function LibWorldEvents.Dragons.DragonType:obtainForDragon(dragon)
    local nbBuff   = GetNumBuffs(dragon.unit.tag)
    local buffIdx  = 1
    local buffInfo = nil
    local typeIdx  = 1

    local currentHP, maxHP, effectiveMaxHP = GetUnitPower(dragon.unit.tag, POWERTYPE_HEALTH)

    for buffIdx = 1, nbBuff do
        buffInfo = self:obtainInfo(dragon.unit.tag, buffIdx)

        for typeIdx = 1, #self.list do
            if buffInfo.abilityId == self.list[typeIdx].abilityId and maxHP == self.list[typeIdx].maxHP then
                buffInfo.dragonName     = buffInfo.buffName
                buffInfo.dragonColorTxt = self.list[typeIdx].colorTxt
                buffInfo.dragonColorRGB = self.list[typeIdx].colorRGB
                buffInfo.maxHP          = self.list[typeIdx].maxHP

                return buffInfo
            end
        end
    end

    return nil
end
