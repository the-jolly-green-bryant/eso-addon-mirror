local internal = _G["LibGuildStore_Internal"]

LGSTime = ZO_Object:Subclass()

LGS_TIMEFRAME_HOURS = 1
LGS_TIMEFRAME_DAYS = 2
LGS_TIMEFRAME_WEEKS = 3
LGS_TIMEFRAME_GUILD_WEEKS = 4

LGS_DATERANGE_TODAY = 1
LGS_DATERANGE_YESTERDAY = 2
LGS_DATERANGE_THISWEEK = 3
LGS_DATERANGE_LASTWEEK = 4
LGS_DATERANGE_PRIORWEEK = 5
LGS_DATERANGE_7DAY = 6
LGS_DATERANGE_10DAY = 7
LGS_DATERANGE_30DAY = 8
LGS_DATERANGE_CUSTOM = 9

LGS_WINDOW_TIME_RANGE_DEFAULT = 1
LGS_WINDOW_TIME_RANGE_THIRTY = 2
LGS_WINDOW_TIME_RANGE_SIXTY = 3
LGS_WINDOW_TIME_RANGE_NINETY = 4
LGS_WINDOW_TIME_RANGE_CUSTOM = 5

local customTimeframeTypeText = {
  [LGS_TIMEFRAME_HOURS] = GetString(GS_CUSTOM_TIMEFRAME_HOURS),
  [LGS_TIMEFRAME_DAYS] = GetString(GS_CUSTOM_TIMEFRAME_DAYS),
  [LGS_TIMEFRAME_WEEKS] = GetString(GS_CUSTOM_TIMEFRAME_WEEKS),
  [LGS_TIMEFRAME_GUILD_WEEKS] = GetString(GS_CUSTOM_TIMEFRAME_GUILD_WEEKS),
}

LGSTime.customTimeframeType = LGS_TIMEFRAME_DAYS
LGSTime.customTimeframe = 90
LGSTime.customFilterDateRange = 90
LGSTime.customTimeframeText = GetString(GS_CUSTOM_TIMEFRAME_DAYS)
LGSTime.oldestTimestamp = nil

LGSTime.defaultCustomTimeframeType = LGS_TIMEFRAME_DAYS
LGSTime.defaultCustomTimeframe = 90
LGSTime.defaultCustomFilterDateRange = 90

local function guild_system_offline()
  local weekCutoff = 1595962800

  if GetWorldName() == 'EU Megaserver' then
    weekCutoff = 1595941200
  end

  while weekCutoff + (7 * ZO_ONE_DAY_IN_SECONDS) < GetTimeStamp() do
    weekCutoff = weekCutoff + (7 * ZO_ONE_DAY_IN_SECONDS)
  end

  return weekCutoff
end

function LGSTime:Initialize()
  self.oldestTime = nil
  self.newestTime = nil
  self.dateRanges = {}
  self.filterDateRanges = {}

  local _, kioskCycle = GetGuildKioskCycleTimes()
  self.kiosk_cycle = kioskCycle
  self.week_start = self.kiosk_cycle - (7 * ZO_ONE_DAY_IN_SECONDS)
  self.initDateTime = GetTimeStamp()
  self.midnight_today = GetTimeStamp() - GetSecondsSinceMidnight()

  if self.kiosk_cycle == 0 then
    self.week_start = guild_system_offline()
    self.kiosk_cycle = self.week_start + (7 * ZO_ONE_DAY_IN_SECONDS)
  end

  self:BuildDateRangeTable()
  self:BuildFilterDateRangeTable()
end

function LGSTime:GetCustomTimeframe()
  return self.customTimeframe
end

function LGSTime:GetCustomTimeframeType()
  return self.customTimeframeType
end

function LGSTime:GetCustomFilterDateRange()
  return self.customFilterDateRange
end

function LGSTime:GetCustomTimeframeChoices()
  return {
    GetString(GS_CUSTOM_TIMEFRAME_HOURS),
    GetString(GS_CUSTOM_TIMEFRAME_DAYS),
    GetString(GS_CUSTOM_TIMEFRAME_WEEKS),
    GetString(GS_CUSTOM_TIMEFRAME_GUILD_WEEKS),
  }
end

function LGSTime:GetCustomTimeframeChoiceValues()
  return {
    LGS_TIMEFRAME_HOURS,
    LGS_TIMEFRAME_DAYS,
    LGS_TIMEFRAME_WEEKS,
    LGS_TIMEFRAME_GUILD_WEEKS,
  }
end

function LGSTime:SetCustomTimeframe(customTimeframeType, customTimeframe, customFilterDateRange)
  --[[ internal:dm("Debug", string.format("SetCustomTimeframe Args: customTimeframeType=%s, customTimeframe=%s, customFilterDateRange=%s",
    tostring(customTimeframeType),
    tostring(customTimeframe),
    tostring(customFilterDateRange)
  ))
  ]]--
  self.customTimeframeType = customTimeframeType or LGS_TIMEFRAME_DAYS
  self.customTimeframe = customTimeframe or 90
  self.customFilterDateRange = customFilterDateRange or 90
  self.customTimeframeText = tostring(self.customTimeframe) .. ' ' .. (customTimeframeTypeText[self.customTimeframeType] or GetString(GS_CUSTOM_TIMEFRAME_DAYS))
  --[[
  internal:dm("Debug", string.format("SetCustomTimeframe: customTimeframeType=%s, customTimeframe=%s, customFilterDateRange=%s, customTimeframeText=%s",
    tostring(self.customTimeframeType),
    tostring(self.customTimeframe),
    tostring(self.customFilterDateRange),
    tostring(self.customTimeframeText)
  ))
  ]]--
end

function LGSTime:SetOldestTime(timestamp)
  if timestamp == nil then return end

  if self.oldestTime == nil or timestamp < self.oldestTime then
    self.oldestTime = timestamp
  end
end

function LGSTime:SetNewestTime(timestamp)
  if timestamp == nil then return end

  if self.newestTime == nil or timestamp > self.newestTime then
    self.newestTime = timestamp
  end
end

function LGSTime:GetOldestTime()
  return self.oldestTime
end

function LGSTime:GetNewestTime()
  return self.newestTime
end

function LGSTime:GetDateRange(dateRange)
  return self.dateRanges[dateRange]
end

function LGSTime:IsInDateRange(dateRange, timestamp)
  if timestamp == nil or type(timestamp) ~= 'number' then return false end

  local range = self:GetDateRange(dateRange)
  if range == nil then return false end
  if range.startTimestamp == nil or range.endTimestamp == nil then return false end

  return timestamp >= range.startTimestamp and timestamp < range.endTimestamp
end

local function GetOldestDateRangeBoundary(timeData)
  local dateRangeBoundaries = {}

  dateRangeBoundaries[1] = timeData.oneStart
  dateRangeBoundaries[2] = timeData.oneEnd
  dateRangeBoundaries[3] = timeData.twoStart
  dateRangeBoundaries[4] = timeData.twoEnd
  dateRangeBoundaries[5] = timeData.threeStart
  dateRangeBoundaries[6] = timeData.threeEnd
  dateRangeBoundaries[7] = timeData.fourStart
  dateRangeBoundaries[8] = timeData.fourEnd
  dateRangeBoundaries[9] = timeData.fiveStart
  dateRangeBoundaries[10] = timeData.fiveEnd
  dateRangeBoundaries[11] = timeData.sixStart
  dateRangeBoundaries[12] = timeData.sixEnd
  dateRangeBoundaries[13] = timeData.sevenStart
  dateRangeBoundaries[14] = timeData.sevenEnd
  dateRangeBoundaries[15] = timeData.eightStart
  dateRangeBoundaries[16] = timeData.eightEnd
  dateRangeBoundaries[17] = timeData.nineStart
  dateRangeBoundaries[18] = timeData.nineEnd

  local oldestTimestamp = nil

  for i = 1, #dateRangeBoundaries do
    local timestamp = dateRangeBoundaries[i]
    -- internal:dm("Debug", timestamp)
    if timestamp ~= nil and (oldestTimestamp == nil or timestamp < oldestTimestamp) then
      oldestTimestamp = timestamp
    end
  end

  -- internal:dm("Debug", oldestTimestamp)
  return oldestTimestamp
end

function LGSTime:BuildDateRangeTable()
  self.nineStart = nil
  self.nineEnd = nil

  -- LGS_DATERANGE_TODAY = 1
  self.oneStart = self.midnight_today
  self.oneEnd = self.midnight_today + ZO_ONE_DAY_IN_SECONDS

  -- LGS_DATERANGE_YESTERDAY = 2
  self.twoStart = self.midnight_today - ZO_ONE_DAY_IN_SECONDS
  self.twoEnd = self.midnight_today

  -- LGS_DATERANGE_THISWEEK = 3
  self.threeStart = self.week_start
  self.threeEnd = self.kiosk_cycle

  -- LGS_DATERANGE_LASTWEEK = 4
  self.fourStart = self.threeStart - (7 * ZO_ONE_DAY_IN_SECONDS)
  self.fourEnd = self.threeStart

  -- LGS_DATERANGE_PRIORWEEK = 5
  self.fiveStart = self.fourStart - (7 * ZO_ONE_DAY_IN_SECONDS)
  self.fiveEnd = self.fourStart

  -- LGS_DATERANGE_7DAY = 6
  self.sixStart = self.midnight_today - (7 * ZO_ONE_DAY_IN_SECONDS)
  self.sixEnd = self.midnight_today + ZO_ONE_DAY_IN_SECONDS

  -- LGS_DATERANGE_10DAY = 7
  self.sevenStart = self.midnight_today - (10 * ZO_ONE_DAY_IN_SECONDS)
  self.sevenEnd = self.midnight_today + ZO_ONE_DAY_IN_SECONDS

  -- LGS_DATERANGE_30DAY = 8
  self.eightStart = self.midnight_today - (30 * ZO_ONE_DAY_IN_SECONDS)
  self.eightEnd = self.midnight_today + ZO_ONE_DAY_IN_SECONDS

  -- LGS_DATERANGE_CUSTOM = 9
  if self.customTimeframeType == LGS_TIMEFRAME_HOURS then
    self.nineStart = self.midnight_today - (self.customTimeframe * ZO_ONE_HOUR_IN_SECONDS)
    self.nineEnd = self.midnight_today + (7 * ZO_ONE_DAY_IN_SECONDS)
  end

  if self.customTimeframeType == LGS_TIMEFRAME_DAYS then
    self.nineStart = self.midnight_today - (self.customTimeframe * ZO_ONE_DAY_IN_SECONDS)
    self.nineEnd = self.midnight_today + (7 * ZO_ONE_DAY_IN_SECONDS)
  end

  if self.customTimeframeType == LGS_TIMEFRAME_WEEKS then
    self.nineStart = self.midnight_today - ((self.customTimeframe * ZO_ONE_DAY_IN_SECONDS) * 7)
    self.nineEnd = self.midnight_today + (7 * ZO_ONE_DAY_IN_SECONDS)
  end

  if self.customTimeframeType == LGS_TIMEFRAME_GUILD_WEEKS then
    self.nineStart = self.kiosk_cycle - ((self.customTimeframe * ZO_ONE_DAY_IN_SECONDS) * 7)
    self.nineEnd = self.kiosk_cycle
  end

  if self.nineStart == nil then
    self.customTimeframeType = LGS_TIMEFRAME_DAYS
    self.customTimeframe = 3
    self.nineStart = self.midnight_today - (self.customTimeframe * ZO_ONE_DAY_IN_SECONDS)
    self.nineEnd = self.midnight_today + (7 * ZO_ONE_DAY_IN_SECONDS)
  end

  self.dateRanges = {}

  self.dateRanges[LGS_DATERANGE_TODAY] = { startTimestamp = self.oneStart, endTimestamp = self.oneEnd }
  self.dateRanges[LGS_DATERANGE_YESTERDAY] = { startTimestamp = self.twoStart, endTimestamp = self.twoEnd }
  self.dateRanges[LGS_DATERANGE_THISWEEK] = { startTimestamp = self.threeStart, endTimestamp = self.threeEnd }
  self.dateRanges[LGS_DATERANGE_LASTWEEK] = { startTimestamp = self.fourStart, endTimestamp = self.fourEnd }
  self.dateRanges[LGS_DATERANGE_PRIORWEEK] = { startTimestamp = self.fiveStart, endTimestamp = self.fiveEnd }
  self.dateRanges[LGS_DATERANGE_7DAY] = { startTimestamp = self.sixStart, endTimestamp = self.sixEnd }
  self.dateRanges[LGS_DATERANGE_10DAY] = { startTimestamp = self.sevenStart, endTimestamp = self.sevenEnd }
  self.dateRanges[LGS_DATERANGE_30DAY] = { startTimestamp = self.eightStart, endTimestamp = self.eightEnd }
  self.dateRanges[LGS_DATERANGE_CUSTOM] = { startTimestamp = self.nineStart, endTimestamp = self.nineEnd }

  self.oldestTimestamp = GetOldestDateRangeBoundary(self)
end

function LGSTime:BuildFilterDateRangeTable()
  self.filterDateRanges = {}

  local daysRange = self.customFilterDateRange
  local customDayRangeStart = self.midnight_today - (daysRange * ZO_ONE_DAY_IN_SECONDS)
  local customDayRangeEnd = self.midnight_today + (7 * ZO_ONE_DAY_IN_SECONDS)

  local customThirtyDayRangeStart = self.midnight_today - (30 * ZO_ONE_DAY_IN_SECONDS)
  local customThirtyDayRangeEnd = self.midnight_today + (7 * ZO_ONE_DAY_IN_SECONDS)

  local customSixtyDayRangeStart = customThirtyDayRangeStart - (30 * ZO_ONE_DAY_IN_SECONDS)
  local customSixtyDayRangeEnd = customThirtyDayRangeStart

  local customNinetyDayRangeStart = customSixtyDayRangeStart - (30 * ZO_ONE_DAY_IN_SECONDS)
  local customNinetyDayRangeEnd = customSixtyDayRangeStart

  self.filterDateRanges[LGS_WINDOW_TIME_RANGE_THIRTY] = {startTimestamp = customThirtyDayRangeStart, endTimestamp = customThirtyDayRangeEnd,}
  self.filterDateRanges[LGS_WINDOW_TIME_RANGE_SIXTY] = {startTimestamp = customSixtyDayRangeStart, endTimestamp = customSixtyDayRangeEnd,}
  self.filterDateRanges[LGS_WINDOW_TIME_RANGE_NINETY] = {startTimestamp = customNinetyDayRangeStart, endTimestamp = customNinetyDayRangeEnd,}
  self.filterDateRanges[LGS_WINDOW_TIME_RANGE_CUSTOM] = {startTimestamp = customDayRangeStart,endTimestamp = customDayRangeEnd,}
end
