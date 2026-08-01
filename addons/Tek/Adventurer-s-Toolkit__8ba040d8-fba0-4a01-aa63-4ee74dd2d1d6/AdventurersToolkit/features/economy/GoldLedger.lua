-- ============================================
-- GOLD LEDGER (Net Worth Tab 2) - v148
-- ============================================
NWT.netWorthCurrentTab = 1  -- 1 = Net Worth, 2 = Gold Ledger
NWT.goldLedgerVersion = "148"  -- For debugging updates

-- Map reason codes to readable names
NWT.ReasonNames = {
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE] = "Guild Purchase",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING] = "Listing Fee",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND] = "Guild Sale",
    [CURRENCY_CHANGE_REASON_VENDOR] = "Vendor",
    [CURRENCY_CHANGE_REASON_VENDOR_REPAIR] = "Repair",
    [CURRENCY_CHANGE_REASON_VENDOR_LAUNDER] = "Launder",
    [CURRENCY_CHANGE_REASON_LOOT] = "Loot",
    [CURRENCY_CHANGE_REASON_LOOT_STOLEN] = "Stolen Loot",
    [CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER] = "Container",
    [CURRENCY_CHANGE_REASON_PICKPOCKET] = "Pickpocket",
    [CURRENCY_CHANGE_REASON_KILL] = "Kill",
    [CURRENCY_CHANGE_REASON_MAIL] = "Mail",
    [CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY] = "COD",
    [CURRENCY_CHANGE_REASON_QUESTREWARD] = "Quest",
    [CURRENCY_CHANGE_REASON_REWARD] = "Writ/Reward",
    [CURRENCY_CHANGE_REASON_TRADE] = "Player Trade",
    [CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD] = "Wayshrine",
    [CURRENCY_CHANGE_REASON_BAGSPACE] = "Bag Space",
    [CURRENCY_CHANGE_REASON_BANKSPACE] = "Bank Space",
    [CURRENCY_CHANGE_REASON_STABLESPACE] = "Stable",
    [CURRENCY_CHANGE_REASON_RESPEC_SKILLS] = "Respec Skills",
    [CURRENCY_CHANGE_REASON_RESPEC_MORPHS] = "Respec Morphs",
    [CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES] = "Respec Attr",
    [CURRENCY_CHANGE_REASON_RESPEC_CHAMPION] = "Respec CP",
    [CURRENCY_CHANGE_REASON_SELL_STOLEN] = "Fence Sale",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE] = "Bounty (Fence)",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD] = "Bounty (Guard)",
    [CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED] = "Confiscated",
    [CURRENCY_CHANGE_REASON_CRAFT] = "Crafting",
    [CURRENCY_CHANGE_REASON_DECONSTRUCT] = "Deconstruct",
    [CURRENCY_CHANGE_REASON_ACHIEVEMENT] = "Achievement",
    [CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD] = "Antiquity",
    [CURRENCY_CHANGE_REASON_BATTLEGROUND] = "Battleground",
    [CURRENCY_CHANGE_REASON_TRIBUTE] = "Tales of Tribute",
    [CURRENCY_CHANGE_REASON_KEEP_REPAIR] = "Keep Repair",
    [CURRENCY_CHANGE_REASON_KEEP_UPGRADE] = "Keep Upgrade",
    [CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP] = "Forward Camp",
    [CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY] = "Guild Heraldry",
    [CURRENCY_CHANGE_REASON_GUILD_TABARD] = "Guild Tabard",
    [CURRENCY_CHANGE_REASON_SOUL_HEAL] = "Soul Heal",
    [CURRENCY_CHANGE_REASON_RECONSTRUCTION] = "Reconstruction",
    [CURRENCY_CHANGE_REASON_BUYBACK] = "Buyback",
    [CURRENCY_CHANGE_REASON_MEDAL] = "Medal",
    [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD] = "Keep Capture",
    [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD] = "Keep Defense",
    [CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER] = "PvP Kill",
    [CURRENCY_CHANGE_REASON_PVP_RESURRECT] = "PvP Resurrect",
    [CURRENCY_CHANGE_REASON_ENDLESS_DUNGEON_VISION_REROLL] = "Endless Dungeon",
    [CURRENCY_CHANGE_REASON_FEED_MOUNT] = "Feed Mount",
    [CURRENCY_CHANGE_REASON_RESPEC_SUBCLASS] = "Respec Subclass",
    [CURRENCY_CHANGE_REASON_CONVERSATION] = "Conversation",
    [CURRENCY_CHANGE_REASON_BANK_FEE] = "Bank Fee",
    [CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND] = "Travel Refund",
    [CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE] = "Ability Upgrade",
    [CURRENCY_CHANGE_REASON_RESEARCH_TRAIT] = "Research",
    [CURRENCY_CHANGE_REASON_REFORGE] = "Reforge",
    [CURRENCY_CHANGE_REASON_TRAIT_REVEAL] = "Trait Reveal",
}

-- Add transaction to history
function NWT.AddTransaction(typeName, amount, balance, itemName)
    if not NWT.savedVars.goldLedger.transactions then
        NWT.savedVars.goldLedger.transactions = {}
    end
    
    local trans = NWT.savedVars.goldLedger.transactions
    table.insert(trans, 1, {  -- Insert at beginning (newest first)
        time = GetTimeStamp(),
        typeName = typeName,
        amount = amount,
        balance = balance,
        itemName = itemName or "",
    })
    
    -- Keep only last 50 transactions
    while #trans > 50 do
        table.remove(trans)
    end
end

-- Track last purchased item for transaction logging
NWT.lastPurchasedItem = nil

-- Track trade partner for player-to-player trades
NWT.tradePartner = nil

-- Capture trade partner when someone invites us to trade
function NWT.OnTradeInviteConsidering(eventCode, inviterCharacterName, inviterDisplayName)
    NWT.tradePartner = inviterDisplayName or inviterCharacterName
end

-- Capture trade partner when we invite someone to trade
function NWT.OnTradeInviteWaiting(eventCode, inviteeCharacterName, inviteeDisplayName)
    NWT.tradePartner = inviteeDisplayName or inviteeCharacterName
end

-- Clear trade partner when trade is canceled or declined
function NWT.OnTradeCanceled(eventCode, cancelerName)
    NWT.tradePartner = nil
end

function NWT.OnTradeInviteDeclined(eventCode)
    NWT.tradePartner = nil
end

function NWT.OnTradeInviteCanceled(eventCode)
    NWT.tradePartner = nil
end

-- Track last guild sale item from mail
NWT.lastGuildSaleInfo = nil

-- Capture guild sale info when taking money from mail
function NWT.OnMailTakeAttachedMoneySuccess(eventCode, mailId)
    local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(mailId)
    
    -- Guild store sale mails are from system and subject contains the item name
    -- Subject format is typically: "Sold: ItemName" or similar
    if fromSystem and subject and attachedMoney and attachedMoney > 0 then
        -- Extract item name from subject (remove "Sold: " prefix if present)
        local itemName = subject
        if itemName:find("^Sold:") then
            itemName = itemName:gsub("^Sold:%s*", "")
        end
        NWT.lastGuildSaleInfo = {
            itemName = itemName,
            amount = attachedMoney,
            timestamp = GetTimeStamp()
        }
    end
end

-- Hook trading house purchase to capture item name
function NWT.OnTradingHousePurchaseReceived(eventCode, result)
    if result == TRADING_HOUSE_RESULT_SUCCESS then
        -- Item name was captured by OnTradingHouseConfirmPendingPurchase
    end
end

function NWT.OnTradingHouseConfirmPendingPurchase(eventCode, pendingPurchaseIndex)
    local icon, itemName, quality, stackCount, sellerName, timeRemaining, purchasePrice = GetTradingHouseSearchResultItemInfo(pendingPurchaseIndex)
    if itemName then
        NWT.lastPurchasedItem = zo_strformat("<<1>>", itemName)
        if stackCount and stackCount > 1 then
            NWT.lastPurchasedItem = NWT.lastPurchasedItem .. " x" .. stackCount
        end
    end
end

-- Check if we need to reset daily totals (resets at 5 AM EST)
function NWT.CheckGoldLedgerDailyReset()
    if not NWT.savedVars or not NWT.savedVars.goldLedger then return end
    
    local now = GetTimeStamp()
    local lastReset = NWT.savedVars.goldLedger.lastResetTimestamp or 0
    
    -- Calculate today's 5 AM EST in seconds
    local secondsInDay = 86400
    local estOffset = 5 * 3600  -- 5 hours from UTC
    local todayStart = math.floor((now + estOffset) / secondsInDay) * secondsInDay - estOffset
    local resetTime = todayStart + (5 * 3600)  -- 5 AM
    
    -- If last reset was before today's 5 AM and we're past 5 AM, reset
    if lastReset < resetTime and now >= resetTime then
        -- Archive today's totals to allTime
        local today = NWT.savedVars.goldLedger.today
        local allTime = NWT.savedVars.goldLedger.allTime
        
        for _, v in pairs(today.income) do allTime.income = allTime.income + v end
        for _, v in pairs(today.expenses) do allTime.expenses = allTime.expenses + v end
        
        -- Reset today
        NWT.savedVars.goldLedger.today = {
            income = { guildSales = 0, vendorSales = 0, loot = 0, mail = 0, quests = 0, other = 0 },
            expenses = { guildPurchases = 0, guildListingFee = 0, vendorPurchases = 0, repairs = 0, travel = 0, mail = 0, bagBank = 0, respec = 0, other = 0 },
        }
        NWT.savedVars.goldLedger.lastResetTimestamp = now
    end
end

-- Map currency change reasons to categories
function NWT.OnMoneyUpdate(eventCode, newMoney, oldMoney, reason)
    local change = newMoney - oldMoney
    
    if not NWT.savedVars or not NWT.savedVars.goldLedger then return end
    
    NWT.CheckGoldLedgerDailyReset()
    
    -- change was already calculated above for debug output
    if change == 0 then return end
    
    local today = NWT.savedVars.goldLedger.today
    local isIncome = change > 0
    local amount = math.abs(change)
    
    -- Get type name for transaction log
    local typeName = NWT.ReasonNames[reason] or "Other"
    
    -- Map reasons to categories
    if reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
        today.expenses.guildPurchases = today.expenses.guildPurchases + amount
        NWT.AddTransaction("Guild Purchase", -amount, newMoney, NWT.lastPurchasedItem)
        NWT.lastPurchasedItem = nil  -- Clear after use
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING then
        if isIncome then
            today.income.guildSales = today.income.guildSales + amount
            NWT.AddTransaction("Listing Refund", amount, newMoney)
        else
            today.expenses.guildListingFee = today.expenses.guildListingFee + amount
            NWT.AddTransaction("Listing Fee", -amount, newMoney)
        end
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND then
        today.income.guildSales = today.income.guildSales + amount
        -- Check if we have guild sale info from mail (item name)
        local itemName = nil
        if NWT.lastGuildSaleInfo and NWT.lastGuildSaleInfo.amount == amount then
            itemName = NWT.lastGuildSaleInfo.itemName
            NWT.lastGuildSaleInfo = nil  -- Clear after use
        end
        NWT.AddTransaction("Guild Sale", amount, newMoney, itemName)
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR then
        if isIncome then
            today.income.vendorSales = today.income.vendorSales + amount
            NWT.AddTransaction("Vendor Sale", amount, newMoney)
        else
            today.expenses.vendorPurchases = today.expenses.vendorPurchases + amount
            NWT.AddTransaction("Vendor Buy", -amount, newMoney)
        end
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_REPAIR then
        today.expenses.repairs = today.expenses.repairs + amount
        NWT.AddTransaction("Repair", -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_LOOT_STOLEN or reason == CURRENCY_CHANGE_REASON_PICKPOCKET or reason == CURRENCY_CHANGE_REASON_KILL then
        today.income.loot = today.income.loot + amount
        NWT.AddTransaction(typeName, amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_MAIL or reason == CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY then
        if isIncome then
            today.income.mail = today.income.mail + amount
            NWT.AddTransaction("Mail", amount, newMoney)
        else
            today.expenses.mail = today.expenses.mail + amount
            NWT.AddTransaction("Mail", -amount, newMoney)
        end
    elseif reason == CURRENCY_CHANGE_REASON_QUESTREWARD then
        today.income.quests = today.income.quests + amount
        NWT.AddTransaction("Quest", amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_REWARD then
        today.income.quests = today.income.quests + amount
        NWT.AddTransaction("Writ/Reward", amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_TRADE then
        local partnerName = NWT.tradePartner or "Unknown"
        -- Clean up the display name (remove @ if present for cleaner display)
        if partnerName:sub(1,1) == "@" then
            partnerName = partnerName:sub(2)
        end
        if isIncome then
            today.income.other = today.income.other + amount
            NWT.AddTransaction("Trade from " .. partnerName, amount, newMoney)
        else
            today.expenses.other = today.expenses.other + amount
            NWT.AddTransaction("Trade to " .. partnerName, -amount, newMoney)
        end
        NWT.tradePartner = nil  -- Clear after use
    elseif reason == CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD then
        today.expenses.travel = today.expenses.travel + amount
        NWT.AddTransaction("Wayshrine", -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_BAGSPACE or reason == CURRENCY_CHANGE_REASON_BANKSPACE or reason == CURRENCY_CHANGE_REASON_STABLESPACE then
        today.expenses.bagBank = today.expenses.bagBank + amount
        NWT.AddTransaction(typeName, -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_SKILLS or reason == CURRENCY_CHANGE_REASON_RESPEC_MORPHS or reason == CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES or reason == CURRENCY_CHANGE_REASON_RESPEC_CHAMPION then
        today.expenses.respec = today.expenses.respec + amount
        NWT.AddTransaction(typeName, -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
        today.income.vendorSales = today.income.vendorSales + amount
        NWT.AddTransaction("Fence Sale", amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER then
        today.expenses.other = today.expenses.other + amount
        NWT.AddTransaction("Launder", -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE or reason == CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD or reason == CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED then
        today.expenses.other = today.expenses.other + amount
        NWT.AddTransaction(typeName, -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_CRAFT or reason == CURRENCY_CHANGE_REASON_DECONSTRUCT then
        if isIncome then
            today.income.other = today.income.other + amount
            NWT.AddTransaction(typeName, amount, newMoney)
        else
            today.expenses.other = today.expenses.other + amount
            NWT.AddTransaction(typeName, -amount, newMoney)
        end
    elseif reason == CURRENCY_CHANGE_REASON_ACHIEVEMENT or reason == CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD then
        today.income.quests = today.income.quests + amount
        NWT.AddTransaction(typeName, amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND or reason == CURRENCY_CHANGE_REASON_TRIBUTE then
        today.income.other = today.income.other + amount
        NWT.AddTransaction(typeName, amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_RECONSTRUCTION or reason == CURRENCY_CHANGE_REASON_SOUL_HEAL then
        today.expenses.other = today.expenses.other + amount
        NWT.AddTransaction(typeName, -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR or reason == CURRENCY_CHANGE_REASON_KEEP_UPGRADE or reason == CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP then
        today.expenses.other = today.expenses.other + amount
        NWT.AddTransaction(typeName, -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_BUYBACK then
        today.expenses.vendorPurchases = today.expenses.vendorPurchases + amount
        NWT.AddTransaction("Buyback", -amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER then
        today.income.loot = today.income.loot + amount
        NWT.AddTransaction("Container", amount, newMoney)
    elseif reason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT or reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL or reason == CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT or reason == CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL then
        -- Ignore bank transfers - gold is just moving, not gained/lost
        return
    else
        -- Catch-all for other reasons - use typeName if available
        if isIncome then
            today.income.other = today.income.other + amount
            NWT.AddTransaction(typeName, amount, newMoney)
        else
            today.expenses.other = today.expenses.other + amount
            NWT.AddTransaction(typeName, -amount, newMoney)
        end
    end
end

-- Format time for display (HH:MM)
function NWT.FormatTransactionTime(timestamp)
    local now = GetTimeStamp()
    local diff = now - timestamp
    
    if diff < 60 then
        return "Just now"
    elseif diff < 3600 then
        return string.format("%dm ago", math.floor(diff / 60))
    elseif diff < 86400 then
        return string.format("%dh ago", math.floor(diff / 3600))
    else
        return string.format("%dd ago", math.floor(diff / 86400))
    end
end

-- Format gold with k/m suffixes for the ledger view
function NWT.FormatGoldLedger(amount)
    if amount >= 1000000 then
        return string.format("%.1fm", amount / 1000000)
    elseif amount >= 1000 then
        return string.format("%.1fk", amount / 1000)
    else
        return tostring(amount)
    end
end
