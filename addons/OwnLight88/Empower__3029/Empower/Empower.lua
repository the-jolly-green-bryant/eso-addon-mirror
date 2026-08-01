Empower = Empower or { }
local Empower = Empower

local EM			= GetEventManager()

Empower.name		= "Empower"
Empower.version		= "1.2"
Empower.varVersion 	= "1"

Empower.locked		= true

Empower.ID 		= 61737

Empower.endTime		= 0
Empower.active		= false

Empower.UPDATE_INTERVAL	= 100

Empower.Color = {
	0.54509804, 0.30196078, 1,
}

Empower.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 48,
	["passiveHide"]	= true,
	["COLOR"]	= Empower.Color,
}

function Empower.combatState()
	Empower.hideOutOfCombat()
end

function Empower.setPos()
	local x, y = Empower.savedVars.offsetX, Empower.savedVars.offsetY
	EmpowerFrame:ClearAnchors()
	EmpowerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function Empower.savePos()
	Empower.savedVars.offsetX = EmpowerFrame:GetLeft()
	Empower.savedVars.offsetY = EmpowerFrame:GetTop()
end

function Empower.hideOutOfCombat()
	if Empower.savedVars.passiveHide then
		EmpowerFrame:SetHidden(not IsUnitInCombat("player"))
	end
end

function Empower.hideFrame()
	EmpowerFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then Empower.hideOutOfCombat() end
end

function Empower.setFontSize(size)
	EmpowerFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function Empower.countDown()
	if Empower.time(Empower.endTime) > 0 then
		EmpowerFrameTime:SetText(string.format("%.1f", Empower.time(Empower.endTime)))
	else
		EmpowerFrameTime:SetText("0.0")
		EmpowerFrame:SetHidden(true)
		Empower.active = false
		EM:UnregisterForUpdate(Empower.name.."Update")
	end
end

function Empower.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function Empower.start(_, changeType, _, _, _, _, endTime)
	if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
		Empower.endTime = endTime
		EM:RegisterForUpdate(Empower.name.."Update", Empower.UPDATE_INTERVAL, Empower.countDown)
		EmpowerFrame:SetHidden(false)
	 	Empower.active = true
	end
end

function Empower.Init(event, addon)
	if addon ~= Empower.name then return end
	EM:UnregisterForEvent(Empower.name.."Load", EVENT_ADD_ON_LOADED)

	Empower.savedVars = ZO_SavedVars:New(Empower.name.."SavedVars", Empower.varVersion, nil, Empower.defaults)

	Empower.setFontSize(Empower.savedVars.timerSize)
	Empower.setPos()

	EmpowerFrame:SetHidden(true)
	EmpowerFrameTime:SetColor(unpack(Empower.savedVars.COLOR))

	Empower.setupMenu()

	EM:RegisterForEvent(Empower.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, Empower.hideFrame)
	EM:RegisterForEvent(Empower.name.."PassiveHide", EVENT_EFFECT_CHANGED, Empower.combatState)
	EM:RegisterForEvent(Empower.name, EVENT_EFFECT_CHANGED, Empower.start)
	EM:AddFilterForEvent(Empower.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, Empower.ID)
	EM:AddFilterForEvent(Empower.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

end

EM:RegisterForEvent(Empower.name.."Load", EVENT_ADD_ON_LOADED, Empower.Init)