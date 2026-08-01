-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuChat"] = {       
  COLOR                 = "resaltado de color",         
  COLOR2                = "Nombres del gremio Color",                                                
  
  -- Settings
  GENERAL               = "General",
  AUTO                  = "Cambio automático",
  SOUND                 = "Tono de señal acústica",                                                       
  SOUND_TT              = "El tono de la señal acústica que se reproduce cuando se le susurra a",        
  GUILDS                = "Membresía del gremio",
  RANG                  = GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),                        
  ALLIANCE              = GetString(SI_LEADERBOARDS_HEADER_ALLIANCE),                            
  LEVEL                 = "Nivel",                                                               
  WHISPER               = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),                       
  PARTY                 = GetString(SI_CHAT_CHANNEL_NAME_PARTY),                                 
  GUILDCHAN             = GetString(SI_CHAT_OPTIONS_GUILD_CHANNELS),
  GUILDINFO             = "Información de los gremios",                                               
  GUILDWHICH            = "¿En qué gremios debería basarse la información?",              
  GUILDNAMES_1          = "Nombre del gremio",
  GUILDNAMES_2          = "¿Cómo deben llamarse tus gremios en el chat?",
  BRACKETS              = "Eliminar los corchetes alrededor de los nombres",                                              
  BRACKETS_TT           = "Elimina los corchetes [] alrededor de los nombres de los jugadores por nombre",                            
  NAME                  = "Nombre de pantalla",                                                             
  NAME_2                = "Cuenta",                                                            
  NAME_3                = "Carácter",                                                           
  NAME_4                = "Carácter@Cuenta",                                                
  WINDOW                = "Ventana de chat",                                                               
  HIDETEXT              = "ocultar el texto",                                                          
  HIDETEXT_TT           = "Ocultar el texto del chat automáticamente",                              
  REGISTER              = "Registro estándar/tabla",                                                     
  REGISTER_TT           = "Selección de la pestaña abierta después de iniciar sesión/recarga",                             
  CHANNEL               = "Canal estándar",                                                                                    
  CHANNEL_TT            = "Determina qué canal de chat se utiliza automáticamente primero después del registro/lanzamiento.",       
  URL                   = "Hacer que las URLs/enlaces sean cliqueables",                                                              
  URL_TT                = "http(s) / www",                                                          
  PARTYSWITCH           = "Cambio automático: Grupo",                                            
  PARTYSWITCH_TT        = "Cambia al canal de chat: Grupo, una vez que se forma un grupo.",          
  PARTYLEAD             = GetString(SI_GROUP_LEADER_TOOLTIP) .. " resaltan en color.",               
  WARNINGCOLOR          = "El texto resaltando el color para los (nuevos) chats de susurros",                         
  TIMESTAMP             = "Sello de tiempo",                                                             
  TIMESTAMP_TT          = "Añade una marca de tiempo a los mensajes de chat.",     
  TIMESTAMPNPC          = "Sellos de tiempo para los PNJ, monstruos",
  TIMESTAMPNPC_TT       = "Además muestra una marca de tiempo para los mensajes de texto de los PNJ, monstruos.",
  DATE                  = "Fecha",                                                                 
  TIME                  = "Tiempo",                                                                
  TIMESTAMP_FORMAT      = "Formato de la marca de tiempo",                                                     
  TIMESTAMP_FORMAT_TT   = "|ceeeeeeFORMAT|r:\n" ..                                                
                          "|cAFD3FFFecha|r\n" ..
                          "|cAFD3FFDD|rDía\n|cAFD3FFD|r: Día (ninguno con prefijo 0)\n\|cAFD3FFMM|r: mes\n|cAFD3FFM|r: Mes (no hay 0 precedentes)\n|cAFD3FFY|r: Año\n\n" ..
                          "|cAFD3FFTiempo\n" ..
                          "|cAFD3FFHH|rhoras (24)\n|cAFD3FFhh|r: horas (12)\n|cAFD3FFH|r: hora (24, ninguno prefijado 0)\n|cAFD3FFh|r: hora (12,ninguno prefijado 0)\n" ..
                          "|cAFD3FFA|r: AM/PM\n|cAFD3FFa|r: am/pm\n|cAFD3FFm|r: minutos\n|cAFD3FFs|r: segundos",
  USEGUILDCOLORS        = "Usa los colores del Guild Chat en su lugar",
  USEGUILDCOLORS_TT     = "En lugar de un color personalizado, se utiliza el color del chat del gremio para la presentación en el chat [Configuración -> Social].",                
}