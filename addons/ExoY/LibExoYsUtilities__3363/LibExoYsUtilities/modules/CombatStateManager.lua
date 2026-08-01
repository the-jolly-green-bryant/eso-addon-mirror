LibExoYsUtilities = LibExoYsUtilities or {}
local LibExoY = LibExoYsUtilities

local CM = ZO_CallbackObject:New()

local combatStartCallbackList = {}
local combatEndCallbackList = {}
local CombatState = {
  delay = 700,
  start = GetGameTimeMilliseconds(),
  duration = 0,
  inCombat = false,
}

--[[ ----------------------- ]]
--[[ -- Exposed Functions -- ]]
--[[ ----------------------- ]]

function LibExoY.RegisterCombatStart(callback)
  if not LibExoY.IsFunc(callback) then return end
  CM:RegisterCallback('CombatStart', callback)
end

function LibExoY.UnregisterCombatStart(callback)
  if not LibExoY.IsFunc(callback) then return end
  CM:UnregisterCallback('CombatStart', callback)
end

function LibExoY.RegisterCombatEnd(callback)
  if not LibExoY.IsFunc(callback) then return end
  CM:RegisterCallback('CombatEnd', callback)
end

function LibExoY.UnregisterCombatEnd(callback)
  if not LibExoY.IsFunc(callback) then return end
  CM:UnregisterCallback('CombatEnd', callback)
end

function LibExoY.GetCombatStartTime()
  return CombatState.inCombat and CombatState.start or 0
end

function LibExoY.GetLastCombatDuration()
  return CombatState.duration
end

function LibExoY.GetCurrentCombatDuration()
  return CombatState.inCombat and GetGameTimeMilliseconds() - CombatState.start or 0
end

function LibExoY.IsInCombat()
  return CombatState.inCombat
end


--[[ ------------------------- ]]
--[[ -- Combat State Manager --]]
--[[ ------------------------- ]]

local function OnPlayerCombatState(_, inCombat)

  local function ExecuteCallback(callback)
    if type(callback) == "function" then
      callback(inCombat)
    end
  end

  local function OnCombatStart()
    CombatState.inCombat = true
    CombatState.start = GetGameTimeMilliseconds()
    CM:FireCallbacks('CombatStart')
  end

  local function OnCombatEnd()
    CombatState.inCombat = false
    CombatState.duration = GetGameTimeMilliseconds() - CombatState.start
    CM:FireCallbacks('CombatEnd')

  end

  if CombatState.callback then
    zo_removeCallLater(CombatState.callback)
    if inCombat then
      return
    end
  end
  if inCombat then
    OnCombatStart()
  else
    CombatState.callback = zo_callLater( function()
      CombatState.callback = nil
      OnCombatEnd()
    end, CombatState.delay)
  end

end

local function Initialize()
  local EM = GetEventManager()
  EM:RegisterForEvent( LibExoY.name.."CombatState", EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState )
  if IsUnitInCombat("player") then OnPlayerCombatState(_, true) end
end

LibExoY.CombatStateManager_InitFunc = Initialize
