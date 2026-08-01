if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

local addonVars = FCOSS.addonVars
local addonName = addonVars.addonName

local EM = EVENT_MANAGER
--local quickslotsNew = FCOSS.quickslotsNew
local quickSlotWheel = FCOSS.quickslotWheelVar
local quickSlotsActionButtonIndex = FCOSS.quickSlotsActionButtonIndex


------------------------------------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------------------------------------
--LibFoodDrinkBuff
local libFDB = LibFoodDrinkBuff or LIB_FOOD_DRINK_BUFF
FCOSS.libFDB = libFDB
--LibPotionBuff
local libPB = LibPotionBuff
FCOSS.libPB = libPB
--LibAddonMenu-2.0
FCOSS.addonMenu = LibAddonMenu2


--local quickslotBarIndexMax = ACTION_BAR_FIRST_UTILITY_BAR_SLOT + ACTION_BAR_UTILITY_BAR_SIZE
--ACTION_BAR_FIRST_NORMAL_SLOT_INDEX

local function quickSlotsDeferredInitialization()
--d("[FCOCS]Quickslots initialized NOW")
	FCOSS.wasInitialized["quickslots"] = true

	FCOSS.updateQuickslotsSettingsDropdown()
end


local function FCOSS_addonLoaded(evetName, addonNameOfAddonLoaded)
	if addonNameOfAddonLoaded ~= addonName then return end
	EM:UnregisterForEvent(evetName)

	--Check if any other dependent/similar addon is active
	FCOSS.checkIfOtherAddonsAreActive()

	--Load the SavedVariables settings
	FCOSS.loadSettings()

	--Deactivate debugging again
	FCOSS.debug = false

	-- Set Localization
	FCOSS.preventerVars.KeyBindingTexts = false
	FCOSS.Localization()

	--Initialize the food and drink buff ability ID names (description texts) for the current active client language
	--FCOSS.getFoodBuffNames(false) --> Using library libFoodDrinkBuffs now

	local settings = FCOSS.settingsVars.settings
	local defaults = FCOSS.settingsVars.defaults
	--Update some localized settings now
	if not settings.textAlertGeneralChanged and settings.textAlertGeneral == defaults["textAlertGeneral"] and FCOSS.localizationVars.fco_ss_loc["icon_tooltip_text"] ~= "" then
		settings.textAlertGeneral = FCOSS.localizationVars.fco_ss_loc["icon_tooltip_text"]
	end
	if not settings.textAlertGeneralChangedPotion and settings.textAlertGeneralPotion == defaults["textAlertGeneralPotion"] and FCOSS.localizationVars.fco_ss_loc["icon_tooltip_potion_text"] ~= "" then
		settings.textAlertGeneralPotion = FCOSS.localizationVars.fco_ss_loc["icon_tooltip_potion_text"]
	end


	--Deferred init of quickslots (on first open of them)
	SecurePostHook(QUICKSLOT_KEYBOARD, "OnDeferredInitialize", quickSlotsDeferredInitialization)

	--Save the last selected quickslot before it gets changed
	ZO_PreHook(quickSlotWheel, "PopulateMenu", function()
		FCOSS.lastSelectedQuickslot = GetCurrentQuickslot()	--QUICKSLOT_RADIAL_KEYBOARD.selectedSlotNum
		--d("[FCOSS]lastSelectedQuickslot: " ..tostring(FCOSS.lastSelectedQuickslot))
	end)

	--Check if quickslot was used, and a collectible was used, and if it was a companion
	--ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
	SecurePostHook("ZO_ActionBar_OnActionButtonUp", function(slotNum)
		--d("[FCOSS]ZO_ActionBar_OnActionButtonUp - slotNum " ..tostring(slotNum))
		--local debugTraceBackStr = debug.traceback() --ATTENTION: Willpause the thread to generate the stack! So better not doing this
		--if not debugTraceBackStr then return end
		--local slotNum = tonumber(debugTraceBackStr:match('keybind = "ACTION_BUTTON_(%d)'))
		if slotNum ~= nil and slotNum == quickSlotsActionButtonIndex then --Is the QuickSlot actionButton (slot)
			local currentQuickslot = GetCurrentQuickslot()
		--d(">currentQuickslot: " ..tostring(currentQuickslot))
			if currentQuickslot == nil then return end
			local slotType = GetSlotType(currentQuickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
		--d(">slotType: " ..tostring(slotType) .. "/" ..tostring(ACTION_TYPE_COLLECTIBLE))
			if slotType ~= ACTION_TYPE_COLLECTIBLE then return end
		--d(">>collectible was used from quickslot" ..tostring(slotNum))
			--Check if collectible used is a companion
			--Get the collectibleId
			local qsItemLink = GetSlotItemLink(currentQuickslot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
			if not qsItemLink then return end
			local collectibleId = GetCollectibleIdFromLink(qsItemLink)
		--d(">>collectibleId for " .. qsItemLink .. ": " ..tostring(collectibleId))
			if not collectibleId then return end
			--Detect the collectible category of the ID
			local collectibleCategory = GetCollectibleCategoryType(collectibleId)
		--d(">>collectibleCategory: " ..tostring(collectibleCategory) .. "/companion: " .. tostring(COLLECTIBLE_CATEGORY_TYPE_COMPANION))
			if not collectibleCategory or collectibleCategory ~= COLLECTIBLE_CATEGORY_TYPE_COMPANION then return end

			zo_callLater(function()
				FCOSS.activateLastQuickslot()
			end, 100)
		end
	end)


	--Load the eevent callback functions
	FCOSS.loadEvents()

	--Create the alert icon control
	FCOSS.createAlertIcons()

	--Add a fragment for the food buff icon container to the HUD and HUD_UD scenes
	--so the icon can be shown/hidden
	local fragmentFood = ZO_HUDFadeSceneFragment:New(FCOStarveStopContainer, nil, 0)
	HUD_SCENE:AddFragment(fragmentFood)
	HUD_UI_SCENE:AddFragment(fragmentFood)
	--Add a fragment for the potion icon container to the HUD and HUD_UD scenes
	--so the icon can be shown/hidden
	local fragmentPotion = ZO_HUDFadeSceneFragment:New(FCOStarveStopContainerPotion, nil, 0)
	HUD_SCENE:AddFragment(fragmentPotion)
	HUD_UI_SCENE:AddFragment(fragmentPotion)
	--Callback function for HUD scene
	HUD_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if newState == SCENE_SHOWING then
			zo_callLater(function()
				if not FCOSS.alertIcon:IsHidden() and FCOSS.alertIcon.hideNow then
					FCOSS.alertIcon.hideNow = false
					FCOStarveStopContainer:SetHidden(true)
					FCOSS.alertIcon:SetHidden(true)
				end
				if not FCOSS.alertIconPotion:IsHidden() and FCOSS.alertIconPotion.hideNow then
					FCOSS.alertIconPotion.hideNow = false
					FCOStarveStopContainerPotion:SetHidden(true)
					FCOSS.alertIconPotion:SetHidden(true)
				end
			end, 350)
		end
	end)

	-- Register slash commands
	FCOSS.RegisterSlashCommands()
end

--Addon initialization
function FCOSS.initialize()
	EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCOSS_addonLoaded)
end

--Starting the addon
FCOSS.initialize()
