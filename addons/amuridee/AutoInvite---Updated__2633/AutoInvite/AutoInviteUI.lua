-- This file is part of AutoInvite
--
-- (C) 2016 Scott Yeskie (Sasky)
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

AutoInviteUI = AutoInviteUI or {}
local ui = AutoInviteUI

function AutoInviteUI.refresh()
    ui.fragmentEnabled.enabled:UpdateValue()
    if not AutoInviteUI.textUpdated then
	   ui.fragmentEnabled.text:UpdateValue()
	   AutoInviteUI.textUpdated = true
	end
	MINI_GROUP_LIST:RefreshData()
    --ui.fragmentOptions.cyr:UpdateValue()
    --ui.fragmentOptions.restart:UpdateValue()
    --ui.fragmentOptions.kick:UpdateValue()
    --ui.fragmentOptions.kickTime:UpdateValue()
    --ui.fragmentOptions.max:UpdateValue()
end

function AutoInvite.CreateMenu()

    local slashcmds = GetString(SI_AUTO_INVITE_SLASHCMD_START).."\n"..GetString(SI_AUTO_INVITE_SLASHCMD_HELP).."\n"..GetString(SI_AUTO_INVITE_SLASHCMD_STOP)
    local controlData = {}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = GetString(SI_AUTO_INVITE_OPT_ENABLED),
					tooltip = GetString(SI_AUTO_INVITE_TT_ENABLED),
					getFunc = function() return AutoInvite.listening end,
					setFunc = function(val)	if val then AutoInvite.startListening() else AutoInvite.disable() end end,
					width = "half",
		    }
       controlData[#controlData+1] = {
					  type = "button",
					  name = GetString(SI_AUTO_INVITE_GROUP_SETTINGS),
					  func = function() GROUP_MENU_KEYBOARD:ShowCategory(AI_SMALL_GROUP_LIST_FRAGMENT) AutoInviteUI.refresh() end,
					  width = "half",	
			}
       controlData[#controlData+1] = {
					type = "editbox",
					name = GetString(SI_AUTO_INVITE_OPT_STRING),
					tooltip = GetString(SI_AUTO_INVITE_TT_STRING),
					getFunc = function() return AutoInvite.cfg.watchStr end,
					setFunc = function(val) AutoInvite.cfg.watchStr = string.lower(val) end,
					width = "half",
            }
       controlData[#controlData+1] = {
			        type = "slider",
					name = GetString(SI_AUTO_INVITE_OPT_MAX_SIZE),
					tooltip = GetString(SI_AUTO_INVITE_TT_MAX_SIZE),
					min = 4,
					max = 12,
					getFunc = function() return AutoInvite.cfg.maxSize end,
					setFunc = function(val) AutoInvite.cfg.maxSize = val end,
					default = 12,
					width = "half",
            }
       controlData[#controlData+1] = {
					type = "checkbox",
					name = GetString(SI_AUTO_INVITE_OPT_RESTART),
					tooltip = GetString(SI_AUTO_INVITE_TT_RESTART),
					getFunc = function() return AutoInvite.cfg.restart end,
					setFunc = function(val) AutoInvite.cfg.restart = val end,
					width = "half",
            }
       controlData[#controlData+1] = {
					type = "checkbox",
					name = GetString(SI_AUTO_INVITE_OPT_CYRCHECK),
					tooltip = GetString(SI_AUTO_INVITE_TT_CYRCHECK),
					getFunc = function() return AutoInvite.cfg.cyrCheck end,
					setFunc = function(val) AutoInvite.cfg.cyrCheck = val end,
					width = "half",
            }
       controlData[#controlData+1] = {
					type = "checkbox",
					name = GetString(SI_AUTO_INVITE_OPT_KICK),
					tooltip = GetString(SI_AUTO_INVITE_TT_KICK),
					getFunc = function() return AutoInvite.cfg.autoKick end,
					setFunc = function(val) AutoInvite.cfg.autoKick = val end,
					width = "half",
            }
       controlData[#controlData+1] = {
					type = "slider",
					name = GetString(SI_AUTO_INVITE_OPT_KICK_TIME),
					tooltip = GetString(SI_AUTO_INVITE_TT_KICK_TIME),
					min = 5,
					max = 600,
					getFunc = function() return AutoInvite.cfg.kickDelay end,
					setFunc = function(val) AutoInvite.cfg.kickDelay = val end,
					default = 300,
					width = "half",
            }
       controlData[#controlData+1] = {
					type = "editbox",
					name = GetString(SI_AUTO_INVITE_OPT_ENROLMENT),
					tooltip = GetString(SI_AUTO_INVITE_TT_ENROLMENT),
					getFunc = function() return AutoInvite.cfg.enrollStr end,
					setFunc = function(val) AutoInvite.cfg.enrollStr = val end,
					isMultiline = true,
					isExtraWide = true,
					width = "full",
            }
       controlData[#controlData+1] = {
					type = "description",
                    text = GetString(SI_AUTO_INVITE_OPT_NEEDED),  
					width = "full",
            }			
       controlData[#controlData+1] = {
					type = "editbox",
					name = "|t32:32:/esoui/art/lfg/gamepad/lfg_roleicon_tank.dds|t",
					getFunc = function() return AutoInvite.cfg.tanksNeeded end,
					setFunc = function(val) AutoInvite.cfg.tanksNeeded = val end,
					width = "full",
            }
       controlData[#controlData+1] = {
					type = "editbox",
					name = "|t32:32:/esoui/art/lfg/gamepad/lfg_roleicon_healer.dds|t",
					getFunc = function() return AutoInvite.cfg.healersNeeded end,
					setFunc = function(val) AutoInvite.cfg.healersNeeded = val end,
					width = "full",
            }
       controlData[#controlData+1] = {
					type = "editbox",
					name =  "|t32:32:/esoui/art/lfg/gamepad/lfg_roleicon_dps.dds|t",
					getFunc = function() return AutoInvite.cfg.ddsNeeded end,
					setFunc = function(val) AutoInvite.cfg.ddsNeeded = val end,
					width = "full",
            }			
       controlData[#controlData+1] = {
						type = "header",
						name = GetString(SI_AUTO_INVITE_CHATS_LISTEN),
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_CHAT_CHANNEL_NAME_ZONE).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_CHAT_CHANNEL_NAME_ZONE).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_1) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_1).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_1] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_1] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_2) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_2).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_2] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_2] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_3) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_3).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_3] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_3] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_4) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_4).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_4] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_4] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_5) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_GUILD_5).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_5] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_GUILD_5] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME0).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME0).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_1] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_1] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME1).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME1).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_2] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_2] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME2).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME2).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_3] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_3] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME3).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME3).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_4] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_4] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME4).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME4).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_5] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_5] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME5).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME5).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_6] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_6] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME6).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_OFFICIALLANGUAGE_ZONECHATCHANNELNAME6).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_7] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_ZONE_LANGUAGE_7] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_GUILDRANKS254).." - "..GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_1) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_1).." "..GetString(SI_GUILDRANKS254).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_1] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_1] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_GUILDRANKS254).." - "..GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_2) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_2).." "..GetString(SI_GUILDRANKS254).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_2] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_2] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_GUILDRANKS254).." - "..GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_3) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_3).." "..GetString(SI_GUILDRANKS254).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_3] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_3] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_GUILDRANKS254).." - "..GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_4) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_4).." "..GetString(SI_GUILDRANKS254).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_4] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_4] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_GUILDRANKS254).." - "..GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_5) end,
					tooltip = function() return GetDynamicChatChannelName(CHAT_CHANNEL_OFFICER_5).." "..GetString(SI_GUILDRANKS254).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_5] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_OFFICER_5] = value end,
					default = true,
					width = "half"
			}
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_CHATCHANNELCATEGORIES1).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_CHATCHANNELCATEGORIES1).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_SAY] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_SAY] = value end,
					default = true,
					width = "half"
			}	
      controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_CHAT_PLAYER_CONTEXT_WHISPER).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_WHISPER] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_WHISPER] = value end,
					default = true,
					width = "half"
			}	
       controlData[#controlData+1] = {
					type = "checkbox",
					name = function() return GetString(SI_CHATCHANNELCATEGORIES2).." "..GetString(SI_CHAT_TAB_GENERAL) end,
					tooltip = function() return GetString(SI_CHATCHANNELCATEGORIES2).." "..GetString(SI_CHAT_TAB_GENERAL).." "..GetString(SI_SCREEN_NARRATION_JOINED_CHANNEL_ICON_NARRATION) end,
					getFunc = function() return AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_YELL] end,
					setFunc = function(value) AutoInvite.cfg.channelsToListenTo[CHAT_CHANNEL_YELL] = value end,
					default = true,
					width = "half"
			}	
       controlData[#controlData+1] = {
					type = "description",
					title = GetString(SI_AUTO_INVITE_OPT_SLASHCMD),
					text = slashcmds,
					width = "half"
			}
			
			
   return controlData
end



function AutoInviteUI.init()
    if ui.created then return end
    
    AutoInviteUI:CreateEnabledFragment()
	--AutoInviteUI:CreateOptionFragment()
	AutoInviteUI:CreateScene()
	
	local LAM = LibAddonMenu2
	
	local panelData = {
		type = "panel",
		name = AutoInvite.AddonId,
		author = "|c3CB371@Masteroshi430|r, |cFFC300@amuridee|r, Ayantir, Sasky, silentgecko",
		version = AutoInvite.Version,
		website = "https://www.esoui.com/downloads/info2633-AutoInvite-Updated.html",
		registerForDefaults = true,
		registerForRefresh = true,
	}
	
	AutoInvite.Pannel = LAM:RegisterAddonPanel(AutoInvite.AddonId.."Config", panelData)
	local controlData = AutoInvite.CreateMenu()
    LAM:RegisterOptionControls(AutoInvite.AddonId.."Config", controlData)
    
	ui.created = true
end





