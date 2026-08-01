
-- Check Behavior of GetString
local lang = {
	SI_BINDING_NAME_DISPLAY_LONGTXT = "Lange Charakterinfo lesen",

	SI_RPF_LONGTXT_NONE = "|cff8888An <<1>> ist nichts Besonderes.|r",
	SI_RPF_LONGTXT_INTRO = "|c88ffffAn <<1>> ist etwas zu bemerken...|r\n|c88ffff<<2>>|r",
	SI_RPF_EXPLANATION1 = "Um einen Flag zu setzen, den andere in Ihrer Gilde sehen werden, müssen Sie den Text in '##RP: ##' einrahmen, zum Beispiel '##RP: Gott unter Sterblichen ##'. Für das Auslesen gibt diese Liste die Reihenfolge der Gilden an, die nach den Flags überprüft werden.",
	SI_RPF_EXPLANATION2 = "Erkannte Markierungen sind: '##RP:', '##RP_<YourCharacterName>:', '##TXT:' and '##TXT_<YourCharacterName>', wobei '<YourCharacterName>' der Name des Charakters ist, für das Sie die Markierung setzen wollen.",
	SI_RPF_EXPLANATION3 = "Texte in 'RP' ersetzen den Titel des Charakters, Texte in 'TXT' können abgerufen werden, wenn der Spieler, der Sie betrachtet, eine Taste drückt.",
	SI_RPF_SETTINGS = "Einstellungen",
	SI_RPF_SETTINGS_TT = "Generelle Einstellungen bearbeiten",
	SI_RPF_GUILDORDER = "Gildenpriorität",
	SI_RPF_GUILDORDER_TT = "Gibt die Reihenfolge der Gilden an, die nach Flags gescannt werden.",
	SI_RPF_MOVEUP = "Nach oben bewegen",
	SI_RPF_MOVEDN = "Nach unten bewegen",
}

for stringId, stringValue in pairs(lang) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
