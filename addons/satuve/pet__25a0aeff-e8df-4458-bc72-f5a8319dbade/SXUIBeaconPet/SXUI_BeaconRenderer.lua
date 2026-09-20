-- Approved character/flame with the original four orbs and 28 cosmetic additions.
SXUI_BeaconRenderer = {Width=256,Height=260}
local R=SXUI_BeaconRenderer
local PATH="SXUIBeaconPet/textures/visual/"
local FRAMES="SXUIBeaconPet/textures/refinement/"
R.Locator={x=128,y=194,width=28,height=34}
R.Assets={body=PATH.."body.dds",head=PATH.."head.dds",leftArm=PATH.."arm_left.dds",
    rightArm=PATH.."arm_right.dds",core=PATH.."core.dds",side=PATH.."side.dds",
    smile=PATH.."smile.dds",yawn=PATH.."yawn.dds",flames={},bodies={},eyes={},runes={},runeGlows={},shells={},rings={}}
for i=1,16 do R.Assets.flames[i]=FRAMES..string.format("flame_%02d.dds",i) end
for i=1,4 do R.Assets.bodies[i]=FRAMES.."body_"..i..".dds" end
R.Assets.leftHands={R.Assets.leftArm,FRAMES.."arm_left_mid.dds",FRAMES.."arm_left_open.dds"}
R.Assets.rightHands={R.Assets.rightArm,FRAMES.."arm_right_mid.dds",FRAMES.."arm_right_open.dds"}
R.Assets.mouths={FRAMES.."mouth_small.dds",FRAMES.."mouth_mid.dds",FRAMES.."mouth_full.dds"}
for _,state in ipairs({"open","half","closed"}) do R.Assets.eyes[state]=PATH.."eyes_"..state..".dds" end
for i=1,4 do
    R.Assets.runes[i]=PATH.."rune_"..i..".dds"
    R.Assets.runeGlows[i]=PATH.."rune_glow_"..i..".dds"
    R.Assets.shells[i]=PATH.."orb_"..i..".dds"
    R.Assets.rings[i]=PATH.."orb_ring_"..i..".dds"
end
R.Assets.eyes.quarter=FRAMES.."eyes_quarter.dds"
R.Assets.eyes.narrow=FRAMES.."eyes_narrow.dds"
R.Assets.locator="SXUIBeaconPet/textures/locator/ruby.dds"
R.RuneGlowAlphaOff,R.RuneGlowAlphaOn=.035,.92
R.RuneGlowPulseMin,R.RuneGlowPulseMax=.78,1
R.RuneGlowPulsePeriod=1200
R.RuneGlowTimer="SXUIBeaconPetRuneGlow"

local function Texture(name,path,level,parent)
    local control=WINDOW_MANAGER:CreateControl("SXUIBeaconPet"..name,parent or R.character,CT_TEXTURE)
    control:SetTexture(path)
    control:SetDrawLayer(DL_CONTROLS)
    control:SetDrawLevel(level)
    control:SetMouseEnabled(false)
    return control
end
local function Put(control,x,y,w,h,angle,alpha)
    control:ClearAnchors()
    control:SetAnchor(CENTER,R.visualRoot,TOPLEFT,x,y)
    control:SetDimensions(w,h)
    control:SetTextureRotation(angle or 0,.5,.5)
    control:SetAlpha(alpha or 1)
end
local function Asset(control,path)
    if control.beaconPath~=path then control:SetTexture(path); control.beaconPath=path end
end

function R:Create()
    if self.root then return end
    self.root=WINDOW_MANAGER:CreateTopLevelWindow("SXUIBeaconPetRoot")
    self.root:SetDimensions(self.Width,self.Height)
    self.root:SetAutoRectClipChildren(false)
    self.root:SetDrawTier(DT_HIGH)
    self.root:SetClampedToScreen(true)
    self.root:SetHidden(true)
    self.root:SetHandler("OnEffectivelyHidden",function()
        if SXUI_BeaconPet then SXUI_BeaconPet:StopUpdates() end
    end)
    self.root:SetHandler("OnEffectivelyShown",function()
        if SXUI_BeaconPet and SXUI_BeaconPet.settings then SXUI_BeaconPet:ResumeUpdates() end
    end)
    self.root:SetHandler("OnMoveStop",function(control)
        SXUI_BeaconSettings:SavePosition(self.settings,control)
        self:Place(self.settings)
    end)
    local function Group(name,parent)
        local c=WINDOW_MANAGER:CreateControl("SXUIBeaconPet"..name,parent,CT_CONTROL)
        c:SetAnchor(TOPLEFT,parent,TOPLEFT,0,0)
        c:SetDimensions(self.Width,self.Height)
        c:SetAutoRectClipChildren(false);c:SetMouseEnabled(false)
        c:SetInheritScale(true);c:SetInheritAlpha(true)
        return c
    end
    self.visualRoot=Group("VisualRoot",self.root)
    self.character=Group("CharacterVisual",self.visualRoot)
    self.flameGroup=Group("FlameVisual",self.visualRoot)
    self.orbGroup=Group("OrbSystem",self.visualRoot)
    self.body=Texture("Body",self.Assets.bodies[1],20)
    self.bodyNext=Texture("BodyNext",self.Assets.bodies[1],20)
    self.leftArm=Texture("LeftArm",self.Assets.leftArm,18)
    self.rightArm=Texture("RightArm",self.Assets.rightArm,18)
    self.flame=Texture("OuterFlame",self.Assets.flames[1],21,self.flameGroup)
    self.sideLeft=Texture("SideLeft",self.Assets.side,23,self.flameGroup)
    self.sideRight=Texture("SideRight",self.Assets.side,23,self.flameGroup)
    self.core=Texture("InnerFlame",self.Assets.core,24,self.flameGroup)
    self.head=Texture("Head",self.Assets.head,25)
    self.eyes=Texture("Eyes",self.Assets.eyes.open,26)
    self.smile=Texture("Smile",self.Assets.smile,27)
    self.yawn=Texture("Yawn",self.Assets.yawn,27)
    self.chest=Texture("Chest",self.Assets.runes[1],26)
    self.locator=Texture("LocatorCrystal",self.Assets.locator,40)
    Put(self.locator,self.Locator.x,self.Locator.y,self.Locator.width,self.Locator.height,0,1)
    self.orbs={}
    for i=1,SXUI_CosmeticOrbs.Count do
        local style=(i-1)%4+1
        self.orbs[i]={shell=Texture("Orb"..i,self.Assets.shells[style],10,self.orbGroup),
            rune=Texture("OrbRune"..i,self.Assets.runes[style],11,self.orbGroup),
            runeGlow=Texture("OrbRuneGlow"..i,self.Assets.runeGlows[style],12,self.orbGroup),
            ring=Texture("OrbRing"..i,self.Assets.rings[style],13,self.orbGroup)}
        self.orbs[i].runeGlow:SetColor(.46,.78,1,1)
        self.orbs[i].runeGlow:SetHidden(true)
        self.orbs[i].glowAlpha=self.RuneGlowAlphaOff
        self.orbs[i].dataBit=0
        if i>4 then
            local tint=SXUI_CosmeticOrbs.Tints[math.floor((i-5)/4)%4+1]
            self.orbs[i].shell:SetColor(tint[1],tint[2],tint[3],1)
            self.orbs[i].rune:SetColor(tint[1],tint[2],tint[3],1)
            self.orbs[i].ring:SetColor(tint[1],tint[2],tint[3],1)
        end
    end
end

function R:MoveVisual(x)
    if self.visualX==x then return end
    self.visualX=x
    self.visualRoot:ClearAnchors()
    self.visualRoot:SetAnchor(TOPLEFT,self.root,TOPLEFT,x,0)
end

function R:Place(settings,x,y)
    self:Create()
    self.settings=settings
    self.root:SetScale(settings.scale)
    self.root:ClearAnchors()
    self.root:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,x or settings.x,y or settings.y)
    local movable=settings.enabled and not settings.locked and not SXUI_BeaconMoveMode.active
    self.root:SetMouseEnabled(movable)
    self.root:SetMovable(movable)
    local walk=SXUI_BeaconPet and SXUI_BeaconPet.walk
    if walk then
        walk:Configure(x or settings.x,settings.scale,GuiRoot:GetWidth(),settings.walkFrequency)
        self:MoveVisual(walk.x)
    end
end

function R:Draw(p)
    self:Create()
    self:MoveVisual(p.walkX or 0)
    local bob,stretch=p.bob,p.stretch
    local hx,hy=128+p.headX,136+bob+p.headY
    Asset(self.body,self.Assets.bodies[p.body])
    Asset(self.bodyNext,self.Assets.bodies[p.bodyNext])
    Put(self.body,128,192+bob-stretch*2,86/p.breath,92*(p.breath+stretch*.055))
    Put(self.bodyNext,128,192+bob-stretch*2,86/p.breath,92*(p.breath+stretch*.055),0,p.bodyMix)
    Asset(self.leftArm,self.Assets.leftHands[p.leftHand])
    Asset(self.rightArm,self.Assets.rightHands[p.rightHand])
    local swing=p.walkSwing or 0
    Put(self.leftArm,86,181+bob-p.armLift,59.2,78.5,p.leftArm+swing)
    Put(self.rightArm,170,181+bob-p.armLift,59.2,78.5,p.rightArm-swing)
    local faceX=hx+(p.faceOffset or 0)
    local faceWidth=p.faceWidth or 1
    for _,control in ipairs({self.head,self.eyes,self.smile,self.yawn}) do
        local left=p.facing and p.facing<0
        control:SetTextureCoords(left and 1 or 0,left and 0 or 1,0,1)
    end
    Put(self.head,faceX,hy,114*faceWidth,83,p.headAngle)
    Asset(self.eyes,self.Assets.eyes[p.eyes])
    Put(self.eyes,faceX+p.headX*.25+(p.faceOffset or 0),hy-1,66*faceWidth,26,p.headAngle)
    Put(self.smile,faceX,hy+20,24*faceWidth,13,p.headAngle,1-p.mouth)
    Asset(self.yawn,self.Assets.mouths[p.mouthFrame])
    Put(self.yawn,faceX,hy+21,19*faceWidth,3+p.mouth*24,p.headAngle,p.mouth)
    Asset(self.chest,self.Assets.runes[p.chest])
    Put(self.chest,128,194+bob-stretch*2,21,26,0,.55)
    for i=1,SXUI_CosmeticOrbs.Count do
        local orb,controls=p.orbs[i],self.orbs[i]
        local level=orb.front and 35 or 10
        controls.shell:SetDrawLevel(level)
        controls.rune:SetDrawLevel(level+1)
        controls.runeGlow:SetDrawLevel(level+2)
        controls.ring:SetDrawLevel(level+3)
        Put(controls.shell,orb.x,orb.y,orb.size,orb.size,0,orb.opacity)
        Put(controls.rune,orb.x,orb.y,orb.size*.56,orb.size*.66,0,orb.alpha*orb.opacity)
        -- Data energy keeps a readable floor even while the decorative Orb softly fades.
        controls.glowBaseAlpha=math.max(.72,orb.alpha*orb.opacity)
        local pulse=controls.dataBit==1 and self:RuneGlowPulse(GetGameTimeMilliseconds()) or 1
        Put(controls.runeGlow,orb.x,orb.y,orb.size*.64,orb.size*.74,0,
            controls.glowAlpha*pulse*controls.glowBaseAlpha)
        Put(controls.ring,orb.x,orb.y,orb.size,orb.size,0,orb.opacity)
        Asset(controls.rune,self.Assets.runes[orb.rune])
        Asset(controls.runeGlow,self.Assets.runeGlows[orb.rune])
    end
end

function R:RuneGlowPulse(now)
    local phase=(now%self.RuneGlowPulsePeriod)/self.RuneGlowPulsePeriod
    local wave=.5-.5*math.cos(phase*math.pi*2)
    return self.RuneGlowPulseMin+(self.RuneGlowPulseMax-self.RuneGlowPulseMin)*wave
end

function R:UpdateRuneGlows()
    local now=GetGameTimeMilliseconds()
    local active=false
    for _,controls in ipairs(self.orbs or {}) do
        if not controls.runeGlow:IsControlHidden() then
            if controls.glowEnd then
                local t=math.max(0,math.min(1,(now-controls.glowStart)/(controls.glowEnd-controls.glowStart)))
                t=t*t*(3-2*t)
                controls.glowAlpha=controls.glowFrom+(controls.glowTo-controls.glowFrom)*t
                if t>=1 then controls.glowEnd=nil end
            end
            local pulse=controls.dataBit==1 and self:RuneGlowPulse(now) or 1
            controls.runeGlow:SetAlpha(controls.glowAlpha*pulse*(controls.glowBaseAlpha or 1))
            active=active or controls.glowEnd~=nil or controls.dataBit==1
        end
    end
    if not active then
        EVENT_MANAGER:UnregisterForUpdate(self.RuneGlowTimer)
        self.runeGlowRunning=false
    end
end

function R:ResumeRuneGlowAnimation()
    if self.runeGlowRunning or not self.root or self.root:IsControlHidden() then return end
    local active=false
    for _,controls in ipairs(self.orbs or {}) do
        active=active or (not controls.runeGlow:IsControlHidden()
            and (controls.glowEnd~=nil or controls.dataBit==1))
    end
    if not active then return end
    EVENT_MANAGER:RegisterForUpdate(self.RuneGlowTimer,20,function() self:UpdateRuneGlows() end)
    self.runeGlowRunning=true
end

function R:SuspendRuneGlowAnimation()
    EVENT_MANAGER:UnregisterForUpdate(self.RuneGlowTimer)
    self.runeGlowRunning=false
end

function R:SetOrbRuneBit(index,value,visible,duration)
    local controls=self.orbs and self.orbs[index]
    if not controls then return false end
    controls.dataBit=value==1 and 1 or 0
    if not visible then
        controls.runeGlow:SetHidden(true)
        controls.glowEnd=nil
        return true
    end
    controls.runeGlow:SetHidden(false)
    local target=controls.dataBit==1 and self.RuneGlowAlphaOn or self.RuneGlowAlphaOff
    duration=tonumber(duration) or 0
    if duration>0 and controls.glowAlpha~=target then
        local now=GetGameTimeMilliseconds()
        controls.glowFrom=controls.glowAlpha
        controls.glowTo=target
        controls.glowStart=now
        controls.glowEnd=now+duration
    else
        controls.glowAlpha=target
        controls.glowEnd=nil
    end
    local pulse=controls.dataBit==1 and self:RuneGlowPulse(GetGameTimeMilliseconds()) or 1
    controls.runeGlow:SetAlpha(controls.glowAlpha*pulse*(controls.glowBaseAlpha or 1))
    self:ResumeRuneGlowAnimation()
    return true
end

function R:HideOrbRuneGlows()
    self:SuspendRuneGlowAnimation()
    for _,controls in ipairs(self.orbs or {}) do
        controls.dataBit=0
        controls.glowAlpha=self.RuneGlowAlphaOff
        controls.glowEnd=nil
        controls.runeGlow:SetHidden(true)
    end
end

function R:DrawFlame(p)
    if not self.root then return end
    local hx=128+p.headX
    local bob=p.bob+p.headY
    local width,height=134*p.flameWidth,134*p.flameHeight
    -- Keep the base of the crown attached while its tips stretch and sway.
    local x=hx+p.flameSway
    local y=137+bob-p.flameLift-height*.5
    local angle=p.headAngle+p.flameAngle
    -- The visual controller owns this frame; data state must not replace it.
    Asset(self.flame,self.Assets.flames[p.flame])
    Put(self.flame,x,y,width,height,angle,1)
    Put(self.sideLeft,hx-42,91+bob,24,52,p.sideAngle)
    Put(self.sideRight,hx+43,91+bob,24,52,-p.sideAngle)
    Put(self.core,hx,98+bob-p.flameLift*.5+p.coreLift,34,48,p.coreAngle,.8)
    for _,control in ipairs({self.flame,self.sideLeft,self.sideRight,self.core}) do SXUI_FlameTint:Apply(control) end
end
