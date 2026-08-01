TVC.Default =
{
	-- Main Settings
	UseTVIcon								= true,
	LogColor								=
	{
		Red = 1,
		Green = 0.8,
		Blue = 0
	},
	RestoreTV								= true,
	SkipRestoreTvAfterMins					= 15,
	ShowAvailableCommandsMessageOnStart		= true,
	Separator								= "'",

	-- Start / Stop settings
	StartCounterInImperialCity				= false,

	-- TV log settings
	LogEnabled 								= true,
	LogTVAmount								= 1,
	TvLogFormat								= "TV diff -> current TV",

	-- TV screen message settings
	MainWindowLeft							= nil,
	MainWindowBottom						= nil,
	UseScreenMessage 						= true,
	ScreenMessageTelVarGain					= 1000,
	ScreenMessageScaling					= 1,
	ScreenMessageFadeTime					= 5,
	ScreenMessageColor						=
	{
		Red = 0,
		Green = 1,
		Blue = 1
	},

	--Bank settings
	UseBalanceTV							= true,
	BalanceTV								= 100,
	LogBalance								= true,

	-- Data
	CurrentTV								= 0,
	TVFromKL								= 0,
	TVFromCO								= 0,
	TVFromPK								= 0,
	TVFromDL								= 0,
	TVFromU									= 0,
	StartTimeStamp							= nil,
	LastChangeTimeStamp						= GetTimeStamp(),
}