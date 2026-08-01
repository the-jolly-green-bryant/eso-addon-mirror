local localization_strings = {
    SLIDER_SIZE = "Icon Size",
    SLIDER_SIZE2 = "Adjust the icon size",
    SLIDER_TEXT = "Text Size",
    SLIDER_TEXT2 = "Adjust the text size",
    COLOR_PICKER = "Text Color",
    COLOR_PICKER2 = "Change the text color",
    POS_X = "Position X",
    POS_X2 = "Change the icon's X position",
    POS_Y = "Position Y",
    POS_Y2 = "Change the icon's Y position",
	SLIDER_STACK = "Stacks before showing icon",
    SLIDER_STACK2 = "Adjust the required number of stacks",
    BUTTOM_HIDE = "Show/Hide",
    BUTTOM_HIDE2 = "Toggle icon visibility for customization",
	
	}
	for stringId, stringValue in pairs(localization_strings) do	
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end