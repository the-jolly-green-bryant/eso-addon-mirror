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

        -- Reuse each window's preview so setting changes can be judged live.
        if self.sv and self.sv.enabled and self.sv.showWindow then
            self:ShowStatusWindowPreview()
        end
        local grw = self.GuildRelayWindow
        if grw and grw.addon and grw.addon.IsAddonRuntimeEnabled and grw.addon:IsAddonRuntimeEnabled()
            and grw.sv and grw.sv.relayWindowShow ~= false
            and not grw.previewActive then
            grw:PreviewOnce()
            -- LAM re-evaluates dynamic button names only on panel refresh.
            self:RefreshSettingsPanel()
        end
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

        self:HideStatusWindowPreview()
        if self.GuildRelayWindow and self.GuildRelayWindow.previewActive then
            self.GuildRelayWindow:StopPreview()
            -- Keep the dynamic preview-button label correct for the next open.
            self:RefreshSettingsPanel()
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
        -- Pilot for a cross-project build-number convention (see .build-counter).
        version = self.buildNumber and string.format("%s (Build %d)", self.version, self.buildNumber) or self.version,
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

    local function RespawnTimerDisabled()
        return not self.sv.enabled or not self.sv.showRespawnTimer
    end

    local function RelayAutoAcceptDisabled()
        return not self.sv.enabled or not self.sv.relayReceiveEnabled
    end

    local function RelayRequestReplyDisabled()
        return not self.sv.enabled or not self.sv.relayRequestReceiveEnabled
    end

    local function RelayWindowPreviewDisabled()
        return not self.sv.enabled or self.sv.relayWindowShow == false
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
                if value and self.settingsPanelOpen and not self.statusWindowPreviewActive then
                    self:ShowStatusWindowPreview()
                end
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
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_UNKNOWN_COUNTUP"),
            tooltip = L("DE_SETTINGS_SHOW_UNKNOWN_COUNTUP_TT"),
            default = self.defaults.showUnknownCountUp,
            getFunc = function() return self.sv.showUnknownCountUp end,
            setFunc = function(value)
                self.sv.showUnknownCountUp = value
                UpdateStatusWindow()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
    }

    local minimalModeControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_MINIMAL_DESC"),
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
            name = L("DE_SETTINGS_MINIMAL_SHOW_FRAME"),
            tooltip = L("DE_SETTINGS_MINIMAL_SHOW_FRAME_TT"),
            default = self.defaults.minimalShowFrame,
            getFunc = function() return self.sv.minimalShowFrame end,
            setFunc = function(value)
                self.sv.minimalShowFrame = value
                self:RefreshWindowLayout()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
    }

    -- Group relay settings by direction so sending and receiving remain distinct.
    local relaySendControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_RELAY_SEND_DESC"),
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_SEND_TIMER_HEADER"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_SHOW_BUTTON"),
            tooltip = L("DE_SETTINGS_RELAY_SHOW_BUTTON_TT"),
            default = self.defaults.relayShowButton,
            getFunc = function() return self.sv.relayShowButton end,
            setFunc = function(value)
                self.sv.relayShowButton = value
                self:RefreshWindowLayout()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_SEND_ENCOUNTER_HEADER"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_GUILD_SHOW_BUTTON"),
            tooltip = L("DE_SETTINGS_RELAY_GUILD_SHOW_BUTTON_TT"),
            default = self.defaults.relayGuildShowButton,
            getFunc = function() return self.sv.relayGuildShowButton end,
            setFunc = function(value)
                self.sv.relayGuildShowButton = value
                self:RefreshWindowLayout()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_SEND_REQUEST_HEADER"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_REQUEST_SHOW_BUTTON"),
            tooltip = L("DE_SETTINGS_RELAY_REQUEST_SHOW_BUTTON_TT"),
            default = self.defaults.relayRequestShowButton,
            getFunc = function() return self.sv.relayRequestShowButton end,
            setFunc = function(value)
                self.sv.relayRequestShowButton = value
                self:RefreshWindowLayout()
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_CODE_OF_CONDUCT_HEADER"),
            width = "full",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RELAY_SHOW_CODE_OF_CONDUCT"),
            tooltip = L("DE_SETTINGS_RELAY_SHOW_CODE_OF_CONDUCT_TT"),
            func = function()
                ZO_Dialogs_ShowDialog("DE_RELAY_CODE_OF_CONDUCT", {
                    infoOnly = true,
                })
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
    }

    local relayReceiveControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_RELAY_RECEIVE_DESC"),
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_RECEIVE_TIMER_HEADER"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_RECEIVE_ENABLED"),
            tooltip = L("DE_SETTINGS_RELAY_RECEIVE_ENABLED_TT"),
            default = self.defaults.relayReceiveEnabled,
            getFunc = function() return self.sv.relayReceiveEnabled end,
            setFunc = function(value)
                self.sv.relayReceiveEnabled = value
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_AUTO_ACCEPT"),
            tooltip = L("DE_SETTINGS_RELAY_AUTO_ACCEPT_TT"),
            default = self.defaults.relayAutoAccept,
            getFunc = function() return self.sv.relayAutoAccept end,
            setFunc = function(value)
                self.sv.relayAutoAccept = value
            end,
            disabled = RelayAutoAcceptDisabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_SHOW_INVALID_NOTICE"),
            tooltip = L("DE_SETTINGS_RELAY_SHOW_INVALID_NOTICE_TT"),
            default = self.defaults.relayShowInvalidNotice,
            getFunc = function() return self.sv.relayShowInvalidNotice end,
            setFunc = function(value)
                self.sv.relayShowInvalidNotice = value
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_RECEIVE_ENCOUNTER_HEADER"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_GUILD_RECEIVE_ENABLED"),
            tooltip = L("DE_SETTINGS_RELAY_GUILD_RECEIVE_ENABLED_TT"),
            default = self.defaults.relayGuildReceiveEnabled,
            getFunc = function() return self.sv.relayGuildReceiveEnabled end,
            setFunc = function(value)
                self.sv.relayGuildReceiveEnabled = value
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_RECEIVE_REQUEST_HEADER"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_REQUEST_RECEIVE_ENABLED"),
            tooltip = L("DE_SETTINGS_RELAY_REQUEST_RECEIVE_ENABLED_TT"),
            default = self.defaults.relayRequestReceiveEnabled,
            getFunc = function() return self.sv.relayRequestReceiveEnabled end,
            setFunc = function(value)
                self.sv.relayRequestReceiveEnabled = value
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            -- This skips only channel choice; the player must still confirm and send chat manually.
            type = "dropdown",
            name = L("DE_SETTINGS_RELAY_REQUEST_REPLY_CHANNEL"),
            tooltip = L("DE_SETTINGS_RELAY_REQUEST_REPLY_CHANNEL_TT"),
            choices = {
                L("DE_SETTINGS_RELAY_REQUEST_REPLY_CHANNEL_ASK"),
                L("DE_SETTINGS_RELAY_REQUEST_REPLY_CHANNEL_WHISPER"),
                L("DE_SETTINGS_RELAY_REQUEST_REPLY_CHANNEL_SAME"),
            },
            choicesValues = { "ask", "whisper", "same" },
            default = self.defaults.relayRequestReplyChannel,
            getFunc = function() return self.sv.relayRequestReplyChannel end,
            setFunc = function(value)
                self.sv.relayRequestReplyChannel = value or "ask"
            end,
            disabled = RelayRequestReplyDisabled,
            width = "full",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_RELAY_REQUEST_COLLECTION_WINDOW"),
            tooltip = L("DE_SETTINGS_RELAY_REQUEST_COLLECTION_WINDOW_TT"),
            min = self.RELAY_REQUEST_COLLECTION_WINDOW_MIN_SECONDS,
            max = self.RELAY_REQUEST_COLLECTION_WINDOW_MAX_SECONDS,
            step = 5,
            default = self.defaults.relayRequestCollectionWindowSeconds,
            getFunc = function() return self.sv.relayRequestCollectionWindowSeconds end,
            setFunc = function(value)
                self.sv.relayRequestCollectionWindowSeconds = value
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
    }

    local relayWindowControls = {
        {
            type = "description",
            text = L("DE_SETTINGS_SECTION_RELAY_WINDOW_DESC"),
            width = "full",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_WINDOW_SHOW"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_SHOW_TT"),
            default = self.defaults.relayWindowShow,
            getFunc = function() return self.sv.relayWindowShow end,
            setFunc = function(value)
                self.sv.relayWindowShow = value
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                    if value and self.settingsPanelOpen and self.sv.enabled
                        and not self.GuildRelayWindow.previewActive then
                        self.GuildRelayWindow:PreviewOnce()
                        self:RefreshSettingsPanel()
                    end
                end
            end,
            disabled = DisabledWhenOff,
            width = "full",
        },
        {
            -- The stored locked flag is the inverse of the user-facing movable checkbox.
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_WINDOW_MOVABLE"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_MOVABLE_TT"),
            default = not self.defaults.relayWindowLocked,
            getFunc = function() return not self.sv.relayWindowLocked end,
            setFunc = function(value)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:SetLocked(not value)
                else
                    self.sv.relayWindowLocked = not value
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "checkbox",
            name = L("DE_SETTINGS_RELAY_WINDOW_SHOW_BORDER"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_SHOW_BORDER_TT"),
            default = self.defaults.relayWindowShowBorder,
            getFunc = function() return self.sv.relayWindowShowBorder end,
            setFunc = function(value)
                self.sv.relayWindowShowBorder = value and true or false
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:ApplyWindowVisual()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "dropdown",
            name = L("DE_SETTINGS_RELAY_WINDOW_ANCHOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_ANCHOR_TT"),
            choices = { L("DE_SETTINGS_ANCHOR_LEFT"), L("DE_SETTINGS_ANCHOR_CENTER"), L("DE_SETTINGS_ANCHOR_RIGHT") },
            choicesValues = { "left", "center", "right" },
            default = self.defaults.relayWindowPosition.anchor,
            -- ResetPosition may clear the saved position table.
            getFunc = function()
                if type(self.sv.relayWindowPosition) ~= "table" then
                    return self.defaults.relayWindowPosition.anchor
                end
                return self.sv.relayWindowPosition.anchor
            end,
            setFunc = function(value)
                if type(self.sv.relayWindowPosition) ~= "table" then
                    self.sv.relayWindowPosition = {}
                end
                self.sv.relayWindowPosition.anchor = value or "right"
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:SavePosition()
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RELAY_WINDOW_RESET_POSITION"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_RESET_POSITION_TT"),
            func = function()
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:ResetPosition()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "button",
            name = function()
                if self.GuildRelayWindow and self.GuildRelayWindow.previewActive then
                    return L("DE_SETTINGS_RELAY_WINDOW_PREVIEW_STOP")
                end
                return L("DE_SETTINGS_RELAY_WINDOW_PREVIEW")
            end,
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_PREVIEW_TT"),
            func = function()
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:TogglePreview()
                end
            end,
            disabled = RelayWindowPreviewDisabled,
            width = "half",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_WINDOW_APPEARANCE_HEADER"),
            width = "full",
        },
        {
            type = "dropdown",
            name = L("DE_SETTINGS_RELAY_WINDOW_SORT_MODE"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_SORT_MODE_TT"),
            choices = { L("DE_SETTINGS_RELAY_WINDOW_SORT_MODE_REMAINING"), L("DE_SETTINGS_RELAY_WINDOW_SORT_MODE_ZONE") },
            choicesValues = { "remaining", "zone" },
            default = self.defaults.relayWindowSortMode,
            getFunc = function() return self.sv.relayWindowSortMode end,
            setFunc = function(value)
                self.sv.relayWindowSortMode = value
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_RELAY_WINDOW_FONT_SIZE"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_FONT_SIZE_TT"),
            min = 12,
            max = 28,
            step = 1,
            default = self.defaults.relayWindowFontSize,
            getFunc = function() return self.sv.relayWindowFontSize end,
            setFunc = function(value)
                self.sv.relayWindowFontSize = value
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_RELAY_WINDOW_BLINK_THRESHOLD"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_BLINK_THRESHOLD_TT"),
            min = 5,
            max = 300,
            step = 5,
            default = self.defaults.relayWindowBlinkThresholdSeconds,
            getFunc = function() return self.sv.relayWindowBlinkThresholdSeconds end,
            setFunc = function(value)
                self.sv.relayWindowBlinkThresholdSeconds = value
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "slider",
            name = L("DE_SETTINGS_RELAY_WINDOW_CHECK_INTERVAL"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_CHECK_INTERVAL_TT"),
            min = 5,
            max = 60,
            step = 5,
            default = self.defaults.relayWindowCheckIntervalSeconds,
            getFunc = function() return self.sv.relayWindowCheckIntervalSeconds end,
            setFunc = function(value)
                self.sv.relayWindowCheckIntervalSeconds = value
                -- StartGuildRelayLivenessTick replaces any existing registration.
                self:StartGuildRelayLivenessTick()
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            -- A genuinely shared active encounter carries no reliable ongoing
            -- progress info (this addon shares once, no repeated updates), so
            -- it expires quickly by default (see CheckGuildRelayEntriesLiveness).
            type = "slider",
            name = L("DE_SETTINGS_RELAY_WINDOW_ACTIVE_SHARE_MAX_AGE"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_ACTIVE_SHARE_MAX_AGE_TT"),
            min = 10,
            max = 300,
            step = 10,
            default = self.defaults.relayWindowActiveShareMaxAgeSeconds,
            getFunc = function() return self.sv.relayWindowActiveShareMaxAgeSeconds end,
            setFunc = function(value)
                self.sv.relayWindowActiveShareMaxAgeSeconds = value
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            -- A cooldown timer promoted to "active" once its respawn estimate
            -- passed has a real, calculated start time to work with, so it is
            -- allowed to stay much longer (see CheckGuildRelayEntriesLiveness).
            type = "slider",
            name = L("DE_SETTINGS_RELAY_WINDOW_ACTIVE_ESTIMATED_MAX_AGE"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_ACTIVE_ESTIMATED_MAX_AGE_TT"),
            min = 30,
            max = 1800,
            step = 30,
            default = self.defaults.relayWindowActiveEstimatedMaxAgeSeconds,
            getFunc = function() return self.sv.relayWindowActiveEstimatedMaxAgeSeconds end,
            setFunc = function(value)
                self.sv.relayWindowActiveEstimatedMaxAgeSeconds = value
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "header",
            name = L("DE_SETTINGS_RELAY_WINDOW_COLOR_HEADER"),
            width = "full",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_BACKGROUND_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_BACKGROUND_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.background) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.background) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.background, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:ApplyWindowVisual()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_TITLE_BAR_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_TITLE_BAR_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.titleBar) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.titleBar) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.titleBar, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:ApplyWindowVisual()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_TITLE_TEXT_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_TITLE_TEXT_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.titleText) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.titleText) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.titleText, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:ApplyWindowVisual()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_ZONE_TEXT_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_ZONE_TEXT_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.zoneText) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.zoneText) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.zoneText, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_PLAYER_TEXT_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_PLAYER_TEXT_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.playerText) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.playerText) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.playerText, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_SEPARATOR_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_SEPARATOR_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.separator) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.separator) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.separator, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_WARNING_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_WARNING_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.warning) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.warning) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.warning, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "colorpicker",
            name = L("DE_SETTINGS_RELAY_WINDOW_BLINK_COLOR"),
            tooltip = L("DE_SETTINGS_RELAY_WINDOW_BLINK_COLOR_TT"),
            hasAlpha = true,
            default = function() return GetDefaultColor(self.defaults.relayWindowColors.blink) end,
            getFunc = function() return CopyColor(self.sv.relayWindowColors.blink) end,
            setFunc = function(r, g, b, a)
                SetColor(self.sv.relayWindowColors.blink, r, g, b, a)
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:Refresh()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
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
        {
            type = "checkbox",
            name = L("DE_SETTINGS_SHOW_FRAME"),
            tooltip = L("DE_SETTINGS_SHOW_FRAME_TT"),
            default = self.defaults.showFrame,
            getFunc = function() return self.sv.showFrame end,
            setFunc = function(value)
                self.sv.showFrame = value
                self:RefreshWindowLayout()
            end,
            disabled = DisabledWhenOff,
            width = "full",
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
            tooltip = L("DE_SETTINGS_CHEST_WIDTH_TT"),
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
            tooltip = L("DE_SETTINGS_CHEST_TEXT_SIZE_TT"),
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
            name = L("DE_SETTINGS_CHEST_TEXT_COLOR"),
            tooltip = L("DE_SETTINGS_CHEST_TEXT_COLOR_TT"),
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
            tooltip = L("DE_SETTINGS_CHEST_BACKGROUND_COLOR_TT"),
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
            tooltip = L("DE_SETTINGS_CHEST_FRAME_COLOR_TT"),
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
            disabled = RespawnTimerDisabled,
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
            disabled = RespawnTimerDisabled,
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
        {
            type = "button",
            name = L("DE_SETTINGS_RESET_RELAY_WINDOW_POS"),
            tooltip = L("DE_SETTINGS_RESET_RELAY_WINDOW_POS_TT"),
            func = function()
                if self.GuildRelayWindow then
                    self.GuildRelayWindow:ResetPosition()
                end
            end,
            disabled = DisabledWhenOff,
            width = "half",
        },
        {
            type = "button",
            name = L("DE_SETTINGS_RESET_RELAY_WINDOW_STYLE"),
            tooltip = L("DE_SETTINGS_RESET_RELAY_WINDOW_STYLE_TT"),
            func = function()
                self:ResetGuildRelayWindowAppearance()
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
                if value and self.settingsPanelOpen then
                    if self.sv.showWindow and not self.statusWindowPreviewActive then
                        self:ShowStatusWindowPreview()
                    end
                    if self.GuildRelayWindow and self.sv.relayWindowShow ~= false
                        and not self.GuildRelayWindow.previewActive then
                        self.GuildRelayWindow:PreviewOnce()
                        self:RefreshSettingsPanel()
                    end
                end
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
            name = L("DE_SETTINGS_SECTION_MINIMAL"),
            controls = minimalModeControls,
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
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_RELAY_SEND"),
            controls = relaySendControls,
        },
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_RELAY_RECEIVE"),
            controls = relayReceiveControls,
        },
        {
            type = "submenu",
            name = L("DE_SETTINGS_SECTION_RELAY_WINDOW"),
            controls = relayWindowControls,
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
