-- CooldownTrackerSettingsActions.lua
-- Gamepad-friendly settings via LibHarvensAddonSettings.
--
-- IMPORTANT:
-- Do NOT call LibHarvensAddonSettings:CreateAddonSettingsPanel() from addons.
-- The library creates its own panel once during its initialization; addons should
-- register via LibHarvensAddonSettings:AddAddon(...) and add settings via AddSetting().

---@type CooldownTracker
local CooldownTracker = assert(_G["CooldownTracker"], "CooldownTracker global missing")
local SettingsUtils = assert(CooldownTracker.SettingsUtils, "CooldownTracker.SettingsUtils missing (load order issue)")

-- Use the canonical state subtree as the settings module table.
local SettingsActions = (CooldownTracker.State and CooldownTracker.State.settings) or {}
CooldownTracker.State.settings = SettingsActions
CooldownTracker.SettingsActions = SettingsActions

---@type any|nil
SettingsActions.addonSettings = SettingsActions.addonSettings or nil
SettingsActions.initialized = SettingsActions.initialized == true
---@type string|nil
SettingsActions.selectedTrackerId = SettingsActions.selectedTrackerId or nil
---@type string|nil
SettingsActions.returnSelectionKey = SettingsActions.returnSelectionKey or nil
---@type string|nil
SettingsActions.pendingSelectionKey = SettingsActions.pendingSelectionKey or nil
SettingsActions.rebuildPending = SettingsActions.rebuildPending == true
SettingsActions.rebuildWhenShown = SettingsActions.rebuildWhenShown == true
SettingsActions.sceneShowHookRegistered = SettingsActions.sceneShowHookRegistered == true

local STACK_DISPLAY_ITEMS = SettingsUtils.STACK_DISPLAY_ITEMS
local STACK_DISPLAY_NAME_BY_VALUE = SettingsUtils.STACK_DISPLAY_NAME_BY_VALUE

---@return TrackerFrameConfig|nil
local function GetMainFrameConfig()
    local sv = CooldownTracker.savedVars
    local cfg = sv and sv.frames and sv.frames.main
    if cfg then
        if cfg.alpha == nil then
            cfg.alpha = 1.0
        end
        if cfg.stackDisplayMode == nil then
            cfg.stackDisplayMode = "overlay"
        end
    end
    return cfg
end

---@return TrackerFrame|nil
local function GetMainFrame()
    local FramesActions = CooldownTracker.FramesActions
    return FramesActions and FramesActions.GetFrame and FramesActions.GetFrame("main") or nil
end

local function ApplyMainFramePosition()
    local frame = GetMainFrame()
    local cfg = GetMainFrameConfig()
    if not frame or not cfg then
        return
    end

    frame.root:ClearAnchors()
    frame.root:SetAnchor(cfg.point, _G["GuiRoot"], cfg.point, cfg.x, cfg.y, nil)
end

---@return table|nil
local function GetSettingsConfig()
    local sv = CooldownTracker.savedVars
    if not sv then
        return nil
    end
    if not sv.settings then
        sv.settings = {}
    end
    if sv.settings.showPreviewInSettings == nil then
        sv.settings.showPreviewInSettings = false
    end
    if sv.settings.previewDefaultMigrated ~= true then
        if sv.settings.showPreviewInSettings == true then
            sv.settings.showPreviewInSettings = false
        end
        sv.settings.previewDefaultMigrated = true
    end
    return sv.settings
end

-- On console, LibHarvensAddonSettings pushes this scene when the user enters an
-- addon panel. The library only clears a panel's `selected` flag when a
-- *different* addon is selected, so closing the whole menu leaves our panel
-- flagged selected. Rebuilding while the scene is hidden is worse than wasted
-- work: the drill-down restore calls SetCurrentList/CreateControls, which
-- re-activates the gamepad parametric list and steals directional input from
-- the character (movement lockups while "Watch combat" streams events).
local SETTINGS_SCENE_NAME = "LibHarvensAddonSettingsScene"

local function GetSettingsScene()
    local sceneManager = _G["SCENE_MANAGER"]
    if not sceneManager or type(sceneManager.GetScene) ~= "function" then
        return nil
    end
    return sceneManager:GetScene(SETTINGS_SCENE_NAME)
end

local function IsSettingsSceneShowing()
    local scene = GetSettingsScene()
    if not scene then
        -- PC panel has no dedicated scene; fall back to the selected flag alone.
        return true
    end
    local state = scene:GetState()
    return state == SCENE_SHOWING or state == SCENE_SHOWN
end

function SettingsActions:IsPanelSelected()
    return self.addonSettings ~= nil and self.addonSettings.selected == true
end

-- Rebuild deferred from a hidden scene runs when the settings scene next shows.
function SettingsActions:EnsureSceneShowHook()
    if self.sceneShowHookRegistered then
        return
    end
    local scene = GetSettingsScene()
    if not scene then
        return
    end
    self.sceneShowHookRegistered = true
    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING and self.rebuildWhenShown then
            self.rebuildWhenShown = false
            self:Rebuild()
        end
    end)
end

function SettingsActions:ScheduleRebuild()
    if self.rebuildPending then
        return
    end
    self.rebuildPending = true
    zo_callLater(function()
        self.rebuildPending = false
        if not self:IsPanelSelected() then
            return
        end
        if not IsSettingsSceneShowing() then
            self.rebuildWhenShown = true
            self:EnsureSceneShowHook()
            return
        end
        self:Rebuild()
    end, 200)
end

function SettingsActions:UpdatePreviewState()
    local cfg = GetSettingsConfig()
    local shouldPreview = cfg and cfg.showPreviewInSettings and self:IsPanelSelected()
    if CooldownTracker and CooldownTracker.SetPreviewActive then
        CooldownTracker:SetPreviewActive(shouldPreview == true)
    end
end

local function AddSection(panel, label, selectionKey)
    local LAS = _G["LibHarvensAddonSettings"]
    local setting = panel:AddSetting({
        type = LAS.ST_SECTION,
        label = label,
    })
    if selectionKey then
        setting.selectionKey = selectionKey
    end
    return setting
end

local function AddLabel(panel, text, selectionKey)
    local LAS = _G["LibHarvensAddonSettings"]
    local setting = panel:AddSetting({
        type = LAS.ST_LABEL,
        label = text,
        canSelect = false,
    })
    if selectionKey then
        setting.selectionKey = selectionKey
    end
    return setting
end

local function AddButton(panel, label, tooltip, handler, selectionKey)
    local LAS = _G["LibHarvensAddonSettings"]
    local setting = panel:AddSetting({
        type = LAS.ST_BUTTON,
        label = label,
        tooltip = tooltip,
        clickHandler = handler,
    })
    if selectionKey then
        setting.selectionKey = selectionKey
    end
    return setting
end

local function AddCheckbox(panel, label, tooltip, getFn, setFn, selectionKey)
    local LAS = _G["LibHarvensAddonSettings"]
    local setting = panel:AddSetting({
        type = LAS.ST_CHECKBOX,
        label = label,
        tooltip = tooltip,
        getFunction = getFn,
        setFunction = setFn,
    })
    if selectionKey then
        setting.selectionKey = selectionKey
    end
    return setting
end

local function AddSlider(panel, label, tooltip, min, max, step, format, getFn, setFn, selectionKey)
    local LAS = _G["LibHarvensAddonSettings"]
    local setting = panel:AddSetting({
        type = LAS.ST_SLIDER,
        label = label,
        tooltip = tooltip,
        min = min,
        max = max,
        step = step,
        format = format,
        getFunction = getFn,
        setFunction = setFn,
    })
    if selectionKey then
        setting.selectionKey = selectionKey
    end
    return setting
end

local function AddDropdown(panel, label, tooltip, items, getFn, setFn, selectionKey)
    local LAS = _G["LibHarvensAddonSettings"]
    local setting = panel:AddSetting({
        type = LAS.ST_DROPDOWN,
        label = label,
        tooltip = tooltip,
        items = items,
        getFunction = getFn,
        setFunction = setFn,
    })
    if selectionKey then
        setting.selectionKey = selectionKey
    end
    return setting
end

local function GetSettingsList()
    local LAS = _G["LibHarvensAddonSettings"]
    return LAS and LAS.list or nil
end

---@return string|nil
---@return number|nil
local function CaptureSelectedSetting()
    local list = GetSettingsList()
    if not list or not list.GetSelectedData then
        return nil, nil
    end
    local data = list:GetSelectedData()
    local selectionKey = data and data.selectionKey or nil
    local selectionIndex = list.GetSelectedIndex and list:GetSelectedIndex() or nil
    return selectionKey, selectionIndex
end

---@param selectionKey string|nil
---@param selectionIndex number|nil
local function RestoreSelectedSetting(selectionKey, selectionIndex)
    if not selectionKey and type(selectionIndex) ~= "number" then
        return
    end

    local list = GetSettingsList()
    if not list then
        return
    end
    if list.IsEmpty and list:IsEmpty() then
        return
    end

    local targetIndex = nil
    if selectionKey and list.FindFirstIndexByEval then
        targetIndex = list:FindFirstIndexByEval(function(data)
            return data and data.selectionKey == selectionKey
        end)
    end

    if not targetIndex and type(selectionIndex) == "number" then
        local maxIndex = list.GetNumItems and list:GetNumItems() or nil
        if maxIndex and maxIndex > 0 then
            targetIndex = zo_clamp(selectionIndex, 1, maxIndex)
        end
    end

    if not targetIndex and list.CalculateFirstSelectableIndex then
        targetIndex = list:CalculateFirstSelectableIndex()
    end

    if targetIndex then
        if list.SetSelectedIndexWithoutAnimation then
            list:SetSelectedIndexWithoutAnimation(targetIndex, true)
        elseif list.SetSelectedIndex then
            list:SetSelectedIndex(targetIndex, true)
        end
    end
end

-- On console, LibHarvensAddonSettings renders each ST_SECTION as a drill-down
-- submenu. The library tracks the open submenu on a secondary "Section" list via
-- an object-identity reference (list.currentSection == the section's control).
-- Our panel is rebuilt wholesale on every change (RemoveAllSettings + re-add),
-- which recreates every section as a brand new object, orphaning that reference
-- and blanking the submenu the user is inside. The helpers below let us capture
-- the drill-down position by stable selectionKey and restore it after a rebuild.
local function CanUseDrillDown()
    local LAS = _G["LibHarvensAddonSettings"]
    local isConsole = _G["ZO_IsConsoleOrGameCoreUI"]
    return type(isConsole) == "function"
        and isConsole() == true
        and LAS ~= nil
        and LAS.scrollList ~= nil
        and type(LAS.scrollList.GetList) == "function"
end

---@return string|nil
local function GetActiveSectionKey()
    if not CanUseDrillDown() then
        return nil
    end
    local LAS = _G["LibHarvensAddonSettings"]
    local sectionList = LAS.scrollList:GetList("Section")
    local section = sectionList and sectionList.currentSection
    return section and section.selectionKey or nil
end

-- Return to the top-level (main) list. Mirrors the library's GoBack without the
-- sound or scene change; rendering is left to the caller/rebuild.
local function SetActiveListToMain()
    if not CanUseDrillDown() then
        return
    end
    local LAS = _G["LibHarvensAddonSettings"]
    local sectionList = LAS.scrollList:GetList("Section")
    if sectionList then
        sectionList.currentSection = nil
    end
    local mainList = LAS.scrollList:GetMainList()
    LAS.scrollList:SetCurrentList(mainList)
    LAS.list = mainList
end

-- Enter a section's submenu and render its children. Returns true on success.
---@param panel any
---@param sectionSetting any
---@return boolean
local function DrillIntoSection(panel, sectionSetting)
    if not CanUseDrillDown() or not panel or not sectionSetting then
        return false
    end
    local LAS = _G["LibHarvensAddonSettings"]
    local sectionList = LAS.scrollList:GetList("Section")
    if not sectionList then
        return false
    end
    sectionList.currentSection = sectionSetting
    LAS.scrollList:SetCurrentList(sectionList)
    panel:CreateControls()
    return true
end

---@param panel any
---@param key string|nil
---@return any|nil
local function FindSettingByKey(panel, key)
    if not key or not panel or not panel.settings then
        return nil
    end
    local settings = panel.settings
    for i = 1, #settings do
        if settings[i].selectionKey == key then
            return settings[i]
        end
    end
    return nil
end

-- Restore the drill-down position and row selection after a full rebuild. Because
-- the rebuild destroys and recreates every section, we re-map by stable
-- selectionKey rather than by the (now dangling) object references the library
-- captured when the user drilled in.
---@param panel any
---@param targetKey string|nil
---@param selectionIndex number|nil
---@param activeSectionKey string|nil
local function RestoreNavigation(panel, targetKey, selectionIndex, activeSectionKey)
    if not panel then
        return
    end

    -- PC (non-drill-down), an unselected panel, or a hidden scene: keep the
    -- simple flat restore. Drilling in while hidden would activate the gamepad
    -- list and steal directional input from the character.
    if not CanUseDrillDown() or panel.selected ~= true or not IsSettingsSceneShowing() then
        RestoreSelectedSetting(targetKey, selectionIndex)
        return
    end

    local LAS = _G["LibHarvensAddonSettings"]
    local targetSetting = FindSettingByKey(panel, targetKey)

    local sectionToOpen = nil
    if targetSetting then
        if targetSetting.type ~= LAS.ST_SECTION and targetSetting.currentSection then
            -- The target row lives inside a submenu; open that submenu.
            sectionToOpen = targetSetting.currentSection
        end
    elseif activeSectionKey then
        -- The target row is gone (e.g. a discovered effect that just became a
        -- tracker). Keep the user in whatever submenu they were browsing.
        local prevSection = FindSettingByKey(panel, activeSectionKey)
        if prevSection and prevSection.type == LAS.ST_SECTION then
            sectionToOpen = prevSection
        end
    end

    if sectionToOpen and sectionToOpen.subMenu ~= false then
        DrillIntoSection(panel, sectionToOpen)
    else
        SetActiveListToMain()
    end

    RestoreSelectedSetting(targetKey, selectionIndex)
end

local function FormatIconTag(icon, size)
    return SettingsUtils.FormatIconTag(icon, size)
end

local function FormatFramedIconTag(icon, size)
    return FormatIconTag(icon, size)
end

local function AppendFramedIconTagLine(lines, icon, size)
    lines[#lines + 1] = FormatFramedIconTag(icon, size)
end

local function AppendLabeledIcon(lines, label, icon, size)
    lines[#lines + 1] = string.format("%s: %s", label, FormatIconTag(icon, size))
end

---@param name string|nil
---@return string|nil
local function NormalizeName(name)
    if not name or name == "" then
        return nil
    end
    return zo_strlower(zo_strformat("<<t:1>>", name))
end

---@param result number|nil
---@return boolean
local function IsDamageResult(result)
    return result == ACTION_RESULT_DAMAGE
        or result == ACTION_RESULT_CRITICAL_DAMAGE
        or result == ACTION_RESULT_DOT_TICK
        or result == ACTION_RESULT_DOT_TICK_CRITICAL
end

---@param setName string|nil
---@param onlyDamage boolean
---@return table[]
local function CollectRecentProcsMatchingSetName(setName, onlyDamage)
    local normalizedSetName = NormalizeName(setName)
    if not normalizedSetName then
        return {}
    end
    local TrackingActions = CooldownTracker and CooldownTracker.TrackingActions
    local recents = TrackingActions and TrackingActions.GetRecentProcs and TrackingActions.GetRecentProcs() or {}
    local matches = {}
    for i = 1, #recents do
        local proc = recents[i]
        local procName = proc and proc.name
        local normalizedProcName = NormalizeName(procName)
        if normalizedProcName and string.find(normalizedProcName, normalizedSetName, 1, true) then
            if not onlyDamage or IsDamageResult(proc.lastResult) then
                matches[#matches + 1] = proc
            end
        end
    end
    return matches
end

---@param tracker TrackerDefinition|nil
---@return string|nil
local function GetSetNameForTracker(tracker)
    if not tracker or not tracker.setId then
        return nil
    end
    local TrackingActions = CooldownTracker and CooldownTracker.TrackingActions
    local setData = TrackingActions and TrackingActions.GetEquippedSet and TrackingActions.GetEquippedSet(tracker.setId) or
        nil
    if setData and setData.name and setData.name ~= "" then
        return setData.name
    end
    if GetItemSetName then
        local setName = GetItemSetName(tracker.setId)
        if setName and setName ~= "" then
            return zo_strformat("<<t:1>>", setName)
        end
    end
    return nil
end

---@param abilityName string|nil
---@return string|nil
local function GetSetNameForProcName(abilityName)
    local normalizedProcName = NormalizeName(abilityName)
    if not normalizedProcName then
        return nil
    end
    local TrackingActions = CooldownTracker and CooldownTracker.TrackingActions
    local equippedSets = TrackingActions and TrackingActions.GetAllEquippedSets and TrackingActions.GetAllEquippedSets() or
        nil
    if not equippedSets then
        return nil
    end
    for _, setData in pairs(equippedSets) do
        local setName = setData and setData.name
        local normalizedSetName = NormalizeName(setName)
        if normalizedSetName and string.find(normalizedProcName, normalizedSetName, 1, true) then
            return setName
        end
    end
    return nil
end

---@param lines table
---@param setName string|nil
local function AppendAssociatedDamageProcs(lines, setName)
    if not setName or setName == "" then
        return
    end
    local matches = CollectRecentProcsMatchingSetName(setName, true)
    if #matches == 0 then
        lines[#lines + 1] = string.format("Associated damage procs: (none seen for %s)", setName)
        return
    end
    lines[#lines + 1] = string.format("Associated damage procs (%s):", setName)
    for i = 1, #matches do
        local proc = matches[i]
        local procName = proc and proc.name or "Unknown"
        local abilityId = proc and proc.abilityId or 0
        AppendLabeledIcon(lines, string.format("Damage proc: %s [%d]", procName, abilityId), proc and proc.icon, 32)
    end
end

local function FormatTrackerTooltip(tracker)
    local lines = {}
    if not tracker then
        return table.concat(lines, "\n")
    end

    local TrackingActions = CooldownTracker and CooldownTracker.TrackingActions
    local resolvedIcon = TrackingActions and TrackingActions.GetIcon and TrackingActions.GetIcon(tracker, nil) or nil
    AppendFramedIconTagLine(lines, resolvedIcon, 48)

    local abilityId = tracker.abilityId
    local displayName = tracker.name or "Unknown"
    lines[#lines + 1] = string.format("Name: %s", displayName)
    lines[#lines + 1] = string.format("Status: %s", tracker.enabled == false and "disabled" or "enabled")
    lines[#lines + 1] = string.format("Trigger source: %s",
        tracker.useCombatEvent == false and "effect change" or "combat event")
    if abilityId then
        lines[#lines + 1] = string.format("Ability ID: %d", abilityId)
    end
    if tracker.setId then
        lines[#lines + 1] = string.format("Set ID: %d", tracker.setId)
    end
    local cooldownSeconds = tonumber(tracker.cooldownSeconds) or 0
    lines[#lines + 1] = string.format("Cooldown: %.0fs", cooldownSeconds)
    if cooldownSeconds == 0 then
        lines[#lines + 1] = "Cooldown mode: permanent after trigger"
    elseif cooldownSeconds == -1 then
        lines[#lines + 1] = "Cooldown mode: show while buff is missing"
    elseif cooldownSeconds == -2 then
        lines[#lines + 1] = "Cooldown mode: follow effect timer"
    end
    lines[#lines + 1] = string.format("Show only during combat: %s", tracker.hideOutsideCombat == true and "yes" or "no")
    if tracker.customIcon and tracker.customIcon ~= "" then
        lines[#lines + 1] = "Custom icon: set"
    end
    AppendAssociatedDamageProcs(lines, GetSetNameForTracker(tracker))
    return table.concat(lines, "\n")
end

local function FormatRecentTooltip(proc)
    local lines = {}
    local casterUnitTag = "player"
    local overrideRank = nil
    local abilityId = proc and proc.abilityId
    local icon = proc and proc.icon
    local abilityName = proc and proc.name
    local source = proc and proc.lastSource or "effect"
    local sourceLabel = source == "combat" and "combat event" or "effect change"
    AppendFramedIconTagLine(lines, icon, 48)
    lines[#lines + 1] = string.format("Observed via: %s", sourceLabel)
    if proc and type(proc.lastResult) == "number" then
        lines[#lines + 1] = string.format("Combat result: %d", proc.lastResult)
    end
    lines[#lines + 1] = string.format("Seen: %dx", (proc and proc.count) or 1)
    lines[#lines + 1] = string.format("Ability ID: %d", abilityId or 0)
    AppendAssociatedDamageProcs(lines, GetSetNameForProcName(abilityName))

    if GetAbilityDuration and abilityId then
        local durationMs = GetAbilityDuration(abilityId, overrideRank, casterUnitTag)
        if durationMs and durationMs > 0 then
            local durationSeconds = math.floor(durationMs / 1000 + 0.5)
            lines[#lines + 1] = string.format("Ability duration: %ds", durationSeconds)
        end
    end

    if GetAbilityFrequencyMS and abilityId then
        local frequencyMs = GetAbilityFrequencyMS(abilityId, casterUnitTag)
        if frequencyMs and frequencyMs > 0 then
            local frequencySeconds = math.floor(frequencyMs / 1000 + 0.5)
            lines[#lines + 1] = string.format("Tick frequency: %ds", frequencySeconds)
        end
    end

    if GetAbilityCastInfo and abilityId then
        local channeled, castMs = GetAbilityCastInfo(abilityId, overrideRank, casterUnitTag)
        if channeled ~= nil then
            local label = channeled and "Channel time" or "Cast time"
            if castMs and castMs > 0 then
                local castSeconds = math.floor(castMs / 1000 + 0.5)
                lines[#lines + 1] = string.format("%s: %ds", label, castSeconds)
            else
                lines[#lines + 1] = string.format("%s: instant", label)
            end
        end
    end

    if GetAbilityTargetDescription and abilityId then
        local targetDesc = GetAbilityTargetDescription(abilityId, overrideRank, casterUnitTag)
        if targetDesc and targetDesc ~= "" then
            lines[#lines + 1] = string.format("Target: %s", targetDesc)
        end
    end

    return table.concat(lines, "\n")
end

local DISCOVERED_SECTION_KEY = "section:discover"
local TRACKERS_SECTION_KEY = "section:trackers"
local DETAILS_SECTION_KEY_PREFIX = "section:details:"
local TRACKER_SELECT_KEY_PREFIX = "tracker:select:"
local TRACKER_ENABLED_KEY_PREFIX = "tracker:enabled:"
local TRACKER_COOLDOWN_KEY_PREFIX = "tracker:cooldown:"
local TRACKER_MIN_STACKS_KEY_PREFIX = "tracker:min-stacks:"
local TRACKER_HIDE_KEY_PREFIX = "tracker:hide:"
local TRACKER_REMOVE_KEY_PREFIX = "tracker:remove:"

---@param tracker TrackerDefinition|nil
---@param trackerId string|nil
---@return string
local function GetTrackerBaseName(tracker, trackerId)
    local baseName = tracker and tracker.name
    if type(baseName) ~= "string" or baseName == "" then
        baseName = tostring(trackerId or "Unknown")
    end
    return baseName
end

---@param tracker TrackerDefinition|nil
---@param trackerId string|nil
---@return string
local function GetTrackerDisplayName(tracker, trackerId)
    local baseName = GetTrackerBaseName(tracker, trackerId)
    if tracker and tracker.abilityId then
        return string.format("%s [%d]", baseName, tracker.abilityId)
    end
    if tracker and tracker.setId then
        return string.format("%s [Set %d]", baseName, tracker.setId)
    end
    return baseName
end

local function RefreshTrackerUI()
    if CooldownTracker and CooldownTracker.RefreshUI then
        CooldownTracker:RefreshUI()
    end
end

---@param trackerTable table<string, TrackerDefinition>|nil
---@param trackerId string|nil
---@param tracker TrackerDefinition|nil
---@param TrackingActions any|nil
local function SaveTrackerUpdate(trackerTable, trackerId, tracker, TrackingActions)
    if not trackerTable or type(trackerId) ~= "string" or trackerId == "" then
        return
    end

    if tracker then
        tracker.id = trackerId
        trackerTable[trackerId] = tracker
        if TrackingActions and TrackingActions.SetTracker then
            TrackingActions.SetTracker(tracker)
        end
    else
        trackerTable[trackerId] = nil
        if TrackingActions and TrackingActions.RemoveTracker then
            TrackingActions.RemoveTracker(trackerId)
        end
    end

    RefreshTrackerUI()
end

function SettingsActions:Rebuild()
    local LAS = _G["LibHarvensAddonSettings"]
    if not LAS or not self.addonSettings then
        return
    end

    local selectionKey, selectionIndex = CaptureSelectedSetting()
    local activeSectionKey = GetActiveSectionKey()

    -- Rebuilds recreate every section as a new object, so the library's drill-down
    -- reference goes stale. Drop back to the main list first so the teardown and
    -- re-add render against a valid list; RestoreNavigation re-drills afterward.
    -- Only while the scene is showing: SetCurrentList activates the gamepad list,
    -- which would steal directional input if the user is out in the world.
    if self:IsPanelSelected() and IsSettingsSceneShowing() then
        SetActiveListToMain()
    end

    -- Clear existing settings (rebuild on demand)
    self.addonSettings:RemoveAllSettings(false)

    local FramesActions = CooldownTracker.FramesActions
    local TrackingActions = CooldownTracker.TrackingActions
    local settingsConfig = GetSettingsConfig()
    local sv = CooldownTracker.savedVars
    local trackerTable = (sv and sv.trackers) or {}

    local watchActive = TrackingActions and TrackingActions.IsCombatDiscoveryActive and
        TrackingActions.IsCombatDiscoveryActive() or false
    AddSection(self.addonSettings, "Combat Discovery", "section:combat-discovery")
    AddCheckbox(self.addonSettings, "Watch combat",
        "Turn this on, trigger the effects, turn it off, and select the effect from the list. Auto-disables after 30s.",
        function()
            return watchActive
        end, function(value)
            if not TrackingActions then return end
            if value then
                TrackingActions.StartCombatDiscovery()
            else
                TrackingActions.StopCombatDiscovery()
            end
            self:ScheduleRebuild()
        end, "discovery:watch")

    local recents = (TrackingActions and TrackingActions.GetRecentProcs) and TrackingActions.GetRecentProcs() or {}
    if #recents > 0 then
        AddButton(self.addonSettings, "Clear List", "Clear recent effects list.", function()
            if TrackingActions and TrackingActions.ClearRecentProcs then
                TrackingActions.ClearRecentProcs()
            end
            self:ScheduleRebuild()
        end, "recents:clear")
    end

    AddSection(self.addonSettings, "Discover effects", DISCOVERED_SECTION_KEY)

    local untrackedRecents = {}
    for i = 1, #recents do
        local proc = recents[i]
        local abilityId = proc and proc.abilityId
        if type(abilityId) == "number" and abilityId > 0 then
            local trackerId = tostring(abilityId)
            if not trackerTable[trackerId] then
                untrackedRecents[#untrackedRecents + 1] = proc
            end
        end
    end

    if #untrackedRecents == 0 then
        if watchActive then
            AddLabel(self.addonSettings, "Waiting for untracked effects...")
        else
            AddLabel(self.addonSettings, "No untracked effects yet.")
        end
    else
        for i = 1, #untrackedRecents do
            local proc = untrackedRecents[i]
            local displayName = string.format("%s [%d]", proc.name or "Unknown", proc.abilityId or 0)
            local tooltip = FormatRecentTooltip(proc)
            local selectionKey = string.format("recent:select:%d", proc.abilityId or 0)
            AddButton(self.addonSettings, displayName, tooltip, function()
                if CooldownTracker and CooldownTracker.AddOrUpdateTracker then
                    local TrackingUtils = CooldownTracker.TrackingUtils
                    local cooldown = (TrackingUtils and TrackingUtils.EstimateInitialCooldownSeconds)
                        and TrackingUtils.EstimateInitialCooldownSeconds(proc.abilityId, 10) or 10
                    local nameOverride = proc.name
                    if type(nameOverride) ~= "string" or nameOverride == "" then
                        nameOverride = nil
                    end
                    CooldownTracker:AddOrUpdateTracker(proc.abilityId, cooldown, nameOverride, nil)
                end
                if TrackingActions and TrackingActions.RemoveRecentProc and type(proc.abilityId) == "number" then
                    TrackingActions.RemoveRecentProc(proc.abilityId)
                end
                self:ScheduleRebuild()
            end, selectionKey)
        end
    end

    local trackerIds = {}
    for id in pairs(trackerTable) do
        trackerIds[#trackerIds + 1] = id
    end
    table.sort(trackerIds)

    AddSection(self.addonSettings, "Trackers", TRACKERS_SECTION_KEY)
    if #trackerIds == 0 then
        AddLabel(self.addonSettings, "No Saved Trackers")
    else
        for _, id in ipairs(trackerIds) do
            local tracker = trackerTable[id]
            local label = string.format("Edit: %s", GetTrackerDisplayName(tracker, id))
            local tooltip = FormatTrackerTooltip(tracker)
            local selectionKey = string.format("%s%s", TRACKER_SELECT_KEY_PREFIX, tostring(id))
            AddButton(self.addonSettings, label, tooltip, function()
                self.selectedTrackerId = tostring(id)
                self.returnSelectionKey = selectionKey
                self.pendingSelectionKey = string.format("%s%s", TRACKER_ENABLED_KEY_PREFIX, tostring(id))
                self:ScheduleRebuild()
            end, selectionKey)
        end
    end

    local selectedTrackerId = self.selectedTrackerId
    local selectedTracker = selectedTrackerId and trackerTable[selectedTrackerId] or nil
    if selectedTrackerId and not selectedTracker then
        self.selectedTrackerId = nil
        self.returnSelectionKey = nil
        selectedTrackerId = nil
    end

    if selectedTrackerId and selectedTracker then
        local detailsKey = string.format("%s%s", DETAILS_SECTION_KEY_PREFIX, tostring(selectedTrackerId))
        local detailsName = GetTrackerBaseName(selectedTracker, selectedTrackerId)
        AddSection(self.addonSettings, detailsName, detailsKey)

        AddCheckbox(self.addonSettings, "Enabled", "Enable or disable this tracker.", function()
            return selectedTracker.enabled ~= false
        end, function(value)
            selectedTracker.enabled = value == true
            SaveTrackerUpdate(trackerTable, selectedTrackerId, selectedTracker, TrackingActions)
            self.pendingSelectionKey = string.format("%s%s", TRACKER_ENABLED_KEY_PREFIX, tostring(selectedTrackerId))
            self:ScheduleRebuild()
        end, string.format("%s%s", TRACKER_ENABLED_KEY_PREFIX, tostring(selectedTrackerId)))

        AddSlider(self.addonSettings, "Cooldown (seconds)",
            "Seconds. Use 0 for permanent after trigger. Use -1 to show while buff is missing. Use -2 to follow effect timer.",
            -2, 300, 1, "%.0f", function()
                return tonumber(selectedTracker.cooldownSeconds) or 0
            end, function(value)
                local nextValue = tonumber(value)
                if nextValue == nil then
                    return
                end
                if nextValue < -1 then
                    nextValue = -2
                elseif nextValue < 0 then
                    nextValue = -1
                end
                selectedTracker.cooldownSeconds = nextValue
                if nextValue < 0 then
                    -- Negative cooldowns are effect-style trackers; ensure we listen to EFFECT_CHANGED.
                    selectedTracker.useCombatEvent = false
                end
                SaveTrackerUpdate(trackerTable, selectedTrackerId, selectedTracker, TrackingActions)
            end, string.format("%s%s", TRACKER_COOLDOWN_KEY_PREFIX, tostring(selectedTrackerId)))

        local selectedCooldownSeconds = tonumber(selectedTracker.cooldownSeconds) or 0
        if selectedTracker.isStackable == true or selectedCooldownSeconds == -1 then
            local isMissingBuffMode = selectedCooldownSeconds == -1
            local minStacksMin = isMissingBuffMode and 1 or 0
            local minStacksTooltip = isMissingBuffMode
                and "Hide the missing-buff icon once the effect has at least this many stacks."
                or "Hide this tracker until the effect has at least this many stacks."
            AddSlider(self.addonSettings, "Minimum stacks",
                minStacksTooltip,
                minStacksMin, 20, 1, "%.0f", function()
                    return tonumber(selectedTracker.minStacksToShow) or minStacksMin
                end, function(value)
                    local nextValue = tonumber(value)
                    if nextValue == nil then
                        return
                    end
                    selectedTracker.minStacksToShow = nextValue
                    SaveTrackerUpdate(trackerTable, selectedTrackerId, selectedTracker, TrackingActions)
                end, string.format("%s%s", TRACKER_MIN_STACKS_KEY_PREFIX, tostring(selectedTrackerId)))
        end

        AddCheckbox(self.addonSettings, "Show only during combat",
            "When enabled, this tracker is hidden while out of combat.", function()
                return selectedTracker.hideOutsideCombat == true
            end, function(value)
                selectedTracker.hideOutsideCombat = value == true
                SaveTrackerUpdate(trackerTable, selectedTrackerId, selectedTracker, TrackingActions)
            end, string.format("%s%s", TRACKER_HIDE_KEY_PREFIX, tostring(selectedTrackerId)))

        AddButton(self.addonSettings, "Remove Tracker",
            "Remove this tracker from the saved list.", function()
                SaveTrackerUpdate(trackerTable, selectedTrackerId, nil, TrackingActions)
                self.selectedTrackerId = nil
                self.returnSelectionKey = nil
                self.pendingSelectionKey = TRACKERS_SECTION_KEY
                self:ScheduleRebuild()
            end, string.format("%s%s", TRACKER_REMOVE_KEY_PREFIX, tostring(selectedTrackerId)))
    end

    AddSection(self.addonSettings, "Frame", "section:frame")
    AddCheckbox(self.addonSettings, "Show preview",
        "Fake icons appear after you exit the settings menu while this is enabled.", function()
            return settingsConfig and settingsConfig.showPreviewInSettings or false
        end, function(value)
            if not settingsConfig then return end
            settingsConfig.showPreviewInSettings = value
            self:UpdatePreviewState()
        end, "frame:preview")

    AddDropdown(self.addonSettings, "Stack display",
        "Controls how stack counts are drawn on each icon.",
        STACK_DISPLAY_ITEMS, function()
            local cfg = GetMainFrameConfig()
            local current = cfg and cfg.stackDisplayMode or "overlay"
            return STACK_DISPLAY_NAME_BY_VALUE[current] or STACK_DISPLAY_ITEMS[1].name
        end, function(_, _, item)
            local cfg = GetMainFrameConfig()
            if not cfg then return end
            cfg.stackDisplayMode = item and item.data or cfg.stackDisplayMode
            local frame = GetMainFrame()
            if frame and FramesActions and FramesActions.SetStackDisplayMode then
                FramesActions.SetStackDisplayMode(frame, cfg.stackDisplayMode)
            end
            if CooldownTracker and CooldownTracker.RefreshUI then
                CooldownTracker:RefreshUI()
            end
        end, "frame:stack-display")

    AddSlider(self.addonSettings, "Scale (%)", "Adjust the size of the tracker frame.", 50, 200, 5, "%.0f", function()
        local cfg = GetMainFrameConfig()
        return cfg and math.floor((cfg.scale or 1) * 100 + 0.5) or 100
    end, function(value)
        local cfg = GetMainFrameConfig()
        if not cfg then return end
        cfg.scale = (value or 100) / 100
        local frame = GetMainFrame()
        if frame and FramesActions and FramesActions.SetScale then
            FramesActions.SetScale(frame, cfg.scale)
        end
    end, "frame:scale")

    AddSlider(self.addonSettings, "Opacity (%)", "Adjust the frame opacity.", 20, 100, 5, "%.0f", function()
        local cfg = GetMainFrameConfig()
        return cfg and math.floor((cfg.alpha or 1) * 100 + 0.5) or 100
    end, function(value)
        local cfg = GetMainFrameConfig()
        if not cfg then return end
        cfg.alpha = (value or 100) / 100
        local frame = GetMainFrame()
        if frame and FramesActions and FramesActions.SetAlpha then
            FramesActions.SetAlpha(frame, cfg.alpha)
        end
    end, "frame:opacity")

    AddSlider(self.addonSettings, "X Position", "Horizontal position (pixels).", 0, 2000, 10, "%.0f", function()
        local cfg = GetMainFrameConfig()
        return cfg and cfg.x or 0
    end, function(value)
        local cfg = GetMainFrameConfig()
        if not cfg then return end
        cfg.x = value or cfg.x
        ApplyMainFramePosition()
    end, "frame:x")

    AddSlider(self.addonSettings, "Y Position", "Vertical position (pixels).", 0, 1200, 10, "%.0f", function()
        local cfg = GetMainFrameConfig()
        return cfg and cfg.y or 0
    end, function(value)
        local cfg = GetMainFrameConfig()
        if not cfg then return end
        cfg.y = value or cfg.y
        ApplyMainFramePosition()
    end, "frame:y")

    self:UpdatePreviewState()
    local restoreKey = self.pendingSelectionKey or selectionKey
    self.pendingSelectionKey = nil
    RestoreNavigation(self.addonSettings, restoreKey, selectionIndex, activeSectionKey)
end

function SettingsActions.Initialize()
    if SettingsActions.initialized then
        return
    end
    SettingsActions.initialized = true

    local LAS = _G["LibHarvensAddonSettings"]
    if not LAS or not LAS.AddAddon then
        if CooldownTracker and CooldownTracker.Log then
            CooldownTracker:Log("LibHarvensAddonSettings not available; settings menu disabled.")
        end
        return
    end

    -- Register this addon with LibHarvensAddonSettings.
    -- The library will create its UI once when the options scene opens.
    local panel = LAS:AddAddon("Cooldown Tracker", { allowRefresh = true })
    panel.author = "clubwratt"
    panel.version = "v" .. tostring(CooldownTracker.version)

    SettingsActions.addonSettings = panel
    SettingsActions:Rebuild()

    local function addonSelected(_, addonSettings)
        if not SettingsActions.addonSettings then
            return
        end
        -- Update preview state whenever selection changes.
        SettingsActions:UpdatePreviewState()
    end
    CALLBACK_MANAGER:RegisterCallback("LibHarvensAddonSettings_AddonSelected", addonSelected)
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", addonSelected)

    -- When discovery/recents update, rebuild the panel if it is currently selected.
    local TrackingActions = CooldownTracker and CooldownTracker.TrackingActions
    if TrackingActions and TrackingActions.CALLBACK_RECENTS_UPDATED then
        CALLBACK_MANAGER:RegisterCallback(TrackingActions.CALLBACK_RECENTS_UPDATED, function()
            if SettingsActions:IsPanelSelected() then
                SettingsActions:ScheduleRebuild()
            end
        end)
    end
end

return SettingsActions
