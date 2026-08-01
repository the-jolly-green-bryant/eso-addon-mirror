Reforged = {}

Reforged.NAME        = "EsoBR_Reforged"
Reforged.VERSION     = "1.2.0"
Reforged.API_VERSION = 101050

Reforged.FLAGS = { "en", "br" }

Reforged.MODES = {
    BR   = "br",
    BREN = "bren",
    ENBR = "enbr",
    EN   = "en",
}

Reforged.DROPDOWN_LABELS = {
    ["br"]   = "Somente Português",
    ["bren"] = "Português+Inglês",
    ["enbr"] = "Inglês+Português",
    ["en"]   = "Somente Inglês",
}

-- Color applied to the secondary-language text in double-name display
Reforged.COLOR_SECONDARY = "|ca99e83"
Reforged.COLOR_RESET     = "|r"

-- Game strings backed up before any modification by modules
Reforged.StringsBackup = {
    ["SI_ABILITY_NAME_AND_RANK"]                     = GetString(SI_ABILITY_NAME_AND_RANK),
    ["SI_ABILITY_TOOLTIP_NAME"]                      = GetString(SI_ABILITY_TOOLTIP_NAME),
    ["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"]      = GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED),
    ["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"]         = GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER),
    ["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"] = GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER),
    ["SI_ITEM_FORMAT_STR_SET_NAME"]                  = GetString(SI_ITEM_FORMAT_STR_SET_NAME),
    ["SI_TOOLTIP_ITEM_NAME"]                         = GetString(SI_TOOLTIP_ITEM_NAME),
    ["SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT"]         = GetString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT),
}

-- Sub-namespaces populated by their respective Core files
Reforged.Data    = {}
Reforged.DB      = {}
Reforged.Modules = {}
Reforged.Hooks   = {}
Reforged.Dump    = {}
Reforged.UI      = { HUD = {}, Settings = {} }
