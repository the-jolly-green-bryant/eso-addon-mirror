LootHound.ItemTracker = {}
local tracker = LootHound.ItemTracker

function tracker:Init()
    -- Tells ESO to run this function every time an item is added to an inventory slot
    EVENT_MANAGER:RegisterForEvent(
        "LootHound_Tracker",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(event, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason, stackCountDelta)
            
            -- 1. Basic safety checks: Ensure it's a brand new item in the player's backpack
            if bagId ~= BAG_BACKPACK or not isNewItem then return end
            if updateReason == INVENTORY_UPDATE_REASON_PLAYER_LOCKED then return end

            -- Grab the item data
            local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
            if not itemLink or itemLink == "" then return end

            -- 2. FILTER: Ignore anything that isn't Wearable Gear
            -- (In ESO, Jewellery is classified as ITEMTYPE_ARMOR natively)
            local itemType = GetItemLinkItemType(itemLink)
            if itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_WEAPON then 
                return -- Stop scanning immediately if it's a potion, gem, or material
            end

            -- 3. Match against WatchList
            -- Ask the WatchList module to do the math and see if this item is wanted
            local matchedEntry = LootHound.WatchList:FindMatch(itemLink)
            
            if matchedEntry then
                -- 4. Execute Alerts: Fire the visual pop-up and audio chimes
                LootHound.AlertSystem:Trigger(itemLink, matchedEntry)
                
                -- 5. Auto-Cleanup: Delete the rule from the Watch List so it doesn't alert again
                LootHound.WatchList:Remove(matchedEntry.id)
                
                -- 6. UI Sync: If the player currently has the LootHound window open,
                -- refresh the UI so they watch the rule disappear in real-time.
                if LootHound.GUI and LootHound.GUI.RefreshWatchList then
                    LootHound.GUI:RefreshWatchList()
                end
            end
        end
    )
end