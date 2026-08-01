local e={
name="Update47Tweaker",
savedVars=nil
}
local o={
nearDistanceShow=true,
nearDistanceColor={1,1,1},
farDistanceShow=true,
farDistanceColor={1,1,1},
canLearnShow=true,
canLearnColor={1,1,1},
lockedSetShow=true,
lockedSetColor={1,1,1},
}
local function i()
if e.savedVars["nearDistanceShow"]then
local t=e.savedVars["nearDistanceColor"][1]*255
local a=e.savedVars["nearDistanceColor"][2]*255
local e=e.savedVars["nearDistanceColor"][3]*255
if t==1 and a==1 and e==1 then
EsoStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER]=string.format("<<1>>m")
else
EsoStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER]=string.format("|c%02X%02X%02X<<1>>m|r",t,a,e)
end
else
EsoStrings[SI_COMPASS_PIN_DISTANCE_FORMATTER]=""
end
if e.savedVars["farDistanceShow"]then
local a=e.savedVars["farDistanceColor"][1]*255
local t=e.savedVars["farDistanceColor"][2]*255
local e=e.savedVars["farDistanceColor"][3]*255
if a==1 and t==1 and e==1 then
EsoStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER]=string.format("<<1>>km")
else
EsoStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER]=string.format("|c%02X%02X%02X<<1>>km|r",a,t,e)
end
else
EsoStrings[SI_COMPASS_PIN_LONG_DISTANCE_FORMATTER]=""
end
end
local function s()
local a=ZO_MultiIcon_Initialize
local i="EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_can_learn.dds"
local o="EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_locked_set_piece.dds"
ZO_MultiIcon_Initialize=function(t)
a(t)
local s=t.AddIcon
t.AddIcon=function(n,t,a,h)
if t==i then
if e.savedVars["canLearnShow"]==false then return end
a=ZO_ColorDef:New(e.savedVars["canLearnColor"][1],e.savedVars["canLearnColor"][2],e.savedVars["canLearnColor"][3],1)
elseif t==o then
if e.savedVars["lockedSetShow"]==false then return end
a=ZO_ColorDef:New(e.savedVars["lockedSetColor"][1],e.savedVars["lockedSetColor"][2],e.savedVars["lockedSetColor"][3],1)
end
s(n,t,a,h)
end
end
end
local function h()
local t=LibHarvensAddonSettings
local a={
allowDefaults=true,
allowRefresh=true,
defaultsFunction=function()
i()
end,
}
local a=t:AddAddon("Update 47 Tweaker",a)
if not a then return end
local n={
type=t.ST_LABEL,
label=function()if not UI_SETTING_COMPASS_DISTANCE_TRACKING or GetSetting(SETTING_TYPE_UI,UI_SETTING_COMPASS_DISTANCE_TRACKING)=="1"then return""else return"|cff0000Turn on Compass Distance Tracking in Interface Options first|r"end end,
}
a:AddSetting(n)
local n={
type=t.ST_CHECKBOX,
label="Show Distances (Near)",
tooltip="Show distance on the compass when a target is nearby.",
default=o["nearDistanceShow"],
setFunction=function(t)
e.savedVars["nearDistanceShow"]=t
i()
end,
getFunction=function()
return e.savedVars["nearDistanceShow"]
end,
disable=function()return UI_SETTING_COMPASS_DISTANCE_TRACKING and GetSetting(SETTING_TYPE_UI,UI_SETTING_COMPASS_DISTANCE_TRACKING)~="1"end,
}
a:AddSetting(n)
local n={
type=t.ST_COLOR,
label="Text Color (Near)",
tooltip="Color of the distance on the compass when a target is nearby.",
setFunction=function(...)
colorR,colorG,colorB,colorA=...
e.savedVars["nearDistanceColor"]={colorR,colorG,colorB}
i()
end,
default=o["nearDistanceColor"],
getFunction=function()
return e.savedVars["nearDistanceColor"][1],e.savedVars["nearDistanceColor"][2],e.savedVars["nearDistanceColor"][3],1
end,
disable=function()return not e.savedVars["nearDistanceShow"]end,
}
a:AddSetting(n)
local n={
type=t.ST_CHECKBOX,
label="Show Distance (Far)",
tooltip="Show distance on the compass when a target is far away.",
default=o["farDistanceShow"],
setFunction=function(t)
e.savedVars["farDistanceShow"]=t
i()
end,
getFunction=function()
return e.savedVars["farDistanceShow"]
end,
disable=function()return UI_SETTING_COMPASS_DISTANCE_TRACKING and GetSetting(SETTING_TYPE_UI,UI_SETTING_COMPASS_DISTANCE_TRACKING)~="1"end,
}
a:AddSetting(n)
local i={
type=t.ST_COLOR,
label="Text Color (Far)",
tooltip="Color of the distance on the compass when a target is far away.",
setFunction=function(...)
colorR,colorG,colorB,colorA=...
e.savedVars["farDistanceColor"]={colorR,colorG,colorB}
i()
end,
default=o["farDistanceColor"],
getFunction=function()
return e.savedVars["farDistanceColor"][1],e.savedVars["farDistanceColor"][2],e.savedVars["farDistanceColor"][3],1
end,
disable=function()return not e.savedVars["farDistanceShow"]end,
}
a:AddSetting(i)
local i={
type=t.ST_SECTION,
}
a:AddSetting(i)
local i={
type=t.ST_CHECKBOX,
label="Show Can Learn",
tooltip="Show icon when an item can be learned.",
default=o["canLearnShow"],
setFunction=function(t)
e.savedVars["canLearnShow"]=t
end,
getFunction=function()
return e.savedVars["canLearnShow"]
end,
disable=false,
}
a:AddSetting(i)
local i={
type=t.ST_COLOR,
label="Color (Can Learn)",
tooltip="Color of the icon for items that can be learned.",
setFunction=function(...)
colorR,colorG,colorB,colorA=...
e.savedVars["canLearnColor"]={colorR,colorG,colorB}
end,
default=o["canLearnColor"],
getFunction=function()
return e.savedVars["canLearnColor"][1],e.savedVars["canLearnColor"][2],e.savedVars["canLearnColor"][3],1
end,
disable=function()return not e.savedVars["canLearnShow"]end,
}
a:AddSetting(i)
local i={
type=t.ST_CHECKBOX,
label="Show Uncollected Gear",
tooltip="Show icon on gear that can be added to your sets collection.",
default=o["lockedSetShow"],
setFunction=function(t)
e.savedVars["lockedSetShow"]=t
end,
getFunction=function()
return e.savedVars["lockedSetShow"]
end,
disable=false,
}
a:AddSetting(i)
local o={
type=t.ST_COLOR,
label="Color (Uncollected Gear)",
tooltip="Color of the icon for gear that can be added to your sets collection.",
setFunction=function(...)
colorR,colorG,colorB,colorA=...
e.savedVars["lockedSetColor"]={colorR,colorG,colorB}
end,
default=o["lockedSetColor"],
getFunction=function()
return e.savedVars["lockedSetColor"][1],e.savedVars["lockedSetColor"][2],e.savedVars["lockedSetColor"][3],1
end,
disable=function()return not e.savedVars["lockedSetShow"]end,
}
a:AddSetting(o)
local e={
type=t.ST_BUTTON,
label="Classic colors",
tooltip="Use classic colors for the icons.",
buttonText="Apply",
clickHandler=function(t,t)
local t,o,a=ZO_SUCCEEDED_TEXT:UnpackRGBA()
e.savedVars["canLearnColor"]={t,o,a}
e.savedVars["lockedSetColor"]={t,o,a}
end,
disable=false,
}
a:AddSetting(e)
end
local function t(a,t)
if t~=e.name then return end
EVENT_MANAGER:UnregisterForEvent(e.name,EVENT_ADD_ON_LOADED)
e.savedVars=ZO_SavedVars:NewAccountWide("Update47Tweaker_SavedVars",1,nil,o)
i()
s()
h()
end
EVENT_MANAGER:RegisterForEvent(e.name,EVENT_ADD_ON_LOADED,t)
