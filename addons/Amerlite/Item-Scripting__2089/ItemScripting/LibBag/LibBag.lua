
local Require, Export, Event = LibAddon('LibBag')
local Insert = table.insert

local moveQueue  = { }
local ItemId     = GetItemId
local ItemLink   = GetItemLink
local IsItemJunk = IsItemJunk
local StackSize  = GetSlotStackSize
local BankingBag = GetBankingBag
local GetString  = GetString
local BACKPACK   = BAG_BACKPACK

local function Map (list, func)
  local new = { }
  for i, v in ipairs(list) do new[i] = func(v) end
  return new
end

local function Contains (list, ...)
  for _, item in pairs(list) do
    for _, value in pairs{...} do 
      if value == item then return true end
    end
  end return false
end

-----------------------------------------------------------
-- Item Object
-----------------------------------------------------------

local function Item (bag, slot)

  local Item = { }
  local link = ItemLink(bag, slot, 1)
  local bag2 = bag == BACKPACK and BankingBag() or BACKPACK

  -- Item Utility Functions -------------------------------

  local function FillSlot ()
    local id = ItemId(bag, slot)
    for slot2 = 0, GetBagUseableSize(bag2) do
      if ItemId(bag2, slot2) == id then 
        local stack2, max = StackSize(bag2, slot2)
        if stack2 < max then return slot2, (max - stack2) end
      end
    end
  end

  local function MoveItem (count, slot2)
    CallSecureProtected('RequestMoveItem', bag, slot, bag2, 
      slot2 or FindFirstEmptySlotInBag(bag2),
      count or StackSize(bag, slot))
  end

  -- Strings ----------------------------------------------

  -- (string) Serialised representation.
  function Item:Link () 
    return link 
  end

  -- (string) Display name of item.
  function Item:Name () 
    return GetItemName(bag, slot) 
  end

  -- (string) Name of player who crafted item. Can be empty string.
  function Item:CreatorName ()
    return GetItemCreatorName(bag, slot)
  end

  -- (string) Flavor text of item.
  function Item:FlavorText ()
    return GetItemLinkFlavorText(link)
  end

  -- (string) File path to icon image.
  function Item:Icon ()
    local icon = GetItemInfo(bag, slot)
    return icon
  end

  -- Numbers ----------------------------------------------

  -- (int) Item id, not instance id.
  function Item:ID () 
    return ItemId(bag, slot)
  end

  -- (int) Item bag id.
  function Item:BagID ()
    return bag
  end

  -- (int) Item slot index.
  function Item:Slot ()
    return slot
  end

  -- (int) The size of the item stack.
  function Item:Stack ()
    local num = StackSize(bag, slot)
    return num
  end

  -- (int) Max stacking size of this item.
  function Item:MaxStack ()
    local _, num = StackSize(bag, slot)
    return num
  end

  -- (int) How many of this item are in the backpack.
  function Item:InBackpack ()
    local num = GetItemLinkStacks(link)
    return num
  end

  -- (int) How many of this item are in the bank.
  function Item:InBank ()
    local _, num = GetItemLinkStacks(link)
    return num
  end

  -- (int) How many of this item are in the craftbag.
  function Item:InCraftbag ()
    local _, _, num = GetItemLinkStacks(link)
    return num
  end

  -- (int) Main stat like armor or damage.
  function Item:Stat () 
    return GetItemStatValue(bag, slot) 
  end

  -- (int) Gear item level 0-50.
  function Item:Level () 
    return GetItemRequiredLevel(bag, slot) 
  end

  -- (int) Gear champion point level 0-160.
  function Item:CP () 
    return GetItemRequiredChampionPoints(bag, slot) 
  end

  -- (int) Vendor gold sell value.
  function Item:Value()
    return GetItemSellValueWithBonuses(bag, slot)
  end

  -- (int) Craft skill level 1-10.
  function Item:CraftRank () 
    return GetItemLinkRequiredCraftingSkillRank(link) 
  end

  -- (int) Condition 0-100 where 0 is broken.
  function Item:Condition () 
    return GetItemCondition(bag, slot) 
  end

  -- Number/String ----------------------------------------

  -- (int, string) General type id, name.
  function Item:Type ()
    local num = GetItemType(bag, slot)
    return num, GetString('SI_ITEMTYPE', num)
  end

  -- (int, string) Specific type id, name.
  function Item:SpecialType ()
    local _, num = GetItemType(bag, slot)
    if num == 0 then return 0, GetString('SI_ITEMTYPE', num) end
    return num, GetString('SI_SPECIALIZEDITEMTYPE', num)
  end

  -- (int, string) Trait id, name.
  function Item:Trait ()
    local num = GetItemTrait(bag, slot)
    if num == 0 then return 0, GetString('SI_ITEMTYPE', num) end
    return num, GetString('SI_ITEMTRAITTYPE', num)
  end

  -- (int, string) Armor type id, name.
  function Item:ArmorType ()
    local num = GetItemArmorType(bag, slot)
    return num, GetString('SI_ARMORTYPE', num)
  end

  -- (int, string) Weapon type id, name.
  function Item:WeaponType ()
    local num = GetItemWeaponType(bag, slot)
    if num == 0 then return 0, GetString('SI_ITEMTYPE', 0) end
    if num == 7 then return 0, GetString('SI_ITEMTYPE', 0) end
    return num, GetString('SI_WEAPONTYPE', num)
  end

  -- (int, string) Quality level 0-5.
  function Item:Quality ()
    local _, _, _, _, _, _, _, num = GetItemInfo(bag, slot)
    return num, GetString('SI_ITEMQUALITY', num)
  end

  -- (int, string) Gear set id, name.
  function Item:GearSet ()
    local hasSet, name, _, _, _, num = GetItemLinkSetInfo(link)
    if hasSet then return num, name 
    else return num, GetString('SI_ITEMTYPE', 0) end
  end

  -- Lists ------------------------------------------------

   -- ({int}) Filter type ids.
  function Item:FilterTypes ()
    return { GetItemFilterTypeInfo(bag, slot) }
  end

  -- ({string}) Filter type names.
  function Item:FilterNames ()
    return Map(Item:FilterTypes(), function (num) 
      return GetString('SI_ITEMFILTERTYPE', num) 
    end)
  end

  -- Boolean ----------------------------------------------

  -- (boolean) Is this item crafted?
  function Item:IsCrafted () 
    return IsItemLinkCrafted(link) 
  end

  -- (boolean) Is this item consumable for the player?
  function Item:IsConsumable () 
    return IsItemConsumable(bag, slot) 
  end

  -- (boolean) Is this Item bound to acount or character?
  function Item:IsBound () 
    return IsItemBound(bag, slot) 
  end

  -- (boolean) Is this item usable for the player?
  function Item:IsUsable () 
    return IsItemUsable(bag, slot) 
  end

  -- (boolean) Is this item marked as stolen?
  function Item:IsStolen () 
    return IsItemStolen(bag, slot) 
  end

  -- (boolean) Is this item equipable by the player?
  function Item:IsEquipable () 
    return IsEquipable(bag, slot) 
  end

  -- (boolean) Is this item marked as junk?
  function Item:IsJunk () 
    return IsItemJunk(bag, slot) 
  end

  -- (boolean) Is this item marked as locked by the player?
  function Item:IsLocked () 
    return IsItemPlayerLocked(bag, slot) 
  end

  -- (boolean) Is this a recipe/book that is known by the character?
  function Item:IsKnown () 
    return IsItemLinkRecipeKnown(link) or IsItemLinkBookKnown(link) 
  end

  -- (boolean) Is this item in a quickslot?
  function Item:IsQuickslotted ()
    local index = FindActionSlotMatchingItem(bag, slot, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    return index ~= nil
  end

  -- (boolean) Is this item researcahble by the currnet character?
  function Item:IsResearchable ()
    local info = GetItemTraitInformation(bag, slot)
    return info == ITEM_TRAIT_INFORMATION_CAN_BE_RESEARCHED
  end

  -- (boolean) Is this item's set collected?
  function Item:IsCollected ()
    return IsItemSetCollectionPieceUnlocked(ItemId(bag, slot))
  end

  -- (boolean) Is this item one of the listed types?
  function Item:IsType (...)
    return Contains({...}, Item:Type())
  end

  -- (boolean) Is this item one of the listed special types?
  function Item:IsSpecialType (...)
    return Contains({...}, Item:SpecialType())
  end

  -- (boolean) Is this item one of the listed filter types?
  function Item:IsFilterType (...)
    return Contains(Item:FilterTypes(), ...) 
        or Contains(Item:FilterNames(), ...)
  end

  -- (boolean) is this item have one of the listed traits?
  function Item:IsTrait (...)
    return Contains({...}, Item:Trait())
  end

  -- (boolean) Is item name one of the listed names?
  function Item:IsName (...)
    return Contains({...}, Item:Name())
  end

  -- (boolean) Does this item have a gear set?
  function Item:HasSet ()
    local hasSet = GetItemLinkSetInfo(link)
    return hasSet
  end

  -- Actions ----------------------------------------------

  -- (nil) Try to use the item.
  function Item:Use () 

    if not IsItemUsable(bag, slot)
    or not CanInteractWithItem(bag, slot)
      then return end

    if GetItemCooldownInfo(bag, slot) > 0
      then return end

    CallSecureProtected('UseItem', bag, slot)
  end

  -- (nil) Try to repair item at a vendor.
  function Item:Repair () 

    if not CanStoreRepair() 
    or not GetInteractionType() == INTERACTION_VENDOR 
      then return end

    if not DoesItemHaveDurability(bag, slot) 
      then return end

    if GetItemCondition(bag, slot) == 100 
      then return end

    RepairItem(bag, slot)   
  end

  -- (nil) Try to repair item with a repair kit.
  function Item:RepairWith (kitSlot)

    if not DoesItemHaveDurability(bag, slot) 
      then return end

    if GetItemCondition(bag, slot) == 100 
      then return end

    if not IsItemRepairKit(bag, kitSlot) 
      then return end

    RepairItemWithRepairKit(bag, slot, bag, kitSlot)
  end

  -- (nil) Try to sell item at an vendor.
  function Item:Sell (count) 

    local count = count or stack
    local total, used = GetFenceSellTransactionInfo()

    if not GetInteractionType() == INTERACTION_VENDOR 
      then return end

    if IsItemPlayerLocked(bag, slot) 
      then return end

    if used == total and IsItemStolen(bag, slot) 
      then return end

    SellInventoryItem(bag, slot, count) 
  end

  -- (nil) Try to launder Item at a fence.
  function Item:Launder (count) 

    local total, used = GetFenceLaunderTransactionInfo()

    if not GetInteractionType() == INTERACTION_VENDOR 
      then return end

    if used == total 
      then return end

    if not IsItemStolen(bag, slot)
      then return end

    LaunderItem(bag, slot, count)
  end

  -- (nil) Try to destory the item.
  function Item:Destroy () 

    if IsItemPlayerLocked(bag, slot) 
      then return end

    DestroyItem(bag, slot)
  end

  -- (nil) Try to equip the item.
  function Item:Equip (toSlot) 

    if not IsEquipable(bag, slot)
      then return end

    EquipItem(bag, slot, toSlot)
  end
    
  -- (nil) Set item as junk.
  function Item:Junk ()

    if IsItemPlayerLocked(bag, slot)
      then return end

    if not CanItemBeMarkedAsJunk(bag, slot)
      then return end

    SetItemIsJunk(bag, slot, true)
  end

  -- (nil) Unset item as junk.
  function Item:Unjunk ()

    if not IsItemJunk(bag, slot) 
      then return end

    SetItemIsJunk(bag, slot, false)
  end

  -- (nil) Lock the item.
  function Item:Lock ()

    if not CanItemBePlayerLocked(bag, slot) 
      then return end
      
    SetItemIsPlayerLocked(bag, slot, true)
  end

  -- (nil) Unlock the item.
  function Item:Unlock ()

    if not IsItemPlayerLocked(bag, slot)
      then return end

    SetItemIsPlayerLocked(bag, slot, false)
  end

  -- (nil) Try to enchant item with a glyph.
  function Item:Enchant (glyphSlot)

    if not CanItemTakeEnchantment(bag, slot, bag, glyphSlot) 
      then return end
      
    EnchantItem(bag, slot, bag, glyphSlot)
  end

  -- (nil) Try to charge item with a soul gem.
  function Item:Charge (gemSlot)

    if not IsItemChargeable(bag, slot)
      then return end

    if not IsItemSoulGem(SOUL_GEM_TYPE_FILLED, bag, gemSlot)
      then return end

    ChargeItemWithSoulGem(bag, slot, bag, gemSlot)
  end

  -- (nil) Try to move item to backpack or bank.
  function Item:Transfer ()

    if IsItemJunk(bag, slot) 
      then return end

    Insert(moveQueue, function() 
      local slot2, fill = FillSlot()
      if slot2 then MoveItem(fill, slot2)
        local extra = StackSize(bag, slot) - fill
        if extra > 0 then Insert(moveQueue, 
        function() MoveItem(extra) end) end
      else MoveItem() end
    end)

  end

  -- (nil) Try to move item to only fill a partial stack.
  function Item:TransferFill ()

    if IsItemJunk(bag, slot) 
      then return end

    Insert(moveQueue, function() 
      local slot2, fill = FillSlot()
      if slot2 then MoveItem(fill, slot2) end
    end)
    
  end

  return Item
end

-----------------------------------------------------------
-- Bag Object
-----------------------------------------------------------

local function Bag (id)

  local Bag = { }

  -- (item) Get an item in this bag.
  function Bag:Item (slot) 
    return Item(id, slot) 
  end

  -- (int) The ID of the bag.
  function Bag:ID ()
    return id
  end

  -- (int) Total number of slots this bag has.
  function Bag:Size () 
    return GetBagUseableSize(id) 
  end

  -- (int) Number of slots without an item.
  function Bag:NumFree () 
    return GetNumBagFreeSlots(id) 
  end

  -- (int) Number of slots with an item.
  function Bag:NumUsed () 
    return GetNumBagUsedSlots(id) 
  end

  -- (int) Slot number of the next empty slot.
  function Bag:FirstFree () 
    return FindFirstEmptySlotInBag(id) 
  end

  -- (boolean) Does this bag have Items marked as junk in it?
  function Bag:HasJunk () 
    return HasAnyJunk(id, true) 
  end

  -- (boolean) Does this bag have stolen Items?
  function Bag:HasStolen () 
    return AreAnyItemsStolen(id) 
  end

  -- (boolean) Is a slot in this bag filled or not?
  function Bag:IsUsed (slot) 
    return HasItemInSlot(id, slot) 
  end

  -- (interator) Each item in the bag to be used in a for loop.
  function Bag:Items ()
    local index, size = -1, GetBagUseableSize(id) 
    return function ()
      index = index + 1
      while index <= size do 
        if HasItemInSlot(id, index) then 
        return Item(id, index), index end
        index = index + 1
      end
    end
  end

  -- (nil) Try to sell all junk at a vendor.
  function Bag:SellJunk ()
      
    if GetInteractionType() ~= INTERACTION_VENDOR
      then return end

    if not HasAnyJunk(id, true) 
      then return end
      
    SellAllJunk()
  end

  -- (nil) Stack all items in the bag.
  function Bag:StackAll ()
    StackBag(id)
  end

  return Bag
end

-----------------------------------------------------------
-- Events
-----------------------------------------------------------

Event.On (EVENT_OPEN_BANK, function (code, bankId)
  Event.OnUpdate(500, function () 
    local index, func = next(moveQueue)
    if index then func(); moveQueue[index] = nil
    else Event.ForgetUpdate() end
  end)
end)

Event.On (EVENT_CLOSE_BANK, function () 
  Event.ForgetUpdate()
  moveQueue = { }
end)

Export('Bag', Bag, true)