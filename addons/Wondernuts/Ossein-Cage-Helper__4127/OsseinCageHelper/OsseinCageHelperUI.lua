OCH = OCH or {}
local OCH = OCH

OCH.prefix = "[OCH]: "

OCH.NONE = "None"
OCH.SELF = "Self"
OCH.ALL = "All"
OCH.TARGET_CHOICES = {OCH.NONE, OCH.SELF, OCH.ALL}

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
OCH.debugMode = 0

OCH.DEBUG_HIGH = 3
-- -----------------------------------------------------------------------------

-- Channeled abilities have `sourceType == COMBAT_UNIT_TYPE_NONE` even though they are player abilities, so we manually exclude them for debugging enemy casts.
OCH.knownChanneledAbilities = {
  [16212] = "Heavy Attack (Restoration)",
  [16420] = "Heavy Attack (Dual Wield)",
  [15383] = "Heavy Attack (Inferno)",
  [26770] = "Resurrect",
  [31816] = "Stone Giant",
  [36508] = "Incapacitating Strike",
  [183006] = "Cephaliarch's Flail",
  [193398] = "Pragmatic Fatecarver",
  [193397] = "Exhausting Fatecarver",
  [103706] = "Channeled Acceleration",
  [6811] = "Recall",
  [137259] = "Exhilarating Drain",
  [220541] = "Trample",
  [36514] = "Soul Harvest",
}

function OCH:Trace(debugLevel, ...)
  if debugLevel <= OCH.debugMode then
    local message = zo_strformat(...)
    d(OCH.prefix .. message)
  end
end

function OCH.TraceEnemyCombatEvents(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
  if OCH.DEBUG_HIGH <= OCH.debugMode then
    -- Debug ability casts of NPCs (unit type None)
    if result == ACTION_RESULT_BEGIN and sourceType == COMBAT_UNIT_TYPE_NONE and not OCH.knownChanneledAbilities[abilityId] then
      local displaySourceName = sourceName or GetUnitDisplayName(OCH.GetTagForId(sourceUnitId)) or ""
      local displayTargetName = GetUnitDisplayName(OCH.GetTagForId(targetUnitId)) or ""
      OCH:Trace(OCH.DEBUG_HIGH, string.format(
        "Ability: %s, ID: %d, Hit Value: %d, Source name: %s, Target name: %s",
        GetFormattedAbilityName(abilityId), abilityId, hitValue, displaySourceName, displayTargetName
      ))
    end
  end
end

function OCH.OnOCHMessage1Move()
  OCH.savedVariables.message1Left = OCHMessage1:GetLeft()
  OCH.savedVariables.message1Top = OCHMessage1:GetTop()
end

function OCH.OnOCHMessage2Move()
  OCH.savedVariables.message2Left = OCHMessage2:GetLeft()
  OCH.savedVariables.message2Top = OCHMessage2:GetTop()
end

function OCH.OnOCHMessage3Move()
  OCH.savedVariables.message3Left = OCHMessage3:GetLeft()
  OCH.savedVariables.message3Top = OCHMessage3:GetTop()
end

function OCH.OnOCHStatusMove()
  OCH.savedVariables.statusLeft = OCHStatus:GetLeft()
  OCH.savedVariables.statusTop = OCHStatus:GetTop()
end

function OCH.DefaultPosition()
  OCH.savedVariables.message1Left = nil
  OCH.savedVariables.message1Top = nil
  OCH.savedVariables.message2Left = nil
  OCH.savedVariables.message2Top = nil
  OCH.savedVariables.message3Left = nil
  OCH.savedVariables.message3Top = nil
  OCH.savedVariables.statusLeft = nil
  OCH.savedVariables.statusTop = nil
  OCH.savedVariables.mapLeft = nil
  OCH.savedVariables.mapTop = nil
end

function OCH.RestorePosition()
  if OCH.savedVariables.message1Left ~= nil then
    OCHMessage1:ClearAnchors()
    OCHMessage1:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        OCH.savedVariables.message1Left,
        OCH.savedVariables.message1Top)
  end
  
  if OCH.savedVariables.message2Left ~= nil then
    OCHMessage2:ClearAnchors()
    OCHMessage2:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        OCH.savedVariables.message2Left,
        OCH.savedVariables.message2Top)
  end

  if OCH.savedVariables.message3Left ~= nil then
    OCHMessage3:ClearAnchors()
    OCHMessage3:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        OCH.savedVariables.message3Left,
        OCH.savedVariables.message3Top)
  end


  if OCH.savedVariables.statusLeft ~= nil then
    OCHStatus:ClearAnchors()
    OCHStatus:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        OCH.savedVariables.statusLeft,
        OCH.savedVariables.statusTop)
  end

end


function OCH.UnlockUI(unlock)
  OCH.status.locked = not unlock
  OCH.HideAllUI(not unlock)
  OCHMessage1:SetMouseEnabled(unlock)
  OCHMessage2:SetMouseEnabled(unlock)
  OCHMessage3:SetMouseEnabled(unlock)
  OCHStatus:SetMouseEnabled(unlock)
  
  OCHMessage1:SetMovable(unlock)
  OCHMessage2:SetMovable(unlock)
  OCHMessage3:SetMovable(unlock)
  OCHStatus:SetMovable(unlock)
end

function OCH.ClearUIOutOfCombat()
  OCH.status.inCombat = false

  -- Calls here Hide icons, if needed.

  OCH.ResetStatus()
  OCH.ResetAllPlayerIcons()
  OCH.ShaperOfFlesh.ClearIcons()
  OCH.Jynorah.ClearBreathIcons()
  OCH.Kazpian.ClearIcons()
  OCH.HideAllUI(true)
  OCH.LoadSavedScale()
end

function OCH.HideAllUI(hide)
  OCHMessage1:SetHidden(hide)
  OCHMessage1Label:SetHidden(hide)
  OCHMessage2:SetHidden(hide)
  OCHMessage3:SetHidden(hide)
  OCHStatus:SetHidden(hide)
  OCHScreenBorder:SetHidden(true) -- do NOT want to display it on unlock.
  
  -- Generic
  OCHStatusLabelTop:SetHidden(hide)

  -- Jynorah
  OCHStatusLabelJynorah1:SetHidden(hide)
  OCHStatusLabelJynorah1Value:SetHidden(hide)
  OCHStatusLabelJynorah2:SetHidden(hide)
  OCHStatusLabelJynorah2Value:SetHidden(hide)
  OCHStatusLabelJynorah3:SetHidden(hide)
  OCHStatusLabelJynorah3Value:SetHidden(hide)
  OCHStatusLabelCausticCarrion:SetHidden(hide)
  OCHStatusLabelCausticCarrionValue:SetHidden(hide)
end


function OCH.CommandLine(param)
  local help = "[OCH] Usage: /OCH {lock,unlock,debug [0-3]}"
  if param == nil or param == "" then
    d(help)
  elseif param == "lock" then
    OCH.Lock()
  elseif param == "unlock" then
    OCH.Unlock()
  elseif param == "debug 0" then
    d(OCH.prefix .. "Setting debug level to 0 (Off)")
    OCH.debugMode = 0
  elseif param == "debug 1" then
    d(OCH.prefix .. "Setting debug level to 1 (Low)")
    OCH.debugMode = 1
  elseif param == "debug 2" then
    d(OCH.prefix .. "Setting debug level to 2 (Low)")
    OCH.debugMode = 2
  elseif param == "debug 3" then
    d(OCH.prefix .. "Setting debug level to 3 (Low)")
    OCH.debugMode = 3
  elseif param == "debug test" then
    local borderId = "debugTest"
    LibCombatAlerts.PlaySounds("DEATH_RECAP_KILLING_BLOW_SHOWN")
    CombatAlerts.ScreenBorderEnable(0xE0115FFF, 2500, borderId)
  else
    d(help)
  end
end

function OCH.Lock()
  OCH.UnlockUI(false)
end

function OCH.Unlock()
  OCH.UnlockUI(true)
end

function OCH.LoadSavedScale()
  OCH.SetScale(OCH.savedVariables.uiCustomScale)
end

-- Caled when sliding the menu slider.
function OCH.SetScale(scale)
  OCH.savedVariables.uiCustomScale = scale

  -- Updating top controls scales all children.
  OCHStatus:SetScale(OCH.savedVariables.uiCustomScale)
  OCHMessage1:SetScale(OCH.savedVariables.uiCustomScale)
  OCHMessage2:SetScale(OCH.savedVariables.uiCustomScale)
  OCHMessage3:SetScale(OCH.savedVariables.uiCustomScale)
end
