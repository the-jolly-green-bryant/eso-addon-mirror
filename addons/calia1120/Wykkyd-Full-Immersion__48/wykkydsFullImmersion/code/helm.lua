local _addon = WYK_FullImmersion

_addon.toggleHelm = function()
	local before = GetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM )
	if before == "1" then _addon.showHelm()
	else _addon.hideHelm() end
end
_addon.hideHelm = function()
	SetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "1", 1 )
end
_addon.showHelm = function()
	SetSetting( SETTING_TYPE_IN_WORLD, IN_WORLD_UI_SETTING_HIDE_HELM, "0", 1 )
end

WYK_FullImmersion = _addon