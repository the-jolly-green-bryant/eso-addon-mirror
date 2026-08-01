ZethExp = {}
ZethExp.name = "ZethExp"

function ZethExp:RestorePosition()
  local left = ZethExp.savedVariables.left
  local top = ZethExp.savedVariables.top
  ZethExpUI:ClearAnchors()
  ZethExpUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  ZethExpUI:SetHidden(not ZethExp.savedVariablesChar.enabled)
end

function ZethExp:Initialize()
  self.savedVariables = ZO_SavedVars:NewAccountWide("ZethExpSavedVariables", 1, nil, {})
  self.savedVariablesChar = ZO_SavedVars:NewCharacterIdSettings("ZethExpSavedVariablesChar", 1, nil, {enabled = true})
  self.RestorePosition()
  ZethExpTimeRemaining()
end

function ZethExpTimeRemaining()
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
      local zethSeconds = timeLeft % 60
      local zethMinutes = (math.floor(timeLeft / 60)) % 60
      local zethHours = math.floor(timeLeft / 60 / 60)
      if zethMinutes < 10 then
        zethMinutes = "0" .. zethMinutes
      end
      if zethSeconds < 10 then
        zethSeconds = "0" .. zethSeconds
      end
      zethText = buffName .. ": " .. zethHours .. ":" .. zethMinutes .. ":" .. zethSeconds
      if buffName:find("Experience") then
        ZethExpUI_Icon:SetTexture("esoui/art/icons/store_experiencescroll_001.dds")
      elseif buffName:find("Ambrosia") then
        ZethExpUI_Icon:SetTexture("esoui/art/icons/quest_potion_001.dds")
      end
      --d(buffName.. ": " .. duration.. ": " .. timeLeft.. " "..indexXPBuff) --for testing only
      ZethExpUILabel:SetText(zethText)
      if timeLeft > 300 then
        ZethExpUILabel:SetColor(0.5, 1, 0.5)
      else
        ZethExpUILabel:SetColor(1, 1, 0.5)
      end
    else
      ZethExpUILabel:SetText("No Experience Buff!")
      ZethExpUILabel:SetColor(1, 0.5, 0.5)
      ZethExpUI_Icon:SetTexture("esoui/art/icons/icon_experience.dds")
    end
  end
    if ZethExp.savedVariablesChar.enabled then
      zo_callLater(function()ZethExpTimeRemaining()end,500)
    end
end

function ZethExp.OnAddOnLoaded(event, addonName)
  if addonName == ZethExp.name then
    ZethExp:Initialize()
  end
end

function ZethExp.OnMoveStopUI()
  ZethExp.savedVariables.left = ZethExpUI:GetLeft()
  ZethExp.savedVariables.top = ZethExpUI:GetTop()
end

SLASH_COMMANDS["/zethexp"] = function (optionDisable)
  optionDisable = optionDisable:lower()
  if optionDisable == "off" then
    ZethExp.savedVariablesChar.enabled = false
    d("ZethExp is now disabled")
    ZethExpUI:SetHidden(true)
  elseif optionDisable == "on" then
    ZethExp.savedVariablesChar.enabled = true
    d("ZethExp is now enabled")
    ZethExpUI:SetHidden(false)
    ZethExpTimeRemaining()
  else
    d("/zethexp on - to turn on Exp Scroll reminder")
    d("/zethexp of - to turn off Exp Scroll reminder")
    if ZethExp.savedVariablesChar.enabled then
      d("ZethExp is currently ON")
    else
      d("ZethExp is currently OFF")
    end
  end
end

EVENT_MANAGER:RegisterForEvent(ZethExp.name, EVENT_ADD_ON_LOADED, ZethExp.OnAddOnLoaded)
