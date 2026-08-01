-- In game texts
ZO_CreateStringId("FTS_REPORT", "You spent <<1>> for a fast travel.")
ZO_CreateStringId("FTS_GOLD_SPENT_TOTAL", "So far you spent <<1>> on fast travels.")
ZO_CreateStringId("FTS_TOO_EXPENSIVE", "Way too much")
ZO_CreateStringId("FTS_RESET", "Reset the spent gold total.")

-- Options menu
ZO_CreateStringId("FTS_OPTIONS_TIER_1", "|c008000Tier 1|r")
ZO_CreateStringId("FTS_OPTIONS_TIER_1_TT", "Fast travel costs at or below this value will be colored green.")

ZO_CreateStringId("FTS_OPTIONS_TIER_2", "|cff8000Tier 2|r")
ZO_CreateStringId("FTS_OPTIONS_TIER_2_TT", "Fast travel costs at this value will be colored orange.")

ZO_CreateStringId("FTS_OPTIONS_TIER_3", "|cff0000Tier 3|r")
ZO_CreateStringId("FTS_OPTIONS_TIER_3_TT", "Fast travel costs at or above this value will be colored red.")

ZO_CreateStringId("FTS_OPTIONS_TIER_4", "Threshold")
ZO_CreateStringId("FTS_OPTIONS_TIER_4_TT", "Fast travel costs above this value will be replaced by \"Way too much\".")


ZO_CreateStringId("FTS_OPTIONS_TEXT", "Use Text If Cost < Threshold")
ZO_CreateStringId("FTS_OPTIONS_TEXT_TT", "Swap the cost to a text saying \"Way too much\" if the cost is higher than the value specified below.")

ZO_CreateStringId("FTS_OPTIONS_DESCRIPTION", "Colors for travel cost fade between green (at tier 1) over orange (at tier 2) to red (at tier 3). This means if the cost is between the value for green and orange, it will be a mixed faded color between green and orange.")
ZO_CreateStringId("FTS_OPTIONS_PREVIEW", "Preview")

ZO_CreateStringId("FTS_OPTIONS_RESET", "Reset gold spent")

-- Confirmation dialog
ZO_CreateStringId("FTS_RESETDIALOG_TITLE", "Fast Travel Spendings - Reset")
ZO_CreateStringId("FTS_RESETDIALOG_TEXT", "Are you sure you want to reset the saved value of cumulative spent gold on fast travels?")
ZO_CreateStringId("FTS_RESETDIALOG_YES", "Reset")
ZO_CreateStringId("FTS_RESETDIALOG_NO", "Cancel")