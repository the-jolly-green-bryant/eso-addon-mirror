BredaExp = {}
BredaExp.name = "BredaExp"

function BredaExp:RestorePosition()
  local left = BredaExp.savedVariables.left
  local top = BredaExp.savedVariables.top
  BredaExpUI:ClearAnchors()
  BredaExpUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
  BredaExpUI:SetHidden(not BredaExp.savedVariablesChar.enabled)
end

function BredaExp:Initialize()
  self.savedVariables = ZO_SavedVars:NewAccountWide("BredaExpSavedVariables", 1, nil, {})
  self.savedVariablesChar = ZO_SavedVars:NewCharacterIdSettings("BredaExpSavedVariablesChar", 1, nil, {enabled = true})
  self.RestorePosition()
  BredaExpTimeRemaining()
end

function BredaExpTimeRemaining()
  local numBuffs = GetNumBuffs("player")
  local hasActiveEffects = numBuffs > 0
  local indexXPBuff = 0
  if hasActiveEffects then
    for i = 1, numBuffs do
      local checkBuffName = GetUnitBuffInfo("player", i)
      if checkBuffName:find("Breda") then
        indexXPBuff = i
		buffGoneText = "TIME TO DRINK UP, BITCH!"
      elseif checkBuffName:find("Jester") then
        indexXPBuff = i
		buffGoneText = "TIME TO EAT UP, BITCH!"
	  end
    end
    if indexXPBuff ~= 0 then
      local buffName, startTime, endTime = GetUnitBuffInfo("player", indexXPBuff)
      local timeLeft = math.floor(((endTime * 1000.0) - GetFrameTimeMilliseconds())/1000)
      --local duration = endTime - startTime --for testing only
      local bredaSeconds = timeLeft % 60
      local bredaMinutes = (math.floor(timeLeft / 60)) % 60
      local bredaHours = math.floor(timeLeft / 60 / 60)
      if bredaMinutes < 10 then
        bredaMinutes = "0" .. bredaMinutes
      end
      if bredaSeconds < 10 then
        bredaSeconds = "0" .. bredaSeconds
      end
      bredaText = buffName .. ": " .. bredaHours .. ":" .. bredaMinutes .. ":" .. bredaSeconds
      if buffName:find("Breda") then
		BredaExpUI_Icon:SetTexture("esoui/art/icons/housing_alt_inc_mug001.dds")
      elseif buffName:find("Jester") then
        BredaExpUI_Icon:SetTexture("esoui/art/icons/hat_jestersfestcap_01.dds")
      end
      --d(buffName.. ": " .. duration.. ": " .. timeLeft.. " "..indexXPBuff) --for testing only
      BredaExpUILabel:SetText(bredaText)
      if timeLeft > 300 then
        BredaExpUILabel:SetColor(0.5, 1, 0.5)
      else
        BredaExpUILabel:SetColor(1, 1, 0.5)
      end
    else
      BredaExpUILabel:SetText("TIME TO DRINK UP, BITCH!")
      BredaExpUILabel:SetColor(1, 0.5, 0.5)
      BredaExpUI_Icon:SetTexture("esoui/art/icons/icon_experience.dds")
    end
  end
    if BredaExp.savedVariablesChar.enabled then
      zo_callLater(function()BredaExpTimeRemaining()end,500)
    end
end

function BredaExp.OnAddOnLoaded(event, addonName)
  if addonName == BredaExp.name then
    BredaExp:Initialize()
  end
end

function BredaExp.OnMoveStopUI()
  BredaExp.savedVariables.left = BredaExpUI:GetLeft()
  BredaExp.savedVariables.top = BredaExpUI:GetTop()
end

SLASH_COMMANDS["/BredaExp"] = function (optionDisable)
  optionDisable = optionDisable:lower()
  if optionDisable == "off" then
    BredaExp.savedVariablesChar.enabled = false
    d("BredaExp is now disabled")
    BredaExpUI:SetHidden(true)
  elseif optionDisable == "on" then
    BredaExp.savedVariablesChar.enabled = true
    d("BredaExp is now enabled")
    BredaExpUI:SetHidden(false)
    BredaExpTimeRemaining()
  else
    d("/BredaExp on - to turn on Event XP item reminder")
    d("/BredaExp off - to turn off Event XP item reminder")
    if BredaExp.savedVariablesChar.enabled then
      d("BredaExp is currently ON")
    else
      d("BredaExp is currently OFF")
    end
  end
end

EVENT_MANAGER:RegisterForEvent(BredaExp.name, EVENT_ADD_ON_LOADED, BredaExp.OnAddOnLoaded)
