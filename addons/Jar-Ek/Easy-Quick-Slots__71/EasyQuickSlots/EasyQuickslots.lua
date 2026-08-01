--
-- Easy Quick Slots
--


EQS = {}

local function Initialize( self, addOnName )

  if addOnName ~= "EasyQuickSlots" then return end

  -- Register keybindings
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_1", "Set Quickslot 1")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_2", "Set Quickslot 2")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_3", "Set Quickslot 3")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_4", "Set Quickslot 4")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_5", "Set Quickslot 5")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_6", "Set Quickslot 6")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_7", "Set Quickslot 7")
  ZO_CreateStringId("SI_BINDING_NAME_SET_QSLOT_8", "Set Quickslot 8")
  ZO_CreateStringId("SI_BINDING_NAME_CYCLE_QSLOT_UP", "Cycle Quickslot Up")
  ZO_CreateStringId("SI_BINDING_NAME_CYCLE_QSLOT_DOWN", "Cycle Quickslot Down")

  -- Display successful startup
  d( "Easy Quick Slots Enabled!" )

end

-- Called from bindings.xml, sets the current Quickslot based on button pressed
function EQS.SetQSlot( id )
	SetCurrentQuickslot(8+id)
end

-- Called from bindings.xml, cycle through the current Quickslot
function EQS.CycleQSlot( up )
	local slotValue = GetCurrentQuickslot()
	if(up == 0) then slotValue = slotValue + 1
	else slotValue = slotValue - 1 end
	if(slotValue < 9) then slotValue = 16
	elseif(slotValue > 16) then slotValue = 9 end
	SetCurrentQuickslot(slotValue)
end

-- Show what is in the quickslot
function EQS.ShowQuickSlot()
	local QSlotValue = GetCurrentQuickSlot()
	-- Need to see API to determine what we can get from the QuickSlot wrt item info
end

function EQS.Update()

  if EQS.active then
	EQS.ShowQuickSlot()
	  -- I don't think anything actually needs to happen here!!
	  -- TODO
	  -- Maybe show current QS somewhere?
	  -- Or Show the list of QSs with a highlight?
  end

end

-- Just cause a chain by itself is boring.
function EQS.BallAndChain( object )
	
	local T = {}
	setmetatable( T , { __index = function( self , func )
		
		if func == "__BALL" then	return object end
		
		return function( self , ... )
			assert( object[func] , func .. " missing in object" )
			object[func]( object , ... )
			return self
		end
	end })
	
	return T
end


-- Init Hook --
EVENT_MANAGER:RegisterForEvent("EasyQuickSlots", EVENT_ADD_ON_LOADED, Initialize )
