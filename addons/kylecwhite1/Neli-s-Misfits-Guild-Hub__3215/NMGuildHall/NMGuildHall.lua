-- Main initialization and coordination for the NMGuildHall addon
-- 
-- Module Dependencies:
--   Required: EventManager, Message, Validator, Compatibility
--   Feature: Settings, ChatIcon, Teleport, Quests, Campaign, Seasonal, UI
--   Data: NMGuildHallTeleportData, NMGuildHallPledges
-- Define the main addon table
NMGuildHall = NMGuildHall or {}
local Addon = NMGuildHall
local Constants = Addon.Constants
local DEFAULT_GUILD_ID = (Constants and Constants.ADDON and Constants.ADDON.DEFAULT_GUILD_ID) or 716827

local function DeepCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end

    seen = seen or {}
    if seen[value] then
        return seen[value]
    end

    local copy = {}
    seen[value] = copy

    for key, nestedValue in pairs(value) do
        copy[DeepCopy(key, seen)] = DeepCopy(nestedValue, seen)
    end

    return copy
end

Addon.db = Addon.db
Addon.guildId = Addon.guildId or DEFAULT_GUILD_ID
Addon.version = Addon.version or (Constants and Constants.ADDON and Constants.ADDON.VERSION) or "9"
Addon.name = Addon.name or (Constants and Constants.ADDON and Constants.ADDON.NAME) or "NMGuildHall"
Addon.displayName = Addon.displayName or (Constants and Constants.ADDON and Constants.ADDON.DISPLAY_NAME) or "|cea4e49Neli's Misfits Guild Hub|r"
if not Addon.defaults then
    Addon.defaults = {
        showChatIcon = (Constants and Constants.CHAT_ICON and Constants.CHAT_ICON.DEFAULT_SHOW) or true,
        monochromeIcon = (Constants and Constants.CHAT_ICON and Constants.CHAT_ICON.DEFAULT_MONOCHROME) or false,
        chatIconStyle = "new",
        chatIconSize = (Constants and Constants.CHAT_ICON and Constants.CHAT_ICON.DEFAULT_SIZE) or 36,
        chatIconLocked = true,
        chatIconX = nil,
        chatIconY = nil,
        noGuildLeave = 0,
        guildId = DEFAULT_GUILD_ID,
        zoneCacheDurationSeconds = (Constants and Constants.TELEPORT and Constants.TELEPORT.DEFAULT_CACHE_DURATION_SECONDS) or 30,
        zoneCacheRefreshCooldownSeconds = (Constants and Constants.TELEPORT and Constants.TELEPORT.DEFAULT_REFRESH_COOLDOWN_SECONDS) or 5,
        zoneCacheRebuildMode = (Constants and Constants.TELEPORT and Constants.TELEPORT.DEFAULT_REBUILD_MODE) or "stale_async",
        messageRateLimit = (Constants and Constants.MESSAGE and Constants.MESSAGE.DEFAULT_RATE_LIMIT) or 5,
        messageRateLimitWindow = (Constants and Constants.MESSAGE and Constants.MESSAGE.DEFAULT_RATE_WINDOW_MS) or 1000,
        maxGuildMembersToCheck = (Constants and Constants.TELEPORT and Constants.TELEPORT.DEFAULT_MAX_MEMBERS_TO_CHECK) or 100,
        dynamicGuildScanScaling = true,
        settingsVersion = (Constants and Constants.ADDON and Constants.ADDON.SETTINGS_VERSION) or 6,
        appliedProfile = "Balanced",
        windowWidth = (Constants and Constants.WINDOW and Constants.WINDOW.DEFAULT_WIDTH) or 700,
        windowHeight = (Constants and Constants.WINDOW and Constants.WINDOW.DEFAULT_HEIGHT) or 550,
        debug = false,
        hideGoldenPursuits = false,
        seasonal = {
            enabled = true,
            ownUi = true,
            chatMessages = true,
            nativeGuildUi = true,
            keepOwnership = true,
            traderUi = true,
            eventOverrides = {
                misfitsBirthday = {
                    enabled = false,
                    timezone = "America/New_York",
                    start = { year = 0, month = 0, day = 0, hour = 0, min = 0, sec = 0 },
                    ["end"] = { year = 0, month = 0, day = 0, hour = 23, min = 59, sec = 59 },
                },
            },
        },
        windowX = (Constants and Constants.WINDOW and Constants.WINDOW.DEFAULT_X) or 0,
        windowY = (Constants and Constants.WINDOW and Constants.WINDOW.DEFAULT_Y) or 0,

        -- Campaign queue widget (top-level, only visible while queued)
        queueWidgetEnabled = false,
        queueWidgetLocked = true,
        queueWidgetX = nil,
        queueWidgetY = nil,
        queueWidgetScale = 1.0,
    }
end
Addon.panel = Addon.panel
Addon.chatIcon = Addon.chatIcon
Addon.UI = Addon.UI
Addon.modulesLoaded = Addon.modulesLoaded or {
    data = false,
    ui = false,
    message = false,
    eventManager = false,
    validator = false,
    compatibility = false,
    seasonal = false,
    teleport = false,
    quests = false,
    campaign = false,
    settings = false,
    queueWidget = false,
}
Addon.initialized = Addon.initialized or false

function NMGuildHall.FormatShortTime(seconds)
    if not seconds or seconds <= 0 then
        return ""
    end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    if days > 0 then
        return string.format("%dd %dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, mins)
    else
        return string.format("%dm", mins)
    end
end

function NMGuildHall:_ChatOut(message)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(message)
    elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        CHAT_SYSTEM:AddMessage(message)
    else
        d(message)
    end
end

function NMGuildHall:_FormatMessage(level, text)
    local prefix = "[NMGuildHub] "
    local color
    if level == "ERROR" then
        color = "ff3333"
    elseif level == "WARNING" then
        color = "ffcc33"
    elseif level == "DEBUG" then
        color = "9aa0a6"
    else
        color = "ea4e49"
    end
    return string.format("|c%s%s%s|r", color, prefix, tostring(text))
end

function NMGuildHall:Msg(text, placeholders)
    if self.Message and self.Message.Info then
        self.Message:Info(text, placeholders)
    else
        self:_ChatOut(self:_FormatMessage("INFO", text))
    end
end

function NMGuildHall:Warn(text, placeholders)
    if self.Message and self.Message.Warn then
        self.Message:Warn(text, placeholders)
    else
        self:_ChatOut(self:_FormatMessage("WARNING", text))
    end
end

function NMGuildHall:Err(text, placeholders)
    if self.Message and self.Message.Error then
        self.Message:Error(text, placeholders)
    else
        self:_ChatOut(self:_FormatMessage("ERROR", text))
    end
end

function NMGuildHall:Debug(text, placeholders)
    if self.Message and self.Message.Debug then
        self.Message:Debug(text, placeholders)
        return
    end

    if self:IsDebugEnabled() then
        self:_ChatOut(self:_FormatMessage("DEBUG", text))
    end
end

function NMGuildHall:IsDebugEnabled()
    return self.db ~= nil and self.db.debug == true
end

-- Get configurable guild ID
function NMGuildHall:GetGuildId()
    return (self.db and self.db.guildId) or self.guildId or DEFAULT_GUILD_ID
end

function NMGuildHall:Initialize()
    -- Check if required data is loaded
    if not NMGuildHallTeleportData or not NMGuildHallPledges then
        self:Err(GetString(NMGH_ERR_DATA_NOT_LOADED))
        return
    end
    
    -- 1. Initialize database first so it's available to all modules
    local success, db = pcall(function()
        local savedVarsName = (Constants and Constants.ADDON and Constants.ADDON.SAVED_VARS_NAME) or "NeliMisfitsSavedVars"
        return ZO_SavedVars:NewAccountWide(savedVarsName, 1, nil, self.defaults)
    end)
    
    if not success or not db then
        self.db = DeepCopy(self.defaults)
    else
        self.db = db
    end

    -- 2. Initialize modules (Message, EventManager, etc.)
    self:InitializeModules()

    -- 3. Initialize core systems that depend on database and modules
    self:InitializeCoreSystems()
    
    -- Mark as fully initialized
    self.initialized = true
    
    -- Final startup feedback
    self:Msg(GetString(NMGH_MSG_INIT_SUCCESS))
    
    -- Display compatibility report at the very end
    if Addon.Compatibility and Addon.Compatibility.DisplayCompatibilityReport then
        Addon.Compatibility:DisplayCompatibilityReport()
    end
end

-- Initialize all modules
function NMGuildHall:InitializeModules()
    -- Modules are now loaded automatically via their export blocks
    -- Just check if they're available and initialize them
    
    -- Initialize Message module FIRST (other modules may depend on it)
    if Addon.Message then
        Addon.Message:Initialize()
        self.modulesLoaded.message = true
        self:Debug(GetString(NMGH_DEBUG_INIT_LOCALIZATION), {name = GetString(NMGH_NAME)})
    end
    
    -- Initialize Event Manager
    if Addon.EventManager then
        Addon.EventManager:Initialize()
        self.modulesLoaded.eventManager = true
    end
    
    -- Initialize Validator
    if Addon.Validator then
        Addon.Validator:Initialize()
        self.modulesLoaded.validator = true
    end
    
    -- Initialize Compatibility
    if Addon.Compatibility then
        Addon.Compatibility:Initialize()
        self.modulesLoaded.compatibility = true
    end

    if Addon.Seasonal then
        if Addon.Seasonal.Initialize then
            Addon.Seasonal:Initialize()
        end
        self.modulesLoaded.seasonal = true
    end
    
    -- Initialize Teleport
    if Addon.Teleport then
        if Addon.Teleport.Initialize then
            Addon.Teleport:Initialize()
        end
        self.modulesLoaded.teleport = true
    end
    
    -- Initialize Quests
    if Addon.Quests then
        if Addon.Quests.Initialize then
            Addon.Quests:Initialize()
        end
        self.modulesLoaded.quests = true
    end

    if Addon.Campaign then
        if Addon.Campaign.Initialize then
            Addon.Campaign:Initialize()
        end
        self.modulesLoaded.campaign = true
    end
    
    -- Initialize ChatIcon
    if Addon.ChatIcon then
        if Addon.ChatIcon.Initialize then
            Addon.ChatIcon:Initialize()
        end
        self.modulesLoaded.chatIcon = true
    end

    -- Initialize QueueWidget
    if Addon.QueueWidget then
        if Addon.QueueWidget.Initialize then
            Addon.QueueWidget:Initialize()
        end
        self.modulesLoaded.queueWidget = true
    end
    
    self:Debug(GetString(NMGH_DEBUG_MODULES_INIT))
end

-- Initialize core addon systems
function NMGuildHall:InitializeCoreSystems()
    -- Initialize Settings module (needs db to be set for migration and LAM2 setup)
    if Addon.Settings and Addon.Settings.Initialize then
        local success, err = pcall(Addon.Settings.Initialize, Addon.Settings)
        if success then
            self.modulesLoaded.settings = true
        else
            self:Err(GetString(NMGH_ERR_SETTINGS_INIT_FAILED), {error = tostring(err)})
        end
    else
        self:Warn(GetString(NMGH_ERR_SETTINGS_NOT_AVAILABLE))
    end

    -- Initialize chat icon — db is guaranteed set before this runs
    if not self._chatIconInitAttempted then
        self._chatIconInitAttempted = true
        if Addon.ChatIcon and Addon.ChatIcon.Create then
            local success, err = pcall(Addon.ChatIcon.Create, Addon.ChatIcon)
            if not success then
                self:Err(GetString(NMGH_ERR_CHATICON_INIT_FAILED), {error = tostring(err)})
            end
        else
            self:Warn(GetString(NMGH_ERR_CHATICON_NOT_AVAILABLE))
        end
    end

    -- Initialize queue widget -- db is guaranteed set before this runs
    if not self._queueWidgetInitAttempted then
        self._queueWidgetInitAttempted = true
        if Addon.QueueWidget and Addon.QueueWidget.Create then
            pcall(Addon.QueueWidget.Create, Addon.QueueWidget)
        end
    end
     
    -- Safe no guild leave initialization
    if self.InitializeNoGuildLeave then
        self:InitializeNoGuildLeave()
    end
    
    -- Register events using Event Manager
    self:RegisterCoreEvents()
    
    -- Safe UI initialization
    if self.UI and self.InitializeUI then
        self:InitializeUI()
    end
    
    self:RegisterSlashCommands()
    
    -- Apply Golden Pursuits visibility if enabled
    self:UpdateGoldenPursuitsVisibility()
end

-- Update Golden Pursuits UI visibility based on settings
function NMGuildHall:UpdateGoldenPursuitsVisibility()
    if not self.db then return end

    if PROMOTIONAL_EVENT_TRACKER and PROMOTIONAL_EVENT_TRACKER.Update and ZO_PostHook then
        if not self._nmghGoldenPursuitsHooked then
            self._nmghGoldenPursuitsHooked = true
            ZO_PostHook(PROMOTIONAL_EVENT_TRACKER, "Update", function(tracker)
                local addon = NMGuildHall
                if not (addon and addon.db and addon.db.hideGoldenPursuits) then
                    return
                end
                local fragment = tracker and tracker.GetFragment and tracker:GetFragment()
                if fragment and fragment.SetHiddenForReason then
                    fragment:SetHiddenForReason("NoTrackedPromotionalEvent", true, 0, 0)
                end
            end)
        end

        if self.db.hideGoldenPursuits then
            -- Hide immediately (and allow the hook to keep it hidden on future updates)
            pcall(function() PROMOTIONAL_EVENT_TRACKER:Update() end)
        else
            -- Best-effort unhide now; hook remains but is gated by SavedVars.
            local fragment = PROMOTIONAL_EVENT_TRACKER.GetFragment and PROMOTIONAL_EVENT_TRACKER:GetFragment()
            if fragment and fragment.SetHiddenForReason then
                pcall(function()
                    fragment:SetHiddenForReason("NoTrackedPromotionalEvent", false)
                end)
            end
            pcall(function() PROMOTIONAL_EVENT_TRACKER:Update() end)
        end
    end
end

-- Safe refresh wrapper with initialization guard
local function SafeRefresh()
    if not Addon.initialized then return end
    if Addon.Teleport and Addon.Teleport.RefreshZoneCache then
        Addon.Teleport:RefreshZoneCache()
    end
end

-- Register core events using Event Manager
function NMGuildHall:RegisterCoreEvents()
    local events = {
        [EVENT_GROUP_MEMBER_JOINED] = SafeRefresh,
        [EVENT_GROUP_MEMBER_LEFT] = SafeRefresh,
        [EVENT_ZONE_CHANGED] = SafeRefresh
    }
    
    if self.EventManager then
        self.EventManager:RegisterMultipleEvents(events, self.name)
    else
        self:Warn(GetString(NMGH_WARN_EVENT_MANAGER_NOT_AVAILABLE))
        for ev, handler in pairs(events) do
            EVENT_MANAGER:RegisterForEvent(self.name, ev, handler)
        end
    end
end

-- Cleanup function for addon shutdown
function NMGuildHall:Cleanup()
    self:Debug(GetString(NMGH_DEBUG_CLEANUP_START))
    
    -- Cancel pending initialization if it hasn't run yet
    if self.initHandle then
        zo_removeCallLater(self.initHandle)
        Addon.initHandle = nil
    end

    -- Restore seasonal hooks before dependent modules start tearing down.
    if Addon.Seasonal and Addon.Seasonal.Cleanup then
        pcall(Addon.Seasonal.Cleanup, Addon.Seasonal)
    end

    -- Cleanup UI
    if self.UI and self.UI.Cleanup then
        pcall(self.UI.Cleanup, self.UI)
    end
    
    -- Cleanup ChatIcon
    if Addon.ChatIcon and Addon.ChatIcon.Cleanup then
        pcall(Addon.ChatIcon.Cleanup, Addon.ChatIcon)
    end

    -- Cleanup QueueWidget
    if Addon.QueueWidget and Addon.QueueWidget.Cleanup then
        pcall(Addon.QueueWidget.Cleanup, Addon.QueueWidget)
    end
     
    -- Cleanup Teleport module
    if Addon.Teleport and Addon.Teleport.Cleanup then
        pcall(Addon.Teleport.Cleanup, Addon.Teleport)
    end
    
    -- Cleanup Quests module
    if Addon.Quests and Addon.Quests.Cleanup then
        pcall(Addon.Quests.Cleanup, Addon.Quests)
    end

    -- Cleanup Campaign module before the event manager tears down shared registrations.
    if Addon.Campaign and Addon.Campaign.Cleanup then
        pcall(Addon.Campaign.Cleanup, Addon.Campaign)
    end
    
    -- Cleanup Event Manager (last, as other modules may use it)
    if Addon.EventManager and Addon.EventManager.UnregisterAllEvents then
        pcall(Addon.EventManager.UnregisterAllEvents, Addon.EventManager)
    end
    
    -- Display final compatibility report
    if Addon.Compatibility and Addon.Compatibility.GetCompatibilityReport then
        local report = Addon.Compatibility:GetCompatibilityReport()
        self:Debug(GetString(NMGH_MSG_COMPAT_STATUS), {status = report.status})
    end
    
    -- Reset state
    self.initialized = false
    self._chatIconInitAttempted = false
    self._queueWidgetInitAttempted = false
    
    self:Debug(GetString(NMGH_DEBUG_CLEANUP_DONE))
end

function NMGuildHall:InitializeUI()
    if self.UI then
        self.UI:Initialize()
        self.modulesLoaded.ui = true
    end
end

function NMGuildHall.OnAddOnLoaded(_, addonName)
    if addonName == Addon.name then
        EVENT_MANAGER:UnregisterForEvent(Addon.name, EVENT_ADD_ON_LOADED)
        
        -- Delay to ensure all data is loaded and chat system is ready
        Addon.initHandle = zo_callLater(function()
            Addon.initHandle = nil
            local success, err = pcall(Addon.Initialize, Addon)
            if not success then
                Addon:Err(GetString(NMGH_ERR_INIT_FAILED), {error = tostring(err)})
            end
        end, (Constants and Constants.ADDON and Constants.ADDON.INIT_DEFER_MS) or 200)
    end
end

function NMGuildHall:CheckNoGuildLeave()
    if not GUILD_HOME or not GUILD_HOME.keybindStripDescriptor then return end

    -- Find the Leave Guild keybind safely by name
    local leaveText = GetString(SI_GUILD_LEAVE)
    local targetDescriptor = nil
    
    for _, desc in ipairs(GUILD_HOME.keybindStripDescriptor) do
        local name = desc.name
        if type(name) == "function" then name = name() end
        if name == leaveText then
            targetDescriptor = desc
            break
        end
    end

    if not targetDescriptor then
        -- Fallback: If we can't find it by name, we abort to be safe.
        -- Using index 1 blindly is unsafe as ZOS might change the order.
        self:Debug(GetString(NMGH_ERR_EVENT_NOT_FOUND), {eventName = "'Leave Guild' keybind"})
        return 
    end

    -- If already wrapped, we don't need to do anything as the wrapper handles the logic dynamically
    if targetDescriptor._nmghWrapped then 
        -- Just force an update if we can
        if KEYBIND_STRIP then
            KEYBIND_STRIP:UpdateKeybindButtonGroup(GUILD_HOME.keybindStripDescriptor)
        end
        return 
    end

    -- Save original visibility
    local originalVisible = targetDescriptor.visible
    
    -- Apply wrapper
    targetDescriptor.visible = function()
        -- 1. Check original visibility first
        if originalVisible then
            local isVisible = originalVisible
            if type(originalVisible) == "function" then
                isVisible = originalVisible()
            end
            if not isVisible then return false end
        end
        
        -- 2. Check NMGH restrictions
        local mode = self.db.noGuildLeave
        
        if mode == 0 then -- Off (Default)
            return true
        elseif mode == 2 then -- All Guilds
            return false
        elseif mode == 1 then -- Neli's Only
            local currentGuildId = GUILD_HOME.guildId
            local targetGuildId = self:GetGuildId()
            -- Ensure types match (sometimes numbers vs strings)
            if tonumber(currentGuildId) == tonumber(targetGuildId) then
                return false
            end
        end
        
        return true
    end
    
    targetDescriptor._nmghWrapped = true
    
    -- Only show message at startup if the feature is actually enabled (Off = 0)
    if self.db and self.db.noGuildLeave and self.db.noGuildLeave ~= 0 then
        self:Msg(GetString(NMGH_MSG_GUILD_LEAVE_PROTECT_ENABLED))
    end
end

function NMGuildHall:InitializeNoGuildLeave()
    -- Apply the wrapper once
    self:CheckNoGuildLeave()
    
    -- Hook RefreshAll to ensure it persists or to catch if descriptor is recreated
    if GUILD_HOME and GUILD_HOME.RefreshAll then
        ZO_PreHook(GUILD_HOME, "RefreshAll", function()
            self:CheckNoGuildLeave()
        end)
    end
end

-- Safe event registration
EVENT_MANAGER:RegisterForEvent(Addon.name, EVENT_ADD_ON_LOADED, Addon.OnAddOnLoaded)
