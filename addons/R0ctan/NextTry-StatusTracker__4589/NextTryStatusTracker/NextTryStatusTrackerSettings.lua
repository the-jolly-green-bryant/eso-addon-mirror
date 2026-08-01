local NTST = NextTryStatusTracker
local function L(key) return NTST.L(key) end
local function msg(text) return NTST.Msg(text) end

local function sanitizeDropdownChoices(choices, values)
    local safeChoices, safeValues = {}, {}
    if type(choices) == "table" then
        for i = 1, #choices do
            local choice = choices[i]
            if choice ~= nil then
                safeChoices[#safeChoices + 1] = choice
                local value = type(values) == "table" and values[i] or choice
                safeValues[#safeValues + 1] = value or ""
            end
        end
    end
    if #safeChoices == 0 then
        safeChoices[1], safeValues[1] = L("none"), ""
    end
    while #safeValues < #safeChoices do safeValues[#safeValues + 1] = safeChoices[#safeValues + 1] or "" end
    while #safeValues > #safeChoices do table.remove(safeValues) end
    return safeChoices, safeValues
end

local function buildPlayerTagDropdownChoices(playerName, assigned, emptyKey)
    local choices, values = NTST:BuildPlayerTagChoices(playerName, assigned)
    if #choices == 0 then return { L(emptyKey) }, { "" } end
    return choices, values
end

local function addControl(controls, control)
    controls[#controls + 1] = control
end

local function addColor(controls, nameKey, tooltipKey, getter, setter, defaultColor, refresh)
    addControl(controls, {
        type = "colorpicker",
        name = L(nameKey),
        tooltip = tooltipKey and L(tooltipKey) or nil,
        hasAlpha = true,
        getFunc = function()
            local c = getter()
            return c.r, c.g, c.b, c.a
        end,
        setFunc = function(r, g, b, a)
            setter({ r = r, g = g, b = b, a = a })
            if refresh then NTST:Refresh(true) end
        end,
        default = NTST.CopyColor(defaultColor),
    })
end

local function addSlider(controls, nameKey, tooltipKey, minValue, maxValue, step, getter, setter, defaultValue)
    addControl(controls, {
        type = "slider",
        name = L(nameKey),
        tooltip = tooltipKey and L(tooltipKey) or nil,
        min = minValue,
        max = maxValue,
        step = step,
        getFunc = getter,
        setFunc = setter,
        default = defaultValue,
    })
end

local function addStyleControls(controls, state, headerKey)
    local styles = NTST.sv.styles[state]
    local defaults = NTST.defaults.styles[state]
    local styleChoices = { L("normal"), L("bold") }
    local styleValues = { "normal", "bold" }

    if headerKey then addControl(controls, { type = "header", name = L(headerKey) }) end
    addSlider(controls, "fontSize", "fontSizeTooltip", 8, 32, 1,
        function() return styles.fontSize end,
        function(value) styles.fontSize = value; NTST:UpdateFontCache(); NTST:Refresh(true) end,
        defaults.fontSize)
    addControl(controls, {
        type = "dropdown",
        name = L("fontStyle"),
        tooltip = L("fontStyleTooltip"),
        choices = styleChoices,
        choicesValues = styleValues,
        getFunc = function() return styles.fontStyle end,
        setFunc = function(value) styles.fontStyle = value; NTST:UpdateFontCache(); NTST:Refresh(true) end,
        default = defaults.fontStyle,
    })
    addColor(controls, "fontColor", "fontColorTooltip",
        function() return styles.fontColor end,
        function(color) styles.fontColor = color end,
        defaults.fontColor,
        true)
    addColor(controls, "backgroundColor", "backgroundColorTooltip",
        function() return styles.backgroundColor end,
        function(color) styles.backgroundColor = color end,
        defaults.backgroundColor,
        true)
end

local function buildSoundChoices()
    local choices, values = { L("none") }, { "" }
    local candidates = {
        "QUEST_ACCEPTED", "QUEST_COMPLETED", "NEW_NOTIFICATION",
        "DEFAULT_CLICK", "POSITIVE_CLICK", "NEGATIVE_CLICK", "MENU_BAR_CLICK",
        "DIALOG_ACCEPT", "DIALOG_DECLINE", "READY_CHECK",
        "BOOK_OPEN", "BOOK_CLOSE", "BOOK_ACQUIRED",
        "ACHIEVEMENT_AWARDED", "LEVEL_UP", "CHAMPION_POINTS_COMMITTED",
        "NEW_MAIL", "MAIL_ITEM_DELETED",
        "MONEY_TRANSACT", "ALLIANCE_POINT_TRANSACT",
        "LOOT_WINDOW", "MAP_PING", "GENERAL_ALERT_ERROR",
        "ABILITY_SLOT_CLEARED", "ABILITY_SLOT_FILLED",
        "SKILL_GAINED", "LOCKPICKING_FORCE",
    }

    local added = {}
    local function addSound(key)
        if key and not added[key] and (key == NTST.defaults.statusSound or not SOUNDS or SOUNDS[key]) then
            added[key] = true
            choices[#choices + 1] = key
            values[#values + 1] = key
        end
    end

    for _, key in ipairs(candidates) do addSound(key) end

    if SOUNDS then
        local keys = {}
        local patterns = { "CLICK", "NOTIFICATION", "QUEST", "READY", "MAIL", "BOOK", "LEVEL", "ACHIEVEMENT", "CHAMPION", "MONEY", "LOOT", "MAP", "ERROR", "SKILL", "ABILITY", "GUILD", "GROUP" }
        for key in pairs(SOUNDS) do
            if type(key) == "string" then
                for _, pattern in ipairs(patterns) do
                    if string.find(key, pattern) then
                        keys[#keys + 1] = key
                        break
                    end
                end
            end
        end
        table.sort(keys)
        for i = 1, math.min(#keys, 80) do addSound(keys[i]) end
    end

    return choices, values
end

function NTST:RefreshSettingsDropdowns()
    if NextTryStatusTrackerFriendDropdown and NextTryStatusTrackerFriendDropdown.UpdateChoices then
        local friendChoices, friendValues = sanitizeDropdownChoices(self:BuildFriendChoices())
        NextTryStatusTrackerFriendDropdown:UpdateChoices(friendChoices, friendValues)
        NextTryStatusTrackerFriendDropdown:UpdateValue()
    end
    if NextTryStatusTrackerGuildDropdown and NextTryStatusTrackerGuildDropdown.UpdateChoices then
        local guildChoices, guildValues = sanitizeDropdownChoices(self:BuildGuildChoices())
        NextTryStatusTrackerGuildDropdown:UpdateChoices(guildChoices, guildValues)
        NextTryStatusTrackerGuildDropdown:UpdateValue()
    end
    if NextTryStatusTrackerGuildMemberDropdown and NextTryStatusTrackerGuildMemberDropdown.UpdateChoices then
        local memberChoices, memberValues = sanitizeDropdownChoices(self:BuildGuildMemberChoices(self.sv.selectedGuildId))
        NextTryStatusTrackerGuildMemberDropdown:UpdateChoices(memberChoices, memberValues)
        NextTryStatusTrackerGuildMemberDropdown:UpdateValue()
    end
    if NextTryStatusTrackerRemoveDropdown and NextTryStatusTrackerRemoveDropdown.UpdateChoices then
        local trackedChoices, trackedValues = sanitizeDropdownChoices(self:BuildTrackedChoices())
        NextTryStatusTrackerRemoveDropdown:UpdateChoices(trackedChoices, trackedValues)
        NextTryStatusTrackerRemoveDropdown:UpdateValue()
    end
    if NextTryStatusTrackerManagedDropdown and NextTryStatusTrackerManagedDropdown.UpdateChoices then
        local trackedChoices, trackedValues = sanitizeDropdownChoices(self:BuildTrackedChoices())
        NextTryStatusTrackerManagedDropdown:UpdateChoices(trackedChoices, trackedValues)
        NextTryStatusTrackerManagedDropdown:UpdateValue()
    end
    if NextTryStatusTrackerTagDropdown and NextTryStatusTrackerTagDropdown.UpdateChoices then
        local tagChoices, tagValues = sanitizeDropdownChoices(self:BuildTagChoices())
        NextTryStatusTrackerTagDropdown:UpdateChoices(tagChoices, tagValues)
        NextTryStatusTrackerTagDropdown:UpdateValue()
    end
    local managedPlayer = self.NormalizeDisplayName(self.sv.selectedManagedPlayer)
    if NextTryStatusTrackerAddTagDropdown and NextTryStatusTrackerAddTagDropdown.UpdateChoices then
        local choices, values = buildPlayerTagDropdownChoices(managedPlayer, false, "noMoreTagsAvailable")
        NextTryStatusTrackerAddTagDropdown:UpdateChoices(choices, values)
        NextTryStatusTrackerAddTagDropdown:UpdateValue()
    end
    if NextTryStatusTrackerRemoveTagDropdown and NextTryStatusTrackerRemoveTagDropdown.UpdateChoices then
        local choices, values = buildPlayerTagDropdownChoices(managedPlayer, true, "noTagsAssigned")
        NextTryStatusTrackerRemoveTagDropdown:UpdateChoices(choices, values)
        NextTryStatusTrackerRemoveTagDropdown:UpdateValue()
    end
end

function NTST:IsOwnSettingsPanel(panel)
    if not panel then return false end
    if self.settingsPanel and panel == self.settingsPanel then return true end

    local panelControl = _G and _G[self.name .. "Options"]
    if panelControl and panel == panelControl then return true end

    if panel.GetName and panel:GetName() == self.name .. "Options" then return true end
    return false
end

function NTST:RegisterSettingsPreviewCallbacks()
    if NextTryShared and NextTryShared.WindowVisibility and NextTryShared.WindowVisibility.RegisterLAMPreviewCallbacks then
        NextTryShared.WindowVisibility.RegisterLAMPreviewCallbacks(
            self,
            function(panel) return self:IsOwnSettingsPanel(panel) end,
            function(active) self:SetSettingsPreview(active) end
        )
    end

    if self.settingsControlsCallbackRegistered or not CALLBACK_MANAGER then return end
    self.settingsControlsCallbackRegistered = true
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        if self:IsOwnSettingsPanel(panel) then
            self:RefreshSettingsDropdowns()
            if panel.IsHidden and not panel:IsHidden() then
                self:SetSettingsPreview(true)
            end
        end
    end)
end

function NTST:RegisterTagDeleteDialog()
    if self.tagDeleteDialogRegistered or not ZO_Dialogs_RegisterCustomDialog then return end
    self.tagDeleteDialogRegistered = true
    ZO_Dialogs_RegisterCustomDialog("NEXTTRY_STATUS_TRACKER_DELETE_TAG", {
        title = { text = L("deleteTagConfirmTitle") },
        mainText = { text = L("deleteTagConfirmText") },
        buttons = {
            {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    local data = dialog and dialog.data
                    if data and data.tagKey then
                        self:DeleteTagDefinition(data.tagKey)
                        self:RefreshSettingsDropdowns()
                        if CALLBACK_MANAGER and self.settingsPanel then
                            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.settingsPanel)
                        end
                        self:Refresh(true)
                    end
                end,
            },
            { text = SI_DIALOG_CANCEL },
        },
    })
end

function NTST:ShowTagDeleteDialog(tagKey)
    if not self:GetTagDefinition(tagKey) or not ZO_Dialogs_ShowDialog then return end
    self:RegisterTagDeleteDialog()
    ZO_Dialogs_ShowDialog("NEXTTRY_STATUS_TRACKER_DELETE_TAG", { tagKey = tagKey })
end

function NTST:CreateSettings()
    local LAM = LibAddonMenu2 or (LibStub and LibStub("LibAddonMenu-2.0"))
    if not LAM then
        msg(L("libAddonMenuMissing"))
        return
    end

    local panelData = {
        type = "panel",
        name = L("settingsTitle"),
        displayName = L("settingsTitle"),
        author = "R0ctan",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    self.settingsPanel = LAM:RegisterAddonPanel(self.name .. "Options", panelData) or (_G and _G[self.name .. "Options"])
    self:RegisterSettingsPreviewCallbacks()

    local layoutChoices = { L("layoutVertical"), L("layoutHorizontal") }
    local layoutValues = { "vertical", "horizontal" }
    local nameChoices = { L("accountName"), L("characterName"), L("accountCharacterName"), L("characterAccountName") }
    local nameValues = { "account", "character", "accountCharacter", "characterAccount" }
    local sortChoices = { L("sortAlphabetical"), L("sortOnlineFirst"), L("sortOfflineFirst") }
    local sortValues = { "alphabetical", "onlineFirst", "offlineFirst" }
    local anchorChoices = { L("anchorLeft"), L("anchorCenter"), L("anchorRight") }
    local anchorValues = { "left", "center", "right" }
    local friendChoices, friendValues = sanitizeDropdownChoices(self:BuildFriendChoices())
    local guildChoices, guildValues = sanitizeDropdownChoices(self:BuildGuildChoices())
    local guildMemberChoices, guildMemberValues = sanitizeDropdownChoices(self:BuildGuildMemberChoices(self.sv.selectedGuildId))
    local trackedChoices, trackedValues = sanitizeDropdownChoices(self:BuildTrackedChoices())
    local tagChoices, tagValues = sanitizeDropdownChoices(self:BuildTagChoices())
    local addPlayerTagChoices, addPlayerTagValues = buildPlayerTagDropdownChoices(self.NormalizeDisplayName(self.sv.selectedManagedPlayer), false, "noMoreTagsAvailable")
    local removePlayerTagChoices, removePlayerTagValues = buildPlayerTagDropdownChoices(self.NormalizeDisplayName(self.sv.selectedManagedPlayer), true, "noTagsAssigned")
    local soundChoices, soundValues = sanitizeDropdownChoices(buildSoundChoices())
    local controls = {}
    local function getManagedPlayer()
        return self.NormalizeDisplayName(self.sv.selectedManagedPlayer)
    end
    local function getManagedProfile()
        local playerName = getManagedPlayer()
        return playerName and self:GetPlayerProfile(playerName) or nil
    end
    local function getSelectedTagDefinition()
        return self:GetTagDefinition(self.sv.selectedTagKey)
    end
    local function refreshManagedControls()
        if CALLBACK_MANAGER and self.settingsPanel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", self.settingsPanel)
        end
        self:Refresh(true)
    end

    addControl(controls, { type = "description", text = L("settingsDescription") })
    addControl(controls, {
        type = "checkbox",
        name = L("windowVisible"),
        tooltip = L("windowVisibleTooltip"),
        getFunc = function() return self.sv.visible end,
        setFunc = function(value) self:SetVisible(value) end,
        default = self.defaults.visible,
    })
    addControl(controls, {
        type = "checkbox",
        name = L("settingsPreview"),
        tooltip = L("settingsPreviewTooltip"),
        getFunc = function() return self.sv.settingsPreview end,
        setFunc = function(value)
            self.sv.settingsPreview = value and true or false
            self.sv.showInSettings = self.sv.settingsPreview
            self:ApplyVisibility()
            self:Refresh(true)
        end,
        default = self.defaults.settingsPreview,
    })

    local displayControls = {}
    addControl(displayControls, {
        type = "checkbox",
        name = L("unlockUi"),
        tooltip = L("unlockUiTooltip"),
        getFunc = function() return self.sv.uiUnlocked end,
        setFunc = function(value) self:SetUnlocked(value) end,
        default = self.defaults.uiUnlocked,
    })
    addControl(displayControls, {
        type = "dropdown",
        name = L("layout"),
        tooltip = L("layoutTooltip"),
        choices = layoutChoices,
        choicesValues = layoutValues,
        getFunc = function() return self.sv.layout end,
        setFunc = function(value) self.sv.layout = value; self:Refresh(true) end,
        default = self.defaults.layout,
    })
    addControl(displayControls, {
        type = "dropdown",
        name = L("windowAnchor"),
        tooltip = L("windowAnchorTooltip"),
        choices = anchorChoices,
        choicesValues = anchorValues,
        getFunc = function() return self.sv.windowAnchor end,
        setFunc = function(value) self.sv.windowAnchor = value or "left"; self:SavePosition(); self:Refresh(true) end,
        default = self.defaults.windowAnchor,
    })
    addControl(displayControls, {
        type = "dropdown",
        name = L("nameMode"),
        tooltip = L("nameModeTooltip"),
        choices = nameChoices,
        choicesValues = nameValues,
        getFunc = function() return self.sv.nameMode end,
        setFunc = function(value) self.sv.nameMode = value; self:Refresh(true) end,
        default = self.defaults.nameMode,
    })
    addControl(displayControls, {
        type = "dropdown",
        name = L("sortMode"),
        tooltip = L("sortModeTooltip"),
        choices = sortChoices,
        choicesValues = sortValues,
        getFunc = function() return self.sv.sortMode end,
        setFunc = function(value) self.sv.sortMode = value; self:Refresh(true) end,
        default = self.defaults.sortMode,
    })
    addControl(displayControls, {
        type = "checkbox",
        name = L("groupByStatus"),
        tooltip = L("groupByStatusTooltip"),
        getFunc = function() return self.sv.groupByStatus end,
        setFunc = function(value) self.sv.groupByStatus = value; self:Refresh(true) end,
        default = self.defaults.groupByStatus,
    })
    addControl(displayControls, {
        type = "checkbox",
        name = L("showOnlyOnline"),
        tooltip = L("showOnlyOnlineTooltip"),
        getFunc = function() return self.sv.showOnlyOnline end,
        setFunc = function(value) self.sv.showOnlyOnline = value and true or false; self:Refresh(true) end,
        default = self.defaults.showOnlyOnline,
    })
    addControl(displayControls, {
        type = "checkbox",
        name = L("showLocation"),
        tooltip = L("showLocationTooltip"),
        getFunc = function() return self.sv.showLocation end,
        setFunc = function(value) self.sv.showLocation = value and true or false; self:UpdateLocationRefreshInterval(); self:Refresh(true) end,
        default = self.defaults.showLocation,
    })
    addControl(displayControls, {
        type = "checkbox",
        name = L("showHoverTooltip"),
        tooltip = L("showHoverTooltipTooltip"),
        getFunc = function() return self.sv.showHoverTooltip end,
        setFunc = function(value) self.sv.showHoverTooltip = value and true or false; self:ApplyMouseStateToRows(); self:Refresh(true) end,
        default = self.defaults.showHoverTooltip,
    })
    addControl(displayControls, {
        type = "checkbox",
        name = L("showNotesTooltip"),
        tooltip = L("showNotesTooltipTooltip"),
        getFunc = function() return self.sv.showNotesTooltip end,
        setFunc = function(value) self.sv.showNotesTooltip = value and true or false; self:Refresh(true) end,
        default = self.defaults.showNotesTooltip,
    })
    addControl(displayControls, {
        type = "checkbox",
        name = L("showDisplayRoleMarker"),
        tooltip = L("showDisplayRoleMarkerTooltip"),
        getFunc = function() return self.sv.showDisplayRoleMarker end,
        setFunc = function(value) self.sv.showDisplayRoleMarker = value and true or false; self:Refresh(true) end,
        default = self.defaults.showDisplayRoleMarker,
    })
    addSlider(displayControls, "locationRefreshSeconds", "locationRefreshSecondsTooltip", 30, 300, 5,
        function() return self.sv.locationRefreshSeconds end,
        function(value) self.sv.locationRefreshSeconds = value; self:UpdateLocationRefreshInterval() end,
        self.defaults.locationRefreshSeconds)
    addSlider(displayControls, "rowGap", "rowGapTooltip", 0, 30, 1,
        function() return self.sv.display.rowGap end,
        function(value) self.sv.display.rowGap = value; self:Refresh(true) end,
        self.defaults.display.rowGap)
    addSlider(displayControls, "groupGap", "groupGapTooltip", 0, 60, 1,
        function() return self.sv.display.groupGap end,
        function(value) self.sv.display.groupGap = value; self:Refresh(true) end,
        self.defaults.display.groupGap)
    addColor(displayControls, "windowBackgroundColor", "windowBackgroundColorTooltip",
        function() return self.sv.display.backgroundColor end,
        function(color) self.sv.display.backgroundColor = color end,
        self.defaults.display.backgroundColor,
        true)
    addColor(displayControls, "windowBorderColor", "windowBorderColorTooltip",
        function() return self.sv.display.borderColor end,
        function(color) self.sv.display.borderColor = color end,
        self.defaults.display.borderColor,
        true)
    addColor(displayControls, "unlockedBorderColor", "unlockedBorderColorTooltip",
        function() return self.sv.display.unlockedBorderColor end,
        function(color) self.sv.display.unlockedBorderColor = color end,
        self.defaults.display.unlockedBorderColor,
        true)
    addSlider(displayControls, "refreshSeconds", "refreshSecondsTooltip", 10, 300, 5,
        function() return self.sv.refreshSeconds end,
        function(value) self.sv.refreshSeconds = value; self:UpdateRefreshInterval() end,
        self.defaults.refreshSeconds)
    addControl(displayControls, {
        type = "button",
        name = L("resetPosition"),
        tooltip = L("resetPositionTooltip"),
        func = function() self:ResetPosition() end,
    })
    addControl(controls, { type = "submenu", name = L("sectionDisplay"), controls = displayControls })

    local blinkControls = {}
    addControl(blinkControls, {
        type = "checkbox",
        name = L("statusBlinkEnabled"),
        tooltip = L("statusBlinkEnabledTooltip"),
        getFunc = function() return self.sv.statusBlinkEnabled ~= false end,
        setFunc = function(value) self.sv.statusBlinkEnabled = value and true or false end,
        default = self.defaults.statusBlinkEnabled,
    })
    addSlider(blinkControls, "blinkCount", "blinkCountTooltip", 0, 10, 1,
        function() return self.sv.blinkCount end,
        function(value) self.sv.blinkCount = value end,
        self.defaults.blinkCount)
    addSlider(blinkControls, "blinkPhaseMs", "blinkPhaseMsTooltip", 100, 2000, 50,
        function() return self.sv.blinkPhaseMs end,
        function(value) self.sv.blinkPhaseMs = value end,
        self.defaults.blinkPhaseMs)
    addColor(blinkControls, "blinkFontColor", "blinkFontColorTooltip",
        function() return self.sv.blinkFontColor end,
        function(color) self.sv.blinkFontColor = color end,
        self.defaults.blinkFontColor,
        false)
    addColor(blinkControls, "blinkBackgroundColor", "blinkBackgroundColorTooltip",
        function() return self.sv.blinkBackgroundColor end,
        function(color) self.sv.blinkBackgroundColor = color end,
        self.defaults.blinkBackgroundColor,
        false)
    addControl(blinkControls, {
        type = "button",
        name = L("testBlink"),
        tooltip = L("testBlinkTooltip"),
        func = function() self:TestBlink() end,
    })
    addControl(controls, { type = "submenu", name = L("sectionBlink"), controls = blinkControls })

    local soundControls = {}
    addControl(soundControls, {
        type = "checkbox",
        name = L("soundEnabled"),
        tooltip = L("soundEnabledTooltip"),
        getFunc = function() return self.sv.soundEnabled end,
        setFunc = function(value) self.sv.soundEnabled = value end,
        default = self.defaults.soundEnabled,
    })
    addControl(soundControls, {
        type = "dropdown",
        name = L("statusSound"),
        tooltip = L("statusSoundTooltip"),
        choices = soundChoices,
        choicesValues = soundValues,
        getFunc = function() return self.sv.statusSound or "" end,
        setFunc = function(value) self.sv.statusSound = value or "" end,
        default = self.defaults.statusSound,
    })
    addControl(soundControls, {
        type = "button",
        name = L("testSound"),
        tooltip = L("testSoundTooltip"),
        func = function() self:TestStatusSound() end,
    })
    addControl(controls, { type = "submenu", name = L("sectionSound"), controls = soundControls })

    local offlineControls = {}
    addStyleControls(offlineControls, "offline")
    addControl(controls, { type = "submenu", name = L("sectionOffline"), controls = offlineControls })

    local onlineControls = {}
    addStyleControls(onlineControls, "online")
    addControl(controls, { type = "submenu", name = L("sectionOnline"), controls = onlineControls })

    addControl(controls, { type = "header", name = L("sectionPlayers") })
    addControl(controls, { type = "description", text = L("reloadHint") })
    addControl(controls, {
        type = "button",
        name = L("refreshDropdowns"),
        tooltip = L("refreshDropdownsTooltip"),
        func = function() self:RefreshSettingsDropdowns() end,
    })

    local managedControls = {
        {
            type = "dropdown",
            name = L("managedPlayer"),
            tooltip = L("managedPlayerTooltip"),
            choices = trackedChoices,
            choicesValues = trackedValues,
            reference = "NextTryStatusTrackerManagedDropdown",
            getFunc = function() return self.sv.selectedManagedPlayer or "" end,
            setFunc = function(value)
                self.sv.selectedManagedPlayer = value or ""
                self.sv.selectedAddTagKey = ""
                self.sv.selectedRemoveTagKey = ""
                self:RefreshSettingsDropdowns()
                refreshManagedControls()
            end,
        },
        {
            type = "description",
            text = function()
                local profile = getManagedProfile()
                if not profile then return L("managedPlayerNone") end
                local sourceKey = profile.source == "friend" and "sourceFriend" or (profile.source == "guild" and "sourceGuild" or "sourceManual")
                local guild = self.CleanPlayerText(profile.guildName) or (profile.guildId and tostring(profile.guildId)) or L("unknown")
                return string.format(L("managedPlayerSummary"), L(sourceKey), guild,
                    self.CleanPlayerText(profile.lastKnownCharacterName) or L("unknown"),
                    self.CleanPlayerText(profile.lastKnownZone) or L("unknown"),
                    self:FormatLastSeen(profile.lastSeenAt))
            end,
        },
        {
            type = "editbox",
            name = L("trackerNote"),
            tooltip = L("trackerNoteTooltip"),
            getFunc = function() local profile = getManagedProfile(); return profile and profile.customNote or "" end,
            setFunc = function(value) local playerName = getManagedPlayer(); if playerName then self:SetPlayerCustomNote(playerName, value) end end,
            disabled = function() return getManagedProfile() == nil end,
            isMultiline = true,
            isExtraWide = true,
        },
        {
            type = "checkbox",
            name = L("playerNotifications"),
            tooltip = L("playerNotificationsTooltip"),
            getFunc = function() local profile = getManagedProfile(); return profile and profile.notificationEnabled ~= false or false end,
            setFunc = function(value) local playerName = getManagedPlayer(); if playerName then self:SetPlayerNotificationEnabled(playerName, value) end end,
            disabled = function() return getManagedProfile() == nil end,
        },
        { type = "header", name = L("roles") },
    }

    for _, key in ipairs(self.roleKeys) do
        local roleKey = key
        addControl(managedControls, {
            type = "checkbox",
            name = L("role" .. string.upper(string.sub(roleKey, 1, 1)) .. string.sub(roleKey, 2)),
            getFunc = function() local profile = getManagedProfile(); return profile and profile.roles[roleKey] or false end,
            setFunc = function(value) local profile = getManagedProfile(); if profile then profile.roles[roleKey] = value and true or false end; refreshManagedControls() end,
            disabled = function() return getManagedProfile() == nil end,
        })
    end

    addControl(managedControls, {
        type = "dropdown",
        name = L("displayRole"),
        tooltip = L("displayRoleTooltip"),
        choices = { L("displayRoleNone"), L("displayRoleTank"), L("displayRoleHealer"), L("displayRoleDd"), L("displayRoleRaidlead") },
        choicesValues = { "none", "tank", "healer", "dd", "raidlead" },
        getFunc = function() local profile = getManagedProfile(); return profile and profile.displayRole or "none" end,
        setFunc = function(value) local profile = getManagedProfile(); if profile and self.validDisplayRoles[value] then profile.displayRole = value end; refreshManagedControls() end,
        disabled = function() return getManagedProfile() == nil end,
    })

    addControl(managedControls, { type = "header", name = L("playerTags") })
    addControl(managedControls, {
        type = "description",
        text = function()
            local playerName = getManagedPlayer()
            local names = self:GetPlayerTagNames(playerName)
            return string.format(L("playerTagsSummary"), #names > 0 and table.concat(names, ", ") or L("none"))
        end,
    })
    addControl(managedControls, {
        type = "dropdown",
        name = L("addPlayerTag"),
        choices = addPlayerTagChoices,
        choicesValues = addPlayerTagValues,
        reference = "NextTryStatusTrackerAddTagDropdown",
        getFunc = function() return self.sv.selectedAddTagKey or "" end,
        setFunc = function(value) self.sv.selectedAddTagKey = value or "" end,
        disabled = function()
            local choices = self:BuildPlayerTagChoices(getManagedPlayer(), false)
            return #choices == 0
        end,
    })
    addControl(managedControls, {
        type = "button",
        name = L("addPlayerTag"),
        func = function()
            if self:SetPlayerTagAssigned(getManagedPlayer(), self.sv.selectedAddTagKey, true) then
                self.sv.selectedAddTagKey = ""
                self:RefreshSettingsDropdowns()
                refreshManagedControls()
            end
        end,
        disabled = function() return getManagedProfile() == nil or not self:GetTagDefinition(self.sv.selectedAddTagKey) end,
    })
    addControl(managedControls, {
        type = "description",
        text = function()
            local choices = self:BuildPlayerTagChoices(getManagedPlayer(), false)
            return #choices == 0 and L("noMoreTagsAvailable") or ""
        end,
    })
    addControl(managedControls, {
        type = "dropdown",
        name = L("removePlayerTag"),
        choices = removePlayerTagChoices,
        choicesValues = removePlayerTagValues,
        reference = "NextTryStatusTrackerRemoveTagDropdown",
        getFunc = function() return self.sv.selectedRemoveTagKey or "" end,
        setFunc = function(value) self.sv.selectedRemoveTagKey = value or "" end,
        disabled = function()
            local choices = self:BuildPlayerTagChoices(getManagedPlayer(), true)
            return #choices == 0
        end,
    })
    addControl(managedControls, {
        type = "button",
        name = L("removePlayerTag"),
        func = function()
            if self:SetPlayerTagAssigned(getManagedPlayer(), self.sv.selectedRemoveTagKey, false) then
                self.sv.selectedRemoveTagKey = ""
                self:RefreshSettingsDropdowns()
                refreshManagedControls()
            end
        end,
        disabled = function() return getManagedProfile() == nil or not self:GetTagDefinition(self.sv.selectedRemoveTagKey) end,
    })
    addControl(managedControls, {
        type = "description",
        text = function()
            local choices = self:BuildPlayerTagChoices(getManagedPlayer(), true)
            return #choices == 0 and L("noTagsAssigned") or ""
        end,
    })

    addControl(managedControls, { type = "header", name = L("tagManagement") })
    addControl(managedControls, { type = "description", text = L("defaultTagsDescription") })
    addControl(managedControls, {
        type = "dropdown",
        name = L("selectTag"),
        tooltip = L("selectTagTooltip"),
        choices = tagChoices,
        choicesValues = tagValues,
        reference = "NextTryStatusTrackerTagDropdown",
        getFunc = function() return self.sv.selectedTagKey or "" end,
        setFunc = function(value)
            self.sv.selectedTagKey = value or ""
            local definition = getSelectedTagDefinition()
            self.sv.tagNameInput = definition and definition.name or ""
            refreshManagedControls()
        end,
    })
    addControl(managedControls, {
        type = "editbox",
        name = L("tagName"),
        tooltip = L("tagNameTooltip"),
        getFunc = function() return self.sv.tagNameInput or "" end,
        setFunc = function(value) self.sv.tagNameInput = value or "" end,
        isMultiline = false,
        isExtraWide = false,
    })
    addControl(managedControls, {
        type = "button",
        name = L("addTag"),
        tooltip = L("addTagTooltip"),
        func = function()
            if not self:AddTagDefinition(self.sv.tagNameInput) then msg(L("tagNameInvalidOrDuplicate")) end
            self:RefreshSettingsDropdowns()
            refreshManagedControls()
        end,
    })
    addControl(managedControls, {
        type = "button",
        name = L("renameTag"),
        tooltip = L("renameTagTooltip"),
        func = function()
            if not self:RenameTagDefinition(self.sv.selectedTagKey, self.sv.tagNameInput) then msg(L("tagNameInvalidOrDuplicate")) end
            self:RefreshSettingsDropdowns()
            refreshManagedControls()
        end,
        disabled = function() return getSelectedTagDefinition() == nil end,
    })
    addControl(managedControls, {
        type = "button",
        name = L("deleteTag"),
        tooltip = L("deleteTagTooltip"),
        func = function()
            self:ShowTagDeleteDialog(self.sv.selectedTagKey)
        end,
        disabled = function() return getSelectedTagDefinition() == nil end,
    })

    addControl(managedControls, {
        type = "button",
        name = L("resetRolesAndTags"),
        tooltip = L("resetRolesAndTagsTooltip"),
        func = function() local playerName = getManagedPlayer(); if playerName then self:ResetPlayerRolesAndTags(playerName); refreshManagedControls() end end,
        disabled = function() return getManagedProfile() == nil end,
    })
    addControl(managedControls, {
        type = "button",
        name = L("resetLastKnown"),
        tooltip = L("resetLastKnownTooltip"),
        func = function() local playerName = getManagedPlayer(); if playerName then self:ResetPlayerLastKnownData(playerName); refreshManagedControls() end end,
        disabled = function() return getManagedProfile() == nil end,
    })
    addControl(managedControls, {
        type = "button",
        name = L("removeManagedPlayer"),
        tooltip = L("removeSelectedPlayerTooltip"),
        func = function() local playerName = getManagedPlayer(); if playerName then self:RemovePlayer(playerName); self:RefreshSettingsDropdowns(); refreshManagedControls() end end,
        disabled = function() return getManagedProfile() == nil end,
    })
    addControl(controls, { type = "submenu", name = L("sectionManagePlayers"), controls = managedControls })

    addControl(controls, { type = "submenu", name = L("sectionFriendImport"), controls = {
        {
            type = "description",
            text = L("friendImportHint"),
        },
        {
            type = "dropdown",
            name = L("friendDropdown"),
            tooltip = L("friendDropdownTooltip"),
            choices = friendChoices,
            choicesValues = friendValues,
            reference = "NextTryStatusTrackerFriendDropdown",
            getFunc = function() return self.sv.selectedFriend or "" end,
            setFunc = function(value) self.sv.selectedFriend = value or "" end,
        },
        {
            type = "button",
            name = L("addSelectedFriend"),
            tooltip = L("addSelectedFriendTooltip"),
            func = function() self:AddSelectedFriend(); self:RefreshSettingsDropdowns() end,
        },
    } })

    addControl(controls, { type = "submenu", name = L("sectionGuildImport"), controls = {
        {
            type = "description",
            text = L("guildImportHint"),
        },
        {
            type = "dropdown",
            name = L("guildDropdown"),
            tooltip = L("guildDropdownTooltip"),
            choices = guildChoices,
            choicesValues = guildValues,
            reference = "NextTryStatusTrackerGuildDropdown",
            getFunc = function() return self.sv.selectedGuildId or "" end,
            setFunc = function(value)
                self.sv.selectedGuildId = value or ""
                self.sv.selectedGuildMember = ""
                self:RefreshSettingsDropdowns()
            end,
        },
        {
            type = "button",
            name = L("refreshGuildMembers"),
            tooltip = L("refreshGuildMembersTooltip"),
            func = function() self:RefreshSettingsDropdowns() end,
        },
        {
            type = "dropdown",
            name = L("guildMemberDropdown"),
            tooltip = L("guildMemberDropdownTooltip"),
            choices = guildMemberChoices,
            choicesValues = guildMemberValues,
            reference = "NextTryStatusTrackerGuildMemberDropdown",
            getFunc = function() return self.sv.selectedGuildMember or "" end,
            setFunc = function(value)
                self.sv.selectedGuildMember = value or ""
                local key = self.NormalizeName(value)
                local cached = key and self.guildMemberSelectionCache and self.guildMemberSelectionCache[key]
                self.sv.selectedGuildMemberCharacter = cached and cached.characterName or ""
            end,
        },
        {
            type = "button",
            name = L("addSelectedGuildMember"),
            tooltip = L("addSelectedGuildMemberTooltip"),
            func = function() self:AddSelectedGuildMember(); self:RefreshSettingsDropdowns() end,
        },
    } })

    addControl(controls, { type = "submenu", name = L("sectionManualImport"), controls = {
        {
            type = "description",
            text = L("manualImportWarning"),
        },
        {
            type = "editbox",
            name = L("manualPlayer"),
            tooltip = L("manualPlayerTooltip"),
            getFunc = function() return self.sv.manualPlayer end,
            setFunc = function(value) self.sv.manualPlayer = value end,
            isMultiline = false,
            isExtraWide = false,
        },
        {
            type = "button",
            name = L("addManualPlayer"),
            tooltip = L("addManualPlayerTooltip"),
            func = function() self:AddPlayer(self.sv.manualPlayer); self.sv.manualPlayer = ""; self:RefreshSettingsDropdowns() end,
        },
    } })

    addControl(controls, { type = "submenu", name = L("sectionRemovePlayer"), controls = {
        {
            type = "dropdown",
            name = L("removePlayer"),
            tooltip = L("removePlayerTooltip"),
            choices = trackedChoices,
            choicesValues = trackedValues,
            reference = "NextTryStatusTrackerRemoveDropdown",
            getFunc = function() return self.sv.selectedRemovePlayer or "" end,
            setFunc = function(value) self.sv.selectedRemovePlayer = value or "" end,
        },
        {
            type = "button",
            name = L("removeSelectedPlayer"),
            tooltip = L("removeSelectedPlayerTooltip"),
            func = function() self:RemovePlayer(self.sv.selectedRemovePlayer); self:RefreshSettingsDropdowns() end,
        },
    } })

    LAM:RegisterOptionControls(self.name .. "Options", controls)
end
