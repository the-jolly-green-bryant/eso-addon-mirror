local LCA = LibCombatAlerts
local CA2 = CombatAlerts2

local NAME = "CA_NightbladeCutthroat"

local start = 0
local stop = 0

local function IsNightbladeClassAbility( abilityId )
	return GetSkillLineClassId(GetSpecificSkillAbilityKeysByAbilityId(abilityId)) == 3
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

-- By default, the first parameter is timeOfExpectedHit, but if stopTime is specified, then it's startTime
function CA2.SetNightbladeCutthroatExclusion( timeOfExpectedHit_or_startTime, stopTime )
	if (timeOfExpectedHit_or_startTime > 0 and CA2.sv.cutthroatProtection and LCA.IsNightbladeCutthroatPassiveActive()) then
		if (stopTime) then
			start = timeOfExpectedHit_or_startTime
			stop = stopTime
		else
			start = timeOfExpectedHit_or_startTime - zo_min(500 + GetLatency(), 750)
			stop = timeOfExpectedHit_or_startTime + 100
		end
		LCA.RegisterInCombatSkillBlock(NAME, SkillBlockerCallback)
	else
		LCA.RegisterInCombatSkillBlock(NAME)
	end
end

function CA2.UpdateNightbladeCutthroatExclusionStopTime( newStopTime )
	stop = newStopTime
end
