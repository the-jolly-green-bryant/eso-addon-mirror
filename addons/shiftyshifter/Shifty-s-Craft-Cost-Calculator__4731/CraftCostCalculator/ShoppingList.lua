--[[
	ShoppingList
	Persistent shopping list of missing crafting materials.

	Storage is account-wide and server-scoped via CraftCostCalculatorVars
	(profile = GetWorldName()), keyed by itemId string for SavedVariables
	safety. Quantities merge when the same material is added again.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.ShoppingList = CCC.ShoppingList or {}
local SL = CCC.ShoppingList

function SL:Init(addon)
	SL.addon = addon
	SL:EnsureStore()
end

function SL:EnsureStore()
	local settings = SL.addon.Settings
	if not settings.shoppingList then
		settings.shoppingList = {}
	end
	return settings.shoppingList
end

function SL:GetStore()
	return SL:EnsureStore()
end

local function keyFor(itemId)
	return tostring(itemId)
end

--- Add missing materials from a calculation result.
-- Merges quantities for materials already on the list.
-- @param result table from CalculationEngine
-- @return number addedKinds, number mergedKinds, number totalQtyAdded
function SL:AddFromResult(result)
	if not result or not result.lines then
		return 0, 0, 0
	end

	local store = SL:GetStore()
	local addedKinds, mergedKinds, totalQty = 0, 0, 0

	for i = 1, #result.lines do
		local line = result.lines[i]
		local qty = line.shortfall or 0
		if qty > 0 and line.itemId then
			local a, m, q = SL:AddItem(line.itemId, qty, {
				itemLink = line.itemLink,
				name = line.name,
				icon = line.icon,
			})
			addedKinds = addedKinds + a
			mergedKinds = mergedKinds + m
			totalQty = totalQty + q
		end
	end

	return addedKinds, mergedKinds, totalQty
end

--- Add or merge a single item onto the shopping list.
-- @return number addedKinds (0|1), number mergedKinds (0|1), number qtyAdded
function SL:AddItem(itemId, quantity, fields)
	if not itemId or not quantity or quantity <= 0 then
		return 0, 0, 0
	end

	fields = fields or {}
	local store = SL:GetStore()
	local key = keyFor(itemId)
	local existing = store[key]
	if existing then
		existing.quantity = (existing.quantity or 0) + quantity
		existing.itemLink = fields.itemLink or existing.itemLink
		existing.name = fields.name or existing.name
		existing.icon = fields.icon or existing.icon
		return 0, 1, quantity
	end

	local link = fields.itemLink or CCC.Utilities:ItemIdToLink(itemId)
	store[key] = {
		itemId = itemId,
		itemLink = link,
		name = fields.name or CCC.Utilities:GetItemName(link),
		icon = fields.icon,
		quantity = quantity,
	}
	return 1, 0, quantity
end

--- Add purchasable missing knowledge items (motifs / recipes / blueprints).
-- Does not include traits (not purchasable as a single knowledge item).
-- @param knowledge table from KnowledgeChecker
-- @return number addedKinds, number mergedKinds, number totalQtyAdded
function SL:AddMissingKnowledge(knowledge)
	if not knowledge or not knowledge.missing then
		return 0, 0, 0
	end

	local addedKinds, mergedKinds, totalQty = 0, 0, 0
	for i = 1, #knowledge.missing do
		local req = knowledge.missing[i]
		if req.itemId and not req.known then
			local a, m, q = SL:AddItem(req.itemId, 1, {
				itemLink = req.itemLink,
				name = req.itemName or req.name,
				icon = CCC.Utilities:ResolveItemIcon(req.itemLink),
			})
			addedKinds = addedKinds + a
			mergedKinds = mergedKinds + m
			totalQty = totalQty + q
		end
	end

	return addedKinds, mergedKinds, totalQty
end

--- Count missing knowledge requirements that have a purchasable itemId.
function SL:CountPurchasableMissingKnowledge(knowledge)
	if not knowledge or not knowledge.missing then
		return 0
	end
	local n = 0
	for i = 1, #knowledge.missing do
		if knowledge.missing[i].itemId then
			n = n + 1
		end
	end
	return n
end

--- @param itemId number
function SL:Remove(itemId)
	if not itemId then
		return false
	end
	local store = SL:GetStore()
	local key = keyFor(itemId)
	if store[key] then
		store[key] = nil
		return true
	end
	return false
end

function SL:Clear()
	local settings = SL.addon.Settings
	settings.shoppingList = {}
end

function SL:IsEmpty()
	return next(SL:GetStore()) == nil
end

function SL:Count()
	local n = 0
	for _ in pairs(SL:GetStore()) do
		n = n + 1
	end
	return n
end

--- Sorted entries with live TTC unit prices / subtotals.
-- @return table entries, number total, boolean complete, number missingPrices
function SL:GetPricedEntries()
	local store = SL:GetStore()
	local entries = {}
	local total = 0
	local missingPrices = 0

	for _, entry in pairs(store) do
		local qty = entry.quantity or 0
		if qty > 0 and entry.itemId then
			local link = entry.itemLink or CCC.Utilities:ItemIdToLink(entry.itemId)
			local unitPrice = SL.addon.PriceProvider:GetUnitPrice(link)
			local subtotal = nil
			local priceMissing = false

			if unitPrice then
				subtotal = unitPrice * qty
				total = total + subtotal
			else
				priceMissing = true
				missingPrices = missingPrices + 1
			end

			entries[#entries + 1] = {
				itemId = entry.itemId,
				itemLink = link,
				name = entry.name or CCC.Utilities:GetItemName(link),
				icon = entry.icon,
				quantity = qty,
				unitPrice = unitPrice,
				subtotal = subtotal,
				missing = priceMissing,
			}
		end
	end

	table.sort(entries, function(a, b)
		local na = a.name or ""
		local nb = b.name or ""
		if na == nb then
			return (a.itemId or 0) < (b.itemId or 0)
		end
		return na < nb
	end)

	return entries, total, (missingPrices == 0), missingPrices
end
