TetsuQuietZone = TetsuQuietZone or {}
local L = TetsuQuietZone.L
if not L then return end

L.TITLE = "|cFFD700Tetsu's|r Quiet Zone"

L.INFO_LABEL = "Info"
L.INFO_TT = "Masque les lignes zone et say qui contiennent un lien de guilde. Peut aussi couper le chat des guildes choisies. Ne bloque pas la fenêtre d'invitation officielle.\nOr / bugs : courrier @Tetsurion."

L.ADS_SECTION = "Couper les pubs de guilde"
L.ADS_SECTION_TT = "Masque les murs de recrutement en zone / say / yell si la ligne a un lien de guilde."

L.ENABLED = "Activer le filtre pubs"
L.ENABLED_TT = "Interrupteur principal des pubs zone/say/yell. Activé = les lignes avec un lien de guilde n'apparaissent pas."

L.FILTER_ZONE = "Filtrer le chat de zone"
L.FILTER_ZONE_TT = "Tous les canaux de zone, langues comprises. Activé par défaut."

L.FILTER_SAY = "Filtrer le say"
L.FILTER_SAY_TT = "Say local. Activé par défaut."

L.FILTER_YELL = "Filtrer le yell"
L.FILTER_YELL_TT = "Désactivé par défaut. Activez si les pubs passent aussi en yell."

L.GUILD_SECTION = "Couper le chat de guilde"
L.GUILD_SECTION_TT = "Chaque interrupteur = une guilde dont tu es membre. Activé = masque ses messages. Les autres restent. Sauvé par id. Désactivé par défaut."
L.GUILD_HINT = "ON - masquer les messages de cette guilde"
L.GUILD_HINT_TT = "Activé = masque tous les messages /g et /o de cette guilde. Les autres, zone et say restent."
L.GUILD_EMPTY = "<<1>>. (emplacement vide)"
L.MUTE_GUILD_TT = "Activé = masque seulement les messages de cette guilde. Pas les autres, ni zone, ni say."

L.HIDDEN_LABEL = "Masqué cette session : <<1>>"
L.HIDDEN_TT = "Lignes ignorées depuis la connexion (pubs + guildes coupées). Remis à zéro au ReloadUI."
