ZeebsOffTaunt = {}
ZeebsOffTaunt.name = "ZeebsOffTaunt"
ZeebsOffTaunt.variableVersion = 1

ZeebsOffTaunt.debug = false
ZeebsOffTaunt.defaults = {
  overrideTimer = 3000,
  bosses = {},
}

function ZeebsOffTaunt.DebugMessage(label, text)
  if ZeebsOffTaunt.debug then
    d("[DEBUG][" .. label .. "] " .. text)
  end
end

function ZeebsOffTaunt.Initialize()
  ZeebsOffTaunt.SV = ZO_SavedVars:New(ZeebsOffTaunt.name .. "Vars", ZeebsOffTaunt.variableVersion, nil, ZeebsOffTaunt.defaults)

  ZeebsOffTaunt.PreHook()
  ZeebsOffTaunt.BuildMenu()
end

function ZeebsOffTaunt.PreHook()
  for k, tauntId in pairs(ZeebsOffTaunt.taunts) do
    LibSkillBlocker.RegisterSkillBlock(ZeebsOffTaunt.name, tauntId, ZeebsOffTaunt.HandleSkillBlock)
  end
end

function ZeebsOffTaunt.HandleSkillBlock(slotNum, abilityId, lastTrigger)
  if not lastTrigger then return end

  if lastTrigger then
    local time = GetGameTimeMilliseconds() - lastTrigger
    ZeebsOffTaunt.DebugMessage("HandleSkillBlock.lastTrigger", time)
    if time > 500 then
      return false
    end
  end

  local shouldBlock = ZeebsOffTaunt.SV.bosses[GetUnitNameHighlightedByReticle()]
  if not shouldBlock then return false end

  ZeebsOffTaunt.DebugMessage("HandleSkillBlock.permit", GetAbilityName(abilityId) .. " : " .. abilityId)
  return true
end

function ZeebsOffTaunt.OnAddOnLoaded(_, addonName)
  if addonName ~= ZeebsOffTaunt.name then return end
  EVENT_MANAGER:UnregisterForEvent(ZeebsOffTaunt.name, EVENT_ADD_ON_LOADED)
  ZeebsOffTaunt.Initialize()
end

EVENT_MANAGER:RegisterForEvent(ZeebsOffTaunt.name, EVENT_ADD_ON_LOADED, ZeebsOffTaunt.OnAddOnLoaded)
