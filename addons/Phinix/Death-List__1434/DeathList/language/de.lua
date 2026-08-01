local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German (Thanks ESOUI.com user Scootworks for the German translation!)
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
	L.DLAddon_UnitAdded			= "Wurde zur Todesliste hinzugefügt."
	L.DLAddon_ToAddPlayers		= "Die Einstellung muss aktiviert werden, um Spieler zur Todesliste hinzuzufügen."
	L.DLAddon_NotAttackable		= "Ziel nicht angreifbar."
	L.DLAddon_NoGuards			= "Unverwundbare Wachen können nicht zur Todesliste hinzufügen werden."
	L.DLAddon_ListCleared		= "Alle Todesziele gelöscht."
L.DLAddon_ListEmpty			= "Es gibt keine Namen auf deiner Todesliste."
L.DLAddon_Removed			= "wurde von deiner Todesliste entfernt."
L.DLAddon_NoExist			= "Ziel ist nicht in deiner Todesliste vorhanden."

-- Settings panel
	L.DLAddon_ShowMarker		= "Markierung Charakter anzeigen"
	L.DLAddon_ShowMarkerTip		= "Zeigt den Namen des Charakters, der zur Todesliste hinzugefügt wurde."
	L.DLAddon_MarkPlayers		= "Spieler Markieren erlauben"
	L.DLAddon_MarkPlayersTip	= "Mit dieser Einstellung wird das Markieren der Spieler zur Todesliste aktiviert."
	L.DLAddon_ShowDebug			= "Zeige Debug"
	L.DLAddon_ShowDebugTip		= "Gibt eine Chat-Nachricht aus, wenn dieses AddOn Funktionen ausführt."
	L.DLAddon_MarkColor			= "Symbolfarbe"
	L.DLAddon_MarkColorTip		= "Wähle eine Farbe des Symbols aus, mit der das Todesziel markiert werden soll."
	L.DLAddon_TextColor			= "Textfarbe "
	L.DLAddon_TextColorTip		= "Wähle eine Farbe des Textes aus, mit der das Todesziel markiert werden soll."
	L.DLAddon_MarkSize			= "Symbolgrösse"
	L.DLAddon_MarkSizeTip		= "Wähle die Grösse des Symbols aus, mit der das Todesziel markiert werden soll."
L.DLAddon_ChatCommants		= "Chat-Befehle"
L.DLAddon_PrintList			= "Druckt den Inhalt Ihrer Todesliste."
L.DLAddon_RemoveName		= "Entferne den angegebenen Namen aus der Todesliste (keine Anführungszeichen)."
L.DLAddon_ClearList			= "Löschen Sie alle Ziele von Ihrer Todesliste."
L.DLAddon_Name				= "Name"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(DLAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DLAddon:GetLanguage() -- set new language return
		return L
	end
end
