-- Lionas's Food & Drink Reminder
-- Author: Lionas
-- Japanese specific file

-- enable/disable
ZO_CreateStringId("LIO_FADR_ENABLE", "は有効です")
ZO_CreateStringId("LIO_FADR_DISABLE", "は無効です")

-- notification
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRE_HOUR_MIN", "残り<<1>>時間<<2>>分で食事の効果が消えます")
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRE_MIN", "残り<<1>>分で食事の効果が消えます")
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRE_CLOSED", "食事の効果がまもなく消えます")
ZO_CreateStringId("LIO_FADR_NEAR_EXPIRED", "食事の効果が切れました！")

ZO_CreateStringId("LIO_FADR_SHOULD_EAT_DRINK", "食事の効果がありません！")

-- menus
ZO_CreateStringId("LIO_FADR_DESCRIPTION", "食事の状態を通知するアドオンです")
ZO_CreateStringId("LIO_FADR_ENABLE_TITLE", "通知を有効にする")
ZO_CreateStringId("LIO_FADR_ENABLE_TOOLTIP", "食事の状態を通知する場合はチェックしてください")
ZO_CreateStringId("LIO_FADR_NOTIFY_THRESHOLD_TITLE", "通知タイミング[分]")
ZO_CreateStringId("LIO_FADR_NOTIFY_THRESHOLD_TOOLTIP", "残り時間がこの時間未満になったら通知します")
ZO_CreateStringId("LIO_FADR_NOTIFY_IN_DUNGEON_TITLE", "ダンジョンで通知する")
ZO_CreateStringId("LIO_FADR_NOTIFY_IN_DUNGEON_TOOLTIP", "ダンジョンで食事の状態を通知する場合はチェックしてください")
ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_TO_CHAT_TITLE", "チャット欄に通知する")
ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_TO_CHAT_TOOLTIP", "チャット欄に食事の状態を通知する場合はチェックしてください")
ZO_CreateStringId("LIO_FADR_NOTIFY_BY_ZONE_CHANGING_TITLE", "ゾーン移動時に通知する")
ZO_CreateStringId("LIO_FADR_NOTIFY_BY_ZONE_CHANGING_TOOLTIP", "ゾーン移動した（旅の祠・特定のエリアへ入った、または、出た）時に食事の状態を通知する場合はチェックしてください")
ZO_CreateStringId("LIO_FADR_NOTIFY_COOLDOWN_TITLE", "通知禁止時間[秒]")
ZO_CreateStringId("LIO_FADR_NOTIFY_COOLDOWN_TOOLTIP", "前回の通知からこの時間が経過するまでは次の通知は行われません")
ZO_CreateStringId("LIO_FADR_DEBUG_TITLE", "不具合時の出力を行う")
ZO_CreateStringId("LIO_FADR_DEBUG_TOOLTIP", "不具合が発生した場合、報告のための情報を取得する場合にチェックしてください")
ZO_CreateStringId("LIO_FADR_TOP_SETTINGHEADER", "全体設定")
ZO_CreateStringId("LIO_FADR_ZONE_SETTING_HEADER", "ゾーン移動")
ZO_CreateStringId("LIO_FADR_DEBUG_SETTING_HEADER", "デバッグ用")
ZO_CreateStringId("LIO_FADR_ENABLE_NONE_TITLE", "既に効果が切れている場合に通知する")
ZO_CreateStringId("LIO_FADR_ENABLE_NONE_TOOLTIP", "ログイン直後や効果が切れた後にゾーン移動やダンジョンに出入りした時に、通知する場合にチェックしてください")

ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_ICON_TITLE", "通知アイコンを表示する")
ZO_CreateStringId("LIO_FADR_ENABLE_NOTIFY_ICON_TOOLTIP", "アイコンで通知する場合はチェックしてください")

ZO_CreateStringId("LIO_FADR_ENABLE_ACCOUNTWIDE_TITLE", "アカウント共通設定を有効にする")
ZO_CreateStringId("LIO_FADR_ENABLE_ACCOUNTWIDE_TOOLTIP", "アカウントで共通の設定を使用する場合はチェックしてください")
ZO_CreateStringId("LIO_FADR_UI_WARN", "この設定を変更するとUIの再読み込みが行われます")

-- keybinds
ZO_CreateStringId("SI_BINDING_NAME_LIO_FADR_ACTIVATE", "通知の切り替え")
