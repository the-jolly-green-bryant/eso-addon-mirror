function KalsCrown.setupMenu()
  local LAM = LibStub("LibAddonMenu-2.0")
  local displayInfo = KalsCrown.vars

  local panelData = {
		type = "panel",
		name = "KalsCrown",
		displayName = "|cFFD700Kals Crown|r",
		author = "Kalinfe",
		version = "1.0.0",
		registerForRefresh = true
	}

	LAM:RegisterAddonPanel("KalsCrownOptions", panelData)

	local options = {
		{
			type = "header",
			name = "Options"
		},
		--{
			--type = "checkbox",
			--name = "Enabled",
			--tooltip = "Turns the icons on and off",
			--getFunc = function() return displayInfo.enabled end,
			--setFunc = function(value)
        --displayInfo.enabled = value

      --end,
		--},
    {
			type = "checkbox",
			name = "Show Self",
			tooltip = "Displays icons on everyone in group",
			getFunc = function() return displayInfo.showSelf end,
			setFunc = function(value)
        displayInfo.showSelf = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Show Everyone",
			tooltip = "Displays icons on everyone in group",
			getFunc = function() return displayInfo.showEveryone end,
			setFunc = function(value)
        displayInfo.showEveryone = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Show Leader",
			tooltip = "Displays the leaders icon",
			getFunc = function() return displayInfo.showLeader end,
      setFunc = function(value)
        displayInfo.showLeader = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Show Tanks",
			tooltip = "Displays icons on the tanks",
			getFunc = function() return displayInfo.showTanks end,
      setFunc = function(value)
        displayInfo.showTanks = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Show Healers",
			tooltip = "Displays icons on the healers",
			getFunc = function() return displayInfo.showHealers end,
      setFunc = function(value)
        displayInfo.showHealers = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Self Icon Size",
			tooltip = "How large icons are on yourself",
      min = 25,
      max = 500,
      step = 5,
			getFunc = function() return displayInfo.selfSize end,
      setFunc = function(value)
        displayInfo.selfSize = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "General Icon Size",
			tooltip = "How large icons are in general",
      min = 25,
      max = 500,
      step = 5,
			getFunc = function() return displayInfo.generalSize end,
      setFunc = function(value)
        displayInfo.generalSize = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Leader Icon Size",
			tooltip = "How large the leaders icon should show",
      min = 25,
      max = 500,
      step = 5,
			getFunc = function() return displayInfo.leaderSize end,
      setFunc = function(value)
        displayInfo.leaderSize = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Tank Icon Size",
			tooltip = "How large the tanks icons should show",
      min = 25,
      max = 500,
      step = 5,
			getFunc = function() return displayInfo.tankSize end,
      setFunc = function(value)
        displayInfo.tankSize = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Healer Icon Size",
			tooltip = "How large the healers icon should show",
      min = 25,
      max = 500,
      step = 5,
			getFunc = function() return displayInfo.healerSize end,
      setFunc = function(value)
        displayInfo.healerSize = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Self Icon Height",
			tooltip = "Position on your player to show your icon",
      min = 0,
      max = 1000,
      step = 10,
			getFunc = function() return displayInfo.selfOffset end,
      setFunc = function(value)
        displayInfo.selfOffset = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "General Icon Height",
			tooltip = "Position on other players to show their icon",
      min = 0,
      max = 1000,
      step = 10,
			getFunc = function() return displayInfo.generalOffset end,
      setFunc = function(value)
        displayInfo.generalOffset = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Leader Icon Height",
			tooltip = "Position on the leader to show their icon",
      min = 0,
      max = 1000,
      step = 10,
			getFunc = function() return displayInfo.leaderOffset end,
      setFunc = function(value)
        displayInfo.leaderOffset = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Tank Icon Height",
			tooltip = "Position on tanks to show their icon",
      min = 0,
      max = 1000,
      step = 10,
			getFunc = function() return displayInfo.tankOffset end,
      setFunc = function(value)
        displayInfo.tankOffset = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "slider",
			name = "Healer Icon Height",
			tooltip = "Position on healers to show their icon",
      min = 0,
      max = 1000,
      step = 10,
			getFunc = function() return displayInfo.healerOffset end,
      setFunc = function(value)
        displayInfo.healerOffset = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Highlight Self",
			getFunc = function() return displayInfo.highlightSelf end,
			setFunc = function(value)
        displayInfo.highlightSelf = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Highlight Everyone",
			getFunc = function() return displayInfo.highlightEveryone end,
			setFunc = function(value)
        displayInfo.highlightEveryone = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Highlight Leader",
			getFunc = function() return displayInfo.highlightLeader end,
      setFunc = function(value)
        displayInfo.highlightLeader = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Highlight Tanks",
			getFunc = function() return displayInfo.highlightTanks end,
      setFunc = function(value)
        displayInfo.highlightTanks = value
        KalsCrown.ReloadGroup()
      end,
		},
    {
			type = "checkbox",
			name = "Highlight Healers",
			getFunc = function() return displayInfo.highlightHealers end,
      setFunc = function(value)
        displayInfo.highlightHealers = value
        KalsCrown.ReloadGroup()
      end,
		},
	}

	LAM:RegisterOptionControls("KalsCrownOptions", options)
end
