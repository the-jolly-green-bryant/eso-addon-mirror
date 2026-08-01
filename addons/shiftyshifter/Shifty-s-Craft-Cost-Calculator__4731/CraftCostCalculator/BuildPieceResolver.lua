--[[
	BuildPieceResolver
	Converts a normalized CCC export gear piece into craftInfo for MaterialResolver.

	Does NOT calculate costs — only maps slot / weight / weapon / trait / level
	into the same craftInfo shape CraftResolver produces for item links.
]]

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.BuildPieceResolver = CCC.BuildPieceResolver or {}
local R = CCC.BuildPieceResolver

-- Default motif when export omits style (guides rarely include it).
-- Style mats are a tiny part of total cost; Breton keeps ResolveLocal happy.
local DEFAULT_STYLE_ID = 1 -- Breton

local SLOT_TO_EQUIP = {
	head = EQUIP_TYPE_HEAD,
	shoulders = EQUIP_TYPE_SHOULDERS,
	chest = EQUIP_TYPE_CHEST,
	hands = EQUIP_TYPE_HAND,
	belt = EQUIP_TYPE_WAIST,
	legs = EQUIP_TYPE_LEGS,
	feet = EQUIP_TYPE_FEET,
	neck = EQUIP_TYPE_NECK,
	ring1 = EQUIP_TYPE_RING,
	ring2 = EQUIP_TYPE_RING,
}

local WEAPON_TYPE_MAP = {
	axe = WEAPONTYPE_AXE,
	mace = WEAPONTYPE_HAMMER,
	sword = WEAPONTYPE_SWORD,
	battleAxe = WEAPONTYPE_TWO_HANDED_AXE,
	maul = WEAPONTYPE_TWO_HANDED_HAMMER,
	greatsword = WEAPONTYPE_TWO_HANDED_SWORD,
	dagger = WEAPONTYPE_DAGGER,
	bow = WEAPONTYPE_BOW,
	shield = WEAPONTYPE_SHIELD,
	fireStaff = WEAPONTYPE_FIRE_STAFF,
	frostStaff = WEAPONTYPE_FROST_STAFF,
	lightningStaff = WEAPONTYPE_LIGHTNING_STAFF,
	healingStaff = WEAPONTYPE_HEALING_STAFF,
}

local ARMOR_WEIGHT_MAP = {
	light = ARMORTYPE_LIGHT,
	medium = ARMORTYPE_MEDIUM,
	heavy = ARMORTYPE_HEAVY,
}

local WEAPON_SLOTS = {
	mainHand = true,
	offHand = true,
	backupMainHand = true,
	backupOffHand = true,
}

local JEWELRY_SLOTS = {
	neck = true,
	ring1 = true,
	ring2 = true,
}

local ARMOR_SLOTS = {
	head = true,
	shoulders = true,
	chest = true,
	hands = true,
	belt = true,
	legs = true,
	feet = true,
}

local QUALITY_NAMES = {
	[1] = "White",
	[2] = "Green",
	[3] = "Blue",
	[4] = "Purple",
	[5] = "Gold",
}

function R:Init(addon)
	R.addon = addon
	R.traitByName = nil
	R.styleByName = nil
end

function R:BuildTraitLookup()
	if R.traitByName then
		return R.traitByName
	end

	local map = {}
	-- Cover the full ITEM_TRAIT_TYPE range used by the client.
	for traitType = 0, 64 do
		local name
		if SI_ITEMTRAITTYPE0 then
			name = GetString(SI_ITEMTRAITTYPE0 + traitType)
		else
			local sid = _G["SI_ITEMTRAITTYPE" .. tostring(traitType)]
			if sid then
				name = GetString(sid)
			end
		end
		if name and name ~= "" and not name:find("ITEMTRAITTYPE", 1, true) then
			map[zo_strlower(name)] = traitType
		end
	end

	-- Common English aliases if localization string lookup fails mid-load.
	local aliases = {
		divines = ITEM_TRAIT_TYPE_ARMOR_DIVINES,
		impenetrable = ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE,
		reinforced = ITEM_TRAIT_TYPE_ARMOR_REINFORCED,
		sturdy = ITEM_TRAIT_TYPE_ARMOR_STURDY,
		["well-fitted"] = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
		["well fitted"] = ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED,
		powered = ITEM_TRAIT_TYPE_WEAPON_POWERED,
		charged = ITEM_TRAIT_TYPE_WEAPON_CHARGED,
		precise = ITEM_TRAIT_TYPE_WEAPON_PRECISE,
		decisive = ITEM_TRAIT_TYPE_WEAPON_DECISIVE,
		defending = ITEM_TRAIT_TYPE_WEAPON_DEFENDING,
		sharpened = ITEM_TRAIT_TYPE_WEAPON_SHARPENED,
		weighted = ITEM_TRAIT_TYPE_WEAPON_WEIGHTED,
		bloodthirsty = ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY,
		arcane = ITEM_TRAIT_TYPE_JEWELRY_ARCANE,
		healthy = ITEM_TRAIT_TYPE_JEWELRY_HEALTHY,
		robust = ITEM_TRAIT_TYPE_JEWELRY_ROBUST,
		harmony = ITEM_TRAIT_TYPE_JEWELRY_HARMONY,
		triune = ITEM_TRAIT_TYPE_JEWELRY_TRIUNE,
		protecting = ITEM_TRAIT_TYPE_JEWELRY_PROTECTING,
		swift = ITEM_TRAIT_TYPE_JEWELRY_SWIFT,
	}
	for k, v in pairs(aliases) do
		if v and not map[k] then
			map[k] = v
		end
	end

	R.traitByName = map
	return map
end

function R:ResolveTraitType(traitName, category)
	if not traitName or traitName == "" then
		return ITEM_TRAIT_TYPE_NONE or 0
	end

	local map = R:BuildTraitLookup()
	local key = zo_strlower(traitName)

	-- Traits that exist on multiple gear categories must use category context first.
	if key == "infused" then
		if category == "jewelry" then
			return ITEM_TRAIT_TYPE_JEWELRY_INFUSED
		elseif category == "weapon" then
			return ITEM_TRAIT_TYPE_WEAPON_INFUSED
		end
		return ITEM_TRAIT_TYPE_ARMOR_INFUSED
	end
	if key == "nirnhoned" then
		if category == "weapon" then
			return ITEM_TRAIT_TYPE_WEAPON_NIRNHONED
		end
		return ITEM_TRAIT_TYPE_ARMOR_NIRNHONED
	end
	if key == "training" then
		if category == "weapon" then
			return ITEM_TRAIT_TYPE_WEAPON_TRAINING
		end
		return ITEM_TRAIT_TYPE_ARMOR_TRAINING
	end
	if key == "intricate" then
		if category == "jewelry" then
			return ITEM_TRAIT_TYPE_JEWELRY_INTRICATE
		elseif category == "weapon" then
			return ITEM_TRAIT_TYPE_WEAPON_INTRICATE
		end
		return ITEM_TRAIT_TYPE_ARMOR_INTRICATE
	end

	local traitType = map[key]
	if traitType then
		return traitType
	end

	return nil
end

function R:GetArmorPattern(equipType, weight)
	local data = CCC.CraftData
	local base = data.EQUIP_PATTERN_BASE[equipType]
	if not base then
		return nil
	end

	if weight == ARMORTYPE_NONE then
		return base
	end

	local patternId = base
	if weight == ARMORTYPE_LIGHT then
		-- Export has no robe flag — assume jerkin/non-robe (+1) for all light pieces.
		patternId = patternId + 1
	elseif weight == ARMORTYPE_MEDIUM then
		patternId = patternId + 8
	elseif weight == ARMORTYPE_HEAVY then
		patternId = patternId + 7
	end
	return patternId
end

function R:ClassifyPiece(piece)
	local slot = piece.slot
	if JEWELRY_SLOTS[slot] or piece.isJewelry then
		return "jewelry"
	end
	if WEAPON_SLOTS[slot] or piece.weaponType then
		return "weapon"
	end
	if ARMOR_SLOTS[slot] or piece.armorWeight then
		return "armor"
	end
	return "unknown"
end

--- @return craftInfo|nil, errorMessage|nil, warningsTable
function R:Resolve(piece)
	local warnings = {}
	local category = R:ClassifyPiece(piece)
	local data = CCC.CraftData

	local station
	local pattern
	local armorType = ARMORTYPE_NONE
	local isMediumArmor = false

	if category == "jewelry" then
		station = CRAFTING_TYPE_JEWELRYCRAFTING
		local equipType = SLOT_TO_EQUIP[piece.slot]
		if not equipType then
			return nil, "Unsupported jewelry slot.", warnings
		end
		pattern = R:GetArmorPattern(equipType, ARMORTYPE_NONE)
	elseif category == "weapon" then
		if not piece.weaponType then
			return nil, "Missing weapon type.", warnings
		end
		local weaponType = WEAPON_TYPE_MAP[piece.weaponType]
		if not weaponType then
			return nil, "Unsupported weapon type: " .. tostring(piece.weaponType), warnings
		end
		local map = data.WEAPON_PATTERNS[weaponType]
		if not map then
			return nil, "Unsupported weapon type.", warnings
		end
		station = map[1]
		pattern = map[2]
	elseif category == "armor" then
		if not piece.armorWeight then
			return nil, "Missing armor weight.", warnings
		end
		armorType = ARMOR_WEIGHT_MAP[piece.armorWeight]
		if not armorType then
			return nil, "Unsupported armor weight: " .. tostring(piece.armorWeight), warnings
		end
		local equipType = SLOT_TO_EQUIP[piece.slot]
		if not equipType then
			return nil, "Unsupported armor slot.", warnings
		end
		if armorType == ARMORTYPE_HEAVY then
			station = CRAFTING_TYPE_BLACKSMITHING
		else
			station = CRAFTING_TYPE_CLOTHIER
		end
		isMediumArmor = (armorType == ARMORTYPE_MEDIUM)
		pattern = R:GetArmorPattern(equipType, armorType)
	else
		return nil, "Could not determine item type for this slot.", warnings
	end

	if not station or not pattern then
		return nil, "Could not determine crafting pattern.", warnings
	end

	local isCP = piece.isChampionPoint == true
	local level = piece.level or (isCP and 160 or 50)
	if piece.level == nil and isCP then
		warnings[#warnings + 1] = "Assumed CP160."
	end

	local quality = piece.quality
	if not quality or quality < 1 or quality > 5 then
		quality = ITEM_FUNCTIONAL_QUALITY_LEGENDARY or 5
		warnings[#warnings + 1] = "Assumed Legendary quality."
	end

	local traitType = R:ResolveTraitType(piece.trait, category)
	if traitType == nil then
		return nil, "Unknown trait: " .. tostring(piece.trait or "?"), warnings
	end
	local traitIndex = traitType + 1

	local styleId = 0
	if station ~= CRAFTING_TYPE_JEWELRYCRAFTING then
		styleId = DEFAULT_STYLE_ID
		if piece.style and piece.style ~= "" then
			-- Name → style id lookup is best-effort; fall back to default.
			warnings[#warnings + 1] = "Style name ignored; using default motif for materials."
		else
			warnings[#warnings + 1] = "No style in export; assumed Breton motif."
		end
	end

	local materialIndex = data:FindMatIndex(level, isCP)
	local materialQuantity = data:GetMaterialQuantity(station, pattern, materialIndex)
	if not materialQuantity then
		return nil, "Could not compute material quantity.", warnings
	end

	local craftInfo = {
		itemLink = nil,
		station = station,
		pattern = pattern,
		isCP = isCP,
		level = level,
		styleId = styleId,
		traitType = traitType,
		traitIndex = traitIndex,
		quality = quality,
		setId = 0,
		setName = piece.setName,
		materialIndex = materialIndex,
		materialQuantity = materialQuantity,
		armorType = armorType,
		isMediumArmor = isMediumArmor,
		fromBuildExport = true,
		enchantmentName = piece.enchantment,
	}

	return craftInfo, nil, warnings
end

function R:GetSlotLabel(slot)
	local labels = {
		head = "Head",
		shoulders = "Shoulders",
		chest = "Chest",
		hands = "Hands",
		belt = "Belt",
		legs = "Legs",
		feet = "Feet",
		neck = "Necklace",
		ring1 = "Ring 1",
		ring2 = "Ring 2",
		mainHand = "Main Hand",
		offHand = "Off Hand",
		backupMainHand = "Backbar Main",
		backupOffHand = "Backbar Off",
	}
	return labels[slot] or slot or "?"
end

function R:GetQualityLabel(quality)
	return QUALITY_NAMES[quality] or tostring(quality or "?")
end

function R:GetCategoryLabel(category)
	if category == "weapon" then
		return "Weapon"
	elseif category == "armor" then
		return "Armor"
	elseif category == "jewelry" then
		return "Jewelry"
	end
	return "—"
end

function R:GetItemTypeLabel(piece, category)
	if category == "weapon" then
		return piece.weaponType or "Weapon"
	elseif category == "jewelry" then
		return "Jewelry"
	elseif category == "armor" then
		return "Armor"
	end
	return "—"
end

function R:GetWeightLabel(piece, category)
	if category == "armor" then
		local w = piece.armorWeight
		if w then
			return w:sub(1, 1):upper() .. w:sub(2)
		end
	elseif category == "jewelry" then
		return "Jewelry"
	elseif category == "weapon" then
		return piece.weaponType or "—"
	end
	return "—"
end
