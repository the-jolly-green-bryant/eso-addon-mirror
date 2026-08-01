if B1UI == nil then B1UI = {} end

local localization_strings = {
		SI_B1UI_ADDON_NAME = "Cuaderno 1",
		SI_B1UI_AUTHOR = "Bloodspill",
		SI_B1UI_VERSION_NUM = "|c00FF003.2|r",
			
		-- Settings Panel
		SI_B1UI_DESCRIPTION_INFO = "Un Cuaderno virtual.",
		
		SI_B1UI_HEADER_GENERAL = "Configuración General",
		
		SI_B1UI_SHOWTITLE_LABEL = "Mostrar título",
		SI_B1UI_SHOWTITLE_TOOLTIP = "Muestra el título del libro.",		
		
		SI_B1UI_TITLE_LABEL = "Titulo Del Libro",		
		SI_B1UI_TITLE_TOOLTIP = "Cambia el título del libro.",
		
		SI_B1UI_COLOR_LABEL = "libro en color",
		SI_B1UI_COLOR_TOOLTIP = "Cambia el color del libro.",
		
		SI_B1UI_DIALOG = "Diálogos de confirmación",
		SI_B1UI_DIALOG_TOOLTIP = "Activa/Desactiva los cuadros de diálogo de confirmación.",
		
		SI_B1UI_LOCK_LABEL = "Bloquear posición",
		SI_B1UI_LOCK_TOOLTIP = "Esto le permite asegurar el portátil en su lugar para que no se puede mover.",	
		
		SI_B1UI_BUTTON_LABEL = "Mostrar chat Botón",
		SI_B1UI_BUTTON_TOOLTIP = "Añade un botón en la ventana de chat para abrir / cerrar el libro.",

		SI_B1UI_OFFSETMAX_LABEL = "Offset Chat Button maximizada",
		SI_B1UI_OFFSETMAX_TOOLTIP = "Compensaciones en el botón en la ventana de chat maximizada.",
		
		SI_B1UI_OFFSETMIN_LABEL = "Offset Chat Button minimizado",
		SI_B1UI_OFFSETMIN_TOOLTIP = "Compensaciones en el botón en la ventana de chat minimizada.",
		
		SI_B1UI_WARNING = "Este ajuste debe ser aplicado y dará lugar a una pantalla de carga.",		
		
		-- UI Panel	
		SI_B1UI_CLOSEBUTTON_TOOLTIP = "Cierra el libro.",
		
		SI_B1UI_RUNBUTTON_TOOLTIP = "Ejecutar esta página como un script Lua.",		

		SI_B1UI_DELETEBUTTON_TITLE = "Eliminar página",
		SI_B1UI_DELETEBUTTON_MAINTEXT = "¿Quieres eliminar esta página?",
		SI_B1UI_DELETEBUTTON_TOOLTIP = "Eliminar esta página.",
		
		SI_B1UI_NEWBUTTON_TITLE = "Página Nueva",
		SI_B1UI_NEWBUTTON_MAINTEXT = "¿Quieres crear una nueva página?",
		SI_B1UI_NEWBUTTON_TOOLTIP = "Crear una nueva página.",
		
		SI_B1UI_SAVEBUTTON_TITLE = "Guardar Página",
		SI_B1UI_SAVEBUTTON_MAINTEXT = "¿Quieres salvar los cambios realizados en la página?",
		SI_B1UI_SAVEBUTTON_TOOLTIP = "Guarde los cambios realizados en esta página.",
		
		SI_B1UI_UNDOPAGE_TITLE = "Deshacer Página",
		SI_B1UI_UNDOPAGE_MAINTEXT = "¿Quieres deshacer todos los cambios realizados en esta página? Se volverá a la última vez que guardó.",
		SI_B1UI_UNDOBUTTON_TOOLTIP = "Deshacer los cambios realizados en esta página.",
		
		SI_B1UI_INFORMATION_TOOLTIP = "Comandos:\n|c00FF00/nb1|r conmuta la ventana de encendido/apagado.\n|c00FF00/nb1s|r alterna la configuración de encendido/apagado.\n|c00FF00/rl|r vuelve a cargar la interfaz de usuario.",
		
		SI_B1UI_YES_LABEL = "Sí",
		SI_B1UI_NO_LABEL = "No",

		-- Controls Panel
		SI_B1UI_KEYBIND_LABEL = "Cuaderno 1",
	}

for stringId, stringValue in pairs(localization_strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end