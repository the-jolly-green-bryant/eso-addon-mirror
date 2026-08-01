TributesEnhancement = TributesEnhancement or {}

local ETE = TributesEnhancement

local Lib = LibExoYsUtilities

local function GetTurnTimeMenu()
  local store = ETE.store.turnTime

  local controls = {}

  table.insert( controls, {
    type = "checkbox",
    name = "Enabled",
    getFunc = function() return store.enabled end,
    setFunc = function(bool)
      store.enabled = bool
    end,
  })

  table.insert( controls, {
    type = "checkbox",
    name = "Show Lock Button",
    getFunc = function() return store.showLock end,
    setFunc = function(bool)
      store.showLock = bool
    end,
  })

  table.insert( controls, {type="divider"} )

  table.insert( controls, {
    type = "checkbox",
    name = "Show Only for Player-Turn",
    getFunc = function() return store.onlyForPlayer end,
    setFunc = function(bool)
      store.onlyForPlayer = bool
    end,
  })

  return  {
    type = "submenu",
    name = Lib.AddIconToString( "Turn Helper", "esoui/art/icons/achievement_els_soaring_timeflow.dds", 36, "front"),
    controls = controls,
  }
end


local function GetAutomationMenu()
  local store = ETE.store.automation

  local controls = {}

  table.insert( controls, {
    type = "checkbox",
    name = "Auto-Accept Casual Match",
    getFunc = function() return store[LFG_ACTIVITY_TRIBUTE_CASUAL] end,
    setFunc = function(bool)
      store[LFG_ACTIVITY_TRIBUTE_CASUAL] = bool
    end,
  })

  table.insert( controls, {
    type = "checkbox",
    name = "Auto-Accept Competitive Match",
    getFunc = function() return store[LFG_ACTIVITY_TRIBUTE_COMPETITIVE] end,
    setFunc = function(bool)
      store[LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = bool
    end,
  })

  table.insert( controls, {
    type = "slider",
    name = "Delay in Seconds",
    min = 1,
    max = 15,
    step = 1,
    getFunc = function() return store.delay end,
    setFunc = function(value)
      store.delay = value
    end,
  })

  --[[table.insert( controls, { type = "divider" })

  table.insert( controls, {
    type = "checkbox",
    name = "Maximize Chat at start of game ",
    getFunc = function() return store.maxChatAtGameStart end,
    setFunc = function(bool)
      store.maxChatAtGameStart = bool
    end,
  })

  table.insert( controls, {
    type = "checkbox",
    name = "Maximize chat at start of opponent turn",
    getFunc = function() return store.maxChatAtOpponentTurnStart end,
    setFunc = function(bool)
      store.maxChatAtOpponentTurnStart = bool
    end,
  })

  table.insert( controls, {
    type = "checkbox",
    name = "Minimize chat at start of your turn",
    getFunc = function() return store.minChatAtPlayerTurnStart end,
    setFunc = function(bool)
      store.minChatAtPlayerTurnStart = bool
    end,
  })]]

  table.insert( controls, {
    type = "header",
    name = "Change Player Online Status...",
  })


  local statusList = {
    [PLAYER_STATUS_ONLINE] = GetString(SI_GAMEPAD_CONTACTS_STATUS_ONLINE),
    [PLAYER_STATUS_AWAY] = GetString(SI_GAMEPAD_CONTACTS_STATUS_AWAY),
    [PLAYER_STATUS_DO_NOT_DISTURB] = GetString(SI_GAMEPAD_CONTACTS_STATUS_DO_NOT_DISTURB),
    [PLAYER_STATUS_OFFLINE] = GetString(SI_GAMEPAD_CONTACTS_STATUS_OFFLINE),
  }

  for _, matchType in pairs( ETE.GetMatchTypeOrder() ) do
    table.insert( controls, {
      type = "checkbox",
      name = "...during "..ETE.GetMatchTypeName(matchType).." Match",
      getFunc = function() return store.changePlayerStatus[matchType].enabled end,
      setFunc = function(bool)
        store.changePlayerStatus[matchType].enabled = bool
      end,
      width = "half",
    })

    table.insert( controls, {
      disabled = function() return not store.changePlayerStatus[matchType].enabled end,
      width = "half",
      type = "dropdown",
      name = "Select Status",
      choices = statusList,
      getFunc = function() return statusList[store.changePlayerStatus[matchType].status] end,
      setFunc = function(selection)
        for statusId, statusStr in pairs(statusList) do
          if statusStr == selection then
            store.changePlayerStatus[matchType].status = statusId
            break
          end
        end
      end,
    })
  end

  return  {
    type = "submenu",
    name = Lib.AddIconToString( "Automation", "esoui/art/icons/store_orsiniumdlc_solopve.dds", 36, "front"),
    controls = controls,
  }
end

function ETE.CreateMenu()
  local displayName = "|c00FF00ExoY|rs Tributes Enhancement"
  local panelData =
  {
    type                = "panel",
    name                = displayName,
    displayName         = displayName,
    author              = "@|c00FF00ExoY|r94 (PC/EU)",
    version             = "1.6.1",
    registerForRefresh  = true,
  }
  local optionsTable = {}

  table.insert(optionsTable, Lib.FeedbackSubmenu("Tributes Enhancement","info3364-ExoYsTributesEnhancement.html"))
  table.insert(optionsTable, GetAutomationMenu() )
  table.insert(optionsTable, GetTurnTimeMenu() )

  table.insert( optionsTable, {
      type = "checkbox",
      name = "Debug Mode",
      getFunc = function() return ETE.store.debug end,
      setFunc = function(bool)
        ETE.store.debug = bool
      end,
    })
  table.insert( optionsTable, {
      type = "checkbox",
      name = "Developer Mode",
      getFunc = function() return ETE.store.dev end,
      setFunc = function(bool)
        ETE.store.dev = bool
      end,
    })


  LibAddonMenu2:RegisterAddonPanel( "TributesEnhancement_Menu", panelData )
  LibAddonMenu2:RegisterOptionControls( "TributesEnhancement_Menu", optionsTable )
end
