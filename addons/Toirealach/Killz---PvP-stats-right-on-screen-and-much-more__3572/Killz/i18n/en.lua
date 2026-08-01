Killz = Killz or {}

Killz.Localization = {
    
    LOADED_STR = "%s %s %s",
    WAS_LOADED = "Loaded",
    NOT_LOADED = "NOT Loaded",
    ENTERED_PVP = "Entered PvP",
    EXITED_PVP = "Exited PvP",
    WAS_DEATH = "You were killed by ",
    WAS_KILL = "Killed ",
    WAS_KILLING_BLOW = "Killing Blow on ",
    USING = " using ",
    SENSELESS_DEATH = "Senseless death...but it won't count against you.",
    NUMBER_OF_DEATHS = "(%s Deaths in a row)",
    NUMBER_OF_KILLS = "(%s Kills in a row)",
    NUMBER_OF_KILLING_BLOWS = "(%s Killing Blows)",
    KILLCLSTREAK_ENDED = "Your kill streak of %d has ended!",
    ALL_TIME_KILLCLSTREAK = "This kill streak of %d in a row is your highest ever!",
    KB_STREAK_ENDED = "Your killing blow streak of %d in a row has ended!",
    ALL_TIME_KB_STREAK = "This killing blow streak of %d in a row is your highest ever!",
    WARNING_RELOADUI = "WARNING: Will automatically reload UI when changed",

    MILESTONE = {
    
        NUMBER_OF_KILLS = {	
        
            [3] = "Three For One!", [5] = "Killing Spree!", [8] = "Dominating!",
            [12] = "Unstoppable!", [15] = "Massacre!", [18] = "Annihilation!",
            [21] = "Legendary!", [25] = "Genocide!", [28] = "Demonic!", 
            [32] = "Godlike!", [40] = "Praise Thee, Demi-God!",
            [50] = "Praise Thee, God of Pain!", 
            [60] = "Praise Thee, God of Blood!",
            [75] = "Praise Thee, God of Destruction!",
            [100] = "Praise Thee, God of Chaos!" 
        },
        
        NUMBER_OF_KILLING_BLOWS = {	
            [2] = "Hunter!", [3] = "Stalker!", [5] = "Killer!", [8] = "Slayer!",
            [12] = "Hit Man!", [15] = "Mass Murderer!", [18] = "Executioner!",
            [21] = "Assassin!", [25] = "Blood Drinker!", [28] = "Agent of Death!", 
            [32] = "Reaper!", [40] = "Angel Of Death!",
            [50] = "God of Death!", 
            [75] = "Obviously Cheating! REPORTED!",
            [100] = "Enough with Cheat Engine Already!"
        },
                
        NUMBER_OF_DEATHS = {	
            [2] = "Honorless Death!", [3] = "Dry Spell!", 
            [4] = "Unfair Disadvantage!", [5] = "Lover, Not a Fighter!",
            [6] = "Forsaken!", [7] = "500ms Latency?", 
            [8] = "Plain Ole Baddie!!", 
            [9] = "I hope you're good at trials.", 
            [10] = "Have you considered reading a book instead of PvP?"
        },
    },

    KILLS_ABBREVIATION = "K",
    DEATHS_ABBREVIATION = "D",
    KBS_ABBREVIATION = "KB",
    AP_ABBREVIATION = "AP",
    CAMP_TIMER = "Camp Timer: %s",
    COMBAT_ENDED = "Combat Ended",
    HIT_TYPE_DAMAGE = "damage",
    HIT_TYPE_HEALTH = "health",
    FAILED = "failed ",
    POSSESSIVE = "'s ",
    BREAK_FREE = "Break Free",
    ON_PREPOSITON = " on ",
    YOU_FELL = "You fell",
    GAINED_XP = "You gained %d experience",
    GAINED_AP = "You gained %d alliance points",
    GAINED_TELVAR = "That kill gave you %d Telvar stones",
    LOST_TELVAR = "Your death cost you %d Telvar stones",
    AVENGED1 = "You avenged %s",
	AVENGED2 = "(%s) by killing %s",
	AVENGED3 = "(%s)",
	REVENGE1 = "You took your revenge on %s",
	REVENGE2 = "(%s)",
    Q_STATE_QUEUEING = "Queueing For %s",
    Q_STATE_ENTERING = "Entering %s",
    Q_STATE_LEAVING = "Leaving Queue For %s",
    Q_STATE_CONFIRMING = "Confirming Queue For %s",
    Q_STATE_WAITING = "In Queue For %s",
    Q_STATE_FINISHED = "Finished Queue For %s",
    Q_STATE_UNKNOWN = "Unknown Queue State For %s",
    UNKNOWN_Q = "Unknown Queue",
    Q_NUMBER = "Number %d ",
    Q_TIME = "Time in queue: %s",
    CONFIRM_STATS_RESET_TITLE = "Reset Killz Session Stats",
    CONFIRM_STATS_RESET_TEXT = "Are you SURE you want to reset your PvP session stats?",
    CONFIRM_YES = "Yes",
    CONFIRM_NO = "No",
    SESSION_STATS = "Session PvP Stats against",
    LIFETIME_STATS = "Lifetime PvP Stats against",
    ALL_TOONS_FOR_ACCOUNT = "Who is this?",

    -- Slash commands

    SLASH_KZREPORT = "/kzreport",
    SLASH_KB = "/kb",
    SLASH_KZL = "/kzl",
    SLASH_KZPREFS = "/kzprefs",
    SLASH_KILLZ = "/killz",
    SLASH_PARAM_REPORT = "report",
    SLASH_PARAM_HELP = "help",
    SLASH_PARAM_LAST = "last",
    SLASH_PARAM_SHOW = "show",
    SLASH_PARAM_HIDE = "hide",
    SLASH_PARAM_IMPORT = "import",
    SLASH_PARAM_RESET = "reset",
    SLASH_PARAM_WHO = "who",

    SLASH_CMD_KZREPORT = "/killz report or ",
    SLASH_CMD_KZREPORT2 = "/kzreport [g/s/w/y/z/g1-g5/o1-o5]",
    SLASH_CMD_KZREPORT3 = "  Share stats to specified chat channel",

    SLASH_CMD_KZLAST = "/kb or",
    SLASH_CMD_KZLAST2 = "/kzl [g/s/w/y/z/g1-g5/o1-o5]",
    SLASH_CMD_KZLAST3 = "  Share last KB to chat channel",

    SLASH_CMD_SHOW = "/killz show - Show stats bar",
    SLASH_CMD_HIDE = "/killz hide - Hide stats bar",
    SLASH_CMD_RESET = "/killz reset - Reset stats bar",
    SLASH_CMD_IMPORT = "/killz import - Import & merge Kill Counter stats",
    SLASH_CMD_PREFS = "/kzprefs - Open the Killz settings panel",

    SLASH_CMD_STATS = "***Killz Stats*** Kills: %d Deaths: %d [Streak: %d] Kills/Death: %.1f KBs: %d AP: %d",
    SLASH_CMD_TIME_STATS_SESSION = " -- Session Time:",
    SLASH_CMD_TIME_STATS_SESSION_DAYS = " %d D",
    SLASH_CMD_TIME_STATS_SESSION_HRS = " %d Hr",
    SLASH_CMD_TIME_STATS_SESSION_MINS = " %d Min",
    SLASH_CMD_TIME_STATS_SESSION_SECS = " %d Sec",
    SLASH_CMD_TIME_STATS = " - K/Hr: %.1f, D/Hr: %.1f, KB/Hr: %.1f",

    -- Settings page

    ALWAYS = "Always",
    NEVER = "Never",
    IN_PVP = "Only In PvP",

    ACCTWIDE_NAME = "Use Account Wide Settings",
    ACCTWIDE_TOOLTIP = "When turned off, each character will keep its own set of statistics",
    STATS_BAR_HEADER = "PVP Stats Bar",
    SHOW_STATS_NAME = "Show PvP Stats Bar",
    SHOW_STATS_TOOLTIP = "When to show the PvP Stats bar",
    SCALE_SLIDER_NAME = "Resize the stats bar by this percentage:",
    SCALE_SLIDER_TOOLTIP = "Resize the PVP Stats Bar by the specified percentage",
    LOCK_CHECKBOX_NAME = "Lock stats bar location",
    LOCK_CHECKBOX_TOOLTIP = "When ON you cannot move the stats bar. When OFF you can move the stats bar anywhere on screen.",
    HIDE_IN_COMBAT_CHECKBOX_NAME = "Hide stats bar while in combat",
    HIDE_IN_COMBAT_CHECKBOX_TOOLTIP = "When ON the stats bar will be hidden during combat. When OFF the stats bar will not be hidden during combat.",
    HIDE_IN_PVE_CHECKBOX_NAME = "Hide stats bar when outside PvP zones",
    HIDE_IN_PVE_CHECKBOX_TOOLTIP = "When ON the stats bar will be hidden whenever you are not in PvP. When OFF the stats bar will be visible aslways.",
    COUNT_PVP_DEATHS_ONLY_NAME = "Only count deaths caused by other players",
    COUNT_PVP_DEATHS_ONLY_TOOLTIP = "When ON deaths caused by environmental factors or NPCs don't count in your PvP stats. When OFF then every death will count, no matter how.",
    RESET_ONLY_ON_LOG_OR_QUIT_NAME = "Reset stats only when I log out or quit",
    RESET_ONLY_ON_LOG_OR_QUIT_TOOLTIP = "When ON your PvP stats will ONLY be reset when you log out of a character or you quit.",
    
    ANNOUNCEMENTS_HEADER = "Announcements",
    PLAY_ANNOUNCE_SOUNDS_NAME = "Play announcement sounds effects",
    PLAY_ANNOUNCE_SOUNDS_TOOLTIP = "When ON sound effects are played for announcements.",
    ANNOUNCE_KILLING_BLOWS_NAME = "Announce killing blows on screen",
    ANNOUNCE_KILLING_BLOWS_TOOLTIP = "When ON announcements will be made for killing blows. When OFF killing blows will only go to the chat window.",
    ANNOUNCE_KILLING_BLOWS_COLORPICKERTIP = "The color of killing blow announcements in chat and on screen",
    ANNOUNCE_DEATHS_NAME = "Announce deaths on screen",
    ANNOUNCE_DEATHS_TOOLTIP = "When ON announcements will be made when you die to other players. When OFF PvP deaths will only go to the chat window.",
    ANNOUNCE_DEATHS_COLORPICKERTIP = "The color of death announcements in chat and on screen",
    ANNOUNCE_KILLS_NAME = "Announce group kills on screen",
    ANNOUNCE_KILLS_TOOLTIP = "When ON announcements will be made for group kills where you didn't have the killing blow. When OFF those kill notices will only go to the chat window.",
    ANNOUNCE_KILLS_COLORPICKERTIP = "The color of kill announcements in chat and on screen",
    ANNOUNCE_MILESTONES_NAME = "Announce milestones on screen",
    ANNOUNCE_MILESTONES_TOOLTIP = "When ON announcements will be made for kills, killing blow and death milestones. When OFF milestones will only go to the chat window.",
    ADD_ACCOUNT_NAME = "Add account to announcements when available",
    ADD_ACCOUNT_TOOLTIP = "When ON account names (i.e. @XXXXX) will be added to the end of announcements.",
    KILLZ_TAB_HEADER = "Killz Chat Tab",
    ADD_KILLZ_TAB_NAME = "Add 'Killz' chat tab",
    ADD_KILLZ_TAB_TOOLTIP = "Add a chat window tab called 'Killz' to display the PVP Kills Feed and/or detailed combat log.",
    ADD_PVP_KILL_FEED_TO_LOG_NAME = "Show PVP Kill Feed information",
    ADD_PVP_KILL_FEED_TO_LOG_TOOLTIP = "Show PVP Kill Feed information in the Killz chat tab?",
    ADD_PVP_KILL_FEED_TO_MAIN_NAME = "     Also show in main chat tab",
    ADD_PVP_KILL_FEED_TO_MAIN_TOOLTIP = "Also show PVP Kill Feed information in the main chat tab?",
    SHOW_AP_GAINED_NAME = "Show Alliance Points gained",
    SHOW_AP_GAINED_TOOLTIP = "Show Alliance Points gained from kills and conquest.",
    SHOW_TELVAR_GAINED_NAME = "Show Tel Var stones gained or lost",
    SHOW_TELVAR_GAINED_TOOLTIP = "Show Tel Var stones gained or lost in combat.",
    SHOW_MOB_KILLS_NAME = "Show Kills/DPS for NPCs & Monster kills",
    SHOW_MOB_KILLS_TOOLTIP = "Show Killing Blow information, including Average DPS, for NPCs & Monster kills as well as players killed.",
    SHOW_COMBAT_LOG_NAME = "Show detailed combat log",
    SHOW_COMBAT_LOG_TOOLTIP = "A detailed combat log will be shown for every combat encounter.",
    AUTO_CONFIRM_QUEUE_NAME = "Automatically confirm entering Cyrodiil",
    ADD_CONFIRM_QUEUE_TOOLTIP = "Automatically confirm the dialog to enter Cyrodill when it comes on screen",
    SHOW_SESSION_TIME_NAME = "Show PvP Session Time Stats in Reports",
    SHOW_SESSION_TIME_TOOLTIP = "Show total PvP Session time and asscoiated stats (e.g. Kills/Minute) in the Killz Report (/kzreport)",
    TELVAR_HEADER = "Telvar Saver",
    TELVAR_SAVER_NAME = "Auto-queue to Cyrodiil when my Telvar exceeds:",
    TELVAR_SAVER_TOOLTIP = "You will be auto-queued to your home Cyrodill campaign or a random Cyrodill campaign when you are in Imperial City and every time you gain enough Telvar stones to exceed the specified amount. To turn this OFF, set the number to 0",
    TELVAR_SAVER_GROUPQ_NAME = "     Queue as a group when I have crown.",
    TELVAR_SAVER_GROUPQ_TOOLTIP = "You will auto-queue your entire group when you are the group leader.",

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
        [ACTION_RESULT_DAMAGE] = "hit",
        [ACTION_RESULT_CRITICAL_DAMAGE] = "critically hit",
        [ACTION_RESULT_PRECISE_DAMAGE] = "precisely hit",
        [ACTION_RESULT_WRECKING_DAMAGE] = "wrecked",
        [ACTION_RESULT_DOT_TICK] = "hit",
        [ACTION_RESULT_DOT_TICK_CRITICAL] = "critically hit",
    
        -- These are all 'heals' which use standard sentence structure
        [ACTION_RESULT_HEAL] = "healed",
        [ACTION_RESULT_CRITICAL_HEAL] = "critically healed",
        [ACTION_RESULT_HOT_TICK] = "healed",
        [ACTION_RESULT_HOT_TICK_CRITICAL] = "critically healed",
    
        -- These are all 'deaths' which use standard sentence structure
        [ACTION_RESULT_DIED] = "killed",
        [ACTION_RESULT_DIED_XP] = "killed",
        [ACTION_RESULT_KILLING_BLOW] = "had the killing blow on", -- I think this only gets sent when the player is the source, so no "You" at beginning?
    
        -- For the following results use:
        -- if sourceName != targetName use standard sentence construction
        -- if sourceName == targetName == playername then use ability failed construction
    
        -- I think these are all always ability failed?
            
        [ACTION_RESULT_SILENCED] = "silenced", 						-- CC effect
        [ACTION_RESULT_STUNNED] = "stunned", 						-- CC effect
        [ACTION_RESULT_SNARED] = "snared",							-- CC effect
        [ACTION_RESULT_BUSY] = "Busy",								-- Always a failure
        [ACTION_RESULT_BAD_TARGET] = "Bad Target",
        [ACTION_RESULT_TARGET_DEAD] = "Target Dead",
        [ACTION_RESULT_CASTER_DEAD] = "Caster Dead",
        [ACTION_RESULT_TARGET_NOT_IN_VIEW] = "Out Of View",
        [ACTION_RESULT_ABILITY_ON_COOLDOWN] = "On Cooldown",
        [ACTION_RESULT_INSUFFICIENT_RESOURCE] = "No Resources",
        [ACTION_RESULT_TARGET_OUT_OF_RANGE] = "Out Of Range",
        [ACTION_RESULT_FAILED] = "Failed",
    
    
        -- For the following results use:
        -- if sourceName != targetName use: source verb target's ability (for hitValue) 
        -- if sourceName == targetName == playername then use ability failed construction
    
        [ACTION_RESULT_REFLECTED] = "reflected",
        [ACTION_RESULT_ABSORBED] = "absorbed",
        [ACTION_RESULT_PARRIED] = "parried",
        [ACTION_RESULT_DODGED] = "dodged", 
        [ACTION_RESULT_BLOCKED] = "blocked", 
        [ACTION_RESULT_BLOCKED_DAMAGE] = "blocked", 
        [ACTION_RESULT_PARTIAL_RESIST] = "partially resisted", 
        [ACTION_RESULT_RESIST] = "resisted",
    
        -- For the following results use:
        -- if sourceName != targetName use standard sentence construction 
        -- if sourceName == targetName == playername then use ability failed construction
    
        [ACTION_RESULT_MISS] = "missed", -- This might require special sentence
        [ACTION_RESULT_DEFENDED] = "defended",
        [ACTION_RESULT_INTERRUPT] = "interrupted", -- CC effect?
        [ACTION_RESULT_FEARED] = "feared",
        [ACTION_RESULT_DISORIENTED] ="disoriented", -- CC effect?
        [ACTION_RESULT_LEVITATED] = "levitated",
        [ACTION_RESULT_INTERCEPTED] = "intercepted",
    
        [ACTION_RESULT_FALL_DAMAGE] = "fell", -- target is always player, source is always 0, so special construction: target verb for hitValue damage
        [ACTION_RESULT_CANT_SEE_TARGET] = "can't see target", -- Is ALWAYS an ability failed
    
        -- With these CC effects as well as silenced, stunned and snared above, there are two cases
        -- First if source & target are different then just use verb and not ability
        -- second, if src & target are both the player then the ability is most
        -- likely break free and they are breaking free from the CC effect.
    
        [ACTION_RESULT_DISARMED] = "disarmed",
        [ACTION_RESULT_OFFBALANCE] = "knocked %s off balance", -- variation: target should be formatted into verb (e.g. "knocked Bob off balance) in standard construction
        [ACTION_RESULT_WEAPONSWAP] = "weaponswapped",
        [ACTION_RESULT_DAMAGE_SHIELDED] = "blocked",
        [ACTION_RESULT_STAGGERED] = "staggered",
        [ACTION_RESULT_KNOCKBACK] = "knockback",
        [ACTION_RESULT_ROOTED] = "rooted",
        
        [ACTION_RESULT_RESURRECT] = "resurrected",
    },
    
    -- the damage / heal preposition is "for" except in the following cases
    ACTION_RESULT_PREPOSITIONS = {
        DEFAULT = "for",
        [ACTION_RESULT_DAMAGE_SHIELDED] = "absorbing",
        [ACTION_RESULT_ABSORBED] = "absorbing",
        [ACTION_RESULT_REFLECTED] = "taking",
        [ACTION_RESULT_PARRIED] = "taking",
        [ACTION_RESULT_DODGED] = "taking", 
        [ACTION_RESULT_BLOCKED] = "taking", 
        [ACTION_RESULT_BLOCKED_DAMAGE] = "taking", 
        [ACTION_RESULT_PARTIAL_RESIST] = "taking", 
        [ACTION_RESULT_RESIST] = "taking",
    },
}
