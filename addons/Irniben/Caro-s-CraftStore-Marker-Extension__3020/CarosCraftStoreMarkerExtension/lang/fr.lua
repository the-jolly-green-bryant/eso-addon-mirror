local L = {}

L.CCSME_IconChoose = "Choisissez une icône"
L.CCSME_IconColorDescr = "La coloration de l'icône est facultative car elle peut parfois causer des problèmes avec d'autres addons liés au chat comme pChat."
L.CCSME_IconColorize = "Coloriser l'icône"
L.CCSME_IconColorChoose = "Choisis une couleur"
L.CCSME_ShowKnownByAll = "Afficher le marqueur dans l'info-bulle si tous les personnages connaissent une recette/motif"
L.CCSME_ShowKnownByAllCustomColor = "Couleur"
L.CCSME_ShowKnownByAllUseCustomColor = "Utiliser une couleur personnalisée"
L.CCSME_AutoMarkKnownByAllAsJunk = "Marquer automatiquement ces recettes/motifs comme indésirables permanents pour PersonalAssistant (sera appliqué au moment où l'info-bulle s'affichera)"
L.CCSME_UnmarkUnknownJunk = "Supprimer les éléments indésirable permanent inconnue sur le personnage actuel"

for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end