-- ============================================================================
-- Localized Globals
-- ============================================================================
local GAFE = GroupActivityFinderExtensions

local GROUP_LIST = GROUP_LIST
local InformationTooltip = InformationTooltip
local SetTooltipText = SetTooltipText
local SI_GROUP_LIST_PANEL_CHARACTER_NAME = SI_GROUP_LIST_PANEL_CHARACTER_NAME
local ZO_PostHook = ZO_PostHook
local ZO_ScrollList_GetData = ZO_ScrollList_GetData
local ZO_ShouldPreferUserId = ZO_ShouldPreferUserId
local ZO_SocialListKeyboard = ZO_SocialListKeyboard
local zo_strformat = zo_strformat

-- ============================================================================
-- Module Declaration
-- ============================================================================
local GroupExtensions = {}

-- ============================================================================
-- Private Functions
-- ============================================================================

--- Sets up group list entry with user ID preference support.
--- Wraps the base SetupGroupEntry to display displayName when user prefers IDs.
--- @param baseSetupGroupEntry function The original GROUP_LIST.SetupGroupEntry function
--- @return function The wrapped setup function
local function createSetupGroupEntry(baseSetupGroupEntry)
  return function(self, control, data)
    baseSetupGroupEntry(self, control, data)
    local isPreferUserId = ZO_ShouldPreferUserId()

    if isPreferUserId then
      control.characterNameLabel:SetText(
        zo_strformat(
          SI_GROUP_LIST_PANEL_CHARACTER_NAME,
          data.index,
          data.displayName
        )
      )
    end
  end
end

--- Updates tooltip to show raw character name when hovering over group member.
--- Only applies when user prefers user IDs over character names.
--- @param self table The social list keyboard instance
--- @param control any The UI control being hovered
local function updateTooltipHook(self, control)
  local row = control:GetParent()
  local data = ZO_ScrollList_GetData(row)
  local isPreferUserId = ZO_ShouldPreferUserId()

  if isPreferUserId then
    InformationTooltip:ClearLines()
    SetTooltipText(
      InformationTooltip,
      data.rawCharacterName
    )
  end
end

-- ============================================================================
-- Public Functions
-- ============================================================================

--- Initializes the group extensions module.
--- Hooks into GROUP_LIST to support user ID preference display.
function GroupExtensions.Init()
  local baseSetupGroupEntry = GROUP_LIST.SetupGroupEntry
  GROUP_LIST.SetupGroupEntry = createSetupGroupEntry(baseSetupGroupEntry)
  ZO_PostHook(ZO_SocialListKeyboard, "CharacterName_OnMouseEnter",
    updateTooltipHook)
end

-- ============================================================================
-- Module Registration
-- ============================================================================
GAFE.GroupExtensions = GroupExtensions
