CC = {}
CC.name = "CCuite"
-- CC.IDs = {
--   [29721] = "Immobilize immunity",
--   [16566] = "CC immunity",
--   [45239] = "Unstoppable",
-- }

function CC.Initialize()
  EVENT_MANAGER:RegisterForUpdate('update', 100, CC.update)
  CC.savedVariables = ZO_SavedVars:New("CCSavedVariables", 1, nil, {})
  CC:RestorePosition()
end

function CC.time(nd)
  local time = math.floor((nd - GetGameTimeMilliseconds()/1000) * 10 + 0.5)/10
  if time < 0.15 then time = 0.0 end
  return time
end

function CC.update()
  local selfBuffs = GetNumBuffs('player')
  for i = 1, selfBuffs do
    local _,_,nd,_,_,_,_,_,_,_,ID = GetUnitBuffInfo('player', i)
    if ID == 29721 then -- dodge
      CCuiteWindowSelfImIm:SetText(string.format('%.1f',CC.time(nd)))
    elseif ID == 16566 then -- CC
      CCuiteWindowSelfCCIm:SetText(string.format('%.1f',CC.time(nd)))
    elseif ID == 45239 then
      CCuiteWindowSelfUnst:SetText(string.format('%.1f',CC.time(nd)))
      elseif ID == 38117 then
        CCuiteWindowSelfCCT:SetText(string.format('%.1f',CC.time(nd)))
    end
  end
  if GetUnitName('reticleover') ~= '' then
    local targBuffs = GetNumBuffs('reticleover')
    for i = 1, targBuffs do
      local _,_,nd,_,_,_,_,_,_,_,ID = GetUnitBuffInfo('reticleover', i)
      if ID == 29721 then -- dodge
        CCuiteWindowTargImIm:SetText(string.format('%.1f',CC.time(nd)))
      elseif ID == 16566 then -- CC
        CCuiteWindowTargCCIm:SetText(string.format('%.1f',CC.time(nd)))
      elseif ID == 45239 then
        CCuiteWindowTargUnst:SetText(string.format('%.1f',CC.time(nd)))
      elseif ID == 38117 then
        CCuiteWindowTargCCT:SetText(string.format('%.1f',CC.time(nd)))
      end
    end
  elseif GetUnitName('reticleover') == '' then
    CCuiteWindowTargImIm:SetText(string.format('0.0'))
    CCuiteWindowTargCCIm:SetText(string.format('0.0'))
    CCuiteWindowTargUnst:SetText(string.format('0.0'))
    CCuiteWindowTargCCT:SetText(string.format('0.0'))
  end
end

function CC.OnIndicatorMoveStop()
  CC.savedVariables.left = CCuiteWindow:GetLeft()
  CC.savedVariables.top = CCuiteWindow:GetTop()
end

function CC.RestorePosition()
  if CC.savedVariables.left and CC.savedVariables.top then
    local left = CC.savedVariables.left
    local top = CC.savedVariables.top

    CCuiteWindow:ClearAnchors()
    CCuiteWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  end
end 

function CC.onAddonLoaded(event, addonName)
  if addonName == CC.name then
    zo_callLater(function()d("CCuite Loaded")end, 4000)
    CC.Initialize()
  end
end

EVENT_MANAGER:RegisterForEvent(CC.name, EVENT_ADD_ON_LOADED, CC.onAddonLoaded)
