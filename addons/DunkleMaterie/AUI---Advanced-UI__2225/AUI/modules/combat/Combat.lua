AUI.Combat = {}
AUI.Combat.Minimeter = {}
AUI.Combat.Statistics = {}
AUI.Combat.Text = {}
AUI.Combat.DamageMeter = {}
AUI.Combat.WeaponChargeWarner = {}

--Combat
AUI_COMBAT_DATA_TYPE_NONE = 1
AUI_COMBAT_DATA_TYPE_DAMAGE_OUT = 2
AUI_COMBAT_DATA_TYPE_HEAL_OUT = 3
AUI_COMBAT_DATA_TYPE_DAMAGE_IN = 4
AUI_COMBAT_DATA_TYPE_HEAL_IN = 5

AUI_COMBAT_DATA_TYPE_DAMAGE = 10
AUI_COMBAT_DATA_TYPE_HEAL = 12

local MAX_RECORD_COUNT = 30

local isLoaded = false
local isCombatMeterStarted = false
local ultiReady = false
local potionReady = false
local playerName = GetRawUnitName(AUI_PLAYER_UNIT_TAG)
local idList = {}
local abilityProcEffects = {}
local combatDataList = {}
local playerSourceId = nil
local combatTimeMS = 0
local stoppedTimeMS = -1
local wasUnitInCombat = false
local isPlayer = 
{
	[COMBAT_UNIT_TYPE_PLAYER] 			= true,
	[COMBAT_UNIT_TYPE_PLAYER_PET] 		= true,
}

local isPet = 
{
	[COMBAT_UNIT_TYPE_PLAYER_PET] 		= true,
}


local isGroup = 
{
	[COMBAT_UNIT_TYPE_GROUP] 			= true,
}

local isDamage = 
{
	[ACTION_RESULT_DAMAGE] 				= true,
	[ACTION_RESULT_CRITICAL_DAMAGE] 	= true,
	[ACTION_RESULT_DOT_TICK]            = true,
	[ACTION_RESULT_DOT_TICK_CRITICAL]   = true,
	[ACTION_RESULT_FALL_DAMAGE]         = true,
	[ACTION_RESULT_DAMAGE_SHIELDED] 	= true,
	[ACTION_RESULT_BLOCKED_DAMAGE]		= true,
}

local isCrit = 
{
	[ACTION_RESULT_CRITICAL_DAMAGE] 	= true,
	[ACTION_RESULT_DOT_TICK_CRITICAL]   = true,
	[ACTION_RESULT_CRITICAL_HEAL]       = true,
	[ACTION_RESULT_HOT_TICK_CRITICAL]   = true,	
}

 local isHeal = {
	[ACTION_RESULT_HEAL]                = true,
	[ACTION_RESULT_CRITICAL_HEAL]       = true,
	[ACTION_RESULT_HOT_TICK]            = true,
	[ACTION_RESULT_HOT_TICK_CRITICAL]   = true,	
}

local experienceData = {}
local combatData = {}

local _, oldHealthValue, _ = GetUnitPower(AUI_PLAYER_UNIT_TAG, POWERTYPE_HEALTH)
local _, oldMagickaValue, _ = GetUnitPower(AUI_PLAYER_UNIT_TAG, POWERTYPE_MAGICKA)
local _, oldStaminaValue, _ = GetUnitPower(AUI_PLAYER_UNIT_TAG, POWERTYPE_STAMINA)

local isHealthLow = false
local isMagickaLow = false
local isStaminaLow = false

local function IsPlayer(_sourceType)
	if isPlayer[_sourceType] then
		return true
	end
	
	return false
end

local function IsPet(_sourceType)
	if isPet[_sourceType] then
		return true
	end
	
	return false
end

local function IsGroup(_sourceType)
	if isGroup[_sourceType] then
		return true
	end
	
	return false
end

local function ClearCombatData()
	combatData = {}

	for _, data in pairs(idList) do	
		if not IsPlayer(data.unitType) and not IsGroup(data.unitType) then
			data= nil
		end
	end
	
	combatTimeMS = 0
	
	AUI.ResetMiniMeter()
end

local function IsCrit(_result)
	if isCrit[_result] then
			return true
	end
	
	return false
end

local function UpdateData(_value, _isCrit, _data, _ms)
	if _data and _ms then
		if _data.endTimeMS then
			_data.endTimeMS = (_ms - _data.startTimeMS)
		end
	
		if _value and _value > 0 then
			_data.total = _data.total + _value
			if _isCrit then
				_data.crit = _data.crit + _value
			else
				_data.damage = _data.damage + _value
			end
			_data.hitCount = _data.hitCount + 1
		end
	end
	
	return _data
end

local function IsAbilitySlotted(_abilityId)
	for slotId = 3, 8 do
		local slotName = GetSlotName(slotId)
		local abilityName = GetAbilityName(_abilityId)
	
		if slotName == abilityName then
			return true	
		end	
	end
	
	return false
end

local recordCount = 0

local function IsUnitOrGroupInCombat()
	local isPlayerGrouped = IsUnitGrouped(AUI_PLAYER_UNIT_TAG)
	local inCombat = false

	if isPlayerGrouped then
		for i = 1, GetGroupSize(), 1 do
			local unitTag = GetGroupUnitTagByIndex(i)
			local isUnitInRange = IsUnitInGroupSupportRange(unitTag)
			if isUnitInRange then
				inCombat = IsUnitInCombat(unitTag)
				
				if inCombat then
					return true
				end
			else
				inCombat = IsUnitInCombat(AUI_PLAYER_UNIT_TAG)	
			end
		end
	else
		inCombat = IsUnitInCombat(AUI_PLAYER_UNIT_TAG)	
	end
	
	return inCombat
end

local function OnUpdateUI()
	if AUI.Combat.Minimeter.IsEnabled() then
		AUI.Combat.Minimeter.UpdateAll()
	end
	
	if AUI.Combat.Statistics.IsShow() then
		AUI.Combat.Statistics.UpdateUI()
	end
end

local function StopCombatMeter()
	if isCombatMeterStarted and not IsUnitOrGroupInCombat()	then
		EVENT_MANAGER:UnregisterForUpdate("AUI_Combat_OnUpdate")
		EVENT_MANAGER:UnregisterForUpdate("AUI_Combat_OnUpdateUI")	
	
		local ms = GetGameTimeMilliseconds()

		combatTimeMS = combatTimeMS - (ms - stoppedTimeMS)

		isCombatMeterStarted = false

		local dateString = GetTimeStamp()

		local records =  {}
		records.data = combatData
		records.dateString = dateString
		records.formatedDate = GetDateStringFromTimestamp(GetTimeStamp()) .. " " .. GetTimeString()
		records.combatTime = combatTimeMS / 1000
		
		table.insert(combatDataList, records)

		if recordCount >= MAX_RECORD_COUNT then
			table.remove(combatDataList, 1)
			recordCount = recordCount - 1
		end
		
		recordCount = recordCount + 1
		
		OnUpdateUI()
	end
	
	stoppedTimeMS = -1
end

local function OnUpdate()
	if not isCombatMeterStarted then
		return
	end

	local playerData = combatData[playerSourceId]
	if playerData then
		local ms = GetGameTimeMilliseconds() 
		local endTimeMS = ms - playerData.startTimeMS

		combatTimeMS = endTimeMS
		
		if not IsUnitOrGroupInCombat() then	
			if wasUnitInCombat then
				if stoppedTimeMS == -1 then
					stoppedTimeMS = ms
				end
				
				zo_callLater(function() StopCombatMeter() end, 500)
			end
		else
			wasUnitInCombat = true
		end
	end	
end

local function StartCombatMeter()
	wasUnitInCombat = false
	ClearCombatData()
	isCombatMeterStarted = true
	EVENT_MANAGER:UnregisterForUpdate("AUI_Combat_OnUpdateUI")
	EVENT_MANAGER:RegisterForUpdate("AUI_Combat_OnUpdateUI", 100, OnUpdateUI)			
		
	EVENT_MANAGER:UnregisterForUpdate("AUI_Combat_OnUpdate")
	EVENT_MANAGER:RegisterForUpdate("AUI_Combat_OnUpdate", 0, OnUpdate)		
end

function AUI.Combat.IsCombatMeterStarted()
	return isCombatMeterStarted
end

function AUI.Combat.GetPlayerSourceId()
	return playerSourceId
end

function AUI.Combat.GetCombatTime()
	return combatTimeMS / 1000
end

function AUI.Combat.GetPlayerPetOutData()
	local total = 0
	for sourceId, unitData in pairs(combatData) do
		if unitData.init and unitData.unitType == COMBAT_UNIT_TYPE_PLAYER_PET then
			return unitData
		end
	end
	
	return nil
end

function AUI.Combat.GetPlayerData()
	return combatData[playerSourceId]
end

function AUI.Combat.GetLastData()
	return combatDataList[recordCount]
end

function AUI.Combat.RemoveCombatData(_index)
	for key, data in pairs(combatDataList) do
		if data.dateString == _index then
			table.remove(combatDataList, key)
			recordCount = recordCount - 1
		end
	end
end

function AUI.Combat.GetNextData(_currentKey)
	local dataList = AUI.Table.Copy(combatDataList)

	table.sort(dataList, function(a, b) if a.dateString > b.dateString then return true end end)	

	local lastData = nil
	for key, data in pairs(dataList) do
		if data.dateString ~= _currentKey and _currentKey <= data.dateString then
			lastData = data
		end
	end

	return lastData
end

function AUI.Combat.GetPreviousData(_currentKey)
	local dataList = AUI.Table.Copy(combatDataList)

	table.sort(dataList, function(a, b) if a.dateString < b.dateString then return true end end)	

	local lastData = nil
	for key, data in pairs(dataList) do
		if data.dateString ~= _currentKey and _currentKey >= data.dateString then
			lastData = data
		end
	end

	return lastData
end

local function GetCombatString(_unitData, _type)
	local str = ""
	if _unitData and _unitData.startTimeMS > 0 then	
		local endTimeS =  AUI.Time.MS_To_S(_unitData.endTimeMS)
		local time = 0	

		if endTimeS > 1 then
			time = AUI.Time.GetFormatedString(endTimeS, 1)
		elseif endTimeS > 0.1 then
			time = AUI.Time.GetFormatedString(endTimeS, 2)	
		else
			time = AUI.Time.GetFormatedString(endTimeS, 3)
		end

		local total = _unitData.total
		local avarage = AUI.Combat.CalculateDPS(total, _unitData.endTimeMS)			

		if _type == AUI_COMBAT_DATA_TYPE_DAMAGE_OUT then
			if total > 0 then
				str = str .. "Damage (Out): " .. AUI.String.ToFormatedNumber(total) .. " (" .. time .. ")"
			end
		
			if avarage > 0 then
				str = str .. " - DPS (Out): " .. AUI.String.ToFormatedNumber(avarage)
			end		
		end

		if _type == AUI_COMBAT_DATA_TYPE_DAMAGE_IN then
			if total > 0 then
				str = str .. " - Damage (In): " .. AUI.String.ToFormatedNumber(total) .. " (" .. time .. ")"
			end
		
			if avarage > 0 then
				str = str .. " - DPS (In): " .. AUI.String.ToFormatedNumber(avarage)
			end		
		end			
		
		if _type == AUI_COMBAT_DATA_TYPE_HEAL_OUT then
			if total > 0 then
				str = str .. " - Heal (Out): " .. AUI.String.ToFormatedNumber(total) .. " (" .. time .. ")"
			end

			if avarage > 0 then
				str = str .. " - HPS (Out): " .. AUI.String.ToFormatedNumber(avarage)
			end				
		end				

		if _type == AUI_COMBAT_DATA_TYPE_HEAL_IN then
			if total > 0 then
				str = str .. " - Heal (In): " .. AUI.String.ToFormatedNumber(total) .. " (" .. time .. ")"
			end

			if avarage > 0 then
				str = str .. " - HPS (In): " .. AUI.String.ToFormatedNumber(avarage)
			end				
		end				
	end
	
	return str
end

local function GetHighestTarget(_sourceUnitData)
	if not _sourceUnitData then
		return nil
	end

	local lastTargetId = nil

	if _sourceUnitData then
		for targetUnitId, targetData in pairs(_sourceUnitData.targets) do
			if not lastTargetData or targetData.total > lastTargetData.total then
				lastTargetId = targetUnitId
			end
		end
	end
	
	return lastTargetId
end

function AUI.Combat.CheckError()
	local errorString = ""
	local error = false

	if IsUnitOrGroupInCombat() then
		errorString = errorString .. AUI.L10n.GetString("waiting_for_combat_end")
		error = true
	elseif not AUI.Table.HasContent(combatDataList) then
		errorString = errorString .. AUI.L10n.GetString("no_records_available")
		error = true
	end

	return error, errorString
end

function AUI.Combat.GetHighestTargetData(_sourceUnitData)
	local targetUnitData = nil
	local type = AUI_COMBAT_DATA_TYPE_DAMAGE_OUT
	
	if _sourceUnitData then
		local unitDamageOutData = _sourceUnitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT]
		local unitHealOutData = _sourceUnitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT]
		local totalDamage = 0
		local totalheal = 0
		
		if unitDamageOutData then
			totalDamage = AUI.Combat.GetTotalValue(unitDamageOutData.targets, "total", true)
		end
		
		if unitHealOutData then
			totalheal = AUI.Combat.GetTotalValue(unitHealOutData.targets, "total", true)
		end
		
		if totalheal > totalDamage then
			type = AUI_COMBAT_DATA_TYPE_HEAL_OUT
		end

		local targetUnitId = GetHighestTarget(_sourceUnitData[type])
		if targetUnitId then
			targetUnitData = _sourceUnitData[type].targets[targetUnitId]
		end
	end	
		
	return targetUnitData, type
end

function AUI.Combat.PostHighestTargetCombatStatistics()
	local sourceUnitData = combatData[playerSourceId]
	local error, errorMessage  = AUI.Combat.CheckError()
	
	if error then
		d("ACS: v." .. AUI_COMBAT_VERSION .. " " .. errorMessage)
		return
	end

	local targetUnitData, type = AUI.Combat.GetHighestTargetData(sourceUnitData)
	if targetUnitData and type then
		local str = "AUI-CS: v." .. AUI_COMBAT_VERSION .. " | "
		
		str = str .. AUI.String.FirstToUpper(zo_strformat(SI_UNIT_NAME, sourceUnitData.unitName))
		str = str .. " at "
		str = str .. AUI.String.FirstToUpper(zo_strformat(SI_UNIT_NAME, combatData[targetUnitData.targetUnitId].unitName))
		str = str .. " => "	
		str = str .. GetCombatString(targetUnitData, type)

		StartChatInput(str, CHAT_CHANNEL_PARTY , nil)
	end
end

function AUI.Combat.PostPlayerCombatStatistics()		
	AUI.Combat.PostCombatStatistics(playerSourceId, nil, nil, true)	
end

function AUI.Combat.PostCombatStatistics(_sourceUnitId, _type, _targetUnitId, calculatePetData)	
	local str = "AUI-CS: v." .. AUI_COMBAT_VERSION .. " | "
	
	local sourceUnitData = combatData[_sourceUnitId]
	
	if calculatePetData and playerSourceId and _sourceUnitId == playerSourceId then
		sourceUnitData = combatData[playerSourceId]
	end
	
	local targetUnitData = nil
	
	if _targetUnitId then
		targetUnitData = combatData[_targetUnitId]
	end

	local error, errorMessage  = AUI.Combat.CheckError()
	
	if error then
		d("ACS: v." .. AUI_COMBAT_VERSION .. " " .. errorMessage)
		return
	end	
	
	if not _targetUnitId then
		if _type then
			str = str .. GetCombatString(sourceUnitData[_type], _type)	
		else
			str = str .. GetCombatString(sourceUnitData[AUI_COMBAT_DATA_TYPE_DAMAGE_OUT], AUI_COMBAT_DATA_TYPE_DAMAGE_OUT)
			str = str .. GetCombatString(sourceUnitData[AUI_COMBAT_DATA_TYPE_HEAL_OUT], AUI_COMBAT_DATA_TYPE_HEAL_OUT)
			str = str .. GetCombatString(sourceUnitData[AUI_COMBAT_DATA_TYPE_DAMAGE_IN], AUI_COMBAT_DATA_TYPE_DAMAGE_IN)
			str = str .. GetCombatString(sourceUnitData[AUI_COMBAT_DATA_TYPE_HEAL_IN], AUI_COMBAT_DATA_TYPE_HEAL_IN)	
		end
	elseif _type and _targetUnitId and sourceUnitData[_type] and sourceUnitData[_type].targets then
		str = str .. zo_strformat(SI_UNIT_NAME, sourceUnitData.unitName)
		str = str .. " at "
		str = str .. targetUnitData.unitName
		str = str .. " => "
		str = str .. GetCombatString(sourceUnitData[_type].targets[_targetUnitId], _type)
	end
	
	StartChatInput(str, CHAT_CHANNEL_PARTY , nil)
end

function AUI.Combat.CalculateDPS(_totalDamage, _time)
	local average = 0

	if _totalDamage and _time then
		local value = _totalDamage
		local s = _time / 1000

		if s > 0 then
			average = AUI.Math.Round(_totalDamage / s)
		end
	end
	
	if average >= _totalDamage then
		average = _totalDamage
	end
	
	return average
end

function AUI.Combat.CalculateCritPrecent(_totalDamage, _totalCrit)
	return (_totalCrit / _totalDamage) * 100
end

function AUI.Combat.GetTotalValue(_targetList, _index, _calculatePet)
	local value = 0

	if _targetList and _index then
		for targetId, targetData in pairs(_targetList) do
			if not targetData.isPet or _calculatePet and targetData.isPet then
				value = value + targetData[_index]
			end
		end	
	end
	
	return value
end

function AUI.Combat.GetTotalAbilityList(_targetList)
	local abilityList = {}

	for _, targetData in pairs(_targetList) do					
		for _, abilityData in pairs(targetData.abilities) do
			local abilityName = GetAbilityName(abilityData.abilityId)
			local newAbilityData = abilityList[abilityName]
			if not newAbilityData then
				abilityList[abilityData.abilityName] = {total = 0, crit = 0, hitCount = 0, abilityId = abilityData.abilityId, icon = abilityData.icon}
				newAbilityData = abilityList[abilityData.abilityName]
			end
					
			newAbilityData.total = newAbilityData.total + abilityData.total
			newAbilityData.crit = newAbilityData.crit + abilityData.crit
			newAbilityData.hitCount = newAbilityData.hitCount + abilityData.hitCount
		end	
	end		
	
	return abilityList
end

local function CreateData(_unitId, _unitType, _combatType)
	if not _unitId or not _unitType or not _combatType then
		return nil
	end	

	if not combatData[_unitId] then	
		combatData[_unitId] = {}	
		combatData[_unitId].init = false
		combatData[_unitId].valid = false
		combatData[_unitId].unitName = "Unit: " .. _unitId
		combatData[_unitId].sourceUnitId = _unitId	
		combatData[_unitId].startTimeMS = 0
		combatData[_unitId].endTimeMS = 0			
	end
	
	if not combatData[_unitId][_combatType] then
		combatData[_unitId][_combatType] = {}	
		combatData[_unitId][_combatType].targets = {}	
		combatData[_unitId][_combatType].total = 0
		combatData[_unitId][_combatType].damage = 0
		combatData[_unitId][_combatType].crit = 0
		combatData[_unitId][_combatType].hitCount = 0
		combatData[_unitId][_combatType].startTimeMS = 0
		combatData[_unitId][_combatType].endTimeMS = 0		
	end	
			
	if idList[_unitId] then
		combatData[_unitId].unitName = idList[_unitId].unitName

		if IsPlayer(_unitType) or IsGroup(_unitType) then
			combatData[_unitId].valid = true	
		end
	end	
	
	return combatData[_unitId]
end	

local function AddData(_sourceUnitId, _sourceType, _targetUnitId, _targetType, _hitValue, _isCrit, _abilityName, _abilityId, _abilityTexture, _combatType, _isPet)
	if not _sourceUnitId or _sourceUnitId == 0 or not _sourceType or not _targetUnitId or _targetUnitId == 0 or not _combatType then
		return false
	end
	
	local data = CreateData(_sourceUnitId, _sourceType, _combatType)
	if data then
		local ms = GetGameTimeMilliseconds()
	
		if data.startTimeMS == 0 then
			data.startTimeMS = ms
		end	
	
		if data[_combatType].startTimeMS == 0 then
			data[_combatType].startTimeMS = ms
		end	

		data[_combatType].isPet = _isPet
		
		UpdateData(_hitValue, _isCrit, data[_combatType], ms)

		if not data[_combatType].targets[_targetUnitId] then
			data[_combatType].targets[_targetUnitId] = {sourceUnitId = _sourceUnitId, total = 0, damage = 0, crit= 0, startTimeMS = ms, endTimeMS = 0, hitCount = 0, targetUnitId = _targetUnitId, isPet = _isPet, abilities = {}}
		end		

		UpdateData(_hitValue, _isCrit, data[_combatType].targets[_targetUnitId], ms)

		if data[_combatType].targets[_targetUnitId] then
			if not data[_combatType].targets[_targetUnitId].abilities[_abilityId] then
				if AUI.String.IsEmpty(_abilityName) then
					_abilityName = AUI.L10n.GetString("unknown")
				end		
			
				if _isPet then
					_abilityName = _abilityName .. " (Pet)"
				end
				
				data[_combatType].targets[_targetUnitId].abilities[_abilityId] = {total = 0, damage = 0, crit= 0, hitCount = 0, abilityName = _abilityName, abilityId = _abilityId, icon = _abilityTexture}
			end

			UpdateData(_hitValue, _isCrit, data[_combatType].targets[_targetUnitId].abilities[_abilityId] , ms)				
		end

		if data.valid then
			data.init = true
			
			if _sourceType == COMBAT_UNIT_TYPE_PLAYER and not playerSourceId then
				playerSourceId = _sourceUnitId
			end
			
			return data
		end	
	end
end	

function AUI.Combat.OnCombatEvent(_eventCode, _result, _isError, _abilityName, _abilityGraphic, _abilityActionSlotType, _sourceName, _sourceType, _targetName, _targetType, _hitValue, _powerType, _damageType, _log, _sourceUnitId, _targetUnitId, _abilityId)
	if not isLoaded or _isError or _hitValue == 0 then
		return
	end	
	
	if not idList[_sourceUnitId] or idList[_sourceUnitId] and idList[_sourceUnitId].unitName ~= _sourceName then
		if not _sourceName or _sourceName == "" then
			_sourceName = AUI.L10n.GetString("unknown")
		end
	
		idList[_sourceUnitId] = {
			["unitName"] = zo_strformat(SI_UNIT_NAME, _sourceName),
			["unitType"] = _sourceType,
		}
	end
	
	if not idList[_targetUnitId] or idList[_targetUnitId] and idList[_targetUnitId].unitName ~= _targetName then
		if not _targetName or _targetName == "" then
			_targetName = AUI.L10n.GetString("unknown")
		end		
	
		idList[_targetUnitId] = {
			["unitName"] = zo_strformat(SI_UNIT_NAME, _targetName),
			["unitType"] = _targetType,
		}
	end	

	if not isCombatMeterStarted and IsPlayer(_sourceType) and (isDamage[_result] or isHeal[_result]) then
		StartCombatMeter()
	end
	
	if isDamage[_result] then	
		local abilityTexture = GetAbilityIcon(_abilityId) or "/esoui/art/icons/icon_missing.dds"
		local abilityName = zo_strformat(SI_ABILITY_NAME, _abilityName)
		local isCrit = IsCrit(_result)

		if isCombatMeterStarted then
			local sourceData = AddData(_sourceUnitId, _sourceType, _targetUnitId, _targetType, _hitValue, isCrit, abilityName, _abilityId, abilityTexture, AUI_COMBAT_DATA_TYPE_DAMAGE_OUT)
			AddData(_targetUnitId, _targetType, _sourceUnitId, _sourceType, _hitValue, isCrit, abilityName, _abilityId, abilityTexture, AUI_COMBAT_DATA_TYPE_DAMAGE_IN)		
		
			if IsPet(_sourceType) then
				local petData = AddData(playerSourceId, COMBAT_UNIT_TYPE_PLAYER, _targetUnitId, _targetType, _hitValue, isCrit, abilityName, _abilityId, abilityTexture, AUI_COMBAT_DATA_TYPE_DAMAGE_OUT, true)
				if petData then
					petData.petData = sourceData
				end
			end
		end
		
		if AUI.Combat.Text.IsEnabled() then
			if IsPlayer(_sourceType) and not IsPlayer(_targetType) then				
				if isCrit then	
					if AUI.Settings.Combat.scrolling_text_show_critical_damage_out then
						AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_CRIT_DAMAGE_OUT, AUI.Settings.Combat.scrolling_text_damage_out_crit_parent_panelName, abilityTexture, abilityName)
					end
				elseif AUI.Settings.Combat.scrolling_text_show_damage_out then
					AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_DAMAGE_OUT, AUI.Settings.Combat.scrolling_text_damage_out_parent_panelName, abilityTexture, abilityName)
				end
			elseif IsPlayer(_targetType) and not IsPlayer(_sourceType) then	
				if isCrit then
					if AUI.Settings.Combat.scrolling_text_show_critical_damage_in then
						AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_CRIT_DAMAGE_IN, AUI.Settings.Combat.scrolling_text_damage_in_crit_parent_panelName, abilityTexture, abilityName)	
					end
				elseif AUI.Settings.Combat.scrolling_text_show_damage_in then
					AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_DAMAGE_IN, AUI.Settings.Combat.scrolling_text_damage_in_parent_panelName, abilityTexture, abilityName)
				end				
			end
		end
	elseif isHeal[_result] then
		local abilityTexture = GetAbilityIcon(_abilityId) or "/esoui/art/icons/icon_missing.dds"
		local abilityName = zo_strformat(SI_ABILITY_NAME, _abilityName)
		local isCrit = IsCrit(_result)	
	
		if isCombatMeterStarted then
			AddData(_sourceUnitId, _sourceType, _targetUnitId, _targetType, _hitValue, isCrit, abilityName, _abilityId, abilityTexture, AUI_COMBAT_DATA_TYPE_HEAL_OUT)
			AddData(_targetUnitId, _targetType, _sourceUnitId, _sourceType, _hitValue, isCrit, abilityName, _abilityId, abilityTexture, AUI_COMBAT_DATA_TYPE_HEAL_IN)
		end
		
		if AUI.Combat.Text.IsEnabled() then	
			if IsPlayer(_sourceType) then		
				if isCrit then
					if AUI.Settings.Combat.scrolling_text_show_critical_heal_out then
						AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_CRIT_HEAL_OUT, AUI.Settings.Combat.scrolling_text_heal_out_crit_parent_panelName, abilityTexture, abilityName)
					end
				elseif AUI.Settings.Combat.scrolling_text_show_heal_out then
					AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_HEAL_OUT, AUI.Settings.Combat.scrolling_text_heal_out_parent_panelName, abilityTexture, abilityName)
				end	
			elseif IsPlayer(_targetType)  then
				if isCrit then
					if AUI.Settings.Combat.scrolling_text_show_critical_heal_in then
						AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_CRIT_HEAL_IN, AUI.Settings.Combat.scrolling_text_heal_in_crit_parent_panelName, abilityTexture, abilityName)
					end
				elseif AUI.Settings.Combat.scrolling_text_show_heal_in then
					AUI.Combat.Text.InsertMessage(_hitValue, AUI_SCROLLING_TEXT_HEAL_IN, AUI.Settings.Combat.scrolling_text_heal_in_parent_panelName, abilityTexture, abilityName)
				end	
			end		
		end
	end	
end

function AUI.Combat.OnPowerUpdate(_unitTag, _powerIndex, _powerType, _powerValue, _powerMax, _powerEffectiveMax)
	if not isLoaded or _unitTag ~= AUI_PLAYER_UNIT_TAG then
		return
	end
	
	local isUnitDead = IsUnitDead(_unitTag)
	
	if _powerType == POWERTYPE_ULTIMATE then
		if AUI.Combat.Text.IsEnabled() and AUI.Settings.Combat.scrolling_text_show_ultimate_ready and _unitTag == AUI_PLAYER_UNIT_TAG then
			local ultimateSlot = GetSlotAbilityCost(8)
			if ultimateSlot > 0 then 
				local unitPercent = AUI.Math.Round((_powerValue / ultimateSlot) * 100)
				if unitPercent >= 100 then			
					if ultiReady then
						AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("ultimate_ready"), AUI_SCROLLING_TEXT_ULTI_READY, AUI.Settings.Combat.scrolling_text_ultimate_ready_parent_panelName, AUI_SCROLLING_TEXT_ULTIMATE_TEXTURE)
					end			
					ultiReady = false
				else
					ultiReady = true
				end
			end		
		end
	elseif _powerType == POWERTYPE_HEALTH then
		if not isUnitDead then
			local value = _powerValue - oldHealthValue

			if value > 0 then
				if AUI.Settings.Combat.scrolling_text_show_health_reg then
					AUI.Combat.Text.InsertMessage("+ " .. AUI.String.ToFormatedNumber(value) .. " Health", AUI_SCROLLING_TEXT_HEALTH_REG, AUI.Settings.Combat.scrolling_text_health_reg_parent_panelName, AUI_SCROLLING_TEXT_HEALTH_REG_TEXTURE)
				end
			elseif value < 0 then
				if AUI.Settings.Combat.scrolling_text_show_health_dereg then
					AUI.Combat.Text.InsertMessage("- " .. AUI.String.ToFormatedNumber(value) .. " Health", AUI_SCROLLING_TEXT_HEALTH_DEREG, AUI.Settings.Combat.scrolling_text_health_dereg_parent_panelName, AUI_SCROLLING_TEXT_HEALTH_DEREG_TEXTURE)
				end
			end
			
			local percent = AUI.Math.Round((_powerValue / _powerMax) * 100)
			if percent <= 25 then
				if not isHealthLow and AUI.Settings.Combat.scrolling_text_show_health_low then
					AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("health_low"), AUI_SCROLLING_TEXT_HEALTH_LOW, AUI.Settings.Combat.scrolling_text_health_low_parent_panelName, AUI_SCROLLING_TEXT_HEALTH_LOW_TEXTURE)
				end	
				isHealthLow = true	
			else
				isHealthLow = false	
			end	

			oldHealthValue = _powerValue
		end
	elseif _powerType == POWERTYPE_MAGICKA then
		if not isUnitDead then
			local value = _powerValue - oldMagickaValue
			
			if value > 0 then
				if AUI.Settings.Combat.scrolling_text_show_magicka_reg then
					AUI.Combat.Text.InsertMessage("+ " .. AUI.String.ToFormatedNumber(value) .. " Magicka", AUI_SCROLLING_TEXT_MAGICKA_REG, AUI.Settings.Combat.scrolling_text_magicka_reg_parent_panelName, AUI_SCROLLING_TEXT_MAGICKA_REG_TEXTURE)
				end
			elseif value < 0 then
				if AUI.Settings.Combat.scrolling_text_show_magicka_dereg then
					AUI.Combat.Text.InsertMessage("- " .. AUI.String.ToFormatedNumber(-value) .. " Magicka", AUI_SCROLLING_TEXT_MAGICKA_DEREG, AUI.Settings.Combat.scrolling_text_magicka_dereg_parent_panelName, AUI_SCROLLING_TEXT_MAGICKA_DEREG_TEXTURE)
				end
			end	

			local percent = AUI.Math.Round((_powerValue / _powerMax) * 100)
			if percent <= 25 then
				if not isMagickaLow and AUI.Settings.Combat.scrolling_text_show_magicka_low then
					AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("magicka_low"), AUI_SCROLLING_TEXT_MAGICKA_LOW, AUI.Settings.Combat.scrolling_text_magicka_low_parent_panelName, AUI_SCROLLING_TEXT_MAGICKA_LOW_TEXTURE)
				end	
				isMagickaLow = true	
			else
				isMagickaLow = false				
			end			
			
			oldMagickaValue = _powerValue		
		end
	elseif _powerType == POWERTYPE_STAMINA then
		if not isUnitDead then
			local value = _powerValue - oldStaminaValue
			
			if value > 0 then
				if AUI.Settings.Combat.scrolling_text_show_stamina_reg then
					AUI.Combat.Text.InsertMessage("+ " .. AUI.String.ToFormatedNumber(value) .. " Stamina", AUI_SCROLLING_TEXT_STAMINA_REG, AUI.Settings.Combat.scrolling_text_stamina_reg_parent_panelName, AUI_SCROLLING_TEXT_STAMINA_REG_TEXTURE)
				end
			elseif value < 0 then
				if AUI.Settings.Combat.scrolling_text_show_stamina_dereg then
					AUI.Combat.Text.InsertMessage("- " .. AUI.String.ToFormatedNumber(-value) .. " Stamina", AUI_SCROLLING_TEXT_STAMINA_DEREG, AUI.Settings.Combat.scrolling_text_stamina_dereg_parent_panelName, AUI_SCROLLING_TEXT_STAMINA_DEREG_TEXTURE)
				end
			end	

			local percent = AUI.Math.Round((_powerValue / _powerMax) * 100)
			if percent <= 25 then
				if not isStaminaLow and AUI.Settings.Combat.scrolling_text_show_stamina_low then
					AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("stamina_low"), AUI_SCROLLING_TEXT_STAMINA_LOW, AUI.Settings.Combat.scrolling_text_stamina_low_parent_panelName, AUI_SCROLLING_TEXT_STAMINA_LOW_TEXTURE)
				end

				isStaminaLow = true
			elseif isStaminaLow then
				isStaminaLow = false				
			end				
			
			oldStaminaValue = _powerValue
		end
	end
end

function AUI.Combat.OnActionUpdateCooldowns()
	if not isLoaded then
		return
	end

	if AUI.Combat.Text.IsEnabled() then
		if potionReady or potionReady then
			local currentQuickSlot = GetCurrentQuickslot()
			local _, _, canUse = GetSlotCooldownInfo(currentQuickSlot)
		
			if canUse then	
				AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("potion_ready"), AUI_SCROLLING_TEXT_POTION_READY, AUI.Settings.Combat.scrolling_text_potion_ready_parent_panelName, AUI_SCROLLING_TEXT_POTION_READY_TEXTURE)
				potionReady = false
			end
		end
	end
end

function AUI.Combat.OnInventoryItemUsed(_itemSoundCategory)
	if not isLoaded then
		return
	end

	if AUI.Combat.Text.IsEnabled() then
		if _itemSoundCategory == ITEM_SOUND_CATEGORY_POTION then 
			potionReady = true
		end
	end
end

function AUI.Combat.OnEffectChanged(_changeType, _effectSlot, _effectName, _unitTag, _beginTime, _endTime, _stackCount, _iconName, _buffType, _effectType, _abilityType, _statusEffectType, _unitName, _unitId, _abilityId)
	if not isLoaded or _unitTag ~= AUI_PLAYER_UNIT_TAG then
		return
	end

	if AUI.Combat.Text.IsEnabled() and IsAbilitySlotted(_abilityId) then
		if _changeType == 1 then
			if AUI.Settings.Combat.scrolling_text_show_instant_casts and AUI.Ability.IsProc(_abilityId) then
				if not abilityProcEffects[_abilityId] then
					local effectName = zo_strformat(SI_ABILITY_NAME, _effectName)
					local abilityTexture = GetAbilityIcon(_abilityId) or "/esoui/art/icons/icon_missing.dds"
					AUI.Combat.Text.InsertMessage(effectName, AUI_SCROLLING_TEXT_PROC, AUI.Settings.Combat.scrolling_text_instant_cast_parent_panelName, abilityTexture)
					abilityProcEffects[_abilityId] = true
				end
			end
		elseif _changeType == 2 then
			if _abilityType == ABILITY_TYPE_BONUS then
				abilityProcEffects[_abilityId] = nil
			end
		end
	end
end

local function UpdateExperienceData()
	experienceData.exp = GetUnitXP(AUI_PLAYER_UNIT_TAG)
	experienceData.cxp = GetPlayerChampionXP()	
end

function AUI.Combat.OnLevelUpdate()
	UpdateExperienceData()
end

function AUI.Combat.OnExperienceUpdate(_unitTag, _currentExp, _maxExp, _reason)
	if not isLoaded then
		return
	end
	if _unitTag == AUI_PLAYER_UNIT_TAG  then
		local unitData = combatData[AUI_PLAYER_UNIT_TAG]
		if experienceData then
			if AUI.Settings.Combat.scrolling_text_show_exp then
				local expierence = math.max(_currentExp - experienceData.exp, 0)
				if expierence > 0 then
					AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(expierence) .. " EXP", AUI_SCROLLING_TEXT_EXP, AUI.Settings.Combat.scrolling_text_exp_parent_panelName, AUI_SCROLLING_TEXT_EXP_TEXTURE)
				end
			end
				
			if AUI.Settings.Combat.scrolling_text_show_cxp then
				local currentCxp = GetPlayerChampionXP()
				local cxp = math.max(currentCxp - experienceData.cxp, 0)	
				if cxp > 0 then
					local currentCxpAtt = GetChampionPointAttributeForRank(GetPlayerChampionPointsEarned() + 1)
					local iconTexture = "/esoui/art/icons/icon_missing.dds"
					if currentCxpAtt == 1 then
						iconTexture = "/esoui/art/champion/champion_points_health_icon-hud-32.dds"
					elseif currentCxpAtt == 2 then
						iconTexture = "/esoui/art/champion/champion_points_magicka_icon-hud-32.dds"
					elseif currentCxpAtt == 3 then
						iconTexture = "/esoui/art/champion/champion_points_stamina_icon-hud-32.dds"
					end				
				
					AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(cxp) .. " CXP", AUI_SCROLLING_TEXT_CXP, AUI.Settings.Combat.scrolling_text_cxp_parent_panelName, iconTexture)	
				end
			end
		end
	end
	
	UpdateExperienceData()
end	

function AUI.Combat.OnAlliancePointUpdate(_alliancePoints, _difference)
	if not isLoaded then
		return
	end

	if AUI.Combat.Text.IsEnabled() and AUI.Settings.Combat.scrolling_text_show_ap then
		if _difference > 0 then
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(_difference) .. " AP", AUI_SCROLLING_TEXT_AP, AUI.Settings.Combat.scrolling_text_ap_parent_panelName, AUI_SCROLLING_TEXT_AP_TEXTURE)
		end
	end
end	

function AUI.Combat.OnTelVarStoneUpdate(_newTelvarStones, _oldTelvarStones)
	if not isLoaded then
		return
	end

	if AUI.Combat.Text.IsEnabled() and AUI.Settings.Combat.scrolling_text_show_telvar then
		local difference = _newTelvarStones - _oldTelvarStones
		if difference > 0 then
			AUI.Combat.Text.InsertMessage(AUI.String.ToFormatedNumber(difference) .. " " .. AUI.L10n.GetString("Tel'Var"), AUI_SCROLLING_TEXT_TELVAR, AUI.Settings.Combat.scrolling_text_telvar_parent_panelName, AUI_SCROLLING_TEXT_TELVAR_TEXTURE)
		end
	end
end	

function AUI.Combat.OnPlayerCombatState(_inCombat)
	if not isLoaded then
		return
	end

	if _inCombat then
		if AUI.Combat.Text.IsEnabled() and AUI.Settings.Combat.scrolling_text_show_combat_start then
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("combat_start"), AUI_SCROLLING_TEXT_COMBAT_START, AUI.Settings.Combat.scrolling_text_combat_start_parent_panelName, AUI_SCROLLING_TEXT_COMBAT_START_TEXTURE)
		end
	else
		if AUI.Combat.Text.IsEnabled() and AUI.Settings.Combat.scrolling_text_show_combat_end then
			AUI.Combat.Text.InsertMessage(AUI.L10n.GetString("combat_end"), AUI_SCROLLING_TEXT_COMBAT_END, AUI.Settings.Combat.scrolling_text_combat_end_panelName, AUI_SCROLLING_TEXT_COMBAT_END_TEXTURE)
		end
		
		if AUI.Combat.WeaponChargeWarner.IsEnabled() then			
			AUI.Combat.WeaponChargeWarner.UpdateAll()
		end			
	end	
end
	
function AUI.Combat.OnGroupUpdate()
	if not isLoaded then
		return
	end

	if AUI.Combat.DamageMeter.IsEnabled() then
		AUI.Combat.DamageMeter.UpdateUI()
	end
end	

function AUI.Combat.Load()
	if isLoaded then
		return
	end

	isLoaded = true
	
	local panel1Anchor = {
		point = LEFT,
		relativePoint = LEFT,
		offsetX = 500,
		offsetY = 0	
	}
	
	local panel2Anchor = {
		point = CENTER,
		relativePoint = CENTER,
		offsetX = 0,
		offsetY = 0	
	}	
	
	local panel3Anchor = {
		point = RIGHT,
		relativePoint = RIGHT,
		offsetX = -600,
		offsetY = 0	
	}		
	
	AUI.Combat.Text.AddSctPanel(AUI.L10n.GetString("left"), "panel1", 200, 1000, panel1Anchor, true, AUI_ANIMATION_ECLIPSE, AUI_ANIMATION_MODE_REVERSE_BACKWARD, 3.0)
	AUI.Combat.Text.AddSctPanel(AUI.L10n.GetString("middle"), "panel2", 200, 500, panel2Anchor, true, AUI_ANIMATION_VERTICAL, AUI_ANIMATION_MODE_BACKWARD, 3.0)
	AUI.Combat.Text.AddSctPanel(AUI.L10n.GetString("right"), "panel3", 200, 1000, panel3Anchor, true, AUI_ANIMATION_ECLIPSE, AUI_ANIMATION_MODE_BACKWARD, 3.0)
	
	AUI.Combat.SetMenuData()

	if AUI.Combat.Minimeter.IsEnabled() then	
		AUI.Combat.Minimeter.Load()
	end

	if AUI.Combat.Text.IsEnabled() then	
		AUI.Combat.Text.Load()
	end	

	if AUI.Combat.WeaponChargeWarner.IsEnabled() then	
		AUI.Combat.WeaponChargeWarner.Load()
	end	

	AUI.Combat.Statistics.Load()
	
	UpdateExperienceData()			
end

function AUI.Combat.Minimeter.IsEnabled()
	return AUI.Settings.Combat.minimeter_enabled
end

function AUI.Combat.Text.IsEnabled()
	return AUI.Settings.Combat.scrolling_text_enabled
end

function AUI.Combat.DamageMeter.IsEnabled()
	return AUI.Settings.Combat.damage_meter_enabled
end

function AUI.Combat.WeaponChargeWarner.IsEnabled()
	return AUI.Settings.Combat.weapon_charge_warner_enabled
end