RanckorsBaggage = RanckorsBaggage or {
    name      = "RanckorsBaggage",
    version   = "v3.1.1",
    devURL    = "https://illyriat.com/",
    namespace = "RanckorsBaggage",
}

local RB = RanckorsBaggage
RB.LAM = LibAddonMenu2

RB.defaults = {
    position        = { x = 0, y = 100 },
    backgroundStyle = "clear",
    uiScale         = 100,
    size            = nil,
    displaySettings = {
        -- Player currencies
        [CURT_MONEY]              = true,
        [CURT_ALLIANCE_POINTS]    = true,
        [CURT_TELVAR_STONES]      = true,
        -- [CURT_EVENT_TICKETS]   = true, -- Deprecated
        [CURT_TOME_POINT_CACHES]  = true,
        [CURT_TOME_POINTS]        = true,
        [CURT_TRADE_BARS]         = true,
        [CURT_TOME_TOKENS]        = true,
        [CURT_UNDAUNTED_KEYS]     = true,
        [CURT_CHAOTIC_CREATIA]    = true,
        [CURT_CROWN_GEMS]         = true,
        [CURT_IMPERIAL_FRAGMENTS] = true,
        [CURT_ENDEAVOR_SEALS]     = true,
        [CURT_WRIT_VOUCHERS]      = true,
        [CURT_ARCHIVAL_FORTUNES]  = true,
        [CURT_CROWNS]             = true,

        -- Banked currencies
        BankedGold           = true,
        BankedAlliancePoints = true,
        BankedTelVar         = true,
        BankedWritVouchers   = true,

        -- Bags
        BagSpace             = true,
        BankSpace            = true,
    },
}

RB.fonts = {
    pc = {
        label   = "ZoFontGameSmall",
        heading = "ZoFontWinH1",
        button  = "ZoFontGameSmall",
        value   = "ZoFontGameLarge",
        title   = "ZoFontWinH1",
    },
    console = {
        label   = "ZoFontGamepad16",
        heading = "ZoFontGamepad18",
        button  = "ZoFontGamepad16",
        value   = "ZoFontGamepad18",
        title   = "ZoFontGamepadBold18",
    }
}

RB.ICONS = {
    GOLD              = "/esoui/art/currency/gold_mipmap.dds",
    AP                = "/esoui/art/currency/alliancepoints.dds",
    TELVAR            = "/esoui/art/currency/telvar_mipmap.dds",
    -- EVENT_TICKET    = "/esoui/art/currency/icon_eventticket_loot.dds",
    TOME_POINT_CACHES = "/esoui/art/currency/u49_tt_cacheoftomepoints_32.dds",
    TOME_POINTS       = "/esoui/art/currency/u49_tt_tomepoints_32.dds",
    TRADE_BARS        = "/esoui/art/currency/u49_TT_TradeBars_32.dds",
    TOME_TOKENS       = "/esoui/art/currency/u49_tt_premiumtomepoints_32.dds",
    UNDAUNTED_KEY     = "/esoui/art/currency/undauntedkey.dds",
    TRANSMUTE         = "/esoui/art/currency/currency_seedcrystal_32.dds",
    CROWN_GEMS        = "/esoui/art/currency/currency_crown_gems.dds",
    IMPERIAL_FRAGMENT = "/esoui/art/currency/currency_imperial_trophy_key_32.dds",
    SEALS             = "/esoui/art/currency/currency_seals_of_endeavor_32.dds",
    WRIT_VOUCHER      = "/esoui/art/icons/icon_writvoucher.dds",
    ARCHIVAL          = "/esoui/art/currency/archivalfragments_32.dds",
    CROWNS            = "/esoui/art/icons/store_crowns.dds",
    BAG               = "/esoui/art/tooltips/icon_bag.dds",
    BANK              = "/esoui/art/icons/servicemappins/servicepin_bank.dds",
    LINK              = "/esoui/art/help/help_tabicon_cs_up.dds",
}

RB.COLORS = {
    GOLD       = "|cFFD700",
    AP         = "|c50C878",
    TELVAR     = "|cADD8E6",
    UNDAUNTED  = "|cB5A642",
    TRANSMUTE  = "|c8A2BE2",
    CROWN_GEMS = "|cE883E8",
    IMPERIAL   = "|c87CEEB",
    SEALS      = "|c87CEEB",
    WRIT       = "|cFFA500",
    ARCHIVAL   = "|c800080",
    CROWNS     = "|cFFFF00",
    NORMAL     = "|cFFFFFF",
    WARNING    = "|cFFA500",
    CRITICAL   = "|cFF0000",
    SECTION    = "|cCCCCCC",
    VERSION    = "|c888888",
}

RB.CURRENCY_NAMES = {
    [CURT_MONEY]              = "Gold",
    [CURT_ALLIANCE_POINTS]    = "Alliance Points",
    [CURT_TELVAR_STONES]      = "Tel Var Stones",
    -- [CURT_EVENT_TICKETS]   = "Event Tickets",
    [CURT_TOME_POINT_CACHES]  = "Caches of Tome Points",
    [CURT_TOME_POINTS]        = "Tome Points",
    [CURT_TRADE_BARS]         = "Trade Bars",
    [CURT_TOME_TOKENS]        = "Premium Tome Tokens",
    [CURT_UNDAUNTED_KEYS]     = "Undaunted Keys",
    [CURT_CHAOTIC_CREATIA]    = "Transmute Crystals",
    [CURT_CROWN_GEMS]         = "Crown Gems",
    [CURT_IMPERIAL_FRAGMENTS] = "Imperial Fragments",
    [CURT_ENDEAVOR_SEALS]     = "Seals of Endeavor",
    [CURT_WRIT_VOUCHERS]      = "Writ Vouchers",
    [CURT_ARCHIVAL_FORTUNES]  = "Archival Fortunes",
    [CURT_CROWNS]             = "Crowns",
}

RB.baseWidth  = nil
RB.baseHeight = nil
RB.hasShownCurrencyWarning = false
RB._pendingUpdate = false