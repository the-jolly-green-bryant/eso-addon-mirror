local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common
local EM, FM, IWM = EVENT_MANAGER, FISHING_MANAGER, INTERACTIVE_WHEEL_MANAGER

local originStartInteractionFunction
local lootDisabled = false
local isStolen = false
local isInteractionDisabled = false

local function isUnitStealthState()
	local stealthState = GetUnitStealthState("player")
	return stealthState == STEALTH_STATE_HIDDEN or stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED
end

local function isMaxedPickpocketChance()
	local isInBonus = GetGameCameraPickpocketingBonusInfo()
	return isInBonus
end

local function toggleLootAvailable(state)
	ZO_Loot:GetNamedChild("AlphaContainerButton1"):SetEnabled(state)
	ZO_Loot:GetNamedChild("AlphaContainerButton2"):SetEnabled(state)
	lootDisabled = not state
end

local function onLootMouseDoubleClick(control, button)
    if (button == MOUSE_BUTTON_INDEX_LEFT) then
	    local action = GetGameCameraInteractableActionInfo()
	    if SK.defaultSavedVars.preventUnsafeStealing and (SKH.isValueInList(SKDC.STEALING_ACTIONS, action) or isStolen) then
		    if isUnitStealthState() then
			    TakeLoot(GetControl(control, "Button"))
		    else
			    PlaySound(SOUNDS.NEGATIVE_CLICK)
		    end
		else
		    TakeLoot(GetControl(control, "Button"))
	    end
	end
end

local function setLootSafetyHandlers()
	local list = ZO_Loot:GetNamedChild("AlphaContainerList")
	if list ~= nil then
	    ZO_PreHook(list.dataTypes[1], "setupCallback", function(control, data)
	        isStolen = data.isStolen
		    if SK.savedVars.preventUnsafeStealing and isStolen then toggleLootAvailable(isUnitStealthState()) end
		    control:SetHandler("OnMouseDoubleClick", onLootMouseDoubleClick)
	    end)
	end
end

local function HandleCombat(eventCode, inCombat)
	if not SK.savedVars.preventAccidentalInteraction then
		isInteractionDisabled = false
	else
		if inCombat then
			isInteractionDisabled = true
		else
			zo_callLater(function() isInteractionDisabled = false end,
				SK.savedVars.preventAccidentalInteractionInterval)
		end
	end
	if SK.savedVars.showExecutionIndicator and SKCI ~= nil then SKCI:updateIndicatorsVisibility(inCombat) end
end

local function baseInteractionDisabled(action, name, additionalInteractInfo)
	if SK.savedVars.debugMode then
		d('action')
		d(action)
		d('name')
		d(name)
		d('additionalInteractInfo')
		d(additionalInteractInfo)
		d('end')
	end
	if HasActiveCompanion() then
		local companionName = SKH.getCurrentCompanionName()
		if SKH.isValueInList(SK.INSECT_NAMES, name) and SK.savedVars.preventUnsafeInsectTake and
			companionName == SKH.getCompanionNameById(SK.COMPANIONS.MIRRI) and not IsUnitDead("reticleover")
		then
			return true
		end
		if SK.savedVars.preventCompanionUnsafeStealing and SKH.isValueInList(SKDC.STEALING_ACTIONS, action) and
			SKH.isValueInList(SKDC.DISLIKE_STEALING_COMPANION_NAMES, companionName)
		then
			return true
		end
		if (SK.savedVars.hideCompanionsInteraction and name and name == companionName) or
			(SK.savedVars.preventAccidentalInteraction and isInteractionDisabled and
				action == SKDC.INTERACTION_TALK)
		then
			return true
		end
		if action == SKDC.INTERACTION_FISHING and SK.savedVars.preventUnsafeFishing and
			companionName == SKH.getCompanionNameById(SK.COMPANIONS.EMBER)
		then
			return true
		end
		if action == SKDC.INTERACTION_OPEN and
			SK.savedVars.companionUnsafeEntryMode ~= SK.COMPANION_PREVENT_MODE.NOTHING
		then
			if (string.find(zo_strlower(name), GetString(SI_SK_DARK_BROTHERHOOD_SANCTUARY)) ~= nil and
				SKH.isValueInList(SKDC.DISLIKE_DB_COMPANION_NAMES, companionName)) or
				(string.find(zo_strlower(name), GetString(SI_SK_OUTLAW_REFUGE)) ~= nil and
				companionName == SKH.getCompanionNameById(SK.COMPANIONS.IZOBEL))
			then
				if SK.isWarningShowed == false then
					if SK.savedVars.companionUnsafeEntryMode == SK.COMPANION_PREVENT_MODE.WARNING then
						local text = table.concat({
							SKH.getFormattedText(
								SK.COLOR.WHITE:Colorize(GetString(SI_SK_COMPANION_DISMISS_MESSAGE)),
								SK.COLOR.ORANGE:Colorize(companionName)
							)
						})
						SKH.showAnimateText(text)
					elseif SK.savedVars.companionUnsafeEntryMode == SK.COMPANION_PREVENT_MODE.DISMISS then
						SKH.summonCompanion(GetActiveCompanionDefId())
					end
					SK.isWarningShowed = true
					zo_callLater(function() SK.isWarningShowed = false end, 10000)
				end
				return true
			end
		end
	end
	return false
end

local function startInteraction(...)
	local action, name, _, _, additionalInteractInfo = GetGameCameraInteractableActionInfo()
	if baseInteractionDisabled(action, name, additionalInteractInfo) then return true end
	if NoAccidentalStealing or NAS or not SK.savedVars.preventUnsafeStealing then
		toggleLootAvailable(true)
		return originStartInteractionFunction(...)
	end
	if lootDisabled then toggleLootAvailable(true) end
	if SKH.isValueInList(SKDC.STEALING_ACTIONS, action) then
		if isUnitStealthState() then
			if action == SKDC.STEALING_ACTION_PICKPOCKET and SK.savedVars.preventPickpocketWithoutBonus and
				additionalInteractInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE
			then
				return not isMaxedPickpocketChance()
			else
				return false
			end
		else
			if action == SKDC.STEALING_ACTION_STEAL_FROM and additionalInteractInfo ~= ADDITIONAL_INTERACT_INFO_LOCKED
				and GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT_STOLEN) == "0"
			then
				toggleLootAvailable(false)
				return false
			else
				return true
			end
		end
	else
		return originStartInteractionFunction(...)
	end
end

local function TryHandlingInteractionHook()
	local action, name, blocked, _, additionalInteractInfo = GetGameCameraInteractableActionInfo()
	if not (action and name) then return end
	if SK.savedVars.hideEmptyInteraction and additionalInteractInfo == ADDITIONAL_INTERACT_INFO_EMPTY and blocked then
		return true
	end
	if SK.savedVars.preventUnsafeStealing then
		local interactKeybindButton = RETICLE.interact:GetNamedChild("KeybindButton")
		if interactKeybindButton then
			if action == SKDC.STEALING_ACTION_PICKPOCKET and SK.savedVars.preventPickpocketWithoutBonus and
				additionalInteractInfo == ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE
			then
				interactKeybindButton:SetHidden(not isMaxedPickpocketChance())
			else
				interactKeybindButton:SetHidden(false)
			end
		end
	end
	if baseInteractionDisabled(action, name, additionalInteractInfo) then return true end
	return false
end

local function TryHandlingSinergyHook()
	if not SK.savedVars.hideDangerInteraction and not SK.savedVars.preventCompanionUnsafeBladeOfWoe then return end
	local _, _, iconFilename = GetCurrentSynergyInfo()
	local isDanger = SKH.isValueInList(SKDC.DANGER_INTERACTION, iconFilename, true)
	if SK.savedVars.hideDangerInteraction and isDanger then return true end
	return SK.savedVars.preventCompanionUnsafeBladeOfWoe and HasActiveCompanion() and isDanger and
		SKH.isValueInList(SKDC.DISLIKE_BOW_COMPANION_NAMES, SKH.getCurrentCompanionName()) and
		string.find(zo_strlower(iconFilename), "darkbrotherhood") ~= nil
end

local function OnStealthStateChangedHook()
	if not SK.savedVars.preventUnsafeStealing then return end
	local action = GetGameCameraInteractableActionInfo()
	if action ~= SKDC.STEALING_ACTION_STEAL_FROM and not isStolen then return end
	toggleLootAvailable(isUnitStealthState())
end

local function InitInteractionControl()
	local IM = FM
	RETICLE.stealthIcon.stealthText:SetHidden(SK.savedVars.hideStealthText)
	if (NoAccidentalStealing or NAS) and SK.savedVars.preventUnsafeStealing then
        SKH.showWarningDialogue(GetString(SI_SK_HAS_NO_ACCIDENTAL_STEALING_MESSAGE))
	end
	if SK.clientAPIVersion > 101037 then IM = IWM end
	if originStartInteractionFunction == nil and IM ~= nil then
		originStartInteractionFunction = IM.StartInteraction
		IM.StartInteraction = function(...) return startInteraction(...) end
		setLootSafetyHandlers()
		ZO_PostHook(ZO_StealthIcon, "OnStealthStateChanged", OnStealthStateChangedHook)
	end
	ZO_PreHook(RETICLE, "TryHandlingInteraction", TryHandlingInteractionHook)
	ZO_PreHook(SYNERGY, "OnSynergyAbilityChanged", TryHandlingSinergyHook)
	EM:RegisterForEvent("SK_Interaction_Automation", EVENT_PLAYER_COMBAT_STATE,	HandleCombat)
	zo_callLater(function() SKH.companionsInteractionStatus() end, 1000)
	zo_callLater(function() SKH.dangerInteractionStatus() end, 1000)
	--ZO_PreHook(
	--	"ZO_Dialogs_ShowDialog",
	--	function(dialogName)
	--	if not SK.savedVars.enableLogoutOrQuitConfirmation then
	--			if dialogName == "LOG_OUT" or dialogName == "LOGOUT_DEFERRED" then
	--				Logout()
	--				return true
	--			elseif dialogName == "QUIT" then
	--				Quit()
	--				return true
	--			end
	--		end
	--	end
	--)
	ZO_PreHook(
		"ZO_Dialogs_ShowPlatformDialog",
		function(dialogName)
			if dialogName == "CONFIRM_DESTROY_ITEM_PROMPT" and SK.savedVars.autoFillDestroyItemConfirmation then
				zo_callLater(function()
					ZO_Dialog1EditBox:SetText(GetString(SI_DESTROY_ITEM_CONFIRMATION))
					ZO_Dialog1EditBox:LoseFocus()
				end)
			else
			end
		end
	)
end

function SKToggleCompanionsInteraction()
	SKH.toggleCompanionsInteraction()
end

function SKToggleDangerInteraction()
	SKH.toggleDangerInteraction()
end

-- Export
SK.Interaction = {
	InitInteractionControl = InitInteractionControl,
}
