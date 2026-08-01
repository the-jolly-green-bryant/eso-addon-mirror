InstantSwap = {
    name = "Instant Swap",
    version = "1.2",
    slashCommand = "/instantswap",
    initialized = false,
    defaultVars = {
        forceUpdate = true,
    },
}

local function DisableSwapAnimation()
	for i = 3, 8 do
        ZO_ActionBar_GetButton(i).hotbarSwapAnimation = nil
	end
end

local function ForceUpdateAllSlots()
	for i = 3, 8 do
        ZO_ActionBar_GetButton(i):HandleSlotChanged()
    end
end

local function OnActionSlotsActiveHotbarUpdated(eventCode, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
	if didActiveHotbarChange and not shouldUpdateAbilityAssignments then
		if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY or activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
            ForceUpdateAllSlots()
		end
	end
end

function InstantSwap.HandleSlashCommand( command )
    command = string.lower(command)
    if (command == "noforce") then
        df('Instant Swap: Force Update disabled')
        InstantSwap.SV.forceUpdate = false
        EVENT_MANAGER:UnregisterForEvent(InstantSwap.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    elseif (command == "force") then
        df('Instant Swap: Force Update enabled')
        InstantSwap.SV.forceUpdate = true
        EVENT_MANAGER:RegisterForEvent(InstantSwap.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnActionSlotsActiveHotbarUpdated)
    end
end

local function OnPlayerActivated(_, _)
    if not InstantSwap.initialized then
        InstantSwap.SV = ZO_SavedVars:NewAccountWide("INSTANT_SWAP_SV", InstantSwap.version, nil, InstantSwap.defaultVars)
        SLASH_COMMANDS[InstantSwap.slashCommand] = InstantSwap.HandleSlashCommand
        DisableSwapAnimation()
        if InstantSwap.SV.forceUpdate then
            EVENT_MANAGER:RegisterForEvent(InstantSwap.name, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnActionSlotsActiveHotbarUpdated)
        end
        df('%s %s initialized', InstantSwap.name, InstantSwap.version)
        InstantSwap.initialized = true
    end
end

EVENT_MANAGER:RegisterForEvent(InstantSwap.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
