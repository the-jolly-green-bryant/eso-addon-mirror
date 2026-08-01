--[[ Acknowledgement: Several portions of this code are based on Votan's Fisherman ]]
local FB = FishBar
local fishingInteractableName = nil
local interactionReady = false
local lastAction = nil
local lure = nil
local FISHING_INTERVAL = 30
local DEFAULT_FISHING_INTERVAL = 30
local FRAME_MOVE_INTERVAL = 604800
local isFishing = false
local bonus = 1

local function StartTimer(interval)
    local now = GetFrameTimeMilliseconds()
    local timerStartSeconds = now / 1000
    local timerEndSeconds = timerStartSeconds + interval

    FB.GUI:SetHidden(false)
    FB.timer:Start(timerStartSeconds, timerEndSeconds)
end

local function StopTimer()
    FB.timer:Stop()
    FB.GUI:SetHidden(true)
end

local function NewInteraction()
    if (not interactionReady or FB.moving) then
        return
    end

    local action, interactableName, _, _, additionalInfo = GetGameCameraInteractableActionInfo()

    if (action and interactableName) then
        if (lastAction == action) then
            return
        end

        lastAction = action

        if (additionalInfo == ADDITIONAL_INTERACT_INFO_FISHING_NODE) then
            fishingInteractableName = interactableName
        else
            local fishing = interactableName == fishingInteractableName

            if (fishing) then
                --FB.Log("fishing started", "info")
                lure = GetFishingLure()
                isFishing = true
                --FB.Log("interval: " .. FISHING_INTERVAL, "warn")
                StartTimer(FISHING_INTERVAL)
            else
                isFishing = false
                lure = nil
                StopTimer()
            end
        end
    else
        if (lastAction == action) then
            return
        end

        lastAction = action
    end
end

-- capture situations where fishing is interrupted
local function CheckInteraction(interactionPossible, _)
    if (interactionPossible) then
        local action = GetGameCameraInteractableActionInfo()

        if (action ~= FB.ReelIn) then
            if (isFishing) then
                StopTimer()
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                isFishing = false
            end
        end
    end
end

local function HookInteraction()
    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", NewInteraction)
    ZO_PreHookHandler(RETICLE.interact, "OnHide", NewInteraction)
    ZO_PostHook(RETICLE, "TryHandlingInteraction", CheckInteraction)
end

local function OnPlayerActivated()
    zo_callLater(
        function()
            interactionReady = true
        end,
        1000
    )
end

local function OnSlotUpdated(_, bagId, _, isNew)
    if (lure == nil) then
        return
    end

    if (bagId ~= BAG_BACKPACK and bagId ~= BAG_VIRTUAL) then
        return
    end

    if (not isNew) then
        if (lure) then
            --FB.Log("stopped fishing", "info")
            isFishing = false
            lure = nil
            StopTimer()

            -- play a sound if Votan's Fisherman is not installed
            if (not VOTANS_FISHERMAN) then
                PlaySound(SOUNDS.QUEST_ABANDONED)
            end
        end
    end
end

local function OnActionLayerChanged()
    if (not FB.moving) then
        StopTimer()
        return
    end
end

local function InitialiseGui(gui)
    FB.GUI = gui
    gui.owner = FB

    -- lock button
    FB.GUI.LockButton = gui:GetNamedChild("LockButton")

    -- timer
    local timerBar = gui:GetNamedChild("TimerBar")
    FB.timer = ZO_TimerBar:New(timerBar)
    FB.timer:SetDirection(TIMER_BAR_COUNTS_DOWN)

    -- set the 'Fishing...' label
    FB.Label = timerBar:GetNamedChild("Label")
    FB.Label:SetText(GetString(SI_GUILDACTIVITYATTRIBUTEVALUE9) .. "...")

    -- bar
    FB.Bar = timerBar:GetNamedChild("Status")

    -- set position and colours
    FB.Setup()
end

local function OnBonusChanged(_, bonusType)
    if (bonusType == NON_COMBAT_BONUS_FISHING_TIME_REDUCTION_PERCENT) then
        bonus = 1 - (GetNonCombatBonus(bonusType) / 100)
        --FB.Log("Bonus: " .. (bonus or "nil"), "warn")
        FISHING_INTERVAL = DEFAULT_FISHING_INTERVAL * bonus
    end
end

local function OnAchievementUpdated(_, achievementId)
    if (FB.Vars.PlayEmote) then
        -- are we tracking this achievement?
        if (FB.Achievements[achievementId]) then
            -- we caught a special fishy
            PlayEmoteByIndex(FB.Vars.Emote)
        end
    end
end

local function Initialise()
    if (LibDebugLogger ~= nil) then
        FB.Logger = LibDebugLogger(FB.Name)
    end

    -- saved variables
    FB.Vars =
        LibSavedVars:NewAccountWide("FishBarSavedVars", "Account", FB.Defaults):AddCharacterSettingsToggle(
            "FishBarSavedVars",
            "Characters"
        )

    -- get current language
    FB.Language = GetCVar("language.2")
    FB.ReelIn = GetString(SI_GAMECAMERAACTIONTYPE17)

    HookInteraction()

    EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdated)
    EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_ACTION_LAYER_POPPED, OnActionLayerChanged)
    EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_ACTION_LAYER_PUSHED, OnActionLayerChanged)
    EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_NON_COMBAT_BONUS_CHANGED, OnBonusChanged)
    EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_ACHIEVEMENT_UPDATED, OnAchievementUpdated)

    FB.RegisterSettings()

    bonus = 1 - (GetNonCombatBonus(NON_COMBAT_BONUS_FISHING_TIME_REDUCTION_PERCENT) / 100)
    FISHING_INTERVAL = DEFAULT_FISHING_INTERVAL * bonus

    InitialiseGui(FishBarWindow)
end

function FB.Setup()
    FB.Bar:SetColor(FB.Vars.BarColour.r, FB.Vars.BarColour.g, FB.Vars.BarColour.b, FB.Vars.BarColour.a)
    FB.Label:SetHidden(not FB.Vars.ShowFishing)
    FB.Label:SetColor(FB.Vars.LabelColour.r, FB.Vars.LabelColour.g, FB.Vars.LabelColour.b, FB.Vars.LabelColour.a)

    -- position
    local position = FB.Vars.Position

    if (position) then
        FB.GUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.Left, position.Top)
    end
end

function FB.EnableMoving()
    if (SCENE_MANAGER:IsInUIMode() and not WINDOW_MANAGER:IsSecureRenderModeEnabled()) then
        SCENE_MANAGER:SetInUIMode(false)
    end

    ZO_SceneManager_ToggleHUDUIBinding()
    StartTimer(FRAME_MOVE_INTERVAL)
    FB.GUI:SetMovable(true)
    FB.GUI:SetMouseEnabled(true)
    FB.GUI.LockButton:SetHidden(false)
    FB.moving = true
end

function FB.LockClick()
    -- save settings
    local top, left = FB.GUI:GetTop(), FB.GUI:GetLeft()

    FB.Vars.Position = {
        Top = top,
        Left = left
    }

    -- reset
    ZO_SceneManager_ToggleHUDUIBinding()
    FB.GUI:SetMouseEnabled(false)
    FB.GUI:SetMovable(false)
    FB.GUI.LockButton:SetHidden(true)
    StopTimer()
    FB.moving = false
end

function FB.Log(message, severity)
    if (FB.Logger) then
        if (severity == "info") then
            FB.Logger:Info(message)
        elseif (severity == "warn") then
            FB.Logger:Warn(message)
        elseif (severity == "debug") then
            FB.Logger:Debug(message)
        end
    end
end

function FB.OnAddonLoaded(_, addonName)
    if (addonName ~= FB.Name) then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(FB.Name, _G.EVENT_ADD_ON_LOADED)

    Initialise()
end

EVENT_MANAGER:RegisterForEvent(FB.Name, _G.EVENT_ADD_ON_LOADED, FB.OnAddonLoaded)
