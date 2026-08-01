local strings = {
	LCH_LANG = "en",
	
	LCH_InitMSG			=		"|cBFBC99[|r|c02fcffLCH|r|cBFBC99]:|r|cb8dbdd Thanks for using Lucent Citadel Helper. Please send issues on discord to|r wondernuts",
	
	--LCH_RYELAZ		=		"Count Ryelaz",
	--LCH_Zilyesset		=		"Zilyesset",
	LCH_Zilyesset		=		"Count Ryelaz",
	LCH_Orphic			=		"Orphic Shattered Shard",
	LCH_Xoryn		    =		"Xoryn",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end