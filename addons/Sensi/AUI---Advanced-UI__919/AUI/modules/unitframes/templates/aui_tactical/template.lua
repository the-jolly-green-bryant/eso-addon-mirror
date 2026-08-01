local addonName = "AUI"
	
local function GetPlayerData()		
	local templateData = 
	{
		[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = 
		{
			["name"] = "AUI_Tactical_PlayerFrame_Health",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_always"] = true,
				["show_increase_armor_effect"] = false,
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#390200"), AUI.Color.ConvertHexToRGBA("#7c0000")},
			},
			["disabled_settings"] = 
			{
				["show_increase_armor_effect"] = true,
			}				
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD] = 
		{
			["name"] = "AUI_Tactical_PlayerFrame_Shield",
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_always"] = true,
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#4c0087"), AUI.Color.ConvertHexToRGBA("#6606af")}
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["bar_alignment"] = true,	
			}				
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA] = 
		{
			["name"] = "AUI_Tactical_PlayerFrame_Magicka",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_always"] = true,
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#001135"), AUI.Color.ConvertHexToRGBA("#001e63")},
			},				
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA] = 
		{
			["name"] = "AUI_Tactical_PlayerFrame_Stamina",
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_always"] = true,
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#013700"), AUI.Color.ConvertHexToRGBA("#264300")},
			},				
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF] = 
		{
			["name"] = "AUI_Tactical_PlayerFrame_Werewolf",	
			["virtual"] = true,
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#3d1f00"), AUI.Color.ConvertHexToRGBA("#5d3112")},
			},			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT] = 
		{	
			["name"] = "AUI_Tactical_PlayerFrame_StaminaMount",	
			["virtual"] = true,		
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#2a3900"), AUI.Color.ConvertHexToRGBA("#485d00")},
			},			
		},	
		[AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE] = 
		{
			["name"] = "AUI_PlayerFrame_SiegeHealth",	
			["virtual"] = true,	
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,					
			},	
			["disabled_settings"] = 
			{
				["bar_alignment"] = true,
			}				
		}
	}
	
	return templateData
end

local function GetTargetData()		
	local templateData = 
	{
		[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_HEALTH] = 
		{
			["name"] = "AUI_TargetFrame_Health",	
			["virtual"] = true,
			["default_settings"] = 
			{
				["show_increase_armor_effect"] = false,		
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,					
			},				
			["disabled_settings"] = 
			{
				["height"] = true,
				["show_increase_armor_effect"] = true,
				["bar_alignment"] = true,
			}				
		},	
		[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD] = 
		{
			["name"] = "AUI_TargetFrame_Shield",	
			["virtual"] = true,	
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["opacity"] = true,
				["show_text"] = true,
				["use_thousand_seperator"] = true,
				["font_art"] = true,
				["font_style"] = true,
				["font_size"] = true,
				["bar_alignment"] = true,
				["show_max_value"] = true,
			}			
		},		
		[AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_HEALTH] = 
		{
			["name"] = "AUI_Tactical_TargetFrame_Health",	
			["virtual"] = true,	
			["default_settings"] =
			{		
				["show_increase_armor_effect"] = false,						
			},
			["disabled_settings"] = 
			{
				["height"] = false,
				["show_increase_armor_effect"] = true,		
			}				
		},	
		[AUI_UNIT_FRAME_TYPE_SECUNDARY_TARGET_SHIELD] = 
		{
			["name"] = "AUI_Tactical_TargetFrame_Shield",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#4c0087"), AUI.Color.ConvertHexToRGBA("#6606af")},
				["show_text"] = false,
			},	
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["opacity"] = true,
			}			
		}	
	}
	
	return templateData
end

local function GetGroupData()		
	local templateData = 
	{			
		[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH] = 
		{
			["name"] = "AUI_Tactical_GroupFrame",	
			["virtual"] = true,		
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#390200"), AUI.Color.ConvertHexToRGBA("#7c0000")},	
				["show_increase_armor_effect"] = false,					
			},	
			["disabled_settings"] = 
			{
				["show_increase_armor_effect"] = true,
			}				
		},	
		[AUI_UNIT_FRAME_TYPE_GROUP_SHIELD] = 
		{
			["name"] = "AUI_Tactical_GroupFrame_Shield",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#4c0087"), AUI.Color.ConvertHexToRGBA("#6606af")}
			},	
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
			}				
		},
		[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION] = 
		{
			["name"] = "AUI_Tactical_GroupFrame_Companion",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_increase_armor_effect"] = false,					
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["show_increase_armor_effect"] = true,
			}				
		}		
	}
	
	return templateData
end

local function GetRaidData()		
	local templateData = 
	{						
		[AUI_UNIT_FRAME_TYPE_RAID_HEALTH] = 
		{
			["name"] = "AUI_Tactical_RaidFrame",
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#390200"), AUI.Color.ConvertHexToRGBA("#7c0000")},	
				["show_increase_armor_effect"] = false,				
			},	
			["disabled_settings"] = 
			{
				["show_increase_armor_effect"] = true,
			}			
		},
		[AUI_UNIT_FRAME_TYPE_RAID_SHIELD] = 
		{
			["name"] = "AUI_Tactical_RaidFrame_Shield",
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#4c0087"), AUI.Color.ConvertHexToRGBA("#6606af")}
			},	
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
			}				
		},	
		[AUI_UNIT_FRAME_TYPE_RAID_COMPANION] = 
		{
			["name"] = "AUI_Tactical_RaidFrame_Companion",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
			},	
			["disabled_settings"] = 
			{
				["width"] = true,
			}				
		}		
	}
	
	return templateData
end

local function GetBossData()		
	local templateData = 
	{	
		[AUI_UNIT_FRAME_TYPE_BOSS_HEALTH] = 
		{
			["name"] = "AUI_Tactical_BossFrame",
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#390200"), AUI.Color.ConvertHexToRGBA("#7c0000")},		
				["show_increase_armor_effect"] = false,					
			},	
			["disabled_settings"] = 
			{
				["show_increase_armor_effect"] = true,
			}				
		},
		[AUI_UNIT_FRAME_TYPE_BOSS_SHIELD] = 
		{
			["name"] = "AUI_Tactical_BossFrame_Shield",
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#4c0087"), AUI.Color.ConvertHexToRGBA("#6606af")}
			},
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
			}			
		}	
	}
	
	return templateData
end

local function GetCompanionData()		
	local templateData = 
	{			
		[AUI_UNIT_FRAME_TYPE_COMPANION] = 
		{
			["name"] = "AUI_Tactical_Companion",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = {AUI.Color.ConvertHexToRGBA("#4c0087"), AUI.Color.ConvertHexToRGBA("#6606af")}
			},	
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
			}				
		}		
	}
	
	return templateData
end

local function OnLoad(p_eventCode, p_addOnName)
	if p_addOnName ~= addonName then
        return
    end	

	if AUI then
		AUI.UnitFrames.AddPlayerTemplate("AUI Tactical", "AUI_Tactical", 1, GetPlayerData())
		AUI.UnitFrames.AddTargetTemplate("AUI Tactical", "AUI_Tactical", 1, GetTargetData())
		AUI.UnitFrames.AddGroupTemplate("AUI Tactical", "AUI_Tactical", 1, GetGroupData())
		AUI.UnitFrames.AddRaidTemplate("AUI Tactical", "AUI_Tactical", 1, GetRaidData())
		AUI.UnitFrames.AddBossTemplate("AUI Tactical", "AUI_Tactical", 1, GetBossData())
		AUI.UnitFrames.AddCompanionTemplate("AUI Tactical", "AUI_Tactical", 1, GetCompanionData())
	end		
	
	EVENT_MANAGER:UnregisterForEvent(addonName .. "_AUI_Frames_Template_AUI_Tactical", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(addonName .. "_AUI_Frames_Template_AUI_Tactical", EVENT_ADD_ON_LOADED, OnLoad)