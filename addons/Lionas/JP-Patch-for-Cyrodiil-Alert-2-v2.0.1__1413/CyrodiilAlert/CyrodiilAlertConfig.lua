local LAM = LibStub("LibAddonMenu-2.0")

function CA.CreateConfigMenu()

    local panelData = {
        type                = "panel",
        name                = CA.name,
        displayName         = CA.colOng:Colorize(GetString(SI_CYRODIIL_ALERT_DISPLAY_NAME)),
        author              = "Tanthul, Enodoc",
        version             = CA.version,
        slashCommand        = nil,
        registerForRefresh  = true,
        registerForDefaults = true,
    }
	local ConfigPanel = LAM:RegisterAddonPanel(CA.name .. GetString(SI_CYRODIIL_ALERT_CONFIG), panelData)

	local ConfigData = {
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_GENERAL_OPTIONS)),
		},
		{
			type = "slider",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_DELAY_TOOLTIP),
			min = 3,
			max = 10,
			step = 1,
			getFunc = function() return CA.vars.notifyDelay end,
			setFunc = function(newValue) CA.vars.notifyDelay = newValue end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_TOOLTIP),
			getFunc = function() return CA.vars.chatOutput end,
			setFunc = function(newValue) CA.vars.chatOutput = newValue end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_TOOLTIP),
			choices = {GetString(SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_DISABLED), "ESO UI", "CA UI"},
			getFunc = function() return CA.vars.chooseUI end,
			setFunc = function(value)
				if value == GetString(SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_DISABLED) then
					CA.vars.onlyChat = true
					CA.vars.chooseUI = value
				else
					CA.vars.onlyChat = false
					CA.vars.chooseUI = value
				end
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SOUND_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SOUND_TOOLTIP),
			getFunc = function() return CA.vars.sound end,
			setFunc = function(newValue) CA.vars.sound = newValue;  end,
			disabled = function() return CA.vars.chooseUI ~= "ESO UI" end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_INSIDE_IC_TOOLTIP),
			getFunc = function() return CA.vars.inside end,
			setFunc = function(newValue) CA.vars.inside = newValue;  end,
			disabled = function() return not IsCollectibleUnlocked(GetImperialCityCollectibleId()) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_NOTIFICATION_OUTSIDE_CY_TOOLTIP),
			getFunc = function() return CA.vars.outside end,
			setFunc = function(newValue) CA.vars.outside = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.vanillaAvA end,
			setFunc = function(newValue) CA.vars.vanillaAvA = newValue;  end,
			warning = "Overrides individual settings for these notifications when OFF",
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OUTSIDE_CY_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_DISABLE_DEFAULT_NOTIFICATION_OUTSIDE_CY_TOOLTIP),
			getFunc = function() return CA.vars.vanillaOutside end,
			setFunc = function(newValue) CA.vars.vanillaOutside = newValue;  end,
			disabled = function() return ((not CA.vars.vanillaAvA) or (CA.vars.outside)) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_REDIRECT_DEFAULT_NOTIFICATION_TO_CHAT_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_REDIRECT_DEFAULT_NOTIFICATION_TO_CHAT_TOOLTIP),
			getFunc = function() return CA.vars.vanillaChat end,
			setFunc = function(newValue) CA.vars.vanillaChat = newValue;  end,
			disabled = function() return not CA.vars.vanillaAvA end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_MESSAGE_TOOLTIP),
			getFunc = function() return CA.vars.showInit end,
			setFunc = function(newValue) CA.vars.showInit = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_TOOLTIP) .. CA.colAld:Colorize(GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_AD_NAME)) ..", " .. CA.colDag:Colorize(GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_DC_NAME)) .. ", " .. CA.colEbo:Colorize(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_EP_NAME),
			getFunc = function() return CA.vars.allianceColors end,
			setFunc = function(newValue) CA.vars.allianceColors = newValue;  end,
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_LOCK_UNLOCK_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_LOCK_UNLOCK_TOOLTIP),
			func = function() CA.Movable() end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_KEEP_STATUS)),
		},
		{
			type = "description",
			title = GetString(SI_CYRODIIL_ALERT_REINITIALIZE_TITLE),
			text = GetString(SI_CYRODIIL_ALERT_REINITIALIZE_TEXT),
			disabled = function() return not IsInCampaign() end,
			width = "half",
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_UPDATE_STATUS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_UPDATE_STATUS_TOOLTIP),
			func = function()
				if (IsInCampaign()) then
					if (CA.currentId ~= GetCurrentCampaignId()) then
--						d("CA Debug: In AvA, Button Update, New Campaign ID")
						CA.currentId = GetCurrentCampaignId()
						CA.campaignId = GetCurrentCampaignId()
						CA.campaignName = GetCampaignName(CA.campaignId)
						myAlliance = GetUnitAlliance("player")
					elseif (CA.currentId == GetCurrentCampaignId()) then
--						d("CA Debug: In AvA, Button Update, Same Campaign ID")
					end
				elseif (not IsInCampaign()) then
					if (CA.currentId ~= GetCurrentCampaignId()) then
--						d("CA Debug: Not AvA, Button Update, New Campaign ID")
						CA.currentId = GetCurrentCampaignId()
						CA.campaignId = GetAssignedCampaignId()
						CA.campaignName = GetCampaignName(CA.campaignId)
						myAlliance = GetUnitAlliance("player")
					elseif (CA.currentId == GetCurrentCampaignId()) then
--						d("CA Debug: Not AvA, Button Update, Same Campaign ID")
					end
				end
				return CA.InitKeeps() end,
			warning = GetString(SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING),
			width = "half"
		},
		{
			type = "description",
			title = GetString(SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TITLE),
			text = GetString(SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TEXT),
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_LIST_ATTACKS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_LIST_ATTACKS_TOOLTIP),
			func = function() CA.vars.dumpAttack = true return CA.dumpChat() end,
			warning = GetString(SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING),
			width = "half"
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_LIST_STATUS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_LIST_STATUS_TOOLTIP),
			func = function() CA.vars.dumpAttack = false return CA.dumpChat() end,
			warning = GetString(SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING),
			width = "half",
		},
		{
			type = "description",
			title = GetString(SI_CYRODIIL_ALERT_IMPERIAL_CITY_TITLE),
			text = GetString(SI_CYRODIIL_ALERT_IMPERIAL_CITY_TEXT),
			width = "half",
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_TOOLTIP),
			func = function() CA.vars.dumpAttack = true return CA.dumpImperial() end,
			warning = GetString(SI_CYRODIIL_ALERT_DUBIOUS_OUTSIDE_CY_WARNING),
			width = "half",
		},	
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OPTIONS_NAME)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showOwnerChanged end,
			setFunc = function(newValue) CA.vars.showOwnerChanged = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.keepCapture end,
			setFunc = function(value)
				CA.vars.keepCapture = value
			end,
			disabled = function() return (not CA.vars.showOwnerChanged or CA.vars.chooseUI ~= "ESO UI") end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_ATTACK_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showAttack end,
			setFunc = function(newValue) CA.vars.showAttack = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_DEFENCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_DEFENCE_TOOLTIP),
			getFunc = function() return CA.vars.siegesAttDef end,
			setFunc = function(newValue) CA.vars.siegesAttDef = newValue;  end,
			disabled = function() return not CA.vars.showAttack end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_SIEGES_BY_ALLIANCE_TOOLTIP),
			getFunc = function() return CA.vars.siegesByAlliance end,
			setFunc = function(newValue) CA.vars.siegesByAlliance = newValue;  end,
			disabled = function() return not CA.vars.showAttack end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_ATTACK_ENDING_NOTIFICATIONS_TOOLTIP),
			getFunc = function() return CA.vars.showAttackEnd end,
			setFunc = function(newValue) CA.vars.showAttackEnd = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showClaim end,
			setFunc = function(newValue) CA.vars.showClaim = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showEmperors end,
			setFunc = function(newValue) CA.vars.showEmperors = newValue;  end,
			disabled = function() return not CA.vars.vanillaAvA end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_IC_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showImperial end,
			setFunc = function(newValue) CA.vars.showImperial = newValue;  end,
			disabled = function() return not CA.vars.vanillaAvA end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showQueue end,
			setFunc = function(newValue) CA.vars.showQueue = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_NAME),
			tooltip = zo_strformat(GetString(SI_CYRODIIL_ALERT_SHOW_ONLY_MY_ALLIANCE_TOOLTIP), GetAllianceName(GetUnitAlliance("player"))),
			getFunc = function() return CA.vars.onlyMyAlliance end,
			setFunc = function(newValue) CA.vars.onlyMyAlliance = newValue;  end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_OBJECTIVE_OPTIONS_NAME)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showTowns end,
			setFunc = function(newValue) CA.vars.showTowns = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showDistricts end,
			setFunc = function(newValue) CA.vars.showDistricts = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_DISTRICT_CAPTURE_IN_CY_TOOLTIP),
			getFunc = function() return CA.vars.showDistrictsOut end,
			setFunc = function(newValue) CA.vars.showDistrictsOut = newValue;  end,
			disabled = function() return not CA.vars.showDistricts  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_TOOLTIP),
			getFunc = function() return CA.vars.showTelvar end,
			setFunc = function(newValue) CA.vars.showTelvar = newValue;  end,
			disabled = function() return not CA.vars.showDistricts  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_INDIVIUAL_FLAG_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showFlags end,
			setFunc = function(newValue) CA.vars.showFlags = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsResources end,
			setFunc = function(newValue) CA.vars.showFlagsResources = newValue;  end,
			disabled = function() return not CA.vars.showFlags end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsTowns end,
			setFunc = function(newValue) CA.vars.showFlagsTowns = newValue;  end,
			disabled = function() return ((not CA.vars.showFlags) or (not CA.vars.showTowns))  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsDistricts end,
			setFunc = function(newValue) CA.vars.showFlagsDistricts = newValue;  end,
			disabled = function() return ((not CA.vars.showFlags) or (not CA.vars.showDistricts))  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_NAME),
			tooltip = zo_strformat(GetString(SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_TOOLTIP), CA.colGrn:Colorize("No Control")),
			getFunc = function() return CA.vars.showFlagsNeutral end,
			setFunc = function(newValue) CA.vars.showFlagsNeutral = newValue;  end,
			disabled = function() return not CA.vars.showFlags end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showGates end,
			setFunc = function(newValue) CA.vars.showGates = newValue;  end,
			disabled = function() return not CA.vars.vanillaAvA end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showScrolls end,
			setFunc = function(newValue) CA.vars.showScrolls = newValue;  end,
			disabled = function() return not CA.vars.vanillaAvA end,
		},
		{
			type = "description",
			text = "\nVersion |c60FF60" .. CA.version .. "|r by @Enodoc, Savant of the United Explorers of Scholarly Pursuits (UESP)\nUESP: The Unofficial Elder Scrolls Pages - A collaborative source for all knowledge on the Elder Scrolls series since 1995. Find us at www.uesp.net\n\nVersions prior to 1.0.0 by @Tanthul, Leader of the Dark Moon PVP Guild operating on the EU Scourge campaign. (AKA Nodens)\n\nAll rights reserved.",
		},
	}
	LAM:RegisterOptionControls(CA.name..GetString(SI_CYRODIIL_ALERT_CONFIG), ConfigData)

	
end -- CA.CreateConfigMenu

