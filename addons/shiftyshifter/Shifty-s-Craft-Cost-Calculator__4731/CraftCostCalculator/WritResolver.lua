--[[
	WritResolver
	Parses Master Writ item links into the same craftInfo shape used by
	CraftResolver, so MaterialResolver / OwnedMaterials / pricing / UI reuse
	the existing pipeline unchanged.

	Gear writ fields (Writ1–Writ6) are read dynamically from the item link.
	Writ1 → pattern mapping is the only static table: those codes are unique to
	master writs and do not match WEAPONTYPE_* / EQUIP_TYPE_* enums.

	Provisioning writs encode the food/drink result itemId in Writ1; ingredients
	are resolved later via the game recipe APIs (no static recipe database).

	Unsupported professions (Alchemy / Enchanting) return a clear error instead
	of hardcoding reagent/rune data CCC does not have.
]]
CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.WritResolver = CCC.WritResolver or {}
local W = CCC.WritResolver

-- Master writs accept Rubedite/Ancestor Silk/… tier gear. CP150 uses material
-- index 40; CP160 (index 41) costs 10× as many base mats for the same writ.
-- Cost calculations intentionally use CP150 — the cheapest valid completion.
local MASTER_WRIT_CP_LEVEL = 150

-- Writ2 craft-school codes (UESP / WritWorthy).
local WRIT2_HEAVY = 188
local WRIT2_MEDIUM = 190
local WRIT2_WOOD = 192
local WRIT2_LIGHT = 194
local WRIT2_JEWELRY = 255
local WRIT2_ENCHANTING = 207

-- Writ1 alchemy solvent markers.
local WRIT1_POTION = 199
local WRIT1_POISON = 239

--[[
	Writ1 item-type code → { station, pattern, isMediumArmor, displayName }

	Pattern indices match CraftData / LibLazyCrafting / the crafting station UI.
	Only codes that appear on real gear Master Writs are listed.
]]
local WRIT_ITEM_TYPES = {
	-- Blacksmithing weapons
	[53] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 1, displayName = "Axe" },
	[56] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 2, displayName = "Mace" },
	[59] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 3, displayName = "Sword" },
	[68] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 4, displayName = "Battle Axe" },
	[69] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 5, displayName = "Maul" },
	[67] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 6, displayName = "Greatsword" },
	[62] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 7, displayName = "Dagger" },
	-- Blacksmithing heavy armor
	[46] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 8, displayName = "Cuirass" },
	[50] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 9, displayName = "Sabatons" },
	[52] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 10, displayName = "Gauntlets" },
	[44] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 11, displayName = "Helm" },
	[49] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 12, displayName = "Greaves" },
	[47] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 13, displayName = "Pauldron" },
	[48] = { station = CRAFTING_TYPE_BLACKSMITHING, pattern = 14, displayName = "Girdle" },
	-- Clothier light armor (robe = pattern 1, jerkin = 2, …)
	[28] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 1, displayName = "Robe" },
	[75] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 2, displayName = "Jerkin" },
	[32] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 3, displayName = "Shoes" },
	[34] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 4, displayName = "Gloves" },
	[26] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 5, displayName = "Hat" },
	[31] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 6, displayName = "Breeches" },
	[29] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 7, displayName = "Epaulets" },
	[30] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 8, displayName = "Sash" },
	-- Clothier medium armor (leather)
	[37] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 9, isMediumArmor = true, displayName = "Jack" },
	[41] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 10, isMediumArmor = true, displayName = "Boots" },
	[43] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 11, isMediumArmor = true, displayName = "Bracers" },
	[35] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 12, isMediumArmor = true, displayName = "Helmet" },
	[40] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 13, isMediumArmor = true, displayName = "Guards" },
	[38] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 14, isMediumArmor = true, displayName = "Arm Cops" },
	[39] = { station = CRAFTING_TYPE_CLOTHIER, pattern = 15, isMediumArmor = true, displayName = "Belt" },
	-- Woodworking
	[70] = { station = CRAFTING_TYPE_WOODWORKING, pattern = 1, displayName = "Bow" },
	[65] = { station = CRAFTING_TYPE_WOODWORKING, pattern = 2, displayName = "Shield" },
	[72] = { station = CRAFTING_TYPE_WOODWORKING, pattern = 3, displayName = "Inferno Staff" },
	[73] = { station = CRAFTING_TYPE_WOODWORKING, pattern = 4, displayName = "Ice Staff" },
	[74] = { station = CRAFTING_TYPE_WOODWORKING, pattern = 5, displayName = "Lightning Staff" },
	[71] = { station = CRAFTING_TYPE_WOODWORKING, pattern = 6, displayName = "Restoration Staff" },
	-- Jewelry
	[24] = { station = CRAFTING_TYPE_JEWELRYCRAFTING, pattern = 1, displayName = "Ring" },
	[18] = { station = CRAFTING_TYPE_JEWELRYCRAFTING, pattern = 2, displayName = "Necklace" },
}

function W:Init(addon)
	W.addon = addon
end

--- Parse numeric writ fields from an item link (same indexing as TTC / WritWorthy).
-- @return table|nil fields
function W:ParseWritFields(itemLink)
	if not itemLink or itemLink == "" then
		return nil
	end

	local parts = { ZO_LinkHandler_ParseLink(itemLink) }
	local function num(i)
		return tonumber(parts[i]) or 0
	end

	local writReward = num(24)
	local vouchers = 0
	if writReward > 0 then
		-- Same formula TTC uses for voucher count.
		vouchers = math.ceil(writReward / 10000 - 0.5)
	end

	return {
		itemId = num(4),
		writ1 = num(10),
		writ2 = num(11),
		writ3 = num(12),
		writ4 = num(13),
		writ5 = num(14),
		writ6 = num(15),
		writReward = writReward,
		vouchers = vouchers,
	}
end

local function resolveSetName(setId)
	if not setId or setId <= 0 then
		return nil
	end
	if GetItemSetName then
		local name = GetItemSetName(setId)
		if name and name ~= "" then
			return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
		end
	end
	return string.format("Set %d", setId)
end

local function resolveStyleName(styleId)
	if not styleId or styleId <= 0 then
		return nil
	end
	if GetItemStyleName then
		local name = GetItemStyleName(styleId)
		if name and name ~= "" then
			return zo_strformat(SI_TOOLTIP_ITEM_NAME, name)
		end
	end
	return string.format("Style %d", styleId)
end

local function resolveTraitName(traitType)
	if not traitType or traitType == ITEM_TRAIT_TYPE_NONE then
		return nil
	end
	local si = _G["SI_ITEMTRAITTYPE" .. tostring(traitType)]
	if si then
		local name = GetString(si)
		if name and name ~= "" then
			return name
		end
	end
	return string.format("Trait %d", traitType)
end

local function unsupportedMessage(profession, reason)
	return string.format(
		"Master %s Writ is not supported: %s. Gear writs (Blacksmithing, Clothing, Woodworking, Jewelry) are supported.",
		profession,
		reason
	)
end

--- True when writ fields match a Provisioning Master Writ (food/drink result in Writ1).
function W:IsProvisioningWrit(fields)
	if not fields then
		return false
	end
	local w1, w2 = fields.writ1, fields.writ2
	return w1 > 0 and w2 == 0 and fields.writ3 == 0 and fields.writ4 == 0
		and w1 ~= WRIT1_POTION and w1 ~= WRIT1_POISON
end

--- Explain why a non-gear / non-provisioning writ cannot be costed.
function W:ExplainUnsupported(fields)
	local w1, w2 = fields.writ1, fields.writ2

	if w1 == WRIT1_POTION or w1 == WRIT1_POISON then
		return unsupportedMessage(
			"Alchemy",
			"potion/poison reagents and solvents cannot be derived from writ fields alone without a reagent-effect database"
		)
	end

	if w2 == WRIT2_ENCHANTING then
		return unsupportedMessage(
			"Enchanting",
			"glyph rune combinations are not encoded as craftable material lists in the writ link"
		)
	end

	if w1 == 0 and w2 == 0 and fields.writ3 == 0 then
		return "This Master Writ has no craft requirement fields (e.g. holiday/sealed writs without Writ1–Writ6 data)."
	end

	return string.format(
		"Unsupported Master Writ (Writ1=%d, Writ2=%d). Supported: Blacksmithing, Clothing, Woodworking, Jewelry, and Provisioning.",
		w1,
		w2
	)
end

--- Resolve a Provisioning Master Writ into craftInfo (ingredients resolved later).
-- @return table|nil craftInfo, string|nil error
function W:ResolveProvisioning(itemLink, fields)
	fields = fields or W:ParseWritFields(itemLink)
	if not fields or not W:IsProvisioningWrit(fields) then
		return nil, nil
	end

	local resultItemId = fields.writ1
	local resultLink = CCC.Utilities:ItemIdToLink(resultItemId)
	local requiredItemName = CCC.Utilities:GetItemName(resultLink)

	local writDescription = nil
	if GenerateMasterWritBaseText then
		local baseText = GenerateMasterWritBaseText(itemLink)
		if baseText and baseText ~= "" then
			writDescription = baseText
		end
	end

	return {
		itemLink = itemLink,
		station = CRAFTING_TYPE_PROVISIONING,
		isMasterWrit = true,
		isProvisioning = true,
		recipeResultItemId = resultItemId,
		provisioningResultItemId = resultItemId,
		requiredItemName = requiredItemName,
		resultItemLink = resultLink,
		vouchers = fields.vouchers,
		writItemType = fields.writ1,
		writCraftType = fields.writ2,
		writDescription = writDescription,
	}
end

--- Validate Writ2 against the expected school for a mapped Writ1 entry.
local function schoolMatches(entry, writ2)
	local station = entry.station
	if station == CRAFTING_TYPE_JEWELRYCRAFTING then
		-- Jewelry uses 255; tolerate 0 on older/odd links.
		return writ2 == WRIT2_JEWELRY or writ2 == 0
	end
	if station == CRAFTING_TYPE_BLACKSMITHING then
		return writ2 == WRIT2_HEAVY
	end
	if station == CRAFTING_TYPE_CLOTHIER then
		if entry.isMediumArmor then
			return writ2 == WRIT2_MEDIUM
		end
		return writ2 == WRIT2_LIGHT
	end
	if station == CRAFTING_TYPE_WOODWORKING then
		return writ2 == WRIT2_WOOD
	end
	return false
end

--- Resolve a Master Writ link into craftInfo.
-- @return table|nil craftInfo, string|nil error
function W:Resolve(itemLink)
	if not CCC.Utilities:IsMasterWrit(itemLink) then
		return nil, "Item is not a Master Writ."
	end

	local fields = W:ParseWritFields(itemLink)
	if not fields then
		return nil, "Could not parse Master Writ link."
	end

	local entry = WRIT_ITEM_TYPES[fields.writ1]
	if not entry then
		local provisioningInfo, provisioningErr = W:ResolveProvisioning(itemLink, fields)
		if provisioningInfo then
			return provisioningInfo
		end
		if provisioningErr then
			return nil, provisioningErr
		end
		return nil, W:ExplainUnsupported(fields)
	end

	-- Jewelry shares Writ1 codes 18/24; require jewelry Writ2 when present.
	if entry.station == CRAFTING_TYPE_JEWELRYCRAFTING and fields.writ2 ~= 0 and fields.writ2 ~= WRIT2_JEWELRY then
		return nil, W:ExplainUnsupported(fields)
	end

	if fields.writ2 ~= 0 and not schoolMatches(entry, fields.writ2) then
		-- Still allow known item types if Writ2 is an unexpected level variant;
		-- UESP notes some Writ2 values may encode level. Fall through with a
		-- note only when the school is clearly wrong for jewelry vs gear.
		if entry.station ~= CRAFTING_TYPE_JEWELRYCRAFTING
			and (fields.writ2 == WRIT2_JEWELRY or fields.writ2 == WRIT2_ENCHANTING) then
			return nil, W:ExplainUnsupported(fields)
		end
	end

	local quality = fields.writ3
	if quality < ITEM_FUNCTIONAL_QUALITY_NORMAL or quality > ITEM_FUNCTIONAL_QUALITY_LEGENDARY then
		return nil, string.format("Master Writ has invalid quality code %d.", quality)
	end

	local styleId = fields.writ6
	if entry.station ~= CRAFTING_TYPE_JEWELRYCRAFTING and (not styleId or styleId == 0) then
		return nil, "Master Writ is missing a style requirement; cannot calculate style material."
	end

	local traitType = fields.writ5 or ITEM_TRAIT_TYPE_NONE
	local traitIndex = traitType + 1

	local setId = fields.writ4 or 0
	local setName = resolveSetName(setId)
	local styleName = resolveStyleName(styleId)
	local traitName = resolveTraitName(traitType)

	local data = CCC.CraftData
	local materialIndex = data:FindMatIndex(MASTER_WRIT_CP_LEVEL, true)
	local materialQuantity = data:GetMaterialQuantity(entry.station, entry.pattern, materialIndex)
	if not materialQuantity then
		return nil, "Could not compute material quantity for this Master Writ."
	end

	local requiredItemName = entry.displayName
	local writDescription = nil
	if GenerateMasterWritBaseText then
		local baseText = GenerateMasterWritBaseText(itemLink)
		if baseText and baseText ~= "" then
			writDescription = baseText
		end
	end

	return {
		itemLink = itemLink,
		station = entry.station,
		pattern = entry.pattern,
		isCP = true,
		level = MASTER_WRIT_CP_LEVEL,
		styleId = styleId,
		styleName = styleName,
		traitType = traitType,
		traitIndex = traitIndex,
		traitName = traitName,
		quality = quality,
		setId = setId,
		setName = setName,
		materialIndex = materialIndex,
		materialQuantity = materialQuantity,
		armorType = entry.isMediumArmor and ARMORTYPE_MEDIUM or ARMORTYPE_NONE,
		isMediumArmor = entry.isMediumArmor == true,
		-- Writ-specific metadata for UI
		isMasterWrit = true,
		writItemType = fields.writ1,
		writCraftType = fields.writ2,
		vouchers = fields.vouchers,
		requiredItemName = requiredItemName,
		writDescription = writDescription,
	}
end
