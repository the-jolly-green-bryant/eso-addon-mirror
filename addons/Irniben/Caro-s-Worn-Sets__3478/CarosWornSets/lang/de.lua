-- German Version (Caro's Worn Sets)

local L = {}
	
	
	L.CaroWS_LAM_TextCol = "Textfarbe"
	L.CaroWS_LAM_Orange = "Problem"
	L.CaroWS_LAM_Yellow = "Mögliches Problem"
	L.CaroWS_LAM_Purple = "Mystisch"
	
	L.CaroWS_LAM_BG = "Hintergrund"
	L.CaroWS_LAM_Size = "Schriftgröße"
	L.CaroWS_LAM_MaxWidth = "Maximale Fensterbreite"
	
	L.CaroWS_EnchantQuality = "Verzauberungsqualität: %s"
	
	L.CaroWS_LAM_Individual = "Individuelle Warnungen"
	
	L.CaroWS_LAM_Hotbars = "Ausgerüstete Fertigkeiten passen nicht zur Waffe"
	L.CaroWS_LAM_Monster = "Unvollständige Monstersets"
	L.CaroWS_LAM_LowLevel = "Niedriges Level"
	L.CaroWS_LAM_EnchantQuality = "Verzauberungsqualität"
	L.CaroWS_LAM_ShowLMH = "Zeige Anzahl leicht/mittel/schwer"
	L.CaroWS_LMH = "L/M/S: %s"
	
	L.CaroWS_LAM_ResetPosition = "Fensterposition zentrieren"
	
	L.CaroWS_LAM_Font = "Schriftart"
	L.CaroWS_LAM_FontBold = "Schmalere Buchstaben"
	L.CaroWS_LAM_FontShadow = "Dickere Schatten"
	
	L.CaroWS_bar0 = "Frontbar"
	L.CaroWS_bar1 = "Backbar"
	
	L.CaroWS_LAM_ShowInInventory = "Zeige im Inventar"
	L.CaroWS_LAM_ShowInBank = "Zeige in der Bank"
	L.CaroWS_LAM_ShowInSkills = "Zeige im Fertigkeitenfenster"
	L.CaroWS_LAM_ShowInUI = "Zeige in der Spieloberfläche"
	
	L.CaroWS_LAM_Special = "Unvollständig getragene Sets"
	L.CaroWS_LAM_SpecialExp = "Füge Sets über das Kontextmenü im Inventar dieser Liste hinzu. Sie werden in einer eigenen Farbe markiert, wenn sie unvollständig sind und nicht als Fehler angezeigt."
	
	L.CaroWS_LAM_SpecialCol = "Farbe"
	L.CaroWS_LAM_SpecialSets = "Markierte Sets"
	L.CaroWS_MarkAsSpecial = "CWS: unvollständig getragenes Set"
	
for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end