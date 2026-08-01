OCCFP = {}

OCCFP.name = "OnlyCastCrystalFragmentsProc"
OCCFP.Version = "1.7"

function OCCFP:Initialize()
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
		local slotNum = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
		if GetSlotBoundId(slotNum) == 46324 then
			
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_RESPECRESULT10)
			ZO_ActionBar_OnActionButtonUp(slotNum)
			return true
		end
	end)
end

function OCCFP.OnAddOnLoaded(event, addonName)
  if addonName == OCCFP.name then
	OCCFP:Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(OCCFP.name, EVENT_ADD_ON_LOADED, OCCFP.OnAddOnLoaded)