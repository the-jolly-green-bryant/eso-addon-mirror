local LCA = LibCombatAlerts
local CA2 = CombatAlerts2

local NAME = "CA_NightbladeCutthroat"

local start = 0
local stop = 0

local function IsNightbladeClassAbility( abilityId )
	return GetSkillLineClassId(GetSpecificSkillAbilityKeysByAbilityId(abilityId)) == 3
end

local function IsNightbladeCutthroatPassiveActive( )
	return select(6, GetSkillAbilityInfo(GetSpecificSkillAbilityKeysByAbilityId(263606)))
end

local function SkillBlockerCallback( actionId, slotIndex, hotbarCategory )
	if (hotbarCategory) then
		-- Relevance check, ignore time window
		return IsNightbladeClassAbility(actionId)
	else
		local currentTime = GetGameTimeMilliseconds()
		if (currentTime >= start and currentTime <= stop) then
			return IsNightbladeClassAbility(actionId)
		end
	end
end

function CA2.SetNightbladeCutthroatExclusion( timeOfExpectedHit )
	if (timeOfExpectedHit > 0 and CA2.sv.cutthroatProtection and IsNightbladeCutthroatPassiveActive()) then
		start = timeOfExpectedHit - 500
		stop = timeOfExpectedHit + 100
		LCA.RegisterInCombatSkillBlock(NAME, SkillBlockerCallback)
	else
		LCA.RegisterInCombatSkillBlock(NAME)
	end
end

function CA2.UpdateNightbladeCutthroatExclusionStopTime( newStopTime )
	stop = newStopTime
end
