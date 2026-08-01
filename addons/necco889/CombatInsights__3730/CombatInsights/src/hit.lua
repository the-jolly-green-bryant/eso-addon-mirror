CombatInsightsHit = {}
local Hit = CombatInsightsHit
local Targets = CombatInsightsTargets
local Player = CombatInsightsPlayer
-- local CompareTable = CombatInsightsCompareTable
local Consts = CombatInsightsConsts
local Utils = CombatInsightsUtils

local logger = Utils.CreateSubLogger("hit")

local function debugPrint(message, ...)
    df("[CPHit]: %s", message:format(...))
end

local function clampPen(pen)
    if pen > 18200 then return 18200 end
    return pen
end

local function clampCritDmg(critDmg)
    if critDmg > 125 then return 125 end
    return critDmg
end

function Hit:New(analysis, index, timeMs, value, isCrit, abilityId, player, target, damageType)
    local o = {}
    o.analysis = analysis
    o.index = index
    o.timeMs = timeMs
    o.value = value
    o.isCrit = isCrit
    o.abilityId = abilityId
    o.player = player
    o.target = target
    o.damageType = damageType

    o.penetration = 0
    o.critDmg = 0
    o.dmgDone = 0
    o.dmgDoneValueKnown = false
    o.dmgDoneToMonsters = 0
    o.dmgTaken = 0
    o.apparentWeaponDmg = 0
    o.weaponDmgBonus = 0
    setmetatable(o, self)
    self.__index = self
    -- o:ReCalcModifiers()
    return o
end


function Hit:Copy(copyPlayerFields, copyTarget)
    -- local other = Utils.DeepCopy(self)
    -- return other
    local o = Hit:New(
        self.analysis,
        self.index,
        self.timeMs,
        self.value,
        self.isCrit,
        self.abilityId,
        copyPlayerFields and self.player:Copy(copyPlayerFields) or self.player,
        copyTarget and self.target:Copy() or self.target,
        self.damageType
    )
    o.enemyHpKnown = self.enemyHpKnown
    o.enemyHpPercent = self.enemyHpPercent
    o.previousHit = self.previousHit
    o.nextHit = self.nextHit
    o.error = self.error
    o:ReCalcModifiers()
    return o
end

function Hit:ReCalcPen()
    local player = self.player
    local target = self.target
    local pen = player.stats.penetration

    if target.minorBreach    then pen = pen + Consts.PEN_MINORBREACH     end
    if target.majorBreach    then pen = pen + Consts.PEN_MAJORBREACH     end
    if target.crusher        then pen = pen + Consts.PEN_CRUSHER         end
    if target.crystalWeapon  then pen = pen + Consts.PEN_CRYSTALWEAPON   end
    if target.alkosh         then pen = pen + Consts.PEN_ALKOSH          end
    if target.crimsonOath    then pen = pen + Consts.PEN_CRIMSONOATH     end
    if target.tremorscale    then pen = pen + Consts.PEN_TREMORSCALE     end
    if target.runicSunder    then pen = pen + Consts.PEN_RUNICSUNDER     end
    if player.cps.fon then
        local fonStack = 0
        if target.burning then fonStack = fonStack + 1 end
        if target.chilled then fonStack = fonStack + 1 end
        if target.diseased then fonStack = fonStack + 1 end
        if target.hemorrhaging then fonStack = fonStack + 1 end
        if target.overcharged then fonStack = fonStack + 1 end
        if target.poisoned then fonStack = fonStack + 1 end
        if target.sundered then fonStack = fonStack + 1 end
        pen = pen + fonStack * Consts.PEN_FON_PER_STACK
    end

    if self.penetrationOffset then
        pen = pen + self.penetrationOffset
        if pen < 0 then pen = 0 end
    end
    self.armorModifier = 1 - ((18200-clampPen(pen)) / 50000)
end

function Hit:ReCalcCritDmg()
    local target = self.target
    local crit = self.player.stats.critDmg
    if target.minorBrittle then crit = crit + Consts.CRIT_DMG_VALUE_MINOR_BRITTLE end
    if target.majorBrittle then crit = crit + Consts.CRIT_DMG_VALUE_MAJOR_BRITTLE end
    if target.dummyEC then
        crit = crit + Consts.CRIT_DMG_VALUE_CATALYST_DUMMY
    else
        if target.flameWeakness then crit = crit + Consts.CRIT_DMG_VALUE_CATALYST end
        if target.frostWeakness then crit = crit + Consts.CRIT_DMG_VALUE_CATALYST end
        if target.shockWeakness then crit = crit + Consts.CRIT_DMG_VALUE_CATALYST end
    end
    --FIXME if EC is up remove flame/frost/shock?
    self.critDmg = crit
    self.critDmgModifier = clampCritDmg(crit) / 100 + 1
end

function Hit:ReCalcDmgDone()
    local target = self.target
    local player = self.player
    local passives = self.player.passives or {}
    local val = 0
    local isMartialDmgType = self.damageType == DAMAGE_TYPE_PHYSICAL or self.damageType == DAMAGE_TYPE_BLEED or self.damageType == DAMAGE_TYPE_POISON or self.damageType == DAMAGE_TYPE_DISEASE
    self.dmgDoneValueKnown = true
    if player.buffs.minorBerserk   then val = val + 5  end
    if player.buffs.majorBerserk   then val = val + 10 end
    if player.buffs.minorSlayer    then val = val + 5  end
    if player.buffs.majorSlayer    then val = val + 10 end
    if player.buffs.spectralCloak  then val = val + 6 end
    
    local data = Consts.abilityTable[self.abilityId]
    if data and not data.ignore then
        if data.st      and player.cps.da  then val = val + 6 end
        if data.aoe     and player.cps.ba  then val = val + 6 end
        if data.dot     and player.cps.th  then val = val + 6 end
        if data.direct  and player.cps.maa then val = val + 6 end
        
        --deadly buffs channels and dots
        if (data.channel or data.dot) and player.gear.sets.deadly and player.gear.sets.deadly[player.stats.activeBar] then
            val = val + 15
        end

        if player.gear.infernoStaff[player.stats.activeBar] and passives.ancientKnowledge then
            -- +12% dot and status effects
            if data.dot or data.statusEffect then
                val = val + passives.ancientKnowledge * 6
            end

        elseif player.gear.lightningStaff[player.stats.activeBar] and passives.ancientKnowledge then
            -- +12% direct and channeled
            if data.direct or data.channel then
                val = val + passives.ancientKnowledge * 6
            end
        end
        
        if data.bow and player.buffs.hawkeye and passives.hawkeye then
            val = val + (player.buffs.hawkeyeStacks or 0) * (passives.hawkeye == 1 and 2 or 5)
        end

        if data.twoHanded and player.buffs.followUp and passives.followUp then
            val = val + passives.followUp * 5
        end
        
        if data.direct and player.buffs.mercilessCharge then
            val = val + math.max(math.min(self.effectiveWeaponDmg * 12 / 6666, 12), 8)
        end

        if passives.rapidRot and data.dot then
            val = val + passives.rapidRot * 5
        end

        if passives.psychicLesion and data.statusEffect then
            val = val + (passives.psychicLesion == 1 and 7 or 15)
        end

        if target.warmth and passives.warmth and data.dot then
            val = val + passives.warmth * 3
        end

        if passives.slaughter and data.dualWield then
            --Slaughter, 10/20% dmg done with dual wield abilities to targets under 25%
            if not self.enemyHpPercent then
                self.enemyHpKnown, self.enemyHpPercent =  self.analysis:GetEnemyHpPercent(self.timeMs, self.target.unitId)
            end
            if not self.enemyHpKnown then
                self.analysis:AddWarningUnknownEnemyHp(self.target.unitId)
                self.dmgDoneValueKnown = false
            elseif self.enemyHpPercent <= 0.25 then
                val = val + (passives.hawkeye == 1 and 2 or 5)
            end
        end

        if passives.vinedusk and player.gear.bow[player.stats.activeBar] then
            --Vinedusk Training, 2/5% dmg done to enemies 15m or closer
            -- we will just assume it applies, dont know the distance
            val = val + (passives.vinedusk == 1 and 2 or 5)
        end

        if passives.skilledTracker and data.fightersGuild then
            val = val + 10
        end

        if player.buffs.graveLordsSacrifice and (data.dot or data.necro) then
            --15% for dot or class ability FIXME level?
            val = val + 15
        end

        if (player.buffs.sunsphere or player.buffs.sunsphere2) and
          (data.templar or data.necro or data.dk or data.sorcerer or data.arcanist or data.nightblade or data.warden) then
            -- +5% with class abilities
            val = val + 5
        end

        if player.buffs.fieryBanner and data.dot then val = val + 6 end
        if player.buffs.magicalBanner and not isMartialDmgType then val = val + 6 end
        if player.buffs.shatteringBanner and data.aoe then val = val + 6 end
        if player.buffs.sunderingBanner and isMartialDmgType then val = val + 6 end
        if player.buffs.shockingBanner and data.direct then val = val + 6 end

    else
        self.analysis:AddWarningUnknownAbility(self.abilityId)
        self.dmgDoneValueKnown = false
    end

    if target.offBalance and player.cps.exp then val = val + 10 end

    if passives.worldInRuin and (self.damageType == DAMAGE_TYPE_FIRE or self.abilityId == DAMAGE_TYPE_POISON) then
        -- World in Ruin  2/5% dmg done with flame and poison
         val = val + (passives.worldInRuin == 1 and 2 or 5)
    end

    if passives.energized and (self.damageType == DAMAGE_TYPE_PHYSICAL or self.abilityId == DAMAGE_TYPE_SHOCK) then
        -- Energized 3/5% physical/shock dmg done
        val = val + (passives.energized == 1 and 3 or 5)
    end
    

    if passives.amplitude then
        if not self.enemyHpPercent then
            self.enemyHpKnown, self.enemyHpPercent =  self.analysis:GetEnemyHpPercent(self.timeMs, self.target.unitId)
        end
        if not self.enemyHpKnown then
            self.analysis:AddWarningUnknownEnemyHp(self.target.unitId)
            self.dmgDoneValueKnown = false
        else
            -- Amplitude 1% dmg done for every 20/10% current hp the target has
            val = val + math.floor(self.enemyHpPercent / (passives.amplitude == 1 and 0.2 or 0.1))
        end
    end

    --twilight tormentor  deals +50 on enemies over 50% but this is unique modifier
    --TODO hurricane deals 6% more every tick which stacks with dmgDone

    if player.bars.hasNecroSiphonSlotted[player.stats.activeBar] then
        val = val + 3
    end

    if (self.abilityId == 18084 or self.abilityId == 21929) then
        --Combustion, 16/33% dmg done with burning and poison status effect
        if passives.combustion then val = val + (passives.combustion == 1 and 16 or 33) end
    elseif self.abilityId == 20805 then
        -- molten whip stacks
        val = val + (player.buffs.seethingFuryWhipStacks and player.buffs.seethingFuryWhipStacks * 20 or 0)
    elseif self.abilityId == 117854 or self.abilityId == 117809 then
        -- boneyard is 30% more if a corpse is consumed which cant be checked
        -- so ill just assume it is always the case
        val = val + 30
    end


    if self.abilityId == 62912 or self.abilityId == 39054 or self.abilityId == 39056 then
        --blockade and wall dot/explosion 10% bonus to burning enemies
        if self.target.burning then val = val + 10 end
    elseif self.abilityId == 126633 then
        --azureblight seed
        --plus 30% per enemy hit up to 180%
        local c = self:GetEnemyHitCount(100, 300, 100)
        val = val + (c < 6 and c or 6) * 30
    elseif self.abilityId == 61502 then
        --proxy detonation: +100% for every target hit including original (i guess thats a bug in description)
        local c = self:GetEnemyHitCount(100, 300, 100)
        val = val + c * 100
    elseif self.abilityId == 39153 then
            --elemental ring shock plus 5% per enemy hit max 6 target
            local c = self:GetEnemyHitCount(100, 300, 100)
            val = val + (c < 6 and c or 6) * 5
    end

    if target.magicKnife and isMartialDmgType then
        val = val + 8
    end

    self.dmgDone = val
    self.dmgDoneModifier = val / 100 + 1
end

function Hit:ReCalcDmgToMonsters()
    local player = self.player
    local val = 0
    if player.gear.sets.ansuul and player.gear.sets.ansuul[player.stats.activeBar] then
        val = val + 7
    end
    if player.gear.sets.velothi and player.gear.sets.velothi[player.stats.activeBar] then
        val = val + 15
    end
    --FIXME is this bar independent or not?
    if player.buffs.ansulActive then val = val + 7 end
    self.dmgDoneToMonsters = val
    self.dmgDoneToMonstersModifier = val / 100 + 1
end

function Hit:ReCalcDmgTaken()
    local target = self.target
    local val = 0
    if target.minorVuln then val = val + 5 end
    if target.majorVuln then val = val + 10 end
    if target.abyssalInk then val = val + 5 end    --yes this is a debuff tooltip lies
    if target.mk then val = val + 8 end
    --TODO im not sure if this can be done more accurately unless the player is the source
    if target.zen then val = val + (target.zenStacks > 5 and 5 or target.zenStacks) end
    if target.bloodied and self.player.buffs.bloodhungry then val = val + 4 end

    if self.damageType == DAMAGE_TYPE_FIRE then
        if target.engulfing then
            val = val + 6
        end
        if target.encratis then
            val = val + 5
        end
    end


    if self.target.daedricPrey and Consts.sorcPetAbilities[self.abilityId] then
        --FIXME need to know which are the daedric summons...
        --Changelog: Daedric Prey: This ability now increases the damage your Daedric Summoning pets deal to the target by 50%, instead of increasing the damage all of your pets deal to the target by 45%.
        --Dev Comment: With subclassing here, we've had to adjust this ability to prevent it from becoming egregiously overpowered when paired with the maximum use case of pets. We've gone forward with a model that largely retains the power where it already lies, where it buffs Sorcerer's pets - and we've gone through and updated any item sets that summon a Daedric entity to be considered a Daedric Summon (Maw of the Infernal, Defiler, and Shadowrend) so they continue to work with this ability. This does mean that other summon based sets will no longer work with this effect, such as Morkuldin.
        val = val + 50
    end
    if self.target.incap or self.target.soulharvest then
        val = val + 20
    end
    self.dmgTaken = val
    self.dmgTakenModifier = val / 100 + 1
end

-- go back and forth in time and see how many hits we have with the same ability ID within a time window
-- maxTimeDiff max time between 2 hit which is considered the same hit
-- maxTotalTimeDiff: how long we go back and forward in time (so the window is 2 times this)
-- maxHit: how many hits we check in both directions
-- we need a fully parsed combat log prior to using this
function Hit:GetEnemyHitCount(maxTimeDiff, maxTotalTimeDiff, maxHits)

    local res = 1
    local fromMs = self.timeMs - maxTotalTimeDiff
    local toMs = self.timeMs + maxTotalTimeDiff
    local currMs = self.timeMs
    local hitToCheck = maxHits
    local otherHit = self.previousHit
    
--     debugPrint("---------------")
--     debugPrint("from %d to %d", fromMs, toMs)
--     debugPrint("%d %d %d %d %s %s",
--         hitToCheck,
--         otherHit and otherHit.timeMs or -1,
--         otherHit and (otherHit.timeMs + maxTimeDiff) or -1,
--         currMs,
--         otherHit and (otherHit.timeMs >= fromMs and "t" or "f") or "?",
--         otherHit and ((otherHit.timeMs + maxTimeDiff) >= currMs and "t" or "f") or "?"
--    )

    while hitToCheck > 0 and otherHit and otherHit.timeMs >= fromMs and (otherHit.timeMs + maxTimeDiff) >= currMs do
        if otherHit.abilityId == self.abilityId then
            res = res + 1
        end
        otherHit = otherHit.previousHit
        currMs = otherHit and otherHit.timeMs or -1
        hitToCheck = hitToCheck - 1

        -- debugPrint("%d %d %d %d %s %s",
        --     hitToCheck,
        --     otherHit and otherHit.timeMs or -1,
        --     otherHit and (otherHit.timeMs + maxTimeDiff) or -1,
        --     currMs,
        --     otherHit and (otherHit.timeMs >= fromMs and "t" or "f") or "?",
        --     otherHit and ((otherHit.timeMs + maxTimeDiff) >= currMs and "t" or "f") or "?"
        -- )

    end

    currMs = self.timeMs
    hitToCheck = maxHits
    otherHit = self.nextHit

    -- debugPrint("***********")
    -- debugPrint("%d %d %d %d %s %s",
    --     hitToCheck,
    --     otherHit and otherHit.timeMs or -1,
    --     otherHit and (otherHit.timeMs - maxTimeDiff) or -1,
    --     currMs,
    --     otherHit and (otherHit.timeMs <= toMs and "t" or "f") or "?",
    --     otherHit and ((otherHit.timeMs - maxTimeDiff) <= currMs and "t" or "f") or "?"
    -- )


    while hitToCheck > 0 and otherHit and otherHit.timeMs <= toMs and (otherHit.timeMs - maxTimeDiff) <= currMs do
        if otherHit.abilityId == self.abilityId then
            res = res + 1
        end
        otherHit = otherHit.nextHit
        currMs = otherHit and otherHit.timeMs or -1
        hitToCheck = hitToCheck - 1

        -- debugPrint("%d %d %d %d %s %s",
        --     hitToCheck,
        --     otherHit and otherHit.timeMs or -1,
        --     otherHit and (otherHit.timeMs - maxTimeDiff) or -1,
        --     currMs,
        --     otherHit and (otherHit.timeMs <= toMs and "t" or "f") or "?",
        --     otherHit and ((otherHit.timeMs - maxTimeDiff) >= currMs and "t" or "f") or "?"
        -- )

        
    end

    return res
end





function Hit:ReCalcWeaponDamage()
    local player = self.player
    local target = self.target
    local passives = self.player.passives or {}

    self.maxPool = math.max(player.stats.maxMagicka, player.stats.maxStamina)
    self.weaponDmgBonus = player.gear.mediumArmorBonus + player.bars.fgbonus[player.stats.activeBar]
    self.spellDmgBonus  = player.gear.mediumArmorBonus + player.bars.fgbonus[player.stats.activeBar]
    if player.buffs.minorSorcery then self.spellDmgBonus = self.spellDmgBonus + 10 end
    if player.buffs.majorSorcery then self.spellDmgBonus = self.spellDmgBonus + 20 end
    if player.buffs.minorBrutality then self.weaponDmgBonus = self.weaponDmgBonus + 10 end
    if player.buffs.majorBrutality then self.weaponDmgBonus = self.weaponDmgBonus + 20 end
    
    if passives.balancedWarrior then
        self.weaponDmgBonus = self.weaponDmgBonus + passives.balancedWarrior * 3
        self.spellDmgBonus = self.spellDmgBonus + passives.balancedWarrior * 3
    end
    -- arca harnessedQuintessence and sorc export mage was changed to flat amount in U46

    --apparentWeaponDmg is just the value reported by the game (higher of weapon / sp)
    if player.stats.spellDmg > player.stats.weaponDmg then
        self.apparentWeaponDmg = player.stats.spellDmg
    else
        self.apparentWeaponDmg = player.stats.weaponDmg
    end

    -- effective will be the "hidden" one with other bonuses
    -- btw some of these effect the tooltip some not, but that doesnt matter here
    self.effectiveWeaponDmg = self.apparentWeaponDmg


    local cpPassive =
        (player.cps.warmage and (
           self.damageType == DAMAGE_TYPE_MAGIC or
           self.damageType == DAMAGE_TYPE_FIRE or
           self.damageType == DAMAGE_TYPE_COLD or
           self.damageType == DAMAGE_TYPE_SHOCK))
           or
        (player.cps.mighty and (
            self.damageType == DAMAGE_TYPE_PHYSICAL or
            self.damageType == DAMAGE_TYPE_POISON or
            self.damageType == DAMAGE_TYPE_DISEASE or
            self.damageType == DAMAGE_TYPE_BLEED))

    self.weaponDmgBonusModifier = 1 + self.weaponDmgBonus/100
    self.effectiveWeaponDmgKnown = true
    if cpPassive then
        self.effectiveWeaponDmg = self.effectiveWeaponDmg + 100 * self.weaponDmgBonusModifier
    end

    if player.cps.ws then
        self.effectiveWeaponDmg = self.effectiveWeaponDmg + 205 * self.weaponDmgBonusModifier
    end

    if player.gear.bloodThristyValue and player.gear.bloodThristyValue > 0 then
        if not self.enemyHpPercent then
            self.enemyHpKnown, self.enemyHpPercent =  self.analysis:GetEnemyHpPercent(self.timeMs, self.target.unitId)
        end
        -- debugPrint("BT: %s %f", tostring(known), enemyHpPercent)
        if not self.enemyHpKnown then
            self.analysis:AddWarningUnknownEnemyHp(self.target.unitId)
            self.effectiveWeaponDmgKnown = false
        else
            self.effectiveWeaponDmg = self.effectiveWeaponDmg + Utils.GetBloodThirstyValue(self.enemyHpPercent, player.bloodThristyValue)
        end
    end

    if player.gear.arenaSets.mastersBow then
        if target.poisonInjection then
            self.effectiveWeaponDmg = self.effectiveWeaponDmg + 330 * self.weaponDmgBonusModifier
        end
    end

    if player.buffs.bannerCavaliersCharge then
        self.analysis:AddWarningOther("Banner with Cavalier's Charge is active, this may cause inaccurate results")
    end

end


function Hit:ReCalcModifiers()
    self:ReCalcPen()
    self:ReCalcCritDmg()
    self:ReCalcWeaponDamage()
    self:ReCalcDmgDone()
    self:ReCalcDmgToMonsters()
    self:ReCalcDmgTaken()
end

local function recalcPenchanged(oldHit, newHit)
    newHit:ReCalcPen()
    newHit.value = math.floor(oldHit.value * newHit.armorModifier / oldHit.armorModifier)
    return newHit
end

local function recalcCritDmgChanged(oldHit, newHit)
    newHit:ReCalcCritDmg()
    if not newHit.isCrit then return newHit end
    newHit.value = math.floor(oldHit.value * newHit.critDmgModifier / oldHit.critDmgModifier)
    return newHit
end

local function recalcTargetDmgTakenChanged(oldHit, newHit)
    newHit:ReCalcDmgTaken()
    newHit.value =  math.floor(oldHit.value * newHit.dmgTakenModifier / oldHit.dmgTakenModifier)
    return newHit
end

local function recalcPlayerDamageDoneChanged(oldHit, newHit)
    newHit:ReCalcDmgDone()
    if newHit.dmgDoneValueKnown then
        newHit.value =  math.floor(oldHit.value * newHit.dmgDoneModifier / oldHit.dmgDoneModifier)
    elseif not newHit.error then
        newHit.analysis:AddWarningDamageDone(newHit.abilityId)
        newHit.error = true
    end
    return newHit
end

local function recalcPlayerDamageDoneToMonstersChanged(oldHit, newHit)
    newHit:ReCalcDmgToMonsters()
    newHit.value =  math.floor(oldHit.value * newHit.dmgDoneToMonstersModifier / oldHit.dmgDoneToMonstersModifier)
    return newHit
end

local function recalcWeaponDamageChanged(oldHit, newHit)
    newHit:ReCalcWeaponDamage()
    if newHit.effectiveWeaponDmgKnown then
        local data = Consts.abilityTable[newHit.abilityId]
        if not data and not newHit.error then
            newHit.analysis:AddWarningUnknownAbility(newHit.abilityId)
            newHit.error = true
        else
            local procSetData = Consts.procsets[newHit.abilityId]
            if not procSetData then
                -- effective pool scaling abilities
                local effectivePoolOld = oldHit.maxPool + 10.5 * oldHit.effectiveWeaponDmg
                local effectivePoolNew = newHit.maxPool + 10.5 * newHit.effectiveWeaponDmg
                -- debugPrint("wepdmgch %d->%d %d->%d",
                --      oldHit.effectiveWeaponDmg, newHit.effectiveWeaponDmg,
                --      effectivePoolOld, effectivePoolNew
                -- )
                newHit.value = math.floor(oldHit.value * (effectivePoolNew / effectivePoolOld))
            else
                -- pure weapon dmg scaling abilities ( proc sets )
                local oldValue = oldHit.effectiveWeaponDmg
                local newValue = newHit.effectiveWeaponDmg
                -- debugPrint("Procset change wdmg: %d -> %d tooltip: %d -> %d", 
                --     oldHit.effectiveWeaponDmg,
                --     newHit.effectiveWeaponDmg,
                --     oldValue,
                --     newValue
                -- )
                newHit.value = oldHit.value * newValue / oldValue
            end
        end
    else
        newHit.error = true
    end
    return newHit
end

function Hit:ChangeCpFF(isActive)
    local o = self:Copy({stats = true, cps = true}, false)
    if isActive and not o.player.cps.ff then
        o.player.stats.critDmg = o.player.stats.critDmg + 8
        o.player.cps.ff = true
    elseif not isActive and o.player.cps.ff then
        o.player.stats.critDmg = o.player.stats.critDmg - 8
        o.player.cps.ff = nil
    end
    return recalcCritDmgChanged(self, o)
end

function Hit:ChangeCpBS(isActive)
    local o = self:Copy({stats = true, cps = true}, false)
    if isActive and not o.player.cps.bs then
        o.player.stats.critDmg = o.player.stats.critDmg + 10
        o.player.cps.bs = true
    elseif not isActive and o.player.cps.bs then
        o.player.stats.critDmg = o.player.stats.critDmg - 10
        o.player.cps.bs = nil
    end
    return recalcCritDmgChanged(self, o)
end

function Hit:ChangeCpEXP(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.exp = isActive or nil
    return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeCpDA(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.da = isActive or nil
    return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeCpBA(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.ba = isActive or nil
    return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeCpTH(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.th = isActive or nil
    return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeCpMAA(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.maa = isActive or nil
    return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeCpWS(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.ws = isActive or nil
    return recalcWeaponDamageChanged(self, o)
end

function Hit:ChangeCpUA(isActive)
    local o = self:Copy({stats = true, cps = true}, false)
    if isActive and not o.player.cps.ua then
        o.player.cps.ua = true
        o.player.stats.weaponDmg = o.player.stats.weaponDmg + 150 * self.weaponDmgBonusModifier
        o.player.stats.spellDmg  = o.player.stats.spellDmg  + 150 * self.weaponDmgBonusModifier
    elseif not isActive and o.player.cps.ua then
        o.player.cps.ua = nil
        o.player.stats.weaponDmg = o.player.stats.weaponDmg - 150 * self.weaponDmgBonusModifier
        o.player.stats.spellDmg  = o.player.stats.spellDmg  - 150 * self.weaponDmgBonusModifier
    end
    return recalcWeaponDamageChanged(self, o)
end

function Hit:ChangeCpFON(isActive)
    local o = self:Copy({cps = true}, false)
    o.player.cps.fon = isActive or nil
    return recalcPenchanged(self, o)
end

function Hit:ChangeCp(cp, isActive)
    if cp == "ff" then return self:ChangeCpFF(isActive) end
    if cp == "bs" then return self:ChangeCpBS(isActive) end
    if cp == "exp" then return self:ChangeCpEXP(isActive) end
    if cp == "da" then return self:ChangeCpDA(isActive) end
    if cp == "ba" then return self:ChangeCpBA(isActive) end
    if cp == "th" then return self:ChangeCpTH(isActive) end
    if cp == "maa" then return self:ChangeCpMAA(isActive) end
    if cp == "ws" then return self:ChangeCpWS(isActive) end
    if cp == "ua" then return self:ChangeCpUA(isActive) end
    if cp == "fon" then return self:ChangeCpFON(isActive) end
end

function Hit:ChangeBuff(buffkey, isActive, recalcFunction)
    local buff = self.player.buffs[buffkey]
    if (isActive and not buff) or (not isActive and buff) then
        local o = self:Copy({buffs = true}, false)
        o.player.buffs[buffkey] = isActive or nil
        return recalcFunction(self, o)
    end
    return self
end



function Hit:ChangeBuffMinorSlayer(isActive)
    return self:ChangeBuff("minorSlayer", isActive, recalcPlayerDamageDoneChanged)
    -- local o = self:Copy()
    -- o.player.buffs.minorSlayer = isActive or nil
    -- return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeBuffMajorSlayer(isActive)
    return self:ChangeBuff("majorSlayer", isActive, recalcPlayerDamageDoneChanged)
    -- local o = self:Copy()
    -- o.player.buffs.majorSlayer = isActive or nil
    -- return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeBuffMinorBerserk(isActive)
    return self:ChangeBuff("minorBerserk", isActive, recalcPlayerDamageDoneChanged)
    -- local o = self:Copy()
    -- o.player.buffs.minorBerserk = isActive or nil
    -- return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeBuffMajorBerserk(isActive)
    return self:ChangeBuff("majorBerserk", isActive, recalcPlayerDamageDoneChanged)
    -- local o = self:Copy()
    -- o.player.buffs.majorBerserk = isActive or nil
    -- return recalcPlayerDamageDoneChanged(self, o)
end

function Hit:ChangeBuffGenericWeaponDmg(buffkey, isActive, value)

    local buff = self.player.buffs[buffkey]
    if (isActive and not buff) or (not isActive and buff) then
        local o = self:Copy({buffs = true, stats = true}, false)
        o.player.buffs[buffkey] = isActive or nil
        o.player.stats.weaponDmg = o.player.stats.weaponDmg + (isActive and value or -value) * self.weaponDmgBonusModifier
        o.player.stats.spellDmg  = o.player.stats.spellDmg  + (isActive and value or -value) * self.weaponDmgBonusModifier
        -- debugPrint("ChangeBuffGenericWeaponDmg %d -> %d", self.player.stats.weaponDmg, o.player.stats.weaponDmg)
        return recalcWeaponDamageChanged(self, o)
    end
    return self
end

function Hit:ChangeBuffGenericCritDmg(buffkey, isActive, value)

    local buff = self.player.buffs[buffkey]
    if (isActive and not buff) or (not isActive and buff) then
        local o = self:Copy({buffs = true, stats = true}, false)
        o.player.buffs[buffkey] = isActive or nil
        o.player.stats.critDmg = o.player.stats.critDmg + (isActive and value or -value)
        o.player.stats.critDmg  = o.player.stats.critDmg  + (isActive and value or -value)
        -- debugPrint("ChangeBuffGenericWeaponDmg %d -> %d", self.player.stats.weaponDmg, o.player.stats.weaponDmg)
        return recalcCritDmgChanged(self, o)
    end
    return self
end

function Hit:ChangeBuffAggressiveHorn(isActive)
    -- return self:ChangeBuffGenericWeaponDmg("aggressiveHorn", isActive, 260)
    if (isActive and not self.player.buffs.aggressiveHorn) or
    (not isActive and self.player.buffs.aggressiveHorn) then
        local o = self:Copy({buffs = true, stats = true}, false)
        o.player.buffs.aggressiveHorn = isActive or nil
        local baseMaxMag = self.player.stats.maxMagicka / ( 1 + ((self.player.gear.undauntedMettle + (self.player.buffs.aggressiveHorn and 10 or 0) / 100) ))
        local baseMaxStam = self.player.stats.maxStamina / ( 1 + ((self.player.gear.undauntedMettle + (self.player.buffs.aggressiveHorn and 10 or 0) / 100) ))
        o.player.stats.maxMagicka = baseMaxMag *  ( 1 + ((o.player.gear.undauntedMettle + (o.player.buffs.aggressiveHorn and 10 or 0) / 100) ))
        o.player.stats.maxStamina = baseMaxStam * ( 1 + ((o.player.gear.undauntedMettle + (o.player.buffs.aggressiveHorn and 10 or 0) / 100) ))
        return recalcWeaponDamageChanged(self, o)
    end


    return self
end

function Hit:ChangeBaseWeaponDamage(value)
    local o = self:Copy({stats = true}, false)
    o.player.stats.weaponDmg = o.player.stats.weaponDmg + value * self.weaponDmgBonusModifier
    o.player.stats.spellDmg  = o.player.stats.spellDmg  + value * self.weaponDmgBonusModifier
    return recalcWeaponDamageChanged(self, o)
end

function Hit:ChangePenOffset(val)
    local o = self:Copy(false, false)
    o.penetrationOffset = val
    return recalcPenchanged(self, o)
end

function Hit:AddLightArmorPiece()
    --TODO undaunted mettle
    if self.player.gear.numLightArmor < 7 then
        local o = self:Copy({gear = true}, false)
        o.player.gear.numLightArmor = o.player.gear.numLightArmor + 1
        o.player:ReCalcBonuses()
        o.penetrationOffset = (o.penetrationOffset or 0) + 939
        return recalcPenchanged(self, o)
    end
    return self
end

function Hit:RemoveLightArmorPiece()
    --TODO undaunted mettle
    if self.player.gear.numLightArmor > 0 then
        local o = self:Copy({gear = true}, false)
        o.player.gear.numLightArmor = o.player.gear.numLightArmor - 1
        o.player:ReCalcBonuses()
        o.penetrationOffset = (o.penetrationOffset or 0)- 939
        return recalcPenchanged(self, o)
    end
    return self
end

function Hit:AddMediumArmorPiece()
    --TODO undaunted mettle
    if self.player.gear.numMediumArmor < 7 then
        local o = self:Copy({gear = true, stats = true}, false)
        o.player.gear.numMediumArmor = o.player.gear.numMediumArmor + 1
        o.player.stats.critDmg = o.player.stats.critDmg + 2
        o.player:ReCalcBonuses()
        o:ReCalcWeaponDamage()
        local old = (1 + self.weaponDmgBonus) / 100
        local new = (1 + o.weaponDmgBonus) / 100
        o.player.stats.weaponDmg = o.player.stats.weaponDmg / old * new
        o.player.stats.spellDmg = o.player.stats.spellDmg / old * new
        local hit = recalcWeaponDamageChanged(self, o)
        return recalcCritDmgChanged(self, hit)
    end
    return self
end

function Hit:RemoveMediumArmorPiece()
    --TODO undaunted mettle
    if self.player.gear.numMediumArmor > 0 then
        local o = self:Copy({gear = true, stats = true}, false)
        o.player.gear.numMediumArmor = o.player.gear.numMediumArmor - 1
        o.player.stats.critDmg = o.player.stats.critDmg - 2
        o.player:ReCalcBonuses()
        o:ReCalcWeaponDamage()
        local old = (1 + self.weaponDmgBonus) / 100
        local new = (1 + o.weaponDmgBonus) / 100
        o.player.stats.weaponDmg = o.player.stats.weaponDmg / old * new
        o.player.stats.spellDmg = o.player.stats.spellDmg / old * new
        local hit = recalcWeaponDamageChanged(self, o)
        return recalcCritDmgChanged(self, hit)
    end
    return self
end

function Hit:ChangeDebuffStagger(newStacks)
    local oldStacks = self.target.staggerStacks or 0
    -- debugPrint("ChangeDebuffStagger %d %d %d", oldValue, newValue, newStacks)
    if oldStacks ~= newStacks then
        --no dmg done modifier here!
        local oldValue = oldStacks * 65 * self.dmgTakenModifier * self.armorModifier
        local newValue = newStacks * 65 * self.dmgTakenModifier * self.armorModifier
        if self.isCrit then
            oldValue = oldValue * self.critDmgModifier
            newValue = newValue * self.critDmgModifier
        end

        if self.value > oldValue then
            local o = self:Copy(false, true)
            o.target.staggerStacks = newStacks
            o.value = math.floor(o.value - oldValue + newValue)
            return o
        end
    end
    return self
end

function Hit:ChangeDebuff(debuffkey, isActive, recalcFunction)
    local debuff = self.target[debuffkey]
    if (isActive and not debuff) or (not isActive and debuff) then
     local o = self:Copy(false, true)
     o.target[debuffkey] = isActive or nil
     return recalcFunction(self, o)
    end
    return self
end

function Hit:ChangeDebuffZen(isActive)
    --TODO stacks if possible
    return self:ChangeDebuff("zen", isActive, recalcTargetDmgTakenChanged)
end

function Hit:ChangeDebuffMk(isActive)
    return self:ChangeDebuff("mk", isActive, recalcTargetDmgTakenChanged)
end

function Hit:ChangeDebuffPoisonInjection(isActive)
    -- masters bow can change our weapon damage based on this debuff
    return self:ChangeDebuff("poisonInjection", isActive, recalcWeaponDamageChanged)
end



function Hit:ChangeSet(setname, bar, isActive)
    -- debugPrint("ChangeSet %s %d %s %s", setname, bar, tostring(isActive),
    --     tostring(o.player:HasSet(setname, bar))
    --     -- tostring(o.player.gear.sets[bar])
    -- )
    local change = (isActive and not self.player:HasSet(setname, bar)) or (not isActive and self.player:HasSet(setname, bar))
    if change and self.player.stats.activeBar == bar then
        local o = self:Copy({gear = true, stats = true}, false)
        o.player.gear.sets[setname][bar] = isActive
        if setname == "deadly" then
            return recalcPlayerDamageDoneChanged(self, o)
        elseif setname == "coral" then
            local known, stamPerc = self.analysis:GetPlayerStaminaPercent(self.timeMs)
            if not known and not o.error then
                o.analysis:AddWarningOther("Cannot calculate coral riptide:\nUnknown player stamina")
                o.error = true
                return o
            else
                local value = Utils.GetCoralRiptideValue(stamPerc)
                o.player.stats.weaponDmg = o.player.stats.weaponDmg + (isActive and value or -value) * self.weaponDmgBonusModifier
                o.player.stats.spellDmg  = o.player.stats.spellDmg  + (isActive and value or -value) * self.weaponDmgBonusModifier
                return recalcWeaponDamageChanged(self, o)
            end
        else
            
            logger:Error("ChangeSet Unknown set %s", setname)
        end
    end
    return self
end

function Hit:ChangeSetVelothi(isActive)
    -- debugPrint("ChangeSet %s %d %s %s", setname, bar, tostring(isActive),
    --     tostring(o.player:HasSet(setname, bar))
    --     -- tostring(o.player.gear.sets[bar])
    -- )
    local wasActive = self.player:HasSet("velothi", 1) or self.player:HasSet("velothi", 2)
    local change = isActive ~= wasActive
    if change then
        local o = self:Copy({gear = true, stats = true}, false)
        o.player.gear.sets["velothi"][1] = isActive
        o.player.gear.sets["velothi"][2] = isActive
        local o2 = recalcPlayerDamageDoneToMonstersChanged(self, o)
        o = o2:Copy(false, false)
        o.penetrationOffset = (o.penetrationOffset or 0) + (isActive and 1650 or -1650)
        o = recalcPenchanged(o2, o)
        local data = Consts.abilityTable[self.abilityId]
        if data then
            if data.basicAttack then
                -- velothi applies a unique 99% modifier (ie not stacking with dmg done or anything)
                -- FIXME light attack hit cap not taken into account
                --https://forums.elderscrollsonline.com/en/discussion/629071/pc-mac-patch-notes-v8-3-5#latest
                --introduced a stat scaling limit on these attacks so they stop benefitting from Weapon or Spell Damage
                -- and Magicka or Stamina after reaching 3850 damage for weapons and 4813 for Werewolf.
                if isActive then
                    o.value = math.floor(o.value * 0.01)
                else
                    o.value = math.floor(o.value / 0.01)
                end
            end
            return o
        elseif not o.error then
            o.analysis:AddWarningUnknownAbility(o.abilityId)
            o.error = true
        end
    end
    return self
end

function Hit:ChangeStaminaPercentForCoral(newPercent, bar)
    if self.player.stats.activeBar == bar and self.player:HasSet("coral", self.player.stats.activeBar) then
        local o = self:Copy({stats = true}, false)
        local known, stamPerc = self.analysis:GetPlayerStaminaPercent(self.timeMs)
        if not known and not o.error then
            o.analysis:AddWarningOther("Cannot calculate coral riptide:\nUnknown player stamina")
            o.error = true
            return o
        else
            local valueOld = Utils.GetCoralRiptideValue(stamPerc)
            local valueNew = Utils.GetCoralRiptideValue(newPercent)
            o.player.stats.weaponDmg = o.player.stats.weaponDmg - valueOld * self.weaponDmgBonusModifier + valueNew * self.weaponDmgBonusModifier
            o.player.stats.spellDmg  = o.player.stats.spellDmg  - valueOld * self.weaponDmgBonusModifier + valueNew * self.weaponDmgBonusModifier
            return recalcWeaponDamageChanged(self, o)
        end
    end
    return self
end

function Hit:ChangeSetArenaWeapon(setname, isActive)
    local hasSet = self.player.gear.arenaSets[setname]
    local change = (isActive and not hasSet) or (not isActive and hasSet)
    -- debugPrint("%s %s %s", setname, tostring(hasSet), tostring(change))
    if change then
        local o = self:Copy({gear = true}, false)
        o.player.gear.arenaSets[setname] = isActive
        if setname == "mastersBow" then
            return recalcWeaponDamageChanged(self, o)
        elseif setname == "maCrushingWall" then
            -- fire, shock dots and explosions
            if o.abilityId == 62912 or
            o.abilityId == 39054 or
            o.abilityId == 39056 or
            o.abilityId == 62990 or
            o.abilityId == 39079 or
            o.abilityId == 39080 then
                if o.dmgDoneValueKnown then
                    local value = 1250 * o.dmgDoneModifier * o.dmgDoneToMonstersModifier * o.dmgTakenModifier * o.armorModifier
                    if o.isCrit then
                        value = value * o.critDmgModifier
                    end
                    -- debugPrint("Diff %d", value)
                    o.value = o.value + (hasSet and -value or value)
                elseif not o.error then
                    o.analysis:AddWarningDamageDone(o.abilityId)
                    o.error = true
                end
                return o
            end
        else
            logger:Error("ChangeSetArenaWeapon Unknown set %s", setname)
        end
    end
    return self
end

function Hit:ChangeMercilessCharge(isActive)
    return self:ChangeBuff("mercilessCharge", isActive, recalcPlayerDamageDoneChanged)
end

function Hit:ChangeSetKilt(isActive)
    if isActive then
        if self.player.buffs.huntersFocusStacks ~= 10 then
            local o = self:Copy({buffs = true, stats = true}, false)
            o.player.buffs.huntersFocusStacks = 10
            o.player.stats.critDmg = self.player.stats.critDmg - (self.player.buffs.huntersFocusStacks or 0) + 10
            return recalcCritDmgChanged(self, o)
        end
    else
        if self.player.buffs.huntersFocusStacks and self.player.buffs.huntersFocusStacks > 0 then
            local o = self:Copy({buffs = true, stats = true}, false)
            o.player.buffs.huntersFocusStacks = 0
            o.player.stats.critDmg = self.player.stats.critDmg - self.player.buffs.huntersFocusStacks
            return recalcCritDmgChanged(self, o)
        end
    end
    return self
end




local playerBuffsCalcFunctions =
{
        -- dmg done
        minorBerserk = recalcPlayerDamageDoneChanged,
        majorBerserk = recalcPlayerDamageDoneChanged,
        minorSlayer = recalcPlayerDamageDoneChanged,
        majorSlayer = recalcPlayerDamageDoneChanged,
        graveLordsSacrifice = recalcPlayerDamageDoneChanged,
        -- crit dmg
        -- minorForce = recalcCritDmgChanged,
        -- majorForce = recalcCritDmgChanged,
        -- weapon dmg
        -- minorSorcery = recalcWeaponDamageChanged,
        -- minorBrutality = recalcWeaponDamageChanged,
        -- majorSorcery = recalcWeaponDamageChanged,
        -- majorBrutality = recalcWeaponDamageChanged,
        -- resource
        -- sets
        ansulActive = recalcPlayerDamageDoneToMonstersChanged,
        -- arena
        spectralCloak = recalcPlayerDamageDoneChanged,
        bloodhungry = recalcTargetDmgTakenChanged,
        fieryBanner = recalcPlayerDamageDoneChanged,
        magicalBanner = recalcPlayerDamageDoneChanged,
        shatteringBanner = recalcPlayerDamageDoneChanged,
        sunderingBanner = recalcPlayerDamageDoneChanged,
        shockingBanner = recalcPlayerDamageDoneChanged,
    }

local playerBuffsSpecialFunctions =
{
    minorCourage = function(isActive, hit) return hit:ChangeBuffGenericWeaponDmg("minorCourage", isActive, 215) end,
    majorCourage = function(isActive, hit) return hit:ChangeBuffGenericWeaponDmg("majorCourage", isActive, 430) end,
    powerfulAssault = function(isActive, hit) return hit:ChangeBuffGenericWeaponDmg("powerfulAssault", isActive, 307) end,
    auraOfPride = function(isActive, hit) return hit:ChangeBuffGenericWeaponDmg("auraOfPride", isActive, 260) end,
    weaponDmgEnchant = function(isActive, hit) return hit:ChangeBuffGenericWeaponDmg("weaponDmgEnchant", isActive, 452) end,
    sunderer = function(isActive, hit) return hit:ChangeBuffGenericWeaponDmg("sunderer", isActive, 100) end,
    aggressiveHorn = function(isActive, hit) return hit:ChangeBuffAggressiveHorn(isActive) end,
    minorForce = function(isActive, hit) return hit:ChangeBuffGenericCritDmg("minorForce", isActive, 10) end,
    majorForce = function(isActive, hit) return hit:ChangeBuffGenericCritDmg("majorForce", isActive, 20) end,
    sulxan = function(isActive, hit) return hit:ChangeBuffGenericCritDmg("sulxan", isActive, 12) end,
}

function Hit:ChangePlayerBuff(buffkey, isActive)
    local buff = self.player.buffs[buffkey]
    if (isActive and not buff) or (not isActive and buff) then
        local f = playerBuffsCalcFunctions[buffkey]
        if f then
            -- simple calculation, update table then recalc with modifiers
            local o = self:Copy({buffs = true}, false)
            o.player.buffs[buffkey] = isActive or nil
            return f(self, o)
        else
            f = playerBuffsSpecialFunctions[buffkey]
            if f then
                -- a bit more complicated one
                return f(isActive, self)
            else
                local o = self:Copy(false, false)
                local s = string.format("Unhandled buff: \"%s\"", buffkey)
                o.analysis:AddWarningOther(s)
                o.error = true
                logger:Error(s)
                return o
            end
        end
    end
    return self
end

local debuffsCalcFunctions = 
{
    minorBreach = recalcPenchanged,
    majorBreach = recalcPenchanged,
    crusher = recalcPenchanged,
    alkosh = recalcPenchanged,
    crimsonOath = recalcPenchanged,
    tremorscale = recalcPenchanged,
    crystalWeapon = recalcPenchanged,
    runicSunder = recalcPenchanged,
    minorBrittle = recalcCritDmgChanged,
    majorBrittle = recalcCritDmgChanged,
    flameWeakness = recalcCritDmgChanged,
    frostWeakness = recalcCritDmgChanged,
    shockWeakness = recalcCritDmgChanged,
    minorVuln = recalcTargetDmgTakenChanged,
    majorVuln = recalcTargetDmgTakenChanged,
    engulfing = recalcTargetDmgTakenChanged,
    encratis = recalcTargetDmgTakenChanged,
    abyssalInk = recalcTargetDmgTakenChanged,
    zen = recalcTargetDmgTakenChanged,
    mk = recalcTargetDmgTakenChanged,
    bloodied = recalcTargetDmgTakenChanged,
    magicKnife = recalcPlayerDamageDoneChanged, --yes this is not a 'damage taken' like the tooltip says
}

local debuffsSpecialFunctions = 
{

}

function Hit:ChangeTargetDebuff(debuffkey, isActive)
    local debuff = self.target[debuffkey]
    if (isActive and not debuff) or (not isActive and debuff) then
        local f = debuffsCalcFunctions[debuffkey]
        if f then
            -- simple calculation, update table then recalc with modifiers
            local o = self:Copy(false, true)
            o.target[debuffkey] = isActive or nil
            return f(self, o)
        else
            f = debuffsSpecialFunctions[debuffkey]
            if f then
                -- a bit more complicated one
                return f(isActive, self)
            else
                local o = self:Copy(false, false)
                local s = string.format("Unhandled debuff: \"%s\"", debuffkey)
                o.analysis:AddWarningOther(s)
                o.error = true
                logger:Error(s)
                return o
            end
        end
    end
    return self
end
