Warhorn = Warhorn or {}		-- NameSpace
local Warhorn = Warhorn

local EM = GetEventManager()

Warhorn.name		= "Warhorn-Tracker"
Warhorn.version		= "2.0.3"
Warhorn.varVersion	= 1

Warhorn.UPDATE_INTERVAL = 500
Warhorn.finishTime = 0

Warhorn.isHorn = {		-- Aggressive Horn
	[40224] = true,		-- I
	[46532] = true,		-- II
	[46535] = true,		-- III
	[46538] = true		-- IV
}

function Warhorn:Initialize()
	Warhorn.savedVariables = ZO_SavedVars:New("WTSavedVariables", Warhorn.varVersion, nil, {})
	Warhorn.RestorePosition()
	Warhorn.buildMenu()

	EM:RegisterForEvent(Warhorn.name.."Effect", EVENT_EFFECT_CHANGED, Warhorn.effectChange)
	EM:AddFilterForEvent(Warhorn.name.."Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_GROUP)
	EM:RegisterForEvent(Warhorn.name.."RetUpdate", EVENT_RETICLE_HIDDEN_UPDATE, Warhorn.retUpdate)
end

function Warhorn.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function Warhorn:effectChange(change, slot, auraName, unitTag, start, finish, e, icon, buffType, effectType, abilityType, statusType, unitName, unitId, abilityId, sourceType)
	if change == EFFECT_RESULT_GAINED and Warhorn.isHorn[abilityId] then
		WarhornTrackerWindow:SetHidden(false)
		WarhornTrackerWindowTitle:SetText("|t40:40:" .. icon .. "|t " .. zo_strformat(SI_ABILITY_NAME, GetAbilityName(abilityId)))
		Warhorn.finishTime = finish
		EM:RegisterForUpdate(Warhorn.name.."Update", Warhorn.UPDATE_INTERVAL, Warhorn.OnUpdate)
	end
		
	--In the event of double war horn		
	if change == EFFECT_RESULT_UPDATED and Warhorn.isHorn[abilityId] then
		Warhorn.finishTime = finish
	end
end

function Warhorn.OnUpdate()
	if Warhorn.time(Warhorn.finishTime) >= 0 then
		WarhornTrackerWindowTimer:SetText(string.format("%d", Warhorn.time(Warhorn.finishTime)))
	else
		WarhornTrackerWindow:SetHidden(true)
		Warhorn.finishTime = 0
		EM:UnregisterForUpdate(Warhorn.name.."Update")
	end
end

function Warhorn.retUpdate(event, hidden)
	if Warhorn.finishTime > 0 then WarhornTrackerWindow:SetHidden(hidden) end
end

function Warhorn.OnMoveStop()
	Warhorn.savedVariables.left = WarhornTrackerWindow:GetLeft()
	Warhorn.savedVariables.top = WarhornTrackerWindow:GetTop()
end

function Warhorn:RestorePosition()
	local left = Warhorn.savedVariables.left
	local top = Warhorn.savedVariables.top
 
	WarhornTrackerWindow:ClearAnchors()
	WarhornTrackerWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Warhorn.OnAddOnLoaded(event, addonName)
	if addonName ~= Warhorn.name then return end

	EM:UnregisterForEvent(Warhorn.name, EVENT_ADD_ON_LOADED)
	Warhorn:Initialize()
end

EM:RegisterForEvent(Warhorn.name, EVENT_ADD_ON_LOADED, Warhorn.OnAddOnLoaded)
