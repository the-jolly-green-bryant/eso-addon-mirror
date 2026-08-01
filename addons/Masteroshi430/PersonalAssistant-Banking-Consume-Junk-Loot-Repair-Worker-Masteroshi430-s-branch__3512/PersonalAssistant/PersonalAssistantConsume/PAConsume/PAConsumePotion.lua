-- Local instances of Global tables --
local PA = PersonalAssistant
local PAC = PA.Constants
local PACO = PA.Consume
local PAHF = PA.HelperFunctions

-- ---------------------------------------------------------------------------------------------------------------------

local function NextPotion()

   local slotIndex = nil
   local maxedPotionStacks = 0
   local minPotionStacks = 9999999
   
   local PACOMenuFunctions = PA.MenuFunctions.PAConsume
   --Check if the functionality is turned on within the addon
   local smallStacksFirst = PACOMenuFunctions.getAutoConsumePotionSmallStacksFirstSetting()
   local playerLevel = GetUnitLevel("player")
   
   local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
   if smallStacksFirst then
     for i, itemData in pairs(bagCache) do
        if itemData.itemType == ITEMTYPE_POTION then
          local usable = playerLevel >= GetItemRequiredLevel(BAG_BACKPACK, i)
          if usable then
             local itemStacks = itemData.stackCount
             if itemStacks < minPotionStacks and itemStacks ~= 0 then
                minPotionStacks = itemStacks
                slotIndex = i
             end
          end
        end
     end
  else
     for i, itemData in pairs(bagCache) do
        if itemData.itemType == ITEMTYPE_POTION then
          local usable = playerLevel >= GetItemRequiredLevel(BAG_BACKPACK, i)
          if usable then
             local itemStacks = itemData.stackCount
             if itemStacks > maxedPotionStacks then
                maxedPotionStacks = itemStacks
                slotIndex = i
             end
          end
        end
     end
  end
  
  return slotIndex
end

-- --------------------------------------------------------------------------------------------------------------------

local function CheckPotion()

  if not IsPlayerActivated() or IsCurrentCampaignVengeanceRuleset() then return end
	
	local level = GetUnitLevel("player")

	
	if IsUnitInCombat("player") then
		return
	else
		-- check if potion slot is empty after combat
    local currentQuickSlot = GetCurrentQuickslot()
    local itemLink = GetSlotItemLink(currentQuickSlot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local count = GetItemLinkInventoryCount(itemLink, INVENTORY_COUNT_BAG_OPTION_BACKPACK)
    local itemType = GetItemLinkItemType(itemLink)

    if itemType == ITEMTYPE_POTION and (not count or count == 0) then
       local theNext = NextPotion()
       if theNext then
				    local itemLink = PAHF.getFormattedItemLink(BAG_BACKPACK, theNext)
				    local itemLinkExt = PAHF.getIconExtendedItemLink(itemLink)
				    local stacks = GetSlotStackSize(BAG_BACKPACK, theNext)
            
			      --CallSecureProtected("ClearSlot", currentQuickSlot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
            CallSecureProtected("SelectSlotItem", BAG_BACKPACK, theNext, currentQuickSlot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)

				    PACO.println(GetString(SI_PA_CHAT_CONSUME_POTION)..stacks.." x "..itemLinkExt)
       end
    end
	end
	
end


-- ---------------------------------------------------------------------------------------------------------------------
-- Export
PA.Consume = PA.Consume or {}
PA.Consume.CheckPotion = CheckPotion
