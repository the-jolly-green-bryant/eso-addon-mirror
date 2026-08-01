SSEA = SSEA or {}
local SSEA = SSEA

function SSEA.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Slip's Sanity's Edge Assist",
		displayName	 = "Slip's Sanity's Edge Assist",
		author			 = SSEA.author,
		version			 = SSEA.version,
		slashCommand = "/ssea",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "description",
			text = "Trial timers, alerts, and indicators for Sanity's Edge.",
		},
		{
			type = "divider",
		},
    {
			type = "description",
			text = "For mechanic arrows on players, install |cff0000OdySupportIcons|r (optional dependency)",
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Unlock UI (you need to be in the trial)",
			default = false,
			getFunc = function() return SSEA.unlockedUI end,
			setFunc = function( newValue ) SSEA.UnlockUI(newValue) end,
		},
    {
			type    = "button",
			name    = "Reset to default position",
			func = function() SSEA.DefaultPosition()  end,
      warning = "Requires /reloadui for the position to reset",
		},
    {
			type    = "checkbox",
			name    = "Hide welcome text on chat",
			default = false,
			getFunc = function() return SSEA.savedVariables.hideWelcome end,
			setFunc = function( newValue ) SSEA.savedVariables.hideWelcome = newValue end,
		},
    {
			type = "divider",
		},
	{
			type    = "checkbox",
			name    = "Enabled on non-hm",
			default = false,
			getFunc = function() return SSEA.savedVariables.enabledOnNonHM end,
			setFunc = function( newValue ) SSEA.savedVariables.enabledOnNonHM = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Debug Mode",
			default = false,
			getFunc = function() return SSEA.savedVariables.debugMode end,
			setFunc = function( newValue ) SSEA.savedVariables.debugMode = newValue end,
		},
    {
			type = "divider",
		},
	{
      type = "header",
      name = "Trash",
      reference = "SSEATrashHeader"
    },
	{
			type    = "checkbox",
			name    = "Disruptor In-game Markers",
			default = true,
			getFunc = function() return SSEA.savedVariables.showTrashDisruptorMarkers2 end,
			setFunc = function(newValue) SSEA.savedVariables.showTrashDisruptorMarkers2 = newValue end,
			warning = "This will enable the marking of Disruptors if currently the group lead. Reticle must be placed on Disruptors to mark them. There is a slight delay upon reading in the reticle's target's name and applying the marker, so the reticle should be held momentarily on the target until a marker has been applied. Having this setting enabled will go through the marker menu in ascending order. It is recommended that the person who is designated to mark be using an addon that hides group members."
		},
	{
			type    = "checkbox",
			name    = "Disruptor Marker Override",
			default = false,
			getFunc = function() return SSEA.savedVariables.showTrashDisruptorMarkersOverride2 end,
			setFunc = function(newValue) SSEA.savedVariables.showTrashDisruptorMarkersOverride2 = newValue end,
			warning = "Whoever has this enabled will contribute to marking the archers. Reticle must be placed on Disruptors to mark them. There is a slight delay upon reading in the reticle's target's name and applying the marker, so the reticle should be held momentarily on the target until a marker has been applied. Having this setting enabled will go through the marker menu in descending order. It is recommended that the person who is designated to mark be using an addon that hides group members."
		},

	{
      type = "header",
      name = "Exarchanic Yaseyla",
      reference = "SSEAYaseylaHeader"
    },
	{
			type    = "checkbox",
			name    = "Show Alerts for Yaseyla Boss Fight",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaAlerts end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaAlerts = newValue end,
			warning = "The Wamasu Cones are about 10 seconds with some variability."
		},
	{
			type    = "checkbox",
			name    = "Show Percentage Notifications",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaPercentageNotifications end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaPercentageNotifications = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Wamasu Cone Countdown",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaWamasuConeCountdown  end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaWamasuConeCountdown  = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Fire Bomb Timer",
			default = false,
			getFunc = function() return SSEA.savedVariables.showYaseylaFireBombs2  end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaFireBombs2  = newValue end,
			warning = "It's recommended to disable this feature because Sanity's Edge Helper handles this better."
		},
	{
			type    = "checkbox",
			name    = "Show Tomb (Frost Bomb) Timer",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaFrostBombs  end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaFrostBombs  = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show Wamasu + Archers Spawn Warnings",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaWamasuWarnings end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaWamasuWarnings = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Shrapnel Warnings",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaShrapnelWarnings   end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaShrapnelWarnings = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Portal + Archers Warnings",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaPortalWarnings end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaPortalWarnings = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Archers True Shot Warnings",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaArcherTrueShotWarnings end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaArcherTrueShotWarnings = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Vengeful Strike Alert",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaVengefulStrikeAlerts end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaVengefulStrikeAlerts = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Enraged Yaseyla Alert",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaEnragedAlert end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaEnragedAlert = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Contramagis Archer In-game Markers",
			default = true,
			getFunc = function() return SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaContramagisArcherMarkers2 = newValue end,
			warning = "This will enable the marking of Contramagis Archers if currently the group lead. Reticle must be placed on Contramagis Archers to mark them. There is a slight delay upon reading in the reticle's target's name and applying the marker, so the reticle should be held momentarily on the target until a marker has been applied. Having this setting enabled will go through the marker menu in ascending order. It is recommended that the person who is designated to mark be using an addon that hides group members."
		},
	{
			type    = "checkbox",
			name    = "Archer Marker Override",
			default = false,
			getFunc = function() return SSEA.savedVariables.showYaseylaContramagisArcherMarkersOverride2 end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaContramagisArcherMarkersOverride2 = newValue end,
			warning = "Whoever has this enabled will contribute to marking the archers. Reticle must be placed on Contramagis Archers to mark them. There is a slight delay upon reading in the reticle's target's name and applying the marker, so the reticle should be held momentarily on the target until a marker has been applied. Having this setting enabled will go through the marker menu in descending order. It is recommended that the person who is designated to mark be using an addon that hides group members."
		},
	{
			type = "divider",
		},

	{
      type = "header",
      name = "Chimera",
      reference = "SSEAChimeraHeader"
    },
	{
			type    = "checkbox",
			name    = "Show Panel for Chimera Boss Fight",
			default = true,
			getFunc = function() return SSEA.savedVariables.showChimeraPanel2 end,
			setFunc = function(newValue) SSEA.savedVariables.showChimeraPanel2 = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Arctic Shred Alerts for Chimera",
			default = true,
			getFunc = function() return SSEA.savedVariables.showChimeraArcticShredAlerts end,
			setFunc = function(newValue) SSEA.savedVariables.showChimeraArcticShredAlerts = newValue end,
		},
	{
			type = "divider",
		},

	{
      type = "header",
      name = "Ansuul the Tormentor",
      reference = "SSEAAnsuulHeader"
    },
	{
			type    = "checkbox",
			name    = "Show Foresight Panel for Ansuul Boss Fight",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulForesightPanel end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulForesightPanel = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Percentage Notifications",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulPercentageNotifications end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulPercentageNotifications = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Manic Phobia Info",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulEssenceManifestationInfo end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulEssenceManifestationInfo = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show Manic Phobia Warnings",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulManicPhobiaWarnings end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulManicPhobiaWarnings = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Manic Phobia Info Panel",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulManicPhobiaInfo end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulManicPhobiaInfo = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Maze Info Panel",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulMazeInfo   end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulMazeInfo = newValue  end,
		},
	{
			type    = "checkbox",
			name    = "Show Wrack Info Panel",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulWrackInfo   end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulWrackInfo = newValue  end,
		},
	{
			type    = "checkbox",
			name    = "Show Maze Warnings",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulMazeWarnings   end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulMazeWarnings = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Poisoned Mind Notification",
			default = false,
			getFunc = function() return SSEA.savedVariables.showAnsuulPoisonedMindNotification   end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulPoisonedMindNotification = newValue  end,
			warning = "Players with Poisoned Mind will have a green triangle on them."
		},
	{
			type    = "checkbox",
			name    = "Show Enraged Atro Inferno Warnings 1",
			default = false,
			getFunc = function() return SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Enraged Atro Inferno Warnings 2",
			default = false,
			getFunc = function() return SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings2 end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulEnragedAtroInfernoWarnings2 = newValue end,
			warning = "[Experimental]"
		},
	{
			type    = "checkbox",
			name    = "Show Enraged Atro Inferno Alerts",
			default = false,
			getFunc = function() return SSEA.savedVariables.showAnsuulEnragedAtroInfernoAlerts end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulEnragedAtroInfernoAlerts = newValue end,
			warning = "[Experimental]"
		},
	{
			type    = "checkbox",
			name    = "Enraged Fragment Markers",
			default = true,
			getFunc = function() return SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulEnragedFragmentMarkers2 = newValue end,
			warning = "This will enable the marking of Enraged Fragments if currently the group lead. Reticle must be placed on Enraged Fragments to mark them. There is a slight delay upon reading in the reticle's target's name and applying the marker, so the reticle should be held momentarily on the target until a marker has been applied. Having this setting enabled will go through the marker menu in ascending order. It is recommended that the person who is designated to mark be using an addon that hides group members."
		},
	{
			type    = "checkbox",
			name    = "E. Fragment Marker Override",
			default = false,
			getFunc = function() return SSEA.savedVariables.showAnsuulEnragedFragmentMarkersOverride2 end,
			setFunc = function(newValue) SSEA.savedVariables.showAnsuulEnragedFragmentMarkersOverride2 = newValue end,
			warning = "Whoever has this enabled will contribute to marking the Enraged Fragments. Reticle must be placed on Enraged Fragments to mark them. There is a slight delay upon reading in the reticle's target's name and applying the marker, so the reticle should be held momentarily on the target until a marker has been applied. Having this setting enabled will go through the marker menu in descending order. It is recommended that the person who is designated to mark be using an addon that hides group members."
		},
	{
			type = "divider",
		},

	{
      type = "header",
      name = "Code's Combat Alerts Integration",
      reference = "SSEACCAHeader"
    },
	{
			type    = "checkbox",
			name    = "Show Alerts for who Wamasus Charge",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertWamasuCharges2 end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertWamasuCharges2 = newValue end,
			warning = "It's recommended to disable this feature because CombatAlerts handles this already."
		},
	{
			type    = "checkbox",
			name    = "Show Timer Bars for Wamasus Charge",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertTimerBarWamasuCharges2 end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertTimerBarWamasuCharges2 = newValue end,
			warning = "It's recommended to disable this feature because CombatAlerts handles this already."
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Yaseyla Fire Bomb Toss",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertYaseylaFireBombToss2 end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertYaseylaFireBombToss2 = newValue end,
			warning = "It's recommended to disable this feature because CombatAlerts handles this already."
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Yaseyla Shrapnel",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertYaseylaShrapnel end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertYaseylaShrapnel = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Timer Bar for Yaseyla Knife Blast",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertYaseylaKnifeBlast end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertYaseylaKnifeBlast = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Chimera Chain Lightning",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertChimeraChainLightning end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertChimeraChainLightning = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Chim.'s Asc. Lion 2x Strike",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertChimeraLionDoubleStrikes end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertChimeraLionDoubleStrikes = newValue end,
			warning = "Chimera's Ascendant Lion Double Strike"
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Chim.'s Asc. Gryph. Peck",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertChimeraGryphonPeck end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertChimeraGryphonPeck = newValue end,
			warning = "Chimera's Ascendant Gryphon Peck"
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Ansuul's Wrack",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulWrack end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulWrack = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Ansuul's Calamity",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulCalamity end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulCalamity = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Ansuul's Sunburst",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulSunburst end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulSunburst = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Ansuul's Wrathstorm",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulWrathstorm2 end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulWrathstorm2 = newValue end,
			warning = "This setting should be kept off for now."
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Portal Channel called 'Execute'",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulExecute end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulExecute = newValue end,
		},
	{
			type    = "checkbox",
			name    = "Show Alerts for Portal Channel called 'Corrupt'",
			default = false,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulCorrupt2 end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulCorrupt2 = newValue end,
			warning = "This setting should be kept off for now."
		},
	{
			type    = "checkbox",
			name    = "Show Alerts with Timer Bars for Manic Phobia",
			default = true,
			getFunc = function() return SSEA.savedVariables.showCombatAlertAnsuulManicPhobia end,
			setFunc = function(newValue) SSEA.savedVariables.showCombatAlertAnsuulManicPhobia = newValue end,
		},

	{
			type = "divider",
		},

	{
      type = "header",
      name = "OdySupportIcons Integration",
      reference = "SSEAOSIHeader"
    },
	{
			type    = "checkbox",
			name    = "Show Icons for Wamasu Charges",
			default = true,
			getFunc = function() return SSEA.savedVariables.showIconWamasuCharges2 end,
			setFunc = function(newValue) SSEA.savedVariables.showIconWamasuCharges2 = newValue end,
			-- warning = "Development in progress."
		},
	{
		type = "button",
		name = "Clear Icons",
		func = SSEA.ClearYaseylaZoneIcons,
		warning = "Clears Yaseyla Wamasu charge icons. This is an experimental feature. Use at your own risk.",
	},
	{
			type    = "checkbox",
			name    = "Show Icons for Chimera's Chain Lightning/Circuit",
			default = true,
			getFunc = function() return SSEA.savedVariables.showIconChimeraChainLightning end,
			setFunc = function(newValue) SSEA.savedVariables.showIconChimeraChainLightning = newValue end,
			warning = "Development in progress."
		},
	{
			type    = "checkbox",
			name    = "Show Icons for Ansuul's Poisoned Mind",
			default = false,
			getFunc = function() return SSEA.savedVariables.showIconAnsuulPoisonedMind end,
			setFunc = function(newValue) SSEA.savedVariables.showIconAnsuulPoisonedMind = newValue end,
			warning = "Development in progress."
		},
	{
			type    = "checkbox",
			name    = "Show Vengeful Strike Heal Absorption",
			default = false,
			getFunc = function() return SSEA.savedVariables.showYaseylaVengefulStrikeHealAbsorption end,
			setFunc = function(newValue) SSEA.savedVariables.showYaseylaVengefulStrikeHealAbsorption = newValue end,
			warning = "Development in progress."
		},
	{
			type    = "checkbox",
			name    = "Fix for wamasu charge icons persisting",
			default = true,
			getFunc = function() return SSEA.savedVariables.fixWamasuChargeIconsPersisting end,
			setFunc = function(newValue) SSEA.savedVariables.fixWamasuChargeIconsPersisting = newValue end,
		},

	{
      type = "divider",
    },
    {
      type = "header",
      name = "Misc",
      reference = "SSEAMiscMenu"
    },
    {
      type = "description",
      text = "Unlock UI first to be able to change scale.",
    },
    {
      type    = "slider",
      name    = "Panel UI Scale",
      min = 0.1,
      max = 3.0,
      step = 0.1,
      decimals = 1,
	  default = 1,
      tooltip = "0.5 is tiny, 2 is huge",
      default = SSEA.savedVariables.panelUICustomScale,
      disabled = function() return SSEA.status.unlockedUI end,
      getFunc = function() return SSEA.savedVariables.panelUICustomScale end,
      setFunc = function(newValue) SSEA.SetPanelScale(newValue) end,
      warning = "Only for extreme resolutions. Addon optimized for scale=1. You can /reloadui after changing the setting to prevent it from getting reset if you crash."
    },
	{
      type    = "slider",
      name    = "Alert UI Scale",
      min = 0.1,
      max = 3.0,
      step = 0.1,
      decimals = 1,
	  default = 0.5,
      tooltip = "0.5 is tiny, 2 is huge",
      default = SSEA.savedVariables.alertUICustomScale,
      disabled = function() return SSEA.status.unlockedUI end,
      getFunc = function() return SSEA.savedVariables.alertUICustomScale end,
      setFunc = function(newValue) SSEA.SetAlertScale(newValue) end,
      warning = "Only for extreme resolutions. Addon optimized for scale=1. You can /reloadui after changing the setting to prevent it from getting reset if you crash."
    },
    }

	LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(SSEA.name .. "Options", menuOptions )
	LAM:RegisterOptionControls(SSEA.name .. "Options", dataTable )
end
