-- Common Works — core
--
-- SavedVariables and their defaults, the show/hide lifecycle, and /commonworks.

CommonWorksUI = CommonWorksUI or {}
local CW = CommonWorksUI

-- Must match the AddOn folder name, which is what EVENT_ADD_ON_LOADED reports.
CW.name    = "CommonWorksUI"
CW.version = "1.0"

local EM = EVENT_MANAGER

CW.defaults = {
    anchor             = { point = TOPLEFT, relativePoint = TOPLEFT, x = 280, y = 190 },
    pinned             = false,
    stowed             = false,
    backdropAlpha      = 0,      -- off; the panel reads fine over the world
    stowInCombat       = false,  -- the whole panel, not a section
    -- IDs keep saved choices stable when TOME_FILTERS (UI.lua) is reordered.
    tomeFilter         = { seasonal = "incomplete", weekly = "inProgress" },
    hideQuestTrackerInInstances = true,
    showActiveQuestInInstances  = true,
    autoClaimTomePoints = true,
    autoWritTurnIn     = false,  -- chains Rolis turn-ins; needs WritWorthy + Lazy Writ Crafter
    writCloseTimeoutMs = 1000,  -- ms spent closing Rolis's window before asking you to; 0 = never
    -- 3D world pins for uncollected Mages Guild lore books (needs LoreBooks + CrutchAlerts).
    loreBookPins         = true,
    loreBookPinDistance  = 150,   -- metres; farther away gets no icon
    loreBookPinSize      = 120,   -- 100 = a 1m icon
    loreBookPinHeight    = 0,     -- metres above the player's own elevation
    loreBookPinStyle     = "book", -- book | diamond | icon; see PIN_STYLES
    loreBookPinColor     = { 0.5, 0.4, 1 },
    loreBookPinArriveColor = { 1, 1, 1 },    -- taken on once you are standing on it
    -- Written only at runtime, so absent here: toggleSprintRestoreValue,
    -- friendlyHealthBarsRestore ([{id, value}] per option changed on PvP entry),
    -- lastProgressedQuest ({ id, name }).
    toggleSprintOnMount = false,  -- holds ESO's own Toggle Sprint on, and restores it
    showMountSprintIcon = true,
    mountSprintIconScale = 60,   -- percent of the texture's native 64px
    mountSprintIconTint = { 0.00, 1.00, 0.27, 0.59 },
    mountSprintIconPosition = { point = CENTER, relativePoint = CENTER, x = 0, y = 180 },
    ttcPromoteMenuEntries = true,  -- lifts TTC's two web actions out of its submenu
    guildStoreShowTrait = true,
    dungeonFinderEnhance = true,
    friendlyHealthBarsInPvp   = false,  -- group + friendly bars to Injured, in PvP zones
    showOffBalanceTracker = true,
    offBalanceFlash = true,
    offBalanceFontFace = "DM Sans Bold",
    offBalanceFontSize = 40,
    offBalanceColor = { 0.30, 1.00, 0.35, 1.00 },
    offBalanceBarHeight = 9,     -- 0 hides the bar, leaving the text
    offBalancePosition = { point = CENTER, relativePoint = CENTER, x = 0, y = -160 },
    -- Low health alert: warn when player health drops to/below a percentage.
    healthAlertEnabled   = true,
    healthAlertThreshold = 40,     -- % of max health
    healthAlertText      = "LOW HEALTH",
    healthAlertFontFace  = "DM Sans Bold",
    healthAlertFontSize  = 46,
    healthAlertColor     = { 1.00, 0.20, 0.20, 1.00 },
    healthAlertDuration  = 1000,   -- ms the label stays up; 0 = sound only
    healthAlertCooldown  = 3000,   -- ms between alerts; 0 = every health tick
    healthAlertSound     = "DUEL_START",
    healthAlertVolume    = 4,      -- same-tick PlaySound repeats; 0 = silent
    healthAlertPosition  = { point = CENTER, relativePoint = CENTER, x = 0, y = -220 },

    -- PvP-only incoming alerts; see CW.UpdateIncomingAlertTracking.
    -- One toggle per CW.INCOMING_ALERTS entry.
    incomingAlertEnabled     = true,
    incomingAlertCorrosive   = true,
    incomingAlertOnslaught   = true,
    incomingAlertRadiant     = true,
    incomingAlertRapidFire   = true,
    incomingAlertSoulAssault = true,
    incomingAlertFatecarver  = true,
    incomingAlertArcanistUlt = true,
    incomingAlertDestroUlt   = true,
    incomingAlertChat        = true,  -- overlapping warnings also go to chat
    incomingAlertFontFace    = "DM Sans Bold",
    incomingAlertFontSize    = 36,
    incomingAlertColor       = { 1.00, 0.15, 0.15, 1.00 },
    incomingAlertUnderlineColor = { 1.00, 0.00, 0.00, 1.00 },
    incomingAlertSound       = "ABILITY_WEAPON_SWAP_FAIL",
    incomingAlertVolume      = 7,      -- same-tick PlaySound repeats; 0 = silent
    incomingAlertPosition    = { point = CENTER, relativePoint = CENTER, x = 0, y = -280 },

    -- CC immunity works in all zones; players look for it in the PvP tab.
    ccImmunityEnabled     = true,
    ccImmunityText        = "CC IMMUNE",
    ccImmunitySoftText    = "ROOT IMMUNE",
    ccImmunityShowSeconds = true,
    ccImmunityFontFace    = "DM Sans Bold",
    ccImmunityFontSize    = 28,
    ccImmunityColor       = { 0.35, 0.80, 1.00, 1.00 },   -- hard CC immunity
    ccImmunitySoftColor   = { 0.60, 1.00, 0.60, 1.00 },   -- snare/root break only
    ccImmunityBarHeight   = 7,     -- 0 hides the bar and leaves the text
    ccImmunityPosition    = { point = CENTER, relativePoint = CENTER, x = 0, y = -100 },

    -- Negate Magic warning. PvP zones only, like the incoming alert above.
    negateAlertEnabled  = true,
    negateAlertText     = "NEGATE",
    negateAlertFontFace = "DM Sans Bold",
    negateAlertFontSize = 59,
    negateAlertColor    = { 0.75, 0.40, 1.00, 1.00 },
    negateAlertDuration = 8000,    -- ms; the field can drop you without a FADED
    negateAlertSound    = "DEFER_NOTIFICATION",
    negateAlertVolume   = 9,       -- same-tick PlaySound repeats; 0 = silent
    negateAlertPosition = { point = CENTER, relativePoint = CENTER, x = 0, y = -380 },
    -- Chat pop-up: group and whisper messages mirrored onto the HUD, newest on top.
    chatAlerts             = true,
    chatAlertsCombatOnly   = true,   -- the point of the feature
    chatAlertsWhisperAlways = false,  -- on: whispers show out of combat too
    chatAlertTestMode      = false,  -- show every channel, in or out of combat
    chatAlertFontFace      = "DM Sans Bold",
    chatAlertFontSize      = 29,
    chatAlertNameColor     = { 1.00, 0.65, 0.20, 1.00 },   -- the orange group tone
    chatAlertTextColor     = { 1.00, 1.00, 1.00, 1.00 },
    chatAlertSound         = "NEW_NOTIFICATION",
    chatAlertVolume        = 4,      -- same-tick PlaySound repeats; 0 = silent
    chatAlertDuration      = 3,      -- seconds
    chatAlertWidth         = 860,    -- messages wrap to this
    -- A corner anchor keeps text still as the display grows.
    chatAlertPosition      = { point = TOPLEFT, relativePoint = CENTER, x = -420, y = -100 },
    -- Blighted Blastbones tones: optional spawn beep, then two cooldown cues.
    blastbonesEnabled = false,
    blastbonesSound0  = "COUNTDOWN_TICK",
    blastbonesVolume0 = 8,         -- 0 keeps the summon itself silent
    blastbonesSound1  = "COUNTDOWN_TICK",
    blastbonesVolume1 = 8,         -- same-tick PlaySound repeats; 0 = tone off
    blastbonesDelay1  = 1000,      -- ms after the cast
    blastbonesSound2  = "OUTFIT_WEAPON_TYPE_RUNE",
    blastbonesVolume2 = 5,
    blastbonesDelay2  = 3500,
    -- GCD-ready alerts fire when a watched ability's global cooldown clears.
    -- Per-ability records live in gcdAlerts; font/color/position are shared.
    gcdAlertEnabled   = true,
    gcdAlerts         = {},
    gcdAlertMaxWaitMs = 2500,      -- drop a pending alert after this; 0 alerts fired
    gcdAlertFontFace  = "DM Sans SemiBold",
    gcdAlertFontSize  = 36,
    -- Initial per-ability colors (entry.color / colorOn / colorOff).
    gcdAlertColor     = { 0.35, 1.00, 0.45, 1.00 },
    gcdAlertColorOn   = { 0.35, 1.00, 0.45, 1.00 },
    gcdAlertColorOff  = { 1.00, 0.42, 0.35, 1.00 },
    gcdAlertPosition  = { point = CENTER, relativePoint = CENTER, x = 0, y = -340 },
    -- Expire reminders use gcdAlerts (entry.kind == "expire") but a separate icon/countdown widget.
    expireReminderFontFace = "DM Sans Bold",
    expireReminderFontSize = 28,
    expireReminderIconSize = 48,
    expireReminderPosition = { point = CENTER, relativePoint = CENTER, x = 0, y = -260 },
    -- LarvalTear: build wheel keybind and current-build HUD label.
    ltWheel           = true,
    ltBuildDisplay    = true,
    ltBuildSets       = true,
    ltBuildSetsFontSize = 12,
    -- Reads as a caption: the gear is reference, the build name is the headline.
    ltBuildSetsColor  = { 1.00, 1.00, 1.00, 0.58 },
    ltBuildFontFace   = "DM Sans SemiBold",
    ltBuildFontSize   = 14,
    ltBuildColor      = { 1.00, 1.00, 1.00, 0.76 },
    ltBuildPosition   = { point = CENTER, relativePoint = CENTER, x = 0, y = 300 },
    -- LarvalTear builds exclude poisons; show which bar remains poisoned after a swap.
    ltPoisonAlert          = true,
    ltPoisonAlertFontFace  = "DM Sans Bold",
    ltPoisonAlertFontSize  = 36,
    ltPoisonAlertColor     = { 0.55, 0.90, 0.45, 1.00 },
    ltPoisonAlertPosition  = { point = CENTER, relativePoint = CENTER, x = 0, y = 240 },
    -- Light attack tracker (LibCombat): grades each cast's preceding light attack and GCD delay.
    laStats            = false,
    laStatsFontFace    = "DM Sans Medium",
    laStatsFontSize    = 16,
    laStatsColor       = { 1.00, 1.00, 1.00, 1.00 },
    laStatsPosition    = { point = CENTER, relativePoint = CENTER, x = 0, y = 340 },
    laStatsSeparator   = "   ",
    laStatsOutOfCombat = true,     -- keep the result up after the fight
    laStatsAccuracy    = true,
    laStatsCount       = true,
    laStatsMissed      = false,
    laStatsLate        = true,
    laStatsAvgGap      = true,
    laStatsWasted      = true,
    laStatsActive      = false,
    laStatsFlash       = true,
    laStatsFlashColor  = { 0.65, 0.86, 0.53, 1.00 },   -- Pantone 358 C, pale enough to read through
    laStatsFlashGrow   = 80,
    -- Millisecond cutoffs for a late weave and a stopped rotation.
    laLateCutoff       = 120,
    laBreakCutoff      = 1500,
    laHitSound         = false,
    laHitSoundKey      = "OUTFIT_WEAPON_TYPE_STAFF",
    laHitSoundVolume   = 5,
    pledges            = { dayKey = "", completedByCharacter = {} },
    -- Gutter checkmarks (UI.toggleGroups). Absent key = shown; no migration needed.
    groupHidden        = { tomeSeasonal = true },
    -- key -> itemLink (GuildStoreIgnore.lua). Seeded defaults would restore removed entries on load.
    -- Empty skips the filter.
    storeIgnored         = {},
    storeIgnoreList      = false,  -- installs the feature; storeIgnoreEnabled is the panel's filter toggle
    storeIgnoreEnabled  = true,
    storeIgnoreListShown = false,
    storeIgnorePos       = { x = 120, y = 120 },  -- upper left: fits any resolution
    -- key -> newest-first prices (PurchaseLog.lua); account-wide for purchases received on alts.
    purchases            = {},
    purchaseLog          = false,
    purchaseLogShown     = false,
    purchaseLogPos       = { x = 120, y = 120 },
    -- UI.SyncTheme overrides; color defaults come from Themes.lua's default palette.
    appearance = {
        preset     = CW.DEFAULT_PALETTE,
        typeface   = "DM Sans SemiBold",
        -- The font string's third field; "" is Normal, with no edge at all.
        fontStyle  = "soft-shadow-thin",
        -- SyncTheme derives the age font, row heights and quest icon size from these
        -- heading (quest, section and footer names) and row sizes.
        pt = { title = 16, body = 15 },
        panelWidth = 380,
        headerColor             = CW.GetPaletteColor(CW.DEFAULT_PALETTE, "headerColor"),
        activeTitleColor        = CW.GetPaletteColor(CW.DEFAULT_PALETTE, "activeTitleColor"),
        activeObjColor          = CW.GetPaletteColor(CW.DEFAULT_PALETTE, "activeObjColor"),
        activeDoneColor         = CW.GetPaletteColor(CW.DEFAULT_PALETTE, "activeDoneColor"),
        activeCountColor        = CW.GetPaletteColor(CW.DEFAULT_PALETTE, "activeCountColor"),
        trackedTomeHeaderColor  = CW.GetPaletteColor(CW.DEFAULT_PALETTE, "trackedTomeHeaderColor"),
        dividerColor          = { 1, 1, 1, 0.205 },
        dividerHeight         = 2,
        dividerWidthPct       = 50,   -- of the panel width; over 100 overhangs both edges
        dividerUnderline      = true, -- rule under each header's text instead of above it
    },
}


-- Keep the saved visibility toggle separate from temporary combat and scene hiding.
CW.inCombat   = false
CW.inGameplay = true

function CW.ShouldHideTracker()
    local sv = CW.SavedVars
    -- Preview overrides hiding without changing the saved preference.
    if CW.UI.SettingsPanelOpen() then return false end
    return sv.stowed or not CW.inGameplay or (sv.stowInCombat and CW.inCombat)
end

function CW.SyncVisibility()
    if CW.ShouldHideTracker() then
        CW.UI.SetPanelHidden(true)
    else
        -- Hidden panels skip layout; Redraw rebuilds it and restores the backdrop.
        CW.UI.Redraw()
    end
end

function CW.TogglePanel()
    CW.SavedVars.stowed = not CW.SavedVars.stowed
    CW.SyncVisibility()
end

-- Bare /commonworks opens settings; `toggle` restores a hidden panel without a keybind.
local COMMANDS = {
    toggle = function() CW.TogglePanel() end,
    lock = function()
        local pinned = not CW.SavedVars.pinned
        CW.SavedVars.pinned = pinned
        CW.UI.SyncLock()
        d(CW.BRAND .. ": panel " .. (pinned and "locked" or "unlocked"))
    end,
    reset = function()
        CW.SavedVars.anchor = ZO_DeepTableCopy(CW.defaults.anchor)
        CW.UI.SyncAnchor()
        d(CW.BRAND .. ": panel moved back to its starting corner")
    end,
}

local function OnSlashCommand(arg)
    local command = COMMANDS[zo_strtrim(zo_strlower(arg or ""))]
    if command then command() else CW.UI.ShowSettings() end
end

-- Lifecycle

-- Restrict the panel to the two gameplay scenes so it stays out of menus.
local function SyncGameplayState()
    CW.inGameplay = HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()
end

-- HUD_UI_SCENE hides before HUD_SCENE shows after interactions.
-- Wait for both to settle to avoid flicker after quest turn-ins.
local visibilityQueued = false
local function QueueVisibility()
    if visibilityQueued then return end
    visibilityQueued = true
    zo_callLater(function()
        visibilityQueued = false
        SyncGameplayState()
        -- Mouse mode ends without OnMouseExit, leaving the chrome expanded.
        if not HUD_UI_SCENE:IsShowing() then CW.UI.ClearChromeHover() end
        CW.SyncVisibility()
        -- Clear all widget placement flags so previews cannot outlive the panel.
        CW.RefreshHudPlacement()
    end, 0)
end

local function WatchScenes()
    SyncGameplayState()
    local function onSceneChange(_, newState)
        if newState == SCENE_SHOWN or newState == SCENE_HIDDEN then QueueVisibility() end
    end
    HUD_SCENE:RegisterCallback("StateChange", onSceneChange)
    HUD_UI_SCENE:RegisterCallback("StateChange", onSceneChange)
end

local RegisterRuntimeEvents
local runtimeEventsRegistered = false
local activityFinderCallbackRegistered = false

local function OnRefreshEvent()
    CW.RedrawSoon()
end

-- Cyrodiil / IC only; leaving forgets the history.
local AVA_EVENTS = { EVENT_OBJECTIVES_UPDATED, EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
                     EVENT_KEEP_UNDER_ATTACK_CHANGED, EVENT_KILL_LOCATIONS_UPDATED }
local function UpdateAvaWatch()
    local on = CW.PvpFocusMode()
    for _, ev in ipairs(AVA_EVENTS) do
        if on then EM:RegisterForEvent(CW.name, ev, OnRefreshEvent)
        else EM:UnregisterForEvent(CW.name, ev) end
    end
    if not on then
        EM:UnregisterForUpdate(CW.name .. "AvaWatch")
        CW.UI.pvpSeen, CW.UI.battleSeen, CW.UI.pvpRecent = {}, {}, {}
        return
    end
    EM:RegisterForUpdate(CW.name .. "AvaWatch", 2500, function()
        if CW.PvpStateChanged() then CW.RedrawSoon() end
    end)
end

local function RegisterActivityFinderCallback()
    if activityFinderCallbackRegistered then return end
    ZO_ACTIVITY_FINDER_ROOT_MANAGER:RegisterCallback("OnActivityFinderStatusUpdate", OnRefreshEvent)
    activityFinderCallbackRegistered = true
end

local function RecheckMountedToggleSprint()
    CW.UpdateMountedToggleSprint(IsMounted())
end

local function OnPlayerActivated()
    CW.currentZoneDisplayType = CW.pendingZoneDisplayType
    CW.pendingZoneDisplayType = nil
    SyncGameplayState()
    CW.inCombat = IsUnitInCombat("player")
    if not runtimeEventsRegistered then
        runtimeEventsRegistered = true
        RegisterRuntimeEvents()
    end
    RegisterActivityFinderCallback()
    UpdateAvaWatch()
    -- Retry controls absent at EVENT_ADD_ON_LOADED; registration flags prevent duplicate work.
    CW.InstallFunDLCButton()
    CW.UpdateWritBridge()
    CW.UpdateLoreBookPins()
    CW.UpdateChatAlerts()
    -- LarvalTear fills its build store at its own EVENT_ADD_ON_LOADED.
    CW.UpdateLarvalTear()
    CW.UpdateOffBalanceTracking()
    CW.UpdateHealthAlertTracking()
    CW.UpdateIncomingAlertTracking()
    CW.UpdateNegateAlertTracking()
    CW.UpdateLaStatsTracking()
    CW.UpdateFriendlyHealthBars()
    CW.ResetHealthAlertThrottle()
    RecheckMountedToggleSprint()
    CW.RedrawSoon()
    CW.QueueTomeResync()
    CW.AutoClaimTomePoints()
end

RegisterRuntimeEvents = function()
    local onQuestEvent = OnRefreshEvent
    -- These fire per kill, so they batch longer than other events.
    local progressQueued = false
    local function redrawAfterProgress()
        if progressQueued then return end
        progressQueued = true
        zo_callLater(function()
            progressQueued = false
            CW.RedrawSoon()
        end, 200)
    end
    local function onQuestProgress(...)
        CW.RecordLastProgressedQuestFromArgs(select(2, ...))
        redrawAfterProgress()
    end

    EM:RegisterForEvent(CW.name, EVENT_PREPARE_FOR_JUMP,
        function(_, _zoneName, _zoneDescription, _loadingTexture, zoneDisplayType)
            CW.pendingZoneDisplayType = zoneDisplayType
            CW.RestoreMountedToggleSprint()
        end)

    EM:RegisterForEvent(CW.name, EVENT_PLAYER_DEACTIVATED, function()
        CW.RestoreMountedToggleSprint()
    end)

    EM:RegisterForEvent(CW.name, EVENT_QUEST_ADDED, function()
        CW.RedrawSoon()
    end)
    EM:RegisterForEvent(CW.name, EVENT_QUEST_REMOVED, function(_, isCompleted, _journalIndex, questName)
        if isCompleted then
            CW.RecordCompletedUndauntedPledge(questName)
        end
        CW.RedrawSoon()
    end)
    HOUSING_EDITOR_STATE:RegisterCallback("HouseSettingsChanged", onQuestEvent)
    -- The campaign queue's four transitions; nothing here polls.
    for _, event in ipairs({ EVENT_CAMPAIGN_QUEUE_JOINED, EVENT_CAMPAIGN_QUEUE_LEFT,
                             EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED,
                             EVENT_CAMPAIGN_QUEUE_STATE_CHANGED }) do
        EM:RegisterForEvent(CW.name, event, onQuestEvent)
    end

    EM:RegisterForEvent(CW.name, EVENT_QUEST_ADVANCED,                  onQuestProgress)
    EM:RegisterForEvent(CW.name, EVENT_QUEST_OPTIONAL_STEP_ADVANCED,    onQuestProgress)
    EM:RegisterForEvent(CW.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, onQuestProgress)

    -- An assist change arrives here, not on any quest event.
    EM:RegisterForEvent(CW.name, EVENT_TRACKING_UPDATE, onQuestEvent)

    -- The claim sweep runs first, so the refresh behind it already has the receipt.
    EM:RegisterForEvent(CW.name, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, function()
        CW.AutoClaimTomePoints()
        redrawAfterProgress()
    end)
    EM:RegisterForEvent(CW.name, EVENT_TIMED_ACTIVITIES_UPDATED, function()
        CW.AutoClaimTomePoints()
        CW.RedrawSoon()
        CW.QueueTomeResync()
    end)

    -- Track zone-story assist changes for our Zone Guide block (CW.ReadZoneStory).
    for _, ev in ipairs({
        EVENT_ZONE_STORY_ACTIVITY_TRACKED,
        EVENT_ZONE_STORY_ACTIVITY_UNTRACKED,
        EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT,
    }) do
        EM:RegisterForEvent(CW.name, ev, onQuestEvent)
    end

    -- Use the native tracker's status source; guarded until the LFG UI exists.
    RegisterActivityFinderCallback()
    for _, ev in ipairs({
        EVENT_ACTIVITY_FINDER_STATUS_UPDATE,
        EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED,
        EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED,
    }) do
        EM:RegisterForEvent(CW.name, ev, onQuestEvent)
    end

    -- Events miss some assist paths: our click, the keybind, the journal's "set active".
    -- Hook ZO_Tracker: instance hooks rawset the method, dropping later add-on hooks.
    -- Filter out other tracker instances in the callback.
    local function onAssist(tracker)
        if tracker == FOCUSED_QUEST_TRACKER then onQuestEvent() end
    end
    SecurePostHook(ZO_Tracker, "ForceAssist", onAssist)
    SecurePostHook(ZO_Tracker, "AssistNext", onAssist)
    SecurePostHook("SetTrackedIsAssisted", onQuestEvent)

    -- The event keeps the combat flag current; only hide-in-combat needs a redraw.
    EM:RegisterForEvent(CW.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        CW.inCombat = inCombat
        if CW.SavedVars.stowInCombat then CW.SyncVisibility() end
    end)

end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= CW.name then return end
    EM:UnregisterForEvent(CW.name, EVENT_ADD_ON_LOADED)

    -- Last argument is the profile key: a PTS character cannot clobber a live one.
    CW.SavedVars = ZO_SavedVars:NewAccountWide("CommonWorksUI_SV", 1, nil, CW.defaults, GetWorldName())

    -- Build the panel before redraws and settings tables before features read them.
    CW.UI.Create()
    CW.CreateSettings()

    CW.UpdateOffBalanceTracking()
    CW.UpdateHealthAlertTracking()
    CW.UpdateIncomingAlertTracking()
    CW.UpdateCcImmunityTracking()
    CW.UpdateNegateAlertTracking()
    CW.UpdateBlastbonesTracking()
    CW.UpdateGcdAlertTracking()
    CW.UpdateChatAlerts()
    CW.UpdateMountStaminaTracking()
    CW.UpdateLaStatsTracking()
    CW.UpdateLaHitSoundTracking()
    CW.InstallTTCContextMenuPromotion()
    CW.InstallGuildStoreTraits()

    -- Wire host callbacks now; build controls when their screen first opens.
    -- The last three are retried from OnPlayerActivated.
    CW.InstallAGSPriceStepper()
    CW.InstallStoreIgnore()
    CW.InstallPurchaseLog()
    CW.InstallFunDLCButton()
    CW.UpdateWritBridge()
    CW.UpdateLoreBookPins()
    CW.UpdateLarvalTear()

    CW.WatchNativeTracker(); CW.SuppressNativeTracker(); CW.SuppressNativeExtras()

    EM:RegisterForEvent(CW.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    WatchScenes()
    SLASH_COMMANDS["/commonworks"] = OnSlashCommand
    CW.UI.SetPanelHidden(true)
end
EM:RegisterForEvent(CW.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
