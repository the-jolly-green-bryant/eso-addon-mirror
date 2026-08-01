OffTaunt = {}
OffTaunt.name = "OffTaunt"
OffTaunt.variableVersion = 1

OffTaunt.debug = false
OffTaunt.defaults = {
  overrideTimer = 500,
  bosses = {},
}

function OffTaunt.DebugMessage(label, text)
  if OffTaunt.debug then
    d("[DEBUG][" .. label .. "] " .. text)
  end
end

function OffTaunt.Initialize()
  OffTaunt.SV = ZO_SavedVars:New(OffTaunt.name .. "Vars", OffTaunt.variableVersion, nil, OffTaunt.defaults)

  OffTaunt.PreHook()
  OffTaunt.BuildMenu()
end

function OffTaunt.PreHook()
  for k, tauntId in pairs(OffTaunt.taunts) do
    LibSkillBlocker.RegisterSkillBlock(OffTaunt.name, tauntId, OffTaunt.HandleSkillBlock)
  end
end

function OffTaunt.HandleSkillBlock(slotNum, abilityId, lastTrigger)
  if not lastTrigger then return end

  if lastTrigger then
    local time = GetGameTimeMilliseconds() - lastTrigger
    OffTaunt.DebugMessage("HandleSkillBlock.lastTrigger", time)
    if time > 500 then
      return false
    end
  end

  local shouldBlock = OffTaunt.SV.bosses[GetUnitNameHighlightedByReticle()]
  if not shouldBlock then return false end

  OffTaunt.DebugMessage("HandleSkillBlock.permit", GetAbilityName(abilityId) .. " : " .. abilityId)
  return true
end

function OffTaunt.OnAddOnLoaded(_, addonName)
  if addonName ~= OffTaunt.name then return end
  EVENT_MANAGER:UnregisterForEvent(OffTaunt.name, EVENT_ADD_ON_LOADED)
  OffTaunt.Initialize()
end

EVENT_MANAGER:RegisterForEvent(OffTaunt.name, EVENT_ADD_ON_LOADED, OffTaunt.OnAddOnLoaded)
