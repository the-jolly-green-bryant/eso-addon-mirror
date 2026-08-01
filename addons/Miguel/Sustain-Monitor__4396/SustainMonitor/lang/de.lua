-- SustainMonitor: Deutsche Lokalisierung
SustainMonitor = SustainMonitor or {}

local L = SustainMonitor.L
if not L then return end

-- Allgemein
L.ADDON_DESCRIPTION     = "Echtzeit Ressourcen-Dashboard mit Burn-Rate und Restzeit-Vorhersage"

-- Ressourcen
L.POTION                = "Trank"

-- Anzeige
L.READY                 = "Bereit"
L.NO_DATA               = "---"

-- Styles
L.STYLE_SIMPLE          = "Einfach"
L.STYLE_ANALYTICAL      = "Analytisch"
L.STYLE_COMBAT          = "Kampf"

-- Action Prompts
L.PROMPT_HEAVY_ATTACK   = "HEAVY ATTACK"
L.PROMPT_USE_POTION     = "TRANK NUTZEN"

-- Settings: Kategorien
L.SETTINGS_GENERAL      = "Allgemein"
L.SETTINGS_DISPLAY      = "Anzeige"
L.SETTINGS_CALCULATION  = "Berechnung"
L.SETTINGS_WARNINGS     = "Warnungen"
L.SETTINGS_BEHAVIOR     = "Verhalten"
L.SETTINGS_HEAVY_ATTACK = "Heavy Attack Vorschlag"

-- Settings: Allgemein
L.SETTING_ENABLED       = "Addon aktivieren"
L.SETTING_ENABLED_TT    = "Sustain Monitor Overlay aktivieren oder deaktivieren"
L.SETTING_LOCKED        = "Position sperren"
L.SETTING_LOCKED_TT     = "HUD-Position sperren um versehentliches Verschieben zu verhindern. Wenn gesperrt ist das HUD klick-durchl\195\164ssig."
L.SETTING_SCALE         = "UI-Skalierung"
L.SETTING_SCALE_TT      = "HUD-Element skalieren (0.5 = halb so gro\195\159, 2.0 = doppelt so gro\195\159)"
L.SETTING_RESET_POS     = "Position zur\195\188cksetzen"
L.SETTING_RESET_POS_TT  = "HUD auf die Standardposition zur\195\188cksetzen"

-- Settings: Anzeige
L.SETTING_STYLE         = "Anzeige-Stil"
L.SETTING_STYLE_TT      = "Einfach: saubere Minimal-Anzeige. Analytisch: mit Live-Ressourcen-Graphen. Kampf: gro\195\159e Zahlen mit Aktions-Hinweisen in Bildschirmmitte."
L.SETTING_SHOW_MAGICKA      = "Magicka anzeigen"
L.SETTING_SHOW_MAGICKA_TT   = "Magicka Burn-Rate und Restzeit anzeigen"
L.SETTING_SHOW_STAMINA      = "Stamina anzeigen"
L.SETTING_SHOW_STAMINA_TT   = "Stamina Burn-Rate und Restzeit anzeigen"
L.SETTING_SHOW_HEALTH       = "Leben anzeigen"
L.SETTING_SHOW_HEALTH_TT    = "Leben Burn-Rate und Restzeit anzeigen"
L.SETTING_SHOW_POTION       = "Trank-Timer anzeigen"
L.SETTING_SHOW_POTION_TT    = "Trank-Cooldown Timer anzeigen"
L.SETTING_SHOW_BARS         = "Ressourcen-Balken anzeigen"
L.SETTING_SHOW_BARS_TT      = "Mini-Ressourcenbalken neben den Werten anzeigen"
L.SETTING_SHOW_TIME         = "Restzeit anzeigen"
L.SETTING_SHOW_TIME_TT      = "Gesch\195\164tzte Zeit bis die Ressource aufgebraucht ist"
L.SETTING_COMPACT           = "Kompakter Modus"
L.SETTING_COMPACT_TT        = "Kompakteres Anzeige-Layout verwenden (nur Einfach-Stil)"
L.SETTING_SHOW_GRAPH        = "Ressourcen-Graph anzeigen"
L.SETTING_SHOW_GRAPH_TT     = "Live-Sparkline-Graph des Ressourcenverlaufs anzeigen (Analytisch-Stil)"
L.SETTING_SHOW_CASTS        = "Verbleibende Casts anzeigen"
L.SETTING_SHOW_CASTS_TT     = "[X] neben der Restzeit anzeigen: wie viele Abilities du noch casten kannst basierend auf deinen ausger\195\188steten Skills (aktualisiert bei Bar-Swap)"

-- Settings: Berechnung
L.SETTING_SMOOTHING         = "Gl\195\164ttungsfaktor"
L.SETTING_SMOOTHING_TT      = "Bestimmt wie reaktiv die Burn-Rate Anzeige ist. Niedriger = stabiler, H\195\182her = reaktiver. Standard: 0.3"

-- Settings: Heavy Attack
L.SETTING_HA_ENABLED        = "Vorschlag aktivieren"
L.SETTING_HA_ENABLED_TT     = "Visuellen und akustischen Hinweis anzeigen wenn ein Heavy Attack sinnvoll w\195\164re"
L.SETTING_HA_THRESHOLD      = "Zeit-Schwellwert (Sekunden)"
L.SETTING_HA_THRESHOLD_TT   = "Heavy Attack vorschlagen wenn Restzeit unter diesen Wert f\195\164llt"
L.SETTING_HA_RESOURCE_PCT   = "Ressourcen-Schwellwert (%)"
L.SETTING_HA_RESOURCE_PCT_TT = "Nur vorschlagen wenn Ressource auch unter diesem Prozentwert liegt"

-- Settings: Warnungen
L.SETTING_WARNINGS_ON       = "Warnungen aktivieren"
L.SETTING_WARNINGS_ON_TT    = "Visuelle Warnungen bei kritisch niedrigen Ressourcen aktivieren"
L.SETTING_THRESH_1          = "Warnstufe 1 (Gelb)"
L.SETTING_THRESH_1_TT       = "Restzeit-Schwellwert in Sekunden f\195\188r gelbe Warnung"
L.SETTING_THRESH_2          = "Warnstufe 2 (Orange)"
L.SETTING_THRESH_2_TT       = "Restzeit-Schwellwert in Sekunden f\195\188r orange Warnung"
L.SETTING_THRESH_3          = "Warnstufe 3 (Rot)"
L.SETTING_THRESH_3_TT       = "Restzeit-Schwellwert in Sekunden f\195\188r rote/blinkende Warnung"
L.SETTING_WARN_SOUND        = "Warn-Sound"
L.SETTING_WARN_SOUND_TT     = "Einen Sound bei Erreichen von Warnstufe 2 oder 3 abspielen"
L.SETTING_WARN_FLASH        = "Warn-Blinken"
L.SETTING_WARN_FLASH_TT     = "Ressourcen-Anzeige bei Erreichen von Warnstufe 3 blinken lassen"
L.SETTING_SOUND_WARNING     = "Ressourcen-Warn-Sound"
L.SETTING_SOUND_WARNING_TT  = "Sound bei Erreichen einer Warnstufe. Bei Auswahl wird eine Vorschau abgespielt."
L.SETTING_SOUND_HEAVY       = "Heavy Attack Sound"
L.SETTING_SOUND_HEAVY_TT    = "Sound wenn ein Heavy Attack vorgeschlagen wird. Bei Auswahl wird eine Vorschau abgespielt."
L.SETTING_SOUND_POTION      = "Trank-Bereit Sound"
L.SETTING_SOUND_POTION_TT   = "Sound wenn dein Trank wieder verf\195\188gbar ist. Bei Auswahl wird eine Vorschau abgespielt."

-- Settings: Alert-Darstellung
L.SETTINGS_ALERT_APPEARANCE     = "Alert-Darstellung"
L.SETTING_COLOR_WARN_YELLOW     = "Warnfarbe 1 (Gelb)"
L.SETTING_COLOR_WARN_YELLOW_TT  = "Farbe f\195\188r die erste Warnstufe (Standard: Gelb)"
L.SETTING_COLOR_WARN_ORANGE     = "Warnfarbe 2 (Orange)"
L.SETTING_COLOR_WARN_ORANGE_TT  = "Farbe f\195\188r die zweite Warnstufe (Standard: Orange)"
L.SETTING_COLOR_WARN_RED        = "Warnfarbe 3 (Rot)"
L.SETTING_COLOR_WARN_RED_TT     = "Farbe f\195\188r die dritte Warnstufe und Blinken (Standard: Rot)"
L.SETTING_ALERT_FONT_SIZE       = "Alert-Schriftgr\195\182\195\159e"
L.SETTING_ALERT_FONT_SIZE_TT    = "Schriftgr\195\182\195\159e f\195\188r die Aktions-Hinweise in Bildschirmmitte (Heavy Attack / Trank nutzen)"

-- Settings: Trank-Darstellung
L.SETTINGS_POTION_APPEARANCE        = "Trank-Darstellung"
L.SETTING_COLOR_POTION              = "Trank-Farbe"
L.SETTING_COLOR_POTION_TT           = "Farbe f\195\188r das Trank-Label und Cooldown-Highlight (Standard: Cyan)"
L.SETTING_COLOR_POTION_READY        = "Trank-Bereit Farbe"
L.SETTING_COLOR_POTION_READY_TT     = "Farbe wenn der Trank bereit ist und Ressourcen in Ordnung sind (Standard: Gr\195\188n)"
L.SETTING_POTION_FONT_SIZE          = "Trank-Zeile Schriftgr\195\182\195\159e"
L.SETTING_POTION_FONT_SIZE_TT       = "Schriftgr\195\182\195\159e f\195\188r die Trank-Timer Zeile im HUD"

-- Settings: Verhalten
L.SETTING_HIDE_OOC          = "Au\195\159erhalb Kampf ausblenden"
L.SETTING_HIDE_OOC_TT       = "HUD automatisch ausblenden wenn nicht im Kampf"
L.SETTING_FADE_DELAY        = "Ausblend-Verz\195\182gerung (Sekunden)"
L.SETTING_FADE_DELAY_TT     = "Sekunden nach Kampfende bevor das HUD ausgeblendet wird"

-- Settings: Ressourcen-Fokus
L.SETTING_FOCUS             = "Ressourcen-Fokus"
L.SETTING_FOCUS_TT          = "Welche Ressource bei Warnungen und Alerts priorisiert wird. Auto erkennt basierend auf deinem Kampfverhalten."
L.FOCUS_AUTO                = "Auto (erkennen)"
L.FOCUS_ALL                 = "Alle Ressourcen"
L.FOCUS_MAGICKA             = "Magicka"
L.FOCUS_STAMINA             = "Stamina"
L.FOCUS_HEALTH              = "Leben"
L.FOCUS_MISMATCH            = "Fokus!"

-- Settings: Graph-Stil
L.SETTING_GRAPH_STYLE       = "Graph-Stil"
L.SETTING_GRAPH_STYLE_TT   = "Visueller Stil f\195\188r den Ressourcenverlauf-Graphen im Analytisch-Modus"
L.GRAPH_STYLE_LINE          = "Linien-Graph"
L.GRAPH_STYLE_BAR           = "Balken-Diagramm"

-- Settings: Debug
L.SETTINGS_DEBUG            = "Entwickler"
L.SETTING_DEBUG_MODE        = "Debug-Modus"
L.SETTING_DEBUG_MODE_TT     = "Debug-Nachrichten im Chat ausgeben (auch per /sm debug umschaltbar)"

-- Slash-Kommandos
L.SLASH_HELP = "Sustain Monitor Befehle:\n/sm - Hilfe anzeigen\n/sm toggle - HUD umschalten\n/sm sounds - Test-Sounds abspielen\n/sm debug - Debug-Modus umschalten\n/sm dump - Diagnose ausgeben"
