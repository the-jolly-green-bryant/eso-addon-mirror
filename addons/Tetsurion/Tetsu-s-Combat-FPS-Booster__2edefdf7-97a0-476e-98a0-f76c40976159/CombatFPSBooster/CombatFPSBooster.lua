local ADDON_NAME = "CombatFPSBooster"
CombatFPSBooster = CombatFPSBooster or {}

local defaultSettings = {
    hideCompass = true,
    hideQuests  = true,
    hideAlerts  = true,
    hideCSA     = false,
    hideWholeInstance = false,
    wholeWhereDungeon = true,
    wholeWhereArena = true,
    wholeWhereArchive = true,
    wholeWhereBG = false,
    wholeWhereCyro = false,
    dungeonPresets = {},
}

local DEFAULT_PRESET = "General"

local defaultFilterSettings = {
    dungeonFilterEnabled = false,
    dungeonNeeded = {},
    dungeonPresets = nil,
    dungeonPresetCurrent = DEFAULT_PRESET,
    dungeonSnapshot = nil,
    dungeonProfileApplied = false,
    dungeonReloadPending = false,
    dungeonAutoSwap = true,
}

local pendingPresetName = nil

local isApplying = false
local scenesHooked = false
local lootHistoryHooked = false
local xpBarHooked = false
local suppressLootFeed = false
local suppressXpBar = false
local InPveInstance
local APPLY_RETRY_MS = 150
local FRAGMENT_REASON = "TetsuCFB"
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

local function FilterVars()
    return CombatFPSBooster.charVars or CombatFPSBooster.savedVars
end

local function AccountVars()
    return CombatFPSBooster.savedVars or CombatFPSBooster.charVars
end

local function PresetTable()
    local acc = AccountVars()
    if acc then
        if type(acc.dungeonPresets) ~= "table" then
            acc.dungeonPresets = {}
        end
        return acc.dungeonPresets
    end
    local ch = FilterVars()
    if ch then
        if type(ch.dungeonPresets) ~= "table" then
            ch.dungeonPresets = {}
        end
        return ch.dungeonPresets
    end
    return {}
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

local function SetFragmentHidden(fragment, hide)
    if fragment and fragment.SetHiddenForReason then
        pcall(function()
            fragment:SetHiddenForReason(FRAGMENT_REASON, hide and true or false)
        end)
    end
end

local function EachLootHistory(fn)
    if LOOT_HISTORY_GAMEPAD then
        fn(LOOT_HISTORY_GAMEPAD)
    end
    if LOOT_HISTORY_KEYBOARD then
        fn(LOOT_HISTORY_KEYBOARD)
    end
end

local function ClearLootQueue(hist)
    if not hist then return end
    local queue = hist.lootQueue
    if type(queue) == "table" then
        for i = #queue, 1, -1 do
            queue[i] = nil
        end
    end
end

local function HookLootHistoryObject(hist)
    if not hist or hist._tetsuCfbHook then
        return
    end
    hist._tetsuCfbHook = true

    local origInsert = hist.InsertOrQueue
    if type(origInsert) == "function" then
        hist.InsertOrQueue = function(self, lootEntry)
            if suppressLootFeed then
                return
            end
            return origInsert(self, lootEntry)
        end
    end

    local origAdd = hist.AddLootEntry
    if type(origAdd) == "function" then
        hist.AddLootEntry = function(self, lootEntry)
            if suppressLootFeed then
                return
            end
            return origAdd(self, lootEntry)
        end
    end

    local origQueue = hist.QueueLootEntry
    if type(origQueue) == "function" then
        hist.QueueLootEntry = function(self, lootEntry)
            if suppressLootFeed then
                return
            end
            return origQueue(self, lootEntry)
        end
    end

    local origCanShow = hist.CanShowItemsInHistory
    if type(origCanShow) == "function" then
        hist.CanShowItemsInHistory = function(self)
            if suppressLootFeed then
                return false
            end
            return origCanShow(self)
        end
    end
end

local function HookLootHistory()
    EachLootHistory(HookLootHistoryObject)
    lootHistoryHooked = LOOT_HISTORY_GAMEPAD ~= nil or LOOT_HISTORY_KEYBOARD ~= nil
end

local function SetLootFeedHidden(hide)
    HookLootHistory()
    suppressLootFeed = hide and true or false

    -- Реальные контролы ленты. ZO_LootHistory_Gamepad — класс, не контрол.
    SafeSetState(ZO_LootHistoryControl_Gamepad, hide)
    SafeSetState(ZO_LootHistoryControl_Keyboard, hide)
    SafeSetState(ZO_LootHistoryControl, hide)
    SafeSetState(ZO_LootHistory, hide)

    SetFragmentHidden(GAMEPAD_LOOT_HISTORY_FRAGMENT, hide)
    SetFragmentHidden(LOOT_HISTORY_FRAGMENT, hide)

    EachLootHistory(function(hist)
        if hide then
            if hist.HideLootQueue then
                pcall(function() hist:HideLootQueue() end)
            else
                hist.hidden = true
            end
            ClearLootQueue(hist)
            if hist.lootStream and hist.lootStream.Pause then
                pcall(function() hist.lootStream:Pause() end)
            end
            if hist.lootStreamPersistent and hist.lootStreamPersistent.Pause then
                pcall(function() hist.lootStreamPersistent:Pause() end)
            end
            if hist.control then
                SafeSetState(hist.control, true)
            end
        else
            ClearLootQueue(hist)
            if hist.DisplayLootQueue then
                pcall(function() hist:DisplayLootQueue() end)
            else
                hist.hidden = false
                if hist.lootStream and hist.lootStream.Resume then
                    pcall(function() hist.lootStream:Resume() end)
                end
                if hist.lootStreamPersistent and hist.lootStreamPersistent.Resume then
                    pcall(function() hist.lootStreamPersistent:Resume() end)
                end
            end
            if hist.control then
                SafeSetState(hist.control, false)
            end
        end
    end)
end

local function SetProgressBarHidden(hide)
    suppressXpBar = hide and true or false
    SetFragmentHidden(PLAYER_PROGRESS_BAR_FRAGMENT, hide)
    SetFragmentHidden(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT, hide)
    -- Только прячем сам бар. Не трогаем имя/локацию и не делаем SetHidden(false):
    -- иначе после меню куски персонажного экрана остаются в HUD.
    if hide and PLAYER_PROGRESS_BAR and PLAYER_PROGRESS_BAR.control then
        SafeSetState(PLAYER_PROGRESS_BAR.control, true)
    end
end

local function HookXpBar()
    if xpBarHooked then
        return
    end
    if not PLAYER_PROGRESS_BAR or not PLAYER_PROGRESS_BAR.RegisterCallback then
        return
    end
    xpBarHooked = true
    pcall(function()
        PLAYER_PROGRESS_BAR:RegisterCallback("Show", function()
            if suppressXpBar then
                SetProgressBarHidden(true)
            end
        end)
    end)
end

local function SetLootAlertsHidden(hide)
    if ZO_AlertTextNotification then
        SafeSetState(ZO_AlertTextNotification, hide)
    end
    if ZO_AlertTextNotificationGamepad then
        SafeSetState(ZO_AlertTextNotificationGamepad, hide)
    end
    if ALERT_MESSAGES_GAMEPAD and ALERT_MESSAGES_GAMEPAD.control then
        SafeSetState(ALERT_MESSAGES_GAMEPAD.control, hide)
    end
    if ALERT_MESSAGES and ALERT_MESSAGES.control then
        SafeSetState(ALERT_MESSAGES.control, hide)
    end

    SetLootFeedHidden(hide)
    SetProgressBarHidden(hide)
    HookXpBar()
end


local function SetDungeonAnnounceHidden(hide)
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

        local zoneKind = DetectHudZoneKind()
        local instanceHide = vars.hideWholeInstance == true and ZoneAllowsWholeHud(vars, zoneKind)

        -- Компас/квесты прячутся только если их собственные галочки вкл.
        -- «Весь данж» лишь удлиняет то же прятание на всю зону.
        -- В Сиродиле компас режимом «весь данж» не трогаем — только боем.
        if vars.hideCompass then
            local hideCompassNow = inCombat or (instanceHide and zoneKind ~= "cyro")
            SetCompassHidden(hideCompassNow)
        else
            SetCompassHidden(false)
        end

        if vars.hideQuests then
            SetQuestTrackerHidden(inCombat or instanceHide)
        else
            SetQuestTrackerHidden(false)
        end

        -- XP, золото и лут — только в бою, как игровые анонсы. «Весь данж» их не трогает.
        if vars.hideAlerts then
            SetLootAlertsHidden(inCombat)
        else
            SetLootAlertsHidden(false)
        end

        if vars.hideCSA then
            SetDungeonAnnounceHidden(inCombat)
        else
            SetDungeonAnnounceHidden(false)
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

local ARENA_ZONE_IDS = {
    [635] = true,  -- Dragonstar Arena
    [681] = true,  -- Maelstrom Arena
    [1051] = true, -- Blackrose Prison
    [1082] = true, -- Vateshran Hollows
}

local function CurrentZoneId()
    if GetUnitWorldPosition then
        local ok, z = pcall(GetUnitWorldPosition, "player")
        if ok and type(z) == "number" and z > 0 then
            return z
        end
    end
    if GetZoneId and GetCurrentMapZoneIndex then
        local ok, z = pcall(function()
            return GetZoneId(GetCurrentMapZoneIndex())
        end)
        if ok and type(z) == "number" and z > 0 then
            return z
        end
    end
    return 0
end

local function IsHouseZone()
    if GetCurrentHouseId then
        local ok, houseId = pcall(GetCurrentHouseId)
        if ok and houseId and houseId > 0 then
            return true
        end
    end
    return false
end

function IsBattlegroundZone()
    if IsActiveWorldBattleground and IsActiveWorldBattleground() then
        return true
    end
    if lastZoneDisplayType and lastZoneDisplayType == ZONE_DISPLAY_TYPE_BATTLEGROUND then
        return true
    end
    if GetMapContentType and MAP_CONTENT_BATTLEGROUND and GetMapContentType() == MAP_CONTENT_BATTLEGROUND then
        return true
    end
    return false
end

function IsCyrodiilZone()
    if IsBattlegroundZone() then
        return false
    end
    if IsInImperialCity and IsInImperialCity() then
        return true
    end
    if IsInCyrodiil and IsInCyrodiil() then
        return true
    end
    if IsInAvAZone and IsInAvAZone() then
        return true
    end
    return false
end

local function IsPvpRestrictedZone()
    return IsBattlegroundZone() or IsCyrodiilZone()
end

function DetectHudZoneKind()
    if IsHouseZone() then
        return nil
    end
    if IsBattlegroundZone() then
        return "bg"
    end
    if IsCyrodiilZone() then
        return "cyro"
    end
    if IsInstanceEndlessDungeon then
        local ok, endless = pcall(IsInstanceEndlessDungeon)
        if ok and endless then
            return "archive"
        end
    end
    local t = lastZoneDisplayType
    if t == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON then
        return "archive"
    end
    if ZONE_DISPLAY_TYPE_ARENA and t == ZONE_DISPLAY_TYPE_ARENA then
        return "arena"
    end
    local zid = CurrentZoneId()
    if zid > 0 and ARENA_ZONE_IDS[zid] then
        return "arena"
    end
    if t == ZONE_DISPLAY_TYPE_DELVE or t == ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON or t == ZONE_DISPLAY_TYPE_GROUP_DELVE then
        return nil
    end
    if t == ZONE_DISPLAY_TYPE_RAID or t == ZONE_DISPLAY_TYPE_DUNGEON then
        return "dungeon"
    end
    if IsPlayerInRaid then
        local ok, raid = pcall(IsPlayerInRaid)
        if ok and raid then
            return "dungeon"
        end
    end
    local diff = 0
    if GetCurrentZoneDungeonDifficulty then
        local ok, d = pcall(GetCurrentZoneDungeonDifficulty)
        if ok and type(d) == "number" then
            diff = d
        end
    end
    if IsUnitInDungeon and IsUnitInDungeon("player") and diff > 0 then
        if ARENA_ZONE_IDS[zid] then
            return "arena"
        end
        return "dungeon"
    end
    return nil
end

function ZoneAllowsWholeHud(vars, kind)
    if not vars or not kind then
        return false
    end
    if kind == "dungeon" then
        return vars.wholeWhereDungeon ~= false
    end
    if kind == "arena" then
        return vars.wholeWhereArena ~= false
    end
    if kind == "archive" then
        return vars.wholeWhereArchive ~= false
    end
    if kind == "bg" then
        return vars.wholeWhereBG == true
    end
    if kind == "cyro" then
        return vars.wholeWhereCyro == true
    end
    return false
end

-- Фильтр аддонов: как раньше. Не БГ, не Сиродил, не логово/паб/дом.
InPveInstance = function()
    if IsHouseZone() then
        return false
    end
    if IsBattlegroundZone() then
        return false
    end
    if IsCyrodiilZone() then
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
    local vars = FilterVars()
    if vars then
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
        local vars = FilterVars()
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
    local vars = FilterVars()
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

    -- pending после успешного релога. Для авто — защита от вечного ReloadUI,
    -- если SetAddOnEnabled не взялся. Для ручного Apply это ложная ошибка:
    -- первый клик по другому пресету сбрасывал флаг и выходил.
    if vars.dungeonReloadPending and vars.dungeonAutoSwap ~= false then
        vars.dungeonReloadPending = false
        vars.dungeonProfileApplied = true
        ChatMsg(L("FILTER_NOAPI", "Combat FPS Booster: could not change addon enabled state. UI will not reload again."))
        return
    end
    vars.dungeonReloadPending = false

    local snapshot = {}
    pendingJobs = {}
    for _, entry in ipairs(managed) do
        snapshot[entry.name] = IsAddonEnabledNow(entry)
        local wantOn = needed[entry.name] == true
        if snapshot[entry.name] ~= wantOn then
            pendingJobs[#pendingJobs + 1] = { entry = entry, enabled = wantOn }
        end
    end

    -- Ручной режим не держит мировой снимок: мир — отдельный пресет.
    if vars.dungeonAutoSwap ~= false then
        if type(vars.dungeonSnapshot) ~= "table" then
            vars.dungeonSnapshot = snapshot
        end
    else
        vars.dungeonSnapshot = nil
    end
    vars.dungeonProfileApplied = true

    if #pendingJobs > 0 then
        vars._filterNeedReload = "dungeon"
        filterBusy = true
        local presetName = vars.dungeonPresetCurrent or DEFAULT_PRESET
        ChatMsg(L("FILTER_APPLY", "Combat FPS Booster: enabling addon preset ") .. tostring(presetName) .. L("FILTER_APPLY_TAIL", ", reloading UI."))
        StartJobQueue()
    end
end

local function RestoreWorldProfile()
    local vars = FilterVars()
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
        ChatMsg(L("FILTER_RESTORE", "Combat FPS Booster: restoring previous addon setup, reloading UI."))
        StartJobQueue()
    end
end

local function EvaluateDungeonFilter()
    local vars = FilterVars()
    if not vars then return end
    if filterBusy then return end
    if IsUnitInCombat and IsUnitInCombat("player") then
        return
    end

    if vars.dungeonFilterEnabled ~= true then
        return
    end
    -- Ручной режим: зона не трогает набор. Только кнопка «Применить».
    if vars.dungeonAutoSwap == false then
        return
    end

    local inInstance = InPveInstance()

    if inInstance then
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

local function OnExperienceUpdate(_, unitTag)
    if unitTag and unitTag ~= "player" then
        return
    end
    if suppressXpBar then
        SetProgressBarHidden(true)
    end
end

local function OnPlayerActivated(eventCode)
    HookLootHistory()
    HookXpBar()
    RequestApplyWithRetry(500)
    RequestDungeonFilterCheck(FILTER_DELAY_MS)
end


local function CopyBoolMap(src)
    local out = {}
    if type(src) ~= "table" then return out end
    for k, v in pairs(src) do
        if type(k) == "string" then
            out[k] = v and true or false
        end
    end
    return out
end

local function SanitizePresetName(name)
    if type(name) ~= "string" then return DEFAULT_PRESET end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return DEFAULT_PRESET end
    if #name > 24 then
        name = name:sub(1, 24)
    end
    return name
end

local function EnsureVarsShape(vars)
    vars = vars or FilterVars()
    if not vars then return end
    if type(vars.dungeonNeeded) ~= "table" then
        vars.dungeonNeeded = {}
    end
    if vars.dungeonFilterEnabled == nil then
        vars.dungeonFilterEnabled = false
    end

    local acc = AccountVars()
    local presets = PresetTable()
    -- Старые пресеты персонажа переезжают на аккаунт ОДИН раз.
    -- Повторный копир возвращал удалённый General после релога:
    -- char.dungeonPresets = nil в SavedVars часто не сохраняется.
    if acc and vars ~= acc and vars.dungeonPresetsMoved ~= true then
        if not next(presets) and type(vars.dungeonPresets) == "table" and next(vars.dungeonPresets) then
            for name, map in pairs(vars.dungeonPresets) do
                if type(name) == "string" then
                    presets[name] = CopyBoolMap(map)
                end
            end
        end
        vars.dungeonPresets = {}
        vars.dungeonPresetsMoved = true
    end
    if not next(presets) then
        presets[DEFAULT_PRESET] = CopyBoolMap(vars.dungeonNeeded)
    end
    if type(vars.dungeonPresetCurrent) ~= "string" or presets[vars.dungeonPresetCurrent] == nil then
        if presets[DEFAULT_PRESET] ~= nil then
            vars.dungeonPresetCurrent = DEFAULT_PRESET
        else
            vars.dungeonPresetCurrent = next(presets) or DEFAULT_PRESET
        end
    end
    if not next(vars.dungeonNeeded) and presets[vars.dungeonPresetCurrent] then
        vars.dungeonNeeded = CopyBoolMap(presets[vars.dungeonPresetCurrent])
    end
    if type(vars.dungeonPresetDraft) ~= "string" or vars.dungeonPresetDraft == "" then
        vars.dungeonPresetDraft = vars.dungeonPresetCurrent
    end
    if vars.dungeonAutoSwap == nil then
        vars.dungeonAutoSwap = true
    end
end

local function PresetNameList()
    EnsureVarsShape()
    local names = {}
    for name in pairs(PresetTable()) do
        names[#names + 1] = name
    end
    table.sort(names, function(a, b)
        if a == DEFAULT_PRESET then return true end
        if b == DEFAULT_PRESET then return false end
        return a < b
    end)
    return names
end

local function LoadPreset(name)
    local vars = FilterVars()
    EnsureVarsShape(vars)
    local presets = PresetTable()
    name = SanitizePresetName(name)
    if presets[name] == nil then
        name = vars.dungeonPresetCurrent or DEFAULT_PRESET
    end
    vars.dungeonPresetCurrent = name
    vars.dungeonNeeded = CopyBoolMap(presets[name])
    vars.dungeonPresetDraft = name
    pendingPresetName = name
end

local function SaveCurrentPreset(name)
    local vars = FilterVars()
    EnsureVarsShape(vars)
    local presets = PresetTable()
    name = SanitizePresetName(name or pendingPresetName or vars.dungeonPresetCurrent)
    local saved = CopyBoolMap(presets[name])
    for addonName, state in pairs(vars.dungeonNeeded or {}) do
        saved[addonName] = state and true or false
    end
    for _, entry in ipairs(ListManagedAddons()) do
        saved[entry.name] = vars.dungeonNeeded[entry.name] == true
    end
    presets[name] = saved
    vars.dungeonPresetCurrent = name
    vars.dungeonNeeded = CopyBoolMap(saved)
    vars.dungeonPresetDraft = name
    pendingPresetName = name
    ChatMsg(L("PRESET_SAVED", "Combat FPS Booster: preset saved: ") .. name)
end

local function DeleteCurrentPreset()
    local vars = FilterVars()
    if not vars then return end
    EnsureVarsShape(vars)
    local presets = PresetTable()
    local count = 0
    for _ in pairs(presets) do
        count = count + 1
    end
    if count <= 1 then
        ChatMsg(L("PRESET_LAST", "Combat FPS Booster: the last preset cannot be deleted."))
        return
    end
    local current = vars.dungeonPresetCurrent
    if type(current) ~= "string" or presets[current] == nil then
        ChatMsg(L("PRESET_LAST", "Combat FPS Booster: the last preset cannot be deleted."))
        return
    end
    presets[current] = nil
    -- На всякий случай вычистить и персонажную копию, если она ещё жива.
    if vars.dungeonPresets and type(vars.dungeonPresets) == "table" then
        vars.dungeonPresets[current] = nil
    end
    local nextName = nil
    if presets[DEFAULT_PRESET] ~= nil then
        nextName = DEFAULT_PRESET
    else
        nextName = next(presets)
    end
    if not nextName then
        presets[DEFAULT_PRESET] = CopyBoolMap(vars.dungeonNeeded)
        nextName = DEFAULT_PRESET
    end
    vars.dungeonPresetCurrent = nextName
    vars.dungeonPresetDraft = nextName
    vars.dungeonNeeded = CopyBoolMap(presets[nextName])
    pendingPresetName = nextName
    ChatMsg(L("PRESET_DELETED", "Combat FPS Booster: preset deleted: ") .. current)
    ChatMsg(L("PRESET_NOW", "Combat FPS Booster: active preset: ") .. nextName)
end


local function FormatPresetAddonList(presetName)
    EnsureVarsShape()
    local presets = PresetTable()
    local map = nil
    if type(presetName) == "string" and presets[presetName] then
        map = presets[presetName]
    else
        local vars = FilterVars()
        map = (vars and vars.dungeonNeeded) or {}
    end
    local titles = {}
    local seen = {}
    for _, entry in ipairs(ListManagedAddons()) do
        if map[entry.name] == true then
            titles[#titles + 1] = entry.title or entry.name
            seen[entry.name] = true
        end
    end
    for name, on in pairs(map) do
        if on == true and type(name) == "string" and not seen[name] then
            titles[#titles + 1] = name
        end
    end
    table.sort(titles, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    if #titles == 0 then
        return L("PRESET_PREVIEW_EMPTY", "(no addons marked on)")
    end
    return table.concat(titles, "\n")
end

local function PresetPreviewTooltip(baseKey, baseFallback)
    local vars = FilterVars()
    EnsureVarsShape(vars)
    local name = (vars and vars.dungeonPresetCurrent) or DEFAULT_PRESET
    local head = L("PRESET_PREVIEW_HEAD", "Enabled in this preset:")
    return L(baseKey, baseFallback) .. "\n\n" .. head .. " " .. tostring(name) .. "\n" .. FormatPresetAddonList(name)
end

local function LayoutSettingsInfoText(text)
    if not GAMEPAD_TOOLTIPS or not text then
        return
    end
    local function apply(tipId)
        if not tipId then
            return
        end
        if GAMEPAD_TOOLTIPS.ClearTooltip then
            GAMEPAD_TOOLTIPS:ClearTooltip(tipId)
        end
        if GAMEPAD_TOOLTIPS.LayoutSettingTooltip then
            GAMEPAD_TOOLTIPS:LayoutSettingTooltip(tipId, text)
            return
        end
        local tip = GAMEPAD_TOOLTIPS.GetTooltip and GAMEPAD_TOOLTIPS:GetTooltip(tipId)
        if tip and tip.LayoutTextBlockTooltip then
            tip:LayoutTextBlockTooltip(text)
        end
    end
    apply(GAMEPAD_LEFT_TOOLTIP)
end

local function RefreshPresetDescriptionPanel()
    local text = PresetPreviewTooltip("PRESET_SELECT_TT", "Switch between saved dungeon addon sets. Presets are account-wide.")
    pcall(LayoutSettingsInfoText, text)
    -- Закрытие дропдауна иногда перетирает панель старым текстом — повтор через кадр.
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_PresetTip")
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_PresetTip", 50, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_PresetTip")
        pcall(LayoutSettingsInfoText, PresetPreviewTooltip("PRESET_SELECT_TT", "Switch between saved dungeon addon sets. Presets are account-wide."))
    end)
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

    settings.version = "1.5.5"
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
        label = L("HIDE_ALERTS", "Hide XP/loot alerts"),
        tooltip = L("HIDE_ALERTS_TT", "Hides XP, gold and loot during combat only: console loot feed, gold/XP ticks, and the left XP bar. Whole-dungeon mode does not keep them hidden between fights."),
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideAlerts end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideAlerts = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("HIDE_CSA", "Hide dungeon announcements in combat"),
        tooltip = L("HIDE_CSA_TT", "Hides large center-screen game announcements during combat only. Never for the whole dungeon."),
        default = false,
        getFunction = function() return CombatFPSBooster.savedVars.hideCSA == true end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideCSA = val and true or false
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("HIDE_INSTANCE", "Hide HUD for the whole dungeon"),
        tooltip = L("HIDE_INSTANCE_TT", "When ON, compass and quest tracker stay hidden for the entire group dungeon, trial, arena or Infinite Archive — if those options are also on. XP, gold, loot and dungeon announcements still hide in combat only. Delves and public dungeons are ignored."),
        default = false,
        getFunction = function() return CombatFPSBooster.savedVars.hideWholeInstance == true end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideWholeInstance = val and true or false
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("FILTER_MASTER", "Use dungeon-only addon set"),
        tooltip = L("FILTER_MASTER_TT", "When ON: entering a dungeon/trial snapshots your current addons, enables only those marked below, then reloads UI. Leaving restores the snapshot and reloads again. Libraries and this booster are never touched. If nothing is marked as needed, nothing is changed and a chat warning is shown."),
        default = false,
        getFunction = function()
            return FilterVars().dungeonFilterEnabled == true
        end,
        setFunction = function(val)
            FilterVars().dungeonFilterEnabled = val and true or false
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("FILTER_AUTO", "Auto-swap addons in dungeons"),
        tooltip = L("FILTER_AUTO_TT", "ON: entering a dungeon snapshots the current addons, applies the selected preset, leaving restores that snapshot. OFF: manual mode. The world snapshot is erased. Save a world preset first if you want to switch back by hand. Apply in the preset list only works while this is OFF."),
        default = true,
        disable = function()
            local vars = FilterVars()
            return not vars or vars.dungeonFilterEnabled ~= true
        end,
        getFunction = function()
            local vars = FilterVars()
            return not vars or vars.dungeonAutoSwap ~= false
        end,
        setFunction = function(val)
            local vars = FilterVars()
            if not vars or vars.dungeonFilterEnabled ~= true then
                return
            end
            local auto = val and true or false
            vars.dungeonAutoSwap = auto
            if not auto then
                vars.dungeonSnapshot = nil
                vars.dungeonProfileApplied = false
                vars.dungeonReloadPending = false
                ChatMsg(L("FILTER_AUTO_OFF", "Combat FPS Booster: manual addon presets. World snapshot cleared. Apply a preset from the list."))
            end
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_DROPDOWN,
        label = L("PRESET_SELECT", "Preset"),
        tooltip = function()
            return PresetPreviewTooltip("PRESET_SELECT_TT", "Switch between saved dungeon addon sets. Presets are account-wide.")
        end,
        items = function()
            local items = {}
            for _, name in ipairs(PresetNameList()) do
                items[#items + 1] = { name = name, data = name }
            end
            if #items == 0 then
                items[1] = { name = DEFAULT_PRESET, data = DEFAULT_PRESET }
            end
            return items
        end,
        getFunction = function()
            local vars = FilterVars()
            EnsureVarsShape(vars)
            return vars.dungeonPresetCurrent or DEFAULT_PRESET
        end,
        setFunction = function(_, itemName, itemData)
            local name = itemData or itemName
            if type(name) == "table" then
                name = name.data or name.name
            end
            LoadPreset(name)
            RefreshPresetDescriptionPanel()
        end,
        default = DEFAULT_PRESET,
    })

    if LibHarvensAddonSettings.ST_BUTTON then
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = L("PRESET_APPLY", "Apply preset"),
            buttonText = L("PRESET_APPLY_BTN", "Apply"),
            tooltip = function()
                return PresetPreviewTooltip("PRESET_APPLY_TT", "Enable the selected preset now and reload UI. Only while auto-swap is OFF. Save a world preset first if you need to switch back later.")
            end,
            disable = function()
                local vars = FilterVars()
                if not vars or vars.dungeonFilterEnabled ~= true or vars.dungeonAutoSwap ~= false then
                    return true
                end
                return IsPvpRestrictedZone()
            end,
            clickHandler = function()
                local vars = FilterVars()
                if not vars or vars.dungeonFilterEnabled ~= true then
                    return
                end
                if vars.dungeonAutoSwap ~= false then
                    ChatMsg(L("PRESET_APPLY_NEED_MANUAL", "Combat FPS Booster: turn off auto-swap to apply a preset by hand."))
                    return
                end
                if IsUnitInCombat and IsUnitInCombat("player") then
                    ChatMsg(L("PRESET_APPLY_COMBAT", "Combat FPS Booster: cannot apply a preset in combat."))
                    return
                end
                if IsPvpRestrictedZone() then
                    ChatMsg(L("PRESET_APPLY_PVP", "Combat FPS Booster: cannot apply a preset in Cyrodiil or battlegrounds."))
                    return
                end
                vars.dungeonReloadPending = false
                ApplyDungeonProfile()
            end,
        })
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L("FILTER_SECTION", "Dungeon addons"),
        tooltip = L("FILTER_SECTION_TT", "Choose which installed addons stay enabled inside a dungeon or trial."),
    })

    if LibHarvensAddonSettings.ST_EDIT then
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_EDIT,
            label = L("PRESET_NAME", "Preset name"),
            tooltip = L("PRESET_NAME_TT", "Name of the preset to save. Same name overwrites that preset."),
            getFunction = function()
                local vars = FilterVars()
                EnsureVarsShape(vars)
                return vars.dungeonPresetDraft or vars.dungeonPresetCurrent or DEFAULT_PRESET
            end,
            setFunction = function(a, b)
                local val = a
                if type(val) ~= "string" then
                    val = b
                end
                if type(val) ~= "string" then
                    return
                end
                val = val:gsub("^%s+", ""):gsub("%s+$", "")
                if val == "" then
                    return
                end
                if #val > 24 then
                    val = val:sub(1, 24)
                end
                local vars = FilterVars()
                EnsureVarsShape(vars)
                vars.dungeonPresetDraft = val
                pendingPresetName = val
            end,
            default = DEFAULT_PRESET,
        })
    end

    if LibHarvensAddonSettings.ST_BUTTON then
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = L("PRESET_SAVE", "Save preset"),
            buttonText = L("PRESET_SAVE_BTN", "Save"),
            tooltip = L("PRESET_SAVE_TT", "Save current on/off flags into this preset name. Missing addons stay remembered."),
            clickHandler = function()
                local vars = FilterVars()
                SaveCurrentPreset((vars and vars.dungeonPresetDraft) or pendingPresetName)
            end,
        })
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_BUTTON,
            label = L("PRESET_DELETE", "Delete preset"),
            buttonText = L("PRESET_DELETE_BTN", "Delete"),
            tooltip = L("PRESET_DELETE_TT", "Delete the selected preset. The last remaining preset cannot be deleted."),
            disable = function()
                return #PresetNameList() <= 1
            end,
            clickHandler = function()
                DeleteCurrentPreset()
            end,
        })
    end

    if LibHarvensAddonSettings.ST_LABEL then
        settings:AddSetting({
            type = LibHarvensAddonSettings.ST_LABEL,
            label = L("PRESET_DIVIDER", "──────── addons ────────"),
        })
    end

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
                local vars = FilterVars()
                return not vars or vars.dungeonFilterEnabled ~= true
            end,
            getFunction = function()
                local vars = FilterVars()
                if not vars.dungeonNeeded then vars.dungeonNeeded = {} end
                return vars.dungeonNeeded[name] == true
            end,
            setFunction = function(val)
                local vars = FilterVars()
                if not vars or vars.dungeonFilterEnabled ~= true then
                    return
                end
                if not vars.dungeonNeeded then vars.dungeonNeeded = {} end
                vars.dungeonNeeded[name] = val and true or false
            end,
        })
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_SECTION,
        label = L("WHOLE_WHERE", "Where whole-dungeon mode applies"),
        tooltip = L("WHOLE_WHERE_TT", "Where compass and quest tracker stay hidden between fights, if those options are on. XP, gold, loot and CSA stay combat-only. Compass is never hidden by this mode in Cyrodiil."),
    })

    local function WholeWhereDisable()
        return CombatFPSBooster.savedVars.hideWholeInstance ~= true
    end
    local function WholeWhereSet(key, val)
        CombatFPSBooster.savedVars[key] = val and true or false
        ApplyCombatVisualState(IsUnitInCombat("player"))
    end

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("WHOLE_DUNGEON", "Dungeons and trials"),
        tooltip = L("WHOLE_DUNGEON_TT", "Group dungeons and trials."),
        default = true,
        disable = WholeWhereDisable,
        getFunction = function() return CombatFPSBooster.savedVars.wholeWhereDungeon ~= false end,
        setFunction = function(val) WholeWhereSet("wholeWhereDungeon", val) end,
    })
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("WHOLE_ARENA", "Arenas"),
        tooltip = L("WHOLE_ARENA_TT", "Maelstrom, Dragonstar, Vateshran, Blackrose."),
        default = true,
        disable = WholeWhereDisable,
        getFunction = function() return CombatFPSBooster.savedVars.wholeWhereArena ~= false end,
        setFunction = function(val) WholeWhereSet("wholeWhereArena", val) end,
    })
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("WHOLE_ARCHIVE", "Infinite Archive"),
        tooltip = L("WHOLE_ARCHIVE_TT", "Infinite Archive runs."),
        default = true,
        disable = WholeWhereDisable,
        getFunction = function() return CombatFPSBooster.savedVars.wholeWhereArchive ~= false end,
        setFunction = function(val) WholeWhereSet("wholeWhereArchive", val) end,
    })
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("WHOLE_BG", "Battlegrounds"),
        tooltip = L("WHOLE_BG_TT", "Battleground matches. Addon presets are not auto-swapped here."),
        default = false,
        disable = WholeWhereDisable,
        getFunction = function() return CombatFPSBooster.savedVars.wholeWhereBG == true end,
        setFunction = function(val) WholeWhereSet("wholeWhereBG", val) end,
    })
    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L("WHOLE_CYRO", "Cyrodiil and Imperial City"),
        tooltip = L("WHOLE_CYRO_TT", "Alliance War zones. Compass stays visible; only the quest tracker can stay hidden between fights."),
        default = false,
        disable = WholeWhereDisable,
        getFunction = function() return CombatFPSBooster.savedVars.wholeWhereCyro == true end,
        setFunction = function(val) WholeWhereSet("wholeWhereCyro", val) end,
    })
end


local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    CombatFPSBooster.savedVars = ZO_SavedVars:NewAccountWide(
        "CombatFPSBoosterSavedVars",
        1,
        nil,
        defaultSettings
    )
    local okChar, charVars = pcall(function()
        return ZO_SavedVars:NewCharacterIdSettings(
            "CombatFPSBoosterCharVars",
            1,
            nil,
            defaultFilterSettings
        )
    end)
    if not okChar or not charVars then
        charVars = ZO_SavedVars:New(
            "CombatFPSBoosterCharVars",
            1,
            nil,
            defaultFilterSettings
        )
    end
    CombatFPSBooster.charVars = charVars
    EnsureVarsShape(CombatFPSBooster.charVars)
    -- Один раз перенести старый аккаунтный фильтр на этого перса, если у перса ещё пусто.
    local acc = CombatFPSBooster.savedVars
    local ch = CombatFPSBooster.charVars
    if ch and acc and not ch.dungeonMigrated then
        local accNeeded = acc.dungeonNeeded
        local chNeeded = ch.dungeonNeeded
        local charEmpty = type(chNeeded) ~= "table" or not next(chNeeded)
        if charEmpty and type(accNeeded) == "table" and next(accNeeded) then
            ch.dungeonNeeded = {}
            for k, v in pairs(accNeeded) do
                ch.dungeonNeeded[k] = v
            end
            ch.dungeonFilterEnabled = acc.dungeonFilterEnabled and true or false
        end
        ch.dungeonMigrated = true
    end

    RegisterSettingsMenu()
    HookHudScenes()
    HookLootHistory()
    HookXpBar()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ALIVE, OnPlayerAlive)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RESPAWN_RESULT, OnRespawnResult)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD, OnPlayerDead)
    if EVENT_EXPERIENCE_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_EXPERIENCE_UPDATE, OnExperienceUpdate)
        pcall(function()
            EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end)
    end
    if EVENT_PREPARE_FOR_JUMP then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PREPARE_FOR_JUMP, OnPrepareForJump)
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
