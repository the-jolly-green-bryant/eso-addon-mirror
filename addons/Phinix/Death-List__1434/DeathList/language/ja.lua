local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.DLAddon_UnitAdded			= "が死亡リストに追加されました."
L.DLAddon_ToAddPlayers		= "プレイヤーを死亡リストに追加するオプションを有効にする必要があります."
L.DLAddon_NotAttackable		= "攻撃対象ではありません."
L.DLAddon_NoGuards			= "不滅護衛をデスリストに追加することはできません."
L.DLAddon_ListCleared		= "すべてのデスリストのターゲットがクリアされました."
L.DLAddon_ListEmpty			= "あなたの死亡リストに名前はありません."
L.DLAddon_Removed			= "はあなたの死亡リストから削除されました."
L.DLAddon_NoExist			= "ターゲットはあなたのデスリストに存在しません."

-- Settings panel
L.DLAddon_ShowMarker		= "マーキング文字を表示"
L.DLAddon_ShowMarkerTip		= "ターゲットをデスリストに追加したキャラクターの名前を表示します."
L.DLAddon_MarkPlayers		= "マーキングプレーヤーを許可する"
L.DLAddon_MarkPlayersTip	= "あなたが他のプレイヤーをデスリストに追加することを可能にします."
L.DLAddon_ShowDebug			= "デバッグを表示"
L.DLAddon_ShowDebugTip		= "死亡リスト機能を実行するときにチャット通知を表示します."
L.DLAddon_MarkColor			= "アイコンの色を選択"
L.DLAddon_MarkColorTip		= "デスリストマークのターゲットアイコンの色を設定します."
L.DLAddon_TextColor			= "文字色を選択"
L.DLAddon_TextColorTip		= "ターゲットをデスリストに追加したキャラクターの名前の色を設定します."
L.DLAddon_MarkSize			= "アイコンサイズを選択"
L.DLAddon_MarkSizeTip		= "ターゲットアイコンとマークされたデスリストのサイズを設定します."
L.DLAddon_ChatCommants		= "チャットコマンド"
L.DLAddon_PrintList			= "あなたの死亡リストの内容を印刷します."
L.DLAddon_RemoveName		= "指定された名前を死亡リストから削除します（引用符なし）."
L.DLAddon_ClearList			= "あなたの死亡リストからすべての目標をクリアしてください."
L.DLAddon_Name				= "名"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(DLAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DLAddon:GetLanguage() -- set new language return
		return L
	end
end
