-- CooldownTrackerMain.lua
-- Main initialization and update loop using the modular architecture
local CooldownTracker = _G["CooldownTracker"]

local function Log(msg)
    if CooldownTracker and CooldownTracker.Log then
        CooldownTracker:Log(msg)
    end
end

local function SafeCall(label, fn, ...)
    local function ErrorHandler(err)
        if debug and debug.traceback then
            return debug.traceback(tostring(err), 2)
        end
        return tostring(err)
    end

    local args = { ... }
    local ok, result = xpcall(function()
        return fn(unpack(args))
    end, ErrorHandler)
    if not ok then
        Log(string.format("%s failed: %s", tostring(label), tostring(result)))
        return false
    end
    return true
end

--- Initialize the update loop for refreshing UI
local function StartUpdateLoop()
    if CooldownTracker.refreshHandle then
        return
    end

    local handle = CooldownTracker.name .. "_Update"
    CooldownTracker.refreshHandle = handle

    EVENT_MANAGER:RegisterForUpdate(handle, 100, function()
        SafeCall("RefreshUI", function()
            CooldownTracker:RefreshUI()
        end)
    end)
end

--- Refresh the UI with current active cooldowns
function CooldownTracker:RefreshUI()
    local FramesActions = self.FramesActions
    local TrackingActions = self.TrackingActions

    if not FramesActions or not TrackingActions then
        return
    end

    local frame = FramesActions.GetFrame("main")
    if not frame then
        return
    end

    local entries
    if self.previewActive and self.GetPreviewEntries then
        entries = self:GetPreviewEntries()
    else
        entries = TrackingActions.GetActiveEntries()
        local isInCombat = IsUnitInCombat("player") == true
        local write = 0
        local count = #entries
        for i = 1, count do
            local entry = entries[i]
            local tracker = TrackingActions.GetTracker(entry.id)
            local keep = true

            if tracker then
                local cooldownSeconds = tonumber(tracker.cooldownSeconds) or 0

                if tracker.enabled == false then
                    keep = false
                end

                -- Stack thresholds are used to hide stackable effects until they build up.
                -- Missing-buff trackers (cooldownSeconds == -1) invert the meaning, so don't drop them here.
                if keep and tracker.isStackable == true and cooldownSeconds ~= -1 then
                    local stacks = type(entry.stackCount) == "number" and entry.stackCount or 0
                    local minStacks = tonumber(tracker.minStacksToShow) or 0
                    if stacks < minStacks then
                        keep = false
                    end

                    if keep and cooldownSeconds <= 0 and stacks <= 0 then
                        keep = false
                    end
                end

                if keep and not isInCombat and tracker.hideOutsideCombat == true then
                    keep = false
                end
            end

            if keep then
                write = write + 1
                entries[write] = entry
            end
        end

        for i = write + 1, count do
            entries[i] = nil
        end
    end

    if #entries == 0 then
        FramesActions.ShowEmpty(frame)
    else
        FramesActions.RenderEntries(frame, entries)
    end
end

--- Refresh equipped sets and update trackers
function CooldownTracker:RefreshEquippedSets()
    local TrackingActions = self.TrackingActions
    if not TrackingActions then
        return
    end

    TrackingActions.RefreshEquippedSets()
    if TrackingActions.SyncMissingBuffTrackers then
        TrackingActions.SyncMissingBuffTrackers()
    end

    self:RefreshUI()
end

--- Disable watchcombat if active
---@param reason string|nil
function CooldownTracker:DisableWatchCombat(reason)
    local TrackingActions = self.TrackingActions
    if TrackingActions and TrackingActions.IsCombatDiscoveryActive and TrackingActions.IsCombatDiscoveryActive() then
        TrackingActions.StopCombatDiscovery()
        self:Log(reason or "Watchcombat disabled.")
    end
end

--- Add or update a tracker from an abilityId
---@param abilityId number
---@param cooldown number
---@param nameOverride string|nil
---@param initialHitResult number|nil
---@return boolean
function CooldownTracker:AddOrUpdateTracker(abilityId, cooldown, nameOverride, initialHitResult)
    local TrackingActions = self.TrackingActions
    if not TrackingActions then
        self:Log("TrackingActions not initialized")
        return false
    end

    -- Determine event mode based on how this ability was last observed.
    -- If seen in recents via effect changed, use effect mode; otherwise default to combat.
    local recentProc = TrackingActions.GetRecentProc(abilityId)
    local useCombatEvent = true -- Default to combat event for hidden procs
    if recentProc and recentProc.lastSource == "effect" then
        useCombatEvent = false -- Use effect changed for buffs/effects seen that way
    end
    -- Cooldown 0 means "permanent after trigger"; keep combat default unless seen via effect.
    -- Negative cooldowns use effect changed (-1 = missing-buff mode, -2 = follow effect timer).
    if cooldown < 0 then
        useCombatEvent = false
    end

    local hitResult = initialHitResult
    if hitResult == nil and recentProc and recentProc.lastSource == "combat" then
        hitResult = recentProc.lastResult
    end
    if not useCombatEvent then
        hitResult = nil
    end

    -- Support explicit name override; otherwise prefer the most recently observed name.
    local name = nameOverride
    if not name or name == "" then
        if recentProc and recentProc.name and recentProc.name ~= "" then
            name = recentProc.name
        else
            name = zo_strformat("<<t:1>>", GetAbilityName(abilityId or 0, nil))
        end
    end

    local trackerId = tostring(abilityId)
    local existingTracker = TrackingActions.GetTracker(trackerId)
    local isUpdate = existingTracker ~= nil
    local hideOutsideCombat = existingTracker and existingTracker.hideOutsideCombat == true or false
    local isStackable = existingTracker and existingTracker.isStackable or nil
    local minStacksToShow = existingTracker and existingTracker.minStacksToShow or nil

    local trackerDef = {
        id = trackerId,
        abilityId = abilityId,
        setId = nil,
        name = name,
        cooldownSeconds = cooldown,
        enabled = true,
        iconMode = TrackingActions.ICON_MODE.AUTO,
        customIcon = nil,
        useCombatEvent = useCombatEvent,
        initialHitResult = type(hitResult) == "number" and hitResult or nil,
        hideOutsideCombat = hideOutsideCombat,
        isStackable = isStackable,
        minStacksToShow = minStacksToShow,
    }

    TrackingActions.SetTracker(trackerDef)

    -- Save to savedvars
    if self.savedVars and self.savedVars.trackers then
        self.savedVars.trackers[trackerId] = trackerDef
    end

    local modeStr = useCombatEvent and "combat" or "effect"
    if isUpdate then
        self:Log(string.format("Updated tracker: %s [%d] - %ds cooldown (%s mode)", name, abilityId, cooldown, modeStr))
    else
        self:Log(string.format("Added tracker: %s [%d] - %ds cooldown (%s mode)", name, abilityId, cooldown, modeStr))
    end

    self:DisableWatchCombat("Watchcombat disabled after adding a tracker.")
    return true
end

--- Main initialization
function CooldownTracker:Initialize()
    -- Load savedvars
    self.savedVars = ZO_SavedVars:NewAccountWide(
        self.savedVarsName,
        self.savedVarsVersion,
        nil,
        self.GetDefaults()
    )
    if self.State then
        self.State.savedVars = self.savedVars
    end

    self.playerName = zo_strformat("<<t:1>>", GetUnitName("player"))
    if self.State then
        self.State.playerName = self.playerName
    end

    -- Initialize modules
    local FramesActions = self.FramesActions
    local TrackingActions = self.TrackingActions
    local SettingsActions = self.SettingsActions

    if not FramesActions or not TrackingActions then
        Log("ERROR: Required modules not loaded")
        return
    end

    -- Compatibility aliases (older module naming)
    self.TrackerFrames = FramesActions
    self.TrackerManager = TrackingActions
    self.Settings = SettingsActions

    -- Refresh equipped sets
    TrackingActions.RefreshEquippedSets()

    -- Load user-configured trackers from savedvars
    if self.savedVars.trackers then
        TrackingActions.LoadTrackers(self.savedVars.trackers)
    end

    -- Create the main display frame
    local frameConfig = self.savedVars.frames and self.savedVars.frames.main
    if frameConfig then
        -- Minimal UI: no title text above icons.
        frameConfig.showTitle = false
        FramesActions.CreateFrame(frameConfig)
    end

    -- Ensure watchcombat is off on login
    if TrackingActions and TrackingActions.StopCombatDiscovery then
        TrackingActions.StopCombatDiscovery()
    end

    -- Start update loop
    StartUpdateLoop()

    -- Initialize settings (optional dependency)
    if SettingsActions and SettingsActions.Initialize then
        SafeCall("Settings.Initialize", function()
            SettingsActions.Initialize()
        end)
    end

    -- Register events
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function()
        SafeCall("OnPlayerActivated", function()
            CooldownTracker:RefreshEquippedSets()
        end)
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
        if bagId ~= BAG_WORN then return end
        SafeCall("OnInventoryUpdate", function()
            CooldownTracker:RefreshEquippedSets()
        end)
    end)
    EVENT_MANAGER:AddFilterForEvent(self.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, function()
        SafeCall("OnArmoryRestore", function()
            CooldownTracker:RefreshEquippedSets()
        end)
    end)

    Log(string.format("Loaded v%s", self.version))
end

-- Addon loaded handler
EVENT_MANAGER:RegisterForEvent(CooldownTracker.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= CooldownTracker.name then
        return
    end

    SafeCall("Initialize", function()
        CooldownTracker:Initialize()
    end)

    EVENT_MANAGER:UnregisterForEvent(CooldownTracker.name, EVENT_ADD_ON_LOADED)
end)
