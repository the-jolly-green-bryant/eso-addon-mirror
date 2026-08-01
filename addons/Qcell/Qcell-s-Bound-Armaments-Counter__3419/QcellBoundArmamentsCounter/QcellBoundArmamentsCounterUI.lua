QBAC = QBAC or {}
local QBAC = QBAC

function QBAC.OnUIMove()
  -- save position
  QBAC.savedVariables.left = QBACUI:GetLeft()
  QBAC.savedVariables.top = QBACUI:GetTop()
end

function QBAC.RestorePosition()
  if QBAC.savedVariables.left ~= nil then
    QBACUI:ClearAnchors()
    QBACUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        QBAC.savedVariables.left,
        QBAC.savedVariables.top)
  end
  QBAC.LoadSavedScale()
  QBAC.LoadSavedAlpha()
  QBAC.LoadSimpleMode()
end

function QBAC.ChangeStacks(numStacks)
  if numStacks == nil or  numStacks < 0 or numStacks > 4 then
    return
  end

  QBACUIStacks:SetText(tostring(numStacks))
  QBAC.status.stacks = numStacks

  -- Set border
  if numStacks == 0 then
    QBACUITextureBorder:SetCenterColor(0,0,0,0.5)
    QBACUIStacks:SetColor(1,1,1,1)
  elseif numStacks <= 2 then
    QBACUITextureBorder:SetCenterColor(1,1,1,0.5)
    QBACUIStacks:SetColor(1,1,1,1)
  elseif numStacks == 3 then
    QBACUITextureBorder:SetCenterColor(1,1,0,0.5)
    QBACUIStacks:SetColor(1,1,0,1)
  elseif numStacks == 4 then
    QBACUITextureBorder:SetCenterColor(0,1,0,0.5)
    QBACUIStacks:SetColor(0,1,0,1)
  end

  if numStacks < 4 and QBAC.GetTargetHealth() > QBAC.savedVariables.unblockHPThreshold/100 then
    QBAC.BlockCast()
  else
    QBAC.UnblockCast()
  end
end

function QBAC.TurnOn()
  QBACUITexture:SetDesaturation(0)
  -- Turned it on, not at 4 stacks.
  if QBAC.status.stacks ~= 4 then
    QBAC.BlockCast()
  end
end

function QBAC.TurnOff()
  QBACUITexture:SetDesaturation(1)
  -- The skill ran out, let them cast it.
  QBAC.UnblockCast()
end

function QBAC.HideUI(hide)
  QBACUI:SetHidden(hide)
  QBAC.status.hidden = hide
end

function QBAC.LoadSavedScale()
  QBAC.SetScale(QBAC.savedVariables.uiCustomScale)
end

function QBAC.SetScale(scale)
  QBAC.savedVariables.uiCustomScale = scale

  -- Updating top controls scales all children.
  QBACUI:SetScale(QBAC.savedVariables.uiCustomScale)
end

function QBAC.LoadSavedAlpha()
  QBAC.SetAlpha(QBAC.savedVariables.textureAlpha)
end

function QBAC.SetAlpha(alpha)
  QBACUITexture:SetAlpha(alpha)
end

function QBAC.LoadSimpleMode()
  QBAC.SimpleMode(QBAC.savedVariables.simpleMode)
end

function QBAC.SimpleMode(state)
  QBAC.savedVariables.simpleMode = state
  QBACUITexture:SetHidden(state)
  QBACUITextureBorder:SetHidden(state)
end

function QBAC.SettingBlockCast(state)
  QBAC.savedVariables.blockCastLessThanFour = state
  if QBAC.savedVariables.blockCastLessThanFour == false then
    QBAC.ForceUnblockCast()
  end
end
