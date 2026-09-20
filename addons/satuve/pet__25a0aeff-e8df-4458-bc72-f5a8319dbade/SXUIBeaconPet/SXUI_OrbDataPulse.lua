-- Addon-side 32-bit visual test controller. No gameplay payload is connected.
SXUI_OrbDataPulse={Count=32,MinInterval=20,MaxInterval=500,DefaultInterval=250,
    Timer="SXUIBeaconPetOrbDataPulse",mode="stopped",bits={}}
local P=SXUI_OrbDataPulse

local aliases={
    ["off"]="all0",["on"]="all1",["alt"]="alternate",["alternate"]="alternate",
    ["inverse"]="inverse",["wave"]="wave",["random"]="random",
    ["counter"]="counter",["stop"]="stopped",["stopped"]="stopped",
}

local function ClampInterval(value)
    value=tonumber(value) or P.DefaultInterval
    value=math.max(P.MinInterval,math.min(P.MaxInterval,value))
    return math.floor(value/10+.5)*10
end

function P:Initialize(beacon,settings)
    self.beacon,self.settings=beacon,settings
    self.interval=ClampInterval(settings.orbDataInterval)
    settings.orbDataInterval=self.interval
    if not self.initialized then
        self.initialized=true;self.randomSeed=1357911;self.counter=0;self.wave=1
        for i=1,self.Count do self.bits[i]=0 end
    end
    local saved=settings.orbDataTest
    self:SetMode(saved=="Alternate" and "alternate" or saved=="Wave" and "wave"
        or saved=="Random" and "random" or saved=="Counter" and "counter" or "stopped",false)
end

function P:SetOrbBit(index,value)
    index=tonumber(index)
    if not index or index%1~=0 or index<1 or index>self.Count then return false end
    value=(value==true or tonumber(value)==1) and 1 or 0
    self.bits[index]=value
    if SXUI_BeaconRenderer and SXUI_BeaconRenderer.SetOrbRuneBit then
        SXUI_BeaconRenderer:SetOrbRuneBit(index,value,self.mode~="stopped",self:TransitionDuration())
    end
    return true
end

function P:TransitionDuration()
    if self.interval<=100 then return 0 end
    if self.interval<=250 then return 40 end
    return 80
end

function P:SetBits(values)
    for i=1,self.Count do self:SetOrbBit(i,values[i] or 0) end
end

function P:NextRandom()
    self.randomSeed=(self.randomSeed*16807)%2147483647
    return self.randomSeed
end

function P:Generate()
    local values={}
    if self.mode=="all0" then
        for i=1,self.Count do values[i]=0 end
    elseif self.mode=="all1" then
        for i=1,self.Count do values[i]=1 end
    elseif self.mode=="alternate" or self.mode=="inverse" then
        local first=self.mode=="alternate" and 1 or 0
        for i=1,self.Count do values[i]=(i-1+first)%2 end
    elseif self.mode=="wave" then
        for i=1,self.Count do values[i]=i==self.wave and 1 or 0 end
        self.wave=self.wave%self.Count+1
    elseif self.mode=="random" then
        for i=1,self.Count do values[i]=self:NextRandom()%2 end
    elseif self.mode=="counter" then
        local value=self.counter
        for i=1,self.Count do values[i]=math.floor(value/2^(self.Count-i))%2 end
        self.counter=(self.counter+1)%4294967296
    end
    return values
end

function P:ApplyCurrent()
    if self.mode=="stopped" then
        if SXUI_BeaconRenderer and SXUI_BeaconRenderer.HideOrbRuneGlows then
            SXUI_BeaconRenderer:HideOrbRuneGlows()
        end
        return
    end
    self:SetBits(self:Generate())
end

function P:Suspend()
    EVENT_MANAGER:UnregisterForUpdate(self.Timer)
    if SXUI_BeaconRenderer and SXUI_BeaconRenderer.SuspendRuneGlowAnimation then
        SXUI_BeaconRenderer:SuspendRuneGlowAnimation()
    end
    self.running=false
end

function P:Resume()
    self:Suspend()
    if self.mode=="stopped" or not self.beacon or not self.beacon.settings.enabled
        or not SXUI_BeaconRenderer.root or SXUI_BeaconRenderer.root:IsControlHidden() then return end
    EVENT_MANAGER:RegisterForUpdate(self.Timer,self.interval,function() self:ApplyCurrent() end)
    self.running=true
    if SXUI_BeaconRenderer and SXUI_BeaconRenderer.ResumeRuneGlowAnimation then
        SXUI_BeaconRenderer:ResumeRuneGlowAnimation()
    end
end

function P:SetMode(mode,save)
    mode=aliases[(mode or ""):lower()] or "stopped"
    self:Suspend();self.mode=mode
    if mode=="wave" then self.wave=1 end
    if mode=="counter" then self.counter=0 end
    if save~=false and self.settings then
        local names={alternate="Alternate",wave="Wave",random="Random",counter="Counter"}
        self.settings.orbDataTest=names[mode] or "Off"
    end
    self:ApplyCurrent();self:Resume()
    return mode
end

function P:SetInterval(value)
    self.interval=ClampInterval(value)
    if self.settings then self.settings.orbDataInterval=self.interval end
    self:Resume()
    return self.interval
end
