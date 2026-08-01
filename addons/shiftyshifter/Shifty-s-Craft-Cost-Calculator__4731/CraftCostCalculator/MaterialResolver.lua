--[[
	MaterialResolver
	Turns craft parameters into a list of {itemId, itemLink, quantity, category}.

	Dynamic APIs used when available:
	  - GetItemStyleMaterialLink(styleId)
	  - GetSmithingTraitItemLink(traitIndex)
	  - GetSmithingImprovementItemLink(station, qualityIndex)
	  - GetRecipeIngredient* / GetItemLinkRecipe* for Provisioning writs

	Static tables used only for refined material itemIds and improvement counts.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.MaterialResolver = CCC.MaterialResolver or {}
local M = CCC.MaterialResolver

local CATEGORY_BASE = "base"
local CATEGORY_STYLE = "style"
local CATEGORY_TRAIT = "trait"
local CATEGORY_IMPROVE = "improvement"
local CATEGORY_INGREDIENT = "ingredient"
local CATEGORY_GLYPH = "glyph"

function M:Init(addon)
	M.addon = addon
end

function M:GetImprovementExpertiseRank(station)
	local settings = M.addon.Settings
	if settings and settings.assumeMaxImprovementExpertise then
		return 3
	end

	local abilityId = CCC.CraftData.IMPROVEMENT_ABILITY_IDS[station]
	if not abilityId or not GetSpecificSkillAbilityKeysByAbilityId then
		return 3
	end

	local skillType, skillIndex, abilityIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
	if not abilityIndex then
		return 3
	end

	local current = GetSkillAbilityUpgradeInfo(skillType, skillIndex, abilityIndex)
	return current or 0
end

function M:GetBaseMaterialItemId(craftInfo)
	local data = CCC.CraftData
	local station = craftInfo.station
	local materialIndex = craftInfo.materialIndex

	if station == CRAFTING_TYPE_JEWELRYCRAFTING then
		local row = data.JEWELRY_MAT_REQUIREMENT[materialIndex]
		if not row then
			return nil
		end
		local tier = row[3]
		return data.MATERIAL_ITEM_IDS[station][tier]
	end

	local tier = data:FindMatTierByIndex(materialIndex)
	if station == CRAFTING_TYPE_CLOTHIER and craftInfo.isMediumArmor then
		return data.MATERIAL_ITEM_IDS[3][tier]
	end
	return data.MATERIAL_ITEM_IDS[station][tier]
end

function M:GetStyleMaterial(craftInfo)
	if craftInfo.station == CRAFTING_TYPE_JEWELRYCRAFTING then
		return nil -- jewelry has no style material
	end
	if not craftInfo.styleId or craftInfo.styleId == 0 then
		return nil
	end

	local link = GetItemStyleMaterialLink(craftInfo.styleId, LINK_STYLE_DEFAULT)
	if not link or link == "" then
		return nil
	end
	return {
		itemId = GetItemLinkItemId(link),
		itemLink = link,
		quantity = 1,
		category = CATEGORY_STYLE,
	}
end

function M:GetTraitMaterial(craftInfo)
	if not craftInfo.traitIndex or craftInfo.traitIndex <= 1 then
		return nil -- no trait
	end

	local link = GetSmithingTraitItemLink(craftInfo.traitIndex, LINK_STYLE_DEFAULT)
	if not link or link == "" then
		return nil
	end
	return {
		itemId = GetItemLinkItemId(link),
		itemLink = link,
		quantity = 1,
		category = CATEGORY_TRAIT,
	}
end

--- Improvement boosters between two qualities (inclusive start, exclusive end).
-- @param craftInfo table
-- @param fromQuality number|nil start quality (default NORMAL / white)
-- @param toQuality number|nil target quality (default craftInfo.quality)
-- @return table materials with fromQuality / toQuality on each entry
function M:GetImprovementMaterials(craftInfo, fromQuality, toQuality)
	fromQuality = fromQuality or ITEM_FUNCTIONAL_QUALITY_NORMAL
	toQuality = toQuality or craftInfo.quality or ITEM_FUNCTIONAL_QUALITY_NORMAL

	if toQuality <= fromQuality then
		return {}
	end

	local station = craftInfo.station
	local rank = M:GetImprovementExpertiseRank(station)
	local counts = CCC.CraftData.IMPROVEMENT_COUNTS[rank] or CCC.CraftData.IMPROVEMENT_COUNTS[3]
	local fallbackIds = CCC.CraftData.IMPROVEMENT_ITEM_IDS[station]
	local results = {}

	-- API index matches from-quality (white→green = 1, … purple→gold = 4).
	for q = fromQuality, toQuality - 1 do
		local qty = counts[q]
		if qty and qty > 0 then
			local link = GetSmithingImprovementItemLink(station, q, LINK_STYLE_DEFAULT)
			local itemId
			if link and link ~= "" then
				itemId = GetItemLinkItemId(link)
			elseif fallbackIds then
				itemId = fallbackIds[q]
				link = CCC.Utilities:ItemIdToLink(itemId)
			end

			if itemId and link then
				results[#results + 1] = {
					itemId = itemId,
					itemLink = link,
					quantity = qty,
					category = CATEGORY_IMPROVE,
					fromQuality = q,
					toQuality = q + 1,
				}
			end
		end
	end

	return results
end

--- Prefer LibLazyCrafting CompileRequirements when available; otherwise local resolution.
function M:ResolveViaLLC(craftInfo)
	if not LibLazyCrafting or not LibLazyCrafting.functionTable or not LibLazyCrafting.functionTable.CompileRequirements then
		return nil
	end

	local request = {
		type = "smithing",
		station = craftInfo.station,
		pattern = craftInfo.pattern,
		materialIndex = craftInfo.materialIndex,
		materialQuantity = craftInfo.materialQuantity,
		style = craftInfo.styleId,
		trait = craftInfo.traitIndex,
		quality = craftInfo.quality,
		useUniversalStyleItem = false,
	}

	local ok, requirements = pcall(LibLazyCrafting.functionTable.CompileRequirements, request)
	if not ok or type(requirements) ~= "table" then
		return nil
	end

	local materials = {}
	for itemId, quantity in pairs(requirements) do
		if type(itemId) == "number" and type(quantity) == "number" and quantity > 0 then
			materials[#materials + 1] = {
				itemId = itemId,
				itemLink = CCC.Utilities:ItemIdToLink(itemId),
				quantity = quantity,
				category = "llc",
			}
		end
	end

	if #materials == 0 then
		return nil
	end
	return materials
end

function M:ResolveLocal(craftInfo)
	local materials = {}

	local baseId = M:GetBaseMaterialItemId(craftInfo)
	if not baseId then
		return nil, "Could not resolve base crafting material."
	end

	materials[#materials + 1] = {
		itemId = baseId,
		itemLink = CCC.Utilities:ItemIdToLink(baseId),
		quantity = craftInfo.materialQuantity,
		category = CATEGORY_BASE,
	}

	local styleMat = M:GetStyleMaterial(craftInfo)
	if styleMat then
		materials[#materials + 1] = styleMat
	elseif craftInfo.station ~= CRAFTING_TYPE_JEWELRYCRAFTING then
		return nil, "Could not resolve style material."
	end

	local traitMat = M:GetTraitMaterial(craftInfo)
	if traitMat then
		materials[#materials + 1] = traitMat
	end

	local improve = M:GetImprovementMaterials(craftInfo)
	for i = 1, #improve do
		materials[#materials + 1] = improve[i]
	end

	local glyphMats, glyphWarning = M:GetGlyphMaterials(craftInfo)
	for i = 1, #glyphMats do
		materials[#materials + 1] = glyphMats[i]
	end
	if glyphWarning then
		craftInfo.glyphWarning = glyphWarning
	end

	return materials
end

--- Optional glyph (enchanting) runes — never fails the equipment resolve.
function M:GetGlyphMaterials(craftInfo)
	if not CCC.GlyphResolver or not CCC.GlyphResolver.ResolveForCraftInfo then
		return {}, nil
	end
	local mats, warning = CCC.GlyphResolver:ResolveForCraftInfo(craftInfo)
	return mats or {}, warning
end

--- Resolve recipe teaching-item link for unknown-recipe ingredient fallback.
local function resolveRecipeTeachingLink(craftInfo, recipeInfo)
	if recipeInfo and recipeInfo.recipeLink and recipeInfo.recipeLink ~= "" then
		return recipeInfo.recipeLink
	end

	local LCK = LibCharacterKnowledge
	local resultItemId = craftInfo.recipeResultItemId or craftInfo.provisioningResultItemId
	if LCK and LCK.GetSourceItemIdFromResultItem and resultItemId then
		local recipeItemId = LCK.GetSourceItemIdFromResultItem(resultItemId)
		if recipeItemId and recipeItemId > 0 then
			return CCC.Utilities:ItemIdToLink(recipeItemId)
		end
	end

	return nil
end

--- Ingredients via recipe list/index APIs (typically work for known recipes).
function M:CollectIngredientsFromRecipeIndices(listIndex, recipeIndex, numIngredients)
	if not listIndex or not recipeIndex then
		return nil
	end
	if not GetRecipeIngredientItemLink then
		return nil
	end

	numIngredients = numIngredients or 0
	if numIngredients <= 0 and GetRecipeInfo then
		local _, _, n = GetRecipeInfo(listIndex, recipeIndex)
		numIngredients = n or 0
	end
	if numIngredients <= 0 then
		return nil
	end

	local materials = {}
	for ingredientIndex = 1, numIngredients do
		local link = GetRecipeIngredientItemLink(listIndex, recipeIndex, ingredientIndex, LINK_STYLE_DEFAULT)
		if link and link ~= "" then
			local quantity = 1
			if GetRecipeIngredientRequiredQuantity then
				quantity = GetRecipeIngredientRequiredQuantity(listIndex, recipeIndex, ingredientIndex) or 1
			elseif GetRecipeIngredientItemInfo then
				local _, _, qty = GetRecipeIngredientItemInfo(listIndex, recipeIndex, ingredientIndex)
				if type(qty) == "number" and qty > 0 then
					quantity = qty
				end
			end
			local itemId = GetItemLinkItemId and GetItemLinkItemId(link)
			if not itemId then
				local parts = { ZO_LinkHandler_ParseLink(link) }
				itemId = tonumber(parts[4])
			end
			if itemId and quantity > 0 then
				materials[#materials + 1] = {
					itemId = itemId,
					itemLink = link,
					quantity = quantity,
					category = CATEGORY_INGREDIENT,
				}
			end
		end
	end

	if #materials == 0 then
		return nil
	end
	return materials
end

--- Ingredients via a Recipe: item link (works for unknown recipes).
function M:CollectIngredientsFromRecipeItemLink(recipeLink)
	if not recipeLink or recipeLink == "" then
		return nil
	end
	if not GetItemLinkRecipeNumIngredients or not GetItemLinkRecipeIngredientItemLink then
		return nil
	end

	local numIngredients = GetItemLinkRecipeNumIngredients(recipeLink) or 0
	if numIngredients <= 0 then
		return nil
	end

	local materials = {}
	for ingredientIndex = 1, numIngredients do
		local link = GetItemLinkRecipeIngredientItemLink(recipeLink, ingredientIndex, LINK_STYLE_DEFAULT)
		if link and link ~= "" then
			local quantity = 1
			-- Prefer dedicated quantity APIs when present; otherwise parse Info returns.
			if GetItemLinkRecipeIngredientInfo then
				local ok, a, b, c = pcall(GetItemLinkRecipeIngredientInfo, recipeLink, ingredientIndex)
				if ok then
					-- Common signature: name, icon, requiredQuantity, ...
					if type(c) == "number" and c > 0 then
						quantity = c
					elseif type(b) == "number" and b > 0 and type(a) == "string" then
						-- Some builds may return name, requiredQuantity
						quantity = b
					end
				end
			end
			local itemId = GetItemLinkItemId and GetItemLinkItemId(link)
			if not itemId then
				local parts = { ZO_LinkHandler_ParseLink(link) }
				itemId = tonumber(parts[4])
			end
			if itemId and quantity > 0 then
				materials[#materials + 1] = {
					itemId = itemId,
					itemLink = link,
					quantity = quantity,
					category = CATEGORY_INGREDIENT,
				}
			end
		end
	end

	if #materials == 0 then
		return nil
	end
	return materials
end

--- Provisioning Master Writ → ingredient material list via game recipe APIs.
-- @return table|nil materials, string|nil error
function M:ResolveProvisioning(craftInfo)
	local resultItemId = craftInfo.recipeResultItemId or craftInfo.provisioningResultItemId
	if not resultItemId or resultItemId <= 0 then
		return nil, "Provisioning writ is missing a recipe result item id."
	end

	local recipeInfo = nil
	if CCC.KnowledgeChecker and CCC.KnowledgeChecker.FindRecipeForResult then
		recipeInfo = CCC.KnowledgeChecker:FindRecipeForResult(resultItemId)
	end

	-- Attach recipe indices onto craftInfo for KnowledgeChecker / UI reuse.
	if recipeInfo then
		craftInfo.recipeListIndex = recipeInfo.listIndex
		craftInfo.recipeIndex = recipeInfo.recipeIndex
		craftInfo.recipeKnown = recipeInfo.known
		if recipeInfo.resultName then
			craftInfo.requiredItemName = craftInfo.requiredItemName or recipeInfo.resultName
		end
		if recipeInfo.recipeLink then
			craftInfo.recipeItemLink = recipeInfo.recipeLink
		end
	end

	local materials = nil
	if recipeInfo then
		materials = M:CollectIngredientsFromRecipeIndices(
			recipeInfo.listIndex, recipeInfo.recipeIndex, recipeInfo.numIngredients)
	end

	-- Unknown recipes: index-based ingredient APIs are often blocked; fall back
	-- to the teaching Recipe: item link (LCK / GetRecipeInfoItemLink).
	if not materials then
		local teachingLink = resolveRecipeTeachingLink(craftInfo, recipeInfo)
		if teachingLink then
			craftInfo.recipeItemLink = craftInfo.recipeItemLink or teachingLink
			materials = M:CollectIngredientsFromRecipeItemLink(teachingLink)
		end
	end

	if not materials or #materials == 0 then
		local dishName = craftInfo.requiredItemName
			or CCC.Utilities:GetItemName(CCC.Utilities:ItemIdToLink(resultItemId))
		if not recipeInfo then
			return nil, string.format(
				"Could not find a provisioning recipe for %s (item %d). Ingredient costing is unavailable for this writ.",
				dishName or "this dish",
				resultItemId
			)
		end
		return nil, string.format(
			"Found recipe for %s but could not read ingredients. Learn the recipe or install LibCharacterKnowledge so the Recipe item can be resolved.",
			dishName or "this dish"
		)
	end

	return materials
end

local function attachDisplayFields(materials)
	for i = 1, #materials do
		local m = materials[i]
		m.name = CCC.Utilities:GetItemName(m.itemLink)
		m.icon = GetItemLinkIcon(m.itemLink)
	end
	return materials
end

--- @return table|nil materials, string|nil error
function M:Resolve(craftInfo)
	if craftInfo and (craftInfo.isProvisioning or craftInfo.station == CRAFTING_TYPE_PROVISIONING) then
		local materials, err = M:ResolveProvisioning(craftInfo)
		if materials then
			return attachDisplayFields(materials)
		end
		return nil, err
	end

	-- Local resolver is preferred for consistent categorization in the UI.
	-- LLC is kept as a soft validation path / future option.
	local materials, err = M:ResolveLocal(craftInfo)
	if materials then
		return attachDisplayFields(materials)
	end
	return nil, err
end

-- CATEGORY_GLYPH exported for UI label maps / tests.
M.CATEGORY_GLYPH = CATEGORY_GLYPH
