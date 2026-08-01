-- RdK Group Tool Iventory
-- By @s0rdrak (PC / EU)

RdKGTool = RdKGTool or {}
RdKGTool.util = RdKGTool.util or {}

local RdKGToolUtil = RdKGTool.util
RdKGToolUtil.inventory = RdKGToolUtil.inventory or {}
local RdkGToolInventory = RdKGToolUtil.inventory

--functions
function RdkGToolInventory.GetSoulGemsInventoryInformation()
	local retVal = {}
	local identifiedItem = 1
	for invId = 0, GetBagSize(BAG_BACKPACK) do
		if IsItemSoulGem(SOUL_GEM_TYPE_FILLED,BAG_BACKPACK,invId) == true then
			retVal[identifiedItem] = {}
			retVal[identifiedItem].slot = invId
			retVal[identifiedItem].stack = GetSlotStackSize(BAG_BACKPACK, invId)
			identifiedItem = identifiedItem + 1
		end
	end
	return retVal
end