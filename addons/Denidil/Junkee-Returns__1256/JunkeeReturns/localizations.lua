Junkee = Junkee or {}
Junkee.localizations = {
	en = {
		JunkBindingName = "Junk current item",
		DeleteBindingName = "Destroy current item",
		JunkLabel = "Junk",
		UnjunkLabel = "Unjunk",
		DeleteLabel = "Destroy"
	},
	de = {
		JunkBindingName = "Aktuellen Gegenstand als Trödel markieren",
		DeleteBindingName = "Aktuellen Gegenstand zerstören",
		JunkLabel = "Als Trödel markieren",
		UnjunkLabel = "Nicht als Trödel markieren",
		DeleteLabel = "Zerstören"
	},
	fr = {
		JunkBindingName = "Mette aux rebuts",
		DeleteBindingName = "Détruire",
		JunkLabel = "Mette aux rebuts",
		UnjunkLabel = "Ne mette pas aux rebuts",
		DeleteLabel = "Détruire"
	}
}

Junkee.language = GetCVar("language.2") or "en"
Junkee.tr = function(str)
	return Junkee.localizations[Junkee.language][str]
end
