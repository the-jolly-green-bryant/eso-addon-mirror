-- CharacterMarkdown - Settings Command Handlers
-- Settings manipulation, get/set, reset, and panel management

local CM = CharacterMarkdown
CM.commands = CM.commands or {}
CM.commands.settings = {}

-- =====================================================
-- SETTINGS HANDLERS
-- =====================================================

local function HandleSettings(args)
    CM.DebugPrint("COMMANDS", "HandleSettings called")

    -- Open settings panel
    if not LibAddonMenu2 then
        CM.Error("Settings panel not available - LibAddonMenu-2.0 is required")
        CM.Info("To install LibAddonMenu-2.0:")
        CM.Info("  Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html")
        return
    end

    -- Use the /markdownsettings command that LAM registered for our panel
    local lamHandler = SLASH_COMMANDS["/markdown_settings"]
    if lamHandler and type(lamHandler) == "function" then
        lamHandler("")
        CM.DebugPrint("COMMANDS", "Opened settings via /markdownsettings LAM handler")
    else
        -- Fallback: Try LibAddonMenu2's OpenToPanel
        local panelId = CM.Settings and CM.Settings.Panel and CM.Settings.Panel.panelId or "CharacterMarkdownPanel"
        if LibAddonMenu2.OpenToPanel then
            LibAddonMenu2:OpenToPanel(panelId)
            CM.DebugPrint("COMMANDS", "Opened settings panel via LAM:OpenToPanel")
        else
            -- Last resort: Open Add-Ons category and show instructions
            SCENE_MANAGER:Show("gameMenuInGame")
            PlaySound(SOUNDS.MENU_SHOW)
            zo_callLater(function()
                local mainMenu = SYSTEMS:GetObject("mainMenu")
                if mainMenu and mainMenu.ShowCategory and MENU_CATEGORY_ADDONS then
                    pcall(function()
                        mainMenu:ShowCategory(MENU_CATEGORY_ADDONS)
                    end)
                end
                CM.Info("Please select 'Character Markdown' from the Add-Ons list")
            end, 100)
        end
    end
end

local function HandleSettingsShow(args)
    -- Use debug module's function
    if CM.commands.debug and CM.commands.debug.DebugSavedVarsState then
        CM.commands.debug.DebugSavedVarsState()
    else
        CM.Error("Debug module not loaded")
    end
end

local function HandleSettingsGet(args)
    if not args or args == "" then
        CM.Error("Usage: /markdown settings get <key>")
        CM.Info("Example: /markdown settings get includeChampionPoints")
        return
    end

    local key = args:match("^%s*(%S+)")
    if not key then
        CM.Error("Invalid key")
        return
    end

    -- Get defaults to validate key exists
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    if defaults[key] == nil then
        CM.Error("Unknown setting: " .. key)
        CM.Info("Settings must be defined in defaults")
        return
    end

    -- Get raw and merged values
    local rawValue = CharacterMarkdownSettings and CharacterMarkdownSettings[key] or nil
    local mergedValue = CM.GetSettings()[key]

    CM.Info("Setting: " .. key)
    CM.Info("  Type: " .. type(defaults[key]))
    CM.Info("  Default: " .. tostring(defaults[key]))
    CM.Info("  Raw (SavedVariables): " .. tostring(rawValue))
    CM.Info("  Merged (Current): " .. tostring(mergedValue))
end

local function HandleSettingsSet(args)
    if not args or args == "" then
        CM.Error("Usage: /markdown settings set <key> <value>")
        CM.Info("Example: /markdown settings set includeChampionPoints true")
        return
    end

    local key, valueStr = args:match("^%s*(%S+)%s+(.+)$")
    if not key or not valueStr then
        CM.Error("Invalid format. Use: /markdown settings set <key> <value>")
        return
    end

    -- Get defaults to validate key and type
    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    if defaults[key] == nil then
        CM.Error("Unknown setting: " .. key)
        return
    end

    local expectedType = type(defaults[key])
    local value

    -- Convert value to correct type
    if expectedType == "boolean" then
        value = (valueStr:lower() == "true" or valueStr:lower() == "1" or valueStr:lower() == "yes")
    elseif expectedType == "number" then
        value = tonumber(valueStr)
        if not value then
            CM.Error("Invalid number: " .. valueStr)
            return
        end
    elseif expectedType == "string" then
        value = valueStr
    else
        CM.Error("Unsupported type: " .. expectedType)
        return
    end

    -- Set value
    if not CharacterMarkdownSettings then
        CM.Error("Settings not available")
        return
    end

    CharacterMarkdownSettings[key] = value
    CharacterMarkdownSettings._lastModified = GetTimeStamp()
    CM.InvalidateSettingsCache()

    CM.Success("Setting updated: " .. key .. " = " .. tostring(value))
end

local function HandleSettingsReset(args)
    if not CharacterMarkdownSettings then
        CM.Error("Settings not available")
        return
    end

    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    local count = 0

    -- CRITICAL: Preserve only text fields (customNotes, customTitle, playStyle) for current character
    local characterId = tostring(GetCurrentCharacterId())
    local preservedTextFields = nil
    if CharacterMarkdownSettings.perCharacterData and CharacterMarkdownSettings.perCharacterData[characterId] then
        preservedTextFields = {
            customNotes = CharacterMarkdownSettings.perCharacterData[characterId].customNotes,
            customTitle = CharacterMarkdownSettings.perCharacterData[characterId].customTitle,
            playStyle = CharacterMarkdownSettings.perCharacterData[characterId].playStyle,
        }
    end

    -- Reset all settings to defaults (preserve internal metadata and per-character data)
    for key, defaultValue in pairs(defaults) do
        if key:sub(1, 1) ~= "_" and key ~= "perCharacterData" then
            CharacterMarkdownSettings[key] = defaultValue
            count = count + 1
        end
    end

    -- Restore only the text fields for current character
    if preservedTextFields then
        if not CharacterMarkdownSettings.perCharacterData then
            CharacterMarkdownSettings.perCharacterData = {}
        end
        if not CharacterMarkdownSettings.perCharacterData[characterId] then
            CharacterMarkdownSettings.perCharacterData[characterId] = {}
        end
        CharacterMarkdownSettings.perCharacterData[characterId].customNotes = preservedTextFields.customNotes
        CharacterMarkdownSettings.perCharacterData[characterId].customTitle = preservedTextFields.customTitle
        CharacterMarkdownSettings.perCharacterData[characterId].playStyle = preservedTextFields.playStyle
    end

    CharacterMarkdownSettings._lastModified = GetTimeStamp()
    CM.InvalidateSettingsCache()

    CM.Success("Reset " .. count .. " settings to defaults (text fields preserved)")
end

local function HandleSettingsEnableAll(args)
    if not CharacterMarkdownSettings then
        CM.Error("Settings not available")
        return
    end

    local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}
    local count = 0

    -- Enable all boolean settings
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "boolean" and key:sub(1, 1) ~= "_" then
            CharacterMarkdownSettings[key] = true
            count = count + 1
        end
    end

    CharacterMarkdownSettings._lastModified = GetTimeStamp()
    CM.InvalidateSettingsCache()

    CM.Success("Enabled " .. count .. " boolean settings")
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.commands.settings.HandleSettings = HandleSettings
CM.commands.settings.HandleSettingsShow = HandleSettingsShow
CM.commands.settings.HandleSettingsGet = HandleSettingsGet
CM.commands.settings.HandleSettingsSet = HandleSettingsSet
CM.commands.settings.HandleSettingsReset = HandleSettingsReset
CM.commands.settings.HandleSettingsEnableAll = HandleSettingsEnableAll

CM.DebugPrint("COMMANDS", "Settings commands module loaded")
