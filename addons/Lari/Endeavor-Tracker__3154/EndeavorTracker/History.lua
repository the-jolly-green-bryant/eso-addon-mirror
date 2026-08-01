--[[
ZO_SortFilterList code derived from Ziggr's ScrollListExample
https://github.com/ziggr/ESO-ScrollListExample
]]

local ET = _G["ET"]

local WM = WINDOW_MANAGER

------------------------------------
-- USEFUL FUNCTIONS --
------------------------------------

-- Use for History Table only because of formatting
function ET.GetMiscRewardsTextFromTable(rewardsTable)
  local rewardText = ""
  if #rewardsTable > 1 then
    for rewardIndex = 2, #rewardsTable do
      for rewardId, quantity in pairs(rewardsTable[rewardIndex]) do
        local rewardType = GetRewardType(rewardId)
        if rewardType == REWARD_ENTRY_TYPE_ADD_CURRENCY then
          local currencyType = GetAddCurrencyRewardInfo(rewardId)
          local currencyIcon =  GetCurrencyLootKeyboardIcon(currencyType)
          rewardText = string.format("%s|cFFFFFF%i|r |t15:15:%s|t  ", rewardText, quantity, currencyIcon)
        elseif rewardType == REWARD_ENTRY_TYPE_EXPERIENCE then
          rewardText = string.format("%s|cFFFFFF%i XP|r ", rewardText, quantity)
        end
      end
    end
    return rewardText
  else
    rewardText = "--"
    return rewardText
  end
end

function ET.FormatDate(date)
  local y = string.sub(date, 1, 4)
  local m = string.sub(date, 5, 6)
  local d = string.sub(date, 7, 8)
  local formattedDate = string.format("%s/%s/%s", y, m, d)
  return formattedDate
end

function ET.GetHistoryTable(activityType)
  local historyTable
  if activityType == TIMED_ACTIVITY_TYPE_DAILY then
    historyTable = ET.SavedVars.History.Daily
  elseif activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
    historyTable = ET.SavedVars.History.Weekly
  end
  return historyTable
end

function ET.SaveHistoryTable(activityType, historyTable)
  if activityType == TIMED_ACTIVITY_TYPE_DAILY then
    ET.SavedVars.History.Daily = historyTable
  elseif activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
    ET.SavedVars.History.Weekly = historyTable
  end
end

------------------------------------
-- ZO_SORTFILTERLIST --
------------------------------------

ETUnitList = ZO_SortFilterList:Subclass()
ETUnitList.defaults = {}
ET.DEFAULT_TEXT = ZO_ColorDef:New(0.2, 0.65, 0.2, 1)
ET.UnitList = nil
ET.units = {}

ETUnitList.SORT_KEYS = {
  ["date"] = {},
  ["name"] = { tiebreaker = "date" },
  ["rewards"] = { tiebreaker = "date" },
  ["misc"] = {tiebreaker = "date" },
}

function ETUnitList:New()
  local units = ZO_SortFilterList.New(self, ET_History)
  return units
end

function ETUnitList:Initialize(control)
  ZO_SortFilterList.Initialize(self, control)

  self.sortHeaderGroup:SelectHeaderByKey("date")
  -- ZO_SortHeader_OnMouseExit(ET_HistoryHeadersDate)

  self.masterList = {}
  ZO_ScrollList_AddDataType(self.list, 1, "ET_HistoryRowTemplate", 30, function(control, data) self:SetupUnitRow(control, data) end)
  ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
  self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, ETUnitList.SORT_KEYS, self.currentSortOrder) end
  self:RefreshData()
end

function ETUnitList:BuildMasterList()
  self.masterList = {}
  local units = ET.units
  for i, v in ipairs(units) do
    local data = v
    table.insert(self.masterList, data)
  end
end

function ETUnitList:FilterScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  ZO_ClearNumericallyIndexedTable(scrollData)

  for i = 1, #self.masterList do
    local data = self.masterList[i]
    table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
  end
end

function ETUnitList:SortScrollList()
  local scrollData = ZO_ScrollList_GetDataList(self.list)
  table.sort(scrollData, self.sortFunction)
end

function ETUnitList:SetupUnitRow(control, data)
  control.data = data
  control.date = GetControl(control, "Date")
  control.name = GetControl(control, "Name")
  control.rewards = GetControl(control, "Rewards")
  control.misc = GetControl(control, "Misc")

  control.date:SetText(ET.FormatDate(data.date))
  control.name:SetText(data.name)
  control.rewards:SetText(data.rewards .. " |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t")
  control.misc:SetText(data.miscRewards)

  control.date.normalColor = ZO_ColorDef:New(1, 1, 1, 1)
  control.name.normalColor = ZO_ColorDef:New(0.2, 0.65, 0.2, 1)
  control.rewards.normalColor = ZO_ColorDef:New(1, 1, 1, 1)

  ZO_SortFilterList.SetupRow(self, control, data)
end

function ET.HistoryRowOnMouseEnter(control)
  if control.name:WasTruncated() then
    InitializeTooltip(InformationTooltip, control.name, BOTTOM)
    InformationTooltip:SetWidth(300)
    SetTooltipText(InformationTooltip, control.data.name)
  end
  ET.UnitList:Row_OnMouseEnter(control)
end

function ET.HistoryRowOnMouseExit(control)
  ClearTooltip(InformationTooltip)
  ET.UnitList:Row_OnMouseExit(control)
end

-- Refreshes the list
function ET.RefreshHistory(activityType)
  local historyTable = ET.GetHistoryTable(activityType)
  local historyList = historyTable.Log

  ET.units = {}
  for i = 1, #historyList do
    ET.units[i] = {
      date = historyList[i].date,
      name = historyList[i].name,
      rewards = historyList[i].rewardsTable[1][2873],
      miscRewards = ET.GetMiscRewardsTextFromTable(historyList[i].rewardsTable)
    }
  end
  ET.UnitList:RefreshData()
end

--------------------------------
-- HISTORY UI --
--------------------------------

function ET.ToggleHistoryTabs(tab)
  if tab == "DAILIES" then
    ET_HistoryDailiesButton:SetState(BSTATE_PRESSED, false)
    ET_HistoryWeekliesButton:SetState(BSTATE_NORMAL, false)
    ET_HistoryStatsButton:SetState(BSTATE_NORMAL, false)
    ET.RefreshHistory(TIMED_ACTIVITY_TYPE_DAILY)
    ET_HistoryHeaders:SetHidden(false)
    ET_HistoryList:SetHidden(false)
    ET_HistoryStats:SetHidden(true)
  elseif tab == "WEEKLIES" then
    ET_HistoryDailiesButton:SetState(BSTATE_NORMAL, false)
    ET_HistoryWeekliesButton:SetState(BSTATE_PRESSED, false)
    ET_HistoryStatsButton:SetState(BSTATE_NORMAL, false)
    ET_HistoryHeaders:SetHidden(false)
    ET_HistoryList:SetHidden(false)
    ET.RefreshHistory(TIMED_ACTIVITY_TYPE_WEEKLY)
    ET_HistoryStats:SetHidden(true)
  elseif tab == "STATS" then
    ET_HistoryDailiesButton:SetState(BSTATE_NORMAL, false)
    ET_HistoryWeekliesButton:SetState(BSTATE_NORMAL, false)
    ET_HistoryStatsButton:SetState(BSTATE_PRESSED, false)
    ET_HistoryHeaders:SetHidden(true)
    ET_HistoryList:SetHidden(true)
    ET_HistoryStats:SetHidden(false)
  end
end

function ET_History_On_Resize_Stop()
  if ET_HistoryDailiesButton:GetState() == BSTATE_PRESSED then
    ET.RefreshHistory(TIMED_ACTIVITY_TYPE_DAILY)
  elseif ET_HistoryWeekliesButton:GetState() == BSTATE_PRESSED then
    ET.RefreshHistory(TIMED_ACTIVITY_TYPE_WEEKLY)
  end
end

---------------------------------------
-- HISTORY LOCALS --
---------------------------------------

local function TotalCompletedByType(historyTable)
  return historyTable.Stats.TotalCompleted
end

local function TotalSealsByType(historyTable)
  local totalSealsByType = historyTable.Stats.TotalSeals .. " |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  return totalSealsByType
end

local function AverageSealsByType(historyTable)
  local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
  end

  local totalSeals = historyTable.Stats.TotalSeals
  local totalCompleted = historyTable.Stats.TotalCompleted

  -- To avoid 0/0 = NaN from happening
  if totalCompleted == 0 and totalSeals == 0 then
    totalCompleted = 1
  end
  local averageSeals = round(totalSeals / totalCompleted, 2) .. " |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  return averageSeals
end

local function MaxSealsByType(historyTable)
  local maxSeals = historyTable.Stats.MaxSeals .. " |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  return maxSeals
end

local function TotalLifetimeSeals()
  local totalLifetimeSeals = ET.SavedVars.History.TotalLifetimeSeals .." |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  return totalLifetimeSeals
end

local function TotalSealsSpent()
  local currentTotalEndeavors = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT)
  local totalLifetimeSeals = ET.SavedVars.History.TotalLifetimeSeals
  local totalSealsSpent = (totalLifetimeSeals - currentTotalEndeavors) .. " |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  return totalSealsSpent
end

local function CurrentTotalSeals()
  local currentTotalEndeavors = GetCurrencyAmount(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT) .. " |t15:15:esoui/art/currency/currency_seals_of_endeavor_64.dds|t"
  return currentTotalEndeavors
end

local function TotalGoldFromEndeavors()
  local gold = ET.SavedVars.History.Daily.Stats.TotalGold + ET.SavedVars.History.Daily.Stats.TotalGold
  gold = gold .. " |t15:15:esoui/art/icons/item_generic_coinbag.dds|t"
  return gold
end

local StatsTable = {
  [1] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalDailyCompleted), func = TotalCompletedByType, activityType = TIMED_ACTIVITY_TYPE_DAILY },
  [2] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalWeeklyCompleted), func = TotalCompletedByType, activityType = TIMED_ACTIVITY_TYPE_WEEKLY },
  [3] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsDailies), func = TotalSealsByType, activityType = TIMED_ACTIVITY_TYPE_DAILY },
  [4] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsWeeklies), func = TotalSealsByType, activityType = TIMED_ACTIVITY_TYPE_WEEKLY },
  [5] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_AverageSealsDailies), func = AverageSealsByType, activityType = TIMED_ACTIVITY_TYPE_DAILY },
  [6] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_AverageSealsWeeklies), func = AverageSealsByType, activityType = TIMED_ACTIVITY_TYPE_WEEKLY },
  [7] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_MostSealsDailies), func = MaxSealsByType, activityType = TIMED_ACTIVITY_TYPE_DAILY },
  [8] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_MostSealsWeeklies), func = MaxSealsByType, activityType = TIMED_ACTIVITY_TYPE_WEEKLY },
  [9] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalLifetimeSeals), func = TotalLifetimeSeals },
  [10] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalSealsSpent), func = TotalSealsSpent },
  [11] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_CurrentTotalSeals), func = CurrentTotalSeals },
  [12] = { name = GetString(ENDEAVOR_TRACKER_HistoryPanelStats_TotalGoldAcquired), func = TotalGoldFromEndeavors },
}

------------------------------
-- HISTORY FUNCTIONS --
------------------------------

-- Called when an endeavor is completed
function ET.UpdateHistory(id, name, activityType, rewardsTable, totalEndeavors)
  -- Get table from SVs
  local historyTable = ET.GetHistoryTable(activityType)

  -- Add completed endeavor info to Log
  local data = {
    date = GetDate(),
    id = id,
    name = name,
    rewardsTable = rewardsTable,
    totalEndeavors = totalEndeavors,
  }
  table.insert(historyTable.Log, data)

  -- Save endeavor ID and name to master table
  historyTable.IdList[id] = name

  -- Count how often IDs are repeated
  historyTable.Repeats[id] = (historyTable.Repeats[id] or 0) + 1

  -- Save new data to SVs
  ET.SaveHistoryTable(historyTable, activityType)

  -- Update stats
  ET.UpdateHistoryStats(activityType, data)

  ET.TrimHistory(historyTable)
end

function ET.TrimHistory(historyTable)
  local date = historyTable.Log[1].date
  -- Remove any endeavor data older than a year
  while GetDate() - historyTable.Log[1].date > 10000 do
    table.remove(historyTable.Log, 1)
  end
end

-- Update SV table for daily and weekly stats
function ET.UpdateHistoryStats(activityType, data)
  -- DAILY or WEEKLY stats
  local historyTable = ET.GetHistoryTable(activityType)

  historyTable.Stats.TotalCompleted = historyTable.Stats.TotalCompleted + 1
  historyTable.Stats.TotalSeals = historyTable.Stats.TotalSeals + data.rewardsTable[1][2873]

  if data.rewardsTable[1][2873] > historyTable.Stats.MaxSeals then
    historyTable.Stats.MaxSeals = data.rewardsTable[1][2873]
  end

  if data.rewardsTable[1][2873] < historyTable.Stats.MinSeals then
    historyTable.Stats.MinSeals = data.rewardsTable[1][2873]
  end

  for i = 1, #data.rewardsTable do
    for rewardId, quantity in pairs(data.rewardsTable[i]) do
      if rewardId == 2808 then
        historyTable.Stats.TotalGold = historyTable.Stats.TotalGold + quantity
      end
    end
  end

  ET.SaveHistoryTable(historyTable, activityType)

  -- Overall stats
  ET.SavedVars.History.TotalLifetimeSeals = ET.SavedVars.History.TotalLifetimeSeals + data.rewardsTable[1][2873]
end

-- Refreshes stats on init and on endeavor completed
function ET.RefreshHistoryStats()
  for i = 1, #StatsTable do
    local control = WM:GetControlByName(string.format("ET_HistoryStats_%i", i))
    control.name = GetControl(control, "Name")
    control.value = GetControl(control, "Value")

    local historyTable = ET.GetHistoryTable(StatsTable[i].activityType)

    control.name:SetText(StatsTable[i].name)
    control.value:SetText(StatsTable[i].func(historyTable))
  end
end

---------------------------
-- INIT --
---------------------------

function ET.InitHistoryList()
  ET.UnitList = ETUnitList:New()
  ET.RefreshHistory(TIMED_ACTIVITY_TYPE_DAILY)
  ET.ToggleHistoryTabs("DAILIES")
end

function ET.InitHistoryStats()
  local parentControl = WM:GetControlByName("ET_HistoryStatsContainerScrollChild")
  parentControl:SetResizeToFitDescendents(true)
  local emptyControl = WM:CreateControl("ET_HistoryStats_Empty", parentControl)
  emptyControl:SetAnchor(TOPLEFT, parentControl, TOPLEFT, 0, 0)

  for i = 1, #StatsTable do
    local relativeControl = parentControl:GetChild(parentControl:GetNumChildren())
    local control = WM:CreateControlFromVirtual(string.format("ET_HistoryStats_%i", i), parentControl, "ET_StatsRowTemplate")
    control:SetAnchor(TOPLEFT, relativeControl, BOTTOMLEFT, 0, 0)
  end

  ET_HistoryStatsTrackingDate:SetText(GetString(ENDEAVOR_TRACKER_HistoryPanelTrackingDate) .. ET.FormatDate(ET.SavedVars.History.LifetimeSealsInitDate))
  ET.SetToolTip(ET_HistoryStatsTrackingDate, RIGHT, GetString(ENDEAVOR_TRACKER_HistoryPanelTrackingDateTooltip))

  ET.RefreshHistoryStats()
end

function ET.InitHistoryHandlers()
  ET_HistoryDailiesButton:SetHandler("OnClicked", function(self) ET.ToggleHistoryTabs("DAILIES") end)
  ET_HistoryWeekliesButton:SetHandler("OnClicked", function(self) ET.ToggleHistoryTabs("WEEKLIES") end)
  ET_HistoryStatsButton:SetHandler("OnClicked", function(self) ET.ToggleHistoryTabs("STATS") end)
end

function ET.InitHistoryStrings()
  -- zo_strformat(GetString

end

function ET.InitHistory()
  ET.InitHistoryList()
  ET.InitHistoryStats()
  ET.InitHistoryHandlers()
end
