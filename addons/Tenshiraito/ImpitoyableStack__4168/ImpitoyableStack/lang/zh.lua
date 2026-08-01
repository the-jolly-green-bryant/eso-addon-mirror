local localization_strings = {
    SLIDER_SIZE = "图标大小",
    SLIDER_SIZE2 = "调整图标的大小",
    SLIDER_TEXT = "文字大小",
    SLIDER_TEXT2 = "调整文字的大小",
    COLOR_PICKER = "文字颜色",
    COLOR_PICKER2 = "更改文字颜色",
    POS_X = "X 位置",
    POS_X2 = "更改图标的 X 坐标",
    POS_Y = "Y 位置",
    POS_Y2 = "更改图标的 Y 坐标",
    SLIDER_STACK = "显示图标所需的堆叠数量",
    SLIDER_STACK2 = "调整所需的堆叠数量",
    BUTTOM_HIDE = "显示/隐藏",
    BUTTOM_HIDE2 = "显示或隐藏图标以进行自定义",
	
	}
	for stringId, stringValue in pairs(localization_strings) do	
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end