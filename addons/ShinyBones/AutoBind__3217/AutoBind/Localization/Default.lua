local _default = {
	SI_SBAUTOBIND_ALERT_ITEMS_BOUND = "items bound",
	SI_SBAUTOBIND_ALERT_NO_ITEMS_FOUND = "No unknown items found",

	SI_SBAUTOBIND_BINDING_BIND_ALL_UNKNOWN = "Bind unknown items",
	SI_SBAUTOBIND_BINDING_SHOW_PREVIEW = "Toggle preview window",

	SI_SBAUTOBIND_PREVIEW_BIND = "Bind",
	SI_SBAUTOBIND_PREVIEW_HEADER = "Preview",
	SI_SBAUTOBIND_PREVIEW_NO_ITEMS_FOUND = "No items found",
	SI_SBAUTOBIND_PREVIEW_REFRESHING = "Refreshing...",

	SI_SBAUTOBIND_SETTINGS_BIND_ON_COLLECT_NAME = "Bind On Collect",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_COLLECT_TOOLTIP = "If enabled, unknown items you collect are automatically bound.",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_MAX_QUALITY_NAME = "Max Quality",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_MAX_QUALITY_TOOLTIP = "Items with higher quality than selected are ignored by the algorithm.",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_VENDOR_TRADE_NAME = "Bind At Vendor",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_VENDOR_TRADE_TOOLTIP = "If enabled, all unknown items in your inventory are automatically bound when a vendor window opens.",
	SI_SBAUTOBIND_SETTINGS_DESCRIPTION_TRAITS = "Select which traits you want to consider for binding. Items containing disabled properties will be ignored for both quick binding functions and preview.",
	SI_SBAUTOBIND_SETTINGS_HEADER_GENERAL = "General",
	SI_SBAUTOBIND_SETTINGS_HEADER_TRAITS = "Traits",
}

for k, v in pairs(_default) do
	ZO_CreateStringId(k, v)
	SafeAddVersion(k, 1)
end
