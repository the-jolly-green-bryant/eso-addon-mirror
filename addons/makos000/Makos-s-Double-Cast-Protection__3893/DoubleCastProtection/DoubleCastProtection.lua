DoubleCastProtection = {}
local DoubleCastProtection = DoubleCastProtection

DoubleCastProtection.name = "DoubleCastProtection"
DoubleCastProtection.version = "1.0.1"
DoubleCastProtection.author = "@makos000"


local lastAbility = 0

local groundString = GetString(SI_ABILITY_TOOLTIP_TARGET_TYPE_GROUND)
local groundAbilities = {}

local function CheckIfGroundAbility(id)
	local result = groundAbilities[id]
	if result == nil then
		result = GetAbilityTargetDescription(id) == groundString
		groundAbilities[id] = result
	end
	return result
end

local function Initialize()

	local function CanUseActionSlots()
	
		local n = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
		local id = 0
		id = GetSlotBoundId(n)
		local debugGroundString = "no adjusted"
		
		if CheckIfGroundAbility(id) then
			debugGroundString = "true"
		else
			debugGroundString = "false"
		end

		--d("lastAbility " .. lastAbility)
		--d("CheckIfGroundAbility " .. debugGroundString)
		local ground = DoubleCastProtection.savedVariables.blockGround and (lastAbility == id or CheckIfGroundAbility(lastAbility)) and CheckIfGroundAbility(id)

		if ground then
			return true
		end
	end

	local function AbilityUsed(_, n)
		if n >= 3 and n <= 8 then
			local id = GetSlotBoundId(n)
			lastAbility = id
			if(CheckIfGroundAbility(id)) then
				zo_callLater(function() DoubleCastProtection.ResetID() end, DoubleCastProtection.savedVariables.lockms)
			end
		end
	end

	-- Event for player using ability
	EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTION_SLOT_ABILITY_USED, AbilityUsed)

	-- This blocks skill
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", CanUseActionSlots)

end

function DoubleCastProtection.ResetID()
	lastAbility = 0
end

function DoubleCastProtection.LoadedMessage()
	d("Makos's DoubleCastProtection loaded")
end

function DoubleCastProtection.OnAddOnLoaded()

	DoubleCastProtection.savedVariables = ZO_SavedVars:NewAccountWide("DoubleCastProtectionSavedVariables", 1, nil, {})

	if (DoubleCastProtection.savedVariables.blockGround == nil) then
		DoubleCastProtection.savedVariables.blockGround = true
	end
	
	if (DoubleCastProtection.savedVariables.lockms == nil) then
		DoubleCastProtection.savedVariables.lockms = 750
	end
	
	DoubleCastProtection.AddonMenu()

	zo_callLater(function() DoubleCastProtection.LoadedMessage() end, 7000)
	EVENT_MANAGER:UnregisterForEvent(DoubleCastProtection.name, EVENT_ADD_ON_LOADED)
	Initialize()
end

EVENT_MANAGER:RegisterForEvent(DoubleCastProtection.name, EVENT_ADD_ON_LOADED, DoubleCastProtection.OnAddOnLoaded)
