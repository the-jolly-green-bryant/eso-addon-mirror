ShosPvPBanker = ShosPvPBanker or {} 
ShosPvPBanker.internalName = "ShosPvPBanker" 
ShosPvPBanker.name = "|c2046e5Sho's PvP Banker|r" 
ShosPvPBanker.author = "|c2046e5sshogrin|r" 
ShosPvPBanker.version = "1.0.1" 

ShosPvPBanker.processedItems = {} 
ShosPvPBanker.actionOccurred = false 

-- Queue Worker 1: Staggered Deposits (Backpack -> Bank)
function ShosPvPBanker.ProcessInventoryQueue(queue, srcBag, destBag, isDeposit, currentIndex)
    if not IsBankOpen() then return end

    if currentIndex > #queue then
        if ShosPvPBanker.actionOccurred then
            local actionText = isDeposit and "Automated Deposit Complete:" or "Automated Withdrawal Complete:"
            d(ShosPvPBanker.name .. " " .. actionText) 
            for name, totalAmount in pairs(ShosPvPBanker.processedItems) do 
                d(" -> " .. name .. " (x" .. totalAmount .. ")") 
            end 
        end
        return
    end

    local currentMove = queue[currentIndex]
    local _, currentStack = GetItemInfo(srcBag, currentMove.slotIndex)
    
    if currentStack > 0 then
        if not ShosPvPBanker.processedItems[currentMove.name] then
            ShosPvPBanker.processedItems[currentMove.name] = 0
        end
        ShosPvPBanker.processedItems[currentMove.name] = ShosPvPBanker.processedItems[currentMove.name] + currentStack
        ShosPvPBanker.actionOccurred = true

        if CallSecureProtected("PickupInventoryItem", srcBag, currentMove.slotIndex, currentStack) then
            CallSecureProtected("PlaceInTransfer", destBag)
            local msg = isDeposit and "Deposited <<1>> x<<2>>" or "Withdrew <<1>> x<<2>>"
            d(zo_strformat("[ShosPvPBanker] " .. msg, currentMove.link, currentStack)) 
        end
    end

    zo_callLater(function()
        ShosPvPBanker.ProcessInventoryQueue(queue, srcBag, destBag, isDeposit, currentIndex + 1)
    end, 300)
end

-- Queue Worker 2: Staggered Multi-Bag Withdrawals (Handles standard and subscriber slots)
function ShosPvPBanker.ProcessWithdrawalQueue(queue, currentIndex)
    if not IsBankOpen() then return end

    if currentIndex > #queue then
        if ShosPvPBanker.actionOccurred then
            d(ShosPvPBanker.name .. " Automated Withdrawal Complete:") 
            for name, totalAmount in pairs(ShosPvPBanker.processedItems) do 
                d(" -> " .. name .. " (x" .. totalAmount .. ")") 
            end 
        end
        return
    end

    local currentMove = queue[currentIndex]
    local _, currentStack = GetItemInfo(currentMove.bagId, currentMove.slotIndex)
    
    if currentStack > 0 then
        if not ShosPvPBanker.processedItems[currentMove.name] then
            ShosPvPBanker.processedItems[currentMove.name] = 0
        end
        ShosPvPBanker.processedItems[currentMove.name] = ShosPvPBanker.processedItems[currentMove.name] + currentStack
        ShosPvPBanker.actionOccurred = true

        if CallSecureProtected("PickupInventoryItem", currentMove.bagId, currentMove.slotIndex, currentStack) then
            CallSecureProtected("PlaceInTransfer", BAG_BACKPACK)
            d(zo_strformat("[ShosPvPBanker] Withdrew <<1>> x<<2>>", currentMove.link, currentStack)) 
        end
    end

    zo_callLater(function()
        ShosPvPBanker.ProcessWithdrawalQueue(queue, currentIndex + 1)
    end, 300)
end

function ShosPvPBanker.DepositPvPItems() 
    if not IsBankOpen() then return end 
    if IsPlayerInAvAWorld() or IsActiveWorldBattleground() then return end 

    ShosPvPBanker.processedItems = {} 
    ShosPvPBanker.actionOccurred = false 
    
    local itemsToDeposit = { 
        [ITEMTYPE_SIEGE or 4] = true,
        [ITEMTYPE_RECALL_STONE or 69] = true, 
        [ITEMTYPE_AVA_REPAIR or 29] = true, 
    } 

    local queue = {} 
    local numSlots = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, numSlots - 1 do 
        local itemLink = GetItemLink(BAG_BACKPACK, slotIndex) 
        if itemLink ~= "" then 
            if itemsToDeposit[GetItemLinkItemType(itemLink)] then 
                table.insert(queue, {
                    slotIndex = slotIndex,
                    name = GetItemLinkName(itemLink),
                    link = itemLink
                })
            end 
        end 
    end 

    if #queue > 0 then
        ShosPvPBanker.ProcessInventoryQueue(queue, BAG_BACKPACK, BAG_BANK, true, 1)
    else
        d(ShosPvPBanker.name .. " No matching PvP items found in inventory to deposit.")
    end
end 

local function OnAddOnLoaded(event, addonName) 
    if addonName ~= ShosPvPBanker.internalName then return end 

    -- Parent to GuiRoot to grant unhindered click layers
    local frame = WINDOW_MANAGER:CreateControlFromVirtual("ShosPvPBanker_UIFrame", GuiRoot, "ShosPvPBanker_UIFrame_Template")
    
    if frame then
        frame:ClearAnchors()
        -- FIXED AUTOMATIC CENTERING LAYOUT:
        -- Anchors the TOP center of our frame to the BOTTOM center of the bank list.
        -- X=0 (forces perfect mathematical centering under the window grid)
        -- Y=60 (keeps the buttons comfortably dropped down in the clear footer space)
        frame:SetAnchor(TOP, ZO_PlayerBankBackpack, BOTTOM, 0, 60)
        frame:SetHidden(true)

        ZO_PreHookHandler(ZO_PlayerBank, "OnEffectivelyShown", function()
            frame:SetHidden(false)
        end)

        ZO_PreHookHandler(ZO_PlayerBank, "OnEffectivelyHidden", function()
            frame:SetHidden(true)
        end)
    end

    -- Run automatic deposits when talking to a banker
    EVENT_MANAGER:RegisterForEvent(ShosPvPBanker.internalName, EVENT_OPEN_BANK, function(eventCode, bankBag) 
        if bankBag == BAG_BANK then 
            ShosPvPBanker.DepositPvPItems()      
        end 
    end) 

    EVENT_MANAGER:UnregisterForEvent(ShosPvPBanker.internalName, EVENT_ADD_ON_LOADED) 
end 

EVENT_MANAGER:RegisterForEvent(ShosPvPBanker.internalName, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
