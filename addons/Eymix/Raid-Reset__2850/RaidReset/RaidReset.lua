local LAM2 = LibAddonMenu2

RaidReset = {
  name = "RaidReset",
  version = "1.8",

  default = {
    confirmReset = false,
    confirmLeave = false,
    resetDelay = 2500,
  },

  sv = nil,
  svVersion = 1,
  svName = "RaidResetVars",

  reset = false,
  confirmReset = false,
  confirmLeave = false,
  resetDelay = 2500,
}


local RR = RaidReset

function RR.Activate()
  if RR.confirmReset then
    LAM2.util.ShowConfirmationDialog("Reset Instance", "Are you sure you want to reset the instance?", function()
      zo_callLater(function ()
        if (CanPlayerChangeGroupDifficulty()) then
          SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
        end
      end, 1000)
      zo_callLater(function ()
        if (CanPlayerChangeGroupDifficulty()) then
          SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
          d("|c57fffcRaidReset : |rInstance has been reset.")
        end
      end, RR.resetDelay)
    end)
  else
    zo_callLater(function ()
      if (CanPlayerChangeGroupDifficulty()) then
        SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
      end
    end, 1000)
    zo_callLater(function ()
      if (CanPlayerChangeGroupDifficulty()) then
        SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
        d("|c57fffcRaidReset : |rInstance has been reset.")
      end
    end, RR.resetDelay)
  end
  RR.reset = false
end

function RR.PlayerActivate()
  if not RR.reset then
    return
  end
  if RR.confirmReset then
    LAM2.util.ShowConfirmationDialog("Reset Instance", "Are you sure you want to reset the instance?", function()
      SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
      -- DO NOT CALL INSTANT
      zo_callLater(function ()
        if (CanPlayerChangeGroupDifficulty()) then
          SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
          d("|c57fffcRaidReset : |rInstance has been reset.")
        end
      end, RR.resetDelay)
    end)
  else
    SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
    -- DO NOT CALL INSTANT
    zo_callLater(function ()
      if (CanPlayerChangeGroupDifficulty()) then
        SetVeteranDifficulty(not IsGroupUsingVeteranDifficulty())
        d("|c57fffcRaidReset : |rInstance has been reset.")
      end
    end, RR.resetDelay)
  end
  RR.reset = false
end

function RR.QuitAndReset()
  if RR.confirmLeave then
    LAM2.util.ShowConfirmationDialog("Leave Instance", "Are you sure you want to leave the instance?", function()
      if IsUnitGroupLeader("player") then
        RR.reset = true
        d("|c57fffcRaidReset : |rLeaving instance and resetting ..")
      else
        d("|c57fffcRaidReset : |rLeaving instance ..")
      end
      zo_callLater(function ()
        ExitInstanceImmediately()
      end , 1000);
    end)
  else
    if IsUnitGroupLeader("player") then
      RR.reset = true
      d("|c57fffcRaidReset : |rLeaving instance and resetting ..")
    else
      d("|c57fffcRaidReset : |rLeaving instance ..")
    end
    zo_callLater(function ()
      ExitInstanceImmediately()
    end , 1000);
  end
end

function RR.EjectAndReset()
  if not HodorReflexes then
    d("|c57fffcRaidReset : |rHodorReflexes not found, can't process the call")
    return
  end
  if IsUnitGroupLeader("player") then
    RR.reset = true
    d("|c57fffcRaidReset : |rEjecting instance and resetting ..")
    HodorReflexes.modules.share.SendExitInstance()
  else
    d("|c57fffcRaidReset : |rLeaving instance ..")
    zo_callLater(function ()
      ExitInstanceImmediately()
    end , 1000);
  end
end

function RR.OnAddOnLoaded(_, name)
  if name == RR.name then
    RR:Initialize()
    EVENT_MANAGER:UnregisterForEvent(RR.name, EVENT_ADD_ON_LOADED)
  end
end

function RR:Initialize()
  ZO_CreateStringId("SI_BINDING_NAME_RAIDRESET", "Reset instance")
  ZO_CreateStringId("SI_BINDING_NAME_RAIDQUITANDRESET", "Quit instance (and reset it as group leader)")
  ZO_CreateStringId("SI_BINDING_NAME_RAIDEJECTANDRESET", "Quit instance as group member or use HodorReflexes eject tool and reset after leaving instance as leader (HodorReflexes required for this call to work)")

  SLASH_COMMANDS["/raidreseteject"] = RR.EjectAndReset
  SLASH_COMMANDS["/raidresetquit"] = RR.QuitAndReset
  SLASH_COMMANDS["/raidreset"] = RR.PlayerActivate

  SLASH_COMMANDS["/rreject"] = RR.EjectAndReset
  SLASH_COMMANDS["/rrquit"] = RR.QuitAndReset
  SLASH_COMMANDS["/rr"] = RR.PlayerActivate

  RR.sv = ZO_SavedVars:NewAccountWide(RR.svName, RR.svVersion, nil, RR.default)
  RR.confirmReset = RR.sv.confirmReset
  RR.confirmLeave = RR.sv.confirmLeave
  RR.resetDelay = RR.sv.resetDelay

  EVENT_MANAGER:RegisterForEvent(RR.name, EVENT_PLAYER_ACTIVATED, RR.PlayerActivate)

  RR:CreateSettingsWindow()
end

function RR:CreateSettingsWindow()
  local panelData = {
    type = "panel",
    name = "RaidReset",
    displayName = "RaidReset",
    author = "Eymix",
    version = RR.version,
    slashCommand = "/raidresetmenu",
  }

  local optionsData = {
    {
      type = "header",
      name = "Raid Reset Settings",
    },
    {
      type = "description",
      text = "Some options to make the addon how you like it the most",
    },
    {
      type = "checkbox",
      name = "Confirm reset window",
      default = RR.default.confirmReset,
      getFunc = function() return RR.sv.confirmReset end,
      setFunc = function(value)
        RR.sv.confirmReset = value
        RR.confirmReset = value
      end,
    },
    {
      type = "checkbox",
      name = "Confirm leave window",
      default = RR.default.confirmLeave,
      getFunc = function() return RR.sv.confirmLeave end,
      setFunc = function(value)
        RR.sv.confirmLeave = value
        RR.confirmLeave = value
      end,
    },
    {
      type = "slider",
      name = "Reset delay",
      tooltip = "Increase the delay if you have issue with the addon not resetting properly",
      getFunc = function() return RR.sv.resetDelay end,
      setFunc = function(value)
        RR.sv.resetDelay = value
        RR.resetDelay = value
      end,
      min = 2000,
      max = 5000,
      step = 100,
      width = "full",
    },
  }

  LAM2:RegisterAddonPanel(RR.name .. "Menu", panelData)
  LAM2:RegisterOptionControls(RR.name .. "Menu", optionsData)
end

EVENT_MANAGER:RegisterForEvent(RR.name, EVENT_ADD_ON_LOADED, RR.OnAddOnLoaded)
