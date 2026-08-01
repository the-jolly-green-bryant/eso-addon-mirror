DataHarvester = DataHarvester or {}

DataHarvester.name = "BMWDataHarvester"
DataHarvester.variableVersion = 4;
DataHarvester.Default = {};

local BMW_GUILD_NAME = "Black Market Wares";
local EXPORT_COMMAND = "/harvestbmw";
local EXPORT_ARG = "export";
local BMWGuildId;
local guildData;
local alreadyExported = false;
-- A transaction ID from 31 March 2021.
-- Addon will not allow transaction IDs that are older.
local MIN_TRANSACTION_ID = 1533848783;
local MIN_TRANSACTION_DATE = "31 March 2021";

function DataHarvester.OnAddOnLoaded(event, addonName)
   if addonName ~= DataHarvester.name then return end;
   DataHarvester:Initialize();
end

function DataHarvester:Initialize()
  DataHarvester.savedVariables = ZO_SavedVars:NewAccountWide("HarvestedData", DataHarvester.variableVersion, nil, DataHarvester.Default);
  self.savedVariables["StartedTime"] = nil;
  self.savedVariables["FinishedTime"] = nil;
  d("BMW harvester version " .. DataHarvester.variableVersion);
  EVENT_MANAGER:UnregisterForEvent(DataHarvester.name, EVENT_ADD_ON_LOADED);
end

EVENT_MANAGER:RegisterForEvent(DataHarvester.name, EVENT_ADD_ON_LOADED, DataHarvester.OnAddOnLoaded);

function DataHarvester:setGuildId()
  local numGuilds = GetNumGuilds();
  for i = 1, numGuilds do
    local currGuildId = GetGuildId(i);
    local currGuildName = GetGuildName(currGuildId);
    if (currGuildName == BMW_GUILD_NAME) then
      BMWGuildId = currGuildId;
      return;
    end
  end
end

local function splitstring (input)
  local space = string.find(input, " ");
  if space then
    return string.sub(input,1,space - 1), string.sub(input,space+1);
  else
    return input, nil;
  end
end

function DataHarvester:exportDeposits()
  local goldDepositsData = {}
  local itemDepositsData = {}
  local oldestEventID = 0;
  local eventsExported = 0;
  local goldDepositsExported = 0;
  local itemDepositsExported = 0;
  local numTargetEventID = tonumber(targetEventID);

  local eventCount = GetNumGuildEvents(BMWGuildId, GUILD_HISTORY_BANK);
  local latestEventID = GetGuildEventId(BMWGuildId, GUILD_HISTORY_BANK, eventCount);
  latestEventID = Id64ToString(latestEventID);
  local numLatestEventID = tonumber(latestEventID);
  local needMoreEvents = numLatestEventID > numTargetEventID;
  if (needMoreEvents) then
    d("--------------------------------------------------");
    d("UNABLE TO EXPORT DEPOSITS");
    d("The Bank Activity Log does not go back far enough.");
    d("Please download more bank activity and try again.");
    return
  else
    self.savedVariables["StartedTime"] = GetTimeStamp();
    for i = 1, eventCount do
      local eventId = GetGuildEventId(BMWGuildId, GUILD_HISTORY_BANK, i);
      eventId = Id64ToString(eventId);
      local eventType, secsSince, v1, v2, v3, v4, v5, v6 = GetGuildEventInfo(BMWGuildId, GUILD_HISTORY_BANK, i);
      oldestEventID = eventId;

      local havePreviouslyExtracted = targetEventID >= eventId
      if (not havePreviouslyExtracted) then
        v1 = (v1 == nil and '(na)' or v1);
        v2 = (v2 == nil and '(na)' or v2);
        v3 = (v3 == nil and '(na)' or v3);
        v4 = (v4 == nil and '(na)' or v4);
        v5 = (v5 == nil and '(na)' or v5);
        v6 = (v6 == nil and '(na)' or v6);
        local displayName = v1;
        if (eventType == GUILD_EVENT_BANKGOLD_ADDED) then
          local goldValue = v2;
          goldDepositsData[i] = eventId .. "&" .. GetTimeStamp() - secsSince .. "&" .. displayName .. "&" .. goldValue;
          eventsExported = eventsExported + 1;
          goldDepositsExported = goldDepositsExported + 1;
        end
        if (eventType == GUILD_EVENT_BANKITEM_ADDED) then
          local quantity = v2;
          local itemLink = v3;
          local itemName = zo_strformat("<<t:1>>", GetItemLinkName(itemLink));
          if itemName ~= nil and itemName ~= "" then
            itemDepositsData[i] = eventId .. "&" .. GetTimeStamp() - secsSince .. "&" .. displayName .. "&" .. quantity .. "&" .. itemLink .. "&" .. itemName;
            eventsExported = eventsExported + 1;
            itemDepositsExported = itemDepositsExported +1;
          end
        end
      end
    end
    guildData["GoldDeposits"] = goldDepositsData;
    guildData["ItemDeposits"] = itemDepositsData;
    d("Recorded "..goldDepositsExported.." new gold deposits and "..itemDepositsExported.." item deposits.");
    d("Export complete!");
    d("Please /reloadui to save data in SavedVariables.");
    self.savedVariables["FinishedTime"] = GetTimeStamp();
    alreadyExported = true;
  end
end

local function exportcommand(input)
  local isErr = false;
  d("==========================");
  d("BMW Bank Deposit Harvester");
  d("==========================");
  if alreadyExported then
    d(EXPORT_COMMAND .. " export has already been called.");
    d("Please /reloadui to export current data and reset addon.");
    isErr = true;
  end
  local exportArg, transactionID = splitstring(input);

  -- Validate the exportArg and transactionID.
  local displayUsage = false;
  if (not isErr and exportArg == nill) then
    displayUsage = true;
  end
  if (not isErr and transactionID == nill) then
    displayUsage = true;
  end
  if (not isErr and exportArg ~= EXPORT_ARG) then
    displayUsage = true;
  end
  if (not displayUsage and tonumber(transactionID) < MIN_TRANSACTION_ID) then
    d("The transaction ID is too old.");
    d("Please use an ID that is newer than " .. MIN_TRANSACTION_DATE);
    isErr = true;
  end

  -- If there was a problem with the parameters, display a usage message.
  -- Otherwise, begin the export.
  if (not isErr) then
    if (displayUsage) then
      d("Usage:");
      d(EXPORT_COMMAND .. " export ID");
      d("ID: The ID of the oldest event.");
    else
      targetEventID = transactionID;
      DataHarvester:setGuildId();
      guildData = DataHarvester.savedVariables;
      DataHarvester:exportDeposits();
    end
  end
  d("--------------------------------------------------");
end

SLASH_COMMANDS[EXPORT_COMMAND] = exportcommand;