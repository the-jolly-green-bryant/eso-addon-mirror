--[[
=============================================================================
 AuctionHouse - ListingUI
 Sell dialog popup and buy confirmation.
 Uses GetControl() with full names to match XML.
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils
local LM = AH.ListingManager

AH.ListingUI = {}
local LUI = AH.ListingUI

local BUY_DIALOG = "AH_BUY_CONFIRM"
local currentSellItem = nil
local selectedDurationIndex = 3

local function C(name) return GetControl(name) end

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function LUI.Initialize()
    Utils.Debug("ListingUI: Initializing")

    ESO_Dialogs[BUY_DIALOG] = {
        title = { text = "Confirm Purchase" },
        mainText = { text = "<<1>>" },
        buttons = {
            {
                text = "Buy",
                callback = function(dialog)
                    if dialog.data and dialog.data.onConfirm then dialog.data.onConfirm() end
                end,
            },
            { text = "Cancel" },
        },
    }

    LUI.SetupSellDialog()
    Utils.Debug("ListingUI: Initialized")
end

---------------------------------------------------------------------------
--  Sell Dialog Setup
---------------------------------------------------------------------------

function LUI.SetupSellDialog()
    local dialog = C("AuctionHouseSellDialog")
    if not dialog then return end

    dialog:SetHandler("OnMouseDown", function() dialog:StartMoving() end)
    dialog:SetHandler("OnMouseUp", function() dialog:StopMovingOrResizing() end)

    -- Duration dropdown: AuctionHouseSellDialogDurationDD
    local durDD = C("AuctionHouseSellDialogDurationDD")
    if durDD then
        LUI.durationDropdown = ZO_ComboBox_ObjectFromContainer(durDD)
        if LUI.durationDropdown then
            LUI.durationDropdown:ClearItems()
            for i, dur in ipairs(LM.Durations) do
                local entry = LUI.durationDropdown:CreateItemEntry(dur.label, function()
                    selectedDurationIndex = i
                end)
                LUI.durationDropdown:AddItem(entry)
            end
            LUI.durationDropdown:SelectItemByIndex(3)
        end
    end

    -- Price input - create in Lua
    local priceBoxParent = C("AuctionHouseSellDialogPriceBox")
    if priceBoxParent then
        local bg = WINDOW_MANAGER:CreateControl("AH_SellPriceBG", priceBoxParent, CT_BACKDROP)
        bg:SetDimensions(200, 32)
        bg:SetAnchorFill(priceBoxParent)
        bg:SetCenterColor(0, 0, 0, 0.8)
        bg:SetEdgeColor(0.4, 0.4, 0.4, 1)
        bg:SetEdgeTexture("", 1, 1, 1)

        local priceInput = WINDOW_MANAGER:CreateControlFromVirtual("AH_SellPriceEdit", priceBoxParent, "ZO_DefaultEditForBackdrop")
        priceInput:SetAnchor(TOPLEFT, bg, TOPLEFT, 6, 2)
        priceInput:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -6, -2)
        priceInput:SetFont("ZoFontGame")
        priceInput:SetMaxInputChars(12)
        ZO_EditDefaultText_Initialize(priceInput, "Enter price...")

        LUI.priceInput = priceInput
        priceInput:SetHandler("OnTextChanged", function() LUI.UpdateFeeDisplay() end)
        priceInput:SetHandler("OnEnter", function() LUI.OnConfirmSell() end)
    end

    -- Confirm button
    local confirmBtn = C("AuctionHouseSellDialogConfirmBtn")
    if confirmBtn then
        confirmBtn:SetHandler("OnClicked", function() LUI.OnConfirmSell() end)
    end

    -- Cancel button
    local cancelBtn = C("AuctionHouseSellDialogCancelBtn")
    if cancelBtn then
        cancelBtn:SetHandler("OnClicked", function() LUI.HideSellDialog() end)
    end
end

---------------------------------------------------------------------------
--  Show Sell Dialog
---------------------------------------------------------------------------

function LUI.ShowSellDialog(itemInfo)
    if not itemInfo then return end
    local dialog = C("AuctionHouseSellDialog")
    if not dialog then return end

    currentSellItem = itemInfo

    -- Icon
    local iconTexture = C("AuctionHouseSellDialogItemRowIcon")
    if iconTexture and itemInfo.icon then iconTexture:SetTexture(itemInfo.icon) end

    -- Name
    local nameLabel = C("AuctionHouseSellDialogItemRowName")
    if nameLabel then
        local qc = AH.QualityColors[itemInfo.quality] or AH.Colors.WHITE
        nameLabel:SetText(Utils.Colorize(
            string.format("%s x%d", itemInfo.itemName, itemInfo.stackCount), qc))
    end

    -- Suggested price
    local sugLabel = C("AuctionHouseSellDialogSuggestedPrice")
    if sugLabel then
        if itemInfo.suggestedPrice and itemInfo.suggestedPrice > 0 then
            local total = itemInfo.suggestedPrice * itemInfo.stackCount
            sugLabel:SetText(string.format("Suggested: %s/each (%s total)",
                Utils.FormatGold(itemInfo.suggestedPrice),
                Utils.FormatGold(math.floor(total))))
        else
            sugLabel:SetText("No price data - set your own price")
        end
    end

    -- Undercut helper: show current market and undercut buttons
    local marketInfo = C("AuctionHouseSellDialogMarketInfo")
    local matchBtn = C("AuctionHouseSellDialogMatchBtn")
    local undercutBtn = C("AuctionHouseSellDialogUndercutBtn")

    local F = AH.Features
    local undercutInfo = F and F.GetUndercutInfo and F.GetUndercutInfo(itemInfo.itemId) or nil

    if marketInfo then
        if undercutInfo and undercutInfo.numListed > 0 then
            marketInfo:SetText(string.format("%d listed  |  Lowest: %s/ea",
                undercutInfo.numListed, Utils.FormatGold(undercutInfo.lowest)))
            marketInfo:SetHidden(false)
        else
            marketInfo:SetText("No competing listings found")
            marketInfo:SetHidden(false)
        end
    end

    if matchBtn then
        if undercutInfo and undercutInfo.matchPrice and undercutInfo.numListed > 0 then
            matchBtn:SetHidden(false)
            matchBtn:SetHandler("OnClicked", function()
                if LUI.priceInput then
                    local totalMatch = undercutInfo.matchPrice * itemInfo.stackCount
                    LUI.priceInput:SetText(tostring(math.floor(totalMatch)))
                    LUI.UpdateFeeDisplay()
                end
            end)
            matchBtn:SetHandler("OnMouseEnter", function(self)
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM,
                    string.format("Match lowest price: %s/ea", Utils.FormatGold(undercutInfo.matchPrice)))
            end)
            matchBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
        else
            matchBtn:SetHidden(true)
        end
    end

    if undercutBtn then
        if undercutInfo and undercutInfo.undercut and undercutInfo.numListed > 0 then
            undercutBtn:SetHidden(false)
            undercutBtn:SetHandler("OnClicked", function()
                if LUI.priceInput then
                    local totalUndercut = undercutInfo.undercut * itemInfo.stackCount
                    LUI.priceInput:SetText(tostring(math.floor(totalUndercut)))
                    LUI.UpdateFeeDisplay()
                end
            end)
            undercutBtn:SetHandler("OnMouseEnter", function(self)
                ZO_Tooltips_ShowTextTooltip(self, BOTTOM,
                    string.format("Undercut by 1%%: %s/ea", Utils.FormatGold(undercutInfo.undercut)))
            end)
            undercutBtn:SetHandler("OnMouseExit", function() ZO_Tooltips_HideTextTooltip() end)
        else
            undercutBtn:SetHidden(true)
        end
    end

    -- Pre-fill price
    if LUI.priceInput then
        if itemInfo.suggestedPrice and itemInfo.suggestedPrice > 0 then
            LUI.priceInput:SetText(tostring(math.floor(itemInfo.suggestedPrice * itemInfo.stackCount)))
        else
            LUI.priceInput:SetText("")
        end
    end

    LUI.UpdateFeeDisplay()

    selectedDurationIndex = 3
    if LUI.durationDropdown then LUI.durationDropdown:SelectItemByIndex(3) end

    dialog:SetHidden(false)
    SetGameCameraUIMode(true)
    if LUI.priceInput then LUI.priceInput:TakeFocus() end
end

function LUI.HideSellDialog()
    local dialog = C("AuctionHouseSellDialog")
    if dialog then dialog:SetHidden(true) end
    currentSellItem = nil
end

---------------------------------------------------------------------------
--  Fee Display
---------------------------------------------------------------------------

function LUI.UpdateFeeDisplay()
    local feeLabel = C("AuctionHouseSellDialogFeeLabel")
    if not feeLabel then return end
    local price = LUI.priceInput and (tonumber(LUI.priceInput:GetText()) or 0) or 0
    if price > 0 then
        feeLabel:SetText(string.format("Fee: %s", Utils.FormatGold(LM.CalculateFee(price))))
    else
        feeLabel:SetText(string.format("Fee: %s min", Utils.FormatGold(LM.MIN_LISTING_FEE)))
    end
end

---------------------------------------------------------------------------
--  Confirm Sell
---------------------------------------------------------------------------

function LUI.OnConfirmSell()
    if not currentSellItem then Utils.PrintError("No item selected.") return end
    local price = LUI.priceInput and (tonumber(LUI.priceInput:GetText()) or 0) or 0
    if price <= 0 then Utils.PrintError("Enter a valid price.") return end
    LM.ConfirmListing(currentSellItem, price, currentSellItem.stackCount, selectedDurationIndex)
    LUI.HideSellDialog()
end

---------------------------------------------------------------------------
--  Buy Confirmation
---------------------------------------------------------------------------

function LUI.ShowBuyConfirmation(listing, onConfirm)
    if not listing then return end

    local comparison = ""
    if AH.PriceTracker then
        local info = AH.PriceTracker.GetPriceInfo(listing.itemLink)
        if info and info.suggested and info.suggested > 0 then
            local ratio = (listing.unitPrice or listing.price) / info.suggested
            if ratio <= 0.8 then comparison = "\n|c44DD44Great deal!|r"
            elseif ratio <= 1.1 then comparison = "\n|cAAAAAAFair price.|r"
            else comparison = "\n|cDD4444Above market.|r" end
        end
    end

    local text = string.format(
        "%s x%d\nSeller: %s\nPrice: %d gold%s\n\nThe seller will send a COD mail.\nAccept the COD to complete the purchase.",
        listing.itemName or "Unknown", listing.quantity or 1,
        listing.seller or "Unknown", listing.price or 0, comparison)

    ZO_Dialogs_ShowDialog(BUY_DIALOG, {
        onConfirm = onConfirm,
    }, { mainTextParams = { text } })
end
