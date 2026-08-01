CustomKillFeed = {}
CustomKillFeed.name = "CustomKillFeed"
CustomKillFeed.version = "2026.07.06"

-- Cache these localized strings once instead of calling GetString() repeatedly.
-- CustomKillFeed.go() re-resolved up to 4 of these on EVERY EVENT_PVP_KILL_FEED_DEATH,
-- which can fire many times per second in large-scale Cyrodiil/battleground fights.
-- The values never change during a session, so resolving them once here removes that
-- repeated work from the hottest code path in the addon.
CustomKillFeed.STR_FILTER_PLAYER = GetString(SI_PLAYER_MENU_PLAYER)
CustomKillFeed.STR_FILTER_GROUP = GetString(SI_MAIN_MENU_GROUP)
CustomKillFeed.STR_FILTER_GUILD = GetString(SI_SOCIAL_MENU_GUILDS)
CustomKillFeed.STR_FILTER_EVERYONE = GetString(SI_CUSTOMERSERVICEASKFORHELPREPORTPLAYERSUBCATEGORY203)

CustomKillFeed.defaults = {
	filter = CustomKillFeed.STR_FILTER_PLAYER,
	combatSummary = false,
	displayKills = true,
	displayDeaths = true,
}

function CustomKillFeed.CreateGuildsCheckboxes()

        local controlData = {
		
			[1] = {	type = "dropdown",
					name = GetString(SI_GAMEPAD_BANK_FILTER_HEADER),
					choices = {CustomKillFeed.STR_FILTER_PLAYER, CustomKillFeed.STR_FILTER_GROUP, CustomKillFeed.STR_FILTER_GUILD, CustomKillFeed.STR_FILTER_EVERYONE},
					getFunc = function() return CustomKillFeed.vars.filter end,
					setFunc = function(value) CustomKillFeed.vars.filter = value end,
					width = "full",
					default = CustomKillFeed.defaults.filter,
			},
			[2] = {
				type = "checkbox",
				name = GetString(SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY).." "..GetString(SI_BATTLEGROUND_SCOREBOARD_HEADER_KILLS_NARRATION),     
				getFunc = function() return CustomKillFeed.vars.displayKills end,
				setFunc = function(value)  CustomKillFeed.vars.displayKills = value end,
				disabled = function() return CustomKillFeed.vars.filter == CustomKillFeed.STR_FILTER_EVERYONE end,
				default = true,
			},
			[3] = {
				type = "checkbox",
				name = GetString(SI_GRAPHICS_OPTIONS_VIDEO_CATEGORY_DISPLAY).." "..GetString(SI_BATTLEGROUND_SCOREBOARD_HEADER_DEATHS_NARRATION),      
				getFunc = function() return CustomKillFeed.vars.displayDeaths end,
				setFunc = function(value)  CustomKillFeed.vars.displayDeaths = value end,
				disabled = function() return CustomKillFeed.vars.filter == CustomKillFeed.STR_FILTER_EVERYONE end,
				default = true,
			},
			[4] = {
				type = "checkbox",
				name = GetString(SI_BUGCATEGORY1).." "..GetString(SI_JOURNAL_PROGRESS_SUMMARY),       
				getFunc = function() return CustomKillFeed.vars.combatSummary end,
				setFunc = function(value)  CustomKillFeed.vars.combatSummary = value end,
				default = false,
			},
			[5] = {
			    type = "header",
				name = CustomKillFeed.STR_FILTER_GUILD,
				disabled = function() return CustomKillFeed.vars.filter ~= CustomKillFeed.STR_FILTER_GUILD end,
			},
	    }
		
        for i = 1, GetNumGuilds() do
			controlData[i+5] = {
				type = "checkbox",
				name = function() return "|c"..CustomKillFeed.getGuildColor(i)..GetGuildName(GetGuildId(i)).."|r" end,       
				getFunc = function() CustomKillFeed.vars.guilds = CustomKillFeed.vars.guilds or {} return CustomKillFeed.vars.guilds[i] or false end,
				setFunc = function(value) CustomKillFeed.vars.guilds = CustomKillFeed.vars.guilds or {} CustomKillFeed.vars.guilds[i] = value end,
				default = false,
				disabled = function() return CustomKillFeed.vars.filter ~= CustomKillFeed.STR_FILTER_GUILD end,
			}
        end
		
		return controlData
end	


function CustomKillFeed.CreateConfiguration()
	
	local LAM = LibAddonMenu2
	

	local panelData = {
		type = "panel",
		name = CustomKillFeed.name,
		author = "|c3CB371@Masteroshi430|r",
		version = CustomKillFeed.version,
		registerForDefaults = true,
		registerForRefresh = true,
	}

	LAM:RegisterAddonPanel(CustomKillFeed.name.."Config", panelData)

	local controlData = CustomKillFeed.CreateGuildsCheckboxes()

    LAM:RegisterOptionControls(CustomKillFeed.name.."Config", controlData)

end

function CustomKillFeed.getGuildColor(guildIndex)

	if pChat and not pChat.db.useESOcolors then  -- use pChat colors when available
	    local HEX
		if guildIndex == 1 then
			   HEX = pChat.db.colours[24] 
		elseif guildIndex == 2 then
			   HEX = pChat.db.colours[26] 
		elseif guildIndex == 3 then
			   HEX = pChat.db.colours[28]  
		elseif guildIndex == 4 then
			   HEX = pChat.db.colours[30]
		elseif guildIndex == 5 then
			   HEX = pChat.db.colours[32] 
	    end	
		HEX = string.sub(HEX, 3)
		return HEX  
	end
	
	local chatCategory -- if no pChat get ESO colors 
	if guildIndex == 1 then
	      chatCategory = CHAT_CATEGORY_GUILD_1 
	elseif guildIndex == 2 then
	      chatCategory = CHAT_CATEGORY_GUILD_2
	elseif guildIndex == 3 then
	      chatCategory = CHAT_CATEGORY_GUILD_3  
	elseif guildIndex == 4 then
	      chatCategory = CHAT_CATEGORY_GUILD_4 
	elseif guildIndex == 5 then
	      chatCategory = CHAT_CATEGORY_GUILD_5 
	end
    
	local guildColorR, guildColorG, guildColorB = GetChatCategoryColor(chatCategory)
	local guildColorDef = ZO_ColorDef:New(guildColorR, guildColorG, guildColorB, 1)
	local hexColor = guildColorDef:ToHex()
	
    return hexColor 
end

function CustomKillFeed.getGuildIcons(displayName)
	local guildIconsString = ""
	for i = 1, GetNumGuilds() do
		local isInGuild = GetGuildMemberIndexFromDisplayName(GetGuildId(i), displayName)
			if isInGuild then
				 local hexColor, guildColorDef = CustomKillFeed.getGuildColor(i)
				 guildIconsString = guildIconsString.."|c"..hexColor..zo_iconTextFormatNoSpace("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_guilds.dds",24,24,"",guildColorDef).."|r" 
			end		
	end
	
	return guildIconsString
end


local g_pvpKillFeedDeathRecurrenceTracker = nil
do
    -- The PvP Kill Feed uses ZO_RecurrenceTracker to track whether any given
    -- killer/victim message has been shown within the last 10 seconds from a
    -- given source (local vs. kill location). Note that the instance count
    -- tracked by ZO_RecurrenceTracker is irrelevant here for the purpose of
    -- the kill feed.
    local EXPIRATION_MS = 10000 -- 10 seconds
    local EXTENSION_MS = 10000 -- 10 seconds
    g_pvpKillFeedDeathRecurrenceTracker = ZO_RecurrenceTracker:New(EXPIRATION_MS, EXTENSION_MS)
end





function CustomKillFeed.go(_, killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank, victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)
        local showKillFeedNotifications = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SHOW_PVP_KILL_FEED_NOTIFICATIONS)
         if showKillFeedNotifications then
		    d("You currently see ZOS's kill feed, turn it off in the game options to enable the awesome CustomKillFeed addon." )
            return 
         end
		 
        -- ZOS' spam filter
        local messageKeySuffix = string.format("%s___%s", killerDisplayName, victimDisplayName)
        local messageKeyLocal = "L" .. messageKeySuffix
        local messageKeyKillLocation = "B" .. messageKeySuffix
        if isKillLocation then
            -- This message was kill location sourced.
            if g_pvpKillFeedDeathRecurrenceTracker:RemoveValue(messageKeyLocal) ~= nil then
                -- The same message was already shown as a result of a local message;
                -- remove the original message from the tracker and suppress this message.
                return
            end
            -- Track this kill location sourced message.
            g_pvpKillFeedDeathRecurrenceTracker:AddValue(messageKeyKillLocation)
        else
            -- This message was locally sourced.
            if g_pvpKillFeedDeathRecurrenceTracker:RemoveValue(messageKeyKillLocation) ~= nil then
                -- The same message was already shown as a result of a kill location message;
                -- remove the original message from the tracker and suppress this message.
                return
            end
            -- Track this locally sourced message.
            g_pvpKillFeedDeathRecurrenceTracker:AddValue(messageKeyLocal)
        end
		
		
		 local ICON_SIZE = 24
		 local killerGuildIcon = ""
		 local victimGuildIcon = ""
		 local yourDisplayname = CustomKillFeed.yourDisplayname
		 if not yourDisplayname then
		     -- Safety net: should already be cached from OnAddonLoaded, but fetch and
		     -- cache it here too rather than silently breaking the "Player" filter for
		     -- the whole session if it was ever missing.
		     yourDisplayname = GetUnitDisplayName("player")
		     CustomKillFeed.yourDisplayname = yourDisplayname
		 end
         local isBattleground = IsActiveWorldBattleground()
		 -- let's filter that kill feed!
		 if CustomKillFeed.vars.filter == CustomKillFeed.STR_FILTER_EVERYONE or isBattleground then
		     -- ZOS' regular kill feed spam!
			 
			 local yourAlliance = GetUnitBattlegroundAlliance("player")
			 if CustomKillFeed.vars.displayDeaths and not CustomKillFeed.vars.displayKills and victimAlliance ~= yourAlliance then
			     return
			 elseif CustomKillFeed.vars.displayKills and not CustomKillFeed.vars.displayDeaths and killerAlliance ~= yourAlliance  then	
			     return
			 end
			 
			 
		 elseif CustomKillFeed.vars.filter == CustomKillFeed.STR_FILTER_PLAYER then 
               if killerDisplayName ~= yourDisplayname and victimDisplayName ~= yourDisplayname then
			       return
               elseif not CustomKillFeed.vars.displayKills and killerDisplayName == yourDisplayname then
			       return
			   elseif not CustomKillFeed.vars.displayDeaths and victimDisplayName == yourDisplayname then
			       return   
			   end			   
		 elseif CustomKillFeed.vars.filter == CustomKillFeed.STR_FILTER_GROUP then
		        local killerIsInGroup = IsPlayerInGroup(killerDisplayName)
				local victimIsInGroup = IsPlayerInGroup(victimDisplayName)
		        if not killerIsInGroup and not victimIsInGroup then
				    return
                elseif not CustomKillFeed.vars.displayKills and killerIsInGroup then
			        return
			    elseif not CustomKillFeed.vars.displayDeaths and victimIsInGroup then
			        return 	
                end	
		 elseif CustomKillFeed.vars.filter == CustomKillFeed.STR_FILTER_GUILD then
		 
		        if not IsGuildMate(killerDisplayName) and not IsGuildMate(victimDisplayName) then
	               return 
	            end
				
		        local gotOne
				CustomKillFeed.vars.guilds = CustomKillFeed.vars.guilds or {}
				for i = 1, GetNumGuilds() do
					if CustomKillFeed.vars.guilds[i] then
						local guildId = GetGuildId(i)
						local killerIsInGuild = GetGuildMemberIndexFromDisplayName(guildId, killerDisplayName)
						local victimIsInGuild = GetGuildMemberIndexFromDisplayName(guildId, victimDisplayName)
						if killerIsInGuild or victimIsInGuild then
						
						    if killerIsInGuild and CustomKillFeed.vars.displayKills then
						        gotOne = true
							elseif victimIsInGuild and CustomKillFeed.vars.displayDeaths then
							    gotOne = true
							end  
							
							-- this was tested to show guild icons with guild chat colors if killer/victim is guildie but it is ugly because of too much spacing between icons
							-- local hexColor = CustomKillFeed.getGuildColor(i)
							-- if killerIsInGuild and killerDisplayName ~= yourDisplayname then 
							    -- killerGuildIcon = "|c"..hexColor..zo_iconFormatInheritColor("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_guilds.dds",24,24).."|r"
							-- end	
							-- if victimIsInGuild and victimDisplayName ~= yourDisplayname then
                                -- victimGuildIcon = "|c"..hexColor..zo_iconFormatInheritColor("/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_guilds.dds",24,24).."|r"     						
							-- end	
                        end					
                    end
				end
				
				if not gotOne then
				    return
				end
		 else -- just in case
		     return
		 end

        
        local killerAllianceColor
        local victimAllianceColor
        if isBattleground then
            killerAllianceColor = GetBattlegroundAllianceColor(killerAlliance):GetBright()
            victimAllianceColor = GetBattlegroundAllianceColor(victimAlliance):GetBright()
        else
            killerAllianceColor = GetAllianceColor(killerAlliance):GetBright()
            victimAllianceColor = GetAllianceColor(victimAlliance):GetBright()
        end


        local emperorIcon = "/esoui/art/campaign/overview_indexicon_emperor_up.dds"

        local killerIcon
        local victimIcon
        if isBattleground then
            killerIcon = ZO_GetBattlegroundIconMarkup(killerAlliance, ICON_SIZE)
            victimIcon = ZO_GetBattlegroundIconMarkup(victimAlliance, ICON_SIZE)
        else
			local killerIsEmperor = false
			local victimIsEmperor = false
			local _,_, emperorDisplayName = GetCampaignEmperorInfo(GetCurrentCampaignId()) or ""
			if emperorDisplayName == killerDisplayName then
			     killerIsEmperor = true
			elseif emperorDisplayName == victimDisplayName then
			     victimIsEmperor = true
			end

			if killerIsEmperor then 
				 killerIcon = zo_iconTextFormatNoSpace(emperorIcon,ICON_SIZE,ICON_SIZE,"")
			else
				 killerIcon = ZO_GetColoredAvARankIconMarkup(killerRank, killerAlliance, ICON_SIZE)
			end
			if victimIsEmperor then 
				 victimIcon = zo_iconTextFormatNoSpace(emperorIcon,ICON_SIZE,ICON_SIZE,"")
			else
				 victimIcon = ZO_GetColoredAvARankIconMarkup(victimRank, victimAlliance, ICON_SIZE)
			end
        end

        -- Alliance names, genders, and rank names below are only needed by the narration
        -- feature, which isn't enabled yet (see "will look later if narration is doable"
        -- further down). Computing them here means every displayed kill message pays for
        -- 6 extra API calls for a value nothing currently reads. Left commented out until
        -- narration ships; re-enable alongside the narration lines below.
        --
        -- local killerAllianceName
        -- local victimAllianceName
        -- if isBattleground then
        --     killerAllianceName = GetString("SI_BATTLEGROUNDALLIANCE", killerAlliance)
        --     victimAllianceName = GetString("SI_BATTLEGROUNDALLIANCE", victimAlliance)
        -- else
        --     killerAllianceName = ZO_CachedStrFormat(SI_ALLIANCE_NAME, GetAllianceName(killerAlliance))
        --     victimAllianceName = ZO_CachedStrFormat(SI_ALLIANCE_NAME, GetAllianceName(victimAlliance))
        -- end

		
        local killerName = ""
        local victimName = ""
		
		if killerDisplayName == yourDisplayname then
		    killerName = zo_iconTextFormatNoSpace("esoui/art/battlegrounds/battlegrounds_scoretracker_playerteamindicator.dds",ICON_SIZE,ICON_SIZE,"")..GetString(SI_BATTLEGROUND_YOU)
		else
            killerName = ZO_LinkHandler_CreateLinkWithoutBrackets(killerDisplayName, nil, "display", killerDisplayName)
        end	

		if victimDisplayName == yourDisplayname then
		    victimName = zo_iconTextFormatNoSpace("esoui/art/battlegrounds/battlegrounds_scoretracker_playerteamindicator.dds",ICON_SIZE,ICON_SIZE,"")..GetString(SI_BATTLEGROUND_YOU)
		else
            victimName = ZO_LinkHandler_CreateLinkWithoutBrackets(victimDisplayName, nil, "display", victimDisplayName)
        end			

        -- local killerGender = GetGenderFromNameDescriptor(killerCharacterName)
        -- local victimGender = GetGenderFromNameDescriptor(victimCharacterName)
        -- local killerRankName = GetAvARankName(killerGender, killerRank)
        -- local victimRankName = GetAvARankName(victimGender, victimRank)

        local hasLocation = killLocation and killLocation ~= ""
        -- local messageStringId = hasLocation and SI_PVP_KILL_FEED_DEATH_AND_LOCATION or SI_PVP_KILL_FEED_DEATH
		
		local deathIcon = "/esoui/art/treeicons/gamepad/gp_tutorial_idexicon_death.dds"
		
		if hasLocation then
		   killLocation = ZO_WHITE:Colorize("@"..killLocation)
		end
		
		local message = killerAllianceColor:Colorize(killerName)..killerIcon..killerGuildIcon..zo_iconTextFormatNoSpace(deathIcon,ICON_SIZE,ICON_SIZE,"")..victimAllianceColor:Colorize(victimName)..victimIcon..victimGuildIcon..killLocation
        
		-- after combat summary 
        if not isBattleground and CustomKillFeed.vars.combatSummary and IsUnitInCombat("player") and not IsUnitDead("player") then
		
		   CustomKillFeed.summary = CustomKillFeed.summary or {}
		   CustomKillFeed.summary[killerName] = CustomKillFeed.summary[killerName] or {}
		   CustomKillFeed.summary[killerName].message = message
		   CustomKillFeed.summary[killerName].display = killerAllianceColor:Colorize(killerName)..killerIcon..killerGuildIcon..zo_iconTextFormatNoSpace(deathIcon,ICON_SIZE,ICON_SIZE,"")
		   CustomKillFeed.summary[killerName].lastLocation = killLocation
		   if CustomKillFeed.summary[killerName][victimAlliance] then
		       CustomKillFeed.summary[killerName][victimAlliance] = CustomKillFeed.summary[killerName][victimAlliance] + 1
		   else
		       CustomKillFeed.summary[killerName][victimAlliance] = 1 
		   end
		
		   return
        end	
		
		-- will look later if narration is doable 
        --local narrationStringId = hasLocation and SI_PVP_KILL_FEED_DEATH_AND_LOCATION_NARRATION or SI_PVP_KILL_FEED_DEATH_NARRATION
        --local narrationMessage = zo_strformat(narrationStringId, killerAllianceName, killerRankName, killerName, victimAllianceName, victimRankName, victimName, killLocation)

 		d(message) 
end

function CustomKillFeed.summaryMessage()
     if not CustomKillFeed.summary or NonContiguousCount(CustomKillFeed.summary) == 0 then return end 
	 
	 local message = ZO_WHITE:Colorize(GetString(SI_BUGCATEGORY1).." "..GetString(SI_JOURNAL_PROGRESS_SUMMARY)..":")
	 
     for killer, data in pairs(CustomKillFeed.summary) do
	    local ep = data[2] or 0
	    local ad = data[1] or 0
		local dc = data[3] or 0
	 
	    if  (ep + ad + dc) < 2 then
		     message = message.."\n"..data.message
			 CustomKillFeed.summary[killer] = nil
	    else
		    local EPmessage = ""
			local DCmessage = ""
            local ADmessage = "" 	
            
			if ep ~= 0 then
			   EPmessage =  ZO_WHITE:Colorize(zo_iconTextFormatNoSpaceAlignedRight("/esoui/art/ava/ava_hud_emblem_ebonheart.dds",24,24,ep))
			end
			
			if dc ~= 0 then
			    DCmessage =  ZO_WHITE:Colorize(zo_iconTextFormatNoSpaceAlignedRight("/esoui/art/ava/ava_hud_emblem_daggerfall.dds",24,24,dc))
			end
			
			if ad ~= 0 then
			   ADmessage =  ZO_WHITE:Colorize(zo_iconTextFormatNoSpaceAlignedRight("/esoui/art/ava/ava_hud_emblem_aldmeri.dds",24,24,ad))
			end
			
			local sumMessage = data.display..EPmessage..DCmessage..ADmessage..data.lastLocation
			message = message.."\n"..sumMessage
			CustomKillFeed.summary[killer] = nil
		end
	 
     end
	 d(message)
end

local function OnAddonLoaded(event, addonName)
	if addonName == CustomKillFeed.name then
       CustomKillFeed.vars = ZO_SavedVars:NewAccountWide("CKFVars", 2, nil, CustomKillFeed.defaults)
       CustomKillFeed.yourDisplayname = GetUnitDisplayName("player")
       CustomKillFeed.CreateConfiguration()
       EVENT_MANAGER:RegisterForEvent(CustomKillFeed.name, EVENT_PVP_KILL_FEED_DEATH, CustomKillFeed.go)
	   EVENT_MANAGER:RegisterForEvent(CustomKillFeed.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat) if CustomKillFeed.vars.combatSummary and not inCombat then CustomKillFeed.summaryMessage() end end )
	   EVENT_MANAGER:RegisterForEvent(CustomKillFeed.name, EVENT_PLAYER_DEAD, function() if CustomKillFeed.vars.combatSummary then CustomKillFeed.summaryMessage() end end )
	end
end	


EVENT_MANAGER:RegisterForEvent(CustomKillFeed.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)






