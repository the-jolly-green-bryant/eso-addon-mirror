local DLAddon = _G['DLAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French
-- Non-indented lines still need human translation and may not make sense.
------------------------------------------------------------------------------------------------------------------

-- General strings
L.DLAddon_UnitAdded			= "ajouté à la liste de mort."
L.DLAddon_ToAddPlayers		= "Doit activer l'option d'ajouter des joueurs à la liste de mort."
L.DLAddon_NotAttackable		= "Objectif non attaquable."
L.DLAddon_NoGuards			= "Vous ne pouvez pas ajouter des gardes invulnérables à la liste de mort."
L.DLAddon_ListCleared		= "Toutes les cibles de la liste de mort effacés."
L.DLAddon_ListEmpty			= "Il n'y a pas de noms sur votre liste de décès."
L.DLAddon_Removed			= "a été retiré de votre liste de décès."
L.DLAddon_NoExist			= "La cible n'existe pas dans votre liste de décès."

-- Settings panel
L.DLAddon_ShowMarker		= "Afficher Marquage Caractère"
L.DLAddon_ShowMarkerTip		= "Afficher le nom du personnage qui a ajouté la cible à la liste de mort."
L.DLAddon_MarkPlayers		= "Autoriser marquage Joueurs"
L.DLAddon_MarkPlayersTip	= "Vous permet d'ajouter d'autres joueurs à la liste de mort."
L.DLAddon_ShowDebug			= "Afficher Debug"
L.DLAddon_ShowDebugTip		= "Affiche les notifications de conversation lors de l'exécution des fonctions de la liste de mort."
L.DLAddon_MarkColor			= "Choisir l'icône de couleur"
L.DLAddon_MarkColorTip		= "Définir la couleur pour la Liste de mort marqué icône cible."
L.DLAddon_TextColor			= "Choisissez la couleur du texte"
L.DLAddon_TextColorTip		= "Définissez la couleur pour le nom du personnage qui a ajouté à la liste des cibles de la mort."
L.DLAddon_MarkSize			= "Choisissez Icon Taille"
L.DLAddon_MarkSizeTip		= "Définissez la taille de la liste de mort marqué icône cible."
L.DLAddon_ChatCommants		= "Commandes de chat"
L.DLAddon_PrintList			= "Imprime le contenu de votre liste de décès."
L.DLAddon_RemoveName		= "Supprimer le nom spécifié de la liste des décès (sans guillemets)."
L.DLAddon_ClearList			= "Effacer toutes les cibles de votre liste de mort."
L.DLAddon_Name				= "prénom"


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(DLAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function DLAddon:GetLanguage() -- set new language return
		return L
	end
end
