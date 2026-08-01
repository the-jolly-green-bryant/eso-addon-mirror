local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

--General strings
L.AddonTitle				= "Vampirs Wehe"
L.KeybindToggle				= "Umschaltunterdrückung"
L.KeybindInnocent			= "Schalten Sie 'Unschuldige angreifen' um."
L.KeybindCriminal			= "Kriminelle Fähigkeiten blockieren"
L.FeedToggleOn				= "Vampirfutter synergie wird nicht länger unterdrückt."
L.FeedToggleOff				= "Vampirfutter synergie wird unterdrückt."
L.BladeToggleOn				= "Klinge des Wehs synergie wird nicht länger unterdrückt."
L.BladeToggleOff			= "Klinge des Wehs synergie wird unterdrückt."
L.SwapToggleV				= "Vampirfütterung unterdrückt, Klinge des Wehs aktiviert."
L.SwapToggleB				= "Klinge des Wehs unterdrückt, Vampirfütterung aktiviert."
L.AddonToggleOn				= "Vampirs Wehe aktiviert."
L.AddonToggleOff			= "Vampirs Wehe behindert."
L.KeybindInnoOn				= "'Unschuldige verschonen' ist aktiviert"
L.KeybindInnoOff			= "'Unschuldige verschonen' ist deaktiviert"
L.BlockCrimeOn				= "Blockieren mit 'Criminal Action'-Fähigkeiten: AUF."
L.BlockCrimeOff				= "Blockieren mit 'Criminal Action'-Fertigkeiten: AUS."
L.AbilityBlocked			= "Vampire's Woe: Fähigkeit blockiert durch Kriminalitätseinstellung."

--Settings strings
L.EnableAddon				= "Aktivieren Sie Addon"
L.EnableAddonTip			= "Aktivieren/Deaktivieren der Addon-Funktion."
L.KeybindOption				= "Tastenbindungsfunktion"
L.KeybindOptionTip			= "Legen Sie das Verhalten fest, wenn Sie auf die Tastensperre drücken."
L.KeyOption1				= "Fütterung Umschalten"
L.KeyOption2				= "Umschaltklinge"
L.KeyOption3				= "Wechseln Zwischen"
L.KeyOption4				= "Aktivieren/Deaktivieren"
L.AllowAlly					= "Bissverbündeten Erlauben"
L.AllowAllyTip				= "Erlaubt es Ihnen, einen Verbündeten zu beißen und ihm Vampirismus zu geben, selbst wenn die Fütterungssynergie unterdrückt wird."
L.AutoInnocent				= "Automatischer unschuldiger Wechsel"
L.AutoInnocentTip			= "Automatisches Deaktivieren von 'Angriff auf Unschuldige verhindern', wenn die Synergie Vampirfutter oder Klinge des Leids angezeigt wird."
L.ShowDebug					= "Debuggen Anzeigen"
L.ShowDebugTip				= "Afficher un avis de discussion lorsque l'alimentation des vampires ou une lame de malheur est activée/désactivée à l'aide du raccourci clavier...."
L.Status					= "Unterdrückungsstatus"
L.FeedSetting				= "Vampirfütterung unterdrücken"
L.FeedSettingTip			= "Blockiere die Synergie der Vampirfütterung durch Auslösen."
L.AutoStage					= "Maximale Stufe aktivieren"
L.AutoStageTip				= "Wenn diese Option aktiviert ist, wird die Vampirfütterung aktiviert, auch wenn die obige Einstellung aktiviert ist, sofern Ihr aktuelles Stadium niedriger ist als das unten eingestellte maximale Stadium."
L.MaxStage					= "Maximale Stufe einstellen"
L.MaxStageTip				= "Die Vampir-Feed-Synergie wird unterdrückt, wenn Ihr aktuelles Stadium größer oder gleich diesem Grenzwert ist."
L.BladeSetting				= "Unterdrücke Wehe"
L.BladeSettingTip			= "Blockieren Sie die Klinge der Weh Synergie von der Auslösung."
L.CriminalSetting			= "Block Kriminelle Handlungsfähigkeiten."
L.CriminalSettingTip		= "Verhindert, dass Fähigkeiten als 'Kriminelle Handlung' gekennzeichnet sind, von der Besetzung."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(VWoe:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function VWoe:GetLanguage() -- set new language return
		return L
	end
end
