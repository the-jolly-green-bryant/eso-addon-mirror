local sf = string.format
TB_Crafting = ZO_Object:Subclass()

-- Temporary links
-- https://github.com/Dolgubon/DolgubonsLazyWritCreator/blob/master/WritCreater.lua
-- https://github.com/ziggr/ESO-WritWorthy/blob/master/WritWorthy_Window.lua

-- new function EventEnumToString (event) from LibLazyCrafting
-- example event LLC_CRAFT_SUCCESS
-- return string
local function EventEnumToString(event)
    local LLC_EVENTS = {
		[LLC_CRAFT_SUCCESS] = "LLC_CRAFT_SUCCESS",
		[LLC_ITEM_TO_IMPROVE_NOT_FOUND] = "LLC_ITEM_TO_IMPROVE_NOT_FOUND",
		[LLC_INSUFFICIENT_MATERIALS] = "LLC_INSUFFICIENT_MATERIALS",
		[LLC_INSUFFICIENT_SKILL] = "LLC_INSUFFICIENT_SKILL",
		[LLC_INITIAL_CRAFT_SUCCESS] = "LLC_INITIAL_CRAFT_SUCCESS",
		[LLC_ENCHANTMENT_FAILED] = "LLC_ENCHANTMENT_FAILED",
		[LLC_CRAFT_PARTIAL_IMPROVEMENT] = "LLC_CRAFT_PARTIAL_IMPROVEMENT",
		[LLC_CRAFT_BEGIN] = "LLC_CRAFT_BEGIN",
		[LLC_NO_FURTHER_CRAFT_POSSIBLE] = "LLC_NO_FURTHER_CRAFT_POSSIBLE"
	}
	if LLC_EVENTS[event] then
		return LLC_EVENTS[event]
	else
		return "UNKNOWN"
	end
end

local function IsCraftingtypeAllowed(craftingType)
	for _,craftingSkillType in pairs(TraitBuddy:GetCraftingSkillTypes()) do
		if craftingType == craftingSkillType then
			return true
		end
	end
	return false
end

local function LLC_CallbackFunction(event, craftingType, requestTable, ...)
	--[[
		function callbackFunction ( String event, integer CraftingType, table requestTable)
		The function that should be called when a requested craft is either complete, or failed for some reason. Not all parameters will always be returned
		Its not just this addon which can fire this event
	]]--

	d("TraitBuddy DEBUG: LLC_CallbackFunction()")
	d(sf("event:%s type:%s '%s'", EventEnumToString(event), ZO_GetCraftingSkillName(craftingType), event))
	d(requestTable)

	if IsCraftingtypeAllowed(craftingType) then
		if "@Weolo" == GetDisplayName() then
			--TraitBuddy.data:TestPatterns()
		end

		-- if requestTable then
		-- 	d("requestTable")
		-- 	d(requestTable)
		-- else
		-- 	d("no requestTable")
		-- end
	end
end

local function GetPatterns()
	-- Pattern index is only available when interacting with crafting stations
	-- [craftingSkillType] patternIndexes are in researchLineIndex order
	local patternIndexes = {
		[CRAFTING_TYPE_BLACKSMITHING] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14},
		[CRAFTING_TYPE_CLOTHIER]={1,3,4,5,6,7,8,9,10,11,12,13,14,15},
		[CRAFTING_TYPE_WOODWORKING] = {1,3,4,5,6,2},
		[CRAFTING_TYPE_JEWELRYCRAFTING] = {2,1}
	}
	return patternIndexes
end

local function GetPatternNames()
	local names = {
		[CRAFTING_TYPE_BLACKSMITHING] = {"Axe", "Mace", "Sword", "Battle Axe", "Maul", "Greatsword", "Dagger", "Cuirass", "Sabatons", "Gauntlets", "Helm", "Greaves", "Pauldron", "Girdle"},
		[CRAFTING_TYPE_CLOTHIER]={"Robe", "Shoes", "Gloves", "Hat", "Breeches", "Epaulets", "Sash", "Jack", "Boots", "Bracers", "Helmet", "Guards", "Arm Cops", "Belt"},
		[CRAFTING_TYPE_WOODWORKING] = {"Bow", "Inferno Staff", "Ice Staff", "Lightning Staff", "Restoration Staff", "Shield"},
		[CRAFTING_TYPE_JEWELRYCRAFTING] = {"Necklace", "Ring"}
	}
	return names
end

function TB_Crafting:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end

function TB_Crafting:Initialize()
	if LibLazyCrafting then
		-- AddRequestingAddon(addonName, autocraft, functionCallback, optionalDebugAuthor, styleTable)
		local autoCraft = true
		local debugAuthor = "@Weolo" -- optional
		local styles = self:GetCommonStyles()
		local interactionTable = LibLazyCrafting:AddRequestingAddon(TraitBuddy.ADDON_NAME, autoCraft, LLC_CallbackFunction, debugAuthor, styles)
		self.LLC = interactionTable
	end
end

function TB_Crafting:Available(warn)
	local available = (self.LLC ~= nil)
	if not available and warn == true then
		d( sf("%s LibLazyCrafting", GetString(SI_ADDON_MANAGER_DEPENDENCIES)) )
	end
	return available
end

function TB_Crafting:Version()
	if not self:Available() then return 0 end
	return LibLazyCrafting.version
end

function TB_Crafting:GetPatternIndex(craftingSkillType, researchLineIndex)
	local patternIndexes = GetPatterns()
	return patternIndexes[craftingSkillType][researchLineIndex]
end

function TB_Crafting:GetCommonStyles()
	-- d("TraitBuddy DEBUG: GetCommonStyles()")
	local styles = {}
	local STYLE_KHAJIIT = 9
	for itemStyleIndex = 1, STYLE_KHAJIIT do
		local itemStyleId = GetValidItemStyleId(itemStyleIndex)
		if itemStyleId > 0 then
			-- d(sf("Adding style %s itemStyleId %s", GetItemStyleName(itemStyleId), itemStyleId))
			styles[itemStyleId] = true
		end
	end
	return styles
end

-- Craft LibLazyCrafting item using craftingSkillType, researchLineIndex, traitIndex, and reference
-- materialIndex is always 1
-- styleIndex should be the simplest possible style for the item
function TB_Crafting:Craft(craftingSkillType, researchLineIndex, traitIndex, reference)
	if not self:Available() then return end

	--[[
		CraftSmithingItem( integer patternIndex, integer materialIndex, integer materialQuantity, integer styleIndex, integer traitIndex, boolean useUniversalStyleItem, integer:nilable stationOverride, integer:nilable setIndex, integer:nilable quality, boolean:nilable autocraft, anything:nilable reference)
		This is the main function in this module. patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, and useUniversalStyleItem act in the same way as the ZOS provided CraftSmithingItem's parameters do.
		stationOverride: Allows you to set a specific crafting station. Default is the station you are at. If you are not at a station the function will fail.
		setIndex: An integer determining the crafted set you wish to create. The default is 1, which signifies no set. A list of set indexes can be found in the Smithing.lua file, or with GetSetIndexes()
		quality: One of the ITEM_QUALITY global constants. The default is white quality.
		autocraft: Determines if the library will craft the item. If it is false, the library will keep it in queue until the requesting addon tells it to craft the item.
		reference: This can be any type of data. It lets your addon to identify the request, to delete it, craft it, and know when it is complete. The default is the empty string.
		potencyId, essenceId, aspectId: If you want to create equipment with glyphs, use these parameters
		quantity: How many to make
		returns: The request table, which contains all the information about the craft request.

		-- local itemName, icon, stack, sellPrice, meetsUsageRequirement, equipType, itemStyleId, displayQuality, itemInstanceId, skillRequirement, createsItemOfLevel, isChampionPoint = GetSmithingPatternMaterialItemInfo(patternIndex, materialIndex)
	]]--
	d("TraitBuddy DEBUG: Craft()")
	d( sf("Parameters: %d %d traitIndex:%d %s", craftingSkillType, researchLineIndex, traitIndex, reference) )
	local STYLE_BRETON = 5
	local patternIndex = self:GetPatternIndex(craftingSkillType, researchLineIndex)
	-- local materialIndex = 1
	-- local materialQuantity = nil
	local isCP = false
	local level = 1
	local styleIndex = LLC_FREE_STYLE_CHOICE
	styleIndex = STYLE_BRETON
	local useUniversalStyleItem = false
	local setIndex = LibLazyCrafting.INDEX_NO_SET
	local quality = ITEM_FUNCTIONAL_QUALITY_NORMAL
	local autocraft = true
	-- styleIndex is the motif number for instance 1 = High Elf
	-- local requestTable = self.LLC:CraftSmithingItem(patternIndex, materialIndex, materialQuantity, styleIndex, traitIndex, useUniversalStyleItem, craftingSkillType, setIndex, quality, autocraft, reference)
	local requestTable = self.LLC:CraftSmithingItemByLevel(patternIndex, isCP, level, styleIndex, traitIndex, useUniversalStyleItem, craftingSkillType, setIndex, quality, autocraft, reference)
end
