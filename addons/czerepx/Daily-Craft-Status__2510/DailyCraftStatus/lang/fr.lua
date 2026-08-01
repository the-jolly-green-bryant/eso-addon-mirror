-- French localization

local _addon = _G["DailyCraftStatus"]

-- these strings need to match game strings 
_addon.langQuestInfo = 
{
	["deliver"] = "Livrez",
	["craft"] = { "Preparez", "Fabriq" },
	["material"] = { "matériaux" },
	["questnames"] = {
		--quest name unique substring followed by status character (or any string actually) 
		{"forge","F"},
		{"taille","T"},
		{"travail du bois","B"},
		{"joaill","J"},
		{"alchim","A"},
		{"enchan","E"},
		{"cuisin","C"}
	}	
}	

-- addon strings for translation
_addon.translation = 
{
	["Lock"] = "Bloquer",
	["Save"] = "Sauvegarder",
	["Unlock"] = "Libérer",
}	
