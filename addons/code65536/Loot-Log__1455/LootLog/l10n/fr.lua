-- Translated by: @jakez31
-- Translated by: @XXXspartiateXXX

local Register = LibCodesCommonCode.RegisterString

Register("SI_LOOTLOG_SUBTITLE_LIST"     , "Historique du butin")
Register("SI_LOOTLOG_SUBTITLE_MATS"     , "Matériaux")

Register("SI_LOOTLOG_SHOW_UNCOLLECTED"  , "Objets non collectés")
Register("SI_LOOTLOG_TIME_LABEL"        , "Matériaux collectés le: %s")

Register("SI_LOOTLOG_HEADER_TIME"       , "Temps")
Register("SI_LOOTLOG_HEADER_ITEM"       , "Objet")
Register("SI_LOOTLOG_HEADER_TRAIT"      , "Trait")
Register("SI_LOOTLOG_HEADER_COUNT"      , "Quantité")
Register("SI_LOOTLOG_HEADER_RECIPIENT"  , "Destinataire")
Register("SI_LOOTLOG_HEADER_CURTOTAL"   , "Total actuel")

Register("SI_LOOTLOG_MODE0"             , "Aucun")
Register("SI_LOOTLOG_MODE1"             , "Objets d'ensemble (personnels)")
Register("SI_LOOTLOG_MODE2"             , "Objets d'ensemble")
Register("SI_LOOTLOG_MODE3"             , "Butin notable (personnel)")
Register("SI_LOOTLOG_MODE4"             , "Butin notable")
Register("SI_LOOTLOG_MODE5"             , "Tout le butin (personnel)")
Register("SI_LOOTLOG_MODE6"             , "Tous enregistrés")

Register("SI_LOOTLOG_HISTORY_LABEL"     , "Conservation de l'historique: %dh (|c336699|l0:1:1:1:1:336699|lChanger/Effacer|l|r)")
Register("SI_LOOTLOG_CHATCOMMANDS_LINK" , "Vous souhaitez associer ou partager un lien des objets d'ensemble ? |c336699|l0:1:1:1:1:336699|lCommandes de Tchat|l|r")

Register("SI_LOOTLOG_CHATCOMMANDS"      , "Commandes de Tchat")
Register("SI_LOOTLOG_LINKTRADE"         , "Publier un lien des objets en surplus")
Register("SI_LOOTLOG_BINDUNCOLLECTED"   , "Associer les objets non collectés")

Register("SI_LOOTLOG_TRADE_REQUEST"     , "Demande")
Register("SI_LOOTLOG_TRADE_LINKRESET"   , "Publier les temps de recharge pour |c00CCFF/linktrade|r ont été réinitialisés.")
Register("SI_LOOTLOG_TRADE_NOLINKS"     , "Aucun lien d'objet à publier.")
Register("SI_LOOTLOG_TRADE_NOLINKS_CD"  , "Aucun nouveau lien d'objet à publier; pour publier le %d objet(s) récemment associé(s), Utilisez la commande |c00CCFF/linktrade reset|r")
Register("SI_LOOTLOG_TRADE_OVERFLOW"    , "Objets restants: %d")
Register("SI_LOOTLOG_BIND_COMPLETED"    , "Objets associés: %d%s")
Register("SI_LOOTLOG_BIND_OVERFLOW"     , "Objets restants: %d; pour éviter les erreurs de limite de débit de messages, attendez brièvement et utilisez à nouveau la commande |c00CCFF/binduncollected|r pour lier les objets restants.")
Register("SI_LOOTLOG_BIND_SHOW"         , "Afficher les objets")
Register("SI_LOOTLOG_AUTOBIND_ON"       , "Les objets d'ensemble non collectés seront automatiquement associés pendant les %d prochaines minutes.")
Register("SI_LOOTLOG_AUTOBIND_OFF"      , "Les objets d'ensemble non collectés ne seront plus automatiquement associés.")

Register("SI_LOOTLOG_SECTION_HISTORY"   , "Données d'historique")
Register("SI_LOOTLOG_SECTION_CHAT"      , "Notifications de Tchat")
Register("SI_LOOTLOG_SECTION_TRADE"     , "Outils de vente")
Register("SI_LOOTLOG_SECTION_UNCCOLORS" , "Couleurs des indicateurs non collectés")
Register("SI_LOOTLOG_SECTION_LCK"       , "Support de LibCharacterKnowledge")
Register("SI_LOOTLOG_SECTION_MULTI"     , "Support multi-comptes")

Register("SI_LOOTLOG_SETTING_HISTORY"   , "Conservation minimale de l'historique (heures)")
Register("SI_LOOTLOG_SETTING_CLEAR"     , "Effacé l'historique")
Register("SI_LOOTLOG_SETTING_CHATMODE"  , "Notifications de Tchat")
Register("SI_LOOTLOG_SETTING_CHATICONS" , "Afficher les icônes dans le Tchat")
Register("SI_LOOTLOG_SETTING_CHATSTOCK" , "Affiche le stock de matériel d'artisanat")
Register("SI_LOOTLOG_SETTING_CHATUNC"   , "Signaler les objets non collectés")
Register("SI_LOOTLOG_SETTING_CHATUNCTT" , "De plus, si le mode de notification est défini sur personnel, les objets non collectés ramassés par d'autres joueurs ignoreront le filtre personnel.")
Register("SI_LOOTLOG_SETTING_CHATRCLR"  , "Utiliser la couleur statique du destinataire")
Register("SI_LOOTLOG_SETTING_TRADEITLS" , "Signaler les objets non collectés partout")
Register("SI_LOOTLOG_SETTING_TRADEILTT" , "Cela incluent l'inventaire des joueurs, les banques, l'inventaire des vendeurs et les fenêtres de butin.")
Register("SI_LOOTLOG_SETTING_TRADELINK" , "Signaler les non collectés, publier par d'autres")
Register("SI_LOOTLOG_SETTING_TRADEREQ"  , "Afficher le lien de la demande")
Register("SI_LOOTLOG_SETTING_TRADEREQ1" , "Avant message")
Register("SI_LOOTLOG_SETTING_TRADEREQ2" , "Après message")
Register("SI_LOOTLOG_SETTING_TRADEREQM" , "Message de la demande")
Register("SI_LOOTLOG_SETTING_TRADEBE"   , "Inclure les objets lié-quand-équipé")
Register("SI_LOOTLOG_SETTING_TRADEBETT" , "La commande de Tchat |c00CCFF/linktrade|r (ou |c00CCFF/lt|r) publiera dans le Tchat un lien des objets échangeables lié-quand-ramassé qui ont deja été collectés, et si cette option est activée, elle inclura également les objets lié-quand-équipé.")
Register("SI_LOOTLOG_SETTING_UCLRPERS"  , "Ramassé par vous")
Register("SI_LOOTLOG_SETTING_UCLRGRP"   , "Ramassé par d'autres")
Register("SI_LOOTLOG_SETTING_UCLRITLS"  , "Listes d'objets")
Register("SI_LOOTLOG_SETTING_UCLRCHAT"  , "Publié par d'autres")
Register("SI_LOOTLOG_SETTING_UCLRITLS"  , "Autres contextes")

Register("SI_LOOTLOG_LCK_DESCRIPTION"   , "S'il est activé, Loot Log prendra en compte l'état des connaissances des autres personnages lors du marquage des recettes, des plans d'ameublement et des motifs comme inconnus.")
Register("SI_LOOTLOG_MULTI_DESCRIPTION" , "S'il est activé, Loot Log peut signaler les objets qui ne sont pas collectés et échangeables avec d'autres comptes.\n\nPour utiliser cette fonctionnalité, vous devez utiliser la section Priorités de compte ci-dessous pour configurer les comptes à signaler.\n\nCette fonctionnalité nécessite LibMultiAccountSets ou LibMultiAccountCollectibles.")
Register("SI_LOOTLOG_MULTI_ACCOUNTS"    , "Priorités du compte")
Register("SI_LOOTLOG_MULTI_PRIORITY"    , "Priorité partageable %d")

Register("SI_LOOTLOG_SELF_IDENTIFIER"   , "Vous")

Register("SI_LOOTLOG_WELCOME"           , "Vous avez installé |cCC33FFLoot Log 4|r, avec un |c00FFCC|H0:lootlog|hhistorique de butin consultable|h|r accessible via la commande de Tchat |c00CCFF/lootlog|r ou via le raccourci clavier. Veuillez consulter la |c00FFCC|H0:llweb|hpage de l'addon Loot Log|h|r pour plus de détails.")
