PowerfulAssault = PowerfulAssault or { }
local PowerfulAssault = PowerfulAssault

local EM			= GetEventManager()

PowerfulAssault.name		= "PowerfulAssault"
PowerfulAssault.version		= "1.1"
PowerfulAssault.varVersion 	= "1"

PowerfulAssault.locked		= true

PowerfulAssault.ID 		= 61771

PowerfulAssault.endTime		= 0
PowerfulAssault.active		= false

PowerfulAssault.UPDATE_INTERVAL	= 100

PowerfulAssault.Color = {
	0.4666, 0.8588, 0.1019,
}

PowerfulAssault.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 48,
	["COLOR"]	= PowerfulAssault.Color,
}

function PowerfulAssault.setPos()
	local x, y = PowerfulAssault.savedVars.offsetX, PowerfulAssault.savedVars.offsetY
	PowerfulAssaultFrame:ClearAnchors()
	PowerfulAssaultFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function PowerfulAssault.savePos()
	PowerfulAssault.savedVars.offsetX = PowerfulAssaultFrame:GetLeft()
	PowerfulAssault.savedVars.offsetY = PowerfulAssaultFrame:GetTop()
end


function PowerfulAssault.hideFrame()
	if PowerfulAssault.active then
		PowerfulAssaultFrame:SetHidden(IsReticleHidden())
	end
end

function PowerfulAssault.setFontSize(size)
	PowerfulAssaultFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function PowerfulAssault.countDown()
	if PowerfulAssault.time(PowerfulAssault.endTime) > 0 then
		PowerfulAssaultFrameTime:SetText(string.format("%.1f", PowerfulAssault.time(PowerfulAssault.endTime)))
	else
		PowerfulAssaultFrameTime:SetText("0.0")
		PowerfulAssaultFrame:SetHidden(true)
		PowerfulAssault.active = false
		EM:UnregisterForUpdate(PowerfulAssault.name.."Update")
	end
end

function PowerfulAssault.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function PowerfulAssault.start(_, changeType, _, _, _, _, endTime)
	if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
		PowerfulAssault.endTime = endTime
		EM:RegisterForUpdate(PowerfulAssault.name.."Update", PowerfulAssault.UPDATE_INTERVAL, PowerfulAssault.countDown)
		PowerfulAssaultFrame:SetHidden(false)
	 	PowerfulAssault.active = true
	end
end

function PowerfulAssault.Init(event, addon)
	if addon ~= PowerfulAssault.name then return end
	EM:UnregisterForEvent(PowerfulAssault.name.."Load", EVENT_ADD_ON_LOADED)

	PowerfulAssault.savedVars = ZO_SavedVars:New(PowerfulAssault.name.."SavedVars", PowerfulAssault.varVersion, nil, PowerfulAssault.defaults)
	
	PowerfulAssault.setFontSize(PowerfulAssault.savedVars.timerSize)
	PowerfulAssault.setPos()

	PowerfulAssaultFrame:SetHidden(true)
	PowerfulAssaultFrameTime:SetColor(unpack(PowerfulAssault.savedVars.COLOR))

	PowerfulAssault.setupMenu()

	EM:RegisterForEvent(PowerfulAssault.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, PowerfulAssault.hideFrame)
	EM:RegisterForEvent(PowerfulAssault.name, EVENT_EFFECT_CHANGED, PowerfulAssault.start)
	EM:AddFilterForEvent(PowerfulAssault.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, PowerfulAssault.ID)
	EM:AddFilterForEvent(PowerfulAssault.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

end

EM:RegisterForEvent(PowerfulAssault.name.."Load", EVENT_ADD_ON_LOADED, PowerfulAssault.Init)
