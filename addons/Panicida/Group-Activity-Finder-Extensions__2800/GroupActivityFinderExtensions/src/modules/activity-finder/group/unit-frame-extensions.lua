-- ============================================================================
-- Localized Globals
-- ============================================================================
local GAFE = GroupActivityFinderExtensions

local CALLBACK_MANAGER = CALLBACK_MANAGER
local DoesUnitExist = DoesUnitExist
local EVENT_MANAGER = EVENT_MANAGER
local GetGroupUnitTagByIndex = GetGroupUnitTagByIndex
local GetUnitEffectiveChampionPoints = GetUnitEffectiveChampionPoints
local GetUnitLevel = GetUnitLevel
local IsUnitDead = IsUnitDead
local IsUnitOnline = IsUnitOnline
local MAX_GROUP_SIZE_THRESHOLD = MAX_GROUP_SIZE_THRESHOLD
local ZO_HIGHLIGHT_TEXT = ZO_HIGHLIGHT_TEXT
local ZO_PostHook = ZO_PostHook
local ZO_SELECTED_TEXT = ZO_SELECTED_TEXT
local ZO_UnitFrameObject = ZO_UnitFrameObject
local ZO_UnitFrames_GetUnitFrame = ZO_UnitFrames_GetUnitFrame
local zo_iconTextFormat = zo_iconTextFormat

-- ============================================================================
-- Constants
-- ============================================================================
local ADDON_NAME = GAFE.name
local CHAMPION_ICON_SIZE = 16
local FADED_ALPHA_VALUE = 0.4
local FULL_ALPHA_VALUE = 1
local LEVEL_LABEL_WIDTH = 60
local LEVEL_LABEL_HEIGHT = 20
local LEVEL_LABEL_OFFSET_X = 0
local LEVEL_LABEL_OFFSET_Y_NORMAL = 9
local LEVEL_LABEL_OFFSET_Y_RAID = -7
local LEVEL_LABEL_FONT_NORMAL = "ZoFontGameBold"
local LEVEL_LABEL_FONT_RAID = "ZoFontGameBold"


-- ============================================================================
-- Module Declaration
-- ============================================================================
local UnitFrameExtensions = {}

-- Cache for created level labels keyed by frame name
local levelLabels = {}

local ignoreTags = {
  ["reticleover"] = true,
  ["reticleovertarget"] = true
}

-- ============================================================================
-- Private Functions
-- ============================================================================

--- Gets or creates a level label for a unit frame.
--- @param unitFrame table The unit frame object
--- @return table|nil levelLabel The level label control, or nil if creation failed
local function GetOrCreateLevelLabel(unitFrame)
  if not unitFrame or not unitFrame.frame then
    return nil
  end

  local frame = unitFrame.frame
  local frameName = frame:GetName()

  -- Check if label already exists in cache
  if levelLabels[frameName] then
    return levelLabels[frameName]
  end

  -- Get the name label to anchor to
  local nameLabel = unitFrame.nameLabel
  if not nameLabel then
    return nil
  end

  local isRaidUnitFrame = frameName:find("^ZO_RaidUnitFrame") ~= nil
  local offsetY = isRaidUnitFrame and LEVEL_LABEL_OFFSET_Y_RAID or
      LEVEL_LABEL_OFFSET_Y_NORMAL
  local fontName = isRaidUnitFrame and LEVEL_LABEL_FONT_RAID or
      LEVEL_LABEL_FONT_NORMAL

  -- Create new label using LibPanicida
  local labelName = frameName .. "_GAFE_Level"
  local levelLabel = LibPanicida.Controls.Label(
    labelName,
    frame,
    { LEVEL_LABEL_WIDTH, LEVEL_LABEL_HEIGHT },
    { TOPLEFT, nameLabel, BOTTOMLEFT, LEVEL_LABEL_OFFSET_X, offsetY },
    fontName,
    nil,
    { TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER }
  )

  if not levelLabel then
    return nil
  end

  -- Cache the label
  levelLabels[frameName] = levelLabel

  return levelLabel
end

--- Updates the level label alpha and color to match native unit frame fade behavior.
--- @param unitFrame table The unit frame object
--- @param isNearby boolean Whether the unit is in support range
local function UpdateLevelLabelAlpha(unitFrame, isNearby)
  if not unitFrame or not unitFrame.frame then
    return
  end

  local frameName = unitFrame.frame:GetName()
  local levelLabel = levelLabels[frameName]
  if not levelLabel then
    return
  end

  local unitTag = unitFrame:GetUnitTag()
  local color
  if unitTag == "reticleover" then
    color = ZO_SELECTED_TEXT
  else
    color = ZO_HIGHLIGHT_TEXT
  end

  local alphaValue = isNearby and FULL_ALPHA_VALUE or FADED_ALPHA_VALUE
  levelLabel:SetColor(color:UnpackRGBA())
  levelLabel:SetAlpha(alphaValue)
end

--- Updates the level display for a specific unit frame.
--- @param unitTag string The unit tag (e.g., "group1")
local function UpdateUnitFrameLevel(unitTag)
  if not unitTag or not DoesUnitExist(unitTag) or ignoreTags[unitTag] then
    return
  end

  local unitFrame = ZO_UnitFrames_GetUnitFrame(unitTag)
  if not unitFrame then
    return
  end

  local levelLabel = GetOrCreateLevelLabel(unitFrame)
  if not levelLabel then
    return
  end

  -- Check if unit is online
  if not IsUnitOnline(unitTag) or IsUnitDead(unitTag) then
    levelLabel:SetHidden(true)
    return
  end

  -- Get level information
  local level = GetUnitLevel(unitTag)
  local championPoints = GetUnitEffectiveChampionPoints(unitTag)

  -- Update label text
  if level and level > 0 then
    levelLabel:SetText(ZO_GetLevelOrChampionPointsString(
      level,
      championPoints,
      CHAMPION_ICON_SIZE
    ))
    levelLabel:SetHidden(false)
  else
    levelLabel:SetHidden(true)
  end
end

--- Updates level display for all group unit frames.
local function UpdateAllGroupFrameLevels()
  for i = 1, MAX_GROUP_SIZE_THRESHOLD do
    local unitTag = GetGroupUnitTagByIndex(i)
    if unitTag then
      UpdateUnitFrameLevel(unitTag)
    end
  end
end

--- Event handler for level updates.
--- @param eventCode number The event code
--- @param unitTag string The unit tag that leveled up
local function OnLevelUpdate(eventCode, unitTag)
  UpdateUnitFrameLevel(unitTag)
end

--- Event handler for champion point updates.
--- @param eventCode number The event code
--- @param unitTag string The unit tag whose CP changed
local function OnChampionPointUpdate(eventCode, unitTag)
  UpdateUnitFrameLevel(unitTag)
end

--- Event handler for group member changes.
local function OnGroupUpdate()
  UpdateAllGroupFrameLevels()
end

--- Event handler for unit death state changes.
--- @param eventCode number The event code
--- @param unitTag string The unit tag whose death state changed
--- @param isDead boolean Whether the unit is now dead
local function OnUnitDeathStateChanged(eventCode, unitTag, isDead)
  UpdateUnitFrameLevel(unitTag)
end

--- Callback handler for unit frame anchor updates.
local function OnUnitFrameAnchorsUpdated()
  UpdateAllGroupFrameLevels()
end

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Initializes the unit frame extensions module.
--- Hooks into the unit frame system to display player levels on group frames.
function UnitFrameExtensions.Init()
  -- Register for events
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames", EVENT_LEVEL_UPDATE,
    OnLevelUpdate)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames",
    EVENT_CHAMPION_POINT_UPDATE, OnChampionPointUpdate)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames",
    EVENT_GROUP_MEMBER_JOINED, OnGroupUpdate)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames",
    EVENT_GROUP_MEMBER_LEFT, OnGroupUpdate)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames", EVENT_GROUP_UPDATE,
    OnGroupUpdate)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames",
    EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupUpdate)
  EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnitFrames",
    EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged)

  -- Register for callback when unit frame anchors are updated
  CALLBACK_MANAGER:RegisterCallback("OnUnitFrameAnchorsUpdated",
    OnUnitFrameAnchorsUpdated)

  -- Hook into RefreshControls to update levels when frames refresh
  ZO_PostHook(ZO_UnitFrameObject, "RefreshControls", function(self)
    local unitTag = self:GetUnitTag()
    if unitTag then
      UpdateUnitFrameLevel(unitTag)
    end
  end)

  -- Hook into DoAlphaUpdate to fade level label with native controls
  ZO_PostHook(ZO_UnitFrameObject, "DoAlphaUpdate", function(self, isNearby)
    UpdateLevelLabelAlpha(self, isNearby)
  end)

  -- Initial update for any existing group
  UpdateAllGroupFrameLevels()
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.UnitFrameExtensions = UnitFrameExtensions
