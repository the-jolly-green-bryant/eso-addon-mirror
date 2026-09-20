-- Cosmetic local motion only. Never reads gameplay data or writes SavedVariables.
SXUI_PetWalking={Radius=80,TurnDuration=.20,FrameDuration=.09}
local W=SXUI_PetWalking
W.__index=W
local function Clamp(v,lo,hi) return math.max(lo,math.min(hi,v)) end
local function Smooth(v) v=Clamp(v,0,1);return v*v*(3-2*v) end

function W:Random(lo,hi)
    self.seed=(self.seed*16807)%2147483647
    return lo+(hi-lo)*self.seed/2147483647
end

function W:New(seed)
    local w=setmetatable({seed=math.max(1,(seed or 9187)%2147483647),x=0,facing=1,
        elapsed=0,time=0,minX=-self.Radius,maxX=self.Radius},self)
    w:Idle()
    return w
end

function W:Idle()
    self.state=self.facing<0 and "IDLE_LEFT" or "IDLE_RIGHT"
    self.elapsed=0;self.target=nil;self.wait=self:Random(3,12)
end

function W:Configure(baseX,scale,screenWidth,frequency)
    self.minX=math.max(-self.Radius,-baseX/scale)
    self.maxX=math.min(self.Radius,(screenWidth-baseX)/scale-256)
    -- Even an unusually narrow viewport must have a stable, finite interval.
    self.minX=math.min(0,self.minX);self.maxX=math.max(0,self.maxX)
    local x=Clamp(self.x,self.minX,self.maxX)
    if x~=self.x or (self.target and (self.target<self.minX or self.target>self.maxX)) then
        self.x=x;self:Idle()
    end
    self.chance=frequency=="Low" and .18 or frequency=="High" and .55 or .35
end

function W:BeginWalk(target)
    target=Clamp(target,self.minX,self.maxX)
    if math.abs(target-self.x)<8 then return false end
    self.target=target
    local direction=target<self.x and -1 or 1
    if direction~=self.facing then
        self.turnFrom=self.facing;self.turnTo=direction
        self.state=direction<0 and "TURN_LEFT" or "TURN_RIGHT"
        self.elapsed=0
    else self:Travel() end
    return true
end

function W:Travel()
    self.startX=self.x;self.elapsed=0
    self.duration=math.abs(self.target-self.x)/self:Random(18,26)
    self.state=self.facing<0 and "WALK_LEFT" or "WALK_RIGHT"
end

function W:Update(dt,enabled,personalityIdle)
    self.paused=not enabled
    if not enabled then return end
    dt=Clamp(dt or 0,0,.1)
    self.time=self.time+dt;self.elapsed=self.elapsed+dt
    if self.state=="TURN_LEFT" or self.state=="TURN_RIGHT" then
        if self.elapsed>=self.TurnDuration then
            self.facing=self.turnTo
            if self.target then self:Travel() else self:Idle() end
        end
    elseif self.state=="WALK_LEFT" or self.state=="WALK_RIGHT" then
        local t=Clamp(self.elapsed/self.duration,0,1)
        self.x=Clamp(self.startX+(self.target-self.startX)*Smooth(t),self.minX,self.maxX)
        if t>=1 then self:Idle() end
    elseif self.elapsed>=self.wait and personalityIdle then
        self.elapsed=0;self.wait=self:Random(3,12)
        if self:Random(0,1)<self.chance then
            local left,right=self.x-self.minX,self.maxX-self.x
            local direction=left<12 and 1 or right<12 and -1 or (self:Random(0,1)<.5 and -1 or 1)
            local space=direction<0 and left or right
            if space>=12 then self:BeginWalk(self.x+direction*self:Random(math.min(24,space),math.min(85,space))) end
        elseif self:Random(0,1)<.10 then
            self.turnFrom=self.facing;self.turnTo=-self.facing;self.elapsed=0
            self.state=self.turnTo<0 and "TURN_LEFT" or "TURN_RIGHT"
        end
    end
end

function W:Pose(p,animated)
    p.walkX=self.x;p.walkState=self.state;p.facing=self.facing
    p.faceWidth,p.faceOffset,p.walkSwing=1,self.facing*3,0
    if self.state=="TURN_LEFT" or self.state=="TURN_RIGHT" then
        local t=Clamp(self.elapsed/self.TurnDuration,0,1)
        p.faceWidth=1-.20*math.sin(math.pi*t)
        p.faceOffset=3*(self.turnFrom+(self.turnTo-self.turnFrom)*Smooth(t))
        p.facing=t<.5 and self.turnFrom or self.turnTo
    elseif animated and not self.paused and (self.state=="WALK_LEFT" or self.state=="WALK_RIGHT") then
        local t=Clamp(self.elapsed/self.duration,0,1)
        local edge=math.sin(math.pi*t)
        local phase=self.elapsed/self.FrameDuration/8*math.pi*2
        local step=math.sin(phase)
        local lift=math.abs(step)
        p.walkSwing=step*.22*edge
        p.bob=p.bob-2.2*lift*edge
        p.stretch=p.stretch+.12*lift*edge
        p.headY=p.headY-.8*lift*edge
        p.headAngle=p.headAngle-self.facing*.022*step*edge
        p.faceWidth=.94
        p.faceOffset=self.facing*5
        p.state=self.facing<0 and "WALK_LEFT" or "WALK_RIGHT"
        p.clipFrame=math.floor(self.elapsed/self.FrameDuration)%8+1
    end
    return p
end
