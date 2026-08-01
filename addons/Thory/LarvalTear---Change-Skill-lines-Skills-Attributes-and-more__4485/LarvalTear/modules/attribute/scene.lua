local Addon = LarvalTearMod
local LTM_ATTRIBUTE_SCENE = Addon.Modules.AttributeScene
local DOMAINS = Addon.Common.Domains
local ATTRIBUTE_TYPES = DOMAINS.AttributeTypes
local ATTRIBUTE_ORDER = DOMAINS.AttributeOrder

local function IsGamepadPreferred()
    return type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() == true
end

local function IsShowingScene(sceneName)
    return type(SCENE_MANAGER) == "table"
        and type(SCENE_MANAGER.IsShowing) == "function"
        and SCENE_MANAGER:IsShowing(sceneName) == true
end

function LTM_ATTRIBUTE_SCENE:IsStatsSceneShowing()
    return IsShowingScene("stats") or IsShowingScene("gamepad_stats_root")
end

function LTM_ATTRIBUTE_SCENE:GetCurrentInteractionTypeSafe()
    if type(GetInteractionType) == "function" then
        return GetInteractionType()
    end

    return nil
end

function LTM_ATTRIBUTE_SCENE:CollectRespecContext(statsManager)
    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local isShowingStats = IsShowingScene("stats")
    local isShowingGamepadStats = IsShowingScene("gamepad_stats_root")
    local currentSceneName = nil
    local interactionType = nil
    local hasIsInGamepadPreferredMode = type(IsInGamepadPreferredMode) == "function"
    local isGamepadPreferred = hasIsInGamepadPreferredMode and IsInGamepadPreferredMode() or nil

    if currentScene and type(currentScene.GetName) == "function" then
        currentSceneName = currentScene:GetName()
    end

    if type(GetInteractionType) == "function" then
        interactionType = GetInteractionType()
    end

    return {
        hasSceneManager = true,
        isShowingStats = isShowingStats,
        isShowingGamepadStats = isShowingGamepadStats,
        currentSceneName = currentSceneName,
        currentSceneExists = currentScene ~= nil,
        statsManagerExists = type(statsManager) == "table",
        statsManagerAttributeControlsExists = type(statsManager) == "table" and type(statsManager.attributeControls) == "table",
        statsManagerAttributeDataExists = type(statsManager) == "table" and type(statsManager.attributeData) == "table",
        hasIsInGamepadPreferredMode = hasIsInGamepadPreferredMode,
        isGamepadPreferred = isGamepadPreferred,
        isPlayerInCombat = type(IsUnitInCombat) == "function" and IsUnitInCombat("player") or nil,
        isRaidInProgress = type(IsRaidInProgress) == "function" and IsRaidInProgress() or nil,
        isVengeance = type(IsCurrentCampaignVengeanceRuleset) == "function" and IsCurrentCampaignVengeanceRuleset() or nil,
        interactionType = interactionType,
        expectedInteractionType = INTERACTION_ATTRIBUTE_RESPEC,
        attributePointAllocationMode = type(statsManager) == "table" and statsManager.attributePointAllocationMode or nil,
        attributeRespecPaymentType = type(statsManager) == "table" and statsManager.attributeRespecPaymentType or nil,
    }
end

function LTM_ATTRIBUTE_SCENE:SnapshotAttributeState(statsManager)
    return self:CollectRespecContext(statsManager)
end

function LTM_ATTRIBUTE_SCENE:IsAttributeRespecReady(snapshot)
    if snapshot and snapshot.isGamepadPreferred == true then
        return snapshot.isShowingGamepadStats == true
            and snapshot.currentSceneName == "gamepad_stats_root"
            and snapshot.statsManagerAttributeDataExists == true
            and snapshot.interactionType == INTERACTION_ATTRIBUTE_RESPEC
    end

    return snapshot
        and snapshot.isShowingStats == true
        and snapshot.currentSceneName == "stats"
        and snapshot.statsManagerAttributeControlsExists == true
        and snapshot.interactionType == INTERACTION_ATTRIBUTE_RESPEC
end

function LTM_ATTRIBUTE_SCENE:IsStatsSceneReady(snapshot)
    if snapshot and snapshot.isGamepadPreferred == true then
        return snapshot.isShowingGamepadStats == true
            and snapshot.currentSceneName == "gamepad_stats_root"
            and snapshot.statsManagerAttributeDataExists == true
    end

    return snapshot
        and snapshot.isShowingStats == true
        and snapshot.currentSceneName == "stats"
        and snapshot.statsManagerAttributeControlsExists == true
end

function LTM_ATTRIBUTE_SCENE:CanInvokeAttributeRespecStart(snapshot)
    return snapshot
        and self:IsStatsSceneReady(snapshot)
        and snapshot.interactionType ~= INTERACTION_ATTRIBUTE_RESPEC
end

function LTM_ATTRIBUTE_SCENE:GetCurrentRespecInteractionState()
    local hasGetInteractionType = type(GetInteractionType) == "function"
    local hasRespecConstant = INTERACTION_ATTRIBUTE_RESPEC ~= nil

    if not hasGetInteractionType or not hasRespecConstant then
        return false, nil
    end

    local interactionType = GetInteractionType()

    if interactionType ~= INTERACTION_ATTRIBUTE_RESPEC then
        return false, interactionType
    end

    return true, interactionType
end

local function TryOpenStatsSceneViaMainMenuKeyboard()
    if type(MAIN_MENU_KEYBOARD) ~= "table" or type(MAIN_MENU_KEYBOARD.ShowScene) ~= "function" then
        return false
    end

    MAIN_MENU_KEYBOARD:ShowScene("stats")
    return true
end

local function TryOpenStatsSceneViaSceneManagerShow()
    SCENE_MANAGER:Show("stats")
    return true
end

local function TryOpenStatsSceneViaSceneManagerPush()
    SCENE_MANAGER:Push("stats")
    return true
end

local function TryOpenGamepadStatsSceneViaMainMenuGamepad()
    if type(MAIN_MENU_GAMEPAD) ~= "table" or type(MAIN_MENU_GAMEPAD.ShowScene) ~= "function" then
        return false
    end

    MAIN_MENU_GAMEPAD:ShowScene("gamepad_stats_root")
    return true
end

local function TryOpenGamepadStatsSceneViaSceneManagerShow()
    SCENE_MANAGER:Show("gamepad_stats_root")
    return true
end

local function TryOpenGamepadStatsSceneViaSceneManagerPush()
    SCENE_MANAGER:Push("gamepad_stats_root")
    return true
end

function LTM_ATTRIBUTE_SCENE:BuildStatsSceneOpenCandidates()
    if IsGamepadPreferred() then
        return {
            {
                label = "MAIN_MENU_GAMEPAD:ShowScene(gamepad_stats_root)",
                invoke = TryOpenGamepadStatsSceneViaMainMenuGamepad,
            },
            {
                label = "SCENE_MANAGER:Show(gamepad_stats_root)",
                invoke = TryOpenGamepadStatsSceneViaSceneManagerShow,
            },
            {
                label = "SCENE_MANAGER:Push(gamepad_stats_root)",
                invoke = TryOpenGamepadStatsSceneViaSceneManagerPush,
            },
        }
    end

    return {
        {
            label = "MAIN_MENU_KEYBOARD:ShowScene(stats)",
            invoke = TryOpenStatsSceneViaMainMenuKeyboard,
        },
        {
            label = "SCENE_MANAGER:Show(stats)",
            invoke = TryOpenStatsSceneViaSceneManagerShow,
        },
        {
            label = "SCENE_MANAGER:Push(stats)",
            invoke = TryOpenStatsSceneViaSceneManagerPush,
        },
    }
end

function LTM_ATTRIBUTE_SCENE:InvokeStatsSceneOpenCandidate(candidate)
    return candidate.invoke() == true
end

function LTM_ATTRIBUTE_SCENE:FindKeyboardSpinner(statsManager, attributeType)
    if not statsManager or type(statsManager.attributeControls) ~= "table" then
        return nil
    end

    for _, control in ipairs(statsManager.attributeControls) do
        if control and control.attributeType == attributeType then
            return control.pointLimitedSpinner, control
        end
    end

    return nil, nil
end

function LTM_ATTRIBUTE_SCENE:SearchClearCandidates(statsManager)
    local candidates = {
        keyboard_controls = type(statsManager) == "table" and type(statsManager.attributeControls) == "table",
        gamepad_data = type(statsManager) == "table" and type(statsManager.attributeData) == "table",
        reset_added_points = false,
        set_added_points_by_total = false,
        set_gamepad_added_points = type(statsManager) == "table" and type(statsManager.SetAddedPoints) == "function",
    }

    if candidates.keyboard_controls then
        for _, key in ipairs(ATTRIBUTE_ORDER) do
            local attributeType = ATTRIBUTE_TYPES[key]
            local spinner = self:FindKeyboardSpinner(statsManager, attributeType)
            if spinner then
                candidates.reset_added_points = candidates.reset_added_points or type(spinner.ResetAddedPoints) == "function"
                candidates.set_added_points_by_total = candidates.set_added_points_by_total or type(spinner.SetAddedPointsByTotalPoints) == "function"
            end
        end
    end

    return candidates
end
