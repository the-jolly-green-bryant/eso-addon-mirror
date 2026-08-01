---------------------------------------------------------------------
-- Additional fight data logging
---------------------------------------------------------------------
CombatInsightsFights = CombatInsightsFights or {}
local Fights = CombatInsightsFights
local Utils = CombatInsightsUtils
local Fight = {}
local HpTracker = {}
local DamageTracker = {}
-- local BossHpTracker = {}
local ResourceTracker = {}
local logger = Utils.CreateSubLogger("fights")

local function debugPrint(message, ...)
    df("[CIFights]: %s", message:format(...))
end

local function combatStateEvt(eventCode, inCombat)
    Fights.HandleCombatState(inCombat)
end

local function onCombatEvt(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
    targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    
    -- debugPrint("%d %d ->%d %d: %d (%d) of:%s", sourceUnitId, sourceType, targetUnitId, targetType, hitValue, abilityId, tostring(overflow) )
    
    if hitValue ~= 0 and targetUnitId ~= 0
    -- and Fights.inCombat
    then
        local f = Fights.currentFight
        if not f then return end

        if sourceUnitId then f:CheckUnit(sourceName, sourceUnitId, sourceType) end
        if targetUnitId then f:CheckUnit(targetName, targetUnitId, targetType) end

        local dt = f:GetDamageTracker(targetUnitId)
        dt:NewHit(hitValue)
        if overflow > 0 then
            -- debugPrint("Overflow unitId : %d val: %d", targetUnitId, overflow)
            dt:OnUnitDied()
        end
    end
end

local function onCombatEvtUnitDied(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
    targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    
    -- debugPrint("onCombatEvtUnitDied: s:%d t:%d", sourceUnitId, targetUnitId)
    if targetUnitId ~= 0 
    -- and Fights.inCombat 
    then
        local f = Fights.currentFight
        if not f then return end
        local dt = f:GetDamageTracker(targetUnitId)
        dt:OnUnitDied()
    end
    
end

local function onBossHealthChanged(eventid, unitTag, _, powerType, powerValue, powerMax, powerEffectiveMax)

    -- Search on ESOUI Source Code GetRawUnitName(string unitTag
    -- GetUnitCaption(string unitTag)
    -- GetUnitBuffInfo(string unitTag, number buffInd
    -- Search on ESOUI Source Code GetUnitDisplayName(string unitTag
    -- Search on ESOUI Source Code GetUnitName(string unitTag
--     ring name
-- Search on ESOUI Source Code GetUnitPowerInfo(string unitTag, number poolIndex)
-- Returns: number:nilable type, number current, number max, number effectiveMax
-- Search on ESOUI Source Code GetUnitPower(string unitTag, number CombatMechanicFlags powerType)
-- Returns: number current, number max, number effectiveMax

    -- debugPrint("onBossHealthChanged %s %d %d", unitTag, powerValue, powerMax)
    local timems = GetGameTimeMilliseconds()
    local f = Fights.currentFight
    local tr = f.bossHpTrackers[unitTag]
    if not tr then
        tr = ResourceTracker:New(POWERTYPE_HEALTH)
        f.bossHpTrackers[unitTag] = tr
    end
    tr:NewSample(timems, powerValue, powerMax)
end

--(number eventCode, string unitTag, number powerIndex, CombatMechanicType powerType, number powerValue, number powerMax, number powerEffectiveMax)
local function onPlayerPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    -- debugPrint("Powerupdate %s %d %d %d %d %d", unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local f = Fights.currentFight
    local timems = GetGameTimeMilliseconds()
    if powerType == POWERTYPE_HEALTH then
        f.playerHpTracker:NewSample(timems, powerValue, powerMax)
    elseif powerType == POWERTYPE_MAGICKA then
        f.playerMagickaTracker:NewSample(timems, powerValue, powerMax)
    elseif powerType == POWERTYPE_STAMINA then
        f.playerStaminaTracker:NewSample(timems, powerValue, powerMax)
    elseif powerType == POWERTYPE_ULTIMATE then
        f.playerUltimateTracker:NewSample(timems, powerValue, powerMax)
    end
end


local function onBossesChanged(_)
    local f = Fights.currentFight
    if f then
        f.bossInfo = {}
        local bossdata = f.bossInfo
        for i = 1, 12 do
            local unitTag = ZO_CachedStrFormat("boss<<1>>", i)
    
            if DoesUnitExist(unitTag) then
                local name = GetUnitName(unitTag)
    
                bossdata[name] = i
                f.bossfight = true
                if f.bossname == "" and name ~= nil and name ~= "" then f.bossname = name end
            end
        end
    end
end

local function onReticleTargetChange(_)
    local f = Fights.currentFight
    if f then
        local current, max, effectiveMax = GetUnitPower("reticleover", POWERTYPE_HEALTH)
        local name = GetUnitName("reticleover")
        
        -- debugPrint("%s %d %d %d", name, current, max, effectiveMax)
        f.reticleHps[name] = max
    end
end


local nextEventHandleNr = 0
local function RegisterCombatResultEvent(result, callback)
    local eventHandleName = "CombatInsightsonCombatEvt" .. tostring(nextEventHandleNr) -- This is needed in order to generate a new unique eventNameSpace for each filterType added!
    nextEventHandleNr = nextEventHandleNr + 1
    EVENT_MANAGER:RegisterForEvent(eventHandleName, EVENT_COMBAT_EVENT, callback)
    EVENT_MANAGER:AddFilterForEvent(eventHandleName, EVENT_COMBAT_EVENT, 
        -- REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, 
        REGISTER_FILTER_IS_ERROR, false,
        REGISTER_FILTER_COMBAT_RESULT, result)
    return eventHandleName
end

local function hpLogLoop()
    local f = Fights.currentFight
    local timeMs = GetGameTimeMilliseconds()
    
    for id,dt in pairs(f.damageTrackers) do
        if dt.damageBuffer > 0 then
            table.insert(dt.timestamps, timeMs)
            table.insert(dt.hits, dt.damageBuffer)
            dt.damageBuffer = 0
        end
    end
end



local function onCombatEvtDbg(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, 
    targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    
     debugPrint("onCombatEvtDbg %s->%s %d r:%d %d %s", sourceName, targetName, abilityId, result, hitValue, abilityName)

    -- debugPrint("evt %d %d %d", eventCode, result, hitValue)
    -- if powerType == POWERTYPE_HEALTH then
    -- end
end

local function onEffectChangedDbg(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount,
     iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
     debugPrint("onEffectChangedDbg %s %s %d %d %d", unitTag, unitName, sourceType, unitId, abilityId)
end

function Fights.Init()
    Fights.fights = {}
    Fights.inCombat = false
    Fights.currentFight = nil
    Fights.PrepareNextFight()
    local timeMs = GetGameTimeMilliseconds()
    local value, max, _ = GetUnitPower("player", POWERTYPE_HEALTH)
    Fights.currentFight.playerHpTracker:NewSample(timeMs, value, max)
    value, max, _ = GetUnitPower("player", POWERTYPE_MAGICKA)
    Fights.currentFight.playerMagickaTracker:NewSample(timeMs, value, max)
    value, max, _ = GetUnitPower("player", POWERTYPE_STAMINA)
    Fights.currentFight.playerStaminaTracker:NewSample(timeMs, value, max)
    value, max, _ = GetUnitPower("player", POWERTYPE_ULTIMATE)
    Fights.currentFight.playerUltimateTracker:NewSample(timeMs, value, max)
    
    EVENT_MANAGER:RegisterForEvent("CombatInsightsCombatState", EVENT_PLAYER_COMBAT_STATE, combatStateEvt)
    EVENT_MANAGER:RegisterForEvent("CombatInsightsPlayerPwrUpd", EVENT_POWER_UPDATE, onPlayerPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent("CombatInsightsPlayerPwrUpd", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    EVENT_MANAGER:RegisterForEvent("CombatInsightsBossChange", EVENT_BOSSES_CHANGED, onBossesChanged)
    EVENT_MANAGER:RegisterForEvent("CombatInsightsReticleTargetChange", EVENT_RETICLE_TARGET_CHANGED, onReticleTargetChange)
    RegisterCombatResultEvent(ACTION_RESULT_DOT_TICK, onCombatEvt)
    RegisterCombatResultEvent(ACTION_RESULT_DOT_TICK_CRITICAL, onCombatEvt)
    RegisterCombatResultEvent(ACTION_RESULT_DAMAGE, onCombatEvt)
    RegisterCombatResultEvent(ACTION_RESULT_CRITICAL_DAMAGE, onCombatEvt)
    RegisterCombatResultEvent(ACTION_RESULT_DIED_XP, onCombatEvtUnitDied)
    RegisterCombatResultEvent(ACTION_RESULT_DIED, onCombatEvtUnitDied)
    EVENT_MANAGER:RegisterForUpdate("CombatInsightsFightsHpLogLoop", 100, hpLogLoop)
    
    -- EVENT_MANAGER:RegisterForEvent("CombatInsightsonEffectChangedDbg", EVENT_EFFECT_CHANGED, onEffectChangedDbg)
    -- EVENT_MANAGER:RegisterForEvent("CombatInsightsonCombatEvtDbg", EVENT_COMBAT_EVENT, onCombatEvtDbg)


    for i=1,10 do
        EVENT_MANAGER:RegisterForEvent("CombatInsightsBossHpEvt" .. i, EVENT_POWER_UPDATE, onBossHealthChanged)
        EVENT_MANAGER:AddFilterForEvent("CombatInsightsBossHpEvt" .. i, EVENT_POWER_UPDATE,
            -- REGISTER_FILTER_IS_ERROR, false,
            REGISTER_FILTER_UNIT_TAG, "boss" .. i,
            REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH
        )
    end

    onBossesChanged()
end


function Fights.LoadSavedFights()
    local fights = CombatInsightsFightData.SV.fights
    
    for _,f in pairs(fights) do
        Fights.fights[f.startDate] = Fight:FromSV(f)
    end
end

-- needs to be called before LoadSavedFights to purge the saved variables from obsolete data
function Fights.PurgeSavedFights()
    local cmxSaved = CombatMetricsFightData.GetFights()
    -- debugPrint("Purge")

    local usage = {}
    local fights = CombatInsightsFightData.SV.fights
    for k,v in pairs(fights) do
        usage[k] = 0
    end


    for i=1,#cmxSaved do
        local s = cmxSaved[i]
        local startDate = s.date
        -- logger:Debug("cmx saved %s - %s", os.date("%Y/%m/%d %H:%M:%S", startDate), os.date("%Y/%m/%d %H:%M:%S", endDate))
        for k,f in pairs(fights) do
            -- logger:Debug("fight saved %s - %s", os.date("%Y/%m/%d %H:%M:%S", f.startDate), os.date("%Y/%m/%d %H:%M:%S", f.endDate))
            if f.startDate then
                if ((f.startDate - 10) <= startDate and (f.startDate + 10) >= startDate) then
                    usage[k] = usage[k] + 1
                    -- logger:Debug("fight %s is in date range usage %d", tostring(k), usage[k])
                -- else
                    -- logger:Debug("fight %s not in date range", tostring(k))
                end
            end
        end
    end

    for k,f in pairs(fights) do
        if usage[k] == 0 then
            -- logger:Debug("Cleaning up fight %s - %s", os.date("%Y/%m/%d %H:%M:%S", f.startDate), os.date("%Y/%m/%d %H:%M:%S", f.endDate))
            CombatInsightsFightData.SV.fights[k] = nil
        end
    end
end




function Fights.PrepareNextFight(state)
    local f = Fight:New()
    if Fights.currentFight then
        hpLogLoop()
    end
    Fights.currentFight = f
end

function Fights.HandleCombatState(state)
    if state ~= Fights.inCombat then
        local f = Fights.currentFight
        Fights.inCombat = state
        -- debugPrint("HandleCombatState: %s", tostring(state))
        if state then
            f.startDate = GetTimeStamp()   --seconds
            f.startTimeMs = GetGameTimeMilliseconds()
            Fights.fights[f.startDate] = f
            -- table.insert(Fights.fights, f)
        else
            f.endDate = GetTimeStamp()   --seconds
            f.endTimeMs = GetGameTimeMilliseconds()
            f:CollectSkillData()
            Fights.inCombat = false
             --sometimes we get a damage event right at the start of the combat so i do it this was, out of combat current alreadly holds a new entry
            Fights.PrepareNextFight()
        end
    end
end

-- function Fights.GetFightByStartTime(startTime)
        
--     local iStart,iEnd,iMid = 1,#Fights.fights,0
--     local bestIndex = 0
--     local bestError = 4294967295
--     local i = 0
    
--     while iStart <= iEnd do
--         iMid = math.floor( (iStart+iEnd)/2 )
--         i = i + 1
--         if i > 32 then
--             debugPrint("GetFightByStartTime too many iterations")
--             return false, 1
--         end

--         local currentError = startTime - Fights.fights[iMid].startDate
--         --2 seconds tolerance should be ok
--         if math.abs(currentError) < 2 then return Fights.fights[iMid] end
--         if currentError > 0 then
--             iStart = iMid + 1
--         else
--             iEnd = iMid - 1
--         end
--     end
--     return nil
-- end

--
function Fights.GetFightsBetweenDates(startDate, endDate)
    local fights = {}
    -- debugPrint("GetFightsBetweenDates %d %d", startDate, endDate)
    startDate = startDate - 2
    endDate = endDate + 2
    -- debugPrint("GetFightsBetweenDates %d %d", startDate, endDate)

    for _,f in pairs(Fights.fights)  do
        -- local f = Fights.fights[i]
        -- debugPrint("GetFightsBetweenDates f %d %d", f.startDate, f.endDate)
        -- if f.startDate and f.endDate and f.startDate >= startDate and f.endDate <= endDate then
        if f:IsInDateRange(startDate, endDate) then
            table.insert(fights, f)
        end
    end
    return fights
end

function Fight:New()
    local o = {}
    o.dataVersion = CombatInsightsConsts.FIGHT_DATA_VERSION
    o.bossInfo = {}
    o.bossfight = false
    o.bossname = ""
    o.bosses = {}
    o.units = {}
    o.damageTrackers = {}
    o.hpTrackers = {}
    o.bossHpTrackers = {}
    o.reticleHps = {}
    o.playerHpTracker = ResourceTracker:New(POWERTYPE_HEALTH)
    o.playerMagickaTracker = ResourceTracker:New(POWERTYPE_MAGICKA)
    o.playerStaminaTracker = ResourceTracker:New(POWERTYPE_STAMINA)
    o.playerUltimateTracker = ResourceTracker:New(POWERTYPE_ULTIMATE)
    o.startDate = 0
    o.endDate = 0
    o.startTimeMs = 0
    o.endTimeMs = 0
    o.playerPassives = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Fight:ToSV()
    self:PostProcess()
    local o = {}
    o.dataVersion = self.dataVersion
    o.bossInfo = Utils.DeepCopy(self.bossInfo)
    o.bossfight = self.bossfight
    o.bossname = self.bossname
    o.bosses = Utils.DeepCopy(self.bosses)
    o.units = Utils.DeepCopy(self.units)
    o.damageTrackers = {}    -- we are not saving this, useless if the enemy didnt die we wont know the hp anyways
    --FIXME remove
    o.damageTrackers = {}
    for k,v in pairs(self.damageTrackers) do
        o.damageTrackers[k] = v:ToSV()
    end
    o.hpTrackers = {}
    for k,v in pairs(self.hpTrackers) do
        o.hpTrackers[k] = v:ToSV()
    end
    o.bossHpTrackers = {}
    for k,v in pairs(self.bossHpTrackers) do
        o.bossHpTrackers[k] = v:ToSV()
    end
    o.reticleHps = Utils.DeepCopy(self.reticleHps)
    o.playerHpTracker = self.playerHpTracker:ToSV()
    o.playerMagickaTracker = self.playerMagickaTracker:ToSV()
    o.playerStaminaTracker = self.playerStaminaTracker:ToSV()
    o.playerUltimateTracker = self.playerUltimateTracker:ToSV()
    o.startDate = self.startDate
    o.endDate = self.endDate
    o.startTimeMs = self.startTimeMs
    o.endTimeMs = self.endTimeMs
    o.playerPassives = Utils.DeepCopy(self.playerPassives)
    return o
end


function Fight:FromSV(saved)
    local o = {}
    -- o.damageTrackers = {}
    -- for k,v in pairs(saved.enemies) do
    --     o.enemies[k] = { unitId = v.unitId,
    --           targetName = v.targetName,
    --           hpTracker = HpTracker:FromSV(v.hpTracker)
    --         }
    -- end
    -- o.bosses = {}
    -- for k,v in pairs(saved.bosses) do
    --     o.bosses[k] = {
    --         name = v.name,
    --         bossHpTracker = ResourceTracker:FromSV(v.bossHpTracker)
    --     }


    --     -- o.bosses[k] = BossHpTracker:FromSV(v)
    --     -- debugPrint("loading boss %s from SV %s", tostring(k), tostring(o.bosses[k]))
    -- end


    
    if saved.dataVersion then
        o.dataVersion = saved.dataVersion
    end
    o.bossInfo = Utils.DeepCopy(saved.bossInfo)
    o.bossfight = saved.bossfight
    o.bossname = saved.bossname
    o.bosses = Utils.DeepCopy(saved.bosses)
    o.units = Utils.DeepCopy(saved.units)
    -- --FIXME remove
    o.damageTrackers = {}
    for k,v in pairs(saved.damageTrackers) do
        o.damageTrackers[k] = DamageTracker:FromSV(v)
    end
    o.hpTrackers = {}
    for k,v in pairs(saved.hpTrackers) do
        o.hpTrackers[k] = ResourceTracker:FromSV(v)
    end
    o.bossHpTrackers = {}
    for k,v in pairs(saved.bossHpTrackers) do
        o.bossHpTrackers[k] = ResourceTracker:FromSV(v)
    end

    o.reticleHps = saved.reticleHps and Utils.DeepCopy(saved.reticleHps) or {}
    o.playerHpTracker = ResourceTracker:FromSV(saved.playerHpTracker)
    o.playerMagickaTracker = ResourceTracker:FromSV(saved.playerMagickaTracker)
    o.playerStaminaTracker = ResourceTracker:FromSV(saved.playerStaminaTracker)
    o.playerUltimateTracker = ResourceTracker:FromSV(saved.playerUltimateTracker)
    o.startDate = saved.startDate
    o.endDate = saved.endDate
    o.startTimeMs = saved.startTimeMs
    o.endTimeMs = saved.endTimeMs
    if saved.playerPassives then    --new field, handle backward compatibility
        o.playerPassives = Utils.DeepCopy(saved.playerPassives)
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

--based on LibCombat CheckUnit
function Fight:CheckUnit(unitName, unitId, unitType)
    if self.units[unitId] == nil then self.units[unitId] = {isFriendly = false, name = "", unitType = COMBAT_UNIT_TYPE_NONE} end
    local unit = self.units[unitId]
    if unit.name == "Offline" or unit.name == "" then unit.name = unitName end
    unit.unitType = unitType

    if not unit.isFriendly then
        if unitType == COMBAT_UNIT_TYPE_GROUP or unitType == COMBAT_UNIT_TYPE_PLAYER then
            unit.isFriendly = true
        end
    end

    if unit.isFriendly == false then
        local bossId = self.bossInfo[unit.name]        -- if this is a boss, add the id (e.g. 1 for unitTag == "boss1")
        if bossId then
            unit.bossId = bossId
            self.bosses[bossId] = unitId
            unit.unitTag = ZO_CachedStrFormat("boss<<1>>", bossId)
        end
    end


end


function Fight:IsInDateRange(startDate, endDate)
    return self.startDate and self.endDate and self.startDate >= startDate and self.endDate <= endDate
end

function Fight:GetDamageTracker(unitId)
    local dt = self.damageTrackers[unitId]
    if not dt then
        dt = DamageTracker:New(unitId)
        self.damageTrackers[unitId] = dt
    end
    return dt
end

function Fight:GetHpTracker(unitId)
    self:PostProcess()
    local t = self.hpTrackers[unitId]
    if not t then return nil end
    return t
end

function Fight:GetBossHpTracker(unitTag)
    self:PostProcess()
    local tr = self.bossHpTrackers[unitTag]
    if tr then
        return tr
    else
         return nil
    end
end

function Fight:PostProcess()
    local run = true
    while run do
        local anyRemoved = false
        for unitId, dt in pairs(self.damageTrackers) do
            local rt = dt:ToResourceTracker(self:GetUnitObservedMaxHp(unitId))
            if rt then
                anyRemoved = true
                self.hpTrackers[unitId] = rt
                self.damageTrackers[unitId] = nil
                break
            end
        end
        if not anyRemoved then
            run = false
        end
    end
end

function Fight:GetUnitObservedMaxHp(unitId)
    --FIXME would it be a safe thing to just grab the max hp by name?
    --unless its a boss, the adds should have the same max hp
    --currently if the enemy didnt die and we havent look at it this we cant track its hp
    local unit = self.units[unitId]
    if unit then
        if unit.name and unit.name ~= "" then
            local observedMaxHp = self.reticleHps[unit.name]
            if observedMaxHp and observedMaxHp > 0 then
                return observedMaxHp
            end
        end
    end
    return nil
end

function Fight:SaveToSavedVariables()
    CombatInsightsFightData.SV.fights[self.startDate] = self
end

function Fight:CollectSkillData()
    --save the relevant passive skill's levels
    for _,v in pairs(CombatInsightsConsts.interestingSkillLineIds) do
        local skillType, skillLineIndex = GetSkillLineIndicesFromSkillLineId(v)
        for i=1,GetNumSkillAbilities(skillType, skillLineIndex) do
            local id = GetSkillAbilityId(skillType, skillLineIndex, i)
            local _, _, _, passive = GetSkillAbilityInfo(skillType, skillLineIndex, i)
            local rank = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, i)
            if passive then
                local key = CombatInsightsConsts.interestingPassives[id]
                if key and rank and rank > 0 then
                    -- df("%s %d %d %d %d %d", key, v, skillType, skillLineIndex, i, rank)
                    self.playerPassives[key] = rank
                end
            end
        end
    end
end

function DamageTracker:New(unitId)
    local o = {}
    o.unitId = unitId
    o.totalDmgTaken = 0
    o.damageBuffer = 0
    o.killed = false
    o.lastTimeStamp = 0
    o.timestamps = {}
    o.hits = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function DamageTracker:ToSV()
    local o = {}
    o.unitId = self.unitId
    o.totalDmgTaken = self.totalDmgTaken
    o.damageBuffer = self.damageBuffer
    o.killed = self.killed
    o.lastTimeStamp = self.lastTimeStamp
    o.timestamps = Utils.TableCopyNumeric(self.timestamps)
    o.hits = Utils.TableCopyNumeric(self.hits)
    return o
end

function DamageTracker:FromSV(saved)
    local o = {}
    o.unitId = saved.unitId
    o.totalDmgTaken = saved.totalDmgTaken
    o.damageBuffer = saved.damageBuffer
    o.killed = saved.killed
    o.lastTimeStamp = saved.lastTimeStamp
    o.timestamps = Utils.TableCopyNumeric(saved.timestamps)
    o.hits = Utils.TableCopyNumeric(saved.hits)
    setmetatable(o, self)
    self.__index = self
    return o
end


function DamageTracker:NewHit(hitValue)
    if not self.killed then
        self.totalDmgTaken = self.totalDmgTaken + hitValue
        self.damageBuffer = self.damageBuffer + hitValue
    else
        -- logger:Warn("Already dead unit taking damage? id: %d", self.unitId)
    end
end

function DamageTracker:OnUnitDied()
    self.killed = true
end

function DamageTracker:ToResourceTracker(observedMaxHp)
    local maxHp = nil

    if self.killed then
        maxHp = self.totalDmgTaken
    elseif observedMaxHp then
            maxHp = observedMaxHp
    end

    if maxHp then
        local resTracker = ResourceTracker:New(POWERTYPE_HEALTH)
        local dmg = 0
        for i = 1, #self.hits do
            resTracker:NewSample(self.timestamps[i], maxHp - dmg, maxHp)
            dmg = dmg + self.hits[i]
        end
        return resTracker
    end
    return nil
end

function ResourceTracker:New(resourceType)
    local o = {}
    o.resourceType = resourceType
    o.timestamps = {}
    o.percents = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function ResourceTracker:ToSV()
    local o = {}
    o.resourceType = self.resourceType
    o.timestamps = Utils.TableCopyNumeric(self.timestamps)
    o.percents = Utils.TableCopyNumeric(self.percents)
    return o
end

function ResourceTracker:FromSV(saved)
    local o = {}
    o.resourceType = saved.resourceType
    o.timestamps = Utils.TableCopyNumeric(saved.timestamps)
    o.percents = Utils.TableCopyNumeric(saved.percents)
    setmetatable(o, self)
    self.__index = self
    return o
end


function ResourceTracker:NewSample(timeMs, value, max)
    if #self.timestamps == 0 or self.timestamps[#self.timestamps] ~= timeMs then
        local actual = zo_round(value / max * 100)
        if actual ~= self.percents[#self.percents] then
            table.insert(self.timestamps, timeMs)
            table.insert(self.percents, actual)
        end
    end
end

function ResourceTracker:GetPercent(timeMs)
    local iStart,iEnd,iMid = 1,#self.timestamps,0
    local bestIndex = 0
    local bestError = 4294967295
    local i = 0
    
    if not self.percents or #self.percents == 0 then
        return false, 1
    end

    while iStart <= iEnd do
        iMid = math.floor( (iStart+iEnd)/2 )
        -- debugPrint("GetPercent %d %d %d %d %d", iStart,iEnd,iMid, bestIndex, bestError)
        i = i + 1
        if i > 32 then
            return false, 1
        end
            
        local currentError = timeMs - self.timestamps[iMid]
        -- debugPrint("GetPercent %d ", currentError)
        if math.abs(currentError) < math.abs(bestError) then
            bestError = currentError
            bestIndex = iMid
        end
            
        if currentError > 0 then
            iStart = iMid + 1
        else
            iEnd = iMid - 1
        end
    end
    return true, self.percents[bestIndex] / 100, math.abs(bestError)
end










