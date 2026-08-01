------------------------------------------------------------------
--FCOPsijicUndoHelper.lua
--Author: Baertram
------------------------------------------------------------------

--Global addon variable
local FCOPUHelper = {}
FCOPUH = FCOPUHelper

--Local lua speed up variables
local tos = tostring

--Local game global speed up variables
local CM 										= CALLBACK_MANAGER
local EM                                        = EVENT_MANAGER
--local iigpm                                 = IsInGamepadPreferredMode


--Addon variables
FCOPUHelper.addonVars                            = {}
FCOPUHelper.addonVars.gAddonName                 = "FCOPsijicUndoHelper"
FCOPUHelper.addonVars.addonNameMenu              = "FCO PsijicUndoHelper"
FCOPUHelper.addonVars.addonNameMenuDisplay       = "|c00FF00FCO |cFFFF00PsijicUndoHelper|r"
FCOPUHelper.addonVars.addonAuthor                = '|cFFFF00Baertram|r'
FCOPUHelper.addonVars.addonVersionOptions        = '1.0' -- version shown in the settings panel
FCOPUHelper.addonVars.addonSavedVariablesName    = "FCOPsijicUndoHelper_Settings"
FCOPUHelper.addonVars.addonSavedVariablesVersion = 1.0 -- Changing this will reset SavedVariables!
FCOPUHelper.addonVars.gAddonLoaded               = false
local addonVars                                  = FCOPUHelper.addonVars
local addonName                                  = addonVars.gAddonName

--Libraries
-- Create the addon settings menu
local LAM                                        = LibAddonMenu2

--Original variables

--Control names of ZO* standard controls etc.
FCOPUHelper.zosVars                              = {}
local zosVars                                    = FCOPUHelper.zosVars
--zosVars.SKILLS_AND_ACTION_BAR_MANAGER			 = SKILLS_AND_ACTION_BAR_MANAGER
zosVars.ACTION_BAR_ASSIGNMENT_MANAGER			 = ACTION_BAR_ASSIGNMENT_MANAGER

--XML controls
local FCOPUH_TLC
local alwaysHideTLC = false

--Constants
local CON_PLAYER = "player"
local skillTypeGuild							= SKILL_TYPE_GUILD
--local CON_WAITTIMEFORPOWERUPDATESInMS 		= 250
local CON_POWER_EVENT_UPDATER_NAME 				= addonName .. "_POWER_UPDATE_CHECK"
local CON_ACTIONBAR_ULTIMATE_SLOTNUM			= ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

--Settings
FCOPUHelper.settingsVars                         = {}
FCOPUHelper.settingsVars.settings                = {}
FCOPUHelper.settingsVars.defaultSettings         = {}

--Prevention booleans
FCOPUHelper.preventerVars                        = {}


--Check vars
FCOPUHelper.supportedPowerTypes                  = {
	[COMBAT_MECHANIC_FLAGS_HEALTH]	= true,
	[COMBAT_MECHANIC_FLAGS_MAGICKA]	= true,
	[COMBAT_MECHANIC_FLAGS_STAMINA]	= true,
}
local supportedPowerTypes                        = FCOPUHelper.supportedPowerTypes

FCOPUHelper.isPowerTypeUpdaterActive             = false
local isPowerTypeUpdaterActive                   = FCOPUHelper.isPowerTypeUpdaterActive


--Skill ability IDs
FCOPUHelper.abilityIds                           = {
	undo =  			{103478},
	--Morphs:
	precognition =  	{103557},
	temporalGuard =  	{103564},
}
local psijicAbilityIdsUndo                       = FCOPUHelper.abilityIds.undo
local psijicAbilityIdsPrecognition               = FCOPUHelper.abilityIds.precognition
local psijicAbilityIdsTemporalGuard              = FCOPUHelper.abilityIds.temporalGuard


FCOPUHelper.psijicSkills                         = {}
local psijicSkills                               = FCOPUHelper.psijicSkills
FCOPUHelper.psijicSkillsSkillLineID              = 130    --TODO verify!!! The skillLine ID of the Psijic skills in skill type SKILL_TYPE_GUILD
local psijicSkillsSkillLineID                    = FCOPUHelper.psijicSkillsSkillLineID
FCOPUHelper.psijicSkillLineIndexInGuildSkills    = nil
local psijicSkillLineIndexInGuildSkills          = FCOPUHelper.psijicSkillLineIndexInGuildSkills

--Current values, cached
FCOPUHelper.currentValues                        = {
	[COMBAT_MECHANIC_FLAGS_HEALTH]	= 0,
	[COMBAT_MECHANIC_FLAGS_MAGICKA]	= 0,
	[COMBAT_MECHANIC_FLAGS_STAMINA]	= 0,
}

local weaponBar2otherWeaponBar = {
	[HOTBAR_CATEGORY_PRIMARY] = HOTBAR_CATEGORY_BACKUP,
	[HOTBAR_CATEGORY_BACKUP] = 	HOTBAR_CATEGORY_PRIMARY,
}
local currentValues                              = FCOPUHelper.currentValues

FCOPUHelper.activeWeaponBar = GetActiveWeaponPairInfo() 		-- Updates at EVET_ADD_ON_LOADED and at weapon swap
FCOPUHelper.activeHotbarCategory = GetActiveHotbarCategory() 	-- Updates at EVET_ADD_ON_LOADED and at weapon swap

FCOPUHelper.isPsijicUndoSkillGiven               = false
local isPsijicUndoSkillGiven                     = FCOPUHelper.isPsijicUndoSkillGiven
FCOPUHelper.isPsijicUndoSkillEquipped            = false
local isPsijicUndoSkillEquipped                  = FCOPUHelper.isPsijicUndoSkillEquipped
FCOPUHelper.activeBarUsesPsijicUndoSkill		 = false
local activeBarUsesPsijicUndoSkill				 = FCOPUHelper.activeBarUsesPsijicUndoSkill

local getActualPowertypeValues

--===================== FUNCTIONS ==============================================
local function getPercent(powerValue, powerMax)
	return zo_round((powerValue / powerMax) * 100), (powerValue / powerMax)
end


local function getUltimateSlotButtonCtrl(hotBarCategory)
	hotBarCategory = hotBarCategory or GetActiveHotbarCategory()
	return ZO_ActionBar_GetButton(CON_ACTIONBAR_ULTIMATE_SLOTNUM, hotBarCategory)
end

local function isAbilityIdPsijicUndoOrMorph(abilityId)
--d("[FCOPUH]isAbilityIdPsijicUndoOrMorph-abilityId: " .. tos(abilityId))
	if abilityId ~= nil and abilityId > 0 and
		(
				(ZO_IsElementInNumericallyIndexedTable(psijicAbilityIdsTemporalGuard, abilityId) == true)
			or 	(ZO_IsElementInNumericallyIndexedTable(psijicAbilityIdsPrecognition, abilityId) == true)
			or 	(ZO_IsElementInNumericallyIndexedTable(psijicAbilityIdsUndo, abilityId) == true)
		)
	then
		return true
	end
	return false
end

--get the Psijic skill line skills
local function getPsijicSkillLineIndexInGuildSkills()
	if psijicSkillLineIndexInGuildSkills ~= nil then return psijicSkillLineIndexInGuildSkills end

	local skillLinesCount = GetNumSkillLines(skillTypeGuild)
	if skillLinesCount == nil then return end
	--GetSkillLineId(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_)
	--** _Returns:_ *integer* _skillLineId_
	local skillLineId
	for i=1, skillLinesCount, 1 do
		skillLineId = GetSkillLineId(skillTypeGuild, i)
		if skillLineId == psijicSkillsSkillLineID then
			FCOPUHelper.psijicSkillLineIndexInGuildSkills = i
			psijicSkillLineIndexInGuildSkills             = FCOPUHelper.psijicSkillLineIndexInGuildSkills
			return i
		end
	end
	return
end

local function registerPowerTypeUpdater(doEnable)
	doEnable = doEnable or false
	isPowerTypeUpdaterActive = FCOPUHelper.isPowerTypeUpdaterActive
--d("[FCOPUH]registerPowerTypeUpdater-doEnable: " .. tos(doEnable) .. ", isPowerTypeUpdaterActive: " .. tos(isPowerTypeUpdaterActive))

	--No Psijic skil line unlocked or the ultimate "Undo" skill is not equipped?
	if isPsijicUndoSkillGiven == false or isPsijicUndoSkillEquipped == false then
		doEnable = false
	end

	if doEnable == true and not isPowerTypeUpdaterActive then
		local updateInterval = FCOPUHelper.settingsVars.settings.trackedTimeFrame * 1000
		if updateInterval > 10000 then updateInterval = 10000 end -- Fix wrong SavedVars or values > 10 seconds
		EM:UnregisterForUpdate(CON_POWER_EVENT_UPDATER_NAME)
		EM:RegisterForUpdate(CON_POWER_EVENT_UPDATER_NAME, updateInterval,
			function()
				getActualPowertypeValues()
			end
		)
		isPowerTypeUpdaterActive = true
	elseif doEnable == false and isPowerTypeUpdaterActive then
		EM:UnregisterForUpdate(CON_POWER_EVENT_UPDATER_NAME)
		isPowerTypeUpdaterActive = false
	end
end

local function checkIfPowerTypeChangeNeedsMonitoring(doForceDisable)
--d("[FCOPUH]checkIfPowerTypeChangeNeedsMonitoring-doForceDisable: " .. tos(doForceDisable))
	doForceDisable = doForceDisable or false
	if doForceDisable == false then
		doForceDisable = IsUnitDead(CON_PLAYER)
	end
	if doForceDisable == false then
		for powerType, isEnabled in pairs(FCOPUHelper.settingsVars.settings.trackedValues) do
			if isEnabled == true then
				registerPowerTypeUpdater(true)
				return true
			end
		end
	end
	registerPowerTypeUpdater(false)
	return false
end

local function checkIfIsPsijicUndoSkillGiven()
--d("[FCOPUH]checkIfIsPsijicUndoSkillGiven")
	local skillIndex = getPsijicSkillLineIndexInGuildSkills()
	if not skillIndex or skillIndex == 0 then
--d("<skillIndex: " ..tos(skillIndex))
		FCOPUHelper.isPsijicUndoSkillGiven = false
		isPsijicUndoSkillGiven             = FCOPUHelper.isPsijicUndoSkillGiven
		return false
	end
	if FCOPUHelper.isPsijicUndoSkillGiven == true then
--d(">isPsijicUndoSkillGiven: " ..tos(isPsijicUndoSkillGiven))
		isPsijicUndoSkillGiven = FCOPUHelper.isPsijicUndoSkillGiven
		return true
	end

	--Read the Psijic skill "Undo" (ultimate)
	psijicSkills = FCOPUHelper.psijicSkills
	if psijicSkills == nil or psijicSkills <= 0 then
--d("<psijicSkills: " ..tos(psijicSkills))
		FCOPUHelper.isPsijicUndoSkillGiven = false
		isPsijicUndoSkillGiven             = FCOPUHelper.isPsijicUndoSkillGiven
		return false
	end

	local undoActiveSkillIndex = 1 --Should be 1 as it's the ultimate
	if not undoActiveSkillIndex then
--d("<undoActiveSkillIndex: " ..tos(undoActiveSkillIndex))
		FCOPUHelper.isPsijicUndoSkillGiven = false
		isPsijicUndoSkillGiven             = FCOPUHelper.isPsijicUndoSkillGiven
		return false
	end

	--* GetSkillAbilityInfo(*[SkillType|#SkillType]* _skillType_, *luaindex* _skillLineIndex_, *luaindex* _skillIndex_)
	--** _Returns:_ *string* _name_, *textureName* _texture_, *luaindex* _earnedRank_, *bool* _passive_, *bool* _ultimate_, *bool* _purchased_, *luaindex:nilable* _progressionIndex_, *integer* _rank_
	local _, _, earnedRank, passive, ultimate, purchased, _, rank = GetSkillAbilityInfo(skillTypeGuild, skillIndex, undoActiveSkillIndex)
----d(">skill name: " ..tos(name) .. ", ultimate: " .. tos(ultimate) .. ", purchased: " ..tos(purchased) .. ", earnedRank: " ..tos(earnedRank) .. ", rank: " ..tos(rank))
	purchased = purchased or false
	passive = passive or false
	ultimate = ultimate or false
	local isPisjicUndoUltimateSkillPurchased = false
	if ultimate and not passive and purchased and earnedRank == 10 and rank >= 1 then
		isPisjicUndoUltimateSkillPurchased = true
	end
--d(">isPisjicUndoUltimateSkillPurchased: " ..tos(isPisjicUndoUltimateSkillPurchased))
	FCOPUHelper.isPsijicUndoSkillGiven = isPisjicUndoUltimateSkillPurchased
	isPsijicUndoSkillGiven             = FCOPUHelper.isPsijicUndoSkillGiven
	return isPisjicUndoUltimateSkillPurchased
end

--Returns: boolean isPsijicUltimateSkillEquippedAtAnyWeaponbar, boolean isPsijicUltimateSkillEquippedAtCurrentlyActiveWeaponBar
local function checkIfIsPsijicUndoSkillEquipped(activeHotBarCategory)
	--d("[FCOPUH]checkIfIsPsijicUndoSkillEquipped-activeHotBarCategory: " .. tos(activeHotBarCategory))
	--Was the Psijic skill line and the ultimate skill purchased already?
	if not isPsijicUndoSkillGiven then
		--d("<isPsijicUndoSkillGiven: false!")
		FCOPUHelper.isPsijicUndoSkillEquipped = false
		isPsijicUndoSkillEquipped             = FCOPUHelper.isPsijicUndoSkillEquipped
		FCOPUHelper.activeBarUsesPsijicUndoSkill = false
		activeBarUsesPsijicUndoSkill		= FCOPUHelper.activeBarUsesPsijicUndoSkill
		return false, false
	end

	--Active weapon bar checks
	if activeHotBarCategory == nil then activeHotBarCategory = GetActiveHotbarCategory() end
	if activeHotBarCategory == nil or (activeHotBarCategory ~= HOTBAR_CATEGORY_PRIMARY and activeHotBarCategory ~= HOTBAR_CATEGORY_BACKUP) then
		--d("<hotBar Category wrong: " .. tos(activeHotBarCategory))
		return isPsijicUndoSkillEquipped, activeBarUsesPsijicUndoSkill
	end

	local anyError = false

	--[Active weapon bar checks]
	FCOPUHelper.isPsijicUndoSkillEquipped 		= false
	isPsijicUndoSkillEquipped             		= FCOPUHelper.isPsijicUndoSkillEquipped
	FCOPUHelper.activeBarUsesPsijicUndoSkill 	= false
	activeBarUsesPsijicUndoSkill				= FCOPUHelper.activeBarUsesPsijicUndoSkill

	--Nothing slotted at all? Check other bar
	if ZO_ActionBar_HasAnyActionSlotted() == false then
		--d("<ZO_ActionBar_HasAnyActionSlotted: false!")
		anyError = true
	end

	--Anything slotted? Check the ultimate slot
	local ultimateSlotButton = getUltimateSlotButtonCtrl(activeHotBarCategory)
	if anyError == false and ultimateSlotButton == nil then
		--d("<ultimateSlotButton: nil!")
		anyError = true
	end

	--Does the ultimate slot have any action/abilityId?
	if anyError == false and (ultimateSlotButton.HasAction == nil or ultimateSlotButton:HasAction() == false) then
		if ultimateSlotButton.iconTexture == nil or ultimateSlotButton.iconTexture.textureFileName == "" then
			--d("<ultimateSlotButton: no action!")
			anyError = true
		end
	end

	--Is the Psijic ultimate abilityId of "Undo", or any of its morphs, slotted?
	if anyError == false then
		local abilityIdOfUltimateSlot = GetSlotBoundId(CON_ACTIONBAR_ULTIMATE_SLOTNUM, activeHotBarCategory)
		if abilityIdOfUltimateSlot ~= nil and isAbilityIdPsijicUndoOrMorph(abilityIdOfUltimateSlot) then
			--d(">Psijic Ultimate undo or morph is slotted on active waeapon bar!")
			FCOPUHelper.isPsijicUndoSkillEquipped = true
			isPsijicUndoSkillEquipped             = FCOPUHelper.isPsijicUndoSkillEquipped
			FCOPUHelper.activeBarUsesPsijicUndoSkill = true
			activeBarUsesPsijicUndoSkill		= FCOPUHelper.activeBarUsesPsijicUndoSkill
			anyError = true
		end
	end

	--Other weapon bar checks - If not already Psijic Ultimate equipped at active bar
	if isPsijicUndoSkillEquipped == false then
		local otherWeaponBarCategory = weaponBar2otherWeaponBar[activeHotBarCategory]
		if otherWeaponBarCategory == nil then return isPsijicUndoSkillEquipped, activeBarUsesPsijicUndoSkill end

		--Nothing slotted at all?
		local anyErrorOtherBar = false
		if ZO_ActionBar_HasAnyActionSlotted() == false then
			--d("<[Other bar]ZO_ActionBar_HasAnyActionSlotted: false!")
			anyErrorOtherBar = true
		end

		--Anything slotted? Check the ultimate slot
		local ultimateSlotButtonOtherBar = getUltimateSlotButtonCtrl(otherWeaponBarCategory)
		if anyErrorOtherBar == false and ultimateSlotButtonOtherBar == nil then
			--d("<[Other bar]ultimateSlotButton: nil!")
			anyErrorOtherBar = true
		end

		--Does the ultimate slot have any action/abilityId?
		-->Slot info at inactive weaponbar is not provided! But the textureFileName of the iconTexture should be filled, if any
		-->Utimate is slotted
		if anyErrorOtherBar == false and (ultimateSlotButtonOtherBar.HasAction == nil or ultimateSlotButtonOtherBar:HasAction() == false) then
			if ultimateSlotButtonOtherBar.iconTexture == nil or ultimateSlotButtonOtherBar.iconTexture.textureFileName == "" then
				--d("<[Other bar]ultimateSlotButton: no action and no texture!")
				anyErrorOtherBar = true
			end
		end

		--Is the Psijic ultimate abilityId of "Undo", or any of its morphs, slotted?
		if anyErrorOtherBar == false then
			local abilityIdOfUltimateSlot = GetSlotBoundId(CON_ACTIONBAR_ULTIMATE_SLOTNUM, otherWeaponBarCategory)
			if abilityIdOfUltimateSlot ~= nil and isAbilityIdPsijicUndoOrMorph(abilityIdOfUltimateSlot) then
				--d(">[Other bar]Psijic Ultimate undo or morph is slotted on other weapon bar!")
				FCOPUHelper.isPsijicUndoSkillEquipped = true
				isPsijicUndoSkillEquipped             = FCOPUHelper.isPsijicUndoSkillEquipped
			end
		end
	end
--d("<isPsijicUndoSkillEquipped: " ..tos(isPsijicUndoSkillEquipped) ..", activeBarUsesPsijicUndoSkill: " ..tos(activeBarUsesPsijicUndoSkill) .. ", activeBar: " ..tos(activeHotBarCategory))
	return isPsijicUndoSkillEquipped, activeBarUsesPsijicUndoSkill
end

local function hideTLCIfNotPsijicUltimateSlotted(pXMLcontrol, doHideOverride)
--d("[FCOPUH]hideTLCIfNotPsijicUltimateSlotted-hideOverride: " ..tos(doHideOverride) ..", alwaysHideTLC: " ..tos(alwaysHideTLC))
	if pXMLcontrol == nil or pXMLcontrol.SetHidden == nil then
		return nil
	end

	if doHideOverride == nil then
		if isPsijicUndoSkillGiven == nil then
			checkIfIsPsijicUndoSkillGiven()
		end
		if isPsijicUndoSkillGiven == true and (isPsijicUndoSkillEquipped == nil or activeBarUsesPsijicUndoSkill == nil) then
			checkIfIsPsijicUndoSkillEquipped()
		end

		if alwaysHideTLC == true then --or SCENE_MANAGER:IsInUIMode() then
			doHideOverride = true
		end
	end

	local settings = FCOPUHelper.settingsVars.settings

	local doHide = doHideOverride
	if doHide == nil and (IsUnitDead(CON_PLAYER) or (settings.onlyInCombat == true and IsUnitInCombat(CON_PLAYER) == false)) then
--d(">>!hide because dead, or not in combat!")
		doHide = true
	else
		if doHide == nil then
			doHide = false
			if isPsijicUndoSkillGiven == false or isPsijicUndoSkillEquipped == false then
				doHide = true
			end
			if doHide == false and (activeBarUsesPsijicUndoSkill == false and settings.onlyShowUIForWeaponBarWithPsijicUltimate == true) then
				doHide = true
			end
		end
	end
--d(">doHide: " ..tos(doHide))
	pXMLcontrol:SetHidden(doHide)
	return doHide
end


local attributeBarsTemplatesUpdated = false
local attributeBarsTLCWasInitialized = false
local myAttributeBars_TEMPLATES = {
    [COMBAT_MECHANIC_FLAGS_MAGICKA] = {
		barControls = { "Bar" },
        background = {
            Left = "ZO_PlayerAttributeBgLeft",
            Right = "ZO_PlayerAttributeBgRight",
            Center = "ZO_PlayerAttributeBgCenter",
            small = "ZO_PlayerAttributeBgSmallCenter",
        },
        frame = {
            Left = "ZO_PlayerAttributeFrameLeft",
            Right = "ZO_PlayerAttributeFrameRight",
            Center = "ZO_PlayerAttributeFrameCenter",
            small = "ZO_PlayerAttributeFrameSmallCenter",
        },
        warner = {
            texture = "ZO_PlayerAttributeMagickaWarnerTexture",
            Left = "ZO_PlayerAttributeWarnerLeft",
            Right = "ZO_PlayerAttributeWarnerRight",
            Center = "ZO_PlayerAttributeWarnerCenter",
        },
        anchors = {
            "ZO_PlayerAttributeBarAnchorLeft",
        },
    },
    [COMBAT_MECHANIC_FLAGS_HEALTH] = {
		barControls = { "Bar" },
        background = {
            Left = "ZO_PlayerAttributeBgLeft",
            Right = "ZO_PlayerAttributeBgRight",
            Center = "ZO_PlayerAttributeBgCenter",
            small = "ZO_PlayerAttributeBgSmallCenter",
        },
        frame = {
            Left = "ZO_PlayerAttributeFrameLeft",
            Right = "ZO_PlayerAttributeFrameRight",
            Center = "ZO_PlayerAttributeFrameCenter",
            small = "ZO_PlayerAttributeFrameSmallCenter",
        },
        warner = {
            texture = "ZO_PlayerAttributeHealthWarnerTexture",
            Left = "ZO_PlayerAttributeWarnerLeft",
            Right = "ZO_PlayerAttributeWarnerRight",
            Center = "ZO_PlayerAttributeWarnerCenter",
        },
        anchors = {
            "ZO_PlayerAttributeHealthBarAnchorLeft",
            "ZO_PlayerAttributeHealthBarAnchorRight",
        },
        smallAnchors = {
            "ZO_PlayerAttributeHealthBarSmallAnchorLeft",
            "ZO_PlayerAttributeHealthBarSmallAnchorRight",
        },
    },
    [COMBAT_MECHANIC_FLAGS_STAMINA] = {
		barControls = { "Bar" },
        background = {
            Left = "ZO_PlayerAttributeBgLeft",
            Right = "ZO_PlayerAttributeBgRight",
            Center = "ZO_PlayerAttributeBgCenter",
            small = "ZO_PlayerAttributeBgSmallCenter",
        },
        frame = {
            Left = "ZO_PlayerAttributeFrameLeft",
            Right = "ZO_PlayerAttributeFrameRight",
            Center = "ZO_PlayerAttributeFrameCenter",
            small = "ZO_PlayerAttributeFrameSmallCenter",
        },
        warner = {
            texture = "ZO_PlayerAttributeStaminaWarnerTexture",
            Left = "ZO_PlayerAttributeWarnerLeft",
            Right = "ZO_PlayerAttributeWarnerRight",
            Center = "ZO_PlayerAttributeWarnerCenter",
        },
        anchors = {
            "ZO_PlayerAttributeBarAnchorRight",
        },
    },

    statusBar = "ZO_PlayerAttributeStatusBar",
    statusBarGloss = "ZO_PlayerAttributeStatusBarGloss",
    statusBarSmall = "ZO_PlayerAttributeStatusBarSmall",
    statusBarGlossSmall = "ZO_PlayerAttributeStatusBarGlossSmall",
    resourceNumbersLabel = "ZO_PlayerAttributeResourceNumbers",

}
local CHILD_DIRECTIONS = { "Left", "Right", "Center" }


local function updateStatusBar(statusBarCtrl, powerType, current, max, effectiveMax)
    local forceInit = false
	if statusBarCtrl.powerType == nil then
		statusBarCtrl.powerType = powerType
	end

    if current == nil or max == nil or effectiveMax == nil then
        current, max, effectiveMax = GetUnitPower(CON_PLAYER, statusBarCtrl.powerType)

        forceInit = true
    end
--d("[FCOPUH]powerType: " ..tos(powerType) .. ", current: " ..tos(current) .. ", max: " ..tos(max) .. ", effectiveMax: " .. tos(effectiveMax))

    if statusBarCtrl.current == current and statusBarCtrl.max == max and statusBarCtrl.effectiveMax == effectiveMax then
        return
    end

    statusBarCtrl.current = current
    statusBarCtrl.max = max
    statusBarCtrl.effectiveMax = effectiveMax

    local barMax = max
    local barCurrent = current
    if #statusBarCtrl.barControls > 1 then
        barMax = barMax / 2
        barCurrent = barCurrent / 2
    end

    for _, control in pairs(statusBarCtrl.barControls) do
        ZO_StatusBar_SmoothTransition(control, barCurrent, barMax, forceInit)
    end

    --[[
	if not forceInit then
        statusBarCtrl:ResetFadeOutDelay()
    end
    statusBarCtrl:UpdateContextualFading()
    ]]

    if statusBarCtrl.control.resourceNumbersLabel then
        statusBarCtrl.control.resourceNumbersLabel:SetText(ZO_FormatResourceBarCurrentAndMax(current, effectiveMax))
    end
end

--[[
local function updateXMLValuesAndHiddenStateZO_PlayerAttributeBars(XMLcontrol, powerType, currentValueOfPowerType)
--d("[FCOPUH]updateXMLValuesAndHiddenStateZO_PlayerAttributeBars-powerType: " .. tos(powerType) .. ", currentValueOfPowerType: " .. tos(currentValueOfPowerType))
	local settings = FCOPUHelper.settingsVars.settings
	if settings == nil then return end

	--Parent the TLC to GuiRoot
	XMLcontrol:SetParent(GuiRoot)

	--Get the health, magicka and stamina controls
	if FCOPUH_TLC.healthCtrl == nil then
		FCOPUH_TLC.healthCtrl = GetControl(XMLcontrol, "Health")
		FCOPUH_TLC.healthBarCtrl = GetControl(FCOPUH_TLC.healthCtrl, "BarLeft")
		FCOPUH_TLC.healthLabelCtrl = GetControl(FCOPUH_TLC.healthCtrl, "ResourceNumbers")
		--FCOPUH_TLC.healthWarnerCtrl = GetControl(FCOPUH_TLC.healthCtrl, "Warner")
		--FCOPUH_TLC.healthWarnerCtrl:SetHidden(true)
	end
	if FCOPUH_TLC.magickaCtrl == nil then
		FCOPUH_TLC.magickaCtrl = GetControl(XMLcontrol, "Magicka")
		FCOPUH_TLC.magickaBarCtrl = GetControl(FCOPUH_TLC.magickaCtrl, "BarLeft")
		FCOPUH_TLC.magickaLabelCtrl = GetControl(FCOPUH_TLC.magickaCtrl, "ResourceNumbers")
		--FCOPUH_TLC.magickaWarnerCtrl = GetControl(FCOPUH_TLC.magickaCtrl, "Warner")
		--FCOPUH_TLC.magickaWarnerCtrl:SetHidden(true)
	end
	if FCOPUH_TLC.staminaCtrl == nil then
		FCOPUH_TLC.staminaCtrl = GetControl(XMLcontrol, "Stamina")
		FCOPUH_TLC.staminaBarCtrl = GetControl(FCOPUH_TLC.staminaCtrl, "BarLeft")
		FCOPUH_TLC.staminaLabelCtrl = GetControl(FCOPUH_TLC.staminaCtrl, "ResourceNumbers")
		--FCOPUH_TLC.staminaWarnerCtrl = GetControl(FCOPUH_TLC.staminaCtrl, "Warner")
		--FCOPUH_TLC.staminaWarnerCtrl:SetHidden(true)
	end

	--Hide the ones disabled in the settings
	local isHealthHidden = not settings.trackedValues[COMBAT_MECHANIC_FLAGS_HEALTH]
	local isMagickaHidden = not settings.trackedValues[COMBAT_MECHANIC_FLAGS_MAGICKA]
	local isStaminaHidden = not settings.trackedValues[COMBAT_MECHANIC_FLAGS_STAMINA]
	FCOPUH_TLC.healthCtrl:SetHidden(isHealthHidden)
	FCOPUH_TLC.magickaCtrl:SetHidden(isMagickaHidden)
	FCOPUH_TLC.staminaCtrl:SetHidden(isStaminaHidden)
	FCOPUH_TLC.healthLabelCtrl:SetHidden(isHealthHidden)
	FCOPUH_TLC.magickaLabelCtrl:SetHidden(isMagickaHidden)
	FCOPUH_TLC.staminaLabelCtrl:SetHidden(isStaminaHidden)


	FCOPUH_TLC.powerTypeBars = {
		[COMBAT_MECHANIC_FLAGS_HEALTH]  = FCOPUH_TLC.healthCtrl,
		[COMBAT_MECHANIC_FLAGS_MAGICKA] = FCOPUH_TLC.magickaCtrl,
		[COMBAT_MECHANIC_FLAGS_STAMINA] = FCOPUH_TLC.staminaCtrl,
	}
	local powerTypeBars = FCOPUH_TLC.powerTypeBars

	FCOPUH_TLC.bars = {
		[COMBAT_MECHANIC_FLAGS_HEALTH]  = FCOPUH_TLC.healthBarCtrl,
		[COMBAT_MECHANIC_FLAGS_MAGICKA] = FCOPUH_TLC.magickaBarCtrl,
		[COMBAT_MECHANIC_FLAGS_STAMINA] = FCOPUH_TLC.staminaBarCtrl,
	}
	local bars = FCOPUH_TLC.bars

	FCOPUH_TLC.labels = {
		[COMBAT_MECHANIC_FLAGS_HEALTH]  = FCOPUH_TLC.healthLabelCtrl,
		[COMBAT_MECHANIC_FLAGS_MAGICKA] = FCOPUH_TLC.magickaLabelCtrl,
		[COMBAT_MECHANIC_FLAGS_STAMINA] = FCOPUH_TLC.staminaLabelCtrl,
	}
	local labels = FCOPUH_TLC.labels


	--Apply the template to the statusBar controls
	if not attributeBarsTemplatesUpdated then
		ApplyTemplateToControl(XMLcontrol, ZO_GetPlatformTemplate("ZO_PlayerAttribute"))
		attributeBarsTemplatesUpdated = true

		for powerTypeOfBar, bar in pairs(powerTypeBars) do
			bar.control = bar
			bar.powerType = powerTypeOfBar

			local powerTypeTemplates = PAB_TEMPLATES[powerTypeOfBar]

			local barControls = powerTypeTemplates.barControls
			local backgroundTemplates = powerTypeTemplates.background
			local frameTemplates = powerTypeTemplates.frame

			if barControls ~= nil then
				local barControlsData = {}
				for _, barcontrolSuffix in ipairs(barControls) do
					table.insert(barControlsData, GetControl(bar, barcontrolSuffix))
				end
				--{GetControl(bar, "BarLeft"), GetControl(bar, "BarRight")}
				bar.barControls = barControlsData

				local gradient = ZO_POWER_BAR_GRADIENT_COLORS[powerType]
				for i, control in ipairs(barControlsData) do
					ZO_StatusBar_SetGradientColor(control, gradient)
					control:SetFadeOutLossColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_OUT, powerType))
					control:SetFadeOutGainColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_IN, powerType))
				end
			end

			local warnerControl = bar.control:GetNamedChild("Warner")
			local bgControl = bar.control:GetNamedChild("BgContainer")

			if warnerControl then
				local warnerTemplates = powerTypeTemplates.warner

				for _, direction in pairs(CHILD_DIRECTIONS) do
					--local bgChild = bgControl:GetNamedChild("Bg" .. direction)
					--ApplyTemplateToControl(bgChild, ZO_GetPlatformTemplate(backgroundTemplates[direction]))

					local frameControl = bar.control:GetNamedChild("Frame" .. direction)
					ApplyTemplateToControl(frameControl, ZO_GetPlatformTemplate(frameTemplates[direction]))

					local warnerChild = warnerControl:GetNamedChild(direction)
					ApplyTemplateToControl(warnerChild, ZO_GetPlatformTemplate(warnerTemplates.texture))
					ApplyTemplateToControl(warnerChild, ZO_GetPlatformTemplate(warnerTemplates[direction]))
				end

				for i, subBar in pairs(bar.barControls) do
					ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(PAB_TEMPLATES.statusBar))

					local gloss = subBar:GetNamedChild("Gloss")
					ApplyTemplateToControl(gloss, ZO_GetPlatformTemplate(PAB_TEMPLATES.statusBarGloss))

					local anchorTemplates = powerTypeTemplates.anchors
					if anchorTemplates then
						subBar:ClearAnchors()
						ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(anchorTemplates[i]))
					else
						ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(PAB_TEMPLATES.anchor))
					end
				end
			else
				ApplyTemplateToControl(bgControl, ZO_GetPlatformTemplate(backgroundTemplates.small))

				local frame = bar.control:GetNamedChild("Frame")
				bar.control.frame = frame
				ApplyTemplateToControl(frame, ZO_GetPlatformTemplate(frameTemplates.small))
				for i, subBar in pairs(bar.barControls) do
					ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(PAB_TEMPLATES.statusBarSmall))

					local gloss = subBar:GetNamedChild("Gloss")
					ApplyTemplateToControl(gloss, ZO_GetPlatformTemplate(PAB_TEMPLATES.statusBarGlossSmall))

					local anchorTemplates = powerTypeTemplates.smallAnchors
					if anchorTemplates then
						subBar:ClearAnchors()
						ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(anchorTemplates[i]))
					end
				end
			end

			local resourceNumbersLabel = bar.control:GetNamedChild("ResourceNumbers")
			if resourceNumbersLabel then
				bar.control.resourceNumbersLabel = resourceNumbersLabel
				ApplyTemplateToControl(resourceNumbersLabel, ZO_GetPlatformTemplate(PAB_TEMPLATES.resourceNumbersLabel))
			end
		end
	end

	--Reanchor it and move it to saved coordinates x and y
	if not FCOPUHelper.isCurrentlyMoved then
		XMLcontrol:ClearAnchors()
		local offsetsUI = settings.UIOffset
		XMLcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetsUI.x, offsetsUI.y)
	end

	--Update the values at the UI -> XML controls of health, magicka, stamina
	if currentValueOfPowerType == nil and powerType ~= nil then
		currentValueOfPowerType = settings.lastSavedValues[powerType]
	end
	if currentValueOfPowerType ~= nil then
		if powerType == nil then
			for powerType, isSupported in pairs(supportedPowerTypes) do
				if isSupported then
					if powerTypeBars[powerType] ~= nil then
						updateStatusBar(powerTypeBars[powerType], powerType, currentValueOfPowerType.value, currentValueOfPowerType.max, currentValueOfPowerType.effectiveMax)
					end
				end
			end
		else
			if powerTypeBars[powerType] ~= nil then
				updateStatusBar(powerTypeBars[powerType], powerType, currentValueOfPowerType.value, currentValueOfPowerType.max, currentValueOfPowerType.effectiveMax)
			end
		end
	end

	--Show/Hide the TLC
	XMLcontrol:SetHidden(false)
end
]]

local function updateXMLValuesAndHiddenState(XMLcontrol, powerType, currentValueOfPowerType)
--d("[FCOPUH]updateXMLValuesAndHiddenState-powerType: " .. tos(powerType) .. ", currentValueOfPowerType: " .. tos(currentValueOfPowerType))
	local settings = FCOPUHelper.settingsVars.settings
	if settings == nil then return end

	--Parent the TLC to GuiRoot
	XMLcontrol:SetParent(GuiRoot)

	--Get the health, magicka and stamina controls
	local powerTypeBars = XMLcontrol.powerTypeBars
	local labels = XMLcontrol.labels
	local bars = XMLcontrol.bars
	if not attributeBarsTLCWasInitialized then
		if XMLcontrol.healthCtrl == nil then
			XMLcontrol.healthCtrl = GetControl(XMLcontrol, "Health")
			XMLcontrol.healthBarCtrl = GetControl(XMLcontrol.healthCtrl, "Bar")
			XMLcontrol.healthLabelCtrl = GetControl(XMLcontrol.healthCtrl, "ResourceNumbers")
		end
		if XMLcontrol.magickaCtrl == nil then
			XMLcontrol.magickaCtrl = GetControl(XMLcontrol, "Magicka")
			XMLcontrol.magickaBarCtrl = GetControl(XMLcontrol.magickaCtrl, "Bar")
			XMLcontrol.magickaLabelCtrl = GetControl(XMLcontrol.magickaCtrl, "ResourceNumbers")
		end
		if XMLcontrol.staminaCtrl == nil then
			XMLcontrol.staminaCtrl = GetControl(XMLcontrol, "Stamina")
			XMLcontrol.staminaBarCtrl = GetControl(XMLcontrol.staminaCtrl, "Bar")
			XMLcontrol.staminaLabelCtrl = GetControl(XMLcontrol.staminaCtrl, "ResourceNumbers")
		end

		XMLcontrol.powerTypeBars = {
			[COMBAT_MECHANIC_FLAGS_HEALTH]  = XMLcontrol.healthCtrl,
			[COMBAT_MECHANIC_FLAGS_MAGICKA] = XMLcontrol.magickaCtrl,
			[COMBAT_MECHANIC_FLAGS_STAMINA] = XMLcontrol.staminaCtrl,
		}
		powerTypeBars = XMLcontrol.powerTypeBars

		XMLcontrol.bars = {
			[COMBAT_MECHANIC_FLAGS_HEALTH]  = XMLcontrol.healthBarCtrl,
			[COMBAT_MECHANIC_FLAGS_MAGICKA] = XMLcontrol.magickaBarCtrl,
			[COMBAT_MECHANIC_FLAGS_STAMINA] = XMLcontrol.staminaBarCtrl,
		}
		bars = XMLcontrol.bars

		XMLcontrol.labels = {
			[COMBAT_MECHANIC_FLAGS_HEALTH]  = XMLcontrol.healthLabelCtrl,
			[COMBAT_MECHANIC_FLAGS_MAGICKA] = XMLcontrol.magickaLabelCtrl,
			[COMBAT_MECHANIC_FLAGS_STAMINA] = XMLcontrol.staminaLabelCtrl,
		}
		labels = XMLcontrol.labels


		--Apply the template to the statusBar controls
		if not attributeBarsTemplatesUpdated then
			ApplyTemplateToControl(XMLcontrol, ZO_GetPlatformTemplate("ZO_PlayerAttribute"))
			attributeBarsTemplatesUpdated = true

			for powerTypeOfBar, bar in pairs(powerTypeBars) do
				bar.control = bar
				bar.powerType = powerTypeOfBar

				local powerTypeTemplates = myAttributeBars_TEMPLATES[powerTypeOfBar]

				local barControls = powerTypeTemplates.barControls
				local backgroundTemplates = powerTypeTemplates.background
				local frameTemplates = powerTypeTemplates.frame

				if barControls ~= nil then
					local barControlsData = {}
					for _, barcontrolSuffix in ipairs(barControls) do
						table.insert(barControlsData, GetControl(bar, barcontrolSuffix))
					end
					--{GetControl(bar, "BarLeft"), GetControl(bar, "BarRight")}
					bar.barControls = barControlsData

					local gradient = ZO_POWER_BAR_GRADIENT_COLORS[powerTypeOfBar]
					for i, control in ipairs(barControlsData) do
						ZO_StatusBar_SetGradientColor(control, gradient)
						control:SetFadeOutLossColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_OUT, powerTypeOfBar))
						control:SetFadeOutGainColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_IN, powerTypeOfBar))
					end
				end

				--local warnerControl = bar.control:GetNamedChild("Warner")
				local bgControl = bar.control:GetNamedChild("BgContainer")
				local frameControl = bar.control:GetNamedChild("Frame")
				ApplyTemplateToControl(frameControl, ZO_GetPlatformTemplate(frameTemplates["Center"]))
				frameControl:SetHidden(true)

				for _, direction in pairs(CHILD_DIRECTIONS) do
					local bgChild = bgControl:GetNamedChild("Bg" .. direction)
					if bgChild ~= nil then
						ApplyTemplateToControl(bgChild, ZO_GetPlatformTemplate(backgroundTemplates[direction]))
						bgChild:SetHidden(true)
					end
				end

				for i, subBar in pairs(bar.barControls) do
					ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(myAttributeBars_TEMPLATES.statusBar))

					local gloss = subBar:GetNamedChild("Gloss")
					ApplyTemplateToControl(gloss, ZO_GetPlatformTemplate(myAttributeBars_TEMPLATES.statusBarGloss))

					--[[
					local anchorTemplates = powerTypeTemplates.anchors
					if anchorTemplates then
						subBar:ClearAnchors()
						ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(anchorTemplates[i]))
					else
						ApplyTemplateToControl(subBar, ZO_GetPlatformTemplate(myAttributeBars_TEMPLATES.anchor))
					end
					]]
				end

				local resourceNumbersLabel = bar.control:GetNamedChild("ResourceNumbers")
				if resourceNumbersLabel ~= nil then
					bar.control.resourceNumbersLabel = resourceNumbersLabel
					ApplyTemplateToControl(resourceNumbersLabel, ZO_GetPlatformTemplate(myAttributeBars_TEMPLATES.resourceNumbersLabel))
				end
			end
		end
		attributeBarsTLCWasInitialized = true
	end

	--Reanchor it and move it to saved coordinates x and y
	if not FCOPUHelper.isCurrentlyMoved then
		XMLcontrol:ClearAnchors()
		local offsetsUI = settings.UIOffset
		XMLcontrol:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetsUI.x, offsetsUI.y)

		--Hide the bars disabled in the settings
		local isHealthHidden = not settings.trackedValues[COMBAT_MECHANIC_FLAGS_HEALTH]
		local isMagickaHidden = not settings.trackedValues[COMBAT_MECHANIC_FLAGS_MAGICKA]
		local isStaminaHidden = not settings.trackedValues[COMBAT_MECHANIC_FLAGS_STAMINA]
		if isHealthHidden == true and isMagickaHidden == true and isStaminaHidden == true then
			--ReEnable at least the health
			FCOPUHelper.settingsVars.settings.trackedValues[COMBAT_MECHANIC_FLAGS_HEALTH] = true
			isHealthHidden = false
		end
		XMLcontrol.healthCtrl:SetHidden(isHealthHidden)
		XMLcontrol.magickaCtrl:SetHidden(isMagickaHidden)
		XMLcontrol.staminaCtrl:SetHidden(isStaminaHidden)

		local alpha = 1
		if settings.UIAlphaByPsijicUltimateValue == true then
			if isPsijicUndoSkillGiven == true then
				--Get the ultimate value of the current weapon bar (or the other bar if the ultimate skill is slotetd there)
				if isPsijicUndoSkillEquipped == true then
					local ultiValue, ultiMax = GetUnitPower(CON_PLAYER, COMBAT_MECHANIC_FLAGS_ULTIMATE)
					if ultiValue == nil or ultiMax == nil or ultiValue == 0 or ultiMax == 0 then
						alpha = tonumber(settings.UIAlphaMin)
					else
						FCOPUHelper.activeHotbarCategory = GetActiveHotbarCategory()
						local activeHotbarCategory = FCOPUHelper.activeHotbarCategory
						if activeBarUsesPsijicUndoSkill == false then
							activeHotbarCategory = weaponBar2otherWeaponBar[activeHotbarCategory]
						end
						local ultiCost = GetSlotAbilityCost(CON_ACTIONBAR_ULTIMATE_SLOTNUM, COMBAT_MECHANIC_FLAGS_ULTIMATE, activeHotbarCategory)
						local ultiPercent, ultiPercentBase = getPercent(ultiValue, ultiCost)
						alpha = zo_clamp(ultiPercentBase, tonumber(settings.UIAlphaMin), 1.0)
--d(">>ultiV: " .. tos(ultiValue) .. ", ultiCost: " ..tos(ultiCost) ..", ulti%: " ..tos(ultiPercent) .. " ultiPercB: " .. tos(ultiPercentBase) .. ", alpha: " ..tos(alpha))
					end
				else
					alpha = tonumber(settings.UIAlphaMin)
				end
			end
		end

		--Reanchor the bars to each other (top: health, medium: magicka, bottom: stamina)
		local relativeTo = XMLcontrol
		if not isHealthHidden then
			XMLcontrol.healthCtrl:SetAnchor(TOPLEFT, relativeTo, TOPLEFT)
			relativeTo = XMLcontrol.healthCtrl
			XMLcontrol.healthCtrl:SetAlpha(alpha)
		end
		if not isMagickaHidden then
			XMLcontrol.magickaCtrl:SetAnchor(TOPLEFT, relativeTo, BOTTOMLEFT)
			relativeTo = XMLcontrol.magickaCtrl
			XMLcontrol.magickaCtrl:SetAlpha(alpha)
		end
		if not isStaminaHidden then
			XMLcontrol.staminaCtrl:SetAnchor(TOPLEFT, relativeTo, BOTTOMLEFT)
			relativeTo = XMLcontrol.staminaCtrl
			XMLcontrol.staminaCtrl:SetAlpha(alpha)
		end
	else
		--d(">TLC is currently moved!")
		return
	end

	--Update the values at the UI -> XML controls of health, magicka, stamina
	if currentValueOfPowerType == nil and powerType ~= nil then
		currentValueOfPowerType = settings.lastSavedValues[powerType]
	end
	if currentValueOfPowerType ~= nil then
		if powerType == nil then
			for powerType, isSupported in pairs(supportedPowerTypes) do
				if isSupported then
					if powerTypeBars[powerType] ~= nil then
						updateStatusBar(powerTypeBars[powerType], powerType, currentValueOfPowerType.value, currentValueOfPowerType.max, currentValueOfPowerType.effectiveMax)
					end
				end
			end
		else
			if powerTypeBars[powerType] ~= nil then
				updateStatusBar(powerTypeBars[powerType], powerType, currentValueOfPowerType.value, currentValueOfPowerType.max, currentValueOfPowerType.effectiveMax)
			end
		end
	end

	--Hide the TLC if ultimate is not slotted
	local wasTLCHidden = hideTLCIfNotPsijicUltimateSlotted(XMLcontrol, nil)
	if wasTLCHidden == true or wasTLCHidden == nil then
--d("<XML TLC was hidden!")
		return
	end
end

local function updateAllPowerTypesAtUI()
	updateXMLValuesAndHiddenState(FCOPUH_TLC, nil, nil)
end

local function updateLastSavedValuesAtUI(powerType, currentValueOfPowerType)
--d("[FCOPUH]updateLastSavedValuesAtUI-powerType: " ..tos(powerType) .. ", value: " ..tos(currentValueOfPowerType))
	if powerType == nil or FCOPUH_TLC == nil then return end
	updateXMLValuesAndHiddenState(FCOPUH_TLC, powerType, currentValueOfPowerType)
end


local function updateLastSavedValues(powerType, nowTime, currentValues)
--d("[FCOPUH]getActualPowertypeValues-powerType: " .. tos(powerType) .. ", nowTime: " .. tos(nowTime))
	if powerType == nil or nowTime == nil or currentValues == nil then return end
	--local settings = FCOPUHelper.settingsVars.settings
	--if settings == nil then return end

	--Save the actual values
	--{ current = currentPower, max = maxPower, effectiveMax = effectiveMaxPower}
	local lastSavedValues = FCOPUHelper.settingsVars.settings.lastSavedValues
	local lastSavedValuesAtPowerType = lastSavedValues[powerType]
	if lastSavedValuesAtPowerType == nil then
		lastSavedValues[powerType] = {}
		lastSavedValuesAtPowerType = lastSavedValues[powerType]
	end

	lastSavedValuesAtPowerType.value = currentValues.current
	lastSavedValuesAtPowerType.max = currentValues.max
	lastSavedValuesAtPowerType.effectiveMax = currentValues.effectiveMax

	--Save the last time we have updated the powerTypes
	FCOPUHelper.settingsVars.settings.lastSavedTime = nowTime --GetTimeStamp() + GetGameTimeMilliseconds()

	updateLastSavedValuesAtUI(powerType, lastSavedValuesAtPowerType)
end


getActualPowertypeValues = function (powerType, powerValue, powerMax, powerEffectiveMax)
	if not isPsijicUndoSkillGiven or not isPsijicUndoSkillEquipped then return end
	local nowTime = GetTimeStamp() + GetGameTimeMilliseconds()
--d("[FCOPUH]getActualPowertypeValues-powerType: " .. tos(powerType) .. ", nowTime: " .. tos(nowTime) .. ", powerValue: " .. tos(powerValue) .. ", powerMax: " .. tos(powerMax) .. ", powerEffectiveMax: " .. tos(powerEffectiveMax))

	--* GetUnitPower(*string* _unitTag_, *[CombatMechanicFlags|#CombatMechanicFlags]* _powerType_)
	--** _Returns:_ *integer* _current_, *integer* _max_, *integer* _effectiveMax_
	--Update all powertyes?
	if powerType == nil then
		for powerType, isSupported in pairs(supportedPowerTypes) do
			if isSupported then
				local currentPower, maxPower, effectiveMaxPower = GetUnitPower(CON_PLAYER, powerType)
				currentValues[powerType] = { current = currentPower, max = maxPower, effectiveMax = effectiveMaxPower}
				updateLastSavedValues(powerType, nowTime, currentValues[powerType])
			end
		end
	else
		if not supportedPowerTypes[powerType] then return end
		if powerValue == nil or powerMax == nil or powerEffectiveMax == nil then return end
		currentValues[powerType] = { current = powerValue, max = powerMax, effectiveMax = powerEffectiveMax}
		updateLastSavedValues(powerType, nowTime, currentValues[powerType])
	end
end



--[[
--Show a help inside the chat
local function help()
	d("[FCO PsijicUndoHelper]")
	d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
end

--Check the commands ppl type to the chat
local function command_handler(args)
    --Parse the arguments string
	local options = {}
    local searchResult = { string.match(args, "^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end

	if #options == 0 or options[1] == "" or options[1] == "help" or options[1] == "hilfe" or options[1] == "aide" or options[1] == "list" then
		help()
	else
	end
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/FCONewAddon"] 	= command_handler
	SLASH_COMMANDS["/fcna"] 		= command_handler
end
]]


--Check for other addons and react on them
--[[
local function CheckIfOtherAddonsActive()
	return false
end
]]

--==============================================================================
--==================== START EVENT CALLBACK FUNCTIONS===========================
--==============================================================================

--[[
local function FCOPsijicUndoHelperAddon_OnPowerUpdate(eventId, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	--PowerType and unitTag should be filtered by event filers already!
	--if powerType == nil then return end
	getActualPowertypeValues(powerType, powerValue)
end
]]

local function FCOPsijicUndoHelperAddon_OnDeathStateChange(eventId, unitTag, isDead)
	--if unitTag ~= CON_PLAYER then return end -- Done via event filters
	checkIfPowerTypeChangeNeedsMonitoring(isDead or (not isPsijicUndoSkillEquipped))
end

--New skill line unlocked?
local function FCOPsijicUndoHelperAddon_OnSkillLineAdded (eventId, skillType, skillLineIndex, advised)
	if skillType ~= skillTypeGuild or skillLineIndex ~= psijicSkillsSkillLineID then return end
	if checkIfIsPsijicUndoSkillGiven() == true then return end
	--Psijic skill line unlocked
	--d("[FCOPUH]Psijic SkillLine got unlocked!")

	getPsijicSkillLineIndexInGuildSkills()
	checkIfIsPsijicUndoSkillGiven() --Is the Psijic ultimate skkill given now?
	if isPsijicUndoSkillGiven == true then
		checkIfIsPsijicUndoSkillEquipped()
	end

	checkIfPowerTypeChangeNeedsMonitoring(not isPsijicUndoSkillEquipped) --Update the checks every n seconds, or disable them
end

local function updateUltimateSlotForActiveHotbar(didActiveHotbarChange, activeHotbarCategory)
--d("[FCOPUH]updateUltimateSlotForActiveHotbar-didActiveHotbarChange: " ..tos(didActiveHotbarChange) .. ", activeHotbarCategory: " ..tos(activeHotbarCategory))
	if not didActiveHotbarChange then return end

	--Hide the TLC
	hideTLCIfNotPsijicUltimateSlotted(FCOPUH_TLC, true)
	--Delay to next frame so the weapon bar's ulti slot data will build properly
	--zo_callLater(function()
		--Check if the active bar got the Psijic ultimate skill slotted
		-->Attention: Also checks the non active bar for the ultimate skill slotted to keep the variable isPsijicUndoSkillEquipped = true in that case
		checkIfIsPsijicUndoSkillEquipped(activeHotbarCategory)
		if isPsijicUndoSkillEquipped == true then
			--if activeBarUsesPsijicUndoSkill == true then
				--Show the TLC, if needed
				hideTLCIfNotPsijicUltimateSlotted(FCOPUH_TLC, nil)
			--end
			--Enable the updaters, if not already running
			checkIfPowerTypeChangeNeedsMonitoring()
			return
		end
		--If both bars do not use the ultimate, then stop the updaters
		checkIfPowerTypeChangeNeedsMonitoring(true)
	--end, 0)
end

local function FCOPsijicUndoHelperAddon_OnActiveHotbarUpdated(event, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
--d("[FCOPUH]OnActiveHotbarUpdated-didActiveHotbarChange: " ..tos(didActiveHotbarChange) .. ", shouldUpdateAbilityAssignments: " ..tos(shouldUpdateAbilityAssignments) .. ", activeHotbarCategory: " ..tos(activeHotbarCategory))
	updateUltimateSlotForActiveHotbar(didActiveHotbarChange, activeHotbarCategory)
end

local function FCOPsijicUndoHelperAddon_OnActiveWeaponPairChanged(eventCode, activeWeaponPair)
--d("[FCOPUH]OnActiveWeaponPairChanged-activeWeaponPair: " ..tos(activeWeaponPair))
	--Hide the TLC if ultimate is not slotted
	if activeWeaponPair == ACTIVE_WEAPON_PAIR_MAIN or activeWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
		FCOPUHelper.activeWeaponBar = activeWeaponPair
		FCOPUHelper.activeHotbarCategory = GetActiveHotbarCategory()
		updateUltimateSlotForActiveHotbar(true, FCOPUHelper.activeHotbarCategory)
	end
end

local function FCOPsijicUndoHelperAddon_OnActionSlotUpdated(eventCode, actionSlotIndex)
--d("[FCOPUH]OnActinSlotUpdated-actionSlotIndex: " ..tos(actionSlotIndex))
	if actionSlotIndex == CON_ACTIONBAR_ULTIMATE_SLOTNUM then
		updateUltimateSlotForActiveHotbar(true)
	end
end

--[[
local function FCOPsijicUndoHelperAddon_OnItemSlotChanged(eventCode, soundCategory)
d("[FCOPUH]OnActiveHotbarUpdated-OnItemSlotChanged: " ..tos(soundCategory))
	updateUltimateSlotForActiveHotbar(true)
end
]]




local function FCOPsijicUndoHelperAddon_OnPlayerCombatState(eventId, inCombat)
	--updateAllPowerTypesAtUI()
	--Hide/Show the TLC based on the combat state
	hideTLCIfNotPsijicUltimateSlotted(FCOPUH_TLC, not inCombat)
end


local function checkInCombatState()
	if FCOPUHelper.settingsVars.settings.onlyInCombat == true then
		EM:RegisterForEvent(addonName .. "_EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, FCOPsijicUndoHelperAddon_OnPlayerCombatState)
	else
		EM:UnregisterForEvent(addonName .. "_EVENT_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE)
	end
end


--==============================================================================
--============================== BEGIN SETTINGS ==================================
--==============================================================================


-- Build the options menu
local function BuildAddonMenu()
	local panelData = {
		type 				= 'panel',
		name 				= addonVars.addonNameMenu,
		displayName 		= addonVars.addonNameMenuDisplay,
		author 				= addonVars.addonAuthor,
		version 			= addonVars.addonVersionOptions,
		registerForRefresh 	= true,
		registerForDefaults = true,
		slashCommand 		= "/fconas",
	}

    local savedVariablesOptions = {
    	[1] = "Per character",
        [2] = "Account wide",
    }
    local savedVariablesOptionsValues = {
		[1] = 1,
		[2] = 2,
	}

	local settings            = FCOPUHelper.settingsVars.settings
	local defaultSettings     = FCOPUHelper.settingsVars.defaults

	FCOPUHelper.SettingsPanel = LAM:RegisterAddonPanel(addonName .. "_LAM", panelData)


--LAM 2.0 callback function if the panel was created
	--[[
    local FCOLAMPanelCreated
	FCOLAMPanelCreated = function(panel)
        if panel ~= FCONA.SettingsPanel then return end
    end
    ]]

	local optionsTable        = {    -- BEGIN OF OPTIONS TABLE

		{
			type = 'description',
			text = "Helper addon for the Psijic skill line's skill 'Undo'/'Temporal Guard'/'Precognition'",
		},
		--==============================================================================
		{
			type          = 'dropdown',
			name          = "SavedVariables save mode",
			tooltip       = "Chosoe how your settings will be saved",
			choices       = savedVariablesOptions,
			choicesValues = savedVariablesOptionsValues,
			getFunc       = function() return FCOPUHelper.settingsVars.defaultSettings.saveMode end,
			setFunc       = function(value)
				FCOPUHelper.settingsVars.defaultSettings.saveMode = value
				ReloadUI()
			end,
			warning       = "Changing this setting will reload your UI!",
		},
		--==============================================================================
		{
			type = 'header',
			name = "'UI settings",
		},
		{
			type    = "checkbox",
			name    = "Only show: In combat",
			tooltip = "Show the UI only during combat",
			getFunc = function() return settings.onlyInCombat end,
			setFunc = function(value)
				settings.onlyInCombat = value
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
				checkInCombatState()
			end,
			default = defaultSettings.onlyInCombat,
		},
		{
			type    = "checkbox",
			name    = "Only show: Active bar got skill slotted",
			tooltip = "Show the UI only if the active weapon bar got the Psijic ultimate skill  slotted. if the other bar got the skill slotted the values will still be saved every n seconds (chosoe below) but the UI will only be shown at the weapon bar(s) where the skill is actually slotted.",
			getFunc = function() return settings.onlyShowUIForWeaponBarWithPsijicUltimate end,
			setFunc = function(value)
				settings.onlyShowUIForWeaponBarWithPsijicUltimate = value
				checkIfIsPsijicUndoSkillEquipped()
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			default = defaultSettings.onlyShowUIForWeaponBarWithPsijicUltimate,
		},
		{
			type    = "checkbox",
			name    = "Alpha: Based on ultimate value",
			tooltip = "Show the UI's alpha/opacity based on the current ultimate value. It will shine thrugh if the ultimate is not ready and it will be fully visible if the ultimate is ready.",
			getFunc = function() return settings.UIAlphaByPsijicUltimateValue end,
			setFunc = function(value)
				settings.UIAlphaByPsijicUltimateValue = value
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			default = defaultSettings.UIAlphaByPsijicUltimateValue,
		},
		{
			type    = "slider",
			name    = "Alpha: Minimum value",
			tooltip = "The minimum UI's alpha value. Default is 0.3",
			getFunc = function() return tonumber(settings.UIAlphaMin) end,
			setFunc = function(value)
				settings.UIAlphaMin = tonumber(value)
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			min = 0.1,
			max = 0.9,
			step = 0.1,
			clampInput = true,
			decimals = 1,
			readOnly = false,
			disabled = function() return not settings.UIAlphaByPsijicUltimateValue end,
			default = defaultSettings.UIAlphaMin,
		},


		{
			type = 'header',
			name = "Tracked attributes",
		},
		{
			type    = "checkbox",
			name    = "Track health",
			tooltip = "Track the health changes and show the health value at the UI",
			getFunc = function() return settings.trackedValues[COMBAT_MECHANIC_FLAGS_HEALTH] end,
			setFunc = function(value)
				settings.trackedValues[COMBAT_MECHANIC_FLAGS_HEALTH] = value
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			default = defaultSettings.trackedValues[COMBAT_MECHANIC_FLAGS_HEALTH],
		},
		{
			type    = "checkbox",
			name    = "Track magicka",
			tooltip = "Track the magicka changes and show the magicka value at the UI",
			getFunc = function() return settings.trackedValues[COMBAT_MECHANIC_FLAGS_MAGICKA] end,
			setFunc = function(value)
				settings.trackedValues[COMBAT_MECHANIC_FLAGS_MAGICKA] = value
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			default = defaultSettings.trackedValues[COMBAT_MECHANIC_FLAGS_MAGICKA],
		},
		{
			type    = "checkbox",
			name    = "Track stamina",
			tooltip = "Track the stamina changes and show the stamina value at the UI",
			getFunc = function() return settings.trackedValues[COMBAT_MECHANIC_FLAGS_STAMINA] end,
			setFunc = function(value)
				settings.trackedValues[COMBAT_MECHANIC_FLAGS_STAMINA] = value
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			default = defaultSettings.trackedValues[COMBAT_MECHANIC_FLAGS_STAMINA],
		},

		{
			type    = "slider",
			name    = "Tracked seconds",
			tooltip = "Track the health/magicka/stamina values state of the past: Choose the seconds in the past here. Default value by the skill 'Undo' is 4 seconds in the past.",
			getFunc = function() return settings.trackedTimeFrame end,
			setFunc = function(value)
				settings.trackedTimeFrame = value
				--Stop active monitoring, so that the seconds will change
				checkIfPowerTypeChangeNeedsMonitoring(true)
				updateAllPowerTypesAtUI()
				updateUltimateSlotForActiveHotbar(true)
			end,
			disabled = false,
			min = 0.1,
			max = 10,
			step = 0.1,
			decimals = 2,
			readOnly = false,
			clamp = true,
			default = defaultSettings.trackedTimeFrame,
		},
	}

	--CM:RegisterCallback("LAM-PanelControlsCreated", FCOLAMPanelCreated)
	LAM:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end

--==============================================================================
--============================== END SETTINGS ==================================
--==============================================================================


--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================

--Create the hooks & pre-hooks
local function CreateHooks()
	--React on an input mode change keyboard->gamepad->keyboard and register the needed hooks
	--EM:RegisterForEvent(addonName .. "_EVENT_INPUT_TYPE_CHANGED", EVENT_INPUT_TYPE_CHANGED, onEventInputTypeChanged)
end

--Load the SavedVariables
local function LoadUserSettings()
--The default values for the language and save mode
    FCOPUHelper.settingsVars.firstRunSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide FCONA.settingsVars.settings
    }

    --Pre-set the deafult values
    FCOPUHelper.settingsVars.defaults         = {
		trackedValues = {
			[COMBAT_MECHANIC_FLAGS_HEALTH] = true,
			[COMBAT_MECHANIC_FLAGS_MAGICKA] = true,
			[COMBAT_MECHANIC_FLAGS_STAMINA] = true,
		},
		trackedTimeFrame = 4, --seconds to track health/magicka/stamina values backwards
		lastUIUpdateTime = 0,
		--The saved values of each powerType
		lastSavedTime = 0, --GetTimeStamp() + GetGameTimeMilliseconds() of the last time as the powerTypes were saved to the SV
		lastSavedValues = {
			[COMBAT_MECHANIC_FLAGS_HEALTH] = {value=0, max=0, effectiveMax=0},
			[COMBAT_MECHANIC_FLAGS_MAGICKA] = {value=0, max=0, effectiveMax=0},
			[COMBAT_MECHANIC_FLAGS_STAMINA] = {value=0, max=0, effectiveMax=0},
		},
		--The User Interface offsets for the ML TLC
		UIOffset = {
			x = 400,
			y = 100,
		},
		onlyInCombat = false,
		onlyShowUIForWeaponBarWithPsijicUltimate = true,
		UIAlphaByPsijicUltimateValue = false,
		UIAlphaMin = 0.3,
    }
	local defaults                            = FCOPUHelper.settingsVars.defaults

	local worldName = GetWorldName()
	local addonSavedVariablesName = addonVars.addonSavedVariablesName
	local addonSavedVariablesVersion = addonVars.addonSavedVariablesVersion

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    --Load the user's FCONA.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
	FCOPUHelper.settingsVars.defaultSettings  = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, 999, "SettingsForAll", FCOPUHelper.settingsVars.firstRunSettings, worldName)

	--Check, by help of basic version 999 FCONA.settingsVars.settings, if the FCONA.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCONA.settingsVars.settings now
	if (FCOPUHelper.settingsVars.defaultSettings.saveMode == 1) then
    	FCOPUHelper.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName)
	else
		FCOPUHelper.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName, nil)
	end
--=============================================================================================================
end


--OnMove of the XML control (drag & drop)
function FCOPUHelper.XMLTLC_OnMoveStart(XMLcontrol)
	FCOPUHelper.isCurrentlyMoved = true
end

function FCOPUHelper.XMLTLC_OnMoveStop(XMLcontrol)
	if not FCOPUHelper.isCurrentlyMoved then return end
	local settings = FCOPUHelper.settingsVars.settings
	if settings == nil then return end

	local left = XMLcontrol:GetLeft()
	local top =  XMLcontrol:GetTop()
	settings.UIOffset = {
		x = left,
		y = top,
	}

	FCOPUHelper.isCurrentlyMoved = false
end


--Initialize the XML attribte bar controls
function FCOPUHelper.XMLTLC_OnInitialized(XMLcontrol)
--d("[FCOPUH]XMLTLC_OnInitialized")
	--Update the TopLevelControl UI XML
	FCOPUH_TLC = XMLcontrol
	FCOPUHelper.TLC_XML_CONTROL = FCOPUH_TLC

	updateAllPowerTypesAtUI()
end

--Addons loaded and palyer & chat is ready
local function FCOPsijicUndoHelperAddon_OnPlayerActivated(eventId, isFirst)
	--Hide the XML TLC if the Psijic ulti is not equipped at the current weapon bar
	local isPsijicUltiNotEquippedAtBar = not isPsijicUndoSkillEquipped
	hideTLCIfNotPsijicUltimateSlotted(FCOPUH_TLC, nil)
	--Check every n seconds for the actual powertyp values and show them at the UI (for n seconds, then update)
	checkIfPowerTypeChangeNeedsMonitoring(isPsijicUltiNotEquippedAtBar)
end


--Addon loads up
local function FCOPsijicUndoHelperAddon_Loaded(eventCode, addOnNameOfEachAddonLoaded)
	--Is this addon found?
	if addOnNameOfEachAddonLoaded ~= addonName then return end
	--Unregister this event again so it isn't fired again after this addon has beend reckognized
    EM:UnregisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)

	addonVars.gAddonLoaded = false

	--SavedVariables
    LoadUserSettings()


	--Get the Psijic Skill Line index
	getPsijicSkillLineIndexInGuildSkills()
	--Get the Psijic Skill line data (all active and passive skills)
	FCOPUHelper.psijicSkills = GetNumSkillAbilities(skillTypeGuild, psijicSkillLineIndexInGuildSkills)
	psijicSkills             = FCOPUHelper.psijicSkills

	FCOPUHelper.activeWeaponBar = GetActiveWeaponPairInfo()
	FCOPUHelper.activeHotbarCategory = GetActiveHotbarCategory()

	--Is the Psijic skill line purchased/unlocked and is the Undo skill (ultimate) equipped?
	checkIfIsPsijicUndoSkillGiven()
	checkIfIsPsijicUndoSkillEquipped()


	--Build the settings menu
	BuildAddonMenu()

	--Create the hooks
    --CreateHooks()

    -- Register slash commands
    --RegisterSlashCommands()

	--Get actual values of health/magicka/stamina
	getActualPowertypeValues(nil)

	--Hide the TLC, if already existing and Ultimate slot at active weapon bar is not the psijic one
	FCOPUHelper.XMLTLC_OnInitialized(FCOPsijicUndoHelperTLC)


    --You can also just use ZO_SimpleSceneFragment instead of ZO_HUDFadeSceneFragment
	local fragment = ZO_HUDFadeSceneFragment:New(FCOPsijicUndoHelperTLC, nil, 0)
	local function OnFCOPUHFragmentStateChange(oldState, newState)
		local currentScene = SCENE_MANAGER:GetCurrentScene()
		if currentScene ~= nil and currentScene == HUD_SCENE then
			--local sceneName = SCENE_MANAGER:GetCurrentSceneName()
			if newState == SCENE_FRAGMENT_SHOWING then
--d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
--d(">>>> SCENE SHOWING: " ..tos(sceneName))
				--Re-Enable the normal SetHidden of the TLC now
				alwaysHideTLC = false

			elseif newState == SCENE_FRAGMENT_SHOWN then
				--Re-Enable the normal SetHidden of the TLC now
				alwaysHideTLC = false
				hideTLCIfNotPsijicUltimateSlotted(FCOPsijicUndoHelperTLC, nil)

			elseif newState == SCENE_FRAGMENT_HIDING then
--d(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
--d("<<<<<<<<<<< SCENE HIDING: " ..tos(sceneName))
				--Disable the normal SetHidden of the TLC now
				alwaysHideTLC = true
			end
		end
	end
	fragment:RegisterCallback("StateChange", OnFCOPUHFragmentStateChange)
	--Hide in menus/Show at fighting UI
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)


	--Events
	EM:RegisterForEvent(addonName .. "_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, FCOPsijicUndoHelperAddon_OnPlayerActivated)

	EM:RegisterForEvent(addonName .. "_EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED, FCOPsijicUndoHelperAddon_OnDeathStateChange)
	EM:AddFilterForEvent(addonName.. "_EVENT_UNIT_DEATH_STATE_CHANGED", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, CON_PLAYER)

	EM:RegisterForEvent(addonName .. "_EVENT_SKILL_LINE_ADDED", EVENT_SKILL_LINE_ADDED, FCOPsijicUndoHelperAddon_OnSkillLineAdded)
	EM:RegisterForEvent(addonName .. "_EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, FCOPsijicUndoHelperAddon_OnActiveHotbarUpdated)
	--EM:RegisterForEvent(addonName .. "_EVENT_ITEM_SLOT_CHANGED", EVENT_ITEM_SLOT_CHANGED, FCOPsijicUndoHelperAddon_OnItemSlotChanged)
	EM:RegisterForEvent(addonName .. "_EVENT_ACTION_SLOT_UPDATED", EVENT_ACTION_SLOT_UPDATED, FCOPsijicUndoHelperAddon_OnActionSlotUpdated)

	EM:RegisterForEvent(addonName .. "_EVENT_ACTIVE_WEAPON_PAIR_CHANGED", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, FCOPsijicUndoHelperAddon_OnActiveWeaponPairChanged)

	checkInCombatState()


	local function OnSlotUpdated(hotbarCategory, slotIndex, isChangedByPlayer)
--d("[FCOPUH]ActionBar:OnSlotUpdated")
		if isChangedByPlayer and (hotbarCategory == HOTBAR_CATEGORY_PRIMARY or hotbarCategory == HOTBAR_CATEGORY_BACKUP) and slotIndex == CON_ACTIONBAR_ULTIMATE_SLOTNUM then
--d(">changed ULTIMATE by player!")
			--Hide the TLC
			hideTLCIfNotPsijicUltimateSlotted(FCOPUH_TLC, true)
			--Disable the updaters
			checkIfPowerTypeChangeNeedsMonitoring(true)

			--Call 250ms later so that the dragged/changed ultimate slot updates properly
			zo_callLater(function()
				--Update all the powertypes once now
				updateAllPowerTypesAtUI()
				--Is the Psijic ultimate skill currently slotted, or not?
				updateUltimateSlotForActiveHotbar(true, hotbarCategory)
			end, 250)
		end
	end
	--[[
	--Only active during respec?
	zosVars.SKILLS_AND_ACTION_BAR_MANAGER:RegisterCallback("SlotUpdated", OnSlotUpdated)
	]]
	--Active during normal slot changes at the actinBar
	zosVars.ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback("SlotUpdated", OnSlotUpdated)


	--Powertype update
	--[[
	local powerTypeEventStr = addonName .. "EVENT_POWER_UPDATE"
	for powerType, isSupported in pairs(supportedPowerTypes) do
		if isSupported then
			local eventFilterUniqueId = powerTypeEventStr .. tos(powerType)
			EM:RegisterForEvent(powerTypeEventStr, EVENT_POWER_UPDATE, FCOPsijicUndoHelperAddon_OnPowerUpdate)
			EM:AddFilterForEvent(powerTypeEventStr, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, powerType, REGISTER_FILTER_UNIT_TAG, CON_PLAYER)
		end
	end
	]]

	addonVars.gAddonLoaded = true
end

-- Register the event "addon loaded" for this addon
local function FCOPUH_Initialized()
	EM:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, FCOPsijicUndoHelperAddon_Loaded)
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOPUH_Initialized()

