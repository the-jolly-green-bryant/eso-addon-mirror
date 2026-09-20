-- Optional LibAddonMenu integration; standalone controls remain available without LAM.
SXUI_BeaconLAM={}
local L=SXUI_BeaconLAM
local S,R,M=SXUI_BeaconSettings,SXUI_BeaconRenderer,SXUI_BeaconMoveMode

function L:Register(beacon)
    local lam=LibAddonMenu2
    if self.registered or not lam then return false end
    local s=beacon.settings
    local function Change(field,value,restart)
        M:Close(false)
        s[field]=value
        S:Clamp(s)
        if restart then beacon:Start() else R:Place(s) end
    end
    self.panel=lam:RegisterAddonPanel("SXUIBeaconPetLAMPanel",{
        type="panel",name="SXUI Beacon Pet",displayName="SXUI Beacon Pet",
        author="Satuve",version="0.7.5",registerForRefresh=true,registerForDefaults=true,
    })
    self.options={
        {type="header",name="Beacon Pet"},
        {type="checkbox",name="Enable Beacon Pet",default=true,
            getFunc=function() return s.enabled end,
            setFunc=function(value) Change("enabled",value,true) end},
        {type="slider",name="Pet Scale",min=S.MinScale,max=S.MaxScale,step=.05,decimals=2,
            default=S.DefaultScale,width="full",
            tooltip="Resize the whole pet, its orbs and drag area. Recommended: 0.95. Smaller legacy sizes remain available.",
            getFunc=function() return s.scale end,
            setFunc=function(value) Change("scale",value,false) end},
        {type="button",name="Use Recommended Size",width="full",
            tooltip="Set scale to 0.95 without resetting your saved position.",
            func=function() Change("scale",S.DefaultScale,false) end},
        {type="checkbox",name="Lock Position",default=true,
            getFunc=function() return s.locked end,
            setFunc=function(value) Change("locked",value,false) end},
        {type="button",name="Move Pet",width="half",
            disabled=function() return not s.enabled end,
            func=function() M:Show(beacon,true) end},
        {type="button",name="Reset Position",width="half",
            func=function() M:Close(false);S:Reset(s) end},
        {type="checkbox",name="Demo Animations",default=true,
            getFunc=function() return s.demoAnimations end,
            setFunc=function(value) Change("demoAnimations",value,true) end},
        {type="checkbox",name="Pet Walking",default=true,
            tooltip="Occasional short walks around the saved base. Pauses while moving or unlocked, and while Demo Animations is off.",
            getFunc=function() return s.walking end,
            setFunc=function(value) Change("walking",value,false) end},
        {type="dropdown",name="Walk Frequency",choices={"Low","Normal","High"},default="Normal",
            getFunc=function() return s.walkFrequency end,
            setFunc=function(value) Change("walkFrequency",value,false) end},
        {type="header",name="Orb Data Test"},
        {type="dropdown",name="Orb Data Test",choices={"Off","Alternate","Wave","Random","Counter"},default="Off",
            tooltip="Addon-side blue rune-star patterns only. No gameplay payload or Companion connection.",
            getFunc=function() return s.orbDataTest end,
            setFunc=function(value)
                s.orbDataTest=value
                SXUI_OrbDataPulse:SetMode(value=="Off" and "stop" or value:lower())
            end},
        {type="slider",name="Orb Data Interval (ms)",min=20,max=500,step=10,decimals=0,
            default=250,width="full",
            tooltip="How long one logical 32-bit test state remains active.",
            getFunc=function() return s.orbDataInterval end,
            setFunc=function(value) SXUI_OrbDataPulse:SetInterval(value) end},
    }
    lam:RegisterOptionControls("SXUIBeaconPetLAMPanel",self.options)
    self.registered=true
    return true
end
