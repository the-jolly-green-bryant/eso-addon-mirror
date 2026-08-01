RewardsForTheWorthy = {}

RewardsForTheWorthy.name = "RewardsForTheWorthy"
RewardsForTheWorthy.defaults = {}
local ITEMLINK_RFTW_GEODE = "|H1:item:134618:124:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"
local ITEMID_RFTW_GEODE = 134618
local HOURS_20 = 72000
local hasAlertedUser = false


function RewardsForTheWorthy:Initialize()
  EVENT_MANAGER:RegisterForEvent(RewardsForTheWorthy.name, EVENT_LOOT_RECEIVED, RewardsForTheWorthy.ReceivedLoot)
  EVENT_MANAGER:RegisterForUpdate(RewardsForTheWorthy.name.."Cycle", 60000, RewardsForTheWorthy.CheckGeodeReady)
end

function RewardsForTheWorthy.OnAddOnLoaded(event, addonName)
  if addonName ~= RewardsForTheWorthy.name then return end
  EVENT_MANAGER:UnregisterForEvent(RewardsForTheWorthy.name, EVENT_ADD_ON_LOADED, RewardsForTheWorthy.OnAddOnLoaded)

  RewardsForTheWorthy.savedVars = ZO_SavedVars:NewAccountWide("RFTWSavedVars", 2, nil, RewardsForTheWorthy.defaults, GetWorldName())
  SLASH_COMMANDS["/rftw"] = RewardsForTheWorthy.TimeUntilNextGeode

  RewardsForTheWorthy:Initialize()
end

function RewardsForTheWorthy.ReceivedLoot(eventCode, receivedBy, itemName, quantity, soundCategory, lootType, isMe, isPickpocketLoot, questItemIcon, itemId, isStolen)

  if not isMe then return end

  if(itemId == ITEMID_RFTW_GEODE) then
    CHAT_ROUTER:AddSystemMessage("A Rewards for the Worthy Geode was looted.")
    local now = GetTimeStamp()
    local nextGeode = now + HOURS_20 -- 20 hours
    RewardsForTheWorthy.savedVars.nextGeode = nextGeode
    hasAlertedUser = false
  end

end

function RewardsForTheWorthy.TimeUntilNextGeode() 
  local now = GetTimeStamp()
  local nextGeode = RewardsForTheWorthy.savedVars.nextGeode
  if(nextGeode == nil) then
    CHAT_ROUTER:AddSystemMessage("Error: Cannot track time left until you have looted your first geode from a Rewards for the Worthy coffer.")
    return
  end
  RewardsForTheWorthy.TimeDifference(now, nextGeode)
end

function RewardsForTheWorthy.TimeDifference(date1, date2)
  if (date1 == nil or date2 == nil) then return end
  if(date1 >= date2) then
    CHAT_ROUTER:AddSystemMessage("A Rewards for the Worthy Geode is now available.")
    return
  end

  local difference = date2 - date1;

  local hoursDifference = zo_floor(difference/60/60);
  difference = difference - hoursDifference*60*60

  local minutesDifference = zo_floor(difference/60);
  difference = difference - minutesDifference*60

  local secondsDifference = zo_floor(difference);

  CHAT_ROUTER:AddSystemMessage(string.format("%02d hours, %02d minutes, %02d seconds until the next geode.", hoursDifference, minutesDifference, secondsDifference))
end

function RewardsForTheWorthy.CheckGeodeReady()
  local now = GetTimeStamp()
  local nextGeode = RewardsForTheWorthy.savedVars.nextGeode
  if(nextGeode == nil) then return end
  if(now > nextGeode and hasAlertedUser == false) then
    CHAT_ROUTER:AddSystemMessage("A Rewards for the Worthy Geode is now available.")
    hasAlertedUser = true
  end
end

EVENT_MANAGER:RegisterForEvent(RewardsForTheWorthy.name, EVENT_ADD_ON_LOADED, RewardsForTheWorthy.OnAddOnLoaded)


-- |H1:item:134583:121:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h -- Green Transmutation Geode (Normal pledge)
-- |H1:item:134623:123:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h -- Purple Uncracked Transmutation Geode
-- |H1:item:134618:124:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h -- RFTW Gold Uncracked Transmutation Geode
-- |H1:item:134591:124:1:0:0:0:5:10000:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h -- Tier 1 Gold Transmutation Geode (50)

-- GetDiffBetweenTimeStamps(id64 laterTime, id64 earlierTime)