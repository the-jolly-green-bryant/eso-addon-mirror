local AutoQueue = _G['AutoQueue']
AutoQueue.Settings = {}

local Settings = AutoQueue.Settings

Settings.default = {
  autoQueue = true,
  muted = false
}

function Settings.SetAutoQueue(bool)
  Settings.vars.autoQueue = bool
  d('Auto queue is now turned ' .. (bool and 'on' or 'off'))
end

function Settings.MuteAutoQueue(bool)
  Settings.vars.muted = bool
  d('You will ' .. (bool and 'no longer' or 'now')  .. ' receive notifications of accepted queues')
end