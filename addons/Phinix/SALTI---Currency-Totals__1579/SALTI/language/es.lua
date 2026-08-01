local SALTI = _G['SALTI']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.SALTI_Title					= "SALTI (Totales de moneda)"
L.SALTI_PTitle					= "SALTI - Totales de moneda"
L.SALTI_GOpts					= "Opciones globales"
L.SALTI_COpts					= "Estado del personaje"
L.SALTI_CCTrack					= "Moneda del personaje de la pista"
L.SALTI_CCTrackD				= "Rastree los Gold, AP, Vales de escritura y Telvar Stones del personaje actual. Al desactivar esta opción, se eliminan los datos de moneda guardados de este personaje."
L.SALTI_TRACKWARN				= "ADVERTENCIA: ¡Recargará automáticamente la UI!"
L.SALTI_IWPos					= "Usa la posición independiente"
L.SALTI_IWPosD					= "Cuando esté habilitada, la ubicación de la información emergente de la herramienta emergente de moneda estará en el lugar donde se colocó por última vez la ventana con la tecla de acceso rápido. Establezca una combinación de teclas o escriba /salti para mostrar/ocultar SALTI para configurar la posición de la ventana."
L.SALTI_SACIcon					= "Mostrar icono de alianza/clase"
L.SALTI_SACIconD				= "Muestra un icono de color junto al nombre de cada personaje rastreado que indica su Clase y la Alianza a la que pertenecen."
L.SALTI_SGC						= "Mostrar moneda global"
L.SALTI_SGCD					= "Muestre el resumen de las monedas de toda la cuenta debajo de los totales estándar."
L.SALTI_GCS						= "Global Currency Espaciado"
L.SALTI_GCSD					= "Amplíe o acorta el espacio entre los elementos de la moneda global."
L.SALTI_ALPHAN					= "Lista de nombres alfabéticos"
L.SALTI_ALPHAND					= "Cuando esté habilitada, la lista de monedas de caracteres rastreados se ordenará alfabéticamente De lo contrario, la lista de caracteres coincide con el orden de sus caracteres en la pantalla de inicio de sesión."
L.SALTI_SGBGold					= "Mostrar Guild Bank Gold"
L.SALTI_SGBGoldD				= "Muestre el resumen de oro almacenado en sus bancos de gremio actuales en la información sobre herramientas de resumen de oro (debe visitar cada banco de gremio para completar/actualizar los valores de oro)."
L.SALTI_DCChar					= "Eliminar datos del personaje:"
L.SALTI_DELETE					= "BORRAR"
L.SALTI_CDELD					= "Eliminar el carácter seleccionado de la base de datos de seguimiento. Si elimina un carácter que aún existe aquí, se configurarán automáticamente para no rastrear. Inicie sesión como el carácter y vuelva a habilitar el seguimiento en Opciones de caracteres para volver a agregarlos a la base de datos."

-- General Strings
L.SALTI_BTotal					= "Depositado:"
L.SALTI_ATotal					= "Totales de cuenta:"
L.SALTI_SOURCE					= "FUENTE"
L.SALTI_CGlobal					= "Global:"
L.SALTI_DBUpdate				= "La base de datos SALTI se restableció en esta versión.\nInicie sesión en cada carácter para reconstruir."

-- Below must be the same as it appears on the in-game currency tab with the translation mod you are using:
--L.SALTI_ETHeader				= "event tickets"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k, v in pairs(SALTI:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function SALTI:GetLanguage() -- set new language return
		return L
	end
end
