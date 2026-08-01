local PriorityRecast = PriorityRecast
local SkillId        = PriorityRecast.SkillId
local AlternateSkill = PriorityRecast.AlternateSkill

local TableClear     = ZO_ClearNumericallyIndexedTable
local TableCopy      = ZO_ShallowNumericallyIndexedTableCopy
local TableInsert    = table.insert
local TableRemove    = table.remove
local TableLength    = table.getn

-------------------------------------------------------------------------------
-- PRIORITIES MODEL
-------------------------------------------------------------------------------
-- The priority list itself acts as an ordered set. Duplicate entries are moved
-- to the requested index. New entries that have an alternate are also inserted
-- alongside the base skill. The priority model also stores duration offsets
-- for skills that have a duration.
-------------------------------------------------------------------------------

local Priorities = { }

local priorities = { }
local offsets    = { }
local builds     = { }


-- Load Saved Variables -------------------------------------------------------

local function LoadSavedLists()

	local name    = "PriorityRecastSaved"
	local server  = GetWorldName()
	local version = 1

	local saved = ZO_SavedVars:NewCharacterIdSettings(name, version, nil, {
		priorities = priorities,
		offsets    = offsets,
		builds     = builds
	}, server)

	priorities = saved.priorities
	offsets    = saved.offsets
	builds     = saved.builds
end


-- Table Insert/Append --------------------------------------------------------

local function Insert(skillId, toIndex)
	if not toIndex
		then TableInsert(priorities, skillId)
		else TableInsert(priorities, toIndex, skillId)
	end
end


-- Table Move Entry -----------------------------------------------------------

local function Move(fromIndex, toIndex)
	if fromIndex == toIndex then return end

	-- Remove and insert at new index.
	local skillId = TableRemove(priorities, fromIndex)
	Insert(skillId, toIndex)

	-- Inform observers to update.
	PriorityRecast:FireCallbacks("PrioritiesUpdated")
end


-- Priorities Iterator --------------------------------------------------------

function Priorities.Iter()
	local index  = 0
	local length = TableLength(priorities)

	return function()
		index = index + 1
		if index > length then return end

		local skillId = priorities[index]
		local offset  = offsets[skillId] or 0

		return index, skillId, offset
	end
end


-- Priorities Empty? ----------------------------------------------------------

function Priorities.IsEmpty()
	return TableLength(priorities) == 0
end


-- Save Offset Time -----------------------------------------------------------

function Priorities.SaveOffset(skillId, offset)
	offsets[skillId] = offset
end


-- Priorities Insert Skill ----------------------------------------------------

function Priorities.Insert(givenId, toIndex)

	local newId = SkillId(givenId)
	local altId = AlternateSkill(newId)

	local givenIndex = nil
	local newIndex   = nil
	local altIndex   = nil

	for index, id in Priorities.Iter() do
		if id == givenId then givenIndex = index end
		if id == newId   then newIndex   = index end
		if id == altId   then altIndex   = index end
	end

	-- Internal move of exiting entry.
	if givenIndex then return Move(givenIndex, toIndex) end

	-- Insert/append new entry.
	if newId and not newIndex then Insert(newId, toIndex) end

	-- Insert/append new alt entry.
	if altId and not altIndex then Insert(altId, toIndex) end

	-- Inform observers to update.
	PriorityRecast:FireCallbacks("PrioritiesUpdated")
end


-- Priorities Remove Skill ----------------------------------------------------

function Priorities.Remove(fromIndex)

	TableRemove(priorities, fromIndex)

	-- Inform observers to update.
	PriorityRecast:FireCallbacks("PrioritiesUpdated")
end

-------------------------------------------------------------------------------
-- SAVE/LOAD BUILDS
-------------------------------------------------------------------------------
-- Priority lists can be saved and loaded from armory builds.
-------------------------------------------------------------------------------

local function LoadBuild(buildIndex)

	-- Get or create the build.
	builds[buildIndex] = builds[buildIndex] or {}
	local build = builds[buildIndex]

	-- Transfer build to priorities.
	TableClear(priorities)
	TableCopy(build, priorities)

	-- Inform observers to update.
	PriorityRecast:FireCallbacks("PrioritiesUpdated")
end


local function SaveBuild(buildIndex)

	-- Get or create the build.
	builds[buildIndex] = builds[buildIndex] or {}
	local build = builds[buildIndex]

	-- Transfer priorities to build.
	TableClear(build)
	TableCopy(priorities, build)
end


local function ArmoryOperation(_, operationType, buildIndex)

	if operationType == ARMORY_BUILD_OPERATION_TYPE_RESTORE then
		LoadBuild(buildIndex)
	end

	if operationType == ARMORY_BUILD_OPERATION_TYPE_SAVE then
		SaveBuild(buildIndex)
	end
end

-------------------------------------------------------------------------------
-- ADDON INITIALIZE
-------------------------------------------------------------------------------

PriorityRecast:RegisterCallback("AddonLoaded", function()
	LoadSavedLists()
	PriorityRecast:On(EVENT_ARMORY_BUILD_OPERATION_STARTED, ArmoryOperation)
end)

-------------------------------------------------------------------------------
-- EXPORTS
-------------------------------------------------------------------------------

PriorityRecast.Priorities = Priorities
