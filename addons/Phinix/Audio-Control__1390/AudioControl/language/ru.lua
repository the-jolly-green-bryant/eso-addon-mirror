local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "Переключите все"
L.EAC_ToggleSounds				= "Переключите все звуки"
L.EAC_ToggleMusic				= "Переключить музыку"
L.EAC_ToggleAmbient				= "Переключите окружающие звуки"
L.EAC_ToggleEffects				= "Звуки переключения эффекта"
L.EAC_ToggleFootsteps			= "Переключать шаги"
L.EAC_ToggleDialogue			= "Туманный диалог звук"
L.EAC_ToggleInterface			= "Звуки интерфейса переключения"
L.EAC_ToggleCinematic			= "Переключить кинематографические звуки"
L.EAC_ToggleCombat				= "Переключить боевую музыку"

-- Binding output strings
L.EAC_AllOn						= "Звук включен по всему миру."
L.EAC_AllOff					= "Звук отключен глобально."
L.EAC_SoundOn					= "Все звуки включены."
L.EAC_SoundOff					= "Все звуки отключены."
L.EAC_MusicOn					= "Музыка включена."
L.EAC_MusicOff					= "Музыка отключена."
L.EAC_AmbientOn					= "Эмбиентные звуки включены."
L.EAC_AmbientOff				= "Эмбиентные звуки отключены."
L.EAC_EffectsOn					= "Эффект звучит включен."
L.EAC_EffectsOff				= "Эффект звучит отключен."
L.EAC_FootstepsOn				= "Шаги включены."
L.EAC_FootstepsOff				= "Шаги отключены."
L.EAC_DialogueOn				= "Диалог звук включен."
L.EAC_DialogueOff				= "Диалог звук отключен."
L.EAC_InterfaceOn				= "Интерфейс звучит включен."
L.EAC_InterfaceOff				= "Интерфейс звуки отключен."
L.EAC_CinematicOn				= "Кинематочный звук включен."
L.EAC_CinematicOff				= "Кинемассовый звук отключен."
L.EAC_CombatAllOn				= "Вся боевая музыка включена."
L.EAC_CombatAllOff				= "Боевая музыка отключена."
L.EAC_CombatBossOn				= "Босс боевой музыки включен."

-- Settings menu strings
L.EAC_MenuTitle					= "Аудио контроль"
L.EAC_MenuGlobalOpts			= "Глобальные аудио варианты"
L.EAC_MenuMaster				= "Мастер аудио тумблер"
L.EAC_MenuMasterTip				= "Включить или отключить все игровые звуки и музыку глобально."
L.EAC_MenuSounds				= "Все звуки переключаются"
L.EAC_MenuSoundsTip				= "Включить или отключить все ниже типов звуковых сигналов в мире."
L.EAC_MenuIndividual			= "Индивидуальные типы звуков"
L.EAC_MenuIndividualTip			= "Настройки сохраняются через логин и выйти и все символы."
L.EAC_MenuAmbient				= "Окружающий звуковой тумблер"
L.EAC_MenuAmbientTip			= "Включить или отключить игру Ambient."
L.EAC_MenuEffects				= "Эффект звуковой тумблер"
L.EAC_MenuEffectsTip			= "Включить или отключить звуки эффекта игры."
L.EAC_MenuFootstep				= "Шаг звукового переключателя"
L.EAC_MenuFootstepTip			= "Включить или отключить звуки игрового шага."
L.EAC_MenuDialogue				= "Диалог звук тумана"
L.EAC_MenuDialogueTip			= "Включить или отключить звуки диалоговых звуков."
L.EAC_MenuInterface				= "Интерфейс Sound Toggle."
L.EAC_MenuInterfaceTip			= "Включить или отключить звуки игрового интерфейса."
L.EAC_MenuCinematic				= "Кинематографический звук"
L.EAC_MenuCinematicTip			= "Включить или отключить игровые кинематографические звуки."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
