local addonName = "AUI"
	
local function GetTemplateData()
	local templateData = 
	{
		[AUI_ATTRIBUTE_TYPE_PLAYER_HEALTH] = 
		{
			["name"] = "TESO_PlayerFrame_Health",		
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
			}
		},
		[AUI_ATTRIBUTE_TYPE_PLAYER_SHIELD] = 
		{
			["name"] = "TESO_PlayerFrame_Shield",
			["virtual"] = true,		
			["default_settings"] =
			{
				["show_text"] = false,
			},		
			["disabled_settings"] = 
			{
				["show_text"] = true,
				["width"] = true,
				["height"] = true,
			}			
		},		
		[AUI_ATTRIBUTE_TYPE_PLAYER_MAGICKA] = 
		{
			["name"] = "TESO_PlayerFrame_Magicka",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_MAGICKA],
			},				
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
			}			
		},		
		[AUI_ATTRIBUTE_TYPE_PLAYER_WEREWOLF] = 
		{
			["name"] = "TESO_PlayerFrame_Werewolf",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_WEREWOLF],
			},					
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,		
				["show_text"] = true,
			}			
		},		
		[AUI_ATTRIBUTE_TYPE_PLAYER_STAMINA] = 
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
			}			
		},
		[AUI_ATTRIBUTE_TYPE_PLAYER_MOUNT] = 
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
			}			
		},	
		[AUI_ATTRIBUTE_TYPE_PLAYER_SIEGE] = 
		{
			["name"] = "TESO_PlayerFrame_SiegeHealth",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["show_text"] = true,
			}			
		},
		[AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_HEALTH] = 
		{
			["name"] = "TESO_TargetFrame_Health",	
			["virtual"] = true,
			["default_settings"] =
			{
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
			},			
			["disabled_settings"] = 
			{
				["display"] = true,
				["height"] = true,
			}			
		},	
		[AUI_ATTRIBUTE_TYPE_PRIMARY_TARGET_SHIELD] = 
		{
			["name"] = "TESO_TargetFrame_Shield",	
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
			},	
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["show_text"] = true,
			}			
		},		
		[AUI_ATTRIBUTE_TYPE_GROUP_HEALTH] = 
		{
			["name"] = "TESO_GroupFrame",	
			["virtual"] = true,
			["disabled_settings"] = 
			{
				["height"] = true,
			},	
			["default_settings"] =
			{
				["width"] = true,
				["height"] = true,
				["bar_color"] = ZO_POWER_BAR_GRADIENT_COLORS[POWERTYPE_HEALTH],
			},			
		},	
		[AUI_ATTRIBUTE_TYPE_GROUP_SHIELD] = 
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
				["show_text"] = true,
			}		
		},				
		[AUI_ATTRIBUTE_TYPE_RAID_HEALTH] = 
		{
			["name"] = "AUI_RaidFrame",
			["virtual"] = true,		
			["default_settings"] =
			{
				["width"] = true,
				["height"] = true,
			},			
		},
		[AUI_ATTRIBUTE_TYPE_RAID_SHIELD] = 
		{
			["name"] = "AUI_RaidFrame_Shield",
			["virtual"] = true,	
			["default_settings"] =
			{
				["show_text"] = false,
			},			
			["disabled_settings"] = 
			{
				["width"] = true,
				["height"] = true,
				["show_text"] = true,
			}		
		},
		[AUI_ATTRIBUTE_TYPE_BOSS_HEALTH] = 
		{
			["name"] = "TESO_BossFrame",
			["virtual"] = true,
			["default_settings"] =
			{
				["row_distance"] = 24,
			},			
		},
		[AUI_ATTRIBUTE_TYPE_BOSS_SHIELD] = 
		{
			["name"] = "TESO_BossFrame_Shield",
			["virtual"] = true,				
		}		
	}
	
	return templateData
end
	
	
local function OnLoad(p_eventCode, p_addOnName)
	if p_addOnName ~= addonName then
        return
    end	
	
	if AUI then
		AUI.Attributes.AddTemplate("TESO", "TESO", 1, GetTemplateData())
	end	

	EVENT_MANAGER:UnregisterForEvent(addonName .. "_TESO_DESIGN", EVENT_ADD_ON_LOADED)	
end

EVENT_MANAGER:RegisterForEvent(addonName .. "_TESO_DESIGN", EVENT_ADD_ON_LOADED, OnLoad)
