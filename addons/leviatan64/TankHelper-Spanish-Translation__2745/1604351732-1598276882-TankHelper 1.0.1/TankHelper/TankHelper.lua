--[[--------------------------------------------------------
	TankHelper
------------------------------------------------------------
	* Este AddOn muestra mensajes de alerta cuando necesitas bloquear, interrumpir o esquivar.
	*
	* Autor: @Bleifish
	* Traducción al español: @Leviatan64
	*
]]----------------------------------------------------------

TankHelper = {}
TankHelper.name = "TankHelper"
TankHelper.version = "1.0.1"

TankHelper.hideTime	= 0

--number eventCode, number activeCombatTipId
function TankHelper.OnActiveCombatTip(eventCode, activeCombatTipId)
	if (activeCombatTipId == 1) then
		--BLOCK
		TankHelper.showAlert("BLOQUEAR")
	elseif (activeCombatTipId == 3) then
		--INTERRUPT
		TankHelper.showAlert("INTERRUMPIR")
	elseif (activeCombatTipId == 4) then
		--DOGE
		TankHelper.showAlert("ESQUIVAR")
	end
end

function TankHelper.showAlert(message)
	EVENT_MANAGER:UnregisterForUpdate(TankHelper.name.."Update")
	TankHelperFrameAlert:SetText(message)
	EVENT_MANAGER:RegisterForUpdate(TankHelper.name.."Update", 100, TankHelper.hideAlert)
	TankHelper.hideTime = GetGameTimeMilliseconds()/100 + 12	-- 1.2 seconds after triggert
end

function TankHelper.hideAlert()
	if (TankHelper.hideTime - GetGameTimeMilliseconds()/100 <= 0) then
		EVENT_MANAGER:UnregisterForUpdate(TankHelper.name.."Update")
		TankHelperFrameAlert:SetText(" ");
	end
end

function TankHelper.setPos()
	TankHelperFrame:ClearAnchors()
	TankHelperFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 600, 500)
	d("TankHelper loaded")
end


function OnAddOnLoaded(eventCode, addOnName)
	if(addOnName == TankHelper.name) then
		TankHelper.setPos()
		EVENT_MANAGER:RegisterForEvent(TankHelper.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, TankHelper.OnActiveCombatTip)
	end
end

EVENT_MANAGER:RegisterForEvent(TankHelper.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
