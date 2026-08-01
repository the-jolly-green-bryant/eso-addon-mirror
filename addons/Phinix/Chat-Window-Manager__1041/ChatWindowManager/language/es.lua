local CWMAddon = _G['CWMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- General strings
L.CWMAddon_Reload			= "Recargar UI"
L.CWMAddon_Clear			= "Vacie la conversacion"
L.CWMAddon_ClearT			= "Borrar la ventana de chat actual."
L.CWMAddon_Toggle			= "Alternar ventana de chat"
L.CWMAddon_Online			= "Alternar estado en línea"
L.CWMAddon_RBox				= "¿Quieres volver a cargar la interfaz de usuario?"

-- Settings panel
L.CWMAddon_Title			= "Administrador de ventanas de chat"
L.CWMAddon_AutoHide			= "Ocultar automáticamente la ventana de chat"
L.CWMAddon_AutoHideT		= "Minimiza la ventana de chat al iniciar sesión, cambiar zonas o volver a cargar la interfaz de usuario."
L.CWMAddon_RemState			= "Recuerda el estado del chat"
L.CWMAddon_RemStateT		= "Anula la siguiente opción manteniendo el estado de chat anterior entre las pantallas de carga."
L.CWMAddon_RButton			= "Añadir Recargar/Clara Botón"
L.CWMAddon_RButtonT			= "Agrega un botón a la ventana de chat para volver a cargar la interfaz de usuario, o presione Mayús y haga clic para borrar el chat actual."
L.CWMAddon_ROffset			= "Botón de recarga Desplazamiento"
L.CWMAddon_ROffsetT			= "Cambie la posición horizontal del botón de recarga cuando se madera está maximizada (para compatibilidad con otros compatibles)."
L.CWMAddon_RConfirm			= "Confirmar Recargar IU"
L.CWMAddon_RConfirmT		= "Agrega un cuadro de confirmación al hacer clic en el botón Recargar IU para evitar recargas accidentales."
L.CWMAddon_SButton			= "Añadir menú de estado de jugador"
L.CWMAddon_SButtonT			= "Agrega el menú de selección de estado en línea del jugador a la ventana de chat."
L.CWMAddon_SChat			= "Alternar estado en el chat"
L.CWMAddon_SChatT			= "Muestra el estado en línea del jugador en el chat cuando se cambia mediante combinación de teclas u otro método."
L.CWMAddon_SOffset			= "Desplazamiento del estado"
L.CWMAddon_SOffsetT			= "Cambie la posición horizontal del indicador de estado en línea cuando se maxe la chat (para la compatibilidad con otros compatibles)."
L.CWMAddon_Extras			= "Opciones extra"
L.CWMAddon_DConfirm			= "Confirmación de eliminación simple"
L.CWMAddon_DConfirmT		= "Elimina la necesidad de escribir 'DELETE' al eliminar ciertas cosas. En su lugar, obtendrá un cuadro para hacer clic en Sí o No."
L.CWMAddon_HideFriend		= "Ocultar amigo Iniciar sesión y Salir"
L.CWMAddon_HideFriendT		= "Evite que los mensajes de estado de Friend login & logout aparezcan en el chat."
L.CWMAddon_TutorialOff		= "Desactivar tutoriales"
L.CWMAddon_TutorialOffT		= "Deshabilite automáticamente los tutoriales emergentes al iniciar sesión (y al habilitar esta opción). Se puede volver a habilitar desde la configuración de juego."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(CWMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function CWMAddon:GetLanguage() -- set new language return
		return L
	end
end
