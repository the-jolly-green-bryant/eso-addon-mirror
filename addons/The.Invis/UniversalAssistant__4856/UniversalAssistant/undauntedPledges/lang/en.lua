local strings = {
    UNDAUNTED_PLEDGES = "Undaunted pledges",
    UNDAUNTED_PLEDGES_TOOLTIP = "Adds veteran dungeon selection for your Undaunted pledges. Requires LibUndauntedPledges.",
    PLEDGES_SELECT_TOOLTIP = "Select veteran dungeons for your pledges. Unchecking clears the selection.",
    PLEDGES_NO_QUESTS = "Accept an Undaunted pledge quest first.",
    PLEDGES_UNAVAILABLE = "Veteran dungeons for your pledges are currently unavailable.",
    PLEDGES_IN_QUEUE = "Selection is unavailable while queued or during a ready check.",
    PLEDGES_MISSING_LIBRARY = "Install and enable LibUndauntedPledges, then use /reloadui.",
}

local ua = UAssistant
ua.AddLanguageStrings("en", strings)
