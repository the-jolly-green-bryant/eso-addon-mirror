local HARDCORE = HARDCORE

local ID = "NoMap"

local ICON_NO_MAP = "/esoui/art/mainmenu/menubar_map_up.dds"

local Rule = {
    id = ID,
    title = "No Map: cartography is forbidden",
    icon = ICON_NO_MAP,
    defaultEnabled = false
}

Rule.active = false
Rule._registeredScenes = {}
Rule._lastAlertMs = 0

local function IsHardcoreActive()
    return HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
end

local function IsWayshrineFastTravelInteraction()
    return GetInteractionType() == INTERACTION_FAST_TRAVEL
end

local function AnnounceBlocked()
    local now = GetFrameTimeMilliseconds()
    if now - Rule._lastAlertMs > 1200 then
        Rule._lastAlertMs = now
        HARDCORE.ShowAlertNoSuppression(UI_ALERT_CATEGORY_ALERT, SOUNDS.NEGATIVE_CLICK,
            "HARDCORE: The map is forbidden.")
    end
end

local function ShouldBlockMap()
    return Rule.active and IsHardcoreActive() and not IsWayshrineFastTravelInteraction()
end

local function HideWorldMap()
    if not ShouldBlockMap() then
        return
    end

    if ZO_WorldMap_HideWorldMap then
        ZO_WorldMap_HideWorldMap()
    elseif SCENE_MANAGER then
        if SCENE_MANAGER:IsShowing("worldMap") then
            SCENE_MANAGER:Hide("worldMap")
        elseif SCENE_MANAGER:IsShowing("gamepad_worldMap") then
            SCENE_MANAGER:Hide("gamepad_worldMap")
        end
    end

    AnnounceBlocked()
end

local function OnMapSceneStateChanged(_oldState, newState)
    if newState == SCENE_SHOWING and ShouldBlockMap() then
        zo_callLater(HideWorldMap, 0)
    end
end

local function RegisterMapScene(sceneName)
    local scene = SCENE_MANAGER and SCENE_MANAGER:GetScene(sceneName)
    if not scene then
        return
    end

    scene:UnregisterCallback("StateChange", OnMapSceneStateChanged)
    scene:RegisterCallback("StateChange", OnMapSceneStateChanged)
    Rule._registeredScenes[sceneName] = scene
end

local function RegisterSceneCallbacks()
    RegisterMapScene("worldMap")
    RegisterMapScene("gamepad_worldMap")
end

local function UnregisterSceneCallbacks()
    for sceneName, scene in pairs(Rule._registeredScenes) do
        if scene then
            scene:UnregisterCallback("StateChange", OnMapSceneStateChanged)
        end
    end
    Rule._registeredScenes = {}
end

function Rule:OnEnable()
    self.active = true
    RegisterSceneCallbacks()
    if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() then
        HideWorldMap()
    end
end

function Rule:OnDisable()
    self.active = false
    UnregisterSceneCallbacks()
end

HARDCORE.RuleManager:RegisterRule(Rule)
