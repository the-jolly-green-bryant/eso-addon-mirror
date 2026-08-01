PillarOfNirn = PillarOfNirn or { }
local PillarOfNirn = PillarOfNirn

local EM		= GetEventManager()

PillarOfNirn.name		= "PillarOfNirn"
PillarOfNirn.version		= "1.1.0"
PillarOfNirn.varVersion 	= "1"

PillarOfNirn.IDs 		= {
	[97714] = true,
	--[97743] = true,
	--[97743] = true,
}

PillarOfNirn.active	= false

PillarOfNirn.downTime	= 0

PillarOfNirn.UPDATE_INTERVAL	= 100

PillarOfNirn.COLORS = {
	["UP"] = {
		1, 0.93, 0.43,
	},
	["DOWN"] = {
		1, 0.43, 0.43,
	},
	["WARNING"] = {
		1, 0.68, 0.43,
	}
}

-- use GetItemId(number Bag bagId, number slotIndex) find out the itemID
PillarOfNirn.TYPES = {
	[1] = "|H1:item:127523:364:50:0:0:0:0:0:0:0:0:0:0:0:1:128:0:1:0:10000:0|h|h",
}

PillarOfNirn.defaults	= {
	["offsetX"]	= 500,
	["offsetY"]	= 500,
	["timerSize"]	= 48,
	["passiveHide"]	= true,
	["COLORS"]	= PillarOfNirn.COLORS,
}

function PillarOfNirn.equipCheck()
	local np = 0
	_,_,_,np = GetItemLinkSetInfo(PillarOfNirn.TYPES[1], true)
	local total = 0
		total = np
	if (total >= 3) then 
		return true 
	end
	return false
end

function PillarOfNirn.gearUpdate()
	if PillarOfNirn.equipCheck() then
		PillarOfNirn.hideFrame()
		EM:RegisterForEvent(PillarOfNirn.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, PillarOfNirn.hideFrame)
		EM:RegisterForEvent(PillarOfNirn.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, PillarOfNirn.combatState)

		EM:RegisterForEvent(PillarOfNirn.name.."EEC", EVENT_EFFECT_CHANGED, PillarOfNirn.combatEvent)
		EM:AddFilterForEvent(PillarOfNirn.name.."EEC", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
	else
		PillarOfNirnFrame:SetHidden(true)
		EM:UnregisterForEvent(PillarOfNirn.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, PillarOfNirn.hideFrame)
		EM:UnregisterForEvent(PillarOfNirn.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, PillarOfNirn.combatState)

		EM:UnregisterForEvent(PillarOfNirn.name.."EEC", EVENT_COMBAT_EVENT, PillarOfNirn.combatEvent)
	end
end

function PillarOfNirn.combatState()
	if not PillarOfNirn.equipCheck() then return end
	PillarOfNirn.hideOutOfCombat()
end

function PillarOfNirn.setPos()
	local x, y = PillarOfNirn.savedVars.offsetX, PillarOfNirn.savedVars.offsetY
	PillarOfNirnFrame:ClearAnchors()
	PillarOfNirnFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function PillarOfNirn.savePos()
	PillarOfNirn.savedVars.offsetX = PillarOfNirnFrame:GetLeft()
	PillarOfNirn.savedVars.offsetY = PillarOfNirnFrame:GetTop()
end

function PillarOfNirn.hideOutOfCombat()
	if PillarOfNirn.savedVars.passiveHide then 
		PillarOfNirnFrame:SetHidden(not IsUnitInCombat("player"))
	end
end

function PillarOfNirn.hideFrame()
	PillarOfNirnFrame:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then PillarOfNirn.hideOutOfCombat() end
end

function PillarOfNirn.setFontSize(size)
	PillarOfNirnFrameTime:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size, 'shadow'))
	PillarOfNirnFrameCountdown:SetFont(string.format('%s|%d|%s', '$(CHAT_FONT)', size-12, 'shadow'))
end

function PillarOfNirn.countDown()
 	if (PillarOfNirn.downTime - GetGameTimeMilliseconds() > 0) then
		PillarOfNirnFrameTime:SetColor(unpack(PillarOfNirn.savedVars.COLORS.DOWN))
		PillarOfNirnFrameTime:SetText(string.format("DOWN", PillarOfNirn.time(PillarOfNirn.downTime)))
	else
		PillarOfNirnFrameTime:SetColor(unpack(PillarOfNirn.savedVars.COLORS.UP))
		PillarOfNirnFrameTime:SetText("PON!!")
		EM:UnregisterForUpdate(PillarOfNirn.name.."Update")
	end
end

function PillarOfNirn.countDown2()
	if (PillarOfNirn.downTime - GetGameTimeMilliseconds() > 0) then	
		PillarOfNirnFrameCountdown:SetText(string.format("%.0f", PillarOfNirn.time(PillarOfNirn.downTime)))
		if (PillarOfNirn.downTime - GetGameTimeMilliseconds() < 5000) then	
			PillarOfNirnFrameCountdown:SetColor(unpack(PillarOfNirn.savedVars.COLORS.WARNING))
		end
		if (PillarOfNirn.downTime - GetGameTimeMilliseconds() < 2000) then
			PillarOfNirnFrameCountdown:SetColor(unpack(PillarOfNirn.savedVars.COLORS.UP))
		end
	else
		PillarOfNirnFrameCountdown:SetColor(unpack(PillarOfNirn.savedVars.COLORS.UP))
		PillarOfNirnFrameCountdown:SetText("0")
		EM:UnregisterForUpdate(PillarOfNirn.name.."Update2")
	end
	
end

function PillarOfNirn.time(nd)
	return math.floor((nd - GetGameTimeMilliseconds())/1000+1)
end

function PillarOfNirn.combatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityID)
	--d("abilityName :"..abilityName)
	--d("abilityId :"..abilityID)

	if PillarOfNirn.IDs[abilityID] and PillarOfNirn.downTime - GetGameTimeMilliseconds() < 0 then
		PillarOfNirn.downTime = GetGameTimeMilliseconds() + 10000 -- 10 seconds after PillarOfNirn procs
		--start a new round of countdown
		EM:RegisterForUpdate(PillarOfNirn.name.."Update", PillarOfNirn.UPDATE_INTERVAL, PillarOfNirn.countDown)
		EM:RegisterForUpdate(PillarOfNirn.name.."Update2", PillarOfNirn.UPDATE_INTERVAL, PillarOfNirn.countDown2)

		PillarOfNirnFrameTime:SetColor(unpack(PillarOfNirn.savedVars.COLORS.DOWN))
		PillarOfNirnFrameCountdown:SetColor(unpack(PillarOfNirn.savedVars.COLORS.DOWN))
	end
end

function PillarOfNirn.Init(event, addon)
	if addon ~= PillarOfNirn.name then return end
	EM:UnregisterForEvent(PillarOfNirn.name.."Load", EVENT_ADD_ON_LOADED)

	PillarOfNirn.savedVars = ZO_SavedVars:NewAccountWide(PillarOfNirn.name.."SavedVars", PillarOfNirn.varVersion, nil, PillarOfNirn.defaults, nil, "$InstallationWide")
	
	PillarOfNirn.setFontSize(PillarOfNirn.savedVars.timerSize)
	PillarOfNirn.setPos()
	PillarOfNirnFrame:SetHidden(true)
	PillarOfNirnFrameTime:SetColor(unpack(PillarOfNirn.savedVars.COLORS.DOWN))
	PillarOfNirnFrameCountdown:SetColor(unpack(PillarOfNirn.savedVars.COLORS.DOWN))

	PillarOfNirn.setupMenu()
	PillarOfNirn.hideOutOfCombat()
	
	EM:RegisterForEvent(PillarOfNirn.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, PillarOfNirn.hideFrame)
	EM:RegisterForEvent(PillarOfNirn.name.."PassiveHide", EVENT_PLAYER_COMBAT_STATE, PillarOfNirn.combatState)

	EM:RegisterForEvent(PillarOfNirn.name.."EEC", EVENT_COMBAT_EVENT, PillarOfNirn.combatEvent)
	EM:AddFilterForEvent(PillarOfNirn.name.."EEC", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 97714)
	--EM:AddFilterForEvent(PillarOfNirn.name.."EEC", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 97743, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_GAINED_DURATION, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

	EM:RegisterForEvent(PillarOfNirn.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, PillarOfNirn.gearUpdate)
	EM:AddFilterForEvent(PillarOfNirn.name.."GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
	
	PillarOfNirn.equipCheck()
	PillarOfNirn.gearUpdate()

end

EM:RegisterForEvent(PillarOfNirn.name.."Load", EVENT_ADD_ON_LOADED, PillarOfNirn.Init)


