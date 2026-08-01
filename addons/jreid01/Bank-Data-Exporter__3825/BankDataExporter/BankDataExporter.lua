BankDataExporter = BankDataExporter or {}
BankDataExporter.name = "BankDataExporter"
BankDataExporter.variableVersion = 4;
BankDataExporter.Default = {};

-- The command that will be registered by the addon in the ESO CLI.
local EXPORT_COMMAND = "/exportbankdata";

-- The command that will be registered by the addon in the ESO CLI for exporting by event count.
local EXPORT_BY_COUNT_COMMAND = "/exportbankdatabycount";

-- The data that is harvested. Eventually placed in the saved variables.
local GUILD_DATA;

-- The ID of the guild.
local GUILD_ID;

-- Flag indicating if the data has already been exported.
local ALREADY_EXPORTED = false;

-- Addon will not allow dates older than 16 March 2023.
local MIN_TRANSACTION_DATETIME = 167902092;
local MIN_TRANSACTION_DATE = '16 March 2023';

-- The number of events to export when using the export by count command.
local EVENT_COUNT = 0;

-- The target end transaction date. Must be between MIN_TRANSACTION_DATETIME and now.
local TARGET_TRANSACTION_DATETIME;

-- The original event ID that the user provided.
local EVENT_ID;

function BankDataExporter.OnAddOnLoaded(event, addonName)
   if addonName ~= BankDataExporter.name then return end;
   BankDataExporter:Initialize();
end

function BankDataExporter:Initialize()
  BankDataExporter.savedVariables = ZO_SavedVars:NewAccountWide("ExportedBankData", BankDataExporter.variableVersion, nil, BankDataExporter.Default);
  self.savedVariables["StartedTime"] = nil;
  self.savedVariables["FinishedTime"] = nil;
  EVENT_MANAGER:UnregisterForEvent(BankDataExporter.name, EVENT_ADD_ON_LOADED);
end

EVENT_MANAGER:RegisterForEvent(BankDataExporter.name, EVENT_ADD_ON_LOADED, BankDataExporter.OnAddOnLoaded);

--[[
Sets the global GUILD_ID variable based on the name of the guild.

@param guildName The name of the guild.

@returns true if the guild name was found and the ID was set, otherwise returns false.
]]--
function BankDataExporter:setGuildId(guildName)
  -- d('in setguildid');
  local numGuilds = GetNumGuilds();
  for i = 1, numGuilds do
    local currGuildId = GetGuildId(i);
    local currGuildName = GetGuildName(currGuildId);
    if (currGuildName == guildName) then
      GUILD_ID = currGuildId;
      -- d("guildid is " .. GUILD_ID);
      return true;
    end
  end
  return false;
end

--[[
Splits a string at the first space.

@param input The input string to split.

@returns The two substrings split from the input string.
]]--
function BankDataExporter:splitstring (input)
  local space = string.find(input, " ");
  if space then
    return string.sub(input,1,space - 1), string.sub(input,space+1);
  else
    return nil, nil;
  end
end

--[[
Gets the timestamp for a given event ID.

@param eventId The event ID of the event.
@returns the timestamp of the event.
]]--
function BankDataExporter:getTimestampForEventId(eventId)
  -- d('eventId ' .. eventId);
  local eventCategory, eventIndex = GetGuildHistoryEventCategoryAndIndex(GUILD_ID, eventId);
  -- d('eventCategory ' .. eventCategory .. ' eventIndex ' .. eventIndex);
  local timestamp = GetGuildHistoryEventTimestamp(GUILD_ID, eventCategory, eventIndex);
  -- d('timestamp ' .. timestamp);
  return timestamp;
end

--[[
Gets the data from the API and stores it in the saved variables.
]]
function BankDataExporter:exportData()
  local goldDepositsData = {};
  local itemDepositsData = {};
  local startTime = GetTimeStamp();
  local endTime = TARGET_TRANSACTION_DATETIME;
  local itemDeposits = 0;
  local goldDeposits = 0;

  self.savedVariables["StartedTime"] = GetTimeStamp();

  -- First, get all the item deposits.
  local newestEventIndex, oldestEventIndex = GetGuildHistoryEventIndicesForTimeRange(GUILD_ID, GUILD_HISTORY_EVENT_CATEGORY_BANKED_ITEM, startTime, endTime);
  -- d('newestEventIndex ' .. newestEventIndex .. ' oldestEventIndex ' .. oldestEventIndex);
  if EVENT_COUNT > 0 then
    -- If EVENT_COUNT is set, add that many events to the oldest event index.
    oldestEventIndex = oldestEventIndex + EVENT_COUNT;
  end

  local dataIndex = 1;
  for eventIndex = newestEventIndex, oldestEventIndex do
    local eventId, timestampS, isRedacted, eventType, displayName, itemLink, quantity  = GetGuildHistoryBankedItemEventInfo(GUILD_ID, eventIndex);
    -- d('eventId ' .. eventId .. ' EVENT_ID ' .. EVENT_ID);
    if (eventType == 0) then
      -- Do not re-export the data for the original event ID.
      if (eventId ~= EVENT_ID) then
        itemDepositsData[dataIndex] = eventId .. "&" .. timestampS .. "&" .. displayName .. "&" .. quantity .. "&" .. itemLink .. "&" .. GetItemLinkName(itemLink);
        dataIndex = dataIndex + 1;
      end
    end
  end
  itemDeposits = dataIndex;

  -- Next get all the gold deposits.
  newestEventIndex, oldestEventIndex = GetGuildHistoryEventIndicesForTimeRange(GUILD_ID, GUILD_HISTORY_EVENT_CATEGORY_BANKED_CURRENCY, startTime, endTime);
  if EVENT_COUNT > 0 then
    -- If EVENT_COUNT is set, add that many events to the oldest event index.
    oldestEventIndex = oldestEventIndex + EVENT_COUNT;
  end
  dataIndex = 1;
  -- d('newestEventIndex ' .. newestEventIndex .. ' oldestEventIndex ' .. oldestEventIndex);
  for eventIndex = newestEventIndex, oldestEventIndex do
    local eventId, timestampS, isRedacted, eventType, displayName, currencyType, amount, kioskName = GetGuildHistoryBankedCurrencyEventInfo(GUILD_ID, eventIndex);
   if (eventType == 0) then
    -- Do not re-export the data for the original event ID.
    if (eventId ~= EVENT_ID) then
        goldDepositsData[dataIndex] = eventId .. "&" .. timestampS .. "&" .. displayName .. "&" .. amount;
        dataIndex = dataIndex + 1;
      end
    end
  end
  goldDeposits = dataIndex;
  d("Recorded ".. goldDeposits .." new gold deposits and ".. itemDeposits .." item deposits.");
  GUILD_DATA["GoldDeposits"] = goldDepositsData;
  GUILD_DATA["ItemDeposits"] = itemDepositsData;
  self.savedVariables["FinishedTime"] = GetTimeStamp();
end

local function exportCommand(input)
  local isErr = false; -- Set when displaying a specific error message.
  local displayUsage = false; -- Set when displaying the generic error message.
  local eventId, guildName, eventTimestamp;
  d("======================");
  d("Bank Data Harvester");
  d("======================");
  if ALREADY_EXPORTED then
    d(EXPORT_COMMAND .. " export has already been called.");
    d("Please /reloadui to export current data and reset addon.");
    isErr = true;
  else
    eventId, guildName = BankDataExporter:splitstring(input);

    if (guildName == nil) then
      displayUsage = true;
    else
      local isGuildIdSet = BankDataExporter:setGuildId(guildName);
      if (not isGuildIdSet) then
        d("Invalid guild name: " .. guildName);
        d("The guild name is case-sensitive and must be spelled correctly.");
        isErr = true;
      end
    end

    if (eventId == nil) then
      displayUsage = true;
    else
      -- d('calling getTimestampForEventId for eventId ' .. eventId);
      eventTimestamp = BankDataExporter:getTimestampForEventId(eventId);
      EVENT_ID = tonumber(eventId); -- Store the original event ID for later use.
    end

    if (not displayUsage and eventTimestamp < MIN_TRANSACTION_DATETIME) then
      d("The end date is too old.");
      d("Please use an end date that is newer than " .. MIN_TRANSACTION_DATE);
      isErr = true;
    end

  end

  -- If there was a problem with the parameters, display a usage message.
  -- Otherwise, begin the export.
  if (not isErr) then
    if (displayUsage) then
      d("Usage:");
      d(EXPORT_COMMAND .. " ID Guild Name");
      d("ID: The ID of the oldest event.");
      d("Guild Name: The name of the guild.");
    else
      TARGET_TRANSACTION_DATETIME = eventTimestamp;
      GUILD_DATA = BankDataExporter.savedVariables;
      BankDataExporter:exportData();
      d("Export complete!");
      d("Please /reloadui to save data in SavedVariables.");
      ALREADY_EXPORTED = true;
    end
  end
  d("--------------------------------------------------");
end

local function exportByCountCommand(input)
  local isErr = false; -- Set when displaying a specific error message.
  local displayUsage = false; -- Set when displaying the generic error message.
  local eventId, guildName, eventCount;
  d("============================");
  d("Bank Data Harvester by Count");
  d("============================");
  if ALREADY_EXPORTED then
    d(EXPORT_BY_COUNT_COMMAND .. " export has already been called.");
    d("Please /reloadui to export current data and reset addon.");
    isErr = true;
  else
    eventCount, guildName = BankDataExporter:splitstring(input);
    eventCount = tonumber(eventCount);

    if (guildName == nil) then
      displayUsage = true;
    else
      local isGuildIdSet = BankDataExporter:setGuildId(guildName);
      if (not isGuildIdSet) then
        d("Invalid guild name: " .. guildName);
        d("The guild name is case-sensitive and must be spelled correctly.");
        isErr = true;
      end
    end

    if (eventCount == nil) then
      displayUsage = true;
    end

    if (not displayUsage and eventCount < 1) then

      isErr = true;
    end

  end

  -- If there was a problem with the parameters, display a usage message.
  -- Otherwise, begin the export.
  if (not isErr) then
    if (displayUsage) then
      d("Usage:");
      d(EXPORT_BY_COUNT_COMMAND .. " COUNT Guild Name");
      d("COUNT: The number of events to export.");
      d("Guild Name: The name of the guild.");
    else
      EVENT_COUNT = eventCount;
      GUILD_DATA = BankDataExporter.savedVariables;
      BankDataExporter:exportData();
      d("Export complete!");
      d("Please /reloadui to save data in SavedVariables.");
      ALREADY_EXPORTED = true
    end
  end
  d("--------------------------------------------------");
end

SLASH_COMMANDS[EXPORT_COMMAND] = exportCommand;
SLASH_COMMANDS[EXPORT_BY_COUNT_COMMAND] = exportByCountCommand;
