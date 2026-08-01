ToggleStatus = ToggleStatus or { }
local ts = ToggleStatus
local EM = EventCallbackManager and EventCallbackManager:New("TSManager") or GetEventManager()
local WM = GetWindowManager()

ts.name = "ToggleStatus"
ts.version = "2.1"

local defaults = {
	["offsetX"] = 500,
	["offsetY"] = 500,
}

local gainType = {
        [EFFECT_RESULT_FULL_REFRESH] = true,
        [EFFECT_RESULT_GAINED] = true,
        [EFFECT_RESULT_TRANSFER] = true,
        [EFFECT_RESULT_UPDATED] = true,
}

-- 134160
-- 134166 -- stacks

local function getStacks(unit)
	for i = 1, GetNumBuffs(unit) do
		local _,_,_,_, stacks,_,_,_,_,_,abilityId = GetUnitBuffInfo(unit, i)
		if abilityId == 134166 then
			return stacks
		end
	end
	return 0
end

local function createGroupStackFrame(name)
	if not HodorReflexes then return end
	local M = HodorReflexes.modules.share
	local dpsRow = M.playersData[name].dpsRow
	local l = dpsRow:GetNamedChild("_Toggle")
	if l then
		M.playersData[name].toggle = l
	else
		l = WM:CreateControl(dpsRow:GetName().."_Toggle", dpsRow, CT_LABEL)
		l:SetFont(M.GetDamageNumFont())
		l:SetAnchor(TOPLEFT, dpsRow:GetChild(dpsRow:GetNumChildren() - 1), TOPRIGHT, 2, 0)
		l:SetHidden(false)
		M.playersData[name].toggle = l
	end
end

local function setGroupUnitStack(unitTag, stackCount)
	if not HodorReflexes or not HodorReflexes_Share_Damage then return end
	local dName = GetUnitDisplayName(unitTag)
	local groupSize = GetGroupSize()
	if stackCount == 0 then
		stackCount = ''
	else
		stackCount = "("..stackCount..")"
	end
	
	local M = HodorReflexes.modules.share
	if not M.playersData[dName] then return end
	if not M.playersData[dName].toggle then
		createGroupStackFrame(dName)
	end
	M.playersData[dName].toggle:SetText(stackCount)
end

local function groupStacks()
	if not IsUnitGrouped('player') then return end
	for i = 1, GetGroupSize() do
		local unit = string.format('group%d', i)
		local stacks = getStacks(unit)
		setGroupUnitStack(unit, stacks)
	end
end

local function stackHandler()
	ts.ui.stacks:SetText(getStacks('player'))
end

local function effectHandler(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if gainType[changeType] then
		ts.ui.texture:SetDesaturation(0)
		ts.ui.border:SetColor(0, 1, 0)
		ts.ui.stacks:SetColor(0, 1, 0)
		ts.ui.status:SetColor(0, 1, 0)
		ts.ui.status:SetText("ON")
		EM:RegisterForUpdate(ts.name.."StackHandler", 200, stackHandler)
		ts.ui.container:SetHidden(false)
	else
		ts.ui.texture:SetDesaturation(1)
		ts.ui.border:SetColor(1, 0, 0)
		ts.ui.stacks:SetColor(1, 0, 0)
		ts.ui.stacks:SetText("0")
		ts.ui.status:SetColor(1, 0, 0)
		ts.ui.status:SetText("OFF")
		EM:UnregisterForUpdate(ts.name.."StackHandler")
	end
end

local function combatState(e, inCombat)
	if not inCombat then
		ts.ui.container:SetHidden(true)
	end
end

local function setupHandlers()
	EM:RegisterForEvent(ts.name.."EffectEvent", EVENT_EFFECT_CHANGED, effectHandler)
	EM:AddFilterForEvent(ts.name.."EffectEvent", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 134160, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EM:RegisterForEvent(ts.name.."Combat", EVENT_PLAYER_COMBAT_STATE, combatState)
	if HodorReflexes then
		EM:RegisterForUpdate(ts.name.."GroupStacks", 300, groupStacks)
	end
end

local function init(e, addonName)
	if addonName ~= ts.name then return end
	EM:UnregisterForEvent(ts.name.."Load", EVENT_ADD_ON_LOADED)
	ts.savedVars = ZO_SavedVars:NewAccountWide("ToggleStatusSavedVariables", 1, nil, defaults)

	ts.ui.setupUI()
	ts.setupMenu()
	setupHandlers()
end

EM:RegisterForEvent(ts.name.."Load", EVENT_ADD_ON_LOADED, init)
