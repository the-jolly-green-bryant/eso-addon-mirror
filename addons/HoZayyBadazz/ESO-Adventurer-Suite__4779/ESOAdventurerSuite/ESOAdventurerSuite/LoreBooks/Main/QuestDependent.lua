-- ESO Adventurer Suite - Lore Book quest/phasing exceptions
-- Known books/documents whose physical world object can move, phase, disappear,
-- or only become available during/after specific quest stages.

local function normalizeTitle(text)
    text = zo_strlower(tostring(text or ""))
    text = text:gsub("^the%s+", "")
    text = text:gsub("[^%w%s]", "")
    text = text:gsub("%s+", " ")
    return zo_strtrim(text)
end

-- Title-based on purpose: ESO's Lore Library resolves the live localized entry
-- from bookId, while the location database can carry the same logical book in
-- several zones/positions. Add entries here as additional phased books are found.
local QUEST_DEPENDENT_TITLES = {
    [normalizeTitle("Tava's Bounty Ledger")] = true,
    [normalizeTitle("For Captain Telomure")] = true,
    [normalizeTitle("Journal of Justiciar Avanaire")] = true,
    [normalizeTitle("To the Villainous Manacar")] = true,
    [normalizeTitle("Night Runner Captain's Journal")] = true,
    [normalizeTitle("The Scaled Elves")] = true,
    [normalizeTitle("Writ of Valid Credentials")] = true,
    [normalizeTitle("Letter from Minique")] = true,
    [normalizeTitle("Tancano's Journal")] = true,
    [normalizeTitle("Weapon Activation")] = true,
}

function EASLoreLibrary.IsQuestDependentTitle(title)
    return QUEST_DEPENDENT_TITLES[normalizeTitle(title)] == true
end

function EASLoreLibrary.IsQuestDependentBook(bookId)
    if not bookId then return false end
    local title = EASLoreLibrary.GetBookTitle and EASLoreLibrary.GetBookTitle(bookId)
    return title and EASLoreLibrary.IsQuestDependentTitle(title) or false
end

function EASLoreLibrary.RegisterQuestDependentTitle(title)
    local key = normalizeTitle(title)
    if key ~= "" then QUEST_DEPENDENT_TITLES[key] = true end
end
