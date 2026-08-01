QDRH = QDRH or {}
local QDRH = QDRH

function QDRH.OnQDRHMessage1Move()
  QDRH.savedVariables.message1Left = QDRHMessage1:GetLeft()
  QDRH.savedVariables.message1Top = QDRHMessage1:GetTop()
end

function QDRH.OnQDRHMessage2Move()
  QDRH.savedVariables.message2Left = QDRHMessage2:GetLeft()
  QDRH.savedVariables.message2Top = QDRHMessage2:GetTop()
end

function QDRH.OnQDRHMessage3Move()
  QDRH.savedVariables.message3Left = QDRHMessage3:GetLeft()
  QDRH.savedVariables.message3Top = QDRHMessage3:GetTop()
end

function QDRH.OnQDRHStatusMove()
  QDRH.savedVariables.statusLeft = QDRHStatus:GetLeft()
  QDRH.savedVariables.statusTop = QDRHStatus:GetTop()
end

function QDRH.OnQDRHMapMove()
  -- implement moving
  QDRH.savedVariables.mapLeft = QDRHMap:GetLeft()
  QDRH.savedVariables.mapTop = QDRHMap:GetTop()
end

function QDRH.OnQDRHDebuffMove()
  QDRH.savedVariables.debuffLeft = QDRHDebuff:GetLeft()
  QDRH.savedVariables.debuffTop = QDRHDebuff:GetTop()
end

function QDRH.DefaultPosition()
  QDRH.savedVariables.message1Left = nil
  QDRH.savedVariables.message1Top = nil
  QDRH.savedVariables.message2Left = nil
  QDRH.savedVariables.message2Top = nil
  QDRH.savedVariables.message3Left = nil
  QDRH.savedVariables.message3Top = nil
  QDRH.savedVariables.statusLeft = nil
  QDRH.savedVariables.statusTop = nil
  QDRH.savedVariables.mapLeft = nil
  QDRH.savedVariables.mapTop = nil
end

function QDRH.RestorePosition()
  if QDRH.savedVariables.message1Left ~= nil then
    QDRHMessage1:ClearAnchors()
    QDRHMessage1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        QDRH.savedVariables.message1Left,
        QDRH.savedVariables.message1Top)
  end
  
  if QDRH.savedVariables.message2Left ~= nil then
    QDRHMessage2:ClearAnchors()
    QDRHMessage2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        QDRH.savedVariables.message2Left,
        QDRH.savedVariables.message2Top)
  end

  if QDRH.savedVariables.message3Left ~= nil then
    QDRHMessage3:ClearAnchors()
    QDRHMessage3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        QDRH.savedVariables.message3Left,
        QDRH.savedVariables.message3Top)
  end


  if QDRH.savedVariables.statusLeft ~= nil then
    QDRHStatus:ClearAnchors()
    QDRHStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        QDRH.savedVariables.statusLeft,
        QDRH.savedVariables.statusTop)
  end

  if QDRH.savedVariables.mapLeft ~= nil then
    QDRHMap:ClearAnchors()
    QDRHMap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
      QDRH.savedVariables.mapLeft,
      QDRH.savedVariables.mapTop)
  end

  if QDRH.savedVariables.debuffLeft ~= nil then
    QDRHDebuff:ClearAnchors()
    QDRHDebuff:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
      QDRH.savedVariables.debuffLeft,
      QDRH.savedVariables.debuffTop)
  end
end


function QDRH.UnlockUI(unlock)
  QDRH.status.locked = not unlock
  QDRH.HideAllUI(not unlock)
  QDRHMessage1:SetMouseEnabled(unlock)
  QDRHMessage2:SetMouseEnabled(unlock)
  QDRHMessage3:SetMouseEnabled(unlock)
  QDRHStatus:SetMouseEnabled(unlock)
  QDRHMap:SetMouseEnabled(unlock)
  QDRHDebuff:SetMouseEnabled(unlock)
  
  QDRHMessage1:SetMovable(unlock)
  QDRHMessage2:SetMovable(unlock)
  QDRHMessage3:SetMovable(unlock)
  QDRHStatus:SetMovable(unlock)
  QDRHMap:SetMovable(unlock)
  QDRHDebuff:SetMovable(unlock)
end

function QDRH.ClearUIOutOfCombat()
  QDRH.status.inCombat = false

  -- Calls here Hide icons, if needed.

  QDRH.ResetStatus()
  QDRH.ResetAllPlayerIcons()
  QDRH.HideAllUI(true)
  QDRH.LoadSavedScale()
end

function QDRH.HideAllUI(hide)
  QDRHMessage1:SetHidden(hide)
  QDRHMessage2:SetHidden(hide)
  QDRHMessage3:SetHidden(hide)
  QDRHStatus:SetHidden(hide)
  QDRHScreenBorder:SetHidden(true) -- do NOT want to display it on unlock.
  
  -- Generic
  QDRHStatusLabelTop:SetHidden(hide)

  -- Fire boss
  QDRHStatusLabel1:SetHidden(hide)
  QDRHStatusLabel1Value:SetHidden(hide)
  QDRHStatusLabel2:SetHidden(hide)
  QDRHStatusLabel2Value:SetHidden(hide)
  QDRHStatusLabel3:SetHidden(hide)
  QDRHStatusLabel3Value:SetHidden(hide)
  QDRHStatusLabel4:SetHidden(hide)
  QDRHStatusLabel4Value:SetHidden(hide)
  QDRHStatusLabel5:SetHidden(hide)
  QDRHStatusLabel5Value:SetHidden(hide)
  
  -- Ice boss
  QDRHStatusLabel1Right:SetHidden(hide)
  QDRHStatusLabel1RightValue:SetHidden(hide)
  QDRHStatusLabel2Right:SetHidden(hide)
  QDRHStatusLabel2RightValue:SetHidden(hide)
  QDRHStatusLabel3Right:SetHidden(hide)
  QDRHStatusLabel3RightValue:SetHidden(hide)
  QDRHStatusLabel4Right:SetHidden(hide)
  QDRHStatusLabel4RightValue:SetHidden(hide)
  QDRHStatusLabel5Right:SetHidden(hide)
  QDRHStatusLabel5RightValue:SetHidden(hide)

  -- Reef Guardian
  QDRHStatusLabelLightning:SetHidden(hide)
  QDRHStatusLabelLightningValue:SetHidden(hide)
  QDRHStatusLabelPoison:SetHidden(hide)
  QDRHStatusLabelPoisonValue:SetHidden(hide)

  QDRHStatusLabelGuardianReef1:SetHidden(hide)
  QDRHStatusLabelGuardianReef1Value:SetHidden(hide)
  QDRHStatusLabelGuardianReef2:SetHidden(hide)
  QDRHStatusLabelGuardianReef2Value:SetHidden(hide)
  QDRHStatusLabelGuardianReef3:SetHidden(hide)
  QDRHStatusLabelGuardianReef3Value:SetHidden(hide)
  QDRHStatusLabelGuardianReef4:SetHidden(hide)
  QDRHStatusLabelGuardianReef4Value:SetHidden(hide)
  QDRHStatusLabelGuardianReef5:SetHidden(hide)
  QDRHStatusLabelGuardianReef5Value:SetHidden(hide)
  QDRHStatusLabelGuardianReef6:SetHidden(hide)
  QDRHStatusLabelGuardianReef6Value:SetHidden(hide)

  QDRHStatusLabelGuardian1:SetHidden(hide)
  QDRHStatusLabelGuardian1Value:SetHidden(hide)
  QDRHStatusLabelGuardian2:SetHidden(hide)
  QDRHStatusLabelGuardian2Value:SetHidden(hide)
  QDRHStatusLabelGuardian3:SetHidden(hide)
  QDRHStatusLabelGuardian3Value:SetHidden(hide)
  QDRHStatusLabelGuardian4:SetHidden(hide)
  QDRHStatusLabelGuardian4Value:SetHidden(hide)
  QDRHStatusLabelGuardian5:SetHidden(hide)
  QDRHStatusLabelGuardian5Value:SetHidden(hide)
  QDRHStatusLabelGuardian6:SetHidden(hide)
  QDRHStatusLabelGuardian6Value:SetHidden(hide)
  -- Reef Guardian Map
  QDRHMap:SetHidden(hide)
  QDRHMapTexture:SetHidden(hide)
  QDRHMapLabel1:SetHidden(hide)
  QDRHMapLabel2:SetHidden(hide)
  QDRHMapLabel3:SetHidden(hide)
  QDRHMapLabel4:SetHidden(hide)
  QDRHMapLabel5:SetHidden(hide)
  QDRHMapLabel6:SetHidden(hide)

  -- Debuff icon
  QDRHDebuff:SetHidden(hide)
  QDRHDebuffTexture:SetHidden(hide)
  QDRHDebuffStacks:SetHidden(hide)
  QDRHDebuffTime:SetHidden(hide)

  -- Taleria
  QDRHStatusLabelTaleria1:SetHidden(hide)
  QDRHStatusLabelTaleria1Value:SetHidden(hide)
  QDRHStatusLabelTaleria2:SetHidden(hide)
  QDRHStatusLabelTaleria2Value:SetHidden(hide)
  QDRHStatusLabelTaleria3:SetHidden(hide)
  QDRHStatusLabelTaleria3Value:SetHidden(hide)
  QDRHStatusLabelTaleria4:SetHidden(hide)
  QDRHStatusLabelTaleria4Value:SetHidden(hide)
  QDRHStatusLabelTaleriaBridge1:SetHidden(hide)
  QDRHStatusLabelTaleriaBridge1Value:SetHidden(hide)
  QDRHStatusLabelTaleriaBridge2:SetHidden(hide)
  QDRHStatusLabelTaleriaBridge2Value:SetHidden(hide)
  QDRHStatusLabelTaleriaBridge3:SetHidden(hide)
  QDRHStatusLabelTaleriaBridge3Value:SetHidden(hide)

  QDRHStatusLabelTaleriaDebuff1:SetHidden(hide)
  QDRHStatusLabelTaleriaDebuff2:SetHidden(hide)
  QDRHStatusLabelTaleriaDebuff3:SetHidden(hide)

  -- Levers
  QDRHStatusLabelLever1:SetHidden(hide)
  QDRHStatusLabelLever1Value:SetHidden(hide)
  QDRHStatusLabelLever2:SetHidden(hide)
  QDRHStatusLabelLever2Value:SetHidden(hide)
  QDRHStatusLabelLever3:SetHidden(hide)
  QDRHStatusLabelLever3Value:SetHidden(hide)

end


function QDRH.CommandLine(param)
  local help = "[QDRH] Usage: /qdrh {lock,unlock}"
  if param == nil or param == "" then
    d(help)
  elseif param == "lock" then
    QDRH.Lock()
  elseif param == "unlock" then
    QDRH.Unlock()
  else
    d(help)
  end
end

function QDRH.Lock()
  QDRH.UnlockUI(false)
end

function QDRH.Unlock()
  QDRH.UnlockUI(true)
end

function QDRH.LoadSavedScale()
  QDRH.SetScale(QDRH.savedVariables.uiCustomScale)
end

-- Caled when sliding the menu slider.
function QDRH.SetScale(scale)
  QDRH.savedVariables.uiCustomScale = scale

  -- Updating top controls scales all children.
  QDRHStatus:SetScale(QDRH.savedVariables.uiCustomScale)
  QDRHMessage1:SetScale(QDRH.savedVariables.uiCustomScale)
  QDRHMessage2:SetScale(QDRH.savedVariables.uiCustomScale)
  QDRHMessage3:SetScale(QDRH.savedVariables.uiCustomScale)
  QDRHMap:SetScale(QDRH.savedVariables.uiCustomScale)
  QDRHDebuff:SetScale(QDRH.savedVariables.uiCustomScale)
end