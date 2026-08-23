local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "カテゴリ",
    SI_QUICKEMOTEMENU_FAVORITES             = "お気に入り",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(空)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "切替",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "サブメニューホバー遅延 (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = クリック時のみ開く",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "UIモードでのみボタンを表示",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "マウスカーソルが有効なとき（UIモード）のみメインボタンを表示します。通常のゲーム/操作モードに戻ると非表示になります。",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "チャットからボタンを切り離す",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP = "ボタンをチャットウィンドウの外に移動します。ボタンを自由にドラッグして移動できます。",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "設定",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "ボタンをチャットに戻す",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "ボタンをチャットから切り離す",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "設定パネルを表示",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "エモート再生後にメニューを閉じる (左クリック)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "ボタン位置をリセット",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X         = "チャットボタンのXオフセット",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X_TOOLTIP = "チャットウィンドウのオプションボタンを基準としたボタンの水平方向のオフセットです。ボタンがチャットウィンドウに取り付けられている場合にのみ適用されます。",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FF機能|r
• カテゴリとお気に入りからエモートに素早くアクセス
• カテゴリとエモートはゲームのデータから直接読み込まれます
• ゲームに追加された新しいエモートは自動的にリストに表示されます

|c3399FF操作|r
• ボタンを左クリックでメニュー開閉
• 右クリック＆ドラッグでボタン移動
• エモートを左クリックで再生
• エモートを右クリックでお気に入り追加/削除

|c3399FFメニュー|r
• カテゴリ — カテゴリ別にエモートを閲覧
• お気に入り — 保存したエモートへ素早くアクセス
• サブメニューはホバーまたはクリックで開く (遅延設定参照)
• メニューはボタン位置に応じて上下左右に開く

|c3399FFヒント|r
• キーバインドでメニューを切替
• /qempanel でこの設定パネルを開く
• お気に入りはアカウント全体で保存
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
