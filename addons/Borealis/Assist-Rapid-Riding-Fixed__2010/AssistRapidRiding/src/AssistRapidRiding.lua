
-- 0. Declare
local arr = {
	name = "AssistRapidRiding",
	version = "1.14",
	savedVarsName = "ARRSV",
	savedVarsVersion = "1.0",
}
AssistRapidRiding = arr
local pairs = pairs
local unpack = unpack
local tokenSeed = 0
local rapidManeuverRefId = 38566
ZO_CreateStringId("SI_BINDING_NAME_ARR_SWITCH", "Manual Switch")

-- X. Utils
function arr.UtilDebug(level)
	local debugLevel = arr.SettingsVarGet('debugLevel')
	return debugLevel and debugLevel >= level
end

function arr.UtilRecover()
	if arr.UtilDebug(1) then d('arr.UtilRecover called') end
	if arr.characterSavedVars.oldSkillAbility ~= nil then
		local osa = arr.characterSavedVars.oldSkillAbility
		if IsUnitInCombat('player') then
			zo_callLater(function() arr.UtilRecover() end, 1000)
			return
		end
		local weaponPair = GetActiveWeaponPairInfo()
		if weaponPair ~= osa.weaponPair then
			arr.queueRecover=true
			return
		end
		if arr.UtilDebug(1) then d('arr.UtilRecover '..' ('..osa.skillType..','..osa.skillIndex..','..osa.abilityIndex..') abilityId:'..(osa.abilityId or 'not saved')) end
		SlotSkillAbilityInSlot(osa.skillType, osa.skillIndex, osa.abilityIndex, osa.slotNum)
		arr.characterSavedVars.oldSkillAbility = nil
		arr.queueRecover = false
	end
end

function arr.UtilSave(slotNum)
	local abilityId = GetSlotBoundId(slotNum)
	if GetSkillAbilityId(arr.rmInfo.skillType, arr.rmInfo.skillIndex, arr.rmInfo.abilityIndex, false)==abilityId then return end
	local _,progressionIndex = GetAbilityProgressionXPInfoFromAbilityId(abilityId)
	local info = arr.progressionIndexToInfo[progressionIndex]
	local weaponPair = GetActiveWeaponPairInfo()
	if arr.UtilDebug(1) then d('arr.UtilSave slot'..slotNum..' ('..info.skillType..','..info.skillIndex..','..info.abilityIndex..') abilityId:'..info.abilityId) end
	arr.characterSavedVars.oldSkillAbility = {
		skillType = info.skillType,
		skillIndex = info.skillIndex,
		abilityIndex = info.abilityIndex,
		abilityId = info.abilityId,
		abilityName = info.abilityName,
		slotNum = slotNum,
		weaponPair = weaponPair,
	}
end

function arr.UtilSwitch(token, force)
	local now = GetGameTimeMilliseconds()
	-- check
	if not arr.rmInfo then return end
	if token ~= arr.token then return end
	if not force and not arr.mounted then return end
	if not force and arr.coverTime and arr.coverTime > now then
		zo_callLater(function() arr.UtilSwitch(token) end, arr.coverTime-now)
		return
	end
	if IsUnitInCombat('player') then
		zo_callLater(function() arr.UtilSwitch(token) end, 1000)
		return
	end
	if arr.UtilDebug(1) then d('arr.UtilSwitch token:'..token) end
	
	--  save old info
	local slotNum = arr.SettingsVarGet('switchSlot') + 2
	if arr.rmInfo.abilityId == GetSlotBoundId(slotNum) then return end
	arr.UtilSave(slotNum)
	
	-- switch ability
	arr.queueRecover = false
	if arr.SettingsVarGet('soundEnabled') then PlaySound(SOUNDS[arr.soundChoices[arr.SettingsVarGet('soundIndex')]]) end
	SlotSkillAbilityInSlot(arr.rmInfo.skillType, arr.rmInfo.skillIndex, arr.rmInfo.abilityIndex, slotNum)

	-- $$$$$. We cannot call the button function
	-- zo_callLater(
		-- function()
			-- --local button = ZO_ActionBar_GetButton(slotNum)
			-- --button.HandlePressAndRelease(button)
			-- CallSecureProtected('ActionButtonDownAndUp',slotNum)
		-- end, 
		-- 1000
	-- )
end

-- X. Prepare
function arr.Prepare()

	arr.progressionIndexToInfo = {}
	arr.rmInfo = nil
	local hasPrgression,rmProgressionIndex = GetAbilityProgressionXPInfoFromAbilityId(rapidManeuverRefId)
	if not hasPrgression then return end
	for skillType = 1, GetNumSkillTypes() do
		for skillIndex = 1, GetNumSkillLines(skillType) do
			for abilityIndex = 1, math.min(7, GetNumAbilities(skillType, skillIndex)) do
				local abilityId = GetSkillAbilityId(skillType, skillIndex, abilityIndex, false)
				local abilityName, _,_,_,_,_, progressionIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
				if rmProgressionIndex == progressionIndex then
					arr.rmInfo = {
						skillType = skillType,
						skillIndex = skillIndex,
						abilityIndex = abilityIndex,
						abilityId = abilityId,
					}
				end
				if progressionIndex then 
					arr.progressionIndexToInfo[progressionIndex] = {
						skillType = skillType,
						skillIndex = skillIndex,
						abilityIndex = abilityIndex,
						abilityId = abilityId,
						abilityName = abilityName,
					}
				end
			end
		end
	end
end

-- X. Bindings
function arr.BindingsSwitch()
	if arr.characterSavedVars.oldSkillAbility ~= nil then
		arr.UtilRecover()
		return
	end
	tokenSeed = tokenSeed+1
	arr.token = tokenSeed
	arr.UtilSwitch(tokenSeed, true)
end

-- X. Listener
function arr.OnMountedStateChanged(eventCode, mounted)
    if arr.SettingsVarGet('hotkeyOnly') then return end
	arr.mounted = mounted
	if not mounted then
		if arr.characterSavedVars.oldSkillAbility ~= nil then
			arr.UtilRecover()
		end
		return 
	end
	
	tokenSeed = tokenSeed+1
	arr.token = tokenSeed
	arr.UtilSwitch(tokenSeed, false)
end

function arr.OnPlayerActivated(eventCode, initial)
	arr.Prepare()
	if not IsMounted() then
		arr.UtilRecover()
	end
end

function arr.OnSlotAbilityUsed(eventCode, slotNum)
	if not IsMounted() then return end -- do not check if not mounted
	local abilityId = GetSlotBoundId(slotNum)
	if arr.UtilDebug(1) then d('arr.OnSlotAbilityUsed '..GetSlotName(slotNum)) end
	if GetSkillAbilityId(arr.rmInfo.skillType, arr.rmInfo.skillIndex, arr.rmInfo.abilityIndex, false)==abilityId then
		arr.coverTime = GetGameTimeMilliseconds() + GetAbilityDuration(abilityId) - arr.SettingsVarGet('reswitchAhead') * 1000
		-- recover
		arr.UtilRecover()
		
		-- keep on check beyond buff
		tokenSeed = tokenSeed+1
		arr.token = tokenSeed
		arr.UtilSwitch(tokenSeed, false)
		return
	end
end

function arr.OnActiveWeaponPairChanged(eventCode, weaponPair, locked)
	if arr.queueRecover and arr.characterSavedVars.oldSkillAbility then
		arr.UtilRecover()
	end
end

-- X. Hook
function arr.Hook()
	EVENT_MANAGER:RegisterForEvent(arr.name, EVENT_MOUNTED_STATE_CHANGED, arr.OnMountedStateChanged)
	EVENT_MANAGER:RegisterForEvent(arr.name, EVENT_ACTION_SLOT_ABILITY_USED, arr.OnSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent(arr.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, arr.OnActiveWeaponPairChanged)
	EVENT_MANAGER:RegisterForEvent(arr.name, EVENT_PLAYER_ACTIVATED, arr.OnPlayerActivated)
end

-- $. Addon
local function OnAddOnLoaded(eventCode, addonName)
	-- check and clear
	if arr.name ~= addonName then return end
	EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	--
	arr.Prepare()
	arr.SettingsLoad()
	arr.SettingsMenu()
	arr.Hook()
end

EVENT_MANAGER:RegisterForEvent(arr.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)