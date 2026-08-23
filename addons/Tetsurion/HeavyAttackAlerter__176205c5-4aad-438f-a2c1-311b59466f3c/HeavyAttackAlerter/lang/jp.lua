local strings = {
    SI_HAA_PANEL_NAME               = "Heavy Attack Alerter",
    SI_HAA_COMBAT_ONLY_NAME         = "戦闘中のみ表示",
    SI_HAA_COMBAT_ONLY_TIP          = "非戦闘時にシールドアイコンを非表示にします。",
    SI_HAA_SOUND_NAME               = "警告音",
    SI_HAA_SOUND_TIP                = "敵が強攻撃を開始したときのサウンド。",
    SI_HAA_SOUND_CHAMPION           = "チャイム (チャンピオンポイント)",
    SI_HAA_SOUND_DUEL               = "決闘 (決闘開始)",
    SI_HAA_SOUND_QUEST              = "勝利 (クエスト完了)",
    SI_HAA_SOUND_NONE               = "無音",
    SI_HAA_ALPHA_NAME               = "通常時の不透明度 (%)",
    SI_HAA_ALPHA_TIP                = "通常時のシールドアイコンの不透明度。",
    SI_HAA_ALERT_ALPHA_NAME         = "警告時の不透明度 (%)",
    SI_HAA_ALERT_ALPHA_TIP          = "強攻撃警告時のシールドアイコンの不透明度。",
    SI_HAA_SIZE_NAME                = "アイコンサイズ (px)",
    SI_HAA_OFFSET_X_NAME            = "水平オフセット (X)",
    SI_HAA_OFFSET_Y_NAME            = "垂直オフセット (Y)",
    SI_HAA_TEST_BUTTON_NAME         = "警告をテスト",
    SI_HAA_TEST_BUTTON_TIP          = "設定を確認するために、1.5秒間のテスト警告とサウンドを作動させます。",
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end