local DLV = DebugLogViewer
local LDL = LibDebugLogger

local LOG_LEVELS = LDL.LOG_LEVELS
local DEFAULT_TAG_SEPARATOR = "\n"

local LogFilter = ZO_Object:Subclass()
DLV.internal.class.LogFilter = LogFilter

function LogFilter:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function LogFilter:Initialize()
    self.rawTagFilter = ""
    self.tagSeparator = DEFAULT_TAG_SEPARATOR
    self.tagFilterIsBlacklist = false
    self.hasTags = false
    self.isTagFiltered = {}
    self.isLevelFiltered = {}
end

function LogFilter:IsTagFiltered(tag)
    if(self.isTagFiltered[tag]) then
        return true
    end

    -- cut off the last part after a slash and check again
    local parentTag = tag:gsub("/.-$", "")
    if(parentTag and parentTag ~= tag) then
        return self:IsTagFiltered(parentTag)
    end

    return false
end

function LogFilter:ShouldShow(time, level, tag, message)
    if(not message) then return false end
    if((self.startTime and time < self.startTime) or (self.endTime and time > self.endTime)) then return false end
    if(self.isLevelFiltered[level]) then return false end
    if(self.hasTags) then
        local isTagFiltered = self:IsTagFiltered(tag:lower())
        if(isTagFiltered and self.tagFilterIsBlacklist) then return false end
        if(not isTagFiltered and not self.tagFilterIsBlacklist) then return false end
    end
    return true
end

function LogFilter:SetTagFilter(tagFilter)
    if(tagFilter == self.rawTagFilter) then return end

    local splitTags = {zo_strsplit(self.tagSeparator, tagFilter)}
    ZO_ClearTable(self.isTagFiltered)
    self.hasTags = false
    for i = 1, #splitTags do
        -- trim surrounding spaces
        local tag = splitTags[i]:gsub("^%s*(.-)%s*$", "%1")
        if(tag ~= "") then
            self.isTagFiltered[tag:lower()] = true
            self.hasTags = true
        end
    end
    self.rawTagFilter = tagFilter
end

function LogFilter:SetTagSeparator(tagSeparator)
    self.tagSeparator = tagSeparator
end

function LogFilter:GetTagSeparator()
    return self.tagSeparator
end

function LogFilter:SetTagFilterBlacklist(blacklist)
    self.tagFilterIsBlacklist = blacklist
end

function LogFilter:IsTagFilterBlacklist()
    return self.tagFilterIsBlacklist
end

function LogFilter:SetLevelFilter(levelFilter)
    for i = 1, #LOG_LEVELS do
        local level = LOG_LEVELS[i]
        self.isLevelFiltered[level] = (levelFilter[level] ~= false)
    end
end

function LogFilter:SetLevelFiltered(level, state)
    self.isLevelFiltered[level] = state
end

function LogFilter:IsLevelFiltered(level)
    return self.isLevelFiltered[level]
end

function LogFilter:SetStartTime(startTime)
    self.startTime = startTime
end

function LogFilter:SetEndTime(endTime)
    self.endTime = endTime
end
