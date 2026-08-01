local addonName = "AUI"
	
local function GetPlayerData()
	local templateData = 
	{
		[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = 
		{
			["name"] = "TESO_PlayerFrame_Health",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["bar_alignment"] = true,
			}
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD] = 
		{
			["name"] = "TESO_PlayerFrame_Shield",
			["virtual"] = true,		
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,
			},		
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
		[AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA] = 
		{
			["name"] = "TESO_PlayerFrame_Magicka",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_alignment"] = BAR_ALIGNMENT_REVERSE,	
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_MAGICKA],
			},				
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["bar_alignment"] = true,
			}			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF] = 
		{
			["name"] = "TESO_PlayerFrame_Werewolf",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_WEREWOLF],
				["bar_alignment"] = BAR_ALIGNMENT_REVERSE,
			},					
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,		
				["show_text"] = true,
				["bar_alignment"] = true,
			}			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA] = 
		{
			["name"] = "TESO_PlayerFrame_Stamina",
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_STAMINA],
			},				
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["bar_alignment"] = true,
			}			
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT] = 
		{	
			["name"] = "TESO_PlayerFrame_StaminaMount",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_MOUNT_STAMINA],
			},				
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["show_text"] = true,
				["bar_alignment"] = true,				
			}			
		},	
		[AUI_UNIT_FRAME_TYPE_PLAYER_SIEGE] = 
		{
			["name"] = "TESO_PlayerFrame_SiegeHealth",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["show_text"] = true,
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
			["name"] = "TESO_TargetFrame_Health",	
			["virtual"] = true,
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],	
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,				
			},			
			["disabled_settings"] = 
			{
				["display"] = true,
				["height"] = true,
				["bar_alignment"] = true,
			}			
		},	
		[AUI_UNIT_FRAME_TYPE_PRIMARY_TARGET_SHIELD] = 
		{
			["name"] = "TESO_TargetFrame_Shield",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,
			},			
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
		}		
	}
	
	return templateData
end

local function GetGroupData()
	local templateData = 
	{	
		[AUI_UNIT_FRAME_TYPE_GROUP_HEALTH] = 
		{
			["name"] = "TESO_GroupFrame",	
			["virtual"] = true,
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],	
				["show_increase_armor_effect"] = false,					
			},				
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,
				["show_increase_armor_effect"] = true,					
			},			
		},	
		[AUI_UNIT_FRAME_TYPE_GROUP_SHIELD] = 
		{
			["name"] = "TESO_GroupFrame_Shield",		
			["virtual"] = true,
			["default_settings"] =
			{
				["show_text"] = false,
			},			
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
		[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION] = 
		{
			["name"] = "TESO_GroupFrame_Companion",	
			["virtual"] = true,
			["default_settings"] =
			{
				["show_increase_armor_effect"] = false,					
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["bar_alignment"] = true,	
				["show_increase_armor_effect"] = true,				
			},			
		},		
	}
	
	return templateData
end

local function GetBossData()
	local templateData = 
	{
		[AUI_UNIT_FRAME_TYPE_BOSS_HEALTH] = 
		{
			["name"] = "TESO_BossFrame",
			["virtual"] = true,
			["default_settings"] =
			{
				["row_distance"] = 24,	
			},	
			["disabled_settings"] = 
			{
				["bar_alignment"] = true,
			}			
		},
		[AUI_UNIT_FRAME_TYPE_BOSS_SHIELD] = 
		{
			["name"] = "TESO_BossFrame_Shield",
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
		}		
	}
	
	return templateData
end
	
local function OnLoad(p_eventCode, p_addOnName)
	if p_addOnName ~= addonName then
        return
    end	
	
	if AUI then
		AUI.UnitFrames.AddPlayerTemplate("AUI TESO", "AUI_TESO", 1, GetPlayerData())
		AUI.UnitFrames.AddTargetTemplate("AUI TESO", "AUI_TESO", 1, GetTargetData())
		AUI.UnitFrames.AddGroupTemplate("AUI TESO", "AUI_TESO", 1, GetGroupData())
		AUI.UnitFrames.AddBossTemplate("AUI TESO", "AUI_TESO", 1, GetBossData())
	end		

	EVENT_MANAGER:UnregisterForEvent(addonName .. "_AUI_Frames_Template_AUI_TESO", EVENT_ADD_ON_LOADED)	
end

EVENT_MANAGER:RegisterForEvent(addonName .. "_AUI_Frames_Template_AUI_TESO", EVENT_ADD_ON_LOADED, OnLoad)
