local ShowMotifs = _G['ShowMotifs']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
L.GENERAL					= "一般"
L.ICON_THEME				= "アイコンのテーマ"
L.ICON_THEME_TOOLTIP		= "アイコンのテーマを選択してください。\n\nインベントリグリッドビューアドオンユーザの注：アイコンは「グリッド」モードでは表示されません。"
L.ICON_SIZE					= "人種モチーフアイコンサイズ"
L.ICON_SIZE_TOOLTIP			= "S人種モチーフアイコンのサイズを設定する"
L.ARMOR_ICON_SIZE			= "アーマータイプのアイコンサイズ"
L.ARMOR_ICON_SIZE_TOOLTIP	= "装甲タイプのアイコンのサイズを設定する"
L.II_POSITION				= "在庫アイコンの位置"
L.II_POSITION_TOOLTIP		= "インベントリリストの左端を基準にしたアイコンの位置を設定する"
L.GSS_POSITION				= "ギルドストアアイコンの位置"
L.GSS_POSITION_TOOLTIP		= "ギルドストアの検索結果リストの左端に相対的なアイコンの位置を設定する"
L.GSL_POSITION				= "ギルドリストアイコンの位置"
L.GSL_POSITION_TOOLTIP		= "ギルドストアリストパネルの左端を基準にしたアイコンの位置を設定する"
L.RACIAL					= "人種モチーフアイコンを表示する"
L.RACIAL_TOOLTIP			= "人種モチーフアイコンを表示します。\n\nインベントリグリッドビューアドオンユーザの注意：アイコンは「グリッド」モードでは表示されません"
L.ARMOR						= "鎧のタイプを表示するアイコン"
L.ARMOR_TOOLTIP				= "装甲タイプのアイコンを表示する。\n\nインベントリグリッドビューアドオンユーザの注意：アイコンは「グリッド」モードでは表示されません"
L.LETTER					= "文字を使う"
L.LETTER_TOOLTIP			= "装甲タイプのグラフィックシンボルの代わりに文字を表示する"
L.COLOR						= "品質カラーを使用する"
L.COLOR_TOOLTIP				= "アイテムの品質に応じてアイコンの色を設定する"
L.TOOLTIP					= "ツールチップを表示"
L.TOOLTIP_TOOLTIP			= "マウスのホバー上のアイコンのツールチップを表示します。\n\nインベントリグリッドビューアドオンユーザの注意：アイコンは「グリッド」モードでは表示されません"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k, v in pairs(ShowMotifs:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function ShowMotifs:GetLanguage() -- set new language return
		return L
	end
end
