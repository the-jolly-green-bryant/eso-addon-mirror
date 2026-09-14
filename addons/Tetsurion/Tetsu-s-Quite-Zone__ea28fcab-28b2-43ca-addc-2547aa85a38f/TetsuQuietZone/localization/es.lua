TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "Info"
L.INFO_TT = "Oculta líneas de zona y say con un hipervínculo de gremio. También puede silenciar el chat de gremios tuyos elegidos. No bloquea la ventana oficial de invitación.\nOro / fallos: correo @Tetsurion."

L.ADS_SECTION = "Silenciar anuncios de gremio"
L.ADS_SECTION_TT = "Oculta muros de recluta en zona / say / yell si la línea tiene un enlace de gremio."

L.ENABLED = "Activar filtro de anuncios"
L.ENABLED_TT = "Interruptor principal de anuncios zona/say/yell. On = las líneas con enlace de gremio no aparecen."

L.FILTER_ZONE = "Filtrar chat de zona"
L.FILTER_ZONE_TT = "Todos los canales de zona, idiomas incluidos. Por defecto on."

L.FILTER_SAY = "Filtrar say"
L.FILTER_SAY_TT = "Say local. Por defecto on."

L.FILTER_YELL = "Filtrar yell"
L.FILTER_YELL_TT = "Por defecto off. Actívalo si también llegan muros por yell."

L.GUILD_SECTION = "Silenciar chat de gremio"
L.GUILD_SECTION_TT = "Cada interruptor es un gremio al que perteneces. On = oculta sus mensajes. Los demás no cambian. Se guarda por id. Por defecto off."
L.GUILD_HINT = "ON - ocultar mensajes de este gremio"
L.GUILD_HINT_TT = "On = oculta todos los mensajes de /g y /o de ese gremio. Otros gremios, zona y say no cambian."
L.GUILD_EMPTY = "<<1>>. (hueco vacío)"
L.MUTE_GUILD_TT = "On = oculta solo los mensajes de este gremio. Otros gremios, zona y say no cambian."

L.HIDDEN_LABEL = "Ocultado esta sesión: <<1>>"
L.HIDDEN_TT = "Líneas saltadas desde el inicio (anuncios + gremios silenciados). Se reinicia con ReloadUI."
