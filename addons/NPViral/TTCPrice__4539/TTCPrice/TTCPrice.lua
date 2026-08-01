-- TTC Price v1.1
-- Author: @NPViral
-- Adds a TTC price button to AwesomeGuildStore sell tab with undercut and thin market protection.

TTCPrice = TTCPrice or {}

local TP = TTCPrice
TP.name    = "TTCPrice"
TP.version = "1.1"

-- ─── Defaults ────────────────────────────────────────────────────────────────

local defaults = {
    priceSource     = "SaleAvg",  -- "SuggestedPrice" | "SaleAvg" | "Avg"
    undercutPercent = 2,          -- % below TTC price
    minEntryCount   = 5,          -- skip items with fewer listings than this
    agsAssist       = true,       -- show button in AGS sell tab
}

-- ─── State ───────────────────────────────────────────────────────────────────

local sv
local priceButton = nil  -- stored reference so the toggle can show/hide it

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function GetTTCData(itemLink)
    if not TamrielTradeCentrePrice then return nil end
    return TamrielTradeCentrePrice:GetPriceInfo(itemLink)
end

local function GetPriceFromData(data)
    if not data then return nil, 0 end
    local price = data[sv.priceSource]
    if not price or price <= 0 then
        price = data.Avg
    end
    if not price or price <= 0 then return nil, 0 end
    return price, data.EntryCount or 0
end

local function CalcUnitPrice(ttcPrice)
    return math.max(1, math.floor(ttcPrice * (1 - sv.undercutPercent / 100) + 0.5))
end

-- ─── AGS Sell Tab Button ─────────────────────────────────────────────────────

local BUTTON_SIZE    = 24
local BUTTON_TEXTURE = "/esoui/art/vendor/vendor_tabicon_sell_%s.dds"

local function AddPriceButton()
    local buttonContainer = WINDOW_MANAGER:GetControlByName("AwesomeGuildStoreFormInvoicePriceButtons")
    if not buttonContainer then return end

    local anchorTarget = buttonContainer:GetNamedChild("ATTPriceButton")
                      or buttonContainer:GetNamedChild("AveragePriceButton")
                      or buttonContainer:GetNamedChild("LastSellPriceButton")
    if not anchorTarget then return end

    local btn = AwesomeGuildStore.class.ToggleButton:New(
        buttonContainer,
        "$(parent)TPPriceButton",
        BUTTON_TEXTURE,
        0, 0,
        BUTTON_SIZE, BUTTON_SIZE,
        "TTC Price"
    )
    btn.control:ClearAnchors()
    btn.control:SetAnchor(RIGHT, anchorTarget, LEFT, 2, 0)
    btn.control:SetDrawLayer(DL_OVERLAY)
    btn.control:SetHidden(not sv.agsAssist)

    btn.HandlePress = function()
        local sellTab = AwesomeGuildStore.internal.tradingHouse.sellTab
        if not sellTab then return end

        local link = sellTab.pendingItemLink
        if not link or link == "" then return end

        local data = GetTTCData(link)
        local ttcPrice, entryCount = GetPriceFromData(data)

        if not ttcPrice then return end
        if entryCount < sv.minEntryCount then return end

        local unit = CalcUnitPrice(ttcPrice)

        if sellTab.isMasterWrit then
            local vouchers = AwesomeGuildStore.internal.GetItemLinkWritVoucherCount(link)
            if vouchers and vouchers > 0 then
                sellTab:SetUnitPrice(math.floor(unit / vouchers))
            else
                sellTab:SetUnitPrice(unit)
            end
        else
            sellTab:SetUnitPrice(unit)
        end
    end

    priceButton = btn.control
end

local function OnAGSFilterSetup()
    ZO_PostHook(AwesomeGuildStore.class.SellTabWrapper, "InitializeListingInput", AddPriceButton)
end

local function RegisterAGSCallback()
    if not AwesomeGuildStore then return end
    AwesomeGuildStore:RegisterCallback(
        AwesomeGuildStore.callback.AFTER_FILTER_SETUP,
        OnAGSFilterSetup
    )
end

-- ─── Settings Panel (LAM) ────────────────────────────────────────────────────

local function BuildSettingsPanel()
    local LAM = LibAddonMenu2

    local panelData = {
        type               = "panel",
        name               = "TTCPrice",
        displayName        = "TTC Price",
        author             = "@NPViral",
        version            = TP.version,
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("TTCPricePanel", panelData)

    local options = {
        {
            type = "header",
            name = "Pricing",
        },
        {
            type          = "dropdown",
            name          = "Price Source",
            tooltip       = "Which TTC price to use as the base before applying the undercut.",
            choices       = { "SaleAvg", "SuggestedPrice", "Avg" },
            choicesValues = { "SaleAvg", "SuggestedPrice", "Avg" },
            getFunc       = function() return sv.priceSource end,
            setFunc       = function(v) sv.priceSource = v end,
        },
        {
            type    = "slider",
            name    = "Undercut Percent (%)",
            tooltip = "How many percent below TTC price to list at.",
            min     = 0,
            max     = 20,
            step    = 1,
            getFunc = function() return sv.undercutPercent end,
            setFunc = function(v) sv.undercutPercent = v end,
        },
        {
            type = "header",
            name = "Filters",
        },
        {
            type    = "slider",
            name    = "Minimum Listings",
            tooltip = "Skip items with fewer active listings than this.",
            min     = 0,
            max     = 50,
            step    = 1,
            getFunc = function() return sv.minEntryCount end,
            setFunc = function(v) sv.minEntryCount = v end,
        },
        {
            type = "header",
            name = "Integration",
        },
        {
            type    = "checkbox",
            name    = "Show Sell Tab Button",
            tooltip = "Show or hide the TTC Price button in the AGS sell form.",
            getFunc = function() return sv.agsAssist end,
            setFunc = function(v)
                sv.agsAssist = v
                if priceButton then
                    priceButton:SetHidden(not v)
                end
            end,
        },
        {
            type    = "button",
            name    = "Feeling generous?",
            tooltip = "Donations keep the skooma flowing.",
            func    = function()
                local ok = pcall(function()
                    if MAIN_MENU_KEYBOARD and type(MAIN_MENU_KEYBOARD.ShowScene) == "function" then
                        MAIN_MENU_KEYBOARD:ShowScene("mailSend")
                    end
                    if ZO_MailSendToField and type(ZO_MailSendToField.SetText) == "function" then
                        ZO_MailSendToField:SetText("@NPViral")
                    end
                    if ZO_MailSendSubjectField and type(ZO_MailSendSubjectField.SetText) == "function" then
                        ZO_MailSendSubjectField:SetText("Skooma Fund")
                    end
                    if ZO_MailSendBodyField and type(ZO_MailSendBodyField.SetText) == "function" then
                        ZO_MailSendBodyField:SetText("Thanks for TTC Price!")
                    end
                end)
                if not ok then
                    CHAT_SYSTEM:AddMessage("Could not open mail automatically. Send gold manually to @NPViral.")
                end
            end,
            width = "full",
        },
    }

    LAM:RegisterOptionControls("TTCPricePanel", options)
end

-- ─── Addon Loaded ────────────────────────────────────────────────────────────

local function OnAddonLoaded(_, addonName)
    if addonName ~= TP.name then return end
    EVENT_MANAGER:UnregisterForEvent(TP.name, EVENT_ADD_ON_LOADED)

    sv = ZO_SavedVars:NewAccountWide("TTCPriceSavedVars", 1, GetWorldName(), defaults)

    BuildSettingsPanel()
    RegisterAGSCallback()
end

EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
