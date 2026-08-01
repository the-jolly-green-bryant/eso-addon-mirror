local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "Tout basculer"
L.EAC_ToggleSounds				= "Basculer tous les sons"
L.EAC_ToggleMusic				= "Basculer la musique"
L.EAC_ToggleAmbient				= "Basculer les sons ambiants"
L.EAC_ToggleEffects				= "Basculer les sons d'effet"
L.EAC_ToggleFootsteps			= "Basculer les traces"
L.EAC_ToggleDialogue			= "Basculer le son de dialogue"
L.EAC_ToggleInterface			= "Basculer les sons d'interface"
L.EAC_ToggleCinematic			= "Basculer les sons cinématographiques"
L.EAC_ToggleCombat				= "Basculer la musique de combat"

-- Binding output strings
L.EAC_AllOn						= "Son activé globalement."
L.EAC_AllOff					= "Son handicapé globalement."
L.EAC_SoundOn					= "Tous les sons activés."
L.EAC_SoundOff					= "Tous les sons handicapés."
L.EAC_MusicOn					= "Musique activée."
L.EAC_MusicOff					= "Musique désactivée."
L.EAC_AmbientOn					= "Sons ambiants activés."
L.EAC_AmbientOff				= "Sons ambiants désactivés."
L.EAC_EffectsOn					= "Effet sons activés."
L.EAC_EffectsOff				= "Effet sons handicapés."
L.EAC_FootstepsOn				= "Pieds activés."
L.EAC_FootstepsOff				= "Pieds handicapés."
L.EAC_DialogueOn				= "Le son de dialogue activé."
L.EAC_DialogueOff				= "Le son de dialogue désactivé."
L.EAC_InterfaceOn				= "Les sons d'interface activés."
L.EAC_InterfaceOff				= "Interface sons désactivés."
L.EAC_CinematicOn				= "Le son cinématographique activé."
L.EAC_CinematicOff				= "Le son cinématographique désactivé."
L.EAC_CombatAllOn				= "Toute la musique de combat activée."
L.EAC_CombatAllOff				= "Musique de combat handicapés."
L.EAC_CombatBossOn				= "Musique de combat Boss activée."

-- Settings menu strings
L.EAC_MenuTitle					= "Contrôle audio"
L.EAC_MenuGlobalOpts			= "Options audio globales"
L.EAC_MenuMaster				= "Bascule audio maître"
L.EAC_MenuMasterTip				= "Activer ou désactiver tous les jeux son et de la musique dans le monde entier."
L.EAC_MenuSounds				= "Tous les sons bascule"
L.EAC_MenuSoundsTip				= "Activer ou désactiver tous les types de son ci-dessous dans le monde."
L.EAC_MenuIndividual			= "Types sonores individuels"
L.EAC_MenuIndividualTip			= "Les paramètres sont maintenus via la connexion et la déconnexion et sur tous les caractères."
L.EAC_MenuAmbient				= "Son ambiant bascule"
L.EAC_MenuAmbientTip			= "Activer ou désactiver le jeu Sounds Ambient."
L.EAC_MenuEffects				= "Bascule au son d'effet"
L.EAC_MenuEffectsTip			= "Activer ou désactiver les sons d'effet de jeu."
L.EAC_MenuFootstep				= "Basculer le pas de pas."
L.EAC_MenuFootstepTip			= "Activer ou désactiver les sons de pas de jeu."
L.EAC_MenuDialogue				= "Bascule de dialogue"
L.EAC_MenuDialogueTip			= "Activer ou désactiver les sons de dialogue de jeu."
L.EAC_MenuInterface				= "Basculer audio d'interface"
L.EAC_MenuInterfaceTip			= "Activer ou désactiver les sons d'interface de jeu."
L.EAC_MenuCinematic				= "Bascule au son cinématique"
L.EAC_MenuCinematicTip			= "Activer ou désactiver les sons cinématiques du jeu."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
