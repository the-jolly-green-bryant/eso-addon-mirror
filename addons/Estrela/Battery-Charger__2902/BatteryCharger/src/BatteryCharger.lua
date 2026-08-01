BatteryCharger = {}

BatteryCharger.AddonName = "BatteryCharger"
--If the charge left on the weapon is less than the value below, we will charge the weapon
BatteryCharger.ChargeTheshold = 3
BatteryCharger.HasAnySoulGemsInBags = true

-- We do this check to reduce the amount of times that FindSoulGems in called.
-- An attacktype of 5 or 6 means that we are light or heavy attacking
local function IsWeaponAttack(AttackType)
    if (AttackType == 5 or AttackType == 6) then
        return true
    else
        return false
    end
end

-- Gets the first soul gem found in the player's inventory
local function FindSoulGems()
    local PlayerInventory = SHARED_INVENTORY:GenerateFullSlotData(nil,BAG_BACKPACK)

    for _, item in pairs(PlayerInventory) do
        if (IsItemSoulGem(SOUL_GEM_TYPE_FILLED,BAG_BACKPACK,item.slotIndex)) then
            BatteryCharger.HasAnySoulGemsInBags = true
            return item.slotIndex
        end
    end
    -- We use a bool here so we don't spam the chat with our message.
    -- We get here only if no filled soul gems were found in the players bag
    if(BatteryCharger.HasAnySoulGemsInBags == true) then
        d("Battery Charger: No filled soul gems found in your bags, unable to charge equiped weapon.")
        BatteryCharger.HasAnySoulGemsInBags = false
        return nil
    end
end

local function ChargeWeapon(EquipmentSlot)
    local SoulGemSlot

    if (IsItemChargeable(BAG_WORN, EquipmentSlot)) then
        SoulGemSlot = FindSoulGems()
        if (not (SoulGemSlot == nil)) then
            --Check the weapon's charge value to make sure it super low or depleted
            if (GetChargeInfoForItem(BAG_WORN, EquipmentSlot) < BatteryCharger.ChargeTheshold) then
                ChargeItemWithSoulGem(BAG_WORN, EquipmentSlot, BAG_BACKPACK, SoulGemSlot)
            end
        end
    end
end

local function Main(_, _, _,  _, _, AttackType)
    local ActiveWeapon, _
    
    if (IsWeaponAttack(AttackType)) then
        ActiveWeapon, _ = GetActiveWeaponPairInfo()

        if (ActiveWeapon == 1)then
            ChargeWeapon(EQUIP_SLOT_MAIN_HAND)
        end
        if (ActiveWeapon == 2) then
            ChargeWeapon(EQUIP_SLOT_BACKUP_MAIN)
        end
    end
end

-- We use the combat event because it triggers numberous times a second which allows us to
-- check the weapon charge frequenly without destroying peoples computers.
-- It does mean that we need the IsWeaponAttack function.  We don't want to check the player
-- bags 20+ times a second.
EVENT_MANAGER:RegisterForEvent(BatteryCharger.name, EVENT_COMBAT_EVENT, Main)