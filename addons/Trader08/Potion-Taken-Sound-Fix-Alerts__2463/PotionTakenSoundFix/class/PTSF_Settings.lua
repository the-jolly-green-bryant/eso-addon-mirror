if PotionTakenSoundFix == nil then PotionTakenSoundFix = {} end
local PTSF = PotionTakenSoundFix

--=============================================================================================================
-- Settings
--=============================================================================================================
function PTSF.loadSettings()
    --The default value for save mode
    local firstRunSettings = {
        saveMode     		    = 2, --Standard: Account wide settings
    }
    PTSF.settingsVars.defaults = {

        potionTakenSound				= 1, --default game sound
        potionTakenVolumeBoost			= 1, --default game volume
        
        potionLostBuffSound				= 1, --NONE (slider value)
        potionLostBuffVolumeBoost		= 1,
        
        potionCooldownEndedSound		= 4, --ALCHEMY_SOLVENT_PLACED. "Game's restore defaults" will play it twice since it doesn't throw our doNotPlaySound value
        potionCooldownEndedVolumeBoost	= 1,
        enableBuffFilter				= false,
        buffFilters						= {},
        
        --new 1.08
        lowRessoucesOnlyInCombat		= 1, --In-combat only or at all times
        lowHealthPercent				= 0, --%
        isOKHealthPercent				= 70, --% for our "out of low" condition. Helps in minimizing sound/auto-slot calls
        isOKHealthRepeatDelay			= 3, --seconds to delay sound/auto-slot from when we're out of low condition and back to low. On that second low, will wait before making sound/auto-slot calls (helps to prevent multiple calls too close to each other)
        lowHealthAutoSlot				= 0, --No
        lowHealthSound					= 1, --NONE (slider value)
        lowHealthVolumeBoost			= 1, --default game volume
        
        lowStaminaPercent				= 0, --%
        isOKStaminaPercent				= 50, --% for our "out of low" condition. Helps in minimizing sound/auto-slot calls
        isOKStaminaRepeatDelay			= 3, --seconds to delay sound/auto-slot from when we're out of low condition and back to low. On that second low, will wait before making sound/auto-slot calls (helps to prevent multiple calls too close to each other)
        lowStaminaAutoSlot				= 0, --No
        lowStaminaSound					= 1, --NONE (slider value)
        lowStaminaVolumeBoost			= 1, --default game volume
        
        lowMagickaPercent				= 0, --%
        isOKMagickaPercent				= 50, --% for our "out of low" condition. Helps in minimizing sound/auto-slot calls
        isOKMagickaRepeatDelay			= 3, --seconds to delay sound/auto-slot from when we're out of low condition and back to low. On that second low, will wait before making sound/auto-slot calls (helps to prevent multiple calls too close to each other)
        lowMagickaAutoSlot				= 0, --No
        lowMagickaSound					= 1, --NONE (slider value)
        lowMagickaVolumeBoost			= 1, --default game volume
        
        --new 1.09 Text-to-chat
        textToChatEnabled				= false,
        textToChatPrefixGood			= "OK",
        textToChatPrefixBad				= "WARN",
        textToChatPrefixGoodColor		= "00FF00",
        textToChatPrefixBadColor		= "FF0000",
        textToChatColor					= "FFFF00",
        TTC_potionTakenEnable 			= false,
        TTC_potionTakenText				= "Potion Taken",
        TTC_potionReadyEnable 			= false,
        TTC_potionReadyText				= "Potion Ready",
        TTC_buffLostEnable	 			= false,
        TTC_buffLostText				= "Buff Lost:",
        TTC_lowHPEnable 				= false,
        TTC_lowHPText					= "Low Health",
        TTC_HPRecoveredEnable			= false,
        TTC_HPRecoveredText				= "Health Recovered",
        TTC_lowStamEnable 				= false,
        TTC_lowStamText					= "Low Stamina",
        TTC_StamRecoveredEnable			= false,
        TTC_StamRecoveredText			= "Stamina Recovered",
        TTC_lowMagEnable 				= false,
        TTC_lowMagText					= "Low Magicka",
        TTC_MagRecoveredEnable			= false,
        TTC_MagRecoveredText			= "Magicka Recovered",
        TTC_AutoQuickslottedPotionEnable 		= false,
        TTC_AutoQuickslottedPotionRdyText		= "quickslotted, potion ready", --Will say for example: TTC_lowHPText..TTC_AutoQuickslottedPotionRdyText or: Low Health Quickslotted and potion is ready
        TTC_AutoQuickslottedPotionNotRdyText	= "quickslotted, but potion is on cooldown", --Will say for example: TTC_lowHPText..TTC_AutoQuickslottedPotionNotRdyText or: Low Health Quickslotted Quickslotted but potion is on cooldown
    }
    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    local addonVars = PTSF.addonVars
    local defaults  = PTSF.settingsVars.defaults
    --Save Mode Load the user's settings from SavedVariables file -> Account wide of addonSavedVarsModeVersion at first
    PTSF.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, PTSF.addonVars.addonSavedVarsModeVersion, "SettingsForAll", firstRunSettings) --Make the save mode static

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if (PTSF.settingsVars.defaultSettings.saveMode == 1) then
        PTSF.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion , "Settings", defaults)

    elseif (PTSF.settingsVars.defaultSettings.saveMode == 2) then
        PTSF.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, "Settings", defaults)
    else
        PTSF.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, "Settings", defaults)
    end
    PTSF.settingsVars.settings.debug = nil --Remove this value from users' savedvars from prior v1.02
    
    --1.05 Need to force off old buffs tracking prior to 1.05 (ID's are now the same coming from potions or other sources...
	--[[PTSF.settingsVars.settings.buffFilters["Major Brutality"] = false
	PTSF.settingsVars.settings.buffFilters["Major Savagery"] = false
	PTSF.settingsVars.settings.buffFilters["Major Sorcery"] = false
	PTSF.settingsVars.settings.buffFilters["Major Prophecy"] = false
	PTSF.settingsVars.settings.buffFilters["Major Vitality"] = false
	PTSF.settingsVars.settings.buffFilters["Minor Protection"] = false
	PTSF.settingsVars.settings.buffFilters["Minor Heroism"] = false
	PTSF.settingsVars.settings.buffFilters["Physical Resistance"] = false
	PTSF.settingsVars.settings.buffFilters["Spell Resistance"] = false
	PTSF.settingsVars.settings.buffFilters["Major Expedition"] = false]]--
    --=============================================================================================================
end

