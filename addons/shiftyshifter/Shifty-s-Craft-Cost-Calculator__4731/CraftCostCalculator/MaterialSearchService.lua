--[[
	MaterialSearchService
	Facade between MaterialIndex / MaterialRepository and UI / ShoppingList.

	Lazy-builds the search index on first use and never rebuilds it.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.MaterialSearchService = CCC.MaterialSearchService or {}
local S = CCC.MaterialSearchService

function S:Init(addon)
	S.addon = addon
end

function S:EnsureIndex()
	S.addon.MaterialIndex:EnsureBuilt()
end

function S:IsReady()
	return S.addon.MaterialIndex:IsBuilt()
end

--- @param query string|nil
--- @param opts table|nil forwarded to MaterialIndex:Search
--- @return table results
function S:Search(query, opts)
	S:EnsureIndex()
	return S.addon.MaterialIndex:Search(query, opts)
end

function S:GetEntry(itemId)
	S:EnsureIndex()
	return S.addon.MaterialIndex:GetEntry(itemId)
end

--- Add a catalog material to the shopping list (merges duplicates).
-- @param itemId number
-- @param quantity number
-- @return boolean ok, string|nil errorMessage, number addedKinds, number mergedKinds, number qtyAdded
function S:AddToShoppingList(itemId, quantity)
	if not itemId then
		return false, "No material selected.", 0, 0, 0
	end

	quantity = tonumber(quantity)
	if not quantity or quantity ~= zo_floor(quantity) or quantity < 1 then
		return false, GetString(CCC_MATERIAL_SEARCH_QTY_INVALID), 0, 0, 0
	end

	S:EnsureIndex()
	local entry = S.addon.MaterialRepository:GetByItemId(itemId)
	if not entry then
		return false, GetString(CCC_MATERIAL_SEARCH_NOT_FOUND), 0, 0, 0
	end

	local added, merged, qty = S.addon.ShoppingList:AddItem(entry.itemId, quantity, {
		itemLink = entry.itemLink,
		name = entry.name,
		icon = entry.icon,
	})

	return true, nil, added, merged, qty
end
