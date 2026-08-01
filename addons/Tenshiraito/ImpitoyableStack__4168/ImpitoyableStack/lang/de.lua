local localization_strings = {
    SLIDER_SIZE = "Symbolgröße",
    SLIDER_SIZE2 = "Ändert die Größe des Symbols",
    SLIDER_TEXT = "Textgröße",
    SLIDER_TEXT2 = "Ändert die Größe des Textes",
    COLOR_PICKER = "Textfarbe",
    COLOR_PICKER2 = "Ändert die Farbe des Textes",
    POS_X = "Position X",
    POS_X2 = "Ändert die X-Position des Symbols",
    POS_Y = "Position Y",
    POS_Y2 = "Ändert die Y-Position des Symbols",
    SLIDER_STACK = "Stacks vor dem Anzeigen des Symbols",
    SLIDER_STACK2 = "Ändert die benötigte Stackanzahl",
    BUTTOM_HIDE = "Anzeigen/Verbergen",
    BUTTOM_HIDE2 = "Zeigt oder verbirgt das Symbol zur Anpassung",
	
	}
	for stringId, stringValue in pairs(localization_strings) do	
		ZO_CreateStringId(stringId, stringValue)
		SafeAddVersion(stringId, 1)
	end