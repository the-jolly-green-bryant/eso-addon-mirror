local LSAddon = _G['LSAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- German (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

L.BindingString					= "Alternativer Beute-Modus"
L.ToggleLootMode				= "Loot-Modus umschalten"
L.ReloadState					= "Zustand neu laden"
L.AutoLootNConfig				= "Auto Loot-Konfiguration"
L.AutoLootNDefault				= "Voreinstellung Auto Loot"
L.AutoLootNDefaultTip			= "Setze den globalen Voreinstellung für die Spieleinstellung 'Immer alles einsammeln'. Wenn diese Option aktiviert ist, wird sie jedes Mal, wenn Sie die Benutzeroberfläche neu laden oder erneut anmelden, auf den Wert zurückgesetzt, der unter 'Zustand neu laden' ausgewählt wurde."
L.AutoLootNReloadTip			= "Wählen Sie den kontoweiten Voreinstellung für die Option 'Immer alles einsammeln', wenn Sie die Benutzeroberfläche neu laden oder erneut anmelden."
L.AutoLootSConfig				= "Auto Loot Gestohlene Konfiguration"
L.AutoLootSDefault				= "Voreinstellung Auto Loot Gestohlen"
L.AutoLootSDefaultTip			= "Setze den globalen Voreinstellung für die Spieleinstellung 'Immer alles stehlen'. Wenn diese Option aktiviert ist, wird sie jedes Mal, wenn Sie die Benutzeroberfläche neu laden oder erneut anmelden, auf den Wert zurückgesetzt, der unter 'Zustand neu laden' ausgewählt wurde."
L.AutoLootSReloadTip			= "Wählen Sie den kontoweiten Standard für die Option 'Immer alles stehlen', wenn Sie die Benutzeroberfläche neu laden oder erneut anmelden."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(LSAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function LSAddon:GetLanguage() -- set new language return
		return L
	end
end
