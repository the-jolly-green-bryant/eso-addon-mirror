local LSAddon = _G['LSAddon']
local L = {}
 
--------------------------------------------------------------------------------------------------------------------
-- French (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

L.BindingString					= "Mode de butin alternatif"
L.ToggleLootMode				= "Loot-Modus umschalten"
L.ReloadState					= "Recharger etat"
L.AutoLootNConfig				= "Config Auto Butin"
L.AutoLootNDefault				= "Butin auto défaut"
L.AutoLootNDefaultTip			= "Définissez la valeur globale par défaut pour le paramètre de jeu 'Butin auto'. Si activé, la valeur sélectionnée dans 'Recharger etat' sera rétablie chaque fois que vous rechargez l'interface utilisateur ou que vous vous reconnectez."
L.AutoLootNReloadTip			= "Choisissez la valeur par défaut pour l'ensemble du compte pour l'option 'Butin auto' lors du rechargement de l'interface utilisateur ou de la consignation."
L.AutoLootSConfig				= "Config Volé Auto Butin"
L.AutoLootSDefault				= "Butin volé auto défaut"
L.AutoLootSDefaultTip			= "Définissez la valeur globale par défaut pour le paramètre de jeu 'Butin volé auto'. Si activé, la valeur sélectionnée dans 'Recharger etat' sera rétablie chaque fois que vous rechargez l'interface utilisateur ou que vous vous reconnectez."
L.AutoLootSReloadTip			= "Choisissez la valeur par défaut pour l'ensemble du compte pour l'option 'Butin volé auto' lors du rechargement de l'interface utilisateur ou de la reconnexion."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(LSAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function LSAddon:GetLanguage() -- set new language return
		return L
	end
end
