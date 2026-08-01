------------------------------------------------
-- German localization
------------------------------------------------

local strings = {
	-- translation by Baertram
	SI_IJA_DIWM_Title				= "|cFF00FFIsJusta|r |cffffffVerhindere Aktionen beim Bewegen|r",

	SI_IJA_DIWM_DISABLEINTERACT		= "Interaktion mit Gefährten",
	SI_IJA_DIWM_DISABLEINTERACT_TIP	= "Deaktiviert die Interaktion mit deinem Gefährten während du dich bewegst.",

	SI_IJA_DIWM_DISABLEMORE			= "Andere Interaktionen",
	SI_IJA_DIWM_DISABLEMORE_TIP		= "Deaktiviert andere Aktionen während du dich bewegst.",
	SI_IJA_DIWM_DISABLEMORE_HEADER	= "Wähle zu deakt. Aktionen aus",
	
	SI_IJA_DIWM_OPTIONAL			= "Optionale Funktionen",
	
	SI_IJA_DIWM_OPTIONAL1			= "Aktivieren Sie die visuelle Darstellung des Absehens",
	SI_IJA_DIWM_OPTIONAL_TIP1		= "Ermöglicht: Das Fadenkreuz wird rot, wenn eine deaktivierte Aktion ausgeführt wird",

	SI_IJA_DIWM_OPTIONAL2			= "In der Hocke deaktivieren",
	SI_IJA_DIWM_OPTIONAL_TIP2		= "Ermöglicht: Deaktiviert das Blockieren von Interaktionen in der Hocke",
	
	SI_IJA_DIWM_OPTIONAL3			= "In Dungeons/Prüfungen deaktivieren",
	SI_IJA_DIWM_OPTIONAL_TIP3		= "Ermöglicht: Deaktiviert das Blockieren von Interaktionen in Dungeons/Prüfungen",
	
	SI_IJA_DIWM_OPTIONAL4			= "In PVP-Zonen deaktivieren",
	SI_IJA_DIWM_OPTIONAL_TIP4		= "Ermöglicht: Deaktiviert das Blockieren von Interaktionen in der PVP-Zone",
	
	SI_IJA_DIWM_OPTIONAL5			= "Interaktionen während der Abklingzeit ausblenden",
	SI_IJA_DIWM_OPTIONAL_TIP5		= "Ermöglicht: wird die Interaktionsaufforderung vollständig ausblenden.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(_G[stringId], 1)
end
