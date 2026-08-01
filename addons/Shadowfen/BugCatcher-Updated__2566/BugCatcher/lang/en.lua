-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

--base language is english
BugCatcher_localization_strings = BugCatcher_localization_strings  or {}

BugCatcher_localization_strings["en"] = {
    -- Settings titles
    SI_BUGCATCHER_BUG_INFO = "Bug Information",
    SI_BUGCATCHER_PREV_BUG = "< < <",
    SI_BUGCATCHER_NEXT_BUG = "> > >",
    SI_BUGCATCHER_DISMISS_BUG = "Dismiss Bug",
    SI_BUGCATCHER_WIPE_ALL_BUGS = "Wipe All Bugs",
    SI_BUGCATCHER_SHOW_LOG = "Show Bug Log",
    SI_BUGCATCHER_WIPE_BUGS = "Wipe Bugs",

    SI_BUGCATCHER_NO_BUGS_FOUND = "No Bugs Found",
    SI_BUGCATCHER_NOTHING = "Nothing to see here.",

    SI_BUGCATCHER_HAVE_NO_BUGS = "If the sack is faded out, you have no bugs.",
    SI_BUGCATCHER_HAVE_BUGS = "If the sack is not faded out, you have bugs.",
    SI_BUGCATCHER_FULL = "The sack is full, no more bugs can be stored. Please show or wipe your bugs as soon as possible.",

    -- Format strings
    SI_BUGCATCHER_BUGS_FOUND = "Bug <<1>> of <<2>>",        -- unused, see Core setName()
    SI_BUGCATCHER_CAUGHT_DUPLICATE = "Caught <<1>> duplicates, last seen on <<2>>.",
    SI_BUGCATCHER_TIMESTAMP = "<<1>> at <<2>><<3>>",        -- unused
    SI_BUGCATCHER_CAUGHT_BUG = "Caught a bug (<<1>> in total).",

    SI_BUGCATCHER_TOTAL_BUGS = "<<1>> bugs currently stored.",

    BUGCATCHER_LOCKUI_NAME = "Lock Sack Position",
    BUGCATCHER_LOCKUI = "If checked, the Bug Sack icon will be locked in place on the screen.",
    BUGCATCHER_RESETPOS = "Reset Sack Position",
}