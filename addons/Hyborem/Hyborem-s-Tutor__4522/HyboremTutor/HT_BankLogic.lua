HT_BankLogic = HT_BankLogic or {}

local scanDelay = 3000
local pending = false

local function Log(message)
    CHAT_SYSTEM:AddMessage(message)
end

function HT_BankLogic.OnBankOpen()
    if pending or not IsBankOpen() or HT_BankWithdraw.IsWithdrawing() then return end
    pending = true
    
    zo_callLater(function()
        pending = false
        if not IsBankOpen() then return end
        
        SHARED_INVENTORY:RefreshInventory(BAG_BACKPACK)
        SHARED_INVENTORY:RefreshInventory(BAG_BANK)
        if IsESOPlusSubscriber() then 
            SHARED_INVENTORY:RefreshInventory(BAG_SUBSCRIBER_BANK) 
        end
        
        HT_BankWithdraw.ClearCache()
        
        local char = GetUnitName("player")
        local toWithdraw = {}
        
        local bags = {BAG_BANK}
        if IsESOPlusSubscriber() then table.insert(bags, BAG_SUBSCRIBER_BANK) end
        
        for _, bag in ipairs(bags) do
            for slot = 0, GetBagSize(bag) - 1 do
                if HT_Knowledge.IsInterestingItem(bag, slot) then
                    local link = GetItemLink(bag, slot)
                    
                    if HT_Queue.ShouldLearnNow(link, char) then
                        table.insert(toWithdraw, {
                            link = link, 
                            srcBag = bag, 
                            srcSlot = slot, 
                            tgtBag = BAG_BACKPACK, 
                        })
                    end
                end
            end
        end
        
        if #toWithdraw > 0 then
            Log(string.format("[Hyborem Tutor] Withdraw: %d items", #toWithdraw))
            HT_BankWithdraw.StartWithdraw(toWithdraw, function()
                Log("[Hyborem Tutor] Withdraw complete")
            end)
        else
            Log("[Hyborem Tutor] Nothing to withdraw")
        end
    end, scanDelay)
end

function HT_BankLogic.OnMerchantOpen()
    if not IsMerchantOpen() then return end
    
    local minScripts = HyboremTutor_Vars.minScripts or 0
    if minScripts == 0 then return end
    
    local scriptCounts = {}
    local scriptSlots = {}
    
    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        local link = GetItemLink(BAG_BACKPACK, slot)
        if link and HT_Knowledge.GetCategory(link) == "SCRIPT" then
            local itemId = GetItemLinkItemId(link)
            scriptCounts[itemId] = (scriptCounts[itemId] or 0) + 1
            if not scriptSlots[itemId] then scriptSlots[itemId] = {} end
            table.insert(scriptSlots[itemId], {bag = BAG_BACKPACK, slot = slot, link = link})
        end
    end
    
    for itemId, count in pairs(scriptCounts) do
        if count > minScripts then
            local toSell = count - minScripts
            for i = 1, toSell do
                local slotInfo = scriptSlots[itemId][i]
                if slotInfo then
                    RequestSellItem(slotInfo.bag, slotInfo.slot)
                    Log(string.format("[Hyborem Tutor] Sold excess script: %s", GetItemLinkName(slotInfo.link)))
                end
            end
        end
    end
end