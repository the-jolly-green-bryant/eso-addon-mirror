local t="MurfTimer"
local e={
frame=nil,
label=nil,
icon=nil,
latencyLabel=nil,
latencyIcon=nil,
startTime=0,
running=false,
autoMode=false,
latencyOn=false,
timerUpdateHandler=nil,
latencyUpdateHandler=nil,
}
local o={
LOW={
image="EsoUI/Art/Campaign/campaignBrowser_hiPop.dds",
color=ZO_SELECTED_TEXT,
},
MEDIUM={
image="EsoUI/Art/Campaign/campaignBrowser_medPop.dds",
color=ZO_SELECTED_TEXT,
},
HIGH={
image="EsoUI/Art/Campaign/campaignBrowser_lowPop.dds",
color=ZO_ERROR_COLOR,
},
}
local function a(e)
local e=math.floor(e/1000)
local t=math.floor(e/60)
local e=e%60
return string.format("%02d:%02d",t,e)
end
local function i()
if e.autoMode and not e.running then
e.label:SetText("AUTO")
elseif e.running then
local t=GetGameTimeMilliseconds()-e.startTime
e.label:SetText(a(t))
end
end
local function h()
if not e.latencyOn then
if e.latencyLabel then
e.latencyLabel:SetText("")
end
if e.latencyIcon then
e.latencyIcon:SetHidden(true)
end
return
end
local a=GetLatency()
local t
if a<150 then
t=o.LOW
elseif a<=300 then
t=o.MEDIUM
else
t=o.HIGH
end
if e.latencyIcon then
e.latencyIcon:SetTexture(t.image)
e.latencyIcon:SetHidden(false)
end
if e.latencyLabel then
e.latencyLabel:SetText(string.format("%d ms",a))
e.latencyLabel:SetColor(t.color:UnpackRGBA())
e.latencyLabel:SetHidden(false)
end
end
local function n()
if e.running then return end
e.startTime=GetGameTimeMilliseconds()
e.running=true
e.frame:SetHidden(false)
if not e.timerUpdateHandler then
e.timerUpdateHandler=EVENT_MANAGER:RegisterForUpdate(t.."TimerUpdate",1000,i)
end
end
local function o()
if not e.running then return end
e.running=false
if e.timerUpdateHandler then
EVENT_MANAGER:UnregisterForUpdate(t.."TimerUpdate")
e.timerUpdateHandler=nil
end
end
local function a()
o()
e.label:SetText("00:00")
end
local function s()
e.frame:SetHidden(false)
end
local function c()
e.frame:SetHidden(true)
end
local function i(t)
e.autoMode=t
if t then
a()
s()
e.label:SetText("AUTO")
else
end
end
local function w()
if not e.autoMode then return end
n()
end
local function m()
if not e.autoMode then return end
o()
end
local function f(a,t)
if not e.autoMode then return end
if not t then return end
local a=IsPlayerInRaid()
local t=GetCurrentZoneDungeonDifficulty()
local e=(GetMapContentType()==MAP_CONTENT_DUNGEON)
if(a and t==0)or e then
n()
end
end
local function r()
local a=WINDOW_MANAGER
e.frame=a:CreateTopLevelWindow(t.."Frame")
e.frame:SetDimensions(320,40)
e.frame:SetAnchor(BOTTOMLEFT,GuiRoot,BOTTOMLEFT,10,-60)
e.frame:SetHidden(true)
e.icon=a:CreateControl(t.."Icon",e.frame,CT_TEXTURE)
e.icon:SetTexture("/esoui/art/lfg/gamepad/lfg_menuicon_timedactivities.dds")
e.icon:SetDimensions(32,32)
e.icon:SetAnchor(LEFT,e.frame,LEFT,0,0)
e.label=a:CreateControl(t.."Label",e.frame,CT_LABEL)
e.label:SetFont("ZoFontGamepad42")
e.label:SetAnchor(LEFT,e.icon,RIGHT,5,0)
e.label:SetText("00:00")
e.label:SetColor(1,1,1,1)
e.latencyIcon=a:CreateControl(t.."LatencyIcon",e.frame,CT_TEXTURE)
e.latencyIcon:SetDimensions(24,24)
e.latencyIcon:SetAnchor(LEFT,e.label,RIGHT,10,3)
e.latencyIcon:SetHidden(true)
e.latencyLabel=a:CreateControl(t.."LatencyLabel",e.frame,CT_LABEL)
e.latencyLabel:SetFont("ZoFontGamepad34")
e.latencyLabel:SetAnchor(LEFT,e.latencyIcon,RIGHT,5,2)
e.latencyLabel:SetText("")
e.latencyLabel:SetColor(1,1,1,1)
e.latencyLabel:SetHidden(true)
end
local function a(a)
if a then
e.latencyOn=true
e.latencyIcon:SetHidden(false)
e.latencyLabel:SetHidden(false)
if not e.latencyUpdateHandler then
e.latencyUpdateHandler=EVENT_MANAGER:RegisterForUpdate(t.."LatencyUpdate",5000,h)
end
h()
else
e.latencyOn=false
e.latencyIcon:SetHidden(true)
e.latencyLabel:SetHidden(true)
if e.latencyUpdateHandler then
EVENT_MANAGER:UnregisterForUpdate(t.."LatencyUpdate")
e.latencyUpdateHandler=nil
end
end
end
local function h()
i(false)
n()
end
local function n()
i(false)
o()
end
local function l()
o()
if e.autoMode then
e.label:SetText("AUTO")
else
e.label:SetText("00:00")
end
end
local function u()
s()
end
local function o()
c()
end
local function s()
if e.autoMode then
i(false)
else
i(true)
end
end
local function i()
a(true)
end
local function c()
a(false)
end
local function e(a,e)
if e~=t then return end
r()
SLASH_COMMANDS["/timerstart"]=h
SLASH_COMMANDS["/timerstop"]=n
SLASH_COMMANDS["/timerreset"]=l
SLASH_COMMANDS["/timeron"]=u
SLASH_COMMANDS["/timeroff"]=o
SLASH_COMMANDS["/timerauto"]=s
SLASH_COMMANDS["/timerlagon"]=i
SLASH_COMMANDS["/timerlagoff"]=c
EVENT_MANAGER:RegisterForEvent(t,EVENT_RAID_TRIAL_STARTED,w)
EVENT_MANAGER:RegisterForEvent(t,EVENT_RAID_TRIAL_COMPLETE,m)
EVENT_MANAGER:RegisterForEvent(t,EVENT_PLAYER_COMBAT_STATE,f)
end
EVENT_MANAGER:RegisterForEvent(t,EVENT_ADD_ON_LOADED,e)
