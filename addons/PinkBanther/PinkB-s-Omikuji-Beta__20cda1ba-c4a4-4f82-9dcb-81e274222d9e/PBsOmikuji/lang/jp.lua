-- 日本語。lang/strings.lua のあとに読み込まれ、同じIDを上書きします。
-- 365種類のおみくじ本文は Fortunes.lua にあり、言語ファイルには含まれません。
local strings = {
	-- ---- 設定パネル --------------------------------------------------------------------
	SI_PBSOMI_EXPLANATION = "ログインしたときに、チャット欄へ今日のおみくじを一枚引きます。運勢は大吉・中吉・小吉・吉・末吉・凶・大凶の七段階、本文は一年分の全365種類で、内容はすべてタムリエルの話です。引く中身は日付と引いた人から決まるため、再ログインや /reloadui では変わりません。同じキャラクターはその日ずっと同じ運勢、別のキャラクターは別の運勢になります。",

	SI_PBSOMI_SECTION_WHEN = "いつ引くか",
	SI_PBSOMI_SECTION_WHAT = "何を表示するか",
	SI_PBSOMI_SECTION_NOW = "今日の運勢",

	SI_PBSOMI_ENABLED = "ログイン時に引く",
	SI_PBSOMI_ENABLED_TOOLTIP = "全体のオン・オフです。オフにするとログイン時には何も表示されず、/omikuji と打ったときだけ今日の運勢が出ます。",

	SI_PBSOMI_SCOPE = "運勢の単位",
	SI_PBSOMI_SCOPE_TOOLTIP = "初期値はキャラクター単位です。おみくじは引いた本人のものなので、メインが大吉の日に生産用のサブが大凶、ということが起こります。アカウント単位にすると、全キャラクターが同じ運勢になります。一日に八回引きたくない方向けです。",
	SI_PBSOMI_SCOPE_CHARACTER = "キャラクターごと",
	SI_PBSOMI_SCOPE_ACCOUNT = "アカウントごと",

	SI_PBSOMI_ONCE = "その日の最初のログインだけ",
	SI_PBSOMI_ONCE_TOOLTIP = "オンにすると、その日の二回目以降のログインでは表示しません。オフなら毎回表示します。どちらでも内容は同じ一枚です。ゾーン移動では表示しません。",

	SI_PBSOMI_DATE = "日付を表示する",
	SI_PBSOMI_DATE_TOOLTIP = "一行目に日付と曜日を入れます。サーバー時間ではなく、お使いの端末の日付です。",

	SI_PBSOMI_DRAW_NOW = "今日の運勢を表示",
	SI_PBSOMI_DRAW_NOW_TOOLTIP = "今日の運勢をもう一度チャットに出します。引き直しではありません。何度押しても同じ一枚です。",
	SI_PBSOMI_DRAW_NOW_BUTTON = "表示",

	SI_PBSOMI_RESET = "初期設定に戻す",
	SI_PBSOMI_RESET_TOOLTIP = "このパネルの設定をすべて初期値に戻し、表示済みの記録も消します。今日の運勢そのものは変わりません。記録に依存していないからです。",
	SI_PBSOMI_RESET_BUTTON = "リセット",

	-- ---- おみくじの表示 ----------------------------------------------------------------
	-- 日曜はじまり。添字で引くので、順番と七つという数は変えないこと。
	SI_PBSOMI_WEEKDAYS = "日,月,火,水,木,金,土",
	SI_PBSOMI_DATE_FORMAT = "%d年%d月%d日（%s）",
	SI_PBSOMI_HEADER_DATED = "%s、%sの運勢は……",
	SI_PBSOMI_HEADER_PLAIN = "%s、今日の運勢は……",
	SI_PBSOMI_FORTUNE_RANK = "【%s】",

	-- ---- チャット ----------------------------------------------------------------------
	SI_PBSOMI_ON = "オン",
	SI_PBSOMI_OFF = "オフ",

	SI_PBSOMI_STATUS_HEADER = "現在の設定：",
	SI_PBSOMI_STATUS_ENABLED = "ログイン時に引く：%s",
	SI_PBSOMI_STATUS_SCOPE = "運勢の単位：%s",
	SI_PBSOMI_STATUS_ONCE = "その日の最初のログインだけ：%s",
	SI_PBSOMI_STATUS_TOTAL = "収録数 %d 種類",
	SI_PBSOMI_STATUS_TODAY = "今日の一枚は %d 番（全 %d 種）",

	SI_PBSOMI_RANKS_HEADER = "運勢の段階と、それぞれの収録数：",
	SI_PBSOMI_RANKS_COUNT = "%d 種類",

	SI_PBSOMI_REPLY_SCOPE = "運勢の単位を %s にしました",
	SI_PBSOMI_REPLY_ONCE = "その日の最初のログインだけ：%s",
	SI_PBSOMI_REPLY_DATE = "日付の表示：%s",
	SI_PBSOMI_REPLY_MASTER = "ログイン時に引く：%s",
	SI_PBSOMI_REPLY_RESET = "設定を初期値に戻しました",

	SI_PBSOMI_ERROR_NO_DATA = "おみくじの本文が読み込まれていません",
	SI_PBSOMI_ERROR_SCOPE = "character か account を指定してください",
	SI_PBSOMI_ERROR_ON_OR_OFF = "on か off を指定してください",
	SI_PBSOMI_ERROR_UNKNOWN = "そのようなコマンドはありません：%s",

	-- ---- ヘルプ ------------------------------------------------------------------------
	SI_PBSOMI_HELP_HEADER = "コマンド：",
	SI_PBSOMI_HELP_DRAW = "/omikuji -- 今日の運勢をもう一度表示",
	SI_PBSOMI_HELP_STATUS = "/omikuji status -- 現在の設定",
	SI_PBSOMI_HELP_SCOPE = "/omikuji scope character | account -- 運勢の単位",
	SI_PBSOMI_HELP_ONCE = "/omikuji once on | off -- その日の最初のログインだけ表示",
	SI_PBSOMI_HELP_DATE = "/omikuji date on | off -- 一行目の日付表示",
	SI_PBSOMI_HELP_RANKS = "/omikuji ranks -- 運勢の段階と収録数",
	SI_PBSOMI_HELP_MASTER = "/omikuji on | off -- ログイン時に引くかどうか",
	SI_PBSOMI_HELP_RESET = "/omikuji reset -- 設定を初期値に戻す",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
