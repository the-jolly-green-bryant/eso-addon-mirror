local DTAddon = _G['DTAddon']
local L = {}
 
--------------------------------------------------------------------------------------------------------------------
-- French translation by ESOUI.com user lexo1000. (Non-indented lines still need human translation!)
--------------------------------------------------------------------------------------------------------------------

-- General Strings
--L.DTAddon_Title			= "Suivi de Donjon"
	L.DTAddon_CNorm			= "Accompli en Normal: "
	L.DTAddon_CVet			= "Accompli en Vétéran: "
	L.DTAddon_CNormI		= "Accompli en Normal I: "
	L.DTAddon_CNormII		= "Accompli en Normal II: "
	L.DTAddon_CVetI			= "Accompli en Vétéran I: "
	L.DTAddon_CVetII		= "Accompli en Vétéran II: "
L.DTAddon_CGChal		= "Skillpoint de défi du groupe"
	L.DTAddon_CDBoss		= "Tous les Boss vaincus: "
	L.DTAddon_Unlock		= "Débloqué au niveau: "
L.DTAddon_True			= "Vrai"
L.DTAddon_False			= "Faux"
L.DTAddon_None			= "Aucun"
L.DTAddon_MQOPT1		= "Tous les caractères"
L.DTAddon_MQOPT2		= "Caractère actuel"
L.DTAddon_MQOPT3		= "Ne pas afficher"
L.DTAddon_CTOPT1		= "Montrer les deux"
L.DTAddon_CTOPT2		= "Seulement complété"
L.DTAddon_CTOPT3		= "Seulement incomplet"
L.DTAddon_QComp			= "Quête terminée: "
L.DTAddon_QCompI		= "Quête I terminée: "
L.DTAddon_QCompII		= "Quête II terminée: "
L.DTAddon_AWide			= " (À l'échelle du compte)"
L.DTAddon_QMQ			= "Sélectionnez des quêtes incomplètes"
L.DTAddon_QMQTip		= "Sélectionnez des donjons pour lesquels le personnage actuel n'a pas encore terminé la quête de points de compétence."
L.DTAddon_QMQVTip		= "S'il est vérifié, la version vétéran des donjons est sélectionnée pour compléter les quêtes de point de compétence (non recommandées).\n\n|cffffffREMARQUE|r: La quête de point de compétence est la même en mode normal et vétéran et ne peut être terminée qu'une seule fois."

-- Account Options
	L.DTAddon_SHMComp		= "Afficher l'accomplissement en Mode Difficile"
L.DTAddon_SHMCompD		= "Affiche une icône si vous avez terminé le donjon vétéran sélectionné ou l'exploit du mode Difficile d'essai."
	L.DTAddon_STTComp		= "Afficher l'accomplissement en Contre la Montre"
L.DTAddon_STTCompD		= "Montrez une icône si vous avez terminé le donjon vétéran sélectionné ou la réalisation chronométrée d'essai."
	L.DTAddon_SNDComp		= "Afficher l'accomplissement Sans Mort"
L.DTAddon_SNDCompD		= "Montrez une icône si vous avez terminé le donjon vétéran sélectionné ou l'essai de décès."
L.DTAddon_SGFComp		= "Achèvement des factions de donjon de groupe"
L.DTAddon_SGFCompD		= "Montrez les progrès actuels en vue de compléter tous les cachots de groupe dans la faction du cachot en surbrillance."
L.DTAddon_SLFGt			= "LFG: Afficher l'achèvement du donjon"
L.DTAddon_SLFGtD		= "Afficher les informations sur les réussites dans l'info-bulle de l'outil de recherche de groupe."
L.DTAddon_SLFGd			= "LFG: Montre la description du donjon"
L.DTAddon_SLFGdD		= "Affichez la description du donjon dans les info-bulles de LFG. Ceci est normalement caché."
L.DTAddon_SNComp		= "CARTE: Achèvement du donjon de groupe normaux"
L.DTAddon_SNCompD		= "Indiquez si vous avez terminé le donjon ou l'épreuve en mode normal dans l'info-bulle."
L.DTAddon_SVComp		= "CARTE: Achèvement du donjon de groupe vétéran"
L.DTAddon_SVCompD		= "Indiquez si vous avez terminé le donjon ou l'épreuve en mode Vétéran dans l'info-bulle."
L.DTAddon_SGCCompM		= "CARTE: "
L.DTAddon_SGCComp		= "Point de compétence du donjon public"
L.DTAddon_SGCCompD		= "Afficher si votre personnage actuel a terminé le défi du groupe Dungeon Skinpoint dans l'info-bulle."
L.DTAddon_SDBComp		= "CARTE: Achèvement du patron du donjon public"
L.DTAddon_SDBCompD		= "Montrer si vous avez vaincu tous les patrons d'un donjon public dans l'info-bulle."
L.DTAddon_SDFComp		= "CARTE: Achèvement de la faction de donjon public"
L.DTAddon_SDFCompD		= "Montrer les progrès actuels en vue de compléter tous les cachots publics dans la réalisation des factions."
L.DTAddon_CNColor		= "Couleur terminée:"
L.DTAddon_CNColorD		= "Sélectionnez la couleur pour le statut d'achèvement ou les noms des personnages qui ont terminé la quête de points de compétence du donjon."
L.DTAddon_NNColor		= "Couleur incomplète:"
L.DTAddon_NNColorD		= "Sélectionnez la couleur pour le statut d'achèvement ou les noms des personnages qui n'ont PAS terminé la quête de points de compétence du donjon."
L.DTAddon_QCompHead		= "Achèvement de la quête du donjon"
L.DTAddon_QCompS		= "Afficher les quêtes de donjon"
L.DTAddon_QCompSD		= "Choisissez d'afficher ou non l'état d'achèvement des quêtes de donjon. Sélectionnez s'il faut afficher l'état de tous les personnages ou uniquement l'état actuel.\n\nREMARQUE : Vous devrez vous connecter à chaque personnage au moins une fois pour qu'il s'affiche dans la liste de tous les personnages."
L.DTAddon_CTDROPDOWN	= "Format du texte de complétion"
L.DTAddon_CTDROPDOWND	= "Si vous affichez tous les personnages, choisissez d'afficher uniquement ceux qui ont terminé la quête de points de compétence du donjon, uniquement ceux qui ne l'ont pas fait, ou les deux (par défaut)."
L.DTAddon_ALPHAN		= "Classer la liste des noms alphabétique"
L.DTAddon_ALPHAND		= "Lorsque cette option est activée, les listes d'achèvement des info-bulles seront classées par ordre alphabétique. Sinon, l'ordre de la liste correspond à l'ordre de création de vos personnages."
L.DTAddon_CHighlight	= "Surligner le caractère actuel "
L.DTAddon_CHighlightD	= "Montrez un astérisque (*) et utilisez la couleur de la réalisation de caractères actuelle pour mettre en évidence le donjon Quest Achion pour votre caractère connecté actuel lorsque vous affichez la liste."
L.DTAddon_HColor		= "Couleur du personnage actuel"
L.DTAddon_HColorD		= "Changez la couleur pour mettre en surbrillance votre caractère actuel dans la liste des noms de l'achèvement de la quête Dungeon."

-- Character Tracking
L.DTAddon_CharTracking	= "Suivi des caractères"
L.DTAddon_TrackChar		= "Suivre le personnage actuel"
L.DTAddon_TrackCharD	= "Inclure le personnage actuellement connecté dans le résumé d'achèvement de la quête lorsque "..L.DTAddon_QCompS.." est défini sur "..L.DTAddon_MQOPT1..". Réactivez-le lorsque vous êtes connecté pour le rajouter."
L.DTAddon_TrackWarn		= "AVERTISSEMENT : rechargera automatiquement l’interface utilisateur !"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(DTAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function DTAddon:GetLanguage() -- set new language return
		return L
	end
end
