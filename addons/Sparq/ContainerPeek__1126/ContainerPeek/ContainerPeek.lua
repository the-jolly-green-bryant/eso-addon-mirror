ContainerPeek = {}

ContainerPeek.name = "ContainerPeek"

-- If UseItem is protected, we need to use CallSecureProtected to call it.
local useCallProtectedFunction = IsProtectedFunction("UseItem")

-- Override a function, adding overridden function a first parameter.
local function Override(objectTable, existingFunctionName, hookFunction)
  if (type(objectTable) == "string") then
    hookFunction = existingFunctionName
    existingFunctionName = objectTable
    objectTable = _G
  end

  local existingFn = objectTable[existingFunctionName]
  if ((existingFn ~= nil) and (type(existingFn) == "function")) then    
    local newFn = function(...)
      return hookFunction(existingFn, ...)
    end
    objectTable[existingFunctionName] = newFn
  end
end

-- Add the "Peek" item to an inventorySlot if it is an autolooting container, but not a 'saved' item.
local function AddContextMenuOption(inventorySlot)
  local bag, index = ZO_Inventory_GetBagAndIndex(inventorySlot)

  if (ContainerPeek.IsAutolootContainer(bag, index) and (not ContainerPeek.IsSavedItem(bag,index))) then 
    AddMenuItem(GetString(SI_CONTAINER_PEEK_ITEM_ACTION_PEEK), function() ContainerPeek.TryUseItem(bag, index) end, MENU_ADD_OPTION_LABEL)
  end
  
  ShowMenu(self)
end

-- Prepare to add the "Peek" item to an inventorySlot.
local function AddContextMenuOptionSoon(inventorySlot)
  if(inventorySlot:GetOwningWindow() == ZO_TradingHouse) then return end
  if(ZO_PlayerInventoryBackpack:IsHidden() and ZO_PlayerBankBackpack:IsHidden() and ZO_GuildBankBackpack:IsHidden()) then return end

  zo_callLater(function() AddContextMenuOption(inventorySlot) end, 50)
end
    
-- Return true if the item in the given bag slot is a usable container that would be autolooted.
function ContainerPeek.IsAutolootContainer(bag, index)
  local usable, onlyFromActionSlot = IsItemUsable(bag, index)
    
  return (
    usable
    and (not onlyFromActionSlot) 
    and CanInteractWithItem(bag, index)
    and GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT) == "1" 
    and GetItemType(bag, index) == ITEMTYPE_CONTAINER
  )
end

-- Return true if the item is a "saved" item that may not be autolooted at all.
function ContainerPeek.IsSavedItem(bag, index)
  return (
    (FCOIsMarked ~= nil and FCOIsMarked(GetItemInstanceId(bag, index), -1))                          -- FCO ItemSaver Addon
    or (ItemSaver_IsItemSaved ~= nil and ItemSaver_IsItemSaved(bag, index))                          -- Item Saver Addon
    or string.match(GetItemName(bag, index), GetString(SI_CONTAINER_PEEK_MATCH_TREASURE_MAP)) ~= nil -- CE Treasure Map containers
  )
end

-- Call a function with Autoloot disabled
function ContainerPeek.DoWithoutAutoloot(func, ...)
  local autoloot_value = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)

  if (autoloot_value == "1") then
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, "0")
    zo_callLater(function() SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, "1") end, 50)
  end        
  
  -- We need to tail-call this to avoid SecureProtected errors.
  return func(...)
end  

-- Call a function with Autoloot enabled
function ContainerPeek.DoWithAutoloot(func, ...)
  local autoloot_value = GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT)

  if (autoloot_value == "0") then
    SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, "1")
    zo_callLater(function() SetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_AUTO_LOOT, "0") end, 50)
  end        
  
  -- We need to tail-call this to avoid SecureProtected errors.
  return func(...)
end  

-- Try to use the item in a bag slot, disabling autoloot while we do.
function ContainerPeek.TryUseItem(bag, index)
  local usable, onlyFromActionSlot = IsItemUsable(bag, index)
  
  if usable and not onlyFromActionSlot then
    ContainerPeek.DoWithoutAutoloot(
      function()
        if useCallProtectedFunction then
          if not CallSecureProtected("UseItem", bag, index) then
            PlaySound(SOUNDS.NEGATIVE_CLICK)
          end
        else
          UseItem(bag, index)
        end
      end
    )
  end        
end  

-- Override the "Use" SlotAction, make it potentially autoloot save.
local function OverrideUseAddSlotAction(parentFunc, self, actionStringId, actionCallback, ...)
  
  if (not ZO_PlayerInventoryBackpack:IsHidden() and actionStringId == SI_ITEM_ACTION_USE) then 
    local bag, index = ZO_Inventory_GetBagAndIndex(self.m_inventorySlot)  
    if (ContainerPeek.IsAutolootContainer(bag, index) and ContainerPeek.IsSavedItem(bag, index)) then
      return parentFunc(
        self, SI_CONTAINER_PEEK_ITEM_ACTION_USE, 
        function(...) return ContainerPeek.DoWithoutAutoloot(actionCallback, ...) end, 
        ...
      ) 
    end
  end
  
  return parentFunc(self, actionStringId, actionCallback, ...)
end


function ContainerPeek.Initialize()
  ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)
  Override(ZO_InventorySlotActions, "AddSlotAction", OverrideUseAddSlotAction)
end

function ContainerPeek.OnAddOnLoaded(event, addonName)
  if addonName == ContainerPeek.name then
    ContainerPeek.Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(ContainerPeek.name, EVENT_ADD_ON_LOADED, ContainerPeek.OnAddOnLoaded)