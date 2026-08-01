--[[
=============================================================================
 AuctionHouse - Constants
 Enumerations, defaults, item quality mappings, and configuration values.
=============================================================================
]]--

d("[AuctionHouse] Constants.lua loading...")

AuctionHouse = AuctionHouse or {}
local AH = AuctionHouse

AH.name = "AuctionHouse"
AH.displayName = "Tamriel Auction House"
AH.version = "1.0.0"
AH.author = "AuctionHouse Team"
AH.savedVarsVersion = 1

---------------------------------------------------------------------------
--  Color Definitions
---------------------------------------------------------------------------
AH.Colors = {
    WHITE       = "FFFFFF",
    GRAY        = "999999",
    GREEN       = "00FF00",
    BLUE        = "3399FF",
    PURPLE      = "AA33FF",
    GOLD        = "FFAA00",
    ORANGE      = "FF6600",
    RED         = "FF3333",
    YELLOW      = "FFFF33",
    HEADER      = "CCCCCC",
    HIGHLIGHT   = "FFD700",
    POSITIVE    = "44DD44",
    NEGATIVE    = "DD4444",
    NEUTRAL     = "AAAAAA",
}

---------------------------------------------------------------------------
--  Item Quality Colors (matches ESO quality tiers)
---------------------------------------------------------------------------
AH.QualityColors = {
    [ITEM_DISPLAY_QUALITY_TRASH]        = "656565",
    [ITEM_DISPLAY_QUALITY_NORMAL]       = "FFFFFF",
    [ITEM_DISPLAY_QUALITY_MAGIC]        = "2DC50E",
    [ITEM_DISPLAY_QUALITY_ARCANE]       = "3A92FF",
    [ITEM_DISPLAY_QUALITY_ARTIFACT]     = "A02EF7",
    [ITEM_DISPLAY_QUALITY_LEGENDARY]    = "EECA2A",
    [ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = "FF7700",
}

AH.QualityNames = {
    [ITEM_DISPLAY_QUALITY_TRASH]        = "Trash",
    [ITEM_DISPLAY_QUALITY_NORMAL]       = "Normal",
    [ITEM_DISPLAY_QUALITY_MAGIC]        = "Fine",
    [ITEM_DISPLAY_QUALITY_ARCANE]       = "Superior",
    [ITEM_DISPLAY_QUALITY_ARTIFACT]     = "Epic",
    [ITEM_DISPLAY_QUALITY_LEGENDARY]    = "Legendary",
    [ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = "Mythic",
}

---------------------------------------------------------------------------
--  Guild Store Time Remaining Enums
---------------------------------------------------------------------------
AH.TimeRemaining = {
    [1] = "< 10 minutes",
    [2] = "< 1 hour",
    [3] = "< 6 hours",
    [4] = "< 12 hours",
    [5] = "< 1 day",
    [6] = "< 2 days",
    [7] = "< 5 days",
    [8] = "< 10 days",
    [9] = "< 30 days",
    [10] = "> 30 days",
}

---------------------------------------------------------------------------
--  UI Configuration
---------------------------------------------------------------------------
AH.UIConfig = {
    -- Main window dimensions
    WINDOW_WIDTH            = 900,
    WINDOW_HEIGHT           = 650,
    WINDOW_MIN_WIDTH        = 700,
    WINDOW_MIN_HEIGHT       = 500,

    -- Results list
    ROW_HEIGHT              = 36,
    VISIBLE_ROWS            = 14,
    ICON_SIZE               = 32,

    -- Tooltip delay (ms)
    TOOLTIP_DELAY           = 250,

    -- Search debounce (ms)
    SEARCH_DEBOUNCE         = 300,

    -- Maximum search results displayed
    MAX_DISPLAY_RESULTS     = 500,
}

---------------------------------------------------------------------------
--  Default SavedVariables
---------------------------------------------------------------------------
AH.DefaultSavedVars = {
    -- Outgoing data for the desktop client to upload
    outgoing = {
        listings = {},
        sales = {},
        last_upload_time = 0,
        last_upload_status = "",
    },

    -- Incoming data from the desktop client (server data)
    incoming = {
        listings = {},
        price_summaries = {},
        server_timestamp = 0,
        download_time = 0,
        count = 0,
    },

    -- Metadata shared between addon and client
    metadata = {
        client_version = "",
        last_sync = 0,
        total_uploaded = 0,
        total_downloaded = 0,
        sync_count = 0,
    },

    -- Local price history cache
    priceHistory = {},

    -- User scan history
    scanHistory = {},

    -- UI state persistence
    ui = {
        windowPosition = { x = 200, y = 100 },
        windowSize = { width = 900, height = 650 },
        lastSearchText = "",
        sortColumn = "unitPrice",
        sortAscending = true,
        filters = {
            quality = -1,       -- -1 = all
            levelMin = 0,
            levelMax = 50,
            cpMin = 0,
            cpMax = 160,
            priceMin = 0,
            priceMax = 0,       -- 0 = no max
            guildName = "",
        },
    },

    -- Settings
    settings = {
        showPriceInTooltip = true,
        tooltipShowAverage = true,
        tooltipShowRange = true,
        tooltipShowSuggested = true,
        tooltipShowVolume = true,
        enableKeybind = true,
        debug = false,
        maxPriceHistoryDays = 30,
        compactMode = false,
    },

    -- Favorites / watchlist (server-synced)
    watchlist = {},

    -- Trusted sellers (server-synced)
    trustedSellers = {},

    -- Sale stats from server
    saleStats = {},

    -- Daily deals from server
    deals = {},

    -- Seller ratings cache
    sellerRatings = {},

    -- Blacklisted sellers
    blacklist = {},
}

---------------------------------------------------------------------------
--  Item Category Filters (maps to ESO item filter types)
---------------------------------------------------------------------------
AH.CategoryFilters = {
    { name = "All Items",           filterType = nil },
    { name = "Weapons",             filterType = ITEMFILTERTYPE_WEAPONS },
    { name = "Armor",               filterType = ITEMFILTERTYPE_ARMOR },
    { name = "Jewelry",             filterType = ITEMFILTERTYPE_JEWELRY },
    { name = "Consumables",         filterType = ITEMFILTERTYPE_CONSUMABLE },
    { name = "Materials",           filterType = ITEMFILTERTYPE_CRAFTING },
    { name = "Furnishings",         filterType = ITEMFILTERTYPE_FURNISHING },
    { name = "Style Materials",     filterType = ITEMFILTERTYPE_STYLE_MATERIAL },
    { name = "Trait Gems",          filterType = ITEMFILTERTYPE_TRAIT_ITEM },
    { name = "Companion Items",     filterType = ITEMFILTERTYPE_COMPANION },
    { name = "Misc",                filterType = ITEMFILTERTYPE_MISCELLANEOUS },
}

---------------------------------------------------------------------------
--  Sort Columns
---------------------------------------------------------------------------
AH.SortColumns = {
    { key = "name",         header = "Item",            width = 260 },
    { key = "unitPrice",    header = "Unit Price",      width = 120 },
    { key = "totalPrice",   header = "Total Price",     width = 120 },
    { key = "quantity",     header = "Qty",             width = 50  },
    { key = "quality",      header = "Quality",         width = 90  },
    { key = "level",        header = "Level",           width = 80  },
    { key = "seller",       header = "Seller",          width = 220 },
    { key = "timeRemaining",header = "Time Left",       width = 120 },
}

---------------------------------------------------------------------------
--  Events (custom addon events)
---------------------------------------------------------------------------
AH.Events = {
    DATA_UPDATED            = "AH_DATA_UPDATED",
    INCOMING_DATA_READY     = "AH_INCOMING_DATA_READY",
    SEARCH_RESULTS_READY    = "AH_SEARCH_RESULTS_READY",
    PRICE_DATA_UPDATED      = "AH_PRICE_DATA_UPDATED",
    UI_REFRESH_NEEDED       = "AH_UI_REFRESH_NEEDED",
}

---------------------------------------------------------------------------
--  Slash Commands
---------------------------------------------------------------------------
AH.SlashCommands = {
    "/ah",
    "/auctionhouse",
    "/auction",
}
