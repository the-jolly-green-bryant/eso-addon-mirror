local name = "LilithHacks"
local repairQueue = {}
Hacks = {}

do


   local function BuildListOfItems(bagId, Predicate)
      local list = {}
      for k,v in pairs(SHARED_INVENTORY:GetOrCreateBagCache(INVENTORY_BACKPACK)) do

	 if Predicate(bagId, v.slotIndex) then
	    table.insert(list, v.slotIndex)
	 end
      end

      return list
   end

   local function IsFilledSoulGem(bagId, slotIndex) return IsItemSoulGem(SOUL_GEM_TYPE_FILLED, bagId, slotIndex) end
   
   local currentGem 
   function Hacks.RechargeWeaponCheck(_, bagId, slotId, _, _, _, _)
      --d((GetChargeInfoForItem(bagId,slotId)))
      if GetChargeInfoForItem(bagId,slotId) < 3 then
	 if not currentGem or not IsFilledSoulGem(INVENTORY_BACKPACK, currentGem) then
	    --local gemSetting = GetSetting(SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_DEFAULT_SOUL_GEM)
	    
	    currentGem = nil
	    for _, index in ipairs(BuildListOfItems(INVENTORY_BACKPACK, IsFilledSoulGem)) do
	       if GetAmountSoulGemWouldChargeItem(bagId, slotId, INVENTORY_BACKPACK, index) > 0 then	
		  currentGem = index
		  break
	       end
	    end
	 end

	 if currentGem then
	    if Hacks.SV.playSounds then
	       PlaySound(SOUNDS.INVENTORY_ITEM_APPLY_CHARGE)
	    end
	    ChargeItemWithSoulGem(bagId, slotId, INVENTORY_BACKPACK, currentGem)
	    d("|C12DA32LLH Weapon charge|r ".. GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS))
	 else
 	    d("|CDA2343LLH No Soul Gems:|r ".. GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS))
	 end
      end
   end

   
   local currentRepairKit
   function Hacks.RepairGearCheck(_, bagId, slotId)
      local condition = GetItemCondition(bagId, slotId)      
      if condition < 3 then
	 
	 if not currentRepairKit or not IsItemNonCrownRepairKit(INVENTORY_BACKPACK, currentRepairKit) then
	    currentRepairKit = nil
	    for _, index in ipairs(BuildListOfItems(INVENTORY_BACKPACK, IsItemNonCrownRepairKit) or {}) do
	       if GetAmountRepairKitWouldRepairItem(bagId, slotId, INVENTORY_BACKPACK, index) > 0 then
		  currentRepairKit = index
		  break
	       end
	    end
	 end
	 if currentRepairKit then
	    if IsUnitDead('player') then
	       --Can't repair while dead, so queue up repairs to happen once alive again.
	       if not repairQueue[slotId] then
		  repairQueue[slotId] = bagId
	       end
	       --table.insert(repairQueue, {bagId, slotId})
	    else
	       if Hacks.SV.playSounds then
		  PlaySound(SOUNDS.INVENTORY_ITEM_REPAIR)
	       end
	       RepairItemWithRepairKit(bagId, slotId, INVENTORY_BACKPACK, currentRepairKit)
	       repairQueue[slotId] = nil
	       d("|C12DA32LLH Gear Repair:|r ".. GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS))
	    end
	 else
	    d("|CDA2343LLH No Repair Kits:|r ".. GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS))
	 end
      end
   end
   
end

local function DeathStateChanged(_, unitTag, isDead)
   if not isDead and unitTag == 'player' and next(repairQueue, nil) then
      zo_callLater(
      	 function()	    
	    for slotId,bagId in pairs(repairQueue) do
	       Hacks.RepairGearCheck(nil, bagId, slotId)
	    end
	 end, 1000
      )
   end
end


local function ToggleAutoCharge(enable)
   if enable then
      EVENT_MANAGER:RegisterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Hacks.RechargeWeaponCheck)
      EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
      EVENT_MANAGER:AddFilterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_ITEM_CHARGE)      
   else
      EVENT_MANAGER:UnregisterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
   end
   
   Hacks.SV.chargeEnabled = enable

end


local function ToggleAutoRepair(enable)
   if enable then
      EVENT_MANAGER:RegisterForEvent(name.."Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Hacks.RepairGearCheck)
      EVENT_MANAGER:AddFilterForEvent(name.."Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
      EVENT_MANAGER:AddFilterForEvent(name.."Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DURABILITY_CHANGE)
      

      EVENT_MANAGER:RegisterForEvent(name, EVENT_UNIT_DEATH_STATE_CHANGED, DeathStateChanged)
      EVENT_MANAGER:AddFilterForEvent(name, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, 'player')
      EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, function() DeathStateChanged(nil, 'player', IsUnitDead('player')) end)
   else
      EVENT_MANAGER:UnregisterForEvent(name.."Repair", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
      EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)
      EVENT_MANAGER:UnregisterForEvent(name, EVENT_UNIT_DEATH_STATE_CHANGED)
      
   end
   
   Hacks.SV.repairEnabled = enable
end
local function OnCharacterLoad(eventCode, initialLoad)
   EVENT_MANAGER:UnregisterForEvent(name, EVENT_PLAYER_ACTIVATED)

   Hacks.SV = ZO_SavedVars:NewAccountWide(name.."_Data", 1, nil, {repairEnabled = true, playSounds = true, chargeEnabled = true, showBossBar = false}, nil)

   
   do
      local framefunc = COMPASS_FRAME.SetBossBarActive
      function COMPASS_FRAME:SetBossBarActive(active)
	 Hacks.active = active
	 framefunc(self, Hacks.SV.showBossBar and active)
      end
   end

   if not Hacks.SV.showBossBar then
      COMPASS_FRAME:SetBossBarActive(false)
   end
   
   ToggleAutoCharge(Hacks.SV.chargeEnabled)
   ToggleAutoRepair(Hacks.SV.repairEnabled)
   
   
   SLASH_COMMANDS["/lhacks"] = function (args)
      if args == "charge" or args == "c" then
	 d(name.. ": Toggling AutoCharge " .. (Hacks.SV.chargeEnabled and "Off" or "On")) 
	 ToggleAutoCharge(not Hacks.SV.chargeEnabled)
      elseif args == "sound" then
	 d(name..": Toggling repair/recharge sounds " ..(Hacks.SV.playSounds and "Off" or "On"))
	 Hacks.SV.playSounds = not Hacks.SV.playSounds
      elseif args == "repair" or args == "r" then
	 d(name.. ": Toggling AutoRepair " .. (Hacks.SV.repairEnabled and "Off" or "On")) 
	 ToggleAutoRepair(not Hacks.SV.repairEnabled)
      elseif args == "boss" or args == "b" then
	 d(name.. ": Toggling Boss Bar " .. (Hacks.SV.showBossBar and "Off" or "On"))
	 Hacks.SV.showBossBar = not Hacks.SV.showBossBar
	 COMPASS_FRAME:SetBossBarActive(Hacks.active)

      else
	 d(name.. " AutoCharge is: ".. (Hacks.SV.chargeEnabled and "On" or "Off"))
	 d(name.. " Boss Bar is: " .. (Hacks.SV.showBossBar and "On" or "Off"))
	 d(name.. " AutoRepair is: " .. (Hacks.SV.repairEnabled and "On" or "Off"))
	 d(name.. " PlaySound is: " .. (Hacks.SV.playSounds and "On" or "Off"))
	 d("LLH Options:",
	   "|u0:20::|uc, charge - Toggle Equipped Weapon AutoCharge",
	   "|u0:20::|ub, boss - Toggle Display of Compass Boss Bar",
	   "|u0:20::|ur, repair - Toggle Equipped Armor AutoRepair",
	   "|u0:20::|usound - Toggle automatic repair/recharge sounds")
      end
   end

   -- Hacks.cTips = ACTIVE_COMBAT_TIP_SYSTEM

   -- Hacks.cTips.control:ClearAnchors()
   -- Hacks.cTips.control:SetAnchor(ComHist.SV.anchorPoint, GuiRoot, nil, ComHist.SV.offX, ComHist.SV.offY)

end

EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_ACTIVATED, OnCharacterLoad)

