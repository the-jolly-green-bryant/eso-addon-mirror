Satuve Rotation Trainer v0.4.7

Fixes:
- Anzeige verwendet die echte Eingabetaste bzw. 1-5 statt ESO-internen Slots 3-7.
- Ultimate-Slot wird auf Front- und Backbar erkannt.
- Ultimate kann Spammable/Execute/Priority 1-10 zugewiesen werden.
- Falls ESO keine Taste fuer Ultimate liefert, wird ULT angezeigt.
- Metronom-/ESO-Timer-/Prioritaetslogik aus v0.4.7 bleibt erhalten.


v0.4.8: Eigene Ultimate-Zeile mit Ultimate-Punkten/Kosten; Ultimate wird nur bei genug Ressource eingeplant. Metronom gleitet durch PRESS weiter nach links und wird nahe PRESS langsamer.


v0.4.9: Adaptives Metronom: letzte 20 Skill-Abstaende, langfristige Annaeherung an 1000 ms; PRESS-Skill bleibt bis zum echten Tastendruck stehen.


v0.5.1: 20-Skill Route Preview / Hotbar Planner mit Bar- und Tastenanzeige sowie geschätzten Bar-Swaps.


v0.5.2:
- Fertiger Skill rutscht nach links und fadet aus.
- /srt move: Metronom mit Pfeiltasten/D-Pad verschieben, ESC/View beendet und speichert.
- /srt test: 40 Skills mit exakt 5 geplanten Bar-Swaps; misst den persoenlichen Rhythmus.
- Trainer plant niemals unter 1000 ms.


v0.5.4:
- Xbox-Fix: private IsKeyDown()-Abfrage entfernt
- /srt move nutzt nur noch sichere OnKeyDown-UI-Eingaben
- D-Pad/Pfeiltasten verschieben weiterhin das Metronom im Move-Modus


v0.5.6: Early-Accept-Fenster: Priority 1 = 200 ms, Priority 2-10 = 350 ms, Spammable/Execute = 300 ms. Proc-Basis-Skills werden als korrekter Tastendruck erkannt.


v0.5.7: Umschaltbar DYNAMIC/STATIC. STATIC spielt Priority 1-10 als feste Reihenfolge und wiederholt sie.


v0.5.8:
- Jeder konfigurierte Skill-Druck resettet sofort seinen Rotationstimer, auch deutlich zu frueh.
- Front/Back werden pro Rotationsplatz getrennt erkannt, auch derselbe Skill auf beiden Bars.
- Metronom bewegt sich kontinuierlich; bei verpasstem PRESS laeuft der Skill langsam weiter statt zu stoppen.


v0.5.9:
- Laengere Zwei-Takt-Metronomstrecke fuer ruhigere Bewegung.
- PRESS ist kein Haltepunkt mehr; verpasste Skills laufen langsam weiter nach links.
- 650-ms-Doppelpress-Sperre verhindert versehentliches erneutes Einreihen.


v0.6.3: Generische Proc-Engine (datengetrieben + Hotbar-Autoerkennung) und manuelle RECAST-Zeit pro Priority (-/+ 1s, AUTO per Klick auf Zeit).


v0.6.4:
- Priority-Fix: EFFECT_RESULT_FADED setzt Cast-/Recast-Timer nicht mehr auf 0 (u.a. Wall of Elements).
- GCD +/- wirkt wieder direkt auf den aktuellen adaptiven Zielwert; Minimum 1000 ms.
