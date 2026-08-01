if Overcrit == nil then Overcrit = {} end
local Overcrit = Overcrit
Overcrit.name = "Overcrit"
Overcrit.version = "0.3.2"
Overcrit.apiVersion = 10132
Overcrit.settingsName = "OvercritSettings"
Overcrit.updateInterval = 500 -- ms

Overcrit.spellCritChance   = 0.5  -- chance 0.0 to 1.0
Overcrit.spellCritBonus    = 1.5  -- damage(crit)/damage(non-crit)
Overcrit.weaponCritChance  = 0.5
Overcrit.weaponCritBonus   = 1.5
Overcrit.damage            = 0
Overcrit.damageNoCC        = 0
Overcrit.startTime         = 0
Overcrit.endTime           = 0
Overcrit.inCombat          = false
Overcrit.lastUpdateTime    = GetGameTimeMilliseconds()
Overcrit.playerName        = GetRawUnitName("player")
Overcrit.isInTrainingPhase = false
Overcrit.critDamageCap     = 1.25
Overcrit.m 				   = 0.50
Overcrit.sum               = 0.0
Overcrit.sumw              = 0.0
Overcrit.statsInitializedS = 0
Overcrit.statsInitializedW = 0

Overcrit.DefaultSavedVars = {["accountWide"]=false,["positionX"]=660, ["positionY"]=30, ["debug"]=false, ["apiVersion"]=10132}
Overcrit.effectElementalCatalystFire  = {}
Overcrit.effectElementalCatalystIce   = {}
Overcrit.effectElementalCatalystShock = {}
Overcrit.effectMinorBrittle           = {}

Overcrit.debuffsUpdateInterval = 50
Overcrit.debuffsLastChecked    = GetGameTimeMilliseconds()
Overcrit.debuffsActive         = {}
Overcrit.specialDebuffsActive  = {}
Overcrit.debuffsIncreasingTakenCritDamage = {
	[142610] = 0.05, -- EC fire
	[142652] = 0.05, -- EC shock
	[142653] = 0.05, -- EC ice
	[145975] = 0.10, -- minor brittle
	}
Overcrit.passiveGlacialPresencePerLevel = 0.05
Overcrit.passiveGlacialPresence = 0.0
Overcrit.physicalDamage = {[DAMAGE_TYPE_BLEED] = true,[DAMAGE_TYPE_DISEASE] = true,[DAMAGE_TYPE_EARTH] = true,[DAMAGE_TYPE_PHYSICAL] = true,[DAMAGE_TYPE_POISON] = true}
Overcrit.lastPrintoutTime = GetGameTimeMilliseconds()
Overcrit.lowHealthUnits = {}

Overcrit.maxHpTargetHp = 0
Overcrit.maxHpTargetName = ""

local function OnLibcombatEventPlayerstats(event, timems, statchange, newvalue, statId)
	if statId ~= nil then
		if statId == LIBCOMBAT_STAT_SPELLCRIT then
			Overcrit.spellCritChance = 0.01 * GetCriticalStrikeChance(newvalue)
		elseif statId == LIBCOMBAT_STAT_SPELLCRITBONUS then
			Overcrit.spellCritBonus = 1.0 + 0.01 * newvalue
			Overcrit.statsInitializedS = 1
		elseif statId == LIBCOMBAT_STAT_WEAPONCRIT then
			Overcrit.weaponCritChance = 0.01 * GetCriticalStrikeChance(newvalue)
		elseif statId == LIBCOMBAT_STAT_WEAPONCRITBONUS then
			Overcrit.weaponCritBonus = 1.0 + 0.01 * newvalue
			Overcrit.statsInitializedW = 1
		end
	end
end

local function UpdateStats()
	
	if Overcrit.damage > 0 then
		local loss = 0.0
		if Overcrit.damageNoCC > 0 then
			loss = 100.0*(Overcrit.damageNoCC - Overcrit.damage)/Overcrit.damageNoCC
		end
		OvercritUIBoxLabel:SetText(string.format("%1.1f", loss))
			
		local m = 1.0
		
		if Overcrit.inCombat then
			m = Overcrit.m
			OvercritUIBoxLabel2:SetText(string.format("%1.1f", 100*m))
		else
			if Overcrit.sumw > 0 then
				m = Overcrit.sum / Overcrit.sumw
			end
			OvercritUIBoxLabel2:SetText(string.format("<%1.1f>", 100*m))
		end
		
		if m > 1.29 then
			OvercritUIBg:SetCenterColor(0.9,0.1,0.1,0.7)
		elseif loss > 2 then
			OvercritUIBg:SetCenterColor(0.9,0.1,0.1,0.7)
		elseif m > 1.25 then
			OvercritUIBg:SetCenterColor(0.5,0.4,0.2,0.5)
		elseif loss > 1 then
			OvercritUIBg:SetCenterColor(0.5,0.4,0.2,0.7)
		elseif loss > 0 then
			OvercritUIBg:SetCenterColor(0.5,0.4,0.2,0.5)
		else
			OvercritUIBg:SetCenterColor(0.2,0.2,0.2,0.2)
		end
	end
end

local function ResetStats()
	Overcrit.startTime = 0
	Overcrit.endTime = 0
	Overcrit.damage = 0
	Overcrit.sum = 0
	Overcrit.sumw = 0
	Overcrit.damageNoCC = 0
	Overcrit.maxHpTargetHp = 0
	Overcrit.maxHpTargetName = ""
end


local function OnCombatEvent(eventCode, result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	local gameTime = GetGameTimeMilliseconds()

	--
	if powerType ~= -1 and (damageType > 0 and hitValue ~= nil and hitValue > 0) then

		local isCriticalDamage    = (result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DOT_TICK_CRITICAL)
		local isNonCriticalDamage = (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DOT_TICK or result == ACTION_RESULT_DAMAGE_SHIELDED)

		-- player/pet hits
		if sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET then

			-- spell / weapon crit
			local m = 0.0 -- crit extra damage as fraction of non-crit damage
			if Overcrit.physicalDamage[damageType] ~= nil then
				m = Overcrit.weaponCritBonus - 1.0
			else
				m = Overcrit.spellCritBonus - 1.0
			end
			
			-- target debuffs
			for key,value in pairs(Overcrit.debuffsIncreasingTakenCritDamage) do
				if Overcrit.debuffsActive[targetUnitId] ~= nil and Overcrit.debuffsActive[targetUnitId][key]~= nil and gameTime < Overcrit.debuffsActive[targetUnitId][key] then
					m = m + value
				end
			end

			if Overcrit.debuffsActive[targetUnitId] ~= nil and Overcrit.debuffsActive[targetUnitId][95136] ~= nil and Overcrit.debuffsActive[targetUnitId][95136] > gameTime then
				m = m + Overcrit.passiveGlacialPresence -- only non-zero with warden passive
			end
			
			Overcrit.m = m
			local m_noCC = m
			if m > Overcrit.critDamageCap then m = Overcrit.critDamageCap end

			Overcrit.damage = Overcrit.damage + hitValue
			
			local hitValueNoCC = hitValue
			if isCriticalDamage then
				hitValueNoCC = (1.0+m_noCC)*hitValue/(1.0 + m)
			end
			
			Overcrit.damageNoCC = Overcrit.damageNoCC + hitValueNoCC

			if (Overcrit.startTime < 1 ) then
				Overcrit.startTime = gameTime
			end
			Overcrit.endTime = gameTime
			
			if Overcrit.statsInitializedW > 0 and Overcrit.statsInitializedS > 0 then
				Overcrit.sum  = Overcrit.sum  + m_noCC * hitValueNoCC
				Overcrit.sumw = Overcrit.sumw + hitValueNoCC
			end
		end

		if gameTime - Overcrit.lastUpdateTime > Overcrit.updateInterval then
			Overcrit.lastUpdateTime = gameTime
			UpdateStats()
		end

	end

end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType) 
	if Overcrit.debuffsActive[unitId] == nil then
		Overcrit.debuffsActive[unitId] = {}
	end
	Overcrit.debuffsActive[unitId][abilityId] = endTime * 1000.0
end

local function OnCombatEventDebuff(eventCode, result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	if Overcrit.debuffsActive[targetUnitId] == nil then
		Overcrit.debuffsActive[targetUnitId] = {}
	end
	if result == ACTION_RESULT_EFFECT_GAINED_DURATION then
		local t = GetGameTimeMilliseconds() + hitValue
		-- don't overwrite longer/permanent debuffs (minor brittle from dummy)
		if Overcrit.debuffsActive[targetUnitId][abilityId] == nil or Overcrit.debuffsActive[targetUnitId][abilityId] < t then
			Overcrit.debuffsActive[targetUnitId][abilityId] = t
		end
	elseif result == ACTION_RESULT_EFFECT_FADED	then
		Overcrit.debuffsActive[targetUnitId][abilityId] = 0
	end

end

local function OnTrialDummyBuffs(eventCode, result, isError,  abilityName,  abilityGraphic,  abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue,  powerType,  damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	-- apply a permanent minor brittle debuff
	if Overcrit.debuffsActive[sourceUnitId] == nil then
		Overcrit.debuffsActive[sourceUnitId] = {}
	end
	Overcrit.debuffsActive[sourceUnitId][145975] = GetGameTimeMilliseconds() + 600000
end

local function OnPlayerCombatState(event, inCombat)
	if inCombat and not Overcrit.inCombat then
		Overcrit.inCombat = inCombat
	elseif not inCombat and Overcrit.inCombat then
		Overcrit.inCombat = inCombat
		UpdateStats()
		ResetStats()
		Overcrit.debuffsActive = {}
	end
end


function Overcrit.SavePosition()
	Overcrit.savedVariables.positionX = OvercritUI:GetLeft()
	Overcrit.savedVariables.positionY = OvercritUI:GetTop()
end


local function RestorePosition()
	if Overcrit.savedVariables.positionX > -1 and Overcrit.savedVariables.positionY > -1 then
		OvercritUI:ClearAnchors()
		OvercritUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, Overcrit.savedVariables.positionX, Overcrit.savedVariables.positionY)
	end
end

local function LoadSavedVariables()
	Overcrit.characterSavedVariables = ZO_SavedVars:NewCharacterNameSettings("OvercritVars", 1, nil, Overcrit.DefaultSavedVars)
	Overcrit.accountWideSavedVariables = ZO_SavedVars:NewAccountWide("OvercritVars", 1, nil, Overcrit.DefaultSavedVars)
	if Overcrit.characterSavedVariables.accountWide then
		Overcrit.savedVariables = Overcrit.accountWideSavedVariables
		Overcrit.savedVariables.accountWide = true
	else
		Overcrit.savedVariables = Overcrit.characterSavedVariables
	end
end

local function InitializeMenu()

    local panelData = {
        type = "panel",
        name = Overcrit.name,
        displayName = Overcrit.name,
        author = "Psiioniic",
        version = Overcrit.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(Overcrit.settingsName, panelData)

	local optionsTable = {
		{
			type = "header",
			name = "Overcrit help / settings",
			width = "full",
		},
		{
			type = "description",
			text = "Shows what fraction of damage is lost due to crit cap (in percent, left) and crit bonus modifier (in percent, right). After a fight, the effective value is shown.",
			width = "full",
		},
		{
			type = "description",
			text = "The add-on uses libCombat to get crit damage modifier for the character (which includes most buffs, sets etc.) and takes into account debuffs on enemy: minor brittle, elemental catalyst, chilled (w/ glacial presence passive).",
			width = "full",
		},
		{
			type = "checkbox",
			name = "Debug",
			tooltip = "",
			getFunc = function()
				return Overcrit.savedVariables.debug
			end,
			setFunc = function(value)
				Overcrit.savedVariables.debug = value
			end,
			width = "full",
			default = false,
			requiresReload = false,
		},
	}
	LibAddonMenu2:RegisterOptionControls(Overcrit.settingsName, optionsTable)
end

local function RegisterInSceneManager()
	HUD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(OvercritUI))
	HUD_UI_SCENE:AddFragment(ZO_SimpleSceneFragment:New(OvercritUI))
end

local function OnAddOnLoaded(event, addon)
	if addon ~= Overcrit.name then return end

	EVENT_MANAGER:UnregisterForEvent(Overcrit.name, EVENT_ADD_ON_LOADED)
	LibCombat:RegisterCallbackType(LIBCOMBAT_EVENT_PLAYERSTATS, OnLibcombatEventPlayerstats, Overcrit.name)

	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEvent", EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEvent", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."PlayerCombatState", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)

	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEventPet", EVENT_COMBAT_EVENT, OnCombatEvent)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventPet", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)

	-- chilled
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEventChilled", EVENT_COMBAT_EVENT, OnCombatEventDebuff)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventChilled", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventChilled", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95136)
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEventChilledT", EVENT_COMBAT_EVENT, OnCombatEventDebuff)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventChilledT", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventChilledT", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 95136)
	
	-- brittle
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."EffectChangedMinorBrittle", EVENT_EFFECT_CHANGED , OnEffectChanged)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."EffectChangedMinorBrittle", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 145975)
	
	-- EC
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEventEC1", EVENT_COMBAT_EVENT, OnCombatEventDebuff)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventEC1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 142610)
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEventEC2", EVENT_COMBAT_EVENT, OnCombatEventDebuff)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventEC2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 142652)
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."CombatEventEC3", EVENT_COMBAT_EVENT, OnCombatEventDebuff)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."CombatEventEC3", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 142653)
	
	-- trial dummy brittle
	EVENT_MANAGER:RegisterForEvent(Overcrit.name.."TrialDummyBuffs", EVENT_COMBAT_EVENT, OnTrialDummyBuffs)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."TrialDummyBuffs", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 120024) -- worms raiment, source unitid will be the dummy
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."TrialDummyBuffs", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
	EVENT_MANAGER:AddFilterForEvent(Overcrit.name.."TrialDummyBuffs", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_TARGET_DUMMY)

	LoadSavedVariables()
	RestorePosition()

	zo_callLater(InitializeMenu, 700)
	zo_callLater(RegisterInSceneManager, 1000)
	
	local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(86192) -- Glacial presence
	local currentLevel = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, skillIndex)
	Overcrit.passiveGlacialPresence = currentLevel * Overcrit.passiveGlacialPresencePerLevel

end

EVENT_MANAGER:RegisterForEvent(Overcrit.name, EVENT_ADD_ON_LOADED, function(...) OnAddOnLoaded(...) end)
