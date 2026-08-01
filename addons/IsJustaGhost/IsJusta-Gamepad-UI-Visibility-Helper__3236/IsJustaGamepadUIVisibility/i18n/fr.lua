------------------------------------------------
-- French localization
------------------------------------------------
-- Courtesy of fzr6n7
local strings = {
    SI_IJA_DYNAMIC_CHAT 				= "Position de la fenêtre de discussion dynamique",
    SI_IJA_DYNAMIC_CHAT_TOOLTIP 		= "Activé: la fenêtre de discussion \"Clavier\" se repositionnera dynamiquement basée sur l'affichage \"Manette\" en cours.",
        
    SI_IJA_SIMPLE_CHAT  				= "Position de la fenêtre de discussion simple",
    SI_IJA_SIMPLE_CHAT_TOOLTIP 			= "Activé: la fenêtre de discussion \"Clavier\" ne suivra pas les élément de l'UI. A la place, elle ira se placer en bas à droite de l'écran, ou au dessus de la barre basse de l'UI.",

    SI_IJA_LOOTHISTORY_MOVE 			= "Modifier l'historique de \"Loot\"",
    SI_IJA_LOOTHISTORY_MOVE_TOOLTIP 	= "Activé: L'historique de \"loot\" de l'interface \"Manette\" utilise l'affichage de l'historique de loot \"Clavier\".",

    SI_IJA_LOOTHISTORY_FONTS_OVERLAY    = "Definit la police de texte de l'icône.",
	SI_IJA_LOOTHISTORY_FONTS_LABEL		= "Définit la police du texte du butin.",
	
	SI_IJA_HUDMETERS_MOVE               = "Déplacer les compteurs du HUD",
    SI_IJA_HUDMETERS_MOVE_TOOLTIP       = "Activé: utilise les compteurs de TelVar, de prime et  d'énergie daedrique par ceux de l'UI \"Clavier\"",
}
 
for stringId, stringValue in pairs(strings) do
	SafeAddString(stringId, stringValue, 1)
    SafeAddVersion(stringId, 1)
end