VisiblePickpocketPing = {}
VisiblePickpocketPing.settings = {}
local settings = VisiblePickpocketPing.settings 

local defaults = {

	offsetX = 0, 
	offsetY = 0,
	width  = 400,
	height = 400,
	locked = false,
	icon = "esoui/art/treeicons/gamepad/gp_tutorial_idexicon_thievesguild.dds",
	
	r = 0,
	g = 294,
	b = 33,
	a = 1,
	
	noWarning = false,
	rVisible = 255,
	gVisible = 0,
	bVisible = 28,
	aVisible = 1,	
	
}

local function getControl()
	return VisiblePickpocketingIndicator
end

local function hideControl()
	getControl():SetHidden(true)	
end

local UNITTAG_PLAYER = 'player'
local function recolorTex(eventCode, unitTag, stealthState)
	-- colorize tex
	if unitTag ~= UNITTAG_PLAYER then return end
	
	local playerHidden 	= stealthState ~= SI_STEALTH_DETECTED
	local useWarningColor = not (settings.noWarning or playerHidden)
	local r = (useWarningColor and settings.rVisible) or settings.r
	local g = (useWarningColor and settings.gVisible) or settings.g
	local b = (useWarningColor and settings.bVisible) or settings.b
	local a = (useWarningColor and settings.aVisible) or settings.a
	getControl():GetNamedChild("Tex"):SetColor(r, g, b, a)
end

ZO_PreHook(ZO_Reticle, "TryHandlingInteraction", function(interactionPossible, currentFrameTimeSeconds)
	
	local _, _, interactionBlocked, _, additionalInteractInfo, _, _, isCriminalInteract = GetGameCameraInteractableActionInfo()
	
	if additionalInteractInfo ~= ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE or interactionBlocked or not(interactionPossible) then
		getControl():SetHidden(settings.locked)
		return 
	end	
	
	local isInBonus, isHostile, percentChance, _, isEmpty, prospectiveResult, _, _ = GetGameCameraPickpocketingBonusInfo()
	local cantInteract 	= isHostile or empty or not prospectiveResult == PROSPECTIVE_PICKPOCKET_RESULT_CAN_ATTEMPT 
	local hideTex 		= cantInteract or (percentChance < 100 and not isInBonus)
	
	if not hideTex then recolorTex(nil, UNITTAG_PLAYER, GetUnitStealthState(UNITTAG_PLAYER)) end
	
	getControl():SetHidden(settings.locked and hideTex)
end)


EVENT_MANAGER:RegisterForEvent("VisiblePickpocketPingSuccess", 	EVENT_JUSTICE_GOLD_PICKPOCKETED, hideControl)
EVENT_MANAGER:RegisterForEvent("VisiblePickpocketPingVisible", 	EVENT_STEALTH_STATE_CHANGED, 	 recolorTex)
EVENT_MANAGER:RegisterForEvent("VisiblePickpocketPingFail", 	EVENT_JUSTICE_PICKPOCKET_FAILED, hideControl)



function VisiblePickpocketPing_Initialize(eventCode, addonName)

	if addonName ~="VisiblePickpocketPing" then return end

	EVENT_MANAGER:UnregisterForEvent("VisiblePickpocketPing", EVENT_ADD_ON_LOADED)
	
	VisiblePickpocketPing.settings = ZO_SavedVars:NewAccountWide("VisiblePickpocketPing_Globals", 0.2, nil, defaults)
	settings = VisiblePickpocketPing.settings 
	VisiblePickpocketPing.CreateMenu(settings, defaults)
	VisiblePickpocketPing.LoadControlPosition()
	VisiblePickpocketPing.LoadControlSize()
	VisiblePickpocketPing.SetLocked(VisiblePickpocketPing.get("locked"))
	VisiblePickpocketPing.SetIcon(VisiblePickpocketPing.get("icon"))
	VisiblePickpocketPing.SetColor(VisiblePickpocketPing.get("r"), VisiblePickpocketPing.get("g"), VisiblePickpocketPing.get("b"), VisiblePickpocketPing.get("a"))
end

EVENT_MANAGER:RegisterForEvent("VisiblePickpocketPing", EVENT_ADD_ON_LOADED, VisiblePickpocketPing_Initialize)

