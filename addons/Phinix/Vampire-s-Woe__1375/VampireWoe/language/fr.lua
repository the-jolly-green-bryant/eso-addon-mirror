local VWoe = _G['VWoeAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French (Thanks to ESOUI.com user Ardevlirn for the translations.)
-- (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

--General strings
	L.AddonTitle				= "Le Malheur du Vampire"
	L.KeybindToggle				= "Basculer la répression"
	L.KeybindInnocent			= "«Empêcher d'attaquer les innocents»"
	L.KeybindCriminal			= "Bloquer les compétences criminelles"
	L.FeedToggleOn				= "La synergie vampirique «Se nourrir» n'est plus réprimé."
	L.FeedToggleOff				= "La synergie vampirique «Se nourrir» est réprimé."
	L.BladeToggleOn				= "La synergie «Lame de Malheur» n’est plus réprimé."
	L.BladeToggleOff			= "La synergie «Lame de Malheur» est réprimé."
	L.SwapToggleV				= "«Se nourrir» réprimé, «Lame de Malheur» activée."
	L.SwapToggleB				= "«Lame de Malheur» réprimé, «Se nourrir» activée."
	L.AddonToggleOn				= "Le Malheur du Vampire: activé."
	L.AddonToggleOff			= "Le Malheur du Vampire: désactivé."
	L.KeybindInnoOn				= "«Empêcher d'attaquer les innocents» est activé."
	L.KeybindInnoOff			= "«Empêcher d'attaquer les innocents» est désactivé."
	L.BlockCrimeOn				= "Bloquer l'utilisation des compétences 'Action criminelle': ON."
	L.BlockCrimeOff				= "Bloquer l'utilisation des compétences 'Action criminelle': OFF."
	L.AbilityBlocked			= "Le Malheur du Vampire: Action bloquée par la configuration des actions criminelles."

--Settings strings
	L.EnableAddon				= "Activer l'extension"
	L.EnableAddonTip			= "Activer/désactiver les fonctionnalités de l'extension."
	L.KeybindOption				= "Fonction des raccourcis clavier"
	L.KeybindOptionTip			= "Définissez le comportement lorsque vous appuyez sur le raccourci clavier 'basculer la suppression.'"
	L.KeyOption1				= "Activer/Desactiver le nourrissement"
	L.KeyOption2				= "Activer/Desactiver la lame"
	L.KeyOption3				= "Basculer entre les deux"
	L.KeyOption4				= "Activer/désactiver"
	L.AllowAlly					= "Autorisé de mordre les alliés quand réprimer"
	L.AllowAllyTip				= "Vous permet de mordre et de transmettre le vampirisme à un allié même lorsque la synergie de nourrissement est réprimé."
	L.AutoInnocent				= "Basculer automatiquement l'attaque d'innocent"
	L.AutoInnocentTip			= "Désactive automatiquement 'Empêcher d'attaquer les innocents' lorsque la synergie «Se nourrir» ou «Lame de Malheur» est affichée."
	L.ShowDebug					= "Afficher les messages de débogage"
	L.ShowDebugTip				= "Afficher un message dans la fenêtre de discussion lorsque «Se nourrir» ou «Lame de Malheur» est activée/désactivée à l'aide d'un raccourci clavier."
	L.Status					= "Statut de la répression"
	L.FeedSetting				= "Réprimer la synergie vampirique «Se nourrir»"
	L.FeedSettingTip			= "Empêche la synergie «Se nourrir» des vampires de se déclencher."
L.AutoStage					= "Activer niveau maximum"
L.AutoStageTip				= "Lorsque cette option est cochée, l'alimentation des vampires sera activée même si le paramètre ci-dessus est coché si votre stade actuel est inférieur au stade maximal défini ci-dessous."
L.MaxStage					= "Définir niveau maximum"
L.MaxStageTip				= "La synergie d'alimentation des vampires sera supprimée lorsque votre niveau actuel sera supérieur ou égal à cette limite."
	L.BladeSetting				= "Réprimer la synergie «Lame de Malheur»"
	L.BladeSettingTip			= "Bloque la synergie «Lame de Malheur» de déclencher."
	L.CriminalSetting			= "Bloquer les compétences 'Action Criminelle'."
	L.CriminalSettingTip		= "Empêche les compétences marquées comme 'Action Criminelle' d'être utilisée."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(VWoe:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function VWoe:GetLanguage() -- set new language return
		return L
	end
end
