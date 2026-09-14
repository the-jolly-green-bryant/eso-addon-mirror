TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "情報"
L.INFO_TT = "ギルドのハイパーリンクを含むゾーン／say 行を非表示にします。所属ギルドのチャットも個別にミュートできます。公式の招待ウィンドウは止めません。\nゴールド／不具合: メール @Tetsurion"

L.ADS_SECTION = "ギルド宣伝をミュート"
L.ADS_SECTION_TT = "ギルドリンク付きの宣伝をゾーン／say／yell から隠します。"

L.ENABLED = "宣伝フィルタをオン"
L.ENABLED_TT = "ゾーン／say／yell 宣伝のマスタースイッチ。オン＝ギルドリンク付きの行は自分のチャットに出ません。"

L.FILTER_ZONE = "ゾーンチャットをフィルタ"
L.FILTER_ZONE_TT = "言語別ゾーンを含む全ゾーンチャンネル。初期オン。"

L.FILTER_SAY = "say をフィルタ"
L.FILTER_SAY_TT = "近くの say。初期オン。"

L.FILTER_YELL = "yell をフィルタ"
L.FILTER_YELL_TT = "初期オフ。yell にも宣伝が来る場合だけオン。"

L.GUILD_SECTION = "ギルドチャットをミュート"
L.GUILD_SECTION_TT = "スイッチは所属ギルドごと。オン＝そのギルドのメッセージを隠す。他ギルドはそのまま。ギルドIDで保存。初期オフ。"
L.GUILD_HINT = "オン - このギルドのメッセージを隠す"
L.GUILD_HINT_TT = "オン＝そのギルドの /g と /o をすべて隠す。他ギルド、ゾーン、say は触らない。"
L.GUILD_EMPTY = "<<1>>.（空きスロット）"
L.MUTE_GUILD_TT = "オン＝このギルドのメッセージだけ隠す。他ギルド、ゾーン、say は触らない。"

L.HIDDEN_LABEL = "このセッションで隠した数: <<1>>"
L.HIDDEN_TT = "ログイン以降にスキップした行（宣伝＋ミュートしたギルド）。ReloadUI でリセット。"
