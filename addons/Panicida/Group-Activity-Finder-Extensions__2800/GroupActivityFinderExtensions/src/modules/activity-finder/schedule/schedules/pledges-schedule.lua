local GAFE = GroupActivityFinderExtensions
local EVENT_MANAGER = EVENT_MANAGER
local LQD = LibQuestData
local libScroll = LibScroll
local LUP = LibUndauntedPledges

--- Gets the pledge quest IDs for a given day offset.
--- @param dayOffset number The number of days from today (0 = today, 1 = tomorrow, etc.)
--- @return table dayPledges Table with pledge quest IDs indexed by NPC (1=Maj, 2=Glirion, 3=Urgarlag)
local function GetPledgesOfDay(dayOffset)
  local pledges = LUP.GetPledges(dayOffset)
  return {
    [1] = pledges[LUP.BASE1].questId,
    [2] = pledges[LUP.BASE2].questId,
    [3] = pledges[LUP.DLC1].questId
  }
end

local PledgesSchedule = ZO_Object:Subclass()


function PledgesSchedule:New(...)
  local instance = ZO_Object.New(self)
  instance:Initialize(...)
  return instance
end

function PledgesSchedule:Initialize(control)
  self.control = control

  self.filter = self.control:GetNamedChild("Filter")

  self.today = self.control:GetNamedChild("Today")
  self.todayHeader = self.today:GetNamedChild("Header")
  self.todayListContainer = self.today:GetNamedChild("ListContainer")

  self.upcoming = self.control:GetNamedChild("Upcoming")
  self.upcomingHeader = self.upcoming:GetNamedChild("Header")
  self.upcomingListContainer = self.upcoming:GetNamedChild("ListContainer")

  self.todayPledges = GetPledgesOfDay(0)

  self:InitializeControls()
  self:InitializeEvents()
end

function PledgesSchedule:InitializeControls()
  self:InitializeFilter()
  self:InitializeTodayFragment()
  self:InitializeUpcomingFragment()
  self:InitializeCountdownLabel()
end

function PledgesSchedule:InitializeFilter()
  local function OnFilterChanged(...)
    self:OnFilterChanged(...)
  end

  local filterComboBox = ZO_ComboBox_ObjectFromContainer(self.filter)
  filterComboBox:SetSortsItems(false)
  filterComboBox:SetFont("ZoFontWinT1")
  filterComboBox:SetSpacing(4)
  self.filterComboBox = filterComboBox

  local todayEntry = ZO_ComboBox:CreateItemEntry("Today", OnFilterChanged)
  todayEntry.data = 'today'
  self.filterComboBox:AddItem(todayEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  local upcomingEntry = ZO_ComboBox:CreateItemEntry("Upcoming", OnFilterChanged)
  upcomingEntry.data = 'upcoming'
  self.filterComboBox:AddItem(upcomingEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)

  self.filterComboBox:SelectItem(todayEntry)
end

function PledgesSchedule:InitializeTodayFragment()
  local function SetupHeaderRow(rowControl, data)
    -- Do whatever you want/need to setup the control
    local control = rowControl
    local label = control:GetNamedChild("Label")
    local maj = control:GetNamedChild("Maj")
    local glirion = control:GetNamedChild("Glirion")
    local urgarlag = control:GetNamedChild("Urgarlag")

    label:SetText(data.character)
    maj:SetText(data.maj)
    glirion:SetText(data.glirion)
    urgarlag:SetText(data.urgarlag)

    label:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))
    maj:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))
    glirion:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))
    urgarlag:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))

    local height = 30
    local labelWidth = 80
    local pledgeWidth = 165

    label:SetDimensions(labelWidth, height)
    label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    maj:SetDimensions(pledgeWidth, height)
    maj:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth, 0)
    glirion:SetDimensions(pledgeWidth, height)
    glirion:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth, 0)
    urgarlag:SetDimensions(pledgeWidth, height)
    urgarlag:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth * 2, 0)
  end

  local function SetupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    local control = rowControl
    local label = control:GetNamedChild("Label")
    local maj = control:GetNamedChild("Maj")
    local glirion = control:GetNamedChild("Glirion")
    local urgarlag = control:GetNamedChild("Urgarlag")

    label:SetText(data.character)
    maj:SetText(data.maj)
    glirion:SetText(data.glirion)
    urgarlag:SetText(data.urgarlag)

    local height = 30
    local labelWidth = 80
    local pledgeWidth = 165

    label:SetDimensions(labelWidth, height)
    label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    maj:SetDimensions(pledgeWidth, height)
    maj:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth, 0)
    glirion:SetDimensions(pledgeWidth, height)
    glirion:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth, 0)
    urgarlag:SetDimensions(pledgeWidth, height)
    urgarlag:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth * 2, 0)
  end

  -- Setup header
  SetupHeaderRow(
    self.todayHeader,
    {
      name = '',
      maj = LibPanicida.Utils.CleanPledgeQuestName(LQD:get_quest_name(
        self.todayPledges[1], GAFE.lang)),
      glirion = LibPanicida.Utils.CleanPledgeQuestName(LQD:get_quest_name(
        self.todayPledges[2], GAFE.lang)),
      urgarlag = LibPanicida.Utils.CleanPledgeQuestName(LQD:get_quest_name(
        self.todayPledges[3], GAFE.lang)),
    }
  )

  local parent = self.todayListContainer

  -- Create the scroll list
  local scrollData = {
    name          = "GAFE_PledgesWindowTodayScrollList",
    parent        = parent,
    rowHeight     = 30,
    rowTemplate   = "GAFE_PledgesScheduleRow",
    setupCallback = SetupDataRow,
  }

  local scrollList = libScroll:CreateScrollList(scrollData)
  scrollList:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
  scrollList:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)

  self.todayScrollList = scrollList
  self:RefreshTodayPledges()
end

function PledgesSchedule:InitializeUpcomingFragment()
  local function SetupHeaderRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    local control = rowControl
    local label = control:GetNamedChild("Label")
    local maj = control:GetNamedChild("Maj")
    local glirion = control:GetNamedChild("Glirion")
    local urgarlag = control:GetNamedChild("Urgarlag")

    label:SetText(data.character)
    maj:SetText(data.maj)
    glirion:SetText(data.glirion)
    urgarlag:SetText(data.urgarlag)

    label:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))
    maj:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))
    glirion:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))
    urgarlag:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS,
      INTERFACE_TEXT_COLOR_SELECTED))

    local height = 30
    local labelWidth = 80
    local pledgeWidth = 165

    label:SetDimensions(labelWidth, height)
    label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    maj:SetDimensions(pledgeWidth, height)
    maj:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth, 0)
    glirion:SetDimensions(pledgeWidth, height)
    glirion:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth, 0)
    urgarlag:SetDimensions(pledgeWidth, height)
    urgarlag:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth * 2, 0)
  end

  local function SetupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    local control = rowControl
    local label = control:GetNamedChild("Label")
    local maj = control:GetNamedChild("Maj")
    local glirion = control:GetNamedChild("Glirion")
    local urgarlag = control:GetNamedChild("Urgarlag")

    label:SetText(zo_strformat(GAFE.Loc("InXDays"), data.day))
    maj:SetText(data.maj)
    glirion:SetText(data.glirion)
    urgarlag:SetText(data.urgarlag)

    local height = 30
    local labelWidth = 80
    local pledgeWidth = 165

    label:SetDimensions(labelWidth, height)
    label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    maj:SetDimensions(pledgeWidth, height)
    maj:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth, 0)
    glirion:SetDimensions(pledgeWidth, height)
    glirion:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth, 0)
    urgarlag:SetDimensions(pledgeWidth, height)
    urgarlag:SetAnchor(TOPLEFT, control, TOPLEFT, labelWidth + pledgeWidth * 2, 0)
  end

  -- Setup header
  SetupHeaderRow(
    self.upcomingHeader,
    {
      character = '',
      maj = "Maj",
      glirion = "Glirion",
      urgarlag = "Urgarlag",
    }
  )

  local parent = self.upcomingListContainer

  -- Create the scroll list
  local scrollData = {
    name          = "GAFE_PledgesWindowUpcomingScrollList",
    parent        = parent,
    rowHeight     = 30,
    rowTemplate   = "GAFE_PledgesScheduleRow",
    setupCallback = SetupDataRow,
  }

  local scrollList = libScroll:CreateScrollList(scrollData)
  scrollList:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
  scrollList:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, 0, 0)

  -- Add data to scroll list.
  local dataItems = {}
  for day = 0, 14 do
    local pledges = GetPledgesOfDay(day)
    local data = {
      day = day,
      maj = LibPanicida.Utils.CleanPledgeQuestName(LQD:get_quest_name(pledges[1],
        GAFE.lang)),
      glirion = LibPanicida.Utils.CleanPledgeQuestName(LQD:get_quest_name(
        pledges[2], GAFE.lang)),
      urgarlag = LibPanicida.Utils.CleanPledgeQuestName(LQD:get_quest_name(
        pledges[3], GAFE.lang)),
    }
    dataItems[day] = data
  end
  scrollList:Update(dataItems)

  self.upcomingScrollList = scrollList
end

function PledgesSchedule:OnFilterChanged(comboBox, entryText, entry)
  self.today:SetHidden(entry.data ~= 'today')
  self.upcoming:SetHidden(entry.data ~= 'upcoming')
end

function PledgesSchedule:InitializeEvents()
  local function OnShown()
    self:RefreshTodayPledges()
    self:UpdateCountdownLabel()
    EVENT_MANAGER:RegisterForUpdate(
      "GAFE_PledgesSchedule_UpdateCountdown",
      1000,
      function() self:UpdateCountdownLabel() end
    )
  end

  local function OnHidden()
    EVENT_MANAGER:UnregisterForUpdate("GAFE_PledgesSchedule_UpdateCountdown")
  end

  ZO_PreHookHandler(self.today, 'OnEffectivelyShown', OnShown)
  ZO_PreHookHandler(self.today, 'OnEffectivelyHidden', OnHidden)
end

function PledgesSchedule:InitializeCountdownLabel()
  self.countdownLabel = WINDOW_MANAGER:CreateControl(
    self.control:GetName() .. "Countdown",
    self.control, CT_LABEL
  )
  self.countdownLabel:SetFont("ZoFontWinH4")
  self.countdownLabel:SetColor(GetInterfaceColor(
    INTERFACE_COLOR_TYPE_TEXT_COLORS,
    INTERFACE_TEXT_COLOR_NORMAL))
  self.countdownLabel:ClearAnchors()
  self.countdownLabel:SetAnchor(BOTTOM, self.control, BOTTOM, 0, -10)
  self.countdownLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

function PledgesSchedule:UpdateCountdownLabel()
  local timeRemaining = GAFE.RewardTracker.GetTimeUntilDailyReset()

  if timeRemaining > 0 then
    local formattedTime = ZO_FormatTime(
      timeRemaining,
      TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS,
      TIME_FORMAT_PRECISION_SECONDS
    )
    self.countdownLabel:SetText(GAFE.Loc("NextReset") .. ": " .. formattedTime)
  end
end

function PledgesSchedule:RefreshTodayPledges()
  -- Add data to scroll list.
  local dataItems = {}
  local numCharacters = GetNumCharacters()
  for i = 1, numCharacters do
    local characterName, _, _, _, _, _, characterId, _ = GetCharacterInfo(i)

    local donePledges = GAFE.SavedVars.dungeons.donePledges[characterId] or {};
    local data = {
      character = zo_strformat("<<1>>", characterName),
      maj = LibPanicida.Utils.TableContainsKey(
            donePledges,
            self.todayPledges[1]
          ) and ("|c32CD32" .. GAFE.Loc("Done") .. "|r") or
          ("|cFFD700" .. GAFE.Loc("Available") .. "|r"),
      glirion = LibPanicida.Utils.TableContainsKey(
            donePledges,
            self.todayPledges[2]
          ) and ("|c32CD32" .. GAFE.Loc("Done") .. "|r") or
          ("|cFFD700" .. GAFE.Loc("Available") .. "|r"),
      urgarlag = LibPanicida.Utils.TableContainsKey(
            donePledges,
            self.todayPledges[3]
          ) and ("|c32CD32" .. GAFE.Loc("Done") .. "|r") or
          ("|cFFD700" .. GAFE.Loc("Available") .. "|r")
    }
    dataItems[i] = data
  end
  self.todayScrollList:Update(dataItems)
end

function GAFE_PledgesSchedule_Init(control)
  GAFE.PledgesSchedule = PledgesSchedule:New(control)
end
