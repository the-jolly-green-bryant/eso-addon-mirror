-- 日本語。lang/strings.lua のあとに読み込まれ、同じIDを上書きします。
local strings = {
	-- ---- 作成画面の状態 ----------------------------------------------------------------
	SI_PBSMX_WHERE_KEYBOARD = "メール作成画面が開いています（キーボードUI）。",
	SI_PBSMX_WHERE_GAMEPAD = "メール作成画面が開いています（ゲームパッドUI）。",
	SI_PBSMX_WHERE_CLOSED = "メール作成画面が開いていません。メールを開き、送信（作成）タブに移動してください。",

	-- ---- 保存と復元 --------------------------------------------------------------------
	SI_PBSMX_SAVED = "下書き %s として保存しました -- %s",
	SI_PBSMX_LOADED = "%s %s を作成画面に戻しました。内容を確認してから送信してください。",
	SI_PBSMX_DELETED = "%s %s を削除しました -- %s",
	SI_PBSMX_DELETED_ALL = "%s を %d 件削除しました。",

	SI_PBSMX_LIST_EMPTY = "保存されている下書きはありません。",
	SI_PBSMX_LIST_HEADER = "%s %d 件（上限 %d 件）:",

	SI_PBSMX_DESCRIBE = "%s → %s",
	SI_PBSMX_DESCRIBE_ITEMS = "添付 %d 個",
	SI_PBSMX_DESCRIBE_GOLD = "%sG",
	SI_PBSMX_DESCRIBE_COD = "代金引換 %sG",
	SI_PBSMX_NO_SUBJECT = "（件名なし）",
	SI_PBSMX_NO_ADDRESSEE = "（宛先なし）",

	-- ---- 戻せなかったもの --------------------------------------------------------------
	SI_PBSMX_NOTE_ITEM_GONE = "%s はバックパックに見つからないため、添付していません。",
	SI_PBSMX_NOTE_NOT_ATTACHED = "%s を添付できませんでした: %s",
	SI_PBSMX_NOTE_UNNAMED_ITEM = "アイテム",
	SI_PBSMX_NOTE_COD = "この下書きには代金引換 %sG が設定されていました。金額欄は1つしかなく、それが「添付ゴールド」か「代金引換」かはラジオボタンが決めるため、こちらでは設定していません。手動で設定してください。",
	SI_PBSMX_NOTE_GOLD_NOT_SET = "画面が代金引換モードのため、下書きの添付ゴールド %sG は戻していません。",

	-- ---- できないとき ------------------------------------------------------------------
	SI_PBSMX_ERROR_NOT_OPEN = "メール作成画面が開いていないため、読み書きできません。メールを開き、送信（作成）タブに移動してください。",
	SI_PBSMX_ERROR_NOT_LOADED = "保存データがまだ準備できていません。",
	SI_PBSMX_ERROR_BLANK = "作成画面が空です。保存するものがありません。",
	SI_PBSMX_ERROR_FULL = "%s は %d 件保存されており、上限は %d 件です。どれか削除するか、設定画面か /pbmail max で上限を上げてください。",
	SI_PBSMX_ERROR_NEED_NUMBER = "どの下書きですか？ /pbmail list の番号を指定してください。",
	SI_PBSMX_ERROR_NO_SUCH = "%s %s は存在しません。一覧で確認してください。",
	SI_PBSMX_NOUN_DRAFT = "下書き",
	SI_PBSMX_NOUN_SENT = "送信済み",
	SI_PBSMX_ERROR_UNKNOWN = "コマンド '%s' は知りません。",

	-- ---- ヘルプ ------------------------------------------------------------------------
	SI_PBSMX_HELP_SAVE = "/pbmail save [名前] -- 作成画面の内容を下書きとして保存",
	SI_PBSMX_HELP_LIST = "/pbmail list -- 下書き一覧（番号付き）",
	SI_PBSMX_HELP_LOAD = "/pbmail load <n> -- 下書き n を作成画面に戻す（送信は自分で押します）",
	SI_PBSMX_HELP_DELETE = "/pbmail delete <n> | all -- 下書きを削除",
	SI_PBSMX_HELP_WHERE = "/pbmail where -- いま作成画面を認識できているか表示",

	-- ---- メール画面のボックス ----------------------------------------------------------
	SI_PBSMX_TAB_DRAFTS = "下書き",
	SI_PBSMX_TAB_DRAFTS_COUNT = "%s (%d)",
	SI_PBSMX_SAVE_ENTRY = "下書きに保存",
	SI_PBSMX_KEYBIND_LOAD = "作成画面に戻す",
	SI_PBSMX_KEYBIND_DELETE = "削除",
	SI_PBSMX_PAGE_PREVIOUS = "前へ",
	SI_PBSMX_PAGE_NEXT = "次へ",
	SI_PBSMX_PAGE_OF = "%d / %d ページ",

	SI_PBSMX_PREVIEW_TO = "宛先: %s",
	SI_PBSMX_PREVIEW_SUBJECT = "件名: %s",
	SI_PBSMX_PREVIEW_NO_BODY = "（本文なし）",
	SI_PBSMX_PREVIEW_ATTACHMENTS = "添付 (%d):",

	SI_PBSMX_DELETE_TITLE = "この下書きを削除しますか？",
	SI_PBSMX_DELETE_PROMPT = "<<1>>\n\n元に戻せません。",

	-- ---- チャットが出ていないときのために、画面に出す一言 ------------------------------
	SI_PBSMX_ALERT_SAVED = "下書き %s として保存しました",
	SI_PBSMX_ALERT_LOADED = "下書きを作成画面に戻しました",
	SI_PBSMX_ALERT_LOADED_WITH_NOTES = "作成画面に戻しました -- %d 件戻せないものがあります（チャット参照）",
	SI_PBSMX_ALERT_DELETED = "下書きを削除しました",
	SI_PBSMX_ERROR_NO_DIALOG = "確認ダイアログが使えないため、削除していません。/pbmail delete <n> をお使いください。",

	SI_PBSMX_WHERE_TABS = "下書きタブ -- キーボード: %s, ゲームパッド: %s",
	SI_PBSMX_YES = "有効",
	SI_PBSMX_NO = "無効",

	-- ---- 送信済みボックス ---------------------------------------------------------------
	SI_PBSMX_TAB_SENT = "送信済み",
	SI_PBSMX_SENT_EMPTY = "送信済みの記録はまだありません。送信したメールはこのアドオンが送信時に記録します（ゲーム側は送信控えを保持していないため、このアドオンを入れる前に送ったものは表示できません）。",
	SI_PBSMX_HELP_SENT = "/pbmail sent [load <n> | delete <n> | all] -- 送信済み一覧、作成画面に戻す、削除",

	-- ---- 保存件数の上限 ----------------------------------------------------------------
	SI_PBSMX_EXPLANATION = "メール画面にない2つのボックス（書きかけと送信済み）を追加します。どちらもメール画面のタブとして表示され、同じ操作は /pbmail からも行えます。",
	SI_PBSMX_SECTION_LIMITS = "保存する件数",

	SI_PBSMX_LIMIT_DRAFTS = "下書きの保存件数",
	SI_PBSMX_LIMIT_DRAFTS_TOOLTIP = "下書きを何件まで保存するか。上限に達した場合は保存を断ります（古いものを捨てることはありません。下書きは残すと決めたものなので）。この値を下げても既存の下書きは消えません。上限を下回るまで新規保存ができなくなるだけです。端数を指定したい場合は /pbmail max drafts <n> を使ってください。",

	SI_PBSMX_LIMIT_SENT = "送信済みの記録件数",
	SI_PBSMX_LIMIT_SENT_TOOLTIP = "送信済みを何件まで記録するか。上限に達すると、新しい1件が入るときに最も古い1件を捨てます（記録を止めてしまってはログの意味がないため）。この値を下げてもすぐには消えません。次に送信したときに新しい件数まで整理されます。端数を指定したい場合は /pbmail max sent <n> を使ってください。",

	SI_PBSMX_LIMIT_STATUS = "%s: %d 件保存中、上限 %d 件",
	SI_PBSMX_LIMIT_SET = "%s: 上限を %d 件にしました。",
	SI_PBSMX_LIMIT_OVER_ROLLING = "現在 %d 件あり、上限を超えています。今は何も削除していません。次に送信したときに %d 件まで整理されます。",
	SI_PBSMX_LIMIT_OVER_KEPT = "現在 %d 件あり、上限を超えています。何も削除していません。%d 件を下回るまで新規保存はできません。",
	SI_PBSMX_ERROR_WHICH_BOX = "どちらのボックスですか？ /pbmail max drafts <n> または /pbmail max sent <n>",
	SI_PBSMX_ERROR_NEED_LIMIT = "件数を指定してください（%d 〜 %d）。",
	SI_PBSMX_HELP_MAX = "/pbmail max [drafts | sent] <n> -- 各ボックスの保存件数",

	SI_PBSMX_GO_TO_SEND = "作成画面に入れました。送信タブに切り替えて、内容を確認してから送信してください。",
	SI_PBSMX_ALERT_GO_TO_SEND = "送信タブに切り替えてください",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
