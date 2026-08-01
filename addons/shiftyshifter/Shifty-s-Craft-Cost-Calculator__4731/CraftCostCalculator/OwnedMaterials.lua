--[[
	OwnedMaterials
	Counts owned crafting materials from backpack, bank, and craft bag.

	Designed for sparse lookups: scans bags only for the itemIds currently
	needed by a calculation. Inventory events invalidate a tiny cache and
	refresh the open results window — no polling / continuous full scans.

	Craft bag note:
	  BAG_VIRTUAL does NOT use sequential slot indices. The slotIndex IS the
	  itemId. Counting must use GetSlotStackSize(BAG_VIRTUAL, itemId) (or
	  ZO_IterateBagSlots), never "for slot = 0, GetBagSize(...)".
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.OwnedMaterials = CCC.OwnedMaterials or {}
local O = CCC.OwnedMaterials

local REFRESH_EVENT = CCC.Name .. "OwnedRefresh"
local DEBOUNCE_MS = 150

function O:Init(addon)
	O.addon = addon
	O.cache = {} -- [itemId] = count
	O.cacheValid = false
	O.watchedIds = nil -- set of itemIds from last calculation
	O:RegisterEvents()
end

function O:IsEnabled()
	local settings = O.addon and O.addon.Settings
	return not settings or settings.useOwnedMaterials ~= false
end

function O:HasCraftBagAccess()
	if HasCraftBag then
		return HasCraftBag()
	end
	if IsESOPlusSubscriber then
		return IsESOPlusSubscriber()
	end
	-- Fall back: direct craft-bag lookups are cheap and return 0 if unavailable
	return true
end

--- Bags included in ownership counts.
function O:GetTrackedBags()
	local bags = {
		BAG_BACKPACK,
		BAG_BANK,
		BAG_SUBSCRIBER_BANK,
	}

	if O:HasCraftBagAccess() then
		bags[#bags + 1] = BAG_VIRTUAL
	end

	return bags
end

function O:InvalidateCache()
	O.cacheValid = false
	ZO_ClearTable(O.cache)
end

--- Add counts from a normal sized bag (backpack / bank).
function O:AddSizedBagCounts(bagId, wanted, counts)
	if ZO_IterateBagSlots then
		for slotIndex in ZO_IterateBagSlots(bagId) do
			local itemId = GetItemId(bagId, slotIndex)
			if itemId and wanted[itemId] then
				counts[itemId] = counts[itemId] + (GetSlotStackSize(bagId, slotIndex) or 0)
			end
		end
		return
	end

	local size = GetBagSize(bagId) or 0
	for slotIndex = 0, size do
		local itemId = GetItemId(bagId, slotIndex)
		if itemId and wanted[itemId] then
			counts[itemId] = counts[itemId] + (GetSlotStackSize(bagId, slotIndex) or 0)
		end
	end
end

--- Craft bag: slotIndex == itemId. Direct O(#wanted) lookups.
function O:AddCraftBagCounts(wanted, counts)
	for itemId in pairs(wanted) do
		-- GetSlotStackSize(BAG_VIRTUAL, itemId) is the supported craft-bag API
		local stack = GetSlotStackSize(BAG_VIRTUAL, itemId)
		if stack and stack > 0 then
			counts[itemId] = counts[itemId] + stack
		end
	end
end

--- Single-pass scan for a set of itemIds. Returns { [itemId] = count }.
function O:CountItems(itemIds)
	local counts = {}
	local wanted = {}

	if type(itemIds) == "table" then
		-- Accept either a list {id, id, ...} or a set {[id]=true}
		local isList = itemIds[1] ~= nil
		if isList then
			for i = 1, #itemIds do
				local id = itemIds[i]
				if id then
					wanted[id] = true
					counts[id] = 0
				end
			end
		else
			for id in pairs(itemIds) do
				if type(id) == "number" then
					wanted[id] = true
					counts[id] = 0
				end
			end
		end
	end

	if not next(wanted) then
		return counts
	end

	local bags = O:GetTrackedBags()
	for b = 1, #bags do
		local bagId = bags[b]
		if bagId == BAG_VIRTUAL then
			O:AddCraftBagCounts(wanted, counts)
		else
			O:AddSizedBagCounts(bagId, wanted, counts)
		end
	end

	return counts
end

--- Cached count for one itemId (rebuilds cache for watched set when stale).
function O:GetOwnedCount(itemId)
	if not itemId then
		return 0
	end
	if not O:IsEnabled() then
		return 0
	end

	if O.cacheValid and O.cache[itemId] ~= nil then
		return O.cache[itemId]
	end

	local ids = O.watchedIds
	if ids and next(ids) then
		local counted = O:CountItems(ids)
		for id, count in pairs(counted) do
			O.cache[id] = count
		end
		O.cacheValid = true
		return O.cache[itemId] or 0
	end

	local counted = O:CountItems({itemId})
	O.cache[itemId] = counted[itemId] or 0
	return O.cache[itemId]
end

--- Prepare cache for a batch of materials (one bag pass).
-- @param materials table array of { itemId = number, ... }
-- @return table { [itemId] = ownedCount }
function O:GetOwnedForMaterials(materials)
	local ids = {}
	local list = {}
	for i = 1, #materials do
		local id = materials[i].itemId
		if id and not ids[id] then
			ids[id] = true
			list[#list + 1] = id
		end
	end

	O.watchedIds = ids

	if not O:IsEnabled() then
		local zeros = {}
		for i = 1, #list do
			zeros[list[i]] = 0
		end
		return zeros
	end

	local counted = O:CountItems(list)
	ZO_ClearTable(O.cache)
	for id, count in pairs(counted) do
		O.cache[id] = count
	end
	O.cacheValid = true
	return counted
end

function O:ScheduleRefresh()
	EVENT_MANAGER:UnregisterForUpdate(REFRESH_EVENT)
	EVENT_MANAGER:RegisterForUpdate(REFRESH_EVENT, DEBOUNCE_MS, function()
		EVENT_MANAGER:UnregisterForUpdate(REFRESH_EVENT)
		O:InvalidateCache()
		if O.addon and O.addon.RefreshDisplayedResult then
			O.addon:RefreshDisplayedResult()
		end
	end)
end

function O:RegisterEvents()
	local name = CCC.Name .. "Owned"

	EVENT_MANAGER:RegisterForEvent(name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
		O:ScheduleRefresh()
	end)

	EVENT_MANAGER:RegisterForEvent(name, EVENT_CRAFT_COMPLETED, function()
		O:ScheduleRefresh()
	end)

	EVENT_MANAGER:RegisterForEvent(name, EVENT_CLOSE_BANK, function()
		O:ScheduleRefresh()
	end)
end
