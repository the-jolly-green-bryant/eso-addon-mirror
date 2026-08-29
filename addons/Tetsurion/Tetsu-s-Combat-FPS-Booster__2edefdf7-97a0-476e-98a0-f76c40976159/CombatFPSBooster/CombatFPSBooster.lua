local ADDON_NAME = "CombatFPSBooster"
CombatFPSBooster = CombatFPSBooster or {}

local defaultSettings = {
    hideCompass = true,
    hideQuests  = true,
    hideAlerts  = true,
    dungeonFilterEnabled = false,
    dungeonNeeded = {},
    dungeonSnapshot = nil,
    dungeonProfileApplied = false,
    dungeonReloadPending = false,
}

local isApplying = false
local scenesHooked = false
local APPLY_RETRY_MS = 150
local FILTER_DELAY_MS = 4000
local RELOAD_DELAY_MS = 1500
local QUEUE_STEP_MS = 50

local PROTECTED = {
    CombatFPSBooster = true,
    LibHarvensAddonSettings = true,
    CrutchAlerts = true,
}

local function L(key, fallback)
    local loc = CombatFPSBooster.L or {}
    return loc[key] or fallback
end

local function SafeSetState(control, hide)
    if not control then return end
    if control.SetHidden then
        control:SetHidden(hide)
    end
    if control.SetAlpha then
        control:SetAlpha(hide and 0 or 1)
    end
end

local function SetCompassHidden(hide)
    if ZO_CompassFrame then
        SafeSetState(ZO_CompassFrame, hide)
    end
    if ZO_Compass then
        SafeSetState(ZO_Compass, hide)
    end
    if COMPASS_FRAME and COMPASS_FRAME.SetCustomPinsEnabled then
        COMPASS_FRAME:SetCustomPinsEnabled(not hide)
    end
end

local function SetQuestTrackerHidden(hide)
    if ZO_FocusedQuestTrackerPanel_Gamepad then
        SafeSetState(ZO_FocusedQuestTrackerPanel_Gamepad, hide)
    end
    if ZO_FocusedQuestTrackerPanel then
        SafeSetState(ZO_FocusedQuestTrackerPanel, hide)
    end
end

local function SetAlertsHidden(hide)
    if ZO_AlertTextNotification then
        SafeSetState(ZO_AlertTextNotification, hide)
    end
    if ZO_CenterScreenAnnounce then
        SafeSetState(ZO_CenterScreenAnnounce, hide)
    end
end

local function ApplyCombatVisualState(inCombat)
    if isApplying then return end
    isApplying = true

    local ok = pcall(function()
        local vars = CombatFPSBooster.savedVars
        if not vars then return end

        if type(inCombat) ~= "boolean" then
            inCombat = IsUnitInCombat("player")
        end

        if vars.hideCompass then
            SetCompassHidden(inCombat)
        else
            SetCompassHidden(false)
        end

        if vars.hideQuests then
            SetQuestTrackerHidden(inCombat)
        else
            SetQuestTrackerHidden(false)
        end

        if vars.hideAlerts then
            SetAlertsHidden(inCombat)
        else
            SetAlertsHidden(false)
        end

        if not inCombat and collectgarbage then
            collectgarbage("step", 100)
        end
    end)

    isApplying = false
    return ok
end

local function RequestApplyCombatVisualState(delayMs, timerKey)
    delayMs = delayMs or 0
    local name = ADDON_NAME .. (timerKey or "_CombatApplyDelay")
    EVENT_MANAGER:UnregisterForUpdate(name)

    if delayMs <= 0 then
        ApplyCombatVisualState(IsUnitInCombat("player"))
        return
    end

    EVENT_MANAGER:RegisterForUpdate(name, delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(name)
        ApplyCombatVisualState(IsUnitInCombat("player"))
    end)
end

local function RequestApplyWithRetry(firstDelay)
    firstDelay = firstDelay or 0
    RequestApplyCombatVisualState(firstDelay, "_CombatApplyDelay")
    RequestApplyCombatVisualState(firstDelay + APPLY_RETRY_MS, "_CombatApplyRetry")
end

local function OnPlayerCombatState(eventCode, inCombat)
    if inCombat then
        RequestApplyWithRetry(0)
    else
        RequestApplyWithRetry(200)
    end
end

local function OnPlayerAlive(eventCode)
    RequestApplyCombatVisualState(500)
end

local function OnRespawnResult(eventCode, result)
    RequestApplyCombatVisualState(500)
end

local function OnPlayerDead(eventCode)
    RequestApplyCombatVisualState(100)
end

local function HookHudScenes()
    if scenesHooked or not SCENE_MANAGER or not SCENE_MANAGER.GetScene then
        return
    end

    local function OnSceneState(_, newState)
        if newState == SCENE_SHOWN or newState == SCENE_SHOWING then
            RequestApplyWithRetry()
        end
    end

    local function HookNamed(name)
        local ok, scene = pcall(function()
            return SCENE_MANAGER:GetScene(name)
        end)
        if ok and scene and scene.RegisterCallback then
            scene:RegisterCallback("StateChange", OnSceneState)
        end
    end

    HookNamed("hud")
    HookNamed("hudui")
    scenesHooked = true
end

-- ---------------------------------------------------------------------------
-- Dungeon addon filter
-- ---------------------------------------------------------------------------

local function ChatMsg(text)
    if not text or text == "" then return end
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        pcall(function() CHAT_ROUTER:AddSystemMessage(text) end)
    elseif CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        pcall(function() CHAT_SYSTEM:AddMessage(text) end)
    else
        d(text)
    end
    if ZO_Alert then
        pcall(ZO_Alert, UI_ALERT_CATEGORY_ALERT, SOUNDS and SOUNDS.NONE or nil, text)
    end
end

local function StripColor(text)
    if not text then return "" end
    text = tostring(text)
    text = text:gsub("|c[%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f]", "")
    text = text:gsub("|r", "")
    return text
end

local function IsProtectedName(name, isLibrary)
    if not name then return true end
    if PROTECTED[name] then return true end
    local lower = string.lower(name)
    if lower == "crutchalerts" then return true end
    if isLibrary then return true end
    if name:sub(1, 3) == "Lib" then return true end
    return false
end

local function GetManager()
    if GetAddOnManager then
        local ok, mgr = pcall(GetAddOnManager)
        if ok and mgr then
            return mgr
        end
    end
    return nil
end

local function InfoAt(index)
    local mgr = GetManager()
    if mgr and mgr.GetAddOnInfo then
        local ok, name, title, author, description, enabled, state, isOutOfDate, isLibrary = pcall(function()
            return mgr:GetAddOnInfo(index)
        end)
        if ok and name then
            return name, title, author, description, enabled, state, isOutOfDate, isLibrary
        end
    end
    if GetAddOnInfo then
        local ok, name, title, author, description, enabled, state, isOutOfDate, isLibrary = pcall(GetAddOnInfo, index)
        if ok and name then
            return name, title, author, description, enabled, state, isOutOfDate, isLibrary
        end
    end
    return nil
end

local function NumAddOns()
    local mgr = GetManager()
    if mgr and mgr.GetNumAddOns then
        local ok, n = pcall(function() return mgr:GetNumAddOns() end)
        if ok and type(n) == "number" then
            return n
        end
    end
    if GetNumAddOns then
        local ok, n = pcall(GetNumAddOns)
        if ok and type(n) == "number" then
            return n
        end
    end
    return 0
end

local function ListManagedAddons()
    local list = {}
    local n = NumAddOns()
    for i = 1, n do
        local name, title, _, _, enabled, _, _, isLibrary = InfoAt(i)
        if name and not IsProtectedName(name, isLibrary) then
            list[#list + 1] = {
                index = i,
                name = name,
                title = StripColor(title or name),
                enabled = enabled and true or false,
            }
        end
    end
    table.sort(list, function(a, b)
        return (a.title or a.name) < (b.title or b.name)
    end)
    return list
end

local function IsAddonEnabledNow(entry)
    if not entry then return false end
    local _, _, _, _, enabled = InfoAt(entry.index)
    if type(enabled) == "boolean" then
        return enabled
    end
    return entry.enabled and true or false
end

local function SetAddonEnabledSafe(entry, enabled)
    if not entry or not entry.index then return false end
    local mgr = GetManager()
    if mgr and mgr.SetAddOnEnabled then
        local ok = pcall(function() mgr:SetAddOnEnabled(entry.index, enabled) end)
        if ok then return true end
    end
    if SetAddOnEnabled then
        local ok = pcall(SetAddOnEnabled, entry.index, enabled)
        if ok then return true end
        ok = pcall(SetAddOnEnabled, entry.name, enabled)
        if ok then return true end
    end
    return false
end

local lastZoneDisplayType = nil

local function InPveInstance()
    if GetCurrentHouseId then
        local ok, houseId = pcall(GetCurrentHouseId)
        if ok and houseId and houseId > 0 then
            return false
        end
    end
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then
        return false
    end

    if IsInstanceEndlessDungeon then
        local ok, endless = pcall(IsInstanceEndlessDungeon)
        if ok and endless then
            return true
        end
    end

    local t = lastZoneDisplayType
    if t then
        if t == ZONE_DISPLAY_TYPE_DELVE
            or t == ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON
            or t == ZONE_DISPLAY_TYPE_GROUP_DELVE then
            return false
        end
        if t == ZONE_DISPLAY_TYPE_DUNGEON
            or t == ZONE_DISPLAY_TYPE_RAID
            or t == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON then
            return true
        end
    end

    if IsPlayerInRaid then
        local ok, raid = pcall(IsPlayerInRaid)
        if ok and raid then
            return true
        end
    end

    local diff = 0
    if GetCurrentZoneDungeonDifficulty then
        local ok, d = pcall(GetCurrentZoneDungeonDifficulty)
        if ok and type(d) == "number" then
            diff = d
        end
    end
    -- Делв и паб: difficulty 0. Групповой данж / триал / арена: > 0.
    if IsUnitInDungeon and IsUnitInDungeon("player") and diff > 0 then
        return true
    end
    return false
end

local function OnPrepareForJump(_, zoneName, zoneDescription, loadingTexture, zoneDisplayType)
    lastZoneDisplayType = zoneDisplayType
end

local filterBusy = false
local pendingJobs = {}

local function CountNeeded(vars, managed)
    local needed = vars.dungeonNeeded or {}
    local n = 0
    managed = managed or ListManagedAddons()
    for _, entry in ipairs(managed) do
        if needed[entry.name] == true then
            n = n + 1
        end
    end
    return n
end

local function ScheduleReload(kind)
    local vars = CombatFPSBooster.savedVars
    if vars then
        -- pending только после релога ЗА данжный набор. Релог выхода его не ставит.
        vars.dungeonReloadPending = (kind == "dungeon")
    end
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonReload")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_DungeonReload", RELOAD_DELAY_MS, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonReload")
        filterBusy = false
        if ReloadUI then
            pcall(ReloadUI)
        end
    end)
end

local function StopJobQueue()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonQueue")
    pendingJobs = {}
end

local function RunJobQueueTick()
    if IsUnitInCombat and IsUnitInCombat("player") then
        return
    end
    if #pendingJobs == 0 then
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonQueue")
        local vars = CombatFPSBooster.savedVars
        if vars and vars._filterNeedReload then
            local kind = vars._filterNeedReload
            vars._filterNeedReload = nil
            ScheduleReload(kind)
        else
            filterBusy = false
        end
        return
    end
    local job = table.remove(pendingJobs, 1)
    pcall(SetAddonEnabledSafe, job.entry, job.enabled)
end

local function StartJobQueue()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonQueue")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_DungeonQueue", QUEUE_STEP_MS, RunJobQueueTick)
end

local function DungeonLayoutMatches(needed, managed)
    needed = needed or {}
    managed = managed or ListManagedAddons()
    for _, entry in ipairs(managed) do
        local wantOn = needed[entry.name] == true
        if IsAddonEnabledNow(entry) ~= wantOn then
            return false
        end
    end
    return true
end

local function ApplyDungeonProfile()
    local vars = CombatFPSBooster.savedVars
    if not vars or not vars.dungeonFilterEnabled then
        return
    end

    local managed = ListManagedAddons()
    if CountNeeded(vars, managed) < 1 then
        ChatMsg(L("FILTER_EMPTY_WARN", "Combat FPS Booster: dungeon filter is on, but no addons are marked as needed. Nothing was changed."))
        return
    end

    local needed = vars.dungeonNeeded or {}

    if DungeonLayoutMatches(needed, managed) then
        vars.dungeonProfileApplied = true
        vars.dungeonReloadPending = false
        return
    end

    if vars.dungeonReloadPending then
        vars.dungeonReloadPending = false
        vars.dungeonProfileApplied = true
        ChatMsg(L("FILTER_NOAPI", "Combat FPS Booster: could not change addon enabled state. UI will not reload again."))
        return
    end

    local snapshot = {}
    pendingJobs = {}
    for _, entry in ipairs(managed) do
        snapshot[entry.name] = IsAddonEnabledNow(entry)
        local wantOn = needed[entry.name] == true
        if snapshot[entry.name] ~= wantOn then
            pendingJobs[#pendingJobs + 1] = { entry = entry, enabled = wantOn }
        end
    end

    if type(vars.dungeonSnapshot) ~= "table" then
        vars.dungeonSnapshot = snapshot
    end
    vars.dungeonProfileApplied = true

    if #pendingJobs > 0 then
        vars._filterNeedReload = "dungeon"
        filterBusy = true
        ChatMsg(L("FILTER_APPLY", "Combat FPS Booster: applying dungeon addon set, reloading UI."))
        StartJobQueue()
    end
end

local function RestoreWorldProfile()
    local vars = CombatFPSBooster.savedVars
    if not vars then return end
    local snapshot = vars.dungeonSnapshot
    if type(snapshot) ~= "table" then
        vars.dungeonProfileApplied = false
        vars.dungeonSnapshot = nil
        return
    end

    local byName = {}
    for _, entry in ipairs(ListManagedAddons()) do
        byName[entry.name] = entry
    end

    pendingJobs = {}
    for name, wasEnabled in pairs(snapshot) do
        local entry = byName[name]
        if entry and IsAddonEnabledNow(entry) ~= wasEnabled then
            pendingJobs[#pendingJobs + 1] = { entry = entry, enabled = wasEnabled }
        end
    end

    vars.dungeonSnapshot = nil
    vars.dungeonProfileApplied = false

    if #pendingJobs > 0 then
        vars._filterNeedReload = "world"
        filterBusy = true
        ChatMsg(L("FILTER_RESTORE", "Combat FPS Booster: restoring world addon set, reloading UI."))
        StartJobQueue()
    end
end

local function EvaluateDungeonFilter()
    local vars = CombatFPSBooster.savedVars
    if not vars then return end
    if filterBusy then return end
    if IsUnitInCombat and IsUnitInCombat("player") then
        return
    end

    local inInstance = InPveInstance()

    if inInstance then
        if not vars.dungeonFilterEnabled then
            return
        end
        if vars.dungeonProfileApplied then
            vars.dungeonReloadPending = false
            return
        end
        ApplyDungeonProfile()
    else
        vars.dungeonReloadPending = false
        if vars.dungeonProfileApplied or type(vars.dungeonSnapshot) == "table" then
            RestoreWorldProfile()
        end
    end
end

local function RequestDungeonFilterCheck(delayMs)
    delayMs = delayMs or FILTER_DELAY_MS
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonFilter")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_DungeonFilter", delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_DungeonFilter")
        EvaluateDungeonFilter()
    end)
end

local function OnPlayerActivated(eventCode)
    RequestApplyWithRetry(500)
    RequestDungeonFilterCheck(FILTER_DELAY_MS)
end

local function RegisterSettingsMenu()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local title = L("TITLE", "Tetsu's Combat FPS Booster")
    local settings
    local ok
    ok, settings = pcall(function()
        return LibHarven:AddAddon(title, { allowRefresh = true })
    end)
    if not ok or not settings then
        settings = LibHarven:AddAddon(title)
    end
    if not settings then return end

    settings.version = "1.3.54"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("HIDE_COMPASS", "Hide compass in combat"),
        tooltip = L("HIDE_COMPASS_TT", "Hides compass during combat."),
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideCompass end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideCompass = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("HIDE_QUESTS", "Hide quest tracker in combat"),
        tooltip = L("HIDE_QUESTS_TT", "Hides active quests during combat."),
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideQuests end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideQuests = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("HIDE_ALERTS", "Hide XP/Gold alerts in combat"),
        tooltip = L("HIDE_ALERTS_TT", "Hides alerts during combat."),
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideAlerts end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideAlerts = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("FILTER_MASTER", "Use dungeon-only addon set"),
        tooltip = L("FILTER_MASTER_TT", "When ON: entering a dungeon/trial snapshots your current addons, enables only those marked below, then reloads UI. Leaving restores the snapshot and reloads again. Libraries and this booster are never touched. If nothing is marked as needed, nothing is changed and a chat warning is shown."),
        default = false,
        getFunction = function()
            return CombatFPSBooster.savedVars.dungeonFilterEnabled == true
        end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.dungeonFilterEnabled = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L("FILTER_SECTION", "Dungeon addons"),
        tooltip = L("FILTER_SECTION_TT", "Choose which installed addons stay enabled inside a dungeon or trial."),
    })

    local managed = ListManagedAddons()
    for i = 1, #managed do
        local entry = managed[i]
        local name = entry.name
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = entry.title or name,
            tooltip = L("FILTER_ITEM_TT", "ON = keep/enable this addon in dungeons. OFF = disable it in dungeons. Locked until the option above is enabled."),
            default = false,
            disable = function()
                local vars = CombatFPSBooster.savedVars
                return not vars or vars.dungeonFilterEnabled ~= true
            end,
            getFunction = function()
                local vars = CombatFPSBooster.savedVars
                if not vars.dungeonNeeded then vars.dungeonNeeded = {} end
                return vars.dungeonNeeded[name] == true
            end,
            setFunction = function(val)
                local vars = CombatFPSBooster.savedVars
                if not vars or vars.dungeonFilterEnabled ~= true then
                    return
                end
                if not vars.dungeonNeeded then vars.dungeonNeeded = {} end
                vars.dungeonNeeded[name] = val and true or false
            end,
        })
    end
end

local function EnsureVarsShape(vars)
    if type(vars.dungeonNeeded) ~= "table" then
        vars.dungeonNeeded = {}
    end
    if vars.dungeonFilterEnabled == nil then
        vars.dungeonFilterEnabled = false
    end
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    CombatFPSBooster.savedVars = ZO_SavedVars:NewAccountWide(
        "CombatFPSBoosterSavedVars",
        1,
        nil,
        defaultSettings
    )
    EnsureVarsShape(CombatFPSBooster.savedVars)

    RegisterSettingsMenu()
    HookHudScenes()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ALIVE, OnPlayerAlive)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RESPAWN_RESULT, OnRespawnResult)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD, OnPlayerDead)
    if EVENT_PREPARE_FOR_JUMP then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PREPARE_FOR_JUMP, OnPrepareForJump)
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
