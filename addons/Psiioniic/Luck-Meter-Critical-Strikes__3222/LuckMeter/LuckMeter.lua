if LMTR == nil then LMTR = {} end
local LMTR = LMTR
LMTR.name = "LuckMeter"
LMTR.version = "0.3.1"
LMTR.apiVersion = 10132
LMTR.settingsName = "LuckMeterSettings"
LMTR.slash             = "/lmtr"

LMTR.spellCritChance   = 0.5  -- chance 0.0 to 1.0
LMTR.spellCritBonus    = 1.5  -- damage(crit)/damage(non-crit)
LMTR.weaponCritChance  = 0.5
LMTR.weaponCritBonus   = 1.5

local BernoulliCounter = {sum = 0.0, sumN = 0.0, sumV = 0.0, hits = 0}

function BernoulliCounter:new (o)
  o = o or {sum = 0.0, sumN = 0.0, sumV = 0.0, hits = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

function BernoulliCounter:add(a, b, pa, c)
	self.sumN  = self.sumN + pa * a + (1.0 - pa) * b
	self.sumV  = self.sumV + (b - a)*(b - a) * pa * (1.0 - pa)
	self.sum   = self.sum  + c
	self.hits  = self.hits + 1
end

function BernoulliCounter:addCritDamage(hitValue, f, m)
	self:add(hitValue, hitValue/(1.0 + m), f, hitValue)
end

function BernoulliCounter:addNonCritDamage(hitValue, f, m)
	self:add(hitValue * (1.0 + m), hitValue, f, hitValue)
end

function BernoulliCounter:addDamage(isCrit, hitValue, f, m)
	if isCrit then
		self:addCritDamage(hitValue, f, m)
	else
		self:addNonCritDamage(hitValue, f, m)
	end
end

function BernoulliCounter:read()
	if self.hits > 0 then
		return self.sumN, self.sumV, self.sum, self.hits
	else
		return 0.0, 0.0, 0.0, 0
	end
end

function BernoulliCounter:readFormattedPerSecond(deltaT)
	if deltaT < 1.0 then deltaT = 1.0 end
	local luck = (self.sum/deltaT - (self.sumN/deltaT)) / (math.sqrt(self.sumV)/deltaT)
	return string.format("%1.2fk in %1.2f s, expected: %1.2fk (+- %1.2f) luck = %1.2f", 0.001*self.sum/deltaT, deltaT, 0.001* (self.sumN/deltaT), 0.001*math.sqrt(self.sumV)/deltaT, luck)
end

function BernoulliCounter:reset()
	self.hits = 0
	self.sum  = 0.0
	self.sumN = 0.0
	self.sumV = 0.0
end

LMTR.defaultCounter    = BernoulliCounter:new()
LMTR.spellCounter      = BernoulliCounter:new()
LMTR.weaponCounter     = BernoulliCounter:new()
LMTR.lightCounter      = BernoulliCounter:new()
LMTR.specialCounter    = BernoulliCounter:new()
LMTR.ncCounter         = BernoulliCounter:new()

LMTR.startTime         = 0
LMTR.endTime           = 0
LMTR.inCombat          = false
LMTR.lastUpdateTime    = GetGameTimeMilliseconds()
LMTR.playerName        = GetRawUnitName("player")
LMTR.isInTrainingPhase = false
LMTR.critDamageCap     = 1.25
LMTR.DefaultSavedVars = {["accountWide"] = false, ["positionX"] = 360, ["positionY"] = 10, ["counterCrits"]={}, ["counterTicks"]={}, ["debug"]=false, ["apiVersion"]=10132}
LMTR.effectElementalCatalystFire  = {}
LMTR.effectElementalCatalystIce   = {}
LMTR.effectElementalCatalystShock = {}
LMTR.effectMinorBrittle           = {}

LMTR.debuffsUpdateInterval = 50
LMTR.debuffsLastChecked    = GetGameTimeMilliseconds()
LMTR.debuffsActive         = {}
LMTR.debuffsIncreasingTakenCritDamage = {
	[142610] = 0.05, -- EC fire
	[142652] = 0.05, -- EC shock
	[142653] = 0.05, -- EC ice
	[145975] = 0.10, -- minor brittle
	}
LMTR_PASSIVES_DEATH_KNELL = 0.04
LMTR.lightAttacks = {
	[15282] = true,
	[15383] = true,
	[15435] = true,
	[15829] = true,
	[16037] = true,
	[16165] = true,
	[16261] = true,
	[16277] = true,
	[16420] = true,
	[16499] = true,
	[16688] = true,
	[17162] = true,
	[17163] = true,
	[17169] = true,
	[17170] = true,
	[17173] = true,
	[17174] = true,
	[17701] = true, -- bow Heavy Attack Damage Bonus = ?
	[18350] = true,
	[18396] = true,
	[18404] = true, -- frost staff: Heavy Attack Damage Bonus = ?
	[18405] = true,
	[18406] = true,
	[18622] = true,
	[19277] = true,
	[21929] = true, -- poison glyph
	[17902] = true, -- poison glyph
	[18084] = true, -- fire glyph
	[17895] = true, -- fire glyph
	[21481] = true, -- ice glyph
	[17897] = true, -- ice glyph
	[40337] = true, -- prismatic
	[46743] = true, -- absorb magicka
	[46746] = true, -- absorb stamina
	[28919] = true, -- absorb health
	}
LMTR.scalesWithMax = {
	-- twilight matriarch
	[24617] = true,
	[28027] = true,
	[117273] = true,
	[117274] = true,
	[117320] = true,
	[117321] = true,
	-- storm atronach
	[23428] = true,

}
LMTR.physicalDamage = {[DAMAGE_TYPE_BLEED] = true,[DAMAGE_TYPE_DISEASE] = true,[DAMAGE_TYPE_EARTH] = true,[DAMAGE_TYPE_PHYSICAL] = true,[DAMAGE_TYPE_POISON] = true}
LMTR.lastPrintoutTime = GetGameTimeMilliseconds()
LMTR.lowHealthUnits = {}
LMTR.unknownCritStatusList = {}
LMTR.maxHpTargetHp = 0
LMTR.maxHpTargetName = ""


local function OnLibcombatEventPlayerstats(event, timems, statchange, newvalue, statId)
	if statId ~= nil then
		if statId == LIBCOMBAT_STAT_SPELLCRIT then
			LMTR.spellCritChance = 0.01 * GetCriticalStrikeChance(newvalue)
		elseif statId == LIBCOMBAT_STAT_SPELLCRITBONUS then
			LMTR.spellCritBonus = 1.0 + 0.01 * newvalue
		elseif statId == LIBCOMBAT_STAT_WEAPONCRIT then
			LMTR.weaponCritChance = 0.01 * GetCriticalStrikeChance(newvalue)
		elseif statId == LIBCOMBAT_STAT_WEAPONCRITBONUS then
			LMTR.weaponCritBonus = 1.0 + 0.01 * newvalue
		end
	end
end

local function GetFormattedStandardDeviation(luck, dpsStandardDeviation)
	local fmt = "%1.2f ( x %1.2fk)"
	if LMTR.isInTrainingPhase then
		fmt = "|cff00ff%1.2f(???)|r"
	elseif luck < -3 then
		fmt = "|cff0000%1.2f(!)|r"
	elseif luck < -2 then
		fmt = "|cffff00%1.2f|r"
	elseif luck < 0 then
		fmt = "%1.2f"
	elseif luck > 3 then
		fmt = "|cff0000+%1.2f(!)|r"
	elseif luck > 2 then
		fmt = "|cffff00+%1.2f|r"
	else
		fmt = "+%1.2f"
	end
	fmt = fmt .. " ( x %1.2fk)"
	return string.format(fmt, luck, 0.001*dpsStandardDeviation)
end

local function UpdateStats()
	if LMTR.inCombat then
		-- in seconds
		local deltaT = 0.001*(LMTR.endTime - LMTR.startTime)
		if deltaT < 1 then
			deltaT = 1.0
		end

		local sumN, sumV, sum, hits = LMTR.defaultCounter:read()

		local dpsReal              = sum / deltaT
		local dpsExpectedMedian    = sumN / deltaT
		local dpsStandardDeviation = math.sqrt(sumV) / deltaT
		if dpsStandardDeviation < 1 then
			dpsStandardDeviation = 1000.0
		end
		local luck = (dpsReal - dpsExpectedMedian)/dpsStandardDeviation

		if LMTR.isInTrainingPhase then
			LuckMeterDpsLabelValue:SetText(string.format("%1.2fk / %1.2fk(???) (%1.1fs)", 0.001*dpsReal, 0.001*dpsExpectedMedian, deltaT))
		else
			LuckMeterDpsLabelValue:SetText(string.format("%1.2fk / %1.2fk (%1.1fs)", 0.001*dpsReal, 0.001*dpsExpectedMedian, deltaT))
		end

		if luck < -10 or luck > 10 or hits < 10 then
			LuckMeterLuckLabelValue:SetText("--")
		else
			LuckMeterLuckLabelValue:SetText(GetFormattedStandardDeviation(luck, dpsStandardDeviation))
		end
	end
end

local function PostStats()
	d("LMTR: combat against "..zo_strformat("<<1>>",LMTR.maxHpTargetName).." ("..tostring(LMTR.maxHpTargetHp).." HP) statistics:")
	d("LMTR: DPS: "..LuckMeterDpsLabelValue:GetText().." luck: "..LuckMeterLuckLabelValue:GetText())
	if LMTR.savedVariables.debug then
		if next(LMTR.unknownCritStatusList) ~= nil then
			d("LMTR: DEBUG: skills with unknown crit status:")
			d(LMTR.unknownCritStatusList)
			d("LMTR: -> ability to crit will be learned, this warning will disappear after more training")
		end
	end

	local deltaT = 0.001*(LMTR.endTime - LMTR.startTime)
	if deltaT < 1 then
		deltaT = 1.0
	end

	if LMTR.savedVariables.debug then
		d("LMTR: DEBUG: luck per damage category")
		d("LMTR:  ".. LMTR.lightCounter:readFormattedPerSecond(deltaT) .. " (light attack)")
		d("LMTR:  ".. LMTR.weaponCounter:readFormattedPerSecond(deltaT) .. " (weapon)")
		d("LMTR:  ".. LMTR.spellCounter:readFormattedPerSecond(deltaT) .. " (spell)")
		d("LMTR:  ".. LMTR.specialCounter:readFormattedPerSecond(deltaT) .. " (special)")
		d("LMTR:  ".. LMTR.ncCounter:readFormattedPerSecond(deltaT) .. " (unable to crit)")
	end
end

local function ResetStats()
	LMTR.startTime = 0
	LMTR.endTime = 0

	LMTR.defaultCounter:reset()
	LMTR.spellCounter:reset()
	LMTR.weaponCounter:reset()
	LMTR.lightCounter:reset()
	LMTR.specialCounter:reset()
	LMTR.ncCounter:reset()

	LMTR.isInTrainingPhase = false
	LMTR.unknownCritStatusList = {}
	LMTR.maxHpTargetHp = 0
	LMTR.maxHpTargetName = ""
end

-- return values:
--  true: ability can crit
--  false: ability can not crit
--  nil: not sure (need more training)
function LMTR.AbilityIdCanCrit(abilityId)
	if LMTR.accountWideSavedVariables.counterCrits[abilityId] ~= nil and LMTR.accountWideSavedVariables.counterTicks[abilityId] ~= nil then
		if LMTR.accountWideSavedVariables.counterCrits[abilityId] > 0 then
			return true
		elseif LMTR.accountWideSavedVariables.counterTicks[abilityId] > 10 then
			return false
		else
			return
		end
	elseif LMTR.accountWideSavedVariables.counterTicks[abilityId] ~= nil and LMTR.accountWideSavedVariables.counterTicks[abilityId] > 10 then
		return false
	else
		return
	end
end

local function RegisterNonCritForAbilityId(abilityId)
	if LMTR.accountWideSavedVariables.counterTicks[abilityId] == nil then
		LMTR.accountWideSavedVariables.counterTicks[abilityId] = 1
	else
		LMTR.accountWideSavedVariables.counterTicks[abilityId] = LMTR.accountWideSavedVariables.counterTicks[abilityId] + 1
	end
end

local function RegisterCritForAbilityId(abilityId)
	if LMTR.accountWideSavedVariables.counterCrits[abilityId] == nil then
		LMTR.accountWideSavedVariables.counterCrits[abilityId] = 1
	else
		LMTR.accountWideSavedVariables.counterCrits[abilityId] = LMTR.accountWideSavedVariables.counterCrits[abilityId] + 1
	end
	if LMTR.accountWideSavedVariables.counterTicks[abilityId] == nil then
		LMTR.accountWideSavedVariables.counterTicks[abilityId] = 1
	else
		LMTR.accountWideSavedVariables.counterTicks[abilityId] = LMTR.accountWideSavedVariables.counterTicks[abilityId] + 1
	end
end

-- todo: per unit
local function UpdateDebuffs()
	LMTR.debuffsActive = {}
	for i = 1, GetNumBuffs("reticleover") do
		local _, _, finish, _, _, _, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("reticleover", i)
		if LMTR.debuffsActive[abilityId] then
			if finish*1000 > LMTR.debuffsActive[abilityId] then
				LMTR.debuffsActive[abilityId] = finish*1000
			end
		else
			LMTR.debuffsActive[abilityId] = finish*1000
		end
		if started == finish then
			LMTR.debuffsActive[abilityId] = GetGameTimeMilliseconds() + 600000
		end
	end
	LMTR.debuffsLastChecked = GetGameTimeMilliseconds()
end

local function OnCombatEvent(eventCode, result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	local gameTime = GetGameTimeMilliseconds()

	-- update enemy debuffs (enemy below reticle)
	if gameTime > LMTR.debuffsLastChecked + LMTR.debuffsUpdateInterval then
		UpdateDebuffs()
	end

	--
	if powerType ~= -1 and (damageType > 0 and hitValue ~= nil and hitValue > 0) then
		--hitValue = hitValue + overflow
		hitValue = hitValue
		local wasValidDamage = false

		local isCriticalDamage    = (result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL)
		local isNonCriticalDamage = (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DAMAGE_SHIELDED)

		-- player/pet hits
		if (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) and (isCriticalDamage or isNonCriticalDamage) then

			-- spell / weapon crit
			local m = 0.0 -- crit extra damage as fraction of non-crit damage
			local f = 0.5 -- crit chance
			if LMTR.physicalDamage[damageType] ~= nil then
				m = LMTR.weaponCritBonus - 1.0
				f = LMTR.weaponCritChance
			else
				m = LMTR.spellCritBonus - 1.0
				f = LMTR.spellCritChance
			end

			-- light attacks crit is larger of the two
			if LMTR.lightAttacks[abilityId] ~= nil then
				f = math.max(LMTR.weaponCritChance, LMTR.spellCritChance)
				m = math.max(LMTR.weaponCritBonus - 1.0, LMTR.spellCritBonus - 1.0)
			end

			-- pets, and some special skills
			if (sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) or LMTR.scalesWithMax[abilityId] ~= nil then
				f = math.max(LMTR.weaponCritChance, LMTR.spellCritChance)
				m = math.max(LMTR.weaponCritBonus - 1.0, LMTR.spellCritBonus - 1.0)
			end

			-- target debuffs
			for key,value in pairs(LMTR.debuffsIncreasingTakenCritDamage) do
				if LMTR.debuffsActive[key]~= nil and gameTime < LMTR.debuffsActive[key] then
					m = m + value
				end
			end

			-- death knell passive
			local currentHp, _, effectiveMaxHp = GetUnitPower("reticleover", POWERTYPE_HEALTH)
			local nmdkbuff = 0
			local reticleUnitName = GetRawUnitName("reticleover")

			if currentHp/effectiveMaxHp < 0.25 then
				LMTR.lowHealthUnits[reticleUnitName] = true
			else
				LMTR.lowHealthUnits[reticleUnitName] = false
			end

			-- detect main enemy (in most cases...)
			if effectiveMaxHp > LMTR.maxHpTargetHp then
				LMTR.maxHpTargetHp = effectiveMaxHp
				LMTR.maxHpTargetName = reticleUnitName
			end

			if LMTR.lowHealthUnits[targetName] ~= nil and LMTR.lowHealthUnits[targetName] then
				local activeHotbarCategory = GetActiveHotbarCategory()
				if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY and LMTR.buffsDeathKnellFrontbar > 0 then
					f = f + LMTR.buffsDeathKnellFrontbar * LMTR_PASSIVES_DEATH_KNELL
					nmdkbuff = LMTR.buffsDeathKnellFrontbar * LMTR_PASSIVES_DEATH_KNELL
				elseif activeHotbarCategory == HOTBAR_CATEGORY_BACKUP and LMTR.buffsDeathKnellBackbar > 0 then
					f = f + LMTR.buffsDeathKnellBackbar * LMTR_PASSIVES_DEATH_KNELL
					nmdkbuff = LMTR.buffsDeathKnellBackbar * LMTR_PASSIVES_DEATH_KNELL
				end
			end

			if f > 1.0 then f = 1.0 end

			local m_noCC = m
			if m > LMTR.critDamageCap then m = LMTR.critDamageCap end

			-- check if ability can't crit (some proc effects)
			if isNonCriticalDamage then
				local abilityCanCrit = LMTR.AbilityIdCanCrit(abilityId)
				if abilityCanCrit == nil then
					LMTR.isInTrainingPhase = true
					LMTR.unknownCritStatusList[abilityId] = abilityName
				elseif not abilityCanCrit then
					-- set crit strike chance to 0!
					f = 0
				end
			end

			-- crit/non-crit list
			if isCriticalDamage then
				RegisterCritForAbilityId(abilityId)
			elseif isNonCriticalDamage then
				RegisterNonCritForAbilityId(abilityId)
			end

			-- DEFAULT counter
			LMTR.defaultCounter:addDamage(isCriticalDamage, hitValue, f, m)

			-- other counters
			if f < 0.001 then
				LMTR.ncCounter:addDamage(isCriticalDamage, hitValue, f, m)
			elseif LMTR.lightAttacks[abilityId] ~= nil then
				LMTR.lightCounter:addDamage(isCriticalDamage, hitValue, f, m)
			elseif (sourceType == COMBAT_UNIT_TYPE_PLAYER_PET) or LMTR.scalesWithMax[abilityId] ~= nil then
				LMTR.specialCounter:addDamage(isCriticalDamage, hitValue, f, m)
			elseif LMTR.physicalDamage[damageType] ~= nil then
				LMTR.weaponCounter:addDamage(isCriticalDamage, hitValue, f, m)
			else
				LMTR.spellCounter:addDamage(isCriticalDamage, hitValue, f, m)
			end

			if GetGameTimeMilliseconds() > LMTR.lastPrintoutTime + 5000 then
				LMTR.lastPrintoutTime = GetGameTimeMilliseconds()
			end

			wasValidDamage = true
		else
			-- only works if filters below are adjusted to include group damage events

			--d("external damage: "..abilityName.. " src="..sourceName.." type="..sourceType.." unit="..sourceUnitId)
			-- use damage events from other players to learn if abilities are in general able to crit
			if isCriticalDamage then
				RegisterCritForAbilityId(abilityId)
			else
				RegisterNonCritForAbilityId(abilityId)
			end
		end

		if wasValidDamage then
			if (LMTR.startTime < 1 ) then
				LMTR.startTime = gameTime
			end
			LMTR.endTime = gameTime
		end
		if gameTime - LMTR.lastUpdateTime > 1000 then
			LMTR.lastUpdateTime = gameTime
			UpdateStats()
		end

	end

end


local function OnPlayerCombatState(event, inCombat)
	if inCombat and not LMTR.inCombat then
		LMTR.inCombat = inCombat
	elseif not inCombat and LMTR.inCombat then
		UpdateStats()
		PostStats()
		ResetStats()
		LMTR.inCombat = inCombat
	end
end


function LMTR.SavePosition()
	LMTR.savedVariables.positionX = LuckMeter:GetLeft()
	LMTR.savedVariables.positionY = LuckMeter:GetTop()
end


local function RestorePosition()
	if LMTR.savedVariables.positionX > -1 and LMTR.savedVariables.positionY > -1 then
		LuckMeter:ClearAnchors()
		LuckMeter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, LMTR.savedVariables.positionX, LMTR.savedVariables.positionY)
	end
end

local function LoadSavedVariables()
	LMTR.characterSavedVariables = ZO_SavedVars:NewCharacterNameSettings("LuckMeterVars", 1, nil, LMTR.DefaultSavedVars)
	LMTR.accountWideSavedVariables = ZO_SavedVars:NewAccountWide("LuckMeterVars", 1, nil, LMTR.DefaultSavedVars)
	if LMTR.characterSavedVariables.accountWide then
		LMTR.savedVariables = LMTR.accountWideSavedVariables
		LMTR.savedVariables.accountWide = true
	else
		LMTR.savedVariables = LMTR.characterSavedVariables
	end

	if LMTR.apiVersion > LMTR.savedVariables.apiVersion then
		d("LMTR: migrate saved variables from "..tostring(LMTR.savedVariables).." to "..LMTR.apiVersion)
		-- migrations can be done here
		LMTR.savedVariables.apiVersion = LMTR.apiVersion
	end

	if GetAPIVersion() > LMTR.apiVersion then
		d("LMTR: This addon has not yet updated for the latest API version. If no update is available, saved variables for this addon should be deleted.")
	end
end

local function UpdateSlottedAbilities()
	LMTR.buffsDeathKnellFrontbar = 0
	LMTR.buffsDeathKnellBackbar = 0
	local gravelordAbilities = {[117637] = true, [117749] = true, [117805] = true, [118726] = true, [118008] = true, [122395] = true}

	for i=1,6 do
		if gravelordAbilities[GetSlotBoundId(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i, HOTBAR_CATEGORY_PRIMARY)] ~= nil then
			LMTR.buffsDeathKnellFrontbar = LMTR.buffsDeathKnellFrontbar + 1
		end
		if gravelordAbilities[GetSlotBoundId(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX+i, HOTBAR_CATEGORY_BACKUP)] ~= nil then
			LMTR.buffsDeathKnellBackbar = LMTR.buffsDeathKnellBackbar + 1
		end
	end
end

local function InitializeMenu()

    local panelData = {
        type = "panel",
        name = LMTR.name,
        displayName = LMTR.name,
        author = "Psiioniic",
        version = LMTR.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(LMTR.settingsName, panelData)

	local optionsTable = {
		{
			type = "header",
			name = "Luck Meter help / settings",
			width = "full",
		},
		{
			type = "description",
			text = "Measures the critical strike luck of a fight as a single number. Values between |cff2233-3 (unlucky)|r and |cff2233+3 (lucky)|r are common. Larger or smaller values can occur rarely. If they occur often, it is most probably a bug in this addon, the underlying API or a library. The expected |c44ffffmean|r and |c44ff44standard deviation|r of the distribution are also given and can be interpreted as the DPS one would have had with average crit luck. Format is:",
			width = "full",
		},
		{
			type = "description",
			text = "DPS: actual DPS / |c44ffffmean DPS|r (time in seconds)\nLuck: |c8888ffluck|r (x |c44ff44expected DPS standard deviation|r)",
			width = "full",
		},
		{
			type = "description",
			text = "A |cff00ff(???)|r after the number means that the addon still has to learn which abilities can critically strike, so the result is not accurate. This will go away after some more fights.",
			width = "full",
		},
		{
			type = "description",
			text = "New: print a warning |cff2233 lost on average x DPS due to critical damage cap. |r if damage is lost to crit cap. Consider changing CP or setup if those values are large.",
			width = "full",
		},
		{
			type = "description",
			text = string.format("Sets and passives which are already taken into account: Mechanical acuity, Minor brittle (increase crit damage taken by %1.2f), Elemental catalyst (increase crit damage taken by %1.2f %1.2f %1.2f), Death Knell (increase crit change by %1.2f per skill), Critical damage cap: %1.2f", LMTR.debuffsIncreasingTakenCritDamage[145975], LMTR.debuffsIncreasingTakenCritDamage[142610], LMTR.debuffsIncreasingTakenCritDamage[142652], LMTR.debuffsIncreasingTakenCritDamage[142653], LMTR_PASSIVES_DEATH_KNELL, 100.0*(LMTR.critDamageCap)),
			width = "full",
		},
		{
			type = "description",
			text = "Technical explanation: the |c8888ffluck number|r is the difference of actual DPS to the mean of the sum of Bernoulli random variables for all damage events divided by their standard deviation. This takes into account the different damage the abilities do: e.g., if your critical chance is 60%, getting 70% critical strikes for blastbones counts more than 70% critical strikes for degeneration. Stats are provides by libCombat, if backstabber is used, enemies are assumed to be always flanked. In this early beta version, only single target fights provide an accurate result. Very short fights can also result in weird numbers. If the addon is not updated after an API change, saved variables should be cleared.",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Debug",
			tooltip = "",
			getFunc = function()
				return LMTR.savedVariables.debug
			end,
			setFunc = function(value)
				LMTR.savedVariables.debug = value
			end,
			width = "full",
			default = false,
			requiresReload = false,
		},
	}
	LibAddonMenu2:RegisterOptionControls(LMTR.settingsName, optionsTable)
end

local function RegisterInSceneManager()
	HUD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(LuckMeter))
	HUD_UI_SCENE:AddFragment(ZO_SimpleSceneFragment:New(LuckMeter))
end

local function OnAddOnLoaded(event, addon)
	if addon ~= LMTR.name then return end

	EVENT_MANAGER:UnregisterForEvent(LMTR.name, EVENT_ADD_ON_LOADED)

	LibCombat:RegisterCallbackType(LIBCOMBAT_EVENT_PLAYERSTATS, OnLibcombatEventPlayerstats, LMTR.name)

	EVENT_MANAGER:RegisterForEvent(LMTR.name.."CombatEvent", EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(LMTR.name.."CombatEvent", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:RegisterForEvent(LMTR.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)

	EVENT_MANAGER:RegisterForEvent(LMTR.name.."CombatEventPet", EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(LMTR.name.."CombatEventPet", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)

	ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback("SlotUpdated", function(hotbarCategory, actionSlotIndex, isChangedByPlayer)
		zo_callLater(function () UpdateSlottedAbilities() end, 500)
    end)

	LoadSavedVariables()
	RestorePosition()

	zo_callLater(function () UpdateSlottedAbilities() end, 500)
	zo_callLater(function () InitializeMenu() end, 700)
	zo_callLater(RegisterInSceneManager, 1000)

	ResetStats()

end

EVENT_MANAGER:RegisterForEvent(LMTR.name, EVENT_ADD_ON_LOADED, function(...) OnAddOnLoaded(...) end)


SLASH_COMMANDS[LMTR.slash] = function (cmd)
    local commands = {}
    local index = 1
	local num = 0

    for i in string.gmatch(cmd, "%S+") do
        if (i ~= nil and i ~= "") then
            commands[index] = i
            index = index + 1
        end
    end

    if #commands == 1 then
		if commands[1] == "d" then
			LMTR.savedVariables.debug = true
		end
	end
end