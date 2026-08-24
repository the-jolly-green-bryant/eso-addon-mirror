local ADDON_NAME = "CombatFPSBooster"
CombatFPSBooster = CombatFPSBooster or {}

local defaultSettings = {
    hideCompass = true,
    hideQuests  = true,
    hideAlerts  = true,
}

local stateBeforeCombat = {
    compassHidden = false,
    questsHidden  = false,
    alertsHidden  = false,
}

local function SafeSetHidden(control, hidden)
    if control and control.SetHidden then
        control:SetHidden(hidden)
    end
end

local function HandleHarvestMap(inCombat)
    if Harvest and Harvest.compass then
        if inCombat then
            if Harvest.compass.Disable then
                pcall(function() Harvest.compass:Disable() end)
            end
        else
            if Harvest.compass.Enable then
                pcall(function() Harvest.compass:Enable() end)
            end
        end
    end
end

local function PerformGarbageCollection()
    collectgarbage("collect")
end

local function SetGamepadAlertsHidden(hidden)
    if ZO_LootHistoryControl_Gamepad then
        SafeSetHidden(ZO_LootHistoryControl_Gamepad, hidden)
    end
    if LOOT_HISTORY_GAMEPAD and LOOT_HISTORY_GAMEPAD.control then
        SafeSetHidden(LOOT_HISTORY_GAMEPAD.control, hidden)
    end
    if ZO_CenterScreenAnnounce then
        SafeSetHidden(ZO_CenterScreenAnnounce, hidden)
    end
end

local function SetCombatVisualState(inCombat)
    local vars = CombatFPSBooster.savedVars
    if not vars then return end

    if inCombat then
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_GC")

        -- 1. Скрытие компаса
        if vars.hideCompass then
            if ZO_CompassFrame then
                stateBeforeCombat.compassHidden = ZO_CompassFrame:IsHidden()
                SafeSetHidden(ZO_CompassFrame, true)
            end
            if COMPASS_FRAME and COMPASS_FRAME.SetCustomPinsEnabled then
                COMPASS_FRAME:SetCustomPinsEnabled(false)
            end
            HandleHarvestMap(true)
        end

        -- 2. Скрытие квестов
        if vars.hideQuests and ZO_FocusedQuestTrackerPanel then
            stateBeforeCombat.questsHidden = ZO_FocusedQuestTrackerPanel:IsHidden()
            SafeSetHidden(ZO_FocusedQuestTrackerPanel, true)
        end

        -- 3. Скрытие оповещений (Опыт, золото, лут в Gamepad Mode)
        if vars.hideAlerts then
            if ZO_LootHistoryControl_Gamepad then
                stateBeforeCombat.alertsHidden = ZO_LootHistoryControl_Gamepad:IsHidden()
            end
            SetGamepadAlertsHidden(true)
        end

    else
        -- ==========================================
        -- ВОЗВРАТ НАСТРОЕК ПОСЛЕ ВЫХОДА ИЗ БОЯ
        -- ==========================================
        if vars.hideCompass then
            HandleHarvestMap(false)
            if COMPASS_FRAME and COMPASS_FRAME.SetCustomPinsEnabled then
                COMPASS_FRAME:SetCustomPinsEnabled(true)
            end
            if ZO_CompassFrame and not stateBeforeCombat.compassHidden then
                SafeSetHidden(ZO_CompassFrame, false)
            end
        end

        if vars.hideQuests and ZO_FocusedQuestTrackerPanel then
            if not stateBeforeCombat.questsHidden then
                SafeSetHidden(ZO_FocusedQuestTrackerPanel, false)
            end
        end

        if vars.hideAlerts then
            if not stateBeforeCombat.alertsHidden then
                SetGamepadAlertsHidden(false)
            end
        end

        -- Фоновая очистка оперативной памяти Lua через 1 сек после боя
        EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_GC", 1000, function()
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_GC")
            PerformGarbageCollection()
        end)
    end
end

local function OnPlayerCombatState(eventCode, inCombat)
    SetCombatVisualState(inCombat)
end

local function RegisterSettingsMenu()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local L = CombatFPSBooster.L or {}

    local settings = LibHarven:AddAddon(L.TITLE or "Combat FPS Booster")
    if not settings then return end

    settings.version = "1.1.0"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_COMPASS or "Hide compass in combat",
        tooltip = L.HIDE_COMPASS_TT or "Hides compass during combat.",
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideCompass end,
        setFunction = function(val) CombatFPSBooster.savedVars.hideCompass = val end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_QUESTS or "Hide quest tracker",
        tooltip = L.HIDE_QUESTS_TT or "Hides active quest tracker in combat.",
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideQuests end,
        setFunction = function(val) CombatFPSBooster.savedVars.hideQuests = val end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_ALERTS or "Hide XP/Gold alerts in combat",
        tooltip = L.HIDE_ALERTS_TT or "Hides alerts during combat.",
        default = true,
        getFunction = function() return CombatFPSBooster.savedVars.hideAlerts end,
        setFunction = function(val) CombatFPSBooster.savedVars.hideAlerts = val end,
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
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)