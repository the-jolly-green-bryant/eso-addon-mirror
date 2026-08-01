Siroria = Siroria or { }
local Siroria = Siroria

local EM		= GetEventManager()

Siroria.name		= "Siroria"
Siroria.version		= "1.7.1"
Siroria.varVersion 	= "1"

Siroria.IDs 		= {
	[109081] = true,	-- Perfect
	[107095] = true,	-- Non-Perfect
}
Siroria.boonIDs		= {
	[110142] = true,	-- Perfect
	[110118] = true,	-- Non-Perfect
}
Siroria.downTime	= 0

Siroria.UPDATE_INTERVAL	= 100

Siroria.COLORS = {
	["UP"] = {
		0, 1, 0,
	},
	["DOWN"] = {
		1, 0, 0,
	},
	["STACK"] = {
		1, 0.66, 0,
	},
	["STACKTIMER"] = {
		0, 1, 1,
	},
}

Siroria.TYPES = {
	[1] = "|H1:item:138329:364:50:45884:370:50:0:0:0:0:0:0:0:0:1:73:0:1:0:0:0|h|h",	-- perfect
	[2] = "|H1:item:137161:362:50:0:0:0:0:0:0:0:0:0:0:0:1:73:0:1:0:300:0|h|h",	-- non perfect
}

Siroria.defaults		= {
	["offsetX"]		= 500,
	["offsetY"]		= 500,
	["timerSize"]		= 48,
	["passiveHide"]		= false,
	["COLORS"]		= Siroria.COLORS,
	["showStacks"]		= true,
	["showStackTimer"]	= true,
	["stayGoNoti"]		= false,
}

function Siroria.setPos()
	local x, y = Siroria.savedVars.offsetX, Siroria.savedVars.offsetY
	SiroriaFrame:ClearAnchors()
	SiroriaFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function Siroria.savePos()
	Siroria.savedVars.offsetX = SiroriaFrame:GetLeft()
	Siroria.savedVars.offsetY = SiroriaFrame:GetTop()
end

function Siroria.equipCheck()
	local np, p = 0
	_,_,_,_,_,_,p = GetItemLinkSetInfo(Siroria.TYPES[1], true)
	_,_,_,np = GetItemLinkSetInfo(Siroria.TYPES[2], true)
	local total = 0
		total = np + p
	if (total >=3) then return true end
	return false
end

function Siroria.gearUpdate()
	if Siroria.equipCheck() then
		Siroria.hideFrame()
		EM:RegisterForEvent(Siroria.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, Siroria.hideFrame)
		EM:RegisterForEvent(Siroria.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, Siroria.combatState)

		EM:RegisterForEvent(Siroria.name.."ECE", EVENT_COMBAT_EVENT, Siroria.combatEvent)
		EM:AddFilterForEvent(Siroria.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED)
		EM:AddFilterForEvent(Siroria.name.."ECE", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	else
		SiroriaFrame:SetHidden(true)
		EM:UnregisterForEvent(Siroria.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, Siroria.hideFrame)
		EM:UnregisterForEvent(Siroria.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, Siroria.combatState)

		EM:UnregisterForEvent(Siroria.name.."ECE", EVENT_COMBAT_EVENT, Siroria.combatEvent)
	end
end

function Siroria.combatState()
	if not Siroria.equipCheck() then return end
	Siroria.hideOutOfCombat()
	Siroria.stackHandler()
end

function Siroria.hideOutOfCombat()
	if Siroria.savedVars.passiveHide then 
		SiroriaFrame:SetHidden(not IsUnitInCombat("player"))
	end
end

function Siroria.stackHandler()
	if IsUnitInCombat("player") and (Siroria.savedVars.showStacks or Siroria.savedVars.showStackTimer) then
		EM:RegisterForUpdate(Siroria.name.."GetStacks", Siroria.UPDATE_INTERVAL, Siroria.getStacks)
	else
		EM:UnregisterForUpdate(Siroria.name.."GetStacks")
		SiroriaFrameStacks:SetText("0")
		SiroriaFrameStackTime:SetText("0.0")
	end
end

function Siroria.hideFrame()
	SiroriaFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then Siroria.hideOutOfCombat() end
end

function Siroria.setFontSize(size)
	SiroriaFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'soft-shadow-thick'))
end

function Siroria.countDown()
 	if not Siroria.active and (Siroria.downTime - GetGameTimeMilliseconds()/1000 > 0) then
		SiroriaFrameTime:SetText(string.format("%.1f", Siroria.time(Siroria.downTime)))
	else
		SiroriaFrameTime:SetColor(unpack(Siroria.savedVars.COLORS.UP))
		SiroriaFrameTime:SetText("0.0")
		EM:UnregisterForUpdate(Siroria.name.."Update")
	end
end

function Siroria.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
end

function Siroria.combatEvent(_, _, _, _, _, _, sourceName, _, _, _, _, _, _, _, _, _, abilityID)
	if Siroria.IDs[abilityID] then
		EM:RegisterForUpdate(Siroria.name.."Update", Siroria.UPDATE_INTERVAL, Siroria.countDown)
		Siroria.downTime = GetGameTimeMilliseconds()/1000 + 10	-- 10 seconds after siroria procs
		SiroriaFrameTime:SetColor(unpack(Siroria.savedVars.COLORS.DOWN))
		Siroria.active = false
	end
end

function Siroria.getStacks()
	local numBuffs = GetNumBuffs("player")
	for i = 1, numBuffs+1 do
		local _,_,timeEnding,_,stackCount,_,_,_,_,_,abilityID = GetUnitBuffInfo("player", i)
		if Siroria.boonIDs[abilityID] then
			SiroriaFrameStacks:SetText(stackCount)
			if Siroria.savedVars.stayGoNoti then
				if ( Siroria.time(timeEnding) > Siroria.time(Siroria.downTime) ) then
					SiroriaFrameStackTime:SetText("Move")
				else
					SiroriaFrameStackTime:SetText("Stay")
				end
			else
				SiroriaFrameStackTime:SetText(string.format("%.1f", Siroria.time(timeEnding)))
			end
			break
		elseif i > numBuffs then
			SiroriaFrameStacks:SetText("0")
			SiroriaFrameStackTime:SetText("0.0")
			break
		end
	end
end

function Siroria.setColors()
	SiroriaFrameTime:SetColor(unpack(Siroria.savedVars.COLORS.UP))
	SiroriaFrameStacks:SetColor(unpack(Siroria.savedVars.COLORS.STACK))
	SiroriaFrameStackTime:SetColor(unpack(Siroria.savedVars.COLORS.STACKTIMER))
end

function Siroria.Init(event, addon)
	if addon ~= Siroria.name then return end
	EM:UnregisterForEvent(Siroria.name.."Load", EVENT_ADD_ON_LOADED)

	Siroria.savedVars = ZO_SavedVars:New(Siroria.name.."SavedVars", Siroria.varVersion, nil, Siroria.defaults)
	
	Siroria.setFontSize(Siroria.savedVars.timerSize)
	Siroria.setPos()
	SiroriaFrame:SetHidden(IsReticleHidden())
	SiroriaFrameStacks:SetHidden(not Siroria.savedVars.showStacks)
	SiroriaFrameStackTime:SetHidden(not Siroria.savedVars.showStackTimer)
	Siroria.setColors()

	Siroria.setupMenu()
	Siroria.hideOutOfCombat()

	Siroria.gearUpdate()

	EM:RegisterForEvent(Siroria.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Siroria.gearUpdate)
	EM:AddFilterForEvent(Siroria.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
end

EM:RegisterForEvent(Siroria.name.."Load", EVENT_ADD_ON_LOADED, Siroria.Init)
