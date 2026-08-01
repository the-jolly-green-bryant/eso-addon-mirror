-- =============================================================================
-- === OptimalWeave Language File: German (de.lua)                           ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/de.lua
    Description:        German localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Information & LIESMICH")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "OptimalWeave optimiert das Weaving durch intelligente Fähigkeitssteuerung basierend auf deinem gewählten Modus.\n\n"..
"Passe die Einstellungen in den Untermenüs an, um das Blockverhalten deinen Vorlieben und deinem Spielstil anzupassen.")

ZO_CreateStringId("OW_MENU_MODE_HEADER", "Grundlegende Einstellungen")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Aktivierungsregeln")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Erweiterte Steuerung")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Leistungseinstellungen")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Addon aktiv")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Addon inaktiv")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Diese Option ist aktuell deaktiviert")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Warnung: Hohe Latenzwerte können Eingabeverzögerungen verursachen!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Hinweis|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000Hinweis:|rDiese Erweiterung wird von der ZeniMax Media Inc. und deren verbundenen Unternehmen weder hergestellt noch unterstützt. The Elder Scrolls® und zugehörige Logos sind registrierte Markenzeichen oder Markenzeichen der ZeniMax Media Inc. in den Vereinigten Staaten und/oder anderen Ländern. Alle Rechte vorbehalten.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Haupteinstellungen")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Betriebsmodus")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Sequenziell:|r Erlaubt das Wirken von Fähigkeiten nur nach einem ausgeführten Leichtangriff.\n|cFF0000Strikt:|r Strikte Blockade. Kein Skill-Queuing während GCD.\n|cFFFF00Intelligent:|r Smarte Blockade. Skill-Queuing nur erlaubt, wenn kein Leichter Angriff in der Queue ist.\n|c00FFFFDeaktiviert:|r Deaktiviert.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Sequenziell")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Strikt")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Intelligent")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Deaktiviert")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Nur im Kampf aktiv")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Wenn aktiviert, verwaltet OptimalWeave das Queuing nur während des Kampfes.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Nur mit feindlichem Ziel")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Wenn aktiviert, verwaltet OptimalWeave das Queuing nur bei ausgewähltem feindlichem Ziel.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Ignorieren beim Blocken")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Wenn aktiviert, beeinflusst OptimalWeave das Queuing nicht während aktiver Blockierung.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Boden-Fähigkeiten-Doppelcast blockieren")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Verhindert versehentliches doppeltes Queuen derselben bodengezielten Fähigkeit in kurzer Folge.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Deaktivieren als Tank")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Automatisch abschalten wenn Tank-Rolle aktiv")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Deaktivieren als Heiler")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Automatisch abschalten wenn Heiler-Rolle aktiv")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "Funktionen auf der zweiten Leiste deaktivieren")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Deaktiviert die meisten Funktionen des Addons auf der zweiten Waffenleiste.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "Weave-Assistent auf zweiten Leiste deaktivieren")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "Deaktiviert den Weave-Assistenten (GCD-Management) auf der zweiten Waffenleiste.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "PvP-Deaktivierung")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "Funktionen in PvP deaktivieren")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "Deaktiviert die meisten Addon-Funktionen in PvP-Gebieten")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "Weave-Assistent in PvP deaktivieren")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "Deaktiviert den Weave-Assistenten (GCD-Management) in PvP-Gebieten")

-- =============================================================================
-- == BLOCK ID SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Blockierte Fähigkeiten")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Neue ID blockieren")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Gib eine Ability-ID ein (z.B. 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "Aktuell blockierte IDs")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Klicke zum Entfernen")

-- =============================================================================
-- == Advanced SETTINGS ========================================================
-- =============================================================================    
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Instant-Zauber Puffer (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Sicherheitsabstand für Instant-Fähigkeiten (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Kanalisierungs-Puffer (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Pufferzeit für kanalisierte Fähigkeiten (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "GCD-Tracking Slot")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "Aktionsleisten-Slot für GCD-Erkennung (1-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Minimale GCD-Dauer (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Minimale GCD-Dauer zur Erkennung (0-20ms)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Zurücksetzzeit (Sekunden)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Setzt die Verfolgung zurück, nachdem für so viele Sekunden nichts gewirkt wurde.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Automatischer GCD-Verfolgungs-Slot")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "Automatische Auswahl des besten GCD-Verfolgungs-Slots aus den Slots 3-8")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Basis-Warteschlangenzeit (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Standard-Input-Warteschlange (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Zurücksetzen bei Waffenwechsel")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Setzt den GCD bei Waffenwechsel zurück")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Zurücksetzen bei Ausweichrolle")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Setzt den GCD bei Ausweichrolle zurück")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Waffe automatisch ziehen")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Waffen automatisch ziehen, wenn im Kampf")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Alles zurücksetzen")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Alle Einstellungen auf Standardwerte zurücksetzen")
ZO_CreateStringId("OW_MENU_DYNAMIC_QUEUE_TIME_LABEL", "Dynamische Queue-Zeit (GCD)")
ZO_CreateStringId("OW_MENU_DYNAMIC_QUEUE_TIME_TOOLTIP", "Verwendet den aktuellen GCD (1000 ms) anstelle des festen Werts.")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Latenzkompensation")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Automatische Latenzanpassung")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Automatische Timing-Anpassung basierend auf aktueller Latenz. Empfohlen bei stabiler Verbindung.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Manuelle Eingabelatenz (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Fester Latenzwert (0-200ms). Nur bei deaktivierter Automatik wirksam.")


-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

-- == Grim Focus SETTINGS ======================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Klassen- und Gildenspezifische Einstellungen")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Grimmiger Fokus")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Benötigte Stacks")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Anzahl Stacks bevor Grimmiger Fokus aktivierbar wird (Empfohlen: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Alle Grimmiger Fokus-Morphs blockieren")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Unermüdlicher Fokus:|r Immer blockiert\n|cFFFF00• Grimmiger Fokus und Gnadenlose Entschlossenheit:|r Nur bei 10 Stacks nutzbar\n|cAAAAAADeaktivieren:|r Standardverhalten für alle Morphs")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Benutzerdefinierte Stacks aktivieren")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Aktiviert:|r Verwendet Stack-Einstellung \n"..
                  "|cAAAAAADeaktiviert:|r Grimmiger Fokus und Gnadenlose Entschlossenheit immer bis 10 Stacks blockieren, Unermüdlicher Fokus immer blockieren\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Gilden")

ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Kriegergilden-Jägerfähigkeiten blockieren")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Blockiert alle Morphs der Kriegergilden-Jägerfähigkeiten (Expertenjäger, Getarnter Jäger & Jäger des Bösen)")

ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Magiergilden-Lichtfähigkeiten blockieren")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Blockiert alle Morphs der Licht-Fähigkeiten (Magielicht, Inneres Licht & Strahlendes Magierlicht.)")      

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "In PvP deaktivieren")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "Deaktiviert die Blockierung von Jäger/Licht-Fähigkeiten in PvP-Gebieten")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Geschmolzene Peitsche")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Geschmolzene Peitsche Fähigkeit blockieren")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Blockiert die Fähigkeit Geschmolzene Peitsche, um die drei Stacks nicht zu verlieren.")      

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Schicksalsschnitzer")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Schicksalsschnitzer blockieren")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Verhindert das Wirken von Schicksalsschnitzer, bis Bedingungen erfüllt sind.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Benötigte Crux-Stacks")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Minimale Anzahl an Crux-Stacks, bevor Schicksalsschnitzer gewirkt werden kann (Empfohlen: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "HP-Grenzwert (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "Schicksalsschnitzer-Blockierung deaktivieren, wenn HP unter diesem Wert liegt")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "HP-Prüfung für Schicksalsschnitzer aktivieren")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Deaktiviert die Blockierung von Schicksalsschnitzer bei niedriger Gesundheit")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Ausdauer-Grenzwert (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Deaktiviert Fatecarver-Blockierung bei niedriger Ausdauer")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Ausdauer-Prüfung für Fatecarver aktivieren")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Deaktiviert Fatecarver-Blockierung bei niedriger Ausdauer")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Flegel des Kephaliarchen")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Flegel des Kephaliarchen blockieren")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "Blockiert Flegel des Kephaliarchen, wenn 3 Crux-Stacks vorhanden sind")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Tentakelschrecken")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Tentakelschrecken blockieren")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Blockiert die Fähigkeit Tentakelschrecken, bis Bedingungen erfüllt sind.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Execute-Check")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Execute-Check aktivieren")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Aktiviert oder deaktiviert die Execute-Check-Funktion")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Execute-Grenzwert (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Ziel-Gesundheitsprozentsatz, unterhalb dessen Execute-Zauber erlaubt sind")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Execute-Zauber")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Strahlende Zerstörung, Strahlender Ruhm, Strahlende Unterdrückung")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Blockiert Strahlende Zerstörung-Morphs, bis das Ziel im Execute-Bereich ist")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Assassinenklinge, Pfählen, Mörderklinge")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Blockiert Assassinenklinge-Morphs, bis das Ziel im Execute-Bereich ist")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Magierrage, Magierzorn, Endloser Zorn")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Blockiere Magierzorn-Morphs, bis das Ziel in der Execute-Bereich ist")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Umkehrschnitt, Umkehrschlag, Henker")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Blockiere Umkehrschnitt-Morphs, bis das Ziel in der Execute-Bereich ist")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")


-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Deaktivierung nach Waffentyp")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Weave-Assistent bei Waffentyp deaktivieren")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Deaktiviert nur den Weave-Assistenten (GCD-Management) für die ausgewählten Waffentypen")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Funktionen bei Waffentyp deaktivieren")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Deaktiviert die meisten Addon-Funktionen für die ausgewählten Waffentypen")

-- Einhandwaffen
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Axt")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Deaktivieren, wenn eine Axt ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Hammer")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Deaktivieren, wenn ein Hammer ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Schwert")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Deaktivieren, wenn ein Schwert ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Dolch")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Deaktivieren, wenn ein Dolch ausgerüstet ist")

-- Zweihandwaffen
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "Zweihandschwert")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "Deaktivieren, wenn ein Zweihandschwert ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "Zweihandaxt")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "Deaktivieren, wenn eine Zweihandaxt ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "Zweihandhammer")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "Deaktivieren, wenn ein Zweihandhammer ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Bogen")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Deaktivieren, wenn ein Bogen ausgerüstet ist")

-- Stäbe
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Flammstab")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Deaktivieren, wenn ein Flammstab ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Froststab")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Deaktivieren, wenn ein Froststab ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Blitzstab")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Deaktivieren, wenn ein Blitzstab ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "Heilstab")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "Deaktivieren, wenn ein Heilstab ausgerüstet ist")

-- Andere Waffen
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Schild")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Deaktivieren, wenn ein Schild ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Rune")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Deaktivieren, wenn eine Rune ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Keine Waffe")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Deaktivieren, wenn keine Waffe ausgerüstet ist")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Reservierte Waffe")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Deaktivieren, wenn ein reservierter Waffentyp ausgerüstet ist")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ==============================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Benutzerdefinierte Blockierlisten")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Benutzerdefinierte Blockliste")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Füge Fähigkeits-IDs hinzu, um sie zu blockieren. Du kannst Fähigkeiten auch durch Rechtsklick auf den Aktionsleisten-Slot hinzufügen (benötigt Neuladen der UI)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "Fähigkeits-ID")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Gib die numerische Fähigkeits-ID ein (z. B. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Zur Blockliste hinzufügen")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Blockierte Fähigkeiten:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Benutzerdefinierte Blockliste aktivieren")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Aktiviert oder deaktiviert die Funktionalität der benutzerdefinierten Blockliste")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "Überprüfe deine SavedVariables-Datei:\n customBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Gesundheitsprüfung")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Wenn aktiviert, werden Fähigkeiten in der Blockliste nur blockiert, wenn deine Gesundheit über dem Schwellenwert liegt.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Gesundheitsschwellenwert für Blockliste (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Fähigkeiten in der Blockliste werden nur blockiert, wenn deine Gesundheit über diesem Prozentsatz liegt.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Benutzerdefinierte Recast-Blockliste")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Füge Fähigkeits-IDs hinzu, um sie zu blockieren. Du kannst Fähigkeiten auch durch Rechtsklick auf den Aktionsleisten-Slot hinzufügen (benötigt Neuladen der UI)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "Fähigkeits-ID")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Gib die numerische Fähigkeits-ID ein (z. B. 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Zur Blockliste hinzufügen")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Recast-blockierte Fähigkeiten:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Benutzerdefinierte Recast-Blockliste aktivieren")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Aktiviert oder deaktiviert die Funktionalität der benutzerdefinierten Recast-Blockliste")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Recast-Blockzeit (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Zeit in Sekunden, unterhalb derer eine Fähigkeit in der Recast-Blockliste erneut gewirkt werden kann (1.0 = 1 Sekunde)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "Überprüfe deine SavedVariables-Datei:\n customRecastBlockList = {\n   [AbilityID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Gesundheitsprüfung")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Wenn aktiviert, werden Fähigkeiten in der Recast-Blockliste nur blockiert, wenn deine Gesundheit über dem Schwellenwert liegt.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Gesundheitsschwellenwert (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Fähigkeiten in der Recast-Blockliste werden nur blockiert, wenn deine Gesundheit über diesem Prozentsatz liegt.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "Fähigkeits-ID wurde hinzugefügt/entfernt. Wenn du keine weiteren Fähigkeiten hinzufügen möchtest, lade bitte die UI neu, damit die Änderungen angezeigt werden können")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "UI neu laden")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Später")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "OK")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Fehler: Bitte gib eine gültige Fähigkeits-ID ein")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "Fähigkeits-ID existiert nicht")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "Fähigkeits-ID ist bereits in der Blockliste")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Ressourcenbasierte Blockliste")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Füge Fähigkeits-IDs hinzu, um sie zu blockieren, wenn deine Hauptressource (Magicka oder Ausdauer) unter dem Schwellenwert liegt. Du kannst Fähigkeiten auch durch Rechtsklick auf den Aktionsleisten-Slot hinzufügen (benötigt Neuladen der UI).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Ressourcenbasierte Blockliste aktivieren")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Aktiviert oder deaktiviert die Funktionalität der ressourcenbasierten Blockliste")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Ressourcenprüfung aktivieren")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Wenn aktiviert, werden Fähigkeiten in der ressourcenbasierten Blockliste nur blockiert, wenn deine Hauptressource (Magicka oder Ausdauer) über dem Schwellenwert liegt.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Ressourcen-Schwellenwert (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Fähigkeiten in der ressourcenbasierten Blockliste werden nur blockiert, wenn deine Hauptressource (Magicka oder Ausdauer) über diesem Prozentsatz liegt.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Fähigkeit: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Magicka-Prüfung")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Aktiviert die Magicka-basierte Blockierung für diese Fähigkeit")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Blockieren, wenn Magicka unter Schwellenwert")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Fähigkeit blockieren, wenn Magicka unter dem Schwellenwert liegt (deaktivieren, um nur unterhalb zuzulassen)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Magicka-Schwellenwert (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Magicka-Prozentsatz-Schwellenwert")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Ausdauer-Prüfung")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Aktiviert die Ausdauer-basierte Blockierung für diese Fähigkeit")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Blockieren, wenn Ausdauer unter Schwellenwert")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Fähigkeit blockieren, wenn Ausdauer unter dem Schwellenwert liegt (deaktivieren, um nur unterhalb zuzulassen)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Ausdauer-Schwellenwert (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Ausdauer-Prozentsatz-Schwellenwert")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================
ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")

ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Modus umschalten (Strikt/Intelligent/Deaktiviert)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Benutzerdefinierte Blockliste umschalten")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Benutzerdefinierte Recast-Blockliste umschalten")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Hinterleisten-Funktionen umschalten")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Weave-Assistent auf der Hinterleiste umschalten")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Execute-Prüfung umschalten")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Entfernen")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Diese Fähigkeit von der Blockliste entfernen (/reloadui erforderlich)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Einstellungsmodus")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Wähle, ob die Einstellungen für alle Charaktere dieses Accounts gemeinsam genutzt (Accountweit) oder für jeden Charakter separat gespeichert werden (Pro Charakter).")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Accountweit")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Pro Charakter")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "Der Einstellungsmodus wurde geändert. UI neu laden, um die Änderungen zu übernehmen?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Letztes Menü im Kampf blockieren")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Verhindert das Öffnen des letzten Menüs (ALT) während des Kampfes.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Charaktermenü im Kampf blockieren")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Verhindert das Öffnen des Charaktermenüs (C) während des Kampfes.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Globalen Cooldown (GCD) anzeigen")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Zeigt den GCD-Indikator (von ZOS bereitgestellt) über der Aktionsleiste an.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Blocklisten nur im Kampf")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Alle benutzerdefinierten Blocklisten sind nur während des Kampfes aktiv. Außerhalb des Kampfes sind alle Blocklisten deaktiviert.")

-- =============================================================================
-- === END OF GERMAN LOCALIZATION ==============================================
-- =============================================================================