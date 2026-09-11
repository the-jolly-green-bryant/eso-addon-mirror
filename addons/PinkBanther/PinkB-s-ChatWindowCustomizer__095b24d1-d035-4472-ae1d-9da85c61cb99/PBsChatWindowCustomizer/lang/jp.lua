local strings = {
	SI_PBSCWC_EXPLANATION = "HUDのチャットウィンドウの位置と大きさ、文字サイズを変更します。ゲーム本体ではウィンドウは右下に固定・大きさも固定です。以下の項目はすべてゲーム本来の値から始まり、動かすまでは何も変更しません。このパネルを開いている間は、ウィンドウの位置をピンクの枠で表示します。",

	SI_PBSCWC_ENABLED = "チャットウィンドウを変更する",
	SI_PBSCWC_ENABLED_TOOLTIP = "以下の設定を適用します。オフにすると、チャットウィンドウと文字をすぐにゲーム本来の状態に戻します（設定内容は残るので、オンに戻せば再び適用されます）。",

	SI_PBSCWC_PREVIEW = "ここでプレビューを表示",
	SI_PBSCWC_PREVIEW_TOOLTIP = "チャットはHUD上でしか描画されないため、このメニューからは見えません。オンの間は、ウィンドウが表示される場所にピンクの枠とサンプルのチャット数行を、選んだ文字サイズで表示します。",

	-- ---- 位置 --------------------------------------------------------------------------
	SI_PBSCWC_SECTION_POSITION = "位置",
	SI_PBSCWC_CORNER = "基準の角",
	SI_PBSCWC_CORNER_TOOLTIP = "位置を画面のどの角から測るかです。ウィンドウも同じ角で固定されるため、大きさを変えたときにどちらへ伸びるかもこれで決まります。右下（ゲーム本来の設定）なら、高さを増やすとウィンドウは上に伸び、入力欄の位置は変わりません。これを切り替えてもウィンドウは動きません。",
	SI_PBSCWC_CORNER_TOP_LEFT = "左上",
	SI_PBSCWC_CORNER_TOP_RIGHT = "右上",
	SI_PBSCWC_CORNER_BOTTOM_LEFT = "左下",
	SI_PBSCWC_CORNER_BOTTOM_RIGHT = "右下",

	SI_PBSCWC_POSITION_X = "左右の端からの距離",
	SI_PBSCWC_POSITION_X_TOOLTIP = "画面の左端または右端（上で選んだ角の側）からウィンドウまでの距離です。0で画面の端にぴったり付きます。",
	SI_PBSCWC_POSITION_Y = "上下の端からの距離",
	SI_PBSCWC_POSITION_Y_TOOLTIP = "画面の上端または下端（上で選んだ角の側）からウィンドウまでの距離です。ゲーム本来のウィンドウは、スキルバーを避けて下から215の位置にあります。",

	-- ---- 大きさ ------------------------------------------------------------------------
	SI_PBSCWC_SECTION_SIZE = "大きさ",
	SI_PBSCWC_WIDTH = "幅",
	SI_PBSCWC_WIDTH_TOOLTIP = "入力欄を含むウィンドウの幅です。ゲーム本来は490です。ゲームは通常300〜550の範囲に制限していますが、このアドオンでは200から画面の幅まで設定できます。",
	SI_PBSCWC_HEIGHT = "高さ",
	SI_PBSCWC_HEIGHT_TOOLTIP = "入力欄を含むウィンドウの高さです。ゲーム本来は280です。ゲームは通常170〜380の範囲に制限していますが、このアドオンでは100から画面の高さまで設定できます。",

	-- ---- 文字 --------------------------------------------------------------------------
	SI_PBSCWC_SECTION_TEXT = "文字",
	SI_PBSCWC_FONT_SIZE = "メッセージの文字サイズ",
	SI_PBSCWC_FONT_SIZE_TOOLTIP = "チャットメッセージの文字サイズです。初期値は、ゲームの設定（設定 > ソーシャルの小／中／大）でゲームが実際に描画しているサイズを実測した値です。動かすと、ゲーム側の小／中／大の代わりにこのサイズが使われます。入力欄は枠の高さが固定されているため、ゲーム本来のサイズのままです。",

	-- ---- 共通 --------------------------------------------------------------------------
	SI_PBSCWC_SECTION_GENERAL = "すべての設定",
	SI_PBSCWC_RESET = "初期設定に戻す",
	SI_PBSCWC_RESET_TOOLTIP = "位置・大きさ・文字サイズをゲーム本来の状態に戻します。",
	SI_PBSCWC_RESET_BUTTON = "戻す",

	SI_PBSCWC_GAME_SETTINGS_HINT = "HUDにチャットを表示するかどうかはゲーム本体の設定です（設定 > ソーシャル）。アドオンからは変更できないため、そちらで設定してください。",

	-- ---- プレビュー ----------------------------------------------------------------------
	SI_PBSCWC_PREVIEW_CAPTION = "チャットウィンドウ（プレビュー）",
	SI_PBSCWC_PREVIEW_ENTRY = "入力欄",
	SI_PBSCWC_PREVIEW_LINE_1 = "|cC8C8FF[ゾーン] 旅人: ワールドボス行く人いますか？|r",
	SI_PBSCWC_PREVIEW_LINE_2 = "|c9FE8FF[グループ] PinkBanther: 今向かってます！|r",
	SI_PBSCWC_PREVIEW_LINE_3 = "|cE8C4FF[ギルド] フレンド: 素材ありがとう|r",
	SI_PBSCWC_PREVIEW_LINE_4 = "|cFFB6E4[ささやき] PinkBanther: またあとで|r",
	SI_PBSCWC_PREVIEW_LINE_5 = "|cFFFFFFPinkBanther: こんにちは、タムリエル！|r",
	SI_PBSCWC_PREVIEW_LINE_6 = "|cC8C8FF[ゾーン] 旅人: みなさんありがとう|r",
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(_G[stringId], stringValue, 2)
end
