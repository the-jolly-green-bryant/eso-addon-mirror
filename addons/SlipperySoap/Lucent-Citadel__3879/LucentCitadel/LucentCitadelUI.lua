LC = LC or {}
local LC = LC

function LC.OnLCMessage1Move()
  LC.savedVariables.message1Left = LCMessage1:GetLeft()
  LC.savedVariables.message1Top = LCMessage1:GetTop()
end

function LC.OnLCMessage2Move()
  LC.savedVariables.message2Left = LCMessage2:GetLeft()
  LC.savedVariables.message2Top = LCMessage2:GetTop()
end

function LC.OnLCMessage3Move()
  LC.savedVariables.message3Left = LCMessage3:GetLeft()
  LC.savedVariables.message3Top = LCMessage3:GetTop()
end

function LC.OnLCStatusMove()
  LC.savedVariables.statusLeft = LCStatus:GetLeft()
  LC.savedVariables.statusTop = LCStatus:GetTop()
end

function LC.OnLCMapMove()
  -- implement moving
  LC.savedVariables.mapLeft = LCMap:GetLeft()
  LC.savedVariables.mapTop = LCMap:GetTop()
end

function LC.OnLCDebuffMove()
  LC.savedVariables.debuffLeft = LCDebuff:GetLeft()
  LC.savedVariables.debuffTop = LCDebuff:GetTop()
end

function LC.DefaultPosition()
  LC.savedVariables.message1Left = nil
  LC.savedVariables.message1Top = nil
  LC.savedVariables.message2Left = nil
  LC.savedVariables.message2Top = nil
  LC.savedVariables.message3Left = nil
  LC.savedVariables.message3Top = nil
  LC.savedVariables.statusLeft = nil
  LC.savedVariables.statusTop = nil
  LC.savedVariables.mapLeft = nil
  LC.savedVariables.mapTop = nil
end

function LC.RestorePosition()
  if LC.savedVariables.message1Left ~= nil then
    LCMessage1:ClearAnchors()
    LCMessage1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LC.savedVariables.message1Left,
        LC.savedVariables.message1Top)
  end
  
  if LC.savedVariables.message2Left ~= nil then
    LCMessage2:ClearAnchors()
    LCMessage2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LC.savedVariables.message2Left,
        LC.savedVariables.message2Top)
  end

  if LC.savedVariables.message3Left ~= nil then
    LCMessage3:ClearAnchors()
    LCMessage3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LC.savedVariables.message3Left,
        LC.savedVariables.message3Top)
  end


  if LC.savedVariables.statusLeft ~= nil then
    LCStatus:ClearAnchors()
    LCStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LC.savedVariables.statusLeft,
        LC.savedVariables.statusTop)
  end

  if LC.savedVariables.mapLeft ~= nil then
    LCMap:ClearAnchors()
    LCMap:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
      LC.savedVariables.mapLeft,
      LC.savedVariables.mapTop)
  end

  if LC.savedVariables.debuffLeft ~= nil then
    LCDebuff:ClearAnchors()
    LCDebuff:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
      LC.savedVariables.debuffLeft,
      LC.savedVariables.debuffTop)
  end
end


function LC.UnlockUI(unlock)
  LC.status.locked = not unlock
  LC.HideAllUI(not unlock)
  LCMessage1:SetMouseEnabled(unlock)
  LCMessage2:SetMouseEnabled(unlock)
  LCMessage3:SetMouseEnabled(unlock)
  LCStatus:SetMouseEnabled(unlock)
  --LCMap:SetMouseEnabled(unlock)
  --LCDebuff:SetMouseEnabled(unlock)
  
  LCMessage1:SetMovable(unlock)
  LCMessage2:SetMovable(unlock)
  LCMessage3:SetMovable(unlock)
  LCStatus:SetMovable(unlock)
  --LCMap:SetMovable(unlock)
  --LCDebuff:SetMovable(unlock)
end

function LC.ClearUIOutOfCombat()
  LC.status.inCombat = false

  -- Calls here Hide icons, if needed.

  LC.ResetStatus()
  LC.ResetAllPlayerIcons()
  LC.HideAllUI(true)
  LC.LoadSavedScale()
end

function LC.HideAllUI(hide)
  LCMessage1:SetHidden(hide)
  LCMessage2:SetHidden(hide)
  LCMessage3:SetHidden(hide)
  LCStatus:SetHidden(hide)
  LCScreenBorder:SetHidden(true) -- do NOT want to display it on unlock.
  
  -- Generic
  LCStatusLabelTop:SetHidden(hide)

  -- Fire boss
  LCStatusLabel1:SetHidden(true)
  LCStatusLabel1Value:SetHidden(true)
  LCStatusLabel2:SetHidden(true)
  LCStatusLabel2Value:SetHidden(true)
  LCStatusLabel3:SetHidden(true)
  LCStatusLabel3Value:SetHidden(true)
  LCStatusLabel4:SetHidden(true)
  LCStatusLabel4Value:SetHidden(true)
  LCStatusLabel5:SetHidden(true)
  LCStatusLabel5Value:SetHidden(true)
  
  -- Ice boss
  LCStatusLabel1Right:SetHidden(true)
  LCStatusLabel1RightValue:SetHidden(true)
  LCStatusLabel2Right:SetHidden(true)
  LCStatusLabel2RightValue:SetHidden(true)
  LCStatusLabel3Right:SetHidden(true)
  LCStatusLabel3RightValue:SetHidden(true)
  LCStatusLabel4Right:SetHidden(true)
  LCStatusLabel4RightValue:SetHidden(true)
  LCStatusLabel5Right:SetHidden(true)
  LCStatusLabel5RightValue:SetHidden(true)

  -- Reef Guardian
  LCStatusLabelLightning:SetHidden(true)
  LCStatusLabelLightningValue:SetHidden(true)
  LCStatusLabelPoison:SetHidden(true)
  LCStatusLabelPoisonValue:SetHidden(true)

  LCStatusLabelArcaneKnot1:SetHidden(hide)
  LCStatusLabelArcaneKnot1Value:SetHidden(hide)
  LCStatusLabelArcaneKnot2:SetHidden(hide)
  LCStatusLabelArcaneKnot2Value:SetHidden(hide)
  LCStatusLabelArcaneKnot3:SetHidden(hide)
  LCStatusLabelArcaneKnot3Value:SetHidden(hide)
  LCStatusLabelArcaneKnot4:SetHidden(hide)
  LCStatusLabelArcaneKnot4Value:SetHidden(hide)
  LCStatusLabelFluctuating1:SetHidden(hide)
  LCStatusLabelFluctuating1Value:SetHidden(hide)
  LCStatusLabelFluctuating2:SetHidden(hide)
  LCStatusLabelFluctuating2Value:SetHidden(hide)

  -- Tempest
  LCStatusLabelTempest:SetHidden(hide)
  LCStatusLabelTempestValue:SetHidden(hide)

  -- previously was: 
  -- previously was: 
  --LCStatusLabelGuardianReef6:SetHidden(hide)
  --LCStatusLabelGuardianReef6Value:SetHidden(hide)
  -- Yellow label color is: e8dd68
  -- Blue Color: 63cbf7
  -- Previous Reef Wipe color: 03C0C1

  LCStatusLabelGuardian1:SetHidden(true)
  LCStatusLabelGuardian1Value:SetHidden(true)
  LCStatusLabelGuardian2:SetHidden(true)
  LCStatusLabelGuardian2Value:SetHidden(true)
  LCStatusLabelGuardian3:SetHidden(true)
  LCStatusLabelGuardian3Value:SetHidden(true)
  LCStatusLabelGuardian4:SetHidden(true)
  LCStatusLabelGuardian4Value:SetHidden(true)
  LCStatusLabelGuardian5:SetHidden(true)
  LCStatusLabelGuardian5Value:SetHidden(true)
  LCStatusLabelGuardian6:SetHidden(true)
  LCStatusLabelGuardian6Value:SetHidden(true)
  -- Reef Guardian Map
  LCMap:SetHidden(true)
  LCMapTexture:SetHidden(true)
  LCMapLabel1:SetHidden(true)
  LCMapLabel2:SetHidden(true)
  LCMapLabel3:SetHidden(true)
  LCMapLabel4:SetHidden(true)
  LCMapLabel5:SetHidden(true)
  LCMapLabel6:SetHidden(true)

  -- Debuff icon
  LCDebuff:SetHidden(true)
  LCDebuffTexture:SetHidden(true)
  LCDebuffStacks:SetHidden(true)
  LCDebuffTime:SetHidden(true)

  -- Taleria
  LCStatusLabelTaleria1:SetHidden(true)
  LCStatusLabelTaleria1Value:SetHidden(true)
  LCStatusLabelTaleria2:SetHidden(true)
  LCStatusLabelTaleria2Value:SetHidden(true)
  LCStatusLabelTaleria3:SetHidden(true)
  LCStatusLabelTaleria3Value:SetHidden(true)
  LCStatusLabelTaleria4:SetHidden(true)
  LCStatusLabelTaleria4Value:SetHidden(true)
  LCStatusLabelTaleriaBridge2:SetHidden(true)
  LCStatusLabelTaleriaBridge2Value:SetHidden(true)
  LCStatusLabelTaleriaBridge3:SetHidden(true)
  LCStatusLabelTaleriaBridge3Value:SetHidden(true)

  LCStatusLabelTaleriaDebuff1:SetHidden(true)
  LCStatusLabelTaleriaDebuff2:SetHidden(true)
  LCStatusLabelTaleriaDebuff3:SetHidden(true)

  -- Levers
  LCStatusLabelLever1:SetHidden(true)
  LCStatusLabelLever1Value:SetHidden(true)
  LCStatusLabelLever2:SetHidden(true)
  LCStatusLabelLever2Value:SetHidden(true)
  LCStatusLabelLever3:SetHidden(true)
  LCStatusLabelLever3Value:SetHidden(true)

end


function LC.CommandLine(param)
  local help = "[LC] Usage: /lc {lock,unlock}"
  local help2 = {
      [1] = "/lc {testingt} = testing set to true",
      [2] = "/lc {testingf} = testing set to false",
      [3] = "/lc {combatt} = combat set to true",
      [4] = "/lc {combatf} = combat set to false",
      [5] = "/lc {ozt} = override zone true",
      [6] = "/lc {ozf} = override zone false",
      [7] = "/lc {zilt} = sets boss to Zilyesset",
      [8] = "/lc {zilf} = sets boss to not Zilyesset",
      [9] = "/lc {orpht} = sets boss to Orphic",
      [10] = "/lc {orphf} = sets boss to not Orphic",
      [11] = "/lc {xort} = sets boss to Xoryn",
      [12] = "/lc {xorf} = sets boss to not Xoryn",
      -- need to increment else condition's for loop after each addition
  }
  local help3 = {
      [1] = "/lc {bh100} = sets boss health to 100%",
      [2] = "/lc {bh91} = sets boss health to 91%",
      [3] = "/lc {bh61} = sets boss health to 61%",
      [4] = "/lc {bh36} = sets boss health to 36%",
      [5] = "/lc {bh11} = sets boss health to 11%",
      [6] = "/lc {bh0} = sets boss health to 0%",
      [7] = "/lc {kse} = killswitch enabled",
      [8] = "/lc {ksd} = killswitch disabled",
      
      [9] = "/lc {pos} = prints player's coordinates to system debug",
      [10] = "/lc {d0} = prints system debug message of 0",
      [11] = "/lc {d1} = prints system debug message of 1",
      [10] = "/lc {kfc} = Krymsyn filling for Illuminati core",
      [11] = "/lc {irko} = Illuminati core reset Arcane Knot order",
      -- need to increment else condition's for loop after each addition
  }
  if param == nil or param == "" then
    d(help)
  elseif param == "lock" then
    LC.Lock()
  elseif param == "unlock" then
    LC.Unlock()
  
  -- SlipperySoap's method of testing addons
  
  -- testing set to true
  elseif  param == "testingt" then
    LC.status.testing = true
  -- testing set to false
  elseif  param == "testingf" then
    LC.status.testing = false
  -- testing set to true
  elseif  param == "combatt" then
    LC.status.inCombat = true
  -- testing set to false
  elseif  param == "combatf" then
    LC.status.inCombat = false
  -- override zone true
  elseif  param == "ozt" then
    LC.status.overridezone = true
    EVENT_MANAGER:RegisterForEvent( LC.name, EVENT_ADD_ON_LOADED, LC.OnAddonLoaded )
  -- override zone false
  elseif  param == "oztf" then
    LC.status.overridezone = false
    EVENT_MANAGER:RegisterForEvent( LC.name, EVENT_ADD_ON_LOADED, LC.OnAddonLoaded )
  -- sets boss to Zilyesset
  elseif  param == "zilt" then
    LC.status.isZilyesset = true
    LC.UpdateTick(gameTimeMs)
  -- sets boss to not Zilyesset
  elseif  param == "zilf" then
    LC.status.isZilyesset = true
    LC.UpdateTick(gameTimeMs)
  --sets boss to Orphic
  elseif  param == "orpht" then
    LC.status.isOrphic = true
    LC.UpdateTick(gameTimeMs)
  -- sets boss to not Orphic
  elseif  param == "orphf" then
    LC.status.isOrphic = true
    LC.UpdateTick(gameTimeMs)
  --sets boss to Xoryn
  elseif  param == "xort" then
    LC.status.isXoryn = true
    LC.UpdateTick(gameTimeMs)
  -- sets boss to not Xoryn
  elseif  param == "xorf" then
    LC.status.isXoryn = true
    LC.UpdateTick(gameTimeMs)
    
  --sets boss to Xoryn
  elseif  param == "xort" then
    LC.status.isXoryn = true
    LC.UpdateTick(gameTimeMs)
  -- sets boss to not Xoryn
  elseif  param == "xorf" then
    LC.status.isXoryn = true
    LC.UpdateTick(gameTimeMs)

  -- local help3 = {
      -- [1] = "/lc {bh100} = sets boss health to 100",
      -- [2] = "/lc {bh91} = sets boss health to 91",
      -- [3] = "/lc {bh61} = sets boss health to 61",
      -- [4] = "/lc {bh36} = sets boss health to 36",
      -- [5] = "/lc {bh11} = sets boss health to 11",
      -- need to increment else condition's for loop after each addition
  -- }
  
  -- sets boss health to 100
  elseif  param == "bh100" then
    LC.status.testingBossHealth = 100 * 0.01
    d("Boss health set to 100%")
  -- sets boss health to 91
  elseif  param == "bh91" then
    LC.status.testingBossHealth = 91 * 0.01
    d("Boss health set to 91%")
  -- sets boss health to 61
  elseif  param == "bh61" then
    LC.status.testingBossHealth = 61 * 0.01
    d("Boss health set to 61%")
  -- sets boss health to 36
  elseif  param == "bh36" then
    LC.status.testingBossHealth = 36 * 0.01
    d("Boss health set to 36%")
  -- sets boss health to 11
  elseif  param == "bh11" then
    LC.status.testingBossHealth = 11 * 0.01
    d("Boss health set to 11%")
  -- sets boss health to 0
  elseif  param == "bh0" then
    LC.status.testingBossHealth = 0
    d("Boss health set to 0%")
  elseif  param == "kse" then
    LC.status.killSwitch = true
    d("Killswithch Enabled")
  elseif  param == "ksd" then
    LC.status.killSwitch = false
    d("Killswithch Disabled")
  elseif  param == "pos" then
    LC.Orphic.PrintPositionForArrowTarget()
    --d("Position Printed (x, y)")
  elseif  param == "d0" then
    d("Debug printing 0")
  elseif  param == "d1" then
    d("Debug printing 1")
  elseif  param == "kfc" then
    d("Krymsyn filling for Illuminati core")
    LC.status.illuminatiArcaneKnotHolders[1] = "Krymsyn_Panda"
  elseif  param == "irko" then
    d("Illuminati core reset Arcane Knot order")
    LC.status.illuminatiArcaneKnotHolders = {
    [1] = "@dappr",
    [2] = "@SeaUnicorn",
    [3] = "@Brangwynn",
    [4] = "@SlipperySoap",
    [5] = "@Haymez327",
    [6] = "@watervision",
    [7] = "@AngelofDeathGaming",
    [8] = "@Dracogenius",
    [9] = "@MrSnowyagi",
    [10] = "@HazeRiderz",
    [11] = "@HatchetHaro",
    [12] = "@Haikyuu_929",
    } -- LC.status.illuminatiArcaneKnotHolders
  else
    d(help)
    -- should match number of help2 elements
    for i=1, 12 do
        if help2[i] ~= nil then
          d(help2[i])
        end
    end
    -- should match number of help3 elements
    for i=1, 6 do
        if help3[i] ~= nil then
          d(help3[i])
        end
    end
  end
end

function LC.Lock()
  LC.UnlockUI(false)
end

function LC.Unlock()
  LC.UnlockUI(true)
end

function LC.LoadSavedScale()
  LC.SetPanelScale(LC.savedVariables.panelUICustomScale)
  LC.SetAlertScale(LC.savedVariables.alertUICustomScale)
end

-- Caled when sliding the menu slider.
function LC.SetPanelScale(scale)
  LC.savedVariables.panelUICustomScale = scale

  -- Updating top controls scales all children.
  LCStatus:SetScale(LC.savedVariables.panelUICustomScale)
  LCMap:SetScale(LC.savedVariables.panelUICustomScale)
  LCDebuff:SetScale(LC.savedVariables.panelUICustomScale)
end

-- Caled when sliding the menu slider.
function LC.SetAlertScale(scale)
  LC.savedVariables.alertUICustomScale = scale

  -- Updating top controls scales all children.
  LCMessage1:SetScale(LC.savedVariables.alertUICustomScale)
  LCMessage2:SetScale(LC.savedVariables.alertUICustomScale)
  LCMessage3:SetScale(LC.savedVariables.alertUICustomScale)
end