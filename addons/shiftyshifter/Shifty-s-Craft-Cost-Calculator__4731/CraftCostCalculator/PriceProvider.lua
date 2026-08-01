-- Selects a unit price from TTC price info according to user settings.

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.PriceProvider = CCC.PriceProvider or {}
local P = CCC.PriceProvider

function P:Init(addon)
	P.addon = addon
end

local MODE_FIELDS = {
	Suggested = { "SuggestedPrice", "Avg", "SaleAvg", "Min" },
	Avg = { "Avg", "SuggestedPrice", "SaleAvg", "Min" },
	SaleAvg = { "SaleAvg", "SuggestedPrice", "Avg", "Min" },
	Min = { "Min", "SuggestedPrice", "Avg", "SaleAvg" },
}

--- @return number|nil unitPrice, table|nil priceInfo, string|nil sourceField
function P:GetUnitPrice(itemLink)
	local info = P.addon.TTCIntegration:GetPriceInfo(itemLink)
	if not info then
		return nil, nil, nil
	end

	local mode = (P.addon.Settings and P.addon.Settings.priceMode) or "Suggested"
	local order = MODE_FIELDS[mode] or MODE_FIELDS.Suggested

	for i = 1, #order do
		local field = order[i]
		local value = info[field]
		if value and value > 0 then
			return value, info, field
		end
	end

	return nil, info, nil
end
