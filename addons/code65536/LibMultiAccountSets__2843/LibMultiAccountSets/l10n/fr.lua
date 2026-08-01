-- Translated by: @jakez31

local Register = LibCodesCommonCode.RegisterString

Register("SI_LMAS_SCAN_STATUS"             , "%d / %d collecté (+%d nouveau)")

Register("SI_LMAS_SETTINGS_CHATCOMMAND"    , "Ce panneau de paramètres d'addon est également accessible via la commande de tchat |c00CCFF/lmas|r.")

Register("SI_LMAS_SETTINGS_CHAT_SECTION"   , "Notifications de tchat")
Register("SI_LMAS_SETTINGS_CHAT_UPDATES"   , "Affiche la mise à jour de votre collection d'articles")

Register("SI_LMAS_SETTINGS_SHARE_SECTION"  , "Partager les données du compte")
Register("SI_LMAS_SETTINGS_SHARE_CAPTION"  , "Exporter et copier, ou coller et importer, pour partager des données")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTC"  , "Exporter le courant")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTCT" , "Exporter les données de collection de jeux d'articles pour le compte actuel")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTA"  , "Tout exporter")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTAT" , "Exporter les données de collection de jeux d'articles pour chaque compte enregistré")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTS"  , "Exporter la sélection (%d)")
Register("SI_LMAS_SETTINGS_SHARE_EXPORTST" , "Exporter les données de collection de jeux d'articles pour les comptes répertoriés ci-dessous")
Register("SI_LMAS_SETTINGS_SHARE_IMPORT"   , "Importer")
Register("SI_LMAS_SETTINGS_SHARE_CLEAR"    , "Nettoyé")
Register("SI_LMAS_SETTINGS_SHARE_SELECT"   , "Comptes sélectionnés pour l'exportation")
Register("SI_LMAS_SETTINGS_SHARE_SELECTT"  , "Liste des comptes, séparés par des virgules, pour \"Exporter la sélection\"")

Register("SI_LMAS_SETTINGS_DELETE_SECTION" , "Supprimer les données du compte")
Register("SI_LMAS_SETTINGS_DELETE_BUTTON"  , "Effacer")
Register("SI_LMAS_SETTINGS_DELETE_WARNING" , "Cela supprimera toutes les données accumulées pour tous les comptes et rechargera l'UI.")

Register("SI_LMAS_SETTINGS_NOSAVE_SECTION" , "Comptes exclus")
Register("SI_LMAS_SETTINGS_NOSAVE_CAPTION" , "Liste des comptes, séparés par des virgules, pour exclure de l'enregistrement")

Register("SI_LMAS_SHARE_EXPORT_LIMIT"      , "Ignoré [<<1>>/<<2>>]; limite de données atteinte.")
Register("SI_LMAS_SHARE_IMPORT_STALE"      , "Ignoré [<<1>>/<<2>>]; les données actuelles sont plus récentes.")
Register("SI_LMAS_SHARE_IMPORT_DONE"       , "Importé [<<1>>/<<2>>]. (<<3>>)")
Register("SI_LMAS_SHARE_IMPORT_INVALID"    , "Annulation de l'importation; données corrompues rencontrées.")
Register("SI_LMAS_SHARE_IMPORT_BADVERSION" , "Les données importées ont été codées par une version incompatible de LibMultiAccountSets; veuillez vous assurer que les utilisateurs ont mis à jour la dernière version de LibMultiAccountSets.")
Register("SI_LMAS_SHARE_IMPORT_NEWACCOUNT" , "Vous avez importé un ou plusieurs nouveaux comptes qui n'existaient pas auparavant dans la base de données; |c00CCFF/reloadui|r peut être nécessaire pour que les comptes nouvellement ajoutés apparaissent dans les menus et les paramètres.")
Register("SI_LMAS_SHARE_IMPORT_TALLY"      , "<<1>> comptes importés.")
