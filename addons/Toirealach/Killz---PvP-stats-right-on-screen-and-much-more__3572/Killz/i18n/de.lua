Killz = Killz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "Geladen",
    NOT_LOADED = "Nicht geladen",
    ENTERED_PVP = "PvP betreten",
    EXITED_PVP = "PvP verlassen",
    WAS_DEATH = "Du wurdest getötet von ",
    WAS_KILL = "Getötet: ",
    WAS_KILLING_BLOW = "Tödlicher Schlag auf ",
    USING = " mit ",
    SENSELESS_DEATH = "Ein sinnloser Tod ... aber er wird nicht gegen Dich angerechnet.",
    NUMBER_OF_DEATHS = "(%s Tode in Folge)",
    NUMBER_OF_KILLS = "(%s Tötungen in Folge)",
    NUMBER_OF_KILLING_BLOWS = "(%s Tödliche Schläge)",
    KILLCLSTREAK_ENDED = "Deine Tötungsserie von %d ist beendet!",
    ALL_TIME_KILLCLSTREAK = "Diese Serie von %d Tötungen in Folge ist die höchste, die du je erreicht hast!",
    KB_STREAK_ENDED = "Deine Serie von %d tödlichen Schlägen in Folge ist beendet!",
    ALL_TIME_KB_STREAK = "Deine Serie von %d tödlichen Schlägen in Folge ist die höchste, die du je erreicht hast!",
    WARNING_RELOADUI = "WARNUNG: Lädt die UI automatisch neu, wenn sie geändert wird",

    MILESTONE = {
    
        NUMBER_OF_KILLS = {	
        
            [3] = "Drei für einen!", [5] = "Blutrausch!", [8] = "Dominierend!",
            [12] = "Unaufhaltsam!", [15] = "Massaker!", [18] = "Auslöscher!",
            [21] = "Legendär!", [25] = "Völkermörder!", [28] = "Dämonisch!", 
            [32] = "Gottähnlich!", [40] = "Gelobt seist Du, Halbgott!",
            [50] = "Gelobt seist Du, Gott des Schmerzes!", 
            [60] = "Gelobt seist Du, Gott des Blutes!",
            [75] = "Gelobt seist Du, Gott der Zerstörung!",
            [100] = "Gelobt seist Du, Gott des Chaos!" 
        },
        
        NUMBER_OF_KILLING_BLOWS = {	
            [2] = "Jäger!", [3] = "Stalker!", [5] = "Killer!", [8] = "Töter!",
            [12] = "Auftragskiller!", [15] = "Massenmörder!", [18] = "Scharfrichter!",
            [21] = "Attentäter!", [25] = "Bluttrinker!", [28] = "Agent des Todes!", 
            [32] = "Sensenmann!", [40] = "Todesengel!",
            [50] = "Gott des Todes!", 
            [75] = "Offensichtlich Betrug! REPORTED!",
            [100] = "Schluss mit der Cheaten!"
        },
                
        NUMBER_OF_DEATHS = {	
            [2] = "Ehrenloser Tod!", [3] = "Fauler Zauber!", 
            [4] = "Ungerechte Benachteiligung!", [5] = "Zu lieb für ein Kämpfer!",
            [6] = "Von deiner Allianz verlassen?", [7] = "500ms Latenz?", 
            [8] = "Bösewicht ist was anderes!!", 
            [9] = "Ich hoffe, du bist gut in Prüfungen.", 
            [10] = "Hast du schon mal daran gedacht, ein Buch zu lesen, anstatt PvP zu machen?"
        },
    },

    KILLS_ABBREVIATION = "K",
    DEATHS_ABBREVIATION = "D",
    KBS_ABBREVIATION = "KB",
    AP_ABBREVIATION = "AP",
    CAMP_TIMER = "Camp Timer: %s",
    COMBAT_ENDED = "Kampf beendet",
    HIT_TYPE_DAMAGE = "Schaden",
    HIT_TYPE_HEALTH = "Leben",
    FAILED = "gescheitert ",
    POSSESSIVE = "'s ",
    BREAK_FREE = "Befrei Dich",
    ON_PREPOSITON = " auf ",
    YOU_FELL = "Du bist gefallen",
    GAINED_XP = "Du hast %d Erfahrung gesammelt",
    GAINED_AP = "Du hast %d Allianzpunkte gesammelt",
    GAINED_TELVAR = "Diese Tötung hat dir %d Telvar-Steine eingebracht",
    LOST_TELVAR = "Dein Tod hat dich %d Telvar-Steine gekostet",
    AVENGED1 = "Du hast %s gerächt",
    AVENGED2 = "(%s) durch Tötung %s",
    AVENGED3 = "(%s)",
    REVENGE1 = "Du hast dich an %s gerächt",
    REVENGE2 = "(%s)",
    Q_STATE_QUEUEING = "Warteschlange für %s",
    Q_STATE_ENTERING = "Betrete %s",
    Q_STATE_LEAVING = "Warteschlange verlassen für %s",
    Q_STATE_CONFIRMING = "Warteschlange bestätigen für %s",
    Q_STATE_WAITING = "In Warteschlange für %s",
    Q_STATE_FINISHED = "Warteschlange beendet für %s",
    Q_STATE_UNKNOWN = "Unbekannter Warteschlangenstatus für %s",
    UNKNOWN_Q = "Unbekannte Warteschlange",
    Q_NUMBER = "Nummer %d ",
    Q_TIME = "Zeit in der Warteschlange: %s",
    CONFIRM_STATS_RESET_TITLE = "Killz Session-Statistiken zurücksetzen",
    CONFIRM_STATS_RESET_TEXT = "Bist du sicher, dass du deine PvP-Sitzungsstatistiken zurücksetzen willst?",
    CONFIRM_YES = "Ja",
    CONFIRM_NO = "Nein",
    SESSION_STATS = "Session PvP-Statistiken gegen",
    LIFETIME_STATS = "Lebenslange PvP-Statistiken gegen",
    ALL_TOONS_FOR_ACCOUNT = "Wer ist das?",

    -- Slash commands

    SLASH_KZREPORT = "/kzreport",
    SLASH_KB = "/kb",
    SLASH_KZL = "/kzl",
    SLASH_KZPREFS = "/kzprefs",
    SLASH_KILLZ = "/killz",
    SLASH_PARAM_REPORT = "Report",
    SLASH_PARAM_HELP = "Hilfe",
    SLASH_PARAM_LAST = "zuletzt",
    SLASH_PARAM_SHOW = "Zeigen",
    SLASH_PARAM_HIDE = "Verstecke",
    SLASH_PARAM_IMPORT = "Import",
    SLASH_PARAM_RESET = "Zurücksetzen",
    SLASH_PARAM_WHO = "Wer",

    SLASH_CMD_KZREPORT = "/killz report or ",
    SLASH_CMD_KZREPORT2 = "/kzreport [g/s/w/y/z/g1-g5/o1-o5]",
    SLASH_CMD_KZREPORT3 = "  Statistiken in einen bestimmten Chat-Kanal ausgeben",

    SLASH_CMD_KZLAST = "/kb or",
    SLASH_CMD_KZLAST2 = "/kzl [g/s/w/y/z/g1-g5/o1-o5]",
    SLASH_CMD_KZLAST3 = "  Letzte KB im Chat-Kanal ausgeben",

    SLASH_CMD_SHOW = "/killz show - Zeige Statistikleiste",
    SLASH_CMD_HIDE = "/killz hide - Verstecke Statistikleiste",
    SLASH_CMD_RESET = "/killz reset - Setzte Statistikleiste zurück",
    SLASH_CMD_IMPORT = "/killz import - Importiere & führe Killcounter-Statistik zusammen",
    SLASH_CMD_PREFS = "/kzprefs - Öffne die Killz-Einstellungen",

    SLASH_CMD_STATS = "***Killz Statistik*** Tötungen: %d Tode: %d [Streak: %d] Tötungen/Tode: %.1f KBs: %d AP: %d",
    SLASH_CMD_TIME_STATS_SESSION = " -- Zeit der Sitzung:",
    SLASH_CMD_TIME_STATS_SESSION_DAYS = " %d T",
    SLASH_CMD_TIME_STATS_SESSION_HRS = " %d Std",
    SLASH_CMD_TIME_STATS_SESSION_MINS = " %d Min",
    SLASH_CMD_TIME_STATS_SESSION_SECS = " %d Sek",
    SLASH_CMD_TIME_STATS = " - K/Std: %.1f, D/Std: %.1f, KB/Std: %.1f",

    -- Einstellungen

    ALWAYS = "Stets",
    NEVER = "Niemals",
    IN_PVP = "Nur im PvP",

    ACCTWIDE_NAME = "Kontoweite Einstellungen verwenden",
    ACCTWIDE_TOOLTIP = "Wenn diese Funktion ausgeschaltet ist, behält jeder Charakter seine eigene Statistik.",
    STATS_BAR_HEADER = "PVP Statistikleiste",
    SHOW_STATS_NAME = "PvP-Statistikleiste anzeigen",
    SHOW_STATS_TOOLTIP = "Wann die PvP-Statistikleiste angezeigt werden soll",
    SCALE_SLIDER_NAME = "Ändern Sie die Größe der Statistikleiste um diesen Prozentsatz:",
    SCALE_SLIDER_TOOLTIP = "Verändert die Größe der PVP-Statistikleiste um den angegebenen Prozentsatz",
    LOCK_CHECKBOX_NAME = "Position der Statistikleiste sperren",
    LOCK_CHECKBOX_TOOLTIP = "Wenn EIN, können Sie den Statistikleiste nicht verschieben. Wenn AUS, können Sie den Statistikleiste überall auf dem Bildschirm verschieben.",
    HIDE_IN_COMBAT_CHECKBOX_NAME = "Statistikleiste im Kampf ausblenden?",
    HIDE_IN_COMBAT_CHECKBOX_TOOLTIP = "Wenn EIN, wird der Statistikleiste während des Kampfes ausgeblendet. Wenn AUS, wird der Statistikleiste während des Kampfes nicht ausgeblendet.",
    HIDE_IN_PVE_CHECKBOX_NAME = "Statistikleiste außerhalb von PvP-Zonen ausblenden?",
    HIDE_IN_PVE_CHECKBOX_TOOLTIP = "Wenn EIN, wird die Statistikleiste ausgeblendet, wenn du nicht im PvP bist. Bei AUS ist der Statistikleiste immer sichtbar.",
    COUNT_PVP_DEATHS_ONLY_NAME = "Nur Tötungen zählen, die von anderen Spielern verursacht werden?",
    COUNT_PVP_DEATHS_ONLY_TOOLTIP = "Wenn EIN, zählen Tode, die durch Umwelteinflüsse oder NPCs verursacht werden, nicht in deinen PvP-Statistiken. Wenn AUS, dann wird jeder Tod zählen, egal wie.",
    RESET_ONLY_ON_LOG_OR_QUIT_NAME = "Statistiken nur zurücksetzen, wenn ich mich Auslogge oder das Spiel beende.",
    RESET_ONLY_ON_LOG_OR_QUIT_TOOLTIP = "Wenn diese Funktion eingeschaltet ist, werden eure PvP-Statistiken NUR zurückgesetzt, wenn ihr euch aus einem Charakter ausloggt oder das Spiel beendet.",

    ANNOUNCEMENTS_HEADER = "Mitteilungen auf Bildschirm",
    PLAY_ANNOUNCE_SOUNDS_NAME = "Soundeffekte für durchsagen abspielen",
    PLAY_ANNOUNCE_SOUNDS_TOOLTIP = "Wenn aktiviert, werden Soundeffekte für Durchsagen abgespielt.",
    ANNOUNCE_KILLING_BLOWS_NAME = "Tötungen auf dem Bildschirm anzeigen?",
    ANNOUNCE_KILLING_BLOWS_TOOLTIP = "Wenn EIN, werden Mitteilungen für Tötungen auf dem Bildschirm ausgegeben. Wenn AUS, werden Tötungen nur im Chatfenster angezeigt.",
    ANNOUNCE_KILLING_BLOWS_COLORPICKERTIP = "Die Farbe von Tötungsmitteilungen im Chat und auf dem Bildschirm",
    ANNOUNCE_DEATHS_NAME = "Tode auf dem Bildschirm anzeigen?",
    ANNOUNCE_DEATHS_TOOLTIP = "Wenn EIN, werden Todesmeldungen an andere Spieler ausgegeben. Wenn AUS, werden PvP-Todesfälle nur im Chat-Fenster angezeigt.",
    ANNOUNCE_DEATHS_COLORPICKERTIP = "Die Farbe von Todesmitteikungen im Chat und auf dem Bildschirm",
    ANNOUNCE_KILLS_NAME = "Tötung durch ein Gruppenmitglieds auf dem Bildschirm anzeigen?",
    ANNOUNCE_KILLS_TOOLTIP = "Wenn EIN, werden Ankündigungen für Gruppenkills gemacht, bei denen du nicht den tödlichen Schlag hattest. Wenn AUS, werden diese Kill-Benachrichtigungen nur im Chat-Fenster angezeigt.",
    ANNOUNCE_KILLS_COLORPICKERTIP = "Die Farbe von Tötungsmitteilungen im Chat und auf dem Bildschirm",
    ANNOUNCE_MILESTONES_NAME = "Mitteilungen von Meilensteinen auf dem Bildschirm?",
    ANNOUNCE_MILESTONES_TOOLTIP = "Wenn EIN, werden Mitteilungen für Tötungen, tödliche Schläge und Todesmeilensteine gemacht. Wenn AUS, werden Meilensteine nur im Chat-Fenster angezeigt.",
    ADD_ACCOUNT_NAME = "Konto für Mitteilungen hinzufügen, wenn verfügbar?",
    ADD_ACCOUNT_TOOLTIP = "Wenn EIN, werden Kontonamen (z. B. @XXXXX) am Ende von Mitteilungen hinzugefügt.",
    KILLZ_TAB_HEADER = "Killz Chatreiter",
    ADD_KILLZ_TAB_NAME = "Füge 'Killz' als Chatreiter hinzu?",
    ADD_KILLZ_TAB_TOOLTIP = "Hinzufügen eines Chatreiters mit Name 'Killz', um den PVP-Kills-Feed und/oder ein detailliertes Kampfprotokoll anzuzeigen.",
    ADD_PVP_KILL_FEED_TO_LOG_NAME = "PVP Kill-Feed Informationen anzeigen?",
    ADD_PVP_KILL_FEED_TO_LOG_TOOLTIP = "PVP Kill-Feed Informationen werden im Killz Chatreiter ausgegeben.",
    ADD_PVP_KILL_FEED_TO_MAIN_NAME = "     Im Haupt anzeigen?",
    ADD_PVP_KILL_FEED_TO_MAIN_TOOLTIP = "PVP Kill-Feed Informationen werden im Haupt Chatreiter ausgegeben.",
    SHOW_AP_GAINED_NAME = "Erzielte Allianzpunkte anzeigen?",
    SHOW_AP_GAINED_TOOLTIP = "Zeigt Allianzpunkte aus Tötungen und Eroberungen an.",
    SHOW_TELVAR_GAINED_NAME = "Gewonnene oder verlorene Tel Var-Steine anzeigen?",
    SHOW_TELVAR_GAINED_TOOLTIP = "Tel Var-Steine anzeigen, die im Kampf gewonnen oder verloren wurden.",
    SHOW_MOB_KILLS_NAME = "Tötungen/DPS für NPCs & Monster-Kills anzeigen?",
    SHOW_MOB_KILLS_TOOLTIP = "Tötungsinformationen, einschließlich der durchschnittlichen DPS, für getötete NPCs und Monster, sowie für getötete Spieler anzeigen.",
    SHOW_COMBAT_LOG_NAME = "Detailliertes Kampfprotokoll anzeigen?",
    SHOW_COMBAT_LOG_TOOLTIP = "Ein detailliertes Kampfprotokoll wird für jede Kampfbegegnung angezeigt.",
    AUTO_CONFIRM_QUEUE_NAME = "Bestätige automatisch den Eintritt nach Cyrodiil",
    ADD_CONFIRM_QUEUE_TOOLTIP = "Bestätige automatisch den Dialog zum Eintritt nach Cyrodill, wenn er auf dem Bildschirm erscheint",
    SHOW_SESSION_TIME_NAME = "Statistik der PvP-Sessionzeit in Berichten anzeigen?",
    SHOW_SESSION_TIME_TOOLTIP = "Anzeige der gesamten PvP-Sessionzeit und der zugehörigen Statistiken (z.B. Kills/Minute) im Killz Report (/kzreport)",
    TELVAR_HEADER = "Telvar-Retter",
    TELVAR_SAVER_NAME = "Automatisches Porten nach Cyrodiil, wenn meine Telvar-Steine über diesen Wert überschreiten:",
    TELVAR_SAVER_TOOLTIP = "Sie werden automatisch in Ihre Heimat-Cyrodill-Kampagne oder eine zufällige Cyrodill-Kampagne reingeportet, wenn Sie sich in der Kaiserstadt befinden und dies jedes Mal, wenn Sie genug Telvar-Steine gesammelt haben,wenn die angegebene Menge überschritten wurde. Um dies auszuschalten, setzen Sie die Zahl auf 0.",
    TELVAR_SAVER_GROUPQ_NAME = "     Warteschlange als Gruppe, wenn ich die Krone habe?",
    TELVAR_SAVER_GROUPQ_TOOLTIP = "Wenn Sie der Gruppenleiter sind, wird Ihre gesamte Gruppe automatisch in die Warteschlange gestellt.",

    -- Combat log

    ACTION_RESULT_VERBS = {

        -- If the source & target are both a player, that means that the player's specified attack 
        -- listed in the action failed (check isError?) for the reason specified in the verb.
        --
        -- It can be more generically described using an ability failure sentence construction:
        --
        -- The second sentence construction is used describe that an :
        -- sourceName..(with "'s" added or no sourceName if player is source)..abilityName..(" on "..target..)" failed ("..verb..")"
        -- 
        -- The third sentence construction describes how the verb affected the target and ability:
        -- targetName verb ability (from sourceName in not player) (for hitValue)

        -- These are all 'hits' which use standard sentence structure
        [ACTION_RESULT_DAMAGE] = "Treffer",
        [ACTION_RESULT_CRITICAL_DAMAGE] = "Kritischer Treffer",
        [ACTION_RESULT_PRECISE_DAMAGE] = "Präziser Treffer",
        [ACTION_RESULT_WRECKING_DAMAGE] = "Wrack",
        [ACTION_RESULT_DOT_TICK] = "Treffer",
        [ACTION_RESULT_DOT_TICK_CRITICAL] = "Kritischer Treffer",

        -- These are all 'heals' which use standard sentence structure
        [ACTION_RESULT_HEAL] = "Geheilt",
        [ACTION_RESULT_CRITICAL_HEAL] = "Kritisch Geheilt",
        [ACTION_RESULT_HOT_TICK] = "Geheilt",
        [ACTION_RESULT_HOT_TICK_CRITICAL] = "Kritisch Geheilt",

        -- These are all 'deaths' which use standard sentence structure
        [ACTION_RESULT_DIED] = "Getötet",
        [ACTION_RESULT_DIED_XP] = "Getötet",
        [ACTION_RESULT_KILLING_BLOW] = "hatte den tödlichen Schlag gegen",

        -- For the following results use:
        -- if sourceName != targetName use standard sentence construction
        -- if sourceName == targetName == playername then use ability failed construction
    
        -- I think these are all always ability failed?
            
        [ACTION_RESULT_SILENCED] = "zum Schweigen gebracht", 
        [ACTION_RESULT_STUNNED] = "betäubt", 
        [ACTION_RESULT_SNARED] = "Gemeinsam",
        [ACTION_RESULT_BUSY] = "Belegt",
        [ACTION_RESULT_BAD_TARGET] = "Falsches Ziel",
        [ACTION_RESULT_TARGET_DEAD] = "Tote Zielperson",
        [ACTION_RESULT_CASTER_DEAD] = "Nachlaufende Tot",
        [ACTION_RESULT_TARGET_NOT_IN_VIEW] = "Außer Sichtweite",
        [ACTION_RESULT_ABILITY_ON_COOLDOWN] = "Abklingende Effekte",
        [ACTION_RESULT_INSUFFICIENT_RESOURCE] = "Keine Ressourcen",
        [ACTION_RESULT_TARGET_OUT_OF_RANGE] = "Außerhalb der Reichweite",
        [ACTION_RESULT_FAILED] = "Gescheitert",

    
        -- For the following results use:
        -- if sourceName != targetName use: source verb target's ability (for hitValue) 
        -- if sourceName == targetName == playername then use ability failed construction
    
        [ACTION_RESULT_REFLECTED] = "reflektiert",
        [ACTION_RESULT_ABSORBED] = "absorbiert",
        [ACTION_RESULT_PARRIED] = "pariert",
        [ACTION_RESULT_DODGED] = "ausgewichen", 
        [ACTION_RESULT_BLOCKED] = "geblockt", 
        [ACTION_RESULT_BLOCKED_DAMAGE] = "geblockt", 
        [ACTION_RESULT_PARTIAL_RESIST] = "teilweise widerstanden", 
        [ACTION_RESULT_RESIST] = "widersetzt",

        -- For the following results use:
        -- if sourceName != targetName use standard sentence construction 
        -- if sourceName == targetName == playername then use ability failed construction    

        [ACTION_RESULT_MISS] = "verpasst",
        [ACTION_RESULT_DEFENDED] = "verteidigt",
        [ACTION_RESULT_INTERRUPT] = "unterbrochen",
        [ACTION_RESULT_FEARED] = "gefürchtet",
        [ACTION_RESULT_DISORIENTED] ="verwirrt",
        [ACTION_RESULT_LEVITATED] = "schwebend",
        [ACTION_RESULT_INTERCEPTED] = "abgefangen",

        [ACTION_RESULT_FALL_DAMAGE] = "fallen",
        [ACTION_RESULT_CANT_SEE_TARGET] = "kann das Ziel nicht sehen",
    
        -- With these CC effects as well as silenced, stunned and snared above, there are two cases
        -- First if source & target are different then just use verb and not ability
        -- second, if src & target are both the player then the ability is most
        -- likely break free and they are breaking free from the CC effect.
    
        [ACTION_RESULT_DISARMED] = "entwaffnet",
        [ACTION_RESULT_OFFBALANCE] = "%s aus dem Gleichgewicht gebracht",
        [ACTION_RESULT_WEAPONSWAP] = "waffentauglich",
        [ACTION_RESULT_DAMAGE_SHIELDED] = "geblockt",
        [ACTION_RESULT_STAGGERED] = "gestaffelt",
        [ACTION_RESULT_KNOCKBACK] = "knockback",
        [ACTION_RESULT_ROOTED] = "rooted",
        
        [ACTION_RESULT_RESURRECT] = "wiederbelebt",
    },

    -- the damage / heal preposition is "for" except in the following cases
    ACTION_RESULT_PREPOSITIONS = {
        DEFAULT = "für",
        [ACTION_RESULT_DAMAGE_SHIELDED] = "absorbiert",
        [ACTION_RESULT_ABSORBED] = "absorbiert",
        [ACTION_RESULT_REFLECTED] = "unter",
        [ACTION_RESULT_PARRIED] = "unter",
        [ACTION_RESULT_DODGED] = "unter", 
        [ACTION_RESULT_BLOCKED] = "unter", 
        [ACTION_RESULT_BLOCKED_DAMAGE] = "unter", 
        [ACTION_RESULT_PARTIAL_RESIST] = "unter", 
        [ACTION_RESULT_RESIST] = "unter",
    },

}

-- ONLY copy these strings over if all the English strings have been translated
-- We know this is true if the size of both tables is the same
if Killz.Localization and #localization == #Killz.Localization then
    ZO_ShallowTableCopy(localization, Killz.Localization)
end