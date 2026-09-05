ShosPvPBanker = ShosPvPBanker or {}

-- Filter and Withdrawal Engine
function ShosPvPBanker.WithdrawPvPItems(mode)
    if not IsBankOpen() then return end
    
    -- Clear out localized tracking records so you can click buttons back-to-back
    ShosPvPBanker.processedItems = {}
    ShosPvPBanker.actionOccurred = false
    local queue = {}
    local playerAlliance = GetUnitAlliance("player")
    
    -- Scans standard vaults and ESO Plus subscriber slots back-to-back
    local targetedBags = { BAG_BANK, BAG_SUBSCRIBER_BANK }
    
    for _, bagId in ipairs(targetedBags) do
        local bankSize = GetBagSize(bagId)
        
        -- Scan slots directly to completely bypass async UI cache lag
        for slotIndex = 0, bankSize - 1 do
            local itemLink = GetItemLink(bagId, slotIndex)
            if itemLink and itemLink ~= "" then
                local itemType = GetItemLinkItemType(itemLink)
                local itemId = GetItemLinkItemId(itemLink)
                local rawName = GetItemLinkName(itemLink)
                
                -- Standardize names to clean lowercase string text for matching
                local itemName = zo_strformat("<<t:1>>", rawName):lower()
                local shouldWithdraw = false
                
                if mode == "IC" then
                    -- STRICT MATCH: Extract the Sigil of Imperial Retreat by exact ID or clean name keyword
                    if itemId == 153629 or string.find(itemName, "imperial retreat") then
                        shouldWithdraw = true
                    end
                    
                elseif mode == "CYRODIIL" then
                    -- Exclude food, drink, and explicitly block all War Tortes and recipes
                    local isFoodOrDrink = (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK)
                    local isTorte = string.find(itemName, "torte") ~= nil

                    if not isFoodOrDrink and not isTorte then
                        -- Separate items based on your precise rule specifications
                        local isRecall = string.find(itemName, "recall") or (itemId == 138711)
                        local isRepair = string.find(itemName, "repair") and (itemType == ITEMTYPE_AVA_REPAIR or itemType == 29 or itemType == 47)
                        
                        if isRepair and (string.find(itemName, "recipe") or string.find(itemName, "blueprint") or string.find(itemName, "motif") or string.find(itemName, "design")) then
                            isRepair = false
                        end
                        
                        -- Flaming Oil is universal; group it together with universal stones and kits
                        local isUniversalPvP = isRecall or isRepair or string.find(itemName, "flaming oil")
                        
                        -- Faction restricted siege categories (Rams, Camps, Ballistas, Catapults, Trebuchets)
                        -- Added boundary/word check for 'ram' and 'camp' to avoid substring misfires
                        local isFactionSiege = (itemType == ITEMTYPE_SIEGE or itemType == 4) 
                            or string.find(itemName, "ballista") 
                            or string.find(itemName, "trebuchet") 
                            or string.find(itemName, "catapult") 
                            or string.find(itemName, "camp") 
                            or string.find(itemName, "lancer") 
                            or string.find(itemName, "ram") 
                            or string.find(itemName, "scattershot")
                        
                        if isUniversalPvP then
                            -- Universal tools can be taken unconditionally by any character
                            shouldWithdraw = true
                        elseif isFactionSiege and (not string.find(itemName, "flaming oil")) then
                            -- Robust string filtering for faction alliance restrictions
                            local hasDominion = string.find(itemName, "dominion") or string.find(itemName, "aldmeri")
                            local hasCovenant = string.find(itemName, "covenant") or string.find(itemName, "daggerfall")
                            local hasPact = string.find(itemName, "pact") or string.find(itemName, "ebonheart")
                            
                            if playerAlliance == ALLIANCE_ALDMERI_DOMINION and hasDominion then
                                shouldWithdraw = true
                            elseif playerAlliance == ALLIANCE_DAGGERFALL_COVENANT and hasCovenant then
                                shouldWithdraw = true
                            elseif playerAlliance == ALLIANCE_EBONHEART_PACT and hasPact then
                                shouldWithdraw = true
                            elseif not (hasDominion or hasCovenant or hasPact) then
                                -- Fallback for any unaligned siege items
                                shouldWithdraw = true
                            end
                        end
                    end
                end
                
                if shouldWithdraw then
                    table.insert(queue, {
                        bagId = bagId,
                        slotIndex = slotIndex,
                        name = zo_strformat("<<1>>", rawName),
                        link = itemLink
                    })
                end
            end
        end
    end
    
    -- Run item movement pipeline if elements matched criteria
    if #queue > 0 then
        ShosPvPBanker.ProcessWithdrawalQueue(queue, 1)
    else
        d(ShosPvPBanker.name .. " No matching items found in bank to withdraw.")
    end
end
