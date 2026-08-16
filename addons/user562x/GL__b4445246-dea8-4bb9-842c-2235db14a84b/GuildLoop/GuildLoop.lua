GuildLoop = GuildLoop or {}
local GL = GuildLoop

GL.name = "GuildLoop"
GL.displayName = "Guild Loop"
GL.version = "1"
GL.savedVariableVersion = 1
GL.updateNamespace = "GuildLoop_Rotation"

GL.timerValues = { 1, 5, 10, 15, 30, 60 }
GL.specialGuildNames = {
    cycle = "Cycle Favorite Guild",
}
GL.defaults = {
    favorites = {},
    enabled = false,
    timerIndex = 4,
    timerUnit = "minutes",
}

GL.savedVars = nil
GL.hookState = {}
GL.firstActivationHandled = false
GL.currentDropdown = nil
GL.favoritePrefix = "|t24:24:EsoUI/Art/Collections/Favorite_StarOnly.dds|t "

GL.allowedAccounts = {
    ["@user562"] = true,
    ["@Drlxzel"] = true,
}

local function IsTable(value)
    return type(value) == "table"
end

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

function GL:NormalizeSettings()
    local saved = self.savedVars
    if not IsTable(saved) then
        return
    end

    if not IsTable(saved.favorites) then
        saved.favorites = {}
    end

    if type(saved.enabled) ~= "boolean" then
        saved.enabled = false
    end

    local timerIndex = tonumber(saved.timerIndex) or self.defaults.timerIndex
    timerIndex = zo_clamp and zo_clamp(timerIndex, 1, #self.timerValues)
        or math.max(1, math.min(#self.timerValues, timerIndex))
    saved.timerIndex = timerIndex

    if saved.timerUnit ~= "seconds"
        and saved.timerUnit ~= "minutes"
    then
        saved.timerUnit = "minutes"
    end
end

--------------------------------------------------
-- TIMER
--------------------------------------------------

function GL:GetTimerValue()
    if not self.savedVars then
        return self.timerValues[self.defaults.timerIndex]
    end

    return self.timerValues[self.savedVars.timerIndex]
        or self.timerValues[self.defaults.timerIndex]
end

function GL:GetTimerUnit()
    if not self.savedVars then
        return self.defaults.timerUnit
    end

    return self.savedVars.timerUnit == "seconds"
        and "seconds"
        or "minutes"
end

function GL:GetTimerSuffix()
    return self:GetTimerUnit() == "seconds" and "s" or "m"
end

function GL:GetTimerText()
    return string.format(
        "%d%s",
        self:GetTimerValue(),
        self:GetTimerSuffix()
    )
end

function GL:GetTimerIntervalMs()
    local multiplier = self:GetTimerUnit() == "seconds"
        and 1000
        or 60 * 1000

    return self:GetTimerValue() * multiplier
end

function GL:CycleTimer()
    if not self.savedVars then
        return
    end

    local nextIndex = self.savedVars.timerIndex + 1

    if nextIndex > #self.timerValues then
        nextIndex = 1
    end

    self.savedVars.timerIndex = nextIndex
    self:RestartRotationTimer()
    self:RefreshDropdownKeybinds(self.currentDropdown)
end

function GL:ToggleTimerUnit()
    if not self.savedVars then
        return
    end

    self.savedVars.timerUnit = self:GetTimerUnit() == "seconds"
        and "minutes"
        or "seconds"

    self:RestartRotationTimer()
    self:RefreshDropdownKeybinds(self.currentDropdown)
end

--------------------------------------------------
-- FAVORITES
--------------------------------------------------

function GL:IsFavorite(guildId)
    if not self.savedVars or guildId == nil then
        return false
    end

    return self.savedVars.favorites[tostring(guildId)] == true
end

function GL:SetFavorite(guildId, isFavorite)
    if not self.savedVars or guildId == nil then
        return false
    end

    if isFavorite then
        self.savedVars.favorites[tostring(guildId)] = true
    else
        self.savedVars.favorites[tostring(guildId)] = nil
    end

    if self:GetFavoriteCount() == 0 then
        self.savedVars.enabled = false
    end

    self:RestartRotationTimer()
    return true
end

function GL:ToggleFavorite(guildId)
    return self:SetFavorite(
        guildId,
        not self:IsFavorite(guildId)
    )
end

--------------------------------------------------
-- GUILD LIST
--------------------------------------------------

function GL:GetGuildNameById(guildId)
    if guildId == nil or type(GetGuildName) ~= "function" then
        return ""
    end

    return tostring(GetGuildName(guildId) or "")
end

function GL:GetGuildList()
    if type(GetNumGuilds) ~= "function"
        or type(GetGuildId) ~= "function"
    then
        return {}
    end

    local guilds = {}

    for index = 1, GetNumGuilds() do
        local guildId = GetGuildId(index)

        guilds[#guilds + 1] = {
            index = index,
            guildId = guildId,
            name = self:GetGuildNameById(guildId),
        }
    end

    return guilds
end

function GL:GetFavoriteGuilds()
    local result = {}

    if not self.savedVars then
        return result
    end

    local guilds = self:GetGuildList()

    for index = 1, #guilds do
        local guildInfo = guilds[index]

        if self:IsFavorite(guildInfo.guildId) then
            result[#result + 1] = guildInfo
        end
    end

    return result
end

function GL:GetFavoriteCount()
    return #self:GetFavoriteGuilds()
end

function GL:GetCurrentGuildId()
    if type(GetRepresentedGuildId) ~= "function" then
        return nil
    end

    return GetRepresentedGuildId()
end

--------------------------------------------------
-- ROTATION
--------------------------------------------------

function GL:ChooseCycleGuild(favoriteGuilds)
    local currentGuildId = self:GetCurrentGuildId()

    if currentGuildId == nil or currentGuildId == 0 then
        return favoriteGuilds[1]
    end

    for index = 1, #favoriteGuilds do
        if favoriteGuilds[index].guildId == currentGuildId then
            local nextIndex = index + 1

            if nextIndex > #favoriteGuilds then
                nextIndex = 1
            end

            return favoriteGuilds[nextIndex]
        end
    end

    return favoriteGuilds[1]
end

function GL:SelectGuildInternal(guildId)
    if guildId == nil or type(SetRepresentedGuildId) ~= "function" then
        return false
    end

    SetRepresentedGuildId(guildId)
    return true
end

function GL:SelectNextFavorite()
    local favorites = self:GetFavoriteGuilds()

    if #favorites < 2 then
        self:RestartRotationTimer()
        return false
    end

    local nextGuild = self:ChooseCycleGuild(favorites)

    if not nextGuild
        or nextGuild.guildId == nil
        or not self:SelectGuildInternal(nextGuild.guildId)
    then
        self:RestartRotationTimer()
        return false
    end

    self:ScheduleSelectedDisplayRefresh(self.currentDropdown)
    self:RestartRotationTimer()
    return true
end

function GL:UnregisterRotationTimer()
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate(
            self.updateNamespace
        )
    end
end

function GL:RestartRotationTimer()
    self:UnregisterRotationTimer()

    if not self.savedVars
        or not self.savedVars.enabled
        or self:GetFavoriteCount() < 2
        or not EVENT_MANAGER
    then
        return
    end

    EVENT_MANAGER:RegisterForUpdate(
        self.updateNamespace,
        self:GetTimerIntervalMs(),
        function()
            GL:SelectNextFavorite()
        end
    )
end

function GL:StopRotation()
    if not self.savedVars then
        return
    end

    self.savedVars.enabled = false
    self:UnregisterRotationTimer()
    self:RefreshDropdownKeybinds(self.currentDropdown)
end

function GL:ActivateRotation(dropdown)
    if not self.savedVars then
        return false
    end

    local favorites = self:GetFavoriteGuilds()

    if #favorites == 0 then
        self.savedVars.enabled = false
        self:UnregisterRotationTimer()
        self:ScheduleSelectedDisplayRefresh(dropdown)
        return false
    end

    self.savedVars.enabled = true

    local nextGuild

    if #favorites == 1 then
        nextGuild = favorites[1]
    else
        nextGuild = self:ChooseCycleGuild(favorites)
    end

    if nextGuild and nextGuild.guildId ~= nil then
        self:SelectGuildInternal(nextGuild.guildId)
    end

    self:RestartRotationTimer()
    self:ScheduleSelectedDisplayRefresh(dropdown)
    self:RefreshDropdownKeybinds(dropdown)
    return nextGuild ~= nil
end

--------------------------------------------------
-- DROPDOWN DISPLAY
--------------------------------------------------

function GL:IsSpecialData(data)
    return data ~= nil
        and data.guildLoopSpecialMode == "cycle"
end

function GL:GetSpecialGuildName(mode)
    return self.specialGuildNames[mode] or ""
end

function GL:GetNativeSelectedGuildText()
    local currentGuildId = self:GetCurrentGuildId()

    if currentGuildId ~= nil and currentGuildId ~= 0 then
        local guildName = self:GetGuildNameById(currentGuildId)

        if guildName ~= "" then
            return guildName
        end
    end

    if type(GetString) == "function" and SI_STATS_NO_GUILD then
        return GetString(SI_STATS_NO_GUILD)
    end

    return "No Guild"
end

function GL:RefreshSelectedDisplay(dropdown)
    if not dropdown
        or type(dropdown.SetSelectedItemText) ~= "function"
    then
        return
    end

    if self.savedVars and self.savedVars.enabled then
        dropdown:SetSelectedItemText(
            self:GetSpecialGuildName("cycle")
        )
    else
        dropdown:SetSelectedItemText(
            self:GetNativeSelectedGuildText()
        )
    end
end

function GL:ScheduleSelectedDisplayRefresh(dropdown)
    if not dropdown then
        return
    end

    if type(zo_callLater) == "function" then
        zo_callLater(function()
            GL:RefreshSelectedDisplay(dropdown)
        end, 0)
    else
        self:RefreshSelectedDisplay(dropdown)
    end
end

--------------------------------------------------
-- DROPDOWN DECORATION
--------------------------------------------------

function GL:CreateSpecialEntry(dropdown, mode)
    local name = self:GetSpecialGuildName(mode)
    local entry

    if type(dropdown.CreateItemEntry) == "function" then
        entry = dropdown:CreateItemEntry(
            name,
            function()
                GL:ActivateRotation(dropdown)
            end
        )
    elseif ZO_ComboBox
        and type(ZO_ComboBox.CreateItemEntry) == "function"
    then
        entry = ZO_ComboBox:CreateItemEntry(
            name,
            function()
                GL:ActivateRotation(dropdown)
            end
        )
    end

    if not entry then
        return nil
    end

    entry.guildLoopSpecialMode = mode
    entry.name = name
    return entry
end

function GL:EnsureSpecialEntries(dropdown)
    if not dropdown
        or type(dropdown.GetItems) ~= "function"
        or type(dropdown.ClearItems) ~= "function"
        or type(dropdown.AddItem) ~= "function"
    then
        return false
    end

    local items = dropdown:GetItems()

    if not IsTable(items) then
        return false
    end

    local specialCount = 0

    for index = 1, #items do
        if self:IsSpecialData(items[index]) then
            specialCount = specialCount + 1
        end
    end

    if specialCount == 1
        and items[1]
        and items[1].guildLoopSpecialMode == "cycle"
    then
        return true
    end

    local nativeItems = {}

    for index = 1, #items do
        local data = items[index]

        if not self:IsSpecialData(data) then
            nativeItems[#nativeItems + 1] = data
        end
    end

    local cycleEntry = self:CreateSpecialEntry(
        dropdown,
        "cycle"
    )

    if not cycleEntry then
        return false
    end

    if type(dropdown.SetSortsItems) == "function" then
        dropdown:SetSortsItems(false)
    end

    dropdown:ClearItems()

    local suppressUpdate = ZO_COMBOBOX_SUPPRESS_UPDATE
        or ZO_COMBOBOX_SUPRESS_UPDATE

    dropdown:AddItem(cycleEntry, suppressUpdate)

    for index = 1, #nativeItems do
        dropdown:AddItem(nativeItems[index], suppressUpdate)
    end

    if type(dropdown.UpdateItems) == "function" then
        dropdown:UpdateItems()
    end

    return true
end

function GL:WrapNativeSelectionCallback(data)
    if not data
        or self:IsSpecialData(data)
        or data.guildLoopSelectionWrapped
        or type(data.callback) ~= "function"
    then
        return
    end

    local originalCallback = data.callback

    data.callback = function(...)
        GL:StopRotation()
        return originalCallback(...)
    end
    data.guildLoopSelectionWrapped = true
end

function GL:BuildGuildDisplayName(guildId)
    local guildName = self:GetGuildNameById(guildId)

    if guildName == "" then
        return ""
    end

    if self:IsFavorite(guildId) then
        guildName = self.favoritePrefix .. guildName
    end

    return guildName
end

function GL:GetHighlightedData(dropdown)
    if not dropdown then
        return nil
    end

    if dropdown.m_currentData then
        return dropdown.m_currentData
    end

    local focus = dropdown.m_focus

    if focus and type(focus.GetFocusItem) == "function" then
        local focusItem = focus:GetFocusItem()
        return focusItem and focusItem.data or nil
    end

    return nil
end

function GL:UpdateVisibleDropdownItem(dropdown, data)
    if not dropdown or not data or not data.guildId then
        return
    end

    data.name = self:BuildGuildDisplayName(data.guildId)

    local focus = dropdown.m_focus

    if focus and type(focus.GetFocusItem) == "function" then
        local focusItem = focus:GetFocusItem()

        if focusItem
            and focusItem.data == data
            and focusItem.control
            and focusItem.control.nameControl
        then
            focusItem.control.nameControl:SetText(data.name)
        end
    end

    if type(dropdown.GetSelectedItemData) == "function"
        and dropdown:GetSelectedItemData() == data
        and type(dropdown.SetSelectedItemText) == "function"
    then
        dropdown:SetSelectedItemText(data.name)
    end
end

function GL:DecorateDropdown(dropdown)
    if not dropdown
        or type(dropdown.GetItems) ~= "function"
    then
        return
    end

    self:EnsureSpecialEntries(dropdown)

    local items = dropdown:GetItems()

    for index = 1, #items do
        local data = items[index]

        if self:IsSpecialData(data) then
            data.name = self:GetSpecialGuildName(
                data.guildLoopSpecialMode
            )
        else
            self:WrapNativeSelectionCallback(data)

            if data.guildId then
                data.name = self:BuildGuildDisplayName(
                    data.guildId
                )
            end
        end
    end

    self:RefreshSelectedDisplay(dropdown)
end

--------------------------------------------------
-- KEYBINDS
--------------------------------------------------

function GL:RefreshDropdownKeybinds(dropdown)
    if not dropdown
        or not KEYBIND_STRIP
        or type(KEYBIND_STRIP.UpdateKeybindButtonGroup)
            ~= "function"
    then
        return
    end

    if type(dropdown.IsActive) == "function"
        and dropdown:IsActive()
    then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(
            dropdown.keybindStripDescriptor,
            dropdown.m_keybindState
        )
    end
end

function GL:ToggleHighlightedFavorite(dropdown)
    local data = self:GetHighlightedData(dropdown)

    if not data or not data.guildId then
        return
    end

    if self:ToggleFavorite(data.guildId) then
        self:UpdateVisibleDropdownItem(dropdown, data)
        self:RefreshSelectedDisplay(dropdown)
        self:RefreshDropdownKeybinds(dropdown)
    end
end

function GL:AddDropdownKeybinds(dropdown)
    local descriptors = dropdown.keybindStripDescriptor

    if not IsTable(descriptors) then
        return false
    end

    descriptors[#descriptors + 1] = {
        keybind = "UI_SHORTCUT_SECONDARY",
        order = 100,
        disabledDuringSceneHiding = true,
        name = function()
            local data = GL:GetHighlightedData(dropdown)

            if data and data.guildId
                and GL:IsFavorite(data.guildId)
            then
                return "Unfavorite"
            end

            return "Favorite"
        end,
        visible = function()
            local data = GL:GetHighlightedData(dropdown)
            return data ~= nil and data.guildId ~= nil
        end,
        callback = function()
            GL:ToggleHighlightedFavorite(dropdown)
        end,
    }

    descriptors[#descriptors + 1] = {
        keybind = "UI_SHORTCUT_TERTIARY",
        order = 200,
        disabledDuringSceneHiding = true,
        name = function()
            return string.format(
                "Timer: %s",
                GL:GetTimerText()
            )
        end,
        callback = function()
            GL:CycleTimer()
        end,
    }

    descriptors[#descriptors + 1] = {
        keybind = "UI_SHORTCUT_QUINARY",
        order = 210,
        disabledDuringSceneHiding = true,
        name = function()
            return GL:GetTimerUnit() == "seconds"
                and "Unit: Seconds"
                or "Unit: Minutes"
        end,
        callback = function()
            GL:ToggleTimerUnit()
        end,
    }

    return true
end

function GL:AttachToDropdown(dropdown)
    if not self:IsAccountAllowed() then
        return false
    end

    if not dropdown
        or not dropdown.keybindStripDescriptor
    then
        return false
    end

    self.currentDropdown = dropdown
    self:DecorateDropdown(dropdown)

    if dropdown.guildLoopInstalled then
        self:RefreshSelectedDisplay(dropdown)
        self:RefreshDropdownKeybinds(dropdown)
        return true
    end

    if not self:AddDropdownKeybinds(dropdown) then
        return false
    end

    if type(dropdown.RegisterCallback) == "function" then
        dropdown:RegisterCallback(
            "OnItemSelected",
            function(control, data)
                GL.currentDropdown = dropdown
                GL:RefreshDropdownKeybinds(dropdown)
            end
        )

        dropdown:RegisterCallback(
            "OnHideDropdown",
            function()
                if GL.currentDropdown == dropdown then
                    GL.currentDropdown = nil
                end
            end
        )
    end

    dropdown.guildLoopInstalled = true
    self:RefreshSelectedDisplay(dropdown)
    self:RefreshDropdownKeybinds(dropdown)
    return true
end

--------------------------------------------------
-- HOOKS
--------------------------------------------------

function GL:InstallHooks()
    if type(SecurePostHook) ~= "function" then
        return false
    end

    if not self.hookState.setCurrentGuildDropdown
        and ZO_GamepadStats
        and type(ZO_GamepadStats.SetCurrentGuildDropdown)
            == "function"
    then
        local ok = pcall(
            SecurePostHook,
            ZO_GamepadStats,
            "SetCurrentGuildDropdown",
            function(statsObject, dropdown)
                GL:AttachToDropdown(dropdown)
            end
        )

        self.hookState.setCurrentGuildDropdown = ok
    end

    if not self.hookState.guildRefresh
        and ZO_Stats_Common
        and type(ZO_Stats_Common.UpdateGuildDropdownGuilds)
            == "function"
    then
        local ok = pcall(
            SecurePostHook,
            ZO_Stats_Common,
            "UpdateGuildDropdownGuilds",
            function(statsObject, dropdown)
                GL:AttachToDropdown(dropdown)
            end
        )

        self.hookState.guildRefresh = ok
    end

    if not self.hookState.activateGuildDropdown
        and ZO_GamepadStats
        and type(ZO_GamepadStats.ActivateGuildDropdown)
            == "function"
    then
        local ok = pcall(
            SecurePostHook,
            ZO_GamepadStats,
            "ActivateGuildDropdown",
            function(statsObject)
                local dropdown = statsObject
                    and statsObject.currentGuildDropdown

                if GL:AttachToDropdown(dropdown) then
                    GL:RefreshDropdownKeybinds(dropdown)
                end
            end
        )

        self.hookState.activateGuildDropdown = ok
    end

    if not self.hookState.guildRow
        and type(ZO_GamepadStatGuildRow_Setup)
            == "function"
    then
        local ok = pcall(
            SecurePostHook,
            "ZO_GamepadStatGuildRow_Setup",
            function(control)
                GL:AttachToDropdown(
                    control and control.dropdown
                )
            end
        )

        self.hookState.guildRow = ok
    end

    return self.hookState.setCurrentGuildDropdown == true
        or self.hookState.guildRefresh == true
        or self.hookState.activateGuildDropdown == true
        or self.hookState.guildRow == true
end

function GL:ScheduleHookRetries()
    local delays = { 0, 100, 500, 1000 }

    for index = 1, #delays do
        zo_callLater(function()
            GL:InstallHooks()
        end, delays[index])
    end
end

function GL:OnPlayerActivated()
    if not self:IsAccountAllowed() then
        return
    end

    self:ScheduleHookRetries()

    if self.firstActivationHandled then
        return
    end

    self.firstActivationHandled = true
    self:RestartRotationTimer()
end

--------------------------------------------------
-- ACCESS CONTROL
--------------------------------------------------

function GL:IsAccountAllowed()
    if type(GetDisplayName) ~= "function" then
        return false
    end

    return self.allowedAccounts[GetDisplayName()] == true
end

--------------------------------------------------
-- INITIALIZATION
--------------------------------------------------

function GL:Initialize()
    self.savedVars = ZO_SavedVars:NewCharacterIdSettings(
        "GuildLoopSavedVariables",
        self.savedVariableVersion,
        nil,
        self.defaults
    )

    self:NormalizeSettings()
    self:InstallHooks()
    self:ScheduleHookRetries()

    EVENT_MANAGER:RegisterForEvent(
        self.name .. "_PlayerActivated",
        EVENT_PLAYER_ACTIVATED,
        function()
            GL:OnPlayerActivated()
        end
    )
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= GL.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        GL.name,
        EVENT_ADD_ON_LOADED
    )

    GL:Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    GL.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
