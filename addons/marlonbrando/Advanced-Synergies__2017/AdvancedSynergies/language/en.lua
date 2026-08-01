AdvSynAddon = WINDOW_MANAGER:CreateControl(nil, GuiRoot)
local AdvSyn = _G['AdvSynAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

--Toggle strings
L.SynergyNotification				= 'Synergy available'
L.SynergyNotificationTooltip			= 'setup mode - go to settings to change'
L.SettingFontsize				= 'Fontsize'
L.SettingMoveNotification			= 'Setup Mode'
L.SettingMoveNotificationTooltip		= 'when active, notification is always shown and movable. ignores "active on this char"'
L.SettingTransparency				= 'Opacity'
L.SettingTransparencyTooltip			= '0 = hidden, 100 = fully visible'
L.SettingActiveOnChar				= 'active on this char'
L.SettingActiveOnCharTooltip			= 'you can disable the notification, but still use debug to help improve this addon'
L.SettingDebug					= 'Debug'
L.SettingDebugTooltip				= 'save synergy details. For more information visit the addon website.'
L.SettingShowNames				= 'show synergy names'
L.SettingShowNamesTooltip			= 'this is a shady setting and does magic stuff!'

------------------------------------------------------------------------------------------------------------------

function AdvSyn:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
