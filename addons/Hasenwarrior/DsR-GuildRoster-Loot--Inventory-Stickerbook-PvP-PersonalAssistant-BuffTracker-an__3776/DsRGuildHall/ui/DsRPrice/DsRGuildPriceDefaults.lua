-- Create namespace
DsRGuildPriceDefaults = {}
local DsRGuildPriceDefaults = DsRGuildPriceDefaults  or {}

DsRGuildPriceDefaults.name = "DsRGuildPriceDefaults"
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildPriceDefaults:Defaults()
    local PriceDefaults = {
        -- Main Settings
        PriceOnOff				= false,
    	RoundPrice				= true,
    	Separator				= ".",
    	TooltipLineSpacing		= -5,
    	Font					= "ZoFontGame",
    	TooltipColor			=
    	{
    		Red		= 0.58,
    		Green	= 1,
    		Blue	= 0.54
    	},
		PriceInfoFont			= "ZoFontGameSmall",
    	TooltipPriceInfoColor	=
    	{
			Green 	= 0.7098039389,
			Red 	= 0.6196078658,
			Blue 	= 0.8039215803
		},

    	-- Bound Items
    	BoundItemsAsVendorPrice	= true,
    	MarkBoundItems			= true,
    	BoundItemMarkColor		=
    	{
    		Red		= 0.50,
    		Green	= 0.50,
    		Blue	= 0.50
    	},

    	--Context Menu Settings
    	ContextMenuColor				=
    	{
			Green 	= 0.7098039389,
			Red 	= 0.6196078658,
			Blue 	= 0.8039215803
    	},
    	UsePriceTooltipMenu				= true,

    	--Low price indicator
    	LowPriceIndicatorTooltip 		= true,
    	LowPriceIndicatorGrid 			= true,
    	VendorPriceLowPriceIndicatorColor =
    	{
    		Red		= 1,
    		Green	= 0,
    		Blue	= 0
    	},

    	--Override settings
    	UseGridItemPriceOverride		= true,
    	GridItemPriceOverrideBehaviour	= PRICE_TOOLTIP_BEST_PRICE,
		OverrideBehaviour 				= PRICE_TOOLTIP_AVERAGE_PRICE,
    	ShowSingleItemPriceInGrid 		= false,
    	EnableFirstPriceInGrid 	= true,
    	EnableSecondPriceInGrid = true,

    	--Price settings
    	DisplayVendorPrice	= true,
    	UseProfitPrice		= false,
    	DisplayProfitPrice	= false,
    	ScaleProfitPrice	= 50,

    	--TTC
    	UseTTCPrice 		= true,
    	ScaleTTCPrice		= 10,
    	IncludeAvgTTCPrice	= true,
    	ScaleAvgTTCPrice	= 0,
    	AvgTTCPriceColor	=
    	{
    		Red		= 0,
    		Green	= 1,
    		Blue	= 1
    	},
    	DisplayTTCPrice		 = true,
    	DisplayTTCPriceInfo  = true,

    	--MM
    	UseMMPrice			= true,
    	DisplayMMPrice		= true,
    	DisplayMMPriceInfo	= true,
    	ScaleMMPrice 		= 0,

    	--ATT
    	UseATTPrice				= false,
    	DisplayATTPrice			= true,
    	DisplayATTPriceInfo		= true,
    	ScaleATTPrice			= 0,
    	ATTDays					= 10,

    	--Average
    	UseAveragePrice		= true,
    	DisplayAveragePrice	= false,
    	IncludeTTCInAP		= true,
    	IncludeTTCAvgInAP	= true,
    	IncludeMMInAP		= true,
    	IncludeATTInAP		= true,

    	--BestPrice
    	UseBestPrice		= true,
    	DisplayBestPrice	= false,
    	IncludeTTCAvgInBP	= true,
    	IncludePPInBP		= true,
    	DisplaySourceInBP	= true,
    
    	--Beta fix
    	FixDoubleTooltip 	= true,
    }


	DsRGuildPrice.SavedVariables = ZO_SavedVars:NewAccountWide("DsRGuildPriceSettings", 1, nil, PriceDefaults)
end