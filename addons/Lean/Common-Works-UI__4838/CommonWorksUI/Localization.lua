CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

-- Prefix on every chat line we print.
CW.BRAND = "|cEBE4B8Common Works|r"

-- Keybind action names, referenced by Bindings.xml.
ZO_CreateStringId("SI_BINDING_NAME_CW_CATEGORY",     "Common Works")
ZO_CreateStringId("SI_BINDING_NAME_CW_TOGGLE",       "Common Works: Toggle Tracker")
ZO_CreateStringId("SI_BINDING_NAME_CW_LT_WHEEL",     "Common Works: LarvalTear Build Wheel")

-- Live only while the wheel is held open. The layer name carries the add-on, so the
-- two actions under it do not repeat it.
ZO_CreateStringId("SI_KEYBINDINGS_LAYER_CW_LT_WHEEL", "Common Works: Build Wheel")
ZO_CreateStringId("SI_BINDING_NAME_CW_LT_PAGE_PREV", "Build Wheel: Previous Page")
ZO_CreateStringId("SI_BINDING_NAME_CW_LT_PAGE_NEXT", "Build Wheel: Next Page")

-- Keys are stable identifiers: change the wording, keep the key. Where the game has
-- the word already, the entry is a GetString.
CW.L = {
    ALL_QUESTS  = "All quests",
    TRACKED_QUESTS = "Tracked Quests",
    NO_JOURNAL_QUESTS = "Your journal is empty.",
    GUILD_DAILIES = "Guild Dailies",
    ZONE_DAILIES = "Zone Dailies",
    TOME_HEADER       = GetString(SI_TAMRIEL_TOMES_TRACKER_HEADER),
    UNDAUNTED   = "Undaunted",
    UNDAUNTED_DAILIES = "Undaunted Dailies",
    BATTLEGROUND      = GetString("SI_QUESTTYPE", QUEST_TYPE_BATTLEGROUND),
    AVA_DAILIES       = GetString("SI_QUESTTYPE", QUEST_TYPE_AVA),
    ZONE_STORY  = zo_strformat("<<1>>", GetString(SI_ZONE_STORY_INFO_HEADER)),
    -- Odd source, but it is the game's own word for a reward already taken.
    TOME_CLAIMED = GetString(SI_DAILY_LOGIN_REWARDS_CLAIMED_TILE_NARRATION),
    TOME_SEASONAL    = GetString("SI_TIMEDACTIVITYTYPE", TIMED_ACTIVITY_TYPE_SEASONAL),
    TOME_WEEKLY      = zo_strformat("<<1>>", GetString("SI_TIMEDACTIVITYTYPE", TIMED_ACTIVITY_TYPE_WEEKLY)),
    -- The queue section's own name, for the restore strip; a live queue heads its block
    -- with what it is queued for instead.
    QUEUE_COUNT = "<<1>> queued",
    NO_KEEPS      = "All calm.",
    CONTESTED = "Contested",
    RECENT_ACTION = "Recent Action",
    -- "Battles" is the game's word. The size tiers exist only in the pin type, so
    -- that wording is ours.
    BATTLES = GetString("SI_MAPFILTER", MAP_FILTER_KILL_LOCATIONS),
    BATTLE_TIERS = { "small", "medium", "large" },
    BATTLE_NEAR = "%s (%s)",
    -- GetKeepHasResourcesForTravel. SI_TOOLTIP_KEEP_NOT_ACCESSIBLE_RESOURCES is a
    -- sentence, too long for an inline flag; "cut off" is what players say.
    NO_TRAVEL      = "cut off",
    -- The glyph beside it is the Elder Scroll, so the game's two words only crowd the line.
    SCROLL_HERE    = "Scroll",
    -- Siege pieces per alliance, which is what the API counts -- not heads.
    SIEGE       = "Siege:",
    KEEP_AGE    = "%dm ago",
    PANEL_LOCK        = "Lock the panel",
    PANEL_UNLOCK      = "Unlock the panel",
    OPEN_SETTINGS    = GetString(SI_GAME_MENU_SETTINGS),
    SET_ACTIVE_QUEST = "Set active quest to",
    ALREADY_ACTIVE_QUEST = "Already your active quest",
    MAKE_PRIMARY_QUEST = "Make primary quest",
    TRACK_QUEST   = "Add to tracker",
    UNTRACK_QUEST = "Remove from tracker",
    READY_FOR_TURN_IN = "Ready for turn-in",
    SHARE_NEEDS_GROUP = "Quest sharing needs a group.",
    QUESTS_EMPTY   = "No quests in journal.",
    TOMES_EMPTY    = "No challenges remaining.",

    -- AwesomeGuildStore sell-tab price stepper.
    AGS_PRICE_UP      = "Increase price by",
    AGS_PRICE_DOWN    = "Decrease price by",
    AGS_PRICE_ROUNDED = "rounded to the nearest 100",

    -- Color only the ignore verb to distinguish our menu entries.
    -- Keep English phrases whole rather than mixing in SI_CHAT_PLAYER_CONTEXT_ADD_IGNORE.
    STORE_IGNORE_ALL       = "|c7FC6FFIgnore|r ALL types of this item",
    STORE_IGNORE_VARIATION = "|c7FC6FFIgnore|r THIS variation only",
    -- Names the set: "ignore this set" on a row you are still reading is a question.
    STORE_IGNORE_SET       = "|c7FC6FFIgnore|r ALL THIS SET (%s)",
    PORT_TO_QUEST          = "Port to quest zone",

    -- %s is the game's own trait word -- Intricate, Ornate.
    STORE_IGNORE_SETLESS     = "|c7FC6FFIgnore|r ALL SET-LESS gear",
    STORE_IGNORE_SETLESS_ROW = "All set-less gear",
    STORE_IGNORE_ALL_ROW     = "All %s",
    STORE_IGNORE_SET_ROW     = "Set: %s",
    STORE_IGNORE_TRAIT       = "|c7FC6FFIgnore|r all %s items",
    STORE_IGNORE_TRAIT_ROW   = "All %s items",
    STORE_IGNORE_MATCH       = "|c7FC6FFIgnore|r partial match...",
    STORE_IGNORE_MATCH_TITLE = "Ignore partial match",
    STORE_IGNORE_MATCH_PROMPT = "Hide every listing whose name contains this text. Capitalization is ignored.",
    STORE_IGNORE_MATCH_ROW   = "Name contains \"%s\"",
    STORE_IGNORE_TITLE     = "Ignored items (%d)",
    STORE_IGNORE_TOGGLE    = "Ignore list (%d)",
    STORE_IGNORE_CLEAR     = "Clear all",
    STORE_IGNORE_CLEAR_TITLE  = "Clear ignore list",
    STORE_IGNORE_CLEAR_PROMPT = "Remove all <<1>> entries? Everything they were hiding "
                             .. "comes back into your searches.",
    -- This trader only, and only what the ignore list itself took out.
    STORE_IGNORE_HIDDEN    = "Ignored: %d",
    -- Wraps AwesomeGuildStore's own show more label, which says one of three things.
    STORE_IGNORE_SHOW_MORE = "%s  (%d items ignored)",
    -- Names the filter in AwesomeGuildStore's own lists, never in our UI.
    STORE_IGNORE_FILTER    = "Common Works ignore list",

    -- Purchase log: %s includes the game's gold icon; relative age uses guild-history text.
    PAID          = "Paid %s, %s",
    PAID_STACK    = "Paid %s for %d, %s each, %s",
    PAID_AVERAGE  = "%d purchases, %s each on average",
    PAID_ROW      = "%s  %s  %s",
    PAID_TITLE    = "Purchases (%d) -- %s spent",
    PAID_TOGGLE   = "Purchases (%d)",
    PAID_CLEAR    = "Clear all",
    PAID_CLEAR_TITLE  = "Clear purchase log",
    PAID_CLEAR_PROMPT = "Forget all <<1>> purchases? The prices you paid stop showing on "
                     .. "their tooltips.",

    GUILD_STORE_SHOW_TRAIT = "Show item trait instead of seller",
    GUILD_STORE_SHOW_TRAIT_TIP = "Replace seller names with item traits in AwesomeGuildStore results when a trait is available. Requires a UI reload.",
    DF_SETTING_HEADER        = "Dungeon Finder QoL",
    DF_SETTING_DESC          = "Adds buttons to Dungeon Finder to automate selecting all incomplete quests in either Normal or Veteran difficulty. Also adds a button to check all Veteran DLC dungeons (except WGT and ICP).",
    DF_SETTING               = "Enhance Dungeon Finder",
    DF_SETTING_TIP           = "Requires a UI reload.",
    STORE_IGNORE_SETTING     = "Ignore list",
    STORE_IGNORE_SETTING_TIP = "Right-click AwesomeGuildStore search results to hide items from every search. Requires a UI reload.",
    PURCHASE_LOG_SETTING     = "Purchase log",
    PURCHASE_LOG_SETTING_TIP = "Remember what you paid for guild store purchases and show it on the item's tooltip. Requires a UI reload.",

    -- Add-ons are enabled per character, so a host installed on one can be off on another.
    AGS_MISSING       = "Disabled: requires AwesomeGuildStore. Install it, or enable it for this character in the add-ons menu.",
    WRITBRIDGE_MISSING = "Disabled: requires WritWorthy and Dolgubon's Lazy Writ Crafter. Install them, or enable them for this character in the add-ons menu.",
    LOREBOOKS_MISSING = "Disabled: requires LoreBooks and CrutchAlerts. Install them, or enable them for this character in the add-ons menu.",

    -- Promoted out of the TTC submenu; the verb is TTC's own.
    TTC_PROMOTED      = "TTC> %s",
    TTC_PROMOTED_GOLD = "TTC> %s (%s)",

    -- LarvalTear build wheel.
    LT_MISSING  = "Disabled: requires LarvalTear. Install it, or enable it for this character in the add-ons menu.",
    LT_NO_BUILD = "No build applied",
    LT_WHEEL_SHEET = "%d / %d",
    LT_SET_LINE = "<<1>>x <<C:2>>",

    -- Poison bar alert, fired when LarvalTear applies a build.
    LT_POISON_FRONT = "POISON: FRONT BAR",
    LT_POISON_BACK  = "POISON: BACK BAR",
    LT_POISON_BOTH  = "POISON: BOTH BARS",
    LT_POISON_NONE  = "NO POISON",

    -- Light attack tracker.
    LA_STATS   = "Weave stats",
    LA_WEAVES  = "Weaves",
    LA_MISSED  = "Missed",
    LA_LATE    = "Late",
    LA_AVG_GAP = "Avg Gap",
    LA_WASTED  = "Wasted",
    LA_ACTIVE  = "Active",
    LA_MISSING = "Disabled: requires LibCombat. Install it, or enable it for this character in the add-ons menu.",

    -- Dungeon Finder buttons.
    DF_FUN_DLC           = "Check Fun DLC",
    DF_FUN_DLC_TIP       = "Select every DLC dungeon you own, except White-Gold Tower and Imperial City Prison",
    DF_NORMAL_QUESTS     = "Normal Quests",
    DF_NORMAL_QUESTS_TIP = "Select every normal dungeon whose quest this character has not completed",
    DF_VET_QUESTS        = "Vet Quests",
    DF_VET_QUESTS_TIP    = "Select every veteran dungeon whose quest this character has not completed",

    -- Master writ turn-in bridge (WritWorthy + Lazy Writ Crafter).
    WRITBRIDGE_TALK_TO_ROLIS  = "writ(s) accepted — talk to Rolis Hlaalu.",
    WRITBRIDGE_DONE           = "No more crafted master writs.",
    WRITBRIDGE_NEED_AUTOACCEPT = "Enable \"Auto Accept\" in Lazy Writ Crafter to chain master writ turn-ins.",
    WRITBRIDGE_ABORTED        = "Master writ chain stopped.",
}
