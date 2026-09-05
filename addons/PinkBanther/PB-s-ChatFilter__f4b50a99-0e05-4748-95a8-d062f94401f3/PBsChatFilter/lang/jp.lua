local strings = {
	-- ---- 設定パネル --------------------------------------------------------------------
	SI_PBSCF_EXPLANATION = "ギルドに5つ入っていると、ギルドチャンネル5本と役員チャンネル5本が同じチャット欄に流れ込みます。コンソールにはタブによる振り分けがないため、読まないものはここでオフにしてください。影響を受けるのはギルドチャンネルだけです。ゾーン・say・yell・ウィスパー・グループ・エモート・各種システムメッセージは今までどおり表示されます。",

	SI_PBSCF_ENABLED = "ギルドチャットをフィルタする",
	SI_PBSCF_ENABLED_TOOLTIP = "全体スイッチです。オフにすると、下の設定をそのまま残したまま、一時的にすべてのギルドチャンネルを表示します。",

	SI_PBSCF_KEEP_OWN = "自分の発言は常に表示する",
	SI_PBSCF_KEEP_OWN_TOOLTIP = "オフにしたギルドでも、自分が送ったメッセージは表示します。これがないと、非表示のギルドチャンネルに書き込んでも何も出ず、送信できていないように見えてしまいます。",

	SI_PBSCF_SECTION_GUILDS = "所属ギルド",
	SI_PBSCF_NO_GUILDS_NOTE = "ログイン時点でどのギルドにも所属していなかったため、一覧は空です。ギルドに加入したあとUIを再読み込みしてください。",

	SI_PBSCF_GUILD_HEADING = "%d. %s",
	SI_PBSCF_ROW_GUILD = "ギルドチャット",
	SI_PBSCF_ROW_GUILD_TOOLTIP = "このギルドの通常チャットをチャット欄に表示します。",
	SI_PBSCF_ROW_OFFICER = "役員チャット",
	SI_PBSCF_ROW_OFFICER_TOOLTIP = "このギルドの役員チャットを表示します。別チャンネルなのでスイッチも別です。通常チャットは非表示のまま役員チャットだけ追う、といった使い方ができます。",

	SI_PBSCF_SECTION_RECRUIT = "ギルド勧誘",
	SI_PBSCF_SECTION_RECRUIT_NOTE = "ギルドの勧誘は、ゾーンチャットに自ギルドのリンクを貼る形で行われます（ギルドファインダーの「チャットにリンク」がメッセージにギルドリンクを挿入します）。ここではそのリンクの有無を見ます。文面を推測するのではなく、ゲーム自身が埋め込んだものを正確に判定するので、勧誘文が何語で書かれていても効きます。リンクを含まない、ただの文章としての勧誘は通常のチャットと区別できないため対象外です。",

	SI_PBSCF_RECRUIT = "ギルドリンクを含むメッセージを非表示",
	SI_PBSCF_RECRUIT_TOOLTIP = "ゾーン・say・yell などが対象で、ギルドチャンネルは対象外です。自分のギルドのチャットに貼られたギルドリンクはそのギルドの会話であり、そのチャンネルを読むかどうかは上の設定ですでに決めているためです。",
	SI_PBSCF_RECRUIT_WHISPER = "ウィスパーも対象にする",
	SI_PBSCF_RECRUIT_WHISPER_TOOLTIP = "ウィスパーでの勧誘も実際にありますが、ウィスパーは相手が直接あなたに話しかけてきたものです。黙って消えてしまう方が、勧誘を1件読むより損失が大きいため、ここをオンにしない限りウィスパーには触れません。",

	SI_PBSCF_SECTION_GENERAL = "全般",
	SI_PBSCF_RESET = "すべて表示に戻す",
	SI_PBSCF_RESET_TOOLTIP = "このパネルの設定をすべて破棄し、アドオンを入れていない状態と同じ表示に戻します。",
	SI_PBSCF_RESET_BUTTON = "リセット",
	SI_PBSCF_RELOAD_HINT = "この一覧はログイン時点の所属ギルドです。加入・脱退したあとはUIを再読み込みすると描き直されます（チャットコマンド /pbfilter は常に最新の一覧を見ます）。",

	-- ---- 状態表示 ----------------------------------------------------------------------
	SI_PBSCF_ON = "オン",
	SI_PBSCF_OFF = "オフ",
	SI_PBSCF_STATE_FILTERING = "ギルドチャットをフィルタ中",
	SI_PBSCF_STATE_PASSING = "オフ（すべて表示）",
	SI_PBSCF_STATUS_NOT_INSTALLED = "チャットフックが入っていません -- チャットには一切手を触れていません",
	SI_PBSCF_STATUS_OWN = "自分の発言は常に表示: %s",
	SI_PBSCF_STATUS_RECRUIT = "ギルドリンクを含むメッセージ: %s（ウィスパーも %s） -- 今セッションの非表示: %d 件",
	SI_PBSCF_STATUS_NO_GUILDS = "ギルドに所属していません",
	SI_PBSCF_STATUS_GUILD_LINE = "%d. %s -- ギルド %s, 役員 %s",
	SI_PBSCF_STATUS_HIDDEN_LINE = "     今セッションの非表示: ギルド %d 件, 役員 %d 件",

	-- ---- コマンドの応答 ----------------------------------------------------------------
	SI_PBSCF_REPLY_RESET = "すべてのギルドを表示に戻しました",
	SI_PBSCF_REPLY_ALL = "すべてのギルドを表示にしました",
	SI_PBSCF_REPLY_NONE = "すべてのギルドを非表示にしました",
	SI_PBSCF_REPLY_BANNER = "ログイン時の状態表示 %s",

	SI_PBSCF_ERROR_NO_SUCH_GUILD = "%d 番目のギルドには所属していません",
	SI_PBSCF_ERROR_ONLY_NEEDS_INDEX = "only にはギルド番号が1つ以上必要です。例: /pbfilter only 1 3",
	SI_PBSCF_ERROR_ON_OR_OFF = "on か off を指定してください",
	SI_PBSCF_ERROR_UNKNOWN = "不明なコマンドです: %s",

	-- ---- ヘルプ ------------------------------------------------------------------------
	SI_PBSCF_HELP_STATUS = "/pbfilter -- どのギルドを表示中か、何件隠したかを表示",
	SI_PBSCF_HELP_MASTER = "/pbfilter on | off -- 全体スイッチ",
	SI_PBSCF_HELP_GUILD = "/pbfilter <n> on | off -- n番目のギルドの両チャンネル",
	SI_PBSCF_HELP_CHANNEL = "/pbfilter <n> guild | officer  on | off -- n番目のギルドの片方だけ",
	SI_PBSCF_HELP_ONLY = "/pbfilter only <n> [<n> ...] -- 指定したギルドだけ表示し、残りは非表示",
	SI_PBSCF_HELP_ALL = "/pbfilter all -- すべて表示",
	SI_PBSCF_HELP_NONE = "/pbfilter none -- すべて非表示",
	SI_PBSCF_HELP_OWN = "/pbfilter own on | off -- 自分の発言を常に表示",
	SI_PBSCF_HELP_RECRUIT = "/pbfilter recruit on | off -- ギルドリンクを含むメッセージを非表示",
	SI_PBSCF_HELP_RECRUIT_WHISPER = "/pbfilter recruit whisper on | off -- ウィスパーも対象にする",
	SI_PBSCF_HELP_BANNER = "/pbfilter banner on | off -- ログイン時に状態を表示",
	SI_PBSCF_HELP_RESET = "/pbfilter reset -- 設定をすべて破棄",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
