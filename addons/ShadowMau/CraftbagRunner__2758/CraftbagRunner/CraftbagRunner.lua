-- *** CraftbagRunner ***

-- *** Pre-Initialize ***
CraftbagRunner = {}
CraftbagRunner.name = "CraftbagRunner"

-- *** Functions ***

function CraftbagRunner.Tester()
	-- Passing a nil value as the parameter signals that we want to start at the beginning
	-- slot of the list so this initializes the sequence.
	CraftbagRunner.previousSlot = GetNextVirtualBagSlotId()
	-- While there are still more items in the craftbag, loop through them until we hit the end (nil)
	while CraftbagRunner.previousSlot
	do
		local slot = CraftbagRunner.previousSlot
		d("Current Slot: "..slot)
		local link = GetItemLink(BAG_VIRTUAL, slot)
		-- d( "Homemade Link: |H1:item:"..slot..":1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
		local nextslot = GetNextVirtualBagSlotId(CraftbagRunner.previousSlot)
		CraftbagRunner.savedVariables.items[slot] = link
		CraftbagRunner.savedVariables.linkName[slot] = GetItemLinkName(link)
		d("Saved Item Link: "..CraftbagRunner.savedVariables.items[slot])
		d("Saved Item Name: "..CraftbagRunner.savedVariables.linkName[slot])
		CraftbagRunner.previousSlot = nextslot
	end
end

-- *** Main ***

-- Check to see if this addon is the one loaded
function CraftbagRunner.OnAddOnLoaded(event, addonName)
	if addonName == CraftbagRunner.name then
		SLASH_COMMANDS["/cbr"] = CraftbagRunner.Tester
		
		-- No need to check any more
		EVENT_MANAGER:UnregisterForEvent(CraftbagRunner.name, EVENT_ADD_ON_LOADED)
		CraftbagRunner.savedVariables = ZO_SavedVars:NewAccountWide("CBR", 1)
		-- Table for the items and their links which is the result of GetItemLink(BAG_VIRTUAL, slot)
		CraftbagRunner.savedVariables.items = {}
		-- Table for the items and their descriptions which is the result of GetItemLinkName(link)
		CraftbagRunner.savedVariables.linkName={}
	end
end

EVENT_MANAGER:RegisterForEvent(CraftbagRunner.name, EVENT_ADD_ON_LOADED, CraftbagRunner.OnAddOnLoaded)