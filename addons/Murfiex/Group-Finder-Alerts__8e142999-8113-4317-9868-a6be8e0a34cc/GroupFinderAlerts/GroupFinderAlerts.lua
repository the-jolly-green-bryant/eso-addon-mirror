local a="GroupFinderAlerts"
local p=45000
local o=false
local r=true
local l={}
local e=0
local n={}
local i={}
local t=ZO_ColorDef:New(GetChatCategoryColor(CHAT_CATEGORY_ZONE)):Colorize("["..GetString(SI_ACTIVITY_FINDER_CATEGORY_GROUP_FINDER).."] ")
local m="|cCC0000"..GetString(SI_SOCIAL_OPTIONS_ALERTS).." "
local y="|cCCCCCC"..GetString(SI_CHECK_BUTTON_ON).." "
local w="|cCCCCCC"..GetString(SI_CHECK_BUTTON_OFF).." "
local function h(e)
return("|c88CCFF"..e.."|r ")
end
local function s(e)
return("|cCCCC00"..e.."|r ")
end
local function u(e)
return("|cCCCCCC"..e.."|r ")
end
local function v()
e=GetGroupFinderFilterCategory()
n={}
for e=1,GetGroupFinderFilterNumPrimaryOptions(e)do
local a,t=GetGroupFinderFilterPrimaryOptionByIndex(e)
n[e]={a,t}
end
i={}
for e=1,GetGroupFinderFilterNumSecondaryOptions(e)do
local a,t=GetGroupFinderFilterSecondaryOptionByIndex(e)
i[e]={a,t}
end
end
local function f()
SetGroupFinderFilterCategory(e)
for e,t in ipairs(n)do
if t[2]==true then
SetGroupFinderFilterPrimaryOptionByIndex(e,true)
end
end
for t,e in ipairs(i)do
SetGroupFinderFilterSecondaryOptionByIndex(t,e[2])
end
end
local function c()
GROUP_FINDER_SEARCH_MANAGER:UnregisterCallback("OnGroupFinderSearchResultsReady",c)
local e=GROUP_FINDER_SEARCH_MANAGER:GetSearchResults()
if not e or#e==0 then return end
local n={}
local a=0
for i,e in ipairs(e)do
local i=GetGroupFinderSearchListingLeaderDisplayNameByIndex(e.listingIndex)
local c=GetGroupFinderSearchListingTitleByIndex(e.listingIndex)
local i=i..e.primaryOptionText..e.secondaryOptionText
local e=t..h(e.primaryOptionText)..s(e.secondaryOptionText)..u(c)
if not l[i]and o and(not r)then
a=a+1
if a<6 then
d(e)
end
if a==6 then
local e=t..h("(...)")
d(e)
end
end
n[i]=true
end
l={}
for e,t in pairs(n)do
l[e]=t
end
r=false
end
local function u()
o=false
EVENT_MANAGER:UnregisterForUpdate(a.."_Monitor")
d(t..m..w)
end
local function l()
if not o then return end
if HasGroupListingForUserType(GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING)then
u()
return
end
local e=GROUP_FINDER_SEARCH_MANAGER:GetSearchState()
if e==ZO_GROUP_FINDER_SEARCH_STATES.WAITING or e==ZO_GROUP_FINDER_SEARCH_STATES.QUEUED then
return
end
f()
GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnGroupFinderSearchResultsReady",c)
GROUP_FINDER_SEARCH_MANAGER:ExecuteSearch()
end
local function c()
o=true
r=true
EVENT_MANAGER:RegisterForUpdate(a.."_Monitor",p,l)
l()
local t=t..m..y
if e==GROUP_FINDER_CATEGORY_ARENA or e==GROUP_FINDER_CATEGORY_DUNGEON or e==GROUP_FINDER_CATEGORY_TRIAL then
for a,e in ipairs(n)do
if e[2]==true then t=t..h(e[1])end
end
local a=0
for t,e in ipairs(i)do
if e[2]==true then a=a+1 end
end
local o=""
if a==0 then
o=GetString("SI_GROUPFINDERCATEGORY_MULTISELECTDEFAULT",e)
else
o=zo_strformat(GetString("SI_GROUPFINDERCATEGORY_MULTISELECTSELECTIONS",e),a)
end
t=t..s(o)
else
t=t..s(GetString("SI_GROUPFINDERCATEGORY",e))
end
d(t)
SCENE_MANAGER:ShowBaseScene()
end
local function t()
local e=GROUP_FINDER_SEARCH_RESULTS_LIST_SCREEN_GAMEPAD
if not e or not e.resultsList.AddUniversalKeybind then
return
end
local e=e.resultsList
for a,t in ipairs(e.universalKeybindDescriptors or{})do
if t.keybind=="UI_SHORTCUT_QUATERNARY"then return end
end
e:AddUniversalKeybind({
name=function()
return GetString(SI_SOCIAL_OPTIONS_ALERTS)
end,
keybind="UI_SHORTCUT_QUATERNARY",
callback=function()
v()
c()
end,
visible=function()
return true
end,
alignment=KEYBIND_STRIP_ALIGN_LEFT,
ethereal=false,
})
e:UpdateKeybinds()
end
local function i()
local e=SCENE_MANAGER:GetScene("group_finder_gamepad_list")
if not e then
return
end
t()
e:RegisterCallback("StateChange",function(t,e)
if e==SCENE_SHOWING and o then
u()
end
end)
end
local function e(t,e)
if e~=a then return end
EVENT_MANAGER:UnregisterForEvent(a,EVENT_ADD_ON_LOADED)
i()
end
EVENT_MANAGER:RegisterForEvent(a,EVENT_ADD_ON_LOADED,e)
