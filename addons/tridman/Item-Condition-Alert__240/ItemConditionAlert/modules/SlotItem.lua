local ItemConditionAlert = {}
ItemConditionAlert = _G["ItemConditionAlert"]
ItemConditionAlert.SlotItem = {}

ItemConditionAlert.SlotItem.StateThresholds = {}
ItemConditionAlert.SlotItem.DefaultItems = ZO_Object:Subclass()

-- Represents state of an item.
ItemConditionAlert.SlotItem.ItemState = {
  ["UNDEFINED"]       = -1,
  [ItemConditionAlert.ItemStates[1]] = 1, 
  [ItemConditionAlert.ItemStates[2]] = 2, 
  [ItemConditionAlert.ItemStates[3]] = 3,  
  [ItemConditionAlert.ItemStates[4]] = 4, 
  [ItemConditionAlert.ItemStates[5]] = 5, 
}

function ItemConditionAlert.SlotItem.DefaultItems:New( ... )
    local result = ZO_Object.New( self )
    result:Initialize( ... )
    return result
end

function ItemConditionAlert.SlotItem.DefaultItems:Initialize()

  self.HELM        = {Name="hood",       Slot = EQUIP_SLOT_HEAD,        Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.CHEST       = {Name="chest",      Slot = EQUIP_SLOT_CHEST,       Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.SHOULDERS   = {Name="shoulder",   Slot = EQUIP_SLOT_SHOULDERS,   Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.HANDS       = {Name="glove",      Slot = EQUIP_SLOT_HAND,        Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.WAIST       = {Name="waist",      Slot = EQUIP_SLOT_WAIST,       Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.LEGS        = {Name="legs",       Slot = EQUIP_SLOT_LEGS,        Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.FEET        = {Name="feet",       Slot = EQUIP_SLOT_FEET,        Type = ItemConditionAlert.TYPE_ARMOR,  Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.MAIN_HAND   = {Name="mainhand",   Slot = EQUIP_SLOT_MAIN_HAND,   Type = ItemConditionAlert.TYPE_WEAPON, Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.OFF_HAND    = {Name="offhand",    Slot = EQUIP_SLOT_OFF_HAND,    Type = ItemConditionAlert.TYPE_WEAPON, Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.BACKUP_MAIN = {Name="backupmain", Slot = EQUIP_SLOT_BACKUP_MAIN, Type = ItemConditionAlert.TYPE_WEAPON, Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  self.BACKUP_OFF  = {Name="backupoff",  Slot = EQUIP_SLOT_BACKUP_OFF,  Type = ItemConditionAlert.TYPE_WEAPON, Condition = -1,  State = nil, X = 0, Y = 0, Ignoreautoswitch = false}
  
end


function ItemConditionAlert.SlotItem:UpdateThresholds()
  self.StateThresholds = {
    [ItemConditionAlert.ItemStates[1]] = ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[1]],
    [ItemConditionAlert.ItemStates[2]] = ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[2]],
    [ItemConditionAlert.ItemStates[3]] = ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[3]], 
    [ItemConditionAlert.ItemStates[4]] = ItemConditionAlert.sv.StateThresholds[ItemConditionAlert.ItemStates[4]],
  }
end

function ItemConditionAlert.SlotItem:GetState(slot)

  local hasDurability = DoesItemHaveDurability(BAG_WORN,slot)
  local hasCharges = IsItemChargeable(BAG_WORN, slot)
  local cond = -1
  
  if hasDurability then
    cond = GetItemCondition(BAG_WORN, slot)    
  elseif hasCharges then
    local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, slot)
    cond = math.floor(charges  * 100 / maxCharges)
  else
    cond = -1
  end
  
  if (cond == 0) then
    return self.ItemState[ItemConditionAlert.ItemStates[5]], cond
  elseif (cond < self.StateThresholds[ItemConditionAlert.ItemStates[4]][2]) then
    return self.ItemState[ItemConditionAlert.ItemStates[4]], cond
  elseif (cond < self.StateThresholds[ItemConditionAlert.ItemStates[3]][2]) then
    return self.ItemState[ItemConditionAlert.ItemStates[3]], cond
  elseif (cond < self.StateThresholds[ItemConditionAlert.ItemStates[2]][2]) then
    return self.ItemState[ItemConditionAlert.ItemStates[2]], cond
  elseif (cond < self.StateThresholds[ItemConditionAlert.ItemStates[1]][2]) then
    return self.ItemState[ItemConditionAlert.ItemStates[1]], cond
  else
    return self.ItemState["UNDEFINED"], cond
  end
  
end