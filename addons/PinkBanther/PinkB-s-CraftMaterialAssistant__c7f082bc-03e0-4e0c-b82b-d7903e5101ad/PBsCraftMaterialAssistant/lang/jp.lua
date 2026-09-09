-- 日本語。lang/strings.lua のあとに読み込まれ、同じIDを上書きします。
local strings = {
	-- ---- 設定パネル --------------------------------------------------------------------
	SI_PBSCMA_EXPLANATION = "作りたいものを選び、作る回数を指定すると、必要な材料・現在の所持数・不足数を別ウィンドウに一覧表示します。候補の一覧はこのパネルではなくそのウィンドウに表示されます。下の「カテゴリー」で絞り込むか、/pbcraft find <文字列> で名前検索し、「候補」スライダーで印を動かして「決定」を押してください。",

	SI_PBSCMA_SECTION_PICK = "作るものを選ぶ",
	SI_PBSCMA_SECTION_AMOUNT = "作る個数",
	SI_PBSCMA_SECTION_WINDOW = "ウィンドウ",

	SI_PBSCMA_BROWSE_SHOWING = "候補一覧を表示する",
	SI_PBSCMA_BROWSE_SHOWING_TOOLTIP = "ウィンドウの表示を候補一覧に切り替えます。オフにするか候補を決定すると、材料表に戻ります。",

	SI_PBSCMA_CATEGORY = "カテゴリー",
	SI_PBSCMA_CATEGORY_TOOLTIP = "ゲーム側のレシピ分類です。文字入力なしで候補を短くするいちばん速い方法です。",
	SI_PBSCMA_CATEGORY_ALL = "すべて",

	SI_PBSCMA_SEARCH = "検索",
	SI_PBSCMA_SEARCH_TOOLTIP = "名前の一部を入力します。この欄は設定ライブラリに文字入力欄がある場合だけ表示されます。/pbcraft find <文字列> でも同じことができ、そちらは必ず使えます。",

	SI_PBSCMA_REBUILD = "検索し直す",
	SI_PBSCMA_REBUILD_TOOLTIP = "現在の条件でもう一度探し直します。レシピを覚えたあとに押してください。",
	SI_PBSCMA_REBUILD_BUTTON = "検索",

	SI_PBSCMA_KNOWN_ONLY = "習得済みのみ",
	SI_PBSCMA_KNOWN_ONLY_TOOLTIP = "オンだと、このキャラクターが実際に作れるものだけを一覧します。オフにすると未習得のレシピも * 付きで表示され、何を覚えるか検討するときに使えます。",

	SI_PBSCMA_PAGE = "ページ",
	SI_PBSCMA_PAGE_TOOLTIP = "候補一覧の何ページ目を表示するか。最後のページより先には進みません。",

	SI_PBSCMA_CURSOR = "候補",
	SI_PBSCMA_CURSOR_TOOLTIP = "ウィンドウ内の印を上下に動かします。これが選択操作で、下のボタンが印の位置の候補を確定します。",

	SI_PBSCMA_TAKE = "印の候補を決定する",
	SI_PBSCMA_TAKE_TOOLTIP = "印のついた候補を集計対象にし、ウィンドウを材料表に戻します。",
	SI_PBSCMA_TAKE_BUTTON = "決定",

	SI_PBSCMA_CLEAR = "選択を解除",
	SI_PBSCMA_CLEAR_TOOLTIP = "選択中のアイテムを忘れます。ウィンドウは残り、未選択と表示します。",
	SI_PBSCMA_CLEAR_BUTTON = "解除",

	SI_PBSCMA_QUANTITY = "作成回数",
	SI_PBSCMA_QUANTITY_TOOLTIP = "レシピを作る回数です。できあがる個数ではありません。1回で4個できるレシピを3回作れば、材料は3回ぶん、できあがりは12個です。実際の個数はウィンドウに表示します。",

	SI_PBSCMA_SCOPE = "所持数を数える範囲",
	SI_PBSCMA_SCOPE_TOOLTIP = "所持列がどの保管場所を数えるかです。家の金庫はクラフト台から取り出せないため、初期設定では数えません。",
	SI_PBSCMA_SCOPE_BACKPACK = "バッグのみ",
	SI_PBSCMA_SCOPE_BANK = "バッグ＋銀行",
	SI_PBSCMA_SCOPE_CRAFTBAG = "バッグ＋銀行＋クラフトバッグ",
	SI_PBSCMA_SCOPE_ALL = "すべて（家の金庫も含む）",

	SI_PBSCMA_ENABLED = "ウィンドウを表示する",
	SI_PBSCMA_ENABLED_TOOLTIP = "全体スイッチです。オフにするとウィンドウを閉じ、インベントリの監視も完全に止めます。",

	SI_PBSCMA_WIDTH = "幅",
	SI_PBSCMA_WIDTH_TOOLTIP = "ウィンドウの幅です。数値3列の幅は固定で、残りが材料名の列になります。長い名前は末尾を省略します。",
	SI_PBSCMA_HEIGHT = "高さ",
	SI_PBSCMA_HEIGHT_TOOLTIP = "ウィンドウの高さです。行が入りきらない場合は末尾の行が描かれないだけで、ウィンドウの外にはみ出すことはありません。",

	SI_PBSCMA_POSITION = "基準位置",
	SI_PBSCMA_POSITION_TOOLTIP = "画面のどこを基準にウィンドウを置くかです。下のオフセットでそこからずらします。",
	SI_PBSCMA_POS_TOPLEFT = "左上",
	SI_PBSCMA_POS_TOP = "上",
	SI_PBSCMA_POS_TOPRIGHT = "右上",
	SI_PBSCMA_POS_LEFT = "左",
	SI_PBSCMA_POS_CENTER = "中央",
	SI_PBSCMA_POS_RIGHT = "右",
	SI_PBSCMA_POS_BOTTOMLEFT = "左下",
	SI_PBSCMA_POS_BOTTOM = "下",
	SI_PBSCMA_POS_BOTTOMRIGHT = "右下",

	SI_PBSCMA_OFFSET_X = "横のずれ",
	SI_PBSCMA_OFFSET_Y = "縦のずれ",
	SI_PBSCMA_OFFSET_TOOLTIP = "基準位置からどれだけ離すかです。マイナスで逆方向に動きます。",

	SI_PBSCMA_FONT_SIZE = "文字サイズ",
	SI_PBSCMA_FONT_SIZE_TOOLTIP = "ウィンドウ内すべての行の文字サイズです。数値列の幅もこれに追従するので、表の桁は揃ったままになります。",

	SI_PBSCMA_FACE = "書体",
	SI_PBSCMA_FACE_TOOLTIP = "コンソールのUIがすでに読み込んでいる書体だけを選べます。どこでも使われていない書体は使用時に生成され、その生成がアドオン共通のメモリを消費するためです。",
	SI_PBSCMA_FACE_GAMEPAD_MEDIUM = "ゲームパッド・中字",
	SI_PBSCMA_FACE_GAMEPAD_BOLD = "ゲームパッド・太字",
	SI_PBSCMA_FACE_GAMEPAD_LIGHT = "ゲームパッド・細字",
	SI_PBSCMA_FACE_MEDIUM = "インターフェース・中字",
	SI_PBSCMA_FACE_BOLD = "インターフェース・太字",

	SI_PBSCMA_STYLE = "縁取り",
	SI_PBSCMA_STYLE_TOOLTIP = "背景から文字を浮き立たせる方法です。明るい背景の上では太い縁取りのほうが読みやすく、負荷は変わりません。",
	SI_PBSCMA_STYLE_SOFT_THIN = "やわらかい影・細",
	SI_PBSCMA_STYLE_SOFT_THICK = "やわらかい影・太",
	SI_PBSCMA_STYLE_OUTLINE = "太い縁取り",
	SI_PBSCMA_STYLE_SHADOW = "影",
	SI_PBSCMA_STYLE_NONE = "なし",

	SI_PBSCMA_OPACITY = "背景の濃さ",
	SI_PBSCMA_OPACITY_TOOLTIP = "文字の後ろに敷く板の濃さです。0にすると板は描かれず、文字だけになります。",

	SI_PBSCMA_DRAW = "表示レイヤー",
	SI_PBSCMA_DRAW_TOOLTIP = "他のUI要素に対してどの高さに描くかです。候補一覧は設定画面を開いたまま読む必要があるため、初期値は「手前」です。",
	SI_PBSCMA_DRAW_FRONT = "手前",
	SI_PBSCMA_DRAW_NORMAL = "通常",
	SI_PBSCMA_DRAW_BACK = "奥",

	SI_PBSCMA_RESET = "初期設定に戻す",
	SI_PBSCMA_RESET_TOOLTIP = "このパネルのすべての設定を初期値に戻し、選択も解除します。",
	SI_PBSCMA_RESET_BUTTON = "リセット",

	-- ---- ウィンドウ --------------------------------------------------------------------
	SI_PBSCMA_WINDOW_TITLE = "クラフト材料",
	SI_PBSCMA_WINDOW_NOTHING_PICKED = "未選択です。設定パネル、または /pbcraft find <文字列>",
	SI_PBSCMA_WINDOW_TARGET_LOST = "選択していたものが、このクライアントのレシピ一覧に見つかりません。",
	SI_PBSCMA_WINDOW_YIELD = "  （できあがり %d 個）",
	SI_PBSCMA_WINDOW_SHORT = "不足 %d 種類",
	SI_PBSCMA_WINDOW_ENOUGH = "材料はそろっています",
	SI_PBSCMA_WINDOW_CRAFTABLE = "   いま作れるのは %d 回",
	SI_PBSCMA_WINDOW_UNCOUNTED = "   （数えられなかった材料があります）",

	SI_PBSCMA_COLUMN_MATERIAL = "材料",
	SI_PBSCMA_COLUMN_NEED = "必要",
	SI_PBSCMA_COLUMN_HAVE = "所持",
	SI_PBSCMA_COLUMN_SHORT = "不足",
	SI_PBSCMA_COLUMN_CANDIDATE = "候補",
	SI_PBSCMA_COLUMN_INGREDIENTS = "材料数",

	SI_PBSCMA_BROWSE_TITLE = "候補 -- %s",
	SI_PBSCMA_BROWSE_TITLE_SEARCH = "検索: %s",
	SI_PBSCMA_BROWSE_COUNT = "%d 件  ページ %d/%d",
	SI_PBSCMA_BROWSE_TRUNCATED = "   （上限で打ち切り）",
	SI_PBSCMA_BROWSE_EMPTY = "該当なし。",
	SI_PBSCMA_BROWSE_UNKNOWN_MARK = " *",

	-- ---- チャット ----------------------------------------------------------------------
	SI_PBSCMA_ON = "オン",
	SI_PBSCMA_OFF = "オフ",

	SI_PBSCMA_STATUS_TARGET = "%s を %d 回ぶん集計中",
	SI_PBSCMA_STATUS_SHORT = "不足 %d 種類、いま作れるのは %d 回",
	SI_PBSCMA_STATUS_SCOPE = "所持数の集計範囲: %s",
	SI_PBSCMA_STATUS_NO_TARGET = "まだ何も選ばれていません -- /pbcraft find <文字列>",
	SI_PBSCMA_STATUS_LOST = "選択していたものが、このクライアントのレシピ一覧に見つかりません",

	SI_PBSCMA_REPLY_MATCHES = "%d 件 -- ページ %d/%d",
	SI_PBSCMA_REPLY_NO_MATCHES = "該当なし",
	SI_PBSCMA_REPLY_PICK_HINT = "/pbcraft pick <番号> で選択します",
	SI_PBSCMA_REPLY_PICKED = "%s を選択、%d 回ぶん",
	SI_PBSCMA_REPLY_QUANTITY = "作成回数を %d 回にしました",
	SI_PBSCMA_REPLY_SWITCH = "%s: %s",
	SI_PBSCMA_REPLY_CLEARED = "選択を解除しました",
	SI_PBSCMA_REPLY_RESET = "すべての設定を初期状態に戻しました",
	SI_PBSCMA_REPLY_PROBE = "カテゴリー %d 件、レシピ %d 件（うち習得済み %d 件） -- 全走査 1 回に %d ミリ秒",
	SI_PBSCMA_REPLY_CATEGORIES = "カテゴリー一覧 -- /pbcraft cat <番号>",

	SI_PBSCMA_ERROR_NO_API = "このクライアントはレシピ関数に応答しないため、一覧を作れません",
	SI_PBSCMA_ERROR_NO_WINDOW = "このクライアントではウィンドウを作成できませんでした",
	SI_PBSCMA_ERROR_NEED_NUMBER = "数値を指定してください",
	SI_PBSCMA_ERROR_NO_SUCH_CANDIDATE = "このページにその番号の候補はありません",
	SI_PBSCMA_ERROR_NO_SUCH_CATEGORY = "その番号のカテゴリーはありません -- /pbcraft list",
	SI_PBSCMA_ERROR_ON_OR_OFF = "on か off を指定してください",
	SI_PBSCMA_ERROR_QUANTITY = "個数は %d 〜 %d の範囲で指定してください",
	SI_PBSCMA_ERROR_SCOPE = "範囲は backpack / bank / craftbag / all のいずれかです",
	SI_PBSCMA_ERROR_UNKNOWN = "不明なコマンドです: %s",
	SI_PBSCMA_ERROR_DRAW_REFUSED = "このクライアントは表示レイヤーの変更を拒否しました。ウィンドウは元の位置のまま描画されています",

	-- ---- ヘルプ ------------------------------------------------------------------------
	SI_PBSCMA_HELP_HEADER = "コマンド:",
	SI_PBSCMA_HELP_STATUS = "/pbcraft -- 選択中のものと不足状況",
	SI_PBSCMA_HELP_FIND = "/pbcraft find <文字列> -- 名前で検索し、候補をウィンドウに表示",
	SI_PBSCMA_HELP_PICK = "/pbcraft pick <番号> -- 表示中のページから候補を選択",
	SI_PBSCMA_HELP_PAGE = "/pbcraft next | prev | page <n> -- 候補のページ移動",
	SI_PBSCMA_HELP_QTY = "/pbcraft qty <n> -- 作成回数",
	SI_PBSCMA_HELP_LIST = "/pbcraft list -- カテゴリー一覧と番号",
	SI_PBSCMA_HELP_CAT = "/pbcraft cat <n> -- カテゴリーで絞り込み（0 ですべて）",
	SI_PBSCMA_HELP_KNOWN = "/pbcraft known on | off -- 習得済みのみに絞る",
	SI_PBSCMA_HELP_SCOPE = "/pbcraft scope backpack | bank | craftbag | all -- 所持数の集計範囲",
	SI_PBSCMA_HELP_BROWSE = "/pbcraft browse [on | off] -- 候補一覧の表示",
	SI_PBSCMA_HELP_CLEAR = "/pbcraft clear -- 選択を解除",
	SI_PBSCMA_HELP_MASTER = "/pbcraft on | off -- 全体スイッチ",
	SI_PBSCMA_HELP_PROBE = "/pbcraft probe -- カタログを1回数え、所要時間を表示",
	SI_PBSCMA_HELP_RESET = "/pbcraft reset -- すべての設定を初期状態に戻す",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
