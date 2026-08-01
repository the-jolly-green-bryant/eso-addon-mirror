local _addon = _G["DailyCraftStatus"]

-- the strings need to match game strings 
_addon.langQuestInfo = 
{
	["deliver"] = "Deliver", 
	["craft"] = { "Craft" },
	["material"] = { "material" },
	["questnames"] = {
		--quest name unique substring followed by status character (or any string actually) 
		{"blacksm","B"},
		{"clothi","C"},
		{"woodwo","W"},
		{"jewelr","J"},
		{"alchem","A"},
		{"enchan","E"},
		{"provis","P"}
	}	
}	

-- addon strings for translation

_addon.translation = _addon.default_translation