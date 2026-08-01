-- cChat_Settings.lua
-- Settings UI using LibAddonMenu-2.0

function cChat.InitializeSettings()
    local LAM = LibAddonMenu2

    if not LAM then
        return
    end

    -- Create settings panel
    local panelData = {
        type = "panel",
        name = "cChat",
        displayName = "cChat - Console Chat",
        author = "tzammy_",
        version = cChat.version,
        registerForRefresh = true,
    }

    LAM:RegisterAddonPanel("cChat_Settings", panelData)

    -- Settings options
    local optionsData = {
        -- Timestamp Section Header
        {
            type = "header",
            name = "Timestamp Settings",
        },
        {
            type = "description",
            text = "Configure how timestamps are displayed in chat messages.",
        },
        -- Show Timestamps Toggle
        {
            type = "checkbox",
            name = "Show Timestamps",
            tooltip = "Add timestamps to all chat messages",
            getFunc = function() return cChat.settings.showTimestamps end,
            setFunc = function(value)
                cChat.settings.showTimestamps = value
                if value then
                    d("cChat: Timestamps enabled")
                else
                    d("cChat: Timestamps disabled")
                end
            end,
            default = cChat.defaults.showTimestamps,
        },
        -- 24-Hour Format Toggle
        {
            type = "checkbox",
            name = "Use 24-Hour Format",
            tooltip = "Use 24-hour time format (14:30) instead of 12-hour format (2:30 PM)",
            getFunc = function() return cChat.settings.use24HourFormat end,
            setFunc = function(value)
                cChat.settings.use24HourFormat = value
                local format = value and "24-hour" or "12-hour"
                d("cChat: Time format set to " .. format)
            end,
            disabled = function() return not cChat.settings.showTimestamps end,
            default = cChat.defaults.use24HourFormat,
        },

        -- Chat History Section Header
        {
            type = "header",
            name = "Chat History Settings",
        },
        {
            type = "description",
            text = "Configure chat history restoration. When enabled, chat messages will be saved and restored when you log in.",
        },
        -- Enable History Toggle
        {
            type = "checkbox",
            name = "Enable Chat History",
            tooltip = "Save chat messages and restore them when you log in",
            getFunc = function() return cChat.settings.enableHistory end,
            setFunc = function(value)
                cChat.settings.enableHistory = value
                if value then
                    d("cChat: Chat history enabled")
                else
                    d("cChat: Chat history disabled")
                end
            end,
            default = cChat.defaults.enableHistory,
        },
        -- Max History Lines Slider
        {
            type = "slider",
            name = "Maximum History Lines",
            tooltip = "Maximum number of chat messages to store (higher values use more memory)",
            min = 100,
            max = 600,
            step = 100,
            getFunc = function() return cChat.settings.maxHistoryLines end,
            setFunc = function(value)
                cChat.settings.maxHistoryLines = value
                d("cChat: Maximum history set to " .. value .. " lines")
            end,
            disabled = function() return not cChat.settings.enableHistory end,
            default = cChat.defaults.maxHistoryLines,
        },
        -- Current History Count Display
        {
            type = "description",
            text = function()
                local count = cChat.History.GetCount()
                local max = cChat.settings.maxHistoryLines
                return string.format("Current history: %d / %d messages", count, max)
            end,
        },
        -- Clear History Button
        {
            type = "button",
            name = "Clear Chat History",
            tooltip = "Delete all stored chat history",
            func = function()
                cChat.History.Clear()
                d("cChat: Chat history cleared")
            end,
            disabled = function() return not cChat.settings.enableHistory end,
            warning = "This will permanently delete all stored chat messages!",
        },

        -- Information Section
        {
            type = "header",
            name = "Information",
        },
        {
            type = "description",
            text = "cChat v" .. cChat.version .. " - A console-friendly chat enhancement addon.\n\n" ..
                   "Slash Commands:\n" ..
                   "  /cchat - Show help\n" ..
                   "  /cchat toggle - Toggle timestamps\n" ..
                   "  /cchat clear - Clear history\n" ..
                   "  /cchat count - Show message count",
        },
    }

    LAM:RegisterOptionControls("cChat_Settings", optionsData)
end
