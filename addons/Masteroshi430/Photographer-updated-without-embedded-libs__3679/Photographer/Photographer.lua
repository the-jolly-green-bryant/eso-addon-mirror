local Addon = {
	Name 			= "Photographer",
	Version 		= "2026.07.09",
	Author			= "Darkretailer, |c3CB371@Masteroshi430|r",
	SavedVars		= "",
	PanelData		= "",
	OptionsTable    = "",
	Debug			= false
}

if (string.lower(UndecorateDisplayName(GetDisplayName())) ~= string.lower(Addon.Author)) then
	Addon.Debug		= false
end

-- Initialisierung diverser Variablen
local photographer_hidden_UI = false
local gui_hidden = false
local target_markers = false
local textPrefix = "|cFFFFFF[Photographer]|r "

-- Localize frequently-used globals as upvalues (faster than global table lookups,
-- and avoids repeated _G indexing every time these are called from event handlers)
local GetSetting = GetSetting
local SetSetting = SetSetting
local SetFloatingMarkerGlobalAlpha = SetFloatingMarkerGlobalAlpha
local ToggleShowIngameGui = ToggleShowIngameGui
local SetGameCameraUIMode = SetGameCameraUIMode
local TakeScreenshot = TakeScreenshot
local zo_callLater = zo_callLater
local d = d

-- Cache the player's own name once instead of recomputing it on every
-- EVENT_LEVEL_UPDATE (UndecorateDisplayName/GetDisplayName/string.lower were
-- previously being called on every level-up event in the game, for every unit)
local playerNameLower = string.lower(UndecorateDisplayName(GetDisplayName()))

-- Liste der auszublendenden Elemente (local: avoids polluting the global
-- namespace and avoids global-table lookups every time it's iterated)
local usersettings_memory = {        
    [1] = {
        SettingsType = SETTING_TYPE_UI,
        Settings = UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS
    },
    [2] = {
        SettingsType = SETTING_TYPE_IN_WORLD,
        Settings = IN_WORLD_UI_SETTING_TARGET_GLOW_ENABLED            
    },
    [3] = {
        SettingsType = SETTING_TYPE_IN_WORLD,
        Settings = IN_WORLD_UI_SETTING_INTERACTABLE_GLOW_ENABLED            
    },
    [4] = {
        SettingsType = SETTING_TYPE_NAMEPLATES,
        Settings = NAMEPLATE_TYPE_ALLIANCE_INDICATORS            
    },
    [5] = {
        SettingsType = SETTING_TYPE_NAMEPLATES,
        Settings = NAMEPLATE_TYPE_FOLLOWER_INDICATORS            
    },
    [6] = {
        SettingsType = SETTING_TYPE_NAMEPLATES,
        Settings = NAMEPLATE_TYPE_GROUP_INDICATORS            
    },
    [7] = {
        SettingsType = SETTING_TYPE_NAMEPLATES,
        Settings = NAMEPLATE_TYPE_ALL_HEALTHBARS            
    },
    [8] = {
        SettingsType = SETTING_TYPE_NAMEPLATES,
        Settings = NAMEPLATE_TYPE_ALL_NAMEPLATES            
    },
    [9] = {
        SettingsType = SETTING_TYPE_NAMEPLATES,
        Settings = NAMEPLATE_TYPE_RESURRECT_INDICATORS            
    },
}



local text = {

	-- Informationen bezüglich der Version	
	versionInfo                                 = Addon.Name .. "-Version " .. Addon.Version .. " is started the first time. Please check you Keybindings and the new Options: ESC > Settings > Addons > Photographer",
	
	-- Men�-Texte
	general                                     = "General",
	events                                      = "Events",
	events_description                          = "Take screenshots automatically",
	events_choice_no                            = "No",
	events_choice_withoutUI                     = "Yes, without UI",
	events_choice_withUI                        = "Yes, with UI",
	events_quest_received                       = "Quest received",
	events_quest_solved                         = "Quest solved",
	events_level_up                             = "Level UP",
	events_achievement                          = "Gotta Achievement",
	events_raid_trial_complete                  = "Raid trial completed",
	
	-- CommandToTakeScreenshot
	ctts_description                            = "Command to take Screenshot",
	ctts_tooltip                                = "Use your Command to take a Screenshot alway made by TESO and Saved to your Save-Path from TESO",
	
	-- TamrielTime als Zeitstempel
	tt_description                              = "Use TamrielTime as TimeStamp",
	tt_tooltip                                  = "Use TamrielTime as TimeStamp. TamrielTime is another Plugin, which have to be installed to use this function.",
	tt_not_installed                            = "Please install the Plugin 'TamrielTime' to show a TimeStamp in the Screenshots!",
	
	-- Erklärungen innerhalb der Tastatureinstellungen
	description                                 = "Screenshot without UserInteface",
	uet_description                             = "Your Key for extern Screenshot-Tool (Steam)",
	ui_toggle_description                       = "Hide UI completely",
	
	-- Feedback gegenüber dem Benutzer
	feedback                                    = "Info in chatbox",
	feedback_none                               = "None",
	feedback_short                              = "Short",
	feedback_full                               = "Full with path",
	feedback_message                            = "Screenshot was created!",
	feedback_ex                                 = "User interface has been hidden for external Screenshot tool!",
	feedback_save                               = "The Screenshot was saved to:",
}
if ( GetCVar("language.2") == "de" ) then	

	-- Informationen bezüglich der Version		
	text.versionInfo                            = Addon.Name .. "-Version " .. Addon.Version .. " wurde das erste Mal gestartet. Bitte prüfe die Tastatureinstellungen und die neuen Optionen unter: ESC > Einstellungen > Erweiterungen > Photographer"
	
	-- Menü-Texte
	text.general                                = "Allgemein"	
	text.events                                 = "Events"
	text.events_description                     = "Erstelle automatische Screenshots"
	text.events_choice_no                       = "Nein"
	text.events_choice_withoutUI                = "Ja, ohne Userinterface"
	text.events_choice_withUI                   = "Ja, mit Userinterface"
	text.events_quest_received                  = "Quest erhalten"
	text.events_quest_solved                    = "Quest abgeschlossen"
	text.events_level_up                        = "Level UP"
	text.events_achievement                     = "Errungenschaft erhalten"
	text.events_raid_trial_complete             = "Pruefung abgeschlossen"
	
	-- CommandToTakeScreenshot
	text.ctts_description                       = "Befehl um einen Screenshot zu erstellen"
	text.ctts_tooltip                           = "Verwende deinen Befehl um einen Screenshot zu machen. Dieser wird immer von TESO selbst erstellt und im Ordner von TESO abgespeichert."
		
	-- TamrielTime als Zeitstempel
	text.tt_description                         = "Verwende TamrielTime als Zeitstempel"
	text.tt_tooltip                             = "Verwende TamrielTime als Zeitstempel in den Screenshots. Dazu muss das Plugin 'TamrielTime' installiert sein."
	text.tt_not_installed                       = "Bitte installiere das Plugin 'TamrielTime' um einen TimeStamp zu verwenden!"
	
	-- Erklärungen innerhalb der Tastatureinstellungen
	text.description                            = "Screenshot ohne Userinteface"
	text.uet_description                        = "Taste fuer externes Screenshot-Tool (Steam)"
	text.ui_toggle_description                  = "Userinterface vollständig ausblenden"

	-- Feedback gegenüber dem Benutzer
	text.feedback                               = "Info in Chatbox"
	text.feedback_none                          = "Keine"
	text.feedback_short                         = "Kurze Information"
	text.feedback_full                          = "Information mit Pfad"
	text.feedback_message                       = "Screenshot wurde erstellt!"
	text.feedback_ex                            = "Benutzeroberflaeche wurde fuer externes Screenshot-Tool ausgeblendet!"
	text.feedback_save                          = "Der Screenshot wurde gespeichert unter:"	
	
end	


function Photographer_OnInitialized(eventCode, addOnName)
	if (addOnName ~= Addon.Name) then return end
	
	-- Lade Library
	local LAM = LibAddonMenu2

	-- Standard-Einstellungen
	local defaults = {
		CurrentVersion = "0.0",
		FeedbackInChatbox = text.feedback_full,
		CommandToTakeScreenshot = "/x",
		UseTamrielTimeAsTimeStamp = false,
		event_quest_received = text.events_choice_withoutUI,
		event_quest_solved = text.events_choice_withoutUI,		
		event_levelup = text.events_choice_withUI,
		event_achievement = text.events_choice_withUI,
		event_raidtrialcompleted = text.events_choice_withUI,
		useCharacterIdSettings = false
    }
	
	
	Addon.SavedVarsAccountWide = ZO_SavedVars:NewAccountWide(Addon.Name .. "SavedVars", 2, nil, defaults)
	Addon.SavedVarsCharacterId = ZO_SavedVars:NewCharacterIdSettings(Addon.Name .. "SavedVars", 2, nil, defaults)
	
	if Addon.SavedVarsAccountWide.useCharacterIdSettings then
	     Addon.SavedVars = Addon.SavedVarsCharacterId   
	else
        Addon.SavedVars = Addon.SavedVarsAccountWide	
	end     
	
	-- Erstelle das Menü für die Einstellungen
	Addon.PanelData = {
			type = "panel",
			name = Addon.Name,
			displayName = Addon.Name,
			author = Addon.Author,
			version = Addon.Version,
			registerForRefresh = true,
			registerForDefaults = true
		}
	LAM:RegisterAddonPanel(Addon.Name, Addon.PanelData)
	
	-- Shared choice list for all four event dropdowns below (previously five
	-- separate but identical tables were allocated)
	local eventChoices = {text.events_choice_no, text.events_choice_withoutUI, text.events_choice_withUI}
	
	Addon.OptionsTable = {
		[1] = {
				type = "header",
				name = text.general,
				width = "full"
		},
	    [2] = { 
		        type = "checkbox", 
				name = GetString(SI_COLLECTIBLE_ACTION_USE).." "..GetString(SI_BINDING_NAME_TOGGLE_CHARACTER).." "..GetString(SI_CUSTOMERSERVICESUBMITFEEDBACKSUBCATEGORIES1305),
			    getFunc = function() return Addon.SavedVarsAccountWide.useCharacterIdSettings end,
			    setFunc = function(value) Addon.SavedVarsAccountWide.useCharacterIdSettings = value
				                            if Addon.SavedVarsAccountWide.useCharacterIdSettings then
												 Addon.SavedVars = Addon.SavedVarsCharacterId   
											else
												Addon.SavedVars = Addon.SavedVarsAccountWide	
											end
	                      end,
			    width = "full",	
			},
		[3] = {
				type = "dropdown",
				name = text.feedback,				
				choices = {text.feedback_none, text.feedback_short, text.feedback_full},
				getFunc = function() return Addon.SavedVars.FeedbackInChatbox end,
				setFunc = function(value) Addon.SavedVars.FeedbackInChatbox = value end
		},
		[4] = {
				type = "editbox",				
				name = text.ctts_description,
				tooltip = text.ctts_tooltip,
				getFunc = function() return Addon.SavedVars.CommandToTakeScreenshot end,
				setFunc = function(value)
					SLASH_COMMANDS[Addon.SavedVars.CommandToTakeScreenshot] = nil
					Addon.SavedVars.CommandToTakeScreenshot = value
					SLASH_COMMANDS[value] = photographer_screenshot_intern
				end,
				width = "full",
				isMultiline = false
		},
		[5] = {
				type = "description",
				text = text.tt_not_installed
		},
		[6] = {
				type = "header",
				name = text.events,
				width = "full"
		},
		[7] = {
				type = "description",
				text = text.events_description
		},
		[8] = {
				type = "dropdown",
				name = text.events_quest_received,				
				choices = eventChoices,
				getFunc = function() return Addon.SavedVars.event_quest_received end,
				setFunc = function(value) Addon.SavedVars.event_quest_received = value end
		},
		[9] = {
				type = "dropdown",
				name = text.events_quest_solved,				
				choices = eventChoices,
				getFunc = function() return Addon.SavedVars.event_quest_solved end,
				setFunc = function(value) Addon.SavedVars.event_quest_solved = value end
		},
		[10] = {
				type = "dropdown",
				name = text.events_level_up,				
				choices = eventChoices,
				getFunc = function() return Addon.SavedVars.event_levelup end,
				setFunc = function(value) Addon.SavedVars.event_levelup = value end
		},
		[11] = {
				type = "dropdown",
				name = text.events_achievement,				
				choices = eventChoices,
				getFunc = function() return Addon.SavedVars.event_achievement end,
				setFunc = function(value) Addon.SavedVars.event_achievement = value end
		},
		[12] = {
			type = "dropdown",
			name = text.events_raid_trial_complete,       
			choices = eventChoices,
			getFunc = function() return Addon.SavedVars.event_raidtrialcompleted end,
			setFunc = function(value) Addon.SavedVars.event_raidtrialcompleted = value end
		},
	}	
	if not (SLASH_COMMANDS["/ttforceshow"] == nil) then
		-- Checkbox für "Tamriel-Time als TimeStamp"
		Addon.OptionsTable[5] = {
		type = "checkbox",
		name = text.tt_description,
		tooltip = text.tt_tooltip,
		getFunc = function() return Addon.SavedVars.UseTamrielTimeAsTimeStamp end,
		setFunc = function() Addon.SavedVars.UseTamrielTimeAsTimeStamp = not Addon.SavedVars.UseTamrielTimeAsTimeStamp end,
		width = "full"
		}
	else
		Addon.SavedVars.UseTamrielTimeAsTimeStamp = false
	end
	
	LAM:RegisterOptionControls(addOnName, Addon.OptionsTable)
		
	-- Steuerung
	ZO_CreateStringId("SI_BINDING_NAME_PHOTOGRAPHER_SCREENSHOT_INTERN", text.description)
	ZO_CreateStringId("SI_BINDING_NAME_PHOTOGRAPHER_SCREENSHOT_EXTERN", text.uet_description)
	ZO_CreateStringId("SI_BINDING_NAME_PHOTOGRAPHER_UI_TOGGLE", text.ui_toggle_description)
	SLASH_COMMANDS[Addon.SavedVars.CommandToTakeScreenshot] = photographer_screenshot_intern
	
	-- Pr�fe Version
	zo_callLater(	function()
		versionInfo_check()
	end, 6000)
	
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, Photographer_OnInitialized)


-- Screenshot über Taste für Externe Tools
function photographer_screenshot_byKey_extern()

	photographer_hide_UI()
	toggleTamrielTime(0, "true")
	
	feedback(text.feedback_ex)
		
	zo_callLater(	function()
		photographer_show_UI()	
	end, 1000)
	
	toggleTamrielTime(1000, "false")
	
end

-- Screenshot für das interne TESO-Screenshot-Tool 
function photographer_screenshot_intern()

	photographer_hide_UI()
	toggleTamrielTime(0, "true")
	
	zo_callLater(	function()
	  feedback(text.feedback_message)
		TakeScreenshot()
	end, 300)	
	
	zo_callLater(	function()
		photographer_show_UI()
	end, 800)
	
	toggleTamrielTime(800, "false")
	
end

-- Screenshot für das interne TESO-Screenshot-Tool
function photographer_screenshot_intern_withUI()
	
	toggleTamrielTime(0, "true")
	
	feedback(text.feedback_message)
	TakeScreenshot()
	
	toggleTamrielTime(1000, "false")
		
end

-- Screenshot durch Event ausf�hren
function photographer_event_screenshot(settings)
	if settings == text.events_choice_withoutUI then
		photographer_screenshot_intern()
	elseif settings == text.events_choice_withUI then
		photographer_screenshot_intern_withUI()
	end
end


-- Toogle Interface completly
function photographer_UI_Toggle()
	if photographer_hidden_UI == false then
		photographer_hide_UI()
	elseif photographer_hidden_UI == true then		
		photographer_show_UI()		
	end
end

function photographer_hide_UI()
	-- Durch 'photographer_hidden_UI' wird sichergestellt dass das Interface nur beim ersten Screenshot innerhalb einer gewissen Zeit, ausgeblendet wird.
	if photographer_hidden_UI == false then
		photographer_hidden_UI = true
		
		-- Aktuelle Marker-Einstellungen sichern und manipulieren
		for i, entry in ipairs(usersettings_memory) do
			entry.UserSettings = GetSetting(entry.SettingsType, entry.Settings)
			SetSetting(entry.SettingsType, entry.Settings, 0, 0)
		end
		-- /Aktuelle Marker-Einstellungen wurden gesichert und Marker ausgeblendet
		
		-- remove target markers if the option is on 		
		if GetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_TARGET_MARKERS) == "1" then
		    target_markers = true
			SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_TARGET_MARKERS, "0", "0")
		end
		
		if not gui_hidden then
			ToggleShowIngameGui()
		end
		SetGameCameraUIMode(false)
		SetFloatingMarkerGlobalAlpha(0)
	end
end

function photographer_show_UI()	
	if photographer_hidden_UI == true then
		photographer_hidden_UI = false
		
		SetFloatingMarkerGlobalAlpha(100)
		if gui_hidden then
			ToggleShowIngameGui()
		end		
		
		-- restore the target markers option if it was on
		if target_markers then
		   SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_TARGET_MARKERS, "1", "0")
		end
		
		-- Gespeicherte Marker-Einstellungen wiederherstellen
		for i, entry in ipairs(usersettings_memory) do
			SetSetting(entry.SettingsType, entry.Settings, entry.UserSettings, entry.UserSettings)
		end
		SetFloatingMarkerGlobalAlpha(100)
		-- /Gespeicherte Marker-Einstellungen wurden wiederhergestellt	
		
	end											
end


function toggleTamrielTime(millisec, state)
	if Addon.SavedVars.UseTamrielTimeAsTimeStamp then
		zo_callLater(	function()
			SLASH_COMMANDS["/ttforceshow"](state)
		end, millisec)
	end
end

--- Events/ ---------------------------------

-- Gotta Quest
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_QUEST_ADDED, function(eventID, journalIndex, questName, objectiveName)
	zo_callLater(	function()
		if Addon.Debug then d("EVENT_QUEST_ADDED") end
		photographer_event_screenshot(Addon.SavedVars.event_quest_received)
	end, 100)
end)

-- Quest solved
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_QUEST_COMPLETE, function(eventID, questName, level, previousXP, currentXP, rank, previousPoints, currentPoints)
	zo_callLater(	function()
		if Addon.Debug then d("EVENT_QUEST_COMPLETE") end
		photographer_event_screenshot(Addon.SavedVars.event_quest_solved)
	end, 1)
end)

-- LevelUP
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_LEVEL_UPDATE, function(eventID, unitTag, level)
	if string.lower(GetUnitName(unitTag)) == playerNameLower then
		zo_callLater(	function()
			if Addon.Debug then d("EVENT_LEVEL_UPDATE") end
			photographer_event_screenshot(Addon.SavedVars.event_levelup)
		end, 1500)
	end
end)

-- Gotta Achievement
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ACHIEVEMENT_AWARDED, function(eventID, name)
	zo_callLater(	function()
	if Addon.Debug then d("EVENT_ACHIEVEMENT_AWARDED") end
		photographer_event_screenshot(Addon.SavedVars.event_achievement)
	end, 1500)
end)

-- Raid trial completed
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_RAID_TRIAL_COMPLETE, function(eventCode, trialName, baseTimeMs, penaltyTimeMs, weekly)
  zo_callLater( function()
  if Addon.Debug then d("EVENT_RAID_TRIAL_COMPLETE") end
    photographer_event_screenshot(Addon.SavedVars.event_raidtrialcompleted)
  end, 1500)
end)

--- /Events ---------------------------------


-- Erhalte den Status der Benutzeroberfläche
local function get_ui_state(eventCode, guiName, hidden) 
	gui_hidden = hidden
	if photographer_hidden_UI and not gui_hidden then
		photographer_show_UI()
	end	
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_GUI_HIDDEN, get_ui_state)

-- Pr�fe Version und gebe ggf. eine Informationen �ber das letzte Update
function versionInfo_check()
  if Addon.SavedVars.CurrentVersion ~= Addon.Version then
    d(textPrefix..text.versionInfo) -- textPrefix..
    Addon.SavedVars.CurrentVersion = Addon.Version
  end
end

-- R�ckmeldung an den Benutzer falls gew�nscht
function feedback(feedback_text)
  if ( (Addon.SavedVars.FeedbackInChatbox == text.feedback_short) or (Addon.SavedVars.FeedbackInChatbox == text.feedback_full) ) then
    d(textPrefix..feedback_text)
  end
end

-- Ausgabe für den Speicherort sofern der Screenshot von TESO erstellt wurde
local function photographer_save_file_feedback(eventID, directory, filename)
  if (Addon.SavedVars.FeedbackInChatbox == text.feedback_full) then
  	d(textPrefix..text.feedback_save)
  	d(textPrefix..directory)
  	d(textPrefix..filename)
	end
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_SCREENSHOT_SAVED, photographer_save_file_feedback)
