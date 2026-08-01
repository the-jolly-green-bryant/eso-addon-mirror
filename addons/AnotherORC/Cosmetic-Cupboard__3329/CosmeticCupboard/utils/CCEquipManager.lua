local CC_EQUIP_NAMES = {
  QUICKSLOT_UPDATE   = 'CC_QUICK_UPDATE',
  COLLECTIBLE_UPDATE = 'CC_COL_UPDATE',
  FINISHED           = 'CC_HAS_FINISHED',
  BLOCKED            = 'CC_WAS_BLOCKED'
}

local CCEquipManager = ZO_Object:Subclass()

function CCEquipManager:New(...)
  local equipManager = ZO_Object.New(self)
  equipManager:Initialize(...)
  return equipManager
end

function CCEquipManager:Initialize()
  self.hasStartedEquip = false
  self.isEquiping = false

  -- List of collectibles to use
  self.collectionQueue = CC_Queue:New()
  self.quickslotQueue = CC_Queue:New()
end


--[[
  Return if an outfit is currently being equiped
]]--
function CCEquipManager:IsEquiping()
  return self.isEquiping
end

--[[
  This is called when both equipe queus are finished.
  This is the case when everything from an outfit has
  been equiped.
]]--
function CCEquipManager:OnFinish()

  self.isEquiping       = false
  self.cosmeticFinished = false
  self.quickslotFinished = false

  self.hasStartedEquip  = false

  self.collectionQueue:Clear()

  CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_EQUIP_FINISH)
end

--[[
  Handles the equiping of items

  {
    itemID        = number
  }

]]--
function CCEquipManager:QueueCollectibleEquip(data)
  self.collectionQueue:Add(
    function ()
      local currentColData = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(data.itemID)
      currentColData:Use()
    end
  )
end

function CCEquipManager:QueueQuickSlotEquip(data)
  self.quickslotQueue:Add(
    function ()

      --[[
        data = {
          hotbarId,
          itemType
          itemId,
          slotid
        }
      ]]--

      if data.itemType == CC_DRAG_TYPE_EMOTE then
        CallSecureProtected("SelectSlotSimpleAction", ACTION_TYPE_EMOTE, data.itemId, data.slotId, data.hotbar)
      else
        CallSecureProtected("SelectSlotSimpleAction", ACTION_TYPE_COLLECTIBLE, data.itemId, data.slotId, data.hotbar)
      end
    end
  )
end

function CCEquipManager:EquipTitle(data)
  SelectTitle(data)
end

function CCEquipManager:EquipOutfit(data)
  if data == nil then
    UnequipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER)
  else
    EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, data)
  end
end

--[[
  Called everytime the cosmetics should be updated

  Checks if there are remaining things to be sloted
  and if not, ends the loop.
]]--
function CCEquipManager:CollectibleEquipLoop()

  if self.cosmeticFinished then return end

  --
  local remain, duration, _, _ = GetSlotCooldownInfo(ACTION_TYPE_ITEM)

  -- See if our input has started
  if not self.hasStartedEquip and remain > 0 then
    self.hasStartedEquip = true
  end

  -- Check if cooldown has finished
  if self.hasStartedEquip and remain <= 0 then
    self.hasStartedEquip = false

    -- Time to equip
    if self.collectionQueue:IsEmpty() then
      self.cosmeticFinished = true
      return
    end

    local func = self.collectionQueue:Pop()
    func()
  end
end

function CCEquipManager:QuickslotEquipLoop()

  if self.quickslotFinished then return end

  if self.quickslotQueue:IsEmpty() then
    self.quickslotFinished = true
    return
  end

  local func = self.quickslotQueue:Pop()
  func()
end

--[[
  Called to check if the equiping has finished
]]--
function CCEquipManager:OnFinishedUpdate()

  -- Equiped has finished
  if self.cosmeticFinished == true and self.quickslotFinished == true then
    EVENT_MANAGER:UnregisterForUpdate(CC_EQUIP_NAMES.FINISHED)
    EVENT_MANAGER:UnregisterForUpdate(CC_EQUIP_NAMES.COLLECTIBLE_UPDATE)
    EVENT_MANAGER:UnregisterForUpdate(CC_EQUIP_NAMES.QUICKSLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(CC_EQUIP_NAMES.BLOCKED, EVENT_COLLECTIBLE_USE_RESULT)

    self:OnFinish()
  end
end

--[[
  Check for a blocked equip
]]
function CCEquipManager:OnEquipBlocked(eventCode, result, isAttemptingActivation)
  local formattedBlockReason = ZO_CachedStrFormat(ZO_CACHED_STR_FORMAT_NO_FORMATTER, GetString("SI_COLLECTIBLEUSAGEBLOCKREASON", result))

  -- Check for a donk
  if formattedBlockReason ~= '' then
    self.hasStartedEquip = true
  end
end

--[[
  Handles the equiping of all outfit data
]]--
function CCEquipManager:Start()

  if self:IsEquiping() then
    return
  end

  CC_CALLBACK_MANAGER:FireCallbacks(CC_ON_EQUIP_START)

  self.isEquiping = true
  self.hasStartedEquip = true

  -- Listen for bonks
  EVENT_MANAGER:RegisterForEvent(CC_EQUIP_NAMES.BLOCKED, EVENT_COLLECTIBLE_USE_RESULT, function(...) self:OnEquipBlocked (...) end)

  -- Start listening for the finish
  EVENT_MANAGER:RegisterForUpdate(CC_EQUIP_NAMES.FINISHED, 100, function() self:OnFinishedUpdate() end)

  -- Start equip loops
  EVENT_MANAGER:RegisterForUpdate(CC_EQUIP_NAMES.COLLECTIBLE_UPDATE, 20, function() self:CollectibleEquipLoop() end)
  EVENT_MANAGER:RegisterForUpdate(CC_EQUIP_NAMES.QUICKSLOT_UPDATE, 100,  function() self:QuickslotEquipLoop() end)
end

CC_EQUIP_MANAGER = CCEquipManager:New()
