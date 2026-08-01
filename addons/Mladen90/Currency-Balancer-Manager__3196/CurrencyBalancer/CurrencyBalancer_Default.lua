CurrencyBalancer.Default =
{
	-- Main Settings
	Separator								= "'",

	-- Balancing Settings
	UseBalancing							= true,
	LogColor								= 
	{
		Red = 0.39,
		Green = 0.78,
		Blue = 0.78,
	},

	-- Gold Settings
	UseBalanceGold							= true,
	BalanceGold								= 10000,
	LogBalanceGold							= true,

	-- Writ Voucher Settings
	UseBalanceWritVoucher					= true,
	BalanceWritVoucher						= 0,
	LogBalanceWritVoucher					= true,
	
	-- AP Settings
	UseBalanceAP							= true,
	BalanceAP								= 100000,
	LogBalanceAP							= true,
	
	-- TV Settings
	UseBalanceTV							= true,
	BalanceTV								= 100,
	LogBalanceTV							= true,

	-- Warning Settings
	LogWarningColor							=
	{
		Red = 1,
		Green = 0,
		Blue = 0,
	},
	WarningTimer							= 30,

	-- TV Settings
	UseWarningTV							= true,
	Repeat_TV_Warning						= 10,
	WarningTV								= 1000,

	-- Event Ticket Settings
	UseWarningEventTicket					= true,
	Repeat_EventTicket_Warning				= 2,
	WarningEventTicket						= 10,

	-- Transmute Crystal Settings
	UseWarningTransmuteCrystal				= true,
	Repeat_TransmuteCrystal_Warning			= 2,
	WarningTransmuteCrystal					= 451,
}