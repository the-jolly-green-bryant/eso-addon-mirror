DQT.Quest = {}

-------- Quest --------
-- boilerplate for class definition
local Quest = ZO_Object:Subclass()
DQT.Quest.Quest = Quest

function Quest:new(...)
	local object = ZO_Object.New(self)
	object:init(...)
	return object
end

--[[
	@param name (string) unique name of quest as it appears in quest journal
	@param displayName (string) (optional) alternate name to display
--]]
function Quest:init(name, displayName)
	self._name = name
	self._displayName = displayName or name
end

function Quest:getName()
	return self._name
end

function Quest:getDisplayName()
	return self._displayName
end

-- equality operator overload
function Quest.eq(left, right)
	return left._name == right._name
end

-------- Quest Type --------
local QUEST_TYPE_ENUM = {
	GROUP_BOSS = 1,
	DELVE = 2, -- delves and public dungeons
	DOLMEN = 3, -- dolmens and geysers,
	PLEDGE = 4,
	MISC = 5
}
	
DQT.Quest.QUEST_TYPE_ENUM = QUEST_TYPE_ENUM

-- boilerplate for class definition
local QuestType = ZO_Object:Subclass()
DQT.Quest.QuestType = QuestType

function QuestType:new(...)
	local object = ZO_Object.New(self)
	object:init(...)
	return object
end

--[[
	A Quest Type represent a collection of quests, of which your character can be given one per day.
	Some quest types have multiple quests in them that can be shared.
	
	@param name (string)
	@param (QUEST_TYPE_ENUM)
	@param quests (list) Quest objects
	@param isShareable (boolean) (optional) defaults to true if more than one quest
--]]
function QuestType:init(name, type, quests, isShareable)
	self._name = name

	self._type = type
	self._quests = quests
	
	self._isShareable = (isShareable ~= false) and (#quests > 1)
end

function QuestType:getName()
	return self._name
end

function QuestType:getQuests()
	return self._quests
end

function QuestType:isShareable()
	return self._isShareable
end

-- equality operator overload
function QuestType.eq(left, right)
	if left._name ~= right._name then
		return false
	end
	
	if #left._quests ~= #right._quests then
		return false
	end
	
	for i, leftQuest in ipairs(left._quests) do
		if leftQuest ~= right._quests[i] then
			return false
		end
	end
	
	return true
end

-------- Quest Section --------

-- boilerplate for class definition
local QuestSection = ZO_Object:Subclass()
DQT.Quest.QuestSection = QuestSection

function QuestSection:new(...)
	local object = ZO_Object.New(self)
	object:init(...)
	return object
end

--[[
	A quest section represents a category of quest types to group together
	
	@param name (string) a unique section name
	@param questTypes (list) QuestType objects
--]]
function QuestSection:init(name, questTypes)
	self._name = name
	self._questTypes = questTypes
end

function QuestSection:getName()
	return self._name
end

function QuestSection:getQuestTypes()
	return self._questTypes
end

-- equality operator overload
function QuestSection.eq(left, right)
	return left._name == right._name
end

-- class type
function QuestSection.type()
	return "QuestSection"
end