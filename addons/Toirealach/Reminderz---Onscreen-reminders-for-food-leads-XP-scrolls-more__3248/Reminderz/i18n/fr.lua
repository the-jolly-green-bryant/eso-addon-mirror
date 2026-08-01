Reminderz = Reminderz or {}

local localization = {

    LOADED_STR = "%s %s %s",
     WAS_LOADED = "chargé",
     NOT_LOADED = "non chargé",

     DAILY_RESET = "La réinitialisation quotidienne est en %s",
     TURN_IN = "Soumettez des quêtes PvP, terminez vos tâches et écrivez.",
     RESET_IS_NOW = "La réinitialisation quotidienne vient d'avoir lieu",
     NO_FOOD_1 = "Aucun buff alimentaire actif !",
     NO_FOOD_2 = "Mangez quelque chose !",
     FOOD_RUNNING_OUT = "%s sera épuisé dans %s",
     NO_MAYHEM = "%s est terminé. Utilisez à nouveau le parchemin !",
     LOW_BAG_SPACE = "Votre inventaire est presque plein !",
     NO_BAG_SPACE = "Votre inventaire est plein !",
     GEAR_MISSING = "Vérifiez votre armure et vos armes ! Il manque quelque chose !",
     ARMOR_MISSING = "Au moins une pièce d'armure n'est pas équipée !",
     JEWELRY_MISSING = "Au moins un bijou n'est pas équipé !",
     WEAPON_MISSING = "une arme manque !",
     MAIN_HAND = "Votre main principale",
     OFF_HAND = "Votre main secondaire",
     SAUVEGARDE = "Sauvegarde",
     IS_ENDING = "%s se termine par %s",
     GO_FEED = "Vous êtes sur %s. Alimentation !",
     VAMP_TOO_HIGH = "Rappel de vampirisme : niveau actuel > niveau souhaité",
     NO_XP_SCROLL = "Aucun parchemin XP n'est actif !",
     XP_SCROLL_ENDING = "Votre parchemin XP se termine dans %s",
     TELVAR_CAP_REACHED = "Vous transportez %d Pierres de Tel Var. Vous devriez les mettre à la banque !",
     RESERVE_TOO_HIGH = "Numéro de réserve Tel'Var trop élevé. Dépôt automatique de toutes les pierres Tel'Var transportées.",
     TELVAR_DEPOSITED = "%d Pierres de Tel Var déposées automatiquement à la banque.",
     WAR_TORTES_MISSING = "Aucun gâteau de guerre n'est actif !",
     WAR_TORTES_RUNNING_OUT = "Votre gâteau de guerre se termine dans %s",
     ACHIEVEMENT_PROGRESS = "Progression : (%s/%s)",
     ACHIEVEMENT_AWARDED = "Succès TERMINÉ !",
     NO_MUNDUS = "Vous n'avez pas de Pierre Mundus active !",
     
     Warning_RELOADUI = "Attention : L'interface utilisateur se rechargera automatiquement lorsque des modifications seront apportées.",
    
     ACCTWIDE_NAME = "Utiliser les paramètres du compte",
     ACCTWIDE_TOOLTIP = "Lorsque cette fonctionnalité est désactivée, chaque personnage aura ses propres souvenirs.",

     TOUJOURS = "Toujours",
     JAMAIS = "Jamais",
     IN_PVP = "Uniquement en PvP",

     REMIND_INTERVAL_NAME = "Intervalle entre les rappels :",
     REMIND_INTERVAL_TOOLTIP = "Intervalle entre les rappels",
     FIRST_REMINDER_NAME = "Temps restant jusqu'au premier rappel :",
     FIRST_REMINDER_TOOLTIP = "Temps restant jusqu'au premier rappel",
     REMIND_COLOR_NAME = "Couleur du texte de rappel :",
     REMIND_COLOR_TOOLTIP = "La couleur de ces rappels dans le chat et à l'écran",
     REMIND_OFF_IN_HOUSES_NAME = "Aucun rappel pendant votre séjour dans les maisons :",
     REMIND_OFF_IN_HOUSES_TOOLTIP = "Définissez cette option sur ON si vous ne souhaitez pas ce rappel lorsque vous êtes dans l'une de vos maisons.",
     REMIND_ONLY_IN_DUNGEONS_NAME = "Rappels PvE uniquement dans les donjons, raids, etc.",
     REMIND_ONLY_IN_DUNGEONS_TOOLTIP = "Définissez sur ON si vous souhaitez uniquement des rappels PvE dans les donjons, raids, etc.", 

     HEADER_GENERAL = "Général",
     NAME_CHATBOX = "Afficher également les rappels dans la fenêtre de discussion",
     TOOLTIP_CHATBOX = "Affiche les rappels dans l'onglet de discussion principal et sur l'écran.",
     NAME_OFFLINE = "Rappel murmuré en mode hors ligne",
     TOOLTIP_OFFLINE = "Si vous définissez votre statut de joueur sur 'Hors ligne', vous serez rappelé que la personne à qui vous venez de chuchoter ne peut pas vous répondre à moins que vous ne changiez votre statut.",
     NAME_SUPPRESS = "Supprimer le message 'Addon chargé'",
     TOOLTIP_SUPPRESS = "Supprime le message dans la fenêtre de discussion indiquant que l'addon a été chargé avec succès.",
     NAME_DAILY_REWARD = "Collectez automatiquement les récompenses quotidiennes",
     TOOLTIP_DAILY_REWARD = "Récupérez automatiquement la récompense de connexion quotidienne lorsqu'elle est disponible",
     NAME_FREE_BAG_SLOTS = "Rappel lorsque des emplacements d'inventaire sont disponibles sous :",
     TOOLTIP_FREE_BAG_SLOTS = "Nombre d'emplacements d'inventaire libres, en dessous duquel vous serez rappelé de l'espace d'inventaire faible. Zéro signifie que le rappel d'inventaire est désactivé.",
     NAME_MISSING_GEAR = "RAPPEL D'ARMURES OU D'ARMES MANQUANTES",
     TOOLTIP_MISSING_GEAR = "Rappelez-vous quand toutes les armures et armes ne sont pas équipées..",
     NAME_ACHIEVEMENTS = "Afficher les mises à jour des succès",
     TOOLTIP_ACHIEVEMENTS = "Mettez toutes les mises à jour de la progression des succès dans la fenêtre de discussion",
    
     HEADER_FOOD = "Nourriture",
     NAME_REMIND_FOOD = "Activer le rappel :",
     TOOLTIP_REMIND_FOOD = "Rappelez-vous quand la nourriture est épuisée ou quand elle sera épuisée.",
    
     HEADER_LEADS = "Antiquités Pistes",
     NAME_REMIND_LEADS = "Rappeler quand un piste expire dans X jours:",
     TOOLTIP_REMIND_LEADS = "Rappeler quand un piste d'antiquités expirera dans",
     LEADS_EXPIRING_FMT_MULTI = "Plusieurs antiquités pistes",
     LEADS_EXPIRING_FMT_MULTI2 = "expireront dans %s!",
     LEADS_EXPIRING_DAYS = "jours",
     LEADS_EXPIRING_HOURS = "heures",

     HEADER_VAMPIRE = "Niveau de vampirisme",
     NAME_REMIND_VAMPIRE = "Activer le rappel :",
     TOOLTIP_REMIND_VAMPIRE = "Rappelez-vous quand le niveau de vampirisme va changer et après.",
     NAME_REMIND_VAMP_IN_PVP = "Uniquement en PvP :",
     TOOLTIP_REMIND_VAMP_IN_PVP = "Si ON, les rappels n'apparaîtront qu'en PvP. Si OFF, les rappels apparaîtront également en PvE..",
    
     HEADER_XP_SCROLLS = "Parchemins et potions XP",
     NAME_XP_SCROLLS = "Activer le rappel :",
     TOOLTIP_XP_SCROLLS = "Mémorisez quand le parchemin ou la potion XP est épuisé, ou quand il sera épuisé.",
    
     HEADER_TELVAR = "Pierres de Tel'Var",
     NAME_TELVAR = "Souviens-toi de ce nombre de Pierres de Tel Var :",
     TOOLTIP_TELVAR = "N'oubliez pas si vous transportez plus que le nombre spécifié de Pierres de Tel Var.",
     NAME_TELVAR_AUTODEPOSIT = "Déposer automatiquement les pierres TelVar :",
     TOOLTIP_TELVAR_AUTODEPOSIT = "Déposez automatiquement les pierres Tel Var que vous transportez lorsqu'elles dépassent le nombre spécifié et que vous vous rendez chez un banquier",
     NAME_TELVAR_RESERVE_AMT = "Conserver ce nombre de Pierres de Tel Var :",
     TOOLTIP_TELVAR_RESERVE_AMT = "Lorsque vous déposez automatiquement des pierres Tel Var, vous conservez ce numéro avec vous pour les multiplicateurs de bonus.",
    
     HEADER_AP_SCROLLS = "Parchemins AP et tartes de guerre",
     NAME_AP_SCROLLS = "Activer le rappel :",
     TOOLTIP_AP_SCROLLS = "Rappelez-vous quand le gâteau de guerre ou le parchemin AP sont épuisés, ou quand ils seront épuisés.",

}

if Reminderz.Localization and #localization == #Reminderz.Localization then
    ZO_ShallowTableCopy(localization, Reminderz.Localization)
end