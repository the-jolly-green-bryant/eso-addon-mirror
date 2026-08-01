-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants
local PAR = PA.Repair
local PAHF = PA.HelperFunctions
local PAEM = PA.EventManager

-- ---------------------------------------------------------------------------------------------------------------------

local _lastNoRepairKitWarningGameTime = 0

local _repairKitItemIds = {
    --[44874] = function() return GetUnitLevel("player") < 10 end,  -- Petty Repair Kit             < lvl 10 REMOVED IN UPDATE 41
	--[44875] = function() return GetUnitLevel("player") < 20 end,  -- Minor Repair Kit             < lvl 20 REMOVED IN UPDATE 41 
	--[44876] = function() return GetUnitLevel("player") < 30 end,  -- Lesser Repair Kit            < lvl 30 REMOVED IN UPDATE 41
	--[44877] = function() return GetUnitLevel("player") < 40 end,  -- Comon Repair Kit             < lvl 40 REMOVED IN UPDATE 41
	--[44878] = function() return GetUnitLevel("player") < 50 end,  -- Greater Repair Kit           < lvl 50  REMOVED IN UPDATE 41
    
	[157516] = true,                                              -- Impresario's Group Repair Kit / no tier
	[135113] = true,                                              -- Bound Crown Repair Kit / no tier
	[932362] = true,                                              -- Crown Repair Kit    Tier=7   any
	[61079] = true,                                               -- Crown Repair Kit    Tier=7   any
	[44879] = true,                                               -- Equipment Repair Kit Tier=6   any  
}

-- --------------------------------------------------------------------------------------------------------------------

local function _getRepairKitsIn(bagId)

    local itemIdComparator = PAHF.getItemIdComparator(_repairKitItemIds, true)
    local repairKitBagCache = SHARED_INVENTORY:GenerateFullSlotData(itemIdComparator, bagId)

    local repairKitTable = setmetatable({}, { __index = table })
    local totalRepairKitCount = 0
	local PARepairSavedVars = PAR.SavedVars
    local defaultRepairKit = PARepairSavedVars.RepairEquipped.defaultRepairKit

    -- create a table with all repairKits
    for _, data in pairs(repairKitBagCache) do
        -- check if it is a repair kit
		local isGroupRepairKitAndCanUse = GetItemId(data.bagId, data.slotIndex) == 157516 and PARepairSavedVars.RepairEquipped.groupRepairKit and IsUnitGrouped("player")
        local isBoundCrownRepairKit = GetItemId(data.bagId, data.slotIndex) == 135113 
        if IsItemRepairKit(data.bagId, data.slotIndex) or isGroupRepairKitAndCanUse or isBoundCrownRepairKit then
			local tier
			if isGroupRepairKitAndCanUse then 
			   if defaultRepairKit == DEFAULT_SOUL_GEM_CHOICE_GOLD then
			       tier = 1
			   else
			       tier = 8
			   end
			elseif isBoundCrownRepairKit then
			   if defaultRepairKit == DEFAULT_SOUL_GEM_CHOICE_GOLD then
			       tier = 8
			   else
			       tier = 1
			   end
			else
			    tier = GetRepairKitTier(data.bagId, data.slotIndex)
			end
			
            repairKitTable:insert({
                bagId = data.bagId,
                slotIndex = data.slotIndex,
                itemName = data.name,
                itemLink = GetItemLink(data.bagId, data.slotIndex, LINK_STYLE_BRACKETS),
                --stackCount = data.stackCount,
                repairKitTier = tier,
                iconString = "|t20:20:"..data.iconFile.."|t ",
            })
            -- update the total repairKit count
            totalRepairKitCount = totalRepairKitCount + data.stackCount
		end
    end

    if defaultRepairKit == DEFAULT_SOUL_GEM_CHOICE_GOLD then
        -- sort table based on the repairKitTiers (lower tier first | regular = tier 6 | crown = tier 7)
        table.sort(repairKitTable, function(a, b) return a.repairKitTier < b.repairKitTier end)
    else
        -- sort table based on the repairKitTiers (higher tier first | crown = tier 7 | regular = tier 6 )
        table.sort(repairKitTable, function(a, b) return a.repairKitTier > b.repairKitTier end)
    end

    return repairKitTable, totalRepairKitCount
end

-- --------------------------------------------------------------------------------------------------------------------

local function RepairEquippedItemWithRepairKit(bagId, slotIndex)
    -- only proceed if player is not dead (since repairKits cannot be used then)
    if not PAHF.isPlayerDeadOrReincarnating() then
        -- check if it is enabled
        local PARepairSavedVars = PAR.SavedVars
        if bagId == BAG_WORN and PARepairSavedVars.RepairEquipped.repairWithRepairKit then
            local hasDurability = DoesItemHaveDurability(bagId, slotIndex)
            -- check if it is repairable
            if hasDurability then
                local itemCondition = GetItemCondition(bagId, slotIndex)
                local repairKitThreshold = PARepairSavedVars.RepairEquipped.repairWithRepairKitThreshold
                PAR.debugln("%s is at %d%%", GetItemName(bagId, slotIndex), itemCondition)
                -- check if it is below and would need to be repaired
                if itemCondition <= repairKitThreshold then
                    local repairKitTable, totalRepairKitCount = _getRepairKitsIn(BAG_BACKPACK)
                    if totalRepairKitCount > 0 then
                        local firstRepairKit = repairKitTable[1]
                        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_BRACKETS)
                        local repairableAmount = GetAmountRepairKitWouldRepairItem(bagId, slotIndex, firstRepairKit.bagId, firstRepairKit.slotIndex)
                        local isNotGrouprepairKit = IsItemNonGroupRepairKit(firstRepairKit.bagId, firstRepairKit.slotIndex)
						local isBoundCrownRepairKit = GetItemId(firstRepairKit.bagId, firstRepairKit.slotIndex) == 135113
						
                        -- just to be sure, check again if there is anything left to repair (in case of double-event-triggers)
                        if repairableAmount > 0 or not isNotGrouprepairKit or isBoundCrownRepairKit then
                            -- some debug information
                            PAR.debugln("Want to repair %s with %s for %d from %d/%d", itemLink, firstRepairKit.itemName, repairableAmount, itemCondition, 100)
                            local isNormalRepairKit = IsItemNonCrownRepairKit(firstRepairKit.bagId, firstRepairKit.slotIndex)
							
							
                            if isNormalRepairKit and isNotGrouprepairKit then
                                -- actually repair the item with a normal repair kit
                                RepairItemWithRepairKit(bagId, slotIndex, firstRepairKit.bagId, firstRepairKit.slotIndex)
                                -- reduce repairKit count and play repair sound
                                totalRepairKitCount = totalRepairKitCount - 1
                                PlaySound(SOUNDS.INVENTORY_ITEM_REPAIR)
                                -- show output to chat
                                PAR.println(SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED, itemLink, itemCondition, firstRepairKit.itemLink)
                            else
                                -- actually repair all items with a crown repair kit
                                if PAHF.attemptToUseItem(firstRepairKit.bagId, firstRepairKit.slotIndex) then
                                    -- reduce repairKit count and play repair sound
                                    totalRepairKitCount = totalRepairKitCount - 1
                                    PlaySound(SOUNDS.INVENTORY_ITEM_REPAIR)
                                    -- show output to chat
                                    PAR.println(SI_PA_CHAT_REPAIR_REPAIRKIT_REPAIRED_ALL, itemLink, itemCondition, firstRepairKit.itemLink)
                                else
                                    -- Item(s) could somehow not be repaired
                                    PAR.debugln("Call of \"UseItem(%s)\" failed! IsUnitInCombat(player) = %s", itemLink, tostring(PAHF.isPlayerInCombat()))
                                    -- Try again when combat is dropped
                                    PAEM.RegisterForEvent(PAR.AddonName, EVENT_PLAYER_COMBAT_STATE, PAR.CheckAndRepairAllEquippedItemsWithRepairKitsCombatState, "RepairKits-DropCombat")
                                end
                            end
                        end
                    end

                    -- check remaining repair kits
                    local lowRepairKitThreshold = PARepairSavedVars.RepairEquipped.lowRepairKitThreshold
                    if totalRepairKitCount <= lowRepairKitThreshold and PARepairSavedVars.RepairEquipped.lowRepairKitWarning then
                        local formatted = zo_strformat(GetString(SI_PA_PATTERN_REPAIRKIT_COUNT), totalRepairKitCount)

                        if totalRepairKitCount == 0 then
                            -- if no repair kits left, have a orange-red message (but only every 10 minutes)
                            local gameTimeMilliseconds = GetGameTimeMilliseconds()
                            local gameTimeMillisecondsPassed = gameTimeMilliseconds - _lastNoRepairKitWarningGameTime
                            local gameTimeMinutesPassed = gameTimeMillisecondsPassed / 1000 / 60
                            if gameTimeMinutesPassed >= 10 then
                                _lastNoRepairKitWarningGameTime = gameTimeMilliseconds
                                PAR.println(formatted, PAC.COLORS.ORANGE_RED, PAC.COLORS.ORANGE_RED)
                            end
                        elseif totalRepairKitCount <= lowRepairKitThreshold then
                            if totalRepairKitCount <= 5 then
                                -- if at or below 5 soul gems, have a orange message
                                PAR.println(formatted, PAC.COLORS.ORANGE, PAC.COLORS.ORANGE)
                            else
                                -- in all other cases, have a yellow message
                                PAR.println(formatted, PAC.COLORS.DEFAULT, PAC.COLORS.DEFAULT)
                            end
                        end
                    end
                end
            end
        end
    else
        PAR.debugln("RepairEquippedItemWithRepairKit.isPlayerDeadOrReincarnating (caught!)")
    end
end

local function CheckAndRepairSingleEquippedItemWithRepairKit(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- need to wait a little bit (e.g. 500ms) because this event is also triggered when dying, but [IsUnitDead("player")] still returns 'false' for a short amount of time
    -- because the durability loss (triggering this function) happens before the player actually is considered dead
    -- triggering a repair when dead can cause ESO to hang itself and force the player to the login screen
    zo_callLater(function() RepairEquippedItemWithRepairKit(bagId, slotIndex) end, 500)
end

local function CheckAndRepairAllEquippedItemsWithRepairKits()
    -- only proceed if player is not dead (since repairKits cannot be used then)
    if not PAHF.isPlayerDeadOrReincarnating() then
        local bagCache = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_WORN)
        for _, itemData in pairs(bagCache) do
            if DoesItemHaveDurability(itemData.bagId, itemData.slotIndex) then
                RepairEquippedItemWithRepairKit(itemData.bagId, itemData.slotIndex)
            end
        end
    end
end

local function CheckAndRepairAllEquippedItemsWithRepairKitsCombatState(eventCode, inCombat)
	-- anti spam
	PAR.SavedVars.LastRepair = PAR.SavedVars.LastRepair or 0
	if GetTimeStamp() == PAR.SavedVars.LastRepair then
	   return
	end
    PAR.SavedVars.LastRepair = GetTimeStamp()	
	
	-- only proceed if player is no longer in combat
    if not inCombat then
        PAR.debugln("combat dropped - check all items")
        PAEM.UnregisterForEvent(PAR.AddonName, EVENT_PLAYER_COMBAT_STATE, "RepairKits-DropCombat")
        CheckAndRepairAllEquippedItemsWithRepairKits()
    end
end

-- ---------------------------------------------------------------------------------------------------------------------
-- Export
PA.Repair = PA.Repair or {}
PA.Repair.CheckAndRepairSingleEquippedItemWithRepairKit = CheckAndRepairSingleEquippedItemWithRepairKit
PA.Repair.CheckAndRepairAllEquippedItemsWithRepairKits = CheckAndRepairAllEquippedItemsWithRepairKits
PA.Repair.CheckAndRepairAllEquippedItemsWithRepairKitsCombatState = CheckAndRepairAllEquippedItemsWithRepairKitsCombatState
PA.Repair._getRepairKitsIn = _getRepairKitsIn