-- ChatLogPreserverSettings.lua: LibHarvensAddonSettings integration

local ChatLogPreserverSettings = {}

local function GetSettings()
    local state = ChatLogPreserver.state
    if not state or not state.savedVars then
        return nil
    end
    return state.savedVars.settings
end

local function ShowLogDialog()
    if ChatLogPreserver.LogDialog and ChatLogPreserver.LogDialog.Show then
        ChatLogPreserver.LogDialog:Show()
    end
end

function ChatLogPreserverSettings.ResetToDefaults()
    local state = ChatLogPreserver.state
    if not state or not state.savedVars or not state.settingsDefaults then
        return
    end

    local defaults = state.settingsDefaults
    local settings = state.savedVars.settings
    settings.enabled = defaults.enabled
    settings.maxEntries = defaults.maxEntries

    if ChatLogPreserver.Actions and ChatLogPreserver.Actions.EnforceMaxEntries then
        ChatLogPreserver.Actions.EnforceMaxEntries()
    end
end

function ChatLogPreserverSettings.Initialize()
    if not LibHarvensAddonSettings then
        return
    end

    local settings = GetSettings()
    local defaults = ChatLogPreserver.state and ChatLogPreserver.state.settingsDefaults
    if not settings or not defaults then
        return
    end

    local panel = LibHarvensAddonSettings:AddAddon("Chat Log Preserver", {
        allowDefaults = true,
        defaultsFunction = function()
            ChatLogPreserverSettings.ResetToDefaults()
        end,
        allowRefresh = true,
    })
    if not panel then
        return
    end

    panel.version = ChatLogPreserver.version

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "View Saved Log",
        buttonText = "Open",
        clickHandler = function()
            ShowLogDialog()
        end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = "Capture",
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = "Preserve Chat History",
        tooltip = "Save formatted chat lines so they can be restored after ReloadUI.",
        default = defaults.enabled,
        getFunction = function()
            return settings.enabled
        end,
        setFunction = function(value)
            settings.enabled = value
        end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_SLIDER,
        label = "Maximum Saved Lines",
        tooltip = "Trim saved history to this many lines.",
        min = 50,
        max = 1000,
        step = 10,
        default = defaults.maxEntries,
        getFunction = function()
            return settings.maxEntries
        end,
        setFunction = function(value)
            settings.maxEntries = value
            if ChatLogPreserver.Actions and ChatLogPreserver.Actions.EnforceMaxEntries then
                ChatLogPreserver.Actions.EnforceMaxEntries()
            end
        end,
    })

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Clear Saved Log",
        buttonText = "Clear",
        clickHandler = function()
            if ChatLogPreserver.Actions and ChatLogPreserver.Actions.ClearHistory then
                ChatLogPreserver.Actions.ClearHistory()
            end
        end,
    })
end

ChatLogPreserver.Settings = ChatLogPreserverSettings
