local a={
name="HelloGoodbye",
}
local e=false
local function o(t)
local a=HOUSE_TOURS_SEARCH_MANAGER:GetSearchState(HOUSE_TOURS_LISTING_TYPE_BROWSE)
local i=GetFrameTimeMilliseconds()-t
if a==ZO_HOUSE_TOURS_SEARCH_STATES.COMPLETE then
e=false
local e=HOUSE_TOURS_SEARCH_MANAGER:GetSearchResults(HOUSE_TOURS_LISTING_TYPE_BROWSE)
if e and#e>0 then
local t=e[math.random(#e)]
local e=t:GetOwnerDisplayName()
local t=t:GetHouseId()
if e and t then
HOUSING_SOCIAL_MANAGER:VisitHouse(t,e,FROM_HOUSE_TOURS)
else
end
else
end
elseif a==ZO_HOUSE_TOURS_SEARCH_STATES.FAILED then
e=false
elseif i>=5000 then
e=false
else
zo_callLater(function()o(t)end,100)
end
end
local function i(a)
local t=HOUSE_TOURS_SEARCH_MANAGER:GetSearchFilters(HOUSE_TOURS_LISTING_TYPE_BROWSE)
if not t then
return
end
t:ResetFilters()
t:SetHouseIds({a})
HOUSE_TOURS_SEARCH_MANAGER:ExecuteSearch(HOUSE_TOURS_LISTING_TYPE_BROWSE)
if not e then
e=true
local e=GetFrameTimeMilliseconds()
zo_callLater(function()o(e)end,100)
end
end
local function o()
local e=ZO_MapPin.PIN_CLICK_HANDLERS and ZO_MapPin.PIN_CLICK_HANDLERS[MOUSE_BUTTON_INDEX_LEFT]
if not e then
return
end
local e=e[MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE]
if not e or not e[3]then
return
end
local t=e[3].GetDynamicHandlers
if not t then
return
end
e[3].GetDynamicHandlers=function(e,...)
local t=t(e,...)or{}
if e then
local e=e:GetFastTravelNodeIndex()
local o,a=GetFastTravelNodeInfo(e)
local e=GetFastTravelNodeHouseId(e)
if e and e~=0 then
table.insert(t,1,{
name=function()return"Travel via Home Tours"end,
callback=function()i(e)end,
show=function()return true end,
gamepadName=GetString(SI_GAMEPAD_WORLD_MAP_INTERACT_CHOOSE_DESTINATION),
gamepadPinActionGroup=ZO_WORLD_MAP_GAMEPAD_PIN_ACTION_GROUP_FAST_TRAVEL,
gamepadChoiceOverrideName=function()
return a.." ("..GetString(SI_ACTIVITY_FINDER_CATEGORY_HOUSE_TOURS)..")"
end,
})
end
end
return t
end
end
local function t()
local e=GetFastTravelNodeInfo
function GetFastTravelNodeInfo(...)
local e={e(...)}
if e[7]==POI_TYPE_HOUSE and e[1]==false then
e[1]=true
e[5]="/esoui/art/icons/poi/poi_group_house_unowned.dds"
end
return unpack(e)
end
end
local function e(i,e)
if e==a.name then
EVENT_MANAGER:UnregisterForEvent(a.name,EVENT_ADD_ON_LOADED)
o()
t()
end
end
EVENT_MANAGER:RegisterForEvent(a.name,EVENT_ADD_ON_LOADED,e)
