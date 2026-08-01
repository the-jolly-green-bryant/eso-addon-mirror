Trap = Trap or { }
local Trap = Trap

local EM		= GetEventManager()

Trap.name		= "Trap"
Trap.version		= "2.3"
Trap.varVersion 	= "2"

Trap.locked		= true

Trap.ID 		= 40382

Trap.endTime		= 0
Trap.active		= false

Trap.UPDATE_INTERVAL	= 100

Trap.Color = {
	1, 1, 1,
}

Trap.Alert_Colors = {
	{ 0, 0.9, 0, 0.9 },
	{ 0, 0, 0.9, 0.9 },
	{ 0.9, 0, 0, 0.9 },
}

Trap.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 1,
	["COLOR"]	= Trap.Color,
	["Alert_Colors"] = Trap.Alert_Colors,
}

function Trap.countDown()
	local t = Trap.time(Trap.endTime)
	if t > 0 then
		Trap.UI.Time:SetText(string.format("%.1f", t))
		if t > 12 then
			Trap.UI.BG:SetEdgeColor(unpack(Trap.savedVars.Alert_Colors[1]))
			Trap.UI.BG:SetEdgeTexture(nil, 1, 1, 0, nil)
		elseif t <= 12 and t > 5 then
			Trap.UI.BG:SetEdgeColor(unpack(Trap.savedVars.Alert_Colors[2]))
			Trap.UI.BG:SetEdgeTexture(nil, 1, 1, 2, nil)
		elseif t <= 5 then
			Trap.UI.BG:SetEdgeColor(unpack(Trap.savedVars.Alert_Colors[3]))
			Trap.UI.BG:SetEdgeTexture(nil, 1, 1, 4, nil)
		end
	else
		Trap.UI.BG:SetEdgeColor(0, .9, 0, .9)
		Trap.UI.BG:SetEdgeTexture(nil, 1, 1, 0, nil)
		Trap.UI.Time:SetText(string.format("%.1f", 0.0))
		Trap.UI.Frame:SetHidden(true)
		Trap.active = false
		EM:UnregisterForUpdate(Trap.name.."Update")
	end
end

function Trap.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function Trap.start()
	Trap.endTime = GetGameTimeMilliseconds()/1000 + 20
	Trap.UI.Cooldown:StartCooldown(19000, 19000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false) --20?
	EM:RegisterForUpdate(Trap.name.."Update", Trap.UPDATE_INTERVAL, Trap.countDown)
	Trap.UI.Frame:SetHidden(false)
	Trap.active = true
	
end

function Trap.Init(event, addon)
	if addon ~= Trap.name then return end
	EM:UnregisterForEvent(Trap.name.."Load", EVENT_ADD_ON_LOADED)

	Trap.savedVars = ZO_SavedVars:New(Trap.name.."SavedVars", Trap.varVersion, nil, Trap.defaults)
	if Trap.savedVars.timerSize > 2 then Trap.savedVars.timerSize = 1 end
	
	Trap.UI.Build()

	Trap.UI.Frame:SetHidden(true)
	Trap.UI.BG:SetEdgeColor(unpack(Trap.savedVars.Alert_Colors[1]))
	Trap.UI.BG:SetEdgeTexture(nil, 1, 1, 0, nil)
	Trap.UI.Time:SetColor(unpack(Trap.savedVars.COLOR))
	Trap.UI.Frame:SetScale(Trap.savedVars.timerSize)

	Trap.setupMenu()
	Trap.UI.Toggle()

	EM:RegisterForEvent(Trap.name, EVENT_COMBAT_EVENT, Trap.start)
	EM:AddFilterForEvent(Trap.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, Trap.ID)
	EM:AddFilterForEvent(Trap.name, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

end

EM:RegisterForEvent(Trap.name.."Load", EVENT_ADD_ON_LOADED, Trap.Init)
