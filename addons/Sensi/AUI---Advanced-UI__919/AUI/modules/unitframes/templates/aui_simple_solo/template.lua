local addonName = "AUI"
	
local function GetPlayerData()	
	local templateData = 
	{
		[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = 
		{
			["name"] = "AUI_PlayerFrame_Health_Simple",		
			["virtual"] = true,	
			["default_settings"] = 
			{
				["show_increase_armor_effect"] = false,
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,				
			},				
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD] = 
		{
			["name"] = "AUI_PlayerFrame_Shield_Simple_Solo",
			["virtual"] = true,	
			["default_settings"] = 
			{
				["show_text"] = true,
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,				
			}			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA] = 
		{
			["name"] = "AUI_PlayerFrame_Magicka_Simple",	
			["virtual"] = true,
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_REVERSE,				
			},			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF] = 
		{
			["name"] = "AUI_PlayerFrame_Werewolf_Simple",	
			["virtual"] = true,	
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_REVERSE,				
			},				
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA] = 
		{
			["name"] = "AUI_PlayerFrame_Stamina_Simple",
			["virtual"] = true,					
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT] = 
		{	
			["name"] = "AUI_PlayerFrame_StaminaMount_Simple",	
			["virtual"] = true,					
		},	
		[AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE] = 
		{
			["name"] = "AUI_PlayerFrame_SiegeHealth_Simple",	
			["virtual"] = true,
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,				
			},			
		}		
	}
	
	return templateData
end

local function OnLoad(p_eventCode, p_addOnName)
	if p_addOnName ~= addonName then
        return
    end	

	if AUI then
		AUI.UnitFrames.AddPlayerTemplate("AUI Simple (Solo Shield)", "AUI_Simple_Solo_Shield", 1, GetPlayerData())
	end	

	EVENT_MANAGER:UnregisterForEvent(addonName .. "_AUI_Frames_Template_AUI_Simple_Solo_Shield", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addonName .. "_AUI_Frames_Template_AUI_Simple_Solo_Shield", EVENT_ADD_ON_LOADED, OnLoad)