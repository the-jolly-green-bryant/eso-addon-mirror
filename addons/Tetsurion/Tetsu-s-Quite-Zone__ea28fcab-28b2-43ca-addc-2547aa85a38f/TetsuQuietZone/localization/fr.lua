TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "Info"
L.INFO_TT = "Masque les lignes zone et say qui contiennent un lien de guilde. Le reste du chat reste. Ne bloque pas la fenêtre d'invitation officielle.\nOr / bugs : courrier @Tetsurion."

L.ENABLED = "Masquer les pubs de guilde"
L.ENABLED_TT = "Interrupteur principal. Activé = les lignes zone/say avec un lien de guilde n'apparaissent pas."

L.FILTER_ZONE = "Filtrer le chat de zone"
L.FILTER_ZONE_TT = "Tous les canaux de zone, langues comprises. Activé par défaut."

L.FILTER_SAY = "Filtrer le say"
L.FILTER_SAY_TT = "Say local. Activé par défaut."

L.FILTER_YELL = "Filtrer le yell"
L.FILTER_YELL_TT = "Désactivé par défaut. Activez si les pubs passent aussi en yell."

L.HIDDEN_LABEL = "Masqué cette session"
L.HIDDEN_TT = "Lignes ignorées depuis la connexion. Remis à zéro au ReloadUI."
