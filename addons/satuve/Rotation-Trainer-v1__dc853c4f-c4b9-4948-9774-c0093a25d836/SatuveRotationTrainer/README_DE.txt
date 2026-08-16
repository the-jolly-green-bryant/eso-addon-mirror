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


0.6.14
- BAR SWAP wird im Trainer als eigener visueller Schritt zwischen Skills angezeigt.
- SWAP bleibt am PRESS-Punkt stehen, bis ESO den tatsächlichen Bar-Wechsel meldet.
- Nach erfolgreichem Swap startet der nächste Skill ca. 250 ms vor PRESS.
- Skills bleiben nach erkanntem Tastendruck 200 ms stabil sichtbar, bevor sie ausblenden.
- Inline-Text "SWAP > Taste" wurde durch den separaten SWAP-Schritt ersetzt.

0.6.16
- BAR SWAP bewegt sich jetzt wie ein normaler Skill von rechts durch die PRESS-Zone nach links.
- SWAP wird nur in der 250-ms-Vorlauf-/200-ms-Nachlaufzone gruen, genau wie Skills.
- Skill-Taste/Zahl liegt jetzt direkt im Skill-Icon statt darunter.
- Tastenanzeige ist groesser und fett (32 px); SWAP nutzt eine passende fette Schrift im Icon.

v0.6.16 – Combat Mapping Lock
- Skill-Zahl/Tastenlabel wird beim Kampfbeginn eingefroren und bleibt auch bei Proc-Varianten stabil.
- Proc-Icons duerfen wechseln, die Zahl des konfigurierten Basisskills bleibt jedoch identisch.
- BAR SWAP wird fuer den aktuellen Skill einmalig vorab geplant und kann nicht spaeter spontan erscheinen.
- Der naechste BAR SWAP wird bereits zwischen zwei Skills aus deren fest gemappten Bars vorausberechnet.


v0.6.18: BAR SWAP hat eigenes Timing. BEFORE und AFTER sind im Setup getrennt von 200-1000 ms in 50-ms-Schritten einstellbar. SWAP nutzt nicht mehr den kompletten Skill-GCD.

v0.6.18 - SWAP als echter Zwischenschritt
- SWAP bewegt sich exakt mit derselben Geschwindigkeit und PRESS-Abbremsung wie Skills.
- BEFORE/AFTER (200-1000 ms) veraendern nur den Abstand vor/nach SWAP, nicht seine Geschwindigkeit.
- Wenn zwischen zwei Skills ein SWAP geplant ist, koennen Skill -> SWAP -> Skill gleichzeitig sichtbar sein.
- Rund um SWAP werden die Abstaende kompakter, damit der zusaetzliche Zwischenschritt Platz hat.


v0.6.19:
- Skill / SWAP / Skill werden als saubere Reihe nebeneinander angezeigt und koennen nicht mehr ueberlappen.
- Die Bewegungsgeschwindigkeit bleibt fuer SWAP und Skills identisch; nur der sichtbare Mindestabstand wird erzwungen.
- Wird die aktuelle Aktion an PRESS nicht rechtzeitig ausgefuehrt, wird sie hinter PRESS zunehmend langsamer und kommt fast zum Stillstand, statt nach links davonzulaufen.


v0.6.20:
- Optionaler PRESS HOLD im Menue: ON/OFF.
- Bei ON bleibt die aktuelle Karte exakt 200 ms auf PRESS stehen.
- Danach laeuft sie mit dem bisherigen Timing/Missed-Slowdown weiter.

v0.6.21:
- AHK COLORS ON/OFF im Menue.
- Feste RGB-Schriftfarben fuer 1-5, SWAP und ULT.
- Rotation kann dadurch per PixelSearch statt ImageSearch gelesen werden.
RGB:
1 #FFB8B8 | 2 #B8FFB8 | 3 #B8D4FF | 4 #FFF0A8
5 #E4B8FF | SWAP #A8FFFF | ULT #FFD0A0


v0.6.22:
- PRESS wird nicht mehr gruen eingefärbt; neutraler dunkler Rahmen.
- RGB-Schriftfarben bleiben unveraendert und sind fuer AHK PixelSearch stabil.

v0.6.23:
- AHK CODE ON/OFF im Menü.
- Im bestehenden grauen PRESS-Rahmen sitzt ein winziger 3-Bit-Datencode.
- 4 kleine 3x3-Pixel-Felder: Sync + 3 Datenbits.
- Code: 1=001, 2=010, 3=011, 4=100, 5=101, SWAP=110, ULT=111.
- Der Code erscheint nur, wenn CURRENT exakt am PRESS-Punkt steht.

v0.6.24:
- Die sichtbare Beschriftung "PRESS" im grauen Zielfeld wurde entfernt.
- Rahmen, Position, PRESS-Hold und AHK-Datencode bleiben unverändert.

v0.6.25:
- Neues weißes DETECT BOX über dem grauen PRESS-Feld.
- Zeigt feste DDS-Bilder für 1,2,3,4,5,SWAP,ULT.
- Dieselben Quellbilder liegen als PNG beim AHK.
- Standard: 300 ms vor PRESS einblenden, mindestens 350 ms sichtbar.
- Lead/Hold im Addon-Menü in 50-ms-Schritten einstellbar.
- Kein Test-Zähler.
- FLOW SPEED kann zwischen ADAPT und FIXED umgeschaltet werden.
  FIXED = konstante Bewegungsgeschwindigkeit ohne PRESS-Easing/Missed-Slowdown.

v0.6.26:
- Zahlen 1-5 aus den bewegten Skill-Icons entfernt.
- SWAP-Text aus dem bewegten SWAP-Element entfernt.
- ULT-Text aus dem bewegten Ultimate-Element entfernt.
- Die weiße DETECT BOX über PRESS ist jetzt die einzige Text-/Bildanzeige für 1-5, SWAP und ULT.
- Skill-Icons selbst bleiben sichtbar.

v0.6.27:
- DETECT BOX komplett auf native ESO-UI umgestellt.
- Keine DDS-Dateien / externen Texturen mehr.
- Weißes CT_BACKDROP, schwarzer ESO-UI-Rahmen und schwarzer nativer CT_LABEL-Text.
- 1-5, SWAP und ULT werden direkt durch ESO gerendert.
- Box bleibt 72x42 px groß.
- Standard weiterhin: 300 ms vor PRESS einblenden, mindestens 350 ms sichtbar.
- FIXED/ADAPT Geschwindigkeitsumschaltung bleibt erhalten.

v0.6.28:
- Zahlen 1-5 wieder auf den bewegten Skill-Icons eingeblendet.
- SWAP-Text wieder auf dem bewegten SWAP-Element eingeblendet.
- ULT-Text wieder auf dem bewegten Ultimate-Element eingeblendet.
- Die native ESO-UI DETECT BOX bleibt unverändert vorhanden.

v0.6.29:
- Die weiße/native DETECT BOX wurde komplett entfernt.
- Zahlen 1-5, SWAP und ULT bleiben wieder direkt auf den bewegten Elementen sichtbar.
- FIXED/ADAPT Geschwindigkeitsumschaltung bleibt erhalten.
