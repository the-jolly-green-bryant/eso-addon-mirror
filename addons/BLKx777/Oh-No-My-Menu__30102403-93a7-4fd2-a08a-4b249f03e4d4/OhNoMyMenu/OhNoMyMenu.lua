local ADDON_NAME = "OhNoMyMenu"

local ONMM = {
    version = "0.2.1-beta",
    inCombat = false,
    isDead = false,
    lastResurrectTargetMS = 0,
    sceneHooksInstalled = false,
    sceneCallbacksInstalled = false,
    p2pHooksInstalled = false,
}

local RESURRECT_TARGET_GRACE_MS = 1200

local RESURRECT_UNIT_TAGS = {
    "reticleoverplayer",
    "reticleovercompanion",
}

local BLOCKED_SCENES = {
    mainMenuGamepad = true,
    mainMenuKeyboard = true,
    mainMenu = true,
}

local function NowMS()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end
    if GetFrameTimeSeconds then
        return math.floor(GetFrameTimeSeconds() * 1000)
    end
    return 0
end

local function IsPlayerInCombat()
    return IsUnitInCombat and IsUnitInCombat("player") == true
end

local function IsPlayerDead()
    return IsUnitDead and IsUnitDead("player") == true
end

local function RefreshPlayerState()
    ONMM.inCombat = IsPlayerInCombat()
    ONMM.isDead = IsPlayerDead()
end

local function ClearResurrectTarget()
    ONMM.lastResurrectTargetMS = 0
end

local function MarkResurrectTarget()
    ONMM.lastResurrectTargetMS = NowMS()
end

local function IsResurrectTargetCurrent()
    if ONMM.inCombat ~= true or ONMM.isDead == true then return false end
    if not IsUnitResurrectableByPlayer then return false end

    for _, unitTag in ipairs(RESURRECT_UNIT_TAGS) do
        if IsUnitResurrectableByPlayer(unitTag) == true then
            return true
        end
    end

    return false
end

local function IsPlayerToPlayerResurrectPromptActive()
    if ONMM.inCombat ~= true or ONMM.isDead == true then return false end
    if not PLAYER_TO_PLAYER then return false end
    if PLAYER_TO_PLAYER.resurrectable ~= true then return false end

    if PLAYER_TO_PLAYER.IsHidden and PLAYER_TO_PLAYER:IsHidden() == true then
        return false
    end

    if PLAYER_TO_PLAYER.hasRequiredSoulGem == false then return false end
    if PLAYER_TO_PLAYER.failedRaidRevives == true then return false end
    if PLAYER_TO_PLAYER.isBeingResurrected == true then return false end
    if PLAYER_TO_PLAYER.hasResurrectPending == true then return false end

    return true
end

local function RefreshResurrectTargetState()
    RefreshPlayerState()

    if ONMM.inCombat ~= true or ONMM.isDead == true then
        ClearResurrectTarget()
        return
    end

    if IsResurrectTargetCurrent() or IsPlayerToPlayerResurrectPromptActive() then
        MarkResurrectTarget()
    end
end

local function WasResurrectTargetRecent()
    if ONMM.lastResurrectTargetMS <= 0 then return false end
    return NowMS() - ONMM.lastResurrectTargetMS <= RESURRECT_TARGET_GRACE_MS
end

local function ShouldBlockMenu()
    RefreshResurrectTargetState()

    return ONMM.inCombat == true
        and ONMM.isDead ~= true
        and WasResurrectTargetRecent()
end

local function IsBlockedScene(sceneName)
    return type(sceneName) == "string" and BLOCKED_SCENES[sceneName] == true
end

local function ContainsBlockedScene(...)
    for i = 1, select("#", ...) do
        if IsBlockedScene(select(i, ...)) then
            return true
        end
    end
    return false
end

local function HideBlockedScene(sceneName)
    if not IsBlockedScene(sceneName) then return end
    if not SCENE_MANAGER or not SCENE_MANAGER.GetScene then return end

    local scene = SCENE_MANAGER:GetScene(sceneName)
    if not scene or not scene.GetState then return end

    local state = scene:GetState()
    if state == SCENE_SHOWING or state == SCENE_SHOWN then
        if SCENE_MANAGER.Hide then
            SCENE_MANAGER:Hide(sceneName)
        elseif SCENE_MANAGER.ShowBaseScene then
            SCENE_MANAGER:ShowBaseScene()
        end
    end
end

local function OnCombatState(_, inCombat)
    ONMM.inCombat = inCombat == true
    ONMM.isDead = IsPlayerDead()

    if ONMM.inCombat ~= true or ONMM.isDead == true then
        ClearResurrectTarget()
    end
end

local function OnPlayerDead()
    ONMM.isDead = true
    ClearResurrectTarget()
end

local function OnPlayerAlive()
    ONMM.isDead = false
    ONMM.inCombat = IsPlayerInCombat()
    ClearResurrectTarget()
end

local function OnUnitDeathStateChanged(_, unitTag, isDead)
    if unitTag ~= "player" then return end

    ONMM.isDead = isDead == true
    ONMM.inCombat = IsPlayerInCombat()

    if ONMM.isDead == true then
        ClearResurrectTarget()
    end
end

local InstallPlayerToPlayerHooks

local function OnPlayerActivated()
    RefreshPlayerState()
    ClearResurrectTarget()
    if InstallPlayerToPlayerHooks then
        InstallPlayerToPlayerHooks()
    end
end

local function OnResurrectionEnded()
    ClearResurrectTarget()
end

InstallPlayerToPlayerHooks = function()
    if ONMM.p2pHooksInstalled then return end
    if not PLAYER_TO_PLAYER or not SecurePostHook then return end

    if PLAYER_TO_PLAYER.TryShowingResurrectLabel then
        SecurePostHook(PLAYER_TO_PLAYER, "TryShowingResurrectLabel", function(_, unitTag)
            RefreshPlayerState()
            if ONMM.inCombat == true and ONMM.isDead ~= true and IsUnitResurrectableByPlayer and IsUnitResurrectableByPlayer(unitTag) == true then
                MarkResurrectTarget()
            end
        end)
    end

    if PLAYER_TO_PLAYER.OnUpdate then
        SecurePostHook(PLAYER_TO_PLAYER, "OnUpdate", function()
            RefreshResurrectTargetState()
        end)
    end

    ONMM.p2pHooksInstalled = true
end

local function RegisterOptionalEvent(eventName, callback)
    local eventId = _G[eventName]
    if eventId ~= nil then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, eventId, callback)
    end
end

local function InstallSceneHooks()
    if ONMM.sceneHooksInstalled then return end
    if not SCENE_MANAGER or not ZO_PreHook then return end

    if SCENE_MANAGER.Push then
        ZO_PreHook(SCENE_MANAGER, "Push", function(_, sceneName)
            if ShouldBlockMenu() and IsBlockedScene(sceneName) then
                return true
            end
            return false
        end)
    end

    if SCENE_MANAGER.Show then
        ZO_PreHook(SCENE_MANAGER, "Show", function(_, sceneName)
            if ShouldBlockMenu() and IsBlockedScene(sceneName) then
                return true
            end
            return false
        end)
    end

    if SCENE_MANAGER.CreateStackFromScratch then
        ZO_PreHook(SCENE_MANAGER, "CreateStackFromScratch", function(_, ...)
            if ShouldBlockMenu() and ContainsBlockedScene(...) then
                return true
            end
            return false
        end)
    end

    ONMM.sceneHooksInstalled = true
end

local function InstallSceneCallbacks()
    if ONMM.sceneCallbacksInstalled then return end
    if not SCENE_MANAGER or not SCENE_MANAGER.GetScene then return end

    for sceneName in pairs(BLOCKED_SCENES) do
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene and scene.RegisterCallback then
            scene:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                    if ShouldBlockMenu() then
                        HideBlockedScene(sceneName)
                    end
                end
            end)
        end
    end

    ONMM.sceneCallbacksInstalled = true
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    RefreshPlayerState()
    ClearResurrectTarget()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_COMBAT_STATE, OnCombatState)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    RegisterOptionalEvent("EVENT_PLAYER_DEAD", OnPlayerDead)
    RegisterOptionalEvent("EVENT_PLAYER_ALIVE", OnPlayerAlive)
    RegisterOptionalEvent("EVENT_RESURRECT_RESULT", OnResurrectionEnded)
    RegisterOptionalEvent("EVENT_END_SOUL_GEM_RESURRECTION", OnResurrectionEnded)

    if EVENT_UNIT_DEATH_STATE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged)
        if EVENT_MANAGER.AddFilterForEvent and REGISTER_FILTER_UNIT_TAG ~= nil then
            EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    InstallPlayerToPlayerHooks()
    InstallSceneHooks()
    InstallSceneCallbacks()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
