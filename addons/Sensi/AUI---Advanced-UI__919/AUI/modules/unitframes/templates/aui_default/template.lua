local addonName = "AUI"
	
local function GetPlayerData()	
	local templateData = 
	{
		[AUI_UNIT_FRAME_TYPE_PLAYER_HEALTH] = 
		{
			["name"] = "AUI_PlayerFrame_Health",		
			["virtual"] = true,	
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,				
			},				
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,	
			}
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_SHIELD] = 
		{
			["name"] = "AUI_PlayerFrame_Shield",
			["virtual"] = true,	
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_CENTER,
				["show_text"] = true,				
			},				
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,
			}		
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_MAGICKA] = 
		{
			["name"] = "AUI_PlayerFrame_Magicka",	
			["virtual"] = true,	
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_REVERSE,				
			},				
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,
			}			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_WEREWOLF] = 
		{
			["name"] = "AUI_PlayerFrame_Werewolf",	
			["virtual"] = true,	
			["default_settings"] = 
			{
				["bar_alignment"] = BAR_ALIGNMENT_REVERSE,				
			},				
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,
			}			
		},		
		[AUI_UNIT_FRAME_TYPE_PLAYER_STAMINA] = 
		{
			["name"] = "AUI_PlayerFrame_Stamina",
			["virtual"] = true,	
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,
			}			
		},
		[AUI_UNIT_FRAME_TYPE_PLAYER_MOUNT] = 
		{	
			["name"] = "AUI_PlayerFrame_StaminaMount",	
			["virtual"] = true,	
			["disabled_settings"] = 
			{
				["height"] = true,
				["bar_alignment"] = true,
			}			
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
				["height"] = true,
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
			["name"] = "AUI_TargetFrame_Shield",	
			["virtual"] = true,	
			["default_settings"] = 
			{
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
			["name"] = "AUI_GroupFrame",	
			["virtual"] = true,		
			["default_settings"] =
			{
				["show_increase_armor_effect"] = false,					
			},	
			["disabled_settings"] = 
			{
				["show_increase_armor_effect"] = true,
			}			
		},	
		[AUI_UNIT_FRAME_TYPE_GROUP_SHIELD] = 
		{
			["name"] = "AUI_GroupFrame_Shield",		
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
		[AUI_UNIT_FRAME_TYPE_GROUP_COMPANION] = 
		{
			["name"] = "AUI_GroupFrame_Companion",		
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
			["name"] = "AUI_RaidFrame",
			["virtual"] = true,		
			["default_settings"] =
			{
				["show_increase_armor_effect"] = false,					
			},	
			["disabled_settings"] = 
			{
				["show_increase_armor_effect"] = true,
			}			
		},
		[AUI_UNIT_FRAME_TYPE_RAID_SHIELD] = 
		{
			["name"] = "AUI_RaidFrame_Shield",
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
		[AUI_UNIT_FRAME_TYPE_RAID_COMPANION] = 
		{
			["name"] = "AUI_RaidFrame_Companion",
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
			["name"] = "AUI_BossFrame",
			["virtual"] = true,			
		},
		[AUI_UNIT_FRAME_TYPE_BOSS_SHIELD] = 
		{
			["name"] = "AUI_BossFrame_Shield",
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
		AUI.UnitFrames.AddPlayerTemplate("AUI", "AUI", 1, GetPlayerData())
		AUI.UnitFrames.AddTargetTemplate("AUI", "AUI", 1, GetTargetData())
		AUI.UnitFrames.AddGroupTemplate("AUI", "AUI", 1, GetGroupData())
		AUI.UnitFrames.AddRaidTemplate("AUI", "AUI", 1, GetRaidData())		
		AUI.UnitFrames.AddBossTemplate("AUI", "AUI", 1, GetBossData())
	end	

	EVENT_MANAGER:UnregisterForEvent(addonName .. "_AUI_Frames_Template_AUI", EVENT_ADD_ON_LOADED)	
end

EVENT_MANAGER:RegisterForEvent(addonName .. "_AUI_Frames_Template_AUI", EVENT_ADD_ON_LOADED, OnLoad)
