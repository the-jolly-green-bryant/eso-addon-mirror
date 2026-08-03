-- Локальная таблица строк — ТРЕБОВАНИЕ ESOUI!
local strings = {
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_AVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Abonnement disponible|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_UNAVAILABLE"] = "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Abonnement indisponible|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_NOTIFICATION_LIBADDOMENU"] = "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 introuvable. Vérifiez et installez-la.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_STRING_MENU"] = "|cCCECC0Date|r                |c98FB98Statut|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM"] = "|cEEEE00Demandons à @Eswagrom...|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_A"] = "|c2DF5F8[@Eswagrom] chuchote : Salut, l'abonnement est maintenant disponible UTILISEZ-LE|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_C"] = "|c5EB9D7[@Eswagrom] : Salut, que pensez-vous de l'essai gratuit ?|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ESWAGROM_B"] = "|c2DF5F8[@Eswagrom] chuchote : Salut, actuellement l'abonnement n'est pas disponible -_-|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION"] = "Envoyer les notifications dans le chat",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CHAT_NOTIFICATION_A"] = "|c00FF00Si DÉSACTIVÉ, le message automatique sur l'abonnement ne sera pas envoyé dans le chat, seul le contrôle manuel /esoplus restera.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT"] = "Taille de la police dans le tableau",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_FONT_A"] = "|c00FF00Modifie la taille de la police dans la fenêtre d'historique des statuts (de 8 à 24)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY"] = "Tableau d'enregistrement de l'abonnement",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_A"] = "|c00FF00Ouvre une fenêtre séparée avec des informations sur l'essai gratuit|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK"] = "Verrouiller la position de la fenêtre",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_LOCK_A"] = "|c00FF00Empêchera de déplacer la fenêtre sur l'écran|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AAA"] = "Transparence de l'arrière-plan",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_BBB"] = "Réinitialiser la position de la fenêtre",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_CCC"] = "Mettre à jour l'historique des statuts",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UPDATE_WINDOW_H"] = "|c00FF00Si quelque chose a planté dans la fenêtre du tableau d'historique — mettez-le à jour, cela pourrait vous aider.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_AVA"] = "disponible",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_UNAVA"] = "indisponible",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES"] = "Nombre de lignes pour l'enregistrement",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_HISTORY_LINES_A"] = "|c00FF00Combien de lignes seront enregistrées dans l'historique SavedVariables [affecte la taille du fichier et la durée de l'enregistrement, au-delà de la limite il y aura réécriture] (de 100 à 5000 nombre possible de lignes)|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_RESET_WINDOW"] = "|cEEEE00Position de la fenêtre réinitialisée.|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_ADDON_NAME"] = "|c00FF00Enregistrements EsoPlus|r",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS"] = "|cFF6347Réinitialiser les Paramètres!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_DEFAULTS_SETTINGS_A"] = "|cFF6347Ramène tous les paramètres de l'addon à l'état 'juste installé'. Réinitialise la position, la taille, la transparence, la police, la visibilité, le nombre de lignes (supprimera les lignes au-delà de la limite enregistrée !!! initialement 2000 lignes) et l'historique.|r",
    
    -- Информационное сабменю
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS"] = "|c00FF00Informations sur ESO Plus|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_A"] = "|c9999FF/esoplus|r |cFF6347écrivez dans le chat pour un contrôle manuel !|r Cet addon enregistre les reçus de l'essai gratuit, donc vous saurez toujours exactement quel jour il a été activé ou manquait. Par défaut, l'historique stocke jusqu'à 2000 entrées. Qu'est-ce que cela signifie en pratique ? Chaque entrée dans le tableau prend une ligne par jour. Ainsi, la limite de 2000 lignes couvre une période d'environ 2000/365≈5,48 ans. En d'autres termes, l'addon conservera l'historique de vos abonnements pendant presque cinq ans et demi.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AA"] = "|c00FF00api utilisées par cet addon|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAA"] = "API (Application Programming Interface) — est un ensemble de règles par lesquelles votre addon interagit avec le serveur de jeu. Pour faire simple, c'est une liste de commandes autorisées qui définissent les limites de ses possibilités. Les méthodes suivantes ont été utilisées pour la mise en œuvre :",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AB"] = "|c00FF00* HasEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAB"] = "** _Returns:_ *bool* _hasFreeTrialNotification_",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AC"] = "|c00FF00* ClearEsoPlusFreeTrialNotification()|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAC"] = "Cet addon n'a pas de fonction de liaison de touche pour appeler le tableau utilisateur avec l'historique des enregistrements, car l'addon est purement informatif. Vous n'aurez presque jamais besoin de ce tableau. L'auteur a délibérément omis d'ajouter un tel bouton en raison de la limitation du jeu : seulement 100 emplacements sont disponibles pour les touches personnalisées, il est donc inopportun de les occuper avec des éléments superflus.",
    
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AD"] = "|c00FF00Fonction de vérification automatique!!!|r",
    ["STRING_ESOPLUSFREETRIALNOTIFICATION_INFORMATION_ESO_PLUS_AAD"] = "|c9999FFLes vérifications automatiques du statut de l'abonnement ont lieu toutes les 15 minutes, indépendamment des paramètres de l'addon, cela est nécessaire pour que vous ne manquiez pas le statut si celui-ci est activé un peu plus tard le même jour, la fonction de vérification ne charge pas votre système. Un tel minuteur est complètement sûr pour les performances. Voici pourquoi :|r |cFFFFC5Fréquence d'exécution Toutes les 15 minutes — c'est extrêmement rare pour un moteur de jeu. À titre de comparaison : le client ESO lui-même traite des dizaines de milliers d'événements chaque seconde (animation, rendu, paquets réseau). Une fonction toutes les 15 minutes est une goutte d'eau dans l'océan. - Toutes les opérations ici sont purement logiques : lecture du statut du compte via l'API intégrée (HasEsoPlus...), travail avec la table locale (Lua table) et affichage d'un message dans le chat (d()). Il n'y a pas de calculs lourds, de boucles sur de grands tableaux, d'accès aux fichiers ou au réseau. Des appels comme ZO_SavedVars, d(), ClearEsoPlus... sont optimisés par les développeurs de ZOS et prennent des microsecondes.|r |cffd700Ping|r est déterminé par la qualité de la connexion Internet et la charge des serveurs ESO. Le minuteur Lua local du client n'envoie pas de données au serveur plus souvent que le jeu ne le fait déjà. La fonction HasEsoPlusFreeTrialNotification() utilise le statut mis en cache du compte — elle ne crée pas de trafic réseau supplémentaire. |c1E90FFComparaison avec d'autres addons.|r De nombreux addons populaires utilisent des minuteurs beaucoup plus fréquents : |cADD8E6- Inventory Insight|r — vérifie l'inventaire à chaque ouverture ; |cADD8E6- Combat Metrics|r — analyse chaque tick de combat (des dizaines de fois par seconde) ; - même les éléments UI standards se mettent à jour 60+ fois par seconde. Ce |cADD8E6minuteur|r de 900 secondes ressemble à « une fois par ère » à côté de cela."
}

-- Регистрация всех строк одним циклом — ТРЕБОВАНИЕ ESOUI!
for stringId, text in pairs(strings) do
    ZO_CreateStringId(stringId, text)
end