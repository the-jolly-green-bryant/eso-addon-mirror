local RPOTracker = _G['RPOTracker']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Panel Strings
--L.RPOTRACK_Title		= "|cFF9900Pale Order|r |cFEE854Tracker|r"
L.RPOTRACK_SOpts		= "Options d'auto-tracker"
L.RPOTRACK_GOpts		= "Options de tracker de groupe"

-- Self Tracker Options
L.RPOTRACK_Show			= "Spectacle de tracker"
L.RPOTRACK_ShowD		= "Afficher le suivi de statut équipé RotPO pour le joueur."
L.RPOTRACK_Lock			= "Tracker de serrure"
L.RPOTRACK_LockD		= "Une fois déverrouillé, vous pouvez déplacer le tracker pour sauver une nouvelle position."
L.RPOTRACK_ShowG		= "Spectacle groupé"
L.RPOTRACK_ShowGD		= "Affichez le suivi de statut équipé RotPO pour le joueur lorsqu'il est groupé."
L.RPOTRACK_ShowBG		= "Montre-arrière"
L.RPOTRACK_ShowBGD		= "Montrez un fond noir derrière l'icône RotPO Tracker."
L.RPOTRACK_Label		= "Étiquette de spectacle"
L.RPOTRACK_LabelD		= "Afficher une étiquette de texte indiquant le pourcentage de la force RotPO en fonction du nombre de membres du groupe présents."
L.RPOTRACK_TScale		= "Échelle du tracker"
L.RPOTRACK_TScaleD		= "Échellez les dimensions de l'icône du tracker."
L.RPOTRACK_LScale		= "Échelle d'étiquette"
L.RPOTRACK_LScaleD		= "Échellez les dimensions de l'étiquette de texte."
L.RPOTRACK_LabelX		= "Étiqueter le décalage horizontal"
L.RPOTRACK_LabelXD		= "Ajustez la position de l'étiquette de texte RotPO de gauche à droite."
L.RPOTRACK_LabelY		= "Étiqueter le décalage vertical"
L.RPOTRACK_LabelYD		= "Ajustez la position de l'étiquette de texte RotPO de haut en bas."

-- Group Tracker Options
L.RPOTRACK_SGF			= "Surveiller les cadres de groupe"
L.RPOTRACK_SGFD			= "Afficher l'icône RotPO pour les cadres d'unité de groupe."
L.RPOTRACK_SRF			= "Surveiller les cadres de raid"
L.RPOTRACK_SRFD			= "Afficher l'icône RotPO sur les cadres de l'unité raid."
L.RPOTRACK_GIS			= "Taille de l'icône de groupe"
L.RPOTRACK_GISD			= "Taille de l'icône RotPO lorsqu'elle est affichée sur les trames de groupe standard."
L.RPOTRACK_RIS			= "Taille de l'icône raid"
L.RPOTRACK_RISD			= "Taille de l'icône RotPO lorsqu'elle est affichée sur des cadres de raid standard."
L.RPOTRACK_GXIO			= "Décalage d'icône horizontale de groupe"
L.RPOTRACK_GXIOD		= "Ajustez la position de l'icône de la trame de groupe RotPO gauche à droite."
L.RPOTRACK_GYIO			= "Décalage d'icône verticale de groupe"
L.RPOTRACK_GYIOD		= "Ajustez la position de l'icône de la trame de groupe RotPO de haut en bas."
L.RPOTRACK_RXIO			= "Offset d'icône horizontale raid"
L.RPOTRACK_RXIOD		= "Ajustez la position de l'icône du cadre raid RotPO gauche à droite."
L.RPOTRACK_RYIO			= "Offset d'icône verticale raid"
L.RPOTRACK_RYIOD		= "Ajustez la position de l'icône du cadre raid RotPO de haut en bas."

-- 3rd Party Frame Options
L.RPOTRACK_Mode1		= "Défaut"
--L.RPOTRACK_Mode2		= "Foundry Tactical Combat"
--L.RPOTRACK_Mode3		= "Lui Extended"
--L.RPOTRACK_Mode4		= "Bandits User Interface"
--L.RPOTRACK_Mode5		= "AUI"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k, v in pairs(RPOTracker:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function RPOTracker:GetLanguage() -- set new language return
		return L
	end
end
