--TODO beschreibungen menu

EAS = EAS or {}
EAS.name = "ExoYsAutoSheathe"
EAS.displayName = "|c00FF00ExoY|rs Auto Sheathe"
EAS.author = "@|c00FF00ExoY|r94 (PC/EU)"
EAS.version = "4.0"
EAS.event = GetEventManager()

local defaults = {
      deactivateInAdvancedPvE= true,
      deactivateInPvP = true,
      delay = 3000,
      debug = false,
      interval = 100,
    }

function OnAddOnLoaded(event, addonName)
  if addonName == EAS.name then
    local self = EAS

    self.store = ZO_SavedVars:NewAccountWide("EASSV", 3, nil, defaults)

    self.CreateMenu()

    -- initialize variable
    self.inDuel = false
    self.overwrite = false
    self.lastAction = 0

    -- register events
    self.event:RegisterForEvent(self.name, EVENT_DUEL_COUNTDOWN, function() self.inDuel = true end)
    self.event:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnCombatState)
    self.event:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    self.event:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED, self.OnAction)
    self.event:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, self.OnAction)

    -- unregister initialization
    self.event:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
  end

  ZO_PreHook("TogglePlayerWield", function()
      --EAS.OnAction(3000)
    return false
  end)
end
EAS.event:RegisterForEvent(EAS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

function EAS.OnPlayerActivated()
  EAS.HandleCurrentLocation()
  EAS.sheathed = ArePlayerWeaponsSheathed()
end


function EAS.OnCombatState(_, enteredCombat)
  local self = EAS
  if enteredCombat then
    self.inCombat = true
  else
    self.inCombat = false
    self.OnAction()
    self.inDuel = false
  end
end


function EAS.HandleCurrentLocation()
  local self = EAS

  local function IsForCurrentLocationRequired()
    if ( IsActiveWorldBattleground() or IsPlayerInAvAWorld() ) and self.store.deactivateInPvP then return false end
    if GetCurrentZoneDungeonDifficulty() ~= 0 and self.store.deactivateInAdvancedPvE then return false end
    return true
  end

  local isRequired = IsForCurrentLocationRequired()
  if self.updateActive == isRequired then return end

  if isRequired then
    self.updateActive = true
    self.event:RegisterForUpdate(self.name, self.store.interval, self.OnUpdate)
  else
    self.updateActive = false
    self.event:UnregisterForUpdate(self.name)
  end
end


function EAS.OnAction(add)
  EAS.lastAction = GetGameTimeMilliseconds()
end


function EAS.OnUpdate()
  local self = EAS
  --d("GameTime: "..GetGameTimeMilliseconds())
  --d("lastAction: "..self.lastAction)
  --d("diff: "..tostring(GetGameTimeMilliseconds() - self.lastAction))
  --d("-------")

  -- early outs
  if self.overwrite then return end
  if self.inCombat then return end
  if self.inDuel then return end
  if IsBlockActive() then self.OnAction() return end
  if ( GetGameTimeMilliseconds() - self.lastAction ) < self.store.delay then return end   -- delay after action (block, cast)

  if not ArePlayerWeaponsSheathed() and self.sheathed then
    self.sheathed = false
    self.OnAction()
    return
  end

  if not ArePlayerWeaponsSheathed() then
    TogglePlayerWield()
    self.sheathed = true
  end
end




--------------------
-- Overwrite Mode --
--------------------

ZO_CreateStringId("SI_BINDING_NAME_EAS_TOGGLE_OVERWRITE", "Toggle Overwrite")

function EAS.ToggleOverwrite()
  EAS.overwrite = not EAS.overwrite
  EAS.OutputModusStatus("Overwrite", EAS.overwrite)
end

SLASH_COMMANDS["/eas"] = EAS.ToggleOverwrite

function EAS.OutputModusStatus(modus, status)
  output = "Auto Sheathe "..tostring(modus).. " Mode: "
  if status then
    output = output.."Activated"
  else
    output = output.."Deactivated"
  end
  d(output)
end


function EAS.CreateMenu()
  local self = EAS

  local panelData = {
    type = "panel",
    name = self.displayName,
    displayName = self.displayName,
    author = self.author,
    version = self.version,

    slashCommand = "/eas_menu",
    registerForRefresh = true,
    --registerForDefaults = true,
    }

  local optionsData = {
    {
        type = "slider",
        name = "Interval (ms)",
        tooltip = "Sets the interval in which is checked for drawn weapons. \n (default = 100)",
        min = 1,
        max = 1000,
        step = 50,
        getFunc = function() return self.store.interval end,
        setFunc = function( value )
          self.store.interval = value
        end,
        width = "half",
        warning = "Reloadui is required for changes to take affect."

    },
    {
        type = "button",
        name = "Restore Default",
        tooltip = "",
        func = function()
                  self.store.delay = defaults.delay
                  self.store.interval = defaults.interval
                end,
        width = "half",
    },
    {
        type = "slider",
        name = "Delay (seconds)",
        tooltip = "SSets the delay when weapons are sheathed after an action. Actions are leaving combat, weapon attacks, skills and block. \n (default = 3)",
        min = 1,
        max = 10,
        step = 0.5,	--(optional)
        getFunc = function() return self.store.delay / 1000 end,
        setFunc = function( value )
          self.store.delay = value*1000
        end,
        width = "half",
    },
    {
        type = "divider",
        width = "full",
    },
    {
        type = "checkbox",
        name = "Deactivate in advanced PvE",
        tooltip = "Disables the addon in arena, dungoen and raid. \n (default = ON)",
        getFunc = function() return self.store.deactivateInAdvancedPvE end,
        setFunc = function( value )
          self.store.deactivateInAdvancedPvE= value
        end,
        width = "full",
        --warning = "Will need to reload the UI.",	--(optional)
    },
    {
        type = "checkbox",
        name = "Deactivate in PvP",
        tooltip = "Disables the addon in battlegrounds, Cyrodiil and Imperial City. \n (default = ON)",
        getFunc = function() return self.store.deactivateInPvP end,
        setFunc = function( value )
            self.store.deactivateInPvP = value
        end,
        width = "full",
        --warning = "Will need to reload the UI.",	--(optional)
    },
    {
        type = "divider",
        width = "full",
    },
    {
        type = "header",
        name = "Overwrite Mode",
        width = "half",	--or "half" (optional)
    },
    {
        type = "button",
        name = "Toggle Overwrite",
        tooltip = "",
        func = function()
                  self.ToggleOverwrite()
                end,
        width = "half",
    },
    {
        type = "description",
        text = "The |c00ffffOverwrite Mode|r allows you to temporarily disable automatically sheathing your weapons. It can be toggled using the chat command |c00ffff/esa|r or by assigning a hotkey. \n A relog or reload will automatically deactivate the Overwrite Mode.",
        width = "full",
    },
  }

  LibAddonMenu2:RegisterAddonPanel("EAS_Settings", panelData)
  LibAddonMenu2:RegisterOptionControls("EAS_Settings", optionsData)
end
