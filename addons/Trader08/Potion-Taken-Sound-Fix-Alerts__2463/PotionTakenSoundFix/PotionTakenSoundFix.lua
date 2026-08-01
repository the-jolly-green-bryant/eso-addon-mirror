if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix
--=============================================================================================================
-- Addon info {{{
--=============================================================================================================

PTSF.addonVars =  {}
PTSF.addonVars.addonRealVersion			= 1.10
PTSF.addonVars.addonRealVersionPreText  = "" --Release is empty string. Pre-Release = "PR " and Release Candicate = "RC "
PTSF.addonVars.addonSavedVarsVersion	= 1.00
PTSF.addonVars.addonSavedVarsModeVersion= 1.00
PTSF.addonVars.addonName				= "PotionTakenSoundFix"
PTSF.addonVars.addonSavedVars			= "PotionTakenSoundFix_Settings"
PTSF.addonVars.settingsName   			= "Potion Taken Sound Fix"
PTSF.addonVars.settingsDisplayName   	= "|cFFFF00Potion|r Taken Sound Fix|l0:1:0:5%:2:FF0000|l & Alerts|l"
PTSF.addonVars.addonAuthor				= "|c00BF9CTrader08|r"
PTSF.addonVars.addonWebsite				= "https://www.esoui.com/downloads/info2463-PotionTakenSoundFix.html"
PTSF.addonVars.addonFeedback			= "https://www.esoui.com/downloads/info2463-PotionTakenSoundFix.html#comments"
PTSF.addonVars.addonDonate				= "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=MGLYRE7N8VTEN&item_name=Support+"..PTSF.addonVars.addonName.."+by+buying+me+a+skooma%21&currency_code=USD&source=url"

--}}}

--=============================================================================================================
-- Libraries {{{
--=============================================================================================================

--LibAddonMenu-2.0
PTSF.addonMenu = LibAddonMenu2
--if PTSF.addonMenu == nil and LibStub then PTSF.addonMenu = LibStub:GetLibrary("LibAddonMenu-2.0") end --deprecated
--}}}

--=============================================================================================================
--	Local variables {{{
--=============================================================================================================

local settings = PTSF.settingsVars.settings
local defaults = PTSF.settingsVars.defaults

local eventRegistered = false
--local potionCooldown_ms = -1

--local userInterfaceVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME))

local baseGamePotionTakenTriggered 			= false --True for some time after the base game sound tries to play. We then need to confirm pot is actually taken before playing the sound
local baseGamePotionTakenTriggeredSlot		= 0 	--1.09 We'll save quickslot as soon as potion was triggered
local potionInventoryItemUsed				= false --Called before single slot update, we will require this check to try to prevent false positives as much as possible
local baseGamePotionTakenSchedule 			= 0 	--Our zo_calllater
local resetPotionTakenCheckVarsDelay 		= 1500 --Humm, no idea how long this could take when server/client lag. 1.5 secs should be enough for lag yet ok for potion taken sound, unless we got a situation where it triggers a false-positive...
local buffsFinder 							= false
local isPlayingPotionTaken 					= false --The 3 "isPlaying" are locks to prevent mutliple calls
local isPlayingPotionLostBuff				= false --Because the event is called for every buff given/lost by the potion
local isPlayingPotionCooldownEnded			= false --This way we make sure we're not calling sound over sound
local isPotionOnCooldown					= false --1.09, for accessibility
local PlaySoundLockDelay					= 1000	 --1000ms delay should be enough yet accurate
local isLowHealthCondition					= false
--local isLowHealthConditionQSlotSelected		= false --Triggers when low health condition is reached and has pot qty and can use pot
local isLowStaminaCondition					= false
--local isLowStaminaConditionQSlotSelected	= false
local isLowMagickaCondition					= false
--local isLowMagickaConditionQSlotSelected	= false
local isInCombat							= false
local quickSlotsOrder 						= {[1] = 4,[2] = 3,[3] = 2,[4] = 1,[5] = 8,[6] = 7,[7] = 6,[8] = 5,}

--Used in code only
local lowResourcesEventsRegistered			= false
local lowHealthUnconditionTimer				= 0 --Timer object
local lowStaminaUnconditionTimer			= 0 --Timer object
local lowMagickaUnconditionTimer			= 0 --Timer object

--(Not in options, should make it better if we do...) To debug potion taken sound logic when no sound is being played, in a least intrusive way as possible
local debugLogic = false
local debugLogicMsg = ""
--}}}

--=============================================================================================================
--	Addon Loaded {{{
--=============================================================================================================

local function PTSF_addonLoaded(eventName, addon)
	if addon ~= PTSF.addonVars.addonName then return end
	if eventRegistered then PTSF.D("Event already Registered") return end
	
	--Load the SavedVariables settings
	PTSF.loadSettings()

    settings = PTSF.settingsVars.settings
    defaults = PTSF.settingsVars.defaults
	
    --Check if this is a new install (we had no saved vars prior to this so the sound settings didn't go thru our "tricked" options menu)
    if(tonumber(settings.potionLostBuffSound) <= 1 ) then --default is 1, but in reality it is sound 2 in our sounds table
    	PTSF.D("Updating save values")
    	settings.potionLostBuffSound = 2
    	if(tonumber(settings.potionCooldownEndedSound) == tonumber(defaults.potionCooldownEndedSound)) then
    		settings.potionCooldownEndedSound = settings.potionCooldownEndedSound + 1
    		PTSF.D("Updated settings.potionCooldownEndedSound="..settings.potionCooldownEndedSound.." from default defaults.potionCooldownEndedSound="..defaults.potionCooldownEndedSound)
    	end
    end
    
	EVENT_MANAGER:UnregisterForEvent(eventName)
	
	--Update user's UI volume
--	userInterfaceVolume = tonumber(GetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME)) --tempo
	
	--1.05
	PTSF.register_potion_taken_events(true)
	
	--new 1.08
	PTSF.register_or_unregister_low_resources_events()
    
    if settings.enableBuffFilter then
    	PTSF.toggle_buff_filters(true)
    end
    	
	--PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF.buffEvent, REGISTER_FILTER_UNIT_TAG, "player") --Only on self (player)
	
	PTSF.D("Loaded successfully")
	eventRegistered = true
	
end --}}}

--=============================================================================================================
--	Some prehook magic {{{
--=============================================================================================================

local function PTSF_PlayItemSound_Hook(sound, action, force)
--    PTSF.D("PTSF_PlayItemSound_Hook sound="..sound.." action="..action.." force="..tostring(force))
    if(sound == ITEM_SOUND_CATEGORY_POTION and action == ITEM_SOUND_ACTION_USE and not force and PTSF.masterSwitch) then
--    	debugLogicMsg = "1-bGPTT" --"PTSF_PlayItemSound_Hook sound="..sound.." action="..action.." force="..tostring(force)
    	baseGamePotionTakenTriggered = true
    	baseGamePotionTakenTriggeredSlot = GetCurrentQuickslot()
    	if baseGamePotionTakenSchedule ~= 0 then
    		EVENT_MANAGER:UnregisterForUpdate(baseGamePotionTakenSchedule)
		end
    	baseGamePotionTakenSchedule = zo_callLater(resetPotionTakenVars, resetPotionTakenCheckVarsDelay)
    	return true --We handle the function call ourselves (Original sound won't play)
    end
    return false --Let thru everything else (all other sounds)
end

local function PTSF_Hook_functions()
	--preHook PlayItemSound function
    ZO_PreHook("PlayItemSound", PTSF_PlayItemSound_Hook)
end --}}}

--=============================================================================================================
--	Player Activated (load hooks and build addon menu) {{{
--=============================================================================================================

function PTSF.Player_Activated(...)
	--Prevent this event to be fired over and over on zone changes
	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_ACTIVATED)

	--Load the hooks
	PTSF_Hook_functions()
	
	--Build addon Menu
	if not PTSF.addonMenu.isBuilt then
	    PTSF.buildAddonMenu()
	end
end --}}}

--=============================================================================================================
--	Potion Taken handler {{{
--=============================================================================================================

--called PTSF.potTaken, but only used for buff lost sound since 1.05
--renamed PTSF.buff v1.10
function PTSF.buffEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)								
--(*[EffectResult|#EffectResult]* _changeType_, *integer* _effectSlot_, *string* _effectName_, *string* _unitTag_, *number* _beginTime_, *number* _endTime_, *integer* _stackCount_, *string* _iconName_, *string* _buffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *string* _unitName_, *integer* _unitId_, *integer* _abilityId_, *[CombatUnitType|#CombatUnitType]* _sourceType_)

--	PTSF.DG("eventCode="..tostring(eventCode).." changeType="..tostring(changeType).." effectSlot="..tostring(effectSlot).." effectName="..tostring(effectName).." unitTag="..tostring(unitTag).." beginTime="..tostring(beginTime).." endTime="..tostring(endTime).." stackCount="..tostring(stackCount).." iconName="..tostring(iconName)
--	.." buffType="..tostring(buffType).." effectType="..tostring(effectType).." abilityType="..tostring(abilityType).." statusEffectType="..tostring(statusEffectType).." unitName="..tostring(unitName).." unitId="..tostring(unitId).." abilityId="..tostring(abilityId).." sourceType="..tostring(sourceType)
--	.."\n")
	if(unitTag ~= "player") then
--	     PTSF.D("PTSF.buffEvent triggered not on player")
	     return
	end
	if(changeType == 1 and beginTime > 0 and endTime > 0) then --changeType = 1 seems to be gained while = 2 lost. beginTime and endTime always return a float value when we just took a potion. Else they return no value or 0 and it's called when pot buffs run out
	    --PTSF.DecreaseUIVolume()
--	    potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug) --potion cooldown from currently selected quickslot
--        PTSF.PlaySound("potionTaken")
        
        --[[In case we use a potion that gives buffs you already have, prevent the lost buff sound to play
        	because using a potion that will "renew" your buffs, it removes the old (so you lose it) and creates a new one.
        	The only bug this might cause is if we actually lose a buff from another potion @ the same time
        	Quite rare and both pot taken and lost buff sounds would play simultaneously anyway--]]
	 	isPlayingPotionLostBuff = true
	 	zo_callLater(function() isPlayingPotionLostBuff = false end, PlaySoundLockDelay)
	    
	    --Since we know the potion duration from the currently selected quickslot and we know we just took a potion and had to be doing it from a quickslot, assume we got the cooldown right.
	    --So we're delay calling the "potion cooldown ended" sound after that said cooldown
--	    zo_callLater(function() PTSF.PlaySound("potionCooldownEnded") end, potionCooldown_ms)

	elseif(changeType == 2 and not isPlayingPotionLostBuff) then --Any Buff lost
		--Known Issue since latest API March 2023: When we take a potion renewing buff(s), API calls this here as buff lost THEN re-calls as buff gained.
		if(settings.enableBuffFilter) then
			if(settings.buffFilters[PTSF.buffs_abilityIds[abilityId]]) then
				PTSF.PlaySound(PTSF.soundCategoryPotionLostBuff) --"potionLostBuff")
				if(settings.TTC_buffLostEnable) then
					PTSF.DA(settings.TTC_buffLostText.." "..tostring(effectName), true)
				end
			end
		--else
	    --	PTSF.PlaySound("potionLostBuff")
	    end
	end
end --}}}

--=============================================================================================================
--	Our PlaySound function {{{
--=============================================================================================================

function PTSF.PlaySound(category)
	if (SOUNDS == nil or not PTSF.masterSwitch) then return end
	local sound
	local volume
	-- PotionTaken {{{
	if (category == PTSF.soundCategoryPotTaken) then --"potionTaken") then
	 	if(isPlayingPotionTaken) then return end
		isPlayingPotionTaken = true
		zo_callLater(function() isPlayingPotionTaken = false end, PlaySoundLockDelay)
--	    PTSF.D("PlaySound category is "..category)
		if(settings.potionTakenSound > 2 and SOUNDS[PTSF.sounds[settings.potionTakenSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.potionTakenSound]]
			volume = settings.potionTakenVolumeBoost
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.potionTakenSound == 2) then
--		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
		else --Defaults to game's potion taken sound
			sound = "DEFAULT"
			volume = 1
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		end --}}}
	-- potionLostBuff {{{
	elseif(category == PTSF.soundCategoryPotionLostBuff) then --"potionLostBuff") then
	  	if(isPlayingPotionLostBuff) then return end
	 	isPlayingPotionLostBuff = true
	 	zo_callLater(function() isPlayingPotionLostBuff = false end, PlaySoundLockDelay)
--	    PTSF.D("PlaySound category is "..category)
		if(settings.potionLostBuffSound > 1 and SOUNDS[PTSF.sounds[settings.potionLostBuffSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.potionLostBuffSound]]
			volume = settings.potionLostBuffVolumeBoost
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.potionLostBuffSound == 1) then
--		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
--		else
--			PTSF.D("PlaySound didn't find any sound to play (code: 5001)")
		end	 --}}}
	-- potionCooldownEnded {{{
	elseif(category == PTSF.soundCategoryPotionCooldownEnded) then --"potionCooldownEnded") then
		if(isPlayingPotionCooldownEnded) then return end
		isPlayingPotionCooldownEnded = true
		isPotionOnCooldown = false --new 1.09
		zo_callLater(function() isPlayingPotionCooldownEnded = false end, PlaySoundLockDelay)
--	    PTSF.D("PlaySound category is "..category)
	    if(settings.TTC_potionReadyEnable) then
	    	PTSF.DA(settings.TTC_potionReadyText, false)
	    end
		if(settings.potionCooldownEndedSound > 1 and SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.potionCooldownEndedSound]]
			volume = settings.potionCooldownEndedVolumeBoost
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.potionCooldownEndedSound == 1) then
--		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
--		else
--			PTSF.D("PlaySound didn't find any sound to play (code: 5002)")
		end
	elseif(category == PTSF.soundCategoryLowHealth) then --"LowHealth") then --new 1.08
--		PTSF.D("PlaySound category is "..category)
		if(settings.lowHealthSound > 2 and SOUNDS[PTSF.sounds[settings.lowHealthSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.lowHealthSound]]
			volume = settings.lowHealthVolumeBoost
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.lowHealthSound == 2) then
--		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
--		else
--			PTSF.D("PlaySound didn't find any sound to play (code: 5002)")
		end
	elseif(category == PTSF.soundCategoryLowStamina) then --"LowStamina") then --new 1.08
--		PTSF.D("PlaySound category is "..category)
		if(settings.lowStaminaSound > 2 and SOUNDS[PTSF.sounds[settings.lowStaminaSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.lowStaminaSound]]
			volume = settings.lowStaminaVolumeBoost
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.lowStaminaSound == 2) then
--		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
--		else
--			PTSF.D("PlaySound didn't find any sound to play (code: 5002)")
		end
	elseif(category == PTSF.soundCategoryLowMagicka) then --"LowMagicka") then --new 1.08
--		PTSF.D("PlaySound category is "..category)
		if(settings.lowMagickaSound > 2 and SOUNDS[PTSF.sounds[settings.lowMagickaSound]]) then -- ~= nil
			sound = SOUNDS[PTSF.sounds[settings.lowMagickaSound]]
			volume = settings.lowMagickaVolumeBoost
--			PTSF.D("PlaySound sound="..sound.." volume="..volume)
		elseif(settings.lowMagickaSound == 2) then
--		    PTSF.D("PlaySound sound is muted")
			return --No sound to play
--		else
--			PTSF.D("PlaySound didn't find any sound to play (code: 5002)")
		end
--	else
--		PTSF.D("PlaySound unknown category ["..tostring(category).."]")
	end --}}}
	
	
	--Now play our sound
	if(sound == "DEFAULT") then
		PlayItemSound(ITEM_SOUND_CATEGORY_POTION, ITEM_SOUND_ACTION_USE, true)
	elseif(sound and volume) then --Volume Booster
    	for i = 1, volume do
        	PlaySound(sound)
--        	PTSF.D(tostring(i).."- Playing "..tostring(sound))
        end
--    else
--    	PTSF.D("PlaySound didn't find any sound to play (code: 5003)")
	end
end --}}}

--=============================================================================================================
--	NEW 1.02 Unknown Potion Buffs Finder {{{
--=============================================================================================================
function PTSF.toggle_potion_buffs_check(enable)
	if(enable) then
		buffsFinder = true
		EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_ITEM_USED, PTSF.INVENTORY_ITEM_USED) --Fix liquid efficiency v1.10, only used for buffs finder now
    	PTSF.DG("Unknown Potion Buffs Finder is |c00FF00ON|r")
    	PTSF.DG("INSTRUCTIONS:\n"
            	.."If you have no lost buff sound for a specific potion,\n"
            	.."1- Enable this option and please let your buffs run out and don't re-buff yourself with any ability\n"
            	.."2- Use that specific potion, you'll see debug lines in chat\n"
            	.."3- Write down the buffs (ability ID's) in red, those are the missing ones\n"
            	.."OR 3- Click on the potion link to show which potion it is and ideally take a screenshot of the chat lines along with the potion tooltip\n"
            	.."4- Post the ability ID's OR screen shot on ESOUI, you can use the 'feedback' button up top of this options' menu\n"
            	.."5- You can now disable this option and wait for a fix")
    	PTSF.DG("-After using a potion, if you see any ability ID in |cFF0000-> red <-|r, please notify dev to have it added.\n"
    	.."-The ability ID's showing in |c00FF00green|r means they are already known by this addon.") --|c00FF00|l0:1:0:-25%:2:000000|lgreen and striked|l|r
    else
    	buffsFinder = false
    	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_ITEM_USED) --Fix liquid efficiency v1.10, only used for buffs finder now
    	PTSF.DG("Unknown Potion Buffs Finder is |c00FF00OFF|r")
    end
end

function PTSF.toggle_buff_filters(enable)
	if(enable) then
		PTSF.D("toggle_buff_filters is |c00FF00ON|r")
		PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF.buffEvent, REGISTER_FILTER_UNIT_TAG, "player") --Only on self (player)
    else
    	PTSF.D("toggle_buff_filters is |c00FF00OFF|r")
    	PTSF.UnRegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName)
    end
end

function PTSF.register_potion_taken_events(enable)
	if(enable) then
		--EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PTSF.INVENTORY_SINGLE_SLOT_UPDATE)
		--EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_ITEM_USED, PTSF.INVENTORY_ITEM_USED) --Fix liquid efficiency v1.10, only used for buffs finder now
		EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_EFFECT_CHANGED, PTSF.EFFECT_CHANGED)
	else
		--EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    	--EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_INVENTORY_ITEM_USED) --Fix liquid efficiency v1.10, only used for buffs finder now
    	EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_EFFECT_CHANGED)
	end
end

--new 1.08
function PTSF.register_or_unregister_low_resources_events()
	if(not PTSF.masterSwitch) then
		if(lowResourcesEventsRegistered) then
			PTSF.D("Unregistered Low Resources Events because of master switch turned off")
			lowResourcesEventsRegistered = false
			EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_POWER_UPDATE, PTSF.PowerUpdate)
			EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_COMBAT_STATE, PTSF.CombatState)
		end
		return
	end
	
	if(settings.lowHealthPercent > 0 or settings.lowStaminaPercent > 0 or settings.lowMagickaPercent > 0) then
		if(not lowResourcesEventsRegistered) then
			PTSF.D("Registered Low Resources Events")
			lowResourcesEventsRegistered = true
			EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_POWER_UPDATE, PTSF.PowerUpdate)
			--EVENT_MANAGER:AddFilterForEvent(string eventNamespace, number eventId, RegisterForEventFilterType filterType, varying filterParameter)
			EVENT_MANAGER:AddFilterForEvent(PTSF.addonVars.addonName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
			EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_COMBAT_STATE, PTSF.CombatState)
			EVENT_MANAGER:AddFilterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_COMBAT_STATE, REGISTER_FILTER_UNIT_TAG, "player")
			--EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_UNIT_DEATH_STATE_CHANGED, PTSF.DeathState) --Shouldn't need this as we check for 0 values (when we're dead) so sounds do not play
		end
	else
		if(lowResourcesEventsRegistered) then
			PTSF.D("Unregistered Low Resources Events")
			lowResourcesEventsRegistered = false
			EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_POWER_UPDATE, PTSF.PowerUpdate)
			EVENT_MANAGER:UnregisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_COMBAT_STATE, PTSF.CombatState)
		end
	end
end

local counter = 1
local tookPotionCheck = 0

-- PTSF.INVENTORY_ITEM_USED {{{
function PTSF.INVENTORY_ITEM_USED(eventCode, itemSoundCategory)
--PTSF.D("INVENTORY_ITEM_USED CALLED");
--EVENT_INVENTORY_ITEM_USED (*integer* _itemSoundCategory_)
--This one gets called 1st but gets called as a false positive if potion is on gcd
	if itemSoundCategory == ITEM_SOUND_CATEGORY_POTION then
--		PTSF.D("INVENTORY_ITEM_USED called eventCode:"..eventCode.." itemSoundCategory:"..itemSoundCategory)
		if buffsFinder then
			counter = 1
			PTSF.DG(counter.."- Potion buffs check begins")
			--PTSF.DG("EVENT_INVENTORY_ITEM_USED")
			if(tookPotionCheck ~= 0) then
				EVENT_MANAGER:UnregisterForUpdate(tookPotionCheck)
			end
			tookPotionCheck = zo_callLater(tookPotionCheckEnded, 250) --250ms time window should be plenty
        end
        --if(baseGamePotionTakenSchedule ~= 0 and baseGamePotionTakenTriggered) then
        --	PTSF.D("EVENT_INVENTORY_ITEM_USED potionInventoryItemUsed is now true")
        --	debugLogicMsg = debugLogicMsg.."=>2-pIIU" -- is now true"
        --	potionInventoryItemUsed = true
        --end
        if(baseGamePotionTakenSchedule ~= 0 and baseGamePotionTakenTriggered) then --TEST and potionInventoryItemUsed) then --All the magic
--        	potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug) --potion cooldown from currently selected quickslot
        	--if(potionCooldown_ms == 0) then --If we can't take a potion but game says we can, we're getting a fake cooldown here which seems to be roll dodge's cooldown. Else, if we CAN take, cooldown is 0. We'll confirm in effect_changed event which HAS potion's cooldown.
        		potionInventoryItemUsed = true;
--        		debugLogicMsg = debugLogicMsg.."=>2-pIIU: true"
			--else
			--	debugLogicMsg = debugLogicMsg.."=>2-pIIU: false cd:"..potionCooldown_ms
			--	PTSF.D("INVENTORY_SINGLE_SLOT_UPDATE potion is NOT Taken, cooldown: "..potionCooldown_ms)
        	--end
        end
    end
end
--}}}
-- PTSF.EFFECT_CHANGED {{{
function PTSF.EFFECT_CHANGED(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime,stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)								
--(*[EffectResult|#EffectResult]* _changeType_, *integer* _effectSlot_, *string* _effectName_, *string* _unitTag_, *number* _beginTime_, *number* _endTime_, *integer* _stackCount_, *string* _iconName_, *string* _buffType_, *[BuffEffectType|#BuffEffectType]* _effectType_, *[AbilityType|#AbilityType]* _abilityType_, *[StatusEffectType|#StatusEffectType]* _statusEffectType_, *string* _unitName_, *integer* _unitId_, *integer* _abilityId_, *[CombatUnitType|#CombatUnitType]* _sourceType_)

--{{{ New way for optimizing performance
--
if(unitTag == "player") then
	if buffsFinder then
		potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug)
		if(tookPotionCheck ~= 0 and potionCooldown_ms > 14000 and string.find(iconName, "achievement") == nil and string.find(effectName, "Dodge Fatigue") == nil) then --We filter to not display achievement buffs nor dodge fatique (roll dodged then used a potion)
			counter = counter + 1
			textColor = "|cFF0000-> "..abilityId.." <-|r"
			if(PTSF.buffs_abilityIds[abilityId]) then
				textColor = "|c00FF00"..abilityId --"|c00FF00|l0:1:0:-25%:2:000000|l"..abilityId.."|l"
			end
			
			PTSF.DG(counter.."- Buff: "..effectName.." abilityId: "..textColor)
		end
	end
	
	if(baseGamePotionTakenSchedule ~= 0 and baseGamePotionTakenTriggered) then -- and potionInventoryItemUsed) then --KNOWN issue: If they have random free pot in CP (Liquid efficiency), sound will not play when free. Bypassing INVENTORY_ITEM_USED SHOULD fix it w/o breaking the addon
		potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug)
		--PTSF.D("EFFECT_CHANGED, cd:"..potionCooldown_ms)
		if(potionCooldown_ms > 14000) then --Gets called multiple times. second false positive has dodge fatigue's cd in potion cd?!? So, cd >= 14000 should always work...
			--debugLogicMsg = debugLogicMsg.."=>3-pEC: yS cd:"..potionCooldown_ms
			if(settings.TTC_potionTakenEnable) then
				PTSF.DA(settings.TTC_potionTakenText, false)
			end
			PTSF.PlaySound(PTSF.soundCategoryPotTaken) --"potionTaken")
--			PTSF.D("EFFECT_CHANGED potion is Taken, cooldown: "..potionCooldown_ms)
			resetPotionTakenVars()
			isPotionOnCooldown = true
			zo_callLater(function() PTSF.PlaySound(PTSF.soundCategoryPotionCooldownEnded) end, PTSF.GetPotionSlotCooldown(PTSF.debug) - 100) --play cooldown ended sound 100ms prior to help with human's reaction time haha
		--else
		--	debugLogicMsg = debugLogicMsg.."=>3-pEC: nS cd:"..potionCooldown_ms
		end
	end
end
--
--}}}
--[[
potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug)

PTSF.D("EFFECT_CHANGED, cd:"..potionCooldown_ms)
	if(unitTag == "player" and string.find(iconName, "achievement") == nil and string.find(effectName, "Dodge Fatigue") == nil) then --We filter to not display achievement buffs nor dodge fatique (roll dodged then used a potion)
		if(tookPotionCheck ~= 0) then --For Unknown potion buffs finder
			counter = counter + 1
			textColor = "|cFF0000-> "..abilityId.." <-|r"
			if(PTSF.buffs_abilityIds[abilityId]) then
				textColor = "|c00FF00"..abilityId --"|c00FF00|l0:1:0:-25%:2:000000|l"..abilityId.."|l"
			end
			
			PTSF.DG(counter.."- Buff: "..effectName.." abilityId: "..textColor)
		end
		if(baseGamePotionTakenSchedule ~= 0 and baseGamePotionTakenTriggered and potionInventoryItemUsed and potionCooldown_ms > 14000) then --Gets called multiple times. second false positive has dodge fatigue's cd in potion cd?!? So, cd >= 14000 should always work...
			debugLogicMsg = debugLogicMsg.."=>3-pEC: yS cd:"..potionCooldown_ms
			if(settings.TTC_potionTakenEnable) then
				PTSF.DA(settings.TTC_potionTakenText, false)
			end
			PTSF.PlaySound("potionTaken")
			PTSF.D("EFFECT_CHANGED potion is Taken, cooldown: "..potionCooldown_ms)
			resetPotionTakenVars()
			isPotionOnCooldown = true
			zo_callLater(function() PTSF.PlaySound("potionCooldownEnded") end, PTSF.GetPotionSlotCooldown(PTSF.debug) - 100) --play cooldown ended sound 100ms prior to help with human's reaction time haha
		else
			debugLogicMsg = debugLogicMsg.."=>3-pEC: nS cd:"..potionCooldown_ms
		end
    end
--]]
end
--}}}

-- PTSF.INVENTORY_SINGLE_SLOT_UPDATE {{{
--[[function PTSF.INVENTORY_SINGLE_SLOT_UPDATE(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
--(*integer* _bagId_, *integer* _slotId_, *bool* _isNewItem_, *integer* _itemSoundCategory_, *integer* _updateReason_)
--Gets called when successfully taking a potion but also if we loot/deposit/withdraw/etc any potion. In other words, any potion change in inventory
PTSF.D("=>ssu:"..slotId.."vs:"..baseGamePotionTakenTriggeredSlot)
debugLogicMsg = debugLogicMsg.."=>3-ssu:"..slotId.."vs:"..baseGamePotionTakenTriggeredSlot
	if itemSoundCategory == ITEM_SOUND_CATEGORY_POTION then
		PTSF.D("INVENTORY_SINGLE_SLOT_UPDATE called")
		if buffsFinder and tookPotionCheck ~= 0 then
			local itemLink = GetItemLink(bagId, slotId)
			counter = counter + 1
			PTSF.DG(counter.."- Potion "..itemLink.." successfully taken") --We actually took a potion!
			--PTSF.DG("EVENT_INVENTORY_SINGLE_SLOT_UPDATE")
        end
        if(baseGamePotionTakenSchedule ~= 0 and baseGamePotionTakenTriggered) then --TEST and potionInventoryItemUsed) then --All the magic
        	potionCooldown_ms = PTSF.GetPotionSlotCooldown(PTSF.debug) --potion cooldown from currently selected quickslot
        	if(potionCooldown_ms > 0) then --BUG HERE was > This happends if baseGameSound tried to play but pot isn't taken and then we loot within baseGamePotionTakenSchedule. But, the cooldown while looting is 0, so we know it's not a pot taken. So we ignore anything below this threshold
        		debugLogicMsg = debugLogicMsg.."=>5.1-cd: "..potionCooldown_ms..":yS"
				PTSF.PlaySound("potionTaken")
				resetPotionTakenVars()
				PTSF.D("INVENTORY_SINGLE_SLOT_UPDATE potion is Taken, cooldown: "..potionCooldown_ms)
				zo_callLater(function() PTSF.PlaySound("potionCooldownEnded") end, potionCooldown_ms)
			else
				debugLogicMsg = debugLogicMsg.."=>5.2cd: "..potionCooldown_ms..":NoS"
				PTSF.D("INVENTORY_SINGLE_SLOT_UPDATE potion is NOT Taken, cooldown: "..potionCooldown_ms)
        	end
        end
    end
end--]]
--}}}
function tookPotionCheckEnded()
	tookPotionCheck = 0
	counter = 1
end
--end of NEW 1.02 Unknown Potion Buffs Finder }}}

--New 1.08 - Low Resources {{{
function PTSF.PowerUpdate(eventType, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
	if(unitTag ~= "player" or (settings.lowRessoucesOnlyInCombat and not isInCombat) or powerValue == 0) then --Ignore powerValue 0 as we're probably dead. Low resource call(s) must have been made prior to this anyway
		return
	end
--	PTSF.D("PTSF.PowerUpdate:".." eventType="..tostring(eventType).." unitTag="..tostring(unitTag).." powerIndex="..tostring(powerIndex).." powerType="..tostring(powerType).." powerValue="..tostring(powerValue).." powerMax="..tostring(powerMax).." powerEffectiveMax="..tostring(powerEffectiveMax).."\n")
		
	--powerType 1=Magicka, 4=Stamina, 32=Health
	local percent
	
	if(powerType == 32 and settings.lowHealthPercent > 0) then
		percent = 100*powerValue/powerMax
		if(percent <= settings.lowHealthPercent) then
			if(not isLowHealthCondition and lowHealthUnconditionTimer == 0) then
--				PTSF.D("Low Health: "..percent.."%")
				if(settings.TTC_lowHPEnable) then
					PTSF.DA(settings.TTC_lowHPText.." "..PTSF.round(percent).."%", true);
				end
				PTSF.PlaySound(PTSF.soundCategoryLowHealth) --"LowHealth")
				--GetSlotItemCount(quickSlotsOrder[settings.lowHealthAutoSlot], HOTBAR_CATEGORY_QUICKSLOT_WHEEL) --Decided to auto-quickslot anyway
				if(settings.lowHealthAutoSlot > 0 and GetCurrentQuickslot() ~= quickSlotsOrder[settings.lowHealthAutoSlot]) then
					SetCurrentQuickslot(quickSlotsOrder[settings.lowHealthAutoSlot])
					if(settings.TTC_AutoQuickslottedPotionEnable) then
						if(isPotionOnCooldown) then
							PTSF.DA(settings.TTC_lowHPText.." "..settings.TTC_AutoQuickslottedPotionNotRdyText, true);
						else
							PTSF.DA(settings.TTC_lowHPText.." "..settings.TTC_AutoQuickslottedPotionRdyText, false);
						end
					end
					if(settings.lowHealthSound == 2) then --Play only when we don't have a sound 2=Disabled
						PlaySound("ABILITY_SLOTTED") --base game doesn't play sound when auto-quickslotted. We don't really hear it when a sound is also selected to play, but makes sense when no sound
						PlaySound("ABILITY_SLOTTED") --boost the volume a bit
						PlaySound("ABILITY_SLOTTED") --boost the volume a bit more
						PlaySound("ABILITY_SLOTTED") --boost the volume even more
						PlaySound("ABILITY_SLOTTED") --boost the volume un peu plus
						PlaySound("ABILITY_SLOTTED") --boost the volume encore plus
						PlaySound("ABILITY_SLOTTED") --boost the volume so we hear it!
					end
				end
				isLowHealthCondition = true
				lowHealthUnconditionTimer = zo_callLater(function() lowHealthUnconditionTimer = 0 end, settings.isOKHealthRepeatDelay * 1000) --Prevent repeating this for lowHealthUnconditionDelay ms. Like, user sets 50% HP. user gets down to 50% (sound), then 52%, then down to 46% (sound again)
			end
		else
			--if(lowHealthUnconditionTimer ~= 0) then
			--	EVENT_MANAGER:UnregisterForUpdate(lowHealthUnconditionTimer)
			--end
			if(percent >= settings.isOKHealthPercent) then --Prevent repeating this too much by adding some % to get out of low condition.
				if(isLowHealthCondition and settings.TTC_HPRecoveredEnable) then
					PTSF.DA(settings.TTC_HPRecoveredText.." "..PTSF.round(percent).."%", false);
				end
				isLowHealthCondition = false
			end
			--lowHealthUnconditionTimer = zo_callLater(function() isLowHealthCondition = false end, lowHealthUnconditionDelay)
		end
	elseif(powerType == 4 and settings.lowStaminaPercent > 0) then
		percent = 100*powerValue/powerMax
		if(percent <= settings.lowStaminaPercent) then
			if(not isLowStaminaCondition and lowStaminaUnconditionTimer == 0) then
--				PTSF.D("Low Stamina: "..percent.."%")
				if(settings.TTC_lowStamEnable) then
					PTSF.DA(settings.TTC_lowStamText.." "..PTSF.round(percent).."%", true);
				end
--				PTSF.D("Current quickslot:"..tostring(GetCurrentQuickslot()))
				if((not isLowHealthCondition or settings.lowHealthAutoSlot == 0) and settings.lowStaminaAutoSlot > 0 and GetCurrentQuickslot() ~= quickSlotsOrder[settings.lowStaminaAutoSlot]) then
					SetCurrentQuickslot(quickSlotsOrder[settings.lowStaminaAutoSlot])
					if(settings.TTC_AutoQuickslottedPotionEnable) then
						if(isPotionOnCooldown) then
							PTSF.DA(settings.TTC_lowStamText.." "..settings.TTC_AutoQuickslottedPotionNotRdyText, true);
						else
							PTSF.DA(settings.TTC_lowStamText.." "..settings.TTC_AutoQuickslottedPotionRdyText, false);
						end
					end
					if(settings.lowStaminaSound == 2) then --Play only when we don't have a sound 2=Disabled
						PlaySound("ABILITY_SLOTTED") --base game doesn't play sound when auto-quickslotted. We don't really hear it when a sound is also selected to play, but makes sense when no sound
						PlaySound("ABILITY_SLOTTED") --boost the volume a bit
						PlaySound("ABILITY_SLOTTED") --boost the volume a bit more
						PlaySound("ABILITY_SLOTTED") --boost the volume even more
						PlaySound("ABILITY_SLOTTED") --boost the volume un peu plus
						PlaySound("ABILITY_SLOTTED") --boost the volume encore plus
						PlaySound("ABILITY_SLOTTED") --boost the volume so we hear it!
					end
				end
				PTSF.PlaySound(PTSF.soundCategoryLowStamina) --"LowStamina")
				isLowStaminaCondition = true
				lowStaminaUnconditionTimer = zo_callLater(function() lowStaminaUnconditionTimer = 0 end, settings.isOKStaminaRepeatDelay * 1000) --Prevent repeating this for lowStaminaUnconditionDelay ms. Like, user sets 50% HP. user gets down to 50% (sound), then 52%, then down to 46% (sound again)
			end
		else
			if(percent >= settings.isOKStaminaPercent) then --Prevent repeating this too much by adding some % to get out of low condition.
				if(isLowStaminaCondition and settings.TTC_StamRecoveredEnable) then
					PTSF.DA(settings.TTC_StamRecoveredText.." "..PTSF.round(percent).."%", false);
				end
				isLowStaminaCondition = false
			end
		end
	elseif(powerType == 1 and settings.lowMagickaPercent > 0) then
		percent = 100*powerValue/powerMax
		if(percent <= settings.lowMagickaPercent) then
			if(not isLowMagickaCondition and lowMagickaUnconditionTimer == 0) then
--				PTSF.D("Low Magicka: "..percent.."%")
				if(settings.TTC_lowMagEnable) then
					PTSF.DA(settings.TTC_lowMagText.." "..PTSF.round(percent).."%", true);
				end
--				PTSF.D("Current quickslot:"..tostring(GetCurrentQuickslot()))
				if((not isLowHealthCondition or settings.lowHealthAutoSlot == 0) and (not isLowStaminaCondition or settings.lowStaminaAutoSlot == 0) and settings.lowMagickaAutoSlot > 0 and GetCurrentQuickslot() ~= quickSlotsOrder[settings.lowMagickaAutoSlot]) then
					SetCurrentQuickslot(quickSlotsOrder[settings.lowMagickaAutoSlot])
					if(settings.TTC_AutoQuickslottedPotionEnable) then
						if(isPotionOnCooldown) then
							PTSF.DA(settings.TTC_lowMagText.." "..settings.TTC_AutoQuickslottedPotionNotRdyText, true);
						else
							PTSF.DA(settings.TTC_lowMagText.." "..settings.TTC_AutoQuickslottedPotionRdyText, false);
						end
					end
					if(settings.lowMagickaSound == 2) then --Play only when we don't have a sound 2=Disabled
						PlaySound("ABILITY_SLOTTED") --base game doesn't play sound when auto-quickslotted. We don't really hear it when a sound is also selected to play, but makes sense when no sound
						PlaySound("ABILITY_SLOTTED") --boost the volume a bit
						PlaySound("ABILITY_SLOTTED") --boost the volume a bit more
						PlaySound("ABILITY_SLOTTED") --boost the volume even more
						PlaySound("ABILITY_SLOTTED") --boost the volume un peu plus
						PlaySound("ABILITY_SLOTTED") --boost the volume encore plus
						PlaySound("ABILITY_SLOTTED") --boost the volume so we hear it!
					end
				end
				PTSF.PlaySound(PTSF.soundCategoryLowMagicka) --"LowMagicka")
				isLowMagickaCondition = true
				lowMagickaUnconditionTimer = zo_callLater(function() lowMagickaUnconditionTimer = 0 end, settings.isOKMagickaRepeatDelay * 1000) --Prevent repeating this for lowMagickaUnconditionDelay ms. Like, user sets 50% HP. user gets down to 50% (sound), then 52%, then down to 46% (sound again)
			end
		else
			if(percent >= settings.isOKMagickaPercent) then --Prevent repeating this too much by adding some % to get out of low condition.
				if(isLowMagickaCondition and settings.TTC_MagRecoveredEnable) then
					PTSF.DA(settings.TTC_MagRecoveredText.." "..PTSF.round(percent).."%", false);
				end
				isLowMagickaCondition = false
			end
		end
	else
		return
	end
	
end
--New 1.08
function PTSF.CombatState(eventType, inCombat)
	isInCombat = inCombat
end
--}}}
--{{{
function resetPotionTakenVars()
	if baseGamePotionTakenSchedule ~= 0 then
		EVENT_MANAGER:UnregisterForUpdate(baseGamePotionTakenSchedule)
	end
	baseGamePotionTakenSchedule 	= 0
	baseGamePotionTakenTriggered 	= false
	potionInventoryItemUsed 		= false
--	potionCooldown_ms				= -1
	if(debugLogic and string.starts(debugLogicMsg, "1-")) then
		PTSF.DG(debugLogicMsg)
		debugLogicMsg = ""
	end
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end
--}}}

--=============================================================================================================
--	Register abilities {{{ Based on Baertram's code
--=============================================================================================================
function PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace, callbackFunc, filterType, filterParameter)
	if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
	if callbackFunc == nil or type(callbackFunc) ~= "function" then return nil end
	local eventCounter = 0
	for abilityId, _ in pairs(PTSF.buffs_abilityIds) do
		eventCounter = eventCounter + 1
		local eventName = addonEventNameSpace .. eventCounter
		EVENT_MANAGER:RegisterForEvent(eventName, EVENT_EFFECT_CHANGED, callbackFunc)
		EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId, filterType, filterParameter)
	end
	return true
end

-- Unregister the register function above
function PTSF.UnRegisterAbilityIdsFilterOnEventEffectChanged(addonEventNameSpace)
    local eventCounter = 0
    if addonEventNameSpace == nil or addonEventNameSpace == "" then return nil end
    for abilityId, _ in pairs(PTSF.buffs_abilityIds) do
        eventCounter = eventCounter + 1
        local eventName = addonEventNameSpace .. eventCounter
        EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_EFFECT_CHANGED)
    end
    return true
end

function PTSF.GetPotionSlotCooldown(chatOutput)
    -- Parameter:   boolean chatOutput: true = output the info to the chat; false = do not show anyhting into the chat
    -- Returns:     number timeLeftInMilliseconds, number buffTotalCooldownInMilliseconds
    chatOutput = chatOutput or false
    -- GetSlotCooldownInfo(*luaindex* _slotIndex_) //NEW!!! GetSlotCooldownInfo(*luaindex* _actionSlotIndex_, *[HotBarCategory|#HotBarCategory]:nilable* _hotbarCategory_)
    -- _Returns:_ *integer* _remain_, *integer* _duration_, *bool* _global_, *[ActionBarSlotType|#ActionBarSlotType]* _globalSlotType_

    --Get the quicklsot index slot ID (quickslot index) = 9
    
    if(debugLogic and baseGamePotionTakenTriggeredSlot ~= GetCurrentQuickslot()) then
    	debugLogicMsg = debugLogicMsg.."=>pGPSC-i:"..baseGamePotionTakenTriggeredSlot.."c:"..GetCurrentQuickslot()
    end
    local remain, duration = GetSlotCooldownInfo(baseGamePotionTakenTriggeredSlot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) --1.09 --GetCurrentQuickslot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if chatOutput then
        PTSF.D("Potion cooldown active, remaining: " .. tostring(remain) .. " of " .. tostring(duration))
    end
    return remain, duration
end

function PTSF.DA(message, negative)
	if(settings.textToChatEnabled) then
		if(negative and settings.textToChatPrefixBad ~= '') then
			d("|c"..settings.textToChatPrefixBadColor.."["..tostring(settings.textToChatPrefixBad).."]|r "..tostring("|c"..settings.textToChatColor..message.."|r")) --Magenta instead or red? D41159
		elseif(not negative and settings.textToChatPrefixGood ~= '') then
			d("|c"..settings.textToChatPrefixGoodColor.."["..tostring(settings.textToChatPrefixGood).."]|r "..tostring("|c"..settings.textToChatColor..message.."|r"))
		else
			d(tostring("|c"..settings.textToChatColor..message.."|r"))
		end
	end
end

function PTSF.round(number)
	return math.floor(number+0.5)
end

--=============================================================================================================
--	onArgCommand (command lines) {{{
--=============================================================================================================
function PTSF.onArgCommand(arg)
--	if(arg == "" or arg == "help" or string.find(arg, "-") == 1) then

	if(string.lower(arg) == "master_switch") then
		if(PTSF.masterSwitch) then
        	PTSF.UnRegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName)
        	PTSF.D("Master Switch is |cFF0000OFF|r (default sound without fix will play)", true)
        	PTSF.masterSwitch = false
        else
        	PTSF.RegisterAbilityIdsFilterOnEventEffectChanged(PTSF.addonVars.addonName, PTSF.buffEvent, REGISTER_FILTER_UNIT_TAG, "player")
            PTSF.DG("Master Switch is |c00FF00ON|r")
            PTSF.masterSwitch = true
        end
    elseif(string.lower(arg) == "buffs_finder") then
    	PTSF.toggle_potion_buffs_check_enabled = not PTSF.toggle_potion_buffs_check_enabled
        PTSF.toggle_potion_buffs_check(PTSF.toggle_potion_buffs_check_enabled)
    elseif(string.lower(arg) == "debug") then
    	PTSF.debug = not PTSF.debug
    	if(PTSF.debug) then
    		PTSF.D("Debug is |c00FF00ON|r", true)
    	else
    		PTSF.D("Debug is |cFF0000OFF|r", true)
    	end
    elseif(string.lower(arg) == "list_buffs") then
    	PTSF.list_abilities_to_chat()
    else
		PTSF.DG("======= Arguments =======")
		PTSF.DG("/ptsf master_switch (Toggles ON/OFF the addon's inner workings)")
		PTSF.DG("/ptsf buffs_finder (Toggles ON/OFF potion buffs finder)")
		PTSF.DG("/ptsf debug (Toggles ON/OFF debug to chat. Mainly used for dev)")
		PTSF.DG("/ptsf list_buffs (List this addon's internal abilityId's linked to potion buffs)")
	end
end --}}}

--=============================================================================================================
--	userInterfaceVolume {{{
--=============================================================================================================
--[[ UI VOLUME
--Increase the Interface Volume
function PTSF.ResetUIVolume()
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, userInterfaceVolume)
end

--Decrease the Interface Volume
function PTSF.MuteUIVolume()
    SetSetting(SETTING_TYPE_AUDIO, AUDIO_SETTING_UI_VOLUME, 0)
    zo_callLater(function() PTSF.IncreaseUIVolume() end, 500)
end --}}}]]

--=============================================================================================================
--	Addon Initialization {{{
--=============================================================================================================

function PTSF.initialize()
	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_PLAYER_ACTIVATED, PTSF.Player_Activated)
	EVENT_MANAGER:RegisterForEvent(PTSF.addonVars.addonName, EVENT_ADD_ON_LOADED, PTSF_addonLoaded)
	SLASH_COMMANDS["/ptsf"] = PTSF.onArgCommand
end --}}}

--Initialize the addon
PTSF.initialize()
