-- LPC.lua - Core logic (ostateczny)
LibPriceCache = LibPriceCache or {}
LibPriceCache.Core = LibPriceCache.Core or {}
local L = LibPriceCache.Core

L.name = "LibPriceCache.Core"
L.version = "1.1.5"

L.DefaultVars = {
    TooltipIntegration = false,
    RoundPrice = true,
    Separator = "'",
    DisableStartupLog = false,
    errors = {},
    lastFullScan = 0,
    UseAveragePrice = true,
    UseBestPrice = false,
    UseTTCPrice = true,
    UseATTPrice = true,
    UseMMPrice = true,
    UseUESPPrice = true,
    UseESOHubPrice = true,
    ShowTTCInTooltip = true,
    ShowESOHubInTooltip = true,
    ShowATTInTooltip = true,
    ShowMMInTooltip = true,
    ShowUESPInTooltip = true,
    ShowVendorInTooltip = true,
    UseVendorPrice = true,
    Weight_TTC = 10,
    Weight_ESO_Hub = 9,
    Weight_ATT = 8,
    Weight_MM = 7,
    Weight_UESP = 2,
    MaxPriceAgeDays = 7,
    AutoScanIIfA = true,
    TooltipColor = {Red = 0.58, Green = 1, Blue = 0.54},
    TooltipPriceInfoColor = {Red = 0.39, Green = 0.59, Blue = 0.78},
    PriceOverrideEnabled = false,
}

-- Buforowanie regionu serwera
local cachedWorldName = nil
local cachedServerRegion = nil

function L:GetServerRegion()
    if cachedServerRegion then
        return cachedServerRegion
    end
    if not cachedWorldName then
        cachedWorldName = GetWorldName()
    end
    if cachedWorldName == "EU Megaserver" then
        cachedServerRegion = "EU"
    elseif cachedWorldName == "NA Megaserver" then
        cachedServerRegion = "NA"
    elseif cachedWorldName == "PTS" then
        cachedServerRegion = "PTS"
    else
        cachedServerRegion = "NA"
    end
    return cachedServerRegion
end

local itemTypeToModule = {
    [ITEMTYPE_ARMOR] = "LPC01",
    [ITEMTYPE_WEAPON] = "LPC01",
    [ITEMTYPE_POTION] = "LPC03",
    [ITEMTYPE_FOOD] = "LPC03",
    [ITEMTYPE_DRINK] = "LPC03",
    [ITEMTYPE_POISON] = "LPC03",
    [ITEMTYPE_RECIPE] = "LPC04",
    [ITEMTYPE_RACIAL_STYLE_MOTIF] = "LPC04",
    [ITEMTYPE_FURNISHING] = "LPC04",
    [ITEMTYPE_STYLE_MATERIAL] = "LPC04",
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = "LPC04",
    [ITEMTYPE_CLOTHIER_BOOSTER] = "LPC04",
    [ITEMTYPE_WOODWORKING_BOOSTER] = "LPC04",
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = "LPC04",
    [ITEMTYPE_ARMOR_BOOSTER] = "LPC04",
    [ITEMTYPE_WEAPON_BOOSTER] = "LPC04",
}

function L:GetDataModuleName(link, isPersonalSale)
    if not link or link == "" then return "LPC02" end
    local itemType = GetItemLinkItemType(link)
    if not itemType then return "LPC02" end
    return itemTypeToModule[itemType] or "LPC02"
end

function L:GetID(link)
    if type(link) ~= "string" then return "0:0:0:0" end
    local id = GetItemLinkItemId(link) or 0
    local quality = GetItemLinkFunctionalQuality(link) or 0
    local cp = GetItemLinkRequiredChampionPoints(link) or 0
    local server = L:GetServerRegion()
    return string.format("%s:%d:%d:%d", server, id, cp, quality)
end

function L:Round(v)
    if not v or type(v) ~= "number" then return 0 end
    return math.floor(v * 100 + 0.5) / 100
end

function L:GetPrinter(link) return L:GetDataModuleName(link, false) end
function L:GetDataModule(link, isPersonalSale) return LibPriceCache[L:GetDataModuleName(link, isPersonalSale)] end

L.gamepadMode = IsInGamepadPreferredMode()
L.uiCooldown = false
L.initialScanDone = false

local function OnGamepadModeChanged()
    L.gamepadMode = IsInGamepadPreferredMode()
    L.uiCooldown = true
    if LibPriceCache.Report and LibPriceCache.Report.Log then
        LibPriceCache.Report:Log("[LPC] Gamepad mode changed. UI cooldown for 2 seconds.")
    else
        d("[LPC] Gamepad mode changed. UI cooldown for 2 seconds.")
    end
    zo_callLater(function()
        L.uiCooldown = false
        if LibPriceCache.Report and LibPriceCache.Report.Log then
            LibPriceCache.Report:Log("[LPC] UI cooldown ended. Normal operation resumed.")
        else
            d("[LPC] UI cooldown ended. Normal operation resumed.")
        end
        if L.db and L.db.TooltipIntegration then
            PLAYER_INVENTORY:UpdateList(INVENTORY_BACKPACK)
            PLAYER_INVENTORY:UpdateList(INVENTORY_CRAFT_BAG)
            PLAYER_INVENTORY:UpdateList(INVENTORY_BANK)
            PLAYER_INVENTORY:UpdateList(INVENTORY_HOUSE_BANK)
            PLAYER_INVENTORY:UpdateList(INVENTORY_GUILD_BANK)
        end
    end, 2000)
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache.Core", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, OnGamepadModeChanged)

local function OnLoaded(event, addonName)
    if addonName ~= "LibPriceCache" then return end
    EVENT_MANAGER:UnregisterForEvent("LibPriceCache.Core", EVENT_ADD_ON_LOADED)
    local serverKey = GetDisplayName() .. "_" .. GetWorldName()
    L.db = ZO_SavedVars:NewAccountWide("LibPriceCacheSettings", 1, nil, L.DefaultVars, serverKey)
    LibPriceCache.Core.db = L.db
    if not L.db then
        d("[LPC] WARNING: Saved variables not available. Using fallback settings (not saved).")
    else
        if not L.db.DisableStartupLog then
            d("[LPC] Saved variables loaded for server: " .. GetWorldName())
        end
    end
    if LibPriceCache.Report and LibPriceCache.Report.Log then
        LibPriceCache.Report:Log("|c00FF00LibPriceCache v" .. L.version .. " core initialized.|r")
    else
        if not L.db or not L.db.DisableStartupLog then
            d("|c00FF00LibPriceCache v" .. L.version .. " core initialized.|r")
        end
    end
    
    -- Initial scan - tylko raz na sesję gry
    if not L.initialScanDone then
        L.initialScanDone = true
        zo_callLater(function()
            if LibPriceCache.Scanner then
                if not L.db or not L.db.DisableStartupLog then
                    if LibPriceCache.Report and LibPriceCache.Report.Log then
                        LibPriceCache.Report:Log("|c3366FF[LPC] Starting delayed inventory scan (180s delay)...|r")
                    else
                        d("[LPC] Starting delayed inventory scan (180s delay)...")
                    end
                end
                LibPriceCache.Scanner:Start("quick")
            else
                if not L.db or not L.db.DisableStartupLog then
                    if LibPriceCache.Report and LibPriceCache.Report.EmergencyLog then
                        LibPriceCache.Report:EmergencyLog("OnLoaded", "LibPriceCache.Scanner not available")
                    else
                        d("[LPC] ERROR: Scanner not available")
                    end
                end
            end
        end, 180000)
    end
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache.Core", EVENT_ADD_ON_LOADED, OnLoaded)

local function SetupTooltipHooks()
    local originalSetBagItem = ItemTooltip.SetBagItem
    if originalSetBagItem then
        ItemTooltip.SetBagItem = function(self, bagId, slotIndex, ...)
            originalSetBagItem(self, bagId, slotIndex, ...)
            if L.db and L.db.TooltipIntegration and not L.uiCooldown then
                local itemLink = GetItemLink(bagId, slotIndex)
                if itemLink and LibPriceCache.Calc and LibPriceCache.Calc.AddPriceLinesToTooltip then
                    LibPriceCache.Calc:AddPriceLinesToTooltip(self, itemLink, false)
                end
            end
        end
    end
    local originalSetLink = ItemTooltip.SetLink
    if originalSetLink then
        ItemTooltip.SetLink = function(self, link, ...)
            originalSetLink(self, link, ...)
            if L.db and L.db.TooltipIntegration and link and not L.uiCooldown then
                if LibPriceCache.Calc and LibPriceCache.Calc.AddPriceLinesToTooltip then
                    LibPriceCache.Calc:AddPriceLinesToTooltip(self, link, false)
                end
            end
        end
    end
    local originalSetTradingHouseItem = ItemTooltip.SetTradingHouseItem
    if originalSetTradingHouseItem then
        ItemTooltip.SetTradingHouseItem = function(self, index, ...)
            originalSetTradingHouseItem(self, index, ...)
            if L.db and L.db.TooltipIntegration and not L.uiCooldown then
                local itemLink = GetTradingHouseSearchResultItemLink(index)
                if itemLink and LibPriceCache.Calc and LibPriceCache.Calc.AddPriceLinesToTooltip then
                    LibPriceCache.Calc:AddPriceLinesToTooltip(self, itemLink, false)
                end
            end
        end
    end
    local originalSetTradingHouseListing = ItemTooltip.SetTradingHouseListing
    if originalSetTradingHouseListing then
        ItemTooltip.SetTradingHouseListing = function(self, index, ...)
            originalSetTradingHouseListing(self, index, ...)
            if L.db and L.db.TooltipIntegration and not L.uiCooldown then
                local itemLink = GetTradingHouseListingItemLink(index)
                if itemLink and LibPriceCache.Calc and LibPriceCache.Calc.AddPriceLinesToTooltip then
                    LibPriceCache.Calc:AddPriceLinesToTooltip(self, itemLink, false)
                end
            end
        end
    end
    zo_callLater(function()
        if GAMEPAD_TOOLTIPS then
            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
            if tooltip and tooltip.LayoutBagItem then
                local originalLayout = tooltip.LayoutBagItem
                tooltip.LayoutBagItem = function(self, bagId, slotIndex, ...)
                    -- DODAJ TOOLTIP PRZED oryginalną funkcją (naprawia gamepad)
                    if L.db and L.db.TooltipIntegration and not L.uiCooldown then
                        local itemLink = GetItemLink(bagId, slotIndex)
                        if itemLink and LibPriceCache.Calc and LibPriceCache.Calc.AddPriceLinesToTooltip then
                            LibPriceCache.Calc:AddPriceLinesToTooltip(self, itemLink, true)
                        end
                    end
                    -- POTEM wykonaj oryginalną funkcję
                    originalLayout(self, bagId, slotIndex, ...)
                end
            end
        end
        if GAMEPAD_INVENTORY then
            local originalUpdate = GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip
            if originalUpdate then
                GAMEPAD_INVENTORY.UpdateCategoryLeftTooltip = function(self, ...)
                    if self.currentSelectedData and self.currentSelectedData.bagId and self.currentSelectedData.slotIndex then
                        local itemLink = GetItemLink(self.currentSelectedData.bagId, self.currentSelectedData.slotIndex)
                        if itemLink and L.db and L.db.TooltipIntegration and not L.uiCooldown then
                            local tooltip = GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP)
                            if tooltip and LibPriceCache.Calc and LibPriceCache.Calc.AddPriceLinesToTooltip then
                                LibPriceCache.Calc:AddPriceLinesToTooltip(tooltip, itemLink, true)
                            end
                        end
                    end
                    originalUpdate(self, ...)
                end
            end
        end
    end, 5000)
    if LibPriceCache.Report and LibPriceCache.Report.Log then
        LibPriceCache.Report:Log("Tooltip hooks installed")
    else
        d("[LPC] Tooltip hooks installed")
    end
end
zo_callLater(SetupTooltipHooks, 8000)

SLASH_COMMANDS["/lpcscan"] = function()
    if LibPriceCache.Scanner then
        LibPriceCache.Scanner:Start("quick")
        if LibPriceCache.Report and LibPriceCache.Report.Log then
            LibPriceCache.Report:Log("Quick scan started")
        else
            d("[LPC] Quick scan started")
        end
    else
        if LibPriceCache.Report and LibPriceCache.Report.Log then
            LibPriceCache.Report:Log("Scanner not available")
        else
            d("[LPC] Scanner not available")
        end
    end
end

SLASH_COMMANDS["/lpcfulldbscan"] = function()
    if LibPriceCache.Extensions and LibPriceCache.Extensions.FullDatabasePriceScan then
        LibPriceCache.Extensions:FullDatabasePriceScan()
    else
        if LibPriceCache.Report and LibPriceCache.Report.Log then
            LibPriceCache.Report:Log("Full scan function not available")
        else
            d("[LPC] Full scan function not available")
        end
    end
end

SLASH_COMMANDS["/lpcstatus"] = function()
    local function statusLog(msg)
        if LibPriceCache.Report and LibPriceCache.Report.Log then
            LibPriceCache.Report:Log(msg)
        else
            d(msg)
        end
    end
    statusLog("=== LibPriceCache Status ===")
    statusLog("Version: " .. L.version)
    statusLog("Last scan: " .. (L.db.lastFullScan > 0 and os.date("%Y-%m-%d %H:%M:%S", L.db.lastFullScan) or "never"))
    statusLog("Server: " .. L:GetServerRegion())
end

SLASH_COMMANDS["/lpchelp"] = function()
    local function helpLog(msg)
        if LibPriceCache.Report and LibPriceCache.Report.Log then
            LibPriceCache.Report:Log(msg)
        else
            d(msg)
        end
    end
    helpLog("|c00FF00LibPriceCache v" .. L.version .. "|r")
    helpLog("Commands: /lpcscan, /lpcfulldbscan, /lpcguildscan, /lpcstatus, /lpcrescan, /lpcscanii")
end

function LibPriceCache.GetPrice(itemLink)
    if not itemLink or not LibPriceCache.Core or not LibPriceCache.Core.db then return nil end
    if not LibPriceCache.Calc or not LibPriceCache.Calc.GetAveragePrice then return nil end
    local maxAge = LibPriceCache.Core.db.MaxPriceAgeDays * 86400
    return LibPriceCache.Calc:GetAveragePrice(itemLink, maxAge)
end