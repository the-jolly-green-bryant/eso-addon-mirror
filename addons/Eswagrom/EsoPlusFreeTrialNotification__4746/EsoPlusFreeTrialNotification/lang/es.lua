
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_AVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Suscripción disponible|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_UNAVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Suscripción no disponible|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_LIBADDOMENU, "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 no encontrada. Verifique e instálela.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_STRING_MENU, "|cCCECC0Fecha|r                |c98FB98Estado|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM, "|cEEEE00Vamos a preguntarle a @Eswagrom...|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_A, "|c2DF5F8[@Eswagrom] susurra: Hola, la suscripción ahora está disponible ÚSALA|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_C, "|c5EB9D7[@Eswagrom]: Hola, ¿qué hay acerca de la prueba gratuita?|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_B, "|c2DF5F8[@Eswagrom] susurra: Hola, actualmente la suscripción no está disponible -_-|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION, "Enviar notificaciones al chat", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION_A, "|c00FF00Si está DESACTIVADO, el mensaje automático sobre la suscripción no llegará al chat, solo quedará la verificación manual /esoplus.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT, "Tamaño de fuente en la tabla", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT_A, "|c00FF00Cambia el tamaño de fuente en la ventana del historial de estados (de 8 a 24)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY, "Tabla de registro de suscripción", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_A, "|c00FF00Abre una ventana con información sobre la prueba gratuita.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_AVA, "|t15:15:/esoui/art/interaction/accept.dds|t |c00FF00disponible|r |t15:15:/esoui/art/interaction/accept.dds|t", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_UNAVA, "|cFF0000X|r |cFF0000no disponible|r |cFF0000X|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES, "Cantidad de líneas para registrar", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES_A, "|c00FF00Cuántas líneas se guardarán en el historial [afecta al tamaño y duración, por exceso se recorta] (de 100 a 5000)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_RESET_WINDOW, "|cEEEE00Posición de la ventana restablecida.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME, "|c00FF00Registros EsoPlus|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS, "|cFF6347¡¡¡Restablecer Configuraciones!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS_A, "|cFF6347Devuelve todas las configuraciones al estado 'recién instalado'. Restaura posición, tamaño, transparencia, fuente, visibilidad, cantidad de líneas (eliminará líneas sobre el límite!!! inicialmente 2000) e historial.|r", 1)
    
    -- Información
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS, "|c00FF00Información sobre el addon|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_A, "|c9999FF/esoplus|r |cFF6347¡escriba en el chat para verificación manual!|r Este addon guarda registros de la obtención de la suscripción gratuita, por lo que siempre sabrá con precisión en qué día se activó o estuvo ausente. Por defecto, el historial almacena hasta 2000 registros. ¿Qué significa esto en la práctica? Cada registro en la tabla ocupa una línea por día. Por lo tanto, el límite de 2000 líneas cubre un período de aproximadamente 2000/365≈5,48 años. En otras palabras, el addon almacenará el historial de sus suscripciones durante casi cinco años y medio.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AA, "|c00FF00api que utiliza este addon|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAA, "API (Application Programming Interface) — es un conjunto de reglas mediante las cuales tu addon interactúa con el servidor del juego. Dicho de forma simple, es una lista de comandos permitidos que definen los límites de sus posibilidades. Para la implementación se utilizaron los siguientes métodos:", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AB, "|c00FF00* HasEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAB, "** _Returns:_ *bool* _hasFreeTrialNotification_", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AC, "|c00FF00* ClearEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAC, "Este addon no tiene función de enlace de tecla para llamar a la tabla de usuario con el historial de registros, ya que el addon es puramente informativo. Esta tabla casi nunca la necesitarás. El autor deliberadamente no agregó tal botón debido a la limitación en el juego: solo hay 100 ranuras disponibles para teclas personalizadas, por lo que ocuparlas con elementos innecesarios no es conveniente.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AD, "|c00FF00¡¡¡Función de comprobación automática!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAD, "|c9999FFLas comprobaciones automáticas del estado de la suscripción ocurren cada 15 minutos, independientemente de la configuración del addon, esto es necesario para que no pierdas el estado si se activa un poco más tarde ese mismo día, la función de comprobación no carga tu sistema. Un temporizador así es completamente seguro para el rendimiento. Esto es por qué:|r |cFFFFC5Frecuencia de ejecución Una vez cada 15 minutos — esto es extremadamente raro para un motor de juego. A modo de comparación: el propio cliente ESO procesa decenas de miles de eventos cada segundo (animación, renderizado, paquetes de red). Una función cada 15 minutos es una gota en el océano. - Todas las operaciones aquí son puramente lógicas: lectura del estado de la cuenta a través de API integrada (HasEsoPlus...), trabajo con tabla local (Lua table) y salida de mensaje al chat (d()). No hay cálculos pesados, bucles sobre grandes matrices, acceso a archivos o red. Llamadas como ZO_SavedVars, d(), ClearEsoPlus... están optimizadas por los desarrolladores de ZOS y se ejecutan en microsegundos.|r |cffd700Ping|r se determina por la calidad de la conexión a internet y la carga de los servidores ESO. El temporizador Lua local del cliente no envía datos al servidor con más frecuencia de lo que ya lo hace el juego. La función HasEsoPlusFreeTrialNotification() utiliza el estado en caché de la cuenta — no crea tráfico de red adicional. |c1E90FFComparación con otros addons.|r Muchos addons populares usan temporizadores mucho más frecuentes: |cADD8E6- Inventory Insight|r — revisa el inventario cada vez que se abre; |cADD8E6- Combat Metrics|r — analiza cada tick de combate (docenas de veces por segundo); - incluso los elementos UI estándar se actualizan 60+ veces por segundo. Este |cADD8E6temporizador|r de 900 segundos parece «una vez en una era» frente a este trasfondo.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO, "|cFF6347Tabla de abajo:|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO_A, "|c9999FFLa tabla muestra hasta 20 ciclos de registros, indicando desde qué fecha hasta qué fecha EsoPlus estuvo disponible o no.|r |cFFFFCAbrir tabla:|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_RECORDS, "|ccdfff3Todos los registros|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_ESOPLUS, "|ccdfff3INFORMACIÓN|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG, "lista de cambios", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGA, "EsoPlusFreeTrialNotification V1.0", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_A, "primera versión", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_AA, "con la antigua biblioteca LibStub", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGB, "EsoPlusFreeTrialNotification v1.1", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_B, "cambios para ESOUI:", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_BB, "1 eliminada la conexión a LibStub, agregada la conexión a LibAddonMenu-2.0\n 2 todos los archivos de idioma con cadenas locales\n 3 Se corrigieron las variables globales sin referencia local para acelerar el acceso a la tabla _G\n 4 se corrigieron algunos cambios menores, similares a los descritos anteriormente.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGC, "EsoPlusFreeTrialNotification v1.2", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_C, "Optimización del código, primera parte", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_CC, "**1. Tabla global única Unified Namespace\n **Implementada correctamente.\n Solo se utiliza una tabla global: ESOPLUSFREETRIALNOTIFICATION_ESWAGROM con un alias local EPFTN.\n 2. Optimización de acceso G optimization\n El uso de local EPFTN ... se considera un estilo de codificación muy bueno. Esto acelera el acceso a la tabla a nivel micro al almacenar en caché la referencia en la pila de Lua, lo que evita buscar nuevamente la tabla global lenta G en cada llamada a función. 3.\n Menú de configuración integrado: El archivo de configuración externo .xml fue completamente eliminado. Todas las configuraciones y entradas ahora se procesan dentro del sistema, y para mayor comodidad se utiliza la biblioteca moderna LibAddonMenu-2.0.\n 4. Cambiado\n Optimización del código:\n Se eliminaron todas las configuraciones no utilizadas y se eliminaron la mayoría de las líneas de código obsoleto para reducir significativamente su tamaño.\n La base de código restante se optimizó considerablemente; la lógica es ahora mínima, clara y fácil de mantener.\n 5. Corregido\n Interfaz de usuario de la tabla con desplazamiento: Se solucionó el problema con la tabla de datos interna. Se implementó una barra de desplazamiento vertical totalmente funcional, que permite a los usuarios navegar fácilmente por los registros.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGD, "EsoPlusFreeTrialNotification v1.3", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_D, "optimización de la tabla", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_DD, "1). Optimización de la tabla de historial\n * **Qué ha cambiado:**\n La lógica para mostrar las entradas en la tabla de historial fue completamente reelaborada. Anteriormente, cada fila era un elemento de interfaz de usuario individual con formato propio, lo que provocaba errores visuales y retrasos al procesar grandes volúmenes de datos.\n Se corrigieron los problemas de fusión de colores del texto.\n Se eliminó el retraso de un segundo al abrir la ventana del addon.\n> ¿Por qué ocurrió esto?\n Este es un problema clásico de optimización de la interfaz de un juego:\n Optimización de memoria: cada cambio de color aumenta la carga en la CPU y la RAM. El motor agrupa elementos con estilos idénticos para reducir la cantidad de objetos a renderizar.\n Límite del motor (ZO_ScrollList): la API de ESO tiene una limitación en la cantidad de formatos de texto únicos dentro de una lista desplazable. Al alcanzar un umbral de aproximadamente 128 líneas, el motor deja de procesar etiquetas de color individuales (|c...) y comienza a aplicar el estilo del grupo anterior a todas las entradas siguientes.\n Fusión por defecto: dado que muchas filas tienen el mismo formato, la interfaz de usuario las considera un único bloque lógico y aplica un estilo uniforme de abajo hacia arriba.\n Nueva solución:\n El historial ahora solo almacena los últimos 20 períodos de disponibilidad/indisponibilidad de EsoPlus. Esto proporciona un volumen de información suficiente y garantiza que la tabla se abra instantáneamente sin ningún retraso.\n Nota importante: El volumen de datos en el archivo SavedVariables (incluso si contiene 2000-5000 registros) no afecta el rendimiento en el juego. La limitación se aplica exclusivamente a la visualización de la interfaz de usuario.\n **2). Carga segura de la localización\n * **Se mejoró el sistema de traducción de idiomas. El inglés ahora sirve como ancla base segura (idioma principal), sobre el cual se carga la localización seleccionada por el usuario. Esto hace que el proceso de inicialización del texto sea más estable y predecible.\n **3). Limpieza de código\n * **Se eliminaron todas las funciones y variables no utilizadas del archivo principal del addon. La base de código ahora es más limpia, ligera y fácil de mantener.", 1)
