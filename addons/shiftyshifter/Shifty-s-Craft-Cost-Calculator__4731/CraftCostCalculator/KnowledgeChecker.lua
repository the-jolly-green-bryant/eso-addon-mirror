--[[
	KnowledgeChecker
	Determines whether the current character can complete a Master Writ based
	on learned knowledge (motif chapters, researched traits, recipes, plans).

	Modular: each Check* function appends to a shared requirements list.
	New knowledge types can be added without touching the cost pipeline.

	Style checks prefer LibCharacterKnowledge when available (optional dep);
	otherwise fall back to IsSmithingStyleKnown. Trait checks use the native
	smithing research API. Recipe/blueprint checks use LCK or recipe list APIs.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.KnowledgeChecker = CCC.KnowledgeChecker or {}
local K = CCC.KnowledgeChecker

-- Motif chapter for each crafting-station pattern index.
-- Values are ITEM_STYLE_CHAPTER_* (game constants), not hardcoded motif IDs.
local MOTIF_CHAPTER_BY_STATION_PATTERN = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		[1] = ITEM_STYLE_CHAPTER_AXES,
		[2] = ITEM_STYLE_CHAPTER_MACES,
		[3] = ITEM_STYLE_CHAPTER_SWORDS,
		[4] = ITEM_STYLE_CHAPTER_AXES,
		[5] = ITEM_STYLE_CHAPTER_MACES,
		[6] = ITEM_STYLE_CHAPTER_SWORDS,
		[7] = ITEM_STYLE_CHAPTER_DAGGERS,
		[8] = ITEM_STYLE_CHAPTER_CHESTS,
		[9] = ITEM_STYLE_CHAPTER_BOOTS,
		[10] = ITEM_STYLE_CHAPTER_GLOVES,
		[11] = ITEM_STYLE_CHAPTER_HELMETS,
		[12] = ITEM_STYLE_CHAPTER_LEGS,
		[13] = ITEM_STYLE_CHAPTER_SHOULDERS,
		[14] = ITEM_STYLE_CHAPTER_BELTS,
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		-- Light
		[1] = ITEM_STYLE_CHAPTER_CHESTS,
		[2] = ITEM_STYLE_CHAPTER_CHESTS,
		[3] = ITEM_STYLE_CHAPTER_BOOTS,
		[4] = ITEM_STYLE_CHAPTER_GLOVES,
		[5] = ITEM_STYLE_CHAPTER_HELMETS,
		[6] = ITEM_STYLE_CHAPTER_LEGS,
		[7] = ITEM_STYLE_CHAPTER_SHOULDERS,
		[8] = ITEM_STYLE_CHAPTER_BELTS,
		-- Medium
		[9] = ITEM_STYLE_CHAPTER_CHESTS,
		[10] = ITEM_STYLE_CHAPTER_BOOTS,
		[11] = ITEM_STYLE_CHAPTER_GLOVES,
		[12] = ITEM_STYLE_CHAPTER_HELMETS,
		[13] = ITEM_STYLE_CHAPTER_LEGS,
		[14] = ITEM_STYLE_CHAPTER_SHOULDERS,
		[15] = ITEM_STYLE_CHAPTER_BELTS,
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		[1] = ITEM_STYLE_CHAPTER_BOWS,
		[2] = ITEM_STYLE_CHAPTER_SHIELDS,
		[3] = ITEM_STYLE_CHAPTER_STAVES,
		[4] = ITEM_STYLE_CHAPTER_STAVES,
		[5] = ITEM_STYLE_CHAPTER_STAVES,
		[6] = ITEM_STYLE_CHAPTER_STAVES,
	},
}

-- Research line index can differ from crafting pattern (esp. woodworking / jewelry).
local RESEARCH_LINE_BY_STATION_PATTERN = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		[1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7,
		[8] = 8, [9] = 9, [10] = 10, [11] = 11, [12] = 12, [13] = 13, [14] = 14,
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		[1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8,
		[9] = 9, [10] = 10, [11] = 11, [12] = 12, [13] = 13, [14] = 14, [15] = 15,
	},
	-- Craft patterns: 1 bow, 2 shield, 3–6 staves. Research lines: 1 bow, 2–5 staves, 6 shield.
	[CRAFTING_TYPE_WOODWORKING] = {
		[1] = 1,
		[2] = 6,
		[3] = 2,
		[4] = 3,
		[5] = 4,
		[6] = 5,
	},
	-- Craft patterns: 1 ring, 2 necklace. Research lines: 1 necklace, 2 ring.
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		[1] = 2,
		[2] = 1,
	},
}

local KIND_STYLE = "style"
local KIND_TRAIT = "trait"
local KIND_RECIPE = "recipe"
local KIND_BLUEPRINT = "blueprint"

function K:Init(addon)
	K.addon = addon
	K.lck = (LibCharacterKnowledge ~= nil) and LibCharacterKnowledge or nil
end

function K:GetLCK()
	if K.lck then
		return K.lck
	end
	if LibCharacterKnowledge then
		K.lck = LibCharacterKnowledge
		return K.lck
	end
	return nil
end

function K:IsEnabled()
	local settings = K.addon and K.addon.Settings
	if settings and settings.checkWritKnowledge == false then
		return false
	end
	return true
end

--- Motif chapter constant for a station pattern, or nil (jewelry / unknown).
function K:GetMotifChapter(station, pattern)
	local byStation = MOTIF_CHAPTER_BY_STATION_PATTERN[station]
	if not byStation then
		return nil
	end
	return byStation[pattern]
end

function K:GetResearchLineIndex(station, pattern)
	local byStation = RESEARCH_LINE_BY_STATION_PATTERN[station]
	if not byStation then
		return pattern
	end
	return byStation[pattern] or pattern
end

local function chapterDisplayName(chapterId, lck)
	if not chapterId then
		return nil
	end
	if lck and lck.GetMotifChapterNames then
		local names = lck.GetMotifChapterNames()
		for i = 1, #names do
			if names[i].id == chapterId then
				return names[i].name
			end
		end
	end
	local si = _G["SI_ITEMSTYLECHAPTER" .. tostring(chapterId)]
	if si then
		local name = GetString(si)
		if name and name ~= "" then
			return name
		end
	end
	return nil
end

local function emptyResult()
	return {
		ready = true,
		requirements = {},
		missing = {},
		missingReasons = {},
		hasRequirements = false,
		unknownCount = 0,
		knownCount = 0,
	}
end

local function summarize(requirements)
	local result = emptyResult()
	result.requirements = requirements
	result.hasRequirements = #requirements > 0

	for i = 1, #requirements do
		local req = requirements[i]
		if req.known then
			result.knownCount = result.knownCount + 1
		else
			result.unknownCount = result.unknownCount + 1
			result.missing[#result.missing + 1] = req
			if req.reason and req.reason ~= "" then
				result.missingReasons[#result.missingReasons + 1] = req.reason
			end
		end
	end

	result.ready = result.unknownCount == 0
	return result
end

local function priceRequirement(addon, req)
	if not req.itemLink and req.itemId then
		req.itemLink = CCC.Utilities:ItemIdToLink(req.itemId)
	end
	if req.itemLink and addon and addon.PriceProvider then
		req.unitPrice = addon.PriceProvider:GetUnitPrice(req.itemLink)
	end
	if req.itemLink and (not req.itemName or req.itemName == "") then
		req.itemName = CCC.Utilities:GetItemName(req.itemLink)
	end
end

--- Resolve motif chapter item ID via LCK when available.
function K:GetMotifChapterItemId(styleId, chapterId)
	local LCK = K:GetLCK()
	if not LCK or not styleId or not chapterId then
		return nil
	end
	if not LCK.GetMotifItemsFromStyle then
		return nil
	end

	local items = LCK.GetMotifItemsFromStyle(styleId)
	if not items then
		return nil
	end

	if items.chapters and items.chapters[chapterId] then
		return items.chapters[chapterId]
	end

	-- Chapterless / complete-book motifs
	if items.books and items.books[1] then
		return items.books[1]
	end

	return nil
end

function K:IsMotifKnown(styleId, chapterId, pattern)
	local LCK = K:GetLCK()
	if LCK and LCK.GetMotifKnowledgeForCharacter and styleId then
		local state = LCK.GetMotifKnowledgeForCharacter(styleId, chapterId)
		if state == LCK.KNOWLEDGE_KNOWN then
			return true
		end
		if state == LCK.KNOWLEDGE_UNKNOWN then
			return false
		end
		-- INVALID / NODATA → fall through to native
	end

	-- Native fallback uses station pattern index (same arg the crafting UI uses).
	-- May be unreliable away from a crafting station; mark uncertain when false.
	if IsSmithingStyleKnown and styleId and pattern then
		if IsSmithingStyleKnown(styleId, pattern) then
			return true
		end
		return false, true
	end

	-- Unable to determine — do not block the writ.
	return true, true
end

function K:CheckStyle(craftInfo, requirements)
	if not craftInfo or craftInfo.station == CRAFTING_TYPE_JEWELRYCRAFTING then
		return
	end

	local styleId = craftInfo.styleId
	if not styleId or styleId <= 0 then
		return
	end

	local chapterId = K:GetMotifChapter(craftInfo.station, craftInfo.pattern)
	local styleName = craftInfo.styleName or string.format("Style %d", styleId)
	local chapterName = chapterDisplayName(chapterId, K:GetLCK())
	local known, uncertain = K:IsMotifKnown(styleId, chapterId, craftInfo.pattern)
	local itemId = K:GetMotifChapterItemId(styleId, chapterId)

	local displayName = styleName
	if chapterName and chapterName ~= "" then
		displayName = string.format("%s — %s", styleName, chapterName)
	end

	local reason = nil
	if not known then
		if chapterName and chapterName ~= "" then
			reason = zo_strformat(GetString(CCC_KNOW_REASON_STYLE_CHAPTER), styleName, chapterName)
		else
			reason = zo_strformat(GetString(CCC_KNOW_REASON_STYLE), styleName)
		end
	end

	local req = {
		kind = KIND_STYLE,
		kindLabel = GetString(CCC_KNOW_KIND_STYLE),
		name = displayName,
		styleName = styleName,
		chapterName = chapterName,
		chapterId = chapterId,
		styleId = styleId,
		known = known == true,
		uncertain = uncertain == true,
		itemId = itemId,
		itemLink = itemId and CCC.Utilities:ItemIdToLink(itemId) or nil,
		reason = reason,
	}
	priceRequirement(K.addon, req)
	requirements[#requirements + 1] = req
end

function K:IsTraitKnown(station, pattern, traitType)
	if not station or not pattern or not traitType or traitType == ITEM_TRAIT_TYPE_NONE then
		return true
	end
	if not GetSmithingResearchLineTraitInfo then
		return true, true
	end

	local researchLine = K:GetResearchLineIndex(station, pattern)
	local numTraits = select(3, GetSmithingResearchLineInfo(station, researchLine))
	if not numTraits or numTraits <= 0 then
		-- Fallback: traitIndex convention used by WritResolver (traitType + 1)
		local _, _, known = GetSmithingResearchLineTraitInfo(station, researchLine, traitType + 1)
		return known == true
	end

	for traitIndex = 1, numTraits do
		local lineTraitType, _, known = GetSmithingResearchLineTraitInfo(station, researchLine, traitIndex)
		if lineTraitType == traitType then
			return known == true
		end
	end

	return false
end

function K:CheckTrait(craftInfo, requirements)
	if not craftInfo then
		return
	end

	local traitType = craftInfo.traitType
	if not traitType or traitType == ITEM_TRAIT_TYPE_NONE then
		return
	end

	local traitName = craftInfo.traitName or string.format("Trait %d", traitType)
	local known, uncertain = K:IsTraitKnown(craftInfo.station, craftInfo.pattern, traitType)

	local lineName = nil
	local researchLine = K:GetResearchLineIndex(craftInfo.station, craftInfo.pattern)
	if GetSmithingResearchLineInfo and researchLine then
		lineName = GetSmithingResearchLineInfo(craftInfo.station, researchLine)
		if lineName and lineName ~= "" then
			lineName = zo_strformat(SI_TOOLTIP_ITEM_NAME, lineName)
		end
	end

	local displayName = traitName
	if lineName and lineName ~= "" then
		displayName = string.format("%s — %s", traitName, lineName)
	end

	local reason = nil
	if not known then
		if lineName and lineName ~= "" then
			reason = zo_strformat(GetString(CCC_KNOW_REASON_TRAIT_LINE), traitName, lineName)
		else
			reason = zo_strformat(GetString(CCC_KNOW_REASON_TRAIT), traitName)
		end
	end

	requirements[#requirements + 1] = {
		kind = KIND_TRAIT,
		kindLabel = GetString(CCC_KNOW_KIND_TRAIT),
		name = displayName,
		traitName = traitName,
		lineName = lineName,
		traitType = traitType,
		known = known == true,
		uncertain = uncertain == true,
		-- Traits cannot be purchased; no shopping item.
		reason = reason,
	}
end

--- Find whether a recipe producing resultItemId is known (native recipe lists).
-- Uses GetRecipeInfoFromItemId when available, then scans recipe lists.
-- Matches via GetRecipeInfo resultItemId (works for unknown recipes) and
-- GetRecipeResultItemLink as a fallback.
function K:FindRecipeForResult(resultItemId)
	if not resultItemId or resultItemId <= 0 then
		return nil
	end

	local function pack(listIndex, recipeIndex)
		if not listIndex or not recipeIndex then
			return nil
		end
		local known, recipeName, numIngredients, _, _, _, requiredCraftingStationType, infoResultId =
			GetRecipeInfo(listIndex, recipeIndex)
		local resultLink = GetRecipeResultItemLink and GetRecipeResultItemLink(listIndex, recipeIndex)
		if (not resultLink or resultLink == "") and infoResultId and infoResultId > 0 then
			resultLink = CCC.Utilities:ItemIdToLink(infoResultId)
		end
		local name = nil
		if resultLink and resultLink ~= "" then
			name = CCC.Utilities:GetItemName(resultLink)
		elseif recipeName and recipeName ~= "" then
			name = zo_strformat(SI_TOOLTIP_ITEM_NAME, recipeName)
		end
		local recipeLink = nil
		if GetRecipeInfoItemLink then
			recipeLink = GetRecipeInfoItemLink(listIndex, recipeIndex)
		end
		return {
			known = known == true,
			resultName = name,
			resultLink = resultLink,
			recipeLink = recipeLink,
			listIndex = listIndex,
			recipeIndex = recipeIndex,
			numIngredients = numIngredients or 0,
			requiredCraftingStationType = requiredCraftingStationType,
			resultItemId = (infoResultId and infoResultId > 0) and infoResultId or resultItemId,
		}
	end

	-- Fast path: game maps result itemId → recipe indices (API version dependent).
	if GetRecipeInfoFromItemId then
		local ok, a, b, c = pcall(GetRecipeInfoFromItemId, resultItemId)
		if ok then
			-- Signatures observed in the wild:
			--   craftingStationType, recipeListIndex, recipeIndex
			--   recipeListIndex, recipeIndex
			local listIndex, recipeIndex
			if type(b) == "number" and type(c) == "number" then
				listIndex, recipeIndex = b, c
			elseif type(a) == "number" and type(b) == "number" and c == nil then
				listIndex, recipeIndex = a, b
			end
			local found = pack(listIndex, recipeIndex)
			if found then
				return found
			end
		end
	end

	if not GetNumRecipeLists or not GetRecipeListInfo or not GetRecipeInfo then
		return nil
	end

	local numLists = GetNumRecipeLists()
	for listIndex = 1, numLists do
		local _, numRecipes = GetRecipeListInfo(listIndex)
		for recipeIndex = 1, (numRecipes or 0) do
			local known, _, _, _, _, _, _, infoResultId = GetRecipeInfo(listIndex, recipeIndex)
			local matched = false
			if infoResultId and infoResultId == resultItemId then
				matched = true
			else
				local resultLink = GetRecipeResultItemLink and GetRecipeResultItemLink(listIndex, recipeIndex)
				if resultLink and resultLink ~= "" then
					local id = GetItemLinkItemId and GetItemLinkItemId(resultLink)
					if not id then
						local parts = { ZO_LinkHandler_ParseLink(resultLink) }
						id = tonumber(parts[4])
					end
					matched = (id == resultItemId)
				end
			end
			if matched then
				return pack(listIndex, recipeIndex)
			end
		end
	end

	return nil
end

function K:CheckRecipe(craftInfo, requirements)
	if not craftInfo then
		return
	end

	local resultItemId = craftInfo.recipeResultItemId or craftInfo.provisioningResultItemId
	if not resultItemId or resultItemId <= 0 then
		return
	end

	local LCK = K:GetLCK()
	local recipeItemId = nil
	local known = nil
	local resultName = nil
	local recipeLink = nil

	if LCK and LCK.GetSourceItemIdFromResultItem then
		recipeItemId = LCK.GetSourceItemIdFromResultItem(resultItemId)
		if recipeItemId and recipeItemId > 0 and LCK.GetItemKnowledgeForCharacter then
			local state = LCK.GetItemKnowledgeForCharacter(recipeItemId)
			known = (state == LCK.KNOWLEDGE_KNOWN)
			recipeLink = CCC.Utilities:ItemIdToLink(recipeItemId)
		end
	end

	if known == nil then
		local found = K:FindRecipeForResult(resultItemId)
		if found then
			known = found.known
			resultName = found.resultName
			recipeLink = found.recipeLink or recipeLink
		end
	end

	if (not recipeLink or recipeLink == "") and craftInfo.recipeItemLink then
		recipeLink = craftInfo.recipeItemLink
	end

	if (not recipeItemId or recipeItemId <= 0) and recipeLink and recipeLink ~= "" then
		recipeItemId = GetItemLinkItemId and GetItemLinkItemId(recipeLink)
		if not recipeItemId then
			local parts = { ZO_LinkHandler_ParseLink(recipeLink) }
			recipeItemId = tonumber(parts[4])
		end
	end

	if known == nil then
		-- Cannot determine — skip rather than false-positive block.
		return
	end

	if not resultName then
		resultName = CCC.Utilities:GetItemName(CCC.Utilities:ItemIdToLink(resultItemId))
	end

	local displayName = resultName
	local itemName = nil
	if recipeLink then
		itemName = CCC.Utilities:GetItemName(recipeLink)
		if itemName and itemName ~= "" then
			displayName = itemName
		end
	end

	local reason = nil
	if not known then
		reason = zo_strformat(GetString(CCC_KNOW_REASON_RECIPE), resultName or displayName)
	end

	local req = {
		kind = KIND_RECIPE,
		kindLabel = GetString(CCC_KNOW_KIND_RECIPE),
		name = displayName,
		resultName = resultName,
		itemName = itemName,
		known = known == true,
		itemId = recipeItemId,
		itemLink = recipeLink,
		reason = reason,
	}
	priceRequirement(K.addon, req)
	requirements[#requirements + 1] = req
end

function K:CheckBlueprint(craftInfo, requirements)
	if not craftInfo then
		return
	end

	local planItemId = craftInfo.blueprintItemId or craftInfo.planItemId
	local resultItemId = craftInfo.furnitureResultItemId
	local LCK = K:GetLCK()

	if (not planItemId or planItemId <= 0) and resultItemId and LCK and LCK.GetSourceItemIdFromResultItem then
		planItemId = LCK.GetSourceItemIdFromResultItem(resultItemId)
	end

	if not planItemId or planItemId <= 0 then
		return
	end

	local known = nil
	if LCK and LCK.GetItemKnowledgeForCharacter then
		local state = LCK.GetItemKnowledgeForCharacter(planItemId)
		if state == LCK.KNOWLEDGE_KNOWN then
			known = true
		elseif state == LCK.KNOWLEDGE_UNKNOWN then
			known = false
		end
	end

	if known == nil and IsItemLinkRecipeKnown then
		-- Furnishing plans often report via recipe-known APIs on the plan link.
		local link = CCC.Utilities:ItemIdToLink(planItemId)
		known = IsItemLinkRecipeKnown(link) == true
	end

	if known == nil then
		return
	end

	local planLink = CCC.Utilities:ItemIdToLink(planItemId)
	local displayName = CCC.Utilities:GetItemName(planLink)
	local reason = nil
	if not known then
		reason = zo_strformat(GetString(CCC_KNOW_REASON_BLUEPRINT), displayName)
	end

	local req = {
		kind = KIND_BLUEPRINT,
		kindLabel = GetString(CCC_KNOW_KIND_BLUEPRINT),
		name = displayName,
		known = known == true,
		itemId = planItemId,
		itemLink = planLink,
		reason = reason,
	}
	priceRequirement(K.addon, req)
	requirements[#requirements + 1] = req
end

--- Evaluate knowledge requirements for resolved craftInfo (gear / recipe writs).
-- @return table knowledge result
function K:Evaluate(craftInfo)
	if not K:IsEnabled() or not craftInfo then
		return emptyResult()
	end

	local requirements = {}
	K:CheckStyle(craftInfo, requirements)
	K:CheckTrait(craftInfo, requirements)
	K:CheckRecipe(craftInfo, requirements)
	K:CheckBlueprint(craftInfo, requirements)

	return summarize(requirements)
end

--- Knowledge-only evaluation from a raw Master Writ link (e.g. provisioning).
-- Returns nil when the link is not a writ or has no checkable knowledge fields.
function K:EvaluateWritLink(itemLink)
	if not K:IsEnabled() or not itemLink or itemLink == "" then
		return nil
	end
	if not CCC.Utilities:IsMasterWrit(itemLink) then
		return nil
	end

	local fields = CCC.WritResolver:ParseWritFields(itemLink)
	if not fields then
		return nil
	end

	-- Provisioning heuristic (same as WritResolver): food/drink item ID in Writ1.
	if CCC.WritResolver:IsProvisioningWrit(fields) then
		local craftInfo = {
			isMasterWrit = true,
			isProvisioning = true,
			recipeResultItemId = fields.writ1,
			itemLink = itemLink,
		}
		local knowledge = K:Evaluate(craftInfo)
		if knowledge.hasRequirements then
			return knowledge
		end
	end

	return nil
end
