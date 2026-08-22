-- TTC Price v1.4
-- Author: @NPViral
-- Core pricing, quick undercut controls, settings, and AwesomeGuildStore integration.

TTCPrice = TTCPrice or {}

local TP = TTCPrice
TP.name    = "TTCPrice"
TP.version = "1.4"

-- ─── Defaults ────────────────────────────────────────────────────────────────

local defaults = {
    priceSource     = "SaleAvg",  -- "SuggestedPrice" | "SaleAvg" | "Avg"
    undercutPercent = 0,          -- baseline % below TTC price
    minEntryCount   = 5,          -- skip items with fewer listings than this
    autoPrice       = true,       -- price selected AGS items automatically
    showPriceButton = false,      -- optional manual baseline-price button
    listingInspectorEnabled = true, -- show own-listing status icons
    listingDriftPercent = 5,        -- review listing when this far above TTC SaleAvg
    listingWaitingDays = 3,          -- non-drifted listing becomes Still Waiting after this many days
}

-- ─── State ───────────────────────────────────────────────────────────────────

local sv
local priceButton
local quickButtons = {}
local agsHookRegistered = false

function TP.GetListingInspectorSettings()
    if not sv then
        return defaults.listingInspectorEnabled, defaults.listingDriftPercent, defaults.listingWaitingDays
    end
    return sv.listingInspectorEnabled, sv.listingDriftPercent, sv.listingWaitingDays
end

local function CallListingInspector(methodName)
    local inspector = TP.ListingInspector
    local method = inspector and inspector[methodName]
    if type(method) == "function" then
        pcall(method, inspector)
    end
end

local function RefreshListingInspector()
    CallListingInspector("Refresh")
end

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function GetTTCData(itemLink)
    if not TamrielTradeCentrePrice
        or type(TamrielTradeCentrePrice.GetPriceInfo) ~= "function" then
        return nil
    end
    return TamrielTradeCentrePrice:GetPriceInfo(itemLink)
end

local function GetPriceFromData(data)
    if type(data) ~= "table" then return nil, 0 end
    local price = data[sv.priceSource]
    if not price or price <= 0 then
        price = data.Avg
    end
    if not price or price <= 0 then return nil, 0 end
    return price, data.EntryCount or 0
end

local function CalcUnitPrice(ttcPrice, undercutPercent)
    local percent = undercutPercent
    if percent == nil then
        percent = sv.undercutPercent
    end
    return math.max(1, math.floor(ttcPrice * (1 - percent / 100) + 0.5))
end

local function ApplyPrice(undercutPercent)
    local internal = AwesomeGuildStore and AwesomeGuildStore.internal
    local tradingHouse = internal and internal.tradingHouse
    local sellTab = tradingHouse and tradingHouse.sellTab
    if not sellTab or type(sellTab.SetUnitPrice) ~= "function" then return end

    local link = sellTab.pendingItemLink
    if not link or link == "" then return end

    local data = GetTTCData(link)
    local ttcPrice, entryCount = GetPriceFromData(data)

    if not ttcPrice then return end
    if entryCount < sv.minEntryCount then return end

    local unit = CalcUnitPrice(ttcPrice, undercutPercent)

    if sellTab.isMasterWrit then
        local getVoucherCount = internal.GetItemLinkWritVoucherCount
        local vouchers = type(getVoucherCount) == "function" and getVoucherCount(link)
        if vouchers and vouchers > 0 then
            sellTab:SetUnitPrice(math.floor(unit / vouchers))
        else
            sellTab:SetUnitPrice(unit)
        end
    else
        sellTab:SetUnitPrice(unit)
    end
end

-- ─── AGS Sell Tab Button ─────────────────────────────────────────────────────

local BUTTON_SIZE         = 24
local BUTTON_TEXTURE      = "/esoui/art/vendor/vendor_tabicon_sell_%s.dds"
local QUICK_BUTTON_WIDTH  = 44
local QUICK_BUTTON_HEIGHT = 28
local QUICK_BUTTON_GAP    = 12
local QUICK_BUTTON_MAX        = 20
local QUICK_BUTTON_Y          = -4
local QUICK_BUTTON_STACK_Y    = -26

local function UpdateQuickButtons()
    if not sv then return end

    local quantitySlider = WINDOW_MANAGER:GetControlByName("AwesomeGuildStoreFormInvoiceQuantitySlider")
    local invoice = quantitySlider and quantitySlider:GetParent()

    local centerOffsetX = 0
    if quantitySlider and invoice then
        local invoiceCenterX = select(1, invoice:GetCenter())
        local quantityCenterX = select(1, quantitySlider:GetCenter())
        if invoiceCenterX and quantityCenterX then
            centerOffsetX = invoiceCenterX - quantityCenterX
        end
    end

    local base = tonumber(sv.undercutPercent) or 0
    local visibleButtons = {}

    for offset = 1, 3 do
        local button = quickButtons[offset]
        if button then
            local target = base + offset
            local visible = target <= QUICK_BUTTON_MAX

            button:SetText(string.format("%d%%", target))
            button:SetHidden(not visible)
            button:ClearAnchors()

            if visible then
                visibleButtons[#visibleButtons + 1] = button
            end
        end
    end

    if not quantitySlider then return end

    local count = #visibleButtons
    if count == 0 then return end

    local groupWidth = count * QUICK_BUTTON_WIDTH + (count - 1) * QUICK_BUTTON_GAP
    local firstCenterX = -(groupWidth / 2) + (QUICK_BUTTON_WIDTH / 2)

    local internal = AwesomeGuildStore and AwesomeGuildStore.internal
    local tradingHouse = internal and internal.tradingHouse
    local sellTab = tradingHouse and tradingHouse.sellTab
    local isStackLayout = sellTab and (tonumber(sellTab.pendingStackCount) or 0) > 1
    local y = isStackLayout and QUICK_BUTTON_STACK_Y or QUICK_BUTTON_Y

    for index, button in ipairs(visibleButtons) do
        local x = centerOffsetX + firstCenterX + (index - 1) * (QUICK_BUTTON_WIDTH + QUICK_BUTTON_GAP)
        button:SetAnchor(CENTER, quantitySlider, TOP, x, y)
    end
end

local function AddQuickButtons(buttonContainer)
    if #quickButtons > 0 or not priceButton then
        UpdateQuickButtons()
        return
    end

    local quantitySlider = WINDOW_MANAGER:GetControlByName("AwesomeGuildStoreFormInvoiceQuantitySlider")
    if not quantitySlider then return end

    local quickParent = quantitySlider:GetParent() or buttonContainer

    for offset = 1, 3 do
        local button = WINDOW_MANAGER:CreateControlFromVirtual(
            "TTCPriceQuick" .. offset .. "Button",
            quickParent,
            "ZO_DefaultButton"
        )
        button:SetDimensions(QUICK_BUTTON_WIDTH, QUICK_BUTTON_HEIGHT)

        -- Keep the controls transparent so the AGS sell-panel artwork shows through.
        button:SetNormalTexture("")
        button:SetPressedTexture("")
        button:SetMouseOverTexture("")
        button:SetDisabledTexture("")

        button:SetDrawLayer(DL_OVERLAY)

        local quickOffset = offset
        button:SetHandler("OnClicked", function()
            local base = tonumber(sv.undercutPercent) or 0
            local target = base + quickOffset
            if target <= QUICK_BUTTON_MAX then
                ApplyPrice(target)
            end
        end)

        quickButtons[offset] = button
    end

    UpdateQuickButtons()
end

local function AddPriceButton()
    if priceButton then
        priceButton:SetHidden(not sv.showPriceButton)
        UpdateQuickButtons()
        return
    end

    local buttonContainer = WINDOW_MANAGER:GetControlByName("AwesomeGuildStoreFormInvoicePriceButtons")
    if not buttonContainer then return end

    local existingButton = buttonContainer:GetNamedChild("TPPriceButton")
    if existingButton then
        priceButton = existingButton
        priceButton:SetHidden(not sv.showPriceButton)
        AddQuickButtons(buttonContainer)
        return
    end

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
    btn.control:SetHidden(not sv.showPriceButton)

    btn.HandlePress = function()
        ApplyPrice()
    end

    priceButton = btn.control
    AddQuickButtons(buttonContainer)
end

local function OnAGSFilterSetup()
    CallListingInspector("TryInstallRowHook")

    if agsHookRegistered then return end
    if not AwesomeGuildStore.class
        or not AwesomeGuildStore.class.SellTabWrapper
        or type(AwesomeGuildStore.class.SellTabWrapper.InitializeListingInput) ~= "function" then
        return
    end
    agsHookRegistered = true
    ZO_PostHook(AwesomeGuildStore.class.SellTabWrapper, "InitializeListingInput", AddPriceButton)
    ZO_PostHook(AwesomeGuildStore.class.SellTabWrapper, "SetPendingItem", function()
        UpdateQuickButtons()
        if sv.autoPrice then
            ApplyPrice()
        end
    end)
end

local function RegisterAGSCallback()
    if not AwesomeGuildStore
        or type(AwesomeGuildStore.RegisterCallback) ~= "function"
        or not AwesomeGuildStore.callback
        or not AwesomeGuildStore.callback.AFTER_FILTER_SETUP then
        return
    end
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
        version             = TP.version,
        registerForRefresh  = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("TTCPricePanel", panelData)

    local options = {
        {
            type = "header",
            name = "Pricing",
        },
        {
            type    = "description",
            text    = "Auto Price uses the baseline undercut. Quick buttons add +1%, +2%, or +3%.",
            width   = "full",
        },
        {
            type          = "dropdown",
            name          = "Price Source",
            tooltip       = "TTC value used for pricing.",
            choices       = { "SaleAvg", "SuggestedPrice", "Avg" },
            choicesValues = { "SaleAvg", "SuggestedPrice", "Avg" },
            getFunc       = function() return sv.priceSource end,
            setFunc       = function(v) sv.priceSource = v end,
            default       = defaults.priceSource,
        },
        {
            type    = "slider",
            name    = "Baseline Undercut (%)",
            tooltip = "Default undercut for Auto Price and the manual TTC button.",
            min     = 0,
            max     = 20,
            step    = 1,
            getFunc = function() return sv.undercutPercent end,
            setFunc = function(v)
                sv.undercutPercent = v
                UpdateQuickButtons()
            end,
            default = defaults.undercutPercent,
        },
        {
            type    = "checkbox",
            name    = "Auto Price Selected Item",
            tooltip = "Fills the AGS price when TTC data is sufficient. Never posts.",
            getFunc = function() return sv.autoPrice end,
            setFunc = function(v) sv.autoPrice = v end,
            default = defaults.autoPrice,
        },
        {
            type = "header",
            name = "Market Safety",
        },
        {
            type    = "slider",
            name    = "Minimum Listings",
            tooltip = "Minimum active TTC listings required for pricing.",
            min     = 0,
            max     = 50,
            step    = 1,
            getFunc = function() return sv.minEntryCount end,
            setFunc = function(v) sv.minEntryCount = v end,
            default = defaults.minEntryCount,
        },
        {
            type = "header",
            name = "Listing Inspector",
        },
        {
            type  = "description",
            text  = "Shows Looks Good, Price Drift, or Still Waiting on your own listings.",
            width = "full",
        },
        {
            type    = "checkbox",
            name    = "Show Listing Status",
            tooltip = "Show status icons on your own listings with enough TTC sales data.",
            getFunc = function() return sv.listingInspectorEnabled end,
            setFunc = function(v)
                sv.listingInspectorEnabled = v
                RefreshListingInspector()
            end,
            default = defaults.listingInspectorEnabled,
        },
        {
            type    = "slider",
            name    = "Price Drift Threshold (%)",
            tooltip = "Price Drift requires this % above TTC Sale Avg; TTC range is also checked when available.",
            min     = 5,
            max     = 30,
            step    = 1,
            getFunc = function() return sv.listingDriftPercent end,
            setFunc = function(v)
                sv.listingDriftPercent = v
                RefreshListingInspector()
            end,
            default = defaults.listingDriftPercent,
        },
        {
            type    = "slider",
            name    = "Still Waiting After (days)",
            tooltip = "Still Waiting after this many days when Price Drift is not detected.",
            min     = 3,
            max     = 10,
            step    = 1,
            getFunc = function() return sv.listingWaitingDays end,
            setFunc = function(v)
                sv.listingWaitingDays = v
                RefreshListingInspector()
            end,
            default = defaults.listingWaitingDays,
        },
        {
            type = "header",
            name = "Sell Tab",
        },
        {
            type    = "checkbox",
            name    = "Show Manual TTC Price Button",
            tooltip = "Show the TTC Price button in the AGS sell form.",
            getFunc = function() return sv.showPriceButton end,
            setFunc = function(v)
                sv.showPriceButton = v
                if priceButton then
                    priceButton:SetHidden(not v)
                end
            end,
            default = defaults.showPriceButton,
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
    CallListingInspector("Initialize")
end

EVENT_MANAGER:RegisterForEvent(TP.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
