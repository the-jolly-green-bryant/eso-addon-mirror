LibItemSets = { }
local LIS = LibItemSets

local Data = { }
local RawData = { }
LIS.RawData = RawData


--------------------------------------------------------------------------------
-- Bitwise flags
--------------------------------------------------------------------------------

-- Armor weights (bits 1-4)
LIS.ARMOR_WEIGHT_L			= 0x1
LIS.ARMOR_WEIGHT_M			= 0x2
LIS.ARMOR_WEIGHT_H			= 0x4
LIS.ARMOR_WEIGHT_ALL		= 0x7
LIS.ARMOR_WEIGHT_NONE		= 0x0
LIS.ARMOR_WEIGHT_MASK		= 0xF

-- Special set types (bits 5-12)
LIS.SPECIAL_CRAFTABLE		= 0x010
LIS.SPECIAL_ABILITY_WEAPON	= 0x020
LIS.SPECIAL_MONSTER_SET		= 0x040
LIS.SPECIAL_MYTHIC			= 0x080

-- Sourcing classifications (bits 13-20)
LIS.SOURCE_TYPE_OVERLAND	= 0x01000
LIS.SOURCE_TYPE_PVP			= 0x02000
LIS.SOURCE_TYPE_DUNGEON		= 0x04000
LIS.SOURCE_TYPE_TRIAL		= 0x08000
LIS.SOURCE_TYPE_ARENA		= 0x10000
LIS.SOURCE_TYPE_ANTIQUITIES	= 0x20000

-- Miscellanea (bits 21 to 24)
LIS.SET_IS_BIND_ON_EQUIP	= 0x100000
LIS.SET_IS_BIND_ON_PICKUP	= 0x200000
LIS.SET_IS_COLLECTIBLE		= 0x400000


--------------------------------------------------------------------------------
-- Special sourceId values (for future expansion, the valid range is -1 to -15)
--------------------------------------------------------------------------------

LIS.SPECIAL_SOURCE_RANDOM_DUNGEON_REWARD	= -1
LIS.SPECIAL_SOURCE_BATTLEGROUNDS			= -2
LIS.SPECIAL_SOURCE_REWARDS_FOR_THE_WORTHY	= -3
LIS.SPECIAL_SOURCE_ANTIQUITIES				= -4


--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

do
	local SPECIAL_SOURCE_NAMES = {
		[LIS.SPECIAL_SOURCE_RANDOM_DUNGEON_REWARD] = GetString(SI_DUNGEON_FINDER_RANDOM_FILTER_TEXT),
		[LIS.SPECIAL_SOURCE_BATTLEGROUNDS] = GetString(SI_BATTLEGROUND_HUD_HEADER),
		[LIS.SPECIAL_SOURCE_REWARDS_FOR_THE_WORTHY] = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H0:item:145577:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
		[LIS.SPECIAL_SOURCE_ANTIQUITIES] = GetString(SI_MAP_INFO_MODE_ANTIQUITIES),
	}

	function LIS.GetSourceName( sourceId )
		if (sourceId and sourceId > 0) then
			return ZO_CachedStrFormat(SI_ZONE_NAME, GetZoneNameById(sourceId))
		else
			return SPECIAL_SOURCE_NAMES[sourceId] or ""
		end
	end
end

function LIS.GetItemSetInfo( itemSetId )
	local result = itemSetId and Data.sets[itemSetId]
	if (result and result.rawSetName) then
		-- Formatting is required to remove ^ tags from non-English languages,
		-- but it is expensive so do it only when info for that set is requested
		result.setName = ZO_CachedStrFormat(SI_ITEM_SET_NAME_FORMATTER, result.rawSetName)
		result.rawSetName = nil
	end
	return result
end

function LIS.GetNumTraitsRequiredToCraftItemSet( itemSetId )
	local result = itemSetId and Data.sets[itemSetId]
	return result and result.craftTraits or -1
end

function LIS.GetAllItemSetIds( )
	return Data.setIds
end

function LIS.GetCraftableItemSetIds( )
	return Data.setIdsCraftable
end

function LIS.GetCollectibleItemSetIds( )
	return Data.setIdsCollectible
end

function LIS.GetAllItemSetIdsForSource( sourceId )
	return sourceId and Data.setIdsBySource[sourceId] or { }
end

function LIS.GetCraftableItemSetIdsForSource( sourceId )
	local results = { }
	for _, itemSetId in ipairs(LIS.GetAllItemSetIdsForSource(sourceId)) do
		if (Data.sets[itemSetId].craftTraits) then
			table.insert(results, itemSetId)
		end
	end
	return results
end

function LIS.GetCollectibleItemSetIdsForSource( sourceId )
	local results = { }
	for _, itemSetId in ipairs(LIS.GetAllItemSetIdsForSource(sourceId)) do
		if (Data.sets[itemSetId].numCollectiblePieces > 0) then
			table.insert(results, itemSetId)
		end
	end
	return results
end

function LIS.CheckFlag( flags, flagToCheck )
	return flagToCheck ~= 0 and BitAnd(flags, flagToCheck) == flagToCheck
end

function LIS.CheckArmorWeight( flags, flagToCheck )
	return BitAnd(flags, LIS.ARMOR_WEIGHT_MASK) == flagToCheck
end

function LIS.GetItemSetCollectionSlotsMask( itemSetId )
	local result = 0
	for i = 1, GetNumItemSetCollectionPieces(itemSetId) do
		local _, slot = GetItemSetCollectionPieceInfo(itemSetId, i)
		if (IsItemSetCollectionSlotUnlocked(itemSetId, slot)) then
			result = result + Id64ToNumber(slot)
		end
	end
	result = NumberToId64(result)
	return result
end

do
	local names = nil
	local function initialize( )
		names = { }
		for i, itemId in ipairs({
			43564, -- Hat
			43563, -- Helmet
			43562, -- Helm
			43547, -- Epaulets
			43554, -- Arm Cops
			43541, -- Pauldron
			43543, -- Robe
			43550, -- Jack
			43537, -- Cuirass
			43545, -- Gloves
			43552, -- Bracers
			43539, -- Gauntlets
			43548, -- Sash
			43555, -- Belt
			43542, -- Girdle
			43546, -- Breeches
			43553, -- Guards
			43540, -- Greaves
			43544, -- Shoes
			43551, -- Boots
			43538, -- Sabatons
			43561, -- Necklace
			43536, -- Ring
			43535, -- Dagger
			43529, -- Axe
			43530, -- Mace
			43531, -- Sword
			43532, -- Battle Axe
			43533, -- Maul
			43534, -- Greatsword
			43549, -- Bow
			43560, -- Restoration Staff
			43557, -- Inferno Staff
			43558, -- Ice Staff
			43559, -- Lightning Staff
			43556, -- Shield
		}) do
			names[2 ^ (i - 1)] = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H0:item:" .. itemId .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"))
		end
	end

	function LIS.GetItemSetCollectionSlotName( slot )
		if (not names) then initialize() end
		return names[Id64ToNumber(slot)] or ""
	end
end


--------------------------------------------------------------------------------
-- On-demand data initialization
--------------------------------------------------------------------------------

local Initialized = false

local function InitializeData( )
	if (Initialized) then return end
	Initialized = true

	Data.sets = { }
	Data.setIds = { }
	Data.setIdsCraftable = { }
	Data.setIdsCollectible = { }
	Data.setIdsBySource = { }

	local rawData = RawData.Get()
	local flagsKey = rawData.flags
	local specialNames = rawData.specialNames
	local zoneClassification = rawData.zoneClassification

	-- For multi-style items, such as crafted items, just pick a style matching the player's race
	local multiStyle = GetUnitRaceId("player")
	if (multiStyle == 10) then multiStyle = 34 end -- Imperial

	-- Alliance-specific styles for PvP sets
	local allianceStyles = {
		[ALLIANCE_ALDMERI_DOMINION] = 25,
		[ALLIANCE_EBONHEART_PACT] = 24,
		[ALLIANCE_DAGGERFALL_COVENANT] = 23,
	}
	local allianceStyle = allianceStyles[GetUnitAlliance("player")] or multiStyle

	-- Enchantments for crafted sample items
	local enchantments = {
		[ARMORTYPE_HEAVY] = 26580,
		[ARMORTYPE_LIGHT] = 26582,
		[ARMORTYPE_MEDIUM] = 26588,
	}
	local function GetCraftedEnchantment( itemLink )
		return enchantments[GetItemLinkArmorType(itemLink)] or 0
	end

	-- Default weight flag
	local weightFlags = {
		[ARMORTYPE_HEAVY] = LIS.ARMOR_WEIGHT_H,
		[ARMORTYPE_LIGHT] = LIS.ARMOR_WEIGHT_L,
		[ARMORTYPE_MEDIUM] = LIS.ARMOR_WEIGHT_M,
	}
	local function GetWeightFlag( itemLink )
		return weightFlags[GetItemLinkArmorType(itemLink)] or LIS.ARMOR_WEIGHT_NONE
	end

	-- Conversion of raw data zone classification to flags
	local zoneClassificationToFlag = {
		[1] = LIS.SOURCE_TYPE_OVERLAND,
		[2] = LIS.SOURCE_TYPE_PVP,
		[3] = LIS.SOURCE_TYPE_DUNGEON,
		[4] = LIS.SOURCE_TYPE_TRIAL,
		[5] = LIS.SOURCE_TYPE_ARENA,
		[6] = LIS.SOURCE_TYPE_ANTIQUITIES,
	}

	local CheckFlag = LIS.CheckFlag

	local function MakeItemLink( id, flags )
		local quality = 364
		local crafted = 0
		local health = 10000

		if (CheckFlag(flags, flagsKey.crafted)) then
			quality = 370
			crafted = 1
		elseif (CheckFlag(flags, flagsKey.jewelry)) then
			health = 0
		elseif (CheckFlag(flags, flagsKey.weapon) and not CheckFlag(flags, flagsKey.shield)) then
			health = 500
		end

		local style = 0

		if (CheckFlag(flags, flagsKey.allianceStyle)) then
			style = allianceStyle
		elseif (CheckFlag(flags, flagsKey.multiStyle)) then
			style = multiStyle
		elseif (CheckFlag(flags, flagsKey.manualStyle)) then
			style = BitRShift(flags, 12)
		end

		local itemLink = string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", id, quality, style, crafted, health)

		if (crafted == 1) then
			-- Attach an enchantment to crafted gear
			itemLink = itemLink:gsub("370:50:0:0:0", "370:50:" .. GetCraftedEnchantment(itemLink) .. ":370:50")
		end

		return itemLink
	end

	local function AddSource( setId, entry, sourceId )
		if (not Data.setIdsBySource[sourceId]) then
			Data.setIdsBySource[sourceId] = { }
		end
		table.insert(Data.setIdsBySource[sourceId], setId)
		table.insert(entry.sourceIds, sourceId)
		entry.flags = BitOr(entry.flags, zoneClassificationToFlag[zoneClassification[sourceId] or 0] or 0)
	end

	for _, itemData in ipairs(rawData.items) do
		local flags = itemData[2]
		local itemLink = MakeItemLink(itemData[1], flags)
		local _, setName, numBonuses, _, _, setId = GetItemLinkSetInfo(itemLink)

		if (setId > 0) then
			local entry = {
				rawSetName = setName,
				numBonuses = numBonuses,
				numCollectiblePieces = GetNumItemSetCollectionPieces(setId),
				sampleItemLink = itemLink,
				sourceIds = { },
			}

			-- Process flags
			if (CheckFlag(flags, flagsKey.crafted)) then
				entry.flags = LIS.ARMOR_WEIGHT_ALL + LIS.SPECIAL_CRAFTABLE
				entry.craftTraits = BitRShift(flags, 12)
			elseif (CheckFlag(flags, flagsKey.mythic)) then
				entry.flags = GetWeightFlag(itemLink) + LIS.SPECIAL_MYTHIC
			elseif (CheckFlag(flags, flagsKey.jewelry)) then
				entry.flags = LIS.ARMOR_WEIGHT_NONE
			elseif (CheckFlag(flags, flagsKey.weapon)) then
				entry.flags = LIS.ARMOR_WEIGHT_NONE + LIS.SPECIAL_ABILITY_WEAPON
			elseif (CheckFlag(flags, flagsKey.monster)) then
				entry.flags = LIS.ARMOR_WEIGHT_ALL + LIS.SPECIAL_MONSTER_SET
			elseif (CheckFlag(flags, flagsKey.mixedWeights)) then
				entry.flags = LIS.ARMOR_WEIGHT_ALL
			else
				entry.flags = GetWeightFlag(itemLink)
			end

			-- Process sourcing
			for i = 3, #itemData do
				local sourceId = itemData[i]
				if (sourceId > 0) then
					-- Positive: zone ID
					if (GetZoneIndex(sourceId) > 1) then
						AddSource(setId, entry, sourceId)
					end
				elseif (sourceId < 0) then
					if (-sourceId % 0x10 ~= 0) then
						-- Negative, lower 4 bits are in use: special source
						AddSource(setId, entry, sourceId)
					else
						-- Negative, lower 4 bits unset: extra source info; there should only be one entry,
						-- since multiples should be combined (the reason for this being in flag format)
						local name = specialNames[sourceId]
						if (name) then
							-- Exact match means singleton name
							entry.extraSourceInfo = name
						else
							local results = { }
							for k, v in pairs(specialNames) do
								if (BitAnd(-sourceId, -k) == -k) then
									table.insert(results, v)
								end
							end
							entry.extraSourceInfo = table.concat(results, ", ")
						end
					end
				end
			end

			-- Binding type
			entry.flags = BitOr(entry.flags, GetItemLinkBindType(itemLink) == BIND_TYPE_ON_EQUIP and LIS.SET_IS_BIND_ON_EQUIP or LIS.SET_IS_BIND_ON_PICKUP)

			table.insert(Data.setIds, setId)
			if (entry.craftTraits) then
				table.insert(Data.setIdsCraftable, setId)
			elseif (entry.numCollectiblePieces > 0) then
				table.insert(Data.setIdsCollectible, setId)
				entry.flags = BitOr(entry.flags, LIS.SET_IS_COLLECTIBLE)
			end
			Data.sets[setId] = entry
		end
	end
end

setmetatable(Data, { __index = function( ... )
	InitializeData()
	return rawget(...)
end })
