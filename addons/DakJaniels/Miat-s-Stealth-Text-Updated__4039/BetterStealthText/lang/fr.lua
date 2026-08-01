local strings =
{
    -- Main state strings
    BETTERSTEALTHTEXT_INVISIBLE = "Invisible",
    BETTERSTEALTHTEXT_REVEALED = "Révélé",
    BETTERSTEALTHTEXT_HIDING = "Dissimulé",

    -- Addon menu and option strings
    BETTERSTEALTHTEXT_ADDON_NAME = "Texte de Furtivité de Miat",
    BETTERSTEALTHTEXT_ADDON_OPTIONS = "Options du Texte de Furtivité de Miat",
    BETTERSTEALTHTEXT_ADDON_ENABLED = "ADDON ACTIVÉ",
    BETTERSTEALTHTEXT_ADDON_ENABLED_TOOLTIP = "ON - activé, OFF - désactivé",
    BETTERSTEALTHTEXT_ACCOUNTWIDE = "Mêmes paramètres pour tous les personnages",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_TOOLTIP = "ON - Chaque personnage a les mêmes paramètres, OFF - Paramètres séparés pour chaque personnage",
    BETTERSTEALTHTEXT_ACCOUNTWIDE_WARNING = "Cette option rechargera l'interface utilisateur",
    BETTERSTEALTHTEXT_DISPLAY_OPTIONS = "Options d'affichage",
    BETTERSTEALTHTEXT_SCALE = "Définir l'échelle du texte de furtivité (%)",
    BETTERSTEALTHTEXT_SCALE_TOOLTIP = "L'échelle d'icône et de texte va de 50% à 400% de l'échelle originale",
    BETTERSTEALTHTEXT_STEALTH_COLORS_OPTIONS = "Options de couleurs de furtivité",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE = "Même couleur pour les états de furtivité CACHÉ et INVISIBLE",
    BETTERSTEALTHTEXT_SAME_HIDDEN_INVISIBLE_TOOLTIP = "ON - activé (la couleur CACHÉ s'applique à INVISIBLE), OFF - désactivé (paramètres séparés pour CACHÉ et INVISIBLE)",
    BETTERSTEALTHTEXT_HIDDEN_COLOR = "Choisir la couleur pour l'état CACHÉ",
    BETTERSTEALTHTEXT_HIDDEN_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité CACHÉ",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR = "Choisir la couleur pour l'état INVISIBLE",
    BETTERSTEALTHTEXT_INVISIBLE_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité INVISIBLE",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE = "Même couleur pour les états de furtivité CACHÉ et INVISIBLE presque détectés",
    BETTERSTEALTHTEXT_SAME_ALMOST_HIDDEN_INVISIBLE_TOOLTIP = "ON - activé (la couleur CACHÉ s'applique à INVISIBLE) pour les états presque détectés, OFF - désactivé (paramètres séparés pour CACHÉ et INVISIBLE) pour les états presque détectés",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR = "Choisir la couleur pour l'état CACHÉ PRESQUE DÉTECTÉ",
    BETTERSTEALTHTEXT_HIDDEN_ALMOST_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité CACHÉ PRESQUE DÉTECTÉ",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR = "Choisir la couleur pour l'état INVISIBLE PRESQUE DÉTECTÉ",
    BETTERSTEALTHTEXT_INVISIBLE_ALMOST_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité INVISIBLE PRESQUE DÉTECTÉ",
    BETTERSTEALTHTEXT_ENABLE_HIDING = "Activer le texte 'DISSIMULÉ'",
    BETTERSTEALTHTEXT_ENABLE_HIDING_TOOLTIP = "ON - activé, OFF - désactivé",
    BETTERSTEALTHTEXT_HIDING_COLOR = "Choisir la couleur pour l'état DISSIMULÉ",
    BETTERSTEALTHTEXT_HIDING_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité DISSIMULÉ",
    BETTERSTEALTHTEXT_DETECTED_COLOR = "Choisir la couleur pour l'état DÉTECTÉ",
    BETTERSTEALTHTEXT_DETECTED_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité DÉTECTÉ",
    BETTERSTEALTHTEXT_REVEALED_COLOR = "Choisir la couleur pour l'état RÉVÉLÉ",
    BETTERSTEALTHTEXT_REVEALED_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de furtivité RÉVÉLÉ",
    BETTERSTEALTHTEXT_DISGUISE_COLORS_OPTIONS = "Options de couleurs de déguisement",
    BETTERSTEALTHTEXT_DISGUISED_COLOR = "Choisir la couleur pour l'état DÉGUISÉ",
    BETTERSTEALTHTEXT_DISGUISED_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de déguisement DÉGUISÉ",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR = "Choisir la couleur pour l'état SUSPECT",
    BETTERSTEALTHTEXT_SUSPICIOUS_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de déguisement SUSPECT",
    BETTERSTEALTHTEXT_DANGER_COLOR = "Choisir la couleur pour l'état DANGER",
    BETTERSTEALTHTEXT_DANGER_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de déguisement DANGER",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR = "Choisir la couleur pour l'état DÉCOUVERT",
    BETTERSTEALTHTEXT_DISCOVERED_COLOR_TOOLTIP = "Choisir la couleur du texte pour l'état de déguisement DÉCOUVERT"
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
