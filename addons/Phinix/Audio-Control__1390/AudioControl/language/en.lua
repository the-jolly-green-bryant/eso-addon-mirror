local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- English
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
	L.EAC_ToggleAll					= "Toggle Everything"
	L.EAC_ToggleSounds				= "Toggle All Sounds"
	L.EAC_ToggleMusic				= "Toggle Music"
	L.EAC_ToggleAmbient				= "Toggle Ambient Sounds"
	L.EAC_ToggleEffects				= "Toggle Effect Sounds"
	L.EAC_ToggleFootsteps			= "Toggle Footsteps"
	L.EAC_ToggleDialogue			= "Toggle Dialogue Sound"
	L.EAC_ToggleInterface			= "Toggle Interface Sounds"
	L.EAC_ToggleCinematic			= "Toggle Cinematic Sounds"
	L.EAC_ToggleCombat				= "Toggle Combat Music"

-- Binding output strings
	L.EAC_AllOn						= "Sound enabled globally."
	L.EAC_AllOff					= "Sound disabled globally."
	L.EAC_SoundOn					= "All sounds enabled."
	L.EAC_SoundOff					= "All sounds disabled."
	L.EAC_MusicOn					= "Music enabled."
	L.EAC_MusicOff					= "Music disabled."
	L.EAC_AmbientOn					= "Ambient sounds enabled."
	L.EAC_AmbientOff				= "Ambient sounds disabled."
	L.EAC_EffectsOn					= "Effect sounds enabled."
	L.EAC_EffectsOff				= "Effect sounds disabled."
	L.EAC_FootstepsOn				= "Footsteps enabled."
	L.EAC_FootstepsOff				= "Footsteps disabled."
	L.EAC_DialogueOn				= "Dialogue sound enabled."
	L.EAC_DialogueOff				= "Dialogue sound disabled."
	L.EAC_InterfaceOn				= "Interface sounds enabled."
	L.EAC_InterfaceOff				= "Interface sounds disabled."
	L.EAC_CinematicOn				= "Cinematic sound enabled."
	L.EAC_CinematicOff				= "Cinematic sound disabled."
	L.EAC_CombatAllOn				= "All combat music enabled."
	L.EAC_CombatAllOff				= "Combat music disabled."
	L.EAC_CombatBossOn				= "Boss combat music enabled."

-- Settings menu strings
	L.EAC_MenuTitle					= "Audio Control"
	L.EAC_MenuGlobalOpts			= "Global Audio Options"
	L.EAC_MenuMaster				= "Master Audio Toggle"
	L.EAC_MenuMasterTip				= "Enable or disable all game sound and music globally."
	L.EAC_MenuSounds				= "All Sounds Toggle"
	L.EAC_MenuSoundsTip				= "Enable or disable all of the below sound types globally."
	L.EAC_MenuIndividual			= "Individual sound types"
	L.EAC_MenuIndividualTip			= "Settings are maintained through login & logout and over all characters."
	L.EAC_MenuAmbient				= "Ambient Sound Toggle"
	L.EAC_MenuAmbientTip			= "Enable or disable game Ambient sounds."
	L.EAC_MenuEffects				= "Effect Sound Toggle"
	L.EAC_MenuEffectsTip			= "Enable or disable game Effect sounds."
	L.EAC_MenuFootstep				= "Footstep Sound Toggle"
	L.EAC_MenuFootstepTip			= "Enable or disable game Footstep sounds."
	L.EAC_MenuDialogue				= "Dialogue Sound Toggle"
	L.EAC_MenuDialogueTip			= "Enable or disable game Dialogue sounds."
	L.EAC_MenuInterface				= "Interface Sound Toggle"
	L.EAC_MenuInterfaceTip			= "Enable or disable game Interface sounds."
	L.EAC_MenuCinematic				= "Cinematic Sound Toggle"
	L.EAC_MenuCinematicTip			= "Enable or disable game Cinematic sounds."


------------------------------------------------------------------------------------------------------------------

function EACAddon:GetLanguage() -- default locale, will be the return unless overwritten
	return L
end
