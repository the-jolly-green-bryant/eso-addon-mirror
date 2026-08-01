local localization = {
    en = {
        ALL_CAMPAIGNS_LABEL = "All Campaigns",
        ALL_CAMPAIGNS_RULES = "Select a campaign for details",
        DEATH_PROMPT_RESURRECT_RESPAWN = "Respawn",
        DEATH_PROMPT_RESURRECT_WAIT = "Wait",
        DEATH_PROMPT_RESURRECT_AUTO_DECLINE_TEXT = "Declining resurrection by |cffffff<<1>>|r shortly.",
        RESURRECT_AUTO_DECLINE_MESSAGE = "|cffffff<<1>>|r wants to resurrect you. Declining in |cffffff<<2>>|r.",
        RESURRECT_RECEIVED_NOTIFICATION = "%s wants to resurrect you.", -- TODO use zo_strformat
        RESURRECT_ACCEPTED_NOTIFICATION = "%s resurrected you.", -- TODO use zo_strformat
        RESURRECT_DECLINED_NOTIFICATION = "You declined the resurrection attempt of %s.", -- TODO use zo_strformat
        TARGET_RESURRECT_RECEIVED_NOTIFICATION = "You offered a resurrection to %s.", -- TODO use zo_strformat
        TARGET_RESURRECT_ACCEPTED_NOTIFICATION = "%s accepted your resurrection.", -- TODO use zo_strformat
        TARGET_RESURRECT_DECLINED_NOTIFICATION = "%s declined your resurrection.", -- TODO use zo_strformat
        PLAYER_KILL_LAST_HIT_NOTIFICATION = "Your %s killed %s for %s", -- TODO use zo_strformat
        PLAYER_KILL_DEATH_NOTIFICATION = "You have been killed by %s %s", -- TODO use zo_strformat
        PLAYER_KILL_ASSIST_NOTIFICATION = "You assisted in killing %s", -- TODO use zo_strformat
        KILL_LAST_HIT_NOTIFICATION = "Your %s killed %s", -- TODO use zo_strformat
        KILL_DEATH_NOTIFICATION = "You have been killed by %s %s", -- TODO use zo_strformat
        KILL_SUICIDE_NOTIFICATION = "You succumbed to %s", -- TODO use zo_strformat

        KEEP_STATUS_SIEGE_WEAPON_COUNT = "<<1>> <<2>> |cffffffsieges|r",
        KEEP_STATUS_UNDER_ATTACK = "<<1>> |cffffffis under attack|r",
        KEEP_STATUS_UNDER_ATTACK_WITH_SIEGES = "<<1>> |cffffffis under attack (|r<<2>>|cffffff)|r",
        KEEP_STATUS_DEFENDED = "<<1>> |cffffffhas been successfully defended|r",
        KEEP_STATUS_DEFENDED_BY = "<<1>> |cffffffhas been defended by|r <<2>>",
        KEEP_STATUS_LOST = "<<1>> |cffffffhas been lost to|r <<2>>",
        KEEP_STATUS_LOST_TO = "<<1>> |cffffffhas been taken by|r <<2>>",
        KEEP_STATUS_CONQUERED = "<<1>> |cffffffhas been successfully conquered|r",

        LINK_TO_CHAT = GetString(SI_ITEM_ACTION_LINK_TO_CHAT),

        SETTINGS_CAMPAIGN_BROWSER_TITLE = "Campaign Browser Improvements",
        SETTINGS_CAMPAIGN_BROWSER_OVERVIEW_LABEL = "Campaign Overview Category",
        SETTINGS_CAMPAIGN_BROWSER_OVERVIEW_DESCRIPTION = "Adds a new category to the campaign browser where all available campaigns are visible at once",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_LABEL = "Campaign Auto Join",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_DESCRIPTION = "Enter the campaign automatically after x seconds when the queue is ready. You can prevent the auto join by declining once",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_TIMEOUT_LABEL = "Campaign Auto Join Timeout",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_TIMEOUT_DESCRIPTION = "Determines how long to wait before to join the campaign automatically",
        SETTINGS_CAMPAIGN_QUEUE_SUPRESS_DIALOG_LABEL = "Suppress Campaign Join Dialog",
        SETTINGS_CAMPAIGN_QUEUE_SUPRESS_DIALOG_DESCRIPTION = "Instead of asking for confirmation, join the campaign directly when you press accept",

        SETTINGS_RESURRECTION_TITLE = "Resurrection Improvements",
        SETTINGS_RESURRECTION_AUTO_DECLINE_LABEL = "Resurrection Auto Decline",
        SETTINGS_RESURRECTION_AUTO_DECLINE_DESCRIPTION = "Automatically decline a resurrection request that you receive after x seconds in order to shorten the time you prevent your benefactor from resurrecting others in case you are away. You can prevent the auto decline by pressing wait/decline.",
        SETTINGS_RESURRECTION_AUTO_DECLINE_TIMEOUT_LABEL = "Resurrection Auto Decline Timeout",
        SETTINGS_RESURRECTION_AUTO_DECLINE_TIMEOUT_DESCRIPTION = "Determines how long to wait before you decline a resurrection request automatically",
        SETTINGS_RESURRECTION_NOTIFICATIONS_LABEL = "Resurrection Chat Notification",
        SETTINGS_RESURRECTION_NOTIFICATIONS_DESCRIPTION = "Shows a message in chat about resurrections on other players or yourself",

        SETTINGS_ATTRIBUTE_BARS_TITLE = "Attribute Bar Improvements",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_LABEL = "Show mutation colors",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_DESCRIPTION = "Renders the target health bar of players in different colors when they are Vampires or Werewolfs",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_START_LABEL = "Werewolf Gradient Start Color",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_START_DESCRIPTION = "The middle part of the target health bar",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_END_LABEL = "Werewolf Gradient End Color",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_END_DESCRIPTION = "The outer end of the target health bar",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_START_LABEL = "Vampire Gradient Start Color",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_START_DESCRIPTION = "The middle part of the target health bar",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_END_LABEL = "Vampire Gradient End Color",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_END_DESCRIPTION = "The outer end of the target health bar",

        targetHealthBar = "Target Health Bar",
        playerHealthBar = "Player Health Bar",
        playerMagickaBar = "Player Magicka Bar",
        playerStaminaBar = "Player Stamina Bar",

        SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_TITLE = "Attribute Bar Numbers",
        SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_LABEL = "Show numbers on attribute bars",
        SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_DESCRIPTION = "Shows numbers on player attribute bars and target health bar",
        SETTINGS_ATTRIBUTE_BAR_TEXT_ENABLED_TITLE = "Show <<1>> numbers",
        SETTINGS_ATTRIBUTE_BAR_TEXT_ENABLED_DESCRIPTION = "Shows numbers on the <<1>> when enabled",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_TITLE = "<<1>> mode",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_DESCRIPTION = "Determines how numbers on the <<1>> should be represented",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_PERCENTAGE_LABEL = "show percentage",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_PERCENTAGE_TOOLTIP = "shows something like '50% / 100%'",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_ABSOLUTE_LABEL = "show absolute value",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_ABSOLUTE_TOOLTIP = "shows something like '5000 / 10000'",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_BOTH_LABEL = "show both",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_BOTH_TOOLTIP = "shows something like '5000 / 10000 (50% / 100%)'",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_TITLE = "<<1>> format",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_DESCRIPTION = "Determines how absolute numbers on the <<1>> should be formatted",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_RAW_LABEL = "raw",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_RAW_TOOLTIP = "shows something like '10000'",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_COMMA_LABEL = "comma separated",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_COMMA_TOOLTIP = "shows something like '10,000'",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_SHORT_LABEL = "shortened",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_SHORT_TOOLTIP = "shows something like '10.0k'",

        SETTINGS_TARGET_FRAME_CLASS_ICON_LABEL = "Show player class icons",
        SETTINGS_TARGET_FRAME_CLASS_ICON_DESCRIPTION = "Inserts a class icon between the name and alliance rank icon of players",
        SETTINGS_TARGET_FRAME_CLASS_LEADERBOARD_RANK_LABEL = "Show player class leaderboard rank",
        SETTINGS_TARGET_FRAME_CLASS_LEADERBOARD_RANK_DESCRIPTION = "Adds the class leaderboard rank of the target player below the class icon",
        SETTINGS_TARGET_FRAME_ALLIANCE_LEADERBOARD_RANK_LABEL = "Show player alliance leaderboard rank",
        SETTINGS_TARGET_FRAME_ALLIANCE_LEADERBOARD_DESCRIPTION = "Adds the alliance leaderboard rank of the target player below the class icon",

        SETTINGS_STEALTH_INDICATOR_TITLE = "Stealth Indicator",
        SETTINGS_STEALTH_INDICATOR_LABEL = "Stealth Indicator",
        SETTINGS_STEALTH_INDICATOR_DESCRIPTION = "Enables display of current type of stealth state (hidden or stealthed)",
        SETTINGS_STEALTH_INDICATOR_ALPHA_LABEL = "Indicator Alpha",
        SETTINGS_STEALTH_INDICATOR_ALPHA_DESCRIPTION = "Transparency of the indicator icons (0 = invisible, 100 = opaque)",
        SETTINGS_STEALTH_INDICATOR_HIDDEN_COLOR_LABEL = "Hidden Indicator Color",
        SETTINGS_STEALTH_INDICATOR_HIDDEN_COLOR_DESCRIPTION = "Color for the 'hidden' indicator",
        SETTINGS_STEALTH_INDICATOR_STEALTHED_COLOR_LABEL = "Stealthed Indicator Color",
        SETTINGS_STEALTH_INDICATOR_STEALTHED_COLOR_DESCRIPTION = "Color for the 'stealthed' indicator",

        SETTINGS_MISC_TITLE = "Miscellaneous Fixes and Improvements",
        SETTINGS_KEEP_CLAIM_DIALOG_FILTER_ALLIANCE_LABEL = "Keep Claim Alliance Filter",
        SETTINGS_KEEP_CLAIM_DIALOG_FILTER_ALLIANCE_DESCRIPTION = "Hides guilds from other alliances that you are a member of in the keep claim dialog, because they cannot be selected anyways",
        SETTINGS_KEEP_CLAIM_UPDATE_TIMER_FIX_LABEL = "Keep Claim Update Timer Fix",
        SETTINGS_KEEP_CLAIM_UPDATE_TIMER_FIX_DESCRIPTION = "Fixes the frozen countdown on the keep claim dialog",
        SETTINGS_QUICKSLOT_FIX_LABEL = "Quickslot Scroll Fix",
        SETTINGS_QUICKSLOT_FIX_DESCRIPTION = "Prevents the quickslot item selection from being reset to top when a battle is going on nearby",
        SETTINGS_QUICKSLOT_CONSOLIDATE_ITEMS_LABEL = "Consolidate quickslot items",
        SETTINGS_QUICKSLOT_CONSOLIDATE_ITEMS_DESCRIPTION = "Shows items of the same type in one stack, even when they exceed the allowed stack size",
        SETTINGS_MAP_OBJECTIVES_TAB_LABEL = "Map Objectives Tab",
        SETTINGS_MAP_OBJECTIVES_TAB_DESCRIPTION = "Adds a new tab to the world map, which shows a list of objectives in Cyrodiil. Only shows up after the campaign state is first initialized",
        SETTINGS_SHOW_CYRODIIL_MAP_IN_GATES_LABEL = "Show Cyrodiil map in gates",
        SETTINGS_SHOW_CYRODIIL_MAP_IN_GATES_DESCRIPTION = "Automatically switch to the Cyrodiil map when you open the map inside an alliance gate",
        SETTINGS_MAP_OBJECTIVE_LEVEL_LABEL = "Map Objective Levels",
        SETTINGS_MAP_OBJECTIVE_LEVEL_DESCRIPTION = "Displays the current keep or resource level after the keep name on the world map and compass",
        SETTINGS_KEEP_STATUS_NOTIFICATIONS_LABEL = "Display Keep Status Notifications",
        SETTINGS_KEEP_STATUS_NOTIFICATIONS_DESCRIPTION = "Print a message to chat whenever the state of a keep changes",
        SETTINGS_KILL_NOTIFICATIONS_LABEL = "Display Kill Notifications",
        SETTINGS_KILL_NOTIFICATIONS_DESCRIPTION = "Print a message to chat whenever you kill someone or get killed",
        SETTINGS_NPC_KILL_NOTIFICATIONS_LABEL = "Enable NPC Kill Notifications",
        SETTINGS_NPC_KILL_NOTIFICATIONS_DESCRIPTION = "Also prints a message to chat whenever you kill NPCs",
        SETTINGS_ABILITY_LINK_MENU_ENTRIES_LABEL = "Show Ability Link Menu Entries",
        SETTINGS_ABILITY_LINK_MENU_ENTRIES_DESCRIPTION = "Adds context menu entries to put ability links into chat",
        SETTINGS_ENHANCE_CP_BAR_TOOLTIP_LABEL = "Enhance Champion Bar Tooltip",
        SETTINGS_ENHANCE_CP_BAR_TOOLTIP_DESCRIPTION = "Adds enlightenment pool fill percentage to the CP bar tooltip in the character menu",
    },
    de = {
        ALL_CAMPAIGNS_LABEL = "Alle Kampagnen",
        ALL_CAMPAIGNS_RULES = "Wähle eine Kampagne für mehr Details",
        DEATH_PROMPT_RESURRECT_RESPAWN = "Wiederbeleben",
        DEATH_PROMPT_RESURRECT_WAIT = "Warten",
        DEATH_PROMPT_RESURRECT_AUTO_DECLINE_TEXT = "|cffffff<<1>>|r lehnte die Wiederbelebung ab.",
        RESURRECT_AUTO_DECLINE_MESSAGE = "|cffffff<<1>>|r möchte dich wiederbeleben. Ablehnen in |cffffff<<2>>|r.",
        RESURRECT_RECEIVED_NOTIFICATION = "%s möchte dich wiederbeleben.", -- TODO use zo_strformat
        RESURRECT_ACCEPTED_NOTIFICATION = "%s hat dich wiederbelebt.", -- TODO use zo_strformat
        RESURRECT_DECLINED_NOTIFICATION = "Du hast den Wiederbelebungsversuch von %s abgelehnt.", -- TODO use zo_strformat
        TARGET_RESURRECT_RECEIVED_NOTIFICATION = "Du versuchst %s wiederzubeleben.", -- TODO use zo_strformat
        TARGET_RESURRECT_ACCEPTED_NOTIFICATION = "%s hat die Wiederbelebung akzeptiert.", -- TODO use zo_strformat
        TARGET_RESURRECT_DECLINED_NOTIFICATION = "%s hat die Wiederbelebung abgelehnt.", -- TODO use zo_strformat
        PLAYER_KILL_LAST_HIT_NOTIFICATION = "%s tötete %s +%s", -- TODO use zo_strformat
        PLAYER_KILL_DEATH_NOTIFICATION = "Du wurdest getötet durch %s %s", -- TODO use zo_strformat
        PLAYER_KILL_ASSIST_NOTIFICATION = "Du hast geholfen %s zu töten", -- TODO use zo_strformat
        KILL_LAST_HIT_NOTIFICATION = "%s tötete %s", -- TODO use zo_strformat
        KILL_DEATH_NOTIFICATION = "Von %s getötet mit %s", -- TODO use zo_strformat
        KILL_SUICIDE_NOTIFICATION = "Du erliegst %s", -- TODO use zo_strformat

        KEEP_STATUS_SIEGE_WEAPON_COUNT = "<<!AC:1>> <<!AC:2>> |cffffffBelagerungswaffen|r",
        KEEP_STATUS_UNDER_ATTACK = "<<!AC:1>> |cffffffwird angegriffen|r",
        KEEP_STATUS_UNDER_ATTACK_WITH_SIEGES = "<<!AC:1>> |cffffffwird angegriffen (|r<<!AC:2>>|cffffff)|r",
        KEEP_STATUS_DEFENDED = "<<!AC:1>> |cffffffwurde erfolgreich verteidigt|r",
        KEEP_STATUS_DEFENDED_BY = "<<!AC:1>> |cffffffwurde verteidigt von|r <<!AC:2>>",
        KEEP_STATUS_LOST = "<<!AC:1>> |cffffffverloren an|r <<!AC:2>>",
        KEEP_STATUS_LOST_TO = "<<!AC:1>> |cffffffeingenommen von|r <<!AC:2>>",
        KEEP_STATUS_CONQUERED = "<<!AC:1>> |cffffffwurde erfolgreich erorbert|r",

        LINK_TO_CHAT = GetString(SI_ITEM_ACTION_LINK_TO_CHAT),

        SETTINGS_CAMPAIGN_BROWSER_TITLE = "Allianzkrieg",
        SETTINGS_CAMPAIGN_BROWSER_OVERVIEW_LABEL = "Alle Kampagnen Übersicht",
        SETTINGS_CAMPAIGN_BROWSER_OVERVIEW_DESCRIPTION = "Fügt die Kategorie \'Alle Kampagnen\' in der Allianzkrieg Übersicht hinzu und zeigt alle verfügbaren Kapagnen auf einer Liste.",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_LABEL = "Kapagne automatisch beitreten",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_DESCRIPTION = "Ihr treten nach x Sekunden automatisch einer Kampagne bei nachdem die Warteschlange bereit ist. Ihr könnt das automatische Beitreten während diesen x Sekunden abbrechen.",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_TIMEOUT_LABEL = "Verzögerung Kampagne beitreten",
        SETTINGS_CAMPAIGN_QUEUE_AUTO_JOIN_TIMEOUT_DESCRIPTION = "Legt die Sekunden fest, bevor der Kampagne automatisch beigetreten wird.",
        SETTINGS_CAMPAIGN_QUEUE_SUPRESS_DIALOG_LABEL = "Unterdrücke Kampagne beitreten Abfrage",
        SETTINGS_CAMPAIGN_QUEUE_SUPRESS_DIALOG_DESCRIPTION = "Anstatt nach einer Bestätigung zu fragen, wird direkt der Kampagne beigetreten.",

        SETTINGS_RESURRECTION_TITLE = "Wiederbelebung Verbesserungen",
        SETTINGS_RESURRECTION_AUTO_DECLINE_LABEL = "Automatische Ablehnung",
        SETTINGS_RESURRECTION_AUTO_DECLINE_DESCRIPTION = "Lehnt automatisch einen Wiederbelebungsversuch den du erhälst nach x Sekunden ab, um eine frühzeitige WIederbelebung zu verhindern, falls du gerade abwesend bist. Durch Drücken von Warten/Ablehnen kannst du das automatische Ablehnen verhindern.", -- TODO Habe ich das richtig verstanden?
        SETTINGS_RESURRECTION_AUTO_DECLINE_TIMEOUT_LABEL = "Ablehnung Zeit",
        SETTINGS_RESURRECTION_AUTO_DECLINE_TIMEOUT_DESCRIPTION = "Legt die Zeit fest, wie lange gewartet wird, bevor die Wiederbelebung automatisch abgelehnt wird",
        SETTINGS_RESURRECTION_NOTIFICATIONS_LABEL = "Chat Nachricht",
        SETTINGS_RESURRECTION_NOTIFICATIONS_DESCRIPTION = "Zeigt eine Chatnachricht über Wiederbelebungen von anderen Spielern oder dir selber",

        SETTINGS_ATTRIBUTE_BARS_TITLE = "Lebensleiste Verbesserungen",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_LABEL = "Vampire/Werwölfe hervorheben",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_DESCRIPTION = "Die Lebensleiste des Ziels wird farblich hervorgehoben, sofern das Ziel ein Vampir/Werwolf ist",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_START_LABEL = "Werwolf farblicher Übergang Startfarbe",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_START_DESCRIPTION = "Mittlerer Teil Lebensleiste des Ziels",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_END_LABEL = "Werwolf farblicher Übergang Endfarbe",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_WEREWOLF_END_DESCRIPTION = "Äusserer Teil Lebensleiste des Ziels",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_START_LABEL = "Vampir farblicher Übergang Startfarbe",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_START_DESCRIPTION = "Mittlerer Teil Lebensleiste des Ziels",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_END_LABEL = "Vampir farblicher Übergang Endfarbe",
        SETTINGS_ATTRIBUTE_BAR_MUTATION_COLORS_VAMPIRE_END_DESCRIPTION = "Äusserer Teil Lebensleiste des Ziels",

        targetHealthBar = "Gegner Lebensbalken",
        playerHealthBar = "Spieler Lebensbalken",
        playerMagickaBar = "Spieler Magickabalken",
        playerStaminaBar = "Spieler Staminabalken",

        SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_TITLE = "Attributsleisten Zahlen",
        SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_LABEL = "Zeige Ressourcenzahlen",
        SETTINGS_ATTRIBUTE_BAR_MODIFICATIONS_DESCRIPTION = "Zeigt numerische Werte in den Attributsleisten an",
        SETTINGS_ATTRIBUTE_BAR_TEXT_ENABLED_TITLE = "Zeige <<1>> Werte",
        SETTINGS_ATTRIBUTE_BAR_TEXT_ENABLED_DESCRIPTION = "Zeigt Zahlenwerte auf dem <<1>>, wenn aktiv",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_TITLE = "<<1>> Modus",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_DESCRIPTION = "Bestimmt wie Zahlen auf dem <<1>> angezeigt werden sollen",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_PERCENTAGE_LABEL = "Prozentwerte",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_PERCENTAGE_TOOLTIP = "Zeigt '50% / 100%' oder ähnliches",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_ABSOLUTE_LABEL = "Absolute Werte",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_ABSOLUTE_TOOLTIP = "Zeigt '5000 / 10000' oder ähnliches",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_BOTH_LABEL = "Beides",
        SETTINGS_ATTRIBUTE_BAR_TEXT_MODE_BOTH_TOOLTIP = "Zeigt '5000 / 10000 (50% / 100%)' oder ähnliches",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_TITLE = "<<1>> Format",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_DESCRIPTION = "Bestimmt wie absolute Werte auf dem <<1>> formatiert werden sollen",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_RAW_LABEL = "Unverändert",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_RAW_TOOLTIP = "Zeigt '10000' oder ähnliches",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_COMMA_LABEL = "Tausender Gruppiert",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_COMMA_TOOLTIP = "Zeigt '10,000' oder ähnliches",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_SHORT_LABEL = "Gekürzt",
        SETTINGS_ATTRIBUTE_BAR_TEXT_FORMAT_SHORT_TOOLTIP = "Zeigt '10,0k' oder ähnliches",

        SETTINGS_TARGET_FRAME_CLASS_ICON_LABEL = "Zeige Klassensymbol",
        SETTINGS_TARGET_FRAME_CLASS_ICON_DESCRIPTION = "Fügt ein Klassensymbol zwischen Name und Allianzrang des Zieles an",
        SETTINGS_TARGET_FRAME_CLASS_LEADERBOARD_RANK_LABEL = "Klassen Rangliste Rang",
        SETTINGS_TARGET_FRAME_CLASS_LEADERBOARD_RANK_DESCRIPTION = "Zeigt den Klassenrang des Ziels unterhalb des Klassensymbols an",
        SETTINGS_TARGET_FRAME_ALLIANCE_LEADERBOARD_RANK_LABEL = "Allianz Rangliste Rang",
        SETTINGS_TARGET_FRAME_ALLIANCE_LEADERBOARD_DESCRIPTION = "Zeigt den Allianzrang des Ziels unterhalb des Klassensymbols an",

        SETTINGS_STEALTH_INDICATOR_TITLE = "Getarnt Anzeige",
        SETTINGS_STEALTH_INDICATOR_LABEL = "Getarnt Anzeige",
        SETTINGS_STEALTH_INDICATOR_DESCRIPTION = "Zeigt den aktuellen Status der Verborgenheit an (schleichen oder unsichtbar)",
        SETTINGS_STEALTH_INDICATOR_ALPHA_LABEL = "Transparenz",
        SETTINGS_STEALTH_INDICATOR_ALPHA_DESCRIPTION = "Transparenz der Anzeige (0 = durchsichtig, 100 = undurchsichtig)",
        SETTINGS_STEALTH_INDICATOR_HIDDEN_COLOR_LABEL = "Schleichen Farbe",
        SETTINGS_STEALTH_INDICATOR_HIDDEN_COLOR_DESCRIPTION = "Farbe der \'schleichen\' Anzeige",
        SETTINGS_STEALTH_INDICATOR_STEALTHED_COLOR_LABEL = "Unsichtbar Farbe",
        SETTINGS_STEALTH_INDICATOR_STEALTHED_COLOR_DESCRIPTION = "Farbe der \'unsichtbar\' Anzeige",

        SETTINGS_MISC_TITLE = "Verschiedene Korrekturen / Verbesserungen",
        SETTINGS_KEEP_CLAIM_DIALOG_FILTER_ALLIANCE_LABEL = "Filter Objekt Beanspruchung",
        SETTINGS_KEEP_CLAIM_DIALOG_FILTER_ALLIANCE_DESCRIPTION = "Falls du Gildenmitglied einer anderen Allianz bist, wird in der Auswahl für die Beanspruchung eines Objektes diese Gidle nicht erscheinen. Diese können sowieso nicht ausgewählt werden",
        SETTINGS_KEEP_CLAIM_UPDATE_TIMER_FIX_LABEL = "Korrektur Wartezeit Objekt Beanspruchung",
        SETTINGS_KEEP_CLAIM_UPDATE_TIMER_FIX_DESCRIPTION = "Behebt das Wartezeit Problem im Objekt Beanspruchung Dialog",
        SETTINGS_CAMPAIGN_BONUS_TOOLTIP_FIX_LABEL = "Korrektur Kampagnenbonus Kurzinfo",
        SETTINGS_CAMPAIGN_BONUS_TOOLTIP_FIX_DESCRIPTION = "Zeigt in der Kurzinfo die korrekte Beschreibung der Kapagnenboni und gibt die richtige Anzahl Rollen aus",
        SETTINGS_QUICKSLOT_FIX_LABEL = "Korrektur Schnellauswahl Fenster",
        SETTINGS_QUICKSLOT_FIX_DESCRIPTION = "Wenn du gerade Gegenstände in die Schnellauswahl ziehen möchtest, springt dir das Spiel nicht wieder nach oben, wenn neben dir ein Kampfereignis ist",
        SETTINGS_QUICKSLOT_CONSOLIDATE_ITEMS_LABEL = " ", -- TODO Wird vermutlich nicht mehr benötigt
        SETTINGS_QUICKSLOT_CONSOLIDATE_ITEMS_DESCRIPTION = " ", -- TODO Wird vermutlich nicht mehr benötigt
        SETTINGS_MAP_OBJECTIVES_TAB_LABEL = "Schauplätze Reiter",
        SETTINGS_MAP_OBJECTIVES_TAB_DESCRIPTION = "Fügt einen neuen Reiter in der Weltkarte hinzu, welcher dir eine Liste von Objekten in Cyrodiil anzeigt. Wird erst nach einer Initialisierung des Kapagnenstatus angezeigt",
        SETTINGS_SHOW_CYRODIIL_MAP_IN_GATES_LABEL = "Cyrodiil Karte im Allianzbereich",
        SETTINGS_SHOW_CYRODIIL_MAP_IN_GATES_DESCRIPTION = "Wechselt automatisch auf die ganze Cyrodiil Karte, sofern du dich in deinem Allianzbereich befindest",
        SETTINGS_MAP_OBJECTIVE_LEVEL_LABEL = "Objektstufe auf Karte/Kompass", -- TODO TODO funktioniert nicht
        SETTINGS_MAP_OBJECTIVE_LEVEL_DESCRIPTION = "Zeigt die Stufe der Burg oder der Ressource auf der Weltkarte und dem Kompass an", -- TODO funktioniert nicht
        SETTINGS_KEEP_STATUS_NOTIFICATIONS_LABEL = "Statusmeldungen einer Burg",
        SETTINGS_KEEP_STATUS_NOTIFICATIONS_DESCRIPTION = "Gib eine Chatnachricht wieder, sobald sich der Status einer Burg ändert",
        SETTINGS_KILL_NOTIFICATIONS_LABEL = "Spieler Tötungsmeldungen",
        SETTINGS_KILL_NOTIFICATIONS_DESCRIPTION = "Gibt einer Chatnachricht wieder, wenn du jemanden tötest oder getötet wirst",
        SETTINGS_NPC_KILL_NOTIFICATIONS_LABEL = "NPC Tötungsmeldungen",
        SETTINGS_NPC_KILL_NOTIFICATIONS_DESCRIPTION = "Gibt einer Chatnachricht wieder, wenn du einen NPC tötest",
        SETTINGS_ABILITY_LINK_MENU_ENTRIES_LABEL = "Fähigkeiten in Chat verlinken",
        SETTINGS_ABILITY_LINK_MENU_ENTRIES_DESCRIPTION = "Ermöglicht es dir deine Fähigkeiten im Chat zu teilen",
        SETTINGS_ENHANCE_CP_BAR_TOOLTIP_LABEL = "Verbesserte Champion Balken Kurzinfo",
        SETTINGS_ENHANCE_CP_BAR_TOOLTIP_DESCRIPTION = "Zeigt den Erfrischungstand in Prozenten in der Champion Balken Kurzinfo im Charaktermenü",
    },
}

local language = GetCVar("language.2")
local stringTable = ZO_ShallowTableCopy(localization["en"])

if(language ~= "en" and localization[language]) then
    ZO_ShallowTableCopy(localization[language], stringTable)
end
sidWarTools.Localization = stringTable
