APC.Default =
{
	-- Main Settings
	UseAPIcon								= true,
	LogColor								= 
	{
		Red = 1,
		Green = 0.8,
		Blue = 0
	},
	RestoreAP								= true,
	SkipRestoreApAfterMins					= 15,
	ShowAvailableCommandsMessageOnStart		= true,
	Separator								= "'",

	-- Start / Stop Settings
	StartCounterInCyrodiil					= false,
	StartCounterInImperialCity				= false,

	-- Alliance point log settings
	LogEnabled 								= true,
	LogAPAmount								= 1,
	ApLogFormat								= "AP gain -> current AP",
	LogTickResourceName						= true,
	LogEveryTickEnabled						= false,

	--Screen message settings
	MainWindowLeft							= nil,
	MainWindowBottom						= nil,
	UseScreenMessage 						= true,
	TickAPAmount							= 1,
	DisplayTickResourceName					= true,
	ScreenMessageScaling					= 1,
	TickFadeTime							= 5,
	TickColor								= 
	{
		Red = 0,
		Green = 1,
		Blue = 1
	},

	-- Bank Settings
	UseBalanceAP							= true,
	BalanceAP								= 100000,
	LogBalance								= true,

	-- Data
	CurrentAP								= 0,
	APFromQ									= 0,
	APFromKH								= 0,
	APFromDT								= 0,
	APFromOT								= 0,
	APFromWD								= 0,
	APFromRA								= 0,
	APFromRE								= 0,
	APFromU									= 0,
	StartTimeStamp							= nil,
	LastGainTimeStamp						= GetTimeStamp(),
}