------------------------------------------------
-- German localization for IsJustaEventTicketSaver 
------------------------------------------------
-- Courtesy of Baertram
local strings = {
	SI_IJA_EVENTTICKETSAVER_NOSPACE = "Du verlierst Event Tickets wenn du diese Quest abschließt ohne vorher Tickets zu verbrauchen.",
	SI_IJA_EVENTTICKETSAVER_ALERT = "Zu viele Tickets",
	SI_IJA_EVENTTICKETSAVER_OPTIONTEXT = "[<<1>>/<<2>> Tickets] <<3>>",

	SI_IJA_EVENTTICKETSAVER_TARGET_TIMER = "Tickets Cooldown <<1>>",
	SI_IJA_EVENTTICKETSAVER_TICKETS_AVAILABLE = "Tickets verfügbar",
	
	SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE = "Auto-Vervollständigen",
	SI_IJA_EVENTTICKETSAVER_AUTOCOMPLETE_TOOLTIP = "Vervollständigt automatisch Quests deren Belohnung Event Tickets sind und wenn das Abgeben der Quest dich nicht auf mehr als das Maximum (12) an Tickets bringt.",

	SI_IJA_EVENTTICKETSAVER_AUTOCLOSE = "Hilf mir meine Tickets zu sichern.",
	SI_IJA_EVENTTICKETSAVER_AUTOCLOSE_TOOLTIP = "Automatisches Beenden der Quest-NPC Interaktion (beim Abgeben) wenn du zu viele Event Tickets besitzst.\nVerhindert das Essen des Jubiläums Kuchens wenn du zu viele Event Tickets besitzst.",
	
	SI_IJA_EVENTTICKETSAVER_SHOWTIME = "Ticket Anzeige - Zeit",
    SI_IJA_EVENTTICKETSAVER_SHOWTIME_TOOLTIP = "Zeige die aktuellen Tickets auf dem HUD für diese Anzahl von Sekunden an.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
