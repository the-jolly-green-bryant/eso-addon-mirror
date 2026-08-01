local HPAStrings = {
	HPA_LOW_ATTR_SLOT_LABEL = "Low %s Slot",
	HPA_LOW_ATTR_THRESHOLD_LABEL = "Low %s Threshold",
	HPA_POPUP_SCALE_LABEL = "Popup Scale",
	HPA_COOLDOWN_ALERT_NAME = "Cooldown Alert",
	HPA_COOLDOWN_ALERT_ENABLED_LABEL = "Enable Quickslot Cooldown Alert",
	HPA_COOLDOWN_ALERT_ENABLED_TOOLTIP = "If enabled an alert will appear when current quickslot item cooldown is over",
	HPA_COOLDOWN_ALERT_FONT_LABEL = "Cooldown Alert Font",
	HPA_COOLDOWN_ALERT_ICON_SIZE_LABEL = "Cooldown Alert Icon Size",
	HPA_COOLDOWN_ALERT_READY_TEXT = "is |c00ff00Ready|r!",
	HPA_COOLDOWN_ALERT_XML_READY_TEXT = "|t48:48:EsoUI/Art/Icons/icon_missing.dds|t is |c00ff00Ready|r!",
	HPA_COOLDOWN_ALERT_XML_LOW_TEXT = "Low Health",
	HPA_COOLDOWN_ALERT_XML_PRESS_TEXT = "Press",
	HPA_LOW_ATTR_TEXT = "Low %s",
	HPA_SET_ALERT_POSITION_NAME = "Set Alert Position",
}

for stringId, stringValue in pairs(HPAStrings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
