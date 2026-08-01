KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam

---------------------------------------------------------------------
local lootFilter
local lls

---------------------------------------------------------------------
local function LootTimeout()
    EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "LootHistoryTimeout")
    lls:IncrementCounter()
    lls:Print()
end

local function OnNewItemReceived(itemLink, stackCountChange, lootType, itemId, isVirtual, isStolen)
    lls:AddItemLink(itemLink, stackCountChange)
    EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "LootHistoryTimeout", 200, LootTimeout)
end

local function OnInventorySlotUpdate(_, bagId, slotIndex, isNewItem, _, inventoryUpdateReason, stackCountChange)
    -- Yoinked from esoui/ingame/zo_loot/loothistory_manager.lua
    -- This includes any inventory item update, only display if the item was new
    if isNewItem and stackCountChange > 0 then
        local itemLink = GetItemLink(bagId, slotIndex)

        -- cover the case where we got an inventory item update but then the item got whisked away somewhere else
        -- before we had a chance to get the info out of it
        if itemLink ~= nil and itemLink ~= "" then
            local lootType = LOOT_TYPE_ITEM
            local itemId = GetItemInstanceId(bagId, slotIndex)
            local isVirtual = bagId == BAG_VIRTUAL
            local isStolen = IsItemStolen(bagId, slotIndex)
            OnNewItemReceived(itemLink, stackCountChange, lootType, itemId, isVirtual, isStolen)
        end
    end
end

---------------------------------------------------------------------
local lootChat = ZO_Object:Subclass()
function lootChat:New(...)
    local instance = ZO_Object.New(self)
    instance.isDefault = false
    instance.maxCharsPerLine = 1200
    return instance
end
function lootChat:Print(message)
    lootFilter:AddMessage(message)
end

---------------------------------------------------------------------
function Spam.InitializeLootHistory()
    if (LibFilteredChatPanel and LibLootSummary) then
        lootFilter = LibFilteredChatPanel:CreateFilter(Spam.name .. "Loot", "/esoui/art/leveluprewards/levelup_bag_upgrade_64.dds", {0, 0.6, 0.2}, false)

        lls = LibLootSummary({chat = lootChat:New()})
        lls:SetCombineDuplicates(true)
        lls:SetCounterText(items)
        lls:SetDelimiter(" - ")
        lls:SetHideSingularQuantities(true)
        lls:SetLinkStyle(LINK_STYLE_BRACKETS)
        lls:SetMinQuality(ITEM_DISPLAY_QUALITY_TRASH)
        lls:SetShowCounter(false)
        lls:SetShowIcon(true)
        lls:SetShowNotCollected(true)
        lls:SetIconSize(90)
        lls:SetShowTrait(false)
        lls:SetPrefix("Looted")
        lls:SetSortedByQuality(true)
        lls:SetSuffix("")
        lls:SetEnabled(true)

        EVENT_MANAGER:RegisterForEvent(Spam.name .. "LootHistory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)

        if (KyzderpsDerps.savedOptions.general.experimental) then
            -- Prevent items from showing up in loot history
            EVENT_MANAGER:UnregisterForEvent(ZO_LOOT_HISTORY_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        end
    else
        KyzderpsDerps:dbg("Not hooking loot history because no LibFilteredChatPanel and/or LibLootSummary enabled.")
    end
end
