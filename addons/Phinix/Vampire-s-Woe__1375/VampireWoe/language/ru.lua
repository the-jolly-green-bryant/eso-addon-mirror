local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Russian translation by ESOUI.com user equidingo.
-- (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

--General strings
	L.AddonTitle				= "Vampire's Woe"
	L.KeybindToggle				= "Переключить подавление синергии"
L.KeybindInnocent			= "Переключить «атакующих невинных»"
L.KeybindCriminal			= "Блокируйте преступные способности"
	L.FeedToggleOn				= "Синергия кормления вампира больше не подавляется."
	L.FeedToggleOff				= "Синергия кормления вампира подавляется."
	L.BladeToggleOn				= "Синергия Клинка Горя больше не подавляется."
	L.BladeToggleOff			= "Синергия Клинка Горя подавляется."
	L.SwapToggleV				= "Кормление вампира подавлено, Клинок Горя включен."
	L.SwapToggleB				= "Клинок Горя подавлен, кормление вампира включено."
	L.AddonToggleOn				= "Аддон Vampire's Woe включен."
	L.AddonToggleOff			= "Аддон Vampire's Woe отключен."
L.KeybindInnoOn				= "«Атакующий невинных» включен."
L.KeybindInnoOff			= "«Атакующий невинных» отключен."
L.BlockCrimeOn				= "Блок, используя навыки «Уголовное действие»: на."
L.BlockCrimeOff				= "Блок, используя навыки «Уголовное действие»: выключен."
L.AbilityBlocked			= "Vampire's Woe: Возможность заблокирована преступностью."

--Settings strings
	L.EnableAddon				= "Включить аддон"
	L.EnableAddonTip			= "Включение/отключение аддона."
	L.KeybindOption				= "Функция назначенной клавиши"
	L.KeybindOptionTip			= "Установите выполняемое действие при нажатии клавиши включения подавления."
	L.KeyOption1				= "Переключить кормление"
	L.KeyOption2				= "Переключить Клинок"
	L.KeyOption3				= "Переключение между"
	L.KeyOption4				= "Включить/выключить"
	L.AllowAlly					= "Кусать союзника при подавлении"
	L.AllowAllyTip				= "Позволяет вам кусать и передавать вампиризм союзнику, даже когда синергия кормления подавляется."
L.AutoInnocent				= "Автоматический невинный переключатель"
L.AutoInnocentTip			= "Автоматически отключать «Предотвратить нападение на невинных», когда отображается синергия Vampire Feed или Blade of Woe."
	L.ShowDebug					= "Показать сообщения отладки"
	L.ShowDebugTip				= "Показывет уведомление в чате, когда вампирское кормление или Клинок Горя включается/выключается нажатием клавиши."
	L.Status					= "Статус подавления"
	L.FeedSetting				= "Подавлять синергию кормления вампира"
	L.FeedSettingTip			= "Блокирует срабатывание синергии кормления вампира."
L.AutoStage					= "Включить максимальный уровень"
L.AutoStageTip				= "Если этот флажок установлен, кормление вампиров будет включено, даже если указанный выше параметр отмечен, если ваша текущая стадия ниже максимальной стадии, установленной ниже."
L.MaxStage					= "Установить максимальный уровень"
L.MaxStageTip				= "Синергия вампирского корма будет подавлена, если ваша текущая стадия больше или равна этому пределу."
	L.BladeSetting				= "Подавлять синергию Клинка Горя"
	L.BladeSettingTip			= "Блокирует срабатывание синергии Клинка Горя."
L.CriminalSetting			= "Блокируйте способности преступного акта."
L.CriminalSettingTip		= "Предотвращает способности, отмеченные как «преступный акт» от того, чтобы быть актуальным."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'ru') then -- overwrite GetLanguage for new language
	for k,v in pairs(VWoe:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function VWoe:GetLanguage() -- set new language return
		return L
	end
end
