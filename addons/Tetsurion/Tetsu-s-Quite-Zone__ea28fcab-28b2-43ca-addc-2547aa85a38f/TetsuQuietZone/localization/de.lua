TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "Info"
L.INFO_TT = "Blendet Zonen- und Say-Zeilen mit Gilden-Hyperlink aus. Kann auch den Chat ausgewählter eigener Gilden stummschalten. Das offizielle Einladungsfenster wird nicht blockiert.\nGold / Bugs: Post @Tetsurion."

L.ADS_SECTION = "Gildenwerbung stummschalten"
L.ADS_SECTION_TT = "Blendet Werbewände in Zone / Say / Yell aus, wenn die Zeile einen Gildenlink enthält."

L.ENABLED = "Werbefilter aktivieren"
L.ENABLED_TT = "Hauptschalter für Zonen-/Say-/Yell-Werbung. An = Zeilen mit Gildenlink erscheinen nicht im Chat."

L.FILTER_ZONE = "Zonenchat filtern"
L.FILTER_ZONE_TT = "Alle Zonenkanäle inklusive Sprachzonen. Standard an."

L.FILTER_SAY = "Say filtern"
L.FILTER_SAY_TT = "Lokales /say. Standard an."

L.FILTER_YELL = "Yell filtern"
L.FILTER_YELL_TT = "Standard aus. Einschalten, wenn Wände auch per Yell kommen."

L.GUILD_SECTION = "Gildenchat stummschalten"
L.GUILD_SECTION_TT = "Jeder Schalter ist eine Gilde, in der du bist. An = Nachrichten dieser Gilde ausblenden. Andere Gilden bleiben. Speichert per Gilden-ID. Standard aus."
L.GUILD_HINT = "AN - Nachrichten dieser Gilde ausblenden"
L.GUILD_HINT_TT = "An = alle Nachrichten aus /g und /o dieser Gilde ausblenden. Andere Gilden, Zone und Say bleiben."
L.GUILD_EMPTY = "<<1>>. (leerer Slot)"
L.MUTE_GUILD_TT = "An = nur Nachrichten dieser Gilde ausblenden. Andere Gilden, Zone und Say bleiben."

L.HIDDEN_LABEL = "Diese Sitzung versteckt: <<1>>"
L.HIDDEN_TT = "Übersprungene Zeilen seit dem Login (Werbung + stummgeschaltete Gilden). Reset bei ReloadUI."
