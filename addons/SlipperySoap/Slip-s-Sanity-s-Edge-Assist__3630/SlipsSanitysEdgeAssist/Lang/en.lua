local strings = {
	SSEA_LANG = "en",
	
	SSEA_InitMSG			=		"|cff71f9[SSEA]|r Thanks for using |ceaa514Slip's Sanity's Edge Assist|r. Please send issues through Discord to |ceaa514SlipperySoap|r.",

	
	SSEA_Yaseyla			=		"Exarchanic Yaseyla",
	SSEA_Twelvane			=		"Archwizard Twelvane",
	SSEA_Chimera			=		"Chimera",
	SSEA_Ansuul		    	=		"Ansuul the Tormentor",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end