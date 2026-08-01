local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Japanese
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "すべてを切り替える"
L.EAC_ToggleSounds				= "すべての音を切り替えます"
L.EAC_ToggleMusic				= "音楽を切り替えます"
L.EAC_ToggleAmbient				= "アンビエントサウンドを切り替える"
L.EAC_ToggleEffects				= "エフェクト音を切り替えます"
L.EAC_ToggleFootsteps			= "足跡を切り替えます"
L.EAC_ToggleDialogue			= "ダイアログサウンドを切り替えます"
L.EAC_ToggleInterface			= "インターフェイスの音を切り替えます"
L.EAC_ToggleCinematic			= "映画の音を切り替えます"
L.EAC_ToggleCombat				= "戦闘音楽を切り替えます"

-- Binding output strings
L.EAC_AllOn						= "サウンドがグローバルに有効になっています。"
L.EAC_AllOff					= "グローバルにサウンドが無効になっています。"
L.EAC_SoundOn					= "すべてのサウンドが有効になっています。"
L.EAC_SoundOff					= "すべてのサウンドは無効になっています。"
L.EAC_MusicOn					= "音楽が有効になっています。"
L.EAC_MusicOff					= "音楽が無効になっています。"
L.EAC_AmbientOn					= "アンビエントサウンドが有効になりました。"
L.EAC_AmbientOff				= "アンビエントサウンドは無効になっています。"
L.EAC_EffectsOn					= "エフェクトサウンドが有効になります。"
L.EAC_EffectsOff				= "効果音は無効になります。"
L.EAC_FootstepsOn				= "フットステップが有効になっています。"
L.EAC_FootstepsOff				= "足跡は無効になっています。"
L.EAC_DialogueOn				= "対話音が有効にします。"
L.EAC_DialogueOff				= "対話音が無効にします。"
L.EAC_InterfaceOn				= "インターフェイスサウンドが有効になっています。"
L.EAC_InterfaceOff				= "インターフェイスサウンドは無効になります。"
L.EAC_CinematicOn				= "映画音が有効にしました。"
L.EAC_CinematicOff				= "映画音が無効にします。"
L.EAC_CombatAllOn				= "すべての戦闘音楽が有効になっています。"
L.EAC_CombatAllOff				= "戦闘音楽が無効になっています。"
L.EAC_CombatBossOn				= "ボス戦闘音楽が有効になっています。"

-- Settings menu strings
L.EAC_MenuTitle					= "オーディオコントロール"
L.EAC_MenuGlobalOpts			= "グローバルオーディオオプション"
L.EAC_MenuMaster				= "マスターオーディオトグル"
L.EAC_MenuMasterTip				= "グローバルにすべてのゲームサウンドと音楽を有効または無効にします。"
L.EAC_MenuSounds				= "すべての音が切り替えます"
L.EAC_MenuSoundsTip				= "以下のすべてのサウンドタイプをグローバルに有効または無効にします。"
L.EAC_MenuIndividual			= "個々のサウンドタイプ"
L.EAC_MenuIndividualTip			= "設定はログイン＆ログアウト、およびすべての文字を介して維持されます。"
L.EAC_MenuAmbient				= "アンビエントサウンドトグル"
L.EAC_MenuAmbientTip			= "ゲームの周囲の音を有効または無効にします。"
L.EAC_MenuEffects				= "効果音が切り替えます"
L.EAC_MenuEffectsTip			= "ゲームエフェクトサウンドを有効または無効にします。"
L.EAC_MenuFootstep				= "足跡音が切り替えます"
L.EAC_MenuFootstepTip			= "ゲームの足元のサウンドを有効または無効にします。"
L.EAC_MenuDialogue				= "ダイアログサウンドトグル"
L.EAC_MenuDialogueTip			= "ゲームダイアログの音を有効または無効にします。"
L.EAC_MenuInterface				= "インターフェースサウンドトグル"
L.EAC_MenuInterfaceTip			= "ゲームインターフェイスのサウンドを有効または無効にします。"
L.EAC_MenuCinematic				= "映画音の切り替え"
L.EAC_MenuCinematicTip			= "ゲーム映画のサウンドを有効または無効にします。"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ja') or (GetCVar('language.2') == 'jp') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
