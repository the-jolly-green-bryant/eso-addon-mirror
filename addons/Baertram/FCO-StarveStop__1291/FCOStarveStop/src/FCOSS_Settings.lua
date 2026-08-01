if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Settings
------------------------------------------------------------------------------------------------------------
local function afterSettings()
end

local function NamesToIDSavedVars()
    --Are the character settings enabled? If not abort here
    if (FCOSS.settingsVars.defaultSettings.saveMode ~= 1) then return nil end
    --Did we move the character name settings to character ID settings already?
    if not FCOSS.settingsVars.settings.namesToIDSavedVars then
        local doMove
        local charName
        local displayName = GetDisplayName()
        --Check all the characters of the account
        for i = 1, GetNumCharacters() do
            local name, _, _, _, _, _, characterId = GetCharacterInfo(i)
            charName = name
            charName = zo_strformat(SI_UNIT_NAME, charName)
            --If the current logged in character was found
            if GetUnitName("player") == name and FCOStarveStop_Settings.Default[displayName][charName] then
                doMove = true
                break -- exit the loop
            end
        end
        --Move the settings from the old character name ones to the new character ID settings now
        if doMove then
            FCOSS.settingsVars.settings = FCOStarveStop_Settings.Default[displayName][charName]
            --Set a flag that the settings were moved
            FCOSS.settingsVars.settings.namesToIDSavedVars = true -- should not be necessary because data don't exist anymore in FCOStarveStop_Settings.Default[displayName][name]
        end
    end
end

function FCOSS.loadSettings()
    --The default values for the language and save mode
    local firstRunSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide settings
    }

    FCOSS.settingsVars.defaults = {
        namesToIDSavedVars      = false,
        languageChosen			= false,
        alwaysUseClientLanguage = false,

        debug					= false,

        --Food buff
        textAlert				= true,
        textAlertDrink     		= "Drink !!!",
        textAlertFood     		= "Eat !!!",
        textAlertGeneral		= "-Your food buff is missing-",
        textAlertGeneralChanged = false,

        iconAlert				= true,
        iconAlertX				= 100,
        iconAlertY              = 100,
        iconAlertWidth			= 64,
        iconAlertHeight			= 64,
        iconAlertTexture		= 9,

        alertOnLogin			= true,
        alertRepeatSeconds		= 120,
        alertRepeatChatOutput	= false,
        alertRepeatChatOutputOnlyWithoutFoodBuff = false,
        chatOutputConsumedNamed = true,
        alertNotInHouse         = false,

        showWarningBeforeExpiration = 0,
        showWarningBeforeExpirationRepeat = 30,

        alertCheckEvent			= 9, -- Always check in every region
        alertCheckDungeons		= 6, -- Always check in every dungeon type & outside of dungeons

        alertSound				= 328, --ding JUSTICE_PICKPOCKET_BONUS
        alertSoundRepeat		= 1,
        alertSoundDelay			= 1500,

        alertSoundPotion	  	= 189, --water noise DYEING_TOOL_FILL_USED
        alertSoundRepeatPotion	= 1,
        alertSoundDelayPotion	= 1500,

        --Potion
        potionAlert				= false,
        potionAlertOnlyInCombat	= true,
        textAlertPotion			= true,
        textAlertGeneralPotion	= "-Drink a potion-",
        textAlertGeneralChangedPotion = false,

        iconAlertPotion		 	= false,
        iconAlertXPotion	  	= 200,
        iconAlertYPotion        = 100,
        iconAlertWidthPotion  	= 64,
        iconAlertHeightPotion 	= 64,
        iconAlertTexturePotion	= 25,

        --Quickslots
        changeQuickslotsWithBuffFood = false,
        --PvE quickslots - General settings
        quickSlotChangePVE		= false,
        quickSlotBeforePVE		= 9,
        --PvE quickslots - Change to slot numbers
        quickSlotChangeToPVELast = true,
        quickSlotChangeToPVE	= 9,
        quickSlotChangeToDelvePVE = 9,
        quickSlotChangeToPublicDungeonPVE = 9,
        quickSlotChangeToGroupDungeonPVE = 9,
        quickSlotChangeToRaidDungeonPVE = 9,
        --PvE quickslots - Change to slot numbers in combat
        quickSlotBeforePVEInCombat		= 9,
        quickSlotChangeToPVEInCombatLast = true,
        quickSlotChangeToPVEInCombat = 9,
        quickSlotChangeToDelvePVEInCombat = 9,
        quickSlotChangeToPublicDungeonPVEInCombat = 9,
        quickSlotChangeToGroupDungeonPVEInCombat = 9,
        quickSlotChangeToRaidDungeonPVEInCombat = 9,

        --PvP quickslots - General settings
        quickSlotChangePVP		= false,
        quickSlotBeforePVP		= 9,
        --PvP quickslots - Change to slot numbers
        quickSlotChangeToPVPLast = true,
        quickSlotChangeToPVP	= 9,
        quickSlotChangeToDelvePVP = 9,
        quickSlotChangeToPublicDungeonPVP = 9,
        quickSlotChangeToGroupDungeonPVP = 9,
        quickSlotChangeToRaidDungeonPVP = 9,
        --PvP quickslots - Change to slot numbers in combat
        quickSlotBeforePVPInCombat		= 9,
        quickSlotChangeToPVPInCombatLast = true,
        quickSlotChangeToPVPInCombat = 9,
        quickSlotChangeToDelvePVPInCombat = 9,
        quickSlotChangeToPublicDungeonPVPInCombat = 9,
        quickSlotChangeToGroupDungeonPVPInCombat = 9,
        quickSlotChangeToRaidDungeonPVPInCombat = 9,

        --Food buff quickslots - General settings
        quickSlotChangeToFoodBuffPVE = 9,
        quickSlotChangeToFoodBuffPVP = 9,
        quickSlotChangeToFoodBuffInCombat = false,

        preferAutoSlotSwitch = false,
        changeToLastSlotAfterCompanionUsageFromQuickSlots = false,
    }

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    local addonVars = FCOSS.addonVars
    local defaults  = FCOSS.settingsVars.defaults
    --Load the user's settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOSS.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, 999, "SettingsForAll", firstRunSettings)

    --Check, by help of basic version 999 settings, if the settings should be loaded for each character or account wide
    --Use the current addon version to read the settings now
    if FCOSS.settingsVars.defaultSettings.saveMode == 1 then
        FCOSS.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion , "Settings", defaults)
        --Transfer the data from the name to the unique ID SavedVars now
        NamesToIDSavedVars()

    else
        FCOSS.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonVars.addonSavedVars, addonVars.addonSavedVarsVersion, "Settings", defaults)
    end
    --=============================================================================================================

    --Do some after settings magic
    afterSettings()
end

