-- Pure pose generation; original four orbs plus cosmetic aura extensions.
SXUI_AnimationController = {}
local A = SXUI_AnimationController
A.__index = A
local sin,cos,pi,floor = math.sin,math.cos,math.pi,math.floor
local function Clamp(x) return math.max(0,math.min(1,x)) end
local function Smooth(x) x=Clamp(x); return x*x*(3-2*x) end
local function Envelope(t,a,b,c,d) return Smooth((t-a)/(b-a))*(1-Smooth((t-c)/(d-c))) end
local flameSequence = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2}
-- Small elliptical paths in the free side margins; no path crosses the figure.
local orbCenters={{26,82},{230,82},{26,207},{230,207}}
A.Clips={
    IDLE_DEFAULT={frames=8,frameMs=250,loop=true},
    IDLE_BLINK={frames=8,duration=.28},
    IDLE_LOOK={frames=8,duration=2.6},
    IDLE_HAPPY={frames=8,duration=2.4},
    IDLE_SLEEPY={frames=8,duration=4.2},
    WAVE={frames=8,duration=2.4},
    HAPPY_BOUNCE={frames=8,duration=1.9},
    WALK_LEFT={frames=8,frameMs=90,loop=true},
    WALK_RIGHT={frames=8,frameMs=90,loop=true},
}

function A:New(seed)
    local controller = setmetatable({machine=SXUI_PetStateMachine:New(seed),time=0,flameTime=0,
        pose={orbs={}},orbClocks={},orbPeriods={}},self)
    for i=1,4 do
        controller.pose.orbs[i]={rune=i,alpha=1}
        controller.orbClocks[i]=i*1.73
        controller.orbPeriods[i]=7.5+i*.83
    end
    SXUI_CosmeticOrbs:Initialize(controller)
    controller:Update(0,false)
    controller:UpdateFlame(0,false)
    return controller
end

-- Internal cosmetic pose setters. No gameplay or transport inputs.
function A:SetOrbRune(index,state)
    if not self.pose.orbs[index] or type(state)~="number" or state%1~=0 or state<1 or state>4 then return false end
    self.pose.orbs[index].rune=state
    return true
end
function A:SetFlameState(state)
    if type(state)~="number" or state%1~=0 or state<1 or state>16 then return false end
    self.pose.flame=state
    return true
end
function A:SetEyeState(state)
    if state~="open" and state~="quarter" and state~="half" and state~="narrow" and state~="closed" then return false end
    self.pose.eyes=state
    return true
end
function A:SetChestRune(state)
    if type(state)~="number" or state%1~=0 or state<1 or state>4 then return false end
    self.pose.chest=state
    return true
end

local function Blink(t)
    if t<0 or t>.28 then return "open" end
    if t<.035 or t>.245 then return "quarter" end
    if t<.07 or t>.21 then return "half" end
    if t<.10 or t>.18 then return "narrow" end
    return "closed"
end

local function PoseState(state)
    if state=="IDLE" then return "IDLE_DEFAULT" end
    if state=="BLINK" or state=="DOUBLE_BLINK" then return "IDLE_BLINK" end
    if state=="LOOK_LEFT" or state=="LOOK_RIGHT" then return "IDLE_LOOK" end
    if state=="YAWN" then return "IDLE_SLEEPY" end
    if state=="HAND_WAVE" then return "WAVE" end
    return state
end

local function ClipFrame(state,elapsed,time)
    local clip=A.Clips[state]
    if not clip then return 1 end
    if clip.loop then return floor((time*1000)/clip.frameMs)%clip.frames+1 end
    return math.min(clip.frames,floor(Clamp(elapsed/clip.duration)*clip.frames)+1)
end

function A:Update(dt,animated)
    dt=math.max(0,math.min(.1,dt or 0)) -- no catch-up bursts after stalls
    if animated then
        self.time=self.time+dt
        self.machine:Update(dt)
    end
    local t=animated and self.time or 0
    local m,p=self.machine,self.pose
    local state,e=animated and m.state or "IDLE",m.elapsed
    p.state=PoseState(state)
    p.clipFrame=ClipFrame(p.state,e,t)
    p.bob=sin(t*1.65)*1.5
    p.breath=1+sin(t*1.65)*.013
    p.headX,p.headY,p.headAngle=sin(t*.72)*.6,0,sin(t*.63)*.012
    p.leftArm,p.rightArm=sin(t*1.1)*.035,-sin(t*1.1+.5)*.035
    p.armLift,p.stretch,p.mouth,p.flameLift=0,0,0,0
    self:SetEyeState("open")
    if state=="BLINK" then self:SetEyeState(Blink(e))
    elseif state=="DOUBLE_BLINK" then self:SetEyeState(Blink(e<.31 and e or e-.34))
    elseif state=="LOOK_LEFT" or state=="LOOK_RIGHT" then
        local look=Envelope(e,0,.6,1.8,2.6)*(state=="LOOK_LEFT" and -1 or 1)
        p.headX,p.headAngle=look*5,look*.065
    elseif state=="IDLE_HAPPY" then
        local happy=Envelope(e,0,.35,1.75,2.4)
        p.bob=p.bob-2.5*happy+sin(e*5)*.5*happy
        p.headY,p.headAngle=-1.5*happy,sin(e*2.5)*.025*happy
        p.armLift=4*happy
        p.leftArm,p.rightArm=.28*happy,-.28*happy
        if happy>.2 then self:SetEyeState("closed") end
    elseif state=="YAWN" then
        local yawn=Envelope(e,.45,1.35,2.55,4.05)
        p.mouth=yawn
        p.stretch=Envelope(e,0,1.4,2.55,4.2)
        p.headY,p.headAngle=-5*p.stretch,-.055*p.stretch
        p.armLift=13*p.stretch
        p.leftArm,p.rightArm=.55*p.stretch,-.55*p.stretch
        p.flameLift=6*yawn
        if e<.20 or e>4.05 then self:SetEyeState("open")
        elseif e<.55 or e>3.75 then self:SetEyeState("quarter")
        elseif e>1.15 and e<3.15 then self:SetEyeState("closed")
        elseif e>.90 and e<3.45 then self:SetEyeState("narrow")
        else self:SetEyeState("half") end
    elseif state=="HAND_WAVE" then
        local wave=Envelope(e,0,.42,1.85,2.4)
        p.rightArm=-wave*(.95+.22*sin(e*13))
        p.armLift=9*wave
        p.headAngle=-.035*wave
        if wave>.45 and sin(e*6)>-.15 then self:SetEyeState("half") end
    elseif state=="HAPPY_BOUNCE" then
        local joy=Envelope(e,0,.22,1.55,1.9)
        local hop=math.abs(sin(e*pi/1.9*2))*joy
        p.bob=p.bob-8*hop
        p.stretch=.62*hop
        p.headY=-2.5*hop
        p.headAngle=sin(e*5)*.025*joy
        p.armLift=11*joy
        p.leftArm,p.rightArm=.68*joy,-.68*joy
        p.mouth=.72*joy
        if joy>.16 then self:SetEyeState("closed") end
    elseif state=="HAND_FIDGET" then
        local fidget=sin(pi*Clamp(e/1.6))^2
        p.leftArm,p.rightArm=.19*fidget,-.22*fidget
        p.armLift=3*fidget
    end
    -- Four drawn breathing frames supplement the existing small geometric motion.
    local bodyFrame=t*1.65/(2*pi)*4
    p.body=floor(bodyFrame)%4+1
    p.bodyNext=p.body%4+1
    p.bodyMix=Smooth(bodyFrame-floor(bodyFrame))
    p.mouthFrame=p.mouth<.3 and 1 or p.mouth<.7 and 2 or 3
    p.leftHand,p.rightHand=1,1
    if state=="YAWN" then
        p.leftHand=p.armLift>8 and 3 or p.armLift>2 and 2 or 1
        p.rightHand=p.leftHand
    elseif state=="HAND_WAVE" then
        p.rightHand=p.armLift>6 and 3 or p.armLift>2 and 2 or 1
    elseif state=="IDLE_HAPPY" or state=="HAPPY_BOUNCE" then
        p.leftHand=p.armLift>7 and 3 or p.armLift>2 and 2 or 1
        p.rightHand=p.leftHand
    elseif state=="HAND_FIDGET" and p.armLift>1 then
        p.leftHand,p.rightHand=2,2
    end
    self:SetChestRune(1)
    for i=1,4 do
        local orb=p.orbs[i]
        local phase=t*.17+(i-1)*pi/2+.35
        local depth=sin(phase)
        orb.x=orbCenters[i][1]+4*cos(phase)
        orb.y=orbCenters[i][2]+17*depth+sin(t*.7+i)*2.5
        orb.size=35+depth*3
        orb.opacity=.84+.12*depth
        orb.front=depth>0
        if animated then
            self.orbClocks[i]=self.orbClocks[i]+dt
            local period=self.orbPeriods[i]
            if self.orbClocks[i]>=period then
                self.orbClocks[i]=self.orbClocks[i]-period
            end
            local c=self.orbClocks[i]
            local changed=false
            -- A single texture switches only while fully faded; no crossfade pair.
            if c>=period-1 and not orb.switched then
                self:SetOrbRune(i,orb.rune%4+1)
                orb.switched=true
                changed=true
            elseif c<period-2 then orb.switched=false end
            if c>=period-2 and c<period-1 then orb.alpha=1-Smooth(c-(period-2))
            elseif c>=period-1 then orb.alpha=Smooth(c-(period-1))
            else orb.alpha=1 end
            if changed then orb.alpha=0 end
        else orb.alpha=1 end
    end
    SXUI_CosmeticOrbs:Update(self,t)
    return p
end

-- Independent 25 Hz flame pose. Never advances personality, runes or orb clocks.
function A:UpdateFlame(dt,animated)
    if animated then self.flameTime=self.flameTime+math.max(0,math.min(.1,dt or 0)) end
    local t=animated and self.flameTime or 0
    local p=self.pose
    -- Each 40 ms step selects a distinct drawn frame, not an opacity-only inbetween.
    local frame=t/.04
    local index=floor(frame+1e-7)%#flameSequence+1
    self:SetFlameState(flameSequence[index])
    p.flameSway=sin(t*4.1)*1.8
    p.flameWidth=1+sin(t*5.2)*.025
    p.flameHeight=1+sin(t*4.3+.6)*.035
    p.flameAngle=sin(t*3.7)*.025
    p.coreAngle=sin(t*6.2)*.09
    p.sideAngle=sin(t*5.1+.8)*.14
    p.coreLift=sin(t*5.7)*1.5
    return p
end
