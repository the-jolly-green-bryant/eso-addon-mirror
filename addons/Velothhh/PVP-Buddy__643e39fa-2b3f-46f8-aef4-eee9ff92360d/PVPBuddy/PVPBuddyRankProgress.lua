-- PvP Buddy embedded port of Dusty Warehouse Alliance Rank Progress v1.18.
-- Integrated so PvP Buddy can show the same top-left Alliance Rank HUD style.

PVPBuddyRankProgress = PVPBuddyRankProgress or {}
PVPBuddyRankProgress.name = "PVPBuddy"
PVPBuddyRankProgress.originalName = "PVPBuddyRankProgress"
PVPBuddyRankProgress.version = "1.18-pvpbuddy-0.1.92"
PVPBuddyRankProgress.settingsDefaults = {
  position = {
    x = 0,
    y = 0
  },
  barColour = "alliance",
  showOnlyInAvaZones = true,
  swapRankAndAllianceIcons = false,
  meterType = "nn",
  displayMode = "alliance"
}
PVPBuddyRankProgress.settings = PVPBuddyRankProgress.settingsDefaults
PVPBuddyRankProgress.addonLoaded = false
PVPBuddyRankProgress.inPvPZone = false
PVPBuddyRankProgress.debugLevel = 0
PVPBuddyRankProgress.debugPrefix = "[PVPBuddy AllianceRank] "
PVPBuddyRankProgress.debugMsgCount = 0
PVPBuddyRankProgress.lastVeterancyDebug = ""

if PVPBUDDY_RANK_STR_TO_NEXT_RANK == nil and type(ZO_CreateStringId) == "function" then
  ZO_CreateStringId("PVPBUDDY_RANK_STR_TO_NEXT_RANK", " AP until next rank")
end

local function PBRANK_SafeCall(label, fn, default, ...)
  if type(fn) ~= "function" then return default end
  local ok, a, b, c, d = pcall(fn, ...)
  if ok then return a, b, c, d end
  return default
end

local function PBRANK_GetUnitAlliance()
  return PBRANK_SafeCall("GetUnitAlliance", GetUnitAlliance, ALLIANCE_NONE or 0, "player") or (ALLIANCE_NONE or 0)
end

local function PBRANK_CommaNumber(value)
  value = tonumber(value) or 0
  value = math.floor(value + 0.5)

  if type(ZO_CommaDelimitNumber) == "function" then
    return ZO_CommaDelimitNumber(value)
  end

  local sign = ""
  if value < 0 then
    sign = "-"
    value = -value
  end

  local text = tostring(value)
  while true do
    local changed
    text, changed = string.gsub(text, "^(-?%d+)(%d%d%d)", "%1,%2")
    if changed == 0 then break end
  end

  return sign .. text
end

local function PBRANK_GetAllianceBadgeTexture(alliance)
  local allianceTextures = {
    [ALLIANCE_ALDMERI_DOMINION or 1] = "aldmeri",
    [ALLIANCE_EBONHEART_PACT or 2] = "ebonheart",
    [ALLIANCE_DAGGERFALL_COVENANT or 3] = "daggerfall"
  }

  local key = allianceTextures[alliance] or "ebonheart"
  return "esoui/art/stats/alliancebadge_" .. key .. ".dds"
end

local function PBRANK_GetAllianceColorDef(alliance)
  if type(ZO_ColorDef) == "table" and type(GetInterfaceColor) == "function" then
    local allianceConst = alliance
    if allianceConst == ALLIANCE_ALDMERI_DOMINION or allianceConst == ALLIANCE_EBONHEART_PACT or allianceConst == ALLIANCE_DAGGERFALL_COVENANT then
      return ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_ALLIANCE, allianceConst))
    end
  end

  if type(ZO_ColorDef) == "table" then
    if alliance == (ALLIANCE_ALDMERI_DOMINION or 1) then return ZO_ColorDef:New(0.95, 0.80, 0.20, 1) end
    if alliance == (ALLIANCE_EBONHEART_PACT or 2) then return ZO_ColorDef:New(0.90, 0.18, 0.18, 1) end
    if alliance == (ALLIANCE_DAGGERFALL_COVENANT or 3) then return ZO_ColorDef:New(0.28, 0.48, 1.00, 1) end
    return ZO_ColorDef:New(1, 1, 1, 1)
  end

  return nil
end

local function PBRANK_IsCyrodiilOnly()
  local inAva = PBRANK_SafeCall("IsPlayerInAvAWorld", IsPlayerInAvAWorld, false) == true
  local inImperialCity = false
  local inBattleground = false

  if type(IsInImperialCity) == "function" then
    inImperialCity = PBRANK_SafeCall("IsInImperialCity", IsInImperialCity, false) == true
  end

  if type(IsActiveWorldBattleground) == "function" then
    inBattleground = PBRANK_SafeCall("IsActiveWorldBattleground", IsActiveWorldBattleground, false) == true
  end

  return inAva and not inImperialCity and not inBattleground
end

local function PBRANK_GetPVPBuddySetting(key, default)
  if PVPBuddy and PVPBuddy.saved and PVPBuddy.saved[key] ~= nil then
    return PVPBuddy.saved[key]
  end

  return default
end

local function PBRANK_CallFirst(names, ...)
  for i = 1, #names do
    local fn = _G[names[i]]

    if type(fn) == "function" then
      local ok, a, b, c, d, e = pcall(fn, ...)

      if ok and a ~= nil then
        return a, b, c, d, e, names[i]
      end
    end
  end

  return nil
end

local function PBRANK_CallFirstWithArgSets(names, argSets)
  for i = 1, #names do
    local fn = _G[names[i]]

    if type(fn) == "function" then
      for j = 1, #argSets do
        local args = argSets[j]
        local ok, a, b, c, d, e = pcall(fn, unpack(args))

        if ok and a ~= nil then
          return a, b, c, d, e, names[i]
        end
      end
    end
  end

  return nil
end

local function PBRANK_ClampPercent(value)
  value = tonumber(value) or 0

  if value < 0 then return 0 end
  if value > 100 then return 100 end
  return value
end

local function PBRANK_GetControlText(names)
  for i = 1, #names do
    local control = _G[names[i]]

    if control and type(control.GetText) == "function" then
      local ok, value = pcall(function() return control:GetText() end)

      if ok and value and tostring(value) ~= "" then
        return tostring(value)
      end
    end
  end

  return nil
end

local function PBRANK_GetControlTexture(names)
  for i = 1, #names do
    local control = _G[names[i]]

    if control and type(control.GetTextureFileName) == "function" then
      local ok, value = pcall(function() return control:GetTextureFileName() end)

      if ok and value and tostring(value) ~= "" then
        return tostring(value)
      end
    end
  end

  return nil
end

local function PBRANK_SetControlColor(control, colorDef)
  if not control then return end

  if colorDef and type(colorDef.UnpackRGBA) == "function" then
    control:SetColor(colorDef:UnpackRGBA())
  else
    control:SetColor(1, 1, 1, 1)
  end
end

local function PBRANK_SetRankIconSize(control, size)
  if control and type(control.SetDimensions) == "function" then
    control:SetDimensions(size, size)
  end
end

local PBRANK_ALLIANCE_RANK_ICON_SIZE = 21
local PBRANK_VETERANCY_RANK_ICON_SIZE = 32

local PBRANK_ALLIANCE_RANK_LABEL_FONT = "$(BOLD_FONT)|17|shadow"
local PBRANK_VETERANCY_RANK_LABEL_FONT = "$(BOLD_FONT)|20|shadow"

local function PBRANK_GetVeterancyManagerInfo()
  local manager = ZO_VETERANCY_MANAGER

  if type(manager) ~= "table" then
    return nil
  end

  if type(manager.RefreshRankData) == "function" then
    pcall(function() manager:RefreshRankData() end)
  end

  local rank = nil
  local earned = nil
  local required = nil
  local rankName = nil
  local icon = nil

  if type(manager.GetCurrentRank) == "function" then
    local ok, value = pcall(function() return manager:GetCurrentRank() end)
    if ok then rank = tonumber(value) end
  end

  if type(manager.GetCurrentTierProgress) == "function" then
    local ok, value = pcall(function() return manager:GetCurrentTierProgress() end)
    if ok then earned = tonumber(value) end
  end

  if type(manager.GetCurrentTierTotal) == "function" then
    local ok, value = pcall(function() return manager:GetCurrentTierTotal() end)
    if ok then required = tonumber(value) end
  end

  if type(manager.GetCurrentRankName) == "function" then
    local ok, value = pcall(function() return manager:GetCurrentRankName() end)
    if ok and value and tostring(value) ~= "" then rankName = tostring(value) end
  end

  if type(manager.GetCurrentRankData) == "function" then
    local ok, rankData = pcall(function() return manager:GetCurrentRankData() end)

    if ok and type(rankData) == "table" then
      if (not rankName or rankName == "") and type(rankData.GetName) == "function" then
        local okName, value = pcall(function() return rankData:GetName() end)
        if okName and value and tostring(value) ~= "" then rankName = tostring(value) end
      end

      if type(rankData.GetLargeIcon) == "function" then
        local okIcon, value = pcall(function() return rankData:GetLargeIcon() end)
        if okIcon and value and tostring(value) ~= "" then icon = tostring(value) end
      end

      if (not icon or icon == "") and type(rankData.GetIcon) == "function" then
        local okIcon, value = pcall(function() return rankData:GetIcon() end)
        if okIcon and value and tostring(value) ~= "" then icon = tostring(value) end
      end
    end
  end

  if rank and earned and required and required > 0 then
    return {
      source = "ZO_VETERANCY_MANAGER",
      rank = rank,
      earned = earned,
      required = required,
      rankName = rankName,
      icon = icon,
    }
  end

  return nil
end

local function PBRANK_GetVeterancyRewardTrackInfo()
  local trackType = REWARD_TRACK_TYPE_AVA_VETERANCY or REWARD_TRACK_TYPE_REWARD_TRACK_TYPE_AVA_VETERANCY

  if not trackType then
    return nil
  end

  if type(GetActiveReferenceTrackIdsForRewardTrackType) ~= "function" or type(GetReferenceTrackIndex) ~= "function" or type(GetInfoForRewardTrack) ~= "function" then
    return nil
  end

  local okRef, referenceTrackId = pcall(GetActiveReferenceTrackIdsForRewardTrackType, trackType)
  if not okRef or not referenceTrackId then return nil end

  local okIndex, trackIndex = pcall(GetReferenceTrackIndex, trackType, referenceTrackId)
  if not okIndex or not trackIndex then return nil end

  local okInfo, _, rank, earned = pcall(GetInfoForRewardTrack, trackType, trackIndex)
  if not okInfo then return nil end

  rank = tonumber(rank) or 0
  earned = tonumber(earned) or 0

  local rewardTrackId = nil
  local required = nil

  if type(GetRewardTrackIdFromReferenceTrackId) == "function" then
    local okReward, value = pcall(GetRewardTrackIdFromReferenceTrackId, trackType, referenceTrackId)
    if okReward then rewardTrackId = value end
  end

  if rewardTrackId and type(GetTotalProgressAtRewardTrackTier) == "function" then
    local okTotal, value = pcall(GetTotalProgressAtRewardTrackTier, rewardTrackId, rank)
    if okTotal then required = tonumber(value) end
  end

  if not required or required <= 0 then return nil end

  local rankName = nil
  local icon = nil

  if type(GetVeterancyRankTitle) == "function" then
    local okName, value = pcall(GetVeterancyRankTitle, rank)
    if okName and value and tostring(value) ~= "" then rankName = tostring(value) end
  end

  if type(GetVeterancyLargeRankIcon) == "function" then
    local okIcon, value = pcall(GetVeterancyLargeRankIcon, rank)
    if okIcon and value and tostring(value) ~= "" then icon = tostring(value) end
  end

  if (not icon or icon == "") and type(GetVeterancyRankIcon) == "function" then
    local okIcon, value = pcall(GetVeterancyRankIcon, rank)
    if okIcon and value and tostring(value) ~= "" then icon = tostring(value) end
  end

  return {
    source = "RewardTrackAPI",
    rank = rank,
    earned = earned,
    required = required,
    rankName = rankName,
    icon = icon,
  }
end

function PVPBuddyRankProgress:GetVeterancyInfo()
  local data = PBRANK_GetVeterancyManagerInfo() or PBRANK_GetVeterancyRewardTrackInfo()

  if data then
    data.rank = tonumber(data.rank) or 0
    data.earned = tonumber(data.earned) or 0
    data.required = tonumber(data.required) or 0

    if data.required > 0 then
      if data.earned < 0 then data.earned = 0 end
      if data.earned > data.required then data.earned = data.required end
    end
  end

  return data
end

function PVPBuddyRankProgress:DebugMsg(level, ...)
  if level <= self.debugLevel then
    self.debugMsgCount = self.debugMsgCount + 1
    local message = zo_strformat(...)
    d(self.debugPrefix .. "[" .. self.debugMsgCount .. "] " .. message)
  end
end

function PVPBuddyRankProgress:SetDebugLevel(level)
  if (level == nil or level == "") then return end

  local levelNumber = tonumber(level)
  if (levelNumber == nil) then return end

  local parsedLevel = math.floor(levelNumber)
  if (parsedLevel < 0) then
    parsedLevel = 0
  elseif (parsedLevel > 4) then
    parsedLevel = 4
  end

  self.debugLevel = parsedLevel
end

function PVPBuddyRankProgress:Init(eventCode, addOnName)
  if (addOnName ~= self.name) then
    return
  end

  EVENT_MANAGER:UnregisterForEvent(self.originalName .. "Load", EVENT_ADD_ON_LOADED)
  self.addonLoaded = true

  self.uiComponents = {
    tlc = PVPBuddyRankProgressTLC,
    ui = PVPBuddyRankProgressUI,
    flag = PVPBuddyRankProgressUIAllianceFlag,
    rankIcon = PVPBuddyRankProgressUIAllianceRankIcon,
    rankLabel = PVPBuddyRankProgressUIAllianceRankLabel,
    bar = PVPBuddyRankProgressUIStatusBar,
    barGlow = PVPBuddyRankProgressUIStatusBarGlowContainer,
    rankNumber = PVPBuddyRankProgressUIAllianceRankNumber,
    meter = PVPBuddyRankProgressUIAlliancePoints
  }

  if not self.uiComponents.ui or not self.uiComponents.bar then
    self:DebugMsg(1, "Alliance Rank Progress XML controls missing")
    return false
  end

  if ANIMATION_MANAGER and type(ANIMATION_MANAGER.CreateTimelineFromVirtual) == "function" and self.uiComponents.barGlow then
    self.animation = {
      glowTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("PVPBuddyRankProgressBarGlow", self.uiComponents.barGlow)
    }
  else
    self.animation = {}
  end

  self.uiComponents.bar:SetMinMax(0, 100)
  self.settings = self.settingsDefaults
  self.settings.showOnlyInAvaZones = true
  self.settings.displayMode = self:GetDisplayMode()

  self:ReAnchor()
  self:GetAllianceFlag()
  self:GetStatus()

  if EVENT_ALLIANCE_POINT_UPDATE ~= nil then
    EVENT_MANAGER:RegisterForEvent(
      self.originalName .. "APUpdate",
      EVENT_ALLIANCE_POINT_UPDATE,
      function(...)
        self:OnAPUpdate()
      end
    )
  end

  if EVENT_ZONE_CHANGED ~= nil then
    EVENT_MANAGER:RegisterForEvent(
      self.originalName .. "ZoneChange",
      EVENT_ZONE_CHANGED,
      function()
        self:ZoneCheck()
      end
    )
  end

  if EVENT_PLAYER_ACTIVATED ~= nil then
    EVENT_MANAGER:RegisterForEvent(
      self.originalName .. "PlayerActivated",
      EVENT_PLAYER_ACTIVATED,
      function()
        self:ZoneCheck()
      end
    )
  end

  if EVENT_REWARD_TRACK_PROGRESS_GAINED ~= nil then
    EVENT_MANAGER:RegisterForEvent(
      self.originalName .. "RewardTrackProgress",
      EVENT_REWARD_TRACK_PROGRESS_GAINED,
      function()
        self:OnAPUpdate()
      end
    )
  end

  if EVENT_REWARD_TRACK_UPDATE_RECEIVED ~= nil then
    EVENT_MANAGER:RegisterForEvent(
      self.originalName .. "RewardTrackUpdate",
      EVENT_REWARD_TRACK_UPDATE_RECEIVED,
      function()
        self:OnAPUpdate()
      end
    )
  end

  if SCENE_MANAGER and type(ZO_HUDFadeSceneFragment) == "table" then
    local arpbFragment = ZO_HUDFadeSceneFragment:New(self.uiComponents.tlc)

    local hud = SCENE_MANAGER:GetScene("hud")
    if hud then hud:AddFragment(arpbFragment) end

    local hudui = SCENE_MANAGER:GetScene("hudui")
    if hudui then hudui:AddFragment(arpbFragment) end
  end

  self:SetColours()
  self:ZoneCheck()

  SLASH_COMMANDS["/pbrankdebug"] = function(...) self:SetDebugLevel(...) end
  SLASH_COMMANDS["/pbranksimulate"] = function(...) self:OnAPUpdate(...) end
  SLASH_COMMANDS["/pbrank"] = function(...) self:OnAPUpdate(...) end
  SLASH_COMMANDS["/pbvetdebug"] = function()
    self:GetStatus()
    d("|c66CCFFPvP Buddy Veterancy:|r " .. tostring(self.lastVeterancyDebug or "no data"))
  end

  return self.addonLoaded
end

function PVPBuddyRankProgress:ApplyPVPBuddyLock()
  if self.uiComponents and self.uiComponents.ui then
    local locked = PBRANK_GetPVPBuddySetting("rankProgressLocked", false) == true

    if type(self.uiComponents.ui.SetMovable) == "function" then
      self.uiComponents.ui:SetMovable(not locked)
    end

    if type(self.uiComponents.ui.SetMouseEnabled) == "function" then
      self.uiComponents.ui:SetMouseEnabled(not locked)
    end
  end
end

function PVPBuddyRankProgress:ReAnchor()
  if self.uiComponents and self.uiComponents.ui and self.settings and self.settings.position then
    self.uiComponents.ui:ClearAnchors()
    self.uiComponents.ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.settings.position.x or 0, self.settings.position.y or 0)
    self.uiComponents.ui:SetScale(1.0)
    self:ApplyPVPBuddyLock()
  end
end

function PVPBuddyRankProgress:OnMoveStop()
  if self.settings and self.settings.position and self.uiComponents and self.uiComponents.ui then
    self.settings.position.x = self.uiComponents.ui:GetLeft()
    self.settings.position.y = self.uiComponents.ui:GetTop()

    if PVPBuddy and PVPBuddy.saved then
      PVPBuddy.saved.rankProgressX = self.settings.position.x
      PVPBuddy.saved.rankProgressY = self.settings.position.y
    end
  end
end

function PVPBuddyRankProgress:GetDisplayMode()
  local mode = PBRANK_GetPVPBuddySetting("rankProgressMode", self.settings and self.settings.displayMode or "alliance")

  if mode ~= "veterancy" then
    mode = "alliance"
  end

  if self.settings then
    self.settings.displayMode = mode
  end

  return mode
end

function PVPBuddyRankProgress:SetDisplayMode(mode)
  if mode ~= "veterancy" then
    mode = "alliance"
  end

  if self.settings then
    self.settings.displayMode = mode
  end

  if PVPBuddy and PVPBuddy.saved then
    PVPBuddy.saved.rankProgressMode = mode
  end

  if self.uiComponents and self.uiComponents.bar then
    self:GetStatus()
    self:SetColours()
    self:ZoneCheck()
  end
end

function PVPBuddyRankProgress:GetAllianceFlag()
  local alliance = PBRANK_GetUnitAlliance()
  local AllianceTexture = self.uiComponents.flag
  if (self.settings.swapRankAndAllianceIcons == true) then
    AllianceTexture = self.uiComponents.rankIcon
  end

  if AllianceTexture then
    AllianceTexture:SetTexture(PBRANK_GetAllianceBadgeTexture(alliance))
  end
end

function PVPBuddyRankProgress:GetAllianceLevelText()
  local AvaRankIconTexture = self.uiComponents.rankIcon
  if (self.settings.swapRankAndAllianceIcons == true) then
    AvaRankIconTexture = self.uiComponents.flag
  end

  if self:GetDisplayMode() == "veterancy" then
    local data = self:GetVeterancyInfo()
    local rank = data and tonumber(data.rank) or 0
    local rankName = data and data.rankName or nil
    local texture = data and data.icon or nil

    if not rankName or tostring(rankName) == "" then
      if rank > 0 then
        rankName = "Veterancy Rank " .. tostring(rank)
      else
        rankName = "Veterancy Rank"
      end
    end

    if not texture or texture == "" then
      texture = PBRANK_GetControlTexture({
        "ZO_CampaignVeterancyRankIcon",
        "ZO_VeterancyRankIcon",
        "ZO_CampaignAvAVeterancyRankIcon",
        "ZO_PvPVeterancyRankIcon",
      })
    end

    if not texture or texture == "" then
      texture = PBRANK_CallFirst({
        "GetVeterancyLargeRankIcon",
        "GetVeterancyRankIcon",
      }, rank)
    end

    if self.uiComponents.rankLabel then
      self.uiComponents.rankLabel:SetFont(PBRANK_VETERANCY_RANK_LABEL_FONT)
      self.uiComponents.rankLabel:SetText(tostring(rankName))
    end

    if self.uiComponents.rankNumber then
      if rank > 0 then
        self.uiComponents.rankNumber:SetText(tostring(rank))
      else
        self.uiComponents.rankNumber:SetText("V")
      end
    end

    if AvaRankIconTexture and texture and texture ~= "" then
      AvaRankIconTexture:SetTexture(texture)
      AvaRankIconTexture:SetColor(1, 1, 1, 1)
      PBRANK_SetRankIconSize(AvaRankIconTexture, PBRANK_VETERANCY_RANK_ICON_SIZE)
    end

    return
  end

  local rank = PBRANK_SafeCall("GetUnitAvARank", GetUnitAvARank, 0, "player") or 0
  local gender = PBRANK_SafeCall("GetUnitGender", GetUnitGender, 0, "player") or 0
  local rankName = ""

  if ZO_CampaignAvARankName and type(ZO_CampaignAvARankName.GetText) == "function" then
    rankName = ZO_CampaignAvARankName:GetText()
  elseif type(GetAvARankName) == "function" then
    rankName = PBRANK_SafeCall("GetAvARankName", GetAvARankName, "", gender, rank) or ""
  end

  if self.uiComponents.rankLabel then
    self.uiComponents.rankLabel:SetFont(PBRANK_ALLIANCE_RANK_LABEL_FONT)
    self.uiComponents.rankLabel:SetText(rankName)
  end

  local rankNumber = ""
  if ZO_CampaignAvARankRank and type(ZO_CampaignAvARankRank.GetText) == "function" then
    rankNumber = ZO_CampaignAvARankRank:GetText()
  else
    rankNumber = tostring(rank)
  end

  if self.uiComponents.rankNumber then
    self.uiComponents.rankNumber:SetText(rankNumber)
  end

  local texture = nil
  if ZO_CampaignAvARankIcon and type(ZO_CampaignAvARankIcon.GetTextureFileName) == "function" then
    texture = ZO_CampaignAvARankIcon:GetTextureFileName()
  elseif type(GetLargeAvARankIcon) == "function" then
    texture = PBRANK_SafeCall("GetLargeAvARankIcon", GetLargeAvARankIcon, nil, rank)
  elseif type(GetAvARankIcon) == "function" then
    texture = PBRANK_SafeCall("GetAvARankIcon", GetAvARankIcon, nil, rank)
  end

  if AvaRankIconTexture and texture and texture ~= "" then
    AvaRankIconTexture:SetTexture(texture)
    PBRANK_SetRankIconSize(AvaRankIconTexture, PBRANK_ALLIANCE_RANK_ICON_SIZE)
  end
end

function PVPBuddyRankProgress:GetAllianceStatus()
  local currentXP = PBRANK_SafeCall("GetUnitAvARankPoints", GetUnitAvARankPoints, 0, "player") or 0
  local lastRankXP, nextRankXP = 0, 0

  if type(GetAvARankProgress) == "function" then
    lastRankXP, nextRankXP = PBRANK_SafeCall("GetAvARankProgress", GetAvARankProgress, 0, currentXP)
  end

  lastRankXP = tonumber(lastRankXP) or 0
  nextRankXP = tonumber(nextRankXP) or 0

  if nextRankXP == 0 then
    self.uiComponents.bar:SetValue(100)
    if self.uiComponents.meter then self.uiComponents.meter:SetText("") end
  else
    local apToNextLevel = currentXP - lastRankXP
    local apRequiredForLevel = nextRankXP - lastRankXP
    local remainingApToRankUp = apRequiredForLevel - apToNextLevel

    local barValue = (apToNextLevel / apRequiredForLevel) * 100
    if (apRequiredForLevel <= 0) then barValue = 100 end
    self.uiComponents.bar:SetValue(barValue)

    local meterText = ""
    if self.settings.meterType == "nn" then
      meterText = PBRANK_CommaNumber(apToNextLevel) .. " / " .. PBRANK_CommaNumber(apRequiredForLevel)
    else
      meterText = PBRANK_CommaNumber(remainingApToRankUp) .. " AP until next rank"
    end

    if (apRequiredForLevel <= 0) then meterText = "" end
    if self.uiComponents.meter then self.uiComponents.meter:SetText(meterText) end
  end

  self:GetAllianceLevelText()
end

function PVPBuddyRankProgress:GetVeterancyStatus()
  local data = self:GetVeterancyInfo()
  local rank = data and tonumber(data.rank) or 0
  local earned = data and tonumber(data.earned) or nil
  local required = data and tonumber(data.required) or nil
  local source = data and tostring(data.source or "unknown") or "none"

  if not earned or not required or required <= 0 then
    earned = 0
    required = 0
  end

  if required > 0 then
    if earned < 0 then earned = 0 end
    if earned > required then earned = required end
  else
    earned = 0
  end

  local barValue = 0
  if required > 0 then
    barValue = PBRANK_ClampPercent((earned / required) * 100)
  end

  if self.uiComponents.bar then
    self.uiComponents.bar:SetValue(barValue)
  end

  if self.uiComponents.meter then
    if required > 0 then
      self.uiComponents.meter:SetText(PBRANK_CommaNumber(earned) .. " / " .. PBRANK_CommaNumber(required))
    else
      self.uiComponents.meter:SetText("0 / 0")
    end
  end

  self.lastVeterancyDebug = "rank=" .. tostring(rank) .. " source=" .. tostring(source) .. " earned=" .. tostring(earned) .. " required=" .. tostring(required)

  self:GetAllianceLevelText()
end

function PVPBuddyRankProgress:GetStatus()
  if self:GetDisplayMode() == "veterancy" then
    self:GetVeterancyStatus()
  else
    self:GetAllianceStatus()
  end
end

function PVPBuddyRankProgress:ZoneCheck()
  local visible = PBRANK_GetPVPBuddySetting("rankProgressVisible", true) == true
  local show = visible and PBRANK_IsCyrodiilOnly()

  self.inPvPZone = show
  self:ApplyPVPBuddyLock()

  if show then
    self:Show()
  else
    self:Hide()
  end
end

function PVPBuddyRankProgress:SetColours()
  local bar = self.uiComponents.bar
  local flag = self.uiComponents.flag
  local rank = self.uiComponents.rankIcon

  if not bar or not flag or not rank then return end

  local alliance = PBRANK_GetUnitAlliance()
  local flagColour = PBRANK_GetAllianceColorDef(alliance)

  if (self.settings.barColour == "white") then
    flag:SetColor(1, 1, 1, 1)
    rank:SetColor(1, 1, 1, 1)
    bar:SetColor(1, 1, 1, 1)
    return
  end

  if (self.settings.barColour == "ap" and type(GetInterfaceColor) == "function" and type(ZO_ColorDef) == "table") then
    flagColour = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_PROGRESSION, PROGRESSION_COLOR_AVA_RANK_END))
    PBRANK_SetControlColor(flag, flagColour)
    if self:GetDisplayMode() == "veterancy" then
      rank:SetColor(1, 1, 1, 1)
    else
      PBRANK_SetControlColor(rank, flagColour)
    end
    if type(ZO_StatusBar_SetGradientColor) == "function" and ZO_AVA_RANK_GRADIENT_COLORS then
      ZO_StatusBar_SetGradientColor(bar, ZO_AVA_RANK_GRADIENT_COLORS)
    else
      PBRANK_SetControlColor(bar, flagColour)
    end
    return
  end

  PBRANK_SetControlColor(flag, flagColour)

  if self:GetDisplayMode() == "veterancy" then
    rank:SetColor(1, 1, 1, 1)
  else
    PBRANK_SetControlColor(rank, flagColour)
  end

  if type(ZO_StatusBar_SetGradientColor) == "function" then
    ZO_StatusBar_SetGradientColor(bar, { flagColour, flagColour })
  else
    PBRANK_SetControlColor(bar, flagColour)
  end
end

function PVPBuddyRankProgress:Hide()
  if self.uiComponents and self.uiComponents.ui then
    self.uiComponents.ui:SetHidden(true)
  end
end

function PVPBuddyRankProgress:Show()
  if self.uiComponents and self.uiComponents.ui then
    local visible = PBRANK_GetPVPBuddySetting("rankProgressVisible", true) == true
    self.uiComponents.ui:SetHidden(not (visible and PBRANK_IsCyrodiilOnly()))
    self:ApplyPVPBuddyLock()
  end
end

function PVPBuddyRankProgress:OnAPUpdate()
  self:ZoneCheck()

  if not self.inPvPZone then return end

  if self.animation and self.animation.glowTimeline then
    self.animation.glowTimeline:PlayFromStart()
  end

  self:GetStatus()
  self:SetColours()
end

EVENT_MANAGER:RegisterForEvent(
  PVPBuddyRankProgress.originalName .. "Load",
  EVENT_ADD_ON_LOADED,
  function(...)
    PVPBuddyRankProgress:Init(...)
  end
)
