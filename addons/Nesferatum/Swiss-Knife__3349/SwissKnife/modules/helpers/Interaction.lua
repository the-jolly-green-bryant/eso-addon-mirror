local SK = SwissKnife
local SKH = SK.HelperFunctions
local SKDC = SK.Data.common

local function companionsInteractionStatus()
	if not SK.savedVars.enableCompanionsInteractionNotification then return end
	local state
	if SK.savedVars.hideCompanionsInteraction then
		state = GetString(SI_SK_MESSAGE_DISABLED)
	else
		state = GetString(SI_SK_MESSAGE_ENABLED)
	end
	SKH.sendMessageToChat(
        SK.COLORED_PREFIXES.SKW,
        SI_SK_AUT_COMPANION_INTERACTION_AVAILABLE,
        SK.COLOR.ORANGE:Colorize(state)
    )
end

local function toggleCompanionsInteraction()
	SK.savedVars.hideCompanionsInteraction = not SK.savedVars.hideCompanionsInteraction
	companionsInteractionStatus()
end

local function dangerInteractionStatus()
	if not SK.savedVars.enableDangerInteractionNotification then return end
	local state
	local adds = ""
	if SK.savedVars.hideDangerInteraction then
		state = GetString(SI_SK_MESSAGE_DISABLED)
		if VampireWoe then
			adds = SKH.getFormattedText(
				GetString(SI_SK_AUT_DANGER_INTERACTION_ADDONS_DISABLED),
				SK.COLOR.ORANGE:Colorize("VampireWoe")
			)
		end
	else
		state = GetString(SI_SK_MESSAGE_ENABLED)
	end
	SKH.sendMessageToChat(
        SK.COLORED_PREFIXES.SKW,
        SI_SK_AUT_DANGER_INTERACTION_AVAILABLE,
        SK.COLOR.ORANGE:Colorize(state),
		adds
    )
end

local function setPreventAttackingInnocents()
	local state = 'true'
	if not SK.savedVars.hideDangerInteraction then state = 'false' end
	SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_PREVENT_ATTACKING_INNOCENTS, state)
end

local function isDarkBrotherhoodQuestZone()
	local zoneId = GetUnitWorldPosition("player")
	return SKH.isValueInList(SKDC.DARK_BROTHER_HOOD_QUEST_ZONES, zoneId)
end

local function toggleDangerInteraction()
	SK.savedVars.hideDangerInteraction = not SK.savedVars.hideDangerInteraction
	setPreventAttackingInnocents()
	dangerInteractionStatus()
	SKPI:SetColor()
end

-- Export helper functions
SK.HelperFunctions.companionsInteractionStatus = companionsInteractionStatus
SK.HelperFunctions.toggleCompanionsInteraction = toggleCompanionsInteraction
SK.HelperFunctions.dangerInteractionStatus = dangerInteractionStatus
SK.HelperFunctions.setPreventAttackingInnocents = setPreventAttackingInnocents
SK.HelperFunctions.toggleDangerInteraction = toggleDangerInteraction
SK.HelperFunctions.isDarkBrotherhoodQuestZone = isDarkBrotherhoodQuestZone
