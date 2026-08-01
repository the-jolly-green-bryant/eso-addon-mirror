local strings = {
	SI_RANDOMOTE_LANG 					= "fr",
	SI_RANDOMOTE_ENABLE					= "Automatique",
	SI_RANDOMOTE_ENABLE_TT				= "Activer/désactiver l'utilisation d'emotes aléatoires en cas d'inactivité",
	SI_RANDOMOTE_STANDARD				= "Émotes standards",
	SI_RANDOMOTE_STANDARD_TT			= "Utiliser des émoticônes standards",
	SI_RANDOMOTE_COLLECTIBLE			= "Emotes à collectionner",
	SI_RANDOMOTE_COLLECTIBLE_TT			= "Utilisez des émoticônes à collectionner (à gagner, une boutique à couronnes, etc.)",
	SI_RANDOMOTE_CHAT_OUTPUT			= "Chat Output",
	SI_RANDOMOTE_CHAT_OUTPUT_TT			= "Afficher les informations via la fenêtre de discussion (utile pour voir la commande slash, la prochaine emote, etc.)",
	SI_RANDOMOTE_DELAY_IDLE				= "Délai d'inactivité",
	SI_RANDOMOTE_DELAY_IDLE_TT			= "Temps en secondes que le joueur est inactif pour commencer automatiquement à utiliser des emotes",
	SI_RANDOMOTE_DELAY_MIN				= "Délai d'emote (minimum)",
	SI_RANDOMOTE_DELAY_MIN_TT			= "Temps minimum en secondes entre les emotes",
	SI_RANDOMOTE_DELAY_MAX				= "Délai d'emote (maximum)",
	SI_RANDOMOTE_DELAY_MAX_TT			= "Temps maximum en secondes entre les emotes",
	SI_RANDOMOTE_FEEDBACK 				= "Envoyer des commentaires",
	SI_RANDOMOTE_FEEDBACK_TT 			= "Envoyez un message à l'auteur de l'addon avec des commentaires, des suggestions ou des rapports de bogue",
	SI_RANDOMOTE_DESCRIPTION_SLASH		= "Commandes de barre oblique",
	SI_RANDOMOTE_DESCRIPTION_EMOTE		= "Émote aléatoire",
	SI_RANDOMOTE_DESCRIPTION_SETTINGS 	= "Menu Paramètres",
	SI_RANDOMOTE_EMOTE_LIST				= "Liste des émoticônes",
	SI_BINDING_NAME_INVOKE_RANDOM		= "Émote aléatoire",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
