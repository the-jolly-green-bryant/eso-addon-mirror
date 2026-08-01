-- Our "namespace". Lua doesn't have a concept of explicit namespacing, but we 
-- can use tables as a proxy. The files in /addons will populate the TradeHouse, 
-- ToolTips, and Options tables once they load. This way our addon only exports 
-- a single global 'namespace' table instead of many misc globals variables.
PadMerchant = {
	name = "PadMerchant",
	version = "2.0",
	ToolTips = {},
	Utils = {},
	Settings = {
		SuggestionMultiplier = 1.25
	},
	FontFaces = {
		MEDIUM = "$(GAMEPAD_BOLD_FONT)",
		BOLD = "$(GAMEPAD_BOLD_FONT)",
		LIGHT = "$(GAMEPAD_LIGHT_FONT)"
	},
	FontSizes = {
		TINY = "$(GP_22)",
		SMALL = "$(GP_27)",
		MEDIUM = "$(GP_34)",
		LARGE = "$(GP_36)",
		XLARGE = "$(GP_42)"

	},
	FontStyles = {
		SOFT_SHADOW_THICK = "soft-shadow-thick"
	},
	Colors = {
		WHITE = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_1,
		GREY = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_2,
		OFF_WHITE = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3
	},
	Icons = {
		GOLD_WHITE = "|t32:32:esoui/art/currency/gamepad/gp_gold.dds|t"
	},
	Strings = {
		SUGGESTED_PRICING = "SUGGESTED PRICING",
		THIS_STACK_OF = "this stack of ",
		PER_UNIT = "per unit",
		TO = " to ",
		NO_LISTINGS_SEEN = "No listing data seen",
		NO_SALES_SEEN = "No sales data seen",
		LISTINGS_AVG = " listings, averaging ",
		SALES_AVG = " sales, averaging ",
		NO_SUGGESTIONS_AVAILABLE = "No suggestions available"
	}
}

function PadMerchant.Utils.FormatNumber(number, addIcon)
	local result = TamrielTradeCentre:FormatNumber(number, 0)
	
	if addIcon then
		result = result .. PadMerchant.Icons.GOLD_WHITE
	end
	
	return result
end

-- Our addons Initialize event. This will be 
-- called once per EVENT_ADD_ON_LOADED event.
local function Initialize(event, addon)
	
	-- The EVENT_ADD_ON_LOADED event is called once per addon, 
	-- hence why we need to name check and de register from the 
	-- event once our event has come through. 
	if addon ~= PadMerchant.name then return end
	GetEventManager():UnregisterForEvent(PadMerchant.name, EVENT_ADD_ON_LOADED)

	-- Set up each of our integrations.
	PadMerchant.ToolTips.Setup()
end

-- Register our Initialize method to the EVENT_ADD_ON_LOADED event. This event is fired by 
-- the game when it loads addons. It fires once per addon, per login or /uireload command.
GetEventManager():RegisterForEvent(PadMerchant.name, EVENT_ADD_ON_LOADED, Initialize)



--[[ Globals Used & Explainations:

EVENT_ADD_ON_LOADED
  The game event for loading addins

GetEventManager()
  Built in function for getting access to the games event manager. Allows
	our addon to register functions as listeners for various events.

]]