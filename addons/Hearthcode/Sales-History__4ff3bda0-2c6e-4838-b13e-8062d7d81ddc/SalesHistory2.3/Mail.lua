local SH = SalesHistory

local function ParseMailForSale(mailId)
    local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived = GetMailItemInfo(mailId)
    
    -- Only process system mail from guild store
    if not fromSystem then return nil end
    
    -- Read mail body
    local body = ReadMail(mailId)
    if not body then return nil end
    
    -- Check if it's a guild sale notification (look for common patterns)
    -- Mail body typically contains: "Your item [ItemName] has been purchased by @Buyer for X gold"
    if not (body:find("purchased") or body:find("sold") or body:find("bought")) then
        return nil
    end
    
    -- Extract item link (format: |H1:item:...|h[Item Name]|h)
    local itemLink = body:match("(|H.-|h%[.-%]|h)")
    if not itemLink then return nil end
    
    -- Extract price (look for number followed by "gold")
    local price = tonumber(body:match("(%d+)%s*gold"))
    if not price then return nil end
    
    -- Extract buyer name (optional, after "by " or "to ")
    local buyer = body:match("by%s+(@?[%w]+)") or body:match("to%s+(@?[%w]+)") or "Unknown"
    
    -- Get item details
    local itemName = GetItemLinkName(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    
    -- Create sale record
    local sale = {
        itemLink = itemLink,
        itemName = itemName,
        sellerName = GetDisplayName():gsub("^@", ""),
        price = price,
        tax = 0, -- Mail doesn't provide tax info
        quantity = 1, -- Mail doesn't specify quantity, assume 1
        dateStr = GetDateStringFromTimestamp(GetTimeStamp()),
        timestamp = GetTimeStamp(),
        buyer = buyer,
        source = "mail", -- Track where this came from
    }
    
    return sale
end

local function OnMailReadable(eventCode, mailId)
    local sale = ParseMailForSale(mailId)
    if not sale then return end
    
    -- Check for duplicate using itemLink + price + date (not exact timestamp)
    local saleDate = GetDateStringFromTimestamp(sale.timestamp)
    local isDuplicate = false
    
    for _, existingSale in ipairs(SH.savedVars.cachedResults) do
        local existingDate = existingSale.dateStr or GetDateStringFromTimestamp(existingSale.timestamp)
        if existingSale.itemLink == sale.itemLink and 
           existingSale.price == sale.price and
           existingDate == saleDate then
            isDuplicate = true
            break
        end
    end
    
    if not isDuplicate then
        table.insert(SH.savedVars.cachedResults, 1, sale) -- Add to front (most recent)
        
        -- Sort by timestamp
        table.sort(SH.savedVars.cachedResults, function(a, b) return a.timestamp > b.timestamp end)
        
        -- Trim to max
        while #SH.savedVars.cachedResults > SH.MAX_RESULTS do
            table.remove(SH.savedVars.cachedResults)
        end
        
        -- Alert user
        local displayName = sale.itemName or "Unknown"
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, 
            string.format("[SalesHistory] Sale recorded from mail: %s | %sg", displayName, tostring(sale.price)))
    end
end

-- Register for mail events
EVENT_MANAGER:RegisterForEvent(SH.name .. "Mail", EVENT_MAIL_READABLE, OnMailReadable)
