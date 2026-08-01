DWAllianceRankProgress = DWAllianceRankProgress or {}
DWAllianceRankProgress.name = "DWAllianceRankProgress"
DWAllianceRankProgress.version = "1.18"
DWAllianceRankProgress.settingsVersion = "1"
DWAllianceRankProgress.settingsDefaults = {
  position = {
    x = 0,
    y = 0
  },
  barColour = "alliance",
  showOnlyInAvaZones = false,
  swapRankAndAllianceIcons = false,
  meterType = "nn"
}
DWAllianceRankProgress.addonLoaded = false
DWAllianceRankProgress.inPvPZone = false
DWAllianceRankProgress.debugLevel = 0
DWAllianceRankProgress.debugPrefix = "[DWAllianceRankProgress] "
DWAllianceRankProgress.debugMsgCount = 0

DW_ARPB_COLOUR_AD = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_ALDMERI_DOMINION))
DW_ARPB_COLOUR_EP = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_EBONHEART_PACT))
DW_ARPB_COLOUR_DC = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_DAGGERFALL_COVENANT))

DW_ARPB_AD_GRADIENT_COLOURS = { DW_ARPB_COLOUR_AD, DW_ARPB_COLOUR_AD }
DW_ARPB_EP_GRADIENT_COLOURS = { DW_ARPB_COLOUR_EP, DW_ARPB_COLOUR_EP }
DW_ARPB_DC_GRADIENT_COLOURS = { DW_ARPB_COLOUR_DC, DW_ARPB_COLOUR_DC }

function DWAllianceRankProgress:DebugMsg(level, ...)
	if level <= self.debugLevel then
		self.debugMsgCount = self.debugMsgCount + 1
		local message = zo_strformat(...)
		d(self.debugPrefix.."["..self.debugMsgCount.."] "..message)
	end
end

function DWAllianceRankProgress:SetDebugLevel(level)
  if (level == nil or level == "") then return end

  self:DebugMsg(1, "Attempting to set ARP debug level")
  local levelNumber = tonumber(level)
  if (levelNumber == nil) then
    return
    self:DebugMsg(1, "Invalid debug level value")
  end

  local parsedLevel = math.floor(levelNumber)

  if (parsedLevel < 0) then
    parsedLevel = 0
  elseif (parsedLevel > 4) then
    parsedLevel = 4
  end

  self:DebugMsg(1, "Parsed level value: <<1>> (type <<2>>)", parsedLevel, type(parsedLevel))
  self.debugLevel = parsedLevel
  self:DebugMsg(1, "ARP debug level set to <<1>>", parsedLevel)
end

function DWAllianceRankProgress:Init(eventCode, addOnName)
  if (addOnName ~= self.name) then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(self.name.."Load", EVENT_ADD_ON_LOADED)
  self:DebugMsg(1, "Initialising <<1>> version <<2>>", self.name, self.version)
  self.addonLoaded = true

  self.uiComponents = {
    tlc = DWAllianceRankProgressTLC,
    ui = DWAllianceRankProgressUI,
    flag = DWAllianceRankProgressUIAllianceFlag,
    rankIcon = DWAllianceRankProgressUIAllianceRankIcon,
    rankLabel = DWAllianceRankProgressUIAllianceRankLabel,
    bar = DWAllianceRankProgressUIStatusBar,
    barGlow = DWAllianceRankProgressUIStatusBarGlowContainer,
    rankNumber = DWAllianceRankProgressUIAllianceRankNumber,
    meter = DWAllianceRankProgressUIAlliancePoints
  }

  self.animation = {
    glowTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("DWAllianceRankProgressBarGlow", self.uiComponents.barGlow)
  }

  self.uiComponents.bar:SetMinMax(0, 100)

  self.settings = ZO_SavedVars:New("DWAllianceRankProgress_SavedVars", self.settingsVersion, nil, self.settingsDefaults, nil)
  if not IsConsoleUI() or (IsConsoleUI() and LibHarvensAddonSettings) then
    self.UserSettings:Init()
  end
  self:ReAnchor()

  self:GetAllianceFlag()
  self:GetStatus()

  EVENT_MANAGER:RegisterForEvent(
    self.name.."APUpdate",
    EVENT_ALLIANCE_POINT_UPDATE,
    function(...)
      self:DebugMsg(1, "AP update")
      self:OnAPUpdate()
    end
  )

  EVENT_MANAGER:RegisterForEvent(
    self.name.."ZoneChange",
    EVENT_ZONE_CHANGED,
    function(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
      self:DebugMsg(1, "Zone changed")
      self:ZoneCheck()
    end
  )

  EVENT_MANAGER:RegisterForEvent(
    self.name.."PlayerActivated",
    EVENT_PLAYER_ACTIVATED,
    function(eventCode, unitTag, newZoneName)
      self:DebugMsg(1, "Player activated")
      self:ZoneCheck()
    end
  )

  local arpbFragment = ZO_HUDFadeSceneFragment:New(self.uiComponents.tlc)

  SCENE_MANAGER:GetScene("hud"):AddFragment(arpbFragment)
  SCENE_MANAGER:GetScene("hudui"):AddFragment(arpbFragment)

  self:SetColours()
  self:ZoneCheck()

  SLASH_COMMANDS["/dwarpdebug"] = function(...) self:SetDebugLevel(...) end
  SLASH_COMMANDS["/dwarpsimulate"] = function(...) self:OnAPUpdate(...) end

  self:DebugMsg(1, "Done initialising <<1>>", self.name)
  return self.addonLoaded
end

function DWAllianceRankProgress:ReAnchor()
  self.uiComponents.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.position.x, self.settings.position.y)
end

function DWAllianceRankProgress:OnMoveStop()
  self:DebugMsg(1, "Addon frame moved, saving location")
  self.settings.position.x = self.uiComponents.ui:GetLeft();
  self.settings.position.y = self.uiComponents.ui:GetTop();
end

function DWAllianceRankProgress:GetAllianceFlag()
  self:DebugMsg(1, "Get alliance flag")
  local alliance = GetUnitAlliance("player")
  local AllianceTexture = self.uiComponents.flag
  if (self.settings.swapRankAndAllianceIcons == true) then
    AllianceTexture = self.uiComponents.rankIcon
  end

  local allianceTextures = {
    [1] = "aldmeri",
    [2] = "ebonheart",
    [3] = "daggerfall"
  }
  AllianceTexture:SetTexture("esoui/art/stats/alliancebadge_"..allianceTextures[alliance]..".dds")
end

function DWAllianceRankProgress:GetAllianceLevelText()
  self:DebugMsg(1, "Get alliance rank name text")

  local AvaRankIconTexture = self.uiComponents.rankIcon
  if (self.settings.swapRankAndAllianceIcons == true) then
    AvaRankIconTexture = self.uiComponents.flag
  end

  self.uiComponents.rankLabel:SetText(ZO_CampaignAvARankName:GetText())
  self.uiComponents.rankNumber:SetText(ZO_CampaignAvARankRank:GetText())
  AvaRankIconTexture:SetTexture(ZO_CampaignAvARankIcon:GetTextureFileName())
end

function DWAllianceRankProgress:GetStatus()
  self:DebugMsg(1, "Get alliance level status")
  local currentXP = GetUnitAvARankPoints("player")
  self:DebugMsg(1, "Current XP: <<1>>", currentXP)
  local lastRankXP, nextRankXP = GetAvARankProgress(currentXP)
  self:DebugMsg(1, "Last rank XP: <<1>>", lastRankXP)
  self:DebugMsg(1, "Next rank XP: <<1>>", nextRankXP)

  if nextRankXP == 0 then
    self.uiComponents.bar:SetValue(100)
  else
    local apToNextLevel = currentXP - lastRankXP
    local apRequiredForLevel = nextRankXP - lastRankXP
    local remainingApToRankUp = apRequiredForLevel - apToNextLevel
    self:DebugMsg(1, "Amount of AP required this level: <<1>>", apRequiredForLevel)
    self:DebugMsg(1, "Amount of AP earned this level: <<1>>", apToNextLevel)
    self:DebugMsg(1, "Amount of AP remaining this level: <<1>>", remainingApToRankUp)

    local barValue = (apToNextLevel / apRequiredForLevel) * 100
    if (apRequiredForLevel <= 0) then barValue = 100 end
    self.uiComponents.bar:SetValue(barValue)

    local meterText = ""
    if self.settings.meterType == "nn" then
      meterText = ZO_CommaDelimitNumber(apToNextLevel).." / "..ZO_CommaDelimitNumber(apRequiredForLevel)
    else
      meterText = ZO_CommaDelimitNumber(remainingApToRankUp)..GetString(DW_ARPB_STR_TO_NEXT_RANK)
    end
    if (apRequiredForLevel <= 0) then meterText = "" end
    self.uiComponents.meter:SetText(meterText)

    self:GetAllianceLevelText()
  end
end

function DWAllianceRankProgress:ZoneCheck()
  self:DebugMsg(1, "Zone check")
  if(self.settings.showOnlyInAvaZones == false or IsPlayerInAvAWorld() == true or IsActiveWorldBattleground() == true) then
    self.inPvPZone = true
    self:DebugMsg(1, "Zone is a PvP zone or the player has chosen to show the addon in all zones")
    self:Show()
  else
    self.inPvPZone = false
    self:DebugMsg(1, "Zone is not a PvP zone, and the player has chosen to show the addon only in PvP zones")
    self:Hide()
  end
end

function DWAllianceRankProgress:SetColours()
  self:DebugMsg(1, "Setting component colours")
  local bar = self.uiComponents.bar
  local flag = self.uiComponents.flag
  local rank = self.uiComponents.rankIcon

  if (self.settings.barColour == "white") then
    flag:SetColor(255, 255, 255, 1)
    rank:SetColor(255, 255, 255, 1)
    bar:SetColor(255, 255, 255, 1)
  else
    local flagColour = ZO_ColorDef:New(255, 255, 255, 1)
    local barColour = ZO_ColorDef:New(255, 255, 255, 1)

    if (self.settings.barColour == "alliance") then
      local alliance = GetUnitAlliance("player")
      local colourAlliance = {
        [1] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_ALDMERI_DOMINION)),
        [2] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_EBONHEART_PACT)),
        [3] = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, ALLIANCE_DAGGERFALL_COVENANT))
      }
      local colourAllianceBar = {
        [1] = DW_ARPB_AD_GRADIENT_COLOURS,
        [2] = DW_ARPB_EP_GRADIENT_COLOURS,
        [3] = DW_ARPB_DC_GRADIENT_COLOURS
      }

      flagColour = colourAlliance[alliance]
      barColour = colourAllianceBar[alliance]
    end

    if (self.settings.barColour == "ap") then
      flagColour = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_PROGRESSION, PROGRESSION_COLOR_AVA_RANK_END))
      barColour = ZO_AVA_RANK_GRADIENT_COLORS
    end

    flag:SetColor(flagColour:UnpackRGBA())
    rank:SetColor(flagColour:UnpackRGBA())
    ZO_StatusBar_SetGradientColor(bar, barColour)
  end
end

function DWAllianceRankProgress:Hide()
  self:DebugMsg(1, "Hide the addon frame")
  self.uiComponents.ui:SetHidden(true)
end

function DWAllianceRankProgress:Show()
  self:DebugMsg(1, "Show the addon frame if applicable")
  if (DWAllianceRankProgress.settings.showOnlyInAvaZones == false or (self.settings.showOnlyInAvaZones == true and self.inPvPZone == true)) then
    self.uiComponents.ui:SetHidden(false)
  end
end

function DWAllianceRankProgress:OnAPUpdate()
  self.animation.glowTimeline:PlayFromStart()
  self:GetStatus()
end

EVENT_MANAGER:RegisterForEvent(
  DWAllianceRankProgress.name.."Load",
  EVENT_ADD_ON_LOADED,
  function(...)
    DWAllianceRankProgress:Init(...)
  end
)
