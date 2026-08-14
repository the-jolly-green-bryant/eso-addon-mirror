
-- AlchemyOpener.lua
-- Author: Awh_Lina
AlchemyOpener = {}
AlchemyOpener.name = "AlchemyOpener"
AlchemyOpener.isLoaded = true
AlchemyOpener.version = "1.0"
AlchemyOpener.defaults_db = {
    enabled = true
    
}
local first_run = true
AlchemyOpener.server = {

}
local isParcel = false
function AlchemyOpener:UpdateIndexes(bagCache)
    for _, data in bagCache do
        local bagId = data.bagId
        local slotIndex = data.slotIndex
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        local itemName = GetItemLinkName(link)
        local itemId = GetItemLinkItemId(link)
        if itemName == "Waxed Apothecary's Parcel" then
            table.insert(AlchemyOpener.server, {bagId = bagId, slotIndex = slotIndex})
            isParcel = true
        end
    end
    
end
function AlchemyOpener:UpdateRun()
    first_run = true
end
local function useIteminquick(bagId, slotIndex)
    CallSecureProtected("UseItem", bagId, slotIndex)
end
function AlchemyOpener:OnOPEN_STORE(eventCode) 
    local isParcel = false
    local numItems = GetNumStoreItems()
    for i = 1, numItems do
        local tex, name, stack, price, sellprice, reqtobuy, reqtouse, quality, questname, currencytype1, currencyQuantity1, currencytype2, currencyQuantity2, entryType, storeFailure, buyerror, actorcatgory = GetStoreEntryInfo(i)
        local size = GetBagUseableSize(BAG_BACKPACK)
        local usedSlots =  GetNumBagUsedSlots(BAG_BACKPACK)
        local freeslots = size - usedSlots
        if name == "Waxed Apothecary's Parcel" then
            BuyStoreItem(i, freeslots)
        end
    end
end
function AlchemyOpener:EVENT_LOOT_UPDATED(eventCode)
    local isParcel = false
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for index, data in pairs(bagCache) do
        local bagId = data.bagId
        local slotIndex = data.slotIndex
        local link = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
        local itemName = GetItemLinkName(link)
        if itemName == "Waxed Apothecary's Parcel" then
            isParcel = true
        end
        if isParcel then
            zo_callLater(useIteminquick(bagId, slotIndex),
            2000)
            zo_callLater(function ()

                LootAll()
            end, 1000)
            end
        isParcel = false
        end
    AlchemyOpener.server = {

    }
    AlchemyOpener:UpdateRun()
end
function AlchemyOpener:UpdateData()
    if first_run then
        LOOT_SHARED:LootAllItems()
    end
    first_run = false
    EVENT_MANAGER:RegisterForUpdate(self.name, 2000, function(...) AlchemyOpener:EVENT_LOOT_UPDATED(...) end)
end    
function AlchemyOpener:Initialize()
    self.db = ZO_SavedVars:New("AlchemyOpenerSettings", 1, nil, AlchemyOpener.defaults_db)
    d("Ready")
end
function AlchemyOpener.OnAddOnLoaded(event, addonName)
    if addonName ~= AlchemyOpener.name then return end
    AlchemyOpener.isLoaded = true
    EVENT_MANAGER:RegisterForEvent(AlchemyOpener.name, EVENT_OPEN_STORE, function() AlchemyOpener:OnOPEN_STORE() end)
    EVENT_MANAGER:RegisterForEvent(AlchemyOpener.name, EVENT_LOOT_UPDATED,function() AlchemyOpener:UpdateData() end)

end

EVENT_MANAGER:RegisterForEvent(AlchemyOpener.name, EVENT_ADD_ON_LOADED, AlchemyOpener.OnAddOnLoaded)