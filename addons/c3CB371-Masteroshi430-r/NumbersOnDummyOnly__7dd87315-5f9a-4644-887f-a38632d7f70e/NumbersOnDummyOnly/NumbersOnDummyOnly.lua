NumbersOnDummyOnly = {}
NumbersOnDummyOnly.name = "NumbersOnDummyOnly"

function NumbersOnDummyOnly.go()
     local settingStatus = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED)
	 
	 if NumbersOnDummyOnly.inHouse and settingStatus == "0" then -- player is in house
		 SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, "1")
		 NumbersOnDummyOnly.numbersEnabled = true
	 elseif settingStatus == "1" then
		 SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_SCROLLING_COMBAT_TEXT_ENABLED, "0")
		 NumbersOnDummyOnly.numbersEnabled = false
	 end
end

function NumbersOnDummyOnly.inHouseState()
	
	if GetCurrentZoneHouseId() > 0 then
	    NumbersOnDummyOnly.inHouse = true
		EVENT_MANAGER:RegisterForEvent(NumbersOnDummyOnly.name, EVENT_COMBAT_EVENT, function(_,_, _, _, _, _, _, _, _, CombatUnitType) if CombatUnitType == COMBAT_UNIT_TYPE_TARGET_DUMMY and not NumbersOnDummyOnly.numbersEnabled then NumbersOnDummyOnly.go() end  end)
	else
	     NumbersOnDummyOnly.inHouse = false
		 NumbersOnDummyOnly.go()
		 EVENT_MANAGER:UnregisterForEvent(NumbersOnDummyOnly.name, EVENT_COMBAT_EVENT)
	end
end


EVENT_MANAGER:RegisterForEvent(NumbersOnDummyOnly.name, EVENT_PLAYER_ACTIVATED, function() zo_callLater(NumbersOnDummyOnly.inHouseState, 10000) end)




