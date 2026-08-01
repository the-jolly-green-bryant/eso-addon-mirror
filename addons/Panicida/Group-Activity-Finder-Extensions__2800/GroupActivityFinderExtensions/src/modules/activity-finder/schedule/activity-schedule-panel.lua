-- =============================================================================
-- Localized Globals
-- =============================================================================
local ZO_Object = ZO_Object
local ZO_MenuBar_AddButton = ZO_MenuBar_AddButton
local ZO_MenuBar_SelectDescriptor = ZO_MenuBar_SelectDescriptor

-- =============================================================================
-- Constants
-- =============================================================================
local ICON_DAILIES = {
  normal = "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
  pressed =
  "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_down.dds",
  highlight =
  "/esoui/art/campaign/campaignbrowser_indexicon_specialevents_over.dds",
}

local ICON_PLEDGES = {
  normal = "/esoui/art/lfg/lfg_indexicon_dungeon_up.dds",
  pressed = "/esoui/art/lfg/lfg_indexicon_dungeon_down.dds",
  highlight = "/esoui/art/lfg/lfg_indexicon_dungeon_over.dds",
}

local ICON_TRIALS = {
  normal = "/esoui/art/lfg/lfg_indexicon_trial_up.dds",
  pressed = "/esoui/art/lfg/lfg_indexicon_trial_down.dds",
  highlight = "/esoui/art/lfg/lfg_indexicon_trial_over.dds",
}

local ICON_QUESTS = {
  normal = "/esoui/art/journal/journal_tabicon_quest_up.dds",
  pressed = "/esoui/art/journal/journal_tabicon_quest_down.dds",
  highlight = "/esoui/art/journal/journal_tabicon_quest_over.dds",
}

-- =============================================================================
-- Module Declaration
-- =============================================================================
local GAFE = GroupActivityFinderExtensions

local ActivitySchedule = ZO_Object:Subclass()

-- =============================================================================
-- Private Functions
-- =============================================================================

--- Creates the menu selector callback function.
--- @param self table The ActivitySchedule instance
--- @return function callback The menu selector callback
local function createMenuSelector(self)
  return function(data)
    local name = self.menuBar:GetName()

    self.pledgesWindow:SetHidden(data.descriptor ~= name .. "ButtonPledges")
    self.dailiesWindow:SetHidden(data.descriptor ~= name .. "DailiesWindow")
    self.trialsWindow:SetHidden(data.descriptor ~= name .. "ButtonTrials")
    self.questsWindow:SetHidden(data.descriptor ~= name .. "ButtonQuests")
    self.menuBarLabel:SetText(data.label)
  end
end

-- =============================================================================
-- Public Functions
-- =============================================================================

--- Creates a new ActivitySchedule instance.
--- @param ... any Constructor arguments passed to Initialize
--- @return table instance The new ActivitySchedule instance
function ActivitySchedule:New(...)
  local instance = ZO_Object.New(self)
  instance:Initialize(...)
  return instance
end

--- Initializes the ActivitySchedule panel.
--- @param control any The parent control for the schedule panel
function ActivitySchedule:Initialize(control)
  self.control = control

  self.questsWindow = self.control:GetNamedChild("QuestsWindow")
  self.trialsWindow = self.control:GetNamedChild("TrialsWindow")
  self.pledgesWindow = self.control:GetNamedChild("PledgesWindow")
  self.dailiesWindow = self.control:GetNamedChild("DailiesWindow")
  self.menuBar = self.control:GetNamedChild("MenuBar")
  self.menuBarLabel = self.menuBar:GetNamedChild("Label")

  self:InitializeControls()
end

--- Initializes all child controls.
function ActivitySchedule:InitializeControls()
  self:InitializeFragment()
end

--- Initializes the fragment and its components.
function ActivitySchedule:InitializeFragment()
  self:InitializeMenuBar()
end

--- Initializes the menu bar with navigation buttons.
function ActivitySchedule:InitializeMenuBar()
  local menuSelector = createMenuSelector(self)
  local name = self.menuBar:GetName()

  ZO_MenuBar_AddButton(self.menuBar, {
    descriptor = name .. "DailiesWindow",
    normal = ICON_DAILIES.normal,
    pressed = ICON_DAILIES.pressed,
    highlight = ICON_DAILIES.highlight,
    label = GAFE.Loc("DailiesSchedule"),
    callback = menuSelector,
  })

  ZO_MenuBar_AddButton(self.menuBar, {
    descriptor = name .. "ButtonPledges",
    normal = ICON_PLEDGES.normal,
    pressed = ICON_PLEDGES.pressed,
    highlight = ICON_PLEDGES.highlight,
    label = GAFE.Loc("PledgesSchedule"),
    callback = menuSelector,
  })

  ZO_MenuBar_AddButton(self.menuBar, {
    descriptor = name .. "ButtonTrials",
    normal = ICON_TRIALS.normal,
    pressed = ICON_TRIALS.pressed,
    highlight = ICON_TRIALS.highlight,
    label = GAFE.Loc("TrialsSchedule"),
    callback = menuSelector,
  })

  if GAFE.SavedVars.beta then
    ZO_MenuBar_AddButton(self.menuBar, {
      descriptor = name .. "ButtonQuests",
      normal = ICON_QUESTS.normal,
      pressed = ICON_QUESTS.pressed,
      highlight = ICON_QUESTS.highlight,
      label = GAFE.Loc("QuestsSchedule"),
      callback = menuSelector,
    })
  end

  ZO_MenuBar_SelectDescriptor(self.menuBar, name .. "DailiesWindow")
end

-- =============================================================================
-- Module Registration
-- =============================================================================

--- Global initialization handler for the ActivitySchedule panel.
--- Called by the XML OnInitialized handler.
--- @param control any The control being initialized
function GAFE_ActivitySchedulePanel_OnInitialized(control)
  GAFE.ActivitySchedule = ActivitySchedule:New(control)
end
