local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PMAddon_GLOBAL			= "OPCIONES GLOBALES"
L.PMAddon_LOCK				= "Posición de bloqueo"
L.PMAddon_LOCKTIP			= "Evita mover la ventana de configuración del veneno."
L.PMAddon_BACK				= "Ocultar fondo"
L.PMAddon_BACKTIP			= "Oculta el fondo de la ventana de configuración de poison."
L.PMAddon_ICONS				= "Mostrar equipar iconos"
L.PMAddon_ICONSTIP			= "Muestra los íconos de los indicadores de tus venenos de armas activos e inactivos cuando se asignan a una ranura favorita."
L.PMAddon_THEME				= "Equipar el tema del icono"
L.PMAddon_THEMETIP			= "Elija el estilo para los indicadores de veneno equipados."
L.PMAddon_STYLE1			= "Fronteras"
L.PMAddon_STYLE2			= "Cheques"
L.PMAddon_DEBUG				= "Mostrar texto de depuración"
L.PMAddon_DEBUGTIP			= "Muestra texto descriptivo en el chat cuando ocurren ciertas cosas."
L.PMAddon_Tooltip			= "Pulse la tecla Mayús para asignar veneno equipado a la ranura. Haga clic derecho para borrar."

-- Keybind strings
L.PMAddon_KBT				= "Alternar ventana de configuración de veneno"
L.PMAddon_KB1				= "Equipar/Unequip Slot 1 Veneno"
L.PMAddon_KB2				= "Equipar/Unequip Slot 2 Veneno"
L.PMAddon_KB3				= "Equipar/Unequip Slot 3 Veneno"
L.PMAddon_KB4				= "Equipar/Unequip Slot 4 Veneno"

-- Debug strings
L.PMAddon_PNE				= "El veneno deseado ya no está en tus bolsas."
L.PMAddon_NPE				= "El arma activa no tiene veneno equipado para asignar."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(PMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PMAddon:GetLanguage() -- set new language return
		return L
	end
end
