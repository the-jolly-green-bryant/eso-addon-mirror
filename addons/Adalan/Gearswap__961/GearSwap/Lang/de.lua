---------------------------------------------
-- English localization for GearSwap
---------------------------------------------
-- translated by Adalan@Aruntas

-- Ä = \195\132
-- ä = \195\164
-- ö = \195\182
-- Ö = \195\150
-- Ü = \195\156
-- ü = \195\188
-- ß = \195\159

local localization_strings = {
	-- SETTINGS MENU START
	-- options checkboxes
	GEARSWAP_NAME = "GearSwap",
	GEARSWAP_TEXT = "GearSwap Ein/Aus",
	SWAPPING_ON_WEAPONSWAP_NAME = "Automatischer R\195\188stungswechsel",
	SWAPPING_ON_WEAPONSWAP_TEXT = "R\195\188stungsset wechseln beim Waffenwechsel Ein/Aus \n(Setwechsel \195\188ber Tastaturbelegung geht weiterhin)",	
	CHANGE_COSTUME_NAME = "Kost\195\188m tauschen bei Waffenwechsel",
	CHANGE_COSTUME_TEXT = "Das tauschen des Kost\195\188ms beim Waffenwechsel durchf\195\188hren.\nFunktioniert nicht bei Kost\195\188men aus der Kost\195\188mliste",
	UNEQUIP_SINGLE_ITEMS_NAME = "Abgelegte Einzelteile",
	UNEQUIP_SINGLE_ITEMS_TEXT = "Erm\195\182glicht das speichern von abgelegten R\195\188stungsteilen, Ringen und Schmuckst\195\188cken des entsprechenden Platzes und werden nicht durch die verf\195\188gbaren ersetzt, die sich beim Waffenwechsel belegen w\195\188rden\nAusser bei Waffen und Kost\195\188men",
	SHOW_MESSAGEBOX_NAME = "Infobox anzeigen ",
	SHOW_MESSAGEBOX_TEXT = "Schaltet die Nachrichtenbox ein, damit sie sichtbar ist und verschoben werden kann",
	MOUNT_ONOFF_NAME =  "Verwende automatisch das Pferd-Set",
	MOUNT_ONOFF_TEXT = "Aktiviert, verwendest Du automatisch das gew\195\188hlte Set, wenn Du auf das |cF083F1Pferd|r aufsitzt und wechselst zur\195\188ck zum zuletzt verwendeten Set (solange Du es nicht ver\195\188nderst), wenn Du wieder absitzt.\n|cF083F1Das funkioniert nur ausserhalb des Kampfes!|r",
	
	-- options slider
	SLIDER_ADJUST_MESSAGE_DELAY_NAME = "Dauer der Infomeldung",
	SLIDER_ADJUST_MESSAGE_DELAY_TEXT = "Anzeige der Dauer der Infomeldung auf dem Bildschirm\n1000 = eine Sekunde",
	SLIDER_ADJUST_UNMOUNT_DELAY_NAME = "Unmount-Swap-Timer",
	SLIDER_ADJUST_UNMOUNT_DELAY_TEXT = "Zeit die vergeht, bevor das Set gewechselt wird beim Absteigen vom Pferd\n1000 = eine Sekunde",
	
	-- options dropdown
	OPTIONS_PRIMARY_GEARSET_NAME = "Erstes Set",
	OPTIONS_PRIMARY_GEARSET_TEXT = "Das erste Set nutzen, wenn die Waffe gewechselt wird",
	OPTIONS_SECONDARY_GEARSET_NAME = "Zweites Set",
	OPTIONS_SECONDARY_GEARSET_TEXT = "Das zweite Set nutzen, wenn die Waffe gewechselt wird",
	OPTIONS_MOUNT_GEARSET_NAME = "Default Set f\195\188r das Pferd",
	OPTIONS_MOUNT_GEARSET_TEXT = "W\195\188hle ein Set zum automatischen verwenden, wenn Du auf dem Pferd sitzt",
	
	-- options submenu - announcements
	SUBMENU_ANNOUNCEMENTS_NAME = "Infomeldungen",
	SUBMENU_ANNOUNCEMENTS_TEXT = "Infomeldungen Ein/Aus",
	SUB_MESSAGE_ONSCREEN_NAME = "Infomeldung OnScreen",
	SUB_MESSAGE_ONSCREEN_TEXT = "Meldung anzeigen, wenn zu einem anderen Set gewechselt wird bei Waffenwechsel",
	SUB_CHAT_MESSAGE_ON_SAVE_NAME = "Info beim Speichern",
	SUB_CHAT_MESSAGE_ON_SAVE_TEXT = "Schaltet die Ausgabe Ein oder Aus, beim Speichern des eingestellten Sets",
	SUB_CHAT_MESSAGE_SINGLE_ITEMS_NAME = "Infomeldung f\195\188r Einzelitems",
	SUB_CHAT_MESSAGE_SINGLE_ITEMS_TEXT = "Zeigt eine Info im Chat an, wieviele Pl\195\164tze unbesetzt sind bei R\195\188stungsteilen, Ringen und Schmuckst\195\188ck",
	SUB_CHAT_MESSAGE_AUTO_MOUNT_NAME = "Chatinfo zum Pferd-Set",
	SUB_CHAT_MESSAGE_AUTO_MOUNT_TEXT = "Legt fest, ob eine Info \195\188ber die Einstellungen im Chat ausgegeben werden soll oder nicht",
	-- SETTINGS MENU END
	
	-- GearSwap_VARS_TEXT
	VAR_PRIMARY_SET_TEXT = "Erstes R\195\188stungsset",
	VAR_SECONDARY_SET_TEXT = "Zweites R\195\188stungsset",
	VAR_ADDITIONAL_SET1 = "Alternatives Set-1",
	VAR_ADDITIONAL_SET2 = "Alternatives Set-2",
	
	-- Binding-Names
	BINDING_PRIMARY_GEARSET_TEXT = "Erstes Set anlegen",
	BINDING_SECONDARY_GEARSET_TEXT = "Zweites Set anlegen",
	BINDING_ADDITIONAL1_GEARSET_TEXT = "Alternatives Set-1 anlegen",
	BINDING_ADDITIONAL2_GEARSET_TEXT = "Alternatives Set-2 anlegen",
	BINDING_GO_NAKED_TEXT = "R\195\188stung ausziehen",
	BINDING_MOUNT_SWAP_TEXT = "Autoset Pferd Ein/Aus",
	BINDING_GEARSWAP_ONOFF_TEXT = "GearSwap Ein/Aus",
	BINDING_SWAPPING_ONOFF_TEXT = "Automatischer Wechsel Ein/Aus",	

	-- Misc Text
	MISC_BUTTON_LABEL_SAVE_TEXT = "Set speichern",
	MISC_ACTIVE_TEXT = " aktiv",
	MISC_EQUIPPED_TEXT = " angelegt",
	MISC_SAVED_TEXT = " gespeichert",
	MISC_UNEQUIPPED_ITEMS_GEARSET_PREFIX_TEXT = "Set ",
	MISC_UNEQUIPPED_ITEMS_TEXT = " - Abgelegte Teile : ",
	MISC_UNDRESSING_ALL_ITEMS_TEXT = "Lege gesamte Kleidung ab...",
	MISC_MOUNT_SWAP_ON = "Pferd autoswap AN",
	MISC_MOUNT_SWAP_OFF = "Pferd autoswap AUS",
	MISC_GEARSWAP_TOGGLE_ON = "GearSwap AN",
	MISC_GEARSWAP_TOGGLE_OFF = "GearSwap AUS",
	MISC_GEARSET_WEAPONSWAP_ON = "Setwechsel mit Waffenwechsel EIN",
	MISC_GEARSET_WEAPONSWAP_OFF = "Setwechsel mit Waffenwechsel AUS",		
	MISC_BUTTON_LABEL_UNDRESS_TEXT = "Alles ausziehen",
}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end