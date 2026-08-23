local U = Ultivite
local Frames = U.Frames
local Combat = U.Combat
local Sound = U.Sound
local Immersive = U.Immersive
local FAB = U.FancyActionBar
local Ownership = U.Ownership
local LayoutSafety = U.LayoutSafety
local ProfileManager = U.ProfileManager

U.name = "Ultivite"
U.version = "1.0.160"
U.savedVersion = 1
U.migrationVersion = 9
U.panel = nil
U.initialized = false

local function chat(message)
    d(string.format("|c7FD4FF[Ultivite]|r %s", tostring(message)))
end

local DS_TOPLEFT_X = 28
local DS_TOPLEFT_Y = 77
local DS_TOPLEFT_GAP = 2
local DS_ACTIONBAR_ENEMY_BOTTOM = -196
local DS_ACTIONBAR_KB_X = 823.9
local DS_ACTIONBAR_KB_Y = 1169.7
local DS_ACTIONBAR_KB_SCALE = 146
local DS_ACTIONBAR_GP_X = 815.0
local DS_ACTIONBAR_GP_Y = 1134.0
local DS_ACTIONBAR_GP_SCALE = 122

local FACTORY_SOUND_BLOCKS = {}

local function applySharedDarkSoulsTopLeftDefaults(frameSettings)
    if not frameSettings then return end
    frameSettings.darkSoulsMode = true
    frameSettings.showDSUltimate = true
    frameSettings.darkSoulsLeft = DS_TOPLEFT_X
    frameSettings.darkSoulsTop = DS_TOPLEFT_Y
    frameSettings.darkSoulsGap = DS_TOPLEFT_GAP
end

local function lockFancyActionBarEditing()
    local fab = FAB
    if not fab then return end

    -- Presets are presentation changes, never an implicit request to edit the
    -- action bar. Close a real edit session when one exists, and also hard-hide
    -- the mover in case a scale/layout refresh exposed it without setting the
    -- internal unlocked flag.
    if fab.IsUnlocked and fab.ToggleMover and fab.IsUnlocked() then
        fab.ToggleMover(false)
    end
    if FAB_Mover then
        FAB_Mover:SetHidden(true)
        FAB_Mover:SetMouseEnabled(false)
        FAB_Mover:SetMovable(false)
    end
    fab.combatEditOverride = false
end

local function lockPresetEditing()
    lockFancyActionBarEditing()

    local frames = Frames
    if frames and frames.saved then
        if frames.SetLocked then
            -- Call the real lock path even if the SavedVariable already says
            -- locked. That guarantees any stale mover controls/toolbars are
            -- physically hidden as part of preset finalization.
            frames.SetLocked(true, true)
        else
            frames.saved.locked = true
        end
    end
end

local function isExplicitEditingActive()
    if Frames and Frames.saved and Frames.saved.locked == false then return true end
    if Combat and Combat.sv and Combat.sv.locked == false then return true end
    if U.QuickMenu and U.QuickMenu.previewEnabled == true then return true end
    local fab = FAB
    if fab and fab.IsUnlocked and fab.IsUnlocked() then return true end
    return false
end

function U.FinalizePresetEditingState(force)
    -- Never auto-exit an explicit move/resize session. Once editing has started,
    -- only the editor's SAVE & LOCK path should end it. Presets still finalize
    -- to a locked state when no editor is active.
    if force ~= true and isExplicitEditingActive() then return false end
    lockPresetEditing()
    if zo_callLater then
        zo_callLater(lockPresetEditing, 0)
        zo_callLater(lockPresetEditing, 120)
    end
    return true
end

local function applyRecommendedCombatDefaults(combatSettings)
    if not combatSettings then return end

    -- Keep display-preset transitions aligned with the current factory tracker
    -- choices without resetting positions, thresholds or other user tuning.
    -- Diagnostic logging remains off so normal gameplay chat stays clean.
    local enabled = {
        "targetFrame",
        "showKjalnarTracker", "onslaughtTimer", "balorghTimer", "tarnishedTimer",
        "dragonAppetiteCounter", "wretchedVitalityTimers",
        "showCcImmunityTracker", "showGenericStackTracker", "showStreakFatigueTracker",
        "showResourceDanger", "showShieldBrokenWarning", "showExecuteDangerWarning",
        "showBurstDamageWarning", "majorBreachTracker",
        "showNoFoodWarning", "showNoMajorResolveWarning",
        "showEnemyCorrosiveAlert", "showEnemyOnslaughtAlert",
        "showPvpKillCounter", "showPvpKillMessages",
    }
    for _, key in ipairs(enabled) do combatSettings[key] = true end

    local disabled = {
        "nullArcaTimer", "showPlayerDebuffTracker", "showDamageShieldStat",
        "showImportantTargetDebuffs", "showLiveDamageStat",
        "showFrontResistanceStat", "showBackResistanceStat",
    }
    for _, key in ipairs(disabled) do combatSettings[key] = false end

    combatSettings.targetFrameMode = "ultivite"
    combatSettings.hideDefaultTargetFrame = true
    combatSettings.showNativePlayerCpFrame = true
    combatSettings.executeDangerWarningMode = "always"
    combatSettings.burstDamageWarningMode = "always"
    combatSettings.hideLUIETargetFrame = true
    combatSettings.autoHideOtherTargetFrames = true
    combatSettings.nativeHideNpcNames = false
    combatSettings.alwaysCollapseChat = false
    combatSettings.diagnosticLogging = false
end

local function refreshRecommendedCombatHud(combatSettings)
    local combat = Combat
    if not combat or not combatSettings then return end
    combat.sv = combatSettings
    if combat.RefreshDisplay then combat.RefreshDisplay() end
    if combat.UpdateCombatTimers then combat.UpdateCombatTimers() end
    if combat.UpdatePlayerAuraHud then combat.UpdatePlayerAuraHud() end
    if combat.UpdateWretchedVitalityTimers then combat.UpdateWretchedVitalityTimers() end
    if combat.UpdateSkillStackTrackers then combat.UpdateSkillStackTrackers(true) end
    if combat.UpdateResourceDangerHud then combat.UpdateResourceDangerHud(true) end
    if combat.UpdateCombatDangerWarnings then combat.UpdateCombatDangerWarnings() end
    if combat.UpdateImportantTargetDebuffs then combat.UpdateImportantTargetDebuffs() end
    if combat.UpdateLiveStatWidgets then combat.UpdateLiveStatWidgets(true) end
    if combat.UpdateMajorBreachDisplay then combat.UpdateMajorBreachDisplay() end
    if combat.UpdateFoodWarning then combat.UpdateFoodWarning() end
    if combat.UpdateMajorResolveWarning then combat.UpdateMajorResolveWarning() end
    if combat.UpdatePvpHud then combat.UpdatePvpHud(false) end
    if combat.UpdateKillMessage then combat.UpdateKillMessage() end
end

local function applyDarkSoulsActionBarExactFabSettings(fabSettings)
    if not fabSettings then return end

    fabSettings.showHotkeys = false
    fabSettings.staticBars = false
    fabSettings.frontBarTop = true
    fabSettings.activeBarTop = true
    fabSettings.hideLockedBar = false
    fabSettings.alphaInactive = 100
    fabSettings.desaturationInactive = 0

    fabSettings.abScaling = fabSettings.abScaling or {}
    fabSettings.abScaling.kb = fabSettings.abScaling.kb or {}
    fabSettings.abScaling.gp = fabSettings.abScaling.gp or {}
    fabSettings.abScaling.kb.enable = true
    fabSettings.abScaling.kb.scale = DS_ACTIONBAR_KB_SCALE
    fabSettings.abScaling.gp.enable = true
    fabSettings.abScaling.gp.scale = DS_ACTIONBAR_GP_SCALE

    fabSettings.abMove = fabSettings.abMove or {}
    fabSettings.abMove.kb = fabSettings.abMove.kb or {}
    fabSettings.abMove.gp = fabSettings.abMove.gp or {}

    fabSettings.abMove.kb.enable = true
    fabSettings.abMove.kb.x = DS_ACTIONBAR_KB_X
    fabSettings.abMove.kb.y = DS_ACTIONBAR_KB_Y
    fabSettings.abMove.kb.prevX = DS_ACTIONBAR_KB_X
    fabSettings.abMove.kb.prevY = DS_ACTIONBAR_KB_Y

    fabSettings.abMove.gp.enable = true
    fabSettings.abMove.gp.x = DS_ACTIONBAR_GP_X
    fabSettings.abMove.gp.y = DS_ACTIONBAR_GP_Y
    fabSettings.abMove.gp.prevX = DS_ACTIONBAR_GP_X
    fabSettings.abMove.gp.prevY = DS_ACTIONBAR_GP_Y

    if FAB and FAB.RefreshRuntime then FAB.RefreshRuntime() end
end

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = deepCopy(child)
    end
    return copy
end

local function fillDefaults(target, defaults)
    if type(target) ~= "table" or type(defaults) ~= "table" then return end
    for key, defaultValue in pairs(defaults) do
        if target[key] == nil then
            target[key] = deepCopy(defaultValue)
        elseif type(target[key]) == "table" and type(defaultValue) == "table" then
            fillDefaults(target[key], defaultValue)
        end
    end
end

local function copyKnownSettings(source, destination, defaults)
    if type(source) ~= "table" or type(destination) ~= "table" or type(defaults) ~= "table" then return end
    for key, defaultValue in pairs(defaults) do
        local sourceValue = source[key]
        if sourceValue ~= nil then
            if type(sourceValue) == "table" then
                destination[key] = deepCopy(sourceValue)
            else
                destination[key] = sourceValue
            end
        elseif destination[key] == nil then
            destination[key] = deepCopy(defaultValue)
        end
    end
end

local function buildProfileDefaults()
    return {
        combat = deepCopy(Combat and Combat.defaults or {}),
        frames = deepCopy(Frames and Frames.defaults or {}),
        sound = deepCopy(Sound and Sound.defaults or {}),
        fab = (FAB and FAB.GetSnapshot and FAB.GetSnapshot()) or {
            enabled = false,
            sourceVersion = "external",
            settings = deepCopy(FAB and FAB.defaultSettings or {}),
            character = deepCopy(FAB and FAB.defaultCharacter or {}),
        },
    }
end

function U.IsUsingAccountWideSettings()
    return not U.accountSV or U.accountSV.useAccountWide ~= false
end

function U.GetActiveProfile()
    return U.IsUsingAccountWideSettings() and U.accountSV or U.characterSV
end

function U.EnsureProfiles()
    local defaults = buildProfileDefaults()
    for _, profile in ipairs({ U.accountSV, U.characterSV }) do
        profile.combat = profile.combat or {}
        profile.frames = profile.frames or {}
        profile.sound = profile.sound or {}
        profile.fab = profile.fab or {}
        fillDefaults(profile.combat, defaults.combat)
        fillDefaults(profile.frames, defaults.frames)
        fillDefaults(profile.sound, defaults.sound)
        fillDefaults(profile.fab, defaults.fab)
    end
end

function U.CopyProfile(source, destination)
    if not source or not destination then return end
    destination.combat = deepCopy(source.combat or {})
    destination.frames = deepCopy(source.frames or {})
    destination.sound = deepCopy(source.sound or {})
    destination.fab = deepCopy(source.fab or {})
end

-- Build a snapshot from the live module tables rather than assuming the top-level
-- profile still owns every table reference. This matters after profile switches,
-- migrations and external FAB reconfiguration, where a module can otherwise keep
-- writing to an older table while the shared profile silently becomes stale.
function U.CaptureLiveProfileSnapshot()
    local active = U.GetActiveProfile() or {}
    local activeFab = active.fab or {}

    local snapshot = {
        combat = deepCopy((Combat and Combat.sv) or active.combat or {}),
        frames = deepCopy((Frames and Frames.saved) or active.frames or {}),
        sound = deepCopy((Sound and Sound.sv) or active.sound or {}),
        fab = (FAB and FAB.GetSnapshot and FAB.GetSnapshot()) or {
            enabled = activeFab.enabled ~= false,
            sourceVersion = activeFab.sourceVersion or "external",
            settings = deepCopy(activeFab.settings or {}),
            character = deepCopy(activeFab.character or {}),
        },
    }

    if snapshot.fab.character then
        snapshot.fab.character.useAccountWide = true
    end
    return snapshot
end

local function syncTableInPlace(destination, source)
    if type(destination) ~= "table" or type(source) ~= "table" then return end

    for key in pairs(destination) do
        if source[key] == nil then
            destination[key] = nil
        end
    end

    for key, value in pairs(source) do
        if type(value) == "table" and type(destination[key]) == "table" then
            syncTableInPlace(destination[key], value)
        else
            destination[key] = deepCopy(value)
        end
    end
end

function U.WriteSnapshotToProfile(snapshot, destination)
    if type(snapshot) ~= "table" or type(destination) ~= "table" then return end

    destination.combat = destination.combat or {}
    destination.frames = destination.frames or {}
    destination.sound = destination.sound or {}
    destination.fab = destination.fab or {}

    -- Preserve existing table identities so modules that are already bound to
    -- account-wide tables keep writing into the canonical SavedVariables tree
    -- after an explicit Save Settings operation.
    syncTableInPlace(destination.combat, snapshot.combat or {})
    syncTableInPlace(destination.frames, snapshot.frames or {})
    syncTableInPlace(destination.sound, snapshot.sound or {})
    syncTableInPlace(destination.fab, snapshot.fab or {})
end

function U.PersistLiveSettingsToCurrentScope()
    local snapshot = U.CaptureLiveProfileSnapshot()
    if U.IsUsingAccountWideSettings() then
        -- The account-wide profile is canonical. Mirror it into the current
        -- character profile too so a later scope change cannot expose stale data.
        U.WriteSnapshotToProfile(snapshot, U.accountSV)
        U.WriteSnapshotToProfile(snapshot, U.characterSV)
        U.accountSV.useAccountWide = true
        U.accountSV.profileSyncRevision = (tonumber(U.accountSV.profileSyncRevision) or 0) + 1
        U.characterSV.profileSyncRevision = U.accountSV.profileSyncRevision
    else
        U.WriteSnapshotToProfile(snapshot, U.characterSV)
    end
    U.EnsureProfiles()
end

function U.RequestSettingsSave(silent)
    if RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave(U.name)
    end
    if FAB and FAB.RequestSave then
        FAB.RequestSave()
    end
    if not silent then
        chat("Settings queued for immediate save.")
    end
end

function U.ReleaseAllOverrides(silent)
    if Immersive then
        if Immersive.IsCameraMode and Immersive.IsCameraMode() and Immersive.SetCameraMode then
            Immersive.SetCameraMode(false, true)
        end
        if Immersive.SetActive then Immersive.SetActive(false, true) end
    end
    if U.QuickMenu and U.QuickMenu.SetPreviewEnabled then U.QuickMenu.SetPreviewEnabled(false) end
    if Ownership and Ownership.ReleaseAll then Ownership.ReleaseAll() end

    if Frames then
        if Frames.ApplyGroupFrameState then Frames.ApplyGroupFrameState() end
        if Frames.ApplyChampionProgressVisibility then Frames.ApplyChampionProgressVisibility(true) end
        if Frames.ApplyChatVisibilityMode then Frames.ApplyChatVisibilityMode() end
        if Frames.RefreshUiVisibilityRules then Frames.RefreshUiVisibilityRules(true) end
        if Frames.RefreshNavigationHelpers then Frames.RefreshNavigationHelpers(true) end
        if Frames.RefreshDSSelfHealthRuntime then Frames.RefreshDSSelfHealthRuntime() end
        if Frames.RefreshDSEnemyHealthRuntime then Frames.RefreshDSEnemyHealthRuntime() end
    end
    if Combat then
        if Combat.RefreshDisplay then Combat.RefreshDisplay() end
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.UpdateCombatDangerWarnings then Combat.UpdateCombatDangerWarnings(true) end
        if Combat.UpdateFoodWarning then Combat.UpdateFoodWarning() end
        if Combat.UpdateMajorResolveWarning then Combat.UpdateMajorResolveWarning() end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
    end
    if U.EnemyUltimateAlerts and U.EnemyUltimateAlerts.Update then U.EnemyUltimateAlerts.Update(true) end
    if not silent then chat("All temporary Ultivite overrides released. Persistent visibility settings were reapplied.") end
    return true
end

function U.SyncCurrentSettingsToAccountWide()
    if not U.accountSV or not U.characterSV then return end

    -- Always capture the live module state. Do not short-circuit merely because
    -- account-wide mode is already selected; that was the old failure mode that
    -- could leave the canonical profile stale while the current character looked right.
    local snapshot = U.CaptureLiveProfileSnapshot()
    U.WriteSnapshotToProfile(snapshot, U.accountSV)
    U.WriteSnapshotToProfile(snapshot, U.characterSV)
    U.accountSV.useAccountWide = true
    U.accountSV.profileSyncRevision = (tonumber(U.accountSV.profileSyncRevision) or 0) + 1
    U.characterSV.profileSyncRevision = U.accountSV.profileSyncRevision
    U.EnsureProfiles()
    if FAB and FAB.SetUseAccountWide then
        FAB.SetUseAccountWide(true)
    end
    U.RequestSettingsSave(true)
    chat("Current live Ultivite settings synced account-wide. Fancy Action Bar+ remains external and its skill/effect configuration was set to account-wide as well.")

    -- Give the priority save request time to be serviced before reloading the UI.
    zo_callLater(function()
        if ReloadUI then ReloadUI() end
    end, 500)
end

function U.PositionFancyActionBarAbovePlayerBars(silent)
    local profile = U.GetActiveProfile()
    local fabSettings = (FAB and FAB.GetSettings and FAB.GetSettings())
    local frameSettings = profile and profile.frames
    local fab = FAB
    local actionBar = GetControl and GetControl("ZO_ActionBar1") or ZO_ActionBar1

    if not fabSettings or not frameSettings or not fab or not actionBar then
        if not silent then chat("Fancy Action Bar is not available for positioning.") end
        return false
    end

    local rootWidth = tonumber(GuiRoot:GetWidth()) or 1920
    local rootHeight = tonumber(GuiRoot:GetHeight()) or 1080
    local visualHeight = Frames and Frames.GetVisualPrimaryBarHeight and Frames.GetVisualPrimaryBarHeight() or 30
    local healthY = tonumber(frameSettings.healthY) or 0
    local resourceTop = (rootHeight / 2) + healthY - (visualHeight / 2)

    if fab.ApplyCombatOnlyVisibility then
        fab.ApplyCombatOnlyVisibility(true)
    end

    local scale = actionBar.GetScale and tonumber(actionBar:GetScale()) or 1
    if not scale or scale <= 0 then scale = 1 end
    local barWidth = (tonumber(actionBar:GetWidth()) or 500) * scale
    local barHeight = (tonumber(actionBar:GetHeight()) or 80) * scale
    local verticalGap = 8
    local x = zo_floor((rootWidth - barWidth) / 2)
    local y = zo_floor(resourceTop - verticalGap - barHeight)

    actionBar:ClearAnchors()
    actionBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)

    -- Centre the complete FAB composition, not only ZO_ActionBar1. Quickslot and
    -- Ultimate extend beyond the root control and otherwise make the bar look
    -- shifted even when the root itself is mathematically centered.
    if fab.CenterActionBar then
        fab.CenterActionBar(true, false)
    end
    if fab.GetWholeActionBarVisualBounds and fab.GetWholeActionBarPosition and fab.SetWholeActionBarPosition then
        local _, _, _, visualBottom = fab.GetWholeActionBarVisualBounds()
        local currentX, currentY = fab.GetWholeActionBarPosition()
        if visualBottom and currentY then
            local desiredBottom = resourceTop - verticalGap
            fab.SetWholeActionBarPosition(currentX, currentY + (desiredBottom - visualBottom))
        end
    end

    local finalX, finalY = x, y
    if fab.GetWholeActionBarPosition then
        finalX, finalY = fab.GetWholeActionBarPosition()
    end
    fabSettings.abMove = fabSettings.abMove or {}
    fabSettings.abMove.kb = fabSettings.abMove.kb or {}
    fabSettings.abMove.gp = fabSettings.abMove.gp or {}
    for _, move in ipairs({ fabSettings.abMove.kb, fabSettings.abMove.gp }) do
        move.x = finalX
        move.y = finalY
        move.enable = true
    end

    if fab.constants and fab.constants.move then
        fab.constants.move.x = finalX
        fab.constants.move.y = finalY
        fab.constants.move.enable = true
    end
    if fab.SetMoved then fab.SetMoved(true) end
    if fab.ReanchorMover then fab.ReanchorMover() end
    if fab.SaveMoverPosition then fab.SaveMoverPosition() end
    if fab.ApplyCombatOnlyVisibility then
        fab.ApplyCombatOnlyVisibility(false)
    end

    U.RequestSettingsSave(true)
    if not silent then
        chat("Fancy Action Bar positioned directly above the bottom resource bars.")
    end
    return true
end

function U.PositionFancyActionBarBelowPlayerBars(silent)
    local profile = U.GetActiveProfile()
    local fabSettings = (FAB and FAB.GetSettings and FAB.GetSettings())
    local frameSettings = profile and profile.frames
    local fab = FAB
    local actionBar = GetControl and GetControl("ZO_ActionBar1") or ZO_ActionBar1

    if not fabSettings or not frameSettings or not fab or not actionBar then
        if not silent then chat("Fancy Action Bar is not available for positioning.") end
        return false, nil, nil
    end

    if fab.ApplyCombatOnlyVisibility then
        fab.ApplyCombatOnlyVisibility(true)
    end

    -- User-approved Pyramid reference captured from the in-game layout report.
    -- Keep the exact saved Pyramid FAB placement instead of recalculating it.
    local kbX, kbY = 801.2, 1177.4
    local gpX, gpY = 803.0, 1296.8
    local useGamepad = fab.style == 2
    local targetX = useGamepad and gpX or kbX
    local targetY = useGamepad and gpY or kbY

    actionBar:ClearAnchors()
    actionBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, targetX, targetY)

    if fab.SetWholeActionBarPosition then
        fab.SetWholeActionBarPosition(targetX, targetY)
    end

    fabSettings.abMove = fabSettings.abMove or {}
    fabSettings.abMove.kb = fabSettings.abMove.kb or {}
    fabSettings.abMove.gp = fabSettings.abMove.gp or {}
    fabSettings.abMove.kb.enable = true
    fabSettings.abMove.kb.x = kbX
    fabSettings.abMove.kb.y = kbY
    fabSettings.abMove.kb.prevX = kbX
    fabSettings.abMove.kb.prevY = kbY
    fabSettings.abMove.gp.enable = true
    fabSettings.abMove.gp.x = gpX
    fabSettings.abMove.gp.y = gpY
    fabSettings.abMove.gp.prevX = gpX
    fabSettings.abMove.gp.prevY = gpY

    if fab.constants and fab.constants.move then
        fab.constants.move.x = targetX
        fab.constants.move.y = targetY
        fab.constants.move.enable = true
    end
    if fab.SetMoved then fab.SetMoved(true) end
    if fab.ReanchorMover then fab.ReanchorMover() end
    if fab.SaveMoverPosition then fab.SaveMoverPosition() end
    if fab.ApplyCombatOnlyVisibility then
        fab.ApplyCombatOnlyVisibility(false)
    end

    local visualLeft, visualTop, visualRight, visualBottom
    if fab.GetWholeActionBarVisualBounds then
        visualLeft, visualTop, visualRight, visualBottom = fab.GetWholeActionBarVisualBounds()
    end

    U.RequestSettingsSave(true)
    if not silent then
        chat("Fancy Action Bar positioned beneath the Pyramid player frames.")
    end
    local fallbackHeight = (tonumber(actionBar:GetHeight()) or 80) * ((actionBar.GetScale and tonumber(actionBar:GetScale())) or 1)
    return true, visualTop or targetY, visualBottom or (targetY + fallbackHeight)
end

function U.ApplyFullDarkSoulsAuxVisibility(enabled)
    enabled = enabled and true or false
    -- These FAB controls live outside the shared ESO action-bar root. Hide only
    -- the explicitly known controls so the Full Dark Souls preset stays minimal
    -- without deleting or rewriting the user's FAB configuration.
    for _, controlName in ipairs({ "FAB_GCD", "FAB_Mover", "FAB_EffectWidgetsRoot" }) do
        local control = GetControl and GetControl(controlName) or nil
        if control and control.SetHidden then
            control:SetHidden(enabled)
        end
    end

    local fabReady = FAB and FAB.IsAvailable and FAB.IsAvailable()
    if not enabled and fabReady then
        if FAB.RefreshEffectWidgets then
            FAB.RefreshEffectWidgets()
        end
        if FAB.ToggleGCD then
            FAB.ToggleGCD()
        end
    end
end

function U.ApplyDefaultCombatHUDLayout(silent)
    local profile = U.GetActiveProfile()
    local frameSettings = profile and profile.frames
    local combatSettings = profile and profile.combat
    if combatSettings then
        applyRecommendedCombatDefaults(combatSettings)
        combatSettings.hideNativeOverheadHealthBars = false
    end
    if frameSettings then
        -- The Ultivite Default preset should return to the same public factory
        -- baseline used by a fresh 1.0.79 install. In particular, do not carry
        -- Full Dark Souls visibility suppression back into the normal preset.
        frameSettings.fullDarkSoulsMode = false
        frameSettings.darkSoulsMode = false
        frameSettings.showDSUltimate = false
        frameSettings.dsSelfHealthBar = false
        frameSettings.dsSelfResourceBars = false
        frameSettings.dsBottomOnly = false
        frameSettings.dsSelfHealthCombatOnly = false
        frameSettings.combatOnly = false
        frameSettings.hideActionBar = false
        frameSettings.dsEnemyHealthMode = "off"
        frameSettings.dsEnemyTrackReticle = false
        frameSettings.hideChampionProgress = false
        frameSettings.hideChampionProgressInPvp = true
        frameSettings.championProgressVisibilityMode = "pvp"
        frameSettings.showTeammateCpReticle = false
        frameSettings.hideWerewolfResourceBar = true
        frameSettings.hideMountStaminaBar = true
        frameSettings.autoHideChat = false
        frameSettings.chatVisibilityMode = "show"
        frameSettings.compassVisibilityMode = "combat"
        frameSettings.questTrackerVisibilityMode = "pvp"
        frameSettings.queueStatusVisibilityMode = "show"
        frameSettings.crosshairVisibilityMode = "show"
        frameSettings.crownDirectionArrow = false
        frameSettings.feetCompass = false
    end
    U.ApplyFullDarkSoulsAuxVisibility(false)
    if Frames then
        Frames.saved = frameSettings or Frames.saved
        if Frames.SetQuickPlayerLayout then
            Frames.SetQuickPlayerLayout("normal", true)
        end
        Frames.RestoreActionBarVisibility()
        Frames.RefreshDSEnemyHealthRuntime()
        if Frames.ApplyUltiviteBottomPreset then
            Frames.ApplyUltiviteBottomPreset(true)
        end
        if Frames.ApplySavedLayoutDirect then
            Frames.ApplySavedLayoutDirect("Ultivite vanilla default preset", true)
        end
        if Frames.ApplyChampionProgressVisibility then
            Frames.ApplyChampionProgressVisibility(true)
        end
        if Frames.ApplyChatVisibilityMode then
            Frames.ApplyChatVisibilityMode()
        elseif Frames.ApplyAutoHideChat then
            Frames.ApplyAutoHideChat()
        end
    end

    if Combat and combatSettings then
        Combat.sv = combatSettings
        if Combat.SetHideNativeOverheadHealthBars then
            Combat.SetHideNativeOverheadHealthBars(false, true)
        end
        refreshRecommendedCombatHud(combatSettings)
    end

    local fabSettings = (FAB and FAB.GetSettings and FAB.GetSettings())
    if fabSettings then
        fabSettings.showHotkeys = false
        fabSettings.staticBars = false
        fabSettings.frontBarTop = true
        fabSettings.activeBarTop = true
        fabSettings.hideLockedBar = false
        fabSettings.alphaInactive = 100
        fabSettings.desaturationInactive = 0
        -- Ultivite owns the native player bars; external FAB must not move them.
        fabSettings.moveHealthBar = false
        fabSettings.moveResourceBars = false
        fabSettings.moveBuffs = false
        fabSettings.moveSynergy = false
        -- Exact user-approved FAB layout captured by Print Positions in ESO.
        -- Keyboard is the authoritative normal/default layout. Gamepad values are
        -- retained from the same diagnostic so switching UI mode stays deterministic.
        fabSettings.abScaling = fabSettings.abScaling or {}
        fabSettings.abScaling.kb = fabSettings.abScaling.kb or {}
        fabSettings.abScaling.gp = fabSettings.abScaling.gp or {}
        fabSettings.abScaling.kb.enable = true
        fabSettings.abScaling.kb.scale = 154
        fabSettings.abScaling.gp.enable = true
        fabSettings.abScaling.gp.scale = 122

        fabSettings.abMove = fabSettings.abMove or {}
        fabSettings.abMove.kb = fabSettings.abMove.kb or {}
        fabSettings.abMove.gp = fabSettings.abMove.gp or {}
        fabSettings.abMove.kb.enable = true
        fabSettings.abMove.kb.x = 796.0245361328
        fabSettings.abMove.kb.y = 1126.2349853516
        fabSettings.abMove.kb.prevX = 796.0245361328
        fabSettings.abMove.kb.prevY = 1126.2349853516
        fabSettings.abMove.gp.enable = true
        fabSettings.abMove.gp.x = 815.0
        fabSettings.abMove.gp.y = 1134.0
        fabSettings.abMove.gp.prevX = 815.0
        fabSettings.abMove.gp.prevY = 1134.0

        if FAB and FAB.constants then
            local isGamepad = FAB.style == 2
            local targetScale = isGamepad and 122 or 154
            local targetX = isGamepad and 815.0 or 796.0245361328
            local targetY = isGamepad and 1134.0 or 1126.2349853516
            if FAB.constants.abScale then
                FAB.constants.abScale.enable = true
                FAB.constants.abScale.scale = targetScale
            end
            if FAB.constants.move then
                FAB.constants.move.enable = true
                FAB.constants.move.x = targetX
                FAB.constants.move.y = targetY
            end
            if FAB.SetScale then FAB.SetScale() end
            if FAB.SetWholeActionBarPosition then
                FAB.SetWholeActionBarPosition(targetX, targetY)
            end
        end
    end

    zo_callLater(function()
        local fab = FAB
        if fab then
            local isGamepad = fab.style == 2
            local targetScale = isGamepad and 122 or 154
            local targetX = isGamepad and 815.0 or 796.0245361328
            local targetY = isGamepad and 1134.0 or 1126.2349853516
            if fab.constants and fab.constants.abScale then
                fab.constants.abScale.enable = true
                fab.constants.abScale.scale = targetScale
            end
            if fab.constants and fab.constants.move then
                fab.constants.move.enable = true
                fab.constants.move.x = targetX
                fab.constants.move.y = targetY
            end
            if fab.SetScale then fab.SetScale() end
            if fab.SetWholeActionBarPosition then fab.SetWholeActionBarPosition(targetX, targetY) end
            if fab.ApplyCombatOnlyVisibility then fab.ApplyCombatOnlyVisibility(false) end
        end
        U.RequestSettingsSave(true)
        if not silent then
            chat("Recommended layout restored: Health 0,623 | Magicka -553,623 | Stamina 553,623 | bars 145.5% x 212.3% | FAB keyboard 154% at 796.0,1126.2.")
        end
    end, 60)
    U.FinalizePresetEditingState()
end

function U.ApplyDarkSoulsSelfPreset(silent)
    local profile = U.GetActiveProfile()
    if not profile or not profile.frames then return false end

    if profile.frames.pyramidLayoutEnabled == true and Frames and Frames.SetPyramidLayoutEnabled then
        Frames.saved = profile.frames
        Frames.SetPyramidLayoutEnabled(false, true)
    end

    -- Leaving the minimal Full Dark Souls preset must restore the normal
    -- recommended combat features instead of carrying its temporary off-state
    -- into the large-bottom player layout.
    applyRecommendedCombatDefaults(profile.combat)

    -- Presets are display modes, not editing modes. Never leave FAB unlocked
    -- simply because another layout was being edited before this preset.
    lockFancyActionBarEditing()

    local f = profile.frames
    f.fullDarkSoulsMode = false
    f.darkSoulsMode = false
    -- Dark Souls Self keeps the standalone Ultimate preference enabled. The
    -- icon remains hidden while the action bar is present and appears beside
    -- the large bottom stack if Hide Action Bar is enabled.
    f.showDSUltimate = true
    f.dsSelfHealthBar = true
    f.dsSelfResourceBars = true
    f.dsBottomOnly = true
    f.dsSelfHealthCombatOnly = false
    f.combatOnly = true
    f.dsBottomX = 0
    f.dsBottomOffset = -220
    f.dsBottomGap = 8
    f.dsEnemyHealthMode = "off"
    f.dsEnemyTrackReticle = false
    f.hideActionBar = false
    U.ApplyFullDarkSoulsAuxVisibility(false)
    if Frames then
        Frames.saved = f
        -- A display preset must never leave player-bar edit mode active. Native
        -- ESO bars are not part of Dark Souls Self and must stay suppressed.
        if Frames.SetLocked then
            Frames.SetLocked(true, true)
        else
            f.locked = true
        end
        if Frames.SetQuickPlayerLayout then
            Frames.SetQuickPlayerLayout("bottomOnly", true)
        end
        if Frames.ApplySavedLayoutDirect then
            Frames.ApplySavedLayoutDirect("Dark Souls Self preset", true)
        end
        Frames.RestoreActionBarVisibility()
        Frames.RefreshDSEnemyHealthRuntime()
        Frames.RefreshDSSelfHealthRuntime()
    end

    refreshRecommendedCombatHud(profile.combat)
    U.RequestSettingsSave(true)
    if CALLBACK_MANAGER and U.panel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
    end
    if not silent then
        chat("Dark Souls Self preset applied: large stacked Health, Magicka and Stamina bars with the normal/Fancy action bar retained.")
    end
    U.FinalizePresetEditingState()
    return true
end

function U.ApplyFullDarkSoulsPreset(silent)
    local profile = U.GetActiveProfile()
    if not profile or not profile.frames or not profile.combat then return false end

    if profile.frames.pyramidLayoutEnabled == true and Frames and Frames.SetPyramidLayoutEnabled then
        Frames.saved = profile.frames
        Frames.SetPyramidLayoutEnabled(false, true)
    end

    local f = profile.frames
    local c = profile.combat
    c.targetFrameMode = "ultivite"

    -- Reference-style Full Dark Souls layout: only the player resource stack and
    -- Ultimate at top left plus one large enemy Health bar near the bottom.
    f.fullDarkSoulsMode = true
    applySharedDarkSoulsTopLeftDefaults(f)
    f.dsSelfHealthBar = false
    f.dsSelfResourceBars = false
    f.dsBottomOnly = false
    f.dsEnemyHealthMode = "only"
    f.dsEnemyTrackReticle = true
    f.dsEnemyX = 0
    f.dsEnemyBottomOffset = -38
    f.dsEnemyWidth = 988
    f.dsEnemyHeight = 18
    f.hideActionBar = true
    f.combatOnly = true
    f.hideChampionProgress = true
    f.hideChampionProgressInPvp = false
    f.championProgressVisibilityMode = "hide"
    f.autoHideChat = true
    f.chatVisibilityMode = "hide"
    f.compassVisibilityMode = "hide"
    f.questTrackerVisibilityMode = "hide"
    f.queueStatusVisibilityMode = "hide"

    -- Full Dark Souls intentionally suppresses every other Ultivite combat HUD
    -- element. These are ordinary saved toggles and remain fully editable after
    -- applying the preset. No set detection code or SavedVariables table is removed.
    local disable = {
        "targetFrame",
        "showKjalnarTracker", "onslaughtTimer", "balorghTimer", "tarnishedTimer",
        "nullArcaTimer", "dragonAppetiteCounter", "wretchedVitalityTimers",
        "showCcImmunityTracker", "showPlayerDebuffTracker",
        "showLiveDamageStat", "showFrontResistanceStat", "showBackResistanceStat",
        "showDamageShieldStat", "showGenericStackTracker", "showStreakFatigueTracker",
        "showResourceDanger", "showShieldBrokenWarning", "showExecuteDangerWarning",
        "showBurstDamageWarning", "showImportantTargetDebuffs", "majorBreachTracker",
        "showNoFoodWarning", "showNoMajorResolveWarning",
        "showPvpKillCounter", "showPvpKillMessages",
    }
    for _, key in ipairs(disable) do c[key] = false end
    c.hideNativeOverheadHealthBars = true
    c.hideDefaultTargetFrame = true
    c.hideLUIETargetFrame = true

    if Frames then
        Frames.saved = f
        if Frames.ApplyChatVisibilityMode then Frames.ApplyChatVisibilityMode()
        elseif Frames.ApplyAutoHideChat then Frames.ApplyAutoHideChat() end
        Frames.SetDSBottomOnly(false, true)
        Frames.SetDSSelfResourceBars(false, true)
        Frames.SetDSSelfHealthBar(false, true)
        Frames.SetDarkSoulsMode(true, true)
        Frames.SetShowDSUltimate(true, true)
        Frames.SetDSEnemyHealthMode("only", true)
        Frames.dsEnemyGeometrySignature = nil
        -- The preset writes the profile first, so explicitly apply every visual
        -- component even when an individual setter sees the requested value
        -- already present and therefore has nothing to toggle.
        Frames.ApplySavedLayoutDirect("Full Dark Souls preset", true)
        if Frames.ApplyBarGeometry then Frames.ApplyBarGeometry() end
        if Frames.ApplyDarkSoulsHealthStyle then Frames.ApplyDarkSoulsHealthStyle() end
        if Frames.SetDarkSoulsResourceTextHidden then Frames.SetDarkSoulsResourceTextHidden(true) end
        if Frames.AnchorAllBarsToSavedPositions then Frames.AnchorAllBarsToSavedPositions() end
        if Frames.PositionAllMovers then Frames.PositionAllMovers() end
        if Frames.UpdateAllMoverSizes then Frames.UpdateAllMoverSizes() end
        if Frames.UpdateDSUltimateControl then Frames.UpdateDSUltimateControl() end
        if Frames.UpdateCombatVisibility then Frames.UpdateCombatVisibility(IsUnitInCombat and IsUnitInCombat("player") or false) end
        Frames.RefreshDSEnemyHealthRuntime()
        Frames.RefreshUiVisibilityRules()
        -- Full Dark Souls is the one mode allowed to hide the shared ESO/FAB
        -- action-bar root even while external FAB remains loaded.
        Frames.ApplyActionBarHidden()
        U.ApplyFullDarkSoulsAuxVisibility(true)
    end

    if Combat then
        Combat.sv = c
        if Combat.SetHideNativeOverheadHealthBars then Combat.SetHideNativeOverheadHealthBars(true, true)
        elseif Combat.SetNativeOverheadTargetBar then Combat.SetNativeOverheadTargetBar(false) end
        if Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
        if Combat.ApplyLUIETargetFrameVisibility then Combat.ApplyLUIETargetFrameVisibility() end
        if Combat.RefreshDisplay then Combat.RefreshDisplay() end
        if Combat.UpdateCombatTimers then Combat.UpdateCombatTimers() end
        if Combat.UpdatePlayerAuraHud then Combat.UpdatePlayerAuraHud() end
        if Combat.UpdateWretchedVitalityTimers then Combat.UpdateWretchedVitalityTimers() end
        if Combat.UpdateSkillStackTrackers then Combat.UpdateSkillStackTrackers(true) end
        if Combat.UpdateResourceDangerHud then Combat.UpdateResourceDangerHud(true) end
        if Combat.UpdateCombatDangerWarnings then Combat.UpdateCombatDangerWarnings() end
        if Combat.UpdateImportantTargetDebuffs then Combat.UpdateImportantTargetDebuffs() end
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
        if Combat.UpdateFoodWarning then Combat.UpdateFoodWarning() end
        if Combat.UpdateMajorResolveWarning then Combat.UpdateMajorResolveWarning() end
        if Combat.UpdatePvpHud then Combat.UpdatePvpHud(false) end
        if Combat.UpdateKillMessage then Combat.UpdateKillMessage() end
    end

    U.RequestSettingsSave(true)
    if CALLBACK_MANAGER and U.panel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
    end
    if not silent then
        chat("Dark Souls preset applied: top-left Health/Magicka/Stamina + Ultimate, large bottom enemy Health bar, action bar and other Ultivite HUD elements hidden.")
    end
    U.FinalizePresetEditingState()
    return true
end

function U.GetDarkSoulsActionBarHealthSource()
    local profile = U.GetActiveProfile()
    local f = profile and profile.frames
    if f and f.dsSelfHealthBar == true and f.dsSelfResourceBars ~= true and f.dsEnemyHealthMode == "off" then
        return "self"
    end
    return "enemy"
end

function U.PositionDarkSoulsActionBarLongBar()
    local profile = U.GetActiveProfile()
    local f = profile and profile.frames
    if not f then return false end

    local guiHeight = GuiRoot and GuiRoot.GetHeight and tonumber(GuiRoot:GetHeight()) or 0
    local fabTop = nil
    local fab = FAB
    if fab and fab.GetWholeActionBarVisualBounds then
        local _, top = fab.GetWholeActionBarVisualBounds()
        fabTop = tonumber(top)
    end
    if not fabTop and ZO_ActionBar1 and ZO_ActionBar1.GetTop then
        fabTop = tonumber(ZO_ActionBar1:GetTop())
    end

    -- Put the thin long Health bar just above the full Fancy Action Bar visual
    -- composition. Persist the resolved bottom offset so profile sync reproduces
    -- the same layout without requiring FAB to be queried every frame.
    local bottomOffset = -300
    if fabTop and guiHeight and guiHeight > 0 then
        bottomOffset = zo_round((fabTop - 12) - guiHeight)
    end
    bottomOffset = math.max(-900, math.min(0, bottomOffset))

    f.dsEnemyX = 0
    f.dsEnemyBottomOffset = bottomOffset
    f.dsBottomX = 0
    f.dsBottomOffset = bottomOffset

    if Frames then
        Frames.saved = f
        Frames.dsEnemyGeometrySignature = nil
        if Frames.ApplyDSEnemyHealthGeometry then Frames.ApplyDSEnemyHealthGeometry() end
        if Frames.UpdateDSEnemyHealthBar then Frames.UpdateDSEnemyHealthBar() end
        if Frames.UpdateDSSelfHealthBar then Frames.UpdateDSSelfHealthBar() end
    end
    U.RequestSettingsSave(true)
    return true
end

function U.SetDarkSoulsActionBarHealthSource(source, silent)
    local profile = U.GetActiveProfile()
    local f = profile and profile.frames
    if not f then return false end

    source = source == "self" and "self" or "enemy"
    f.dsSelfResourceBars = false
    f.dsBottomOnly = false
    if source == "self" then
        f.dsSelfHealthBar = true
        f.dsEnemyHealthMode = "off"
        f.dsEnemyTrackReticle = false
    else
        f.dsSelfHealthBar = false
        f.dsEnemyHealthMode = "only"
        f.dsEnemyTrackReticle = true
        f.dsEnemyWidth = 988
        f.dsEnemyHeight = 18
        f.dsEnemyX = 0
    end

    if Frames then
        Frames.saved = f
        Frames.dsEnemyGeometrySignature = nil
        Frames.RefreshDSEnemyHealthRuntime()
        Frames.RefreshDSSelfHealthRuntime()
    end
    U.PositionDarkSoulsActionBarLongBar()
    U.RequestSettingsSave(true)
    if CALLBACK_MANAGER and U.panel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
    end
    if not silent then
        chat(source == "self" and "Dark Souls + Action Bar long Health bar: SELF" or "Dark Souls + Action Bar long Health bar: ENEMY TARGET")
    end
    return true
end

function U.ApplyDarkSoulsActionBarPreset(silent)
    local profile = U.GetActiveProfile()
    if not profile or not profile.frames or not profile.combat or not (FAB and FAB.IsAvailable and FAB.IsAvailable()) then return false end

    if profile.frames.pyramidLayoutEnabled == true and Frames and Frames.SetPyramidLayoutEnabled then
        Frames.saved = profile.frames
        Frames.SetPyramidLayoutEnabled(false, true)
    end

    local f = profile.frames
    local c = profile.combat
    local fabSettings = FAB and FAB.GetSettings and FAB.GetSettings()

    -- Dark Souls + Action Bar is a layout preset, not a global combat-feature
    -- disable. Restore the recommended combat defaults so warnings/trackers do
    -- not stay off after switching away from the minimal Dark Souls preset.
    applyRecommendedCombatDefaults(c)

    -- Same Dark Souls player presentation as the no-action-bar preset,
    -- but keep the external Fancy Action Bar and place one long Health bar above it.
    f.fullDarkSoulsMode = false
    applySharedDarkSoulsTopLeftDefaults(f)
    f.dsSelfHealthBar = false
    f.dsSelfResourceBars = false
    f.dsBottomOnly = false
    f.dsEnemyHealthMode = "only"
    f.dsEnemyTrackReticle = true
    f.dsEnemyX = 0
    f.dsEnemyBottomOffset = DS_ACTIONBAR_ENEMY_BOTTOM
    f.dsEnemyWidth = 988
    f.dsEnemyHeight = 18
    f.dsBottomX = 0
    f.dsBottomOffset = DS_ACTIONBAR_ENEMY_BOTTOM
    f.dsBottomGap = 8
    f.hideActionBar = false
    f.combatOnly = true
    f.hideChampionProgress = true
    f.hideChampionProgressInPvp = false
    f.autoHideChat = true
    f.chatVisibilityMode = "hide"
    f.compassVisibilityMode = "hide"
    f.questTrackerVisibilityMode = "hide"
    f.queueStatusVisibilityMode = "hide"

    c.hideNativeOverheadHealthBars = true
    c.hideDefaultTargetFrame = true
    c.hideLUIETargetFrame = true

    applyDarkSoulsActionBarExactFabSettings(fabSettings)

    lockFancyActionBarEditing()
    U.ApplyFullDarkSoulsAuxVisibility(false)
    if Frames then
        Frames.saved = f
        if Frames.ApplyChatVisibilityMode then Frames.ApplyChatVisibilityMode()
        elseif Frames.ApplyAutoHideChat then Frames.ApplyAutoHideChat() end
        Frames.SetDSBottomOnly(false, true)
        Frames.SetDSSelfResourceBars(false, true)
        Frames.SetDSSelfHealthBar(false, true)
        Frames.SetDarkSoulsMode(true, true)
        Frames.SetShowDSUltimate(true, true)
        Frames.SetDSEnemyHealthMode("only", true)
        Frames.dsEnemyGeometrySignature = nil
        Frames.ApplySavedLayoutDirect("Dark Souls + Action Bar preset", true)
        if Frames.ApplyBarGeometry then Frames.ApplyBarGeometry() end
        if Frames.ApplyDarkSoulsHealthStyle then Frames.ApplyDarkSoulsHealthStyle() end
        if Frames.SetDarkSoulsResourceTextHidden then Frames.SetDarkSoulsResourceTextHidden(true) end
        if Frames.AnchorAllBarsToSavedPositions then Frames.AnchorAllBarsToSavedPositions() end
        if Frames.UpdateDSUltimateControl then Frames.UpdateDSUltimateControl() end
        Frames.RestoreActionBarVisibility()
        Frames.RefreshDSEnemyHealthRuntime()
        Frames.RefreshUiVisibilityRules()
    end

    if Combat then
        Combat.sv = c
        if Combat.SetHideNativeOverheadHealthBars then Combat.SetHideNativeOverheadHealthBars(true, true)
        elseif Combat.SetNativeOverheadTargetBar then Combat.SetNativeOverheadTargetBar(false) end
        if Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
        if Combat.ApplyLUIETargetFrameVisibility then Combat.ApplyLUIETargetFrameVisibility() end
        if Combat.RefreshDisplay then Combat.RefreshDisplay() end
        if Combat.UpdateCombatTimers then Combat.UpdateCombatTimers() end
        if Combat.UpdatePlayerAuraHud then Combat.UpdatePlayerAuraHud() end
        if Combat.UpdateImportantTargetDebuffs then Combat.UpdateImportantTargetDebuffs() end
        if Combat.UpdateLiveStatWidgets then Combat.UpdateLiveStatWidgets(true) end
        if Combat.UpdateMajorBreachDisplay then Combat.UpdateMajorBreachDisplay() end
        if Combat.UpdateFoodWarning then Combat.UpdateFoodWarning() end
        if Combat.UpdateMajorResolveWarning then Combat.UpdateMajorResolveWarning() end
        if Combat.UpdatePvpHud then Combat.UpdatePvpHud(false) end
    end

    zo_callLater(function()
        local fab = FAB
        if fab and fab.GetSettings and fab.GetSettings() then
            local isGamepad = fab.style == 2
            local targetScale = isGamepad and DS_ACTIONBAR_GP_SCALE or DS_ACTIONBAR_KB_SCALE
            local targetX = isGamepad and DS_ACTIONBAR_GP_X or DS_ACTIONBAR_KB_X
            local targetY = isGamepad and DS_ACTIONBAR_GP_Y or DS_ACTIONBAR_KB_Y

            if fab.constants and fab.constants.abScale then
                fab.constants.abScale.enable = true
                fab.constants.abScale.scale = targetScale
            end
            if fab.constants and fab.constants.move then
                fab.constants.move.enable = true
                fab.constants.move.x = targetX
                fab.constants.move.y = targetY
            end
            if fab.SetScale then fab.SetScale() end
            if fab.SetWholeActionBarPosition then fab.SetWholeActionBarPosition(targetX, targetY) end
            if fab.ApplyCombatOnlyVisibility then fab.ApplyCombatOnlyVisibility(false) end
        elseif not silent then
            chat("Dark Souls + Action Bar could not position Fancy Action Bar+. Confirm the standalone addon is enabled.")
        end

        -- These are the exact user-approved printed values for this preset.
        f.dsEnemyBottomOffset = DS_ACTIONBAR_ENEMY_BOTTOM
        f.dsBottomOffset = DS_ACTIONBAR_ENEMY_BOTTOM
        if Frames then
            Frames.saved = f
            Frames.dsEnemyGeometrySignature = nil
            Frames.RefreshDSEnemyHealthRuntime()
            Frames.RefreshDSSelfHealthRuntime()
        end
        U.RequestSettingsSave(true)
    end, 80)

    if CALLBACK_MANAGER and U.panel then
        CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
    end
    if not silent then
        chat("Dark Souls + Action Bar preset applied: top-left player bars + Ultimate, Fancy Action Bar, and a centered thin enemy Health bar above it.")
    end
    U.FinalizePresetEditingState()
    return true
end

function U.GetLayoutPositioningLines()
    local lines = {}
    if Frames and Frames.GetLayoutPositioningLines then
        local frameLines = Frames.GetLayoutPositioningLines()
        for _, line in ipairs(frameLines or {}) do
            lines[#lines + 1] = line
        end
    elseif Frames and Frames.PrintLayoutPositioning then
        lines[#lines + 1] = "FRAME POSITION DATA UNAVAILABLE IN COMPACT MODE"
    end

    local profile = U.GetActiveProfile()
    local settings = (FAB and FAB.GetSettings and FAB.GetSettings())
    if settings then
        local kb = settings.abMove and settings.abMove.kb or {}
        local gp = settings.abMove and settings.abMove.gp or {}
        local kbScale = settings.abScaling and settings.abScaling.kb or {}
        local gpScale = settings.abScaling and settings.abScaling.gp or {}
        lines[#lines + 1] = string.format(
            "FAB SAVED kb=(%.1f,%.1f enable=%s scale=%s) gp=(%.1f,%.1f enable=%s scale=%s) combatOnly=%s activeBarTop=%s staticBars=%s",
            tonumber(kb.x) or 0, tonumber(kb.y) or 0, tostring(kb.enable == true), tostring(kbScale.scale or "?"),
            tonumber(gp.x) or 0, tonumber(gp.y) or 0, tostring(gp.enable == true), tostring(gpScale.scale or "?"),
            tostring(profile and profile.frames and profile.frames.combatOnly == true), tostring(settings.activeBarTop == true), tostring(settings.staticBars == true)
        )
        local fab = FAB
        if fab and fab.GetWholeActionBarPosition then
            local actualX, actualY = fab.GetWholeActionBarPosition()
            local scale = 1
            local actionBar = GetControl and GetControl("ZO_ActionBar1") or ZO_ActionBar1
            if actionBar and actionBar.GetScale then scale = tonumber(actionBar:GetScale()) or 1 end
            if fab.GetWholeActionBarVisualBounds then
                local left, top, right, bottom = fab.GetWholeActionBarVisualBounds()
                lines[#lines + 1] = string.format(
                    "FAB ACTUAL root=(%.1f,%.1f) scale=%.3f visual=(%.1f,%.1f)-(%.1f,%.1f) visualCenter=(%.1f,%.1f)",
                    tonumber(actualX) or 0, tonumber(actualY) or 0, scale,
                    tonumber(left) or 0, tonumber(top) or 0, tonumber(right) or 0, tonumber(bottom) or 0,
                    ((tonumber(left) or 0) + (tonumber(right) or 0)) / 2,
                    ((tonumber(top) or 0) + (tonumber(bottom) or 0)) / 2
                )
            else
                lines[#lines + 1] = string.format("FAB ACTUAL root=(%.1f,%.1f) scale=%.3f", tonumber(actualX) or 0, tonumber(actualY) or 0, scale)
            end
        else
            lines[#lines + 1] = "FAB ACTUAL unavailable until Fancy Action Bar is active"
        end
    else
        lines[#lines + 1] = "FAB SAVED unavailable"
    end

    lines[#lines + 1] = string.format("PROFILE accountWide=%s version=%s", tostring(U.IsUsingAccountWideSettings()), tostring(U.version))
    return lines
end


local function exportEscapeString(value)
    value = tostring(value or "")
    value = value:gsub("\\", "\\\\")
    value = value:gsub("\r", "\\r")
    value = value:gsub("\n", "\\n")
    value = value:gsub("\t", "\\t")
    value = value:gsub('"', '\\"')
    return '"' .. value .. '"'
end

local function exportKeySort(a, b)
    local ta, tb = type(a), type(b)
    if ta == tb then
        if ta == "number" then return a < b end
        return tostring(a) < tostring(b)
    end
    if ta == "number" then return true end
    if tb == "number" then return false end
    return ta < tb
end

local function exportKeyText(key)
    if type(key) == "string" and key:match("^[%a_][%w_]*$") then
        return key
    end
    if type(key) == "number" then
        return "[" .. tostring(key) .. "]"
    end
    return "[" .. exportEscapeString(key) .. "]"
end

local function serializeSettingValue(value, indent, seen)
    local valueType = type(value)
    if valueType == "nil" then return "nil" end
    if valueType == "boolean" or valueType == "number" then return tostring(value) end
    if valueType == "string" then return exportEscapeString(value) end
    if valueType ~= "table" then return exportEscapeString("<" .. valueType .. ">") end

    if seen[value] then return exportEscapeString("<cycle>") end
    seen[value] = true

    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys, exportKeySort)

    if #keys == 0 then
        seen[value] = nil
        return "{}"
    end

    local childIndent = indent .. "  "
    local lines = { "{" }
    for _, key in ipairs(keys) do
        lines[#lines + 1] = childIndent .. exportKeyText(key) .. " = " .. serializeSettingValue(value[key], childIndent, seen) .. ","
    end
    lines[#lines + 1] = indent .. "}"
    seen[value] = nil
    return table.concat(lines, "\n")
end

local COMBAT_EXPORT_RUNTIME_KEYS = {
    abilityId = true,
    learnedName = true,
    kjalnarSetId = true,
    nativeSettingsCaptured = true,
    nativeOriginalAllHealthbars = true,
    nativeOriginalAllNameplates = true,
    nativeOriginalEnemyNpcHealthbars = true,
    nativeOriginalEnemyPlayerHealthbars = true,
    nativeOriginalEnemyNpcNameplates = true,
    nativeOriginalEnemyPlayerNameplates = true,
    nativeOriginalFriendlyNpcNameplates = true,
    nativeOriginalNeutralNpcNameplates = true,
    pvpKills = true,
    pvpDeaths = true,
    pvpSessionKey = true,
    pvpSessionActive = true,
}

local function buildSettingsExportProfile(profile)
    local combat = deepCopy(profile.combat or {})
    for key in pairs(COMBAT_EXPORT_RUNTIME_KEYS) do combat[key] = nil end

    local fab = deepCopy(profile.fab or {})
    if fab.settings then
        -- FAB can retain a full copy of its upstream default table inside the
        -- live SavedVariables. That is not a user preference and previously
        -- duplicated thousands of characters in the export, causing copied
        -- reports to be cut off before Frames and Sound were reached.
        fab.settings.default = nil
    end
    if fab.character then
        fab.character.default = nil
    end

    return {
        combat = combat,
        frames = deepCopy(profile.frames or {}),
        sound = deepCopy(profile.sound or {}),
        fab = fab,
    }
end

function U.GetAllSettingsExportText()
    local profile = U.GetActiveProfile() or {}
    local export = {
        addonVersion = U.version,
        profileScope = U.IsUsingAccountWideSettings() and "account-wide" or "character",
        world = GetWorldName and GetWorldName() or "unknown",
        character = GetUnitName and GetUnitName("player") or "unknown",
        settings = buildSettingsExportProfile(profile),
    }

    return table.concat({
        "ULTIVITE ALL SETTINGS EXPORT BEGIN",
        serializeSettingValue(export, "", {}),
        "ULTIVITE ALL SETTINGS EXPORT END",
    }, "\n")
end

function U.PrintAllSettings()
    local text = U.GetAllSettingsExportText()
    chat("Printing complete active Ultivite settings export to chat.")
    for line in text:gmatch("[^\n]+") do
        d(line)
    end
    chat("Settings export complete. Use Show / Copy All Settings for a selectable Ctrl+C window.")
end

function U.ShowAllSettingsExport()
    local window = U.settingsExportWindow
    if not window then
        window = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteSettingsExportWindow")
        window:SetDimensions(1040, 640)
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        window:SetDrawTier(DT_HIGH)
        window:SetDrawLayer(DL_OVERLAY)
        window:SetDrawLevel(5100)
        window:SetMouseEnabled(true)
        window:SetHidden(true)

        local backdrop = WINDOW_MANAGER:CreateControl("UltiviteSettingsExportBackdrop", window, CT_BACKDROP)
        backdrop:SetAnchorFill(window)
        backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
        backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.98)
        backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
        backdrop:SetEdgeColor(0.35, 0.35, 0.35, 1)

        local title = WINDOW_MANAGER:CreateControl("UltiviteSettingsExportTitle", window, CT_LABEL)
        title:SetFont("ZoFontWinH2")
        title:SetText("Ultivite All Settings Export")
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 18)

        local help = WINDOW_MANAGER:CreateControl("UltiviteSettingsExportHelp", window, CT_LABEL)
        help:SetFont("ZoFontGame")
        help:SetText("Every configurable setting in the active Ultivite profile is selected below. Runtime counters and duplicate internal default snapshots are omitted so the export stays complete. Press Ctrl+C to copy it.")
        help:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
        help:SetDimensions(990, 44)

        local edit = WINDOW_MANAGER:CreateControl("UltiviteSettingsExportEdit", window, CT_EDITBOX)
        edit:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 94)
        edit:SetDimensions(992, 472)
        edit:SetFont("ZoFontGame")
        edit:SetMultiLine(true)
        edit:SetNewLineEnabled(true)
        edit:SetEditEnabled(true)
        edit:SetCopyEnabled(true)
        edit:SetPasteEnabled(false)
        edit:SetMaxInputChars(200000)
        edit:SetSelectAllOnFocus(true)
        edit:SetColor(1, 1, 1, 1)
        edit:SetHandler("OnEscape", function()
            edit:LoseFocus()
            window:SetHidden(true)
        end)

        local printButton = WINDOW_MANAGER:CreateControl("UltiviteSettingsExportPrint", window, CT_BUTTON)
        printButton:SetDimensions(220, 36)
        printButton:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 24, -18)
        printButton:SetFont("ZoFontGameBold")
        printButton:SetText("Print to Chat")
        printButton:SetHandler("OnClicked", function() U.PrintAllSettings() end)

        local close = WINDOW_MANAGER:CreateControl("UltiviteSettingsExportClose", window, CT_BUTTON)
        close:SetDimensions(180, 36)
        close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -24, -18)
        close:SetFont("ZoFontGameBold")
        close:SetText("Close")
        close:SetHandler("OnClicked", function()
            edit:LoseFocus()
            window:SetHidden(true)
        end)

        window.edit = edit
        U.settingsExportWindow = window
    end

    window.edit:SetText(U.GetAllSettingsExportText())
    window:SetHidden(false)
    zo_callLater(function()
        if window and window.edit and not window:IsHidden() then
            window.edit:TakeFocus()
            window.edit:SelectAll()
        end
    end, 20)
end

function U.GetLayoutPositioningText()
    local lines = { "ULTIVITE LAYOUT REPORT BEGIN" }
    for _, line in ipairs(U.GetLayoutPositioningLines()) do
        lines[#lines + 1] = line
    end
    lines[#lines + 1] = "ULTIVITE LAYOUT REPORT END"
    return table.concat(lines, "\n")
end

function U.ShowPositionsForGPT()
    return U.ShowLayoutReport()
end

function U.PrintLayoutPositioning()
    for _, line in ipairs(U.GetLayoutPositioningLines()) do
        chat("LAYOUT " .. line)
    end
    chat("Use Show Layout Report in Advanced & Support to open the complete layout in one selectable text box.")
end

function U.ShowLayoutReport()
    local window = U.layoutCopyWindow
    if not window then
        window = WINDOW_MANAGER:CreateTopLevelWindow("UltiviteLayoutCopyWindow")
        window:SetDimensions(980, 560)
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        window:SetDrawTier(DT_HIGH)
        window:SetDrawLayer(DL_OVERLAY)
        window:SetDrawLevel(5000)
        window:SetMouseEnabled(true)
        window:SetHidden(true)

        local backdrop = WINDOW_MANAGER:CreateControl("UltiviteLayoutCopyBackdrop", window, CT_BACKDROP)
        backdrop:SetAnchorFill(window)
        backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
        backdrop:SetCenterColor(0.02, 0.02, 0.02, 0.98)
        backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2, 0)
        backdrop:SetEdgeColor(0.35, 0.35, 0.35, 1)

        local title = WINDOW_MANAGER:CreateControl("UltiviteLayoutCopyTitle", window, CT_LABEL)
        title:SetFont("ZoFontWinH2")
        title:SetText("Ultivite Layout Report")
        title:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 18)

        local help = WINDOW_MANAGER:CreateControl("UltiviteLayoutCopyHelp", window, CT_LABEL)
        help:SetFont("ZoFontGame")
        help:SetText("The complete current layout is selected below. Press Ctrl+C to copy it for troubleshooting or support.")
        help:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)

        local edit = WINDOW_MANAGER:CreateControl("UltiviteLayoutCopyEdit", window, CT_EDITBOX)
        edit:SetAnchor(TOPLEFT, window, TOPLEFT, 24, 82)
        edit:SetDimensions(932, 410)
        edit:SetFont("ZoFontGame")
        edit:SetMultiLine(true)
        edit:SetNewLineEnabled(true)
        edit:SetEditEnabled(true)
        edit:SetCopyEnabled(true)
        edit:SetPasteEnabled(false)
        edit:SetMaxInputChars(10000)
        edit:SetSelectAllOnFocus(true)
        edit:SetColor(1, 1, 1, 1)
        edit:SetHandler("OnEscape", function()
            edit:LoseFocus()
            window:SetHidden(true)
        end)

        local close = WINDOW_MANAGER:CreateControl("UltiviteLayoutCopyClose", window, CT_BUTTON)
        close:SetDimensions(180, 36)
        close:SetAnchor(BOTTOM, window, BOTTOM, 0, -18)
        close:SetFont("ZoFontGameBold")
        close:SetText("Close")
        close:SetHandler("OnClicked", function()
            edit:LoseFocus()
            window:SetHidden(true)
        end)

        window.edit = edit
        U.layoutCopyWindow = window
    end

    window.edit:SetText(U.GetLayoutPositioningText())
    window:SetHidden(false)
    zo_callLater(function()
        if window and window.edit and not window:IsHidden() then
            window.edit:TakeFocus()
            window.edit:SelectAll()
        end
    end, 20)
end

function U.SetAccountWideSettings(enabled, silent)
    enabled = enabled and true or false
    if U.IsUsingAccountWideSettings() == enabled then return end

    -- Capture what the player is actually seeing before changing ownership.
    -- This avoids carrying a stale wrapper table into the newly selected scope.
    local snapshot = U.CaptureLiveProfileSnapshot()
    local destination = enabled and U.accountSV or U.characterSV
    U.WriteSnapshotToProfile(snapshot, destination)
    U.accountSV.useAccountWide = enabled
    if enabled then
        U.accountSV.profileSyncRevision = (tonumber(U.accountSV.profileSyncRevision) or 0) + 1
        U.characterSV.profileSyncRevision = U.accountSV.profileSyncRevision
    end

    U.EnsureProfiles()
    U.RequestSettingsSave(true)

    if not silent then
        if enabled then
            chat("Account-wide settings enabled. Current live Ultivite settings were copied into the shared profile.")
        else
            chat("Character settings enabled. Current live Ultivite settings were copied into this character profile.")
        end
    end

    zo_callLater(function()
        if ReloadUI then ReloadUI() end
    end, 500)
end

function U.MigrateLegacySettings()
    local current = tonumber(U.accountSV.migrationVersion) or 0
    local startingMigrationVersion = current
    local legacyLayoutPresent = false

    if current < 1 then
        local combatDefaults = Combat.defaults or {}
        local frameDefaults = Frames.defaults or {}
        local soundDefaults = Sound.defaults or {}

        local oldCombatAccount = ZO_SavedVars:NewAccountWide("KjalnarStacksSavedVariables", 1, nil, combatDefaults)
        local oldCombatCharacter = ZO_SavedVars:NewCharacterIdSettings("KjalnarStacksSavedVariables", 1, nil, combatDefaults)
        local oldCombatScope = ZO_SavedVars:NewCharacterIdSettings("KjalnarStacksProfileSavedVariables", 1, nil, { useAccountWide = true })
        local oldCombatActive = (oldCombatScope.useAccountWide ~= false) and oldCombatAccount or oldCombatCharacter

        local oldFrameAccount = ZO_SavedVars:NewAccountWide("VanillaFrameMoverSavedVariables", 1, nil, frameDefaults, GetWorldName())
        local oldFrameCharacter = ZO_SavedVars:NewCharacterIdSettings("VanillaFrameMoverCharacterSavedVariables", 1, nil, frameDefaults, GetWorldName())
        local oldFrameActive = (oldFrameAccount.useAccountWide ~= false) and oldFrameAccount or oldFrameCharacter
        -- Vanilla Frame Mover increments persistenceLoadCount when it has actually
        -- been used. A nonzero value means there is a legacy layout to preserve.
        if (tonumber(oldFrameAccount.persistenceLoadCount) or 0) > 0
            or (tonumber(oldFrameCharacter.persistenceLoadCount) or 0) > 0 then
            legacyLayoutPresent = true
        end

        local oldSound = ZO_SavedVars:NewAccountWide("SoundSuppressorSavedVariables", 1, nil, soundDefaults)

        copyKnownSettings(oldCombatActive, U.accountSV.combat, combatDefaults)
        copyKnownSettings(oldFrameActive, U.accountSV.frames, frameDefaults)
        copyKnownSettings(oldSound, U.accountSV.sound, soundDefaults)

        copyKnownSettings(oldCombatCharacter, U.characterSV.combat, combatDefaults)
        copyKnownSettings(oldFrameCharacter, U.characterSV.frames, frameDefaults)
        copyKnownSettings(oldSound, U.characterSV.sound, soundDefaults)

        current = 1
        U.accountSV.useAccountWide = true
    end

    if current < 2 and FAB then
        local fabDefaults = FAB.defaultSettings or {}
        local fabCharacterDefaults = FAB.defaultCharacter or {}
        local oldFabAccount = ZO_SavedVars:NewAccountWide("FancyActionBarSV", 1, nil, fabDefaults, GetWorldName())
        local oldFabCharacter = ZO_SavedVars:NewCharacterIdSettings("FancyActionBarSV", 1, nil, fabCharacterDefaults, GetWorldName())

        local oldKbMove = oldFabAccount and oldFabAccount.abMove and oldFabAccount.abMove.kb
        local oldGpMove = oldFabAccount and oldFabAccount.abMove and oldFabAccount.abMove.gp
        local function moveLooksCustomized(move, defaultY)
            if type(move) ~= "table" then return false end
            return move.enable == true
                or math.abs((tonumber(move.x) or 0) - 0) > 0.01
                or math.abs((tonumber(move.y) or defaultY) - defaultY) > 0.01
        end
        if moveLooksCustomized(oldKbMove, -22) or moveLooksCustomized(oldGpMove, -75) then
            legacyLayoutPresent = true
        end

        local function migrateFabInto(profile)
            profile.fab = profile.fab or {}
            if profile.fab.enabled == nil then profile.fab.enabled = true end
            profile.fab.sourceVersion = "2.19.6"
            profile.fab.settings = deepCopy(oldFabAccount or {})
            profile.fab.character = deepCopy(oldFabCharacter or {})
            -- Historical migration from early Ultivite builds: capture the
            -- active character-specific FAB ability/effect values into the legacy
            -- Ultivite snapshot. Version 1.0.71 later migrates that snapshot back
            -- into the separately installed FAB+ addon.
            if oldFabCharacter and oldFabCharacter.useAccountWide == false then
                for key in pairs(fabCharacterDefaults) do
                    if key ~= "useAccountWide" and oldFabCharacter[key] ~= nil then
                        profile.fab.settings[key] = deepCopy(oldFabCharacter[key])
                    end
                end
            end
            fillDefaults(profile.fab.settings, fabDefaults)
            fillDefaults(profile.fab.character, fabCharacterDefaults)
            profile.fab.character.useAccountWide = true
        end

        migrateFabInto(U.accountSV)
        migrateFabInto(U.characterSV)
        current = 2
    end

    if current < 3 then
        local function nearlyEqual(a, b)
            return math.abs((tonumber(a) or 0) - b) < 0.0001
        end

        local function upgradeUntouchedFrameDefaults(profile)
            local f = profile and profile.frames
            if not f then return end
            local oldDefaultLayout = nearlyEqual(f.barWidth, 1.35)
                and nearlyEqual(f.barThickness, 1.97)
                and nearlyEqual(f.healthX, 0) and nearlyEqual(f.healthY, 644)
                and nearlyEqual(f.magickaX, -511) and nearlyEqual(f.magickaY, 644)
                and nearlyEqual(f.staminaX, 504) and nearlyEqual(f.staminaY, 644)
            if oldDefaultLayout then
                f.barWidth = 1.755
                f.barThickness = 2.561
            end
        end

        local function upgradeUntouchedFabDefaults(profile)
            local settings = profile and profile.fab and profile.fab.settings
            if not settings then return end
            local kb = settings.abScaling and settings.abScaling.kb
            local gp = settings.abScaling and settings.abScaling.gp
            local kbMove = settings.abMove and settings.abMove.kb
            local gpMove = settings.abMove and settings.abMove.gp

            -- Only replace the upstream 2.19.6 presentation defaults. If the
            -- player already changed scale or moved the bar, keep their layout.
            local untouchedScale = kb and gp
                and kb.enable ~= true and nearlyEqual(kb.scale, 100)
                and gp.enable ~= true and nearlyEqual(gp.scale, 100)
            if untouchedScale then
                kb.enable, kb.scale = true, 122
                gp.enable, gp.scale = true, 122
            end

            local untouchedMove = kbMove and gpMove
                and kbMove.enable ~= true and nearlyEqual(kbMove.x, 0) and nearlyEqual(kbMove.y, -22)
                and gpMove.enable ~= true and nearlyEqual(gpMove.x, 0) and nearlyEqual(gpMove.y, -75)
            if untouchedMove then
                settings.ultiviteCenterVersion = nil
            else
                settings.ultiviteCenterVersion = settings.ultiviteCenterVersion or 1
            end

            local untouchedPresentation = untouchedScale and untouchedMove
                and settings.staticBars == true
                and settings.hideLockedBar == true
                and settings.showHotkeys == true
                and settings.alphaInactive == 20
            if untouchedPresentation then
                settings.staticBars = true
                settings.hideLockedBar = false
                settings.showHotkeys = false
                settings.alphaInactive = 100
            end
            if settings.combatOnly == nil then settings.combatOnly = true end
        end

        for _, profile in ipairs({ U.accountSV, U.characterSV }) do
            upgradeUntouchedFrameDefaults(profile)
            upgradeUntouchedFabDefaults(profile)
        end
        current = 3
    end

    if current < 4 then
        local function nearlyEqual(a, b)
            return math.abs((tonumber(a) or 0) - b) < 0.0001
        end

        local function markUntouchedLayout(profile)
            local f = profile and profile.frames
            if not f then return end

            -- 1.0.22 still used these original fixed coordinates. Only profiles
            -- that exactly match the untouched layout are automatically moved.
            local untouched = nearlyEqual(f.healthX, 0) and nearlyEqual(f.healthY, 644)
                and nearlyEqual(f.magickaX, -511) and nearlyEqual(f.magickaY, 644)
                and nearlyEqual(f.staminaX, 504) and nearlyEqual(f.staminaY, 644)
                and nearlyEqual(f.barWidth, 1.755)
                and nearlyEqual(f.barThickness, 2.561)

            local settings = profile and profile.fab and profile.fab.settings
            local kbMove = settings and settings.abMove and settings.abMove.kb
            local gpMove = settings and settings.abMove and settings.abMove.gp
            local untouchedFabMove = settings and kbMove and gpMove
                and kbMove.enable ~= true and nearlyEqual(kbMove.x, 0) and nearlyEqual(kbMove.y, -22)
                and gpMove.enable ~= true and nearlyEqual(gpMove.x, 0) and nearlyEqual(gpMove.y, -75)

            if untouched and untouchedFabMove and startingMigrationVersion == 0 then
                f.compactGap = 24
                f.bottomMargin = 8
                f.ultiviteDefaultLayoutPending = true
            end
        end

        for _, profile in ipairs({ U.accountSV, U.characterSV }) do
            markUntouchedLayout(profile)
        end
        current = 4
    end

    if current < 5 then
        local function upgradeWashedOutFabDefault(profile)
            local settings = profile and profile.fab and profile.fab.settings
            if not settings then return end

            -- Ultivite 1.0.22-1.0.27 made the inactive row fully opaque but
            -- accidentally retained FAB+'s 50%% inactive desaturation. Upgrade
            -- only that exact Ultivite presentation so deliberately customized
            -- FAB colour/desaturation settings are preserved.
            local tint = settings.tintInactive
            local whiteTint = type(tint) == "table"
                and math.abs((tonumber(tint[1]) or 0) - 1) < 0.0001
                and math.abs((tonumber(tint[2]) or 0) - 1) < 0.0001
                and math.abs((tonumber(tint[3]) or 0) - 1) < 0.0001
            if settings.alphaInactive == 100
                and settings.desaturationInactive == 50
                and whiteTint then
                settings.desaturationInactive = 0
            end
        end

        for _, profile in ipairs({ U.accountSV, U.characterSV }) do
            upgradeWashedOutFabDefault(profile)
        end
        current = 5
    end

    if current < 6 then
        -- Only a genuinely unmigrated/fresh profile gets the approved default
        -- layout automatically. Existing Ultivite users keep every saved position.
        if startingMigrationVersion == 0 and not legacyLayoutPresent then
            local profile = U.GetActiveProfile()
            if profile and profile.frames then
                profile.frames.defaultSettingRevertPending = true
            end
        end
        current = 6
    end

    if current < 7 then
        -- 1.0.41 makes combat visibility one master HUD setting. Preserve the
        -- user's existing intent: if either the player bars or FAB was already
        -- combat-only, make the combined HUD combat-only. If both were always
        -- visible, keep the combined HUD always visible.
        for _, profile in ipairs({ U.accountSV, U.characterSV }) do
            local f = profile and profile.frames
            local fabSettings = profile and profile.fab and profile.fab.settings
            if f then
                local unified = (f.combatOnly == true) or (fabSettings and fabSettings.combatOnly == true) or false
                f.combatOnly = unified
            end
        end
        current = 7
    end

    if current < 8 then
        -- 1.0.71 removes the bundled FAB+ copy. Preserve the user's existing
        -- Ultivite action-bar setup by migrating that saved snapshot once into
        -- the separately installed Fancy Action Bar+ SavedVariables.
        local profile = U.GetActiveProfile()
        if FAB and FAB.ApplyProfileSnapshot and profile and profile.fab then
            FAB.ApplyProfileSnapshot(profile.fab)
            if FAB.SetUseAccountWide and profile.fab.character then
                FAB.SetUseAccountWide(profile.fab.character.useAccountWide ~= false)
            end
        end
        current = 8
    end

    if current < 9 then
        -- 1.0.130 separates Target Frame Mode from enemy overhead Health bars.
        -- 1.0.129's ENEMY HEALTH BARS -> VANILLA path temporarily changed the
        -- target-frame flags as well; restore that saved pre-cycle state once.
        for _, profile in ipairs({ U.accountSV, U.characterSV }) do
            local c = profile and profile.combat
            local f = profile and profile.frames
            if c then
                if c.quickMenuEnemyHealthSavedTargetFrame ~= nil then
                    local savedTargetFrame = c.quickMenuEnemyHealthSavedTargetFrame == true
                    c.targetFrame = savedTargetFrame
                    if savedTargetFrame then c.hideDefaultTargetFrame = true end
                    c.targetFrameMode = savedTargetFrame and "ultivite" or "vanilla"
                    c.quickMenuEnemyHealthSavedTargetFrame = nil
                else
                    -- Existing pre-1.0.130 profiles receive the new default field
                    -- during SavedVariables default merging, so derive from the
                    -- legacy frame state unconditionally during this migration.
                    local dsEnemyOff = not f or tostring(f.dsEnemyHealthMode or "off") == "off"
                    local looksVanilla = c.targetFrame == false and c.hideDefaultTargetFrame ~= true and dsEnemyOff
                    c.targetFrameMode = looksVanilla and "vanilla" or "ultivite"
                end
            end
        end
        current = 9
    end

    U.accountSV.migrationVersion = math.max(current, U.migrationVersion)
    U.RequestSettingsSave(true)
end

local function removeLegacyProfileControls(options, moduleName)
    local cleaned = {}
    local skippingProfile = false
    local firstDescriptionRemoved = false
    for _, option in ipairs(options or {}) do
        local name = type(option) == "table" and option.name or nil
        local text = type(option) == "table" and option.text or nil

        if moduleName == "combat" and name == "Settings profile" then
            skippingProfile = true
        elseif moduleName == "frames" and name == "Settings scope" then
            skippingProfile = true
        elseif skippingProfile then
            local stop = false
            if moduleName == "combat" and (name == "Position and size" or name == "Target Frame — Position & Size") then stop = true end
            if moduleName == "frames" and (name == "Visibility" or name == "General Visibility") then stop = true end
            if stop then
                skippingProfile = false
                cleaned[#cleaned + 1] = option
            end
        else
            local isDescription = type(option) == "table" and option.type == "description"
            local redundantProfileText = moduleName == "frames" and type(text) == "string" and text:find("Profile switching preserves", 1, true)
            if isDescription and not firstDescriptionRemoved then
                firstDescriptionRemoved = true
            elseif not redundantProfileText then
                cleaned[#cleaned + 1] = option
            end
        end
    end
    return cleaned
end

local function removeFirstDescription(options)
    local cleaned = {}
    local removed = false
    for _, option in ipairs(options or {}) do
        if not removed and type(option) == "table" and option.type == "description" then
            removed = true
        else
            cleaned[#cleaned + 1] = option
        end
    end
    return cleaned
end

local function appendAll(destination, source)
    for _, item in ipairs(source or {}) do destination[#destination + 1] = item end
end

local function removeDescriptionOptionsRecursive(options)
    local cleaned = {}
    for _, option in ipairs(options or {}) do
        if type(option) == "table" then
            if option.type ~= "description" then
                if type(option.controls) == "table" then
                    option.controls = removeDescriptionOptionsRecursive(option.controls)
                end
                cleaned[#cleaned + 1] = option
            end
        else
            cleaned[#cleaned + 1] = option
        end
    end
    return cleaned
end

local function findOptionByName(options, wantedName)
    for _, option in ipairs(options or {}) do
        if type(option) == "table" then
            if option.name == wantedName then
                return option
            end
            if type(option.controls) == "table" then
                local nested = findOptionByName(option.controls, wantedName)
                if nested then return nested end
            end
        end
    end
    return nil
end

local function addIfPresent(destination, option)
    if option then destination[#destination + 1] = option end
end

local function removeNamedOptionRecursive(options, names)
    local cleaned = {}
    for _, option in ipairs(options or {}) do
        local keep = true
        if type(option) == "table" then
            local optionName = tostring(option.name or "")
            if names[optionName] then
                keep = false
            else
                if type(option.controls) == "table" then
                    option.controls = removeNamedOptionRecursive(option.controls, names)
                end
            end
        end
        if keep then cleaned[#cleaned + 1] = option end
    end
    return cleaned
end

local function cleanMenuTree(options)
    local cleaned = {}
    local previousWasDivider = true
    for _, option in ipairs(options or {}) do
        if type(option) == "table" and next(option) ~= nil then
            if type(option.controls) == "table" then
                option.controls = cleanMenuTree(option.controls)
            end

            local isEmptySubmenu = option.type == "submenu" and type(option.controls) == "table" and #option.controls == 0
            local isDivider = option.type == "divider"
            if not isEmptySubmenu and not (isDivider and previousWasDivider) then
                cleaned[#cleaned + 1] = option
                previousWasDivider = isDivider
            end
        end
    end
    if #cleaned > 0 and cleaned[#cleaned].type == "divider" then
        table.remove(cleaned, #cleaned)
    end
    return cleaned
end

local function stripFabMenuColor(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

local function cleanMirroredFabOptions(options)
    local removed = {
        ["Accountwide Skill Settings"] = true,
        ["Toggle Actionbar Visibility"] = true,
        ["Actionbar Size & Position"] = true,
        ["Adjust Health Bar"] = true,
        ["Adjust Mag/Stam Bars"] = true,
        ["Adjust Player Buffs Bar"] = true,
        ["Adjust Synergy Prompt"] = true,
        ["Force UI Adjustments"] = true,
        ["Debug mode"] = true,
    }
    local friendlyNames = {
        ["General"] = "Bar Rows & Visibility",
        ["UI Customization"] = "Appearance",
        ["Timer Display"] = "Timers, Stacks & Ultimate",
        ["Gamepad UI"] = "Gamepad Timer Display",
        ["Expiration Settings (Shared)"] = "Expiry & Alert Styling",
        ["Ability Configuration"] = "Skill & Effect Tracking",
        ["Tracked Effects"] = "Tracked Skill Effects",
        ["Effect Widgets"] = "Detached Effect Widgets",
        ["Buffs Gained From others"] = "Buffs Gained From Others",
        ["Debuffs on Target"] = "Debuffs on Current Target",
        ["Additional Tracking Options"] = "Additional Tracking",
        ["Miscellaneous"] = "Other Action Bar Options",
        ["Horizonal position"] = "Horizontal position",
        ["Adjust stacks horizonatal position"] = "Stacks horizontal position",
        ["Adjust stacks vetrtical position"] = "Stacks vertical position",
        ["stacks display settings"] = "Stacks Display Settings",
        ["Quickslot display settings"] = "Quickslot Display Settings",
    }
    local cleaned = {}
    for _, option in ipairs(options or {}) do
        if type(option) == "table" then
            local plainName = stripFabMenuColor(option.name)
            if not removed[plainName] then
                if option.name then option.name = friendlyNames[plainName] or plainName end
                if type(option.controls) == "table" then
                    option.controls = cleanMirroredFabOptions(option.controls)
                end
                cleaned[#cleaned + 1] = option
            end
        else
            cleaned[#cleaned + 1] = option
        end
    end
    return cleaned
end

local function buildSimplifiedFrameOptions(raw)
    local function getHudPreset()
        local profile = Ultivite and U.GetActiveProfile and U.GetActiveProfile() or nil
        local f = profile and profile.frames or (Frames and Frames.saved)
        if not f then return "default" end

        if f.pyramidLayoutEnabled == true then return "pyramid" end
        if f.fullDarkSoulsMode == true then return "darkSouls" end

        local hasActionBarLongHealth = (f.dsEnemyHealthMode == "only")
            or (f.dsSelfHealthBar == true and f.dsSelfResourceBars ~= true and f.dsEnemyHealthMode == "off")
        if f.darkSoulsMode == true and f.hideActionBar ~= true and hasActionBarLongHealth
            and FAB and FAB.IsAvailable and FAB.IsAvailable() then
            return "darkSoulsActionBar"
        end

        local quick = Frames and Frames.GetQuickPlayerLayout and Frames.GetQuickPlayerLayout() or "normal"
        if quick == "bottomOnly" then return "darkSoulsSelf" end
        if quick == "topLeft" then return "topLeft" end
        if quick == "both" then return "both" end
        return "default"
    end

    local function setHudPreset(value)
        value = tostring(value or "default")
        if value == "pyramid" then
            if Frames and Frames.SetPyramidLayoutEnabled then
                Frames.SetPyramidLayoutEnabled(true, false)
            end
        elseif value == "darkSouls" then
            U.ApplyFullDarkSoulsPreset(false)
        elseif value == "darkSoulsActionBar" then
            U.ApplyDarkSoulsActionBarPreset(false)
        elseif value == "darkSoulsSelf" then
            U.ApplyDarkSoulsSelfPreset(false)
        elseif value == "topLeft" then
            local profile = U.GetActiveProfile()
            applyRecommendedCombatDefaults(profile and profile.combat)
            Frames.SetQuickPlayerLayout("topLeft", false)
        elseif value == "both" then
            local profile = U.GetActiveProfile()
            applyRecommendedCombatDefaults(profile and profile.combat)
            Frames.SetQuickPlayerLayout("both", false)
        else
            U.ApplyDefaultCombatHUDLayout(false)
        end

        -- Applying a preset must never be treated as entering edit mode.
        -- Movement and resize overlays are only opened by the explicit Unlock
        -- controls in their respective settings sections.
        if U.FinalizePresetEditingState then
            U.FinalizePresetEditingState()
        end

        if CALLBACK_MANAGER and Ultivite and U.panel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
        end
    end

    local presetControls = {
        {
            type = "dropdown",
            name = "HUD Preset",
            tooltip = "Ultivite Default restores the approved normal layout. Dark Souls shows the compact top-left player bars with Ultimate, hides the action bar, and uses one wide enemy Health bar at the bottom. Dark Souls + Action Bar keeps Fancy Action Bar and places the long Health bar above it.",
            choices = {
                "Ultivite Default",
                "Pyramid",
                "Dark Souls",
                "Dark Souls + Action Bar",
                "Dark Souls Self (large bottom)",
                "Dark Souls top-left only",
                "Dark Souls top-left + Self",
            },
            choicesValues = { "default", "pyramid", "darkSouls", "darkSoulsActionBar", "darkSoulsSelf", "topLeft", "both" },
            getFunc = getHudPreset,
            setFunc = setHudPreset,
            width = "full",
        },
        {
            type = "dropdown",
            name = "Long Health Bar Source",
            tooltip = "For Dark Souls + Action Bar, choose whether the long thin bar above Fancy Action Bar shows the current enemy target or your own Health.",
            choices = { "Enemy target", "Self Health" },
            choicesValues = { "enemy", "self" },
            getFunc = function() return U.GetDarkSoulsActionBarHealthSource() end,
            setFunc = function(value) U.SetDarkSoulsActionBarHealthSource(value, false) end,
            disabled = function() return getHudPreset() ~= "darkSoulsActionBar" end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Hide default overhead Health bars",
            tooltip = "Hides ESO's normal overhead Health bars. Dark Souls presets enable this automatically. Turning it off restores the ESO nameplate Health bar settings captured before Ultivite hid them.",
            getFunc = function()
                return Combat and Combat.GetHideNativeOverheadHealthBars and Combat.GetHideNativeOverheadHealthBars() or false
            end,
            setFunc = function(value)
                if Combat and Combat.SetHideNativeOverheadHealthBars then
                    Combat.SetHideNativeOverheadHealthBars(value, false)
                end
            end,
            default = false,
            width = "full",
        },
    }

    local combatOnlyOption = findOptionByName(raw, "Show bars only in combat")
    if combatOnlyOption then
        combatOnlyOption.name = "Show combat HUD only in combat"
        combatOnlyOption.tooltip = "One master switch for the player combat HUD. When enabled, Health/Magicka/Stamina bars, Dark Souls Ultimate, the Dark Souls long Health bar, and Fancy Action Bar all hide out of combat and show together in combat. Unlocking an editor temporarily shows the element being edited."
        presetControls[#presetControls + 1] = combatOnlyOption
    end
    addIfPresent(presetControls, findOptionByName(raw, "Show Ultimate beside Dark Souls bars"))

    local result = {
        presetControls[1],
        {
            type = "checkbox",
            name = "Pyramid",
            tooltip = "Reference Pyramid layout: Health centred above two smaller Magicka and Stamina bars that meet beneath it. Fancy Action Bar stays near the bottom with a protected margin below it. Turning Pyramid off restores the previous bar size and positions.",
            getFunc = function()
                local profile = Ultivite and U.GetActiveProfile and U.GetActiveProfile() or nil
                local f = profile and profile.frames or (Frames and Frames.saved)
                return f and f.pyramidLayoutEnabled == true or false
            end,
            setFunc = function(value)
                if Frames and Frames.SetPyramidLayoutEnabled then
                    Frames.SetPyramidLayoutEnabled(value == true, false)
                end
                if CALLBACK_MANAGER and Ultivite and U.panel then
                    CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
                end
            end,
            default = false,
            width = "full",
        },
        {
            type = "submenu",
            name = "Preset Options & Combat Visibility",
            tooltip = "Options that change how the selected HUD preset appears and when the complete combat HUD is visible.",
            controls = { unpack(presetControls, 2) },
        },
    }

    result[#result + 1] = { type = "header", name = "Player Bar Size & Editing" }
    addIfPresent(result, findOptionByName(raw, "Unlock bars for editing"))
    addIfPresent(result, findOptionByName(raw, "Width"))
    addIfPresent(result, findOptionByName(raw, "Thickness"))

    local positionControls = {}
    addIfPresent(positionControls, findOptionByName(raw, "Snap to grid"))
    addIfPresent(positionControls, findOptionByName(raw, "Grid size"))
    result[#result + 1] = {
        type = "submenu",
        name = "Player Bar Position Grid",
        controls = positionControls,
    }

    local textMenu = findOptionByName(raw, "Player Bar Text")
    if textMenu then
        textMenu.name = "Player Bar Text & Numbers"
        result[#result + 1] = textMenu
    end

    local function refreshUltivitePanel()
        if CALLBACK_MANAGER and U.panel then
            CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel)
        end
    end

    local function setPvpOnlyVisibility(kind, enabled)
        local current = Frames.GetUiVisibilityMode(kind)
        if enabled then
            Frames.SetUiVisibilityMode(kind, "pvp", true)
        elseif current == "pvp" then
            Frames.SetUiVisibilityMode(kind, "show", true)
        end
        refreshUltivitePanel()
    end

    local function setAlwaysHiddenVisibility(kind, enabled)
        local current = Frames.GetUiVisibilityMode(kind)
        if enabled then
            Frames.SetUiVisibilityMode(kind, "hide", true)
        elseif current == "hide" then
            Frames.SetUiVisibilityMode(kind, "show", true)
        end
        refreshUltivitePanel()
    end

    local function getFabVisibilitySettings()
        return FAB and FAB.GetSettings and FAB.GetSettings() or nil
    end

    local function getCombatVisibilitySettings()
        local profile = Ultivite and U.GetActiveProfile and U.GetActiveProfile() or nil
        return (Combat and Combat.sv) or (profile and profile.combat) or nil
    end

    local function saveVisibilityChange()
        if Ultivite and U.RequestSettingsSave then
            U.RequestSettingsSave(true)
        end
        refreshUltivitePanel()
    end

    local function refreshFabWeaponLock()
        local sv = getFabVisibilitySettings()
        if not (sv and FAB) then return end
        if FAB.OnWeaponSwapLocked then
            local locked = false
            if GetActiveWeaponPairInfo then
                local _, currentLocked = GetActiveWeaponPairInfo()
                locked = currentLocked and true or false
            end
            FAB.OnWeaponSwapLocked(locked, nil, true, sv.hideLockedBar)
        end
        if FAB.RefreshRuntime then FAB.RefreshRuntime() end
    end

    local function refreshFabLayout()
        if FAB and FAB.RefreshRuntime then
            FAB.RefreshRuntime()
        elseif FAB and FAB.UpdateBarSettings then
            FAB.UpdateBarSettings(nil)
        elseif FAB and FAB.RefreshHotbarPresentation then
            FAB.RefreshHotbarPresentation(nil, true)
        end
    end

    local function setCombatVisibilityFlag(key, value, applyFunc)
        local sv = getCombatVisibilitySettings()
        if not sv then return end
        sv[key] = value and true or false
        if applyFunc then applyFunc(sv[key]) end
        saveVisibilityChange()
    end

    -- Direct mirrors of ESO's own Interface and Nameplate settings. These live
    -- at the bottom of UI Visibility so Ultivite-specific rules remain easy to
    -- find first. Unlike Ultivite's temporary combat/PvP visibility rules, these
    -- controls intentionally save to ESO's persisted UserSettings.
    local function getEsoSettingValue(systemType, settingId)
        if not GetSetting or systemType == nil or settingId == nil then return nil end
        local ok, value = pcall(GetSetting, systemType, settingId)
        if not ok or value == nil then return nil end
        return tostring(value)
    end

    local function setEsoSettingValue(systemType, settingId, value)
        if not SetSetting or systemType == nil or settingId == nil or value == nil then return false end
        value = tostring(value)
        if getEsoSettingValue(systemType, settingId) == value then return true end
        local option = SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA
        local ok
        if option ~= nil then
            ok = pcall(SetSetting, systemType, settingId, value, option)
        else
            ok = pcall(SetSetting, systemType, settingId, value)
        end
        refreshUltivitePanel()
        if not ok then return false end
        local applied = getEsoSettingValue(systemType, settingId) == value
        if not applied and d then
            d("[Ultivite] ESO setting write did not apply; the live value did not change.")
        end
        return applied
    end

    local function getEsoSettingBool(systemType, settingId)
        local value = getEsoSettingValue(systemType, settingId)
        return value == "1" or value == "true"
    end

    local function addEsoBooleanControl(controls, name, systemType, settingId, tooltip)
        if systemType == nil or settingId == nil then return end
        controls[#controls + 1] = {
            type = "checkbox",
            name = name,
            tooltip = tooltip,
            getFunc = function() return getEsoSettingBool(systemType, settingId) end,
            setFunc = function(value) setEsoSettingValue(systemType, settingId, value and 1 or 0) end,
            width = "full",
        }
    end

    local function addNameplateChoiceControl(controls, name, settingId, tooltip, healthBar)
        if SETTING_TYPE_NAMEPLATES == nil or settingId == nil then return end
        local never = NAMEPLATE_CHOICE_NEVER ~= nil and NAMEPLATE_CHOICE_NEVER or NAMEPLATE_CHOICE_NONE
        local targeted = NAMEPLATE_CHOICE_TARGETED
        local always = NAMEPLATE_CHOICE_ALWAYS
        local injuredTargeted = NAMEPLATE_CHOICE_INJURED_OR_TARGETED
        local choices, values
        if healthBar and injuredTargeted ~= nil then
            choices = { "Never", "Targeted", "Injured or targeted", "Always" }
            values = { never, targeted, injuredTargeted, always }
        else
            choices = { "Never", "Targeted", "Always" }
            values = { never, targeted, always }
        end
        controls[#controls + 1] = {
            type = "dropdown",
            name = name,
            tooltip = tooltip,
            choices = choices,
            choicesValues = values,
            getFunc = function()
                local value = tonumber(getEsoSettingValue(SETTING_TYPE_NAMEPLATES, settingId))
                for _, valid in ipairs(values) do
                    if value == valid then return valid end
                end
                return values[1]
            end,
            setFunc = function(value)
                setEsoSettingValue(SETTING_TYPE_NAMEPLATES, settingId, value)
                if settingId == NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES
                    or settingId == NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES
                    or settingId == NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES then
                    if Frames and Frames.saved then Frames.saved.vanillaNpcNamesHidden = false end
                    if Combat and Combat.ClearNpcNamesOverride then Combat.ClearNpcNamesOverride() end
                elseif settingId == NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES
                    or settingId == NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES
                    or settingId == NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES then
                    if Combat and Combat.ClearPlayerNamesOverride then Combat.ClearPlayerNamesOverride() end
                end
                if Ultivite and U.RequestSettingsSave then U.RequestSettingsSave(true) end
            end,
            width = "full",
        }
    end

    local vanillaEsoInterfaceControls = {
    }

    local vanillaGeneralControls = {}
    addEsoBooleanControl(vanillaGeneralControls, "House Tracker", SETTING_TYPE_UI, UI_SETTING_SHOW_HOUSE_TRACKER, "Mirrors Settings > Interface > House Tracker.")
    addEsoBooleanControl(vanillaGeneralControls, "Quest Tracker", SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, "Mirrors ESO's native Quest Tracker toggle. Ultivite's Quest Tracker visibility mode can temporarily override this while its rule is active.")
    addEsoBooleanControl(vanillaGeneralControls, "Automatic Quest Tracking", SETTING_TYPE_UI, UI_SETTING_AUTOMATIC_QUEST_TRACKING, "Mirrors ESO's Automatic Quest Tracking setting.")
    addEsoBooleanControl(vanillaGeneralControls, "Quest Giver Icons", SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_BESTOWER_INDICATORS, "Mirrors ESO's Quest Giver Icons setting.")
    addEsoBooleanControl(vanillaGeneralControls, "Compass Quest Givers", SETTING_TYPE_UI, UI_SETTING_COMPASS_QUEST_GIVERS, "Shows or hides quest giver pins on the native compass.")
    if SETTING_TYPE_UI ~= nil and UI_SETTING_COMPASS_ACTIVE_QUESTS ~= nil then
        vanillaGeneralControls[#vanillaGeneralControls + 1] = {
            type = "dropdown",
            name = "Compass Active Quests",
            tooltip = "Mirrors ESO's Compass Active Quests setting. This controls quest pins on the compass, not whether the compass frame itself is visible.",
            choices = { "On", "Focused quest only", "Off" },
            choicesValues = { COMPASS_ACTIVE_QUESTS_CHOICE_ON, COMPASS_ACTIVE_QUESTS_CHOICE_FOCUSED, COMPASS_ACTIVE_QUESTS_CHOICE_OFF },
            getFunc = function() return tonumber(getEsoSettingValue(SETTING_TYPE_UI, UI_SETTING_COMPASS_ACTIVE_QUESTS)) or COMPASS_ACTIVE_QUESTS_CHOICE_OFF end,
            setFunc = function(value) setEsoSettingValue(SETTING_TYPE_UI, UI_SETTING_COMPASS_ACTIVE_QUESTS, value) end,
            width = "full",
        }
    end
    addEsoBooleanControl(vanillaGeneralControls, "Compass Companions", SETTING_TYPE_UI, UI_SETTING_COMPASS_COMPANION, "Shows or hides companions on the native compass.")
    addEsoBooleanControl(vanillaGeneralControls, "Compass Target Markers", SETTING_TYPE_UI, UI_SETTING_COMPASS_TARGET_MARKERS, "Shows or hides target markers on the native compass.")
    addEsoBooleanControl(vanillaGeneralControls, "Compass Distance Tracking", SETTING_TYPE_UI, UI_SETTING_COMPASS_DISTANCE_TRACKING, "Shows or hides native compass distance tracking.")
    addEsoBooleanControl(vanillaGeneralControls, "Weapon Indicator", SETTING_TYPE_UI, UI_SETTING_SHOW_WEAPON_INDICATOR, "Mirrors ESO's Weapon Indicator toggle.")
    addEsoBooleanControl(vanillaGeneralControls, "Armor Indicator", SETTING_TYPE_UI, UI_SETTING_SHOW_ARMOR_INDICATOR, "Mirrors ESO's Armor Indicator toggle.")
    addEsoBooleanControl(vanillaGeneralControls, "Raid Lives", SETTING_TYPE_UI, UI_SETTING_SHOW_RAID_LIVES, "Shows or hides ESO's native raid lives display.")
    addEsoBooleanControl(vanillaGeneralControls, "Alliance War notifications", SETTING_TYPE_UI, UI_SETTING_SHOW_AVA_NOTIFICATIONS, "Shows or hides native Alliance War notifications.")
    addEsoBooleanControl(vanillaGeneralControls, "Guild Keep notices", SETTING_TYPE_UI, UI_SETTING_SHOW_GUILD_KEEP_NOTICES, "Shows or hides native guild keep notices.")
    addEsoBooleanControl(vanillaGeneralControls, "Leaderboard notifications", SETTING_TYPE_UI, UI_SETTING_SHOW_LEADERBOARD_NOTIFICATIONS, "Shows or hides native leaderboard notifications.")
    addEsoBooleanControl(vanillaGeneralControls, "PvP kill feed notifications", SETTING_TYPE_UI, UI_SETTING_SHOW_PVP_KILL_FEED_NOTIFICATIONS, "Shows or hides ESO's native PvP kill feed notifications.")
    addEsoBooleanControl(vanillaGeneralControls, "Framerate", SETTING_TYPE_UI, UI_SETTING_SHOW_FRAMERATE, "Shows or hides ESO's native FPS display.")
    addEsoBooleanControl(vanillaGeneralControls, "Latency", SETTING_TYPE_UI, UI_SETTING_SHOW_LATENCY, "Shows or hides ESO's native latency display.")
    if #vanillaGeneralControls > 0 then
        vanillaEsoInterfaceControls[#vanillaEsoInterfaceControls + 1] = { type = "submenu", name = "Interface Toggles", controls = vanillaGeneralControls }
    end

    local vanillaNameplateControls = {}
    if SETTING_TYPE_NAMEPLATES ~= nil then
        local npcNameTypes = {
            NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES,
            NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES,
            NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES,
        }
        vanillaNameplateControls[#vanillaNameplateControls + 1] = {
            type = "checkbox",
            name = "Hide all NPC names",
            tooltip = "Deterministic NPC name toggle. ON forces enemy, friendly and neutral NPC names to Never. OFF forces all three categories to Always. Player names are unchanged.",
            getFunc = function()
                local f = Frames and Frames.saved
                if f and f.vanillaNpcNamesHidden ~= nil then return f.vanillaNpcNamesHidden == true end
                local never = NAMEPLATE_CHOICE_NEVER ~= nil and NAMEPLATE_CHOICE_NEVER or NAMEPLATE_CHOICE_NONE
                if never == nil then return false end
                local enemy = NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES and tonumber(getEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES))
                local friendly = NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES and tonumber(getEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES))
                local neutral = NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES and tonumber(getEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES))
                return enemy == never and friendly == never and neutral == never
            end,
            setFunc = function(value)
                local f = Frames and Frames.saved
                local csv = getCombatVisibilitySettings()
                value = value and true or false
                if f then f.vanillaNpcNamesHidden = value end
                if csv then
                    csv.npcNamesGlobalHidden = value
                    csv.npcNamesOverrideActive = true
                end
                if Combat then
                    if csv then Combat.sv = csv end
                    if Combat.SetNpcNamesHidden then Combat.SetNpcNamesHidden(value) end
                else
                    local choice = value and (NAMEPLATE_CHOICE_NEVER or NAMEPLATE_CHOICE_NONE or 0) or (NAMEPLATE_CHOICE_ALWAYS or NAMEPLATE_CHOICE_TARGETED or 1)
                    if not value and NAMEPLATE_TYPE_ALL_NAMEPLATES ~= nil then
                        setEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES, 1)
                    end
                    setEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, choice)
                    setEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, choice)
                    setEsoSettingValue(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, choice)
                end
                if Ultivite and U.RequestSettingsSave then U.RequestSettingsSave(true) end
                refreshUltivitePanel()
            end,
            default = false,
            width = "full",
        }
        addEsoBooleanControl(vanillaNameplateControls, "Enable ESO nameplates", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_NAMEPLATES, "Master ESO nameplate switch. Ultivite target and Dark Souls rules can still override specific categories.")
        addEsoBooleanControl(vanillaNameplateControls, "Enable ESO overhead Health bars", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALL_HEALTHBARS, "Master ESO overhead Health bar switch. Dark Souls and Ultivite target-bar rules can temporarily override this.")
        addNameplateChoiceControl(vanillaNameplateControls, "Enemy NPC names", NAMEPLATE_TYPE_ENEMY_NPC_NAMEPLATES, "Native ESO visibility for enemy NPC names.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Friendly NPC names", NAMEPLATE_TYPE_FRIENDLY_NPC_NAMEPLATES, "Native ESO visibility for friendly NPC names.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Neutral NPC names", NAMEPLATE_TYPE_NEUTRAL_NPC_NAMEPLATES, "Native ESO visibility for neutral NPC names.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Enemy player names", NAMEPLATE_TYPE_ENEMY_PLAYER_NAMEPLATES, "Native ESO visibility for enemy player names.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Friendly player names", NAMEPLATE_TYPE_FRIENDLY_PLAYER_NAMEPLATES, "Native ESO visibility for friendly player names.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Group member names", NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, "Native ESO visibility for group member names.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Your player nameplate", NAMEPLATE_TYPE_PLAYER_NAMEPLATE, "Native ESO visibility for your own player nameplate.", false)
        addNameplateChoiceControl(vanillaNameplateControls, "Enemy NPC Health bars", NAMEPLATE_TYPE_ENEMY_NPC_HEALTHBARS, "Native ESO visibility for enemy NPC overhead Health bars.", true)
        addNameplateChoiceControl(vanillaNameplateControls, "Enemy player Health bars", NAMEPLATE_TYPE_ENEMY_PLAYER_HEALTHBARS, "Native ESO visibility for enemy player overhead Health bars.", true)
        addNameplateChoiceControl(vanillaNameplateControls, "Friendly NPC Health bars", NAMEPLATE_TYPE_FRIENDLY_NPC_HEALTHBARS, "Native ESO visibility for friendly NPC overhead Health bars.", true)
        addNameplateChoiceControl(vanillaNameplateControls, "Friendly player Health bars", NAMEPLATE_TYPE_FRIENDLY_PLAYER_HEALTHBARS, "Native ESO visibility for friendly player overhead Health bars.", true)
        addNameplateChoiceControl(vanillaNameplateControls, "Group member Health bars", NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, "Native ESO visibility for group member overhead Health bars.", true)
        addNameplateChoiceControl(vanillaNameplateControls, "Neutral NPC Health bars", NAMEPLATE_TYPE_NEUTRAL_NPC_HEALTHBARS, "Native ESO visibility for neutral NPC overhead Health bars.", true)
        addNameplateChoiceControl(vanillaNameplateControls, "Your player Health bar", NAMEPLATE_TYPE_PLAYER_HEALTHBAR, "Native ESO visibility for your own overhead Health bar.", true)
        addEsoBooleanControl(vanillaNameplateControls, "Show player titles", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_SHOW_PLAYER_TITLES, "Shows or hides player titles in ESO nameplates.")
        addEsoBooleanControl(vanillaNameplateControls, "Show player guilds", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_SHOW_PLAYER_GUILDS, "Shows or hides player guild information in ESO nameplates.")
        addEsoBooleanControl(vanillaNameplateControls, "Alliance indicators", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_ALLIANCE_INDICATORS, "Shows or hides alliance indicators in ESO nameplates.")
        addEsoBooleanControl(vanillaNameplateControls, "Group indicators", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_INDICATORS, "Shows or hides group indicators above players.")
        addEsoBooleanControl(vanillaNameplateControls, "Follower indicators", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_FOLLOWER_INDICATORS, "Shows or hides follower indicators.")
        addEsoBooleanControl(vanillaNameplateControls, "Target markers", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_TARGET_MARKERS, "Shows or hides ESO target markers in nameplates.")
        addEsoBooleanControl(vanillaNameplateControls, "Resurrect indicators", SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_RESURRECT_INDICATORS, "Shows or hides resurrect indicators in nameplates.")
    end
    if #vanillaNameplateControls > 0 then
        vanillaEsoInterfaceControls[#vanillaEsoInterfaceControls + 1] = { type = "submenu", name = "Names, Nameplates & Overhead Bars", controls = vanillaNameplateControls }
    end

    local vanillaChatControls = {}
    addEsoBooleanControl(vanillaChatControls, "Chat Bubbles", SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED, "Mirrors ESO's main Chat Bubbles toggle.")
    addEsoBooleanControl(vanillaChatControls, "Your own Chat Bubbles", SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED_FOR_LOCAL_PLAYER, "Shows or hides chat bubbles for your own character.")
    addEsoBooleanControl(vanillaChatControls, "Chat Bubbles only from contacts", SETTING_TYPE_CHAT_BUBBLE, CHAT_BUBBLE_SETTING_ENABLED_ONLY_FROM_CONTACTS, "Limits chat bubbles to contacts using ESO's native setting.")
    if #vanillaChatControls > 0 then
        vanillaEsoInterfaceControls[#vanillaEsoInterfaceControls + 1] = { type = "submenu", name = "Chat Bubbles", controls = vanillaChatControls }
    end

    result[#result + 1] = {
        type = "submenu",
        name = "UI Visibility",
        tooltip = "Canonical visibility controls for ESO and Ultivite HUD elements. Advanced implementation switches are kept out of this section.",
        controls = {
            {
                type = "dropdown",
                name = "Golden Pursuits",
                tooltip = "Show or hide ESO's Golden Pursuits tracker.",
                choices = { "Show", "Hide" },
                choicesValues = { "show", "hide" },
                getFunc = function()
                    return (Frames.IsGoldenPursuitsHidden and Frames.IsGoldenPursuitsHidden()) and "hide" or "show"
                end,
                setFunc = function(value)
                    if Frames.SetGoldenPursuitsHidden then Frames.SetGoldenPursuitsHidden(value == "hide", true) end
                    refreshUltivitePanel()
                end,
                default = "show",
                width = "full",
            },
            {
                type = "submenu",
                name = "Player HUD & Global Visibility",
                controls = {
                    {
                        type = "dropdown",
                        name = "HUD Preset",
                        tooltip = "Presets can intentionally hide or replace several HUD elements at once.",
                        choices = {
                            "Ultivite Default",
                            "Dark Souls",
                            "Dark Souls + Action Bar",
                            "Dark Souls Self (large bottom)",
                            "Dark Souls top-left only",
                            "Dark Souls top-left + Self",
                        },
                        choicesValues = { "default", "darkSouls", "darkSoulsActionBar", "darkSoulsSelf", "topLeft", "both" },
                        getFunc = getHudPreset,
                        setFunc = setHudPreset,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show combat HUD only in combat",
                        tooltip = "Master Combat Only visibility. Hides the player resource HUD and Fancy Action Bar while out of combat.",
                        getFunc = function() return Frames.saved and Frames.saved.combatOnly == true end,
                        setFunc = function(value) Frames.SetCombatOnly(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide complete action bar",
                        tooltip = "Hides the entire ESO action bar root, including Fancy Action Bar+ and Ultimate.",
                        getFunc = function() return Frames.saved and Frames.saved.hideActionBar == true end,
                        setFunc = function(value) Frames.SetHideActionBar(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide Werewolf resource meter",
                        tooltip = "Hides ESO's extra Werewolf resource meter that normally appears directly beneath the Magicka bar. This does not hide Magicka itself.",
                        getFunc = function() return not Frames.saved or Frames.saved.hideWerewolfResourceBar ~= false end,
                        setFunc = function(value) Frames.SetHideWerewolfResourceBar(value, true); refreshUltivitePanel() end,
                        default = true,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide Mount Stamina meter",
                        tooltip = "Force hides ESO's small Mount Stamina bar, including while mounted. Ultivite blocks ESO's mount-state refresh from bringing it back. Turn this off to restore normal ESO behavior.",
                        getFunc = function() return not Frames.saved or Frames.saved.hideMountStaminaBar ~= false end,
                        setFunc = function(value) Frames.SetHideMountStaminaBar(value, true); refreshUltivitePanel() end,
                        default = true,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show Dark Souls Ultimate",
                        tooltip = "Shows Ultivite's standalone Ultimate icon with the Dark Souls player layouts when that layout supports it.",
                        getFunc = function() return Frames.saved and Frames.saved.showDSUltimate == true end,
                        setFunc = function(value) Frames.SetShowDSUltimate(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show bottom Dark Souls Health bar",
                        tooltip = "Shows the large bottom Dark Souls style player Health bar and hides the corresponding native ESO/FAB-moved Health bar.",
                        getFunc = function() return Frames.saved and Frames.saved.dsSelfHealthBar == true end,
                        setFunc = function(value) Frames.SetDSSelfHealthBar(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show bottom Dark Souls Magicka / Stamina",
                        tooltip = "Adds bottom Dark Souls Magicka and Stamina and hides the corresponding native ESO/FAB-moved resource bars.",
                        getFunc = function() return Frames.saved and Frames.saved.dsSelfResourceBars == true end,
                        setFunc = function(value) Frames.SetDSSelfResourceBars(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide bottom Dark Souls bars out of combat",
                        tooltip = "Keeps the large bottom Dark Souls player bars visible only while in combat. The master Combat HUD option can also control them.",
                        getFunc = function() return Frames.saved and Frames.saved.dsSelfHealthCombatOnly == true end,
                        setFunc = function(value) Frames.SetDSSelfHealthCombatOnly(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Bottom Dark Souls player bars only",
                        tooltip = "When enabled, the custom bottom player bars replace and suppress the normal Health, Magicka and Stamina bars.",
                        getFunc = function() return Frames.saved and Frames.saved.dsBottomOnly == true end,
                        setFunc = function(value) Frames.SetDSBottomOnly(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "header",
                        name = "Navigation Helpers",
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show crown direction arrow",
                        tooltip = "Shows the small white arrow pointing toward the current group leader/crown. Size, opacity and position are under Player HUD & Layouts > Navigation Helper Appearance & Position.",
                        getFunc = function() return Frames.saved and Frames.saved.crownDirectionArrow == true end,
                        setFunc = function(value) Frames.SetCrownDirectionArrow(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show feet compass",
                        tooltip = "Shows the professional ground-style white compass beneath the character. Size, opacity and position are under Player HUD & Layouts > Navigation Helper Appearance & Position.",
                        getFunc = function() return Frames.saved and Frames.saved.feetCompass == true end,
                        setFunc = function(value) Frames.SetFeetCompass(value, true); refreshUltivitePanel() end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "dropdown",
                        name = "Champion Progress Bar visibility",
                        tooltip = "This controls ESO's Champion XP progress bar only. It does not control CP numbers shown on player or group frames. Show always keeps the progress bar available on the normal HUD. Hide in combat suppresses Champion progress while you are fighting. Hide in PvP only suppresses it in Battlegrounds, Cyrodiil and Imperial City. Hide always suppresses Champion progress everywhere. Skill and XP gain animations can still use ESO's shared progress bar.",
                        choices = { "On / Show always", "Hide in combat", "Hide in PvP only", "Hide always" },
                        choicesValues = { "show", "combat", "pvp", "hide" },
                        getFunc = function() return Frames.GetChampionProgressVisibilityMode() end,
                        setFunc = function(value) Frames.SetChampionProgressVisibilityMode(value, true); refreshUltivitePanel() end,
                        default = "pvp",
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Overhead Player Info",
                        tooltip = "Shows Character Name + CP + Level above group members. Information for enemy or other players you mouse over stays at a fixed 2D reticle anchor; Ultivite never queries a non-grouped player's world position. This is independent from ESO's native Player Names setting below.",
                        getFunc = function() return Combat and Combat.IsOverheadPlayerInfoEnabled and Combat.IsOverheadPlayerInfoEnabled() or false end,
                        setFunc = function(value)
                            if Combat and Combat.SetOverheadPlayerInfoEnabled then
                                Combat.SetOverheadPlayerInfoEnabled(value, true)
                            end
                            refreshUltivitePanel()
                        end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show player names above heads",
                        tooltip = "Shows or hides ESO's native blue player names above enemy, friendly and group players. This does not disable Ultivite's Overhead Player Info Character Name + CP/Level overlay.",
                        getFunc = function()
                            return not (Combat and Combat.IsPlayerNamesHidden and Combat.IsPlayerNamesHidden())
                        end,
                        setFunc = function(value)
                            if Combat and Combat.SetPlayerNamesHidden then Combat.SetPlayerNamesHidden(not value, true) end
                            refreshUltivitePanel()
                        end,
                        default = true,
                        width = "full",
                    },
                    {
                        type = "dropdown",
                        name = "Chat visibility",
                        tooltip = "Normal leaves chat under ESO control. Hide in combat and Hide in PvP suppress the chat window only in those contexts. Auto Hide hides the chat window whenever you are not actively typing.",
                        choices = { "Normal", "Hide in combat", "Hide in PvP", "Auto Hide" },
                        choicesValues = { "show", "combat", "pvp", "hide" },
                        getFunc = function() return Frames.GetChatVisibilityMode and Frames.GetChatVisibilityMode() or "show" end,
                        setFunc = function(value) if Frames.SetChatVisibilityMode then Frames.SetChatVisibilityMode(value, true) end; refreshUltivitePanel() end,
                        default = "show",
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Compass",
                controls = {
                    {
                        type = "dropdown",
                        name = "Compass visibility",
                        tooltip = "Show keeps the compass under normal ESO control. Hide in combat suppresses it only while fighting. Hide in PvP suppresses it only in Battlegrounds, Cyrodiil and Imperial City. Hide always suppresses it everywhere.",
                        choices = { "On / Show", "Hide in combat", "Hide in PvP", "Hide always" },
                        choicesValues = { "show", "combat", "pvp", "hide" },
                        getFunc = function() return Frames.GetUiVisibilityMode("compass") end,
                        setFunc = function(value) Frames.SetUiVisibilityMode("compass", value, true); refreshUltivitePanel() end,
                        default = "combat",
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Navigation Helper Appearance & Position",
                controls = {
                    {
                        type = "slider",
                        name = "Crown arrow size",
                        tooltip = "Size of the crown direction marker. The white arrow is intentionally long and the gold crown is permanently attached to its base at every rotation angle.",
                        min = 14, max = 96, step = 1,
                        getFunc = function() return (Frames.saved and Frames.saved.crownDirectionArrowSize) or 40 end,
                        setFunc = function(value) Frames.SetCrownDirectionArrowSize(value) end,
                        default = 40,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Crown arrow opacity",
                        tooltip = "Makes the white crown arrow more or less transparent.",
                        min = 10, max = 100, step = 5,
                        getFunc = function() return zo_round(((Frames.saved and Frames.saved.crownDirectionArrowOpacity) or 0.70) * 100) end,
                        setFunc = function(value) Frames.SetCrownDirectionArrowOpacity(value / 100) end,
                        default = 70,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Crown arrow horizontal position",
                        tooltip = "Moves the crown arrow left or right from screen centre.",
                        min = -1000, max = 1000, step = 5,
                        getFunc = function() return (Frames.saved and Frames.saved.crownDirectionArrowX) or 0 end,
                        setFunc = function(value) Frames.SetCrownDirectionArrowX(value) end,
                        default = 0,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Crown arrow vertical position",
                        tooltip = "Moves the crown arrow up or down from screen centre.",
                        min = -700, max = 700, step = 5,
                        getFunc = function() return (Frames.saved and Frames.saved.crownDirectionArrowY) or -90 end,
                        setFunc = function(value) Frames.SetCrownDirectionArrowY(value) end,
                        default = -90,
                        width = "full",
                    },
                    {
                        type = "divider",
                    },
                    {
                        type = "slider",
                        name = "Feet compass size",
                        tooltip = "Changes the overall width of the ground compass. The redesigned oval keeps a natural perspective instead of becoming heavily squashed.",
                        min = 140, max = 650, step = 5,
                        getFunc = function() return (Frames.saved and Frames.saved.feetCompassSize) or 330 end,
                        setFunc = function(value) Frames.SetFeetCompassSize(value) end,
                        default = 330,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Feet compass opacity",
                        tooltip = "Adjusts the ground compass ring opacity. Direction text stays high contrast so it remains readable.",
                        min = 10, max = 100, step = 5,
                        getFunc = function() return zo_round(((Frames.saved and Frames.saved.feetCompassOpacity) or 0.66) * 100) end,
                        setFunc = function(value) Frames.SetFeetCompassOpacity(value / 100) end,
                        default = 66,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Feet compass horizontal position",
                        tooltip = "Moves the feet compass left or right.",
                        min = -1000, max = 1000, step = 5,
                        getFunc = function() return (Frames.saved and Frames.saved.feetCompassX) or 0 end,
                        setFunc = function(value) Frames.SetFeetCompassX(value) end,
                        default = 0,
                        width = "full",
                    },
                    {
                        type = "slider",
                        name = "Feet compass vertical position",
                        tooltip = "Moves the feet compass up or down. Positive values move it lower on screen.",
                        min = -700, max = 700, step = 5,
                        getFunc = function() return (Frames.saved and Frames.saved.feetCompassY) or 335 end,
                        setFunc = function(value) Frames.SetFeetCompassY(value) end,
                        default = 335,
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Crosshair / Reticle",
                controls = {
                    {
                        type = "dropdown",
                        name = "Crosshair visibility",
                        tooltip = "Controls only ESO's center crosshair texture; interaction prompts and reticle text remain available. Show keeps normal ESO behavior. Only in combat hides the crosshair while out of combat. Only in PvP shows it only in Battlegrounds, Cyrodiil and Imperial City. Hide in combat and Hide in PvP do the inverse. Hide always removes the crosshair texture everywhere.",
                        choices = { "On / Show", "Only in combat", "Only in PvP", "Hide in combat", "Hide in PvP", "Hide always" },
                        choicesValues = { "show", "combatOnly", "pvpOnly", "combat", "pvp", "hide" },
                        getFunc = function() return Frames.GetUiVisibilityMode("crosshair") end,
                        setFunc = function(value) Frames.SetUiVisibilityMode("crosshair", value, true); refreshUltivitePanel() end,
                        default = "show",
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Quest Tracker",
                controls = {
                    {
                        type = "dropdown",
                        name = "Quest Tracker visibility",
                        tooltip = "Show keeps the Quest Tracker under normal ESO control. Hide in combat suppresses it only while fighting. Hide in PvP suppresses it only in Battlegrounds, Cyrodiil and Imperial City. Hide always suppresses it everywhere.",
                        choices = { "On / Show", "Hide in combat", "Hide in PvP", "Hide always" },
                        choicesValues = { "show", "combat", "pvp", "hide" },
                        getFunc = function() return Frames.GetUiVisibilityMode("quests") end,
                        setFunc = function(value) Frames.SetUiVisibilityMode("quests", value, true); refreshUltivitePanel() end,
                        default = "pvp",
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Queue & Status UI",
                controls = {
                    {
                        type = "dropdown", name = "Queue status",
                        tooltip = "Controls only explicitly known ESO queue/status controls.",
                        choices = { "On / Show", "Hide in combat", "Hide in PvP", "Hide always" }, choicesValues = { "show", "combat", "pvp", "hide" },
                        getFunc = function() return Frames.GetUiVisibilityMode("queue") end,
                        setFunc = function(value) Frames.SetUiVisibilityMode("queue", value, true); refreshUltivitePanel() end,
                        default = "show", width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Target Frames, Health Bars & Names",
                controls = {
                    {
                        type = "checkbox",
                        name = "Enable Ultivite target frame",
                        tooltip = "Shows Ultivite's own persistent target frame when a valid target is available.",
                        getFunc = function()
                            local sv = getCombatVisibilitySettings()
                            return sv and sv.targetFrame == true
                        end,
                        setFunc = function(value)
                            setCombatVisibilityFlag("targetFrame", value, function()
                                if Combat and Combat.RefreshDisplay then Combat.RefreshDisplay() end
                            end)
                        end,
                        default = true,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide stock ESO target frame",
                        tooltip = "Hides ESO's normal reticle target frame.",
                        getFunc = function()
                            local sv = getCombatVisibilitySettings()
                            return sv and sv.hideDefaultTargetFrame == true
                        end,
                        setFunc = function(value)
                            setCombatVisibilityFlag("hideDefaultTargetFrame", value, function()
                                if Combat and Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
                            end)
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide LUI Extended target frame",
                        tooltip = "Hides LUI Extended's custom target frame when LUI Extended is installed.",
                        getFunc = function()
                            local sv = getCombatVisibilitySettings()
                            return sv and sv.hideLUIETargetFrame == true
                        end,
                        setFunc = function(value)
                            setCombatVisibilityFlag("hideLUIETargetFrame", value, function()
                                if Combat and Combat.ApplyLUIETargetFrameVisibility then Combat.ApplyLUIETargetFrameVisibility() end
                            end)
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Auto hide any other target frame",
                        tooltip = "Allows Ultivite to suppress another duplicate target frame it detects.",
                        getFunc = function()
                            local sv = getCombatVisibilitySettings()
                            return sv and sv.autoHideOtherTargetFrames == true
                        end,
                        setFunc = function(value)
                            local sv = getCombatVisibilitySettings()
                            if not sv then return end
                            sv.autoHideOtherTargetFrames = value and true or false
                            if Combat then
                                Combat.dynamicHiddenTargetFrame = nil
                                Combat.dynamicHiddenTargetFrameState = nil
                                if Combat.ApplyOtherTargetFrameVisibility then Combat.ApplyOtherTargetFrameVisibility(false) end
                            end
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide default overhead Health bars",
                        tooltip = "Hides ESO's normal overhead enemy Health bars and restores the captured ESO nameplate settings when disabled.",
                        getFunc = function()
                            return Combat and Combat.GetHideNativeOverheadHealthBars and Combat.GetHideNativeOverheadHealthBars() or false
                        end,
                        setFunc = function(value)
                            if Combat and Combat.SetHideNativeOverheadHealthBars then
                                Combat.SetHideNativeOverheadHealthBars(value, true)
                            end
                            saveVisibilityChange()
                        end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Use native overhead target bar",
                        tooltip = "When disabled, Ultivite does not force ESO's native targeted overhead healthbar mode.",
                        getFunc = function()
                            local sv = getCombatVisibilitySettings()
                            return sv and sv.nativeOverheadTargetBar == true
                        end,
                        setFunc = function(value)
                            if Combat and Combat.SetNativeOverheadTargetBar then
                                Combat.SetNativeOverheadTargetBar(value)
                            end
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide NPC names in native mode",
                        tooltip = "Hides enemy, friendly and neutral NPC names while native overhead target mode is active. Player names are left alone.",
                        getFunc = function()
                            local sv = getCombatVisibilitySettings()
                            return sv and sv.nativeHideNpcNames == true
                        end,
                        setFunc = function(value)
                            local sv = getCombatVisibilitySettings()
                            if not sv then return end
                            sv.nativeHideNpcNames = value and true or false
                            if Combat and Combat.ApplyNativeOverheadTargetBar then Combat.ApplyNativeOverheadTargetBar() end
                            saveVisibilityChange()
                        end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "dropdown",
                        name = "Target Frame Mode",
                        tooltip = "Ultivite enables the custom Ultivite target frame and hides ESO's stock target frame. Vanilla / Default disables Ultivite target-frame ownership and returns to ESO's stock target frame. You can switch back at any time.",
                        choices = { "Ultivite", "Vanilla / Default" },
                        choicesValues = { "ultivite", "vanilla" },
                        getFunc = function() return U.IsVanillaTargetFramesActive and U.IsVanillaTargetFramesActive() and "vanilla" or "ultivite" end,
                        setFunc = function(value)
                            if value == "vanilla" then
                                if U.ApplyVanillaTargetFrames then U.ApplyVanillaTargetFrames(false) end
                            else
                                if U.EnableUltiviteTargetFrames then U.EnableUltiviteTargetFrames(false) end
                            end
                            refreshUltivitePanel()
                        end,
                        default = "ultivite",
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Action Bar Visibility",
                controls = {
                    {
                        type = "checkbox",
                        name = "Hide locked Action Bars",
                        tooltip = "Mirrors Fancy Action Bar+'s Hide locked Action Bars option, including Oakensoul, Werewolf and other weapon-swap lock states.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.hideLockedBar == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.hideLockedBar = value and true or false
                            refreshFabWeaponLock()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide inactive slots on inactive bars",
                        tooltip = "Hides inactive-row slots that have no active timer or stack display.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.hideInactiveSlots == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.hideInactiveSlots = value and true or false
                            if not sv.hideInactiveSlots and FAB and FAB.slotHidden then
                                for key in pairs(FAB.slotHidden) do
                                    FAB.slotHidden[key] = false
                                end
                            end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide companion ultimate slot",
                        tooltip = "Completely hides the companion Ultimate slot.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.hideCompanionUlt == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.hideCompanionUlt = value and true or false
                            if FAB and FAB.HandleCompanionUltimate then FAB.HandleCompanionUltimate() end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Hide default action button frames",
                        tooltip = "Hides ESO's default action-button frames. This affects the button borders rather than the abilities themselves.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.hideDefaultFrames == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.hideDefaultFrames = value and true or false
                            if FAB and FAB.ConfigureFrames then FAB.ConfigureFrames() end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show custom action button frames",
                        tooltip = "Shows Fancy Action Bar+'s custom keyboard frames around action-bar buttons.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.showFrames == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.showFrames = value and true or false
                            if FAB and FAB.ConfigureFrames then FAB.ConfigureFrames() end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show action bar hotkeys",
                        tooltip = "Shows keyboard/gamepad binding text on action-bar buttons.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.showHotkeys == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.showHotkeys = value and true or false
                            if FAB and FAB.HideHotkeys then FAB.HideHotkeys(not sv.showHotkeys) end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show active bar arrow",
                        tooltip = "Shows Fancy Action Bar+'s active weapon-bar arrow when the swap control is not locked.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.showArrow == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.showArrow = value and true or false
                            if FAB and FAB.RefreshAdjacentSlots then FAB.RefreshAdjacentSlots() end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show action bar while dead",
                        tooltip = "Keeps Fancy Action Bar+ visible while your character is dead.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.showDeath == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.showDeath = value and true or false
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        default = false,
                        width = "full",
                    },
                    {
                        type = "checkbox",
                        name = "Show gamepad ultimate hotkeys",
                        tooltip = "Shows the gamepad LB/RB labels on Ultimate controls.",
                        getFunc = function()
                            local sv = getFabVisibilitySettings()
                            return sv and sv.showHotkeysUltGP == true
                        end,
                        setFunc = function(value)
                            local sv = getFabVisibilitySettings()
                            if not sv then return end
                            sv.showHotkeysUltGP = value and true or false
                            if FAB and FAB.HideHotkeys then FAB.HideHotkeys(not sv.showHotkeys) end
                            if FAB and FAB.RefreshAdjacentSlots then FAB.RefreshAdjacentSlots() end
                            refreshFabLayout()
                            saveVisibilityChange()
                        end,
                        width = "full",
                    },
                },
            },
            {
                type = "submenu",
                name = "Vanilla ESO Interface Toggles",
                tooltip = "Direct mirrors of ESO's own Interface, Nameplates and Chat Bubble visibility settings. Kept at the bottom so Ultivite's own visibility controls remain first.",
                controls = vanillaEsoInterfaceControls,
            },
        },
    }

    local darkSoulsControls = {}
    local enemyHealthMenu = findOptionByName(raw, "Dark Souls enemy health bar")
    if enemyHealthMenu then
        enemyHealthMenu.name = "Long Health Bar"
        darkSoulsControls[#darkSoulsControls + 1] = enemyHealthMenu
    end

    darkSoulsControls[#darkSoulsControls + 1] = {
        type = "slider",
        name = "Bottom player bar scale",
        tooltip = "Changes the size of the large bottom Dark Souls Health, Magicka and Stamina bars together.",
        min = 50,
        max = 250,
        step = 5,
        getFunc = function()
            local f = Frames and Frames.saved
            return zo_round((tonumber(f and f.dsSelfScale) or 1.0) * 100)
        end,
        setFunc = function(value)
            if Frames and Frames.SetDSSelfScale then Frames.SetDSSelfScale(value / 100) end
        end,
        width = "full",
    }

    local dsPositioning = findOptionByName(raw, "Dark Souls preset positioning")
    if dsPositioning then
        dsPositioning.name = "Preset Positioning (Advanced)"
        darkSoulsControls[#darkSoulsControls + 1] = dsPositioning
    end

    local dsAdvanced = {}
    addIfPresent(dsAdvanced, findOptionByName(raw, "Dark Souls player bars"))
    addIfPresent(dsAdvanced, findOptionByName(raw, "Show bottom player Health"))
    addIfPresent(dsAdvanced, findOptionByName(raw, "Add bottom Magicka and Stamina"))
    addIfPresent(dsAdvanced, findOptionByName(raw, "Bottom player bars only"))
    darkSoulsControls[#darkSoulsControls + 1] = {
        type = "submenu",
        name = "Manual Layout Controls (Advanced)",
        controls = dsAdvanced,
    }
    result[#result + 1] = {
        type = "submenu",
        name = "Dark Souls Options",
        tooltip = "Long Health bar, preset positioning and manual Dark Souls layout controls.",
        controls = darkSoulsControls,
    }

    local reset = findOptionByName(raw, "Player UI Reset & Diagnostics")
    if reset then
        reset.name = "Player UI Reset & Diagnostics (Advanced)"
        result[#result + 1] = reset
    end

    return result
end

local function buildSimplifiedCombatOptions(raw)
    local result = {}

    local warnings = findOptionByName(raw, "Warnings & HUD Convenience")
    if warnings then
        warnings.name = "Combat Warnings & Resource Alerts"
        warnings.controls = removeNamedOptionRecursive(warnings.controls, { ["Always collapse chat window"] = true })
        result[#result + 1] = warnings
    end

    local selfEffects = findOptionByName(raw, "Self effects: CC immunity & debuffs")
    if selfEffects then selfEffects.name = "Self Effects"; result[#result + 1] = selfEffects end

    local targetEffects = findOptionByName(raw, "Target effects & debuffs")
    if targetEffects then targetEffects.name = "Target Effects"; result[#result + 1] = targetEffects end

    local timers = findOptionByName(raw, "Combat Timers & Set Trackers")
    if timers then
        timers.name = "Set & Stack Trackers"
        timers.controls = timers.controls or {}
        timers.controls[#timers.controls + 1] = {
            type = "submenu",
            name = "Quick Tracker Toggles",
            controls = {
                {
                    type = "button", name = "Enable all dedicated set trackers",
                    tooltip = "Enables Onslaught, Balorgh, Tarnished Nightmare, Null Arca, Dragon's Appetite and Wretched Vitality. Other trackers are unchanged.",
                    func = function()
                        local sv = Combat.sv; if not sv then return end
                        sv.onslaughtTimer = true; sv.balorghTimer = true; sv.tarnishedTimer = true
                        sv.nullArcaTimer = true; sv.dragonAppetiteCounter = true; sv.wretchedVitalityTimers = true
                        Combat.UpdateCombatTimers(); Combat.ScanWretchedVitalityBuffs(); U.RequestSettingsSave(true)
                    end,
                    width = "full",
                },
                {
                    type = "button", name = "Disable all dedicated set trackers",
                    tooltip = "Disables only the six dedicated set trackers. Skill stacks, Streak, Kjalnar and debuff tracking are unchanged.",
                    func = function()
                        local sv = Combat.sv; if not sv then return end
                        sv.onslaughtTimer = false; sv.balorghTimer = false; sv.tarnishedTimer = false
                        sv.nullArcaTimer = false; sv.dragonAppetiteCounter = false; sv.wretchedVitalityTimers = false
                        Combat.UpdateCombatTimers(); Combat.wretchedVitalityBuffs = {}; Combat.UpdateWretchedVitalityTimers(); U.RequestSettingsSave(true)
                    end,
                    width = "full",
                },
            },
        }
        result[#result + 1] = timers
    end

    local live = findOptionByName(raw, "Live character stats")
    if live then live.name = "Live Stats"; result[#result + 1] = live end

    local pvp = findOptionByName(raw, "PvP kills and deaths")
    if pvp then pvp.name = "PvP"; result[#result + 1] = pvp end

    local targetControls = {}
    addIfPresent(targetControls, findOptionByName(raw, "Unlock target frame for editing"))
    addIfPresent(targetControls, findOptionByName(raw, "Center horizontally"))
    addIfPresent(targetControls, findOptionByName(raw, "Center on screen"))
    addIfPresent(targetControls, findOptionByName(raw, "Target frame size"))
    addIfPresent(targetControls, findOptionByName(raw, "Use native overhead target bar"))
    addIfPresent(targetControls, findOptionByName(raw, "Show health bars for ALL enemies"))
    addIfPresent(targetControls, findOptionByName(raw, "Hide NPC names in native mode"))
    addIfPresent(targetControls, findOptionByName(raw, "Edit behaviour"))
    addIfPresent(targetControls, findOptionByName(raw, "Target behaviour"))
    result[#result + 1] = { type = "submenu", name = "Target Frame (Advanced)", controls = targetControls }

    local appearanceControls = {}
    addIfPresent(appearanceControls, findOptionByName(raw, "Combat HUD Text Appearance"))
    addIfPresent(appearanceControls, findOptionByName(raw, "Combat HUD Reset"))
    result[#result + 1] = { type = "submenu", name = "Appearance & Reset (Advanced)", controls = appearanceControls }

    return result
end

local function buildSimplifiedSoundOptions(raw)
    local result = {}
    addIfPresent(result, findOptionByName(raw, "Enable sound suppression"))
    addIfPresent(result, findOptionByName(raw, "Start sound capture"))
    addIfPresent(result, findOptionByName(raw, "Play all captured sounds"))
    addIfPresent(result, findOptionByName(raw, "Print blocked sounds"))

    result[#result + 1] = {
        type = "submenu",
        name = "Sound Capture & Diagnostics (Advanced)",
        controls = {},
    }
    local advanced = result[#result].controls
    addIfPresent(advanced, findOptionByName(raw, "Capture duration"))
    addIfPresent(advanced, findOptionByName(raw, "Play-all delay"))
    addIfPresent(advanced, findOptionByName(raw, "Print capture"))
    addIfPresent(advanced, findOptionByName(raw, "Stop play all"))
    addIfPresent(advanced, findOptionByName(raw, "Live diagnostic logging"))
    addIfPresent(advanced, findOptionByName(raw, "Clear diagnostics"))
    return result
end

function U.IsVanillaTargetFramesActive()
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    local sv = (Combat and Combat.sv) or (profile and profile.combat) or nil
    local f = (Frames and Frames.saved) or (profile and profile.frames) or nil
    if not sv then return false end

    -- Target Frame Mode is an explicit state. Enemy overhead Health-bar choices
    -- are intentionally not part of this decision, so those two controls cannot
    -- fight each other or make the menu report the wrong mode.
    if sv.targetFrameMode ~= "ultivite" and sv.targetFrameMode ~= "vanilla" then
        local dsEnemyOff = not f or tostring(f.dsEnemyHealthMode or "off") == "off"
        local looksVanilla = sv.targetFrame == false and sv.hideDefaultTargetFrame ~= true and dsEnemyOff
        sv.targetFrameMode = looksVanilla and "vanilla" or "ultivite"
    end
    return sv.targetFrameMode == "vanilla"
end

local function CaptureUltiviteTargetFrameState(sv)
    if not sv or U.IsVanillaTargetFramesActive() then return end
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    local f = (Frames and Frames.saved) or (profile and profile.frames) or nil

    sv.vanillaTargetFramesSavedTargetFrame = sv.targetFrame ~= false
    -- Enemy overhead Health bars are intentionally not part of the target-frame
    -- snapshot. They are an independent World UI choice and must survive mode
    -- changes in either direction.
    sv.vanillaTargetFramesSavedHideDefaultTargetFrame = sv.hideDefaultTargetFrame == true
    sv.vanillaTargetFramesSavedAutoHideOtherTargetFrames = sv.autoHideOtherTargetFrames == true
    sv.vanillaTargetFramesHasSnapshot = true

    if f then
        f.vanillaTargetFramesSavedDSEnemyHealthMode = tostring(f.dsEnemyHealthMode or "off")
        f.vanillaTargetFramesSavedDSEnemyTrackReticle = f.dsEnemyTrackReticle == true
        f.vanillaTargetFramesHasSnapshot = true
    end
end

local function ApplyTargetFrameRuntime(sv)
    Combat.sv = sv
    if Combat.SetHideNativeOverheadHealthBars then Combat.SetHideNativeOverheadHealthBars(sv.hideNativeOverheadHealthBars == true, true) end
    if Combat.ApplyNativeOverheadTargetBar then Combat.ApplyNativeOverheadTargetBar() end
    if Combat.ApplyOtherTargetFrameVisibility then Combat.ApplyOtherTargetFrameVisibility(false) end
    if Combat.ApplyDefaultTargetFrameVisibility then Combat.ApplyDefaultTargetFrameVisibility() end
    if Combat.RefreshDisplay then Combat.RefreshDisplay() end

    -- ESO can refresh the reticle target frame during the same frame as a mode
    -- switch. Reassert once after the UI has settled so Ultivite mode cannot leave
    -- the stock red target bar visible.
    if zo_callLater and Combat.ApplyDefaultTargetFrameVisibility then
        zo_callLater(function()
            if Combat and Combat.ApplyDefaultTargetFrameVisibility then
                Combat.ApplyDefaultTargetFrameVisibility()
            end
        end, 25)
    end

    U.RequestSettingsSave(true)
end

function U.ApplyVanillaTargetFrames(silent)
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    local sv = (Combat and Combat.sv) or (profile and profile.combat) or nil
    if not sv or not Combat then return false end

    CaptureUltiviteTargetFrameState(sv)
    sv.targetFrameMode = "vanilla"
    sv.targetFrame = false
    sv.hideDefaultTargetFrame = false
    sv.autoHideOtherTargetFrames = false

    local f = (Frames and Frames.saved) or (profile and profile.frames) or nil
    if f then
        f.dsEnemyHealthMode = "off"
        f.dsEnemyTrackReticle = false
        if Frames then
            Frames.saved = f
            if Frames.RefreshDSEnemyHealthRuntime then Frames.RefreshDSEnemyHealthRuntime() end
        end
    end

    ApplyTargetFrameRuntime(sv)

    if not silent and d then
        d("[Ultivite] Target Frame Mode: Vanilla / Default.")
    end
    return true
end

function U.EnableUltiviteTargetFrames(silent)
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    local sv = (Combat and Combat.sv) or (profile and profile.combat) or nil
    if not sv or not Combat then return false end

    sv.targetFrameMode = "ultivite"
    if sv.vanillaTargetFramesHasSnapshot == true then
        sv.targetFrame = sv.vanillaTargetFramesSavedTargetFrame ~= false
        sv.autoHideOtherTargetFrames = sv.vanillaTargetFramesSavedAutoHideOtherTargetFrames == true
    else
        -- Legacy Vanilla users have no snapshot. Restore only the core Ultivite
        -- target frame. Enemy overhead Health bars are a separate World UI choice.
        sv.targetFrame = true
        sv.autoHideOtherTargetFrames = true
    end

    -- Ultivite mode means Ultivite owns target presentation. This is deliberately
    -- absolute rather than restored from an old snapshot: ESO's stock reticle
    -- target frame must remain hidden for NPC and player targets alike.
    sv.hideDefaultTargetFrame = true

    local f = (Frames and Frames.saved) or (profile and profile.frames) or nil
    if f and f.vanillaTargetFramesHasSnapshot == true then
        f.dsEnemyHealthMode = tostring(f.vanillaTargetFramesSavedDSEnemyHealthMode or "off")
        f.dsEnemyTrackReticle = f.vanillaTargetFramesSavedDSEnemyTrackReticle == true
        if Frames then
            Frames.saved = f
            if Frames.RefreshDSEnemyHealthRuntime then Frames.RefreshDSEnemyHealthRuntime() end
        end
    end

    ApplyTargetFrameRuntime(sv)

    if not silent and d then
        d("[Ultivite] Target Frame Mode: Ultivite.")
    end
    return true
end

function U.ToggleTargetFrameMode(silent)
    if U.IsVanillaTargetFramesActive and U.IsVanillaTargetFramesActive() then
        return U.EnableUltiviteTargetFrames(silent)
    end
    return U.ApplyVanillaTargetFrames(silent)
end

function U.BuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelName = "UltiviteOptions"
    U.panel = LAM:RegisterAddonPanel(panelName, {
        type = "panel",
        name = "Ultivite",
        displayName = "|c7FD4FFUltivite|r",
        author = "Ben",
        version = U.version,
        slashCommand = "/ultivite",
        registerForRefresh = true,
        registerForDefaults = false,
    })

    local rawFrameOptions = removeLegacyProfileControls(Frames.GetMenuOptions(), "frames")
    local rawCombatOptions = removeLegacyProfileControls(Combat.GetMenuOptions(), "combat")
    local rawSoundOptions = removeFirstDescription(Sound.GetMenuOptions())

    local frameOptions = removeDescriptionOptionsRecursive(buildSimplifiedFrameOptions(rawFrameOptions))
    local uiVisibilityHub = findOptionByName(frameOptions, "UI Visibility")
    local combatOptions = removeDescriptionOptionsRecursive(buildSimplifiedCombatOptions(rawCombatOptions))
    local soundOptions = removeDescriptionOptionsRecursive(buildSimplifiedSoundOptions(rawSoundOptions))
    local immersiveOptions = Immersive and Immersive.GetMenuOptions and Immersive.GetMenuOptions() or {}
    local unifiedProfileOptions = ProfileManager and ProfileManager.GetMenuOptions and ProfileManager.GetMenuOptions() or {}
    local layoutSafetyOptions = LayoutSafety and LayoutSafety.GetMenuOptions and LayoutSafety.GetMenuOptions() or {}

    local diagnosticsControls = {
        {
            type = "description",
            title = "Ultivite Override Ownership",
            text = function()
                return Ownership and Ownership.GetStatusText and Ownership.GetStatusText() or "Ownership manager unavailable."
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Release All Ultivite Overrides",
            tooltip = "Stops Immersive and Camera modes, closes Preview, releases every temporary ownership claim, then reapplies your persistent visibility settings.",
            func = function() U.ReleaseAllOverrides(false) end,
            width = "full",
        },
        {
            type = "description",
            title = "Enemy Ultimate Alert Listener",
            text = function()
                local alerts = U.EnemyUltimateAlerts
                return alerts and alerts.GetStatusText and alerts.GetStatusText()
                    or "Enemy Ultimate alert module unavailable."
            end,
            width = "full",
        },
        {
            type = "button",
            name = "Print enemy Ultimate alert status",
            tooltip = "Prints listener registration, active filters, event counts, the last accepted ability ID and the last rejected event reason.",
            func = function()
                local alerts = U.EnemyUltimateAlerts
                if alerts and alerts.PrintStatus then alerts.PrintStatus() end
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Diagnostic logging",
            tooltip = "Allows automatic Ultivite combat and equipment diagnostics to print to chat, including set active/inactive messages. Off by default. Manual diagnostic buttons and slash commands still print when you deliberately run them.",
            getFunc = function() return Combat.sv and Combat.sv.diagnosticLogging == true end,
            setFunc = function(value)
                if not Combat.sv then return end
                Combat.sv.diagnosticLogging = value and true or false
                Combat.debug = Combat.sv.diagnosticLogging == true
                U.RequestSettingsSave(true)
            end,
            default = false,
            width = "full",
        },
        {
            type = "button",
            name = "Print frame status",
            func = function()
                if Frames.PrintConflictStatus then Frames.PrintConflictStatus() end
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Print combat status",
            func = function() Combat.HandleSlash("status") end,
            width = "half",
        },
        {
            type = "button",
            name = "Print live stat values",
            func = function() Combat.PrintLiveStatDiagnostic() end,
            width = "half",
        },
        {
            type = "button",
            name = "Print sound status",
            func = function() Sound.PrintStatus() end,
            width = "half",
        },
        {
            type = "button",
            name = "Print danger warning state",
            func = function() Combat.PrintCombatDangerDiagnostic() end,
            width = "full",
        },
        {
            type = "submenu",
            name = "Duplicate target-frame tools",
            tooltip = "Only use this if another addon leaves a second target frame on screen.",
            controls = (function()
                local raw = removeLegacyProfileControls(Combat.GetMenuOptions(), "combat")
                local other = findOptionByName(raw, "Other target frames")
                return other and other.controls or {}
            end)(),
        },
        {
            type = "button",
            name = "Print UI visibility status",
            func = function() Frames.PrintUiVisibilityDiagnostic() end,
            width = "full",
        },
    }

    local fabProfile = {
        enabled = FAB and FAB.IsAvailable and FAB.IsAvailable() or false,
        settings = FAB and FAB.GetSettings and FAB.GetSettings() or nil,
        character = FAB and FAB.GetCharacterSettings and FAB.GetCharacterSettings() or nil,
    }

    local function getWholeFabPosition(axis)
        if FAB and FAB.GetWholeActionBarPosition then
            local x, y = FAB.GetWholeActionBarPosition()
            return zo_round(axis == "x" and (x or 0) or (y or 0))
        end
        local sv = fabProfile and fabProfile.settings
        if not sv then return 0 end
        local key = FAB and FAB.style == 2 and "gp" or "kb"
        local move = sv.abMove and sv.abMove[key]
        return zo_round(tonumber(move and move[axis]) or 0)
    end

    local function setWholeFabPosition(axis, value)
        if not (FAB and FAB.SetWholeActionBarPosition) then return end
        local x, y = FAB.GetWholeActionBarPosition()
        if axis == "x" then x = value else y = value end
        FAB.SetWholeActionBarPosition(x, y)
        U.RequestSettingsSave(true)
    end

    local function makeWholeFabPositionSliders()
        return {
            {
                type = "slider",
                name = "Whole Action Bar Horizontal Position",
                tooltip = "Moves the complete Fancy Action Bar left or right. This is NOT the quickslot/potion offset control.",
                min = -4000, max = 8000, step = 1,
                getFunc = function() return getWholeFabPosition("x") end,
                setFunc = function(value) setWholeFabPosition("x", value) end,
                disabled = function() return not (fabProfile and fabProfile.enabled ~= false and FAB) end,
                width = "half",
            },
            {
                type = "slider",
                name = "Whole Action Bar Vertical Position",
                tooltip = "Moves the complete Fancy Action Bar up or down. This is NOT the quickslot/potion offset control.",
                min = -2000, max = 5000, step = 1,
                getFunc = function() return getWholeFabPosition("y") end,
                setFunc = function(value) setWholeFabPosition("y", value) end,
                disabled = function() return not (fabProfile and fabProfile.enabled ~= false and FAB) end,
                width = "half",
            },
        }
    end

    local fabControls = {
        {
            type = "button",
            name = "Open Full Fancy Action Bar+ Settings",
            tooltip = "Opens the standalone Fancy Action Bar+ panel. Use it for FAB UI presets, the ability configuration editor, effect widgets and blacklist editors that rely on FAB's own named controls.",
            func = function()
                if not (FAB and FAB.OpenExternalSettings and FAB.OpenExternalSettings()) then
                    chat("Fancy Action Bar+ settings panel could not be opened. Confirm Fancy Action Bar+ is enabled.")
                end
            end,
            disabled = function() return not (FAB and FAB.IsAvailable and FAB.IsAvailable()) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use account-wide FAB skill/effect settings",
            tooltip = "Mirrors Fancy Action Bar+'s own Accountwide Skill Settings option. FAB's normal UI settings are already account-wide; this controls its character-scoped ability configuration and effect widgets.",
            getFunc = function()
                local cv = FAB and FAB.GetCharacterSettings and FAB.GetCharacterSettings()
                return not cv or cv.useAccountWide ~= false
            end,
            setFunc = function(value)
                if FAB and FAB.SetUseAccountWide then FAB.SetUseAccountWide(value) end
                U.RequestSettingsSave(true)
            end,
            default = true,
            requiresReload = true,
            width = "full",
        },
        {
            type = "submenu",
            name = "Action Bar Layout & Editing",
            tooltip = "Move, resize or center the complete Fancy Action Bar.",
            controls = {
                {
                    type = "checkbox",
                    name = "Unlock Action Bar",
                    tooltip = "Forces Fancy Action Bar visible for editing. Drag anywhere over the highlighted action-bar edit surface to move the complete bar. Mouse wheel up enlarges it and mouse wheel down shrinks it.",
                    getFunc = function()
                        return FAB and FAB.IsUnlocked and FAB.IsUnlocked() or false
                    end,
                    setFunc = function(value)
                        if FAB and FAB.ToggleMover then
                            FAB.ToggleMover(value)
                            U.RequestSettingsSave(true)
                        end
                    end,
                    disabled = function() return not (fabProfile and fabProfile.enabled ~= false and FAB) end,
                    width = "full",
                },
                {
                    type = "button",
                    name = "Center Action Bar Horizontally",
                    tooltip = "Centers the complete visible Fancy Action Bar composition, including quickslot, both skill rows and Ultimate, on the actual screen centre.",
                    func = function()
                        if FAB and FAB.CenterActionBar then
                            local wasUnlocked = FAB.IsUnlocked and FAB.IsUnlocked()
                            if not wasUnlocked and FAB.ToggleMover then
                                FAB.ToggleMover(true)
                            end
                            FAB.CenterActionBar(true, false)
                            if not wasUnlocked and FAB.ToggleMover then
                                FAB.ToggleMover(false)
                            end
                            U.RequestSettingsSave(true)
                        end
                    end,
                    disabled = function() return not (fabProfile and fabProfile.enabled ~= false and FAB) end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Fancy Action Bar size",
                    tooltip = "Resizes the complete current keyboard or gamepad action bar.",
                    min = 50, max = 200, step = 1,
                    getFunc = function()
                        local sv = fabProfile and fabProfile.settings
                        if not sv then
                            return FAB and FAB.style == 2 and 122 or 148
                        end
                        local key = FAB and FAB.style == 2 and "gp" or "kb"
                        local t = sv.abScaling and sv.abScaling[key]
                        return t and tonumber(t.scale) or (key == "gp" and 122 or 148)
                    end,
                    setFunc = function(value)
                        local sv = fabProfile and fabProfile.settings
                        if not sv then return end
                        local key = FAB and FAB.style == 2 and "gp" or "kb"
                        sv.abScaling = sv.abScaling or {}
                        sv.abScaling[key] = sv.abScaling[key] or {}
                        sv.abScaling[key].enable = true
                        sv.abScaling[key].scale = value
                        if FAB and FAB.constants then
                            FAB.constants.abScale.enable = true
                            FAB.constants.abScale.scale = value
                            FAB.SetScale()
                            FAB.RefreshBarPosition(true)
                        end
                        U.RequestSettingsSave(true)
                    end,
                    default = 148,
                    width = "full",
                },
                makeWholeFabPositionSliders()[1],
                makeWholeFabPositionSliders()[2],
            },
        },
    }

    if fabProfile and fabProfile.enabled ~= false and FAB and FAB.BuildMenu then
        local mirroredOptions = FAB.BuildMenu()
        mirroredOptions = cleanMirroredFabOptions(mirroredOptions)
        local function wrapFabPersistence(optionsToWrap)
            for _, option in ipairs(optionsToWrap or {}) do
                if type(option) == "table" then
                    if type(option.setFunc) == "function" and not option._ultiviteSaveWrapped then
                        local originalSet = option.setFunc
                        option.setFunc = function(...)
                            originalSet(...)
                            U.RequestSettingsSave(true)
                        end
                        option._ultiviteSaveWrapped = true
                    end
                    if type(option.func) == "function" and not option._ultiviteFuncSaveWrapped then
                        local originalFunc = option.func
                        option.func = function(...)
                            originalFunc(...)
                            U.RequestSettingsSave(true)
                        end
                        option._ultiviteFuncSaveWrapped = true
                    end
                    if type(option.controls) == "table" then
                        wrapFabPersistence(option.controls)
                    end
                end
            end
        end
        wrapFabPersistence(mirroredOptions)
        local fabAppearance = {}
        local fabTimers = {}
        local fabOther = {}
        for _, option in ipairs(mirroredOptions or {}) do
            local optionName = type(option) == "table" and stripFabMenuColor(option.name) or ""
            if type(option) == "table" and option.type == "divider" then
                -- Section dividers were useful in FAB+'s original flat menu, but
                -- Ultivite now groups those sections into named submenus.
            elseif optionName == "Bar Rows & Visibility" or optionName == "Appearance" then
                fabAppearance[#fabAppearance + 1] = option
            elseif optionName == "Timers, Stacks & Ultimate" or optionName == "Gamepad Timer Display" or optionName == "Expiry & Alert Styling" then
                fabTimers[#fabTimers + 1] = option
            else
                fabOther[#fabOther + 1] = option
            end
        end

        if #fabAppearance > 0 then
            fabControls[#fabControls + 1] = {
                type = "submenu",
                name = "Bar Appearance & Rows",
                tooltip = "Front and back row order, inactive-row appearance, frames, highlights and other visual action-bar settings.",
                controls = fabAppearance,
            }
        end
        if #fabTimers > 0 then
            fabControls[#fabControls + 1] = {
                type = "submenu",
                name = "Timers, Stacks & Ultimate",
                tooltip = "Timer fonts, stack counters, target counters, Ultimate values, quickslot timers and expiry styling for keyboard and gamepad layouts.",
                controls = fabTimers,
            }
        end
        if #fabOther > 0 then
            fabControls[#fabControls + 1] = {
                type = "submenu",
                name = "Other Action Bar Options",
                tooltip = "Less commonly changed Fancy Action Bar options, including trade protection, enemy markers and the global cooldown tracker.",
                controls = fabOther,
            }
        end
    else
        fabControls[#fabControls + 1] = {
            type = "description",
            text = "Fancy Action Bar+ is not detected.",
            width = "full",
        }
    end

    local profileScopeOption = {
        type = "checkbox",
        name = "Use account-wide settings",
        tooltip = "When enabled, Ultivite player bars, Dark Souls layouts, combat trackers and sound suppression use one shared account profile. Fancy Action Bar+ remains a separate addon with its own SavedVariables; its account-wide skill/effect toggle is mirrored in the Action Bar section.",
        getFunc = function() return U.IsUsingAccountWideSettings() end,
        setFunc = function(value) U.SetAccountWideSettings(value, false) end,
        default = true,
        width = "full",
        warning = "Changing profile scope reloads the UI once so every Ultivite module switches to the same profile cleanly.",
    }

    local saveButton = {
        type = "button",
        name = "Save Settings",
        tooltip = "Captures live Ultivite settings plus a snapshot of the standalone Fancy Action Bar+ configuration for export/preset continuity, then requests immediate saves for both addons.",
        func = function()
            U.PersistLiveSettingsToCurrentScope()
            U.RequestSettingsSave(false)
        end,
        width = "full",
    }

    local syncButton = {
        type = "button",
        name = "Use This Setup on All Characters",
        tooltip = "Copies the current Ultivite setup into the account-wide Ultivite profile and enables FAB+ account-wide skill/effect settings. Fancy Action Bar+ itself remains a separate addon and owns its SavedVariables.",
        warning = "This replaces the existing account-wide Ultivite profile with the setup you are using now, then reloads the UI.",
        func = function() U.SyncCurrentSettingsToAccountWide() end,
        width = "full",
    }

    local reloadButton = {
        type = "button",
        name = "Reload UI",
        tooltip = "Reloads the ESO UI. Use this after settings explicitly marked as requiring a reload.",
        func = function()
            U.RequestSettingsSave(true)
            if ReloadUI then ReloadUI() end
        end,
        width = "full",
    }

    local openQuickMenuButton = {
        type = "button",
        name = "Open Quick Menu",
        tooltip = "Opens the compact Ultivite Quick Menu without requiring chat. Close it with the X button to return to these settings.",
        func = function()
            local quick = Ultivite and Ultivite.QuickMenu or nil
            if quick and quick.OpenFromSettings then
                quick.OpenFromSettings()
            else
                chat("Ultivite Quick Menu is not ready yet. Try again after the UI finishes loading.")
            end
        end,
        width = "full",
    }

    local restoreLayoutButton = {
        type = "button",
        name = "Restore Recommended Layout",
        tooltip = "Restores Ultivite's recommended normal HUD positions and recommended combat toggles without deleting profiles, sound settings or blocklists.",
        warning = "This changes your current HUD positions and recommended combat toggles. It does not erase other Ultivite settings.",
        func = function() U.ApplyDefaultCombatHUDLayout(false) end,
        width = "full",
    }

    local printPositionsButton = {
        type = "button",
        name = "Print Layout Positioning",
        tooltip = "Prints the exact player bar, Dark Souls and Fancy Action Bar positions and scales to chat for troubleshooting.",
        func = function() U.PrintLayoutPositioning() end,
        width = "full",
    }

    local showLayoutReportButton = {
        type = "button",
        name = "Show Layout Report",
        tooltip = "Opens one selectable text box containing the complete current layout and profile information. Copy it with Ctrl+C when you need to share your setup for support. Ultivite does not use ESO private clipboard APIs.",
        func = function() U.ShowLayoutReport() end,
        width = "full",
    }

    local showAllSettingsButton = {
        type = "button",
        name = "Show / Copy All Settings",
        tooltip = "Opens one selectable text box containing every configurable setting in the active Ultivite profile, including Combat, Frames, Sound and nested Fancy Action Bar settings. Runtime counters and duplicate internal default snapshots are omitted so copied exports are not cut off. Press Ctrl+C to copy it.",
        func = function() U.ShowAllSettingsExport() end,
        width = "full",
    }

    local printAllSettingsButton = {
        type = "button",
        name = "Print All Settings to Chat",
        tooltip = "Prints the complete active Ultivite profile to chat. This can be a large export. Use Show / Copy All Settings when you want one selectable block instead.",
        func = function() U.PrintAllSettings() end,
        width = "full",
    }

    local function stripCloneReferences(option)
        if type(option) ~= "table" then return option end
        -- LAM `reference` values become global control names. Quick-access
        -- copies must not reuse the original control names or LibAddonMenu
        -- will try to CreateControl() twice with the same name.
        option.reference = nil
        if type(option.controls) == "table" then
            for _, child in ipairs(option.controls) do
                stripCloneReferences(child)
            end
        end
        return option
    end

    local function addClone(destination, source)
        if source then
            destination[#destination + 1] = stripCloneReferences(deepCopy(source))
        end
    end

    local quickSetupControls = {
        deepCopy(openQuickMenuButton),
        deepCopy(profileScopeOption),
        deepCopy(saveButton),
        deepCopy(syncButton),
        deepCopy(reloadButton),
    }
    addClone(quickSetupControls, findOptionByName(frameOptions, "HUD Preset"))
    quickSetupControls[#quickSetupControls + 1] = {
        type = "dropdown",
        name = "Target Frame Mode (shortcut)",
        tooltip = "Quick shortcut to the canonical Target Frame Mode under UI Visibility > Target Frames & ESO Overhead Bars.",
        choices = { "Ultivite", "Vanilla / Default" },
        choicesValues = { "ultivite", "vanilla" },
        getFunc = function() return U.IsVanillaTargetFramesActive and U.IsVanillaTargetFramesActive() and "vanilla" or "ultivite" end,
        setFunc = function(value)
            if value == "vanilla" then U.ApplyVanillaTargetFrames(false) else U.EnableUltiviteTargetFrames(false) end
        end,
        default = "ultivite",
        width = "full",
    }

    local startControls = {}
    appendAll(startControls, quickSetupControls)
    startControls[#startControls + 1] = {
        type = "submenu",
        name = "Unified Profile Manager",
        tooltip = "Create named profiles and choose which Ultivite systems each profile controls. This manager is available only in the full settings menu.",
        controls = unifiedProfileOptions,
    }
    startControls[#startControls + 1] = {
        type = "submenu",
        name = "Resolution & UI Scale Safety",
        tooltip = "Apply a resolution-aware Ultivite HUD scale preset and repair elements that moved off screen after a display or UI scale change.",
        controls = layoutSafetyOptions,
    }

    local combatEffectsControls = {}
    addClone(combatEffectsControls, findOptionByName(combatOptions, "Combat Warnings & Resource Alerts"))
    addClone(combatEffectsControls, findOptionByName(combatOptions, "Self Effects"))
    addClone(combatEffectsControls, findOptionByName(combatOptions, "Target Effects"))

    local trackerStatsControls = {}
    addClone(trackerStatsControls, findOptionByName(combatOptions, "Set & Stack Trackers"))
    addClone(trackerStatsControls, findOptionByName(combatOptions, "Live Stats"))
    addClone(trackerStatsControls, findOptionByName(combatOptions, "PvP"))

    local advancedControls = {
        {
            type = "submenu",
            name = "Export / Copy Settings",
            tooltip = "Export every setting in your active Ultivite profile so the complete setup can be copied, shared or used as a reference.",
            controls = {
                deepCopy(showAllSettingsButton),
                deepCopy(printAllSettingsButton),
            },
        },
        {
            type = "submenu",
            name = "Layout Reset & Support",
            controls = {
                deepCopy(restoreLayoutButton),
                deepCopy(printPositionsButton),
                deepCopy(showLayoutReportButton),
            },
        },
    }
    addClone(advancedControls, findOptionByName(combatOptions, "Target Frame (Advanced)"))
    addClone(advancedControls, findOptionByName(combatOptions, "Appearance & Reset (Advanced)"))
    advancedControls[#advancedControls + 1] = {
        type = "submenu",
        name = "Diagnostics & Maintenance",
        controls = diagnosticsControls,
    }

    -- Build a canonical UI Visibility section and strip duplicate convenience
    -- copies from Player HUD / Advanced. The Quick Access target-mode entry is
    -- explicitly labelled as a shortcut so users know it controls the same state.
    local uiVisibilityControls = uiVisibilityHub and deepCopy(uiVisibilityHub.controls) or {}

    local navShowCrown = findOptionByName(uiVisibilityControls, "Show crown direction arrow")
    local navShowFeet = findOptionByName(uiVisibilityControls, "Show feet compass")
    local navAppearanceSource = findOptionByName(uiVisibilityControls, "Navigation Helper Appearance & Position")
    local nativeEsoAdvanced = findOptionByName(uiVisibilityControls, "Vanilla ESO Interface Toggles")
    local overheadInfo = findOptionByName(uiVisibilityControls, "Overhead Player Info")
    local playerNames = findOptionByName(uiVisibilityControls, "Show player names above heads")
    local nativeHideNpc = findOptionByName(uiVisibilityControls, "Hide NPC names in native mode")
    local targetMode = findOptionByName(uiVisibilityControls, "Target Frame Mode")

    uiVisibilityControls = removeNamedOptionRecursive(uiVisibilityControls, {
        ["HUD Preset"] = true,
        ["Show Dark Souls Ultimate"] = true,
        ["Show bottom Dark Souls Health bar"] = true,
        ["Show bottom Dark Souls Magicka / Stamina"] = true,
        ["Hide bottom Dark Souls bars out of combat"] = true,
        ["Bottom Dark Souls player bars only"] = true,
        ["Navigation Helpers"] = true,
        ["Show crown direction arrow"] = true,
        ["Show feet compass"] = true,
        ["Overhead Player Info"] = true,
        ["Show player names above heads"] = true,
        ["Enable Ultivite target frame"] = true,
        ["Hide stock ESO target frame"] = true,
        ["Hide LUI Extended target frame"] = true,
        ["Auto hide any other target frame"] = true,
        ["Hide default overhead Health bars"] = true,
        ["Use native overhead target bar"] = true,
        ["Hide NPC names in native mode"] = true,
        ["Target Frame Mode"] = true,
        ["Target Frames, Health Bars & Names"] = true,
        ["Action Bar Visibility"] = true,
        ["Vanilla ESO Interface Toggles"] = true,
        ["Hide all NPC names"] = true,
    })

    local generalHud = findOptionByName(uiVisibilityControls, "Player HUD & Global Visibility")
    if generalHud then generalHud.name = "General HUD Visibility" end

    local navAppearance = findOptionByName(uiVisibilityControls, "Navigation Helper Appearance & Position")
    if navAppearance then
        navAppearance.name = "Navigation Helpers"
        navAppearance.tooltip = "Show or hide Ultivite navigation helpers. Size, opacity and position are under Player HUD & Layouts."
        navAppearance.controls = {}
        if navShowCrown then navAppearance.controls[#navAppearance.controls + 1] = stripCloneReferences(deepCopy(navShowCrown)) end
        if navShowFeet then navAppearance.controls[#navAppearance.controls + 1] = stripCloneReferences(deepCopy(navShowFeet)) end
    end

    local namesControls = {}
    namesControls[#namesControls + 1] = {
        type = "checkbox",
        name = "ESO NPC names above heads",
        tooltip = "Shows or hides ESO's native enemy, friendly and neutral NPC nameplates. This is separate from Ultivite Overhead Player Info.",
        getFunc = function()
            if Combat and Combat.IsNpcNamesHidden then return not Combat.IsNpcNamesHidden() end
            local f = Frames and Frames.saved
            return not (f and f.vanillaNpcNamesHidden == true)
        end,
        setFunc = function(value)
            local f = Frames and Frames.saved
            local csv = getCombatVisibilitySettings()
            local hidden = value ~= true
            if f then f.vanillaNpcNamesHidden = hidden end
            if csv then
                csv.npcNamesGlobalHidden = hidden
                csv.npcNamesOverrideActive = true
            end
            if Combat and Combat.SetNpcNamesHidden then
                if csv then Combat.sv = csv end
                Combat.SetNpcNamesHidden(hidden)
            end
            U.RequestSettingsSave(true)
            refreshUltivitePanel()
        end,
        default = true,
        width = "full",
    }
    if playerNames then
        local playerNamesClone = stripCloneReferences(deepCopy(playerNames))
        playerNamesClone.name = "ESO player names above heads"
        playerNamesClone.tooltip = "Shows or hides ESO's native player nameplates. This is separate from Overhead Player Info, which is Ultivite's Character Name + CP/Level overlay."
        namesControls[#namesControls + 1] = playerNamesClone
    end
    if overheadInfo then namesControls[#namesControls + 1] = stripCloneReferences(deepCopy(overheadInfo)) end
    if nativeHideNpc then
        local nativeNpcClone = stripCloneReferences(deepCopy(nativeHideNpc))
        nativeNpcClone.disabled = function()
            return not (Combat and Combat.GetEnemyOverheadHealthMode and (Combat.GetEnemyOverheadHealthMode() == "target" or Combat.GetEnemyOverheadHealthMode() == "all"))
        end
        namesControls[#namesControls + 1] = nativeNpcClone
    end
    local namesMenu = {
        type = "submenu",
        name = "Player & NPC Names",
        tooltip = "ESO native player/NPC names and Ultivite's separate Character Name + CP/Level overhead overlay.",
        controls = namesControls,
    }

    local targetControls = {}
    if targetMode then targetControls[#targetControls + 1] = stripCloneReferences(deepCopy(targetMode)) end
    targetControls[#targetControls + 1] = {
        type = "dropdown",
        name = "ESO enemy overhead Health bars",
        tooltip = "Controls only the Health bars rendered above enemies in the world. This is independent from Target Frame Mode and will never switch the top-screen target frame.",
        choices = { "ESO default", "Target only", "All enemies", "Hide all" },
        choicesValues = { "vanilla", "target", "all", "off" },
        getFunc = function() return Combat and Combat.GetEnemyOverheadHealthMode and Combat.GetEnemyOverheadHealthMode() or "vanilla" end,
        setFunc = function(value)
            if Combat and Combat.SetEnemyOverheadHealthMode then Combat.SetEnemyOverheadHealthMode(value, true) end
            refreshUltivitePanel()
        end,
        default = "vanilla",
        width = "full",
    }
    local targetMenu = {
        type = "submenu",
        name = "Target Frames & ESO Overhead Bars",
        tooltip = "Target Frame Mode controls the top-screen target frame. ESO enemy overhead Health bars independently control native bars above enemies in the world.",
        controls = targetControls,
    }

    -- Put the two most commonly confused world-player controls near the top,
    -- before Compass / Quest / Queue visibility.
    local orderedVisibility = {}
    local insertedPlayerUi = false
    for _, option in ipairs(uiVisibilityControls) do
        if not insertedPlayerUi and type(option) == "table" and option.name == "Compass" then
            orderedVisibility[#orderedVisibility + 1] = namesMenu
            orderedVisibility[#orderedVisibility + 1] = targetMenu
            insertedPlayerUi = true
        end
        orderedVisibility[#orderedVisibility + 1] = option
    end
    if not insertedPlayerUi then
        orderedVisibility[#orderedVisibility + 1] = namesMenu
        orderedVisibility[#orderedVisibility + 1] = targetMenu
    end
    uiVisibilityControls = orderedVisibility
    table.insert(uiVisibilityControls, 1, {
        type = "description",
        text = "Visibility presets are batch shortcuts. Individual controls below show the current state and can override a preset. ESO Player/NPC Names are native blue nameplates; Overhead Player Info is Ultivite's separate Character Name + CP/Level overlay. Target Frame Mode controls the top-screen target frame; ESO enemy overhead bars control world-space Health bars.",
        width = "full",
    })

    -- Player HUD & Layouts keeps layout/editing controls only. Visibility and
    -- support tools live in their canonical sections instead of repeating here.
    local playerResetAdvanced = findOptionByName(frameOptions, "Player UI Reset & Diagnostics (Advanced)")
    if playerResetAdvanced then
        advancedControls[#advancedControls + 1] = stripCloneReferences(deepCopy(playerResetAdvanced))
    end
    frameOptions = removeNamedOptionRecursive(frameOptions, {
        ["UI Visibility"] = true,
        ["HUD Preset"] = true,
        ["Show combat HUD only in combat"] = true,
        ["Hide default overhead Health bars"] = true,
        ["Player UI Reset & Diagnostics (Advanced)"] = true,
        ["Show Layout Report"] = true,
    })
    if navAppearanceSource then
        local navLayout = stripCloneReferences(deepCopy(navAppearanceSource))
        navLayout.name = "Navigation Helper Appearance & Position"
        navLayout.tooltip = "Size, opacity and position for the crown arrow and feet compass. Their visibility modes are under UI Visibility."
        frameOptions[#frameOptions + 1] = navLayout
    end
    if nativeEsoAdvanced then
        local nativeAdvancedClone = stripCloneReferences(deepCopy(nativeEsoAdvanced))
        nativeAdvancedClone.name = "ESO Native UI Settings (Advanced)"
        nativeAdvancedClone.tooltip = "Direct mirrors of ESO's underlying Interface, Nameplate and Chat Bubble settings. Use only when you need finer control than Ultivite's normal visibility options."
        advancedControls[#advancedControls + 1] = nativeAdvancedClone
    end

    local presetOptionsMenu = findOptionByName(frameOptions, "Preset Options & Combat Visibility")
    if presetOptionsMenu then
        presetOptionsMenu.name = "Preset Options"
        presetOptionsMenu.tooltip = "Options specific to the selected Dark Souls layout. General hide/show controls are under UI Visibility."
    end

    -- Advanced target-frame controls keep editing/behaviour tools but not the
    -- same visibility switches exposed canonically above.
    advancedControls = removeNamedOptionRecursive(advancedControls, {
        ["Use native overhead target bar"] = true,
        ["Show health bars for ALL enemies"] = true,
        ["Hide NPC names in native mode"] = true,
        ["Enable target frame"] = true,
        ["Hide stock ESO target frame"] = true,
    })

    local graphicsControls = {}
    if U.QuickMenu and U.QuickMenu.BuildGraphicsMenuControls then
        graphicsControls = U.QuickMenu.BuildGraphicsMenuControls()
    end

    local options = {
        {
            type = "submenu",
            name = "1. Quick Access & Profiles",
            tooltip = "Common shortcuts plus profile scope, save, sync and reload controls. Detailed visibility options live in section 2.",
            controls = startControls,
        },
        {
            type = "submenu",
            name = "2. UI Visibility",
            tooltip = "Central control hub for everything Ultivite can deliberately hide, suppress or collapse.",
            controls = uiVisibilityControls,
        },
        {
            type = "submenu",
            name = "3. Player HUD & Layouts",
            controls = frameOptions,
        },
        {
            type = "submenu",
            name = "4. Combat Warnings & Effects",
            controls = combatEffectsControls,
        },
        {
            type = "submenu",
            name = "5. Trackers, Stats & PvP",
            controls = trackerStatsControls,
        },
        {
            type = "submenu",
            name = "6. Action Bar",
            controls = fabControls,
        },
        {
            type = "submenu",
            name = "7. Graphics Profiles",
            tooltip = "Create, edit and assign graphics profiles. Automatic switching uses PvP in Battlegrounds, Cyrodiil and Imperial City, and PvE everywhere else.",
            controls = graphicsControls,
        },
        {
            type = "submenu",
            name = "8. Immersive & Convenience",
            tooltip = "Temporary Immersive Mode plus independent notification cleanup controls.",
            controls = immersiveOptions,
        },
        {
            type = "submenu",
            name = "9. Sound Suppressor",
            controls = soundOptions,
        },
        {
            type = "submenu",
            name = "10. Advanced & Support",
            controls = advancedControls,
        },
    }

    options = cleanMenuTree(options)
    LAM:RegisterOptionControls(panelName, options)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
        if panel == U.panel then
            local quick = Ultivite and Ultivite.QuickMenu or nil
            if quick and quick.CloseSettingsSession then quick.CloseSettingsSession() end
            U.RequestSettingsSave(true)
        end
    end)
end

function U.OpenSettings()
    if LibAddonMenu2 and U.panel and LibAddonMenu2.OpenToPanel then
        LibAddonMenu2:OpenToPanel(U.panel)
    else
        chat("Open Settings > Addons > Ultivite.")
    end
end

function U.Initialize()
    if U.initialized then return end

    local profileDefaults = buildProfileDefaults()
    local accountDefaults = {
        useAccountWide = true,
        migrationVersion = 0,
        quickMenuSections = {},
        graphics = {},
        combat = deepCopy(profileDefaults.combat),
        frames = deepCopy(profileDefaults.frames),
        sound = deepCopy(profileDefaults.sound),
        fab = deepCopy(profileDefaults.fab),
    }
    local characterDefaults = {
        combat = deepCopy(profileDefaults.combat),
        frames = deepCopy(profileDefaults.frames),
        sound = deepCopy(profileDefaults.sound),
        fab = deepCopy(profileDefaults.fab),
    }

    -- Retain the established world-name profile parameter for both scopes. ESO
    -- character IDs are already server-specific, but removing this now would
    -- strand existing per-character settings under a different table path.
    U.accountSV = ZO_SavedVars:NewAccountWide("UltiviteSavedVariables", U.savedVersion, nil, accountDefaults, GetWorldName())
    U.characterSV = ZO_SavedVars:NewCharacterIdSettings("UltiviteCharacterSavedVariables", U.savedVersion, nil, characterDefaults, GetWorldName())
    if U.accountSV.useAccountWide == nil then U.accountSV.useAccountWide = true end

    -- Remember whether this is a genuinely fresh Ultivite profile before the
    -- legacy migration creates compatibility SavedVariables. Keeping the three
    -- factory sound entries out of Sound.defaults prevents recursive default
    -- merging from changing an existing user's personal sound blocklist.
    local freshFactoryProfile = (tonumber(U.accountSV.migrationVersion) or 0) == 0
        and type(U.accountSV.frames) == "table"
        and U.accountSV.frames.persistenceLoadCount == nil

    -- A brand-new 1.0.79 install already starts from the approved factory
    -- profile and standalone FAB owns its own defaults. Do not run historical
    -- Ultivite migrations against that fresh profile, because older migrations
    -- intentionally changed Combat Only and FAB presentation for past releases.
    if freshFactoryProfile then
        U.accountSV.migrationVersion = U.migrationVersion
    end

    U.EnsureProfiles()
    U.MigrateLegacySettings()
    U.EnsureProfiles()

    if freshFactoryProfile then
        U.accountSV.sound = U.accountSV.sound or {}
        U.characterSV.sound = U.characterSV.sound or {}
        U.accountSV.sound.blocked = deepCopy(FACTORY_SOUND_BLOCKS)
        U.characterSV.sound.blocked = deepCopy(FACTORY_SOUND_BLOCKS)
    end

    -- Account-wide means one canonical profile. Mirror that shared profile into
    -- this character's fallback table at login before any module is initialized.
    -- The modules themselves still bind directly to the account-wide tables.
    if U.IsUsingAccountWideSettings() then
        U.CopyProfile(U.accountSV, U.characterSV)
        U.characterSV.profileSyncRevision = U.accountSV.profileSyncRevision
    end

    local profile = U.GetActiveProfile()
    if FAB and FAB.RefreshRuntime then
        FAB.RefreshRuntime()
    end
    Frames.Initialize(profile.frames)
    Combat.Initialize(profile.combat)
    if U.EnemyUltimateAlerts and U.EnemyUltimateAlerts.Initialize then U.EnemyUltimateAlerts.Initialize() end
    Sound.Initialize(profile.sound)
    if Immersive and Immersive.Initialize then Immersive.Initialize(U.accountSV) end
    if LayoutSafety and LayoutSafety.Initialize then LayoutSafety.Initialize(U.accountSV) end
    if ProfileManager and ProfileManager.Initialize then ProfileManager.Initialize(U.accountSV) end

    EVENT_MANAGER:RegisterForEvent(U.name .. "ProfilePersist", EVENT_PLAYER_DEACTIVATED, function()
        -- Character swaps are the critical cross-character handoff point.
        -- Capture live module tables before ESO tears the character UI down.
        U.PersistLiveSettingsToCurrentScope()
        U.RequestSettingsSave(true)
    end)

    if profile.frames and profile.frames.defaultSettingRevertPending then
        profile.frames.defaultSettingRevertPending = false
        zo_callLater(function() U.ApplyDefaultCombatHUDLayout(true) end, 800)
    end
    if profile.frames and profile.frames.fullDarkSoulsMode then
        U.ApplyFullDarkSoulsAuxVisibility(true)
    end

    U.BuildMenu()

    SLASH_COMMANDS["/ultivite"] = function(text)
        local command = zo_strlower and zo_strlower(zo_strtrim and zo_strtrim(text or "") or (text or "")) or (text or "")
        if command == "settings" or command == "export" or command == "copysettings" then
            U.ShowAllSettingsExport()
        elseif command == "printsettings" then
            U.PrintAllSettings()
        elseif command == "layout" or command == "positions" then
            U.PrintLayoutPositioning()
        elseif command == "copy" or command == "gpt" or command == "copypositions" then
            U.ShowLayoutReport()
        elseif command == "preset" then
            U.ApplyDefaultCombatHUDLayout(false)
        elseif command == "dsself" or command == "darksoulsself" then
            U.ApplyDarkSoulsSelfPreset(false)
        elseif command == "darksouls" or command == "fulldarksouls" or command == "fullsouls" then
            U.ApplyFullDarkSoulsPreset(false)
        elseif command == "darksoulsfab" or command == "dsfab" then
            U.ApplyDarkSoulsActionBarPreset(false)
        elseif command == "reload" or command == "reloadui" then
            U.RequestSettingsSave(true)
            if ReloadUI then ReloadUI() end
        else
            U.OpenSettings()
        end
    end
    SLASH_COMMANDS["/ulti"] = SLASH_COMMANDS["/ultivite"]

    if profile.frames and profile.frames.ultiviteDefaultLayoutPending then
        zo_callLater(function()
            U.ApplyDefaultCombatHUDLayout(true)
            profile.frames.ultiviteDefaultLayoutPending = nil
            U.RequestSettingsSave(true)
        end, 300)
    end

    U.initialized = true
    chat(string.format("v%s loaded. Fancy Action Bar+ is external; Ultivite mirrors its supported settings and keeps its own HUD profile separate.", U.version))
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= U.name then return end
    EVENT_MANAGER:UnregisterForEvent(U.name, EVENT_ADD_ON_LOADED)
    U.Initialize()
end

EVENT_MANAGER:RegisterForEvent(U.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
