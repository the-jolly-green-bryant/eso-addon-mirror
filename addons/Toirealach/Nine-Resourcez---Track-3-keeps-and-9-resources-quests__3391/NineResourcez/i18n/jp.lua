NineResourcez = NineResourcez or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "ロード済み",
    NOT_LOADED = "ロードされていません",
   
    SETTINGS_GENERAL_OPTIONS_HEADER = "マップPIN設定",
    SETTINGS_SUPPRESS_MSGS_LABEL = "リソース収集とその他のメッセージを抑制する",
    SETTINGS_SUPPRESS_MSGS_DESCRIPTION = "チャット ウィンドウでのリソース収集とその他のメッセージを抑制します",
    SETTINGS_MAP_PIN_ICON_LABEL = "マップピンアイコンを選択",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "マップピンアイコンを選択",
    SETTINGS_MAP_PIN_SIZE_LABEL = "ピン サイズ",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "マップ ピンのサイズを設定します",
    SETTINGS_MAP_PIN_COLOR_LABEL = "ピンの色",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "マップピンの色を設定します",
    SETTINGS_MAP_PIN_LEVEL_LABEL = "ピンレベル",
    SETTINGS_MAP_PIN_LEVEL_DESCRIPTION = "マップ ピン レベルを設定します",
    CLICK_HANDLER_NAME = "ウェイポイントを捕捉したターゲットに設定",
    PIN_FILTER_NAME = "9 つのリソースまたは 3 つの城を占領する",
    NOW_TRACKING = "タスクを追跡中: %s",
    YOU_CAPTURED = "捕獲されました",
    QUEST_COMPLETED = "%s クエストは完了しました!",
    QUEST_ABANDONED = "%s クエストは中止されました。",
    NEITHER_QUEST = "%s も %s もクエスト ジャーナルにありません。",
}

if NineResourcez.Localization and #localization == #NineResourcez.Localization then
    ZO_ShallowTableCopy(localization, NineResourcez.Localization)
end