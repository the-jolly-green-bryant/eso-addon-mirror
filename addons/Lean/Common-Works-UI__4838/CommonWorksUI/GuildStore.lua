-- Common Works -- AGS listing-price stepper (+100 rounds 5421 to 5500),
-- traits in place of seller names.
-- OptionalDependsOn loads AGS first; nothing is built without it.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER

-- Parallel: step amounts, and the labels between the +/- rows.
local STEPS  = { 100, 1000, 10000, 100000 }
local LABELS = { "100", "1000", "10k", "100k" }
local ROUND_TO = 100   -- finest rounding, and the smallest step

-- 203 is the width of AGS's own sliders, so the stepper lines up with them.
local PANEL_W   = 203
local BTN_W     = 46
local BTN_H     = 22
local LABEL_H   = 16
local ROW_GAP   = 2
local PANEL_H   = BTN_H + ROW_GAP + LABEL_H + ROW_GAP + BTN_H   -- 64
local COL_PITCH = PANEL_W / #STEPS

-- Grow AGS's 160px form to keep the profit and listings rows from clipping.
local FORM_H_BASE = 160
local GAP         = 10
local FORM_H      = FORM_H_BASE + PANEL_H + GAP * 2

-- API.lua is the only surface AGS promises to keep stable, so gate on GetAPIVersion()
-- and duck-type every entry point below.
function CW.GetAGS()
    local AGS = AwesomeGuildStore
    if type(AGS) ~= "table" then return nil end
    if type(AGS.GetAPIVersion) ~= "function" or AGS.GetAPIVersion() < 4 then return nil end
    if type(AGS.RegisterCallback) ~= "function" then return nil end
    if type(AGS.callback) ~= "table" or not AGS.callback.AFTER_INITIAL_SETUP then return nil end
    if type(AGS.class) ~= "table" or not AGS.class.SellTabWrapper then return nil end
    return AGS
end

function CW.AwesomeGuildStoreAvailable()
    return CW.GetAGS() ~= nil
end

-- The invoice holds the authoritative total; AGS mirrors it into currentSellPrice,
-- the fallback if the vanilla field moves.
local function GetCurrentPrice(sellTab)
    local invoice = TRADING_HOUSE.invoiceSellPrice
    if invoice and invoice.sellPrice then return invoice.sellPrice end
    return sellTab.currentSellPrice or 0
end

-- Two significant figures: 223,100 is a 220,000 listing. Never coarser than the button
-- pressed, or +100 on a six-figure price would snap to the nearest ten thousand.
local function RoundPrice(value, step)
    local grain = ROUND_TO
    while value >= grain * 100 do grain = grain * 10 end
    return zo_roundToNearest(value, math.min(grain, step))
end

local function AdjustPrice(sellTab, delta)
    if (sellTab.pendingStackCount or 0) <= 0 then return end   -- nothing on the block

    local target = RoundPrice(math.max(0, GetCurrentPrice(sellTab) + delta), math.abs(delta))
    -- The total, not AGS's per-unit price: AGS pre-hooks SetPendingPostPrice and
    -- back-computes the unit price, so the slider and the fee rows follow.
    TRADING_HOUSE:SetPendingPostPrice(target)
    PlaySound(SOUNDS.DEFAULT_CLICK)
end

local function MakeStepButton(parent, name, text, tooltipKey, amount, onClick)
    local btn = WM:CreateControlFromVirtual(name, parent, "ZO_DefaultButton")
    btn:SetDimensions(BTN_W, BTN_H)
    btn:SetText(text)
    -- The total price label swallows clicks below DL_OVERLAY; AGS lifts its buttons too.
    btn:SetDrawLayer(DL_OVERLAY)
    btn:SetDrawLevel(2)
    btn:SetHandler("OnClicked", onClick)
    btn:SetHandler("OnMouseEnter", function(self)
        -- Above, not beside: a side tooltip covers the price rows.
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, -4, TOP)
        SetTooltipText(InformationTooltip,
            string.format("%s %s (%s)", CW.L[tooltipKey], ZO_CommaDelimitNumber(amount),
                CW.L.AGS_PRICE_ROUNDED))
    end)
    btn:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
    return btn
end

local function BuildStepper(sellTab, invoice)
    local panel = WM:CreateControl("CW_AGS_PriceStep", invoice, CT_CONTROL)
    panel:SetDimensions(PANEL_W, PANEL_H)
    panel:SetDrawLayer(DL_OVERLAY)
    panel:SetDrawLevel(1)

    for i = 1, #STEPS do
        local amount = STEPS[i]
        -- Centre each column on its slot, four across the slider width.
        local x = (i - 1) * COL_PITCH + (COL_PITCH - BTN_W) / 2

        local plus = MakeStepButton(panel, "CW_AGS_PriceUp" .. i, "+", "AGS_PRICE_UP", amount,
            function() AdjustPrice(sellTab, amount) end)
        plus:SetAnchor(TOPLEFT, panel, TOPLEFT, x, 0)

        local label = WM:CreateControl("CW_AGS_PriceLabel" .. i, panel, CT_LABEL)
        label:SetDimensions(COL_PITCH, LABEL_H)
        label:SetFont("ZoFontGameSmall")
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
        label:SetText(LABELS[i])
        label:SetAnchor(TOP, plus, BOTTOM, 0, ROW_GAP)

        local minus = MakeStepButton(panel, "CW_AGS_PriceDown" .. i, "-", "AGS_PRICE_DOWN", amount,
            function() AdjustPrice(sellTab, -amount) end)
        minus:SetAnchor(TOP, label, BOTTOM, 0, ROW_GAP)
    end

    return panel
end

-- Runs the first time AGS finishes building the store UI.
local function Install(tradingHouseWrapper)
    if CW.agsPriceStepperInstalled then return end

    local sellTab = tradingHouseWrapper and tradingHouseWrapper.sellTab
    if not sellTab then return end
    -- Everything below reaches into AGS internals; bail if a version reshapes them.
    if not (sellTab.ppuSlider and sellTab.sellPriceControl and sellTab.priceButtonContainer) then return end

    local invoice = TRADING_HOUSE.invoice
    local priceLabel = invoice:GetNamedChild("SellPriceLabel")
    local form = TRADING_HOUSE.postItemPane:GetNamedChild("Form")
    if not (priceLabel and form) then return end

    local panel = BuildStepper(sellTab, invoice)

    -- Insert below the unit price slider. AGS hides it by zeroing its height, so
    -- BOTTOMLEFT works in either state; fee rows follow the price label down.
    panel:SetAnchor(TOPLEFT, sellTab.ppuSlider, BOTTOMLEFT, 0, GAP)
    priceLabel:ClearAnchors()
    priceLabel:SetAnchor(TOPLEFT, panel, BOTTOMLEFT, 0, GAP)
    form:SetHeight(FORM_H)

    -- AGS re-anchors its buttons into this space on every SetPendingItem for non-stackables.
    -- Hook the class: instance hooks shadow the method and drop later add-ons' hooks.
    SecurePostHook(CW.GetAGS().class.SellTabWrapper, "SetPendingItem", function(self)
        if self ~= sellTab then return end
        if self.ppuSlider:IsHidden() then
            self.priceButtonContainer:ClearAnchors()
            self.priceButtonContainer:SetAnchor(BOTTOMRIGHT, panel, TOPRIGHT, 0, -ROW_GAP)
        end
    end)

    CW.agsPriceStepperInstalled = true
end

-- Wait for first store open: AGS builds its sell tab in RunInitialSetup.
function CW.InstallAGSPriceStepper()
    local AGS = CW.GetAGS()
    if not AGS then return end
    if CW.agsPriceStepperRegistered then return end
    CW.agsPriceStepperRegistered = true

    AGS:RegisterCallback(AGS.callback.AFTER_INITIAL_SETUP, function(tradingHouseWrapper)
        Install(tradingHouseWrapper)
    end)

    -- Already fired if a store was opened before we got here.
    local tradingHouse = AGS.internal and AGS.internal.tradingHouse
    if tradingHouse and tradingHouse.initialized then
        Install(tradingHouse)
    end
end

-- Search results show the item trait where AwesomeGuildStore draws the seller name.
function CW.InstallGuildStoreTraits()
    if not CW.SavedVars.guildStoreShowTrait then return end
    if not CW.GetAGS() then return end

    -- Wait one frame so this wraps row setup after both AGS and PerfectPixel.
    EM:RegisterForEvent("CW_GuildStoreTraits", EVENT_OPEN_TRADING_HOUSE, function()
        EM:UnregisterForEvent("CW_GuildStoreTraits", EVENT_OPEN_TRADING_HOUSE)
        zo_callLater(function()
            local dataType = ZO_ScrollList_GetDataTypeTable(TRADING_HOUSE.searchResultsList, 1)
            SecurePostHook(dataType, "setupCallback", function(rowControl, result)
                -- PerfectPixel hides AGS's SellerName and draws its own Seller label instead.
                local label = rowControl:GetNamedChild("Seller") or rowControl.sellerName
                -- Capture seller colors before overriding: PerfectPixel uses alpha 0.4,
                -- AGS uses ZO_NORMAL_TEXT. Restore them for pooled rows without a trait.
                rowControl.cwSellerStyle = rowControl.cwSellerStyle or
                    { label:GetAlpha(), label:GetColor() }
                local trait = GetItemLinkTraitInfo(result.itemLink)
                if trait == ITEM_TRAIT_TYPE_NONE then
                    local alpha, r, g, b, a = unpack(rowControl.cwSellerStyle)
                    label:SetAlpha(alpha)
                    label:SetColor(r, g, b, a)
                else
                    label:SetText(GetString("SI_ITEMTRAITTYPE", trait))
                    label:SetAlpha(1)
                    label:SetColor(0.8, 0.8, 0.8, 1)
                end
            end)
        end, 0)
    end)
end
