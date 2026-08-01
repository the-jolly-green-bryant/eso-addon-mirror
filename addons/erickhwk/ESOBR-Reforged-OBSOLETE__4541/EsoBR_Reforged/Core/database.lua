local DB = Reforged.DB

DB.Defaults = {
    ShowNPC              = "bren",
    ShowLocations        = "bren",
    ShowCraft            = "bren",
    ShowAbilitiesMenu    = "br",
    ShowAbilitiesTooltip = "bren",
    ShowChampionTooltip  = "bren",
    ShowItemsNamesTooltip    = "bren",
    ShowItemsEnchantsTooltip = "bren",
    ShowItemsTraitsTooltip   = "bren",
    ShowItemsSetsTooltip     = "bren",
    EnglishSearch            = true,
    TradingHouseSearch       = false,
    ShowCollectionsSetsMenu  = "bren",
    ModoGlobal               = "bren",
    IsUpdateNeeded = true,
    Data = {
        ApiVersion   = 0,
        AddonVersion = "",
        Abilities      = {},
        Items          = {},
        Sets           = {},
        SetsNames      = {},
        Traits         = {},
        Potions        = {},
        Locations      = {},
        CraftAbilities = {},
        Parts          = {},
        Prefixes       = {},
        Affixes        = {},
        EnchantPrefixes = {},
    },
}

DB.DefaultsChar = {
    IsFirstLaunch = true,
}

function DB.init()
    Reforged.Settings = ZO_SavedVars:NewAccountWide(
        "EsoBRReforgedVariables", 1, nil, DB.Defaults)
    Reforged.SettingsChar = ZO_SavedVars:New(
        "EsoBRReforgedVariables", 1, "character", DB.DefaultsChar)
end

function DB.isStale()
    local d = Reforged.Settings.Data
    return d.ApiVersion ~= GetAPIVersion()
        or d.AddonVersion ~= Reforged.VERSION
end

function DB.get(key)
    return Reforged.Settings[key]
end

function DB.set(key, value)
    Reforged.Settings[key] = value
end

function DB.clear()
    Reforged.Settings.Data = ZO_DeepTableCopy(DB.Defaults.Data)
    Reforged.Settings.IsUpdateNeeded = true
end
