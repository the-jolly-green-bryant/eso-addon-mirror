OverloadTimer = OverloadTimer or { }
local OverloadTimer = OverloadTimer

local EM			= GetEventManager()

OverloadTimer.name		= "OverloadTimer"
OverloadTimer.version		= "1.2"
OverloadTimer.varVersion 	= "1"

OverloadTimer.locked		= true

OverloadTimer.ID 		= 87346

OverloadTimer.endTime		= 0
OverloadTimer.active		= false

OverloadTimer.UPDATE_INTERVAL	= 100

OverloadTimer.Color = {
	1, 0.7333, 0.2392,
}

OverloadTimer.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 48,
	["COLOR"]	= OverloadTimer.Color,
}

function OverloadTimer.setPos()
	local x, y = OverloadTimer.savedVars.offsetX, OverloadTimer.savedVars.offsetY
	OverloadTimerFrame:ClearAnchors()
	OverloadTimerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function OverloadTimer.savePos()
	OverloadTimer.savedVars.offsetX = OverloadTimerFrame:GetLeft()
	OverloadTimer.savedVars.offsetY = OverloadTimerFrame:GetTop()
end


function OverloadTimer.hideFrame()
	if OverloadTimer.active then
		OverloadTimerFrame:SetHidden(IsReticleHidden())
	end
end

function OverloadTimer.setFontSize(size)
	OverloadTimerFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function OverloadTimer.countDown()
	if OverloadTimer.time(OverloadTimer.endTime) > 0 then
		OverloadTimerFrameTime:SetText(string.format("%.1f", OverloadTimer.time(OverloadTimer.endTime)))
	else
		OverloadTimerFrameTime:SetText("0.0")
		OverloadTimerFrame:SetHidden(true)
		OverloadTimer.active = false
		EM:UnregisterForUpdate(OverloadTimer.name.."Update")
	end
end

function OverloadTimer.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function OverloadTimer.start(_, changeType, _, _, _, _, endTime)
	if changeType == EFFECT_RESULT_GAINED then
		OverloadTimer.endTime = endTime
		EM:RegisterForUpdate(OverloadTimer.name.."Update", OverloadTimer.UPDATE_INTERVAL, OverloadTimer.countDown)
		OverloadTimerFrame:SetHidden(false)
	 	OverloadTimer.active = true
	end
end

function OverloadTimer.Init(event, addon)
	if addon ~= OverloadTimer.name then return end
	EM:UnregisterForEvent(OverloadTimer.name.."Load", EVENT_ADD_ON_LOADED)

	OverloadTimer.savedVars = ZO_SavedVars:New(OverloadTimer.name.."SavedVars", OverloadTimer.varVersion, nil, OverloadTimer.defaults)
	
	OverloadTimer.setFontSize(OverloadTimer.savedVars.timerSize)
	OverloadTimer.setPos()

	OverloadTimerFrame:SetHidden(true)
	OverloadTimerFrameTime:SetColor(unpack(OverloadTimer.savedVars.COLOR))

	OverloadTimer.setupMenu()

	EM:RegisterForEvent(OverloadTimer.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, OverloadTimer.hideFrame)
	EM:RegisterForEvent(OverloadTimer.name, EVENT_EFFECT_CHANGED, OverloadTimer.start)
	EM:AddFilterForEvent(OverloadTimer.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, OverloadTimer.ID)
	EM:AddFilterForEvent(OverloadTimer.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

end

EM:RegisterForEvent(OverloadTimer.name.."Load", EVENT_ADD_ON_LOADED, OverloadTimer.Init)
