Vampz = Vampz or {}

local localization = {

    LOADED_STR = "%s %s %s",
    WAS_LOADED = "ロード済み",
    NOT_LOADED = "ロードされていません",
    NAME_SUPPRESS = "アドオンが読み込まれたメッセージを抑制する",
    TOOLTIP_SUPPRESS = "アドオンが正常にロードされたことを伝えるチャット ウィンドウのメッセージを非表示にします。",
    SETTINGS_GENERAL_OPTIONS_HEADER = "マップPIN設定",
    SETTINGS_MAP_PIN_ICON_LABEL = "マップピンアイコンを選択",
    SETTINGS_MAP_PIN_ICON_DESCRIPTION = "マップピンアイコンを選択",
    SETTINGS_MAP_PIN_SIZE_LABEL = "ピン サイズ",
    SETTINGS_MAP_PIN_SIZE_DESCRIPTION = "マップ ピンのサイズを設定します",
    SETTINGS_MAP_PIN_COLOR_LABEL = "ピンの色",
    SETTINGS_MAP_PIN_COLOR_DESCRIPTION = "マップピンの色を設定します",
    SETTINGS_CLICKABLE_LABEL = "Vampz マップのピンをクリックするとウェイポイントを設定します",
    SETTINGS_CLICKABLE_DESCRIPTION = "地図上にウェイポイントを配置するために地図のピンをクリックすることを許可しますか?",
    CLICK_HANDLER_NAME = "ウェイポイントを吸血鬼の餌場に設定",
    PIN_FILTER_NAME = "吸血鬼の餌場",
}

if Vampz.Localization and #localization == #Vampz.Localization then
    ZO_ShallowTableCopy(localization, Vampz.Localization)
end