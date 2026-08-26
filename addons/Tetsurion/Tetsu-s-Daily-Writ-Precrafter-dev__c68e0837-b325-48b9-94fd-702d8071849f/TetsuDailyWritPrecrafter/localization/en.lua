TetsuDailyWritPrecrafter = TetsuDailyWritPrecrafter or {}
TetsuDailyWritPrecrafter.L = {
    TITLE                   = "|cFFD700Tetsu's|r Daily Writ Precrafter",

    OPTIONS_SECTION_LABEL   = "Automation",
    OPTIONS_SECTION_TT      = "Gamepad-safe automation toggles.",
    AUTO_QUEST_LABEL        = "Auto-accept and turn in crafting writs",
    AUTO_QUEST_TT           = "Pick up writs from the board and turn them in at the crates automatically.",
    AUTO_BOX_LABEL          = "Auto-open writ reward boxes",
    AUTO_BOX_TT             = "Open daily writ containers as soon as they appear in the backpack.",

    PRECRAFT_SECTION_LABEL  = "Pre-craft (this character)",
    PRECRAFT_SECTION_TT     = "Settings are saved per character.",
    PRECRAFT_ENABLED_LABEL  = "Pre-craft for the future",
    PRECRAFT_ENABLED_TT     = "When enabled, R3 crafts items for several days ahead using the daily rotation. When disabled, R3 crafts only what the active writ quest needs.",
    PRECRAFT_DAYS_LABEL     = "Days ahead",
    PRECRAFT_DAYS_TT        = "How many days to pre-craft (including today). Slider 1–10.",

    KEYBIND_PRECRAFT        = "|c00FF00[R3]|r Pre-craft <<1>> days (<<2>> pcs)",
    KEYBIND_QUEST_CRAFT     = "|c00FF00[R3]|r Craft for active writ (<<1>> pcs)",
    KEYBIND_NOTHING         = "|c888888[R3]|r Nothing to craft",

    CONFIRM_TITLE_PRECRAFT  = "Pre-craft Daily Writs",
    CONFIRM_PROMPT_PRECRAFT = "Craft items for <<1>> days ahead? (<<2>> items)",
    CONFIRM_TITLE_QUEST     = "Craft Active Writ",
    CONFIRM_PROMPT_QUEST    = "Craft the items required by your active writ? (<<1>> items)",

    PROGRESS_CRAFTING       = "Crafting...",
    PROGRESS_STATUS         = "Processed: <<1>> of <<2>>",

    ERR_BAG_FULL            = "Not enough bag space (need ~<<1>> free slots).",
    ERR_NO_STYLE            = "No known style material found in backpack or craft bag.",
    ERR_MISSING_RUNES       = "Missing enchanting runes (potency / essence / Ta).",
    ERR_CANNOT_CRAFT        = "Cannot craft <<1>> (missing materials, style, or skill).",
    ERR_CRAFT_FAILED        = "Craft failed (<<1>>/<<2>>). Skipping.",
    ERR_NOT_AT_STATION      = "You are not at a crafting station.",
    ERR_PROV_SKIP_UNKNOWN   = "Skip (recipe not known): <<1>>",
    ERR_NOTHING_TO_CRAFT    = "Nothing to craft.",
    ERR_NO_ACTIVE_WRIT      = "No active crafting writ for this station.",

    PRECHECK_HEADER         = "|cFF6666[Tetsu's Daily Writ Precrafter]|r Not enough materials. Craft aborted:",
    PRECHECK_JOBS           = "Jobs in queue: |cFFFFFF<<1>>|r",
    PRECHECK_LINE           = "  - |cFFD700<<1>>|r: need |cFFFFFF<<2>>|r, have |cFFFFFF<<3>>|r (|cFF6666-<<4>>|r)",
    PRECHECK_ABORT          = "Add the missing materials and press R3 again.",
    PRECHECK_OK             = "Materials check OK. Crafting |c00FF00<<1>>|r items...",

    USING_QUEST_DATA        = "Using active writ quest data.",
    USING_PREDICTED         = "Pre-craft mode: using daily rotation for <<1>> days.",
    CRAFT_DONE              = "Done. Crafted: |c00FF00<<1>>|r, skipped: |cFFFF00<<2>>|r.",
    PATTERN_TODAY           = "Today's pattern: |cFFD700<<1>>|r",
}
