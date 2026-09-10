-- 日本語。lang/strings.lua のあとに読み込まれ、同じIDを上書きします。
-- ロール結果の一行目はこのアドオンの文字列ではなく、クライアント本体の
-- SI_RANDOM_ROLL_DICE_RESULT（「◯◯が40をロール(3 x 20面)。」）を使います。本物のロールと
-- 同じ文になるのが目的なので、翻訳もクライアント側のものをそのまま使うのが正しい。
local strings = {
	-- ---- 設定パネル --------------------------------------------------------------------
	SI_PBSDICE_EXPLANATION = "チャット画面の「ランダムロール」は引数なしの /roll です。つまり毎回 1〜100 の一個振りしかできません。このアドオンでは振るダイスをここで決めておけます。個数は最大10個、出目は最大1000面まで。/pbdice か、このパネル下部のボタンで振れます。ただしアドオンが振ったダイスは自分のチャットにしか出ません（他の人には見えません）。パーティ全員に見せたい場合は、ゲーム本体に振ってもらう必要があります。最後の設定をオンにすると、チャット画面を開いた時点で入力欄に対応する /roll コマンドが入っているので、送信を押すだけで本物のロールになります。",

	SI_PBSDICE_SECTION_DICE = "ダイス",
	SI_PBSDICE_SECTION_HOW = "振り方",
	SI_PBSDICE_SECTION_OUTPUT = "表示",
	SI_PBSDICE_SECTION_REAL = "全員に見えるロール",
	SI_PBSDICE_SECTION_NOW = "振る",

	SI_PBSDICE_COUNT = "ダイスの個数",
	SI_PBSDICE_COUNT_TOOLTIP = "1〜10個。各ダイスを個別に振り、合計を結果として表示します。3d20 が昔からそういう意味であるのと同じです。",

	SI_PBSDICE_SIDES = "ダイスの面数",
	SI_PBSDICE_SIDES_TOOLTIP = "2〜1000面。100面はチャット画面の「ランダムロール」と同じ値なので、1個×100面は今お使いのロールそのものです。",

	SI_PBSDICE_EACH = "各ダイスの出目を表示",
	SI_PBSDICE_EACH_TOOLTIP = "各ダイスが何を出したかと、その合計を二行目に表示します。1個のときは内訳がないので表示しません。これはゲーム本体のロールにはできないことです（本体は合計しか教えてくれません）。",

	SI_PBSDICE_TAG = "自分にしか見えないロールに印を付ける",
	SI_PBSDICE_TAG_TOOLTIP = "このアドオンが振ったロールの末尾に、目立たない印を付けます。見た目が本物のロールとまったく同じなのに、実際には誰にも見えていないためです。どちらか判別できる方だけオフにしてください。",

	SI_PBSDICE_KEYBIND = "チャット画面のR3で振る",
	SI_PBSDICE_KEYBIND_TOOLTIP = "チャット画面に、右スティック押し込み（R3）のボタンを追加します。押すと自分のチャットにダイスの結果が出ます。0.5秒長押しすると、代わりに対応する /roll コマンドを入力欄に入れるので、送信を押せばゲーム本体がロールしてグループ全員に見えます。最後の送信だけはプレイヤーが押す必要があります（アドオンからチャットは送れないため）。△のランダムロールはそのままで、今までどおり動きます。△の長押しではなく空きボタンにしているのは、△は押し込んだ瞬間にゲームがロールしてしまうためで、△を乗っ取ると今度は全員に見える本物のロールに手が届かなくなるからです。",

	SI_PBSDICE_KEYBIND_NAME = "PB's Diceを振る（自分のみ／長押しで全員）",

	SI_PBSDICE_PREFILL = "チャット入力欄に /roll を入れておく",
	SI_PBSDICE_PREFILL_TOOLTIP = "チャット画面を開いたとき、入力欄に設定したダイスの /roll コマンドを入れておきます。送信を押せばゲーム本体がロールするので、グループのチャットに流れて全員に見えます。入力欄が空のときだけ入れるので、書きかけの文章が消えることはありません。普通に発言したいときは消してから入力してください。そのため初期状態ではオフです。",

	SI_PBSDICE_ROLL_NOW = "今すぐ振る",
	SI_PBSDICE_ROLL_NOW_TOOLTIP = "上の設定でダイスを振り、結果をチャットに表示します。見えるのは自分だけです。",
	SI_PBSDICE_ROLL_NOW_BUTTON = "振る",

	SI_PBSDICE_RESET = "初期設定に戻す",
	SI_PBSDICE_RESET_TOOLTIP = "このパネルの設定をすべて初期値に戻します。初期値は100面が1個、つまりチャット画面が元々行うロールと同じです。",

	SI_PBSDICE_RESET_BUTTON = "リセット",

	-- ---- ロール結果 --------------------------------------------------------------------
	SI_PBSDICE_STAGE_OCCUPIED = "入力欄に文字が残っているので、そのままにしました。消してからもう一度長押ししてください",
	SI_PBSDICE_STAGE_NO_BOX = "書き込む入力欄が見つかりません",

	SI_PBSDICE_LOCAL_TAG = " |c9d9d9d(自分のみ)|r",
	SI_PBSDICE_BREAKDOWN = "%s = %s",
	SI_PBSDICE_RESULT_FALLBACK = "%sが%sをロール(%s x %s面)。",

	-- ---- 状態 --------------------------------------------------------------------------
	SI_PBSDICE_STATUS_HEADER = "現在の設定 (バージョン %s):",
	SI_PBSDICE_STATUS_DICE = "ダイス: %dd%d",
	SI_PBSDICE_STATUS_EACH = "各ダイスの出目: %s",
	SI_PBSDICE_STATUS_TAG = "自分のみの印: %s",
	SI_PBSDICE_STATUS_KEYBIND = "チャット画面のR3: %s",
	SI_PBSDICE_STATUS_KEYBIND_PENDING = "  (ボタンはチャット画面を最初に開いたときに追加されます。まだ追加されていません)",
	SI_PBSDICE_STATUS_KEYBIND_NA = "  (ゲームパッド用チャット画面が見つからないため、この設定は働きません)",
	SI_PBSDICE_STATUS_KEYBIND_TAKEN = "  (R3は他が先に使っていたため、手を出していません)",
	SI_PBSDICE_STATUS_PREFILL = "チャット入力欄への記入: %s",
	SI_PBSDICE_STATUS_PREFILL_NA = "  (ゲームパッド用チャット画面が見つからないため、この設定は働きません)",
	SI_PBSDICE_STATUS_COMMAND = "全員に見せるには次を送信: %s",
	SI_PBSDICE_STATUS_CLAMPED = "  (クライアントの上限が %dd%d のため、送信内容はそこまでに丸めます)",

	SI_PBSDICE_ON = "オン",
	SI_PBSDICE_OFF = "オフ",

	-- ---- 応答 --------------------------------------------------------------------------
	SI_PBSDICE_REPLY_COUNT = "ダイスの個数: %d",
	SI_PBSDICE_REPLY_SIDES = "ダイスの面数: %d",
	SI_PBSDICE_REPLY_EACH = "各ダイスの出目: %s",
	SI_PBSDICE_REPLY_TAG = "自分のみの印: %s",
	SI_PBSDICE_REPLY_KEYBIND = "チャット画面のR3: %s",
	SI_PBSDICE_REPLY_PREFILL = "チャット入力欄への記入: %s",
	SI_PBSDICE_REPLY_PREFILL_HINT = "チャット画面を開くと %s が入った状態になります",
	SI_PBSDICE_REPLY_RESET = "すべての設定を初期値に戻しました",

	-- ---- エラー ------------------------------------------------------------------------
	SI_PBSDICE_ERROR_COUNT = "ダイスの個数は %d〜%d です",
	SI_PBSDICE_ERROR_SIDES = "ダイスの面数は %d〜%d です",
	SI_PBSDICE_ERROR_ON_OR_OFF = "on か off を指定してください",
	SI_PBSDICE_ERROR_UNKNOWN = "そのようなコマンドはありません: %s",

	-- ---- ヘルプ ------------------------------------------------------------------------
	SI_PBSDICE_HELP_HEADER = "コマンド一覧:",
	SI_PBSDICE_HELP_ROLL = "/pbdice -- 設定したダイスを振る",
	SI_PBSDICE_HELP_SPEC = "/pbdice 3d20 -- その場かぎりで振る（設定は変わりません）",
	SI_PBSDICE_HELP_COUNT = "/pbdice count 3 -- ダイスの個数、1〜10",
	SI_PBSDICE_HELP_SIDES = "/pbdice sides 20 -- ダイスの面数、2〜1000",
	SI_PBSDICE_HELP_EACH = "/pbdice each on | off -- 各ダイスの出目を表示する",
	SI_PBSDICE_HELP_TAG = "/pbdice tag on | off -- 自分のみのロールに印を付ける",
	SI_PBSDICE_HELP_KEYBIND = "/pbdice keybind on | off -- チャット画面のR3（押す=振る、長押し=/rollを用意）",
	SI_PBSDICE_HELP_PREFILL = "/pbdice prefill on | off -- チャット入力欄に /roll を入れておく",
	SI_PBSDICE_HELP_STATUS = "/pbdice status -- 現在の設定を表示",
	SI_PBSDICE_HELP_RESET = "/pbdice reset -- すべての設定を初期値に戻す",

	-- ---- 調査コマンド ------------------------------------------------------------------
	SI_PBSDICE_PROBE_HEADER = "アドオンからロールできるかをクライアントに尋ねます:",
	SI_PBSDICE_PROBE_CONSTANT = "%s = %s",
	SI_PBSDICE_PROBE_MISSING = "RandomDiceRoll が存在しません。試すものがありません",
	SI_PBSDICE_PROBE_CALL = "RandomDiceRoll(6, 1, 0): 呼び出し=%s 戻り値=%s",
	SI_PBSDICE_PROBE_ALLOWED = "通りました。今 1d6 が本物として振られています。このアドオンも本物のロールにできます",
	SI_PBSDICE_PROBE_REFUSED = "拒否されました（想定どおり）。ロールAPIは private で、アドオンからは届きません",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
