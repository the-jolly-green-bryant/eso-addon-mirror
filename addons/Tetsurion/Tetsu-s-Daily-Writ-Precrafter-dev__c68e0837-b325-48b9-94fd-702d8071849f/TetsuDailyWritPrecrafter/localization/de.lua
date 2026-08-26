TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
local L = TetsuDailyWritPrecrafter.L
if not L then return end

L.TITLE                   = "|cFFD700Tetsu's|r Daily Writ Precrafter"

L.OPTIONS_SECTION_LABEL   = "Automatisierung"
L.OPTIONS_SECTION_TT      = "Gamepad-sichere Automatisierungsoptionen."
L.AUTO_QUEST_LABEL        = "Handwerksschriebe automatisch annehmen und abgeben"
L.AUTO_QUEST_TT           = "Schriebe vom Brett annehmen und an den Kisten automatisch abgeben."
L.AUTO_BOX_LABEL          = "Belohnungskisten automatisch öffnen"
L.AUTO_BOX_TT             = "Tägliche Schrieb-Behälter öffnen, sobald sie im Rucksack erscheinen."

L.PRECRAFT_SECTION_LABEL  = "Vorkraften (dieser Charakter)"
L.PRECRAFT_SECTION_TT     = "Einstellungen werden pro Charakter gespeichert."
L.PRECRAFT_ENABLED_LABEL  = "Für die Zukunft vorkraften"
L.PRECRAFT_ENABLED_TT     = "Wenn aktiv: R3 fertigt Gegenstände für mehrere Tage im Voraus nach der Tagesrotation. Wenn inaktiv: R3 fertigt nur, was der aktive Schrieb verlangt."
L.PRECRAFT_DAYS_LABEL     = "Tage im Voraus"
L.PRECRAFT_DAYS_TT        = "Wie viele Tage vorkraften (einschließlich heute). Schieberegler 1–10."

L.KEYBIND_PRECRAFT        = "|c00FF00[R3]|r Vorkraften <<1>> Tage (<<2>> Stk.)"
L.KEYBIND_QUEST_CRAFT     = "|c00FF00[R3]|r Aktiven Schrieb fertigen (<<1>> Stk.)"
L.KEYBIND_NOTHING         = "|c888888[R3]|r Nichts zu fertigen"

L.CONFIRM_TITLE_PRECRAFT  = "Tägliche Schriebe vorkraften"
L.CONFIRM_PROMPT_PRECRAFT = "Gegenstände für <<1>> Tage im Voraus fertigen? (<<2>> Gegenstände)"
L.CONFIRM_TITLE_QUEST     = "Aktiven Schrieb fertigen"
L.CONFIRM_PROMPT_QUEST    = "Die für den aktiven Schrieb benötigten Gegenstände fertigen? (<<1>> Stk.)"

L.PROGRESS_CRAFTING       = "Fertigen..."
L.PROGRESS_STATUS         = "Verarbeitet: <<1>> von <<2>>"

L.ERR_BAG_FULL            = "Nicht genug Platz im Rucksack (ca. <<1>> freie Plätze nötig)."
L.ERR_NO_STYLE            = "Kein bekanntes Stilmaterial in Rucksack oder Handwerkstasche gefunden."
L.ERR_MISSING_RUNES       = "Fehlende Verzauberungsrunen (Potenz / Essenz / Ta)."
L.ERR_CANNOT_CRAFT        = "Kann <<1>> nicht fertigen (Materialien, Stil oder Fertigkeit fehlen)."
L.ERR_CRAFT_FAILED        = "Fertigung fehlgeschlagen (<<1>>/<<2>>). Übersprungen."
L.ERR_NOT_AT_STATION      = "Ihr steht nicht an einer Handwerksstation."
L.ERR_PROV_SKIP_UNKNOWN   = "Übersprungen (Rezept unbekannt): <<1>>"
L.ERR_NOTHING_TO_CRAFT    = "Nichts zu fertigen."
L.ERR_NO_ACTIVE_WRIT      = "Kein aktiver Handwerksschrieb für diese Station."

L.PRECHECK_HEADER         = "|cFF6666[Tetsu's Daily Writ Precrafter]|r Nicht genug Materialien. Fertigung abgebrochen:"
L.PRECHECK_JOBS           = "Aufträge in der Warteschlange: |cFFFFFF<<1>>|r"
L.PRECHECK_LINE           = "  - |cFFD700<<1>>|r: benötigt |cFFFFFF<<2>>|r, vorhanden |cFFFFFF<<3>>|r (|cFF6666-<<4>>|r)"
L.PRECHECK_ABORT          = "Fehlende Materialien hinzufügen und erneut R3 drücken."
L.PRECHECK_OK             = "Materialprüfung OK. Fertige |c00FF00<<1>>|r Gegenstände..."

L.USING_QUEST_DATA        = "Nutze Daten des aktiven Schriebs."
L.USING_PREDICTED         = "Vorkraft-Modus: Tagesrotation für <<1>> Tage."
L.CRAFT_DONE              = "Fertig. Gefertigt: |c00FF00<<1>>|r, übersprungen: |cFFFF00<<2>>|r."
L.PATTERN_TODAY           = "Heutiges Muster: |cFFD700<<1>>|r"
