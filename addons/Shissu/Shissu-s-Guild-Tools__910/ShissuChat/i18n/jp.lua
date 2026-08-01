-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuChat"] = {       
  COLOR                 = "カラーハイライト",         
  COLOR2                = "ギルド名カラー",                                                
  
  -- Settings
  GENERAL               = "一般的な",
  AUTO                  = "自動交換",
  SOUND                 = "音響信号の音色",                                                       
  SOUND_TT              = "囁かれた時に鳴る音響信号の音色",        
  GUILDS                = "ギルド会員",
  RANG                  = GetString(SI_GAMEPAD_GUILD_ROSTER_RANK_HEADER),                        
  ALLIANCE              = GetString(SI_LEADERBOARDS_HEADER_ALLIANCE),                            
  LEVEL                 = "Level",                                                               
  WHISPER               = GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER),                       
  PARTY                 = GetString(SI_CHAT_CHANNEL_NAME_PARTY),                                 
  GUILDCHAN             = GetString(SI_CHAT_OPTIONS_GUILD_CHANNELS),
  GUILDINFO             = "ギルド情報",                                               
  GUILDWHICH            = "どのギルドの情報を元にするべきなのでしょうか？",              
  GUILDNAMES_1          = "ギルド名",
  GUILDNAMES_2          = "チャットのギルドは何と呼ぶべきか？",
  BRACKETS              = "名前の周りのカッコを外す",                                              
  BRACKETS_TT           = "プレイヤー名の周りの括弧[]を削除します。",                            
  NAME                  = "表示名",                                                             
  NAME_2                = "アカウント名",                                                            
  NAME_3                = "キャラクター名",                                                           
  NAME_4                = "キャラクター名@アカウント",                                                
  WINDOW                = "チャットスター",                                                               
  HIDETEXT              = "隠し文字",                                                          
  HIDETEXT_TT           = "チャットテキストを自動的に非表示にする",                              
  REGISTER              = "標準レジスタ/タブ",                                                     
  REGISTER_TT           = "ReloadUi",                             
  CHANNEL               = "標準チャンネル",                                                                                    
  CHANNEL_TT            = "登録/再起動後、どのチャットチャンネルを自動的に最初に使用するかを決定します。",       
  URL                   = "URL/リンクをクリック可能にする",                                                              
  URL_TT                = "http(s) / www",                                                          
  PARTYSWITCH           = "自動変更：グループ",                                            
  PARTYSWITCH_TT        = "チャットチャンネルに切り替えます。グループ、一旦グループを結成します。",          
  PARTYLEAD             = GetString(SI_GROUP_LEADER_TOOLTIP) .. " 色でハイライトします。",               
  WARNINGCOLOR          = "(新)ウィスパーチャットのテキストハイライト色",                         
  TIMESTAMP             = "タイムスタンプ",                                                             
  TIMESTAMP_TT          = "チャットメッセージにタイムスタンプを追加します。",     
  TIMESTAMPNPC          = "NPC、モンスターのタイムスタンプ",
  TIMESTAMPNPC_TT       = "さらに、NPCやモンスターからのテキストメッセージのタイムスタンプを表示します。",
  DATE                  = "日付",                                                                 
  TIME                  = "時間",                                                                
  TIMESTAMP_FORMAT      = "タイムスタンプ形式",                                                     
  TIMESTAMP_FORMAT_TT   = "|ceeeeee形式|r:\n" ..                                                
                          "|cAFD3FF日付|r\n" ..
                          "|cAFD3FFDD|r日\n|cAFD3FFD|r: 日(接頭辞なし 0)\n\|cAFD3FFMM|r: 月\n|cAFD3FFM|r: 月（先行0なし\n|cAFD3FFY|r: 年\n\n" ..
                          "|cAFD3FF時間\n" ..
                          "|cAFD3FFHH|rじかん (24)\n|cAFD3FFhh|r: じかん (12)\n|cAFD3FFH|r: じかん (24)\n|cAFD3FFh|r: じかん\n" ..
                          "|cAFD3FFA|r: AM/PM\n|cAFD3FFa|r: am/pm\n|cAFD3FFm|r: 議事録\n|cAFD3FFs|r: セコンド",
  USEGUILDCOLORS        = "代わりにギルドチャットの色を使う",
  USEGUILDCOLORS_TT     = "チャット内の演出は、カスタムカラーではなく、ギルドチャットの色を使用しています[設定→ソーシャル]。",
}