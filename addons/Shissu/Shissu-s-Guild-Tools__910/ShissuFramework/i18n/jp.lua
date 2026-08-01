-- Automatische Generierung
ShissuLocalization = ShissuLocalization or {}

ShissuLocalization["ShissuFramework"] = {
  DONATE  = "このアドオンが好きで、あなたのサポートを表明したいですか？そして、@Shissu :-)に寄付を送ってください。",
  LEFT    = "マウスの左ボタン",
  RIGHT   = "マウスの右ボタン",     
  MIDDLE  = "マウスの中ボタン",

  NOTE    = "ノート",
  FILTER  = "チャット フィルター プロトコル",

  TEXT    = "あなたの文章",   
  INFO    = "情報のご案内",
  ERR     = "エラー",
  MISSING = "ファイル %1 が見つかりません。",

  ADD     = "追加",
  DELETE  = "除去",
  SAVE    = "保存",
}

ShissuLocalization["ShissuFileIntegrity"] = {
  TITLE   = "データの完全性",
  FILES   = "ファイル",
  INFO    = "以下のファイルは正常に読み込まれました（読み込まれませんでした）。これらのファイルがない場合、個々のモジュールの機能を保証することはできません。アドオンの再インストールをお願いします。",
}

ShissuLocalization["ShissuLanguageChanger"] = {
  TITLE   = "TESO 言語設定",
  LANG    = "言語",
  DESC    = "ゲームを再起動することなく、エルダー・スクロールズ・オンラインの言語を選択した言語に変更します。",
  SLASH   = "また、以下のコマンドを使用してチャットで言語を変更することもできます。 %1/slc LANG",
  WARNING = "%1注意|r: インターフェイスを直接リロードします。",
}

ShissuLocalization["ShissuStandardCommands"] = {
  TITLE   = "チャットの標準コマンド",
  DESC    = "|cAFD3FF/rl|r - RELOADUI\n\n" .. 
            "|cAFD3FF/on|r - 選手の状態 " .. EsoStrings[SI_PLAYERSTATUS1] .. "\n\n" .. 
            "|cAFD3FF/off|r - 選手の状態 " .. EsoStrings[SI_PLAYERSTATUS4] .. "\n\n" ..
            "|cAFD3FF/brb|r - 選手の状態 " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/dnd|r - 選手の状態 " .. EsoStrings[SI_PLAYERSTATUS3] .. "\n\n" ..
            "|cAFD3FF/afk|r - 選手の状態 " .. EsoStrings[SI_PLAYERSTATUS2] .. "\n\n" ..
            
            "|cAFD3FF乱数を転がす|r\n" ..
            "1とお好きな数字の間に乱数を転がします。音声出力を操作することもできます。" .. "\n\n" .. 
            
            "|cAFD3FF/dice|r [ナンバー] [de,en,es,fr,jp,ru]" .. "\n\n" .. 
            "|cAFD3FF/roll|r [ナンバー] [de,en,es,fr,jp,ru]" .. "\n\n",

  DE_DICE  = "%1 hat bei einem Zufallswurf (1-%2) die Zahl %3 erwürfelt.",
  EN_DICE  = "%1 has rolled the number %3 on a random roll (1-%2).",
  ES_DICE  = "%1 ha rodado el número %3 en un rodaje aleatorio (1-%2).",
  FR_DICE  = "%1 roule le nombre %3 dans un jet alkatoire de 1-%2.",
  JP_DICE  = "%1 はランダムに %3 を転がしました (1-%2)。",
  RU_DICE  = "%1 выкатила число %3 на случайном отрезке (1-%2).",
}

ZO_CreateStringId("SI_BINDING_NAME_SSC_offlineToogle", "プレーヤーの状態のオン/オフ")
ZO_CreateStringId("SI_BINDING_NAME_SSC_reload", "Reload UI")