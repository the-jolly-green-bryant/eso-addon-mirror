CombatInsightsPlayer = {}
local Player = CombatInsightsPlayer
local Consts = CombatInsightsConsts
local Utils = CombatInsightsUtils

local logger = Utils.CreateSubLogger("Player")

local function debugPrint(message, ...)
    df("[CiPlayer]: %s", message:format(...))
end

function Player:New()
    local o = {}

    o.gear = {
        bloodThristyValue = 0,
        numMediumArmor = 0,
        numLightArmor = 0,
        numHeavyArmor = 0,
        mediumArmorBonus = 0,
        undauntedMettle = 0,
        infernoStaff = {false,false},
        lightningStaff = {false,false},
        dualWield = {false,false},
        bow = {false,false},
        sets = {},
        arenaSets = {},
    }

    o.bars = {
        fgbonus = {0,0},
        hasNecroSiphonSlotted = {},
    }

    o.stats = {
        penetration = 0,
        spellDmg = 0,
        weaponDmg = 0,
        critDmg = 50,
        activeBar = 1,
        magicka = 0,
        stamina = 0,
        health = 0,
        ultimate = 0,
    }
    
    o.passives = {}
    o.buffs = {}
    o.buffCounters = {}
    o.cps = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Player:ReCalcBonuses()
    self.gear.mediumArmorBonus = self.gear.numMediumArmor * 2
    self.gear.undauntedMettle = (self.gear.numMediumArmor > 0 and 2 or 0)
                                +(self.gear.numLightArmor > 0 and 2 or 0)
                                +(self.gear.numHeavyArmor > 0 and 2 or 0)
end

function Player:Copy(fields)
    if fields == nil then
        local tmp = self.buffCounters
        self.buffCounters = nil -- no need, this is just for a workaround for tracking buffs
        local newInst = Utils.DeepCopy(self)
        self.buffCounters = tmp
        return newInst
    else
        local o = {}
        o.gear = fields.gear and Utils.DeepCopy(self.gear) or self.gear
        o.bars = fields.bars and Utils.DeepCopy(self.bars) or self.bars
        o.stats = fields.stats and ZO_ShallowTableCopy(self.stats) or self.stats
        o.passives = fields.passives and ZO_ShallowTableCopy(self.passives) or self.passives
        o.buffs = fields.buffs and ZO_ShallowTableCopy(self.buffs) or self.buffs
        o.cps = fields.cps and ZO_ShallowTableCopy(self.cps) or self.cps

        setmetatable(o, self)
        self.__index = self
        return o
    end
end

local function getSetName(itemLink)
    local _, setName, _, _, _, _ = GetItemLinkSetInfo(itemLink)
    return setName
end

local function getNumWorn(exampleItem, itemList)
    local bar1 = 0
    local bar2 = 0
    local setName = getSetName(exampleItem)
    
    for i,v in ipairs(Consts.itemSlotsBody) do
        local s = getSetName(itemList[v])
        if s == setName then
            bar1 = bar1 + 1
            bar2 = bar2 + 1
        end
    end

    for i,v in ipairs(Consts.itemSlotsJewels) do
        local s = getSetName(itemList[v])
        if s == setName then
            bar1 = bar1 + 1
            bar2 = bar2 + 1
        end
    end
    
    if itemList[EQUIP_SLOT_MAIN_HAND] ~= "" and getSetName(itemList[EQUIP_SLOT_MAIN_HAND]) == setName then
        if GetItemLinkEquipType(itemList[EQUIP_SLOT_MAIN_HAND]) == EQUIP_TYPE_ONE_HAND then
            bar1 = bar1 + 1
        else
            bar1 = bar1 + 2
        end
    end
    
    if itemList[EQUIP_SLOT_OFF_HAND] ~= "" and getSetName(itemList[EQUIP_SLOT_OFF_HAND]) == setName then
        bar1 = bar1 + 1
    end
    
    if itemList[EQUIP_SLOT_BACKUP_MAIN] ~= "" and getSetName(itemList[EQUIP_SLOT_BACKUP_MAIN]) == setName then
        if GetItemLinkEquipType(itemList[EQUIP_SLOT_BACKUP_MAIN]) == EQUIP_TYPE_ONE_HAND then
            bar2 = bar2 + 1
        else
            bar2 = bar2 + 2
        end
    end
    
    if itemList[EQUIP_SLOT_BACKUP_OFF] ~= "" and getSetName(itemList[EQUIP_SLOT_BACKUP_OFF]) == setName then
        bar2 = bar2 + 1
    end

    return bar1, bar2
end

local function getBloodThirstyValue(itemList)
    local res = 0
    for i,v in ipairs(Consts.itemSlotsJewels) do
        -- debugPrint("getBloodThirstyValue %s", itemList[v])
        local id, desc = GetItemLinkTraitInfo(itemList[v])
        
        -- /script local i,de = GetItemLinkTraitInfo("|H1:item:175045:364:50:45883:370:50:31:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h") d(tostring(de))
        -- /script local i,de = GetItemLinkTraitInfo("|H1:item:175045:364:50:45883:370:50:31:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h") local _,_,val = string.find(de, "(%d%d%d?)|r[^%%]+") d(val)
        
        
        if id == ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY then
            -- debugPrint("getBloodThirstyValue %d %s", id, desc)
            --Increases your Weapon and Spell Damage against enemies under 90% Health by up to 350.
            --2 or 3 digit without trailing % the digits are color formatted like |cffffff350|r
            local _,_,val = string.find(desc, "(%d%d%d?)|r[^%%]+")
            -- debugPrint("find res: %s", tostring(val))
            if val then
                res = res + val
            end
        end
    end
    return res
end


local function isAbilityOnBar(skillBarData, bar, abilityId)
    if skillBarData[bar] == nil then
        return false
    end
    for k, skill in ipairs(skillBarData[bar]) do
        if k ~= 1 and k ~= 2 then
            if skill == abilityId then
                return true
            end
        end
    end
    return false
end

local function getNumberOfSkillsOnBar(skillBarData, bar, skillSet)
    local num = 0
    if skillBarData[bar] ~= nil then
        for k, skill in ipairs(skillBarData[bar]) do
            if k ~= 1 and k ~= 2 then
                if skillSet[skill] then
                    num = num + 1
                end
            end
        end
    end
    return num
end

local function getNumberOfArmorWeight(itemlist, armorType)
    local num = 0
    for i,v in ipairs(Consts.itemSlotsBody) do
        if GetItemLinkArmorType(itemlist[v]) == armorType then
            num = num + 1
        end
    end
    return num
end


function Player:InitBasics(charData)
    -- self.classId = charData.classId
    -- self.raceId = charData.raceId
end

function Player:ParseItems(itemlist)
-- /script local a,b,c = CMX.GetAbilityStats(); d(a[1].charData.equip[1])

    self.gear.bloodThristyValue = getBloodThirstyValue(itemlist)
    self.gear.numMediumArmor = getNumberOfArmorWeight(itemlist, ARMORTYPE_MEDIUM)
    self.gear.numLightArmor = getNumberOfArmorWeight(itemlist, ARMORTYPE_LIGHT)
    self.gear.numHeavyArmor = getNumberOfArmorWeight(itemlist, ARMORTYPE_HEAVY)

    self.gear.infernoStaff[1] = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_MAIN_HAND]) == WEAPONTYPE_FIRE_STAFF
    self.gear.infernoStaff[2] = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_BACKUP_MAIN]) == WEAPONTYPE_FIRE_STAFF
    self.gear.lightningStaff[1] = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_MAIN_HAND]) == WEAPONTYPE_LIGHTNING_STAFF
    self.gear.lightningStaff[2] = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_BACKUP_MAIN]) == WEAPONTYPE_LIGHTNING_STAFF

    local wt1 = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_MAIN_HAND])
    local wt2 = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_OFF_HAND])
    self.gear.dualWield[1] = (wt1 == WEAPONTYPE_AXE or wt1 == WEAPONTYPE_DAGGER or wt1 == WEAPONTYPE_HAMMER) and (wt2 == WEAPONTYPE_AXE or wt2 == WEAPONTYPE_DAGGER or wt2 == WEAPONTYPE_HAMMER)
    wt1 = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_BACKUP_MAIN])
    wt2 = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_BACKUP_OFF])
    self.gear.dualWield[2] = (wt1 == WEAPONTYPE_AXE or wt1 == WEAPONTYPE_DAGGER or wt1 == WEAPONTYPE_HAMMER) and (wt2 == WEAPONTYPE_AXE or wt2 == WEAPONTYPE_DAGGER or wt2 == WEAPONTYPE_HAMMER)

    self.gear.bow[1] = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_MAIN_HAND]) == WEAPONTYPE_BOW
    self.gear.bow[2] = GetItemLinkWeaponType(itemlist[EQUIP_SLOT_BACKUP_MAIN]) == WEAPONTYPE_BOW
 
    for k,v in pairs(Consts.sets) do
        local b1p = 0
        local b2p = 0
        local b1, b2 = getNumWorn(v.iln, itemlist)
        if v.ilp then
            -- get num of perfected pieces if the set has a perf variant
            b1p, b2p = getNumWorn(v.ilp, itemlist)
        end
        if v.arena then
            -- we can have the arena weapon on either bar
            self.gear.arenaSets[k] = (b1 + b1p) >= v.n or (b2 + b2p) >= v.n
        else
            self.gear.sets[k] = {}
            self.gear.sets[k][1] = (b1 + b1p) >= v.n
            self.gear.sets[k][2] = (b2 + b2p) >= v.n
        end
    end

    self:ReCalcBonuses()
end


function Player:InitBars(skillBarData, logdata)
    self.bars.fgbonus[1] = getNumberOfSkillsOnBar(skillBarData, 1, Consts.fightersGuildAbilities) * 3
    self.bars.fgbonus[2] = getNumberOfSkillsOnBar(skillBarData, 2, Consts.fightersGuildAbilities) * 3
    self.bars.hasNecroSiphonSlotted[1] = getNumberOfSkillsOnBar(skillBarData, 2, Consts.necroSiphon) > 0
    self.bars.hasNecroSiphonSlotted[2] = getNumberOfSkillsOnBar(skillBarData, 2, Consts.necroSiphon) > 0
    
    --find the first weapon swap or ability cast the log and figure out the current bar
    for k, logline in ipairs(logdata) do
        local logtype = logline[1]
        
        if logtype == LIBCOMBAT_EVENT_MESSAGES then
            local message = logline[3]
            local bar = logline[4]
            local messagetext
            if message == LIBCOMBAT_MESSAGE_WEAPONSWAP then
                if bar ~= nil and bar > 0 then
                    -- debugPrint("Found active bar by barswap: %d (tobar: %d)", bar == 1 and 2 or 1, bar)
                    self:BarswapTo(bar == 1 and 2 or 1)
                    return
                end
            end
        elseif logtype == LIBCOMBAT_EVENT_SKILL_TIMINGS then
            local _, _, reducedslot, abilityId, status, skillDelay = unpack(logline)

            -- debugPrint("ST: %d %d", 0, abilityId)
            if reducedslot ~= nil then
                local isWeaponAttack = reducedslot%10 == 1 or reducedslot%10 == 2
                if not isWeaponAttack then
                    local onBar1 = isAbilityOnBar(skillBarData, 1, abilityId)
                    local onBar2 = isAbilityOnBar(skillBarData, 2, abilityId)
                    
                    if onBar1 ~= onBar2 then
                        --the skill is only on one of the bars
                        -- debugPrint("Found active bar by skill use: %d (%d)  %s %s", (onBar1 and 1 or 2), abilityId, tostring(onBar1), tostring(onBar2))
                        self:BarswapTo(onBar1 and 1 or 2)
                        return
                    end
                end
            end
        end
    end
    self:BarswapTo(1)
    -- debugPrint("Could not find active bar. Assuming bar 1")
end

function Player:InitCps(cpdata)
    --TODO bastion red cp not supported
    local slottedBlueCps = cpdata[1].slotted
    local stars = cpdata[1].stars
    for k,v in pairs(Consts.slottableCpIds) do
        if slottedBlueCps[v] then self.cps[k]  = true end
    end
    for k,v in pairs(Consts.passiveCps) do
        if stars[v] then self.cps[k]  = true end
    end
end

local function isGain(changeType)
    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        return true
    elseif changeType == EFFECT_RESULT_FADED then
        return false
    else
        logger:Error("Unknown change type: %d", changeType)
    end
    return false
end

function Player:HandleStatChange(logline)
    local _, timeMs, statchange, newvalue, statId = unpack(logline)
    local change = statchange
    local value = newvalue
    -- if statId == LIBCOMBAT_STAT_SPELLPENETRATION then 
        -- ownStats.spellPen = value
    if statId == LIBCOMBAT_STAT_WEAPONPENETRATION then
        self.stats.penetration = value
    elseif statId == LIBCOMBAT_STAT_SPELLPOWER then
        self.stats.spellDmg = value
    elseif statId == LIBCOMBAT_STAT_WEAPONPOWER then
        self.stats.weaponDmg = value
    elseif statId == LIBCOMBAT_STAT_WEAPONCRITBONUS then
        -- if value ~= self.stats.critDmg then
        --     debugPrint("CritDmg ch %d  %d -> %d", timeMs, self.stats.critDmg, value )
        -- end
        self.stats.critDmg = value
    elseif statId == LIBCOMBAT_STAT_MAXMAGICKA then
        self.stats.maxMagicka = value
    elseif statId == LIBCOMBAT_STAT_MAXSTAMINA then
        self.stats.maxStamina = value
    end
    -- debugPrint("playerstats %d", self.stats.penetration)
end

-- these buffs have some messed up events, the gain and lose wont line up properly
-- when there are multiple users, this means its not enough to track the gain/lose events,
-- we should track a counter as a workaround
local workarounds =
{
    [Consts.buffs.fieryBanner] = true,
    [Consts.buffs.magicalBanner] = true,
    [Consts.buffs.shatteringBanner] = true,
    [Consts.buffs.sunderingBanner] = true,
    [Consts.buffs.shockingBanner] = true,
}

function Player:HandleBuffEvent(cmxFight, logline, trialDummy)
    local _, timeMs, unitId, abilityId, changeType, effectType, stacks, sourceType, slot = unpack(logline)
    if unitId ~= cmxFight.playerid then return end
    local abilityName = GetAbilityName(abilityId)
    local buffs = self.buffs

    --watch out some abilites have the same name but different effect!
    --seething fury 122729 weaponDmg buff stacks this is not the one consumed by molten whip cast!
    --seething fury 122658 is the one gives 20% bonus for whip

    -- if abilityName == GetAbilityName(Consts.buffs.minorForce) then
    --     debugPrint("minor force change %d %d %d %s", timeMs, abilityId, changeType, tostring(isGain(changeType)))
    --     local text, color = CMX.GetCombatLogString(CombatInsights.analysis.cmxFight, logline, 14)
    --     d(text)
    -- end
    if abilityName ~= "" and Consts.buffsIgnore[abilityId] == nil then
        if workarounds[abilityId] then
            if self.buffCounters[abilityId] == nil then self.buffCounters[abilityId] = 0 end

            if isGain(changeType) then
                self.buffCounters[abilityId] = self.buffCounters[abilityId] + 1
            else
                self.buffCounters[abilityId] = self.buffCounters[abilityId] - 1
            end

            if self.buffCounters[abilityId] > 0 then
                changeType = EFFECT_RESULT_GAINED
            else
                changeType = EFFECT_RESULT_FADED
            end

            for k,v in pairs(Consts.buffs) do
                if abilityId == v then
                    buffs[k] = isGain(changeType)
                end
            end
        elseif abilityId == Consts.buffs.seethingFuryWhip then
            buffs.seethingFuryWhip = isGain(changeType)
            buffs.seethingFuryWhipStacks = buffs.seethingFuryWhip and stacks or 0
        elseif abilityId == Consts.buffs.hawkeye then
            buffs.hawkeye = isGain(changeType)
            buffs.hawkeyeStacks = buffs.hawkeye and stacks or 0
        elseif abilityId == Consts.buffs.huntersFocus then
            buffs.huntersFocus = isGain(changeType)
            buffs.huntersFocusStacks = buffs.huntersFocus and stacks or 0
        elseif abilityId == Consts.buffs.crux then
            buffs.crux = isGain(changeType)
            buffs.cruxStacks = buffs.crux and stacks or 0
        else
            for k,v in pairs(Consts.buffs) do
                if abilityName == GetAbilityName(v) then
                    buffs[k] = isGain(changeType)
                end
            end
        end
    end
    if trialDummy then
        for _,v in pairs(Consts.trialDummybuffs) do
            buffs[v] = true
        end
    end
end

function Player:BarswapTo(bar)
    self.stats.activeBar = bar
end

function Player:HasSet(setname, bar)
    local setdata = self.gear.sets[setname]
    if not setdata then return false end
    return setdata[bar]
end

function Player:UpdateMagicka(val)
    self.stats.magicka = val
end

function Player:UpdateStamina(val)
    self.stats.stamina = val
end

function Player:UpdateHealth(val)
    self.stats.health = val
end

function Player:UpdateUltimate(val)
    self.stats.ultimate = val
end