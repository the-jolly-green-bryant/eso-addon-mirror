
local strings = {
	DEFAULT_TOPLEFT = "Zonennamen & Uhrzeit oben links",
	PERFECT_PIXEL = "Nützlich für PerfectPixel-Benutzer ;-)",
	LESS_FLASHY = "Karte verblassen",
	LESS_FLASHY_TOOLTIP = "Blenden Sie die Karte in der Nacht leicht aus, um Ihre Augen zu erfreuen.\n87 ist in Ordnung\n100 ist die Standardeinstellung",
	DESATURATION = "Karte Entsättigung",
	DESATURATION_TOOLTIP = "Farben auf der Karte entsättigen.\n20 ist in Ordnung\n0 ist die Standardeinstellung",
	SECONDS = "Erzwinge das 24h-Format mit Sekunden auf der Kartenuhr",
	SECONDS_TOOLTIP = ":-)",
	TO = "Nach ",
	WAYSHRINE = "Wegschrein",
	WAYSHRINE_ONLY = "Kann nur via Wegschrein erreicht werden.",
	ABBR = "Abgekürzt Festungen",
	ABBR_TOOLTIP = "Zeigt die abgekürzten internationalen Namen der Festungen in Cyrodiil an.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
