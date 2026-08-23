local U = Ultivite

-- Ultivite does not embed Fancy Action Bar+. This bridge talks to the separately
-- installed addon and mirrors safe FAB settings into Ultivite's menu.
local B = {}
U.FancyActionBar = B
local COMBAT_VISIBILITY_OWNER = "CombatOnlyActionBar"

local function getFab()
    return _G.FancyActionBar
end

-- Read-through compatibility for the small set of native FAB+ runtime methods
-- Ultivite invokes from its mirrored controls. The bridge keeps its own wrapper
-- methods when defined, while unknown fields resolve against the installed FAB+
-- object. This also keeps dynamic fields such as style/constants current.
setmetatable(B, {
    __index = function(_, key)
        local fab = getFab()
        if type(fab) == "table" then return fab[key] end
        return nil
    end,
})

local function getVersion()
    local fab = getFab()
    if fab and fab.GetVersion then
        local ok, value = pcall(fab.GetVersion)
        if ok and value then return tostring(value) end
    end
    return "unknown"
end

function B.IsAvailable()
    return type(getFab()) == "table"
end

function B.GetSettings()
    local fab = getFab()
    if not fab or not ZO_SavedVars then return nil end
    return ZO_SavedVars:NewAccountWide(
        "FancyActionBarSV",
        tonumber(fab.variableVersion) or 1,
        nil,
        fab.defaultSettings or {},
        GetWorldName()
    )
end

function B.GetCharacterSettings()
    local fab = getFab()
    if not fab or not ZO_SavedVars then return nil end
    return ZO_SavedVars:NewCharacterIdSettings(
        "FancyActionBarSV",
        tonumber(fab.variableVersion) or 1,
        nil,
        fab.defaultCharacter or {},
        GetWorldName()
    )
end

local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = deepCopy(child)
    end
    return copy
end

local function syncKnown(destination, source, defaults)
    if type(destination) ~= "table" or type(source) ~= "table" then return end
    defaults = type(defaults) == "table" and defaults or source
    for key in pairs(defaults) do
        local value = source[key]
        if value ~= nil then
            destination[key] = deepCopy(value)
        end
    end
end

function B.GetSnapshot()
    local fab = getFab()
    local sv = B.GetSettings()
    local cv = B.GetCharacterSettings()
    return {
        enabled = B.IsAvailable(),
        sourceVersion = getVersion(),
        settings = deepCopy(sv or (fab and fab.defaultSettings) or {}),
        character = deepCopy(cv or (fab and fab.defaultCharacter) or {}),
    }
end

function B.ApplyProfileSnapshot(snapshot)
    local fab = getFab()
    if not fab or type(snapshot) ~= "table" then return false end

    local sv = B.GetSettings()
    local cv = B.GetCharacterSettings()
    if not sv or not cv then return false end

    syncKnown(sv, snapshot.settings or {}, fab.defaultSettings or {})
    syncKnown(cv, snapshot.character or {}, fab.defaultCharacter or {})
    if snapshot.character and snapshot.character.useAccountWide ~= nil then
        cv.useAccountWide = snapshot.character.useAccountWide and true or false
    end

    B.RefreshRuntime()
    return true
end

function B.SetUseAccountWide(value)
    local cv = B.GetCharacterSettings()
    if not cv then return end
    cv.useAccountWide = value and true or false
end

function B.RefreshRuntime()
    local fab = getFab()
    if not fab then return end

    local calls = {
        { "UpdateStyle" },
        { "RefreshLayoutConstants" },
        { "UpdateDurationLimits" },
        { "RefreshHighlightConfiguration" },
        { "SetScale" },
        { "RefreshBarPosition", true },
        { "RefreshActiveBarSlots" },
        { "UpdateWeaponSwapControlVisibility" },
        { "RefreshEffectWidgets" },
        { "UpdateUltimateValueLabels" },
    }
    for _, call in ipairs(calls) do
        local fn = fab[call[1]]
        if type(fn) == "function" then
            pcall(fn, unpack(call, 2))
        end
    end
end

function B.RequestSave()
    if RequestAddOnSavedVariablesPrioritySave then
        RequestAddOnSavedVariablesPrioritySave("FancyActionBar+")
    end
end

function B.CommitMoverPosition()
    local fab = getFab()
    if not fab or type(fab.SaveMoverPosition) ~= "function" then return false end

    local ok = pcall(fab.SaveMoverPosition)
    if ok then B.RequestSave() end
    return ok
end

local function getModeKey()
    local fab = getFab()
    return fab and fab.style == 2 and "gp" or "kb"
end

function B.GetWholeActionBarPosition()
    local sv = B.GetSettings()
    if not sv then return 0, 0 end
    local key = getModeKey()
    local move = sv.abMove and sv.abMove[key]
    return tonumber(move and move.x) or 0, tonumber(move and move.y) or 0
end

function B.SetWholeActionBarPosition(x, y)
    local fab = getFab()
    local sv = B.GetSettings()
    if not fab or not sv then return end

    local key = getModeKey()
    sv.abMove = sv.abMove or {}
    sv.abMove[key] = sv.abMove[key] or {}
    local move = sv.abMove[key]
    move.enable = true
    move.x = tonumber(x) or 0
    move.y = tonumber(y) or 0
    move.prevX = move.x
    move.prevY = move.y

    if fab.constants and fab.constants.move then
        fab.constants.move.enable = true
        fab.constants.move.x = move.x
        fab.constants.move.y = move.y
    end

    local bar = GetControl and GetControl("ZO_ActionBar1") or ZO_ActionBar1
    if bar and bar.ClearAnchors and bar.SetAnchor then
        bar:ClearAnchors()
        bar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, move.x, move.y)
    end
    if fab.SetMoved then pcall(fab.SetMoved, true) end
    if fab.ReanchorMover then pcall(fab.ReanchorMover) end
    B.RequestSave()
end

function B.GetWholeActionBarVisualBounds()
    local bar = GetControl and GetControl("ZO_ActionBar1") or ZO_ActionBar1
    if not bar then return nil end
    local left = bar.GetLeft and bar:GetLeft() or 0
    local top = bar.GetTop and bar:GetTop() or 0
    local right = bar.GetRight and bar:GetRight() or left
    local bottom = bar.GetBottom and bar:GetBottom() or top
    return left, top, right, bottom
end

-- Ultivite's strict combat-only rule remains an Ultivite HUD feature. FAB+
-- uses ESO's ZO_ActionBar1 as its action-bar root, so this bridge owns only the
-- root visibility state while FAB+ continues to own layout, slots and effects.
local function scheduleCombatEntryHandoff(generation)
    if type(zo_callLater) ~= "function" then return end
    local function applyAfterEsoRefresh()
        if generation ~= B.combatVisibilityGeneration then return end
        if not (IsUnitInCombat and IsUnitInCombat("player")) then return end
        local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
        local frames = profile and profile.frames
        if not frames or frames.combatOnly ~= true or frames.hideActionBar == true then return end
        B.ApplyCombatOnlyVisibility(true)
    end
    zo_callLater(applyAfterEsoRefresh, 0)
    zo_callLater(applyAfterEsoRefresh, 100)
end

function B.ApplyCombatOnlyVisibility(forceVisible)
    local profile = U.GetActiveProfile and U.GetActiveProfile() or nil
    local frames = profile and profile.frames
    if not frames then return false end

    local bar = GetControl and GetControl("ZO_ActionBar1") or ZO_ActionBar1
    if not bar then return false end

    local ownership = U.Ownership
    local wasHidden = bar.IsHidden and bar:IsHidden() or false
    local inCombat = IsUnitInCombat and IsUnitInCombat("player") or false
    local shouldHideForCombat = forceVisible ~= true and frames.combatOnly == true and not inCombat
    local firstVisibilityDecision = B.lastCombatOnlyEnabled == nil
    local previousInCombat = B.lastCombatVisibilityInCombat
    local enteringCombat = frames.combatOnly == true and inCombat and previousInCombat ~= true
    local combatOnlyDisabled = frames.combatOnly ~= true and B.lastCombatOnlyEnabled == true
    local combatOnlyEnabled = frames.combatOnly == true and B.lastCombatOnlyEnabled ~= true
    if previousInCombat == nil or previousInCombat ~= inCombat then
        B.combatVisibilityGeneration = (tonumber(B.combatVisibilityGeneration) or 0) + 1
    end
    B.lastCombatVisibilityInCombat = inCombat
    B.lastCombatOnlyEnabled = frames.combatOnly == true
    if enteringCombat and frames.hideActionBar ~= true then
        scheduleCombatEntryHandoff(B.combatVisibilityGeneration)
    end

    if ownership and ownership.AcquireControl and ownership.ReleaseControl then
        local releasedCombatOwner = false
        if shouldHideForCombat then
            ownership.AcquireControl(COMBAT_VISIBILITY_OWNER, bar)
        else
            releasedCombatOwner = ownership.ReleaseControl(COMBAT_VISIBILITY_OWNER, bar)
        end

        -- The explicit Hide Action Bar option and every temporary visibility
        -- owner have priority over Combat HUD and edit visibility.
        if frames.hideActionBar == true then
            B.combatVisibilityWasBlocked = true
            local enforced = ownership.EnforceControl and ownership.EnforceControl(bar)
            if not enforced and bar.SetHidden then bar:SetHidden(true) end
            return true
        end
        if ownership.EnforceControl and ownership.EnforceControl(bar) then
            B.combatVisibilityWasBlocked = true
            return true
        end

        local ownerJustReleased = B.combatVisibilityWasBlocked == true
        B.combatVisibilityWasBlocked = false
        local shouldShowOnce = forceVisible == true
            or enteringCombat
            or (releasedCombatOwner and frames.combatOnly ~= true)
            or combatOnlyDisabled
            or (combatOnlyEnabled and inCombat)
            or (firstVisibilityDecision and frames.combatOnly ~= true)
            or (ownerJustReleased and (frames.combatOnly ~= true or inCombat))

        -- A transition into a visible state gets one deliberate show. Later
        -- reconciliation leaves the root alone so ESO and FAB+ can manage scene
        -- and presentation visibility without a competing periodic writer.
        if shouldShowOnce and bar.SetHidden then bar:SetHidden(false) end
    else
        local shouldShow = forceVisible == true or not shouldHideForCombat
        if frames.hideActionBar == true then shouldShow = false end
        if bar.SetHidden then bar:SetHidden(not shouldShow) end
    end

    -- When Ultivite reveals a FAB root that was hidden out of combat, let FAB+
    -- immediately refresh the pieces it owns so the visible bar is fully live.
    local isHidden = bar.IsHidden and bar:IsHidden() or false
    if wasHidden and not isHidden then
        local fab = getFab()
        if fab then
            if type(fab.RefreshBarPosition) == "function" then
                pcall(fab.RefreshBarPosition, true)
            end
            if type(fab.RefreshActiveBarSlots) == "function" then
                pcall(fab.RefreshActiveBarSlots)
            end
            if type(fab.UpdateUltimateValueLabels) == "function" then
                pcall(fab.UpdateUltimateValueLabels)
            end
        end
    end

    return true
end

function B.OpenExternalSettings()
    local fab = getFab()
    if not fab or not LibAddonMenu2 then return false end
    local panelName = (fab.GetName and fab.GetName() or "FancyActionBar+") .. "Menu"
    local panel = (WINDOW_MANAGER and WINDOW_MANAGER.GetControlByName and WINDOW_MANAGER:GetControlByName(panelName))
        or (GetControl and GetControl(panelName))
    if panel and LibAddonMenu2.OpenToPanel then
        LibAddonMenu2:OpenToPanel(panel)
        return true
    end
    return false
end

local function stripColor(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

-- FAB+ 2.19.6 does not expose its LAM option table as an API. To avoid copying
-- FAB's menu source, Ultivite asks FAB to build a fresh option table at runtime
-- while temporarily intercepting only the LAM registration calls. The sections
-- with named cross-control references stay in FAB's own panel to prevent duplicate
-- control names and fragile coupling.
function B.BuildMenu()
    local fab = getFab()
    local lam = LibAddonMenu2
    local sv = B.GetSettings()
    local cv = B.GetCharacterSettings()
    if not fab or not lam or not sv or not cv or type(fab.BuildMenu) ~= "function" then
        return {}
    end

    local captured = nil
    local dummyPanel = {}
    local oldRegisterAddonPanel = lam.RegisterAddonPanel
    local oldRegisterOptionControls = lam.RegisterOptionControls
    local oldRegisterCallback = CALLBACK_MANAGER and CALLBACK_MANAGER.RegisterCallback

    lam.RegisterAddonPanel = function() return dummyPanel end
    lam.RegisterOptionControls = function(_, _, options)
        captured = options
    end
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER.RegisterCallback = function() end
    end

    local ok = pcall(fab.BuildMenu, sv, cv, fab.defaultSettings or {})

    lam.RegisterAddonPanel = oldRegisterAddonPanel
    lam.RegisterOptionControls = oldRegisterOptionControls
    if CALLBACK_MANAGER then
        CALLBACK_MANAGER.RegisterCallback = oldRegisterCallback
    end

    if not ok or type(captured) ~= "table" then return {} end

    local unsafeTopLevel = {
        ["UI Presets"] = true,
        ["Actionbar Size & Position"] = true,
        ["Ability Configuration"] = true,
    }

    local safe = {}
    for _, option in ipairs(captured) do
        if type(option) == "table" then
            local name = stripColor(option.name)
            if not unsafeTopLevel[name] then
                safe[#safe + 1] = option
            end
        end
    end
    return safe
end

setmetatable(B, {
    __index = function(_, key)
        local fab = getFab()
        if not fab then return nil end
        return fab[key]
    end,
})
