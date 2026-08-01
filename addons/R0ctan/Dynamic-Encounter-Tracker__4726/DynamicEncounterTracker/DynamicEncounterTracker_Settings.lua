local DE = DynamicEncounterTracker

local function L(key)
    return DE:T(key)
end

local function CopyColor(color)
    return color[1], color[2], color[3], color[4] or 1
end

local function SetColor(target, r, g, b, a)
    target[1] = r
    target[2] = g
    target[3] = b
    target[4] = a or 1
end

local function GetDefaultColor(color)
    return {
        r = color[1],
        g = color[2],
        b = color[3],
        a = color[4] or 1,
    }
end

function DE:RefreshSettingsPanel()
    if self.settingsPanel and self.settingsPanel.RefreshPanel then
        self.settingsPanel:RefreshPanel()
    end
end

function DE:RegisterSettingsPanelCallbacks()
    if self.settingsPanelCallbacksRegistered then
        return
    end

    self.settingsPanelOpenedCallback = function(panel)
        if panel ~= self.settingsPanel then
            return
        end
        self.settingsPanelOpen = true
        self:UpdateChestAlertPreview()
    end

    self.settingsPanelClosedCallback = function(panel)
        if panel ~= self.settingsPanel then
            return
        end
        self.settingsPanelOpen = false
        if self.centerAlertPreviewActive then
            self:HideCenterChestAlert()
        else
            self:ApplyChestAlertInteraction()
        end
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", self.settingsPanelOpenedCallback)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", self.settingsPanelClosedCallback)
    self.settingsPanelCallbacksRegistered = true
end

function DE:CreateSettings()
    local LAM = LibAddonMenu2

    local panelName = self.name .. "Options"
    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = "|cD6BD78" .. L("DE_ADDON_NAME") .. "|r",
        author = self.author,
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel(panelName, panelData)
    self:RegisterSettingsPanelCallbacks()

    local function DisabledWhenOff()
        return not self.sv.enabled
    end

    local function ChestHintsDisabled()
        return not self.sv.enabled or not self.sv.showChestHints
    end

    local function ChestWindowDisabled()
        return not self.sv.enabled
            or not self.sv.showChestHints
            or not self.sv.showCenterChestAlert
    end

    local function DiagnosticDisabled()
        return not self:HasDebugModule() or not self.sv.enabled or not self.sv.debugEnabled
    end

    local function UpdateStatusWindow()
        self:RefreshWindowLayout()
        self:RefreshUI()
    end

    local function UpdateChestPreview()
        self:ApplyAppearance()
        self:UpdateChestAlertPreview()
    end

    local statusContentControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_STATUS_CONTENT_DESC"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_STATUS_SHOW"),
            default = self.defaults.showWindow,
            getFunc = function() return self.sv.showWindow end,
            setFunc = function(value)
                self.sv.showWindow = value
                self:RefreshVisibility()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_STATUS_MOVABLE"),
            tooltip = L("DE_SETTINGS_STATUS_MOVABLE_TT"),
            default = not self.defaults.locked,
            getFunc = function() return not self.sv.locked end,
            setFunc = function(value)
                self.sv.locked = not value
                self:ApplyLockState()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_MINIMAL_MODE"),
            tooltip = L("DE_SETTINGS_MINIMAL_MODE_TT"),
            default = self.defaults.minimalMode,
            getFunc = function() return self.sv.minimalMode end,
            setFunc = function(value)
                self.sv.minimalMode = value
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_CLOSE_BUTTON"),
            tooltip = L("DE_SETTINGS_SHOW_CLOSE_BUTTON_TT"),
            default = self.defaults.showCloseButton,
            getFunc = function() return self.sv.showCloseButton end,
            setFunc = function(value)
                self.sv.showCloseButton = value
                self:ApplyLockState()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_MINIMAL_TOGGLE_BUTTON"),
            tooltip = L("DE_SETTINGS_SHOW_MINIMAL_TOGGLE_BUTTON_TT"),
            default = self.defaults.showMinimalToggleButton,
            getFunc = function() return self.sv.showMinimalToggleButton end,
            setFunc = function(value)
                self.sv.showMinimalToggleButton = value
                self:ApplyLockState()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_HIDE_MENUS"),
            tooltip = L("DE_SETTINGS_HIDE_MENUS_TT"),
            default = self.defaults.hideInMenus,
            getFunc = function() return self.sv.hideInMenus end,
            setFunc = function(value)
                self.sv.hideInMenus = value
                self:RefreshVisibility()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_WORLD_MAP"),
            tooltip = L("DE_SETTINGS_WORLD_MAP_TT"),
            default = self.defaults.showOnWorldMap,
            getFunc = function() return self.sv.showOnWorldMap end,
            setFunc = function(value)
                self.sv.showOnWorldMap = value
                self:RefreshVisibility()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_STEP"),
            tooltip = L("DE_SETTINGS_SHOW_STEP_TT"),
            default = self.defaults.showStepInStatus,
            getFunc = function() return self.sv.showStepInStatus end,
            setFunc = function(value)
                self.sv.showStepInStatus = value
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_STEP_PROGRESS"),
            tooltip = L("DE_SETTINGS_SHOW_STEP_PROGRESS_TT"),
            default = self.defaults.showStepProgressInStatus,
            getFunc = function() return self.sv.showStepProgressInStatus end,
            setFunc = function(value)
                self.sv.showStepProgressInStatus = value
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_PARTICIPATION"),
            tooltip = L("DE_SETTINGS_SHOW_PARTICIPATION_TT"),
            default = self.defaults.showParticipationInStatus,
            getFunc = function() return self.sv.showParticipationInStatus end,
            setFunc = function(value)
                self.sv.showParticipationInStatus = value
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_SECTION"),
            tooltip = L("DE_SETTINGS_SHOW_SECTION_TT"),
            default = self.defaults.showPhase,
            getFunc = function() return self.sv.showPhase end,
            setFunc = function(value)
                self.sv.showPhase = value
                if value then
                    self:RefreshParticipatingPhase()
                end
                UpdateStatusWindow()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_HINT"),
            tooltip = L("DE_SETTINGS_SHOW_HINT_TT"),
            default = self.defaults.showHintInStatusWindow,
            getFunc = function() return self.sv.showHintInStatusWindow end,
            setFunc = function(value)
                self.sv.showHintInStatusWindow = value
                UpdateStatusWindow()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
    }

    local statusAppearanceControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_STATUS_STYLE_DESC"),
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_TEXT_SIZE"),
            tooltip = L("DE_SETTINGS_TEXT_SIZE_TT"),
            min = 14,
            max = 28,
            step = 1,
            default = self.defaults.textSize,
            getFunc = function() return self.sv.textSize end,
            setFunc = function(value)
                self.sv.textSize = value
                self:ApplyAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_WINDOW_WIDTH"),
            tooltip = L("DE_SETTINGS_WINDOW_WIDTH_TT"),
            min = self.WINDOW_MIN_WIDTH,
            max = self.WINDOW_MAX_WIDTH,
            step = 10,
            default = self.defaults.size.width,
            getFunc = function() return self.sv.size.width end,
            setFunc = function(value)
                self:SetWindowWidth(value)
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_BACKGROUND_OPACITY"),
            tooltip = L("DE_SETTINGS_BACKGROUND_OPACITY_TT"),
            min = 0,
            max = 100,
            step = 1,
            default = self.defaults.backgroundOpacity * 100,
            getFunc = function() return self.sv.backgroundOpacity * 100 end,
            setFunc = function(value)
                self.sv.backgroundOpacity = value / 100
                self:ApplyAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_TITLE_COLOR"),
            tooltip = L("DE_SETTINGS_TITLE_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.title) end,
            getFunc = function() return CopyColor(self.sv.colors.title) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.title, r, g, b, a)
                self:ApplyAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_LABEL_COLOR"),
            tooltip = L("DE_SETTINGS_LABEL_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.label) end,
            getFunc = function() return CopyColor(self.sv.colors.label) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.label, r, g, b, a)
                self:ApplyAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_TEXT_COLOR"),
            tooltip = L("DE_SETTINGS_TEXT_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.value) end,
            getFunc = function() return CopyColor(self.sv.colors.value) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.value, r, g, b, a)
                self:ApplyAppearance()
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_UP_COLOR"),
            tooltip = L("DE_SETTINGS_UP_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.active) end,
            getFunc = function() return CopyColor(self.sv.colors.active) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.active, r, g, b, a)
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RESPAWN_COLOR"),
            tooltip = L("DE_SETTINGS_RESPAWN_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.cooldown) end,
            getFunc = function() return CopyColor(self.sv.colors.cooldown) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.cooldown, r, g, b, a)
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_UNKNOWN_COLOR"),
            tooltip = L("DE_SETTINGS_UNKNOWN_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.unknown) end,
            getFunc = function() return CopyColor(self.sv.colors.unknown) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.unknown, r, g, b, a)
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_FRAME_COLOR"),
            tooltip = L("DE_SETTINGS_FRAME_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.frame) end,
            getFunc = function() return CopyColor(self.sv.colors.frame) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.frame, r, g, b, a)
                self:ApplyAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_DIVIDER_COLOR"),
            tooltip = L("DE_SETTINGS_DIVIDER_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.colors.border) end,
            getFunc = function() return CopyColor(self.sv.colors.border) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.colors.border, r, g, b, a)
                self:ApplyAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
    }

    local chestHintControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_CHEST_DESC"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_CHEST_ENABLED"),
            tooltip = L("DE_SETTINGS_CHEST_ENABLED_TT"),
            default = self.defaults.showChestHints,
            getFunc = function() return self.sv.showChestHints end,
            setFunc = function(value)
                self.sv.showChestHints = value
                if not value then
                    self.state.chestHintText = nil
                    self.state.chestHintUntil = nil
                    self:HideCenterChestAlert()
                end
                self:RefreshUI()
                self:UpdateChestAlertPreview()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_CHEST_WINDOW"),
            tooltip = L("DE_SETTINGS_CHEST_WINDOW_TT"),
            default = self.defaults.showCenterChestAlert,
            getFunc = function() return self.sv.showCenterChestAlert end,
            setFunc = function(value)
                self.sv.showCenterChestAlert = value
                if not value then
                    self:HideCenterChestAlert()
                end
                self:UpdateChestAlertPreview()
            end,
            disabled = ChestHintsDisabled,
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_CHEST_DURATION"),
            tooltip = L("DE_SETTINGS_CHEST_DURATION_TT"),
            min = 1,
            max = 30,
            step = 1,
            default = self.defaults.centerChestAlertSeconds,
            getFunc = function() return self.sv.centerChestAlertSeconds end,
            setFunc = function(value)
                self.sv.centerChestAlertSeconds = value
            end,
            disabled = ChestWindowDisabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_CHEST_MOVABLE"),
            tooltip = L("DE_SETTINGS_CHEST_MOVABLE_TT"),
            default = self.defaults.chestAlertMovable,
            getFunc = function() return self.sv.chestAlertMovable end,
            setFunc = function(value)
                self.sv.chestAlertMovable = value
                self:UpdateChestAlertPreview()
            end,
            disabled = ChestWindowDisabled,
            width = "full",
        },
        {
            type = "description",
            text = L("DE_SETTINGS_CHEST_PREVIEW_DESC"),
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_WINDOW_WIDTH"),
            min = self.CHEST_ALERT_MIN_WIDTH,
            max = self.CHEST_ALERT_MAX_WIDTH,
            step = 10,
            default = self.defaults.chestAlertSize.width,
            getFunc = function() return self.sv.chestAlertSize.width end,
            setFunc = function(value)
                self:SetChestAlertWidth(value)
                self:UpdateChestAlertPreview()
            end,
            disabled = ChestWindowDisabled,
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_TEXT_SIZE"),
            min = 16,
            max = 42,
            step = 1,
            default = self.defaults.chestAlertTextSize,
            getFunc = function() return self.sv.chestAlertTextSize end,
            setFunc = function(value)
                self.sv.chestAlertTextSize = value
                UpdateChestPreview()
            end,
            disabled = ChestWindowDisabled,
            width = "full",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_TEXT_COLOR_SHORT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.chestAlertColors.text) end,
            getFunc = function() return CopyColor(self.sv.chestAlertColors.text) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.chestAlertColors.text, r, g, b, a)
                UpdateChestPreview()
            end,
            disabled = ChestWindowDisabled,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_BACKGROUND_COLOR"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.chestAlertColors.background) end,
            getFunc = function() return CopyColor(self.sv.chestAlertColors.background) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.chestAlertColors.background, r, g, b, a)
                UpdateChestPreview()
            end,
            disabled = ChestWindowDisabled,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_FRAME_COLOR"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.chestAlertColors.frame) end,
            getFunc = function() return CopyColor(self.sv.chestAlertColors.frame) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.chestAlertColors.frame, r, g, b, a)
                UpdateChestPreview()
            end,
            disabled = ChestWindowDisabled,
            width = "half",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_CHEST_CENTER"),
            tooltip = L("DE_SETTINGS_CHEST_CENTER_TT"),
            func = function()
                self:ResetChestAlertPosition()
            end,
            disabled = ChestWindowDisabled,
            width = "half",
        },
    }

    local respawnTimerControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_RESPAWN_DESC"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RESPAWN_TIMER_SHOW"),
            tooltip = L("DE_SETTINGS_RESPAWN_TIMER_SHOW_TT"),
            default = self.defaults.showRespawnTimer,
            getFunc = function() return self.sv.showRespawnTimer end,
            setFunc = function(value)
                self.sv.showRespawnTimer = value
                self:RecalculateActiveCooldown()
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RESPAWN_WINDOW_HINT"),
            tooltip = L("DE_SETTINGS_RESPAWN_WINDOW_HINT_TT"),
            default = self.defaults.showSpawnWindowHint,
            getFunc = function() return self.sv.showSpawnWindowHint end,
            setFunc = function(value)
                self.sv.showSpawnWindowHint = value
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RESPAWN_OVERRUN"),
            tooltip = L("DE_SETTINGS_RESPAWN_OVERRUN_TT"),
            default = self.defaults.showRespawnOverrun,
            getFunc = function() return self.sv.showRespawnOverrun end,
            setFunc = function(value)
                self.sv.showRespawnOverrun = value
                self:RecalculateActiveCooldown()
                self:RefreshUI()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "description",
            text = L("DE_SETTINGS_RESPAWN_NOTICE"),
            width = "full",
        },
    }

    local function AddRespawnTimerControl(config, fieldName, nameKey, tooltipKey)
        local defaultEarliest, defaultExpected = self:GetConfiguredRespawnTiming(config)
        local defaultValue = fieldName == "earliestSeconds" and defaultEarliest or defaultExpected
        respawnTimerControls[#respawnTimerControls + 1] = {
            type = "editbox",
            name = L(nameKey),
            tooltip = L(tooltipKey),
            isMultiline = false,
            maxChars = 6,
            default = self:FormatRespawnTime(defaultValue),
            getFunc = function()
                local timing = self:GetRespawnTiming(config)
                return self:FormatRespawnTime(timing[fieldName])
            end,
            setFunc = function(value)
                if not self:SetRespawnTimerOverrideFromText(config, fieldName, value) then
                    self:Print(self:T("DE_SETTINGS_RESPAWN_INVALID_TIME", tostring(value or "")))
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        }
    end

    for _, config in ipairs(self:GetAllEncounterConfigsForSettings()) do
        local zoneName = zo_strformat(SI_ZONE_NAME, GetZoneNameById(config.zoneId))
        respawnTimerControls[#respawnTimerControls + 1] = {
            type = "header",
            name = self:T("DE_SETTINGS_RESPAWN_ENCOUNTER_FMT", zoneName, config.key),
            width = "full",
        }
        AddRespawnTimerControl(config, "earliestSeconds", "DE_SETTINGS_RESPAWN_EARLIEST", "DE_SETTINGS_RESPAWN_EARLIEST_TT")
        AddRespawnTimerControl(config, "expectedSeconds", "DE_SETTINGS_RESPAWN_EXPECTED", "DE_SETTINGS_RESPAWN_EXPECTED_TT")
    end

    respawnTimerControls[#respawnTimerControls + 1] = {
        type = "button",
        name = L("DE_SETTINGS_RESPAWN_RESET"),
        warning = L("DE_SETTINGS_RESPAWN_RESET_WARN"),
        isDangerous = true,
        func = function()
            self:ResetRespawnTimerOverrides()
            self:Print(self:T("DE_SETTINGS_RESPAWN_RESET_DONE"))
        end,
        disabled = DisabledWhenOff,
        width = "full",
    }

    local diagnosticControls = {}

    local moduleSettingsContext = {
        chestHintControls = chestHintControls,
        diagnosticControls = diagnosticControls,
        disabledWhenOff = DisabledWhenOff,
        chestWindowDisabled = ChestWindowDisabled,
        diagnosticDisabled = DiagnosticDisabled,
        updateStatusWindow = UpdateStatusWindow,
    }

    local respawnMeasurementModule = self:GetModule("respawnMeasurement")
    if respawnMeasurementModule and type(respawnMeasurementModule.AppendSettingsControls) == "function" then
        respawnMeasurementModule:AppendSettingsControls(moduleSettingsContext)
    end

    local debugModule = self:GetModule("debug")
    if debugModule and type(debugModule.AppendSettingsControls) == "function" then
        debugModule:AppendSettingsControls(moduleSettingsContext)
    end

    local resetControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_RESET_DESC"),
            width = "full",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RESET_STATUS_POS"),
            tooltip = L("DE_SETTINGS_RESET_STATUS_POS_TT"),
            func = function()
                self:ResetWindowPosition()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RESET_CHEST_POS"),
            tooltip = L("DE_SETTINGS_RESET_CHEST_POS_TT"),
            func = function()
                self:ResetChestAlertPosition()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RESET_STATUS_STYLE"),
            tooltip = L("DE_SETTINGS_RESET_STATUS_STYLE_TT"),
            func = function()
                self:ResetStatusWindowAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RESET_CHEST_STYLE"),
            tooltip = L("DE_SETTINGS_RESET_CHEST_STYLE_TT"),
            func = function()
                self:ResetChestAlertAppearance()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
    }

    local options = {
        {
            type = "description",
            text = L("DE_SETTINGS_PANEL_DESC"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_ADDON_ENABLED"),
            tooltip = L("DE_SETTINGS_ADDON_ENABLED_TT"),
            default = self.defaults.enabled,
            getFunc = function() return self.sv.enabled end,
            setFunc = function(value)
                self:SetEnabled(value)
                self:UpdateChestAlertPreview()
            end,
            width = "full",
        },
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_STATUS_CONTENT"),
            controls = statusContentControls,
        },
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_STATUS_STYLE"),
            controls = statusAppearanceControls,
        },
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_CHEST"),
            controls = chestHintControls,
        },
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_RESPAWN"),
            controls = respawnTimerControls,
        },
    }

    if #diagnosticControls > 0 then
        options[#options + 1] = {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_DEBUG"),
            controls = diagnosticControls,
        }
    end

    options[#options + 1] = {
        type = "submenu",
        name = L("DE_SETTINGS_SECTION_RESET"),
        controls = resetControls,
    }

    LAM:RegisterOptionControls(panelName, options)
end
