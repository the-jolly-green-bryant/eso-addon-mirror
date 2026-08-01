-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Functions_ItemOptional.lua
-- File Description: This file contains functions, which don't need an item to work and don't give informations about the item in the first line.
-- Load Order Requirements: before Rule, after RuleEnvironment, Utilities, any Extensions
-- 
-----------------------------------------------------------------------------------

-- Imports
local RbI = RulebasedInventory
local ruleEnv = RbI.Import(RbI.ruleEnvironment)
local self = RbI.Import(RbI.executionEnv)
local ctx = RbI.Import(self.ctx)
local ext = RbI.Import(RbI.extensions)
local utils = RbI.Import(RbI.utils)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Crafting skill functions --------------------------------------------------
------------------------------------------------------------------------------

-- @return the number of the skill [0-7], 0: none, 7:jewelry
local function getCraftingTypeValueFromItem()
	local craftingSkill = GetItemLinkCraftingSkillType(ctx.itemLink) -- gearCraftingType-method
	if(craftingSkill == CRAFTING_TYPE_INVALID) then
		craftingSkill = GetItemLinkRecipeCraftingSkillType(ctx.itemLink) -- recipeCraftingType-method
	end
	if(craftingSkill == CRAFTING_TYPE_INVALID) then
		if(self.type('material_raw_jewelrytrait')) then
			craftingSkill = CRAFTING_TYPE_JEWELRYCRAFTING
		else
			local itemLinkId = GetItemLinkItemId(ctx.itemLink)
			craftingSkill = RbI.itemCatalog.furnishingCraftingType[itemLinkId] or 0
		end
	end
	if(craftingSkill == CRAFTING_TYPE_INVALID) then
		local icon = GetItemLinkInfo(ctx.itemLink)
		craftingSkill = RbI.itemCatalog.masterwritIcon2CraftingType[icon] or 0
	end
	return craftingSkill
end

-- @param 'craftingSkillName': if not given the craftingType will be determined from the item (also for furnishings and masterwrits)
-- 							   otherwise the given craftingSkillName will be used
-- @return the number of the skill [0-7], 0: none, 7:jewelry
local craftingTypeGetValue = ruleEnv.Register("craftingTypeGetValue", function(craftingSkillName)
	if(craftingSkillName == nil) then -- no argument => auto retrieval craftskill
		return getCraftingTypeValueFromItem()
	end
	local craftingSkill = RbI.dataType.gearCraftingType[craftingSkillName:lower()] -- same mapping as recipeCraftingType
	if(craftingSkill == nil) then
		ruleEnv.errorInvalidArgument(1, craftingSkillName, 'gearCraftingType', 'craftingType')
	end
	return craftingSkill
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

ruleEnv.Register("craftingType", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(#{...} == 0) then
		return craftingSkill
	end
	local args = ruleEnv.GetArguments('CraftingType', true, 'gearCraftingType', ...)
	return utils.TableContainsValue(args, craftingSkill)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_LINKONLY)

local craftingLevel = ruleEnv.Register("craftingLevel", function(craftingSkillName)
	local craftingSkill = craftingTypeGetValue(craftingSkillName)
	if(craftingSkill == 0) then return RbI.NaN end
	local skillType, skillId = GetCraftingSkillLineIndices(craftingSkill)
	local _, level = GetSkillLineInfo(skillType, skillId)
	return level or 0
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)
ruleEnv.Register("skilllinelevel", craftingLevel, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY) -- deprecated 'skilllinelevel'

-- @return the minimum level of all given characters
-- @require RequireMultiCharactersApi
ruleEnv.Register("craftingLevelMin", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetCraftingLevelMin(craftingSkill, 50, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

-- @return the maximum level of all given characters
-- @require RequireMultiCharactersApi
ruleEnv.Register("craftingLevelMax", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetCraftingLevelMax(craftingSkill, 0, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

-- @return if characters in list before current character need leveling in craftskillline
-- @require RequireMultiCharactersApi
ruleEnv.Register("needCraftingLevelInOrder", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().InOrderCraftingLevel(true, craftingSkill, charNames)
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)
ruleEnv.Register("needCraftingLevel", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().InOrderCraftingLevel(false, craftingSkill, charNames)
end, ruleEnv.GET_BOOL, ruleEnv.NEED_LINKONLY)

local bonusTable = {
	[CRAFTING_TYPE_ALCHEMY] = NON_COMBAT_BONUS_ALCHEMY_LEVEL,
	[CRAFTING_TYPE_BLACKSMITHING] = NON_COMBAT_BONUS_BLACKSMITHING_LEVEL,
	[CRAFTING_TYPE_CLOTHIER] = NON_COMBAT_BONUS_CLOTHIER_LEVEL,
	[CRAFTING_TYPE_ENCHANTING] = NON_COMBAT_BONUS_ENCHANTING_LEVEL,
	[CRAFTING_TYPE_PROVISIONING] = NON_COMBAT_BONUS_PROVISIONING_LEVEL,
	[CRAFTING_TYPE_WOODWORKING] = NON_COMBAT_BONUS_WOODWORKING_LEVEL,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = NON_COMBAT_BONUS_JEWELRYCRAFTING_LEVEL,
}
local craftingRank = ruleEnv.Register("craftingRank", function(craftingSkillName)
	local craftingSkill = craftingTypeGetValue(craftingSkillName)
	if(craftingSkill == 0) then return RbI.NaN end
	local bonus = bonusTable[craftingSkill]
	return GetNonCombatBonus(bonus) or 0
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

-- @return the minimum rank of all given characters
-- @require MultiCharactersApi
ruleEnv.Register("craftingRankMin", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetCraftingRankMin(craftingSkill, 50, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

-- @return the maximum rank of all given characters
-- @require MultiCharactersApi
ruleEnv.Register("craftingRankMax", function(...)
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetCraftingRankMax(craftingSkill, 0, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)

-- @return how many characters have the same 'required rank'
-- @require MultiCharactersApi
ruleEnv.Register("craftingRankCount", function(...)
	local firstArg = select(1, ...)
	local rank, firstCharIndex
	if(type(firstArg) == 'number') then
		rank = firstArg
		firstCharIndex = 2
	else
		rank = self.craftingRankRequired()
		firstCharIndex = 1
	end
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0 or rank == 0) then return RbI.NaN end
	local charNames = ruleEnv.GetCharactersNames(true, select(firstCharIndex, ...))
	return ext.RequireMultiCharactersApi().GetCraftingRankCount(craftingSkill, rank, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)


local bonusTableExtract = {
	[CRAFTING_TYPE_BLACKSMITHING] = NON_COMBAT_BONUS_BLACKSMITHING_EXTRACT_LEVEL,
	[CRAFTING_TYPE_CLOTHIER] = NON_COMBAT_BONUS_CLOTHIER_EXTRACT_LEVEL,
	[CRAFTING_TYPE_WOODWORKING] = NON_COMBAT_BONUS_WOODWORKING_EXTRACT_LEVEL,
	[CRAFTING_TYPE_JEWELRYCRAFTING] = NON_COMBAT_BONUS_JEWELRYCRAFTING_EXTRACT_LEVEL,
	[CRAFTING_TYPE_ENCHANTING] = NON_COMBAT_BONUS_ENCHANTING_DECONSTRUCTION_UPGRADE,
}
-- GetNonCombatBonus returns 0 if the character has not the skillline activated (craftingRank==0)
-- returns 1-4 for level 0-3, so we have to subtract 1 for this
ruleEnv.Register("craftingExtractBonus", function()
	local craftingSkill = craftingTypeGetValue()
	if(craftingSkill == 0) then return RbI.NaN end
	local bonus = bonusTableExtract[craftingSkill]
	local result = GetNonCombatBonus(bonus)
	if(result == 0 or craftingSkill == CRAFTING_TYPE_ENCHANTING) then return result end
	return result - 1
end, ruleEnv.GET_INT, ruleEnv.NEED_LINKONLY)