--[[----------------------------------------------------------------------------
 Burning Light Tracker 1.2.1
--------------------------------------------------------------------------------
 Kompakte Anzeige der Burning-Light-Stacks (Templer, Aedrischer Speer).

 BEHOBEN IN 1.2.1 -- Initialisierung der eigenen Unit-ID
   SYMPTOM
     Nach Login, /reloadui oder Zonenwechsel blieb der Tracker in den ersten
     Sekunden stumm. Ein /reloadui MITTEN im Kampf funktionierte dagegen sofort.

   URSACHE
     playerUnitId wird bei jeder Spieleraktivierung verworfen und neu gelernt.
     Der einzige Lernkanal war bis 1.2.0 EVENT_EFFECT_CHANGED mit
     REGISTER_FILTER_UNIT_TAG == "player". Dieser Kanal ist als ALLEINIGE Quelle
     unzuverlaessig:
       a) Ausserhalb des Kampfes gibt es keinen garantierten Effektwechsel auf
          dem Spieler -- das Event feuert schlicht nicht.
       b) Fuer Effekte auf dem Spieler selbst meldet der Client die unitId
          haeufig als 0. IsUsableUnitId verwirft das korrekterweise, womit der
          Lerner weiterlaeuft, ohne je zu liefern.
     Bis die ID feststand, lieferte OwnerCheck fuer JEDES eigene Ereignis nil
     ("unknown owner") -- und diese Ereignisse wurden ersatzlos verworfen. Beim
     Reload im Kampf lagen bereits aktive Effekte an, deshalb kam der Effektkanal
     dort sofort zum Zug und alles schien in Ordnung.

   FIX
     1) ZWEITER, STRIKTER LERNKANAL (autoritativ)
        Eine eigene, transiente Registrierung auf EVENT_COMBAT_EVENT, gefiltert
        mit REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE == COMBAT_UNIT_TYPE_PLAYER
        (und REGISTER_FILTER_IS_ERROR == false). COMBAT_UNIT_TYPE_PLAYER
        bezeichnet ausschliesslich den lokalen Spieler; Gruppenmitglieder sind
        COMBAT_UNIT_TYPE_GROUP, alle anderen COMBAT_UNIT_TYPE_OTHER. Zusaetzlich
        prueft der Handler den Wert noch einmal selbst -- COMBAT_UNIT_TYPE_NONE
        wird strikt verworfen, der Filter allein gilt nicht als Beweis. Die
        Registrierung meldet sich ab, sobald die ID feststeht, und beruehrt die
        beiden Tracking-Registrierungen (_Stack, _Proc) nicht.
        Der Effektkanal bleibt als opportunistische Zweitquelle bestehen: er
        liefert manchmal frueher, gilt aber nur als VORLAEUFIG. Meldet der
        Combatkanal spaeter eine abweichende ID, wird sie korrigiert.
     2) ENG BEGRENZTER ZWISCHENSPEICHER
        Solange playerUnitId unbekannt ist, werden eigene Kandidatenereignisse
        (144028 GAINED mit gueltigem hitValue, 80170) mit ihrem ORIGINALEN
        Zeitstempel und Framestempel gepuffert -- hoechstens PENDING_MAX Stueck
        und hoechstens STACK_DURATION_MS alt. Sobald die ID sicher feststeht,
        wird der Puffer in Ankunftsreihenfolge durch GENAU DIESELBE
        Eigentuemerpruefung geschickt wie der Live-Pfad. Nur Ereignisse, deren
        unitIds der gelernten eigenen ID entsprechen, werden angewandt; alles
        andere wird verworfen und als fremd gezaehlt.
        Es wird NICHTS geschaetzt, nichts anhand lokaler Zeit rekonstruiert und
        kein Ereignis unbekannter Herkunft akzeptiert.

   NICHT GEAENDERT
     OwnerCheck bleibt strikt (nil und false werden verworfen), es gibt keine
     permissive Rueckfallregel, keine geratenen Unit-IDs, REQUIRE_SELF_TARGET
     bleibt true, und Stacklogik, Proclogik, Timer, Designs, Position,
     Lock-Modus und Lokalisierung sind unveraendert.

 NEU IN 1.2.0
   Zweisprachige Oberflaeche (Deutsch / Englisch). Saemtliche sichtbaren Texte
   liegen in EINER zentralen Tabelle L und werden ueber die Hilfsfunktion T()
   geholt; ausserhalb von L steht kein Benutzertext mehr im Code.
   Neue Befehle: /blt lang, /blt lang de, /blt lang en.
   Neuer SavedVariables-Schluessel: language ("de" oder "en").

   AUTOMATISCHE STANDARDSPRACHE
     Nur wenn NOCH KEINE Sprache gespeichert ist, wird die Clientsprache ueber
     GetCVar("language.2") gelesen. Das ist die einzige ueber alle bisherigen
     API-Versionen hinweg stabile Sprachkennung des Clients (Werte u. a. "de",
     "en", "fr", "es", "ru", "jp", "zh"); GetLanguage()/GetCVar("language")
     existieren nicht bzw. sind nicht verlaesslich. Der Aufruf ist in pcall
     gekapselt und das Ergebnis wird auf einen String geprueft -- laesst sich
     die Sprache nicht sicher bestimmen, wird nichts erzwungen und Englisch
     verwendet. Eine manuelle Auswahl hat immer Vorrang und wird von der
     Erkennung nie ueberschrieben.

   Erkennungs-, Zustands-, Timer-, Eigentuemer- und Proclogik sind gegenueber
   1.1.1 UNVERAENDERT; ergaenzt wurde ausschliesslich die Textschicht plus die
   Speicherung der Sprachauswahl.

 BEHOBEN IN 1.1.1
   A) Fremde Spieler wurden mitgezaehlt.
      Die alte Eigentuemerpruefung arbeitete mit sourceType/targetType und liess
      unbestimmbare Faelle durch. Burning-Light-Effektereignisse melden aber
      sourceType == targetType == COMBAT_UNIT_TYPE_NONE (0) -- fuer eigene UND
      fuer fremde Ereignisse gleichermassen. Damit war die Pruefung wirkungslos,
      sobald in der Naehe jemand kaempfte.
      Jetzt wird ausschliesslich ueber die Unit-IDs geprueft.
   B) Nach /reloadui konnte ein aktiver Stack erscheinen.
      Hauptursache war A: unmittelbar nach dem Ladebildschirm fuellten fremde
      Ereignisse den Tracker und frischten das 3-Sekunden-Fenster staendig auf.
      Zweitursache: die Combat-Events wurden bereits bei EVENT_ADD_ON_LOADED
      registriert, also bevor der Spieler vollstaendig aktiviert war.
      Jetzt wird erst bei EVENT_PLAYER_ACTIVATED registriert, nach einem
      vollstaendigen Laufzeit-Reset.

 EIGENE UNIT-ID
   Die ESO-API kennt KEIN GetUnitId("player"). Auch GetUnitUniqueIdentifier
   liefert nicht die in EVENT_COMBAT_EVENT verwendete unitId. Etablierte
   Combat-Bibliotheken (z. B. LibCombat) lernen die Spieler-ID stattdessen aus
   Ereignissen, die eine unitId zusammen mit einer eindeutigen Zuordnung zum
   Spieler tragen.
   Dieses Addon nutzt dafuer genau eine eng gefilterte Registrierung auf
   EVENT_EFFECT_CHANGED mit REGISTER_FILTER_UNIT_TAG == "player". Daraus wird
   ausschliesslich die unitId gelesen; nichts anderes aus diesem Event wird
   ausgewertet. Sobald die ID bekannt ist, meldet sich die Registrierung selbst
   wieder ab. Bei jedem EVENT_PLAYER_ACTIVATED wird die ID verworfen und neu
   gelernt, weil Unit-IDs zonen- und sitzungsbezogen sind.

 NEU IN 1.1.0
   Drei waehlbare Designs (/blt design 1..3). Erkennungs-, Zustands-, Timer- und
   Proclogik sind gegenueber 1.0.0 UNVERAENDERT geblieben; ergaenzt wurde
   ausschliesslich die Darstellungsschicht plus die Speicherung der Auswahl.

 HERKUNFT DER ABILITY-IDs
   Die drei IDs stammen aus EINER echten Diagnoseaufnahme mit dem Wegwerf-Addon
   BLDiag, auf einer Templer-Figur mit dem dort gelernten Passivrang. Sie sind
   NICHT durch mehrere unabhaengige Tests validiert. Insbesondere ist offen, ob
   Rang I und Rang II des Passivs dieselben IDs verwenden -- auf einer
   niedrigstufigen Figur kann der Tracker deshalb stumm bleiben.

     144028  Stackereignis, Name "brennendes Licht".
             Erscheint mit result == ACTION_RESULT_EFFECT_GAINED und
             hitValue == 1..4 (der Stackwert).
             Dasselbe Ability erzeugt zusaetzlich ein Ereignis mit
             ACTION_RESULT_EFFECT_GAINED_DURATION, dessen hitValue die DAUER
             (3000) traegt. Dieses Ereignis wird ausschliesslich ignoriert.
     80170   Procschaden, Name "brennendes Licht".
     178118  "Ueberladen" -- separater Folgeeffekt. Wird nicht registriert und
             erreicht diesen Code deshalb nie.

 API-ANNAHMEN
   1) EVENT_COMBAT_EVENT-Signatur (18 Werte inkl. eventCode):
        eventCode, result, isError, abilityName, abilityGraphic,
        abilityActionSlotType, sourceName, sourceType, targetName, targetType,
        hitValue, powerType, damageType, log, sourceUnitId, targetUnitId,
        abilityId, overflow
      Liefert der Client weniger Werte, sind die hinteren Parameter nil. Der
      Handler steigt dann sauber aus, statt einen Lua-Fehler zu erzeugen.
   2) Die Werte 2240 / 2245 aus der Diagnose sind KEINE sourceType-Werte --
      COMBAT_UNIT_TYPE_* umfasst nur eine Handvoll kleiner Werte. Sie
      entsprechen sehr wahrscheinlich ACTION_RESULT_EFFECT_GAINED bzw.
      ACTION_RESULT_EFFECT_GAINED_DURATION. Dieser Code vergleicht deshalb
      ausschliesslich gegen die benannten Konstanten und nie gegen Zahlen.
   3) Combat-Events tragen keinen eigenen Zeitstempel. Gestempelt wird bei
      Empfang mit GetGameTimeMilliseconds(). Durch die Netzwerklatenz zeigt der
      Countdown systematisch minimal zu lang an. Das ist hingenommen.
   4) EVENT_PLAYER_ACTIVATED deckt Login, jeden Ladebildschirm (also auch den
      Zonenwechsel) und /reloadui gemeinsam ab. Ein eigener Zonenevent ist
      dafuer nicht noetig.
   5) Ob 144028 auch ein ACTION_RESULT_EFFECT_FADED erzeugt und ob dieses fuer
      den ganzen Stapel oder je Einzelstack feuert, ist UNBESTAETIGT. Solange
      das offen ist, waere ein Reset darauf riskant -- er koennte mitten im
      Zyklus auf 0 setzen. Schalter: RESET_ON_EFFECT_FADED.
   6) Alle drei Designs bestehen ausschliesslich aus CT_CONTROL-Containern,
      CT_BACKDROP-Flaechen und CT_LABEL-Texten. Keine externen Texturen, keine
      Bilddateien, keine Bibliotheken. Schriftnamen werden ueber SetFontSafe
      gesetzt, damit ein in einer API-Version fehlender Font nicht zum Fehler
      fuehrt.

 BEWUSST NICHT ENTHALTEN
   Kein EVENT_EFFECT_CHANGED, kein Buff-Polling, keine allgemeine
   Schadensauswertung, keine Logspeicherung, keine Konfigurationsoberflaeche,
   keine Bibliotheken, keine Animationen.
------------------------------------------------------------------------------]]

local ADDON_NAME    = "BurningLightTracker"
local ADDON_VERSION = "1.2.1"

--------------------------------------------------------------------------------
-- Konstanten
--------------------------------------------------------------------------------

local STACK_ABILITY_ID  = 144028
local PROC_ABILITY_ID   = 80170
local OVERCHARGED_ID    = 178118   -- nur zur Dokumentation, nie registriert

local MAX_STACKS        = 4
local STACK_DURATION_MS = 3000     -- Fenster je gueltigem Stackereignis
local PROC_FLASH_MS     = 700      -- Dauer der Proc-Hervorhebung
local UPDATE_INTERVAL   = 50       -- ms, ausschliesslich Anzeige

-- Siehe API-Annahme 5. Erst auf true setzen, wenn im Log bestaetigt ist, dass
-- ACTION_RESULT_EFFECT_FADED fuer 144028 den GANZEN Stapel beendet.
local RESET_ON_EFFECT_FADED = false

-- Sicherheitsventil. Der Stack ist ein Effekt AUF dem Spieler, deshalb muessen
-- laut Spezifikation sourceUnitId UND targetUnitId der eigenen ID entsprechen.
-- Sollte der Client fuer das Stackereignis targetUnitId nicht befuellen (im Log
-- an lastTarget in /blt erkennbar), genuegt hier ein false, um nur noch die
-- Quelle zu pruefen. Standard ist die strenge Variante.
local REQUIRE_SELF_TARGET = true

-- Groesse des Initialisierungs-Zwischenspeichers (siehe "BEHOBEN IN 1.2.1").
-- Nur wirksam, solange playerUnitId unbekannt ist. Aeltere Eintraege als
-- STACK_DURATION_MS werden verworfen, weil sie ohnehin abgelaufen waeren.
local PENDING_MAX = 16

-- Design 1 (horizontal) -- Masse wie in 1.0.0, damit das Erscheinungsbild
-- unveraendert bleibt.
local UI_WIDTH    = 152
local UI_HEIGHT   = 42
local DOT_SIZE    = 10
local DOT_SPACING = 14
local DOT_X       = 8
local DOT_Y       = 24

-- Design 2 (kreisfoermig)
local C_WIDTH     = 64
local C_HEIGHT    = 84
local C_CX        = 32     -- Kreismittelpunkt im Container
local C_CY        = 34
local C_RADIUS    = 24
local C_SLOTS     = 16     -- Positionen auf dem Ring; jede vierte bleibt frei
local C_DOT       = 7

-- Design 3 (vertikaler Balken)
local V_WIDTH     = 78
local V_HEIGHT    = 78
local V_FRAME_X   = 6
local V_FRAME_Y   = 6
local V_FRAME_W   = 20
local V_FRAME_H   = 64
local V_SEG_X     = 8
local V_SEG_W     = 16
local V_SEG_H     = 14
local V_SEG_GAP   = 1
local V_SEG_TOP   = 8

local FONT_TITLE  = "ZoFontGameSmall"
local FONT_VALUE  = "ZoFontGameSmall"
local FONT_BIG    = "ZoFontWinH4"      -- grosse Stackzahl in Design 2 und 3

local COLORS = {
    [0] = { 0.45, 0.45, 0.45 },   -- grau
    [1] = { 0.95, 0.85, 0.25 },   -- gelb
    [2] = { 0.95, 0.85, 0.25 },   -- gelb
    [3] = { 1.00, 0.55, 0.15 },   -- orange
    [4] = { 1.00, 0.85, 0.45 },   -- hellgolden
}
local COLOR_PROC  = { 1.00, 0.97, 0.75 }
local COLOR_EMPTY = { 0.16, 0.16, 0.16 }
local COLOR_TEXT  = { 0.85, 0.85, 0.85 }
local COLOR_TEST  = { 0.55, 0.85, 1.00 }
local COLOR_FRAME = { 0.30, 0.30, 0.30 }

local DEFAULT_LOCKED = true
local DEFAULT_DESIGN = 1

--------------------------------------------------------------------------------
-- Lokalisierung
--------------------------------------------------------------------------------
-- EINZIGE Quelle aller sichtbaren Texte. Ausserhalb dieser Tabelle steht kein
-- Benutzertext mehr im Code -- weder deutsch noch englisch. Quelltextkommentare
-- bleiben bewusst deutsch.
--
-- Konventionen:
--   * Nur ASCII, wie im Rest der Datei (ue/ae/oe statt Umlauten).
--   * Formatplatzhalter muessen in beiden Sprachen in Anzahl UND Reihenfolge
--     uebereinstimmen -- T() formatiert ueber string.format.
--   * Ability-Namen und Ability-IDs werden NICHT uebersetzt.

local FALLBACK_LANG = "en"

local LANGUAGES = { de = true, en = true }

local L = {
    de = {
        lang_name           = "Deutsch",

        loaded              = "geladen. |cFFFFFF/blt|r fuer Hilfe und Status.",

        state_locked        = "gesperrt",
        state_unlocked      = "verschiebbar",
        window_off          = "aus",
        time_seconds        = "%.1f s",

        ui_title            = "Burning Light",
        ui_title_test       = "Burning Light (Test)",
        ui_proc             = "PROC",
        ui_test             = "TEST",

        help_header         = "Burning Light Tracker %s -- UI ist %s, Design %d (%s).",
        help_cmds_basic     = "|cFFFFFF/blt lock|r sperren  |cFFFFFF/blt unlock|r verschieben  |cFFFFFF/blt reset|r Standardposition  |cFFFFFF/blt test|r UI-Test",
        help_cmds_design    = "|cFFFFFF/blt design|r Designs anzeigen  |cFFFFFF/blt design 1|2|3|r Design waehlen",
        help_cmds_lang      = "|cFFFFFF/blt lang|r Sprache anzeigen  |cFFFFFF/blt lang de|r bzw. |cFFFFFF/blt lang en|r Sprache waehlen",
        help_test_running   = "|cFF60FFTestmodus laeuft|r -- /blt test beendet ihn.",
        status_state        = "Stand: %d/%d, Fenster %s, Position %d/%d",
        status_events       = "Ereignisse: %d Stacks, %d Procs",
        status_dropped      = "Verworfen: %d fremd, %d unbekannter Besitzer, %d Wertebereich, %d Duplikat",
        status_unit_known   = "Eigene Unit-ID: |cFFFFFF%s|r -- gelernt aus %s.",
        status_unit_waiting = "Eigene Unit-ID: %s -- Lernphase laeuft, %d Ereignis(se) zwischengespeichert.",
        status_unit_seen    = "Zuletzt gesehen: source=%s target=%s",
        status_pending      = "Zwischenspeicher: %d nachtraeglich verarbeitet, %d als fremd verworfen, %d verfallen, %d verdraengt",
        status_unit_unknown = "|cFFFF60noch unbekannt|r",
        src_combat          = "Combat-Event (sourceType PLAYER)",
        src_effect          = "Effektereignis (unitTag player, vorlaeufig)",
        src_effect_final    = "Effektereignis (unitTag player)",
        status_types        = "Zuletzt gesehen: sourceType=%s targetType=%s | IDs %d Stack, %d Proc, %d ignoriert",

        ui_locked           = "UI gesperrt.",
        ui_unlocked         = "UI verschiebbar. Ziehen, danach |cFFFFFF/blt lock|r.",
        reset_position      = "Position auf Standard zurueckgesetzt (%d/%d). Sperrstatus unveraendert: %s.",

        design_current      = "Aktuelles Design: |cFFFFFF%d|r (%s)",
        design_line_active  = "  |cFFFFFF/blt design %d|r  %s  <- aktiv",
        design_line_other   = "  |cA0A0A0/blt design %d|r  %s",
        design_invalid      = "Ungueltige Designnummer \"%s\". Erlaubt: 1 bis %d. Design bleibt %d.",
        design_already      = "Design %d (%s) ist bereits aktiv.",
        design_applied      = "Design %d (%s) aktiviert.",
        design_1            = "Horizontal",
        design_2            = "Kreis",
        design_3            = "Vertikaler Balken",

        test_started        = "Testmodus: 0/4 bis 4/4 und Proc. Endet selbst; /blt test bricht ab.",
        test_stopped        = "Testmodus beendet.",

        lang_current        = "Aktuelle Sprache: |cFFFFFF%s|r (%s).",
        lang_usage          = "|cFFFFFF/blt lang de|r Deutsch  |cFFFFFF/blt lang en|r Englisch",
        lang_set            = "Sprache auf Deutsch gesetzt.",
        lang_invalid        = "Ungueltige Sprache \"%s\". Erlaubt: de, en. Sprache bleibt %s.",

        unknown_cmd         = "Unbekannter Unterbefehl \"%s\".",
    },

    en = {
        lang_name           = "English",

        loaded              = "loaded. |cFFFFFF/blt|r for help and status.",

        state_locked        = "locked",
        state_unlocked      = "movable",
        window_off          = "off",
        time_seconds        = "%.1f s",

        ui_title            = "Burning Light",
        ui_title_test       = "Burning Light (Test)",
        ui_proc             = "PROC",
        ui_test             = "TEST",

        help_header         = "Burning Light Tracker %s -- UI is %s, design %d (%s).",
        help_cmds_basic     = "|cFFFFFF/blt lock|r lock  |cFFFFFF/blt unlock|r move  |cFFFFFF/blt reset|r default position  |cFFFFFF/blt test|r UI test",
        help_cmds_design    = "|cFFFFFF/blt design|r list designs  |cFFFFFF/blt design 1|2|3|r choose design",
        help_cmds_lang      = "|cFFFFFF/blt lang|r show language  |cFFFFFF/blt lang de|r or |cFFFFFF/blt lang en|r choose language",
        help_test_running   = "|cFF60FFTest mode running|r -- /blt test stops it.",
        status_state        = "State: %d/%d, window %s, position %d/%d",
        status_events       = "Events: %d stacks, %d procs",
        status_dropped      = "Dropped: %d foreign, %d unknown owner, %d out of range, %d duplicate",
        status_unit_known   = "Own unit ID: |cFFFFFF%s|r -- learned from %s.",
        status_unit_waiting = "Own unit ID: %s -- learning, %d event(s) buffered.",
        status_unit_seen    = "Last seen: source=%s target=%s",
        status_pending      = "Buffer: %d replayed, %d dropped as foreign, %d expired, %d evicted",
        status_unit_unknown = "|cFFFF60not known yet|r",
        src_combat          = "combat event (sourceType PLAYER)",
        src_effect          = "effect event (unitTag player, provisional)",
        src_effect_final    = "effect event (unitTag player)",
        status_types        = "Last seen: sourceType=%s targetType=%s | IDs %d stack, %d proc, %d ignored",

        ui_locked           = "UI locked.",
        ui_unlocked         = "UI movable. Drag it, then |cFFFFFF/blt lock|r.",
        reset_position      = "Position reset to default (%d/%d). Lock state unchanged: %s.",

        design_current      = "Current design: |cFFFFFF%d|r (%s)",
        design_line_active  = "  |cFFFFFF/blt design %d|r  %s  <- active",
        design_line_other   = "  |cA0A0A0/blt design %d|r  %s",
        design_invalid      = "Invalid design number \"%s\". Allowed: 1 to %d. Design stays %d.",
        design_already      = "Design %d (%s) is already active.",
        design_applied      = "Design %d (%s) activated.",
        design_1            = "Horizontal",
        design_2            = "Circular",
        design_3            = "Vertical Bar",

        test_started        = "Test mode: 0/4 up to 4/4 and proc. Stops by itself; /blt test aborts.",
        test_stopped        = "Test mode stopped.",

        lang_current        = "Current language: |cFFFFFF%s|r (%s).",
        lang_usage          = "|cFFFFFF/blt lang de|r German  |cFFFFFF/blt lang en|r English",
        lang_set            = "Language set to English.",
        lang_invalid        = "Invalid language \"%s\". Allowed: de, en. Language stays %s.",

        unknown_cmd         = "Unknown subcommand \"%s\".",
    },
}

-- Aktive Sprache. Wird in InitSavedVars aus BurningLightTrackerSaved.language
-- gesetzt; bis dahin gilt der Rueckfallwert.
local currentLang = FALLBACK_LANG

-- Liefert einen gueltigen Sprachcode oder nil.
local function NormalizeLang(v)
    if type(v) ~= "string" then return nil end
    v = v:match("^%s*(%S*)%s*$")
    if v == nil then return nil end
    v = v:lower()
    if LANGUAGES[v] then return v end
    return nil
end

-- Automatische Standardsprache. Siehe Kopfkommentar: GetCVar("language.2") ist
-- die einzige stabile Clientsprachenkennung. Vollstaendig defensiv -- ist sie
-- nicht sicher bestimmbar, wird sie NICHT erzwungen.
local function DetectClientLanguage()
    if type(GetCVar) ~= "function" then return FALLBACK_LANG end
    local ok, value = pcall(GetCVar, "language.2")
    if not ok or type(value) ~= "string" then return FALLBACK_LANG end
    local code = value:lower()
    if code == "de" then return "de" end
    return FALLBACK_LANG
end

-- Zentrale Textfunktion. Holt den Text der aktiven Sprache, faellt bei
-- fehlendem Schluessel auf Englisch zurueck und formatiert nur dann, wenn
-- Argumente uebergeben wurden. Ein fehlerhafter Formatstring darf das Addon
-- nicht killen, deshalb pcall.
local function T(key, ...)
    local tbl = L[currentLang] or L[FALLBACK_LANG]
    local s = tbl and tbl[key]
    if type(s) ~= "string" then
        s = L[FALLBACK_LANG][key]
    end
    if type(s) ~= "string" then
        return "[" .. tostring(key) .. "]"
    end
    if select("#", ...) > 0 then
        local ok, res = pcall(string.format, s, ...)
        if ok then return res end
    end
    return s
end

-- Beschreibung der drei Designs. container und render werden in BuildUI
-- nachgetragen; width/height muessen vorher bekannt sein, weil DefaultPosition
-- und ClampPosition sie brauchen. labelKey zeigt in die Lokalisierungstabelle;
-- die gespeicherte Designnummer bleibt davon unberuehrt.
local DESIGNS = {
    { id = 1, key = "horizontal", labelKey = "design_1", width = UI_WIDTH, height = UI_HEIGHT },
    { id = 2, key = "circular",   labelKey = "design_2", width = C_WIDTH,  height = C_HEIGHT  },
    { id = 3, key = "vertical",   labelKey = "design_3", width = V_WIDTH,  height = V_HEIGHT  },
}

local function DesignLabel(id)
    local dsg = DESIGNS[id]
    if dsg == nil then return tostring(id) end
    return T(dsg.labelKey)
end

--------------------------------------------------------------------------------
-- Zustand
--------------------------------------------------------------------------------

-- Modell: reiner Zustand. Kennt keine UI, ruft keine Spiel-API auf.
-- EINZIGE Zustandsquelle -- alle drei Designs lesen ausschliesslich daraus.
local M = {
    stacks    = 0,
    expiresAt = 0,      -- 0 = kein laufendes Fenster
    procUntil = 0,      -- 0 = keine Proc-Hervorhebung
    lastFrame = nil,    -- Duplikatschutz
    lastValue = nil,    -- Duplikatschutz
}

-- Die in EVENT_COMBAT_EVENT verwendete eigene Unit-ID. Wird dynamisch gelernt
-- (siehe Kopfkommentar) und bei jeder Spieleraktivierung neu ermittelt.
local playerUnitId = nil

-- Kanal, aus dem playerUnitId stammt: nil, "effect" (vorlaeufig) oder
-- "combat" (autoritativ). Nur fuer die Statusausgabe und fuer die Entscheidung,
-- ob der Combat-Lerner weiterlaufen darf.
local playerUnitSource = nil

-- Vorwaertsdeklaration: der Lerner (weiter unten, aber VOR dem Modell) muss den
-- Zwischenspeicher leeren koennen; dessen Definition braucht ihrerseits das
-- Modell und die Ansicht und steht deshalb spaeter.
local PendingFlush

-- Nur fuer die Statusausgabe von /blt. Keine Logik haengt daran.
local STATS = {
    stackEvents = 0, procEvents = 0,
    droppedRange = 0, droppedDup = 0,
    droppedForeign = 0,        -- Unit-ID bekannt, gehoert aber nicht uns
    droppedUnknownOwner = 0,   -- eigene oder fremde Unit-ID nicht bestimmbar
    pendingReplayed = 0,       -- nach dem Lernen nachtraeglich angewandt
    pendingForeign = 0,        -- gepuffert, nach dem Lernen als fremd verworfen
    pendingExpired = 0,        -- gepuffert, aber aelter als STACK_DURATION_MS
    pendingEvicted = 0,        -- aus dem vollen Puffer verdraengt
    unitIdCorrections = 0,     -- Effektkanal spaeter vom Combatkanal korrigiert
    lastSourceType = nil, lastTargetType = nil,
    lastSourceUnitId = nil, lastTargetUnitId = nil,
}

local UI = {
    win = nil, bg = nil, fragment = nil, updateRegistered = false,
    -- Design 1
    d1 = nil, title = nil, dots = {}, stackText = nil, timeText = nil,
    -- Design 2
    d2 = nil, circleSegs = {}, circleValue = nil, circleSub = nil,
    -- Design 3
    d3 = nil, barFrame = nil, barSegs = {}, barValue = nil, barSub = nil,
}

-- Testmodus. Schreibt niemals in M.
local TEST = { active = false, step = 0, stepEnd = 0 }

local TEST_STEPS = {
    { stacks = 0, proc = false, ms = 500 },
    { stacks = 1, proc = false, ms = 500 },
    { stacks = 2, proc = false, ms = 500 },
    { stacks = 3, proc = false, ms = 500 },
    { stacks = 4, proc = false, ms = 700 },
    { stacks = 4, proc = true,  ms = 800 },
    { stacks = 0, proc = false, ms = 400 },
}

--------------------------------------------------------------------------------
-- Hilfsfunktionen
--------------------------------------------------------------------------------

local function Chat(fmt, ...)
    local msg = (select("#", ...) > 0) and string.format(fmt, ...) or fmt
    d("|cFFC050[BLT]|r " .. msg)
end

-- Eine einzige Zeitquelle fuer Stempel und Ablauf.
local function Now()
    return GetGameTimeMilliseconds()
end

-- Nur fuer den Duplikatschutz: Ereignisse desselben Frames tragen denselben
-- Wert. Bewusst kein Millisekunden-Schwellwert -- ein echter Uebergang 1 -> 2
-- liegt durch die spielinterne 0,5-Sekunden-Sperre nie im selben Frame.
local function FrameStamp()
    return GetFrameTimeMilliseconds()
end

local function IsInt(v, lo, hi)
    return type(v) == "number" and v == math.floor(v) and v >= lo and v <= hi
end

local function IsUsableUnitId(v)
    return type(v) == "number" and v > 0
end

-- Ergebnis: true = gehoert uns, false = gehoert jemand anderem,
--           nil = nicht bestimmbar (wird ebenfalls verworfen, aber getrennt
--           gezaehlt, damit /blt den Unterschied zeigt).
local function OwnerCheck(unitId)
    if not IsUsableUnitId(playerUnitId) then return nil end
    if not IsUsableUnitId(unitId) then return nil end
    return unitId == playerUnitId
end

-- Zaehlt das Verwerfen und liefert false zurueck, damit der Aufrufer knapp
-- bleibt.
local function DropByOwner(verdict)
    if verdict == nil then
        STATS.droppedUnknownOwner = STATS.droppedUnknownOwner + 1
    else
        STATS.droppedForeign = STATS.droppedForeign + 1
    end
    return false
end

-- Ein in einer API-Version fehlender Schriftname darf das Addon nicht killen.
local function SetFontSafe(control, name, fallback)
    if control == nil then return end
    local ok = pcall(function() control:SetFont(name) end)
    if not ok and fallback ~= nil then
        pcall(function() control:SetFont(fallback) end)
    end
end

local function SetColorOf(control, c, alpha)
    if control == nil then return end
    control:SetColor(c[1], c[2], c[3], alpha or 1)
end

local function SetFillOf(control, c, alpha)
    if control == nil then return end
    control:SetCenterColor(c[1], c[2], c[3], alpha or 1)
end

--------------------------------------------------------------------------------
-- Ermittlung der eigenen Unit-ID
--------------------------------------------------------------------------------
-- Ausschliesslich zur Identitaetsbestimmung. Zwei getrennte, transiente
-- Registrierungen, beide unabhaengig von den Tracking-Registrierungen
-- (_Stack, _Proc), die hier NICHT angefasst werden:
--
--   A) Effektkanal  EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG "player".
--      Liefert manchmal frueher (aktive Effekte nach einem Reload im Kampf),
--      aber NICHT zuverlaessig: ausserhalb des Kampfes feuert er unter
--      Umstaenden gar nicht, und fuer Effekte auf dem Spieler meldet der Client
--      die unitId haeufig als 0. Deshalb gilt sein Ergebnis nur als
--      VORLAEUFIG -- der Combatkanal darf es korrigieren.
--
--   B) Combatkanal  EVENT_COMBAT_EVENT, gefiltert auf
--      REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE == COMBAT_UNIT_TYPE_PLAYER.
--      COMBAT_UNIT_TYPE_PLAYER bezeichnet ausschliesslich den lokalen Spieler
--      (Gruppenmitglieder sind COMBAT_UNIT_TYPE_GROUP, alle uebrigen
--      COMBAT_UNIT_TYPE_OTHER). Das ist die AUTORITATIVE Quelle. Der Handler
--      prueft den Wert zusaetzlich selbst -- COMBAT_UNIT_TYPE_NONE wird strikt
--      verworfen, der Filter allein gilt nicht als Beweis.
--
-- Sobald die ID autoritativ feststeht, melden sich beide Registrierungen ab.

local PLAYER_ID_NAME    = ADDON_NAME .. "_PlayerId"
local PLAYER_ID_CE_NAME = ADDON_NAME .. "_PlayerIdCE"

-- Nur fuer die Statusausgabe: laeuft der autoritative Kanal noch?
local combatLearnerActive = false

local function StillLearningFromCombat()
    return combatLearnerActive
end

local function StopPlayerIdLearner()
    EVENT_MANAGER:UnregisterForEvent(PLAYER_ID_NAME, EVENT_EFFECT_CHANGED)
end

local function StopPlayerIdCombatLearner()
    EVENT_MANAGER:UnregisterForEvent(PLAYER_ID_CE_NAME, EVENT_COMBAT_EVENT)
    combatLearnerActive = false
end

-- Einzige Stelle, an der playerUnitId gesetzt wird. "combat" schlaegt "effect".
local function AdoptPlayerUnitId(unitId, source)
    if not IsUsableUnitId(unitId) then return end
    if playerUnitId == unitId and playerUnitSource == source then return end

    if playerUnitId ~= nil and playerUnitId ~= unitId then
        -- Kann nur passieren, wenn der Effektkanal vorlaeufig etwas anderes
        -- geliefert hatte. Der Combatkanal korrigiert; nie umgekehrt.
        STATS.unitIdCorrections = STATS.unitIdCorrections + 1
    end

    playerUnitId     = unitId
    playerUnitSource = source

    StopPlayerIdLearner()
    if source == "combat" then
        StopPlayerIdCombatLearner()
    end

    -- Jetzt erst duerfen die zwischengespeicherten Ereignisse geprueft werden.
    if PendingFlush then PendingFlush() end
end

-- Signatur wie im Kopfkommentar dokumentiert (17 Werte inkl. eventCode).
local function OnEffectForPlayerId(_, changeType, effectSlot, effectName, unitTag,
                                   beginTime, endTime, stackCount, iconName,
                                   buffType, effectType, abilityType,
                                   statusEffectType, unitName, unitId,
                                   abilityId, sourceType)
    if unitTag ~= "player" then return end
    if not IsUsableUnitId(unitId) then return end
    AdoptPlayerUnitId(unitId, "effect")
end

-- Dieselbe Signatur wie OnCombatEvent. Ausgewertet werden AUSSCHLIESSLICH
-- sourceType und sourceUnitId; nichts aus diesem Event beruehrt das Modell.
local function OnCombatForPlayerId(_, result, isError, abilityName, abilityGraphic,
                                   abilityActionSlotType, sourceName, sourceType,
                                   targetName, targetType, hitValue, powerType,
                                   damageType, log, sourceUnitId, targetUnitId,
                                   abilityId, overflow)
    if isError then return end
    if COMBAT_UNIT_TYPE_PLAYER == nil then return end
    -- STRIKT: nur der lokale Spieler. COMBAT_UNIT_TYPE_NONE (0) und jeder
    -- andere Wert werden verworfen, auch wenn der Filter fehlen sollte.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end
    if not IsUsableUnitId(sourceUnitId) then return end
    AdoptPlayerUnitId(sourceUnitId, "combat")
end

local function StartPlayerIdLearner()
    StopPlayerIdLearner()
    StopPlayerIdCombatLearner()

    if EVENT_EFFECT_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(PLAYER_ID_NAME, EVENT_EFFECT_CHANGED, OnEffectForPlayerId)
        if REGISTER_FILTER_UNIT_TAG ~= nil then
            EVENT_MANAGER:AddFilterForEvent(PLAYER_ID_NAME, EVENT_EFFECT_CHANGED,
                                            REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    if EVENT_COMBAT_EVENT ~= nil and COMBAT_UNIT_TYPE_PLAYER ~= nil then
        EVENT_MANAGER:RegisterForEvent(PLAYER_ID_CE_NAME, EVENT_COMBAT_EVENT, OnCombatForPlayerId)
        combatLearnerActive = true
        if REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE ~= nil then
            EVENT_MANAGER:AddFilterForEvent(PLAYER_ID_CE_NAME, EVENT_COMBAT_EVENT,
                                            REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE,
                                            COMBAT_UNIT_TYPE_PLAYER)
        end
        if REGISTER_FILTER_IS_ERROR ~= nil then
            EVENT_MANAGER:AddFilterForEvent(PLAYER_ID_CE_NAME, EVENT_COMBAT_EVENT,
                                            REGISTER_FILTER_IS_ERROR, false)
        end
    end
end

--------------------------------------------------------------------------------
-- Modell   (unveraendert gegenueber 1.0.0)
--------------------------------------------------------------------------------

local function ModelReset()
    M.stacks    = 0
    M.expiresAt = 0
    M.procUntil = 0
    M.lastFrame = nil
    M.lastValue = nil
end

-- value ist bereits als Ganzzahl 1..MAX_STACKS geprueft.
local function ModelApplyStack(value, now, frame)
    -- Duplikatschutz: derselbe Wert im selben Frame.
    if M.lastValue == value and M.lastFrame ~= nil and M.lastFrame == frame then
        STATS.droppedDup = STATS.droppedDup + 1
        return false
    end

    -- Selbstkorrektur: hitValue 1 beginnt immer einen neuen Zyklus, auch wenn
    -- gerade 4/4 steht oder eine Proc-Hervorhebung laeuft (verpasster Proc).
    if value == 1 then
        M.procUntil = 0
    end

    M.stacks    = value
    M.expiresAt = now + STACK_DURATION_MS
    M.lastValue = value
    M.lastFrame = frame
    return true
end

-- Der Proc kann eintreffen, ohne dass Stack 4 je sichtbar war. Kein Fehlerfall.
local function ModelProc(now)
    M.procUntil = now + PROC_FLASH_MS
    M.expiresAt = 0          -- Stacktimer beenden
    M.lastValue = nil
    M.lastFrame = nil
end

local function ModelTick(now)
    if M.procUntil > 0 then
        if now >= M.procUntil then ModelReset(); return true end
        return false
    end
    if M.expiresAt > 0 and now >= M.expiresAt then
        ModelReset()
        return true
    end
    return false
end

local function ModelIsIdle()
    return M.stacks == 0 and M.procUntil == 0 and M.expiresAt == 0
end

--------------------------------------------------------------------------------
-- Ansicht: gemeinsamer Teil
--------------------------------------------------------------------------------

local UPDATE_NAME = ADDON_NAME .. "_Update"

local Render, SetUpdateActive, StopTest   -- vorwaerts deklariert

--------------------------------------------------------------------------------
-- Initialisierungs-Zwischenspeicher   (neu in 1.2.1)
--------------------------------------------------------------------------------
-- Greift AUSSCHLIESSLICH, solange playerUnitId noch unbekannt ist. Gepuffert
-- werden nur Ereignisse, die abgesehen von der Eigentuemerpruefung bereits alle
-- Bedingungen erfuellen, samt ihrer ORIGINALEN Zeit- und Framestempel.
--
-- Beim Leeren laeuft exakt dieselbe strenge Pruefung wie im Live-Pfad. Ein
-- Eintrag wird angewandt, wenn er der gelernten eigenen ID entspricht --
-- andernfalls wird er verworfen und als fremd gezaehlt. Es wird nichts
-- geschaetzt und nichts anhand lokaler Zeit rekonstruiert.

local PENDING = {}

local function PendingCount()
    return #PENDING
end

local function PendingClear()
    PENDING = {}
end

-- kind == "stack" | "proc"
local function PendingPush(kind, srcId, tgtId, value, now, frame)
    -- Nur waehrend der Lernphase. Steht die ID fest, gibt es nichts zu puffern.
    if IsUsableUnitId(playerUnitId) then return end
    -- Ohne brauchbare Quell-ID laesst sich spaeter nichts beweisen -> verwerfen.
    if not IsUsableUnitId(srcId) then return end
    if kind == "stack" and not IsInt(value, 1, MAX_STACKS) then return end

    if #PENDING >= PENDING_MAX then
        table.remove(PENDING, 1)
        STATS.pendingEvicted = STATS.pendingEvicted + 1
    end

    PENDING[#PENDING + 1] = {
        kind = kind, src = srcId, tgt = tgtId,
        value = value, now = now, frame = frame,
    }
end

PendingFlush = function()
    if #PENDING == 0 then return end

    local list = PENDING
    PENDING = {}                       -- vor der Auswertung leeren: Reentranz

    local now     = Now()
    local applied = false

    for i = 1, #list do
        local e = list[i]

        if (now - e.now) > STACK_DURATION_MS then
            -- Waere ohnehin abgelaufen. Nicht anwenden, sonst erschiene ein
            -- alter Stapel als aktuell.
            STATS.pendingExpired = STATS.pendingExpired + 1
        else
            local srcOk = OwnerCheck(e.src)
            if srcOk ~= true then
                DropByOwner(srcOk)
                STATS.pendingForeign = STATS.pendingForeign + 1
            elseif e.kind == "proc" then
                STATS.procEvents     = STATS.procEvents + 1
                STATS.pendingReplayed = STATS.pendingReplayed + 1
                ModelProc(e.now)
                applied = true
            else
                local tgtOk = true
                if REQUIRE_SELF_TARGET then tgtOk = OwnerCheck(e.tgt) end
                if tgtOk ~= true then
                    DropByOwner(tgtOk)
                    STATS.pendingForeign = STATS.pendingForeign + 1
                elseif ModelApplyStack(e.value, e.now, e.frame) then
                    STATS.stackEvents     = STATS.stackEvents + 1
                    STATS.pendingReplayed = STATS.pendingReplayed + 1
                    applied = true
                end
            end
        end
    end

    if applied and not TEST.active then
        SetUpdateActive(true)
        Render()
    end
end

local function ActiveDesignId()
    local n = BurningLightTrackerSaved and BurningLightTrackerSaved.design
    if type(n) ~= "number" or DESIGNS[n] == nil then return DEFAULT_DESIGN end
    return n
end

local function ActiveDesign()
    return DESIGNS[ActiveDesignId()]
end

local function CurrentSize()
    local dsg = ActiveDesign()
    return dsg.width, dsg.height
end

-- Schrittsteuerung des Testmodus. Laeuft ausschliesslich auf TEST.
local function TestAdvance(now)
    if TEST.stepEnd == 0 then
        local s = TEST_STEPS[TEST.step]
        if s == nil then StopTest(false); return end
        TEST.stepEnd = now + s.ms
        return
    end
    if now >= TEST.stepEnd then
        TEST.step = TEST.step + 1
        local s = TEST_STEPS[TEST.step]
        if s == nil then StopTest(false); return end
        TEST.stepEnd = now + s.ms
    end
end

local function OnUpdateTick()
    local now = Now()

    -- Das Modell wird IMMER weiter ausgewertet, auch waehrend des Testmodus.
    -- Sonst friert ein laufendes Stackfenster fuer die Dauer des Tests ein und
    -- die Anzeige waere beim Testende kurzzeitig veraltet. Der Testmodus
    -- schreibt weiterhin nichts in M -- er liest nur nicht daraus.
    ModelTick(now)

    if TEST.active then
        TestAdvance(now)
        if TEST.active then Render() end
        return
    end

    Render()
    if ModelIsIdle() then SetUpdateActive(false) end
end

SetUpdateActive = function(active)
    if active then
        if not UI.updateRegistered then
            EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_INTERVAL, OnUpdateTick)
            UI.updateRegistered = true
        end
        return
    end
    -- Der Testmodus haelt den Takt, auch wenn das Modell im Leerlauf ist.
    if TEST.active then return end
    if UI.updateRegistered then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        UI.updateRegistered = false
    end
end

-- Liefert den anzuzeigenden Zustand: aus dem Testmodus oder aus dem Modell.
-- EINZIGE Quelle fuer alle drei Designs.
local function DisplayState()
    if TEST.active then
        local s = TEST_STEPS[TEST.step]
        if s == nil then return 0, 0, false, true end
        local remaining = TEST.stepEnd - Now()
        if remaining < 0 or s.proc or s.stacks == 0 then remaining = 0 end
        return s.stacks, remaining, s.proc, true
    end

    local isProc    = M.procUntil > 0
    local remaining = 0
    if not isProc and M.expiresAt > 0 then
        remaining = M.expiresAt - Now()
        if remaining < 0 then remaining = 0 end
    end
    return M.stacks, remaining, isProc, false
end

--------------------------------------------------------------------------------
-- Design 1: horizontal   (Darstellung wie in 1.0.0)
--------------------------------------------------------------------------------

local function RenderHorizontal(stacks, remaining, isProc, isTest, lit, timeStr)
    for i = 1, MAX_STACKS do
        local dot = UI.dots[i]
        if dot then
            SetFillOf(dot, (isProc or i <= stacks) and lit or COLOR_EMPTY)
        end
    end

    if isProc then
        UI.stackText:SetText(T("ui_proc"))
        SetColorOf(UI.stackText, COLOR_PROC)
    else
        UI.stackText:SetText(string.format("%d/%d", stacks, MAX_STACKS))
        SetColorOf(UI.stackText, lit)
    end

    if timeStr then
        UI.timeText:SetText(timeStr)
        UI.timeText:SetHidden(false)
    else
        UI.timeText:SetText("")
        UI.timeText:SetHidden(true)
    end

    if isTest then
        UI.title:SetText(T("ui_title_test"))
        SetColorOf(UI.title, COLOR_TEST)
    else
        UI.title:SetText(T("ui_title"))
        SetColorOf(UI.title, COLOR_TEXT)
    end
end

--------------------------------------------------------------------------------
-- Design 2: kreisfoermig
--------------------------------------------------------------------------------

local function RenderCircular(stacks, remaining, isProc, isTest, lit, timeStr)
    for i = 1, MAX_STACKS do
        local on = isProc or i <= stacks
        local c  = on and lit or COLOR_EMPTY
        local seg = UI.circleSegs[i]
        if seg then
            for j = 1, #seg do SetFillOf(seg[j], c) end
        end
    end

    UI.circleValue:SetText(isProc and tostring(MAX_STACKS) or tostring(stacks))
    SetColorOf(UI.circleValue, lit)

    if isProc then
        UI.circleSub:SetText(T("ui_proc"))
        SetColorOf(UI.circleSub, COLOR_PROC)
        UI.circleSub:SetHidden(false)
    elseif timeStr then
        UI.circleSub:SetText(timeStr)
        SetColorOf(UI.circleSub, isTest and COLOR_TEST or COLOR_TEXT)
        UI.circleSub:SetHidden(false)
    elseif isTest then
        UI.circleSub:SetText(T("ui_test"))
        SetColorOf(UI.circleSub, COLOR_TEST)
        UI.circleSub:SetHidden(false)
    else
        UI.circleSub:SetText("")
        UI.circleSub:SetHidden(true)
    end
end

--------------------------------------------------------------------------------
-- Design 3: vertikaler Stack-Balken
--------------------------------------------------------------------------------

local function RenderVertical(stacks, remaining, isProc, isTest, lit, timeStr)
    for i = 1, MAX_STACKS do
        local seg = UI.barSegs[i]
        if seg then
            SetFillOf(seg, (isProc or i <= stacks) and lit or COLOR_EMPTY)
        end
    end

    -- Deutliche Rahmenhervorhebung bei vollem Balken und beim Proc.
    if UI.barFrame then
        if isProc or stacks >= MAX_STACKS then
            UI.barFrame:SetEdgeColor(lit[1], lit[2], lit[3], 1)
        else
            UI.barFrame:SetEdgeColor(COLOR_FRAME[1], COLOR_FRAME[2], COLOR_FRAME[3], 1)
        end
    end

    UI.barValue:SetText(isProc and tostring(MAX_STACKS) or tostring(stacks))
    SetColorOf(UI.barValue, lit)

    if isProc then
        UI.barSub:SetText(T("ui_proc"))
        SetColorOf(UI.barSub, COLOR_PROC)
        UI.barSub:SetHidden(false)
    elseif timeStr then
        UI.barSub:SetText(timeStr)
        SetColorOf(UI.barSub, isTest and COLOR_TEST or COLOR_TEXT)
        UI.barSub:SetHidden(false)
    elseif isTest then
        UI.barSub:SetText(T("ui_test"))
        SetColorOf(UI.barSub, COLOR_TEST)
        UI.barSub:SetHidden(false)
    else
        UI.barSub:SetText("")
        UI.barSub:SetHidden(true)
    end
end

--------------------------------------------------------------------------------
-- Gemeinsamer Einstiegspunkt der Darstellung
--------------------------------------------------------------------------------

Render = function()
    if UI.win == nil then return end

    local stacks, remaining, isProc, isTest = DisplayState()

    local lit = COLORS[stacks] or COLORS[0]
    if isProc then lit = COLOR_PROC end

    local timeStr = (remaining > 0) and T("time_seconds", remaining / 1000) or nil

    local dsg = ActiveDesign()
    if dsg and dsg.render then
        dsg.render(stacks, remaining, isProc, isTest, lit, timeStr)
    end
end

StopTest = function(silent)
    if not TEST.active then return end
    TEST.active  = false
    TEST.step    = 0
    TEST.stepEnd = 0
    Render()                                   -- Ansicht wieder auf das Modell
    SetUpdateActive(not ModelIsIdle())
    if not silent then Chat(T("test_stopped")) end
end

--------------------------------------------------------------------------------
-- Fenster, Position, Sperrstatus
--------------------------------------------------------------------------------

local function ApplyLockState()
    if UI.win == nil then return end
    local locked = BurningLightTrackerSaved.locked and true or false
    UI.win:SetMovable(not locked)
    UI.win:SetMouseEnabled(not locked)
    if UI.bg then
        if locked then
            UI.bg:SetCenterColor(0, 0, 0, 0.25)
            UI.bg:SetEdgeColor(0, 0, 0, 0)
        else
            -- Im entsperrten Zustand immer sichtbar und greifbar, auch bei 0/4.
            UI.bg:SetCenterColor(0, 0, 0, 0.55)
            UI.bg:SetEdgeColor(1.00, 0.75, 0.25, 1)
        end
    end
end

local function DefaultPosition()
    local w  = (GuiRoot and GuiRoot:GetWidth())  or 1920
    local h  = (GuiRoot and GuiRoot:GetHeight()) or 1080
    local dw = CurrentSize()
    return math.floor(w / 2 - dw / 2), math.floor(h * 0.62)
end

-- Gespeicherte Absolutkoordinaten koennen nach einem Aufloesungswechsel oder
-- einem Designwechsel (andere Fenstergroesse) ausserhalb des Bildschirms
-- liegen. Es wird ausschliesslich begrenzt -- eine Position innerhalb des
-- Bildschirms bleibt unveraendert.
local function ClampPosition(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then return DefaultPosition() end
    local w = (GuiRoot and GuiRoot:GetWidth())  or 1920
    local h = (GuiRoot and GuiRoot:GetHeight()) or 1080
    local dw, dh = CurrentSize()
    if x < 0 then x = 0 end
    if y < 0 then y = 0 end
    if x > w - dw then x = w - dw end
    if y > h - dh then y = h - dh end
    if x < 0 then x = 0 end
    if y < 0 then y = 0 end
    return x, y
end

local function ApplyPosition()
    if UI.win == nil then return end
    local x, y = ClampPosition(BurningLightTrackerSaved.x, BurningLightTrackerSaved.y)
    BurningLightTrackerSaved.x, BurningLightTrackerSaved.y = x, y
    UI.win:ClearAnchors()
    UI.win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

-- Speichern und Wiederherstellen benutzen denselben Anker (TOPLEFT an
-- GuiRoot/TOPLEFT). Anderenfalls wandert das Fenster bei jedem Reload.
local function SavePosition()
    if UI.win == nil then return end
    BurningLightTrackerSaved.x = math.floor(UI.win:GetLeft())
    BurningLightTrackerSaved.y = math.floor(UI.win:GetTop())
end

-- Blendet die Container um, passt die Fenstergroesse an und begrenzt die
-- Position. Position und Sperrstatus werden dabei NICHT zurueckgesetzt.
local function ApplyDesign()
    if UI.win == nil then return end
    local id = ActiveDesignId()
    for i = 1, #DESIGNS do
        local cont = DESIGNS[i].container
        if cont then cont:SetHidden(i ~= id) end
    end
    local dsg = DESIGNS[id]
    UI.win:SetDimensions(dsg.width, dsg.height)
    ApplyPosition()
    ApplyLockState()
    Render()
end

--------------------------------------------------------------------------------
-- UI-Aufbau
--------------------------------------------------------------------------------
-- Alle drei Designs werden EINMAL beim Laden erzeugt und danach nur noch per
-- SetHidden umgeschaltet. Damit kostet ein Designwechsel nichts und es
-- entstehen keine doppelten Controlnamen.

local function BuildDesign1(wm, win)
    local cont = wm:CreateControl(ADDON_NAME .. "_D1", win, CT_CONTROL)
    cont:SetAnchorFill(win)
    UI.d1 = cont

    local title = wm:CreateControl(ADDON_NAME .. "_Title", cont, CT_LABEL)
    SetFontSafe(title, FONT_TITLE)
    title:SetAnchor(TOPLEFT, cont, TOPLEFT, 8, 3)
    title:SetText(T("ui_title"))
    UI.title = title

    for i = 1, MAX_STACKS do
        local dot = wm:CreateControl(ADDON_NAME .. "_Dot" .. i, cont, CT_BACKDROP)
        dot:SetDimensions(DOT_SIZE, DOT_SIZE)
        dot:SetAnchor(TOPLEFT, cont, TOPLEFT, DOT_X + (i - 1) * DOT_SPACING, DOT_Y)
        dot:SetEdgeTexture("", 1, 1, 1)
        dot:SetEdgeColor(0, 0, 0, 0.8)
        UI.dots[i] = dot
    end

    local stackText = wm:CreateControl(ADDON_NAME .. "_Stacks", cont, CT_LABEL)
    SetFontSafe(stackText, FONT_VALUE)
    stackText:SetAnchor(TOPLEFT, cont, TOPLEFT, DOT_X + MAX_STACKS * DOT_SPACING + 6, DOT_Y - 3)
    UI.stackText = stackText

    local timeText = wm:CreateControl(ADDON_NAME .. "_Time", cont, CT_LABEL)
    SetFontSafe(timeText, FONT_VALUE)
    timeText:SetAnchor(TOPRIGHT, cont, TOPRIGHT, -8, DOT_Y - 3)
    SetColorOf(timeText, COLOR_TEXT)
    UI.timeText = timeText

    DESIGNS[1].container = cont
    DESIGNS[1].render    = RenderHorizontal
end

local function BuildDesign2(wm, win)
    local cont = wm:CreateControl(ADDON_NAME .. "_D2", win, CT_CONTROL)
    cont:SetAnchorFill(win)
    UI.d2 = cont

    -- 16 Positionen auf dem Ring, jede vierte bleibt frei. Dadurch entstehen
    -- vier klar getrennte Bogensegmente aus je drei Flaechen.
    local half = C_DOT / 2
    for slot = 1, C_SLOTS do
        if slot % 4 ~= 0 then
            local segIndex = math.floor((slot - 1) / 4) + 1
            local angle = math.rad(-90 + (slot - 1) * (360 / C_SLOTS))
            local px = C_CX + C_RADIUS * math.cos(angle) - half
            local py = C_CY + C_RADIUS * math.sin(angle) - half

            local piece = wm:CreateControl(ADDON_NAME .. "_CSeg" .. slot, cont, CT_BACKDROP)
            piece:SetDimensions(C_DOT, C_DOT)
            piece:SetAnchor(TOPLEFT, cont, TOPLEFT, math.floor(px + 0.5), math.floor(py + 0.5))
            piece:SetEdgeTexture("", 1, 1, 1)
            piece:SetEdgeColor(0, 0, 0, 0.8)

            UI.circleSegs[segIndex] = UI.circleSegs[segIndex] or {}
            table.insert(UI.circleSegs[segIndex], piece)
        end
    end

    local value = wm:CreateControl(ADDON_NAME .. "_CValue", cont, CT_LABEL)
    SetFontSafe(value, FONT_BIG, FONT_TITLE)
    value:SetAnchor(CENTER, cont, TOPLEFT, C_CX, C_CY)
    value:SetText("0")
    UI.circleValue = value

    local sub = wm:CreateControl(ADDON_NAME .. "_CSub", cont, CT_LABEL)
    SetFontSafe(sub, FONT_VALUE)
    sub:SetAnchor(CENTER, cont, TOPLEFT, C_CX, C_HEIGHT - 12)
    SetColorOf(sub, COLOR_TEXT)
    sub:SetText("")
    sub:SetHidden(true)
    UI.circleSub = sub

    DESIGNS[2].container = cont
    DESIGNS[2].render    = RenderCircular
end

local function BuildDesign3(wm, win)
    local cont = wm:CreateControl(ADDON_NAME .. "_D3", win, CT_CONTROL)
    cont:SetAnchorFill(win)
    UI.d3 = cont

    local frame = wm:CreateControl(ADDON_NAME .. "_VFrame", cont, CT_BACKDROP)
    frame:SetDimensions(V_FRAME_W, V_FRAME_H)
    frame:SetAnchor(TOPLEFT, cont, TOPLEFT, V_FRAME_X, V_FRAME_Y)
    frame:SetCenterColor(0, 0, 0, 0.45)
    frame:SetEdgeTexture("", 2, 2, 1)
    frame:SetEdgeColor(COLOR_FRAME[1], COLOR_FRAME[2], COLOR_FRAME[3], 1)
    UI.barFrame = frame

    -- Stufe 1 unten, Stufe 4 oben.
    for i = 1, MAX_STACKS do
        local seg = wm:CreateControl(ADDON_NAME .. "_VSeg" .. i, cont, CT_BACKDROP)
        seg:SetDimensions(V_SEG_W, V_SEG_H)
        seg:SetAnchor(TOPLEFT, cont, TOPLEFT, V_SEG_X,
                      V_SEG_TOP + (MAX_STACKS - i) * (V_SEG_H + V_SEG_GAP))
        seg:SetEdgeTexture("", 1, 1, 1)
        seg:SetEdgeColor(0, 0, 0, 0.8)
        UI.barSegs[i] = seg
    end

    local value = wm:CreateControl(ADDON_NAME .. "_VValue", cont, CT_LABEL)
    SetFontSafe(value, FONT_BIG, FONT_TITLE)
    value:SetAnchor(CENTER, cont, TOPLEFT, 52, 26)
    value:SetText("0")
    UI.barValue = value

    local sub = wm:CreateControl(ADDON_NAME .. "_VSub", cont, CT_LABEL)
    SetFontSafe(sub, FONT_VALUE)
    sub:SetAnchor(CENTER, cont, TOPLEFT, 52, 52)
    SetColorOf(sub, COLOR_TEXT)
    sub:SetText("")
    sub:SetHidden(true)
    UI.barSub = sub

    DESIGNS[3].container = cont
    DESIGNS[3].render    = RenderVertical
end

local function BuildUI()
    local wm = WINDOW_MANAGER

    local win = wm:CreateTopLevelWindow(ADDON_NAME .. "_Window")
    win:SetDimensions(CurrentSize())
    win:SetClampedToScreen(true)
    win:SetHandler("OnMoveStop", SavePosition)
    UI.win = win

    local bg = wm:CreateControl(ADDON_NAME .. "_BG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetEdgeTexture("", 8, 8, 1)
    UI.bg = bg

    BuildDesign1(wm, win)
    BuildDesign2(wm, win)
    BuildDesign3(wm, win)

    -- Ohne HUD-Fragment schwebt die Anzeige ueber Inventar, Karte und
    -- Ladebildschirm. Defensiv, falls eine API-Version die Namen aendert.
    if ZO_HUDFadeSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        local ok, frag = pcall(function() return ZO_HUDFadeSceneFragment:New(win) end)
        if ok and frag then
            pcall(function() HUD_SCENE:AddFragment(frag) end)
            pcall(function() HUD_UI_SCENE:AddFragment(frag) end)
            UI.fragment = frag
        end
    end

    ApplyDesign()   -- setzt Container, Groesse, Position, Sperrstatus, Render
end

--------------------------------------------------------------------------------
-- Kanal: EVENT_COMBAT_EVENT, gefiltert auf zwei Ability-IDs
--                                        (unveraendert gegenueber 1.0.0)
--------------------------------------------------------------------------------

local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
                             abilityActionSlotType, sourceName, sourceType, targetName,
                             targetType, hitValue, powerType, damageType, log,
                             sourceUnitId, targetUnitId, abilityId, overflow)

    -- Liefert der Client eine kuerzere Signatur, ist abilityId nil -> raus.
    if type(abilityId) ~= "number" then return end
    if isError then return end

    STATS.lastSourceType   = sourceType
    STATS.lastTargetType   = targetType
    STATS.lastSourceUnitId = sourceUnitId
    STATS.lastTargetUnitId = targetUnitId

    ---------------------------------------------------------------- Procschaden
    if abilityId == PROC_ABILITY_ID then
        -- Bewusst KEINE Einschraenkung auf ein einzelnes result: Der Proc kann
        -- als normaler oder als kritischer Treffer eintreffen.
        -- Nur die Quelle muss der eigene Spieler sein; das Ziel ist der Gegner.
        local srcOk = OwnerCheck(sourceUnitId)
        if srcOk ~= true then
            -- Unveraendert streng: das Ereignis wird JETZT verworfen. Neu ist
            -- nur, dass es waehrend der Lernphase zusaetzlich gepuffert und
            -- spaeter erneut gegen die dann bekannte eigene ID geprueft wird.
            PendingPush("proc", sourceUnitId, targetUnitId, nil, Now(), FrameStamp())
            DropByOwner(srcOk)
            return
        end
        STATS.procEvents = STATS.procEvents + 1
        ModelProc(Now())
        if not TEST.active then
            SetUpdateActive(true)
            Render()
        end
        return
    end

    ------------------------------------------------------------- Stackereignis
    if abilityId ~= STACK_ABILITY_ID then return end

    if RESET_ON_EFFECT_FADED and ACTION_RESULT_EFFECT_FADED ~= nil
       and result == ACTION_RESULT_EFFECT_FADED then
        ModelReset()
        if not TEST.active then Render(); SetUpdateActive(false) end
        return
    end

    -- Ausschliesslich das GAINED-Ereignis traegt den Stackwert. Das
    -- GAINED_DURATION-Ereignis traegt die Dauer (3000) und wird ignoriert.
    if ACTION_RESULT_EFFECT_GAINED == nil then return end
    if result ~= ACTION_RESULT_EFFECT_GAINED then return end

    -- Der Stack ist ein Effekt AUF dem Spieler: Quelle und Ziel muessen die
    -- eigene Unit-ID tragen. sourceType/targetType werden bewusst NICHT mehr
    -- ausgewertet -- sie sind fuer dieses Ereignis 0 (COMBAT_UNIT_TYPE_NONE),
    -- und zwar bei eigenen wie bei fremden Spielern.
    local srcOk = OwnerCheck(sourceUnitId)
    if srcOk ~= true then
        -- Siehe Procbranch: verworfen bleibt verworfen; waehrend der Lernphase
        -- wird zusaetzlich gepuffert. PendingPush prueft hitValue selbst.
        PendingPush("stack", sourceUnitId, targetUnitId, hitValue, Now(), FrameStamp())
        DropByOwner(srcOk)
        return
    end
    if REQUIRE_SELF_TARGET then
        local tgtOk = OwnerCheck(targetUnitId)
        if tgtOk ~= true then
            DropByOwner(tgtOk)
            return
        end
    end

    -- Strikt pruefen, niemals begrenzen. Eine Begrenzung nach oben wuerde aus
    -- einer Dauerangabe ein falsches 4/4 samt Proc machen.
    if not IsInt(hitValue, 1, MAX_STACKS) then
        STATS.droppedRange = STATS.droppedRange + 1
        return
    end

    if ModelApplyStack(hitValue, Now(), FrameStamp()) then
        STATS.stackEvents = STATS.stackEvents + 1
        if not TEST.active then
            SetUpdateActive(true)
            Render()
        end
    end
end

--------------------------------------------------------------------------------
-- Reset-Anker
--------------------------------------------------------------------------------

local function HardReset()
    ModelReset()
    if not TEST.active then
        SetUpdateActive(false)
        Render()
    end
end

-- Vollstaendiger Laufzeit-Reset. Setzt Modell, Testmodus und Anzeige-Timer
-- zurueck. Faesst SavedVariables (Position, Sperrstatus, Design) NICHT an.
local function ResetRuntimeState()
    ModelReset()
    PendingClear()            -- Zwischenspeicher ist streng zonen-/sitzungslokal

    TEST.active  = false
    TEST.step    = 0
    TEST.stepEnd = 0

    -- Bewusst direkt statt ueber SetUpdateActive: der Handler muss auch dann
    -- verschwinden, wenn gerade ein Testmodus lief.
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    UI.updateRegistered = false
end

--------------------------------------------------------------------------------
-- Slash-Commands
--------------------------------------------------------------------------------

local function LockStateText()
    return BurningLightTrackerSaved.locked and T("state_locked") or T("state_unlocked")
end

local function CmdHelp()
    local dsg = ActiveDesign()
    Chat(T("help_header", ADDON_VERSION, LockStateText(), dsg.id, DesignLabel(dsg.id)))
    Chat(T("help_cmds_basic"))
    Chat(T("help_cmds_design"))
    Chat(T("help_cmds_lang"))
    if TEST.active then
        Chat(T("help_test_running"))
    end
    Chat(T("status_state",
         M.stacks, MAX_STACKS,
         (M.expiresAt > 0) and T("time_seconds", math.max(0, M.expiresAt - Now()) / 1000)
                           or T("window_off"),
         BurningLightTrackerSaved.x or 0, BurningLightTrackerSaved.y or 0))
    Chat(T("status_events", STATS.stackEvents, STATS.procEvents))
    Chat(T("status_dropped",
         STATS.droppedForeign, STATS.droppedUnknownOwner,
         STATS.droppedRange, STATS.droppedDup))
    if IsUsableUnitId(playerUnitId) then
        local srcKey = "src_combat"
        if playerUnitSource == "effect" then
            -- Vorlaeufig, solange der Combatkanal noch korrigieren darf.
            srcKey = StillLearningFromCombat() and "src_effect" or "src_effect_final"
        end
        Chat(T("status_unit_known", tostring(playerUnitId), T(srcKey)))
    else
        Chat(T("status_unit_waiting", T("status_unit_unknown"), PendingCount()))
    end
    Chat(T("status_unit_seen",
         tostring(STATS.lastSourceUnitId), tostring(STATS.lastTargetUnitId)))
    Chat(T("status_pending",
         STATS.pendingReplayed, STATS.pendingForeign,
         STATS.pendingExpired, STATS.pendingEvicted))
    Chat(T("status_types",
         tostring(STATS.lastSourceType), tostring(STATS.lastTargetType),
         STACK_ABILITY_ID, PROC_ABILITY_ID, OVERCHARGED_ID))
end

local function CmdLock()
    BurningLightTrackerSaved.locked = true
    SavePosition()
    ApplyLockState()
    Chat(T("ui_locked"))
end

local function CmdUnlock()
    BurningLightTrackerSaved.locked = false
    ApplyLockState()
    Chat(T("ui_unlocked"))
end

local function CmdResetPos()
    local x, y = DefaultPosition()
    BurningLightTrackerSaved.x, BurningLightTrackerSaved.y = x, y
    ApplyPosition()
    Chat(T("reset_position", x, y, LockStateText()))
end

local function CmdDesign(arg)
    if arg == nil or arg == "" then
        local cur = ActiveDesignId()
        Chat(T("design_current", cur, DesignLabel(cur)))
        for i = 1, #DESIGNS do
            Chat(T((i == cur) and "design_line_active" or "design_line_other",
                   i, DesignLabel(i)))
        end
        return
    end

    local n = tonumber(arg)
    if n == nil or n ~= math.floor(n) or DESIGNS[n] == nil then
        -- Ungueltige Werte lassen das aktuelle Design unveraendert.
        Chat(T("design_invalid", tostring(arg), #DESIGNS, ActiveDesignId()))
        return
    end

    if n == ActiveDesignId() then
        Chat(T("design_already", n, DesignLabel(n)))
        return
    end

    -- Nur die Designauswahl wird geschrieben. Position und Sperrstatus bleiben
    -- unangetastet; ApplyDesign begrenzt die Position lediglich, falls das
    -- neue Fenster sonst ueber den Bildschirmrand ragen wuerde.
    BurningLightTrackerSaved.design = n
    ApplyDesign()
    Chat(T("design_applied", n, DesignLabel(n)))
end

local function CmdTest()
    if TEST.active then StopTest(false); return end
    -- Der Testmodus treibt ausschliesslich die Ansicht. Das Modell laeuft
    -- unberuehrt weiter; beim Beenden synchronisiert die Ansicht wieder darauf.
    TEST.active  = true
    TEST.step    = 1
    TEST.stepEnd = 0
    SetUpdateActive(true)
    Render()
    Chat(T("test_started"))
end

-- Schreibt ausschliesslich den Schluessel language. Position, Sperrstatus und
-- Design bleiben unangetastet; die Erkennungslogik wird nicht beruehrt.
local function CmdLang(arg)
    if arg == nil or arg == "" then
        Chat(T("lang_current", currentLang, T("lang_name")))
        Chat(T("lang_usage"))
        return
    end

    local code = NormalizeLang(arg)
    if code == nil then
        -- Fehlermeldung in der AKTUELL aktiven Sprache.
        Chat(T("lang_invalid", tostring(arg), currentLang))
        Chat(T("lang_usage"))
        return
    end

    currentLang = code
    BurningLightTrackerSaved.language = code
    Render()                                   -- sichtbare UI-Texte umstellen
    -- Bestaetigung bereits in der NEU gewaehlten Sprache.
    Chat(T("lang_set"))
end

local function OnSlash(args)
    args = args or ""
    local cmd, rest = args:match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()
    if     cmd == "lock"   then CmdLock()
    elseif cmd == "unlock" then CmdUnlock()
    elseif cmd == "reset"  then CmdResetPos()
    elseif cmd == "test"   then CmdTest()
    elseif cmd == "design" then CmdDesign(rest)
    elseif cmd == "lang"   then CmdLang(rest)
    elseif cmd == ""       then CmdHelp()
    else
        Chat(T("unknown_cmd", cmd))
        CmdHelp()
    end
end

--------------------------------------------------------------------------------
-- Initialisierung
--------------------------------------------------------------------------------

-- Bewusst eine schlichte globale Tabelle: kein ZO_SavedVars, keine Profile,
-- keine Migration. Beim ersten Start existiert sie noch nicht.
local function InitSavedVars()
    if type(BurningLightTrackerSaved) ~= "table" then
        BurningLightTrackerSaved = {}
    end
    if BurningLightTrackerSaved.locked == nil then
        BurningLightTrackerSaved.locked = DEFAULT_LOCKED
    end
    -- Design zuerst pruefen: DefaultPosition braucht die Fenstergroesse des
    -- aktiven Designs. Ungueltige oder fehlende Werte fallen auf 1 zurueck,
    -- ohne Position oder Sperrstatus anzufassen.
    local dv = BurningLightTrackerSaved.design
    if type(dv) ~= "number" or dv ~= math.floor(dv) or DESIGNS[dv] == nil then
        BurningLightTrackerSaved.design = DEFAULT_DESIGN
    end
    if type(BurningLightTrackerSaved.x) ~= "number"
       or type(BurningLightTrackerSaved.y) ~= "number" then
        BurningLightTrackerSaved.x, BurningLightTrackerSaved.y = DefaultPosition()
    end

    -- Sprache. Reihenfolge ist bewusst:
    --   1. gespeicherter gueltiger Wert  -> unveraendert uebernehmen
    --      (eine manuelle Auswahl hat damit Vorrang und wird nach /reloadui
    --       NIE durch die Erkennung ueberschrieben)
    --   2. gar kein Wert gespeichert     -> Clientsprache versuchen
    --   3. gespeicherter, aber ungueltiger Wert -> Englisch
    local lang = NormalizeLang(BurningLightTrackerSaved.language)
    if lang == nil then
        if BurningLightTrackerSaved.language == nil then
            lang = DetectClientLanguage()
        else
            lang = FALLBACK_LANG
        end
    end
    BurningLightTrackerSaved.language = lang
    currentLang = lang
end

local function UnregisterCombat()
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Stack", EVENT_COMBAT_EVENT)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Proc",  EVENT_COMBAT_EVENT)
end

local function RegisterCombat()
    local em = EVENT_MANAGER

    -- Immer erst abmelden. EVENT_PLAYER_ACTIVATED feuert bei jedem
    -- Ladebildschirm erneut; ohne das entstuenden doppelte Handler und damit
    -- eine doppelte Verarbeitung desselben Ereignisses.
    UnregisterCombat()

    em:RegisterForEvent(ADDON_NAME .. "_Stack", EVENT_COMBAT_EVENT, OnCombatEvent)
    em:RegisterForEvent(ADDON_NAME .. "_Proc",  EVENT_COMBAT_EVENT, OnCombatEvent)

    -- Filter werden NACH der Registrierung gesetzt, und pro Filterwert braucht
    -- es eine eigene Registrierung. Dadurch erreicht 178118 den Handler nie.
    if REGISTER_FILTER_ABILITY_ID ~= nil then
        em:AddFilterForEvent(ADDON_NAME .. "_Stack", EVENT_COMBAT_EVENT,
                             REGISTER_FILTER_ABILITY_ID, STACK_ABILITY_ID)
        em:AddFilterForEvent(ADDON_NAME .. "_Proc", EVENT_COMBAT_EVENT,
                             REGISTER_FILTER_ABILITY_ID, PROC_ABILITY_ID)
    end
    -- Ohne verfuegbaren Filter greift zusaetzlich die ID-Pruefung im Handler.
end

-- Feste Reihenfolge, identisch bei jeder Spieleraktivierung (Login,
-- Ladebildschirm, Zonenwechsel, /reloadui).
local function OnPlayerActivated()
    UnregisterCombat()        -- 1. keine Ereignisse waehrend des Umbaus
    ResetRuntimeState()       -- 2. Modell, Testmodus und OnUpdate zuruecksetzen

    playerUnitId     = nil    -- 3. Unit-IDs sind zonenbezogen: neu lernen
    playerUnitSource = nil    --    (beide Lernkanaele starten frisch)
    StartPlayerIdLearner()

    ApplyPosition()           -- 4. gespeicherte Position
    ApplyLockState()          -- 5. gespeicherter Sperrstatus
    Render()                  -- 6. Anzeige explizit auf 0/4

    RegisterCombat()          -- 7. genau eine frische Registrierung
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Loaded", EVENT_ADD_ON_LOADED)

    InitSavedVars()
    ResetRuntimeState()
    BuildUI()                 -- endet mit ApplyDesign() -> Render()

    -- Combat-Events werden hier NICHT registriert. Das passiert erst bei
    -- EVENT_PLAYER_ACTIVATED, damit waehrend des Ladebildschirms keine
    -- Ereignisse verarbeitet werden koennen.
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    if EVENT_PLAYER_DEAD ~= nil then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Dead", EVENT_PLAYER_DEAD, HardReset)
    end
    if EVENT_PLAYER_ALIVE ~= nil then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Alive", EVENT_PLAYER_ALIVE, HardReset)
    end

    SLASH_COMMANDS["/blt"] = OnSlash

    Chat(T("loaded"))
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
