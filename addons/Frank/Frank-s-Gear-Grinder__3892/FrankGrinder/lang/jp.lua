local strings = {

    -----------
    -- Menu
    GG_MENU_LE_HEADER = "リード有効期限のリマインダー",
    GG_MENU_LE_DESC = "プレイヤーがゾーンを変更した際にリマインダーが発動します。設定した日数以内に期限切れとなるリードがある場合、リマインダーが表示されます。リマインダーが表示された後は、設定した間隔のあいだ一時停止されます。",
    GG_MENU_LE_ENABLED = "有効",
    GG_MENU_LE_ENABLED_TT = "リード有効期限のリマインダーを有効にしますか？",
    GG_MENU_LE_ANNOUNCE_REMINDERS = "リマインダーを通知",
    GG_MENU_LE_ANNOUNCE_REMINDERS_TT = "リード有効期限リマインダーを画面上に表示しますか？",
    GG_MENU_LE_CHAT_REMINDERS = "チャットにリマインダーを表示",
    GG_MENU_LE_CHAT_REMINDERS_TT = "チャットウィンドウにリマインダーを表示しますか？",
    GG_MENU_LE_WARNING_PERIOD = "リマインダー開始日数（1～20日）",
    GG_MENU_LE_WARNING_PERIOD_TT = "リードの期限切れまで何日前からリマインダーを開始するか。",
    GG_MENU_LE_NO_WARNING_PERIOD = "リマインダー停止間隔（分）[1–120]",
    GG_MENU_LE_NO_WARNING_PERIOD_TT = "リマインダー間の秒数間隔。",
    GG_MENU_GF_HEADER = "グループ検索の通知",
    GG_MENU_GF_ENABLED = "有効",
    GG_MENU_GF_ENABLED_TT = "グループ検索の通知をチャットウィンドウに表示しますか？",
    GG_MENU_GF_CHECK_INTERVAL = "グループ検索チェック間隔（秒）[5–60]",
    GG_MENU_GF_CHECK_INTERVAL_TT = "グループ検索で新しい試練の募集を確認する秒数間隔。最小5秒、最大60秒。",
    GG_MENU_GF_TRIAL_HEADER = "通知対象の試練（グループ検索）",
    GG_MENU_GF_TRIAL_DESC = "「任意の試練」で作成された募集も通知対象に含まれます。",
    GG_MENU_GF_TRIAL_TT = "%s のグループ検索募集を含めますか？",
    GG_MENU_PA_HEADER = "Personal Assistant 連携",
    GG_MENU_PA_DESC = "必要条件:\n- アドオン: LibCharacterKnowledge、LibPrice（TamrielTradeCentre、Master Merchant、Arkadius' Trade Tools などの価格ソースが有効であること）\n- 商人キャラクター用の専用 Personal Assistant LOOT プロファイル。余剰品や販売用アイテムが銀行から引き出された際に自動習得されないようにします。\n\nルーティングルール:\n1. クラフターが未習得のアイテム → クラフターへ送付\n2. 低価値アイテムは LibCharacterKnowledge に従い次のキャラクターへ\n3. 余剰品および高価値アイテムは商人へ送付（有効時）、無効時は銀行に残留。",
    GG_MENU_PA_ENABLED = "有効？",
    GG_MENU_PA_ENABLED_TT = "Personal Assistant の上書きを有効にしますか？無効化には UI の再読み込みが必要です。",
    GG_MENU_PA_SALE_VALUE_THRESHOLD = "販売価格のしきい値",
    GG_MENU_PA_SALE_VALUE_THRESHOLD_TT = "この価格以下のアイテムは低価値として扱われます。",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME = "クラフター名",
    GG_MENU_PA_CRAFTER_CHARACTER_NAME_TT = "クラフターとして使用するキャラクター名。",
    GG_MENU_PA_TRADER_CHARACTER_NAME = "商人名",
    GG_MENU_PA_TRADER_CHARACTER_NAME_TT = "商人として使用するキャラクター名。",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED = "商人へ引き出す？",
    GG_MENU_PA_WITHDRAW_TO_TRADER_ENABLED_TT = "余剰アイテムを銀行から商人へ引き出します。",

    -----------
    -- core
    GG_LAM_NOT_FOUND = "LibAddonMenu2 が見つかりません。メニューを作成できません。",
    GG_CHARACTERS = "キャラクター",
    GG_SHOW_WINDOW = "ウィンドウを表示",
    GG_TOGGLE_LOCATION_TRACKER = "ロケーション変更トラッカーを切り替え",
    GG_REMAINING = " 残り",
    GG_ELAPSED = " 経過",

    -----------
    -- Lead Expiry
    GG_LE_NEW_LEAD = "未発見／新しいリード",
    GG_LE_LEAD = "リード",
    GG_LE_LORE_LEAD = "未完了のコーデックス／ロア・リード",
    GG_LE_EXPIRY_IN = " 有効期限：あと ",
    GG_LE_EXPIRING_IN = "リードの有効期限が近づいています：あと ",
    GG_LE_FOUND_IN = " 発見場所：",
    GG_LE_UNKNOWN_NAME = "不明な手掛かり",
    GG_LE_UNKNOWN_ZONE = "不明なゾーン",
    GG_LE_REMIND = "通知",
    GG_LE_IGNORE = "無視",
    GG_LE_DISABLE_REMINDER = "通知を無効化",
    GG_LE_ENABLE_REMINDER = "通知を有効化",
    GG_LE_TOGGLE_REMINDER = "通知切替",
    
    -----------
    -- Group Finder
    GG_GF_NEW_LISTING = "新しいリスティング",
    GG_GF_UPDATED_LISTING = "更新されたリスティング",
    GG_GF_REMOVED_LISTING = "削除されたリスティング",
    GG_GF_NO_LISTING = "グループ検索：|cff0000リスティングが見つかりません。|r 見つかり次第通知します。",

    -----------
    -- Location Change
    GG_LOCATION_CHANGED = "ロケーションが変更されました",
    GG_LOCATION_ENABLED = "ロケーション変更トラッカーが有効になりました",
    GG_LOCATION_DISABLED = "ロケーション変更トラッカーが無効になりました",

    -----------
    -- Night Market
    GG_NM_MENU_ELMS_GUIDANCE_HEADER = "ナイトマーケットのクエスト目標ガイド",
    GG_NM_MENU_BLUE_MARKERS = "青いマーカーはクエスト開始地点の候補を示します。",
    GG_NM_MENU_GREEN_MARKERS = "緑のマーカーはクエスト目標地点の候補を示します。",
    GG_NM_MENU_NOTE_ON_ELMS = "注: これらのマーカーを表示するには ElmsMarkers をインストールして有効化する必要があります。",
    GG_NM_MENU_QUEST_LIST_HDR = "番号は以下のクエストに対応しています。",
    GG_NM_MENU_HIDE_TRACKER = "勢力スコアトラッカーを非表示",
    GG_NM_MENU_HIDE_TRACKER_TT = "画面上のナイトマーケット勢力スコアを非表示にします。",
    GG_NM_MENU_ELMS_ENABLE = "ElmsMarkers へのマーカー注入を有効化しますか？",
    GG_NM_MENU_ELMS_ENABLE_TT = "ナイトマーケットのクエスト用に ElmsMarkers に3Dマーカーを追加します。",
    GG_NM_GROUP_AUTO = "Argent グループ自動化",
    GG_NM_GROUP_AUTO_OFF = "オフ",
    GG_NM_GROUP_AUTO_ON = "オン",
    GG_NM_GROUP_AUTO_ERROR_NOTINZONE = "イベントゾーン外です",
    GG_NM_GROUP_AUTO_ERROR_ZONENOTACTIVE = "イベントゾーンが有効ではありません",
    GG_NM_GROUP_AUTO_ERROR_FAILEDTWICE = "グループ検索の作成に2回失敗しました",
    GG_NM_GROUP_AUTO_ALLDONE = "すべての鍵を入手しました",
    GG_NM_GROUP_AUTO_LISTINGREMOVED = "リスティングを削除しました",
    GG_NM_GROUP_AUTO_QUESTSHARE1 = "共有",
    GG_NM_GROUP_AUTO_QUESTSHARE2 = "件のクエストをグループと共有しました。",
    GG_NM_GROUP_AUTOMATION_KEYBIND = "Argent グループ自動化を切り替え",


    -----------
    -- Time
    GG_TIME_SECONDS = "秒",
    GG_TIME_MINUTES = "分",
    GG_TIME_HOURS = "時間",
    GG_TIME_DAYS = "日",
    GG_TIME_NONE = "なし",

}

for id, val in pairs(strings) do
   ZO_CreateStringId(id, val)
   SafeAddVersion(id, 1)
end