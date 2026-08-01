-------------------------------------------------
-- German localization for LRSA
-------------------------------------------------

local strings = {
    LRSA_LEFT_STR = "LINKS",
	LRSA_RIGHT_STR = "RECHTS",
	LRSA_CHECKBOX1_NAME = "Untertitel anzeigen",
	LRSA_CHECKBOX1_TOOLTIP = "Beschriftungen für die linke und rechte Seite anzeigen",
	LRSA_SLIDER1_NAME = "Schriftgröße",
	LRSA_SLIDER1_TOOLTIP = "Geben Sie die Schriftgröße für Etiketten an",
	LRSA_COLORPICKER1_NAME = "Schriftfarbe",
    LRSA_COLORPICKER1_TOOLTIP = "Schriftfarbe auswählen",
	LRSA_SLIDER2_NAME = "Horizontaler Abstand",
	LRSA_SLIDER2_TOOLTIP = "Geben Sie die horizontale Anzeigekoordinate an",
    LRSA_SLIDER3_NAME = "Vertikale Abstand",
	LRSA_SLIDER3_TOOLTIP = "Geben Sie die vertikale Anzeigekoordinate an"
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end