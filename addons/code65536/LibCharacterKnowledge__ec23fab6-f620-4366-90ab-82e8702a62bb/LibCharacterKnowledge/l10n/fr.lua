-- Translated by: @jakez31
-- Translated by: @XXXspartiateXXX

local Register = LibCodesCommonCode.RegisterString

Register("SI_LCK_SCAN_START"                , "Analyse du tableau des objets; cela ne se produit qu'une seule fois par mise à jour majeure du jeu.")
Register("SI_LCK_SCAN_COMPLETE"             , "Analyse terminée.")

Register("SI_LCK_SETTINGS_CHATCOMMAND"      , "Ce panneau de paramètres de l'addon est également accessible via la |c00CCFF/lck|r commande de Tchat.")

Register("SI_LCK_SETTINGS_SERVER"           , "Serveur")

Register("SI_LCK_SETTINGS_USE_DEFAULT"      , "Utilisation par défaut")

Register("SI_LCK_SETTINGS_TRACKING1"        , "Ne pas suivre")
Register("SI_LCK_SETTINGS_TRACKING2"        , "Suivre la qualité faible")
Register("SI_LCK_SETTINGS_TRACKING3"        , "Suivre la qualité moyenne")
Register("SI_LCK_SETTINGS_TRACKING4"        , "Tout suivre")

Register("SI_LCK_SETTINGS_PRIORITY"         , "Classe prioritaire")
Register("SI_LCK_SETTINGS_PRIORITY_HELP"    , "Plusieurs personnages peuvent partager la même classe de priorité; les personnages d'une même classe de priorité sont classés par ancienneté, les personnages plus anciens étant prioritaires sur les personnages plus récents.")

Register("SI_LCK_SETTINGS_EXPORT"           , "Sélectionner pour l'exportation")

Register("SI_LCK_SETTINGS_MAIN_SECTION"     , "Suivi et priorité")
Register("SI_LCK_SETTINGS_RANKING_PREVIEW"  , "Ordre de classement actuel des personnages")
Register("SI_LCK_SETTINGS_SYSTEM_DEFAULTS"  , "Ces valeurs par défaut des paramètres du système s'appliqueront à chaque personnages à moins qu'elles ne soient remplacées au niveau du serveur, du compte ou du personnage:")
Register("SI_LCK_SETTINGS_SERVER_DEFAULTS"  , "Ces valeurs par défaut des paramètres du serveur s'appliqueront à chaque personnage de ce serveur à moins qu'elles ne soient remplacées au niveau du compte ou du personnage:")
Register("SI_LCK_SETTINGS_ACCOUNT_DEFAULTS" , "Ces valeurs par défaut des paramètres communs au compte s'appliqueront à chaque personnage appartenant à ce compte, sauf si elles sont remplacées au niveau du personnage:")

Register("SI_LCK_SETTINGS_SHARE_SECTION"    , "Partager des données")
Register("SI_LCK_SETTINGS_SHARE_CAPTION"    , "Exporter et copier, ou coller et importer, pour partager des données")
Register("SI_LCK_SETTINGS_SHARE_EXPORTC"    , "Exporter l'actuel")
Register("SI_LCK_SETTINGS_SHARE_EXPORTCT"   , "Exporter les données de connaissance pour le personnage actuel")
Register("SI_LCK_SETTINGS_SHARE_EXPORTA"    , "Tout exporter")
Register("SI_LCK_SETTINGS_SHARE_EXPORTAT"   , "Exporter les données de connaissance pour chaque personnage activé")
Register("SI_LCK_SETTINGS_SHARE_EXPORTS"    , "Exporter la sélection (%d)")
Register("SI_LCK_SETTINGS_SHARE_EXPORTST"   , "Exporter les données de connaissance pour les personnages avec \"Sélectionner pour l'exportation\" activé")
Register("SI_LCK_SETTINGS_SHARE_IMPORT"     , "Importé")
Register("SI_LCK_SETTINGS_SHARE_CLEAR"      , "Nettoyé")

Register("SI_LCK_SETTINGS_RESET_SECTION"    , "Réinitialiser les données")
Register("SI_LCK_SETTINGS_RESET_WARNING"    , "Réinitialise tous les paramètres, supprime toutes les données associées à LibCharacterKnowledge et recharge l'interface utilisateur.")

Register("SI_LCK_SETTINGS_NOSAVE_SECTION"   , "Comptes exclus")
Register("SI_LCK_SETTINGS_NOSAVE_CAPTION"   , "Liste des comptes, séparés par des virgules, pour exclure de l'enregistrement")

Register("SI_LCK_SHARE_EXPORT_LIMIT"        , "Ignoré [<<1>>/<<2>>]; limite de données atteinte.")
Register("SI_LCK_SHARE_IMPORT_STALE"        , "Ignoré [<<1>>/<<2>>]; les données actuelles sont plus récentes.")
Register("SI_LCK_SHARE_IMPORT_DONE"         , "Importé [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LCK_SHARE_IMPORT_INVALID"      , "Abandon de l'importation; données corrompues rencontrées.")
Register("SI_LCK_SHARE_IMPORT_BADVERSION"   , "Les données importées ont été codées par une version incompatible de LibCharacterKnowledge; veuillez vous assurer que l'ensemble des utilisateurs ont mis à jour la dernière version de LibCharacterKnowledge.")
Register("SI_LCK_SHARE_IMPORT_NEWCHARACTER" , "Vous avez importé un ou plusieurs nouveaux personnages qui n'existaient pas auparavant dans la base de données; |c00CCFF/reloadui|r peut être nécessaire pour que les personnages nouvellement ajoutés apparaissent dans les menus et les paramètres.")
Register("SI_LCK_SHARE_IMPORT_TALLY"        , "<<1>> personnages importés.")
