local strings = {
	DUR_HEADING1 = "Ausgestattet Artikel",
	DUR_HEADING2 = "Waffe Gebühren",
	DUR_HEADING3 = "Andere",
	DUR_SHOW_DURABILITY = "Zeigen Prozent Haltbarkeit",
	DUR_SHOW_DURABILITY_TT = "Lassen Sie sich die Prozent Haltbarkeit auf der rechten unteren Ecke des Elements",
	DUR_SHOW_ALWAYS = "Zeigen immer Prozent",
	DUR_SHOW_ALWAYS_TT = "Lassen Sie sich die Prozent Haltbarkeit, egal was die Haltbarkeit",
	DUR_SHOW_CHARGE_ALWAYS_TT = "Zeigen die prozentuale Gebühren, egal was die Gebühren",
	DUR_SHOW_HIGHLIGHT = "Highlight anzeigen",
	DUR_SHOW_HIGHLIGHT_TT = "Lassen Sie sich die farbige Hervorhebung, wenn das Einzelteil, die Haltbarkeit Schwelle erreicht",
	DUR_COLOUR = "Hervorhebungsfarbe",
	DUR_COLOUR_TT = "Farbe der Haltbarkeit Warn Highlight",
	DUR_THRESHOLD = "Schwelle",
	DUR_THRESHOLD_TT = "Der Prozentsatz, wenn Sie die Haltbarkeit Warnung angezeigt werden soll",
	DUR_REPAIR = "Reparaturaufforderung beim Besuch eines Anbieters",
	DUR_REPAIR_PER = "Prompt Prozentsatz reparieren",
	DUR_REPAIR_PER_TT = "Nur zur Reparatur auffordern, wenn sich das schlechteste Stück der Ausrüstung auf diesem Niveau oder darunter befindet",
}

if GetString(DUR_HEADING1):len() == 0 then
	for key,value in pairs(strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end