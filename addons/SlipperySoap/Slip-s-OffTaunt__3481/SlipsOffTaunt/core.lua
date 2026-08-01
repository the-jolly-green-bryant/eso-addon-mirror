SlipsOffTaunt = {}
SlipsOffTaunt.name = "SlipsOffTaunt"
SlipsOffTaunt.variableVersion = 1

SlipsOffTaunt.debug = false
SlipsOffTaunt.defaults = {
  overrideTimer = 3000,
  bosses = {},
}

function SlipsOffTaunt.DebugMessage(label, text)
  if SlipsOffTaunt.debug then
    d("[DEBUG][" .. label .. "] " .. text)
  end
end

function SlipsOffTaunt.Initialize()
  SlipsOffTaunt.SV = ZO_SavedVars:New(SlipsOffTaunt.name .. "Vars", SlipsOffTaunt.variableVersion, nil, SlipsOffTaunt.defaults)

  SlipsOffTaunt.PreHook()
  SlipsOffTaunt.BuildMenu()
end

function SlipsOffTaunt.PreHook()
  for k, tauntId in pairs(SlipsOffTaunt.taunts) do
    LibSkillBlocker.RegisterSkillBlock(SlipsOffTaunt.name, tauntId, SlipsOffTaunt.HandleSkillBlock)
  end
end

function SlipsOffTaunt.HandleSkillBlock(slotNum, abilityId, lastTrigger)
  if not lastTrigger then return end

  if lastTrigger then
    local time = GetGameTimeMilliseconds() - lastTrigger
    SlipsOffTaunt.DebugMessage("HandleSkillBlock.lastTrigger", time)
    if time > 500 then
      return false
    end
  end

  local shouldBlock = SlipsOffTaunt.SV.bosses[GetUnitNameHighlightedByReticle()]
  if not shouldBlock then return false end

  SlipsOffTaunt.DebugMessage("HandleSkillBlock.permit", GetAbilityName(abilityId) .. " : " .. abilityId)
  return true
end

function SlipsOffTaunt.OnAddOnLoaded(_, addonName)
  if addonName ~= SlipsOffTaunt.name then return end
  EVENT_MANAGER:UnregisterForEvent(SlipsOffTaunt.name, EVENT_ADD_ON_LOADED)
  SlipsOffTaunt.Initialize()
end

EVENT_MANAGER:RegisterForEvent(SlipsOffTaunt.name, EVENT_ADD_ON_LOADED, SlipsOffTaunt.OnAddOnLoaded)
