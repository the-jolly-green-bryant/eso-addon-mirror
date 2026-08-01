-- English Version (Caro's Worn Sets)

local L = {}

	L.CaroWS_LAM_TextCol = "Text color"
	L.CaroWS_LAM_Orange = "Problem"
	L.CaroWS_LAM_Yellow = "Possible problem"
	L.CaroWS_LAM_Purple = "Mystic"
	
	L.CaroWS_LAM_BG = "Background color"
	L.CaroWS_LAM_Size = "Font size"
	L.CaroWS_LAM_MaxWidth = "Maximum window width"
	
	L.CaroWS_EnchantQuality = "Enchantment quality: %s"
	
	L.CaroWS_LAM_Individual = "Individual warnings"
	
	L.CaroWS_LAM_Hotbars = "Skills in hotbar not fitting equipped weapon"
	L.CaroWS_LAM_Monster = "Incomplete monster sets"
	L.CaroWS_LAM_LowLevel = "Low level"
	L.CaroWS_LAM_EnchantQuality = "Enchantment quality"
	L.CaroWS_LAM_ShowLMH = "Show numbers for light/medium/heavy"
	L.CaroWS_LMH = "L/M/H: %s"
	
	L.CaroWS_bar0 = "front bar"
	L.CaroWS_bar1 = "back bar"
	
	L.CaroWS_LAM_ResetPosition = "Move window to center"
	
	L.CaroWS_LAM_Font = "Font"
	L.CaroWS_LAM_FontBold = "Light font"
	L.CaroWS_LAM_FontShadow = "Thick shadow"
	L.CaroWS_LAM_ShowInInventory = "Show in inventory"
	L.CaroWS_LAM_ShowInBank = "Show in bank"
	L.CaroWS_LAM_ShowInSkills = "Show in skills window"
	L.CaroWS_LAM_ShowInUI = "Show in UI"
		
	L.CaroWS_LAM_Special = "Sets worn incomplete"
	L.CaroWS_LAM_SpecialExp = "Add sets to this list via context menu in your inventory. They will be shown in the color chosen for this category if they are incomplete and not marked as problematic."
	
	L.CaroWS_LAM_SpecialCol = "Color"
	L.CaroWS_LAM_SpecialSets = "Marked sets"
	L.CaroWS_MarkAsSpecial = "CWS: set worn incomplete"
	
for stringId, stringValue in pairs(L) do
	ZO_CreateStringId(stringId, stringValue)
end