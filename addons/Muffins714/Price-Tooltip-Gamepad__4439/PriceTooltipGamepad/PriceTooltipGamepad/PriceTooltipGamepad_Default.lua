local PTTG = PriceTooltip
PTTG.Default =
{
	-- Main Settings
	RoundPrice                        = true,
	Separator                         = "'",
	-- TooltipLineSpacing                = -5,
	-- Font                              = "ZoFontWinH4",
	TooltipColor                      =
	{
		Red   = 0.58,
		Green = 1,
		Blue  = 0.54
	},
	-- PriceInfoFont                     = "ZoFontGameSmall",
	TooltipPriceInfoColor             =
	{
		Red   = 0.39,
		Green = 0.59,
		Blue  = 0.78
	},
	GamepadFont                       = "topSection",
	GamepadPriceInfoFont              = "topSubsection",
	DisableStartupLog                 = false,
	DisplayCraftCost                  = false,
	--	DisplayCraftCostInfo              = false,

	-- Bound Items
	BoundItemsAsVendorPrice           = true,
	MarkBoundItems                    = true,
	BoundItemMarkColor                =
	{
		Red   = 0.50,
		Green = 0.50,
		Blue  = 0.50
	},

	--Context Menu Settings
	ContextMenuColor                  =
	{
		Red   = 0.58,
		Green = 1,
		Blue  = 0.54
	},
	UsePriceTooltipMenu               = true,
	UsePriceTooltipMenuGamepad        = true,

	--Low price indicator
	LowPriceIndicatorTooltip          = true,
	LowPriceIndicatorGrid             = true,
	VendorPriceLowPriceIndicatorColor =
	{
		Red   = 1,
		Green = 0,
		Blue  = 0
	},
	ProfitPriceLowPriceIndicatorColor =
	{
		Red   = 1,
		Green = 1,
		Blue  = 0
	},

	--Override settings
	UseGridItemPriceOverride          = true,
	GridItemPriceOverrideBehaviour    = "Average price",
	UseMinItemGridPrice               = false,
	MinItemGridPrice                  = 100,
	ShowSingleItemPriceInGrid         = false,
	GridPriceColor                    =
	{
		Red   = 0.58,
		Green = 1,
		Blue  = 0.54
	},
	EnableFirstPriceInGrid            = true,
	EnableSecondPriceInGrid           = true,
	OverrideMM                        = true,

	--Price settings
	DisplayVendorPrice                = true,
	UseProfitPrice                    = false,
	DisplayProfitPrice                = false,
	ScaleProfitPrice                  = 50,

	--TCC
	UseTTCPrice                       = false,
	ScaleTTCPrice                     = 10,
	IncludeAvgTTCPrice                = true,
	ScaleAvgTTCPrice                  = 0,
	AvgTTCPriceColor                  =
	{
		Red   = 0,
		Green = 1,
		Blue  = 1
	},
	DisplayTTCPrice                   = false,
	DisplayTTCPriceInfo               = false,

	--MM
	UseMMPrice                        = false,
	DisplayMMPrice                    = false,
	DisplayMMPriceInfo                = false,
	ScaleMMPrice                      = 0,

	--ATT
	UseATTPrice                       = false,
	DisplayATTPrice                   = false,
	DisplayATTPriceInfo               = false,
	ScaleATTPrice                     = 0,
	ATTDays                           = 10,

	-- UESP
	UseUESPPrice                      = false,
	ScaleUESPPrice                    = 0,
	DisplayUESPPrice                  = false,
	--DisplayUESPPriceInfo	= false,

	--Average
	UseAveragePrice                   = true,
	DisplayAveragePrice               = true,
	IncludeTTCInAP                    = true,
	IncludeTTCAvgInAP                 = true,
	IncludeMMInAP                     = true,
	IncludeATTInAP                    = true,
	IncludeUESPInAP                   = true,


	--BestPrice
	UseBestPrice      = false,
	DisplayBestPrice  = false,
	IncludeTTCAvgInBP = true,
	IncludePPInBP     = false,
	DisplaySourceInBP = true,

	--Beta fix
	-- FixDoubleTooltip  = false,

	-- Data
	Init              =
	{
		FirstTime_1 = true,
		FirstTime_2 = true,
		FirstTime_3 = true,
		FirstTime_4 = true,
		FirstTime_5 = true,
		FirstTime_6 = true,
		FirstTime_7 = true,
		FirstTime_8 = true,
		FirstTime_9 = true,
	},
}
