if GetCVar("language.2") ~= "ja" then return end
local strings = {
    SI_PBSSMS_SCENE_FAILED = "スクリーンショットモードを開始できませんでした: %s",
    SI_PBSSMS_BOTH_FAILED = "UIを非表示にできませんでした: %s",
    SI_PBSSMS_FELL_BACK = "代わりにUIを非表示にします: %s",
    SI_PBSSMS_TURNED_ON = "有効にしました。L2を押したまま十字キー左を押してください。",
    SI_PBSSMS_TURNED_OFF = "無効にしました。",
    SI_PBSSMS_MODE_SET = "動作モード: %s",
    SI_PBSSMS_ERROR_MODE = "/pbshot mode auto、scene、gui のいずれかを指定してください。",
    SI_PBSSMS_RESET = "設定を初期化しました。",
    SI_PBSSMS_ERROR_UNKNOWN = "不明なコマンド: %s。/pbshot help を参照してください。",
    SI_PBSSMS_HELP_HEADER = "ゲームパッドで通常画面のL2を押したまま十字キー左を押してください。",
    SI_PBSSMS_HELP_STATUS = "/pbshot status — 動作状態を表示",
    SI_PBSSMS_HELP_NOW = "/pbshot now — 動作確認（UI非表示中は復帰）",
    SI_PBSSMS_HELP_MODE = "/pbshot mode auto|scene|gui — 動作モードを選択",
    SI_PBSSMS_HELP_BINDS = "/pbshot binds — ボタン割り当てを確認",
    SI_PBSSMS_HELP_MASTER = "/pbshot on|off — 有効／無効",
    SI_PBSSMS_HELP_RESET = "/pbshot reset — 設定を初期化",
}
for id, value in pairs(strings) do SafeAddString(_G[id], value, 1) end
