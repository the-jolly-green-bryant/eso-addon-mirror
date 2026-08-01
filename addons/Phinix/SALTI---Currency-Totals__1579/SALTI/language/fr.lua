local SALTI = _G['SALTI']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French (Thanks to ESOUI.com user lexo1000 for the translations.)
-- (Non-indented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Strings
	L.SALTI_Title					= "SALTI"
	L.SALTI_PTitle					= "SALTI - Récapitulatif des devises"
	L.SALTI_GOpts					= "Options générales"
L.SALTI_COpts					= "Statut du personnage"
	L.SALTI_CCTrack					= "Suivre les devises du personnage"
	L.SALTI_CCTrackD				= "Enregistre les montants en or, en Points d\'Alliance et en Pierres de Tel Var en possession du personnage actuel. Désactiver cette option supprimera les données sauvegardées pour ce personnage."
L.SALTI_TRACKWARN				= "AVERTISSEMENT: rechargera automatiquement l\'interface utilisateur!"
	L.SALTI_IWPos					= "Déverouiller la position de l\'info-bulle"
	L.SALTI_IWPosD					= "Permet de positionner manuellement l\'emplacement de l\'info-bulle de devise."
	L.SALTI_SACIcon					= "Afficher l\'icône de classe"
	L.SALTI_SACIconD				= "Affiche une icône colorée indiquant la classe et l\'alliance de chaque personnage suivi."
L.SALTI_SGC						= "Afficher la devise globale"
L.SALTI_SGCD					= "Afficher le récapitulatif des devises à l\'échelle du compte sous les totaux standard."
L.SALTI_GCS						= "Global Currency Espacement"
L.SALTI_GCSD					= "Élargir ou raccourcir l'espace entre les devises globales."
L.SALTI_ALPHAN					= "Liste alphabétique des noms"
L.SALTI_ALPHAND					= "Lorsque cette option est activée, la liste des devises de caractères suivis sera classée par ordre alphabétique. Sinon, la liste des caractères correspond à l\'ordre de vos personnages sur l\'écran de connexion."
	L.SALTI_SGBGold					= "Afficher l\'or dans la banque de guilde"
	L.SALTI_SGBGoldD				= "Affiche également la quantité d\'or entreposée dans la banque de guilde actuelle. Il est nécessaire de visiter chaque banque de guilde pour mettre à jour le montant en or."
L.SALTI_DCChar					= "Supprimer les données du personnage:"
L.SALTI_DELETE					= "EFFACER"
L.SALTI_CDELD					= "Supprimer le caractère sélectionné de la base de suivi. Si vous supprimez un caractère encore existant ici, ils seront automatiquement configurés pour ne pas suivre. Connectez-vous en tant que personnage et réactivez le suivi sous Options de personnage pour les rajouter à la base de données."

-- General Strings
	L.SALTI_BTotal					= "En banque:"
L.SALTI_ATotal					= "Totaux du compte:"
	L.SALTI_SOURCE					= "PERSONNAGES"
L.SALTI_CGlobal					= "Globale:"
L.SALTI_DBUpdate				= "La base de données SALTI a été réinitialisée avec cette version.\nConnectez-vous à chaque caractère à reconstruire."
L.SALTI_ETICKETS				= "tickets d'événement"

------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k, v in pairs(SALTI:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end
	function SALTI:GetLanguage() -- set new language return
		return L
	end
end
