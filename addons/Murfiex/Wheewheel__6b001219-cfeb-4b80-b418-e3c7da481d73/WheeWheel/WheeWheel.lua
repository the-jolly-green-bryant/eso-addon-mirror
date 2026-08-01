local t={
name="WheeWheel",
savedVars=nil
}
local l
local h={time_ms=0,id=0}
local r={
HOLD_TIME_DECREASE=150,
wheel1={
name="Main",
[1]={type=101,val=1},
[2]={type=101,val=2},
[3]={type=9,val=21},
[4]={type=9,val=1},
[5]={type=9,val=23},
[6]={type=101,val=6},
[7]={type=101,val=7},
[8]={type=301,val=8},
},
wheel2={
name="Allies",
[1]={type=7,val=300},
[2]={type=7,val=9911},
[3]={type=7,val=9353},
[4]={type=7,val=9245},
[5]={type=7,val=301},
[6]={type=7,val=267},
[7]={type=7,val=10184},
[8]={type=7,val=9745},
},
wheel3={
name="Fun",
[1]={type=8,val=142},
[2]={type=8,val=876},
[3]={type=8,val=793},
[4]={type=7,val=9432},
[5]={type=7,val=5889},
[6]={type=8,val=88},
[7]={type=8,val=857},
[8]={type=8,val=595},
},
wheel4={
name="Tools",
[1]={type=7,val=8883},
[2]={type=7,val=14325},
[3]={type=7,val=601},
[4]={type=7,val=8006},
[5]={type=7,val=1108},
[6]={type=7,val=341},
[7]={type=7,val=11083},
[8]={type=7,val=12269},
},
}
local w={[0]="Nothing",
[7]="Collectible",
[8]="Emote",
[9]="Quick Chat",
[101]="Wheel: Quickslot",
[102]="Wheel: Allies",
[103]="Wheel: Mementos",
[104]="Wheel: Tools",
[105]="Wheel: Emotes",
[301]="Target Marker",
[302]="Travel to House",
}
local s={
[13]="wheel1",
[12]="wheel2",
[14]="wheel3",
[11]="wheel4",
}
local e={
SELECT_TYPE="SELECT_TYPE",
SELECT_COLLECTIBLE="SELECT_COLLECTIBLE",
SELECT_EMOTE_CATEGORY="SELECT_EMOTE_CATEGORY",
SELECT_EMOTE="SELECT_EMOTE",
SELECT_QUICKCHAT="SELECT_QUICKCHAT",
SELECT_TARGET_MARKER="SELECT_TARGET_MARKER",
SELECT_WHEEL_SLOT="SELECT_WHEEL_SLOT",
SELECT_HOUSE_LINK="SELECT_HOUSE_LINK",
}
local i={
status="idle",
results={},
}
local function c(t,a)
local e
if t==0 then
return ZO_UTILITY_SLOT_EMPTY_TEXTURE
elseif t==101 then
e=GetSlotTexture(a,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
return(e and e~="")and e or ZO_UTILITY_SLOT_EMPTY_TEXTURE
elseif t==102 then
e=GetSlotTexture(a,HOTBAR_CATEGORY_ALLY_WHEEL)
return(e and e~="")and e or ZO_UTILITY_SLOT_EMPTY_TEXTURE
elseif t==103 then
e=GetSlotTexture(a,HOTBAR_CATEGORY_MEMENTO_WHEEL)
return(e and e~="")and e or ZO_UTILITY_SLOT_EMPTY_TEXTURE
elseif t==104 then
e=GetSlotTexture(a,HOTBAR_CATEGORY_TOOL_WHEEL)
return(e and e~="")and e or ZO_UTILITY_SLOT_EMPTY_TEXTURE
elseif t==105 then
e=GetSlotTexture(a,HOTBAR_CATEGORY_EMOTE_WHEEL)
return(e and e~="")and e or ZO_UTILITY_SLOT_EMPTY_TEXTURE
elseif t==7 then
e=GetCollectibleIcon(a)
return(e and e~="")and e or"/esoui/art/icons/icon_missing.dds"
elseif t==8 then
local t=GetEmoteIndex(a)
if t then
local a,t=GetEmoteInfo(t)
if t then
e=GetSharedEmoteIconForCategory(t)
end
end
return(e and e~="")and e or"/esoui/art/icons/icon_missing.dds"
elseif t==9 then
return"/esoui/art/icons/emotes/emotecategoryicon_quickchat.dds"
elseif t==301 then
local t=ZO_GetPlatformTargetMarkerIconTable()
if t then
e=t[a]
end
return(e and e~="")and e or"/esoui/art/icons/icon_missing.dds"
elseif t==302 then
local e=type(a)=="string"and a or""
if e~=""then
local t,t,t,e=ZO_LinkHandler_ParseLink(e)
if e then
local e=GetCollectibleIdForHouse(tonumber(e))
if e and e~=0 then
local t,t,e=GetCollectibleInfo(e)
if e and e~=""then return e end
end
end
end
return"/esoui/art/collections/gamepad/gp_collections_tabicon_housing_up.dds"
else
return"/esoui/art/icons/icon_missing.dds"
end
end
local a
local function f()
if a then return a end
a={}
local e=GetNumDefaultQuickChats()
for t=1,e do
local e=GetDefaultQuickChatName(t)
if e and e~=""then
table.insert(a,{
val=t,
text=e,
})
end
end
return a
end
local a=false
local function u(o)
local n=HOUSE_TOURS_SEARCH_MANAGER:GetSearchState(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
local s=GetFrameTimeMilliseconds()-o
if n==ZO_HOUSE_TOURS_SEARCH_STATES.COMPLETE then
a=false
i.results={}
local e=HOUSE_TOURS_SEARCH_MANAGER:GetSortedSearchResults(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
if e then
for t,e in ipairs(e)do
local a=e:GetOwnerDisplayName()
local t=e:GetHouseId()
if a and t then
local n=string.format("|H1:housing:%d:%s|h|h",t,a)
local t=e:GetFormattedNickname()
local o=e:GetFormattedHouseName()
local t=(t and t~="")and(t.." - "..o)or o
t=t.." ("..a..")"
local e=e:GetCollectibleIcon()
table.insert(i.results,{
text=t,
icon=e,
houseLink=n,
})
end
end
end
i.status="done"
l()
elseif n==ZO_HOUSE_TOURS_SEARCH_STATES.FAILED or s>=2000 then
a=false
i.status="failed"
i.results={}
l()
else
zo_callLater(function()u(o)end,200)
end
end
local function m()
if a then return end
i.status="searching"
i.results={}
local e=HOUSE_TOURS_SEARCH_MANAGER:GetSearchFilters(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
e:ResetFilters()
HOUSE_TOURS_SEARCH_MANAGER:ExecuteSearch(HOUSE_TOURS_LISTING_TYPE_FAVORITE)
a=true
local e=GetFrameTimeMilliseconds()
zo_callLater(function()u(e)end,200)
end
local u={
[e.SELECT_TYPE]={
title="Select Type",
entries={
{
text="Nothing",
type=0,
isFinal=true,
},
{
text="Quick Chat",
type=9,
nextState=e.SELECT_QUICKCHAT,
},
{
text="Emote",
type=8,
nextState=e.SELECT_EMOTE_CATEGORY,
},
{
text="Assistants",
type=7,
categoryIndex=8,
subCategoryIndex=1,
nextState=e.SELECT_COLLECTIBLE,
},
{
text="Companions",
type=7,
categoryIndex=8,
subCategoryIndex=2,
nextState=e.SELECT_COLLECTIBLE,
},
{
text="Mementos",
type=7,
categoryIndex=9,
subCategoryIndex=false,
nextState=e.SELECT_COLLECTIBLE,
},
{
text="Tools",
type=7,
categoryIndex=10,
subCategoryIndex=false,
nextState=e.SELECT_COLLECTIBLE,
},
{
text="Target Marker",
type=301,
nextState=e.SELECT_TARGET_MARKER,
},
{
text="Travel to House",
type=302,
nextState=e.SELECT_HOUSE_LINK,
},
{
text="Wheel: Quickslot",
type=101,
hotbarCategory=HOTBAR_CATEGORY_QUICKSLOT_WHEEL,
nextState=e.SELECT_WHEEL_SLOT,
},
{
text="Wheel: Allies",
type=102,
hotbarCategory=HOTBAR_CATEGORY_ALLY_WHEEL,
nextState=e.SELECT_WHEEL_SLOT,
},
{
text="Wheel: Mementos",
type=103,
hotbarCategory=HOTBAR_CATEGORY_MEMENTO_WHEEL,
nextState=e.SELECT_WHEEL_SLOT,
},
{
text="Wheel: Tools",
type=104,
hotbarCategory=HOTBAR_CATEGORY_TOOL_WHEEL,
nextState=e.SELECT_WHEEL_SLOT,
},
{
text="Wheel: Emotes",
type=105,
hotbarCategory=HOTBAR_CATEGORY_EMOTE_WHEEL,
nextState=e.SELECT_WHEEL_SLOT,
},
},
},
[e.SELECT_COLLECTIBLE]={
title="Select Collectible",
getDynamicEntries=function(a)
local e={}
local t=a.data.categoryIndex
local o=a.data.subCategoryIndex
if not t then return e end
local a
if type(o)=="number"then
_,a=GetCollectibleSubCategoryInfo(t,o)
for a=1,a do
local a=GetCollectibleId(t,o,a)
local t,n,o,n,i=GetCollectibleInfo(a)
if t and t~=""and i then
table.insert(e,{
text=t,
icon=o,
collectibleId=a,
isFinal=true,
})
end
end
else
_,_,a=GetCollectibleCategoryInfo(t)
for a=1,a do
local a=GetCollectibleId(t,nil,a)
local t,n,i,n,o=GetCollectibleInfo(a)
if t and t~=""and o then
table.insert(e,{
text=t,
icon=i,
collectibleId=a,
isFinal=true,
})
end
end
end
table.sort(e,function(e,t)return e.text<t.text end)
return e
end,
},
[e.SELECT_EMOTE_CATEGORY]={
title="Select Emote Category",
getDynamicEntries=function()
local a={}
local o={}
local t=GetNumEmotes()
for t=1,t do
local i,t=GetEmoteInfo(t)
if i and t then
if not o[t]then
o[t]=true
local i=GetString("SI_EMOTECATEGORY",t)
local o=GetSharedEmoteIconForCategory(t)
table.insert(a,{
text=i,
icon=o,
emoteCategory=t,
nextState=e.SELECT_EMOTE,
})
end
end
end
table.sort(a,function(e,t)return e.emoteCategory<t.emoteCategory end)
return a
end,
},
[e.SELECT_EMOTE]={
title="Select Emote",
getDynamicEntries=function(t)
local e={}
local t=t.data.emoteCategory
if not t then return e end
local a=GetNumEmotes()
for o=1,a do
local a,i,n,s=GetEmoteInfo(o)
if i==t and a then
local o=GetEmoteCollectibleId(o)
local t=true
if o then
local a,a,a,a,e=GetCollectibleInfo(o)
t=e
end
if t then
local t=GetSharedEmoteIconForCategory(i)
local a=s or a
table.insert(e,{
text=a,
icon=t,
emoteId=n,
isFinal=true,
})
end
end
end
table.sort(e,function(t,e)return t.text<e.text end)
return e
end,
},
[e.SELECT_QUICKCHAT]={
title="Select Quick Chat",
getDynamicEntries=function()
local e={}
local t=f()
local a="/esoui/art/icons/emotes/emotecategoryicon_quickchat.dds"
for o,t in ipairs(t)do
table.insert(e,{
text=t.text,
icon=a,
quickChatId=t.val,
isFinal=true,
})
end
return e
end,
},
[e.SELECT_WHEEL_SLOT]={
title="Select Wheel Slot",
getDynamicEntries=function(e)
local i={}
local e=e.data.hotbarCategory
if not e then return i end
for a=1,8 do
local o=GetSlotName(a,e)
local t=GetSlotTexture(a,e)
if not t or t==""then
t=ZO_UTILITY_SLOT_EMPTY_TEXTURE
end
local e="Slot "..a
if o and o~=""then
e=e..": "..zo_strformat(SI_TOOLTIP_ITEM_NAME,o)
else
e=e..": Empty"
end
table.insert(i,{
text=e,
icon=t,
wheelSlotIndex=a,
isFinal=true,
})
end
return i
end,
},
[e.SELECT_TARGET_MARKER]={
title="Select Target Marker",
getDynamicEntries=function()
local a={}
local t=ZO_GetPlatformTargetMarkerIconTable()
for e=1,8 do
local t=t[e]
if t then
table.insert(a,{
text="Marker "..e,
icon=t,
targetMarkerId=e,
isFinal=true,
})
end
end
return a
end,
},
[e.SELECT_HOUSE_LINK]={
title="Select Favorite House",
getDynamicEntries=function(e)
if i.status=="idle"then
m()
end
if i.status=="searching"then
return{{text="Searching favorites...",isFinal=false}}
end
if#i.results==0 then
return{{text="No favorite houses found",isFinal=false}}
end
local t={}
for a,e in ipairs(i.results)do
table.insert(t,{
text=e.text,
icon=e.icon,
houseLink=e.houseLink,
isFinal=true,
})
end
return t
end,
},
}
local m=function(a)
local e=a.data.currentState or e.SELECT_TYPE
local e=u[e]
if not e then return{}end
local t=e.entries
if e.getDynamicEntries then
t=e.getDynamicEntries(a)
end
if not t then return{}end
local a={}
for t,e in ipairs(t)do
local t={
template="ZO_GamepadMenuEntryTemplate",
text=e.text,
templateData={
setup=ZO_SharedGamepadEntry_OnSetup,
type=e.type,
nextState=e.nextState,
collectibleId=e.collectibleId,
emoteId=e.emoteId,
quickChatId=e.quickChatId,
categoryIndex=e.categoryIndex,
subCategoryIndex=e.subCategoryIndex,
emoteCategory=e.emoteCategory,
isFinal=e.isFinal,
targetMarkerId=e.targetMarkerId,
wheelSlotIndex=e.wheelSlotIndex,
hotbarCategory=e.hotbarCategory,
houseLink=e.houseLink,
},
}
if e.icon then
t.icon=e.icon
end
table.insert(a,t)
end
return a
end
local a=function(a,o)
local i=a.data.slot
local n=a.data.wheelKey
if not i or not n then return 1 end
local t=t.savedVars[n][i]
local i=t.type
local t=t.val
local a=a.data.currentState or e.SELECT_TYPE
if a==e.SELECT_TYPE then
for a,e in ipairs(o)do
local o=e.templateData
if o.type==i then
if i~=7 then
return a
else
local e=o.categoryIndex
local o=o.subCategoryIndex
if e then
if type(o)=="number"then
local n,i=GetCollectibleSubCategoryInfo(e,o)
for i=1,(i or 0)do
if GetCollectibleId(e,o,i)==t then return a end
end
else
local i,i,o=GetCollectibleCategoryInfo(e)
for o=1,(o or 0)do
if GetCollectibleId(e,nil,o)==t then return a end
end
end
end
end
end
end
elseif a==e.SELECT_COLLECTIBLE then
if i~=7 then return 1 end
for a,e in ipairs(o)do
if e.templateData.collectibleId==t then return a end
end
elseif a==e.SELECT_EMOTE_CATEGORY then
if i~=8 then return 1 end
local e=GetEmoteIndex(t)
if e then
local t,e=GetEmoteInfo(e)
for t,a in ipairs(o)do
if a.templateData.emoteCategory==e then return t end
end
end
elseif a==e.SELECT_EMOTE then
if i~=8 then return 1 end
for a,e in ipairs(o)do
if e.templateData.emoteId==t then return a end
end
elseif a==e.SELECT_QUICKCHAT then
if i~=9 then return 1 end
for a,e in ipairs(o)do
if e.templateData.quickChatId==t then return a end
end
elseif a==e.SELECT_WHEEL_SLOT then
for a,e in ipairs(o)do
if e.templateData.wheelSlotIndex==t then return a end
end
elseif a==e.SELECT_TARGET_MARKER then
if i~=301 then return 1 end
for e,a in ipairs(o)do
if a.templateData.targetMarkerId==t then return e end
end
elseif a==e.SELECT_HOUSE_LINK then
if i~=302 then return 1 end
for a,e in ipairs(o)do
if e.templateData.houseLink==t then return a end
end
end
return 1
end
local n
function l()
if n and n.data and
n.data.currentState==e.SELECT_HOUSE_LINK then
local e=m(n)
n.info.parametricList=e
n:setupFunc()
local e=a(n,e)
n.entryList:SetSelectedIndex(e,false,true)
end
end
ESO_Dialogs["slotdialog"]={
gamepadInfo={
dialogType=GAMEPAD_DIALOGS.PARAMETRIC,
},
canQueue=true,
title={
text=function(t)
local e=t.data.currentState or e.SELECT_TYPE
local e=u[e]
return e and e.title or"Select"
end,
},
setup=function(e)
n=e
local t=m(e)
e.info.parametricList=t
e:setupFunc()
local t=a(e,t)
e.entryList:SetSelectedIndex(t,false,true)
end,
parametricList={},
parametricListOnSelectionChangedCallback=function(e,e,e)
end,
buttons={
{
keybind="DIALOG_PRIMARY",
text=GetString(SI_GAMEPAD_SELECT_OPTION),
callback=function(i)
local a=i.entryList:GetTargetData()
if not a then return end
local n=i.data.currentState or e.SELECT_TYPE
if a.isFinal then
local e=i.data.slot
local o=i.data.wheelKey or"wheel1"
local i=a.type or i.data.selectedType
if i==0 then
t.savedVars[o][e].type=0
t.savedVars[o][e].val=0
LibHarvensAddonSettings.list:RefreshVisible()
elseif a.houseLink then
t.savedVars[o][e].type=302
t.savedVars[o][e].val=a.houseLink
LibHarvensAddonSettings.list:RefreshVisible()
elseif a.collectibleId then
t.savedVars[o][e].type=i
t.savedVars[o][e].val=a.collectibleId
LibHarvensAddonSettings.list:RefreshVisible()
elseif a.emoteId then
t.savedVars[o][e].type=i
t.savedVars[o][e].val=a.emoteId
LibHarvensAddonSettings.list:RefreshVisible()
elseif a.quickChatId then
t.savedVars[o][e].type=i
t.savedVars[o][e].val=a.quickChatId
LibHarvensAddonSettings.list:RefreshVisible()
elseif a.targetMarkerId then
t.savedVars[o][e].type=i
t.savedVars[o][e].val=a.targetMarkerId
LibHarvensAddonSettings.list:RefreshVisible()
elseif a.wheelSlotIndex then
t.savedVars[o][e].type=i
t.savedVars[o][e].val=a.wheelSlotIndex
LibHarvensAddonSettings.list:RefreshVisible()
end
elseif a.nextState then
if n==e.SELECT_TYPE then
i.data.selectedType=a.type
end
if a.categoryIndex then
i.data.categoryIndex=a.categoryIndex
i.data.subCategoryIndex=a.subCategoryIndex
end
if a.emoteCategory then
i.data.emoteCategory=a.emoteCategory
end
if a.hotbarCategory then
i.data.hotbarCategory=a.hotbarCategory
end
i.data.transitionToState=a.nextState
end
end,
},
{
keybind="DIALOG_NEGATIVE",
text=function(t)
local t=t.data.currentState or e.SELECT_TYPE
if t==e.SELECT_TYPE then
return GetString(SI_DIALOG_CANCEL)
else
return GetString(SI_GAMEPAD_BACK_OPTION)
end
end,
callback=function(t)
local a=t.data.currentState or e.SELECT_TYPE
if a==e.SELECT_COLLECTIBLE then
t.data.transitionToState=e.SELECT_TYPE
t.data.shouldReopen=true
elseif a==e.SELECT_EMOTE then
t.data.transitionToState=e.SELECT_EMOTE_CATEGORY
t.data.shouldReopen=true
elseif a==e.SELECT_EMOTE_CATEGORY then
t.data.transitionToState=e.SELECT_TYPE
t.data.shouldReopen=true
elseif a==e.SELECT_QUICKCHAT then
t.data.transitionToState=e.SELECT_TYPE
t.data.shouldReopen=true
elseif a==e.SELECT_TARGET_MARKER then
t.data.transitionToState=e.SELECT_TYPE
t.data.shouldReopen=true
elseif a==e.SELECT_WHEEL_SLOT then
t.data.transitionToState=e.SELECT_TYPE
t.data.shouldReopen=true
elseif a==e.SELECT_HOUSE_LINK then
t.data.transitionToState=e.SELECT_TYPE
t.data.shouldReopen=true
end
end,
},
},
finishedCallback=function(t)
n=nil
if t.data.transitionToState==e.SELECT_HOUSE_LINK then
i.status="idle"
i.results={}
end
if t.data.transitionToState then
local a={
slot=t.data.slot,
wheelKey=t.data.wheelKey,
selectedType=t.data.selectedType,
currentState=t.data.transitionToState,
categoryIndex=t.data.categoryIndex,
subCategoryIndex=t.data.subCategoryIndex,
emoteCategory=t.data.emoteCategory,
hotbarCategory=t.data.hotbarCategory,
}
if t.data.shouldReopen or t.data.transitionToState~=e.SELECT_TYPE then
ZO_Dialogs_ShowGamepadDialog("slotdialog",a)
end
end
end,
}
local function y()
local o=LibHarvensAddonSettings
local a={
allowDefaults=true,
allowRefresh=true,
defaultsFunction=function()
for i,a in pairs(r)do
if type(a)=="table"and t.savedVars[i]then
for e=1,8 do
if a[e]then
t.savedVars[i][e].type=a[e].type
t.savedVars[i][e].val=a[e].val
end
end
end
end
o.list:RefreshVisible()
end,
}
local n=o:AddAddon("WheeWheel",a)
if not n then return end
local a={
type=o.ST_LABEL,
label="|cff0000WheeWheel setup|r",
}
n:AddSetting(a)
local a={
type=o.ST_SLIDER,
label="Speed up radial menus",
tooltip="This will decrease the time in milliseconds that you have to hold the button to bring up the radial menus in the game. Warning: do not set this too high. The higher the speed up, the faster you must tap the button to register as a single press.",
getFunction=function()return t.savedVars.HOLD_TIME_DECREASE end,
setFunction=function(e)t.savedVars.HOLD_TIME_DECREASE=e end,
default=r.HOLD_TIME_DECREASE,
min=0,
max=200,
step=10,
unit="ms",
format="%d",
}
n:AddSetting(a)
local a={
{key="wheel1",displayName="Wheel 1"},
{key="wheel2",displayName="Wheel 2"},
{key="wheel3",displayName="Wheel 3"},
{key="wheel4",displayName="Wheel 4"},
}
for a,i in ipairs(a)do
local a={
type=o.ST_LABEL,
label="|cFFFF00"..i.displayName.."|r",
}
n:AddSetting(a)
local a={
type=o.ST_EDIT,
label="Name",
tooltip="Name for "..i.displayName,
default=r[i.key].name,
getFunction=function()return t.savedVars[i.key].name end,
setFunction=function(e)t.savedVars[i.key].name=e end,
}
n:AddSetting(a)
for a=1,8 do
local e={
type=o.ST_BUTTON,
label=function()
local e=t.savedVars[i.key][a]
local o=e.type
local t=e.val
local e=c(o,t)
local i=""
if e and e~=""then
i=zo_iconFormat(e,32,32).." "
end
local e=""
if o==0 then
e="Slot "..tostring(a)..": Empty"
elseif o==7 then
local t=GetCollectibleInfo(t)
e="Slot "..tostring(a)..": "..(t or"Unknown Collectible")
elseif o==8 then
local o=GetNumEmotes()
for o=1,o do
local o,s,n,i=GetEmoteInfo(o)
if n==t then
local t=i or o
e="Slot "..tostring(a)..": "..(t or"Unknown Emote")
break
end
end
if e==""then
e="Slot "..tostring(a)..": Unknown Emote"
end
elseif o==9 then
local t=GetDefaultQuickChatName(t)
e="Slot "..tostring(a)..": "..(t or"Unknown Chat")
elseif o==301 then
e="Slot "..tostring(a)..": Target Marker "..tostring(t)
elseif o==302 then
local o,o,o,o,t=ZO_LinkHandler_ParseLink(tostring(t))
if t then
e="Slot "..tostring(a)..": House ("..t..")"
else
e="Slot "..tostring(a)..": House (no link set)"
end
elseif o==101 then
local o=GetSlotName(t,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
e="Slot "..tostring(a)..": Quickslot "..tostring(t)..(o~=""and" ("..o..")"or"")
elseif o==102 then
local o=GetSlotName(t,HOTBAR_CATEGORY_ALLY_WHEEL)
e="Slot "..tostring(a)..": Ally "..tostring(t)..(o~=""and" ("..o..")"or"")
elseif o==103 then
local o=GetSlotName(t,HOTBAR_CATEGORY_MEMENTO_WHEEL)
e="Slot "..tostring(a)..": Memento "..tostring(t)..(o~=""and" ("..o..")"or"")
elseif o==104 then
local o=GetSlotName(t,HOTBAR_CATEGORY_TOOL_WHEEL)
e="Slot "..tostring(a)..": Tool "..tostring(t)..(o~=""and" ("..o..")"or"")
elseif o==105 then
local o=GetSlotName(t,HOTBAR_CATEGORY_EMOTE_WHEEL)
e="Slot "..tostring(a)..": Emote Wheel "..tostring(t)..(o~=""and" ("..o..")"or"")
else
e="Slot "..tostring(a)..": "..(w[o]or"Unknown")
end
return i..e
end,
buttonText="Assign",
tooltip="Click to assign an action to this slot",
clickHandler=function()
ZO_Dialogs_ShowGamepadDialog("slotdialog",{slot=a,wheelKey=i.key,currentState=e.SELECT_TYPE})
end,
}
n:AddSetting(e)
end
end
end
local function w()
ZO_PostHook(ZO_UtilityWheel_Shared,"RefreshCategories",function(e)
local a=e:GetNextHotbarCategory()
local o=e:GetPreviousHotbarCategory()
local i=e:GetHotbarCategory()
local a=t.savedVars[s[a]]
local o=t.savedVars[s[o]]
local t=t.savedVars[s[i]]
if a~=nil then e.nextCategoryName:SetText(a.name)end
if o~=nil then e.previousCategoryName:SetText(o.name)end
if t~=nil then e.categoryLabel:SetText(t.name)end
end)
end
local function u()
ZO_PreHook(ZO_UtilityWheel_Shared,"SetupEntryControl",function(e,o,i)
local e=e:GetHotbarCategory()
local a=s[e]
if a==nil then return false end
local e=t.savedVars[a][i.slotNum].type
local a=t.savedVars[a][i.slotNum].val
local t
if e==101 then
t=GetSlotItemCount(a,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
elseif e==102 then
t=GetSlotItemCount(a,HOTBAR_CATEGORY_ALLY_WHEEL)
elseif e==103 then
t=GetSlotItemCount(a,HOTBAR_CATEGORY_MEMENTO_WHEEL)
elseif e==104 then
t=GetSlotItemCount(a,HOTBAR_CATEGORY_TOOL_WHEEL)
elseif e==105 then
t=GetSlotItemCount(a,HOTBAR_CATEGORY_EMOTE_WHEEL)
end
ZO_SetupSelectableItemRadialMenuEntryTemplate(o,false,t)
if o.label then
if(e==8 or e==9)then
o.label:SetText(i.name)
o.label:SetHidden(false)
else
o.label:SetHidden(true)
end
end
return true
end)
end
local function m()
local a=0
ZO_PostHook(ZO_InteractiveRadialMenuController,"StartInteraction",function(e)
if e.beginHold~=nil then
e.beginHold=e.beginHold-t.savedVars.HOLD_TIME_DECREASE
e.currentHotbarCategoryIndex=2
else
local e=GetFrameTimeMilliseconds()
if e-a<200 and not IsInteractionPending()and not IsInteracting()then
if e-h.time_ms<10000 then
AssignTargetMarkerToReticleTarget(h.id)
h.time_ms=e
end
end
a=e
end
end)
end
local function f()
local o=ZO_GetUtilityWheelSlottedEntries
ZO_GetUtilityWheelSlottedEntries=function(a)
local e=s[a]
if e==nil then return o(a)end
local o={}
for a=1,#t.savedVars[e]do
local i=t.savedVars[e][a].type
local e=t.savedVars[e][a].val
local t=c(i,e)
o[a]=
{
type=i,
id=e,
icon=t,
slotIndex=a,
}
end
return o
end
end
local function l()
SecurePostHook(ZO_UtilityWheel_Shared,"PopulateMenu",function(o)
local e=o:GetHotbarCategory()
local e=s[e]
if e==nil then return end
for a=1,#t.savedVars[e]do
local i=t.savedVars[e][a].type
local e=t.savedVars[e][a].val
if i==101 then
local t=GetSlotName(e,10)
t=zo_strformat(SI_TOOLTIP_ITEM_NAME,t)
local n=GetSlotItemDisplayQuality(e,HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
local i=t
if n then
local e,a,o=GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS,n)
local e={r=e,g=a,b=o}
i={t,e}
end
local t=GetSlotType(e,10)
if t==9 then
i="Quickslot Quick Chat"
elseif t==8 then
i="Quickslot Emote"
end
o.menu.entries[a].name=i
o.menu.entries[a].data.name=ZO_UTILITY_SLOT_EMPTY_STRING
o.menu.entries[a].callback=function()SetCurrentQuickslot(e)end
elseif i==102 then
local t=GetSlotName(e,HOTBAR_CATEGORY_ALLY_WHEEL)
o.menu.entries[a].name=t~=""and t or"Ally Slot "..e
o.menu.entries[a].callback=function()
local e=GetSlotBoundId(e,HOTBAR_CATEGORY_ALLY_WHEEL)
if e and e~=0 then UseCollectible(e)end
end
elseif i==103 then
local t=GetSlotName(e,HOTBAR_CATEGORY_MEMENTO_WHEEL)
o.menu.entries[a].name=t~=""and t or"Memento Slot "..e
o.menu.entries[a].callback=function()
local e=GetSlotBoundId(e,HOTBAR_CATEGORY_MEMENTO_WHEEL)
if e and e~=0 then UseCollectible(e)end
end
elseif i==104 then
local t=GetSlotName(e,HOTBAR_CATEGORY_TOOL_WHEEL)
o.menu.entries[a].name=t~=""and t or"Tool Slot "..e
o.menu.entries[a].callback=function()
local e=GetSlotBoundId(e,HOTBAR_CATEGORY_TOOL_WHEEL)
if e and e~=0 then UseCollectible(e)end
end
elseif i==105 then
local i=GetSlotBoundId(e,HOTBAR_CATEGORY_EMOTE_WHEEL)
local t=""
if i and i~=0 then
t=GetCollectibleInfo(i)
o.menu.entries[a].callback=function()
UseCollectible(i)
end
else
local e=GetSlotBoundId(e,HOTBAR_CATEGORY_EMOTE_WHEEL)
if e and e~=0 then
local a=GetNumEmotes()
for a=1,a do
local i,i,a,o=GetEmoteInfo(a)
if a==e then
t=o
break
end
end
end
end
o.menu.entries[a].name=t~=""and t or"Emote Slot "..e
elseif i==7 then
local t=GetCollectibleInfo(e)
o.menu.entries[a].name=t
o.menu.entries[a].callback=function()UseCollectible(e)end
elseif i==301 then
o.menu.entries[a].name="Target Marker"
o.menu.entries[a].callback=
function()
AssignTargetMarkerToReticleTarget(e)
h.time_ms=GetFrameTimeMilliseconds()
h.id=e
end
elseif i==302 then
local e=e or""
local i,i,i,t,e=ZO_LinkHandler_ParseLink(e)
local i=e and(e.."'s house")or"House (invalid)"
o.menu.entries[a].name=i
o.menu.entries[a].callback=function()
if t and e then
JumpToSpecificHouse(e,t)
else
end
end
end
end
end)
local a=ZO_UtilityWheelValidateOrClearSlot
SecurePostHook("ZO_UtilityWheelValidateOrClearSlot",function(t,e)
local t=a(t,e)
if s[e]~=nil then
return true
else
return t
end
end)
end
local function a()
t.savedVars=ZO_SavedVars:NewAccountWide("WheeWheel_SavedVars",1,GetWorldName(),r)
m()
f()
l()
u()
w()
y()
end
local function e()
EVENT_MANAGER:UnregisterForEvent(t.name,EVENT_PLAYER_ACTIVATED)
zo_callLater(function()
a()
end,100)
end
EVENT_MANAGER:RegisterForEvent(t.name,EVENT_PLAYER_ACTIVATED,e)
