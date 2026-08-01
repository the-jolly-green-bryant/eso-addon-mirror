local EZReport = _G['EZReport']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- (Non-indented and commented lines still require human translation and may not make sense!)
------------------------------------------------------------------------------------------------------------------

-- Addon Setting Labels
L.EZReport_GOpts				= "Options globales"
L.EZReport_TIcon				= "Afficher l'icône signalée par la cible"
L.EZReport_DTime				= "Afficher l'heure signalée par la cible"
L.EZReport_RCooldown			= "Rapport de récupération"
L.EZReport_RCooldownM			= "EZReport a déjà été signalé aujourd'hui: le délai de récupération des rapports est activé."
L.EZReport_OutputChat			= "Afficher les messages de chat"
L.EZReport_12HourFormat			= "Format horaire 12 heures"
L.EZReport_IncPrev				= "Inclure les données du rapport précédent"
L.EZReport_DCategory			= "Catégorie par défaut"
L.EZReport_DReason				= "Raison par défaut"
L.EZReport_Reset				= "Réinitialiser l'historique"
L.EZReport_Clear				= "CLAIR"

-- Target Reported Colors
L.EZReport_RColorS				= "Cibler les couleurs signalées"
L.EZReport_RColor1				= "Couleur générique"
L.EZReport_RColor2				= "Mauvaise couleur de nom"
L.EZReport_RColor3				= "Couleur toxique"
L.EZReport_RColor4				= "Tricher Couleur"
L.EZReport_RColor5				= "Alt signalé couleur"

-- Addon Setting Tooltips
L.EZReport_TIconT				= "Afficher une icône indiquant les cibles que vous avez précédemment signalées. Correspond aux icônes vues lors du choix d'une catégorie dans la fenêtre de rapport."
L.EZReport_DTimeT				= "Afficher l'heure à laquelle une cible a été rapportée pour la dernière fois à côté de l'icône de rapport cible. Si le personnage actuel n'a jamais été signalé, indique la date la plus récente à laquelle un personnage de son compte a été signalé."
L.EZReport_RCooldownT			= "Lorsque cette option est activée, empêche le signalement par raccourci si vous avez déjà signalé la cible aujourd'hui. Utile lorsque vous signalez des groupes importants de robots afin que vous puissiez spammer le raccourci clavier et que le système de rapport ne sera activé que si vous n'avez pas encore signalé de cible."
L.EZReport_OutputChatT			= "Affiche des messages informatifs liés aux diverses fonctions d'addon dans le chat."
L.EZReport_12HourFormatT		= "Lorsque cette option est activée, les horodatages générés utilisent le format d'heure 12 heures (heure plus AM ou PM). Si vous désactivez cette option, le format 'heure militaire' s'affiche 24 heures sur 24."
L.EZReport_IncPrevT				= "Inclut les données de date, d'heure et de nom concernant les rapports précédents de ce caractère ou les caractères connus lors de l'envoi d'un rapport."
L.EZReport_DCategoryT			= "Choisissez la sous-catégorie par défaut à sélectionner automatiquement lors de l'ouverture de la fenêtre de rapport."
L.EZReport_DReasonT				= "Incluez la raison sélectionnée dans la section des détails personnalisés de la fenêtre de rapport. L'option Manuel (par défaut) est de laisser ce champ vide pour que vous le tapiez manuellement."
L.EZReport_ResetT				= "Effacer la base de données entière des caractères et des comptes précédemment rapportés."
L.EZReport_ResetM				= "La base de données EZReport a été réinitialisée."

-- Category List
L.EZReport_CatList1				= "Mauvais nom"
L.EZReport_CatList2				= "Harcèlement"
L.EZReport_CatList3				= "La triche"
L.EZReport_CatList4				= "Autre"
L.EZReport_CatList5				= "Aucune (par défaut)"

-- Reason List
L.EZReport_ReasonList1			= "Botting"
L.EZReport_ReasonList2			= "Exploitant"
L.EZReport_ReasonList3			= "Harcèlement"
L.EZReport_ReasonList4			= "Manuel (par défaut)"

-- Chat List
L.EZReport_CReason1				= "Rapport générique"
L.EZReport_CReason2				= "Mauvais nom"
L.EZReport_CReason3				= "Comportement toxique"
L.EZReport_CReason4				= "La triche"

-- Chat Strings
L.EZReport_RepT					= "Signalé:"
L.EZReport_RepC					= "Caractère rapporté:"
L.EZReport_Unkn					= "compte inconnu"
L.EZReport_Now					= "à présent:"
L.EZReport_Char					= "personnage:"
L.EZReport_For					= "pour:"
L.EZReport_NoMatch				= "Aucun résultat."

-- Info Panel
L.EZReport_RAcct				= "Compte de rapport: "
L.EZReport_RAlts				= "Alts précédemment rapportés: "

-- General Strings
L.EZReport_RLast				= "Signaler le dernier joueur ciblé"
L.EZReport_RHistory				= "Historique du rapport cible"
L.EZReport_ROpen				= "Ouvrir la fenêtre principale"
L.EZReport_Reason				= "Raison (optionnel):"
L.EZReport_CName				= "Le nom du personnage:"
L.EZReport_AName				= "Nom du compte:"
L.EZReport_MLoc					= "Carte:"
L.EZReport_Coords				= "Coords:"
L.EZReport_Time					= "Date/heure:"
L.EZReport_CButton				= "Clair"
L.EZReport_Today				= "Aujourd'hui"
L.EZReport_Updated				= "La base de données EZReport a été mise à jour."
L.EZReport_AccUnavail			= "Compte non disponible"
L.EZReport_LocUnavail			= "Lieu non disponible"
L.EZReport_Wayshrine			= "L’Oratoire D"
L.EZReport_Accounts				= "Rapports par compte"
L.EZReport_Characters			= "Rapports par personnage"
L.EZReport_Locations			= "Rapports par lieu"
L.EZReport_Generated			= "Généré: EZReport par Phinix"
L.EZReport_Previous				= "Signalé précédemment:"
L.EZReport_Confirm				= "Confirmation de la suppression"
L.EZReport_Cancel				= "Annuler"
L.EZReport_Delete				= "Effacer"

-- Tooltip strings
L.EZReport_TTShow				= "Cliquez pour afficher le résumé du rapport."
L.EZReport_TTClick				= "Cliquez dans le champ de résultat et appuyez sur:"
L.EZReport_TTSelect1			= "Ctrl+A"
L.EZReport_TTSelect2			= " pour tout sélectionner."
L.EZReport_TTCopy1				= "Ctrl+C"
L.EZReport_TTCopy2				= " pour copier."
L.EZReport_TTPaste1				= "Ctrl+V"
L.EZReport_TTPaste2				= " pour coller ailleurs."
L.EZReport_TTAccounts			= "Passer à l'affichage des comptes."
L.EZReport_TTCharacters			= "Passez à l'affichage des caractères."
L.EZReport_TTEMode				= "Passez en mode d'édition de base de données."
L.EZReport_TTRMode				= "Passez en mode de rapport de texte."
L.EZReport_TTCEntry1			= "Clic-gauche"
L.EZReport_TTCEntry2			= " pour montrer les entrées de caractères."
L.EZReport_TTAEntry1			= "Maj+clic-gauche"
L.EZReport_TTAEntry2			= " pour afficher les entrées de compte."
L.EZReport_TTDEntry1			= "Clic-droit"
L.EZReport_TTDEntry2			= " pour supprimer l'entrée sélectionnée."


------------------------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k, v in pairs(EZReport:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function EZReport:GetLanguage() -- set new locale return
		return L
	end
end
