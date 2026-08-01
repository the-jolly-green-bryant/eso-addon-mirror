local GroupFDB = _G['GroupFDB']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Panel Strings.
L.GroupFDB_Title			= "グループフード＆ドリンクバフ"
L.GroupFDB_GOpts			= "グローバルオプション"
L.GroupFDB_SGF				= "グループフレームの監視"
L.GroupFDB_SGFD				= "グループユニットフレームに飲み物アイコンの食べ物を表示します。"
L.GroupFDB_SRF				= "レイドフレームの監視"
L.GroupFDB_SRFD				= "レイドユニットフレームに飲み物アイコンの食べ物を表示します。"
L.GroupFDB_SAB				= "アクティブバフインジケーターを表示する"
L.GroupFDB_SABD				= "アクティブな食べ物や飲み物のアイコンをグループやレイドフレームに表示します。"
L.GroupFDB_SJB				= "ジャンクバフインジケータを表示"
L.GroupFDB_SJBD				= "アクティブなジャンクフードまたは飲み物のアイコンをグループとレイドフレームに表示します。"
L.GroupFDB_SNB				= "行方不明のバフインジケータを表示"
L.GroupFDB_SNBD				= "グループに赤いアイコンを表示して、メンバーに食べ物や飲み物が有効になっていないときにフレームを襲撃します。"
L.GroupFDB_GMode			= "グループバフモード"
L.GroupFDB_GModeD			= "現在使用しているグループユニットフレームのサポートモジュールを選択してください。 デフォルトはゲームの通常のフレームです。"
L.GroupFDB_RMode			= "レイドバフモード"
L.GroupFDB_RModeD			= "あなたが現在使用している空襲ユニットフレーム用のサポートモジュールを選択してください。 デフォルトはゲームの通常のフレームです。"
L.GroupFDB_GIS				= "グループアイコンサイズ"
L.GroupFDB_GISD				= "標準のグループフレームに表示されているときの飲食物アイコンのサイズ（8ピクセルの倍数）。"
L.GroupFDB_RIS				= "レイドアイコンサイズ"
L.GroupFDB_RISD				= "標準のレイドフレームに表示されているときの飲食物アイコンのサイズ。8の倍数で表します。"
L.GroupFDB_GXIO				= "グループ水平アイコンオフセット"
L.GroupFDB_GXIOD			= "グループフレームの飲食物アイコンの位置を左から右に調整します。"
L.GroupFDB_GYIO				= "グループ垂直アイコンオフセット"
L.GroupFDB_GYIOD			= "グループフレームの飲食物アイコンの位置を上下に調整します。"
L.GroupFDB_RXIO				= "レイド水平アイコンオフセット"
L.GroupFDB_RXIOD			= "レイドフレームの飲食物アイコンの位置を左から右に調整します。"
L.GroupFDB_RYIO				= "レイド垂直アイコンオフセット"
L.GroupFDB_RYIOD			= "レイドフレームの飲食物アイコンの位置を上下に調整します。"

-- Group frame support options
L.GroupFDB_Mode1			= "デフォルト"
--L.GroupFDB_Mode2			= "Foundry Tactical Combat"
--L.GroupFDB_Mode3			= "Lui Extended"
--L.GroupFDB_Mode4			= "Bandits User Interface"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(GroupFDB:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function GroupFDB:GetLanguage() -- set new language return
		return L
	end
end
