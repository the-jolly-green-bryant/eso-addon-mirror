ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuChat"] = {                           
  COLOR                 = "colored",                                                         
  COLOR2                = "Guildname color",      
  
  -- Settings
  AUTO                  = "Automatic change",
  SOUND                 = "Acoustic Sound (Whispers)",                                                       
  SOUND_TT              = "Acoustic beep, which is played when you are whispered",        
  GUILDS                = "guild membership",
  RANG                  = GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),                        
  ALLIANCE              = GetString(SI_LEADERBOARDS_HEADER_ALLIANCE),                            
  LEVEL                 = "Level",                                                               
  WHISPER               = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),                       
  PARTY                 = GetString(SI_CHAT_CHANNEL_NAME_PARTY),                                 
  GUILDCHAN             = GetString(SI_CHAT_OPTIONS_GUILD_CHANNELS),
  GUILDINFO             = "Guild information",                                               
  GUILDWHICH            = "Which guilds should the information be based on?",              
  GUILDNAMES_1          = "Names",
  GUILDNAMES_2          = "What are your guilds in the chat room?",
  BRACKETS              = "Remove brackets",                                              
  BRACKETS_TT           = "Removes brackets [] around the names of the players",                            
  NAME                  = "Display name",                                                             
  NAME_2                = "Accountname",                                                            
  NAME_3                = "character",                                                           
  NAME_4                = "Charakter@Account",                                                
  WINDOW                = "Chat window",                                                               
  HIDETEXT              = "Hide text",                                                          
  HIDETEXT_TT           = "Hide chat text automatically",                              
  REGISTER              = "Standard tab",                                                     
  REGISTER_TT           = "Selecting the open tab after login/reloadui",                             
  CHANNEL               = "Standard channel",                                                                                    
  CHANNEL_TT            = "Determines which chat channel is automatically used first after login/reloadui.",       
  URL                   = "URLs / links can be clicked",                                                              
  URL_TT                = "http(s) / www",                                                          
  PARTYSWITCH           = "Automatic change: group",                                            
  PARTYSWITCH_TT        = "Switches to the Chat Channel: Group when a group is formed.",          
  PARTYLEAD             = GetString(SI_GROUP_LEADER_TOOLTIP) .. " colored.",               
  WARNINGCOLOR          = "Texts for coloring (new) chats",                         
  TIMESTAMP             = "Timestamp",                                                             
  TIMESTAMP_TT          = "Adds a timestamp to chat messages.",                        
  DATE                  = "Date",                                                                 
  TIME                  = "Time",                                                                
  TIMESTAMP_FORMAT      = "Timestamp format",                                                     
  TIMESTAMP_FORMAT_TT   = "|ceeeeeeFORMAT|r:\n" ..
                          "|cAFD3FFDDDate|r\n" ..
                          "|cAFD3FFDD|rDay\n|cAFD3FFD|r: Day(no previous 0)\n\|cAFD3FFMM|r: Month\n|cAFD3FFM|r: Month (no previous 0)\n|cAFD3FFY|r: Year\n\n" ..
                          "|cAFD3FFDDTime\n" ..
                          "|cAFD3FFHH|rHour (24)\n|cAFD3FFhh|r: Hour (12)\n|cAFD3FFH|r: Hour (24, no previous 0)\n|cAFD3FFh|r: Hpur (12, no previous 0)\n" ..
                          "|cAFD3FFA|r: AM/PM\n|cAFD3FFa|r: am/pm\n|cAFD3FFm|r: Minutes\n|cAFD3FFs|r: Seconds",
}