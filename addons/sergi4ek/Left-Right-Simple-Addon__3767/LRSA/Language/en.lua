-------------------------------------------------
-- English localization for LRSA by @dack_janiels[NA]
-------------------------------------------------

local strings = {
    LRSA_LEFT_STR = "LEFT",
	LRSA_RIGHT_STR = "RIGHT",
	LRSA_CHECKBOX1_NAME = "Display labels",
	LRSA_CHECKBOX1_TOOLTIP = "Display labels on the left and right sides",
	LRSA_SLIDER1_NAME = "Font size",
	LRSA_SLIDER1_TOOLTIP = "Specify the font size for the labels",
	LRSA_COLORPICKER1_NAME = "Label color",
    LRSA_COLORPICKER1_TOOLTIP = "Choose a color for the labels",
	LRSA_SLIDER2_NAME = "Horizontal distance",
	LRSA_SLIDER2_TOOLTIP = "Specify the display coordinate horizontally",
    LRSA_SLIDER3_NAME = "Vertical distance",
	LRSA_SLIDER3_TOOLTIP = "Specify the display coordinate vertically"
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(stringId, 1)
end