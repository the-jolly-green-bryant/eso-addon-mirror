QRH = QRH or {}
local QRH = QRH

function QRH.AddonMenu()
	local menuOptions = {
		type				 = "panel",
		name				 = "Qcell's Rockgrove Helper",
		displayName	 = "|cFF4500Qcell's Rockgrove Helper|r",
		author			 = QRH.author,
		version			 = QRH.version,
		slashCommand = "/qrh",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local dataTable = {
		{
			type = "description",
			text = "Trial timers, alerts and indicators for Rockgrove Helper.",
		},
		{
			type = "divider",
		},
    {
			type = "description",
			text = "For mechanics arrows on players for Sludge (poison), Death Touch (curse), install |cff0000OdySupportIcons|r (optional dependency)",
		},
		{
			type = "divider",
		},
		{
			type    = "checkbox",
			name    = "Unlock UI (to move it)",
			default = false,
			getFunc = function() return QRH.unlockedUI end,
			setFunc = function( newValue ) QRH.UnlockUI(newValue) end,
		},
    {
			type    = "button",
			name    = "Reset to default position",
			func = function() QRH.DefaultPosition()  end,
      warning = "Requires /reloadui for the position to reset",
		},
    {
			type    = "checkbox",
			name    = "Hide welcome text on chat",
			default = false,
			getFunc = function() return QRH.savedVariables.hideWelcome end,
			setFunc = function( newValue ) QRH.savedVariables.hideWelcome = newValue end,
		},
    {
			type = "divider",
		},
    {
      type = "header",
      name = "Oaxiltso",
      reference = "OaxiltsoHeader"
    },
    {
			type    = "checkbox",
			name    = "Show Blitz timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showOaxiltsoBlitz end,
			setFunc = function(newValue) QRH.savedVariables.showOaxiltsoBlitz = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show Sludge timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showOaxiltsoPoison end,
			setFunc = function(newValue) QRH.savedVariables.showOaxiltsoPoison = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show names and sides of poisoned players",
			default = true,
			getFunc = function() return QRH.savedVariables.showOaxiltsoPoisonedPlayers   end,
			setFunc = function(newValue) QRH.savedVariables.showOaxiltsoPoisonedPlayers = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Meteor Block Alert",
			default = true,
			getFunc = function() return QRH.savedVariables.showOaxiltsoMeteorBlock  end,
			setFunc = function(newValue) QRH.savedVariables.showOaxiltsoMeteorBlock  = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show dodge bar for the cleave",
			default = true,
			getFunc = function() return QRH.savedVariables.showOaxiltsoCleaveDodgeBar  end,
			setFunc = function(newValue) QRH.savedVariables.showOaxiltsoCleaveDodgeBar  = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Oaxiltso pool icons",
			default = true,
			getFunc = function() return QRH.savedVariables.showOaxiltsoPoolIcons  end,
			setFunc = function(newValue) QRH.savedVariables.showOaxiltsoPoolIcons  = newValue  end,
		},
    {
      type = "header",
      name = "Flame-Herald Bahsei",
      reference = "BahseiHeader"
    },
    {
			type    = "checkbox",
			name    = "Show Next Curse timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiNextCurse   end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiNextCurse   = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show Next portal timer (HM only)",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiNextPortal   end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiNextPortal   = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show number of Players in portal (HM)",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiPlayersInPortal   end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiPlayersInPortal   = newValue end,
      warning = "Experimental feature",
		},
    {
			type    = "checkbox",
			name    = "Show Portal Debuff timer (HM only)",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiPortalDebuff    end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiPortalDebuff    = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show Bahsei next Sickle timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiNextSickle  end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiNextSickle  = newValue end,
		},
    {
			type    = "checkbox",
			name    = "Show Bahsei next Sun (30% to 0% only)",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiNextSun  end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiNextSun  = newValue end,
		},
    {
			type = "divider",
		},
    {
			type    = "checkbox",
			name    = "Show Interrupt prompt (Tanks only)",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiInterruptForTanks  end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiInterruptForTanks  = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Flesh Abomination slam (Tanks only)",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiSlamForTanks  end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiSlamForTanks  = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Main Tank Exploding timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiTankExploding   end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiTankExploding   = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Death Touch countdown on yourself",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiDeathTouchCountdown   end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiDeathTouchCountdown   = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Prime Meteor (Sun) bar timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showBahseiSunProgressBar   end,
			setFunc = function(newValue) QRH.savedVariables.showBahseiSunProgressBar   = newValue  end,
      warning = "The timer remains even after the meteor has been killed.",
		},
    {
      type = "header",
      name = "Xalvakka",
      reference = "XalvakkaHeader"
    },
    {
			type    = "checkbox",
			name    = "Show RUN IN X% at 70%,40%",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaRunTimer  end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaRunTimer  = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show jump timer on stage 1 (HM only)",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaJumpTimer  end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaJumpTimer = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Volatile Shell shield value",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaShieldValue   end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaShieldValue   = newValue  end,
      warning = "The shield value only updates if you aim your reticle on the Volatile Shell",
		},
    {
			type    = "checkbox",
			name    = "Show purge now on synergy",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaPurgeNowAlert   end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaPurgeNowAlert   = newValue  end,
      warning = "When you kill a wraith and gain a synergy, it shows a Purge Now alert.",
		},
    {
			type    = "checkbox",
			name    = "Show purge soul timer",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaPurgeSoulTimer   end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaPurgeSoulTimer   = newValue  end,
      warning = "Increasing count of how long you've been holding the purge soul synergy (increasing damage).",
		},
    {
			type    = "checkbox",
			name    = "Show ON BLOB when taking jelly damage",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaOnBlob   end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaOnBlob   = newValue  end,
      warning = "Players from the UK may understand something else here. It just means you are taking damage from the jelly.",
		},
    {
			type    = "checkbox",
			name    = "Show Xalvakka Split Icons",
			default = true,
			getFunc = function() return QRH.savedVariables.showXalvakkaSplitIcons   end,
			setFunc = function(newValue) QRH.savedVariables.showXalvakkaSplitIcons   = newValue  end,
      warning = "Icons on Volatile Shell positions.",
		},
    {
      type = "header",
      name = "Trash",
      reference = "TrashHeader"
    },
    {
			type    = "checkbox",
			name    = "Show Earthquake alert",
			default = true,
			getFunc = function() return QRH.savedVariables.showTrashEarthquake  end,
			setFunc = function(newValue) QRH.savedVariables.showTrashEarthquake = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Prime Meteor (sun) timer bar",
			default = true,
			getFunc = function() return QRH.savedVariables.showTrashSunProgressBar  end,
			setFunc = function(newValue) QRH.savedVariables.showTrashSunProgressBar = newValue  end,
		},
    {
			type    = "checkbox",
			name    = "Show Molten Rain (Ash Titan) timer bar",
			default = true,
			getFunc = function() return QRH.savedVariables.showTrashMoltenRainBar  end,
			setFunc = function(newValue) QRH.savedVariables.showTrashMoltenRainBar = newValue  end,
		},
	}

	LAM = LibAddonMenu2
	LAM:RegisterAddonPanel(QRH.name .. "Options", menuOptions )
	LAM:RegisterOptionControls(QRH.name .. "Options", dataTable )
end
