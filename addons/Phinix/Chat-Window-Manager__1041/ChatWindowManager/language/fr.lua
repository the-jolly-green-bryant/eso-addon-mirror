local CWMAddon = _G['CWMAddon']
local L = {}

------------------------------------------------------------------------------------------------------------------
-- French (Thanks to ESOUI.com user lexo1000 for the translations.)
-- Non-indented or commented lines still require human translation and may not make sense!
------------------------------------------------------------------------------------------------------------------

-- General strings
	L.CWMAddon_Reload           = "Recharger l'interface utilisateur"
	L.CWMAddon_Clear            = "Effacer la fenêtre de discussion"
	L.CWMAddon_ClearT           = "Efface le contenu de la fenêtre de discussion actuellement ouverte."
	L.CWMAddon_Toggle           = "Ouvrir/fermer la fenêtre de discussion"
L.CWMAddon_Online			= "Basculer l'état en ligne"
L.CWMAddon_RBox				= "Voulez-vous recharger l'interface utilisateur?"

-- Settings panel
L.CWMAddon_Title			= "Gestionnaire de fenêtre de discussion"
	L.CWMAddon_AutoHide         = "Masquer automatiquement la fenêtre de discussion"
	L.CWMAddon_AutoHideT        = "Minimise la fenêtre de discussion à la connexion, lors d'un changement de zone ou lors d'un rechargement de l'interface utilisateur."
L.CWMAddon_RemState         = "Souvenez-vous de l'état du chat"
L.CWMAddon_RemStateT        = "Remplace la prochaine option en maintenant l'état de chat précédent entre les écrans de chargement."
	L.CWMAddon_RButton          = "Afficher le bouton de rechargement/effacement"
L.CWMAddon_RButtonT         = "Ajoute un bouton à la fenêtre de discussion pour recharger l'interface utilisateur, ou Maj-clic pour effacer la discussion en cours."
L.CWMAddon_ROffset			= "Décalage de bouton de rechargement"
L.CWMAddon_ROffsetT			= "Modifiez la position horizontale du bouton RELOAD lorsque le chat est maximisé (pour la compatibilité avec d'autres addons)."
L.CWMAddon_RConfirm			= "Confirmer le rechargement UI"
L.CWMAddon_RConfirmT		= "Ajoute une boîte de confirmation lorsque vous cliquez sur le bouton Recharger l'interface utilisateur pour éviter les recharges accidentelles."
L.CWMAddon_SButton			= "Ajouter le menu d'état du joueur"
L.CWMAddon_SButtonT			= "Ajoute le menu de sélection du statut en ligne du joueur à la fenêtre de discussion."
L.CWMAddon_SChat			= "Bascule de statut dans le chat"
L.CWMAddon_SChatT			= "Afficher le statut en ligne du joueur dans le chat lorsqu'il est modifié par association de touches ou par une autre méthode."
L.CWMAddon_SOffset			= "Décalage de statut"
L.CWMAddon_SOffsetT			= "Changez la position horizontale de l'indicateur d'état en ligne lorsque le chat est maximisé (pour la compatibilité avec d'autres addons)."
L.CWMAddon_Extras			= "Options supplémentaires"
L.CWMAddon_DConfirm			= "Confirmer la suppression simple"
L.CWMAddon_DConfirmT		= "Élimine le besoin de taper «DELETE» lors de la suppression de certaines choses. Vous obtiendrez à la place une boîte pour cliquer sur Oui ou Non."
L.CWMAddon_HideFriend		= "Cacher ami Connexion & Déconnexion"
L.CWMAddon_HideFriendT		= "Prévenir ami Connexion/Déconnexion des messages d'état d'apparaître dans le discuter."
L.CWMAddon_TutorialOff		= "Désactiver les tutoriels."
L.CWMAddon_TutorialOffT		= "Désactiver automatiquement les didacticiels contextuels lors de la connexion (et lors de l'activation de cette option). Peut être réactivé à partir des paramètres de jeu."


------------------------------------------------------------------------------------------------------------------

if (GetCVar('language.2') == 'fr') then -- overwrite GetLanguage for new language
	for k,v in pairs(CWMAddon:GetLanguage()) do
		if (not L[k]) then -- no translation for this string, use default
			L[k] = v
		end
	end

	function CWMAddon:GetLanguage() -- set new language return
		return L
	end
end
