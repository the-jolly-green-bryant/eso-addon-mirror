-- Purely cosmetic personality, local walking and an independent 25 Hz flame.
SXUI_BeaconPet={}
local B=SXUI_BeaconPet
local NAME,UPDATE,FLAME="SXUIBeaconPet","SXUIBeaconPetAnimation","SXUIBeaconPetFlame"
local R=SXUI_BeaconRenderer

function B:Tick()
    if not self.settings.enabled or R.root:IsControlHidden() then self:StopUpdates(); return end
    local now=GetGameTimeMilliseconds()
    local dt=math.max(0,now-(self.lastTime or now))/1000
    self.lastTime=now
    local pose=self.animation:Update(dt,true)
    local walking=self.settings.walking and self.settings.locked and not SXUI_BeaconMoveMode.active
    self.walk:Update(dt,walking,self.animation.machine.state=="IDLE")
    R:Draw(self.walk:Pose(pose,true))
end

function B:TickFlame()
    if not self.settings.enabled or R.root:IsControlHidden() then self:StopUpdates(); return end
    local now=GetGameTimeMilliseconds()
    local dt=math.max(0,now-(self.lastFlameTime or now))/1000
    self.lastFlameTime=now
    SXUI_FlameTint:Update(dt)
    R:DrawFlame(self.animation:UpdateFlame(dt,true))
end

function B:StopVisualAnimations()
    EVENT_MANAGER:UnregisterForUpdate(UPDATE)
    EVENT_MANAGER:UnregisterForUpdate(FLAME)
    self.bodyRunning,self.flameRunning=false,false
    self.lastTime,self.lastFlameTime=nil,nil
end

function B:StartVisualAnimations()
    if not self.settings or not self.settings.enabled or not self.animation
        or not R.root or R.root:IsControlHidden() then self:StopVisualAnimations();return end
    local now=GetGameTimeMilliseconds()
    if not self.flameRunning then
        self.lastFlameTime=now
        EVENT_MANAGER:RegisterForUpdate(FLAME,40,function() self:TickFlame() end)
        self.flameRunning=true
    end
    if self.settings.demoAnimations then
        if not self.bodyRunning then
            self.lastTime=now
            EVENT_MANAGER:RegisterForUpdate(UPDATE,50,function() self:Tick() end)
            self.bodyRunning=true
        end
    elseif self.bodyRunning then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE)
        self.bodyRunning=false;self.lastTime=nil
    end
end

function B:StopUpdates()
    self:StopVisualAnimations()
    SXUI_OrbDataPulse:Suspend()
    self.updatesRunning=false
end

function B:ResumeUpdates()
    if not self.settings or not self.settings.enabled or not self.animation
        or not R.root or R.root:IsControlHidden() then self:StopUpdates();return end
    if not self.updatesRunning then
        self.updatesRunning=true
    end
    SXUI_OrbDataPulse:Resume()
    self:StartVisualAnimations()
end

function B:Stop()
    self:StopUpdates()
    if R.root then R.root:SetHidden(true) end
end

function B:Start()
    self:Stop()
    if not self.settings.enabled then return end
    self.animation=self.animation or SXUI_AnimationController:New(GetGameTimeMilliseconds()+17)
    self.walk=self.walk or SXUI_PetWalking:New(GetGameTimeMilliseconds()+9187)
    R:Place(self.settings)
    self.walk:Update(0,self.settings.walking and self.settings.demoAnimations and self.settings.locked and not SXUI_BeaconMoveMode.active,false)
    R:Draw(self.walk:Pose(self.animation:Update(0,self.settings.demoAnimations),self.settings.demoAnimations))
    R:DrawFlame(self.animation:UpdateFlame(0,true))
    SXUI_OrbDataPulse:Initialize(self,self.settings)
    SXUI_BeaconVisibility:Refresh()
    self:ResumeUpdates()
end

function B:Command(text) SXUI_BeaconSettings:Command(self,text) end

EVENT_MANAGER:RegisterForEvent(NAME,EVENT_ADD_ON_LOADED,function(_,addonName)
    if addonName~=NAME then return end
    EVENT_MANAGER:UnregisterForEvent(NAME,EVENT_ADD_ON_LOADED)
    B.settings=SXUI_BeaconSettings:Load()
    SXUI_BeaconVisibility:Initialize(B)
    SXUI_BeaconLAM:Register(B)
    SLASH_COMMANDS["/beacon"]=function(text) B:Command(text) end
    B:Start()
end)
