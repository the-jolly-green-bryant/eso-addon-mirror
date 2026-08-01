---
--- Created by YeOldeDragon.
--- DateTime: 2021-03-19 19:08
--- Updated: 2026-03-09 — bank scanning, per-source counts, color coding
---

YeOldeCraftingInventory = {}

-- BagTypes tracked
-- Backpack + Craft bag = "inventory"
-- BAG_BANK + BAG_SUBSCRIBER_BANK = "bank"

local CRAFTING_MAT = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		64489, -- Rubedite Ingot
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		64504, -- Ancestor Silk
		64506, -- Rubedo Leather
	},
	[CRAFTING_TYPE_ENCHANTING] = {
		45850, -- Ta (normal quality)
		64509, -- Rejera (CP 150 potency)
		64508, -- Jehade (CP 150 potency)
		45833, -- Deni (stamina)
		45832, -- Makko (magika)
		45831, -- Oko (health)
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		64502, -- Sanded Ruby Ash
	},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		135146, -- Platinum Ounce
	},
	[CRAFTING_TYPE_ALCHEMY] = {
		-- Ingredients are too varied to track statically
	},
	[CRAFTING_TYPE_PROVISIONING] = {
		-- Ingredients are too varied to track statically
	},
}

--- MaterialInfo[id] = { name, icon, type, invCount, bankCount }
YeOldeCraftingInventory.MaterialInfo = {}

local SV = nil

------------------------------
-- Utilities

local function getItemLinkFromItemId(itemId)
	return string.format("|H1:item:%d:%d:50:0:0:0:0:0:0:0:0:0:0:0:0:%d:%d:0:0:%d:0|h|h", itemId, 0, 0, 0, 10000)
end

function YeOldeCraftingInventory.GetCurrentCraftingLevel(craftingType)
	if craftingType == CRAFTING_TYPE_BLACKSMITHING then
		return GetNonCombatBonus(NON_COMBAT_BONUS_BLACKSMITHING_LEVEL)
	elseif craftingType == CRAFTING_TYPE_CLOTHIER then
		return GetNonCombatBonus(NON_COMBAT_BONUS_CLOTHIER_LEVEL)
	elseif craftingType == CRAFTING_TYPE_WOODWORKING then
		return GetNonCombatBonus(NON_COMBAT_BONUS_WOODWORKING_LEVEL)
	elseif craftingType == CRAFTING_TYPE_ENCHANTING then
		return GetNonCombatBonus(NON_COMBAT_BONUS_ENCHANTING_LEVEL)
	elseif craftingType == CRAFTING_TYPE_JEWELRYCRAFTING then
		return GetNonCombatBonus(NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL)
	end
end

------------------------------
-- Bag scanning

local function UpdateMaterialCount(id, info)
	if not info then
		return
	end

	-- GetItemLinkStacks returns 3 counts: backpack, bank, craftBag
	local backpackCount, bankCount, craftBagCount = GetItemLinkStacks(info.link)

	info.invCount = backpackCount
	info.bankCount = bankCount + craftBagCount
end

local function ParseAllBags()
	for id, info in pairs(YeOldeCraftingInventory.MaterialInfo) do
		UpdateMaterialCount(id, info)
	end
end

local function OnInventorySingleSlotUpdate(_, bagId, slotId)
	local id = GetItemId(bagId, slotId)
	local info = YeOldeCraftingInventory.MaterialInfo[id]
	if info then
		UpdateMaterialCount(id, info)
	end
end

------------------------------
-- Tooltip

--- Returns tooltip lines for the given crafting type.
--- Shows inventory count (backpack) and bank count (bank + craft bag) per material.
function YeOldeCraftingInventory:GetTooltipLines(craftingType)
	local result = {}
	local mats = CRAFTING_MAT[craftingType]

	if mats == nil or #mats == 0 then
		result[1] = "|c888888" .. YeOldeInfos.lang[SI_YEOLDEINFOS_UNTRACKED_MATS] .. "|r"
		return result
	end

	for _, matId in ipairs(mats) do
		local info = YeOldeCraftingInventory.MaterialInfo[matId]
		if info then
			local inv = info.invCount or 0
			local bank = info.bankCount or 0

			-- Color: green if in inventory, gold if only in bank/craft bag, red if nowhere
			local nameColor
			local minMats = tonumber(SV.MinCraftingMats) or 500
			if (inv + bank) >= minMats then
				nameColor = YeOldeInfos.Colors.GREEN:ToHex()
			elseif (inv + bank) > 0 then
				nameColor = YeOldeInfos.Colors.GOLD:ToHex()
			else
				nameColor = YeOldeInfos.Colors.RED:ToHex()
			end

			local iconStr = "|t20:20:" .. info.icon .. "|t"
			local cleanName = info.name:gsub("%^.*", "")
			local nameStr = "|c" .. nameColor .. cleanName .. "|r"

			local invStr = zo_strformat(YeOldeInfos.lang[SI_YEOLDEINFOS_INV], ZO_CommaDelimitNumber(inv))
			local bankStr = zo_strformat(YeOldeInfos.lang[SI_YEOLDEINFOS_BANK], ZO_CommaDelimitNumber(bank))

			result[#result + 1] = string.format("%s %s |c888888 %s  %s|r", iconStr, nameStr, invStr, bankStr)
		end
	end

	return result
end

------------------------------
-- Initialization

function YeOldeCraftingInventory.Initialize(sv)
	SV = sv
	-- Build MaterialInfo from IDs
	for type, ids in ipairs(CRAFTING_MAT) do
		for _, id in ipairs(ids) do
			if id > 0 then
				local link = getItemLinkFromItemId(id)
				YeOldeCraftingInventory.MaterialInfo[id] = {
					link = link,
					name = GetItemLinkName(link),
					icon = GetItemLinkIcon(link),
					type = type,
					invCount = 0,
					bankCount = 0,
				}
			end
		end
	end

	-- Initial full scan (includes bank — data is available client-side from login)
	ParseAllBags()

	EVENT_MANAGER:RegisterForEvent(YeOldeInfos.AddonName, EVENT_INVENTORY_FULL_UPDATE, ParseAllBags)
	EVENT_MANAGER:RegisterForEvent(
		YeOldeInfos.AddonName,
		EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
		OnInventorySingleSlotUpdate
	)
	EVENT_MANAGER:AddFilterForEvent(
		YeOldeInfos.AddonName,
		EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
		REGISTER_FILTER_IS_NEW_ITEM,
		true
	)
end
