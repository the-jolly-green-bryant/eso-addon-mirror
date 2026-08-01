ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuChat"] = {                          
  COLOR                 = "выделено цветом",                                                         
  COLOR2                = "Цвет названия гильдии",      

  -- Settings
  AUTO                  = "Авто-переключение",
  SOUND                 = "Звук (Личное сообщение)",                                                       
  SOUND_TT              = "Звуковой сигнал звук, который воспроизводится при получении личного сообщения",        
  GUILDS                = "согильдейцы",
  RANG                  = GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),                        
  ALLIANCE              = GetString(SI_LEADERBOARDS_HEADER_ALLIANCE),                            
  LEVEL                 = "Уровень",                                                               
  WHISPER               = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),                       
  PARTY                 = GetString(SI_CHAT_CHANNEL_NAME_PARTY),                                 
  GUILDCHAN             = GetString(SI_CHAT_OPTIONS_GUILD_CHANNELS),
  GUILDINFO             = "Информация о гильдии",                                               
  GUILDWHICH            = "Для каких гильдий выводить дополнительную информацию?",              
  GUILDNAMES_1          = "Названия",
  GUILDNAMES_2          = "Как гильдии отображаются в чате?",
  BRACKETS              = "Удалить скобки имен",                                              
  BRACKETS_TT           = "Удаляет скобки [] вокруг имен игроков",                            
  NAME                  = "Отображаемое имя",                                                             
  NAME_2                = "Имя пользователя",                                                            
  NAME_3                = "персонаж",                                                           
  NAME_4                = "Charakter@Account",                                        
  WINDOW                = "Окно чата",                                                               
  HIDETEXT              = "Скрыть текст",                                                          
  HIDETEXT_TT           = "Автоматически скрывать текст чата",                              
  REGISTER              = "Вкладка по умолчанию",                                                     
  REGISTER_TT           = "Выберите вкладку, которая автоматически открывается после входа в игру или reloadui.",                             
  CHANNEL               = "Канал по умолчанию",                                                                                    
  CHANNEL_TT            = "Выберите канал, на который переключается автоматически после входа в игру или reloadui",       
  URL                   = "Преобразование URL-адресов/ссылок",                                                           
  URL_TT                = "http(s)/www",                                                          
  PARTYSWITCH           = "Авто-переключение на группу",                                            
  PARTYSWITCH_TT        = "Переключение канала чата на групповй при формировании группы.",          
  PARTYLEAD             = GetString(SI_GROUP_LEADER_TOOLTIP) .. " выделен цветом.",               
  WARNINGCOLOR          = "Цвет текста для (новых) чатов",                         
  TIMESTAMP             = "Время",                                                             
  TIMESTAMP_TT          = "Добавляет в сообщения чата метку времени.",                        
  DATE                  = "Дата",                                                                 
  TIME                  = "Время",                                                                
  TIMESTAMP_FORMAT      = "Формат времени",                                                     
  TIMESTAMP_FORMAT_TT   = "|ceeeeeeФОРМАТ|r:\n" ..
                          "|cAFD3FFДата|r\n" ..
                          "|cAFD3FF|rДень\n|cAFD3FF|r: День (без 0)\n\|cAFD3FFMM|r: Месяц\n|cAFD3FFM|r: Месяц (без 0)\n|cAFD3FFY|r: Год\n\n" ..
                          "|cAFD3FFВремя\n" ..
                          "|cAFD3FFHH|rЧасы (24)\n|cAFD3FFhh|r: Часы (12)\n|cAFD3FFH|r: Часы (24, без 0)\n|cAFD3FFh|r: Часы (12, без 0)\n" ..
                          "|cAFD3FFA|r: AM/PM\n|cAFD3FFa|r: am/pm\n|cAFD3FFm|r: Минуты\n|cAFD3FFs|r: Секунды",
}