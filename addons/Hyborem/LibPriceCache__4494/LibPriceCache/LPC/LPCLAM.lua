-- LPCLAM.lua
LibPriceCache = LibPriceCache or {}
LibPriceCache.LPCLAM = LibPriceCache.LPCLAM or {}

local LAM = LibPriceCache.LPCLAM

local function ReloadUIMessage()
    d("|cFFFF00[LibPriceCache] Settings changed. Click 'Reload UI' or type /reloadui to apply changes.|r")
end

function LAM:Init()
    local panelData = {
        type = "panel",
        name = "LibPriceCache",
        displayName = "LibPriceCache Settings",
        author = "Hyborem & Grok",
        version = LibPriceCache.version,
        registerForRefresh = true,
    }

    local options = {
        { type = "header", name = "General Settings" },
        { type = "button", name = "Full Database Scan", tooltip = "Scan all items from Master Merchant, ATT, TTC and other addons to refresh prices",
            func = function()
                if LibPriceCache.Extensions and LibPriceCache.Extensions.FullDatabasePriceScan then
                    LibPriceCache.Extensions:FullDatabasePriceScan()
                    d("|c00FF00[LibPriceCache] Full database scan started!|r")
                else
                    d("|cFF0000[LibPriceCache] Full database scan function not available!|r")
                end
            end, width = "full" },
        { type = "checkbox", name = "Enable Tooltip Prices", getFunc = function() return LibPriceCache.Core.db.TooltipIntegration end,
            setFunc = function(v) LibPriceCache.Core.db.TooltipIntegration = v; ReloadUIMessage() end, default = false },
        { type = "checkbox", name = "Use Average Price", tooltip = "Display weighted average price from addon sources",
            getFunc = function() return LibPriceCache.Core.db.UseAveragePrice end,
            setFunc = function(v) LibPriceCache.Core.db.UseAveragePrice = v; ReloadUIMessage() end, default = true },
        { type = "checkbox", name = "Use Best Price", getFunc = function() return LibPriceCache.Core.db.UseBestPrice end,
            setFunc = function(v) LibPriceCache.Core.db.UseBestPrice = v; ReloadUIMessage() end, default = false },
        { type = "slider", name = "Data freshness (days)", min = 1, max = 30, step = 1,
            getFunc = function() return LibPriceCache.Core.db.MaxPriceAgeDays or 7 end,
            setFunc = function(v) LibPriceCache.Core.db.MaxPriceAgeDays = v end, default = 7 },
        { type = "checkbox", name = "Round prices", getFunc = function() return LibPriceCache.Core.db.RoundPrice end,
            setFunc = function(v) LibPriceCache.Core.db.RoundPrice = v; ReloadUIMessage() end, default = true },
        { type = "dropdown", name = "Thousand separator", width = "half", choices = {"'", ",", ".", "_", "SPACE", "NONE"},
            getFunc = function() return LibPriceCache.Core.db.Separator end,
            setFunc = function(v) LibPriceCache.Core.db.Separator = v; ReloadUIMessage() end, default = "'" },
        { type = "checkbox", name = "Disable startup messages", getFunc = function() return LibPriceCache.Core.db.DisableStartupLog end,
            setFunc = function(v) LibPriceCache.Core.db.DisableStartupLog = v end, default = false },
        { type = "checkbox", name = "Auto-scan IIfA on login", tooltip = "Automatically scan all account items via Inventory Insight (IIfA) after login",
            getFunc = function() return LibPriceCache.Core.db.AutoScanIIfA end,
            setFunc = function(v) LibPriceCache.Core.db.AutoScanIIfA = v end, default = true,
            disabled = function() return not (IIfA and IIfA.GetInventoryDB) end },
        { type = "header", name = "Price Override (UI replacement)" },
        { type = "checkbox", name = "Enable price override", tooltip = "Replace displayed prices in inventory and guild store with LPC calculated prices (toggles /lpcpo)",
            getFunc = function()
                local core = LibPriceCache.Core
                return core and core.db and core.db.PriceOverrideEnabled or false
            end,
            setFunc = function(v)
                local core = LibPriceCache.Core
                if core and core.db then
                    core.db.PriceOverrideEnabled = v
                    core.db.dirty = true
                    d("|cFFFF00[LibPriceCache] Price override " .. (v and "enabled" or "disabled") .. ". Type /reloadui to apply changes.|r")
                    if v then
                        if LibPriceCache.PriceOverride then
                            if LibPriceCache.PriceOverride.SetupGuildStoreHooks then
                                LibPriceCache.PriceOverride.SetupGuildStoreHooks()
                            end
                            if LibPriceCache.PriceOverride.SetupInventoryColorHooks then
                                LibPriceCache.PriceOverride.SetupInventoryColorHooks()
                            end
                        end
                        PLAYER_INVENTORY:UpdateList(INVENTORY_BACKPACK)
                        PLAYER_INVENTORY:UpdateList(INVENTORY_CRAFT_BAG)
                        PLAYER_INVENTORY:UpdateList(INVENTORY_BANK)
                        PLAYER_INVENTORY:UpdateList(INVENTORY_HOUSE_BANK)
                        PLAYER_INVENTORY:UpdateList(INVENTORY_GUILD_BANK)
                    end
                else
                    d("|cFF0000[LibPriceCache] Cannot save price override: core.db not ready.|r")
                end
            end,
            default = false },
        { type = "submenu", name = "Source Weights (0-10)", controls = {
            {type = "slider", name = "TTC", min = 0, max = 10, step = 1, getFunc = function() return LibPriceCache.Core.db.Weight_TTC or 10 end, setFunc = function(v) LibPriceCache.Core.db.Weight_TTC = v end, default = 10},
            {type = "slider", name = "ESO-Hub", min = 0, max = 10, step = 1, getFunc = function() return LibPriceCache.Core.db.Weight_ESO_Hub or 9 end, setFunc = function(v) LibPriceCache.Core.db.Weight_ESO_Hub = v end, default = 9},
            {type = "slider", name = "ATT", min = 0, max = 10, step = 1, getFunc = function() return LibPriceCache.Core.db.Weight_ATT or 8 end, setFunc = function(v) LibPriceCache.Core.db.Weight_ATT = v end, default = 8},
            {type = "slider", name = "MM", min = 0, max = 10, step = 1, getFunc = function() return LibPriceCache.Core.db.Weight_MM or 7 end, setFunc = function(v) LibPriceCache.Core.db.Weight_MM = v end, default = 7},
            {type = "slider", name = "UESP", min = 0, max = 10, step = 1, getFunc = function() return LibPriceCache.Core.db.Weight_UESP or 2 end, setFunc = function(v) LibPriceCache.Core.db.Weight_UESP = v end, default = 2},
        } },
        { type = "submenu", name = "Tooltip Visibility (needs /reloadui)", controls = {
            {type = "checkbox", name = "Show TTC", getFunc = function() return LibPriceCache.Core.db.ShowTTCInTooltip end, setFunc = function(v) LibPriceCache.Core.db.ShowTTCInTooltip = v; ReloadUIMessage() end, default = true},
            {type = "checkbox", name = "Show ESO-Hub", getFunc = function() return LibPriceCache.Core.db.ShowESOHubInTooltip end, setFunc = function(v) LibPriceCache.Core.db.ShowESOHubInTooltip = v; ReloadUIMessage() end, default = true},
            {type = "checkbox", name = "Show ATT", getFunc = function() return LibPriceCache.Core.db.ShowATTInTooltip end, setFunc = function(v) LibPriceCache.Core.db.ShowATTInTooltip = v; ReloadUIMessage() end, default = true},
            {type = "checkbox", name = "Show MM", getFunc = function() return LibPriceCache.Core.db.ShowMMInTooltip end, setFunc = function(v) LibPriceCache.Core.db.ShowMMInTooltip = v; ReloadUIMessage() end, default = true},
            {type = "checkbox", name = "Show UESP", getFunc = function() return LibPriceCache.Core.db.ShowUESPInTooltip end, setFunc = function(v) LibPriceCache.Core.db.ShowUESPInTooltip = v; ReloadUIMessage() end, default = false},
            {type = "checkbox", name = "Show Vendor", getFunc = function() return LibPriceCache.Core.db.ShowVendorInTooltip end, setFunc = function(v) LibPriceCache.Core.db.ShowVendorInTooltip = v; ReloadUIMessage() end, default = true},
        } },
        { type = "submenu", name = "Tooltip Appearance (needs /reloadui)", controls = {
            { type = "colorpicker", name = "Price text color", width = "half", getFunc = function() return LibPriceCache.Core.db.TooltipColor.Red, LibPriceCache.Core.db.TooltipColor.Green, LibPriceCache.Core.db.TooltipColor.Blue end,
                setFunc = function(r, g, b) LibPriceCache.Core.db.TooltipColor.Red = r; LibPriceCache.Core.db.TooltipColor.Green = g; LibPriceCache.Core.db.TooltipColor.Blue = b; ReloadUIMessage() end },
            { type = "colorpicker", name = "Price info color", width = "half", getFunc = function() return LibPriceCache.Core.db.TooltipPriceInfoColor.Red, LibPriceCache.Core.db.TooltipPriceInfoColor.Green, LibPriceCache.Core.db.TooltipPriceInfoColor.Blue end,
                setFunc = function(r, g, b) LibPriceCache.Core.db.TooltipPriceInfoColor.Red = r; LibPriceCache.Core.db.TooltipPriceInfoColor.Green = g; LibPriceCache.Core.db.TooltipPriceInfoColor.Blue = b; ReloadUIMessage() end },
        } },
        { type = "button", name = "|t32:32:LibPriceCache/icon/hyborem.dds|t Donate", tooltip = "Support the developer (opens mail window)",
            func = function() SCENE_MANAGER:Show('mailSend'); zo_callLater(function() ZO_MailSendToField:SetText("@HyboremInfernal"); ZO_MailSendSubjectField:SetText("LibPriceCache Support (Manual: 5000g)") end, 250) end, width = "full" },
        { type = "button", name = "Reload UI (apply changes)", tooltip = "Reload the UI to apply all settings changes",
            func = function() ReloadUI() end, width = "full", color = {1, 0.8, 0, 1} },
    }

    LibAddonMenu2:RegisterAddonPanel("LibPriceCache_Settings", panelData)
    LibAddonMenu2:RegisterOptionControls("LibPriceCache_Settings", options)
end

local function OnAddOnLoaded(event, addonName)
    if addonName == "LibPriceCache" then
        EVENT_MANAGER:UnregisterForEvent("LibPriceCache_LAM", EVENT_ADD_ON_LOADED)
        zo_callLater(function() LibPriceCache.LPCLAM:Init() end, 2000)
    end
end
EVENT_MANAGER:RegisterForEvent("LibPriceCache_LAM", EVENT_ADD_ON_LOADED, OnAddOnLoaded)