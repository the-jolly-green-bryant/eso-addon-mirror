local strings = {
	SI_QcDSR_LANG = "en",
	
	SI_QcDSR_InitMSG			=		"|cBFBC99[|r|ccc0000t|r|cffffff.vicson|r|cBFBC99]:|r |cb8dbddinitialized language patch for|r |ceaa514\"Qcell's Dreadsail Reef Helper\"|r|cb8dbdd!|r",
	
	SI_QcDSR_LYLANAR			=		"Lylanar",
	SI_QcDSR_TURLASSIL			=		"Turlassil",
	SI_QcDSR_GUARDIAN			=		"Reef Guardian",
	SI_QcDSR_TALERIA			=		"Tideborn Taleria",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end