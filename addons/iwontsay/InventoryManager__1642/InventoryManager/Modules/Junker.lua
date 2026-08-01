local DEBUG =
-- function() end
d

if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

function IM:CheckAndDestroy(dryrun)
	if GetNumBagFreeSlots(BAG_BACKPACK) >= IM.settings.destroyThreshold then
		return
	end

	IM.currentRuleset:ResetCounters()
  IM:ProcessBag(BAG_BACKPACK, IM.ACTION_DESTROY,
    function(data) return data.junk and not IM.FCOISL:IsProtectedAction(data.action, data.bagId, data.slotId) end,
    function(data) IM:ProcessSingleItem(dryrun, data) end,
    function() end,
    IM.settings.statusChangeDelay)
end

function IM:ReportOpsState(currently)
	local currentlystr
	if(currently) then
		currentlystr = GetString(IM_LOG_ASSTATE_CURRENTLY)
	end
	if(IM.opssuspended) then
		CHAT_SYSTEM:AddMessage(zo_strformat(GetString(IM_LOG_SUSP_OFF), currentlystr))
	else
		CHAT_SYSTEM:AddMessage(zo_strformat(GetString(IM_LOG_SUSP_ON), currentlystr))
	end
end

function IM:WorkBackpack(dryrun)
  if IM.opssuspended then
	IM:ReportOpsState(true)
	return
  end

  local action = IM.ACTION_JUNK
  if dryrun then action = nil end
  
	IM.currentRuleset:ResetCounters()
	IM:ProcessBag(BAG_BACKPACK, action,
		function(data) return dryrun or not data.junk end,
		function(data) IM:ProcessSingleItem(dryrun, data) end,
		function() IM:CheckAndDestroy(dryrun) end,
		IM.settings.statusChangeDelay)
end

function IM:UnJunk()
	for i = 1, GetBagSize(BAG_BACKPACK), 1 do
		SetItemIsJunk(BAG_BACKPACK, i, false)
	end
end

function IM:OnInvSlotUpdate(bagId, slotId)
	IM:SetCurrentInventory(bagId)
	local data = IM:GetItemData(slotId)
	
	if not data then return end

	if not self.currentRuleset or not self.currentRuleset.Match then return end
	
	data.action, data.index, data.text = self.currentRuleset:Match(data, IM.ACTION_JUNK)
  IM:ProcessSingleItem(false, data)

	IM:CheckAndDestroy()
end

local function OnInvSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange) 
	if not isNewItem or bagId ~= BAG_BACKPACK then return end

	IM:OnInvSlotUpdate(bagId, slotId)
end

EVENT_MANAGER:RegisterForEvent(IM.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInvSlotUpdate)
