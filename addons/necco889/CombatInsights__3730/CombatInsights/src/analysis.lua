CombatInsightsAnalysis = CombatInsightsAnalysis or {}
local Analysis = CombatInsightsAnalysis
local Targets = CombatInsightsTargets
local Fights = CombatInsightsFights
local Player = CombatInsightsPlayer
local Calculation = CombatInsightsCalculation
local Hit = CombatInsightsHit


local function debugPrint(message, ...)
    df("[CiA]: %s", message:format(...))
end

--FIXME remove diffTableCfg
function Analysis:New(fightDataImport, calculationConfigs)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.cmxFightDataImport = fightDataImport
    o.cmxFight = fightDataImport[1]
    o.cmxSelection = fightDataImport[2]
    o.warnings =
    {
        unknownAbilities = {},
        unknownEnemyHp = {},
        damageDone = {},
        weaponDmg = {},
        other = {},
    }
    o.progressTxt = ""
    o.progressPercent = 0
    o.hpCache = {}
    o.hpquery = 0       --FIXME REMOVE
    if o.cmxFight then
        o.trialDummyIds = {}
        for k,u in pairs(o.cmxFight.units) do
            if u.isTrialDummy then
                o.trialDummy = true
                o.trialDummyIds[k] = true
            end
        end
        o.cmxLog = o.cmxFight.log
        if o.cmxLog then
            o.player = Player:New()
            o.targets = Targets:New()
            -- CMX sometimes merges more fights together and doesnt detect combat end
            -- so we cant get a 1 to 1 relation like this or the hp lookup will fail
            -- o.additionalFightData = Fights.GetFightByStartTime(o.cmxFight.date)
            -- as a temporary workaround ill collect all the fights that are contained within the cmx logs timespan
            o.additionalFightDatas = Fights.GetFightsBetweenDates(o.cmxFight.date, o.cmxFight.date + math.floor((o.cmxFight.combatend - o.cmxFight.combatstart) / 1000))
            o.hits = {}
            
            o.player:InitBasics(o.cmxFight.charData)
            o.player:ParseItems(o.cmxFight.charData.equip)
            o.player:InitCps(o.cmxFight.CP)
            o.player:InitBars(o.cmxFight.charData.skillBars, o.cmxLog)
            if o.additionalFightDatas and o.additionalFightDatas[1] then
                if o.additionalFightDatas[1].dataVersion ~= CombatInsightsConsts.FIGHT_DATA_VERSION then
                    o:AddWarningOther("Additional fight version mismatch")
                end
                o.player.passives = o.additionalFightDatas[1].playerPassives
            else
                o:AddWarningOther("Additional fight data missing")
            end

            -- o.loopdata = {}
            -- o.loopdata.startIndex = 1
            -- o.loopdata.remaining = #o.cmxFight.log

            o.calculations = {}
            for _,cfg in ipairs(calculationConfigs) do
                if cfg.predicate and cfg.predicate(o.player) then
                    table.insert(o.calculations, Calculation:New(cfg))
                end
            end
        else
            o.error = "Missing LibCombat log for selected fight"
        end
    else
        o.error = "Fight data missing from fight"
    end
    return o
end



function Analysis:ProcessLogLine(lineIndex)
    if not self.error then
        self.progressTxt = "Reading combat log"
        self.logLineIndex = lineIndex
        -- debugPrint("lineidx : %d", lineIndex)
        self.progressPercent = lineIndex / #self.cmxLog

        local player = self.player
        -- self.loopdata.currentIndex = lineIndex
         local logline = self.cmxLog[lineIndex]
        -- local text, color = CMX.GetCombatLogString(fight, logline, 14)
        local logtype = logline[1]
        local timeMs = logline[2]
        
        if logtype == LIBCOMBAT_EVENT_DAMAGE_OUT then
            local _, _, result, _, targetUnitId, abilityId, hitValue, damageType, overflow = unpack(logline)
            --FIXME handle absorbs ?
            local t = self.targets:Get(targetUnitId)
            local isCrit = (result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL)
            local hit = Hit:New(self, #self.hits + 1, timeMs, hitValue, isCrit, abilityId, player:Copy(), t:Copy(), damageType)
    
            table.insert(self.hits, hit)
            local numHits = #self.hits
            if numHits > 1 then
                self.hits[numHits].previousHit = self.hits[numHits-1]
                self.hits[numHits-1].nextHit = self.hits[numHits]
            end
            
        elseif logtype == LIBCOMBAT_EVENT_EFFECTS_IN or logtype == LIBCOMBAT_EVENT_GROUPEFFECTS_IN then
            -- local _, _, unitId, abilityId, changeType, effectType, stacks, sourceType, slot = unpack(logline)
            player:HandleBuffEvent(self.cmxFight, logline, self.trialDummy)
            
        elseif logtype == LIBCOMBAT_EVENT_EFFECTS_OUT or logtype == LIBCOMBAT_EVENT_GROUPEFFECTS_OUT then
            local _, _, unitId, abilityId, changeType, effectType, stacks, sourceType, slot = unpack(logline)
            self.targets:HandleDebuffEvent(self, logline, self.trialDummy and self.trialDummyIds[unitId])
        
        elseif logtype == LIBCOMBAT_EVENT_PLAYERSTATS then
            player:HandleStatChange(logline)
            
        elseif logtype == LIBCOMBAT_EVENT_MESSAGES then
            local message = logline[3]
            local bar = logline[4]
            if message == LIBCOMBAT_MESSAGE_WEAPONSWAP then
                if bar ~= nil and bar > 0 then
                    player:BarswapTo(bar)
                end
            end
            
        -- this is not needed im tracking the boss hp seperately
        -- elseif logtype == LIBCOMBAT_EVENT_BOSSHP then
            -- player:HandleStatChange(logline)
            -- local _, _, bossId, currenthp, maxhp = unpack(logline)
            -- debugPrint("BoosHP id %d curr: %d max: %d", bossId, currenthp, maxhp)
            -- local unitId = fight.bosses[bossId]
            -- local bossName = units[unitId].name
            -- local percent = zo_round(currenthp/maxhp * 100)
            
        -- elseif logtype == LIBCOMBAT_EVENT_RESOURCES then
        end
    end
end


-- this must be called when the full list is parsed
-- because only this way we can detect how many enemies were hit by the same ability
-- for now i wont make it a task because the performance is pretty good
function Analysis:CalculateBaseHits()
    if not self.error then
        self.progressTxt = "Calculating original hit parameters"
        for i=1,#self.hits do
            self.progressPercent = i / #self.hits
            self.hits[i]:ReCalcModifiers()
        end
    end
end

-- do one calculation for one hit
-- this is called by LibAsync in the background
function Analysis.ProcessHitDiff(self, hitIndex, calculationIndex)
    if not self.error then
        self.progressTxt = "Calculating differences"
        self.progressPercent = hitIndex / #self.hits
        -- self.loopdata.currentHitIndex = hitIndex

        local hit = self.hits[hitIndex]
        local calculation = self.calculations[calculationIndex]

        if calculation then
            if calculation.config.fUptimeExtractor then
                calculation.uptimeCounter:NewSample(calculation.config.fUptimeExtractor(hit), hit.target.unitId, hit.abilityId)
            end
            if calculation.cmpForCurrentGain then
                calculation.cmpForCurrentGain:Hit(hit, calculation.config.tfCurrentGain(hit), hit.target.unitId, hit.abilityId)
            end
            if calculation.cmpForPossibleGain then
                calculation.cmpForPossibleGain:Hit(hit, calculation.config.tfPossibleGain(hit), hit.target.unitId, hit.abilityId)
            end
        end
    end
end

function Analysis:GetEnemyHpPercent(timeMs, unitId)
    self.hpquery = self.hpquery + 1
    -- --check cache
    -- local cTime = self.hpCache[timeMs]
    -- if cTime then
    --     local cUnit = cTime[unitId]
    --     if cUnit then return cUnit[1], cUnit[2] end
    -- end

    local known, val = false, 1

    local unit = self.cmxFight.units[unitId]
    if unit then
        if self.additionalFightDatas and #self.additionalFightDatas ~= 0 then
            for _,f in ipairs(self.additionalFightDatas) do
                if unit.bossId then
                    local bossHpTracker = f:GetBossHpTracker(unit.unitTag)
                    if bossHpTracker then
                        -- debugPrint("returning bossHpTracker")
                        --FIXME try to fallback to the other one?
                        known, val = bossHpTracker:GetPercent(timeMs)
                    end
                end
        
                local hpTracker = f:GetHpTracker(unit.unitId)
                if hpTracker then
                    -- debugPrint("Returning basic hp tracker")
                    known, val = hpTracker:GetPercent(timeMs)
                end
            end
        else
            -- debugPrint("Additional fight data missing, or empty")
        end
    else
        -- debugPrint("Cannot find unit in CMX data %d", unitId)
    end

    -- --push to cache
    -- if not cTime then
    --     cTime = {}
    --     self.hpCache[timeMs] = cTime
    -- end 
    -- local cUnit = cTime[unitId]
    -- if not cUnit then
    --     cUnit = {known, val}
    --     cTime[unitId] = cUnit
    -- end
    return known, val
end


function Analysis:GetPlayerResourcePercent(trackerKey, timeMs)
    if not self.additionalFightDatas or #self.additionalFightDatas == 0 then
        -- debugPrint("Additional fight data missing, or empty")
        return false, 1
    end

    local bestError = 4294967295
    local bestPerc = 1
    local bestRes = false
    for _,f in ipairs(self.additionalFightDatas) do
        local res, perc, error = f[trackerKey]:GetPercent(timeMs)
        if res then
            if error < bestError then
                bestPerc = perc
                bestError = error
                bestRes = true
            end
        end
    end
    return bestRes, bestPerc
end

function Analysis:GetPlayerHealthPercent(timeMs)
    return self:GetPlayerResourcePercent("playerHpTracker", timeMs)
end

function Analysis:GetPlayerMagickaPercent(timeMs)
    return self:GetPlayerResourcePercent("playerMagickaTracker", timeMs)
end

function Analysis:GetPlayerStaminaPercent(timeMs)
    return self:GetPlayerResourcePercent("playerStaminaTracker", timeMs)
end

function Analysis:GetPlayerUltimatePercent(timeMs)
    return self:GetPlayerResourcePercent("playerUltimateTracker", timeMs)
end



function Analysis:AddWarningUnknownAbility(abilityId)
    self.warnings.unknownAbilities[abilityId] = true
end

function Analysis:AddWarningUnknownEnemyHp(unitId)
    if not self.warnings.unknownEnemyHp[unitId] then
        local unitName = "???"
        if self.cmxFight then
            local u = CombatInsights.analysis.cmxFight.units[unitId]
            if u then unitName = u.name end
        end
        self.warnings.unknownEnemyHp[unitId] = unitName
    end
end

function Analysis:AddWarningDamageDone(abilityId)
    self.warnings.damageDone[abilityId] = true
end

function Analysis:AddWarningWeaponDmg(abilityId)
    self.warnings.weaponDmg[abilityId] = true
end

function Analysis:AddWarningOther(text)
    self.warnings.other[text] = true
end

