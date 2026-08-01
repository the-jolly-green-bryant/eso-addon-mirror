-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: Functions_NoItem.lua
-- File Description: This file contains non item related functions.
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
-- RbI functions -------------------------------------------------------------
------------------------------------------------------------------------------

local rule = ruleEnv.Register("rule", function(ruleName)
	local rule = RbI.rules.user[ruleName:lower()]
	if(rule == nil) then
		ruleEnv.errorInvalidArgument(nil, ruleName, RbI.account.rules, 'Rulename')
	end
	return ruleEnv.EvaluateRule(rule)
end, ruleEnv.NEED_NOITEM)
ruleEnv.Register("_", rule, ruleEnv.NEED_NOITEM)

ruleEnv.Register("constant", function(constantName)
	local compiledContent = RbI.constants[constantName:lower()]
	if(compiledContent == nil) then
		ruleEnv.errorInvalidArgument(nil, constantName, RbI.account.constants, 'Constantname')
	end
	if(type(compiledContent) == 'function') then return compiledContent() end
	return compiledContent
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("task", function(taskName)
	return ctx.taskName == taskName
end, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Inventory functions -------------------------------------------------------
------------------------------------------------------------------------------

-- return <bool> 'true': if one of the given banks is currently opened
-- @NotItemRelated
ruleEnv.Register("targetBank", function(...)
	local bagId = ctx.station
	if(bagId == nil) then return true end -- test-button
	return ruleEnv.Validate('Bank', true, 'bank', bagId, ...)
end, ruleEnv.NI_BOOL, ruleEnv.NEED_NOITEM)

-- @NotItemRelated
ruleEnv.Register("freeslots", function(...)
	local input = ruleEnv.GetArguments('freeslots', true, nil, ...)

	local count = 0
	local data = RbI.dataType['bag']

	for i = 1, #input do
		if (data[input[i]] == nil) then
			ruleEnv.errorInvalidArgument(i, input[i], data)
		else
			count = count + GetNumBagFreeSlots(data[input[i]])
		end
	end
	return count
end, ruleEnv.NI_INT, ruleEnv.NEED_NOITEM)


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Account functions ---------------------------------------------------------
------------------------------------------------------------------------------

-- implemented by MegwynW
-- @NotItemRelated
ruleEnv.Register("esoplus", function()
	return IsESOPlusSubscriber()
end, ruleEnv.NI_BOOL, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Character functions -------------------------------------------------------
------------------------------------------------------------------------------

-- @return the level of specified character
-- @require RequireMultiCharactersApi
ruleEnv.Register("characterLevel", function(charName)
	return ext.RequireMultiCharactersApi().GetCharacterLevel(charName or RbI.GetUnitName('player'))
end, ruleEnv.GET_INT, ruleEnv.NEED_NOITEM)

-- @return the minimum level of all given characters
-- @require RequireMultiCharactersApi
ruleEnv.Register("characterLevelMin", function(...)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetCharacterLevelMin(50, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_NOITEM)

-- @return the maximum level of all given characters
-- @require RequireMultiCharactersApi
ruleEnv.Register("characterLevelMax", function(...)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetCharacterLevelMax(0, charNames)
end, ruleEnv.GET_INT, ruleEnv.NEED_NOITEM)

-- implemented by MegwynW
local function isCharacter(...)
	local charNames = ruleEnv.GetCharactersNames(nil, ...)
	local thisCharactersName = RbI.GetUnitName('player')

	for i = 1, #charNames do
		if (thisCharactersName == charNames[i]) then
			return true
		end
	end

	return false
end

-- @NotItemRelated
ruleEnv.Register("isCharacter", isCharacter, ruleEnv.NI_BOOL, ruleEnv.NEED_NOITEM)

-- @return the current character name
ruleEnv.Register("characterName", function(...)
	local hasAny = false
	for _,_ in pairs({...}) do
		hasAny = true
		break
	end
	if(hasAny) then
		return isCharacter(...)
	else
		return RbI.GetUnitName('player')
	end
end, ruleEnv.GET_STRING, ruleEnv.NEED_NOITEM)

ruleEnv.Register("stealthState", function(...)
	local stealthState = GetUnitStealthState("player")
	return ruleEnv.Validate('StealthState', true, 'stealthState', stealthState, ...)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_NOITEM)

local mountTrainTypeGet = function(mountSkillName)
	return ruleEnv.GetArguments('mountTrainType', true, 'mountTrainType', mountSkillName)[1]
end
local mountSkillMap = {
	[RIDING_TRAIN_CARRYING_CAPACITY] = 1,
	[RIDING_TRAIN_STAMINA] = 3,
	[RIDING_TRAIN_SPEED] = 5,
}
local function getMountLevel(mountSkill)
	return select(mountSkillMap[mountSkill], GetRidingStats())
end
ruleEnv.Register("mountLevel", function(mountSkillName)
	return getMountLevel(mountTrainTypeGet(mountSkillName))
end, ruleEnv.NEED_NOITEM)

-- @return the minimum level of all given characters
ruleEnv.Register("mountLevelMin", function(mountSkillName, ...)
	local mountSkill = mountTrainTypeGet(mountSkillName)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetMountLevelMin(mountSkill, 50, charNames)
end, ruleEnv.NEED_NOITEM)

-- @return the maximum level of all given characters
ruleEnv.Register("mountLevelMax", function(mountSkillName, ...)
	local mountSkill = mountTrainTypeGet(mountSkillName)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().GetMountLevelMax(mountSkill, 0, charNames)
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("needMountLevelInOrder", function(mountSkillName, ...)
	local mountSkill = mountTrainTypeGet(mountSkillName)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().InOrderMountLevel(true, mountSkill, charNames)
end, ruleEnv.NEED_NOITEM)
ruleEnv.Register("needMountLevel", function(mountSkillName, ...)
	local mountSkill = mountTrainTypeGet(mountSkillName)
	local charNames = ruleEnv.GetCharactersNames(true, ...)
	return ext.RequireMultiCharactersApi().InOrderMountLevel(false, mountSkill, charNames)
end, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Champion Point Tree functions ---------------------------------------------
------------------------------------------------------------------------------

-- GetChampionSkillCurrentBonusText()
-- GetChampionSkillData()
-- GetChampionSkillDescription()
-- GetChampionSkillId()
-- GetChampionSkillJumpPoints()
-- GetChampionSkillLinkIds()
-- GetChampionSkillMaxPoints()
-- GetChampionSkillName()
-- GetChampionSkillPosition()
-- GetChampionSkillType()

local function IsCPSlotted(skillId)
	for index=1, 4 do
		if GetSlotBoundId(index, HOTBAR_CATEGORY_CHAMPION) == skillId then
			return true
		end
	end
	return false
end

-- required points for first jump point
local function RequiredPoints(cSkillId)
	if not DoesChampionSkillHaveJumpPoints(cSkillId) then return 1 end
	local _, firstJumpPoint = GetChampionSkillJumpPoints(cSkillId)
	return firstJumpPoint
end

local function IsCPSlotable(skillId)
	return CanChampionSkillTypeBeSlotted(GetChampionSkillType(skillId))
end

-- return <int> if its a passive or slotted it will return the spent points into this skill
-- @NotItemRelated
ruleEnv.Register("cSkill", function(skillName)
	skillName = string.lower(skillName)
	if(not IsChampionSystemUnlocked()) then
		return false
	end
	local cSkillId = ruleEnv.GetArguments("cSkillName", true, "cSkill", skillName)[1]
	if(not IsCPSlotable(cSkillId) or IsCPSlotted(cSkillId)) then
		return GetNumPointsSpentOnChampionSkill(cSkillId)
	end
	return 0
end, ruleEnv.NI_INT, ruleEnv.NEED_NOITEM)

-- return <int> how many champion points spended in this skill
-- @NotItemRelated
ruleEnv.Register("cSkillSpent", function(skillName)
	skillName = string.lower(skillName)
	if(not IsChampionSystemUnlocked()) then
		return 0
	end
	local cSkillId = ruleEnv.GetArguments("cSkillName", true, "cSkill", skillName)[1]
	return GetNumPointsSpentOnChampionSkill(cSkillId)
end, ruleEnv.NI_INT, ruleEnv.NEED_NOITEM)

-- return <boolean>
-- @NotItemRelated
ruleEnv.Register("cSkillSlotted", function(skillName)
	skillName = string.lower(skillName)
	if(not IsChampionSystemUnlocked()) then
		return false
	end
	local cSkillId = ruleEnv.GetArguments("cSkillName", true, "cSkill", skillName)[1]
	return IsCPSlotted(cSkillId)
end, ruleEnv.NI_BOOL, ruleEnv.NEED_NOITEM)

-- return <boolean> true, when it is a slotable star and there are enough points
-- @NotItemRelated
ruleEnv.Register("cSkillSlotable", function(skillName)
	skillName = string.lower(skillName)
	if(not IsChampionSystemUnlocked()) then
		return false
	end
	local cSkillId = ruleEnv.GetArguments("cSkillName", true, "cSkill", skillName)[1]
	return IsCPSlotable(cSkillId) and GetNumPointsSpentOnChampionSkill(cSkillId) >= RequiredPoints(cSkillId)
end, ruleEnv.NI_BOOL, ruleEnv.NEED_NOITEM)

-- @NotItemRelated
ruleEnv.Register("cSkillTypeSlotable", function(skillName)
	skillName = string.lower(skillName)
	if(not IsChampionSystemUnlocked()) then
		return false
	end
	local cSkillId = ruleEnv.GetArguments("cSkillName", true, "cSkill", skillName)[1]
	return IsCPSlotable(cSkillId)
end, ruleEnv.NI_BOOL, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Quest functions -----------------------------------------------------------
------------------------------------------------------------------------------

ruleEnv.Register("hasQuest", function(...)
	local input = {...}
	if(#input == 0) then
		ruleEnv.errorInvalidArgument(nil, nil, 'questName', 'QuestName')
	end

	local quests = {}
	for i = 1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(i) then
			table.insert(quests, string.lower(GetJournalQuestName(i)))
		end
	end

	local match, message = utils.textCheckMany(input, quests, true)
	if match == nil then
		ruleEnv.error(message)
		return false
	end
	return match
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- ZoneType functions --------------------------------------------------------
------------------------------------------------------------------------------

ruleEnv.Register("zoneType", function(...)
	return ruleEnv.Validate('ZoneType', true, 'zoneType', ctx.zoneTypes, ...)
end, ruleEnv.MATCH_MATRIX, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Group functions ------------------------------------------------------------
------------------------------------------------------------------------------

ruleEnv.Register("groupSize", function()
	local size = GetGroupSize() -- returns 0 for not in group, otherwise >=2
	if(size == 0) then size = 1 end -- just to make it clear that we're solo
	return size
end, ruleEnv.NI_INT, ruleEnv.NEED_NOITEM)

ruleEnv.Register("groupRole", function(...)
	local groupRole = GetSelectedLFGRole()
	return ruleEnv.Validate('GroupRole', true, 'groupRole', groupRole, ...)
end, ruleEnv.MATCH_FILTER, ruleEnv.NEED_NOITEM)

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Test and alpha functions --------------------------------------------------
------------------------------------------------------------------------------

ruleEnv.Register("dump", function(...)
	d(ctx.itemLink..': '..tostring(...))
	return false
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("dumpWhen", function(value, ...)
	if(value) then
		if(select(1, ...) == nil) then
			d(ctx.itemLink..': '..tostring(value))
		else
			d(ctx.itemLink..': '..tostring(...))
		end
	end
	return value
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("dumpWhenF", function(value, ...)
	if(value) then
		if(select(1, ...) == nil) then
			d(ctx.itemLink..': '..tostring(value))
		else
			d(ctx.itemLink..': '..tostring(...))
		end
	end
	return false
end, ruleEnv.NEED_NOITEM)

-- arguments have to strings with rule-content
ruleEnv.Register("ensure", function(...)
	for _, content in pairs({...}) do
		if(type(content) ~= "string") then
			ruleEnv.error("Only string arguments with rulecode are permitted!")
		end
		local result = ruleEnv.RunRule(RbI.BaseRule("ensure", true, content))
		if(not result) then
			ruleEnv.error("Ensure failure "..content.." on item: "..ctx.itemLink)
		end
	end
	return true
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("call", function(fn)
	return fn()
end, ruleEnv.NEED_NOITEM)

-- emits an internal function error
ruleEnv.Register("fail", function(msg)
	ruleEnv.error(msg)
end, ruleEnv.NEED_NOITEM)

ruleEnv.Register("back", function(...)
	return ...
end, ruleEnv.NEED_NOITEM)