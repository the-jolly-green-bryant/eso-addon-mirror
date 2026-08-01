HT_BankWithdraw = HT_BankWithdraw or {}

local invCache = {[BAG_BACKPACK]={}}
local isWithdrawing = false
local withdrawQueue = {}
local withdrawCallback = nil

function HT_BankWithdraw.ClearCache()
    invCache[BAG_BACKPACK] = {}
end

function HT_BankWithdraw.FindEmptySlot()
    for slot = 0, GetBagSize(BAG_BACKPACK) - 1 do
        if not SHARED_INVENTORY.bagCache[BAG_BACKPACK][slot] and not invCache[BAG_BACKPACK][slot] then
            invCache[BAG_BACKPACK][slot] = true
            return slot
        end
    end
    return nil
end

function HT_BankWithdraw.StartWithdraw(items, callback)
    if isWithdrawing then
        return false
    end
    isWithdrawing = true
    withdrawQueue = items
    withdrawCallback = callback
    
    HT_BankWithdraw.ProcessWithdraw()
    return true
end

function HT_BankWithdraw.ProcessWithdraw()
    if #withdrawQueue == 0 then
        isWithdrawing = false
        if withdrawCallback then withdrawCallback() end
        return
    end
    
    local item = table.remove(withdrawQueue, 1)
    
    local emptySlot = HT_BankWithdraw.FindEmptySlot()
    if emptySlot then
        CallSecureProtected("RequestMoveItem", 
            item.srcBag, item.srcSlot, 
            item.tgtBag, emptySlot, 1)
        HT_BankWithdraw.ProcessWithdraw()
    else
        CHAT_SYSTEM:AddMessage("[Hyborem Tutor] |cFF0000No empty slot, stopping withdraw|r")
        isWithdrawing = false
    end
end

function HT_BankWithdraw.IsWithdrawing()
    return isWithdrawing
end