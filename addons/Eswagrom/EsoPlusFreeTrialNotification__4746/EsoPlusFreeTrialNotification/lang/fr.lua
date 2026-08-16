
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_AVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|c00FF00Abonnement disponible|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_UNAVAILABLE, "|t34:34:/esoui/art/characterselect/keyboard/characterselect_esoplus_chalice.dds|t|cFF0000Abonnement indisponible|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_NOTIFICATION_LIBADDOMENU, "|cFF0000[ESO Plus]|r LibAddonMenu-2.0 introuvable. Vérifiez et installez-la.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_STRING_MENU, "|cCCECC0Date|r                |c98FB98Statut|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM, "|cEEEE00Demandons à @Eswagrom...|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_A, "|c2DF5F8[@Eswagrom] chuchote : Salut, l'abonnement est maintenant disponible UTILISEZ-LE|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_C, "|c5EB9D7[@Eswagrom] : Salut, que pensez-vous de l'essai gratuit ?|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ESWAGROM_B, "|c2DF5F8[@Eswagrom] chuchote : Salut, actuellement l'abonnement n'est pas disponible -_-|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION, "Envoyer les notifications dans le chat", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHAT_NOTIFICATION_A, "|c00FF00Si DÉSACTIVÉ, le message automatique sur l'abonnement ne sera pas envoyé dans le chat, seul le contrôle manuel /esoplus restera.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT, "Taille de la police dans le tableau", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_FONT_A, "|c00FF00Modifie la taille de la police dans la fenêtre d'historique des statuts (de 8 à 24)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY, "Tableau d'enregistrement de l'abonnement", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_A, "|c00FF00Ouvre une fenêtre séparée avec des informations sur l'essai gratuit|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_AVA, "|t15:15:/esoui/art/interaction/accept.dds|t |c00FF00disponible|r |t15:15:/esoui/art/interaction/accept.dds|t", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_UNAVA, "|cFF0000X|r |cFF0000indisponible|r |cFF0000X|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES, "Nombre de lignes pour l'enregistrement", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_HISTORY_LINES_A, "|c00FF00Combien de lignes seront enregistrées dans l'historique SavedVariables [affecte la taille du fichier et la durée de l'enregistrement, au-delà de la limite il y aura réécriture] (de 100 à 5000 nombre possible de lignes)|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_RESET_WINDOW, "|cEEEE00Position de la fenêtre réinitialisée.|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME, "|c00FF00Enregistrements EsoPlus|r", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS, "|cFF6347Réinitialiser les Paramètres!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_DEFAULTS_SETTINGS_A, "|cFF6347Ramène tous les paramètres de l'addon à l'état 'juste installé'. Réinitialise la position, la taille, la transparence, la police, la visibilité, le nombre de lignes (supprimera les lignes au-delà de la limite enregistrée !!! initialement 2000 lignes) et l'historique.|r", 1)
    
    -- Информационное сабменю
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS, "|c00FF00Informations sur ESO Plus|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_A, "|c9999FF/esoplus|r |cFF6347écrivez dans le chat pour un contrôle manuel !|r Cet addon enregistre les reçus de l'essai gratuit, donc vous saurez toujours exactement quel jour il a été activé ou manquait. Par défaut, l'historique stocke jusqu'à 2000 entrées. Qu'est-ce que cela signifie en pratique ? Chaque entrée dans le tableau prend une ligne par jour. Ainsi, la limite de 2000 lignes couvre une période d'environ 2000/365≈5,48 ans. En d'autres termes, l'addon conservera l'historique de vos abonnements pendant presque cinq ans et demi.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AA, "|c00FF00api utilisées par cet addon|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAA, "API (Application Programming Interface) — est un ensemble de règles par lesquelles votre addon interagit avec le serveur de jeu. Pour faire simple, c'est une liste de commandes autorisées qui définissent les limites de ses possibilités. Les méthodes suivantes ont été utilisées pour la mise en œuvre :", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AB, "|c00FF00* HasEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAB, "** _Returns:_ *bool* _hasFreeTrialNotification_", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AC, "|c00FF00* ClearEsoPlusFreeTrialNotification()|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAC, "Cet addon n'a pas de fonction de liaison de touche pour appeler le tableau utilisateur avec l'historique des enregistrements, car l'addon est purement informatif. Vous n'aurez presque jamais besoin de ce tableau. L'auteur a délibérément omis d'ajouter un tel bouton en raison de la limitation du jeu : seulement 100 emplacements sont disponibles pour les touches personnalisées, il est donc inopportun de les occuper avec des éléments superflus.", 1)
    
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AD, "|c00FF00Fonction de vérification automatique!!!|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_INFO_ESO_PLUS_AAD, "|c9999FFLes vérifications automatiques du statut de l'abonnement ont lieu toutes les 15 minutes, indépendamment des paramètres de l'addon, cela est nécessaire pour que vous ne manquiez pas le statut si celui-ci est activé un peu plus tard le même jour, la fonction de vérification ne charge pas votre système. Un tel minuteur est complètement sûr pour les performances. Voici pourquoi :|r |cFFFFC5Fréquence d'exécution Toutes les 15 minutes — c'est extrêmement rare pour un moteur de jeu. À titre de comparaison : le client ESO lui-même traite des dizaines de milliers d'événements chaque seconde (animation, rendu, paquets réseau). Une fonction toutes les 15 minutes est une goutte d'eau dans l'océan. - Toutes les opérations ici sont purement logiques : lecture du statut du compte via l'API intégrée (HasEsoPlus...), travail avec la table locale (Lua table) et affichage d'un message dans le chat (d()). Il n'y a pas de calculs lourds, de boucles sur de grands tableaux, d'accès aux fichiers ou au réseau. Des appels comme ZO_SavedVars, d(), ClearEsoPlus... sont optimisés par les développeurs de ZOS et prennent des microsecondes.|r |cffd700Ping|r est déterminé par la qualité de la connexion Internet et la charge des serveurs ESO. Le minuteur Lua local du client n'envoie pas de données au serveur plus souvent que le jeu ne le fait déjà. La fonction HasEsoPlusFreeTrialNotification() utilise le statut mis en cache du compte — elle ne crée pas de trafic réseau supplémentaire. |c1E90FFComparaison avec d'autres addons.|r De nombreux addons populaires utilisent des minuteurs beaucoup plus fréquents : |cADD8E6- Inventory Insight|r — vérifie l'inventaire à chaque ouverture ; |cADD8E6- Combat Metrics|r — analyse chaque tick de combat (des dizaines de fois par seconde) ; - même les éléments UI standards se mettent à jour 60+ fois par seconde. Ce |cADD8E6minuteur|r de 900 secondes ressemble à « une fois par ère » à côté de cela.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO, "|cFF6347Tableau ci-dessous:|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_ADDON_NAME_INFO_A, "|c9999FFLe tableau affiche jusqu'à 20 cycles d'enregistrements, indiquant les périodes où EsoPlus était disponible ou non (du début à la fin).|r |cFFFFCOuvrir le tableau:|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_RECORDS, "|ccdfff3Tous les enregistrements|r", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_GENERAL_INFO_ESOPLUS, "|ccdfff3INFORMATION|r", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG, "liste des modifications", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGA, "EsoPlusFreeTrialNotification V1.0", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_A, "première version", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_AA, "avec l'ancienne bibliothèque LibStub", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGB, "EsoPlusFreeTrialNotification v1.1", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_B, "modifications pour ESOUI :", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_BB, "1 la connexion à LibStub a été supprimée, une connexion à LibAddonMenu-2.0 ajoutée\n 2 tous les fichiers de langue avec des chaînes locales\n 3 Correction des variables globales sans référence locale pour accélérer l'accès au tableau _G\n 4 correction de quelques modifications mineures, similaires à celles décrites ci-dessus.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGC, "EsoPlusFreeTrialNotification v1.2", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_C, "Optimisation du code, première partie", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_CC, "**1. Table globale unique Unified Namespace\n **Implémentée correctement.\n Une seule table globale est utilisée : ESOPLUSFREETRIALNOTIFICATION_ESWAGROM avec un alias local EPFTN.\n 2. Optimisation de l'accès G optimization\n L'utilisation de local EPFTN ... est considérée comme un très bon style de codage. Cela accélère l'accès à la table au niveau micro en mettant en cache la référence dans la pile Lua, ce qui évite de rechercher à nouveau la table globale lente G à chaque appel de fonction. 3.\n Menu de configuration intégré : Le fichier de configuration externe .xml a été complètement supprimé. Toutes les configurations et entrées sont maintenant traitées à l'intérieur du système, et la bibliothèque moderne LibAddonMenu-2.0 est utilisée pour plus de commodité.\n 4. Modifié\n Optimisation du code :\n Toutes les configurations inutilisées ont été supprimées et la plupart des lignes de code obsolète ont été retirées, ce qui a considérablement réduit sa taille.\n La base de code restante a été considérablement optimisée ; la logique est désormais minimale, claire et facile à entretenir.\n 5. Corrigé\n Interface utilisateur de la table avec défilement : Le problème avec le tableau de données interne a été résolu. Une barre de défilement verticale pleinement fonctionnelle a été implémentée, permettant aux utilisateurs de naviguer facilement entre les enregistrements.", 1)

    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOGD, "EsoPlusFreeTrialNotification v1.3", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_D, "optimisation du tableau", 1)
    SafeAddString(SI_ESOPLUSFREETRIALNOTIF_CHANGELOG_DD, "1). Optimisation du tableau d'historique\n * **Ce qui a changé :**\n La logique d'affichage des entrées dans le tableau d'historique a été entièrement repensée. Auparavant, chaque ligne était un élément d'interface utilisateur distinct avec une mise en forme individuelle, ce qui provoquait des erreurs visuelles et des retards lors du traitement de grands volumes de données.\n Les problèmes de fusion des couleurs de texte ont été corrigés.\n Le délai d'une seconde à l'ouverture de la fenêtre de l'addon a été éliminé.\n> Pourquoi cela s'est-il produit ?\n C'est un problème classique d'optimisation de l'interface d'un jeu :\n Optimisation de la mémoire : chaque changement de couleur augmente la charge sur le processeur et la mémoire vive. Le moteur regroupe les éléments ayant les mêmes styles pour réduire le nombre d'objets à rendre.\n Limite du moteur (ZO_ScrollList) : l'API ESO a une limite sur le nombre de formats de texte uniques dans une liste déroulante. Une fois la valeur seuil atteinte, soit environ 128 lignes, le moteur cesse de traiter les étiquettes de couleur individuelles (|c...) et commence à appliquer le style du groupe précédent à toutes les entrées suivantes.\n Fusion par défaut : comme de nombreuses lignes ont le même formatage, l'interface utilisateur les considère comme un seul bloc logique et applique un style unique de bas en haut.\n Nouvelle solution :\n L'historique ne conserve désormais que les 20 dernières périodes de disponibilité/indisponibilité d'EsoPlus. Cela fournit un volume d'informations suffisant et garantit l'ouverture instantanée du tableau sans aucun retard.\n Note importante : Le volume de données dans le fichier SavedVariables (même s'il contient 2000-5000 enregistrements) n'affecte en rien les performances dans le jeu. La limitation ne concerne que la visualisation de l'interface utilisateur.\n **2). Chargement sécurisé de la localisation\n * **Le système de traduction linguistique a été amélioré. L'anglais sert maintenant d'ancre de base sécurisée (langue principale), après quoi la localisation choisie par l'utilisateur est chargée par-dessus. Cela rend le processus d'initialisation du texte plus stable et prévisible.\n **3). Nettoyage du code\n * **Toutes les fonctions et variables inutilisées ont été supprimées du fichier principal de l'addon. La base de code est maintenant plus propre, plus légère et plus facile à entretenir.", 1)
