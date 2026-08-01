local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- Polish
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "Przełącz wszystko"
L.EAC_ToggleSounds				= "Przełącz wszystkie dźwięki"
L.EAC_ToggleMusic				= "Przełącz muzykę"
L.EAC_ToggleAmbient				= "Przełącz dźwięki otoczenia"
L.EAC_ToggleEffects				= "Przełącz dźwięki efektów"
L.EAC_ToggleFootsteps			= "Przełącz kroki"
L.EAC_ToggleDialogue			= "Przełącz dźwięk dialogu"
L.EAC_ToggleInterface			= "Przełącz dźwięki interfejsu"
L.EAC_ToggleCinematic			= "Przełącz dźwięki kinowe"
L.EAC_ToggleCombat				= "Przełącz muzykę bojową"

-- Binding output strings
L.EAC_AllOn						= "Dźwięk włączony globalnie."
L.EAC_AllOff					= "Dźwięk wyłączony globalnie."
L.EAC_SoundOn					= "Wszystkie dźwięki włączone."
L.EAC_SoundOff					= "Wszystkie dźwięki wyłączone."
L.EAC_MusicOn					= "Włączona muzyka."
L.EAC_MusicOff					= "Muzyka wyłączona."
L.EAC_AmbientOn					= "Włączone dźwięki otoczenia."
L.EAC_AmbientOff				= "Dźwięki otoczenia wyłączone."
L.EAC_EffectsOn					= "Efekt dźwięków włączony."
L.EAC_EffectsOff				= "Dźwięki efektu wyłączone."
L.EAC_FootstepsOn				= "Włączone ślady"
L.EAC_FootstepsOff				= "Pociągi wyłączone."
L.EAC_DialogueOn				= "Włączona dźwięk dialogu."
L.EAC_DialogueOff				= "Dialog dźwięk wyłączony."
L.EAC_InterfaceOn				= "Włączone dźwięki interfejsu."
L.EAC_InterfaceOff				= "Dźwięki interfejsu wyłączone."
L.EAC_CinematicOn				= "Włączony dźwięk kinowy."
L.EAC_CinematicOff				= "Wyłączony dźwięk kinowy."
L.EAC_CombatAllOn				= "Włączona muzyka bojowa."
L.EAC_CombatAllOff				= "Muzyka bojowa wyłączona."
L.EAC_CombatBossOn				= "Włączona muzyka bojowa bossa."

-- Settings menu strings
L.EAC_MenuTitle					= "Kontrola dźwięku"
L.EAC_MenuGlobalOpts			= "Globalne opcje dźwięku"
L.EAC_MenuMaster				= "Master audio przełącznik."
L.EAC_MenuMasterTip				= "Włącz lub wyłącz wszystkie dźwięki gry i muzykę na całym świecie."
L.EAC_MenuSounds				= "Wszystkie dźwięki przełączają się"
L.EAC_MenuSoundsTip				= "Włącz lub wyłącz wszystkie poniższe typy dźwięków globalnie."
L.EAC_MenuIndividual			= "Indywidualne typy dźwięku."
L.EAC_MenuIndividualTip			= "Ustawienia są utrzymywane przez logowanie i wylogowanie i na wszystkich znakach."
L.EAC_MenuAmbient				= "Toggle dźwięku otoczenia"
L.EAC_MenuAmbientTip			= "Włącz lub wyłącz dźwięki ambientowe."
L.EAC_MenuEffects				= "Przełącznik dźwięku"
L.EAC_MenuEffectsTip			= "Włącz lub wyłącz dźwięki efektu gry."
L.EAC_MenuFootstep				= "Przełącznik dźwięku krokowego"
L.EAC_MenuFootstepTip			= "Włącz lub wyłącz dźwięki kroków."
L.EAC_MenuDialogue				= "Przełącznik dźwięku dialogowego."
L.EAC_MenuDialogueTip			= "Włącz lub wyłącz dźwięk dialogu gry."
L.EAC_MenuInterface				= "Przełącznik dźwięku interfejsu."
L.EAC_MenuInterfaceTip			= "Włącz lub wyłącz dźwięk interfejsu gry."
L.EAC_MenuCinematic				= "Toggle dźwięku kinowego"
L.EAC_MenuCinematicTip			= "Włącz lub wyłącz gry kinowe dźwięki."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'pl') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
