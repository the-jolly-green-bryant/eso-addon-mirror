BetterBars = BetterBars or {}
local T = BetterBars

T.name = "BetterBars"
T.displayName = "Better Bars"
T.version = "0.0.01"
T.savedVariableVersion = 1

local defaults = {
    resourceBars = {
        enabled = false,
        valueDisplay = "PERCENT",
        health = { enabled=true, layout="CRESCENT", scale=1.0, opacity=0.92, offsetX=-240, offsetY=-20, length=350, thickness=34, crescentDepth=3, crescentSide="RIGHT", dynamicMaxSize=true },
        magicka = { enabled=true, layout="CRESCENT", scale=1.0, opacity=0.92, offsetX=-155, offsetY=-20, length=350, thickness=32, crescentDepth=3, crescentSide="RIGHT", dynamicMaxSize=true },
        stamina = { enabled=true, layout="CRESCENT", scale=1.0, opacity=0.92, offsetX=155, offsetY=-20, length=350, thickness=32, crescentDepth=3, crescentSide="LEFT", dynamicMaxSize=true },
        shield = { enabled=true, layout="CRESCENT", scale=1.0, opacity=0.92, offsetX=240, offsetY=-20, length=350, thickness=30, crescentDepth=3, crescentSide="LEFT", hideWhenEmpty=true, dynamicMaxSize=true },
    },
}

function T:IsGameplayHUDSceneActive()
    if not SCENE_MANAGER then return true end
    local currentScene = SCENE_MANAGER:GetCurrentScene()
    return currentScene == HUD_SCENE or currentScene == HUD_UI_SCENE
end

function T:RegisterSceneVisibilityGuard()
    if self.sceneVisibilityGuardRegistered or not SCENE_MANAGER then return end
    self.sceneVisibilityGuardRegistered = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
        if T.ResourceBars and T.ResourceBars.RefreshVisibilityAll then T.ResourceBars:RefreshVisibilityAll() end
    end)
end

function T:Initialize()
    self.saved = ZO_SavedVars:NewCharacterIdSettings("BetterBarsSavedVariables", self.savedVariableVersion, nil, defaults)
    self:RegisterSceneVisibilityGuard()
    if self.ResourceBars and self.ResourceBars.Initialize then self.ResourceBars:Initialize() end
    if self.Settings and self.Settings.Initialize then self.Settings:Initialize() end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= T.name then return end
    EVENT_MANAGER:UnregisterForEvent(T.name, EVENT_ADD_ON_LOADED)
    T:Initialize()
end

EVENT_MANAGER:RegisterForEvent(T.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
