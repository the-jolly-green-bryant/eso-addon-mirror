--[[
	GlyphResolver
	Resolves potency / essence / aspect runes for an enchantment on gear.

	Sources:
	  - Item link EnchantId (glyph itemId) + EnchantSubType/Level → quality & potency
	  - Build export enchantment name + piece level/quality
	  - LibLazyCrafting helpers when present (soft dependency)

	Returns material rows (category "glyph") or a warning string; never fails
	the parent equipment calculation.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.GlyphResolver = CCC.GlyphResolver or {}
local R = CCC.GlyphResolver

local CATEGORY_GLYPH = "glyph"

function R:Init(addon)
	R.addon = addon
	R.nameLookup = nil
end

function R:IsEnabled()
	local settings = R.addon and R.addon.Settings
	return not settings or settings.includeGlyphCosts ~= false
end

local function normalizeKey(name)
	if not name or name == "" then
		return nil
	end
	local s = zo_strformat("<<1>>", name)
	s = zo_strlower(zo_strtrim(s))
	s = s:gsub("^glyph of%s+", "")
	-- Strip common potency-quality adjectives from full glyph names.
	s = s:gsub("^truly%s+superb%s+", "")
	s = s:gsub("^truly%s+monumental%s+", "")
	s = s:gsub("^trifling%s+", "")
	s = s:gsub("^inferior%s+", "")
	s = s:gsub("^petty%s+", "")
	s = s:gsub("^slight%s+", "")
	s = s:gsub("^minor%s+", "")
	s = s:gsub("^moderate%s+", "")
	s = s:gsub("^average%s+", "")
	s = s:gsub("^strong%s+", "")
	s = s:gsub("^major%s+", "")
	s = s:gsub("^greater%s+", "")
	s = s:gsub("^grand%s+", "")
	s = s:gsub("^splendid%s+", "")
	s = s:gsub("^monumental%s+", "")
	s = s:gsub("^superb%s+", "")
	s = s:gsub("%s+enchantment$", "")
	s = zo_strtrim(s)
	if s == "" or s == "—" or s == "-" or s == "none" or s == "n/a" then
		return nil
	end
	return s
end

function R:BuildNameLookup()
	if R.nameLookup then
		return R.nameLookup
	end

	local map = {}
	local data = CCC.GlyphData
	for i = 1, #data.GLYPH_INFO do
		local row = data.GLYPH_INFO[i]
		local subName = normalizeKey(row[5])
		local addName = normalizeKey(row[6])
		if subName then
			map[subName] = {parity = -1, essenceId = row[9], glyphItemId = row[3], label = row[5]}
		end
		if addName then
			map[addName] = {parity = 1, essenceId = row[9], glyphItemId = row[4], label = row[6]}
		end
	end

	for alias, target in pairs(data.NAME_ALIASES) do
		local key = normalizeKey(alias)
		local targetKey = normalizeKey(target)
		if key and targetKey and map[targetKey] then
			map[key] = map[targetKey]
		end
	end

	R.nameLookup = map
	return map
end

--- Snap gear level to nearest craftable potency tier; return potency itemId.
function R:FindPotencyItemId(isCP, level, parity)
	local data = CCC.GlyphData
	local calculatedKey = level or 1
	if isCP then
		calculatedKey = calculatedKey + 50
	end

	local levelToFind
	for i = 1, #data.LEVEL_LEAPS do
		if calculatedKey <= data.LEVEL_LEAPS[i].Key then
			levelToFind = data.LEVEL_LEAPS[i]
			break
		end
	end
	if not levelToFind then
		levelToFind = data.LEVEL_LEAPS[#data.LEVEL_LEAPS]
	end

	for i = 1, #data.POTENCY_LEVELS do
		local row = data.POTENCY_LEVELS[i]
		if row.lvl == levelToFind.lvl and row.cp == levelToFind.cp and row[1] == parity then
			return row[2]
		end
	end
	return nil
end

function R:GetAspectItemId(quality)
	quality = quality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY or 5
	if quality < 1 then
		quality = 1
	elseif quality > 5 then
		quality = 5
	end
	return CCC.GlyphData.ASPECT_BY_QUALITY[quality]
end

--- Look up essence + parity from a glyph itemId (item-link EnchantId).
function R:GetEssenceForGlyphItemId(glyphItemId)
	if not glyphItemId or glyphItemId <= 0 then
		return nil
	end

	-- Soft: LibLazyCrafting exposes the same tables.
	if LibLazyCrafting and LibLazyCrafting.getGlyphInfo then
		local glyphInfo = LibLazyCrafting.getGlyphInfo()
		if type(glyphInfo) == "table" then
			for i = 1, #glyphInfo do
				local row = glyphInfo[i]
				if row[3] == glyphItemId then
					return -1, row[9], row[5]
				elseif row[4] == glyphItemId then
					return 1, row[9], row[6]
				end
			end
		end
	end

	local info = CCC.GlyphData.GLYPH_INFO
	for i = 1, #info do
		local row = info[i]
		if row[3] == glyphItemId then
			return -1, row[9], row[5]
		elseif row[4] == glyphItemId then
			return 1, row[9], row[6]
		end
	end
	return nil
end

--- Look up essence + parity from enchant ability id (GetItemLinkAppliedEnchantId style).
function R:GetEssenceForEnchantAbilityId(enchantAbilityId)
	if not enchantAbilityId or enchantAbilityId <= 0 then
		return nil
	end

	if LibLazyCrafting and LibLazyCrafting.EnchantAttributesToGlyphIds then
		-- Ability path still needs level/quality for full IDs; essence only here.
	end

	local info = CCC.GlyphData.GLYPH_INFO
	for i = 1, #info do
		local row = info[i]
		if row[1] == enchantAbilityId then
			return -1, row[9], row[5], row[3]
		elseif row[2] == enchantAbilityId then
			return 1, row[9], row[6], row[4]
		end
	end
	return nil
end

function R:MatchEnchantmentName(name)
	local key = normalizeKey(name)
	if not key then
		return nil
	end

	local lookup = R:BuildNameLookup()
	if lookup[key] then
		return lookup[key]
	end

	-- Soft contains match (longest label wins) for guide wording variants.
	local best
	local bestLen = 0
	for labelKey, entry in pairs(lookup) do
		if key:find(labelKey, 1, true) or labelKey:find(key, 1, true) then
			local len = #labelKey
			if len > bestLen then
				best = entry
				bestLen = len
			end
		end
	end
	return best
end

local function makeRuneMaterial(itemId)
	if not itemId or itemId <= 0 then
		return nil
	end
	return {
		itemId = itemId,
		itemLink = CCC.Utilities:ItemIdToLink(itemId),
		quantity = 1,
		category = CATEGORY_GLYPH,
	}
end

--- Build the three rune materials from resolved ids.
-- @return materials|nil, warning|nil
function R:MaterialsFromRuneIds(potencyId, essenceId, aspectId, glyphLabel)
	if not potencyId or not essenceId or not aspectId then
		return nil, string.format(
			"Incomplete rune mapping for %s (potency=%s essence=%s aspect=%s).",
			glyphLabel or "glyph",
			tostring(potencyId),
			tostring(essenceId),
			tostring(aspectId)
		)
	end

	local materials = {}
	local potency = makeRuneMaterial(potencyId)
	local essence = makeRuneMaterial(essenceId)
	local aspect = makeRuneMaterial(aspectId)
	if not potency or not essence or not aspect then
		return nil, "Could not build rune item links for glyph."
	end
	materials[#materials + 1] = potency
	materials[#materials + 1] = essence
	materials[#materials + 1] = aspect
	return materials
end

--- Prefer LLC when available for glyph item links.
function R:ResolveViaLLCGlyphLink(glyphLink)
	if not LibLazyCrafting or not LibLazyCrafting.getComponentRunesForGlyphItemLink then
		return nil
	end
	if not glyphLink or glyphLink == "" then
		return nil
	end

	local ok, response = pcall(LibLazyCrafting.getComponentRunesForGlyphItemLink, glyphLink)
	if not ok or type(response) ~= "table" then
		return nil
	end
	if not response.potencyItemID or not response.essenceItemID or not response.aspectItemID then
		return nil
	end
	return R:MaterialsFromRuneIds(
		response.potencyItemID,
		response.essenceItemID,
		response.aspectItemID,
		CCC.Utilities:GetItemName(glyphLink)
	)
end

--- Resolve from an already-built glyph item link (with subtype/level).
function R:ResolveFromGlyphLink(glyphLink)
	if not glyphLink or glyphLink == "" then
		return nil, "No glyph link."
	end

	local viaLlc, llcWarn = R:ResolveViaLLCGlyphLink(glyphLink)
	if viaLlc then
		return viaLlc
	end
	if llcWarn then
		-- LLC returned a partial warning; continue with local path.
	end

	local glyphItemId = GetItemLinkItemId(glyphLink)
	local parity, essenceId, label = R:GetEssenceForGlyphItemId(glyphItemId)
	if not essenceId then
		return nil, string.format("Unknown glyph (item %s).", tostring(glyphItemId))
	end

	local quality = GetItemLinkFunctionalQuality(glyphLink) or ITEM_FUNCTIONAL_QUALITY_NORMAL
	local aspectId = R:GetAspectItemId(quality)

	local minLevel, minCP = GetItemLinkGlyphMinLevels(glyphLink)
	local isCP = (minCP and minCP > 0) and true or false
	local level = isCP and minCP or (minLevel or 1)

	-- Some CP glyphs report minLevel=50 with minCP set; prefer CP when present.
	local potencyId = R:FindPotencyItemId(isCP, level, parity)
	return R:MaterialsFromRuneIds(potencyId, essenceId, aspectId, label)
end

--- Resolve from equipment item link fields / APIs.
function R:ResolveFromItemLink(itemLink)
	if not itemLink or itemLink == "" then
		return nil, nil
	end

	local parts = {ZO_LinkHandler_ParseLink(itemLink)}
	local enchantId = tonumber(parts[7]) or 0
	local enchantSubtype = tonumber(parts[8]) or 0
	local enchantLevel = tonumber(parts[9]) or 0

	-- Applied enchant only (ignore default loot enchants that have no glyph item).
	if GetItemLinkAppliedEnchantId then
		local applied = GetItemLinkAppliedEnchantId(itemLink)
		if not applied or applied == 0 then
			if enchantId == 0 then
				return nil, nil -- no enchantment
			end
			-- Link has EnchantId but Applied API says 0 → still try link field
			-- (some crafted preview links only populate the link fields).
		elseif applied > 0 then
			-- Applied id may be glyph itemId (matches link) or ability id.
			local asGlyphParity = R:GetEssenceForGlyphItemId(applied)
			if asGlyphParity then
				enchantId = applied
			else
				local parity, essenceId, label, glyphItemId = R:GetEssenceForEnchantAbilityId(applied)
				if essenceId and glyphItemId then
					-- Fall through using ability-derived glyph item + gear level/quality.
					local quality = GetItemLinkFunctionalQuality(itemLink) or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
					local cp = GetItemLinkRequiredChampionPoints(itemLink) or 0
					local isCP = cp > 0
					local level = isCP and cp or (GetItemLinkRequiredLevel(itemLink) or 1)
					local potencyId = R:FindPotencyItemId(isCP, level, parity)
					local aspectId = R:GetAspectItemId(quality)
					return R:MaterialsFromRuneIds(potencyId, essenceId, aspectId, label)
				end
			end
		end
	end

	if not enchantId or enchantId == 0 then
		return nil, nil
	end

	-- Construct a glyph link preserving potency/quality encoding from the gear link.
	local glyphLink = string.format(
		"|H0:item:%d:%d:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
		enchantId,
		enchantSubtype > 0 and enchantSubtype or 1,
		enchantLevel > 0 and enchantLevel or 1
	)

	local materials, warn = R:ResolveFromGlyphLink(glyphLink)
	if materials then
		return materials
	end

	-- Fallback: gear level + gear quality + glyph item essence.
	local parity, essenceId, label = R:GetEssenceForGlyphItemId(enchantId)
	if not essenceId then
		return nil, warn or string.format("Unsupported enchantment (id %d).", enchantId)
	end

	local quality = GetItemLinkFunctionalQuality(itemLink) or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
	local cp = GetItemLinkRequiredChampionPoints(itemLink) or 0
	local isCP = cp > 0
	local level = isCP and cp or (GetItemLinkRequiredLevel(itemLink) or 1)
	local potencyId = R:FindPotencyItemId(isCP, level, parity)
	local aspectId = R:GetAspectItemId(quality)
	return R:MaterialsFromRuneIds(potencyId, essenceId, aspectId, label)
end

--- Resolve from build-export enchantment name + craftInfo level/quality.
function R:ResolveFromName(enchantmentName, craftInfo)
	local match = R:MatchEnchantmentName(enchantmentName)
	if not match then
		return nil, string.format("Unknown enchantment '%s'.", tostring(enchantmentName))
	end

	local isCP = craftInfo and craftInfo.isCP
	local level = craftInfo and craftInfo.level or (isCP and 160 or 50)
	local quality = craftInfo and craftInfo.quality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY or 5

	if LibLazyCrafting and LibLazyCrafting.EnchantAttributesToGlyphIds and match.glyphItemId then
		-- LLC wants enchant ability id; we have glyph itemId. Use local potency/aspect.
	end

	local potencyId = R:FindPotencyItemId(isCP, level, match.parity)
	local aspectId = R:GetAspectItemId(quality)
	return R:MaterialsFromRuneIds(potencyId, match.essenceId, aspectId, match.label)
end

--- Main entry: append glyph mats for craftInfo when enabled.
-- @return materials (possibly empty), warning|nil
function R:ResolveForCraftInfo(craftInfo)
	if not R:IsEnabled() or not craftInfo then
		return {}, nil
	end

	-- Prefer explicit glyph item + subtype/level from CraftResolver.
	if craftInfo.glyphItemId and craftInfo.glyphItemId > 0 then
		local subtype = craftInfo.glyphSubtype or 0
		local gLevel = craftInfo.glyphLevel or 0
		if subtype > 0 and gLevel > 0 then
			local glyphLink = string.format(
				"|H0:item:%d:%d:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h",
				craftInfo.glyphItemId,
				subtype,
				gLevel
			)
			local mats, warn = R:ResolveFromGlyphLink(glyphLink)
			if mats then
				return mats, nil
			end
			-- Fall through to essence + gear level if glyph link decode failed.
		end

		local parity, essenceId, label = R:GetEssenceForGlyphItemId(craftInfo.glyphItemId)
		if not essenceId and craftInfo.enchantAbilityId then
			parity, essenceId, label = R:GetEssenceForEnchantAbilityId(craftInfo.enchantAbilityId)
		end
		if essenceId then
			local potencyId = R:FindPotencyItemId(craftInfo.isCP, craftInfo.level, parity)
			local aspectId = R:GetAspectItemId(craftInfo.glyphQuality or craftInfo.quality)
			local mats, warn = R:MaterialsFromRuneIds(potencyId, essenceId, aspectId, label)
			return mats or {}, warn
		end
		return {}, string.format("Unknown glyph item %d.", craftInfo.glyphItemId)
	end

	if craftInfo.enchantAbilityId and craftInfo.enchantAbilityId > 0 then
		local parity, essenceId, label = R:GetEssenceForEnchantAbilityId(craftInfo.enchantAbilityId)
		if essenceId then
			local potencyId = R:FindPotencyItemId(craftInfo.isCP, craftInfo.level, parity)
			local aspectId = R:GetAspectItemId(craftInfo.glyphQuality or craftInfo.quality)
			local mats, warn = R:MaterialsFromRuneIds(potencyId, essenceId, aspectId, label)
			return mats or {}, warn
		end
		return {}, string.format("Unsupported enchantment (ability %d).", craftInfo.enchantAbilityId)
	end

	if craftInfo.itemLink then
		local mats, warn = R:ResolveFromItemLink(craftInfo.itemLink)
		if mats then
			return mats, nil
		end
		return {}, warn
	end

	if craftInfo.enchantmentName and craftInfo.enchantmentName ~= "" then
		local mats, warn = R:ResolveFromName(craftInfo.enchantmentName, craftInfo)
		return mats or {}, warn
	end

	return {}, nil
end
