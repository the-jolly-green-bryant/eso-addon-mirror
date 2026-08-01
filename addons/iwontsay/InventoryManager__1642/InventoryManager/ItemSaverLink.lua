local DEBUG =
function() end
-- d
 
local function _tr(str)
    return str
end
 
if not InventoryManager then InventoryManager = {} end
local IM = InventoryManager

local TXT_NO_CARE
local TXT_NO_MARK
local TXT_ANY_MARK
 
local I_NO_CARE = -3
local I_NO_MARK = -2
local I_ANY_MARK = -1
 
local ISL = { }

IM.ISL = ISL;

function ISL:hasAddon()
	return ItemSaver_IsItemSaved ~= nil
end

function ISL:FitMark(instanceId, mark, bagId, slotIndex)
    -- If we have switched off this addon, render this filter setting as irrelevant
    if not ISL:hasAddon() then return true end
	
	if not mark then return true end
 
	DEBUG(ItemSaver_IsItemSaved(bagId, slotIndex))
    if mark == I_NO_MARK then return not ItemSaver_IsItemSaved(bagId, slotIndex)
    elseif mark == I_ANY_MARK then return ItemSaver_IsItemSaved(bagId, slotIndex)
    end

	-- Could happen if we did use FCOIS once and the rule has an old specific marking. That would not match anymore
	return true
end
