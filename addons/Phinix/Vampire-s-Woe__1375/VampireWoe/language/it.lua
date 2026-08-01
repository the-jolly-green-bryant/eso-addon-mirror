local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

--General strings
L.AddonTitle				= "La Pena del Vampiro"
L.KeybindToggle				= "Commuta soppressione"
L.KeybindInnocent			= "'Attaccare gli innocenti'"
L.KeybindCriminal			= "Bloccare le abilità criminali"
L.FeedToggleOn				= "La sinergia dei Alimentazione per Vampiri non è più soppressa."
L.FeedToggleOff				= "La sinergia dei Alimentazione per Vampiri viene soppressa."
L.BladeToggleOn				= "La sinergia di Lama di Dolore non viene più soppressa."
L.BladeToggleOff			= "La sinergia di Lama di Dolore viene soppressa."
L.SwapToggleV				= "Alimentazione del vampiro soppressa, Lama di Dolore attivata."
L.SwapToggleB				= "Lama di Dolore repressa, alimentazione dei vampiri abilitata."
L.AddonToggleOn				= "La Pena del Vampiro abilitato."
L.AddonToggleOff			= "La Pena del Vampiro disabilitato."
L.KeybindInnoOn				= "'Attaccare gli innocenti' è abilitato."
L.KeybindInnoOff			= "'Attaccare gli innocenti' è disabilitato."
L.BlockCrimeOn				= "Bloccare usando le abilità di 'azione criminale': acceso."
L.BlockCrimeOff				= "Bloccare usando le abilità di 'azione criminale': spento."
L.AbilityBlocked			= "Vampire's Woe: Abilità bloccata dal crimine config."

--Settings strings
L.EnableAddon				= "Abilita Addon"
L.EnableAddonTip			= "Abilita/Disabilita la funzionalità di aggiunta."
L.KeybindOption				= "Funzione di combinazione di tasti"
L.KeybindOptionTip			= "Impostare il comportamento quando si preme il tasto di controllo Soppressione interruzione."
L.KeyOption1				= "Attiva l'alimentazione"
L.KeyOption2				= "Attiva la lama"
L.KeyOption3				= "Cambia tra"
L.KeyOption4				= "Abilita/Disabilita"
L.AllowAlly					= "Consentire alleato morso"
L.AllowAllyTip				= "Ti permette di mordere e passare il vampirismo ad un alleato anche quando la sinergia di alimentazione viene soppressa."
L.AutoInnocent				= "Commutazione automatica innocente"
L.AutoInnocentTip			= "Disattiva automaticamente 'Prevenire l'attacco agli innocenti' quando viene mostrata la sinergia di Mangime per vampiri o Lama del dolore."
L.ShowDebug					= "Mostra debug"
L.ShowDebugTip				= "Mostra un avviso di chat quando l'alimentazione del vampiro o la lama di sventura viene attivata/disattivata utilizzando la combinazione di tasti."
L.Status					= "Stato di soppressione"
L.FeedSetting				= "Sopprimere l'alimentazione del vampiro"
L.FeedSettingTip			= "Blocca il vampiro che alimenta la sinergia dall'innescare."
L.AutoStage					= "Abilita livello massimo"
L.AutoStageTip				= "Se selezionata, l'alimentazione dei vampiri sarà abilitata anche se l'impostazione sopra è selezionata se il livello attuale è inferiore al livello massimo impostato di seguito."
L.MaxStage					= "Imposta livello massimo"
L.MaxStageTip				= "La sinergia del cibo dei vampiri verrà soppressa quando la tua fase attuale è maggiore o uguale a questo limite."
L.BladeSetting				= "Elimina la lama della sventura"
L.BladeSettingTip			= "Blocca la lama della sinergia sinergica dal grilletto."
L.CriminalSetting			= "Blocca le abilità 'Atti criminali'."
L.CriminalSettingTip		= "Impedisce il lancio di abilità contrassegnate come 'Atto criminale'."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(VWoe:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function VWoe:GetLanguage() -- set new language return
		return L
	end
end
