-- Core Addon Table
MemoryGarbageCollector = {
    name = "MemoryGarbageCollector",
    version = "1.1.3",
    author = "|cbf16b9NeBioNik|r [@BioNik12]",

    fullName = "Memory Garbage Collector",
    shortName = "MGC",
    prefix = "|cbf16b9[MGC]|r",

    -- Cleanup threshold
    maxMemoryUsage = 0,

    chat = nil,

    color = {
        main = "bf16b9",
        grey = "666666",
    },

    -- Saved variables configuration
    svName = "MemoryGarbageCollectorSV",
    svVersion = 1,
    config = {}
}

local EM = EVENT_MANAGER
local MGC = MemoryGarbageCollector

local MaxMemoryUsage = MGC.maxMemoryUsage
local ChatColor = MGC.color

local DEFAULT_SAVED_VARS = {
    autoClear = true,
    refreshRate = 10, -- minutes
    comparisonMethod = 1,
    overflowRelative = 10, -- percent
    overflowAbsolute = 50, -- MB
    showDebugMessages = false,
    silentMode = false,
}

local SF = string.format

-- GetFormattedString
local GFS = function(STR_NAME, ...)
    return SF(GetString(STR_NAME), ...)
end

function MGC.Initialize()
    MGC.config = ZO_SavedVars:NewAccountWide(MGC.svName, MGC.svVersion, nil, DEFAULT_SAVED_VARS)

    MGC.InitMenu()

    -- Start with 15 sec delay and calculate starting memory usage.
    zo_callLater(function()
        MGC.refreshSettings()
    end, 15000)
end

function MGC.InitMenu()
    local config = MGC.config

    local LAM = LibAddonMenu2
    local panelName = MGC.name .. "_LAM"

    local panelData = {
        type = "panel",
        name = MGC.fullName,
        author = MGC.author,
        version = MGC.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "description",
            text = GFS(SI_MGC_ADDON_DESCRIPTION),
        },
        {
            type = "divider",
            alpha = 0.4,
        },
        {
            type = "checkbox",
            name = GFS(SI_MGC_AUTO_CLEAR),
            tooltip = GFS(SI_MGC_AUTO_CLEAR_TOOLTIP),
            getFunc = function()
                return config.autoClear
            end,
            setFunc = function(v)
                config.autoClear = v
                MGC.refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.autoClear,
        },
        {
            type = "slider",
            name = GFS(SI_MGC_REFRESH_RATE),
            tooltip = GFS(SI_MGC_REFRESH_RATE_TOOLTIP),
            min = 1,
            max = 60,
            decimals = 0,
            disabled = function()
                return not config.autoClear
            end,
            getFunc = function()
                return config.refreshRate
            end,
            setFunc = function(v)
                config.refreshRate = v
                MGC.refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.refreshRate,
        },
        {
            type = "dropdown",
            name = GFS(SI_MGC_COMPARISON_METHOD),
            tooltip = GFS(SI_MGC_COMPARISON_METHOD_TOOLTIP),
            disabled = function()
                return not config.autoClear
            end,
            getFunc = function()
                return config.comparisonMethod
            end,
            setFunc = function(v)
                config.comparisonMethod = v
                MGC.refreshSettings()
            end,
            choicesValues = { 1, 2 },
            choices = { GFS(SI_MGC_OVERFLOW_RELATIVE), GFS(SI_MGC_OVERFLOW_ABSOLUTE) },
            default = DEFAULT_SAVED_VARS.comparisonMethod,
        },
        {
            type = "slider",
            name = GFS(SI_MGC_OVERFLOW_RELATIVE),
            tooltip = GFS(SI_MGC_OVERFLOW_RELATIVE_TOOLTIP),
            min = 5,
            max = 50,
            step = 5,
            decimals = 0,
            disabled = function()
                return not (config.autoClear and config.comparisonMethod == 1)
            end,
            getFunc = function()
                return config.overflowRelative
            end,
            setFunc = function(v)
                config.overflowRelative = v
                MGC.refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.overflowRelative,
        },
        {
            type = "slider",
            name = GFS(SI_MGC_OVERFLOW_ABSOLUTE),
            tooltip = GFS(SI_MGC_OVERFLOW_ABSOLUTE_TOOLTIP),
            min = 30,
            max = 500,
            step = 25,
            decimals = 0,
            disabled = function()
                return not (config.autoClear and config.comparisonMethod == 2)
            end,
            getFunc = function()
                return config.overflowAbsolute
            end,
            setFunc = function(v)
                config.overflowAbsolute = v
                MGC.refreshSettings()
            end,
            default = DEFAULT_SAVED_VARS.overflowAbsolute,
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = GetString(SI_MGC_SHOW_DEBUG_MESSAGES),
            disabled = function()
                return config.silentMode
            end,
            getFunc = function()
                return config.showDebugMessages
            end,
            setFunc = function(v)
                config.showDebugMessages = v
            end,
            default = DEFAULT_SAVED_VARS.showDebugMessages,
        },
        {
            type = "checkbox",
            name = "Silent Mode",
            tooltip = GetString(SI_MGC_SILENT_MODE),
            getFunc = function()
                return config.silentMode
            end,
            setFunc = function(v)
                config.silentMode = v
            end,
            default = DEFAULT_SAVED_VARS.silentMode,
        },
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)
end

function MGC.refreshSettings()
    MGC.calcMaxMemory()
    MGC.setRefreshTimer()
end

function MGC.setRefreshTimer()
    local eventName = MGC.name .. "_Auto"
    EVENT_MANAGER:UnregisterForUpdate(eventName)

    if MGC.config.autoClear == true then
        local refreshSeconds = MGC.config.refreshRate * 60 * 1000 -- min to seconds
        EVENT_MANAGER:RegisterForUpdate(eventName, refreshSeconds, function()
            MGC.checkGarbage()
        end)
    end
end

function MGC.calcMaxMemory(memory)
    if not MGC.config.autoClear then
        return
    end

    if not memory then
        memory = MGC.currentMemory()
    end

    local max = 1024
    if MGC.config.comparisonMethod == 1 then
        max = memory * (1 + MGC.config.overflowRelative / 100)
    else
        max = memory + MGC.config.overflowAbsolute
    end

    -- Round to 5 MB
    max = math.ceil(max / 5) * 5

    MGC.sendDebugMessage(GFS(SI_MGC_MEMORY_INIT_MAX, max))
    MaxMemoryUsage = max
end

function MGC.currentMemory()
    return math.ceil(collectgarbage("count") / 1024)
end

function MGC.checkGarbage()
    if IsUnitInCombat("player") then
        return
    end

    local limit = MaxMemoryUsage or 1024;
    local current = MGC.currentMemory()

    -- Check currently used memory for overflow limit.
    MGC.sendDebugMessage(GFS(SI_MGC_MEMORY_OVERFLOW_DEBUG, current, limit))

    if current <= limit then
        return
    end

    -- Run garbage collect when overflow is reached.
    collectgarbage("collect")

    local after = MGC.currentMemory()
    MGC.calcMaxMemory(after)

    MGC.chatMessage(GFS(SI_MGC_MEMORY_OVERFLOW_REACHED, current, after, current - after))
end

-- Send message to game chat
function MGC.chatMessage(message)
    -- Do not send anything when silentMode on.
    if MGC.config.silentMode then
        return
    end

    if LibChatMessage then
        if not MGC.chat then
            MGC.chat = LibChatMessage(MGC.shortName, MGC.shortName)
        end

        local formatted = SF("|c%s[%s]|r %s", ChatColor.grey, GetTimeString(), message)
        MGC.chat:SetTagColor(ChatColor.main):Printf(formatted)
    else
        local formatted = SF("%s |c%s[%s]|r %s", MGC.prefix, ChatColor.grey, GetTimeString(), message)
        CHAT_SYSTEM:AddMessage(formatted)
    end
end

-- Send debug message to game chat
function MGC.sendDebugMessage(message)
    if MGC.config.showDebugMessages then
        MGC.chatMessage(message)
    end
end

-- Addon Initialize
EM:RegisterForEvent(MGC.name, EVENT_ADD_ON_LOADED, function(_, name)
    if name == MGC.name then
        MGC.Initialize()

        EM:UnregisterForEvent(MGC.name, EVENT_ADD_ON_LOADED)
    end
end)
