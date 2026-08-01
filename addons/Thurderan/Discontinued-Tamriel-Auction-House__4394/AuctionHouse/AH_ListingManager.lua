--[[
=============================================================================
 AuctionHouse - ListingManager
 Independent auction system using COD mail for safe transactions.
 No guild store scanning - this is a standalone auction house.
=============================================================================
]]--

local AH = AuctionHouse
local Utils = AH.Utils

AH.ListingManager = {}
local LM = AH.ListingManager

LM.States = {
    LISTED          = "listed",
    AWAITING_COD    = "awaiting_cod",
    COD_SENT        = "cod_sent",
    COMPLETE        = "complete",
    CANCELLED       = "cancelled",
    EXPIRED         = "expired",
}

LM.Durations = {
    { label = "12 Hours",   seconds = 43200 },
    { label = "24 Hours",   seconds = 86400 },
    { label = "48 Hours",   seconds = 172800 },
    { label = "3 Days",     seconds = 259200 },
    { label = "7 Days",     seconds = 604800 },
}

LM.LISTING_FEE_PERCENT = 0
LM.MIN_LISTING_FEE = 0

local pendingCODSend = nil
local pendingSyncReload = nil  -- Delayed ReloadUI after queuing sync actions

LM.batchMode = false  -- When true, don't auto-ReloadUI on buy/sell

---------------------------------------------------------------------------
--  Initialization
---------------------------------------------------------------------------

function LM.Initialize()
    Utils.Debug("ListingManager: Initializing")

    if not AH.savedVars.myListings then AH.savedVars.myListings = {} end
    if not AH.savedVars.myPurchases then AH.savedVars.myPurchases = {} end
    if not AH.savedVars.codQueue then AH.savedVars.codQueue = {} end

    -- Clean up cancelled/completed purchases on startup
    for id, p in pairs(AH.savedVars.myPurchases) do
        if p.state == LM.States.CANCELLED or p.state == LM.States.COMPLETED then
            AH.savedVars.myPurchases[id] = nil
        end
    end

    EVENT_MANAGER:RegisterForEvent(AH.name .. "_MailSent",
        EVENT_MAIL_SEND_SUCCESS, LM.OnMailSendSuccess)
    EVENT_MANAGER:RegisterForEvent(AH.name .. "_MailFail",
        EVENT_MAIL_SEND_FAILED, LM.OnMailSendFailed)

    -- COD verification: check incoming mail against purchases
    EVENT_MANAGER:RegisterForEvent(AH.name .. "_MailRead",
        EVENT_MAIL_READABLE, LM.OnMailReadable)

    -- Track when COD mail is accepted (mail removed after taking attachment)
    EVENT_MANAGER:RegisterForEvent(AH.name .. "_MailRemoved",
        EVENT_MAIL_REMOVED, LM.OnMailRemoved)

    -- Track when buyer takes item from COD mail
    EVENT_MANAGER:RegisterForEvent(AH.name .. "_MailTakeItem",
        EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, LM.OnMailTakeItem)

    -- Initialize persisted verified mail tracking
    if not AH.savedVars.verifiedCODMails then AH.savedVars.verifiedCODMails = {} end

    LM.HookInventory()

    EVENT_MANAGER:RegisterForUpdate(AH.name .. "_CODCheck",
        10000, LM.CheckIncomingPurchases)
    EVENT_MANAGER:RegisterForUpdate(AH.name .. "_ExpiryCheck",
        60000, LM.CheckExpiredListings)

    LM.InitializeDialogs()

    -- Re-lock active listed items after inventory loads (short delay)
    zo_callLater(function() LM.RelockActiveListings() end, 2000)

    Utils.Debug("ListingManager: Initialized")
end

---------------------------------------------------------------------------
--  SELLER: Creating Listings
---------------------------------------------------------------------------

function LM.ListItem(bagId, slotIndex)
    local itemLink = GetItemLink(bagId, slotIndex)
    if not itemLink or itemLink == "" then
        Utils.PrintError("No item selected.")
        return
    end
    if IsItemBound(bagId, slotIndex) then
        Utils.PrintError("%s is bound and cannot be traded.", Utils.GetCleanItemName(itemLink))
        return
    end

    local _, stackCount = GetItemInfo(bagId, slotIndex)
    local suggestedPrice = 0
    if AH.PriceTracker and AH.PriceTracker.GetSuggestedPrice then
        suggestedPrice = AH.PriceTracker.GetSuggestedPrice(itemLink) or 0
    end

    AH._pendingListItem = {
        bagId           = bagId,
        slotIndex       = slotIndex,
        itemLink        = itemLink,
        itemName        = Utils.GetCleanItemName(itemLink),
        itemId          = Utils.GetItemIDFromLink(itemLink),
        icon            = Utils.GetItemIcon(itemLink),
        stackCount      = stackCount,
        quality         = Utils.GetItemQuality(itemLink),
        level           = GetItemLinkRequiredLevel(itemLink),
        championPoints  = GetItemLinkRequiredChampionPoints(itemLink),
        traitType       = GetItemLinkTraitType(itemLink),
        itemType        = GetItemLinkItemType(itemLink),
        suggestedPrice  = math.floor(suggestedPrice),
    }

    -- Show the sell dialog popup
    if AH.ListingUI then
        AH.ListingUI.ShowSellDialog(AH._pendingListItem)
    else
        local qc = AH.QualityColors[AH._pendingListItem.quality] or AH.Colors.WHITE
        Utils.Print("Selected: %s x%d",
            Utils.Colorize(AH._pendingListItem.itemName, qc), stackCount)
        Utils.Print("To list, type: %s",
            Utils.Colorize("/ah sell <total price>", AH.Colors.HIGHLIGHT))
    end
end

function LM.ConfirmListing(itemInfo, price, quantity, durationIndex)
    if not itemInfo or price <= 0 then
        Utils.PrintError("Invalid listing parameters.")
        return
    end
    quantity = quantity or itemInfo.stackCount
    durationIndex = durationIndex or 3
    local duration = LM.Durations[durationIndex] or LM.Durations[3]

    local currentLink = GetItemLink(itemInfo.bagId, itemInfo.slotIndex)
    if currentLink ~= itemInfo.itemLink then
        Utils.PrintError("Item no longer found in that inventory slot.")
        return
    end

    local listingId = LM.GenerateListingId()
    local now = Utils.GetTimestamp()

    local listing = {
        id              = listingId,
        itemLink        = itemInfo.itemLink,
        itemName        = itemInfo.itemName,
        itemId          = itemInfo.itemId,
        icon            = itemInfo.icon,
        quality         = itemInfo.quality,
        level           = itemInfo.level,
        championPoints  = itemInfo.championPoints,
        traitType       = itemInfo.traitType,
        itemType        = itemInfo.itemType,
        tooltipData     = Utils.ExtractTooltipData(itemInfo.itemLink),
        quantity        = quantity,
        price           = price,
        unitPrice       = math.floor(price / math.max(quantity, 1)),
        fee             = fee,
        seller          = Utils.GetPlayerName(),
        characterName   = Utils.GetCharacterName(),
        duration        = duration.seconds,
        durationLabel   = duration.label,
        createdAt       = now,
        expiresAt       = now + duration.seconds,
        state           = LM.States.LISTED,
        buyer           = nil,
        bagId           = itemInfo.bagId,
        slotIndex       = itemInfo.slotIndex,
    }

    AH.savedVars.myListings[listingId] = listing
    LM.QueueForSyncAuto(listing, "create")

    -- Lock the item to prevent accidental sale/decon/destroy
    LM.LockListedItem(itemInfo.bagId, itemInfo.slotIndex)

    local qc = AH.QualityColors[itemInfo.quality] or AH.Colors.WHITE
    Utils.Print("Listed %s x%d for %s. Expires in %s.",
        Utils.Colorize(itemInfo.itemName, qc), quantity,
        Utils.Colorize(Utils.FormatGold(price), AH.Colors.HIGHLIGHT),
        duration.label)

    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
end

function LM.CancelListing(listingId)
    local listing = AH.savedVars.myListings[listingId]
    if not listing then Utils.PrintError("Listing not found.") return end
    if listing.state ~= LM.States.LISTED then
        Utils.PrintError("Cannot cancel: state is '%s'.", listing.state)
        return
    end
    listing.state = LM.States.CANCELLED
    LM.UnlockListedItem(listing)
    LM.QueueForSyncAndReload(listing, "cancel")
    Utils.Print("Cancelled listing for %s.", Utils.Colorize(listing.itemName, AH.Colors.NEUTRAL))
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
end

--- Cancel ALL active listings on the server and locally.
function LM.CancelAllListings()
    -- Cancel local listings
    local count = 0
    for id, listing in pairs(AH.savedVars.myListings) do
        if listing.state == LM.States.LISTED then
            listing.state = LM.States.CANCELLED
            LM.UnlockListedItem(listing)
            LM.QueueForSync(listing, "cancel")
            count = count + 1
        end
    end

    -- Also queue a special "cancel_all" action for the server
    -- This handles listings that exist on the server but not locally
    LM.QueueForSyncAndReload({ cancelAll = true }, "cancel_all")

    if count > 0 then
        Utils.Print("Cancelled %d local listings.", count)
    end
    Utils.Print("Sent cancel-all request to server. Do /ah refresh to sync.")
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
end

--- Release a stuck reservation back to the market.
function LM.ReleaseListing(listingId)
    local listing = AH.savedVars.myListings[listingId]
    local codInfo = AH.savedVars.codQueue[listingId]

    if not listing and not codInfo then
        Utils.PrintError("Listing not found.")
        return
    end

    -- Release from COD queue
    if codInfo then
        local itemName = codInfo.itemName or "Unknown"
        local buyer = codInfo.buyer or "Unknown"
        AH.savedVars.codQueue[listingId] = nil

        Utils.Print("Released %s back to market. %s's purchase was cancelled.",
            Utils.Colorize(itemName, AH.Colors.NEUTRAL),
            Utils.Colorize(buyer, AH.Colors.WHITE))
    end

    -- Reset listing back to listed state
    if listing then
        listing.state = LM.States.LISTED
        listing.buyer = nil
    end

    -- Tell the server to release it
    LM.QueueForSyncAndReload({ id = listingId, state = LM.States.LISTED }, "release")

    PlaySound(SOUNDS.QUEST_ABANDONED)
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
end

---------------------------------------------------------------------------
--  BUYER: Purchasing
---------------------------------------------------------------------------

function LM.BuyItem(listing)
    if not listing or not listing.id then Utils.PrintError("Invalid listing.") return end
    if listing.seller == Utils.GetPlayerName() then
        Utils.PrintError("You cannot buy your own listing.")
        return
    end
    local playerGold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    if playerGold < listing.price then
        Utils.PrintError("You need %s. You have %s.",
            Utils.FormatGold(listing.price), Utils.FormatGold(playerGold))
        return
    end
    if AH.ListingUI then
        AH.ListingUI.ShowBuyConfirmation(listing, function() LM.ExecutePurchase(listing) end)
    else
        LM.ExecutePurchase(listing)
    end
end

function LM.ExecutePurchase(listing)
    AH.savedVars.myPurchases[listing.id] = {
        listingId   = listing.id,
        seller      = listing.seller,
        price       = listing.price,
        itemName    = listing.itemName or "Unknown",
        itemLink    = listing.itemLink or "",
        quantity    = listing.quantity or 1,
        quality     = listing.quality or 1,
        state       = LM.States.AWAITING_COD,
        purchasedAt = Utils.GetTimestamp(),
    }
    LM.QueueForSyncAuto({
        id = listing.id, state = LM.States.AWAITING_COD,
        buyer = Utils.GetPlayerName(), soldAt = Utils.GetTimestamp(),
    }, "purchase")

    -- Mark this listing as no longer available in browse
    -- (update local cache so it disappears from search immediately)
    if listing.state then listing.state = LM.States.AWAITING_COD end
    if AH.DataManager and AH.DataManager.MarkListingPurchased then
        AH.DataManager.MarkListingPurchased(listing.id)
    end

    Utils.Print("Purchase committed! %s will send you a COD mail.",
        Utils.Colorize(listing.seller, AH.Colors.WHITE))
    Utils.Print("If the seller doesn't respond, type %s to cancel.",
        Utils.Colorize("/ah cancelbuy " .. listing.id, AH.Colors.HIGHLIGHT))
    -- Invalidate search cache and refresh UI
    if AH.SearchEngine and AH.SearchEngine.InvalidateCache then
        AH.SearchEngine.InvalidateCache()
    end
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
    CALLBACK_MANAGER:FireCallbacks(AH.Events.UI_REFRESH_NEEDED)
end

--- Buyer cancels their own purchase. This counts as a strike.
function LM.CancelPurchase(listingId)
    local purchase = AH.savedVars.myPurchases[listingId]
    if not purchase then
        Utils.PrintError("Purchase not found.")
        return
    end
    if purchase.state ~= LM.States.AWAITING_COD then
        Utils.PrintError("Cannot cancel: state is '%s'.", purchase.state)
        return
    end

    purchase.state = LM.States.CANCELLED
    LM.QueueForSyncAndReload({ id = listingId }, "cancel_purchase")

    Utils.Print("Cancelled your purchase of %s. The listing is back on the market.",
        Utils.Colorize(purchase.itemName or "Unknown", AH.Colors.NEUTRAL))
    Utils.Print("%s This counts toward your cancellation limit.",
        Utils.Colorize("Note:", AH.Colors.YELLOW))

    -- Remove from purchases tab
    AH.savedVars.myPurchases[listingId] = nil
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
end

---------------------------------------------------------------------------
--  SELLER: COD Send
---------------------------------------------------------------------------

function LM.OnItemPurchased(listingId, buyerName)
    local listing = AH.savedVars.myListings[listingId]
    if not listing then return end

    -- Check if seller already cancelled this listing locally
    if listing.state == LM.States.CANCELLED then
        Utils.Print("%s Someone bought %s but you already cancelled it. Auto-releasing back to market.",
            Utils.Colorize("⚠", AH.Colors.YELLOW),
            Utils.Colorize(listing.itemName or "item", AH.Colors.NEUTRAL))
        LM.QueueForSyncAndReload({ id = listingId, state = LM.States.LISTED }, "release")
        return
    end

    listing.state = LM.States.AWAITING_COD
    listing.buyer = buyerName

    -- Unlock the item so seller can send it via COD mail
    LM.UnlockListedItem(listing)

    AH.savedVars.codQueue[listingId] = {
        listingId = listingId, buyer = buyerName,
        itemName = listing.itemName, itemLink = listing.itemLink,
        quantity = listing.quantity, price = listing.price,
        quality = listing.quality,
        characterName = listing.characterName,
        state = LM.States.AWAITING_COD,
        bagId = listing.bagId, slotIndex = listing.slotIndex,
    }

    PlaySound(SOUNDS.TELVAR_GAINED)
    local qc = AH.QualityColors[listing.quality] or AH.Colors.WHITE
    Utils.Print("")
    Utils.Print("%s %s purchased your %s x%d for %s!",
        Utils.Colorize("★ SOLD!", AH.Colors.POSITIVE),
        Utils.Colorize(buyerName, AH.Colors.WHITE),
        Utils.Colorize(listing.itemName, qc), listing.quantity,
        Utils.Colorize(Utils.FormatGold(listing.price), AH.Colors.HIGHLIGHT))
    if listing.characterName and listing.characterName ~= "" then
        Utils.Print("Send COD from %s. Open TAH -> COD Queue.",
            Utils.Colorize(listing.characterName, AH.Colors.HIGHLIGHT))
    else
        Utils.Print("Open Tamriel Auction House -> COD Queue to send it.")
    end

    -- Show popup notification
    LM.ShowSaleNotification(buyerName, listing.itemName, listing.price, listing.quantity)
end

function LM.SendCOD(listingId)
    local codInfo = AH.savedVars.codQueue[listingId]
    if not codInfo then Utils.PrintError("No pending COD for that listing.") return end

    -- Check if the listing is still in awaiting_cod state
    -- (it might have been released or the reservation expired)
    local listing = AH.savedVars.myListings[listingId]
    if listing and listing.state ~= LM.States.AWAITING_COD then
        Utils.PrintError("This sale is no longer active (state: %s).", listing.state)
        Utils.PrintError("The buyer may have cancelled or the reservation expired.")
        AH.savedVars.codQueue[listingId] = nil
        CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
        return
    end

    -- Check the server-synced listings to make sure buyer is still committed
    local incoming = AH.savedVars.incoming
    if incoming and incoming.ah_listings then
        local serverListing = incoming.ah_listings[listingId]
        if serverListing and serverListing.state == "listed" then
            Utils.PrintError("This reservation has expired on the server. The listing is back on the market.")
            Utils.Print("Do NOT send this COD — the buyer is no longer committed.")
            AH.savedVars.codQueue[listingId] = nil
            if listing then listing.state = LM.States.LISTED; listing.buyer = nil end
            CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
            return
        end
    end

    local itemLink = GetItemLink(codInfo.bagId, codInfo.slotIndex)
    local itemFound = (itemLink == codInfo.itemLink)

    if not itemFound then
        local fb, fs = LM.FindItemInInventory(codInfo.itemLink)
        if fb then codInfo.bagId = fb codInfo.slotIndex = fs itemFound = true end
    end

    if not itemFound then
        Utils.PrintError("Cannot find %s in your inventory!", codInfo.itemName)
        return
    end

    pendingCODSend = codInfo
    -- Use short ID in subject (last 2 segments of listingId to stay under 64 char limit)
    local shortId = codInfo.listingId:match("_(%d+_%d+)$") or codInfo.listingId:sub(-12)
    local subject = string.format("[AH:%s] %s", shortId, codInfo.itemName)
    -- Truncate subject to 64 chars (ESO limit)
    if #subject > 64 then
        subject = subject:sub(1, 64)
    end
    local body = string.format(
        "Tamriel Auction House Delivery\nItem: %s x%d\nCOD: %d gold\nListing: %s",
        codInfo.itemName, codInfo.quantity, codInfo.price, codInfo.listingId)

    -- Open the mail send scene so the player can verify and send
    SCENE_MANAGER:Show("mailSend")

    -- Pre-fill after a short delay to let the scene load
    zo_callLater(function()
        -- Set recipient
        if MAIL_SEND.to and MAIL_SEND.to.SetText then
            MAIL_SEND.to:SetText(codInfo.buyer)
        end
        -- Set subject
        if MAIL_SEND.subject and MAIL_SEND.subject.SetText then
            MAIL_SEND.subject:SetText(subject)
        end
        -- Set body
        if MAIL_SEND.body and MAIL_SEND.body.SetText then
            MAIL_SEND.body:SetText(body)
        end

        -- Attach the item
        ClearQueuedMail()
        QueueItemAttachment(codInfo.bagId, codInfo.slotIndex, codInfo.quantity)

        -- Select COD radio button
        if MAIL_SEND.radioButtonGroup and MAIL_SEND.codRadioButton then
            MAIL_SEND.radioButtonGroup:SetClickedButton(MAIL_SEND.codRadioButton)
            MAIL_SEND.sendMoneyMode = false
        end

        Utils.Print("Mail compose opened — set COD to %s and click Send.",
            Utils.Colorize(Utils.FormatGold(codInfo.price), AH.Colors.HIGHLIGHT))
    end, 300)

    Utils.Print("Opening mail to %s...", Utils.Colorize(codInfo.buyer, AH.Colors.WHITE))
    Utils.Print("Verify the COD amount and click Send to complete the sale.")
end

function LM.OnMailSendSuccess(eventCode)
    if not pendingCODSend then return end
    local codInfo = pendingCODSend
    pendingCODSend = nil

    local listing = AH.savedVars.myListings[codInfo.listingId]
    if listing then listing.state = LM.States.COD_SENT end
    AH.savedVars.codQueue[codInfo.listingId] = nil
    LM.QueueForSyncAndReload({ id = codInfo.listingId, state = LM.States.COD_SENT }, "cod_sent")

    Utils.Print("%s COD sent to %s!",
        Utils.Colorize("✓", AH.Colors.POSITIVE),
        Utils.Colorize(codInfo.buyer, AH.Colors.WHITE))
    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
end

function LM.OnMailSendFailed(eventCode, reason)
    if pendingCODSend then
        Utils.PrintError("COD failed (error %d). Try again.", reason)
        pendingCODSend = nil
    end
end

---------------------------------------------------------------------------
--  BUYER: COD Mail Verification
---------------------------------------------------------------------------

function LM.OnMailReadable(eventCode, mailId)
    -- Check if this COD mail matches a pending purchase
    local senderDisplayName, senderCharacterName, subject, _, _, _, _, _, _, _, codAmount = GetMailItemInfo(mailId)
    local senderName = senderDisplayName or ""

    -- Only check mails that look like AH deliveries
    if not subject or not string.find(subject, "%[AH") then return end
    if not codAmount or codAmount == 0 then return end

    -- Extract listing ID from subject "[AH:listingId] Item Name"
    local subjectListingId = subject:match("%[AH:([^%]]+)%]")

    -- Find matching purchase
    local matchedPurchase = nil
    local matchedId = nil

    -- Best match: by listing ID (may be partial — last 2 segments)
    if subjectListingId then
        for id, purchase in pairs(AH.savedVars.myPurchases) do
            if purchase.state == LM.States.AWAITING_COD then
                local lid = purchase.listingId or id
                -- Match full ID or partial (ends with the short ID)
                if lid == subjectListingId or lid:find(subjectListingId, 1, true) then
                    matchedPurchase = purchase
                    matchedId = id
                    break
                end
            end
        end
    end

    -- Fallback for old-format subjects "[AH] Item Name"
    if not matchedPurchase then
        local subjectItemName = subject:match("%[AH[^%]]*%]%s*(.*)")
        if subjectItemName then
            subjectItemName = subjectItemName:gsub("%^n", ""):gsub("%s+$", "")
        end
        for id, purchase in pairs(AH.savedVars.myPurchases) do
            if purchase.state == LM.States.AWAITING_COD and
               purchase.seller == senderName then
                local purchaseName = (purchase.itemName or ""):gsub("%^n", ""):gsub("%s+$", "")
                if subjectItemName and purchaseName == subjectItemName and purchase.price == codAmount then
                    matchedPurchase = purchase
                    matchedId = id
                    break
                end
            end
        end
    end

    if not matchedPurchase then return end

    -- Verify COD amount
    local warnings = {}
    if codAmount ~= matchedPurchase.price then
        table.insert(warnings, string.format(
            "COD amount mismatch! Expected %s, but COD is %s",
            Utils.FormatGold(matchedPurchase.price),
            Utils.FormatGold(codAmount)))
    end

    -- Verify attached item by name (links can differ due to formatting)
    local numAttachments = GetMailAttachmentInfo(mailId)
    if numAttachments and numAttachments > 0 then
        local attachLink = GetAttachedItemLink(mailId, 1, LINK_STYLE_BRACKETS)
        local receivedName = (GetItemLinkName(attachLink) or ""):gsub("%^n", ""):gsub("%s+$", ""):lower()
        local expectedName = (matchedPurchase.itemName or ""):gsub("%^n", ""):gsub("%s+$", ""):lower()
        if receivedName ~= "" and expectedName ~= "" and receivedName ~= expectedName then
            table.insert(warnings, string.format(
                "Item mismatch! Expected %s, but received %s",
                matchedPurchase.itemName or "Unknown",
                GetItemLinkName(attachLink) or "Unknown"))
        end
    end

    -- Show warnings or confirmation
    if #warnings > 0 then
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        Utils.Print("")
        Utils.Print(Utils.Colorize("⚠ WARNING — COD VERIFICATION FAILED", AH.Colors.NEGATIVE))
        for _, w in ipairs(warnings) do
            Utils.Print(Utils.Colorize("  " .. w, AH.Colors.NEGATIVE))
        end
        Utils.Print(Utils.Colorize("  DO NOT accept this COD! The seller may be trying to scam you.", AH.Colors.NEGATIVE))
        Utils.Print(Utils.Colorize("  You can decline it and cancel your purchase with /ah cancelbuy", AH.Colors.YELLOW))
        Utils.Print("")

        -- Show warning popup
        LM.ShowWarningDialog(
            "COD Verification Failed",
            table.concat(warnings, "\n") .. "\n\nDo NOT accept this COD mail. Decline it and report the seller.")
    else
        -- Track this mail so we can mark purchase complete when accepted
        -- Persisted in SavedVariables so it survives /reloadui
        AH.savedVars.verifiedCODMails[tostring(mailId)] = {
            purchaseId = matchedId,
            listingId = matchedPurchase.listingId or matchedId,
        }
        Utils.Print(Utils.Colorize("✓ COD verified", AH.Colors.POSITIVE) ..
            " — item and price match your purchase from " ..
            Utils.Colorize(senderName, AH.Colors.WHITE))
    end
end

--- Called when buyer takes item attachment from a COD mail.
function LM.OnMailTakeItem(eventCode, mailId)
    LM._CompletePurchaseFromMail(mailId)
end

function LM.OnMailRemoved(eventCode, mailId)
    LM._CompletePurchaseFromMail(mailId)
end

--- Shared logic: mark a purchase as completed based on a verified COD mail.
function LM._CompletePurchaseFromMail(mailId)
    local key = tostring(mailId)
    if not AH.savedVars.verifiedCODMails then return end
    local tracked = AH.savedVars.verifiedCODMails[key]
    if not tracked then return end
    AH.savedVars.verifiedCODMails[key] = nil

    -- Mark purchase as completed
    local purchase = AH.savedVars.myPurchases[tracked.purchaseId]
    if purchase then
        purchase.state = LM.States.COMPLETED
        LM.QueueForSyncAndReload({ id = tracked.listingId, state = LM.States.COMPLETED }, "complete_purchase")

        PlaySound(SOUNDS.QUEST_COMPLETED)
        Utils.Print("%s Purchase of %s completed!",
            Utils.Colorize("✓", AH.Colors.POSITIVE),
            Utils.Colorize(purchase.itemName or "item", AH.Colors.WHITE))
        CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
    end
end

---------------------------------------------------------------------------
--  UI: Sale Notification Popup
---------------------------------------------------------------------------

local SALE_DIALOG_NAME = "AH_SALE_NOTIFICATION"
local WARNING_DIALOG_NAME = "AH_COD_WARNING"

function LM.InitializeDialogs()
    -- Sale notification dialog
    ESO_Dialogs[SALE_DIALOG_NAME] = {
        title = { text = "Tamriel Auction House" },
        mainText = { text = "<<1>>" },
        buttons = {
            [1] = {
                text = "Open COD Queue",
                callback = function()
                    if AH.UI then
                        AH.UI.Show()
                        AH.UI.SwitchTab("codqueue")
                    end
                end,
            },
            [2] = {
                text = "Dismiss",
            },
        },
    }

    -- COD warning dialog
    ESO_Dialogs[WARNING_DIALOG_NAME] = {
        title = { text = "⚠ COD Verification Failed" },
        mainText = { text = "<<1>>" },
        buttons = {
            [1] = {
                text = "OK",
            },
        },
    }
end

function LM.ShowSaleNotification(buyerName, itemName, price, quantity)
    if not ESO_Dialogs[SALE_DIALOG_NAME] then LM.InitializeDialogs() end

    local msg = string.format(
        "%s purchased your %s x%d for %s!\n\nOpen the COD Queue to send the item.",
        buyerName, itemName, quantity, Utils.FormatGold(price))

    ZO_Dialogs_ShowDialog(SALE_DIALOG_NAME, nil, { mainTextParams = { msg } })
end

function LM.ShowWarningDialog(title, message)
    if not ESO_Dialogs[WARNING_DIALOG_NAME] then LM.InitializeDialogs() end
    ZO_Dialogs_ShowDialog(WARNING_DIALOG_NAME, nil, { mainTextParams = { message } })
end

---------------------------------------------------------------------------
--  Helpers
---------------------------------------------------------------------------

--- Lock an item in inventory so it can't be sold/deconstructed/destroyed.
--- Uses FCO ItemSaver if available (works on all items), falls back to native lock (equipment only).
function LM.LockListedItem(bagId, slotIndex)
    if not bagId or not slotIndex then return end
    -- Try FCOIS first (works on everything)
    if FCOIS and FCOIS.MarkItem then
        local iconId = FCOIS_CON_ICON_LOCK or 1
        if not FCOIS.IsMarked(bagId, slotIndex, iconId) then
            FCOIS.MarkItem(bagId, slotIndex, iconId, true, true)
            Utils.Debug("FCOIS locked item at bag=%d slot=%d", bagId, slotIndex)
        end
        return
    end
    -- Fallback: native lock (equipment only)
    if CanItemBePlayerLocked(bagId, slotIndex) then
        if not IsItemPlayerLocked(bagId, slotIndex) then
            SetItemIsPlayerLocked(bagId, slotIndex, true)
            Utils.Debug("Native locked item at bag=%d slot=%d", bagId, slotIndex)
        end
    end
end

--- Unlock a previously locked listed item.
--- Uses FCO ItemSaver if available, falls back to native lock.
function LM.UnlockListedItem(listing)
    if not listing then return end
    local bagId, slotIndex = listing.bagId, listing.slotIndex
    -- Verify the item is still the same before unlocking
    if bagId and slotIndex then
        local currentLink = GetItemLink(bagId, slotIndex)
        if currentLink == listing.itemLink then
            LM._UnlockSlot(bagId, slotIndex)
            return
        end
    end
    -- Item may have moved slots — search inventory
    local foundBag, foundSlot = LM.FindItemInInventory(listing.itemLink)
    if foundBag and foundSlot then
        LM._UnlockSlot(foundBag, foundSlot)
    end
end

--- Internal: unlock a specific bag/slot.
function LM._UnlockSlot(bagId, slotIndex)
    if FCOIS and FCOIS.MarkItem then
        local iconId = FCOIS_CON_ICON_LOCK or 1
        if FCOIS.IsMarked(bagId, slotIndex, iconId) then
            FCOIS.MarkItem(bagId, slotIndex, iconId, false, true)
            Utils.Debug("FCOIS unlocked item at bag=%d slot=%d", bagId, slotIndex)
        end
        return
    end
    if CanItemBePlayerLocked(bagId, slotIndex) and IsItemPlayerLocked(bagId, slotIndex) then
        SetItemIsPlayerLocked(bagId, slotIndex, false)
        Utils.Debug("Native unlocked item at bag=%d slot=%d", bagId, slotIndex)
    end
end

--- Re-lock all active listings on addon load (items may have moved slots).
function LM.RelockActiveListings()
    if not AH.savedVars.myListings then return end
    local count = 0
    for _, listing in pairs(AH.savedVars.myListings) do
        if listing.state == LM.States.LISTED and listing.itemLink then
            local bagId, slotIndex = listing.bagId, listing.slotIndex
            local currentLink = bagId and slotIndex and GetItemLink(bagId, slotIndex) or ""
            if currentLink ~= listing.itemLink then
                -- Item moved — find it
                bagId, slotIndex = LM.FindItemInInventory(listing.itemLink)
                if bagId and slotIndex then
                    listing.bagId = bagId
                    listing.slotIndex = slotIndex
                end
            end
            if bagId and slotIndex then
                LM.LockListedItem(bagId, slotIndex)
                count = count + 1
            end
        end
    end
    if count > 0 then
        Utils.Debug("Re-locked %d active listed items", count)
    end
end

function LM.FindItemInInventory(targetLink)
    for _, bagId in ipairs({ BAG_BACKPACK, BAG_BANK }) do
        for slot = 0, GetBagSize(bagId) - 1 do
            if GetItemLink(bagId, slot) == targetLink then return bagId, slot end
        end
    end
    return nil, nil
end

function LM.CheckIncomingPurchases()
    local incoming = AH.savedVars.incoming
    if not incoming then return end

    -- Process new purchases (seller side)
    if incoming.ah_purchases then
        for _, purchase in ipairs(incoming.ah_purchases) do
            if purchase.seller == Utils.GetPlayerName() and
               purchase.state == LM.States.AWAITING_COD then
                -- Skip if already in COD queue or already processed
                if AH.savedVars.codQueue[purchase.listingId] then
                    -- Already in queue, skip
                elseif AH.savedVars.myListings[purchase.listingId] and
                       (AH.savedVars.myListings[purchase.listingId].state == LM.States.AWAITING_COD or
                        AH.savedVars.myListings[purchase.listingId].state == LM.States.COD_SENT) then
                    -- Already processed (state already updated), skip
                else
                    LM.OnItemPurchased(purchase.listingId, purchase.buyer)
                end
            end
        end
    end

    -- Buyer side: sync purchase states from server
    -- The server returns our purchases with current states in ah_buyer_purchases
    if incoming.ah_buyer_purchases and AH.savedVars.myPurchases then
        -- Build lookup of server purchase states by listing ID
        local serverStates = {}
        for _, bp in ipairs(incoming.ah_buyer_purchases) do
            serverStates[bp.listingId] = bp.state
        end

        for id, purchase in pairs(AH.savedVars.myPurchases) do
            local listingId = purchase.listingId or id
            local serverState = serverStates[listingId]

            if serverState then
                if serverState == "completed" and purchase.state ~= LM.States.COMPLETED then
                    purchase.state = LM.States.COMPLETED
                    Utils.Print("%s Purchase of %s completed!",
                        Utils.Colorize("✓", AH.Colors.POSITIVE),
                        Utils.Colorize(purchase.itemName or "item", AH.Colors.WHITE))
                    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
                elseif serverState == "cod_sent" and purchase.state == LM.States.AWAITING_COD then
                    purchase.state = LM.States.COD_SENT
                    Utils.Print("COD for %s has been sent by the seller!",
                        Utils.Colorize(purchase.itemName or "item", AH.Colors.WHITE))
                    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
                end
            else
                -- Listing not in buyer_purchases — server has no active record
                if purchase.state == LM.States.AWAITING_COD or purchase.state == LM.States.COD_SENT then
                    -- Check if it's back as 'listed' in browse (seller released it)
                    local browseListing = incoming.ah_listings and incoming.ah_listings[listingId]
                    if browseListing and browseListing.state == "listed" then
                        Utils.Print("%s Your purchase of %s was released by the seller.",
                            Utils.Colorize("⚠", AH.Colors.YELLOW),
                            Utils.Colorize(purchase.itemName or "item", AH.Colors.NEUTRAL))
                        AH.savedVars.myPurchases[id] = nil
                        CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
                    else
                        -- Server has no record at all — listing was completed, cancelled, or expired
                        -- Mark as completed and remove
                        Utils.Debug("Purchase %s no longer on server — removing", listingId)
                        AH.savedVars.myPurchases[id] = nil
                        CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
                    end
                end
            end
        end
    end

    -- Process notifications for released/cancelled/expired reservations
    if incoming.ah_notifications then
        for _, notif in ipairs(incoming.ah_notifications) do
            local ntype = notif.type or (notif.data and notif.data.type) or ""
            local listingId = notif.listing_id or ""

            if ntype == "reservation_expired" or ntype == "purchase_cancelled" or ntype == "purchase_released" then
                -- Clean up COD queue if this was our listing
                if AH.savedVars.codQueue[listingId] then
                    local codInfo = AH.savedVars.codQueue[listingId]
                    AH.savedVars.codQueue[listingId] = nil

                    local listing = AH.savedVars.myListings[listingId]
                    if listing then
                        listing.state = LM.States.LISTED
                        listing.buyer = nil
                    end

                    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                    if ntype == "purchase_cancelled" then
                        Utils.Print("%s %s cancelled their purchase of %s. Listing is back on the market.",
                            Utils.Colorize("⚠", AH.Colors.YELLOW),
                            Utils.Colorize(codInfo.buyer or "Buyer", AH.Colors.WHITE),
                            Utils.Colorize(codInfo.itemName or "item", AH.Colors.NEUTRAL))
                    elseif ntype == "reservation_expired" then
                        Utils.Print("%s Reservation expired for %s. Listing is back on the market.",
                            Utils.Colorize("⚠", AH.Colors.YELLOW),
                            Utils.Colorize(codInfo.itemName or "item", AH.Colors.NEUTRAL))
                    else
                        Utils.Print("%s Purchase of %s was released. Listing is back on the market.",
                            Utils.Colorize("⚠", AH.Colors.YELLOW),
                            Utils.Colorize(codInfo.itemName or "item", AH.Colors.NEUTRAL))
                    end
                    Utils.Print("Do NOT send COD for this item.")
                    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
                end

                -- Clean up buyer's purchase list too
                if AH.savedVars.myPurchases[listingId] then
                    AH.savedVars.myPurchases[listingId].state = LM.States.CANCELLED
                    CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
                end

            elseif ntype == "purchase_failed" then
                -- Buyer's purchase was rejected by the server (someone else bought it first)
                local data = notif.data or {}
                local reason = data.reason or "Item no longer available"
                local itemName = data.item_name or "Unknown"

                -- Remove from buyer's purchase list entirely (never completed)
                if AH.savedVars.myPurchases[listingId] then
                    AH.savedVars.myPurchases[listingId] = nil
                end

                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                Utils.Print("")
                Utils.Print("%s Purchase failed for %s",
                    Utils.Colorize("✗", AH.Colors.NEGATIVE),
                    Utils.Colorize(itemName, AH.Colors.NEUTRAL))
                Utils.Print("  Reason: %s", Utils.Colorize(reason, AH.Colors.YELLOW))
                Utils.Print("  Your gold was not affected.")
                Utils.Print("")

                -- Show popup dialog
                LM.ShowWarningDialog(
                    "Purchase Failed",
                    string.format(
                        "%s was already purchased by another player.\n\n"
                        .. "Your gold was not affected.\n"
                        .. "The listing has been removed from your Purchases tab.",
                        itemName))

                CALLBACK_MANAGER:FireCallbacks(AH.Events.DATA_UPDATED)
            end
        end

        -- Clear processed notifications
        incoming.ah_notifications = {}
    end
end

function LM.CheckExpiredListings()
    local now = Utils.GetTimestamp()
    local DAY = 86400

    -- Expire active listings past their time
    for id, listing in pairs(AH.savedVars.myListings) do
        if listing.state == LM.States.LISTED and listing.expiresAt and listing.expiresAt < now then
            listing.state = LM.States.EXPIRED
            LM.UnlockListedItem(listing)
            LM.QueueForSync(listing, "expire")
            Utils.Print("Listing expired: %s", Utils.Colorize(listing.itemName, AH.Colors.NEUTRAL))
        end
    end

    -- Clean up old cancelled/expired/completed listings (older than 24h)
    for id, listing in pairs(AH.savedVars.myListings) do
        if (listing.state == "cancelled" or listing.state == "expired" or listing.state == "completed") then
            local age = now - (listing.createdAt or 0)
            if age > DAY then
                LM.UnlockListedItem(listing)
                AH.savedVars.myListings[id] = nil
            end
        end
    end

    -- Clean up old purchases (cancelled/completed older than 24h)
    if AH.savedVars.myPurchases then
        for id, purchase in pairs(AH.savedVars.myPurchases) do
            if purchase.state == "cancelled" or purchase.state == "completed" then
                local age = now - (purchase.purchasedAt or 0)
                if age > DAY then
                    AH.savedVars.myPurchases[id] = nil
                end
            end
        end
    end
end

function LM.HookInventory()
    local lcm = LibCustomMenu
    if not lcm then
        Utils.Print("LibCustomMenu not found. Right-click listing from inventory is disabled.")
        Utils.Print("Install LibCustomMenu from ESOUI for inventory context menu support.")
        return
    end

    lcm:RegisterContextMenu(function(inventorySlot, slotActions)
        local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
        if not bagId or not slotIndex then return end
        local itemLink = GetItemLink(bagId, slotIndex)
        if not itemLink or itemLink == "" then return end
        if IsItemBound(bagId, slotIndex) then return end
        local itemType = GetItemType(bagId, slotIndex)
        if itemType == ITEMTYPE_QUEST or itemType == ITEMTYPE_TROPHY then return end
        AddCustomMenuItem(Utils.Colorize("List on Tamriel Auction House", "FFD700"),
            function() LM.ListItem(bagId, slotIndex) end)
    end, lcm.CATEGORY_LATE)
end

function LM.QueueForSync(data, action)
    if not AH.savedVars.outgoing then return end
    if not AH.savedVars.outgoing.ah_actions then AH.savedVars.outgoing.ah_actions = {} end
    table.insert(AH.savedVars.outgoing.ah_actions, {
        action = action, data = data,
        timestamp = Utils.GetTimestamp(), player = Utils.GetPlayerName(),
    })
end

--- Queue sync AND trigger auto-reload after a short debounced delay.
function LM.QueueForSyncAndReload(data, action)
    LM.QueueForSync(data, action)

    -- Debounce: reset timer on each call so bulk ops only reload once
    if pendingSyncReload then
        EVENT_MANAGER:UnregisterForUpdate(AH.name .. "_SyncReload")
    end
    pendingSyncReload = true
    EVENT_MANAGER:RegisterForUpdate(AH.name .. "_SyncReload", 1500, function()
        EVENT_MANAGER:UnregisterForUpdate(AH.name .. "_SyncReload")
        pendingSyncReload = nil
        ReloadUI("ingame")
    end)
end

--- Queue sync with auto-reload UNLESS batch mode is active.
function LM.QueueForSyncAuto(data, action)
    if LM.batchMode then
        LM.QueueForSync(data, action)
    else
        LM.QueueForSyncAndReload(data, action)
    end
end

function LM.SetBatchMode(enabled)
    LM.batchMode = enabled
    if enabled then
        Utils.Print("%s Batch mode ON — auto-sync disabled. Click %s when done.",
            Utils.Colorize("⚡", AH.Colors.YELLOW),
            Utils.Colorize("Refresh", AH.Colors.HIGHLIGHT))
    else
        Utils.Print("%s Batch mode OFF — auto-sync re-enabled.",
            Utils.Colorize("⚡", AH.Colors.POSITIVE))
    end
end

function LM.GetMyListings()
    local r = {}
    for _, l in pairs(AH.savedVars.myListings) do
        if l.state == LM.States.LISTED or l.state == LM.States.AWAITING_COD then
            table.insert(r, l)
        end
    end
    table.sort(r, function(a, b) return (a.createdAt or 0) > (b.createdAt or 0) end)
    return r
end

function LM.GetCODQueue()
    local r = {}
    for _, c in pairs(AH.savedVars.codQueue) do table.insert(r, c) end
    return r
end

function LM.GetMyPurchases()
    local r = {}
    for _, p in pairs(AH.savedVars.myPurchases) do
        -- Only show active purchases (not cancelled or completed)
        if p.state ~= LM.States.CANCELLED and p.state ~= LM.States.COMPLETED then
            table.insert(r, p)
        end
    end
    table.sort(r, function(a, b) return (a.purchasedAt or 0) > (b.purchasedAt or 0) end)
    return r
end

function LM.CalculateFee(price)
    return math.max(math.floor(price * LM.LISTING_FEE_PERCENT / 100), LM.MIN_LISTING_FEE)
end

function LM.GenerateListingId()
    return string.format("%s_%d_%d",
        Utils.GetPlayerName():gsub("@", ""), Utils.GetTimestamp(), math.random(10000, 99999))
end
