--[[
Quick Cast Toggle
by xen32
--]]

-- Bind
ZO_CreateStringId("SI_BINDING_NAME_QUICKCASTTOGGLE", "Toggle Quick Cast")
ZO_CreateStringId("SI_BINDING_NAME_QUICKCASTTOGGLETEMP", "Toggle Quick Cast for 15s")

-- Function
function QuickCastSettingToggle()
    local qcsetting = GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_QUICK_CAST_GROUND_ABILITIES)

    if qcsetting == "1" then
	qcsetting = "2"
	qctext = "AUTO"
	else 
	qcsetting = "1"
	qctext = "ON"
	end

    SetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_QUICK_CAST_GROUND_ABILITIES, qcsetting, 1)
    d("Quick cast set to " .. qctext)
end


function QuickCastSettingToggleTemp()

	QuickCastSettingToggle()
	d("Switching back in 15 seconds")
	zo_callLater(function () QuickCastSettingToggle() end, 15000)
end