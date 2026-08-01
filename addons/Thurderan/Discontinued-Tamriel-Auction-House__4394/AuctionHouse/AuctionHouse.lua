--[[
=============================================================================
 AuctionHouse - Main Entry Point
 Independent auction house system. No guild store scanning.
=============================================================================
]]--

AuctionHouse = AuctionHouse or {}
local AH = AuctionHouse

---------------------------------------------------------------------------
--  Addon Loaded
---------------------------------------------------------------------------

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= "AuctionHouse" then return end
    EVENT_MANAGER:UnregisterForEvent("AuctionHouse_Loaded", EVENT_ADD_ON_LOADED)

    local Utils = AH.Utils
    if not Utils then
        d("[AuctionHouse] ERROR: Utilities module failed to load.")
        return
    end

    -- SavedVariables
    AH.savedVars = ZO_SavedVars:NewAccountWide(
        "AuctionHouse_SavedVariables",
        AH.savedVarsVersion, nil, AH.DefaultSavedVars)

    AH.MigrateSavedVars()

    -- Signal the desktop client to do a fresh pull
    AH.savedVars.metadata.requestSync = true

    -- Initialize modules (no Scanner)
    if AH.DataManager and AH.DataManager.Initialize then AH.DataManager.Initialize() end
    if AH.PriceTracker and AH.PriceTracker.Initialize then AH.PriceTracker.Initialize() end
    if AH.SearchEngine and AH.SearchEngine.Initialize then AH.SearchEngine.Initialize() end
    if AH.UI and AH.UI.Initialize then AH.UI.Initialize() end
    if AH.Settings and AH.Settings.Initialize then AH.Settings.Initialize() end
    if AH.ListingManager and AH.ListingManager.Initialize then AH.ListingManager.Initialize() end
    if AH.ListingUI and AH.ListingUI.Initialize then AH.ListingUI.Initialize() end
    if AH.Features and AH.Features.Initialize then AH.Features.Initialize() end

    -- Hook tooltips and context menus for new features
    if AH.Features then
        AH.Features.HookContextMenuExtras()
        AH.Features.HookTooltips()
    end

    -- Slash commands
    SLASH_COMMANDS["/ah"] = AH.OnSlashCommand
    SLASH_COMMANDS["/auctionhouse"] = AH.OnSlashCommand
    SLASH_COMMANDS["/auction"] = AH.OnSlashCommand

    Utils.Print("%s v%s loaded. Type %s to open.",
        AH.displayName, AH.version,
        Utils.Colorize("/ah", AH.Colors.HIGHLIGHT))
end

---------------------------------------------------------------------------
--  Slash Commands
---------------------------------------------------------------------------

function AH.OnSlashCommand(input)
    local Utils = AH.Utils
    if not Utils then d("[AuctionHouse] Not loaded.") return end

    local args = {}
    for word in string.gmatch(input or "", "%S+") do
        table.insert(args, string.lower(word))
    end
    local cmd = args[1] or ""

    if cmd == "" or cmd == "open" or cmd == "show" then
        if AH.UI then AH.UI.Toggle() end

    elseif cmd == "sell" then
        local price = tonumber(args[2])
        if price and price > 0 and AH._pendingListItem then
            AH.ListingManager.ConfirmListing(AH._pendingListItem, price, AH._pendingListItem.stackCount, 3)
            AH._pendingListItem = nil
        elseif not AH._pendingListItem then
            Utils.Print("No item pending. Right-click an item in inventory first.")
        else
            Utils.Print("Usage: /ah sell <price>")
        end

    elseif cmd == "send" then
        if args[2] and AH.ListingManager then
            AH.ListingManager.SendCOD(args[2])
        else
            Utils.Print("Usage: /ah send <listing_id>")
        end

    elseif cmd == "codqueue" or cmd == "pending" then
        AH.PrintCODQueue()

    elseif cmd == "mylistings" or cmd == "listings" then
        AH.PrintMyListings()

    elseif cmd == "purchases" then
        AH.PrintMyPurchases()

    elseif cmd == "cancel" then
        if args[2] and AH.ListingManager then
            AH.ListingManager.CancelListing(args[2])
        else
            Utils.Print("Usage: /ah cancel <listing_id>")
        end

    elseif cmd == "release" then
        if args[2] and AH.ListingManager then
            AH.ListingManager.ReleaseListing(args[2])
        else
            Utils.Print("Usage: /ah release <listing_id>")
            Utils.Print("Releases a stuck purchase back to the market.")
        end

    elseif cmd == "cancelbuy" then
        if args[2] and AH.ListingManager then
            AH.ListingManager.CancelPurchase(args[2])
        else
            Utils.Print("Usage: /ah cancelbuy <listing_id>")
            Utils.Print("Cancels your purchase (counts toward cancellation limit).")
        end

    elseif cmd == "cancelall" then
        if AH.ListingManager then
            AH.ListingManager.CancelAllListings()
        end

    elseif cmd == "search" then
        local query = string.sub(input, #cmd + 2)
        if AH.UI then
            AH.UI.Show()
            if AH.UI.searchInput and query ~= "" then
                AH.UI.searchInput:SetText(query)
                AH.UI.ExecuteSearch()
            end
        end

    elseif cmd == "status" then
        AH.PrintStatus()

    elseif cmd == "watchlist" then
        AH.PrintWatchlist()

    elseif cmd == "watch" then
        local itemName = string.sub(input, #cmd + 2):gsub("^%s+", "")
        if itemName == "" then
            Utils.Print("Usage: /ah watch <item name>")
        elseif AH.Features then
            -- Search for the item to get its ID
            local allListings = AH.DataManager and AH.DataManager.GetAllListings() or {}
            local found = false
            for _, l in ipairs(allListings) do
                if l.itemName and l.itemName:lower():find(itemName:lower(), 1, true) then
                    AH.Features.WatchlistAdd(l.itemName, l.itemId, 0)
                    found = true
                    break
                end
            end
            if not found then
                Utils.Print("Item not found in current listings. Try opening the AH and searching first.")
            end
        end

    elseif cmd == "unwatch" then
        local itemName = string.sub(input, #cmd + 2):gsub("^%s+", "")
        if AH.Features then
            local removed = false
            for itemId, w in pairs(AH.savedVars.watchlist or {}) do
                if w.itemName and w.itemName:lower():find(itemName:lower(), 1, true) then
                    AH.Features.WatchlistRemove(itemId)
                    removed = true
                    break
                end
            end
            if not removed then Utils.Print("Item not found on watchlist.") end
        end

    elseif cmd == "trust" then
        local seller = string.sub(input, #cmd + 2):gsub("^%s+", "")
        if seller == "" then
            Utils.Print("Usage: /ah trust <player name>")
        elseif AH.Features then
            AH.Features.TrustSeller(seller)
        end

    elseif cmd == "untrust" then
        local seller = string.sub(input, #cmd + 2):gsub("^%s+", "")
        if seller == "" then
            Utils.Print("Usage: /ah untrust <player name>")
        elseif AH.Features then
            AH.Features.UntrustSeller(seller)
        end

    elseif cmd == "deals" then
        if AH.UI then
            AH.UI.Show()
            AH.UI.SwitchTab("deals")
        end

    elseif cmd == "stats" then
        AH.PrintSaleStats()

    elseif cmd == "relist" then
        if args[2] and AH.Features then
            AH.Features.QuickRelist(args[2])
        else
            Utils.Print("Usage: /ah relist <listing_id>")
        end

    elseif cmd == "storefront" or cmd == "shop" then
        local seller = string.sub(input, #cmd + 2):gsub("^%s+", "")
        if seller == "" then
            Utils.Print("Usage: /ah storefront <seller name>")
        elseif AH.UI and AH.Features then
            AH.UI.Show()
            AH.UI.ShowStorefront(seller)
        end

    elseif cmd == "debug" then
        AH.savedVars.settings.debug = not AH.savedVars.settings.debug
        Utils.Print("Debug: %s", AH.savedVars.settings.debug and "ON" or "OFF")

    elseif cmd == "refresh" then
        Utils.Print("Refreshing auction data...")
        ReloadUI("ingame")

    elseif cmd == "help" then
        AH.PrintHelp()

    else
        Utils.Print("Unknown command. Type /ah help")
    end
end

---------------------------------------------------------------------------
--  Print Functions
---------------------------------------------------------------------------

function AH.PrintHelp()
    local Utils = AH.Utils
    if not Utils then return end
    Utils.Print("=== Tamriel Auction House Commands ===")
    Utils.Print("/ah - Toggle window")
    Utils.Print("/ah search <query> - Search for items")
    Utils.Print("/ah mylistings - Your active listings")
    Utils.Print("/ah codqueue - Items to COD to buyers")
    Utils.Print("/ah purchases - Your purchase history")
    Utils.Print("/ah status - Sync status")
    Utils.Print("/ah stats - 7-day sale & purchase stats")
    Utils.Print("/ah watchlist - Price watchlist")
    Utils.Print("/ah watch <name> - Watch for item listings")
    Utils.Print("/ah unwatch <name> - Stop watching item")
    Utils.Print("/ah deals - Browse daily deals (below market)")
    Utils.Print("/ah trust <name> - Add trusted seller")
    Utils.Print("/ah untrust <name> - Remove trusted seller")
    Utils.Print("/ah storefront <name> - View seller's listings")
    Utils.Print("/ah relist <id> - Quick relist expired listing")
    Utils.Print("/ah release <id> - Release stuck purchase")
    Utils.Print("/ah cancelbuy <id> - Cancel purchase")
    Utils.Print("/ah cancelall - Cancel ALL your listings")
    Utils.Print("/ah refresh - Reload for latest data")
    Utils.Print("/ah debug - Toggle debug")
    Utils.Print("")
    Utils.Print("To sell: right-click item in inventory")
end

function AH.PrintStatus()
    local Utils = AH.Utils
    if not Utils or not AH.DataManager then return end
    local status = AH.DataManager.GetSyncStatus()
    Utils.Print("=== Status ===")
    Utils.Print("Client: %s",
        status.isClientConnected
        and Utils.Colorize("Connected", AH.Colors.POSITIVE)
        or Utils.Colorize("Not Connected", AH.Colors.NEUTRAL))
    Utils.Print("Listings: %s", Utils.FormatNumber(status.totalListings))

    local myCount = 0
    for _, l in pairs(AH.savedVars.myListings or {}) do
        if l.state == "listed" then myCount = myCount + 1 end
    end
    Utils.Print("My Active Listings: %d", myCount)
end

function AH.PrintMyListings()
    local Utils = AH.Utils
    if not Utils or not AH.ListingManager then return end
    local listings = AH.ListingManager.GetMyListings()
    if #listings == 0 then
        Utils.Print("No active listings.")
        return
    end
    Utils.Print("=== My Listings (%d) ===", #listings)
    for _, l in ipairs(listings) do
        local qc = AH.QualityColors[l.quality] or AH.Colors.WHITE
        Utils.Print("  %s x%d - %s [%s]",
            Utils.Colorize(l.itemName, qc), l.quantity,
            Utils.FormatGold(l.price), l.state)
    end
end

function AH.PrintCODQueue()
    local Utils = AH.Utils
    if not Utils or not AH.ListingManager then return end
    local queue = AH.ListingManager.GetCODQueue()
    if #queue == 0 then
        Utils.Print("No pending CODs.")
        return
    end
    Utils.Print("=== COD Queue (%d) ===", #queue)
    for _, c in ipairs(queue) do
        local charInfo = ""
        if c.characterName and c.characterName ~= "" then
            charInfo = string.format(" (%s)", Utils.Colorize(c.characterName, AH.Colors.HIGHLIGHT))
        end
        Utils.Print("  %s x%d -> %s for %s%s",
            Utils.Colorize(c.itemName, AH.Colors.HIGHLIGHT),
            c.quantity or 1, c.buyer, Utils.FormatGold(c.price), charInfo)
        Utils.Print("    /ah send %s", c.listingId)
    end
end

function AH.PrintMyPurchases()
    local Utils = AH.Utils
    if not Utils or not AH.ListingManager then return end
    local purchases = AH.ListingManager.GetMyPurchases()
    if #purchases == 0 then
        Utils.Print("No purchases.")
        return
    end
    Utils.Print("=== Purchases (%d) ===", #purchases)
    for _, p in ipairs(purchases) do
        Utils.Print("  %s from %s - %s [%s]",
            Utils.Colorize(p.itemName, AH.Colors.HIGHLIGHT),
            p.seller, Utils.FormatGold(p.price), p.state)
    end
end

function AH.PrintWatchlist()
    local Utils = AH.Utils
    if not Utils then return end
    local watchlist = AH.savedVars.watchlist or {}
    local count = 0
    for _ in pairs(watchlist) do count = count + 1 end
    if count == 0 then
        Utils.Print("Watchlist empty. Use /ah watch <item name> or right-click > Watch on TAH")
        return
    end
    Utils.Print("=== Watchlist (%d) ===", count)
    for itemId, w in pairs(watchlist) do
        local priceStr = ""
        if w.maxPrice and w.maxPrice > 0 then
            priceStr = string.format(" (max %s/ea)", Utils.FormatGold(w.maxPrice))
        end
        Utils.Print("  %s%s", Utils.Colorize(w.itemName or itemId, AH.Colors.HIGHLIGHT), priceStr)
    end
end

function AH.PrintSaleStats()
    local Utils = AH.Utils
    if not Utils or not AH.Features then return end
    local s = AH.Features.GetSaleStats()
    Utils.Print("=== 7-Day Stats ===")
    Utils.Print("Sold: %s items for %s",
        Utils.Colorize(tostring(s.sold_7d or 0), AH.Colors.HIGHLIGHT),
        Utils.Colorize(Utils.FormatGold(s.gold_7d or 0), AH.Colors.POSITIVE))
    Utils.Print("Bought: %s items for %s",
        Utils.Colorize(tostring(s.bought_7d or 0), AH.Colors.HIGHLIGHT),
        Utils.Colorize(Utils.FormatGold(s.spent_7d or 0), AH.Colors.NEUTRAL))
    Utils.Print("Net: %s",
        Utils.Colorize(Utils.FormatGold((s.gold_7d or 0) - (s.spent_7d or 0)),
            (s.gold_7d or 0) >= (s.spent_7d or 0) and AH.Colors.POSITIVE or AH.Colors.NEUTRAL))
end

---------------------------------------------------------------------------
--  SavedVars Migration
---------------------------------------------------------------------------

function AH.MigrateSavedVars()
    local sv = AH.savedVars
    local defaults = AH.DefaultSavedVars
    for key, default in pairs(defaults) do
        if sv[key] == nil then
            sv[key] = type(default) == "table" and (AH.Utils and AH.Utils.DeepCopy(default) or default) or default
        elseif type(default) == "table" then
            for subKey, subDefault in pairs(default) do
                if sv[key][subKey] == nil then
                    sv[key][subKey] = type(subDefault) == "table" and (AH.Utils and AH.Utils.DeepCopy(subDefault) or subDefault) or subDefault
                end
            end
        end
    end
end

---------------------------------------------------------------------------
--  Register
---------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent("AuctionHouse_Loaded", EVENT_ADD_ON_LOADED, OnAddonLoaded)
