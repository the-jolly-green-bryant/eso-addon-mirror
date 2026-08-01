local AdvSyn = _G['AdvSynAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
------------------------------------------------------------------------------------------------------------------

--Toggle strings
L.SynergyNotification				= 'Synergie verfügbar'
L.SynergyNotificationTooltip			= 'Einrichtungsmodus - änderbar in den Einstellungen'
L.SettingFontsize				= 'Schriftgröße'
L.SettingMoveNotification			= 'Einrichtungsmodus'
L.SettingMoveNotificationTooltip		= 'wenn aktiv, wird der Hinweis immer gezeigt und ist verschiebbar. Ignoriert "Aktiv auf diesem Charakter"'
L.SettingTransparency				= 'Transparenz'
L.SettingTransparencyTooltip			= '0 = versteckt, 100 = voll sichtbar'
L.SettingActiveOnChar				= 'Aktiv auf diesem Charakter'
L.SettingActiveOnCharTooltip			= 'Du kannst die Benachrichtigung deaktivieren, und trotzdem Debug-Infos speichern um das Addon zu verbessern.'
L.SettingDebug					= 'Debug'
L.SettingDebugTooltip				= 'Synergie-Infos speichern. Geh auf die Addon-Webseite für mehr Info.'
L.SettingShowNames				= 'Synergienamen anzeigen'
L.SettingShowNamesTooltip			= 'Diese Einstellung ist verdächtig und macht magische Dinge'


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(AdvSyn:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function AdvSyn:GetLanguage() -- set new language return
		return L
	end
end
