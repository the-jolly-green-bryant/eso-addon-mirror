FCOUltimateReminder = {}
local FCOUR = FCOUltimateReminder
FCOUR.addonVars =  {}
local addonVars = FCOUR.addonVars
addonVars.addonRealVersion		= 1.1
addonVars.addonSavedVarsVersion	= 0.2
addonVars.addonName				= "FCOUltimateReminder"
addonVars.addonSavedVars		= "FCOUltimateReminder_Settings"
addonVars.settingsName   		= "FCO Ultimate Reminder"
addonVars.settingsDisplayName   = "|c00FF00FCO |cFFFF00 Ultimate Reminder|r"
addonVars.addonAuthor			= "Baertram"
addonVars.addonWebsite			= "http://www.esoui.com/downloads/info1628-FCOUltimateReminder.html"
addonVars.addonFeedback			= "https://www.esoui.com/portal.php?&uid=2028"
addonVars.addonDonate			= "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
addonVars.addonWebsiteFCOUltimateSound = "http://www.esoui.com/downloads/info979-FCOUltimateSound.html"
local addonName = addonVars.addonName

local updateUltimateData, checkIfUltimateAbilityIsReady


--[[
    Known bugs:
    2022-05-10, Baertram, Ultimate icon at the active weapon pair (not changed during fight) was greyed out as it was <100%
                and as it reaches 100% it stays greyed out until a weapon pair change was done
]]


local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER

local CON_PLAYER = "player"

local ultimateIndex = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

local activeWeaponPairToHotbarCategory = {
    [ACTIVE_WEAPON_PAIR_MAIN] =     HOTBAR_CATEGORY_PRIMARY,
    [ACTIVE_WEAPON_PAIR_BACKUP] =   HOTBAR_CATEGORY_BACKUP,
}
local g_activeHotbar = HOTBAR_CATEGORY_PRIMARY

FCOUR.alertText				= ""
FCOUR.inCombat				= false
FCOUR.alertIconIsBlinking	    = false

--The Ultimate abilities at the 2 ability bars
FCOUR.ultimateReady = {}
FCOUR.ultimateReady[ACTIVE_WEAPON_PAIR_MAIN] = false
FCOUR.ultimateReady[ACTIVE_WEAPON_PAIR_BACKUP] = false
FCOUR.ultiVars = {}
FCOUR.ultiVars.costs = 0
FCOUR.ultiVars.value = 0
--Fallback texture for the ultimate skill
FCOUR.falllbackUltimateTexture  = "EsoUI/Art/ActionBar/abilityInset.dds"
FCOUR.ultimateDecorationTexture = "EsoUI/Art/ActionBar/ability_ultimate_frameDecoBG.dds"
FCOUR.ultimateReadyLoopTexture  = "EsoUI/Art/ActionBar/abilityhighlight_mage_med.dds"
FCOUR.ultimateEdgeTexture       = "EsoUI/Art/ActionBar/gp_QuickslotFill.dds" --8x8, 0 1 0 1
FCOUR.ultimateFrameTexture      = "EsoUI/Art/ActionBar/abilityFrame64_up.dds"

FCOUR.addonMenu = {}
FCOUR.addonMenu.isShown = false

FCOUR.preventerVars						= {}
FCOUR.preventerVars.KeyBindingTexts				= false
FCOUR.preventerVars.gLocalizationDone			= false
FCOUR.preventerVars.iconManuallyHidden			= false
FCOUR.preventerVars.weaponSwitched 				= false
FCOUR.preventerVars.activeWeaponBarAtAlertIconBlinkStart = ACTIVE_WEAPON_PAIR_NONE
FCOUR.preventerVars.changedBySettingsMenu 		= false
FCOUR.preventerVars.iconShownBeforeMenuOpened 	= false

FCOUR.numVars = {}
--Available languages
FCOUR.numVars.languageCount = 7 --English, German, French, Spanish, Italian, Japanese, Russian
FCOUR.langVars = {}
FCOUR.langVars.languages = {}
--Build the languages array
for i=1, FCOUR.numVars.languageCount do
	FCOUR.langVars.languages[i] = true
end
FCOUR.localizationVars				 	= {}
FCOUR.localizationVars.localizationAll  = {}

FCOUR.settingsVars					 	= {}
FCOUR.settingsVars.settings						 	= {}
FCOUR.settingsVars.defaultSettings				 	= {}

FCOUR.locVars							= {}
--Uncolored "FCOIS" pre chat text for the chat output
FCOUR.locVars.preChatText = "[" .. addonVars.settingsName .. "]"
local preChatText = FCOUR.locVars.preChatText
--Green colored "FCOUR" pre text for the chat output
FCOUR.locVars.preChatTextGreen = "|c22DD22"..preChatText.."|r "
--Red colored "FCOUR" pre text for the chat output
FCOUR.locVars.preChatTextRed = "|cDD2222"..preChatText.."|r "
--Blue colored "FCOUR" pre text for the chat output
FCOUR.locVars.preChatTextBlue = "|c2222DD"..preChatText.."|r "
--The active weapon bar
FCOUR.activeWeaponPair = 1


function FCOUR.createAlertIcons()
    local settings = FCOUR.settingsVars.settings
    --Ultimate alert icon button frame
    local buttonFrame = WINDOW_MANAGER:CreateControl(addonName .. "_AlertIconButtonFrame", FCOUltimateReminderContainer, CT_TEXTURE)
    FCOUR.alertIcon = buttonFrame
    buttonFrame:SetTexture(FCOUR.ultimateFrameTexture)
    buttonFrame:SetHidden(true)
    buttonFrame:SetMouseEnabled(true)
    buttonFrame:SetMovable(true)
    buttonFrame:SetDimensions(settings.iconAlertWidth + 1, settings.iconAlertHeight + 1)
    buttonFrame:ClearAnchors()
    buttonFrame:SetParent(FCOUltimateReminderContainer)
    buttonFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.iconAlertX, settings.iconAlertY)
    buttonFrame:SetDrawLayer(DL_CONTROLS)
    buttonFrame:SetDrawTier(DT_LOW)
    --Handlers
    buttonFrame:SetHandler("OnMouseUp", function(self, mouseButton, upInside)
        if not FCOUltimateReminder_SettingsMenu:IsHidden() then return false end
    	if mouseButton == MOUSE_BUTTON_INDEX_RIGHT and upInside then
            FCOUR.preventerVars.iconManuallyHidden = true
            FCOUR.alertIconIsBlinking = false
			FCOUR.preventerVars.iconShownBeforeMenuOpened = false
        	self:SetHidden(true)
		end
    end)
    buttonFrame:SetHandler("OnMouseEnter", function()
		--Build the tooltip text
		local tooltipText = ""
        if FCOUR.alertText ~= "" then
        	tooltipText = FCOUR.alertText
        end
        if tooltipText ~= nil and tooltipText ~= "" then
	        ZO_Tooltips_ShowTextTooltip(buttonFrame, BOTTOM, tooltipText)
        end
	end)
    buttonFrame:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
    buttonFrame:SetHandler("OnMoveStop", function()
		settings.iconAlertX = buttonFrame:GetLeft()
		settings.iconAlertY = buttonFrame:GetTop()
    end)

    --Ultimate alert icon
    local icon = WINDOW_MANAGER:CreateControl(addonName .. "_AlertIcon", buttonFrame, CT_TEXTURE)
    icon:SetHidden(false)
    icon:SetMouseEnabled(false)
    icon:SetMovable(false)
    icon:SetDimensions(settings.iconAlertWidth, settings.iconAlertHeight)
    icon:ClearAnchors()
    icon:SetParent(buttonFrame)
    icon:SetAnchor(TOPLEFT, buttonFrame, 1, 1)
    icon:SetDrawLayer(DL_OVERLAY)
    icon:SetDrawTier(DT_MEDIUM)
    icon.hideNow = false
    FCOUR.alertIcon.icon = icon

    --Get the actual ultimate ability values
    updateUltimateData = updateUltimateData or FCOUR.updateUltimateData
    updateUltimateData()
    -- Calculate the percentage to activation
    local pct = ( FCOUR.ultiVars.costs > 0 ) and math.max(zo_roundToNearest((FCOUR.ultiVars.value/FCOUR.ultiVars.costs),0.01),0) or 0
    --Ultimate alert icon's label for percentage
    local percentageLable = WINDOW_MANAGER:CreateControl(addonName .. "_AlertIconPercentageLabel", buttonFrame, CT_LABEL)
    percentageLable:SetHidden(false)
    percentageLable:SetMouseEnabled(false)
    percentageLable:SetMovable(false)
    percentageLable:SetDimensions(settings.iconAlertWidth, 30)
    percentageLable:SetColor(1, 1, 1, 1)
    percentageLable:SetFont("ZoFontGameBold")
    percentageLable:SetScale(1)
    percentageLable:SetWrapMode(TEX_MODE_CLAMP)
    percentageLable:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    percentageLable:ClearAnchors()
    percentageLable:SetParent(buttonFrame)
    percentageLable:SetAnchor(CENTER, buttonFrame, CENTER, 1, 1)
    percentageLable:SetDrawLayer(DL_OVERLAY)
    percentageLable:SetDrawTier(DT_HIGH)
    percentageLable:SetText(tostring(pct*100) .. "%")
    FCOUR.alertIcon.percentageLabel = percentageLable

    --Ultimate alert icon's label for value/costs
    local valueLable = WINDOW_MANAGER:CreateControl(addonName .. "_AlertIconValueLabel", buttonFrame, CT_LABEL)
    valueLable:SetHidden(false)
    valueLable:SetMouseEnabled(false)
    valueLable:SetMovable(false)
    local valueLabelWidth = settings.iconAlertWidth
    if valueLabelWidth <= 48 then valueLabelWidth = 60 end
    valueLable:SetDimensions(valueLabelWidth, 20)
    valueLable:SetColor(1, 1, 1, 1)
    valueLable:SetFont("ZoFontGameBold")
    valueLable:SetScale(0.9)
    valueLable:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    valueLable:ClearAnchors()
    valueLable:SetParent(buttonFrame)
    valueLable:SetAnchor(BOTTOM, buttonFrame, TOP, 0, -3)
    valueLable:SetDrawLayer(DL_OVERLAY)
    valueLable:SetDrawTier(DT_HIGH)
    valueLable:SetText(tostring(FCOUR.ultiVars.value) .. "/" .. tostring(FCOUR.ultiVars.costs))
    FCOUR.alertIcon.valueLabel = valueLable

    --Update the texture and dimensions etc.
    FCOUR.UpdateAlertIconValues(true)
    --Show/hide the value/percentage text labels at the icon
    FCOUR.UpdateAlertIconTextVisibility()
end

function FCOUR.getActiveWeaponBar()
    local activeWeaponBar = GetActiveWeaponPairInfo()
    if activeWeaponBar == ACTIVE_WEAPON_PAIR_MAIN or activeWeaponBar == ACTIVE_WEAPON_PAIR_BACKUP then
        -- update bar category
        g_activeHotbar = activeWeaponPairToHotbarCategory[activeWeaponBar] or GetActiveHotbarCategory()

        FCOUR.activeWeaponPair = activeWeaponBar
        return activeWeaponBar
    end
    return nil
end

function FCOUR.UpdateAlertIconTextVisibility()
    local settings = FCOUR.settingsVars.settings
    local showValue = settings.iconAlert and settings.iconAlertShowValue
    local showPercentage = settings.iconAlert and settings.iconAlertShowPercentage
    --Show/Hide the value text label
    FCOUR.alertIcon.valueLabel:SetHidden(not showValue)
    --Show/Hide the percentage text label
    FCOUR.alertIcon.percentageLabel:SetHidden(not showPercentage)
end

function FCOUR.UpdateAlertIconValues(doHide)
	if FCOUR.alertIcon == nil then return false end
    doHide = doHide or false
--[[
    * GetSlotTexture(index)
    ** _Returns:_ *string* _texture_
  ]]
    local settings = FCOUR.settingsVars.settings
    --Get the current ultimate slos index
    --Get the active ultimate ability info + texture
    local ultimateAlertTexture = GetSlotTexture(ultimateIndex, g_activeHotbar)
    if ultimateAlertTexture == nil or ultimateAlertTexture == "" then ultimateAlertTexture = FCOUR.falllbackUltimateTexture end
    local ultimateName = GetSlotName(ultimateIndex, g_activeHotbar)
    ultimateName = zo_strformat("<<C:1>>", ultimateName)
--d("Ultimate ability name: " .. tostring(ultimateName) .. ", Texture: " .. tostring(ultimateAlertTexture))
	if ultimateAlertTexture ~= nil then
        --Update the alert icon frame
        FCOUR.alertIcon:SetDimensions(settings.iconAlertWidth + 2, settings.iconAlertHeight + 2)
        FCOUR.alertIcon:ClearAnchors()
        FCOUR.alertIcon:SetParent(FCOUltimateReminderContainer)
        --Hide the alert icon container
        FCOUltimateReminderContainer:SetHidden(doHide)
        FCOUR.alertIcon:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.iconAlertX, settings.iconAlertY)
        FCOUR.alertIcon:SetDrawLayer(DL_CONTROLS)
        --Update the alert icon
        FCOUR.alertIcon.icon:SetTexture(ultimateAlertTexture)
        --FCOUltimateReminderContainer:SetDimensions(settings.iconAlertWidth, settings.iconAlertHeight)
        FCOUR.alertIcon.icon:SetDimensions(settings.iconAlertWidth, settings.iconAlertHeight)
        FCOUR.alertIcon.icon:ClearAnchors()
        FCOUR.alertIcon.icon:SetParent(FCOUR.alertIcon)
        FCOUR.alertIcon.icon:SetAnchor(TOPLEFT, FCOUR.alertIcon, TOPLEFT, 1, 1)
        FCOUR.alertIcon.icon:SetDrawLayer(DL_OVERLAY)
        FCOUR.alertIcon.icon:SetDesaturation(0)
        --Check if the ultimate ability is ready
        checkIfUltimateAbilityIsReady = checkIfUltimateAbilityIsReady or FCOUR.checkIfUltimateAbilityIsReady
        local ultiReady = checkIfUltimateAbilityIsReady()
        --if it's not ready colorize the texture black/grayed out
        if not ultiReady then
            FCOUR.alertIcon.icon:SetDesaturation(1)
        end
    end
end
local updateAlertIconValues = FCOUR.UpdateAlertIconValues

--Fires each time a skill is slotted or all the action slots are updated
function FCOUR.Update_Ulti_Costs(cost)
    if FCOUR.getActiveWeaponBar() == nil then return false end
--d("Update ulti costs - g_activeHotbar: " ..tostring(g_activeHotbar) .. ", ultimateIndex: " ..tostring(ultimateIndex))
    local isSlotUsed = IsSlotUsed(ultimateIndex, g_activeHotbar)
    --Cost of actual ultimate skill
    if isSlotUsed then
        if cost ~= nil then
            FCOUR.ultiVars.costs = cost
        else
            local ultiCosts, ultiMechanic
            if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
                ultiCosts, ultiMechanic = GetSlotAbilityCost(ultimateIndex, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_activeHotbar)
--d(">1")
            else
                ultiCosts, ultiMechanic = GetSlotAbilityCost(ultimateIndex, g_activeHotbar)
            end
--d("Ulti costs: " .. ultiCosts)
            if ultiCosts ~= nil and ultiCosts >= 0 then
                if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil or (COMBAT_MECHANIC_FLAGS_ULTIMATE == nil and ultiMechanic == POWERTYPE_ULTIMATE) then
                    FCOUR.ultiVars.costs = ultiCosts
                else
                    FCOUR.ultiVars.costs = 0
                end
            else
                FCOUR.ultiVars.costs = -1
            end
        end
    else
        FCOUR.ultiVars.costs = -1
    end
end

--Fires each time a skill is used etc.
function FCOUR.Update_Ulti_Value(value)
    if FCOUR.getActiveWeaponBar() == nil then return false end
--d("Update ulti value")
    local isSlotUsed = IsSlotUsed(ultimateIndex)
    if isSlotUsed then
        if value ~= nil then
            FCOUR.ultiVars.value = value
        else
            --Current ultimate value
            local ultiPower
            if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
                ultiPower = GetUnitPower(CON_PLAYER, COMBAT_MECHANIC_FLAGS_ULTIMATE)
            else
                ultiPower = GetUnitPower(CON_PLAYER, POWERTYPE_ULTIMATE)
            end

            --d("Ulti power: " .. ultiPower)
            if not ultiPower or ultiPower < 0 then
                ultiPower = -1
            end
            FCOUR.ultiVars.value = ultiPower
        end
    else
        FCOUR.ultiVars.value = -1
    end
end

function FCOUR.updateUltimateData(value, cost)
    --Update the actual ultimate's costs
    FCOUR.Update_Ulti_Costs(cost)
    --Update the actual ultimate's value
    FCOUR.Update_Ulti_Value(value)
end
updateUltimateData = FCOUR.updateUltimateData

function FCOUR.checkIfUltimateAbilityIsSlotted()
    --Check if the ultimate ability is slotted
    local slotType = GetSlotType(ultimateIndex, g_activeHotbar)
    return slotType == ACTION_TYPE_ABILITY
end
local checkIfUltimateAbilityIsSlotted = FCOUR.checkIfUltimateAbilityIsSlotted

function FCOUR.checkIfUltimateAbilityIsReady()
    --Get fresh ultimate data
    updateUltimateData()
	--Is the ultimate ability ready?
	local ultiVars = FCOUR.ultiVars
--d("[FCOUR]checkIfUltimateAbilityIsReady - value: " ..tostring(ultiVars.value) .. ", costs: " ..tostring(ultiVars.costs))
    if ultiVars.value > 0 and ultiVars.costs >= 0 then
		--Ultimate current value is lower then the costs?
		if ultiVars.value < ultiVars.costs then return false end
		return true
	end
	return false
end
checkIfUltimateAbilityIsReady = FCOUR.checkIfUltimateAbilityIsReady

function FCOUR.updateUltimateDataFromEvent(powerValue, powerMax, powerEffectiveMax)
    -- Get the currently slotted ultimate cost
    local cost, mechType
    if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
        cost = GetSlotAbilityCost(ultimateIndex, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_activeHotbar)
    else
        cost, mechType = GetSlotAbilityCost(ultimateIndex, g_activeHotbar)
    end
    -- Update the value/cost label
    if FCOUR.alertIcon.valueLabel then FCOUR.alertIcon.valueLabel:SetText( tostring(powerValue) .. "/" .. tostring(cost)) end
    -- Update the percentage label
    if FCOUR.alertIcon.percentageLabel then
        -- Calculate the percentage to activation
        local pct = ( cost > 0 ) and math.max(zo_roundToNearest((powerValue / cost), 0.01), 0) or 0
        FCOUR.alertIcon.percentageLabel:SetText(tostring(pct * 100) .. "%")
    end
    --Update the addon values
    updateUltimateData(powerValue, cost)
end
local updateUltimateDataFromEvent = FCOUR.updateUltimateDataFromEvent

function FCOUR.ShowTextAlert()
    --Get fresh ultimate data
    updateUltimateData()
    local textAlertMsg = FCOUR.settingsVars.settings.textAlertUltimateReady
    d(textAlertMsg .. "\n\n>>Value: " .. tostring(FCOUR.ultiVars.value)  .. " / costs: " .. tostring(FCOUR.ultiVars.costs))
end

function FCOUR.checkIfAlertIconBlinkShouldBeAborted(test)
    test = test or false
--d("[FCOUR.checkIfAlertIconBlinkShouldBeAborted] test: " ..tostring(test))
    if FCOUR.preventerVars.iconManuallyHidden then
        --d(">manually hidden!")
        FCOUR.preventerVars.iconManuallyHidden = false
        FCOUR.alertIconIsBlinking = false
        return true
    end
    --Get the active weapon bar number
    local activeWeaponBar = FCOUR.getActiveWeaponBar()
    if activeWeaponBar == nil then return false end
    local settings = FCOUR.settingsVars.settings
    --The active weapon bar was switched during the alert icon blinking -> Recheck the ultimate skill etc.
    --Or is the now current weapon bar not allowed to show the ultimate skill?
    local visibleOnWeaponBars = tonumber(settings.visibleOnWeaponBars)
    local activeWeaponBarShouldNotShowUlti = (visibleOnWeaponBars ~= 3 and visibleOnWeaponBars ~= tonumber(activeWeaponBar)) or false
    if FCOUR.preventerVars.activeWeaponBarAtAlertIconBlinkStart ~= activeWeaponBar or activeWeaponBarShouldNotShowUlti then
--d("> Weapon bar switched, not allowed to show ultimate: " .. tostring(activeWeaponBarShouldNotShowUlti) .. " -> Stop blinking")
        FCOUR.alertIconIsBlinking = false
        FCOUR.preventerVars.iconManuallyHidden = false
        return true
    end
    --[[
    --Is the ultimate ability not ready and it's no test?
    if not test and not FCOUR.checkIfUltimateAbilityIsReady() then
        FCOUR.alertIconIsBlinking = false
        FCOUR.preventerVars.iconManuallyHidden = false
        return true
    end
    ]]
    --d("<<< return false")
    return false
end

function FCOUR.ToggleAlertIcon(override, blink, test)
    if FCOUR.alertIcon == nil then return false end
    local settings = FCOUR.settingsVars.settings
    blink = blink or false
    local ultiReady = checkIfUltimateAbilityIsReady()
    if not ultiReady and blink then blink = false end
    test = test or false

--d("[FCOUR.ToggleAlertIcon] override: " .. tostring(override) .. ", blink: " .. tostring(blink) .. ", ultiReady: " .. tostring(ultiReady) .. ", test: " .. tostring(test))

    if not settings.iconAlert or (override ~= nil and override == false)
        or (override ~= nil and override == false and FCOUltimateReminder_SettingsMenu:IsHidden() and not LAMAddonSettingsWindow:IsHidden()) then
        if override == nil and FCOUR.preventerVars.changedBySettingsMenu then
            FCOUR.preventerVars.iconShownBeforeMenuOpened = false
        end
        if not FCOUR.alertIcon:IsHidden() or FCOUR.alertIconIsBlinking then
            FCOUR.preventerVars.iconManuallyHidden = false
            --Only hide the icon if not in the settings menu, or if settings menu changed the value on purpose
            if not FCOUltimateReminder_SettingsMenu:IsHidden() and not FCOUR.preventerVars.changedBySettingsMenu then
                return false
            end
            --Is the FCOUltimateReminderSettingsMenu hidden but another LAM addon settings panel is shown?
            FCOUltimateReminderContainer:SetHidden(true)
            FCOUR.alertIcon:SetHidden(true)
            FCOUR.alertIconIsBlinking = false
        end

    elseif settings.iconAlert or (override ~= nil and override) then
        if FCOUR.alertIcon:IsHidden() or blink or test then
--d(">alert icon: Prepare to show")
            --Get ultimate values internally
            updateAlertIconValues(false)
            local ultiVars = FCOUR.ultiVars
            if ultiVars.value ~= -1 and ultiVars.costs ~= -1 then
                --Check if the ultimate values are updted and write them to the icon now
                updateUltimateDataFromEvent(ultiVars.value, nil, nil)
            end
            --Was the icon shown before the menu was open?
            if FCOUltimateReminder_SettingsMenu:IsHidden() then
                FCOUR.preventerVars.iconShownBeforeMenuOpened = true
            end
            --Reset the manual alert icon hidden variable
            FCOUR.preventerVars.iconManuallyHidden = false
            --Should the icon blink 3 times?
            --During each blink check if the ultimate ability is not used or the weapon bars are swapped, and stop the blinking!
            if blink then
--d(">>>> Start blinking, weapon bar: " .. FCOUR.getActiveWeaponBar())
                FCOUR.alertIconIsBlinking = true
                FCOUR.preventerVars.activeWeaponBarAtAlertIconBlinkStart = FCOUR.getActiveWeaponBar()
                if FCOUR.checkIfAlertIconBlinkShouldBeAborted(test) then return false end
                if not FCOUR.alertIconIsBlinking then return false end
--d(">blink: show 1")
                FCOUR.alertIcon:SetHidden(false)
                zo_callLater(function()
                    if not FCOUR.alertIconIsBlinking then return false end
--d(">blink: hier 1")
                    FCOUR.alertIcon:SetHidden(true)
                    --Check if blink should be aborted
                    if FCOUR.checkIfAlertIconBlinkShouldBeAborted(test) then return false end
                    zo_callLater(function()
                        if not FCOUR.alertIconIsBlinking then return false end
--d(">blink: show 2")
                        FCOUR.alertIcon:SetHidden(false)
                        zo_callLater(function()
                            if not FCOUR.alertIconIsBlinking then return false end
--d(">blink: hide 2")
                            FCOUR.alertIcon:SetHidden(true)
                            --Check if blink should be aborted
                            if FCOUR.checkIfAlertIconBlinkShouldBeAborted(test) then return false end
                            zo_callLater(function()
                                if not FCOUR.alertIconIsBlinking then return false end
                                --Check if blink should be aborted
                                if FCOUR.checkIfAlertIconBlinkShouldBeAborted(test) then return false end
--d(">blink: show 3")
                                FCOUR.alertIcon:SetHidden(false)
                                FCOUR.alertIconIsBlinking = false
                                if FCOUR.checkIfAlertIconBlinkShouldBeAborted(test) then return false end
                                zo_callLater(function() if FCOUR.checkIfAlertIconBlinkShouldBeAborted(test) then return false end end, 1000)
                            end, 650)
                        end, 650)
                    end, 650)
                end, 650)
            else
--d(">>>> Show alert icon now")
                FCOUR.alertIcon:SetHidden(false)
                FCOUR.alertIconIsBlinking = false
                FCOUR.preventerVars.iconManuallyHidden = false
            end
        end
    end
end
local toggleAlertIcon = FCOUR.ToggleAlertIcon

function FCOUR.alertNow(chatOutput, test)
    test = test or false
    chatOutput = chatOutput or false
    local settings = FCOUR.settingsVars.settings
    local ultiIsReady = checkIfUltimateAbilityIsReady()
    local ultiNotSlotted = not checkIfUltimateAbilityIsSlotted()

--d("[FCOUR.alertNow] chatOutput: " .. tostring(chatOutput) .. ", test: " .. tostring(test) .. ", ultiNotSlotted: " .. tostring(ultiNotSlotted) .. ", ultiIsReady: " .. tostring(ultiIsReady))
    --Text alert
    local showTextAlert = settings.textAlert
    local textAlert = ""
    if ultiIsReady then
        textAlert = settings.textAlertUltimateReady
    else
        textAlert = FCOUR.localizationVars.fco_ur_loc["icon_tooltip_text_not_ready"]
    end
    local textAlertWithPreText = textAlert
    if textAlert ~= "" then
        textAlertWithPreText =  FCOUR.locVars.preChatTextRed .. textAlert
    end
    --Update the tooltip variable with the current text
    FCOUR.alertText = textAlertWithPreText
    if showTextAlert and ((not ultiNotSlotted and ultiIsReady) or test) then
        --Is the ultimate ability ready?
        if ultiIsReady or test then
            if test then
                textAlert = "---TEST--- " .. textAlert
            end
            --CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_BROADCAST, CSA_EVENT_SMALL_TEXT, nil, textAlert)
            local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
            params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT )
            params:SetText(textAlert)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
        end
    end
    --Icon alert
    if settings.iconAlert then
        --Show/hide the value/percentage text labels at the icon
        FCOUR.UpdateAlertIconTextVisibility()
        --Blink the ulti icon now? Or only show it? (Enabled in the settings & and ultimate is slotted?)
        local blinkIcon = settings.iconAlertBlink and not ultiNotSlotted
        toggleAlertIcon(nil, blinkIcon, test)
    end
    --Chat output?
    if chatOutput and (not ultiNotSlotted or test) then
        local chatOutputText = textAlertWithPreText or settings.textAlertUltimateReady
        if chatOutputText and chatOutputText ~= "" then
            d(chatOutputText)
        end
    end
end
local alertNow = FCOUR.alertNow

function FCOUR.checkIfUltimateAlertShouldBeShown()
--d("checkIfUltimateAlertShouldBeShown - blinking: " .. tostring(FCOUR.alertIconIsBlinking))
	--Do not check if the ultimate icon ic currently blinking
    --A new check will be initiated after the blinking
    if FCOUR.alertIconIsBlinking then return false end

    local settings = FCOUR.settingsVars.settings
    local function hideAlertIconNow()
        toggleAlertIcon(false, false, false)
        return false
    end

    --LAM settings menu of FCOUR is hidden but LAM settings menu of others is still visible? Then hide the icon!
    if FCOUltimateReminder_SettingsMenu:IsHidden() and not LAMAddonSettingsWindow:IsHidden() then
        --Hide the alert icon now
        return hideAlertIconNow()
    end

    --Only show alerts in combat? Check combat state
	if settings.alertOnlyInCombat and not FCOUR.inCombat then
--d("[FCOUR]checkIfUltimateAlertShouldBeShown - not in combat but need to -> abort")
        --Hide the alert icon now
        return hideAlertIconNow()
    end
    --Icon should be only shown on a special weapon bar?
--d(">activeWeaponPair: " .. tostring(FCOUR.activeWeaponPair) .. ", settings show on weapon pair: " ..tostring(settings.visibleOnWeaponBars))
    if settings.iconAlert and tonumber(settings.visibleOnWeaponBars) ~= 3 and tonumber(settings.visibleOnWeaponBars) ~= tonumber(FCOUR.activeWeaponPair) then
--d("<<<weapon bar not matching")
        --Hide the alert icon now
        return hideAlertIconNow()
    end
    --Ulti is ready and slotted to action slot?
    local ultiIsReady = checkIfUltimateAbilityIsReady()
    local ultiNotSlotted = not checkIfUltimateAbilityIsSlotted()
    --Icon should be only shown if ultimate is at value to execute?
--d(">ultiIsReady: " .. tostring(ultiIsReady) .. ", ultiNotSlotted: " ..tostring(ultiNotSlotted) .. ", settings only visible if full: " ..tostring(settings.onlyVisibleIfUltimateFull))
    if settings.iconAlert and settings.onlyVisibleIfUltimateFull then
        if not ultiIsReady or ultiNotSlotted then
--d("<<<ulti not ready")
            --Hide the alert icon now
            return hideAlertIconNow()
        end
    end
    --Alert text should be shown? And/Or alert icon should be shown
    if settings.textAlert or settings.iconAlert then
--d(">Show text/icon alert now")
        --and (ultiIsReady or ultiNotSlotted)) then
        alertNow(settings.alertChatOutput, false)
    end
end
local checkIfUltimateAlertShouldBeShown = FCOUR.checkIfUltimateAlertShouldBeShown

function FCOUR.buildAddonMenu()
    local FCOURsettings = FCOUR.settingsVars.settings
    local FCOURdefaultSettings = FCOUR.settingsVars.defaults
    local FCOURglobalDefaultSettings = FCOUR.settingsVars.defaultSettings
    local FCOURaddonVars = addonVars
    local locVars = FCOUR.localizationVars.fco_ur_loc

    FCOUR.panelData    = {
        type                = "panel",
        name                = FCOURaddonVars.settingsName,
        displayName         = FCOURaddonVars.settingsDisplayName,
        author              = FCOURaddonVars.addonAuthor,
        version             = tostring(FCOURaddonVars.addonRealVersion),
        registerForRefresh  = true,
        registerForDefaults = true,
        slashCommand 		= "/fcours",
        website             = FCOURaddonVars.addonWebsite,
        feedback            = FCOURaddonVars.addonFeedback,
        donation            = FCOURaddonVars.addonDonate,
    }

-- !!! RU Patch Section START
--  Add english language description behind language descriptions in other languages
	local function nvl(val) if val == nil then return "..." end return val end
	local LV_Cur = locVars
	local LV_Eng = FCOUR.localizationVars.localizationAll[1]
	local languageOptions = {}
	for i=1, FCOUR.numVars.languageCount do
		local s="options_language_dropdown_selection"..i
		if LV_Cur==LV_Eng then
			languageOptions[i] = nvl(LV_Cur[s])
		else
			languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
		end
	end
-- !!! RU Patch Section END

    local savedVariablesOptions = {
    	[1] = locVars["options_savedVariables_dropdown_selection1"],
        [2] = locVars["options_savedVariables_dropdown_selection2"],
    }

    --The options panel data for the LAM settings of this addon
  	FCOUR.optionsData  = {
		{
			type              = "description",
			text              = locVars["options_description"],
		},

--==============================================================================
		{
        	type = 'header',
        	name = locVars["options_header1"],
        },
		{
			type = 'dropdown',
			name = locVars["options_language"],
			tooltip = locVars["options_language_tooltip"],
			choices = languageOptions,
            getFunc = function() return languageOptions[FCOURglobalDefaultSettings.language] end,
            setFunc = function(value)
                for i,v in pairs(languageOptions) do
                    if v == value then
                    	FCOURglobalDefaultSettings.language = i
                        --Tell the settings that you have manually chosen the language and want to keep it
                        --Read in function Localization() after ReloadUI()
                        FCOURsettings.languageChoosen = true
                        ReloadUI()
                    end
                end
            end,
	        disabled = function() return FCOURsettings.alwaysUseClientLanguage end,
            warning = locVars["options_language_description1"],
		},
		{
			type = "checkbox",
			name = locVars["options_language_use_client"],
			tooltip = locVars["options_language_use_client_tooltip"],
			getFunc = function() return FCOURsettings.alwaysUseClientLanguage end,
			setFunc = function(value)
					  FCOURsettings.alwaysUseClientLanguage = value
                      ReloadUI()
		            end,
            default = FCOURdefaultSettings.alwaysUseClientLanguage,
            warning = locVars["options_language_description1"],
		},
		{
			type = 'dropdown',
			name = locVars["options_savedvariables"],
			tooltip = locVars["options_savedvariables_tooltip"],
			choices = savedVariablesOptions,
            getFunc = function() return savedVariablesOptions[FCOURglobalDefaultSettings.saveMode] end,
            setFunc = function(value)
                for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        FCOURglobalDefaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
            end,
            warning = locVars["options_language_description1"],
		},
        {
        	type = 'description',
        	text = locVars["options_language_description1"],
        },
--==============================================================================
		{
			type = "button",
			name = locVars["options_alert_test"],
			tooltip = locVars["options_alert_test_tooltip"],
			func = function()
                alertNow(FCOURsettings.alertChatOutput, true)
            end,
			width = "full",
            disabled = function() return not FCOURsettings.textAlert and not FCOURsettings.iconAlert end,
		},

--==============================================================================
		{
			type = "checkbox",
			name = locVars["options_alert_only_in_combat"],
			tooltip = locVars["options_alert_only_in_combat_tooltip"],
			getFunc = function() return FCOURsettings.alertOnlyInCombat end,
			setFunc = function(value)
				FCOURsettings.alertOnlyInCombat = value
			end,
			default = FCOURdefaultSettings.alertOnlyInCombat,
		},
        {
            type = "checkbox",
            name = locVars["options_alert_chat_output"],
            tooltip = locVars["options_alert_chat_output_tooltip"],
            getFunc = function() return FCOURsettings.alertChatOutput end,
            setFunc = function(value)
                FCOURsettings.alertChatOutput = value
            end,
            disabled = function() return not FCOURsettings.textAlert and not FCOURsettings.iconAlert end,
            default = FCOURdefaultSettings.alertChatOutput,
        },
		{
			type = "submenu",
			name = locVars["options_header_text_alert"],
			controls = {
						    {
						      type              = "checkbox",
						      name              = locVars["options_text_alert_enabled"],
						      tooltip           = locVars["options_text_alert_enabled_tooltip"],
						      getFunc           = function() return FCOURsettings.textAlert end,
						      setFunc           = function(value) FCOURsettings.textAlert = value end,
						      default           = FCOURsettings.textAlert
						    },

						    {
						      type              = "editbox",
						      name              = locVars["options_text_alert_ultimate_ability_text"],
						      tooltip           = locVars["options_text_alert_ultimate_ability_text_tooltip"],
						      getFunc           = function() return FCOURsettings.textAlertUltimateReady end,
						      setFunc           = function(textVar)
						      						FCOURsettings.textAlertUltimateReady = textVar
						                            FCOUR.alertTextUltimateReady = ""
						                          end,
						      disabled          = function() return not FCOURsettings.textAlert end,
						      default           = FCOURsettings.textAlertUltimateReady
						    },


                        }, -- controls submenu alert text
		},  -- submenu alert text
		{
			type = "submenu",
			name = locVars["options_header_icon_alert"],
			controls = {
							--Alert icon for Ultimate abilities
						    {
						      type              = "checkbox",
						      name              = locVars["options_icon_alert_enabled"],
						      tooltip           = locVars["options_icon_alert_enabled_tooltip"],
						      getFunc           = function() return FCOURsettings.iconAlert end,
						      setFunc           = function(value)
						      					  	FCOURsettings.iconAlert = value
                                                    FCOUR.preventerVars.changedBySettingsMenu = true
                                                    toggleAlertIcon(nil, false, false)
                                                    FCOUR.preventerVars.changedBySettingsMenu = false
						                          end,
						      default           = FCOURsettings.iconAlert
						    },
                            {
                                type = "checkbox",
                                name = locVars["options_icon_alert_blink"],
                                tooltip = locVars["options_icon_alert_blink_tooltip"],
                                getFunc = function() return FCOURsettings.iconAlertBlink end,
                                setFunc = function(value)
                                    FCOURsettings.iconAlertBlink = value
                                end,
                                default = FCOURdefaultSettings.iconAlertBlink,
                                disabled = function() return not FCOURsettings.iconAlert end,
                            },
                            {
                                type = "checkbox",
                                name = locVars["options_icon_alert_show_value"],
                                tooltip = locVars["options_icon_alert_show_value_tooltip"],
                                getFunc = function() return FCOURsettings.iconAlertShowValue end,
                                setFunc = function(value)
                                    FCOURsettings.iconAlertShowValue = value
                                    --Show/hide the value/percentage text labels at the icon
                                    FCOUR.UpdateAlertIconTextVisibility()
                                end,
                                default = FCOURdefaultSettings.iconAlertShowValue,
                                disabled = function() return not FCOURsettings.iconAlert end,
                            },
                            {
                                type = "checkbox",
                                name = locVars["options_icon_alert_show_percentage"],
                                tooltip = locVars["options_icon_alert_show_percentage_tooltip"],
                                getFunc = function() return FCOURsettings.iconAlertShowPercentage end,
                                setFunc = function(value)
                                    FCOURsettings.iconAlertShowPercentage = value
                                    --Show/hide the value/percentage text labels at the icon
                                    FCOUR.UpdateAlertIconTextVisibility()
                                end,
                                default = FCOURdefaultSettings.iconAlertShowPercentage,
                                disabled = function() return not FCOURsettings.iconAlert end,
                            },
                            {
                                type = "checkbox",
                                name = locVars["options_visible_with_ultimate_full"],
                                tooltip = locVars["options_visible_with_ultimate_full_tooltip"],
                                getFunc = function() return FCOURsettings.onlyVisibleIfUltimateFull end,
                                setFunc = function(value)
                                    FCOURsettings.onlyVisibleIfUltimateFull = value
                                end,
                                disabled = function() return not FCOURsettings.iconAlert end,
                                default = FCOURdefaultSettings.onlyVisibleIfUltimateFull,
                            },
                            {
                                type = "slider",
                                min = 1,
                                max = 3,
                                step = 1,
                                name = locVars["options_visible_on_weapon_bar"],
                                tooltip = locVars["options_visible_on_weapon_bar_tooltip"],
                                getFunc = function() return FCOURsettings.visibleOnWeaponBars end,
                                setFunc = function(value)
                                    FCOURsettings.visibleOnWeaponBars = value
                                end,
                                disabled = function() return not FCOURsettings.iconAlert end,
                                default = FCOURdefaultSettings.visibleOnWeaponBars,
                            },
					 		{
								type = "slider",
								name = locVars["options_icon_alert_width"],
								tooltip = locVars["options_icon_alert_width_tooltip"],
								min = 8,
								max = 500,
								getFunc = function() return FCOURsettings.iconAlertWidth end,
								setFunc = function(width)
										FCOURsettings.iconAlertWidth = width
                                        updateAlertIconValues()
					 				end,
					            width="half",
								default = FCOURdefaultSettings.iconAlertWidth,
					            disabled = function() return not FCOURsettings.iconAlert end,
							},

					 		{
								type = "slider",
								name = locVars["options_icon_alert_height"],
								tooltip = locVars["options_icon_alert_height_tooltip"],
								min = 8,
								max = 500,
								getFunc = function() return FCOURsettings.iconAlertHeight end,
								setFunc = function(height)
										FCOURsettings.iconAlertHeight = height
                                        updateAlertIconValues()
					 				end,
					            width="half",
								default = FCOURdefaultSettings.iconAlertHeight,
					            disabled = function() return not FCOURsettings.iconAlert end,
							},

					 		{
								type = "slider",
								name = locVars["options_icon_alert_position_x"],
								tooltip = locVars["options_icon_alert_position_x_tooltip"],
								min = 0,
								max = 3600,
								getFunc = function() return FCOURsettings.iconAlertX end,
								setFunc = function(x)
										FCOURsettings.iconAlertX = x
                                        updateAlertIconValues()
					 				end,
					            width="half",
								default = FCOURdefaultSettings.iconAlertX,
					            disabled = function() return not FCOURsettings.iconAlert end,
							},

					 		{
								type = "slider",
								name = locVars["options_icon_alert_position_y"],
								tooltip = locVars["options_icon_alert_position_y_tooltip"],
								min = 0,
								max = 2400,
								getFunc = function() return FCOURsettings.iconAlertY end,
								setFunc = function(y)
										FCOURsettings.iconAlertY = y
                                        updateAlertIconValues()
					 				end,
					            width="half",
								default = FCOURdefaultSettings.iconAlertY,
					            disabled = function() return not FCOURsettings.iconAlert end,
							},

                        }, -- controls submenu alert icon
		},  -- submenu alert icon

		{
			type = "submenu",
			name = locVars["options_header_sound_alert"],
			controls = {

                --Button to show addon FCOUltimateSound or show where to download it
                {
                    type = "button",
                    name = locVars["options_alert_sound"],
                    tooltip = locVars["options_alert_sound_tooltip"],
                    func = function()
                        if FCOUS and FCOUS.LAMsettingsPanel then
                            --Open the FCOUltimateSound LAM panel
                            FCOUR.addonMenu:OpenToPanel(FCOUS.LAMsettingsPanel)
                        else
                            --Show weblink for FCOUltimateSound in a popup
                            local FCOUSwebsite = FCOURaddonVars.addonWebsiteFCOUltimateSound
                            if FCOUSwebsite and FCOUSwebsite ~= "" then
                                RequestOpenUnsafeURL(FCOUSwebsite)
                            end
                        end
                    end,
                    width = "full",
                    disabled = function() return false end,
                },

			}, --controls sound
        }, --submenu sound
  }
  FCOUR.addonMenuPanel = FCOUR.addonMenu:RegisterAddonPanel(addonName .. "_SettingsMenu", FCOUR.panelData)
  FCOUR.addonMenu:RegisterOptionControls(addonName .. "_SettingsMenu", FCOUR.optionsData)
  --Show the alert icon and potion alert icon
  local function FCUR_LAM_Opened(panel)
      if panel ~= FCOUR.addonMenuPanel then return end
      --d("FCOUltimateReminder_SettingsMenu LAM OnEffectivelyShown")
      toggleAlertIcon(true, false, false)
  end
  --Hide the alert icon and potion alert icon
    local function FCUR_LAM_Closed(panel)
        if panel ~= FCOUR.addonMenuPanel then return end
        --d("FCOUltimateReminder_SettingsMenu LAM OnEffectivelyHidden")
        toggleAlertIcon(false, false, false)
        --Check delayed after the FCOUltimateReminder settings panel was closed and the new panel was updated
        -- if the ultimate ready icon should be shown again
        checkIfUltimateAlertShouldBeShown()
    end

    CM:RegisterCallback("LAM-PanelOpened", FCUR_LAM_Opened)
    CM:RegisterCallback("LAM-PanelClosed", FCUR_LAM_Closed)



    FCOUR.preventerVars.addonMenuBuild = true
end

function FCOUR.ActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)

    -- update bar category
    g_activeHotbar = activeWeaponPairToHotbarCategory[activeWeaponPair] or GetActiveHotbarCategory()

    --d("ActiveWeaponPairChanged, locked: " .. tostring(locked))
    FCOUR.activeWeaponPair = activeWeaponPair
	if locked then
        FCOUR.preventerVars.weaponSwitched = true
        --If the ultimate icon is currently blinking and the weapon bar was changed:
        --Stop the blinking and show the icon
        if FCOUR.alertIconIsBlinking then
--d(">Switched weapon during alert icon blink!")
            FCOUR.alertIconIsBlinking = false
            FCOUR.preventerVars.iconManuallyHidden = false
            --Check if alert icon should be shown again, below in the zoCalllater function (a bit delayed)
        end
--d(">Hiding the alert icon")
        --Hide the alert icon now
        toggleAlertIcon(false, false, false)

        --Call this function a bit later to read the correct ultimate skill, and not the one from the prior list
        zo_callLater(function()
--d(">> ActiveWeaponPairChanged: called later")
            --Update the ultimate texture etc.
            updateAlertIconValues(true)
            --Show the text alert and/or the icon alert now?
            checkIfUltimateAlertShouldBeShown()
        end, 50)
    else
      	FCOUR.preventerVars.weaponSwitched = false
	end
end
local activeWeaponPairChanged = FCOUR.ActiveWeaponPairChanged

function FCOUR.OnPlayerCombatState(event, insideCombat)
--d("[FCOUR] OnPlayerCombatState - insideCombat: " ..tostring(insideCombat))
	--Save the inCombat state
    FCOUR.inCombat = insideCombat
    --Show the text alert and/or the icon alert now?
    checkIfUltimateAlertShouldBeShown()
    --Only show ultimate in combat and we are leaving the combat? Hide the alert icon again
    local settings = FCOUR.settingsVars.settings
    if not insideCombat and settings.alertOnlyInCombat then
        toggleAlertIcon(false, false, false)
    end
end
local onPlayerCombatState = FCOUR.OnPlayerCombatState

--function EVENT_POWER_UPDATE (eventId, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax) end
--[[
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType [CombatMechanicFlags|#CombatMechanicFlags]
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
--- @return void
]]
function FCOUR.OnPowerUpdate( eventCode , unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax )
    -- Player power updates?
    --if unitTag == CON_PLAYER then --Filtered via event filter already
    --Ultimate values updated?
    if (COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE)
            or (COMBAT_MECHANIC_FLAGS_ULTIMATE == nil and powerType == POWERTYPE_ULTIMATE) then
        -- Ultimate slotted?
        --if not checkIfUltimateAbilityIsSlotted() then return end
        updateUltimateDataFromEvent( powerValue , powerMax , powerEffectiveMax )
        checkIfUltimateAlertShouldBeShown()
    end
    --end
end
local onPowerUpdate = FCOUR.OnPowerUpdate

function FCOUR.OnActionSlotUsed(eventCode, slotNum)
	--Is the slot number the last one = Ultimate skill?
    if slotNum == ultimateIndex then   --ACTION_BAR_UTILITY_BAR_SIZE then
		--get the ability ID
	    --local abiltyId = GetSlotBoundId(slotNum, g_activeHotbar)
		--Check if ability ID is on the blacklist
        --local excludedUltimates = FCOUR.buffAbilityIds.ultimatesExcluded
		--local isNotWantedUltimate = excludedUltimates[abiltyId] or false
		--Show ability ID and name, if debug mode is activated
        --if FCOUR.debug then
		--    local abilityName = GetAbilityName(abiltyId)
		--	d("Ability name: " .. abilityName .. ", ID: " .. abiltyId .. ", onBlacklist: " .. tostring(isNotWantedUltimate))
        --end
        --Update the ultimate values and show them at the icon
        updateAlertIconValues(true)
        --Show the text alert and/or the icon alert now?
        checkIfUltimateAlertShouldBeShown()
	end
end
local onActionSlotUsed = FCOUR.OnActionSlotUsed

--Check for other addons
--function FCOUR.checkForOtherAddons()
--end

function FCOUR.Player_Activated(...)
    FCOUR.activeWeaponPair = FCOUR.getActiveWeaponBar()
    --Player activated event fired - Check if the alert text/icon should be shown
    checkIfUltimateAlertShouldBeShown()
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
	--Debug mode
	if (options[1] ~= nil and (options[1] == "debug")) then
		FCOUR.debug = not FCOUR.debug
        d(FCOUR.locVars.preChatTextBlue .. FCOUR.localizationVars.fco_ur_loc["debugMode_"..tostring(FCOUR.debug)])
	end
end

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcoultimatereminder"]	= command_handler
	SLASH_COMMANDS["/fcour"]			    = command_handler
end

function FCOUR.addonLoaded(evetName, addonNameOfEachAddon)
	if addonNameOfEachAddon ~= addonName then return end
	EM:UnregisterForEvent(evetName)

    --LibAddonMenu-2.0
    FCOUR.addonMenu = LibAddonMenu2


    --The default values for the language and save mode
    local firstRunSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    FCOUR.settingsVars.defaults = {
		languageChosen			= false,
		alwaysUseClientLanguage = false,

        debug					= false,

        --Ultimate abilities
		alertOnlyInCombat			= true,
		textAlert				    = true,
        textAlertUltimateReady 		= "!!! Ultimate ability ready !!!",
        textAlertUltimateChanged    = false,

		iconAlert				= true,
        iconAlertShowPercentage = true,
        iconAlertShowValue      = true,
		iconAlertX				= 100,
		iconAlertY              = 100,
        iconAlertWidth			= 48,
        iconAlertHeight			= 48,
        iconAlertTexture		= 1,
        iconAlertBlink          = true,

        alertChatOutput         = false,
        onlyVisibleIfUltimateFull = false,
        visibleOnWeaponBars     = 3,
    }
    local defaults = FCOUR.settingsVars.defaults

    local worldName = GetWorldName()

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
	FCOUR.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, 999, "SettingsForAll", firstRunSettings, worldName)

	--Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
	if (FCOUR.settingsVars.defaultSettings.saveMode == 1) then
    	FCOUR.settingsVars.settings = ZO_SavedVars:New(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion , "Settings", defaults, worldName, nil, nil, nil, nil)
	else
		FCOUR.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, "Settings", defaults, worldName, nil)
	end
--=============================================================================================================

	--Deactivate debugging again
	FCOUR.debug = false

	-- Set Localization
	FCOUR.preventerVars.KeyBindingTexts = false
    FCOUR.Localization()

	--Build the addon menu once
	FCOUR.buildAddonMenu()

	--Register for the zone change/player ready event
	EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED,                              FCOUR.Player_Activated)
    --Register callback function if the weapon bars change
    EM:RegisterForEvent(addonName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED,                    activeWeaponPairChanged)
	--Register callback function if you get into combat
	EM:RegisterForEvent(addonName, EVENT_PLAYER_COMBAT_STATE,                           onPlayerCombatState)
	--Register callback function if you change the action slots
	EM:RegisterForEvent(addonName, EVENT_ACTION_SLOT_ABILITY_USED,                      onActionSlotUsed)
    --Register event for the power update
    EM:RegisterForEvent(addonName  .. "_EVENT_POWER_UPDATE_Ulti", EVENT_POWER_UPDATE,   onPowerUpdate)
    EM:AddFilterForEvent(addonName .. "_EVENT_POWER_UPDATE_Ulti", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, CON_PLAYER)

    --Create the alert icon control
	FCOUR.createAlertIcons()

    -- update bar category
    g_activeHotbar = GetActiveHotbarCategory()

	--Add a fragment for the food buff icon container to the HUD and HUD_UD scenes
    --so the icon can be shown/hidden
	local fragment = ZO_HUDFadeSceneFragment:New(FCOUltimateReminderContainer, nil, 0)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
	--Callback function
    HUD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
--d(">HUD_SCENE showing")
			zo_callLater(function()
				if not FCOUR.alertIcon:IsHidden() and FCOUR.alertIcon.icon.hideNow then
					FCOUR.alertIcon.icon.hideNow = false
		    		FCOUltimateReminderContainer:SetHidden(true)
			    	FCOUR.alertIcon:SetHidden(true)
                else
--d(">HUD_SCENE showing, update Ulti values and check if should be shown")
                    --Update the ultimate values and show them at the icon
                    updateAlertIconValues(true)
                    --Show the text alert and/or the icon alert now?
                    checkIfUltimateAlertShouldBeShown()
                end
            end, 350)
		end
    end)
    -- Register slash commands
	RegisterSlashCommands()
end

function FCOUR.initialize()
	EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCOUR.addonLoaded)
end

function FCOUR.Localization()
--d("[FCOUltimateReminder] Localization - Start, keybindings: " .. tostring(FCOUR.preventerVars.KeyBindingTexts) ..", useClientLang: " .. tostring(FCOUR.settingsVars.settings.alwaysUseClientLanguage))
	--Was localization already done during keybindings? Then abort here
 	if FCOUR.preventerVars.KeyBindingTexts == true and FCOUR.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
	--Always use the client's language?
    if not FCOUR.settingsVars.settings.alwaysUseClientLanguage then
		--Was a language chosen already?
	    if not FCOUR.settingsVars.settings.languageChosen then
--d("[FCOUltimateReminder] Localization: Fallback to english. Keybindings: " .. tostring(FCOUR.preventerVars.KeyBindingTexts) .. ", language chosen: " .. tostring(FCOUR.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(FCOUR.settingsVars.defaultSettings.language))
			if FCOUR.settingsVars.defaultSettings.language == nil then
--d("[FCOUltimateReminder] Localization: defaultSettings.language is NIL -> Fallback to english now")
		    	fallbackToEnglish = true
		    else
				--Is the languages array filled and the language is not valid (not in the language array with the value "true")?
				if FCOUR.langVars.languages ~= nil and #FCOUR.langVars.languages > 0 and not FCOUR.langVars.languages[FCOUR.settingsVars.defaultSettings.language] then
		        	fallbackToEnglish = true
--d("[FCOUltimateReminder] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
				end
		    end
		end
	end
--d("[FCOUltimateReminder] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
	--Fallback to english language now
    if (fallbackToEnglish) then FCOUR.settingsVars.defaultSettings.language = 1 end
	--Is the standard language english set?
    if FCOUR.settingsVars.settings.alwaysUseClientLanguage or (FCOUR.preventerVars.KeyBindingTexts or (FCOUR.settingsVars.defaultSettings.language == 1 and not FCOUR.settingsVars.settings.languageChosen)) then
--d("[FCOUltimateReminder] localization: Language chosen is false or always use client language is true!")
		local lang = GetCVar("language.2")
		--Check for supported languages
		if(lang == "de") then
	    	FCOUR.settingsVars.defaultSettings.language = 2
	    elseif (lang == "en") then
	    	FCOUR.settingsVars.defaultSettings.language = 1
	    elseif (lang == "fr") then
	    	FCOUR.settingsVars.defaultSettings.language = 3
	    elseif (lang == "es") then
	    	FCOUR.settingsVars.defaultSettings.language = 4
	    elseif (lang == "it") then
	    	FCOUR.settingsVars.defaultSettings.language = 5
	    elseif (lang == "jp") then
	    	FCOUR.settingsVars.defaultSettings.language = 6
	    elseif (lang == "ru") then
	    	FCOUR.settingsVars.defaultSettings.language = 7
		else
	    	FCOUR.settingsVars.defaultSettings.language = 1
	    end
	end
--d("[FCOUltimateReminder] localization: default settings, language: " .. tostring(FCOUR.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOUR.localizationVars.fco_ur_loc = FCOUR.localizationVars.localizationAll[FCOUR.settingsVars.defaultSettings.language]

    FCOUR.preventerVars.gLocalizationDone = true
end

--Global function to get text for the keybindings etc.
function FCOUR.GetLocText(textName, isKeybindingText)
	isKeybindingText = isKeybindingText or false

    FCOUR.preventerVars.KeyBindingTexts = isKeybindingText

	--Do the localization now
   	FCOUR.Localization()

	if textName == nil or FCOUR.localizationVars.fco_ur_loc == nil or FCOUR.localizationVars.fco_ur_loc[textName] == nil then return "" end
   	return FCOUR.localizationVars.fco_ur_loc[textName]
end

FCOUR.initialize()
