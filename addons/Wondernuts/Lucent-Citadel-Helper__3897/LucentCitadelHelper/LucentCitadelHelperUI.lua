LCH = LCH or {}
local LCH = LCH

LCH.prefix = "[LCH]: "

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
LCH.debugMode = 0
-- -----------------------------------------------------------------------------

function LCH:Trace(debugLevel, ...)
  if debugLevel <= LCH.debugMode then
    local message = zo_strformat(...)
    d(LCH.prefix .. message)
  end
end

function LCH.OnLCHMessage1Move()
  LCH.savedVariables.message1Left = LCHMessage1:GetLeft()
  LCH.savedVariables.message1Top = LCHMessage1:GetTop()
end

function LCH.OnLCHMessage2Move()
  LCH.savedVariables.message2Left = LCHMessage2:GetLeft()
  LCH.savedVariables.message2Top = LCHMessage2:GetTop()
end

function LCH.OnLCHMessage3Move()
  LCH.savedVariables.message3Left = LCHMessage3:GetLeft()
  LCH.savedVariables.message3Top = LCHMessage3:GetTop()
end

function LCH.OnLCHStatusMove()
  LCH.savedVariables.statusLeft = LCHStatus:GetLeft()
  LCH.savedVariables.statusTop = LCHStatus:GetTop()
end

function LCH.DefaultPosition()
  LCH.savedVariables.message1Left = nil
  LCH.savedVariables.message1Top = nil
  LCH.savedVariables.message2Left = nil
  LCH.savedVariables.message2Top = nil
  LCH.savedVariables.message3Left = nil
  LCH.savedVariables.message3Top = nil
  LCH.savedVariables.statusLeft = nil
  LCH.savedVariables.statusTop = nil
  LCH.savedVariables.mapLeft = nil
  LCH.savedVariables.mapTop = nil
end

function LCH.RestorePosition()
  if LCH.savedVariables.message1Left ~= nil then
    LCHMessage1:ClearAnchors()
    LCHMessage1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LCH.savedVariables.message1Left,
        LCH.savedVariables.message1Top)
  end
  
  if LCH.savedVariables.message2Left ~= nil then
    LCHMessage2:ClearAnchors()
    LCHMessage2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LCH.savedVariables.message2Left,
        LCH.savedVariables.message2Top)
  end

  if LCH.savedVariables.message3Left ~= nil then
    LCHMessage3:ClearAnchors()
    LCHMessage3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LCH.savedVariables.message3Left,
        LCH.savedVariables.message3Top)
  end


  if LCH.savedVariables.statusLeft ~= nil then
    LCHStatus:ClearAnchors()
    LCHStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        LCH.savedVariables.statusLeft,
        LCH.savedVariables.statusTop)
  end

end


function LCH.UnlockUI(unlock)
  LCH.status.locked = not unlock
  LCH.HideAllUI(not unlock)
  LCHMessage1:SetMouseEnabled(unlock)
  LCHMessage2:SetMouseEnabled(unlock)
  LCHMessage3:SetMouseEnabled(unlock)
  LCHStatus:SetMouseEnabled(unlock)
  
  LCHMessage1:SetMovable(unlock)
  LCHMessage2:SetMovable(unlock)
  LCHMessage3:SetMovable(unlock)
  LCHStatus:SetMovable(unlock)
end

function LCH.ClearUIOutOfCombat()
  LCH.status.inCombat = false

  -- Calls here Hide icons, if needed.

  LCH.ResetStatus()
  LCH.ResetAllPlayerIcons()
  LCH.HideAllUI(true)
  LCH.LoadSavedScale()
end

function LCH.HideAllUI(hide)
  LCHMessage1:SetHidden(hide)
  LCHMessage1Label:SetHidden(hide)
  LCHMessage2:SetHidden(hide)
  LCHMessage3:SetHidden(hide)
  LCHStatus:SetHidden(hide)
  LCHScreenBorder:SetHidden(true) -- do NOT want to display it on unlock.
  
  -- Generic
  LCHStatusLabelTop:SetHidden(hide)

  -- Zilyesset
  LCHStatusLabelZilyesset1:SetHidden(hide)
  LCHStatusLabelZilyesset1Value:SetHidden(hide)
  LCHStatusLabelZilyesset2:SetHidden(hide)
  LCHStatusLabelZilyesset2Value:SetHidden(hide)
  LCHStatusLabelZilyesset3:SetHidden(hide)
  LCHStatusLabelZilyesset3Value:SetHidden(hide)
  LCHStatusLabelZilyesset4:SetHidden(hide)
  LCHStatusLabelZilyesset4Value:SetHidden(hide)

  -- Orphic
  LCHStatusLabelOrphic1:SetHidden(hide)
  LCHStatusLabelOrphic1Value:SetHidden(hide)
  LCHStatusLabelOrphic2:SetHidden(hide)
  LCHStatusLabelOrphic2Value:SetHidden(hide)

  -- Xoryn
  LCHStatusLabelXoryn1:SetHidden(hide)
  LCHStatusLabelXoryn1Value:SetHidden(hide)
  LCHStatusLabelXoryn2:SetHidden(hide)
  LCHStatusLabelXoryn2Value:SetHidden(hide)
  LCHStatusLabelXoryn3:SetHidden(hide)
  LCHStatusLabelXoryn3Value:SetHidden(hide)
  LCHStatusLabelXoryn4:SetHidden(hide)
  LCHStatusLabelXoryn4Value:SetHidden(hide)
  LCHStatusLabelXoryn5:SetHidden(hide)
  LCHStatusLabelXoryn5Value:SetHidden(hide)
end


function LCH.CommandLine(param)
  local help = "[LCH] Usage: /lch {lock,unlock,debug [0-3]}"
  if param == nil or param == "" then
    d(help)
  elseif param == "lock" then
    LCH.Lock()
  elseif param == "unlock" then
    LCH.Unlock()
  elseif param == "debug 0" then
    d(LCH.prefix .. "Setting debug level to 0 (Off)")
    LCH.debugMode = 0
  elseif param == "debug 1" then
    d(LCH.prefix .. "Setting debug level to 1 (Low)")
    LCH.debugMode = 1
  elseif param == "debug 2" then
    d(LCH.prefix .. "Setting debug level to 2 (Low)")
    LCH.debugMode = 2
  elseif param == "debug 3" then
    d(LCH.prefix .. "Setting debug level to 3 (Low)")
    LCH.debugMode = 3
  else
    d(help)
  end
end

function LCH.Lock()
  LCH.UnlockUI(false)
end

function LCH.Unlock()
  LCH.UnlockUI(true)
end

function LCH.LoadSavedScale()
  LCH.SetScale(LCH.savedVariables.uiCustomScale)
end

-- Caled when sliding the menu slider.
function LCH.SetScale(scale)
  LCH.savedVariables.uiCustomScale = scale

  -- Updating top controls scales all children.
  LCHStatus:SetScale(LCH.savedVariables.uiCustomScale)
  LCHMessage1:SetScale(LCH.savedVariables.uiCustomScale)
  LCHMessage2:SetScale(LCH.savedVariables.uiCustomScale)
  LCHMessage3:SetScale(LCH.savedVariables.uiCustomScale)
end
