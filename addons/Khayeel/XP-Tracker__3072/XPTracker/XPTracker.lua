XPTracker = {}

XPTracker.name = "XPTracker"
 
XPTracker.Default = {
  L1left = 25,
  L1top = 50,
  L2left = 25,
  L2top = 75,
  L3left = 25,
  L3top = 125,
  XPGainFontStyle = "BOLD_FONT",
  XPGainFontSize = 30,
  XPGainFontWeight = "soft-shadow-thick",
  XPRateFontStyle = "BOLD_FONT",
  XPRateFontSize = 30,
  XPRateFontWeight = "soft-shadow-thick",
  XPDunFontStyle = "BOLD_FONT",
  XPDunFontSize = 30,
  XPDunFontWeight = "soft-shadow-thick",
  xptLastHiddenState = false,
  xptRateHiddenState = false,
  xptDunXPHiddenState = false,
  xptCurZone = "",
  xptLastStr = " EXP",
  xptRateMinStr = " EXP/m",
  xptRateHrStr = " EXP/h",
  xptDunXPStr = " ",
  xptTimeFrameMin = true,
  xptExpDun = 0,
  xptTimeDun = 0,
  r1 = 255,
  r2 = 255,
  r3 = 255,
  g1 = 255,
  g2 = 255,
  g3 = 255,
  b1 = 255,
  b2 = 255,
  b3 = 255,
  a1 = 255,
  a2 = 255,
  a3 = 255,
}

XPTracker.DefaultAccWide = {
  xptAccWideSet = true
}

function XPTracker:RestorePosition()
  local L1left = XPTracker.savedVariables.L1left
  local L1top = XPTracker.savedVariables.L1top
  local L2left = XPTracker.savedVariables.L2left
  local L2top = XPTracker.savedVariables.L2top
  local L3left = XPTracker.savedVariables.L3left
  local L3top = XPTracker.savedVariables.L3top
  XPTrackerIndicatorLastKillLabel:ClearAnchors()
  XPTrackerIndicatorLastKillLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, L1left, L1top)
  XPTrackerIndicatorXPRateLabel:ClearAnchors()
  XPTrackerIndicatorXPRateLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, L2left, L2top)
  XPTrackerIndicatorDunXPLabel:ClearAnchors()
  XPTrackerIndicatorDunXPLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, L3left, L3top)
end

function XPTracker:RestoreFonts()
  local xpGainFStyle = XPTracker.savedVariables.XPGainFontStyle
  local xpGainFSize = XPTracker.savedVariables.XPGainFontSize
  local xpGainFWeight = XPTracker.savedVariables.XPGainFontWeight
  local xpRateFStyle = XPTracker.savedVariables.XPRateFontStyle
  local xpRateFSize = XPTracker.savedVariables.XPRateFontSize
  local xpRateFWeight = XPTracker.savedVariables.XPRateFontWeight
  local xpDunFStyle = XPTracker.savedVariables.XPDunFontStyle
  local xpDunFSize = XPTracker.savedVariables.XPDunFontSize
  local xpDunFWeight = XPTracker.savedVariables.XPDunFontWeight
  local xpGainNameFont = " "
  if xpGainFWeight == "NoShadow" then
    xpGainNameFont = zo_strformat("$(<<1>>)|$(KB_<<2>>)", xpGainFStyle, xpGainFSize)
  else
    xpGainNameFont = zo_strformat("$(<<1>>)|$(KB_<<2>>)|<<3>>", xpGainFStyle, xpGainFSize, xpGainFWeigth)
  end
  XPTrackerIndicatorLastKillLabel:SetFont(xpGainNameFont)
  XPTrackerIndicatorLastKillLabel:SetColor(XPTracker.savedVariables.r1,XPTracker.savedVariables.g1,XPTracker.savedVariables.b1,XPTracker.savedVariables.a1)
  local xpRateNameFont = " "
  if xpRateFWeight == "NoShadow" then
    xpRateNameFont = zo_strformat("$(<<1>>)|$(KB_<<2>>)", xpRateFStyle, xpRateFSize)
  else
    xpRateNameFont = zo_strformat("$(<<1>>)|$(KB_<<2>>)|<<3>>", xpRateFStyle, xpRateFSize, xpRateFWeigth)
  end
  XPTrackerIndicatorXPRateLabel:SetFont(xpRateNameFont)
  XPTrackerIndicatorXPRateLabel:SetColor(XPTracker.savedVariables.r2,XPTracker.savedVariables.g2,XPTracker.savedVariables.b2,XPTracker.savedVariables.a2)
  local xpDunNameFont = " "
  if xpDunFWeight == "NoShadow" then
    xpDunNameFont = zo_strformat("$(<<1>>)|$(KB_<<2>>)", xpDunFStyle, xpDunFSize)
  else
    xpDunNameFont = zo_strformat("$(<<1>>)|$(KB_<<2>>)|<<3>>", xpDunFStyle, xpDunFSize, xpDunFWeigth)
  end
  XPTrackerIndicatorDunXPLabel:SetFont(xpDunNameFont)
  XPTrackerIndicatorDunXPLabel:SetColor(XPTracker.savedVariables.r3,XPTracker.savedVariables.g3,XPTracker.savedVariables.b3,XPTracker.savedVariables.a3)
end

function XPTracker:LoadHiddenState()
  if XPTracker.savedVariables.xptLastHiddenState == false then
    XPTrackerIndicatorLastKillLabel:SetHidden(false)
  else
    XPTrackerIndicatorLastKillLabel:SetHidden(true)
  end
  if XPTracker.savedVariables.xptRateHiddenState == false then
    XPTrackerIndicatorXPRateLabel:SetHidden(false)
  else
    XPTrackerIndicatorXPRateLabel:SetHidden(true)
  end
  if XPTracker.savedVariables.xptDunXPHiddenState == false then
    XPTrackerIndicatorDunXPLabel:SetHidden(false)
  else
    XPTrackerIndicatorDunXPLabel:SetHidden(true)
  end
end

function XPTracker:Initialize()
  self.combatStarted = 0
  self.timeLastKill = 125
  self.xpAccumulated = 0
  self.xpAccumulated2 = 0
  self.xpGain1 = 0
  self.xpGain2 = 0
  self.xpGain3 = 0
  self.xpGain1ms = 0
  self.xpGain2ms = 0
  self.xpGain3ms = 0
  self.xpAveMin1 = 0
  self.xpAveMin2 = 0
  self.inDun = false
  self.defaultAccWideSettings = ZO_SavedVars:NewAccountWide("XPSavedVariables", 3, nil, XPTracker.DefaultAccWide)  
  if self.defaultAccWideSettings.xptAccWideSet == false then
    self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("XPSavedVariables", 3, nil, XPTracker.Default)  
  else
    self.savedVariables = ZO_SavedVars:NewAccountWide("XPSavedVariables", 3, nil, XPTracker.Default)  
  end
  self:RestorePosition()
  self:RestoreFonts()
  self:LoadHiddenState()
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_EXPERIENCE_GAIN, XPTracker.OnXPGain);
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, XPTracker.OnCombatStart);
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RANK_POINT_UPDATE, XPTracker.RankPointsUpdate)
  SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneChange)
  EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, XPTracker.OnZoneChanged)
  SLASH_COMMANDS["/xpt"] = xptslashcom
end
 
function XPTracker.OnAddOnLoaded(event, addonName)
  if addonName == XPTracker.name then
    XPTracker:Initialize()
    XPTracker.LAM:RegisterAddonPanel(XPTracker.panelName, XPTracker.panelData)
    XPTracker.LAM:RegisterOptionControls(XPTracker.panelName, XPTracker.optionsTable)
  end
end

function XPTracker.OnLabelMoveStop()
  XPTracker.savedVariables.L1left = XPTrackerIndicatorLastKillLabel:GetLeft()
  XPTracker.savedVariables.L1top = XPTrackerIndicatorLastKillLabel:GetTop()
  XPTracker.savedVariables.L2left = XPTrackerIndicatorXPRateLabel:GetLeft()
  XPTracker.savedVariables.L2top = XPTrackerIndicatorXPRateLabel:GetTop()
  XPTracker.savedVariables.L3left = XPTrackerIndicatorDunXPLabel:GetLeft()
  XPTracker.savedVariables.L3top = XPTrackerIndicatorDunXPLabel:GetTop()
end

function XPTracker.OnCombatStart(event, inCombat)
  if inCombat then
    XPTracker.combatStarted = os.time()
  else
    XPTracker.combatStarted = 0
  end
end

function XPTracker.OnXPGain(event, reason, numLevel, numPrevXP, numCurrXP, numChampPoints)
  local xpLastKill = numCurrXP - numPrevXP
  local xptCurZone = GetUnitZone("player")
  if XPTracker.inDun == true then
    XPTracker.savedVariables.xptExpDun = XPTracker.savedVariables.xptExpDun + xpLastKill
  end
  local timeNow = os.time()
  XPTrackerIndicatorLastKillLabel:SetText(zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(xpLastKill)) .. XPTracker.savedVariables.xptLastStr)
  if XPTracker.savedVariables.xptTimeFrameMin == true then
    -- Minute Version
    if XPTracker.xpAccumulated == 0 then
      XPTracker.xpAccumulated = xpLastKill
      XPTracker.xpGain1 = xpLastKill
      XPTracker.xpGain1ms = timeNow
      XPTracker.timeLastKill = XPTracker.xpGain1ms
      if XPTracker.combatStarted > 0 then
        if XPTracker.xpGain1ms - XPTracker.combatStarted == 0 then
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated * 60  
        else
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated / (XPTracker.xpGain1ms - XPTracker.combatStarted) * 60
        end
        XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateMinStr)
      else
        XPTrackerIndicatorXPRateLabel:SetText(" ")
      end
    else
      if timeNow - XPTracker.xpGain1ms <= 30 then
        XPTracker.xpAccumulated = XPTracker.xpAccumulated + xpLastKill
        XPTracker.xpGain2 = xpLastKill
        XPTracker.xpGain2ms = timeNow
        XPTracker.timeLastKill = timeNow
        if XPTracker.xpGain2ms - XPTracker.xpGain1ms == 0 then
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated * 60
        else
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated / (XPTracker.xpGain2ms - XPTracker.xpGain1ms) * 60
        end
      XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateMinStr)
      elseif timeNow - XPTracker.xpGain1ms <= 60 and timeNow - XPTracker.xpGain1ms > 30 then
        XPTracker.xpAccumulated2 = XPTracker.xpAccumulated2 + xpLastKill
        XPTracker.xpGain3 = xpLastKill
        XPTracker.xpGain3ms = timeNow
        XPTracker.timeLastKill = timeNow
        if XPTracker.xpGain3ms - XPTracker.xpGain1ms == 0 then
          XPTracker.xpAveMin2 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) * 60
        else
          XPTracker.xpAveMin2 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) / (XPTracker.xpGain3ms - XPTracker.xpGain1ms) * 60
        end
      XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin2, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateMinStr)
      elseif timeNow - XPTracker.xpGain1ms > 60 and timeNow - XPTracker.timeLastKill < 60 then
        XPTracker.xpAccumulated = XPTracker.xpAccumulated2
        XPTracker.xpAccumulated2 = xpLastKill
        XPTracker.xpGain1 = XPTracker.xpGain2
        XPTracker.xpGain1ms = XPTracker.xpGain2ms
        XPTracker.xpGain2 = XPTracker.xpGain3
        XPTracker.xpGain2ms = XPTracker.xpGain3ms
        XPTracker.xpGain3 = xpLastKill
        XPTracker.xpGain3ms = timeNow
        if XPTracker.xpGain3ms - XPTracker.xpGain1ms == 0 then
          XPTracker.xpAveMin1 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) * 60
        else
          XPTracker.xpAveMin1 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) / (XPTracker.xpGain3ms - XPTracker.xpGain1ms) * 60
        end
      XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 3, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateMinStr)
      else
        XPTracker.xpAccumulated = xpLastKill
        XPTracker.xpAccumulated2 = 0
        XPTracker.xpGain1 = xpLastKill
        XPTracker.xpGain2 = 0
        XPTracker.xpGain3 = 0
        XPTracker.xpGain1ms = timeNow
        XPTracker.xpGain2ms = 0
        XPTracker.xpGain3ms = 0
        XPTracker.xpAveMin1 = 0
        XPTracker.xpAveMin2 = 0
        XPTracker.timeLastKill = timeNow
        if XPTracker.combatStarted > 0 then
          if XPTracker.xpGain1ms - XPTracker.combatStarted == 0 then
            XPTracker.xpAveMin1 = XPTracker.xpAccumulated * 60  
          else
            XPTracker.xpAveMin1 = XPTracker.xpAccumulated / (XPTracker.xpGain1ms - XPTracker.combatStarted) * 60
          end
          XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateMinStr)
        else
          XPTrackerIndicatorXPRateLabel:SetText(" ")
        end
      end
    end
  else
    --Hourly Version
    if XPTracker.xpAccumulated == 0 then
      XPTracker.xpAccumulated = xpLastKill
      XPTracker.xpGain1 = xpLastKill
      XPTracker.xpGain1ms = timeNow
      XPTracker.timeLastKill = XPTracker.xpGain1ms
      if XPTracker.combatStarted > 0 then
        if XPTracker.xpGain1ms - XPTracker.combatStarted == 0 then
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated * 3600
        else
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated / (XPTracker.xpGain1ms - XPTracker.combatStarted) * 3600
        end
        XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateHrStr)
      else
        XPTrackerIndicatorXPRateLabel:SetText(" ")
      end
    else
      if timeNow - XPTracker.xpGain1ms <= 1800 then
        XPTracker.xpAccumulated = XPTracker.xpAccumulated + xpLastKill
        XPTracker.xpGain2 = xpLastKill
        XPTracker.xpGain2ms = timeNow
        XPTracker.timeLastKill = timeNow
        if XPTracker.xpGain2ms - XPTracker.xpGain1ms == 0 then
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated * 3600
        else
          XPTracker.xpAveMin1 = XPTracker.xpAccumulated / (XPTracker.xpGain2ms - XPTracker.xpGain1ms) * 3600
        end
      XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateHrStr)
      elseif timeNow - XPTracker.xpGain1ms <= 3600 and timeNow - XPTracker.xpGain1ms > 1800 then
        XPTracker.xpAccumulated2 = XPTracker.xpAccumulated2 + xpLastKill
        XPTracker.xpGain3 = xpLastKill
        XPTracker.xpGain3ms = timeNow
        XPTracker.timeLastKill = timeNow
        if XPTracker.xpGain3ms - XPTracker.xpGain1ms == 0 then
          XPTracker.xpAveMin2 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) * 3600
        else
          XPTracker.xpAveMin2 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) / (XPTracker.xpGain3ms - XPTracker.xpGain1ms) * 3600
        end
      XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin2, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateHrStr)
      elseif timeNow - XPTracker.xpGain1ms > 3600 and timeNow - XPTracker.timeLastKill < 3600 then
        XPTracker.xpAccumulated = XPTracker.xpAccumulated2
        XPTracker.xpAccumulated2 = xpLastKill
        XPTracker.xpGain1 = XPTracker.xpGain2
        XPTracker.xpGain1ms = XPTracker.xpGain2ms
        XPTracker.xpGain2 = XPTracker.xpGain3
        XPTracker.xpGain2ms = XPTracker.xpGain3ms
        XPTracker.xpGain3 = xpLastKill
        XPTracker.xpGain3ms = timeNow
        if XPTracker.xpGain3ms - XPTracker.xpGain1ms == 0 then
          XPTracker.xpAveMin1 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) * 3600
        else
          XPTracker.xpAveMin1 = (XPTracker.xpAccumulated + XPTracker.xpAccumulated2) / (XPTracker.xpGain3ms - XPTracker.xpGain1ms) * 3600
        end
      XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 3, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateHrStr)
      else
        XPTracker.xpAccumulated = xpLastKill
        XPTracker.xpAccumulated2 = 0
        XPTracker.xpGain1 = xpLastKill
        XPTracker.xpGain2 = 0
        XPTracker.xpGain3 = 0
        XPTracker.xpGain1ms = timeNow
        XPTracker.xpGain2ms = 0
        XPTracker.xpGain3ms = 0
        XPTracker.xpAveMin1 = 0
        XPTracker.xpAveMin2 = 0
        XPTracker.timeLastKill = timeNow
        if XPTracker.combatStarted > 0 then
          if XPTracker.xpGain1ms - XPTracker.combatStarted == 0 then
            XPTracker.xpAveMin1 = XPTracker.xpAccumulated * 3600  
          else
            XPTracker.xpAveMin1 = XPTracker.xpAccumulated / (XPTracker.xpGain1ms - XPTracker.combatStarted) * 3600
          end
          XPTrackerIndicatorXPRateLabel:SetText(zo_strformat("<<1>><<2>>", xptCurZone .. ": ", ZO_AbbreviateAndLocalizeNumber(XPTracker.xpAveMin1, 2, useUppercaseSuffixes)) .. XPTracker.savedVariables.xptRateHrStr)
        else
          XPTrackerIndicatorXPRateLabel:SetText(" ")
        end
      end
    end
  end
end

function XPTracker.RankPointsUpdate(event, unitTag, rankPoints, difference)
  --d(difference)
  --d(rankPoints)
end

XPTracker.LAM = LibAddonMenu2
XPTracker.panelName = "XPTrackerSettingsPanel"

XPTracker.panelData = {
    type = "panel",
    name = "XP Tracker",
    displayName = "XP Tracker Settings",
    author = "Khayeel",
    version = "1.2",
}

XPTracker.optionsTable = {
  [1] = {
    type = "header",
    name = "Account-wide Settings",
    width = "full",
  },
  [2] = {
      type = "description",
      title = nil,
      text = "Turn on the option below to use and set-up account-wide setting and positioning instead. Switching automatically does a /reloadui.",
      width = "full",
  },
  [3] = {
    type = "checkbox",
    name = "Use Account-wide Settings",
    tooltip = "Switch between Account-wide and Character-based Settings.",
    getFunc = function() return XPTracker.defaultAccWideSettings.xptAccWideSet end,
    setFunc = function(value) XPTracker.defaultAccWideSettings.xptAccWideSet = value ReloadUI() end,
    width = "full",
    warning = "Automatic UI Reload.",
  },
  [4] = {
    type = "submenu",
    name = "Latest XP Gained Font Customization",
    tooltip = "Use the combination of below settings to customize the Latest XP Gained Text.",	--(optional)
    controls = {
      [1] = {
          type = "description",
          title = nil,
          text = "Use the combination of below settings to customize the Latest XP Gained Text.",
          width = "full",
      },
      [2] = {
          type = "dropdown",
          name = "Style",
          tooltip = nil,
          choices = {"Medium", "Bold", "Chat", "Antique", "Handwritten", "Stone Tablet"},
          getFunc = function() if XPTracker.savedVariables.XPGainFontStyle == "MEDIUM_FONT" then return "Medium" elseif XPTracker.savedVariables.XPGainFontStyle == "BOLD_FONT" then return "Bold" elseif XPTracker.savedVariables.XPGainFontStyle == "CHAT_FONT" then return "Chat" elseif XPTracker.savedVariables.XPGainFontStyle == "ANTIQUE_FONT" then return "Antique" elseif XPTracker.savedVariables.XPGainFontStyle == "HANDWRITTEN_FONT" then return "Handwritten" else return "Stone Tablet" end end,
          setFunc = function(var) if var == "Medium" then XPTracker.savedVariables.XPGainFontStyle = "MEDIUM_FONT" elseif var == "Bold" then XPTracker.savedVariables.XPGainFontStyle = "BOLD_FONT" elseif var == "Chat" then XPTracker.savedVariables.XPGainFontStyle = "CHAT_FONT" elseif var == "Antique" then XPTracker.savedVariables.XPGainFontStyle = "ANTIQUE_FONT" elseif var == "Handwritten" then XPTracker.savedVariables.XPGainFontStyle = "HANDWRITTEN_FONT" else XPTracker.savedVariables.XPGainFontStyle = "STONE_TABLET_FONT" end end,
          width = "full",
          warning = "Reloading UI after settings required.",
      },
      [3] = {
        type = "dropdown",
        name = "Weight",
        tooltip = nil,
        choices = {"No Shadow", "Thick Shadow", "Thin Shadow", "Thick Outline"},
        getFunc = function() if XPTracker.savedVariables.XPGainFontWeight == "NoShadow" then return "No Shadow" elseif XPTracker.savedVariables.XPGainFontWeight == "soft-shadow-thick" then return "Thick Shadow" elseif XPTracker.savedVariables.XPGainFontWeight == "soft-shadow-thin" then return "Thin Shadow" else return "Thick Outline" end end,
        setFunc = function(var) if var == "No Shadow" then XPTracker.savedVariables.XPGainFontWeight = "NoShadow" elseif var == "Thick Shadow" then XPTracker.savedVariables.XPGainFontWeight = "soft-shadow-thick" elseif var == "Thin Shadow" then XPTracker.savedVariables.XPGainFontWeight = "soft-shadow-thin" else XPTracker.savedVariables.XPGainFontWeight = "thick-outline" end end,
        width = "full",
        warning = "Reloading UI after settings required.",
      },
      [4] = {
        type = "dropdown",
        name = "Size",
        tooltip = nil,
        choices = {zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(8)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(12)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(16)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(20)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(24)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(30)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(40))},
        getFunc = function() return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(XPTracker.savedVariables.XPGainFontSize)) end,
        setFunc = function(var) XPTracker.savedVariables.XPGainFontSize = tonumber(var) end,
        width = "full",
        warning = "Reloading UI after settings required.",
      },
      [5] = {
        type = "colorpicker",
        name = "Last XP Text Color",
        getFunc = function() return XPTrackerIndicatorLastKillLabel:GetColor() end,	--(alpha is optional)
        setFunc = function(r,g,b,a) XPTrackerIndicatorLastKillLabel:SetColor(r,g,b,a) XPTracker.savedVariables.r1 = r XPTracker.savedVariables.g1 = g XPTracker.savedVariables.b1 = b XPTracker.savedVariables.a1 = a end,	--(alpha is optional)
        width = "full",	--or "full" (optional)
      },
      [6] = {
        type = "checkbox",
        name = "Hide Last XP",
        tooltip = "Hides the Latest XP Gained Amount Display",
        getFunc = function() return XPTracker.savedVariables.xptLastHiddenState end,
        setFunc = function(value) XPTracker.savedVariables.xptLastHiddenState  = value XPTracker:LoadHiddenState() end,
        width = "half",
      },
      [7] = {
        type = "editbox",
        name = "Last XP Gained Text",
        tooltip = "Edit the text after the Last XP Amount.",
        getFunc = function() return XPTracker.savedVariables.xptLastStr end,
        setFunc = function(text) XPTracker.savedVariables.xptLastStr = text end,
        isMultiline = false,
        width = "half",
      },
    },
  },
  [5] = {
    type = "submenu",
    name = "XP Rate Font Customization",
    tooltip = "Use the combination of below settings to customize the XP Rate Text.",	--(optional)
    controls = {
      [1] = {
          type = "description",
          title = nil,
          text = "Use the combination of below settings to customize the XP Rate Text.",
          width = "full",
      },
      [2] = {
          type = "dropdown",
          name = "Style",
          tooltip = nil,
          choices = {"Medium", "Bold", "Chat", "Antique", "Handwritten", "Stone Tablet"},
          getFunc = function() if XPTracker.savedVariables.XPRateFontStyle == "MEDIUM_FONT" then return "Medium" elseif XPTracker.savedVariables.XPRateFontStyle == "BOLD_FONT" then return "Bold" elseif XPTracker.savedVariables.XPRateFontStyle == "CHAT_FONT" then return "Chat" elseif XPTracker.savedVariables.XPRateFontStyle == "ANTIQUE_FONT" then return "Antique" elseif XPTracker.savedVariables.XPRateFontStyle == "HANDWRITTEN_FONT" then return "Handwritten" else return "Stone Tablet" end end,
          setFunc = function(var) if var == "Medium" then XPTracker.savedVariables.XPRateFontStyle = "MEDIUM_FONT" elseif var == "Bold" then XPTracker.savedVariables.XPRateFontStyle = "BOLD_FONT" elseif var == "Chat" then XPTracker.savedVariables.XPRateFontStyle = "CHAT_FONT" elseif var == "Antique" then XPTracker.savedVariables.XPRateFontStyle = "ANTIQUE_FONT" elseif var == "Handwritten" then XPTracker.savedVariables.XPRateFontStyle = "HANDWRITTEN_FONT" else XPTracker.savedVariables.XPRateFontStyle = "STONE_TABLET_FONT" end end,
          width = "full",
          warning = "Reloading UI after settings required.",
      },
      [3] = {
        type = "dropdown",
        name = "Weight",
        tooltip = nil,
        choices = {"No Shadow", "Thick Shadow", "Thin Shadow", "Thick Outline"},
        getFunc = function() if XPTracker.savedVariables.XPRateFontWeight == "NoShadow" then return "No Shadow" elseif XPTracker.savedVariables.XPRateFontWeight == "soft-shadow-thick" then return "Thick Shadow" elseif XPTracker.savedVariables.XPRateFontWeight == "soft-shadow-thin" then return "Thin Shadow" else return "Thick Outline" end end,
        setFunc = function(var) if var == "No Shadow" then XPTracker.savedVariables.XPRateFontWeight = "NoShadow" elseif var == "Thick Shadow" then XPTracker.savedVariables.XPRateFontWeight = "soft-shadow-thick" elseif var == "Thin Shadow" then XPTracker.savedVariables.XPRateFontWeight = "soft-shadow-thin" else XPTracker.savedVariables.XPRateFontWeight = "thick-outline" end end,
        width = "full",
        warning = "Reloading UI after settings required.",
      },
      [4] = {
        type = "dropdown",
        name = "Size",
        tooltip = nil,
        choices = {zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(8)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(12)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(16)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(20)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(24)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(30)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(40))},
        getFunc = function() return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(XPTracker.savedVariables.XPRateFontSize)) end,
        setFunc = function(var) XPTracker.savedVariables.XPRateFontSize = tonumber(var) end,
        width = "full",
        warning = "Reloading UI after settings required.",
      },
      [5] = {
        type = "colorpicker",
        name = "XP Rate Text Color",
        getFunc = function() return XPTrackerIndicatorXPRateLabel:GetColor() end,	--(alpha is optional)
        setFunc = function(r,g,b,a) XPTrackerIndicatorXPRateLabel:SetColor(r,g,b,a) XPTracker.savedVariables.r2 = r XPTracker.savedVariables.g2 = g XPTracker.savedVariables.b2 = b XPTracker.savedVariables.a2 = a end,	--(alpha is optional)
        width = "full",	--or "full" (optional)
      },
      [6] = {
        type = "checkbox",
        name = "Hide XP Rate",
        tooltip = "Hides the XP Rate Display",
        getFunc = function() return XPTracker.savedVariables.xptRateHiddenState end,
        setFunc = function(value) XPTracker.savedVariables.xptRateHiddenState  = value XPTracker:LoadHiddenState() end,
        width = "half",
      },
      [7] = {
        type = "checkbox",
        name = "Hourly XP Rate",
        tooltip = "Check to show Hourly XP Gain Rate instead of by a Minute.",
        getFunc = function() return not XPTracker.savedVariables.xptTimeFrameMin end,
        setFunc = function(value) XPTracker.savedVariables.xptTimeFrameMin = not value end,
        width = "half",
      },
      [8] = {
        type = "editbox",
        name = "XP/Minute Text",
        tooltip = "Edit the text for XP per Minute Display.",
        getFunc = function() return XPTracker.savedVariables.xptRateMinStr end,
        setFunc = function(text) XPTracker.savedVariables.xptRateMinStr = text end,
        isMultiline = false,
        width = "half",
      },
      [9] = {
        type = "editbox",
        name = "XP/Hour Text",
        tooltip = "Edit the text for XP per Hour Display.",
        getFunc = function() return XPTracker.savedVariables.xptRateHrStr end,
        setFunc = function(text) XPTracker.savedVariables.xptRateHrStr = text end,
        isMultiline = false,
        width = "half",
      },
    },
  },
  [6] = {
    type = "submenu",
    name = "Dungeon EXP/Time Customization",
    tooltip = "Dungeon EXP/Time displays upon exiting a dungeon.",	--(optional)
    controls = {
      [1] = {
          type = "description",
          title = nil,
          text = "Dungeon EXP/Time displays upon exiting a dungeon.",
          width = "full",
      },
      [2] = {
          type = "dropdown",
          name = "Style",
          tooltip = nil,
          choices = {"Medium", "Bold", "Chat", "Antique", "Handwritten", "Stone Tablet"},
          getFunc = function() if XPTracker.savedVariables.XPDunFontStyle == "MEDIUM_FONT" then return "Medium" elseif XPTracker.savedVariables.XPDunFontStyle == "BOLD_FONT" then return "Bold" elseif XPTracker.savedVariables.XPDunFontStyle == "CHAT_FONT" then return "Chat" elseif XPTracker.savedVariables.XPDunFontStyle == "ANTIQUE_FONT" then return "Antique" elseif XPTracker.savedVariables.XPDunFontStyle == "HANDWRITTEN_FONT" then return "Handwritten" else return "Stone Tablet" end end,
          setFunc = function(var) if var == "Medium" then XPTracker.savedVariables.XPDunFontStyle = "MEDIUM_FONT" elseif var == "Bold" then XPTracker.savedVariables.XPDunFontStyle = "BOLD_FONT" elseif var == "Chat" then XPTracker.savedVariables.XPDunFontStyle = "CHAT_FONT" elseif var == "Antique" then XPTracker.savedVariables.XPDunFontStyle = "ANTIQUE_FONT" elseif var == "Handwritten" then XPTracker.savedVariables.XPDunFontStyle = "HANDWRITTEN_FONT" else XPTracker.savedVariables.XPDunFontStyle = "STONE_TABLET_FONT" end end,
          width = "full",
          warning = "Reloading UI after settings required.",
      },
      [3] = {
        type = "dropdown",
        name = "Weight",
        tooltip = nil,
        choices = {"No Shadow", "Thick Shadow", "Thin Shadow", "Thick Outline"},
        getFunc = function() if XPTracker.savedVariables.XPDunFontWeight == "NoShadow" then return "No Shadow" elseif XPTracker.savedVariables.XPDunFontWeight == "soft-shadow-thick" then return "Thick Shadow" elseif XPTracker.savedVariables.XPDunFontWeight == "soft-shadow-thin" then return "Thin Shadow" else return "Thick Outline" end end,
        setFunc = function(var) if var == "No Shadow" then XPTracker.savedVariables.XPDunFontWeight = "NoShadow" elseif var == "Thick Shadow" then XPTracker.savedVariables.XPDunFontWeight = "soft-shadow-thick" elseif var == "Thin Shadow" then XPTracker.savedVariables.XPDunFontWeight = "soft-shadow-thin" else XPTracker.savedVariables.XPDunFontWeight = "thick-outline" end end,
        width = "full",
        warning = "Reloading UI after settings required.",
      },
      [4] = {
        type = "dropdown",
        name = "Size",
        tooltip = nil,
        choices = {zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(8)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(12)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(16)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(20)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(24)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(30)), zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(40))},
        getFunc = function() return zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(XPTracker.savedVariables.XPDunFontSize)) end,
        setFunc = function(var) XPTracker.savedVariables.XPDunFontSize = tonumber(var) end,
        width = "full",
        warning = "Reloading UI after settings required.",
      },
      [5] = {
        type = "colorpicker",
        name = "Dungeon XP/Time Text Color",
        getFunc = function() return XPTrackerIndicatorDunXPLabel:GetColor() end,	--(alpha is optional)
        setFunc = function(r,g,b,a) XPTrackerIndicatorDunXPLabel:SetColor(r,g,b,a) XPTracker.savedVariables.r3 = r XPTracker.savedVariables.g3 = g XPTracker.savedVariables.b3 = b XPTracker.savedVariables.a3 = a end,	--(alpha is optional)
        width = "full",	--or "full" (optional)
      },
      [6] = {
        type = "checkbox",
        name = "Hide Dungeon EXP/Time Display",
        tooltip = "Prevents the Dungeon EXP/Time Display from showing.",
        getFunc = function() return XPTracker.savedVariables.xptDunXPHiddenState end,
        setFunc = function(value) XPTracker.savedVariables.xptDunXPHiddenState  = value XPTracker:LoadHiddenState() end,
        width = "full",
      },
    },
  },
}

function xptslashcom(extra)
  if extra == "" then
    d("/xpt hide - Hides all the XP Tracker UI.")
    d("/xpt show - Shows all the XP Tracker UI.")
    d("/xpt hidexplast - Hides Last XP Gained.")
    d("/xpt showxplast - Shows Last XP Gained.")
    d("/xpt hidexprate - Hides XP Gain Rate.")
    d("/xpt showxprate - Shows XP Gain Rate.")
    d("/xpt switchrate - Switch between per minute or per hour XP Gain Rate display.")
    d("/xpt hidedunxp - Hides Dungeon XP/Time.")
    d("/xpt showdunxp - Shows Dungeon XP/Time.")
    d("/xpt countreset - Resets all counters.")
  elseif extra == "hide" then
      XPTracker:HideLastXP()
      XPTracker:HideRateXP()
      XPTracker:HideDunXP()
  elseif extra == "show" then
      XPTracker:ShowLastXP()
      XPTracker:ShowRateXP()
      XPTracker:ShowDunXP()
  elseif extra == "hidexplast" then
    XPTracker:HideLastXP()
  elseif extra == "showxplast" then
    XPTracker:ShowLastXP()
  elseif extra == "hidexprate" then
    XPTracker:HideRateXP()
  elseif extra == "showxprate" then
    XPTracker:ShowRateXP()
  elseif extra == "switchrate" then
    if XPTracker.savedVariables.xptTimeFrameMin == true then
      XPTracker.savedVariables.xptTimeFrameMin = false
    else
      XPTracker.savedVariables.xptTimeFrameMin = true
    end
  elseif extra == "hidedunxp" then
    XPTracker:HideDunXP()
  elseif extra == "showdunxp" then
    XPTracker:ShowDunXP()
  elseif extra == "countreset" then
    XPTrackerIndicatorXPRateLabel:SetText(" ")
    XPTrackerIndicatorDunXPLabel:SetText(" ")
    XPTrackerIndicatorLastKillLabel:SetText(" ")
    XPTracker.combatStarted = 0
    XPTracker.timeLastKill = 125
    XPTracker.xpAccumulated = 0
    XPTracker.xpAccumulated2 = 0
    XPTracker.xpGain1 = 0
    XPTracker.xpGain2 = 0
    XPTracker.xpGain3 = 0
    XPTracker.xpGain1ms = 0
    XPTracker.xpGain2ms = 0
    XPTracker.xpGain3ms = 0
    XPTracker.xpAveMin1 = 0
    XPTracker.xpAveMin2 = 0
  else
    d("/xpt hide - Hides all the XP Tracker UI.")
    d("/xpt show - Shows all the XP Tracker UI.")
    d("/xpt hidexplast - Hides Last XP Gained.")
    d("/xpt showxplast - Shows Last XP Gained.")
    d("/xpt hidexprate - Hides XP Gain Rate.")
    d("/xpt showxprate - Shows XP Gain Rate.")
    d("/xpt switchrate - Switch between per minute or per hour XP Gain Rate display.")
    d("/xpt hidedunxp - Hides Dungeon XP/Time.")
    d("/xpt showdunxp - Shows Dungeon XP/Time.")
    d("/xpt countreset - Resets all counters.")
  end
end
 
ZO_CreateStringId("SI_BINDING_NAME_XPT_TOGGLE_UI_STATE", "Toggle All XP Tracker Display")
ZO_CreateStringId("SI_BINDING_NAME_XPT_TOGGLE_UI_STATE1", "Toggle Last XP Display")
ZO_CreateStringId("SI_BINDING_NAME_XPT_TOGGLE_UI_STATE2", "Toggle XP Rate Display")
ZO_CreateStringId("SI_BINDING_NAME_XPT_TOGGLE_UI_STATE3", "Toggle Dungeon XP/Time Display")
     
function XPTracker:HideState()
  if XPTracker.savedVariables.xptLastHiddenState == false or XPTracker.savedVariables.xptRateHiddenState == false or XPTracker.savedVariables.xptDunXPHiddenState == false then
    XPTracker:HideLastXP()
    XPTracker:HideRateXP()
    XPTracker:HideDunXP()
  else
    XPTracker:ShowLastXP()
    XPTracker:ShowRateXP()
    XPTracker:ShowDunXP()
  end
end

function XPTracker:HideState1()
  if XPTracker.savedVariables.xptLastHiddenState == false then
    XPTracker:HideLastXP()
  else
    XPTracker:ShowLastXP()
  end
end

function XPTracker:HideState2()
  if XPTracker.savedVariables.xptRateHiddenState == false then
    XPTracker:HideRateXP()
  else
    XPTracker:ShowRateXP()
  end
end

function XPTracker:HideState3()
  if XPTracker.savedVariables.xptDunXPHiddenState == false then
    XPTracker:HideDunXP()
  else
    XPTracker:ShowDunXP()
  end
end

function XPTracker:ShowLastXP()
  XPTrackerIndicatorLastKillLabel:SetHidden(false)
  XPTracker.savedVariables.xptLastHiddenState = false
end

function XPTracker:ShowRateXP()
  XPTrackerIndicatorXPRateLabel:SetHidden(false)
  XPTracker.savedVariables.xptRateHiddenState = false
end

function XPTracker:ShowDunXP()
  XPTrackerIndicatorDunXPLabel:SetHidden(false)
  XPTracker.savedVariables.xptDunXPHiddenState = false
end

function XPTracker:HideLastXP()
  XPTrackerIndicatorLastKillLabel:SetHidden(true)
  XPTracker.savedVariables.xptLastHiddenState = true
end

function XPTracker:HideRateXP()
  XPTrackerIndicatorXPRateLabel:SetHidden(true)
  XPTracker.savedVariables.xptRateHiddenState = true
end

function XPTracker:HideDunXP()
  XPTrackerIndicatorDunXPLabel:SetHidden(true)
  XPTracker.savedVariables.xptDunXPHiddenState = true
end

function sceneChange(sceneName, oldState, newState)
  if (sceneName:GetName() == "hud") then
      if (newState == SCENE_SHOWING) then
        XPTrackerIndicator:SetHidden(false)
      elseif (newState == SCENE_HIDING) then
        XPTrackerIndicator:SetHidden(true)
      end
  elseif (sceneName:GetName() == "hudui") then
    if (newState == SCENE_SHOWING) then
      XPTrackerIndicator:SetHidden(false)
    elseif (newState == SCENE_HIDING) then
      XPTrackerIndicator:SetHidden(true)
    end
  else
    if (newState == SCENE_SHOWING) then
        XPTrackerIndicator:SetHidden(true)
    end
  end
end

function XPTracker.OnZoneChanged(event, initial)
  if initial == false then
    if IsUnitInDungeon("player") == true then
      XPTracker.inDun = true
    end
  else
    if IsUnitInDungeon("player") == true then
      local zoneName = GetUnitZone("player")
      if XPTracker.inDun == false then
        XPTracker.inDun = true
        XPTracker.savedVariables.xptTimeDun = os.time()
        XPTracker.savedVariables.xptDunXPStr = zo_strformat("<<1>>: ", zoneName)
      end
    else
      if XPTracker.inDun == true then
        XPTracker.inDun = false
        XPTracker.savedVariables.xptTimeDun = (os.time() - XPTracker.savedVariables.xptTimeDun)
        XPTrackerIndicatorDunXPLabel:SetText(XPTracker.savedVariables.xptDunXPStr .. zo_strformat("<<1>>", ZO_AbbreviateAndLocalizeNumber(XPTracker.savedVariables.xptExpDun, 2, useUppercaseSuffixes)) .. "xp/" .. timeToString(XPTracker.savedVariables.xptTimeDun))
        XPTracker.savedVariables.xptExpDun = 0
      end
    end
  end
end

function timeToString(seconds)
  if seconds >= 3600 then
    return tostring(math.floor((seconds/3600) * 10) / 10) .. "h" 
  elseif seconds >= 60 then
    return tostring(math.floor((seconds/60) * 10) / 10) .. "m" 
  else
    return tostring(seconds) .. "s"
  end
end

EVENT_MANAGER:RegisterForEvent(XPTracker.name, EVENT_ADD_ON_LOADED, XPTracker.OnAddOnLoaded)