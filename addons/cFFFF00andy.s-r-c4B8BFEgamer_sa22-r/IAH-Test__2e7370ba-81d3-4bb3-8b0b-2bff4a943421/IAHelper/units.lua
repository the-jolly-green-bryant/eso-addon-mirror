-- A slightly modified version of Hodor's units to track ids of group members.
-- The only reason why I need this module is to filter attacks on the player,
-- because targetName and targetType from EVENT_COMBAT_EVENT are not reliable.
IAHelper.units = {}

IA_EVENT_UNITS_UPDATED = "UnitsUpdated"

local EM = EVENT_MANAGER
local units = IAHelper.units

local unitList = {}
local idTag = {}
local groupSizeOnline = 0 -- number of online group members
local unitsNum = 0 -- number of units added

local EVENT_GROUP_EFFECT = IAHelper.NAME .. 'GroupEffect'

function units.AddUnit(id, tag)
	local unit = unitList[tag]
	if unit and not idTag[id] then
		unit.id = id
		idTag[id] = tag
		unitsNum = unitsNum + 1
	end
	if unitsNum >= groupSizeOnline then -- found all ids for group members
		EM:UnregisterForEvent(EVENT_GROUP_EFFECT, EVENT_EFFECT_CHANGED)
	end
end

function units.GetTag(id)
	return idTag[id]
end

function units.GetId(tag)
	local unit = unitList[tag] -- accessing unitList[tag] twice is slower than creating a local variable for it
	return unit and unit.id
end

function units.IsOnline(tag)
	local unit = unitList[tag]
	return unit ~= nil and unit.isOnline
end

function units.IsPlayer(tag)
	local unit = unitList[tag]
	return unit and unit.isPlayer
end

function units.GetClassId(tag)
	local unit = unitList[tag]
	return unit and unit.classId
end

function units.GetName(tag)
	local unit = unitList[tag]
	return unit and unit.name
end

function units.GetDisplayName(tag)
	local unit = unitList[tag]
	return unit and unit.displayName
end

-- Returns real group tag for 'player' (if grouped)
function units.GetPlayerTag()
	local unit = unitList['player']
	return unit and unit.tag
end

function units.IsPlayerGrouped()
	return IsUnitGrouped('player')
end

-- Check if unit id is player
function units.IsPlayerUnitId(id)
	local unit = unitList['player']
	return id > 0 and unit.id == id
end

-- Returns true if unitId is a group member (including player, even if not grouped), false otherwise
function units.IsGroupUnitId(id)
	return idTag[id] ~= nil
end

function units.Refresh()
	unitList = {}
	idTag = {}
	unitsNum = 0
	groupSizeOnline = 0
end

function units.Initialize()
	IAHelper.RegisterCallback(IA_EVENT_GROUP_CHANGED, units.Register)
end

function units.Register()
	EM:UnregisterForEvent(EVENT_GROUP_EFFECT, EVENT_EFFECT_CHANGED)
	units.Refresh()

	groupSizeOnline = 0
	if units.IsPlayerGrouped() then
		for i = 1, GetGroupSize() do
			local tag = GetGroupUnitTagByIndex(i)
			if IsUnitPlayer(tag) then
				local unit = {
					tag = tag,
					id = 0,
					name = GetUnitName(tag),
					displayName = GetUnitDisplayName(tag),
					classId = GetUnitClassId(tag),
					isOnline = IsUnitOnline(tag),
					isPlayer = AreUnitsEqual(tag, 'player'),
				}
				if unit.isOnline then groupSizeOnline = groupSizeOnline + 1 end
				if unit.isPlayer then unitList['player'] = unit end
				unitList[tag] = unit
			end
		end
	else
		groupSizeOnline = 1
		unitList['player'] = {
			tag = 'player',
			id = 0,
			name = GetUnitName('player'),
			displayName = GetUnitDisplayName('player'),
			classId = GetUnitClassId('player'),
			isOnline = true,
			isPlayer = true,
		}
	end

	EM:RegisterForEvent(EVENT_GROUP_EFFECT,  EVENT_EFFECT_CHANGED, function(_, _, _, _, tag, _, _, _, _, _, _, _, _, _, id) units.AddUnit(id, tag) end)
	EM:AddFilterForEvent(EVENT_GROUP_EFFECT, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, units.IsPlayerGrouped() and 'group' or 'player')

	IAHelper.cm:FireCallbacks(IA_EVENT_UNITS_UPDATED)
end

function units.Unregister()
	IAHelper.UnregisterCallback(IA_EVENT_GROUP_CHANGED, units.Register)
	EM:UnregisterForEvent(EVENT_GROUP_EFFECT, EVENT_EFFECT_CHANGED)
	units.Refresh()
end