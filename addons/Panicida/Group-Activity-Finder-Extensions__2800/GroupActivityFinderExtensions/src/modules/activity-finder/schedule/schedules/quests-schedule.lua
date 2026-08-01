local GAFE = GroupActivityFinderExtensions
local EVENT_MANAGER = EVENT_MANAGER
local libScroll = LibScroll
local LQD = LibQuestData

local dataItems = {}

local QuestsSchedule = ZO_Object:Subclass()

function QuestsSchedule:New(...)
  local instance = ZO_Object.New(self)
  instance:Initialize(...)
  return instance
end

function QuestsSchedule:Initialize(control)
  self.control = control

  self.characterFilter = self.control:GetNamedChild("CharacterFilter")
  self.zoneFilter = self.control:GetNamedChild("ZoneFilter")

  self.listContainer = self.control:GetNamedChild("ContainerListContainer")

  self.characterId = GetCurrentCharacterId()

  self:InitializeData()
  self:InitializeControls()
  self:InitializeEvents()
end

function QuestsSchedule:InitializeData()
  local allZones = LibQuestData_GetAllZones()
  for zoneName, zone in pairs(allZones) do
    local quests = {}
    for _, questPinData in ipairs(zone) do
      local questId = questPinData[LQD.quest_map_pin_index.quest_id]
      local npcName = LQD:get_quest_giver(
        questPinData[LQD.quest_map_pin_index.quest_giver],
        GAFE.lang
      )
      local questRepeat = LQD:get_quest_repeat(questId)
      -- questRepeat == QUEST_REPEAT_REPEATABLE

      if npcName and questRepeat == QUEST_REPEAT_DAILY then
        table.insert(quests, { questId = questId, npcName = npcName })
      end
    end

    if #quests > 0 then
      table.sort(quests, function(a, b)
        return a.npcName < b.npcName
      end)
      table.insert(dataItems, { zoneName = zoneName, quests = quests })
    end
  end
  table.sort(dataItems, function(a, b)
    return a.zoneName < b.zoneName
  end)
end

function QuestsSchedule:InitializeControls()
  self:InitializeFragment()
  self:InitializeFilters()
  self:InitializeCountdownLabel()
end

function QuestsSchedule:InitializeFilters()
  self:InitializeCharacterFilter()
  self:InitializeZoneFilter()
end

function QuestsSchedule:InitializeCharacterFilter()
  local function OnFilterChanged(...)
    self:OnCharacterFilterChanged(...)
  end

  local filterComboBox = ZO_ComboBox_ObjectFromContainer(self.characterFilter)
  filterComboBox:SetSortsItems(false)
  filterComboBox:SetFont("ZoFontWinT1")
  filterComboBox:SetSpacing(4)
  self.characterFilterComboBox = filterComboBox

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
    self.characterFilterComboBox:AddItem(entry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  end

  self.characterFilterComboBox:SelectItem(currentCharacterEntry)
end

function QuestsSchedule:InitializeZoneFilter()
  local function OnFilterChanged(...)
    self:OnZoneFilterChanged(...)
  end

  local filterComboBox = ZO_ComboBox_ObjectFromContainer(self.zoneFilter)
  filterComboBox:SetSortsItems(false)
  filterComboBox:SetFont("ZoFontWinT1")
  filterComboBox:SetSpacing(4)
  self.zoneFilterComboBox = filterComboBox

  local favouritesEntry = ZO_ComboBox:CreateItemEntry(
    zo_strformat("<<1>>", "Favourites"),
    OnFilterChanged
  )
  favouritesEntry.data = "favourites"
  self.zoneFilterComboBox:AddItem(favouritesEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)
  local allEntry = ZO_ComboBox:CreateItemEntry(
    zo_strformat("<<1>>", "All"),
    OnFilterChanged
  )
  allEntry.data = "all"
  self.zoneFilterComboBox:AddItem(allEntry, ZO_COMBOBOX_SUPPRESS_UPDATE)

  self.zoneFilterComboBox:SelectItem(favouritesEntry)
end

function QuestsSchedule:InitializeFragment()
  local function SetupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    local control = rowControl
    local zoneName = control:GetNamedChild("ZoneName")
    local questsContainer = control:GetNamedChild("Quests")

    local height = 30
    local labelWidth = 350
    local statusWidth = 165

    zoneName:SetDimensions(labelWidth, height)
    zoneName:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)

    local questsCount = 0
    for _, questData in ipairs(data.quests) do
      local name = control:GetName() .. "Quest" .. (questsCount + 1)
      local quest = _G[name] or
          WINDOW_MANAGER:CreateControl(name, questsContainer, CT_LABEL)
      quest:SetDimensions(labelWidth, height)
      quest:ClearAnchors()
      quest:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
      quest:SetText(questData.npcName)
      quest:SetHidden(false)
      questsCount = questsCount + 1
    end

    questsContainer:SetDimensions(
      labelWidth + statusWidth,
      height * questsCount + 1
    )
    questsContainer:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)

    zoneName:SetText(data.zoneName)
  end

  local parent = self.listContainer

  -- Create the scroll list
  local scrollData = {
    name          = "GAFE_QuestsWindowScrollList",
    parent        = parent,
    rowHeight     = 30,
    rowTemplate   = "GAFE_QuestsScheduleRow",
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

function QuestsSchedule:OnCharacterFilterChanged(comboBox, entryText, entry)
  self.characterId = entry.data
  self.scrollList:Update(dataItems)
end

function QuestsSchedule:OnZoneFilterChanged(comboBox, entryText, entry)
  -- TODO: implement
  -- self.characterId = entry.data
  -- self.scrollList:Update(dataItems)
end

function QuestsSchedule:InitializeCountdownLabel()
  self.countdownLabel = WINDOW_MANAGER:CreateControl(
    self.control:GetName() .. "Countdown", self.control, CT_LABEL)
  self.countdownLabel:SetFont("ZoFontWinH4")
  self.countdownLabel:SetColor(GetInterfaceColor(
    INTERFACE_COLOR_TYPE_TEXT_COLORS,
    INTERFACE_TEXT_COLOR_NORMAL))
  self.countdownLabel:ClearAnchors()
  self.countdownLabel:SetAnchor(BOTTOM, self.control, BOTTOM, 0, -10)
  self.countdownLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

function QuestsSchedule:UpdateCountdownLabel()
  local timeRemaining = GAFE.RewardTracker.GetTimeUntilDailyReset()
  local formattedTime = ZO_FormatTime(
    timeRemaining,
    TIME_FORMAT_STYLE_SHOW_LARGEST_TWO_UNITS,
    TIME_FORMAT_PRECISION_SECONDS
  )
  self.countdownLabel:SetText(GAFE.Loc("NextReset") .. ": " .. formattedTime)
end

function QuestsSchedule:InitializeEvents()
  ZO_PreHookHandler(self.control, 'OnEffectivelyShown',
    function()
      self:UpdateCountdownLabel()
      EVENT_MANAGER:RegisterForUpdate("GAFE_QuestsSchedule_UpdateCountdown", 1000,
        function() self:UpdateCountdownLabel() end)
    end)
  ZO_PreHookHandler(self.control, 'OnEffectivelyHidden',
    function()
      EVENT_MANAGER:UnregisterForUpdate(
        "GAFE_QuestsSchedule_UpdateCountdown")
    end)
end

function GAFE_QuestsSchedule_Init(control)
  GAFE.QuestsSchedule = QuestsSchedule:New(control)
end
