-- ============================================================================
-- Daily Pledge Manager v1.2.9
-- Author: DerpyNoodle
-- ============================================================================

local ADDON_NAME = "DailyPledgeManager"
local ADDON_DISPLAY_NAME = "Daily Pledge Manager"
local ADDON_VERSION = "1.2.9"
local LUP = LibUndauntedPledges

local DailyTracker = {}
_G.DailyPledgeManager = DailyTracker

-- ============================================================================
-- CHANGELOG (newest first)
-- ============================================================================
local CHANGELOG = {
    ["1.2.9"] = {
        "Fix — Queue actions now respect the Dungeon Finder cooldown. Previously, if you had a leave-early penalty active, clicking Queue All or a single dungeon would flip the addon to a fake \"queued\" state while ESO silently rejected the request, leaving you waiting for a pop that never came. Now the addon checks the cooldown first, refuses to queue, and tells you how much time is left.",
    },
    ["1.2.8"] = {
        "Fix — Abandon All now actually leaves the Dungeon Finder queue. Previously it cleared the visual state but the real ESO queue stayed active, so you could still get popped into a dungeon a few seconds after hitting Abandon All.",
    },
    ["1.2.7"] = {
        "Keybinds — Queue All (default: 9), Abandon All (default: 0), Toggle Window (default: -)",
        "Leave Queue — Queue All button turns orange when queued, click again to leave",
    },
}

-- ============================================================================
-- PLEDGE RESET TIMES (UTC)
-- ============================================================================
local RESET_TIMES = {
    NA = 10, -- 6:00 AM ET = 10:00 UTC
    EU = 3,  -- 3:00 UTC
}


-- ============================================================================
-- DEFAULT SETTINGS
-- ============================================================================
local defaults = {
    left = nil,  -- nil means center on first run
    top = nil,   -- nil means center on first run
    firstRun = true,
    windowVisible = true,
    collapsed = false,
    locked = false,
    preferVeteran = true,
    soundEnabled = true,
    soundOnQueuePop = SOUNDS.LFG_FIND_REPLACEMENT,
    windowOpacity = 0.92,
    showTooltips = true,
    lastKnownPledges = {},
    lastResetCheck = 0,
    notifyOnNewPledges = true,
    server = "NA",
    showCompassPins = true,
    showResetTimer = true,
    autoAcceptReadyCheck = false,
    autoAcceptPledges = false,
    lastSeenVersion = nil,
}

local sv
local SAVED_VARS_NAME = "DailyPledgeManagerVars"
local SAVED_VARS_VERSION = 1
local SV_MIGRATION_VERSION = 2

local SAVED_VARS_KEYS = {
    "left",
    "top",
    "firstRun",
    "windowVisible",
    "collapsed",
    "locked",
    "preferVeteran",
    "soundEnabled",
    "soundOnQueuePop",
    "windowOpacity",
    "showTooltips",
    "lastKnownPledges",
    "lastResetCheck",
    "notifyOnNewPledges",
    "server",
    "showCompassPins",
    "showResetTimer",
    "autoAcceptReadyCheck",
    "autoAcceptPledges",
    "lastSeenVersion",
}

local function GetServerSettingFromWorldName(worldName)
    if type(worldName) ~= "string" then return nil end

    local lowerWorldName = zo_strlower(worldName)
    if string.find(lowerWorldName, "eu") then
        return "EU"
    elseif string.find(lowerWorldName, "na") then
        return "NA"
    end

    return nil
end

local function GetServerNamespace()
    local worldName = GetWorldName()
    if type(worldName) == "string" and worldName ~= "" then
        return worldName
    end
    return nil
end

local function CopySavedVarValue(value)
    if type(value) == "table" then
        local copy = {}
        ZO_DeepTableCopy(value, copy)
        return copy
    end

    return value
end

local function IsSavedVarDataMeaningful(data)
    if not data then return false end

    for _, key in ipairs(SAVED_VARS_KEYS) do
        local value = data[key]
        local defaultValue = defaults[key]

        if type(value) == "table" then
            if next(value) ~= nil then
                return true
            end
        elseif value ~= defaultValue then
            return true
        end
    end

    return false
end

local function IsServerDataUntouched(data)
    if not data then return true end

    if (data.svMigrationVersion or 0) >= SV_MIGRATION_VERSION then
        return false
    end

    for _, key in ipairs(SAVED_VARS_KEYS) do
        local value = data[key]
        local defaultValue = defaults[key]

        if type(value) == "table" then
            if next(value) ~= nil then
                return false
            end
        elseif value ~= defaultValue then
            return false
        end
    end

    return true
end

local function CopySavedVarsInto(source, target)
    for _, key in ipairs(SAVED_VARS_KEYS) do
        target[key] = CopySavedVarValue(source[key])
    end
end

local function InitializeSavedVars()
    local serverNamespace = GetServerNamespace()
    local detectedServer = GetServerSettingFromWorldName(serverNamespace)
    local legacySv = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, defaults)
    local serverSv = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, serverNamespace, defaults)

    if IsServerDataUntouched(serverSv) and IsSavedVarDataMeaningful(legacySv) then
        CopySavedVarsInto(legacySv, serverSv)
        serverSv.migratedFromLegacy = true
        serverSv.migratedFromNamespace = "account-wide"
    end

    if detectedServer then
        serverSv.server = detectedServer
    elseif not serverSv.server then
        serverSv.server = defaults.server
    end

    serverSv.svMigrationVersion = SV_MIGRATION_VERSION

    return serverSv
end

-- ============================================================================
-- STATE
-- ============================================================================
DailyTracker.MainWindow = nil
DailyTracker.Container = nil
DailyTracker.AbandonBtn = nil
DailyTracker.QueueAllBtn = nil
DailyTracker.ModeToggle = nil
DailyTracker.CloseBtn = nil
DailyTracker.MinimizeBtn = nil
DailyTracker.TitleLabel = nil
DailyTracker.NotificationBell = nil
DailyTracker.Lines = {}
DailyTracker.queuedActivityIds = {}
DailyTracker.isUnderway = false
DailyTracker.isQueued = false
DailyTracker.hasNewPledges = false
DailyTracker.activeDungeonName = nil  -- locked pledge name for current dungeon run
DailyTracker.bellPulseAnimation = nil
DailyTracker.ResetTimerLabel = nil
DailyTracker.lastFinderStatus = nil

DailyTracker.activityIdCache = {
    veteran = {},
    normal = {},
    cacheBuilt = false,
}

-- ============================================================================
-- KEYBIND
-- ============================================================================
ZO_CreateStringId("SI_BINDING_NAME_DAILY_PLEDGE_MANAGER_TOGGLE", "Toggle Daily Pledge Manager")
ZO_CreateStringId("SI_BINDING_NAME_DAILY_PLEDGE_MANAGER_QUEUE_ALL", "Queue All Pledges")
ZO_CreateStringId("SI_BINDING_NAME_DAILY_PLEDGE_MANAGER_ABANDON_ALL", "Abandon All Pledges")

function DailyTracker.ToggleKeybind()
    DailyTracker.ToggleWindow()
end

function DailyTracker.QueueAllKeybind()
    if DailyTracker.isQueued then
        DailyTracker.CancelQueue()
    else
        DailyTracker.QueueAllPledges()
    end
end

function DailyTracker.AbandonAllKeybind()
    DailyTracker.AbandonAllPledges()
end

-- Returns a short display string for the first bound key of an action, e.g. "[9]"
-- Returns nil if no key is bound. Uses confirmed ESO API from ESOUIDocumentation.
local function GetKeybindHint(actionName)
    local numLayers = GetNumActionLayers()
    for layerIndex = 1, numLayers do
        local _, numCategories = GetActionLayerInfo(layerIndex)
        for categoryIndex = 1, numCategories do
            local _, numActions = GetActionLayerCategoryInfo(layerIndex, categoryIndex)
            for actionIndex = 1, numActions do
                local name = GetActionInfo(layerIndex, categoryIndex, actionIndex)
                if name == actionName then
                    local keyCode = GetActionBindingInfo(layerIndex, categoryIndex, actionIndex, 1)
                    if keyCode and keyCode ~= KEY_INVALID and keyCode ~= 0 then
                        local keyName = GetKeyName(keyCode)
                        if keyName and keyName ~= "" then
                            return "[" .. keyName .. "]"
                        end
                    end
                    return nil
                end
            end
        end
    end
    return nil
end

-- Updates the keybind hint labels on the Queue All and Abandon All buttons.
function DailyTracker.RefreshKeybindHints()
    if DailyTracker.QueueAllBtn then
        local hint = GetKeybindHint("DAILY_PLEDGE_MANAGER_QUEUE_ALL")
        local label = DailyTracker.QueueAllBtn:GetNamedChild("KeyHint")
        if label then
            if hint then
                label:SetText(hint)
                label:SetHidden(false)
            else
                label:SetHidden(true)
            end
        end
    end
    if DailyTracker.AbandonBtn then
        local hint = GetKeybindHint("DAILY_PLEDGE_MANAGER_ABANDON_ALL")
        local label = DailyTracker.AbandonBtn:GetNamedChild("KeyHint")
        if label then
            if hint then
                label:SetText(hint)
                label:SetHidden(false)
            else
                label:SetHidden(true)
            end
        end
    end
end

-- ============================================================================
-- UTILITY
-- ============================================================================
local function GetCurrentUTCHour()
    return tonumber(os.date("!%H"))
end

local function HasResetOccurred()
    local now = GetTimeStamp()
    local currentHour = GetCurrentUTCHour()
    local resetHour = RESET_TIMES[sv.server] or RESET_TIMES.NA
    local lastCheck = sv.lastResetCheck or 0
    local timeSinceLastCheck = now - lastCheck

    if timeSinceLastCheck > 72000 then
        return true
    end

    local today = os.date("!%Y%m%d")
    local lastCheckDay = os.date("!%Y%m%d", lastCheck)

    if today ~= lastCheckDay and currentHour >= resetHour then
        return true
    end

    return false
end

-- Calculate seconds until next pledge reset
local function GetSecondsUntilReset()
    local resetHour = RESET_TIMES[sv.server] or RESET_TIMES.NA
    local currentHour = tonumber(os.date("!%H"))
    local currentMin = tonumber(os.date("!%M"))
    local currentSec = tonumber(os.date("!%S"))

    -- Calculate hours until reset
    local hoursUntilReset
    if currentHour < resetHour then
        -- Reset is later today
        hoursUntilReset = resetHour - currentHour
    else
        -- Reset is tomorrow
        hoursUntilReset = (24 - currentHour) + resetHour
    end

    -- Convert to total seconds and subtract current minutes/seconds
    local secondsUntilReset = (hoursUntilReset * 3600) - (currentMin * 60) - currentSec

    return secondsUntilReset
end

-- Format seconds into HH:MM:SS string
local function FormatTimeRemaining(totalSeconds)
    if totalSeconds <= 0 then
        return "00:00:00"
    end

    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60

    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- ============================================================================
-- ACTIVITY CACHE
-- ============================================================================

-- Legacy fallback aliases for pledge names that differ from Activity Finder / zone names.
-- LibUndauntedPledges now supplies the authoritative pledge/activity mapping.
local LEGACY_PLEDGE_NAME_MAP = {
    ["darkshade ii"] = "darkshade caverns ii",
    ["banished cells i"] = "the banished cells i",
    ["banished cells ii"] = "the banished cells ii",
}

local function NormalizePledgeName(name)
    if type(name) ~= "string" then return "" end
    return zo_strlower(zo_strtrim(name))
end

local function GetCurrentServerKey()
    if sv and sv.server then
        return sv.server
    end

    local worldName = GetWorldName()
    return GetServerSettingFromWorldName(worldName) or "NA"
end

local function GetCurrentPledgeData()
    if not LUP or not LUP.GetPledges then
        return nil
    end

    return LUP.GetPledges(0, GetCurrentServerKey())
end

local function FindLibPledgeEntryByName(displayName)
    local pledgeData = GetCurrentPledgeData()
    if not pledgeData then return nil end

    local normalizedName = NormalizePledgeName(displayName)
    if normalizedName == "" then return nil end

    for _, pledgeGiverId in ipairs({LUP.BASE1, LUP.BASE2, LUP.DLC1}) do
        local entry = pledgeData[pledgeGiverId]
        if entry and entry.name then
            local entryName = NormalizePledgeName(entry.name)
            if entryName == normalizedName then
                return entry
            end

            local legacyAlias = LEGACY_PLEDGE_NAME_MAP[normalizedName]
            if legacyAlias and entryName == legacyAlias then
                return entry
            end
        end
    end

    return nil
end

local function BuildActivityCache()
    if DailyTracker.activityIdCache.cacheBuilt then return end

    for id = 1, 6000 do
        local name = GetActivityName(id)
        if name and name ~= "" then
            local activityType = GetActivityType(id)
            local lowerName = string.lower(name)

            if activityType == LFG_ACTIVITY_MASTER_DUNGEON then
                DailyTracker.activityIdCache.veteran[lowerName] = id
            elseif activityType == LFG_ACTIVITY_DUNGEON then
                DailyTracker.activityIdCache.normal[lowerName] = id
            end
        end
    end

    DailyTracker.activityIdCache.cacheBuilt = true
end

local function GetActivityIdByName(targetName, preferVeteran)
    local libEntry = FindLibPledgeEntryByName(targetName)
    if libEntry then
        local activityId = preferVeteran and libEntry.activityIdV or libEntry.activityIdN
        if activityId and activityId > 0 then
            return activityId
        end

        local fallbackActivityId = preferVeteran and libEntry.activityIdN or libEntry.activityIdV
        if fallbackActivityId and fallbackActivityId > 0 then
            return fallbackActivityId
        end
    end

    BuildActivityCache()

    local targetLower = NormalizePledgeName(targetName)
    local cache = preferVeteran and DailyTracker.activityIdCache.veteran or DailyTracker.activityIdCache.normal

    -- Check direct match first
    if cache[targetLower] then
        return cache[targetLower]
    end

    -- Check legacy fallback mapping
    local mappedName = LEGACY_PLEDGE_NAME_MAP[targetLower]
    if mappedName and cache[mappedName] then
        return cache[mappedName]
    end

    -- Fuzzy match - check if names contain each other
    for name, id in pairs(cache) do
        if string.find(name, targetLower, 1, true) or string.find(targetLower, name, 1, true) then
            return id
        end
    end

    -- Try word-based matching for remaining cases
    -- Extract key words from target (remove common suffixes like I, II)
    local baseTarget = string.gsub(targetLower, "%s+[iv]+$", "")
    for name, id in pairs(cache) do
        local baseName = string.gsub(name, "%s+[iv]+$", "")
        if string.find(baseName, baseTarget, 1, true) or string.find(baseTarget, baseName, 1, true) then
            return id
        end
    end

    local fallbackCache = preferVeteran and DailyTracker.activityIdCache.normal or DailyTracker.activityIdCache.veteran
    if fallbackCache[targetLower] then
        return fallbackCache[targetLower]
    end

    return nil
end

-- ============================================================================
-- PLEDGE TRACKING & NOTIFICATIONS
-- ============================================================================
local function GetCurrentPledgeNames()
    local pledges = {}
    for i = 1, GetNumJournalQuests() do
        local questName = GetJournalQuestName(i)
        if string.find(questName, "Pledge:") then
            local displayName = string.gsub(questName, "Pledge: ", "")
            table.insert(pledges, displayName)
        end
    end
    table.sort(pledges)
    return pledges
end

local function ArePledgesDifferent(oldPledges, newPledges)
    if #oldPledges ~= #newPledges then return true end
    for i, name in ipairs(newPledges) do
        if oldPledges[i] ~= name then
            return true
        end
    end
    return false
end

function DailyTracker.CheckForNewPledges()
    local currentPledges = GetCurrentPledgeNames()

    -- Track pledges for state management
    if #currentPledges > 0 then
        if #sv.lastKnownPledges > 0 and ArePledgesDifferent(sv.lastKnownPledges, currentPledges) then
            DailyTracker.hasNewPledges = true
        end
        sv.lastKnownPledges = currentPledges
    end

    sv.lastResetCheck = GetTimeStamp()
end

-- Called when reset is detected - shows generic reset notification
function DailyTracker.NotifyPledgeReset()
    if not sv.notifyOnNewPledges then return end

    DailyTracker.hasNewPledges = true
    DailyTracker.ShowResetNotification()
    sv.lastResetCheck = GetTimeStamp()
end

function DailyTracker.ShowResetNotification()
    if sv.soundEnabled then
        PlaySound(SOUNDS.QUEST_SHARE_SENT)
    end

    local wm = GetWindowManager()

    -- Destroy existing popup to ensure fresh layout
    if DailyTracker.ResetPopupWindow then
        DailyTracker.ResetPopupWindow:SetHidden(true)
        DailyTracker.ResetPopupWindow = nil
    end

    -- Create popup
    local popup = wm:CreateTopLevelWindow("DailyPledgeResetPopup" .. GetGameTimeMilliseconds())
    popup:SetMouseEnabled(false)
    popup:SetMovable(false)
    popup:SetClampedToScreen(true)
    popup:SetDimensions(400, 90)
    popup:SetAnchor(TOP, GuiRoot, TOP, 0, 120)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawTier(DT_HIGH)
    popup:SetHidden(true)
    DailyTracker.ResetPopupWindow = popup

    -- Background
    local bg = wm:CreateControl("$(parent)Bg", popup, CT_BACKDROP)
    bg:SetAnchorFill(popup)
    bg:SetCenterColor(0.08, 0.08, 0.1, 0.95)
    bg:SetEdgeColor(0.7, 0.55, 0.2, 1)
    bg:SetEdgeTexture("", 2, 2, 2)
    popup.bg = bg

    -- Title (centered, constrained width)
    local title = wm:CreateControl("$(parent)Title", popup, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetColor(1, 0.85, 0.35, 1)
    title:SetText("Daily Pledges Reset!")
    title:SetDimensions(380, 30)
    title:SetAnchor(TOP, popup, TOP, 0, 15)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    popup.title = title

    -- Message (centered, constrained width)
    local msg = wm:CreateControl("$(parent)Message", popup, CT_LABEL)
    msg:SetFont("ZoFontGame")
    msg:SetColor(0.85, 0.85, 0.85, 1)
    msg:SetText("Visit the Undaunted Enclave to pick up new pledges.")
    msg:SetDimensions(380, 24)
    msg:SetAnchor(TOP, title, BOTTOM, 0, 6)
    msg:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    popup.message = msg

    -- Show popup with fade in
    popup:SetAlpha(0)
    popup:SetHidden(false)

    -- Fade in animation
    local fadeInStart = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_ResetPopupFadeIn", 20, function()
        local elapsed = GetGameTimeMilliseconds() - fadeInStart
        local progress = elapsed / 400 -- 400ms fade in

        if progress >= 1 then
            popup:SetAlpha(1)
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_ResetPopupFadeIn")

            -- Schedule fade out after 5 seconds
            zo_callLater(function()
                DailyTracker.HideResetNotification()
            end, 5000)
        else
            popup:SetAlpha(progress)
        end
    end)

    DailyTracker.StartBellPulse()
end

function DailyTracker.HideResetNotification()
    if not DailyTracker.ResetPopupWindow then return end

    local popup = DailyTracker.ResetPopupWindow
    local fadeOutStart = GetGameTimeMilliseconds()

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_ResetPopupFadeOut", 20, function()
        local elapsed = GetGameTimeMilliseconds() - fadeOutStart
        local progress = elapsed / 600 -- 600ms fade out

        if progress >= 1 then
            popup:SetAlpha(0)
            popup:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_ResetPopupFadeOut")
        else
            popup:SetAlpha(1 - progress)
        end
    end)
end

function DailyTracker.StartBellPulse()
    if not DailyTracker.NotificationBell then return end
    if DailyTracker.bellPulseAnimation then return end

    DailyTracker.bellPulseAnimation = true
    local startTime = GetGameTimeMilliseconds()

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_BellPulse", 50, function()
        if not DailyTracker.bellPulseAnimation or not DailyTracker.NotificationBell then
            DailyTracker.StopBellPulse()
            return
        end

        local elapsed = GetGameTimeMilliseconds() - startTime
        local scale = 1 + 0.15 * math.abs(math.sin(elapsed / 300))
        local alpha = 0.7 + 0.3 * math.abs(math.sin(elapsed / 200))

        DailyTracker.NotificationBell:SetScale(scale)
        DailyTracker.NotificationBell:SetAlpha(alpha)
    end)
end

function DailyTracker.StopBellPulse()
    DailyTracker.bellPulseAnimation = nil
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_BellPulse")

    if DailyTracker.NotificationBell then
        DailyTracker.NotificationBell:SetScale(1)
        DailyTracker.NotificationBell:SetAlpha(1)
    end
end

function DailyTracker.DismissNotification()
    DailyTracker.hasNewPledges = false
    DailyTracker.StopBellPulse()
    DailyTracker.UpdateUIDisplay()
end

-- ============================================================================
-- ROLE CHECK
-- ============================================================================
local function HasAnyRoleSelected()
    local selectedRole = GetSelectedLFGRole()
    return selectedRole and selectedRole ~= LFG_ROLE_INVALID
end

-- ============================================================================
-- QUEUE LOGIC
-- ============================================================================
-- Returns secondsRemaining (>0) if the player has an active Dungeon Finder
-- "leave early" / activity-started cooldown, else 0. This is the same API
-- ESO's own ActivityFinderRoot_Manager uses (see eso source:
-- ActivityFinderRoot_Manager:RegisterForEvents -> OnCooldownsUpdate, which
-- calls GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_ACTIVITY_STARTED)).
-- Without this guard, ESO silently refuses StartActivityFinderSearch() while
-- the cooldown is active and DPM ends up with isQueued=true but no real
-- matchmaking happening — the player just sits there forever.
local function GetDungeonFinderCooldownRemaining()
    if type(GetLFGCooldownTimeRemainingSeconds) ~= "function" then return 0 end
    if not LFG_COOLDOWN_ACTIVITY_STARTED then return 0 end
    local remaining = GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_ACTIVITY_STARTED) or 0
    if remaining < 0 then remaining = 0 end
    return remaining
end

local function FormatCooldownRemaining(seconds)
    if seconds <= 0 then return "0s" end
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    if mins > 0 then
        return string.format("%dm %ds", mins, secs)
    end
    return string.format("%ds", secs)
end

-- Pre-flight check shared by every queue-trigger path.
-- Returns true if queueing is allowed; returns false (and surfaces a chat
-- message) if a Dungeon Finder cooldown is currently blocking new queues.
local function GuardAgainstDungeonFinderCooldown()
    local remaining = GetDungeonFinderCooldownRemaining()
    if remaining > 0 then
        d("|cFF6666[Daily Pledge Manager]|r Dungeon Finder cooldown active — " ..
            FormatCooldownRemaining(remaining) .. " remaining.")
        return false
    end
    return true
end

function DailyTracker.CancelQueue()
    -- CancelGroupSearches() is the correct ESO API -- confirmed from ESO's own
    -- LFG_LEAVE_QUEUE_CONFIRMATION dialog callback in ingamedialogs.lua.
    if type(CancelGroupSearches) == "function" then CancelGroupSearches() end

    DailyTracker.queuedActivityIds = {}
    DailyTracker.isQueued = false
    -- No sound here -- ESO fires LFG_SEARCH_FINISHED automatically via
    -- EVENT_ACTIVITY_FINDER_STATUS_UPDATE when the queue drops. Playing it
    -- manually here caused it to play twice.
    DailyTracker.UpdateUIDisplay()
    d("|cFFAA00[Daily Pledge Manager]|r Queue Cancelled.")
end

function DailyTracker.ToggleQueue(activityId, dungeonName)
    if DailyTracker.isUnderway then
        d("|cFFAA00[Daily Pledge Manager]|r Already in a dungeon.")
        return
    end

    if not HasAnyRoleSelected() then
        d("|cFF6666[Daily Pledge Manager]|r Select a role in Activity Finder first.")
        return
    end

    if GetGroupSize() >= 4 then
        d("|cFFAA00[Daily Pledge Manager]|r Group is full.")
        return
    end

    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
        d("|cFF6666[Daily Pledge Manager]|r Must be Group Leader to queue.")
        return
    end

    if DailyTracker.queuedActivityIds[activityId] then
        DailyTracker.CancelQueue()
    else
        -- Cooldown gate (v1.2.9): refuse to flip into the "queued" state if
        -- ESO would silently reject the request due to a Leave-Early cooldown.
        if not GuardAgainstDungeonFinderCooldown() then
            DailyTracker.UpdateUIDisplay()
            return
        end

        if ClearActivityFinderSearch then ClearActivityFinderSearch() end

        if AddActivityFinderSpecificSearchEntry and StartActivityFinderSearch then
            AddActivityFinderSpecificSearchEntry(activityId)
            StartActivityFinderSearch()

            DailyTracker.queuedActivityIds = {}
            DailyTracker.queuedActivityIds[activityId] = true
            DailyTracker.isQueued = true

            local mode = sv.preferVeteran and "Veteran" or "Normal"
            d("|c66FF66[Daily Pledge Manager]|r Queued for " .. mode .. ": " .. dungeonName)

            if sv.soundEnabled then
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end
        end
    end

    DailyTracker.UpdateUIDisplay()
end

function DailyTracker.QueueAllPledges()
    if DailyTracker.isUnderway then
        d("|cFFAA00[Daily Pledge Manager]|r Already in a dungeon.")
        return
    end

    if not HasAnyRoleSelected() then
        d("|cFF6666[Daily Pledge Manager]|r Select a role in Activity Finder first.")
        return
    end

    if GetGroupSize() >= 4 then
        d("|cFFAA00[Daily Pledge Manager]|r Group is full.")
        return
    end

    if IsUnitGrouped("player") and not IsUnitGroupLeader("player") then
        d("|cFF6666[Daily Pledge Manager]|r Must be Group Leader to queue.")
        return
    end

    -- Cooldown gate (v1.2.9): see ToggleQueue for rationale. Mirrored here so
    -- the Queue All button + Queue All keybind both honor the cooldown.
    if not GuardAgainstDungeonFinderCooldown() then
        DailyTracker.UpdateUIDisplay()
        return
    end

    if ClearActivityFinderSearch then ClearActivityFinderSearch() end
    DailyTracker.queuedActivityIds = {}

    local addedCount = 0

    for i = 1, GetNumJournalQuests() do
        local questName = GetJournalQuestName(i)
        if string.find(questName, "Pledge:") then
            if not DailyTracker.IsPledgeReadyToTurnIn(i) then
                local displayName = string.gsub(questName, "Pledge: ", "")
                local activityId = GetActivityIdByName(displayName, sv.preferVeteran)

                if activityId then
                    AddActivityFinderSpecificSearchEntry(activityId)
                    DailyTracker.queuedActivityIds[activityId] = true
                    addedCount = addedCount + 1
                end
            end
        end
    end

    if addedCount > 0 then
        if StartActivityFinderSearch then
            StartActivityFinderSearch()
            DailyTracker.isQueued = true
            local mode = sv.preferVeteran and "Veteran" or "Normal"
            d("|c66FF66[Daily Pledge Manager]|r Queued for " .. addedCount .. " " .. mode .. " dungeons.")

            if sv.soundEnabled then
                PlaySound(SOUNDS.POSITIVE_CLICK)
            end
        end
    else
        d("|cFFFF88[Daily Pledge Manager]|r No pledges available to queue.")
    end

    DailyTracker.UpdateUIDisplay()
end

-- ============================================================================
-- COMPLETION CHECK
-- ============================================================================
function DailyTracker.IsPledgeReadyToTurnIn(journalIndex)
    -- Primary: hard complete flag from the game itself
    if GetJournalQuestIsComplete(journalIndex) then return true end

    -- Secondary: scan condition text for turn-in prompts (fires when the quest
    -- advances to the "return to enclave" step after the final boss dies).
    -- We intentionally do NOT check isComplete flags here â€” intermediate steps
    -- tick complete as you progress through the dungeon and would cause false positives.
    local numSteps = GetJournalQuestNumSteps(journalIndex)
    for step = 1, numSteps do
        local numCond = GetJournalQuestNumConditions(journalIndex, step)
        for cond = 1, numCond do
            local text = GetJournalQuestConditionInfo(journalIndex, step, cond)
            if text and text ~= "" then
                local lowerText = string.lower(text)
                if string.find(lowerText, "return to", 1, true)
                    or string.find(lowerText, "speak to", 1, true)
                    or string.find(lowerText, "talk to", 1, true)
                    or string.find(lowerText, "report to", 1, true)
                    or string.find(lowerText, "go to", 1, true)
                    or string.find(lowerText, "bring", 1, true)
                then
                    return true
                end
            end
        end
    end

    return false
end

function DailyTracker.AbandonAllPledges()
    -- RECURRING BUG GUARD (v1.2.8):
    -- "Abandon All" must also LEAVE the Dungeon Finder queue. Without this, the
    -- visual queue state cleared but the real ESO queue kept running and the
    -- player still got popped into a dungeon a few seconds later. Route
    -- through DailyTracker.CancelQueue() so the cancel path is shared with the
    -- "Leave Queue" button and Queue-All-keybind toggle. CancelGroupSearches()
    -- is the canonical leave-queue API, confirmed from ESO's own
    -- LFG_LEAVE_QUEUE_CONFIRMATION dialog callback in ingamedialogs.lua.
    -- (Note: ESO's UI labels this surface "Dungeon Finder", but the underlying
    --  API constants/events still use the LFG_ prefix — those stay verbatim.)
    if DailyTracker.isQueued or next(DailyTracker.queuedActivityIds) ~= nil then
        DailyTracker.CancelQueue()
    end

    local count = 0
    for i = GetNumJournalQuests(), 1, -1 do
        local questName = GetJournalQuestName(i)
        if string.find(questName, "Pledge:") then
            AbandonQuest(i)
            count = count + 1
        end
    end
    DailyTracker.queuedActivityIds = {}
    DailyTracker.UpdateUIDisplay()

    if count > 0 then
        d("|cFFAA00[Daily Pledge Manager]|r Abandoned " .. count .. " pledges.")
    end
end

-- ============================================================================
-- WINDOW CONTROLS
-- ============================================================================
function DailyTracker.ToggleWindow()
    if not DailyTracker.MainWindow then return end
    sv.windowVisible = not sv.windowVisible
    DailyTracker.MainWindow:SetHidden(not sv.windowVisible)
    if sv.windowVisible then
        DailyTracker.UpdateUIDisplay()
    end
end

function DailyTracker.ToggleCollapse()
    sv.collapsed = not sv.collapsed
    DailyTracker.UpdateUIDisplay()
end

function DailyTracker.ToggleLock()
    sv.locked = not sv.locked
    DailyTracker.MainWindow:SetMovable(not sv.locked)
    local status = sv.locked and "locked" or "unlocked"
    d("|cFFAA00[Daily Pledge Manager]|r Window " .. status .. ".")
end

function DailyTracker.ToggleDungeonMode()
    -- Prevent mode change while in a dungeon
    if IsUnitInDungeon("player") then
        d("|cFFAA00[Daily Pledge Manager]|r Cannot change mode while in a dungeon.")
        return
    end
    sv.preferVeteran = not sv.preferVeteran
    DailyTracker.UpdateUIDisplay()
    local mode = sv.preferVeteran and "Veteran" or "Normal"
    d("|cFFAA00[Daily Pledge Manager]|r Now queueing for " .. mode .. " dungeons.")
end

-- ============================================================================
-- UI UPDATE
-- ============================================================================

-- ============================================================================
-- DUNGEON LOCK â€” detect which pledge dungeon we entered and stay locked on it
-- until the player actually leaves the dungeon, regardless of sub-zone changes.
-- ============================================================================

local function BuildAllDungeonZoneData()
    local zoneIds = {}
    local zoneNames = {}
    local seen = {}

    local function WalkZoneParents(startZoneId)
        local zid = startZoneId
        local limit = 10
        while zid and zid > 0 and limit > 0 do
            if seen[zid] then break end
            seen[zid] = true
            table.insert(zoneIds, zid)
            local zname = string.lower(GetZoneNameById(zid) or "")
            if zname ~= "" then
                table.insert(zoneNames, zname)
            end
            local pid = GetParentZoneId(zid)
            if not pid or pid == 0 or pid == zid then break end
            zid = pid
            limit = limit - 1
        end
    end

    local mapZoneIndex = GetCurrentMapZoneIndex()
    if mapZoneIndex then WalkZoneParents(GetZoneId(mapZoneIndex)) end

    local playerZoneIndex = GetUnitZoneIndex("player")
    if playerZoneIndex then WalkZoneParents(GetZoneId(playerZoneIndex)) end

    return zoneIds, zoneNames
end

local function TryLockDungeonPledge()
    -- Walk zone chain and match against every active pledge
    local zoneIds, zoneNames = BuildAllDungeonZoneData()

    for i = 1, GetNumJournalQuests() do
        local questName = GetJournalQuestName(i)
        if string.find(questName, "Pledge:") then
            local displayName = string.gsub(questName, "Pledge: ", "")
            local dungeonNameLower = NormalizePledgeName(displayName)
            local libEntry = FindLibPledgeEntryByName(displayName)
            local mappedName = libEntry and NormalizePledgeName(libEntry.name) or LEGACY_PLEDGE_NAME_MAP[dungeonNameLower] or dungeonNameLower
            local baseName = string.gsub(dungeonNameLower, "%s+[iv]+$", "")
            local baseMappedName = string.gsub(mappedName, "%s+[iv]+$", "")

            -- Check zone ID match
            if libEntry and libEntry.zoneId then
                for _, zid in ipairs(zoneIds) do
                    if zid == libEntry.zoneId then
                        DailyTracker.activeDungeonName = displayName
                        return
                    end
                end
            end

            -- Check zone name match
            for _, zname in ipairs(zoneNames) do
                if zname ~= "" then
                    if string.find(zname, dungeonNameLower, 1, true)
                        or string.find(zname, mappedName, 1, true)
                        or string.find(zname, baseName, 1, true)
                        or string.find(zname, baseMappedName, 1, true)
                        or string.find(dungeonNameLower, zname, 1, true)
                        or string.find(mappedName, zname, 1, true)
                    then
                        DailyTracker.activeDungeonName = displayName
                        return
                    end
                end
            end
        end
    end

    -- No match found â€” leave lock unchanged (don't clear mid-dungeon)
end

function DailyTracker.OnZoneChanged()
    if IsUnitInDungeon("player") then
        -- Re-try lock if we don't have one yet (player just entered)
        if not DailyTracker.activeDungeonName then
            zo_callLater(TryLockDungeonPledge, 1000)
        end
    else
        -- Player left the dungeon â€” clear the lock
        DailyTracker.activeDungeonName = nil
        DailyTracker.UpdateUIDisplay()
    end
end

-- ============================================================================

local function UpdateContentAnchors()
    if not DailyTracker.Container or not DailyTracker.Divider then return end

    local containerTopOffset = (sv and sv.showResetTimer and not sv.collapsed) and 30 or 4

    DailyTracker.Container:ClearAnchors()
    DailyTracker.Container:SetAnchor(TOPLEFT, DailyTracker.Divider, BOTTOMLEFT, 0, containerTopOffset)
    DailyTracker.Container:SetAnchor(TOPRIGHT, DailyTracker.Divider, BOTTOMRIGHT, 0, containerTopOffset)
end

function DailyTracker.UpdateUIDisplay()
    if not DailyTracker.MainWindow or not sv then return end

    UpdateContentAnchors()

    -- Hide all lines
    for _, line in pairs(DailyTracker.Lines) do
        line:SetHidden(true)
    end

    -- Update mode toggle
    if DailyTracker.ModeToggle then
        local inDungeon = IsUnitInDungeon("player")
        if inDungeon then
            -- Grey out when locked in dungeon
            local modeText = sv.preferVeteran and "Veteran" or "Normal"
            DailyTracker.ModeToggle.label:SetText("|c666666" .. modeText .. "|r")
        elseif sv.preferVeteran then
            DailyTracker.ModeToggle.label:SetText("|cFF9933Veteran|r")
        else
            DailyTracker.ModeToggle.label:SetText("|cAAFFAANormal|r")
        end
    end

    -- Notification bell
    if DailyTracker.NotificationBell then
        DailyTracker.NotificationBell:SetHidden(not DailyTracker.hasNewPledges)
    end

    -- Collapsed state
    if sv.collapsed then
        DailyTracker.Container:SetHidden(true)
        DailyTracker.ButtonContainer:SetHidden(true)
        if DailyTracker.ResetTimerLabel then
            DailyTracker.ResetTimerLabel:SetHidden(true)
        end
        DailyTracker.MainWindow:SetHeight(36)
        DailyTracker.MinimizeBtn.icon:SetTexture("esoui/art/buttons/plus_up.dds")
        return
    else
        DailyTracker.Container:SetHidden(false)
        if DailyTracker.ResetTimerLabel then
            DailyTracker.ResetTimerLabel:SetHidden(not sv.showResetTimer)
        end
        DailyTracker.MinimizeBtn.icon:SetTexture("esoui/art/buttons/minus_up.dds")
    end

    local foundCount = 0
    local hasActivePledges = false
    local LINE_HEIGHT = 28

    local isAnyQueueActive = false
    for _ in pairs(DailyTracker.queuedActivityIds) do
        isAnyQueueActive = true
        break
    end

    -- Use game API to check if ANY queue is active as a fallback
    if not isAnyQueueActive and IsActivityFinderSearchInProgress then
        isAnyQueueActive = IsActivityFinderSearchInProgress()
    end

    local wasUnderway = DailyTracker.isUnderway
    DailyTracker.isUnderway = IsUnitInDungeon("player")
    DailyTracker.isQueued = isAnyQueueActive

    -- When first entering a dungeon, try to lock onto the matching pledge.
    -- Once locked, we NEVER re-detect mid-dungeon â€” sub-zone changes can't break it.
    if DailyTracker.isUnderway and not wasUnderway then
        -- Just entered a dungeon â€” lock with a small delay so zone data is ready
        zo_callLater(TryLockDungeonPledge, 1000)
    elseif not DailyTracker.isUnderway and wasUnderway then
        -- Just left a dungeon â€” clear the lock
        DailyTracker.activeDungeonName = nil
    end

    for i = 1, GetNumJournalQuests() do
        local questName = GetJournalQuestName(i)

        if string.find(questName, "Pledge:") then
            foundCount = foundCount + 1
            hasActivePledges = true
            local line = DailyTracker.GetOrCreateLine(foundCount)

            local displayName = string.gsub(questName, "Pledge: ", "")
            local isReady = DailyTracker.IsPledgeReadyToTurnIn(i)

            local nameText = ""
            local statusText = ""
            local canClick = false
            local tooltipText = nil

            -- Determine name color based on mode
            local nameColor = sv.preferVeteran and "|cFF9933" or "|cFFFFFF"

            -- Check if this is the locked dungeon pledge for the current run.
            -- We use the lock set at dungeon entry so sub-zone changes never break it.
            local isThisDungeonActive = false
            if DailyTracker.isUnderway and DailyTracker.activeDungeonName then
                isThisDungeonActive = (NormalizePledgeName(displayName) == NormalizePledgeName(DailyTracker.activeDungeonName))
            end

            if isReady then
                -- Pledge is done â€” release the dungeon lock so the status shows correctly
                if DailyTracker.activeDungeonName and
                    NormalizePledgeName(displayName) == NormalizePledgeName(DailyTracker.activeDungeonName) then
                    DailyTracker.activeDungeonName = nil
                end
                nameText = "|c66FF66" .. displayName .. "|r"
                statusText = "|c66FF66Complete|r"
                tooltipText = "Complete! Return to the Undaunted Enclave."

            elseif DailyTracker.isUnderway and isThisDungeonActive then
                -- This is the dungeon we're currently in
                nameText = nameColor .. displayName .. "|r"
                statusText = "|cFFAA00In Progress...|r"
                tooltipText = "Dungeon in progress."

            elseif DailyTracker.isUnderway then
                -- We're in a dungeon but not this one - grey it out
                nameText = "|c888888" .. displayName .. "|r"
                statusText = "|c666666Waiting|r"
                tooltipText = "Complete current dungeon first."

            else
                local activityId = GetActivityIdByName(displayName, sv.preferVeteran)

                if activityId then
                    if isAnyQueueActive then
                        if DailyTracker.queuedActivityIds[activityId] then
                            nameText = "|cFFFF66" .. displayName .. "|r"
                            statusText = "|cFFFF66Queued|r"
                            canClick = true
                            tooltipText = "Click to cancel queue"
                        else
                            nameText = "|c888888" .. displayName .. "|r"
                            statusText = sv.preferVeteran and "|c666666Vet|r" or ""
                            tooltipText = "Queued for another dungeon"
                        end
                    else
                        nameText = nameColor .. displayName .. "|r"
                        statusText = sv.preferVeteran and "|cFF6600Vet|r" or "|cAAFFAANorm|r"
                        canClick = true
                        local mode = sv.preferVeteran and "Veteran" or "Normal"
                        tooltipText = "Click to queue for " .. mode
                    end

                    if canClick then
                        line:SetHandler("OnClicked", function()
                            DailyTracker.ToggleQueue(activityId, displayName)
                        end)
                    else
                        line:SetHandler("OnClicked", nil)
                    end
                else
                    nameText = "|c888888" .. displayName .. "|r"
                    statusText = "|cFF6666Error|r"
                    tooltipText = "Could not find dungeon activity"
                end
            end

            line.nameLabel:SetText(nameText)
            line.statusLabel:SetText(statusText)
            line:SetMouseEnabled(canClick or sv.showTooltips)
            line:SetHidden(false)

            if sv.showTooltips and tooltipText then
                line.tooltipText = tooltipText
                line:SetHandler("OnMouseEnter", function(self)
                    self.highlight:SetHidden(false)
                    InitializeTooltip(InformationTooltip, self, RIGHT, 5, 0)
                    SetTooltipText(InformationTooltip, self.tooltipText)
                end)
                line:SetHandler("OnMouseExit", function(self)
                    self.highlight:SetHidden(true)
                    ClearTooltip(InformationTooltip)
                end)
            else
                line:SetHandler("OnMouseEnter", function(self)
                    self.highlight:SetHidden(false)
                end)
                line:SetHandler("OnMouseExit", function(self)
                    self.highlight:SetHidden(true)
                end)
            end
        end
    end

    if foundCount == 0 then
        local line = DailyTracker.GetOrCreateLine(1)
        line.nameLabel:SetText("|c888888No Active Pledges|r")
        line.statusLabel:SetText("")
        line:SetMouseEnabled(false)
        line:SetHidden(false)
        foundCount = 1
    end

    local contentHeight = foundCount * LINE_HEIGHT

    if DailyTracker.Container then
        DailyTracker.Container:SetHeight(contentHeight > 0 and contentHeight or 28)
    end

    -- Timer row height (only when visible)
    local timerHeight = (sv.showResetTimer and not sv.collapsed) and 28 or 0

    if hasActivePledges then
        DailyTracker.ButtonContainer:SetHidden(false)
        DailyTracker.MainWindow:SetHeight(36 + timerHeight + 8 + contentHeight + 8 + 70 + 10)
    else
        DailyTracker.ButtonContainer:SetHidden(true)
        DailyTracker.MainWindow:SetHeight(36 + timerHeight + 8 + contentHeight + 15)
    end

    -- Update Queue All button state based on active queue
    if DailyTracker.QueueAllBtn then
        local btn = DailyTracker.QueueAllBtn
        if isAnyQueueActive then
            btn.label:SetText("Leave Queue")
            btn.bg:SetCenterColor(0.6, 0.3, 0.0, 0.95)   -- orange bg
            btn.bg:SetEdgeColor(0.8, 0.5, 0.1, 1)         -- orange border
            btn:SetHandler("OnClicked", DailyTracker.CancelQueue)
            btn:SetHandler("OnMouseEnter", function(self)
                self.bg:SetCenterColor(0.75, 0.4, 0.05, 0.98)
                self.label:SetColor(1, 0.9, 0.6, 1)
                InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
                SetTooltipText(InformationTooltip, "Leave the current dungeon queue")
            end)
            btn:SetHandler("OnMouseExit", function(self)
                self.bg:SetCenterColor(0.6, 0.3, 0.0, 0.95)
                self.label:SetColor(1, 0.85, 0.5, 1)
                ClearTooltip(InformationTooltip)
            end)
            btn.label:SetColor(1, 0.85, 0.5, 1)   -- warm orange text
        else
            btn.label:SetText("Queue All Pledges")
            btn.bg:SetCenterColor(0.2, 0.35, 0.2, 0.95)  -- back to green
            btn.bg:SetEdgeColor(0.4, 0.6, 0.3, 1)
            btn:SetHandler("OnClicked", DailyTracker.QueueAllPledges)
            btn:SetHandler("OnMouseEnter", function(self)
                self.bg:SetCenterColor(0.25, 0.45, 0.25, 0.98)
                self.label:SetColor(1, 1, 0.8, 1)
                InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
                local mode = sv.preferVeteran and "Veteran" or "Normal"
                SetTooltipText(InformationTooltip, "Queue for all incomplete " .. mode .. " pledges")
            end)
            btn:SetHandler("OnMouseExit", function(self)
                self.bg:SetCenterColor(0.2, 0.35, 0.2, 0.95)
                self.label:SetColor(0.9, 0.95, 0.7, 1)
                ClearTooltip(InformationTooltip)
            end)
            btn.label:SetColor(0.9, 0.95, 0.7, 1)  -- back to light gold text
        end
    end
end

function DailyTracker.GetOrCreateLine(index)
    if not DailyTracker.Lines[index] then
        local wm = GetWindowManager()

        local btn = wm:CreateControl("$(parent)Line" .. index, DailyTracker.Container, CT_BUTTON)
        btn:SetAnchor(TOPLEFT, DailyTracker.Container, TOPLEFT, 0, (index - 1) * 28)
        btn:SetAnchor(TOPRIGHT, DailyTracker.Container, TOPRIGHT, 0, (index - 1) * 28)
        btn:SetHeight(28)
        btn:SetMouseEnabled(true)

        -- Highlight background
        local highlight = wm:CreateControl("$(parent)Highlight", btn, CT_TEXTURE)
        highlight:SetAnchorFill(btn)
        highlight:SetTexture("esoui/art/miscellaneous/listitem_highlight.dds")
        highlight:SetAlpha(0.3)
        highlight:SetHidden(true)
        btn.highlight = highlight

        -- Dungeon name label (left side)
        local nameLabel = wm:CreateControl("$(parent)Name", btn, CT_LABEL)
        nameLabel:SetFont("ZoFontGame")
        nameLabel:SetAnchor(LEFT, btn, LEFT, 12, 0)
        nameLabel:SetWidth(180)
        nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        nameLabel:SetMouseEnabled(false)
        btn.nameLabel = nameLabel

        -- Status label (right side)
        local statusLabel = wm:CreateControl("$(parent)Status", btn, CT_LABEL)
        statusLabel:SetFont("ZoFontGameSmall")
        statusLabel:SetAnchor(RIGHT, btn, RIGHT, -12, 0)
        statusLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        statusLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        statusLabel:SetMouseEnabled(false)
        btn.statusLabel = statusLabel

        DailyTracker.Lines[index] = btn
    end
    return DailyTracker.Lines[index]
end

-- ============================================================================
-- RESET TIMER
-- ============================================================================
DailyTracker.lastSecondsRemaining = nil

function DailyTracker.UpdateResetTimer()
    if not DailyTracker.ResetTimerLabel then return end

    local secondsRemaining = GetSecondsUntilReset()

    -- Check if reset just occurred (timer wrapped from low to high)
    if DailyTracker.lastSecondsRemaining and DailyTracker.lastSecondsRemaining <= 5 and secondsRemaining > 80000 then
        -- Reset just happened! Notify user
        zo_callLater(function()
            DailyTracker.NotifyPledgeReset()
            DailyTracker.UpdateUIDisplay()
        end, 2000)
    end
    DailyTracker.lastSecondsRemaining = secondsRemaining

    if not sv.showResetTimer then
        DailyTracker.ResetTimerLabel:SetHidden(true)
        return
    end

    DailyTracker.ResetTimerLabel:SetHidden(false)

    local timeString = FormatTimeRemaining(secondsRemaining)

    -- Color coding based on time remaining
    local color
    if secondsRemaining <= 10 then
        -- Last 10 seconds - red (imminent reset)
        color = "|cFF3333"
    elseif secondsRemaining <= 3600 then
        -- Less than 1 hour - yellow/gold
        color = "|cFFCC00"
    elseif secondsRemaining <= 7200 then
        -- Less than 2 hours - cyan/teal
        color = "|c66DDDD"
    else
        -- More than 2 hours - normal gray-blue
        color = "|cAABBCC"
    end

    DailyTracker.ResetTimerLabel:SetText(color .. "Pledges reset in " .. timeString .. "|r")
end

function DailyTracker.StartResetTimer()
    -- Update immediately
    DailyTracker.UpdateResetTimer()

    -- Update every second
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_ResetTimer", 1000, function()
        DailyTracker.UpdateResetTimer()
    end)
end

function DailyTracker.StopResetTimer()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_ResetTimer")
end

-- ============================================================================
-- AUTO ACCEPT PLEDGES
-- ============================================================================
DailyTracker.isInteractingWithPledgeGiver = false
DailyTracker.autoAcceptPending = false

local function BuildPledgeGiverNameLookup()
    local names = {}

    if LUP and LUP.GetPledgeGiverName then
        for _, pledgeGiverId in ipairs({LUP.BASE1, LUP.BASE2, LUP.DLC1}) do
            local localizedName = LUP.GetPledgeGiverName(pledgeGiverId)
            if localizedName and localizedName ~= "" then
                names[NormalizePledgeName(localizedName)] = true
            end
        end
    end

    if next(names) == nil then
        names["maj al-ragath"] = true
        names["glirion the redbeard"] = true
        names["urgarlag chief-bane"] = true
    end

    return names
end

local PLEDGE_GIVERS = BuildPledgeGiverNameLookup()

local function IsPledgeGiver(name)
    if not name then return false end
    return PLEDGE_GIVERS[NormalizePledgeName(name)] == true
end

-- Check if a dialogue option is for accepting a pledge
local function IsPledgeAcceptOption(optionText)
    if not optionText then return false end
    local lowerText = string.lower(optionText)
    -- Look for pledge-related acceptance options
    return string.find(lowerText, "accept") or
           string.find(lowerText, "pledge") or
           string.find(lowerText, "i'll") or
           string.find(lowerText, "i will") or
           string.find(lowerText, "yes") or
           string.find(lowerText, "sign me up") or
           string.find(lowerText, "what do you have")
end

-- Check if option is a goodbye/exit option (to avoid)
local function IsGoodbyeOption(optionText)
    if not optionText then return false end
    local lowerText = string.lower(optionText)
    return string.find(lowerText, "goodbye") or
           string.find(lowerText, "nevermind") or
           string.find(lowerText, "never mind") or
           string.find(lowerText, "not interested") or
           string.find(lowerText, "leave")
end

DailyTracker.justInteractedWithPledgeGiver = false

function DailyTracker.OnChatterBegin(eventCode, optionCount)
    if not sv.autoAcceptPledges then return end

    -- End interaction if we just accepted a quest (like UPU does)
    if DailyTracker.justInteractedWithPledgeGiver then
        DailyTracker.justInteractedWithPledgeGiver = false
        EndInteraction(INTERACTION_CONVERSATION)
        return
    end

    -- Check NPC name when chatter begins
    local unitName = GetUnitName("interact")
    if not IsPledgeGiver(unitName) then
        DailyTracker.isInteractingWithPledgeGiver = false
        return
    end

    DailyTracker.isInteractingWithPledgeGiver = true

    -- Get first option text
    local optionString = GetChatterOption(1)
    if not optionString then return end

    -- Check if this is the store option (quest already taken)
    local lowerOption = string.lower(optionString)
    if string.find(lowerOption, "store") or string.find(lowerOption, "browse") then
        return -- Quest already taken, don't auto-interact
    end

    -- Check if this is a pledge dialogue
    if string.find(lowerOption, "pledge") or string.find(lowerOption, "what") then
        -- Register for the quest offered event to continue the dialogue flow
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_QUEST_OFFERED, DailyTracker.OnPledgeQuestOfferedStep1)
        SelectChatterOption(1)
    elseif not IsGoodbyeOption(optionString) then
        -- For returning pledges or other dialogue, continue
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_CONVERSATION_UPDATED, DailyTracker.OnPledgeConversationUpdated)
        SelectChatterOption(1)
    end
end

-- Step 1: First EVENT_QUEST_OFFERED fires (this is actually mid-dialogue)
function DailyTracker.OnPledgeQuestOfferedStep1(eventCode)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_QUEST_OFFERED)
    -- Register for the actual quest accept
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_QUEST_OFFERED, DailyTracker.OnPledgeQuestOfferedStep2)
    AcceptOfferedQuest()
end

-- Step 2: Second EVENT_QUEST_OFFERED fires (actual quest acceptance)
function DailyTracker.OnPledgeQuestOfferedStep2(eventCode)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_QUEST_OFFERED)
    AcceptOfferedQuest()
    DailyTracker.justInteractedWithPledgeGiver = true
end

-- For returning pledges
function DailyTracker.OnPledgeConversationUpdated(eventCode, conversationBodyText, conversationOptionCount)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_CONVERSATION_UPDATED)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_QUEST_COMPLETE_DIALOG, DailyTracker.OnPledgeQuestComplete)
    SelectChatterOption(1)
end

-- Complete the quest when turning in
function DailyTracker.OnPledgeQuestComplete(eventCode)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_AutoPledge", EVENT_QUEST_COMPLETE_DIALOG)
    CompleteQuest()
    DailyTracker.justInteractedWithPledgeGiver = true
end

function DailyTracker.OnInteractionEnd()
    DailyTracker.isInteractingWithPledgeGiver = false
end

-- ============================================================================
-- AUTO READY CHECK
-- ============================================================================
function DailyTracker.OnReadyCheck()
    if not sv.autoAcceptReadyCheck then return end

    -- Accept a ready check if one is pending
    if HasLFGReadyCheckNotification() then
        AcceptLFGReadyCheckNotification()
    end

    -- Accept replacement notifications if someone left and a replacement was found
    if HasActivityFindReplacementNotification and HasActivityFindReplacementNotification() then
        AcceptActivityFindReplacementNotification()
    end
end

-- ============================================================================
-- EVENTS
-- ============================================================================
function DailyTracker.OnFinderUpdate(event, status)
    local previousStatus = DailyTracker.lastFinderStatus

    if status == ACTIVITY_FINDER_STATUS_NONE then
        DailyTracker.queuedActivityIds = {}
        DailyTracker.isQueued = false
    elseif status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        if sv.soundEnabled and previousStatus ~= ACTIVITY_FINDER_STATUS_READY_CHECK then
            PlaySound(sv.soundOnQueuePop)
        end
    else
        if sv.soundEnabled and previousStatus ~= nil and previousStatus ~= status then
            PlaySound(SOUNDS.POSITIVE_CLICK)
        end
    end

    DailyTracker.lastFinderStatus = status
    DailyTracker.UpdateUIDisplay()
end

function DailyTracker.OnCooldownsUpdated()
    -- Defensive reconcile (v1.2.9): if a Dungeon Finder cooldown becomes
    -- active while we think the player is still queued, the underlying ESO
    -- search is no longer valid. Force CancelQueue so the addon's UI matches
    -- reality. In practice the pre-queue gate prevents this from happening,
    -- but this catches the edge case where a cooldown starts mid-queue.
    local remaining = GetDungeonFinderCooldownRemaining()
    if remaining > 0 and (DailyTracker.isQueued or next(DailyTracker.queuedActivityIds) ~= nil) then
        DailyTracker.CancelQueue()
    else
        DailyTracker.UpdateUIDisplay()
    end
end

function DailyTracker.OnPlayerActivated()
    zo_callLater(function()
        if HasResetOccurred() then
            DailyTracker.NotifyPledgeReset()
        end
        -- If we logged in or reloaded while inside a dungeon, lock onto the pledge
        if IsUnitInDungeon("player") and not DailyTracker.activeDungeonName then
            TryLockDungeonPledge()
        end
        DailyTracker.UpdateUIDisplay()
    end, 3000)
end

function DailyTracker.OnQuestAdded()
    zo_callLater(function()
        DailyTracker.CheckForNewPledges()
        DailyTracker.UpdateUIDisplay()
    end, 500)
end

-- ============================================================================
-- SETTINGS MENU
-- ============================================================================
local function CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = ADDON_DISPLAY_NAME,
        author = "|cFF9900DerpyNoodle|r",
        version = ADDON_VERSION,
        slashCommand = "/dailysettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable = {
        {
            type = "header",
            name = "General",
        },
        {
            type = "checkbox",
            name = "Show Window",
            tooltip = "Toggle the tracker window visibility",
            getFunc = function() return sv.windowVisible end,
            setFunc = function(value)
                sv.windowVisible = value
                DailyTracker.MainWindow:SetHidden(not value)
            end,
            default = defaults.windowVisible,
        },
        {
            type = "checkbox",
            name = "Lock Window",
            tooltip = "Prevent the window from being moved",
            getFunc = function() return sv.locked end,
            setFunc = function(value)
                sv.locked = value
                DailyTracker.MainWindow:SetMovable(not value)
            end,
            default = defaults.locked,
        },
        {
            type = "slider",
            name = "Window Opacity",
            tooltip = "Adjust background transparency",
            min = 0.5,
            max = 1.0,
            step = 0.05,
            getFunc = function() return sv.windowOpacity end,
            setFunc = function(value)
                sv.windowOpacity = value
                local bg = DailyTracker.MainWindow:GetNamedChild("Bg")
                if bg then bg:SetAlpha(value) end
            end,
            default = defaults.windowOpacity,
        },
        {
            type = "dropdown",
            name = "Server",
            tooltip = "Select your server for pledge reset detection",
            choices = {"NA", "EU"},
            getFunc = function() return sv.server end,
            setFunc = function(value) sv.server = value end,
            default = defaults.server,
        },
        {
            type = "header",
            name = "Queue",
        },
        {
            type = "checkbox",
            name = "Default to Veteran",
            tooltip = "Queue for Veteran dungeons by default",
            getFunc = function() return sv.preferVeteran end,
            setFunc = function(value)
                sv.preferVeteran = value
                DailyTracker.UpdateUIDisplay()
            end,
            default = defaults.preferVeteran,
        },
        {
            type = "checkbox",
            name = "Sound Effects",
            tooltip = "Play sounds for queue events",
            getFunc = function() return sv.soundEnabled end,
            setFunc = function(value) sv.soundEnabled = value end,
            default = defaults.soundEnabled,
        },
        {
            type = "checkbox",
            name = "Auto Accept Ready Check",
            tooltip = "Automatically accept dungeon ready checks and replacement notifications when your queue pops",
            getFunc = function() return sv.autoAcceptReadyCheck end,
            setFunc = function(value) sv.autoAcceptReadyCheck = value end,
            default = defaults.autoAcceptReadyCheck,
        },
        {
            type = "checkbox",
            name = "Auto Accept Pledges",
            tooltip = "Automatically skip dialogue and accept pledges when talking to Maj al-Ragath, Glirion the Redbeard, or Urgarlag Chief-Bane",
            getFunc = function() return sv.autoAcceptPledges end,
            setFunc = function(value) sv.autoAcceptPledges = value end,
            default = defaults.autoAcceptPledges,
        },
        {
            type = "header",
            name = "Notifications",
        },
        {
            type = "checkbox",
            name = "Notify on New Pledges",
            tooltip = "Alert when new daily pledges are available after reset",
            getFunc = function() return sv.notifyOnNewPledges end,
            setFunc = function(value) sv.notifyOnNewPledges = value end,
            default = defaults.notifyOnNewPledges,
        },
        {
            type = "checkbox",
            name = "Show Tooltips",
            tooltip = "Show helpful tooltips on hover",
            getFunc = function() return sv.showTooltips end,
            setFunc = function(value)
                sv.showTooltips = value
                DailyTracker.UpdateUIDisplay()
            end,
            default = defaults.showTooltips,
        },
        {
            type = "checkbox",
            name = "Show Reset Timer",
            tooltip = "Display a countdown timer showing when daily pledges will reset",
            getFunc = function() return sv.showResetTimer end,
            setFunc = function(value)
                sv.showResetTimer = value
                DailyTracker.UpdateResetTimer()
                DailyTracker.UpdateUIDisplay()
            end,
            default = defaults.showResetTimer,
        },
        {
            type = "header",
            name = "Compass",
        },
        {
            type = "checkbox",
            name = "Show Compass Pins",
            tooltip = "Show orange compass pins pointing to the Undaunted Enclave when you have active pledges (requires CustomCompassPins addon)",
            getFunc = function() return sv.showCompassPins end,
            setFunc = function(value)
                sv.showCompassPins = value
                DailyTracker.RefreshCompassPins()
            end,
            default = defaults.showCompassPins,
        },
    }

    -- Keybinds section
    local keybindTable = {
        {
            type = "header",
            name = "Keybinds",
        },
        {
            type = "keybind",
            name = "Queue All Pledges",
            tooltip = "Press this key to instantly queue for all incomplete pledges",
            keybind = "DAILY_PLEDGE_MANAGER_QUEUE_ALL",
            additionalBindings = 0,
        },
        {
            type = "keybind",
            name = "Abandon All Pledges",
            tooltip = "Press this key to abandon all active pledge quests",
            keybind = "DAILY_PLEDGE_MANAGER_ABANDON_ALL",
            additionalBindings = 0,
        },
        {
            type = "keybind",
            name = "Toggle Window",
            tooltip = "Press this key to show/hide the Daily Pledge Manager window",
            keybind = "DAILY_PLEDGE_MANAGER_TOGGLE",
            additionalBindings = 0,
        },
    }
    for _, entry in ipairs(keybindTable) do
        table.insert(optionsTable, entry)
    end

    LAM:RegisterAddonPanel(ADDON_NAME .. "Options", panelData)
    LAM:RegisterOptionControls(ADDON_NAME .. "Options", optionsTable)
end

-- ============================================================================
-- STYLED BUTTON CREATION
-- ============================================================================
local function CreateStyledButton(parent, name, width, height, text, textColor, bgColor, borderColor)
    local wm = GetWindowManager()

    local btn = wm:CreateControl(name, parent, CT_BUTTON)
    btn:SetDimensions(width, height)
    btn:SetMouseEnabled(true)

    -- Button background
    local bg = wm:CreateControl("$(parent)Bg", btn, CT_BACKDROP)
    bg:SetAnchorFill(btn)
    bg:SetCenterColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 0.9)
    bg:SetEdgeColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
    bg:SetEdgeTexture("", 1, 1, 1)
    btn.bg = bg

    -- Inner glow/highlight
    local glow = wm:CreateControl("$(parent)Glow", btn, CT_TEXTURE)
    glow:SetAnchor(TOPLEFT, btn, TOPLEFT, 2, 2)
    glow:SetAnchor(TOPRIGHT, btn, TOPRIGHT, -2, 2)
    glow:SetHeight(height / 3)
    glow:SetTexture("esoui/art/miscellaneous/inset_highlight.dds")
    glow:SetAlpha(0.15)
    btn.glow = glow

    -- Button text
    local label = wm:CreateControl("$(parent)Label", btn, CT_LABEL)
    label:SetFont("ZoFontGame")
    label:SetColor(textColor[1], textColor[2], textColor[3], textColor[4] or 1)
    label:SetText(text)
    label:SetAnchor(CENTER, btn, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    btn.label = label

    return btn
end

-- ============================================================================
-- UI CREATION (Professional Style)
-- ============================================================================
function DailyTracker.CreateUI()
    local wm = GetWindowManager()

    -- Calculate center position for first-time users
    local windowWidth = 280
    local windowHeight = 200
    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()

    -- Use saved position or center if first run
    local posLeft = sv.left or ((screenWidth - windowWidth) / 2)
    local posTop = sv.top or ((screenHeight - windowHeight) / 2)

    -- Main Window
    local tlw = wm:CreateTopLevelWindow("DailyPledgeManagerWin")
    tlw:SetMouseEnabled(true)
    tlw:SetMovable(not sv.locked)
    tlw:SetClampedToScreen(true)
    tlw:SetDimensions(windowWidth, windowHeight)
    tlw:SetHidden(not sv.windowVisible)
    tlw:SetHandler("OnMoveStop", function(self)
        sv.left = self:GetLeft()
        sv.top = self:GetTop()
    end)
    tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, posLeft, posTop)
    DailyTracker.MainWindow = tlw

    -- Save position if it was centered (first run)
    if sv.left == nil then
        sv.left = posLeft
        sv.top = posTop
    end

    -- Main background with gradient feel
    local bg = wm:CreateControl("$(parent)Bg", tlw, CT_BACKDROP)
    bg:SetAnchorFill(tlw)
    bg:SetCenterColor(0.08, 0.08, 0.1, sv.windowOpacity)
    bg:SetEdgeColor(0.5, 0.45, 0.35, 1)
    bg:SetEdgeTexture("", 2, 2, 2)

    -- Header bar
    local headerBar = wm:CreateControl("$(parent)Header", tlw, CT_BACKDROP)
    headerBar:SetAnchor(TOPLEFT, tlw, TOPLEFT, 2, 2)
    headerBar:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -2, 2)
    headerBar:SetHeight(32)
    headerBar:SetCenterColor(0.15, 0.13, 0.1, 0.95)
    headerBar:SetEdgeColor(0.4, 0.35, 0.25, 0.8)
    headerBar:SetEdgeTexture("", 1, 1, 1)

    -- Title icon
    local titleIcon = wm:CreateControl("$(parent)TitleIcon", tlw, CT_TEXTURE)
    titleIcon:SetTexture("esoui/art/lfg/lfg_indexicon_dungeon_up.dds")
    titleIcon:SetDimensions(26, 26)
    titleIcon:SetAnchor(LEFT, headerBar, LEFT, 8, 0)

    -- Title text
    local titleLabel = wm:CreateControl("$(parent)Title", tlw, CT_LABEL)
    titleLabel:SetFont("ZoFontWinH3")
    titleLabel:SetColor(0.95, 0.85, 0.55, 1)
    titleLabel:SetText("Daily Pledges")
    titleLabel:SetAnchor(LEFT, titleIcon, RIGHT, 6, 0)
    DailyTracker.TitleLabel = titleLabel

    -- Notification Bell
    local bellBtn = wm:CreateControl("$(parent)Bell", tlw, CT_BUTTON)
    bellBtn:SetDimensions(22, 22)
    bellBtn:SetAnchor(LEFT, titleLabel, RIGHT, 8, 0)
    bellBtn:SetHidden(true)
    bellBtn:SetNormalTexture("esoui/art/tutorial/tutorial_icon_notification.dds")
    bellBtn:SetHandler("OnClicked", function()
        DailyTracker.DismissNotification()
    end)
    bellBtn:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        SetTooltipText(InformationTooltip, "New pledges available! Click to dismiss.")
    end)
    bellBtn:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    DailyTracker.NotificationBell = bellBtn

    -- Mode toggle button
    local modeBtn = wm:CreateControl("$(parent)ModeBtn", tlw, CT_BUTTON)
    modeBtn:SetDimensions(60, 20)
    modeBtn:SetAnchor(RIGHT, tlw, TOPRIGHT, -52, 18)

    local modeBg = wm:CreateControl("$(parent)Bg", modeBtn, CT_BACKDROP)
    modeBg:SetAnchorFill(modeBtn)
    modeBg:SetCenterColor(0.2, 0.18, 0.15, 0.9)
    modeBg:SetEdgeColor(0.5, 0.4, 0.3, 0.8)
    modeBg:SetEdgeTexture("", 1, 1, 1)
    modeBtn.bg = modeBg

    local modeLbl = wm:CreateControl("$(parent)Label", modeBtn, CT_LABEL)
    modeLbl:SetFont("ZoFontGameSmall")
    modeLbl:SetText(sv.preferVeteran and "|cFF9933Veteran|r" or "|cAAFFAANormal|r")
    modeLbl:SetAnchor(CENTER, modeBtn, CENTER, 0, 0)
    modeBtn.label = modeLbl

    modeBtn:SetHandler("OnClicked", function() DailyTracker.ToggleDungeonMode() end)
    modeBtn:SetHandler("OnMouseEnter", function(self)
        self.bg:SetCenterColor(0.3, 0.25, 0.2, 0.95)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        SetTooltipText(InformationTooltip, "Toggle Veteran/Normal mode")
    end)
    modeBtn:SetHandler("OnMouseExit", function(self)
        self.bg:SetCenterColor(0.2, 0.18, 0.15, 0.9)
        ClearTooltip(InformationTooltip)
    end)
    DailyTracker.ModeToggle = modeBtn

    -- Minimize button
    local minBtn = wm:CreateControl("$(parent)Min", tlw, CT_BUTTON)
    minBtn:SetDimensions(20, 20)
    minBtn:SetAnchor(RIGHT, tlw, TOPRIGHT, -28, 18)

    local minIcon = wm:CreateControl("$(parent)Icon", minBtn, CT_TEXTURE)
    minIcon:SetTexture("esoui/art/buttons/minus_up.dds")
    minIcon:SetDimensions(16, 16)
    minIcon:SetAnchor(CENTER, minBtn, CENTER, 0, 0)
    minBtn.icon = minIcon

    minBtn:SetHandler("OnClicked", function() DailyTracker.ToggleCollapse() end)
    minBtn:SetHandler("OnMouseEnter", function(self) self.icon:SetAlpha(0.7) end)
    minBtn:SetHandler("OnMouseExit", function(self) self.icon:SetAlpha(1) end)
    DailyTracker.MinimizeBtn = minBtn

    -- Close button
    local closeBtn = wm:CreateControl("$(parent)Close", tlw, CT_BUTTON)
    closeBtn:SetDimensions(20, 20)
    closeBtn:SetAnchor(RIGHT, tlw, TOPRIGHT, -6, 18)

    local closeIcon = wm:CreateControl("$(parent)Icon", closeBtn, CT_TEXTURE)
    closeIcon:SetTexture("esoui/art/buttons/decline_up.dds")
    closeIcon:SetDimensions(18, 18)
    closeIcon:SetAnchor(CENTER, closeBtn, CENTER, 0, 0)
    closeBtn.icon = closeIcon

    closeBtn:SetHandler("OnClicked", function() DailyTracker.ToggleWindow() end)
    closeBtn:SetHandler("OnMouseEnter", function(self) self.icon:SetTexture("esoui/art/buttons/decline_over.dds") end)
    closeBtn:SetHandler("OnMouseExit", function(self) self.icon:SetTexture("esoui/art/buttons/decline_up.dds") end)
    DailyTracker.CloseBtn = closeBtn

    -- Divider line
    local divider = wm:CreateControl("$(parent)Divider", tlw, CT_TEXTURE)
    divider:SetTexture("esoui/art/miscellaneous/horizontaldivider.dds")
    divider:SetAnchor(TOPLEFT, headerBar, BOTTOMLEFT, 5, 2)
    divider:SetAnchor(TOPRIGHT, headerBar, BOTTOMRIGHT, -5, 2)
    divider:SetHeight(3)
    divider:SetColor(0.6, 0.5, 0.35, 0.6)
    DailyTracker.Divider = divider

    -- Reset Timer Label (centered below divider)
    local timerLabel = wm:CreateControl("$(parent)ResetTimer", tlw, CT_LABEL)
    timerLabel:SetFont("ZoFontGame")
    timerLabel:SetColor(0.7, 0.7, 0.8, 1)
    timerLabel:SetText("Pledges reset in --:--:--")
    timerLabel:SetAnchor(TOP, divider, BOTTOM, 0, 2)
    timerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    timerLabel:SetMouseEnabled(true)
    timerLabel:SetHandler("OnMouseEnter", function(self)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        local resetHour = RESET_TIMES[sv.server] or RESET_TIMES.NA
        SetTooltipText(InformationTooltip, string.format("Daily pledges reset at %02d:00 UTC (%s server)", resetHour, sv.server))
    end)
    timerLabel:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    DailyTracker.ResetTimerLabel = timerLabel

    -- Content container (re-anchored dynamically based on reset timer visibility)
    local container = wm:CreateControl("$(parent)Container", tlw, CT_CONTROL)
    container:SetHeight(100)
    DailyTracker.Container = container

    -- Button container (anchored to bottom of window so buttons stay in place)
    local buttonContainer = wm:CreateControl("$(parent)ButtonContainer", tlw, CT_CONTROL)
    buttonContainer:SetAnchor(BOTTOM, tlw, BOTTOM, 0, -10)
    buttonContainer:SetDimensions(260, 70)
    buttonContainer:SetHidden(true)
    DailyTracker.ButtonContainer = buttonContainer

    -- Queue All button (styled)
    local qAllBtn = CreateStyledButton(
        buttonContainer,
        "$(parent)QueueAll",
        220, 30,
        "Queue All Pledges",
        {0.9, 0.95, 0.7, 1},      -- text color (light gold)
        {0.2, 0.35, 0.2, 0.95},   -- bg color (dark green)
        {0.4, 0.6, 0.3, 1}        -- border color (green)
    )
    qAllBtn:SetAnchor(TOP, buttonContainer, TOP, 0, 0)
    qAllBtn:SetHandler("OnClicked", DailyTracker.QueueAllPledges)
    qAllBtn:SetHandler("OnMouseEnter", function(self)
        self.bg:SetCenterColor(0.25, 0.45, 0.25, 0.98)
        self.label:SetColor(1, 1, 0.8, 1)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        local mode = sv.preferVeteran and "Veteran" or "Normal"
        SetTooltipText(InformationTooltip, "Queue for all incomplete " .. mode .. " pledges")
    end)
    qAllBtn:SetHandler("OnMouseExit", function(self)
        self.bg:SetCenterColor(0.2, 0.35, 0.2, 0.95)
        self.label:SetColor(0.9, 0.95, 0.7, 1)
        ClearTooltip(InformationTooltip)
    end)
    -- Key hint label for Queue All (hidden until a keybind is assigned)
    local qAllKey = wm:CreateControl("$(parent)KeyHint", qAllBtn, CT_LABEL)
    qAllKey:SetFont("ZoFontGameSmall")
    qAllKey:SetColor(0.7, 0.85, 0.5, 0.75)
    qAllKey:SetText("")
    qAllKey:SetAnchor(RIGHT, qAllBtn, RIGHT, -8, 0)
    qAllKey:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    qAllKey:SetMouseEnabled(false)
    qAllKey:SetHidden(true)
    DailyTracker.QueueAllBtn = qAllBtn

    -- Abandon All button (styled)
    local abandonBtn = CreateStyledButton(
        buttonContainer,
        "$(parent)Abandon",
        160, 26,
        "Abandon All",
        {0.9, 0.7, 0.6, 1},       -- text color (light red)
        {0.35, 0.15, 0.15, 0.9},  -- bg color (dark red)
        {0.5, 0.3, 0.25, 1}       -- border color (red)
    )
    abandonBtn:SetAnchor(TOP, qAllBtn, BOTTOM, 0, 8)
    abandonBtn:SetHandler("OnClicked", DailyTracker.AbandonAllPledges)
    abandonBtn:SetHandler("OnMouseEnter", function(self)
        self.bg:SetCenterColor(0.45, 0.2, 0.2, 0.95)
        self.label:SetColor(1, 0.8, 0.7, 1)
        InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5)
        SetTooltipText(InformationTooltip, "Abandon all pledge quests")
    end)
    abandonBtn:SetHandler("OnMouseExit", function(self)
        self.bg:SetCenterColor(0.35, 0.15, 0.15, 0.9)
        self.label:SetColor(0.9, 0.7, 0.6, 1)
        ClearTooltip(InformationTooltip)
    end)
    -- Key hint label for Abandon All (hidden until a keybind is assigned)
    local abandonKey = wm:CreateControl("$(parent)KeyHint", abandonBtn, CT_LABEL)
    abandonKey:SetFont("ZoFontGameSmall")
    abandonKey:SetColor(0.9, 0.55, 0.45, 0.75)
    abandonKey:SetText("")
    abandonKey:SetAnchor(RIGHT, abandonBtn, RIGHT, -8, 0)
    abandonKey:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    abandonKey:SetMouseEnabled(false)
    abandonKey:SetHidden(true)
    DailyTracker.AbandonBtn = abandonBtn
end

-- ============================================================================
-- COMPASS PINS FOR UNDAUNTED ENCLAVE
-- ============================================================================
local COMPASS_PIN_UNDAUNTED = "DailyPledgeManager_UndauntedEnclave"

-- Undaunted Enclave locations by map texture path
local UNDAUNTED_LOCATIONS = {
    ["grahtwood/eldenrootgroundfloor_base"] = { 0.5673, 0.6613 },
    ["stormhaven/wayrest_base"] = { 0.1481, 0.4865 },
    ["deshaan/mournhold_base"] = { 0.3273, 0.6843 },
}

local function GetCurrentMapPath()
    local textureName = GetMapTileTexture()
    if textureName then
        local path = textureName:lower():match("maps/([%w%-]+/[%w%-]+_%w+)")
        return path
    end
    return nil
end

local function HasActivePledges()
    for i = 1, GetNumJournalQuests() do
        local questName = GetJournalQuestName(i)
        if string.find(questName, "Pledge:") then
            return true
        end
    end
    return false
end

local function InitializeCompassPins()
    if not COMPASS_PINS then
        d("|cFF6600[Daily Pledge Manager]|r CustomCompassPins not found - compass pins disabled. Install CustomCompassPins for compass navigation to Undaunted Enclaves.")
        return
    end

    local showingCustomLabel = false
    local labelOverrideActive = false

    local pinLayout = {
        maxDistance = 0.05,
        texture = "esoui/art/compass/quest_icon_assisted.dds",
        sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
            local size = 80 - 10 * normalizedDistance
            pin:SetDimensions(size, size)
            pin:SetDrawLayer(DL_OVERLAY)
            pin:SetDrawTier(DT_HIGH)
            pin:SetDrawLevel(1000)

            local absAngle = zo_abs(normalizedAngle)
            if absAngle < 0.08 then
                COMPASS.centerOverPinLabel:SetText("|cFF9900Daily Pledges Available|r")
                COMPASS.centerOverPinLabel:SetHidden(false)
                COMPASS.centerOverPinLabel:SetAlpha(1)
                showingCustomLabel = true
                labelOverrideActive = true
            elseif absAngle >= 0.15 and showingCustomLabel then
                showingCustomLabel = false
                labelOverrideActive = false
            end
        end,
        additionalLayout = {
            update = function(pin, angle, normalizedAngle, normalizedDistance)
                local icon = pin:GetNamedChild("Background")
                if icon then
                    icon:SetColor(1, 0.5, 0, 1)
                    icon:SetDrawLayer(DL_OVERLAY)
                    icon:SetDrawTier(DT_HIGH)
                    icon:SetDrawLevel(1000)
                end

                if labelOverrideActive then
                    COMPASS.centerOverPinLabel:SetText("|cFF9900Daily Pledges Available|r")
                    COMPASS.centerOverPinLabel:SetHidden(false)
                    COMPASS.centerOverPinLabel:SetAlpha(1)
                end
            end,
            reset = function(pin)
                local icon = pin:GetNamedChild("Background")
                if icon then
                    icon:SetColor(1, 1, 1, 1)
                end
                showingCustomLabel = false
                labelOverrideActive = false
            end,
        },
    }

    local function PinCallback()
        if not sv or not sv.showCompassPins then return end
        if not HasActivePledges() then return end

        local mapPath = GetCurrentMapPath()
        if not mapPath then return end

        local location = UNDAUNTED_LOCATIONS[mapPath]
        if location then
            COMPASS_PINS.pinManager:CreatePin(COMPASS_PIN_UNDAUNTED, "undaunted_enclave", location[1], location[2], "Undaunted Enclave")
        end
    end

    COMPASS_PINS:AddCustomPin(COMPASS_PIN_UNDAUNTED, PinCallback, pinLayout)
    COMPASS_PINS:RefreshPins(COMPASS_PIN_UNDAUNTED)
end

function DailyTracker.RefreshCompassPins()
    if COMPASS_PINS then
        COMPASS_PINS:RefreshPins(COMPASS_PIN_UNDAUNTED)
    end
end

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================
local function RegisterSlashCommands()
    SLASH_COMMANDS["/daily"] = function(args)
        if args == "" then
            DailyTracker.ToggleWindow()
        elseif args == "lock" then
            DailyTracker.ToggleLock()
        elseif args == "help" then
            d("|cFFD700â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•|r")
            d("|cFFD700  Daily Pledge Manager|r")
            d("|cFFD700â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•|r")
            d("  /daily - Toggle window")
            d("  /daily lock - Lock/unlock position")
            d("  /daily help - Show this help")
            d("|cFFD700â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•|r")
        else
            d("|cFFAA00[Daily Pledge Manager]|r Unknown command. Use /daily help")
        end
    end

    SLASH_COMMANDS["/pledges"] = SLASH_COMMANDS["/daily"]
end

-- ============================================================================
-- WELCOME / WHAT'S NEW POPUP
-- ============================================================================

function DailyTracker.GetWelcomeText()
    return table.concat({
        "Track and queue for your daily Undaunted pledges without",
        "opening the Activity Finder.",
        "",
        "|cFFAA00Features:|r",
        "  |cCCCCCC\226\128\162|r  One-click dungeon queuing from the tracker",
        "  |cCCCCCC\226\128\162|r  Queue All — queue every incomplete pledge at once",
        "  |cCCCCCC\226\128\162|r  Leave Queue — click Queue All again to leave",
        "  |cCCCCCC\226\128\162|r  Keybinds — Queue All, Abandon All, Toggle Window",
        "  |cCCCCCC\226\128\162|r  Veteran / Normal toggle",
        "  |cCCCCCC\226\128\162|r  Auto-accept ready checks",
        "  |cCCCCCC\226\128\162|r  Auto-accept pledges from quest givers",
        "  |cCCCCCC\226\128\162|r  Compass pins pointing to the Undaunted Enclave",
        "  |cCCCCCC\226\128\162|r  Pledge reset countdown timer",
        "  |cCCCCCC\226\128\162|r  New pledge notifications on daily reset",
        "  |cCCCCCC\226\128\162|r  Dungeon detection — tracks which pledge you're running",
        "  |cCCCCCC\226\128\162|r  Completion detection — shows when a pledge is ready to turn in",
        "",
        "|cFFAA00How to use:|r",
        "  |cFFFFFF/daily|r — Toggle the tracker window",
        "  |cFFFFFF/daily lock|r — Lock/unlock window position",
        "  |cFFFFFF/daily help|r — Show all commands",
        "  |cFFFFFF/dailysettings|r — Open settings panel",
        "",
        "Drag the tracker window to reposition it.",
    }, "\n")
end

function DailyTracker.GetChangelogText()
    local entries = CHANGELOG[ADDON_VERSION]
    if not entries or #entries == 0 then
        return "Minor fixes and improvements."
    end

    local lines = {}
    for _, entry in ipairs(entries) do
        table.insert(lines, "  |cCCCCCC\226\128\162|r  " .. entry)
    end

    return table.concat(lines, "\n")
end

function DailyTracker.ShowWelcomeOrUpdatePopup()
    if not sv then return end

    -- Same version — do nothing
    if sv.lastSeenVersion == ADDON_VERSION then return end

    local isFirstInstall = (sv.lastSeenVersion == nil)
    local titleText, bodyText

    if isFirstInstall then
        titleText = "Welcome to Daily Pledge Manager!"
        bodyText = DailyTracker.GetWelcomeText()
    else
        titleText = "What's New in v" .. ADDON_VERSION
        bodyText = DailyTracker.GetChangelogText()
    end

    local wm = GetWindowManager()
    local POPUP_WIDTH = 500
    local POPUP_HEIGHT = 440
    local BUTTON_HEIGHT = 34
    local PADDING = 20

    -- Create popup window
    local uniqueName = "DailyPledgeWelcomePopup" .. GetGameTimeMilliseconds()
    local popup = wm:CreateTopLevelWindow(uniqueName)
    popup:SetMouseEnabled(true)
    popup:SetMovable(true)
    popup:SetClampedToScreen(true)
    popup:SetDimensions(POPUP_WIDTH, POPUP_HEIGHT)
    popup:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    popup:SetDrawLayer(DL_OVERLAY)
    popup:SetDrawTier(DT_HIGH)
    popup:SetHidden(true)
    DailyTracker.WelcomePopupWindow = popup

    -- Background
    local bg = wm:CreateControl("$(parent)Bg", popup, CT_BACKDROP)
    bg:SetAnchorFill(popup)
    bg:SetCenterColor(0.08, 0.08, 0.1, 0.97)
    bg:SetEdgeColor(0.7, 0.55, 0.2, 1)
    bg:SetEdgeTexture("", 2, 2, 2)

    -- Title
    local title = wm:CreateControl("$(parent)Title", popup, CT_LABEL)
    title:SetFont("ZoFontWinH2")
    title:SetColor(1, 0.85, 0.35, 1)
    title:SetText(titleText)
    title:SetAnchor(TOP, popup, TOP, 0, PADDING)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Version subtitle (only for welcome)
    local subtitleOffset = 0
    if isFirstInstall then
        local subtitle = wm:CreateControl("$(parent)Subtitle", popup, CT_LABEL)
        subtitle:SetFont("ZoFontGameSmall")
        subtitle:SetColor(0.6, 0.6, 0.6, 1)
        subtitle:SetText("v" .. ADDON_VERSION .. " by DerpyNoodle")
        subtitle:SetAnchor(TOP, title, BOTTOM, 0, 4)
        subtitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        subtitleOffset = 22
    end

    -- Close X button (top right)
    local closeBtn = wm:CreateControl("$(parent)CloseBtn", popup, CT_BUTTON)
    closeBtn:SetDimensions(24, 24)
    closeBtn:SetAnchor(TOPRIGHT, popup, TOPRIGHT, -8, 8)

    local closeIcon = wm:CreateControl("$(parent)Icon", closeBtn, CT_TEXTURE)
    closeIcon:SetTexture("esoui/art/buttons/decline_up.dds")
    closeIcon:SetDimensions(20, 20)
    closeIcon:SetAnchor(CENTER, closeBtn, CENTER, 0, 0)

    local function DismissPopup()
        sv.lastSeenVersion = ADDON_VERSION
        -- Also clear legacy firstRun if set
        if sv.firstRun then sv.firstRun = false end

        local fadeStart = GetGameTimeMilliseconds()
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_WelcomePopupFadeOut", 20, function()
            local elapsed = GetGameTimeMilliseconds() - fadeStart
            local progress = elapsed / 400
            if progress >= 1 then
                popup:SetAlpha(0)
                popup:SetHidden(true)
                popup:SetMouseEnabled(false)
                EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_WelcomePopupFadeOut")
            else
                popup:SetAlpha(1 - progress)
            end
        end)
    end

    closeBtn:SetHandler("OnClicked", DismissPopup)
    closeBtn:SetHandler("OnMouseEnter", function() closeIcon:SetTexture("esoui/art/buttons/decline_over.dds") end)
    closeBtn:SetHandler("OnMouseExit", function() closeIcon:SetTexture("esoui/art/buttons/decline_up.dds") end)

    -- Scrollable content area
    -- Body text label (no scroll — ESO doesn't have CT_SCROLL, auto-size popup instead)
    local bodyLabel = wm:CreateControl("$(parent)Body", popup, CT_LABEL)
    bodyLabel:SetFont("ZoFontGame")
    bodyLabel:SetColor(0.85, 0.85, 0.85, 1)
    bodyLabel:SetText(bodyText)
    bodyLabel:SetWidth(POPUP_WIDTH - (PADDING * 2) - 16)
    bodyLabel:SetAnchor(TOP, title, BOTTOM, 0, 8 + subtitleOffset)
    bodyLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    -- Auto-size popup height based on text content
    local textHeight = bodyLabel:GetTextHeight()
    local totalHeight = 50 + subtitleOffset + 8 + textHeight + 12 + BUTTON_HEIGHT + PADDING + 10
    if totalHeight < POPUP_HEIGHT then totalHeight = POPUP_HEIGHT end
    popup:SetHeight(totalHeight)

    -- "Got it!" button at the bottom
    local gotItBtn = wm:CreateControl("$(parent)GotItBtn", popup, CT_BUTTON)
    gotItBtn:SetDimensions(140, BUTTON_HEIGHT)
    gotItBtn:SetAnchor(BOTTOM, popup, BOTTOM, 0, -PADDING)

    local gotItBg = wm:CreateControl("$(parent)Bg", gotItBtn, CT_BACKDROP)
    gotItBg:SetAnchorFill(gotItBtn)
    gotItBg:SetCenterColor(0.2, 0.35, 0.2, 0.95)
    gotItBg:SetEdgeColor(0.4, 0.6, 0.3, 1)
    gotItBg:SetEdgeTexture("", 1, 1, 1)

    local gotItGlow = wm:CreateControl("$(parent)Glow", gotItBtn, CT_TEXTURE)
    gotItGlow:SetAnchor(TOPLEFT, gotItBtn, TOPLEFT, 2, 2)
    gotItGlow:SetAnchor(TOPRIGHT, gotItBtn, TOPRIGHT, -2, 2)
    gotItGlow:SetHeight(BUTTON_HEIGHT / 3)
    gotItGlow:SetTexture("esoui/art/miscellaneous/inset_highlight.dds")
    gotItGlow:SetAlpha(0.15)

    local gotItLabel = wm:CreateControl("$(parent)Label", gotItBtn, CT_LABEL)
    gotItLabel:SetFont("ZoFontGame")
    gotItLabel:SetColor(0.9, 0.95, 0.7, 1)
    gotItLabel:SetText("Got it!")
    gotItLabel:SetAnchor(CENTER, gotItBtn, CENTER, 0, 0)
    gotItLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    gotItBtn:SetHandler("OnClicked", DismissPopup)
    gotItBtn:SetHandler("OnMouseEnter", function()
        gotItBg:SetCenterColor(0.25, 0.45, 0.25, 0.98)
        gotItLabel:SetColor(1, 1, 0.8, 1)
    end)
    gotItBtn:SetHandler("OnMouseExit", function()
        gotItBg:SetCenterColor(0.2, 0.35, 0.2, 0.95)
        gotItLabel:SetColor(0.9, 0.95, 0.7, 1)
    end)

    -- Fade in
    popup:SetAlpha(0)
    popup:SetHidden(false)

    local fadeInStart = GetGameTimeMilliseconds()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_WelcomePopupFadeIn", 20, function()
        local elapsed = GetGameTimeMilliseconds() - fadeInStart
        local progress = elapsed / 400

        if progress >= 1 then
            popup:SetAlpha(1)
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_WelcomePopupFadeIn")
        else
            popup:SetAlpha(progress)
        end
    end)
end

-- ============================================================================
-- INIT
-- ============================================================================
local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    sv = InitializeSavedVars()
    DailyTracker.savedVariables = sv

    zo_callLater(BuildActivityCache, 2000)

    DailyTracker.CreateUI()
    DailyTracker.UpdateUIDisplay()
    DailyTracker.StartResetTimer()
    CreateSettingsMenu()
    RegisterSlashCommands()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADDED, DailyTracker.OnQuestAdded)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_REMOVED, DailyTracker.UpdateUIDisplay)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_ADVANCED, DailyTracker.UpdateUIDisplay)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_CONDITION_COUNTER_CHANGED, DailyTracker.UpdateUIDisplay)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_QUEST_COMPLETE_DIALOG, DailyTracker.UpdateUIDisplay)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, DailyTracker.OnFinderUpdate)
    if EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVITY_FINDER_COOLDOWNS_UPDATE, DailyTracker.OnCooldownsUpdated)
    end
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, DailyTracker.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ZONE_CHANGED, DailyTracker.OnZoneChanged)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_KEYBINDING_CLEARED, function() DailyTracker.RefreshKeybindHints() end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_KEYBINDING_SET, function() DailyTracker.RefreshKeybindHints() end)
    zo_callLater(DailyTracker.RefreshKeybindHints, 1000)

    -- Auto Ready Check events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, DailyTracker.OnReadyCheck)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, DailyTracker.OnReadyCheck)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_NEW, DailyTracker.OnReadyCheck)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUPING_TOOLS_FIND_REPLACEMENT_NOTIFICATION_REMOVED, DailyTracker.OnReadyCheck)

    -- Auto Accept Pledges events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_CHATTER_BEGIN, DailyTracker.OnChatterBegin)

    zo_callLater(function()
        InitializeCompassPins()
    end, 3000)

    -- Show welcome or what's new popup (delayed so game is fully loaded)
    zo_callLater(function()
        DailyTracker.ShowWelcomeOrUpdatePopup()
    end, 2000)

    d("|cFFAA00[Daily Pledge Manager]|r v" .. ADDON_VERSION .. " loaded")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
