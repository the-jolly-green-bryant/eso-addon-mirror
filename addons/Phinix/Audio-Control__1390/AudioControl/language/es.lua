local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Spanish
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "Alternar todo"
L.EAC_ToggleSounds				= "Alternar todos los sonidos"
L.EAC_ToggleMusic				= "Alternar música"
L.EAC_ToggleAmbient				= "Alternar sonidos ambientales"
L.EAC_ToggleEffects				= "Efecto de palanca sonidos"
L.EAC_ToggleFootsteps			= "Pisos de palanca"
L.EAC_ToggleDialogue			= "Alternar el sonido de diálogo"
L.EAC_ToggleInterface			= "Suena de interfaz de palanca"
L.EAC_ToggleCinematic			= "Toggle sonidos cinematográficos"
L.EAC_ToggleCombat				= "Alternar música de combate"

-- Binding output strings
L.EAC_AllOn						= "Sonido habilitado globalmente."
L.EAC_AllOff					= "Sonido deshabilitado globalmente."
L.EAC_SoundOn					= "Todos los sonidos habilitados."
L.EAC_SoundOff					= "Todos los sonidos deshabilitados."
L.EAC_MusicOn					= "Música habilitada."
L.EAC_MusicOff					= "Música deshabilitada."
L.EAC_AmbientOn					= "Sonidos ambientales habilitados."
L.EAC_AmbientOff				= "Sonidos ambientales deshabilitados."
L.EAC_EffectsOn					= "Efecto sonidos habilitados."
L.EAC_EffectsOff				= "Efecto sonidos deshabilitados."
L.EAC_FootstepsOn				= "Pasos habilitados."
L.EAC_FootstepsOff				= "Pasos deshabilitados."
L.EAC_DialogueOn				= "Diálogo de sonido habilitado."
L.EAC_DialogueOff				= "Diálogo de sonido deshabilitado."
L.EAC_InterfaceOn				= "Sonidos de interfaz habilitados."
L.EAC_InterfaceOff				= "Sonidos de interfaz deshabilitados."
L.EAC_CinematicOn				= "Sonido cinematográfico habilitado."
L.EAC_CinematicOff				= "Sonido cinematográfico deshabilitado."
L.EAC_CombatAllOn				= "Toda la música de combate habilitada."
L.EAC_CombatAllOff				= "Música de combate desactivada."
L.EAC_CombatBossOn				= "Música de combate de jefe habilitado."

-- Settings menu strings
L.EAC_MenuTitle					= "Control de audio"
L.EAC_MenuGlobalOpts			= "Opciones de audio globales"
L.EAC_MenuMaster				= "Maestro de alternar de audio."
L.EAC_MenuMasterTip				= "Habilitar o deshabilitar todo el sonido del juego y la música globalmente."
L.EAC_MenuSounds				= "Todos los sonidos alternan"
L.EAC_MenuSoundsTip				= "Habilitar o deshabilitar todos los tipos de sonido a continuación."
L.EAC_MenuIndividual			= "Tipos de sonido individuales"
L.EAC_MenuIndividualTip			= "Los ajustes se mantienen a través de inicio de sesión y cierre de sesión y sobre todos los caracteres."
L.EAC_MenuAmbient				= "Toggle de sonido ambiental"
L.EAC_MenuAmbientTip			= "Habilitar o deshabilitar los sonidos ambientales del juego."
L.EAC_MenuEffects				= "Efecto de alternar"
L.EAC_MenuEffectsTip			= "Habilitar o deshabilitar los sonidos del efecto del juego."
L.EAC_MenuFootstep				= "Pisado de pisaje de sonido"
L.EAC_MenuFootstepTip			= "Habilitar o deshabilitar los sonidos de los pies del juego."
L.EAC_MenuDialogue				= "Diálogo alternar"
L.EAC_MenuDialogueTip			= "Habilitar o deshabilitar los sonidos del diálogo del juego."
L.EAC_MenuInterface				= "Toggle de sonido de la interfaz"
L.EAC_MenuInterfaceTip			= "Habilitar o deshabilitar los sonidos de la interfaz del juego."
L.EAC_MenuCinematic				= "Palanca de sonido cinematográfico"
L.EAC_MenuCinematicTip			= "Habilitar o deshabilitar los sonidos cinematográficos."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'es') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
