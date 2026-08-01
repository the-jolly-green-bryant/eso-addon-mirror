local TBoxAddon = _G['TBoxAddon']
local pTC = TBoxAddon.TColor
TBoxAddon.DB = {}
TBoxAddon.AT = {}
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- (Requires human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- General
	L.TBoxAddon_SEARCHBOX				= "Recherche de trésor par nom."
	L.TBoxAddon_CLOSE					= "Fermer Treasure Box"
	L.TBoxAddon_TITLE					= "Treasure Box"
	L.TBoxAddon_RECENT					= "Trouvé récemment:"
	L.TBoxAddon_FAVZONE					= "Top Zone:"
	L.TBoxAddon_UPDATE1					= "[TBox]: Base de données mise à jour Treasure Box."
	L.TBoxAddon_UPDATE2					= "[TBox]: Veuillez /reloadui pour terminer."
	L.TBoxAddon_UPDATE3					= "[TBox]: Veuillez patienter..."
	L.TBoxAddon_NOCATEGORY				= "Non classé"
	L.TBoxAddon_RESETSEARCH				= "Cliquez sur le bouton pour réinitialiser la recherche de texte.\n\n"..pTC("FFFFFF", "NOTE: ").."D'autres filtres sont maintenus."
	L.TBoxAddon_TFOUNDOFF				= pTC("00FF00", "Afficher seulement trouvé").." est"..pTC("FFFFFF", " SUR").."\n\nCliquez pour afficher TOUS les trésors, que vous les ayez trouvés ou non."
	L.TBoxAddon_TFOUNDON				= pTC("00FF00", "Afficher seulement trouvé").." est"..pTC("FFFFFF", " OFF").."\n\nCliquez pour afficher uniquement les trésors que vous avez trouvés sur l'un de vos personnages."
	L.TBoxAddon_RESETFILTER				= "Réinitialiser les filtres"
	L.TBoxAddon_RQUALITYS1				= "Afficher seulement "
	L.TBoxAddon_RQUALITYS2				= " et des articles de meilleure qualité dans la liste Récemment trouvé."
	L.TBoxAddon_UPDATING				= "[TBox]: Treasure Box mise à jour de la base de données, veuillez ne pas redémarrer..."

-- Navigation
	L.TBoxAddon_TFOUND					= "Trésor Trouvé:"
	L.TBoxAddon_QUALITYHEAD				= "Qualité Trésor:"
	L.TBoxAddon_TIMEHEAD				= "Temps Trouvé:"
	L.TBoxAddon_TIMEDAYS1				= "Derniers"
	L.TBoxAddon_TIMEDAYS2				= "jours"
	L.TBoxAddon_ANY						= "Toute"
	L.TBoxAddon_ALLTYPES				= "Catégorie: Toute"
	L.TBoxAddon_ALLZONES				= "Trouvé dans: Toute"
	L.TBoxAddon_ANYFOUND				= "Trouvé par: Toute"
	L.TBoxAddon_QUALITYS				= "Afficher la qualité: "
	L.TBoxAddon_QUALITY1				= "Normal"
	L.TBoxAddon_QUALITY2				= "Fine"
	L.TBoxAddon_QUALITY3				= "Superior"
	L.TBoxAddon_QUALITY4				= "Epic"
	L.TBoxAddon_QUALITY5				= "Legendary"
	L.TBoxAddon_FINZONES				= "Trouvé dans les zones:"
	L.TBoxAddon_LFOUNDIN				= "Dernière découverte dans: "
	L.TBoxAddon_LFOUNDBY				= "Dernière découverte par: "
	L.TBoxAddon_FOUNDON					= "Dernière découverte le: "
	L.TBoxAddon_TOTALF					= "Total trouvé: "
	L.TBoxAddon_NEVER					= "Jamais"
	L.TBoxAddon_NONE					= "Rien"
	L.TBoxAddon_UNKNOWN					= "Inconnue"
	L.TBoxAddon_SALPHA					= "Trier alphabétiquement"
	L.TBoxAddon_SFOUND					= "Trier par numéro trouvé"

-- Settings
	L.TBoxAddon_GOPTS					= "Options générales"
	L.TBoxAddon_CHARALPHA				= "Trier la liste des caractères"
	L.TBoxAddon_CHARALPHAT				= "Activé affiche la liste des caractères par ordre alphabétique. Sinon, il utilise l'ordre de sélection des personnages du jeu.\n\n"..pTC("FFFFFF", "NOTE: ").."Le jeu renvoie uniquement l'ordre de CRÉATION des personnages. Il ne suit pas les caractères réorganisés manuellement."
	L.TBoxAddon_USTIME					= "12 heures Temps"
	L.TBoxAddon_USTIMET					= "Lorsqu'il est activé, les horodatages des trésors précédemment trouvés seront affichés en 12 heures avec am/pm après l'heure. Désactivez pour afficher au format 24 heures (militaire)."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k, v in pairs(TBoxAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function TBoxAddon:GetLanguage() -- set new language return
		return L
	end
end
