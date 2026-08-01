------------------------------------------------------------------
--FCOUltimateSound.lua
--Author: Baertram
--[[
    Changes/removes the sound when your ultimate ability is ready
]]
------------------------------------------------------------------
FCOUS = FCOUS or {}
local FCOUS = FCOUS

local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER
local tos = tostring

--Constants
local CON_PLAYER                    = "player"
local CON_MUTE                      = "mute"
local CON_NONE                      = "NONE"
local CON_SELECTED_SOUND_IDX_NONE   = 1
local CON_ULTIMATE_READY            = "ABILITY_ULTIMATE_READY"
local CON_ULTIMATE_READY_BACKUPED   = "ABILITY_ULTIMATE_READY_FCO"

--Backup the real ultimate ready sound as FCO named sound
local backupedUltimateReadySound = SOUNDS[CON_ULTIMATE_READY]
SOUNDS[CON_ULTIMATE_READY_BACKUPED] = backupedUltimateReadySound

local ultimateIndex = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

local activeWeaponPairToHotbarCategory = {
    [ACTIVE_WEAPON_PAIR_MAIN] =     HOTBAR_CATEGORY_PRIMARY,
    [ACTIVE_WEAPON_PAIR_BACKUP] =   HOTBAR_CATEGORY_BACKUP,
}
local g_activeHotbar = HOTBAR_CATEGORY_PRIMARY

--Number values
FCOUS.numVars = {}
FCOUS.numVars.languageCount = 7

--Language variables
FCOUS.langVars              = {}
FCOUS.langVars.languages = {}
--Build the languages array
for i=1, FCOUS.numVars.languageCount do
    FCOUS.langVars.languages[i] = true
end

--Addon variables
FCOUS.addonVars = {}
local addonVars = FCOUS.addonVars
addonVars.gAddonName				= "FCOUltimateSound"
addonVars.addonNameMenu				= "FCO Ultimate Sound"
addonVars.addonNameMenuDisplay		= "|c00FF00FCO |cFFFF00 Ultimate Sound|r"
addonVars.addonAuthor 				= '|cFFFF00Baertram|r'
addonVars.addonVersion		   		= 0.13 -- Changing this will reset SavedVariables!
addonVars.addonVersionOptions 		= '0.1.8' -- version shown in the settings panel
addonVars.addonVersionOptionsNumber = 0.180
addonVars.addonSavedVariablesName	= "FCOUltimateSound_Settings"
addonVars.gAddonLoaded				= false

local addonName = addonVars.gAddonName

FCOUS.settingsVars                          = {}
FCOUS.settingsVars.settings 				= {}
FCOUS.settingsVars.defaultSettings			= {}

FCOUS.preventerVars = {}
FCOUS.preventerVars.gLocalizationDone = false
FCOUS.preventerVars.gUltimateSoundChangedInSettings = false
FCOUS.preventerVars.playingUltimateSoundOnWeaponSwitch = false
FCOUS.preventerVars.actualWeaponBarId = -1
FCOUS.preventerVars.activeWeaponPairLocked = false
FCOUS.preventerVars.weaponSwitchedButPlayNoSound = false
FCOUS.preventerVars.forcePlay = false --Shall we only play a sound now without any further checks?

--Array for the translations
FCOUS.localizationVars = {}

--Array for the ultimate variables
FCOUS.ultiVars = {}
FCOUS.ultiVars.value = -1
FCOUS.ultiVars.costs = -1

--===================== FUNCTIONS ==============================================

--Change or mute the ultimate sound
local function FCOUltimateSound_ChangeUltimateSound(newSoundName, noUltimateSound)
    newSoundName = newSoundName or CON_MUTE
    if noUltimateSound == nil then noUltimateSound = FCOUS.settingsVars.settings.noUltimateSound end
    --Mute the ultimate sound?
    if newSoundName == CON_MUTE and noUltimateSound == true then
        --Set the current ultimate sound to mute
        SOUNDS[CON_ULTIMATE_READY] = SOUNDS.NONE
    elseif newSoundName == CON_ULTIMATE_READY then
        --Revert ultimate sound from backuped original ultimate sound
        if SOUNDS[CON_ULTIMATE_READY_BACKUPED] ~= nil then
            SOUNDS[CON_ULTIMATE_READY] = SOUNDS[CON_ULTIMATE_READY_BACKUPED]
        end
    else
        --d("FCOUltimateSound_ChangeUltimateSound to: " .. SOUNDS[newSoundName])
        if newSoundName ~= nil and SOUNDS[newSoundName] ~= nil then
            SOUNDS[CON_ULTIMATE_READY] = SOUNDS[newSoundName]
        else
            SOUNDS[CON_ULTIMATE_READY] = SOUNDS.NONE
        end
    end
end

--Update the ultimate sound now
local function FCOUltimateSound_UpdateUltimateSound(activeWeaponBarId)
    --d("[FCOUltimateSound_UpdateUltimateSound] activeWeaponBarId: " .. tos(activeWeaponBarId))

    --ACTIVE_WEAPON_PAIR_BACKUP = 2
    --ACTIVE_WEAPON_PAIR_MAIN = 1
    --ACTIVE_WEAPON_PAIR_NONE = 0

    if activeWeaponBarId == nil or activeWeaponBarId == ACTIVE_WEAPON_PAIR_NONE then return end
    local settings = FCOUS.settingsVars.settings
    local noUltimateSound = settings.noUltimateSound
    --Change or mute the ultimate sound now
    if noUltimateSound == true then
        FCOUltimateSound_ChangeUltimateSound(CON_MUTE, noUltimateSound)
        return
    else
        local ultimateSoundNameAtActiveWeaponBarId = settings.ultimateSoundName[activeWeaponBarId]
        if ultimateSoundNameAtActiveWeaponBarId ~= nil and ultimateSoundNameAtActiveWeaponBarId ~= "" then
--d(">ultimateSoundNameAtActiveWeaponBarId: " ..tos(ultimateSoundNameAtActiveWeaponBarId))
            FCOUltimateSound_ChangeUltimateSound(ultimateSoundNameAtActiveWeaponBarId, noUltimateSound)
            return
        end
    end
    FCOUltimateSound_ChangeUltimateSound(CON_ULTIMATE_READY, noUltimateSound)
end

--Change the ultimate sound to the one set in FCOUS.settingsVars.settings for the active weapon bar
local function FCOUltimateSound_GetWeaponBarUltimateSound(weaponBarId)
--d("[FCOUltimateSound_GetWeaponBarUltimateSound] weaponBarId: " .. tos(weaponBarId))
    local activeWeaponBarId
    if weaponBarId == nil or weaponBarId == -1  then
        activeWeaponBarId = GetActiveWeaponPairInfo()
    else
        activeWeaponBarId = weaponBarId
    end
    --Get the active weapon bar and change the ultimate sound to the one setup for this bar
    if activeWeaponBarId ~= nil then
        --Change the ultimate sound to the one selected for the current weapon bar
        FCOUltimateSound_UpdateUltimateSound(activeWeaponBarId)
    else
        --Fallback solution: Use ultimate sound of weapon bar 1
        FCOUltimateSound_UpdateUltimateSound(ACTIVE_WEAPON_PAIR_MAIN)
    end
end

--Fires each time a skill is slotted or all the action slots are updated
local function FCOUltimateSound_Update_Ulti_Costs()
--d("Update ulti costs")
    local prevVarActualWeaponBarId = FCOUS.preventerVars.actualWeaponBarId
    if prevVarActualWeaponBarId == nil or (prevVarActualWeaponBarId ~= 1 and prevVarActualWeaponBarId ~= 2)  then return end
    if not FCOUS.settingsVars.settings.ultimateSoundOnWeaponSwitch then return end
    local isSlotUsed = IsSlotUsed(ultimateIndex, g_activeHotbar)

    --Cost of actual ultimate skill
    local ultiCosts,  ultiMechanic
    if isSlotUsed then
        local ultiCosts, ultiMechanic
        if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
            ultiCosts, ultiMechanic = GetSlotAbilityCost(ultimateIndex, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_activeHotbar)
        else
            ultiCosts, ultiMechanic = GetSlotAbilityCost(ultimateIndex, g_activeHotbar)
        end
        if ultiCosts ~= nil and ultiCosts > 0 then
            if ultiMechanic == POWERTYPE_ULTIMATE or COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
                FCOUS.ultiVars.costs = ultiCosts
            else
                FCOUS.ultiVars.costs = 0
            end
        else
            FCOUS.ultiVars.costs = -1
        end
    else
        FCOUS.ultiVars.costs = -1
    end
--d("<Ulti costs: " .. FCOUS.ultiVars.costs .. ", ultiCosts: " ..tos(ultiCosts) .. ", ultiMechanic: " ..tos(ultiMechanic))
end

--Fires each time a skill is used etc.
local function FCOUltimateSound_Update_Ulti_Value()
--d("Update ulti value")
    local prevVarActualWeaponBarId = FCOUS.preventerVars.actualWeaponBarId
    if prevVarActualWeaponBarId == nil
            or (prevVarActualWeaponBarId <= ACTIVE_WEAPON_PAIR_NONE or prevVarActualWeaponBarId > ACTIVE_WEAPON_PAIR_BACKUP) then
        return false
    end
    if not FCOUS.settingsVars.settings.ultimateSoundOnWeaponSwitch then return end

    local isSlotUsed = IsSlotUsed(ultimateIndex, g_activeHotbar)
    if isSlotUsed then
        --Current ultimate value
        local ultiPower
        if COMBAT_MECHANIC_FLAGS_ULTIMATE ~= nil then
            ultiPower = GetUnitPower(CON_PLAYER, COMBAT_MECHANIC_FLAGS_ULTIMATE)
        else
            ultiPower = GetUnitPower(CON_PLAYER, POWERTYPE_ULTIMATE)
        end
--d("Ulti power: " .. ultiPower)
        if ultiPower <= 0 then
            ultiPower = -1
        end
        FCOUS.ultiVars.value = ultiPower
    else
        FCOUS.ultiVars.value = -1
    end
end

--Function to play the weapon switched sound
local function FCOUltimateSound_PlaySoundOnWeaponSwitch(weaponBarId)
--d("[FCOUltimateSound_PlaySoundOnWeaponSwitch] WeaponBar: " .. weaponBarId)
	--Active weapon pair is given with 1 or 2?
	if weaponBarId <= ACTIVE_WEAPON_PAIR_NONE or weaponBarId > ACTIVE_WEAPON_PAIR_BACKUP then return false end
	local settings = FCOUS.settingsVars.settings
--d(">1")
    --Are we in combat and does the setting only allow to play the weapon swithc sound in combat?
    if settings.weaponSwitchSoundOnlyInFight and not IsUnitInCombat(CON_PLAYER) then return false end
--d(">2")
    local weaponSwitchSoundName = settings.weaponSwitchSoundName
    if weaponSwitchSoundName[weaponBarId] == CON_NONE then return false end
--d(">3")
	--Force the PlaySound Hook to just call the standard PlaySound procedure
	--FCOUS.preventerVars.forcePlay = true
    --Play the weapon switched sound now
    PlaySound(SOUNDS[weaponSwitchSoundName[weaponBarId]])
end


--Fires each time you change your weapon bars
local function FCOUltimateSound_ActiveWeaponPairChanged(eventCode, activeWeaponPair, locked)
--d("Changed weapon bar to: " .. activeWeaponPair .. " (" .. FCOUS.preventerVars.actualWeaponBarId .. "), locked: " .. tos(locked))
    FCOUS.preventerVars.activeWeaponPairLocked = locked

    -- update bar category
    g_activeHotbar = activeWeaponPairToHotbarCategory[activeWeaponPair] or GetActiveHotbarCategory()

    --Normal: Play no ultimate sound after weapon bar switch
    FCOUS.preventerVars.weaponSwitchedButPlayNoSound = true
    if locked and FCOUS.preventerVars.actualWeaponBarId ~= activeWeaponPair then
		--Play the weapon bar switched sound
        FCOUltimateSound_PlaySoundOnWeaponSwitch(activeWeaponPair)
        --Update the ultimate sound for the actual weapon bar
        FCOUltimateSound_GetWeaponBarUltimateSound(activeWeaponPair)
        --Set the current weapon bar ID
        FCOUS.preventerVars.actualWeaponBarId = activeWeaponPair
        --No ultimate sound should be played? All needed variables were updated, so abort here
        local settings = FCOUS.settingsVars.settings
        if settings.noUltimateSound then return end
        --Don't play sound on weapon bar switch and ultimate is ready
        if not settings.ultimateSoundOnWeaponSwitch then
            --Dont play a sound upon weapon bar change, if it is not wished
            FCOUS.preventerVars.weaponSwitchedButPlayNoSound = true

        --Play sound on weapon bar switch and ultimate is ready
        else
            --Play a sound upon weapon bar change, if it is not wished
            FCOUS.preventerVars.weaponSwitchedButPlayNoSound = false
            --Call this function a bit later to read the correct ultimate skill, and not the one from the prior list
            zo_callLater(function()
--d(">WeaponBar switched: Play ultimate sound")
                --Update the actual ultimate's costs
                FCOUltimateSound_Update_Ulti_Costs()
                --Update the actual ultimate's value
                FCOUltimateSound_Update_Ulti_Value()
                local ultiVars = FCOUS.ultiVars
                if ultiVars.value ~= -1 and ultiVars.costs ~= -1 and ultiVars.value > 0 and ultiVars.costs > 0 then
                    --Ultimate current value is lower then the costs?
                    if ultiVars.value < ultiVars.costs then return false end
                    --Set the variable for the play sound each time on weapon switch so it won't be played twice
                    FCOUS.preventerVars.playingUltimateSoundOnWeaponSwitch = true
--d("Playing ultimate sound now, value/costs: " .. FCOUS.ultiVars.value .. "/" .. FCOUS.ultiVars.costs)
                    PlaySound(SOUNDS[CON_ULTIMATE_READY])
                end
            end, 50)
        end
    end
end

local function Localization()
    --d("[FCOUS] Localization - Start, useClientLang: " .. tos(FCOUS.settingsVars.settings.alwaysUseClientLanguage))
    --Was localization already done during keybindings? Then abort here
    if FCOUS.preventerVars.gLocalizationDone == true then return end
    local settingsBase = FCOUS.settingsVars
    local defaultSettings = settingsBase.settings
    local settings = settingsBase.settings
    --Fallback to english variable
    local fallbackToEnglish = false
    --Always use the client's language?
    if not settings.alwaysUseClientLanguage then
        --Was a language chosen already?
        if not settings.languageChosen then
            --d("[FCOUS] Localization: Fallback to english. Language chosen: " .. tos(FCOUS.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tos(FCOUS.settingsVars.defaultSettings.language))
            if defaultSettings.language == nil then
                --d("[FCOUS] Localization: defaultSettings.language is NIL -> Fallback to english now")
                fallbackToEnglish = true
            else
                --Is the languages array filled and the language is not valid (not in the language array with the value "true")?
                if FCOUS.langVars.languages ~= nil and #FCOUS.langVars.languages > 0 and not FCOUS.langVars.languages[defaultSettings.language] then
                    fallbackToEnglish = true
                    --d("[FCOUS] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
                end
            end
        end
    end
    --d("[FCOUS] localization, fallBackToEnglish: " .. tos(fallbackToEnglish))
    --Fallback to english language now
    if (fallbackToEnglish) then FCOUS.settingsVars.defaultSettings.language = 1 end
    --Is the standard language english set?
    if settings.alwaysUseClientLanguage or (defaultSettings.language == 1 and not settings.languageChosen) then
        --d("[FCOUS] localization: Language chosen is false or always use client language is true!")
        local lang = GetCVar("language.2")
        --Check for supported languages
        if(lang == "de") then
            FCOUS.settingsVars.defaultSettings.language = 2
        elseif (lang == "en") then
            FCOUS.settingsVars.defaultSettings.language = 1
        elseif (lang == "fr") then
            FCOUS.settingsVars.defaultSettings.language = 3
        elseif (lang == "es") then
            FCOUS.settingsVars.defaultSettings.language = 4
        elseif (lang == "it") then
            FCOUS.settingsVars.defaultSettings.language = 5
        elseif (lang == "jp") then
            FCOUS.settingsVars.defaultSettings.language = 6
        elseif (lang == "ru") then
            FCOUS.settingsVars.defaultSettings.language = 7
        else
            FCOUS.settingsVars.defaultSettings.language = 1
        end
    end
    --d("[FCOUS] localization: default settings, language: " .. tos(FCOUS.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOUS.localizationVars.fcous_loc = FCOUS.localizationVars.localizationAll[FCOUS.settingsVars.defaultSettings.language]

    FCOUS.preventerVars.gLocalizationDone = true
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

	if(#options == 0 or options[1] == "" or options[1] == "toggle") then
    	FCOUS.settingsVars.settings.noUltimateSound = not FCOUS.settingsVars.settings.noUltimateSound
        FCOUltimateSound_UpdateUltimateSound()
        if (FCOUS.settingsVars.settings.noUltimateSound == true) then
        	d(FCOUS.localizationVars.fcous_loc["chatcommands_noultimatesound_on"])
        else
        	FCOUS.settingsVars.settings.noUltimateSound = false
        	d(FCOUS.localizationVars.fcous_loc["chatcommands_noultimatesound_off"])
        end
        --ReloadUI()
    end
end

-- Build the options menu
local function BuildAddonMenu()
    local ttSuffix = "_tooltip"

    local LAM 	= LibAddonMenu2

	local panelData = {
		type 				= 'panel',
		name 				= addonVars.addonNameMenu,
		displayName 		= addonVars.addonNameMenuDisplay,
		author 				= addonVars.addonAuthor,
		version 			= addonVars.addonVersionOptions,
		registerForRefresh 	= true,
		registerForDefaults = true,
		slashCommand = "/fcouss",
	}

    -- !!! RU Patch Section START
    --  Add english language description behind language descriptions in other languages
    local function nvl(val) if val == nil then return "..." end return val end
    local LV_Cur = FCOUS.localizationVars.fcous_loc
    local LV_Eng = FCOUS.localizationVars.localizationAll[1]
    local languageOptions = {}
    local languageOptionsValues = {}
    for i=1, FCOUS.numVars.languageCount do
        local s="options_language_dropdown_selection"..i
        if LV_Cur==LV_Eng then
            languageOptions[i] = nvl(LV_Cur[s])
        else
            languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
        end
        languageOptionsValues[i] = i
    end
    -- !!! RU Patch Section END

    local fcous_loc = FCOUS.localizationVars.fcous_loc

    local savedVariablesOptions = {
    	[1] = fcous_loc["options_savedVariables_dropdown_selection1"],
        [2] = fcous_loc["options_savedVariables_dropdown_selection2"],
    }
    local savedVariablesOptionsValues = {
    	[1] = 1,
        [2] = 2,
    }

    local FCOUSsettings = FCOUS.settingsVars.settings

	local function UpdateWeaponSwitchSoundDescription(weaponBarId)
        if weaponBarId == -1 then
            for weaponPairId=ACTIVE_WEAPON_PAIR_MAIN, ACTIVE_WEAPON_PAIR_BACKUP, 1 do
        	    UpdateWeaponSwitchSoundDescription(weaponPairId)
            end
		elseif weaponBarId == ACTIVE_WEAPON_PAIR_MAIN or weaponBarId == ACTIVE_WEAPON_PAIR_BACKUP then
            local weaponSwitchSoundName = FCOUSsettings.weaponSwitchSoundName
            for weaponPairId=ACTIVE_WEAPON_PAIR_MAIN, ACTIVE_WEAPON_PAIR_BACKUP, 1 do
                --Weapon switch sound bar id
                GetControl("FCOUltimateSoundWeaponSwitchSoundBar"..tos(weaponPairId)).label:SetText(fcous_loc["options_play_sound_on_weapon_switch" ..tos(weaponPairId)] .. ": " .. weaponSwitchSoundName[weaponPairId])
            end
		end
    end
    local function UpdateNewUltimateSoundDescription(weaponBarId)
        if weaponBarId == -1 then
            for weaponPairId=ACTIVE_WEAPON_PAIR_MAIN, ACTIVE_WEAPON_PAIR_BACKUP, 1 do
        	    UpdateNewUltimateSoundDescription(weaponPairId)
            end
		elseif weaponBarId == ACTIVE_WEAPON_PAIR_MAIN or weaponBarId == ACTIVE_WEAPON_PAIR_BACKUP then
            local ultimateSoundName = FCOUSsettings.ultimateSoundName
            for weaponPairId=ACTIVE_WEAPON_PAIR_MAIN, ACTIVE_WEAPON_PAIR_BACKUP, 1 do
                --New ultimate sound id
                GetControl("FCOUltimateSoundNewUltimateSound" .. tos(weaponPairId)).label:SetText(fcous_loc["options_newultimatesound" ..tos(weaponPairId)] .. ": " .. ultimateSoundName[weaponPairId])
            end
		end
    end

    local function playChosenUltimateSoundFromSettings(soundIdx)
        if soundIdx == CON_SELECTED_SOUND_IDX_NONE or SOUNDS == nil then return end
        local fcousSounds = FCOUS.sounds
        local value = fcousSounds[soundIdx]
        if not value then return end
        --FCOUS.preventerVars.forcePlay = false

        if value == CON_ULTIMATE_READY then
            PlaySound(SOUNDS[CON_ULTIMATE_READY_BACKUPED])
        else
            if not SOUNDS[value] then return end
            PlaySound(SOUNDS[value])
        end
    end


	FCOUS.LAMsettingsPanel = LAM:RegisterAddonPanel(addonName .. "_LAM", panelData)

	--LAM 2.0 callback function if the panel was created
    local FCOLAMPanelCreated
	FCOLAMPanelCreated = function(panel)
        if panel ~= FCOUS.LAMsettingsPanel then return end
        UpdateNewUltimateSoundDescription(-1)
        UpdateWeaponSwitchSoundDescription(-1)

        CM:UnregisterCallback("LAM-RefreshPanel", FCOLAMPanelCreated)
    end
	CM:RegisterCallback("LAM-PanelControlsCreated", FCOLAMPanelCreated)

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

		{
			type = 'description',
			text = fcous_loc["options_description"],
		},
        --==============================================================================
		{
        	type = 'header',
        	name = fcous_loc["options_header1"],
        },
		{
			type = 'dropdown',
			name = fcous_loc["options_language"],
			tooltip = fcous_loc["options_language" .. ttSuffix],
			choices = languageOptions,
			choicesValues = languageOptionsValues,
            getFunc = function() return FCOUS.settingsVars.defaultSettings.language end,
            setFunc = function(value)
                FCOUS.settingsVars.defaultSettings.language = value
                FCOUSsettings.languageChoosen = true
            end,
            warning = fcous_loc["options_language_description1"],
            requiresReload = true,
		},
        {
            type = "checkbox",
            name = fcous_loc["options_language_use_client"],
            tooltip = fcous_loc["options_language_use_client".. ttSuffix],
            getFunc = function() return FCOUSsettings.alwaysUseClientLanguage end,
            setFunc = function(value)
                FCOUSsettings.alwaysUseClientLanguage = value
                --ReloadUI()
            end,
            default = FCOUSsettings.alwaysUseClientLanguage,
            warning = fcous_loc["options_language_description1"],
            requiresReload = true,
        },
		{
			type = 'dropdown',
			name = fcous_loc["options_savedvariables"],
			tooltip = fcous_loc["options_savedvariables".. ttSuffix],
			choices = savedVariablesOptions,
            choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOUS.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                FCOUS.settingsVars.defaultSettings.saveMode = value
                ReloadUI()
            end,
            warning = fcous_loc["options_language_description1"],
            requiresReload = true,
		},
--==============================================================================
		{
        	type = 'header',
        	name = fcous_loc["options_header_ultimate_sound"],
        },
		{
			type = "checkbox",
			name = fcous_loc["options_toggle_noultimatesound"],
			tooltip = fcous_loc["options_toggle_noultimatesound".. ttSuffix],
			getFunc = function() return FCOUSsettings.noUltimateSound end,
			setFunc = function(value)
            	FCOUSsettings.noUltimateSound = value
                FCOUltimateSound_UpdateUltimateSound()
            end
            --warning = fcous_loc["options_language_description1"],
		},

        {
            type = 'slider',
            name = fcous_loc["options_newultimatesound1"],
            tooltip = fcous_loc["options_newultimatesound1".. ttSuffix],
            min = 1,
            max = #FCOUS.sounds,
            getFunc = function()
                return FCOUSsettings.ultimateSoundNameIndex[ACTIVE_WEAPON_PAIR_MAIN]
            end,
            setFunc = function(idx)
                local activeWeaponPair = ACTIVE_WEAPON_PAIR_MAIN
                FCOUSsettings.ultimateSoundNameIndex[activeWeaponPair] = idx
                FCOUSsettings.ultimateSoundName[activeWeaponPair] = FCOUS.sounds[idx]
                UpdateNewUltimateSoundDescription(activeWeaponPair)

                FCOUltimateSound_UpdateUltimateSound(activeWeaponPair)
                FCOUS.preventerVars.gUltimateSoundChangedInSettings = true

                playChosenUltimateSoundFromSettings(idx)
            end,
            default = FCOUSsettings.ultimateSoundNameIndex[ACTIVE_WEAPON_PAIR_MAIN],
            disabled = function() return FCOUSsettings.noUltimateSound end,
            reference = "FCOUltimateSoundNewUltimateSound" ..tos(ACTIVE_WEAPON_PAIR_MAIN),
        },
        {
            type = 'slider',
            name = fcous_loc["options_newultimatesound2"],
            tooltip = fcous_loc["options_newultimatesound2".. ttSuffix],
            min = 1,
            max = #FCOUS.sounds,
            getFunc = function()
                return FCOUSsettings.ultimateSoundNameIndex[ACTIVE_WEAPON_PAIR_BACKUP]
            end,
            setFunc = function(idx)
                local activeWeaponPair = ACTIVE_WEAPON_PAIR_BACKUP
                FCOUSsettings.ultimateSoundNameIndex[activeWeaponPair] = idx
                FCOUSsettings.ultimateSoundName[activeWeaponPair] = FCOUS.sounds[idx]
                UpdateNewUltimateSoundDescription(activeWeaponPair)

                FCOUltimateSound_UpdateUltimateSound(activeWeaponPair)
                FCOUS.preventerVars.gUltimateSoundChangedInSettings = true

                playChosenUltimateSoundFromSettings(idx)
            end,
            default = FCOUSsettings.ultimateSoundNameIndex[ACTIVE_WEAPON_PAIR_BACKUP],
            disabled = function() return FCOUSsettings.noUltimateSound end,
            reference = "FCOUltimateSoundNewUltimateSound" ..tos(ACTIVE_WEAPON_PAIR_BACKUP),
        },


		{
			type = "checkbox",
			name = fcous_loc["options_only_play_ultimate_if_in_fight"],
			tooltip = fcous_loc["options_only_play_ultimate_if_in_fight".. ttSuffix],
			getFunc = function() return FCOUSsettings.ultimateSoundOnlyInFight end,
			setFunc = function(value)
            	FCOUSsettings.ultimateSoundOnlyInFight = value
            end,
            disabled = function() return FCOUSsettings.noUltimateSound end
        },
        {
            type = "checkbox",
            name = fcous_loc["options_play_ultimate_always_on_weapon_switch"],
            tooltip = fcous_loc["options_play_ultimate_always_on_weapon_switch".. ttSuffix],
            getFunc = function() return FCOUSsettings.ultimateSoundOnWeaponSwitch end,
            setFunc = function(value)
                FCOUSsettings.ultimateSoundOnWeaponSwitch = value
            end,
            disabled = function() return FCOUSsettings.noUltimateSound end
        },
--==============================================================================
		{
        	type = 'header',
        	name = fcous_loc["options_header_sound_on_weapon_switch"],
        },

        {
            type = 'slider',
            name = fcous_loc["options_play_sound_on_weapon_switch1"],
            tooltip = fcous_loc["options_play_sound_on_weapon_switch1".. ttSuffix],
            min = 1,
            max = #FCOUS.sounds,
            getFunc = function()
                return FCOUSsettings.weaponSwitchSoundNameIndex[ACTIVE_WEAPON_PAIR_MAIN]
            end,
            setFunc = function(idx)
                local weaponPair = ACTIVE_WEAPON_PAIR_MAIN
                FCOUSsettings.weaponSwitchSoundNameIndex[weaponPair] = idx
                FCOUSsettings.weaponSwitchSoundName[weaponPair] = FCOUS.sounds[idx]
                UpdateWeaponSwitchSoundDescription(weaponPair)

                playChosenUltimateSoundFromSettings(idx)
            end,
            default = FCOUSsettings.weaponSwitchSoundNameIndex[ACTIVE_WEAPON_PAIR_MAIN],
            reference = "FCOUltimateSoundWeaponSwitchSoundBar" ..tos(ACTIVE_WEAPON_PAIR_MAIN),
        },

        {
            type = 'slider',
            name = fcous_loc["options_play_sound_on_weapon_switch2"],
            tooltip = fcous_loc["options_play_sound_on_weapon_switch2".. ttSuffix],
            min = 1,
            max = #FCOUS.sounds,
            getFunc = function()
                return FCOUSsettings.weaponSwitchSoundNameIndex[ACTIVE_WEAPON_PAIR_BACKUP]
            end,
            setFunc = function(idx)
                local weaponPair = ACTIVE_WEAPON_PAIR_BACKUP
                FCOUSsettings.weaponSwitchSoundNameIndex[weaponPair] = idx
                FCOUSsettings.weaponSwitchSoundName[weaponPair] = FCOUS.sounds[idx]
                UpdateWeaponSwitchSoundDescription(weaponPair)

                playChosenUltimateSoundFromSettings(idx)
            end,
            default = FCOUSsettings.weaponSwitchSoundNameIndex[ACTIVE_WEAPON_PAIR_BACKUP],
            reference = "FCOUltimateSoundWeaponSwitchSoundBar" ..tos(ACTIVE_WEAPON_PAIR_BACKUP),
        },

		{
			type = "checkbox",
			name = fcous_loc["options_only_play_sound_if_in_fight"],
			tooltip = fcous_loc["options_only_play_sound_if_in_fight".. ttSuffix],
			getFunc = function() return FCOUSsettings.weaponSwitchSoundOnlyInFight end,
			setFunc = function(value)
            	FCOUSsettings.weaponSwitchSoundOnlyInFight = value
            end,
            disabled = function()
            	if FCOUSsettings.weaponSwitchSoundName[ACTIVE_WEAPON_PAIR_MAIN] == CON_NONE
                        and FCOUSsettings.weaponSwitchSoundName[ACTIVE_WEAPON_PAIR_BACKUP] == CON_NONE then
                	return true
                else
                	return false
                end
            end,
        },


	} -- END OF OPTIONS TABLE

	LAM:RegisterOptionControls(addonName .. "_LAM", optionsTable)
end


--==============================================================================
--============================== END FCOUS.settingsVars.settings ==================================
--==============================================================================

local function getActiveWeaponBarAndUpdateUltimateSoundNow()
    --Get the active weapon bar
    local activeWeaponBarId, _ = GetActiveWeaponPairInfo()
--d("[FCOUS]getActiveWeaponBarAndUpdateUltimateSoundNow - activeWeaponBarId: " ..tos(activeWeaponBarId))
    if activeWeaponBarId ~= nil then
        FCOUS.preventerVars.actualWeaponBarId = activeWeaponBarId
        --Change the ultimate sound to the one selected for the current weapon bar
        FCOUltimateSound_UpdateUltimateSound(activeWeaponBarId)
    else
        --Fallback: Weapon bar is 1
        FCOUS.preventerVars.actualWeaponBarId = ACTIVE_WEAPON_PAIR_MAIN
        FCOUltimateSound_UpdateUltimateSound(ACTIVE_WEAPON_PAIR_MAIN)
    end
end


--Hook function for "Play Sound"
local function FCOUltimateSound_PlaySound_Hook(sound)
    --Ultimate ready sound = "Ability_Ultimate_Ready_Sound"

    local prevVars = FCOUS.preventerVars
--d("[FCOUltimateSound_PlaySound_Hook] sound: " ..tos(sound) .. ", forcePlay: " .. tos(prevVars.forcePlay))
    --Shall we only play a sound now without any further checks?
    if prevVars.forcePlay == true then
        FCOUS.preventerVars.forcePlay = false
        --Return false to abort prehook checks and start standard PlaySound function to just play the sound
        return false
    end

    local isDefaultUltiSoundPlayed = sound == SOUNDS[CON_ULTIMATE_READY_BACKUPED] or false

    --Is the curernt ultimate ready sound, or the "original" backuped ultimate ready sound?
    if isDefaultUltiSoundPlayed or sound == SOUNDS[CON_ULTIMATE_READY] then
        local settings = FCOUS.settingsVars.settings
       -- d("PlaySoundHook - Ultimate sound (".. sound .. "): ActiveWeaponBar " .. prevVars.actualWeaponBarId .. ", PlaySwitchSound: " .. tos(prevVars.playingUltimateSoundOnWeaponSwitch) ..
       --         ", SoundChangedInFCOUSsettings: " .. tos(prevVars.gUltimateSoundChangedInSettings) .. ", PlaySoundOnlyInFight: " .. tos(settings.ultimateSoundOnlyInFight))
        --Ultimate sound was changed in the settings? Just play it: Return false to end this prehook and call original PlaySound function
        if prevVars.gUltimateSoundChangedInSettings then
            FCOUS.preventerVars.gUltimateSoundChangedInSettings = false
            return false
        end
        --No ultimate sound enabled? Do not play sounds
        if settings.noUltimateSound then
            --d("> No ultimate sound: ABORTED")
            return true
        end
        --Play ultimate sound only in combat? Return true to "fullfill" prehook and don#t start normal PlaySound afterwards
        if settings.ultimateSoundOnlyInFight and not IsUnitInCombat(CON_PLAYER) then
            --d("> Only in fight allowed: ABORTED")
            return true
        end

        --Weapon bar was switched, ultimate is ready (Played by standard ESO) but option to play it is disabled
        local actualWeaponBarId = prevVars.actualWeaponBarId
        if prevVars.weaponSwitchedButPlayNoSound and actualWeaponBarId ~= nil and actualWeaponBarId > ACTIVE_WEAPON_PAIR_NONE and actualWeaponBarId <= ACTIVE_WEAPON_PAIR_BACKUP then
            local activeWeaponBarId, _ = GetActiveWeaponPairInfo()
            if activeWeaponBarId == prevVars.actualWeaponBarId then
                --d("> WeaponSwitchedButPlayNoSound: SAME WEAPON BAR")
                --Play sound as ultimate just got full on the same weapon bar
                return false
            end
            --d("> WeaponSwitchedButPlayNoSound: ABORTED")
            --Play no sound if disabled in the FCOUS.settingsVars.settings
            return true
        end
        --[[
        --The actual weapon bar is the same like before, it is locked and the switch to another bar is coming later?
        if not isDefaultUltiSoundPlayed and not prevVars.playingUltimateSoundOnWeaponSwitch and prevVars.activeWeaponPairLocked then
            d("> Same weapon bar: ABORTED")
            --Setting ultimate sound to NONE now to avoid play again from standard ESO
            --SOUNDS[CON_ULTIMATE_READY] = SOUNDS.NONE
            --Don't play the standard ESO ultimate sound notification here if we changed weapons and the ultimate is ready
            return true
        end
        --Playing ultimate sound at each weapon switch, if ultimate is ready?
        if prevVars.playingUltimateSoundOnWeaponSwitch then
            --Reset the variable for the play sound each time on weapon switch
            FCOUS.preventerVars.playingUltimateSoundOnWeaponSwitch = false
            --If the ultimate just got full the sound would be played twice, once form this addon and once from standard ESO source code.
            --Set the ultimate sound to NONE so the normal ultimate full sound won#t be played
            d("PlaySoundHook - Play Ultimate sound after weapon bar switch")
            --Tell the PlaySound hook to just play a sound
            --FCOUS.preventerVars.forcePlay = true
            --PlaySound(SOUNDS[CON_ULTIMATE_READY])
            --Setting ultimate sound to NONE now to avoid play again from standard ESO
            --return true
        end
        ]]

        --if the backuped ultimate ready sound tries to play update it again with the active weapon bar's sound
        if isDefaultUltiSoundPlayed then
            local activeWeaponBarId, _ = GetActiveWeaponPairInfo()
            local ultimateSoundNameAtActiveWeaponBarId = settings.ultimateSoundName[activeWeaponBarId]

            --Set the variable to force the play in PlaySounds
            FCOUS.preventerVars.forcePlay = true
            --Play the replaced sound now for the ultimate ready of the actual bar
            PlaySound(SOUNDS[ultimateSoundNameAtActiveWeaponBarId])
            return true
        end

    end
	--Return false to end this prehook and run the normal PlaySound function to play the ultimate sound now
    return false
end

--Function with the hooks
local function FCOUltimateSound_Hook_functions()
	--preHook the Play Sound function
    ZO_PreHook("PlaySound", FCOUltimateSound_PlaySound_Hook)
end

--==============================================================================
--==================== START EVENT CALLBACK FUNCTIONS===========================
--==============================================================================

-- Fires each time after addons were loaded and player is ready to move (after each zone change too)
local function FCOUltimateSound_Player_Activated(...)
	--Prevent this event to be fired again and again upon each zone change
	EM:UnregisterForEvent(addonName, EVENT_PLAYER_ACTIVATED)

    --Register callback function if the weapon bars change
    EM:RegisterForEvent(addonName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, FCOUltimateSound_ActiveWeaponPairChanged)

    --Replace the ultimate erady sound with teh one of the active weapon bar
    getActiveWeaponBarAndUpdateUltimateSoundNow()

	--Load the hooks - PlaySound hook
    FCOUltimateSound_Hook_functions()

    addonVars.gAddonLoaded = false
end

--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================

--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/fcoultimatesound"] = command_handler
	SLASH_COMMANDS["/fcous"]	 	    = command_handler
end

local function LoadSavedVariables()
    --For the default SavedVariables
    local function updateUltimateReadySoundIndex()
        for idx, soundName in pairs(FCOUS.sounds) do
            if soundName == CON_ULTIMATE_READY then
                FCOUS.ABILITY_ULTIMATE_READY_ID = idx
                return
            end
        end
    end
    updateUltimateReadySoundIndex()

    --The default values for the language and save mode
    local firstLoadSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide FCOUS.settingsVars.settings
    }

    --Pre-set the deafult values
    local defaults = {
        --language 	 		    	     = 1, --Standard: English
        --saveMode     		    	     = 2, --Standard: Account wide FCOUS.settingsVars.settings
        alwaysUseClientLanguage         = false,
        languageChoosen				    = false,
        noUltimateSound				    = false,
        ultimateSoundNameIndex		    = {
            [ACTIVE_WEAPON_PAIR_MAIN]       = FCOUS.ABILITY_ULTIMATE_READY_ID, --set in file FCOUltimateSoundSounds.lua
            [ACTIVE_WEAPON_PAIR_BACKUP]     = FCOUS.ABILITY_ULTIMATE_READY_ID,
        },
        ultimateSoundName			    = {
            [ACTIVE_WEAPON_PAIR_MAIN]       = CON_ULTIMATE_READY,
            [ACTIVE_WEAPON_PAIR_BACKUP]     = CON_ULTIMATE_READY,
        },
        weaponSwitchSoundNameIndex	    = {
            [ACTIVE_WEAPON_PAIR_MAIN]       = CON_SELECTED_SOUND_IDX_NONE,
            [ACTIVE_WEAPON_PAIR_BACKUP]     = CON_SELECTED_SOUND_IDX_NONE,
        },
        weaponSwitchSoundName		    = {
            [ACTIVE_WEAPON_PAIR_MAIN]       = CON_NONE,
            [ACTIVE_WEAPON_PAIR_BACKUP]     = CON_NONE,
        },
        ultimateSoundOnlyInFight	    = true,
        ultimateSoundOnWeaponSwitch     = true,
        soundsOnWeaponSwitch		    = false,
        weaponSwitchSoundOnlyInFight    = true,
    }


    --=============================================================================================================
    --	LOAD SAVEDVARIABLES
    --=============================================================================================================
    local worldName = GetWorldName()
    local svName = addonVars.addonSavedVariablesName
    local svVersion = addonVars.addonVersion
    local svSubtabName = "settings"

    --Load the user's FCOUS.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
    FCOUS.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(svName, 999, svSubtabName .."ForAll", firstLoadSettings, worldName)

    --Check, by help of basic version 999 FCOUS.settingsVars.settings, if the FCOUS.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCOUS.settingsVars.settings now
    if (FCOUS.settingsVars.defaultSettings.saveMode == 1) then
        FCOUS.settingsVars.settings = ZO_SavedVars:NewCharacterIdSettings(svName, svVersion , svSubtabName, defaults, worldName)
    else
        FCOUS.settingsVars.settings = ZO_SavedVars:NewAccountWide(svName, svVersion, svSubtabName, defaults, worldName)
    end
    --=============================================================================================================
end

--Addon loads up
local function FCOUltimateSound_Loaded(eventCode, addOnNameOfEachAddon)
    --Is this addon found?
    if addOnNameOfEachAddon ~= addonName then return end
    --Unregister this event again so it isn't fired again after this addon has beend reckognized
    EM:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)
    --Register for the zone change/player ready event
    EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, FCOUltimateSound_Player_Activated)

    addonVars.gAddonLoaded = false

    LoadSavedVariables()

    --Set Localization
    Localization()

    --Show the menu
    BuildAddonMenu()

    -- Register slash commands
    RegisterSlashCommands()

    -- update bar category
    g_activeHotbar = GetActiveHotbarCategory()

    addonVars.gAddonLoaded = true
end

-- Register the event "addon loaded" for this addon
local function FCOUltimateSound_Initialized()
	EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, FCOUltimateSound_Loaded)
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOUltimateSound_Initialized()


