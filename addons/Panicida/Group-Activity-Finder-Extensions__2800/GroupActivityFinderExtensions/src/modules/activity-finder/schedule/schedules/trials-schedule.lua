-- =============================================================================
-- LOCALIZED GLOBALS
-- =============================================================================

local GAFE = GroupActivityFinderExtensions
local EM = EVENT_MANAGER
local WM = WINDOW_MANAGER
local libScroll = LibScroll

local GetCurrentCharacterId = GetCurrentCharacterId
local GetNumCharacters = GetNumCharacters
local GetCharacterInfo = GetCharacterInfo
local GetInterfaceColor = GetInterfaceColor
local ZO_FormatTime = ZO_FormatTime
local zo_strformat = zo_strformat
local ZO_PreHookHandler = ZO_PreHookHandler
local ZO_ComboBox = ZO_ComboBox
local ZO_ComboBox_ObjectFromContainer = ZO_ComboBox_ObjectFromContainer
local ZO_Object = ZO_Object

-- =============================================================================
-- CONSTANTS
-- =============================================================================

local ORDERED_TRIALS_ID = {
  AetherianArchive = 1,
  HelRaCitadel = 2,
  SanctumOphidia = 3,
  MawOfLorkhaj = 4,
  HallsOfFabrication = 5,
  AsylumSanctorium = 6,
  Cloudrest = 7,
  Sunspire = 8,
  KynesAegis = 9,
  Rockgrove = 10,
  DreadsailReef = 11,
}

local UPDATE_INTERVAL_MS = 1000
local ROW_HEIGHT = 30
local LABEL_WIDTH = 350
local PLEDGE_WIDTH = 165

-- =============================================================================
-- MODULE DECLARATION
-- =============================================================================

local TrialsSchedule = ZO_Object:Subclass()

-- =============================================================================
-- PRIVATE FUNCTIONS
-- =============================================================================

--- Builds the data items table mapping trial IDs to their display data.
--- @return table dataItems Map of trial IDs to label and activityId
local function buildDataItems()
  return {
    [ORDERED_TRIALS_ID.AetherianArchive] = { label = GAFE.Loc("TrialAetherianArchive"), activityId = GAFE.ACTIVITY_ID.NormalAetherianArchive },
    [ORDERED_TRIALS_ID.HelRaCitadel] = { label = GAFE.Loc("TrialHelRaCitadel"), activityId = GAFE.ACTIVITY_ID.NormalHelRaCitadel },
    [ORDERED_TRIALS_ID.SanctumOphidia] = { label = GAFE.Loc("TrialSanctumOphidia"), activityId = GAFE.ACTIVITY_ID.NormalSanctumOphidia },
    [ORDERED_TRIALS_ID.MawOfLorkhaj] = { label = GAFE.Loc("TrialMawOfLorkhaj"), activityId = GAFE.ACTIVITY_ID.NormalMawOfLorkhaj },
    [ORDERED_TRIALS_ID.HallsOfFabrication] = { label = GAFE.Loc("TrialHallsOfFabrication"), activityId = GAFE.ACTIVITY_ID.NormalHallsOfFabrication },
    [ORDERED_TRIALS_ID.AsylumSanctorium] = { label = GAFE.Loc("TrialAsylumSanctorium"), activityId = GAFE.ACTIVITY_ID.NormalAsylumSanctorium },
    [ORDERED_TRIALS_ID.Cloudrest] = { label = GAFE.Loc("TrialCloudrest"), activityId = GAFE.ACTIVITY_ID.NormalCloudrest },
    [ORDERED_TRIALS_ID.Sunspire] = { label = GAFE.Loc("TrialSunspire"), activityId = GAFE.ACTIVITY_ID.NormalSunspire },
    [ORDERED_TRIALS_ID.KynesAegis] = { label = GAFE.Loc("TrialKynesAegis"), activityId = GAFE.ACTIVITY_ID.NormalKynesAegis },
    [ORDERED_TRIALS_ID.Rockgrove] = { label = GAFE.Loc("TrialRockgrove"), activityId = GAFE.ACTIVITY_ID.NormalRockgrove },
    [ORDERED_TRIALS_ID.DreadsailReef] = { label = GAFE.Loc("TrialDreadsailReef"), activityId = GAFE.ACTIVITY_ID.NormalDreadsailReef }
  }
end

-- =============================================================================
-- PUBLIC FUNCTIONS (Class Methods)
-- =============================================================================

--- Creates a new TrialsSchedule instance.
--- @param ... any Constructor arguments passed to Initialize
--- @return table instance The new TrialsSchedule instance
function TrialsSchedule:New(...)
  local instance = ZO_Object.New(self)
  instance:Initialize(...)
  return instance
end

--- Initializes the TrialsSchedule with the given control.
--- @param control any The parent UI control
function TrialsSchedule:Initialize(control)
  self.control = control
  self.filter = self.control:GetNamedChild("Filter")
  self.listContainer = self.control:GetNamedChild("ContainerListContainer")
  self.characterId = GetCurrentCharacterId()
  self.dataItems = buildDataItems()

  self:InitializeControls()
end

--- Initializes all UI controls and event handlers.
function TrialsSchedule:InitializeControls()
  self:InitializeFragment()
  self:InitializeFilter()
  self:InitializeCountdownLabel()
  self:InitializeEvents()
end

--- Initializes the character filter dropdown.
function TrialsSchedule:InitializeFilter()
  local function OnFilterChanged(...)
    self:OnFilterChanged(...)
  end

  local filterComboBox = ZO_ComboBox_ObjectFromContainer(self.filter)
  filterComboBox:SetSortsItems(false)
  filterComboBox:SetFont("ZoFontWinT1")
  filterComboBox:SetSpacing(4)
  self.filterComboBox = filterComboBox

  local currentCharacterEntry
  local numCharacters = GetNumCharacters()
  for i = 1, numCharacters do
    local characterName, _, _, _, _, _, id, _ = GetCharacterInfo(i)

    local entry = ZO_ComboBox:CreateItemEntry(
      zo_strformat("<<1>>", characterName),
      OnFilterChanged
    )
    entry.data = id
    if id == self.characterId then
      currentCharacterEntry = entry
    end
    self.filterComboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  end

  self.filterComboBox:SelectItem(currentCharacterEntry)
end

--- Initializes the scroll list fragment for displaying trials.
function TrialsSchedule:InitializeFragment()
  local dataItems = self.dataItems

  --- Sets up an individual row in the scroll list.
  --- @param rowControl any The row control to set up
  --- @param data table The data for this row
  --- @param scrollList any The parent scroll list
  local function SetupDataRow(rowControl, data, scrollList)
    local trialsData = GAFE.TRIALS_ACTIVITY_DATA

    local control = rowControl
    local label = control:GetNamedChild("Label")
    local state = control:GetNamedChild("State")

    label:SetDimensions(LABEL_WIDTH, ROW_HEIGHT)
    label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    state:SetDimensions(PLEDGE_WIDTH, ROW_HEIGHT)
    state:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)

    label:SetText(data.label)
    local activityData = trialsData[data.activityId]
    if activityData then
      local chestAvailable = GAFE.TrialsChests.GetTimeUntilNextChest(
        self.characterId,
        activityData.q
      ) <= 0
      if chestAvailable then
        state:SetText("|cFFD700" .. GAFE.Loc("Available") .. "|r")
      else
        state:SetText("|c32CD32" .. GAFE.Loc("Done") .. "|r")
      end
    end
  end

  local parent = self.listContainer

  local scrollData = {
    name          = "GAFE_TrialsWindowScrollList",
    parent        = parent,
    rowHeight     = ROW_HEIGHT,
    rowTemplate   = "GAFE_TrialsScheduleRow",
    setupCallback = SetupDataRow,
  }

  local scrollList = libScroll:CreateScrollList(scrollData)
  scrollList:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
  scrollList:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)

  scrollList:Update(dataItems)

  self.scrollList = scrollList

  ZO_PreHookHandler(ZO_SearchingForGroup, 'OnEffectivelyShown',
    function() self.scrollList:Update(dataItems) end)
end

--- Handles filter dropdown selection changes.
--- @param comboBox any The combo box control
--- @param entryText string The selected entry text
--- @param entry table The selected entry data
function TrialsSchedule:OnFilterChanged(comboBox, entryText, entry)
  self.characterId = entry.data
  self.scrollList:Update(self.dataItems)
end

--- Initializes the countdown label for weekly reset timer.
function TrialsSchedule:InitializeCountdownLabel()
  self.countdownLabel = WM:CreateControl(
    self.control:GetName() .. "Countdown", self.control, CT_LABEL)
  self.countdownLabel:SetFont("ZoFontWinH4")
  self.countdownLabel:SetColor(GetInterfaceColor(
    INTERFACE_COLOR_TYPE_TEXT_COLORS,
    INTERFACE_TEXT_COLOR_NORMAL))
  self.countdownLabel:ClearAnchors()
  self.countdownLabel:SetAnchor(BOTTOM, self.control, BOTTOM, 0, -10)
  self.countdownLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

--- Updates the countdown label with time until weekly reset.
function TrialsSchedule:UpdateCountdownLabel()
  local timeRemaining = GAFE.RewardTracker.GetTimeUntilWeeklyReset()
  if timeRemaining > 0 then
    local formattedTime = ZO_FormatTime(
      timeRemaining,
      TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS,
      TIME_FORMAT_PRECISION_SECONDS
    )
    self.countdownLabel:SetText(GAFE.Loc("WeeklyReset") .. ": " .. formattedTime)
  end
end

--- Initializes show/hide event handlers for the control.
function TrialsSchedule:InitializeEvents()
  ZO_PreHookHandler(self.control, 'OnEffectivelyShown',
    function()
      self:UpdateCountdownLabel()
      EM:RegisterForUpdate("GAFE_TrialsSchedule_UpdateCountdown",
        UPDATE_INTERVAL_MS,
        function() self:UpdateCountdownLabel() end)
    end)
  ZO_PreHookHandler(self.control, 'OnEffectivelyHidden',
    function() EM:UnregisterForUpdate("GAFE_TrialsSchedule_UpdateCountdown") end)
end

-- =============================================================================
-- MODULE REGISTRATION
-- =============================================================================

--- Global initialization function called from XML.
--- @param control any The control to initialize
function GAFE_TrialsSchedule_Init(control)
  GAFE.TrialsSchedule = TrialsSchedule:New(control)
end
