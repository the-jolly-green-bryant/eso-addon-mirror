local OCH = OCH or {}
local strings = {
	OCH_LANG          = "jp",

	OCH_InitMSG       =
	"|cBFBC99[|r|c02fcffOCH|r|cBFBC99]:|r|cb8dbdd Thanks for using Ossein Cage Helper. Please send issues on discord to|r wondernuts (日本語化済み)",

	OCH_ShaperOfFlesh = "肉の加工者",
	OCH_Jynorah       = "ジノラー",
	OCH_Kazpian       = "オーバーフィーンド・カズピアン",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end

OCH.data.jynorahName = string.lower(GetString(OCH_Jynorah))
OCH.data.shaperOfFleshName = string.lower(GetString(OCH_ShaperOfFlesh))
OCH.data.kazpianName = string.lower(GetString(OCH_Kazpian))
