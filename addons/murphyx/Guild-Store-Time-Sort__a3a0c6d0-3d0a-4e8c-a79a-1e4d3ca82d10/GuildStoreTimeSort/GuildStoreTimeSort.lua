local t="GuildStoreTimeSort"
local function a()
if TRADING_HOUSE_SEARCH==nil or GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS==nil then return end
TRADING_HOUSE_SEARCH:ChangeSort(TRADING_HOUSE_SORT_TYPE_TIME,ZO_SORT_ORDER_DOWN)
local e=GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS.sortHeaderGroup
if e~=nil then
e.sortDirection=false
if e.sortHeaders[1]and e.sortHeaders[2]then
e:DeselectHeader(e.sortHeaders[2])
e:SelectHeader(e.sortHeaders[1])
end
end
end
local function o(o,e)
if e==t then
EVENT_MANAGER:UnregisterForEvent(t,EVENT_ADD_ON_LOADED)
a()
end
end
EVENT_MANAGER:RegisterForEvent(t,EVENT_ADD_ON_LOADED,o)
