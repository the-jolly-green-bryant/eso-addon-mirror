Acuity = Acuity or { }
local Acuity = Acuity

local EM		= GetEventManager()

Acuity.name		= "Acuity"
Acuity.version		= "2.4"
Acuity.varVersion 	= "1"

Acuity.ID 		= 99204
Acuity.endTime		= 0
Acuity.downTime		= 0
Acuity.active		= false

Acuity.UPDATE_INTERVAL	= 100

Acuity.COLORS = {
	["UP"] = {
		0, 1, 0,
	},
	["PROC"] = {
		0.26, 0.74, 0.96,
	},
	["DOWN"] = {
		1, 0, 0,
	}
}

Acuity.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 48,
	["passiveHide"]	= false,
	["COLORS"]	= Acuity.COLORS,
}

function Acuity.setPos()
	local x, y = Acuity.savedVars.offsetX, Acuity.savedVars.offsetY
	AcuityFrame:ClearAnchors()
	AcuityFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function Acuity.savePos()
	Acuity.savedVars.offsetX = AcuityFrame:GetLeft()
	Acuity.savedVars.offsetY = AcuityFrame:GetTop()
end

function Acuity.hideOutOfCombat()
	if not Acuity.equipCheck() then return end
	if Acuity.savedVars.passiveHide then 
		AcuityFrame:SetHidden(not IsUnitInCombat("player"))
	end
end

function Acuity.hideFrame()
	AcuityFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then Acuity.hideOutOfCombat() end
end

function Acuity.setFontSize(size)
	AcuityFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function Acuity.equipCheck()
	local g = 0
	_,_,_,g = GetItemLinkSetInfo("|H1:item:131105:370:50:54484:370:50:0:0:0:0:0:0:0:0:1:65:1:1:0:462:0|h|h", true)
	if g >= 3 then return true end
	return false
end

function Acuity.gearUpdate()
	if Acuity.equipCheck() then
		Acuity.hideFrame()
		EM:RegisterForEvent(Acuity.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, Acuity.hideFrame)
		EM:RegisterForEvent(Acuity.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, Acuity.hideOutOfCombat)
		EM:RegisterForEvent(Acuity.name, EVENT_EFFECT_CHANGED, Acuity.start)
		EM:AddFilterForEvent(Acuity.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, Acuity.ID)
		EM:AddFilterForEvent(Acuity.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	else
		AcuityFrame:SetHidden(true)
		EM:UnregisterForEvent(Acuity.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
		EM:UnregisterForEvent(Acuity.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE)
		EM:UnregisterForEvent(Acuity.name, EVENT_EFFECT_CHANGED)
	end
end

function Acuity.countDown()
	if Acuity.active then
		local time = Acuity.time(Acuity.endTime)
		if time <= 0 then
			Acuity.downTime = GetGameTimeMilliseconds()/1000 + 25	-- 25 seconds after proc ends
			AcuityFrameTime:SetColor(unpack(Acuity.savedVars.COLORS.DOWN))
			Acuity.active = false
			return
		else
			AcuityFrameTime:SetText(string.format("%.1f", time))
		end
	elseif not Acuity.active and (Acuity.downTime - GetGameTimeMilliseconds()/1000 > 0) then
		AcuityFrameTime:SetText(string.format("%.1f", Acuity.time(Acuity.downTime)))
	else
		AcuityFrameTime:SetColor(unpack(Acuity.savedVars.COLORS.UP))
		AcuityFrameTime:SetText("0.0")
		EM:UnregisterForUpdate(Acuity.name.."Update")
	end
end

function Acuity.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function Acuity.start(_, changeType, _, _, _, _, endTime)
	if changeType == EFFECT_RESULT_GAINED then
		EM:RegisterForUpdate(Acuity.name.."Update", Acuity.UPDATE_INTERVAL, Acuity.countDown)
		Acuity.endTime = endTime
		AcuityFrameTime:SetColor(unpack(Acuity.savedVars.COLORS.PROC))
		Acuity.active = true
	elseif changeType == EFFECT_RESULT_FADED then
		Acuity.downTime = GetGameTimeMilliseconds()/1000 + 25	-- 25 seconds after proc ends
		AcuityFrameTime:SetColor(unpack(Acuity.savedVars.COLORS.DOWN))
		Acuity.active = false
	end
end

function Acuity.Init(event, addon)
	if addon ~= Acuity.name then return end
	EM:UnregisterForEvent(Acuity.name.."Load", EVENT_ADD_ON_LOADED)

	Acuity.savedVars = ZO_SavedVars:New(Acuity.name.."SavedVars", Acuity.varVersion, nil, Acuity.defaults)
	
	Acuity.setFontSize(Acuity.savedVars.timerSize)
	Acuity.setPos()
	AcuityFrame:SetHidden(IsReticleHidden())
	AcuityFrameTime:SetColor(unpack(Acuity.savedVars.COLORS.UP))

	Acuity.setupMenu()
	Acuity.hideOutOfCombat()

	Acuity.gearUpdate()

	EM:RegisterForEvent(Acuity.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Acuity.gearUpdate)
	EM:AddFilterForEvent(Acuity.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

end

EM:RegisterForEvent(Acuity.name.."Load", EVENT_ADD_ON_LOADED, Acuity.Init)
