WPamA.i18n = {
  lang = "JP",
  
-- Marker (substring) in quest name for detect Veteran Pledge
  VeteranM = "ベテラン",
-- Marker (substring) in active quest step text for detect DONE stage
  DoneM = {
    [1] = "へ戻る",
    [2] = "と話す",
  },
-- Keybinding string
  KeyBindShowStr = "アドオンウィンドウの表示/非表示",
  KeyBindChgStr  = "アドオンウィンドウモードの変更",
  KeyBindCharStr = "キャラクターウィンドウの表示/非表示",
  KeyBindClndStr = "カレンダーウィンドウの表示/非表示",
  KeyBindWWBStr  = "ロスガーボスウィンドウの表示/非表示",
  KeyBindInvtStr = "その他ウィンドウの表示/非表示",
  KeyBindPostTd  = "今日の誓いをチャットに投稿する",
  KeyBindRGLA    = "RGLA(レイドグループリーダーアシスタント）の表示/非表示",
  KeyBindRGLASrt = "RGLA: 開始",
  KeyBindRGLAStp = "RGLA: 停止",
  KeyBindRGLAPst = "RGLA: チャットに投稿",
  KeyBindRGLAShr = "RGLA: クエストの共有",
-- No character error string
  NoCharErr = "キャラクターリストの読み込みエラー!",
-- More character. It is the result of removing and adding characters
  MoreCharErr = (WPamA.Consts.RowCnt+1).." 以上のキャラクターを検知しました! キャラクターベースのリセットのため '/wpa rch' をタイプしてください",
-- Caption
  CaptChar = "キャラクター",
  CaptClnd = "カレンダー",
  CaptWWB  = "ロスガーワールドボス",
  CaptInvt = "その他",
-- Labels
  TotalRow = "合計",
  ResetChar = "リセット",
  HdrLvl = "レベル",
  HdrName = "名前",
  HdrClnd = "カレンダー",
  HdrMSL = "MSL",
  HdrSilver = "ノーマル / シルバー",
  HdrGold = "ベテラン / ゴールド",
  OptLocation = "ダンジョン名の代わりに地名",
  OptENDungeon = "ダンジョン名を英語で表示",
  OptDontShowNone = "\"なし\"の代わりに空白を表示",
  OptTitleToolTip = "ウィンドウのタイトルのツールチップを有効にする",
  SendInvTo = "<<1>> に招待を送る",
  RGLABossKilled = "ボスが倒されました。RGLAを停止しました。",
  RGLALeaderChanged = "グループリーダーが変更されました。RGLAを停止しました。",
  RGLAOptQAutoShare = "クエストの自動共有を有効にする",
  RGLAOptQAlert = "画面に通知する",
  RGLAOptQChat = "チャットに通知する",
  RGLAOptBossKilled = "ボスが倒されるとRGLAは停止します。",
  RGLAShare = "共有",
  RGLAStop = "停止",
  RGLAPost = "投稿",
  RGLAStart = "開始",
  RGLAStarted = "開始済み",
-- RGLA Errors
  RGLA_ErrBoss = "ボスは既に倒されています。RGLAは起動できません。",
  RGLA_ErrQuest = "ロスガーデイリーボスクエストを受けていません!",
  RGLA_ErrWrothgar = "現在、ロスガーにいません!",
  RGLA_ErrLeader = "グループリーダーではありません!",
  RGLA_ErrAI = "AutoInviteアドオンが見つからないか、有効でありません!",
-- Dungeons Status
  DungStDone = "完了",
  DungStNA = "無効",
-- Wrothgar Boss Status
  WWBStNone = "なし",
  WWBStDone = "完了",
  WWBStCur  = "進行中",
-- Enlightened
  EnlOn  = "あなたのキャラクターは悟りを開きました。",
  EnlOff = "あなたのキャラクターは悟りを開いていません。",
}
WPamA.i18n.ToolTip = {
  [0] = "ウィンドウを閉じる",
  [1] = "オプションウィンドウの表示/非表示",
  [2] = "ウィンドウモードを変更",
  [3] = "チャットに今日の誓いを投稿する",
  [4] = "あなたの現在の進捗は、誓いを完了しています。",
  [5] = "現在及び未来の誓いのカレンダー",
  [6] = "あなたの現在の進捗は、デイリークエスト進行中です",
  [7] = "ゴールド/シルバー/ブロンズ鍵、ロックピック、極大魂石",
  [8] = "スケールされたダンジョンに入れる最小レベル",
--  [9] = "",
  [10] = "キャラクターリストのリセット",
  [11] = "ゴールド製アンドーンテッドの鍵",
  [12] = "シルバー製アンドーンテッドの鍵",
  [13] = "ブロンズ製アンドーンテッドの鍵",
  [14] = "ロックピック",
  [15] = "極大魂石",
  [16] = "極大魂石 (空)",
--
  [21] = "未完成のドルメン\n - 蘇ったザンダデュノズ",
  [22] = "ニジャレフト・フォールズ\n - ニジャレフト ドワーフ センチュリオン",
  [23] = "族長王の玉座\n - 族長王エドゥ",
  [24] = "マッド・オーガの祭壇\n -  マッド・ウルカズブル",
  [25] = "密猟者の野営地\n - オールド・スナガラ",
  [26] = "呪われた託児所\n - 悪鬼コリンサック",
  [27] = "アチーブメントのカウントダウン",
}
WPamA.i18n.RGLAMsg = {
  [1] = "ギルド: メンバーを探す ...",
  [2] = "ギルド: メンバーを探す（短縮）",
  [3] = "ギルド: 1分後に開始",
  [4] = "グループ: 1分後に開始",
  [5] = "グループ: 開始",
  [6] = "ギルド: ボスが倒された",
  [7] = "グループ: 既に行っている",
  [8] = "アドオンについて",
}
-- In Dungeons structure:
-- Mark - The substring in quest name which indicates the dungeon
-- Name - Short name of the dungeon displayed by the addon
WPamA.i18n.Dungeons = {
-- Virtual dungeon
  [1] = { -- None
    Mark = "-1-",
    Name = "なし",
  },
  [2] = { -- Unknown
    Mark = "-2-",
    Name = "不明",
  },
-- First location dungeons
  [3] = { -- AD, Auridon, Banished Cells
    Mark = "追放者",
    Name = "追放者の監房",
  },
  [4] = { -- EP, Stonefalls, Fungal Grotto
    Mark = "フンガル",
    Name = "フンガル洞窟",
  },
  [5] = { -- DC, Glenumbra, Spindleclutch
    Mark = "スピンドル",
    Name = "スピンドルクラッチ",
  },
-- Second location dungeons
  [6] = { -- AD, Grahtwood, Elden Hollow
    Mark = "エルデン",
    Name = "エルデン洞穴",
  },
  [7] = { -- EP, Deshaan, Darkshade Caverns
    Mark = "ダークシェード",
    Name = "ダークシェード洞穴",
  },
  [8] = { -- DC, Stormhaven, Wayrest Sewers
    Mark = "ウェイレスト",
    Name = "ウェイレスト下水道",
  },
-- 3 location dungeons
  [9] = { -- AD, Greenshade, City of Ash
    Mark = "灰",
    Name = "灰の街",
  },
  [10] = { -- EP, Shadowfen, Arx Corinium
    Mark = "アークス",
    Name = "アークス・コリニウム",
  },
  [11] = { -- DC, Rivenspire, Crypt of Hearts
    Mark = "墓地",
    Name = "ハーツ墓地",
  },
-- 4 location dungeons
  [12] = { -- AD, Malabal Tor, Tempest Island
    Mark = "テンペスト",
    Name = "テンペスト島",
  },
  [13] = { -- EP, Eastmarch, Direfrost Keep
    Mark = "ダイアフロスト",
    Name = "ダイアフロスト砦",
  },
  [14] = { -- DC, Alik`r Desert, Volenfell
    Mark = "ヴォレンフェル",
    Name = "ヴォレンフェル",
  },
-- 5 location dungeons
  [15] = { -- AD, Reaper`s March, Selene`s Web
    Mark = "セレーン",
    Name = "セレーンの巣",
  },
  [16] = { -- EP, The Rift, Blessed Crucible
    Mark = "るつぼ",
    Name = "聖なるるつぼ",
  },
  [17] = { -- DC, Bangkorai, Blackheart Haven 
    Mark = "ヘブン",
    Name = "ブラックハートヘブン",
  },
-- 6 location dungeons
  [18] = { -- Any, Coldharbour, Vaults of Madness
    Mark = "狂気",
    Name = "狂気の地下室",
  },
-- 7 location dungeons
  [19] = { -- Any, Imperial City, IC Prison
    Mark = "監獄",
    Name = "帝国監獄",
  },
  [20] = { -- Any, Imperial City, WG Tower
    Mark = "塔",
    Name = "白金の塔",
  },
}
WPamA.i18n.DailyBossQ = {
  [1] = "無知という異端", -- zanda, 蘇ったザンダデュノズ
  [2] = "雪と蒸気", -- nyz, ニジャレフト
  [3] = "悪い遊びの臭い", -- edu, 族長王エドゥ
  [4] = "学問的救出", -- ogre, マッド・ウルカズブル
  [5] = "大衆のための肉", -- poa, オールド・スナガラ
  [6] = "自然の恵み", -- cori, 悪鬼コリンサック
}
WPamA.i18n.DayOfWeek = {
  [0] = "日",
  [1] = "月",
  [2] = "火",
  [3] = "水",
  [4] = "木",
  [5] = "金",
  [6] = "土",
}
-- The message in chat should always be Japanese. This part should be only in Japanese localization.
WPamA.JP = {
-- Chat
  Chat = {
    Td1 = "今日の誓い[",
    Td2 = "より]: ",
    Silver = "シルバー : ",
    Gold = ", ゴールド : ",
    Loot1 = "(",
    Loot2 = "が窃取可能)",
    Use1 = " (",
    Use2 = "を利用)",
  },
  RGLA = {
    CG = "/g1",
    CP = "/p",
    F1 = "/g1 <<1>> のクエストがシェアできます。",
    F2 = "AutoInvite及びAutoShareで参加するにはいずれかの文字列をチャットから入力してください。\"<<1>>",
    F3 = "AutoInviteで参加するにはいずれかの文字列をチャットから入力してください。\"<<1>>",
    F4 = "\" , \"<<1>>",
    F5 = "\" ( <<1>> ).",
    F6 = "/g1 AutoInvite及びAutoShareで \"<<1>>\" の参加を募集しています。",
    F7 = "/g1 AutoInviteで \"<<1>>\" の参加を募集しています。",
    F8 = "<<1>> あと1分で <<2>> を開始します。",
    F9 = "/p <<1>> を開始します。",
    F10 = "/g1 <<1>> は倒されました。",
    F11 = "/p クエストは自動的にシェアされます。おそらく、あなたは既に他のボスのクエストを受けているか、今日の分を既に完了しています。",
    F12 = "アドオン<<1>> v<<2>> from ESOUI.COM: 自動招待及び自動共有機能を有する「誓い」と「ロスガーボスデイリークエスト」の追跡ツールです。",
  },
  ShareSubstr = "share",
  DayOfWeek = {},
  DungeonsName = {},
}
for i=0,6 do
  WPamA.JP.DayOfWeek[i] = WPamA.i18n.DayOfWeek[i]
end
for n, v in pairs(WPamA.i18n.Dungeons) do
  WPamA.JP.DungeonsName[n] = v.Name
end

WPamA.Consts.DailyBoss = {
    [1] = {
      H = "ザンダ",
      S = {
        [1] = "+zanda",
        [2] = "+zan",
        [3] = "+dolmen",
      },
    },
    [2] = {
      H = "ニジャ",
      S = {
        [1] = "+nyz",
      },
    },
    [3] = {
      H = "エドゥ",
      S = {
        [1] = "+edu",
      },
    },
    [4] = {
      H = "マッド",
      S = {
        [1] = "+ogre",
        [2] = "+mad",
      },
    },
    [5] = {
      H = "スナガラ",
      S = {
        [1] = "+poa",
      },
    },
    [6] = {
      H = "コリン",
      S = {
        [1] = "+cori",
      },
    },
}
