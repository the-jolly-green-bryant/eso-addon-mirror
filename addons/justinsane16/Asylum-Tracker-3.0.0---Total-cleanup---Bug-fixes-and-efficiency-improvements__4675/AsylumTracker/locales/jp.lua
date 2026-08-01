local AST = AsylumTracker
AST.lang.jp = {}

local locale_strings = {
     -- Settings Menu
     ["AST_SETT_HEADER"] = "Asylum Tracker 設定",
     ["AST_SETT_INFO"] = "Asylum Tracker 情報",
     ["AST_SETT_DESCRIPTION"] = "聖者の隔離所に役立つ通知や警告を行います",
     ["AST_SETT_NOTIFICATIONS"] = "通知",
     ["AST_SETT_LANGUAGE"] = "言語",
          --     ["AST_SETT_LANGUAGE_OVERRIDE"] = "Language Override",
          --     ["AST_SETT_LANGUAGE_OVERRIDE_DESC"] = "Ignore the game's locale and load a specific language to use for the addon",
          --     ["AST_SETT_LANGUAGE_DROPDOWN_TOOL"] = "Select Language to load.",

          --     ["AST_SETT_TIMERS"] = "Timer Settings (BETA)",
          --     ["AST_SETT_OLMS_ADJUST"] = "Adjust Olms' timers",
          --     ["AST_SETT_LLOTHIS_ADJUST"] = "Adjust Llothis' timers",
          --     ["AST_SETT_OLMS_ADJUST_DESC"] = "Adjust Olms' timers to account for other mechanics happening when a timer reaches 0",
          --     ["AST_SETT_LLOTHIS_ADJUST_DESC"] = "Adjust Oppressive Bolts timer to account for Defiling Blast happening when the oppressive bolts timer reaches 0",

     -- Unlock Button
     ["AST_SETT_UNLOCK"] = "アンロック",
     ["AST_SETT_LOCK"] = "ロック",
     ["AST_SETT_UNLOCK_TOOL"] = "通知等を表示させて動かせるようにします",

     -- Generics
     ["AST_SETT_YOU"] = "あなた",
     ["AST_SETT_SOON"] = "準備",
     ["AST_SETT_NOW"] = "NOW",
     ["AST_SETT_COLOR"] = "カラー",
     ["AST_SETT_COLOR_1"] = "メインカラー",
     ["AST_SETT_COLOR_2"] = "サブカラー",
     ["AST_SETT_FONT_SIZE"] = "フォントサイズ",
     ["AST_SETT_SCALE"] = "大きさ",
     ["AST_SETT_SCALE_WARN"] = "この設定を変更すると通知がぼやけてしまうため、フォントサイズを先に設定してください",
          --     ["AST_SETT_TIMER_COLOR"] = "Timer Color",
          --     ["AST_SETT_TIMER_COLOR_TOOL"] = "The color for the countdown number displayed on timers",

     -- Center Notifications Button
          -- ["AST_SETT_CENTER_NOTIF"] = "Reset Positions",
          -- ["AST_SETT_CENTER_NOTIF_TOOL"] = "Resets the notifications to their default positions",

     -- Sound Effects
     ["AST_SETT_SOUND_EFFECT"] = "サウンドエフェクト",
     ["AST_SETT_SOUND_EFFECT_TOOL"] = "抑圧のボルトとストームオブヘブンに対するサウンドエフェクト", -- I'm not sure what the official Japanese Translations are for Defiling Dye Blast or Storm the Heavens

     -- Mini Notifications
     ["AST_SETT_LLOTHIS_NOTIF"] = "ロシスの通知", -- Notifications for Llothis
     ["AST_SETT_LLOTHIS_NOTIF_TOOL"] = "以下の状況で通知を出します : ロシスが倒された時、復活が近い時、復活する時",
     ["AST_SETT_FELMS_NOTIF"] = "フェルムスの通知", -- Notifications for Felms
     ["AST_SETT_FELMS_NOTIF_TOOL"] = "以下の状況で通知を出します : フェルムスが倒された時、復活が近い時、復活する時",

     -- Olms' HP
     ["AST_SETT_OLMS_HP_SIZE"] = "オルムスのHP通知のフォントサイズ", -- Font Size for Olms' HP Notification
     ["AST_SETT_OLMS_HP_SIZE_TOOL"] = "オルムスのHP通知のフォントサイズを変更します",
     ["AST_SETT_OLMS_HP_SCALE"] = "オルムスのHP通知の大きさ",
     ["AST_SETT_OLMS_HP_SCALE_TOOL"] = "オルムスのHP通知の大きさを変更します",
     ["AST_SETT_OLMS_HP_COLOR_1_TOOL"] = "オルムスがジャンプを行うまでのHPが2%以上の時と5%以下の時の色",
     ["AST_SETT_OLMS_HP_COLOR_2_TOOL"] = "オルムスがジャンプを行うまでのHPが2%以下の時の色",

     -- Storm the Heavens
     ["AST_SETT_STORM"] = "ストームオブヘブン", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_STORM_TOOL"] = "オルムスの放つ雷追尾弾",
     ["AST_SETT_STORM_SIZE_TOOL"] = "天への嵐の通知のフォントサイズを変更します",
     ["AST_SETT_STORM_SCALE_TOOL"] = "天への嵐の通知の大きさを変更します",
     ["AST_SETT_STORM_COLOR_1_TOOL"] = "天への嵐の通知の最初の明滅の色",
     ["AST_SETT_STORM_COLOR_2_TOOL"] = "天への嵐の通知の２回目の明滅の色",
          -- ["AST_SETT_STORM_SOUND_EFFECT"] = "Sound Effect",
          -- ["AST_SETT_STORM_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Storm the Heavens.",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
          -- ["AST_SETT_STORM_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Storm the Heavens Sound Effect",

     -- Defiling Dye Blast
     ["AST_SETT_BLAST"] = "ロシスのブラスト", -- I'm sure there's an official translation for the ability, but I'm not sure what it is.
     ["AST_SETT_BLAST_TOOL"] = "ロシスが放つ毒のブラスト攻撃",
     ["AST_SETT_BLAST_SIZE_TOOL"] = "ブラストの通知のフォントサイズを変更します",
     ["AST_SETT_BLAST_SCALE_TOOL"] = "ブラストの通知の大きさを変更します",
     ["AST_SETT_BLAST_COLOR_TOOL"] = "ブラストの通知の色を変更します",
          -- ["AST_SETT_BLAST_SOUND_EFFECT"] = "Sound Effect",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_TOOL"] = "Sound Effect that will be used for Defiling Blast.",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME"] = "Sound Effect Volume",
          -- ["AST_SETT_BLAST_SOUND_EFFECT_VOLUME_TOOL"] = "Volume of Defiling Blast Sound Effect.",

     -- Protectors
     ["AST_SETT_PROTECT"] = "スフィア", -- The little sphere's the shield Olms
     ["AST_SETT_PROTECT_TOOL"] = "ボスにシールドを張るスフィア",
     ["AST_SETT_PROTECT_SIZE_TOOL"] = "スフィアに関する通知のフォントサイズを変更します",
     ["AST_SETT_PROTECT_SCALE_TOOL"] = "スフィアに関する通知の大きさを変更します",
     ["AST_SETT_PROTECT_COLOR_1_TOOL"] = "スフィアがシールドを付与する際明滅する通知の最初の色",
     ["AST_SETT_PROTECT_COLOR_2_TOOL"] = "スフィアがシールドを付与する際明滅する通知の２番目の色",
          -- ["AST_SETT_PROTECT_MESSAGE"] = "Sphere Text",
          -- ["AST_SETT_PROTECT_MESSAGE_TOOL"] = "Set Custom Sphere Text",

     -- Teleport Strike
     ["AST_SETT_JUMP"] = "テレポートストライク", -- Felms' jumping mechanic
     ["AST_SETT_JUMP_TOOL"] = "フェルムスのジャンプ攻撃",
     ["AST_SETT_JUMP_SIZE_TOOL"] = "テレポートストライクの通知のフォントサイズを変更します",
     ["AST_SETT_JUMP_SCALE_TOOL"] = "テレポートストライクの通知の大きさを変更します",
     ["AST_SETT_JUMP_COLOR_TOOL"] = "テレポートストライクの通知の色を変更します",

     -- Oppressive Bolts
     ["AST_SETT_BOLTS"] = "抑圧のボルト", -- Llothis' attack that needs to be interrupted
     ["AST_SETT_BOLTS_TOOL"] = "ロシスのバッシュ可能な攻撃",
     ["AST_SETT_BOLTS_SIZE_TOOL"] = "抑圧のボルトの通知のフォントサイズを変更します",
     ["AST_SETT_BOLTS_SCALE_TOOL"] = "抑圧のボルトの通知の大きさを変更します",
     ["AST_SETT_BOLTS_COLOR_TOOL"] = "抑圧のボルトの通知の色を変更します",
     ["AST_SETT_INTTERUPT"] = "バッシュ成功メッセージ",
     ["AST_SETT_INTTERUPT_TOOL"] = "ロシスへのバッシュが成功した時のメッセージ",

     -- Steam Breath
     ["AST_SETT_STEAM"] = "スチームブレス", -- Olms' steam breath attack
     ["AST_SETT_STEAM_TOOL"] = "オルムスの蒸気範囲ブレス攻撃",
     ["AST_SETT_STEAM_SIZE_TOOL"] = "スチームブレスの通知のフォントサイズを変更します",
     ["AST_SETT_STEAM_SCALE_TOOL"] = "スチームブレスの通知の大きさを変更します",
     ["AST_SETT_STEAM_COLOR_TOOL"] = "スチームブレスの通知の色を変更します",

     -- Exhaustive Charges
          -- ["AST_SETT_CHARGES"] = "Exhaustive Charges",
          -- ["AST_SETT_CHARGES_TOOL"] = "Olms' Exhaustive Charges Attack",
          -- ["AST_SETT_CHARGES_SIZE_TOOL"] = "Change the Font Size for Olms' Exhaustive Charges",
          -- ["AST_SETT_CHARGES_SCALE_TOOL"] = "Change the Scale for Olms' Exhaustive Charges",
          -- ["AST_SETT_CHARGES_COLOR_TOOL"] = "Color for Olms' Exhaustive Charges",

     -- Trial By Fire
     ["AST_SETT_FIRE"] = "炎の試練", -- Olms' Fire mechanic below 25% HP
     ["AST_SETT_FIRE_TOOL"] = "オルムスのHPが25%以下の時に繰り出す炎の範囲攻撃",
     ["AST_SETT_FIRE_SIZE_TOOL"] = "炎の試練の通知のフォントサイズを変更します",
     ["AST_SETT_FIRE_SCALE_TOOL"] = "炎の試練の通知の大きさを変更します",
     ["AST_SETT_FIRE_COLOR_TOOL"] = "炎の試練の通知の色を変更します",

     -- Maim
     ["AST_SETT_MAIM"] = "不自由デバフ", -- Felms' Maim debuff
     ["AST_SETT_MAIM_TOOL"] = "フェルムスの不自由デバフ",
     ["AST_SETT_MAIM_SIZE_TOOL"] = "不自由デバフ通知のフォントサイズを変更します",
     ["AST_SETT_MAIM_SCALE_TOOL"] = "不自由デバフ通知の大きさを変更します",
     ["AST_SETT_MAIM_COLOR_TOOL"] = "不自由デバフ通知の色を変更します",

     -- In-Game Notifications
     ["AST_NOTIF_LLOTHIS_IN_10"] = "ロシス復活まであと10秒", -- Llothis will be back up in 10 seconds (because when he gets killed in the fight, he doesn't die, he goes dormant and then gets back up after ~35s)
     ["AST_NOTIF_LLOTHIS_IN_5"] = "ロシス復活まであと5秒",
     ["AST_NOTIF_LLOTHIS_UP"] = "ロシス復活", -- Llothis stands back up
     ["AST_NOTIF_LLOTHIS_DOWN"] = "ロシスダウン", -- llothis goes dormant.
     ["AST_NOTIF_FELMS_IN_10"] = "フェルムス復活まであと10秒",
     ["AST_NOTIF_FELMS_IN_5"] = "フェルムス復活まであと５秒",
     ["AST_NOTIF_FELMS_UP"] = "フェルムス復活",
     ["AST_NOTIF_FELMS_DOWN"] = "フェルムスダウン",

     -- On-screen Notifications
     ["AST_NOTIF_OLMS_JUMP"] = "オルムスジャンプ", -- For when Olms jumps at 90/75/50/25% HP
     ["AST_NOTIF_PROTECTOR"] = "スフィア", -- Referring to the protectors
     ["AST_NOTIF_KITE"] = "ストームまで: ", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_KITE_NOW"] = "ストーム!", -- Referring to Olms' Storm the Heavens mechanic. (Storm would probably be a better word to translate than Kite)
     ["AST_NOTIF_BLAST"] = "ブラスト: ", -- Referring to Llothis' Cone attack. (Cone would probably be a better word to translate than blast)
     ["AST_NOTIF_JUMP"] = "フェルムスジャンプ: ",
     ["AST_NOTIF_BOLTS"] = "バッシュまで: ", -- Referring to Llothis' Oppressive bolts attack
     ["AST_NOTIF_INTERRUPT"] = "バッシュ", -- For when you need to Interrupt Llothis' oppressive bolts attack
     ["AST_NOTIF_FIRE"] = "炎の試練: ",
     ["AST_NOTIF_STEAM"] = "スチームブレス: ", -- Referring to Olms' Steam breath
     ["AST_NOTIF_MAIM"] = "不自由デバフ: ", -- Referring to Felms' Maim
     -- ["AST_NOTIF_CHARGES"] = "CHARGES: ",

     -- Previewing Notifications
     ["AST_PREVIEW_OLMS_HP_1"] = "オルムス",
     ["AST_PREVIEW_OLMS_HP_2"] = "HP",
     ["AST_PREVIEW_STORM_1"] = "ストーム",
     ["AST_PREVIEW_STORM_2"] = "まで",
     ["AST_PREVIEW_SPHERE_1"] = "スフ",
     ["AST_PREVIEW_SPHERE_2"] = "ィア",
     ["AST_PREVIEW_BLAST"] = "ブラスト",
     ["AST_PREVIEW_JUMP"] = "フェルムスジャンプ",
     ["AST_PREVIEW_BOLTS"] = "バッシュまで",
     ["AST_PREVIEW_FIRE"] = "炎の試練",
     ["AST_PREVIEW_STEAM"] = "スチームブレス",
     ["AST_PREVIEW_MAIM"] = "不自由デバフ",
     -- ["AST_PREVIEW_CHARGES"] = "CHARGES",
}

function AST.lang.jp.LoadStrings()
     for k, v in pairs(locale_strings) do
          ZO_CreateStringId(k, v)
     end
end
