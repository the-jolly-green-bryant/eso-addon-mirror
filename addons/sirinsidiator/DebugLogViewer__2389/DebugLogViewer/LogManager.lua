local DLV = DebugLogViewer
local LDL = LibDebugLogger

local internal = DLV.internal
local gettext = internal.gettext
local osdate = os.date

local LOG_DATA = internal.LOG_DATA
local LEVEL_TO_LOCALIZED_STRING = internal.LEVEL_TO_LOCALIZED_STRING
local ENTRY_TIME_INDEX = LDL.ENTRY_TIME_INDEX
local ENTRY_OCCURENCES_INDEX = LDL.ENTRY_OCCURENCES_INDEX
local ENTRY_LEVEL_INDEX = LDL.ENTRY_LEVEL_INDEX
local ENTRY_TAG_INDEX = LDL.ENTRY_TAG_INDEX

-- TRANSLATORS: Template tooltip text for the tag of a log entry in the log viewer list
local TAG_TOOLTIP_TEMPLATE = gettext("Level: %s\nTag: %s\nOccurrences: %d")
local TIME_FORMAT = "%T.%%03.0f"
local ERROR_SOUND_COOLDOWN = 2000 -- milliseconds

local LogManager = ZO_Object:Subclass()
internal.class.LogManager = LogManager

function LogManager:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function LogManager:Initialize(quickLog, logViewer)
    self.lastId = 0
    self.logEntryById = {}
    self.lastTimePlayed = 0

    local masterList
    local logEntryById = self.logEntryById

    local function ReplaceMasterList(newList)
        masterList = newList
        self.masterList = newList
        logViewer:SetMasterList(newList)
    end
    ReplaceMasterList({})

    LDL:RegisterCallback(LDL.CALLBACK_LOG_ADDED, function(entry, wasDuplicate)
        self:PlayErrorSoundIfNeeded(entry)

        if(not wasDuplicate) then
            self:CreateDataEntry(entry)
        else
            local data = self:GetLogData(self.lastId)
            data.time = self:FormatLogViewerTime(entry[ENTRY_TIME_INDEX])
            data.tagTooltip = self:CreateTagTooltip(entry)
        end

        quickLog:AddPendingEntry(self:GetLogData(self.lastId))
        logViewer:RequestRefresh()
    end)

    LDL:RegisterCallback(LDL.CALLBACK_LOG_PRUNED, function(startIndex)
        local newList = {}
        for i = 1, #masterList do
            if(i < startIndex) then
                local data = ZO_ScrollList_GetDataEntryData(masterList[i])
                logEntryById[data.id] = nil
            else
                newList[#newList + 1] = masterList[i]
            end
        end
        ReplaceMasterList(newList)
        logViewer:RequestRefresh()
    end)

    LDL:RegisterCallback(LDL.CALLBACK_LOG_CLEARED, function()
        logEntryById = {}
        self.logEntryById = logEntryById

        ReplaceMasterList({})

        quickLog:Clear()
        logViewer:RequestRefresh()
    end)

    local logTable = LDL:GetLog()
    local logCount = #logTable
    local quickLogStartIndex = quickLog:GetFirstIndex(logCount)
    for i = 1, logCount do
        local dataEntry = self:CreateDataEntry(logTable[i])
        if(i >= quickLogStartIndex) then
            local data = ZO_ScrollList_GetDataEntryData(masterList[i])
            quickLog:AddEntry(data)
        end
    end

    DLV:RegisterCallback(internal.callback.REFRESH_QUICK_LOG, function()
        if(not quickLog:ShouldRefresh()) then return end
        quickLog:Clear()

        local quickLogStartIndex = quickLog:GetFirstIndex(#masterList)
        for i = quickLogStartIndex, #masterList do
            local data = ZO_ScrollList_GetDataEntryData(masterList[i])
            quickLog:AddPendingEntry(data)
        end
    end)

    DLV:RegisterCallback(internal.callback.REFRESH_LOG_VIEWER, function()
        for i = 1, #LDL.LOG_LEVELS do
            logViewer:UpdateFilterButtonColor(LDL.LOG_LEVELS[i])
        end
        logViewer:RequestRefresh()
    end)
end

function LogManager:PlayErrorSoundIfNeeded(entry)
    local now = GetGameTimeMilliseconds()
    if(now - self.lastTimePlayed < ERROR_SOUND_COOLDOWN) then return end

    local level = entry[ENTRY_LEVEL_INDEX]
    local tag = entry[ENTRY_TAG_INDEX]
    if(tag == LDL.TAG_INGAME and level == LDL.LOG_LEVEL_ERROR) then
        self.lastTimePlayed = now
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
end

function LogManager:CreateDataEntry(entry)
    local id = self.lastId + 1
    local dataEntry = ZO_ScrollList_CreateDataEntry(LOG_DATA, {
        id = id,
        log = entry,
        time = self:FormatLogViewerTime(entry[ENTRY_TIME_INDEX]),
        tagTooltip = self:CreateTagTooltip(entry)
    })
    self.logEntryById[id] = dataEntry
    self.masterList[#self.masterList + 1] = dataEntry
    self.lastId = id
    return dataEntry
end

function LogManager:GetLogData(id)
    local dataEntry = self.logEntryById[id]
    return ZO_ScrollList_GetDataEntryData(dataEntry)
end

function LogManager:FormatLogViewerTime(timestamp)
    return osdate(TIME_FORMAT, timestamp / 1000):format(timestamp % 1000)
end

function LogManager:CreateTagTooltip(entry)
    local levelString = LEVEL_TO_LOCALIZED_STRING[entry[ENTRY_LEVEL_INDEX]]
    return TAG_TOOLTIP_TEMPLATE:format(levelString, entry[ENTRY_TAG_INDEX] or "-missing-", entry[ENTRY_OCCURENCES_INDEX])
end
