local SH_localization  = {
 SH_mod_name = "StoreHelper"
,SH_display_name = "Store Helper"

,SH_bought_mats_msg     = "SH: gekauft %u %s"										-- ie purchased 5 Flint
,SH_buy_reduced_msg     = "SH: %s Kauf von %u auf %u reduzieren - gold prüfen"
,SH_PA_integration_msg  = "SH: PAJunk/Repair gefunden. SH wird 0,2s pausieren."

,SH_OptMenu_header_name = "Store Helper Optionen"
,SH_OptMenu_description = "Halten Sie eine minimale Anzahl von Matten im Handwerksstil bereit. All-Types kauft Toon-Rassenmatten, um sicherzustellen, dass der Kauf von Toon die Matte verwenden kann.\nZählt nur Craftbag-, Bank- und aktuelles Toon-Inventar."
,SH_OptMenu_chk_UseToon_name	 = "Toon-Einstellungen verwenden"
,SH_OptMenu_chk_UseToon_tooltip  = "Verwenden Sie Einstellungen für dieses Toon anstelle von Kontostandardeinstellungen"
,SH_OptMenu_chk_buy2chat_name    = "Nachricht an Chat kaufen"
,SH_OptMenu_chk_buy2chat_tooltip = "kaufnachrichten im Chat anzeigen"
,SH_OptMenu_AllTypes_name	 	 = "All Mat Types"
,SH_OptMenu_AllTypes_tooltip 	 = "Wenn nach bestimmten Mattenkäufen die Gesamtzahl der Matten geringer ist, kaufen Sie mehr: 0-250\nIgnoriert Nickel außer Imperial Toons mit Ovr=Nickel."
,SH_OptMenu_AllTypes_desc		 = "Dieses Toon kauft %s, um das Ziel für alle Typen zu erreichen."
,SH_OptMenu_ShowPA_AddFunc_name  = "Nachrichten für andere Mod-Interaktionen anzeigen"
,SH_OptMenu_ShowPA_AddFunc_tooltip = "Nachricht, wenn Verzögerung für PersonalAssistant oder andere Add-ons hinzugefügt wird, fügen Sie Store-Funktionen hinzu"

-- racial style mat names generated in main code using system calls -> no SH_OptMenu_*_name strings
,SH_OptMenu_box_genMat_tooltip	  = "min auf Lager zu halten: 0-250 (Box für >250 verwenden)"

,SH_OptMenu_Nickel_note = "          Wird nur für die AllTypes-Entscheidung gezählt, wenn Imperial mit Override auf Nickel gesetzt ist." 
,SH_OptMenu_Imp_override_name = "Imperial Race Alle Mattentypen Buy Override " 
,SH_OptMenu_Imp_override_tooltip = "Das Imperial-Motiv ist selten/teuer, nur wenige Toons werden den Stil kennen.\nUm den Kauf von Matten mit eingeschränkter Verwendung zu verhindern, wird AllTypes Buy dies für Imperials verwenden, um die Wahl der Kaufmatte zu ermöglichen.\nHat KEINEN Einfluss auf das Nickel-spezifische Kaufziel."
,SH_OptMenu_Imp_override_desc = "          Hat nur Auswirkungen auf imperiale charaktere."

,SH_err_add_for_store_no_addon_name = "SH: ein anderes Addon hat SH gebeten, eine Store-Funktion auszuführen, ohne den Addon-Namen anzugeben"
,SH_err_add_for_store_no_func_desc  = "SH: %s bat SH, eine Speicherfunktion ohne Beschreibung für die Lademeldung auszuführen"
,SH_err_add_for_store_not_func      = "SH: %s hat SH gebeten, eine Speicherfunktion zu verarbeiten, aber keine Funktion übergeben (%s)"
,SH_err_add_for_store_already_added = "SH: %s bat SH, (%s) hinzuzufügen, was bereits enthalten war"
,SH_accepted_func	                = "SH: akzeptierte Einkaufsfunktion %s(%s)"
		-- SH: accepted shopping function Bob(buy rune stones)

,SH_err_remove_func_no_addon_name	= "SH: ein anderes Addon hat darum gebeten, eine Funktion zu entfernen, ohne den Addon-Namen anzugeben"
,SH_err_remove_func_no_func_desc	= "SH: %s bat SH, eine Store-Funktion ohne Beschreibungsschlüssel zu entfernen"
,SH_err_remove_func_not_func		= "SH: %s hat SH gebeten, eine Speicherfunktion zu entfernen, aber keine Funktion übergeben"
,SH_err_remove_func_not_found		= "SH: %s bat SH zu entfernen (%s), aber die Funktion wurde nie hinzugefügt oder wurde bereits entfernt"
,SH_removed_func					= "SH: Einkaufsfunktion entfernt %s(%s)"
,SH_cannot_find_alltypes_matID		= "SH: schwerwiegender Fehler kann alltypes_matID nicht finden"

,SH_debug_msg_off = "SH: Debug-Nachrichten aus"
,SH_debug_msg_on  = "SH: Debug-Nachrichten an"
,SH_debug_show_ap_entries        = "SH: store nimmt Alliance Point-Einträge an %u"
,SH_debug_show_gold_entries      = "SH: laden nimmt goldeinträge %u"
,SH_debug_show_gold_only_entries = "SH: laden nimmt nur goldeinträge an %u"
,SH_debug_show_telvar_entries    = "SH: store nimmt Telvar-einträge an %u"


-- if a new race is added define SH_style_*, SH_mat_* here
-- if you need a custom language not included by ZOS set SH_load_ZOS_names to false & fill in values
-- SH_style_* is just a display name
,SH_load_ZOS_names	= true
,SH_style_breton	= "custom style name"
,SH_style_redguard	= "custom style name"
,SH_style_orc		= "custom style name"
,SH_style_darkelf	= "custom style name"
,SH_style_nord		= "custom style name"
,SH_style_argonian	= "custom style name"
,SH_style_highelf	= "custom style name"
,SH_style_woodelf	= "custom style name"
,SH_style_khajiit	= "custom style name"
,SH_style_imperial	= "custom style name"

-- SH_mat_* is used for item matching in store entries.
-- custom mat name MUST match the name from GetStoreEntryInfo() not the formated name shown on the screen
,SH_mat_breton		= "custom mat name"
,SH_mat_redguard	= "custom mat name"
,SH_mat_orc			= "custom mat name"
,SH_mat_darkelf		= "custom mat name"
,SH_mat_nord		= "custom mat name"
,SH_mat_argonian	= "custom mat name"
,SH_mat_highelf		= "custom mat name"
,SH_mat_woodelf		= "custom mat name"
,SH_mat_khajiit		= "custom mat name"
,SH_mat_imperial	= "custom mat name"
-- MUST match the name from GetStoreEntryInfo() - REALLY
}

-- loaded SH main LUA first instead of second
-- quick store local into SH for use
ZO_ShallowTableCopy(SH_localization, StoreHelper.localization)


-- do NOT try to set pointer directly, for some reason it will clear addon
-- StoreHelper.localization = SH_localization

-- another way is copying the strings into the Global table with dup checking
-- probably more overhead than the shallow table copy
--[[ 
for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(StringId, 1)
end

other files use this to find the key on the _G table
for key, value in pairs(strings) do
	SafeAddString(_G[key], value, 1)
end

in code use GetString(xx)
]]
