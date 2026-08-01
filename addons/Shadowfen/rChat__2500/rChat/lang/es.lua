--[[
Author: Ayantir
Filename: es.lua
Version: 5

Many Thanks to Toperharrier for his original work

]]--

-- Vars with -H are headers, -TT are tooltips
-- All the texts that need a translation. As this is being used as the
-- default (fallback) language, all strings that the addon uses MUST
-- be defined here.

--base language is english, so the file en.lua shuld be kept empty!
rChat_localization_strings = rChat_localization_strings  or {}

rChat_localization_strings["es"] = {

	-- ************************************************
	-- Chat tab selector Bindings
	-- ************************************************
	RCHAT_Tab1 = "Select Chat Tab 1",
	RCHAT_Tab2 = "Select Chat Tab 2",
	RCHAT_Tab3 = "Select Chat Tab 3",
	RCHAT_Tab4 = "Select Chat Tab 4",
	RCHAT_Tab5 = "Select Chat Tab 5",
	RCHAT_Tab6 = "Select Chat Tab 6",
	RCHAT_Tab7 = "Select Chat Tab 7",
	RCHAT_Tab8 = "Select Chat Tab 8",
	RCHAT_Tab9 = "Select Chat Tab 9",
	RCHAT_Tab10 = "Select Chat Tab 10",
	RCHAT_Tab11 = "Select Chat Tab 11",
	RCHAT_Tab12 = "Select Chat Tab 12",

	-- 9.3.6.24 Additions
	RCHAT_CHATTABH = "Chat Tab Settings",
	RCHAT_enableChatTabChannel = "Enable Last Used Channel Per Tab",
	RCHAT_enableChatTabChannelT = "Enable chat tabs to remember the last used channel, it will become the default until you opt to use a different one in that tab.",
	RCHAT_enableWhisperTab = "Enable Whisper Redirect",
	RCHAT_enableWhisperTabT = "Enable redirect your whispers to a specific tab.",

-- New Need Translations
	RCHAT_OPTIONSH = "Opciones",

	RCHAT_GUILDNUMBERS = "Numerar gremios",
	RCHAT_GUILDNUMBERSTT = "Muestra el número de gremio al lado de su etiqueta",

	RCHAT_ALLGUILDSSAMECOLOUR = "Usar el mismo color para todos los gremios",
	RCHAT_ALLGUILDSSAMECOLOURTT = "Colorea todos los gremios del mismo color que /guild1",

	RCHAT_ALLZONESSAMECOLOUR = "Usar el mismo color para todos los chat de zona",
	RCHAT_ALLZONESSAMECOLOURTT = "Colorea todos los chats de zona del mismo color que /zone",

	RCHAT_ALLNPCSAMECOLOUR = "Usar el mismo color para todas las lineas de PNJ",
	RCHAT_ALLNPCSAMECOLOURTT = "Hace que todo el texto de PNJs use el mismo color que PNJ /say",

	RCHAT_DELZONETAGS = "Desactiva las etiquetas de zona",
	RCHAT_DELZONETAGSTT = "Borra las etiquetas del tipo dice, grita al inicio del mensaje de chat",

	RCHAT_ZONETAGSAY = "dice",
	RCHAT_ZONETAGYELL = "grita",
	RCHAT_ZONETAGPARTY = "Grupo",
	RCHAT_ZONETAGZONE = "zona",

	RCHAT_CARRIAGERETURN = "Newline between name and message",
	RCHAT_CARRIAGERETURNTT = "Player names and chat texts are separated by a newline.",

	RCHAT_USEESOCOLORS = "Usar colores de ESO",
	RCHAT_USEESOCOLORSTT = "Usa los colores seleccionados en las opciones sociales del juego en lugar de las de rChat",

	RCHAT_DIFFFORESOCOLORS = "Diferencia entre los colores de ESO",
	RCHAT_DIFFFORESOCOLORSTT = "Si usas los colores de ESO y la opción dos colores de rChat, puedes ajustar la diferencia de brillo entre el nombre de jugador y el mensaje",

	RCHAT_REMOVECOLORSFROMMESSAGES = "Eliminar mensajes coloreados",
	RCHAT_REMOVECOLORSFROMMESSAGESTT = "Evita gente utilizando cosas como el texto de chat coloreado tipo arco-iris",

	RCHAT_PREVENTCHATTEXTFADING = "Desactivar el desvanecimiento de texto del chat",
	RCHAT_PREVENTCHATTEXTFADINGTT = "Evita que el texto del chat desaparezca(puedes ajustar la transparencia de fondo bajo Opciones - Social)",

	RCHAT_AUGMENTHISTORYBUFFER = "Augment # of lines displayed in chat",
	RCHAT_AUGMENTHISTORYBUFFERTT = "Per default, only the last 200 lines are displayed in chat. This feature raise this value up to 1000 lines",

	RCHAT_USEONECOLORFORLINES = "Usar un solo color",
	RCHAT_USEONECOLORFORLINESTT = "En lugar de usar dos colores por canal, usa solo el primer color",

	RCHAT_GUILDTAGSNEXTTOENTRYBOX = "Etiquetas de gremio en el cajón de escritura del chat",
	RCHAT_GUILDTAGSNEXTTOENTRYBOXTT = "Muestra la etiqueta del gremio en lugar del nombre en el cajón de escritura del chat",

	RCHAT_DISABLEBRACKETS = "Eliminar los corchetes de los nombres",
	RCHAT_DISABLEBRACKETSTT = "Elimina los corchetes [] que rodean los nombres de jugadores",

	RCHAT_DEFAULTCHANNEL = "Chat predeterminado",
	RCHAT_DEFAULTCHANNELTT = "Selecciona el chat a usar al iniciar sesión",

	RCHAT_DEFAULTCHANNELCHOICE99 = "Do not change",
	RCHAT_DEFAULTCHANNELCHOICE31 = "/zone",
	RCHAT_DEFAULTCHANNELCHOICE0 = "/say",
	RCHAT_DEFAULTCHANNELCHOICE12 = "/guild1",
	RCHAT_DEFAULTCHANNELCHOICE13 = "/guild2",
	RCHAT_DEFAULTCHANNELCHOICE14 = "/guild3",
	RCHAT_DEFAULTCHANNELCHOICE15 = "/guild4",
	RCHAT_DEFAULTCHANNELCHOICE16 = "/guild5",
	RCHAT_DEFAULTCHANNELCHOICE17 = "/officer1",
	RCHAT_DEFAULTCHANNELCHOICE18 = "/officer2",
	RCHAT_DEFAULTCHANNELCHOICE19 = "/officer3",
	RCHAT_DEFAULTCHANNELCHOICE20 = "/officer4",
	RCHAT_DEFAULTCHANNELCHOICE21 = "/officer5",

	RCHAT_GEOCHANNELSFORMAT = "Names format",
	RCHAT_GEOCHANNELSFORMATTT = "Formato de nombres para canales locales (say, zone, tell)",

	RCHAT_DEFAULTTAB = "Ficha predeterminada",
	RCHAT_DEFAULTTABTT = "Seleccione qué pestaña mostrar al inicio",

	RCHAT_ADDCHANNELANDTARGETTOHISTORY = "Cambiar de canal al usar el historial",
	RCHAT_ADDCHANNELANDTARGETTOHISTORYTT = "Cambie el canal cuando use las teclas de flecha para que coincida con el canal utilizado anteriormente.",

	RCHAT_URLHANDLING = "Detectar y hacer clic en URL",
	RCHAT_URLHANDLINGTT = "Si una URL que comienza con http (s): // está vinculada en el chat, pChat la detectará y podrá hacer clic en ella para ir directamente al enlace correspondiente con el navegador de su sistema",

	RCHAT_ENABLECOPY = "Activar copia",
	RCHAT_ENABLECOPYTT = "Activar copia con un clic derecho sobre el texto - también activar el conmutador de canal con un clic izquierdo. Desactive esta opción si tienes problemas para visualizar los enlaces en el chat",


	-- Group Settings

	RCHAT_GROUPH = "Ajustes de canales grupales",

	RCHAT_ENABLEPARTYSWITCH = "Habilitar cambio automático al entrar en grupo",
	RCHAT_ENABLEPARTYSWITCHTT = "Habilitar el cambio automático cambiara tu canal de chat actual al canal de grupo al entrar en uno y lo restaurará al salir de el",

	RCHAT_GROUPLEADER = "Color especial para el líder del grupo",
	RCHAT_GROUPLEADERTT = "Habilitar esta función le permitirá establecer un color especial para los mensajes del líder del grupo",

	RCHAT_GROUPLEADERCOLOR = "Color para líder del grupo",
	RCHAT_GROUPLEADERCOLORTT = "Color de los mensajes del líder del grupo. El segundo color solo se establece si \"Usar colores de ESO \" se establece en Desactivado",

	RCHAT_GROUPLEADERCOLOR1 = "Color de los mensajes para el líder del grupo",
	RCHAT_GROUPLEADERCOLOR1TT = "Color del mensaje para el líder del grupo. Si \"Usar colores de ESO \" está configurado en Desactivado, esta opción se desactivará. El color del líder del grupo será el establecido anteriormente y los mensajes del líder del grupo serán este.",

	RCHAT_GROUPNAMES = "Formato de nombres para grupos",
	RCHAT_GROUPNAMESTT = "Formato delos nombres de tus compañeros de grupo en el canal grupal",

	RCHAT_GROUPNAMESCHOICE1 = "@UserID",
	RCHAT_GROUPNAMESCHOICE2 = "Character Name",
	RCHAT_GROUPNAMESCHOICE3 = "Character Name@UserID",
	RCHAT_GROUPNAMESCHOICE4 = "Character Name(@UserID)",

	-- Sync settings

	RCHAT_SYNCH = "Configuraciones de sincronización",

	RCHAT_CHATSYNCCONFIG = "Sincronizar la configuración del chat",
	RCHAT_CHATSYNCCONFIGTT = "Si la sincronización está habilitada, todos tus personajes tendrán la misma configuración del chat (color, orientación, tamaño de la ventana, pestañas) \nPS: Seleccione esta opción cuando su chat configurado correctamente!",

	RCHAT_CHATSYNCCONFIGIMPORTFROM = "Importar configuración del chat",
	RCHAT_CHATSYNCCONFIGIMPORTFROMTT = "Siempre se puede importar la configuración del chat instantánea de otro personaje (color, orientación, tamaño de la ventana, pestañas)",

	-- Appearance
	RCHAT_APPEARANCEMH = "Apariencia de la ventana de chat",

	RCHAT_WINDOWDARKNESS = "Transparencia de la ventana de chat",
	RCHAT_WINDOWDARKNESSTT = "Increase the darkening of the chat window",

	RCHAT_CHATMINIMIZEDATLAUNCH = "Chat es minimizado en el arranque",
	RCHAT_CHATMINIMIZEDATLAUNCHTT = "Minimizar la ventana de chat de la izquierda en el lanzamiento",

	RCHAT_CHATMINIMIZEDINMENUS = "Chat es minimizado en menús",
	RCHAT_CHATMINIMIZEDINMENUSTT = "Minimizar ventana de chat a la izquierda de la pantalla cuando usted entra en los menús (Gremio, Personaje, la artesanía, etc.)",

	RCHAT_CHATMAXIMIZEDAFTERMENUS = "Restaurar chat después de salir de los menús",
	RCHAT_CHATMAXIMIZEDAFTERMENUSTT = "Siempre restaurar la ventana de chat después de salir de los menús",

	RCHAT_FONTCHANGE = "Fuente del texto",
	RCHAT_FONTCHANGETT = "Establecer la fuente del texto",

	RCHAT_TABWARNING = "Alerta de mensaje nuevo",
	RCHAT_TABWARNINGTT = "Establece el color de alerta para pestañas del chat",

	-- Whisper settings

	RCHAT_IMH = "Susurros",

	RCHAT_WHISPSOUND_ENABLED = "Habilitar sonidos para mensajes susurrados",
	RCHAT_SOUNDFORINCWHISPS = "Sonido para susurros entrantes",
	RCHAT_SOUNDFORINCWHISPSTT = "Elige un sonido a reproducir cuando recibas un susurro",

	RCHAT_NOTIFYIM = "Notificación visual",
	RCHAT_NOTIFYIMTT = "Si pierde un susurro, aparecerá una notificación en la esquina superior derecha del chat que le permitirá acceder rápidamente a él. Además, si su chat se minimizó en ese momento, se mostrará una notificación en el minibar",

	-- Restore chat settings

	RCHAT_RESTORECHATH = "Restaurar chat",

	RCHAT_RESTOREONRELOADUI = "Después de ReloadUI",
	RCHAT_RESTOREONRELOADUITT = "Después de volver a cargar el juego con un ReloadUI (), pChat restaurará su chat y su historial",

	RCHAT_RESTOREONLOGOUT = "Después de un cierre de sesión",
	RCHAT_RESTOREONLOGOUTTT = "Después de cerrar sesión, rChat restaurará su chat y su historial si inicia sesión en el tiempo asignado establecido en",

	RCHAT_RESTOREONAFK = "Después de ser pateado",
	RCHAT_RESTOREONAFKTT = "Después de ser expulsado del juego después de inactividad, inundación o desconexión de la red, rChat restaurará su chat y su historial si inicia sesión en el tiempo asignado.",

	RCHAT_RESTOREONQUIT = "Después de salir del juego",
	RCHAT_RESTOREONQUITTT = "Después de abandonar el juego, rChat restaurará su chat y su historial si inicia sesión en el tiempo asignado.",

	RCHAT_TIMEBEFORERESTORE = "Tiempo máximo para restaurar el chat",
	RCHAT_TIMEBEFORERESTORETT = "Después de este tiempo (en horas), rChat no intentará restaurar el chat",

	RCHAT_RESTORESYSTEM = "Restaurar mensajes del sistema",
	RCHAT_RESTORESYSTEMTT = "Restaurar mensajes del sistema (como notificaciones de inicio de sesión o mensajes de complementos) cuando se restaura el chat",

	RCHAT_RESTORESYSTEMONLY = "Restaurar solo mensajes del sistema",
	RCHAT_RESTORESYSTEMONLYTT = "Restaurar solo mensajes del sistema (como notificaciones de inicio de sesión o mensajes de complementos) cuando se restaura el chat",

	RCHAT_RESTOREWHISPS = "Restaurar susurros",
	RCHAT_RESTOREWHISPSTT = "Restaure los susurros enviados y recibidos después del cierre de sesión, desconecte o salga. Los susurros siempre se restauran después de un ReloadUI ()",

	RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUIT  = "Restaurar el historial de entrada de texto",
	RCHAT_RESTORETEXTENTRYHISTORYATLOGOUTQUITTT  = "Restaurar el historial de entrada de texto disponible con las teclas de flecha después de cerrar sesión, desconectar o salir. El historial de entrada de texto siempre se restaura después de un ReloadUI ()",

	-- Anti Spam settings

	RCHAT_ANTISPAMH = "Anti-Spam",

	RCHAT_FLOODPROTECT = "Activar anti-flood",
	RCHAT_FLOODPROTECTTT = "Evita que los jugadores cerca de usted y no podrá enviar mensajes idénticos repetidos",

	RCHAT_FLOODGRACEPERIOD = "Duración de destierro anti-flood",
	RCHAT_FLOODGRACEPERIODTT = "Número de segundos mientras se ignorará el mensaje idéntico anterior",

	RCHAT_LOOKINGFORPROTECT = "No haga caso de mensajes de agrupación",
	RCHAT_LOOKINGFORPROTECTTT = "No haga caso de los mensajes de los jugadores que buscan establecer / unirse a grupo",

	RCHAT_WANTTOPROTECT = "No haga caso de mensajes comerciales",
	RCHAT_WANTTOPROTECTTT = "No haga caso de los mensajes de los jugadores que buscan comprar, venta o canje",

	RCHAT_GUILDPROTECT = "Ignore Guild Recruiting messages",
	RCHAT_GUILDPROTECTTT = "Ignore messages from players promoting Guild memberships",

	RCHAT_SPAMGRACEPERIOD = "Detener temporalmente el correo no deseado",
	RCHAT_SPAMGRACEPERIODTT = "Cuando te haces un mensaje de grupo de investigación, o el comercio, el spam desactiva temporalmente la función que ha anulado el tiempo para tener una respuesta. Se reactiva automáticamente después de un período que se puede conectar (en minutos)",

	-- Nicknames settings

	RCHAT_NICKNAMESH = "Nicknames",
	RCHAT_NICKNAMESD = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",
	RCHAT_NICKNAMES = "List of Nicknames",
	RCHAT_NICKNAMESTT = "You can add nicknames for the people you want, just type OldName = Newname\n\nE.g : @Ayantir = Little Blonde\n\nIt will change the name of all the account if OldName is a @UserID or only the specified Char if the OldName is a Character Name.",

	-- Timestamp settings

	RCHAT_TIMESTAMPH = "Etiqueta horaria",

	RCHAT_ENABLETIMESTAMP = "Activar etiquetas horarias",
	RCHAT_ENABLETIMESTAMPTT = "Añade una etiqueta horaria a los mensajes de texto",

	RCHAT_TIMESTAMPCOLORISLCOL = "Colorear la etiqueta horaria de igual forma que el interlocutor",
	RCHAT_TIMESTAMPCOLORISLCOLTT = "Ignora el color de la etiqueta horaria y la colorea igual al nombre del jugador o PNJ interlocutor",

	RCHAT_TIMESTAMPFORMAT = "Formato de etiqueta horaria",
	RCHAT_TIMESTAMPFORMATTT = "FORMAT:\nHH: horas (24)\nhh: horas (12)\nH: hora (24, sin 0 de inicio)\nh: hora (12, sin 0 de inicio)\nA: AM/PM\na: am/pm\nm: minutos\ns: segundos",

	RCHAT_TIMESTAMP = "Etiqueta horaria",
	RCHAT_TIMESTAMPTT = "Establece el color para la etiqueta horaria",

	-- Guild settings

	RCHAT_NICKNAMEFOR = "Nombre",
	RCHAT_NICKNAMEFORTT = "Nombre para ",

	RCHAT_OFFICERTAG = "Etiqueta de canal de Oficial",
	RCHAT_OFFICERTAGTT = "Prefijo para canales de Oficiales",

	RCHAT_SWITCHFOR = "Interruptor para canal",
	RCHAT_SWITCHFORTT = "Nuevo interruptor para canal. Ex: /myguild",

	RCHAT_OFFICERSWITCHFOR = "Interruptor para canal oficial",
	RCHAT_OFFICERSWITCHFORTT = "Nuevo Interruptor para canal oficial. Ex: /offs",

	RCHAT_NAMEFORMAT = "Formato de nombre",
	RCHAT_NAMEFORMATTT = "Selecciona como son presentados los nombres de miembros del gremio",

	RCHAT_FORMATCHOICE1 = "@IDUsuario",
	RCHAT_FORMATCHOICE2 = "Nombre del personaje",
	RCHAT_FORMATCHOICE3 = "Nombre del personaje@IDUsuario",
	RCHAT_FORMATCHOICE4 = "Nombre del personaje(@IDUsuario)",

	RCHAT_SETCOLORSFORTT = "Establecer colores para miembros de <<1>>",
	RCHAT_SETCOLORSFORCHATTT = "Establecer colores para mensajes de <<1>>",

	RCHAT_SETCOLORSFOROFFICIERSTT = "Establecer colores para miembro del chat de Oficiales de <<1>>",
	RCHAT_SETCOLORSFOROFFICIERSCHATTT = "Establecer colores para mensajes del chat de Oficiales de <<1>>",

	RCHAT_MEMBERS = "<<1>> - Jugadores",
	RCHAT_CHAT = "<<1>> - Mensajes",

	RCHAT_OFFICERSTT = " Oficiales",

	-- Channel colors settings

	RCHAT_CHATCOLORSH = "Colores del chat",

	RCHAT_SAY = "Dice - Jugador",
	RCHAT_SAYTT = "Establece el color para el nombre del jugador en el canal principal",

	RCHAT_SAYCHAT = "Dice - Chat",
	RCHAT_SAYCHATTT = "Establece el color del mensaje de chat para el canal principal",

	RCHAT_ZONE = "Zona - Jugador",
	RCHAT_ZONETT = "Establece el color para el nombre del jugador en el canal de zona",

	RCHAT_ZONECHAT = "Zona - Chat",
	RCHAT_ZONECHATTT = "Establece el color del mensaje de chat para el canal de zona",

	RCHAT_YELL = "Grito - Jugador",
	RCHAT_YELLTT = "Establece el color para el nombre del jugador en el canal de gritos",

	RCHAT_YELLCHAT = "Grito - Chat",
	RCHAT_YELLCHATTT = "Establece el color del mensaje de chat para el canal de gritos",

	RCHAT_INCOMINGWHISPERS = "Susurros entrantes - Jugador",
	RCHAT_INCOMINGWHISPERSTT = "Establece el color para el nombre del jugador en susurros entrantes",

	RCHAT_INCOMINGWHISPERSCHAT = "Susurros entrantes - Chat",
	RCHAT_INCOMINGWHISPERSCHATTT = "Establece el color del mensaje de chat para susurros entrantes",

	RCHAT_OUTGOINGWHISPERS = "Susurros salientes - Jugador",
	RCHAT_OUTGOINGWHISPERSTT = "Establece el color para el nombre del jugador en susurros salientes",

	RCHAT_OUTGOINGWHISPERSCHAT = "Susurros salientes - Chat",
	RCHAT_OUTGOINGWHISPERSCHATTT = "Establece el color del mensaje de chat para susurros salientes",

	RCHAT_GROUP = "Grupo - Jugador",
	RCHAT_GROUPTT = "Establece el color para el nombre del jugador en el canal de grupo",

	RCHAT_GROURCHAT = "Grupo - Chat",
	RCHAT_GROURCHATTT = "Establece el color del mensaje de chat para grupos",

	-- Other colors

	RCHAT_OTHERCOLORSH = "Otros colores",

	RCHAT_EMOTES = "Emoticones - Jugador",
	RCHAT_EMOTESTT = "Establece el color para el jugador en emoticones",

	RCHAT_EMOTESCHAT = "Emoticones - Chat",
	RCHAT_EMOTESCHATTT = "Establece el color de texto de los emoticones",

	RCHAT_ENZONE = "EN Zona - Jugador",
	RCHAT_ENZONETT = "Establece el color para el jugador en el canal de zona ingles",

	RCHAT_ENZONECHAT = "EN Zona - Chat",
	RCHAT_ENZONECHATTT = "Establece el color de chat para el canal de zona ingles",

	RCHAT_FRZONE = "FR Zona - Jugador",
	RCHAT_FRZONETT = "Establece el color para el jugador en el canal de zona francés",

	RCHAT_FRZONECHAT = "FR Zona - Chat",
	RCHAT_FRZONECHATTT = "Establece el color de chat para el canal de zona francés",

	RCHAT_DEZONE = "DE Zona - Jugador",
	RCHAT_DEZONETT = "Establece el color para el jugador en el canal de zona alemán",

	RCHAT_DEZONECHAT = "DE Zona - Chat",
	RCHAT_DEZONECHATTT = "Establece el color de chat para el canal de zona alemán",

	RCHAT_JPZONE = "JP Zone - Player",
	RCHAT_JPZONETT = "Establece el color para el jugador en el canal de zona japonesa",

	RCHAT_JPZONECHAT = "JP Zone - Chat",
	RCHAT_JPZONECHATTT = "Establece el color de chat para el canal de zona japonesa",

	RCHAT_RUZONE = "RU Zone - Player",
	RCHAT_RUZONETT = "Establece el color para el jugador en el canal de zona rusa",

	RCHAT_RUZONECHAT = "RU Zone - Chat",
	RCHAT_RUZONECHATTT = "Establece el color de chat para el canal de zona rusa",

	RCHAT_NPCSAY = "PNJ Decir - Nombre PNJ",
	RCHAT_NPCSAYTT = "Establece el color para el nombre de PNJ",

	RCHAT_NPCSAYCHAT = "PNJ Decir - Chat",
	RCHAT_NPCSAYCHATTT = "Establece el color para el mensaje de PNJs",

	RCHAT_NPCYELL = "PNJ Gritos - Nombre PNJ",
	RCHAT_NPCYELLTT = "Establece el color para el nombre de PNJ",

	RCHAT_NPCYELLCHAT = "PNJ Gritos - Chat",
	RCHAT_NPCYELLCHATTT = "Establece el color del mensaje para gritos de PNJs",

	RCHAT_NPCWHISPER = "PNJ Susurros - Nombre PNJ",
	RCHAT_NPCWHISPERTT = "Establece el color para el nombre de PNJ",

	RCHAT_NPCWHISPERCHAT = "PNJ Susurros - Chat",
	RCHAT_NPCWHISPERCHATTT = "Establece el color del mensaje para susurros de PNJs",

	RCHAT_NPCEMOTES = "PNJ Emoticones - Nombre PNJ",
	RCHAT_NPCEMOTESTT = "Establece el color para el nombre de PNJ",

	RCHAT_NPCEMOTESCHAT = "PNJ Emoticones - Chat",
	RCHAT_NPCEMOTESCHATTT = "Establece el color del mensaje para emoticones de PNJs",

	-- Various strings not in panel settings

	RCHAT_COPYXMLTITLE = "Copie el texto con Ctrl + C",
	RCHAT_COPYXMLLABEL = "Copie el texto con Ctrl + C",
	RCHAT_COPYXMLTOOLONG = "El texto es demasiado largo y está dividido",
	RCHAT_COPYXMLNEXT = "Siguiente",

	RCHAT_COPYMESSAGECT = "Copiar mensaje",
	RCHAT_COPYLINECT = "Copiar linea",
	RCHAT_COPYDISCUSSIONCT = "Copiar conversación de canal",
	RCHAT_ALLCT = "Copiar chat completo",

	RCHAT_SWITCHTONEXTTABBINDING = "Cambiar a la pestaña siguiente",
	RCHAT_TOGGLECHATBINDING = "Activar la ventana de charla",
	RCHAT_WHISPMYTARGETBINDING = "Susurra mi objetivo",

	RCHAT_SAVMSGERRALREADYEXISTS = "No se puede guardar su mensaje, este ya existe",
	RCHAT_RCHAT_AUTOMSG_NAME_DEFAULT_TEXT = "Example : ts3",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT = "Escriba aquí el texto que se enviará cuando use la función de mensaje automático",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP1_TEXT = "Las líneas nuevas se eliminarán automáticamente",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP2_TEXT = "Este mensaje se enviará cuando valide el mensaje \"!nameOfMessage\". (ex: |cFFFFFF!ts3|r)",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP3_TEXT = "Para enviar un mensaje en un canal específico, agregue su interruptor al comienzo del mensaje (ex: |cFFFFFF/g1|r)",
	RCHAT_RCHAT_AUTOMSG_NAME_HEADER = "Abreviatura de su mensaje",
	RCHAT_RCHAT_AUTOMSG_MESSAGE_HEADER = "Mensaje de sustitución",
	RCHAT_RCHAT_AUTOMSG_ADD_TITLE_HEADER = "Nuevo mensaje automatizado",
	RCHAT_RCHAT_AUTOMSG_EDIT_TITLE_HEADER = "Modificar mensaje automatizado",
	RCHAT_RCHAT_AUTOMSG_ADD_AUTO_MSG = "Añadir",
	RCHAT_RCHAT_AUTOMSG_EDIT_AUTO_MSG = "Editar",
	RCHAT_SI_BINDING_NAME_RCHAT_SHOW_AUTO_MSG = "Mensajes automatizados",
	RCHAT_RCHAT_AUTOMSG_REMOVE_AUTO_MSG = "Eliminar",

	RCHAT_CLEARBUFFER = "Vacie Chat",
	RCHAT_CLEARCACHE = "Borrar el registro de chat",
	RCHAT_CLEARCACHE_TT = "Vacíe el historial de chat para que no se pueda restaurar antes de este punto.",

    RCHAT_MENTION_NM = "Notificación de menciones",
    RCHAT_MENTION_ENABLED = "Habilitar la detección de menciones en el chat",
    RCHAT_MENTIONSTR = "Texto para buscar en el chat",
    RCHAT_SOUND_ENABLED = "Habilitar notificación con sonido",
    RCHAT_SOUND_INDEX = "Que sonido tocar",
    RCHAT_COLOR_ENABLED = "Activar resaltado con color",
    RCHAT_MENTIONCOLOR = "Color de resaltado para usar",
    RCHAT_SOUND_NAME = "Nombre del sonido actual",

	RCHAT_DISABLELOGGER = "Deshabilitar el bloqueo de chat por LibDebugLogger",
	RCHAT_DISABLELOGGERTT = "Deshabilite el bloqueo de LibDebugLogger de los mensajes del SISTEMA en el chat.",
}

