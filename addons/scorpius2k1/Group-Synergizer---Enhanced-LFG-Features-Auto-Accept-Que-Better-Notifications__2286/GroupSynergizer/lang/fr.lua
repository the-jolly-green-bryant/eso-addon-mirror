local strings = {
	SI_GROUP_SYNERGIZER_LANG 		= "fr",

	SI_GROUP_SYNERGIZER_ENABLE 		= "Activé",
	SI_GROUP_SYNERGIZER_SOUND 		= "Son amélioré",
	SI_GROUP_SYNERGIZER_SCREEN 		= "Visuel amélioré",
	SI_GROUP_SYNERGIZER_ENHANCE 	= "LFG amélioré",
	SI_GROUP_SYNERGIZER_ACCEPT 		= "Chèques prêts à accepter automatiquement",
	SI_GROUP_SYNERGIZER_RELEASE 	= "Libération automatique dans les champs de bataille",
	SI_GROUP_SYNERGIZER_SLASH 		= "Commandes Pledge/Group Slash",
	SI_GROUP_SYNERGIZER_DELAY 		= "Délai de notification sonore",

	SI_GROUP_SYNERGIZER_LFG_CHAT 	= "Prêt à vérifier!",
	SI_GROUP_SYNERGIZER_LFG_CHAT_A 	= "Vérification prêt acceptée automatiquement!",
	SI_GROUP_SYNERGIZER_LFG_SCREEN 	= "Vérification du groupe prêt!",

	SI_GROUP_SYNERGIZER_ENABLE_TT 	= "Activer/Désactiver LFG Enhancer",
	SI_GROUP_SYNERGIZER_SOUND_TT 	= "Plus de son audible lors de la vérification prête",
	SI_GROUP_SYNERGIZER_SCREEN_TT 	= "Meilleure notification d'écran lors du contrôle prêt",
	SI_GROUP_SYNERGIZER_ENHANCE_TT 	= "Afficher les engagements/quêtes quotidiens, accepter automatiquement et vérifier les quêtes actives dans l'outil de recherche de groupes et d'activités",
	SI_GROUP_SYNERGIZER_ACCEPT_TT 	= "Accepter automatiquement le contrôle prêt à la recherche d'un groupe",
	SI_GROUP_SYNERGIZER_RELEASE_TT 	= "Libération automatique à la mort sur les champs de bataille",
	SI_GROUP_SYNERGIZER_SLASH_TT 	= "Commandes de barre oblique \nEngagements quotidiens /pl /pledge \nQuitter le groupe /lv /leave",
	SI_GROUP_SYNERGIZER_DELAY_TT 	= "Délai (en secondes) entre les nofications sonores lors de la vérification LFG Ready",

	SI_GROUP_SYNERGIZER_SLASH_WARN	= "Recharge de l'interface utilisateur requise"
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
