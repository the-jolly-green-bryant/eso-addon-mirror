local NAME = "AchievementDateFormatter"

-- Format definitions: each entry describes a component ORDER and PADDING.
-- Components: YYYY=4-digit year, MM=zero-padded month, DD=zero-padded day,
--             M=month (no padding), D=day (no padding)
local FORMATS = {
    { key = "YYYYMMDD", parts = { "YYYY", "MM", "DD" } },
    { key = "YYYYMD",   parts = { "YYYY", "M",  "D"  } },
    { key = "DDMMYYYY", parts = { "DD",   "MM", "YYYY" } },
    { key = "DMYYYY",   parts = { "D",    "M",  "YYYY" } },
    { key = "MMDDYYYY", parts = { "MM",   "DD", "YYYY" } },
    { key = "MDYYYY",   parts = { "M",    "D",  "YYYY" } }
}

local FORMAT_MAP = {}
for _, f in ipairs(FORMATS) do FORMAT_MAP[f.key] = f end

local SEPARATORS = {
    { key = "-",      label = "Hyphen  ( - )" },
    { key = "/",      label = "Slash  ( / )" },
    { key = ".",      label = "Dot  ( . )" },
    { key = ",",      label = "Comma  ( , )" },
    { key = " ",      label = "Space" },
    { key = "",       label = "None" },
    { key = "custom", label = "Custom..." },
}

local DEFAULTS = {
    formatKey      = "DDMMYYYY",
    separatorKey   = "/",
    customSeparator = "",
}

local db

local function ComponentValue(comp, month, day, year)
    if comp == "YYYY" then return string.format("%04d", year)
    elseif comp == "MM" then return string.format("%02d", month)
    elseif comp == "DD" then return string.format("%02d", day)
    elseif comp == "M"  then return tostring(month)
    elseif comp == "D"  then return tostring(day)
    end
    return ""
end

local function AssembleDate(month, day, year, sep, formatKey)
    local fmt = FORMAT_MAP[formatKey] or FORMAT_MAP[DEFAULTS.formatKey]
    local parts = {}
    for _, comp in ipairs(fmt.parts) do
        table.insert(parts, ComponentValue(comp, month, day, year))
    end
    return table.concat(parts, sep)
end

local function GetSeparator()
    if db.separatorKey == "custom" then return db.customSeparator end
    return db.separatorKey
end

local function ReformatDate(dateStr)
    if not dateStr or dateStr == "" then return dateStr end
    local m, d, y = dateStr:match("^(%d+)/(%d+)/(%d+)$")
    if not m then return dateStr end
    return AssembleDate(tonumber(m), tonumber(d), tonumber(y), GetSeparator(), db.formatKey)
end

local function RefreshVisible()
    if not ACHIEVEMENTS or not ACHIEVEMENTS.achievementPool then return end
    for _, achievement in pairs(ACHIEVEMENTS.achievementPool:GetActiveObjects()) do
        if achievement.achievementId and achievement.date then
            local _, _, _, _, completed, date = GetAchievementInfo(achievement.achievementId)
            if completed and date and date ~= "" then
                achievement.date:SetText(ReformatDate(date))
            end
        end
    end
end

local function SetupSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local clientLang = GetCVar("language.2")
    local isEnglish  = clientLang == "en"

    local formatChoices, formatValues = {}, {}
    for _, f in ipairs(FORMATS) do
        local pattern = table.concat(f.parts, "-")
        local example = AssembleDate(6, 30, 2026, "-", f.key)
        table.insert(formatChoices, pattern .. "  (" .. example .. ")")
        table.insert(formatValues, f.key)
    end

    local sepChoices, sepValues = {}, {}
    for _, s in ipairs(SEPARATORS) do
        table.insert(sepChoices, s.label)
        table.insert(sepValues, s.key)
    end

    local panelData = {
        type        = "panel",
        name        = "Achievement Date Formatter",
        displayName = "Achievement Date Formatter",
        author      = "justinsane16",
        version     = "1.1",
        registerForRefresh = true,
    }

    local optionsData = {}

    if not isEnglish then
        table.insert(optionsData, {
            type = "description",
            text = "|cffff6600Warning: This addon reformats dates from the English (EN) client date format (M/D/YYYY). "
                .. "Your client language is '" .. clientLang .. "'. "
                .. "Dates in the Achievements menu may not be reformatted correctly.|r",
        })
    end

    table.insert(optionsData, {
        type          = "dropdown",
        name          = "Date Format",
        tooltip       = "The order and zero-padding of date components.",
        choices       = formatChoices,
        choicesValues = formatValues,
        scrollable    = true,
        getFunc       = function() return db.formatKey end,
        setFunc       = function(value) db.formatKey = value; RefreshVisible() end,
        default       = DEFAULTS.formatKey,
    })

    table.insert(optionsData, {
        type          = "dropdown",
        name          = "Separator",
        tooltip       = "The character inserted between date components.",
        choices       = sepChoices,
        choicesValues = sepValues,
        getFunc       = function() return db.separatorKey end,
        setFunc       = function(value) db.separatorKey = value; RefreshVisible() end,
        default       = DEFAULTS.separatorKey,
    })

    table.insert(optionsData, {
        type     = "editbox",
        name     = "Custom Separator",
        tooltip  = "Your custom separator text. Only used when 'Custom...' is selected above.",
        disabled = function() return db.separatorKey ~= "custom" end,
        getFunc  = function() return db.customSeparator end,
        setFunc  = function(value) db.customSeparator = value; RefreshVisible() end,
        default  = DEFAULTS.customSeparator,
    })

    LAM:RegisterAddonPanel("AchievementDateFormatterPanel", panelData)
    LAM:RegisterOptionControls("AchievementDateFormatterPanel", optionsData)
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= NAME then return end
    EVENT_MANAGER:UnregisterForEvent(NAME, EVENT_ADD_ON_LOADED)

    db = ZO_SavedVars:NewAccountWide("AchievementDateFormatter_SavedVars", 1, nil, DEFAULTS)

    SetupSettingsMenu()

    ZO_PostHook(Achievement, "Show", function(self, achievementId)
        if not self.date or self.date:IsHidden() then return end
        local _, _, _, _, _, date = GetAchievementInfo(achievementId)
        if date and date ~= "" then
            self.date:SetText(ReformatDate(date))
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)