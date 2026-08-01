BSCCompanionInfoExtension = BSCCompanionInfoExtension or {}
local BSCCOIN_EX = BSCCompanionInfoExtension
BSCCompainionInfo = BSCCompainionInfo or {}
local BSCCOIN = BSCCompainionInfo

BSCCOIN_EX.AbilityVersionMap = {
	[157131] = { 157132, 157133, 157134, 157135, 157136, 157137 },
	[157140] = { 157141, 157142, 157143, 157144, 157145, 157147, 157209, 157210, 157211, 157212, 157213, 157214, 157224, 157225, 157226, 157227, 157228, 157229 },
	[157230] = { 157230, 157231, 157232, 157233 }
}

BSCCOIN_EX.SkillsWithoutBeginEvent = { 164291 }

BSCCOIN_EX.BaseAbilityMap = {}

BSCCOIN_EX.RegisteredEvents = {}

local function contains(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

local function BuildBaseSkillMap()
	for v in pairs(BSCCOIN_EX.AbilityVersionMap) do
		for j, x in ipairs(BSCCOIN_EX.AbilityVersionMap[v]) do
			BSCCOIN_EX.BaseAbilityMap[x] = v
		end
	end
end

local function FindBaseSkill(abilityId)
	if (BSCCOIN_EX.BaseAbilityMap[abilityId]) then
		return true, BSCCOIN_EX.BaseAbilityMap[abilityId]
	else
		return false, nil
	end
end

local function ResetCooldowns(hasteAbilityId)
	--d("Haste was cast!")
	for i, v in ipairs(BSCCOIN.ACTION_BAR_SKILL_LIST) do		
		if (v.abilityId ~= hasteAbilityId) then
			local now = GetGameTimeMilliseconds()/1000
			v.endTime = now
			v.updateCD = true	
		end			
	end
end

local function SecondWind(secondWindAbilityId)
	for i, v in ipairs(BSCCOIN.ACTION_BAR_SKILL_LIST) do		
		if (v.abilityId ~= secondWindAbilityId) then
			local now = GetGameTimeMilliseconds()/1000
			local newEndTime = v.endTime - 5 -- Remove 5 seconds of cooldown
			--d(zo_strformat("[Second Wind]: Ability: <<1>>, Previous Endtime: <<2>>, New Endtime: <<3>>", v.abilityId, v.endTime, newEndTime))
			if (newEndTime <= now) then
				v.endTime = now
			else
				v.endTime = newEndTime
			end
			v.updateCD = true	
		end			
	end
end

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////// --- Event Handlers -- /////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

local function EventTester(eventCode,result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)

	--[[
	d("    		OnCombatEvent		")
	d(zo_strformat("abilityId[<<1>>] AbilityName[<<2>>] sourceName[<<3>>] TargetName[<<4>>] result[<<5>>] abilityActionSlotType[<<6>>]", abilityId, GetAbilityName(abilityId), sourceName, targetName, result, abilityActionSlotType))
	d(zo_strformat("sourceType[<<1>>] targetType[<<2>>] sourceUnitId[<<3>>] targetUnitId[<<4>>]", sourceType, targetType, sourceUnitId, targetUnitId))
	d(zo_strformat("TName[<<1>>] SName[<<2>>]", LibUnitTracker:GetUnitNameByUnitId(targetUnitId), LibUnitTracker:GetUnitNameByUnitId(sourceUnitId)))
	d("    							")
	]]
	-- Not your companion, so do not track
	if (sourceUnitId == 0) then
		return
	end

	if sourceUnitId ~= 0 then
		if LibUnitTracker:GetUnitNameByUnitId(sourceUnitId) ~= zo_strformat('<<1>>', GetCompanionName(GetActiveCompanionDefId())) then return end
	end

	local cd = GetAbilityCooldown(abilityId, 'companion');
	local hasRootAbility, rootAbilityId = FindBaseSkill(abilityId)
	if (hasRootAbility) then
		cd = GetAbilityCooldown(rootAbilityId, 'companion')
	end
	for i, v in ipairs(BSCCOIN.ACTION_BAR_SKILL_LIST) do		
		if (v.abilityId == abilityId) or (hasRootAbility and v.abilityId == rootAbilityId) then
			local now = GetGameTimeMilliseconds()/1000
			v.startTime = now
			v.endTime = now + cd/1000
			v.updateCD = true
		end			
	end

	if (GetAbilityName(abilityId) == "Haste") then
		ResetCooldowns(abilityId)
    elseif (GetAbilityName(abilityId) == "Second Wind") then
    	SecondWind(abilityId)
    end
end

-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------

local function AddAbilityEvent(abilityId)
	EVENT_MANAGER:RegisterForEvent("EventTester"..BSCCOIN_EX.Name..tostring(abilityId), EVENT_COMBAT_EVENT, EventTester)
	EVENT_MANAGER:AddFilterForEvent("EventTester"..BSCCOIN_EX.Name..tostring(abilityId), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, tonumber(abilityId))
	
	-- Some skills do not have a begin event, like Thunderous Strike
	if (not contains(BSCCOIN_EX.SkillsWithoutBeginEvent, abilityId)) then
		EVENT_MANAGER:AddFilterForEvent("EventTester"..BSCCOIN_EX.Name..tostring(abilityId), EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
	end

	EVENT_MANAGER:AddFilterForEvent("EventTester"..BSCCOIN_EX.Name..tostring(abilityId), EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, 'companion')
	table.insert(BSCCOIN_EX.RegisteredEvents, "EventTester"..BSCCOIN.Name..tostring(abilityId))
	--d("Add: EventTester"..BSCCOIN_EX.Name..tostring(abilityId).." : "..GetAbilityName(abilityId))
end

function BSCCOIN:InitSkillBarIcons()
	if not DoesUnitExist("companion") or not HasActiveCompanion() then return end
	
	-- Update Hotbar Stuff
	local hotbar = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar(HOTBAR_CATEGORY_COMPANION)
	if hotbar == nil then return end

	-- Unregister
	for i, v in ipairs(BSCCOIN_EX.RegisteredEvents) do
		EVENT_MANAGER:UnregisterForEvent(v, EVENT_COMBAT_EVENT)
		--d("Remove: "..v)
	end


	-- Empty Table again
	BSCCOIN_EX.RegisteredEvents = {}
	BSCCOIN.ACTION_BAR_SKILL_LIST = { }	
	
	for slotIndex, slotData in hotbar:SlotIterator(COMPANION_SKILLS_FILTER) do
		local skilldata = slotData:GetCompanionSkillData()
		local newslotidx = tonumber(slotIndex) -2
		if skilldata ~= nil then
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(newslotidx)):SetTexture(GetAbilityIcon(skilldata.abilityId))
			if newslotidx < 6 then
				--d(skilldata.abilityId)
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx] = { }
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].abilityId = skilldata.abilityId
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].startTime = 0
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].endTime = 0
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].updateCD = false		
				
				--d("Setting up ability "..tostring(skilldata.abilityId)..": "..GetAbilityName(skilldata.abilityId))
				if (BSCCOIN_EX.AbilityVersionMap[skilldata.abilityId] ~= nil) then
					for i, v in ipairs(BSCCOIN_EX.AbilityVersionMap[skilldata.abilityId]) do
						AddAbilityEvent(v)
					end
					else
						--d(GetAbilityName(skilldata.abilityId).." has no morphs")
						AddAbilityEvent(skilldata.abilityId)
					end
					EVENT_MANAGER:UnregisterForEvent(BSCCOIN.Name..tostring(skilldata.abilityId), EVENT_EFFECT_CHANGED)
			end
		else
			BSCCompainionInfoUI:GetNamedChild("SKillInfoIC"..tostring(newslotidx)):SetTexture(ZO_NO_TEXTURE_FILE)		
			if newslotidx < 6 then
				-- Empty SkillData
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx] = { }
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].abilityId = -1	
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].startTime = 0
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].endTime = 0		
				BSCCOIN.ACTION_BAR_SKILL_LIST[newslotidx].updateCD = false	
			end
		end
	end
end
-------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------

BuildBaseSkillMap()