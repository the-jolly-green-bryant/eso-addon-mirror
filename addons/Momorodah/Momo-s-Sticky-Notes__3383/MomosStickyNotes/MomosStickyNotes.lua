-- Author: Momorodah

-- Message from the author:
-- This is my first addon for ESO so there is a chance I've made some sub-optimal decisions when it comes to the code.
-- If you have any suggestions for improvement please don't hesitate to leave a comment! I'm always eager to improve my
-- programming skills and advise is always welcome, as long as it's constructive and polite of course ^-^
-- Much love, Momorodah
--
-- Oh and by the way, I am not Momo and Momo is not a Khajiit, she's a cat.

MomosSN = {}
 
MomosSN.name = "MomosStickyNotes"
MomosSN.version = 1

function MomosSN:Initialize()
	-- Define keybind string
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_MomosSNControlList", "Toggle sticky note control list")
	ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_MomosSNControlListWithMouse", "Toggle sticky note control list (and show/hide mouse)")

	MomosSN.inCombat = IsUnitInCombat("player")

	EVENT_MANAGER:RegisterForEvent(MomosSN.name, EVENT_PLAYER_COMBAT_STATE, MomosSN.OnPlayerCombatState)

	MomosSN.savedVariables = ZO_SavedVars:NewCharacterIdSettings("MomosSNSavedVariables", MomosSN.version, nil, MomosSN.defaultVariables)
	-- For testing purposes: remove all stickyNotes pleeeeease
	--MomosSN.savedVariables.stickyNotes = {}
	
	MomosSN.style:Initialize()
	MomosSN.settings:Initialize()
end
 
function MomosSN.OnAddOnLoaded(event, addonName)
	if addonName == MomosSN.name then
		MomosSN:Initialize()
		EVENT_MANAGER:UnregisterForEvent(MomosSN.name, EVENT_ADD_ON_LOADED)
	end
end
EVENT_MANAGER:RegisterForEvent(MomosSN.name, EVENT_ADD_ON_LOADED, MomosSN.OnAddOnLoaded)

function MomosSN.OnPlayerCombatState(event, inCombat)
	if not MomosSN.savedVariables.hideInCombat then return end
	if inCombat then
		MomosSN.root:SetHidden(true)
	else
		MomosSN.root:SetHidden(false)
	end	
end