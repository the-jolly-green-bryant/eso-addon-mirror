--Updated by lexo1000 - 2022-05-25
local util = AdvancedFilters.util
local enStrings = AdvancedFilters.ENstrings
local afPrefix = "|cFF0000[AdvancedFilters%s]|r"
local afPrefixNormal    = enStrings.AFPREFIXNORMAL
local afPrefixError     = string.format(enStrings.AFPREFIX, " ERREUR")

local strings = {
    --MISCELLANEOUS
    Fence = "Volé",

    --DROPDOWN CONTEXT MENU
    ResetToAll           = "Réinitialiser les filtres",
    InvertDropdownFilter = "Inverser le filtre : %s",

    --WEAPON
    TwoHandAxe = util.Localize(SI_WEAPONTYPE1).." à deux mains",
    TwoHandSword = util.Localize(SI_WEAPONTYPE3).." à deux mains",
    TwoHandHammer = util.Localize(SI_WEAPONTYPE2).." à deux mains",

    --LAM settings menu
    lamDescription = "",
    lamHideItemCount = "Masquer le compteur d'objet",
    lamHideItemCountTT = "Masque le nombre d'objets présents dans la sous-catégorie affiché entre parenthèses en bas de l'inventaire à côté du nombre d'objet total.",
    lamHideItemCountColor = "Couleur du compteur d'objet",
    lamHideItemCountColorTT = "Détermine la couleur du compteur d'objet affiché en bas de l'inventaire.",
    lamHideSubFilterLabel = "Masquer le nom des sous-catégories",
    lamHideSubFilterLabelTT = "Masque le nom des sous-catégories affiché en haut à gauche de la fenêtre d'inventaire.",
    lamGrayOutSubFiltersWithNoItems = "Désactiver les sous-catégories sans objets",
    lamGrayOutSubFiltersWithNoItemsTT = "Grise le bouton des sous-catégories qui ne contiennent aucun objet.",
    lamShowIconsInFilterDropdowns = "Afficher les icônes",
    lamShowIconsInFilterDropdownsTT = "Affiche une icône à côté du nom des filtres dans le menu déroulant des filtres.",
    lamRememberFilterDropdownsLastSelection = "Enregistrer la dernière sélection du menu des filtres",
    lamRememberFilterDropdownsLastSelectionTT = "Mémorise le dernier filtre utilisé dans le menu déroulant des filtres et réapplique ce filtre en revenant dans la sous-catégorie d'objet.\n\nL'enregistrement est réinitialisé à la déconnexion ou après un rechargement de l'interface utilisateur.",
    lamShowDropdownSelectedReminderAnimation = "Mettre en évidence le dernier filtre enregistré",
    lamShowDropdownSelectedReminderAnimationTT = "Fait briller le menu déroulant sur le dernier filtre enregistré lorsque un filtre autre que |cFFFFFFTout|r est sélectionné.",
    lamShowDropdownLastSelectedEntries = "Afficher l'historique de sélection de le menu déroulant des filtres",
    lamShowDropdownLastSelectedEntriesTT = "Cliquez avec le bouton droit sur le menu déroulant du filtre pour afficher une liste des 10 dernières entrées du menu déroulant sélectionné sous les entrées du menu contextuel standard. Cliquez sur une entrée d'historique pour la sélectionner à nouveau (si le menu déroulant de la barre de sous-filtre actuelle fournit cette entrée car l'historique est créé entre les barres de sous-filtre) !",
    lamHideCharBoundAtBankDeposit = "Masquer les objets liés au personnage",
    lamHideCharBoundAtBankDepositTT = "Masque les objets liés au personnage dans l'onglet |cFFFFFFDépôt|r de la banque.",
    lamShowFilterDropdownMenuOnRightMouse   = "Afficher le menu des filtres avec un clic-droit",
    lamShowFilterDropdownMenuOnRightMouseTT = "Affiche le menu déroulant des filtres en faisant un clic-droit sur le bouton de la sous-catégorie.\n\n|t100.000000%:100.000000%:EsoUI/Art/Miscellaneous/icon_RMB.dds|t : Affiche le menu déroulant des filtres.\nSHIFT+|t100.000000%:100.000000%:EsoUI/Art/Miscellaneous/icon_RMB.dds|t : Affiche les options du menu déroulant des filtres.",
    lamHeaderVisual = "Compteur d'objet",
    lamHeaderFilterCategory = "Nom des sous-catégories",
    lamHeaderSubfilter = "Bouton des sous-catégories",
    lamHeaderDropdownFilterbox = "Menu déroulant des filtres",
    lamDebugOutput = "Activer le déboguage",
    lamDebugOutputTT = "Affiche les messages de débogage dans la fenêtre de discussion.",
    lamDebugSpamOutput = "Activer le déboguage avancé",
    lamDebugSpamOutputTT = "Attention : cela va afficher beaucoup de messages d'AdvancedFilters dans la fenêtre de discussion.",
    lamDebugSpamExcludeRefreshSubfilterBar = "Exclure \'RefreshSubfilterBar\'",
    lamDebugSpamExcludeDropdownBoxFilters = "Exclure les filtres \'Dropdownbox\'",

    --Error messages
    errorCheckChatPlease    = afPrefixError .. " Veuillez lire le message d'erreur dans la fenêtre de discussion !",
    errorLibrayMissing      = afPrefixError .. " La librairie \'%s\' requise n'est pas chargée. Cette extension ne fonctionnera pas correctement !",
    errorWhatToDo1          = "!> Veuillez répondre aux 4 questions suivantes et envoyer les réponses (et si elles sont données : les variables affichées dans les lignes, en commençant par ->, après les questions) dans les commentaires de l'extension AdvancedFilters à l'adresse @www.esoui.com:\nhttps://bit.ly/2lSbb2A",
    errorWhatToDo2          = "1) Qu'avez-vous fait ?\n2)Où l'avez-vous fait ?\n3)Avez-vous vérifié si l'erreur se produit uniquement avec l'extension AdvancedFilters et si les librairies requises sont activées ?\n4)Si l'erreur se produit avec d'autres extensions actives : Quels autres extensions utilisiez-vous lorsque l'erreur s'est produite, et êtes-vous en mesure de dire laquelle de celle-ci est à l'origine de l'erreur ?",

    --Errors because of other addons
    errorOtherAddonsMulticraft = afPrefixError .. "Une autre extension pose problème\'" .. afPrefixNormal .. "\' -> VEUILLEZ DÉSACTIVER CETTE EXTENSION : \'MultiCraft\'!",
    errorOtherAddonsMulticraftLong = "VEUILLEZ DÉSACTIVER CETTE EXTENSION\'MultiCraft\'! " .. afPrefixNormal .. " ne peut pas fonctionner si cette extension est activée. \'Multicraft\' a été remplacé par la propre interface utilisateur multi-artisanat du jeu de base, vous n'en avez donc plus besoin !"
}

--QuickSlots
strings.BodyMarking = "Corps"
strings.JewelryPiercing  = strings.Jewelry
strings.HeadMarking = strings.Head
strings.Facial = "Facial"
strings.Hair = "Cheveux"
strings.Hat = "Chapeaux"
strings.Skin = "Peaux"
strings.Polymorph = "Polymorphe"
strings.Personality = "Personnalités"

setmetatable(strings, {__index = enStrings})
AdvancedFilters.strings = strings
