ForceOverflow = ForceOverflow or { }
local fo = ForceOverflow
local EM = EventCallbackManager and EventCallbackManager:New("FOManager") or GetEventManager()

fo.name = "ForceOverflow"
fo.version = "1.0"
local cdTime = 0

local defaults = {
	["offsetX"] = 500,
	["offsetY"] = 500,
	["combatHide"] = true,
}

local gainType = {
        [EFFECT_RESULT_FULL_REFRESH] = true,
        [EFFECT_RESULT_GAINED] = true,
        [EFFECT_RESULT_TRANSFER] = true,
        [EFFECT_RESULT_UPDATED] = true,
}

local function countdown()
	cdTime = cdTime - 1
	if cdTime <= 0 then
		cdTime = 0
		EM:UnregisterForUpdate(fo.name.."Countdown")
	end
	fo.ui.timer:SetText(string.format("%d", cdTime))
end

local function effectHandler(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if gainType[changeType] then
		fo.ui.container:SetHidden(false)
		cdTime = endTime - beginTime
		fo.ui.timer:SetText(string.format("%d", cdTime))
		EM:RegisterForUpdate(fo.name.."Countdown", 1000, countdown)
	elseif changeType == EFFECT_RESULT_FADED then
		cdTime = 0
		EM:UnregisterForUpdate(fo.name.."Countdown")
		fo.ui.timer:SetText(string.format("%d", cdTime))
	end
end

local function combatState(e, inCombat)
	if not inCombat then
		fo.ui.container:SetHidden(true)
	end
end

local function setupHandlers()
	EM:RegisterForEvent(fo.name.."EffectEvent", EVENT_EFFECT_CHANGED, effectHandler)
	EM:AddFilterForEvent(fo.name.."EffectEvent", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, 147872, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	EM:RegisterForEvent(fo.name.."Combat", EVENT_PLAYER_COMBAT_STATE, combatState)
end

local function init(e, addonName)
	if addonName ~= fo.name then return end
	EM:UnregisterForEvent(fo.name.."Load", EVENT_ADD_ON_LOADED)
	fo.savedVars = ZO_SavedVars:NewAccountWide("ForceOverflowSavedVariables", 1, nil, defaults)

	fo.setupUI()
	fo.setupMenu()
	setupHandlers()
end

EM:RegisterForEvent(fo.name.."Load", EVENT_ADD_ON_LOADED, init)
