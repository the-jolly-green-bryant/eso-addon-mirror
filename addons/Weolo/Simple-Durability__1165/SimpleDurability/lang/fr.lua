local strings = {
	DUR_HEADING1 = "Durabilité des armures",
	DUR_HEADING2 = "Charge des armes",
	DUR_HEADING3 = "Divers",
	DUR_SHOW_DURABILITY = "Afficher le pourcentage",
	DUR_SHOW_DURABILITY_TT = "Affiche le pourcentage de dégradation dans le coin inférieur droit de l'objet.",
	DUR_SHOW_ALWAYS = "Toujours afficher le pourcentage",
	DUR_SHOW_ALWAYS_TT = "Affiche le pourcentage de durabilité en permanence.",
	DUR_SHOW_CHARGE_ALWAYS_TT = "Affiche le pourcentage de charge en permanence.",
	DUR_SHOW_HIGHLIGHT = "Afficher en surbrillance",
	DUR_SHOW_HIGHLIGHT_TT = "Affiche les objets en surbrillance lorsqu'ils passent sous le seuil d'alerte.",
	DUR_COLOUR = "Couleur de la surbrillance",
	DUR_COLOUR_TT = "Détermine la couleur de surbrillance des objets qui passent sous le seuil d'alerte.",
	DUR_THRESHOLD = "Seuil d'alerte",
	DUR_THRESHOLD_TT = "Détermine le pourcentage de dégradation en-dessous duquel l'alerte apparaît.",
	DUR_REPAIR = "Demander la réparation automatiquement",
	DUR_REPAIR_PER = "Pourcentage d'invite de réparation",
	DUR_REPAIR_PER_TT = "Seulement invite à réparer lorsque le pire équipement est à ce niveau ou en dessous",
}

if GetString(DUR_HEADING1):len() == 0 then
	for key,value in pairs(strings) do
		SafeAddVersion(key, 1)
		ZO_CreateStringId(key, value)
	end
end