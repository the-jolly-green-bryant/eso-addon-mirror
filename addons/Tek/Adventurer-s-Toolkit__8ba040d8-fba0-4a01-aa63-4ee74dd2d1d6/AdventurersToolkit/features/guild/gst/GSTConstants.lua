-- ============================================
-- GST CONSTANTS AND SHARED STATE
-- ============================================
-- Exposes constants, state tables, and helpers for other gst/*.lua files.

NWT.GSTConstants = NWT.GSTConstants or {}
local GC = NWT.GSTConstants

-- Category lookup table for massive performance boost
GC.itemTypeToCategory = {
    [ITEMTYPE_REAGENT] = "Reagents",
    [ITEMTYPE_POISON_BASE] = "Solvents",
    [ITEMTYPE_POTION_BASE] = "Solvents",
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = "Raw Metal",
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = "Refined Metal",
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = "Tempers",
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = "Raw Cloth/Leather",
    [ITEMTYPE_CLOTHIER_MATERIAL] = "Refined Cloth",
    [ITEMTYPE_CLOTHIER_BOOSTER] = "Tannins",
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = "Raw Wood",
    [ITEMTYPE_WOODWORKING_MATERIAL] = "Refined Wood",
    [ITEMTYPE_WOODWORKING_BOOSTER] = "Resins",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = "Raw Jewelry",
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = "Refined Jewelry",
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = "Jewelry Plating",
    [ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER] = "Jewelry Plating",
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = "Aspect Runes",
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = "Essence Runes",
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = "Potency Runes",
    [ITEMTYPE_INGREDIENT] = "Ingredients",
    [ITEMTYPE_FOOD] = "Food",
    [ITEMTYPE_DRINK] = "Drinks",
    [ITEMTYPE_STYLE_MATERIAL] = "Style Mats",
    [ITEMTYPE_ARMOR_TRAIT] = "Trait Stones",
    [ITEMTYPE_WEAPON_TRAIT] = "Trait Stones",
    [ITEMTYPE_JEWELRY_TRAIT] = "Jewelry Traits",
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = "Jewelry Traits",
    [ITEMTYPE_RAW_MATERIAL] = "Raw Mats",
    [ITEMTYPE_FURNISHING] = "Furnishings",
    [ITEMTYPE_FURNISHING_MATERIAL] = "Furnishing Mats",
    [ITEMTYPE_ARMOR] = "Armor",
    [ITEMTYPE_WEAPON] = "Weapons",
    [ITEMTYPE_GLYPH_ARMOR] = "Armor Glyphs",
    [ITEMTYPE_GLYPH_JEWELRY] = "Jewelry Glyphs",
    [ITEMTYPE_GLYPH_WEAPON] = "Weapon Glyphs",
    [ITEMTYPE_POTION] = "Potions",
    [ITEMTYPE_POISON] = "Poisons",
    [ITEMTYPE_RECIPE] = "Recipes",
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = "Motifs",
    [ITEMTYPE_MASTER_WRIT] = "Master Writs",
    [ITEMTYPE_SOUL_GEM] = "Soul Gems",
    [ITEMTYPE_TREASURE] = "Treasure",
    [ITEMTYPE_TROPHY] = "Trophies",
    [ITEMTYPE_CONTAINER] = "Containers",
    [ITEMTYPE_FISH] = "Fish",
    [ITEMTYPE_SIEGE] = "Siege",
}

-- Time period constants (seconds)
GC.TIME_PERIODS = {
    { key = "month", seconds = 30 * 86400, name = "30 Days" },
    { key = "prevWeek", seconds = 14 * 86400, minAge = 7 * 86400, name = "Last Week" },
    { key = "week", seconds = 7 * 86400, name = "7 Days" },
    { key = "day", seconds = 86400, name = "24 Hours" },
}

-- Mutable shared state (accessed by GSTScan, GSTCommands, GSTEventProcessing)
NWT.GST = NWT.GST or {
    scanning = false,
    eventQueue = {},
    isProcessingQueue = false,
    requestQueue = {},
    activeRequest = nil,
    lastRequestTime = 0,
    scanGuildId = nil,
    scanComplete = false,
    scanEventCount = 0,
    bankEventCount = 0,
    lastKioskName = "",
    loadingGuilds = false,
    categoryCallbackRegistered = false,
    currentScanGuildId = nil,
    displayQueue = {},
    displayIndex = 1,
    scanData = nil,
}

local function CreateEmptyPeriodData()
    return {
        sellers = {},
        buyers = {},
        items = {},
        categories = {},
        mySales = 0,
        myGold = 0,
        myTax = 0,
        myBestSale = 0,
        myBestItem = "",
        myItems = {},
        totalSales = 0,
        totalGold = 0,
        totalTax = 0,
        deposits = 0,
        withdrawals = 0,
        traderCost = 0,
        kioskBids = 0,
        kioskRefunds = 0,
        bigTicketCount = 0,
        bigTicketGold = 0,
        depositorCount = 0,
        depositors = {},
    }
end

function GC.ClearScanData()
    local gst = NWT.GST
    gst.scanData = {
        month = CreateEmptyPeriodData(),
        prevWeek = CreateEmptyPeriodData(),
        week = CreateEmptyPeriodData(),
        day = CreateEmptyPeriodData(),
        oldestSale = 0,
        newestSale = 0,
        kioskName = "",
    }
    gst.scanEventCount = 0
end

function GC.GetItemTypeCategory(itemType)
    return GC.itemTypeToCategory[itemType] or "Other"
end
