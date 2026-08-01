local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

--General strings
L.AddonTitle				= "ヴァンパイアの悲哀"
L.KeybindToggle				= "抑制を切り替える"
L.KeybindInnocent			= "「無実の攻撃」を切り替えます"
L.KeybindCriminal			= "犯罪能力をブロックします"
L.FeedToggleOn				= "ヴァンパイアフィードの相乗効果はもはや抑制されていません。"
L.FeedToggleOff				= "ヴァンパイアフィードのシナジーが抑えられています。"
L.BladeToggleOn				= "悲惨な相乗効果の刃はもはや抑制されません。"
L.BladeToggleOff			= "相乗効果の刃が抑制されています。"
L.SwapToggleV				= "吸血鬼の餌が抑えられ、悲惨な刃が可能になりました。"
L.SwapToggleB				= "悲惨な刃、抑圧された吸血鬼の刃。"
L.AddonToggleOn				= "ヴァンパイアの不幸が有効になりました。"
L.AddonToggleOff			= "ヴァンパイアの悲惨な障害。"
L.KeybindInnoOn				= "「無実の攻撃」が有効になっています"
L.KeybindInnoOff			= "「無害な攻撃」は無効になっています"
L.BlockCrimeOn				= "「犯罪行動」スキルを使用してブロックする：ON。"
L.BlockCrimeOff				= "「犯罪行動」スキルを使用してブロックする：OFF。"
L.AbilityBlocked			= "Vampire's Woe: 能力は犯罪構成によって妨げられました。"

--Settings strings
L.EnableAddon				= "アドオンを有効にする"
L.EnableAddonTip			= "アドオン機能を有効/無効にします。"
L.KeybindOption				= "キーバインディング機能"
L.KeybindOptionTip			= "トグル抑制キーバインドを押したときの動作を設定します。"
L.KeyOption1				= "給餌をトグル"
L.KeyOption2				= "トグルブレード"
L.KeyOption3				= "スイッチを切り替える"
L.KeyOption4				= "有効/無効"
L.AllowAlly					= "噛む許可"
L.AllowAllyTip				= "摂食の相乗効果が抑制されているときでも、あなたは味方を味方に噛んで渡すことができます。"
L.AutoInnocent				= "自動イノセントトグル"
L.AutoInnocentTip			= "VampireFeedまたはBladeofWoeの相乗効果が表示されたときに、「PreventAttackingInnocents」を自動的に無効にします。"
L.ShowDebug					= "デバッグを表示"
L.ShowDebugTip				= "吸血鬼の餌や悲しみの刃がキーバインドを使用してオン/オフされると、チャット通知を表示します。"
L.Status					= "抑制ステータス"
L.FeedSetting				= "吸血鬼の餌を抑える"
L.FeedSettingTip			= "吸血鬼の摂食の相乗効果を引き起こさないようにする。"
L.AutoStage					= "最大ステージを有効にする"
L.AutoStageTip				= "チェックすると、現在のステージが以下に設定された最大ステージより低い場合、上記の設定がチェックされていても、吸血鬼の餌食が有効になります。"
L.MaxStage					= "最大ステージを設定する"
L.MaxStageTip				= "現在のステージがこの制限以上になると、ヴァンパイア フィード シナジーは抑制されます。"
L.BladeSetting				= "苦難の刃を抑える"
L.BladeSettingTip			= "災いの相乗効果の刃をトリガーからブロックします。"
L.CriminalSetting			= "ブロック「犯罪行為」能力。"
L.CriminalSettingTip		= "「犯罪行為」としてマークされた能力がキャストされるのを防ぎます。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(VWoe:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function VWoe:GetLanguage() -- set new language return
		return L
	end
end
