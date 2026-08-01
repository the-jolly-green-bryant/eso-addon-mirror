-- SwissArmyKnife French Localization File
-- Last Updated 14-10-2017
-- Written Decembre 2016 by Tristan Carron (@homeopatix)
-- Released under terms in license accompanying this file.

-- Options Menu
ZO_CreateStringId("KF_KEY_TO_SEARCH", "SwissArmyKnife")

-- KeyBindings
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeTEXT", "Affiche SwissArmyKnife")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeJUMP", "Voyager vers la maison Principale")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeJUNK", "Définis Junk")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeLOCK", "Lock ou Unlock")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeBAND", "Change l'affichage du bandeau")
ZO_CreateStringId("SI_BINDING_NAME_SwissArmyKnifeHELMET", "Affiche ou cache le casque")

-- Slash commande
SAK.lang = {
		KF_SLASH_1 = "Slash commande pour ",
		KF_SLASH_2 = "Affiche les slash commande",
		KF_SLASH_3 = "Montre l'addon graphique",
		KF_SLASH_4 = "Cache l'addon graphique",
		KF_SLASH_5 = "Montre tous les ",
		KF_SLASH_5_2 = " dans le chat",
		KF_SLASH_7 = "Ne rien montrer dans le chat (default)",

		KF_SLASH_8 = "Affichage de tous les ",
		KF_SLASH_8_2 = " ramassés activé",
		KF_SLASH_10 = "Affichage des ",
		KF_SLASH_10_2 = " et les ",
		KF_SLASH_10_3 = " désactivé",
		KF_GOOD = "************* Bon farming !! **************",

		KF_INITIALIZED = "est initialisé !!",
		-- money deposit
		KF_RAD = "Déposé en banque ",
		KF_RAD_1 = "Rien à déposé en banque.",
		KF_RAD_2 = "Reste : ",
		KF_RAD_3 = " et ",
		KF_RAD_4 = " sur le personnage",
		KF_SLASH_18 = "Argent min à garder sur soit",
		KF_SLASH_19 = "Pierres de Tel Var min à garder sur soit",

		KF_SLASH_20 = "Argent min à garder dans le sac defini à ",
		KF_SLASH_21 = "Tel Var min à garder dans le sac defini à ",
		KF_SLASH_22 = "Slash command pour quitter un group",
		KF_SLASH_23 = "Tu n'est pas groupé !!!!",
		KF_SLASH_24 = "Tu quitte le groupe !!!!",

		KF_SETTINGS_1 = "Affichage",
		KF_SETTINGS_2 = "Money Bank",
		KF_SETTINGS_21 = "Auto Dèpôt paramètres",
		KF_SETTINGS_3 = "Affiche les Settings",

		KF_COST_REPAIR = "Cout de reparation :",
		KF_SEUIL_REP_1 = "Durability",
		KF_SEUIL_REP_2 = "Seuil Durability",
		KF_SEUIL_REP_3 = "Seuil de reparation d'armures",
		KF_SEUIL_REP_4 = "Defini seuil de reparation",
		KF_SEUIL_REP_5 = "Seuil de rep defini a ",
		
		KF_SEUIL_REP_6 = "Couleur de surbrillance du contour",
		KF_SEUIL_REP_6_2 = "Couleur d'affichage de la durability du contour",
		KF_SEUIL_REP_7 = "Couleur de surbrillance du texte",
		KF_SEUIL_REP_7_2 = "Couleur d'affichage du texte de la durability",

		KF_SEUIL_REPA_1 = "Charges",
		KF_SEUIL_REPA_2 = "Seuil Charges",
		KF_SEUIL_REPA_3 = "Seuil de charge d'arme",
		KF_SEUIL_REPA_4 = "Defini seuil de charge",
		KF_SEUIL_REPA_5 = "Seuil de charge defini a ",
		
		KF_SEUIL_REPA_6 = "Couleur de surbrillance du contour",
		KF_SEUIL_REPA_6_2 = "Couleur d'affichage de la durability du contour",
		KF_SEUIL_REPA_7 = "Couleur de surbrillance du texte",
		KF_SEUIL_REPA_7_2 = "Couleur d'affichage du texte de la charge",
		KF_REPAIR_1 = "Equipements réparé pour",
		KF_REPAIR_2 = "Pas assez d'argent pour réparé",
		KF_AUTO_REPA_1 = "Réparations automatique",
		KF_AUTO_REPA_2 = "Utilisation de l'auto-reparation",
		KF_AUTO_REPA_4 = "Affichage auto réparation dans le chat",
		KF_AUTO_REPA_6 = "Recharge automatique",
		KF_AUTO_REPA_7 = "Utilisation de l'auto-recharge",
		KF_AUTO_REPA_9 = "Affichage auto recharge dans le chat",
		KF_AUTO_REPA_10 = "Defini le seuil de recharge auto",
		KF_AUTO_REPA_11 = "Seuil de recharge auto défini à ",
		KF_AUTO_REPA_12 = "rechargé avec",
		KF_AUTO_REPA_13 = "Activé",
		KF_AUTO_REPA_14 = "Désactivé",
		

		KF_GENERAL_ST_1 = "General",
		KF_GENERAL_ST_2 = "Multi-compte",
		KF_GENERAL_ST_2_1 = "Sauvegarde les reglages pour tous les personnages",
		KF_GENERAL_ST_3 = "Ce changement rechargera l'interface utilisateur",
		KF_GENERAL_ST_4 = "Montre l'experience",
		KF_GENERAL_ST_4_1 = "Montre l'experience et le niveau",
		KF_GENERAL_ST_8 = "Montre la taille de la plage d'illumination",
		KF_GENERAL_ST_8_1 = "Montre la taille de la plage d'illumination ou l'experience manquante",
		KF_GENERAL_ST_8_2 = "Montre la barre d'illumination",
		KF_GENERAL_ST_8_3 = "Montre la barre d'illumination ou non",

		KF_LANG_1 = "Bonjour au groupe",
		KF_LANG_2 = "Au revoir et merci au groupe",
		KF_LANG_3 = "Reponse à un ami",
		KF_LANG_4 = "Bonjour à la guild1",
		KF_LANG_5 = "Bonjour à la guild2",
		KF_LANG_6 = "Bonjour à la guild3",
		KF_LANG_7 = "Bonjour à la guild4",
		KF_LANG_8 = "Bonjour à la guild5",
		KF_LANG_10 = "Affiche les slash commande de language",
		KF_SLASH_11 = "Slash commande de language pour ",

		KF_SETTINGS_1_1 = "Réparation et charges",
		KF_SETTINGS_2_1 = "Texte Automatique",
		KF_SETTINGS_3_1 = "!!!! On ne peut pas envoyer de message directement dans le chat, Donc le message et ecrit pour vous dans le chat et vous n'avez plus qu'a presser enter pour le poster !!!!",
		KF_SETTINGS_4 = "Groupe",
		KF_SETTINGS_5 = "Message de bienvenue               /kh =",
		KF_SETTINGS_6 = "Message d'adieu               /kt =",
		KF_SETTINGS_7 = "Amis",
		KF_SETTINGS_8 = "Reponse pour le copain               /kr =",
		KF_SETTINGS_9 = "Guilde",
		KF_SETTINGS_10 = "Guild 1               /kg1 =",
		KF_SETTINGS_11 = "Guild 2               /kg2 =",
		KF_SETTINGS_12 = "Guild 3               /kg3 =",
		KF_SETTINGS_13 = "Guild 4               /kg4 =",
		KF_SETTINGS_14 = "Guild 5               /kg5 =",
		KF_SETTINGS_15 = "Presser le bouton valider pour confirmer vos choix",
		KF_SETTINGS_16 = "Valider",
		KF_SETTINGS_17 = "Affiche l'icon du mail",
		KF_TRAVEL_1 = "Affiche le cout de voyage",
		KF_TRAVEL_2 = "Affiche le cout de voyage ou non",
		KF_STATS_4 = "Experience",

		KF_TIME_PLAYED_1 = "Montre le Temp de jeu",
		KF_TIME_PLAYED_2 = "Affiche votre temp de jeu total et de session",
		KF_TIME_PLAYED_3 = " jour(s)",
		KF_TIME_PLAYED_4 = " heure(s)",
		KF_TIME_PLAYED_5 = " minute(s)",
		KF_TIME_PLAYED_6 = " seconde(s)",
		KF_TIME_PLAYED_7 = "Montre l'Or gagné",
		KF_TIME_PLAYED_8 = "Or gagné pendant la session et or gagné à l'heure",
		
		KF_TIME_PLAYED_9_1 = "Gold par heure",
		KF_TIME_PLAYED_9 = "Réparation incluse",
		KF_TIME_PLAYED_10 = "Inclure le cout des réparations dans le gain d'or a l'heure",
		KF_TIME_PLAYED_11 = "Afficher le niveau de champion",
		KF_TIME_PLAYED_12 = "Afficher le niveau de champion ou non",

		KF_STATS_1 = "Statistiques",
		KF_STATS_2 = "Remise à Zero",
		KF_STATS_3 = "Remise à Zero de l'argent gagné par heure et du temps de jeu",

		KF_HOUSE_1 = "Maison",
		KF_HOUSE_2 = "Maison Principale",
		KF_HOUSE_3 = "Voyager vers la maison",
		KF_HOUSE_4 = "Préparation pour le voyage vers ",
		KF_HOUSE_5 = "Impossible de voyager depuis Cyrodiil",
		KF_HOUSE_6 = "Change le bandeau",

		KF_SMALL_ADDON_1 = "Affichage potions",
		KF_SMALL_ADDON_2 = "Affichage des potions ou des Soulgem en dehors de la citè impérial",

		KF_THIEF_1 = "Voleur",
		KF_THIEF_2 = "Change votre nom en warning clignotant quand rechercher par les gardes",
		KF_THIEF_3 = "Désactivé le Warning",
		KF_THIEF_4 = "Addon Voleur",
		KF_THIEF_5 = "Désactivé l'Addon Voleur",
		KF_THIEF_6 = "Affichage du heat",
		KF_THIEF_7 = "Affichage du niveau de recherche",

		KF_DIS_START_1 = "Affichage complet",
		KF_DIS_START_2 = "Affichage complet au lancement du jeu",

		KF_DONATE_1 = "Vous pouvez m'envoyer un commentaire ou un cadeau par mail directement, d'avance merci !!!",
		KF_DONATE_2 = "Donner par mail",
		KF_DONATE_3 = "Donne 100 Gold",
		KF_DONATE_4 = "Donne 1000 Gold",
		KF_DONATE_5 = "Donne 10000 Gold",
		KF_DONATE_6 = "Donne 100000 Gold",
		KF_DONATE_7 = "Envoyer un commentaire",

		KF_BAG_1 ="Seuil d'alert taille du sac",
		KF_BAG_2 ="Place libre dans le sac pour alerte",

		KF_REPAIRCOST_1 = "Affichage du cout de réparation",
		KF_REPAIRCOST_2 = "Affiche ou non le cout de réparation",

		KF_BAGBANK_1 = "Affiche la taille du sac et de la bank",
		KF_BAGBANK_2 = "Affiche ou non la taille du sac ou de la banque",

		KF_COMBAT_1 = "Affiche en combat",
		KF_COMBAT_2 = "Affiche en combat ou non",

		KF_TELVAR = "TelVar Stone Alarme",
		KF_TELVAR_1 = "Active l'alarme pour les pierres de TelVar",
		KF_TELVAR_2 = "Pierres de Tel Var max avant alarme",
		KF_TELVAR_3 = "Defini le seuil d'alarme",
		KF_TELVAR_4 = "Seuil d'alarme defini a ",
		KF_ALLI_1 = "Point d'alliance à garder sur soit ",
		KF_ALLI_2 = "Point d'alliance à garder sur soit défini à",
		KF_ALLI_3 = "Assignats à garder sur soit ",
		KF_ALLI_4 = "Assignats à garder sur soit défini à",

		KF_MONEY_1 = "Montre l'or gagné",
		KF_MONEY_2 = "Montre les pierres de TelVar gagnées",
		KF_MONEY_3 = "Montre les points d'alliance gagnés",
		KF_MOUNT_1 = "Affiche le timer d'étable",
		KF_MOUNT_2 = "Montre le temps restant avant entrainement",
		KF_MOUNT_3 = "Disponible",
		KF_VAMP_1 = "Morsure Vampire disponible",
		KF_VAMP_2 = "Morsure Vampire disponible dans",
		KF_VAMP_3 = "Morsure Loup-Garou disponible",
		KF_VAMP_4 = "Morsure Loup-Garou disponible dans",

		KF_CRYSTAL_1 = "Affiche cristal de transmutation",
		KF_CRYSTAL_2 = "Affiche Les assignats",

		KF_JUNK_1 = "Objets Junk vendus",
		KF_JUNK_2 = "Aucun objets Junk à vendre",
		KF_JUNK_3 = "Objets Junk dans le sac",
		KF_JUNK_4 = "Vente automatique du junk",
		KF_JUNK_5 = "Affichage du junk",
		KF_JUNK_6 = "Affichage du junk ou non",
		KF_JUNK_7 = "JUNK & LOCK",
		KF_JUNK_8 = "Affiche le Junk dans le chat",
		KF_JUNK_9 = "Affiche le Lock dans le chat",
		KF_JUNK_10 = "Affichage de l'auto Junk",
		KF_JUNK_11 = "Affichage du loot dans le chat",
		KF_JUNK_12 = "a été supprimer du JUNK",
		KF_JUNK_13 = "a été défini comme JUNK",
		KF_JUNK_14 = "a été Verrouillé",
		KF_JUNK_15 = "a été Déverrouillé",

		KF_BANDEAU_1 = "Affichage du bandeau",
		KF_BANDEAU_2 = "Affichage des deadricAmbers",
		KF_BANDEAU_3 = "Affichage des potions",
		KF_BANDEAU_4 = "Affichage des SoulGems",
		KF_BANDEAU_5 = "Affichage du crafting",
		KF_BANDEAU_6 = "Choix de votre affichage",
		KF_BANDEAU_7 = "Affiche Potions de combat",
		KF_BANDEAU_8 = "Affiche Stealing helper",

		KF_WRIT_HELPER_1 = "Afficher la fenetre d'aide au craft",
		KF_WRIT_HELPER_2 = "Afficher la fenetre d'aide au craft ou non",
		KF_WRIT_HELPER_3 = "Afficher la fenetre d'aide pour le warning de recherche",
		KF_WRIT_HELPER_4 = "Afficher la fenetre d'aide pour le warning de recherche ou non",
		KF_WRIT_HELPER_5 = "Afficher la fenetre d'aide pour la recherche de group",
		KF_WRIT_HELPER_6 = "Afficher la fenetre d'aide pour la recherche de group ou non",
		KF_WRIT_HELPER_7 = "En File d'attente pour groupe",
		KF_WRIT_HELPER_8 = "Estimé",
		KF_WRIT_HELPER_9 = "Réel",

		KF_USE_BANK = "Utiliser l'auto dépôt",

		KF_DEPOSIT_MONEY = "Auto dépôt pour l'argent",
		KF_DEPOSIT_TELVAR = "Auto dépôt pour les pierres de Tel Var",
		KF_DEPOSIT_ALLIANCE = "Auto dépôt pour les point d'alliance",
		KF_DEPOSIT_WRIT = "Auto dépôt pour les Assignats",
}