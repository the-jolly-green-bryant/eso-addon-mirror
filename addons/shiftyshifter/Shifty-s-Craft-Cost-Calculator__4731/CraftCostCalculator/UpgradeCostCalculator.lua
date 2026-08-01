--[[
	UpgradeCostCalculator
	Material + gold cost to improve crafted gear from a chosen quality up to Legendary.

	Reuses MaterialResolver improvement math, OwnedMaterials, and CalculationEngine.
	Kept separate from full craft cost so upgrade-specific options (chance %, etc.)
	can be added later without touching the craft pipeline.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.UpgradeCostCalculator = CCC.UpgradeCostCalculator or {}
local U = CCC.UpgradeCostCalculator

-- Functional quality values (same as GetItemLinkFunctionalQuality / improvement API).
-- Prefer game globals when present; fall back to documented numeric tiers.
local QUALITY_NORMAL = ITEM_FUNCTIONAL_QUALITY_NORMAL or 1
local QUALITY_FINE = ITEM_FUNCTIONAL_QUALITY_FINE or 2
local QUALITY_SUPERIOR = ITEM_FUNCTIONAL_QUALITY_SUPERIOR or 3
local QUALITY_EPIC = ITEM_FUNCTIONAL_QUALITY_EPIC or 4
local QUALITY_LEGENDARY = ITEM_FUNCTIONAL_QUALITY_LEGENDARY or 5

local TARGET_QUALITY = QUALITY_LEGENDARY

local QUALITY_NAMES = {
	[QUALITY_NORMAL] = "White",
	[QUALITY_FINE] = "Green",
	[QUALITY_SUPERIOR] = "Blue",
	[QUALITY_EPIC] = "Purple",
	[QUALITY_LEGENDARY] = "Gold",
}

local STATION_NAMES = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
	[CRAFTING_TYPE_CLOTHIER] = "Clothing",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry Crafting",
}

function U:Init(addon)
	U.addon = addon
end

function U:GetTargetQuality()
	return TARGET_QUALITY
end

function U:GetQualityName(quality)
	return QUALITY_NAMES[quality] or ("Quality " .. tostring(quality))
end

function U:GetStationName(station)
	return STATION_NAMES[station] or ("Station " .. tostring(station))
end

--- Selectable starting qualities (anything below Legendary).
function U:GetSelectableQualities()
	return {
		QUALITY_NORMAL,
		QUALITY_FINE,
		QUALITY_SUPERIOR,
		QUALITY_EPIC,
	}
end

function U:IsSupportedStation(station)
	return station and CCC.CraftData.IMPROVEMENT_ITEM_IDS[station] ~= nil
end

--- Default starting quality when opening from a craft result.
function U:DefaultFromQuality(craftInfo)
	if not craftInfo then
		return QUALITY_NORMAL
	end
	local q = craftInfo.quality or QUALITY_NORMAL
	if q >= TARGET_QUALITY then
		return QUALITY_NORMAL
	end
	if q < QUALITY_NORMAL then
		return QUALITY_NORMAL
	end
	return q
end

--- Attach display names/icons to improvement materials.
function U:FinalizeMaterials(materials)
	for i = 1, #materials do
		local m = materials[i]
		m.name = CCC.Utilities:GetItemName(m.itemLink)
		m.icon = GetItemLinkIcon(m.itemLink)
	end
	return materials
end

--- Build per-step view models from priced calculation lines.
function U:BuildSteps(materials, pricedLines)
	local steps = {}
	for i = 1, #materials do
		local mat = materials[i]
		local line = pricedLines[i]
		local fromQ = mat.fromQuality
		local toQ = mat.toQuality or ((fromQ or 0) + 1)
		steps[#steps + 1] = {
			fromQuality = fromQ,
			toQuality = toQ,
			fromName = U:GetQualityName(fromQ),
			toName = U:GetQualityName(toQ),
			label = string.format("%s → %s", U:GetQualityName(fromQ), U:GetQualityName(toQ)),
			material = mat,
			line = line,
			required = line and line.required or mat.quantity,
			owned = line and line.owned or 0,
			shortfall = line and line.shortfall or mat.quantity,
			unitPrice = line and line.unitPrice,
			subtotal = line and line.subtotal,
			fullSubtotal = line and line.fullSubtotal,
			missing = line and line.missing,
			name = (line and line.name) or mat.name,
			itemLink = (line and line.itemLink) or mat.itemLink,
			itemId = (line and line.itemId) or mat.itemId,
			icon = (line and line.icon) or mat.icon,
		}
	end
	return steps
end

--- Summarize required upgrade materials as "Name ×qty, …".
function U:BuildMaterialsSummary(steps)
	local parts = {}
	for i = 1, #steps do
		local step = steps[i]
		parts[#parts + 1] = string.format("%s ×%d",
			zo_strformat("<<1>>", step.name or "?"),
			step.required or 0)
	end
	return table.concat(parts, ", ")
end

--- @param craftInfo table resolved craft parameters (station required)
--- @param itemLink string
--- @param fromQuality number current item quality
--- @param toQuality number|nil target (default Legendary)
--- @return table|nil result, string|nil errorMessage
function U:Calculate(craftInfo, itemLink, fromQuality, toQuality)
	if not craftInfo then
		return nil, "No craft information available."
	end
	if not U:IsSupportedStation(craftInfo.station) then
		return nil, "Upgrade costs are only available for Blacksmithing, Clothing, Woodworking, and Jewelry Crafting."
	end

	toQuality = toQuality or TARGET_QUALITY
	fromQuality = fromQuality or QUALITY_NORMAL

	if fromQuality < QUALITY_NORMAL then
		fromQuality = QUALITY_NORMAL
	end
	if fromQuality >= toQuality then
		return nil, "Item is already at or above the selected target quality."
	end

	local materials = U.addon.MaterialResolver:GetImprovementMaterials(craftInfo, fromQuality, toQuality)
	if not materials or #materials == 0 then
		return nil, "No upgrade materials required for this quality range."
	end
	U:FinalizeMaterials(materials)

	local priced = U.addon.CalculationEngine:Calculate(itemLink, craftInfo, materials)
	local steps = U:BuildSteps(materials, priced.lines)

	return {
		isUpgradeCost = true,
		itemLink = itemLink,
		itemName = priced.itemName,
		craftInfo = craftInfo,
		fromQuality = fromQuality,
		toQuality = toQuality,
		fromName = U:GetQualityName(fromQuality),
		toName = U:GetQualityName(toQuality),
		stationName = U:GetStationName(craftInfo.station),
		steps = steps,
		lines = priced.lines,
		total = priced.total, -- missing mats only
		fullTotal = priced.fullTotal, -- buy everything
		complete = priced.complete,
		pricedCount = priced.pricedCount,
		missingCount = priced.missingCount,
		fullyOwnedCount = priced.fullyOwnedCount,
		useOwnedMaterials = priced.useOwnedMaterials,
		materialsSummary = U:BuildMaterialsSummary(steps),
		ttcAvailable = priced.ttcAvailable,
	}
end

--- Convenience: resolve item then calculate upgrade cost.
function U:CalculateForItem(itemLink, fromQuality, toQuality)
	if not itemLink or itemLink == "" then
		return nil, "No item link provided."
	end

	local craftInfo, err = U.addon.CraftResolver:Resolve(itemLink)
	if not craftInfo then
		return nil, err or "Unable to resolve crafting requirements."
	end
	if craftInfo.isMasterWrit then
		return nil, "Upgrade cost applies to crafted gear, not Master Writs."
	end

	fromQuality = fromQuality or U:DefaultFromQuality(craftInfo)
	return U:Calculate(craftInfo, itemLink, fromQuality, toQuality)
end
