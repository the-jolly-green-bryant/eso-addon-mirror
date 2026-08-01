local localizationStrings = {
    VOLETTE_YES = "Oui",
    VOLETTE_NO = "Non",
    
    VOLETTE_REQUIRES_RELOADUI = "Nécessite de recharger l'interface.",
    VOLETTE_RELOADUI_DIALOG_TITLE = "Recharger l'interface",
    VOLETTE_RELOADUI_DIALOG_DESCRIPTION = "Ce changement sera pris au compte la prochaine fois que l'interface sera rechargée. Souhaitez-vous le faire maintenant ?",

    VOLETTE_CONFIRM_DIALOG_TITLE = "Confirmation",
    VOLETTE_CONFIRM_DIALOG_DESCRIPTION = "Confirmez-vous l'action ?",

    VOLETTE_HQ_OWNER_CRAFT = "Propriétaire du QG d'artisanat",
    VOLETTE_HQ_OWNER_PARSE = "Propriétaire du QG d'entraînement",
    VOLETTE_HQ_OWNER_MISSING = "Vous devez choisir le propriétaire du QG dans les paramètres.",

    VOLETTE_CONTACTS_ENABLE = "Activer le menu de contacts",
    VOLETTE_CONTACTS_ENABLE_TOOLTIP = "Activer pour avoir un menu de contacts supplémentaire à côté de la liste d'amis",
    VOLETTE_CONTACTS_ADDED = "<<1>> a été ajouté aux contacts.",
    VOLETTE_CONTACTS_REMOVED = "<<1>> a été retiré des contacts.",
    VOLETTE_CONTACTS_EXISTS = "<<1>> est déjà dans les contacts.",
    VOLETTE_CONTACTS_WAS_INVITED = "<<1>> a été invité.",
    VOLETTE_CONTACTS_WHISPER_BUTTON_TOOLTIP = "Chuchoter",
    VOLETTE_CONTACTS_INVITE_BUTTON_TOOLTIP = "Inviter",
    VOLETTE_CONTACTS_REMOVE_BUTTON_TOOLTIP = "Retirer de la liste",
    VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP = "Épingler",
    VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP = "Désépingler",

    VOLETTE_TRAVEL_WAYSHRINE_CHOICE = "Sélectionner une maison proche d'un oratoire",
    VOLETTE_TRAVEL_WAYSHRINE_CHOICE_TOOLTIP = "Tente une téléportation devant cette maison lorsque la commande |cffcc00/v-wayshrine|r est utilisée. Si vous ne possédez pas la maison, une autre sera utilisée.",
    VOLETTE_TRAVEL_AUTO = "Auto",
    VOLETTE_TRAVEL_WAYSHRINE_RECOMMENDATION = "Vous devez posséder une des maisons compatibles. \"<<1>>\" est recommandée.",
    VOLETTE_TRAVEL_WAYSHRINE_PORTING = "En déplacement vers \"<<1>>\".",
    VOLETTE_TRAVEL_SEARCHING_ANOTHER_WAYSHRINE = "Vous devez posséder \"<<1>>\". Tentative de trouver une autre maison...",

    VOLETTE_SAVINGS_SUBMENU_TITLE = "Épargne",
    VOLETTE_SAVINGS_SUBMENU_DESCRIPTION = "Ne laissez pas votre fortune sur vos rerolls ! Déposez automatiquement vos devises en banque lorsqu'elles commencent à s'accumuler.",
    VOLETTE_SAVINGS_ENABLE = "|c66a3ffActiver|r",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT = "Montant minimum",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT = "Montant maximum",
    VOLETTE_SAVINGS_MINIMUM_AMOUNT_TOOLTIP = "Vos personnages garderont toujours au moins ce montant dans leurs sacs.",
    VOLETTE_SAVINGS_MAXIMUM_AMOUNT_TOOLTIP = "Vos personnages n'auront jamais plus que ce montant dans leurs sacs.",
    VOLETTE_SAVINGS_ENABLE_FOR_DESCRIPTION = "Activer pour les personnages suivants :",
    VOLETTE_SAVINGS_DEPOSIT = "Dépôt : <<1>>",
    VOLETTE_SAVINGS_WITHDRAWAL = "Retrait : <<1>>",
    VOLETTE_SAVINGS_NOT_ENOUGH_CURRENCIES = "Impossible de trouver <<1>> dans la banque.",

    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HOME = "Téléportation dans la maison principale",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_CRAFT = "Téléportation au HQ d'artisanat",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_HQ_PARSE = "Téléportation au HQ d'entraînement",
    SI_BINDING_NAME_VOLETTE_KEYBIND_PORT_TO_WAYSHRINE = "Téléportation vers un oratoire",

}

for stringId, stringValue in pairs(localizationStrings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
