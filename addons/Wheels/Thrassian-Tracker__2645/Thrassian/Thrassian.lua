Thrassian = Thrassian or { }
local t = Thrassian
local EM = GetEventManager()
local scID = 136123
local WM = GetWindowManager()

t.name = "Thrassian"
t.version = "3.0"

local defaults = {
	["offsetX"] = 500,
	["offsetY"] = 300,
	["groupStacks"] = false,
}

local groupStackFrames = { }

function t.checkEquipped()
	local e = 0
	local _
	_,_,_,e = GetItemLinkSetInfo("|H1:item:164291:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:10000:0|h|h", true)
	return e == 1
end

function t.gearUpdate()
	if t.checkEquipped() then
		t.UI.setDisplay(true)
	else
		t.UI.setDisplay(false, true)
	end
	t.UI.count:SetText(tostring(t.getStacks('player')))
end

function t.getStacks(unit)
	local numBuffs = GetNumBuffs(unit)
	for i = 1, numBuffs+1 do
		local _,_,_,_,stackCount,_,_,_,_,_,abilityID = GetUnitBuffInfo(unit, i)
		if abilityID == scID then
			return stackCount
		elseif i > numBuffs then
			return 0
		end
	end
end

local function createGroupStackFrame(name) -- Thanks Andy for exposing this stuff
	if not HodorReflexes then return end
	local M = HodorReflexes.modules.share
	local dpsRow = M.playersData[name].dpsRow
	local l = dpsRow:GetNamedChild("_Thrass")
	if l then
		M.playersData[name].thrass = l
	else
		l = WM:CreateControl(dpsRow:GetName().."_Thrass", dpsRow, CT_LABEL)
		l:SetFont(M.GetDamageNumFont())
		l:SetAnchor(TOPLEFT, dpsRow:GetChild(dpsRow:GetNumChildren() - 1), TOPRIGHT, 2, 0)
		l:SetHidden(false)
		M.playersData[name].thrass = l
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
	if not M.playersData[dName].thrass then
		createGroupStackFrame(dName)
	end
	M.playersData[dName].thrass:SetText(stackCount)
	
end

function t.handleStackChange(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
	if string.find(unitTag, "group") and t.savedVars.groupStacks then
		if changeType == EFFECT_RESULT_FADED then
			setGroupUnitStack(unitTag, t.getStacks(unitTag))
			return
		end
		setGroupUnitStack(unitTag, stackCount)
	elseif unitTag == 'player' then 
		if changeType == EFFECT_RESULT_FADED then
			t.UI.count:SetText(tostring(t.getStacks('player')))
			return
		end
		t.UI.count:SetText(stackCount)
	end
end

local function buildFrames()
	for i = 1, GetGroupSize() do
		local c = HodorReflexes_Share_Damage:GetNamedChild("Row"..i)
		if not c then return end
		d("building "..i)
		createGroupStackFrame(i)
	end
end

local function activated()
	t.UI.count:SetText(tostring(t.getStacks('player')))
end

local function combatState(e, inCombat)
	if not HodorReflexes then return end
	for i = 1, GetGroupSize() do
		setGroupUnitStack('group'..i, t.getStacks('group'..i))
	end
end

function t.init(e, addon)
	if addon ~= t.name then return end
	EM:UnregisterForEvent(t.name.."onLoad", EVENT_ADD_ON_LOADED)
	t.savedVars = ZO_SavedVars:NewCharacterIdSettings("ThrassianSavedVars", 1, "Thrassian", defaults, GetWorldName())
	t.UI.build()
	t.buildMenu()
	t.gearUpdate()
	EM:RegisterForEvent(t.name.."effectChanged", EVENT_EFFECT_CHANGED, t.handleStackChange)
	EM:AddFilterForEvent(t.name.."effectChanged", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, scID)
	EM:RegisterForEvent(t.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, t.gearUpdate)
	EM:AddFilterForEvent(t.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	EM:RegisterForEvent(t.name.."playerActivate", EVENT_PLAYER_ACTIVATED, activated)
	EM:RegisterForEvent(t.name.."combatState", EVENT_PLAYER_COMBAT_STATE, combatState)
end

EM:RegisterForEvent(t.name.."onLoad", EVENT_ADD_ON_LOADED, t.init)

