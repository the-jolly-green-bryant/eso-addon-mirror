FlamechasersSpellcheck = FlamechasersSpellcheck or {}
local FSC = FlamechasersSpellcheck

FSC.English = FSC.English or {}
FSC.Frequency = FSC.Frequency or {}
FSC.CorrectionDeletes = FSC.CorrectionDeletes or {}
FSC.ESO = FSC.ESO or {}
FSC.Chat = FSC.Chat or {}

FSC.DEFAULT_SETTINGS = {
    spellcheckEnabled = true,
    suggestionsEnabled = true,
    suggestionIntelligence = "super",
    superConversationContext = true,
    personalizationEnabled = true,
    correctionLearningEnabled = true,
    dictionaries = { english = true, eso = true },
    dictionaryCategories = {},
    underlineOpacity = 78,
    underlineColor = { r = 1.00, g = 0.12, b = 0.12, a = 1.00 },
    suggestionStyle = "bar",
    suggestionHeight = 22,
    suggestionFont = "ZoFontGame",
    suggestionTextScale = 90,
    suggestionTextColor = { r = 0.82, g = 0.82, b = 0.82, a = 1.00 },
    suggestionSelectedColor = { r = 1.00, g = 0.84, b = 0.40, a = 1.00 },
    suggestionBackgroundOpacity = 100,
    suggestionDividerOpacityPercent = 24,
}

FSC.SAVED_DEFAULTS = {
    settings = FSC.DEFAULT_SETTINGS,
    userWords = {},
    autocomplete = {
        unigrams = {},
        bigrams = {},
        trigrams = {},
        fourgrams = {},
        learnedMessages = 0,
    },
    correctionLearning = {
        pairs = {},
        acceptances = 0,
    },
}
