local strings = {
		AHUD_PERFECT = "Perfect Condition",
		AHUD_GOOD = "Good Condition",
		AHUD_ACCEPTABLE = "Acceptable Condition",
		AHUD_BAD = "Bad Condition",
		AHUD_BROCKEN = "Brocken Condition",
		AHUD_PERFECT_DESC = "Set the color for perfect condition",
		AHUD_GOOD_DESC = "Set the color for good condition",
		AHUD_ACCEPTABLE_DESC = "Set the color for acceptable condition",
		AHUD_BAD_DESC = "Set the color for bad condition",
		AHUD_BROCKEN_DESC = "Set the color for brocken condition",
		AHUD_PREVIEW = "Preview",
		AHUD_PREVIEW_DESC = "Shows a preview of the UI element",
		AHUD_SHOWTEXT = "Hide Text",
		AHUD_SHOWTEXT_DESC = "Shows the condition in percent",
		AHUD_ICONSIZE = "Icon Size",
		AHUD_ICONSIZE_DESC = "Changes the size of the icons",
		AHUD_ICONSIZE_WARN = "You have to reload the addon /reloadui",
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
