DebuffMe = DebuffMe or {}
local DebuffMe = DebuffMe

DebuffMe.DebuffList = {
    [1] = "-- None --",
	[2] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(38541)), --Taunt
	[3] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(17906)), --Crusher
	[4] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(75753)), --Alkosh
	[5] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(31104)), --EngFlames
    [6] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(62988)), --OffBalance
    [7] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(79717)), --Minor Vulnerability
    [8] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(62504)), --Minor Maim
	[9] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(39100)), --Minor MagSteal    
	[10] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(88575)), --Minor LifeSteal    
    [11] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(17945)), --Weakening  
	[12] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61742)), --Minor Breach
	[13] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61743)), --Major Breach
	[14] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(106754)), --Major Vulnerability
	[15] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(34384)), --Morag Tong
	[16] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(145975)), --Minor Brittle
	[17] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(126597)), --Z'en
	[18] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(142610)), --EC Fire
	[19] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(142653)), --EC Shock
	[20] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(142652)), --EC Frost
}
--52788 Taunt immunity
--134599 OffBalance immunity
--68359 Minor Vulne (not IA)
--68368 Mino Maim (not W+S)
--80020  Minor Lifesteal
--41958 Green Altar
--41967 Red Altar

DebuffMe.TransitionTable = {
	[1] = 0,
	[2] = 38541, --Taunt
	[3] = 17906, --Crusher
	[4] = 75753, --Alkosh
	[5] = 31104, --EngFlames
    [6] = 62988, --OffBalance
    [7] = 79717, --Minor Vulnerability
    [8] = 62504, --Minor Maim
	[9] = 39100, --Minor MagSteal   
	[10] = 88575, --Minor LifeSteal 
    [11] = 17945, --Weakening  
	[12] = 61742, --Minor Breach
	[13] = 61743, --Major Breach
	[14] = 122397, --Major Vulnerability
	[15] = 34384, --Morag Tong
	[16] = 145975, --Minor Brittle
	[17] = 126597, --Z'en
	[18] = 142610, --EC Fire
	[19] = 142653, --EC Shock
	[20] = 142652, --EC Frost
}

DebuffMe.CustomAbilityNameWithID = {
	[38541] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(38541)), --Taunt
	[52788] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(52788)), --Taunt Immunity
	[17906] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(17906)), --Crusher
	[75753] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(75753)), --Alkosh
	[31104] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(31104)), --EngFlames
	[62988] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(62988)), --OffBalance
	[134599] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(134599)), --OffBalance Immunity
	[81519] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(79717)), --Minor Vulnerability
	[68359] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(68359)), --Minor Vulne (not IA)
    [68368] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(62504)), --Minor Maim
	[39100] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(39100)), --Minor MagSteal    
	[88575] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(88575)), --Minor LifeSteal    
    [17945] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(17945)), --Weakening  
	[61742] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61742)), --Minor Breach   
	[61743] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(61743)), --Major Breach 
	[106754] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(106754)), --Major Vulnerability 
	[34384] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(34384)), --Morag Tong
	[145975] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(145975)), --Minor Brittle
	[126597] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(126597)), --Z'en
	[142610] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(142610)), --EC Fire
	[142653] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(142653)), --EC Shock
	[142652] = zo_strformat(SI_ABILITY_NAME, GetAbilityName(142652)), --EC Frost
}

DebuffMe.Abbreviation = {
    [1] = "",
	[2] = "TN", --Taunt
	[3] = "CR", --Crusher
	[4] = "AL", --Alkosh
	[5] = "EF", --EngFlames
    [6] = "OB", --OffBalance
    [7] = "IA", --Minor Vulnerability
    [8] = "mM", --Minor Maim
	[9] = "mS", --Minor MagSteal    
	[10] = "mL", --Minor LifeSteal   
    [11] = "WK", --Weakening  
	[12] = "mB", --Minor Breach
	[13] = "MB", --Major Breach
	[14] = "MV", --Major Vulnerability 
	[15] = "MT", --Morag Tong
	[16] = "BR", --Minor Brittle
	[17] = "Zn", --Z'en
	[18] = "VF", --EC Fire
	[19] = "VS", --EC Shock
	[20] = "VI", --EC Frost
}