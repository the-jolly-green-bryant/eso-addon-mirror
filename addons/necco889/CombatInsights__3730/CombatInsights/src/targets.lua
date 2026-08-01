CombatInsightsTargets = {}
local Targets = CombatInsightsTargets
local Consts = CombatInsightsConsts
local Utils = CombatInsightsUtils
local logger = Utils.CreateSubLogger("targets")


local function debugPrint(message, ...)
    df("[CPChT]: %s", message:format(...))
end


local Target = {}
function Target:New(unitId)
    local o = {}
    o.unitId = unitId
    -- o.dmgTaken = 0
    -- o.debuffCrit = 0
    -- o.penetration = 0
    setmetatable(o, self)
    self.__index = self
    return o
end

function Target:Copy()
    -- return Utils.DeepCopy(self)
    local o = ZO_ShallowTableCopy(self)
    setmetatable(o, getmetatable(self))
    return o
end

-- function Target:ReCalcDmgTaken()
--     local t = self
--     local dmgTaken = 0
--     if t.minorVuln then dmgTaken = dmgTaken + 5 end
--     if t.majorVuln then dmgTaken = dmgTaken + 10 end
--     if t.abyssalInk then dmgTaken = dmgTaken + 5 end    --yes this is a debuff tooltip lies
--     if t.mk then dmgTaken = dmgTaken + 8 end               --TODO MK check
--     if t.zen then dmgTaken = dmgTaken + (t.zenStacks > 5 and 5 or t.zenStacks) end
--     t.dmgTaken = dmgTaken
-- end

-- function Target:ReCalcDebuffCrit()
--     local t = self
--     local crit = 0
--     if t.minorBrittle then crit = crit  + Consts.CRIT_DMG_VALUE_MINOR_BRITTLE end
--     if t.majorBrittle then crit = crit  + Consts.CRIT_DMG_VALUE_MAJOR_BRITTLE end
--     if t.dummyEC then
--         crit = crit       + Consts.CRIT_DMG_VALUE_CATALYST_DUMMY
--     else
--         if t.flameWeakness then crit = crit + Consts.CRIT_DMG_VALUE_CATALYST end
--         if t.frostWeakness then crit = crit + Consts.CRIT_DMG_VALUE_CATALYST end
--         if t.shockWeakness then crit = crit + Consts.CRIT_DMG_VALUE_CATALYST end
--     end
--     --FIXME if EC is up remove flame/frost/shock?
--     t.debuffCrit = crit
-- end

-- function Target:ReCalcDebuffPen()
--     local t = self
--     local pen = 0
--     if t.minorBreach    then pen = pen + Consts.PEN_MINORBREACH     end
--     if t.majorBreach    then pen = pen + Consts.PEN_MAJORBREACH     end
--     if t.crusher        then pen = pen + Consts.PEN_CRUSHER         end
--     if t.crystalWeapon  then pen = pen + Consts.PEN_CRYSTALWEAPON   end
--     if t.alkosh         then pen = pen + Consts.PEN_ALKOSH          end
--     if t.crimsonOath    then pen = pen + Consts.PEN_CRIMSONOATH     end
--     if t.tremorscale    then pen = pen + Consts.PEN_TREMORSCALE     end
--     if t.runicSunder    then pen = pen + Consts.PEN_RUNICSUNDER     end
--     --TODO FON (660)
--     t.penetration = pen
-- end


function Targets:New()
    local o = {}
    o.targets = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Targets:Get(unitId)
    local t = self.targets[unitId]
    if not t then
        t = Target:New(unitId)
        self.targets[unitId] = t
    end
    return t
end

local function isGain(changeType)
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        return true
    elseif changeType == EFFECT_RESULT_FADED then
        return false
    else
        debugPrint("ERROR Unknown change type: %d", changeType)
    end
    return false
end

function Targets:HandleDebuffEvent(analysis, logline, trialDummy)
    local _, timeMs, unitId, abilityId, changeType, effectType, stacks, sourceType, slot = unpack(logline)
    if not unitId then
        logger:Warn("HandleDebuffEvent Unknown unitId ability: %d %s", abilityId, GetAbilityName(abilityId))
        return
    end
    local t = self:Get(unitId)
    
    local abilityName = GetAbilityName(abilityId)

    if abilityName == GetAbilityName(Consts.debuffs.abyssalInk) then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            t.abyssalInk = isGain(changeType)
        end
    elseif abilityName == GetAbilityName(Consts.debuffs.incap) then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            t.incap = isGain(changeType)
        end
    elseif abilityName == GetAbilityName(Consts.debuffs.soulharvest) then
        if sourceType == COMBAT_UNIT_TYPE_PLAYER then
            t.soulharvest = isGain(changeType)
        end
    elseif abilityName == GetAbilityName(Consts.debuffs.zen) then
        t.zen = isGain(changeType)
        t.zenStacks = 5 --TODO probably this will be complicated
    elseif abilityName == GetAbilityName(Consts.debuffs.stagger) then
        t.stagger = isGain(changeType)
        t.staggerStacks = t.stagger and stacks or 0
    elseif abilityName == GetAbilityName(Consts.debuffs.offBalance) or abilityName == "Off-Balance" or abilityName == "Off Balance" then
        t.offBalance = isGain(changeType)
    else
        -- general debuff
        for k,v in pairs(Consts.debuffs) do
            if abilityName == GetAbilityName(v) then
                t[k] = isGain(changeType)
            end
        end
    end

    --FIXME off balance on dummy is not visible in the fight log
    if trialDummy then
        for _,v in pairs(Consts.trialDummyDebuffs) do
            t[v] = true
        end
        -- FIXME hack for offbalance
        -- on dummy its not reported and triggered by any damage ( ie: if u dont hit it for some seconds it wont proc on cooldown )
        -- best i can think of is just assume its gonna be up for 7 seconds every 22 seconds (full uptime)
        local period = (timeMs - analysis.cmxFight.dpsstart) % 22000
        if period < 7000 then
            t.offBalance = true
        else
            t.offBalance = nil
        end
    end

    -- t:ReCalcDebuffPen()
    -- t:ReCalcDebuffCrit()
    -- t:ReCalcDmgTaken()
end

