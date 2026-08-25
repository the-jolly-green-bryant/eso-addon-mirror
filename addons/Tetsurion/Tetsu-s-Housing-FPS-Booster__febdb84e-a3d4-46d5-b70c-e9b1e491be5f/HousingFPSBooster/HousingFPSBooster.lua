local ADDON_NAME = "HousingFPSBooster"
HousingFPSBooster = HousingFPSBooster or {}

local defaultSettings = {
    enableHousingBooster = true,
    hideCombatBars       = true,
}

local isApplyingState = false
local wasInHouse = false

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

local function SetAttributeBarsFragmentActive(active)
    local fragments = {
        PLAYER_ATTRIBUTE_BARS_FRAGMENT,
        GAMEPAD_PLAYER_ATTRIBUTE_BARS_FRAGMENT,
    }

    local scenes = { "hud", "hudui" }

    for _, frag in ipairs(fragments) do
        if frag then
            for _, sceneName in ipairs(scenes) do
                local scene = SCENE_MANAGER:GetScene(sceneName)
                if scene then
                    local hasFrag = scene:HasFragment(frag)
                    if active and not hasFrag then
                        scene:AddFragment(frag)
                    elseif not active and hasFrag then
                        scene:RemoveFragment(frag)
                    end
                end
            end
        end
    end
end

local function SetGamepadQuestTrackerHidden(hide)
    SafeSetState(ZO_FocusedQuestTrackerPanel_Gamepad, hide)
    SafeSetState(ZO_FocusedQuestTrackerPanel, hide)
end

local function CancelAllRestorationTimers()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage1_Nav")
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage2_ActionBar")
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage3_Attributes")
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage4_Harvest")
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_ApplyDelay")
end

local function HandleHarvestMap(inHouse)
    if Harvest and Harvest.compass then
        if inHouse then
            EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage4_Harvest")
            if Harvest.compass.Disable then
                pcall(function() Harvest.compass:Disable() end)
            end
        end
    end
end

-- Поэтапное пробуждение интерфейса при выходе в открытый мир
local function StartStagedRestoration()
    CancelAllRestorationTimers()

    -- Этап 1 (2.0 сек): Компас и квесты
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Stage1_Nav", 2000, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage1_Nav")
        if COMPASS_FRAME and COMPASS_FRAME.SetCustomPinsEnabled then
            COMPASS_FRAME:SetCustomPinsEnabled(true)
        end
        if ZO_CompassFrame then
            SafeSetState(ZO_CompassFrame, false)
        end
        SetGamepadQuestTrackerHidden(false)
    end)

    -- Этап 2 (4.0 сек): Панель способностей
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Stage2_ActionBar", 4000, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage2_ActionBar")
        SafeSetState(ZO_ActionBar1, false)
    end)

    -- Этап 3 (6.0 сек): Полоски ресурсов и фрагменты
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Stage3_Attributes", 6000, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage3_Attributes")
        SetAttributeBarsFragmentActive(true)
        SafeSetState(ZO_PlayerAttributeBars, false)
        SafeSetState(ZO_PlayerAttributeBars_Gamepad, false)
    end)

    -- Этап 4 (8.0 сек): Метки HarvestMap
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Stage4_Harvest", 8000, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Stage4_Harvest")
        if Harvest and Harvest.compass and Harvest.compass.Enable then
            pcall(function() Harvest.compass:Enable() end)
        end
    end)
end

local function ApplyHousingVisualState()
    if isApplyingState then return end
    isApplyingState = true

    local vars = HousingFPSBooster.savedVars
    if not vars then 
        isApplyingState = false
        return 
    end

    local currentHouseId = GetCurrentZoneHouseId()
    local inHouse = (currentHouseId ~= nil and currentHouseId > 0)
    local inCombat = IsUnitInCombat("player")

    if inHouse and vars.enableHousingBooster then
        wasInHouse = true
        CancelAllRestorationTimers()

        -- 1. Скрытие компаса и квестов
        if ZO_CompassFrame then
            SafeSetState(ZO_CompassFrame, true)
        end
        if COMPASS_FRAME and COMPASS_FRAME.SetCustomPinsEnabled then
            COMPASS_FRAME:SetCustomPinsEnabled(false)
        end
        HandleHarvestMap(true)
        SetGamepadQuestTrackerHidden(true)

        -- 2. Скрытие боевых панелей вне боя (на манекене в бою всё видно)
        local shouldHideBars = vars.hideCombatBars and (not inCombat)

        SafeSetState(ZO_ActionBar1, shouldHideBars)
        SetAttributeBarsFragmentActive(not shouldHideBars)
        SafeSetState(ZO_PlayerAttributeBars, shouldHideBars)
        SafeSetState(ZO_PlayerAttributeBars_Gamepad, shouldHideBars)

    else
        -- Возврат интерфейса при выходе в открытый мир
        if wasInHouse or (not vars.enableHousingBooster) then
            wasInHouse = false
            StartStagedRestoration()
        end
    end

    isApplyingState = false
end

local function RequestApplyHousingVisualState(delayMs)
    delayMs = delayMs or 0
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_ApplyDelay")

    if delayMs <= 0 then
        ApplyHousingVisualState()
        return
    end

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_ApplyDelay", delayMs, function()
        EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_ApplyDelay")
        ApplyHousingVisualState()
    end)
end

-- Перехват открытия HUD после меню карты и инвентаря
local function HookHudScenes()
    local scenes = { "hud", "hudui" }
    for _, sceneName in ipairs(scenes) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene then
            scene:RegisterCallback("StateChange", function(oldState, newState)
                if newState == SCENE_SHOWN then
                    local currentHouseId = GetCurrentZoneHouseId()
                    if currentHouseId and currentHouseId > 0 then
                        RequestApplyHousingVisualState(150)
                    end
                end
            end)
        end
    end
end

local function OnPlayerActivated(eventCode)
    local currentHouseId = GetCurrentZoneHouseId()
    local inHouse = (currentHouseId ~= nil and currentHouseId > 0)
    -- 500 мс в доме, 2000 мс в открытом мире для защиты CPU
    RequestApplyHousingVisualState(inHouse and 500 or 2000)
end

local function OnPlayerCombatState(eventCode, inCombat)
    local currentHouseId = GetCurrentZoneHouseId()
    if currentHouseId and currentHouseId > 0 then
        RequestApplyHousingVisualState(inCombat and 0 or 250)
    end
end

local function OnHousingEditorModeChanged(eventCode, oldMode, newMode)
    if newMode == HOUSING_EDITOR_MODE_DISABLED then
        RequestApplyHousingVisualState(200)
    end
end

local function RegisterSettingsMenu()
    local LibHarven = LibHarvensAddonSettings
    if not LibHarven then return end

    local L = HousingFPSBooster.L or {}

    local settings = LibHarven:AddAddon(L.TITLE or "Tetsu's Housing FPS Booster")
    if not settings then return end

    settings.version = "1.1.2"
    settings.author = "Tetsurion"

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.ENABLE_BOOSTER or "Enable Housing Booster",
        tooltip = L.ENABLE_BOOSTER_TT or "Optimizes UI and scripts in houses.",
        default = true,
        getFunction = function() return HousingFPSBooster.savedVars.enableHousingBooster end,
        setFunction = function(val)
            HousingFPSBooster.savedVars.enableHousingBooster = val
            ApplyHousingVisualState()
        end,
    })

    settings:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = L.HIDE_COMBAT_BARS or "Hide Action Bars & Attributes",
        tooltip = L.HIDE_COMBAT_BARS_TT or "Hides skills and resources. Disable for target dummies.",
        default = true,
        getFunction = function() return HousingFPSBooster.savedVars.hideCombatBars end,
        setFunction = function(val)
            HousingFPSBooster.savedVars.hideCombatBars = val
            ApplyHousingVisualState()
        end,
    })
end

local function OnAddOnLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    HousingFPSBooster.savedVars = ZO_SavedVars:NewAccountWide(
        "HousingFPSBoosterSavedVars",
        1,
        nil,
        defaultSettings
    )

    RegisterSettingsMenu()
    HookHudScenes()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_HOUSING_EDITOR_MODE_CHANGED, OnHousingEditorModeChanged)
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)