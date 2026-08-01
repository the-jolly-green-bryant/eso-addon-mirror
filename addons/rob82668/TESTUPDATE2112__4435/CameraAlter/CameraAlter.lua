local ADDON_NAME = "CameraAlter"
local CameraAlter = {}

CameraAlter.defaults = {
    enabled = true,
    blockInventory = true,
    blockCharacter = true,
    blockCrafting = true,
    blockStyleStations = false,
    blockDialogue = true,
    blockMerchant = true,
    blockCompanion = true,
    maintainCameraState = true,
    maintainEveryMs = 10,
    interactionGraceMs = 1200,
    releaseStabilityMs = 320,
    interactionChainLockMs = 1000,
    persistentLogging = true,
    playIdleWhenOpen = false,
    debug = false,
}

CameraAlter.state = {
    blocking = false,
    activeScene = nil,
    savedHeading = nil,
    savedPitch = nil,
    removedFragmentsByScene = {},
    inReinforcement = false,
    interactionGraceUntilMs = 0,
    pendingDisableAtMs = 0,
    pendingDisableReason = nil,
    noReasonSinceMs = 0,
    interactionChainLockUntilMs = 0,
}

local trackedScenes = {
    inventory = "blockInventory",
    gamepad_inventory_root = "blockInventory",
    character = "blockCharacter",
    stats = "blockCharacter",
    gamepad_stats_root = "blockCharacter",
    interact = "blockDialogue",

    -- Keyboard crafting scenes.
    alchemy = "blockCrafting",
    enchanting = "blockCrafting",
    smithing = "blockCrafting",
    provisioner = "blockCrafting",
    provisioning = "blockCrafting",
    jewelryCrafting = "blockCrafting",

    -- Common gamepad crafting roots.
    gamepad_alchemy_root = "blockCrafting",
    gamepad_enchanting_root = "blockCrafting",
    gamepad_smithing_root = "blockCrafting",
    gamepad_provisioner_root = "blockCrafting",
    gamepad_provisioning_root = "blockCrafting",
    gamepad_jewelry_root = "blockCrafting",

    -- Dye / outfitter style stations (default OFF).
    restyle = "blockStyleStations",
    restyle_station = "blockStyleStations",
    outfit = "blockStyleStations",
    outfitter = "blockStyleStations",
    dye = "blockStyleStations",

    -- Companion / assistant style scenes (default ON).
    companion = "blockCompanion",
    companions = "blockCompanion",
    companionKeyboard = "blockCompanion",
    companionGamepad = "blockCompanion",
    companionCharacter = "blockCompanion",
    companionRapport = "blockCompanion",

    -- Merchant/store style scenes.
    store = "blockMerchant",
    gamepad_store = "blockMerchant",
    fence_keyboard = "blockMerchant",
    gamepad_fence = "blockMerchant",
    stables = "blockMerchant",
    gamepad_stable = "blockMerchant",
}

local interactionTypeToSetting = {
    INTERACTION_CRAFT = "blockCrafting",
    INTERACTION_CONVERSATION = "blockDialogue",
    INTERACTION_QUEST = "blockDialogue",
    INTERACTION_VENDOR = "blockMerchant",
    INTERACTION_STABLE = "blockMerchant",
    INTERACTION_DYE_STATION = "blockStyleStations",
}

local function IsFn(name)
    return type(_G[name]) == "function"
end

local function IsEventId(name)
    return type(_G[name]) == "number"
end

local function DebugLog(...)
    if CameraAlter.sv and CameraAlter.sv.debug then
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        local message = table.concat(parts, " ")
        d(string.format("[%s] %s", ADDON_NAME, message))
        CameraAlter:PersistLog(message, false)
    end
end

local function SceneMatches(sceneName)
    if type(sceneName) ~= "string" then
        return false
    end

    local settingName = trackedScenes[sceneName]
    if settingName then
        return CameraAlter.sv and CameraAlter.sv[settingName] == true
    end

    if not CameraAlter.sv then
        return false
    end

    local normalized = zo_strlower(sceneName)

    -- Some scene names vary by API/client language; use conservative keyword matching.
    if CameraAlter.sv.blockCrafting and (
        string.find(normalized, "craft", 1, true) ~= nil
        or string.find(normalized, "smith", 1, true) ~= nil
        or string.find(normalized, "enchant", 1, true) ~= nil
        or string.find(normalized, "alchemy", 1, true) ~= nil
        or string.find(normalized, "provision", 1, true) ~= nil
        or string.find(normalized, "jewelry", 1, true) ~= nil
    ) then
        return true
    end

    if CameraAlter.sv.blockDialogue and (
        normalized == "interact"
        or string.find(normalized, "dialog", 1, true) ~= nil
        or string.find(normalized, "conversation", 1, true) ~= nil
        or string.find(normalized, "quest", 1, true) ~= nil
    ) then
        return true
    end

    if CameraAlter.sv.blockMerchant and (
        string.find(normalized, "store", 1, true) ~= nil
        or string.find(normalized, "vendor", 1, true) ~= nil
        or string.find(normalized, "merchant", 1, true) ~= nil
        or string.find(normalized, "fence", 1, true) ~= nil
        or string.find(normalized, "stable", 1, true) ~= nil
    ) then
        return true
    end

    return false
end

local function ShouldBlockCurrentInteractionType()
    if type(GetInteractionType) ~= "function" or not CameraAlter.sv then
        return false
    end

    local interactionType = GetInteractionType()
    if interactionType == nil or (type(_G.INTERACTION_NONE) == "number" and interactionType == INTERACTION_NONE) then
        return false
    end

    for key, settingName in pairs(interactionTypeToSetting) do
        local interactionConst = _G[key]
        if type(interactionConst) == "number" and interactionType == interactionConst then
            return CameraAlter.sv[settingName] == true
        end
    end

    return false
end

local function GetCurrentInteractionType()
    if type(GetInteractionType) ~= "function" then
        return nil
    end

    local ok, interactionType = pcall(GetInteractionType)
    if ok then
        return interactionType
    end

    return nil
end

local function IsInteractionTypeNamed(interactionType, name)
    local interactionConst = _G[name]
    return type(interactionConst) == "number" and interactionType == interactionConst
end

local function ShouldBlockCompanionContext()
    if not CameraAlter.sv or not CameraAlter.sv.blockCompanion then
        return false
    end

    if IsFn("IsInteractingWithMyAssistant") then
        local ok, isAssistant = pcall(IsInteractingWithMyAssistant)
        if ok and isAssistant then
            return true
        end
    end

    return false
end

local function IsCurrentSceneBlockedBySettings()
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetCurrentScene) ~= "function" then
        return false
    end

    local currentScene = SCENE_MANAGER:GetCurrentScene()
    if not currentScene or type(currentScene.GetName) ~= "function" then
        return false
    end

    local sceneName = currentScene:GetName()
    return SceneMatches(sceneName)
end

local function HasAnyBlockingReason()
    return ShouldBlockCurrentInteractionType() or ShouldBlockCompanionContext() or IsCurrentSceneBlockedBySettings()
end

local function GetNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        local ok, now = pcall(GetFrameTimeMilliseconds)
        if ok and type(now) == "number" then
            return now
        end
    end

    return 0
end

function CameraAlter:PersistLog(message, force)
    if not self.sv then
        return
    end

    if not force and not self.sv.persistentLogging then
        return
    end

    self.sv.logBuffer = self.sv.logBuffer or {}
    local nowMs = GetNowMs()
    local line = string.format("%d | %s", nowMs, tostring(message))
    table.insert(self.sv.logBuffer, line)

    local maxLines = 400
    while #self.sv.logBuffer > maxLines do
        table.remove(self.sv.logBuffer, 1)
    end
end

function CameraAlter:CancelPendingDisable()
    if (self.state.pendingDisableAtMs or 0) > 0 then
        self:PersistLog("Cancel pending disable", true)
    end
    self.state.pendingDisableAtMs = 0
    self.state.pendingDisableReason = nil
end

function CameraAlter:RequestDisable(reason, delayMs)
    if not self.state.blocking then
        return
    end

    local nowMs = GetNowMs()
    local safeDelay = math.max(0, tonumber(delayMs) or 0)
    local targetMs = nowMs + safeDelay

    if targetMs > (self.state.pendingDisableAtMs or 0) then
        self.state.pendingDisableAtMs = targetMs
        self.state.pendingDisableReason = reason
        self:PersistLog(string.format("Queue disable in %dms (%s)", safeDelay, tostring(reason)), true)
    end
end

local function ResolveSceneName(sceneOrName)
    if type(sceneOrName) == "string" then
        return sceneOrName
    end

    if type(sceneOrName) == "table" and type(sceneOrName.GetName) == "function" then
        local ok, name = pcall(sceneOrName.GetName, sceneOrName)
        if ok then
            return name
        end
    end

    return nil
end

function CameraAlter:CaptureCameraState()
    if IsFn("GetPlayerCameraHeading") then
        local ok, value = pcall(GetPlayerCameraHeading)
        if ok then
            self.state.savedHeading = value
        end
    end

    if IsFn("GetPlayerCameraPitch") then
        local ok, value = pcall(GetPlayerCameraPitch)
        if ok then
            self.state.savedPitch = value
        end
    end
end

function CameraAlter:RestoreCameraState()
    if not self.sv.maintainCameraState then
        return
    end

    if self.state.savedHeading ~= nil and IsFn("SetPlayerCameraHeading") then
        pcall(SetPlayerCameraHeading, self.state.savedHeading)
    end

    if self.state.savedPitch ~= nil and IsFn("SetPlayerCameraPitch") then
        pcall(SetPlayerCameraPitch, self.state.savedPitch)
    end
end

function CameraAlter:ForceDisableFraming()
    local disableCalls = {
        "ZO_SetPlayerSceneFramingEnabled",
        "ZO_EnablePlayerSceneFraming",
        "SetPlayerSceneFramingEnabled",
    }

    for _, fnName in ipairs(disableCalls) do
        if IsFn(fnName) then
            pcall(_G[fnName], false)
        end
    end

    if IsFn("SetFrameLocalPlayerInGameCamera") then
        pcall(SetFrameLocalPlayerInGameCamera, false)
    end

    if IsFn("SetInteractionUsingInteractCamera") then
        pcall(SetInteractionUsingInteractCamera, false)
    end

    if IsFn("SetFrameInteractionTarget") then
        pcall(SetFrameInteractionTarget, 0.5, 0.5)
    end

    if IsFn("SetFrameLocalPlayerLookAtDistanceFactor") then
        pcall(SetFrameLocalPlayerLookAtDistanceFactor, nil)
    end

    if IsFn("SetFramingScreenType") and type(_G.FRAMING_SCREEN_DEFAULT) == "number" then
        pcall(SetFramingScreenType, FRAMING_SCREEN_DEFAULT)
    end
end

function CameraAlter:GetSceneByName(sceneName)
    if not SCENE_MANAGER or type(SCENE_MANAGER.GetScene) ~= "function" then
        return nil
    end

    local ok, scene = pcall(SCENE_MANAGER.GetScene, SCENE_MANAGER, sceneName)
    if ok then
        return scene
    end

    return nil
end

function CameraAlter:ApplySceneFragmentPolicy(sceneName, remove)
    local scene = self:GetSceneByName(sceneName)
    if not scene then
        return
    end

    if type(scene.RemoveFragment) ~= "function" or type(scene.AddFragment) ~= "function" then
        return
    end

    local fragmentNames = {
        "FRAME_PLAYER_FRAGMENT",
        "GAMEPAD_FRAME_PLAYER_FRAGMENT",
    }

    self.state.removedFragmentsByScene[sceneName] = self.state.removedFragmentsByScene[sceneName] or {}
    local removed = self.state.removedFragmentsByScene[sceneName]

    for _, fragmentName in ipairs(fragmentNames) do
        local fragment = _G[fragmentName]
        if fragment then
            if remove then
                local ok = pcall(scene.RemoveFragment, scene, fragment)
                if ok then
                    removed[fragmentName] = true
                end
            elseif removed[fragmentName] then
                pcall(scene.AddFragment, scene, fragment)
                removed[fragmentName] = nil
            end
        end
    end
end

function CameraAlter:StartMaintainer()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "_Maintain", self.sv.maintainEveryMs, function()
        local shouldBlockInteractionType = ShouldBlockCurrentInteractionType()
        local nowMs = GetNowMs()
        local currentInteractionType = GetCurrentInteractionType()

        if currentInteractionType ~= nil and self.sv.blockMerchant then
            if IsInteractionTypeNamed(currentInteractionType, "INTERACTION_VENDOR")
                or IsInteractionTypeNamed(currentInteractionType, "INTERACTION_CONVERSATION")
                or IsInteractionTypeNamed(currentInteractionType, "INTERACTION_QUEST")
            then
                self.state.interactionChainLockUntilMs = nowMs + (self.sv.interactionChainLockMs or 0)
            end
        end

        if ShouldBlockCompanionContext() then
            self.state.interactionChainLockUntilMs = nowMs + (self.sv.interactionChainLockMs or 0)
        end

        local hasChainLock = nowMs < (self.state.interactionChainLockUntilMs or 0)
        local hasAnyReason = HasAnyBlockingReason() or hasChainLock
        local nowMs = GetNowMs()
        local hasGrace = nowMs < (self.state.interactionGraceUntilMs or 0)

        if hasAnyReason then
            self:CancelPendingDisable()
            self.state.noReasonSinceMs = 0
        end

        if not self.state.blocking and (hasAnyReason or hasGrace) then
            self:EnableBlock("interaction_type")
        end

        if self.state.blocking then
            self:ForceDisableFraming()
            self:RestoreCameraState()

            if self.state.activeScene == "interaction_type" then
                if shouldBlockInteractionType then
                    self.state.interactionGraceUntilMs = 0
                else
                    if (self.state.interactionGraceUntilMs or 0) == 0 then
                        self.state.interactionGraceUntilMs = nowMs + (self.sv.interactionGraceMs or 0)
                    end

                    if nowMs >= (self.state.interactionGraceUntilMs or 0) then
                        self.state.interactionGraceUntilMs = 0
                        self:RequestDisable("interaction grace elapsed", 0)
                    end
                end
            end

            if not hasAnyReason and not hasGrace then
                if (self.state.noReasonSinceMs or 0) == 0 then
                    self.state.noReasonSinceMs = nowMs
                end
            end

            local pendingAt = self.state.pendingDisableAtMs or 0
            local stableForMs = (self.state.noReasonSinceMs or 0) > 0 and (nowMs - self.state.noReasonSinceMs) or 0
            if pendingAt > 0 and nowMs >= pendingAt and not hasAnyReason and not hasGrace and stableForMs >= (self.sv.releaseStabilityMs or 0) then
                self:DisableBlock()
            end
        end
    end)
end

function CameraAlter:StopMaintainer()
    EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME .. "_Maintain")
end

function CameraAlter:EnableBlock(sceneName)
    if not self.sv.enabled then
        return
    end

    if self.state.blocking then
        self.state.activeScene = sceneName or self.state.activeScene
        self.state.interactionGraceUntilMs = 0
        self:CancelPendingDisable()
        -- Re-apply immediately on scene handoff to avoid a 1-frame camera pop.
        self:ForceDisableFraming()
        self:RestoreCameraState()
        return
    end

    self.state.blocking = true
    self.state.activeScene = sceneName
    self.state.interactionGraceUntilMs = 0
    self.state.noReasonSinceMs = 0
    self:CancelPendingDisable()

    self:CaptureCameraState()
    self:ApplySceneFragmentPolicy(sceneName, true)
    self:ForceDisableFraming()

    if IsFn("SetGameCameraUIMode") then
        pcall(SetGameCameraUIMode, true)
    end

    self:StartMaintainer()

    if self.sv.playIdleWhenOpen and IsFn("DoCommand") then
        pcall(DoCommand, "/idle")
    end

    DebugLog("Blocking enabled for scene", sceneName)
    self:PersistLog("Block ON: " .. tostring(sceneName), true)
end

function CameraAlter:DisableBlock()
    if not self.state.blocking then
        return
    end

    if self.state.activeScene then
        self:ApplySceneFragmentPolicy(self.state.activeScene, false)
    end

    self.state.blocking = false
    self.state.activeScene = nil
    self.state.interactionGraceUntilMs = 0
    self.state.noReasonSinceMs = 0
    self:CancelPendingDisable()
    self:StopMaintainer()

    DebugLog("Blocking disabled")
    self:PersistLog("Block OFF", true)
end

function CameraAlter:IsBlocking()
    return self.sv.enabled and self.state.blocking
end

function CameraAlter:InstallBestEffortHooks()
    if type(ZO_PreHook) ~= "function" then
        return
    end

    local function BlockWhenActive(...)
        if CameraAlter:IsBlocking() then
            local firstArg = select(1, ...)
            if firstArg == false then
                return false
            end
            DebugLog("Blocked camera/framing call")
            return true
        end

        return false
    end

    -- These symbols differ by game version; hook whatever exists.
    local hookTargets = {
        "ZO_SetPlayerSceneFramingEnabled",
        "ZO_EnablePlayerSceneFraming",
        "SetPlayerSceneFramingEnabled",
        "SetFrameLocalPlayerInGameCamera",
        "RequestReframeLocalPlayerInGameCamera",
        "SetInteractionUsingInteractCamera",
        "SetFrameInteractionTarget",
        "SetFrameLocalPlayerLookAtDistanceFactor",
        "SetFramingScreenType",
    }

    for _, fnName in ipairs(hookTargets) do
        if IsFn(fnName) then
            ZO_PreHook(fnName, BlockWhenActive)
            DebugLog("Installed hook on", fnName)
        end
    end
end

function CameraAlter:InstallReinforcementPostHooks()
    if type(ZO_PostHook) ~= "function" then
        return
    end

    local function ReinforceWhenActive(...)
        if not CameraAlter:IsBlocking() then
            return
        end

        if CameraAlter.state.inReinforcement then
            return
        end

        CameraAlter.state.inReinforcement = true

        CameraAlter:ForceDisableFraming()
        CameraAlter:RestoreCameraState()
        CameraAlter.state.inReinforcement = false
    end

    local postTargets = {
        "ZO_SetPlayerSceneFramingEnabled",
        "ZO_EnablePlayerSceneFraming",
        "SetPlayerSceneFramingEnabled",
    }

    for _, fnName in ipairs(postTargets) do
        if IsFn(fnName) then
            ZO_PostHook(fnName, ReinforceWhenActive)
            DebugLog("Installed post-hook on", fnName)
        end
    end
end

function CameraAlter:InstallSceneManagerHooks()
    if type(ZO_PreHook) ~= "function" or not SCENE_MANAGER then
        return
    end

    local function ArmBlockForScene(sceneOrName)
        local sceneName = ResolveSceneName(sceneOrName)
        if sceneName and SceneMatches(sceneName) then
            CameraAlter:EnableBlock(sceneName)
        end
    end

    if type(SCENE_MANAGER.Show) == "function" then
        ZO_PreHook(SCENE_MANAGER, "Show", function(_, sceneOrName, ...)
            ArmBlockForScene(sceneOrName)
            return false
        end)
    end

    if type(SCENE_MANAGER.Toggle) == "function" then
        ZO_PreHook(SCENE_MANAGER, "Toggle", function(_, sceneOrName, ...)
            ArmBlockForScene(sceneOrName)
            return false
        end)
    end

    if type(SCENE_MANAGER.Push) == "function" then
        ZO_PreHook(SCENE_MANAGER, "Push", function(_, sceneOrName, ...)
            ArmBlockForScene(sceneOrName)
            return false
        end)
    end

    if type(SCENE_MANAGER.ShowWithFollowup) == "function" then
        ZO_PreHook(SCENE_MANAGER, "ShowWithFollowup", function(_, sceneOrName, ...)
            ArmBlockForScene(sceneOrName)
            return false
        end)
    end
end

function CameraAlter:RegisterOptionalEvent(eventName, callback)
    if not IsEventId(eventName) then
        DebugLog("Event not present on this client:", eventName)
        return false
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_" .. eventName, _G[eventName], callback)
    DebugLog("Registered event hook:", eventName)
    return true
end

function CameraAlter:InstallInteractionEventHooks()
    -- Crafting station entry/exit.
    self:RegisterOptionalEvent("EVENT_CRAFTING_STATION_INTERACT", function(...)
        if self.sv.enabled and self.sv.blockCrafting then
            self:EnableBlock("crafting_event")
            DebugLog("Crafting interaction begin")
        end
    end)

    self:RegisterOptionalEvent("EVENT_END_CRAFTING_STATION_INTERACT", function(...)
        if self.state.blocking and self.state.activeScene == "crafting_event" then
            self:RequestDisable("crafting end", self.sv.interactionGraceMs or 0)
            DebugLog("Crafting interaction end")
        end
    end)

    -- Store open/close can use a different transition path than direct scene show.
    self:RegisterOptionalEvent("EVENT_OPEN_STORE", function(...)
        if self.sv.enabled and self.sv.blockMerchant then
            self:EnableBlock("store_event")
            DebugLog("Store open")
        end
    end)

    self:RegisterOptionalEvent("EVENT_CLOSE_STORE", function(...)
        if self.state.blocking and self.state.activeScene == "store_event" then
            self:RequestDisable("store close", self.sv.interactionGraceMs or 0)
            DebugLog("Store close")
        end
    end)

    self:RegisterOptionalEvent("EVENT_DYEING_STATION_INTERACT_START", function(...)
        if self.sv.enabled and self.sv.blockStyleStations then
            self:EnableBlock("style_station_event")
            DebugLog("Style station begin")
        end
    end)

    self:RegisterOptionalEvent("EVENT_DYEING_STATION_INTERACT_END", function(...)
        if self.state.blocking and self.state.activeScene == "style_station_event" then
            self:RequestDisable("style station end", self.sv.interactionGraceMs or 0)
            DebugLog("Style station end")
        end
    end)

    -- NPC conversation entry/exit.
    self:RegisterOptionalEvent("EVENT_CHATTER_BEGIN", function(...)
        if self.sv.enabled and self.sv.blockDialogue then
            self:EnableBlock("dialogue_event")
            DebugLog("Dialogue begin")
        end
    end)

    self:RegisterOptionalEvent("EVENT_CHATTER_END", function(...)
        if self.state.blocking and self.state.activeScene == "dialogue_event" then
            self:RequestDisable("dialogue end", self.sv.interactionGraceMs or 0)
            DebugLog("Dialogue end")
        end
    end)
end

function CameraAlter:InitializeSettings()
    local LAM = LibAddonMenu2
    if not LAM and type(LibStub) == "function" then
        LAM = LibStub("LibAddonMenu-2.0", true)
    end

    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = "Camera Alter",
        displayName = "Camera Alter",
        author = "rob82",
        version = "0.1.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "Panel", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Enable Addon",
            getFunc = function() return self.sv.enabled end,
            setFunc = function(value)
                self.sv.enabled = value
                if not value then
                    self:DisableBlock()
                end
            end,
            default = self.defaults.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block Inventory Camera Flip",
            getFunc = function() return self.sv.blockInventory end,
            setFunc = function(value) self.sv.blockInventory = value end,
            default = self.defaults.blockInventory,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block Character Sheet Camera Flip",
            getFunc = function() return self.sv.blockCharacter end,
            setFunc = function(value) self.sv.blockCharacter = value end,
            default = self.defaults.blockCharacter,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block Crafting Station Camera Change",
            tooltip = "When opening crafting station UI, keep your normal camera framing.",
            getFunc = function() return self.sv.blockCrafting end,
            setFunc = function(value) self.sv.blockCrafting = value end,
            default = self.defaults.blockCrafting,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block Dye/Outfitter Station Camera Change",
            tooltip = "Default OFF so you can see your character while changing style/colors.",
            getFunc = function() return self.sv.blockStyleStations end,
            setFunc = function(value) self.sv.blockStyleStations = value end,
            default = self.defaults.blockStyleStations,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block NPC Dialogue Camera Change",
            tooltip = "Applies to dialogue/quest conversation scenes.",
            getFunc = function() return self.sv.blockDialogue end,
            setFunc = function(value) self.sv.blockDialogue = value end,
            default = self.defaults.blockDialogue,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block Merchant Camera Change",
            tooltip = "Applies to merchant/store/fence/stable interactions.",
            getFunc = function() return self.sv.blockMerchant end,
            setFunc = function(value) self.sv.blockMerchant = value end,
            default = self.defaults.blockMerchant,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Block Companion/Assistant Camera Change",
            tooltip = "Default ON. Helps keep camera steady during companion/assistant interaction menus.",
            getFunc = function() return self.sv.blockCompanion end,
            setFunc = function(value) self.sv.blockCompanion = value end,
            default = self.defaults.blockCompanion,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Maintain Camera Heading/Pitch",
            tooltip = "Best effort. Runs while the target UI scene is open.",
            getFunc = function() return self.sv.maintainCameraState end,
            setFunc = function(value) self.sv.maintainCameraState = value end,
            default = self.defaults.maintainCameraState,
            width = "full",
        },
        {
            type = "slider",
            name = "Maintain Interval (ms)",
            min = 20,
            max = 250,
            step = 10,
            getFunc = function() return self.sv.maintainEveryMs end,
            setFunc = function(value)
                self.sv.maintainEveryMs = value
                if self.state.blocking then
                    self:StopMaintainer()
                    self:StartMaintainer()
                end
            end,
            default = self.defaults.maintainEveryMs,
            width = "full",
        },
        {
            type = "slider",
            name = "Interaction Transition Grace (ms)",
            tooltip = "Keeps blocking briefly when switching conversation <-> merchant/crafting to prevent camera flicker.",
            min = 0,
            max = 2000,
            step = 50,
            getFunc = function() return self.sv.interactionGraceMs end,
            setFunc = function(value) self.sv.interactionGraceMs = value end,
            default = self.defaults.interactionGraceMs,
            width = "full",
        },
        {
            type = "slider",
            name = "Release Stability (ms)",
            tooltip = "How long no interaction/camera-block reasons must persist before release. Higher = less flicker.",
            min = 0,
            max = 1000,
            step = 20,
            getFunc = function() return self.sv.releaseStabilityMs end,
            setFunc = function(value) self.sv.releaseStabilityMs = value end,
            default = self.defaults.releaseStabilityMs,
            width = "full",
        },
        {
            type = "slider",
            name = "Interaction Chain Lock (ms)",
            tooltip = "Keeps lock briefly across dialogue/store/companion handoffs to prevent flash-level camera pops.",
            min = 0,
            max = 2000,
            step = 50,
            getFunc = function() return self.sv.interactionChainLockMs end,
            setFunc = function(value) self.sv.interactionChainLockMs = value end,
            default = self.defaults.interactionChainLockMs,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Play /idle when opening scene",
            tooltip = "Optional fallback animation while inventory/character scene is open.",
            getFunc = function() return self.sv.playIdleWhenOpen end,
            setFunc = function(value) self.sv.playIdleWhenOpen = value end,
            default = self.defaults.playIdleWhenOpen,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug Logging",
            getFunc = function() return self.sv.debug end,
            setFunc = function(value) self.sv.debug = value end,
            default = self.defaults.debug,
            width = "full",
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "Panel", optionsData)
end

function CameraAlter:OnSceneStateChanged(scene, _, newState)
    if not scene or type(scene.GetName) ~= "function" then
        return
    end

    local sceneName = scene:GetName()
    if not SceneMatches(sceneName) then
        return
    end

    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
        self:CancelPendingDisable()
        self:EnableBlock(sceneName)
    elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
        if self.state.blocking and self.state.activeScene == sceneName then
            local nowMs = GetNowMs()
            self.state.interactionGraceUntilMs = nowMs + (self.sv.interactionGraceMs or 0)
            self:PersistLog(string.format("Scene hide grace: %s (%dms)", tostring(sceneName), self.sv.interactionGraceMs or 0), true)
        end

        if not ShouldBlockCurrentInteractionType() then
            self:RequestDisable("scene hidden: " .. tostring(sceneName), self.sv.interactionGraceMs or 0)
        end
    end
end

function CameraAlter:RegisterCommands()
    SLASH_COMMANDS["/cameraalter"] = function(argument)
        local arg = zo_strlower(argument or "")

        if arg == "on" then
            self.sv.enabled = true
            d("[CameraAlter] Enabled")
            return
        end

        if arg == "off" then
            self.sv.enabled = false
            self:DisableBlock()
            d("[CameraAlter] Disabled")
            return
        end

        if arg == "debug" then
            self.sv.debug = not self.sv.debug
            d(string.format("[CameraAlter] Debug: %s", tostring(self.sv.debug)))
            return
        end

        if arg == "probe" then
            local probes = {
                "ZO_SetPlayerSceneFramingEnabled",
                "ZO_EnablePlayerSceneFraming",
                "SetPlayerSceneFramingEnabled",
                "SetGameCameraUIMode",
                "SetPlayerCameraHeading",
                "SetPlayerCameraPitch",
            }

            d("[CameraAlter] Probe start")
            self:PersistLog("Probe start", true)
            for _, name in ipairs(probes) do
                local line = string.format("%s: %s", name, tostring(IsFn(name)))
                d(string.format("[CameraAlter] %s", line))
                self:PersistLog("Probe " .. line, true)
            end

            if SCENE_MANAGER and type(SCENE_MANAGER.GetCurrentScene) == "function" then
                local currentScene = SCENE_MANAGER:GetCurrentScene()
                if currentScene and type(currentScene.GetName) == "function" then
                    local sceneLine = string.format("Current scene: %s", tostring(currentScene:GetName()))
                    d(string.format("[CameraAlter] %s", sceneLine))
                    self:PersistLog("Probe " .. sceneLine, true)
                end
            end

            d("[CameraAlter] Probe end")
            self:PersistLog("Probe end", true)
            d("[CameraAlter] Probe saved to SavedVariables logBuffer")
            return
        end

        if arg == "clearlog" then
            self.sv.logBuffer = {}
            d("[CameraAlter] Persistent log cleared")
            return
        end

        d("[CameraAlter] Commands: /cameraalter on | off | debug | probe | clearlog")
    end
end

function CameraAlter:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide("CameraAlterSavedVariables", 1, nil, self.defaults)
    self.sv.logBuffer = self.sv.logBuffer or {}

    self:InstallBestEffortHooks()
    self:InstallReinforcementPostHooks()
    self:InstallSceneManagerHooks()
    self:InstallInteractionEventHooks()
    self:InitializeSettings()
    self:RegisterCommands()

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(...)
        self:OnSceneStateChanged(...)
    end)

    DebugLog("Initialized")
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    CameraAlter:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
