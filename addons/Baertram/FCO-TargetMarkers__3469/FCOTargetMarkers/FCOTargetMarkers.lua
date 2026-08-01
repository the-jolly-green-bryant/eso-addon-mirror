------------------------------------------------------------------
--FCOTargetMarkers.lua
--Author: Baertram
------------------------------------------------------------------

--Global addon variable
FCOTM = {}
local FCOTM = FCOTM

--Local game global speed up variables
local CM = CALLBACK_MANAGER
local EM = EVENT_MANAGER
local iigpm = IsInGamepadPreferredMode

--Addon variables
FCOTM.addonVars                            = {}
FCOTM.addonVars.gAddonName                 = "FCOTargetMarkers"
FCOTM.addonVars.addonNameMenu              = "FCO TargetMarkers"
FCOTM.addonVars.addonNameMenuDisplay       = "|c00FF00FCO |cFFFF00TargetMarkers|r"
FCOTM.addonVars.addonAuthor                = '|cFFFF00Baertram|r'
FCOTM.addonVars.addonVersionOptions        = '0.6' -- version shown in the settings panel
FCOTM.addonVars.addonSavedVariablesName    = "FCOTargetMarkers_Settings"
FCOTM.addonVars.addonSavedVariablesVersion = 0.01 -- Changing this will reset SavedVariables!
FCOTM.addonVars.gAddonLoaded               = false
local addonVars                            = FCOTM.addonVars
local addonName                            = addonVars.gAddonName

--Libraries
-- Create the addon settings menu
local LAM = LibAddonMenu2


--Settings
FCOTM.settingsVars					= {}
FCOTM.settingsVars.settings 		= {}
FCOTM.settingsVars.defaultSettings	= {}

--Prevention booleans
FCOTM.preventerVars = {}
FCOTM.preventerVars.gLocalizationDone 					= false
FCOTM.preventerVars.gLockpickActive                  	= false
FCOTM.preventerVars.gOnLockpickChatStateWasMinimized 	= false
FCOTM.preventerVars.KeyBindingTexts 					= false


--Number variables
FCOTM.numVars = {}
--Available languages
FCOTM.numVars.languageCount = 7 --English, German, French, Spanish, Italian, Japanese, Russian
FCOTM.langVars = {}
FCOTM.langVars.languages = {}
local numVars = FCOTM.numVars
--Build the languages array
for i=1, numVars.languageCount do
	FCOTM.langVars.languages[i] = true
end

--Localization / translation
FCOTM.localizationVars = {}
FCOTM.localizationVars.FCOTM_loc = {}
local FCOTM_loc

--Uncolored "FCOTM" pre chat text for the chat output
FCOTM.preChatText = "FCOTargetMarkers"
local preChatText = FCOTM.preChatText
--Green colored "FCOTM" pre text for the chat output
FCOTM.preChatTextGreen = "|c22DD22"..preChatText.."|r "
--Red colored "FCOTM" pre text for the chat output
--FCOTM.preChatTextRed                     = "|cDD2222"..preChatText.."|r "
--Blue colored "FCOTM" pre text for the chat output
FCOTM.preChatTextBlue                    = "|c2222DD"..preChatText.."|r "
--local redText 	= FCOTM.preChatTextRed
local greenText = FCOTM.preChatTextGreen
local blueText 	= FCOTM.preChatTextBlue



local defaultTARGET_MARKER_KEYBOARD_ICON_PATHS =
{
	[TARGET_MARKER_TYPE_ONE] = "EsoUI/Art/TargetMarkers/Target_Blue_Square_64.dds",
	[TARGET_MARKER_TYPE_TWO] = "EsoUI/Art/TargetMarkers/Target_Gold_Star_64.dds",
	[TARGET_MARKER_TYPE_THREE] = "EsoUI/Art/TargetMarkers/Target_Green_Circle_64.dds",
	[TARGET_MARKER_TYPE_FOUR] = "EsoUI/Art/TargetMarkers/Target_Orange_Triangle_64.dds",
	[TARGET_MARKER_TYPE_FIVE] = "EsoUI/Art/TargetMarkers/Target_Pink_Moons_64.dds",
	[TARGET_MARKER_TYPE_SIX] = "EsoUI/Art/TargetMarkers/Target_Purple_Oblivion_64.dds",
	[TARGET_MARKER_TYPE_SEVEN] = "EsoUI/Art/TargetMarkers/Target_Red_Weapons_64.dds",
	[TARGET_MARKER_TYPE_EIGHT] = "EsoUI/Art/TargetMarkers/Target_White_Skull_64.dds",
}

local defaultTARGET_MARKER_GAMEPAD_ICON_PATHS =
{
	[TARGET_MARKER_TYPE_ONE] = "EsoUI/Art/TargetMarkers/Target_Blue_Square_64.dds",
	[TARGET_MARKER_TYPE_TWO] = "EsoUI/Art/TargetMarkers/Gamepad/Target_Gold_Star.dds",
	[TARGET_MARKER_TYPE_THREE] = "EsoUI/Art/TargetMarkers/Gamepad/Target_Green_Circle.dds",
	[TARGET_MARKER_TYPE_FOUR] = "EsoUI/Art/TargetMarkers/Gamepad/Target_Orange_Triangle.dds",
	[TARGET_MARKER_TYPE_FIVE] = "EsoUI/Art/TargetMarkers/Gamepad/Target_Pink_Moons.dds",
	[TARGET_MARKER_TYPE_SIX] = "EsoUI/Art/TargetMarkers/Gamepad/Target_Purple_Oblivion.dds",
	[TARGET_MARKER_TYPE_SEVEN] = "EsoUI/Art/TargetMarkers/Gamepad/Target_Red_Weapons.dds",
	[TARGET_MARKER_TYPE_EIGHT] = "EsoUI/Art/TargetMarkers/Gamepad/Target_White_Skull.dds",
}
local customTARGET_MARKER_KEYBOARD_ICON_PATHS, customTARGET_MARKER_GAMEPAD_ICON_PATHS


--===================== FUNCTIONS ==============================================

--Output debug message in chat
local function debugMessage(msg_text, deep)
	local settings = FCOTM.settingsVars.settings
	if deep and not settings.deepDebug then
    	return
    end
	if settings.debug == true then
    	if deep then
        	--Blue colored "FCOTargetMarkers" at the start of the string
	        d(blueText .. msg_text)
        else
        	--Green colored "FCOTargetMarkers" at the start of the string
	        d(greenText .. msg_text)
        end
	end
end

local function Localization()
--d("[FCOTM] Localization - Start, useClientLang: " .. tostring(FCOTM.settingsVars.settings.alwaysUseClientLanguage))
	--Was localization already done during keybindings? Then abort here
 	if FCOTM.preventerVars.gLocalizationDone == true then return end
    --Fallback to english variable
    local fallbackToEnglish = false
	local settingsBase = FCOTM.settingsVars
	local settings = settingsBase.settings
	local defSettings = settingsBase.defaultSettings
	local defLang = defSettings.language

	--Always use the client's language?
    if not settings.alwaysUseClientLanguage then
		--Was a language chosen already?
	    if not settings.languageChosen then
--d("[FCOTM] Localization: Fallback to english. Language chosen: " .. tostring(FCOTM.settingsVars.settings.languageChosen) .. ", defaultLanguage: " .. tostring(FCOTM.settingsVars.defaultSettings.language))
			if defLang == nil then
--d("[FCOTM] Localization: defaultSettings.language is NIL -> Fallback to english now")
		    	fallbackToEnglish = true
		    else
				local languages = FCOTM.langVars.languages
				--Is the languages array filled and the language is not valid (not in the language array with the value "true")?
				if languages ~= nil and #languages > 0 and not languages[defLang] then
		        	fallbackToEnglish = true
--d("[FCOTM] Localization: defaultSettings.language is ~= " .. i .. ", and this language # is not valid -> Fallback to english now")
				end
		    end
		end
	end
--d("[FCOTM] localization, fallBackToEnglish: " .. tostring(fallbackToEnglish))
	--Fallback to english language now
    if (fallbackToEnglish) then
		FCOTM.settingsVars.defaultSettings.language = 1
		defLang = FCOTM.settingsVars.defaultSettings.language
	end
	--Is the standard language english set?
    if settings.alwaysUseClientLanguage or (defLang == 1 and not settings.languageChosen) then
--d("[FCOTM] localization: Language chosen is false or always use client language is true!")
		local lang = GetCVar("language.2")
		--Check for supported languages
		if(lang == "de") then
	    	FCOTM.settingsVars.defaultSettings.language = 2
	    elseif (lang == "en") then
	    	FCOTM.settingsVars.defaultSettings.language = 1
	    elseif (lang == "fr") then
	    	FCOTM.settingsVars.defaultSettings.language = 3
	    elseif (lang == "es") then
	    	FCOTM.settingsVars.defaultSettings.language = 4
	    elseif (lang == "it") then
	    	FCOTM.settingsVars.defaultSettings.language = 5
	    elseif (lang == "jp") then
	    	FCOTM.settingsVars.defaultSettings.language = 6
	    elseif (lang == "ru") then
	    	FCOTM.settingsVars.defaultSettings.language = 7
		else
	    	FCOTM.settingsVars.defaultSettings.language = 1
	    end
	end
--d("[FCOTM] localization: default settings, language: " .. tostring(FCOTM.settingsVars.defaultSettings.language))
    --Get the localized texts from the localization file
    FCOTM.localizationVars.FCOTM_loc = FCOTM.localizationVars.localizationAll[FCOTM.settingsVars.defaultSettings.language]
	FCOTM_loc = FCOTM.localizationVars.FCOTM_loc
end

--Show a help inside the chat
local function help()
	d(FCOTM_loc["chatcommands_info"])
	d("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
	d(FCOTM_loc["chatcommands_help"])
    d(FCOTM_loc["chatcommands_debug"])
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
		local settings = FCOTM.settingsVars.settings
		if options[1] == "debug" then
			FCOTM.settingsVars.settings.debug = not FCOTM.settingsVars.settings.debug
			if settings.debug == true then
				d(FCOTM_loc["chatcommands_debug_on"])
			else
				FCOTM.settingsVars.settings.deepDebug = false
				d(FCOTM_loc["chatcommands_debug_off"])
			end
		elseif options[1] == "deepdebug" then
			FCOTM.settingsVars.settings.deepDebug = not FCOTM.settingsVars.settings.deepDebug
			if settings.deepDebug == true then
				FCOTM.settingsVars.settings.debug = true
				d(FCOTM_loc["chatcommands_deepdebug_on"])
			else
				FCOTM.settingsVars.settings.debug = false
				d(FCOTM_loc["chatcommands_deepdebug_off"])
			end
		end
	end
end

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
		slashCommand = "/fcotms",
	}

-- !!! RU Patch Section START
--  Add english language description behind language descriptions in other languages
	local function nvl(val) if val == nil then return "..." end return val end
	local LV_Cur = FCOTM_loc
	local LV_Eng = FCOTM.localizationVars.localizationAll[1]
	local languageOptions = {}
	local languageOptionsValues = {}
	for i=1, numVars.languageCount do
		local s="options_language_dropdown_selection"..i
		if LV_Cur==LV_Eng then
			languageOptions[i] = nvl(LV_Cur[s])
		else
			languageOptions[i] = nvl(LV_Cur[s]) .. " (" .. nvl(LV_Eng[s]) .. ")"
		end
		languageOptionsValues[i] = i
	end
-- !!! RU Patch Section END

    local savedVariablesOptions = {
    	[1] = FCOTM_loc["options_savedVariables_dropdown_selection1"],
        [2] = FCOTM_loc["options_savedVariables_dropdown_selection2"],
    }
    local savedVariablesOptionsValues = {
		[1] = 1,
		[2] = 2,
	}

	local settings = FCOTM.settingsVars.settings
	local defaultSettings = FCOTM.settingsVars.defaults

	FCOTM.SettingsPanel = LAM:RegisterAddonPanel(addonName, panelData)

	local function UpdateChamberStressedSoundDescription()
		--New ultimate sound 1
		--FCOTargetMarkersChamberHeader.header:SetFont("ZoFontGameSmall")
		--FCOTargetMarkersChamberHeader.header:SetText(FCOTM_loc["options_chamber_stressed_sound"] .. ": " .. FCOTM.sounds[settings.chamberStressedSound])
		--FCOTargetMarkersChamberHeader.data.name = FCOTM_loc["options_chamber_stressed_sound"] .. ": " .. FCOTM.sounds[settings.chamberStressedSound]
		--FCOTargetMarkersChamberHeader:UpdateValue()
    end

--LAM 2.0 callback function if the panel was created
    local FCOLAMPanelCreated
	FCOLAMPanelCreated = function(panel)
        if panel ~= FCOTM.SettingsPanel then return end
        UpdateChamberStressedSoundDescription()
    end

	local optionsTable =
    {	-- BEGIN OF OPTIONS TABLE

		{
			type = 'description',
			text = FCOTM_loc["options_description"],
		},
--==============================================================================
		{
        	type = 'header',
        	name = FCOTM_loc["options_header1"],
        },
		{
			type = 'dropdown',
			name = FCOTM_loc["options_language"],
			tooltip = FCOTM_loc["options_language_tooltip"],
			choices = languageOptions,
            choicesValues = languageOptionsValues,
			getFunc = function() return FCOTM.settingsVars.defaultSettings.language end,
            setFunc = function(value)
                --[[
				for i,v in pairs(languageOptions) do
                    if v == value then
                        debugMessage("[Settings language] v: " .. tostring(v) .. ", i: " .. tostring(i), false)
                    	FCOTM.settingsVars.defaultSettings.language = i
                        --Tell the FCOTM.settingsVars.settings that you have manually chosen the language and want to keep it
                        --Read in function Localization() after ReloadUI()
                        settings.languageChoosen = true
						--FCOTM_loc			  	 = FCOTM_loc[i]
                        ReloadUI()
                    end
                end
                ]]
				FCOTM.settingsVars.defaultSettings.language = value
				--Tell the FCOTM.settingsVars.settings that you have manually chosen the language and want to keep it
				--Read in function Localization() after ReloadUI()
				settings.languageChoosen = true
				--FCOTM_loc			  	 = FCOTM_loc[i]
				ReloadUI()
            end,
           disabled = function() return settings.alwaysUseClientLanguage end,
           warning = FCOTM_loc["options_language_description1"],
           requiresReload = true,
        },
		{
			type = "checkbox",
			name = FCOTM_loc["options_language_use_client"],
			tooltip = FCOTM_loc["options_language_use_client_tooltip"],
			getFunc = function() return settings.alwaysUseClientLanguage end,
			setFunc = function(value)
				settings.alwaysUseClientLanguage = value
                      --ReloadUI()
		            end,
            default = defaultSettings.alwaysUseClientLanguage,
            warning = FCOTM_loc["options_language_description1"],
            requiresReload = true,
		},
		{
			type = 'dropdown',
			name = FCOTM_loc["options_savedvariables"],
			tooltip = FCOTM_loc["options_savedvariables_tooltip"],
			choices = savedVariablesOptions,
			choicesValues = savedVariablesOptionsValues,
            getFunc = function() return FCOTM.settingsVars.defaultSettings.saveMode end,
            setFunc = function(value)
                --[[
				for i,v in pairs(savedVariablesOptions) do
                    if v == value then
                        debugMessage("[Settings save mode] v: " .. tostring(v) .. ", i: " .. tostring(i), false)
                        FCOTM.settingsVars.defaultSettings.saveMode = i
                        ReloadUI()
                    end
                end
                ]]
				FCOTM.settingsVars.defaultSettings.saveMode = value
				ReloadUI()
            end,
            warning = FCOTM_loc["options_language_description1"],
		},
-------------------------------------------------------------------------------------------------
		{
        	type = 'header',
        	name = FCOTM_loc["options_header_settings_group"],
        },
		{
			type = "checkbox",
			name = FCOTM_loc["options_block_markers_if_grouped_and_no_leader"],
			tooltip = FCOTM_loc["options_block_markers_if_grouped_and_no_leader_TT"],
			getFunc = function() return settings.blockMarkersIfGroupedAndNoLeader end,
			setFunc = function(value)
				settings.blockMarkersIfGroupedAndNoLeader = value
			end,
            default = defaultSettings.blockMarkersIfGroupedAndNoLeader,
		},
		{
			type = "checkbox",
			name = FCOTM_loc["options_change_unit_frame_target_marker_size"],
			tooltip = FCOTM_loc["options_change_unit_frame_target_marker_size_TT"],
			getFunc = function() return settings.changeGroupUnitFrameTargetMarkerSize end,
			setFunc = function(value)
				settings.changeGroupUnitFrameTargetMarkerSize = value
			end,
            default = defaultSettings.changeGroupUnitFrameTargetMarkerSize,
		},
		{
			type = "slider",
			min = 8,
			max = 50,
			step = 2,
			name = FCOTM_loc["options_target_marker_size"],
			tooltip = FCOTM_loc["options_target_marker_size_TT"],
			getFunc = function() return settings.newGroupUnitFrameTargetMarkerSize end,
			setFunc = function(value)
				settings.newGroupUnitFrameTargetMarkerSize = value
			end,
			disabled = function() return not settings.changeGroupUnitFrameTargetMarkerSize end,
			default = defaultSettings.newGroupUnitFrameTargetMarkerSize,
		},
-------------------------------------------------------------------------------------------------
		{
        	type = 'header',
        	name = FCOTM_loc["options_header_settings_unitframes"],
        },
		{
			type = "checkbox",
			name = FCOTM_loc["options_change_unit_frame_target_marker_size"],
			tooltip = FCOTM_loc["options_change_unit_frame_target_marker_size_TT"],
			getFunc = function() return settings.changeUnitFrameTargetMarkerSize end,
			setFunc = function(value)
				settings.changeUnitFrameTargetMarkerSize = value
			end,
            default = defaultSettings.changeUnitFrameTargetMarkerSize,
		},
		{
			type = "slider",
			min = 8,
			max = 80,
			step = 2,
			name = FCOTM_loc["options_target_marker_size"],
			tooltip = FCOTM_loc["options_target_marker_size_TT"],
			getFunc = function() return settings.newUnitFrameTargetMarkerSize end,
			setFunc = function(value)
				settings.newUnitFrameTargetMarkerSize = value
			end,
			disabled = function() return not settings.changeUnitFrameTargetMarkerSize end,
			default = defaultSettings.newUnitFrameTargetMarkerSize,
		},
	} -- END OF OPTIONS TABLE

	--CM:RegisterCallback("LAM-PanelControlsCreated", FCOLAMPanelCreated)
	LAM:RegisterOptionControls(addonName, optionsTable)
end

--==============================================================================
--============================== END SETTINGS ==================================
--==============================================================================

--Check for other addons and react on them
--[[
local function CheckIfOtherAddonsActive()
	return false
end
]]

local function isGroupLeaderCheck()
	local settings = FCOTM.settingsVars.settings
	if not settings.blockMarkersIfGroupedAndNoLeader then return false end
	if IsUnitGrouped("player") then
		if IsUnitGroupLeader("player") == false then
			return true
		else
			return false
		end
	else
		return false
	end
	return false
end


local function assignCustomTargetMarkerIcons()
	customTARGET_MARKER_KEYBOARD_ICON_PATHS = 	ZO_ShallowTableCopy(defaultTARGET_MARKER_KEYBOARD_ICON_PATHS)
	customTARGET_MARKER_GAMEPAD_ICON_PATHS = 	ZO_ShallowTableCopy(defaultTARGET_MARKER_GAMEPAD_ICON_PATHS)

	--Redirect a few textures to new ones
	-->Logout and delete file live/shader_cache.cooked if icons wont change ingame!
	--[[
	for targetMarkerIndex, targetMarkerDefaulTexturePath in ipairs(defaultTARGET_MARKER_KEYBOARD_ICON_PATHS) do
		--Replace keyboard with gamepad textures e.g.
		RedirectTexture(targetMarkerDefaulTexturePath, defaultTARGET_MARKER_GAMEPAD_ICON_PATHS[targetMarkerIndex])
	end
	]]
end

--Remove all markers on all units, by applying them to ourself.
--Only works if currently no target is selected and the unit below the reticle will not change
function FCOTM.RemoveAllTargetMarkers()
	local aborted = false
	if isGroupLeaderCheck() then return end
	if IsInteractionCameraActive() then
		--d("<IsInteractionCameraActive")
		return
	end
	if IsGameCameraUnitHighlightedAttackable() then
		--d("<IsGameCameraUnitHighlightedAttackable")
		return
	end
	if IsGameCameraPreferredTargetValid() then
		--d("<IsGameCameraPreferredTargetValid")
		return
	end

	local playerName = GetUnitName("player")
	local unitName = GetUnitNameHighlightedByReticle()
	--d(">unitName: " ..tostring(unitName) .. ", playerName: " .. tostring(playerName))

	local iconsTable = GetPlatformTargetMarkerIconTable()
	local numIcons = #iconsTable
	for iconIndex=1, numIcons, 1 do
		--The unit below the reticle did not change?
		local unitNameNow = GetUnitNameHighlightedByReticle()
		if unitNameNow == unitName then
			--Assign all icons to the unit, after nother, so they will be removed from other units
			AssignTargetMarkerToReticleTarget(iconIndex)
		else
			aborted = true
		end
	end
	if not aborted then
		--Assign the last marker icon to the unitName now if it's not the player
		if unitName ~= nil and unitName ~= "" and unitName ~= playerName then
			--Remove the last target marker icon again, as it was set
			AssignTargetMarkerToReticleTarget(TARGET_MARKER_TYPE_EIGHT)
		end
	end
	--Check if any marker icon is active at the player
	local targetMarkerType = GetUnitTargetMarkerType("player")
	--Unmark the currently marked one
	if targetMarkerType ~= TARGET_MARKER_TYPE_NONE then
		AssignTargetMarkerToReticleTarget(targetMarkerType)
	end
end


function FCOTM.ToggleTargetMarker(iconIndex, toYourself)
	toYourself = toYourself or false
	if isGroupLeaderCheck() then return end
	--This will only assign the target marker on ourselves!
	if toYourself == true then
		AssignTargetMarkerToReticleTarget(iconIndex)
	else
		--Simualate the TAB press to show the selection wheel and then assign the icon
		TARGET_MARKERS:StartInteraction()
		AssignTargetMarkerToReticleTarget(iconIndex)
		TARGET_MARKERS:StopInteraction()
	end
end
--==============================================================================
--==================== START EVENT CALLBACK FUNCTIONS===========================
--==============================================================================


--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================

--Create the hooks & pre-hooks
local function CreateHooks()
	assignCustomTargetMarkerIcons()

	function GetPlatformTargetMarkerIcon(targetMarker)
		if targetMarker then
			if iigpm() then
				return customTARGET_MARKER_GAMEPAD_ICON_PATHS[targetMarker]
			else
				return customTARGET_MARKER_KEYBOARD_ICON_PATHS[targetMarker]
			end
		end
	end

	function GetPlatformTargetMarkerIconTable()
		return iigpm() and customTARGET_MARKER_GAMEPAD_ICON_PATHS or customTARGET_MARKER_KEYBOARD_ICON_PATHS
	end

	ZO_PreHook("AssignTargetMarkerToReticleTarget", function(iconIndex)
		return isGroupLeaderCheck()
	end)
	ZO_PreHook(TARGET_MARKER_WHEEL_KEYBOARD, "StartInteraction", function()
		return isGroupLeaderCheck()
	end)
	ZO_PreHook(TARGET_MARKER_WHEEL_KEYBOARD, "PrepareForInteraction", function()
		return isGroupLeaderCheck()
	end)

	function TARGET_MARKER_WHEEL_KEYBOARD:PopulateMenu()
		--local icons = IsInGamepadPreferredMode() and TARGET_MARKER_ICONS_GAMEPAD or TARGET_MARKER_ICONS_KEYBOARD
		for iconIndex, iconPath in ipairs(GetPlatformTargetMarkerIconTable()) do
			TARGET_MARKER_WHEEL_KEYBOARD.menu:AddEntry("", iconPath, iconPath, function() AssignTargetMarkerToReticleTarget(iconIndex) end, iconIndex)
		end
	end


	--UNIT_FRAMES objects
	local GROUP_UNIT_FRAME = "ZO_GroupUnitFrame"
	local COMPANION_UNIT_FRAME = "ZO_CompanionUnitFrame"
	local RAID_UNIT_FRAME = "ZO_RaidUnitFrame"
	local COMPANION_RAID_UNIT_FRAME = "ZO_CompanionRaidUnitFrame"
	local TARGET_UNIT_FRAME = "ZO_TargetUnitFrame"
	local COMPANION_GROUP_UNIT_FRAME = "ZO_CompanionGroupUnitFrame"

	function ZO_UnitFrameObject:UpdateName()
		local selfVar = self
		if selfVar.nameLabel then
			local settings = FCOTM.settingsVars.settings
			if not settings.changeUnitFrameTargetMarkerSize
				and not settings.changeGroupUnitFrameTargetMarkerSize then return false end


			local name
			local tag = selfVar.unitTag
			local style = selfVar.style
			local pendingCompanionName
			local isCompanionTag = (tag == "companion" and true) or false
			if isCompanionTag == true and HasPendingCompanion() then
				pendingCompanionName = GetCompanionName(GetPendingCompanionDefId())
				name = zo_strformat(SI_COMPANION_NAME_FORMATTER, pendingCompanionName)
			elseif IsGroupCompanionUnitTag(tag) then
				local playerGroupTag = GetLocalPlayerGroupUnitTag()
				local playerCompanionTag = GetCompanionUnitTagByGroupUnitTag(playerGroupTag)
				if playerCompanionTag == tag and HasPendingCompanion() then
					pendingCompanionName = GetCompanionName(GetPendingCompanionDefId())
					name = zo_strformat(SI_COMPANION_NAME_FORMATTER, pendingCompanionName)
				else
					if style == COMPANION_GROUP_UNIT_FRAME and playerCompanionTag ~= tag then
						name = GetString(SI_UNIT_FRAME_NAME_COMPANION)
					else
						name = GetUnitName(tag)
					end
				end
			elseif IsUnitPlayer(tag) then
				name = ZO_GetPrimaryPlayerNameFromUnitTag(tag)
			else
				name = GetUnitName(tag)
			end

			local nameText
			local targetMarkerType = GetUnitTargetMarkerType(tag)
			if targetMarkerType ~= TARGET_MARKER_TYPE_NONE then
				local iconPath = GetPlatformTargetMarkerIcon(targetMarkerType)
				if style == TARGET_UNIT_FRAME then
					nameText = zo_iconTextFormatNoSpaceAlignedRight(iconPath, settings.newUnitFrameTargetMarkerSize, settings.newUnitFrameTargetMarkerSize, name)
				else
					nameText = zo_iconTextFormatNoSpace(iconPath, settings.newGroupUnitFrameTargetMarkerSize, settings.newGroupUnitFrameTargetMarkerSize, name)
				end
			else
				nameText = name
			end
			selfVar.nameLabel:SetText(nameText)
		end
	end
end

--Global function to get text for the keybindings etc.
function FCOTM.GetKeybindLocText(textName, isKeybindingText)
	isKeybindingText = isKeybindingText or false

    FCOTM.preventerVars.KeyBindingTexts = isKeybindingText

	--Do the localization now
   	Localization()

	if textName == nil or FCOTM_loc == nil or FCOTM_loc[textName] == nil then return "" end
   	return FCOTM_loc[textName]
end


--Register the slash commands
local function RegisterSlashCommands()
    -- Register slash commands
	SLASH_COMMANDS["/FCOTargetMarkers"] = command_handler
	SLASH_COMMANDS["/fcotm"] 		 	= command_handler
end

--Load the SavedVariables
local function LoadUserSettings()
--The default values for the language and save mode
    FCOTM.settingsVars.firstRunSettings = {
        language 	 		    = 1, --Standard: English
        saveMode     		    = 2, --Standard: Account wide FCOTM.settingsVars.settings
    }

    --Pre-set the deafult values
    FCOTM.settingsVars.defaults = {
		alwaysUseClientLanguage		= true,
        languageChoosen				= false,
        debug						= false,
        deepDebug					= false,
		--Group
		blockMarkersIfGroupedAndNoLeader = true,
		--Unit frames
		changeUnitFrameTargetMarkerSize = false,
		newUnitFrameTargetMarkerSize = 20,
		changeGroupUnitFrameTargetMarkerSize = false,
		newGroupUnitFrameTargetMarkerSize = 20,
    }
	local defaults = FCOTM.settingsVars.defaults

	local worldName = GetWorldName()
	local addonSavedVariablesName = addonVars.addonSavedVariablesName
	local addonSavedVariablesVersion = addonVars.addonSavedVariablesVersion

--=============================================================================================================
--	LOAD USER SETTINGS
--=============================================================================================================
    --Load the user's FCOTM.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
	FCOTM.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, 999, "SettingsForAll", FCOTM.settingsVars.firstRunSettings, worldName)

	--Check, by help of basic version 999 FCOTM.settingsVars.settings, if the FCOTM.settingsVars.settings should be loaded for each character or account wide
    --Use the current addon version to read the FCOTM.settingsVars.settings now
	if (FCOTM.settingsVars.defaultSettings.saveMode == 1) then
    	FCOTM.settingsVars.settings = ZO_SavedVars:NewCharacterId(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName)
	else
		FCOTM.settingsVars.settings = ZO_SavedVars:NewAccountWide(addonSavedVariablesName, addonSavedVariablesVersion, "Settings", defaults, worldName, nil)
	end
--=============================================================================================================
end

--Addon loads up
local function FCOTargetMarkers_Loaded(eventCode, addOnNameOfEachAddonLoaded)
    --Is this addon found?
    if addOnNameOfEachAddonLoaded ~= addonName then return end
    --Unregister this event again so it isn't fired again after this addon has beend reckognized
    EM:UnregisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
    --Do not load with API version too low
    if GetAPIVersion() < 101036 or TARGET_MARKER_WHEEL_KEYBOARD == nil then return end

    debugMessage("[Addon loading begins...]", true)
    addonVars.gAddonLoaded = false

    --SavedVariables
    LoadUserSettings()

    -- Set Localization
    Localization()

    --Show the menu
    BuildAddonMenu()

    --Create the hooks
    CreateHooks()

    -- Register slash commands
    RegisterSlashCommands()

    debugMessage("[Addon loading finished. Have fun!]", true)
    addonVars.gAddonLoaded = true
end

-- Register the event "addon loaded" for this addon
local function FCOTargetMarkers_Initialized()
	EM:RegisterForEvent(addonName .. "_EVENT_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, FCOTargetMarkers_Loaded)
end


--------------------------------------------------------------------------------
--- Call the start function for this addon to register events etc.
--------------------------------------------------------------------------------
FCOTargetMarkers_Initialized()
