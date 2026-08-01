local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Opciones globales"
L.EZReport_TIcon				= "Mostrar icono de objetivo informado"
L.EZReport_DTime				= "Mostrar hora reportada objetivo"
L.EZReport_RCooldown			= "Enfriamiento de informes"
L.EZReport_RCooldownM			= "EZReport ya se informó el día de hoy: Rehabilitación de informes está activado"
L.EZReport_OutputChat			= "Mostrar mensajes de chat"
L.EZReport_12HourFormat			= "Formato de hora de 12 horas"
L.EZReport_IncPrev				= "Incluir datos del informe anterior"
L.EZReport_DCategory			= "Categoría por defecto"
L.EZReport_DReason				= "Motivo predeterminado"
L.EZReport_Reset				= "Restablecer historial de informes"
L.EZReport_Clear				= "CLARO"

-- Target Reported Colors
L.EZReport_RColorS				= "Colores reportados objetivo"
L.EZReport_RColor1				= "Color genérico"
L.EZReport_RColor2				= "Color de mal nombre"
L.EZReport_RColor3				= "Color Tóxico"
L.EZReport_RColor4				= "Color de engaño"
L.EZReport_RColor5				= "Color reportado alt"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Muestra un icono que indica los objetivos que has informado anteriormente. Coincide con los íconos vistos al elegir una categoría en la ventana del informe."
L.EZReport_DTimeT				= "Mostrar la hora en que se informó un objetivo por última vez junto al Icono de objetivo informado. Si nunca se informó el carácter actual, muestra la hora más reciente en que se informó de cualquier carácter en su cuenta."
L.EZReport_RCooldownT			= "Cuando está habilitado, evita los informes de teclas de acceso rápido si ya ha informado el objetivo hoy. Es útil cuando se reportan grandes grupos de robots para que pueda enviar correo basura al enlace clave y el sistema de informes solo se activará cuando tenga un objetivo que aún no haya informado."
L.EZReport_OutputChatT			= "Muestra mensajes informativos relacionados con varias funciones adicionales en el chat."
L.EZReport_12HourFormatT		= "Cuando está habilitado, las marcas de tiempo generadas usarán el formato de 12 horas (hora más AM o PM). Si lo desactivas, se mostrará el formato 24 horas 'hora militar'."
L.EZReport_IncPrevT				= "Incluye datos de fecha, hora y nombre sobre informes anteriores de este personaje o alts conocidos al enviar un informe."
L.EZReport_DCategoryT			= "Elija la subcategoría predeterminada para seleccionar automáticamente al abrir la ventana del informe."
L.EZReport_DReasonT				= "Incluya el motivo seleccionado en la sección de detalles personalizados de la ventana de informes. La opción manual (predeterminada) es dejarlo en blanco para que lo escriba manualmente."
L.EZReport_ResetT				= "Borrar toda la base de datos de los personajes y cuentas reportados anteriormente."
L.EZReport_ResetM				= "La base de datos EZReport ha sido restablecida."

-- Category List
L.EZReport_CatList1				= "Mal nombre"
L.EZReport_CatList2				= "Acoso"
L.EZReport_CatList3				= "Engañando"
L.EZReport_CatList4				= "Otra"
L.EZReport_CatList5				= "Ninguno (predeterminado)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"
L.EZReport_ReasonList2			= "Explotando"
L.EZReport_ReasonList3			= "Acoso"
L.EZReport_ReasonList4			= "Manual (predeterminado)"

-- Chat List
L.EZReport_CReason1				= "Informe genérico"
L.EZReport_CReason2				= "Mal nombre"
L.EZReport_CReason3				= "Comportamiento tóxico"
L.EZReport_CReason4				= "Engañando"

-- Chat Strings
L.EZReport_RepT					= "Reportado:"
L.EZReport_RepC					= "Personaje reportado:"
L.EZReport_Unkn					= "cuenta desconocida"
L.EZReport_Now					= "ahora:"
L.EZReport_Char					= "personaje:"
L.EZReport_For					= "para:"
L.EZReport_NoMatch				= "No se encontraron coincidencias."

-- Info Panel
L.EZReport_RAcct				= "Informe de cuenta: "
L.EZReport_RAlts				= "Alts previamente reportados: "

-- General Strings
L.EZReport_RLast				= "Informar del objetivo del último jugador"
L.EZReport_RHistory				= "Historial de informes de objetivos"
L.EZReport_ROpen				= "Abrir ventana principal"
L.EZReport_Reason				= "Motivo (opcional):"
L.EZReport_CName				= "Nombre del personaje:"
L.EZReport_AName				= "Nombre de la cuenta:"
L.EZReport_MLoc					= "Mapa:"
L.EZReport_Coords				= "Coords:"
L.EZReport_Time					= "Fecha y hora:"
L.EZReport_CButton				= "Clara"
L.EZReport_Today				= "Hoy"
L.EZReport_Updated				= "La base de datos EZReport ha sido actualizada."
L.EZReport_AccUnavail			= "Cuenta no disponible"
L.EZReport_LocUnavail			= "Ubicación no disponible"
L.EZReport_Wayshrine			= "Wayshrine"
L.EZReport_Accounts				= "Informes por cuenta"
L.EZReport_Characters			= "Informes por personaje"
L.EZReport_Locations			= "Informes por ubicación"
L.EZReport_Generated			= "Generar: EZReport por Phinix"
L.EZReport_Previous				= "Previamente reportado:"
L.EZReport_Confirm				= "Confirmar eliminación"
L.EZReport_Cancel				= "Cancelar"
L.EZReport_Delete				= "Borrar"

-- Tooltip strings
L.EZReport_TTShow				= "Haga clic para mostrar el resumen del informe."
L.EZReport_TTClick				= "Haga clic en el campo de resultados y presione:"
L.EZReport_TTSelect1			= "Ctrl+A"
L.EZReport_TTSelect2			= " para seleccionar todos."
L.EZReport_TTCopy1				= "Ctrl+C"
L.EZReport_TTCopy2				= " copiar."
L.EZReport_TTPaste1				= "Ctrl+V"
L.EZReport_TTPaste2				= " para pegar en otro lugar."
L.EZReport_TTAccounts			= "Cambiar a mostrar cuentas."
L.EZReport_TTCharacters			= "Cambiar a mostrar caracteres."
L.EZReport_TTEMode				= "Cambiar al modo de edición de la base de datos."
L.EZReport_TTRMode				= "Cambiar al modo de informe de texto."
L.EZReport_TTCEntry1			= "Click izquierdo"
L.EZReport_TTCEntry2			= " para mostrar las entradas de caracteres."
L.EZReport_TTAEntry1			= "Shift+Click izquierdo"
L.EZReport_TTAEntry2			= " para mostrar las entradas de la cuenta."
L.EZReport_TTDEntry1			= "Botón derecho del ratón"
L.EZReport_TTDEntry2			= " para borrar la entrada seleccionada."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function EZReport:GetLanguage() -- set new language return
		return L
	end
end
