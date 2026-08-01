--[[
=============================================================================
 AuctionHouse - Settings
 Addon settings panel using LibAddonMenu-2.0 (LAM).
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils

AH.Settings = {}
local Settings = AH.Settings

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function Settings.Initialize()
    Utils.Debug("Settings: Initializing")

    local LAM = LibAddonMenu2
    if not LAM then
        Utils.Debug("Settings: LibAddonMenu-2.0 not available, skipping settings panel")
        return
    end

    local panelData = {
        type = "panel",
        name = AH.displayName,
        displayName = Utils.Colorize(AH.displayName, AH.Colors.GOLD),
        author = AH.author,
        version = AH.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(AH.name .. "_Settings", panelData)

    local sv = AH.savedVars.settings

    local optionsData = {
        -- ==================== General ====================
        {
            type = "header",
            name = "General",
        },

        -- ==================== Tooltip ====================
        {
            type = "header",
            name = "Tooltip Integration",
        },
        {
            type = "checkbox",
            name = "Show Prices in Tooltips",
            tooltip = "Display Tamriel Auction House price data when hovering over items.",
            getFunc = function() return sv.showPriceInTooltip end,
            setFunc = function(v) sv.showPriceInTooltip = v end,
            default = AH.DefaultSavedVars.settings.showPriceInTooltip,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = "Show Suggested Price",
            tooltip = "Show the suggested sell price in tooltips.",
            getFunc = function() return sv.tooltipShowSuggested end,
            setFunc = function(v) sv.tooltipShowSuggested = v end,
            default = AH.DefaultSavedVars.settings.tooltipShowSuggested,
            disabled = function() return not sv.showPriceInTooltip end,
        },
        {
            type = "checkbox",
            name = "Show Average Price",
            tooltip = "Show the average listing price in tooltips.",
            getFunc = function() return sv.tooltipShowAverage end,
            setFunc = function(v) sv.tooltipShowAverage = v end,
            default = AH.DefaultSavedVars.settings.tooltipShowAverage,
            disabled = function() return not sv.showPriceInTooltip end,
        },
        {
            type = "checkbox",
            name = "Show Price Range",
            tooltip = "Show the min/max price range in tooltips.",
            getFunc = function() return sv.tooltipShowRange end,
            setFunc = function(v) sv.tooltipShowRange = v end,
            default = AH.DefaultSavedVars.settings.tooltipShowRange,
            disabled = function() return not sv.showPriceInTooltip end,
        },
        {
            type = "checkbox",
            name = "Show Listing Volume",
            tooltip = "Show how many listings were found for this item.",
            getFunc = function() return sv.tooltipShowVolume end,
            setFunc = function(v) sv.tooltipShowVolume = v end,
            default = AH.DefaultSavedVars.settings.tooltipShowVolume,
            disabled = function() return not sv.showPriceInTooltip end,
        },

        -- ==================== Data Management ====================
        {
            type = "header",
            name = "Data Management",
        },
        {
            type = "slider",
            name = "Price History Retention (Days)",
            tooltip = "How many days of price history to keep. Older data is automatically cleaned up.",
            min = 7,
            max = 90,
            step = 1,
            getFunc = function() return sv.maxPriceHistoryDays end,
            setFunc = function(v) sv.maxPriceHistoryDays = v end,
            default = AH.DefaultSavedVars.settings.maxPriceHistoryDays,
        },
        {
            type = "button",
            name = "Clear Local Price Cache",
            tooltip = "Delete all locally stored price history. Server data will be re-downloaded on next sync.",
            func = function()
                AH.savedVars.priceHistory = {}
                Utils.Print("Local price cache cleared.")
            end,
            isDangerous = true,
            warning = "This will delete all locally stored price data!",
        },
        {
            type = "button",
            name = "Clear Outgoing Queue",
            tooltip = "Clear any pending data waiting to be uploaded. Use if you suspect corrupted data.",
            func = function()
                AH.savedVars.outgoing.listings = {}
                AH.savedVars.outgoing.sales = {}
                Utils.Print("Outgoing queue cleared.")
            end,
            isDangerous = true,
            warning = "Pending listings and sales will be lost!",
        },

        -- ==================== Display ====================
        {
            type = "header",
            name = "Display",
        },
        {
            type = "checkbox",
            name = "Compact Mode",
            tooltip = "Use a more compact layout with smaller rows in the results list.",
            getFunc = function() return sv.compactMode end,
            setFunc = function(v) sv.compactMode = v end,
            default = AH.DefaultSavedVars.settings.compactMode,
        },

        -- ==================== Advanced ====================
        {
            type = "header",
            name = "Advanced",
        },
        {
            type = "checkbox",
            name = "Debug Mode",
            tooltip = "Enable verbose debug messages in chat. For troubleshooting only.",
            getFunc = function() return sv.debug end,
            setFunc = function(v) sv.debug = v end,
            default = AH.DefaultSavedVars.settings.debug,
        },

        -- ==================== Status Info ====================
        {
            type = "header",
            name = "Status",
        },
        {
            type = "description",
            text = function()
                local status = AH.DataManager.GetSyncStatus()
                local lines = {
                    string.format("Desktop Client: %s",
                        status.isClientConnected
                        and Utils.Colorize("Connected", AH.Colors.POSITIVE)
                        or Utils.Colorize("Not Connected", AH.Colors.RED)),
                    string.format("Client Version: %s", status.clientVersion),
                    string.format("Last Sync: %s", Utils.FormatTimestamp(status.lastSync)),
                    string.format("Total Listings: %s",
                        Utils.FormatNumber(status.totalListings)),
                    string.format("Pending Upload: %d listings, %d sales",
                        status.pendingListings, status.pendingSales),
                    string.format("Total Synced: %s up / %s down",
                        Utils.FormatNumber(status.totalUploaded),
                        Utils.FormatNumber(status.totalDownloaded)),
                }
                return table.concat(lines, "\n")
            end,
        },
    }

    LAM:RegisterOptionControls(AH.name .. "_Settings", optionsData)

    Utils.Debug("Settings: Initialized")
end
