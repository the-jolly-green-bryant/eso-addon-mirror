-- AutoQueue namespace
local AutoQueue = _G['AutoQueue']

-- Addon details
AutoQueue.name = 'AutoQueue'
AutoQueue.version = '1.0.05'
AutoQueue.slash = '/autoqueue'

-- AutoQueue.db = 'AQStorage'
-- AutoQueue.dbVersion = 1

local Settings = AutoQueue.Settings

-- Addon initialization
function AutoQueue.Initialize(code, addon)
  if addon ~= AutoQueue.name then return end

  EVENT_MANAGER:UnregisterForEvent(AutoQueue.name, EVENT_ADD_ON_LOADED)
  SLASH_COMMANDS[AutoQueue.slash] = AutoQueue.SlashCommand

  AutoQueue.Settings.vars = ZO_SavedVars:NewAccountWide('AQStorage', 1, nil, Settings.default)

  AutoQueue.Handler.Initialize()
end

function AutoQueue.SlashCommand(params)
  if params == '' then
    Settings.SetAutoQueue(not Settings.vars.autoQueue)
    return
  end

  if params:lower() == 'mute' then
    Settings.MuteAutoQueue(not Settings.vars.muted)
    return
  end

  if params:lower() == 'help' then
    d('/autoqueue - Toggles the addon')
    d('/autoqueue mute - Mutes the addon when it accepts queues')
    return
  end
end

EVENT_MANAGER:RegisterForEvent(AutoQueue.name, EVENT_ADD_ON_LOADED, AutoQueue.Initialize)
