local DLV = DebugLogViewer
local LDL = LibDebugLogger
local LAM = LibAddonMenu2

local internal = DLV.internal
local gettext = internal.gettext

local LOG_LEVEL_VERBOSE = LDL.LOG_LEVEL_VERBOSE
local LOG_LEVEL_DEBUG = LDL.LOG_LEVEL_DEBUG
local LOG_LEVEL_INFO = LDL.LOG_LEVEL_INFO
local LOG_LEVEL_WARNING = LDL.LOG_LEVEL_WARNING
local LOG_LEVEL_ERROR = LDL.LOG_LEVEL_ERROR

local FADE_MODE_TIMER = 1
local FADE_MODE_VISIBLE = 2
local FADE_MODE_HIDDEN = 3

internal.FADE_MODE_TIMER = FADE_MODE_TIMER
internal.FADE_MODE_VISIBLE = FADE_MODE_VISIBLE
internal.FADE_MODE_HIDDEN = FADE_MODE_HIDDEN

local LEVEL_TO_LOCALIZED_STRING = internal.LEVEL_TO_LOCALIZED_STRING

do
    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local logWidth, logHeight = 460, 160
    local logOffsetX, logOffsetY = screenWidth - logWidth, screenHeight - logHeight
    local viewerWidth, viewerHeight = 930, 500
    local viewerOffsetX, viewerOffsetY = (screenWidth - viewerWidth) / 2, (screenHeight - viewerHeight) / 2

    internal.DEFAULT_SETTINGS = {
        version = 1,
        quickLog = {
            enabled = true,
            window = {
                x = logOffsetX,
                y = logOffsetY,
                width = logWidth,
                height = logHeight,
                locked = true
            },
            color = {
                [LOG_LEVEL_VERBOSE] = {0.60, 0.60, 0.60, 1.00}, -- 0x999999
                [LOG_LEVEL_DEBUG] = {0.46, 1.00, 1.00, 1.00}, -- 0x75FFFF
                [LOG_LEVEL_INFO] = {1.00, 1.00, 0.46, 1.00}, -- 0xFFFF75
                [LOG_LEVEL_WARNING] = {1.00, 0.60, 0.46, 1.00}, -- 0xFF9A75
                [LOG_LEVEL_ERROR] = {1.00, 0.46, 0.46, 1.00}, -- 0xFF7575
            },
            backgroundFade = {
                mode = FADE_MODE_TIMER,
                timeout = 3,
                duration = 0.35,
            },
            lineFade = {
                mode = FADE_MODE_TIMER,
                timeout = 10,
                duration = 1,
                clearBuffer = true,
            },
            historyLength = 400,
            fontSize = 12,
            levelFilter = {
                [LOG_LEVEL_VERBOSE] = true,
                [LOG_LEVEL_DEBUG] = true,
                [LOG_LEVEL_INFO] = false,
                [LOG_LEVEL_WARNING] = false,
                [LOG_LEVEL_ERROR] = false,
            },
            tagFilter = "LibDebugLogger",
            timeFilter = internal.TIME_FILTER_SESSION,
        },
        logViewer = {
            window = {
                x = viewerOffsetX,
                y = viewerOffsetY,
            },
            color = {
                [LOG_LEVEL_VERBOSE] = {0.60, 0.60, 0.60, 1.00}, -- 0x999999
                [LOG_LEVEL_DEBUG] = {0.46, 1.00, 1.00, 1.00}, -- 0x75FFFF
                [LOG_LEVEL_INFO] = {1.00, 1.00, 0.46, 1.00}, -- 0xFFFF75
                [LOG_LEVEL_WARNING] = {1.00, 0.60, 0.46, 1.00}, -- 0xFF9A75
                [LOG_LEVEL_ERROR] = {1.00, 0.46, 0.46, 1.00}, -- 0xFF7575
            },
            levelFilter = {
                [LOG_LEVEL_VERBOSE] = false,
                [LOG_LEVEL_DEBUG] = false,
                [LOG_LEVEL_INFO] = false,
                [LOG_LEVEL_WARNING] = false,
                [LOG_LEVEL_ERROR] = false,
            },
            tagFilter = "",
            tagFilterIsBlacklist = false,
            timeFilter = internal.TIME_FILTER_SESSION,
        }
    }
end
local DEFAULT_SETTINGS = internal.DEFAULT_SETTINGS

local function RefreshQuickLog()
    internal:FireCallbacks(internal.callback.REFRESH_QUICK_LOG)
end

local function RefreshLogViewer()
    internal:FireCallbacks(internal.callback.REFRESH_LOG_VIEWER)
end

local function CreateQuickLogLevelFilterSection(optionsData, saveData, level)
    local levelLabel = LEVEL_TO_LOCALIZED_STRING[level]
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = levelLabel,
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("When enabled, the quick log will show <<1>> messages.", levelLabel),
        width = "half",
        getFunc = function() return not saveData.quickLog.levelFilter[level] end,
        setFunc = function(value)
            saveData.quickLog.levelFilter[level] = not value
            RefreshQuickLog()
        end,
        default = not DEFAULT_SETTINGS.quickLog.levelFilter[level],
    }
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Text Color"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The color used for <<1>> messages.", levelLabel),
        width = "half",
        getFunc = function() return unpack(saveData.quickLog.color[level]) end,
        setFunc = function(r, g, b, a)
            saveData.quickLog.color[level] = {r, g, b, a}
            RefreshQuickLog()
        end,
        default = ZO_ColorDef:New(unpack(DEFAULT_SETTINGS.quickLog.color[level])), -- need to provide a table with keys. ZO_ColorDef happens to fit the requirements
    }
end

local function CreateLogViewerColorSetting(optionsData, saveData, level)
    local levelLabel = LEVEL_TO_LOCALIZED_STRING[level]
    optionsData[#optionsData + 1] = {
        type = "colorpicker",
        width = "half",
        name = levelLabel,
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The color used for <<1>> messages.", levelLabel),
        width = "half",
        getFunc = function() return unpack(saveData.logViewer.color[level]) end,
        setFunc = function(r, g, b, a)
            saveData.logViewer.color[level] = {r, g, b, a}
            RefreshLogViewer()
        end,
        default = ZO_ColorDef:New(unpack(DEFAULT_SETTINGS.logViewer.color[level])), -- need to provide a table with keys. ZO_ColorDef happens to fit the requirements
    }
end

local function CreateSettingsDialog(saveData)
    local panelId = "DebugLogViewerOptions"

    local panelData = {
        type = "panel",
        -- TRANSLATORS: Title of the settings panel. Shouldn't really need a translation
        name = gettext("Debug Log Viewer"),
        author = "sirinsidiator",
        version = "1.2.0.697",
        website = "https://www.esoui.com/downloads/info2389-DebugLogViewer.html",
        feedback = "https://www.esoui.com/portal.php?id=218&a=bugreport",
        donation = "https://www.esoui.com/downloads/info2389-DebugLogViewer.html#donate",
        registerForRefresh = true,
        registerForDefaults = true
    }
    local panel = LAM:RegisterAddonPanel(panelId, panelData)

    local optionsData = {}

    optionsData[#optionsData + 1] = {
        type = "checkbox",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Quick Log"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("When enabled, a log panel will show the latest messages."),
        getFunc = function() return saveData.quickLog.enabled end,
        setFunc = function(value)
            if(value) then
                internal.quickLog:Show()
            else
                internal.quickLog:Hide()
            end
        end,
        default = DEFAULT_SETTINGS.quickLog.enabled,
    }

    local quickLogSubmenuData = {}

    optionsData[#optionsData + 1] = {
        type = "submenu",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Quick Log"),
        disabled = function() return not saveData.quickLog.enabled end,
        controls = quickLogSubmenuData
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "editbox",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Tag Filter"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The logger tags that should be hidden in the quick log. Each line represents one tag"),
        isMultiline = true,
        getFunc = function()
            return saveData.quickLog.tagFilter
        end,
        setFunc = function(text)
            saveData.quickLog.tagFilter = text
            RefreshQuickLog()
        end,
        default = DEFAULT_SETTINGS.quickLog.tagFilter,
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "header",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Log Levels"),
    }

    for i = 1, #LDL.LOG_LEVELS do
        local level = LDL.LOG_LEVELS[i]
        CreateQuickLogLevelFilterSection(quickLogSubmenuData, saveData, level)
    end

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "button",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Copy Log Viewer Colors"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("This will apply the colors used for the log viewer to the quick log."),
        func = function()
            ZO_DeepTableCopy(saveData.logViewer.color, saveData.quickLog.color)
            RefreshQuickLog()
        end,
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "header",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Background"),
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "dropdown",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Mode"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("Controls how the background of the quick log will behave."),
        choices = {
            -- TRANSLATORS: label for when the specified component fades out on a timer
            gettext("Timer"),
            -- TRANSLATORS: label for when the specified component is always hidden
            gettext("Hidden"),
            -- TRANSLATORS: label for when the specified component is always visible
            gettext("Visible")
        },
        choicesValues = {FADE_MODE_TIMER, FADE_MODE_HIDDEN, FADE_MODE_VISIBLE},
        choicesTooltips = {
            -- TRANSLATORS: tooltip for when the specified component fades out on a timer
            gettext("Fade out after the time specified below"),
            -- TRANSLATORS: tooltip for when the specified component is always hidden
            gettext("Never show"),
            -- TRANSLATORS: tooltip for when the specified component is always visible
            gettext("Always show")
        },
        getFunc = function() return saveData.quickLog.backgroundFade.mode end,
        setFunc = function(value)
            saveData.quickLog.backgroundFade.mode = value
            internal.quickLog:UpdateBackgroundFade()
        end,
        default = DEFAULT_SETTINGS.quickLog.backgroundFade.mode,
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "slider",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Fade Timeout"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The time it takes before the background and scroll bar start fading out"),
        min = 0.1,
        max = 60,
        decimals = 2,
        clampFunction = function(value, min, max)
            return math.max(min, value)
        end,
        getFunc = function()
            return saveData.quickLog.backgroundFade.timeout
        end,
        setFunc = function(value)
            saveData.quickLog.backgroundFade.timeout = value
            internal.quickLog:UpdateBackgroundFade()
        end,
        default = DEFAULT_SETTINGS.quickLog.backgroundFade.timeout,
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "slider",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Fade Duration"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The time it takes for the background and scroll bar to fade out"),
        min = 0.1,
        max = 60,
        decimals = 2,
        clampFunction = function(value, min, max)
            return math.max(min, value)
        end,
        getFunc = function()
            return saveData.quickLog.backgroundFade.duration
        end,
        setFunc = function(value)
            saveData.quickLog.backgroundFade.duration = value
            internal.quickLog:UpdateBackgroundFade()
        end,
        default = DEFAULT_SETTINGS.quickLog.backgroundFade.duration,
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "header",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Log Lines"),
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "dropdown",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Mode"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("Controls how the lines of the quick log will behave."),
        choices = {
            gettext("Timer"),
            gettext("Visible")
        },
        choicesValues = {FADE_MODE_TIMER, FADE_MODE_VISIBLE},
        choicesTooltips = {
            gettext("The lines will fade out after the time specified below"),
            gettext("The lines will always be visible")
        },
        getFunc = function() return saveData.quickLog.lineFade.mode end,
        setFunc = function(value)
            saveData.quickLog.lineFade.mode = value
            internal.quickLog:UpdateLineFade()
        end,
        default = DEFAULT_SETTINGS.quickLog.lineFade.mode,
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "slider",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Fade Timeout"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The time it takes before the lines start fading out"),
        min = 0.1,
        max = 60,
        decimals = 2,
        clampFunction = function(value, min, max)
            return math.max(min, value)
        end,
        getFunc = function()
            return saveData.quickLog.lineFade.timeout
        end,
        setFunc = function(value)
            saveData.quickLog.lineFade.timeout = value
            internal.quickLog:UpdateLineFade()
        end,
        disabled = function()
            return saveData.quickLog.lineFade.mode ~= FADE_MODE_TIMER
        end,
        default = DEFAULT_SETTINGS.quickLog.lineFade.timeout,
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "slider",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Fade Duration"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The time it takes for the lines to fade out"),
        min = 0.1,
        max = 60,
        decimals = 2,
        clampFunction = function(value, min, max)
            return math.max(min, value)
        end,
        getFunc = function()
            return saveData.quickLog.lineFade.duration
        end,
        setFunc = function(value)
            saveData.quickLog.lineFade.duration = value
            internal.quickLog:UpdateLineFade()
        end,
        disabled = function()
            return saveData.quickLog.lineFade.mode ~= FADE_MODE_TIMER
        end,
        default = DEFAULT_SETTINGS.quickLog.lineFade.duration,
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "checkbox",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Clear After Fade Out"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("When enabled, messages will be cleared from the buffer after the lines have faded out."),
        getFunc = function() return saveData.quickLog.lineFade.clearBuffer end,
        setFunc = function(value)
            saveData.quickLog.lineFade.clearBuffer = value
            internal.quickLog:UpdateLineFade()
        end,
        disabled = function()
            return saveData.quickLog.lineFade.mode ~= FADE_MODE_TIMER
        end,
        default = not DEFAULT_SETTINGS.quickLog.lineFade.clearBuffer,
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "header",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Other"),
    }
    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "slider",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Font Size"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The size of the quick log entries"),
        min = 5,
        max = 50,
        getFunc = function()
            return saveData.quickLog.fontSize
        end,
        setFunc = function(value)
            saveData.quickLog.fontSize = value
            internal.quickLog:SetFontSize(value)
        end,
        default = DEFAULT_SETTINGS.quickLog.fontSize,
    }

    quickLogSubmenuData[#quickLogSubmenuData + 1] = {
        type = "slider",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("History Length"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The number of entries to be shown in the quick log"),
        min = 100,
        max = 1000,
        step = 100,
        getFunc = function()
            return saveData.quickLog.historyLength
        end,
        setFunc = function(value)
            saveData.quickLog.historyLength = value
            internal.quickLog:SetHistoryLength(value)
        end,
        default = DEFAULT_SETTINGS.quickLog.historyLength,
    }

    local logViewerSubmenuData = {}

    optionsData[#optionsData + 1] = {
        type = "submenu",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Log Viewer"),
        controls = logViewerSubmenuData
    }

    for i = 1, #LDL.LOG_LEVELS do
        local level = LDL.LOG_LEVELS[i]
        CreateLogViewerColorSetting(logViewerSubmenuData, saveData, level)
    end

    logViewerSubmenuData[#logViewerSubmenuData + 1] = {
        type = "button",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Copy Quick Log Colors"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("This will apply the colors used for the quick log to the log viewer."),
        func = function()
            ZO_DeepTableCopy(saveData.quickLog.color, saveData.logViewer.color)
            RefreshLogViewer()
        end,
    }

    local debugLoggerSubmenuData = {}

    optionsData[#optionsData + 1] = {
        type = "submenu",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("LibDebugLogger"),
        controls = debugLoggerSubmenuData
    }

    debugLoggerSubmenuData[#debugLoggerSubmenuData + 1] = {
        type = "checkbox",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Stack Traces"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("When enabled, LibDebugLogger will log stack traces for all messages."),
        getFunc = function() return LDL:IsTraceLoggingEnabled() end,
        setFunc = function(value) LDL:SetTraceLoggingEnabled(value) end,
        default = LDL.DEFAULT_SETTINGS.logTraces,
    }

    debugLoggerSubmenuData[#debugLoggerSubmenuData + 1] = {
        type = "dropdown",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Log Level"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        tooltip = gettext("The minimum level for logged messages."),
        choices = {
            LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_VERBOSE],
            LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_DEBUG],
            LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_INFO],
            LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_WARNING],
            LEVEL_TO_LOCALIZED_STRING[LDL.LOG_LEVEL_ERROR],
        },
        choicesValues = {
            LDL.LOG_LEVEL_VERBOSE,
            LDL.LOG_LEVEL_DEBUG,
            LDL.LOG_LEVEL_INFO,
            LDL.LOG_LEVEL_WARNING,
            LDL.LOG_LEVEL_ERROR
        },
        getFunc = function() return LDL:GetMinLogLevel() end,
        setFunc = function(value) LDL:SetMinLogLevel(value) end,
        default = LDL.DEFAULT_SETTINGS.minLogLevel,
    }

    debugLoggerSubmenuData[#debugLoggerSubmenuData + 1] = {
        type = "description",
        with = "half",
        text = function()
            local log = LDL:GetLog()
            -- TRANSLATORS: label for an entry in the addon settings
            return gettext("The debug log currently contains <<1[no entries/one entry/$d entries]>>.", #log)
        end,
    }

    debugLoggerSubmenuData[#debugLoggerSubmenuData + 1] = {
        type = "button",
        with = "half",
        -- TRANSLATORS: label for an entry in the addon settings
        name = gettext("Clear Log"),
        -- TRANSLATORS: tooltip text for an entry in the addon settings
        warning = gettext("This will remove all logged messages."),
        func = function() LDL:ClearLog() end,
        isDangerous = true
    }

    LAM:RegisterOptionControls(panelId, optionsData)

    DLV:RegisterCallback(internal.callback.OPEN_SETTINGS, function()
        LAM:OpenToPanel(panel)
    end)
end

local function RepairSettingsTable(saveData, defaultData)
    -- get rid of old entries that no longer exist
    for key, data in pairs(saveData) do
        if(defaultData[key] == nil) then
            saveData[key] = nil
        end
    end

    -- walk through all the defaults
    for key, data in pairs(defaultData) do
        if(type(data) == "table") then
            if(saveData[key]) then
                -- repair the existing data
                RepairSettingsTable(saveData[key], data)
            else
                -- otherwise just copy the missing table
                saveData[key] = ZO_DeepTableCopy(data)
            end
        elseif(saveData[key] == nil) then
            -- all other missing values are just copied
            saveData[key] = data
        end
    end
end

local function LoadSettings(tableName)
    _G[tableName] = _G[tableName] or {}
    local name = GetDisplayName()
    local world = GetWorldName()
    local key = world .. name

    if(_G[tableName][key]) then
        RepairSettingsTable( _G[tableName][key], DEFAULT_SETTINGS)
    else
        _G[tableName][key] = ZO_DeepTableCopy(DEFAULT_SETTINGS)
    end
    local saveData = _G[tableName][key]

    CreateSettingsDialog(saveData)

    return saveData
end

DLV.internal.LoadSettings = LoadSettings
