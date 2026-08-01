local EACAddon = _G['EACAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- German
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- Binding name strings
L.EAC_ToggleAll					= "Alles umschalten"
L.EAC_ToggleSounds				= "Um alle Töne umschalten"
L.EAC_ToggleMusic				= "Musik umschalten"
L.EAC_ToggleAmbient				= "Umgebungsgeräusche umschalten"
L.EAC_ToggleEffects				= "Toggle-Effekt klingt"
L.EAC_ToggleFootsteps			= "Schritte umschalten"
L.EAC_ToggleDialogue			= "Toggle-Dialogklang"
L.EAC_ToggleInterface			= "Toggle-Schnittstelle klingt"
L.EAC_ToggleCinematic			= "Kino-Sounds umschalten"
L.EAC_ToggleCombat				= "Toggle-Kampfmusik"

-- Binding output strings
L.EAC_AllOn						= "Klang global aktiviert."
L.EAC_AllOff					= "Klang global behindert."
L.EAC_SoundOn					= "Alle Sounds aktiviert."
L.EAC_SoundOff					= "Alle Sounds deaktiviert."
L.EAC_MusicOn					= "Musik aktiviert."
L.EAC_MusicOff					= "Musik deaktiviert."
L.EAC_AmbientOn					= "Umgebungsgeräusche aktiviert."
L.EAC_AmbientOff				= "Umgebungsgeräusche deaktiviert."
L.EAC_EffectsOn					= "Effektgeräusche aktiviert."
L.EAC_EffectsOff				= "Effektgeräusche deaktiviert."
L.EAC_FootstepsOn				= "Fußschritte aktiviert."
L.EAC_FootstepsOff				= "Fußschritte deaktiviert."
L.EAC_DialogueOn				= "Dialogklang aktiviert."
L.EAC_DialogueOff				= "Dialogklang ist deaktiviert."
L.EAC_InterfaceOn				= "Schnittstellengeräusche aktiviert."
L.EAC_InterfaceOff				= "Schnittstellengeräusche deaktiviert."
L.EAC_CinematicOn				= "Cinematic Sound aktiviert."
L.EAC_CinematicOff				= "Cinematic Sound deaktiviert."
L.EAC_CombatAllOn				= "Alle Combat-Musik aktiviert."
L.EAC_CombatAllOff				= "Kampfmusik deaktiviert."
L.EAC_CombatBossOn				= "Boss Combat Music aktiviert."

-- Settings menu strings
L.EAC_MenuTitle					= "Audiokontrolle"
L.EAC_MenuGlobalOpts			= "Globale Audiooptionen"
L.EAC_MenuMaster				= "Master-Audio-Toggle"
L.EAC_MenuMasterTip				= "Aktivieren oder deaktivieren Sie den gesamten Spiel Sound und Musik global."
L.EAC_MenuSounds				= "Alle Sounds wechseln"
L.EAC_MenuSoundsTip				= "Aktivieren oder deaktivieren Sie alle unten linkten Tontypen global."
L.EAC_MenuIndividual			= "Einzelne Soundarten"
L.EAC_MenuIndividualTip			= "Die Einstellungen werden über Login & Logout und über alle Zeichen aufrechterhalten."
L.EAC_MenuAmbient				= "Umgebungsgeräusch umgeschaltet."
L.EAC_MenuAmbientTip			= "Game-Umgebungsgeräusche aktivieren oder deaktivieren."
L.EAC_MenuEffects				= "Effekt Sound Toggle."
L.EAC_MenuEffectsTip			= "Aktivieren oder Deaktivieren von Game-Effekt-Geräuschen."
L.EAC_MenuFootstep				= "Fußstapfen Sound wechseln"
L.EAC_MenuFootstepTip			= "Aktivieren/Deaktivieren von Spiel-Fußstapfen."
L.EAC_MenuDialogue				= "Dialog-Sound-Toggle"
L.EAC_MenuDialogueTip			= "Aktivieren oder Deaktivieren von Spieldialog-Sounds."
L.EAC_MenuInterface				= "Schnittstellen-Sound-Toggle"
L.EAC_MenuInterfaceTip			= "Aktivieren oder deaktivieren Sie die Game-Interface-Sounds."
L.EAC_MenuCinematic				= "Cinematic Sound Toggle"
L.EAC_MenuCinematicTip			= "Spielen-Cinematic-Sounds aktivieren oder deaktivieren."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'de') then -- overwrite GetLanguage for new language
	for k,v in pairs(EACAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EACAddon:GetLanguage() -- set new language return
		return L
	end
end
