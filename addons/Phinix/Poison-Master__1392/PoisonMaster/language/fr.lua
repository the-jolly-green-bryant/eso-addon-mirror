local PMAddon = _G['PMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.PMAddon_GLOBAL			= "OPTIONS GLOBALES"
L.PMAddon_LOCK				= "Position de verrouillage"
L.PMAddon_LOCKTIP			= "Empêche de déplacer la fenêtre de configuration poison."
L.PMAddon_BACK				= "Masquer le fond"
L.PMAddon_BACKTIP			= "Cache l’arrière-plan de la fenêtre de configuration poison."
L.PMAddon_ICONS				= "Afficher les icônes d'équipement"
L.PMAddon_ICONSTIP			= "Affiche les indicateurs d'icône pour les poisons de votre arme active et inactive lorsque vous les attribuez à un emplacement favori"
L.PMAddon_THEME				= "Équiper le thème d'icônes"
L.PMAddon_THEMETIP			= "Choisissez le style des indicateurs de poison équipés."
L.PMAddon_STYLE1			= "Frontières"
L.PMAddon_STYLE2			= "Chèques"
L.PMAddon_DEBUG				= "Afficher le texte de débogage"
L.PMAddon_DEBUGTIP			= "Affiche un texte descriptif dans le chat lorsque certaines choses se produisent."
L.PMAddon_Tooltip			= "Cliquez en maintenant la touche Maj enfoncée pour affecter le poison équipé à l'emplacement. Faites un clic droit pour effacer."

-- Keybind strings
L.PMAddon_KBT				= "Basculer fenêtre de configuration Poison"
L.PMAddon_KB1				= "Equiper/déséquipez emplacement 1 poison:"
L.PMAddon_KB2				= "Equiper/déséquipez emplacement 2 poison:"
L.PMAddon_KB3				= "Equiper/déséquipez emplacement 3 poison:"
L.PMAddon_KB4				= "Equiper/déséquipez emplacement 4 poison:"

-- Debug strings
L.PMAddon_PNE				= "Le poison désiré n’est plus dans vos sacs."
L.PMAddon_NPE				= "L'arme active n'a pas de poison équipé à attribuer."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(PMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function PMAddon:GetLanguage() -- set new language return
		return L
	end
end
