local SALTI = _G['SALTI']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.SALTI_Title					= "SALTI (通貨の合計)"
L.SALTI_PTitle					= "SALTI - 通貨の合計"
L.SALTI_GOpts					= "グローバルオプション"
L.SALTI_COpts					= "文字の状態"
L.SALTI_CCTrack					= "文字通貨の追跡"
L.SALTI_CCTrackD				= "現在のキャラクターの金、AP、筆記帳、Telvarストーンを追跡します。 これをオフにすると、この文字の保存通貨データが削除されます."
L.SALTI_TRACKWARN				= "警告：自動的にUIが読み込まれます！"
L.SALTI_IWPos					= "独立したポジションを使用する"
L.SALTI_IWPosD					= "有効にすると、ポップアップ通貨のヒントの場所は、ホットキーを切り替えたウィンドウが最後に配置された場所になります。 ウィンドウの位置を設定するには、キーバインドを設定するか、/salti を入力してSALTIを表示/非表示にします."
L.SALTI_SACIcon					= "アライアンス/クラスアイコンを表示する"
L.SALTI_SACIconD				= "それぞれのキャラクターの名前の隣に色付きのアイコンが表示され、そのクラスと所属するアライアンスを示します."
L.SALTI_SGC						= "グローバル通貨を表示"
L.SALTI_SGCD					= "口座全体の通貨の概要を標準合計で表示します."
L.SALTI_GCS						= "グローバル通貨パディング："
L.SALTI_GCSD					= "グローバル通貨項目間のスペースを広げたり短くします。"
L.SALTI_ALPHAN					= "名前リストをアルファベット順に並べ替える"
L.SALTI_ALPHAND					= "有効にすると、追跡された文字通貨リストがアルファベット順に表示されます。 それ以外の場合、文字のリストはログイン画面の文字の順序と一致します."
L.SALTI_SGBGold					= "ギルドバンクゴールドを表示する"
L.SALTI_SGBGoldD				= "あなたの現在のギルドバンクに保存されている金の要約をゴールドサマリーツールチップに表示します（金の値を入力/更新するには各ギルドの銀行を訪れる必要があります）."
L.SALTI_DCChar					= "キャラクターのデータを削除する："
L.SALTI_DELETE					= "削除"
L.SALTI_CDELD					= "選択した文字を追跡データベースから削除します。 ここにまだ存在する文字を削除すると、それらは自動的にトラックしないように設定されます。 キャラクタとしてログインし、キャラクタオプションの下で再度トラッキングを有効にして、それらをデータベースに再追加します."

-- General Strings
L.SALTI_BTotal					= "銀行:"
L.SALTI_ATotal					= "アカウント合計:"
L.SALTI_SOURCE					= "ソース"
L.SALTI_CGlobal					= "グローバル："
L.SALTI_DBUpdate				= "SALTIデータベースはこのバージョンをリセットしました。\n再構築するには、各文字にログインしてください."

-- Below must be the same as it appears on the in-game currency tab with the translation mod you are using:
--L.SALTI_ETHeader				= "event tickets"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k, v in pairs(SALTI:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function SALTI:GetLanguage() -- set new language return
		return L
	end
end
