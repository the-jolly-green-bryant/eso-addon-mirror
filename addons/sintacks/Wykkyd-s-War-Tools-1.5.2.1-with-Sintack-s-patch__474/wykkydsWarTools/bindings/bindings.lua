ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_STRATEGY_UI", "Toggle Strategy UI")

WYK_WarTools.Bindings = {}

WYK_WarTools.Bindings.ToggleStrategyUI = function()
	if not WYK_WarTools_StrategyUI then return end
	WYK_WarTools_StrategyUI:Toggle()
end