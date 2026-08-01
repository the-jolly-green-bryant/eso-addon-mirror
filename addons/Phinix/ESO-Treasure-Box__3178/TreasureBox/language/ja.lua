local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "名前で宝物を検索します。"
	L.TBoxAddon_CLOSE					= "閉じる「トレジャーボックス"
	L.TBoxAddon_TITLE					= "宝箱"
	L.TBoxAddon_RECENT					= "最近見つかった："
	L.TBoxAddon_FAVZONE					= "トップゾーン："
	L.TBoxAddon_UPDATE1					= "[TBox]: トレジャーボックスデータベースを更新しました。"
	L.TBoxAddon_UPDATE2					= "[TBox]: /reloaduiを実行して完了してください。"
	L.TBoxAddon_UPDATE3					= "[TBox]: お待ちください..."
	L.TBoxAddon_NOCATEGORY				= "未分類"
	L.TBoxAddon_RESETSEARCH				= "ボタンをクリックして、テキスト検索をリセットします。\n\n"..pTC("FFFFFF", "ノート： ").."他のフィルターは維持されます。"
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "見つかったものだけを表示").." です"..pTC("FFFFFF", " オン").."\n\nあなたがそれらを見つけたかどうかにかかわらず、すべての宝物を表示することを切り替えるためにクリックしてください。"
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "見つかったものだけを表示").." です"..pTC("FFFFFF", " オフ").."\n\nクリックして、キャラクターの1つで見つけた宝物のみを表示します。"
	L.TBoxAddon_RESETFILTER				= "フィルターのリセット"
	L.TBoxAddon_RQUALITYS1				= "のみを表示 "
	L.TBoxAddon_RQUALITYS2				= " そして最近見つかったリストのより高品質のアイテム。"
	L.TBoxAddon_UPDATING				= "[TBox]: トレジャーボックスデータベースの更新、再起動しないでください..."

-- Navigation
	L.TBoxAddon_TFOUND					= "トレジャーが見つかりました："
	L.TBoxAddon_QUALITYHEAD				= "宝物の品質："
	L.TBoxAddon_TIMEHEAD				= "見つかった時間："
	L.TBoxAddon_TIMEDAYS1				= "過去"
	L.TBoxAddon_TIMEDAYS2				= "日数"
	L.TBoxAddon_ANY						= "任意"
	L.TBoxAddon_ALLTYPES				= "カテゴリー： 任意"
	L.TBoxAddon_ALLZONES				= "で見つかりました： 任意"
	L.TBoxAddon_ANYFOUND				= "によって発見： 任意"
	L.TBoxAddon_QUALITYS				= "品質を表示します： "
	L.TBoxAddon_QUALITY1				= "正常"
	L.TBoxAddon_QUALITY2				= "罰金"
	L.TBoxAddon_QUALITY3				= "上長"
	L.TBoxAddon_QUALITY4				= "エピック"
	L.TBoxAddon_QUALITY5				= "伝説の"
	L.TBoxAddon_FINZONES				= "発見ゾーン："
	L.TBoxAddon_LFOUNDIN				= "最後に見つかった場所： "
	L.TBoxAddon_LFOUNDBY				= "最終発見者： "
	L.TBoxAddon_FOUNDON					= "最終発見日： "
	L.TBoxAddon_TOTALF					= "見つかった合計： "
	L.TBoxAddon_NEVER					= "決して"
	L.TBoxAddon_NONE					= "無し"
	L.TBoxAddon_UNKNOWN					= "未知の"
	L.TBoxAddon_SALPHA					= "アルファベット順にソートします"
	L.TBoxAddon_SFOUND					= "見つかった数字でソートします"

-- Settings
	L.TBoxAddon_GOPTS					= "一般オプション"
	L.TBoxAddon_CHARALPHA				= "ソート文字リスト"
	L.TBoxAddon_CHARALPHAT				= "有効にすると、文字のリストがアルファベット順に表示されます。 それ以外の場合は、ゲームのキャラクター選択順序を使用します。\n\n"..pTC("FFFFFF", "ノート： ").."ゲームはキャラクター作成順序のみを返します。 手動で並べ替えられた文字は追跡されません。"
	L.TBoxAddon_USTIME					= "12時間の時間"
	L.TBoxAddon_USTIMET					= "有効にすると、以前に見つかった宝物のタイムスタンプが12時間以内に表示され、その時間の後に午前/午後が表示されます。 オフにすると、24時間（軍事）時間で表示されます。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
