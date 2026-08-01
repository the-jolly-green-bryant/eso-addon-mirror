------------------------------------------------
-- French localization for IsJustaEventTicketSaver
------------------------------------------------
-- Courtesy of fzr6n7
local strings = {
    SI_IJA_EVENTTICKETSAVER_NOSPACE = "Vous allez perdre les tickets d'évènement si vous accepter cette quête sans dépenser vos tickets d'abord.",
    SI_IJA_EVENTTICKETSAVER_ALERT = "Trop de tickets",
    SI_IJA_EVENTTICKETSAVER_OPTIONTEXT = "[<<1>>/<<2>> Tickets] <<3>>",
 
    SI_IJA_EVENTTICKETSAVER_TARGET_TIMER = "Tickets dans <<1>>",
    SI_IJA_EVENTTICKETSAVER_TICKETS_AVAILABLE = "Tickets disponibles",
 
    SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE = "Auto-complétion.",
    SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE_TOOLTIP = "Auto-complète les quêtes récompensant avec des tickets d'évènements si le montant des tickets offerts ne fait pas dépasser le total de 12.",
    
    SI_IJA_EVENTTICKETSAVER_AUTOCLOSE = "Aidez moi à ne pas gaspiller les tickets.",
    SI_IJA_EVENTTICKETSAVER_AUTOCLOSE_TOOLTIP = "Abandonne la quête automatiquement si vous avez trop de tickets d'évènement.\nEmpêche l'utilisation du gâteau du Jubilé si vous avez trop de tickets.",
    
    SI_IJA_EVENTTICKETSAVER_SHOWTIME = "Temps d'affichage.",
    SI_IJA_EVENTTICKETSAVER_SHOWTIME_TOOLTIP = "Temps en secondes pour l'affichage du nombre de tickets sur l'interface.",
}
 
for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end