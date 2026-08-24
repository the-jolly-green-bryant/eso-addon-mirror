local U = Ultivite
if not U then return end

U.ProfileManager = U.ProfileManager or {}
local P = U.ProfileManager

P.sv = nil
P.initialized = false

local DEFAULT_CONTROL = {
    hud = true,
    visibility = true,
    combat = true,
    actionBar = true,
    graphics = true,
    immersive = true,
}

local FRAME_VISIBILITY_KEYS = {
    combatOnly = true,
    hideActionBar = true,
    groupFrameVisibilityMode = true,
    hideGroupFrame = true,
    championProgressVisibilityMode = true,
    hideChampionProgress = true,
    hideChampionProgressInPvp = true,
    chatVisibilityMode = true,
    autoHideChat = true,
    compassVisibilityMode = true,
    questTrackerVisibilityMode = true,
    queueStatusVisibilityMode = true,
    crosshairVisibilityMode = true,
    feetCompass = true,
    feetCompassVisibilityMode = true,
    crownDirectionArrow = true,
    crownDirectionArrowVisibilityMode = true,
    hideMountStaminaBar = true,
    hideWerewolfResourceBar = true,
    goldenPursuitsHidden = true,
    vanillaNpcNamesHidden = true,
}

local COMBAT_VISIBILITY_KEYS = {
    targetFrame = true,
    targetFrameMode = true,
    hideDefaultTargetFrame = true,
    hideLUIETargetFrame = true,
    autoHideOtherTargetFrames = true,
    enemyOverheadHealthMode = true,
    useNativeOverheadTargetBar = true,
    nativeHideNpcNames = true,
    npcNamesGlobalHidden = true,
    npcNamesOverrideActive = true,
    playerNamesGlobalHidden = true,
    overheadPlayerInfoEnabled = true,
    cpOnHover = true,
}

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = deepCopy(child) end
    return copy
end

local function copyMatching(source, predicate)
    local result = {}
    for key, value in pairs(source or {}) do
        if predicate(key) then result[key] = deepCopy(value) end
    end
    return result
end

local function mergeInto(destination, source)
    if type(destination) ~= "table" or type(source) ~= "table" then return end
    for key, value in pairs(source) do destination[key] = deepCopy(value) end
end

local function requestSave()
    if U.RequestSettingsSave then U.RequestSettingsSave(true) end
end

local function refreshLAM()
    if CALLBACK_MANAGER and U.panel then CALLBACK_MANAGER:FireCallbacks("LAM-RefreshPanel", U.panel) end
end

local function currentProfileTables()
    local active = U.GetActiveProfile and U.GetActiveProfile() or {}
    return (U.Frames and U.Frames.saved) or active.frames or {},
        (U.Combat and U.Combat.sv) or active.combat or {},
        (U.Sound and U.Sound.sv) or active.sound or {}
end

function P.CaptureCurrent()
    local frames, combat = currentProfileTables()
    local quick = U.QuickMenu
    local immersive = U.Immersive
    local fab = U.FancyActionBar
    return {
        hud = copyMatching(frames, function(key) return FRAME_VISIBILITY_KEYS[key] ~= true end),
        visibilityFrames = copyMatching(frames, function(key) return FRAME_VISIBILITY_KEYS[key] == true end),
        combat = copyMatching(combat, function(key) return COMBAT_VISIBILITY_KEYS[key] ~= true end),
        visibilityCombat = copyMatching(combat, function(key) return COMBAT_VISIBILITY_KEYS[key] == true end),
        actionBar = fab and fab.GetSnapshot and fab.GetSnapshot() or nil,
        graphics = quick and quick.GetCurrentGraphicsSettings and quick.GetCurrentGraphicsSettings() or nil,
        immersive = immersive and immersive.CaptureSnapshot and immersive.CaptureSnapshot() or nil,
    }
end

local function getSelected()
    if not P.sv then return nil end
    return P.sv.profiles[P.sv.selectedId or ""]
end

local function ensureSelected()
    if not P.sv then return nil end
    local selected = getSelected()
    if selected then return selected end
    P.sv.selectedId = P.sv.order[1]
    return getSelected()
end

local function nextId()
    P.sv.nextId = (tonumber(P.sv.nextId) or 0) + 1
    local id = "profile_" .. tostring(P.sv.nextId)
    while P.sv.profiles[id] do
        P.sv.nextId = P.sv.nextId + 1
        id = "profile_" .. tostring(P.sv.nextId)
    end
    return id
end

function P.CreateFromCurrent(name)
    if not P.sv then return false end
    name = tostring(name or P.sv.pendingName or "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then name = "Ultivite Profile " .. tostring(#P.sv.order + 1) end
    local id = nextId()
    P.sv.profiles[id] = {
        name = name,
        controls = deepCopy(DEFAULT_CONTROL),
        snapshot = P.CaptureCurrent(),
    }
    P.sv.order[#P.sv.order + 1] = id
    P.sv.selectedId = id
    P.sv.pendingName = ""
    requestSave()
    refreshLAM()
    if d then d("[Ultivite] Created unified profile: " .. name .. ".") end
    return true
end

function P.UpdateSelected()
    local selected = ensureSelected()
    if not selected then return false end
    selected.snapshot = P.CaptureCurrent()
    requestSave()
    if d then d("[Ultivite] Updated unified profile: " .. tostring(selected.name) .. ".") end
    return true
end

function P.RenameSelected()
    local selected = ensureSelected()
    if not selected then return false end
    local name = tostring(P.sv.pendingName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return false end
    selected.name = name
    P.sv.pendingName = ""
    requestSave()
    refreshLAM()
    return true
end

function P.DeleteSelected()
    if not P.sv or #P.sv.order <= 1 then return false end
    local id = P.sv.selectedId
    P.sv.profiles[id] = nil
    for index, value in ipairs(P.sv.order) do
        if value == id then table.remove(P.sv.order, index); break end
    end
    P.sv.selectedId = P.sv.order[1]
    requestSave()
    refreshLAM()
    return true
end

local function refreshRuntime()
    local frames = U.Frames
    local combat = U.Combat
    if frames then
        if frames.ApplyPositions then frames.ApplyPositions() end
        if frames.ApplyBarGeometry then frames.ApplyBarGeometry() end
        if frames.ApplyTextStyle then frames.ApplyTextStyle() end
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
        if combat.UpdateCombatTimers then combat.UpdateCombatTimers() end
        if combat.UpdateLiveStatWidgets then combat.UpdateLiveStatWidgets(true) end
        if combat.ScanPlayerAuraHud then combat.ScanPlayerAuraHud() end
        if combat.ScanTargetAuras then combat.ScanTargetAuras() end
        if combat.UpdateImportantTargetDebuffs then combat.UpdateImportantTargetDebuffs(true) end
        if combat.UpdateCombatDangerWarnings then combat.UpdateCombatDangerWarnings(true) end
        if combat.UpdateResourceDangerHud then combat.UpdateResourceDangerHud(true) end
        if combat.UpdateFoodWarning then combat.UpdateFoodWarning() end
        if combat.UpdateMajorResolveWarning then combat.UpdateMajorResolveWarning() end
        if combat.UpdateMajorBreachDisplay then combat.UpdateMajorBreachDisplay() end
        if combat.ApplyNativeOverheadTargetBar then combat.ApplyNativeOverheadTargetBar() end
        if combat.ApplyDefaultTargetFrameVisibility then combat.ApplyDefaultTargetFrameVisibility() end
        if combat.UpdateOverheadPlayerInfo then combat.UpdateOverheadPlayerInfo() end
    end
    if U.EnemyUltimateAlerts and U.EnemyUltimateAlerts.RefreshEventRegistration then U.EnemyUltimateAlerts.RefreshEventRegistration() end
    if U.EnemyUltimateAlerts and U.EnemyUltimateAlerts.Update then U.EnemyUltimateAlerts.Update(true) end
    if U.QuickMenu and U.QuickMenu.Refresh then U.QuickMenu.Refresh() end
end

function P.ApplySelected()
    local selected = ensureSelected()
    if not selected or type(selected.snapshot) ~= "table" then return false end
    selected.controls = selected.controls or deepCopy(DEFAULT_CONTROL)
    local controls = selected.controls
    local snapshot = selected.snapshot
    local frames, combat = currentProfileTables()

    if controls.hud ~= false then mergeInto(frames, snapshot.hud) end
    if controls.visibility ~= false then
        mergeInto(frames, snapshot.visibilityFrames)
        mergeInto(combat, snapshot.visibilityCombat)
    end
    if controls.combat ~= false then mergeInto(combat, snapshot.combat) end
    if controls.actionBar ~= false and snapshot.actionBar and U.FancyActionBar and U.FancyActionBar.ApplyProfileSnapshot then
        U.FancyActionBar.ApplyProfileSnapshot(snapshot.actionBar)
    end
    if controls.graphics ~= false and snapshot.graphics and U.QuickMenu and U.QuickMenu.ApplyGraphicsSettingsSnapshot then
        U.QuickMenu.ApplyGraphicsSettingsSnapshot(snapshot.graphics, true)
    end
    if controls.immersive ~= false and snapshot.immersive and U.Immersive and U.Immersive.ApplySnapshot then
        U.Immersive.ApplySnapshot(snapshot.immersive, true)
    end

    -- Unified profiles may have been captured under another resolution preset.
    -- Rebase the imported layout to the display preset that is active on this
    -- client before any controls are refreshed, so a 4K snapshot cannot appear
    -- oversized or off-screen on a 1080p canvas.
    if U.LayoutSafety and U.LayoutSafety.NormalizeActiveProfile then
        U.LayoutSafety.NormalizeActiveProfile(true)
    end

    refreshRuntime()
    if U.PersistLiveSettingsToCurrentScope then U.PersistLiveSettingsToCurrentScope() end
    requestSave()
    refreshLAM()
    if d then d("[Ultivite] Applied unified profile: " .. tostring(selected.name) .. ".") end
    return true
end

function P.GetSelectedName()
    local selected = ensureSelected()
    return selected and tostring(selected.name or "Unnamed") or "None"
end

local function profileChoices()
    local labels, values = {}, {}
    for _, id in ipairs(P.sv and P.sv.order or {}) do
        local profile = P.sv.profiles[id]
        if profile then labels[#labels + 1] = tostring(profile.name or id); values[#values + 1] = id end
    end
    return labels, values
end

local function controlCheckbox(name, key, tooltip)
    return {
        type = "checkbox", name = name, tooltip = tooltip,
        getFunc = function()
            local selected = ensureSelected()
            return selected and selected.controls and selected.controls[key] ~= false
        end,
        setFunc = function(value)
            local selected = ensureSelected()
            if not selected then return end
            selected.controls = selected.controls or deepCopy(DEFAULT_CONTROL)
            selected.controls[key] = value == true
            requestSave()
        end,
        default = true, width = "full",
    }
end

function P.GetMenuOptions()
    return {
        { type = "description", title = "Unified Profile Manager", text = "Profiles are account-wide named snapshots. Each profile decides which Ultivite systems it owns when applied. Systems you uncheck are left exactly as they are." },
        { type = "dropdown", name = "Selected profile",
            choices = function() local labels = profileChoices(); return labels end,
            choicesValues = function() local _, values = profileChoices(); return values end,
            getFunc = function() return P.sv and P.sv.selectedId end,
            setFunc = function(value) if P.sv and P.sv.profiles[value] then P.sv.selectedId = value; requestSave(); refreshLAM() end end,
            width = "full" },
        { type = "editbox", name = "New or renamed profile name", isMultiline = false,
            getFunc = function() return P.sv and tostring(P.sv.pendingName or "") or "" end,
            setFunc = function(value) if P.sv then P.sv.pendingName = tostring(value or ""); requestSave() end end,
            width = "full" },
        { type = "button", name = "Create Profile From Current Setup", func = function() P.CreateFromCurrent() end, width = "full" },
        { type = "button", name = "Apply Selected Profile", func = P.ApplySelected, width = "full" },
        { type = "button", name = "Update Selected From Current Setup", func = P.UpdateSelected, width = "full" },
        { type = "button", name = "Rename Selected", func = P.RenameSelected, width = "half" },
        { type = "button", name = "Delete Selected", func = P.DeleteSelected, isDangerous = true,
            disabled = function() return not P.sv or #P.sv.order <= 1 end, width = "half" },
        { type = "submenu", name = "Systems Controlled By Selected Profile", controls = {
            controlCheckbox("Player HUD and layouts", "hud", "Bars, positions, sizes and Dark Souls layout state."),
            controlCheckbox("UI visibility", "visibility", "ESO HUD visibility, target-frame ownership, names, overhead bars and navigation visibility."),
            controlCheckbox("Combat trackers and warnings", "combat", "Combat information, trackers, warnings, PvP counters and their layout."),
            controlCheckbox("Fancy Action Bar", "actionBar", "The supported Fancy Action Bar snapshot stored with this profile."),
            controlCheckbox("Graphics", "graphics", "The live ESO graphics values captured when this profile was saved."),
            controlCheckbox("Immersive profile", "immersive", "The selected Immersive profile and its hide configuration."),
        } },
    }
end

function P.Initialize(accountSV)
    if P.initialized or not accountSV then return end
    P.initialized = true
    accountSV.unifiedProfileManager = accountSV.unifiedProfileManager or {
        profiles = {}, order = {}, selectedId = nil, nextId = 0, pendingName = "",
    }
    P.sv = accountSV.unifiedProfileManager
    P.sv.profiles = type(P.sv.profiles) == "table" and P.sv.profiles or {}
    P.sv.order = type(P.sv.order) == "table" and P.sv.order or {}
    if #P.sv.order == 0 then P.CreateFromCurrent("Current Setup") end
    ensureSelected()
end
