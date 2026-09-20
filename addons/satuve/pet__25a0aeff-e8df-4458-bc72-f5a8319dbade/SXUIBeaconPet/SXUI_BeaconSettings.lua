-- Private settings and chat commands; no menu-library or BUI dependencies.
SXUI_BeaconSettings = {}
local S = SXUI_BeaconSettings
S.DefaultScale=.95 -- About 41% above .675; existing saved preferences win.
S.MinScale,S.MaxScale=.5,2 -- Keep legacy small sizes selectable in LAM too.

local function Number(value,fallback,minimum,maximum)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then value = fallback end
    return math.max(minimum,math.min(maximum,value))
end

function S:Clamp(settings)
    settings.scale = Number(settings.scale,self.DefaultScale,self.MinScale,self.MaxScale)
    -- Saved position is the original four-Orb pet base, never its walking offset.
    local maxX=math.max(0,GuiRoot:GetWidth()-256*settings.scale)
    local maxY=math.max(0,GuiRoot:GetHeight()-260*settings.scale)
    settings.x = Number(settings.x,24,0,maxX)
    settings.y = Number(settings.y,220,0,maxY)
end

function S:Load()
    -- Keep schema 1 and existing base/scale preferences during the visual rollback.
    local defaults = {enabled=true,demoAnimations=true,x=24,y=220,scale=self.DefaultScale,locked=true,
        walking=true,walkFrequency="Normal",orbDataTest="Off",orbDataInterval=250,appearanceVersion=0}
    local settings = ZO_SavedVars:NewAccountWide("SXUI_BEACON_VARS",1,nil,defaults)
    if settings.locked == nil then settings.locked = true end
    if settings.demoAnimations == nil then settings.demoAnimations = true end
    if type(settings.walking)~="boolean" then settings.walking=true end
    if settings.walkFrequency~="Low" and settings.walkFrequency~="High" then settings.walkFrequency="Normal" end
    if settings.orbDataTest~="Alternate" and settings.orbDataTest~="Wave"
        and settings.orbDataTest~="Random" and settings.orbDataTest~="Counter" then settings.orbDataTest="Off" end
    settings.orbDataInterval=math.floor(Number(settings.orbDataInterval,250,20,500)/10+.5)*10
    settings.appearanceVersion = tonumber(settings.appearanceVersion) or 0
    settings.appearanceVersion = 4
    self:Clamp(settings)
    return settings
end

function S:SavePosition(settings,control)
    if not settings or settings.locked or not settings.enabled or SXUI_BeaconMoveMode.active then return end
    -- Rect coordinates are in GuiRoot UI space; do not divide by the pet's scale.
    settings.x = control:GetLeft()-GuiRoot:GetLeft()
    settings.y = control:GetTop()-GuiRoot:GetTop()
    self:Clamp(settings)
end

local function Say(text)
    if CHAT_SYSTEM then CHAT_SYSTEM:AddMessage("SXUI Beacon Pet: "..text) end
end
S.Say=Say

function S:Reset(settings)
    settings.x,settings.y=24,220
    self:Clamp(settings)
    SXUI_BeaconRenderer:Place(settings)
end

function S:Command(beacon,text)
    local args = {}
    for token in (text or ""):gmatch("%S+") do args[#args+1] = token:lower() end
    local command,settings = args[1],beacon.settings
    if not command or command == "settings" then
        SXUI_BeaconMoveMode:Show(beacon)
        return
    elseif command == "move" then
        SXUI_BeaconMoveMode:Show(beacon,true)
        return
    end
    -- A command during a draft move cancels that draft before changing settings.
    SXUI_BeaconMoveMode:Close(false)
    if command == "on" or command == "off" then
        settings.enabled = command == "on"
        beacon:Start()
    elseif command == "walk" and (args[2]=="on" or args[2]=="off") then
        settings.walking=args[2]=="on"
    elseif command == "walk" and (args[2]=="low" or args[2]=="normal" or args[2]=="high") then
        settings.walkFrequency=args[2]:sub(1,1):upper()..args[2]:sub(2)
        if settings.enabled then SXUI_BeaconRenderer:Place(settings) end
    elseif command == "bits" and args[2]=="interval" and tonumber(args[3]) then
        local interval=SXUI_OrbDataPulse:SetInterval(args[3])
        Say("Orb data interval: "..interval.." ms")
        return
    elseif command == "bits" then
        local mode=args[2] or "stop"
        local valid={off=true,on=true,alt=true,alternate=true,inverse=true,wave=true,
            random=true,counter=true,stop=true}
        if not valid[mode] then
            Say("/beacon bits off/on/alt/inverse/wave/random/counter/stop | bits interval 20..500")
            return
        end
        mode=SXUI_OrbDataPulse:SetMode(mode)
        Say("Orb rune-star test: "..mode.." / "..SXUI_OrbDataPulse.interval.." ms")
        return
    elseif command == "position" or command == "orbs" or command == "carrier" then
        Say("This pet is cosmetic only. Data and calibration commands were retired.")
        return
    elseif command == "demo" and (args[2] == "on" or args[2] == "off") then
        settings.demoAnimations = args[2] == "on"
        beacon:Start()
    elseif command == "reset" then
        self:Reset(settings)
    elseif command == "lock" or command == "unlock" then
        settings.locked = command == "lock"
        if settings.enabled then SXUI_BeaconRenderer:Place(settings) end
    elseif command == "pos" and tonumber(args[2]) and tonumber(args[3]) then
        settings.x,settings.y = tonumber(args[2]),tonumber(args[3])
        self:Clamp(settings)
        if settings.enabled then SXUI_BeaconRenderer:Place(settings) end
    elseif command == "scale" and tonumber(args[2]) then
        settings.scale = tonumber(args[2])
        self:Clamp(settings)
        if settings.enabled then SXUI_BeaconRenderer:Place(settings) end
    elseif command ~= "status" then
        Say("/beacon (settings) | move | on/off | scale 0.5..2.0 | demo on/off | walk on/off/low/normal/high | bits off/on/alt/inverse/wave/random/counter/stop | bits interval 20..500 | status")
        return
    end
    Say("32 cosmetic orbs; walking "..(settings.walking and "ON" or "OFF").." / "..settings.walkFrequency)
    Say("Orb rune-star test "..SXUI_OrbDataPulse.mode.." / "..SXUI_OrbDataPulse.interval.." ms")
    Say(string.format("%s, %s, position %.0f / %.0f, scale %.3g, %s",
        settings.enabled and "ON" or "OFF",settings.demoAnimations and "Animation ON" or "Animation OFF",
        settings.x,settings.y,settings.scale,settings.locked and "locked" or "drag unlocked"))
end
