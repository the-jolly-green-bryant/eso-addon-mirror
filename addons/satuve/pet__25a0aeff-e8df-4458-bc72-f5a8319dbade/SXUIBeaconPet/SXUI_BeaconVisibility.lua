-- Event-driven HUD visibility. Unknown scenes are blocking by default.
SXUI_BeaconVisibility={inWorld=true}
local V=SXUI_BeaconVisibility
local R=SXUI_BeaconRenderer

function V:AllowedScene(scene)
    if not scene then return false end
    local name=scene:GetName()
    if name=="hud" or name=="hudui" then return true end
    local move=SXUI_BeaconMoveMode
    return scene==move.scene and move.active and move.moving
end

function V:ShouldShow()
    if not self.beacon or not self.beacon.settings.enabled or not self.inWorld then return false end
    local scene=SCENE_MANAGER:GetCurrentScene()
    if not self:AllowedScene(scene) then return false end
    local state=scene:GetState()
    if state~=SCENE_SHOWING and state~=SCENE_SHOWN then return false end
    local nextScene=SCENE_MANAGER:GetNextScene()
    if nextScene and nextScene~=scene and not self:AllowedScene(nextScene) then return false end
    return true
end

function V:Refresh()
    if not R.root then return end
    local visible=self:ShouldShow()
    R.root:SetHidden(not visible)
    -- Reconcile after SetHidden, in addition to effective visibility handlers.
    -- Starting an already running lifecycle must not reset its clocks or timers.
    if visible then self.beacon:ResumeUpdates() else self.beacon:StopUpdates() end
end

function V:Initialize(beacon)
    self.beacon=beacon
    if self.initialized then return end
    self.initialized=true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged",function() self:Refresh() end)
    EVENT_MANAGER:RegisterForEvent("SXUIBeaconPetVisibility",EVENT_PLAYER_DEACTIVATED,function()
        self.inWorld=false
        self:Refresh()
    end)
    EVENT_MANAGER:RegisterForEvent("SXUIBeaconPetVisibility",EVENT_PLAYER_ACTIVATED,function()
        self.inWorld=true
        self:Refresh()
    end)
end
