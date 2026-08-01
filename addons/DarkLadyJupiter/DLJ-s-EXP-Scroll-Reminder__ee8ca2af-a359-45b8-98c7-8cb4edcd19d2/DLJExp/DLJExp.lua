DLJExp = {}
DLJExp.name = "DLJExp"

function DLJExp:RestorePosition()
  local left = DLJExp.savedVariables.left
  local top = DLJExp.savedVariables.top
  DLJExpUI:ClearAnchors()
  DLJExpUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  DLJExpUI:SetHidden(not DLJExp.savedVariablesChar.enabled)
end

function DLJExp:Initialize()
  self.savedVariables = ZO_SavedVars:NewAccountWide("DLJExpSavedVariables", 1, nil, {})
  self.savedVariablesChar = ZO_SavedVars:NewCharacterIdSettings("DLJExpSavedVariablesChar", 1, nil, {enabled = true})
  self.RestorePosition()
  DLJExpTimeRemaining()
end

function DLJExpTimeRemaining()
  local numBuffs = GetNumBuffs("player")
  local hasActiveEffects = numBuffs > 0
  local indexXPBuff = 0
  if hasActiveEffects then
    for i = 1, numBuffs do
      local checkBuffName = GetUnitBuffInfo("player", i)
      if checkBuffName:find("Experience") then
        indexXPBuff = i
      elseif checkBuffName:find("Ambrosia") then
        indexXPBuff = i
      end
    end
    if indexXPBuff ~= 0 then
      local buffName, startTime, endTime = GetUnitBuffInfo("player", indexXPBuff)
      local timeLeft = math.floor(((endTime * 1000.0) - GetFrameTimeMilliseconds())/1000)
      --local duration = endTime - startTime --for testing only
      local dljSeconds = timeLeft % 60
      local dljMinutes = (math.floor(timeLeft / 60)) % 60
      local dljHours = math.floor(timeLeft / 60 / 60)
      if dljMinutes < 10 then
        dljMinutes = "0" .. dljMinutes
      end
      if dljSeconds < 10 then
        dljSeconds = "0" .. dljSeconds
      end
      dljText = buffName .. ": " .. dljHours .. ":" .. dljMinutes .. ":" .. dljSeconds
      if buffName:find("Experience") then
        DLJExpUI_Icon:SetTexture("esoui/art/icons/store_experiencescroll_001.dds")
      elseif buffName:find("Ambrosia") then
        DLJExpUI_Icon:SetTexture("esoui/art/icons/quest_potion_001.dds")
      end
      --d(buffName.. ": " .. duration.. ": " .. timeLeft.. " "..indexXPBuff) --for testing only
      DLJExpUILabel:SetText(dljText)
      if timeLeft > 300 then
        DLJExpUILabel:SetColor(0.5, 1, 0.5)
      else
        DLJExpUILabel:SetColor(1, 1, 0.5)
      end
    else
      DLJExpUILabel:SetText("No Experience Buff!")
      DLJExpUILabel:SetColor(1, 0.5, 0.5)
      DLJExpUI_Icon:SetTexture("esoui/art/icons/icon_experience.dds")
    end
  end
    if DLJExp.savedVariablesChar.enabled then
      zo_callLater(function()DLJExpTimeRemaining()end,500)
    end
end

function DLJExp.OnAddOnLoaded(event, addonName)
  if addonName == DLJExp.name then
    DLJExp:Initialize()
  end
end

function DLJExp.OnMoveStopUI()
  DLJExp.savedVariables.left = DLJExpUI:GetLeft()
  DLJExp.savedVariables.top = DLJExpUI:GetTop()
end

SLASH_COMMANDS["/DLJexp"] = function (optionDisable)
  optionDisable = optionDisable:lower()
  if optionDisable == "off" then
    DLJExp.savedVariablesChar.enabled = false
    d("DLJExp is now disabled")
    DLJExpUI:SetHidden(true)
  elseif optionDisable == "on" then
    DLJExp.savedVariablesChar.enabled = true
    d("DLJExp is now enabled")
    DLJExpUI:SetHidden(false)
    DLJExpTimeRemaining()
  else
    d("/dljexp on - to turn on Exp Scroll reminder")
    d("/dljexp of - to turn off Exp Scroll reminder")
    if DLJExp.savedVariablesChar.enabled then
      d("DLJExp is currently ON")
    else
      d("DLJExp is currently OFF")
    end
  end
end

EVENT_MANAGER:RegisterForEvent(DLJExp.name, EVENT_ADD_ON_LOADED, DLJExp.OnAddOnLoaded)
