ZO_PreHook(ZO_UtilityWheel_Keyboard, "CycleLeft", function()
	if IsUnitInCombat('player') then
		--d("|cEE82EENMSW:|cE6E6FA Blocked the Quickslot wheel from cycling left.|r")
		ZO_Alert(ALERT, nil, "|cEE82EENMSW:|cE6E6FA Blocked the Quickslot wheel from cycling left.|r")
		return true
	else
		return false
	end
end)

ZO_PreHook(ZO_UtilityWheel_Keyboard, "CycleRight", function()
	if IsUnitInCombat('player') then
		--d("|cEE82EENMSW:|cE6E6FA Blocked the Quickslot wheel from cycling right.|r")
		ZO_Alert(ALERT, nil, "|cEE82EENMSW:|cE6E6FA Blocked the Quickslot wheel from cycling right.|r")
		return true
	else
		return false
	end
end)