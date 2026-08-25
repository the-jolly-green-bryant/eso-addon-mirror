local ADDON_NAME = "CombatFPSBooster"
CombatFPSBooster = CombatFPSBooster or {}

local defaultSettings = {
    hideCompass = true,
    hideQuests  = true,
    hideAlerts  = true,
}

local isApplying = false

local function SafeSetState(control, hide)
    if control then
        if control.SetHidden then
            control:SetHidden(hide)
        end
        if control.SetAlpha then
            control:SetAlpha(hide and 0 or 1)
        end
    end
end

local function SetCompassHidden(hide)
    if ZO_CompassFrame then
        SafeSetState(ZO_CompassFrame, hide)
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

    local vars = CombatFPSBooster.savedVars
    if not vars then
        isApplying = false
        return
    end

    -- 1. Компас
    if vars.hideCompass then
        SetCompassHidden(inCombat)
    else
        SetCompassHidden(false)
    end

    -- 2. Трекер заданий
    if vars.hideQuests then
        SetQuestTrackerHidden(inCombat)
    else
        SetQuestTrackerHidden(false)
    end

    -- 3. Оповещения опыта, золота и лута
    if vars.hideAlerts then
        SetAlertsHidden(inCombat)
    else
        SetAlertsHidden(false)
    end

    -- Сборщик мусора Lua после завершения боя
    if not inCombat and collectgarbage then
        collectgarbage("step", 100)
    end

    isApplying = false
end

local function RequestApplyCombatVisualState(delayMs)
    delayMs = delayMs or 0
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_CombatApplyDelay")

    if delayMs <= 0 then
        ApplyCombatVisualState(IsUnitInCombat("player"))
        return
    end

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_CombatApplyDelay", delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_CombatApplyDelay")
        ApplyCombatVisualState(IsUnitInCombat("player"))
    end)
end

-- Вход и выход из боя
local function OnPlayerCombatState(eventCode, inCombat)
    RequestApplyCombatVisualState(inCombat and 0 or 200)
end

-- Загрузка локаций и телепорты
local function OnPlayerActivated(eventCode)
    RequestApplyCombatVisualState(500)
end

-- Воскрешение на месте камнем душ или союзником
local function OnPlayerAlive(eventCode)
    RequestApplyCombatVisualState(500)
end

-- Сброс состояния при подтверждении респавна
local function OnRespawnResult(eventCode, result)
    RequestApplyCombatVisualState(500)
end

-- Возврат интерфейса при смерти персонажа (экран смерти должен быть чистым)
local function OnPlayerDead(eventCode)
    RequestApplyCombatVisualState(100)
end

local function RegisterSettingsMenu()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local L = CombatFPSBooster.L or {}

    local settings = LibHarven:AddAddon(L.TITLE or "Tetsu's Combat FPS Booster")
    if not settings then return end

    settings.version = "1.2.1"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_COMPASS or "Hide compass in combat",
        tooltip = L.HIDE_COMPASS_TT or "Hides compass during combat.",
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideCompass end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideCompass = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_QUESTS or "Hide quest tracker in combat",
        tooltip = L.HIDE_QUESTS_TT or "Hides active quests during combat.",
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideQuests end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideQuests = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_ALERTS or "Hide XP/Gold alerts in combat",
        tooltip = L.HIDE_ALERTS_TT or "Hides alerts during combat.",
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideAlerts end,
        setFunction = function(val)
            CombatFPSBooster.savedVars.hideAlerts = val
            ApplyCombatVisualState(IsUnitInCombat("player"))
        end,
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

    RegisterSettingsMenu()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ALIVE, OnPlayerAlive)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_RESPAWN_RESULT, OnRespawnResult)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_DEAD, OnPlayerDead)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)