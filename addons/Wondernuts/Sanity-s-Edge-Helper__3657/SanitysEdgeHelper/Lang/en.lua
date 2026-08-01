local strings = {
	SEH_LANG = "en",
	
	SEH_InitMSG			=		"|cBFBC99[|r|c02fcffSEH|r|cBFBC99]:|r|cb8dbdd Thanks for using Sanity Edge Helper. Please send issues on discord to|r wondernuts",
	
	SEH_Yaseyla			=		"Exarchanic Yaseyla",
	SEH_Twelvane		=		"Archwizard Twelvane",
	SEH_Chimera			=		"Chimera",
	SEH_Ansuul		    =		"Ansuul the Tormentor",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end