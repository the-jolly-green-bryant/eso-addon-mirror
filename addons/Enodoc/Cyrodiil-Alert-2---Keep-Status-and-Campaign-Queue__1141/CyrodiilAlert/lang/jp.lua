-- This file is part of CyrodiilAlert
ZO_CreateStringId("SI_CYRODIIL_ALERT", "CyrodiilAlert")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LANG", "jp")

--- CyrodiilAlert.lua

-- InitKeeps
ZO_CreateStringId("SI_CYRODIIL_ALERT_INIT_TEXT", "シロディールアラートが初期化された")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMP_WELCOME", "ようこそ <<1>>！")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CAMP_HOME", "ホームキャンペーン: <<1>>")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CURRENT_IMPERIAL", "インペラルシティへのアクセス権を所有している")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DO_NOT_HAVE_IMPERIAL", "インペラルシティへのアクセス権がない")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTSIDE_CYRODIIL", "シロディールの外の通知はオフです")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CHAT_OUTPUT_ON", "チャット出力はオン")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CHAT_OUTPUT_OFF", "チャット出力はオフ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_ON", "オンスクリーン通知はオン")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OFF", "オンスクリーン通知はオン")

-- DumpChat
ZO_CreateStringId("SI_CYRODIIL_ALERT_STATUS_TEXT", "シロディールの状況:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNDER_ATTACK", "攻撃されている！")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_ATTACK", "     攻撃されている城はない")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_A", "     包囲攻撃: A:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SLASH_D", " / D:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_ATT", "     包囲攻撃: Att: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SLASH_DEF", " / Def:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_AD", "     包囲攻撃: AD: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DC", ", DC: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_EP", ", EP: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SIEGES_NONE", "     包囲攻撃: なし")

-- dumpImperial
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY", "インペラルシティ:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NO_DISTRICT_UNDER_ATTACK", "     攻撃されている地域はない")
ZO_CreateStringId("SI_CYRODIIL_ALERT_AD_NAME", "     アルドメリ・ドミニオン")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UNLOCKED", "アンロック")
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_CONTROLLED", ", 支配下を維持している: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCKED", "ロック")
ZO_CreateStringId("SI_CYRODIIL_ALERT_EP_NAME", "     エボンハート・パクト")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DC_NAME", "     ダガーフォール・カバナント")

-- dumpDistricts
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_DISTRICTS", "帝国地域:")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISTRICTS", ": 地域: ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TEL_VAR_BONUS", "テルバーボーナス")

-- CampaignQueue
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_GROUP", " (グループ)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_SOLO", " (ソロ)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_QUEUE_POSITION", "<<1>> キューの位置: <<2>> <<3>>")

-- OnAllianceOwnerChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CAPTURED", "<<1>> は <<2>> によって占領された")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL", "<<1>> <<2>> |t16:16:<<X:3>>|t (合計 <<4>>)")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IN_DISTRICTS_TOTAL2", "<<1>> <<2>> |t30:30:<<X:3>>|t (合計 <<4>>)")

-- OnKeepUnderAttackChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_UNDER_ATTACK", "<<1>> が攻撃されている！")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_NO_LONGER_UNDER_ATTACK", "<<1>> はもう攻撃されていない")

-- OnGateChanged
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_OPEN", "<<1>> が開いています！")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IS_CLOSED", "<<1>> が閉まっています！")

-- OnDeposeEmperor
ZO_CreateStringId("SI_CYRODIIL_ALERT_ABDICATED", "<<1>> <<2>> の皇帝 <<3>> が放棄した！")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DEPOSED", "<<1>> <<2>> の皇帝 <<3>> が退けられた！")

-- OnCoronateEmperor
ZO_CreateStringId("SI_CYRODIIL_ALERT_CROWNED_EMPEROR", "<<1>> <<2>> の <<3>> が皇帝に就任した！")

-- OnArtifactControlState
ZO_CreateStringId("SI_CYRODIIL_ALERT_PICKED_UP", "<<1>> <<2>> の <<3>> が <<4>> を獲得した")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_TAKEN", "<<1>> <<2>> の <<3>> が <<4>> から <<5>> を奪取した")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_DROPPED", "<<1>> <<2>> の <<3>> が <<4>> を落とした")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_SECURED", "<<1>> <<2>> の <<3>> が <<4>> で <<5>> を守りた")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RETURNED", "<<1>> <<2>> の <<3>> が <<4>> を <<5>> に戻した")
ZO_CreateStringId("SI_CYRODIIL_ALERT_TIMEOUT", "<<1>> <<2>> が <<3>> に戻された（タイムアウト）")

-- OnObjectiveControlState
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CAPTURED2", "<<1>> が <<2>> を占領した")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_RECAPTURED", "<<1>> が <<2>> を再占領した")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NEUTRAL", "<<1>> は 支配なしに落ちた")

-- OnClaimKeep
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_CLAIMED", "<<1>> <<2>> は <<3>> の <<4>> を主張した")

-- OnImperialAccessGained
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_GAINED_ACCESS", "<<1>> <<2>> はインペリアルシティへのアクセス権を手にいれた！")

-- OnImperialAccessLost
ZO_CreateStringId("SI_CYRODIIL_ALERT_HAS_LOST_ACCESS", "<<1>> <<2>> はインペリアルシティへのアクセス権を失いた")

-- CAslash
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTSIDE_OFF", "シロディールの外の通知はオフ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTSIDE_ON", "シロディールの外の通知はオン")
ZO_CreateStringId("SI_CYRODIIL_ALERT_HELP", "スラッシュコマンドが利用可能です: show, hide, status, attacks, imperial, ic, init, out, clear, help")




--- CyrodiilAlertConfig.lua
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISPLAY_NAME", "Cyrodiil Alert 2")
ZO_CreateStringId("SI_CYRODIIL_ALERT_CONFIG", "設定")
ZO_CreateStringId("SI_CYRODIIL_ALERT_GENERAL_OPTIONS", "一般オプション")

-- Notification Delay
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_NAME", "通知遅延")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_TOOLTIP", "通知が画面に残る秒数")

-- Output to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_NAME", "チャット出力")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_TOOLTIP", "チャットウィンドウにも通知を表示する")

-- On-Screen Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_NAME", "オンスクリーン通知")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_TOOLTIP", "Disabled: スクリーンに通知を表示しない\nESO UI: ESOのビルドインのアナウンスシステムを使用して通知を表示する\nCA UI: シロディールアラートのカスタムウィンドウで通知を表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_DISABLED", "Disabled")

-- Sound
ZO_CreateStringId("SI_CYRODIIL_ALERT_SOUND_NAME", "     音")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SOUND_TOOLTIP", "ESOのUIを使った音の通知を有効にする")

-- Enable Notifications inside IC
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_NAME", "インペリアルシティの中で通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_TOOLTIP", "インペリアルシティの中にいるときにシロディールの通知を取得する")

-- Enable Notifications outside Cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_NAME", "シロディールの外部で通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_TOOLTIP", "シロディールの外にいる時に通知を取得する")

-- Disable default eso notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_NAME", "デフォルトのESO通知を無効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_TOOLTIP", "アーティファクトゲート、皇帝、エルダースクロールのバニラUI通知を表示しない(CA通知の代わりに下記の関連するオプションと結合される)")

-- Disable default notification outside cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OUTSIDE_CY_NAME", "     シロディール外のデフォルト通知を無効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OUTSIDE_CY_TOOLTIP", "CAが無効かどうかに関わらず、シロディールの外でバニラUI通知を表示しない")

-- Redirect default notification to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_DEFAULT_NOTIFICATION_TO_CHAT_NAME", "     デフォルト通知をチャットにリダイレクトする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_DEFAULT_NOTIFICATION_TO_CHAT_TOOLTIP", "バニラUI通知をチャットウィンドウに強制的に表示する")

-- Show initialization message
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_NAME", "初期化メッセージを表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_TOOLTIP", "シロディールに入った時に、キャンペーン名・現在の維持状況・インペリアルシティへのアクセス・帝国地域の状況をチャットウィンドウに表示する")

-- Use alliance colors
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_NAME", "アライアンス色を使用する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_TOOLTIP", "色付きでアライアンス名を表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_AD_NAME", "アルドメリ・ドミニオン")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_DC_NAME", "ダガーフォール・カバナント")
ZO_CreateStringId("SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_EP_NAME", "エボンハート・パクト")

-- Lock/Unlock
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCK_UNLOCK_NAME", "固定/解除")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LOCK_UNLOCK_TOOLTIP", "警告ウィンドウを固定/解除")

-- Keep status
ZO_CreateStringId("SI_CYRODIIL_ALERT_KEEP_STATUS", "保持中施設状況")

-- Reinitialize
ZO_CreateStringId("SI_CYRODIIL_ALERT_REINITIALIZE_TITLE", "再初期化")
ZO_CreateStringId("SI_CYRODIIL_ALERT_REINITIALIZE_TEXT", "'/ca init'も使用可能")

-- Update Status
ZO_CreateStringId("SI_CYRODIIL_ALERT_UPDATE_STATUS_NAME", "更新状況")
ZO_CreateStringId("SI_CYRODIIL_ALERT_UPDATE_STATUS_TOOLTIP", "アドオンを再初期化し、保持中施設と現在のシロディールキャンペーンのリソースを更新する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING", "シロディールの外が疑わしい")

-- Output status to chat
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TITLE", "チャットに状況を出力")
ZO_CreateStringId("SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TEXT", "'/ca attacks' and '/ca status'も使用可能")

-- List attacks
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_ATTACKS_NAME", "攻撃の一覧")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_ATTACKS_TOOLTIP", "攻撃されている保持中施設とリソースの一覧を出力する")

-- List status
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_STATUS_NAME", "状況の一覧")
ZO_CreateStringId("SI_CYRODIIL_ALERT_LIST_STATUS_TOOLTIP", "全ての保持中施設とリソースの、所有権と攻撃状況を出力する")

-- Imperial City
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_TITLE", "インペリアルシティ")
ZO_CreateStringId("SI_CYRODIIL_ALERT_IMPERIAL_CITY_TEXT", "'/ca ic', '/ca ic all', '/ca ic access', or '/ca ic districts'も使用可能")

-- Access & Districts
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_NAME", "アクセスと地域")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_TOOLTIP", "インペリアルシティと地域の支配状況を出力する")

-- Notification Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_OPTIONS_NAME", "通知オプション")

-- Enable Alliance Owner Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_NAME", "アライアンスの占領通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_TOOLTIP", "アライアンスが施設を占領した時に通知を受け取る")

-- Notification Importance
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME", "     重要な通知")
ZO_CreateStringId("SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP", "Major(メジャー): アライアンスの所有権の変化がESO UIでメジャーなイベントとして表示される\nMinor(マイナー): アライアンスの所有権の変化がESO UIのマイナーなイベントとして表示される")

-- Enable Attack Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_NAME", "攻撃通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_TOOLTIP", "攻撃に関する通知を受け取る")

-- Show Attack/Defence Sieges
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_DEFENCE_NAME", "     攻撃/守備の包囲攻撃を表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ATTACK_DEFENCE_TOOLTIP", "全体で攻撃/守備している包囲攻撃武器の数を表示する")

-- Show Sieges by Alliance
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_NAME", "アライアンスによる包囲攻撃を表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_TOOLTIP", "アライアンスによる包囲攻撃武器の数を表示する")

-- Enable Attack Ending Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_NAME", "攻撃終了通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_TOOLTIP", "攻撃終了に関する通知を受け取る")

-- Enable Guild Claim Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_NAME", "ギルドの権利に関する通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_TOOLTIP", "ギルドが権利を保持している施設の通知を受け取る")

-- Enable Emperor Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_NAME", "皇帝に関する通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_TOOLTIP", "皇帝に関する通知を受け取る")

-- Enable Imperial City Access Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_NAME", "インペリアルシティのアクセスに関する通知を\n有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_TOOLTIP", "インペリアルシティのアクセスに関する通知を受け取る")

-- Enable Queue Notification
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_NAME", "キューに関する通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_TOOLTIP", "キャンペーンキューの位置が変化した時に通知を受け取る")

-- Show Only My Alliance
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_NAME", "自身のアライアンスだけ表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_TOOLTIP", "<<1>> の保持施設とリソースの通知のみ受け取る") -- 英語版注意！

-- Objective Options
ZO_CreateStringId("SI_CYRODIIL_ALERT_OBJECTIVE_OPTIONS_NAME", "施設オプション")

-- Enable Town Capture Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_NAME", "町の占領通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_TOOLTIP", "シロディールの町の占領に関する通知を受け取る")

-- Enable District Capture Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_NAME", "地域の占領通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_TOOLTIP", "インペリアルシティの地域の占領に関する通知を受け取る")

-- Show District Capture in Cyrodiil
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_NAME", "     シロディール内の地域の占領を表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_TOOLTIP", "シロディールの中にいる時に帝国地域の占領に関する通知を受け取る")

-- Show Tel Var Capture Bonus
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_NAME", "     テルバー占領ボーナスを表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_TOOLTIP", "地域のテルバーボーナスの変化を表示する")

-- Enable Indiviual Flag Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_NAME", "独立フラグの通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_TOOLTIP", "アライアンスの独立フラグの保護に関する通知を受け取る")

-- Show Resource Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_NAME", "     リソースフラグを表示する")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_TOOLTIP", "農場・鉱山・製材所のフラグに関する通知を受け取る")

-- Show Town Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_NAME", "     町のフラグを表示")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_TOOLTIP", "町の独立フラグに関する通知を受け取る")

-- Show District Flags
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_NAME", "     地域のフラグを表示")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_TOOLTIP", "インペリアルシティの地域のフラグに関する通知を受け取る")

-- Show Flags at Neutral
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_NAME", "     中立のフラグを表示")
ZO_CreateStringId("SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_TOOLTIP", "占領中にフラグが <<1>> に落ちた時に通知を受け取る")

-- Enable Gate Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_NAME", "門に関する通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_TOOLTIP", "アーティファクトの門に関する通知を受け取る")


-- Enable Scroll Notifications
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_NAME", "呪文に関する通知を有効にする")
ZO_CreateStringId("SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_TOOLTIP", "エルダー呪文に関する通知を受け取る")
