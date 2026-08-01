local LSAddon = _G['LSAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- English
--------------------------------------------------------------------------------------------------------------------

L.AltLootMode					= "Alternate Loot Mode"
L.ToggleLootMode				= "Toggle Loot Mode"
L.ReloadState					= "Reload State"
L.AutoLootNConfig				= "Auto Loot Config"
L.AutoLootNDefault				= "Default Auto Loot"
L.AutoLootNDefaultTip			= "Set global default for 'Auto Loot' game setting. If enabled it will reset to the value selected in 'Reload State' any time you reload the UI or relog."
L.AutoLootNReloadTip			= "Choose the account-wide default for the 'Auto Loot' option when reloading the UI or relogging."
L.AutoLootSConfig				= "Auto Loot Stolen Config"
L.AutoLootSDefault				= "Default Auto Loot Stolen"
L.AutoLootSDefaultTip			= "Set global default for 'Auto Loot Stolen Items' game setting. If enabled it will reset to the value selected in 'Reload State' any time you reload the UI or relog."
L.AutoLootSReloadTip			= "Choose the account-wide default for the 'Auto Loot Stolen Items' option when reloading the UI or relogging."

------------------------------------------------------------------------------------------------------------------

function LSAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
