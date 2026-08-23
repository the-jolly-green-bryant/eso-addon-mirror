-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.Travel = EPC.Travel or {}
local T = EPC.Travel

T.PAGE_SIZE = 6
T.BOOK_PAGE_SIZE = 10
T.modeOrder = {"SHRINES", "FRIENDS", "GUILD", "GROUP"}
T.modeLabels = {
    SHRINES = "Wayshrines",
    FRIENDS = "Friends",
    GUILD = "Guild",
    GROUP = "Group",
}

local function safeNumber(value, fallback)
    value = tonumber(value)
    if value == nil then return fallback or 0 end
    return value
end

local function clean(value, fallback)
    value = tostring(value or "")
    value = string.gsub(value, "[%c]+", " ")
    value = string.gsub(value, "%s+", " ")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    if value == "" then return fallback or "" end
    return value
end

local function lower(value)
    return string.lower(clean(value, ""))
end

local function formatNumber(value)
    local number = math.floor(safeNumber(value, 0))
    local sign = number < 0 and "-" or ""
    local digits = tostring(math.abs(number))
    local parts = {}

    while #digits > 3 do
        table.insert(parts, 1, string.sub(digits, -3))
        digits = string.sub(digits, 1, -4)
    end
    table.insert(parts, 1, digits)
    return sign .. table.concat(parts, ",")
end

local function isOnlineStatus(playerStatus, secsSinceLogoff)
    if PLAYER_STATUS_OFFLINE ~= nil then
        return playerStatus ~= PLAYER_STATUS_OFFLINE
    end
    return safeNumber(secsSinceLogoff, 1) == 0
end

local function currentZoneFirstSort(a, b)
    if a.isCurrentZone ~= b.isCurrentZone then
        return a.isCurrentZone == true
    end

    local zoneA = lower(a.zoneName)
    local zoneB = lower(b.zoneName)
    if zoneA ~= zoneB then return zoneA < zoneB end

    local nameA = lower(a.name)
    local nameB = lower(b.name)
    if nameA ~= nameB then return nameA < nameB end

    return lower(a.key) < lower(b.key)
end

local function getCurrentMapIdSafe()
    if type(GetCurrentMapId) ~= "function" then return 0 end
    local ok, mapId = pcall(GetCurrentMapId)
    if not ok then return 0 end
    return safeNumber(mapId, 0)
end

local function getZoneIdentity(zoneIndex)
    local numericZoneIndex = safeNumber(zoneIndex, 0)
    local zoneId = 0

    if numericZoneIndex > 0 and type(GetZoneId) == "function" then
        local ok, returnedZoneId = pcall(GetZoneId, numericZoneIndex)
        if ok then zoneId = safeNumber(returnedZoneId, 0) end
    end

    local parentZoneId = zoneId
    if zoneId > 0 and type(GetParentZoneId) == "function" then
        local ok, returnedParentZoneId = pcall(GetParentZoneId, zoneId)
        if ok and safeNumber(returnedParentZoneId, 0) > 0 then
            parentZoneId = safeNumber(returnedParentZoneId, zoneId)
        end
    end

    return zoneId, parentZoneId
end

local function zonesMatch(entry, quest)
    if not entry or not quest then return false end

    local entryZoneIndex = safeNumber(entry.zoneIndex, 0)
    local questZoneIndex = safeNumber(quest.zoneIndex, 0)
    if entryZoneIndex > 0 and questZoneIndex > 0 and entryZoneIndex == questZoneIndex then
        return true
    end

    local entryZoneId = safeNumber(entry.zoneId, 0)
    local questZoneId = safeNumber(quest.zoneId, 0)
    if entryZoneId > 0 and questZoneId > 0 and entryZoneId == questZoneId then
        return true
    end

    local entryParent = safeNumber(entry.parentZoneId, 0)
    local questParent = safeNumber(quest.parentZoneId, 0)
    if entryParent > 0 and questZoneId > 0 and entryParent == questZoneId then
        return true
    end
    if questParent > 0 and entryZoneId > 0 and questParent == entryZoneId then
        return true
    end

    local entryZoneName = lower(entry.zoneName)
    local questZoneName = lower(quest.zoneName)
    return entryZoneName ~= "" and questZoneName ~= "" and entryZoneName == questZoneName
end

local function questAwareWayshrineSort(a, b)
    local distanceA = tonumber(a.questDistance)
    local distanceB = tonumber(b.questDistance)

    if distanceA ~= nil and distanceB ~= nil then
        if math.abs(distanceA - distanceB) > 0.0000001 then
            return distanceA < distanceB
        end
    elseif distanceA ~= nil or distanceB ~= nil then
        return distanceA ~= nil
    end

    if a.isQuestZone ~= b.isQuestZone then
        return a.isQuestZone == true
    end

    return currentZoneFirstSort(a, b)
end

local function getJumpAvailability(zoneId)
    if type(CanJumpToPlayerInZone) ~= "function" or safeNumber(zoneId, 0) <= 0 then
        return true, nil
    end

    local ok, canJump, result = pcall(CanJumpToPlayerInZone, zoneId)
    if not ok then return true, nil end
    return canJump == true, result
end

local function jumpResultText(result)
    if JUMP_TO_PLAYER_RESULT_PLAYER_OFFLINE ~= nil and result == JUMP_TO_PLAYER_RESULT_PLAYER_OFFLINE then
        return "Player is offline"
    elseif JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED ~= nil and result == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
        return "Zone access required"
    elseif JUMP_TO_PLAYER_RESULT_SOLO_ZONE ~= nil and result == JUMP_TO_PLAYER_RESULT_SOLO_ZONE then
        return "Solo-only destination"
    elseif JUMP_TO_PLAYER_RESULT_PLAYER_DIFFICULTY_LOCKED ~= nil and result == JUMP_TO_PLAYER_RESULT_PLAYER_DIFFICULTY_LOCKED then
        return "Difficulty mismatch"
    elseif JUMP_TO_PLAYER_RESULT_CROSS_ALLIANCE_LOCKED ~= nil and result == JUMP_TO_PLAYER_RESULT_CROSS_ALLIANCE_LOCKED then
        return "Alliance restriction"
    elseif JUMP_TO_PLAYER_RESULT_GENERIC_FAILURE ~= nil and result == JUMP_TO_PLAYER_RESULT_GENERIC_FAILURE then
        return "Travel unavailable"
    end
    return "ESO currently blocks travel"
end

function T:Initialize()
    self.selectedKey = nil
    self.lastView = nil
    self.lastFocusedQuestKey = nil
    self.questPositionCache = {}
    self.questPositionRequests = {}
    self.questPendingKeys = {}
end

function T:InvalidateQuestPositionCache()
    self.questPositionCache = {}
    self.questPositionRequests = {}
    self.questPendingKeys = {}
end

function T:FindQuestCondition(questIndex)
    if type(GetJournalQuestNumSteps) ~= "function" or type(GetJournalQuestNumConditions) ~= "function" then
        return nil, nil
    end

    local stepsOk, numSteps = pcall(GetJournalQuestNumSteps, questIndex)
    if not stepsOk then return nil, nil end
    numSteps = safeNumber(numSteps, 0)

    local fallbackStep = nil
    local fallbackCondition = nil

    for stepIndex = 1, numSteps do
        local conditionsOk, numConditions = pcall(GetJournalQuestNumConditions, questIndex, stepIndex)
        if conditionsOk then
            numConditions = safeNumber(numConditions, 0)
            for conditionIndex = 1, numConditions do
                if not fallbackStep then
                    fallbackStep = stepIndex
                    fallbackCondition = conditionIndex
                end

                if type(GetJournalQuestConditionValues) == "function" then
                    local valuesOk, _, _, isFailCondition, isComplete, _, isVisible = pcall(
                        GetJournalQuestConditionValues,
                        questIndex,
                        stepIndex,
                        conditionIndex
                    )
                    if valuesOk and isVisible == true and not isFailCondition and not isComplete then
                        return stepIndex, conditionIndex
                    end
                end
            end
        end
    end

    return fallbackStep, fallbackCondition
end

function T:RequestFocusedQuestPosition(quest)
    if not quest or not quest.positionKey then return end
    if self.questPositionCache[quest.positionKey] or self.questPendingKeys[quest.positionKey] then return end

    if type(RequestJournalQuestConditionAssistance) ~= "function" then
        self.questPositionCache[quest.positionKey] = { available = false }
        return
    end

    local ok, taskId = pcall(
        RequestJournalQuestConditionAssistance,
        quest.questIndex,
        quest.stepIndex,
        quest.conditionIndex
    )

    if ok and taskId ~= nil then
        self.questPositionRequests[taskId] = quest.positionKey
        self.questPendingKeys[quest.positionKey] = taskId
    else
        -- Do not repeatedly request a condition that ESO says has no map position.
        self.questPositionCache[quest.positionKey] = { available = false }
    end
end

function T:OnQuestPositionRequestComplete(taskId, pinType, xLoc, yLoc, areaRadius, insideCurrentMapWorld, isBreadcrumb, teleportNPCId, waypointId, symbolicState, additionalSymbolicLocX, additionalSymbolicLocY)
    local positionKey = self.questPositionRequests and self.questPositionRequests[taskId]
    if not positionKey then return end

    self.questPositionRequests[taskId] = nil
    self.questPendingKeys[positionKey] = nil

    local x = tonumber(xLoc)
    local y = tonumber(yLoc)
    local exact = insideCurrentMapWorld == true
        and x ~= nil and y ~= nil
        and x >= 0 and x <= 1
        and y >= 0 and y <= 1

    self.questPositionCache[positionKey] = {
        available = exact,
        x = x,
        y = y,
        insideCurrentMapWorld = insideCurrentMapWorld == true,
        isBreadcrumb = isBreadcrumb == true,
        symbolicState = symbolicState,
    }

    if EPC.saved and EPC.saved.activeTab == "MAP" then
        EPC.saved.travelPage = 1
        EPC.saved.travelBookPage = 1
        EPC:RequestRefresh("quest-position")
    end
end

function T:GetFocusedQuest(snapshot)
    if type(GetNumTracked) ~= "function"
        or type(GetTrackedByIndex) ~= "function"
        or type(GetTrackedIsAssisted) ~= "function"
        or TRACK_TYPE_QUEST == nil then
        return nil
    end

    local countOk, numTracked = pcall(GetNumTracked)
    if not countOk then return nil end
    numTracked = safeNumber(numTracked, 0)

    for trackedIndex = 1, numTracked do
        local trackedOk, trackType, param1, param2 = pcall(GetTrackedByIndex, trackedIndex)
        if trackedOk and trackType == TRACK_TYPE_QUEST then
            local assistedOk, assisted = pcall(GetTrackedIsAssisted, trackType, param1, param2)
            if assistedOk and assisted == true then
                local questIndex = safeNumber(param1, 0)
                if questIndex > 0 then
                    local questName = "Focused quest"
                    if type(GetJournalQuestName) == "function" then
                        local nameOk, returnedQuestName = pcall(GetJournalQuestName, questIndex)
                        if nameOk then questName = clean(returnedQuestName, questName) end
                    end

                    local zoneName = "Unknown zone"
                    local objectiveName = "Current objective"
                    local zoneIndex = 0
                    local poiIndex = 0
                    if type(GetJournalQuestLocationInfo) == "function" then
                        local locationOk, returnedZoneName, returnedObjectiveName, returnedZoneIndex, returnedPoiIndex = pcall(
                            GetJournalQuestLocationInfo,
                            questIndex
                        )
                        if locationOk then
                            zoneName = clean(returnedZoneName, zoneName)
                            objectiveName = clean(returnedObjectiveName, objectiveName)
                            zoneIndex = safeNumber(returnedZoneIndex, 0)
                            poiIndex = safeNumber(returnedPoiIndex, 0)
                        end
                    end

                    local zoneId, parentZoneId = getZoneIdentity(zoneIndex)
                    local stepIndex, conditionIndex = self:FindQuestCondition(questIndex)
                    local identityKey = string.format(
                        "%d:%d:%d",
                        questIndex,
                        safeNumber(stepIndex, 0),
                        safeNumber(conditionIndex, 0)
                    )

                    local quest = {
                        questIndex = questIndex,
                        name = questName,
                        objectiveName = objectiveName,
                        zoneName = zoneName,
                        zoneIndex = zoneIndex,
                        zoneId = zoneId,
                        parentZoneId = parentZoneId,
                        poiIndex = poiIndex,
                        stepIndex = stepIndex,
                        conditionIndex = conditionIndex,
                        identityKey = identityKey,
                    }

                    if stepIndex and conditionIndex then
                        quest.positionKey = string.format(
                            "%s:%d",
                            identityKey,
                            getCurrentMapIdSafe()
                        )
                        quest.position = self.questPositionCache[quest.positionKey]
                        if not quest.position then
                            self:RequestFocusedQuestPosition(quest)
                            quest.position = self.questPositionCache[quest.positionKey]
                        end
                    end

                    return quest
                end
            end
        end
    end

    return nil
end

function T:GetMode()
    local mode = EPC.saved and EPC.saved.travelMode or "SHRINES"
    if not self.modeLabels[mode] then
        mode = "SHRINES"
        if EPC.saved then EPC.saved.travelMode = mode end
    end
    return mode
end

function T:SetMode(mode)
    if not self.modeLabels[mode] then return end
    EPC.saved.travelMode = mode
    EPC.saved.travelPage = 1
    EPC.saved.travelBookPage = 1
    self.selectedKey = nil
    EPC:RefreshNow("travel-mode")
end

function T:GetPageSize(pageSize)
    pageSize = math.floor(safeNumber(pageSize, self.PAGE_SIZE or 4))
    return math.max(1, math.min(12, pageSize))
end

function T:GetPageKey(pageSize)
    pageSize = self:GetPageSize(pageSize)
    if pageSize == (self.BOOK_PAGE_SIZE or 8) then return "travelBookPage" end
    return "travelPage"
end

function T:ChangePage(delta, pageSize)
    pageSize = self:GetPageSize(pageSize)
    local pageKey = self:GetPageKey(pageSize)
    local page = safeNumber(EPC.saved[pageKey], 1) + safeNumber(delta, 0)
    EPC.saved[pageKey] = math.max(1, page)
    self.selectedKey = nil
    EPC:RefreshNow("travel-page")
end

function T:SelectVisibleRow(rowIndex, pageSize)
    local view
    if pageSize ~= nil then
        local snapshot = EPC.lastSnapshot or (EPC.Engine and EPC.Engine:BuildSnapshot()) or {}
        view = self:BuildView(snapshot, pageSize)
    else
        view = self.lastView
    end
    local row = view and view.rows and view.rows[rowIndex]
    if not row then return end
    self.selectedKey = row.key
    EPC:RefreshNow("travel-selection")
end

function T:CanLeaveNow()
    if type(IsUnitInCombat) == "function" then
        local ok, inCombat = pcall(IsUnitInCombat, "player")
        if ok and inCombat then return false, "Unavailable in combat" end
    end

    if type(CanLeaveCurrentLocationViaTeleport) == "function" then
        local ok, canLeave = pcall(CanLeaveCurrentLocationViaTeleport)
        if ok and not canLeave then return false, "Travel blocked at this location" end
    end

    return true, "Ready"
end

-- Build a single discovered wayshrine entry using the same safety rules as the Travel page.
function T:GetWayshrineNodeEntry(nodeIndex)
    nodeIndex = safeNumber(nodeIndex, 0)
    if nodeIndex <= 0 or type(GetFastTravelNodeInfo) ~= "function" then return nil end

    local ok, known, name, normalizedX, normalizedY, _, _, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = pcall(
        GetFastTravelNodeInfo,
        nodeIndex
    )
    local isWayshrine = POI_TYPE_WAYSHRINE == nil or poiType == POI_TYPE_WAYSHRINE
    if not ok or not known or not isWayshrine or linkedCollectibleIsLocked then return nil end

    if type(GetFastTravelNodeOutboundOnlyInfo) == "function" then
        local outboundOk, outbound = pcall(GetFastTravelNodeOutboundOnlyInfo, nodeIndex)
        if outboundOk and outbound == true then return nil end
    end

    local zoneIndex = 0
    local poiIndexFunction = GetFastTravelNodePOIIndicies or GetFastTravelNodePOIIndices
    if type(poiIndexFunction) == "function" then
        local indicesOk, returnedZoneIndex = pcall(poiIndexFunction, nodeIndex)
        if indicesOk then zoneIndex = safeNumber(returnedZoneIndex, 0) end
    end

    local zoneName = "Unknown zone"
    if zoneIndex > 0 and type(GetZoneNameByIndex) == "function" then
        local zoneOk, returnedZoneName = pcall(GetZoneNameByIndex, zoneIndex)
        if zoneOk then zoneName = clean(returnedZoneName, zoneName) end
    end
    local zoneId, parentZoneId = getZoneIdentity(zoneIndex)

    local cost = 0
    if type(GetRecallCost) == "function" then
        local costOk, returnedCost = pcall(GetRecallCost, nodeIndex)
        if costOk then cost = safeNumber(returnedCost, 0) end
    end

    local currency = CURT_MONEY
    if type(GetRecallCurrency) == "function" then
        local currencyOk, returnedCurrency = pcall(GetRecallCurrency, nodeIndex)
        if currencyOk and returnedCurrency ~= nil then currency = returnedCurrency end
    end

    local canAfford = true
    if cost > 0 and type(GetCurrencyAmount) == "function" and CURRENCY_LOCATION_CHARACTER ~= nil then
        local amountOk, amount = pcall(GetCurrencyAmount, currency, CURRENCY_LOCATION_CHARACTER)
        if amountOk then canAfford = safeNumber(amount, 0) >= cost end
    end

    local canLeave, leaveReason = self:CanLeaveNow()
    local costText
    if cost <= 0 then
        costText = "Free"
    elseif currency == CURT_MONEY or currency == nil then
        costText = formatNumber(cost) .. " gold"
    else
        costText = "Cost " .. formatNumber(cost)
    end

    local statusText = leaveReason
    if canLeave and not canAfford then statusText = "Not enough currency" end

    return {
        kind = "SHRINE",
        key = "S:" .. tostring(nodeIndex),
        nodeIndex = nodeIndex,
        name = clean(name, "Unnamed wayshrine"),
        zoneName = zoneName,
        zoneIndex = zoneIndex,
        zoneId = zoneId,
        parentZoneId = parentZoneId,
        normalizedX = tonumber(normalizedX),
        normalizedY = tonumber(normalizedY),
        isShownInCurrentMap = isShownInCurrentMap == true,
        cost = cost,
        costText = costText,
        statusText = statusText,
        canTravel = canLeave and canAfford,
    }
end

-- Find the nearest discovered wayshrine to a saved checkpoint. ESO exposes fast-travel
-- node coordinates relative to the current map, so this temporarily evaluates the
-- checkpoint's saved map, then restores the map that was active beforehand.
function T:GetNearestWayshrineToCheckpoint(checkpoint)
    if type(checkpoint) ~= "table" then return nil, false end
    local targetX, targetY = tonumber(checkpoint.x), tonumber(checkpoint.y)
    if not targetX or not targetY or targetX <= 0 or targetY <= 0 then return nil, false end

    local originalMapId = getCurrentMapIdSafe()
    local originalMapIndex = 0
    if type(GetCurrentMapIndex) == "function" then
        local ok, value = pcall(GetCurrentMapIndex)
        if ok then originalMapIndex = safeNumber(value, 0) end
    end

    local desiredMapId = safeNumber(checkpoint.mapId, 0)
    local desiredMapIndex = safeNumber(checkpoint.mapIndex, 0)
    local switched = false
    local comparableMapReady = true
    if desiredMapId > 0 and type(SetMapToMapId) == "function" and desiredMapId ~= originalMapId then
        pcall(SetMapToMapId, desiredMapId)
        comparableMapReady = getCurrentMapIdSafe() == desiredMapId
        switched = comparableMapReady
    elseif desiredMapIndex > 0 and type(SetMapToMapListIndex) == "function" and desiredMapIndex ~= originalMapIndex then
        pcall(SetMapToMapListIndex, desiredMapIndex)
        local currentMapIndex = 0
        if type(GetCurrentMapIndex) == "function" then
            local ok, value = pcall(GetCurrentMapIndex)
            if ok then currentMapIndex = safeNumber(value, 0) end
        end
        comparableMapReady = currentMapIndex == desiredMapIndex
        switched = comparableMapReady
    end

    local total = 0
    if type(GetNumFastTravelNodes) == "function" then
        local ok, count = pcall(GetNumFastTravelNodes)
        if ok then total = safeNumber(count, 0) end
    end

    local best, bestDistance = nil, nil
    local sameZoneFallback = nil
    local checkpointZoneId = safeNumber(checkpoint.zoneId, 0)
    local checkpointZoneName = lower(checkpoint.zone or checkpoint.mapName or "")

    for nodeIndex = 1, total do
        local entry = self:GetWayshrineNodeEntry(nodeIndex)
        if entry then
            local sameZone = false
            if checkpointZoneId > 0 then
                sameZone = entry.zoneId == checkpointZoneId or entry.parentZoneId == checkpointZoneId
            end
            if not sameZone and checkpointZoneName ~= "" then
                sameZone = lower(entry.zoneName) == checkpointZoneName
            end
            if sameZone and sameZoneFallback == nil then sameZoneFallback = entry end

            if comparableMapReady and entry.isShownInCurrentMap and entry.normalizedX and entry.normalizedY then
                local dx = entry.normalizedX - targetX
                local dy = entry.normalizedY - targetY
                local distance = (dx * dx) + (dy * dy)
                if bestDistance == nil or distance < bestDistance then
                    best = entry
                    bestDistance = distance
                end
            end
        end
    end

    if switched then
        if originalMapId > 0 and type(SetMapToMapId) == "function" then
            pcall(SetMapToMapId, originalMapId)
        elseif originalMapIndex > 0 and type(SetMapToMapListIndex) == "function" then
            pcall(SetMapToMapListIndex, originalMapIndex)
        end
    end

    if best then
        best.checkpointDistanceSquared = bestDistance
        best.exactCheckpointMapMatch = true
        return best, true
    end
    if sameZoneFallback then
        sameZoneFallback.exactCheckpointMapMatch = false
        return sameZoneFallback, false
    end
    return nil, false
end

function T:TravelToWayshrineNode(nodeIndex, displayName)
    local entry = self:GetWayshrineNodeEntry(nodeIndex)
    if not entry then
        EPC:Print("That wayshrine is no longer available or has not been discovered.")
        return false
    end
    if not entry.canTravel then
        EPC:Print(entry.statusText or "ESO currently blocks travel to that wayshrine.")
        return false
    end
    if type(FastTravelToNode) ~= "function" then
        EPC:Print("Fast-travel API is unavailable.")
        return false
    end
    EPC:Print("Traveling to " .. clean(displayName or entry.name, entry.name) .. ".")
    local ok = pcall(FastTravelToNode, entry.nodeIndex)
    if not ok then
        EPC:Print("ESO rejected the travel request. Try the normal World Map.")
        return false
    end
    return true
end

function T:GetWayshrines(snapshot)
    local entries = {}
    local currentZone = lower(snapshot and snapshot.zoneName or "")
    local focusedQuest = self:GetFocusedQuest(snapshot)
    local canLeave, leaveReason = self:CanLeaveNow()
    local total = 0

    if type(GetNumFastTravelNodes) == "function" then
        local ok, count = pcall(GetNumFastTravelNodes)
        if ok then total = safeNumber(count, 0) end
    end

    local poiIndexFunction = GetFastTravelNodePOIIndicies or GetFastTravelNodePOIIndices

    for nodeIndex = 1, total do
        local ok, known, name, normalizedX, normalizedY, _, _, poiType, isShownInCurrentMap, linkedCollectibleIsLocked = pcall(
            GetFastTravelNodeInfo,
            nodeIndex
        )
        local isWayshrine = POI_TYPE_WAYSHRINE == nil or poiType == POI_TYPE_WAYSHRINE

        if ok and known and isWayshrine and not linkedCollectibleIsLocked then
            local isOutboundOnly = false
            if type(GetFastTravelNodeOutboundOnlyInfo) == "function" then
                local outboundOk, outbound = pcall(GetFastTravelNodeOutboundOnlyInfo, nodeIndex)
                if outboundOk then isOutboundOnly = outbound == true end
            end

            if not isOutboundOnly then
                local zoneIndex = 0
                if type(poiIndexFunction) == "function" then
                    local indicesOk, returnedZoneIndex = pcall(poiIndexFunction, nodeIndex)
                    if indicesOk then zoneIndex = safeNumber(returnedZoneIndex, 0) end
                end

                local zoneName = "Unknown zone"
                if zoneIndex > 0 and type(GetZoneNameByIndex) == "function" then
                    local zoneOk, returnedZoneName = pcall(GetZoneNameByIndex, zoneIndex)
                    if zoneOk then zoneName = clean(returnedZoneName, zoneName) end
                end

                local zoneId, parentZoneId = getZoneIdentity(zoneIndex)
                local cost = 0
                if type(GetRecallCost) == "function" then
                    local costOk, returnedCost = pcall(GetRecallCost, nodeIndex)
                    if costOk then cost = safeNumber(returnedCost, 0) end
                end

                local currency = CURT_MONEY
                if type(GetRecallCurrency) == "function" then
                    local currencyOk, returnedCurrency = pcall(GetRecallCurrency, nodeIndex)
                    if currencyOk and returnedCurrency ~= nil then currency = returnedCurrency end
                end

                local canAfford = true
                if cost > 0 and type(GetCurrencyAmount) == "function" and CURRENCY_LOCATION_CHARACTER ~= nil then
                    local amountOk, amount = pcall(GetCurrencyAmount, currency, CURRENCY_LOCATION_CHARACTER)
                    if amountOk then canAfford = safeNumber(amount, 0) >= cost end
                end

                local costText
                if cost <= 0 then
                    costText = "Free"
                elseif currency == CURT_MONEY or currency == nil then
                    costText = formatNumber(cost) .. " gold"
                else
                    costText = "Cost " .. formatNumber(cost)
                end

                local statusText = leaveReason
                if canLeave and not canAfford then statusText = "Not enough currency" end

                local shrineName = clean(name, "Unnamed wayshrine")
                local entry = {
                    kind = "SHRINE",
                    key = "S:" .. tostring(nodeIndex),
                    nodeIndex = nodeIndex,
                    name = shrineName,
                    zoneName = zoneName,
                    zoneIndex = zoneIndex,
                    zoneId = zoneId,
                    parentZoneId = parentZoneId,
                    normalizedX = tonumber(normalizedX),
                    normalizedY = tonumber(normalizedY),
                    isShownInCurrentMap = isShownInCurrentMap == true,
                    displayText = shrineName .. " - " .. zoneName,
                    costText = costText,
                    statusText = statusText,
                    canTravel = canLeave and canAfford,
                    isCurrentZone = currentZone ~= "" and lower(zoneName) == currentZone,
                }

                entry.isQuestZone = zonesMatch(entry, focusedQuest)

                local questPosition = focusedQuest and focusedQuest.position or nil
                if entry.isQuestZone
                    and questPosition and questPosition.available == true
                    and entry.isShownInCurrentMap
                    and entry.normalizedX ~= nil and entry.normalizedY ~= nil then
                    local deltaX = entry.normalizedX - questPosition.x
                    local deltaY = entry.normalizedY - questPosition.y
                    entry.questDistance = (deltaX * deltaX) + (deltaY * deltaY)
                end

                entries[#entries + 1] = entry
            end
        end
    end

    if focusedQuest then
        table.sort(entries, questAwareWayshrineSort)
    else
        table.sort(entries, currentZoneFirstSort)
    end

    local bestQuestShrine = nil
    if focusedQuest then
        for i = 1, #entries do
            local entry = entries[i]
            if entry.questDistance ~= nil or entry.isQuestZone then
                bestQuestShrine = entry
                break
            end
        end
    end

    if bestQuestShrine then
        bestQuestShrine.isQuestBest = true
        bestQuestShrine.displayText = "QUEST BEST - " .. bestQuestShrine.name .. " - " .. bestQuestShrine.zoneName
    end

    return entries, focusedQuest, bestQuestShrine
end

function T:GetFriends(snapshot)
    local entries = {}
    local currentZone = lower(snapshot and snapshot.zoneName or "")
    local ownDisplayName = clean(type(GetDisplayName) == "function" and GetDisplayName() or "", "")
    local canLeave, leaveReason = self:CanLeaveNow()
    local count = 0

    if type(GetNumFriends) == "function" then
        local ok, returnedCount = pcall(GetNumFriends)
        if ok then count = safeNumber(returnedCount, 0) end
    end

    for friendIndex = 1, count do
        local infoOk, displayName, _, playerStatus, secsSinceLogoff = pcall(GetFriendInfo, friendIndex)
        displayName = clean(displayName, "")

        if infoOk and displayName ~= "" and displayName ~= ownDisplayName and isOnlineStatus(playerStatus, secsSinceLogoff) then
            local characterOk, hasCharacter, characterName, zoneName, _, _, _, _, zoneId = pcall(GetFriendCharacterInfo, friendIndex)
            if characterOk and hasCharacter then
                zoneName = clean(zoneName, "Unknown location")
                characterName = clean(characterName, displayName)
                local canJump, result = getJumpAvailability(zoneId)
                local ready = canLeave and canJump
                local statusText = not canLeave and leaveReason or (canJump and "Ready" or jumpResultText(result))

                entries[#entries + 1] = {
                    kind = "FRIEND",
                    key = "F:" .. lower(displayName),
                    name = displayName,
                    displayName = displayName,
                    characterName = characterName,
                    zoneName = zoneName,
                    zoneId = zoneId,
                    displayText = displayName .. " - " .. zoneName,
                    costText = "Free",
                    statusText = statusText,
                    canTravel = ready,
                    isCurrentZone = currentZone ~= "" and lower(zoneName) == currentZone,
                }
            end
        end
    end

    table.sort(entries, currentZoneFirstSort)
    return entries
end

function T:GetGuildMembers(snapshot)
    local entries = {}
    local seen = {}
    local currentZone = lower(snapshot and snapshot.zoneName or "")
    local ownDisplayName = clean(type(GetDisplayName) == "function" and GetDisplayName() or "", "")
    local canLeave, leaveReason = self:CanLeaveNow()
    local guildCount = 0

    if type(GetNumGuilds) == "function" then
        local ok, returnedCount = pcall(GetNumGuilds)
        if ok then guildCount = safeNumber(returnedCount, 0) end
    end

    for guildIndex = 1, guildCount do
        local guildId = nil
        local guildOk, returnedGuildId = pcall(GetGuildId, guildIndex)
        if guildOk then guildId = returnedGuildId end

        if guildId then
            local guildName = "Guild"
            if type(GetGuildName) == "function" then
                local nameOk, returnedGuildName = pcall(GetGuildName, guildId)
                if nameOk then guildName = clean(returnedGuildName, guildName) end
            end

            local memberCount = 0
            local countOk, returnedMemberCount = pcall(GetNumGuildMembers, guildId)
            if countOk then memberCount = safeNumber(returnedMemberCount, 0) end

            for memberIndex = 1, memberCount do
                local infoOk, displayName, _, _, playerStatus, secsSinceLogoff = pcall(GetGuildMemberInfo, guildId, memberIndex)
                displayName = clean(displayName, "")
                local dedupeKey = lower(displayName)

                if infoOk and displayName ~= "" and displayName ~= ownDisplayName and not seen[dedupeKey] and isOnlineStatus(playerStatus, secsSinceLogoff) then
                    local characterOk, hasCharacter, characterName, zoneName, _, _, _, _, zoneId = pcall(GetGuildMemberCharacterInfo, guildId, memberIndex)
                    if characterOk and hasCharacter then
                        seen[dedupeKey] = true
                        zoneName = clean(zoneName, "Unknown location")
                        characterName = clean(characterName, displayName)
                        local canJump, result = getJumpAvailability(zoneId)
                        local ready = canLeave and canJump
                        local statusText = not canLeave and leaveReason or (canJump and "Ready" or jumpResultText(result))

                        entries[#entries + 1] = {
                            kind = "GUILD",
                            key = "G:" .. dedupeKey,
                            name = displayName,
                            displayName = displayName,
                            characterName = characterName,
                            guildName = guildName,
                            zoneName = zoneName,
                            zoneId = zoneId,
                            displayText = displayName .. " - " .. zoneName,
                            costText = "Free",
                            statusText = statusText,
                            canTravel = ready,
                            isCurrentZone = currentZone ~= "" and lower(zoneName) == currentZone,
                        }
                    end
                end
            end
        end
    end

    table.sort(entries, currentZoneFirstSort)
    return entries
end

function T:GetGroupMembers(snapshot)
    local entries = {}
    local currentZone = lower(snapshot and snapshot.zoneName or "")
    local canLeave, leaveReason = self:CanLeaveNow()
    local groupSize = 0

    if type(GetGroupSize) == "function" then
        local ok, returnedSize = pcall(GetGroupSize)
        if ok then groupSize = safeNumber(returnedSize, 0) end
    end

    for sortIndex = 1, groupSize do
        local tagOk, unitTag = pcall(GetGroupUnitTagByIndex, sortIndex)
        local isSelf = false
        if tagOk and unitTag and type(AreUnitsEqual) == "function" then
            local equalOk, equal = pcall(AreUnitsEqual, unitTag, "player")
            if equalOk then isSelf = equal == true end
        end

        if tagOk and unitTag and unitTag ~= "" and not isSelf then
            local online = true
            if type(IsUnitOnline) == "function" then
                local onlineOk, returnedOnline = pcall(IsUnitOnline, unitTag)
                if onlineOk then online = returnedOnline == true end
            end

            if online then
                local displayName = ""
                if type(GetUnitDisplayName) == "function" then
                    local displayOk, returnedDisplayName = pcall(GetUnitDisplayName, unitTag)
                    if displayOk then displayName = clean(returnedDisplayName, "") end
                end

                local characterName = displayName
                if type(GetUnitName) == "function" then
                    local characterOk, returnedCharacterName = pcall(GetUnitName, unitTag)
                    if characterOk then characterName = clean(returnedCharacterName, displayName) end
                end

                local zoneName = "Unknown location"
                if type(GetUnitZone) == "function" then
                    local zoneOk, returnedZoneName = pcall(GetUnitZone, unitTag)
                    if zoneOk then zoneName = clean(returnedZoneName, zoneName) end
                end

                local canJump, result = true, nil
                if type(CanJumpToGroupMember) == "function" then
                    local jumpOk, returnedCanJump, returnedResult = pcall(CanJumpToGroupMember, unitTag)
                    if jumpOk then canJump, result = returnedCanJump == true, returnedResult end
                end

                local ready = canLeave and canJump
                local statusText = not canLeave and leaveReason or (canJump and "Ready" or jumpResultText(result))
                local name = displayName ~= "" and displayName or characterName

                entries[#entries + 1] = {
                    kind = "GROUP",
                    key = "P:" .. lower(name) .. ":" .. tostring(sortIndex),
                    name = name,
                    displayName = displayName,
                    characterName = characterName,
                    unitTag = unitTag,
                    zoneName = zoneName,
                    displayText = name .. " - " .. zoneName,
                    costText = "Free",
                    statusText = statusText,
                    canTravel = ready,
                    isCurrentZone = currentZone ~= "" and lower(zoneName) == currentZone,
                }
            end
        end
    end

    table.sort(entries, currentZoneFirstSort)
    return entries
end

function T:GetEntries(mode, snapshot)
    if mode == "FRIENDS" then
        return self:GetFriends(snapshot), nil, nil
    elseif mode == "GUILD" then
        return self:GetGuildMembers(snapshot), nil, nil
    elseif mode == "GROUP" then
        return self:GetGroupMembers(snapshot), nil, nil
    end
    return self:GetWayshrines(snapshot)
end

function T:BuildView(snapshot, pageSize)
    pageSize = self:GetPageSize(pageSize)
    local pageKey = self:GetPageKey(pageSize)
    local mode = self:GetMode()
    local entries, focusedQuest, bestQuestShrine = self:GetEntries(mode, snapshot)

    local focusedQuestKey = focusedQuest and focusedQuest.identityKey or ""
    if mode == "SHRINES" and focusedQuestKey ~= (self.lastFocusedQuestKey or "") then
        EPC.saved.travelPage = 1
        EPC.saved.travelBookPage = 1
        self.selectedKey = nil
        self.lastFocusedQuestKey = focusedQuestKey
    elseif mode ~= "SHRINES" then
        self.lastFocusedQuestKey = focusedQuestKey
    end

    local pageCount = math.max(1, math.ceil(#entries / pageSize))
    local page = EPC:Clamp(EPC.saved[pageKey] or 1, 1, pageCount)
    EPC.saved[pageKey] = page

    local selected = nil
    if self.selectedKey then
        for i = 1, #entries do
            if entries[i].key == self.selectedKey then
                selected = entries[i]
                break
            end
        end
    end
    if self.selectedKey and not selected then self.selectedKey = nil end

    local firstIndex = ((page - 1) * pageSize) + 1
    local rows = {}
    for i = 0, pageSize - 1 do
        local entry = entries[firstIndex + i]
        if entry then rows[#rows + 1] = entry end
    end

    local emptyText
    local hint
    local header = "MAP AND TRAVEL"
    local title = "Travel from " .. clean(snapshot and snapshot.zoneName, "Unknown zone")
    local discoveryTarget = EPC.saved and EPC.saved.questDiscoveryTarget or nil
    local description = "Choose a destination, select it, then press TRAVEL. Travel never starts automatically."

    if mode == "SHRINES" then
        emptyText = "No discovered wayshrines are available."

        if focusedQuest then
            header = "QUEST-AWARE TRAVEL"
            title = "Focused quest: " .. focusedQuest.name

            if bestQuestShrine and bestQuestShrine.questDistance ~= nil then
                description = string.format(
                    "%s is the nearest discovered wayshrine to the current objective by straight-line map distance. Terrain and entrances may make another route faster.",
                    bestQuestShrine.name
                )
                hint = "QUEST BEST is listed first. Select it, then press TRAVEL."
            elseif bestQuestShrine then
                description = string.format(
                    "%s is prioritized because it is in %s. ESO did not expose comparable objective coordinates, so this is zone-first rather than exact-distance ranking.",
                    bestQuestShrine.name,
                    focusedQuest.zoneName
                )
                hint = "QUEST BEST is the first discovered wayshrine in the focused quest's zone."
            else
                description = string.format(
                    "No discovered wayshrine was found in %s. Try FRIENDS, GUILD, or GROUP to reach someone already in that zone.",
                    focusedQuest.zoneName
                )
                hint = "Direct wayshrine travel requires a discovered node. Social travel may still reach the quest zone."
            end
        else
            hint = "Focus a quest to rank its nearest available wayshrine, or select any discovered destination below."
        end
    elseif mode == "FRIENDS" then
        emptyText = "No online friends were found."
        hint = "Travel to Player goes to the nearest wayshrine and may reach zones you have not visited. ESO access rules still apply."
    elseif mode == "GUILD" then
        emptyText = "No online guild members were found."
        hint = "Guild travel goes to the member's nearest wayshrine and may reach undiscovered zones. ESO access rules still apply."
    else
        emptyText = "No online group members were found."
        hint = "Group travel uses ESO's Travel to Player system and normally arrives at the nearest wayshrine. Access rules still apply."
    end

    local selectedDetails = nil
    if selected then
        selectedDetails = string.format("Selected: %s - %s. %s; %s.", selected.name, selected.zoneName, selected.costText, selected.statusText)
    end

    local stats
    if mode == "SHRINES" and focusedQuest then
        stats = {
            { label = "FOCUSED QUEST", value = focusedQuest.name },
            { label = "BEST SHRINE", value = bestQuestShrine and bestQuestShrine.name or "None discovered" },
            { label = "SELECTED", value = selected and selected.name or "Choose below" },
            { label = "STATUS", value = selected and (selected.costText .. " - " .. selected.statusText) or "Quest route ready" },
        }
    else
        stats = {
            { label = "TRAVEL MODE", value = self.modeLabels[mode] },
            { label = "AVAILABLE", value = tostring(#entries) },
            { label = "SELECTED", value = selected and selected.name or "Choose below" },
            { label = "STATUS", value = selected and (selected.costText .. " - " .. selected.statusText) or "Select a destination" },
        }
    end

    local view = {
        mode = mode,
        modeLabel = self.modeLabels[mode],
        header = header,
        title = title,
        description = description,
        entries = entries,
        rows = rows,
        selected = selected,
        focusedQuest = focusedQuest,
        bestQuestShrine = bestQuestShrine,
        page = page,
        pageCount = pageCount,
        pageSize = pageSize,
        canPageBack = page > 1,
        canPageForward = page < pageCount,
        actionEnabled = selected ~= nil and selected.canTravel == true,
        actionText = "TRAVEL",
        emptyText = emptyText,
        hint = selectedDetails or hint,
        stats = stats,
    }

    self.lastView = view
    return view
end

function T:TravelSelected()
    local snapshot = EPC.lastSnapshot or (EPC.Engine and EPC.Engine:BuildSnapshot())
    local view = self:BuildView(snapshot)
    local entry = view.selected

    if not entry then
        EPC:Print("Select a destination first.")
        return
    end

    local canLeave, leaveReason = self:CanLeaveNow()
    if not canLeave then
        EPC:Print(leaveReason .. ".")
        return
    end

    if not entry.canTravel then
        EPC:Print(entry.statusText or "ESO currently blocks this destination.")
        return
    end

    local travelFunction
    local travelArgument
    local unavailableMessage

    if entry.kind == "SHRINE" then
        travelFunction = FastTravelToNode
        travelArgument = entry.nodeIndex
        unavailableMessage = "Fast-travel API is unavailable."
    elseif entry.kind == "FRIEND" then
        travelFunction = JumpToFriend
        travelArgument = entry.displayName
        unavailableMessage = "Friend travel API is unavailable."
    elseif entry.kind == "GUILD" then
        travelFunction = JumpToGuildMember
        travelArgument = entry.displayName
        unavailableMessage = "Guild travel API is unavailable."
    elseif entry.kind == "GROUP" then
        travelFunction = JumpToGroupMember
        travelArgument = entry.displayName ~= "" and entry.displayName or entry.characterName
        unavailableMessage = "Group travel API is unavailable."
    end

    if type(travelFunction) ~= "function" then
        EPC:Print(unavailableMessage or "Travel API is unavailable.")
        return
    end

    EPC:Print("Traveling to " .. entry.name .. ".")
    local ok = pcall(travelFunction, travelArgument)
    if not ok then
        EPC:Print("ESO rejected the travel request. Try the normal map or Social menu.")
    end
end
