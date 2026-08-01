local LAM = LibAddonMenu2

function CA.CreateConfigMenu()

    local panelData = {
        type                = "panel",
        name                = CA.name,
        displayName         = CA.colOng:Colorize(GetString(SI_CYRODIIL_ALERT_DISPLAY_NAME)),
        author              = "Tanthul, Enodoc, Lionas [ライオナス], Scootworks",
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
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ON_SCREEN_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.notifOutput end,
			setFunc = function(newValue) CA.vars.notifOutput = newValue end,
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
			disabled = function() return (not CA.vars.notifOutput) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SOUND_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SOUND_TOOLTIP),
			getFunc = function() return CA.vars.sound end,
			setFunc = function(newValue) CA.vars.sound = newValue;  end,
			disabled = function() return (not CA.vars.notifOutput) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OUTPUT_CHAT_TOOLTIP),
			getFunc = function() return CA.vars.chatOutput end,
			setFunc = function(newValue) CA.vars.chatOutput = newValue end,
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
			name = GetString(SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_KEEPS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_REDIRECT_SHOW_INIT_KEEPS_TOOLTIP),
			getFunc = function() return CA.vars.showInitUIKeeps end,
			setFunc = function(newValue) CA.vars.showInitUIKeeps = newValue;  end,
			disabled = function() return (not CA.vars.showInit) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_TOOLTIP) .. CA.colAld:Colorize(GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_AD_NAME)) ..", " .. CA.colDag:Colorize(GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_DC_NAME)) .. ", " .. CA.colEbo:Colorize(GetString(SI_CYRODIIL_ALERT_USE_ALLIANCE_COLORS_EP_NAME)),
			getFunc = function() return CA.vars.allianceColors end,
			setFunc = function(newValue) CA.vars.allianceColors = newValue;  end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_QUEUE_OPTIONS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_QUEUE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showQueue end,
			setFunc = function(newValue) CA.vars.showQueue = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_QUEUE_READY_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_QUEUE_READY_TOOLTIP),
			choices = {"Major", "Minor", "Off"},
			getFunc = function() return CA.vars.queueReady end,
			setFunc = function(value)
				CA.vars.queueReady = value
			end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_QUEUE_ACCEPT_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_QUEUE_ACCEPT_TOOLTIP),
			getFunc = function() return CA.vars.queueAccept end,
			setFunc = function(newValue) CA.vars.queueAccept = newValue;  end,
		},
		{
			type = "slider",
			name = GetString(SI_CYRODIIL_ALERT_QUEUE_ACCEPT_DELAY_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_QUEUE_ACCEPT_DELAY_TOOLTIP),
			min = 5,
			max = 50,
			step = 1,
			getFunc = function() return CA.vars.queueDelay end,
			setFunc = function(newValue) CA.vars.queueDelay = newValue end,
			disabled = function() return not CA.vars.queueAccept end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_CAMPAIGN_OPTIONS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_EMPEROR_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showEmperors end,
			setFunc = function(newValue) CA.vars.showEmperors = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_EMPEROR_OUT_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_EMPEROR_OUT_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showEmperorsOutside end,
			setFunc = function(newValue) CA.vars.showEmperorsOutside = newValue;  end,
			disabled = function() return not CA.vars.showEmperors end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_GATE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showGates end,
			setFunc = function(newValue) CA.vars.showGates = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_GATE_OUT_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_GATE_OUT_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showGatesOutside end,
			setFunc = function(newValue) CA.vars.showGatesOutside = newValue;  end,
			disabled = function() return not CA.vars.showGates end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_SCROLL_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showScrolls end,
			setFunc = function(newValue) CA.vars.showScrolls = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_SCROLL_OUT_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_SCROLL_OUT_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showScrollsOutside end,
			setFunc = function(newValue) CA.vars.showScrollsOutside = newValue;  end,
			disabled = function() return not CA.vars.showScrolls end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_SCORE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_SCORE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showScore end,
			setFunc = function(newValue) CA.vars.showScore = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_UNDERPOP_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_UNDERPOP_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showUnderpop end,
			setFunc = function(newValue) CA.vars.showUnderpop = newValue;  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_CLAIM_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showClaim end,
			setFunc = function(newValue) CA.vars.showClaim = newValue;  end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_NOTIFICATION_OPTIONS_NAME)),
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
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_ALLIANCE_OWNER_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showOwnerChanged end,
			setFunc = function(newValue) CA.vars.showOwnerChanged = newValue;  end,
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
			name = GetString(SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_NAME),
			tooltip = zo_strformat(GetString(SI_CYRODIIL_ALERT_SHOW_FLAGS_AS_NEUTRAL_TOOLTIP), CA.colGrn:Colorize("No Control")),
			getFunc = function() return CA.vars.showFlagsNeutral end,
			setFunc = function(newValue) CA.vars.showFlagsNeutral = newValue;  end,
			disabled = function() return not CA.vars.showFlags end,
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
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_KEEP_OPTIONS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_KEEP_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_KEEP_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showKeeps end,
			setFunc = function(newValue) CA.vars.showKeeps = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.keepAttack end,
			setFunc = function(value)
				CA.vars.keepAttack = value
			end,
			disabled = function() return (not CA.vars.showAttack or not CA.vars.showKeeps) end,
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
			disabled = function() return (not CA.vars.showOwnerChanged or not CA.vars.showKeeps) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_KEEP_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_KEEP_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsKeeps end,
			setFunc = function(newValue) CA.vars.showFlagsKeeps = newValue;  end,
			disabled = function() return (not CA.vars.showFlags or not CA.vars.showKeeps) end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_OUTPOST_OPTIONS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_OUTPOST_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_OUTPOST_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showOutposts end,
			setFunc = function(newValue) CA.vars.showOutposts = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.outpostAttack end,
			setFunc = function(value)
				CA.vars.outpostAttack = value
			end,
			disabled = function() return (not CA.vars.showAttack or not CA.vars.showOutposts) end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.outpostCapture end,
			setFunc = function(value)
				CA.vars.outpostCapture = value
			end,
			disabled = function() return (not CA.vars.showOwnerChanged or not CA.vars.showOutposts) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_OUTPOST_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_OUTPOST_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsOutposts end,
			setFunc = function(newValue) CA.vars.showFlagsOutposts = newValue;  end,
			disabled = function() return (not CA.vars.showFlags or not CA.vars.showOutposts) end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_RESOURCE_OPTIONS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_RESOURCE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_RESOURCE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showResources end,
			setFunc = function(newValue) CA.vars.showResources = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.resourceAttack end,
			setFunc = function(value)
				CA.vars.resourceAttack = value
			end,
			disabled = function() return (not CA.vars.showAttack or not CA.vars.showResources) end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.resourceCapture end,
			setFunc = function(value)
				CA.vars.resourceCapture = value
			end,
			disabled = function() return (not CA.vars.showOwnerChanged or not CA.vars.showResources) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_RESOURCE_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsResources end,
			setFunc = function(newValue) CA.vars.showFlagsResources = newValue;  end,
			disabled = function() return (not CA.vars.showFlags or not CA.vars.showResources) end,
		},
--		{
--			type = "checkbox",
--			name = GetString(SI_CYRODIIL_ALERT_RESOURCE_UPDATES_NAME),
--			tooltip = GetString(SI_CYRODIIL_ALERT_RESOURCE_UPDATES_TOOLTIP),
--			getFunc = function() return CA.vars.showResourceUpdates end,
--			setFunc = function(newValue) CA.vars.showResourceUpdates = newValue;  end,
--		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_TOWN_OPTIONS)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_TOWN_CAPTURE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showTowns end,
			setFunc = function(newValue) CA.vars.showTowns = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.townAttack end,
			setFunc = function(value)
				CA.vars.townAttack = value
			end,
			disabled = function() return (not CA.vars.showAttack or not CA.vars.showTowns) end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.townCapture end,
			setFunc = function(value)
				CA.vars.townCapture = value
			end,
			disabled = function() return (not CA.vars.showOwnerChanged or not CA.vars.showTowns) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_TOWN_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsTowns end,
			setFunc = function(newValue) CA.vars.showFlagsTowns = newValue;  end,
			disabled = function() return (not CA.vars.showFlags or not CA.vars.showTowns)  end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_OBJECTIVE_OPTIONS_NAME)),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_BRIDGES_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_BRIDGES_TOOLTIP),
			getFunc = function() return CA.vars.showBridges end,
			setFunc = function(newValue) CA.vars.showBridges = newValue;  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME_INDENTED),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.bridgeAttack end,
			setFunc = function(value)
				CA.vars.bridgeAttack = value
			end,
			disabled = function() return (not CA.vars.showBridges) end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_BRIDGES_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_BRIDGES_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.bridgePassable end,
			setFunc = function(value)
				CA.vars.bridgePassable = value
			end,
			disabled = function() return (not CA.vars.showBridges) end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_DAEDRIC_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_DAEDRIC_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showDaedric end,
			setFunc = function(newValue) CA.vars.showDaedric = newValue;  end,
		},
		{
			type = "header",
			name = GetString(SI_CYRODIIL_ALERT_IMPERIAL_CITY_TITLE),
		},
		{
			type = "description",
			text = GetString(SI_CYRODIIL_ALERT_IMPERIAL_CITY_STATUS),
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ENABLE_DISTRICT_CAPTURE_NOTIFICATION_TOOLTIP),
			getFunc = function() return CA.vars.showDistricts end,
			setFunc = function(newValue) CA.vars.showDistricts = newValue;  end,
			disabled = function() return not CA.ICUnlocked end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_TEL_VAR_CAPTURE_BONUS_TOOLTIP),
			getFunc = function() return CA.vars.showTelvar end,
			setFunc = function(newValue) CA.vars.showTelvar = newValue;  end,
			disabled = function() return not CA.vars.showDistricts or not CA.ICUnlocked  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ATTACK_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.districtAttack end,
			setFunc = function(value)
				CA.vars.districtAttack = value
			end,
			disabled = function() return (not CA.vars.showAttack or not CA.vars.showDistricts) or not CA.ICUnlocked  end,
		},
		{
			type = "dropdown",
			name = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_NOTIFICATION_IMPORTANCE_TOOLTIP),
			choices = {"Major", "Minor"},
			getFunc = function() return CA.vars.districtCapture end,
			setFunc = function(value)
				CA.vars.districtCapture = value
			end,
			disabled = function() return (not CA.vars.showOwnerChanged or not CA.vars.showDistricts) or not CA.ICUnlocked  end,
		},
		{
			type = "checkbox",
			name = GetString(SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_SHOW_DISTRICT_FLAGS_TOOLTIP),
			getFunc = function() return CA.vars.showFlagsDistricts end,
			setFunc = function(newValue) CA.vars.showFlagsDistricts = newValue;  end,
			disabled = function() return (not CA.vars.showFlags or not CA.vars.showDistricts) or not CA.ICUnlocked  end,
		},
		{
			type = "header",
			name = CA.colWht:Colorize(GetString(SI_CYRODIIL_ALERT_KEEP_STATUS)),
		},
		{
			type = "description",
			title = GetString(SI_CYRODIIL_ALERT_REINITIALIZE_TITLE),
			text = GetString(SI_CYRODIIL_ALERT_REINITIALIZE_TEXT),
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
			width = "half"
		},
		{
			type = "description",
			title = GetString(SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TITLE),
			text = GetString(SI_CYRODIIL_ALERT_OUTPUT_STATUS_TO_CHAT_TEXT),
			warning = GetString(SI_CYRODIIL_ALERT_MUST_BE_IN_CY),
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_LIST_ATTACKS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_LIST_ATTACKS_TOOLTIP),
			func = function() CA.vars.dumpAttack = true return CA.dumpChat() end,
			warning = GetString(SI_CYRODIIL_ALERT_MUST_BE_IN_CY),
			width = "half"
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_LIST_STATUS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_LIST_STATUS_TOOLTIP),
			func = function() CA.vars.dumpAttack = false return CA.dumpChat() end,
			warning = GetString(SI_CYRODIIL_ALERT_MUST_BE_IN_CY),
			width = "half",
		},
		{
			type = "description",
			title = GetString(SI_CYRODIIL_ALERT_IMPERIAL_CITY_STATUS_TITLE),
			text = GetString(SI_CYRODIIL_ALERT_IMPERIAL_CITY_TEXT),
			warning = GetString(SI_CYRODIIL_ALERT_MUST_BE_IN_IC),
			disabled = function() return not CA.ICUnlocked end,
			width = "half",
		},
		{
			type = "button",
			name = GetString(SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_NAME),
			tooltip = GetString(SI_CYRODIIL_ALERT_ACCESS_DISTRICTS_TOOLTIP),
			func = function() CA.vars.dumpAttack = true CA.dumpDistricts() return end,
			warning = GetString(SI_CYRODIIL_ALERT_MUST_BE_IN_IC),
			disabled = function() return not CA.ICUnlocked end,
			width = "half",
		},	
		{
			type = "header",
		},
		{
			type = "description",
			text = "\nVersion |c60FF60" .. CA.version .. "|r by @Enodoc, Savant of the United Explorers of Scholarly Pursuits (UESP)\nUESP: The Unofficial Elder Scrolls Pages - A collaborative source for all knowledge on the Elder Scrolls series since 1995. Find us at www.uesp.net\n\nJapanese localization: Lionas \n日本語版： Lionas [ライオナス]\n\nGerman localization: Scootworks \n\nVersions prior to 1.0.0 by @Tanthul, Leader of the Dark Moon PVP Guild operating on the EU Scourge campaign. (AKA Nodens)\n\nAll rights reserved.",
		},
	}
	LAM:RegisterOptionControls(CA.name..GetString(SI_CYRODIIL_ALERT_CONFIG), ConfigData)

	
end -- CA.CreateConfigMenu

