SSB = {}

SSB.name = "SiphoningStrikesBlocker"
SSB.Version = "2.0"

local flag = true
local permission = true

function SSB:Initialize()
	ZO_PreHook("ZO_ActionBar_CanUseActionSlots", function()
		flag = not flag -- Since ZO_ActionBar_CanUseActionSlots is called twice for each ability cast
		if flag then
			local slotNum = tonumber(debug.traceback():match('ACTION_BUTTON_(%d)'))
			-- if attempt to use SS or its morph
			if GetSlotBoundId(slotNum) == 33319 or GetSlotBoundId(slotNum) == 36935 or GetSlotBoundId(slotNum) == 36908 then
				-- if not using SS
				if permission then
					---start = GetGameTimeMilliseconds()
					return false
				else
					ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_RESPECRESULT10)
					return true
				end
			end
		end
	end)
end

function SSB.OnAddOnLoaded(event, addonName)
  if addonName == SSB.name then
	SSB:Initialize()
  end
end

function SSB.OnEffectChanged( _,  _,  _,  _,  _,  beginTime,  _,  _,  _,  _,  _,  _,  _,  _,  _,  abilityId,  _)
	-- when attempt to use SS or its morph
	if abilityId == 33319 or abilityId == 36935 or abilityId == 36908 then
		if beginTime == 0 then
			permission = true
		else
			permission = false
		end
	end
end

EVENT_MANAGER:RegisterForEvent(SSB.name, EVENT_ADD_ON_LOADED, SSB.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(SSB.name, EVENT_EFFECT_CHANGED, SSB.OnEffectChanged)
EVENT_MANAGER:AddFilterForEvent(SSB.name, EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)