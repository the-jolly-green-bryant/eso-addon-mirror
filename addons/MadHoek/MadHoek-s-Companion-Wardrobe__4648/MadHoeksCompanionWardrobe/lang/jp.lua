-- STRINGS - JAPANESE:
-- lang/jp.lua

-- ==================================================
-- Panel / LAM Settings
-- ==================================================
ZO_CreateStringId("MHCWL_PANEL", "|cA02EF7MadHoek's Companion Wardrobe|r")
ZO_CreateStringId("MHCWL_PANEL_MAIN_HEADER", "全般")

ZO_CreateStringId("MHCWL_WINDOW_OPEN_WITH", "コンパニオンメニューと一緒に開く")
ZO_CreateStringId("MHCWL_WINDOW_OPEN_WITH_TOOLTIP", "コンパニオンメニューと一緒にCompanion Wardrobeのメイン画面を開きます。")
ZO_CreateStringId("MHCWL_MENU_BUTTON_OPEN_WITH", "コンパニオンメニューボタンを表示")
ZO_CreateStringId("MHCWL_MENU_BUTTON_OPEN_WITH_TOOLTIP", "コンパニオンメニュー内にCompanion Wardrobeの切り替えボタンを表示します。")

ZO_CreateStringId("MHCWL_SETTINGS_RESET_COMPANION_BUTTON_POSITION", "リセット")
ZO_CreateStringId("MHCWL_SETTINGS_RESET_COMPANION_BUTTON_POSITION_TOOLTIP", "Companion Wardrobeのコンパニオンメニューボタンを初期位置に戻します。")
ZO_CreateStringId("MHCWL_NOTIFY_COMPANION_BUTTON_POSITION_RESET", "コンパニオンメニューボタンの位置をリセットしました。")

ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE", "ツールチップモード")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_TOOLTIP", "アドオンが表示するツールチップヘルプの量を設定します。")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_OFF", "オフ")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_SIMPLE", "シンプル")
ZO_CreateStringId("MHCWL_SETTINGS_TOOLTIP_MODE_TUTORIAL", "チュートリアル")

ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR", "アクティブロードアウトの強調色")
ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_TOOLTIP", "アクティブなロードアウト選択ハイライトの色を設定します。")
ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_RESET", "リセット")
ZO_CreateStringId("MHCWL_SETTINGS_ACTIVE_HIGHLIGHT_COLOR_RESET_TOOLTIP", "アクティブロードアウトの強調色を初期値に戻します。")
ZO_CreateStringId("MHCWL_NOTIFY_ACTIVE_HIGHLIGHT_COLOR_RESET", "強調色をリセットしました。")

ZO_CreateStringId("MHCWL_ADVANCED_HEADER", "詳細")
ZO_CreateStringId("MHCWL_ADVANCED_HEADER_TOOLTIP", "詳細オプション")

ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE", "コンパニオンシルエットモード")
ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE_TOOLTIP", "インスペクト画面でCompanion Wardrobeが使用するシルエットの選び方を設定します。")
ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE_AUTO", "種族と性別で自動")
ZO_CreateStringId("MHCWL_SETTINGS_SILHOUETTE_MODE_COMPANION_ID", "既知のコンパニオン別")

-- ==================================================
-- Debug Settings
-- ==================================================
ZO_CreateStringId("MHCWL_DEBUG_HEADER", "デバッグ")
ZO_CreateStringId("MHCWL_DEBUG_HEADER_TOOLTIP", "デバッグオプション")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MODE", "デバッグモードを有効化")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MODE_TOOLTIP", "開発者用スラッシュコマンドとデバッグメッセージをチャットに表示します。")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MESSAGES", "デバッグメッセージを有効化")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_MESSAGES_TOOLTIP", "自動デバッグメッセージをチャットに表示します。")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_FORCE_LOCKED", "コンパニオンスキルをロック扱いにする")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_FORCE_LOCKED_TOOLTIP", "デバッグ専用。警告テスト用にコンパニオンスキルをロック済みとして扱います。")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_SLOT7_ULTIMATE", "スキルスロット7をアルティメットに表示")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_SLOT7_ULTIMATE_TOOLTIP", "デバッグ専用。インスペクト表示テスト用にコンパニオンのスキルスロット7をアルティメット枠に表示します。")

ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_TIMINGS", "タイミング安全バッファ")
ZO_CreateStringId("MHCWL_SETTINGS_DEBUG_TIMINGS_TOOLTIP", "キュー処理されるアドオン操作に追加のミリ秒を加えます。装備の読み込みや自動取得が不安定な場合に増やしてください。")

-- ==================================================
-- Color Settings / Profiles
-- ==================================================
ZO_CreateStringId("MHCWL_COLORS_HEADER", "色")
ZO_CreateStringId("MHCWL_COLORS_HEADER_TOOLTIP", "色設定")

ZO_CreateStringId("MHCWL_SETTINGS_LOADOUT_COLOR_HEADER", "ロードアウトカラー")
ZO_CreateStringId("MHCWL_SETTINGS_LOADOUT_COLOR_HEADER_TOOLTIP", "ロードアウトの色と表示設定")

ZO_CreateStringId("MHCWL_COLOR_PROFILE", "カラープロファイル")
ZO_CreateStringId("MHCWL_COLOR_PROFILE_STANDARD", "標準")
ZO_CreateStringId("MHCWL_COLOR_PROFILE_ROLE", "ロール")
ZO_CreateStringId("MHCWL_COLOR_PROFILE_CUSTOM", "カスタム")

ZO_CreateStringId("MHCWL_COLOR_PROFILE_TOOLTIP", "ロードアウトのカラープロファイルを選択します。「標準」と「ロール」は切り替え時にプロファイル色をリセットします。「カスタム」は独自の名前と色を保持します。")

ZO_CreateStringId("MHCWL_COLOR_SLOT_ENABLED", "有効")
ZO_CreateStringId("MHCWL_COLOR_SLOT_NAME", "名前")
ZO_CreateStringId("MHCWL_COLOR_SLOT_COLOR", "色")

ZO_CreateStringId("MHCWL_COLOR_USE_FOR_FAVORITES", "お気に入りに色を使用")

ZO_CreateStringId("MHCWL_COLOR_DEFAULT", "標準")
ZO_CreateStringId("MHCWL_COLOR_RED", "赤")
ZO_CreateStringId("MHCWL_COLOR_ORANGE", "オレンジ")
ZO_CreateStringId("MHCWL_COLOR_YELLOW", "黄")
ZO_CreateStringId("MHCWL_COLOR_GREEN", "緑")
ZO_CreateStringId("MHCWL_COLOR_BLUE", "青")
ZO_CreateStringId("MHCWL_COLOR_PURPLE", "紫")
ZO_CreateStringId("MHCWL_COLOR_CUSTOM", "カスタム")
ZO_CreateStringId("MHCWL_COLOR_COLOR", "色")

ZO_CreateStringId("MHCWL_COLOR_ROLE_TANK", "タンク")
ZO_CreateStringId("MHCWL_COLOR_ROLE_HEALER", "ヒーラー")
ZO_CreateStringId("MHCWL_COLOR_ROLE_DPS", "DPS")
ZO_CreateStringId("MHCWL_COLOR_ROLE_SUPPORT", "サポート")

-- ==================================================
-- Generic UI / Windows
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_MAIN_TITLE", "Companion Wardrobe")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_TITLE", "オプション")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_TITLE", "ロードアウト確認")
ZO_CreateStringId("MHCWL_WINDOW_RENAME_TITLE", "ロードアウト名変更")
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_TITLE", "ロードアウト書き出し")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_TITLE", "ロードアウト読み込み")

ZO_CreateStringId("MHCWL_LOADOUT", "ロードアウト ")
ZO_CreateStringId("MHCWL_RENAME_TEXT", "新しい名前を入力:")
ZO_CreateStringId("MHCWL_EMPTY_MARKER", " |c888888(空)|r")
ZO_CreateStringId("MHCWL_UNKNOWN", "不明")

ZO_CreateStringId("MHCWL_PAGE_LABEL", "ページ <<1>>/<<2>>")

-- ==================================================
-- Main Window Actions
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_GEAR", "装備を保存")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_SKILLS", "スキルを保存")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_GEAR", "装備を読み込み")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_SKILLS", "スキルを読み込み")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT", "インポート")

-- ==================================================
-- Buttons / Basic Tooltips
-- ==================================================
ZO_CreateStringId("MHCWL_BUTTON_LOCK", "ロック")
ZO_CreateStringId("MHCWL_BUTTON_UNLOCK", "ロック解除")
ZO_CreateStringId("MHCWL_BUTTON_FAVORITE", "お気に入り")
ZO_CreateStringId("MHCWL_BUTTON_UNFAVORITE", "お気に入り解除")

ZO_CreateStringId("MHCWL_TOOLTIP_CLOSE", "閉じる")
ZO_CreateStringId("MHCWL_TOOLTIP_SETTINGS", "設定")
ZO_CreateStringId("MHCWL_TOOLTIP_ACTIVE", "有効")
ZO_CreateStringId("MHCWL_TOOLTIP_SELECT", "選択")
ZO_CreateStringId("MHCWL_TOOLTIP_SAVE", "保存")
ZO_CreateStringId("MHCWL_TOOLTIP_RENAME", "名前変更")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT", "確認")
ZO_CreateStringId("MHCWL_TOOLTIP_DELETE", "削除")
ZO_CreateStringId("MHCWL_TOOLTIP_ADD", "追加")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_PREVIOUS", "前へ")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_NEXT", "次へ")

ZO_CreateStringId("MHCWL_TOOLTIP_EMPTY_GEAR", "空")
ZO_CreateStringId("MHCWL_TOOLTIP_EMPTY_SKILL", "空")
ZO_CreateStringId("MHCWL_TOOLTIP_LOCKED_LEVEL", "ロック中\nコンパニオンレベル <<1>> で解除")

ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_NORMAL_LOADOUTS", "通常を非表示")
ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_NORMAL_LOADOUTS", "通常を表示")
ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_FAVORITE_LOADOUTS", "お気に入りを非表示")
ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_FAVORITE_LOADOUTS", "お気に入りを表示")

ZO_CreateStringId("MHCWL_TOOLTIP_QUEUE_MISSING_GEAR_FETCH", "クリックして不足装備を銀行取得キューに追加します。")

-- ==================================================
-- Sorting
-- ==================================================
ZO_CreateStringId("MHCWL_SORTING_PREFIX", "並び順: ")

ZO_CreateStringId("MHCWL_SORT_MODE_SLOT_ORDER", "スロット順")
ZO_CreateStringId("MHCWL_SORT_MODE_ALL_AZ", "すべて A-Z")
ZO_CreateStringId("MHCWL_SORT_MODE_FAVORITES_AZ", "お気に入り A-Z")
ZO_CreateStringId("MHCWL_SORT_MODE_FAVORITES_SLOT", "お気に入りスロット")

-- ==================================================
-- Inspect Window
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_GEAR_HEADER", "装備")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_SKILLS_HEADER", "スキル")

ZO_CreateStringId("MHCWL_WINDOW_INSPECT_SKILL_SLOTNAME", "スロット ")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_SKILL_ULTIMATE_SLOTNAME", "アルティメット")

ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_ACTIVE", "読み込み")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_ACQUIRE_GEAR", "装備を取得")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_STORE_GEAR", "装備を保管")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_RENAME", "名前変更")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_DUPLICATE", "複製")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_EXPORT", "エクスポート")
ZO_CreateStringId("MHCWL_WINDOW_INSPECT_DROPDOWN_IMPORT", "インポート")

ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SWITCH_VIEW", "表示/テキスト切替")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_ARMOR", "防具")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_WEAPONS", "装身具・武器")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SKILLS", "スキル")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_COLOR", "ロードアウト名の色を変更")

ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACTIVE", "読み込み")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACQUIRE_GEAR", "装備取得")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_STORE_GEAR", "装備保管")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_RENAME", "名前変更")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_DUPLICATE", "複製")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_EXPORT", "エクスポート")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_IMPORT", "インポート")

-- ==================================================
-- Inspect Text View
-- ==================================================
ZO_CreateStringId("MHCWL_INSPECT_TEXT_EMPTY", "空")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_GEAR", "装備")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_LIGHT", "軽装")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_MEDIUM", "中装")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_HEAVY", "重装")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_NECKLACE", "ネックレス")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_RING", "指輪")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_NO_TRAIT", "特性なし")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_UNKNOWN", "不明")

ZO_CreateStringId("MHCWL_INSPECT_TEXT_ARMOR_HEADER", "防具")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_JEWELRY_HEADER", "装身具")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_WEAPONS_HEADER", "武器")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_SKILLS_HEADER", "スキル")

ZO_CreateStringId("MHCWL_INSPECT_TEXT_BLOCKED", "無効 - ")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_TWO_HANDED_WEAPON", "両手武器")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_WEAPON_DAMAGE", "<<1>> / ダメージ: <<2>>")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_SKILL_BASE_VALUES", "基本値: 詠唱 <<1>> / 対象 <<2>> / 持続 <<3>> / CD <<4>>")

ZO_CreateStringId("MHCWL_INSPECT_TEXT_WEAPON", "武器")
ZO_CreateStringId("MHCWL_INSPECT_TEXT_TRAIT", "特性")

-- ==================================================
-- Import / Export Windows
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_INFO", "下のエクスポート文字列をコピー:")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_INFO", "下にインポート文字列を貼り付け:")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_INFO_OVERWRITE", "下にインポート文字列を貼り付けます。現在のロードアウトを上書きします。")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_INFO_CREATE", "下にインポート文字列を貼り付けます。新しいロードアウトを作成します。")

ZO_CreateStringId("MHCWL_WINDOW_IMPORT_BUTTON", "インポート")
ZO_CreateStringId("MHCWL_WINDOW_IMPORT_BUTTON_TOOLTIP", "インポート")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_GEAR", "装備")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_GEAR_TOOLTIP", "装備のみエクスポート")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_GEAR_TOOLTIP_TUTORIAL", "装備をエクスポート\n\nこのロードアウトに保存されたコンパニオン装備のみをエクスポートします。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS", "スキル")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS_TOOLTIP", "スキルのみエクスポート")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_EXPORT_SKILLS_TOOLTIP_TUTORIAL", "スキルをエクスポート\n\nこのロードアウトに保存されたコンパニオンスキルのみをエクスポートします。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_GEAR", "装備")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_GEAR_TOOLTIP", "装備のみインポート")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_GEAR_TOOLTIP_TUTORIAL", "装備をインポート\n\n貼り付けたロードアウトから保存済みコンパニオン装備のみをインポートします。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS", "スキル")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS_TOOLTIP", "スキルのみインポート")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_SKILLS_TOOLTIP_TUTORIAL", "スキルをインポート\n\n貼り付けたロードアウトから保存済みコンパニオンスキルのみをインポートします。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE", "お気に入り")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE_TOOLTIP", "お気に入りとしてインポート")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_FAVORITE_TOOLTIP_TUTORIAL", "お気に入りとしてインポート\n\nインポートしたロードアウトをお気に入りに設定します。")

ZO_CreateStringId("MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL", "選択")
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL_TOOLTIP", "すべて選択")
ZO_CreateStringId("MHCWL_WINDOW_EXPORT_DIALOG_SELECT_ALL_TOOLTIP_TUTORIAL", "すべて選択\n\nエクスポート文字列全体を選択してコピーできるようにします。")

ZO_CreateStringId("MHCWL_EXPORTED_LOADOUT", "エクスポート済みロードアウト")
ZO_CreateStringId("MHCWL_IMPORTED_LOADOUT", "インポート済みロードアウト")

-- ==================================================
-- Notifications / Generic Loadout Actions
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_LOCKED", "ロードアウトはロックされています。")
ZO_CreateStringId("MHCWL_NOTIFY_SAVED", "保存: ")
ZO_CreateStringId("MHCWL_NOTIFY_SAVED_GEAR", "装備のみ保存: ")
ZO_CreateStringId("MHCWL_NOTIFY_SAVED_SKILLS", "スキルのみ保存: ")
ZO_CreateStringId("MHCWL_NOTIFY_DUPLICATED", "複製: ")

-- ==================================================
-- Notifications / Import / Export
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_EMPTY", "インポート文字列が空です。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_PARSE_FAILED", "インポートの解析に失敗しました。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_FORMAT_INVALID", "無効なインポート形式です。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_DATA_INVALID", "インポートデータが無効です。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_INVALID_SCHEMA", "未対応のインポートスキーマです。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_INVALID_VERSION", "未対応のインポートバージョンです。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_INVALID_TARGET", "無効なインポート先です。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_NO_DATA_LOADOUT", "インポートにロードアウトデータがありません。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_NO_ACTIVE_COMPANION", "アクティブなコンパニオンがいません。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_MAX_LOADOUT_COUNT", "ロードアウト数が上限に達しています。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_WRONG_COMPANION", "このロードアウトは別のコンパニオン用です。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORT_FAILED", "インポートに失敗しました。")
ZO_CreateStringId("MHCWL_NOTIFY_IMPORTED", "インポート: ")

ZO_CreateStringId("MHCWL_NOTIFY_EXPORT_SELECTED", "エクスポート文字列を選択しました。Ctrl+Cでコピーしてください。")
ZO_CreateStringId("MHCWL_NOTIFY_EXPORT_FAILED", "エクスポートに失敗しました。")

-- ==================================================
-- Notifications / Gear Fetch
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_NO_MISSING_GEAR", "不足している装備はありません。")
ZO_CreateStringId("MHCWL_NOTIFY_NO_FETCHABLE_GEAR", "取得可能な装備が見つかりません。")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_QUEUED", "装備取得をキューに追加しました。銀行を開いてください。")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_CANCELED_EMPTY", "装備取得をキャンセルしました: キューが空です。")

ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_COMPLETE_MOVED", "装備取得完了。移動: ")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_MOVED", "移動: ")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_FETCH_MISSING", " 不足: ")
ZO_CreateStringId("MHCWL_NOTIFY_BACKPACK_FULL_COULD_NOT_MOVE", " 所持品が満杯のため移動できません: ")

-- ==================================================
-- Notifications / Gear Store
-- ==================================================
ZO_CreateStringId("MHCWL_NOTIFY_BANK_NOT_OPEN", "銀行が開いていません。")
ZO_CreateStringId("MHCWL_NOTIFY_OPEN_BANK_TO_STORE", "装備を保管するには銀行を開いてください。")
ZO_CreateStringId("MHCWL_NOTIFY_BANK_FULL", "銀行が満杯です。")
ZO_CreateStringId("MHCWL_NOTIFY_NO_STORABLE_GEAR", "保管可能な装備が見つかりません。")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_QUEUED", "装備保管をキューに追加しました。銀行を開いてください。")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_CANCELED_EMPTY", "装備保管をキャンセルしました: キューが空です。")

ZO_CreateStringId("MHCWL_NOTIFY_STORED_COMPANION_GEAR", "コンパニオン装備を保管: ")
ZO_CreateStringId("MHCWL_NOTIFY_STORED_GEAR", "装備を保管: ")

ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_COMPLETE_MOVED", "装備保管完了。移動: ")
ZO_CreateStringId("MHCWL_NOTIFY_GEAR_STORE_MOVED", "移動: ")
ZO_CreateStringId("MHCWL_NOTIFY_BANK_FULL_COULD_NOT_MOVE", " 銀行が満杯のため移動できません: ")

ZO_CreateStringId("MHCWL_NOTIFY_ITEM_SINGULAR", "個")
ZO_CreateStringId("MHCWL_NOTIFY_ITEM_PLURAL", "個")

-- ==================================================
-- Warnings
-- ==================================================
ZO_CreateStringId("MHCWL_WARNING_TOOLTIP_TITLE", "ロードアウト警告")
ZO_CreateStringId("MHCWL_WARNING_MISSING_GEAR", "不足している装備:")
ZO_CreateStringId("MHCWL_WARNING_LOCKED_SKILL_SLOTS", "ロックされたスキルスロット:")
ZO_CreateStringId("MHCWL_WARNING_INVALID_SKILLS", "無効な保存済みスキル:")
ZO_CreateStringId("MHCWL_WARNING_LOCKED_SKILL_LINES", "ロックされたスキルライン")

-- ==================================================
-- Tutorial Tooltips / Main Window
-- ==================================================
ZO_CreateStringId("MHCWL_TOOLTIP_SAVE_TUTORIAL", "ロードアウトを保存")
ZO_CreateStringId("MHCWL_TOOLTIP_RENAME_TUTORIAL", "ロードアウト名変更")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_TUTORIAL", "ロードアウト確認")
ZO_CreateStringId("MHCWL_TOOLTIP_DELETE_TUTORIAL", "ロードアウト削除")
ZO_CreateStringId("MHCWL_TOOLTIP_ADD_TUTORIAL", "ロードアウト追加")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_PREVIOUS_TUTORIAL", "前のページ")
ZO_CreateStringId("MHCWL_TOOLTIP_PAGE_NEXT_TUTORIAL", "次のページ")

ZO_CreateStringId("MHCWL_BUTTON_FAVORITE_TUTORIAL", "お気に入りに追加")
ZO_CreateStringId("MHCWL_BUTTON_UNFAVORITE_TUTORIAL", "お気に入りから削除")
ZO_CreateStringId("MHCWL_BUTTON_LOCK_TUTORIAL", "ロードアウトをロック")
ZO_CreateStringId("MHCWL_BUTTON_UNLOCK_TUTORIAL", "ロードアウトのロック解除")

ZO_CreateStringId("MHCWL_TOOLTIP_SORT_TUTORIAL", "ロードアウトを並び替え")
ZO_CreateStringId("MHCWL_TOOLTIP_SORT_CURRENT_MODE", "現在のモード:")
ZO_CreateStringId("MHCWL_TOOLTIP_SORT_CHANGE_TUTORIAL", "クリックして並び順を変更します。")

ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_FAVORITES_TUTORIAL", "お気に入りロードアウトを表示")
ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_FAVORITES_TUTORIAL", "お気に入りロードアウトを非表示")
ZO_CreateStringId("MHCWL_TOOLTIP_FAVORITES_FILTER_TUTORIAL", "お気に入りロードアウトの表示を切り替えます。")

ZO_CreateStringId("MHCWL_TOOLTIP_SHOW_NORMAL_TUTORIAL", "通常ロードアウトを表示")
ZO_CreateStringId("MHCWL_TOOLTIP_HIDE_NORMAL_TUTORIAL", "通常ロードアウトを非表示")
ZO_CreateStringId("MHCWL_TOOLTIP_NORMAL_FILTER_TUTORIAL", "通常ロードアウトの表示を切り替えます。")

ZO_CreateStringId("MHCWL_TOOLTIP_SETTINGS_TUTORIAL", "設定\n\nロードアウトオプションを開きます。")
ZO_CreateStringId("MHCWL_TOOLTIP_CLOSE_TUTORIAL", "ウィンドウを閉じる\n\nCompanion Wardrobeウィンドウを非表示にします。")

-- ==================================================
-- Tutorial Tooltips / Options Dropdown
-- ==================================================
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_GEAR_TOOLTIP", "装備を保存")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_GEAR_TOOLTIP_TUTORIAL", "装備を保存\n\nロードアウト保存時に現在装備中のコンパニオン装備を含めます。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_SKILLS_TOOLTIP", "スキルを保存")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_SAVE_SKILLS_TOOLTIP_TUTORIAL", "スキルを保存\n\nロードアウト保存時に現在スロットに設定されているコンパニオンスキルを含めます。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_GEAR_TOOLTIP", "装備を読み込み")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_GEAR_TOOLTIP_TUTORIAL", "装備を読み込み\n\nロードアウト読み込み時に保存済みコンパニオン装備を装備します。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_SKILLS_TOOLTIP", "スキルを読み込み")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_LOAD_SKILLS_TOOLTIP_TUTORIAL", "スキルを読み込み\n\nロードアウト読み込み時に保存済みコンパニオンスキルをスロットに設定します。")

ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_TOOLTIP", "インポート")
ZO_CreateStringId("MHCWL_WINDOW_OPTIONS_IMPORT_TOOLTIP_TUTORIAL", "ロードアウトをインポート\n\n共有されたロードアウトを貼り付けて新しいロードアウトとして取り込むためのインポート画面を開きます。")

ZO_CreateStringId("MHCWL_WINDOW_IMPORT_BUTTON_TOOLTIP_TUTORIAL", "ロードアウトをインポート\n\n貼り付けたロードアウトを選択中のスロットへインポートします。")

-- ==================================================
-- Tutorial Tooltips / Inspect Window
-- ==================================================
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACTIVE_TUTORIAL", "ロードアウトを読み込み\n\nこのロードアウトを有効化し、コンパニオンに適用します。")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_ACQUIRE_GEAR_TUTORIAL", "不足装備を取得\n\n不足している保存済み装備を銀行取得キューに追加します。")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_STORE_GEAR_TUTORIAL", "装備を保管\n\nこのロードアウトの装備をインベントリから銀行へ移動します。")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_RENAME_TUTORIAL", "ロードアウト名変更\n\nこのロードアウトの名前を変更します。")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_DUPLICATE_TUTORIAL", "ロードアウトを複製\n\nこのロードアウトのコピーを作成します。")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_EXPORT_TUTORIAL", "ロードアウトをエクスポート\n\n共有やバックアップ用にエクスポート画面を開きます。")
ZO_CreateStringId("MHCWL_INSPECT_TOOLTIP_IMPORT_TUTORIAL", "ロードアウトをインポート\n\n貼り付けたインポートデータでこのロードアウトを上書きします。")

ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SWITCH_VIEW_TUTORIAL", "表示切替\n\nグラフィック表示とテキスト表示を切り替えます。")

ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_ARMOR_TUTORIAL", "防具表示\n\n保存済みの防具と装身具をテキストで表示します。")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_WEAPONS_TUTORIAL", "武器表示\n\n保存済みの武器をテキストで表示します。")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_SKILLS_TUTORIAL", "スキル表示\n\n保存済みのコンパニオンスキルをテキストで表示します。")
ZO_CreateStringId("MHCWL_TOOLTIP_INSPECT_COLOR_TUTORIAL", "ロードアウト色\n\nこのロードアウトに色カテゴリを割り当てます。")

-- ==================================================
-- Keybindings
-- ==================================================
ZO_CreateStringId("SI_BINDING_NAME_MHCWL_WINDOW_TOGGLE", "Companion Wardrobe の表示切替")