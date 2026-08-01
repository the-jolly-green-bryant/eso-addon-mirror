-------------------------------------------------------------------------------
-- Advanced Member Tooltip v2.00
-------------------------------------------------------------------------------
-- Author: Arkadius
-- This Add-on is not created by, affiliated with or sponsored by ZeniMax Media
-- Inc. or its affiliates. The Elder Scrolls® and related logos are registered
-- trademarks or trademarks of ZeniMax Media Inc. in the United States and/or
-- other countries.
--
-- You can read the full terms at:
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------

local LGH = LibHistoire
local LAM = LibAddonMenu2
local ASYNC = LibAsync
local AddonName = "AdvancedMemberTooltip"

AMT = {}

-------------------------------------------------
----- early helper                          -----
-------------------------------------------------

local function is_empty_or_nil(t)
  if t == nil or t == "" then return true end
  return type(t) == "table" and ZO_IsTableEmpty(t) or false
end

local function is_in(search_value, search_table)
  if is_empty_or_nil(search_value) then return false end
  for k, v in pairs(search_table) do
    if search_value == v then return true end
    if type(search_value) == "string" then
      if string.find(string.lower(v), string.lower(search_value)) then return true end
    end
  end
  return false
end

-------------------------------------------------
----- lang setup                            -----
-------------------------------------------------

AMT.client_lang = GetCVar("Language.2")
AMT.effective_lang = nil
AMT.supported_lang = { "de", "en", "fr", }
if is_in(AMT.client_lang, AMT.supported_lang) then
  AMT.effective_lang = AMT.client_lang
else
  AMT.effective_lang = "en"
end
AMT.supported_lang = AMT.client_lang == AMT.effective_lang

-------------------------------------------------
----- mod                                   -----
-------------------------------------------------

AMT.despawnTimestamp, AMT.kioskCycle = GetGuildKioskCycleTimes()
AMT.LibHistoireGeneralListener = {}
AMT.LibHistoireBankListener = {}
AMT.guildDonationsColumn = {}
AMT.rosterDirty = false
AMT.selectedGuildBankId = nil
AMT.selectedGuildBankName = nil
AMT.slashCommandFullRefresh = false
AMT.worldName = GetWorldName()

local weekCutoff = 0
local todayStart = 0
local yesterdayStart = 0
local yesterdayEnd = 0
local thisweekStart = 0
local thisweekEnd = 0
local lastweekStart = 0
local lastweekEnd = 0
local priorweekStart = 0
local priorweekEnd = 0
local lastSevenDaysStart = 0
local lastTenDaysStart = 0
local lastThirtyDaysStart = 0

AMT.useSunday = false
AMT.addToCutoff = 0
AMT.libHistoireScanByTimestamp = false
AMT.isLeapYear = nil

local AMT_DATERANGE_TODAY = 1
local AMT_DATERANGE_YESTERDAY = 2
local AMT_DATERANGE_THISWEEK = 3
local AMT_DATERANGE_LASTWEEK = 4
local AMT_DATERANGE_PRIORWEEK = 5
local AMT_DATERANGE_7DAY = 6
local AMT_DATERANGE_10DAY = 7
local AMT_DATERANGE_30DAY = 8

AMT.savedData = {}
local defaultData = {
  addToCutoff = 0,
  exportEpochTime = false,
  dateTimeFormat = 1,
  ["NA Megaserver"] = {
    CurrentKioskTime = 0,
    addRosterColumn = true,
    useSunday = false,
    lastReceivedRosterEventID = {},
    lastBankedCurrencyEventID = {},
    EventsProcessed = {},
    newestRosterTimestamp = {},
    newestBankedCurrencyTimestamp = {},
  },
  ["EU Megaserver"] = {
    CurrentKioskTime = 0,
    addRosterColumn = true,
    useSunday = false,
    lastReceivedRosterEventID = {},
    lastBankedCurrencyEventID = {},
    EventsProcessed = {},
    newestRosterTimestamp = {},
    newestBankedCurrencyTimestamp = {},
  },
}
local exampleGuildId = nil
if GetNumGuilds() >= 1 then
  exampleGuildId = GetGuildId(1)
end
AMT.exampleGuildFoundedDate = "1/1/2000"
if exampleGuildId then AMT.exampleGuildFoundedDate = GetGuildFoundedDate(exampleGuildId) end
AMT.dateFormats = { "mm.dd.yy", "dd.mm.yy", "yy.dd.mm", "yy.mm.dd", }
AMT.dateFormatValues = { 1, 2, 3, 4 }

local amtDefaults = {
  useSunday = false,
  addToCutoff = 0,
  addRosterColumn = true,
  exportEpochTime = false,
  dateTimeFormat = 1,
}

AMT.show_log = true
if LibDebugLogger then
  AMT.logger = LibDebugLogger.Create(AddonName)
end
local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not AMT.show_log then return end
  if logger and log_type == "Debug" then
    AMT.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    AMT.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    AMT.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    AMT.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  if not t then
    emit_message(log_type, indent .. "[Nil Table]")
    return
  end

  if next(t) == nil then
    emit_message(log_type, indent .. "[Empty Table]")
    return
  end

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function AMT:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end

-- Hooked functions
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter = ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter
local org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit = ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit

function AMT:IsLibHistoireListenerSetup(guildId)
  local generalListener = AMT.LibHistoireGeneralListener[guildId]
  local bankListener = AMT.LibHistoireBankListener[guildId]
  if generalListener ~= nil and bankListener ~= nil then
    if next(generalListener) ~= nil and next(bankListener) ~= nil then
      return true
    end
  end
  return false
end

function AMT:AreLibHistoireListenersRunning(guildId)
  local generalListener = AMT.LibHistoireGeneralListener[guildId]
  local bankListener = AMT.LibHistoireBankListener[guildId]
  if AMT:IsLibHistoireListenerSetup(guildId) then
    return generalListener:IsRunning() and bankListener:IsRunning()
  end
  return false
end

local function secToTime(timeframe)
  local outputString = ""
  local nextTimeframe = 0
  local years = math.floor(math.modf(timeframe / 31540000))
  nextTimeframe = timeframe - (years * 31540000)
  local days = math.floor(math.modf(nextTimeframe / 86400))
  nextTimeframe = timeframe - (years * 31540000) - (days * 86400)
  local hours = math.floor(math.modf(nextTimeframe / 3600))
  nextTimeframe = timeframe - (years * 31540000) - (days * 86400) - (hours * 3600)
  local minutes = math.floor(math.modf(nextTimeframe / 60))
  nextTimeframe = timeframe - (years * 31540000) - (days * 86400) - (hours * 3600) - (minutes * 60)
  local seconds = nextTimeframe

  local hasYears = years > 0
  local hasDays = days > 0
  local hasHours = hours > 0
  local hasMinutes = minutes > 0
  local hasSeconds = seconds > 0

  -- Determine whether to display minutes or seconds
  local displayMinutes = not (hasYears or hasDays or hasHours) or not (hasYears or hasDays) and hasMinutes
  local displaySeconds = not (hasYears or hasDays or hasHours)

  if hasYears then
    outputString = outputString .. string.format(GetString(AMT_DATE_FORMAT_YEARS), years)
  end
  if hasDays then
    outputString = outputString .. string.format(GetString(AMT_DATE_FORMAT_DAYS), days)
  end
  if hasHours then
    outputString = outputString .. string.format(GetString(AMT_DATE_FORMAT_HOURS), hours)
  end
  if displayMinutes and hasMinutes then
    outputString = outputString .. string.format(GetString(AMT_DATE_FORMAT_MINUTES), minutes)
  end
  if displaySeconds and hasSeconds then
    outputString = outputString .. string.format(GetString(AMT_DATE_FORMAT_SECONDS), seconds)
  end
  if outputString == "" then
    outputString = GetString(AMT_DATE_FORMAT_NONE)
  end
  return outputString
end

function AMT:DetermineSecondsSinceLogoff(secsSinceLogoff, foundedDate)
  local somethingDone = false
  local resultNum = secsSinceLogoff
  if secsSinceLogoff > foundedDate then
    --AMT:dm("Debug", "secsSinceLogoff > foundedDate")
    --AMT:dm("Debug", secsSinceLogoff)
    --AMT:dm("Debug", foundedDate)
    resultNum = GetTimeStamp() - secsSinceLogoff
    somethingDone = true
  end
  --[[ if the sec is more then 1577836800 or Wednesday, January 1, 2020
  then it might be a time stamp but not 624 months or 12 years ago
  ]]--
  if secsSinceLogoff > 1577836800 then
    --AMT:dm("Debug", "secsSinceLogoff > 31540000")
    --AMT:dm("Debug", secsSinceLogoff)
    --AMT:dm("Debug", foundedDate)
    resultNum = GetTimeStamp() - secsSinceLogoff
    somethingDone = true
  end
  if not somethingDone then
    --AMT:dm("Debug", "Maybe it is correct")
    --AMT:dm("Debug", secsSinceLogoff)
    --AMT:dm("Debug", foundedDate)
  end
  return resultNum
end

local function TrimTagString(str)
  local stringTrimmed = string.gsub(str, '{t:', '')
  stringTrimmed = string.gsub(stringTrimmed, '}', '')
  return stringTrimmed
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)
  org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter(control)

  local parent = control:GetParent()
  local data = ZO_ScrollList_GetData(parent)
  local applicationPending = data.rankId == DEFAULT_INVITED_RANK
  local guildMemberIndex = data.index
  local displayName = string.lower(data.displayName)
  local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
  local guildName = GUILD_ROSTER_MANAGER:GetGuildName()
  local foundedDate = AMT:GetGuildFoundedDate(guildId)
  local oldestGeneralGuildEvent = AMT.savedData[guildName]["oldestEvents"][GUILD_HISTORY_GENERAL]
  local hasGeneralGuildEvents = oldestGeneralGuildEvent > 0
  local timestamp = GetTimeStamp()
  --[[ Old Bug: if the sec is more then 1577836800 or Wednesday, January 1, 2020
  then it might be a time stamp but not 624 months or 12 years ago
  ]]--
  local name, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
  local online = (playerStatus ~= PLAYER_STATUS_OFFLINE)

  local tooltip
  if applicationPending then tooltip = data.displayName
  else tooltip = data.characterName end
  local str
  local oldestDeposit, mostRecentDeposit, oldestTimeframe, mostRecentTimeframe

  local guildData = AMT.savedData[guildName]
  if guildData then
    local memberData = guildData[displayName]
    if memberData and not applicationPending then
      tooltip = tooltip .. "\n\n"

      -- Member For
      if memberData.timeJoined == 0 then
        if hasGeneralGuildEvents then
          str = secToTime(timestamp - oldestGeneralGuildEvent)
        else
          str = secToTime(timestamp - foundedDate)
        end
        tooltip = tooltip .. zo_strformat(GetString(AMT_MEMBER), "> ", str) .. "\n"
      else
        str = secToTime(timestamp - memberData.timeJoined)
        tooltip = tooltip .. zo_strformat(GetString(AMT_MEMBER), "", str) .. "\n"
      end

      -- Online Offline Status
      if data.hasCharacter and online then
        tooltip = tooltip .. GetString(AMT_PLAYER_ONLINE) .. "\n\n"
      else
        str = secToTime(secsSinceLogoff)
        tooltip = tooltip .. zo_strformat(GetString(AMT_SINCE_LOGOFF), "", str) .. "\n\n"
      end

      -- All Deposit info
      tooltip = tooltip .. GetString(AMT_DEPOSITS) .. ':' .. "\n"
      local bankDepositType = GUILD_EVENT_BANKGOLD_ADDED

      local totaltDepositStr, lastDepositStr
      -- Total Deposits, timeFirst
      if (memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeFirst == 0) then
        totaltDepositStr = GetString(AMT_NO_DEPOSITS)
      else
        oldestDeposit = memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeFirst
        oldestTimeframe = timestamp - oldestDeposit
        totaltDepositStr = secToTime(oldestTimeframe)
      end

      -- Last Deposits, timeLast
      if (memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeLast == 0) then
        lastDepositStr = GetString(AMT_NO_DEPOSITS)
      else
        oldestDeposit = memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeLast
        oldestTimeframe = timestamp - oldestDeposit
        lastDepositStr = secToTime(oldestTimeframe)
      end
      local totalDepositValue = ZO_LocalizeDecimalNumber(memberData[bankDepositType][AMT_DATERANGE_THISWEEK].total)
      local lastDepositValue = ZO_LocalizeDecimalNumber(memberData[bankDepositType][AMT_DATERANGE_THISWEEK].last)
      tooltip = tooltip .. string.format(GetString(AMT_TOTAL), totalDepositValue, totaltDepositStr) .. "\n"
      tooltip = tooltip .. string.format(GetString(AMT_LAST), lastDepositValue, lastDepositStr) .. "\n\n"

      -- All Withdrawal info
      tooltip = tooltip .. GetString(AMT_WITHDRAWALS) .. ':' .. "\n"
      bankDepositType = GUILD_EVENT_BANKGOLD_REMOVED

      local totalWithdrawalStr, lastWithdrawalStr
      -- Total Withdrawals, timeFirst
      if (memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeFirst == 0) then
        totalWithdrawalStr = GetString(AMT_NO_WITHDRAWALS)
      else
        mostRecentDeposit = memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeFirst
        mostRecentTimeframe = timestamp - mostRecentDeposit
        totalWithdrawalStr = secToTime(mostRecentTimeframe)
      end

      -- Last Withdrawals, timeLast
      if (memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeLast == 0) then
        lastWithdrawalStr = GetString(AMT_NO_WITHDRAWALS)
      else
        mostRecentDeposit = memberData[bankDepositType][AMT_DATERANGE_THISWEEK].timeLast
        mostRecentTimeframe = timestamp - mostRecentDeposit
        lastWithdrawalStr = secToTime(mostRecentTimeframe)
      end
      local totalWithdrawalValue = ZO_LocalizeDecimalNumber(memberData[bankDepositType][AMT_DATERANGE_THISWEEK].total)
      local lastWithdrawalValue = ZO_LocalizeDecimalNumber(memberData[bankDepositType][AMT_DATERANGE_THISWEEK].last)
      tooltip = tooltip .. string.format(GetString(AMT_TOTAL), totalWithdrawalValue, totalWithdrawalStr) .. "\n"
      tooltip = tooltip .. string.format(GetString(AMT_LAST), lastWithdrawalValue, lastWithdrawalStr)

    end
  end

  InitializeTooltip(InformationTooltip, control, BOTTOM, 0, 0, TOPCENTER)
  SetTooltipText(InformationTooltip, tooltip)
end

function ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
  ClearTooltip(InformationTooltip)

  org_ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit(control)
end

function AMT.createGuild(guildName)
  AMT.savedData[guildName] = AMT.savedData[guildName] or {}
  AMT.savedData[guildName]["oldestEvents"] = AMT.savedData[guildName]["oldestEvents"] or {}
  AMT.savedData[guildName]["oldestEvents"][GUILD_HISTORY_GENERAL] = AMT.savedData[guildName]["oldestEvents"][GUILD_HISTORY_GENERAL] or 0
  AMT.savedData[guildName]["oldestEvents"][GUILD_HISTORY_BANK] = AMT.savedData[guildName]["oldestEvents"][GUILD_HISTORY_BANK] or 0
  AMT.savedData[guildName]["lastScans"] = AMT.savedData[guildName]["lastScans"] or {}
  AMT.savedData[guildName]["lastScans"][GUILD_HISTORY_GENERAL] = AMT.savedData[guildName]["lastScans"][GUILD_HISTORY_GENERAL] or 0
  AMT.savedData[guildName]["lastScans"][GUILD_HISTORY_BANK] = AMT.savedData[guildName]["lastScans"][GUILD_HISTORY_BANK] or 0
end

function AMT:createUser(guildName, displayName)
  local eventGoldAdded = GUILD_EVENT_BANKGOLD_ADDED
  local eventGoldRemoved = GUILD_EVENT_BANKGOLD_REMOVED
  local name = string.lower(displayName)
  AMT.savedData[guildName] = AMT.savedData[guildName] or {}
  AMT.savedData[guildName][name] = AMT.savedData[guildName][name] or {}
  AMT.savedData[guildName][name][eventGoldAdded] = AMT.savedData[guildName][name][eventGoldAdded] or {}
  AMT.savedData[guildName][name][eventGoldRemoved] = AMT.savedData[guildName][name][eventGoldRemoved] or {}

  --clear old values
  AMT.savedData[guildName][name][eventGoldAdded].timeFirst = nil
  AMT.savedData[guildName][name][eventGoldAdded].timeLast = nil
  AMT.savedData[guildName][name][eventGoldAdded].last = nil
  AMT.savedData[guildName][name][eventGoldAdded].total = nil
  AMT.savedData[guildName][name][eventGoldRemoved].timeFirst = nil
  AMT.savedData[guildName][name][eventGoldRemoved].timeLast = nil
  AMT.savedData[guildName][name][eventGoldRemoved].last = nil
  AMT.savedData[guildName][name][eventGoldRemoved].total = nil


  -- setup event user info
  AMT.savedData[guildName][name].timeJoined = AMT.savedData[guildName][name].timeJoined or 0
  --[[ there was a weird error on EU for the following line
        str = secToTime(timestamp - memberData.timeJoined)
        I must not have put a 0 at some point for the user data and it was set
        to an empty table.
  ]]--
  if type(AMT.savedData[guildName][name].timeJoined) ~= 'number' then AMT.savedData[guildName][name].timeJoined = 0 end

  for week = AMT_DATERANGE_TODAY, AMT_DATERANGE_30DAY do
    AMT.savedData[guildName][name][eventGoldAdded][week] = AMT.savedData[guildName][name][eventGoldAdded][week] or {}
    AMT.savedData[guildName][name][eventGoldRemoved][week] = AMT.savedData[guildName][name][eventGoldRemoved][week] or {}

    AMT.savedData[guildName][name][eventGoldAdded][week].timeFirst = AMT.savedData[guildName][name][eventGoldAdded][week].timeFirst or 0
    AMT.savedData[guildName][name][eventGoldAdded][week].timeLast = AMT.savedData[guildName][name][eventGoldAdded][week].timeLast or 0
    AMT.savedData[guildName][name][eventGoldAdded][week].last = AMT.savedData[guildName][name][eventGoldAdded][week].last or 0
    AMT.savedData[guildName][name][eventGoldAdded][week].total = AMT.savedData[guildName][name][eventGoldAdded][week].total or 0

    AMT.savedData[guildName][name][eventGoldRemoved][week].timeFirst = AMT.savedData[guildName][name][eventGoldRemoved][week].timeFirst or 0
    AMT.savedData[guildName][name][eventGoldRemoved][week].timeLast = AMT.savedData[guildName][name][eventGoldRemoved][week].timeLast or 0
    AMT.savedData[guildName][name][eventGoldRemoved][week].last = AMT.savedData[guildName][name][eventGoldRemoved][week].last or 0
    AMT.savedData[guildName][name][eventGoldRemoved][week].total = AMT.savedData[guildName][name][eventGoldRemoved][week].total or 0
  end
end

function AMT.resetUser(guildName, displayName)
  local eventGoldAdded = GUILD_EVENT_BANKGOLD_ADDED
  local eventGoldRemoved = GUILD_EVENT_BANKGOLD_REMOVED
  local name = string.lower(displayName)
  AMT.savedData[guildName] = AMT.savedData[guildName] or {}
  if (AMT.savedData[guildName][name] == nil) then
    AMT:createUser(guildName, name)
    return
  end
  AMT.savedData[guildName][name][eventGoldAdded] = AMT.savedData[guildName][name][eventGoldAdded] or {}
  AMT.savedData[guildName][name][eventGoldRemoved] = AMT.savedData[guildName][name][eventGoldRemoved] or {}

  for week = AMT_DATERANGE_TODAY, AMT_DATERANGE_30DAY do
    AMT.savedData[guildName][name][eventGoldAdded][week] = AMT.savedData[guildName][name][eventGoldAdded][week] or {}
    AMT.savedData[guildName][name][eventGoldRemoved][week] = AMT.savedData[guildName][name][eventGoldRemoved][week] or {}

    AMT.savedData[guildName][name][eventGoldAdded][week].timeFirst = 0
    AMT.savedData[guildName][name][eventGoldAdded][week].timeLast = 0
    AMT.savedData[guildName][name][eventGoldAdded][week].last = 0
    AMT.savedData[guildName][name][eventGoldAdded][week].total = 0

    AMT.savedData[guildName][name][eventGoldRemoved][week].timeFirst = 0
    AMT.savedData[guildName][name][eventGoldRemoved][week].timeLast = 0
    AMT.savedData[guildName][name][eventGoldRemoved][week].last = 0
    AMT.savedData[guildName][name][eventGoldRemoved][week].total = 0
  end
end

local function ConvertEventIdLibHistoireId(eventId)
  local idString = tostring(eventId)
  assert(#idString < 10, "eventId is too large to convert")
  while #idString < 9 do
    idString = "0" .. idString
  end
  return "3" .. idString
end

local function AddAtIfNeeded(str)
  if string.sub(str, 1, 1) ~= "@" then
    str = "@" .. str
  end
  return str
end

function AMT.ProcessListenerEvent(guildId, category, theEvent)
  --[[if the event does not exist then set it to true and continue,
  otherwise don't record the same event

  This array is reset on Kiosk Flip]]--
  if AMT.savedData[GetWorldName()]["EventsProcessed"][theEvent.eventId] == nil then
    AMT.savedData[GetWorldName()]["EventsProcessed"][theEvent.eventId] = true
  else
    return
  end

  local function addDonation(guildName, displayName, eventType, weekTimeframe, timestamp, goldAmount)
    if (eventType == GUILD_EVENT_BANKGOLD_ADDED) or (eventType == GUILD_EVENT_BANKGOLD_REMOVED) then
      AMT.savedData[guildName][displayName][eventType][weekTimeframe].total = AMT.savedData[guildName][displayName][eventType][weekTimeframe].total + goldAmount
      AMT.savedData[guildName][displayName][eventType][weekTimeframe].last = goldAmount
      AMT.savedData[guildName][displayName][eventType][weekTimeframe].timeLast = timestamp

      if (AMT.savedData[guildName][displayName][eventType][weekTimeframe].timeFirst == 0) then
        AMT.savedData[guildName][displayName][eventType][weekTimeframe].timeFirst = timestamp
      end
      AMT.savedData[guildName]["lastScans"][category] = timestamp
      AMT.rosterDirty = true
    end
  end

  local function updateJoinDate(guildName, displayName, eventType, timestamp)
    if eventType == GUILD_EVENT_GUILD_JOIN then
      if not (AMT.savedData[guildName] and AMT.savedData[guildName][displayName]) then return end
      if (AMT.savedData[guildName][displayName].timeJoined ~= timestamp) then
        AMT.savedData[guildName][displayName].timeJoined = timestamp
      end
    end
  end

  -- seemed to be correct but later gives odd result
  -- local timestamp = GetTimeStamp() - theEvent.evTime
  local guildName = GetGuildName(guildId)
  local displayName = string.lower(theEvent.evName)
  local eventType = theEvent.evType
  local goldAmount = theEvent.evGold
  local timestamp = theEvent.evTime

  if AMT.savedData[guildName]["oldestEvents"][category] == 0 or AMT.savedData[guildName]["oldestEvents"][category] > timestamp then AMT.savedData[guildName]["oldestEvents"][category] = timestamp end

  if (category == GUILD_HISTORY_GENERAL) then
    updateJoinDate(guildName, displayName, eventType, timestamp)
  end

  if (category == GUILD_HISTORY_BANK) then
    -- AMT:dm("Debug", string.format("%s, %s, %s, %s, %s, %s", guildName, displayName, eventType, "weekTimeframe", timestamp, goldAmount))
    if (timestamp >= todayStart) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_TODAY, timestamp, goldAmount) end
    if (timestamp >= yesterdayStart and timestamp < yesterdayEnd) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_YESTERDAY, timestamp, goldAmount) end
    if (timestamp >= thisweekStart and timestamp < thisweekEnd) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_THISWEEK, timestamp, goldAmount) end
    if (timestamp >= lastweekStart and timestamp < lastweekEnd) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_LASTWEEK, timestamp, goldAmount) end
    if (timestamp >= priorweekStart and timestamp < priorweekEnd) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_PRIORWEEK, timestamp, goldAmount) end
    if (timestamp >= lastSevenDaysStart) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_7DAY, timestamp, goldAmount) end
    if (timestamp >= lastTenDaysStart) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_10DAY, timestamp, goldAmount) end
    if (timestamp >= lastThirtyDaysStart) then addDonation(guildName, displayName, eventType, AMT_DATERANGE_30DAY, timestamp, goldAmount) end
  end
end

function AMT:SetupListener(guildId)
  AMT:dm("Debug", "SetupListener: " .. guildId .. " : " .. GetGuildName(guildId))
  AMT.LibHistoireGeneralListener[guildId] = LGH:CreateGuildHistoryListener(guildId, GUILD_HISTORY_GENERAL)
  AMT.LibHistoireBankListener[guildId] = LGH:CreateGuildHistoryListener(guildId, GUILD_HISTORY_BANK)

  local newestReceivedGeneralEventID = AMT.savedData[GetWorldName()]["lastReceivedRosterEventID"][guildId] or "0"
  local newestReceivedBankEventID = AMT.savedData[GetWorldName()]["lastBankedCurrencyEventID"][guildId] or "0"

  if newestReceivedGeneralEventID then
    local lastReceivedRosterEventID = StringToId64(AMT.savedData[GetWorldName()]["lastReceivedRosterEventID"][guildId]) or "0"
    --AMT:dm("Info", string.format("lastReceivedRosterEventID set to: %s", lastReceivedRosterEventID))
    AMT.LibHistoireGeneralListener[guildId]:SetAfterEventId(lastReceivedRosterEventID)
  end

  if AMT.libHistoireScanByTimestamp then
    local setAfterTimestamp = AMT.kioskCycle - (ZO_ONE_DAY_IN_SECONDS * 14) -- this week and last week
    AMT.LibHistoireBankListener[guildId]:SetAfterEventTime(setAfterTimestamp)
  elseif newestReceivedBankEventID then
    local lastBankedCurrencyEventID = StringToId64(AMT.savedData[GetWorldName()]["lastBankedCurrencyEventID"][guildId]) or "0"
    --AMT:dm("Info", string.format("lastBankedCurrencyEventID set to: %s", lastBankedCurrencyEventID))
    AMT.LibHistoireBankListener[guildId]:SetAfterEventId(lastBankedCurrencyEventID)
  end

  -- Begin Listener General
  AMT.LibHistoireGeneralListener[guildId]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)
    if eventType == GUILD_EVENT_GUILD_JOIN then
      local convertedId = Id64ToString(eventId)
      local theEvent = {
        evType = eventType,
        evTime = eventTime,
        evName = p1, -- Username that joined the guild
        evGold = nil, -- because it is when user joined
        eventId = convertedId, -- eventId but new
      }

      local oneEventRange = GetNumGuildHistoryEventRanges(guildId, GUILD_HISTORY_EVENT_CATEGORY_ROSTER) == 1
      local timeStampInRange = not AMT.savedData[GetWorldName()]["newestRosterTimestamp"][guildId] or theEvent.evTime > AMT.savedData[GetWorldName()]["newestRosterTimestamp"][guildId]
      if oneEventRange and timeStampInRange then
        AMT.savedData[GetWorldName()]["lastReceivedRosterEventID"][guildId] = convertedId
      end

      local guildName = GetGuildName(guildId)
      local displayName = string.lower(theEvent.evName)
      if not AMT.savedData[guildName][displayName] then AMT:createUser(guildName, displayName) end
      AMT.ProcessListenerEvent(guildId, GUILD_HISTORY_GENERAL, theEvent)
    end
  end)

  -- Begin Listener Bank
  AMT.LibHistoireBankListener[guildId]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)
    if (eventType == GUILD_EVENT_BANKGOLD_ADDED or eventType == GUILD_EVENT_BANKGOLD_REMOVED) then
      local convertedId = Id64ToString(eventId)
      local theEvent = {
        evType = eventType,
        evTime = eventTime,
        evName = p1, -- Username that joined the guild
        evGold = p2, -- The ammount of gold
        eventId = convertedId, -- eventId but new
      }

      local oneEventRange = GetNumGuildHistoryEventRanges(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY) == 1
      local timeStampInRange = not AMT.savedData[GetWorldName()]["newestBankedCurrencyTimestamp"][guildId] or theEvent.evTime > AMT.savedData[GetWorldName()]["newestBankedCurrencyTimestamp"][guildId]
      if oneEventRange and timeStampInRange then
        AMT.savedData[GetWorldName()]["lastBankedCurrencyEventID"][guildId] = convertedId
      end

      AMT.ProcessListenerEvent(guildId, GUILD_HISTORY_BANK, theEvent)
    end
  end)

  -- Start Listeners
  AMT.LibHistoireGeneralListener[guildId]:Start()
  AMT.LibHistoireBankListener[guildId]:Start()
end

-- Setup LibHistoire listeners
function AMT:SetupListenerLibHistoire()
  --AMT:dm("Debug", "SetupListenerLibHistoire")
  for guildNum = 1, GetNumGuilds() do
    local guildId = GetGuildId(guildNum)
    AMT.LibHistoireGeneralListener[guildId] = {}
    AMT.LibHistoireBankListener[guildId] = {}
    AMT:SetupListener(guildId)
  end
end

function AMT:KioskFlipListenerSetup()
  local currentKioskTime = AMT.savedData[GetWorldName()]["CurrentKioskTime"]
  local forceRefresh = AMT.slashCommandFullRefresh
  local weeklyRefreshComplete = currentKioskTime == AMT.kioskCycle
  if weeklyRefreshComplete and not forceRefresh then
    AMT:dm("Debug", "Kiosk Reset Week Not Needed")
    return
  end
  AMT:dm("Debug", "Kiosk Reset Start in KioskFlipListenerSetup")
  AMT.libHistoireScanByTimestamp = true
  AMT.savedData[GetWorldName()]["CurrentKioskTime"] = AMT.kioskCycle
  AMT.savedData[GetWorldName()]["EventsProcessed"] = {}
  for guildNum = 1, GetNumGuilds() do
    local guildId = GetGuildId(guildNum)
    local guildName = GetGuildName(guildId)
    AMT.LibHistoireGeneralListener[guildId]:Stop()
    AMT.LibHistoireBankListener[guildId]:Stop()
    AMT.LibHistoireGeneralListener[guildId] = nil
    AMT.LibHistoireBankListener[guildId] = nil
    for member = 1, GetNumGuildMembers(guildId), 1 do
      AMT.resetUser(guildName, GetGuildMemberInfo(guildId, member))
    end
  end
  -- if slash command used reset this
  AMT.slashCommandFullRefresh = false

  for guildNum = 1, GetNumGuilds() do
    local guildId = GetGuildId(guildNum)
    AMT.savedData[GetWorldName()]["lastReceivedRosterEventID"][guildId] = "0"
    AMT.savedData[GetWorldName()]["lastBankedCurrencyEventID"][guildId] = "0"
    AMT:SetupListener(guildId)
  end
  AMT.libHistoireScanByTimestamp = false
  AMT:LibHistoireRefresh()
end

function AMT:DoRefresh()
  AMT:dm("Debug", "DoRefresh")
  AMT.libHistoireScanByTimestamp = false
  AMT:LibHistoireRefresh()
end

function AMT:LibHistoireRefresh()
  local numEventsRoster = {}
  local numEventsBankedCurrency = {}
  local hasEventsRoster = {}
  local hasEventsBankedCurrency = {}
  local eventRangesRoster = {}
  local eventRangesBankedCurrency = {}
  local eventsLinkedRoster = {}
  local eventsLinkedBankedCurrency = {}
  local numGuilds = GetNumGuilds()
  for guildNum = 1, numGuilds do
    local guildId = GetGuildId(guildNum)
    numEventsRoster[guildId] = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_ROSTER)
    numEventsBankedCurrency[guildId] = GetNumGuildHistoryEvents(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
    hasEventsRoster[guildId] = numEventsRoster[guildId] >= 1
    hasEventsBankedCurrency[guildId] = numEventsBankedCurrency[guildId] >= 1
    eventRangesRoster[guildId] = GetNumGuildHistoryEventRanges(guildId, GUILD_HISTORY_EVENT_CATEGORY_ROSTER)
    eventRangesBankedCurrency[guildId] = GetNumGuildHistoryEventRanges(guildId, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY)
    eventsLinkedRoster[guildId] = hasEventsRoster[guildId] and eventRangesRoster[guildId] == 1
    eventsLinkedBankedCurrency[guildId] = hasEventsBankedCurrency[guildId] and eventRangesBankedCurrency[guildId] == 1
  end
  local task = ASYNC:Create("LibHistoireRefresh")
  task:Call(function(task) AMT:dm("Info", GetString(AMT_LIBHISTOIRE_REFRESHING)) end)
  task:For(1, numGuilds):Do(function(guildNum)
    local guildId = GetGuildId(guildNum)
    if eventsLinkedRoster[guildId] then
      --AMT:dm("Debug", "Could Process Roster: " .. tostring(guildId) .. " : " .. GetGuildName(guildId))
      --AMT:dm("Debug", "Num Events Roster: " .. tostring(numEventsRoster[guildId]) .. " : " .. GetGuildName(guildId))
      local endIndex = numEventsRoster[guildId]
      task:For(1, endIndex):Do(function(eventIndex)
        local eventId, timestampS, isRedacted, eventType, actingDisplayName, targetDisplayName, rankId = GetGuildHistoryRosterEventInfo(guildId, eventIndex)
        if eventType == GUILD_HISTORY_ROSTER_EVENT_JOIN then
          local convertedId = ConvertEventIdLibHistoireId(eventId)
          actingDisplayName = AddAtIfNeeded(actingDisplayName)
          local theEvent = {
            -- backwards compatibility for now
            evType = GUILD_EVENT_GUILD_JOIN,
            evTime = timestampS,
            evName = actingDisplayName, -- Username that joined the guild
            evGold = nil, -- because it is when user joined
            eventId = convertedId, -- eventId but new
          }
          task:Call(function(task) AMT.ProcessListenerEvent(guildId, GUILD_HISTORY_GENERAL, theEvent) end)
        end
      end)
    end
    if eventsLinkedBankedCurrency[guildId] then
      --AMT:dm("Debug", "Could Process BankedCurrency: " .. tostring(guildId) .. " : " .. GetGuildName(guildId))
      --AMT:dm("Debug", "Num Events BankedCurrency: " .. tostring(hasEventsBankedCurrency[guildId]) .. " : " .. GetGuildName(guildId))
      local endIndex = numEventsBankedCurrency[guildId]
      task:For(1, endIndex):Do(function(eventIndex)
        local eventId, timestampS, isRedacted, eventType, displayName, currencyType, amount, kioskName = GetGuildHistoryBankedCurrencyEventInfo(guildId, eventIndex)
        if (eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED or eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN) then
          -- backwards compatibility for now
          if eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_DEPOSITED then eventType = GUILD_EVENT_BANKGOLD_ADDED end
          if eventType == GUILD_HISTORY_BANKED_CURRENCY_EVENT_WITHDRAWN then eventType = GUILD_EVENT_BANKGOLD_REMOVED end
          local convertedId = ConvertEventIdLibHistoireId(eventId)
          displayName = AddAtIfNeeded(displayName)
          local theEvent = {
            evType = eventType,
            evTime = timestampS,
            evName = displayName, -- Username that joined the guild
            evGold = amount, -- The ammount of gold
            eventId = convertedId, -- eventId but new
          }
          task:Call(function(task) AMT.ProcessListenerEvent(guildId, GUILD_HISTORY_BANK, theEvent) end)
        end
      end)
    end
  end)
  task:Call(function(task) AMT:dm("Info", GetString(AMT_REFRESH_FINISHED)) end)
end

local function table_sort(a, sortfield)
  local new1 = {}
  local new2 = {}
  for k, v in pairs(a) do
    table.insert(new1, { key = k, val = v })
  end
  table.sort(new1, function(a, b) return (a.val[sortfield] < b.val[sortfield]) end)
  for k, v in pairs(new1) do
    table.insert(new2, v.val)
  end
  return new2
end

function AMT:ExportGuildStats()
  local export = ZO_SavedVars:NewAccountWide('AdvancedMemberTooltip', 1, "EXPORT", {}, nil)

  local numGuilds = GetNumGuilds()
  local guildNum = self.guildNumber
  if guildNum > numGuilds then
    AMT:dm("Info", GetString(AMT_INVALID_GUILD_NUMBER))
    return
  end

  local guildId = GetGuildId(guildNum)
  local guildName = GetGuildName(guildId)

  AMT:dm("Info", GetString(AMT_EXPORTING) .. guildName)
  export[guildName] = {}
  local list = export[guildName]

  local numGuildMembers = GetNumGuildMembers(guildId)
  local foundedDate = AMT:GetGuildFoundedDate(guildId)
  local displayName, note, rankIndex, playerStatus, secsSinceLogoff, displayNameKey
  for guildMemberIndex = 1, numGuildMembers do
    displayName, note, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(guildId, guildMemberIndex)
    -- because it's stored with lower case
    displayNameKey = string.lower(displayName)
    secsSinceLogoff = AMT:DetermineSecondsSinceLogoff(secsSinceLogoff, foundedDate)
    if AMT.savedData[guildName][displayNameKey] then

      local amountDeposited = AMT.savedData[guildName][displayNameKey][GUILD_EVENT_BANKGOLD_ADDED][AMT_DATERANGE_THISWEEK].total or 0
      local amountWithdrawan = AMT.savedData[guildName][displayNameKey][GUILD_EVENT_BANKGOLD_REMOVED][AMT_DATERANGE_THISWEEK].total or 0
      local timeJoined = AMT.savedData[guildName][displayNameKey].timeJoined or 0
      local timestamp = GetTimeStamp()
      local timeStringOutput = ""
      local lastSeenString = ""

      if (timeJoined == 0) then
        local timeString = secToTime(timestamp - AMT.savedData[guildName]["oldestEvents"][GUILD_HISTORY_GENERAL])
        timeStringOutput = string.format(" = %s %s", "> ", timeString)
      else
        local timeString = secToTime(timestamp - timeJoined)
        timeStringOutput = string.format(" = %s %s", "", timeString)
      end

      local str = secToTime(secsSinceLogoff)
      lastSeenString = string.format("%s", str)

      if AMT.savedData.exportEpochTime then
        timeStringOutput = "&" .. AMT.savedData[guildName][displayNameKey].timeJoined
        lastSeenString = timestamp - secsSinceLogoff
        if timeJoined == 0 then
          --[[Until I figure out something better if the guild history
          does not go back far enough their timeJoined is 0. So show
          that is when ESO Launched for sorting and not founded date
          ]]--
          timeStringOutput = "&" .. 1396594800
        end
      end

      -- export normal case for displayName
      -- sample = "@displayName&timeJoined&amountDeposited&amountWithdrawan"
      table.insert(list, displayName .. timeStringOutput .. "&" .. lastSeenString .. "&" .. amountDeposited .. "&" .. amountWithdrawan)
    end
  end
  AMT:dm("Info", "Guild Stats Export complete.  /reloadui to save the file.")
end

local function get_formatted_date_parts(date_str, date_format)
  local d, m, y, arr, x, yy, mm, dd, use_month_names
  local months = { jan = 1, feb = 2, mar = 3, apr = 4, may = 5, jun = 6, jul = 7, aug = 8, sep = 9, oct = 10, nov = 11, dec = 12 }
  local unused1, unused2

  if (date_format) then

    if string.find(date_format, "mmm") then
      use_month_names = true
    else
      use_month_names = false
    end

    d = string.find(date_format, "dd")
    m = string.find(date_format, "mm")
    y = string.find(date_format, "yy")

    arr = { { pos = y, b = "yy" }, { pos = m, b = "mm" }, { pos = d, b = "dd" } }
    arr = table_sort(arr, "pos")

    date_format = string.gsub(date_format, "yyyy", "(%%d+)")
    date_format = string.gsub(date_format, "mmm", "(%%a+)")
    date_format = string.gsub(date_format, "yy", "(%%d+)")
    date_format = string.gsub(date_format, "mm", "(%%d+)")
    date_format = string.gsub(date_format, "dd", "(%%d+)")
    date_format = string.gsub(date_format, " ", "%%s")
  else
    date_format = "(%d+)-(%d+)-(%d+)"
    arr = { { pos = 1, b = "yy" }, { pos = 2, b = "mm" }, { pos = 3, b = "dd" } }
  end

  if (date_str and date_str ~= "") then
    unused1, unused2, arr[1].c, arr[2].c, arr[3].c = string.find(string.lower(date_str), date_format)
  else
    return nil, nil, nil
  end

  arr = table_sort(arr, "b")
  yy = arr[3].c
  mm = arr[2].c
  dd = arr[1].c

  if (use_month_names) then

    mm = months[lower(string.sub(mm, 1, 3))]
    if (not mm) then
      error("Invalid month name.")
    end
  end

  -- for naughty people who still use two digit years.

  if (string.len(yy) == 2) then
    if (tonumber(yy) > 40) then
      yy = "19" .. yy
    else
      yy = "20" .. yy
    end
  end

  return tonumber(dd), tonumber(mm), tonumber(yy)
end

function AMT:IsLeapYear(year)
  return (year % 400 == 0) or ((year % 4) == 0 and (year % 100 ~= 0))
end

function AMT:GetGuildFoundedDate(guildId)
  -- AMT:dm("Debug", "GetGuildFoundedDate")
  local dateString = GetGuildFoundedDate(guildId)
  -- AMT:dm("Debug", dateString)
  local dateFormat = AMT.dateFormats[AMT.savedData.dateTimeFormat]
  local day, month, year = get_formatted_date_parts(dateString, dateFormat)
  AMT.isLeapYear = AMT:IsLeapYear(year)
  -- AMT:dm("Debug", string.format("day: %s, month: %s, year: %s", day, month, year))
  local epochTime = os.time { year = year, month = month, day = day, hour = 0 }
  if not year then
    epochTime = 1396594800 -- ESO Launch
  end
  -- AMT:dm("Debug", epochTime)
  return epochTime
end

function AMT:RemovePlayerStatusInformation()
  AMT:dm("Debug", "RemovePlayerStatusInformation")
  local skipSettings = {
    addRosterColumn = true,
    version = true,
    addToCutoff = true,
    ["EU Megaserver"] = true,
    exportEpochTime = true,
    dateTimeFormat = true,
    ["NA Megaserver"] = true,
    ["lastReceivedGeneralEventID"] = true,
    ["lastReceivedBankEventID"] = true,
    [""] = true,
    ["lastCleanUp"] = true,
    ["EXPORT"] = true,
  }

  local skipGuildInfo = {
    oldestEvents = true,
    lastScans = true,
  }

  local userDisplayName = GetDisplayName()
  local saveData = AdvancedMemberTooltip["Default"][userDisplayName]["$AccountWide"]

  for guildName, guildData in pairs(saveData) do
    -- Check if guildName is not a setting
    if not skipSettings[guildName] then
      local testGuildName = guildName
      local testGuildData = guildData
      for displayName, memberData in pairs(guildData) do
        if type(memberData) == "table" and not skipGuildInfo[displayName] then
          -- List of keys to remove
          local keysToRemove = {
            "playerStatusLastSeen",
            "secsSinceLogoff",
            "playerStatusOnline",
            "playerStatusOffline",
            CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT,
            CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL
          }
          -- Removing keys
          for _, key in ipairs(keysToRemove) do
            AMT.savedData[guildName][displayName][key] = nil
          end
        end
      end
    end
  end
end

function AMT.ModifySundayTime()
  local modifyStartTime = 0
  local addHours = 0
  if GetWorldName() == "NA Megaserver" then
    modifyStartTime = modifyStartTime + (3600 * 12) -- roll to midnight Tuesday
    modifyStartTime = modifyStartTime + (3600 * 48) -- roll to midnight Sunday
  else
    modifyStartTime = modifyStartTime + (3600 * 6) -- roll to midnight Tuesday
    modifyStartTime = modifyStartTime + (3600 * 48) -- roll to midnight Sunday
  end
  addHours = (3600 * AMT.savedData.addToCutoff) -- add additional hours past midnight
  return modifyStartTime, addHours
end

function AMT.DoSundayTime()
  AMT:dm("Debug", "DoSundayTime")
  local modifyStartTime, addHours = AMT.ModifySundayTime()
  local dayCutoff = GetTimeStamp() - GetSecondsSinceMidnight()

  -- start of date ranges
  todayStart = dayCutoff
  yesterdayStart = dayCutoff - ZO_ONE_DAY_IN_SECONDS -- Yesterday
  yesterdayEnd = dayCutoff

  -- special modified start for this week
  thisweekStart = thisweekStart - modifyStartTime
  thisweekStart = thisweekStart + addHours
  thisweekEnd = thisweekEnd - modifyStartTime
  thisweekEnd = thisweekEnd + addHours

  -- continue with date ranges
  lastweekStart = thisweekStart - (ZO_ONE_DAY_IN_SECONDS * 7)
  lastweekEnd = thisweekStart
  priorweekStart = lastweekStart - (ZO_ONE_DAY_IN_SECONDS * 7)
  priorweekEnd = lastweekStart -- prior week end
  lastSevenDaysStart = dayCutoff - (7 * ZO_ONE_DAY_IN_SECONDS) -- last 7 days
  lastTenDaysStart = dayCutoff - (10 * ZO_ONE_DAY_IN_SECONDS) -- last 10 days
  lastThirtyDaysStart = dayCutoff - (30 * ZO_ONE_DAY_IN_SECONDS) -- last 30 days

  --[[
  AMT:dm("Info", "thisweekEnd = thisweekEnd - modifyStartTime")
  AMT:dm("Info", thisweekStart)
  AMT:dm("Info", thisweekEnd)
  AMT:dm("Info", os.date("%c", thisweekStart))
  AMT:dm("Info", os.date("%c", thisweekEnd))
  ]]--

  local timeString = "Cutoff Times: "
  local timeStart = os.date("%c", thisweekStart)
  local timeEnd = os.date("%c", thisweekEnd)

  timeString = timeString .. timeStart .. " / " .. timeEnd
  AMT:dm("Info", timeString)
end

function AMT.DoTuesdayTime()
  AMT:dm("Debug", "DoTuesdayTime")
  local dayCutoff = GetTimeStamp() - GetSecondsSinceMidnight()
  weekCutoff = AMT.kioskCycle

  todayStart = dayCutoff
  yesterdayStart = dayCutoff - ZO_ONE_DAY_IN_SECONDS -- Yesterday
  yesterdayEnd = dayCutoff
  thisweekStart = weekCutoff - (ZO_ONE_DAY_IN_SECONDS * 7)
  thisweekEnd = weekCutoff -- GetGuildKioskCycleTimes()
  lastweekStart = thisweekStart - (ZO_ONE_DAY_IN_SECONDS * 7) -- last week Tuesday flip
  lastweekEnd = thisweekStart -- last week end
  priorweekStart = lastweekStart - (ZO_ONE_DAY_IN_SECONDS * 7)
  priorweekEnd = lastweekStart -- prior week end
  lastSevenDaysStart = dayCutoff - (7 * ZO_ONE_DAY_IN_SECONDS) -- last 7 days
  lastTenDaysStart = dayCutoff - (10 * ZO_ONE_DAY_IN_SECONDS) -- last 10 days
  lastThirtyDaysStart = dayCutoff - (30 * ZO_ONE_DAY_IN_SECONDS) -- last 30 days

  local timeString = "Cutoff Times: "
  local timeStart = os.date("%c", thisweekStart)
  local timeEnd = os.date("%c", thisweekEnd)

  timeString = timeString .. timeStart .. " / " .. timeEnd
  if not AMT.savedData[GetWorldName()].useSunday then AMT:dm("Info", timeString) end
end

function AMT.Slash(allArgs)
  local args = ""
  local guildNumber = 0
  local exp2 = 0
  local argNum = 0
  for w in string.gmatch(allArgs, "%w+") do
    argNum = argNum + 1
    if argNum == 1 then args = w end
    if argNum == 2 then guildNumber = tonumber(w) end
    if argNum == 3 then exp2 = tonumber(w) end
  end
  args = string.lower(args)
  if args == "help" or args == "" then
    AMT:dm("Info", GetString(AMT_HELP_EXPORT))
    AMT:dm("Info", GetString(AMT_HELP_REFRESH))
    return
  end
  if args == 'export' then
    if (guildNumber > 0) and (GetNumGuilds() > 0) and (guildNumber <= GetNumGuilds()) then
      AMT.guildNumber = guildNumber
      AMT:ExportGuildStats()
    else
      AMT:dm("Info", GetString(AMT_HELP_EXPORT_DESC))
      AMT:dm("Info", GetString(AMT_HELP_EXPORT_EXAMPLE))
    end
    return
  end
  if args == 'refresh' then
    AMT:DoRefresh()
    return
  end
  if args == 'fullrefresh' then
    -- AMT.savedData["CurrentKioskTime"] = 1396594800
    AMT.slashCommandFullRefresh = true
    AMT:KioskFlipListenerSetup()
    return
  end
  AMT:dm("Info", string.format(GetString(AMT_HELP_INVALID), args))
end

function AMT:LibAddonMenuInit()
  AMT:dm("Debug", "LibAddonMenuInit")
  local panelData = {
    type = 'panel',
    name = 'AdvancedMemberTooltip',
    displayName = 'Advanced Member Tooltip',
    author = 'Arkadius, Calia1120, |cFF9B15Sharlikran|r',
    version = '2.38',
    registerForRefresh = true,
    registerForDefaults = true,
  }
  LAM:RegisterAddonPanel('AdvancedMemberTooltipOptions', panelData)

  -- Open main window with mailbox scenes
  local optionsData = {}
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(AMT_CUTOFF_OPTIONS_HEADER),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(AMT_SUNDAY_CUTOFF_NAME),
    tooltip = GetString(AMT_SUNDAY_CUTOFF_TIP),
    getFunc = function() return AMT.savedData[GetWorldName()].useSunday end,
    setFunc = function(value)
      AMT.savedData[GetWorldName()].useSunday = value
      if not AMT.savedData[GetWorldName()].useSunday then
        AMT.savedData.addToCutoff = 0
      end
      AMT.DoTuesdayTime()
      if AMT.savedData[GetWorldName()].useSunday then AMT.DoSundayTime() end
    end,
    default = amtDefaults.useSunday,
  }
  optionsData[#optionsData + 1] = {
    type = 'slider',
    name = GetString(AMT_ADD_HOURS_NAME),
    tooltip = GetString(AMT_ADD_HOURS_TIP),
    min = 0,
    max = 36,
    getFunc = function() return AMT.savedData.addToCutoff end,
    setFunc = function(value)
      AMT.savedData.addToCutoff = value
      AMT.DoTuesdayTime()
      if AMT.savedData[GetWorldName()].useSunday then AMT.DoSundayTime() end
    end,
    default = amtDefaults.addToCutoff,
    disabled = function() return not AMT.savedData[GetWorldName()].useSunday end,
  }
  optionsData[#optionsData + 1] = {
    type = "description",
    title = GetString(AMT_NOTE_TEXT),
    text = GetString(AMT_REFRESH_TEXT),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(AMT_GUILDROSTER_HEADER),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(AMT_DONATIONS_COLUMN_NAME),
    tooltip = GetString(AMT_DONATIONS_COLUMN_TIP),
    getFunc = function() return AMT.savedData[GetWorldName()].addRosterColumn end,
    setFunc = function(value)
      AMT.savedData[GetWorldName()].addRosterColumn = value
      AMT.guildDonationsColumn:IsDisabled(not value)
    end,
    default = amtDefaults.addRosterColumn,
  }
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(AMT_DATE_FORMAT_HEADER),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = "description",
    title = GetString(AMT_DATE_GUILD_CREATION_TITLE),
    text = AMT.exampleGuildFoundedDate .. GetString(AMT_DATE_GUILD_CREATION_TEXT),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = "dropdown",
    name = GetString(AMT_DATE_GUILD_CREATION_NAME),
    choices = AMT.dateFormats,
    choicesValues = AMT.dateFormatValues,
    getFunc = function() return AMT.savedData.dateTimeFormat end,
    setFunc = function(value) AMT.savedData.dateTimeFormat = value end,
    default = amtDefaults.dateTimeFormat,
  }
  optionsData[#optionsData + 1] = {
    type = "description",
    title = GetString(AMT_NOTE_TEXT),
    text = GetString(AMT_DATE_GUILD_FORMAT_DESC),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = "header",
    name = GetString(AMT_EXPORT_OPTIONS_HEADER),
    width = "full",
  }
  optionsData[#optionsData + 1] = {
    type = 'checkbox',
    name = GetString(AMT_EXPORT_OPTIONS_NAME),
    tooltip = GetString(AMT_EXPORT_OPTIONS_TIP),
    getFunc = function() return AMT.savedData.exportEpochTime end,
    setFunc = function(value)
      AMT.savedData.exportEpochTime = value
    end,
    default = amtDefaults.exportEpochTime,
  }

  LAM:RegisterOptionControls('AdvancedMemberTooltipOptions', optionsData)
end

function AMT:GetAmountDonated(guildId, displayName, timeframe)
  local amountDonated = 0

  local guildName = GetGuildName(guildId)
  if guildName == "" then return amountDonated end
  local name = string.lower(displayName)
  local guildData = AMT.savedData[guildName]
  -- AMT.savedData[guildName][name][GUILD_EVENT_BANKGOLD_ADDED][AMT_DATERANGE_THISWEEK].total

  if guildData then
    local memberData = guildData[name]
    if memberData then
      local bankGoldAdded = memberData[GUILD_EVENT_BANKGOLD_ADDED]
      if bankGoldAdded and bankGoldAdded[timeframe] then
        amountDonated = bankGoldAdded[timeframe].total or 0
      end
    end
  end

  return amountDonated
end

function AMT:GetAmountDonatedForRoster(guildId, displayName, formattedZone)
  local amountDonated = 0
  local applicationPending = GetString(SI_GUILD_INVITED_PLAYER_LOCATION) == formattedZone
  if applicationPending then return amountDonated end

  local guildName = GetGuildName(guildId)
  if guildName == "" then return amountDonated end
  local name = string.lower(displayName)
  local guildData = AMT.savedData[guildName]
  -- AMT.savedData[guildName][name][GUILD_EVENT_BANKGOLD_ADDED][AMT_DATERANGE_THISWEEK].total

  if guildData then
    local memberData = guildData[name]
    if memberData then
      local bankGoldAdded = memberData[GUILD_EVENT_BANKGOLD_ADDED]
      if bankGoldAdded and bankGoldAdded[AMT_DATERANGE_THISWEEK] then
        amountDonated = bankGoldAdded[AMT_DATERANGE_THISWEEK].total or 0
      end
    end
  end

  return amountDonated
end

function AMT:InitRosterChanges()
  -- LibGuildRoster adding the Sold Column
  AMT.guildDonationsColumn = LibGuildRoster:AddColumn({
    key = 'AMT_Donations',
    disabled = not AMT.savedData[GetWorldName()].addRosterColumn,
    width = 110,
    header = {
      title = "Donations",
      align = TEXT_ALIGN_RIGHT
    },
    row = {
      align = TEXT_ALIGN_RIGHT,
      data = function(guildId, data, index)
        return AMT:GetAmountDonatedForRoster(guildId, data.displayName, data.formattedZone)
      end,
      format = function(value)
        return ZO_LocalizeDecimalNumber(value) .. " |t16:16:EsoUI/Art/currency/currency_gold.dds|t"
      end
    },
  })

  LibGuildRoster:OnRosterReady(function()
    -- open the roster after a doposit
    SCENE_MANAGER.scenes.guildRoster:RegisterCallback("StateChange", function(oldState, newState)
      -- [STATES]: hiding, showing, shown, hidden

      if (newState == "showing" or newState == "shown") then
        if AMT.rosterDirty then
          LibGuildRoster:Refresh()
          AMT.rosterDirty = false
        end
      end
    end)
    -- after a doposit while roster open
    ZO_PreHook(GUILD_ROSTER_MANAGER, "OnGuildIdChanged", function(self)
      if AMT.rosterDirty then
        LibGuildRoster:Refresh()
        AMT.rosterDirty = false
      end
    end)

  end)

end

local function OnGuildMemberAdded(eventCode, guildId, displayName)
  --AMT:dm("Debug", "OnGuildMemberAdded")
  local guildName = GetGuildName(guildId)
  AMT:createUser(guildName, displayName)
end
EVENT_MANAGER:RegisterForEvent(AddonName .. "_GuildMemberAdded", EVENT_GUILD_MEMBER_ADDED, OnGuildMemberAdded)

local function OnPlayerJoinedGuild(eventCode, guildServerId, characterName, guildId)
  --AMT:dm("Debug", "OnPlayerJoinedGuild")
  --AMT:dm("Debug", guildServerId)
  --AMT:dm("Debug", characterName)
  --AMT:dm("Debug", GetDisplayName())
  --AMT:dm("Debug", guildId)
end
EVENT_MANAGER:RegisterForEvent(AddonName .. "_JoinedGuild", EVENT_GUILD_SELF_JOINED_GUILD, OnPlayerJoinedGuild)

-- Will be called upon loading the addon
local function onAddOnLoaded(eventCode, addonName)
  if (addonName == AddonName) then
    AMT:dm("Debug", "onAddOnLoaded")
    local userDisplayName = GetDisplayName()

    AMT.savedData = ZO_SavedVars:NewAccountWide("AdvancedMemberTooltip", 1, nil, defaultData)
    local sv = AdvancedMemberTooltip["Default"][userDisplayName]["$AccountWide"]

    -- Remove old empty guild name from previous LibHistoire
    if sv[""] ~= nil then sv[""] = nil end

    -- Remove unused settings
    local oldSettingsKeys = { "useSunday", "lastReceivedBankEventID", "lastReceivedGeneralEventID", "addRosterColumn", "EventProcessed", "CurrentKioskTime", "lastCleanUp" }
    for index, key in pairs(oldSettingsKeys) do
      if sv[key] ~= nil then
        sv[key] = nil
      end
    end

    -- Remove unused settings from NA and EU depending on which you are logged into
    local keysToCheck = { "lastReceivedGeneralEventID", "lastReceivedBankEventID" }
    for index, key in pairs(keysToCheck) do
      if sv[GetWorldName()][key] ~= nil then
        sv[GetWorldName()][key] = nil
      end
    end

    AMT.DoTuesdayTime()
    if AMT.savedData[GetWorldName()].useSunday then AMT.DoSundayTime() end
    -- Set up /amt as a slash command toggle for the main window
    SLASH_COMMANDS['/amt'] = AMT.Slash
    for guildNum = 1, GetNumGuilds() do
      local guildId = GetGuildId(guildNum)
      local guildName = GetGuildName(guildId)
      AMT.createGuild(guildName)
      for member = 1, GetNumGuildMembers(guildId), 1 do
        local memberName = GetGuildMemberInfo(guildId, member)
        AMT:createUser(guildName, memberName)
      end
      if AMT.savedData[GetWorldName()]["lastReceivedRosterEventID"][guildId] == nil then AMT.savedData[GetWorldName()]["lastReceivedRosterEventID"][guildId] = "0" end
      if AMT.savedData[GetWorldName()]["lastBankedCurrencyEventID"][guildId] == nil then AMT.savedData[GetWorldName()]["lastBankedCurrencyEventID"][guildId] = "0" end
    end

    AMT:RemovePlayerStatusInformation()
    AMT:LibAddonMenuInit()
    AMT:SetupListenerLibHistoire()
    AMT:KioskFlipListenerSetup()
    AMT:InitRosterChanges()

    EVENT_MANAGER:UnregisterForEvent(AddonName .. "_AddOnLoaded", EVENT_ADD_ON_LOADED)
  end
end
EVENT_MANAGER:RegisterForEvent(AddonName .. "_AddOnLoaded", EVENT_ADD_ON_LOADED, onAddOnLoaded)

LGH:RegisterCallback(LGH.callback.INITIALIZED, function()
  LGH:RegisterCallback(LGH.callback.MANAGED_RANGE_FOUND, function(guildId, category)
    if not AMT:IsLibHistoireListenerSetup(guildId) then return end
    if not AMT:AreLibHistoireListenersRunning(guildId) then
      AMT:dm("Debug", "Linked Range Callback for: " .. tostring(guildId))
      AMT:SetupListener(guildId)
    end
  end)
end)
