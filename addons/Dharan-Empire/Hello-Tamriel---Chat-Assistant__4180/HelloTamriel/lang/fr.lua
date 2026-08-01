local strings = {
    HELLOTAMRIEL_HELLO = "Bonjour, {name} ! Bienvenue sur The Elder Scrolls Online.",
    HELLOTAMRIEL_ZONE_WELCOME = "Bienvenue à {zone}, {name} !",
    HELLOTAMRIEL_GUILD_GREETING_EXAMPLE = "Bonsoir membres de la guilde, comment allez-vous aujourd'hui ?",
    HELLOTAMRIEL_RECRUITER_EXAMPLE = "Vous cherchez une guilde ? Chuchotez-moi pour une invitation !",
    HELLOTAMRIEL_CUSTOM1_EXAMPLE = "Bonjour de la part du message personnalisé 1 !",
    HELLOTAMRIEL_CUSTOM2_EXAMPLE = "Bonjour de la part du message personnalisé 2 !",
    HELLOTAMRIEL_CUSTOM3_EXAMPLE = "Bonjour de la part du message personnalisé 3 !",

    HELLOTAMRIEL_USE_CHARACTER = "Utiliser les paramètres du personnage",
    HELLOTAMRIEL_USE_CHARACTER_TIP = "Activez pour utiliser les paramètres uniquement pour ce personnage. Désactivez pour utiliser les paramètres du compte.",
    HELLOTAMRIEL_ENABLE_GREETING = "Activer le message d'accueil",
    HELLOTAMRIEL_ENABLE_GREETING_TIP = "Active ou désactive le message de bienvenue à la connexion.",
    HELLOTAMRIEL_WELCOME_MSG = "Message de bienvenue",
    HELLOTAMRIEL_WELCOME_MSG_TIP = "Définissez votre message de bienvenue personnalisé. Utilisez {name} pour le nom de votre personnage et {zone} pour la zone actuelle.",
    HELLOTAMRIEL_ENABLE_ZONE_WELCOME = "Activer le message de zone",
    HELLOTAMRIEL_ENABLE_ZONE_WELCOME_TIP = "Active ou désactive le message de bienvenue lors de l'entrée dans une nouvelle zone.",
    HELLOTAMRIEL_ZONE_WELCOME_MSG = "Message de bienvenue de zone",
    HELLOTAMRIEL_ZONE_WELCOME_MSG_TIP = "Définissez votre message personnalisé de bienvenue de zone. Utilisez {name} pour le nom de votre personnage et {zone} pour la nouvelle zone.",

    HELLOTAMRIEL_AUTO_FILL_GREETING = "Message de guilde automatique",
    HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING = "Activer le message automatique de guilde",
    HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING_TIP = "Si activé, remplit automatiquement la boîte de chat avec un message configurable à la guilde sélectionnée lors de la connexion, mais seulement si suffisamment de temps s'est écoulé depuis la dernière utilisation.",
    HELLOTAMRIEL_AUTO_FILL_GREETING_MSG = "Message automatique de guilde",
    HELLOTAMRIEL_AUTO_FILL_GREETING_MSG_TIP = "Message à remplir automatiquement dans le chat. Exemple : Bonsoir membres de la guilde, comment allez-vous aujourd'hui ?",
    HELLOTAMRIEL_AUTO_FILL_MINUTES = "Minutes minimales entre messages automatiques",
    HELLOTAMRIEL_AUTO_FILL_MINUTES_TIP = "Intervalle minimal en minutes avant que le message automatique s'affiche à nouveau (défaut : 1440 = 24 heures).",
    HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL = "Sélectionner la guilde pour le message automatique",
    HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL_TIP = "Sélectionnez la guilde à laquelle vous souhaitez envoyer le message automatique. Cela ne s'appliquera qu'à la première guilde sélectionnée lors de la connexion ou du rechargement de l'UI. Utilisez la flèche vers le haut dans le chat pour répéter rapidement le message à d'autres guildes.",

    HELLOTAMRIEL_GUILD_SLOT = "Emplacement de guilde",

    HELLOTAMRIEL_GUILD_RECRUITER = "Recruteur de guilde",
    HELLOTAMRIEL_ENABLE_RECRUITER = "Activer le mode recruteur de guilde",
    HELLOTAMRIEL_ENABLE_RECRUITER_TIP = "Si activé (ou via la commande /guildrecruiter), votre message de recrutement sera automatiquement rempli dans le chat de zone à chaque changement de zone.",
    HELLOTAMRIEL_RECRUITER_MSG = "Message de recrutement",
    HELLOTAMRIEL_RECRUITER_MSG_TIP = "Le message à remplir automatiquement lors de l'entrée dans une zone. Exemple : Vous cherchez une guilde ? Chuchotez-moi pour une invitation !",
    HELLOTAMRIEL_RECRUITER_ENABLED = "Mode recruteur de guilde ACTIVÉ. Votre message de recrutement sera automatiquement rempli à chaque changement de zone.",
    HELLOTAMRIEL_RECRUITER_DISABLED = "Mode recruteur de guilde DÉSACTIVÉ.",

    HELLOTAMRIEL_CUSTOM_GUILD_MESSAGES = "Messages personnalisés de guilde",
    HELLOTAMRIEL_SELECT_GUILD_CUSTOM = "Sélectionner la guilde pour les messages personnalisés",
    HELLOTAMRIEL_SELECT_GUILD_CUSTOM_TIP = "Seuls les membres de cette guilde déclencheront les messages personnalisés lors d'un chuchotement depuis l'annuaire de la guilde.",

    HELLOTAMRIEL_ENABLE_CUSTOM1 = "Activer le message personnalisé 1",
    HELLOTAMRIEL_ENABLE_CUSTOM1_TIP = "Active pour remplir automatiquement votre message de chuchotement avec ce texte lors d'un chuchotement à un membre de guilde. Basculez avec /guildcustom1.",
    HELLOTAMRIEL_CUSTOM1_MSG = "Message personnalisé 1",
    HELLOTAMRIEL_CUSTOM1_MSG_TIP = "Le message à remplir automatiquement (1).",
    HELLOTAMRIEL_CUSTOM1_STATUS = "Message personnalisé 1 %s",

    HELLOTAMRIEL_ENABLE_CUSTOM2 = "Activer le message personnalisé 2",
    HELLOTAMRIEL_ENABLE_CUSTOM2_TIP = "Active pour remplir automatiquement votre message de chuchotement avec ce texte lors d'un chuchotement à un membre de guilde. Basculez avec /guildcustom2.",
    HELLOTAMRIEL_CUSTOM2_MSG = "Message personnalisé 2",
    HELLOTAMRIEL_CUSTOM2_MSG_TIP = "Le message à remplir automatiquement (2).",
    HELLOTAMRIEL_CUSTOM2_STATUS = "Message personnalisé 2 %s",

    HELLOTAMRIEL_ENABLE_CUSTOM3 = "Activer le message personnalisé 3",
    HELLOTAMRIEL_ENABLE_CUSTOM3_TIP = "Active pour remplir automatiquement votre message de chuchotement avec ce texte lors d'un chuchotement à un membre de guilde. Basculez avec /guildcustom3.",
    HELLOTAMRIEL_CUSTOM3_MSG = "Message personnalisé 3",
    HELLOTAMRIEL_CUSTOM3_MSG_TIP = "Le message à remplir automatiquement (3).",
    HELLOTAMRIEL_CUSTOM3_STATUS = "Message personnalisé 3 %s",

    HELLOTAMRIEL_ENABLED = "ACTIVÉ",
    HELLOTAMRIEL_DISABLED = "DÉSACTIVÉ",
}
for id, value in pairs(strings) do
    SafeAddString(_G[id], value, 2)
end