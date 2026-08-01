-- translated by @h.metaverse
SafeAddString(SI_BINDING_NAME_TOGGLE_LIBRARIAN, "LibrarianのON/OFF")
SafeAddString(SI_BINDING_NAME_RELOAD_UI, "UIをリロード")
SafeAddString(SI_WINDOW_TITLE_LIBRARIAN, "Librarian")
SafeAddString(SI_LIBRARIAN_SORT_TYPE_UNREAD, "未読")
SafeAddString(SI_LIBRARIAN_SORT_TYPE_FOUND, "発見した日時")
SafeAddString(SI_LIBRARIAN_SORT_TYPE_TITLE, "タイトル")
SafeAddString(SI_LIBRARIAN_SORT_TYPE_WORD_COUNT, "文章量")
SafeAddString(SI_LIBRARIAN_MARK_UNREAD, "未読にする")
SafeAddString(SI_LIBRARIAN_MARK_READ, "既読にする")
SafeAddString(SI_LIBRARIAN_BOOK_COUNT, "%d 冊")
SafeAddString(SI_LIBRARIAN_UNREAD_COUNT, "%s (%d 冊未読)")
SafeAddString(SI_LIBRARIAN_SHOW_ALL_BOOKS, "全てのキャラクターの書物を見る")
SafeAddString(SI_LIBRARIAN_NEW_BOOK_FOUND, "Librarianに書物を追加")
SafeAddString(SI_LIBRARIAN_NEW_BOOK_FOUND_WITH_TITLE, "Librarianに書物を追加: %s")
SafeAddString(SI_LIBRARIAN_FULLTEXT_SEARCH, "全文検索:")
SafeAddString(SI_LIBRARIAN_SEARCH_HINT, "キーワードを入力してください。")
SafeAddString(SI_LIBRARIAN_RELOAD_REMINDER, "Librarianのデータ更新後はUIをリロードすることを推奨します.")
SafeAddString(SI_LIBRARIAN_BACKUP_REMINDER, "定期的にLibrarianのSavedVariablesのバックアップを行ってください。手順についてはESOUIのLibrarianを参照してください。")
SafeAddString(SI_LIBRARIAN_EMPTY_LIBRARY_IMPORT_PROMPT, [[あなたのLibrarianが空になります。
バグが修正されたパッチ1.3を適用するためには、アドオンデータのストレージを正しい場所に今すぐ戻す必要があります。
この移行を実行するためにLibrarian設定メニューの「パッチ前からインポートする」ボタンをクリックしてください。
この手順を実行する前にあなたのLibrarianのSavedVariablesのバックアップを行うことを推奨します。
Librarianの設定は、ウィンドウの右上の設定ボタンをクリックして開くことができます。]])

--TimeFormats Label
ZO_CreateStringId("SI_SETTING_LABEL_TIME_FORMAT_PRECISION_TWELVE_HOUR_LIBRARIAN", "12時間")
ZO_CreateStringId("SI_SETTING_LABEL_TIME_FORMAT_PRECISION_TWENTY_FOUR_HOUR_LIBRARIAN", "24時間(推奨)")

--AlertStyles Label
ZO_CreateStringId("SI_SETTING_LABEL_ALERT_STYLE_NONE_LIBRARIAN", "なし")
ZO_CreateStringId("SI_SETTING_LABEL_ALERT_STYLE_CHAT_ONLY_LIBRARIAN", "チャットのみ")
ZO_CreateStringId("SI_SETTING_LABEL_ALERT_STYLE_ALERT_ONLY_LIBRARIAN", "アラートのみ")
ZO_CreateStringId("SI_SETTING_LABEL_ALERT_STYLE_BOTH_LIBRARIAN", "両方")

--ReloadReminders Label
ZO_CreateStringId("SI_SETTING_LABEL_RELOAD_REMINDER_NEVER_LIBRARIAN", "リマインドしない")
ZO_CreateStringId("SI_SETTING_LABEL_RELOAD_REMINDER_ONE_NEW_BOOK_LIBRARIAN", "最新の1冊")
ZO_CreateStringId("SI_SETTING_LABEL_RELOAD_REMINDER_FIVE_NEW_BOOKS_LIBRARIAN", "最新の5冊")
ZO_CreateStringId("SI_SETTING_LABEL_RELOAD_REMINDER_TEN_NEW_BOOKS_LIBRARIAN", "最新の10冊")

--SettingOptions Name and Tooltip
ZO_CreateStringId("SI_SETTING_OPTION_NAME_TIME_FORMAT_LIBRARIAN", "時刻の表記の設定")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_TIME_FORMAT_LIBRARIAN", "時刻の表記を選択してください。")
ZO_CreateStringId("SI_SETTING_OPTION_NAME_ALERT_SETTINGS_LIBRARIAN", "通知の設定")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_ALERT_SETTINGS_LIBRARIAN", "通知の方法を選択してください。")
ZO_CreateStringId("SI_SETTING_OPTION_NAME_RELOAD_UI_REMINDER_LIBRARIAN", "UIをリロードした後のリマインダー設定")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_RELOAD_UI_REMINDER_LIBRARIAN", "/reloadui コマンドを実行した後、新しく発見された書物をリマインドする数を設定します。")
ZO_CreateStringId("SI_SETTING_OPTION_NAME_UNREAD_INDICATOR_LIBRARIAN", "未読アイコンの表示")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_UNREAD_INDICATOR_LIBRARIAN", "書物を開いた際に未読アイコンを表示します。")
ZO_CreateStringId("SI_SETTING_OPTION_NAME_CHARACTER_SPIN_LIBRARIAN", "キャラクターの回転")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_CHARACTER_SPIN_LIBRARIAN", "Librarianを開いた際にキャラクターがカメラの方を向くことを許可します。")
ZO_CreateStringId("SI_SETTING_OPTION_WARNING_CHARACTER_SPIN_LIBRARIAN", "自動的にUIをリロードします。")
ZO_CreateStringId("SI_SETTING_OPTION_NAME_IMPORT_LORE_LIBRARY_LIBRARIAN", "伝承の蔵書庫から取込む")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_IMPORT_LORE_LIBRARY_LIBRARIAN", "伝承の蔵書庫からまだ取り込んでいない書物を取込みます。直感記憶により一度でもロックを解除した全ての書物に対応しています。")
ZO_CreateStringId("SI_SETTING_OPTION_NAME_IMPORT_FROM_BEFORE_PATCH_LIBRARIAN", "パッチ前からインポートする")
ZO_CreateStringId("SI_SETTING_OPTION_TOOLTIP_IMPORT_FROM_BEFORE_PATCH_LIBRARIAN", "アカウント名が壊れていたパッチ1.3より前からデータを移行します。")