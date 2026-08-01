function OnAddOnLoaded(event, addonName)
	if (addonName ~= "RandomDungeonTimer") then return end
	
	EVENT_MANAGER:UnregisterForEvent("RandomDungeonTimer", EVENT_ADD_ON_LOADED)
	SLASH_COMMANDS["/rdt"] = function ()
		local timeRemaining = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_DUNGEON_REWARD_GRANTED)
	
		if timeRemaining == 0 then
			CHAT_ROUTER:AddSystemMessage("Random dungeon daily reward is available.")
		else
			local hoursRemaining = math.floor(timeRemaining / 3600)
			local minutesRemaining = math.floor((timeRemaining - hoursRemaining * 3600) / 60)
			CHAT_ROUTER:AddSystemMessage(string.format("Random dungeon daily reward will be available in %dh %.2dm.", hoursRemaining, minutesRemaining))
		end
	end
end

EVENT_MANAGER:RegisterForEvent("RandomDungeonTimer", EVENT_ADD_ON_LOADED, OnAddOnLoaded)