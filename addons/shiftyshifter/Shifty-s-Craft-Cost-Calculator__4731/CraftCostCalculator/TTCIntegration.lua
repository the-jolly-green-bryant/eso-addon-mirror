-- Thin wrapper around Tamriel Trade Centre's public price API.

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.TTCIntegration = CCC.TTCIntegration or {}
local TTC = CCC.TTCIntegration

function TTC:Init(addon)
	TTC.addon = addon
	TTC.available = (TamrielTradeCentrePrice ~= nil and TamrielTradeCentrePrice.GetPriceInfo ~= nil)
end

function TTC:IsAvailable()
	return TTC.available == true
end

--- Returns TamrielTradeCentre_PriceInfo or nil.
function TTC:GetPriceInfo(itemLink)
	if not TTC:IsAvailable() or not itemLink then
		return nil
	end
	return TamrielTradeCentrePrice:GetPriceInfo(itemLink)
end

function TTC:GetPriceTableTimestamp()
	if TamrielTradeCentrePrice and TamrielTradeCentrePrice.PriceTable then
		return TamrielTradeCentrePrice.PriceTable.TimeStamp
	end
	return nil
end
