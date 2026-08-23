local U = Ultivite
if not U then return end

U.Immersive = U.Immersive or {}
local I = U.Immersive
local Ownership = U.Ownership

local UPDATE_NAME = "UltiviteImmersiveRuntime"
local UPDATE_MS = 150
local GROUP_HIDE_REASON = "UltiviteImmersiveMode"
local TARGET_HIDE_REASON = "UltiviteImmersiveMode"
local GOLDEN_HIDE_REASON = "UltiviteImmersiveMode"
local OWNERSHIP_OWNER = "ImmersiveMode"
local VOTAN_RESOURCE = "VotanMinimapVisibility"
local OVERHEAD_RESOURCE = "EsoOverheadVisibility"

I.version = "1.0.160"
I.active = false
I.sv = nil
I.hiddenControls = I.hiddenControls or {}
I.votanWasShown = nil
I.votanTemporarilyHidden = false
I.alertHooksInstalled = false
I.chatHooksInstalled = false
I.lateHooksInstalled = false
I.lastAlertKey = nil
I.lastAlertMs = 0
I.cameraMode = false
I.cameraPrevious = nil
I.notificationTestRoot = nil

local DEFAULTS = {
    immersive = {
        hideActionBar = true,
        hidePlayerBars = true,
        hideTargetFrames = true,
        hideGroupFrames = true,
        hideEsoCompass = true,
        hideQuestTracker = true,
        hideGoldenPursuits = true,
        hideChat = true,
        hideCrosshair = false,
        hideChampionProgress = true,
        hideCombatInformation = true,
        hideCombatWarnings = true,
        hideNavigationHelpers = true,
        hideOverheadPlayerInfo = true,
        hideVotanMinimap = true,
        hideHarvestMap3dPins = true,
        hideInteractionPrompts = false,
        hideNotifications = false,
    },
    notifications = {
        blockFriendStatus = false,
        blockGuildRoster = false,
        blockGuildMotd = false,
        blockGroupJoinLeave = false,
        blockScreenshotSaved = false,
        blockTargetImmune = false,
        blockCraftingResults = false,
        blockLoreAndCollections = false,
        blockAbilityRank = false,
        duplicateAlertThrottle = 0,
    },
}

local BUILTIN_PROFILES = {
    screenshot = {
        name = "Camera / Screenshot",
        builtin = true,
        settings = {
            hideActionBar = true, hidePlayerBars = true, hideTargetFrames = true, hideGroupFrames = true,
            hideEsoCompass = true, hideQuestTracker = true, hideGoldenPursuits = true, hideChat = true,
            hideCrosshair = true, hideChampionProgress = true, hideCombatInformation = true,
            hideCombatWarnings = true, hideNavigationHelpers = true, hideOverheadPlayerInfo = true,
            hideVotanMinimap = true, hideHarvestMap3dPins = true,
            hideInteractionPrompts = true, hideNotifications = true,
        },
    },
    exploration = {
        name = "Exploration",
        builtin = true,
        settings = {
            hideActionBar = true, hidePlayerBars = true, hideTargetFrames = true, hideGroupFrames = true,
            hideEsoCompass = false, hideQuestTracker = true, hideGoldenPursuits = true, hideChat = true,
            hideCrosshair = false, hideChampionProgress = true, hideCombatInformation = true,
            hideCombatWarnings = true, hideNavigationHelpers = false, hideOverheadPlayerInfo = true,
            hideVotanMinimap = false, hideHarvestMap3dPins = true,
            hideInteractionPrompts = false, hideNotifications = false,
        },
    },
    minimalCombat = {
        name = "Minimal Combat",
        builtin = true,
        settings = {
            hideActionBar = false, hidePlayerBars = false, hideTargetFrames = false, hideGroupFrames = false,
            hideEsoCompass = true, hideQuestTracker = true, hideGoldenPursuits = true, hideChat = true,
            hideCrosshair = false, hideChampionProgress = true, hideCombatInformation = false,
            hideCombatWarnings = false, hideNavigationHelpers = true, hideOverheadPlayerInfo = true,
            hideVotanMinimap = true, hideHarvestMap3dPins = true,
            hideInteractionPrompts = false, hideNotifications = false,
        },
    },
}

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = deepCopy(child) end
    return copy
end

local function fillDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then return end
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = deepCopy(value)
        elseif type(target[key]) == "table" and type(value) == "table" then
            fillDefaults(target[key], value)
        end
    end
end

local function requestSave()
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
end

local function getFrames()
    return U.Frames
end

local function getCombat()
    return U.Combat
end

local function getAlerts()
    return U.EnemyUltimateAlerts
end

local function getConfig()
    -- Camera mode always uses the full factory hide set. The editable profile is
    -- kept separate.
    if I.cameraMode then return BUILTIN_PROFILES.screenshot.settings end
    local state = I.sv and I.sv.immersiveProfiles
    local profile = state and state.profiles and state.profiles[state.selectedId or ""]
    return profile and profile.settings or (I.sv and I.sv.immersive or DEFAULTS.immersive)
end

local function getNotifications()
    return I.sv and I.sv.notifications or DEFAULTS.notifications
end

local function safeHidden(control)
    if not control or not control.IsHidden then return nil end
    local ok, value = pcall(function() return control:IsHidden() end)
    if ok then return value and true or false end
    return nil
end

local function hideControl(control)
    if not control or not control.SetHidden then return end
    if Ownership and Ownership.AcquireControl then
        Ownership.AcquireControl(OWNERSHIP_OWNER, control)
        return
    end
    if I.hiddenControls[control] == nil then
        local previous = safeHidden(control)
        if previous ~= nil then I.hiddenControls[control] = previous end
    end
    pcall(function() control:SetHidden(true) end)
end

local function restoreControl(control)
    if not control then return false end
    if Ownership and Ownership.ReleaseControl then
        return Ownership.ReleaseControl(OWNERSHIP_OWNER, control)
    end
    local wasHidden = I.hiddenControls[control]
    if wasHidden == nil then return false end
    if control.SetHidden then
        pcall(function() control:SetHidden(wasHidden == true) end)
    end
    I.hiddenControls[control] = nil
    return true
end

local function restoreDirectControls()
    if Ownership and Ownership.ReleaseOwner then
        Ownership.ReleaseOwner(OWNERSHIP_OWNER)
        I.hiddenControls = {}
        I.chatControl = nil
        return
    end
    for control, wasHidden in pairs(I.hiddenControls) do
        if control and control.SetHidden then
            pcall(function() control:SetHidden(wasHidden == true) end)
        end
    end
    I.hiddenControls = {}
    I.chatControl = nil
end

local function isChatTextEntryOpen()
    local entry = U.GetChatTextEntry and U.GetChatTextEntry() or nil
    if entry and type(entry.IsOpen) == "function" then
        local ok, open = pcall(entry.IsOpen, entry)
        if ok then return open == true end
    end
    local frames = getFrames()
    if frames and type(frames.IsChatTextEntryOpen) == "function" then
        local ok, open = pcall(frames.IsChatTextEntryOpen)
        if ok then return open == true end
    end
    return false
end

function I.RefreshChatVisibility()
    local frames = getFrames()
    local control = frames and frames.GetChatControl and frames.GetChatControl() or nil
    if I.chatControl and I.chatControl ~= control then restoreControl(I.chatControl) end
    I.chatControl = control
    if not control then return false end

    local cfg = getConfig()
    if not I.active or not cfg.hideChat or isChatTextEntryOpen() then
        restoreControl(control)
        return false
    end

    hideControl(control)
    return true
end

local function getVotan()
    -- Never enumerate _G. API 101050 includes private secure functions in the
    -- global table, and merely iterating those entries can taint insecure code.
    local addon = rawget(_G, "VOTANS_MINIMAP")
    if type(addon) == "table" and type(addon.ToggleShowMap) == "function" and type(addon.player) == "table" then
        return addon
    end
    return nil
end

local function getVotanShown(addon)
    if not addon or not addon.player then return nil end
    if addon.player.showMap == nil then return nil end
    return addon.player.showMap == true
end

function I.HideVotanTemporarily()
    if Ownership and Ownership.AcquireResource then
        return Ownership.AcquireResource(OWNERSHIP_OWNER, VOTAN_RESOURCE,
            function()
                return getVotanShown(getVotan())
            end,
            function()
                local addon = getVotan()
                if addon and getVotanShown(addon) == true then addon:ToggleShowMap() end
            end,
            function(wasShown)
                local addon = getVotan()
                local shown = getVotanShown(addon)
                if addon and wasShown ~= nil and shown ~= wasShown then addon:ToggleShowMap() end
            end)
    end
    if I.votanTemporarilyHidden then return end
    local addon = getVotan()
    if not addon then return end
    local shown = getVotanShown(addon)
    if shown == nil then return end
    I.votanWasShown = shown
    if shown then
        local ok = pcall(function() addon:ToggleShowMap() end)
        if ok then I.votanTemporarilyHidden = true end
    end
end

function I.RestoreVotanTemporaryState()
    if Ownership and Ownership.ReleaseResource then
        Ownership.ReleaseResource(OWNERSHIP_OWNER, VOTAN_RESOURCE)
        return
    end
    if I.votanWasShown == nil then
        I.votanTemporarilyHidden = false
        return
    end
    local addon = getVotan()
    if addon then
        local shown = getVotanShown(addon)
        if I.votanWasShown == true and shown == false then
            pcall(function() addon:ToggleShowMap() end)
        elseif I.votanWasShown == false and shown == true then
            pcall(function() addon:ToggleShowMap() end)
        end
    end
    I.votanWasShown = nil
    I.votanTemporarilyHidden = false
end

local function hideGroupFrames()
    if UNIT_FRAMES and UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason then
        pcall(function() UNIT_FRAMES:SetGroupAndRaidFramesHiddenForReason(GROUP_HIDE_REASON, true) end)
        return
    end
    local frames = getFrames()
    if frames and frames.GetGroupFrameControl then hideControl(frames.GetGroupFrameControl()) end
end

local function releaseGroupFrames()
    if UNIT_FRAMES and UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason then
        pcall(function() UNIT_FRAMES:SetGroupAndRaidFramesHiddenForReason(GROUP_HIDE_REASON, false) end)
    end
end

local function hideTargetFrames()
    if UNIT_FRAMES and UNIT_FRAMES.SetFrameHiddenForReason then
        pcall(function() UNIT_FRAMES:SetFrameHiddenForReason("reticleover", TARGET_HIDE_REASON, true) end)
    end
    hideControl(_G.ZO_TargetUnitFramereticleover)

    local combat = getCombat()
    if combat then
        hideControl(combat.root)
    end

    local frames = getFrames()
    if frames and frames.dsEnemyHealthControl then
        hideControl(frames.dsEnemyHealthControl.frame)
    end
end

local function releaseTargetFrames()
    if UNIT_FRAMES and UNIT_FRAMES.SetFrameHiddenForReason then
        pcall(function() UNIT_FRAMES:SetFrameHiddenForReason("reticleover", TARGET_HIDE_REASON, false) end)
    end
end

local function hidePlayerBars()
    local frames = getFrames()
    if frames then
        if frames.GetFrame then hideControl(frames.GetFrame()) end
        if frames.GetWerewolfResourceBarControl then hideControl(frames.GetWerewolfResourceBarControl()) end
        if frames.GetMountStaminaBarControl then hideControl(frames.GetMountStaminaBarControl()) end
        if frames.dsSelfHealthControl then hideControl(frames.dsSelfHealthControl.frame) end
        if frames.dsSelfMagickaControl then hideControl(frames.dsSelfMagickaControl.frame) end
        if frames.dsSelfStaminaControl then hideControl(frames.dsSelfStaminaControl.frame) end
        if frames.dsUltimateControl then hideControl(frames.dsUltimateControl.frame) end
    end
    hideControl(_G.ZO_PlayerAttributeHealth)
    hideControl(_G.ZO_PlayerAttributeMagicka)
    hideControl(_G.ZO_PlayerAttributeStamina)
    hideControl(_G.ZO_PlayerAttribute)
end

local function hideCombatInformation()
    local combat = getCombat()
    if not combat then return end
    hideControl(combat.timerRoot)
    hideControl(combat.wretchedVitalityRoot)
    hideControl(combat.ccImmunityRoot)
    hideControl(combat.playerDebuffRoot)
    hideControl(combat.pvpHudRoot)
    hideControl(combat.genericStackRoot)
    hideControl(combat.streakFatigueRoot)
    hideControl(combat.targetDebuffRoot)
    if combat.liveStatWidgets then
        for _, widget in pairs(combat.liveStatWidgets) do
            hideControl(widget and widget.root)
        end
    end
end

local function hideCombatWarnings()
    local combat = getCombat()
    if combat then
        hideControl(combat.majorBreachRoot)
        hideControl(combat.foodWarningRoot)
        hideControl(combat.majorResolveWarningRoot)
        hideControl(combat.combatDangerRoot)
        hideControl(combat.resourceDangerRoot)
        hideControl(combat.killMessageRoot)
    end
    local alerts = getAlerts()
    if alerts then
        hideControl(alerts.globalRoot)
        hideControl(alerts.targetRoot)
    end
end

local function hideNavigationHelpers()
    local frames = getFrames()
    if not frames then return end
    hideControl(frames.crownDirectionArrowControl or _G.UltiviteCrownDirectionArrow)
    hideControl(frames.feetCompassControl or _G.UltiviteFeetCompass)
end

local function hideOverheadInfo()
    local combat = getCombat()
    if not combat then return end
    hideControl(combat.overheadPlayerInfoReticleLabel)
    if combat.overheadPlayerInfoGroupLabels then
        for _, label in pairs(combat.overheadPlayerInfoGroupLabels) do hideControl(label) end
    end
end

local NAMEPLATE_CHOICE_SETTINGS = {
    NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS,
    NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS_HIGHLIGHT,
    NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES,
    NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES_HIGHLIGHT,
    NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS,
    NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS_HIGHLIGHT,
    NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES,
    NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES_HIGHLIGHT,
    NAMEPLATE_TYPE_FRIENDLY_NPC_HEALTHBARS,
    NAMEPLATE_TYPE_FRIENDLY_NPC_HEALTHBARS_HIGHLIGHT,
    NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES,
    NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES_HIGHLIGHT,
    NAMEPLATE_TYPE_FRIENDLY_PLAYER_HEALTHBARS,
    NAMEPLATE_TYPE_FRIENDLY_PLAYER_HEALTHBARS_HIGHLIGHT,
    NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES,
    NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES_HIGHLIGHT,
    NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS,
    NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS_HIGHLIGHT,
    NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES,
    NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES_HIGHLIGHT,
    NAMEPLATE_TYPE_NEUTRAL_NPC_HEALTHBARS,
    NAMEPLATE_TYPE_NEUTRAL_NPC_HEALTHBARS_HIGHLIGHT,
    NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES,
    NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES_HIGHLIGHT,
    NAMEPLATE_TYPE_PLAYER_HEALTHBAR,
    NAMEPLATE_TYPE_PLAYER_HEALTHBAR_HIGHLIGHT,
    NAMEPLATE_TYPE_PLAYER_NAMEPLATE,
    NAMEPLATE_TYPE_PLAYER_NAMEPLATE_HIGHLIGHT,
}

local NAMEPLATE_TOGGLE_SETTINGS = {
    NAMEPLATE_TYPE_ALL_HEALTHBARS,
    NAMEPLATE_TYPE_ALL_NAMEPLATES,
    NAMEPLATE_TYPE_ALLIANCE_INDICATORS,
    NAMEPLATE_TYPE_FOLLOWER_INDICATORS,
    NAMEPLATE_TYPE_GROUP_INDICATORS,
    NAMEPLATE_TYPE_RESURRECT_INDICATORS,
    NAMEPLATE_TYPE_SHOW_PLAYER_GUILDS,
    NAMEPLATE_TYPE_SHOW_PLAYER_TITLES,
    NAMEPLATE_TYPE_TARGET_MARKERS,
}

local function readSetting(settingType, settingId)
    local ok, value = pcall(GetSetting, settingType, settingId)
    if not ok or value == nil then return nil end
    return tostring(value)
end

local function writeTemporarySetting(settingType, settingId, value)
    if value == nil then return end
    value = tostring(value)
    if readSetting(settingType, settingId) == value then return end
    pcall(SetSetting, settingType, settingId, value, SETTINGS_SET_OPTION_DO_NOT_SAVE_TO_PERSISTED_DATA)
end

local function captureOverheadVisibility()
    local snapshot = { nameplates = {} }
    for _, settingId in ipairs(NAMEPLATE_CHOICE_SETTINGS) do
        snapshot.nameplates[settingId] = readSetting(SETTING_TYPE_NAMEPLATES, settingId)
    end
    for _, settingId in ipairs(NAMEPLATE_TOGGLE_SETTINGS) do
        snapshot.nameplates[settingId] = readSetting(SETTING_TYPE_NAMEPLATES, settingId)
    end
    snapshot.chatBubbles = readSetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED)
    return snapshot
end

local function hideNativeOverheadVisibility()
    local never = tostring(NAMEPLATE_CHOICE_NEVER)
    for _, settingId in ipairs(NAMEPLATE_CHOICE_SETTINGS) do
        writeTemporarySetting(SETTING_TYPE_NAMEPLATES, settingId, never)
    end
    for _, settingId in ipairs(NAMEPLATE_TOGGLE_SETTINGS) do
        writeTemporarySetting(SETTING_TYPE_NAMEPLATES, settingId, "0")
    end
    writeTemporarySetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED, "0")
end

local function restoreOverheadVisibility(snapshot)
    if type(snapshot) ~= "table" then return end
    local nameplates = snapshot.nameplates or {}
    for _, settingId in ipairs(NAMEPLATE_CHOICE_SETTINGS) do
        writeTemporarySetting(SETTING_TYPE_NAMEPLATES, settingId, nameplates[settingId])
    end
    for _, settingId in ipairs(NAMEPLATE_TOGGLE_SETTINGS) do
        writeTemporarySetting(SETTING_TYPE_NAMEPLATES, settingId, nameplates[settingId])
    end
    writeTemporarySetting(SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED, snapshot.chatBubbles)
end

function I.HideNativeOverheadTemporarily()
    if not Ownership or not Ownership.AcquireResource then return false end
    return Ownership.AcquireResource(
        OWNERSHIP_OWNER,
        OVERHEAD_RESOURCE,
        captureOverheadVisibility,
        hideNativeOverheadVisibility,
        restoreOverheadVisibility)
end

function I.RestoreNativeOverheadTemporaryState()
    if Ownership and Ownership.ReleaseResource then
        Ownership.ReleaseResource(OWNERSHIP_OWNER, OVERHEAD_RESOURCE)
    end
end

local function hideGoldenPursuits()
    if PROMOTIONAL_EVENT_TRACKER and PROMOTIONAL_EVENT_TRACKER.GetFragment then
        local ok, fragment = pcall(function() return PROMOTIONAL_EVENT_TRACKER:GetFragment() end)
        if ok and fragment and fragment.SetHiddenForReason then
            pcall(function() fragment:SetHiddenForReason(GOLDEN_HIDE_REASON, true) end)
            return
        end
    end
    hideControl(_G.ZO_PromotionalEventTracker_Keyboard)
end

local function hideNotifications()
    hideControl(_G.ZO_AlertTextNotification)
    hideControl(_G.ZO_CenterScreenAnnounce)
    hideControl(_G.ZO_ActiveCombatTipsTip)
    hideControl(_G.ZO_SynergyTopLevel)
end

local function hideCameraOnlyHud()
    -- Camera mode is intentionally broader than the editable Immersive profile.
    -- These public top-level controls can otherwise appear briefly in a shot
    -- after the normal HUD categories have already been suppressed.
    local names = {
        "ZO_PlayerToPlayer", "ZO_BossBar", "ZO_BossUnitFrame", "ZO_Subtitles",
        "ZO_QuestTimer", "ZO_ZoneStoryTracker", "ZO_SiegeBar", "ZO_RamTopLevel",
        "ZO_Notifications", "ZO_TutorialHudInfoTipKeyboard", "ZO_GamepadTooltipTopLevel",
        "ZO_ActivityTracker", "ZO_ActivityTrackerPanel", "ZO_ActivityFinderStatus",
        "ZO_BattlegroundFinderStatus", "ZO_PromotionalEventTracker_TL",
        "ZO_PlayerBuffs", "ZO_PlayerDebuffs", "ZO_TargetBuffs", "ZO_TargetDebuffs",
        "ZO_ObjectiveCaptureMeter", "ZO_CaptureMeter", "ZO_KeepCaptureBonus",
    }
    for _, name in ipairs(names) do hideControl(_G[name]) end
end

local function releaseGoldenPursuits()
    if PROMOTIONAL_EVENT_TRACKER and PROMOTIONAL_EVENT_TRACKER.GetFragment then
        local ok, fragment = pcall(function() return PROMOTIONAL_EVENT_TRACKER:GetFragment() end)
        if ok and fragment and fragment.SetHiddenForReason then
            pcall(function() fragment:SetHiddenForReason(GOLDEN_HIDE_REASON, false) end)
        end
    end
end

function I.Enforce()
    if not I.active then return end
    local cfg = getConfig()
    local frames = getFrames()

    if cfg.hideActionBar then hideControl(_G.ZO_ActionBar1) end
    if cfg.hidePlayerBars then hidePlayerBars() end
    if cfg.hideTargetFrames then hideTargetFrames() end
    if cfg.hideGroupFrames then hideGroupFrames() end
    if cfg.hideEsoCompass then hideControl(_G.ZO_CompassFrame) end
    if cfg.hideQuestTracker then hideControl(_G.ZO_FocusedQuestTrackerPanel) end
    if cfg.hideGoldenPursuits then hideGoldenPursuits() end
    I.RefreshChatVisibility()
    if cfg.hideCrosshair then hideControl(_G.ZO_ReticleContainerReticle) end
    if cfg.hideInteractionPrompts then hideControl(_G.ZO_ReticleContainer) end
    if cfg.hideChampionProgress and PLAYER_PROGRESS_BAR then hideControl(PLAYER_PROGRESS_BAR.control) end
    if cfg.hideCombatInformation then hideCombatInformation() end
    if cfg.hideCombatWarnings then hideCombatWarnings() end
    if cfg.hideNavigationHelpers then hideNavigationHelpers() end
    if cfg.hideOverheadPlayerInfo then
        hideOverheadInfo()
        I.HideNativeOverheadTemporarily()
    end
    if cfg.hideVotanMinimap then I.HideVotanTemporarily() end
    if cfg.hideHarvestMap3dPins then hideControl(_G.HM_WorldPins) end
    if cfg.hideNotifications then hideNotifications() end
    if I.cameraMode then hideCameraOnlyHud() end
end

local function refreshOwnedUi()
    local frames = getFrames()
    local combat = getCombat()
    local alerts = getAlerts()

    if frames then
        if frames.ApplyGroupFrameState then frames.ApplyGroupFrameState() end
        if frames.ApplyChampionProgressVisibility then frames.ApplyChampionProgressVisibility(true) end
        if frames.ApplyChatVisibilityMode then frames.ApplyChatVisibilityMode() end
        if frames.RefreshUiVisibilityRules then frames.RefreshUiVisibilityRules(true) end
        if frames.RefreshNavigationHelpers then frames.RefreshNavigationHelpers(true) end
        if frames.RefreshDSSelfHealthRuntime then frames.RefreshDSSelfHealthRuntime() end
        if frames.RefreshDSEnemyHealthRuntime then frames.RefreshDSEnemyHealthRuntime() end
        if frames.ApplyGoldenPursuitsVisibility then frames.ApplyGoldenPursuitsVisibility() end
    end

    if combat then
        if combat.RefreshDisplay then combat.RefreshDisplay() end
        if combat.UpdateLiveStatWidgets then combat.UpdateLiveStatWidgets(true) end
        if combat.ScanPlayerAuraHud then combat.ScanPlayerAuraHud() end
        if combat.UpdateImportantTargetDebuffs then combat.UpdateImportantTargetDebuffs(true) end
        if combat.UpdateCombatDangerWarnings then combat.UpdateCombatDangerWarnings(true) end
        if combat.UpdateFoodWarning then combat.UpdateFoodWarning() end
        if combat.UpdateMajorResolveWarning then combat.UpdateMajorResolveWarning() end
        if combat.UpdateMajorBreachDisplay then combat.UpdateMajorBreachDisplay() end
        if combat.UpdatePvpHud then combat.UpdatePvpHud(false) end
        if combat.UpdateOverheadPlayerInfo then combat.UpdateOverheadPlayerInfo() end
    end

    if alerts and alerts.Update then alerts.Update(true) end
end

function I.Reapply()
    if not I.active then return end
    releaseGroupFrames()
    releaseTargetFrames()
    releaseGoldenPursuits()
    I.RestoreVotanTemporaryState()
    restoreDirectControls()
    refreshOwnedUi()
    I.Enforce()
end

function I.IsActive()
    return I.active == true
end

function I.SetActive(enabled, silent)
    enabled = enabled == true
    if I.active == enabled then
        if enabled then I.Enforce() end
        return true
    end

    I.active = enabled
    if enabled then
        I.hiddenControls = {}
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, UPDATE_MS, I.Enforce)
        I.Enforce()
    else
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
        releaseGroupFrames()
        releaseTargetFrames()
        releaseGoldenPursuits()
        I.RestoreVotanTemporaryState()
        restoreDirectControls()
        refreshOwnedUi()
    end

    if not silent and d then
        d(enabled and "[Ultivite] Immersive Mode enabled." or "[Ultivite] Immersive Mode disabled.")
    end
    return true
end

function I.Toggle(silent)
    if I.IsCameraMode() then return I.SetCameraMode(false, silent) end
    return I.SetActive(not I.IsActive(), silent)
end

local function messageText(message, ...)
    if message == nil then return "" end
    if type(message) == "string" then
        if select("#", ...) > 0 and zo_strformat then
            local ok, formatted = pcall(zo_strformat, message, ...)
            if ok and formatted and formatted ~= "" then return tostring(formatted) end
        end
        return message
    end
    if GetString then
        local ok, value = pcall(GetString, message)
        if ok and value and value ~= "" then
            if select("#", ...) > 0 and zo_strformat then
                local ok2, formatted = pcall(zo_strformat, value, ...)
                if ok2 and formatted then return tostring(formatted) end
            end
            return tostring(value)
        end
    end
    return tostring(message)
end

local function normalize(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    return string.lower(text)
end

local TARGET_IMMUNE_PHRASES = {
    "target is immune",
    "immune to snares",
    "immune to bleeding",
    "too powerful for that effect",
    "valid empty soul gem",
}

local CRAFT_RESULT_PHRASES = {
    "improvement attempt succeeded",
    "improvement attempt failed",
    "no usable items found",
    "lack the skill to recover",
}

local function containsAny(text, phrases)
    for _, phrase in ipairs(phrases) do
        if string.find(text, phrase, 1, true) then return true end
    end
    return false
end

local function shouldSuppressAlert(category, soundId, message, ...)
    local sv = getNotifications()
    local text = normalize(messageText(message, ...))

    if sv.blockTargetImmune and containsAny(text, TARGET_IMMUNE_PHRASES) then return true end
    if sv.blockCraftingResults and containsAny(text, CRAFT_RESULT_PHRASES) then return true end

    local throttle = tonumber(sv.duplicateAlertThrottle) or 0
    if throttle > 0 and text ~= "" then
        local now = GetFrameTimeMilliseconds and GetFrameTimeMilliseconds() or 0
        local key = tostring(category) .. ":" .. text
        if key == I.lastAlertKey and (now - (I.lastAlertMs or 0)) < throttle * 1000 then
            return true
        end
        I.lastAlertKey = key
        I.lastAlertMs = now
    end
    return false
end

local function hookTableEvent(tableValue, eventCode, predicate)
    if not tableValue or not eventCode or type(predicate) ~= "function" then return false end
    if type(tableValue[eventCode]) ~= "function" or not ZO_PreHook then return false end
    ZO_PreHook(tableValue, eventCode, predicate)
    return true
end

function I.InstallAlertHooks()
    if I.alertHooksInstalled then return end
    I.alertHooksInstalled = true

    if ZO_PreHook and ZO_Alert then
        ZO_PreHook("ZO_Alert", function(category, soundId, message, ...)
            return shouldSuppressAlert(category, soundId, message, ...)
        end)
    end

    if not ZO_AlertText_GetHandlers then return end
    local handlers = ZO_AlertText_GetHandlers()
    hookTableEvent(handlers, EVENT_SCREENSHOT_SAVED, function()
        return getNotifications().blockScreenshotSaved == true
    end)
    hookTableEvent(handlers, EVENT_LORE_BOOK_LEARNED, function()
        return getNotifications().blockLoreAndCollections == true
    end)
    hookTableEvent(handlers, EVENT_LORE_COLLECTION_COMPLETED, function()
        return getNotifications().blockLoreAndCollections == true
    end)
    hookTableEvent(handlers, EVENT_SKILL_RANK_UPDATE, function()
        return getNotifications().blockAbilityRank == true
    end)
    hookTableEvent(handlers, EVENT_CRAFT_COMPLETED, function()
        return getNotifications().blockCraftingResults == true
    end)
end

local function installChatHookForTable(handlers)
    hookTableEvent(handlers, EVENT_FRIEND_PLAYER_STATUS_CHANGED, function()
        return getNotifications().blockFriendStatus == true
    end)
    hookTableEvent(handlers, EVENT_GUILD_MEMBER_ADDED, function()
        return getNotifications().blockGuildRoster == true
    end)
    hookTableEvent(handlers, EVENT_GUILD_MEMBER_REMOVED, function()
        return getNotifications().blockGuildRoster == true
    end)
    hookTableEvent(handlers, EVENT_GUILD_MOTD_CHANGED, function()
        return getNotifications().blockGuildMotd == true
    end)
    hookTableEvent(handlers, EVENT_GROUP_MEMBER_JOINED, function()
        return getNotifications().blockGroupJoinLeave == true
    end)
    hookTableEvent(handlers, EVENT_GROUP_MEMBER_LEFT, function()
        return getNotifications().blockGroupJoinLeave == true
    end)
end

function I.InstallChatHooks()
    if I.chatHooksInstalled then return end
    if not ZO_ChatSystem_GetEventHandlers then return end
    I.chatHooksInstalled = true

    installChatHookForTable(ZO_ChatSystem_GetEventHandlers())
    if CHAT_ROUTER and type(CHAT_ROUTER.registeredEventHandlers) == "table" then
        installChatHookForTable(CHAT_ROUTER.registeredEventHandlers)
    end
end

function I.ReinstallLateHooks()
    if I.lateHooksInstalled then return end
    I.lateHooksInstalled = true
    -- Some chat addons replace event handlers during login. Install once more
    -- after the first PLAYER_ACTIVATED so the final public handler table is
    -- covered without repeatedly wrapping handlers on every zone transition.
    I.chatHooksInstalled = false
    I.InstallChatHooks()
end

local function ensureImmersiveProfiles()
    if not I.sv then return nil end
    local state = I.sv.immersiveProfiles
    if type(state) ~= "table" then
        state = { profiles = {}, order = {}, selectedId = "custom", nextId = 0, pendingName = "" }
        I.sv.immersiveProfiles = state
    end
    state.profiles = type(state.profiles) == "table" and state.profiles or {}
    state.order = type(state.order) == "table" and state.order or {}

    if not state.profiles.custom then
        state.profiles.custom = { name = "Custom", settings = deepCopy(I.sv.immersive or DEFAULTS.immersive) }
    end
    fillDefaults(state.profiles.custom.settings, DEFAULTS.immersive)

    for id, factory in pairs(BUILTIN_PROFILES) do
        local profile = state.profiles[id]
        if type(profile) ~= "table" then
            profile = deepCopy(factory)
            state.profiles[id] = profile
        end
        profile.name = factory.name
        profile.builtin = true
        profile.settings = type(profile.settings) == "table" and profile.settings or {}
        fillDefaults(profile.settings, factory.settings)
    end

    for id, profile in pairs(state.profiles) do
        if not BUILTIN_PROFILES[id] and type(profile) == "table" then
            profile.settings = type(profile.settings) == "table" and profile.settings or {}
            fillDefaults(profile.settings, DEFAULTS.immersive)
        end
    end

    local wanted = { "custom", "screenshot", "exploration", "minimalCombat" }
    local seen = {}
    local order = {}
    local function add(id)
        if state.profiles[id] and not seen[id] then seen[id] = true; order[#order + 1] = id end
    end
    for _, id in ipairs(wanted) do add(id) end
    for _, id in ipairs(state.order) do add(id) end
    for id in pairs(state.profiles) do add(id) end
    state.order = order
    if not state.profiles[state.selectedId or ""] then state.selectedId = "custom" end
    return state
end

function I.GetSelectedProfileId()
    local state = ensureImmersiveProfiles()
    return state and state.selectedId or "custom"
end

function I.GetSelectedProfileName()
    local state = ensureImmersiveProfiles()
    local profile = state and state.profiles[state.selectedId]
    return profile and tostring(profile.name or state.selectedId) or "Custom"
end

function I.SelectProfile(profileId, silent)
    local state = ensureImmersiveProfiles()
    if not state or not state.profiles[profileId or ""] then return false end
    state.selectedId = profileId
    requestSave()
    if I.active then I.Reapply() end
    if not silent and d then d("[Ultivite] Immersive profile selected: " .. I.GetSelectedProfileName() .. ".") end
    return true
end

function I.CreateProfileFromCurrent()
    local state = ensureImmersiveProfiles()
    if not state then return false end
    state.nextId = (tonumber(state.nextId) or 0) + 1
    local id = "custom_" .. tostring(state.nextId)
    while state.profiles[id] do state.nextId = state.nextId + 1; id = "custom_" .. tostring(state.nextId) end
    local name = tostring(state.pendingName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Immersive Profile " .. tostring(state.nextId) end
    state.profiles[id] = { name = name, settings = deepCopy(getConfig()) }
    state.order[#state.order + 1] = id
    state.selectedId = id
    state.pendingName = ""
    requestSave()
    return true
end

function I.RenameSelectedProfile()
    local state = ensureImmersiveProfiles()
    local profile = state and state.profiles[state.selectedId]
    if not profile or profile.builtin then return false end
    local name = tostring(state.pendingName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return false end
    profile.name = name
    state.pendingName = ""
    requestSave()
    return true
end

function I.DeleteSelectedProfile()
    local state = ensureImmersiveProfiles()
    local id = state and state.selectedId
    local profile = id and state.profiles[id]
    if not profile or profile.builtin or id == "custom" then return false end
    if I.active then I.SetActive(false, true) end
    state.profiles[id] = nil
    for index, value in ipairs(state.order) do if value == id then table.remove(state.order, index); break end end
    state.selectedId = "custom"
    requestSave()
    return true
end

function I.RestoreSelectedBuiltin()
    local state = ensureImmersiveProfiles()
    local id = state and state.selectedId
    local factory = id and BUILTIN_PROFILES[id]
    if not factory then return false end
    state.profiles[id].settings = deepCopy(factory.settings)
    requestSave()
    if I.active then I.Reapply() end
    return true
end

function I.CaptureSnapshot()
    return { selectedId = I.GetSelectedProfileId(), name = I.GetSelectedProfileName(), settings = deepCopy(getConfig()) }
end

function I.ApplySnapshot(snapshot, silent)
    if type(snapshot) ~= "table" or type(snapshot.settings) ~= "table" then return false end
    local state = ensureImmersiveProfiles()
    local id = state.profiles[snapshot.selectedId or ""] and snapshot.selectedId or "unified"
    if id == "unified" then
        state.profiles[id] = { name = tostring(snapshot.name or "Unified Profile Immersive"), settings = deepCopy(snapshot.settings) }
        local found = false
        for _, value in ipairs(state.order) do if value == id then found = true; break end end
        if not found then state.order[#state.order + 1] = id end
    else
        state.profiles[id].settings = deepCopy(snapshot.settings)
    end
    state.selectedId = id
    fillDefaults(state.profiles[id].settings, DEFAULTS.immersive)
    requestSave()
    if I.active then I.Reapply() end
    if not silent and d then d("[Ultivite] Immersive profile snapshot applied.") end
    return true
end

function I.IsCameraMode()
    return I.cameraMode == true
end

function I.SetCameraMode(enabled, silent)
    enabled = enabled == true
    if I.cameraMode == enabled then return true end
    local state = ensureImmersiveProfiles()
    if not state then return false end

    if enabled then
        -- A Notification Cleaner preview is deliberately transient and should
        -- never be restored after Camera Mode. Cancel it before ownership takes
        -- the HUD snapshot so it cannot leak into a screenshot or reappear when
        -- Camera Mode is released.
        EVENT_MANAGER:UnregisterForUpdate("UltiviteNotificationCleanerTestHide")
        if I.notificationTestRoot then I.notificationTestRoot:SetHidden(true) end
        I.cameraPrevious = { active = I.active == true, selectedId = state.selectedId }
        I.cameraMode = true
        -- Camera Mode uses the immutable factory screenshot settings through
        -- getConfig(). Do not select or save the similarly named editable
        -- profile: this toggle is temporary and must not change the profile the
        -- player returns to after logout, reload or a normal toggle-off.
        I.SetActive(true, true)
    else
        local previous = I.cameraPrevious or { active = false, selectedId = "custom" }
        I.SetActive(false, true)
        I.cameraMode = false
        I.cameraPrevious = nil
        if state.profiles[previous.selectedId or ""] then state.selectedId = previous.selectedId end
        if previous.active then I.SetActive(true, true) end
    end
    requestSave()
    if not silent and d then d(enabled and "[Ultivite] Camera / Screenshot Mode enabled." or "[Ultivite] Camera / Screenshot Mode disabled.") end
    return true
end

function I.ToggleCameraMode(silent)
    return I.SetCameraMode(not I.IsCameraMode(), silent)
end

local function createNotificationTestRoot()
    if I.notificationTestRoot or not WINDOW_MANAGER or not GuiRoot then return end
    local root = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteNotificationCleanerTest")
    root:SetDimensions(660, 54)
    root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -40, 90)
    root:SetDrawTier(DT_HIGH)
    root:SetDrawLayer(DL_OVERLAY)
    root:SetDrawLevel(4950)
    root:SetClampedToScreen(true)
    root:SetHidden(true)
    local backdrop = WINDOW_MANAGER:CreateControl("UltiviteNotificationCleanerTestBackdrop", root, CT_BACKDROP)
    backdrop:SetAnchorFill(root)
    backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.94)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
    backdrop:SetEdgeColor(0.30, 0.75, 0.95, 1)
    local label = WINDOW_MANAGER:CreateControl("UltiviteNotificationCleanerTestLabel", root, CT_LABEL)
    label:SetAnchorFill(root)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetFont("$(BOLD_FONT)|22|soft-shadow-thick")
    root.label = label
    I.notificationTestRoot = root
end

function I.TestNotification(key, label)
    createNotificationTestRoot()
    if not I.notificationTestRoot then return false end
    local blocked = getNotifications()[key] == true
    I.notificationTestRoot.label:SetColor(blocked and 0.35 or 1.0, blocked and 1.0 or 0.78, blocked and 0.45 or 0.20, 1)
    I.notificationTestRoot.label:SetText((blocked and "BLOCKED PREVIEW: " or "VISIBLE PREVIEW: ") .. tostring(label))
    I.notificationTestRoot:SetHidden(false)
    EVENT_MANAGER:UnregisterForUpdate("UltiviteNotificationCleanerTestHide")
    EVENT_MANAGER:RegisterForUpdate("UltiviteNotificationCleanerTestHide", 3000, function()
        EVENT_MANAGER:UnregisterForUpdate("UltiviteNotificationCleanerTestHide")
        if I.notificationTestRoot then I.notificationTestRoot:SetHidden(true) end
    end)
    return true
end

function I.Initialize(accountSV)
    if not accountSV then return end
    accountSV.immersiveAndConvenience = accountSV.immersiveAndConvenience or {}
    fillDefaults(accountSV.immersiveAndConvenience, DEFAULTS)
    I.sv = accountSV.immersiveAndConvenience
    ensureImmersiveProfiles()
    I.active = false

    I.InstallAlertHooks()
    I.InstallChatHooks()

    EVENT_MANAGER:RegisterForEvent("UltiviteImmersiveDeactivate", EVENT_PLAYER_DEACTIVATED, function()
        if I.active then
            I.RestoreVotanTemporaryState()
            I.RestoreNativeOverheadTemporaryState()
        end
    end)
    EVENT_MANAGER:RegisterForEvent("UltiviteImmersiveActivate", EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(function()
            I.ReinstallLateHooks()
            if I.active then I.Reapply() end
        end, 700)
    end)
end

local function checkbox(name, tooltip, parent, key)
    return {
        type = "checkbox",
        name = name,
        tooltip = tooltip,
        getFunc = function() return parent()[key] == true end,
        setFunc = function(value)
            parent()[key] = value == true
            requestSave()
            if I.active then I.Reapply() end
        end,
        default = false,
        width = "full",
    }
end

function I.GetMenuOptions()
    local cfg = function() return getConfig() end
    local notes = function() return getNotifications() end
    local immersiveDefaults = DEFAULTS.immersive

    local hideControls = {
        { type = "checkbox", name = "Action Bar", getFunc = function() return cfg().hideActionBar end, setFunc = function(v) cfg().hideActionBar = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideActionBar },
        { type = "checkbox", name = "Player resource bars", getFunc = function() return cfg().hidePlayerBars end, setFunc = function(v) cfg().hidePlayerBars = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hidePlayerBars },
        { type = "checkbox", name = "Target frames", getFunc = function() return cfg().hideTargetFrames end, setFunc = function(v) cfg().hideTargetFrames = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideTargetFrames },
        { type = "checkbox", name = "Group frames", getFunc = function() return cfg().hideGroupFrames end, setFunc = function(v) cfg().hideGroupFrames = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideGroupFrames },
        { type = "checkbox", name = "ESO compass", getFunc = function() return cfg().hideEsoCompass end, setFunc = function(v) cfg().hideEsoCompass = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideEsoCompass },
        { type = "checkbox", name = "Quest tracker", getFunc = function() return cfg().hideQuestTracker end, setFunc = function(v) cfg().hideQuestTracker = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideQuestTracker },
        { type = "checkbox", name = "Golden Pursuits", getFunc = function() return cfg().hideGoldenPursuits end, setFunc = function(v) cfg().hideGoldenPursuits = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideGoldenPursuits },
        { type = "checkbox", name = "Chat", getFunc = function() return cfg().hideChat end, setFunc = function(v) cfg().hideChat = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideChat },
        { type = "checkbox", name = "Crosshair", getFunc = function() return cfg().hideCrosshair end, setFunc = function(v) cfg().hideCrosshair = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideCrosshair },
        { type = "checkbox", name = "Champion progress bar", getFunc = function() return cfg().hideChampionProgress end, setFunc = function(v) cfg().hideChampionProgress = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideChampionProgress },
        { type = "checkbox", name = "Ultivite combat information", getFunc = function() return cfg().hideCombatInformation end, setFunc = function(v) cfg().hideCombatInformation = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideCombatInformation },
        { type = "checkbox", name = "Ultivite combat warnings", getFunc = function() return cfg().hideCombatWarnings end, setFunc = function(v) cfg().hideCombatWarnings = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideCombatWarnings },
        { type = "checkbox", name = "Feet compass and crown arrow", getFunc = function() return cfg().hideNavigationHelpers end, setFunc = function(v) cfg().hideNavigationHelpers = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideNavigationHelpers },
        { type = "checkbox", name = "Nameplates and overhead information", tooltip = "Temporarily hides ESO nameplates, overhead health bars, titles, guild text, indicators, target markers and chat bubbles, plus Ultivite's overhead player labels.", getFunc = function() return cfg().hideOverheadPlayerInfo end, setFunc = function(v) cfg().hideOverheadPlayerInfo = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideOverheadPlayerInfo },
        { type = "checkbox", name = "Votan's Minimap", getFunc = function() return cfg().hideVotanMinimap end, setFunc = function(v) cfg().hideVotanMinimap = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideVotanMinimap },
        { type = "checkbox", name = "HarvestMap 3D world pins", tooltip = "Temporarily hides HarvestMap's 3D world pins without changing HarvestMap's saved display preference.", getFunc = function() return cfg().hideHarvestMap3dPins end, setFunc = function(v) cfg().hideHarvestMap3dPins = v == true; requestSave(); if I.active then I.Reapply() end end, default = immersiveDefaults.hideHarvestMap3dPins },
        { type = "checkbox", name = "Interaction prompts and synergy prompt", getFunc = function() return cfg().hideInteractionPrompts == true end, setFunc = function(v) cfg().hideInteractionPrompts = v == true; requestSave(); if I.active then I.Reapply() end end, default = false },
        { type = "checkbox", name = "ESO alerts and centre-screen notifications", getFunc = function() return cfg().hideNotifications == true end, setFunc = function(v) cfg().hideNotifications = v == true; requestSave(); if I.active then I.Reapply() end end, default = false },
    }

    local notificationControls = {}
    local function addNotification(name, tooltip, key, previewLabel)
        notificationControls[#notificationControls + 1] = checkbox(name, tooltip, notes, key)
        notificationControls[#notificationControls + 1] = {
            type = "button", name = "Preview / Test: " .. name,
            tooltip = "Shows a three-second preview with the current filter result. BLOCKED PREVIEW means this category is enabled in Notification Cleaner.",
            func = function() I.TestNotification(key, previewLabel or name) end, width = "full",
        }
    end
    addNotification("Friend login / logout messages", "Suppresses ESO's normal friend status lines in chat. Other chat addons that fully replace the handler can override this.", "blockFriendStatus", "Friend has logged in")
    addNotification("Guild member join / leave messages", "Suppresses ESO's normal guild roster join and leave lines in chat.", "blockGuildRoster", "Guild member joined")
    addNotification("Guild Message of the Day notices", "Suppresses ESO's normal Guild MotD chat notice when that event is routed through the base chat handler.", "blockGuildMotd", "Guild Message of the Day")
    addNotification("Group join / leave messages", "Suppresses ESO's normal group member join and leave chat lines.", "blockGroupJoinLeave", "Group member joined")
    addNotification("Screenshot saved alert", "Suppresses ESO's upper-right Screenshot Saved alert. Screenshots are still taken normally.", "blockScreenshotSaved", "Screenshot saved")
    addNotification("Target immune alerts", "Suppresses the common ESO target-immune alert messages, including immune, too powerful and empty soul gem spam. This filter is intentionally narrow.", "blockTargetImmune", "Target is immune")
    addNotification("Crafting result alerts", "Suppresses common ESO crafting-result alert text such as improvement success/failure and no-usable-items messages.", "blockCraftingResults", "Improvement attempt succeeded")
    addNotification("Lorebook and collection completion alerts", "Suppresses ESO alert-text events for learned lorebooks and completed lore collections.", "blockLoreAndCollections", "Lore collection completed")
    addNotification("Ability rank alerts", "Suppresses ESO's ability-rank alert text. Skill progression itself is unchanged.", "blockAbilityRank", "Ability rank increased")
    notificationControls[#notificationControls + 1] = {
            type = "dropdown",
            name = "Duplicate alert throttle",
            tooltip = "Suppresses an identical ZO_Alert if it repeats inside this many seconds. 0 disables throttling.",
            choices = { "Off", "1 second", "2 seconds", "3 seconds", "5 seconds", "10 seconds" },
            choicesValues = { 0, 1, 2, 3, 5, 10 },
            getFunc = function() return tonumber(notes().duplicateAlertThrottle) or 0 end,
            setFunc = function(value) notes().duplicateAlertThrottle = tonumber(value) or 0; requestSave() end,
            default = 0,
            width = "full",
        }

    local state = ensureImmersiveProfiles()
    local function profileLabels()
        local labels = {}
        for _, id in ipairs(state and state.order or {}) do
            local profile = state.profiles[id]
            if profile then labels[#labels + 1] = tostring(profile.name or id) end
        end
        return labels
    end
    local function profileValues()
        local values = {}
        for _, id in ipairs(state and state.order or {}) do if state.profiles[id] then values[#values + 1] = id end end
        return values
    end

    local profileControls = {
        { type = "dropdown", name = "Selected Immersive profile", choices = profileLabels, choicesValues = profileValues,
            getFunc = function() return I.GetSelectedProfileId() end,
            setFunc = function(value) I.SelectProfile(value, false) end, width = "full" },
        { type = "editbox", name = "New or renamed Immersive profile name", isMultiline = false,
            getFunc = function() local current = ensureImmersiveProfiles(); return current and tostring(current.pendingName or "") or "" end,
            setFunc = function(value) local current = ensureImmersiveProfiles(); if current then current.pendingName = tostring(value or ""); requestSave() end end,
            width = "full" },
        { type = "button", name = "Duplicate Current Immersive Profile", func = I.CreateProfileFromCurrent, width = "full" },
        { type = "button", name = "Rename Selected Custom", func = I.RenameSelectedProfile,
            disabled = function() local current = ensureImmersiveProfiles(); local profile = current and current.profiles[current.selectedId]; return not profile or profile.builtin == true end,
            width = "half" },
        { type = "button", name = "Delete Selected Custom", func = I.DeleteSelectedProfile, isDangerous = true,
            disabled = function() local current = ensureImmersiveProfiles(); local profile = current and current.profiles[current.selectedId]; return not profile or profile.builtin == true or current.selectedId == "custom" end,
            width = "half" },
        { type = "button", name = "Restore Built-in Profile Defaults", func = I.RestoreSelectedBuiltin,
            disabled = function() local current = ensureImmersiveProfiles(); return not current or BUILTIN_PROFILES[current.selectedId] == nil end,
            width = "full" },
    }

    return {
        {
            type = "checkbox",
            name = function() return "Immersive Mode active now: " .. I.GetSelectedProfileName() end,
            tooltip = "Temporarily hides the selected HUD elements without changing their normal Ultivite or ESO visibility preferences. Immersive Mode always starts OFF after a fresh login or UI reload.",
            getFunc = function() return I.IsActive() end,
            setFunc = function(value)
                if value ~= true and I.IsCameraMode() then I.SetCameraMode(false, true)
                else I.SetActive(value == true, true) end
            end,
            default = false,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Camera / Screenshot Mode active now",
            tooltip = "Temporarily selects the Camera / Screenshot profile and hides every controlled HUD element, including interaction prompts and notifications. Turning it off restores the previous Immersive profile and active state.",
            getFunc = function() return I.IsCameraMode() end,
            setFunc = function(value) I.SetCameraMode(value == true, false) end,
            default = false,
            width = "full",
        },
        { type = "submenu", name = "Immersive Profile Manager", controls = profileControls },
        {
            type = "submenu",
            name = "Immersive Mode hides",
            tooltip = "Choose exactly what the selected Immersive profile suppresses. Camera / Screenshot hides interaction prompts and notifications but still leaves settings and confirmation dialogs usable.",
            controls = hideControls,
        },
        {
            type = "submenu",
            name = "Notification Cleaner",
            tooltip = "Independent Ultivite filters inspired by common ESO notification-cleanup ideas. They do not require or copy another addon.",
            controls = notificationControls,
        },
        {
            type = "description",
            text = "Safety: Ultivite only hides HarvestMap's existing 3D world-pin layer while the selected Immersive profile is active. It does not change HarvestMap filters or SavedVariables, ordinary map pins, camera fragments, harvesting interactions or confirmation-dialog actions.",
            width = "full",
        },
    }
end
