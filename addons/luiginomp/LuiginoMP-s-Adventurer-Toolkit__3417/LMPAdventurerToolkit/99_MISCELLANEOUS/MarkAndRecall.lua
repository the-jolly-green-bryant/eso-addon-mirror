MARK_AND_RECALL = {}
local systemName = "Mark and Recall"
function MARK_AND_RECALL.GetName() return systemName end

function MARK_AND_RECALL.GetSavedNodeInfo()
    if MAIN.characterVariables.savedNodeIndex == nil then
        d("No fast travel node saved.")
    else
        local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(MAIN.characterVariables.savedNodeIndex)
        d(zo_strformat("Saved fast travel node: <<1>> (<<2>>).", MAIN.characterVariables.savedNodeIndex, name))
    end
end

function MARK_AND_RECALL.SetSavedNodeByIndex(index)
    local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(index)
    local isOutboundOnly, errorStringId = GetFastTravelNodeOutboundOnlyInfo(index)
    if known == true and isOutboundOnly == false then
        MAIN.characterVariables.savedNodeIndex = index
    else
        local isKnown = ""
        if known == true then isKnown = "Discovered"
        elseif known == false then isKnown = "Undiscovered"
        else isKnown = known end
        local outBoundOnly = ""
        if isOutboundOnly == true then outBoundOnly = "Outbound Only"
        elseif isOutboundOnly == false then outBoundOnly = "Two-Way"
        else outBoundOnly = isOutboundOnly end
        d(zo_strformat("ERROR: Can't save fast travel node <<1>> (<<2>>). <<3>>. <<4>>.", index, name, isKnown, outBoundOnly))
        SOUNDS.PlayError()
    end
    MARK_AND_RECALL.GetSavedNodeInfo()
end

function MARK_AND_RECALL.SetSavedNodeByName(nodeName)
    local indexFound = false
    for index = 1, GetNumFastTravelNodes() do
        local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(index)
        if zo_strformat("<<1>>",nodeName) == zo_strformat("<<1>>", name) then
            MARK_AND_RECALL.SetSavedNodeByIndex(index)
            indexFound = true
            break
        end
    end
    if indexFound == false then
        d("WARNING - could not find node index based on name: "..nodeName)
        SOUNDS.PlayError()
    end
end

function MARK_AND_RECALL.Initialize()
    if MAIN.characterVariables.savedNodeIndex == nil then
        for index = 1, GetNumFastTravelNodes() do
            local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfo(index)
            local isOutboundOnly, errorStringId = GetFastTravelNodeOutboundOnlyInfo(index)
            if known == true and isOutboundOnly == false then
                MARK_AND_RECALL.SetSavedNodeByIndex(index)
                break
            end
        end
        if MAIN.characterVariables.savedNodeIndex == nil then
            EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ZONE_CHANGED, function(eventCode, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
                local wayshrineInNameIndex = tostring(string.find(GetPlayerActiveSubzoneName(), "Wayshrine", 1, true))
                if wayshrineInNameIndex ~= nil and wayshrineInNameIndex > 0 then
                    MARK_AND_RECALL.SetSavedNodeByName(GetPlayerActiveSubzoneName())
                    EVENT_MANAGER:UnregisterForEvent(systemName, EVENT_ZONE_CHANGED)
                end
            end)
        end
    else MARK_AND_RECALL.SetSavedNodeByIndex(MAIN.characterVariables.savedNodeIndex) end
end

MAIN.AddToInitializeSystemsList(MARK_AND_RECALL)

--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_CURRENT_SUBZONE_LIST_CHANGED, function(eventCode) d("EVENT_CURRENT_SUBZONE_LIST_CHANGED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_MAP_PING, function(eventCode, pingEventType, pingType, pingTag, offsetX, offsetY, isLocalPlayerOwner) d("EVENT_MAP_PING") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_PLAYER_IN_PIN_AREA_CHANGED, function(eventCode, pinType, param1, param2, param3, playerIsInside) d("EVENT_PLAYER_IN_PIN_AREA_CHANGED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_POIS_INITIALIZED, function(eventCode) d("EVENT_POIS_INITIALIZED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_POI_DISCOVERED, function(eventCode, zoneIndex, poiIndex) d("EVENT_POI_DISCOVERED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_POI_UPDATED, function(eventCode, zoneIndex, poiIndex) d("EVENT_POI_UPDATED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_ZONE_UPDATE, function(eventCode, unitTag, newZoneName) d("EVENT_ZONE_UPDATE") end)

--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_END_FAST_TRAVEL_INTERACTION, function(eventCode) d("EVENT_END_FAST_TRAVEL_INTERACTION") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode) d("EVENT_END_FAST_TRAVEL_KEEP_INTERACTION") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED, function(eventCode, linkIndex, linkType, owningAlliance, oldLinkType, oldOwningAlliance, isLocal) d("EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED, function(eventCode) d("EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_FAST_TRAVEL_NETWORK_UPDATED, function(eventCode, nodeIndex) d("EVENT_FAST_TRAVEL_NETWORK_UPDATED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_JUMP_FAILED, function(eventCode, reason) d("EVENT_JUMP_FAILED") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_START_FAST_TRAVEL_INTERACTION, function(eventCode, nodeIndex) d("EVENT_START_FAST_TRAVEL_INTERACTION") end)
--EVENT_MANAGER:RegisterForEvent(systemName, EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function(eventCode, keepId) d("EVENT_START_FAST_TRAVEL_KEEP_INTERACTION") end)

SLASH_COMMANDS["/getmarked"] = function() MARK_AND_RECALL.GetSavedNodeInfo() end
SLASH_COMMANDS["/mark"] = function(info)
    if info == nil or info == "" then
        local wayshrineInNameIndex = tostring(string.find(GetPlayerActiveSubzoneName(), "Wayshrine", 1, true))
        if wayshrineInNameIndex == nil or wayshrineInNameIndex == 0 or wayshrineInNameIndex == "nil" or wayshrineInNameIndex == "0" then
            d("Failed to use mark - must be standing at a wayshrine.")
            SOUNDS.PlayError()
        else MARK_AND_RECALL.SetSavedNodeByName(GetPlayerActiveSubzoneName()) end
    else
        d("TODO: add functionality for mark to discern whether passed argument is index or name.")
        SOUNDS.PlayAlert()
    end
end
SLASH_COMMANDS["/recall"] = function()
    d("TODO: add recall functionality.")
    SOUNDS.PlayAlert()
end