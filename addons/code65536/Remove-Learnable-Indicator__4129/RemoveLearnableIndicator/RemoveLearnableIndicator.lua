local function HookHandler( data )
	if (type(data) == "table") then
		data.canBeUsedToLearn = false
	--	data.isLockedSetPiece = false
	end
	return false
end

-- /esoui/ingame/inventory/sharedinventory.lua
ZO_PreHook(MasterMerchant and ZO_SharedInventoryManager or SHARED_INVENTORY, "RefreshStatusSortOrder", function(_, slotData) return HookHandler(slotData) end)

-- /esoui/ingame/zo_loot/loot.lua
ZO_PreHook(LOOT_WINDOW, "SetUpLootItem", function(_, _, data) return HookHandler(data) end)
