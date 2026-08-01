local strings = {
	AOCH_LANG = "en",
	
	AOCH_InitMSG			=		"[AOCH] Thanks for using Asquart's Ossein Cage Helper. Please send any issues on discord to asquart",
	AOCH_OsiMSG			=		"Please install |cff0000OdySupportIcons|r's latest version (optional dependency) to see all the addon features, including markers.",

	AOCH_Tri1			=		"A Trifecta! Impressive!",
	AOCH_Tri2			=		"Now how about...",
	AOCH_Tri3			=		"... touch grass ?",

	AOCH_CarrionShield	=		"Carrion Shield", -- .lang  A749908 
	AOCH_SpectralRevenant	=	"Osteon Spectral Revenant", -- .lang A117765 
	AOCH_Abductor		    =	"Dreadful Abductor", -- .lang  A117260

	AOCH_GednaRelvel		    =	"Red Witch Gedna Relvel", -- .lang A117896
	AOCH_TorturedRanyu		=	"Tortured Ranyu", -- .lang A117738
	AOCH_BloodDrkinerThisa	=	"Blood Drinker Thisa", -- .lang A117733

	AOCH_ShaperOfFlesh	=		"Shaper of Flesh", -- .lang A117215
	AOCH_Fleshspawn		=		"Fleshspawn", -- .lang A118330
	AOCH_Channeler		=		"Channeler", -- .lang A117220
	AOCH_Harvester		=		"Harvester", -- .lang A117354
	AOCH_Daedroth		=		"Daedroth", -- .lang A117348

	AOCH_Jynorah			=		"Jynorah", -- .lang A117683
	AOCH_Skorknif		=		"Skorkhif", -- .lang A117684
	AOCH_Valneer			=		"Blazeforged Valneer", -- .lang A117108
	AOCH_Myrinax			=		"Sparkstorm Myrinax", -- .lang A117107

	AOCH_Kazpian			=		"Overfiend Kazpian", -- .lang A117085
	AOCH_AgonizerBomb	=		"Agonizer Bomb", -- .lang A118272
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end