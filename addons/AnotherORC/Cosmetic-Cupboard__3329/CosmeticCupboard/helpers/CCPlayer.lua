local CC_Player = ZO_Object:Subclass()

function CC_Player:New(...)
  local ccPlayer = ZO_Object.New(self)
  ccPlayer:Initialize(...)
  return ccPlayer
end

function CC_Player:Initialize()
end

function CC_Player:NewEquipCollectibles(data)

  -- Is there any data
  if not data then return end

  for i = 1, #EQUIPED_ICONS do

    local dataCollectible = data[EQUIPED_ICONS[i][1]]

    local collectilbeSlotType = COLLECTIBLE_CATAGORIES_APPEARANCE[i-1][1]
    local equipedCollectible = GetActiveCollectibleByType(collectilbeSlotType)

    -- There is something to equip
    if dataCollectible ~= nil then
      -- Make sure the thing in the slot is not already what we want
      if dataCollectible ~= equipedCollectible then

        CC_EQUIP_MANAGER:QueueCollectibleEquip({ itemID = dataCollectible })
      end
    else
      -- Something is being worn.  Get rid of it.
      -- We wan't remove mounts...
      if equipedCollectible ~= 0 and collectilbeSlotType ~= COLLECTIBLE_CATEGORY_TYPE_MOUNT then
        CC_EQUIP_MANAGER:QueueCollectibleEquip({ itemID = equipedCollectible })
      end
    end
  end

end

function CC_Player:NewEquipQuickSlots(data)

  if not data then return end

  -- loop through all hotbar types
  for i = 1, #HOTBAR_CATEGORIES do

    local barId = HOTBAR_CATEGORIES[i][2]

    local hotbarData = data[barId]

    for j = 1, 8 do

      local itemData = hotbarData[j]

      if itemData then
        local itemType = itemData[1]
        local itemId = itemData[2]
        local hotbarType = HOTBAR_CATEGORIES[i][1]

        local currentSlotBoundId = GetSlotBoundId(j, hotbarType)

        -- Check for something in the slot
        if currentSlotBoundId == 0 then
          -- There is nothing, slot this
          CC_EQUIP_MANAGER:QueueQuickSlotEquip({ hotbar = hotbarType, itemType = itemType, itemId = itemId, slotId = j })
        else
          -- There is something

          -- Make sure they are different
          if currentSlotBoundId ~= itemId then
            CC_EQUIP_MANAGER:QueueQuickSlotEquip({ hotbar = hotbarType, itemType = itemType, itemId = itemId, slotId = j })
          end
        end
      end
    end
  end
end

-- Create reference to the player
CC_PLAYER_MANAGER = CC_Player:New()
