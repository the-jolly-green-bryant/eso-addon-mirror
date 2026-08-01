Speedrun              = Speedrun or {}
local Speedrun        = Speedrun
local WM              = GetWindowManager()
local EM              = EVENT_MANAGER
local LAM             = LibAddonMenu2
local sV
local cV
local defaultDisplay  = {
  [1] = "BOSS 1",
  [2] = "BOSS 1 |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
  [3] = "BOSS 2",
  [4] = "BOSS 2 |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
  [5] = "BOSS 3",
  [6] = "BOSS 3 |t20:20:esoui\\art\\icons\\poi\\poi_groupboss_incomplete.dds|t",
}
local profilesIcon    = "|cffdf80|t20:20:esoui\\art\\contacts\\social_status_online.dds|t|r"
local colorEnabled    = {.6, .57, .46, 1}
local colorDisabled   = {.3, .3 , .2 , 1}
local normalIcon      = "/esoui/art/lfg/gamepad/lfg_menuicon_normaldungeon.dds"
local vetIcon         = "/esoui/art/lfg/gamepad/lfg_menuicon_veteranldungeon.dds"

-- esoui\art\lfg\gamepad\lfg_roleicon_dps.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_dps_down.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_dps_up.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_healer.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_healer_down.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_healer_up.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_tank.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_tank_down.dds
-- esoui\art\lfg\gamepad\lfg_roleicon_tank_up.dds
-- art\icons\poi\poi_areaofinterest_complete.dds
-- art\icons\poi\poi_group_house_glow.dds
-- art\icons\poi\poi_group_house_owned.dds
-- art\icons\poi\poi_group_house_unowned.dds

-------------------------
---- Variables    -------
-------------------------
local globalTimer
local previousSegment
local currentRaid
local bestPossibleTime
local uiTracked         = false
local numActiveSegments = 0
local hudHidden         = true
local huduiHidden       = true
local combatState       = false
-------------------------
---- Functions 		-------
-------------------------
local function SortProfileNames(a, b)
  return a < b
end

local function AddTooltipLine(control, tooltipControl, tooltip)
  local tooltipTextType = type(tooltip)
  if tooltipTextType == "string" then
    if tooltip == "" then ZO_Options_OnMouseExit(control) return end

  elseif tooltipTextType == "number" then	tooltip = GetString(tooltip)
  elseif tooltipTextType == "function" then tooltip = tooltip()
  else ZO_Options_OnMouseExit(control) return end

  SetTooltipText(tooltipControl, tooltip)
end

function Speedrun.OnMouseEnter(control) --copy from ZO_Options_OnMouseEnter but modified to support multiple tooltip lines
  local tooltipText = control.tooltip
  if tooltipText ~= nil and #tooltipText > 0 then
    InitializeTooltip(InformationTooltip, control, BOTTOMLEFT, 0, -2, TOPLEFT)
    if type(tooltipText) == "table" then
      for i = 1, #tooltipText do
        AddTooltipLine(control, InformationTooltip, tooltipText[i])
      end
    else
      AddTooltipLine(control, InformationTooltip, tooltipText)
    end
  end
end

do
  local function lockUI()
    Speedrun.ToggleUILocked()
  end

  local function hideGroup()
    Speedrun.HideGroupToggle()
  end

  local function loadProfile(name)
    Speedrun.LoadProfile(name)
  end

  local function portHome(outside)
    RequestJumpToHouse(GetHousingPrimaryHouse(), outside)
  end

  local function openMenu()
    LAM:OpenToPanel(Speedrun_Settings)
  end

  local function testingHouse()
    RequestJumpToHouse(38)
  end

  function Speedrun.Submenu( button, upInside )
    if not upInside then return end

    local sV            = Speedrun.savedVariables
    local cV            = Speedrun.savedSettings

    local lockString    = sV.unlockUI    and "Lock UI"      or "Unlock UI"
    local hgString      = cV.groupHidden and "Unhide Group" or "Hide Group"
    local profileString = "Load Profile"
    local homeString    = "Port Home"
    local menuString    = "Open Settings"

    local portOptions = {
      { label = "Inside",  callback = function() portHome(false) end },
      { label = "Outside", callback = function() portHome(true)  end }
    }

    Speedrun.UpdateProfileList()
    ClearMenu()

    AddCustomMenuItem(hgString, hideGroup)

    if GetDisplayName() == "@nogetrandom" then AddCustomMenuItem(homeString, testingHouse)
    else AddCustomSubMenuItem(homeString, portOptions) end

    AddCustomSubMenuItem(profileString, Speedrun.profileNames)
    AddCustomMenuItem(lockString, lockUI)
    AddCustomMenuItem(menuString, openMenu)

    ShowMenu(button)
    AnchorMenu(button)
  end

  function Speedrun.UpdateProfileList()
    Speedrun.profileNames	= {}
    local profileList     = {}
    local profileNames    = Speedrun:GetProfileNames()

    table.sort(profileNames, SortProfileNames)

    for i = 1, #profileNames do
      if profileNames[i] ~= Speedrun.activeProfile then
        local profile = profileNames[i]
        local function callbackfunc() loadProfile(profile) end
        table.insert(Speedrun.profileNames, {label = profile, callback = callbackfunc})
      end
    end
  end
end

function Speedrun.SaveLoc_Panel()
  sV["speedrun_panel_OffsetX"] = SpeedRun_Panel:GetLeft()
  sV["speedrun_panel_OffsetY"] = SpeedRun_Panel:GetTop()
end

function Speedrun.SaveLoc_Food()
  sV.food.x = SpeedRun_Food:GetLeft()
  sV.food.y = SpeedRun_Food:GetTop()
end

function Speedrun.GetActiveProfileDisplay()
  local profileDisplay = zo_strformat("|cffffff[ |cffdf80" .. Speedrun.activeProfile .. " |cffffff]|r")
  return profileDisplay
end

function Speedrun:GetProfileNames()
  local sV = Speedrun.savedVariables
  local profiles = {}
  for name, v in pairs(sV.profiles) do table.insert(profiles, name) end
  return profiles
end

function Speedrun.ResetUI()
  Speedrun:dbg(2, "Resetting UI.")

  SpeedRun_Timer_Container:SetHeight(0)
  SpeedRun_TotalTimer_Title:SetText(" ")
  SpeedRun_Vitality_Label:SetText("  ")
  SpeedRun_Advanced_PreviousSegment:SetText(" ")
  SpeedRun_Advanced_PreviousSegment:SetColor(unpack { 1, 1, 1 })
  SpeedRun_Advanced_BestPossible_Value:SetText(" ")
  SpeedRun_Score_Label:SetText(" ")

  if Speedrun.segments then
    for i,x in ipairs(Speedrun.segments) do
      local name = WM:GetControlByName(x:GetName())
      x:SetHidden(true)
      name:GetNamedChild("_Name"):SetText(" ")
      name:GetNamedChild("_Best"):SetText(" ")
      name:GetNamedChild("_Diff"):SetText(" ")
    end
  end

  Speedrun.ResetAddsUI()
  if Speedrun.zone == 1227 then Speedrun.UpdateAdds() end
  Speedrun.isUIDrawn = false
  Speedrun.isScoreSet = false
end

function Speedrun.ResetAddsUI()
  SpeedRun_Adds_SA:SetText(" ")
  SpeedRun_Adds_SA_Counter:SetText(" ")
  SpeedRun_Adds_LA:SetText(" ")
  SpeedRun_Adds_LA_Counter:SetText(" ")
  SpeedRun_Adds_EA:SetText(" ")
  SpeedRun_Adds_EA_Counter:SetText(" ")
end

function Speedrun.ResetAnchors()
  SpeedRun_Panel:ClearAnchors()
  SpeedRun_Panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV["speedrun_panel_OffsetX"], sV["speedrun_panel_OffsetY"])
  SpeedRun_Timer_Container:ClearAnchors()
  SpeedRun_Timer_Container:SetAnchor(TOPLEFT, SpeedRun_Panel, BOTTOMLEFT, 0, 0)
end

function Speedrun.SetDefaultUI()
  SpeedRun_Timer_Container_Profile:SetText(Speedrun.GetActiveProfileDisplay())

  numActiveSegments = 0

  for i, x in ipairs(defaultDisplay) do
    local segmentRow
    if WM:GetControlByName("SpeedRun_Segment", i) then
      segmentRow = WM:GetControlByName("SpeedRun_Segment", i)
    else
      segmentRow = WM:CreateControlFromVirtual("SpeedRun_Segment", SpeedRun_Timer_Container, "SpeedRun_Segment", i)
    end
    segmentRow:GetNamedChild('_Name'):SetText(x);

    if i == 1 then
      Speedrun.segmentTimer[i] = 0
      segmentRow:SetAnchor(TOPLEFT, SpeedRun_Timer_Container, TOPLEFT, 0, 40)
    else
      Speedrun.segmentTimer[i] = 0 + Speedrun.segmentTimer[i - 1]
      segmentRow:SetAnchor(TOPLEFT, Speedrun.segments[i - 1], TOPLEFT, 0, 20)
    end
    segmentRow:GetNamedChild('_Best'):SetText(" ")

    segmentRow:SetHidden(false)
    Speedrun.segments[i] = segmentRow;

    numActiveSegments = numActiveSegments + 1
  end
  SpeedRun_Vitality_Label:SetText(Speedrun.FormatVitality(false, 36, 36))
  SpeedRun_TotalTimer_Title:SetText("--:--")
  SpeedRun_Score_Label:SetText("--'--")
  Speedrun.SetSimpleUI(sV.uiSimple)
end

function Speedrun.ToggleUILocked()
  sV.unlockUI = not sV.unlockUI
  SpeedRun_Panel:SetMovable(sV.unlockUI)
end

function Speedrun.ToggleUIVisibility()
  sV.showUI = not sV.showUI
  Speedrun.UpdateUIConfiguration()
end

function Speedrun.SetUIHidden(hide)
  SpeedRun_Timer_Container:SetHidden(hide)
  SpeedRun_TotalTimer_Title:SetHidden(hide)
  SpeedRun_Vitality_Label:SetHidden(hide)
  SpeedRun_Score_Label:SetHidden(hide)

  local hideAdvanced = hide == true and hide or (not sV.showAdvanced)
  local hideAdds
  if Speedrun.inMenu and Speedrun.currentTrialMenu == 1227 then
    hideAdds = hide == true and hide or (not sV.showAdds)
  else
    if GetZoneId(GetUnitZoneIndex("player")) == 1227 then
      hideAdds = hide == true and hide or (not sV.showAdds)
    else
      hideAdds = true
    end
  end
  SpeedRun_Advanced:SetHidden(hideAdvanced)
  SpeedRun_Adds:SetHidden(hideAdds)
end

function Speedrun.UpdateAlpha()
  local alpha
  if Speedrun.inMenu then alpha = 1
  else
    if combatState then
      if sV.combatAlpha == 0
      then alpha = 0
      else alpha = (sV.combatAlpha / 100) end
    else alpha = 1 end
  end

  SpeedRun_Timer_Container:SetAlpha(alpha)
  SpeedRun_TotalTimer_Title:SetAlpha(alpha)
  SpeedRun_Vitality_Label:SetAlpha(alpha)
  SpeedRun_Score_Label:SetAlpha(alpha)
  SpeedRun_Advanced:SetAlpha(alpha)
  SpeedRun_Adds:SetAlpha(alpha)
end


function Speedrun.ShowInMenu()
  local hide = not Speedrun.inMenu
  SpeedRun_Timer_Container:SetHidden(hide)
  SpeedRun_TotalTimer_Title:SetHidden(hide)
  SpeedRun_Vitality_Label:SetHidden(hide)
  SpeedRun_Score_Label:SetHidden(hide)
  SpeedRun_Advanced:SetHidden(not sV.showAdvanced)
  if not hide and Speedrun.currentTrialMenu == 1227 then
    SpeedRun_Adds:SetHidden(not sV.showAdds)
  end
end

function Speedrun.UpdateAnchors()
  SpeedRun_Adds:ClearAnchors()
  if not sV.showAdvanced then
    SpeedRun_Adds:SetAnchor(TOPRIGHT, SpeedRun_TotalTimer, BOTTOMRIGHT, 0, 30)
  else
    SpeedRun_Adds:SetAnchor(TOPRIGHT, SpeedRun_TotalTimer, BOTTOMRIGHT, 0, 80)
  end
end

function Speedrun.UpdateDifficultySwitch()
  local isVet = Speedrun.ResolveTrialDiffculty()

  -- was changed from normal to veteran
  if isVet then	SpeedRun_Panel_Difficulty_Switch:SetTexture(vetIcon)
    -- was changed from veteran to normal
  else SpeedRun_Panel_Difficulty_Switch:SetTexture(normalIcon) end

  local canChange = CanPlayerChangeGroupDifficulty() and colorEnabled or colorDisabled
  SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(canChange))

  if ZO_GroupListVeteranDifficultySettings then
    ZO_GroupListVeteranDifficultySettings.veteranModeButton:SetState(isVet and BSTATE_PRESSED or BSTATE_NORMAL )
    ZO_GroupListVeteranDifficultySettings.normalModeButton:SetState (isVet and BSTATE_NORMAL  or BSTATE_PRESSED)
  end
end

function Speedrun.ToggleDifficulty()
  -- do nothing if setting is unavailable
  if not CanPlayerChangeGroupDifficulty() then SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorDisabled)) return end

  local vet = IsUnitUsingVeteranDifficulty('player')
  SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorEnabled))
  SetVeteranDifficulty(not vet)
  Speedrun.UpdateDifficultySwitch(not vet)
end

function Speedrun.DifficultyOnMouseEnter()
  if CanPlayerChangeGroupDifficulty() then
    -- highlight button on mouseover
    SpeedRun_Panel_Difficulty_Switch:SetColor(.9, .9, .8, 1)
  end
end

function Speedrun.DifficultyOnMouseExit()
  -- set brightness to reflect availability of setting
  if CanPlayerChangeGroupDifficulty() then
    SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorEnabled))
  else
    SpeedRun_Panel_Difficulty_Switch:SetColor(unpack(colorDisabled))
  end
end

local function UpdateSimpleUISwitch(simple)
  if simple then
    SpeedRun_Timer_Container_Segments_Switch:SetNormalTexture("/esoui/art/buttons/pointsplus_up.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetPressedTexture("/esoui/art/buttons/pointsplus_down.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetMouseOverTexture("/esoui/art/buttons/pointsplus_over.dds")
  else
    SpeedRun_Timer_Container_Segments_Switch:SetNormalTexture("/esoui/art/buttons/pointsminus_up.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetPressedTexture("/esoui/art/buttons/pointsminus_down.dds")
    SpeedRun_Timer_Container_Segments_Switch:SetMouseOverTexture("/esoui/art/buttons/pointsminus_over.dds")
  end
end

function Speedrun.ToggleSimpleUI()
  sV.uiSimple = not sV.uiSimple
  Speedrun.SetSimpleUI(sV.uiSimple)
end

function Speedrun.ResetSegments()
  for i,x in ipairs(Speedrun.segments) do
    local name = WM:GetControlByName(x:GetName())
    x:SetHidden(true)
    x:SetHeight(0)
    name:GetNamedChild("_Name"):SetText(" ")
    name:GetNamedChild("_Best"):SetText(" ")
    name:GetNamedChild("_Diff"):SetText(" ")
    name:GetNamedChild("_Name"):SetHeight(0)
    name:GetNamedChild("_Best"):SetHeight(0)
    name:GetNamedChild("_Diff"):SetHeight(0)
  end
end

function Speedrun.SetSimpleUI(simple)
  for i = 1, numActiveSegments do
    local segment = WM:GetControlByName(Speedrun.segments[i]:GetName())
    if segment then
      local n = segment:GetNamedChild('_Name')
      local d = segment:GetNamedChild('_Diff')
      local b = segment:GetNamedChild('_Best')
      local h = simple == true and 0 or 23
      local H = simple == true and 0 or 5
      n:SetHeight(h)
      d:SetHeight(h)
      b:SetHeight(h)
      segment:SetHidden(simple)
      segment:SetHeight(H)

      if simple then
        h = 49
      else
        h = 49 + (20 * numActiveSegments)
      end
      SpeedRun_Timer_Container:SetHeight(h)
    end
  end
  UpdateSimpleUISwitch(simple)
end

function Speedrun.CreateRaidSegmentFromMenu(raidID)
  Speedrun.CreateRaidSegment(raidID)
  SpeedRun_Score_Label:SetText(Speedrun.BestPossible(raidID))
  -- SpeedRun_TotalTimer_Title:SetText("00:00")
  SpeedRun_TotalTimer_Title:SetText("--:--")
  local v = Speedrun.GetTrialMaxVitality(raidID)
  SpeedRun_Vitality_Label:SetText(Speedrun.FormatVitality(false, v, v))
end

function Speedrun.FormatVitality(chat, current, max)
  local displayVitality = ""
  if current and max then
    if chat then
      if current == max then
        displayVitality = "[Vitality: |c00ff00" .. current .. "|r / " .. "|c00ff00" .. max .. "|r]"
      elseif current <= 0 then
        displayVitality = "[Vitality: |cff0000" .. current .. "|r / " .. "|cff0000" .. max .. "|r]"
      elseif current > 0 and current < max then
        displayVitality = "[Vitality: |cffffff" .. current .. "|r / " .. "|cffffff" .. max .. "|r]"
      end
    else
      if current == max then
        displayVitality = "|c00ff00" .. current .. "|r / " .. "|c00ff00" .. max .. "|r"
      elseif current <= 0 then
        displayVitality = "|cff0000" .. current .. "|r / " .. "|cff0000" .. max .. "|r"
      elseif current > 0 and current < max then
        displayVitality = "|cffffff" .. current .. "|r / " .. "|cffffff" .. max .. "|r"
      end
    end
  end
  return displayVitality
end

function Speedrun.UpdateGlobalTimer()
  if (not Speedrun.IsInTrialZone()) then return end
  local timer
  if Speedrun.FormatRaidTimer(GetRaidDuration(), true) ~= nil
  then timer = Speedrun.FormatRaidTimer(GetRaidDuration(), true)
  else timer = "00:00" end
  -- GetRaidTargetTime()
  SpeedRun_TotalTimer_Title:SetText(timer)
  -- if (bestPossibleTime == nil or Speedrun.segmentTimer[Speedrun.Step] == Speedrun.segmentTimer[Speedrun.Step + 1]) then
  Speedrun.UpdateCurrentScore()
  -- end
end

function Speedrun.UpdateCurrentVitality()
  local mVitality = GetCurrentRaidStartingReviveCounters()
  local cVitality = GetRaidReviveCountersRemaining()
  if not mVitality then return end
  SpeedRun_Vitality_Label:SetText(Speedrun.FormatVitality(false, cVitality, mVitality))
end

function Speedrun.UpdateCurrentScore()
  -- local timer
  -- if bestPossibleTime then
  --   if Speedrun.segmentTimer[Speedrun.Step] == Speedrun.segmentTimer[Speedrun.Step + 1] or Speedrun.segmentTimer[Speedrun.Step + 1] == nil  then
  --     timer = GetRaidDuration() / 1000
  --   else timer = bestPossibleTime / 1000 end
  -- else timer = GetRaidDuration() / 1000 end

  local scoreString
  if Speedrun.isComplete == false then
    if IsRaidInProgress() then
      local timer = GetRaidDuration() / 1000
      local score = math.floor(Speedrun.GetScore(timer, GetRaidReviveCountersRemaining(), Speedrun.raidID))
      if score <= 0
      then scoreString = "0"
      else scoreString = Speedrun.FormatRaidScore(score)
      end
    else
      scoreString = Speedrun.BestPossible(Speedrun.zone)
    end
  else
    -- in case trial is completed but player is only moving between areas inside the trial.
    scoreString = Speedrun.FormatRaidScore(sV.finalScore)
  end
  SpeedRun_Score_Label:SetText(scoreString)
end

function Speedrun.UpdateWindowPanel(waypoint, raid)
  waypoint = waypoint or 1
  raid = raid or nil

  if waypoint and raid then Speedrun.UpdateSegment(waypoint, raid) end
  Speedrun.UpdateGlobalTimer()
end

local function SetSegment(row, step)
  row:GetNamedChild('_Best'):SetText(Speedrun.FormatRaidTimer(Speedrun.segmentTimer[step], true))
  bestPossibleTime = Speedrun.segmentTimer[step]

  local bestTime = Speedrun.FormatRaidTimer(Speedrun.segmentTimer[step], true)
  SpeedRun_Advanced_BestPossible_Value:SetText(bestTime)
end

function Speedrun.CreateRaidSegment(id, same)
  --Reset segment control
  Speedrun.segmentTimer = {}
  numActiveSegments     = 0
  Speedrun.ResetSegments()

  SpeedRun_Timer_Container_Profile:SetText(Speedrun.GetActiveProfileDisplay())
  SpeedRun_Timer_Container_Raid:SetText("|ce6b800" .. zo_strformat(SI_ZONE_NAME, GetZoneNameById(id)).. "|r")

  for i, x in ipairs(Speedrun.Data.stepList[id]) do
    local segmentRow

    if WM:GetControlByName("SpeedRun_Segment", i) then segmentRow = WM:GetControlByName("SpeedRun_Segment", i)
    else segmentRow = WM:CreateControlFromVirtual("SpeedRun_Segment", SpeedRun_Timer_Container, "SpeedRun_Segment", i) end

    segmentRow:GetNamedChild('_Name'):SetText(x);

    if same and Speedrun.Step > 1 then
      if Speedrun.currentRaidTimer[i] then
        if i == 1 then
          Speedrun.segmentTimer[i] = Speedrun.currentRaidTimer[i]
        else
          Speedrun.segmentTimer[i] = Speedrun.currentRaidTimer[i] + Speedrun.segmentTimer[i - 1]
        end
        SetSegment(segmentRow, i)
      else
        if Speedrun.GetSavedTimer(id, i) then
          Speedrun.segmentTimer[i] = Speedrun.GetSavedTimer(id, i) + Speedrun.segmentTimer[i - 1]
          SetSegment(segmentRow, i)
        else
          Speedrun.segmentTimer[i] = 0 + Speedrun.segmentTimer[i - 1]
          segmentRow:GetNamedChild('_Best'):SetText(" ")
          bestPossibleTime = 0
          SpeedRun_Advanced_BestPossible_Value:SetText(" ")
        end
      end
    else
      if Speedrun.GetSavedTimer(id, i) then
        if i == 1 then Speedrun.segmentTimer[i] = Speedrun.GetSavedTimer(id, i)
        else Speedrun.segmentTimer[i] = Speedrun.GetSavedTimer(id, i) + Speedrun.segmentTimer[i - 1] end

        SetSegment(segmentRow, i)

        -- segmentRow:GetNamedChild('_Best'):SetText(Speedrun.FormatRaidTimer(Speedrun.segmentTimer[i], true))
        -- bestPossibleTime = Speedrun.segmentTimer[i]
        --
        -- local bestTime = Speedrun.FormatRaidTimer(Speedrun.segmentTimer[i], true)
        -- SpeedRun_Advanced_BestPossible_Value:SetText(bestTime)
      else
        if i == 1 then Speedrun.segmentTimer[i] = 0
        else Speedrun.segmentTimer[i] = 0 + Speedrun.segmentTimer[i - 1] end
        segmentRow:GetNamedChild('_Best'):SetText(" ")
        bestPossibleTime = 0
        SpeedRun_Advanced_BestPossible_Value:SetText(" ")
      end
    end

    if i == 1 then
      segmentRow:SetAnchor(TOPLEFT, SpeedRun_Timer_Container, TOPLEFT, 0, 40)
    else
      -- segmentRow:SetAnchor(TOPLEFT, SpeedRun_Timer_Container, TOPLEFT, 0, (i * 20) + 20)
      segmentRow:SetAnchor(TOPLEFT, Speedrun.segments[i - 1], TOPLEFT, 0, 20)
    end

    segmentRow:SetHidden(false)
    Speedrun.segments[i] = segmentRow;
    numActiveSegments    = numActiveSegments + 1
  end

  SpeedRun_Timer_Container_Raid:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
  Speedrun.UpdateGlobalTimer()
  Speedrun.isUIDrawn = true
  Speedrun.SetSimpleUI(sV.uiSimple)
  Speedrun.SetUIHidden(not sV.showUI)

  if (id == 677 or id == 1227) and cV.individualArenaTimers then
    Speedrun:dbg(1, "|cffdf80<<1>>'s|r individual |ce6b800<<2>> |cfffffftimers loaded|r.", GetUnitName('player'), GetZoneNameById(id))
  else
    Speedrun:dbg(1, "<<1>> |ce6b800<<2>> |cfffffftimers loaded|r.", Speedrun.GetActiveProfileDisplay(), GetZoneNameById(id))
  end
end

function Speedrun.UpdateSegment(step, raid)
  --TODO Divide into multiple function
  -- if raid == nil then
  --     raid = GetZoneId(GetUnitZoneIndex("player"))
  -- end

  local difference
  if (Speedrun.segmentTimer[step] ~= nil and Speedrun.segmentTimer[step] ~= Speedrun.segmentTimer[step + 1])  then
    difference = Speedrun.currentRaidTimer[step] - Speedrun.segmentTimer[step]
  else difference = 0 end

  --TODO correct previousSegementDif
  local previousSegementDif = 0
  if step > 1 then
    if Speedrun.GetSavedTimer(Speedrun.raidID, step) then
      if Speedrun.currentRaidTimer[step - 1] ~= nil then
        previousSegementDif = Speedrun.currentRaidTimer[step] - Speedrun.currentRaidTimer[step - 1] - Speedrun.GetSavedTimer(Speedrun.raidID, step)
      else
        previousSegementDif = 0
      end
    end

  elseif step == 1 then
    if Speedrun.GetSavedTimer(Speedrun.raidID, step) then
      previousSegementDif = Speedrun.currentRaidTimer[step] - Speedrun.GetSavedTimer(Speedrun.raidID, step)
    else
      previousSegementDif = 0
    end
  end

  --TODO IF NO PRESAVED TIME
  if Speedrun.segmentTimer[table.getn(Speedrun.segmentTimer)] then
    bestPossibleTime = difference + Speedrun.segmentTimer[table.getn(Speedrun.segmentTimer)]
    SpeedRun_Advanced_BestPossible_Value:SetText(Speedrun.FormatRaidTimer(bestPossibleTime))
  else
    SpeedRun_Advanced_BestPossible_Value:SetText(" ")
  end

  SpeedRun_Advanced_PreviousSegment:SetText(Speedrun.FormatRaidTimer(previousSegementDif))

  if Speedrun.Step and Speedrun.currentRaidTimer[Speedrun.Step] and Speedrun.segments[Speedrun.Step] then
    Speedrun.segments[Speedrun.Step]:GetNamedChild('_Best'):SetText(Speedrun.FormatRaidTimer(Speedrun.currentRaidTimer[Speedrun.Step]))
  end

  local segment = Speedrun.segments[Speedrun.Step]:GetNamedChild('_Diff')
  segment:SetText(Speedrun.FormatRaidTimer(difference, true))
  Speedrun.DifferenceColor(difference, segment)
  Speedrun.DifferenceColor(previousSegementDif, SpeedRun_Advanced_PreviousSegment)
end

function Speedrun.DifferenceColor(diff, segment)
  if diff > (-0.001) then
    segment:SetColor(unpack { 1, 0, 0 })
  else
    segment:SetColor(unpack { 0, 1, 0 })
  end
end

function Speedrun.ShowFoodReminder(show)
  SpeedRun_Food:SetHidden(not show)
  SpeedRun_Food:SetMouseEnabled(show)
  SpeedRun_Food:SetMovable(show)
end

function Speedrun.UpdateFoodReminderSize()
  local path = "EsoUI/Common/Fonts/univers67.otf"
  local outline = "soft-shadow-thick"
  SpeedRun_Food_Label:SetFont(path .. "|" .. sV.food.size .. "|" .. outline)
end

local function shouldHideUI()
  if Speedrun.inMenu then return false end
  if (hudHidden and huduiHidden) then return true end
  if (sV.showUI ~= true) or (cV.isTracking ~= true) then return true end
  if not Speedrun.IsInTrialZone() then return true end
  -- if (sV.hideInCombat and IsUnitInCombat("player")) then return true end
  return false
end

local function shouldHidePanel()
  if not sV.showPanelAlways then return shouldHideUI() end
  if Speedrun.inMenu then return false end
  if (hudHidden and huduiHidden) then return true end
  return false
end

function Speedrun.UpdateVisibility()
  local hidden = SpeedRun_Timer_Container:IsHidden()
  local hide   = shouldHideUI()
  if (hidden ~= hide) then Speedrun.SetUIHidden(hide) end
  SpeedRun_Panel:SetHidden(shouldHidePanel())
  Speedrun.UpdateAlpha()
end

function Speedrun.UpdateUIConfiguration()
  local h = SCENE_MANAGER:GetScene("hud")
  local hUI = SCENE_MANAGER:GetScene("hudui")

  local function OnStateChangedHud(oldState, newState)


    -- if (sV.showUI ~= true) or (cV.isTracking ~= true) then
    --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
    --   Speedrun.SetUIHidden(true)
    --   return
    -- end

    if newState == SCENE_SHOWN then
      hudHidden = false
      -- if Speedrun.IsInTrialZone() then
      --   SpeedRun_Panel:SetHidden(false)
      --   Speedrun.SetUIHidden(false)
      -- else
      --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
      --   Speedrun.SetUIHidden(true)
      -- end
    else
      hudHidden = true
      -- SpeedRun_Panel:SetHidden(true)
      -- Speedrun.SetUIHidden(true)
    end
    Speedrun.UpdateVisibility()
  end

  local function OnStateChangedHudUI(oldState, newState)

    -- if (sV.showUI ~= true) or (cV.isTracking ~= true) then
    --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
    --   Speedrun.SetUIHidden(true)
    --   return
    -- end

    if newState == SCENE_SHOWN then
      huduiHidden = false
      -- if Speedrun.IsInTrialZone() then
      --   SpeedRun_Panel:SetHidden(false)
      --   Speedrun.SetUIHidden(false)
      -- else
      --   SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
      --   Speedrun.SetUIHidden(true)
      -- end
    else
      huduiHidden = true
      -- SpeedRun_Panel:SetHidden(true)
      -- Speedrun.SetUIHidden(true)
    end

    Speedrun.UpdateVisibility()
  end

  EM:UnregisterForEvent(Speedrun.name .. "HideInCombat", EVENT_PLAYER_COMBAT_STATE)

  local function enableUI()
    if not Speedrun.isUIDrawn then Speedrun.SetDefaultUI() end

    h:RegisterCallback("StateChange", OnStateChangedHud)
    hUI:RegisterCallback("StateChange", OnStateChangedHudUI)


    -- if (not Speedrun.inMenu) then Speedrun.SetUIHidden(shouldHideUI()) end

    Speedrun.UpdateVisibility()

    uiTracked = true
  end

  local function disableUI()
    h:UnregisterCallback("StateChange")
    hUI:UnregisterCallback("StateChange")

    Speedrun.UpdateVisibility()
    -- SpeedRun_Panel:SetHidden(not sV.showPanelAlways)
    -- Speedrun.SetUIHidden(true)
    uiTracked = false
  end

  if not sV.showPanelAlways then
    if (not sV.showUI) or (not cV.isTracking) then disableUI() return end
  end

  if sV.changeAlpha then
    EM:RegisterForEvent(Speedrun.name .. "HideInCombat", EVENT_PLAYER_COMBAT_STATE, function()
      combatState = IsUnitInCombat("player")
      Speedrun.UpdateVisibility()
    end)
  end

  if uiTracked == false then enableUI() end
end

function InitiatePanelOptions(p)
  p:SetHidden(false)
  p.tooltip = "Open dropdown"
end

function Speedrun.InitiateUI()
  sV = Speedrun.savedVariables
  cV = Speedrun.savedSettings

  Speedrun.SetUIHidden(true)
  Speedrun.ResetUI()
  Speedrun.ResetAnchors()
  Speedrun.SetDefaultUI()
  Speedrun.UpdateAnchors()
  SpeedRun_Panel:SetMovable(sV.unlockUI)

  local food = SpeedRun_Food
  food:ClearAnchors()

  if (sV.food.x == 0 and sV.food.y == 0)
  then food:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
  else food:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.food.x, sV.food.y) end

  Speedrun.UpdateFoodReminderSize()
  Speedrun.UpdateFoodReminderInterval(GetGameTimeMilliseconds() / 1000, 0)

  local options = SpeedRun_Panel:GetNamedChild("_Options")
  InitiatePanelOptions(options)
  Speedrun.UpdateDifficultySwitch()

  if (not sV.showPanelAlways and ((sV.showUI ~= true) or (cV.isTracking ~= true))) then return end

  Speedrun.UpdateUIConfiguration()
  EM:RegisterForEvent(Speedrun.name .. "Leader", EVENT_LEADER_UPDATE, Speedrun.UpdateDifficultySwitch)
  EM:RegisterForEvent(Speedrun.name .. "LeftGroup", EVENT_GROUP_MEMBER_LEFT, Speedrun.UpdateDifficultySwitch)
  EM:AddFilterForEvent(Speedrun.name .. "LeftGroup", EVENT_GROUP_MEMBER_LEFT, REGISTER_FILTER_UNIT_TAG, "player")
end

--[[
	/script d(SCENE_MANAGER:GetHUDSceneName())
	/script d(SCENE_MANAGER.currentScene)
	/script d(SCENE_MANAGER:IsShowingBaseScene())
	/script d(IsReticleHidden())

	/script zo_callLater(function() d(SCENE_MANAGER:IsShowingBaseScene()) end, 1000)
]]
