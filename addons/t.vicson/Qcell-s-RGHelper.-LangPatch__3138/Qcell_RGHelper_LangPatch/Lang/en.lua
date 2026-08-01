local strings = {
	SI_QcellRGH_LANG = "en",
	
	SI_QcellRGH_InitMSG					=	"|cBFBC99[|r|ccc0000t|r|cffffff.vicson|r|cBFBC99]:|r |cb8dbddinitialized language patch for|r |ceaa514\"Qcell's Rockgrove Helper\"|r|cb8dbdd!|r",
	
	SI_QcellRGH_OAXILTSO				=	"Oaxiltso",
	SI_QcellRGH_BAHSEI					=	"Bahsei",
	SI_QcellRGH_XALVAKKA				=	"Xalvakka",
	SI_QcellRGH_XALVAKKA_VOLATILE_SHELL	=	"Volatile Shell",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
