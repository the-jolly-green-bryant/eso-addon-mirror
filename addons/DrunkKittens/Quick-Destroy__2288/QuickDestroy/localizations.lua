QuickDestroy = QuickDestroy or {}
QuickDestroy.localizations = {
	en = {
		DestroyBindingName = "Destroy current item",
		DestroyLabel = "Destroy"
	},
	de = {
		DestroyBindingName = "Aktuellen Gegenstand zerstören",
		DestroyLabel = "Zerstören"
	},
	fr = {
		DestroyBindingName = "Détruire",
		DestroyLabel = "Détruire"
	},
	ru = {
		DestroyBindingName = "Уничтожить текущий предмет",
		DestroyLabel = "Уничтожить"
	},
}

QuickDestroy.language = GetCVar("language.2") or "en"
QuickDestroy.tr = function(str)
	return QuickDestroy.localizations[QuickDestroy.language][str]
end
