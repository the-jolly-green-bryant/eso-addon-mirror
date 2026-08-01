
-- Replacing the following functions with added check to see if player is in combat.
ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, 'CycleLeft', function()
	return IsUnitInCombat("player")
end)

ZO_PreHook(INTERACTIVE_WHEEL_MANAGER, 'CycleRight', function()
	return IsUnitInCombat("player")
end)

--[[
	should I add settings and the ability to use a delay?
	
	
function addon:Initialize()
	local function blockSwitch()
		return self:BlockSwitch()
	end
	
	ZO_PreHook(UTILITY_WHEEL_MANAGER, 'CycleLeft', function()
		return blockSwitch()
	end)

	ZO_PreHook(UTILITY_WHEEL_MANAGER, 'CycleRight', function()
		return blockSwitch()
	end)
end

function addon:BlockSwitch()
	if self.savedVars.useDalay then
		local timeNowMilliseconds = GetFrameTimeMilliseconds()
		local lastCheck = self.lastCheck or 0
		self.lastCheck = timeNowMilliseconds + self.savedVars.delay
		
		return lastCheck >= timeNowMilliseconds
	end
	return IsUnitInCombat("player")
end

]]