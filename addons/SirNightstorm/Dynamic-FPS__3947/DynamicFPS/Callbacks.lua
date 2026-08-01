local Callback = {}

local callbacks = {}

local function logCallback(eventCode, message)
  if message ~= nil then
    message = " ("..message..")"
  else
    message = "."
  end
  if DynamicFPS.isInDialog then
    message = message.." (inDialog)"
  elseif DynamicFPS.isScrying then
    message = message.." (isScrying)"
  end
  if callbacks[eventCode] ~= nil then
    DynamicFPS.LogDebug("> "..callbacks[eventCode].name..message)
  else
    DynamicFPS.LogDebug("> Event "..eventCode..message)
  end
end

function Callback.OnCombatState(_, inCombat)
  DynamicFPS.isInCombat = inCombat
  DynamicFPS.isScrying = false
  DynamicFPS.lastActiveTime = GetGameTimeSeconds()
  DynamicFPS.SetActive()
end

function Callback.OnDialogBegin(eventCode)
  DynamicFPS.isInDialog = true
  DynamicFPS.isScrying = false
  logCallback(eventCode)
  DynamicFPS.SetActive()
end

function Callback.OnDialogEnd(eventCode)
  DynamicFPS.isInDialog = false
  DynamicFPS.isScrying = false
  logCallback(eventCode)
  DynamicFPS.SetActive()
end

function Callback.OnScryingResult(eventCode, result)
  if result == 0 then
    DynamicFPS.isScrying = true
    logCallback(eventCode, "result="..result)
  end
  DynamicFPS.SetActive()
end

function Callback.OnScryingExit(eventCode, accept)
  if accept then
    DynamicFPS.isScrying = false
    logCallback(eventCode, "accept="..tostring(accept))
  end
  DynamicFPS.SetActive()
end

function Callback.OnEvent(eventCode)
  logCallback(eventCode)
  DynamicFPS.SetActive()
end

function Callback.OnLogoutHook(_)
  if not DynamicFPS.savedVars.enabled then return end
  DynamicFPS.LogInfo("onLogout; restoring to "..DynamicFPS.savedVars.fixedFPS.."fps")
  DynamicFPS.paused = true
  SetCVar("MinFrameTime.2", ""..(1 / DynamicFPS.savedVars.fixedFPS))
end

function Callback.OnLogoutCanceledHook(_)
  if not DynamicFPS.savedVars.enabled then return end
  DynamicFPS.LogInfo("onLogoutCanceled")
  DynamicFPS.paused = false
  DynamicFPS.SetActive()
end

-- --- @return table
-- function DynamicFPS.GetCallbacks()
--   return callbacks
-- end

function DynamicFPS.RegisterCallbacks()
  if DynamicFPS.callbacksRegistered then return end

  for eventCode, data in pairs(callbacks) do
    if data.callback ~= nil then
      DynamicFPS.LogDebug(eventCode..": "..data.name .. ": callback")
      EVENT_MANAGER:RegisterForEvent(DynamicFPS.name..data.name, eventCode, data.callback)
    else
      DynamicFPS.LogDebug(eventCode..": "..data.name .. ": setActiveOnEvent")
      EVENT_MANAGER:RegisterForEvent(DynamicFPS.name..data.name, eventCode, Callback.OnEvent)
    end
  end

  if not DynamicFPS.hooksRegistered then
    ZO_PreHook("Logout", Callback.OnLogoutHook)
    ZO_PreHook("Quit", Callback.OnLogoutHook)
    ZO_PreHook("CancelLogout", Callback.OnLogoutCanceledHook)
    DynamicFPS.hooksRegistered = true
  end

  DynamicFPS.callbacksRegistered = true
end

function DynamicFPS.UnregisterCallbacks()
  if not DynamicFPS.callbacksRegistered then return end

  for eventCode, _ in pairs(callbacks) do
    EVENT_MANAGER:UnregisterForEvent(DynamicFPS.name, eventCode)
  end
end

callbacks = {
  [EVENT_PLAYER_COMBAT_STATE] = { callback = Callback.OnCombatState, name = "CombatState" },

  [EVENT_PLAYER_ACTIVATED] = { name = "PlayerActivated" },
  [EVENT_NEW_MOVEMENT_IN_UI_MODE] = { name = "UIMovement" },
  [EVENT_GLOBAL_MOUSE_DOWN] = { name = "MouseDown" },
  [EVENT_GLOBAL_MOUSE_UP] = { name = "MouseUp" },
  [EVENT_ACTION_LAYER_POPPED] = { name = "LayerPopped" },
  [EVENT_ACTION_LAYER_PUSHED] = { name = "LayerPushed" },
  [EVENT_END_FAST_TRAVEL_INTERACTION] = { name = "EndFastTravel" },
  [EVENT_END_FAST_TRAVEL_KEEP_INTERACTION] = { name = "EndFastTravelKeep" },
  [EVENT_CLIENT_INTERACT_RESULT] = { name = "ClientInteract" },

  -- NPC conversation screens
  [EVENT_CHATTER_BEGIN] = { callback = Callback.OnDialogBegin, name = "ChatterBegin" },
  [EVENT_CONVERSATION_UPDATED] = { name = "ConversationUpdated" },
  [EVENT_QUEST_OFFERED] = { name = "QuestOffered" },
  [EVENT_QUEST_COMPLETE_DIALOG] = { name = "QuestComplete" },
  [EVENT_CHATTER_END] = { callback = Callback.OnDialogEnd, name = "ChatterEnd" },

  -- Antiquity scrying screen
  [EVENT_ANTIQUITY_SCRYING_RESULT] = { callback = Callback.OnScryingResult, name = "AntiquityScryResult"},
  [EVENT_SCRYING_EXIT_RESPONSE] = { callback = Callback.OnScryingExit, name = "AntiquityScryExit"},

  -- Antiquity dig screen
  [EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY] = { callback = Callback.OnDialogBegin, name = "AntiquityDigReady"},
  [EVENT_ANTIQUITY_DIGGING_EXIT_RESPONSE] = { callback = Callback.OnDialogEnd, name = "AntiquityDigExit"},
  [EVENT_ANTIQUITY_DIGGING_NUM_RADARS_REMAINING_CHANGED] = { name = "AntiquityDigRadars"},
  [EVENT_ANTIQUITY_DIG_SPOT_DIG_POWER_CHANGED] = { name = "AntiquityDigPowerChanged"},
  [EVENT_ANTIQUITY_DIGGING_MOUSE_OVER_ACTIVE_SKILL_CHANGED] = { name = "AntiquityDigMouseOver" }
}