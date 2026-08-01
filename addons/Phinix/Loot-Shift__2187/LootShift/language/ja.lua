local LSAddon = _G['LSAddon']
local L = {}

--------------------------------------------------------------------------------------------------------------------
-- Japanese (Needs human translation!)
--------------------------------------------------------------------------------------------------------------------

L.BindingString					= "代替ルートモード"
L.ToggleLootMode				= "ルートモードの切り替え"
L.ReloadState					= "リロード後の値"
L.AutoLootNConfig				= "自動ルート設定"
L.AutoLootNDefault				= "デフォルトオートルート"
L.AutoLootNDefaultTip			= "'Auto Loot'ゲーム設定のグローバルデフォルトを設定します。 有効にすると、UIまたはリロッグをリロードするたびに 'リロード後の値'で選択された値にリセットされます。"
L.AutoLootNReloadTip			= "UIを再読み込みするときや、再ログアウトするときに、 'Auto Loot'オプションのアカウント全体のデフォルトを選択します。"
L.AutoLootSConfig				= "自動盗難の設定"
L.AutoLootSDefault				= "デフォルトの自動盗難"
L.AutoLootSDefaultTip			= "'Auto Loot Stolen Items'ゲーム設定のグローバルデフォルトを設定します。 有効にすると、UIまたはリロッグをリロードするたびに 'リロード後の値'で選択された値にリセットされます。"
L.AutoLootSReloadTip			= "UIを再読み込みするときや、再ログアウトするときに、 'Auto Loot Stolen Items'オプションのアカウント全体のデフォルトを選択します。"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(LSAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function LSAddon:GetLanguage() -- set new language return
		return L
	end
end
