local LCCC = LibCodesCommonCode
local LCA = LibCombatAlerts
local RCR = Raidificator

local Register = LCA and LCA.RegisterInCombatSkillBlock
if (not Register) then return end

local NAME = "RCR_CastBlocker"

local BLOCKED_IDS = {
	[ 40195] = true, -- Camouflaged Hunter
	[ 40478] = true, -- Inner Light
	[ 61489] = true, -- Revealing Flare
	[ 61519] = true, -- Lingering Flare
	[ 61524] = true, -- Blinding Flare
	[103564] = true, -- Temporal Guard
}

local function SkillBlockerCallback( abilityId )
	return BLOCKED_IDS[abilityId]
end

local function RefreshEnablementState( zoneId )
	if (RCR.vars.castBlocker and RCR.GetZoneClassification(zoneId or LCCC.GetZoneId())) then
		Register(NAME, SkillBlockerCallback)
	else
		Register(NAME)
	end
end

RCR.CB = {
	BLOCKED_IDS = BLOCKED_IDS,
	RefreshEnablementState = RefreshEnablementState,
}

LCCC.MonitorZoneChanges(NAME, RefreshEnablementState)
