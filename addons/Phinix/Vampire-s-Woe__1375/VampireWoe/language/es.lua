local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

--General strings
L.AddonTitle				= "Ay del Vampiro"
L.KeybindToggle				= "Supresión de palanca"
L.KeybindInnocent			= "Alternar 'atacar inocentes'"
L.KeybindCriminal			= "Bloquear habilidades delictivas"
L.FeedToggleOn				= "Ya no se suprime la sinergia de Alimentación de Vampiros."
L.FeedToggleOff				= "La sinergia de Alimentación de Vampiros está siendo suprimida."
L.BladeToggleOn				= "La sinergia de Hoja de la Aflicción ya no se suprime."
L.BladeToggleOff			= "Se está suprimiendo la sinergia de Hoja de la Aflicción."
L.SwapToggleV				= "Vampiro de alimentación suprimido, hoja de aflicción habilitada."
L.SwapToggleB				= "Hoja de aflicción suprimida, alimentación de vampiros habilitada.."
L.AddonToggleOn				= "Ay del Vampiro está habilitado."
L.AddonToggleOff			= "Ay del Vampiro está inhabilitado."
L.KeybindInnoOn				= "'Atacar inocentes' está habilitado."
L.KeybindInnoOff			= "'Atacar inocentes' está desactivado."
L.BlockCrimeOn				= "Bloque usando habilidades de 'acción criminal': On."
L.BlockCrimeOff				= "Bloque usando habilidades de 'acción criminal': Off."
L.AbilityBlocked			= "Vampire's Woe: Capacidad bloqueada por el ajuste del crimen."

--Settings strings
L.EnableAddon				= "Habilitar complemento"
L.EnableAddonTip			= "Habilitar/deshabilitar la funcionalidad del complemento."
L.KeybindOption				= "Función de enlace de teclas"
L.KeybindOptionTip			= "Establezca el comportamiento al presionar el enlace de Supresión de alternancia."
L.KeyOption1				= "Alimentación de palanca"
L.KeyOption2				= "Cuchilla de palanca"
L.KeyOption3				= "Cambiar entre"
L.KeyOption4				= "Habilitar/deshabilitar"
L.AllowAlly					= "Permitir picar aliado"
L.AllowAllyTip				= "Te permite morder y pasar el vampirismo a un aliado incluso cuando se suprime la sinergia de alimentación."
L.AutoInnocent				= "Alternar inocente automático"
L.AutoInnocentTip			= "Desactive automáticamente 'Prevenir el ataque de inocentes' cuando se muestre la sinergia Vampire Feed o Blade of Woe."
L.ShowDebug					= "Mostrar depuración"
L.ShowDebugTip				= "Muestra un aviso de chat cuando la alimentación de vampiros o la hoja de aflicción se activa/desactiva mediante el enlace de teclas."
L.Status					= "Estado de supresión"
L.FeedSetting				= "Suprimir la alimentación de vampiros"
L.FeedSettingTip			= "Bloquea la activación de la sinergia de alimentación de vampiros."
L.AutoStage					= "Habilitar escenario máximo"
L.AutoStageTip				= "Cuando está marcada, la alimentación de vampiros se habilitará incluso si la configuración anterior está marcada si su etapa actual es inferior a la etapa máxima establecida a continuación."
L.MaxStage					= "Establecer escenario máximo"
L.MaxStageTip				= "La sinergia de alimentación de vampiros se suprimirá cuando tu etapa actual sea mayor o igual a este límite."
L.BladeSetting				= "Suprimir la hoja de la aflicción"
L.BladeSettingTip			= "Bloquea la cuchilla de la sinergia de la activación."
L.CriminalSetting			= "Bloquear habilidades de 'acto criminal'."
L.CriminalSettingTip		= "Previene habilidades marcadas como 'acto criminal' de ser utilizado."

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(VWoe:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function VWoe:GetLanguage() -- set new language return
		return L
	end
end
