-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

--Main Title (not translated)
ZO_CreateStringId("SI_AUTO_INVITE", "AutoInvite")

--Status messages
ZO_CreateStringId("SI_AUTO_INVITE_NO_GROUP_MESSAGE", "Gruppe ist leer")
ZO_CreateStringId("SI_AUTO_INVITE_SEND_TO_USER", "Schicke Einladung zu <<1>>")
ZO_CreateStringId("SI_AUTO_INVITE_KICK", "Kicke <<1>> (Offline für <<2>>)")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_OPEN_RESTART", "Wieder Platz in der Gruppe. Horche wieder auf '<<1>>'")
ZO_CreateStringId("SI_AUTO_INVITE_START_ON", "AutoInvite horcht auf den Text '<<1>>'")
ZO_CreateStringId("SI_AUTO_INVITE_STOP", "Stopp AutoInvite")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_FULL_STOP", "Gruppe voll. AutoInvite deaktiviert.")
ZO_CreateStringId("SI_AUTO_INVITE_OFF", "Deaktiviere AutoInvite")

--Error messages
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ACCOUNT", "Kann den Spieler <<1>> nicht finden. Bitte manuell einladen.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_ZONE", "Der Spieler <<1>> ist nicht in Cyrodiil, sondern in <<2>>")
ZO_CreateStringId("SI_AUTO_INVITE_INV_BLOCK", "Blocke Einladung um Abstürze zu vermeiden.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_INVITE", "Fehler - Konnte in folgendem Channel nicht inviten:")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_KICK_TABLE", "Kein Spieler in der Gruppe mit dem Namen <<1>> gefunden. Bitte manuell kicken.")
ZO_CreateStringId("SI_AUTO_INVITE_ERROR_NOT_GROUP_LEADER", "Du bist nicht der Gruppenleiter!")

--Menu
ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENABLED", "Aktiviert")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENABLED", "AutoInvite aktivieren oder nicht")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_STRING", "Einladungstext")
ZO_CreateStringId("SI_AUTO_INVITE_TT_STRING", "Der Text, auf welchen AutoInvite horcht.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_MAX_SIZE", "Maximale Gruppengröße")
ZO_CreateStringId("SI_AUTO_INVITE_TT_MAX_SIZE", "Maximale Anzahl an Spielern, die in die Gruppe eingeladen werden")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_RESTART", "Neustart")
ZO_CreateStringId("SI_AUTO_INVITE_TT_RESTART", "Startet AutoInvite neu, wenn die Gruppe nicht voll ist")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_CYRCHECK", "Cyrodiil Check")
ZO_CreateStringId("SI_AUTO_INVITE_TT_CYRCHECK", "Nur Spieler einladen, die auch in Cyrodiil sind.\n(Diese Bedingung tritt nur ein, wenn du selbst ebenfalls in Cyrodiil bist.)")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK", "Auto-Kick")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK", "Automatisches Kicken von Spielern, die offline sind")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_KICK_TIME", "Zeit vor Kick")
ZO_CreateStringId("SI_AUTO_INVITE_TT_KICK_TIME", "Anzahl der Sekunden, die gewartet werden soll, bevor Offline-Spieler gekickt werden.")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_SLASHCMD", "Slash Befehle")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFRESH", "Liste aktualisieren")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REFORM", "Neu gruppieren")
ZO_CreateStringId("SI_AUTO_INVITE_BTN_REINVITE", "Erneut einladen")

ZO_CreateStringId("SI_AUTO_INVITE_OPT_ENROLMENT", "Deine vorgefertigte Rekrutierungsnachricht")
ZO_CreateStringId("SI_AUTO_INVITE_TT_ENROLMENT", "Dies füllt den Chat voraus, wenn du auf die Schaltfläche darüber klickst, um deine Rekrutierungsnachricht zu posten. Verwende Folgendes, damit AutoInvite es ersetzt durch:\n++cn dein aktueller Name der Allianz-Kampagne\n++gs deine Gruppengröße\n++rs deine verbleibenden Plätze in der Gruppe\n++ro deine benötigten Rollen (unten konfigurieren)")
ZO_CreateStringId("SI_AUTO_INVITE_OPT_NEEDED", "Benötigte Gruppenrollen für die Rekrutierungsnachricht (einschließlich deiner)")

ZO_CreateStringId("SI_AUTO_INVITE_OTHER_SETTINGS", "Haupteinstellungen")
ZO_CreateStringId("SI_AUTO_INVITE_CHATS_LISTEN", "Chats zum Anhören")

-- keybind
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REGROUP", "Umgruppieren")
ZO_CreateStringId("SI_BINDING_NAME_AUTOINVITE_REINVITE", "Erneut einladen")
ZO_CreateStringId("SI_AUTO_INVITE_GROUP_SETTINGS", "Gruppeneinstellungen")

--Slash commands
--Note: Don't translate between the color codes  |C ... |r
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_INFO", "AutoInvite - Befehle |CFFFF00/ai <str>|r.:")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_START", "|CFFFF00/ai foo|r - Starte das Horchen auf den Text 'foo'")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_STOP", "|CFFFF00/ai|r - AutoInvite abschalten")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_REGRP", "|CFFFF00/ai regrp|r - Gruppe auflösen und neu einladen")
ZO_CreateStringId("SI_AUTO_INVITE_SLASHCMD_HELP", "|CFFFF00/ai help|r - Zeigt dieses Hilfe-Menü")

--Templates for using in code (reference):
--ZO_CreateStringId("SI_AUTO_INVITE_", )
--GetString(SI_AUTO_INVITE...)
--zo_strformat(GetString(SI_AUTO_INVITE_...), param1, param2))