local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Italian
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "Attiva tutto"
L.EAC_ToggleSounds				= "Attiva/disattiva tutti i suoni"
L.EAC_ToggleMusic				= "Attiva/disattiva la musica"
L.EAC_ToggleAmbient				= "Attiva/disattiva suoni ambientali"
L.EAC_ToggleEffects				= "Attiva/disattiva effetto"
L.EAC_ToggleFootsteps			= "Attiva/disattiva le orme"
L.EAC_ToggleDialogue			= "Attiva/disattiva il suono del dialogo"
L.EAC_ToggleInterface			= "Attiva/disattiva i suoni dell'interfaccia"
L.EAC_ToggleCinematic			= "Attiva/disattiva suoni cinematografici"
L.EAC_ToggleCombat				= "Attiva/disattiva la musica da combattimento"

-- Binding output strings
L.EAC_AllOn						= "Sound Abilitato a livello globale."
L.EAC_AllOff					= "Suono disabilitato a livello globale."
L.EAC_SoundOn					= "Tutti i suoni abilitati."
L.EAC_SoundOff					= "Tutti i suoni disabilitati."
L.EAC_MusicOn					= "Musica abilitata."
L.EAC_MusicOff					= "Musica disabilitata."
L.EAC_AmbientOn					= "Suoni ambientali abilitati."
L.EAC_AmbientOff				= "Suoni ambient disabilitati."
L.EAC_EffectsOn					= "Effetto suoni abilitati."
L.EAC_EffectsOff				= "Effetto suona disabilitato."
L.EAC_FootstepsOn				= "Passi abilitati."
L.EAC_FootstepsOff				= "Passi disabilitati."
L.EAC_DialogueOn				= "Suono di dialogo Abilitato."
L.EAC_DialogueOff				= "Suono di dialogo disabilitato."
L.EAC_InterfaceOn				= "Suoni interfaccia abilitati."
L.EAC_InterfaceOff				= "Suoni interfaccia disabilitati."
L.EAC_CinematicOn				= "Suono cinematografico abilitato."
L.EAC_CinematicOff				= "Suono cinematografico disabilitato."
L.EAC_CombatAllOn				= "Combatti la musica abilitata."
L.EAC_CombatAllOff				= "Combatti la musica disabilitata."
L.EAC_CombatBossOn				= "Abilitato musica da combattimento Boss."

-- Settings menu strings
L.EAC_MenuTitle					= "Controllo audio"
L.EAC_MenuGlobalOpts			= "Opzioni audio globali"
L.EAC_MenuMaster				= "Passaggio audio principale"
L.EAC_MenuMasterTip				= "Abilita o disabilita tutto il suono del gioco e la musica a livello globale."
L.EAC_MenuSounds				= "Tutti i suoni commutano"
L.EAC_MenuSoundsTip				= "Abilita o disabilita tutti i seguenti tipi sonori globalmente."
L.EAC_MenuIndividual			= "Tipi di suono individuali"
L.EAC_MenuIndividualTip			= "Le impostazioni vengono mantenute tramite il login e il logout e su tutti i caratteri."
L.EAC_MenuAmbient				= "Toggle del suono ambientale"
L.EAC_MenuAmbientTip			= "Abilita o disabilita i suoni ambientali di Game."
L.EAC_MenuEffects				= "Effetto il suono del suono"
L.EAC_MenuEffectsTip			= "Abilita o disabilita i suoni dell'effetto di gioco."
L.EAC_MenuFootstep				= "Pagestep Sound Toggle."
L.EAC_MenuFootstepTip			= "Abilita o disabilita i suoni del passo del gioco."
L.EAC_MenuDialogue				= "Dialogue a disattivare il suono."
L.EAC_MenuDialogueTip			= "Abilita o disabilita i suoni di dialogo di gioco."
L.EAC_MenuInterface				= "Interfaccia a commutazione del suono"
L.EAC_MenuInterfaceTip			= "Abilita o disabilita i suoni dell'interfaccia di gioco."
L.EAC_MenuCinematic				= "Toggle del suono cinematografico"
L.EAC_MenuCinematicTip			= "Abilita o disabilita i suoni cinematografici di gioco."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'it') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
