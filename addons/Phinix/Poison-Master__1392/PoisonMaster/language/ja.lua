local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PMAddon_GLOBAL			= "グローバルオプション"
L.PMAddon_LOCK				= "ロック位置"
L.PMAddon_LOCKTIP			= "毒設定ウィンドウを移動しないようにします。"
L.PMAddon_BACK				= "背景を隠す"
L.PMAddon_BACKTIP			= "ポイズン設定ウィンドウの背景を隠します。"
L.PMAddon_ICONS				= "装備アイコンを表示"
L.PMAddon_ICONSTIP			= "お気に入りのスロットに割り当てられたときにあなたのアクティブと非アクティブの武器毒のアイコンインジケーターを表示します。"
L.PMAddon_THEME				= "装備アイコンのテーマ"
L.PMAddon_THEMETIP			= "装備毒インジケーターのスタイルを選択してください。"
L.PMAddon_STYLE1			= "国境"
L.PMAddon_STYLE2			= "チェック"
L.PMAddon_DEBUG				= "デバッグテキストを表示"
L.PMAddon_DEBUGTIP			= "特定のことが起こったときにチャットで説明文を表示します。"
L.PMAddon_Tooltip			= "Shift +クリックで装備毒をスロットに割り当てます 右クリックして消去します。"

-- Keybind strings
L.PMAddon_KBT				= "毒設定ウィンドウの切り替え"
L.PMAddon_KB1				= "スロット1毒の装備/未装備"
L.PMAddon_KB2				= "スロット2毒の装備/未装備"
L.PMAddon_KB3				= "スロット3毒の装備/未装備"
L.PMAddon_KB4				= "スロット4毒の装備/未装備"

-- Debug strings
L.PMAddon_PNE				= "欲しい毒はもうあなたのかばんに入っていません。"
L.PMAddon_NPE				= "アクティブな武器には装備するべき毒がありません"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(PMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PMAddon:GetLanguage() -- set new language return
		return L
	end
end
