local GS = GetString
local secSpace = CSPS.secSpace
local ctrGear = {}
local gearSelector = {
	controls = ctrGear
}
CSPS.gearSelector = gearSelector
local gearCategories = {
	
}

local LLC = false
local craftedItems = {}
local reconList = {}
local craftingRequests = {}
CSPS.craftingRequests = craftingRequests
local maraId = 44904

local cspsD = CSPS.cspsD
local cspsPost = CSPS.post
local ttAddLine = CSPS.helperFunctions.ttAddLine

local theGear = {}

local gearSlots = {
	EQUIP_SLOT_HEAD, EQUIP_SLOT_SHOULDERS,EQUIP_SLOT_CHEST, EQUIP_SLOT_HAND, EQUIP_SLOT_WAIST, EQUIP_SLOT_LEGS, EQUIP_SLOT_FEET, 
	EQUIP_SLOT_NECK, EQUIP_SLOT_RING1, EQUIP_SLOT_RING2,
	EQUIP_SLOT_MAIN_HAND, EQUIP_SLOT_OFF_HAND, EQUIP_SLOT_BACKUP_MAIN, EQUIP_SLOT_BACKUP_OFF,
	EQUIP_SLOT_POISON, EQUIP_SLOT_BACKUP_POISON,
}

local gearSlotIcons = {
	[EQUIP_SLOT_CHEST] = "gearslot_chest",
	[EQUIP_SLOT_HAND] = "gearslot_hands",
	[EQUIP_SLOT_WAIST] = "gearslot_belt",
	[EQUIP_SLOT_LEGS] = "gearslot_legs",
	[EQUIP_SLOT_FEET] = "gearslot_feet",
	[EQUIP_SLOT_HEAD] = "gearslot_head",
	[EQUIP_SLOT_SHOULDERS] = "gearslot_shoulders",
	[EQUIP_SLOT_MAIN_HAND] = "gearslot_mainhand",
	[EQUIP_SLOT_OFF_HAND] = "gearslot_offhand",
	[EQUIP_SLOT_BACKUP_MAIN] = "gearslot_mainhand",
	[EQUIP_SLOT_BACKUP_OFF] = "gearslot_offhand",
	[EQUIP_SLOT_NECK] = "gearslot_neck",
	[EQUIP_SLOT_RING1] = "gearslot_ring",
	[EQUIP_SLOT_RING2] = "gearslot_ring",
	[EQUIP_SLOT_POISON] = "gearslot_poison",
	[EQUIP_SLOT_BACKUP_POISON] = "gearslot_poison",
}

local weaponTypeIcons = {
	[WEAPONTYPE_AXE] = "esoui/art/tradinghouse/tradinghouse_weapons_1h_axe_up.dds",
	[WEAPONTYPE_BOW] = "esoui/art/inventory/inventory_tabicon_bow_up.dds",
	[WEAPONTYPE_DAGGER] = "esoui/art/tradinghouse/tradinghouse_weapons_1h_dagger_up.dds",
	[WEAPONTYPE_FIRE_STAFF] = "esoui/art/tradinghouse/tradinghouse_weapons_staff_flame_up.dds",
	[WEAPONTYPE_FROST_STAFF] = "esoui/art/tradinghouse/tradinghouse_weapons_staff_frost_up.dds",
	[WEAPONTYPE_HAMMER] = "esoui/art/tradinghouse/tradinghouse_weapons_1h_mace_up.dds",
	[WEAPONTYPE_HEALING_STAFF] = "esoui/art/progression/icon_healstaff.dds",
	[WEAPONTYPE_LIGHTNING_STAFF] = "esoui/art/tradinghouse/tradinghouse_weapons_staff_lightning_up.dds",
	[WEAPONTYPE_SHIELD] = "esoui/art/inventory/inventory_tabicon_shield_up.dds",
	[WEAPONTYPE_SWORD] = "esoui/art/tradinghouse/tradinghouse_weapons_1h_sword_up.dds",
	[WEAPONTYPE_TWO_HANDED_AXE] = "esoui/art/tradinghouse/tradinghouse_weapons_2h_axe_up.dds",
	[WEAPONTYPE_TWO_HANDED_HAMMER] = "esoui/art/tradinghouse/tradinghouse_weapons_2h_mace_up.dds",
	[WEAPONTYPE_TWO_HANDED_SWORD] = "esoui/art/tradinghouse/tradinghouse_weapons_2h_sword_up.dds",
}

local armorTypeIcons = {
	[ARMORTYPE_LIGHT] = "esoui/art/inventory/inventory_tabicon_armorlight_up.dds",
	[ARMORTYPE_MEDIUM] = "esoui/art/inventory/inventory_tabicon_armormedium_up.dds",
	[ARMORTYPE_HEAVY] = "esoui/art/inventory/inventory_tabicon_armorheavy_up.dds",
}

local gearSlotsBody = {
	[EQUIP_SLOT_CHEST] = true,
	[EQUIP_SLOT_HAND] = true,
	[EQUIP_SLOT_WAIST] = true,
	[EQUIP_SLOT_LEGS] = true,
	[EQUIP_SLOT_FEET] = true,
	[EQUIP_SLOT_HEAD] = true,
	[EQUIP_SLOT_SHOULDERS] = true,
}
	
local gearSlotsHands = {
	[EQUIP_SLOT_MAIN_HAND] = true,
	[EQUIP_SLOT_OFF_HAND] = true,
	[EQUIP_SLOT_BACKUP_MAIN] = true,
	[EQUIP_SLOT_BACKUP_OFF] = true,
}

local gearSlotsBackbar = {
	[EQUIP_SLOT_BACKUP_MAIN] = true,
	[EQUIP_SLOT_BACKUP_OFF] = true,
}

local gearSlotsMainHand = {
	[EQUIP_SLOT_MAIN_HAND] = true,
	[EQUIP_SLOT_BACKUP_MAIN] = true,
}

local gearSlotsJewelry = {
	[EQUIP_SLOT_NECK] = true,
	[EQUIP_SLOT_RING1] = true,
	[EQUIP_SLOT_RING2] = true,
}

local gearSlotsPoison = {
	[EQUIP_SLOT_POISON] = true,
	[EQUIP_SLOT_BACKUP_POISON] = true,
}

local isTwoHanded = {
    [WEAPONTYPE_FIRE_STAFF] = true,
    [WEAPONTYPE_FROST_STAFF] = true,
    [WEAPONTYPE_HEALING_STAFF] = true,
    [WEAPONTYPE_LIGHTNING_STAFF] = true,
    [WEAPONTYPE_TWO_HANDED_AXE] = true,
    [WEAPONTYPE_TWO_HANDED_HAMMER] = true,
    [WEAPONTYPE_TWO_HANDED_SWORD] = true,
	[WEAPONTYPE_BOW] = true,
}


local equipSlotToEquipType = {
	[EQUIP_SLOT_BACKUP_MAIN] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true},
	[EQUIP_SLOT_BACKUP_OFF] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_OFF_HAND] = true},

	[EQUIP_SLOT_MAIN_HAND] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_MAIN_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true},
	[EQUIP_SLOT_OFF_HAND] = {[EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_OFF_HAND] = true},

	[EQUIP_SLOT_POISON] = {[EQUIP_TYPE_POISON] = true},
	[EQUIP_SLOT_BACKUP_POISON] = {[EQUIP_TYPE_POISON] = true},

	[EQUIP_SLOT_CHEST] = {[EQUIP_TYPE_CHEST] = true},
	[EQUIP_SLOT_FEET] = {[EQUIP_TYPE_FEET] = true},
	[EQUIP_SLOT_HEAD] = {[EQUIP_TYPE_HEAD] = true},
	[EQUIP_SLOT_LEGS] = {[EQUIP_TYPE_LEGS] = true},
	[EQUIP_SLOT_SHOULDERS] = {[EQUIP_TYPE_SHOULDERS] = true},
	[EQUIP_SLOT_WAIST] = {[EQUIP_TYPE_WAIST] = true},
	[EQUIP_SLOT_HAND] = {[EQUIP_TYPE_HAND] = true},

	[EQUIP_SLOT_NECK] = {[EQUIP_TYPE_NECK] = true},
	[EQUIP_SLOT_RING1] = {[EQUIP_TYPE_RING] = true},
	[EQUIP_SLOT_RING2] = {[EQUIP_TYPE_RING] = true},
}

local itemFitIndicators = {
	{texture = "esoui/art/inventory/inventory_icon_equipped.dds", color = ZO_SUCCEEDED_TEXT}, -- result = 1, item is equipped
	{texture = "esoui/art/inventory/newitem_icon.dds", color = ZO_ORANGE},  -- result = 2, item needs inspection
	{texture = "esoui/art/inventory/inventory_sell_forbidden_icon.dds", color = ZO_ERROR_COLOR}, -- result = 3, item is not available
	{texture = "esoui/art/tooltips/icon_bag.dds", color = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_ARCANE)},  -- result = 4, item is in inventory
	{texture = "esoui/art/tooltips/icon_bank.dds", color = GetItemQualityColor(ITEM_FUNCTIONAL_QUALITY_ARTIFACT)}, -- result = 5, item is in bank
	{texture = "esoui/art/tooltips/icon_bag.dds", color = ZO_ORANGE},  --6) inventory, could fit
	{texture = "esoui/art/tooltips/icon_bank.dds", color = ZO_ORANGE }, --7) bank, could fit
}
	
-- EQUIP_SLOT_COSTUME		[EQUIP_TYPE_COSTUME

local trueFalseColors = {[true] = ZO_SUCCEEDED_TEXT, [false] = ZO_ERROR_COLOR}

local poisonItemLink = "|H0:item:%s:308:50:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:%s|h|h"

local itemIdsGlyphsArmor = {
	26580, 26582, 26588, 68343, -- health, magicka, stamina, prismatic defense
}

local itemIdsGlyphsWeapon = {
	26848, 5365, 26844, 26587, 26841, 45869, -- flame, frost, shock, poison, foul, decreasehealth
	43573,45868,45867,  -- absorb health / magicka / stamina
	54484,26845, 5366, 26591, 68344, -- weapon damage, crushing, hardening, weakening, prismatic onslaught 
}

local itemIdsGlyphsJewelry = {
	26581, 26583, 26589,  -- health/magicka/stamina recovery 
	45884, 45883,  -- increase magical/physical harm
	45870, 45871,  -- reduce spell/stam cost
	45872, 45873,   -- bashing damage, shielding
	26849, 5364, 43570, 26586, 26847,  -- flame/frost/shock/poison/disease resistance
	45875, 45874,  -- potion speed / poweer
	166047,	166046, -- prismatic recovery, reduce prismatic skill cost
	45886, 45885,  -- decrease spell/physical harm
}

local enchantIds = false
local enchantNames = false
local enchantGlyphs = false

local vCategories = {"type", "enchant", "trait", "quality"}
local traitIcons = false

local myCPLevel = math.min(GetUnitChampionPoints("player") or 0, 160)
myCPLevel = math.floor(myCPLevel/10)*10
local myLevel = GetUnitLevel("player")	
	
local function tableContains(myTable, myEntry)
	if not myTable or not myEntry then return false end
	for i, v in pairs(myTable) do
		if v == myEntry then return true end
	end
	return false
end

function CSPS.getGearSlotsHands()
	return gearSlotsHands
end

function CSPS.getSortedGearSlots()
	return gearSlots
end

local function buildGlyphTables()
	enchantIds = {}
	enchantNames = {}
	enchantGlyphs = {}
	for j, w in pairs({itemIdsGlyphsArmor, itemIdsGlyphsJewelry, itemIdsGlyphsWeapon}) do
		for i, v in pairs(w) do
			local itemLink = string.format("|H0:item:%s:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", v) 
			local _, enchantNameFull = GetItemLinkEnchantInfo(itemLink)
			local enchantId = GetItemLinkDefaultEnchantId(itemLink)
			local enchantName = v ~= 68343 and v ~= 166047 and
				(string.match(enchantNameFull, "(.+)%s*Enchantment") or string.match(enchantNameFull, ":.%s*(.+)") or string.match(enchantNameFull, ":%s*(.+)") or string.match(enchantNameFull, "Enchantement%s*(.+)")) --string.char(194,160) makes the sec.space
			local enchantSearchCategory = GetEnchantSearchCategoryType(enchantId)
			if enchantId == 179 then enchantSearchCategory = ENCHANTMENT_SEARCH_CATEGORY_PRISMATIC_REGEN end
			enchantName = enchantName or GS("SI_ENCHANTMENTSEARCHCATEGORYTYPE", enchantSearchCategory) or ""
			-- d(itemLink.." - "..enchantName)
			enchantIds[v] = enchantId
			enchantGlyphs[enchantId] = v
			enchantNames[enchantId] = zo_strformat("<<C:1>>", enchantName)
		end
	end
end


local function setSelectorPoison(firstId, secondId)
	if not firstId then
		gearSelector.firstId = false
		return
	end
	secondId = secondId or 0
	gearSelector.firstId = firstId
	gearSelector.secondId = secondId
	gearSelector.link = string.format(poisonItemLink, firstId, secondId)
end


CSPSGearSelectorPoisonList = ZO_SortFilterList:Subclass()

local CSPSGearSelectorPoisonList = CSPSGearSelectorPoisonList

function CSPSGearSelectorPoisonList:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return list
end

function CSPSGearSelectorPoisonList:SetupItemRow( control, data )
	control.data = data
	GetControl(control, "Name").normalColor = ZO_DEFAULT_TEXT
	GetControl(control, "Name"):SetText(data.name)
	
	GetControl(control, "Selected"):SetHidden(data.firstId ~= gearSelector.firstId or data.secondId ~= gearSelector.secondId)
	ZO_SortFilterList.SetupRow(self, control, data)
end

function CSPSGearSelectorPoisonList:Setup( )
	ZO_ScrollList_AddDataType(self.list, 1, "CSPSPOISONLISTENTRY", 28, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.masterList = {}
	
	local sortKeys = {}
	self.currentSortKey = ""
	self.currentSortOrder = ZO_SORT_ORDER_UP
	self.sortFunction = function( listEntry1, listEntry2 )	return true end

	self:RefreshData()
end

local poisonSelection = {}
local usePoisonEffectNames = false

function CSPSGearSelectorPoisonList:BuildMasterList()
	self.masterList = {}
	for i, v in pairs(poisonSelection) do
		local name = CSPS.getAlternatePoisonName(v[2] or 0)
		name = usePoisonEffectNames and name or string.format(poisonItemLink, v[1] or 0, v[2] or 0)
		table.insert(self.masterList, {name = name, firstId = v[1], secondId = v[2] or 0})
	end
end

function CSPSGearSelectorPoisonList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	for _, data in ipairs(self.masterList) do
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end


function CSPS.poisonListMouseEnter(control)
	CSPS.ctrPoisonList:Row_OnMouseEnter(control)
	CSPS.showPoisonTooltip(control, nil, control.data.firstId, control.data.secondId or 0)
end

function CSPS.poisonListMouseExit(control)
	CSPS.ctrPoisonList:Row_OnMouseExit(control)
	ZO_Tooltips_HideTextTooltip()
end

function CSPS.poisonListMouseUp(control, button, upInside)
	setSelectorPoison(control.data.firstId, control.data.secondId)
	CSPS.ctrPoisonList:RefreshVisible()
end

local function getPoisonsFromInventory()
	local poisonsInInventory = {}
	local poisonsFound = {}
	local myBags = {BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}
	for _, bagId in pairs(myBags) do
		for slotIndex = 0, GetBagSize(bagId) do
			if GetItemType(bagId, slotIndex) == ITEMTYPE_POISON then
				local itemLink = GetItemLink(bagId, slotIndex)
				local firstId = GetItemLinkItemId(itemLink)
				local secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
				poisonsFound[firstId] = poisonsFound[firstId] or {}
				if not poisonsFound[firstId][secondId] then
					poisonsFound[firstId][secondId] = true
					table.insert(poisonsInInventory, {firstId = firstId, secondId = secondId, link = itemLink})
				end
			end
		end
	end
	return poisonsInInventory
end

local function fillPoisonList(myList)
	poisonSelection = myList or getPoisonsFromInventory()
	CSPS.ctrPoisonList:RefreshData()
end

local function showPoisonMenu(gearSlot, control)
	ClearMenu()
	local function setPoison(poisonTable)
		theGear[gearSlot or gearSelector.gearSlot] = {firstId = poisonTable.firstId or poisonTable[1], secondId = poisonTable.secondId or poisonTable[2], link=poisonTable.link}
		CSPS.refreshTree()
		
		if not gearSlot then hideGearWindow() return end
		CSPS.refreshTree()
	end
	local function createPoisonSubmenu(poisonIdList, callback)
		local poisonSubMenu = {}
		for i, v in pairs(poisonIdList) do
			if type(v) == "table" then -- if it's not a table it's just the first id and the callback function fills the list!
				v.link = v.link or string.format(poisonItemLink, v.firstId or v[1] or 0, v.secondId or v[2] or 0) 
			end
			table.insert(poisonSubMenu, {label = type(v) == "table" and v.link or string.format(poisonItemLink, v or 0, 0), 	
			callback = function() (callback or setPoison)(v) end,
			tooltip = type(v) == "table" and function(menuControl, inside) if inside then CSPS.showPoisonTooltip(menuControl, nil, v.firstId or v[1] or 0, v.secondId or v[2] or 0) else ZO_Tooltips_HideTextTooltip() end end})
		end
		return poisonSubMenu
	end
	AddCustomSubMenuItem(string.format("%s/%s ...", GS(SI_MAIN_MENU_INVENTORY), GS(SI_CURRENCYLOCATION1)), createPoisonSubmenu(getPoisonsFromInventory()))
	
	
	local typicalPoisons = {
		{76827, 138240},	-- health poison ix
		{79690, 0},	-- crown lethal poison
	}
	
	AddCustomSubMenuItem(GS(CSPS_Txt_StandardProfile), createPoisonSubmenu(typicalPoisons))
	AddCustomSubMenuItem(GS(SI_ITEMTYPEDISPLAYCATEGORY28),	createPoisonSubmenu(CSPS.getPoisonIds(false, true))) -- crown poisons
	
	AddCustomSubMenuItem(GS(SI_ITEM_FORMAT_STR_CRAFTED), createPoisonSubmenu(CSPS.getPoisonIds(), 
		function(firstId) 
			CSPS.showGearWin(control, gearSlot) 
			fillPoisonList(CSPS.getPoisonIds(firstId))
			--[[
			zo_callLater(function()
				ClearMenu()
				for i, v in pairs(CSPS.getPoisonIds(firstId)) do
					local name = CSPS.getAlternatePoisonName(v[2] or 0)
					name = name or string.format(poisonItemLink, v[1] or 0, v[2] or 0)
					AddCustomMenuItem(name, function() setPoison(v) end)
					AddCustomMenuTooltip(function(control, inside) if inside then CSPS.showPoisonTooltip(control, nil, v.firstId or v[1] or 0, v.secondId or v[2] or 0) else ZO_Tooltips_HideTextTooltip() end end)
					
				end
				ShowMenu()
			end, 42) -- we need a little delay so ESO can close the old menu
			]]--
		end))
	AddCustomMenuItem("-", function() end)
	AddCustomMenuItem(GS(SI_DIALOG_REMOVE), function() theGear[gearSlot] = false CSPS.refreshTree() end)
	AddCustomMenuItem(GS(SI_DIALOG_CANCEL), function() end)
	
	ShowMenu()	
end

local function generateItemLevelAndSublevel(level, cpLevel, itemQuality)
	cpLevel = cpLevel and math.floor(cpLevel/10)*10 or myCPLevel -- myCPLevel is already floored
	level = level or myLevel
	level = math.floor(level/2)*2
	itemQuality = itemQuality or 1
	if cpLevel >= 160 then return 50, 365 + itemQuality end
	if cpLevel > 100 then return 50, (cpLevel - 110) * 1.8 + 235 + itemQuality end --jumps of 18 from 236 on, but cp/10!
	if cpLevel > 0 then return 50, 115 + itemQuality * 10 + cpLevel/10 - 1 end
	return level, 19 + itemQuality
end

local function addEnchantToNotCraftedLink(itemLink, enchantGlyph, itemQuality)
	if not itemLink then return itemLink end
	itemQuality = itemQuality or GetItemLinkQuality(itemLink) or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
	local level, subLevel = generateItemLevelAndSublevel(GetItemLinkRequiredLevel(itemLink), GetItemLinkRequiredChampionPoints(itemLink), itemQuality)
	subLevel = enchantGlyph and subLevel or 0
	level = enchantGlyph and level or 0
	enchantGlyph = enchantGlyph or 0
	return string.gsub(itemLink, "([^:]+:[^:]+:[^:]+:[^:]+:[^:]+:)([^:]+:[^:]+:[^:]+:)(.*)", "%1:"..enchantGlyph..":"..subLevel..":"..level..":%3")
end

local function buildCraftedItemLink(itemId, itemQuality, enchantGlyph, traitType, level, cpLevel)
	if not itemId then return "" end
	itemQuality = itemQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
	local _, subLevel = generateItemLevelAndSublevel(level, cpLevel, itemQuality)
	local linkTable = {
		"|H0:item",
		itemId,
		subLevel,
		level or myLevel or 50,
		enchantGlyph or 0,
		enchantGlyph and subLevel or 0,
		enchantGlyph and 50 or 0,
		traitType or 0,
		"0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h",
	}
	return table.concat(linkTable, ":")
end

CSPS.buildCraftedItemLink = buildCraftedItemLink

local function removeExistingMythics(exepction)
	for i, v in pairs(theGear) do
		if v and v.mythic and (not exepction or i ~= exepction) then theGear[i] = false end
	end
end

local function unequipExistingMythic(exepction)
	for _, gearSlot in ipairs(gearSlots) do
		if gearSlot ~= exepction and GetItemDisplayQuality(BAG_WORN, gearSlot) == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then
			RequestUnequipItem(BAG_WORN, gearSlot)
			return true
		end
	end
	return false
end

local function checkItemLevel(itemLink, noText)
	local warnLevel = false
	local ignoreLevel = false
	
	if GetItemLinkItemId(itemLink) == 44904 then 
		if noText then return false end
		ignoreLevel = true
	end
	
	local auxCPLevel = myCPLevel
	
	if GetItemLinkItemType(itemLink) == ITEMTYPE_POISON then
		if GetItemLinkDisplayQuality(itemLink) == ITEM_FUNCTIONAL_QUALITY_LEGENDARY then 
			if noText then return false end
			ignoreLevel = true
		end
		if auxCPLevel > 150 then auxCPLevel = 150 end
	end
	
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	
	local maxLevelDiff = CSPS.savedVariables.settings.maxLevelDiff or 10
	
	if not ignoreLevel then
		if math.abs(reqCP - auxCPLevel) >= maxLevelDiff or auxCPLevel == 0 and math.abs(reqLevel - myLevel) >= maxLevelDiff then 
			warnLevel = true 
		end
	end
	
	if noText then return warnLevel end
	
	local levelText = reqCP and reqCP > 0 and string.format("|t28:28:esoui/art/champion/champion_icon_32.dds|t %s", reqCP) or reqLevel
	levelText = string.format("%s: %s", GS(SI_ITEM_FORMAT_STR_LEVEL), levelText)
	return warnLevel, levelText
end

CSPS.checkItemLevel = checkItemLevel

local function getSetItemInfo(setId, gearSlot, itemType,  traitType, itemQuality, enchantId)
	if setId == maraId then
		local itemLink = buildCraftedItemLink(maraId)
		return GetItemLinkIcon(itemLink), itemLink, nil, nil
	end
	if type(setId) == "table" then
		enchantId = setId.enchant
		itemQuality = setId.quality
		traitType = setId.trait
		itemType = setId.type
		setId = setId.setId or 0
	end
	itemQuality = itemQuality or ITEM_FUNCTIONAL_QUALITY_LEGENDARY
	if not enchantGlyphs then buildGlyphTables() end -- need enchantNames for varification
	local enchantGlyph = enchantId and enchantGlyphs[enchantId] or false
	
	local numPieces = GetNumItemSetCollectionPieces(setId)
	
	if numPieces > 0 then
		local setType = GetItemSetType(setId)
		for i=1, numPieces do
			if numPieces == 1  and setType ~= ITEM_SET_TYPE_WEAPON then itemQuality = ITEM_FUNCTIONAL_QUALITY_LEGENDARY end -- mythic items 
			-- no green items that aren't open world sets
			if setType == ITEM_SET_TYPE_DUNGEON and itemQuality < ITEM_FUNCTIONAL_QUALITY_ARCANE then itemQuality = ITEM_FUNCTIONAL_QUALITY_ARCANE end
			-- no blue perfected items
			if GetItemSetUnperfectedSetId(setId) ~= 0 and itemQuality == ITEM_FUNCTIONAL_QUALITY_ARCANE then itemQuality = ITEM_FUNCTIONAL_QUALITY_ARTIFACT end
			local pieceId, setSlot = GetItemSetCollectionPieceInfo(setId, i)
			local itemLink = GetItemSetCollectionPieceItemLink(pieceId, 0, traitType, itemQuality)
			local equipType = GetItemLinkEquipType(itemLink)
			if (gearSlotsHands[gearSlot] and GetItemLinkWeaponType(itemLink) == itemType) or
				 ((not gearSlotsHands[gearSlot]) and equipSlotToEquipType[gearSlot] and equipSlotToEquipType[gearSlot][equipType] and (gearSlotsJewelry[gearSlot] or itemType == GetItemLinkArmorType(itemLink))) then 
				local icon = GetItemLinkInfo(itemLink)
				if enchantGlyph then itemLink = addEnchantToNotCraftedLink(itemLink, enchantGlyph, itemQuality) end
				return icon, itemLink, pieceId, setSlot
			end
		end
	elseif setId == 0 then
		local itemId = CSPS.getGenericItemId(gearSlotsHands[gearSlot] and itemType, gearSlotsBody[gearSlot] and itemType, gearSlot)
		local itemLink = buildCraftedItemLink(itemId, itemQuality, enchantGlyph, traitType)
		local icon = GetItemLinkInfo(itemLink)
		return icon, itemLink, nil, nil
	else
		local allSetItemIds = LibSets and LibSets.GetSetItemIds(setId)
		if not allSetItemIds then return "---", "---" end
		for theItemId, v in pairs(allSetItemIds) do
			local itemLink = buildCraftedItemLink(theItemId, itemQuality, enchantGlyph, traitType)
			local equipType = GetItemLinkEquipType(itemLink)
			if (gearSlotsHands[gearSlot] and GetItemLinkWeaponType(itemLink) == itemType) or
				 ((not gearSlotsHands[gearSlot]) and equipSlotToEquipType[gearSlot] and equipSlotToEquipType[gearSlot][equipType] and (gearSlotsJewelry[gearSlot] or itemType == GetItemLinkArmorType(itemLink))) then 
					local icon = GetItemLinkInfo(itemLink)
					return icon, itemLink, nil, nil
			end
		end
		return false, "---", nil, nil
	end
	
end
CSPS.getSetItemInfo = getSetItemInfo

local function doesSetFitGearSlot(gearSlot, setId)
	if not gearSlot then return true end
	if not setId then return false end
	local fittingEquipTypes = equipSlotToEquipType[gearSlot]
	local setType = GetItemSetType(setId)
	if setType == ITEM_SET_TYPE_CRAFTED then return true end
	if setType == ITEM_SET_TYPE_MONSTER then return gearSlot == EQUIP_SLOT_SHOULDERS or gearSlot == EQUIP_SLOT_HEAD end
	if setType == ITEM_SET_TYPE_WEAPON then return gearSlotsHands[gearSlot] == true end
    
	if GetNumItemSetCollectionPieces(setId) == 1 then
		--mythic or single weapon
		return fittingEquipTypes[GetItemLinkEquipType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, 1)))]
	end
	
	if GetNumItemSetCollectionPieces(setId) < 22 then
		for i=1, GetNumItemSetCollectionPieces(setId) do
			if fittingEquipTypes[GetItemLinkEquipType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, i)))] then return true end
		end
		return false
	end
		
	return true
end

local function buildTraitIconTable()
	traitIcons = {}
	for i=1, GetNumSmithingTraitItems() do
		local itemTraitType, _, textureName = GetSmithingTraitItemInfo(i)
		if itemTraitType then traitIcons[itemTraitType] = textureName end
	end
end

local function getWeaponTypeName(weaponType)
	if isTwoHanded[weaponType] then
		return string.format("%s (%s)", GS("SI_WEAPONTYPE", weaponType), GS(SI_WEAPONCONFIGTYPE3))
	else
		return GS("SI_WEAPONTYPE", weaponType)
	end
end

local function getTextAndIcon(category, gearSlot, value)
	if not value then return "-", "esoui/art/buttons/radiobuttondisabledup.dds" end -- disabled texture?
	local returnFuncs  = {
		["type"] = function()
			if gearSlotsHands[gearSlot] then
				return getWeaponTypeName(value), weaponTypeIcons[value]
			else
				return GS("SI_ARMORTYPE", value), armorTypeIcons[value]
			end
		end,
		["enchant"] = function()
			local itemLink = string.format("|H0:item:%s:369:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", enchantGlyphs[value])
			return enchantNames[value], GetItemLinkIcon(itemLink)
		end,
		["quality"] = function()
			local qualityIcons = {
				[ITEM_FUNCTIONAL_QUALITY_LEGENDARY] = "esoui/art/icons/jewelrycrafting_booster_refined_chromium.dds", 
				[ITEM_FUNCTIONAL_QUALITY_ARTIFACT] = "esoui/art/icons/jewelrycrafting_booster_refined_zircon.dds", 
				[ITEM_FUNCTIONAL_QUALITY_ARCANE] = "esoui/art/icons/jewelrycrafting_booster_refined_iridium.dds", 
				[ITEM_FUNCTIONAL_QUALITY_MAGIC] = "esoui/art/icons/jewelrycrafting_booster_refined_terne.dds", 
				[ITEM_FUNCTIONAL_QUALITY_NORMAL] = "esoui/art/buttons/radiobuttondisabledup.dds",
				[ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE] = "esoui/art/icons/antiquities_u30_mythic_ring_fragment05.dds",
			}
			return GetItemQualityColor(value):Colorize(GS("SI_ITEMDISPLAYQUALITY", value)), qualityIcons[value] or ""
			--ICON?
		end,
		["trait"] = function()
			if not traitIcons then buildTraitIconTable() end
			return GS("SI_ITEMTRAITTYPE", value), traitIcons[value]
		end,
	}
	return returnFuncs[category]()
end

local function isSlotShield(gearSlot)
	if gearSlot then 
		return theGear[gearSlot] and gearSlotsHands[gearSlot] and theGear[gearSlot]["type"] == WEAPONTYPE_SHIELD
	else
		return gearSelector.gearSlot and gearSlotsHands[gearSelector.gearSlot] and gearSelector.type == WEAPONTYPE_SHIELD
	end
end

local function getItemSetMinQuality(setId)
	return GetItemLinkQuality(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, 1)))
end

local function isSetMythic(setId)
	if not setId then return false end
	local setType = GetItemSetType(setId)
	return GetNumItemSetCollectionPieces(setId) == 1 and setType ~= ITEM_SET_TYPE_WEAPON	
end

local function getValueList(category, gearSlot, isShield)
	local setId = gearSlot and theGear[gearSlot].setId or not gearSlot and gearSelector.setId 
	setId = setId ~= 0 and setId or false
	
	returnFuncs = {
		["trait"] = function()
			gearSlot = gearSlot or gearSelector.gearSlot
			local armorTraits = {ITEM_TRAIT_TYPE_ARMOR_DIVINES, ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, ITEM_TRAIT_TYPE_ARMOR_INFUSED, ITEM_TRAIT_TYPE_ARMOR_NIRNHONED, ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS, ITEM_TRAIT_TYPE_ARMOR_REINFORCED, ITEM_TRAIT_TYPE_ARMOR_STURDY, ITEM_TRAIT_TYPE_ARMOR_TRAINING, ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED}
			local jewelryTraits = {ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY, ITEM_TRAIT_TYPE_JEWELRY_ARCANE, ITEM_TRAIT_TYPE_JEWELRY_HARMONY, ITEM_TRAIT_TYPE_JEWELRY_HEALTHY, ITEM_TRAIT_TYPE_JEWELRY_INFUSED,  ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE, ITEM_TRAIT_TYPE_JEWELRY_ROBUST, ITEM_TRAIT_TYPE_JEWELRY_SWIFT, ITEM_TRAIT_TYPE_JEWELRY_TRIUNE}
			local weaponTraits = {ITEM_TRAIT_TYPE_WEAPON_PRECISE, ITEM_TRAIT_TYPE_WEAPON_CHARGED, ITEM_TRAIT_TYPE_WEAPON_DECISIVE, ITEM_TRAIT_TYPE_WEAPON_DEFENDING, ITEM_TRAIT_TYPE_WEAPON_INFUSED, ITEM_TRAIT_TYPE_WEAPON_NIRNHONED, ITEM_TRAIT_TYPE_WEAPON_POWERED, ITEM_TRAIT_TYPE_WEAPON_SHARPENED, ITEM_TRAIT_TYPE_WEAPON_TRAINING}
			return gearSlotsHands[gearSlot] and not isShield and weaponTraits or gearSlotsJewelry[gearSlot] and jewelryTraits or armorTraits
		end,
		["enchant"] = function()
			gearSlot = gearSlot or gearSelector.gearSlot
			local myTable = {}
			for i, v in pairs(gearSlotsHands[gearSlot] and not isShield and itemIdsGlyphsWeapon or gearSlotsJewelry[gearSlot] and itemIdsGlyphsJewelry or itemIdsGlyphsArmor) do
				table.insert(myTable, enchantIds[v])
			end
			return myTable
		end,
		["type"] = function()
			gearSlot = gearSlot or gearSelector.gearSlot
			local armorTypes = {ARMORTYPE_LIGHT, ARMORTYPE_MEDIUM, ARMORTYPE_HEAVY}
			if gearSlotsBody[gearSlot] and setId and GetItemSetType(setId) ~= ITEM_SET_TYPE_CRAFTED then 
				armorTypes = {}
				local armorTypesChecked = {}
				for i=1, GetNumItemSetCollectionPieces(setId) do
					local armorType = GetItemLinkArmorType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId, i)))
					if armorType ~= 0 and not armorTypesChecked[armorType] then
						table.insert(armorTypes, armorType)
						armorTypesChecked[armorType] = true
					end
				end
			end
			local weaponTypes = {WEAPONTYPE_AXE, WEAPONTYPE_SWORD, WEAPONTYPE_HAMMER, WEAPONTYPE_DAGGER, WEAPONTYPE_TWO_HANDED_AXE, WEAPONTYPE_TWO_HANDED_SWORD, WEAPONTYPE_TWO_HANDED_HAMMER, WEAPONTYPE_BOW, WEAPONTYPE_FIRE_STAFF, WEAPONTYPE_FROST_STAFF, WEAPONTYPE_LIGHTNING_STAFF, WEAPONTYPE_HEALING_STAFF, WEAPONTYPE_SHIELD}
			if gearSlotsHands[gearSlot] and setId and GetItemSetType(setId) == ITEM_SET_TYPE_WEAPON then
				weaponTypes = {}
				for i=1, GetNumItemSetCollectionPieces(setId) do
					local collectionPieceWeaponType = GetItemLinkWeaponType(GetItemSetCollectionPieceItemLink(GetItemSetCollectionPieceInfo(setId,i)))
					if collectionPieceWeaponType > 0 then table.insert(weaponTypes, collectionPieceWeaponType) end
				end
			end
	
			return gearSlotsBody[gearSlot] and armorTypes or gearSlotsHands[gearSlot] and weaponTypes or false
		end,
		["quality"] = function()
			cspsD(setId or 0)
			if not setId then return false end
			local setType = GetItemSetType(setId)
				
			local qualityList = {ITEM_FUNCTIONAL_QUALITY_LEGENDARY, ITEM_FUNCTIONAL_QUALITY_ARTIFACT, ITEM_FUNCTIONAL_QUALITY_ARCANE, ITEM_FUNCTIONAL_QUALITY_MAGIC, ITEM_FUNCTIONAL_QUALITY_NORMAL}
			if isSetMythic(setId) then --mythic
				qualityList = {ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE} 
			elseif setType ~= ITEM_SET_TYPE_CRAFTED then
				while qualityList[#qualityList] < getItemSetMinQuality(setId) do
					table.remove(qualityList, #qualityList)
				end
			end	
			return qualityList
		end
	}
	return returnFuncs[category]()
end

local function checkGearData(gearSlot, setDefault)
	local myTable = gearSlot and theGear[gearSlot] or gearSelector
	local returnTable = {}
	for _, v in pairs(vCategories) do
		local myList = getValueList(v, gearSlot, isSlotShield(gearSlot))
		myTable[v] = tableContains(myList, myTable[v]) and myTable[v] or myList and setDefault and myList[1] or nil
		returnTable[v] = not myList
	end
	return returnTable
end

local function refreshGearSelector()
	if not gearSelector.setId then
		for i, v in pairs(vCategories) do
			ctrGear[v]:SetHidden(true)
		end
	end
	local hideTable = checkGearData(nil, true)
	for _, v in pairs(vCategories) do
		ctrGear[v]:SetHidden(hideTable[v])
		local labelText, textureName = getTextAndIcon(v, gearSelector.gearSlot, gearSelector[v])
		ctrGear[v]["label"]:SetText(labelText)
		ctrGear[v]["icon"]:SetTexture(textureName)
	end
	
end

local function showVCatMenu(category, gearSlot, control, createSubMenu)
	if gearSlot and theGear[gearSlot] and theGear[gearSlot].mara or not gearSlot and gearSelector.mara then return end
	if not createSubMenu then ClearMenu() end
	local mySubMenu = {}
	local isWeapon = gearSlotsHands[gearSlot or gearSelector.gearSlot]
	local myList = getValueList(category, gearSlot, isSlotShield(gearSlot))
	if not myList then return end
	
	for _, v in pairs(myList) do
		local myName, myIcon = getTextAndIcon(category, gearSlot or gearSelector.gearSlot, v)
		local myEntry = {
			label = string.format("|t26:26:%s|t %s", myIcon, myName),
			callback = function()
				if gearSlot then 
					local gearData  = theGear[gearSlot]
					gearData[category] = v
					checkGearData(gearSlot, true)
					local _, itemLink = getSetItemInfo(gearData, gearSlot)
					gearData.link = itemLink
					gearData.itemUniqueID = nil
					gearData.fitsExactly = nil
					CSPS.refreshTree()
				else 
					gearSelector[category] = v
					refreshGearSelector()
				end	
			end}
		if createSubMenu then
			table.insert(mySubMenu, myEntry)
		else		
			AddCustomMenuItem(myEntry.label, myEntry.callback)
		end
	end
	if gearSlot and not createSubMenu then
		AddCustomMenuItem("-", function() end)
		AddCustomMenuItem(GS(SI_SAVING_EDIT_BOX_EDIT), function() CSPS.showGearWin(control.ctrBtnEdit, gearSlot) end)
	end
	if not createSubMenu then ShowMenu() else return mySubMenu end
end

local function setSetId(setId)
	gearSelector.setId = setId
	gearSelector.mara = nil
	local gearSlot = gearSelector.gearSlot
	gearSelector.mythic = isSetMythic(setId)
	refreshGearSelector()
end

local function formatSetName(setId)
	if GetItemSetType(setId) == ITEM_SET_TYPE_WEAPON then
		return zo_strformat("<<C:1>> (<<C:2>>)", GetItemSetName(setId), GetItemSetCollectionCategoryName(GetItemSetCollectionCategoryId(setId)))
	end
	return zo_strformat("<<C:1>>", GetItemSetName(setId))
end

local function getSetAutoCompleteOptions(gearSlot)
	if gearSlotsPoison[gearSlot] then return false, false end
	local allSets = {}
	local allSetsT = {}
	for i, v in pairs(CSPS.GetSetList()) do
		if not gearSlot or doesSetFitGearSlot(gearSlot, v) then
			local mySetName = formatSetName(v)
			allSetsT[v]= mySetName
			allSets[mySetName] = v
		end
	end
	return allSets, allSetsT
end

local function getActiveSets()
	local setCounts = {}
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable and gearTable.setId and gearTable.setId ~= 0 then
			setCounts[gearTable.setId] = setCounts[gearTable.setId] or {0, 0, 0}
			if gearSlotsHands[gearSlot] then
				local addNum = isTwoHanded[gearTable.type] and 2 or 1
				if gearSlotsBackbar[gearSlot] then 
					setCounts[gearTable.setId][3] = setCounts[gearTable.setId][3] + addNum
				else
					setCounts[gearTable.setId][2] = setCounts[gearTable.setId][2] + addNum
				end
			else
				setCounts[gearTable.setId][1] = setCounts[gearTable.setId][1] + 1
			end
		end
	end
	return setCounts
end

local function addTooltipEnchantFromItemLink(itemLink, r,g,b)
	local _, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
	local enchantText = string.format("%s\n%s", string.upper(enchantHeader), enchantDescription)
	if enchantHeader == "" then	enchantText = string.upper(GS(SI_ENCHANTMENTSEARCHCATEGORYTYPE0)) end
	InformationTooltip:AddLine(enchantText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

local function addTooltipTraitInfoFromItemLink(itemLink, traitType, r,g,b) --
	local lTraitType, traitDescription = GetItemLinkTraitInfo(itemLink) 
	if traitType and lTraitType ~= traitType then cspsD("Traittype differs: "..traitType.." vs "..lTraitType) end
	traitType = traitType or lTraitType
	local traitName = zo_strformat("<<Z:1>>", GS("SI_ITEMTRAITTYPE", traitType))
	if traitType > 0 then traitName = string.format("%s\n%s", traitName, traitDescription) end
	InformationTooltip:AddLine(traitName, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
end

local function addTooltipItemInfo(itemLink, itemQuality, icon, armorType, setDoesNotFit, typeFits, qualityFits, warnLevel, levelText)
	icon = icon ~= "" and icon or GetItemLinkIcon(itemLink)
	itemQuality = itemQuality or GetItemLinkQuality(itemLink)
	local qualityColor = GetItemQualityColor(itemQuality) or ZO_NORMAL_TEXT
	local r,g,b = qualityColor:UnpackRGB()
	if setDoesNotFit then r,g,b = ZO_ERROR_COLOR:UnpackRGB() end
	InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", icon ,  GetItemLinkName(itemLink)), "ZoFontWinH2", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	
	r,g,b = ZO_NORMAL_TEXT:UnpackRGB()
	if GetItemLinkItemId(itemLink) == maraId then
		InformationTooltip:AddLine(GetItemLinkFlavorText(itemLink), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		return true
	end
	local qualityText = GS("SI_ITEMDISPLAYQUALITY", itemQuality or 1)
	if qualityFits ~= nil then qualityText = trueFalseColors[qualityFits]:Colorize(qualityText) end
	
	qualityText = warnLevel and string.format("%s, %s", qualityText, trueFalseColors[false]:Colorize(levelText)) or qualityText
	
	qualityText = armorType and string.format("%s, %s", (typeFits ~= nil and trueFalseColors[typeFits] or ZO_NORMAL_TEXT):Colorize(GS("SI_ARMORTYPE", armorType)), qualityText) or qualityText
	
	InformationTooltip:AddLine(qualityText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	
end

local function addTooltipSetInfo(itemLink, gearSlot, subtractOne)

	local hasSet, _, numBonuses, _, _, linkSetId = GetItemLinkSetInfo(itemLink)
	
	if not hasSet then return end

	local setCount = theGear[gearSlot].setCount
	local numActive = setCount and math.max(setCount[1] + setCount[2], setCount[1] + setCount[3]) or 42
	numActive = subtractOne and numActive - 1 or numActive
	
	local activeBoni, inactiveBoni = {}, {}
	for i=1, numBonuses do
		local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, false, i)
		if numActive >= numRequired then 
			table.insert(activeBoni, (string.gsub(bonusDescription, "\n\r\n", " ")))
		else
			table.insert(inactiveBoni, (string.gsub(bonusDescription, "\n\r\n", " ")))
		end
	end
	if #activeBoni > 0 then
		r, g, b = ZO_SELECTED_TEXT:UnpackRGB()
		InformationTooltip:AddLine(table.concat(activeBoni, "\n"), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end
	if #inactiveBoni > 0 then
		r, g, b = ZO_DISABLED_TEXT:UnpackRGB()
		InformationTooltip:AddLine(table.concat(inactiveBoni, "\n"), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	end
end

local function hideGearWindow()
	if CSPS.gearWindow then CSPS.gearWindow:SetHidden(true) end
	gearSelector.gearSlot = false
	EVENT_MANAGER:UnregisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN)
	CSPS.refreshSetCount()
	CSPS.refreshTree()
end

local function editFunc(control, mySlot)
	
	if not control.canEdit then return end
	
	if CSPS.gearWindow and not CSPS.gearWindow:IsHidden() and gearSelector.gearSlot == mySlot then 
		hideGearWindow()
		return
	end
	if gearSlotsPoison[mySlot] then showPoisonMenu(mySlot, control.ctrBtnEdit) return end
	
	CSPS.showGearWin(control.ctrBtnEdit, mySlot)
	
end

local function addToCraftlist(gearSlot)
	local gearData = theGear[gearSlot]
	if not gearData then cspsD("Gear not found") return end
	CSPS.savedVariables.craftList = CSPS.savedVariables.craftList or {}
	local craft = not gearData.recon and {armorType = gearSlotsBody[gearSlot] and gearData.type or nil, weaponType = gearSlotsHands[gearSlot] and gearData.type or nil, isCP = myCPLevel > 0, level = myCPLevel > 0 and myCPLevel or myLevel, traitIndex = gearData.trait, setIndex = gearData.setId, quality = gearData.quality, enchant = gearData.enchant, isJewelry = gearSlotsJewelry[gearSlot] or nil} or nil
	table.insert(CSPS.savedVariables.craftList, {link = gearData.link, charId = GetCurrentCharacterId(), recon = gearData.recon, gearSlot = gearSlot, craft = craft})
	CSPS.showElement("craftList", true)
end

local function showSetContextMenu(gearSlot, control)
	local setDirectly = gearSlot and true or false
	gearSlot = gearSlot or gearSelector.gearSlot
	if gearSlotsPoison[gearSlot] then return false, false end
	local setCounts = getActiveSets()

	local function iterateBag(bagId, tableToFill, tableToFill2)
		for slotIndex=0, GetBagSize(bagId) do
			local itemLink = GetItemLink(bagId, slotIndex)
			local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
			if hasSet then tableToFill[setId] = true end
			local equipType = GetItemLinkEquipType(itemLink)
			if tableToFill2 and hasSet and equipType and equipType ~= 0 and equipSlotToEquipType[gearSlot][equipType] then
				table.insert(tableToFill2, {itemLink = itemLink, bagId = bagId, slotIndex = slotIndex})
			end
		end
	end
	
	local setsInInventory = {}
	local setItemsInventory = {}
	iterateBag(BAG_BACKPACK, setsInInventory, setItemsInventory)
	iterateBag(BAG_WORN, setsInInventory)
	
	local setsInBank = {}
	local setItemsBank = {}
	iterateBag(BAG_BANK, setsInBank, setItemsBank)
	iterateBag(BAG_SUBSCRIBER_BANK, setsInBank, setItemsBank)
	
	local function createSubMenu(setIdList)
		local idByName = {}
		local sortedNames = {}
		for setId in pairs(setIdList) do
			if doesSetFitGearSlot(gearSlot, setId) then
				local formattedSetName = formatSetName(setId)
				table.insert(sortedNames, formattedSetName)
				idByName[formattedSetName] = setId
			end
		end
		table.sort(sortedNames)
		local mySubMenu = {}
		for _, formattedSetName in pairs(sortedNames) do
			local setId = idByName[formattedSetName]			
			table.insert(mySubMenu, {label = formattedSetName, 
				callback = function() 
					if setDirectly then
						theGear[gearSlot] = theGear[gearSlot] or {}
						local gearData = theGear[gearSlot]
						gearData.itemUniqueID = nil
						gearData.setId = setId
						checkGearData(gearSlot, true)
						gearData.mythic = isSetMythic(setId)
						if gearData.mythic then removeExistingMythics(gearSlot) end
						local _, itemLink = getSetItemInfo(gearData, gearSlot)
						gearData.link = itemLink
						CSPS.refreshSetCount()
						CSPS.refreshTree()
					else
						CSPSWindowGearWindowSetsEdit:SetText(formattedSetName) 
						setSetId(setId)
					end
				end})
		end
		return mySubMenu
	end
	local function createSubMenuForItems(itemList)
		
		local mySubMenu = {}
		for i, v in pairs(itemList) do
			table.insert(mySubMenu, {label = v.itemLink, 
			callback = function() 
				CSPS.setFromBagAndSlot(gearSlot, v.bagId, v.slotIndex) 
				hideGearWindow()
			end, 
			tooltip = function(itemControl, inside) 
				if not inside then ZO_Tooltips_HideTextTooltip() return end
				InitializeTooltip(InformationTooltip, itemControl, LEFT)
				addTooltipItemInfo(v.itemLink, nil, nil, gearSlotsBody[gearSlot] and GetItemLinkArmorType(v.itemLink), nil)
				addTooltipTraitInfoFromItemLink(v.itemLink)
				addTooltipEnchantFromItemLink(v.itemLink)
				-- addTooltipSetInfo(v.itemLink, gearSlot, true)
			end})
		end
		return mySubMenu
	end
	ClearMenu()	
	--
	--
	--
	--
	local needsSeparator = false
	if CSPS.helperFunctions.anyEntryNotFalse(setCounts) then
		AddCustomSubMenuItem(string.format("%s (%s)", GS(SI_MASTER_WRIT_DESCRIPTION_SET), GS(SI_RESTYLE_SHEET_HEADER)), createSubMenu(setCounts))
		needsSeparator = true
	end
	if CSPS.helperFunctions.anyEntryNotFalse(setsInInventory) then
		AddCustomSubMenuItem(string.format("%s (%s)", GS(SI_MASTER_WRIT_DESCRIPTION_SET), GS(SI_BAG1)), createSubMenu(setsInInventory))
		needsSeparator = true
	end
	if CSPS.helperFunctions.anyEntryNotFalse(setsInBank) then
		AddCustomSubMenuItem(string.format("%s (%s)", GS(SI_MASTER_WRIT_DESCRIPTION_SET), GS(SI_BAG2)), createSubMenu(setsInBank))
		needsSeparator = true
	end
	if needsSeparator then AddCustomMenuItem("-", function() end) end
	
	local itemLinkCurrentlyWorn = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT)
	if itemLinkCurrentlyWorn ~= "" then
		AddCustomMenuItem(GS(SI_CHARACTER_EQUIP_TITLE), function() CSPS.setGearSlotFromBagWorn(gearSlot) hideGearWindow() end)
		AddCustomMenuTooltip(function(itemControl, inside) 
				if not inside then ZO_Tooltips_HideTextTooltip() return end
				InitializeTooltip(InformationTooltip, itemControl, LEFT)
				if not addTooltipItemInfo(itemLinkCurrentlyWorn, nil, nil, gearSlotsBody[gearSlot] and GetItemLinkArmorType(itemLinkCurrentlyWorn), nil) then -- returns if item is mara
					addTooltipTraitInfoFromItemLink(itemLinkCurrentlyWorn)
					addTooltipEnchantFromItemLink(itemLinkCurrentlyWorn)
				end
			end)
	end
	if #setItemsInventory > 0 then
		AddCustomSubMenuItem(string.format("%s (%s)", GS(SI_INVENTORY_MODE_ITEMS), GS(SI_BAG1)), createSubMenuForItems(setItemsInventory))
	end
	if #setItemsBank > 0 then
		AddCustomSubMenuItem(string.format("%s (%s)", GS(SI_INVENTORY_MODE_ITEMS), GS(SI_BAG2)), createSubMenuForItems(setItemsBank))
	end
	
	if setDirectly and control then
		local equipItem = control.equipItem
		local retrieveItem = control.retrieveItem
		local couldFits = control.couldFits
		
		AddCustomMenuItem("-", function() end)
		AddCustomMenuItem(GS(SI_SAVING_EDIT_BOX_EDIT), function() editFunc(control, gearSlot) end)

		if equipItem or retrieveItem then
			AddCustomMenuItem("-", function() end)
			if equipItem then
				AddCustomMenuItem(GS(SI_ITEM_ACTION_EQUIP), function() EquipItem(unpack(equipItem)) end)
			end
			if retrieveItem then
				AddCustomMenuItem(GS(SI_BANK_WITHDRAW), 
					function() 
						CSPS.moveItem(retrieveItem[1], retrieveItem[2], BAG_BACKPACK)
					end)
			end
		elseif couldFits and (#couldFits[BAG_BACKPACK] > 0 or GetInteractionType() == INTERACTION_BANK) then
			AddCustomMenuItem("-", function() end)
			if #couldFits[BAG_BACKPACK] > 0 then
				for i, v in pairs(couldFits[BAG_BACKPACK]) do
					AddCustomMenuItem(string.format(GS(CSPS_GEAR_EquipSimilar), i), function() EquipItem(BAG_BACKPACK, v.slotIndex, gearSlot) end)
					
					AddCustomMenuTooltip(function(itemControl, inside) 
						if not inside then ZO_Tooltips_HideTextTooltip() return end
						InitializeTooltip(InformationTooltip, itemControl, LEFT)
						--ttAddLine(v.itemLink)
						addTooltipItemInfo(v.itemLink, nil, nil, gearSlotsBody[gearSlot] and GetItemLinkArmorType(v.itemLink), nil)
						ttAddLine(v.differences, nil, ZO_ERROR_COLOR)
					end)
				end
			else
				local entryIndex = 0
				for _, bagId in pairs({BAG_BANK, BAG_SUBSCRIBER_BANK}) do
					if #couldFits[bagId] > 0 then
						for i, v in pairs(couldFits[bagId]) do
							entryIndex = entryIndex + 1
							AddCustomMenuItem(string.format(GS(CSPS_GEAR_WithdrawSimilar), entryIndex), function() 
								CSPS.moveItem(bagId, v.slotIndex, BAG_BACKPACK)
							end)
							AddCustomMenuTooltip(function(itemControl, inside) 
								if not inside then ZO_Tooltips_HideTextTooltip() return end
								InitializeTooltip(InformationTooltip, itemControl, LEFT)
								--ttAddLine(v.itemLink)
								addTooltipItemInfo(v.itemLink, nil, nil, gearSlotsBody[gearSlot] and GetItemLinkArmorType(v.itemLink), nil)
								ttAddLine(v.differences, nil, ZO_ERROR_COLOR)
							end)
						end
					end
				end
			end
			AddCustomMenuItem("-", function() end)
		end
		
		if theGear[gearSlot] then
			if theGear[gearSlot].recon or theGear[gearSlot].craft then 
				local reconData = theGear[gearSlot].recon
				AddCustomMenuItem(reconData and string.format("%s (%s)", GS(SI_RETRAIT_STATION_PERFORM_RECONSTRUCT), reconData.currencyFormatted) or GS(CSPS_AddToCraftlist), 
					function() addToCraftlist(gearSlot) end)
			end
			AddCustomMenuItem(GS(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(theGear[gearSlot].link) end)
		end
	end
	
	ShowMenu()
			
end

function CSPS.InitGearWindow(control)
	ctrGear.title = control:GetNamedChild("Title")
	local setText = control:GetNamedChild("SetsEdit")
	ctrGear.sets = {box = setText, label = GetControl(control, "SetsLabel")}
	ctrGear.type = GetControl(control, "Type")
	ctrGear.quality = GetControl(control, "Quality")
	ctrGear.trait = GetControl(control, "Trait")
	ctrGear.enchant = GetControl(control, "Enchantment")
	ctrGear.window = control
	ctrGear.btnOK = GetControl(control, "Ok")
	ctrGear.btnRemove = GetControl(control, "Remove")
	ctrGear.gearStuff = GetControl(control, "SetItemFields")
	ctrGear.poisonStuff = GetControl(control, "PoisonFields")
	ctrGear.poisonList = GetControl(control, "PoisonFieldsList")
	CSPS.ctrPoisonList = CSPSGearSelectorPoisonList:New(ctrGear.poisonStuff)
		
	--setText.data = setText.data or {}
	--setText.data.tooltipText = GS(SI_ITEM_SETS_BOOK_TITLE)
	--setText:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	--setText:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)


	local itemSetNameAutoComplete = ZO_AutoComplete:New(setText, NO_INCLUDE_FLAGS, NO_EXCLUDE_FLAGS, DEFAULT_ONLINE_ONLY, MAX_RESULTS, AUTO_COMPLETION_AUTOMATIC_MODE, AUTO_COMPLETION_USE_ARROWS)
	
	local setOptions = {}

	itemSetNameAutoComplete.GetAutoCompletionResults = function(autoCompleControl, text)
		setOptions = getSetAutoCompleteOptions(gearSelector.gearSlot)
		local results = {}
		if #text < 4 then 
			for i, v in pairs(setOptions) do
				if string.lower(string.sub(i, 1, #text)) == string.lower(text) then table.insert(results, i) end
				
			end
		else
			for i, v in pairs(setOptions) do
				if string.find(string.lower(i), string.lower(text), 1, true) then table.insert(results, i) end
			end
		end
		table.sort(results)
		if #results > 20 then 
			for i=21, #results do
				table.remove(results, 21)
			end
		end
		return unpack(results)
	end

	setText:SetHandler("OnTextChanged", 
		function() 
				local setId = setOptions[setText:GetText()] 
				setSetId(setId and setId or false)
			end, "getSetNameResult")
	setText:SetHandler("OnMouseUp",
		function(_, mouseButton, upInside)
			if upInside and mouseButton == 2 then showSetContextMenu() end
		end)
		
	control:GetNamedChild("BtnListSelect"):SetHandler("OnClicked",
		function()
			if gearSlotsPoison[gearSelector.gearSlot] then 
				showPoisonMenu()
			else
				showSetContextMenu()
			end
		end)
	for _, v in pairs(vCategories) do
		ctrGear[v]:SetHandler("OnMouseUp", function(_, mouseButton, upInside) 
			if upInside then showVCatMenu(v) end
		end)
	end
end

local function clickOutsideGearWindow(anchorControl)
	local control = WINDOW_MANAGER:GetMouseOverControl()
	for i = 1, 15 do
		if control == CSPS.gearWindow or control == ZO_Menu then return end
		local controlName = control:GetName()
		if string.sub(controlName, 1, 10) == "ZO_SubMenu" or string.sub(controlName, 1, 16) == "ZO_CustomSubMenu" or string.sub(controlName, 1, 11) == "ZO_ComboBox" then return end
		if anchorControl and control == anchorControl then return end
		if control == control:GetParent() then break end
		control = control:GetParent()
		if control == nil then break end
	end
	hideGearWindow()
end


function CSPS.showGearWin(control, gearSlot)
	if not CSPS.gearWindow then CSPS.gearWindow = WINDOW_MANAGER:CreateControlFromVirtual("CSPSWindowGearWindow", CSPSWindow, "CSPSGearWindow") end
	
	CSPS.gearWindow:ClearAnchors()
	if control then 
		CSPS.gearWindow:SetAnchor(RIGHT, control, LEFT, -10, 0)
		CSPS.gearWindow:SetAnchor(LEFT, CSPSWindow, CENTER, -100, 0, ANCHOR_CONSTRAINS_X)
	end
	gearSelector.gearSlot = gearSlot
	CSPS.refreshTree()
	local mySetItem = theGear[gearSlot] or {}
	local _, setOptionsT = getSetAutoCompleteOptions(gearSlot)
	
	if gearSlotsPoison[gearSlot] then 
		ctrGear.title:SetText(GS(SI_ITEMTYPEDISPLAYCATEGORY23))
		ctrGear.gearStuff:SetHidden(true)
		ctrGear.poisonStuff:SetHidden(false)
		CSPS.gearWindow:SetHeight(420)
	else
		ctrGear.title:SetText(GS(SI_ITEM_SETS_BOOK_TITLE))
		ctrGear.gearStuff:SetHidden(false)
		CSPS.gearWindow:SetHeight(139)
		ctrGear.poisonStuff:SetHidden(true)
		ctrGear.sets.box:SetText(mySetItem.setId and setOptionsT[mySetItem.setId] or "")
		for _, v in pairs(vCategories) do
			gearSelector[v] = mySetItem[v]
		end
		setSetId(not mySetItem.mara and mySetItem.setId)
		gearSelector.mara = mySetItem.mara
	end
	
	ctrGear.btnOK:SetHandler("OnClicked", function()
		if gearSlotsPoison[gearSelector.gearSlot] then
			if gearSelector.firstId then
				local myTable = {firstId = gearSelector.firstId, secondId = gearSelector.secondId or 0, link = gearSelector.link}
				theGear[gearSelector.gearSlot] = myTable
				hideGearWindow()
			end
		else
			if gearSelector.setId then
				local myTable = {}
				myTable.setId = gearSelector.setId
				myTable.quality = gearSelector.quality
				myTable.trait = gearSelector.trait
				myTable.enchant = gearSelector.enchant
				myTable.mara = gearSelector.mara
				if not gearSlotsJewelry[gearSelector.gearSlot] then myTable.type = gearSelector.type end
				local _, itemLink = getSetItemInfo(myTable, gearSelector.gearSlot)
				myTable.link = itemLink
				myTable.mythic = gearSelector.mythic 
				if myTable.mythic then removeExistingMythics(gearSelector.gearSlot) end
				theGear[gearSelector.gearSlot] = myTable
				hideGearWindow()
			end
		end
	end)
	
	ctrGear.btnRemove:SetHandler("OnClicked", function()
		theGear[gearSelector.gearSlot] = false
		hideGearWindow()
	end)
	
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."GearWinHider", EVENT_GLOBAL_MOUSE_DOWN, function() clickOutsideGearWindow(control) end)
	CSPS.gearWindow:SetHidden(false)
end


function CSPS.buildGearString()
	local myGearString = {}
	local myGearStringUnique = {}
	local numberOfItems = 0
	for _, gearSlot in pairs(gearSlots) do
		local slotTable = theGear[gearSlot]
		if slotTable then numberOfItems = numberOfItems + 1 end
		if gearSlotsPoison[gearSlot] then
			table.insert(myGearString, slotTable and 
				string.format("%s:%s",
					slotTable.firstId or 0,
					slotTable.secondId or 0)
			or 0)
		elseif type(slotTable) == "table" and slotTable.mara then
			table.insert(myGearString, "mara:44904")
		else
			table.insert(myGearString, slotTable and
				-- setId, type, trait, quality, enchantId
				string.format("%d:%d:%d:%d:%d", 
					slotTable.setId or 0,
					slotTable.type or 0,
					slotTable.trait or 0,
					slotTable.quality or 0,
					slotTable.enchant or 0) or 0)
			
			table.insert(myGearStringUnique, slotTable and slotTable.itemUniqueID or 0)
			
		end
	end
	myGearStringUnique = table.concat(myGearStringUnique, ";") or nil
	myGearString = table.concat(myGearString, ";")
	
	return myGearString, myGearStringUnique, numberOfItems
end

local function checkPoisonForTable(itemLink, myTable)
	if not myTable then return false, false end
	local firstId = GetItemLinkItemId(itemLink)
	local secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
	return myTable.firstId == firstId, myTable.secondId == secondId
end

local function checkItemForSlot(itemLink, mySlot)
	local myTable = mySlot and theGear[mySlot]
	if not myTable then return false, false, false, false, false end
	if myTable.mara then return GetItemLinkItemId(itemLink) == 44904, true, true, true, true end
	
	local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
	local setIdFits = setId == myTable.setId
	
	local qualityFits = GetItemLinkDisplayQuality(itemLink) == myTable.quality 
	local enchantFits = GetItemLinkFinalEnchantId(itemLink) == myTable.enchant 
	
	local typeFits = gearSlotsBody[mySlot] and GetItemLinkArmorType(itemLink) == myTable.type or 
		gearSlotsHands[mySlot] and GetItemLinkWeaponType(itemLink) == myTable.type or gearSlotsJewelry[mySlot] or false
	
	local traitFits = myTable.trait == GetItemLinkTraitInfo(itemLink)
	
	return setIdFits, enchantFits, qualityFits, typeFits, traitFits
end

CSPS.checkItemForSlot = checkItemForSlot

local function findSetItem(mySlot, findNew, includeDifferences)
	if not mySlot then return false, false, false, false, false end
	local bagIds = {BAG_BACKPACK, BAG_BANK,  BAG_SUBSCRIBER_BANK }
	local fitsExactly, couldFit = {}, {}
	local uniqueIdToFind = theGear[mySlot].itemUniqueID or false
	local foundNotUnique = false	
	theGear[mySlot].fitsExactly = not findNew and theGear[mySlot].fitsExactly or {}
	local lastFits = theGear[mySlot].fitsExactly
	
	for _, bagId in pairs(bagIds) do
		fitsExactly[bagId] = {}
		couldFit[bagId] = {}
	end
	cspsD("Looking for item for slot "..mySlot)
	for _, bagId in pairs(bagIds) do
		cspsD("Looking for item in bag "..bagId)
		local isBackpack = bagId == BAG_BACKPACK 
		
		local lastFitBag = lastFits and lastFits[isBackpack]
		
		if lastFitBag and lastFitBag.itemLink == GetItemLink(lastFitBag.bagId, lastFitBag.slotIndex, 1) then
			if not uniqueIdToFind or not foundNotUnique or isBackpack then
				fitsExactly[lastFitBag.bagId] = {lastFitBag}
				cspsD("Found exact item in list of items found in previous search.")
				return fitsExactly, couldFit
			end
		else

			lastFits[isBackpack] = false
		end

		
		for slotIndex = 0, GetBagSize(bagId) do
			local itemLink = GetItemLink(bagId, slotIndex, 1)
			if uniqueIdToFind then
				local itemUniqueID = Id64ToString(GetItemUniqueId(bagId, slotIndex))
				if itemUniqueID == uniqueIdToFind then
					fitsExactly[bagId] = {{slotIndex = slotIndex, itemLink = itemLink}}
					lastFits[isBackpack] = {slotIndex = slotIndex, itemLink = itemLink, bagId = bagId}
					for _, otherBag in pairs(bagIds) do
						if otherBag ~= bagId then fitsExactly[otherBag] = {} end
					end
					cspsD("Found exact item with unique id.")
					return fitsExactly, couldFit, true -- third parameter to indicated we found the unique item
				end
			end
			local equipType = GetItemLinkEquipType(itemLink)
			if equipType and equipType ~= 0 and equipSlotToEquipType[mySlot][equipType] then
				if equipType == EQUIP_TYPE_POISON then
					local fit1, fit2 = checkPoisonForTable(itemLink, theGear[mySlot])
					if fit1 and not checkItemLevel(itemLink, true) then
						if fit2 then
							table.insert(fitsExactly[bagId], {slotIndex = slotIndex, itemLink = itemLink})
							lastFits[isBackpack] = {slotIndex = slotIndex, itemLink = itemLink, bagId = bagId}
							cspsD("Found exact potion, stop search and return lists.")
							return fitsExactly, couldFit
						else
						
							--- TODO    TODO    TODO ---
							---  differences!!
							---------------------------
							
							table.insert(couldFit[bagId], {slotIndex = slotIndex, itemLink = itemLink, differences = ""})
						end
					end
				else
					local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(itemLink, mySlot)
					if setIdFits and typeFits and not checkItemLevel(itemLink, true) then
						if enchantFits and qualityFits and traitFits then
							table.insert(fitsExactly[bagId], {slotIndex = slotIndex, itemLink = itemLink})
							lastFits[isBackpack] = {slotIndex = slotIndex, itemLink = itemLink, bagId = bagId}
							if not uniqueIdToFind then 
								cspsD("Found exact item, stop search and return lists.")
								return fitsExactly, couldFit 
							elseif not isBackpack then
								foundNotUnique = true 
							end
							
						else
							local itemDifferences = false
							if includeDifferences then
								itemDifferences = {}
								if not qualityFits then 
									table.insert(itemDifferences, GS("SI_ITEMDISPLAYQUALITY", GetItemLinkDisplayQuality(itemLink)))
								end
								if not traitFits then
									table.insert(itemDifferences, GS("SI_ITEMTRAITTYPE", GetItemLinkTraitInfo(itemLink)))
								end
								if not enchantFits then 
									local _, enchantHeader = GetItemLinkEnchantInfo(itemLink)
									table.insert(itemDifferences, enchantHeader)
								end
								itemDifferences = table.concat(itemDifferences, "/")
							end
							table.insert(couldFit[bagId], {slotIndex = slotIndex, itemLink = itemLink, differences = itemDifferences})
						end
					end
				end
			end
		end
	end
	cspsD("Search complete. Return lists.")
	return fitsExactly, couldFit
end

CSPS.findSetItem = findSetItem

local function showPoisonTooltip(control, gearSlot, firstId, secondId)
	if not firstId then return end
	local itemLink = string.format(poisonItemLink, firstId, secondId or 0)
	InitializeTooltip(InformationTooltip, control, gearSlot and LEFT or RIGHT)
	local icon = GetItemLinkIcon(itemLink)
	local r,g,b = GetItemQualityColor(GetItemLinkDisplayQuality(itemLink)):UnpackRGB()
	
	local fit1, fit2 = checkPoisonForTable(GetItemLink(BAG_WORN, gearSlot), {firstId = firstId, secondId = secondId})
	if gearSlot and (not fit1 or not fit2) then r,g,b = ZO_ERROR_COLOR:UnpackRGB() end
	
	InformationTooltip:AddLine(zo_strformat("|t28:28:<<1>>|t <<C:2>>", icon , GetItemLinkName(itemLink)), "ZoFontWinH2", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
	local _, _, onUseText = GetItemLinkOnUseAbilityInfo(itemLink)				
	if onUseText and onUseText ~= "" then 
		InformationTooltip:AddLine(onUseText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
	end
	for i=1, 10 do
		local hasAb, abText = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
		if not hasAb then break end
		if abText and abText ~= "" then 
			InformationTooltip:AddLine(abText, "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true) 
		else 
			break
		end
	end
	
	
	if gearSlot and (not fit1 or not fit2) then
		local fitsExactly, couldFit = findSetItem(gearSlot)
		if #fitsExactly[BAG_BACKPACK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			InformationTooltip:AddLine(string.format("|t26:26:esoui/art/tooltips/icon_bag.dds|t %s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", fitsExactly[BAG_BACKPACK][1].itemLink, GS(SI_ITEM_ACTION_EQUIP)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
			control.equipItem = {BAG_BACKPACK, fitsExactly[BAG_BACKPACK][1].slotIndex, gearSlot}
		elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
			ZO_Tooltip_AddDivider(InformationTooltip)
			r, g, b = ZO_NORMAL_TEXT:UnpackRGB()
			local fittingItem = fitsExactly[BAG_BANK][1] or fitsExactly[BAG_SUBSCRIBER_BANK][1]
			local bagId = #fitsExactly[BAG_BANK] > 0 and BAG_BANK or BAG_SUBSCRIBER_BANK
			control.retrieveItem = {bagId, fittingItem.slotIndex}
			InformationTooltip:AddLine(string.format("|t26:26:esoui/art/tooltips/icon_bank.dds|t %s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t: %s", fittingItem.itemLink, GS(SI_BANK_WITHDRAW)), "ZoFontGame", r, g, b, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
		end
	end
end

CSPS.showPoisonTooltip = showPoisonTooltip	

local function addInventoryInfo(gearSlot, parentControl)
	
	local fitsExactly, couldFit, foundUnique = findSetItem(gearSlot, false, true) -- last true = includeDifferences
	
	if #fitsExactly[BAG_BACKPACK] > 0 then
		ZO_Tooltip_AddDivider(InformationTooltip)
		local iconUnique = foundUnique and " |t26:26:esoui/art/tooltips/icon_lock.dds|t" or ""
		ttAddLine(string.format("|t26:26:esoui/art/tooltips/icon_bag.dds|t%s %s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", iconUnique, fitsExactly[BAG_BACKPACK][1].itemLink, GS(SI_ITEM_ACTION_EQUIP)))
		parentControl.equipItem = {BAG_BACKPACK, fitsExactly[BAG_BACKPACK][1].slotIndex, gearSlot}
		return true
	end
	if #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
		ZO_Tooltip_AddDivider(InformationTooltip)
		local fittingItem = fitsExactly[BAG_BANK][1] or fitsExactly[BAG_SUBSCRIBER_BANK][1]
		local myItemText = string.format("|t26:26:esoui/art/tooltips/icon_bank.dds|t %s", fittingItem.itemLink)
		
		if GetInteractionType() == INTERACTION_BANK then
			myItemText = string.format("%s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", myItemText, GS(SI_ITEM_ACTION_BANK_WITHDRAW))
			parentControl.retrieveItem = {fitsExactly[BAG_BANK][1] and BAG_BANK or BAG_SUBSCRIBER_BANK, fittingItem.slotIndex}				
		end
		
		ttAddLine(myItemText)
		return true
	end
	
	if #couldFit[BAG_BACKPACK] == 0 and #couldFit[BAG_BANK] == 0 and #couldFit[BAG_SUBSCRIBER_BANK] == 0 then return false end
	ZO_Tooltip_AddDivider(InformationTooltip)
	
	local function addBagCouldFits(bagId, bagIcon)
		for i, v in pairs(couldFit[bagId]) do
			ttAddLine(string.format("|t26:26:esoui/art/tooltips/%s.dds:inheritcolor|t %s (%s)", bagIcon, v.itemLink, ZO_ERROR_COLOR:Colorize(v.differences or "-")), "ZoFontGameSmall", ZO_ORANGE)
		end
	end
	
	parentControl.couldFits = couldFit
	
	addBagCouldFits(BAG_BACKPACK, "icon_bag")
	addBagCouldFits(BAG_BANK, "icon_bank")
	addBagCouldFits(BAG_SUBSCRIBER_BANK, "icon_bank")
		
	return false
end

local function showSetItemTooltip(control, setId, gearSlot, itemType,  traitType, itemQuality, enchantId)
	local myTable = theGear[gearSlot]
	if not myTable then return false end
	local parentControl = control:GetParent()
	if WINDOW_MANAGER:GetMouseOverControl():GetParent() ~= parentControl then return false end
	
	InitializeTooltip(InformationTooltip, control, LEFT)
	
	local icon, itemLink, pieceId, setSlot = getSetItemInfo(setId or 0, gearSlot, itemType,  traitType, itemQuality, enchantId)

	local wornItem = GetItemLink(BAG_WORN, gearSlot)
	local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(wornItem, gearSlot)
	local warnLevel, levelText = checkItemLevel(wornItem)
	
	local isMara = addTooltipItemInfo(itemLink, itemQuality, icon, gearSlotsBody[gearSlot] and itemType or false, not setIdFits, typeFits, qualityFits, warnLevel, levelText)
		
	if not isMara then 
		ZO_Tooltip_AddDivider(InformationTooltip)
			
		if traitType then
			r,g,b =  trueFalseColors[traitFits]:UnpackRGB()
			addTooltipTraitInfoFromItemLink(itemLink, traitType, r,g,b)
		end

		r,g,b =  trueFalseColors[enchantFits]:UnpackRGB()
		addTooltipEnchantFromItemLink(itemLink, r,g,b)

		addTooltipSetInfo(itemLink, gearSlot)
	end
	
	myTable.recon = nil
	
	if not (setIdFits and enchantFits and qualityFits and typeFits and traitFits) or myTable.itemUniqueID and myTable.itemUniqueID ~= Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot)) then 
		
		if addInventoryInfo(gearSlot, parentControl) then ttAddLine(GS(CSPS_RMB_MENU)) return end
		
		local myItemText = false
		if GetItemSetType(setId) == ITEM_SET_TYPE_CRAFTED then
			myTable.craft = true
			myItemText = GS(SI_ITEM_FORMAT_STR_CRAFTED)
			local traitsNeeded = LibSets and LibSets.GetTraitsNeeded(setId)
			if traitsNeeded then 
				local canCraft = CSPS.canCraftSetItem(setId, gearSlot, gearSlotsBody[gearSlot] and itemType, gearSlotsHands[gearSlot] and itemType)
				if canCraft ~= nil then traitsNeeded = trueFalseColors[canCraft]:Colorize(traitsNeeded) end
				myItemText = string.format("%s (%s)", myItemText, traitsNeeded) 
			end
			local mySetZoneIds = LibSets and LibSets.GetZoneIds(setId)
			if mySetZoneIds then
				local zoneIdsChecked = {}
				local setZoneNames = {}
				for i, v in pairs(mySetZoneIds) do
					if not zoneIdsChecked[v] then
						zoneIdsChecked[v] = true
						table.insert(setZoneNames, zo_strformat("<<C:1>>", GetZoneNameById(v)))
					end
				end
				if #setZoneNames > 0 then
					myItemText = string.format("%s:\n%s", myItemText, table.concat(setZoneNames, ", "))
				end
			end
			local traitKnown = CSPS.canCraftTrait(gearSlot, gearSlotsBody[gearSlot] and itemType, gearSlotsHands[gearSlot] and itemType, traitType)
			if traitKnown ~= nil then 
				myItemText = string.format("%s\n%s: %s", myItemText, 
					GS(SI_MASTER_WRIT_DESCRIPTION_TRAIT), trueFalseColors[traitKnown]:Colorize(GS("SI_ITEMTRAITTYPE", traitType)))
			end
			myItemText = string.format("%s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", myItemText, GS(CSPS_AddToCraftlist))
		else
			local categoryId = GetItemSetCollectionCategoryId(setId)
			if categoryId and categoryId ~= 0 then
				myItemText = zo_strformat("<<C:1>>: <<C:2>>", 
					GetItemSetCollectionCategoryName(GetItemSetCollectionCategoryParentId(categoryId)),
					GetItemSetCollectionCategoryName(categoryId))
			end	
			if setSlot and IsItemSetCollectionSlotUnlocked(setId, setSlot) then
				local reconCurrencies, reconCurrenciesFormatted = {}, {} -- all of this is not needed right now, but it seems like they might add more currencies some day...
				for i=1, GetNumItemReconstructionCurrencyOptions() do
					local currencyType = GetItemReconstructionCurrencyOptionType(i)
					local cost = GetItemReconstructionCurrencyOptionCost(setId, currencyType)
					local currencyIcon = ZO_Currency_GetPlatformCurrencyIcon(currencyType)
					cost = ((GetPlayerStoredCurrencyAmount(currencyType) < cost) and ZO_ERROR_COLOR or ZO_SUCCEEDED_TEXT):Colorize(cost)
					if currencyType ~= 0 then 
						table.insert(reconCurrenciesFormatted, string.format("%s |t22:22:%s|t", cost, currencyIcon))
						table.insert(reconCurrencies, currencyType)
					end
				end
				if #reconCurrencies > 0 then
					myItemText = myItemText and myItemText.."\n" or ""
					myItemText = string.format("%s%s: %s", myItemText, GS(SI_RETRAIT_STATION_PERFORM_RECONSTRUCT), table.concat(reconCurrenciesFormatted, ", "))
					myItemText = string.format("%s\n|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", myItemText, GS(CSPS_AddToCraftlist))
					myTable.recon = {setId = setId, pieceId = pieceId, traitType = traitType, itemQuality = itemQuality, currencyType = reconCurrencies[1], currencyFormatted = reconCurrenciesFormatted[1]}
				end
			end
		end
		if myItemText then 
			ZO_Tooltip_AddDivider(InformationTooltip)
			ttAddLine(myItemText)
		end
	end

	ttAddLine(GS(CSPS_RMB_MENU))
end

function CSPS.extractGearString(myGearString, myGearStringUnique)
	local myGear = {}
	if not myGearString or myGearString == "" or myGearString == "-" then
		for i, gearSlot in pairs(gearSlots) do
			myGear[gearSlot] = false	
		end
		return myGear
	end
	local singleUniqueStrings = myGearStringUnique and myGearStringUnique ~= "-" and {SplitString(";", myGearStringUnique)} or {}
	local singleGearStrings = {SplitString(";", myGearString)}
	for i, gearSlot in pairs(gearSlots) do
		if singleGearStrings[i] == "0" then
			myGear[gearSlot] = false		
		else
			local singleSlotTable = {SplitString(":", singleGearStrings[i])}
			local itemUniqueID = singleUniqueStrings[i] ~= "0" and singleUniqueStrings[i]
			if gearSlotsPoison[gearSlot] then
				myGear[gearSlot] = {
					firstId = tonumber(singleSlotTable[1]) or 0,
					secondId = tonumber(singleSlotTable[2]) or 0,
				}
			elseif singleSlotTable[1] == "mara" then
				myGear[gearSlot] = {
					setId = maraId,
					mara = true,
					link = buildCraftedItemLink(maraId),
					itemUniqueID = itemUniqueID,
				}
			else
				myGear[gearSlot] = {
					setId = tonumber(singleSlotTable[1]),
					type = tonumber(singleSlotTable[2]),
					trait = tonumber(singleSlotTable[3]),
					quality = tonumber(singleSlotTable[4]),
					enchant = tonumber(singleSlotTable[5]),
					itemUniqueID = itemUniqueID,
				}
				local gearItem = myGear[gearSlot]
				local _, itemLink = getSetItemInfo(gearItem, gearSlot)
				gearItem.link = itemLink
				
				if gearSlotsJewelry[gearSlot] then gearItem.type = nil end
			end
		end
	end
	return myGear
end

local function setMara(gearSlot, itemLink, itemUniqueID)
	theGear[gearSlot] = {mara = true, setId = maraId, link = itemLink, itemUniqueID = itemUniqueID}
end

local function setPoisonFromIdAndLink(gearSlot, itemLink, itemId)
	itemId = itemId or GetItemLinkItemId(itemLink)
	theGear[gearSlot] = {
		firstId = itemId,
		secondId = tonumber(string.match(itemLink, ":(%d+)|")) or 0
	}
end

local function setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
	theGear[gearSlot] = {}
	local slotTable = theGear[gearSlot]
	local hasSetInfo, _, _, _, neededNumber, itemSetId = GetItemLinkSetInfo(itemLink, false)
	slotTable.setId = hasSetInfo and itemSetId or 0
	slotTable.quality = GetItemLinkDisplayQuality(itemLink)
	if slotTable.quality == ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE then slotTable.mythic = true end
	if slotTable.mythic then removeExistingMythics(gearSlot) end
	local enchantId = GetItemLinkFinalEnchantId(itemLink)
	slotTable.enchant = enchantId
	slotTable.trait = GetItemLinkTraitInfo(itemLink)
	slotTable.link = itemLink
	slotTable.itemUniqueID = itemUniqueID
	if gearSlotsBody[gearSlot] then
		slotTable.type = GetItemLinkArmorType(itemLink)
	elseif gearSlotsHands[gearSlot] then
		local weaponType = GetItemLinkWeaponType(itemLink)
		slotTable.type = weaponType
	end
end

local function removeDuplicateUniqueId(itemUniqueID)
	for gearSlot, gearData in pairs(theGear) do
		if gearData and gearData.itemUniqueID == itemUniqueID then theGear[gearSlot] = false end
	end
end

function CSPS.setGearFromWizards(gearSetup)
	for _, gearSlot in pairs(gearSlots) do
		local gearData = gearSetup[gearSlot]
		if gearData then
			if gearData.id == "0" then
				theGear[gearSlot] = false
			elseif gearSlotsPoison[gearSlot] then
				setPoisonFromIdAndLink(gearSlot, gearData.link)
			elseif GetItemLinkItemId(gearData.link) == maraId then
				setMara(gearSlot, gearData.link, gearData.id)
			else
				setArmorOrWeaponFromLink(gearSlot, gearData.link, gearData.id)
			end
		end
	end
end


local function setFromBagAndSlot(gearSlot, bagId, slotIndex)
	local itemLink = GetItemLink(bagId, slotIndex)
	local itemType = GetItemType(bagId, slotIndex)
	local itemUniqueID = Id64ToString(GetItemUniqueId(bagId, slotIndex))
	itemUniqueID = itemUniqueID ~= "0" and itemUniqueID or false
	local itemId = GetItemId(bagId, slotIndex)
	
	if gearSlotsPoison[gearSlot] then
		if itemType ~= ITEMTYPE_POISON then return false end
		setPoisonFromIdAndLink(gearSlot, itemLink, itemId)
		CSPS.refreshTree()
		
		return true
	end
	
	local equipType = GetItemLinkEquipType(itemLink)
	
	if gearSlotsHands[gearSlot] then
		if itemType ~= ITEMTYPE_WEAPON then return false end
		if not equipSlotToEquipType[gearSlot][equipType] then return false end
		local weaponType = GetItemLinkWeaponType(itemLink)
		local slotToClearReverse = {
			[EQUIP_SLOT_BACKUP_OFF]  = EQUIP_SLOT_BACKUP_MAIN,
			[EQUIP_SLOT_OFF_HAND] = EQUIP_SLOT_MAIN_HAND,
		}
		if isTwoHanded[weaponType] then
			local slotToClear = {
				[EQUIP_SLOT_BACKUP_MAIN]  = EQUIP_SLOT_BACKUP_OFF,
				[EQUIP_SLOT_MAIN_HAND] = EQUIP_SLOT_OFF_HAND,
			}
			if slotToClear[gearSlot] then theGear[slotToClear[gearSlot]] = false end
		elseif slotToClearReverse[gearSlot] then
			local weaponTypeMain = theGear[slotToClearReverse[gearSlot]]
			weaponTypeMain = weaponTypeMain and weaponTypeMain.type
			weaponTypeMain = weaponTypeMain and isTwoHanded[weaponTypeMain]
			if weaponTypeMain then theGear[slotToClearReverse[gearSlot]] = false end
		end
		if itemUniqueID then removeDuplicateUniqueId(itemUniqueID) end
		setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
		CSPS.refreshSetCount()
		CSPS.refreshTree()
		return true
	end
	
	if itemType ~= ITEMTYPE_ARMOR then return false end
	if not equipSlotToEquipType[gearSlot][equipType] then return false end
	
	if itemId == maraId then 
		if itemUniqueID then removeDuplicateUniqueId(itemUniqueID) end
		setMara(gearSlot, itemLink, itemUniqueID) 
	else	
		if itemUniqueID then removeDuplicateUniqueId(itemUniqueID) end
		setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
	end
	CSPS.refreshSetCount()
	CSPS.refreshTree()
	return true
end

CSPS.setFromBagAndSlot = setFromBagAndSlot

local function receiveDrag(gearSlot)
	local acceptedCursorContentTypes = {[MOUSE_CONTENT_INVENTORY_ITEM] = true, [MOUSE_CONTENT_EQUIPPED_ITEM] = true}
	if not acceptedCursorContentTypes[GetCursorContentType()] then return false end

	local bagId = GetCursorBagId()
	local slotIndex = GetCursorSlotIndex()
	ClearCursor()
		
	setFromBagAndSlot(gearSlot, bagId, slotIndex)
		
end

local function setIndicators(control, myItemFitIndicator, customItemIndicator, indTooltip)
	control.ctrIndicator:SetTexture(myItemFitIndicator.texture)
	control.ctrIndicator:SetColor(myItemFitIndicator.color:UnpackRGB())
	
	control.ctrIndicator:SetHidden(false)
	control.ctrIndicator2:SetHidden(not customItemIndicator)
	control.ctrIndicator:SetHandler("OnMouseEnter", function()
		if not indTooltip or #indTooltip == 0 then return end
		ZO_Tooltips_ShowTextTooltip(control.ctrIndicator, RIGHT, table.concat(indTooltip, "\n"))
	end)
end

local function setupEmptyNode(control, mySlot)
	control.tooltipFunction = function(self) if control.canEdit then ZO_Tooltips_ShowTextTooltip(self, TOP, GS(CSPS_QS_TT_Edit)) end end
	control.tooltipExitFunction = function() ZO_Tooltips_HideTextTooltip() end
	control:SetHandler("OnMouseUp", 
		function(_, mouseButton, upInside)
			if not upInside then return end
			if mouseButton == 2 and control.canEdit then 
				if gearSlotsPoison[mySlot] then editFunc(control, mySlot) return end
				showSetContextMenu(mySlot, control) 
			end 
		end)
	control.ctrSetName:SetText("-")
	control.ctrIcon:SetTexture(string.format("esoui/art/characterwindow/%s.dds", gearSlotIcons[mySlot]))
	control.ctrTrait:SetHidden(true)
	control.ctrEnchantment:SetHidden(true)		
	control.ctrIndicator:SetHidden(true)
	control.ctrIndicator2:SetHidden(true)
end

local function checkPoisonItemData(control, mySlot, myTable)
	local fit1, fit2 = checkPoisonForTable(GetItemLink(BAG_WORN, mySlot), myTable)
	if fit1 then return itemFitIndicators[fit2 and 1 or 2] end
	
	local fitsExactly, couldFit, fitsUnique = findSetItem(mySlot)
	if #fitsExactly[BAG_BACKPACK] > 0 then return itemFitIndicators[4] end
	if #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then return itemFitIndicators[5] end
	
	return itemFitIndicators[3]
end

local function setupPoisonNode(control, mySlot, myTable)
	local itemLink = string.format(poisonItemLink, myTable.firstId or 0, myTable.secondId or 0)
	control.ctrSetName:SetText(itemLink)
	control.ctrIcon:SetTexture(GetItemLinkIcon(itemLink))
	control.ctrTrait:SetHidden(true)
	control.ctrEnchantment:SetHidden(true)
	
	
	
	control.tooltipFunction = function(self)
		if not theGear[mySlot] then ZO_Tooltips_ShowTextTooltip(self, TOP, GS(CSPS_QS_TT_Edit)) return end
		showPoisonTooltip(control.ctrEnchantment, mySlot, myTable.firstId, myTable.secondId)
		InformationTooltip:AddLine(GS(CSPS_QS_TT_Edit))
	end
	
	control.tooltipExitFunction = function()
		control.retrieveItem = nil
		control.equipItem = nil
		control.couldFits = nil
		ZO_Tooltips_HideTextTooltip()
	end
	control:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
		if not upInside then return end
		if mouseButton == 1 then
			if control.equipItem then 
				EquipItem(unpack(control.equipItem))
				zo_callLater(function() showPoisonTooltip(control.ctrEnchantment, mySlot, myTable.firstId, myTable.secondId) end, 420)
				InformationTooltip:AddLine(GS(CSPS_QS_TT_Edit))
			elseif control.retrieveItem then
				CSPS.moveItem(control.retrieveItem[1], control.retrieveItem[2], BAG_BACKPACK)
				zo_callLater(function() showPoisonTooltip(control.ctrEnchantment, mySlot, myTable.firstId, myTable.secondId) end, 420)
			end
		elseif mouseButton == 2 and control.canEdit	then
			editFunc(control, mySlot)
		end
	end)
	setIndicators(control, checkPoisonItemData(control, mySlot, myTable))
end

local function checkGearItemData(control, mySlot, myTable, indTooltip)
	
	local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(GetItemLink(BAG_WORN, mySlot), mySlot)
	
	if setIdFits then --worn item
		
		control.ctrEnchantment:SetColor((enchantFits and ZO_SUCCEEDED_TEXT or ZO_ERROR_COLOR):UnpackRGB()) 
		control.ctrTrait:SetColor((traitFits and ZO_SUCCEEDED_TEXT or ZO_ERROR_COLOR):UnpackRGB())
		
		local uniqueIdFits = not myTable.itemUniqueID or myTable.itemUniqueID == Id64ToString(GetItemUniqueId(BAG_WORN, mySlot))
		if not uniqueIdFits then 
			local fitsExactly, _, foundUnique = findSetItem(mySlot, true)
			if foundUnique then table.insert(indTooltip, GS(CSPS_GEAR_NotUniqueWorn)) return #fitsExactly[BAG_BACKPACK] > 0 and itemFitIndicators[4] or itemFitIndicators[5] end
			table.insert(indTooltip, GS(CSPS_GEAR_NotUnique)) 
		end
		if not enchantFits or not traitFits or not qualityFits then 
			local fitsExactly, _, foundUnique = findSetItem(mySlot, true)
			if #fitsExactly[BAG_BACKPACK] > 0 then table.insert(indTooltip, GS(CSPS_GEAR_NotAllParametersWorn)) return itemFitIndicators[4] end 
			if #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then table.insert(indTooltip, GS(CSPS_GEAR_NotAllParametersWorn)) return itemFitIndicators[5] end
			table.insert(indTooltip, GS(CSPS_GEAR_NotAllParameters)) 
		end
		return uniqueIdFits and qualityFits and enchantFits and traitFits and itemFitIndicators[1] or itemFitIndicators[2]
	end
	control.ctrEnchantment:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
	control.ctrTrait:SetColor(ZO_NORMAL_TEXT:UnpackRGB())
	
	local fitsExactly, couldFit, foundUnique = findSetItem(mySlot)
	local uniqueIdFits = foundUnique or not myTable.itemUniqueID
	if not uniqueIdFits then table.insert(indTooltip, GS(CSPS_GEAR_NotUnique)) end
	if #fitsExactly[BAG_BACKPACK] > 0 then return itemFitIndicators[uniqueIdFits and 4 or 6] end
	if #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then return itemFitIndicators[uniqueIdFits and 5 or 7] end
	table.insert(indTooltip, GS(CSPS_GEAR_NotAllParameters))
	if #couldFit[BAG_BACKPACK] > 0 then return itemFitIndicators[6] end
	if #couldFit[BAG_BANK] > 0 or #couldFit[BAG_SUBSCRIBER_BANK] > 0 then return itemFitIndicators[7] end
	return itemFitIndicators[3]
end

local function NodeSetupGear(node, control, data, open, userRequested, enabled)
	--Entries in data: Text, Value, entrColor
	local mySlot = data.gearSlot
	control.ctrSelected:SetHidden(gearSelector.gearSlot ~= mySlot)
	control.ctrSelected:SetColor(CSPS.cpColors[6]:UnpackRGB())
	local myTable = theGear[mySlot]

	control.receiveDragFunction = function() receiveDrag(mySlot) end
	
	control.canEdit = not (mySlot == EQUIP_SLOT_BACKUP_OFF and theGear[EQUIP_SLOT_BACKUP_MAIN] and theGear[EQUIP_SLOT_BACKUP_MAIN].type and isTwoHanded[theGear[EQUIP_SLOT_BACKUP_MAIN].type] or
		mySlot == EQUIP_SLOT_OFF_HAND and theGear[EQUIP_SLOT_MAIN_HAND] and theGear[EQUIP_SLOT_MAIN_HAND].type and isTwoHanded[theGear[EQUIP_SLOT_MAIN_HAND].type]) 

	control.ctrBtnEdit:SetHidden(not control.canEdit)
	control.ctrIcon:SetMouseEnabled(control.canEdit)
	control.ctrSetName:SetMouseEnabled(control.canEdit)
	control.ctrBtnEdit:SetHandler("OnClicked", function() editFunc(control, mySlot) end)
	
	if not myTable then setupEmptyNode(control, mySlot) return end
		
	if gearSlotsPoison[mySlot] then setupPoisonNode(control, mySlot, myTable) return end
		
	control.ctrTrait:SetHidden(false)
	control.ctrEnchantment:SetHidden(false)			
	control.ctrIndicator2:SetHidden(myTable.itemUniqueID and true or false)
	--control.ctrSetName:SetText(zo_strformat("<<C:1>>", GetItemSetName(myTable.setId)))
	if myTable.setCountF and not CSPS.savedVariables.settings.hideNumSetItems then
		control.ctrSetName:SetText(string.format("%s (%s)", myTable.link, myTable.setCountF))
	else
		control.ctrSetName:SetText(myTable.link)
	end
	local itemIcon = getSetItemInfo(myTable.setId or 0, mySlot, myTable.type)
	if myTable.mara then
		itemIcon = GetItemLinkIcon(myTable.link)
	end
	control.ctrIcon:SetTexture(itemIcon)
	control.ctrTrait:SetText(GS("SI_ITEMTRAITTYPE", myTable.trait))
	control.ctrEnchantment:SetText(enchantNames[myTable.enchant])
	
	-- TOOLTIPS FOR GEAR ITEMS NEED TO BE A LITTLE BIGGER _ CONSTRAINTS HAVE TO BE RESET ON MOUSEEXIT
	local ttdc1, ttdc2, ttdc3, ttdc4 = false, false, false, false
	control.tooltipFunction = function()
		ttdc1, ttdc2, ttdc3, ttdc4 = InformationTooltip:GetDimensionConstraints()
		if not theGear[mySlot] then return end
		InformationTooltip:SetDimensionConstraints(ttdc1, ttdc2, 420, ttdc4)
		showSetItemTooltip(control.ctrEnchantment, myTable.setId, mySlot, myTable.type, myTable.trait, myTable.quality, myTable.enchant)
	end
	
	control.tooltipExitFunction = function()
		if ttdc1 then InformationTooltip:SetDimensionConstraints(ttdc1, ttdc2, ttdc3, ttdc4) end
		control.retrieveItem = nil
		control.equipItem = nil
		control.couldFits = nil
		if theGear[mySlot] then theGear[mySlot].recon = nil theGear[mySlot].craft = nil end
		ZO_Tooltips_HideTextTooltip()
	end
	
	control:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
		if not upInside then return end
		if mouseButton == 1 then
			if control.equipItem then
				local delay = theGear[mySlot].mythic and unequipExistingMythic(mySlot) and 500 or 0
				zo_callLater(function() EquipItem(unpack(control.equipItem)) end, delay)
				zo_callLater(function() showSetItemTooltip(control.ctrEnchantment, myTable.setId, mySlot, myTable.type, myTable.trait, myTable.quality, myTable.enchant) end, 420 + delay)
			elseif control.retrieveItem then
				CSPS.moveItem(control.retrieveItem[1], control.retrieveItem[2], BAG_BACKPACK)
				zo_callLater(function() showSetItemTooltip(control.ctrEnchantment, myTable.setId, mySlot, myTable.type, myTable.trait, myTable.quality, myTable.enchant) end, 420)
			end
			if theGear[mySlot] and (theGear[mySlot].recon or theGear[mySlot].craft) then 
				addToCraftlist(mySlot)
			end
		elseif mouseButton == 2 and control.canEdit then
			showSetContextMenu(mySlot, control)
		end
	end)
	
	control.ctrEnchantment:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
		if not upInside then return end
		showVCatMenu("enchant", mySlot, control)
		end)
	control.ctrTrait:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
		if not upInside then return end
		showVCatMenu("trait", mySlot, control)
		end)
	control.ctrIcon:SetHandler("OnMouseUp", function(_, mouseButton, upInside)
		if not upInside then return end
		if gearSlotsJewelry[mySlot] then
			showVCatMenu("quality", mySlot, control)
			return
		end
		local typeMenu = showVCatMenu("type", mySlot, control, true)
		local qualityMenu = showVCatMenu("quality", mySlot, control, true)
		ClearMenu()
		AddCustomSubMenuItem(GS(SI_SMITHING_HEADER_ITEM), typeMenu)
		AddCustomSubMenuItem(GS(SI_MASTER_WRIT_DESCRIPTION_QUALITY), qualityMenu)
		ShowMenu()
		end)
	
	local indTooltip = {}
		
	setIndicators(control, checkGearItemData(control, mySlot, myTable, indTooltip), not myTable.itemUniqueID, indTooltip)
	
end

local function doesWornItemFitSlot(gearSlot)
	if gearSlot == EQUIP_SLOT_POISON or gearSlot == EQUIP_SLOT_BACKUP_POISON then
		local fit1, fit2 = checkPoisonForTable(GetItemLink(BAG_WORN, gearSlot), theGear[gearSlot])
		return fit1 and fit2
	else
		local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(GetItemLink(BAG_WORN, gearSlot), gearSlot)
		return setIdFits and enchantFits and qualityFits and typeFits and traitFits
	end
end

CSPS.doesWornItemFitSlot = doesWornItemFitSlot

local function equipAllFittingGear(callAfterMythic)
	if not callAfterMythic then 
		for gearSlot, gearTable in pairs(theGear) do
			if gearTable and gearTable.mythic then
				if unequipExistingMythic(gearSlot) then
					zo_callLater(function() equipAllFittingGear(true) end, 500)
					return
				end
				break
			end
		end
	end
	local alreadyEquipped = {}
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable then
			
			if not doesWornItemFitSlot(gearSlot) then
				cspsD("Slot to change: "..gearSlot)
				local fitsExactly, couldFit = findSetItem(gearSlot, true)
				cspsD("Fits exactly:")
				cspsD(fitsExactly)
				cspsD("Could fit:")
				cspsD(couldFit)
				if #fitsExactly[BAG_BACKPACK] > 0 then
					cspsD(fitsExactly[BAG_BACKPACK])
					for _, fittingItem in pairs(fitsExactly[BAG_BACKPACK]) do
						-- since we`re equipping all items at once if there is one item fitting two slots (possible for rings or weapons) we have to check
						-- we have to iterate over the fitting items because they might still be there but already queed to equip
						if not alreadyEquipped[fittingItem.slotIndex] then
							EquipItem(BAG_BACKPACK, fittingItem.slotIndex, gearSlot)
							alreadyEquipped[fittingItem.slotIndex] = true
							break
						end
					end
				else
					cspsPost(string.format(GS(CSPS_GEAR_ItemNotFound), gearTable.link or "?"))
				end
			end
		end
	end
end

CSPS.equipAllFittingGear = equipAllFittingGear

local function retrieveAllFittingGear()

	if GetInteractionType() ~= INTERACTION_BANK then return false end
	
	local itemsToRetrieve = {}
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable then
			if not doesWornItemFitSlot(gearSlot) then
				local fitsExactly, couldFit = findSetItem(gearSlot)
				if #fitsExactly[BAG_BACKPACK] == 0 then 
					if #fitsExactly[BAG_BANK] > 0 then
						table.insert(itemsToRetrieve, 
							{bagId = BAG_BANK, 
							slotIndex = fitsExactly[BAG_BANK][1].slotIndex, 
							itemLink = fitsExactly[BAG_BANK][1].itemLink})
					elseif #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
						table.insert(itemsToRetrieve, 
							{bagId = BAG_SUBSCRIBER_BANK, 
							slotIndex = fitsExactly[BAG_SUBSCRIBER_BANK][1].slotIndex, 
							itemLink = fitsExactly[BAG_SUBSCRIBER_BANK][1].itemLink})
					end
				end	
			end
		end
	end
		
	local function transferItem(sourceBag, sourceSlot)
		local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
		if not destSlot then return false end
		if IsProtectedFunction("RequestMoveItem") then
			CallSecureProtected("RequestMoveItem", sourceBag, sourceSlot, BAG_BACKPACK, destSlot, 1)
		else
			RequestMoveItem(sourceBag, sourceSlot, BAG_BACKPACK, destSlot, 1)
		end
		return destSlot
	end
	
	local function transferNext()			
		local nextItem = itemsToRetrieve[1]
		local destSlot = transferItem(nextItem.bagId, nextItem.slotIndex)
		if not destSlot then d(GS(SI_ACTIONRESULT3430)) return end
		local myTries = 1
		local function checkSlot(myTries)
			myTries = myTries + 1
			zo_callLater(function()
				if GetItemLink(BAG_BACKPACK, destSlot, 1) ~= nextItem.itemLink then
					if myTries < 20 and GetInteractionType() == INTERACTION_BANK then 
						checkSlot(myTries) 
					else
						d(GS(SI_TRANSACTION_FAILED_TITLE))
					end
				else
					table.remove(itemsToRetrieve, 1)
					if #itemsToRetrieve > 0 then transferNext() end
				end
			end, 50)
		end
		checkSlot(myTries)
	end
	if #itemsToRetrieve > 0 then transferNext() end
end

function CSPS.setupGearSection(control, node, data)
	local canRetrieve = false
	local canEquip = false
	local canCraft = false
	if node:IsOpen() and not data.fillContent then
		for gearSlot, gearTable in pairs(theGear) do
			if gearTable then
				if not doesWornItemFitSlot(gearSlot) then
					local fitsExactly, couldFit = findSetItem(gearSlot)
					if #fitsExactly[BAG_BACKPACK] > 0 then
						canEquip = true
					elseif #fitsExactly[BAG_BANK] > 0 or #fitsExactly[BAG_SUBSCRIBER_BANK] > 0 then
						canRetrieve = true
					end
				end
			end
		end
		canRetrieve = canRetrieve and GetInteractionType() == INTERACTION_BANK
		canCraft = CSPS.savedVariables.craftList and true
	end
	local btnApply = GetControl(control, "BtnApply")
	local btnRetrieve = GetControl(control, "BtnRetrieve")
	
	local btnCraftList = GetControl(control, "BtnPlus")
	CSPS.setButtonTextures(btnCraftList, "esoui/art/treeicons/achievements_indexicon_crafting")
	btnCraftList:SetHidden(not canCraft)
	btnCraftList:SetHandler("OnClicked", function() CSPS.showElement("craftList") end)
	btnCraftList:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnCraftList, RIGHT, GS(CSPS_ShowCraftlist)) end)
	btnCraftList:SetWidth(canCraft and 21 or 0)
	btnApply:SetHidden(not canEquip)
	btnApply:SetWidth(canEquip and 21 or 0)
	btnApply:SetHandler("OnClicked", function() equipAllFittingGear() end)
	btnApply:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnApply, RIGHT, GS(SI_ITEM_ACTION_EQUIP)) end)
	btnRetrieve:SetHidden(not canRetrieve)
	btnRetrieve:SetWidth(canRetrieve and 21 or 0)
	btnRetrieve:SetHandler("OnClicked", retrieveAllFittingGear)
	btnRetrieve:SetHandler("OnMouseEnter", function() ZO_Tooltips_ShowTextTooltip(btnRetrieve, RIGHT, GS(SI_BANK_WITHDRAW)) end)
end


function CSPS.setupGearTree()
	CSPS.getCurrentGear()
	CSPS.setupLLC()
	local myTree = CSPS.getTreeControl()
	if not enchantIds then buildGlyphTables() end
	myTree:AddTemplate("CSPSLEGEAR", NodeSetupGear, nil, nil, 24, 0)
	local fillContent = {}
		for i, v in pairs(gearSlots) do
		table.insert(fillContent, {"CSPSLEGEAR", {gearSlot = v}})
	end
	local overNode = myTree:AddNode("CSPSLH", {name = GS(SI_GAMEPAD_DYEING_EQUIPMENT_HEADER), variant=7, fillContent=fillContent}) -- variant 3 = skill section = always active color

	if myLevel < 50 then
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."LevelUp", EVENT_LEVEL_UPDATE,
			function(_, unitTag, level) 
				if unitTag ~= "player" then return end
				myLevel = level
			end)
	end
	if myCPLevel < 160 then
		EVENT_MANAGER:RegisterForEvent(CSPS.name.."CPLevelUp", EVENT_CHAMPION_POINT_UPDATE,
			function(_, unitTag, _, currentChampionPoints) 
				if unitTag ~= "player" then return end
				myCPLevel = math.min(currentChampionPoints, 160)
				myCPLevel = math.floor(myCPLevel/10)*10
			end)
	end
	
end

local function setGearSlotFromBagWorn(gearSlot)
	local itemLink = GetItemLink(BAG_WORN, gearSlot, LINK_STYLE_DEFAULT)
	local itemUniqueID = Id64ToString(GetItemUniqueId(BAG_WORN, gearSlot))
	itemUniqueID = itemUniqueID ~= "0" and itemUniqueID or false
	local itemId = GetItemLinkItemId(itemLink)
	
	if itemId == maraId then -- the actual functions are way up above because of the receive-drag-function that uses them too
		setMara(gearSlot, itemLink, itemUniqueID)
	elseif not gearSlotsPoison[gearSlot] and itemLink ~= "" then
		setArmorOrWeaponFromLink(gearSlot, itemLink, itemUniqueID)
	elseif itemLink ~= "" then
		setPoisonFromIdAndLink(gearSlot, itemLink, itemId)
	end
end

CSPS.setGearSlotFromBagWorn = setGearSlotFromBagWorn

function CSPS.getCurrentGear()	
	--local ringOfMara = false
	for _, gearSlot in ipairs(gearSlots) do
		theGear[gearSlot] = false
		setGearSlotFromBagWorn(gearSlot)
	end
	CSPS.refreshSetCount()
	return theGear
end

function CSPS.refreshSetCount()
	local setCounts = getActiveSets()
	local setCountFormatted = {}
	for setId, setCountNumbers in pairs(setCounts) do
		if setCountNumbers[2] > 0 or setCountNumbers[3] > 0 then
			setCountFormatted[setId] = string.format("%s/%sx", setCountNumbers[1] + setCountNumbers[2], setCountNumbers[1] + setCountNumbers[3])
		else	
			setCountFormatted[setId] = setCountNumbers[1].."x"
		end
	end
	for gearSlot, gearTable in pairs(theGear) do
		if gearTable and gearTable.setId and gearTable.setId ~= 0 then
			gearTable.setCountF = setCountFormatted[gearTable.setId]
			gearTable.setCount = setCounts[gearTable.setId]
		elseif gearTable then
			gearTable.setCountF = nil
			gearTable.setCount = nil
		end
	end
	return setCountFormatted
end

function CSPS.getTheGear()
	return theGear or {}
end

function CSPS.setTheGear(newGear)
	if not newGear or type(newGear) ~= "table" then return false end
	theGear = newGear
	local hadMythic = false
	for gearSlot, v in pairs(theGear) do
		if v then
			if not v.link then
				if gearSlotsPoison[gearSlot] then
					if v.firstId then v.link = string.format(poisonItemLink, v.firstId, v.secondId or 0) else theGear[gearSlot] = nil end
				else
					local _, itemLink = getSetItemInfo(v, gearSlot)
					
					v.link = itemLink
				end
			end
			v.mythic = isSetMythic(v.setId)
			if v.mythic then 
				if hadMythic then
					theGear[gearSlot] = false
				else
					hadMythic = true
				end
			end
		end
	end
	CSPS.refreshSetCount()
	CSPS.refreshTree()
end

function CSPS.importGearFromHub(gearString)
	local gearList = {SplitString(",", gearString)}
		
	if not enchantIds then buildGlyphTables() end -- need enchantNames for varification
	
	local myGear = {}
	
	for _, gearStr in pairs(gearList) do
		for i=1,3 do
			gearStr = string.gsub(gearStr, "::", ":0:")
		end
		
		local gearData = {SplitString(":", gearStr)}
		--equip-slot:gear-weight/weapon-type/jewelry-type:set-id:trait-id:enchant-id or glyph-id (or just equip-slot:itemId for poison)
		local equipSlot = tonumber(gearData[1])
		if equipSlot and gearSlotIcons[equipSlot] then -- check if equipSlot is supported by the addon
			myGear[equipSlot] = {}
			local myTable = myGear[equipSlot]
			if gearSlotsPoison[equipSlot] then
				local firstId = tonumber(gearData[2])
				local secondIdArray = CSPS.getPoisonIds(firstId)
				local secondId = gearData[3] and tonumber(gearData[3]) or secondIdArray and secondIdArray[1] or 0
				myTable.firstId = firstId
				myTable.secondId = secondId
				myTable.link = string.format(poisonItemLink, firstId, secondId)
			else
				myTable.setId = tonumber(gearData[3]) or 0
				local setType = GetItemSetType(myTable.setId)
				myTable.setId = setType ~= 0 and myTable.setId or 0
				myTable.mythic = isSetMythic(myTable.setId) 
				myTable.quality = myTable.mythic and ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE or ITEM_FUNCTIONAL_QUALITY_LEGENDARY -- not saved
				
				myTable.trait = tonumber(gearData[4]) or 0
				
				myTable.enchant = tonumber(gearData[5]) or 0 --saved by glyphId
				myTable.enchant = enchantIds[myTable.enchant] or 0
				
				if gearSlotsJewelry[equipSlot] then
					-- nothing
				elseif gearSlotsBody[equipSlot] then
					myTable.type = tonumber(gearData[2]) or 0
				
				elseif gearSlotsHands[equipSlot] then
					myTable.type = tonumber(gearData[2]) or 0
				
				end
			end
		end
	end
	CSPS.setTheGear(myGear)
	
end

function CSPS.exportGearToESOHUB()
	local gearStr = {}
	local glyphByEnchant = {}
	if not enchantGlyphs then buildGlyphTables() end -- need enchantNames for varification
	
	for equipSlot, gearData in pairs(theGear) do
		if gearData then
			local slotTable = {equipSlot}
			if gearSlotsPoison[equipSlot] then
				table.insert(slotTable, gearData.firstId or 0)
				table.insert(slotTable, gearData.secondId or 0)
			elseif gearSlotsHands[equipSlot] or gearSlotsBody[equipSlot] or gearSlotsJewelry[equipSlot] then
				table.insert(slotTable, gearData.type or 0) --2
				table.insert(slotTable, gearData.setId or 0) --3
				table.insert(slotTable, gearData.trait or 0) --4
				table.insert(slotTable, gearData.enchant and enchantGlyphs[gearData.enchant] or 0) --5
			end
			table.insert(gearStr, table.concat(slotTable, ":"))
		end
	end
	return table.concat(gearStr, ",")
end

local function createUpgradeRequest(svData, uniqueId, bagId, slotIndex, quality)
	if not LLC then return end
	quality = quality or GetItemLinkQuality(svData.link)
	if GetItemDisplayQuality(bagId, slotIndex) == quality then return true end
	svData.waitingForUpgrade = uniqueId
	
	craftedItems[svData.reference] = {bagId = bagId, slotIndex = slotIndex, data = svData, uniqueId = uniqueId}
	cspsD("Creating upgrade-request")
	 LLC:ImproveSmithingItem(bagId, slotIndex, quality, false, svData.reference)
	local workaround = LLC:findItemByReference(svData.reference)
	local LLCdata = workaround and #workaround > 0 and workaround[1] 
	if not LLCdata then cspsD("No LLCdata for upgradeRequest "..svData.reference) end
	LLCdata = LLCdata or {}
	
	craftingRequests[svData.reference] = {upgrade = true, uniqueId = uniqueId, LLCdata = LLCdata, bagId = bagId, slotIndex = slotIndex, quality = quality, reference = svData.reference}
end

local function createEnchantRequest(svData, uniqueId, itemLink, bagId, slotIndex) 
	if not LLC then return end
	local enchantId = GetItemLinkFinalEnchantId(itemLink)
	if not enchantId or enchantId == 0 then cspsD("No enchantment planned.") return false end
	
	if bagId and GetItemLinkFinalEnchantId(itemLink) == GetItemLinkFinalEnchantId(GetItemLink(bagId, slotIndex)) then
		return true
	end
	
	if craftingRequests[svData.reference.."e"] then 
		cspsD("Enchantment request exists. Adding uniqueId, bagId, slotIndex")
		local enchantRequest = craftingRequests[svData.reference.."e"]
		enchantRequest.bagId = bagId
		enchantRequest.slotIndex = slotIndex
		enchantRequest.uniqueId = uniqueId
		svData.waitingForEnchantment = uniqueId
		craftedItems[svData.reference] = {bagId = bagId, slotIndex = slotIndex, data = svData, uniqueId = uniqueId}
		return false
	end
	cspsD("Creating enchantment request")
	svData.waitingForEnchantment = uniqueId
	craftedItems[svData.reference] = {bagId = bagId, slotIndex = slotIndex, data = svData, uniqueId = uniqueId}
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	local reqLevel = GetItemLinkRequiredLevel(itemLink)
	
	local LLCdata = LLC:CraftEnchantingGlyphByAttributes(reqCP > 0, reqCP > 0 and reqCP or reqLevel, enchantId, GetItemLinkQuality(itemLink), false, svData.reference.."e")
	
	craftingRequests[svData.reference.."e"] = {glyph = true, uniqueId = uniqueId, LLCdata = LLCdata, bagId = bagId, slotIndex = slotIndex, enchantId = enchantId, reference = svData.reference}
	--LLC:AddGlyphToExistingGear(requestTable, itemData.bagId, itemData.slotIndex)	does not actually work
end

local function createCraftRequest(svData, itemLink, index, recon, forceNew)
	if not LLC then return end
	svData.reference = svData.reference or "CSPS-"..index
	if craftingRequests[svData.reference] then
		if forceNew then
			if not recon then LLC:cancelItemByReference(svData.reference) end
			craftingRequests[svData.reference] = nil
		else
			return
		end
	end
	if recon then
		craftingRequests[svData.reference] = {LLCdata = {autocraft = false}, 
			recon = recon, link = itemLink, index = index}
		if GetItemLinkFinalEnchantId(GetItemSetCollectionPieceItemLink(recon.pieceId)) ~= GetItemLinkFinalEnchantId(itemLink) then
			createEnchantRequest(svData, nil, itemLink)
		end
		return
	end
	local itemStyle = svData.style or 1
	local itemLink = string.gsub(itemLink, "([^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:)([^:]+:)(.*)", "%1:"..itemStyle..":%3")
	if not svData.craft then return end
	local craft = svData.craft
	local station, pattern = CSPS.getPatternInfo(svData.gearSlot, svData.craft.armorType, svData.craft.weaponType)
	
	local LLCdata = LLC:CraftSmithingItemByLevel(pattern, craft.isCP , craft.level, itemStyle, craft.traitIndex + 1, false, station, craft.setIndex, craft.quality, false, svData.reference)
	
	--if craft.enchant then
	--	LLC:CraftEnchantingGlyphByAttributes(craft.isCP , craft.level, craft.enchant, craft.quality, false, svData.reference, requestTable)
	--end
	--LLC:CraftSmithingItemFromLink(itemLink, svData.reference)
	--requestTable.autocraft = false
	craftingRequests[svData.reference] = {LLCdata = LLCdata}
	createEnchantRequest(svData, nil, itemLink)
end

local function findNextReconItem()
	for i,v in pairs(craftingRequests) do
		if v.recon and v.LLCdata.autocraft then return i, v end
	end
end


local function finishedItem(index, data, bagId, slotIndex, doNotRefresh)
	cspsD("Finished item at bag "..bagId.." and slot "..slotIndex)
	data.waitingForEnchantment = nil
	data.waitingForUpgrade = nil
	data.waitingForGear = nil
	craftingRequests[data.reference] = nil
	craftingRequests[data.reference.."e"] = nil
	data.uniqueId = Id64ToString(GetItemUniqueId(bagId, slotIndex))
	if data.charId == GetCurrentCharacterId() then
		if data.gearSlot then
			local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(GetItemLink(bagId,slotIndex), gearSlot)
			if setIdFits and enchantFits and qualityFits and typeFits and traitFits then setFromBagAndSlot(data.gearSlot, bagId, slotIndex) end
		end
		CSPS.savedVariables.craftList[index] = nil
		if not doNotRefresh then CSPS.visualCraftList:RefreshData() end
		CSPS.refreshTree()
		return
	end
	craftedItems[data.reference] = {bagId = bagId, slotIndex = slotIndex, data = data, uniqueId = data.uniqueId}
	if not doNotRefresh then CSPS.visualCraftList:RefreshVisible() end
end
		
local function workRecon()
	if not LLC or not findNextReconItem() then return end--and GetInteractionType() == INTERACTION_RETRAIT then 
	local currentReconReference, currentReconItem = false, false
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_ReconstructionEnded", EVENT_INTERACTION_ENDED, function()
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_ReconstructionEnded", EVENT_INTERACTION_ENDED)
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_ReconstructResponse", EVENT_RECONSTRUCT_RESPONSE)
		EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_ReconNewItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
	end)
	ZO_RETRAIT_STATION_KEYBOARD.tabs:SelectFragment(ZO_RETRAIT_STATION_KEYBOARD.reconstructTab.categoryName)
	local itemData = false
	local success = false
	local expectedItemLink = false
	local reconData = false
	local svData = false
	
	local function reconNextPiece()
		cspsD("Trying to find next item")
		currentReconReference, currentReconItem = findNextReconItem()
		if not currentReconItem then cspsD("Nothing more to reconstruct") return end
		reconData = currentReconItem.recon
		svData = CSPS.savedVariables.craftList[currentReconItem.index]
		expectedItemLink = svData and svData.link
		if not expectedItemLink then return end
		local quality = reconData.itemQuality
		quality = (CSPS.isUpgradeSkillLeveled(expectedItemLink) or CSPS.savedVariables.settings.upgradeAnyway) and quality or getItemSetMinQuality(reconData.setId)
		cspsD("Expected item: "..expectedItemLink)
		RequestItemReconstruction(reconData.pieceId, reconData.traitType, quality, reconData.currencyType)
	end
	local function processPiece()
		cspsD("Processing item")
		local uniqueId = Id64ToString(GetItemUniqueId(itemData.bagId, itemData.slotIndex))
		local finished = true		
		if not createEnchantRequest(svData, uniqueId, expectedItemLink, itemData.bagId, itemData.slotIndex, setAuto) then
			CSPS.post(GS(CSPS_WaitingForEnchant))
			finished = false
		end
		finished = createUpgradeRequest(svData, uniqueId, itemData.bagId, itemData.slotIndex, reconData.itemQuality) and finished
		
		if finished then
			finishedItem(index, svData, itemData.bagId, itemData.slotIndex)	
		else
			CSPS.visualCraftList:RefreshVisible()
		end
		reconNextPiece()
	end	
	--{setId = setId, setSlot = setSlot, traitType = traitType, itemQuality = itemQuality, currencyType = reconCurrencies[1], currencyFormatted = reconCurrenciesFormatted[1]}
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_ReconstructResponse", EVENT_RECONSTRUCT_RESPONSE, function(_, result)
		if result ~= RECONSTRUCT_RESPONSE_SUCCESS then
			CSPS.post(GS("SI_RECONSTRUCTRESPONSE", result))
			return
		end
		local resultLink = GetLastCraftingResultItemLink(1)
		cspsD("Result item: "..resultLink) -- can use itemId for recon because itemlink is generated by the game and not by me...
		if GetItemLinkItemId(resultLink) ~= GetItemLinkItemId(expectedItemLink) then return end
		success = true
		if itemData then processPiece() end
	end)
	
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_ReconNewItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_,  bagId, slotIndex, isNew, _, _, countChange)
		local itemLink = GetItemLink(bagId, slotIndex)
		cspsD("Recon item "..itemLink.." at bagId "..bagId.." and slotIndex "..slotIndex)
		if GetItemLinkItemId(itemLink) ~= GetItemLinkItemId(expectedItemLink) then return end
		itemData = {bagId = bagId, slotIndex = slotIndex}
		if success then processPiece() end
	end)
	EVENT_MANAGER:AddFilterForEvent(CSPS.name.."_ReconNewItem", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, true)
	reconNextPiece()
end

EVENT_MANAGER:RegisterForEvent(CSPS.name.."_RetraitInteract", EVENT_RETRAIT_STATION_INTERACT_START, function() workRecon() end)

local function switchAutoCraft(data)	
	if not LLC then return end
	cspsD("Switching autocraft for "..data.link)
	local requestTable = craftingRequests["CSPS-"..data.index]
	local enchantTable = craftingRequests["CSPS-"..data.index.."e"]
	requestTable = requestTable and requestTable.LLCdata
	enchantTable = enchantTable and enchantTable.LLCdata
	if not requestTable and not enchantTable then
		cspsD("Request table not found!")
		return
	end
	if requestTable then requestTable.autocraft = not requestTable.autocraft end
	if enchantTable then enchantTable.autocraft = not enchantTable.autocraft end
	CSPS.visualCraftList:RefreshVisible()
	LLC:craftInteract()
	
	
	if not data.recon or not requestTable or not requestTable.autocraft then return end
	
	local level = GetItemLinkRequiredLevel(data.link)
	local cpLevel = GetItemLinkRequiredChampionPoints(data.link)
	local warnLevel = false
	if level ~= math.floor(myLevel/2)*2 or cpLevel ~= myCPLevel then
		CSPS.post(string.format(GS(CSPS_ReconLevel), myLevel, myCPLevel))
		warnLevel = true
	end
	
	if GetInteractionType() == INTERACTION_RETRAIT and not warnLevel then workRecon() end
end

local craftListClass = ZO_SortFilterList:Subclass()

function craftListClass:New( control )
	local list = ZO_SortFilterList.New(self, control)
	list.frame = control
	list:Setup()
	return list
end

local function getCharNameFromSvData(svData)
if not svData or not svData.charId then return false end 
	local charName = CSPS.savedVariables.charData[svData.charId]
	charName = charName and charName["$lastCharacterName"]
	return charName ~= "" and charName or false
end

local function setStyleForRecon(svData, style)
	svData.style = style 
	local requestTable = craftingRequests[svData.reference]
	requestTable = requestTable and requestTable.LLCdata
	if requestTable then requestTable.style = style end
	CSPS.visualCraftList:RefreshVisible()
end

local function showStyleMenu(svData)
	ClearMenu()
	local function formatItemStyleNameAndIconAndNumber(itemStyle)
		local matLink = GetItemStyleMaterialLink(itemStyle)
		if not matLink or matLink == "" then return false end
		return zo_strformat("<<C:1>> (|t24:24:<<3>>|t <<2>>)", GetItemStyleName(itemStyle), GetCurrentSmithingStyleItemCount(itemStyle), GetItemLinkIcon(matLink))
	end
	for i=1,9 do
		local styleName = formatItemStyleNameAndIconAndNumber(i)
		if styleName then AddCustomMenuItem(styleName, function() setStyleForRecon(svData, i) end) end
	end
	local otherStyles, styleIdsByName = {}, {}
	for i=11, GetHighestItemStyleId() do
		local styleName = formatItemStyleNameAndIconAndNumber(i)
		if styleName then table.insert(otherStyles, styleName) styleIdsByName[styleName] = i end
	end
	table.sort(otherStyles)
	local subMenu = {}
	AddCustomMenuItem("-", function() end)
	for i,v in pairs(otherStyles) do
		table.insert(subMenu, {label = v, callback = function() 
				setStyleForRecon(svData, styleIdsByName[v])
			end})
		if #subMenu >= 20 or i == #otherStyles then
			AddCustomSubMenuItem(string.format("%s - %s", string.sub(subMenu[1].label, 1,1), string.sub(v, 1,1)), subMenu)
			subMenu = {}
		end
	end
	ShowMenu()
end

local function findUniqueItem(uniqueIdToFind)
	for _, bagId in pairs({BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK}) do
		for slotIndex=0,GetBagSize(bagId) do
			local oneItemId = GetItemId(bagId, slotIndex) ~= 0 and Id64ToString(GetItemUniqueId(bagId, slotIndex))
			if oneItemId and oneItemId == uniqueIdToFind then 
				return bagId, slotIndex, uniqueIdToFind
			end
		end
	end
end

local function checkCraftedItemUnique(svData)
	local uniqueId = svData.uniqueId or svData.waitingForEnchantment or svData.waitingForUpgrade
	if not uniqueId then return false end
	local itemData = craftedItems[svData.reference]
	
	local itemUniqueID = itemData and Id64ToString(GetItemUniqueId(itemData.bagId, itemData.slotIndex))
	if itemUniqueID == uniqueId then return itemData end
	
	
	local bagId, slotIndex, uniqueId = findUniqueItem(uniqueId)
	if bagId then 
		itemData = {bagId = bagId, slotIndex = slotIndex, uniqueId = uniqueId}
		craftedItems[svData.reference] = itemData
		return itemData
	end
	craftedItems[svData.reference] = nil
	svData.uniqueId = nil
	svData.waitingForEnchantment = nil
	svData.waitingForUpgrade = nil
	return false

end

function craftListClass:SetupItemRow( control, data )
	control.data = data
	local ctrName = GetControl(control, "Name")
	local ctrCharName = GetControl(control, "CharName")
	local ctrStyle = GetControl(control, "Style")
	local ctrInd = GetControl(control, "Indicator")
	local ctrBag = GetControl(control, "BagIcon")
	ctrInd.nonRecolorable = true
	local ctrMarker = GetControl(control, "BG2")
	ctrMarker:SetTexture(data.recon and "esoui/art/battlegrounds/battlegrounds_scoreboard_highlightstrip_orange.dds" or "esoui/art/battlegrounds/battlegrounds_scoreboard_highlightstrip_purple.dds")
	ctrMarker.nonRecolorable = true
	--ctrName.normalColor = ZO_DEFAULT_TEXT
	ctrName:SetText(data.link)
	local svData = data.svData
	ctrCharName:SetText(getCharNameFromSvData(svData) or "-")
	local itemStyle = svData.style or 1
	
	ctrStyle:SetText(data.recon and "" or zo_strformat("<<C:1>>", GetItemStyleName(itemStyle)))
	ctrStyle:SetHidden(data.recon and true)
	ctrStyle:SetHandler("OnMouseUp", function(_, mouseButton, upInside) if upInside then showStyleMenu(svData) end end)
	
	local itemData = checkCraftedItemUnique(svData)
	local LLCdata = svData.waitingForEnchantment and craftingRequests[svData.reference.."e"] or craftingRequests[svData.reference]
	control.isMarked = LLCdata and LLCdata.LLCdata.autocraft
	if svData.uniqueId or svData.waitingForEnchantment or svData.waitingForUpgrade then
		local inBag = itemData.bagId == BAG_BACKPACK
		local forMe = svData.charId == GetCurrentCharacterId()
		local atDestination = forMe and inBag or not forMe and not inBag
		ctrBag:SetTexture(inBag and "esoui/art/tooltips/icon_bag.dds" or  "esoui/art/tooltips/icon_bank.dds")
		ctrBag:SetColor((atDestination and CSPS.colors.green or CSPS.colors.orange):UnpackRGB())
		ctrBag:SetHidden(false)
	else
		ctrBag:SetHidden(true)
	end
	if svData.uniqueId then
		ctrInd:SetTexture("esoui/art/buttons/accept_up.dds")
		ctrInd:SetColor(CSPS.colors.green:UnpackRGB())
	elseif svData.waitingForUpgrade then
		ctrInd:SetTexture("esoui/art/crafting/smithing_tabicon_improve_up.dds")
		ctrInd:SetColor((control.isMarked and CSPS.colors.orange or CSPS.colors.white):UnpackRGB())		
	elseif svData.waitingForEnchantment then
		ctrInd:SetTexture("esoui/art/crafting/enchantment_tabicon_potency_up.dds")
		ctrInd:SetColor((control.isMarked and CSPS.colors.blue or CSPS.colors.white):UnpackRGB())
	elseif data.recon then		
		ctrInd:SetTexture("esoui/art/inventory/inventory_trait_reconstruct_icon.dds")
		ctrInd:SetColor((control.isMarked and CSPS.colors.orange or CSPS.colors.white):UnpackRGB())
	else
		ctrInd:SetTexture("esoui/art/treeicons/achievements_indexicon_crafting_up.dds")
		ctrInd:SetColor((control.isMarked and CSPS.colors.green or CSPS.colors.white):UnpackRGB())
	end
	ctrMarker:SetHidden(not control.isMarked)
--CSPScraftListLE

	ZO_SortFilterList.SetupRow(self, control, data)
	
end

local enchantQueue = {}
local nextEnchantItem = false

local function workEnchantQueue()
	if #enchantQueue == 0 then cspsD("No enchant queue") EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_CraftingStopped", EVENT_INTERACTION_ENDED) return end
	if nextEnchantItem or ZO_CraftingUtils_IsPerformingCraftProcess() or LibLazyCrafting.isCurrentlyCrafting[1] then cspsD("Currently crafting") return end
	local function enchantNext()
		nextEnchantItem = enchantQueue[1]
		if not nextEnchantItem then 
			cspsD("No more items")
			EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_CraftingStopped", EVENT_INTERACTION_ENDED)
			return 
		end
		EnchantItem(nextEnchantItem.bagId, nextEnchantItem.slotIndex, nextEnchantItem.glyphBag, nextEnchantItem.glyphSlot)
	end
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_EnchantDone", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
		function(_, eBagId, eSlotIndex, _, _, eReason, eStackChange)
			if not nextEnchantItem or eStackChange ~= 0 or eBagId ~= nextEnchantItem.bagId or eSlotIndex ~= nextEnchantItem.slotIndex then 
				cspsD("Not the slot change expected")
				return 
			end
			if GetItemLinkFinalEnchantId(GetItemLink(eBagId, eSlotIndex)) ~= nextEnchantItem.enchantId then
				cspsD("Enchantment failed")
				EVENT_MANAGER:UnregisterForEvent(CSPS.name.."_EnchantDone", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
				return
			end
			cspsD("Enchantment successful")
			finishedItem(nextEnchantItem.index, nextEnchantItem.svData, eBagId, eSlotIndex)
			table.remove(enchantQueue, 1)
			enchantNext()
		end)
	EVENT_MANAGER:AddFilterForEvent(CSPS.name.."_EnchantDone", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_IS_NEW_ITEM, false)
	cspsD("Working enchant queue")
	enchantNext()
end

local function enchantThis(bagId, slotIndex, glyphBag, glyphSlot, index, svData, enchantId)
	table.insert(enchantQueue, {bagId = bagId, slotIndex = slotIndex, glyphBag = glyphBag, glyphSlot = glyphSlot, index = index, svData = svData, enchantId = enchantId})
	cspsD("Item added to enchant queue, tyring to work queue and registering for update")
	EVENT_MANAGER:RegisterForEvent(CSPS.name.."_CraftingStopped", EVENT_INTERACTION_ENDED, function(_, craftingType) if craftingType == INTERACTION_CRAFT then workEnchantQueue() end end)
	workEnchantQueue()
end




function CSPS.setupLLC()
	if not LibLazyCrafting or LibLazyCrafting.version < 4.035 then return end
	LLC = LibLazyCrafting:AddRequestingAddon("CSPS", true, function(event, craftingType, result) 
		cspsD(event)
		if event == LLC_NO_FURTHER_CRAFT_POSSIBLE then workEnchantQueue() return end
		if event ~= LLC_CRAFT_SUCCESS then return end
		cspsD(result)
		if not result then return end
		for i, v in pairs(CSPS.savedVariables.craftList) do
			if v.reference and (v.reference == result.reference or v.reference.."e" == result.reference) then
				local myRequest = craftingRequests[result.reference]
				if not myRequest then cspsD("Crafting request not found: "..v.reference) return end
				
				if myRequest.glyph then
					local uniqueId = Id64ToString(GetItemUniqueId(myRequest.bagId, myRequest.slotIndex))
					if not v.waitingForEnchantment then 
						v.waitingForGear = uniqueId
						cspsD("Glyph created, no gear yet")
						return
					end
					cspsD("Glyph created, looking for original item")
					if uniqueId ~= v.waitingForEnchantment then 
						-- TODO what happens if the item has been moved or destroyed
						CSPS.post(string.format("%s - %s", v.link, GS(SI_MAIL_ITEM_NOT_FOUND)))
						return 
					end
					cspsD("Trying to enchant")
					enchantThis(myRequest.bagId, myRequest.slotIndex, result.bag, result.slot, i, v, myRequest.enchantId)
					
					return
				end
				if v.waitingForEnchantment then cspsD("Waiting for enchant, but no glyph created?") return end
				cspsD("Item created")
				if v.waitingForGear then 
					local glyphBag, glyphSlot = findUniqueItem(v.waitingForGear)
					if glyphBag then
						enchantThis(result.bag, result.slot, i, v, GetItemLinkFinalEnchantId(v.link))
						return
					end
					cspsD("Waiting for gear - glyph not found. Glyph back on the table...")
					v.waitingForGear = nil
				end
				if createEnchantRequest(v, Id64ToString(GetItemUniqueId(result.bag, result.slot)), v.link, result.bag, result.slot) then
					finishedItem(i, v, result.bag, result.slot)
				else
					craftingRequests[v.reference] = nil
				end
				return
			end
		end
		cspsD("No entry for this reference")
	end)
	CSPS.LLC = LLC
end	
	
function craftListClass:Setup()
	ZO_ScrollList_AddDataType(self.list, 1, "CSPScraftListLE", 30, function(control, data) self:SetupItemRow(control, data) end)
	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	self:SetAlternateRowBackgrounds(true)
	self.masterList = { }
	self:RefreshData()
end

function CSPS.craftListRowMouseEnter(control)
	CSPS.visualCraftList:Row_OnMouseEnter(control)
	local itemLink = control.data.link
	InitializeTooltip(InformationTooltip, control, LEFT)
	local armorType = GetItemLinkArmorType(itemLink)
	addTooltipItemInfo(itemLink, nil, nil, armorType > 0 and armorType, nil)
	
	local reqCP = GetItemLinkRequiredChampionPoints(itemLink)
	local reqLevel = GetItemLinkRequiredLevel(itemLink)

	
	ttAddLine(reqCP and reqCP > 0 and string.format("|t28:28:esoui/art/champion/champion_icon_32.dds|t %s", reqCP) or reqLevel)
	
	if LLC and control.data.recon and (myCPLevel ~= reqCP or math.floor(myLevel/2)*2 ~= reqLevel) then
		ttAddLine(string.format(GS(CSPS_ReconLevel), myLevel, myCPLevel), nil, ZO_ERROR_COLOR)
	end
	if not LLC then
		ttAddLine(GS(CSPS_LLC_NEEDED), nil, ZO_ERROR_COLOR)
		return
	end
	addTooltipTraitInfoFromItemLink(itemLink)
	addTooltipEnchantFromItemLink(itemLink)
	local charName = getCharNameFromSvData(control.data.svData)
	if charName then ttAddLine("--> "..charName) end
	
	if control.data.recon then 
		local _, _, _, _, _, setId = GetItemLinkSetInfo(itemLink)
		local upgradeCostFormatted = CSPS.getUpgradeCost(itemLink, getItemSetMinQuality(setId), control.data.recon.itemQuality)
		if control.data.svData.gearSlot and control.data.recon.traitType and not CSPS.canCraftTrait(control.data.svData.gearSlot, GetItemLinkArmorType(itemLink), GetItemLinkWeaponType(itemLink), control.data.recon.traitType) then
			ttAddLine(ZO_ERROR_COLOR:Colorize(GS(SI_TRADESKILLRESULT120)))
		end
		ttAddLine(table.concat({control.data.recon.currencyFormatted, upgradeCostFormatted}, ", "))
	end
	local reference = control.data.svData.reference
	for i=1, 2 do
		local LLCdata = craftingRequests[reference]
		LLCdata = LLCdata and not LLCdata.recon and LLCdata.LLCdata
		if LLCdata then
			local mats = {}
			for i, v in pairs(LLC:getMatRequirements(LLCdata)) do 
				local matAmount = v
				if matAmount > 0 then
					local matLink = "|H0:item:"..i..":0:0:0:0:0:0:0:0:0:0:0:0:0:0:123:0:0:0:0:0|h|h"
				
					local s1, s2, s3 = GetItemLinkStacks(matLink)
					local matsAvailable = s1+s2+s3
					matAmount = (matAmount > matsAvailable and ZO_ERROR_COLOR or ZO_SUCCEEDED_TEXT):Colorize(matAmount.."x")
					table.insert(mats, zo_strformat("<<1>><<2>><<C:3>>", matAmount, secSpace, GetItemLinkName(matLink))) --secure space
				end
			end
			if #mats > 0 then
				ttAddLine(table.concat(mats, ", "))--, "ZoFontGameSmall")
			end
		end
		reference = reference.."e"
	end
	if GetInteractionType() == INTERACTION_BANK and (control.data.svData.uniqueId or control.data.svData.waitingForEnchantment or control.data.svData.waitingForUpgrade) then 
		local inBag = craftedItems[control.data.svData.reference] and craftedItems[control.data.svData.reference].bagId == BAG_BACKPACK
		ttAddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", GS(inBag and SI_BANK_DEPOSIT or SI_BANK_WITHDRAW)))
	elseif not control.data.svData.uniqueId then
		ttAddLine(string.format("|t26:26:esoui/art/miscellaneous/icon_lmb.dds|t %s", GS(control.isMarked and SI_GAMEPAD_ADDON_MANAGER_DISABLE_ADDON or SI_GAMEPAD_ADDON_MANAGER_ENABLE_ADDON)))
	end
end

function CSPS.craftListRowMouseExit(control)
	CSPS.visualCraftList:Row_OnMouseExit(control)
	ZO_Tooltips_HideTextTooltip()
end

local function transferItemByData(data)
	local itemData = data.svData.reference and craftedItems[data.svData.reference]
	if not itemData then return end
	local inBag = itemData.bagId == BAG_BACKPACK 
	if GetInteractionType() ~= INTERACTION_BANK then return end
	local destBag = inBag and BAG_BANK or BAG_BACKPACK
	local destSlot = FindFirstEmptySlotInBag(destBag)
	if not destSlot then
		if not inBag then 
			CSPS.post(GS(SI_PROSPECTIVEPICKPOCKETRESULT4)) 
			return 
		else
			destBag = BAG_SUBSCRIBER_BANK
			destSlot = FindFirstEmptySlotInBag(BAG_SUBSCRIBER_BANK)
		end
	end
	if not destSlot then cspsPost(GS(SI_INVENTORY_ERROR_BANK_FULL)) return end
	cspsD("Trying to move")	
	if IsProtectedFunction("RequestMoveItem") then
		CallSecureProtected("RequestMoveItem", itemData.bagId, itemData.slotIndex, destBag, destSlot, 1)
	else
		RequestMoveItem(itemData.bagId, itemData.slotIndex, destBag, destSlot, 1)
	end
end
--SI_SMITHING_CONSOLIDATED_STATION_ADD_SET_DIALOG_SELECT_ALL
--SI_CRAFTING_CLEAR_SELECTIONS

function CSPS.craftListRowMouseUp(control, button, upInside)
	if not upInside then return end
	if button == 2 then
		ClearMenu()
		AddCustomMenuItem(GS(SI_ABILITY_ACTION_CLEAR_SLOT), function() 
			if control.data.svData.reference then 
				-- enchantment could be in line on LLC even for recon
				if LLC then LLC:cancelItemByReference(control.data.svData.reference) end
				craftingRequests[control.data.svData.reference] = nil
			end
			CSPS.savedVariables.craftList[control.data.index] = nil
			CSPS.visualCraftList:RefreshData()
			end)
		AddCustomMenuItem(GS(SI_ITEM_ACTION_LINK_TO_CHAT), function() ZO_LinkHandler_InsertLink(control.data.link) end)	
		ShowMenu()
		return
	end
	if control.data.svData.uniqueId or (GetInteractionType() == INTERACTION_BANK and (control.data.svData.waitingForEnchantment or control.data.svData.waitingForUpgrade)) then 
		transferItemByData(control.data)
		return 
	end
	
	if not LLC then cspsD(GS(CSPS_LLC_NEEDED)) return end
	switchAutoCraft(control.data)

	CSPS.visualCraftList:RefreshVisible()
end


function craftListClass:BuildMasterList()
	self.masterList = { }
	CSPS.savedVariables.craftList = CSPS.savedVariables.craftList or {}
	local needsTreeRefresh = false
	for i, v in pairs(CSPS.savedVariables.craftList) do
		local itemRemoved = false
		v.reference = v.reference or "CSPS-"..i
		if v.uniqueId then
			local bagId, slotIndex = findUniqueItem(v.uniqueId)
			if bagId then
				craftedItems[v.reference] = {bagId = bagId, slotIndex = slotIndex, data = v, uniqueId = v.uniqueId}
				if bagId == BAG_BACKPACK and v.charId == GetCurrentCharacterId() then
					if v.gearSlot then
						local setIdFits, enchantFits, qualityFits, typeFits, traitFits = checkItemForSlot(GetItemLink(bagId, slotIndex), v.gearSlot)
						if setIdFits and enchantFits and qualityFits and typeFits and traitFits then
							setFromBagAndSlot(v.gearSlot, bagId, slotIndex)
							needsTreeRefresh = true
						end
					end
					craftedItems[v.reference] = nil
					CSPS.savedVariables.craftList[i] = nil
					itemRemoved = true
				end
			else
				v.uniqueId = nil
			end
		elseif v.waitingForEnchantment or v.waitingForUpgrade then
			local bagId, slotIndex = findUniqueItem(v.waitingForEnchantment or v.waitingForUpgrade)
			if bagId then
				craftedItems[v.reference] = {bagId = bagId, slotIndex = slotIndex, data = v, uniqueId = v.waitingForEnchantment or v.waitingForUpgrade}
				local finished = true
				if v.waitingForEnchantment and GetItemLinkFinalEnchantId(GetItemLink(bagId,slotIndex)) ~= GetItemLinkFinalEnchantId(v.link) then
					createEnchantRequest(v, v.waitingForEnchantment, v.link, bagId, slotIndex)
					finished = false
				end
				if v.waitingForUpgrade and GetItemLinkQuality(GetItemLink(bagId, slotIndex)) ~= GetItemLinkQuality(v.link) then
					createUpgradeRequest(v, v.waitingForUpgrade, bagId, slotIndex, GetItemLinkQuality(v.link))
					finished = false
				end
				if finished then 
					finishedItem(i, v, bagId, slotIndex, true) -- true: do not refresh list that's just being built
				end
			else
				v.waitingForEnchantment = nil
				v.waitingForUpgrade = nil
			end
		end
		if not itemRemoved then
			if not v.uniqueId and not v.waitingForEnchantment and not v.waitingForUpgrade then
				createCraftRequest(v, v.link, i, v.recon, forceNew)
			end
			table.insert(self.masterList, {link = v.link, recon = v.recon, svData = v, index = i})
		end
	end
	
	if needsTreeRefresh then CSPS.refreshTree() end
end

function craftListClass:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)
	for _, data in ipairs(self.masterList) do
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

local hasShownCraftList = false

function CSPS.showCraftList()
	if not LLC and not hasShownCraftList then 
		hasShownCraftList = true
		cspsPost(GS(CSPS_LLC_NEEDED))
	end
	if not CSPS.visualCraftList then
		local clWin = CSPSWindowCraftList
		CSPS.visualCraftList = craftListClass:New(clWin)
		local waitingForRefresh = false
		clWin:SetHandler("OnEffectivelyShown",  function() 
			EVENT_MANAGER:RegisterForEvent("CSPS_BANK_CRAFTED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, 
				function(_, eBagId, eSlotIndex, _, _, eReason, eStackChange)
					cspsD("Inventory slot update")					
					if eStackChange ~= -1 then return end
					cspsD("Stack change is -1")
					if not waitingForRefresh then
						waitingForRefresh = true
						zo_callLater(function()	CSPS.visualCraftList:RefreshData() waitingForRefresh = false end, 420)
					end
				end)
		end)
		clWin:SetHandler("OnEffectivelyHidden", function() 
			EVENT_MANAGER:UnregisterForEvent("CSPS_BANK_CRAFTED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
		end)
	else
		CSPS.visualCraftList:RefreshData()
	end
end