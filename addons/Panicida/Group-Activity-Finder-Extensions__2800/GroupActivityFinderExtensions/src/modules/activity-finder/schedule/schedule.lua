-- =============================================================================
-- Localized Globals
-- =============================================================================
local GAFE = GroupActivityFinderExtensions
local WINDOW_MANAGER = WINDOW_MANAGER
local GROUP_MENU_KEYBOARD = GROUP_MENU_KEYBOARD
local ZO_FadeSceneFragment = ZO_FadeSceneFragment
local ZO_ACTIVITY_FINDER_SORT_PRIORITY = ZO_ACTIVITY_FINDER_SORT_PRIORITY
local GuiRoot = GuiRoot

-- =============================================================================
-- Constants
-- =============================================================================
local BASE_DUNGEONS_PRIORITY = ZO_ACTIVITY_FINDER_SORT_PRIORITY.DUNGEONS
local ACTIVITY_PRIORITY = BASE_DUNGEONS_PRIORITY + 1000

-- =============================================================================
-- Module Declaration
-- =============================================================================
local Schedule = {}

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Initializes the Activity Schedule panel and registers it with the group menu.
--- Creates the UI control and adds the schedule category to GROUP_MENU_KEYBOARD.
function Schedule.Init()
  local control = _G["GAFE_ActivitySchedulePanel"] or
      WINDOW_MANAGER:CreateControlFromVirtual(
        'GAFE_ActivitySchedulePanel',
        GuiRoot,
        "GAFE_ActivitySchedulePanel"
      )

  local fragment = ZO_FadeSceneFragment:New(control)

  GROUP_MENU_KEYBOARD:AddCategory({
    priority = ACTIVITY_PRIORITY,
    name = GAFE.Loc("ActivitySchedule"),
    categoryFragment = fragment,
    normalIcon = "esoui/art/journal/journal_tabicon_cadwell_up.dds",
    pressedIcon = "esoui/art/journal/journal_tabicon_cadwell_down.dds",
    mouseoverIcon = "esoui/art/journal/journal_tabicon_cadwell_over.dds",
  })
end

-- =============================================================================
-- Module Registration
-- =============================================================================
GAFE.Schedule = Schedule
