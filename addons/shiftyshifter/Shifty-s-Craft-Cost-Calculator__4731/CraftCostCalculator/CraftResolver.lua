--[[
	CraftResolver
	Converts an item link into craft parameters (station, pattern, level, style, trait, quality).

	Finished gear uses ESO item-link APIs. Master Writs are delegated to WritResolver.
	No station interaction required.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.CraftResolver = CCC.CraftResolver or {}
local R = CCC.CraftResolver

function R:Init(addon)
	R.addon = addon
end

local function getArmorPattern(itemLink, weight)
	local data = CCC.CraftData
	local equipType = GetItemLinkEquipType(itemLink)
	local base = data.EQUIP_PATTERN_BASE[equipType]
	if not base then
		return nil
	end

	if weight == ARMORTYPE_NONE then
		-- Jewelry
		return base
	end

	local patternId = base
	if weight == ARMORTYPE_LIGHT then
		-- Robe stays on base chest pattern (1); all other light pieces shift +1 (jerkin=2, …)
		if not (IsItemLinkRobe and IsItemLinkRobe(itemLink)) then
			patternId = patternId + 1
		end
	elseif weight == ARMORTYPE_MEDIUM then
		patternId = patternId + 8
	elseif weight == ARMORTYPE_HEAVY then
		patternId = patternId + 7
	end
	return patternId
end

--- Resolve craft parameters from an item link (finished gear or Master Writ).
-- @return table|nil craftInfo, string|nil error
function R:Resolve(itemLink)
	if CCC.Utilities:IsMasterWrit(itemLink) then
		return CCC.WritResolver:Resolve(itemLink)
	end

	if not CCC.Utilities:IsCraftableGear(itemLink) then
		return nil, "Item is not craftable gear or a supported Master Writ."
	end

	local data = CCC.CraftData
	local weight = GetItemLinkArmorType(itemLink)
	local station
	local pattern

	local equipType = GetItemLinkEquipType(itemLink)
	if equipType == EQUIP_TYPE_RING or equipType == EQUIP_TYPE_NECK then
		station = CRAFTING_TYPE_JEWELRYCRAFTING
		pattern = getArmorPattern(itemLink, ARMORTYPE_NONE)
	elseif weight == ARMORTYPE_NONE then
		local weaponType = GetItemLinkWeaponType(itemLink)
		local map = data.WEAPON_PATTERNS[weaponType]
		if not map then
			return nil, "Unsupported weapon type."
		end
		station = map[1]
		pattern = map[2]
	else
		if weight == ARMORTYPE_HEAVY then
			station = CRAFTING_TYPE_BLACKSMITHING
		elseif weight == ARMORTYPE_LIGHT or weight == ARMORTYPE_MEDIUM then
			station = CRAFTING_TYPE_CLOTHIER
		else
			return nil, "Unsupported armor type."
		end
		pattern = getArmorPattern(itemLink, weight)
	end

	if not station or not pattern then
		return nil, "Could not determine crafting pattern."
	end

	local cp = GetItemLinkRequiredChampionPoints(itemLink) or 0
	local isCP = cp > 0
	local level = isCP and cp or (GetItemLinkRequiredLevel(itemLink) or 1)

	local styleId = GetItemLinkItemStyle(itemLink)
	if (not styleId or styleId == 0) and station ~= CRAFTING_TYPE_JEWELRYCRAFTING then
		return nil, "Item has no style; cannot calculate style material."
	end

	local traitType = GetItemLinkTraitInfo(itemLink) or ITEM_TRAIT_TYPE_NONE
	-- Smithing trait index is 1 (none) + ItemTraitType
	local traitIndex = traitType + 1

	local quality = GetItemLinkFunctionalQuality(itemLink) or ITEM_FUNCTIONAL_QUALITY_NORMAL
	local _, setName, _, _, _, setId = GetItemLinkSetInfo(itemLink, false)

	local materialIndex = data:FindMatIndex(level, isCP)
	local materialQuantity = data:GetMaterialQuantity(station, pattern, materialIndex)
	if not materialQuantity then
		return nil, "Could not compute material quantity for this item."
	end

	-- Applied glyph: item-link EnchantId is the glyph itemId (UESP).
	-- GetItemLinkAppliedEnchantId may return a glyph itemId or an enchant
	-- ability id depending on client data; GlyphResolver accepts either.
	local linkParts = {ZO_LinkHandler_ParseLink(itemLink)}
	local linkEnchantId = tonumber(linkParts[7]) or 0
	local glyphSubtype = tonumber(linkParts[8]) or 0
	local glyphLevel = tonumber(linkParts[9]) or 0

	local glyphItemId = nil
	local enchantAbilityId = nil

	if GetItemLinkAppliedEnchantId then
		local appliedEnchantId = GetItemLinkAppliedEnchantId(itemLink) or 0
		-- Skip default-only loot enchants (Applied == 0): those are not crafted glyphs.
		if appliedEnchantId > 0 then
			glyphItemId = linkEnchantId > 0 and linkEnchantId or appliedEnchantId
			enchantAbilityId = appliedEnchantId
			if linkEnchantId == 0 then
				glyphSubtype = 0
				glyphLevel = 0
			end
		end
	elseif linkEnchantId > 0 then
		-- Older clients without AppliedEnchantId: use link fields.
		glyphItemId = linkEnchantId
	end

	return {
		itemLink = itemLink,
		station = station,
		pattern = pattern,
		isCP = isCP,
		level = level,
		styleId = styleId,
		traitType = traitType,
		traitIndex = traitIndex,
		quality = quality,
		setId = setId or 0,
		setName = setName,
		materialIndex = materialIndex,
		materialQuantity = materialQuantity,
		armorType = weight,
		isMediumArmor = (weight == ARMORTYPE_MEDIUM),
		glyphItemId = glyphItemId,
		glyphSubtype = glyphSubtype > 0 and glyphSubtype or nil,
		glyphLevel = glyphLevel > 0 and glyphLevel or nil,
		enchantAbilityId = enchantAbilityId,
	}
end
