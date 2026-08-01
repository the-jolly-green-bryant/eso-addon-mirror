local LSAddon = _G['LSAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Italian (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

L.BindingString					= "Modalità di bottino alternativo"
L.ToggleLootMode				= "Passa alla modalità bottino"
L.ReloadState					= "Valore dopo ricarica"
L.AutoLootNConfig				= "Configurazione automatica del bottino"
L.AutoLootNDefault				= "Bottino automatico predefinito"
L.AutoLootNDefaultTip			= "Imposta l'impostazione predefinita globale per l'impostazione del gioco 'Bottino automatico'. Se abilitato, ripristinerà il valore selezionato in 'Valore dopo ricarica' ogni volta che ricarichi l'interfaccia utente o il relog."
L.AutoLootNReloadTip			= "Scegli l'impostazione predefinita per l'account per l'opzione 'Bottino automatico' quando ricarichi l'interfaccia utente o il relogging."
L.AutoLootSConfig				= "Configurazione rubata auto loot"
L.AutoLootSDefault				= "Furto automatico rubato"
L.AutoLootSDefaultTip			= "Imposta il valore predefinito globale per l'impostazione di gioco 'Bottino rubare automatico'. Se abilitato, ripristinerà il valore selezionato in 'Valore dopo ricarica' ogni volta che ricarichi l'interfaccia utente o il relog."
L.AutoLootSReloadTip			= "Scegli l'impostazione predefinita per l'account per l'opzione 'Bottino rubare automatico' quando ricarichi l'interfaccia utente o il relogging."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(LSAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function LSAddon:GetLanguage() -- set new language return
		return L
	end
end
