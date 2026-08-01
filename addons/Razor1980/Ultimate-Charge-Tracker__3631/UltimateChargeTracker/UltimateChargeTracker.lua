-------------------------------------------------------------------------------
--
-- Copyright (c) 2021, 2022 Bogdan C
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--
-------------------------------------------------------------------------------
--
-- DISCLAIMER:
--
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax
-- Media Inc. or its affiliates. The Elder Scrolls® and related logos are
-- registered trademarks or trademarks of ZeniMax Media Inc. in the United
-- States and/or other countries. All rights reserved.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
-------------------------------------------------------------------------------

local ADDON_NAME = "UltimateChargeTracker"
local EM = GetEventManager()
local WM = GetWindowManager()
local SV, UI
local nowcharging = false
local chargetime = 0
local Timer = nil
local HadUltiCall = false
local PlayerInCombat = false


local function SetupUI(state)
   UI:SetMouseEnabled(state)
   UI:SetMovable(state)

   if not state then
      local valid, point, target, relPoint, x, y = UI:GetAnchor(0)

      if valid then
         SV.Anchor = { p = point, t = target:GetName(), r = relPoint, x = x, y = y }
      end 
   end
end

local function OnMouseUp(self, button, upInside)
   if upInside then
      if button == 2 then
         ClearMenu()
         AddMenuItem("Save & Hide", function() SetupUI(false) end)
         ShowMenu(self)
      end
   end
end

local function OnUnitDeath(evt, unitTag, isDead)
   if isDead==T and unitTag == "player" then
      if nowcharging==true then
         zo_removeCallLater(TIMERID)				  
	     nowcharging=false
         chargetime=0
         UI.label:SetText("Not Charging!")
         UI.label:SetColor(1,0,0,1)    
	  end
   end
end

local function EndCharge()
   if (HadUltiCall == false) then
      nowcharging=false
      chargetime=0
      UI.label:SetText("Not Charging!")
      UI.label:SetColor(1,0,0,1)      
   else
      HadUltiCall=false
   end
end   


local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)   
   if PlayerInCombat == false then
      return
   end
   ulti=GetUnitPower("player", POWERTYPE_ULTIMATE)
   if (ulti==500) then      
      if (nowcharging==true) then
	     zo_removeCallLater(TIMERID)				  
	     nowcharging=false
         chargetime=0                  
         UI.label:SetText("Not Charging!")
         UI.label:SetColor(1,0,0,1)     
	  end
	  return
   end    
   if nowcharging == true then --reset charge time on attack during charge
      if ((sourceType==0) and (abilityActionSlotType == 0) and (targetType==1)) then --when blocking
	     zo_removeCallLater(TIMERID)			   			   
	     chargetime=GetTimeStamp()			  
		 TIMERID=zo_callLater(EndCharge, 9000)
	  end
      if sourceType == COMBAT_UNIT_TYPE_PLAYER then	  
         if ((targetType ~= COMBAT_UNIT_TYPE_PLAYER) and (targetType ~= COMBAT_UNIT_TYPE_PLAYER_PET)) then
	        if ((abilityActionSlotType == ACTION_SLOT_TYPE_BLOCK) or (abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK) or (abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK) or (abilityActionSlotType == ACTION_SLOT_TYPE_WEAPON_ATTACK)) then		
     	       zo_removeCallLater(TIMERID)			   			   
			   chargetime=GetTimeStamp()			  
			   TIMERID=zo_callLater(EndCharge, 9000)
            end 
         end
      end		 
   else -- that is, nowcharging == false 
	  if ((sourceType==0) and (abilityActionSlotType == 0) and (targetType==1)) then --when blocking	  
		 nowcharging=true
    	 chargetime=GetTimeStamp()			  
 		 TIMERID=zo_callLater(EndCharge, 9000)			   
         UI.label:SetText("Charging...")
         UI.label:SetColor(0,1,0,1)
		return
	 end
      if sourceType == COMBAT_UNIT_TYPE_PLAYER then	     
         if ((targetType ~= COMBAT_UNIT_TYPE_PLAYER) and (targetType ~= COMBAT_UNIT_TYPE_PLAYER_PET)) then
	        if ((abilityActionSlotType == ACTION_SLOT_TYPE_BLOCK) or (abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK) or (abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK) or (abilityActionSlotType == ACTION_SLOT_TYPE_WEAPON_ATTACK)) then
	           nowcharging=true
    	       chargetime=GetTimeStamp()			  
			   TIMERID=zo_callLater(EndCharge, 9000)			   
			   UI.label:SetText("Charging...")
               UI.label:SetColor(0,1,0,1)			
			end
			if (abilityActionSlotType == ACTION_SLOT_ULTIMATE) then
			   zo_removeCallLater(TIMERID)				  
			   nowcharging=false
               chargetime=0                  
               UI.label:SetText("Not Charging!")
               UI.label:SetColor(1,0,0,1)     
			   HadUltiCall=true
			end
		 end
	  end
   end
end  

local function OnCombatState(eventCode, inCombat)
   PlayerInCombat=inCombat
end


local function OnLoaded(evt, name)
   if name == ADDON_NAME then      
      EM:UnregisterForEvent(name, evt)	  

      SV = ZO_SavedVars:New("ULTIMATE_CHARGE_TRACKER_SV", 1, { Anchor = { p = BOTTOM, t = "GuiRoot", r = BOTTOMRIGHT, x = 300, y = -100 }, firstTime = true })

      UI = WM:CreateControlFromVirtual(nil, GuiRoot, "UltimateChargeTracker_Template")
	  
	  UI:SetHidden(false)
	  
	  EndCharge()

      UI:SetHandler("OnMouseUp", OnMouseUp)

      if SV.firstTime then
         SV.firstTime = false
         d("=== Ultimate Charge Tracker ===")
         d("Adjust Ultimate Charge Tracker position and then right-click to hide window and save its position.")
         d("Type /ut to unlock Ultimate Charge Tracker window again.")
         SetupUI(true)
      end

      UI:SetAnchor(SV.Anchor.p, _G[SV.Anchor.t], SV.Anchor.r, SV.Anchor.x, SV.Anchor.y)
     
      UI:RegisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeath)
	  UI:RegisterForEvent(EVENT_COMBAT_EVENT, OnCombatEvent)
	  UI:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, OnCombatState)

      SLASH_COMMANDS["/ut"] = function() SetupUI(true) end
   end
end

EM:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)