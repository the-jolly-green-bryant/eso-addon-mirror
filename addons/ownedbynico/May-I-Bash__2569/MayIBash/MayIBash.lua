MIB = MIB or {}
MIB.name = "MayIBash"
MIB.version = "1.1"
MIB.ui = ZO_SimpleSceneFragment:New(MIBTracker)

MIB.actions = {
	DODGE = 28549,
	BREAKFREE = 16565,
	BASH = 21970,
}

function MIB.onStaminaChange(_, _, _, _, value, _, _)

	local dodgeCost = GetAbilityCost(MIB.actions.DODGE)
	local breakfreeCost = GetAbilityCost(MIB.actions.BREAKFREE)
	local bashCost = GetAbilityCost(MIB.actions.BASH)
	
	local reserve = breakfreeCost > dodgeCost and breakfreeCost or dodgeCost
	local bashes = math.floor((value - reserve) / bashCost)
	
	if bashes > 0 then
		MIBTrackerCounter:SetText("|c00FF00" .. tostring(bashes) .. "|r")
		MIBTrackerLabel:SetText("Bashes left")
	else
		MIBTrackerCounter:SetText("|cFF00000|r")
		MIBTrackerLabel:SetText("Stop bashing")
	end
end

function MIB.onAddOnLoaded(_, addonName)
	if addonName ~= MIB.name then return end
	
	MIB.initializeSettingsMenu()
	
	if MIB.savedVariables.trackerLeft ~= nil and MIB.savedVariables.trackerTop ~= nil then
		MIBTracker:ClearAnchors()
		MIBTracker:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MIB.savedVariables.trackerLeft, MIB.savedVariables.trackerTop)
	end
	
	if MIB.savedVariables.lockui == true then
		MIBTracker:SetMovable(false)
	end
	
	EVENT_MANAGER:RegisterForEvent(MIB.name, EVENT_POWER_UPDATE, MIB.onStaminaChange)
	EVENT_MANAGER:AddFilterForEvent(MIB.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_STAMINA)
	EVENT_MANAGER:AddFilterForEvent(MIB.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
	HUD_SCENE:AddFragment(MIB.ui)
	HUD_UI_SCENE:AddFragment(MIB.ui)
	MIBTracker:SetHidden(false)
end

EVENT_MANAGER:RegisterForEvent(MIB.name, EVENT_ADD_ON_LOADED, MIB.onAddOnLoaded)