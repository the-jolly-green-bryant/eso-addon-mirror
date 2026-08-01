local LSAddon = _G['LSAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Spanish (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

L.BindingString					= "Modo de botín alternativo"
L.ToggleLootMode				= "Alternar modo de botín"
L.ReloadState					= "Valor después de la recarga"
L.AutoLootNConfig				= "Configuración de Auto Loot"
L.AutoLootNDefault				= "Predeterminado Auto Loot"
L.AutoLootNDefaultTip			= "Establecer el valor predeterminado global para la configuración del juego 'Auto Loot'. Si está habilitado, se restablecerá al valor seleccionado en 'Valor después de la recarga' cada vez que vuelva a cargar la interfaz de usuario o vuelva a iniciar sesión."
L.AutoLootNReloadTip			= "Elija el valor predeterminado de toda la cuenta para la opción 'Auto Loot' cuando vuelva a cargar la interfaz de usuario o vuelva a iniciar la sesión."
L.AutoLootSConfig				= "Auto Loot robado configuración"
L.AutoLootSDefault				= "Predeterminado Auto Loot Stolen"
L.AutoLootSDefaultTip			= "Establecer el valor predeterminado global para la configuración del juego 'Auto Loot Stolen Items'. Si está habilitado, se restablecerá al valor seleccionado en 'Valor después de la recarga' cada vez que vuelva a cargar la interfaz de usuario o vuelva a iniciar sesión."
L.AutoLootSReloadTip			= "Elija el valor predeterminado de toda la cuenta para la opción 'Auto Loot Stolen Items' cuando vuelva a cargar la interfaz de usuario o vuelva a iniciar la sesión."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(LSAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function LSAddon:GetLanguage() -- set new language return
		return L
	end
end
