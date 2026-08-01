--[[
	CalculationEngine
	Combines material list + owned counts + TTC prices into a cost breakdown.

	Craft cost uses only materials still needed (shortfall = required - owned).
	If the player already owns enough of a material, its line cost is 0.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.CalculationEngine = CCC.CalculationEngine or {}
local E = CCC.CalculationEngine

function E:Init(addon)
	E.addon = addon
end

--- @param itemLink string
--- @param craftInfo table
--- @param materials table
--- @return table result
function E:Calculate(itemLink, craftInfo, materials)
	local ownedCounts = E.addon.OwnedMaterials:GetOwnedForMaterials(materials)
	local useOwned = E.addon.OwnedMaterials:IsEnabled()

	local lines = {}
	local total = 0
	local fullTotal = 0
	local pricedCount = 0
	local missingPriceCount = 0
	local fullyOwnedCount = 0

	for i = 1, #materials do
		local mat = materials[i]
		local required = mat.quantity or 0
		local owned = ownedCounts[mat.itemId] or 0
		if not useOwned then
			owned = 0
		end
		local shortfall = required - owned
		if shortfall < 0 then
			shortfall = 0
		end

		local unitPrice, priceInfo, sourceField = E.addon.PriceProvider:GetUnitPrice(mat.itemLink)
		local subtotal = nil
		local fullSubtotal = nil
		local priceMissing = false

		if unitPrice then
			fullSubtotal = unitPrice * required
			subtotal = unitPrice * shortfall
			fullTotal = fullTotal + fullSubtotal
			total = total + subtotal
			pricedCount = pricedCount + 1
		else
			-- Only count as a pricing gap if we still need to buy some
			if shortfall > 0 then
				priceMissing = true
				missingPriceCount = missingPriceCount + 1
			end
		end

		if shortfall == 0 and required > 0 then
			fullyOwnedCount = fullyOwnedCount + 1
		end

		lines[#lines + 1] = {
			itemId = mat.itemId,
			itemLink = mat.itemLink,
			name = mat.name,
			icon = mat.icon,
			quantity = required, -- required (kept for backwards compatibility)
			required = required,
			owned = owned,
			shortfall = shortfall,
			category = mat.category,
			fromQuality = mat.fromQuality,
			toQuality = mat.toQuality,
			unitPrice = unitPrice,
			subtotal = subtotal,
			fullSubtotal = fullSubtotal,
			missing = priceMissing, -- no TTC price (and still needed)
			priceSource = sourceField,
			priceInfo = priceInfo,
		}
	end

	local resultUnit, resultInfo, resultSource = E.addon.PriceProvider:GetUnitPrice(itemLink)

	return {
		itemLink = itemLink,
		itemName = CCC.Utilities:GetItemName(itemLink),
		craftInfo = craftInfo,
		lines = lines,
		total = total, -- cost of missing materials only
		fullTotal = fullTotal, -- cost if buying everything
		complete = (missingPriceCount == 0),
		pricedCount = pricedCount,
		missingCount = missingPriceCount,
		fullyOwnedCount = fullyOwnedCount,
		useOwnedMaterials = useOwned,
		resultMarketPrice = resultUnit,
		resultPriceInfo = resultInfo,
		resultPriceSource = resultSource,
		ttcAvailable = E.addon.TTCIntegration:IsAvailable(),
	}
end
