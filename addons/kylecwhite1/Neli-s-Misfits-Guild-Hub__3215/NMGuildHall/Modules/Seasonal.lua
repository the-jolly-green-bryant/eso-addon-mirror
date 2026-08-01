-- Seasonal Module
-- Used for date-based events (e.g. Misfits birthday) and any temporary UI/behavior tweaks.
-- Designed to be safe-by-default: no UI work until explicitly applied.

NMGuildHall = NMGuildHall or {}
local Addon = NMGuildHall

local Seasonal = {
    initialized = false,
    -- Active seasonal event (string key) after evaluation, or nil.
    activeKey = nil,
    -- Active event payload (table) after evaluation, or nil.
    activeEvent = nil,
}

-- Default seasonal definitions.
-- Customize these in code for now; if/when you want, they can be moved into SavedVars + Settings UI.
local DEFAULT_EVENTS = {
    -- Example: Misfits birthday week
    -- NOTE: Update these dates to the real guild birthday window.
    misfitsBirthday = {
        key = "misfitsBirthday",
        name = "Misfits Birthday",
        -- Enabled by default; users can opt out via settings/SavedVars.
        enabled = true,
        timezone = "America/New_York",
        start = { month = 5, day = 24, hour = 0, min = 0, sec = 0 },
        ["end"] = { month = 5, day = 26, hour = 23, min = 59, sec = 59 },

        -- Hook points (optional):
        -- onEnter = function(self, addon) end
        -- onLeave = function(self, addon) end
        -- apply = function(self, addon) end
    },
}

local DEFAULT_EVENT_OVERRIDES = {
    misfitsBirthday = {
        enabled = false,
        timezone = "America/New_York",
        start = { year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0 },
        ["end"] = { year = 0, month = 0, day = 0, hour = 23, min = 59, sec = 59 },
    },
}

local GUILD_NAME_REAL = "Neli's Misfits"
local GUILD_NAME_JOKE = "Neil\226\128\153s FitMisses" -- Neil’s FitMisses
local unpackArgs = unpack or table.unpack
local packArgs = table.pack or function(...)
    return { n = select("#", ...), ... }
end
local ADDON_STRING_ID_NAMES = {
    "NMGH_NAME",
    "NMGH_DISPLAY_NAME",
    "NMGH_SETTINGS_CHOICE_NM_ONLY",
    "NMGH_HELP_MAIN",
}

local function ShallowCopy(source)
    if type(source) ~= "table" then
        return source
    end

    local copy = {}
    for key, value in pairs(source) do
        copy[key] = value
    end
    return copy
end

local function ContainsRealGuildName(text)
    if type(text) ~= "string" or text == "" then
        return false
    end
    -- Exact match first (fast path).
    if text:find(GUILD_NAME_REAL, 1, true) then
        return true
    end
    -- Tolerate curly apostrophe / formatting that may appear in some UI strings.
    -- Example: Neli’s Misfits
    if text:find("Neli", 1, true) and text:find("Misfits", 1, true) then
        return true
    end
    return false
end

local function ReplaceRealWithJoke(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    -- Replace the canonical form.
    if text:find(GUILD_NAME_REAL, 1, true) then
        return text:gsub(GUILD_NAME_REAL, GUILD_NAME_JOKE)
    end
    -- Replace the visible guild-name tokens while keeping surrounding formatting intact.
    -- This covers curly apostrophes and minor formatting differences.
    if text:find("Neli", 1, true) and text:find("Misfits", 1, true) then
        local rewritten = text:gsub("Neli", "Neil", 1)
        rewritten = rewritten:gsub("Misfits", "FitMisses", 1)
        return rewritten
    end
    return text
end

local function ReplaceJokeWithReal(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    if text:find(GUILD_NAME_JOKE, 1, true) then
        return text:gsub(GUILD_NAME_JOKE, GUILD_NAME_REAL)
    end
    if text:find("Neil", 1, true) and text:find("FitMisses", 1, true) then
        local restored = text:gsub("FitMisses", "Misfits", 1)
        restored = restored:gsub("Neil", "Neli", 1)
        return restored
    end
    return text
end

local function ReadStringValueByName(name)
    if type(GetString) ~= "function" or type(name) ~= "string" or name == "" then
        return nil
    end

    local stringId = _G[name]
    if stringId == nil then
        return nil
    end

    local ok, value = pcall(GetString, stringId)
    if ok and type(value) == "string" and value ~= "" then
        return value
    end

    return nil
end

local function WriteStringValueByName(name, value)
    if type(name) ~= "string" or name == "" or type(value) ~= "string" then
        return false
    end

    local stringId = _G[name]
    if stringId ~= nil and type(SafeAddString) == "function" then
        local ok = pcall(SafeAddString, stringId, value, 1)
        if ok then
            return true
        end
    end

    if type(ZO_CreateStringId) == "function" then
        local ok = pcall(ZO_CreateStringId, name, value)
        if ok then
            return true
        end
    end

    return false
end

local function IsVisibleGuildSelectorLabelRewritten()
    local label = _G["ZO_GuildSelectorComboBoxSelectedItemText"]
    if not (label and label.GetText) then
        return false
    end

    local ok, current = pcall(label.GetText, label)
    if not ok or type(current) ~= "string" or current == "" then
        return false
    end

    return current:find(GUILD_NAME_JOKE, 1, true) ~= nil
end

local function SafeNowDate()
    -- Prefer ESO's time source; fall back safely.
    local ts = (GetTimeStamp and GetTimeStamp()) or 0
    if ts <= 0 then
        return nil
    end
    if os and os.date then
        -- Use local date; ESO doesn't expose server calendar directly.
        local t = os.date("*t", ts)
        if t and t.month and t.day then
            return t.year, t.month, t.day
        end
    end
    return nil
end

local function SafeNowTimestamp()
    local ts = (GetTimeStamp and GetTimeStamp()) or 0
    if type(ts) ~= "number" or ts <= 0 then
        return nil
    end
    return ts
end

local function DayOfYear(month, day)
    -- Minimal day-of-year conversion for range checks (non-leap is fine for seasonal UI windows).
    local monthDays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local d = 0
    for m = 1, math.max(1, math.min(12, month or 1)) - 1 do
        d = d + monthDays[m]
    end
    d = d + (day or 1)
    return d
end

local function IsLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function GetDaysInMonth(year, month)
    local monthDays = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and year and IsLeapYear(year) then
        return 29
    end
    return monthDays[month]
end

local function WeekdaySunday0(year, month, day)
    local monthOffsets = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 }
    if month < 3 then
        year = year - 1
    end
    return (year + math.floor(year / 4) - math.floor(year / 100) + math.floor(year / 400) + monthOffsets[month] + day) % 7
end

local function NthWeekdayOfMonth(year, month, targetWeekday, occurrence)
    local firstWeekday = WeekdaySunday0(year, month, 1)
    local firstTargetDay = 1 + ((targetWeekday - firstWeekday + 7) % 7)
    return firstTargetDay + ((occurrence or 1) - 1) * 7
end

local function CivilToUnixUtc(year, month, day, hour, minute, second)
    local y = year
    local m = month
    y = y - (m <= 2 and 1 or 0)
    local era = math.floor((y >= 0 and y or y - 399) / 400)
    local yoe = y - era * 400
    local mp = m + (m > 2 and -3 or 9)
    local doy = math.floor((153 * mp + 2) / 5) + day - 1
    local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
    local days = era * 146097 + doe - 719468
    return days * 86400 + (hour or 0) * 3600 + (minute or 0) * 60 + (second or 0)
end

local function IsNewYorkDstLocal(year, month, day, hour)
    local h = tonumber(hour) or 0
    if month < 3 or month > 11 then
        return false
    end
    if month > 3 and month < 11 then
        return true
    end

    local secondSundayInMarch = NthWeekdayOfMonth(year, 3, 0, 2)
    local firstSundayInNovember = NthWeekdayOfMonth(year, 11, 0, 1)

    if month == 3 then
        if day > secondSundayInMarch then
            return true
        end
        if day < secondSundayInMarch then
            return false
        end
        return h >= 2
    end

    if day < firstSundayInNovember then
        return true
    end
    if day > firstSundayInNovember then
        return false
    end
    return h < 2
end

local function NewYorkLocalToUtcTimestamp(year, month, day, hour, minute, second)
    local offsetHours = IsNewYorkDstLocal(year, month, day, hour) and -4 or -5
    return CivilToUnixUtc(year, month, day, hour or 0, minute or 0, second or 0) - offsetHours * 3600
end

local function GetTimezoneEventWindowUtc(ev, startYear)
    if type(ev) ~= "table" or type(ev.start) ~= "table" or type(ev["end"]) ~= "table" then
        return nil, nil
    end

    if ev.timezone ~= "America/New_York" then
        return nil, nil
    end

    local startMonth = tonumber(ev.start.month)
    local startDay = tonumber(ev.start.day)
    local startHour = tonumber(ev.start.hour) or 0
    local startMinute = tonumber(ev.start.min) or 0
    local startSecond = tonumber(ev.start.sec) or 0

    local endMonth = tonumber(ev["end"].month)
    local endDay = tonumber(ev["end"].day)
    local endHour = tonumber(ev["end"].hour) or 23
    local endMinute = tonumber(ev["end"].min) or 59
    local endSecond = tonumber(ev["end"].sec) or 59

    if not (startMonth and startMonth >= 1 and startMonth <= 12
        and startDay and startDay >= 1
        and endMonth and endMonth >= 1 and endMonth <= 12
        and endDay and endDay >= 1) then
        return nil, nil
    end

    local startMonthDays = GetDaysInMonth(startYear, startMonth)
    local endYear = startYear
    if endMonth < startMonth or (endMonth == startMonth and endDay < startDay) then
        endYear = startYear + 1
    end
    local endMonthDays = GetDaysInMonth(endYear, endMonth)

    if not (startMonthDays and startDay <= startMonthDays and endMonthDays and endDay <= endMonthDays) then
        return nil, nil
    end

    local startUtc = NewYorkLocalToUtcTimestamp(startYear, startMonth, startDay, startHour, startMinute, startSecond)
    local endUtc = NewYorkLocalToUtcTimestamp(endYear, endMonth, endDay, endHour, endMinute, endSecond)
    return startUtc, endUtc
end

local function IsTimestampWithinTimezoneEvent(ts, ev)
    if not (os and os.date and type(ts) == "number" and ts > 0) then
        return false
    end

    local utcNow = os.date("!*t", ts)
    if not (utcNow and utcNow.year) then
        return false
    end

    local startUtc, endUtc = GetTimezoneEventWindowUtc(ev, utcNow.year)
    if startUtc and endUtc and ts >= startUtc and ts <= endUtc then
        return true
    end

    startUtc, endUtc = GetTimezoneEventWindowUtc(ev, utcNow.year - 1)
    return startUtc and endUtc and ts >= startUtc and ts <= endUtc or false
end

local function IsInRange(month, day, startMonth, startDay, endMonth, endDay)
    local cur = DayOfYear(month, day)
    local s = DayOfYear(startMonth, startDay)
    local e = DayOfYear(endMonth, endDay)

    -- Normal window (same year segment)
    if s <= e then
        return cur >= s and cur <= e
    end
    -- Wrapped window (e.g. Dec -> Jan)
    return cur >= s or cur <= e
end

local function NormalizeSeasonalOverrideBoundary(value, defaultHour, defaultMinute, defaultSecond)
    local normalized = {
        year = 0,
        month = 0,
        day = 0,
        hour = defaultHour or 0,
        min = defaultMinute or 0,
        sec = defaultSecond or 0,
    }

    if type(value) ~= "table" then
        return normalized
    end

    local year = tonumber(value.year)
    if year and year >= 0 then
        normalized.year = math.floor(year)
    end

    local month = tonumber(value.month)
    if month and month >= 0 then
        normalized.month = math.floor(month)
    end

    local day = tonumber(value.day)
    if day and day >= 0 then
        normalized.day = math.floor(day)
    end

    local hour = tonumber(value.hour)
    if hour then
        normalized.hour = math.max(0, math.min(23, math.floor(hour)))
    end

    local minute = tonumber(value.min)
    if minute then
        normalized.min = math.max(0, math.min(59, math.floor(minute)))
    end

    local second = tonumber(value.sec)
    if second then
        normalized.sec = math.max(0, math.min(59, math.floor(second)))
    end

    return normalized
end

local function NormalizeSeasonalEventOverride(value, defaultValue)
    local normalized = {
        enabled = false,
        timezone = "America/New_York",
        start = NormalizeSeasonalOverrideBoundary(nil, 0, 0, 0),
        ["end"] = NormalizeSeasonalOverrideBoundary(nil, 23, 59, 59),
    }

    if type(defaultValue) == "table" then
        if type(defaultValue.enabled) == "boolean" then
            normalized.enabled = defaultValue.enabled
        end
        if defaultValue.timezone == "UTC" or defaultValue.timezone == "America/New_York" then
            normalized.timezone = defaultValue.timezone
        end
        normalized.start = NormalizeSeasonalOverrideBoundary(defaultValue.start, 0, 0, 0)
        normalized["end"] = NormalizeSeasonalOverrideBoundary(defaultValue["end"], 23, 59, 59)
    end

    if type(value) == "table" then
        if type(value.enabled) == "boolean" then
            normalized.enabled = value.enabled
        end
        if value.timezone == "UTC" or value.timezone == "America/New_York" then
            normalized.timezone = value.timezone
        end
        normalized.start = NormalizeSeasonalOverrideBoundary(value.start, normalized.start.hour, normalized.start.min, normalized.start.sec)
        normalized["end"] = NormalizeSeasonalOverrideBoundary(value["end"], normalized["end"].hour, normalized["end"].min, normalized["end"].sec)
    end

    return normalized
end

local function NormalizeSeasonalEventOverrides(value, defaults)
    local normalized = {}
    local defaultTable = type(defaults) == "table" and defaults or {}

    for eventKey, defaultValue in pairs(defaultTable) do
        local overrideValue = type(value) == "table" and value[eventKey] or nil
        normalized[eventKey] = NormalizeSeasonalEventOverride(overrideValue, defaultValue)
    end

    return normalized
end

local function GetExplicitEventWindowUtc(ev)
    if type(ev) ~= "table" or type(ev.start) ~= "table" or type(ev["end"]) ~= "table" then
        return nil, nil
    end

    local startYear = tonumber(ev.start.year)
    local startMonth = tonumber(ev.start.month)
    local startDay = tonumber(ev.start.day)
    local startHour = tonumber(ev.start.hour) or 0
    local startMinute = tonumber(ev.start.min) or 0
    local startSecond = tonumber(ev.start.sec) or 0

    local endYear = tonumber(ev["end"].year)
    local endMonth = tonumber(ev["end"].month)
    local endDay = tonumber(ev["end"].day)
    local endHour = tonumber(ev["end"].hour) or 23
    local endMinute = tonumber(ev["end"].min) or 59
    local endSecond = tonumber(ev["end"].sec) or 59

    if not (startYear and startYear > 0
        and startMonth and startMonth >= 1 and startMonth <= 12
        and startDay and startDay >= 1
        and endYear and endYear > 0
        and endMonth and endMonth >= 1 and endMonth <= 12
        and endDay and endDay >= 1) then
        return nil, nil
    end

    local startMonthDays = GetDaysInMonth(startYear, startMonth)
    local endMonthDays = GetDaysInMonth(endYear, endMonth)
    if not (startMonthDays and startDay <= startMonthDays and endMonthDays and endDay <= endMonthDays) then
        return nil, nil
    end

    if ev.timezone == "UTC" then
        return CivilToUnixUtc(startYear, startMonth, startDay, startHour, startMinute, startSecond),
            CivilToUnixUtc(endYear, endMonth, endDay, endHour, endMinute, endSecond)
    end

    if ev.timezone == "America/New_York" then
        return NewYorkLocalToUtcTimestamp(startYear, startMonth, startDay, startHour, startMinute, startSecond),
            NewYorkLocalToUtcTimestamp(endYear, endMonth, endDay, endHour, endMinute, endSecond)
    end

    return nil, nil
end

local function HasCompleteExplicitOverrideWindow(override)
    if type(override) ~= "table" then
        return false
    end

    return GetExplicitEventWindowUtc(override) ~= nil
end

function Seasonal:_Log()
    if Addon and Addon.Message and Addon.Message.For then
        return Addon.Message:For("Seasonal")
    end
    return nil
end

function Seasonal:GetConfig()
    local defaults = Addon and Addon.defaults and Addon.defaults.seasonal
    local stored = Addon and Addon.db and Addon.db.seasonal
    local legacyEnabled = Addon and Addon.db and Addon.db.seasonalEnabled
    local config = {
        enabled = true,
        ownUi = true,
        chatMessages = true,
        nativeGuildUi = true,
        keepOwnership = true,
        traderUi = true,
        eventOverrides = NormalizeSeasonalEventOverrides(nil, DEFAULT_EVENT_OVERRIDES),
    }

    if type(defaults) == "table" then
        if type(defaults.enabled) == "boolean" then
            config.enabled = defaults.enabled
        end
        if type(defaults.ownUi) == "boolean" then
            config.ownUi = defaults.ownUi
        end
        if type(defaults.chatMessages) == "boolean" then
            config.chatMessages = defaults.chatMessages
        end
        if type(defaults.guildNamePatch) == "boolean" then
            config.nativeGuildUi = defaults.guildNamePatch
            config.keepOwnership = defaults.guildNamePatch
            config.traderUi = defaults.guildNamePatch
        end
        if type(defaults.nativeGuildUi) == "boolean" then
            config.nativeGuildUi = defaults.nativeGuildUi
        end
        if type(defaults.keepOwnership) == "boolean" then
            config.keepOwnership = defaults.keepOwnership
        end
        if type(defaults.traderUi) == "boolean" then
            config.traderUi = defaults.traderUi
        end
        if type(defaults.eventOverrides) == "table" then
            config.eventOverrides = NormalizeSeasonalEventOverrides(defaults.eventOverrides, DEFAULT_EVENT_OVERRIDES)
        end
    end

    if type(stored) == "table" then
        if type(stored.enabled) == "boolean" then
            config.enabled = stored.enabled
        end
        if type(stored.ownUi) == "boolean" then
            config.ownUi = stored.ownUi
        end
        if type(stored.chatMessages) == "boolean" then
            config.chatMessages = stored.chatMessages
        end
        if type(stored.guildNamePatch) == "boolean" then
            config.nativeGuildUi = stored.guildNamePatch
            config.keepOwnership = stored.guildNamePatch
            config.traderUi = stored.guildNamePatch
        end
        if type(stored.nativeGuildUi) == "boolean" then
            config.nativeGuildUi = stored.nativeGuildUi
        end
        if type(stored.keepOwnership) == "boolean" then
            config.keepOwnership = stored.keepOwnership
        end
        if type(stored.traderUi) == "boolean" then
            config.traderUi = stored.traderUi
        end
        if type(stored.eventOverrides) == "table" then
            config.eventOverrides = NormalizeSeasonalEventOverrides(stored.eventOverrides, config.eventOverrides)
        end
    end

    if type(legacyEnabled) == "boolean" then
        config.enabled = legacyEnabled
    end

    return config
end

function Seasonal:GetEffectiveEventDefinition(eventKey, ev)
    if type(ev) ~= "table" then
        return ev
    end

    local overrides = self:GetConfig().eventOverrides
    local override = type(overrides) == "table" and overrides[eventKey] or nil
    if not (type(override) == "table" and override.enabled == true and HasCompleteExplicitOverrideWindow(override)) then
        return ev
    end

    local effective = ShallowCopy(ev)
    effective.timezone = override.timezone or ev.timezone
    effective.start = ShallowCopy(override.start)
    effective["end"] = ShallowCopy(override["end"])
    return effective
end

function Seasonal:IsEnabled()
    return self:GetConfig().enabled ~= false
end

function Seasonal:_InvokeEventCallback(ev, callbackName)
    if type(ev) ~= "table" or type(ev[callbackName]) ~= "function" then
        return true
    end

    local ok, err = pcall(ev[callbackName], ev, Addon)
    if ok then
        return true
    end

    local log = self:_Log()
    if log and log.Error then
        log:Error("Seasonal callback failed ({event}.{callback}): {error}", {
            callback = tostring(callbackName),
            event = tostring(ev.key or self.activeKey or "unknown"),
            error = tostring(err),
        })
    end
    return false
end

function Seasonal:Initialize()
    if self.initialized then
        return
    end
    self.initialized = true

    local log = self:_Log()
    if log and log.Debug then
        log:Debug("Seasonal module initialized")
    end

    -- Apply early so global hooks (e.g. GetGuildName/chat routing) can take effect during login.
    -- Safe: Apply() is idempotent and will no-op when no seasonal event is active.
    self:Apply()
end

function Seasonal:GetEvents()
    -- Future: merge with db overrides.
    return DEFAULT_EVENTS
end

function Seasonal:EvaluateActiveEvent()
    self.activeKey = nil
    self.activeEvent = nil

    local ts = SafeNowTimestamp()

    local _, m, d = SafeNowDate()
    if not ts and (not m or not d) then
        return nil
    end

    for key, ev in pairs(self:GetEvents()) do
        if type(ev) == "table" and ev.enabled == true and ev.start and ev["end"] then
            local effectiveEvent = self:GetEffectiveEventDefinition(key, ev)
            local explicitStartUtc, explicitEndUtc = nil, nil
            if ts then
                explicitStartUtc, explicitEndUtc = GetExplicitEventWindowUtc(effectiveEvent)
            end
            if ts and explicitStartUtc and explicitEndUtc and ts >= explicitStartUtc and ts <= explicitEndUtc then
                self.activeKey = key
                self.activeEvent = effectiveEvent
                return effectiveEvent
            end

            local hasTimezone = type(effectiveEvent.timezone) == "string" and effectiveEvent.timezone ~= ""
            if ts and hasTimezone then
                if IsTimestampWithinTimezoneEvent(ts, effectiveEvent) then
                    self.activeKey = key
                    self.activeEvent = effectiveEvent
                    return effectiveEvent
                end
            end
            local sm = tonumber(effectiveEvent.start.month)
            local sd = tonumber(effectiveEvent.start.day)
            local em = tonumber(effectiveEvent["end"].month)
            local ed = tonumber(effectiveEvent["end"].day)
            if (not explicitStartUtc) and (((not hasTimezone) or not ts) and m and d and sm and sd and em and ed and IsInRange(m, d, sm, sd, em, ed)) then
                self.activeKey = key
                self.activeEvent = effectiveEvent
                return effectiveEvent
            end
        end
    end

    return nil
end

function Seasonal:IsActive()
    return self.activeEvent ~= nil
end

function Seasonal:GetActive()
    return self.activeEvent
end

function Seasonal:_TryHookGuildSelectorJoke()
    -- Only affects displayed text; does not modify guild id/selection.
    if self._guildSelectorHooked then
        return true
    end

    if type(ZO_ComboBox_ObjectFromContainer) ~= "function" then
        return false
    end

    local container = _G["ZO_GuildSelectorComboBox"]
    if not container then
        return false
    end

    local comboBox = ZO_ComboBox_ObjectFromContainer(container)
    if not comboBox or type(comboBox.SetSelectedItemText) ~= "function" then
        return false
    end

    if comboBox._nmghNeilHooked then
        self._guildSelectorHooked = true
        return true
    end

    local orig = comboBox.SetSelectedItemText
    comboBox._nmghNeilHooked = true
    comboBox._nmghNeilOrig = orig
    local selectedItemTextWrapper = function(selfCombo, text, ...)
        if type(text) == "string" and text ~= "" then
            -- Only touch the displayed text if it contains the real guild name.
            if ContainsRealGuildName(text) then
                text = ReplaceRealWithJoke(text)
            end
        end
        return orig(selfCombo, text, ...)
    end
    comboBox._nmghNeilWrapper = selectedItemTextWrapper

    comboBox.SetSelectedItemText = selectedItemTextWrapper

    -- Also patch dropdown rows (typically 1-5 guilds). We only rewrite rows that match the real name.
    -- This is display-only; we do not touch item callbacks/data.
    local origClear = comboBox.ClearItems
    if type(origClear) == "function" and not comboBox._nmghNeilOrigClearItems then
        comboBox._nmghNeilOrigClearItems = origClear
        comboBox._nmghNeilClearItemsWrapper = function(selfCombo, ...)
            selfCombo._nmghNeilRowIndex = 0
            return origClear(selfCombo, ...)
        end
        comboBox.ClearItems = comboBox._nmghNeilClearItemsWrapper
    end

    local origAdd = comboBox.AddItem
    if type(origAdd) == "function" and not comboBox._nmghNeilOrigAddItem then
        comboBox._nmghNeilOrigAddItem = origAdd
        comboBox._nmghNeilAddItemWrapper = function(selfCombo, itemEntry, ...)
            selfCombo._nmghNeilRowIndex = (tonumber(selfCombo._nmghNeilRowIndex) or 0) + 1

            -- Only the first 5 rows, and only if the row name matches.
            local itemToAdd = itemEntry
            if selfCombo._nmghNeilRowIndex <= 5 and type(itemEntry) == "table" then
                local name = itemEntry.name
                local nameString = itemEntry.nameString
                local needsCopy = ContainsRealGuildName(name) or ContainsRealGuildName(nameString)

                if needsCopy then
                    itemToAdd = ShallowCopy(itemEntry)
                end

                if ContainsRealGuildName(name) then
                    itemToAdd.name = ReplaceRealWithJoke(name)
                end
                -- Some item entries also carry the display text under different keys.
                if ContainsRealGuildName(nameString) then
                    itemToAdd.nameString = ReplaceRealWithJoke(nameString)
                end
            end

            return origAdd(selfCombo, itemToAdd, ...)
        end
        comboBox.AddItem = comboBox._nmghNeilAddItemWrapper
    end

    self._guildSelectorHooked = true
    self._guildSelectorComboBox = comboBox

    self:_RefreshGuildSelectorVisibleText(true)

    local log = self:_Log()
    if log and log.Debug then
        log:Debug("Seasonal display hook enabled: guild selector ({from} -> {to})", {
            from = GUILD_NAME_REAL,
            to = GUILD_NAME_JOKE,
        })
    end

    return true
end

function Seasonal:_RefreshGuildSelectorVisibleText(shouldJoke)
    local label = _G["ZO_GuildSelectorComboBoxSelectedItemText"]
    local comboBox = self._guildSelectorComboBox

    if label and label.GetText and label.SetText then
        local ok, current = pcall(label.GetText, label)
        if ok and type(current) == "string" and current ~= "" then
            local rewritten = self:_TransformVisibleGuildNameText(current, shouldJoke)
            if rewritten ~= current then
                pcall(label.SetText, label, rewritten)
            end
        end
    end

    local isRewritten = IsVisibleGuildSelectorLabelRewritten()
    if shouldJoke and isRewritten then
        self._guildSelectorRewroteVisible = true
        return true
    elseif not shouldJoke and not isRewritten then
        self._guildSelectorRewroteVisible = false
        return true
    end

    if comboBox and type(comboBox.SetSelectedItemText) == "function" then
        local selectedText = nil

        if comboBox.m_selectedItemData and type(comboBox.m_selectedItemData) == "table" then
            selectedText = comboBox.m_selectedItemData.name or comboBox.m_selectedItemData.nameString
        end

        if (not selectedText or selectedText == "") and label and label.GetText then
            local ok, current = pcall(label.GetText, label)
            if ok then
                selectedText = current
            end
        end

        if shouldJoke and ContainsRealGuildName(selectedText) then
            pcall(comboBox.SetSelectedItemText, comboBox, selectedText)
        elseif not shouldJoke and type(selectedText) == "string" and selectedText ~= "" then
            local rewritten = ReplaceJokeWithReal(selectedText)
            if rewritten ~= selectedText then
                pcall(comboBox.SetSelectedItemText, comboBox, rewritten)
            end
        end
    end

    self._guildSelectorRewroteVisible = IsVisibleGuildSelectorLabelRewritten()
    return (shouldJoke and self._guildSelectorRewroteVisible == true)
        or ((not shouldJoke) and self._guildSelectorRewroteVisible ~= true)
end

function Seasonal:_ApplyChannelInfoGuildNameJoke()
    if type(ZO_ChatSystem_GetChannelInfo) ~= "function" then
        return false
    end

    local channelInfo = ZO_ChatSystem_GetChannelInfo()
    if type(channelInfo) ~= "table" then
        return false
    end

    self._channelInfoGuildNameOriginals = self._channelInfoGuildNameOriginals or {}

    local getGuildName = self._getGuildNameOriginal or _G.GetGuildName
    if type(getGuildName) ~= "function" then
        return false
    end

    local patchedAny = false
    local function patchEntry(channelId)
        local entry = channelInfo[channelId]
        if type(entry) ~= "table" or not ContainsRealGuildName(entry.name) then
            return false
        end

        if self._channelInfoGuildNameOriginals[channelId] == nil then
            self._channelInfoGuildNameOriginals[channelId] = {
                name = entry.name,
                dynamicName = entry.dynamicName,
            }
        end

        entry.name = ReplaceRealWithJoke(entry.name)
        entry.dynamicName = false
        return true
    end

    for guildIndex = 1, (GetNumGuilds and GetNumGuilds() or 0) do
        local guildId = GetGuildId and GetGuildId(guildIndex)
        local guildName = guildId and getGuildName(guildId)
        if ContainsRealGuildName(guildName) then
            patchedAny = patchEntry(CHAT_CHANNEL_GUILD_1 - 1 + guildIndex) or patchedAny
            patchedAny = patchEntry(CHAT_CHANNEL_OFFICER_1 - 1 + guildIndex) or patchedAny
        end
    end

    self._channelInfoGuildNamePatched = next(self._channelInfoGuildNameOriginals) ~= nil

    if patchedAny then
        self:_RefreshGuildSelectorVisibleText(true)
        self:_RefreshAddonVisualText()
    end

    if patchedAny and not self._channelInfoGuildNameLogged then
        self._channelInfoGuildNameLogged = true
        local log = self:_Log()
        if log and log.Debug then
            log:Debug("Seasonal display hook enabled: guild/officer channels ({from} -> {to})", {
                from = GUILD_NAME_REAL,
                to = GUILD_NAME_JOKE,
            })
        end
    end

    return self._channelInfoGuildNamePatched == true
end

function Seasonal:_SetChatFormatter(formatterKey, formatterFn)
    if not (CHAT_ROUTER and type(CHAT_ROUTER) == "table" and type(CHAT_ROUTER.GetRegisteredMessageFormatters) == "function") then
        return false
    end

    local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    if type(formatters) ~= "table" then
        return false
    end

    formatters[formatterKey] = formatterFn
    if type(CHAT_ROUTER.RegisterMessageFormatter) == "function" then
        pcall(CHAT_ROUTER.RegisterMessageFormatter, CHAT_ROUTER, formatterKey, formatterFn)
    end
    return true
end

function Seasonal:_ApplyChatFormatterGuildNameJoke()
    if not (CHAT_ROUTER and type(CHAT_ROUTER) == "table" and type(CHAT_ROUTER.GetRegisteredMessageFormatters) == "function") then
        return false
    end

    local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    if type(formatters) ~= "table" then
        return false
    end

    self._chatFormatterGuildNameState = self._chatFormatterGuildNameState or {}

    local keys = {
        EVENT_CHAT_MESSAGE_CHANNEL,
        "AddSystemMessage",
    }

    local wrappedAny = false
    local wrappedNow = false

    for _, formatterKey in ipairs(keys) do
        local current = formatters[formatterKey]
        local state = self._chatFormatterGuildNameState[formatterKey]

        if state and current == state.wrapper then
            wrappedAny = true
        elseif type(current) == "function" then
            local original = current
            local wrapper = function(...)
                local results = packArgs(original(...))
                if type(results[1]) == "string" and ContainsRealGuildName(results[1]) then
                    results[1] = ReplaceRealWithJoke(results[1])
                end
                return unpackArgs(results, 1, results.n)
            end

            self._chatFormatterGuildNameState[formatterKey] = {
                original = original,
                wrapper = wrapper,
            }

            if self:_SetChatFormatter(formatterKey, wrapper) then
                wrappedAny = true
                wrappedNow = true
            end
        end
    end

    self._chatFormatterGuildNameHooked = wrappedAny

    if wrappedNow and not self._chatFormatterGuildNameLogged then
        self._chatFormatterGuildNameLogged = true
        local log = self:_Log()
        if log and log.Debug then
            log:Debug("Seasonal display hook enabled: live chat ({from} -> {to})", {
                from = GUILD_NAME_REAL,
                to = GUILD_NAME_JOKE,
            })
        end
    end

    return wrappedAny
end

function Seasonal:_AreChatFormatterGuildNameHooksActive()
    if not (CHAT_ROUTER and type(CHAT_ROUTER) == "table" and type(CHAT_ROUTER.GetRegisteredMessageFormatters) == "function") then
        return false
    end

    local formatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    if type(formatters) ~= "table" then
        return false
    end

    local eventState = self._chatFormatterGuildNameState and self._chatFormatterGuildNameState[EVENT_CHAT_MESSAGE_CHANNEL]
    if not (eventState and formatters[EVENT_CHAT_MESSAGE_CHANNEL] == eventState.wrapper) then
        return false
    end

    local systemFormatter = formatters["AddSystemMessage"]
    if type(systemFormatter) == "function" then
        local systemState = self._chatFormatterGuildNameState and self._chatFormatterGuildNameState["AddSystemMessage"]
        if not (systemState and systemFormatter == systemState.wrapper) then
            return false
        end
    end

    return true
end

function Seasonal:_StartChatFormatterGuildNameJokeRetry()
    if self._chatFormatterGuildNameRetryActive then
        return
    end
    self._chatFormatterGuildNameRetryActive = true

    local attemptsLeft = 60
    local function tick()
        self:_ApplyChatFormatterGuildNameJoke()

        if self:_AreChatFormatterGuildNameHooksActive() then
            self._chatFormatterGuildNameRetryActive = false
            return
        end

        attemptsLeft = attemptsLeft - 1
        if attemptsLeft <= 0 then
            self._chatFormatterGuildNameRetryActive = false
            return
        end

        if zo_callLater then
            self._chatFormatterGuildNameRetryCallId = zo_callLater(tick, 500)
        else
            self._chatFormatterGuildNameRetryActive = false
        end
    end

    tick()
end

function Seasonal:_TryHookGetGuildNameJoke()
    -- Many native UI paths (including chat guild prefixes/labels) resolve the displayed guild name
    -- via GetGuildName(guildId). Hooking this is the most reliable way to affect those displays.
    if self._getGuildNameHooked then
        return true
    end

    local orig = _G.GetGuildName
    if type(orig) ~= "function" then
        return false
    end

    if self._getGuildNameWrapper and orig == self._getGuildNameWrapper then
        self._getGuildNameHooked = true
        return true
    end

    self._getGuildNameOriginal = orig
    self._getGuildNameWrapper = function(guildId, ...)
        local name = orig(guildId, ...)
        if ContainsRealGuildName(name) then
            return ReplaceRealWithJoke(name)
        end
        return name
    end
    _G.GetGuildName = self._getGuildNameWrapper

    self._getGuildNameHooked = true

    local log = self:_Log()
    if log and log.Debug then
        log:Debug("Seasonal display hook enabled: GetGuildName() ({from} -> {to})", {
            from = GUILD_NAME_REAL,
            to = GUILD_NAME_JOKE,
        })
    end

    return true
end

function Seasonal:_TryHookClaimedKeepGuildNameJoke()
    -- Keep tooltips and keep-summary panels resolve the claimed guild through
    -- GetClaimedKeepGuildName(keepId, bgQueryType). Hooking this keeps the
    -- claimed-owner display local to addon users only.
    if self._claimedKeepGuildNameHooked then
        return true
    end

    local orig = _G.GetClaimedKeepGuildName
    if type(orig) ~= "function" then
        return false
    end

    if self._claimedKeepGuildNameWrapper and orig == self._claimedKeepGuildNameWrapper then
        self._claimedKeepGuildNameHooked = true
        return true
    end

    self._claimedKeepGuildNameOriginal = orig
    self._claimedKeepGuildNameWrapper = function(keepId, bgQueryType, ...)
        local guildName = orig(keepId, bgQueryType, ...)
        if ContainsRealGuildName(guildName) then
            return ReplaceRealWithJoke(guildName)
        end
        return guildName
    end
    _G.GetClaimedKeepGuildName = self._claimedKeepGuildNameWrapper

    self._claimedKeepGuildNameHooked = true
    return true
end

function Seasonal:_TryHookKeepClaimAnnouncementJoke()
    -- Center-screen keep-claim announcements pass the guild name into helper
    -- formatter functions rather than resolving it via GetClaimedKeepGuildName.
    if self._keepClaimAnnouncementHooked then
        return true
    end

    self._keepClaimAnnouncementState = self._keepClaimAnnouncementState or {}

    local function WrapAnnouncementFormatter(globalName)
        local original = _G[globalName]
        if type(original) ~= "function" then
            return false
        end

        local state = self._keepClaimAnnouncementState[globalName]
        if state and original == state.wrapper then
            return true
        end

        local wrapper = function(campaignId, keepId, guildName, ...)
            if ContainsRealGuildName(guildName) then
                guildName = ReplaceRealWithJoke(guildName)
            end
            return original(campaignId, keepId, guildName, ...)
        end

        self._keepClaimAnnouncementState[globalName] = {
            original = original,
            wrapper = wrapper,
        }
        _G[globalName] = wrapper
        return true
    end

    local hookedClaim = WrapAnnouncementFormatter("GetClaimKeepCampaignEventDescription")
    local hookedRelease = WrapAnnouncementFormatter("GetReleaseKeepCampaignEventDescription")
    local hookedLost = WrapAnnouncementFormatter("GetLostKeepCampaignEventDescription")

    self._keepClaimAnnouncementHooked = hookedClaim or hookedRelease or hookedLost
    return self._keepClaimAnnouncementHooked == true
end

function Seasonal:_TryHookKeybindStripJoke()
    -- Some UI surfaces (like KEYBIND_STRIP) render label text independently of chat/guild selector.
    -- Hook the setup function so any descriptor name containing the guild name is rewritten.
    if self._keybindStripHooked then
        return true
    end

    local setupFn = _G.ZO_KeybindStripButtonTemplate_Setup
    if type(setupFn) ~= "function" then
        return false
    end

    if self._keybindStripWrapper and setupFn == self._keybindStripWrapper then
        self._keybindStripHooked = true
        return true
    end

    self._keybindStripOriginal = setupFn
    self._keybindStripWrapper = function(button, data, ...)
        local renderData = data
        if type(data) == "table" and ContainsRealGuildName(data.name) then
            -- Only change display text and avoid mutating the shared descriptor.
            renderData = ShallowCopy(data)
            renderData.name = ReplaceRealWithJoke(data.name)
        end

        local r1, r2, r3 = setupFn(button, renderData, ...)

        -- Best-effort patch of the already-rendered label controls (template differences across UI versions).
        if button and button.GetNamedChild then
            local nameLabel = button:GetNamedChild("Name") or button:GetNamedChild("Label") or button:GetNamedChild("Text")
            if nameLabel and nameLabel.GetText and nameLabel.SetText then
                local t = nameLabel:GetText()
                if ContainsRealGuildName(t) then
                    nameLabel:SetText(ReplaceRealWithJoke(t))
                end
            end
        end

        return r1, r2, r3
    end
    _G.ZO_KeybindStripButtonTemplate_Setup = self._keybindStripWrapper

    self._keybindStripHooked = true
    return true
end

function Seasonal:_TryHookTradingHouseTitleJoke()
    -- Trading House titles and footers resolve their selected guild through
    -- GetCurrentTradingHouseGuildDetails(), which bypasses GetGuildName().
    -- Wrap only the returned display string so the override stays client-side.
    if self._tradingHouseHooked then
        return true
    end

    local orig = _G.GetCurrentTradingHouseGuildDetails
    if type(orig) ~= "function" then
        return false
    end

    if self._tradingHouseWrapper and orig == self._tradingHouseWrapper then
        self._tradingHouseHooked = true
        return true
    end

    self._tradingHouseOriginal = orig
    self._tradingHouseWrapper = function(...)
        local results = packArgs(orig(...))
        if ContainsRealGuildName(results[2]) then
            results[2] = ReplaceRealWithJoke(results[2])
        end
        return unpackArgs(results, 1, results.n)
    end
    _G.GetCurrentTradingHouseGuildDetails = self._tradingHouseWrapper

    self._tradingHouseHooked = true
    return true
end

function Seasonal:_RewriteAddonControlTree(root, transform)
    if not root or type(transform) ~= "function" then
        return false
    end

    local visited = 0
    local maxNodes = 1200
    local any = false
    local queue = { root }
    local qHead = 1

    while qHead <= #queue do
        local control = queue[qHead]
        qHead = qHead + 1
        visited = visited + 1

        if visited > maxNodes then
            break
        end

        if control and control.GetText and control.SetText then
            local ok, current = pcall(control.GetText, control)
            if ok and type(current) == "string" and current ~= "" then
                local rewritten = transform(current)
                if rewritten ~= current then
                    pcall(control.SetText, control, rewritten)
                    any = true
                end
            end
        end

        if control and control.GetNumChildren and control.GetChild then
            local okN, childCount = pcall(control.GetNumChildren, control)
            if okN and type(childCount) == "number" then
                for i = 1, childCount do
                    local okChild, child = pcall(control.GetChild, control, i)
                    if okChild and child then
                        queue[#queue + 1] = child
                    end
                end
            end
        end
    end

    return any
end

function Seasonal:_RefreshAddonVisualText()
    local any = false
    local roots = {
        Addon and Addon.UI and Addon.UI.window,
        Addon and Addon.panel,
        Addon and Addon.Settings and Addon.Settings.panel,
    }

    for _, root in ipairs(roots) do
        if self:_RewriteAddonControlTree(root, ReplaceRealWithJoke) then
            any = true
        end
    end

    local headerTitle = _G["NMGuildHall_HeaderTitleTop"]
    if headerTitle and headerTitle.SetText and type(GetString) == "function" and _G.NMGH_NAME ~= nil then
        pcall(headerTitle.SetText, headerTitle, GetString(_G.NMGH_NAME))
        any = true
    end

    return any
end

function Seasonal:_RestoreAddonVisualText()
    local roots = {
        Addon and Addon.UI and Addon.UI.window,
        Addon and Addon.panel,
        Addon and Addon.Settings and Addon.Settings.panel,
    }

    for _, root in ipairs(roots) do
        self:_RewriteAddonControlTree(root, ReplaceJokeWithReal)
    end

    local headerTitle = _G["NMGuildHall_HeaderTitleTop"]
    if headerTitle and headerTitle.SetText and type(GetString) == "function" and _G.NMGH_NAME ~= nil then
        pcall(headerTitle.SetText, headerTitle, GetString(_G.NMGH_NAME))
    end
end

function Seasonal:_TransformVisibleGuildNameText(text, shouldJoke)
    if shouldJoke then
        return ReplaceRealWithJoke(text)
    end
    return ReplaceJokeWithReal(text)
end

function Seasonal:_RewriteVisibleGuildNameTree(root, shouldJoke)
    if not root then
        return false
    end

    return self:_RewriteAddonControlTree(root, function(text)
        return self:_TransformVisibleGuildNameText(text, shouldJoke)
    end)
end

function Seasonal:_RefreshControlText(control, shouldJoke)
    if not (control and control.GetText and control.SetText) then
        return false
    end

    local ok, current = pcall(control.GetText, control)
    if not ok or type(current) ~= "string" or current == "" then
        return false
    end

    local rewritten = self:_TransformVisibleGuildNameText(current, shouldJoke)
    if rewritten ~= current then
        pcall(control.SetText, control, rewritten)
        return true
    end
    return false
end

function Seasonal:_RefreshGuildSelectorVisibleState(shouldJoke)
    if self._guildSelectorHooked then
        self:_RefreshGuildSelectorVisibleText(shouldJoke)
        return
    end

    local label = _G["ZO_GuildSelectorComboBoxSelectedItemText"]
    self:_RefreshControlText(label, shouldJoke)
end

function Seasonal:_RefreshGuildRosterDisplays(shouldJoke)
    local manager = _G.GUILD_ROSTER_MANAGER
    if type(manager) == "table" then
        local guildId = type(manager.GetGuildId) == "function" and manager:GetGuildId() or manager.guildId
        if guildId ~= nil then
            manager.guildName = GetGuildName(guildId)
            if type(manager.RefreshAll) == "function" then
                pcall(manager.RefreshAll, manager)
            elseif type(manager.RefreshVisible) == "function" then
                pcall(manager.RefreshVisible, manager)
            end
        end
    end

    local keyboard = _G.GUILD_ROSTER_KEYBOARD
    if type(keyboard) == "table" and type(keyboard.RefreshVisible) == "function" then
        pcall(keyboard.RefreshVisible, keyboard)
    end
    self:_RewriteVisibleGuildNameTree(keyboard and keyboard.control, shouldJoke)

    local gamepad = _G.GUILD_ROSTER_GAMEPAD
    if type(gamepad) == "table" then
        if type(manager) == "table" then
            if type(manager.GetGuildName) == "function" then
                gamepad.guildName = manager:GetGuildName()
            end
            if type(manager.GetGuildAlliance) == "function" then
                gamepad.guildAlliance = manager:GetGuildAlliance()
            end
        end
        if type(gamepad.RefreshTooltip) == "function" then
            pcall(gamepad.RefreshTooltip, gamepad)
        end
    end
    self:_RewriteVisibleGuildNameTree(gamepad and gamepad.control, shouldJoke)
end

function Seasonal:_RefreshGuildRecruitmentDisplays(shouldJoke)
    local keyboard = _G.GUILD_RECRUITMENT_KEYBOARD
    if type(keyboard) == "table" and keyboard.guildId ~= nil then
        if type(keyboard.RefreshGuildPermissionsState) == "function" then
            pcall(keyboard.RefreshGuildPermissionsState, keyboard)
        elseif type(keyboard.SetGuildId) == "function" then
            pcall(keyboard.SetGuildId, keyboard, keyboard.guildId)
        end
    end
    self:_RewriteVisibleGuildNameTree(keyboard and keyboard.control, shouldJoke)

    local gamepad = _G.GUILD_RECRUITMENT_GAMEPAD
    if type(gamepad) == "table" and gamepad.guildId ~= nil then
        if type(gamepad.RefreshGuildListingView) == "function" then
            pcall(gamepad.RefreshGuildListingView, gamepad)
        end
        if type(gamepad.RefreshGuildPermissionsState) == "function" then
            pcall(gamepad.RefreshGuildPermissionsState, gamepad)
        end
        if type(gamepad.IsSceneShown) == "function" and gamepad:IsSceneShown() then
            if type(gamepad.RefreshRecruitmentList) == "function" then
                pcall(gamepad.RefreshRecruitmentList, gamepad)
            end
            if type(gamepad.ShowCurrentCategory) == "function" then
                pcall(gamepad.ShowCurrentCategory, gamepad)
            end
            if type(gamepad.RefreshKeybinds) == "function" then
                pcall(gamepad.RefreshKeybinds, gamepad)
            end
        end
    end
    self:_RewriteVisibleGuildNameTree(gamepad and gamepad.control, shouldJoke)
end

function Seasonal:_RefreshGuildBankDisplays(shouldJoke)
    local guildId = type(GetSelectedGuildBankId) == "function" and GetSelectedGuildBankId() or nil

    local gamepad = _G.GAMEPAD_GUILD_BANK
    if type(gamepad) == "table" then
        if type(gamepad.RefreshHeaderData) == "function" then
            pcall(gamepad.RefreshHeaderData, gamepad)
        elseif type(gamepad.RefreshGuildBank) == "function" then
            pcall(gamepad.RefreshGuildBank, gamepad)
        end
    end
    self:_RewriteVisibleGuildNameTree(gamepad and gamepad.control, shouldJoke)

    if guildId ~= nil and _G.ZO_GUILD_NAME_FOOTER_FRAGMENT and type(_G.ZO_GUILD_NAME_FOOTER_FRAGMENT.SetGuildName) == "function" then
        pcall(_G.ZO_GUILD_NAME_FOOTER_FRAGMENT.SetGuildName, _G.ZO_GUILD_NAME_FOOTER_FRAGMENT, GetGuildName(guildId))
    end

    local inventory = _G.PLAYER_INVENTORY
    if type(inventory) == "table" then
        if type(inventory.UpdateList) == "function" and type(_G.INVENTORY_GUILD_BANK) == "number" then
            local UPDATE_EVEN_IF_HIDDEN = true
            pcall(inventory.UpdateList, inventory, _G.INVENTORY_GUILD_BANK, UPDATE_EVEN_IF_HIDDEN)
        end

        if _G.GUILD_BANK_FRAGMENT and type(_G.GUILD_BANK_FRAGMENT.IsShowing) == "function" and _G.GUILD_BANK_FRAGMENT:IsShowing() then
            if KEYBIND_STRIP and type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
                if inventory.guildBankWithdrawTabKeybindButtonGroup then
                    pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, inventory.guildBankWithdrawTabKeybindButtonGroup)
                end
                if inventory.guildBankDepositTabKeybindButtonGroup then
                    pcall(KEYBIND_STRIP.UpdateKeybindButtonGroup, KEYBIND_STRIP, inventory.guildBankDepositTabKeybindButtonGroup)
                end
            end
        end
    end
    self:_RewriteVisibleGuildNameTree(inventory and inventory.control, shouldJoke)
end

function Seasonal:_RefreshTradingHouseDisplays(shouldJoke)
    local tradingHouse = _G.TRADING_HOUSE
    if type(tradingHouse) == "table" then
        if type(tradingHouse.UpdateForGuildChange) == "function" then
            pcall(tradingHouse.UpdateForGuildChange, tradingHouse)
        end
        self:_RefreshControlText(tradingHouse.titleLabel, shouldJoke)
        self:_RewriteVisibleGuildNameTree(tradingHouse.control, shouldJoke)
    end

    local gamepadTradingHouse = _G.GAMEPAD_TRADING_HOUSE
    if type(gamepadTradingHouse) == "table" then
        if type(gamepadTradingHouse.RefreshHeader) == "function" then
            pcall(gamepadTradingHouse.RefreshHeader, gamepadTradingHouse)
        end
        if type(gamepadTradingHouse.RefreshGuildNameFooter) == "function" then
            pcall(gamepadTradingHouse.RefreshGuildNameFooter, gamepadTradingHouse)
        end
        self:_RewriteVisibleGuildNameTree(gamepadTradingHouse.control, shouldJoke)
    end

    local ags = _G.AwesomeGuildStore
    if type(ags) == "table" and type(ags.internal) == "table" then
        local wrapper = ags.internal.tradingHouseWrapper
        if type(wrapper) == "table" then
            local selector = wrapper.guildSelector
            if type(selector) == "table" then
                self:_RefreshControlText(selector.titleLabel, shouldJoke)
                self:_RefreshControlText(selector.selectedItemText, shouldJoke)
                self:_RewriteVisibleGuildNameTree(selector.guildSelector, shouldJoke)
            end

            if type(wrapper.tradingHouse) == "table" then
                self:_RewriteVisibleGuildNameTree(wrapper.tradingHouse.control, shouldJoke)
            end
        end
    end

    local agsRoots = {
        _G.AwesomeGuildStoreGuilds,
        _G.AwesomeGuildStoreGuildTraders,
    }
    for _, root in ipairs(agsRoots) do
        self:_RewriteVisibleGuildNameTree(root, shouldJoke)
    end
end

function Seasonal:_RefreshKeepDisplays(shouldJoke)
    local systems = _G.SYSTEMS
    if systems and type(systems.GetObject) == "function" then
        local keepInfo = systems:GetObject("world_map_keep_info")
        if type(keepInfo) == "table" and type(keepInfo.GetKeepUpgradeObject) == "function" then
            local keepUpgradeObject = keepInfo:GetKeepUpgradeObject()
            if keepUpgradeObject and type(keepUpgradeObject.SetBGQueryType) == "function" and type(ZO_WorldMap_GetBattlegroundQueryType) == "function" then
                pcall(keepUpgradeObject.SetBGQueryType, keepUpgradeObject, ZO_WorldMap_GetBattlegroundQueryType())
            end
        end
    end

    local tooltips = {
        _G.ZO_KeepTooltip,
        _G.ZO_KeepTooltip_Gamepad,
    }

    for _, tooltip in ipairs(tooltips) do
        if tooltip and tooltip.IsHidden and not tooltip:IsHidden() and type(tooltip.RefreshKeepInfo) == "function" then
            pcall(tooltip.RefreshKeepInfo, tooltip)
        end
        self:_RewriteVisibleGuildNameTree(tooltip, shouldJoke)
    end
end

function Seasonal:_RefreshSeasonalGuildNameDisplays(forceAll)
    local config = self:GetConfig()
    local nativeShouldJoke = not forceAll and config.nativeGuildUi ~= false
    local traderShouldJoke = not forceAll and config.traderUi ~= false
    local keepShouldJoke = not forceAll and config.keepOwnership ~= false

    self:_RefreshGuildSelectorVisibleState(nativeShouldJoke)
    self:_RefreshGuildRosterDisplays(nativeShouldJoke)
    self:_RefreshGuildRecruitmentDisplays(nativeShouldJoke)
    self:_RefreshGuildBankDisplays(nativeShouldJoke)

    if self._addonVisualStringJokeApplied == true then
        self:_RefreshAddonVisualText()
    else
        self:_RestoreAddonVisualText()
    end

    self:_RefreshTradingHouseDisplays(traderShouldJoke)

    self:_RefreshKeepDisplays(keepShouldJoke)
end

function Seasonal:_ApplyAddonVisualStringJoke()
    self._addonVisualStringOriginals = self._addonVisualStringOriginals or {}
    self._addonVisualStringJokeApplied = true

    for _, name in ipairs(ADDON_STRING_ID_NAMES) do
        local current = ReadStringValueByName(name)
        if ContainsRealGuildName(current) then
            if self._addonVisualStringOriginals[name] == nil then
                self._addonVisualStringOriginals[name] = current
            end
            WriteStringValueByName(name, ReplaceRealWithJoke(current))
        end
    end

    local addonConstants = Addon and Addon.Constants and Addon.Constants.ADDON
    if addonConstants then
        local currentDisplayName = addonConstants.DISPLAY_NAME
        if ContainsRealGuildName(currentDisplayName) then
            if self._addonVisualConstantsOriginalDisplayName == nil then
                self._addonVisualConstantsOriginalDisplayName = currentDisplayName
            end
            addonConstants.DISPLAY_NAME = ReplaceRealWithJoke(currentDisplayName)
        end
    end

    if Addon and ContainsRealGuildName(Addon.displayName) then
        if self._addonOriginalDisplayName == nil then
            self._addonOriginalDisplayName = Addon.displayName
        end
        Addon.displayName = ReplaceRealWithJoke(Addon.displayName)
    end

    self:_RefreshAddonVisualText()
end

function Seasonal:_RestoreAddonVisualStringJoke()
    self._addonVisualStringJokeApplied = false

    if self._addonVisualStringOriginals then
        for name, original in pairs(self._addonVisualStringOriginals) do
            if type(original) == "string" and original ~= "" then
                WriteStringValueByName(name, original)
            end
        end
    end

    local addonConstants = Addon and Addon.Constants and Addon.Constants.ADDON
    if addonConstants and type(self._addonVisualConstantsOriginalDisplayName) == "string" then
        addonConstants.DISPLAY_NAME = self._addonVisualConstantsOriginalDisplayName
    end

    if Addon and type(self._addonOriginalDisplayName) == "string" then
        Addon.displayName = self._addonOriginalDisplayName
    end

    self:_RestoreAddonVisualText()
end

function Seasonal:_UnhookTradingHouseTitleJoke()
    if type(self._tradingHouseOriginal) == "function"
        and type(self._tradingHouseWrapper) == "function"
        and _G.GetCurrentTradingHouseGuildDetails == self._tradingHouseWrapper then
        _G.GetCurrentTradingHouseGuildDetails = self._tradingHouseOriginal
    end
    self._tradingHouseOriginal = nil
    self._tradingHouseWrapper = nil
    self._tradingHouseHooked = false
end

function Seasonal:_StartKeybindStripJokeRetry()
    if self._keybindStripHooked or self._keybindStripRetryActive then
        return
    end
    self._keybindStripRetryActive = true

    local attemptsLeft = 60
    local function tick()
        if self._keybindStripHooked then
            self._keybindStripRetryActive = false
            return
        end
        attemptsLeft = attemptsLeft - 1
        if attemptsLeft < 0 then
            self._keybindStripRetryActive = false
            return
        end

        self:_TryHookKeybindStripJoke()

        if not self._keybindStripHooked and zo_callLater then
            self._keybindStripRetryCallId = zo_callLater(tick, 500)
        else
            self._keybindStripRetryActive = false
        end
    end

    tick()
end

function Seasonal:_UnhookKeybindStripJoke()
    if self._keybindStripRetryCallId ~= nil and zo_removeCallLater then
        pcall(zo_removeCallLater, self._keybindStripRetryCallId)
    end
    self._keybindStripRetryCallId = nil
    self._keybindStripRetryActive = false

    if type(self._keybindStripOriginal) == "function"
        and type(self._keybindStripWrapper) == "function"
        and _G.ZO_KeybindStripButtonTemplate_Setup == self._keybindStripWrapper then
        _G.ZO_KeybindStripButtonTemplate_Setup = self._keybindStripOriginal
    end
    self._keybindStripOriginal = nil
    self._keybindStripWrapper = nil
    self._keybindStripHooked = false
end

function Seasonal:_StartGuildSelectorJokeRetry()
    if (self._guildSelectorHooked and self._guildSelectorRewroteVisible == true) or self._guildSelectorRetryActive then
        return
    end
    self._guildSelectorRetryActive = true

    local attemptsLeft = 30
    local function tick()
        if self._guildSelectorHooked and self._guildSelectorRewroteVisible == true then
            self._guildSelectorRetryActive = false
            return
        end
        attemptsLeft = attemptsLeft - 1
        if attemptsLeft < 0 then
            self._guildSelectorRetryActive = false
            return
        end
        self:_TryHookGuildSelectorJoke()
        if self._guildSelectorHooked then
            self:_RefreshGuildSelectorVisibleText(true)
        end
        if (not self._guildSelectorHooked or self._guildSelectorRewroteVisible ~= true) and zo_callLater then
            self._guildSelectorRetryCallId = zo_callLater(tick, 1000)
        else
            self._guildSelectorRetryActive = false
        end
    end

    tick()
end

function Seasonal:_UnhookGuildSelectorJoke()
    if self._guildSelectorRetryCallId ~= nil and zo_removeCallLater then
        pcall(zo_removeCallLater, self._guildSelectorRetryCallId)
    end
    self._guildSelectorRetryCallId = nil
    self._guildSelectorRetryActive = false

    local comboBox = self._guildSelectorComboBox
    if comboBox and comboBox._nmghNeilHooked and type(comboBox._nmghNeilOrig) == "function"
        and comboBox.SetSelectedItemText == comboBox._nmghNeilWrapper then
        comboBox.SetSelectedItemText = comboBox._nmghNeilOrig
    end
    if comboBox then
        comboBox._nmghNeilOrig = nil
        comboBox._nmghNeilWrapper = nil
        comboBox._nmghNeilHooked = nil
    end
    if comboBox and type(comboBox._nmghNeilOrigAddItem) == "function"
        and comboBox.AddItem == comboBox._nmghNeilAddItemWrapper then
        comboBox.AddItem = comboBox._nmghNeilOrigAddItem
    end
    if comboBox then
        comboBox._nmghNeilOrigAddItem = nil
        comboBox._nmghNeilAddItemWrapper = nil
    end
    if comboBox and type(comboBox._nmghNeilOrigClearItems) == "function"
        and comboBox.ClearItems == comboBox._nmghNeilClearItemsWrapper then
        comboBox.ClearItems = comboBox._nmghNeilOrigClearItems
    end
    if comboBox then
        comboBox._nmghNeilOrigClearItems = nil
        comboBox._nmghNeilClearItemsWrapper = nil
        comboBox._nmghNeilRowIndex = nil
    end

    self._guildSelectorComboBox = nil
    self._guildSelectorHooked = false
    self._guildSelectorRewroteVisible = false

    -- Best-effort revert current visible label.
    local label = _G["ZO_GuildSelectorComboBoxSelectedItemText"]
    if label and label.GetText and label.SetText then
        local current = label:GetText()
        if type(current) == "string" and current ~= "" then
            label:SetText(ReplaceJokeWithReal(current))
        end
    end
end

function Seasonal:_RestoreChatFormatterGuildNameJoke()
    if self._chatFormatterGuildNameRetryCallId ~= nil and zo_removeCallLater then
        pcall(zo_removeCallLater, self._chatFormatterGuildNameRetryCallId)
    end
    self._chatFormatterGuildNameRetryCallId = nil
    self._chatFormatterGuildNameRetryActive = false

    if self._chatFormatterGuildNameState then
        for formatterKey, state in pairs(self._chatFormatterGuildNameState) do
            if type(state) == "table" and type(state.original) == "function" and type(state.wrapper) == "function" then
                local formatters = CHAT_ROUTER and type(CHAT_ROUTER.GetRegisteredMessageFormatters) == "function" and CHAT_ROUTER:GetRegisteredMessageFormatters() or nil
                if type(formatters) == "table" and formatters[formatterKey] == state.wrapper then
                    self:_SetChatFormatter(formatterKey, state.original)
                end
            end
        end
    end

    self._chatFormatterGuildNameState = nil
    self._chatFormatterGuildNameHooked = false
    self._chatFormatterGuildNameLogged = false
end

function Seasonal:_RestoreChannelInfoGuildNameJoke()
    if not self._channelInfoGuildNameOriginals or type(ZO_ChatSystem_GetChannelInfo) ~= "function" then
        self._channelInfoGuildNamePatched = false
        self._channelInfoGuildNameLogged = false
        return
    end

    local channelInfo = ZO_ChatSystem_GetChannelInfo()
    if type(channelInfo) == "table" then
        for channelId, original in pairs(self._channelInfoGuildNameOriginals) do
            local entry = channelInfo[channelId]
            if type(entry) == "table" then
                entry.name = original.name
                entry.dynamicName = original.dynamicName
            end
        end
    end

    self._channelInfoGuildNameOriginals = nil
    self._channelInfoGuildNamePatched = false
    self._channelInfoGuildNameLogged = false
end

function Seasonal:_UnhookGetGuildNameJoke()
    if type(self._getGuildNameOriginal) == "function"
        and type(self._getGuildNameWrapper) == "function"
        and _G.GetGuildName == self._getGuildNameWrapper then
        _G.GetGuildName = self._getGuildNameOriginal
    end
    self._getGuildNameOriginal = nil
    self._getGuildNameWrapper = nil
    self._getGuildNameHooked = false
end

function Seasonal:_UnhookClaimedKeepGuildNameJoke()
    if type(self._claimedKeepGuildNameOriginal) == "function"
        and type(self._claimedKeepGuildNameWrapper) == "function"
        and _G.GetClaimedKeepGuildName == self._claimedKeepGuildNameWrapper then
        _G.GetClaimedKeepGuildName = self._claimedKeepGuildNameOriginal
    end
    self._claimedKeepGuildNameOriginal = nil
    self._claimedKeepGuildNameWrapper = nil
    self._claimedKeepGuildNameHooked = false
end

function Seasonal:_UnhookKeepClaimAnnouncementJoke()
    local names = {
        "GetClaimKeepCampaignEventDescription",
        "GetReleaseKeepCampaignEventDescription",
        "GetLostKeepCampaignEventDescription",
    }

    for _, globalName in ipairs(names) do
        local state = self._keepClaimAnnouncementState and self._keepClaimAnnouncementState[globalName]
        if state and type(state.original) == "function" and type(state.wrapper) == "function"
            and _G[globalName] == state.wrapper then
            _G[globalName] = state.original
        end
    end

    self._keepClaimAnnouncementState = nil
    self._keepClaimAnnouncementHooked = false
end

function Seasonal:_StopAllEffects()
    self:_RestoreAddonVisualStringJoke()
    self:_RestoreChatFormatterGuildNameJoke()
    self:_RestoreChannelInfoGuildNameJoke()
    self:_UnhookGetGuildNameJoke()
    self:_UnhookClaimedKeepGuildNameJoke()
    self:_UnhookKeepClaimAnnouncementJoke()
    self:_UnhookGuildSelectorJoke()
    self:_UnhookKeybindStripJoke()
    self:_UnhookTradingHouseTitleJoke()
    self:_RefreshSeasonalGuildNameDisplays(true)
end

-- Apply any seasonal tweaks. Safe to call multiple times.
function Seasonal:Apply()
    local prevKey = self.activeKey
    local prevEvent = self.activeEvent

    if not self:IsEnabled() then
        self.activeKey = nil
        self.activeEvent = nil
        if prevEvent then
            self:_InvokeEventCallback(prevEvent, "onLeave")
        else
            self:_StopAllEffects()
        end
        return nil
    end

    -- Re-evaluate every time Apply is called so callers don't need to track timing.
    local ev = self:EvaluateActiveEvent()

    if prevKey ~= self.activeKey then
        if prevEvent then
            self:_InvokeEventCallback(prevEvent, "onLeave")
        end
        if ev then
            self:_InvokeEventCallback(ev, "onEnter")
        end
    end

    if ev then
        self:_InvokeEventCallback(ev, "apply")
    elseif prevEvent then
        self:_StopAllEffects()
    end

    return ev
end

function Seasonal:Cleanup()
    if self.activeEvent then
        self:_InvokeEventCallback(self.activeEvent, "onLeave")
    else
        self:_StopAllEffects()
    end
    self.activeKey = nil
    self.activeEvent = nil
    self.initialized = false

    local log = self:_Log()
    if log and log.Debug then
        log:Debug("Seasonal module cleaned up")
    end
end

-- Export module
Addon.Seasonal = Seasonal

-- Birthday behavior: swap the displayed guild selector name as a joke.
DEFAULT_EVENTS.misfitsBirthday.apply = function(_, addon)
    if not (addon and addon.Seasonal) then
        return
    end

    local seasonal = addon.Seasonal
    local config = seasonal.GetConfig and seasonal:GetConfig() or {}

    if config.ownUi ~= false then
        seasonal:_ApplyAddonVisualStringJoke()
        seasonal:_StartKeybindStripJokeRetry()
    else
        seasonal:_RestoreAddonVisualStringJoke()
        seasonal:_UnhookKeybindStripJoke()
    end

    if config.nativeGuildUi ~= false then
        seasonal:_ApplyChannelInfoGuildNameJoke()
        seasonal:_StartGuildSelectorJokeRetry()
        seasonal:_TryHookGetGuildNameJoke()
    else
        seasonal:_RestoreChannelInfoGuildNameJoke()
        seasonal:_UnhookGuildSelectorJoke()
        seasonal:_UnhookGetGuildNameJoke()
    end

    if config.keepOwnership ~= false then
        seasonal:_TryHookClaimedKeepGuildNameJoke()
        seasonal:_TryHookKeepClaimAnnouncementJoke()
    else
        seasonal:_UnhookClaimedKeepGuildNameJoke()
        seasonal:_UnhookKeepClaimAnnouncementJoke()
    end

    if config.traderUi ~= false then
        seasonal:_TryHookTradingHouseTitleJoke()
    else
        seasonal:_UnhookTradingHouseTitleJoke()
    end

    if config.chatMessages ~= false then
        seasonal:_ApplyChatFormatterGuildNameJoke()
        seasonal:_StartChatFormatterGuildNameJokeRetry()
    else
        seasonal:_RestoreChatFormatterGuildNameJoke()
    end

    seasonal:_RefreshSeasonalGuildNameDisplays(false)
end
DEFAULT_EVENTS.misfitsBirthday.onLeave = function(_, addon)
    if addon and addon.Seasonal and addon.Seasonal._StopAllEffects then
        addon.Seasonal:_StopAllEffects()
    end
end

return Seasonal