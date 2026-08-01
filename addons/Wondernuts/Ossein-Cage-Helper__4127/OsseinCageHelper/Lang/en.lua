local strings = {
	OCH_LANG = "en",
	
	OCH_InitMSG			=		"|cBFBC99[|r|c02fcffOCH|r|cBFBC99]:|r|cb8dbdd Thanks for using Ossein Cage Helper. Please send issues on discord to|r wondernuts",

	OCH_ShaperOfFlesh			=		"Shaper of Flesh",
	OCH_Jynorah		=		"Jynorah",
	OCH_Kazpian		    =		"Overfiend Kazpian",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end