-- English, and the base every other language file overrides. Loaded first, so a translation
-- that is missing a line falls back to the line here rather than to "<missing SI_...>".
--
-- The 365 fortunes themselves are NOT here. They are Japanese, they live in Fortunes.lua, and
-- they are the same in every client -- see the note at the top of Main.lua for why.
local strings = {
	-- ---- Settings panel ---------------------------------------------------------------
	SI_PBSOMI_EXPLANATION = "An omikuji is the paper fortune slip you draw at a Japanese shrine: a rank, from 大吉 (great blessing) down to 大凶 (great curse), and a line of advice under it. This one is drawn in chat when you log in, out of 365 written fortunes -- one for every day of a year -- and the advice is about Tamriel. The slip is worked out from the date and from who is drawing, so it does not change when you reload -- the same character sees the same fortune all day, and each of your characters gets its own. The fortunes are written in Japanese.",

	SI_PBSOMI_SECTION_WHEN = "When it is drawn",
	SI_PBSOMI_SECTION_WHAT = "What is shown",
	SI_PBSOMI_SECTION_NOW = "Today",

	SI_PBSOMI_ENABLED = "Draw at login",
	SI_PBSOMI_ENABLED_TOOLTIP = "The master switch. Off, nothing is put in chat at login and /omikuji is the only way to see the day's slip.",

	SI_PBSOMI_SCOPE = "One fortune per",
	SI_PBSOMI_SCOPE_TOOLTIP = "Character is the default: the fun of a fortune slip is that it is yours, so your main can have 大吉 on a day your crafting alt has 大凶. Account gives every character the same slip, for people who would rather have one fortune a day than eight.",
	SI_PBSOMI_SCOPE_CHARACTER = "Character",
	SI_PBSOMI_SCOPE_ACCOUNT = "Account",

	SI_PBSOMI_ONCE = "Only the first login of the day",
	SI_PBSOMI_ONCE_TOOLTIP = "On, the slip appears at the first login of a day and every later login that day is quiet. Off, it appears at every login -- it is the same slip either way. Zone changes never print it.",

	SI_PBSOMI_DATE = "Show the date",
	SI_PBSOMI_DATE_TOOLTIP = "Puts the calendar date and weekday in the first line. The date is your local date, not the server's.",

	SI_PBSOMI_DRAW_NOW = "Show today's fortune",
	SI_PBSOMI_DRAW_NOW_TOOLTIP = "Puts today's slip in chat again. It is the same slip -- there is nothing here that rerolls it.",
	SI_PBSOMI_DRAW_NOW_BUTTON = "Show",

	SI_PBSOMI_RESET = "Back to defaults",
	SI_PBSOMI_RESET_TOOLTIP = "Every setting on this panel back to the shipped value, and the record of what has been shown is forgotten. Today's fortune does not change -- it never depended on that record.",
	SI_PBSOMI_RESET_BUTTON = "Reset",

	-- ---- The slip ---------------------------------------------------------------------
	-- Sunday first. Read by index, so the order matters and the count has to stay at seven.
	SI_PBSOMI_WEEKDAYS = "Sun,Mon,Tue,Wed,Thu,Fri,Sat",
	SI_PBSOMI_DATE_FORMAT = "%d-%02d-%02d (%s)",
	SI_PBSOMI_HEADER_DATED = "%s -- your fortune for %s",
	SI_PBSOMI_HEADER_PLAIN = "%s -- today's fortune",
	SI_PBSOMI_FORTUNE_RANK = "【%s】",

	-- ---- Chat -------------------------------------------------------------------------
	SI_PBSOMI_ON = "on",
	SI_PBSOMI_OFF = "off",

	SI_PBSOMI_STATUS_HEADER = "settings:",
	SI_PBSOMI_STATUS_ENABLED = "draw at login: %s",
	SI_PBSOMI_STATUS_SCOPE = "one fortune per: %s",
	SI_PBSOMI_STATUS_ONCE = "only the first login of the day: %s",
	SI_PBSOMI_STATUS_TOTAL = "%d fortunes written",
	SI_PBSOMI_STATUS_TODAY = "today's is number %d of %d",

	SI_PBSOMI_RANKS_HEADER = "the ranks, best first, and how many fortunes each has:",
	SI_PBSOMI_RANKS_COUNT = "%d",

	SI_PBSOMI_REPLY_SCOPE = "one fortune per %s",
	SI_PBSOMI_REPLY_ONCE = "only the first login of the day: %s",
	SI_PBSOMI_REPLY_DATE = "showing the date: %s",
	SI_PBSOMI_REPLY_MASTER = "draw at login: %s",
	SI_PBSOMI_REPLY_RESET = "every setting back to default",

	SI_PBSOMI_ERROR_NO_DATA = "the fortunes did not load, so there is nothing to draw",
	SI_PBSOMI_ERROR_SCOPE = "that wants character or account",
	SI_PBSOMI_ERROR_ON_OR_OFF = "that wants on or off",
	SI_PBSOMI_ERROR_UNKNOWN = "no such command: %s",

	-- ---- Help -------------------------------------------------------------------------
	SI_PBSOMI_HELP_HEADER = "commands:",
	SI_PBSOMI_HELP_DRAW = "/omikuji -- today's fortune again",
	SI_PBSOMI_HELP_STATUS = "/omikuji status -- what the settings are",
	SI_PBSOMI_HELP_SCOPE = "/omikuji scope character | account -- who gets their own fortune",
	SI_PBSOMI_HELP_ONCE = "/omikuji once on | off -- only the first login of the day",
	SI_PBSOMI_HELP_DATE = "/omikuji date on | off -- the date in the first line",
	SI_PBSOMI_HELP_RANKS = "/omikuji ranks -- the seven ranks and how many fortunes each has",
	SI_PBSOMI_HELP_MASTER = "/omikuji on | off -- draw at login, or do not",
	SI_PBSOMI_HELP_RESET = "/omikuji reset -- every setting back to default",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
