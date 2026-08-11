-- define local variables as much as possible, so scope is local
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Suscripción disponible|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Suscripción no disponible|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 no encontrada. Verifique e instálela.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU"] = "|cCCECC0Fecha|r                |c98FB98Estado|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM"] = "|cEEEE00Vamos a preguntarle a @Eswagrom...|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A"] = "|c2DF5F8[@Eswagrom] susurra: Hola, la suscripción ahora está disponible ÚSALA|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C"] = "|c5EB9D7[@Eswagrom]: Hola, ¿qué hay acerca de la prueba gratuita?|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B"] = "|c2DF5F8[@Eswagrom] susurra: Hola, actualmente la suscripción no está disponible -_-|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION"] = "Enviar notificaciones al chat",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00Si está DESACTIVADO, el mensaje automático sobre la suscripción no llegará al chat, solo quedará la verificación manual /esoplus.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "Tamaño de fuente en la tabla",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00Cambia el tamaño de fuente en la ventana del historial de estados (de 8 a 24)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY"] = "Tabla de registro de suscripción",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00Abre una ventana con información sobre la prueba gratuita.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "Bloquear posición de la ventana",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00Impide mover la ventana por la pantalla|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "Transparencia del fondo",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "Restaurar posición de la ventana",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "Actualizar historial de estados",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00Si algo falló en la ventana de la tabla — actualícela, quizás esto te ayude.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "|c00FF00disponible|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "|cFF0000no disponible|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Cantidad de líneas para registrar",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00Cuántas líneas se guardarán en el historial [afecta al tamaño y duración, por exceso se recorta] (de 100 a 5000)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Posición de la ventana restablecida.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00Registros EsoPlus|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347¡¡¡Restablecer Configuraciones!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Devuelve todas las configuraciones al estado 'recién instalado'. Restaura posición, tamaño, transparencia, fuente, visibilidad, cantidad de líneas (eliminará líneas sobre el límite!!! inicialmente 2000) e historial.|r",
    
    -- Información
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00Información sobre el addon|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347¡escriba en el chat para verificación manual!|r Este addon guarda registros de la obtención de la suscripción gratuita, por lo que siempre sabrá con precisión en qué día se activó o estuvo ausente. Por defecto, el historial almacena hasta 2000 registros. ¿Qué significa esto en la práctica? Cada registro en la tabla ocupa una línea por día. Por lo tanto, el límite de 2000 líneas cubre un período de aproximadamente 2000/365≈5,48 años. En otras palabras, el addon almacenará el historial de sus suscripciones durante casi cinco años y medio.",

    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00api que utiliza este addon|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "API (Application Programming Interface) — es un conjunto de reglas mediante las cuales tu addon interactúa con el servidor del juego. Dicho de forma simple, es una lista de comandos permitidos que definen los límites de sus posibilidades. Para la implementación se utilizaron los siguientes métodos:",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "Este addon no tiene función de enlace de tecla para llamar a la tabla de usuario con el historial de registros, ya que el addon es puramente informativo. Esta tabla casi nunca la necesitarás. El autor deliberadamente no agregó tal botón debido a la limitación en el juego: solo hay 100 ranuras disponibles para teclas personalizadas, por lo que ocuparlas con elementos innecesarios no es conveniente.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00¡¡¡Función de comprobación automática!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFLas comprobaciones automáticas del estado de la suscripción ocurren cada 15 minutos, independientemente de la configuración del addon, esto es necesario para que no pierdas el estado si se activa un poco más tarde ese mismo día, la función de comprobación no carga tu sistema. Un temporizador así es completamente seguro para el rendimiento. Esto es por qué:|r |cFFFFC5Frecuencia de ejecución Una vez cada 15 minutos — esto es extremadamente raro para un motor de juego. A modo de comparación: el propio cliente ESO procesa decenas de miles de eventos cada segundo (animación, renderizado, paquetes de red). Una función cada 15 minutos es una gota en el océano. - Todas las operaciones aquí son puramente lógicas: lectura del estado de la cuenta a través de API integrada (HasEsoPlus...), trabajo con tabla local (Lua table) y salida de mensaje al chat (d()). No hay cálculos pesados, bucles sobre grandes matrices, acceso a archivos o red. Llamadas como ZO_SavedVars, d(), ClearEsoPlus... están optimizadas por los desarrolladores de ZOS y se ejecutan en microsegundos.|r |cffd700Ping|r se determina por la calidad de la conexión a internet y la carga de los servidores ESO. El temporizador Lua local del cliente no envía datos al servidor con más frecuencia de lo que ya lo hace el juego. La función HasEsoPlusFreeTrialNotification() utiliza el estado en caché de la cuenta — no crea tráfico de red adicional. |c1E90FFComparación con otros addons.|r Muchos addons populares usan temporizadores mucho más frecuentes: |cADD8E6- Inventory Insight|r — revisa el inventario cada vez que se abre; |cADD8E6- Combat Metrics|r — analiza cada tick de combate (docenas de veces por segundo); - incluso los elementos UI estándar se actualizan 60+ veces por segundo. Este |cADD8E6temporizador|r de 900 segundos parece «una vez en una era» frente a este trasfondo.",

["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION"] ="|cFF6347La tabla está ahora aquí abajo:|r",
["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME_INFORMATION_A"] ="|c9999FFAl mostrar un gran número de registros (2000 por defecto), la tabla puede abrirse con un retraso de un segundo, es normal.|r |cFFFFC5Abra la tabla:|r",

["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION__ALLRECORDS"] = "|ccdfff3Todos los registros|r",
["STRING_ESOPLUSFREETRIALNOTIFICATION_GENERAL_INFORMATION_ESOPLUS"] = "|ccdfff3INFORMACIÓN|r"

}

-- Регистрация всех строк одним циклом — ТРЕБОВАНИЕ ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end