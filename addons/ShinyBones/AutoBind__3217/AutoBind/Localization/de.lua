local _de = {
	SI_SBAUTOBIND_ALERT_ITEMS_BOUND = "Gegenstände gebunden",
	SI_SBAUTOBIND_ALERT_NO_ITEMS_FOUND = "Keine ungebundenen Gegenstände gefunden",

	SI_SBAUTOBIND_BINDING_BIND_ALL_UNKNOWN = "Unbekannte Gegenstände binden",
	SI_SBAUTOBIND_BINDING_SHOW_PREVIEW = "Vorschaufenster umschalten",

	SI_SBAUTOBIND_PREVIEW_BIND = "Binden",
	SI_SBAUTOBIND_PREVIEW_HEADER = "Vorschau",
	SI_SBAUTOBIND_PREVIEW_NO_ITEMS_FOUND = "Keine Gegenstände gefunden",
	SI_SBAUTOBIND_PREVIEW_REFRESHING = "Wird aktualisiert...",

	SI_SBAUTOBIND_SETTINGS_BIND_ON_COLLECT_NAME = "Beim Einsammeln binden",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_COLLECT_TOOLTIP = "Wenn aktiviert, werden unbekannte Gegenstände beim einsammeln automatisch gebunden.",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_MAX_QUALITY_NAME = "Max. Qualität",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_MAX_QUALITY_TOOLTIP = "Gegenstände mit einer höheren Qualität als ausgewählt, werden vom Algorithmus ignoriert.",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_VENDOR_TRADE_NAME = "Am Händler binden",
	SI_SBAUTOBIND_SETTINGS_BIND_ON_VENDOR_TRADE_TOOLTIP = "Wenn aktiviert, werden alle unbekannten Gegenstände im Inventar automatisch gebunden, wenn ein Händlerfenster geöffnet wird.",
	SI_SBAUTOBIND_SETTINGS_DESCRIPTION_TRAITS = "Wähle die Eigenschaften, die du für das Binden berücksichtigen möchtest. Gegenstände mit deaktivierten Eigenschaften werden sowohl für Schnellbindungsfunktionen als auch für die Vorschau ignoriert.",
	SI_SBAUTOBIND_SETTINGS_HEADER_GENERAL = "Allgemein",
	SI_SBAUTOBIND_SETTINGS_HEADER_TRAITS = "Eigenschaften",
}

for k, v in pairs(_de) do
	SafeAddString(_G[k], v, 1)
end
