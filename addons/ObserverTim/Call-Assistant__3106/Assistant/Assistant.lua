-- Assistant, by ObserverTim

local Usable = IsCollectibleUsable
local UseIt  = UseCollectible
local Using  = IsCollectibleActive

local function MakeAssistantList()
  SLASH_COMMANDS["/assistants"] = function() MakeAssistantList() end

  for ix=1,GetTotalCollectiblesByCategoryType(27) do -- Companions
    local collId = GetCollectibleIdFromType(27,ix)
	local collName = "/"..string.match(string.lower(GetCollectibleName(collId)),"[%a-]+")
	if IsCollectibleUsable(collId) then
      SLASH_COMMANDS[collName] = function() UseCollectible(collId) end
	  d(collName)
	end
  end
  for ix=1,GetTotalCollectiblesByCategoryType(8) do -- assistnts
    local collId = GetCollectibleIdFromType(8,ix)
	local collName = "/"..string.match(string.lower(GetCollectibleName(collId)),"[%a-]+")
	if collName == "/baron" then collName = "/jangleplume" end
	if IsCollectibleUsable(collId) then
      SLASH_COMMANDS[collName] = function() UseCollectible(collId) end
	  d(collName)
	end
  end
  EVENT_MANAGER:UnregisterForEvent("Assistant",EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("Assistant", EVENT_ADD_ON_LOADED, MakeAssistantList)
