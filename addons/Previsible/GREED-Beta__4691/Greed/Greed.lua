Greed_Addon = Greed_Addon or {}
local Greed = Greed_Addon
local GreedData = Greed_Addon.Data
local localization = Greed_Addon.Localization or {}

local function T(key, ...)
    local value = localization[key] or key
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, value, ...)
        if ok then
            return formatted
        end
    end
    return value
end

local function NormalizeClientLanguageCode(language)
    language = string.lower(tostring(language or ""))
    if language == "" then return "en" end

    if language == "ja" then return "jp" end
    if language == "zhcn" or language == "zh_cn" or language == "zh-hans" or language == "zhhans" or language == "cn" then
        return "zh"
    end

    return language
end

local function GetClientLanguageCode()
    if GetCVar then
        local lang = GetCVar("language.2")
        if type(lang) ~= "string" or lang == "" then
            lang = GetCVar("Language.2")
        end
        if type(lang) ~= "string" or lang == "" then
            lang = GetCVar("language")
        end
        if type(lang) ~= "string" or lang == "" then
            lang = GetCVar("Language")
        end
        if type(lang) == "string" and lang ~= "" then
            return NormalizeClientLanguageCode(lang)
        end
    end

    return "en"
end

local LOCALE_SAFE_FONT_LANGUAGES = {
    ru = true,
    zh = true,
    jp = true,
    ja = true,
    ko = true,
}

local libSets = LibSets
local libAddonMenu = LibAddonMenu2
local cachedAllSetNames
local cachedLibSetsSearchDataByLanguage
local cachedLiveSetNamesByLanguage

Greed.name = "Greed"
Greed.displayName = "GREED"
Greed.author = "Previsible"

local SLOT_SIZE = 42
local SLOT_GAP = 8
local ROW_HEIGHT = 48
local ROW_GAP = 6
local SLOT_START_X = 314
local MAX_ROWS_VIEWPORT_HEIGHT = (ROW_HEIGHT * 8) + (ROW_GAP * 7)
local MAIN_WINDOW_DEFAULT_WIDTH = 820
local MAIN_WINDOW_DEFAULT_HEIGHT = 620
local MAIN_WINDOW_MIN_WIDTH = 820
local MAIN_WINDOW_MIN_HEIGHT = 620
local MAIN_WINDOW_MAX_WIDTH = 1600
local MAIN_WINDOW_MAX_HEIGHT = 1000
local MAIN_WINDOW_ROWS_TOP = 128
local MAIN_WINDOW_SLOT_HEADER_TOP = 102
local MAIN_WINDOW_FOOTER_HEIGHT = 46
local MAIN_WINDOW_FOOTER_BOTTOM = 4
local MAIN_WINDOW_ROWS_FOOTER_GAP = 2
local MAIN_WINDOW_TABS_Y = 50
local MAIN_SCROLLBAR_WIDTH = 12
local MAIN_SCROLLBAR_THUMB_WIDTH = 8
local MAIN_SCROLLBAR_GAP = 0
local MAIN_SCROLLBAR_RIGHT_PADDING = 4
local MAIN_SCROLLBAR_WINDOW_RIGHT_INSET = 14
local MAIN_ROWS_LEFT_INSET = 16
local MAIN_ROWS_RIGHT_INSET = MAIN_SCROLLBAR_WINDOW_RIGHT_INSET - MAIN_SCROLLBAR_RIGHT_PADDING
local FOOTER_LEGEND_GROUP_WIDTH = 500
local FOOTER_LEGEND_ITEM_SPACING = 220

local SAVED_VARS_NAME = "GreedSavedVariables"
local SAVED_VARS_VERSION = 1
local DEFAULT_PAGE_NAME = "Page 1"
local LEGACY_DEFAULT_PAGE_NAME = "Healer Farms"
local TRACKING_SCOPE_ACCOUNT = "account"
local TRACKING_SCOPE_CHARACTER = "character"
local TRACKING_SCOPE_ACCOUNT_LABEL = T("Account-Wide")
local TRACKING_SCOPE_CHARACTER_LABEL = T("This Character")
local TRACKING_SCOPE_CHOICES = { TRACKING_SCOPE_CHARACTER_LABEL, TRACKING_SCOPE_ACCOUNT_LABEL }
local TRACKING_SCOPE_BY_LABEL = {
    [TRACKING_SCOPE_CHARACTER_LABEL] = TRACKING_SCOPE_CHARACTER,
    [TRACKING_SCOPE_ACCOUNT_LABEL] = TRACKING_SCOPE_ACCOUNT,
}
local TRACKING_SCOPE_LABEL_BY_SCOPE = {
    [TRACKING_SCOPE_CHARACTER] = TRACKING_SCOPE_CHARACTER_LABEL,
    [TRACKING_SCOPE_ACCOUNT] = TRACKING_SCOPE_ACCOUNT_LABEL,
}
local CHAMPION_POINTS_SCENE_NAMES = { "championPerks", "championPerksKeyboard" }
local SAVED_VAR_DEFAULTS = {
    launcher = {
        locked = false,
    },
    windowPositions = {},
    trackedListScope = TRACKING_SCOPE_CHARACTER,
    trackedListScopeByCharacter = {},
    trackingProfiles = {
        account = {
            pages = {},
            pageOrder = {},
            currentPage = DEFAULT_PAGE_NAME,
        },
        characters = {},
    },
    currentPage = DEFAULT_PAGE_NAME,
    pageOrder = {},
    pages = {},
    dropLog = {
        enabled = true,
        askMessage = T("Hey! You picked up {item}. If you don't need it, could I please have it?"),
        entries = {},
        width = 650,
        height = 380,
        textSize = 2,
        textSizeVersion = 2,
        fontName = "Univers 55",
        onlyMissing = true,
        currentPageOnly = false,
        hideInMenus = true,
        trackGroupLoot = true,
        showAccountNames = false,
        debugLoot = false,
        locked = false,
        opacity = 0.40,
        pageFilterName = "__ALL_DROPS__",
        traitFilters = {},
    },
    textPrompts = {
        locked = false,
        dropTextEnabled = true,
        spaulderTextEnabled = true,
        fontName = "Univers 55",
        drop = {
            enabled = true,
            locked = false,
            fontName = "Univers 55",
            fontSize = "Normal",
            colorName = "White",
            color = { 1.00, 1.00, 1.00, 1 },
            bold = false,
            italic = false,
            underline = false,
            rainbow = false,
        },
        spaulder = {
            enabled = true,
            locked = false,
            fontName = "Univers 55",
            fontSize = "Extra Large",
            colorName = "Dark Red",
            color = { 0.58, 0.02, 0.02, 1 },
            bold = true,
            italic = false,
            underline = false,
            rainbow = false,
        },
    },
    antiquityLeads = {
        watched = {},
        found = {},
        showOtherPlayers = false,
    },
}

local SERVER_SAVED_VARS_MIGRATION_FLAG = "serverNamespaceMigrationV1"
local TRACKING_PROFILE_MIGRATION_FLAG = "trackingProfilesMigrationV1"
local TRACKING_SCOPE_SELECTION_MIGRATION_FLAG = "trackingScopeSelectionMigrationV1"

local function GetSavedVarsServerNamespace()
    if type(GetWorldName) ~= "function" then return nil end

    local worldName = GetWorldName()
    if type(worldName) == "string" and worldName ~= "" then
        return worldName
    end

    return nil
end

local function CopySavedVarValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, child in pairs(value) do
        copy[key] = CopySavedVarValue(child)
    end
    return copy
end

local function SavedVarValueDiffersFromDefault(value, defaultValue)
    if type(value) == "table" then
        if type(defaultValue) ~= "table" then
            return next(value) ~= nil
        end

        for key, child in pairs(value) do
            if key ~= SERVER_SAVED_VARS_MIGRATION_FLAG and SavedVarValueDiffersFromDefault(child, defaultValue[key]) then
                return true
            end
        end

        return false
    end

    return value ~= defaultValue
end

local function CopySavedVarsInto(source, target)
    if type(source) ~= "table" or type(target) ~= "table" then return end

    for key, value in pairs(source) do
        if key ~= SERVER_SAVED_VARS_MIGRATION_FLAG then
            target[key] = CopySavedVarValue(value)
        end
    end
end

local function NormalizeTrackingScope(scope)
    if scope == TRACKING_SCOPE_ACCOUNT then
        return TRACKING_SCOPE_ACCOUNT
    end

    return TRACKING_SCOPE_CHARACTER
end

local function GetCachedAllSetNames()
    if not cachedAllSetNames then
        cachedAllSetNames = libSets.GetAllSetNames()
    end

    return cachedAllSetNames or {}
end

local function GetLibSetsSearchCache(language)
    cachedLibSetsSearchDataByLanguage = cachedLibSetsSearchDataByLanguage or {}
    language = NormalizeClientLanguageCode(language or "en")
    cachedLibSetsSearchDataByLanguage[language] = cachedLibSetsSearchDataByLanguage[language] or {}
    return cachedLibSetsSearchDataByLanguage[language]
end

local function GetLiveSetNameCache(language)
    cachedLiveSetNamesByLanguage = cachedLiveSetNamesByLanguage or {}
    language = NormalizeClientLanguageCode(language or "en")
    cachedLiveSetNamesByLanguage[language] = cachedLiveSetNamesByLanguage[language] or {}
    return cachedLiveSetNamesByLanguage[language]
end

local function SortAddSetResultsByBaseName(a, b)
    return string.lower(a.baseName or "") < string.lower(b.baseName or "")
end

local ADD_SET_RESULT_LIMIT = 8
local DROP_LOG_MAX_ENTRIES = 60
local DROP_LOG_MAX_VISIBLE_ROWS = 24
local SETS_OVERVIEW_MAX_ROWS = 12
local SOURCES_TO_FARM_MAX_ROWS = 12
local SOURCES_TO_FARM_ROW_HEIGHT = 30
local DROP_LOG_DEFAULT_WIDTH = 650
local DROP_LOG_DEFAULT_HEIGHT = 380
local DROP_LOG_MIN_WIDTH = 480
local DROP_LOG_MIN_HEIGHT = 220
local DROP_LOG_MAX_WIDTH = 1100
local DROP_LOG_MAX_HEIGHT = 820
local DEFAULT_DROP_ASK_MESSAGE = T("Hey! You picked up {item}. If you don't need it, could I please have it?")
local DROP_LOG_PAGE_FILTER_ALL = "__ALL__"
local DROP_LOG_PAGE_FILTER_ALL_DROPS = "__ALL_DROPS__"
local DROP_LOG_DEFAULT_OPACITY = 0.40
local DROP_LOG_TEXT_SIZES = {
    { label = T("Smaller"), size = 14, rowHeight = 25 },
    { label = T("Small"), size = 16, rowHeight = 28 },
    { label = T("Normal"), size = 18, rowHeight = 31 },
    { label = T("Large"), size = 20, rowHeight = 36 },
    { label = T("Extra Large"), size = 22, rowHeight = 40 },
}
local DEFAULT_DROP_LOG_TEXT_SIZE_INDEX = 2
local DROP_LOG_TEXT_SIZE_VERSION = 2
local DEFAULT_FONT_NAME = "Univers 55"
local DEFAULT_TEXT_PROMPT_DURATION_MS = 5200
local DROP_TEXT_FADE_IN_MS = 1200
local DROP_TEXT_FADE_OUT_MS = 1600
local DROP_TEXT_ALERT_STAGGER_MS = 700
local SPAULDER_OF_RUIN_ITEM_LINK = "|H1:item:181695:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:5200:0|h|h"
local SPAULDER_AURA_OF_PRIDE_ABILITY_ID = 163359
local SPAULDER_AURA_DURATION_MS = 60 * 60 * 1000

local TEXT_PROMPT_SIZE_OPTIONS = {
    { key = "Smaller", label = T("Smaller"), size = 18 },
    { key = "Small", label = T("Small"), size = 24 },
    { key = "Normal", label = T("Normal"), size = 30 },
    { key = "Large", label = T("Large"), size = 36 },
    { key = "Extra Large", label = T("Extra Large"), size = 42 },
}
local TEXT_PROMPT_SIZE_LABELS = {}
local TEXT_PROMPT_SIZE_BY_KEY = {}
local TEXT_PROMPT_SIZE_BY_LABEL = {}
for _, sizeOption in ipairs(TEXT_PROMPT_SIZE_OPTIONS) do
    TEXT_PROMPT_SIZE_BY_KEY[sizeOption.key] = sizeOption
    TEXT_PROMPT_SIZE_BY_LABEL[sizeOption.label] = sizeOption
    table.insert(TEXT_PROMPT_SIZE_LABELS, sizeOption.label)
end

local TEXT_PROMPT_COLOR_OPTIONS = {
    { key = "White", label = T("White"), color = { 1.00, 1.00, 1.00, 1 } },
    { key = "Dark Red", label = T("Dark Red"), color = { 0.58, 0.02, 0.02, 1 } },
    { key = "Gold", label = T("Gold"), color = { 1.00, 0.78, 0.24, 1 } },
    { key = "Green", label = T("Green"), color = { 0.25, 0.86, 0.34, 1 } },
    { key = "Blue", label = T("Blue"), color = { 0.38, 0.68, 1.00, 1 } },
    { key = "Purple", label = T("Purple"), color = { 0.72, 0.50, 0.95, 1 } },
    { key = "Soft Pink", label = T("Soft Pink"), color = { 1.00, 0.58, 0.76, 1 } },
    { key = "Soft Teal", label = T("Soft Teal"), color = { 0.42, 0.86, 0.82, 1 } },
    { key = "Muted Orange", label = T("Muted Orange"), color = { 0.96, 0.58, 0.26, 1 } },
    { key = "Rainbow", label = T("Rainbow"), color = { 1.00, 1.00, 1.00, 1 }, rainbow = true },
}
local TEXT_PROMPT_COLOR_LABELS = {}
local TEXT_PROMPT_COLOR_BY_KEY = {}
local TEXT_PROMPT_COLOR_BY_LABEL = {}
for _, colorOption in ipairs(TEXT_PROMPT_COLOR_OPTIONS) do
    TEXT_PROMPT_COLOR_BY_KEY[colorOption.key] = colorOption
    TEXT_PROMPT_COLOR_BY_LABEL[colorOption.label] = colorOption
    table.insert(TEXT_PROMPT_COLOR_LABELS, colorOption.label)
end

local PASTEL_RAINBOW_HEX = {
    "E7A1A1", "E7C18B", "E3D58A", "A9D9A6", "9FD8D3", "A9BDEB", "C5A7E8", "E5A6CF",
}

local FONT_OPTIONS = {
    { label = "Univers 55", face = "EsoUI/Common/Fonts/univers55.otf", fallback = false },
    { label = "Univers 57", face = "EsoUI/Common/Fonts/univers57.otf", fallback = false },
    { label = "Univers 67", face = "EsoUI/Common/Fonts/univers67.otf", fallback = false },
    { label = "ProseAntique", face = "EsoUI/Common/Fonts/ProseAntiquePSMT.otf", fallback = false },
    { label = "Consolas", face = "EsoUI/Common/Fonts/consola.ttf", fallback = false },
    { label = "Futura Condensed", face = "$(MEDIUM_FONT)", fallback = true },
    { label = "FTN87", face = "$(BOLD_FONT)", fallback = true },
    { label = "Future Condensed Light", face = "$(MEDIUM_FONT)", fallback = true },
    { label = "Skyrim Handwritten", face = "$(HANDWRITTEN_FONT)", fallback = true },
    { label = "Trajan Pro", face = "$(ANTIQUE_FONT)", fallback = true },
    { label = "Calligraphica", face = "$(ANTIQUE_FONT)", fallback = true },
    { label = "Almendra", face = "$(ANTIQUE_FONT)", fallback = true },
    { label = "Sansita Once", face = "$(MEDIUM_FONT)", fallback = true },
    { label = "Bellota", face = "$(MEDIUM_FONT)", fallback = true },
    { label = "ESO-FWUDS_70 M", face = "$(MEDIUM_FONT)", fallback = true },
    { label = "ESO-FWNTLGUDC70 DB", face = "$(BOLD_FONT)", fallback = true },
    { label = "Myingheiprc-w5", face = "$(MEDIUM_FONT)", fallback = true },
}

local FONT_OPTION_BY_LABEL = {}
local FONT_CHOICE_LABELS = {}
local FONT_FALLBACK_LABELS = {}
for _, fontOption in ipairs(FONT_OPTIONS) do
    FONT_OPTION_BY_LABEL[fontOption.label] = fontOption
    table.insert(FONT_CHOICE_LABELS, fontOption.label)
    if fontOption.fallback == true then
        table.insert(FONT_FALLBACK_LABELS, fontOption.label)
    end
end

local SLASH_COMMAND_DOCS = {
    { command = "/greed", description = T("Toggle the main Greed window.") },
    { command = "/greedtrade", description = T("Prepare newest-run tradeable loot links in Group chat.") },
    { command = "/greeddroptest", description = T("Add linked test drops for Drop List and Drop Text.") },
    { command = "/greedlootdebug", description = T("Toggle Drop List loot debug messages.") },
    { command = "/greedownedwhy", description = T("Toggle owned-count hover summaries.") },
}
Greed.slashCommandDocs = SLASH_COMMAND_DOCS

local TAMRIEL_TOMES_CONTROL_NAMES = {
    "TamrielTomes",
    "TamrielTomesWindow",
    "TamrielTomesFrame",
    "TamrielTomesMain",
    "TamrielTomesUI",
    "TamrielTomesPanel",
    "TamrielTomesBook",
    "TamrielTomesTome",
}
local DROP_LOG_TRAIT_FILTERS = {
    { key = "Powered", label = T("Powered") },
    { key = "Charged", label = T("Charged") },
    { key = "Precise", label = T("Precise") },
    { key = "Infused", label = T("Infused") },
    { key = "Defending", label = T("Defending") },
    { key = "Training", label = T("Training") },
    { key = "Sharpened", label = T("Sharpened") },
    { key = "Decisive", label = T("Decisive") },
    { key = "Nirnhoned", label = T("Nirnhoned") },
    { key = "Sturdy", label = T("Sturdy") },
    { key = "Impenetrable", label = T("Impenetrable") },
    { key = "Reinforced", label = T("Reinforced") },
    { key = "Well-fitted", label = T("Well-fitted") },
    { key = "Invigorating", label = T("Invigorating") },
    { key = "Divines", label = T("Divines") },
    { key = "Arcane", label = T("Arcane") },
    { key = "Healthy", label = T("Healthy") },
    { key = "Robust", label = T("Robust") },
    { key = "Triune", label = T("Triune") },
    { key = "Protective", label = T("Protective") },
    { key = "Swift", label = T("Swift") },
    { key = "Harmony", label = T("Harmony") },
    { key = "Bloodthirsty", label = T("Bloodthirsty") },
    { key = "Ornate", label = T("Ornate") },
    { key = "Intricate", label = T("Intricate") },
    { key = "Unknown", label = T("Unknown") },
}

local COLORS = {
    window = { 0.015, 0.013, 0.010, 0.98 },
    panel = { 0.055, 0.048, 0.038, 0.96 },
    launcher = { 0.030, 0.026, 0.020, 0.94 },
    row = { 0.035, 0.031, 0.024, 0.88 },
    rowAlt = { 0.050, 0.044, 0.034, 0.88 },
    rowDivider = { 0.78, 0.58, 0.22, 0.38 },
    edge = { 0.76, 0.58, 0.25, 0.95 },
    mutedEdge = { 0.35, 0.30, 0.21, 0.95 },
    cell = { 0.010, 0.009, 0.007, 0.98 },
    cellEdge = { 0.63, 0.48, 0.21, 0.96 },
    needFill = { 0.86, 0.02, 0.015, 0.42 },
    needTint = { 1.00, 0.04, 0.02, 0.88 },
    badge = { 0.02, 0.018, 0.014, 0.92 },
    emptyCell = { 0.005, 0.005, 0.004, 0.28 },
    text = { 0.94, 0.88, 0.73, 1 },
    mutedText = { 0.72, 0.66, 0.54, 1 },
    red = { 0.86, 0.04, 0.03, 0.58 },
    gold = { 1.00, 0.78, 0.24, 1 },
    activeTab = { 0.82, 0.64, 0.22, 1 },
    inactiveTab = { 0.58, 0.53, 0.43, 1 },
    collected = { 0.05, 1.00, 0.30, 1 },
    collectedBg = { 0.00, 0.10, 0.03, 0.88 },
    stickerBook = { 1.00, 0.82, 0.10, 1 },
    stickerBookBg = { 0.16, 0.11, 0.00, 0.88 },
    perfectedRow = { 0.235, 0.155, 0.040, 0.94 },
    perfectedRowAlt = { 0.285, 0.185, 0.052, 0.94 },
    perfectedRowEdge = { 1.00, 0.72, 0.16, 0.56 },
    perfectedText = { 1.00, 0.84, 0.42, 1 },
    perfectedMutedText = { 0.92, 0.74, 0.38, 1 },
    scrollTrack = { 0.045, 0.036, 0.018, 0.96 },
    scrollThumb = { 1.00, 0.74, 0.16, 1 },
}

local PERFECTED_BORDER_COLOR = { 1.00, 0.75, 0.10, 1 }
local MAIN_SCROLL_TRACK_COLOR = { 0.00, 0.00, 0.00, 0.72 }
local MAIN_SCROLL_TRACK_EDGE_COLOR = { 0.00, 0.00, 0.00, 0.00 }
local MAIN_SCROLL_TRACK_INSET_COLOR = { 0.00, 0.00, 0.00, 0.72 }
local MAIN_SCROLL_THUMB_COLOR = { 0.64, 0.46, 0.12, 0.96 }
local MAIN_SCROLL_THUMB_EDGE_COLOR = { 0.88, 0.66, 0.22, 1.00 }
local MAIN_SCROLL_INACTIVE_THUMB_COLOR = { 0.00, 0.00, 0.00, 0.72 }
local MAIN_SCROLL_INACTIVE_THUMB_EDGE_COLOR = { 0.00, 0.00, 0.00, 0.00 }
local MAIN_SCROLL_THUMB_HIGHLIGHT_COLOR = { 0.64, 0.46, 0.12, 0.96 }
local MAIN_SCROLL_THUMB_SHADOW_COLOR = { 0.42, 0.31, 0.10, 0.95 }
local PERFECTED_BORDER_STYLES = {
    {
        topTexture = "EsoUI/Art/Miscellaneous/progressbar_genericfill.dds",
        sideTexture = "EsoUI/Art/Miscellaneous/progressbar_genericfill.dds",
        topThickness = 4,
        sideThickness = 2,
        debugTopThickness = 6,
        debugSideThickness = 3,
        textureCoords = { 0, 1, 0, 1 },
        sideTextureCoords = { 0, 1, 0, 1 },
    },
    {
        topTexture = "EsoUI/Art/Tooltips/UI-TooltipCenter.dds",
        sideTexture = "EsoUI/Art/Tooltips/UI-TooltipCenter.dds",
        topThickness = 4,
        sideThickness = 2,
        debugTopThickness = 6,
        debugSideThickness = 3,
        textureCoords = { 0, 1, 0, 1 },
        sideTextureCoords = { 0, 1, 0, 1 },
    },
    {
        topTexture = "EsoUI/Art/Miscellaneous/progressbar_genericfill.dds",
        sideTexture = "EsoUI/Art/Tooltips/UI-TooltipCenter.dds",
        topThickness = 5,
        sideThickness = 4,
        debugTopThickness = 7,
        debugSideThickness = 5,
        textureCoords = { 0.15, 0.85, 0.15, 0.85 },
        sideTextureCoords = { 0, 1, 0, 1 },
    },
}


local PERFECTED_SIDE_OVERHANG_VALUES = { 0, 8, 12, 16, 20, 24 }
local DEFAULT_PERFECTED_SIDE_OVERHANG = 12

local WEAPON_ITEMS = {
    { key = "greatsword", label = T("Greatsword"), shortLabel = T("Great"), group = T("Two-Handed"), weaponType = WEAPONTYPE_TWO_HANDED_SWORD, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "battleAxe", label = T("Battle Axe"), shortLabel = T("BAxe"), group = T("Two-Handed"), weaponType = WEAPONTYPE_TWO_HANDED_AXE, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "maul", label = T("Maul"), shortLabel = T("Maul"), group = T("Two-Handed"), weaponType = WEAPONTYPE_TWO_HANDED_HAMMER, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "dagger", label = T("Dagger"), shortLabel = T("Dagg"), group = T("One-Handed"), weaponType = WEAPONTYPE_DAGGER, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "sword", label = T("Sword"), shortLabel = T("Swd"), group = T("One-Handed"), weaponType = WEAPONTYPE_SWORD, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "axe", label = T("Axe"), shortLabel = T("Axe"), group = T("One-Handed"), weaponType = WEAPONTYPE_AXE, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "mace", label = T("Mace"), shortLabel = T("Mace"), group = T("One-Handed"), weaponType = WEAPONTYPE_HAMMER, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "shield", label = T("Shield"), shortLabel = T("Shld"), group = T("Shield"), weaponType = WEAPONTYPE_SHIELD, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "bow", label = T("Bow"), shortLabel = T("Bow"), group = T("Ranged / Magical"), weaponType = WEAPONTYPE_BOW, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "flameStaff", label = T("Flame Staff"), shortLabel = T("Flame"), group = T("Ranged / Magical"), weaponType = WEAPONTYPE_FIRE_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "lightningStaff", label = T("Lightning Staff"), shortLabel = T("Ltng"), group = T("Ranged / Magical"), weaponType = WEAPONTYPE_LIGHTNING_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "frostStaff", label = T("Frost Staff"), shortLabel = T("Frost"), group = T("Ranged / Magical"), weaponType = WEAPONTYPE_FROST_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
    { key = "restorationStaff", label = T("Restoration Staff"), shortLabel = T("Resto"), group = T("Ranged / Magical"), weaponType = WEAPONTYPE_HEALING_STAFF, fallbackIcon = GreedData.placeholderIcons.weapon },
}

local WEAPON_ITEM_GROUPS = {
    { label = T("Two-Handed"), keys = { "greatsword", "battleAxe", "maul" }, column = 0, y = 0 },
    { label = T("One-Handed"), keys = { "dagger", "sword", "axe", "mace" }, column = 0, y = 96 },
    { label = T("Shield"), keys = { "shield" }, column = 0, y = 218 },
    { label = T("Ranged / Magical"), keys = { "bow", "flameStaff", "lightningStaff", "frostStaff", "restorationStaff" }, column = 1, y = 0 },
}

local LIVE_SET_NAME_ITEM_FILTERS = {
    { equipType = EQUIP_TYPE_CHEST },
    { equipType = EQUIP_TYPE_RING },
    { equipType = EQUIP_TYPE_NECK },
    { equipType = EQUIP_TYPE_HEAD },
    { equipType = EQUIP_TYPE_SHOULDERS },
    { weaponType = WEAPONTYPE_SWORD },
    { weaponType = WEAPONTYPE_FIRE_STAFF },
}

local WEAPON_ITEM_BY_KEY = {}
for _, weaponType in ipairs(WEAPON_ITEMS) do
    WEAPON_ITEM_BY_KEY[weaponType.key] = weaponType
end

local MONSTER_ARMOR_SLOT_KEYS = {
    head = true,
    shoulders = true,
}

local MONSTER_ARMOR_WEIGHT_OPTIONS = {
    { key = "light", label = T("Light"), armorType = ARMORTYPE_LIGHT },
    { key = "medium", label = T("Medium"), armorType = ARMORTYPE_MEDIUM },
    { key = "heavy", label = T("Heavy"), armorType = ARMORTYPE_HEAVY },
}

local MONSTER_ARMOR_WEIGHT_BY_KEY = {}
for _, option in ipairs(MONSTER_ARMOR_WEIGHT_OPTIONS) do
    MONSTER_ARMOR_WEIGHT_BY_KEY[option.key] = option
end

local FARM_WEAPON_LABELS = {
    greatsword = T("Greatsword"),
    battleAxe = T("Battle Axe"),
    maul = T("Maul"),
    dagger = T("Dagger"),
    sword = T("Sword"),
    axe = T("Axe"),
    mace = T("Mace"),
    shield = T("Shield"),
    bow = T("Bow"),
    flameStaff = T("Flame Staff"),
    lightningStaff = T("Ltng Staff"),
    frostStaff = T("Frost Staff"),
    restorationStaff = T("Resto Staff"),
}

local FARM_SLOT_LABELS = {
    head = T("Head"),
    shoulders = T("Shoulders"),
    chest = T("Chest"),
    hands = T("Hands"),
    waist = T("Waist"),
    legs = T("Legs"),
    feet = T("Feet"),
    neck = T("Necklace"),
    ring = T("Ring"),
}

local ARMOR_SLOT_LOCALIZATION = {
    head = { label = T("Head"), shortLabel = T("Head") },
    shoulders = { label = T("Shoulders"), shortLabel = T("Shldr") },
    chest = { label = T("Chest"), shortLabel = T("Chest") },
    hands = { label = T("Hands"), shortLabel = T("Hands") },
    waist = { label = T("Waist"), shortLabel = T("Waist") },
    legs = { label = T("Legs"), shortLabel = T("Legs") },
    feet = { label = T("Feet"), shortLabel = T("Feet") },
    neck = { label = T("Neck"), shortLabel = T("Neck") },
    ring = { label = T("Ring"), shortLabel = T("Ring") },
}

for _, slot in ipairs(GreedData.armorSlots or {}) do
    local labels = ARMOR_SLOT_LOCALIZATION[slot.key]
    if labels then
        slot.label = labels.label
        slot.shortLabel = labels.shortLabel
    end
end

local LEGACY_WEAPON_LOCALIZATION = {
    lightningStaff = { label = T("Lightning Staff"), badge = T("Ltng") },
    restorationStaff = { label = T("Restoration Staff"), badge = T("Resto") },
    bow = { label = T("Bow"), badge = T("Bow") },
    iceStaff = { label = T("Ice Staff"), badge = T("Ice") },
    fireStaff = { label = T("Fire Staff"), badge = T("Fire") },
}

for key, weaponType in pairs(GreedData.weaponTypes or {}) do
    local labels = LEGACY_WEAPON_LOCALIZATION[key]
    if labels then
        weaponType.label = labels.label
        weaponType.badge = labels.badge
    end
end

local function CallControlMethod(control, methodName, ...)
    local method = control and control[methodName]
    if type(method) == "function" then
        method(control, ...)
    end
end

local function GetControlDimension(control, methodName, fallback)
    local method = control and control[methodName]
    if type(method) == "function" then
        local value = method(control)
        if type(value) == "number" and value > 0 then
            return value
        end
    end

    return fallback
end

local function AllowMultilineLabelText(label, maxLines)
    CallControlMethod(label, "SetMaxLineCount", maxLines or 0)
end

local function GetUtf8CharacterByteLength(firstByte)
    if type(firstByte) ~= "number" then return 1 end
    if firstByte < 0x80 then return 1 end
    if firstByte < 0xE0 then return 2 end
    if firstByte < 0xF0 then return 3 end
    if firstByte < 0xF8 then return 4 end
    return 1
end

local function CreatePromptDragSurface(parent, baseName)
    if not WINDOW_MANAGER or not parent or not baseName then return nil end

    local surface = WINDOW_MANAGER:CreateControl(baseName .. "DragSurface", parent, CT_CONTROL)
    surface:SetAnchorFill(parent)
    surface:SetMouseEnabled(false)
    surface:SetHidden(true)
    CallControlMethod(surface, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(surface, "SetDrawTier", DT_HIGH)
    CallControlMethod(surface, "SetDrawLevel", 2300)
    return surface
end

local function SetBackdropStyle(backdrop, centerColor, edgeColor)
    if not backdrop then return end

    CallControlMethod(backdrop, "SetCenterTexture", "EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    CallControlMethod(backdrop, "SetEdgeTexture", "EsoUI/Art/Tooltips/UI-TooltipEdge.dds", 128, 16)
    CallControlMethod(backdrop, "SetCenterColor", centerColor[1], centerColor[2], centerColor[3], centerColor[4])
    CallControlMethod(backdrop, "SetEdgeColor", edgeColor[1], edgeColor[2], edgeColor[3], edgeColor[4])
end

local function SetSolidBackdrop(backdrop, color)
    if not backdrop then return end

    CallControlMethod(backdrop, "SetCenterTexture", "EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    CallControlMethod(backdrop, "SetCenterColor", color[1], color[2], color[3], color[4])
    CallControlMethod(backdrop, "SetEdgeColor", 0, 0, 0, 0)
end

local function SetTransparentCheckBackdrop(backdrop, edgeColor)
    if not backdrop then return end

    -- Keep the old reliable boxed checkbox look. Transparent/custom-drawn checks were too hard to see in ESO.
    local fillColor = COLORS.collectedBg
    if edgeColor == COLORS.stickerBook then
        fillColor = COLORS.stickerBookBg
    end

    SetBackdropStyle(backdrop, fillColor, edgeColor or COLORS.edge)
end


local function SetButtonText(button, text)
    button:SetText(text)
    button:SetFont("ZoFontGame")
    CallControlMethod(button, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
    CallControlMethod(button, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    button:SetNormalFontColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    button:SetMouseOverFontColor(1, 0.95, 0.72, 1)
    button:SetPressedFontColor(COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1)
end

local function GetControlTextWidth(control, fallback)
    if control and type(control.GetTextWidth) == "function" then
        local ok, value = pcall(function()
            return control:GetTextWidth()
        end)
        if ok and type(value) == "number" and value > 0 then
            return value
        end
    end

    return fallback or 80
end

local function ShowGreedSimpleTooltip(target, text)
    if not WINDOW_MANAGER or not GuiRoot or not target or not text or text == "" then return end

    if not Greed.simpleTooltipControls then
        local window = WINDOW_MANAGER:CreateControl("GreedSimpleTooltipWindow", GuiRoot, CT_TOPLEVELCONTROL)
        window:SetMouseEnabled(false)
        window:SetHidden(true)
        CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
        CallControlMethod(window, "SetDrawTier", DT_HIGH)
        CallControlMethod(window, "SetDrawLevel", 4000)

        local backdrop = WINDOW_MANAGER:CreateControl("GreedSimpleTooltipBackdrop", window, CT_BACKDROP)
        backdrop:SetAnchorFill(window)
        backdrop:SetMouseEnabled(false)
        SetBackdropStyle(backdrop, { 0.018, 0.016, 0.012, 0.98 }, COLORS.edge)

        local label = WINDOW_MANAGER:CreateControl("GreedSimpleTooltipLabel", window, CT_LABEL)
        label:SetAnchor(TOPLEFT, window, TOPLEFT, 8, 5)
        label:SetFont("ZoFontGameSmall")
        label:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
        label:SetMouseEnabled(false)

        Greed.simpleTooltipControls = {
            window = window,
            label = label,
        }
    end

    local controls = Greed.simpleTooltipControls
    local window = controls.window
    local label = controls.label
    AllowMultilineLabelText(label, 4)
    label:SetText(text)

    local horizontalPadding = 20
    local verticalPadding = 12
    local maxLabelWidth = 340
    local textWidth = math.ceil(GetControlTextWidth(label, (#text * 7) + 4))
    local labelWidth = math.max(80, math.min(maxLabelWidth, textWidth + 2))

    -- Give the label a bounded measurement area first so localized text can wrap,
    -- then size the tooltip from the rendered text height instead of clipping it.
    label:SetDimensions(labelWidth, 120)
    local textHeight = GetControlDimension(label, "GetTextHeight", 18)
    if textHeight <= 18 and textWidth > labelWidth then
        textHeight = math.ceil(textWidth / labelWidth) * 18
    end
    textHeight = math.max(18, math.min(72, math.ceil(textHeight)))

    local width = labelWidth + horizontalPadding
    local height = textHeight + verticalPadding
    label:SetDimensions(labelWidth, textHeight)
    window:SetDimensions(width, height)

    local targetLeft = target.GetLeft and target:GetLeft() or 0
    local targetTop = target.GetTop and target:GetTop() or 0
    local targetHeight = target.GetHeight and target:GetHeight() or 24
    local rootWidth = GetControlDimension(GuiRoot, "GetWidth", 1280)
    local rootHeight = GetControlDimension(GuiRoot, "GetHeight", 720)
    local x = math.max(4, math.min(rootWidth - width - 4, targetLeft))
    local y = targetTop - height - 6
    if y < 4 then
        y = targetTop + targetHeight + 6
    end
    y = math.max(4, math.min(rootHeight - height - 4, y))

    window:ClearAnchors()
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 4000)
    CallControlMethod(window, "BringWindowToTop")
    window:SetHidden(false)
end

local function HideGreedSimpleTooltip()
    if Greed.simpleTooltipControls and Greed.simpleTooltipControls.window then
        Greed.simpleTooltipControls.window:SetHidden(true)
    end
end

local function SetSimpleTooltip(control, tooltipText)
    if not control then return end

    control:SetHandler("OnMouseEnter", function(target)
        local text = type(tooltipText) == "function" and tooltipText() or tooltipText
        if not text or text == "" then return end
        ShowGreedSimpleTooltip(target, text)
    end)

    control:SetHandler("OnMouseExit", function()
        HideGreedSimpleTooltip()
    end)
end

local function CreateSolidIconPart(parent, name, width, height, color)
    local part = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    part:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    part:SetDimensions(width, height)
    part:SetColor((color or COLORS.text)[1], (color or COLORS.text)[2], (color or COLORS.text)[3], (color or COLORS.text)[4])
    part:SetMouseEnabled(false)
    return part
end

local function AddTextureIcon(parent, name, texturePath, size, color)
    local texture = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    texture:SetDimensions(size or 24, size or 24)
    texture:SetAnchor(CENTER, parent, CENTER, 0, 0)
    texture:SetTexture(texturePath)
    texture:SetColor((color or COLORS.text)[1], (color or COLORS.text)[2], (color or COLORS.text)[3], (color or COLORS.text)[4])
    texture:SetMouseEnabled(false)
    return texture
end

local function AddDropListButtonIcon(button, baseName, iconType)
    if not button then return end

    local icon = WINDOW_MANAGER:CreateControl(baseName .. "Icon", button, CT_CONTROL)
    icon:SetDimensions(28, 28)
    icon:SetAnchor(CENTER, button, CENTER, 0, 0)
    icon:SetMouseEnabled(false)

    if iconType == "lock" then
        button.greedLockIcon = AddTextureIcon(icon, baseName .. "KeyTexture", "EsoUI/Art/WorldMap/map_indexicon_key_up.dds", 24, COLORS.text)
    elseif iconType == "filter" then
        AddTextureIcon(icon, baseName .. "FilterTexture", "EsoUI/Art/WorldMap/map_indexicon_filters_up.dds", 24, COLORS.text)
    elseif iconType == "close" then
        local label = WINDOW_MANAGER:CreateControl(baseName .. "CloseLabel", icon, CT_LABEL)
        label:SetDimensions(24, 24)
        label:SetAnchor(CENTER, icon, CENTER, 0, 0)
        label:SetFont("ZoFontGameBold")
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
        label:SetText("X")
        label:SetMouseEnabled(false)
    end

    return icon
end

local function AddResizeGripIcon(control, baseName, side)
    if not control then return end

    control:SetText("")
    control:SetMouseEnabled(true)

    local icon = WINDOW_MANAGER:CreateControl(baseName .. "Icon", control, CT_CONTROL)
    icon:SetDimensions(26, 22)
    if side == "left" then
        icon:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 4, -2)
    else
        icon:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -4, -2)
    end
    icon:SetMouseEnabled(false)

    local function addPart(partName, width, height, anchorPoint, relativeTo, relativePoint, offsetX, offsetY)
        local part = CreateSolidIconPart(icon, baseName .. partName, width, height, COLORS.edge)
        part:SetAnchor(anchorPoint, relativeTo or icon, relativePoint or anchorPoint, offsetX or 0, offsetY or 0)
        return part
    end

    -- Pixel-art resize grips: small block-built arrows pointing toward the bottom corners.
    -- These avoid the ESO directional-arrow textures, which only looked correct left/right.
    if side == "left" then
        addPart("CornerH", 14, 2, BOTTOMLEFT, icon, BOTTOMLEFT, 0, 0)
        addPart("CornerV", 2, 14, BOTTOMLEFT, icon, BOTTOMLEFT, 0, 0)
        addPart("Diag1", 3, 3, BOTTOMLEFT, icon, BOTTOMLEFT, 4, -4)
        addPart("Diag2", 3, 3, BOTTOMLEFT, icon, BOTTOMLEFT, 8, -8)
        addPart("Diag3", 3, 3, BOTTOMLEFT, icon, BOTTOMLEFT, 12, -12)
        addPart("HeadH", 8, 2, BOTTOMLEFT, icon, BOTTOMLEFT, 0, -6)
        addPart("HeadV", 2, 8, BOTTOMLEFT, icon, BOTTOMLEFT, 6, 0)
    else
        addPart("CornerH", 14, 2, BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
        addPart("CornerV", 2, 14, BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, 0)
        addPart("Diag1", 3, 3, BOTTOMRIGHT, icon, BOTTOMRIGHT, -4, -4)
        addPart("Diag2", 3, 3, BOTTOMRIGHT, icon, BOTTOMRIGHT, -8, -8)
        addPart("Diag3", 3, 3, BOTTOMRIGHT, icon, BOTTOMRIGHT, -12, -12)
        addPart("HeadH", 8, 2, BOTTOMRIGHT, icon, BOTTOMRIGHT, 0, -6)
        addPart("HeadV", 2, 8, BOTTOMRIGHT, icon, BOTTOMRIGHT, -6, 0)
    end

    control.greedResizeGripIcon = icon
    control.greedResizeGripSide = side

    return icon
end

local function ClearButtonTextures(button)
    if not button then return end

    CallControlMethod(button, "SetNormalTexture", "")
    CallControlMethod(button, "SetMouseOverTexture", "")
    CallControlMethod(button, "SetPressedTexture", "")
    CallControlMethod(button, "SetDisabledTexture", "")
end

local function SafeAnnounce(message)
    if CHAT_SYSTEM then
        CHAT_SYSTEM:AddMessage(message)
    elseif d then
        d(message)
    end
end

local function TrimText(value)
    return tostring(value or ""):match("^%s*(.-)%s*$")
end

local function GetFontOption(fontName)
    return FONT_OPTION_BY_LABEL[fontName or ""] or FONT_OPTION_BY_LABEL[DEFAULT_FONT_NAME] or FONT_OPTIONS[1]
end

local function BuildFontString(fontName, size, weightSuffix)
    local fontOption = GetFontOption(fontName)
    local face = fontOption and fontOption.face or "$(MEDIUM_FONT)"
    local language = GetClientLanguageCode()
    if LOCALE_SAFE_FONT_LANGUAGES[language] then
        -- The selectable Latin font files do not contain every Cyrillic or CJK glyph.
        -- Keep the saved font choice, but render Drop List and prompt text with ESO's locale-aware font.
        face = "$(MEDIUM_FONT)"
    end
    local fontSize = math.floor(tonumber(size) or 16)
    local suffix = weightSuffix or "soft-shadow-thin"
    -- Use a direct numeric font size instead of arbitrary $(KB_N) macros.
    -- ESO does not define every KB_* size, so values like 29, 34, or 42 could fall back tiny.
    return string.format("%s|%d|%s", face, fontSize, suffix)
end

local function StyleTransparentTextButton(button)
    if not button then return end

    ClearButtonTextures(button)
    CallControlMethod(button, "SetHorizontalAlignment", TEXT_ALIGN_CENTER)
    CallControlMethod(button, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    CallControlMethod(button, "SetNormalFontColor", COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    CallControlMethod(button, "SetMouseOverFontColor", 1, 0.95, 0.72, 1)
    CallControlMethod(button, "SetPressedFontColor", COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1)
end

Greed.Internal = Greed.Internal or {}
local Internal = Greed.Internal
Internal.T = T
Internal.libSets = libSets
Internal.GetClientLanguageCode = GetClientLanguageCode
Internal.SLOT_SIZE = SLOT_SIZE
Internal.SLOT_GAP = SLOT_GAP
Internal.ROW_HEIGHT = ROW_HEIGHT
Internal.SLOT_START_X = SLOT_START_X
Internal.MAIN_WINDOW_DEFAULT_WIDTH = MAIN_WINDOW_DEFAULT_WIDTH
Internal.MAIN_WINDOW_DEFAULT_HEIGHT = MAIN_WINDOW_DEFAULT_HEIGHT
Internal.MAIN_WINDOW_ROWS_TOP = MAIN_WINDOW_ROWS_TOP
Internal.MAIN_WINDOW_SLOT_HEADER_TOP = MAIN_WINDOW_SLOT_HEADER_TOP
Internal.MAIN_WINDOW_FOOTER_HEIGHT = MAIN_WINDOW_FOOTER_HEIGHT
Internal.MAIN_WINDOW_FOOTER_BOTTOM = MAIN_WINDOW_FOOTER_BOTTOM
Internal.MAIN_WINDOW_TABS_Y = MAIN_WINDOW_TABS_Y
Internal.MAIN_SCROLLBAR_WINDOW_RIGHT_INSET = MAIN_SCROLLBAR_WINDOW_RIGHT_INSET
Internal.MAIN_ROWS_LEFT_INSET = MAIN_ROWS_LEFT_INSET
Internal.MAIN_ROWS_RIGHT_INSET = MAIN_ROWS_RIGHT_INSET
Internal.FOOTER_LEGEND_GROUP_WIDTH = FOOTER_LEGEND_GROUP_WIDTH
Internal.FOOTER_LEGEND_ITEM_SPACING = FOOTER_LEGEND_ITEM_SPACING
Internal.COLORS = COLORS
Internal.CallControlMethod = CallControlMethod
Internal.GetControlDimension = GetControlDimension
Internal.SetBackdropStyle = SetBackdropStyle
Internal.SetTransparentCheckBackdrop = SetTransparentCheckBackdrop
Internal.SetButtonText = SetButtonText
Internal.GetControlTextWidth = GetControlTextWidth
Internal.SetSimpleTooltip = SetSimpleTooltip
Internal.WEAPON_ITEMS = WEAPON_ITEMS
Internal.SafeAnnounce = SafeAnnounce
Internal.NormalizeClientLanguageCode = NormalizeClientLanguageCode
Internal.DEFAULT_PAGE_NAME = DEFAULT_PAGE_NAME
Internal.GetCachedAllSetNames = GetCachedAllSetNames
Internal.GetLibSetsSearchCache = GetLibSetsSearchCache
Internal.GetLiveSetNameCache = GetLiveSetNameCache
Internal.SortAddSetResultsByBaseName = SortAddSetResultsByBaseName
Internal.ADD_SET_RESULT_LIMIT = ADD_SET_RESULT_LIMIT
Internal.SETS_OVERVIEW_MAX_ROWS = SETS_OVERVIEW_MAX_ROWS
Internal.SOURCES_TO_FARM_MAX_ROWS = SOURCES_TO_FARM_MAX_ROWS
Internal.SOURCES_TO_FARM_ROW_HEIGHT = SOURCES_TO_FARM_ROW_HEIGHT
Internal.WEAPON_ITEM_GROUPS = WEAPON_ITEM_GROUPS
Internal.LIVE_SET_NAME_ITEM_FILTERS = LIVE_SET_NAME_ITEM_FILTERS
Internal.WEAPON_ITEM_BY_KEY = WEAPON_ITEM_BY_KEY
Internal.MONSTER_ARMOR_SLOT_KEYS = MONSTER_ARMOR_SLOT_KEYS
Internal.MONSTER_ARMOR_WEIGHT_OPTIONS = MONSTER_ARMOR_WEIGHT_OPTIONS
Internal.FARM_WEAPON_LABELS = FARM_WEAPON_LABELS
Internal.FARM_SLOT_LABELS = FARM_SLOT_LABELS
Internal.AllowMultilineLabelText = AllowMultilineLabelText
Internal.TrimText = TrimText
Internal.StyleTransparentTextButton = StyleTransparentTextButton
Internal.TRACKING_SCOPE_CHOICES = TRACKING_SCOPE_CHOICES
Internal.CHAMPION_POINTS_SCENE_NAMES = CHAMPION_POINTS_SCENE_NAMES
Internal.SAVED_VAR_DEFAULTS = SAVED_VAR_DEFAULTS
Internal.DROP_LOG_MAX_ENTRIES = DROP_LOG_MAX_ENTRIES
Internal.DROP_LOG_MAX_VISIBLE_ROWS = DROP_LOG_MAX_VISIBLE_ROWS
Internal.DROP_LOG_DEFAULT_WIDTH = DROP_LOG_DEFAULT_WIDTH
Internal.DROP_LOG_DEFAULT_HEIGHT = DROP_LOG_DEFAULT_HEIGHT
Internal.DROP_LOG_MIN_WIDTH = DROP_LOG_MIN_WIDTH
Internal.DROP_LOG_MIN_HEIGHT = DROP_LOG_MIN_HEIGHT
Internal.DROP_LOG_MAX_WIDTH = DROP_LOG_MAX_WIDTH
Internal.DROP_LOG_MAX_HEIGHT = DROP_LOG_MAX_HEIGHT
Internal.DEFAULT_DROP_ASK_MESSAGE = DEFAULT_DROP_ASK_MESSAGE
Internal.DROP_LOG_PAGE_FILTER_ALL = DROP_LOG_PAGE_FILTER_ALL
Internal.DROP_LOG_PAGE_FILTER_ALL_DROPS = DROP_LOG_PAGE_FILTER_ALL_DROPS
Internal.DROP_LOG_DEFAULT_OPACITY = DROP_LOG_DEFAULT_OPACITY
Internal.DROP_LOG_TEXT_SIZES = DROP_LOG_TEXT_SIZES
Internal.DEFAULT_DROP_LOG_TEXT_SIZE_INDEX = DEFAULT_DROP_LOG_TEXT_SIZE_INDEX
Internal.DROP_LOG_TEXT_SIZE_VERSION = DROP_LOG_TEXT_SIZE_VERSION
Internal.DEFAULT_FONT_NAME = DEFAULT_FONT_NAME
Internal.TEXT_PROMPT_SIZE_LABELS = TEXT_PROMPT_SIZE_LABELS
Internal.TEXT_PROMPT_SIZE_BY_KEY = TEXT_PROMPT_SIZE_BY_KEY
Internal.TEXT_PROMPT_COLOR_LABELS = TEXT_PROMPT_COLOR_LABELS
Internal.TEXT_PROMPT_COLOR_BY_KEY = TEXT_PROMPT_COLOR_BY_KEY
Internal.FONT_OPTION_BY_LABEL = FONT_OPTION_BY_LABEL
Internal.TAMRIEL_TOMES_CONTROL_NAMES = TAMRIEL_TOMES_CONTROL_NAMES
Internal.DROP_LOG_TRAIT_FILTERS = DROP_LOG_TRAIT_FILTERS
Internal.AddDropListButtonIcon = AddDropListButtonIcon
Internal.AddResizeGripIcon = AddResizeGripIcon
Internal.BuildFontString = BuildFontString
Internal.DEFAULT_TEXT_PROMPT_DURATION_MS = DEFAULT_TEXT_PROMPT_DURATION_MS
Internal.DROP_TEXT_FADE_IN_MS = DROP_TEXT_FADE_IN_MS
Internal.DROP_TEXT_FADE_OUT_MS = DROP_TEXT_FADE_OUT_MS
Internal.DROP_TEXT_ALERT_STAGGER_MS = DROP_TEXT_ALERT_STAGGER_MS
Internal.SPAULDER_OF_RUIN_ITEM_LINK = SPAULDER_OF_RUIN_ITEM_LINK
Internal.SPAULDER_AURA_OF_PRIDE_ABILITY_ID = SPAULDER_AURA_OF_PRIDE_ABILITY_ID
Internal.SPAULDER_AURA_DURATION_MS = SPAULDER_AURA_DURATION_MS
Internal.TEXT_PROMPT_SIZE_OPTIONS = TEXT_PROMPT_SIZE_OPTIONS
Internal.TEXT_PROMPT_SIZE_BY_LABEL = TEXT_PROMPT_SIZE_BY_LABEL
Internal.TEXT_PROMPT_COLOR_BY_LABEL = TEXT_PROMPT_COLOR_BY_LABEL
Internal.PASTEL_RAINBOW_HEX = PASTEL_RAINBOW_HEX
Internal.GetUtf8CharacterByteLength = GetUtf8CharacterByteLength
Internal.CreatePromptDragSurface = CreatePromptDragSurface
Internal.FONT_CHOICE_LABELS = FONT_CHOICE_LABELS

function Greed:Debug(message)
    SafeAnnounce("Greed debug: " .. tostring(message))
end

function Greed:GetFontFaceByLabel(label)
    local fontOption = GetFontOption(label)
    return fontOption and fontOption.face or "$(MEDIUM_FONT)"
end

function Greed:BuildFontString(fontLabel, size, weightSuffix)
    return BuildFontString(fontLabel, size, weightSuffix)
end

function Greed:PrintFontDebug()
    self:InitializeDropLogSettings()
    self:InitializeTextPromptSettings()
    local dropSize = self:GetDropLogTextSizeData()
    SafeAnnounce("Greed font debug: Drop List label=" .. tostring(self.savedVars.dropLog.fontName or DEFAULT_FONT_NAME))
    SafeAnnounce("Greed font debug: Drop List row font=" .. tostring(dropSize.font or "nil"))
    local dropPrompt = self:GetPromptSettings("drop")
    local spaulderPrompt = self:GetPromptSettings("spaulder")
    SafeAnnounce("Greed font debug: Drop Text label=" .. tostring(dropPrompt.fontName or DEFAULT_FONT_NAME))
    SafeAnnounce("Greed font debug: Drop Text font=" .. tostring(self:GetTextPromptFont("drop")))
    SafeAnnounce("Greed font debug: Spaulder Text label=" .. tostring(spaulderPrompt.fontName or DEFAULT_FONT_NAME))
    SafeAnnounce("Greed font debug: Spaulder Text font=" .. tostring(self:GetTextPromptFont("spaulder")))
end

function Greed:RunCallback(callback, debugLabel)
    if callback == nil then
        self:Debug(debugLabel .. " callback is missing.")
        return
    end

    if type(callback) ~= "function" then
        self:Debug(debugLabel .. " callback is not callable.")
        return
    end

    callback()
end

function Greed:StartMovingControl(control)
    if not control then
        self:Debug("Cannot move a missing control.")
        return false
    end

    CallControlMethod(control, "SetMovable", true)

    if type(control.StartMoving) ~= "function" then
        self:Debug("Cannot start launcher/window movement because StartMoving is unavailable.")
        return false
    end

    control:StartMoving()
    return true
end

function Greed:StopMovingControl(control)
    if not control then
        self:Debug("Cannot stop movement for a missing control.")
        return false
    end

    if type(control.StopMovingOrResizing) == "function" then
        control:StopMovingOrResizing()
    elseif type(control.StopMovingOrSizing) == "function" then
        control:StopMovingOrSizing()
    else
        -- Some ESO controls end movement when Movable is turned off; use that as a safe fallback.
        self:Debug("StopMovingOrResizing is unavailable; ending movement by disabling movable state.")
    end

    CallControlMethod(control, "SetMovable", false)

    return true
end

function Greed:Initialize()
    local serverNamespace = GetSavedVarsServerNamespace()
    if serverNamespace then
        local legacySavedVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, SAVED_VAR_DEFAULTS)
        local serverSavedVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, serverNamespace, SAVED_VAR_DEFAULTS)

        if serverSavedVars[SERVER_SAVED_VARS_MIGRATION_FLAG] ~= true then
            local serverHasUserData = SavedVarValueDiffersFromDefault(serverSavedVars, SAVED_VAR_DEFAULTS)
            local legacyHasUserData = SavedVarValueDiffersFromDefault(legacySavedVars, SAVED_VAR_DEFAULTS)
            if not serverHasUserData and legacyHasUserData then
                CopySavedVarsInto(legacySavedVars, serverSavedVars)
            end
            serverSavedVars[SERVER_SAVED_VARS_MIGRATION_FLAG] = true
        end

        self.savedVars = serverSavedVars
    else
        self.savedVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, SAVED_VAR_DEFAULTS)
    end
    self.savedVars.launcher = self.savedVars.launcher or {}
    self.savedVars.launcher.locked = self.savedVars.launcher.locked == true
    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self:InitializeTrackingProfiles()
    self:InitializeSavedPages()
    self:InitializeDropLogSettings()
    self:InitializeTextPromptSettings()
    self:InitializeAntiquityLeadSettings()
    self:MigrateSavedWeaponTracking()
    self.cursorModeOwned = false
    self.iconFallbackDebugShown = {}
    self.perfectedBorderDebugPrinted = false
    self.debugBorderMode = false
    self.borderStyle = 1
    self.borderSideOverhang = DEFAULT_PERFECTED_SIDE_OVERHANG
    self.perfectedBorders = {}
    self.firstPerfectedBorder = nil
    self.borderSizeDebugPrinted = false
    self.legendGoldBorder = nil
    self.hasOpenedWindow = false

    self.controls = {
        window = GreedWindow,
        launcher = GreedLauncher,
        rows = GreedWindowRows,
        slotHeader = GreedWindowSlotHeader,
        footer = GreedWindowFooter,
        pageDropdown = GreedWindowPageDropdown,
        titleBar = GreedWindowTitleBar,
        close = GreedWindowTitleBarClose,
        tabs = {
            favorites = GreedWindowTabsFavorites,
            sets = GreedWindowTabsSets,
            statistics = GreedWindowTabsStatistics,
            options = GreedWindowTabsOptions,
        },
        newPage = GreedWindowNewPage,
    }

    self.activeTab = "grid"
    CallControlMethod(self.controls.window, "SetKeyboardEnabled", false)

    self:StyleStaticControls()
    self:RestoreLauncherPosition()
    self:WireMovement()
    self:RestoreMainWindowSize()
    self:CreateMainWindowResizeControls()
    self:WireActions()
    self:BuildPageDropdown()
    self:BuildTabs()
    self.displayFavorites = self:BuildDisplayFavorites()
    self:BuildVisibleColumns()
    self:UpdateMainWindowLayout()
    self:BuildSlotHeader()
    self:SetupRowsScrolling()
    self:BuildFavorites()
    self:BuildFooter()
    self:LiftMainTopControls()
    self:RegisterAddonSettingsPanel()
    self:StartDropListMenuWatcher()
    self:RegisterEscapeCloseHandler()
    self:RefreshLauncherVisibility()
    self:StartTextPromptWatcher()

    if self.savedVars.dropLog.enabled == true then
        self:ShowDropListWindow(false)
    end

    SLASH_COMMANDS["/greed"] = function()
        self:ToggleWindow()
    end

    SLASH_COMMANDS["/greedtrade"] = function(args)
        self:HandleGreedTradeCommand(args)
    end

    SLASH_COMMANDS["/greeddroptest"] = function()
        self:AddDropLogTestEntry()
    end

    SLASH_COMMANDS["/greedlootdebug"] = function()
        self:InitializeDropLogSettings()
        self.savedVars.dropLog.debugLoot = not (self.savedVars.dropLog.debugLoot == true)
        SafeAnnounce("Greed: Loot debug " .. (self.savedVars.dropLog.debugLoot and "ON" or "OFF") .. ".")
    end

    SLASH_COMMANDS["/greedownedwhy"] = function()
        self.ownedWhyDebug = not (self.ownedWhyDebug == true)
        SafeAnnounce("Greed: owned-count hover summary " .. (self.ownedWhyDebug and "ON" or "OFF") .. ".")
    end

    if EVENT_GAME_CAMERA_UI_MODE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GAME_CAMERA_UI_MODE_CHANGED, function()
            self:OnGameCameraUIModeChanged()
        end)
    end

    if EVENT_ITEM_SET_COLLECTIONS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "CollectionRefreshAll", EVENT_ITEM_SET_COLLECTIONS_UPDATED, function()
            self:RefreshCollectionStatus()
        end)
    end

    if EVENT_ITEM_SET_COLLECTION_UPDATED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "CollectionRefreshOne", EVENT_ITEM_SET_COLLECTION_UPDATED, function()
            self:RefreshCollectionStatus()
        end)
    end

    self:RegisterOwnedInventoryRefreshEvents()
    self:RegisterTradeLootRuntimeEvents()

    if EVENT_LOOT_RECEIVED then
        EVENT_MANAGER:RegisterForEvent(self.name .. "DropLogLootReceived", EVENT_LOOT_RECEIVED, function(_, receivedBy, itemName, quantity, soundCategory, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId)
            self:OnLootReceivedForDropLog(receivedBy, itemName, quantity, lootType, lootedBySelf, itemId)
        end)
    end

end

function Greed:GetCharacterTrackingKey()
    if type(GetCurrentCharacterId) == "function" then
        local ok, characterId = pcall(GetCurrentCharacterId)
        if ok and characterId ~= nil then
            local key = tostring(characterId)
            if key ~= "" and key ~= "0" then
                return key
            end
        end
    end

    local name
    if type(GetRawUnitName) == "function" then
        local ok, rawName = pcall(GetRawUnitName, "player")
        if ok then name = rawName end
    end
    if (type(name) ~= "string" or name == "") and type(GetUnitName) == "function" then
        local ok, unitName = pcall(GetUnitName, "player")
        if ok then name = unitName end
    end

    if type(name) == "string" and name ~= "" then
        return name
    end

    return "__unknown_character__"
end

function Greed:CreateEmptyTrackingProfile()
    return {
        pages = {},
        pageOrder = {},
        currentPage = DEFAULT_PAGE_NAME,
    }
end

function Greed:NormalizeTrackingProfile(profile)
    if type(profile) ~= "table" then
        profile = self:CreateEmptyTrackingProfile()
    end
    if type(profile.pages) ~= "table" then
        profile.pages = {}
    end
    if type(profile.pageOrder) ~= "table" then
        profile.pageOrder = {}
    end
    if type(profile.currentPage) ~= "string" or profile.currentPage == "" then
        profile.currentPage = DEFAULT_PAGE_NAME
    end

    for _, pageData in pairs(profile.pages) do
        if type(pageData) == "table" then
            if type(pageData.sets) ~= "table" then
                pageData.sets = {}
            end
            if type(pageData.removedSets) ~= "table" then
                pageData.removedSets = {}
            end
        end
    end

    return profile
end

function Greed:TrackingProfileHasListData(profile)
    return type(profile) == "table"
        and ((type(profile.pages) == "table" and next(profile.pages) ~= nil)
            or (type(profile.pageOrder) == "table" and #profile.pageOrder > 0))
end

function Greed:InitializeTrackingProfiles()
    if not self.savedVars then return end

    self.savedVars.trackedListScope = NormalizeTrackingScope(self.savedVars.trackedListScope)
    if type(self.savedVars.trackedListScopeByCharacter) ~= "table" then
        self.savedVars.trackedListScopeByCharacter = {}
    end
    if self.savedVars[TRACKING_SCOPE_SELECTION_MIGRATION_FLAG] ~= true then
        local characterKey = self:GetCharacterTrackingKey()
        if self.savedVars.trackedListScopeByCharacter[characterKey] == nil then
            self.savedVars.trackedListScopeByCharacter[characterKey] = self.savedVars.trackedListScope
        end
        self.savedVars[TRACKING_SCOPE_SELECTION_MIGRATION_FLAG] = true
    end

    if type(self.savedVars.trackingProfiles) ~= "table" then
        self.savedVars.trackingProfiles = {}
    end

    local profiles = self.savedVars.trackingProfiles
    profiles.account = self:NormalizeTrackingProfile(profiles.account)
    if type(profiles.characters) ~= "table" then
        profiles.characters = {}
    end

    if self.savedVars[TRACKING_PROFILE_MIGRATION_FLAG] ~= true then
        local legacyProfile = {
            pages = self.savedVars.pages,
            pageOrder = self.savedVars.pageOrder,
            currentPage = self.savedVars.currentPage,
        }
        if self:TrackingProfileHasListData(legacyProfile) and not self:TrackingProfileHasListData(profiles.account) then
            profiles.account.pages = CopySavedVarValue(legacyProfile.pages or {})
            profiles.account.pageOrder = CopySavedVarValue(legacyProfile.pageOrder or {})
            profiles.account.currentPage = legacyProfile.currentPage
        end
        profiles.account = self:NormalizeTrackingProfile(profiles.account)
        self.savedVars[TRACKING_PROFILE_MIGRATION_FLAG] = true
    end
end

function Greed:GetTrackingScope()
    self:InitializeTrackingProfiles()
    local characterKey = self:GetCharacterTrackingKey()
    local scopes = self.savedVars.trackedListScopeByCharacter
    local scope = NormalizeTrackingScope(scopes[characterKey])
    scopes[characterKey] = scope
    return scope
end

function Greed:GetTrackingScopeLabel()
    return TRACKING_SCOPE_LABEL_BY_SCOPE[self:GetTrackingScope()] or TRACKING_SCOPE_ACCOUNT_LABEL
end

function Greed:GetTrackingProfileForScope(scope)
    self:InitializeTrackingProfiles()
    scope = NormalizeTrackingScope(scope)

    local profiles = self.savedVars.trackingProfiles
    if scope == TRACKING_SCOPE_CHARACTER then
        local characterKey = self:GetCharacterTrackingKey()
        profiles.characters[characterKey] = self:NormalizeTrackingProfile(profiles.characters[characterKey])
        return profiles.characters[characterKey]
    end

    profiles.account = self:NormalizeTrackingProfile(profiles.account)
    return profiles.account
end

function Greed:GetCurrentTrackingProfile()
    return self:GetTrackingProfileForScope(self:GetTrackingScope())
end

function Greed:SetTrackingScope(scope)
    scope = NormalizeTrackingScope(scope)
    self:InitializeTrackingProfiles()
    local characterKey = self:GetCharacterTrackingKey()
    local scopes = self.savedVars.trackedListScopeByCharacter
    local currentScope = NormalizeTrackingScope(scopes[characterKey])
    scopes[characterKey] = currentScope
    if currentScope == scope then return end

    scopes[characterKey] = scope
    self:InitializeSavedPages()
    self:BuildPageDropdown()
    self:RefreshGridFromSaved()
    self:BuildDropListPageDropdown()
    self:RefreshDropListWindow()
    self:RefreshDropOptionsState()
end

function Greed:SetTrackingScopeByLabel(label)
    self:SetTrackingScope(TRACKING_SCOPE_BY_LABEL[label] or TRACKING_SCOPE_CHARACTER)
end

function Greed:InitializeSavedPages()
    local profile = self:GetCurrentTrackingProfile()

    local hasPages = false
    local hasDefaultCarrier = false
    for _, pageData in pairs(profile.pages) do
        if type(pageData) == "table" then
            hasPages = true
            if type(pageData.sets) ~= "table" then
                pageData.sets = {}
            end
            if type(pageData.removedSets) ~= "table" then
                pageData.removedSets = {}
            end
            if pageData.usesDefaults == true then
                hasDefaultCarrier = true
            end
        end
    end

    if not hasPages then
        profile.pages[DEFAULT_PAGE_NAME] = {
            sets = {},
            removedSets = {},
            usesDefaults = false,
        }
        profile.pageOrder = { DEFAULT_PAGE_NAME }
    elseif not hasDefaultCarrier and type(profile.pages[LEGACY_DEFAULT_PAGE_NAME]) == "table" and profile.pages[LEGACY_DEFAULT_PAGE_NAME].usesDefaults == nil then
        -- Existing single-page Greed installs used Healer Farms as the implicit default-data page.
        profile.pages[LEGACY_DEFAULT_PAGE_NAME].usesDefaults = true
    end

    self:SyncPageOrder()

    if type(profile.currentPage) ~= "string" or not profile.pages[profile.currentPage] then
        profile.currentPage = self:GetFallbackPageName()
    end
end

function Greed:InitializeTextPromptSettings()
    if type(self.savedVars.textPrompts) ~= "table" then
        self.savedVars.textPrompts = {}
    end

    local prompts = self.savedVars.textPrompts

    local legacyFont = type(prompts.fontName) == "string" and prompts.fontName or DEFAULT_FONT_NAME
    if not FONT_OPTION_BY_LABEL[legacyFont] then
        legacyFont = DEFAULT_FONT_NAME
    end

    local function normalizePrompt(promptKey, legacyEnabled, defaultFont, defaultSize, defaultColorName, defaultColor, defaultBold)
        if type(prompts[promptKey]) ~= "table" then
            prompts[promptKey] = {}
        end

        local prompt = prompts[promptKey]
        if type(prompt.enabled) ~= "boolean" then
            prompt.enabled = legacyEnabled ~= false
        end
        if type(prompt.locked) ~= "boolean" then
            prompt.locked = prompts.locked == true
        end
        if type(prompt.fontName) ~= "string" or not FONT_OPTION_BY_LABEL[prompt.fontName] then
            prompt.fontName = defaultFont or legacyFont or DEFAULT_FONT_NAME
        end
        if type(prompt.fontSize) ~= "string" or not TEXT_PROMPT_SIZE_BY_KEY[prompt.fontSize] then
            prompt.fontSize = defaultSize or "Normal"
        end
        if type(prompt.colorName) ~= "string" or not TEXT_PROMPT_COLOR_BY_KEY[prompt.colorName] then
            prompt.colorName = defaultColorName or "White"
        end
        if type(prompt.color) ~= "table" or #prompt.color < 4 then
            local colorOption = TEXT_PROMPT_COLOR_BY_KEY[prompt.colorName]
            prompt.color = self:CopyTable((colorOption and colorOption.color) or defaultColor or { 1, 1, 1, 1 })
        end
        prompt.bold = false
        -- Bold, italic, underline, and the separate rainbow checkbox were removed from the Options UI.
        -- Rainbow is controlled only by choosing Rainbow in the Color dropdown.
        prompt.italic = false
        prompt.underline = false
        prompt.rainbow = prompt.colorName == "Rainbow"
        return prompt
    end

    local dropPrompt = normalizePrompt("drop", prompts.dropTextEnabled, legacyFont, "Normal", "Rainbow", { 1, 1, 1, 1 }, false)
    local spaulderPrompt = normalizePrompt("spaulder", prompts.spaulderTextEnabled, legacyFont, "Extra Large", "Gold", { 1.00, 0.78, 0.24, 1 }, true)

    if prompts.promptFormatDefaultMigrationV2 ~= true then
        if dropPrompt.colorName == "White" and dropPrompt.rainbow ~= true then
            dropPrompt.colorName = "Rainbow"
            dropPrompt.rainbow = true
            local colorOption = TEXT_PROMPT_COLOR_BY_KEY.Rainbow or TEXT_PROMPT_COLOR_BY_KEY.White
            dropPrompt.color = self:CopyTable(colorOption.color)
        end
        if spaulderPrompt.colorName == "Dark Red" then
            spaulderPrompt.colorName = "Gold"
            spaulderPrompt.rainbow = false
            local colorOption = TEXT_PROMPT_COLOR_BY_KEY.Gold or TEXT_PROMPT_COLOR_BY_KEY.White
            spaulderPrompt.color = self:CopyTable(colorOption.color)
        end
        prompts.promptFormatDefaultMigrationV2 = true
    end

    prompts.dropTextEnabled = dropPrompt.enabled ~= false
    prompts.spaulderTextEnabled = spaulderPrompt.enabled ~= false
    prompts.fontName = legacyFont
    prompts.locked = (dropPrompt.locked == true and spaulderPrompt.locked == true)
end

function Greed:InitializeAntiquityLeadSettings()
    if type(self.savedVars.antiquityLeads) ~= "table" then
        self.savedVars.antiquityLeads = {}
    end

    local leads = self.savedVars.antiquityLeads
    if type(leads.watched) ~= "table" then
        leads.watched = {}
    end
    if type(leads.found) ~= "table" then
        leads.found = {}
    end
    leads.showOtherPlayers = leads.showOtherPlayers == true
end

function Greed:StyleStaticControls()
    SetBackdropStyle(GreedWindowBackdrop, COLORS.window, COLORS.edge)
    SetBackdropStyle(GreedLauncherFrame, { 0, 0, 0, 0 }, COLORS.edge)

    CallControlMethod(self.controls.launcher, "SetMouseEnabled", true)
    CallControlMethod(GreedLauncherFrame, "SetMouseEnabled", true)
    CallControlMethod(GreedLauncherIcon, "SetMouseEnabled", true)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetMouseEnabled", true)
    CallControlMethod(GreedLauncherLabel, "SetMouseEnabled", true)
    CallControlMethod(self.controls.launcher, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(GreedLauncherFrame, "SetDrawLayer", DL_CONTROLS)
    CallControlMethod(GreedLauncherFrame, "SetDrawTier", DT_LOW)
    CallControlMethod(GreedLauncherFrame, "SetDrawLevel", 0)
    CallControlMethod(GreedLauncherIcon, "SetDrawLayer", DL_CONTROLS)
    CallControlMethod(GreedLauncherIcon, "SetDrawTier", DT_MEDIUM)
    CallControlMethod(GreedLauncherIcon, "SetDrawLevel", 10)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetDrawLayer", DL_TEXT)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetDrawTier", DT_HIGH)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetDrawLevel", 40)
    CallControlMethod(GreedLauncherLabel, "SetDrawLayer", DL_TEXT)
    CallControlMethod(GreedLauncherLabel, "SetDrawTier", DT_HIGH)
    CallControlMethod(GreedLauncherLabel, "SetDrawLevel", 50)

    if GreedWindowTitleBarTitle then
        GreedWindowTitleBarTitle:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    end
    if GreedWindowTitleBarByline then
        GreedWindowTitleBarByline:SetColor(COLORS.mutedText[1], COLORS.mutedText[2], COLORS.mutedText[3], COLORS.mutedText[4])
    end
    self:PositionTitleByline()

    if GreedLauncherLabel then
        GreedLauncherLabel:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
        GreedLauncherLabel:SetText("GREED")
    end

    local launcherGlyph = _G["GreedLauncherGlyph"]
    if launcherGlyph then
        launcherGlyph:SetHidden(true)
        launcherGlyph:SetMouseEnabled(false)
    end

    CallControlMethod(GreedLauncherIcon, "SetHidden", false)
    CallControlMethod(GreedLauncherIcon, "SetMouseEnabled", true)
    CallControlMethod(GreedLauncherIcon, "SetTexture", GreedData.placeholderIcons.helmet)
    CallControlMethod(GreedLauncherIcon, "SetColor", 1, 0.96, 0.86, 1)

    CallControlMethod(GreedLauncherWeaponOverlay, "SetHidden", false)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetMouseEnabled", true)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetTexture", GreedData.placeholderIcons.weaponOverlay)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetColor", 1, 0.04, 0.03, 1)
    CallControlMethod(GreedLauncherWeaponOverlay, "SetDimensions", 30, 30)
    CallControlMethod(GreedLauncherWeaponOverlay, "ClearAnchors")
    CallControlMethod(GreedLauncherWeaponOverlay, "SetAnchor", BOTTOMRIGHT, GreedLauncherFrame, BOTTOMRIGHT, -8, -14)

    self:StyleCloseButton()
    SetButtonText(self.controls.newPage, T("+ Add Set"))
    self:CreatePageActionControls()
    self:LiftMainTopControls()
end

function Greed:SetMainTopControlDrawOrder(control, level)
    if not control then return end

    CallControlMethod(control, "SetDrawLayer", DL_TEXT)
    CallControlMethod(control, "SetDrawTier", DT_HIGH)
    CallControlMethod(control, "SetDrawLevel", level or 500)
    CallControlMethod(control, "SetMouseEnabled", true)
end

function Greed:StyleTransparentTopButton(button)
    if not button then return end

    ClearButtonTextures(button)
    CallControlMethod(button, "SetNormalFontColor", COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    CallControlMethod(button, "SetMouseOverFontColor", 1, 0.95, 0.72, 1)
    CallControlMethod(button, "SetPressedFontColor", COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1)
end

function Greed:LiftMainTopControls()
    if not self.controls then return end

    self:StyleTransparentTopButton(self.controls.newPage)
    self:StyleTransparentTopButton(self.controls.pageActions)
    self:StyleTransparentTopButton(self.controls.close)

    self:SetMainTopControlDrawOrder(self.controls.newPage, 520)
    self:SetMainTopControlDrawOrder(self.controls.pageActions, 520)
    self:SetMainTopControlDrawOrder(self.controls.pageDropdown, 520)
    self:SetMainTopControlDrawOrder(self.controls.close, 540)
    self:SetMainTopControlDrawOrder(GreedWindowTabs, 510)

    for _, button in pairs(self.controls.tabs or {}) do
        self:StyleTransparentTopButton(button)
        self:SetMainTopControlDrawOrder(button, 530)
    end
end

function Greed:GetControlDrawDebug(control)
    if not control then return "missing" end

    local function read(methodName)
        local method = control[methodName]
        if type(method) ~= "function" then return "n/a" end
        local ok, value = pcall(method, control)
        if ok then return tostring(value) end
        return "err"
    end

    return "layer=" .. read("GetDrawLayer") .. ", tier=" .. read("GetDrawTier") .. ", level=" .. read("GetDrawLevel")
end

function Greed:PrintHitDebug()
    local scroll = self.rowsScroll or {}
    local rows = self.controls and self.controls.rows
    local content = self.controls and self.controls.rowsContent
    local visibleRows = {}
    local hiddenMouseEnabled = 0

    for index, row in ipairs(self.favoriteRows or {}) do
        if row and row.IsHidden and not row:IsHidden() then
            table.insert(visibleRows, tostring(index))
        elseif row and row.IsMouseEnabled and row:IsMouseEnabled() then
            hiddenMouseEnabled = hiddenMouseEnabled + 1
        end
    end

    SafeAnnounce("Greed hit debug: offset=" .. tostring(scroll.offset or 0) .. ", viewport=" .. tostring(scroll.viewportHeight or "nil"))
    SafeAnnounce("Greed hit debug: rows height=" .. tostring(rows and GetControlDimension(rows, "GetHeight", 0) or "nil") .. ", content top=" .. tostring(content and content.GetTop and content:GetTop() or "nil") .. ", content bottom=" .. tostring(content and content.GetBottom and content:GetBottom() or "nil"))
    SafeAnnounce("Greed hit debug: + Add Set mouse=" .. tostring(self.controls and self.controls.newPage and self.controls.newPage:IsMouseEnabled() or false) .. ", + Add Set " .. self:GetControlDrawDebug(self.controls and self.controls.newPage))
    SafeAnnounce("Greed hit debug: rowsContent mouse=" .. tostring(content and content.IsMouseEnabled and content:IsMouseEnabled() or false) .. ", rowsContent " .. self:GetControlDrawDebug(content))
    SafeAnnounce("Greed hit debug: visible rows=" .. (#visibleRows > 0 and table.concat(visibleRows, ", ") or "none") .. ", hidden mouse-enabled rows=" .. tostring(hiddenMouseEnabled))
    if self.textPromptControls and self.textPromptControls.window then
        SafeAnnounce("Greed hit debug: drop text prompt visible=" .. tostring(not self.textPromptControls.window:IsHidden()) .. ", mouse=" .. tostring(self.textPromptControls.window:IsMouseEnabled()) .. ", " .. self:GetControlDrawDebug(self.textPromptControls.window))
    end
    if self.spaulderPromptControls and self.spaulderPromptControls.window then
        SafeAnnounce("Greed hit debug: spaulder prompt visible=" .. tostring(not self.spaulderPromptControls.window:IsHidden()) .. ", mouse=" .. tostring(self.spaulderPromptControls.window:IsMouseEnabled()) .. ", " .. self:GetControlDrawDebug(self.spaulderPromptControls.window))
    end
    local activePopups = {}
    local popupSets = {
        "dropOptionsControls", "dropTraitControls", "dropListClearControls", "sourcesToFarmControls",
        "setsOverviewControls", "addControls", "editControls", "removeControls", "movePageControls",
        "deletePageControls", "pageNameControls", "genericConfirmControls", "antiquityControls",
    }
    for _, key in ipairs(popupSets) do
        local controls = self[key]
        if controls and controls.window and controls.window.IsHidden and not controls.window:IsHidden() then
            table.insert(activePopups, key)
        end
    end
    SafeAnnounce("Greed hit debug: active popups=" .. (#activePopups > 0 and table.concat(activePopups, ", ") or "none"))
end

function Greed:PrintGridSlotHitDebug(box, row, setData, column)
    if not self.hitDebug then return end

    SafeAnnounce("Greed grid hit debug: slot=" .. tostring(setData and setData.name or "unknown") .. " " .. tostring(column and column.label or column and column.key or "unknown"))
    SafeAnnounce("Greed grid hit debug: slot mouse=" .. tostring(box and box.IsMouseEnabled and box:IsMouseEnabled() or false) .. ", slot " .. self:GetControlDrawDebug(box))
    SafeAnnounce("Greed grid hit debug: row mouse=" .. tostring(row and row.IsMouseEnabled and row:IsMouseEnabled() or false) .. ", row " .. self:GetControlDrawDebug(row))
    local content = self.controls and self.controls.rowsContent
    SafeAnnounce("Greed grid hit debug: rowsContent mouse=" .. tostring(content and content.IsMouseEnabled and content:IsMouseEnabled() or false) .. ", rowsContent " .. self:GetControlDrawDebug(content))
end

function Greed:StyleCloseButton()
    local closeButton = self.controls and self.controls.close or GreedWindowTitleBarClose
    if not closeButton then return end

    -- Keep the close control inside the Greed window and make it text-only.
    -- The XML/default button art was causing decorative lines above/below the X.
    closeButton:ClearAnchors()
    closeButton:SetDimensions(18, 18)
    closeButton:SetAnchor(TOPRIGHT, self.controls.window or GreedWindow, TOPRIGHT, -5, 5)
    closeButton:SetText("X")
    closeButton:SetFont("ZoFontGameBold")
    closeButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(closeButton, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    closeButton:SetNormalFontColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    closeButton:SetMouseOverFontColor(1, 0.95, 0.72, 1)
    closeButton:SetPressedFontColor(COLORS.gold[1], COLORS.gold[2], COLORS.gold[3], 1)
    ClearButtonTextures(closeButton)
    CallControlMethod(closeButton, "SetDrawLayer", DL_TEXT)
    CallControlMethod(closeButton, "SetDrawTier", DT_HIGH)
    CallControlMethod(closeButton, "SetDrawLevel", 200)
end

function Greed:CreatePageActionControls()
    if self.controls.pageActions then return end

    self.controls.pageDropdown:SetDimensions(160, 30)

    local pageActions = WINDOW_MANAGER:CreateControlFromVirtual("GreedWindowPageActions", self.controls.window, "ZO_DefaultButton")
    pageActions:SetDimensions(58, 30)
    pageActions:SetAnchor(RIGHT, self.controls.pageDropdown, LEFT, -4, 0)
    SetButtonText(pageActions, T("Pages"))
    pageActions:SetHandler("OnClicked", function(control)
        self:ShowPageActionsMenu(control)
    end)

    self.controls.pageActions = pageActions
end

function Greed:WireMovement()
    if self:RestoreWindowPosition(self.controls.window, "mainWindow") ~= true then
        self:ApplyDefaultWindowPositionIfMissing(self.controls.window, "mainWindow")
    end
    self:MakeMovable(self.controls.window, self.controls.titleBar, nil, nil, function(movedWindow)
        self:SaveWindowPosition(movedWindow or self.controls.window, "mainWindow")
    end)
    self:MakeMovable(self.controls.launcher, {
        self.controls.launcher,
        GreedLauncherFrame,
        GreedLauncherIcon,
        GreedLauncherWeaponOverlay,
        GreedLauncherLabel,
    }, function()
        self:ToggleWindow()
    end, function()
        SafeAnnounce(T("Greed options coming later."))
    end, function()
        self:SaveLauncherPosition()
    end, function()
        if self:IsLauncherLocked() then return false end
        return true
    end)
end

function Greed:MakeMovable(control, handle, clickCallback, rightClickCallback, moveStopCallback, canMoveCallback)
    local startLeft, startTop, isMoving

    if not control or not handle then
        self:Debug("Movable setup skipped because a control or handle is missing.")
        return
    end

    CallControlMethod(control, "SetMouseEnabled", true)
    CallControlMethod(control, "SetClampedToScreen", true)
    if moveStopCallback then
        control:SetHandler("OnMoveStop", function(movedControl)
            self:RunCallback(function()
                moveStopCallback(movedControl or control)
            end, "Move-stop")
        end)
    end

    local function finishMovement(savePosition)
        local wasMoving = isMoving == true
        if wasMoving then
            self:StopMovingControl(control)
            isMoving = false

            if savePosition and moveStopCallback then
                self:RunCallback(function()
                    moveStopCallback(control)
                end, "Move-stop")
            end
        else
            CallControlMethod(control, "SetMovable", false)
        end

        return wasMoving
    end

    local function onMouseDown(_, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

        startLeft = control:GetLeft() or 0
        startTop = control:GetTop() or 0
        isMoving = false

        if canMoveCallback and canMoveCallback() == false then
            return
        end

        isMoving = self:StartMovingControl(control) == true
    end

    local function onMouseUp(_, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            finishMovement(true)
            if rightClickCallback then
                self:RunCallback(rightClickCallback, "Right-click")
            end
            return
        end

        if button ~= MOUSE_BUTTON_INDEX_LEFT then return end

        local movedDuringClick = finishMovement(true)

        if clickCallback and startLeft and startTop then
            local movedX = math.abs((control:GetLeft() or startLeft) - startLeft)
            local movedY = math.abs((control:GetTop() or startTop) - startTop)
            if movedX < 3 and movedY < 3 then
                self:RunCallback(clickCallback, "Left-click")
            end
        end
    end

    local handles = type(handle) == "table" and handle or { handle }
    for _, movementHandle in ipairs(handles) do
        if movementHandle then
            CallControlMethod(movementHandle, "SetMouseEnabled", true)
            movementHandle:SetHandler("OnMouseDown", onMouseDown)
            movementHandle:SetHandler("OnMouseUp", onMouseUp)
        end
    end
end

function Greed:RestoreLauncherPosition()
    local saved = self.savedVars and self.savedVars.launcher
    if not saved or type(saved.x) ~= "number" or type(saved.y) ~= "number" then return end

    self.controls.launcher:ClearAnchors()
    self.controls.launcher:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saved.x, saved.y)
end

function Greed:SaveLauncherPosition()
    if not self.savedVars or not self.savedVars.launcher then return end

    local left = self.controls.launcher:GetLeft()
    local top = self.controls.launcher:GetTop()
    if left and top then
        self.savedVars.launcher.x = left
        self.savedVars.launcher.y = top
    end
end

function Greed:IsLauncherLocked()
    return self.savedVars and self.savedVars.launcher and self.savedVars.launcher.locked == true
end

function Greed:SetLauncherLocked(locked)
    self.savedVars.launcher = self.savedVars.launcher or {}
    self.savedVars.launcher.locked = locked == true
end

function Greed:RestoreWindowPosition(control, positionKey)
    local saved = self.savedVars and self.savedVars.windowPositions and self.savedVars.windowPositions[positionKey]
    if not control or not saved or type(saved.x) ~= "number" or type(saved.y) ~= "number" then return false end

    local x = saved.x
    local y = saved.y
    if positionKey == "dropTextPrompt" or positionKey == "spaulderPrompt" then
        local screenWidth = GetControlDimension(GuiRoot, "GetWidth", 1920)
        local screenHeight = GetControlDimension(GuiRoot, "GetHeight", 1080)
        local width = GetControlDimension(control, "GetWidth", 400)
        local height = GetControlDimension(control, "GetHeight", 80)
        x = math.max(0, math.min(x, math.max(0, screenWidth - width)))
        y = math.max(0, math.min(y, math.max(0, screenHeight - height)))
        saved.x = x
        saved.y = y
    end

    CallControlMethod(control, "SetClampedToScreen", true)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    return true
end

function Greed:SaveWindowPosition(control, positionKey)
    if not control or not positionKey then return end

    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions[positionKey] = self.savedVars.windowPositions[positionKey] or {}

    local left = control:GetLeft()
    local top = control:GetTop()
    if left and top then
        self.savedVars.windowPositions[positionKey].x = left
        self.savedVars.windowPositions[positionKey].y = top
    end
end

function Greed:GetDefaultWindowPosition(positionKey, windowWidth, windowHeight)
    local screenWidth = GetControlDimension(GuiRoot, "GetWidth", 1920)
    local screenHeight = GetControlDimension(GuiRoot, "GetHeight", 1080)
    local width = tonumber(windowWidth) or 400
    local height = tonumber(windowHeight) or 300
    local x, y

    if positionKey == "mainWindow" then
        x = math.floor(screenWidth * 0.08)
        y = math.floor(screenHeight * 0.12)
    elseif positionKey == "dropOptions" then
        x = math.floor(screenWidth - width - (screenWidth * 0.04))
        y = math.floor(screenHeight * 0.12)
    elseif positionKey == "sourcesToFarm" then
        x = math.floor(screenWidth * 0.08)
        y = math.floor(screenHeight * 0.52)
    elseif positionKey == "dropList" then
        x = math.floor(screenWidth - width - (screenWidth * 0.04))
        y = math.floor(screenHeight - height - (screenHeight * 0.08))
    else
        return nil, nil
    end

    x = math.max(0, math.min(x, math.max(0, screenWidth - width)))
    y = math.max(0, math.min(y, math.max(0, screenHeight - height)))
    return x, y
end

function Greed:ApplyDefaultWindowPosition(control, positionKey)
    if not control or not positionKey then return false end

    local width = GetControlDimension(control, "GetWidth", 400)
    local height = GetControlDimension(control, "GetHeight", 300)
    local x, y = self:GetDefaultWindowPosition(positionKey, width, height)
    if type(x) ~= "number" or type(y) ~= "number" then return false end

    CallControlMethod(control, "SetClampedToScreen", true)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    return true
end

function Greed:ApplyDefaultWindowPositionIfMissing(control, positionKey)
    local saved = self.savedVars and self.savedVars.windowPositions and self.savedVars.windowPositions[positionKey]
    if saved and type(saved.x) == "number" and type(saved.y) == "number" then
        return false
    end

    return self:ApplyDefaultWindowPosition(control, positionKey)
end

function Greed:GetMainScrollbarReserveWidth()
    return MAIN_SCROLLBAR_WIDTH + MAIN_SCROLLBAR_GAP + MAIN_SCROLLBAR_RIGHT_PADDING
end

function Greed:GetMainRowsContentWidth(rowsWidth)
    return math.max(1, (tonumber(rowsWidth) or self:GetDynamicRowsWidth()) - MAIN_SCROLLBAR_WIDTH - MAIN_SCROLLBAR_RIGHT_PADDING)
end

function Greed:GetMainRowsContentHeight(rowCount)
    local rows = rowCount
    if type(rows) ~= "number" then
        rows = #(self.displayFavorites or self.favoriteRows or GreedData.favorites or {})
    end

    if rows <= 0 then
        return MAX_ROWS_VIEWPORT_HEIGHT
    end

    return math.max(ROW_HEIGHT, (rows * (ROW_HEIGHT + ROW_GAP)) - ROW_GAP)
end

function Greed:GetMainRowsMaxViewportHeight()
    return math.max(MAX_ROWS_VIEWPORT_HEIGHT, self:GetMainRowsContentHeight())
end

function Greed:GetMainWindowSizeBounds(minRowsWidth)
    local rowsWidth = minRowsWidth or self:GetDynamicRowsWidth()
    local minWidth = math.max(MAIN_WINDOW_MIN_WIDTH, (rowsWidth or 944) + MAIN_ROWS_LEFT_INSET + MAIN_ROWS_RIGHT_INSET)
    local minHeight = MAIN_WINDOW_MIN_HEIGHT
    local screenHeight = GetControlDimension(GuiRoot, "GetHeight", MAIN_WINDOW_MAX_HEIGHT + 20)
    local maxWidth = minWidth
    local maxRowsHeight = self:GetMainRowsMaxViewportHeight()
    local contentMaxHeight = MAIN_WINDOW_ROWS_TOP + maxRowsHeight + MAIN_WINDOW_FOOTER_HEIGHT + MAIN_WINDOW_FOOTER_BOTTOM + MAIN_WINDOW_ROWS_FOOTER_GAP
    local maxHeight = math.max(minHeight, math.min(contentMaxHeight, MAIN_WINDOW_MAX_HEIGHT, math.max(minHeight, screenHeight - 20)))

    return minWidth, maxWidth, minHeight, maxHeight
end

function Greed:GetMainRowsViewportHeight(windowHeight)
    local height = tonumber(windowHeight) or MAIN_WINDOW_DEFAULT_HEIGHT
    local available = height - MAIN_WINDOW_ROWS_TOP - MAIN_WINDOW_FOOTER_HEIGHT - MAIN_WINDOW_FOOTER_BOTTOM - MAIN_WINDOW_ROWS_FOOTER_GAP
    return math.max(MAX_ROWS_VIEWPORT_HEIGHT, math.min(self:GetMainRowsMaxViewportHeight(), math.floor(available)))
end

function Greed:ApplyMainWindowSize(width, height)
    if not self.controls or not self.controls.window then return end

    local minWidth, maxWidth, minHeight, maxHeight = self:GetMainWindowSizeBounds()
    local nextWidth = math.max(minWidth, math.min(maxWidth, tonumber(width) or MAIN_WINDOW_DEFAULT_WIDTH))
    local nextHeight = math.max(minHeight, math.min(maxHeight, tonumber(height) or MAIN_WINDOW_DEFAULT_HEIGHT))

    self.controls.window:SetDimensions(nextWidth, nextHeight)
    self:UpdateMainWindowLayout()
end

function Greed:RestoreMainWindowSize()
    local saved = self.savedVars and self.savedVars.windowPositions and self.savedVars.windowPositions.mainWindow
    if not saved or type(saved.width) ~= "number" or type(saved.height) ~= "number" then return end

    self:ApplyMainWindowSize(saved.width, saved.height)
end

function Greed:SaveMainWindowSize()
    if not self.controls or not self.controls.window then return end

    self.savedVars.windowPositions = self.savedVars.windowPositions or {}
    self.savedVars.windowPositions.mainWindow = self.savedVars.windowPositions.mainWindow or {}
    self:SaveWindowPosition(self.controls.window, "mainWindow")

    local width = GetControlDimension(self.controls.window, "GetWidth", MAIN_WINDOW_DEFAULT_WIDTH)
    local height = GetControlDimension(self.controls.window, "GetHeight", MAIN_WINDOW_DEFAULT_HEIGHT)
    local minWidth, maxWidth, minHeight, maxHeight = self:GetMainWindowSizeBounds()
    self.savedVars.windowPositions.mainWindow.width = math.max(minWidth, math.min(maxWidth, width))
    self.savedVars.windowPositions.mainWindow.height = math.max(minHeight, math.min(maxHeight, height))
end

function Greed:LayoutMainWindowResizeControls()
    if not self.controls or not self.controls.window then return end

    local leftGrip = self.controls.mainResizeLeftGrip
    if leftGrip then
        leftGrip:ClearAnchors()
        leftGrip:SetAnchor(BOTTOMLEFT, self.controls.window, BOTTOMLEFT, 4, -4)
    end

    local rightGrip = self.controls.mainResizeRightGrip
    if rightGrip then
        rightGrip:ClearAnchors()
        rightGrip:SetAnchor(BOTTOMRIGHT, self.controls.window, BOTTOMRIGHT, -4, -4)
    end
end

function Greed:CreateMainWindowResizeControls()
    if not self.controls or not self.controls.window or self.controls.mainResizeLeftGrip then return end

    local window = self.controls.window
    local leftGrip = WINDOW_MANAGER:CreateControl("GreedWindowResizeLeftGrip", window, CT_LABEL)
    leftGrip:SetDimensions(32, 28)
    leftGrip:SetText("")
    AddResizeGripIcon(leftGrip, "GreedWindowResizeLeftGrip", "left")
    CallControlMethod(leftGrip, "SetDrawLayer", DL_TEXT)
    CallControlMethod(leftGrip, "SetDrawTier", DT_HIGH)
    CallControlMethod(leftGrip, "SetDrawLevel", 240)
    leftGrip:SetMouseEnabled(true)
    leftGrip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartMainWindowResize("left")
        end
    end)
    leftGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopMainWindowResize()
        end
    end)

    local rightGrip = WINDOW_MANAGER:CreateControl("GreedWindowResizeRightGrip", window, CT_LABEL)
    rightGrip:SetDimensions(32, 28)
    rightGrip:SetText("")
    AddResizeGripIcon(rightGrip, "GreedWindowResizeRightGrip", "right")
    CallControlMethod(rightGrip, "SetDrawLayer", DL_TEXT)
    CallControlMethod(rightGrip, "SetDrawTier", DT_HIGH)
    CallControlMethod(rightGrip, "SetDrawLevel", 240)
    rightGrip:SetMouseEnabled(true)
    rightGrip:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartMainWindowResize("right")
        end
    end)
    rightGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopMainWindowResize()
        end
    end)

    window:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT and self.mainWindowResize then
            self:StopMainWindowResize()
        end
    end)

    self.controls.mainResizeLeftGrip = leftGrip
    self.controls.mainResizeRightGrip = rightGrip
    self:LayoutMainWindowResizeControls()
end

function Greed:StartMainWindowResize(side)
    if not self.controls or not self.controls.window or not GetUIMousePosition then return end

    local window = self.controls.window
    local mouseX, mouseY = GetUIMousePosition()
    self.mainWindowResize = {
        side = side or "right",
        startMouseX = mouseX or 0,
        startMouseY = mouseY or 0,
        startWidth = GetControlDimension(window, "GetWidth", MAIN_WINDOW_DEFAULT_WIDTH),
        startHeight = GetControlDimension(window, "GetHeight", MAIN_WINDOW_DEFAULT_HEIGHT),
        startLeft = window:GetLeft() or 0,
        startTop = window:GetTop() or 0,
    }

    window:SetHandler("OnUpdate", function()
        self:UpdateMainWindowResize()
    end)
end

function Greed:UpdateMainWindowResize()
    local resize = self.mainWindowResize
    if not self.controls or not self.controls.window or not resize or not GetUIMousePosition then return end

    local mouseX, mouseY = GetUIMousePosition()
    local deltaX = (mouseX or resize.startMouseX) - resize.startMouseX
    local deltaY = (mouseY or resize.startMouseY) - resize.startMouseY
    local minWidth, maxWidth, minHeight, maxHeight = self:GetMainWindowSizeBounds()
    local nextWidth
    local nextLeft = resize.startLeft

    if resize.side == "left" then
        nextWidth = math.max(minWidth, math.min(maxWidth, resize.startWidth - deltaX))
        nextLeft = resize.startLeft + (resize.startWidth - nextWidth)
    else
        nextWidth = math.max(minWidth, math.min(maxWidth, resize.startWidth + deltaX))
    end

    local nextHeight = math.max(minHeight, math.min(maxHeight, resize.startHeight + deltaY))

    self.controls.window:ClearAnchors()
    self.controls.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, nextLeft, resize.startTop)
    self.controls.window:SetDimensions(nextWidth, nextHeight)
    self:UpdateMainWindowLayout()
end

function Greed:StopMainWindowResize()
    if self.controls and self.controls.window then
        self.controls.window:SetHandler("OnUpdate", nil)
    end

    self.mainWindowResize = nil
    self:SaveMainWindowSize()
    self:UpdateMainWindowLayout()
end

function Greed:MakePopupWindowMovable(window, titleBar, titleLabel, positionKey)
    if self:RestoreWindowPosition(window, positionKey) ~= true then
        self:ApplyDefaultWindowPositionIfMissing(window, positionKey)
    end
    self:MakeMovable(window, { titleBar, titleLabel }, nil, nil, function(movedWindow)
        self:SaveWindowPosition(movedWindow or window, positionKey)
    end)
end

function Greed:WireActions()
    self.controls.close:SetHandler("OnClicked", function()
        self:HideWindow()
    end)

    self.controls.newPage:SetHandler("OnClicked", function()
        self:ToggleAddSetWindow()
    end)
end

function Greed:BuildPageDropdown()
    if not ZO_ComboBox_ObjectFromContainer then return end

    local comboBox = ZO_ComboBox_ObjectFromContainer(self.controls.pageDropdown)
    comboBox:SetSortsItems(false)
    if type(comboBox.ClearItems) == "function" then
        comboBox:ClearItems()
    end

    local currentPage = self:GetCurrentPageName()
    for _, pageName in ipairs(self:GetPageNames()) do
        local selectedPageName = pageName
        comboBox:AddItem(comboBox:CreateItemEntry(selectedPageName, function()
            self:SelectPage(selectedPageName)
        end))
    end
    comboBox:SetSelectedItem(currentPage)
    self:LiftMainTopControls()
end

function Greed:SelectPage(pageName)
    local profile = self:GetCurrentTrackingProfile()
    if not pageName or not profile.pages[pageName] then return end

    profile.currentPage = pageName
    self:BuildPageDropdown()
    self:RefreshGridFromSaved()
end

function Greed:ShowPageActionsMenu(control)
    ClearMenu()

    self:AddContextMenuItem(T("New Page"), function()
        self:ShowPageNameDialog("new")
    end)
    self:AddContextMenuItem(T("Rename Page"), function()
        self:ShowPageNameDialog("rename")
    end)
    self:AddContextMenuItem(T("Move Page Up"), function()
        self:MoveCurrentPageInOrder(-1)
    end)
    self:AddContextMenuItem(T("Move Page Down"), function()
        self:MoveCurrentPageInOrder(1)
    end)
    self:AddContextMenuItem(T("Move Page to Top"), function()
        self:MoveCurrentPageToTop()
    end)
    self:AddContextMenuItem(T("Delete Page"), function()
        self:ShowDeletePageDialog()
    end)

    ShowMenu(control)
end

function Greed:SelectTab(tabKey)
    self.activeTab = tabKey

    for key, button in pairs(self.controls.tabs) do
        local color = key == tabKey and COLORS.activeTab or COLORS.inactiveTab
        button:SetNormalFontColor(color[1], color[2], color[3], color[4])
    end

    if tabKey == "favorites" or tabKey == "grid" then
        self.activeTab = "grid"
        return
    end

    if tabKey == "statistics" then
        self:ToggleDropListWindow()
        return
    end

    if tabKey == "options" then
        self:ToggleDropOptionsWindow()
        return
    end

    if tabKey == "sets" then
        self:ToggleSourcesToFarmWindow()
        return
    end
end

function Greed:GetTabLabel(tabKey)
    local labels = {
        favorites = T("Favorites"),
        sets = T("List"),
        statistics = T("Log"),
        options = T("Options"),
    }

    return labels[tabKey] or tabKey
end

function Greed:CopyTable(source)
    if type(source) ~= "table" then return {} end

    local copy = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            copy[key] = self:CopyTable(value)
        else
            copy[key] = value
        end
    end

    return copy
end

function Greed:ClearResolvedItemFields(piece)
    if not piece then return end

    piece.itemLink = nil
    piece.itemId = nil
    piece.itemName = nil
    piece.icon = nil
    piece.iconResolutionFailed = nil
    piece.collectionSlot = nil
    piece.collectionPieceId = nil
end

function Greed:GetSetRowKey(baseName, isPerfectedRow)
    return string.format("%s|%s", baseName or "Unknown Set", isPerfectedRow and "perfected" or "normal")
end

function Greed:GetPerfectedDisplayName(baseName, perfectedSetId)
    local perfectedName = perfectedSetId and self:GetLibSetsSetName(perfectedSetId) or nil
    if type(perfectedName) == "string" and perfectedName ~= "" then
        return perfectedName
    end

    return T("Perfected %s", baseName or T("Unknown Set"))
end

function Greed:ResolveTrackedRowIdentity(setData)
    local setId = tonumber(setData and setData.setId)
    local normalSetId = tonumber(setData and setData.normalSetId)
    local perfectedSetId = tonumber(setData and setData.perfectedSetId)
    local identitySetId = setId
    local isPerfected = false
    local perfectedInfo = setId and libSets.GetPerfectedSetInfo(setId) or nil
    local setIdIsPerfected = perfectedInfo and (perfectedInfo.isPerfectedSet == true or perfectedInfo.isPerfectedSet == 1)

    if setIdIsPerfected then
        isPerfected = true
        normalSetId = perfectedInfo.nonPerfectedSetId or normalSetId
        perfectedSetId = setId
    elseif setData and (setData.perfected == true or setData.isPerfectedRow == true) then
        isPerfected = true
        if perfectedSetId then
            perfectedInfo = libSets.GetPerfectedSetInfo(perfectedSetId)
            normalSetId = (perfectedInfo and perfectedInfo.nonPerfectedSetId) or normalSetId
            perfectedSetId = (perfectedInfo and perfectedInfo.perfectedSetId) or perfectedSetId
            identitySetId = perfectedSetId
        elseif perfectedInfo then
            normalSetId = perfectedInfo.nonPerfectedSetId or normalSetId or setId
            perfectedSetId = perfectedInfo and perfectedInfo.perfectedSetId or nil
            identitySetId = perfectedSetId or setId
        end
    elseif perfectedInfo then
        normalSetId = perfectedInfo.nonPerfectedSetId or normalSetId or setId
        perfectedSetId = perfectedSetId or perfectedInfo.perfectedSetId
    end

    normalSetId = normalSetId or setId
    return identitySetId, normalSetId, perfectedSetId, isPerfected
end

function Greed:GetTrackedRowSortInfo(setData, stableIndex)
    setData = setData or {}
    local setId, normalSetId, _, isPerfected = self:ResolveTrackedRowIdentity(setData)
    local familyName = normalSetId and self:GetLibSetsSetName(normalSetId) or nil
    familyName = familyName or setData.baseName or setData.lookupName or setData.name or ""

    return {
        familyKey = string.lower(familyName),
        versionOrder = isPerfected and 1 or 0,
        setId = tonumber(setId) or 0,
        stableIndex = stableIndex or 0,
    }
end

function Greed:SyncPageOrder()
    if not self.savedVars then return end
    local profile = self:GetCurrentTrackingProfile()

    if type(profile.pageOrder) ~= "table" then
        profile.pageOrder = {}
    end

    local seen = {}
    local cleanedOrder = {}

    for _, pageName in ipairs(profile.pageOrder) do
        if type(pageName) == "string" and profile.pages[pageName] and not seen[pageName] then
            table.insert(cleanedOrder, pageName)
            seen[pageName] = true
        end
    end

    local missingPages = {}
    for pageName, pageData in pairs(profile.pages or {}) do
        if type(pageName) == "string" and type(pageData) == "table" and not seen[pageName] then
            table.insert(missingPages, pageName)
            seen[pageName] = true
        end
    end

    table.sort(missingPages, function(a, b)
        return string.lower(a) < string.lower(b)
    end)

    for _, pageName in ipairs(missingPages) do
        table.insert(cleanedOrder, pageName)
    end

    profile.pageOrder = cleanedOrder
end

function Greed:GetPageOrderIndex(pageName)
    self:SyncPageOrder()
    local profile = self:GetCurrentTrackingProfile()

    for index, orderedPageName in ipairs(profile.pageOrder or {}) do
        if orderedPageName == pageName then
            return index
        end
    end

    return nil
end

function Greed:RemovePageFromOrder(pageName)
    if not self.savedVars then return end
    local profile = self:GetCurrentTrackingProfile()
    if type(profile.pageOrder) ~= "table" then return end

    for index = #profile.pageOrder, 1, -1 do
        if profile.pageOrder[index] == pageName then
            table.remove(profile.pageOrder, index)
        end
    end
end

function Greed:SetPageOrderName(oldPageName, newPageName)
    if not self.savedVars then return end
    local profile = self:GetCurrentTrackingProfile()
    if type(profile.pageOrder) ~= "table" then return end

    for index, pageName in ipairs(profile.pageOrder) do
        if pageName == oldPageName then
            profile.pageOrder[index] = newPageName
            return
        end
    end

    table.insert(profile.pageOrder, newPageName)
end

function Greed:MoveCurrentPageInOrder(direction)
    self:SyncPageOrder()
    local profile = self:GetCurrentTrackingProfile()

    local currentPage = self:GetCurrentPageName()
    local currentIndex = self:GetPageOrderIndex(currentPage)
    if not currentIndex then return end

    local targetIndex = currentIndex + direction
    if targetIndex < 1 then
        SafeAnnounce(T("Greed: This page is already at the top."))
        return
    end
    if targetIndex > #(profile.pageOrder or {}) then
        SafeAnnounce(T("Greed: This page is already at the bottom."))
        return
    end

    local pageOrder = profile.pageOrder
    pageOrder[currentIndex], pageOrder[targetIndex] = pageOrder[targetIndex], pageOrder[currentIndex]

    self:BuildPageDropdown()
    SafeAnnounce(T("Greed: Page order updated."))
end

function Greed:MoveCurrentPageToTop()
    self:SyncPageOrder()
    local profile = self:GetCurrentTrackingProfile()

    local currentPage = self:GetCurrentPageName()
    local currentIndex = self:GetPageOrderIndex(currentPage)
    if not currentIndex then return end

    if currentIndex == 1 then
        SafeAnnounce(T("Greed: This page is already at the top."))
        return
    end

    table.remove(profile.pageOrder, currentIndex)
    table.insert(profile.pageOrder, 1, currentPage)

    self:BuildPageDropdown()
    SafeAnnounce(T("Greed: Page moved to top."))
end

function Greed:GetSortedPageNames()
    local pageNames = {}

    self:SyncPageOrder()
    local profile = self:GetCurrentTrackingProfile()

    for _, pageName in ipairs(profile.pageOrder or {}) do
        if type(pageName) == "string" and type(profile.pages[pageName]) == "table" then
            table.insert(pageNames, pageName)
        end
    end

    return pageNames
end

function Greed:GetFallbackPageName()
    local pageNames = self:GetSortedPageNames()
    return pageNames[1] or DEFAULT_PAGE_NAME
end

function Greed:GetCurrentPageName()
    self:InitializeSavedPages()
    local profile = self:GetCurrentTrackingProfile()
    return profile.currentPage or self:GetFallbackPageName()
end

function Greed:GetCurrentPageData()
    local pageName = self:GetCurrentPageName()
    local profile = self:GetCurrentTrackingProfile()
    return profile.pages[pageName]
end

function Greed:CurrentPageUsesDefaults()
    local pageData = self:GetCurrentPageData()
    return pageData and pageData.usesDefaults == true
end

function Greed:GetPageNames()
    self:InitializeSavedPages()
    return self:GetSortedPageNames()
end

function Greed:GetSavedSets()
    self:InitializeSavedPages()
    return self:GetCurrentPageData().sets
end

function Greed:GetRemovedSets()
    self:InitializeSavedPages()
    return self:GetCurrentPageData().removedSets
end

function Greed:GetSavedSetOverride(rowKey)
    local savedSets = self:GetSavedSets()
    return rowKey and savedSets[rowKey] or nil
end

function Greed:IsRowRemoved(rowKey)
    local removedSets = self:GetRemovedSets()
    return rowKey and removedSets[rowKey] == true
end

function Greed:SetRowRemoved(rowKey, removed)
    if not rowKey then return end

    local removedSets = self:GetRemovedSets()
    removedSets[rowKey] = removed == true and true or nil
end

function Greed:IsDefaultRowKey(rowKey)
    if not rowKey then return false end

    for _, setData in ipairs(GreedData.favorites or {}) do
        if rowKey == self:GetSetRowKey(setData.name, false) or rowKey == self:GetSetRowKey(setData.name, true) then
            return true
        end
    end

    return false
end

function Greed:AddWeaponKeyToTracking(tracking, typeKey)
    if not tracking or not typeKey then return end

    if typeKey == "swordAndShield" then
        tracking.sword = true
        tracking.shield = true
        return
    end

    local mappedKey = ({
        iceStaff = "frostStaff",
        infernoStaff = "flameStaff",
        fireStaff = "flameStaff",
    })[typeKey] or typeKey

    if WEAPON_ITEM_BY_KEY[mappedKey] then
        tracking[mappedKey] = true
    end
end

function Greed:CreateEmptyWeaponTrackingTable()
    local weapons = {}

    for _, weapon in ipairs(WEAPON_ITEMS) do
        weapons[weapon.key] = false
    end

    return weapons
end

function Greed:NormalizeWeaponTrackingTable(weapons)
    local tracking = self:CreateEmptyWeaponTrackingTable()
    if type(weapons) ~= "table" then return tracking end

    for key, value in pairs(weapons) do
        if type(key) == "number" and type(value) == "table" then
            if value.enabled ~= false then
                self:AddWeaponKeyToTracking(tracking, value.type)
            end
        elseif type(key) == "string" then
            if value == true then
                self:AddWeaponKeyToTracking(tracking, key)
            elseif type(value) == "table" and value.enabled ~= false then
                self:AddWeaponKeyToTracking(tracking, value.type or key)
            end
        end
    end

    return tracking
end

function Greed:GetNormalizedWeaponKey(typeKey)
    local tracking = {}
    self:AddWeaponKeyToTracking(tracking, typeKey)

    for _, weapon in ipairs(WEAPON_ITEMS) do
        if tracking[weapon.key] then
            return weapon.key
        end
    end

    return WEAPON_ITEMS[1].key
end

function Greed:MigrateSavedWeaponTracking()
    local function migrateProfile(profile)
        if type(profile) ~= "table" or type(profile.pages) ~= "table" then return end

        for _, pageData in pairs(profile.pages) do
            if type(pageData) == "table" and type(pageData.sets) == "table" then
                for _, setOverride in pairs(pageData.sets) do
                    if type(setOverride) == "table" and type(setOverride.weapons) == "table" then
                        setOverride.weapons = self:NormalizeWeaponTrackingTable(setOverride.weapons)
                    end
                end
            end
        end
    end

    self:InitializeTrackingProfiles()
    local profiles = self.savedVars.trackingProfiles or {}
    migrateProfile(profiles.account)
    for _, profile in pairs(profiles.characters or {}) do
        migrateProfile(profile)
    end
    migrateProfile({ pages = self.savedVars.pages })
end

function Greed:CreatePieceForSlot(setData, slotKey, perfectedOnly)
    local sourcePiece = setData.pieces and setData.pieces[slotKey] or nil
    local piece = self:CopyTable(sourcePiece or {})

    if not sourcePiece then
        piece.collected = false
    end

    if slotKey == "ring" then
        piece.count = piece.count or 0
        piece.total = piece.total or 2
    end

    piece.perfected = perfectedOnly and true or nil
    self:ClearResolvedItemFields(piece)

    return piece
end

function Greed:CreateWeaponPiece(sourcePiece, typeKey, perfectedOnly)
    local piece = self:CopyTable(sourcePiece or {})

    if not sourcePiece then
        piece.collected = false
    end

    piece.type = self:GetNormalizedWeaponKey(typeKey or piece.type)
    piece.perfected = perfectedOnly and true or nil
    self:ClearResolvedItemFields(piece)

    return piece
end

function Greed:GetDefaultWeaponPiece(setData, perfectedOnly, typeKey)
    for _, piece in ipairs(setData.weapons or {}) do
        if (piece.perfected == true) == perfectedOnly then
            if self:GetNormalizedWeaponKey(piece.type) == typeKey then
                return piece
            end
        end
    end

    return nil
end

function Greed:GetTrackedWeaponCount(setData)
    local count = 0

    for _, weapon in ipairs(WEAPON_ITEMS) do
        if setData.weapons and setData.weapons[weapon.key] then
            count = count + 1
        end
    end

    return count
end

function Greed:ApplySavedTrackingOverride(row, sourceSetData)
    local override = self:GetSavedSetOverride(row.rowKey)
    if not override then return end

    if override.isMonsterSet == true then
        row.isMonsterSet = true
    end
    if override.armorWeights or override.armorWeight or override.weightPreference then
        row.armorWeights = self:NormalizeMonsterArmorWeights(override.armorWeights or override.armorWeight or override.weightPreference)
    end

    if type(override.pieces) == "table" then
        row.pieces = {}
        for _, slot in ipairs(GreedData.armorSlots) do
            if override.pieces[slot.key] == true then
                row.pieces[slot.key] = self:CreatePieceForSlot(sourceSetData, slot.key, row.isPerfectedRow)
            end
        end
    end

    if type(override.weapons) == "table" then
        row.weapons = {}
        local savedWeapons = self:NormalizeWeaponTrackingTable(override.weapons)
        for _, weapon in ipairs(WEAPON_ITEMS) do
            if savedWeapons[weapon.key] == true then
                local sourcePiece = self:GetDefaultWeaponPiece(sourceSetData, row.isPerfectedRow, weapon.key)
                row.weapons[weapon.key] = self:CreateWeaponPiece(sourcePiece, weapon.key, row.isPerfectedRow)
            end
        end
    end
end

function Greed:ApplyMonsterSetTrackingRules(setData)
    if not self:IsMonsterSetData(setData) then return end

    setData.armorWeights = self:NormalizeMonsterArmorWeights(setData.armorWeights or setData.armorWeight or setData.weightPreference)

    for _, slot in ipairs(GreedData.armorSlots or {}) do
        if not MONSTER_ARMOR_SLOT_KEYS[slot.key] then
            setData.pieces[slot.key] = nil
        end
    end

    setData.weapons = {}
end

function Greed:BuildDisplayFavorites()
    local rows = {}
    local defaultRowKeys = {}

    if self:CurrentPageUsesDefaults() then
        for _, setData in ipairs(GreedData.favorites or {}) do
            local normalRow = self:CreateDisplaySetRow(setData, false)
            defaultRowKeys[normalRow.rowKey] = true
            if not self:IsRowRemoved(normalRow.rowKey) and self:DisplaySetHasTrackedPieces(normalRow) then
                table.insert(rows, normalRow)
            end

            local perfectedRow = self:CreateDisplaySetRow(setData, true)
            defaultRowKeys[perfectedRow.rowKey] = true
            if not self:IsRowRemoved(perfectedRow.rowKey) and self:DisplaySetHasTrackedPieces(perfectedRow) then
                table.insert(rows, perfectedRow)
            end
        end
    end

    for rowKey, savedRow in pairs(self:GetSavedSets()) do
        if type(savedRow) == "table" and savedRow.userAdded == true and not defaultRowKeys[rowKey] and not self:IsRowRemoved(rowKey) then
            local displayRow = self:CreateDisplaySetRowFromSaved(rowKey, savedRow)
            if self:DisplaySetHasTrackedPieces(displayRow) then
                table.insert(rows, displayRow)
            end
        end
    end

    local sortInfoByRow = {}
    for index, row in ipairs(rows) do
        sortInfoByRow[row] = self:GetTrackedRowSortInfo(row, index)
    end

    table.sort(rows, function(a, b)
        local aSort = sortInfoByRow[a]
        local bSort = sortInfoByRow[b]
        if aSort.familyKey ~= bSort.familyKey then
            return aSort.familyKey < bSort.familyKey
        end

        if aSort.versionOrder ~= bSort.versionOrder then
            return aSort.versionOrder < bSort.versionOrder
        end

        if aSort.setId ~= bSort.setId then
            return aSort.setId < bSort.setId
        end

        return aSort.stableIndex < bSort.stableIndex
    end)

    return rows
end

function Greed:CreateDisplaySetRow(setData, perfectedOnly)
    local row = {
        name = setData.name,
        baseName = setData.name,
        lookupName = setData.lookupName or setData.name,
        source = setData.source,
        setId = setData.setId,
        normalSetId = setData.normalSetId or setData.setId,
        perfectedSetId = setData.perfectedSetId,
        pieces = {},
        weapons = {},
        isPerfectedRow = perfectedOnly == true,
        isMonsterSet = setData.isMonsterSet == true,
        armorWeights = self:NormalizeMonsterArmorWeights(setData.armorWeights or setData.armorWeight or setData.weightPreference),
    }
    row.rowKey = self:GetSetRowKey(row.baseName, row.isPerfectedRow)

    if perfectedOnly then
        row.name = self:GetPerfectedDisplayName(setData.name, setData.perfectedSetId)
        row.source = self:GetVeteranSourceText(setData.source)
    end

    for slotKey, piece in pairs(setData.pieces or {}) do
        if (piece.perfected == true) == perfectedOnly then
            row.pieces[slotKey] = self:CreatePieceForSlot(setData, slotKey, perfectedOnly)
        end
    end

    for _, piece in ipairs(setData.weapons or {}) do
        if (piece.perfected == true) == perfectedOnly then
            local weaponTracking = self:CreateEmptyWeaponTrackingTable()
            self:AddWeaponKeyToTracking(weaponTracking, piece.type)
            for _, weapon in ipairs(WEAPON_ITEMS) do
                if weaponTracking[weapon.key] == true then
                    row.weapons[weapon.key] = self:CreateWeaponPiece(piece, weapon.key, perfectedOnly)
                end
            end
        end
    end

    self:ApplySavedTrackingOverride(row, setData)
    self:ApplyMonsterSetTrackingRules(row)

    return row
end

function Greed:CreateDisplaySetRowFromSaved(rowKey, savedRow)
    local storedBaseName = savedRow.baseName or (rowKey and rowKey:match("^(.-)|")) or "Unknown Set"
    local selectedSetId, normalSetId, perfectedSetId, isPerfected = self:ResolveTrackedRowIdentity(savedRow)
    selectedSetId = isPerfected and (perfectedSetId or selectedSetId) or selectedSetId
    local baseName = (normalSetId and self:GetLibSetsSetName(normalSetId)) or storedBaseName
    local source = savedRow.source or "LibSets"
    local sourceSetData = {
        pieces = {},
        weapons = {},
    }

    local row = {
        name = isPerfected and self:GetPerfectedDisplayName(baseName, perfectedSetId or selectedSetId or savedRow.setId) or baseName,
        baseName = baseName,
        lookupName = savedRow.lookupName or baseName,
        source = isPerfected and self:GetVeteranSourceText(source) or source,
        setId = selectedSetId or savedRow.setId,
        normalSetId = normalSetId,
        perfectedSetId = perfectedSetId,
        pieces = {},
        weapons = {},
        isPerfectedRow = isPerfected,
        userAdded = true,
        rowKey = rowKey or self:GetSetRowKey(baseName, isPerfected),
        isMonsterSet = savedRow.isMonsterSet == true,
        armorWeights = self:NormalizeMonsterArmorWeights(savedRow.armorWeights or savedRow.armorWeight or savedRow.weightPreference),
    }

    for _, slot in ipairs(GreedData.armorSlots) do
        if savedRow.pieces and savedRow.pieces[slot.key] == true then
            row.pieces[slot.key] = self:CreatePieceForSlot(sourceSetData, slot.key, isPerfected)
        end
    end

    local savedWeapons = self:NormalizeWeaponTrackingTable(savedRow.weapons)
    for _, weapon in ipairs(WEAPON_ITEMS) do
        if savedWeapons[weapon.key] == true then
            row.weapons[weapon.key] = self:CreateWeaponPiece(nil, weapon.key, isPerfected)
        end
    end

    self:ApplyMonsterSetTrackingRules(row)

    return row
end

function Greed:DisplaySetHasTrackedPieces(setData)
    if not setData then return false end

    for _, _ in pairs(setData.pieces or {}) do
        return true
    end

    return self:GetTrackedWeaponCount(setData) > 0
end

function Greed:GetVeteranSourceText(source)
    if type(source) ~= "string" then return source or "" end

    local trialName = source:match("^Trial%s*%-%s*(.+)$")
    if trialName and not trialName:match("^Veteran%s+") then
        return T("Trial - Veteran %s", trialName)
    end

    return source
end

function Greed:GetDynamicRowsWidth()
    local armorColumnCount = 0
    local weaponColumnCount = 0

    for _, column in ipairs(self.visibleColumns or {}) do
        if column.kind == "weapon" then
            weaponColumnCount = weaponColumnCount + 1
        else
            armorColumnCount = armorColumnCount + 1
        end
    end

    local columnCount = armorColumnCount + math.max(weaponColumnCount, 1)
    local columnsWidth = 0

    if columnCount > 0 then
        columnsWidth = (columnCount * SLOT_SIZE) + ((columnCount - 1) * SLOT_GAP)
    end

    return math.max(MAIN_WINDOW_MIN_WIDTH - 32, SLOT_START_X + columnsWidth + self:GetMainScrollbarReserveWidth())
end

function Greed:BuildVisibleColumns()
    self.visibleColumns = {}

    for _, slot in ipairs(GreedData.armorSlots) do
        if self:IsArmorSlotTracked(slot.key) then
            table.insert(self.visibleColumns, {
                kind = "armor",
                key = slot.key,
                label = slot.label,
                shortLabel = slot.shortLabel,
                equipType = slot.equipType,
                fallbackIcon = slot.fallbackIcon,
                total = slot.total,
            })
        end
    end

    for _, weapon in ipairs(WEAPON_ITEMS) do
        if self:IsWeaponTracked(weapon.key) then
            table.insert(self.visibleColumns, {
                kind = "weapon",
                key = weapon.key,
                label = weapon.label,
                shortLabel = weapon.shortLabel,
                weaponType = weapon.weaponType,
                fallbackIcon = weapon.fallbackIcon or GreedData.placeholderIcons.weapon,
            })
        end
    end
end

function Greed:IsArmorSlotTracked(slotKey)
    for _, setData in ipairs(self.displayFavorites or GreedData.favorites) do
        if setData.pieces and setData.pieces[slotKey] then
            return true
        end
    end

    return false
end

function Greed:IsWeaponTracked(weaponKey)
    for _, setData in ipairs(self.displayFavorites or GreedData.favorites) do
        if setData.weapons and setData.weapons[weaponKey] then
            return true
        end
    end

    return false
end

function Greed:BuildFavorites(ownedItemIndex)
    for _, row in ipairs(self.favoriteRows or {}) do
        row:SetHidden(true)
        row:SetMouseEnabled(false)
    end

    self.perfectedBorderCount = 0
    self.perfectedBorders = {}
    self.firstPerfectedBorder = nil
    self.favoriteRows = {}
    self.rowBuildId = (self.rowBuildId or 0) + 1

    local rows = self.displayFavorites or GreedData.favorites or {}
    ownedItemIndex = ownedItemIndex or self:BuildOwnedItemIndex()
    for index, setData in ipairs(rows) do
        self:CreateFavoriteRow(index, setData, ownedItemIndex)
    end

    self:UpdateRowsScrollLimits(#rows)
end

function Greed:SetMainScrollbarDrawOrder(control, drawLevel)
    if not control then return end

    CallControlMethod(control, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(control, "SetDrawTier", DT_HIGH)
    CallControlMethod(control, "SetDrawLevel", drawLevel or 3900)
end

function Greed:StyleMainScrollbarBackdrop(control, centerColor, edgeColor, drawLevel)
    if not control then return end

    self:SetMainScrollbarDrawOrder(control, drawLevel)

    -- Keep the overlay parent/draw order that made the scrollbar visible,
    -- but use a muted solid texture instead of the huge bright yellow block.
    if type(control.SetTexture) == "function" then
        control:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
        local color = centerColor or COLORS.scrollThumb
        control:SetColor(color[1], color[2], color[3], color[4])
        return
    end

    SetBackdropStyle(control, centerColor or COLORS.scrollTrack, edgeColor or COLORS.mutedEdge)
end

function Greed:SetRowsScrollOffsetFromScrollbarMouse()
    local scroll = self.rowsScroll
    local track = self.controls and self.controls.scrollTrack
    local thumb = self.controls and self.controls.scrollThumb
    if not scroll or not track or not thumb or not GetUIMousePosition then return end

    local maxOffset = scroll.maxOffset or 0
    if maxOffset <= 0 then return end

    local _, mouseY = GetUIMousePosition()
    local trackTop = track.GetTop and track:GetTop() or 0
    local trackHeight = GetControlDimension(track, "GetHeight", scroll.viewportHeight or MAX_ROWS_VIEWPORT_HEIGHT)
    local thumbHeight = GetControlDimension(thumb, "GetHeight", 48)
    local available = math.max(1, trackHeight - thumbHeight)
    local relativeY = math.max(0, math.min(available, (mouseY or trackTop) - trackTop - (thumbHeight / 2)))
    local nextOffset = (relativeY / available) * maxOffset

    self:SetRowsScrollOffset(nextOffset)
end

function Greed:StartRowsScrollbarDrag()
    if not self.rowsScroll or (self.rowsScroll.maxOffset or 0) <= 0 then return end

    self.rowsScrollbarDragging = true
    if self.controls and self.controls.scrollTrack then
        self.controls.scrollTrack:SetHandler("OnUpdate", function()
            self:UpdateRowsScrollbarDrag()
        end)
    end
    self:SetRowsScrollOffsetFromScrollbarMouse()
end

function Greed:UpdateRowsScrollbarDrag()
    if self.rowsScrollbarDragging ~= true then return end
    self:SetRowsScrollOffsetFromScrollbarMouse()
end

function Greed:StopRowsScrollbarDrag()
    self.rowsScrollbarDragging = false
    if self.controls and self.controls.scrollTrack then
        self.controls.scrollTrack:SetHandler("OnUpdate", nil)
    end
end

function Greed:SetupRowsScrolling()
    local rows = self.controls.rows
    if not rows then return end

    CallControlMethod(rows, "SetClipsChildren", true)
    CallControlMethod(rows, "SetMouseEnabled", true)

    local rowsWidth = GetControlDimension(rows, "GetWidth", 944)
    local rowsHeight = GetControlDimension(rows, "GetHeight", MAX_ROWS_VIEWPORT_HEIGHT)
    local rowContentWidth = self:GetMainRowsContentWidth(rowsWidth)
    rows:SetDimensions(rowsWidth, rowsHeight)

    local content = WINDOW_MANAGER:CreateControl("GreedWindowRowsContent", rows, CT_CONTROL)
    content:SetDimensions(rowContentWidth, rowsHeight)
    content:SetAnchor(TOPLEFT, rows, TOPLEFT, 0, 0)
    content:SetMouseEnabled(false)
    CallControlMethod(content, "SetDrawLayer", DL_CONTROLS)
    CallControlMethod(content, "SetDrawTier", DT_LOW)
    CallControlMethod(content, "SetDrawLevel", 1)

    -- Solid, main-window-only scrollbar.  It is parented to the main window rather than
    -- the clipped rows control so it cannot disappear behind rows or clipping.
    local scrollParent = self.controls.window or rows
    local track = WINDOW_MANAGER:CreateControl("GreedWindowRowsScrollTrack", scrollParent, CT_TEXTURE)
    track:SetDimensions(MAIN_SCROLLBAR_WIDTH, rowsHeight)
    track:SetAnchor(TOPRIGHT, self.controls.window or rows, TOPRIGHT, -MAIN_SCROLLBAR_WINDOW_RIGHT_INSET, MAIN_WINDOW_ROWS_TOP)
    track:SetMouseEnabled(true)
    self:StyleMainScrollbarBackdrop(track, MAIN_SCROLL_TRACK_COLOR, MAIN_SCROLL_TRACK_EDGE_COLOR, 3900)

    local thumb = WINDOW_MANAGER:CreateControl("GreedWindowRowsScrollThumb", track, CT_TEXTURE)
    thumb:SetDimensions(MAIN_SCROLLBAR_THUMB_WIDTH, 48)
    thumb:SetAnchor(TOP, track, TOP, 0, 2)
    thumb:SetMouseEnabled(true)
    self:StyleMainScrollbarBackdrop(thumb, MAIN_SCROLL_THUMB_COLOR, MAIN_SCROLL_THUMB_EDGE_COLOR, 3910)

    local function onMouseWheel(_, delta)
        self:ScrollRows(delta)
    end
    local function onMouseDown(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StartRowsScrollbarDrag()
        end
    end
    local function onMouseUp(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            self:StopRowsScrollbarDrag()
        end
    end
    local function onMouseExit()
        self:StopRowsScrollbarDrag()
    end

    rows:SetHandler("OnMouseWheel", onMouseWheel)
    track:SetHandler("OnMouseWheel", onMouseWheel)
    thumb:SetHandler("OnMouseWheel", onMouseWheel)
    track:SetHandler("OnMouseDown", onMouseDown)
    thumb:SetHandler("OnMouseDown", onMouseDown)
    track:SetHandler("OnMouseUp", onMouseUp)
    thumb:SetHandler("OnMouseUp", onMouseUp)
    track:SetHandler("OnMouseExit", onMouseExit)
    thumb:SetHandler("OnMouseExit", onMouseExit)

    self.controls.rowsContent = content
    self.controls.scrollTrack = track
    self.controls.scrollThumb = thumb
    self.rowsScroll = {
        offset = 0,
        maxOffset = 0,
        contentHeight = rowsHeight,
        viewportHeight = rowsHeight,
    }
end

function Greed:GetRowsParent()
    return self.controls.rowsContent or self.controls.rows
end

function Greed:UpdateRowsScrollLimits(rowCount)
    local rows = self.controls.rows
    local content = self.controls.rowsContent
    if not rows or not content then return end

    local viewportHeight = GetControlDimension(rows, "GetHeight", MAX_ROWS_VIEWPORT_HEIGHT)
    local rowsWidth = GetControlDimension(rows, "GetWidth", 944)
    local rowContentWidth = self:GetMainRowsContentWidth(rowsWidth)
    local contentHeight = 0
    local step = ROW_HEIGHT + ROW_GAP

    if rowCount and rowCount > 0 then
        contentHeight = rowCount * step - ROW_GAP
    end

    content:ClearAnchors()
    content:SetAnchor(TOPLEFT, rows, TOPLEFT, 0, 0)
    content:SetDimensions(rowContentWidth, viewportHeight)
    content:SetMouseEnabled(false)

    self.rowsScroll = self.rowsScroll or {}
    self.rowsScroll.contentHeight = contentHeight
    self.rowsScroll.viewportHeight = viewportHeight
    local visibleRowCount = math.max(1, math.floor((viewportHeight + ROW_GAP) / step))
    self.rowsScroll.maxOffset = math.max(0, math.max(0, (rowCount or 0) - visibleRowCount) * step)

    if self.controls.scrollTrack then
        self.controls.scrollTrack:ClearAnchors()
        self.controls.scrollTrack:SetDimensions(MAIN_SCROLLBAR_WIDTH, viewportHeight)
        self.controls.scrollTrack:SetAnchor(TOPRIGHT, self.controls.window or rows, TOPRIGHT, -MAIN_SCROLLBAR_WINDOW_RIGHT_INSET, MAIN_WINDOW_ROWS_TOP)
        self.controls.scrollTrack:SetMouseEnabled(true)
        self:StyleMainScrollbarBackdrop(self.controls.scrollTrack, MAIN_SCROLL_TRACK_COLOR, MAIN_SCROLL_TRACK_EDGE_COLOR, 3900)
    end

    self:SetRowsScrollOffset(math.min(self.rowsScroll.offset or 0, self.rowsScroll.maxOffset))
end

function Greed:ScrollRows(delta)
    if not self.rowsScroll or (self.rowsScroll.maxOffset or 0) <= 0 then return end

    local step = ROW_HEIGHT + ROW_GAP
    local nextOffset = (self.rowsScroll.offset or 0) - ((delta or 0) * step)
    self:SetRowsScrollOffset(nextOffset)
end

function Greed:SetRowsScrollOffset(offset)
    local rows = self.controls.rows
    local content = self.controls.rowsContent
    if not rows or not content then return end

    self.rowsScroll = self.rowsScroll or {}
    local maxOffset = self.rowsScroll.maxOffset or 0
    local step = ROW_HEIGHT + ROW_GAP
    local clampedOffset = math.max(0, math.min(maxOffset, offset or 0))
    local newOffset = math.floor(clampedOffset / step) * step
    self.rowsScroll.offset = newOffset

    content:ClearAnchors()
    content:SetAnchor(TOPLEFT, rows, TOPLEFT, 0, 0)
    content:SetMouseEnabled(false)

    self:UpdateRowVisibility()
    self:UpdateRowsScrollbar()
    if self.hitDebug then
        self:PrintHitDebug()
    end
end

function Greed:UpdateRowVisibility()
    local scroll = self.rowsScroll or {}
    local viewportHeight = scroll.viewportHeight or GetControlDimension(self.controls.rows, "GetHeight", MAX_ROWS_VIEWPORT_HEIGHT)
    local offset = scroll.offset or 0
    local step = ROW_HEIGHT + ROW_GAP
    local rowsParent = self:GetRowsParent()

    for index, row in ipairs(self.favoriteRows or {}) do
        if row then
            local rowTop = ((index - 1) * step) - offset
            local rowBottom = rowTop + ROW_HEIGHT
            local isVisible = rowTop >= 0 and rowBottom <= viewportHeight
            -- ESO clipping is unreliable for mouse hitboxes, so offscreen rows are hidden and mouse-disabled.
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, rowsParent, TOPLEFT, 0, rowTop)
            row:SetHidden(not isVisible)
            row:SetMouseEnabled(isVisible)
        end
    end
end

function Greed:UpdateRowsScrollbar()
    local scroll = self.rowsScroll
    local track = self.controls.scrollTrack
    local thumb = self.controls.scrollThumb
    if not scroll or not track or not thumb then return end

    local viewportHeight = scroll.viewportHeight or GetControlDimension(self.controls.rows, "GetHeight", MAX_ROWS_VIEWPORT_HEIGHT)
    local contentHeight = scroll.contentHeight or viewportHeight
    local maxOffset = scroll.maxOffset or 0
    local rowContentWidth = self:GetMainRowsContentWidth(GetControlDimension(self.controls.rows, "GetWidth", 944))

    -- Keep the bar visible whenever rows exist so the user can see exactly where it is.
    local hasRows = #(self.favoriteRows or {}) > 0
    track:SetHidden(not hasRows)
    thumb:SetHidden(not hasRows)
    if not hasRows then return end

    track:ClearAnchors()
    track:SetDimensions(MAIN_SCROLLBAR_WIDTH, viewportHeight)
    track:SetAnchor(TOPRIGHT, self.controls.window or self.controls.rows, TOPRIGHT, -MAIN_SCROLLBAR_WINDOW_RIGHT_INSET, MAIN_WINDOW_ROWS_TOP)
    track:SetMouseEnabled(true)
    self:StyleMainScrollbarBackdrop(track, MAIN_SCROLL_TRACK_COLOR, MAIN_SCROLL_TRACK_EDGE_COLOR, 3900)
    thumb:SetMouseEnabled(true)

    local trackHeight = GetControlDimension(track, "GetHeight", viewportHeight)
    local thumbHeight
    if maxOffset <= 0 then
        -- When the full list fits in the window there is nothing to scroll.
        -- Keep the scrollbar hit area in place, but camouflage the thumb so it
        -- does not look distorted as a full-height gold bar.
        thumbHeight = trackHeight
        self:StyleMainScrollbarBackdrop(thumb, MAIN_SCROLL_INACTIVE_THUMB_COLOR, MAIN_SCROLL_INACTIVE_THUMB_EDGE_COLOR, 3910)
    else
        self:StyleMainScrollbarBackdrop(thumb, MAIN_SCROLL_THUMB_COLOR, MAIN_SCROLL_THUMB_EDGE_COLOR, 3910)
        -- Keep the thumb from becoming a huge block.  This makes the position change clear,
        -- and lets it travel from the very top of the track to the very bottom.
        local proportionalHeight = math.floor(trackHeight * viewportHeight / math.max(contentHeight, viewportHeight))
        thumbHeight = math.max(44, math.min(76, proportionalHeight))
    end

    thumbHeight = math.min(trackHeight, thumbHeight)
    local available = math.max(0, trackHeight - thumbHeight)
    local thumbY = 0

    if maxOffset > 0 and available > 0 then
        thumbY = math.floor(((scroll.offset or 0) / maxOffset) * available)
    end

    thumb:SetDimensions(MAIN_SCROLLBAR_THUMB_WIDTH, thumbHeight)
    thumb:ClearAnchors()
    thumb:SetAnchor(TOP, track, TOP, 0, thumbY)
end

function Greed:CountPerfectedSamples()
    local count = 0

    for _, setData in ipairs(GreedData.favorites) do
        if setData.pieces then
            for _, piece in pairs(setData.pieces) do
                if piece.perfected == true then
                    count = count + 1
                end
            end
        end

        if setData.weapons then
            for _, piece in ipairs(setData.weapons) do
                if piece.perfected == true then
                    count = count + 1
                end
            end
        end
    end

    return count
end

function Greed:CreateFavoriteRow(index, setData, ownedItemIndex)
    local rowsParent = self:GetRowsParent()
    local rowBaseName = "GreedFavoriteRow" .. (self.rowBuildId or 1) .. "_" .. index
    local row = WINDOW_MANAGER:CreateControl(rowBaseName, rowsParent, CT_CONTROL)
    self.favoriteRows = self.favoriteRows or {}
    self.favoriteRows[index] = row
    local rowsWidth = GetControlDimension(self.controls.rows, "GetWidth", self:GetDynamicRowsWidth())
    local rowWidth = GetControlDimension(rowsParent, "GetWidth", self:GetMainRowsContentWidth(rowsWidth))
    row:SetDimensions(rowWidth, ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, rowsParent, TOPLEFT, 0, (index - 1) * (ROW_HEIGHT + ROW_GAP))
    row:SetMouseEnabled(true)
    CallControlMethod(row, "SetDrawLayer", DL_CONTROLS)
    CallControlMethod(row, "SetDrawTier", DT_LOW)
    CallControlMethod(row, "SetDrawLevel", 10)
    row:SetHandler("OnMouseWheel", function(_, delta)
        self:ScrollRows(delta)
    end)

    local bg = WINDOW_MANAGER:CreateControl(rowBaseName .. "Bg", row, CT_BACKDROP)
    bg:SetAnchorFill(row)
    bg:SetMouseEnabled(false)
    local rowFill
    local rowEdge
    if setData.isPerfectedRow then
        rowFill = index % 2 == 0 and COLORS.perfectedRowAlt or COLORS.perfectedRow
        rowEdge = COLORS.perfectedRowEdge
    else
        rowFill = index % 2 == 0 and COLORS.rowAlt or COLORS.row
        rowEdge = COLORS.mutedEdge
    end
    SetBackdropStyle(bg, rowFill, rowEdge)

    local accent = WINDOW_MANAGER:CreateControl(rowBaseName .. "Accent", row, CT_BACKDROP)
    accent:SetDimensions(3, ROW_HEIGHT - 8)
    accent:SetAnchor(LEFT, row, LEFT, 4, 0)
    accent:SetMouseEnabled(false)
    SetSolidBackdrop(accent, setData.isPerfectedRow and COLORS.perfectedRowEdge or COLORS.rowDivider)

    local separator = WINDOW_MANAGER:CreateControl(rowBaseName .. "Separator", row, CT_BACKDROP)
    separator:SetDimensions(math.max(1, rowWidth - 30), 1)
    separator:SetAnchor(BOTTOM, row, BOTTOM, 0, 0)
    separator:SetMouseEnabled(false)
    SetSolidBackdrop(separator, COLORS.rowDivider)

    local name = WINDOW_MANAGER:CreateControl(rowBaseName .. "Name", row, CT_LABEL)
    name:SetDimensions(288, 24)
    name:SetAnchor(TOPLEFT, row, TOPLEFT, 16, 6)
    name:SetFont("ZoFontGame")
    local nameColor = setData.isPerfectedRow and COLORS.perfectedText or COLORS.text
    name:SetColor(nameColor[1], nameColor[2], nameColor[3], nameColor[4])
    name:SetText(setData.name)
    name:SetMouseEnabled(false)

    local source = WINDOW_MANAGER:CreateControl(rowBaseName .. "Source", row, CT_LABEL)
    source:SetDimensions(288, 18)
    source:SetAnchor(TOPLEFT, name, BOTTOMLEFT, 0, -1)
    source:SetFont("ZoFontGameSmall")
    local sourceColor = setData.isPerfectedRow and COLORS.perfectedMutedText or COLORS.mutedText
    source:SetColor(sourceColor[1], sourceColor[2], sourceColor[3], sourceColor[4])
    source:SetText(setData.source)
    source:SetMouseEnabled(false)

    for slotIndex, column in ipairs(self.visibleColumns) do
        local piece = self:GetPieceForColumn(setData, column)
        if piece then
            self:CreateSlotBox(row, index, slotIndex, setData, column, piece, ownedItemIndex)
        else
            self:CreateEmptySlotBox(row, index, slotIndex)
        end
    end
end

function Greed:GetPieceForColumn(setData, column)
    if column.kind == "weapon" then
        return setData.weapons and setData.weapons[column.key] or nil
    end

    return setData.pieces and setData.pieces[column.key] or nil
end

function Greed:CreateEmptySlotBox(row, rowIndex, slotIndex)
    local name = "GreedFavoriteRow" .. (self.rowBuildId or 1) .. "_" .. rowIndex .. "EmptySlot" .. slotIndex
    local x = SLOT_START_X + (slotIndex - 1) * (SLOT_SIZE + SLOT_GAP)

    local box = WINDOW_MANAGER:CreateControl(name, row, CT_BACKDROP)
    box:SetDimensions(SLOT_SIZE, SLOT_SIZE)
    box:SetAnchor(TOPLEFT, row, TOPLEFT, x, 2)
    box:SetMouseEnabled(true)
    box:SetHandler("OnMouseWheel", function(_, delta)
        self:ScrollRows(delta)
    end)
    SetBackdropStyle(box, COLORS.emptyCell, COLORS.mutedEdge)
end

function Greed:CreateSlotBox(row, rowIndex, slotIndex, setData, column, piece, ownedItemIndex)
    local name = "GreedFavoriteRow" .. (self.rowBuildId or 1) .. "_" .. rowIndex .. "Slot" .. slotIndex
    local x = SLOT_START_X + (slotIndex - 1) * (SLOT_SIZE + SLOT_GAP)

    local box = WINDOW_MANAGER:CreateControl(name, row, CT_CONTROL)
    box:SetDimensions(SLOT_SIZE, SLOT_SIZE)
    box:SetAnchor(TOPLEFT, row, TOPLEFT, x, 2)
    box:SetMouseEnabled(true)
    CallControlMethod(box, "SetDrawLayer", DL_TEXT)
    CallControlMethod(box, "SetDrawTier", DT_HIGH)
    CallControlMethod(box, "SetDrawLevel", 60)

    local frame = WINDOW_MANAGER:CreateControl(name .. "Frame", box, CT_BACKDROP)
    frame:SetAnchorFill(box)
    frame:SetMouseEnabled(false)
    CallControlMethod(frame, "SetDrawLayer", DL_BACKGROUND)
    CallControlMethod(frame, "SetDrawTier", DT_LOW)
    CallControlMethod(frame, "SetDrawLevel", 0)

    local isPerfected = piece.perfected == true
    SetBackdropStyle(frame, COLORS.cell, COLORS.cellEdge)

    local icon = WINDOW_MANAGER:CreateControl(name .. "Icon", box, CT_TEXTURE)
    icon:SetAnchor(TOPLEFT, box, TOPLEFT, 4, 4)
    icon:SetAnchor(BOTTOMRIGHT, box, BOTTOMRIGHT, -4, -4)
    local iconPath = self:ResolveCellIcon(setData, column, piece)
    icon:SetTexture(iconPath)
    icon:SetColor(1, 1, 1, 1)
    CallControlMethod(icon, "SetDrawLayer", DL_CONTROLS)
    CallControlMethod(icon, "SetDrawTier", DT_LOW)
    CallControlMethod(icon, "SetDrawLevel", 10)
    icon:SetMouseEnabled(false)

    if piece.iconResolutionFailed then
        self:CreateIconErrorBadge(box, name)
    end

    -- Owned inventory and Sticker Book state are checked separately.
    -- Rings stay special because this tracker treats the selected ring piece as two desired copies.
    local collectedCount, neededCount = self:GetPieceCounts(column, piece, setData, ownedItemIndex)
    local stickerBookUnlocked = self:IsPieceUnlockedInStickerbook(setData, column, piece) == true

    if collectedCount >= neededCount then
        self:CreateCollectedBadge(box, name)
    elseif stickerBookUnlocked then
        self:CreateStickerBookBadge(box, name)
    end

    if column.kind == "weapon" then
        self:CreateWeaponBadge(box, name, piece)
    elseif column.key == "ring" then
        local countLabel = WINDOW_MANAGER:CreateControl(name .. "Count", box, CT_LABEL)
        countLabel:SetAnchor(BOTTOM, box, BOTTOM, 0, -2)
        countLabel:SetDimensions(SLOT_SIZE, 16)
        countLabel:SetFont("ZoFontGameSmall")
        countLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        countLabel:SetColor(1, 0.96, 0.82, 1)
        CallControlMethod(countLabel, "SetDrawLayer", DL_TEXT)
        CallControlMethod(countLabel, "SetDrawTier", DT_HIGH)
        CallControlMethod(countLabel, "SetDrawLevel", 110)
        countLabel:SetMouseEnabled(false)
        countLabel:SetText(string.format("%d/%d", collectedCount, neededCount))
    end

    box:SetHandler("OnMouseWheel", function(_, delta)
        self:ScrollRows(delta)
    end)
    box:SetHandler("OnMouseEnter", function(control)
        self:PrintGridSlotHitDebug(control, row, setData, column)
        self:ShowSlotTooltip(control, setData, column, piece, collectedCount, neededCount, stickerBookUnlocked)
    end)
    box:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    box:SetHandler("OnMouseUp", function(control, button)
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            self:ShowItemMenu(control, setData, column, piece)
        end
    end)
end

function Greed:CreateTransparentCheckmark(parent, baseName, color, size, drawLevel)
    if not parent then return nil end

    -- Kept the old function name to avoid touching callers, but this now uses ESO's native checkbox texture.
    -- Do not replace this with custom/pixel-art checkmarks. Reliability/readability matters more here.
    local checkSize = size or 18
    local check = WINDOW_MANAGER:CreateControl(baseName .. "NativeCheck", parent, CT_TEXTURE)
    check:SetDimensions(checkSize, checkSize)
    check:SetAnchor(CENTER, parent, CENTER, 0, 0)
    check:SetTexture("EsoUI/Art/Buttons/checkbox_checked.dds")
    check:SetColor((color or COLORS.text)[1], (color or COLORS.text)[2], (color or COLORS.text)[3], (color or COLORS.text)[4])
    check:SetMouseEnabled(false)
    CallControlMethod(check, "SetDrawLayer", DL_TEXT)
    CallControlMethod(check, "SetDrawTier", DT_HIGH)
    CallControlMethod(check, "SetDrawLevel", drawLevel or 125)

    return check
end


function Greed:CreateCollectedBadge(box, baseName)
    local badgeBg = WINDOW_MANAGER:CreateControl(baseName .. "CollectedBadgeBg", box, CT_BACKDROP)
    badgeBg:SetDimensions(18, 18)
    badgeBg:SetAnchor(TOPLEFT, box, TOPLEFT, 1, 1)
    badgeBg:SetMouseEnabled(false)
    CallControlMethod(badgeBg, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badgeBg, "SetDrawTier", DT_HIGH)
    CallControlMethod(badgeBg, "SetDrawLevel", 120)
    SetTransparentCheckBackdrop(badgeBg, COLORS.collected)

    self:CreateTransparentCheckmark(badgeBg, baseName .. "Collected", COLORS.collected, 18, 125)
end

function Greed:CreateStickerBookBadge(box, baseName)
    local badgeBg = WINDOW_MANAGER:CreateControl(baseName .. "StickerBookBadgeBg", box, CT_BACKDROP)
    badgeBg:SetDimensions(18, 18)
    badgeBg:SetAnchor(TOPLEFT, box, TOPLEFT, 1, 1)
    badgeBg:SetMouseEnabled(false)
    CallControlMethod(badgeBg, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badgeBg, "SetDrawTier", DT_HIGH)
    CallControlMethod(badgeBg, "SetDrawLevel", 120)
    SetTransparentCheckBackdrop(badgeBg, COLORS.stickerBook)

    self:CreateTransparentCheckmark(badgeBg, baseName .. "StickerBook", COLORS.stickerBook, 18, 125)
end

function Greed:CreateWeaponBadge(box, baseName, piece)
    local weaponType = self:GetWeaponType(piece)
    local badgeText = weaponType.shortLabel or weaponType.badge or "Wpn"

    local badgeBg = WINDOW_MANAGER:CreateControl(baseName .. "WeaponBadgeBg", box, CT_BACKDROP)
    badgeBg:SetDimensions(38, 14)
    badgeBg:SetAnchor(BOTTOM, box, BOTTOM, 0, -2)
    CallControlMethod(badgeBg, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badgeBg, "SetDrawTier", DT_HIGH)
    CallControlMethod(badgeBg, "SetDrawLevel", 110)
    badgeBg:SetMouseEnabled(false)
    SetBackdropStyle(badgeBg, COLORS.badge, COLORS.gold)

    local badge = WINDOW_MANAGER:CreateControl(baseName .. "WeaponBadge", box, CT_LABEL)
    badge:SetDimensions(38, 14)
    badge:SetAnchor(CENTER, badgeBg, CENTER, 0, 0)
    badge:SetFont("ZoFontGameSmall")
    badge:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(badge, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    badge:SetColor(1, 0.90, 0.58, 1)
    CallControlMethod(badge, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badge, "SetDrawTier", DT_HIGH)
    CallControlMethod(badge, "SetDrawLevel", 115)
    badge:SetMouseEnabled(false)
    badge:SetText(badgeText)
end

function Greed:CreateNeedOverlay(box, baseName, icon)
    local redOverlay = WINDOW_MANAGER:CreateControl(baseName .. "NeedOverlay", box, CT_BACKDROP)
    redOverlay:SetAnchor(TOPLEFT, icon, TOPLEFT)
    redOverlay:SetAnchor(BOTTOMRIGHT, icon, BOTTOMRIGHT)
    redOverlay:SetMouseEnabled(false)
    CallControlMethod(redOverlay, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(redOverlay, "SetDrawTier", DT_MEDIUM)
    CallControlMethod(redOverlay, "SetDrawLevel", 30)
    SetSolidBackdrop(redOverlay, COLORS.needFill)

    local redX = WINDOW_MANAGER:CreateControl(baseName .. "NeedX", box, CT_LABEL)
    redX:SetAnchor(CENTER, icon, CENTER, 0, 0)
    redX:SetDimensions(SLOT_SIZE - 8, SLOT_SIZE - 8)
    redX:SetFont("ZoFontWinH3")
    redX:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(redX, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    redX:SetColor(COLORS.needTint[1], COLORS.needTint[2], COLORS.needTint[3], COLORS.needTint[4])
    redX:SetText("X")
    redX:SetMouseEnabled(false)
    CallControlMethod(redX, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(redX, "SetDrawTier", DT_HIGH)
    CallControlMethod(redX, "SetDrawLevel", 40)
end

function Greed:CreatePerfectedBadge(box, baseName)
    -- The old gold border/background approaches were unreliable in ESO.
    -- This badge uses the same reliable label-overlay method as the red X.
    local badgeBg = WINDOW_MANAGER:CreateControl(baseName .. "PerfectedBadgeBg", box, CT_BACKDROP)
    badgeBg:SetDimensions(16, 16)
    badgeBg:SetAnchor(TOPLEFT, box, TOPLEFT, 1, 1)
    badgeBg:SetMouseEnabled(false)
    CallControlMethod(badgeBg, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badgeBg, "SetDrawTier", DT_HIGH)
    CallControlMethod(badgeBg, "SetDrawLevel", 120)
    SetBackdropStyle(badgeBg, { 0.015, 0.012, 0.006, 0.86 }, PERFECTED_BORDER_COLOR)

    local badge = WINDOW_MANAGER:CreateControl(baseName .. "PerfectedBadge", box, CT_LABEL)
    badge:SetDimensions(16, 16)
    badge:SetAnchor(CENTER, badgeBg, CENTER, 0, 0)
    badge:SetFont("ZoFontGameBold")
    badge:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(badge, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    badge:SetColor(PERFECTED_BORDER_COLOR[1], PERFECTED_BORDER_COLOR[2], PERFECTED_BORDER_COLOR[3], PERFECTED_BORDER_COLOR[4])
    badge:SetText("P")
    badge:SetMouseEnabled(false)
    CallControlMethod(badge, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badge, "SetDrawTier", DT_HIGH)
    CallControlMethod(badge, "SetDrawLevel", 125)
end

function Greed:CreatePerfectedBorder(box, baseName)
    self.perfectedBorderCount = (self.perfectedBorderCount or 0) + 1

    local borderContainer = WINDOW_MANAGER:CreateControl(baseName .. "PerfectedBorderContainer", box, CT_CONTROL)
    borderContainer:SetDimensions(SLOT_SIZE, SLOT_SIZE)
    borderContainer:SetAnchor(TOPLEFT, box, TOPLEFT, 0, 0)
    borderContainer:SetAnchor(BOTTOMRIGHT, box, BOTTOMRIGHT, 0, 0)
    borderContainer:SetMouseEnabled(false)
    CallControlMethod(borderContainer, "SetDrawLayer", DL_TEXT)
    CallControlMethod(borderContainer, "SetDrawTier", DT_HIGH)
    CallControlMethod(borderContainer, "SetDrawLevel", 85)

    local borderData = {
        cell = box,
        container = borderContainer,
        top = self:CreatePerfectedBorderSegment(baseName .. "PerfectedBorderTop", borderContainer),
        bottom = self:CreatePerfectedBorderSegment(baseName .. "PerfectedBorderBottom", borderContainer),
        left = self:CreatePerfectedBorderSegment(baseName .. "PerfectedBorderLeft", borderContainer),
        right = self:CreatePerfectedBorderSegment(baseName .. "PerfectedBorderRight", borderContainer),
    }

    self.perfectedBorders = self.perfectedBorders or {}
    table.insert(self.perfectedBorders, borderData)
    self.firstPerfectedBorder = self.firstPerfectedBorder or borderData

    self:ApplyPerfectedBorder(borderData)
end

function Greed:CreatePerfectedBorderSegment(name, parent)
    local segment = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    segment:SetMouseEnabled(false)
    CallControlMethod(segment, "SetDrawLayer", DL_TEXT)
    CallControlMethod(segment, "SetDrawTier", DT_HIGH)
    CallControlMethod(segment, "SetDrawLevel", 90)

    return segment
end

function Greed:GetActiveBorderStyle()
    return PERFECTED_BORDER_STYLES[self.borderStyle or 1] or PERFECTED_BORDER_STYLES[1]
end

function Greed:GetBorderThickness(style, thicknessKey, debugThicknessKey)
    if self.debugBorderMode then
        return style[debugThicknessKey] or style[thicknessKey]
    end

    return style[thicknessKey]
end

function Greed:StyleBorderTexture(segment, texturePath, textureCoords, drawLevel)
    if not segment then return end

    segment:ClearAnchors()
    segment:SetTexture(texturePath)
    segment:SetColor(PERFECTED_BORDER_COLOR[1], PERFECTED_BORDER_COLOR[2], PERFECTED_BORDER_COLOR[3], PERFECTED_BORDER_COLOR[4])

    local coords = textureCoords or { 0, 1, 0, 1 }
    CallControlMethod(segment, "SetTextureCoords", coords[1], coords[2], coords[3], coords[4])

    segment:SetMouseEnabled(false)
    CallControlMethod(segment, "SetDrawLayer", DL_TEXT)
    CallControlMethod(segment, "SetDrawTier", DT_HIGH)
    CallControlMethod(segment, "SetDrawLevel", drawLevel or 90)
end

function Greed:ApplyPerfectedBorder(borderData)
    if not borderData or not borderData.cell or not borderData.container then return end

    local cell = borderData.cell
    local borderContainer = borderData.container
    local cellWidth = GetControlDimension(cell, "GetWidth", SLOT_SIZE)
    local cellHeight = GetControlDimension(cell, "GetHeight", SLOT_SIZE)
    local borderWidth = GetControlDimension(borderContainer, "GetWidth", cellWidth)
    local borderHeight = GetControlDimension(borderContainer, "GetHeight", cellHeight)
    local style = self:GetActiveBorderStyle()
    local topBottomThickness = self:GetBorderThickness(style, "topThickness", "debugTopThickness")
    local sideThickness = self:GetBorderThickness(style, "sideThickness", "debugSideThickness")
    local outsideOffset = self.debugBorderMode and 2 or 1
    local sideOverhang = self:GetBorderSideOverhang()
    local sideOffset = sideOverhang / 2
    local sideHeight = borderHeight + sideOverhang

    borderContainer:ClearAnchors()
    borderContainer:SetDimensions(cellWidth, cellHeight)
    borderContainer:SetAnchor(TOPLEFT, cell, TOPLEFT, 0, 0)
    borderContainer:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, 0, 0)

    self:StyleBorderTexture(borderData.top, style.topTexture, style.textureCoords, 90)
    borderData.top:SetDimensions(borderWidth + outsideOffset * 2, topBottomThickness)
    borderData.top:SetAnchor(TOPLEFT, borderContainer, TOPLEFT, -outsideOffset, -outsideOffset)

    self:StyleBorderTexture(borderData.bottom, style.topTexture, style.textureCoords, 90)
    borderData.bottom:SetDimensions(borderWidth + outsideOffset * 2, topBottomThickness)
    borderData.bottom:SetAnchor(BOTTOMLEFT, borderContainer, BOTTOMLEFT, -outsideOffset, outsideOffset)

    self:StyleBorderTexture(borderData.left, style.sideTexture, style.sideTextureCoords, 90)
    borderData.left:SetDimensions(sideThickness, sideHeight)
    borderData.left:SetAnchor(TOPLEFT, borderContainer, TOPLEFT, -outsideOffset, -sideOffset)

    self:StyleBorderTexture(borderData.right, style.sideTexture, style.sideTextureCoords, 90)
    borderData.right:SetDimensions(sideThickness, sideHeight)
    borderData.right:SetAnchor(TOPRIGHT, borderContainer, TOPRIGHT, outsideOffset, -sideOffset)

    borderData.debugCellHeight = cellHeight
    borderData.debugBorderHeight = borderHeight
    borderData.debugSideOverhang = sideOverhang
    borderData.debugCalculatedSideHeight = sideHeight
    borderData.debugLeftHeight = GetControlDimension(borderData.left, "GetHeight", sideHeight)
    borderData.debugRightHeight = GetControlDimension(borderData.right, "GetHeight", sideHeight)
end

function Greed:RefreshPerfectedBorders()
    for _, borderData in ipairs(self.perfectedBorders or {}) do
        self:ApplyPerfectedBorder(borderData)
    end
end

function Greed:RefreshAllBorders()
    self:RefreshPerfectedBorders()
    self:RefreshLegendGoldBorder()
end

function Greed:ToggleDebugBorderMode()
    self.debugBorderMode = not self.debugBorderMode
    self.borderSizeDebugPrinted = false
    self:RefreshAllBorders()

    if self.debugBorderMode then
        SafeAnnounce("Greed: Debug border mode ON")
        SafeAnnounce(string.format("Greed: Perfected borders rendered: %d", self.perfectedBorderCount or 0))
        self:DebugFirstPerfectedBorderSize()
    else
        SafeAnnounce("Greed: Debug border mode OFF")
    end
end

function Greed:CycleBorderStyle()
    self.borderStyle = (self.borderStyle or 1) + 1
    if self.borderStyle > #PERFECTED_BORDER_STYLES then
        self.borderStyle = 1
    end

    self.borderSizeDebugPrinted = false
    self:RefreshAllBorders()
    SafeAnnounce(string.format("Greed: Border style %d", self.borderStyle))

    if self.debugBorderMode then
        self:DebugFirstPerfectedBorderSize()
    end
end

function Greed:GetBorderSideOverhang()
    return self.borderSideOverhang or DEFAULT_PERFECTED_SIDE_OVERHANG
end

function Greed:CycleBorderSideOverhang()
    local current = self:GetBorderSideOverhang()
    local nextIndex = 1

    for index, value in ipairs(PERFECTED_SIDE_OVERHANG_VALUES) do
        if value == current then
            nextIndex = index + 1
            break
        end
    end

    if nextIndex > #PERFECTED_SIDE_OVERHANG_VALUES then
        nextIndex = 1
    end

    self.borderSideOverhang = PERFECTED_SIDE_OVERHANG_VALUES[nextIndex]
    self.borderSizeDebugPrinted = false
    self:RefreshAllBorders()

    SafeAnnounce(string.format("Greed: Border side overhang = %d", self.borderSideOverhang))

    if self.debugBorderMode then
        self:DebugFirstPerfectedBorderSize()
    end
end

function Greed:DebugFirstPerfectedBorderSize()
    if self.borderSizeDebugPrinted then return end

    self.borderSizeDebugPrinted = true

    local borderData = self.firstPerfectedBorder
    if not borderData then
        SafeAnnounce("Greed border debug:")
        SafeAnnounce("cell height = 0")
        SafeAnnounce("border container height = 0")
        SafeAnnounce("left side height = 0")
        SafeAnnounce("right side height = 0")
        return
    end

    self:ApplyPerfectedBorder(borderData)

    SafeAnnounce("Greed border debug:")
    SafeAnnounce(string.format("cell height = %.0f", borderData.debugCellHeight or 0))
    SafeAnnounce(string.format("border container height = %.0f", borderData.debugBorderHeight or 0))
    SafeAnnounce(string.format("side overhang = %.0f", borderData.debugSideOverhang or 0))
    SafeAnnounce(string.format("calculated side height = %.0f", borderData.debugCalculatedSideHeight or 0))
    SafeAnnounce(string.format("left side height = %.0f", borderData.debugLeftHeight or 0))
    SafeAnnounce(string.format("right side height = %.0f", borderData.debugRightHeight or 0))
end

function Greed:DebugPerfectedSampleCount()
    if self.perfectedBorderDebugPrinted then return end

    self.perfectedBorderDebugPrinted = true
    SafeAnnounce(string.format("Greed: Perfected sample count: %d", self.perfectedSampleCount or 0))
end

function Greed:GetWeaponType(piece)
    return WEAPON_ITEM_BY_KEY[piece.type] or GreedData.weaponTypes[piece.type] or {
        label = T("Weapon"),
        badge = "Wpn",
        fallbackIcon = GreedData.placeholderIcons.weapon,
    }
end

function Greed:ResolveCellIcon(setData, column, piece)
    if piece.icon then
        piece.iconResolutionFailed = false
        return piece.icon
    end

    local itemLink, itemId = self:ResolveItemLink(setData, column, piece)
    if itemLink and GetItemLinkIcon then
        local iconPath = GetItemLinkIcon(itemLink)
        if iconPath and iconPath ~= "" then
            piece.itemLink = itemLink
            piece.itemId = itemId
            piece.itemName = self:GetItemLinkDisplayName(itemLink, setData, column, piece)
            piece.collectionSlot = piece.collectionSlot or self:GetCollectionSlotFromItemLink(itemLink)
            piece.iconResolutionFailed = false
            return iconPath
        end
    end

    local fallbackIcon, label = self:GetFallbackIconAndLabel(column, piece)
    piece.iconResolutionFailed = true
    self:DebugIconFallback(setData, label, "LibSets did not return a usable item icon")

    return fallbackIcon
end

function Greed:ResolveItemLink(setData, column, piece)
    if piece.itemLink then
        return piece.itemLink, piece.itemId
    end

    local setId = self:GetLibSetsSetId(setData)
    if not setId then
        self:DebugIconFallback(setData, self:GetColumnDisplayLabel(column, piece), "set ID could not be resolved")
        return nil, nil
    end

    local equipType, weaponType = self:GetLibSetsFilters(column, piece)
    if not equipType and not weaponType then
        self:DebugIconFallback(setData, self:GetColumnDisplayLabel(column, piece), "slot filters are missing")
        return nil, nil
    end

    local itemId = libSets.GetSetItemId(setId, nil, equipType, nil, nil, nil, weaponType)

    if column.kind == "weapon" then
        -- Some LibSets versions are pickier when filtering weapon items; retry with weapon type only.
        if not itemId and weaponType then
            itemId = libSets.GetSetItemId(setId, nil, nil, nil, nil, nil, weaponType)
        end
    end

    if not itemId then
        self:DebugIconFallback(setData, self:GetColumnDisplayLabel(column, piece), "item ID could not be resolved")
        return nil, nil
    end

    local itemLink = libSets.buildItemLink(itemId, 368)
    if not itemLink or itemLink == "" then
        self:DebugIconFallback(setData, self:GetColumnDisplayLabel(column, piece), "item link could not be built")
        return nil, itemId
    end

    piece.itemLink = itemLink
    piece.itemId = itemId
    piece.collectionSlot = piece.collectionSlot or self:GetCollectionSlotFromItemLink(itemLink)

    return itemLink, itemId
end

function Greed:GetLibSetsSetId(setData)
    if not setData then return nil end

    if setData and setData.isPerfectedRow == true then
        if setData.perfectedSetId then
            setData.setId = setData.perfectedSetId
            return setData.perfectedSetId
        end

        if setData.setId then
            local perfectedInfo = libSets.GetPerfectedSetInfo(setData.setId)
            if perfectedInfo and perfectedInfo.perfectedSetId then
                setData.perfectedSetId = perfectedInfo.perfectedSetId
                setData.normalSetId = perfectedInfo.nonPerfectedSetId or setData.normalSetId or setData.setId
                setData.setId = perfectedInfo.perfectedSetId
                return perfectedInfo.perfectedSetId
            end
        end
    end

    if setData.setId then
        return setData.setId
    end

    local setId = libSets.GetSetByName(setData.lookupName or setData.name)
    setData.setId = setId

    return setId
end

function Greed:GetLibSetsFilters(column, piece)
    if column.kind == "weapon" then
        local weaponType = column.weaponType and column or self:GetWeaponType(piece)
        return nil, weaponType.weaponType
    end

    return column.equipType, nil
end

function Greed:GetFallbackIconAndLabel(column, piece)
    local fallbackIcon = column.fallbackIcon or GreedData.placeholderIcons.armor
    local label = column.label

    if column.kind == "weapon" then
        local weaponType = self:GetWeaponType(piece)
        fallbackIcon = weaponType.fallbackIcon or GreedData.placeholderIcons.weapon
        label = weaponType.label
    end

    return fallbackIcon, label
end

function Greed:GetColumnDisplayLabel(column, piece)
    if column.kind == "weapon" then
        return self:GetWeaponType(piece).label
    end

    return column.label
end

function Greed:GetItemLinkDisplayName(itemLink, setData, column, piece)
    if GetItemLinkName then
        local itemName = GetItemLinkName(itemLink)
        if itemName and itemName ~= "" then
            return itemName
        end
    end

    return self:GetDisplayItemName(setData, column, piece)
end

function Greed:DebugIconFallback(setData, label, reason)
    local key = string.format("%s/%s", setData.name or "Unknown Set", label or "Unknown Slot")
    if self.iconFallbackDebugShown and self.iconFallbackDebugShown[key] then return end

    self.iconFallbackDebugShown = self.iconFallbackDebugShown or {}
    self.iconFallbackDebugShown[key] = true

    SafeAnnounce(string.format("Greed debug: could not resolve real item icon for %s / %s (%s). Showing a marked fallback.", setData.name, label, reason or "unknown reason"))
end

function Greed:CreateIconErrorBadge(box, baseName)
    local badgeBg = WINDOW_MANAGER:CreateControl(baseName .. "IconErrorBg", box, CT_BACKDROP)
    badgeBg:SetDimensions(14, 14)
    badgeBg:SetAnchor(TOPRIGHT, box, TOPRIGHT, -2, 2)
    CallControlMethod(badgeBg, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badgeBg, "SetDrawTier", DT_HIGH)
    CallControlMethod(badgeBg, "SetDrawLevel", 80)
    badgeBg:SetMouseEnabled(false)
    SetBackdropStyle(badgeBg, { 0.42, 0.02, 0.01, 0.92 }, COLORS.red)

    local badge = WINDOW_MANAGER:CreateControl(baseName .. "IconError", box, CT_LABEL)
    badge:SetDimensions(14, 14)
    badge:SetAnchor(CENTER, badgeBg, CENTER, 0, 0)
    badge:SetFont("ZoFontGameSmall")
    badge:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    CallControlMethod(badge, "SetVerticalAlignment", TEXT_ALIGN_CENTER)
    CallControlMethod(badge, "SetDrawLayer", DL_TEXT)
    CallControlMethod(badge, "SetDrawTier", DT_HIGH)
    CallControlMethod(badge, "SetDrawLevel", 85)
    badge:SetColor(1, 0.88, 0.78, 1)
    badge:SetMouseEnabled(false)
    badge:SetText("!")
end

function Greed:HasAntiquityLeadDataSource()
    -- Kept intentionally conservative. Greed will not invent or ship a fake lead list.
    return type(GetNumAntiquities) == "function" and type(GetAntiquityInfo) == "function"
end

function Greed:CreateAntiquityLeadsWindow()
    if self.antiquityControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedAntiquityLeadsWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(560, 330)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, -20)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    self:EnableEscapeForWindow(window)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 292)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedAntiquityLeadsBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedAntiquityLeadsTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(560, 46)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedAntiquityLeadsTitle", window, CT_LABEL)
    title:SetDimensions(500, 26)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 15)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Antiquity Leads"))
    title:SetMouseEnabled(true)

    local closeButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedAntiquityLeadsClose", window, "ZO_DefaultButton")
    closeButton:SetDimensions(30, 28)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -16, 12)
    SetButtonText(closeButton, "X")
    StyleTransparentTextButton(closeButton)
    closeButton:SetHandler("OnClicked", function()
        self:HideAntiquityLeadsWindow()
    end)

    local searchBackdrop = WINDOW_MANAGER:CreateControlFromVirtual("GreedAntiquityLeadsSearchBackdrop", window, "ZO_EditBackdrop")
    searchBackdrop:SetDimensions(390, 30)
    searchBackdrop:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 18)

    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("GreedAntiquityLeadsSearchBox", searchBackdrop, "ZO_DefaultEditForBackdrop")
    searchBox:SetAnchorFill(searchBackdrop)
    searchBox:SetMaxInputChars(80)
    if searchBox.SetDefaultText then
        searchBox:SetDefaultText(T("Search lead name"))
    end

    local message = WINDOW_MANAGER:CreateControl("GreedAntiquityLeadsMessage", window, CT_LABEL)
    message:SetDimensions(510, 120)
    message:SetAnchor(TOPLEFT, searchBackdrop, BOTTOMLEFT, 0, 20)
    message:SetFont("ZoFontGame")
    AllowMultilineLabelText(message, 6)
    message:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    message:SetText(T("Lead data source unavailable. Add a lead data table or enable supported Antiquity API."))

    self.antiquityControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        searchBox = searchBox,
        message = message,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "antiquityLeads")
end

function Greed:ShowAntiquityLeadsWindow()
    if self.antiquityControls and self.antiquityControls.window then
        self.antiquityControls.window:SetHidden(true)
    end
    SafeAnnounce(T("Greed: Antiquity lead watchlist is deferred until a reliable lead data source is available."))
end

function Greed:HideAntiquityLeadsWindow()
    if self.antiquityControls and self.antiquityControls.window then
        self.antiquityControls.window:SetHidden(true)
    end
end

function Greed:RegisterAddonSettingsPanel()
    if self.addonSettingsRegistered then return end

    local lam = libAddonMenu
    self.addonSettingsRegistered = true

    local panelData = {
        type = "panel",
        name = "Greed",
        displayName = "GREED",
        author = self.author or "Previsible",
        version = "0.9.3-beta",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local textSizeChoices = {}
    for _, sizeData in ipairs(DROP_LOG_TEXT_SIZES) do
        table.insert(textSizeChoices, sizeData.label)
    end

    local slashCommandLines = {}
    for _, doc in ipairs(SLASH_COMMAND_DOCS) do
        table.insert(slashCommandLines, doc.command .. " - " .. doc.description)
    end

    local optionsData = {
        { type = "description", text = T("Greed wishlist and Drop List settings.") },
        { type = "header", name = T("Drop List") },
        {
            type = "checkbox",
            name = T("Toggle Drop List Window"),
            tooltip = T("Show or hide the Greed Drop List window."),
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.enabled == true
            end,
            setFunc = function(value)
                self:InitializeDropLogSettings()
                self.savedVars.dropLog.enabled = value == true
                if self.savedVars.dropLog.enabled then
                    self:ShowDropListWindow(false)
                else
                    self:HideDropListWindow(false)
                end
                self:RefreshDropOptionsState()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = T("Include other players' loot"),
            tooltip = T("Track wishlist drops looted by other group members, not only your own loot."),
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.trackGroupLoot ~= false
            end,
            setFunc = function(value)
                self:InitializeDropLogSettings()
                self.savedVars.dropLog.trackGroupLoot = value ~= false
                self:RefreshDropListWindow()
                self:RefreshDropOptionsState()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = T("Only log items I still need"),
            tooltip = T("Skip wishlist drops only when you already own the tracked item count. Sticker Book unlocks still count as needed."),
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.onlyMissing ~= false
            end,
            setFunc = function(value)
                self:InitializeDropLogSettings()
                self.savedVars.dropLog.onlyMissing = value ~= false
                self:RefreshDropListWindow()
                self:RefreshDropOptionsState()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = T("Hide Drop List during menus"),
            tooltip = T("Hide the Drop List when screens like Skills, Inventory, Settings, Collections, or Tamriel Tomes are open."),
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.hideInMenus ~= false
            end,
            setFunc = function(value)
                self:InitializeDropLogSettings()
                self.savedVars.dropLog.hideInMenus = value == true
                self:UpdateDropListMenuVisibility()
                self:RefreshDropOptionsState()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = T("Lock Drop List window"),
            tooltip = T("Prevent the Drop List from being moved or resized."),
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.locked == true
            end,
            setFunc = function(value)
                self:SetDropListLocked(value == true)
            end,
            default = false,
        },
        { type = "header", name = T("Drop List Appearance") },
        {
            type = "dropdown",
            name = T("Drop List Text Size"),
            choices = textSizeChoices,
            getFunc = function()
                return self:GetDropLogTextSizeLabel()
            end,
            setFunc = function(value)
                self:SetDropLogTextSizeByLabel(value)
            end,
            default = T("Small"),
        },
        {
            type = "dropdown",
            name = T("Greed Drop List Font"),
            choices = FONT_CHOICE_LABELS,
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.fontName or DEFAULT_FONT_NAME
            end,
            setFunc = function(value)
                self:SetDropLogFontByLabel(value)
            end,
            default = DEFAULT_FONT_NAME,
        },
        {
            type = "slider",
            name = T("Background Opacity"),
            tooltip = T("0 makes the Drop List background transparent."),
            min = 0,
            max = 95,
            step = 5,
            getFunc = function()
                return self:GetDropListOpacityPercent()
            end,
            setFunc = function(value)
                self:SetDropListOpacity((value or 0) / 100)
            end,
            default = 40,
        },
        { type = "header", name = T("Text Prompts") },
        {
            type = "checkbox",
            name = T("Greed Drop Text"),
            tooltip = T("Show a text-only alert when a Greed wishlist item drops."),
            getFunc = function()
                self:InitializeTextPromptSettings()
                return self:IsPromptEnabled("drop")
            end,
            setFunc = function(value)
                self:SetPromptEnabled("drop", value ~= false)
                self:RefreshDropOptionsState()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = T("Spaulder Text"),
            tooltip = T("Show a text-only reminder for Spaulder of Ruin when safe checks say it is needed."),
            getFunc = function()
                self:InitializeTextPromptSettings()
                return self:IsPromptEnabled("spaulder")
            end,
            setFunc = function(value)
                self:SetPromptEnabled("spaulder", value ~= false)
                self:RefreshDropOptionsState()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = T("Lock all Text Prompts"),
            tooltip = T("Prevent Greed text prompt positions from being dragged."),
            getFunc = function()
                self:InitializeTextPromptSettings()
                return self.savedVars.textPrompts.locked == true
            end,
            setFunc = function(value)
                self:InitializeTextPromptSettings()
                self.savedVars.textPrompts.locked = value == true
                self:RefreshTextPromptMovement()
                self:RefreshDropOptionsState()
            end,
            default = false,
        },
        {
            type = "dropdown",
            name = T("Text Box Font"),
            choices = FONT_CHOICE_LABELS,
            getFunc = function()
                self:InitializeTextPromptSettings()
                return self.savedVars.textPrompts.fontName or DEFAULT_FONT_NAME
            end,
            setFunc = function(value)
                self:SetTextPromptFontByLabel(value)
            end,
            default = DEFAULT_FONT_NAME,
        },
        { type = "header", name = T("Tracked List") },
        {
            type = "dropdown",
            name = T("Tracked List Scope"),
            choices = TRACKING_SCOPE_CHOICES,
            getFunc = function()
                return self:GetTrackingScopeLabel()
            end,
            setFunc = function(value)
                self:SetTrackingScopeByLabel(value)
            end,
            default = TRACKING_SCOPE_CHARACTER_LABEL,
        },
        { type = "header", name = T("Launcher / Windows") },
        {
            type = "checkbox",
            name = T("Lock Greed Launcher Icon"),
            tooltip = T("Prevent the small Greed launcher icon from being dragged while keeping it clickable."),
            getFunc = function()
                return self:IsLauncherLocked()
            end,
            setFunc = function(value)
                self:SetLauncherLocked(value == true)
                self:RefreshDropOptionsState()
            end,
            default = false,
        },
        {
            type = "button",
            name = T("Reset Windows"),
            func = function()
                self:ResetWindowPositions()
            end,
        },
        {
            type = "button",
            name = T("Reset Drop List"),
            func = function()
                self:ShowResetDropListConfirm()
            end,
            warning = T("Resets Drop List settings, clears filters, and clears Drop List history after confirmation."),
        },
        {
            type = "button",
            name = T("Reset Greed"),
            func = function()
                self:ShowResetGreedConfirm()
            end,
            warning = T("Resets Greed settings and window positions, but keeps pages and tracked sets."),
        },
        { type = "header", name = T("Testing / Maintenance") },
        {
            type = "checkbox",
            name = T("Debug loot events"),
            tooltip = T("Print loot events and skip reasons to chat. Use only while testing in group content."),
            getFunc = function()
                self:InitializeDropLogSettings()
                return self.savedVars.dropLog.debugLoot == true
            end,
            setFunc = function(value)
                self:InitializeDropLogSettings()
                self.savedVars.dropLog.debugLoot = value == true
            end,
            default = false,
        },
        {
            type = "button",
            name = T("Test Drop Row"),
            func = function()
                self:AddDropLogTestEntry()
            end,
        },
        {
            type = "button",
            name = T("Clear History"),
            func = function()
                self:InitializeDropLogSettings()
                self.savedVars.dropLog.entries = {}
                self.savedVars.dropLog.scrollOffset = 0
                self:RefreshDropListWindow()
            end,
            warning = T("Clears the visible Drop List history."),
        },
        {
            type = "description",
            title = T("Slash Commands"),
            text = table.concat(slashCommandLines, "\n"),
        },
    }

    lam:RegisterAddonPanel("GreedAddonSettingsPanel", panelData)
    lam:RegisterOptionControls("GreedAddonSettingsPanel", optionsData)
end

function Greed:AnchorRemoveFavoriteWindowToGreed()
    local controls = self.removeControls
    local window = controls and controls.window
    if not window then return end

    local greedWindow = self.controls and self.controls.window or GreedWindow
    window:ClearAnchors()
    if greedWindow and type(greedWindow.IsHidden) == "function" and greedWindow:IsHidden() ~= true then
        window:SetAnchor(CENTER, greedWindow, CENTER, 0, 0)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

function Greed:CreateRemoveFavoriteWindow()
    if self.removeControls then return end

    local window = WINDOW_MANAGER:CreateControl("GreedRemoveFavoriteWindow", GuiRoot, CT_TOPLEVELCONTROL)
    window:SetDimensions(420, 170)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(true)
    window:SetMovable(false)
    window:SetHidden(true)
    CallControlMethod(window, "SetDrawLayer", DL_OVERLAY)
    CallControlMethod(window, "SetDrawTier", DT_HIGH)
    CallControlMethod(window, "SetDrawLevel", 270)

    local backdrop = WINDOW_MANAGER:CreateControl("GreedRemoveFavoriteBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill(window)
    SetBackdropStyle(backdrop, COLORS.window, COLORS.edge)

    local titleBar = WINDOW_MANAGER:CreateControl("GreedRemoveFavoriteTitleBar", window, CT_CONTROL)
    titleBar:SetDimensions(420, 48)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetMouseEnabled(true)

    local title = WINDOW_MANAGER:CreateControl("GreedRemoveFavoriteTitle", window, CT_LABEL)
    title:SetDimensions(380, 28)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 16)
    title:SetFont("ZoFontGameBold")
    title:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])
    title:SetText(T("Remove Set from Greed List"))
    title:SetMouseEnabled(true)

    local message = WINDOW_MANAGER:CreateControl("GreedRemoveFavoriteMessage", window, CT_LABEL)
    message:SetDimensions(380, 48)
    message:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 14)
    message:SetFont("ZoFontGame")
    AllowMultilineLabelText(message, 3)
    message:SetColor(COLORS.text[1], COLORS.text[2], COLORS.text[3], COLORS.text[4])

    local removeButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedRemoveFavoriteConfirm", window, "ZO_DefaultButton")
    removeButton:SetDimensions(100, 30)
    removeButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -128, -18)
    SetButtonText(removeButton, T("Remove"))
    removeButton:SetHandler("OnClicked", function()
        self:ConfirmRemoveFavorite()
    end)

    local cancelButton = WINDOW_MANAGER:CreateControlFromVirtual("GreedRemoveFavoriteCancel", window, "ZO_DefaultButton")
    cancelButton:SetDimensions(100, 30)
    cancelButton:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -18)
    SetButtonText(cancelButton, T("Cancel"))
    cancelButton:SetHandler("OnClicked", function()
        self:HideRemoveFavoriteDialog()
    end)

    self.removeControls = {
        window = window,
        titleBar = titleBar,
        title = title,
        message = message,
        removeButton = removeButton,
        cancelButton = cancelButton,
    }

    self:MakePopupWindowMovable(window, titleBar, title, "removeConfirm")
end

function Greed:ShowRemoveFavoriteDialog(setData)
    if not setData or not setData.rowKey then return end

    self:CreateRemoveFavoriteWindow()
    self.pendingRemoveSetData = setData
    self.pendingRemoveAllSets = false

    local baseName = setData.baseName or setData.name or T("Unknown Set")
    local displayName = setData.isPerfectedRow and self:GetPerfectedDisplayName(baseName, setData.perfectedSetId or setData.setId) or baseName
    if self.removeControls.title then
        self.removeControls.title:SetText(T("Remove Set from Greed List"))
    end
    if self.removeControls.removeButton then
        SetButtonText(self.removeControls.removeButton, T("Remove"))
    end
    self.removeControls.message:SetText(T("Remove %s from this page?", displayName))
    self:AnchorRemoveFavoriteWindowToGreed()
    self.removeControls.window:SetHidden(false)
end

function Greed:GetCurrentPageDisplaySetCount()
    local rows = self.displayFavorites or self:BuildDisplayFavorites() or {}
    return #rows
end

function Greed:ShowRemoveAllSetsDialog()
    self:CreateRemoveFavoriteWindow()

    if self:GetCurrentPageDisplaySetCount() <= 0 then
        SafeAnnounce(T("Greed: This page is already empty."))
        return
    end

    self.pendingRemoveSetData = nil
    self.pendingRemoveAllSets = true

    local pageName = self:GetCurrentPageName() or DEFAULT_PAGE_NAME
    if self.removeControls.title then
        self.removeControls.title:SetText(T("Remove All Sets from Greed List"))
    end
    if self.removeControls.removeButton then
        SetButtonText(self.removeControls.removeButton, T("Remove"))
    end
    self.removeControls.message:SetText(T("Remove all sets from %s? This only clears the current page.", pageName))
    self:AnchorRemoveFavoriteWindowToGreed()
    self.removeControls.window:SetHidden(false)
end

function Greed:HideRemoveFavoriteDialog()
    if self.removeControls and self.removeControls.window then
        self.removeControls.window:SetHidden(true)
    end
    self.pendingRemoveSetData = nil
    self.pendingRemoveAllSets = nil
end

function Greed:RefreshAfterGreedListChanged()
    self:RefreshGridFromSaved()
    if type(self.RefreshSourcesToFarmWindow) == "function" then
        self:RefreshSourcesToFarmWindow()
    end
    if type(self.BuildDropListPageDropdown) == "function" then
        self:BuildDropListPageDropdown()
    end
    if type(self.RefreshDropOptionsState) == "function" then
        self:RefreshDropOptionsState()
    end
end

function Greed:ConfirmRemoveAllSetsFromGreedList()
    local profile = self:GetCurrentTrackingProfile()
    local pageName = self:GetCurrentPageName()
    local pageData = profile and profile.pages and profile.pages[pageName]
    if type(pageData) ~= "table" then
        self:HideRemoveFavoriteDialog()
        return
    end

    pageData.sets = {}
    pageData.removedSets = {}
    pageData.usesDefaults = false

    self:HideRemoveFavoriteDialog()
    self:RefreshAfterGreedListChanged()
end

function Greed:ConfirmRemoveFavorite()
    if self.pendingRemoveAllSets == true then
        self:ConfirmRemoveAllSetsFromGreedList()
        return
    end

    local setData = self.pendingRemoveSetData
    if not setData or not setData.rowKey then
        self:HideRemoveFavoriteDialog()
        return
    end

    if setData.userAdded == true then
        self:GetSavedSets()[setData.rowKey] = nil
        self:SetRowRemoved(setData.rowKey, false)
    else
        self:SetRowRemoved(setData.rowKey, true)
    end

    self:HideRemoveFavoriteDialog()
    self:RefreshAfterGreedListChanged()
end


function Greed:OpenStickerbookScene()
    if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ToggleSceneGroup) == "function" then
        MAIN_MENU_KEYBOARD:ToggleSceneGroup("collectionsSceneGroup", "itemSetsBook")
        return true
    end

    if SCENE_MANAGER and type(SCENE_MANAGER.Show) == "function" then
        SCENE_MANAGER:Show("itemSetsBook")
        return true
    end

    return false
end

function Greed:OpenInStickerbook(setData, column, piece)
    if not setData or not column or not piece then
        SafeAnnounce(T("Greed: Could not identify this item for Stickerbook."))
        return
    end

    local itemLink = piece.itemLink
    if not itemLink or itemLink == "" then
        itemLink = self:ResolveItemLink(setData, column, piece)
    end

    if itemLink and itemLink ~= "" then
        libSets.OpenSetItemCollectionBookForItemLink(itemLink)
        SafeAnnounce(T("Greed: Opening Stickerbook for %s.", self:GetDisplayItemName(setData, column, piece)))
        return
    end

    if self:OpenStickerbookScene() then
        SafeAnnounce(T("Greed: Opened Stickerbook. I could not jump directly to this exact set item."))
        return
    end

    SafeAnnounce(T("Greed: Stickerbook could not be opened from this item."))
end

function Greed:ShowItemMenu(control, setData, column, piece)
    ClearMenu()

    self:AddContextMenuItem(T("Remove Set from Greed List"), function()
        self:ShowRemoveFavoriteDialog(setData)
    end)
    self:AddContextMenuItem("|cFFD66B" .. T("Remove All Sets from Greed List") .. "|r", function()
        self:ShowRemoveAllSetsDialog()
    end)
    self:AddContextMenuItem(T("Edit tracked pieces"), function()
        self:ShowEditTrackedPiecesWindow(setData)
    end)
    self:AddContextMenuItem(T("Move to another page"), function()
        self:ShowMovePageDialog(setData)
    end)
    self:AddContextMenuItem(T("Open in Stickerbook"), function()
        self:OpenInStickerbook(setData, column, piece)
    end)
    self:AddContextMenuItem(T("Post item link to chat"), function()
        self:PostItemLinkToChat(setData, column, piece)
    end)
    self:AddContextMenuItem(T("Copy Item Link"), function()
        if piece.itemLink then
            SafeAnnounce("Greed: " .. piece.itemLink)
        else
            SafeAnnounce(T("Greed: Copy Item Link placeholder - no resolved item link for this cell."))
        end
    end)

    ShowMenu(control)
end

function Greed:AddContextMenuItem(label, callback)
    if AddCustomMenuItem then
        AddCustomMenuItem(label, callback)
    else
        AddMenuItem(label, callback)
    end
end

function Greed:PostItemLinkToChat(setData, column, piece)
    local text = piece.itemLink or string.format("[Greed] %s", self:GetDisplayItemName(setData, column, piece))

    if StartChatInput then
        StartChatInput(text)
    else
        SafeAnnounce(text)
    end
end

function Greed:ToggleWindow()
    if self.controls.window:IsHidden() then
        self:ShowWindow()
    else
        self:HideWindow()
    end
end

function Greed:ShowWindow()
    self.controls.window:SetHidden(false)
    if self.ownedItemIndexDirty == true then
        self:RefreshOwnedItemIndicators()
    end
    self:UpdateDropListMenuVisibility()

    if not self.hasOpenedWindow then
        self:SetRowsScrollOffset(0)
        self.hasOpenedWindow = true
    else
        self:SetRowsScrollOffset(self.rowsScroll and self.rowsScroll.offset or 0)
    end
end

function Greed:HideWindow()
    self:HideEditTrackedPiecesWindow()
    self:HideAddSetWindow()
    self:HideRemoveFavoriteDialog()
    self:HidePageNameDialog()
    self:HideDeletePageDialog()
    self:HideMovePageDialog()
    self:HideDropTraitFilterWindow()
    self:HideDropOptionsWindow()
    self:HideSourcesToFarmWindow()
    self:HideSetsOverviewWindow()
    self.controls.window:SetHidden(true)
    self:UpdateDropListMenuVisibility()
end

function Greed:EnterCursorMode()
    -- Greed is an overlay/reference window. It must never force cursor/UI mode
    -- simply because the main window is visible.
    self.cursorModeOwned = false
end

function Greed:LeaveCursorMode()
    self.cursorModeOwned = false
end

function Greed:OnGameCameraUIModeChanged()
    self.cursorModeOwned = false
    self:UpdateDropListMenuVisibility(true)
    self:RefreshLauncherVisibility()
    self:RefreshTamrielTomesFallbackPolling()
end
