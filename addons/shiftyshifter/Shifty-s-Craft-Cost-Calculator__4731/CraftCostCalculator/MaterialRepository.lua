--[[
	MaterialRepository
	Builds a searchable catalog of crafting materials.

	Sources (preferred dynamic where possible):
	  - Refined base mats: CraftData.MATERIAL_ITEM_IDS (station APIs need a craft table)
	  - Style mats: GetNumValidItemStyles / GetValidItemStyleId / GetItemStyleMaterialLink
	  - Trait mats: GetSmithingTraitItemLink / GetSmithingTraitItemInfo
	  - Improvement mats: GetSmithingImprovementItemLink per station × quality
	  - Alchemy / Enchanting / primary Furnishing: ProfessionMaterialData (no full off-station API)
	  - Provisioning + Furnishing ingredients: GetNumRecipeLists / GetRecipeIngredientItemLink
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.MaterialRepository = CCC.MaterialRepository or {}
local R = CCC.MaterialRepository

local CATEGORY_BASE = "base"
local CATEGORY_STYLE = "style"
local CATEGORY_TRAIT = "trait"
local CATEGORY_IMPROVE = "improvement"
local CATEGORY_ALCHEMY = "alchemy"
local CATEGORY_ENCHANTING = "enchanting"
local CATEGORY_PROVISIONING = "provisioning"
local CATEGORY_FURNISHING = "furnishing"

local STATION_LABELS = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
	[CRAFTING_TYPE_CLOTHIER] = "Clothing",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry",
	[CRAFTING_TYPE_ALCHEMY] = "Alchemy",
	[CRAFTING_TYPE_ENCHANTING] = "Enchanting",
	[CRAFTING_TYPE_PROVISIONING] = "Provisioning",
}

local IMPROVE_LABELS = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmith Improvement",
	[CRAFTING_TYPE_CLOTHIER] = "Clothier Improvement",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking Improvement",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry Improvement",
}

local BASE_LABELS = {
	[CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
	[CRAFTING_TYPE_CLOTHIER] = "Clothing",
	[3] = "Leather",
	[CRAFTING_TYPE_WOODWORKING] = "Woodworking",
	[CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry",
}

local TRAIT_EMPTY_STOP = 8
local TRAIT_INDEX_MAX = 64

function R:Init(addon)
	R.addon = addon
	R.catalog = nil
	R.byItemId = nil
end

local function normalizeName(name)
	if not name or name == "" then
		return ""
	end
	return zo_strlower(name)
end

local function isFurnishingSpecialType(specialIngredientType)
	if not specialIngredientType then
		return false
	end
	if PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING
		and specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING then
		return true
	end
	-- Fallback numeric used historically if the constant is unavailable.
	return specialIngredientType == 3
end

function R:MakeEntry(itemId, itemLink, category, categoryLabel, station)
	if not itemId or itemId <= 0 then
		return nil
	end

	local link = itemLink
	if not link or link == "" then
		link = CCC.Utilities:ItemIdToLink(itemId)
	end
	if not link or link == "" then
		return nil
	end

	local name = CCC.Utilities:GetItemName(link)
	if not name or name == "" or name == "Unknown" then
		return nil
	end

	local icon = GetItemLinkIcon(link)
	return {
		itemId = itemId,
		itemLink = link,
		name = name,
		nameLower = normalizeName(name),
		icon = icon,
		category = category,
		categoryLabel = categoryLabel,
		station = station,
	}
end

function R:AddEntry(seen, list, entry)
	if not entry or not entry.itemId then
		return
	end
	if seen[entry.itemId] then
		return
	end
	seen[entry.itemId] = true
	list[#list + 1] = entry
end

function R:AddIdList(seen, list, ids, category, categoryLabel, station)
	if not ids then
		return
	end
	for i = 1, #ids do
		local itemId = ids[i]
		local link = CCC.Utilities:ItemIdToLink(itemId)
		R:AddEntry(seen, list, R:MakeEntry(itemId, link, category, categoryLabel, station))
	end
end

function R:CollectBaseMaterials(seen, list)
	local mats = CCC.CraftData.MATERIAL_ITEM_IDS
	if not mats then
		return
	end

	for stationKey, tiers in pairs(mats) do
		local label = BASE_LABELS[stationKey] or STATION_LABELS[stationKey] or "Base Material"
		local station = (stationKey == 3) and CRAFTING_TYPE_CLOTHIER or stationKey
		for i = 1, #tiers do
			local itemId = tiers[i]
			local link = CCC.Utilities:ItemIdToLink(itemId)
			R:AddEntry(seen, list, R:MakeEntry(itemId, link, CATEGORY_BASE, label, station))
		end
	end
end

function R:CollectImprovementMaterials(seen, list)
	local stations = {
		CRAFTING_TYPE_BLACKSMITHING,
		CRAFTING_TYPE_CLOTHIER,
		CRAFTING_TYPE_WOODWORKING,
		CRAFTING_TYPE_JEWELRYCRAFTING,
	}
	local fallbackIds = CCC.CraftData.IMPROVEMENT_ITEM_IDS

	for s = 1, #stations do
		local station = stations[s]
		local label = IMPROVE_LABELS[station] or "Improvement"
		local fallback = fallbackIds and fallbackIds[station]
		for q = 1, 4 do
			local link
			if GetSmithingImprovementItemLink then
				link = GetSmithingImprovementItemLink(station, q, LINK_STYLE_DEFAULT)
			end
			local itemId
			if link and link ~= "" then
				itemId = GetItemLinkItemId(link)
			elseif fallback and fallback[q] then
				itemId = fallback[q]
				link = CCC.Utilities:ItemIdToLink(itemId)
			end
			if itemId then
				R:AddEntry(seen, list, R:MakeEntry(itemId, link, CATEGORY_IMPROVE, label, station))
			end
		end
	end
end

function R:CollectStyleMaterials(seen, list)
	if not GetItemStyleMaterialLink then
		return
	end

	local label = "Style Material"

	if GetNumValidItemStyles and GetValidItemStyleId then
		local num = GetNumValidItemStyles() or 0
		for i = 1, num do
			local styleId = GetValidItemStyleId(i)
			if styleId and styleId > 0 then
				local link = GetItemStyleMaterialLink(styleId, LINK_STYLE_DEFAULT)
				if link and link ~= "" then
					local itemId = GetItemLinkItemId(link)
					R:AddEntry(seen, list, R:MakeEntry(itemId, link, CATEGORY_STYLE, label, nil))
				end
			end
		end
	elseif GetHighestItemStyleId then
		local highest = GetHighestItemStyleId() or 0
		for styleId = 1, highest do
			local link = GetItemStyleMaterialLink(styleId, LINK_STYLE_DEFAULT)
			if link and link ~= "" then
				local itemId = GetItemLinkItemId(link)
				R:AddEntry(seen, list, R:MakeEntry(itemId, link, CATEGORY_STYLE, label, nil))
			end
		end
	end

	if GetUniversalStyleId then
		local uni = GetUniversalStyleId()
		if uni and uni > 0 then
			local link = GetItemStyleMaterialLink(uni, LINK_STYLE_DEFAULT)
			if link and link ~= "" then
				local itemId = GetItemLinkItemId(link)
				R:AddEntry(seen, list, R:MakeEntry(itemId, link, CATEGORY_STYLE, label, nil))
			end
		end
	end
end

function R:CollectTraitMaterials(seen, list)
	if not GetSmithingTraitItemLink then
		return
	end

	local label = "Trait Material"
	local emptyStreak = 0

	-- Index 1 is typically "no trait"; still probe from 1 and skip empties.
	for traitIndex = 1, TRAIT_INDEX_MAX do
		local link = GetSmithingTraitItemLink(traitIndex, LINK_STYLE_DEFAULT)
		local itemId
		if link and link ~= "" then
			itemId = GetItemLinkItemId(link)
		end

		if itemId and itemId > 0 then
			emptyStreak = 0
			R:AddEntry(seen, list, R:MakeEntry(itemId, link, CATEGORY_TRAIT, label, nil))
		else
			emptyStreak = emptyStreak + 1
			if traitIndex > 1 and emptyStreak >= TRAIT_EMPTY_STOP then
				break
			end
		end
	end
end

function R:CollectAlchemyMaterials(seen, list)
	local data = CCC.ProfessionMaterialData
	if not data then
		return
	end
	R:AddIdList(seen, list, data.ALCHEMY_REAGENTS, CATEGORY_ALCHEMY, "Alchemy Reagent", CRAFTING_TYPE_ALCHEMY)
	R:AddIdList(seen, list, data.ALCHEMY_SOLVENTS, CATEGORY_ALCHEMY, "Alchemy Solvent", CRAFTING_TYPE_ALCHEMY)
end

function R:CollectEnchantingMaterials(seen, list)
	local data = CCC.ProfessionMaterialData
	if not data then
		return
	end
	R:AddIdList(seen, list, data.ENCHANTING_POTENCY, CATEGORY_ENCHANTING, "Enchanting Potency", CRAFTING_TYPE_ENCHANTING)
	R:AddIdList(seen, list, data.ENCHANTING_ESSENCE, CATEGORY_ENCHANTING, "Enchanting Essence", CRAFTING_TYPE_ENCHANTING)
	R:AddIdList(seen, list, data.ENCHANTING_ASPECT, CATEGORY_ENCHANTING, "Enchanting Aspect", CRAFTING_TYPE_ENCHANTING)
end

function R:CollectFurnishingPrimary(seen, list)
	local data = CCC.ProfessionMaterialData
	if not data then
		return
	end
	R:AddIdList(seen, list, data.FURNISHING_PRIMARY, CATEGORY_FURNISHING, "Furnishing", nil)
	R:CollectFromBlueprintLinks(seen, list, data.FURNISHING_SEED_BLUEPRINTS)
end

--- Discover ingredients from blueprint/recipe item links (works even when unknown).
function R:CollectFromBlueprintLinks(seen, list, blueprintIds)
	if not blueprintIds or not GetItemLinkRecipeNumIngredients or not GetItemLinkRecipeIngredientItemLink then
		return
	end

	for i = 1, #blueprintIds do
		local blueprintLink = CCC.Utilities:ItemIdToLink(blueprintIds[i])
		if blueprintLink and blueprintLink ~= "" then
			local numIngredients = GetItemLinkRecipeNumIngredients(blueprintLink) or 0
			for ingredientIndex = 1, numIngredients do
				local link = GetItemLinkRecipeIngredientItemLink(blueprintLink, ingredientIndex, LINK_STYLE_DEFAULT)
				if link and link ~= "" then
					local itemId = GetItemLinkItemId(link)
					R:AddEntry(seen, list, R:MakeEntry(
						itemId, link, CATEGORY_FURNISHING, "Furnishing", nil))
				end
			end
		end
	end
end

function R:CollectProvisioningSpecial(seen, list)
	local data = CCC.ProfessionMaterialData
	if not data then
		return
	end
	R:AddIdList(seen, list, data.PROVISIONING_SPECIAL, CATEGORY_PROVISIONING, "Provisioning", CRAFTING_TYPE_PROVISIONING)
end

--- Walk all recipe lists and collect unique ingredients (Provisioning + Furnishing).
-- Ingredient links are available for known recipes; unknown recipes are attempted
-- as well in case the client returns data.
function R:CollectRecipeIngredients(seen, list)
	if not GetNumRecipeLists or not GetRecipeListInfo or not GetRecipeInfo then
		return
	end
	if not GetRecipeIngredientItemLink then
		return
	end

	local numLists = GetNumRecipeLists() or 0
	for recipeListIndex = 1, numLists do
		local _, numRecipes = GetRecipeListInfo(recipeListIndex)
		numRecipes = numRecipes or 0
		for recipeIndex = 1, numRecipes do
			local _, _, numIngredients, _, _, specialIngredientType, requiredCraftingStationType =
				GetRecipeInfo(recipeListIndex, recipeIndex)
			numIngredients = numIngredients or 0
			if numIngredients > 0 then
				local isFurnishing = isFurnishingSpecialType(specialIngredientType)
				local isProvisioning = (requiredCraftingStationType == CRAFTING_TYPE_PROVISIONING)
					or (PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES
						and specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_SPICES)
					or (PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING
						and specialIngredientType == PROVISIONER_SPECIAL_INGREDIENT_TYPE_FLAVORING)

				local category, label, station
				if isFurnishing then
					category = CATEGORY_FURNISHING
					label = "Furnishing"
					station = requiredCraftingStationType
				elseif isProvisioning then
					category = CATEGORY_PROVISIONING
					label = "Provisioning"
					station = CRAFTING_TYPE_PROVISIONING
				elseif requiredCraftingStationType == CRAFTING_TYPE_ALCHEMY then
					category = CATEGORY_ALCHEMY
					label = "Alchemy"
					station = CRAFTING_TYPE_ALCHEMY
				elseif requiredCraftingStationType == CRAFTING_TYPE_ENCHANTING then
					category = CATEGORY_ENCHANTING
					label = "Enchanting"
					station = CRAFTING_TYPE_ENCHANTING
				else
					-- Remaining recipe-list crafts are furnishings at gear stations.
					category = CATEGORY_FURNISHING
					label = "Furnishing"
					station = requiredCraftingStationType
				end

				for ingredientIndex = 1, numIngredients do
					local link = GetRecipeIngredientItemLink(
						recipeListIndex, recipeIndex, ingredientIndex, LINK_STYLE_DEFAULT)
					if link and link ~= "" then
						local itemId = GetItemLinkItemId(link)
						R:AddEntry(seen, list, R:MakeEntry(itemId, link, category, label, station))
					end
				end
			end
		end
	end
end

--- Build the full catalog once. Subsequent calls return the cache.
-- @return table array of material entries
function R:GetCatalog()
	if R.catalog then
		return R.catalog
	end

	local seen = {}
	local list = {}

	R:CollectBaseMaterials(seen, list)
	R:CollectImprovementMaterials(seen, list)
	R:CollectStyleMaterials(seen, list)
	R:CollectTraitMaterials(seen, list)
	R:CollectAlchemyMaterials(seen, list)
	R:CollectEnchantingMaterials(seen, list)
	R:CollectFurnishingPrimary(seen, list)
	R:CollectProvisioningSpecial(seen, list)
	R:CollectRecipeIngredients(seen, list)

	table.sort(list, function(a, b)
		local na = a.nameLower or ""
		local nb = b.nameLower or ""
		if na == nb then
			return (a.itemId or 0) < (b.itemId or 0)
		end
		return na < nb
	end)

	local byId = {}
	for i = 1, #list do
		byId[list[i].itemId] = list[i]
	end

	R.catalog = list
	R.byItemId = byId
	return list
end

function R:GetByItemId(itemId)
	R:GetCatalog()
	return R.byItemId and R.byItemId[itemId] or nil
end

function R:IsBuilt()
	return R.catalog ~= nil
end

function R:GetCount()
	local catalog = R:GetCatalog()
	return #catalog
end
