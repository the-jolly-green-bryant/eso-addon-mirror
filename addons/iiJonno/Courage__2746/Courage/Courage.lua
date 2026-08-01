Courage = Courage or { }
local Courage = Courage

local EM		= GetEventManager()

Courage.name		= "Courage"
Courage.version		= "1.5"
Courage.varVersion 	= "1.5"

Courage.locked		= true

-- Olo - p.Olo - SPC
Courage.ID = { [109966] = true,}

Courage.endTime		= 0
Courage.active		= false

Courage.UPDATE_INTERVAL	= 100

Courage.Color = {
	1, 1, 1,
}

Courage.Alert_Colors = {
	{ 0, 0.9, 0, 0.9 },
	{ 0, 0, 0.9, 0.9 },
	{ 0.9, 0, 0, 0.9 },
}

Courage.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 1,
	["COLOR"]	= Courage.Color,
	["Alert_Colors"] = Courage.Alert_Colors,
}

function Courage.countDown()
	local t = Courage.time(Courage.endTime)
	if t > 0 then
		Courage.UI.Time:SetText(string.format("%.0f", t))
		if t > 12 then
			Courage.UI.BG:SetEdgeColor(unpack(Courage.savedVars.Alert_Colors[1]))
			Courage.UI.BG:SetEdgeTexture(nil, 1, 1, 0, nil)
		elseif t <= 12 and t > 5 then
			Courage.UI.BG:SetEdgeColor(unpack(Courage.savedVars.Alert_Colors[2]))
			Courage.UI.BG:SetEdgeTexture(nil, 1, 1, 2, nil)
		elseif t <= 5 then
			Courage.UI.BG:SetEdgeColor(unpack(Courage.savedVars.Alert_Colors[3]))
			Courage.UI.BG:SetEdgeTexture(nil, 1, 1, 4, nil)
		end
	else
		Courage.UI.BG:SetEdgeColor(0, .9, 0, .9)
		Courage.UI.BG:SetEdgeTexture(nil, 1, 1, 0, nil)
		Courage.UI.Time:SetText(string.format("%.0f", 0))
		Courage.UI.Frame:SetHidden(true)
		Courage.active = false
		EM:UnregisterForUpdate(Courage.name.."Update")
	end
end

function Courage.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000))
end

function Courage.start(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not Courage.ID[abilityId] or unitTag ~= "player" or (changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_UPDATED) then return end

    -- Calculate for how long it will last
    timer = endTime - beginTime

    Courage.endTime = GetGameTimeMilliseconds()/1000 + timer
    Courage.UI.Cooldown:StartCooldown(timer, timer, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)

    EM:RegisterForUpdate(Courage.name.."Update", Courage.UPDATE_INTERVAL, Courage.countDown)
    Courage.UI.Frame:SetHidden(false)
    Courage.active = true
end

function Courage.reset()
	Courage.endTime = 0
	Courage.UI.Cooldown:StartCooldown(0, 0, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
	EM:RegisterForUpdate(Courage.name.."Update", Courage.UPDATE_INTERVAL, Courage.countDown)
	Courage.UI.Frame:SetHidden(true)
	Courage.active = true
end

function Courage.Init(event, addon)
	if addon ~= Courage.name then return end
	EM:UnregisterForEvent(Courage.name.."Load", EVENT_ADD_ON_LOADED)

	Courage.savedVars = ZO_SavedVars:New(Courage.name.."SavedVars", Courage.varVersion, nil, Courage.defaults)
	if Courage.savedVars.timerSize > 2 then Courage.savedVars.timerSize = 1 end

	Courage.UI.Build()

	Courage.UI.Frame:SetHidden(true)
	Courage.UI.BG:SetEdgeColor(unpack(Courage.savedVars.Alert_Colors[1]))
	Courage.UI.BG:SetEdgeTexture(nil, 1, 1, 0, nil)
	Courage.UI.Time:SetColor(unpack(Courage.savedVars.COLOR))
	Courage.UI.Frame:SetScale(Courage.savedVars.timerSize)

	Courage.setupMenu()
	Courage.UI.Toggle()

	EM:RegisterForEvent(Courage.name, EVENT_EFFECT_CHANGED, Courage.start)
	EM:RegisterForEvent(Courage.name, EVENT_PLAYER_DEAD, Courage.reset)
end

EM:RegisterForEvent(Courage.name.."Load", EVENT_ADD_ON_LOADED, Courage.Init)
