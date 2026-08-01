-----------------------------------------------------------------------------
-- 					      									               --
-- 	Title:		 Tamriel Chronos                    					   --
--	Description: Tamriel Time and astronomical data                        --
--	Author: 	 Gandalf (@Gandalf2675)									   --
-- 					      									               --
-----------------------------------------------------------------------------

local strings = {
    -- keybindings		
	SI_BINDING_NAME_TAMRIELCHRONOS_CLOCK = "Uhr Anzeigen/Ausblenden",			
	SI_BINDING_NAME_TAMRIELCHRONOS_ZOOM  = "Zoom Ein/Aus",		
	SI_BINDING_NAME_TAMRIELCHRONOS_CONV  = "Konvertierung Anzeigen/Ausblenden",		
	SI_BINDING_NAME_TAMRIELCHRONOS_CAL   = "Kalender Anzeigen/Ausblenden",	
	-- Chronos.lua		
	SI_TACHRONOS_PLAYER_ALERT		 = "Mehr als <<1>> Minuten gespielt, bitte eine Spielpause einlegen!",
	SI_TACHRONOS_PLAYER_ALERT_FINAL  = "Mehr als <<1>> Minuten gespielt, bitte eine Spielpause einlegen! (Finale Meldung)",
	
	-- cm.lua		
	SI_TACHRONOS_TITLE_CONF          = "Konfiguration",
	
	SI_TACHRONOS_MODE                = "Uhrentyp",
	SI_TACHRONOS_MODE_tt             = "",
	
	SI_TACHRONOS_MODE_h24            = "24h Dual",   
	SI_TACHRONOS_MODE_monD           = "Monde Digital", 
	SI_TACHRONOS_MODE_mon            = "Monde",        
	SI_TACHRONOS_MODE_noMoD          = "Digitaluhr",    
	SI_TACHRONOS_MODE_dualA          = "12h Dual analog",   
	SI_TACHRONOS_MODE_dualD          = "12h Dual digital",     
	SI_TACHRONOS_MODE_e24            = "24h Dual Erdzeit",     

	SI_TACHRONOS_DESC_h24            = "\nTamriel Uhr mit digitaler 2. Zeit, Tag/Nacht Anzeige, Mondphasen und einem Zifferblatt, dass sich dem Tageslicht anpasst", 
	SI_TACHRONOS_DESC_monD           = "\nDigitaluhr mit Mondphasen",
	SI_TACHRONOS_DESC_mon            = "\nMondphasen Anzeige",    
	SI_TACHRONOS_DESC_noMoD          = "",    
	SI_TACHRONOS_DESC_dualA          = "\nTamriel Uhr mit analoger 2. Zeit und Anzeige der Mondphasen",   
	SI_TACHRONOS_DESC_dualD          = "\nTamriel Uhr mit digitaler 2. Zeit und Anzeige der Mondphasen",   
	SI_TACHRONOS_DESC_e24            = "\nErdzeit Uhr mit digitaler 2. Zeit, Overlay für Tamriel Nächte, Mondphasen und einem Zifferblatt, dass sich dem Tageslicht anpasst", 
	
	SI_TACHRONOS_SECS                = "Anzeige der Sekunden",
	SI_TACHRONOS_SECS_tt             = "",

	SI_TACHRONOS_REAL                = "Digitaluhr in Erdzeit anzeigen",
	SI_TACHRONOS_REAL_tt             = "oder in TST (Tamriel Standard Time)",

	SI_TACHRONOS_SCALE               = "Skalierung",
	SI_TACHRONOS_SCALE_tt            = "",

	SI_TACHRONOS_TIME_FONT           = "Schriftart der Digitaluhr",
	SI_TACHRONOS_TIME_FONT_tt        = "Schriftart der digitalen Zeitanzeige",
	
	SI_TACHRONOS_TIME_COLOR          = "Farbe der Digitaluhr",
	SI_TACHRONOS_TIME_COLOR_tt       = "Farbe der digitalen Zeitanzeige",

	SI_TACHRONOS_SHOW_HOLIDAYS       = "Feiertag im Chat zeigen",
	SI_TACHRONOS_SHOW_HOLIDAYS_tt    = "Nach dem Einloggen werden in die aktuelle Feiertage im Chat als Links angezeigt",
	
	SI_TACHRONOS_HEALTH              = "Spielpausen",
	SI_TACHRONOS_HEALTH_tt           = "Erinnerung für eine Spielpause nach so vielen Minuten",

	SI_TACHRONOS_HIDE                = "Uhr beim Start ausblenden",
	SI_TACHRONOS_HIDE_tt        	 = "",
	
	SI_TACHRONOS_HELP                = "Hilfe",
	SI_TACHRONOS_HELP_F              = "",
	SI_TACHRONOS_HELP_F_DESC         = "Tamriel Chronos stellt Uhren nach Tamriel Zeit, astronomische Daten,\n"
	                               .."ein Zeit-Konvertierungstool und ein Feiertagsalender zur Verfügung.\n\n"
								   .."Die Uhren können frei bewegt werden und merken sich ihre Position.\n"
								   .."Die astronomischen Daten werden im Tooltip der Uhr angezeigt.\n"
								   .."Es können Hotkeys für das Ausblenden und das Vergrössern der Uhr definiert werden.\n"
								   .."Mit einem Click der rechten Maustaste auf die Uhr werden die Chronos Daten in the Chat geschrieben.\n\n"
								   .."Mit einem Doppelklick auf die Uhr oder mit einem definierten Hotkey wird das\n"
								   .."Zeit-Konvertierungsdtool angezeigt.\n\n"
								   .."Der Tamriel Feiertagskalender kann über den Info-Schalter im Zeit-Konvertierungstool\n"
								   .."oder über einen Hotkey aufgerufen werden.\n\n"
								   .."Die Tamriel Zeit Konversion basiert auf:\n   - https://esoclock.uesp.net/\n"
								   .."Tamriel Feiertagskalender basiert auf:\n"
								   .."   - https://www.imperial-library.info/content/calendar-tamriel\n"
								   .."   - https://en.uesp.net/wiki/Lore:Holidays",
								   
	-- base.lua/tooltip
	SI_TACHRONOS_M_WAINING		   = "(abnehmend)",
	SI_TACHRONOS_M_WAXING		       = "(zunehmend)",
	SI_TACHRONOS_T_TITLE             = "Zeit",
	SI_TACHRONOS_T_REAL              = "\n   Erde:             %s  %02d.%02d.%04d",
	SI_TACHRONOS_T_TAMRIEL           = "\n   Tamriel:          %s  %02d.%02d.2E%03d\n",
	SI_TACHRONOS_M_TITLE             = "\nMonde",
	SI_TACHRONOS_M_LEVEL             = "\n   Füllgrade:        %.0f%%",
	SI_TACHRONOS_M_PHASE             = "\n   Phase:            %s %s\n",
	SI_TACHRONOS_E_TITLE             = "\nNächste Ereignisse",
	SI_TACHRONOS_E_SUNSET            = "\n   Sonnenuntergang:  ",
	SI_TACHRONOS_E_SUNRISE           = "\n   Sonnenaufgang:    ",
	SI_TACHRONOS_E_FULLMOON          = "\n   Vollmond:         ",
	SI_TACHRONOS_E_NEWMOON           = "\n   Neumond:          ",
	SI_TACHRONOS_T_PLAYED            = "\nGespielte Zeit:      %s\n",
	
	-- moon.lua
	SI_TACHRONOS_MOON_00X            = "???",
	SI_TACHRONOS_MOON_000            = "Neumond",
	SI_TACHRONOS_MOON_025            = "Erstes Viertel",
	SI_TACHRONOS_MOON_050            = "Halbmond zunehmend",
	SI_TACHRONOS_MOON_075            = "Zweites Viertel",
	SI_TACHRONOS_MOON_100            = "Vollmond",
	SI_TACHRONOS_MOON_125            = "Drittes Viertel",
	SI_TACHRONOS_MOON_150            = "Halbmond abnehmend",
	SI_TACHRONOS_MOON_175            = "Letztes Viertel",
	
	-- conv.lua
	SI_TACHRONOS_CONV_TITLE          = "Tamriel Chronos - Umrechnung",
	SI_TACHRONOS_CONV_EST            = "Erdzeit",
	SI_TACHRONOS_CONV_TST            = "Tamriel Zeit",
	SI_TACHRONOS_CONV_NUMBER         = "Fehler: Werte müssen numerisch sein",
	SI_TACHRONOS_CONV_HH             = "Fehler: Stunden müssen im Bereich 0..23 liegen3",
	SI_TACHRONOS_CONV_MM             = "Fehler: Minuten müssen im Bereich von 0..59 liegen",
	SI_TACHRONOS_CONV_SS             = "Fehler: Sekunden müssen im Bereich von 0..59 liegen",
	SI_TACHRONOS_CONV_YY             = "Fehler: Jahre müssen im Bereich von 2014..2017 liegen",
	SI_TACHRONOS_CONV_YY_T           = "Fehler: Jahre müssen im Bereich von 2E 582..2E 679 liegen",
	SI_TACHRONOS_CONV_MO             = "Fehler: Monate müssen im Bereich von 1..12 liegen",
	SI_TACHRONOS_CONV_DD             = "Fehler: Tage müssen im Bereich von 1..31 liegen",
	SI_TACHRONOS_CONV_MOON           = "Monde:  %.0f%% - %s %s",
	
    SI_TACHRONOS_TODAYS_HOLIDAYS            = "Tamriel Chronos - <<1>>",
    
    SI_TACHRONOS_CALENDAR_TITLE             = "Tamriel Feiertags Kalender",

	SI_TACHRONOS_Legend_Year                = "Monate",
	SI_TACHRONOS_Jan                        = "Januar",
	SI_TACHRONOS_Feb                        = "Februar",
	SI_TACHRONOS_Mar                        = "März",
	SI_TACHRONOS_Apr                        = "April",
	SI_TACHRONOS_May                        = "Mai",
	SI_TACHRONOS_Jun                        = "Juni",
	SI_TACHRONOS_Jul                        = "Juli",
	SI_TACHRONOS_Aug                        = "August",
	SI_TACHRONOS_Sep                        = "September",
	SI_TACHRONOS_Oct                        = "Oktober",
	SI_TACHRONOS_Nov                        = "November",
	SI_TACHRONOS_Dec                        = "Dezember",

	SI_TACHRONOS_Legend_Week                = "Wochentage",
	SI_TACHRONOS_Sunday                     = "Sonntag",
	SI_TACHRONOS_Monday                     = "Montag",
	SI_TACHRONOS_Tuesday                    = "Dienstag",
	SI_TACHRONOS_Wednesday                  = "Mittwoch",
	SI_TACHRONOS_Thursday                   = "Donnerstag",
	SI_TACHRONOS_Friday                     = "Freitag",
	SI_TACHRONOS_Saturday                   = "Samstag",
	
}

local pairs = pairs
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end