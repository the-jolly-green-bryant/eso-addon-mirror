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

-- Undaunted pledge turn-ins use the enclave tied to the player's alliance.
-- Keep this in Travel so Activities and any future routing UI share one source
-- of truth instead of assuming one generic "Undaunted Enclave" destination.
function T:GetUndauntedEnclaveForPlayer()
    local alliance = 0
    if type(GetUnitAlliance) == "function" then
        local ok, value = pcall(GetUnitAlliance, "player")
        if ok then alliance = safeNumber(value, 0) end
    end

    if ALLIANCE_ALDMERI_DOMINION ~= nil and alliance == ALLIANCE_ALDMERI_DOMINION then
        return { alliance = alliance, city = "Elden Root", zone = "Grahtwood", wayshrine = "Elden Root Wayshrine" }
    elseif ALLIANCE_DAGGERFALL_COVENANT ~= nil and alliance == ALLIANCE_DAGGERFALL_COVENANT then
        return { alliance = alliance, city = "Wayrest", zone = "Stormhaven", wayshrine = "Wayrest Wayshrine" }
    elseif ALLIANCE_EBONHEART_PACT ~= nil and alliance == ALLIANCE_EBONHEART_PACT then
        return { alliance = alliance, city = "Mournhold", zone = "Deshaan", wayshrine = "Mournhold Wayshrine" }
    end

    return nil
end

function T:GetAlliancePledgeTurnInWayshrine(entries)
    local enclave = self:GetUndauntedEnclaveForPlayer()
    if not enclave then return nil, nil end

    local exactName = lower(enclave.wayshrine)
    local cityNeedle = lower(enclave.city)
    local zoneNeedle = lower(enclave.zone)
    local zoneFallback = nil

    for i = 1, #(entries or {}) do
        local entry = entries[i]
        local shrineName = lower(entry and entry.name or "")
        local zoneName = lower(entry and entry.zoneName or "")
        if shrineName == exactName or (cityNeedle ~= "" and string.find(shrineName, cityNeedle, 1, true)) then
            return entry, enclave
        end
        if not zoneFallback and zoneNeedle ~= "" and zoneName == zoneNeedle then
            zoneFallback = entry
        end
    end

    return zoneFallback, enclave
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

local function getCanonicalZoneId(zoneId)
    local current = safeNumber(zoneId, 0)
    if current <= 0 then return 0 end
    if type(GetParentZoneId) ~= "function" then return current end

    local seen = {}
    for _ = 1, 8 do
        if seen[current] then break end
        seen[current] = true
        local ok, parent = pcall(GetParentZoneId, current)
        parent = ok and safeNumber(parent, 0) or 0
        if parent <= 0 or parent == current then break end
        current = parent
    end
    return current
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


local function serviceTextMatches(kind, name, icon)
    local textValue = lower(tostring(name or "") .. " " .. tostring(icon or ""))
    if kind == "GUILD_STORE" then
        local guildNeedles = {"guild trader", "guildtrader", "guild store", "guildstore", "trading house", "trader"}
        for i = 1, #guildNeedles do
            if string.find(textValue, guildNeedles[i], 1, true) then return true end
        end
        return false
    end

    -- Ordinary merchant routing intentionally excludes guild traders so the two
    -- buttons remain distinct destinations.
    if string.find(textValue, "guild trader", 1, true)
        or string.find(textValue, "guildtrader", 1, true)
        or string.find(textValue, "guild store", 1, true)
        or string.find(textValue, "guildstore", 1, true) then
        return false
    end
    local merchantNeedles = {
        "merchant", "vendor", "generalstore", "general_store", "general goods",
        "shop", "store", "armsman", "armorer", "clothier", "woodworker",
        "alchemist", "enchanter", "mystic", "chef", "brewer", "outfitter",
        "blacksmith", "weaponsmith", "grocer"
    }
    for i = 1, #merchantNeedles do
        if string.find(textValue, merchantNeedles[i], 1, true) then return true end
    end
    return false
end

function T:GetNearestCurrentZoneService(kind)
    kind = kind == "GUILD_STORE" and "GUILD_STORE" or "MERCHANT"
    if type(SetMapToPlayerLocation) == "function" then pcall(SetMapToPlayerLocation) end

    local mapId = getCurrentMapIdSafe()
    local zoneIndex = 0
    if type(GetCurrentMapZoneIndex) == "function" then
        local ok, value = pcall(GetCurrentMapZoneIndex)
        if ok then zoneIndex = safeNumber(value, 0) end
    end
    if zoneIndex <= 0 and type(GetUnitZoneIndex) == "function" then
        local ok, value = pcall(GetUnitZoneIndex, "player")
        if ok then zoneIndex = safeNumber(value, 0) end
    end

    local playerX, playerY = 0.5, 0.5
    if type(GetMapPlayerPosition) == "function" then
        local ok, x, y, _, shown = pcall(GetMapPlayerPosition, "player")
        if ok and shown ~= false and tonumber(x) and tonumber(y) then
            playerX, playerY = tonumber(x), tonumber(y)
        end
    end

    local candidates = {}
    local function addCandidate(name, x, y, source)
        x, y = tonumber(x), tonumber(y)
        if not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then return end
        local dx, dy = x - playerX, y - playerY
        candidates[#candidates + 1] = {
            name = clean(name, kind == "GUILD_STORE" and "Guild Trader" or "Merchant"),
            x = x, y = y, distance2 = dx * dx + dy * dy, mapId = mapId,
            zoneIndex = zoneIndex, source = source,
        }
    end

    if zoneIndex > 0 and type(GetNumPOIs) == "function" and type(GetPOIMapInfo) == "function" then
        local ok, count = pcall(GetNumPOIs, zoneIndex)
        count = ok and safeNumber(count, 0) or 0
        for poiIndex = 1, count do
            local infoOk, x, y, _, icon, shown, locked = pcall(GetPOIMapInfo, zoneIndex, poiIndex)
            if infoOk and shown == true and locked ~= true and tonumber(x) and tonumber(y) then
                local name = ""
                if type(GetPOIInfo) == "function" then
                    local nameOk, returnedName = pcall(GetPOIInfo, zoneIndex, poiIndex)
                    if nameOk then name = clean(returnedName, "") end
                end
                if serviceTextMatches(kind, name, icon) then
                    addCandidate(name, x, y, "poi")
                end
            end
        end
    end

    -- The minimap learns merchant locations when the player opens a store. Use
    -- those remembered positions too, since ESO does not expose every vendor as
    -- a normal map POI.
    if kind == "MERCHANT" and EPC.saved and type(EPC.saved.miniMapKnownMerchants) == "table" and mapId > 0 then
        local list = EPC.saved.miniMapKnownMerchants[tostring(mapId)]
        if type(list) == "table" then
            for i = 1, #list do
                local row = list[i]
                if type(row) == "table" then addCandidate(row.name, row.x, row.y, "learned") end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if math.abs((a.distance2 or 0) - (b.distance2 or 0)) > 0.0000001 then
            return (a.distance2 or 0) < (b.distance2 or 0)
        end
        return lower(a.name) < lower(b.name)
    end)
    return candidates[1]
end

function T:GetNearestWayshrineToCurrentMapPoint(targetX, targetY)
    targetX, targetY = tonumber(targetX), tonumber(targetY)
    if not targetX or not targetY then return nil end
    local total = 0
    if type(GetNumFastTravelNodes) == "function" then
        local ok, count = pcall(GetNumFastTravelNodes)
        if ok then total = safeNumber(count, 0) end
    end
    local best, bestDistance = nil, nil
    for nodeIndex = 1, total do
        local entry = self:GetWayshrineNodeEntry(nodeIndex)
        if entry and entry.canTravel and entry.isShownInCurrentMap and entry.normalizedX and entry.normalizedY then
            local dx, dy = entry.normalizedX - targetX, entry.normalizedY - targetY
            local dist2 = dx * dx + dy * dy
            if bestDistance == nil or dist2 < bestDistance then
                best, bestDistance = entry, dist2
            end
        end
    end
    return best
end

function T:TravelToNearestService(kind)
    kind = kind == "GUILD_STORE" and "GUILD_STORE" or "MERCHANT"
    local label = kind == "GUILD_STORE" and "guild store" or "merchant"
    local target = self:GetNearestCurrentZoneService(kind)
    if not target then
        EPC:Print("No known " .. label .. " could be found in your current zone. Visit one once or open the zone map so ESO can expose its location.")
        return false
    end

    -- Leave a normal ESO waypoint on the service so the player can walk from
    -- the arrival wayshrine to the exact merchant/trader location.
    if type(PingMap) == "function" and MAP_PIN_TYPE_PLAYER_WAYPOINT ~= nil and MAP_TYPE_LOCATION_CENTERED ~= nil then
        pcall(PingMap, MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, target.x, target.y)
    end

    local shrine = self:GetNearestWayshrineToCurrentMapPoint(target.x, target.y)
    if not shrine then
        EPC:Print("Found " .. target.name .. ", but no discovered wayshrine on this zone map can be used to reach it.")
        return false
    end

    EPC:Print(string.format("Nearest %s: %s. Traveling via %s and setting a waypoint on the destination.", label, target.name, shrine.name))
    return self:TravelToWayshrineNode(shrine.nodeIndex, shrine.name)
end

-- Resolve the stable overland zone recorded by ESO for an accepted quest.
-- This is intentionally based on questId/GetQuestZoneId rather than
-- GetJournalQuestLocationInfo(), because the latter may be an instance or
-- objective label rather than a real travel zone.
-- Resolve stable overland metadata exposed specifically for an active journal quest.
-- This is intentionally separate from GetQuestZoneId(), which can identify an
-- interior instance (for example a Main Story mission) rather than the zone that
-- owns the wayshrines needed to reach it.
function T:GetMainStoryHarborageZone(journalQuestIndex)
    local qIndex = safeNumber(journalQuestIndex, 0)
    if qIndex <= 0 then return 0, "" end

    -- The Harborage itself is the reliable signal here. Do not require a
    -- QUEST_TYPE_MAIN_STORY match because ESO journal metadata can report an
    -- unexpected quest type for active Main Story steps.
    local alliance = 0
    if type(GetUnitAlliance) == "function" then
        local aOk, value = pcall(GetUnitAlliance, "player")
        if aOk then alliance = safeNumber(value, 0) end
    end

    local wanted = ""
    local dc = (ALLIANCE_DAGGERFALL_COVENANT ~= nil and alliance == ALLIANCE_DAGGERFALL_COVENANT) or alliance == 3
    local ad = (ALLIANCE_ALDMERI_DOMINION ~= nil and alliance == ALLIANCE_ALDMERI_DOMINION) or alliance == 1
    local ep = (ALLIANCE_EBONHEART_PACT ~= nil and alliance == ALLIANCE_EBONHEART_PACT) or alliance == 2
    if dc then
        wanted = "Glenumbra"
    elseif ad then
        wanted = "Auridon"
    elseif ep then
        wanted = "Stonefalls"
    end
    if wanted == "" then return 0, "" end

    if type(GetNumZones) == "function" and type(GetZoneNameByIndex) == "function" and type(GetZoneId) == "function" then
        local countOk, count = pcall(GetNumZones)
        count = countOk and safeNumber(count, 0) or 0
        for zoneIndex = 1, count do
            local nameOk, name = pcall(GetZoneNameByIndex, zoneIndex)
            if nameOk and lower(name or "") == lower(wanted) then
                local idOk, zoneId = pcall(GetZoneId, zoneIndex)
                zoneId = idOk and safeNumber(zoneId, 0) or 0
                return zoneId, wanted
            end
        end
    end
    return 0, wanted
end

local function isHarborageLocation(value)
    local text = lower(clean(value, ""))
    return text ~= "" and string.find(text, "harborage", 1, true) ~= nil
end

function T:GetJournalQuestOverlandFallbackZone(journalQuestIndex)
    local qIndex = safeNumber(journalQuestIndex, 0)
    if qIndex <= 0 then return 0, "", "" end

    -- ESO reports The Harborage as the location for many Main Story quests.
    -- Translate that one special hub to the alliance-specific overland zone that
    -- actually contains its entrance and wayshrines. Other quests remain dynamic.
    if type(GetJournalQuestLocationInfo) == "function" then
        local locOk, locationName, _, locationZoneIndex = pcall(GetJournalQuestLocationInfo, qIndex)
        if locOk then
            locationZoneIndex = safeNumber(locationZoneIndex, 0)

            -- First trust the location's numeric zone index, not its display label.
            if locationZoneIndex > 0 and type(GetZoneId) == "function" then
                local idOk, locationZoneId = pcall(GetZoneId, locationZoneIndex)
                locationZoneId = idOk and safeNumber(locationZoneId, 0) or 0
                if locationZoneId > 0 then
                    local canonical = getCanonicalZoneId(locationZoneId)
                    if canonical <= 0 then canonical = locationZoneId end
                    local zoneName = ""
                    if type(GetZoneNameById) == "function" then
                        local nameOk, value = pcall(GetZoneNameById, canonical)
                        if nameOk then zoneName = clean(value, "") end
                    end
                    if zoneName ~= "" and not isHarborageLocation(zoneName) then
                        return canonical, zoneName, "journal-location-zone-index"
                    end
                end
            end

            if isHarborageLocation(locationName) then
                local zoneId, zoneName = self:GetMainStoryHarborageZone(qIndex)
                if zoneName ~= "" then return zoneId, zoneName, "main-story-harborage" end
            end
        end
    end

    if type(GetJournalQuestZoneStoryZoneId) == "function" then
        local ok, zoneStoryId = pcall(GetJournalQuestZoneStoryZoneId, qIndex)
        zoneStoryId = ok and safeNumber(zoneStoryId, 0) or 0
        if zoneStoryId > 0 then
            local canonical = getCanonicalZoneId(zoneStoryId)
            if canonical <= 0 then canonical = zoneStoryId end
            local zoneName = ""
            if type(GetZoneNameById) == "function" then
                local nameOk, value = pcall(GetZoneNameById, canonical)
                if nameOk then zoneName = clean(value, "") end
            end
            if zoneName ~= "" then return canonical, zoneName, "zone-story" end
        end
    end

    if type(GetJournalQuestStartingZone) == "function" and type(GetZoneId) == "function" then
        local ok, startZoneIndex = pcall(GetJournalQuestStartingZone, qIndex)
        startZoneIndex = ok and safeNumber(startZoneIndex, 0) or 0
        if startZoneIndex > 0 then
            local idOk, startZoneId = pcall(GetZoneId, startZoneIndex)
            startZoneId = idOk and safeNumber(startZoneId, 0) or 0
            if startZoneId > 0 then
                local canonical = getCanonicalZoneId(startZoneId)
                if canonical <= 0 then canonical = startZoneId end
                local zoneName = ""
                if type(GetZoneNameById) == "function" then
                    local nameOk, value = pcall(GetZoneNameById, canonical)
                    if nameOk then zoneName = clean(value, "") end
                end
                if zoneName ~= "" then return canonical, zoneName, "starting-zone" end
            end
        end
    end

    return 0, "", ""
end

function T:GetQuestRecordZone(quest)
    if not quest then return 0, 0, "" end
    local questId = safeNumber(quest.questId, 0)
    if questId <= 0 and safeNumber(quest.questIndex, 0) > 0 and type(GetJournalQuestId) == "function" then
        local ok, value = pcall(GetJournalQuestId, safeNumber(quest.questIndex, 0))
        if ok then questId = safeNumber(value, 0) end
    end

    local zoneId = 0
    if questId > 0 and type(GetQuestZoneId) == "function" then
        local ok, value = pcall(GetQuestZoneId, questId)
        if ok then zoneId = safeNumber(value, 0) end
    end
    local canonicalZoneId = getCanonicalZoneId(zoneId)
    if canonicalZoneId <= 0 then canonicalZoneId = zoneId end

    local zoneName = ""
    local nameId = canonicalZoneId > 0 and canonicalZoneId or zoneId
    if nameId > 0 and type(GetZoneNameById) == "function" then
        local ok, value = pcall(GetZoneNameById, nameId)
        if ok then zoneName = clean(value, "") end
    end
    return zoneId, canonicalZoneId, zoneName
end

-- v0.25.27: resolve the best discovered wayshrine for a Quest Finder selection.
-- ESO does not expose world coordinates for an unaccepted quest giver, so
-- unstarted quests use the selected quest's zone as the authoritative route.
-- Accepted/assisted quests can still use the existing objective-distance ranking.
function T:GetNearestWayshrineForQuestSelection(quest)
    if not quest then
        return nil, "Select a quest first."
    end

    local snapshot = EPC.lastSnapshot or (EPC.Engine and EPC.Engine:BuildSnapshot()) or {}
    local entries = self:GetWayshrines(snapshot)
    local selectedQuestIndex = safeNumber(quest.questIndex, 0)
    local questRecordZoneId, questRecordCanonicalZoneId, questRecordZoneName = self:GetQuestRecordZone(quest)

    local function findShrineByCanonicalZone(targetZoneId, matchType)
        targetZoneId = safeNumber(targetZoneId, 0)
        if targetZoneId <= 0 then return nil end
        local canonical = getCanonicalZoneId(targetZoneId)
        if canonical <= 0 then canonical = targetZoneId end
        local exact, canonicalMatch = nil, nil
        for i = 1, #(entries or {}) do
            local entry = entries[i]
            local entryZoneId = safeNumber(entry and entry.zoneId, 0)
            if entryZoneId == targetZoneId and not exact then exact = entry end
            if not canonicalMatch and entryZoneId > 0 and getCanonicalZoneId(entryZoneId) == canonical then
                canonicalMatch = entry
            end
        end
        if exact then return exact, matchType end
        if canonicalMatch then return canonicalMatch, matchType end
        return nil
    end

    local function findShrineByZoneName(targetZoneName, matchType)
        local wanted = lower(clean(targetZoneName, ""))
        if wanted == "" then return nil end
        for i = 1, #(entries or {}) do
            local entry = entries[i]
            if lower(entry and entry.zoneName or "") == wanted then
                return entry, matchType
            end
        end
        return nil
    end

    -- The Harborage is an alliance-specific hub, not a standalone overland travel zone.
    -- Resolve it immediately before objective-map logic can strand us inside the private map.
    if selectedQuestIndex > 0 and type(GetJournalQuestLocationInfo) == "function" then
        local locOk, locationName, objectiveName, locationZoneIndex = pcall(GetJournalQuestLocationInfo, selectedQuestIndex)
        if locOk then
            locationName = clean(locationName, "")
            objectiveName = clean(objectiveName, "")
            locationZoneIndex = safeNumber(locationZoneIndex, 0)

            -- Main Story mission instances can report the quest title itself as the
            -- zone/objective. Resolve those to the alliance Harborage host BEFORE
            -- the numeric instance zone is considered, otherwise a valid Glenumbra/
            -- Auridon/Stonefalls wayshrine can never match.
            local journalQuestName = ""
            if type(GetJournalQuestName) == "function" then
                local nameOk, value = pcall(GetJournalQuestName, selectedQuestIndex)
                if nameOk then journalQuestName = clean(value, "") end
            end
            local selfReferential = journalQuestName ~= "" and (
                lower(locationName) == lower(journalQuestName) or lower(objectiveName) == lower(journalQuestName)
            )
            local isMainStory = false
            if type(GetJournalQuestType) == "function" then
                local typeOk, qt = pcall(GetJournalQuestType, selectedQuestIndex)
                qt = typeOk and safeNumber(qt, -1) or -1
                isMainStory = (QUEST_TYPE_MAIN_STORY ~= nil and qt == QUEST_TYPE_MAIN_STORY)
            end
            if isHarborageLocation(locationName) or (selfReferential and isMainStory) then
                local harborageZoneId, harborageZoneName = self:GetMainStoryHarborageZone(selectedQuestIndex)
                local shrine, matchType = nil, nil
                if harborageZoneId > 0 then
                    shrine, matchType = findShrineByCanonicalZone(harborageZoneId, "main-story-overland-entry")
                end
                if not shrine and harborageZoneName ~= "" then
                    shrine, matchType = findShrineByZoneName(harborageZoneName, "main-story-overland-entry-name")
                end
                if shrine then
                    shrine.resolvedQuestZoneId = harborageZoneId
                    shrine.resolvedQuestZoneName = harborageZoneName
                    return shrine, matchType
                end
            end

            -- Only trust the numeric zone identity after rejecting private Main Story
            -- mission zones that use the quest title as their map/location name.
            if locationZoneIndex > 0 and type(GetZoneId) == "function" then
                local idOk, locationZoneId = pcall(GetZoneId, locationZoneIndex)
                locationZoneId = idOk and safeNumber(locationZoneId, 0) or 0
                if locationZoneId > 0 then
                    local shrine, matchType = findShrineByCanonicalZone(locationZoneId, "journal-location-zone-index")
                    if shrine then return shrine, matchType end
                end
            end

            if isHarborageLocation(locationName) then
                local harborageZoneId, harborageZoneName = self:GetMainStoryHarborageZone(selectedQuestIndex)
                local shrine, matchType = nil, nil
                if harborageZoneId > 0 then
                    shrine, matchType = findShrineByCanonicalZone(harborageZoneId, "harborage-alliance-zone")
                end
                if not shrine and harborageZoneName ~= "" then
                    shrine, matchType = findShrineByZoneName(harborageZoneName, "harborage-alliance-zone-name")
                end
                if shrine then
                    shrine.resolvedQuestZoneId = harborageZoneId
                    shrine.resolvedQuestZoneName = harborageZoneName
                    return shrine, matchType
                end
            end
        end
    end

    -- A completed Undaunted pledge belongs at this character's alliance enclave.
    if selectedQuestIndex > 0 and type(GetJournalQuestInfo) == "function" then
        local ok, _, _, _, _, _, completed, _, _, _, questType = pcall(GetJournalQuestInfo, selectedQuestIndex)
        local isPledge = ok and QUEST_TYPE_UNDAUNTED_PLEDGE ~= nil and questType == QUEST_TYPE_UNDAUNTED_PLEDGE
        if isPledge then
            if type(GetJournalQuestIsComplete) == "function" then
                local completeOk, completeValue = pcall(GetJournalQuestIsComplete, selectedQuestIndex)
                if completeOk then completed = completeValue == true end
            end
            if completed == true then
                local pledgeShrine, enclave = self:GetAlliancePledgeTurnInWayshrine(entries)
                if pledgeShrine then
                    pledgeShrine.pledgeTurnIn = true
                    pledgeShrine.pledgeEnclave = enclave
                    return pledgeShrine, "pledge-turnin"
                elseif enclave then
                    return nil, string.format(
                        "No discovered wayshrine was found for your %s Undaunted pledge turn-in in %s, %s.",
                        enclave.city, enclave.city, enclave.zone
                    )
                end
            end
        end
    end

    local function mapResultSucceeded(ok, result)
        if not ok then return false end
        if SET_MAP_RESULT_FAILED ~= nil and result == SET_MAP_RESULT_FAILED then return false end
        return true
    end

    local function notifyMapChanged()
        if type(CALLBACK_MANAGER) == "table" and type(CALLBACK_MANAGER.FireCallbacks) == "function" then
            pcall(CALLBACK_MANAGER.FireCallbacks, CALLBACK_MANAGER, "OnWorldMapChanged")
        end
    end

    -- Resolve an instanced/objective map to the real overland map that physically
    -- contains it. ESO exposes universally-normalized map rectangles even when
    -- parent-map metadata is incomplete. We scan map records for the smallest
    -- containing zone that also owns one of the player's discovered wayshrines.
    local function getContainingOverlandWayshrine(matchType)
        if type(GetCurrentMapId) ~= "function"
            or type(GetUniversallyNormalizedMapInfo) ~= "function"
            or type(GetNumMaps) ~= "function"
            or type(GetMapIdByIndex) ~= "function"
            or type(GetMapInfoById) ~= "function" then
            return nil
        end

        local okMap, currentMapId = pcall(GetCurrentMapId)
        currentMapId = okMap and safeNumber(currentMapId, 0) or 0
        if currentMapId <= 0 then return nil end

        local okRect, ox, oz, w, h = pcall(GetUniversallyNormalizedMapInfo, currentMapId)
        if not okRect then return nil end
        ox, oz, w, h = tonumber(ox) or 0, tonumber(oz) or 0, tonumber(w) or 0, tonumber(h) or 0
        if w <= 0 or h <= 0 then return nil end
        local cx, cz = ox + (w * 0.5), oz + (h * 0.5)

        local mapEntries = self:GetWayshrines(snapshot)
        local bestEntry, bestArea, bestZoneId = nil, nil, 0
        local mapCountOk, mapCount = pcall(GetNumMaps)
        mapCount = mapCountOk and safeNumber(mapCount, 0) or 0

        for mapIndex = 1, mapCount do
            local idOk, mapId = pcall(GetMapIdByIndex, mapIndex)
            mapId = idOk and safeNumber(mapId, 0) or 0
            if mapId > 0 and mapId ~= currentMapId then
                local infoOk, _, _, _, zoneIndex = pcall(GetMapInfoById, mapId)
                zoneIndex = infoOk and safeNumber(zoneIndex, 0) or 0
                if zoneIndex > 0 then
                    local rectOk, mx, mz, mw, mh = pcall(GetUniversallyNormalizedMapInfo, mapId)
                    mx, mz, mw, mh = tonumber(mx) or 0, tonumber(mz) or 0, tonumber(mw) or 0, tonumber(mh) or 0
                    if rectOk and mw > 0 and mh > 0 then
                        local epsilon = 0.000001
                        local contains = cx >= (mx - epsilon) and cx <= (mx + mw + epsilon)
                            and cz >= (mz - epsilon) and cz <= (mz + mh + epsilon)
                        local area = mw * mh
                        if contains and area >= (w * h) then
                            local zoneId = 0
                            if type(GetZoneId) == "function" then
                                local zidOk, zid = pcall(GetZoneId, zoneIndex)
                                if zidOk then zoneId = safeNumber(zid, 0) end
                            end
                            if zoneId > 0 then
                                local canonical = getCanonicalZoneId(zoneId)
                                if canonical <= 0 then canonical = zoneId end
                                for i = 1, #(mapEntries or {}) do
                                    local entry = mapEntries[i]
                                    local entryZoneId = safeNumber(entry and entry.zoneId, 0)
                                    local entryCanonical = getCanonicalZoneId(entryZoneId)
                                    if entryZoneId == zoneId or (entryCanonical > 0 and entryCanonical == canonical) then
                                        if bestArea == nil or area < bestArea then
                                            bestEntry, bestArea, bestZoneId = entry, area, zoneId
                                        end
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if bestEntry then
            bestEntry.resolvedQuestZoneId = bestZoneId
            if bestZoneId > 0 and type(GetZoneNameById) == "function" then
                local nameOk, zoneName = pcall(GetZoneNameById, bestZoneId)
                if nameOk then bestEntry.resolvedQuestZoneName = clean(zoneName, "") end
            end
            return bestEntry, matchType .. "-overland-container"
        end
        return nil
    end

    local function getShownWayshrineFromCurrentMap(matchType)
        local mapEntries = self:GetWayshrines(snapshot)

        -- Resolve the destination from ESO's map state itself. isShownInCurrentMap can
        -- be stale/false immediately after SetMapToQuestCondition(), especially when
        -- the quest objective is on an instance/sub-map. The current map zone index is
        -- authoritative and its parent zone gives us the overland destination.
        local mapZoneIndex = 0
        if type(GetCurrentMapZoneIndex) == "function" then
            local ok, value = pcall(GetCurrentMapZoneIndex)
            if ok then mapZoneIndex = safeNumber(value, 0) end
        end

        local mapZoneId, mapParentZoneId = getZoneIdentity(mapZoneIndex)
        local mapCanonicalZoneId = getCanonicalZoneId(mapZoneId)
        if mapCanonicalZoneId <= 0 then mapCanonicalZoneId = getCanonicalZoneId(mapParentZoneId) end

        local exactZone, canonicalZone = nil, nil
        for i = 1, #(mapEntries or {}) do
            local entry = mapEntries[i]
            if entry then
                local entryZoneIndex = safeNumber(entry.zoneIndex, 0)
                local entryZoneId = safeNumber(entry.zoneId, 0)
                if mapZoneIndex > 0 and entryZoneIndex == mapZoneIndex and not exactZone then
                    exactZone = entry
                elseif mapZoneId > 0 and entryZoneId == mapZoneId and not exactZone then
                    exactZone = entry
                end

                if mapCanonicalZoneId > 0 and not canonicalZone then
                    local entryCanonicalZoneId = getCanonicalZoneId(entryZoneId)
                    if entryCanonicalZoneId > 0 and entryCanonicalZoneId == mapCanonicalZoneId then
                        canonicalZone = entry
                    end
                end
            end
        end

        -- Prefer exact destination-zone identity, then its canonical/main overland zone.
        -- Do not fall back to an arbitrary shrine merely because it is shown on a map;
        -- that was the path that could keep a cross-zone quest in the player's current zone.
        if exactZone then return exactZone, matchType end
        if canonicalZone then return canonicalZone, matchType end
        return nil
    end

    -- Quest objectives can live on private instance maps (for example a main-story
    -- interior) whose zone identity has no fast-travel nodes. In that case, walk the
    -- WORLD MAP hierarchy outward. The first parent map that resolves to a discovered
    -- wayshrine is the real overland travel destination. This is intentionally dynamic:
    -- no quest names, cities, alliances, or zone names are hardcoded here.
    local function getWayshrineFromObjectiveParentMaps(matchType)
        local shrine, resolvedType = getShownWayshrineFromCurrentMap(matchType)
        if shrine then return shrine, resolvedType end

        -- Stronger fallback for instance maps: locate the smallest overland map
        -- whose universal rectangle contains the objective and that has a discovered
        -- wayshrine. This avoids relying on a missing/incorrect parent-zone chain.
        shrine, resolvedType = getContainingOverlandWayshrine(matchType)
        if shrine then return shrine, resolvedType end

        if type(MapZoomOut) ~= "function" then return nil end

        local previousMapId = getCurrentMapIdSafe()
        for _ = 1, 8 do
            local ok, result = pcall(MapZoomOut)
            if not mapResultSucceeded(ok, result) then break end
            notifyMapChanged()

            local currentMapId = getCurrentMapIdSafe()
            -- Stop if ESO did not actually move to a parent map.
            if currentMapId > 0 and previousMapId > 0 and currentMapId == previousMapId then break end
            previousMapId = currentMapId

            shrine, resolvedType = getShownWayshrineFromCurrentMap(matchType .. "-parent")
            if shrine then return shrine, resolvedType end

            -- Once we have zoomed all the way to a root/world map there is no useful
            -- zone identity left to match. Avoid ever choosing an arbitrary shrine.
            local zoneIndex = 0
            if type(GetCurrentMapZoneIndex) == "function" then
                local zoneOk, value = pcall(GetCurrentMapZoneIndex)
                if zoneOk then zoneIndex = safeNumber(value, 0) end
            end
            if zoneIndex <= 0 and currentMapId <= 0 then break end
        end
        return nil
    end

    -- IMPORTANT: for accepted quests, resolve the CURRENT OBJECTIVE MAP before any
    -- journal-zone matching. A quest can be journaled under Stormhaven while its next
    -- positional objective is actually in Glenumbra. Broad zone matching first caused
    -- the old code to return a Stormhaven shrine and never reach the real objective.
    if selectedQuestIndex > 0 then
        if type(GetJournalQuestNumSteps) == "function"
            and type(GetJournalQuestNumConditions) == "function"
            and type(GetJournalQuestConditionInfo) == "function"
            and type(DoesJournalQuestConditionHavePosition) == "function"
            and type(SetMapToQuestCondition) == "function" then

            local stepsOk, stepCount = pcall(GetJournalQuestNumSteps, selectedQuestIndex)
            stepCount = stepsOk and safeNumber(stepCount, 0) or 0

            for stepIndex = 1, stepCount do
                local countOk, conditionCount = pcall(GetJournalQuestNumConditions, selectedQuestIndex, stepIndex)
                conditionCount = countOk and safeNumber(conditionCount, 0) or 0
                for conditionIndex = 1, conditionCount do
                    local infoOk, _, _, _, isFailCondition, isComplete, _, isVisible = pcall(
                        GetJournalQuestConditionInfo,
                        selectedQuestIndex,
                        stepIndex,
                        conditionIndex,
                        false
                    )
                    local posOk, hasPosition = pcall(
                        DoesJournalQuestConditionHavePosition,
                        selectedQuestIndex,
                        stepIndex,
                        conditionIndex
                    )

                    if infoOk and posOk and hasPosition == true
                        and isFailCondition ~= true and isComplete ~= true and isVisible ~= false then
                        local setOk, setResult = pcall(SetMapToQuestCondition, selectedQuestIndex, stepIndex, conditionIndex)
                        if mapResultSucceeded(setOk, setResult) then
                            notifyMapChanged()
                            local shrine, matchType = getWayshrineFromObjectiveParentMaps("quest-condition-map")
                            if shrine then return shrine, matchType end
                        end
                    end
                end
            end
        end

        -- Completed non-pledge quests may have a separate hand-in map.
        if type(GetJournalQuestIsComplete) == "function"
            and type(GetJournalQuestNumSteps) == "function"
            and type(SetMapToQuestStepEnding) == "function" then
            local completeOk, isComplete = pcall(GetJournalQuestIsComplete, selectedQuestIndex)
            if completeOk and isComplete == true then
                local stepsOk, stepCount = pcall(GetJournalQuestNumSteps, selectedQuestIndex)
                stepCount = stepsOk and safeNumber(stepCount, 0) or 0
                for stepIndex = stepCount, 1, -1 do
                    local setOk, setResult = pcall(SetMapToQuestStepEnding, selectedQuestIndex, stepIndex)
                    if mapResultSucceeded(setOk, setResult) then
                        notifyMapChanged()
                        local shrine, matchType = getWayshrineFromObjectiveParentMaps("quest-ending-map")
                        if shrine then return shrine, matchType end
                    end
                end
            end
        end

        -- If positional map APIs leave us inside a private instance, use journal-level
        -- overland metadata before the generic quest record. For Main Story quests this
        -- can resolve the alliance-side overland zone even when GetQuestZoneId() names
        -- the mission instance itself. This remains dynamic for every active quest.
        local journalFallbackZoneId, journalFallbackZoneName, journalFallbackSource =
            self:GetJournalQuestOverlandFallbackZone(selectedQuestIndex)
        if journalFallbackZoneId > 0 or journalFallbackZoneName ~= "" then
            local shrine, matchType = nil, nil
            if journalFallbackZoneId > 0 then
                shrine, matchType = findShrineByCanonicalZone(
                    journalFallbackZoneId, "journal-" .. tostring(journalFallbackSource or "overland-zone")
                )
            end
            if not shrine and journalFallbackZoneName ~= "" then
                shrine, matchType = findShrineByZoneName(
                    journalFallbackZoneName, "journal-zone-name-" .. tostring(journalFallbackSource or "overland-zone")
                )
            end
            if shrine then
                shrine.resolvedQuestZoneId = journalFallbackZoneId
                shrine.resolvedQuestZoneName = journalFallbackZoneName
                return shrine, matchType
            end
        end

        -- Only then use ESO's generic quest record zone. It may identify an interior
        -- instance, so it is deliberately lower priority than journal overland data.
        if questRecordZoneId > 0 then
            local shrine, matchType = findShrineByCanonicalZone(questRecordZoneId, "quest-record-zone")
            if shrine then return shrine, matchType end
        end

        -- Only after objective/ending/quest-record resolution fails do we use ESO's broad quest-zone map.
        if type(SetMapToQuestZone) == "function" then
            local setOk, setResult = pcall(SetMapToQuestZone, selectedQuestIndex)
            if mapResultSucceeded(setOk, setResult) then
                notifyMapChanged()
                local shrine, matchType = getWayshrineFromObjectiveParentMaps("quest-map-zone")
                if shrine then return shrine, matchType end
            end
        end
    end

    -- Last-resort metadata match. This is useful for unaccepted quests and accepted
    -- quests whose conditions do not expose a position, but it is intentionally AFTER
    -- the active objective-map path above so it cannot trap cross-zone quests.
    local targetZoneId = questRecordZoneId > 0 and questRecordZoneId or safeNumber(quest.zoneId, 0)
    local targetZoneIndex = safeNumber(quest.zoneIndex, 0)
    local targetZoneName = questRecordZoneName ~= "" and lower(questRecordZoneName) or lower(quest.zone or quest.zoneName or "")

    if selectedQuestIndex > 0 and targetZoneId <= 0 and type(GetJournalQuestLocationInfo) == "function" then
        local ok, journalZoneName, _, journalZoneIndex = pcall(GetJournalQuestLocationInfo, selectedQuestIndex)
        if ok then
            if targetZoneName == "" or targetZoneName == "accepted quest" then
                targetZoneName = lower(journalZoneName or "")
            end
            journalZoneIndex = safeNumber(journalZoneIndex, 0)
            if targetZoneIndex <= 0 and journalZoneIndex > 0 then targetZoneIndex = journalZoneIndex end
            if targetZoneId <= 0 and journalZoneIndex > 0 and type(GetZoneId) == "function" then
                local idOk, journalZoneId = pcall(GetZoneId, journalZoneIndex)
                if idOk then targetZoneId = safeNumber(journalZoneId, 0) end
            end
        end
    end

    local targetCanonicalZoneId = getCanonicalZoneId(targetZoneId)
    local targetCanonicalZoneName = ""
    if targetCanonicalZoneId > 0 and type(GetZoneNameById) == "function" then
        local nameOk, canonicalName = pcall(GetZoneNameById, targetCanonicalZoneId)
        if nameOk then targetCanonicalZoneName = lower(canonicalName or "") end
    end

    local nameFallback, canonicalFallback, canonicalNameFallback = nil, nil, nil
    for i = 1, #(entries or {}) do
        local entry = entries[i]
        local entryZoneId = safeNumber(entry.zoneId, 0)
        local entryZoneIndex = safeNumber(entry.zoneIndex, 0)
        local entryZoneName = lower(entry.zoneName or "")

        if targetZoneIndex > 0 and entryZoneIndex == targetZoneIndex then return entry, "zone" end
        if targetZoneId > 0 and entryZoneId == targetZoneId then return entry, "zone" end
        if not nameFallback and targetZoneName ~= "" and entryZoneName == targetZoneName then nameFallback = entry end

        local entryCanonicalZoneId = getCanonicalZoneId(entryZoneId)
        if not canonicalFallback and targetCanonicalZoneId > 0
            and entryCanonicalZoneId > 0 and entryCanonicalZoneId == targetCanonicalZoneId then
            canonicalFallback = entry
        end

        if not canonicalNameFallback and targetCanonicalZoneName ~= ""
            and entryCanonicalZoneId > 0 and type(GetZoneNameById) == "function" then
            local okName, entryMainName = pcall(GetZoneNameById, entryCanonicalZoneId)
            if okName and lower(entryMainName or "") == targetCanonicalZoneName then
                canonicalNameFallback = entry
            end
        end
    end

    if nameFallback then return nameFallback, "zone" end
    if canonicalFallback then return canonicalFallback, "zone" end
    if canonicalNameFallback then return canonicalNameFallback, "zone" end

    return nil, string.format(
        "No discovered wayshrine could be resolved for the current objective of %s.",
        clean(quest.name or quest.zone or quest.zoneName, "that quest")
    )
end

function T:TravelToNearestQuestStarterWayshrine(quest)
    local entry, matchTypeOrReason = self:GetNearestWayshrineForQuestSelection(quest)
    if not entry then
        EPC:Print(matchTypeOrReason or "No discovered wayshrine was found for that quest.")
        return false
    end

    if matchTypeOrReason == "pledge-turnin" then
        local enclave = entry.pledgeEnclave or self:GetUndauntedEnclaveForPlayer()
        EPC:Print(string.format(
            "Undaunted pledge turn-in: routing to your alliance enclave in %s, %s via %s.",
            enclave and enclave.city or "your alliance city",
            enclave and enclave.zone or "the alliance zone",
            entry.name
        ))
    elseif matchTypeOrReason == "objective" then
        EPC:Print(string.format("Nearest discovered wayshrine to the active quest objective: %s.", entry.name))
    elseif matchTypeOrReason == "quest-map-objective" then
        EPC:Print(string.format("Quest destination resolved from ESO's quest map; traveling to the nearest discovered wayshrine: %s.", entry.name))
    elseif matchTypeOrReason == "quest-condition-map" then
        EPC:Print(string.format("Quest objective resolved from ESO's active condition map; traveling to a discovered wayshrine in that destination zone: %s.", entry.name))
    elseif matchTypeOrReason == "quest-ending-map" then
        EPC:Print(string.format("Quest hand-in destination resolved from ESO's ending map; traveling to a discovered wayshrine in that destination zone: %s.", entry.name))
    elseif string.find(tostring(matchTypeOrReason or ""), "overland%-container") then
        EPC:Print(string.format("Quest objective resolved to the containing overland zone%s; traveling via %s.",
            entry.resolvedQuestZoneName and (" (" .. entry.resolvedQuestZoneName .. ")") or "", entry.name))
    elseif matchTypeOrReason == "quest-map-zone" then
        EPC:Print(string.format("Quest destination resolved from ESO's quest map; traveling to a discovered wayshrine in that zone: %s.", entry.name))
    elseif matchTypeOrReason == "map-fallback" then
        EPC:Print(string.format("Using a discovered wayshrine on the selected quest's zone map: %s.", entry.name))
    else
        EPC:Print(string.format(
            "Traveling toward %s via %s. ESO does not expose exact coordinates for unaccepted quest starters, so this route uses the quest zone.",
            clean(quest and quest.name, "the selected quest"),
            entry.name
        ))
    end

    return self:TravelToWayshrineNode(entry.nodeIndex, entry.name)
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


-- Guild leader primary-home travel -------------------------------------------------
-- ESO exposes guild leaders through GetGuildInfo()/guild ranks and allows visiting
-- another player's primary residence with JumpToHouse(displayName). The game owns
-- house permissions/access checks; the Suite only issues the requested jump.
function T:GetGuildLeaderHomeOptions()
    local rows = {}
    local guildCount = 0
    if type(GetNumGuilds) == "function" then
        local ok, n = pcall(GetNumGuilds)
        if ok then guildCount = safeNumber(n, 0) end
    end

    for guildIndex = 1, guildCount do
        local guildId = nil
        if type(GetGuildId) == "function" then
            local ok, id = pcall(GetGuildId, guildIndex)
            if ok then guildId = id end
        end
        if guildId then
            local guildName = "Guild " .. tostring(guildIndex)
            if type(GetGuildName) == "function" then
                local ok, name = pcall(GetGuildName, guildId)
                if ok then guildName = clean(name, guildName) end
            end

            local leaderName = ""
            if type(GetGuildInfo) == "function" then
                local ok, _, _, returnedLeader = pcall(GetGuildInfo, guildId)
                if ok then leaderName = clean(returnedLeader, "") end
            end

            -- Fallback for clients/API revisions where GetGuildInfo does not provide
            -- a usable leader display name: find the roster member with guild-master rank.
            if leaderName == "" and type(GetNumGuildMembers) == "function"
                and type(GetGuildMemberInfo) == "function" then
                local okCount, count = pcall(GetNumGuildMembers, guildId)
                count = okCount and safeNumber(count, 0) or 0
                for memberIndex = 1, count do
                    local okInfo, displayName, _, rankIndex = pcall(GetGuildMemberInfo, guildId, memberIndex)
                    if okInfo and displayName and displayName ~= "" then
                        local isMaster = false
                        if type(IsGuildRankGuildMaster) == "function" and rankIndex ~= nil then
                            local okMaster, result = pcall(IsGuildRankGuildMaster, guildId, rankIndex)
                            isMaster = okMaster and result == true
                        end
                        if isMaster then
                            leaderName = clean(displayName, "")
                            break
                        end
                    end
                end
            end

            rows[#rows + 1] = {
                guildId = guildId,
                guildName = guildName,
                leaderName = leaderName,
                label = leaderName ~= "" and (guildName .. " - " .. leaderName) or (guildName .. " - Leader unavailable"),
            }
        end
    end

    table.sort(rows, function(a,b) return lower(a.guildName or "") < lower(b.guildName or "") end)
    return rows
end

function T:GetSelectedGuildLeaderHome()
    local options = self:GetGuildLeaderHomeOptions()
    if #options == 0 then
        self.selectedGuildLeaderGuildId = nil
        return nil, options
    end

    local wanted = tonumber(self.selectedGuildLeaderGuildId)
    if wanted then
        for _, row in ipairs(options) do
            if tonumber(row.guildId) == wanted then return row, options end
        end
    end

    self.selectedGuildLeaderGuildId = options[1].guildId
    return options[1], options
end

function T:SelectGuildLeaderGuild(guildId)
    self.selectedGuildLeaderGuildId = tonumber(guildId) or guildId
    if EPC.RefreshNow then EPC:RefreshNow("guild-leader-home-selection") end
end

function T:TravelToSelectedGuildLeaderHome()
    local selected = self:GetSelectedGuildLeaderHome()
    if not selected then
        EPC:Print("You are not currently in a guild.")
        return
    end
    if clean(selected.leaderName, "") == "" then
        EPC:Print("ESO did not expose the leader for " .. tostring(selected.guildName or "that guild") .. ".")
        return
    end

    local canLeave, reason = self:CanLeaveNow()
    if not canLeave then
        EPC:Print(tostring(reason or "Travel is currently unavailable") .. ".")
        return
    end

    local leader = clean(selected.leaderName, "")
    local own = clean(type(GetDisplayName) == "function" and GetDisplayName() or "", "")

    if leader == own then
        if type(GetHousingPrimaryHouse) == "function" and type(RequestJumpToHouse) == "function" then
            local okHouse, houseId = pcall(GetHousingPrimaryHouse)
            houseId = okHouse and safeNumber(houseId, 0) or 0
            if houseId > 0 then
                EPC:Print("Traveling to your primary residence for " .. tostring(selected.guildName or "guild") .. ".")
                local ok = pcall(RequestJumpToHouse, houseId, false)
                if not ok then EPC:Print("ESO rejected the house travel request.") end
                return
            end
        end
        EPC:Print("You are the guild leader, but ESO did not expose a primary residence to travel to.")
        return
    end

    if type(JumpToHouse) ~= "function" then
        EPC:Print("Guild leader home travel API is unavailable.")
        return
    end

    EPC:Print("Traveling to " .. leader .. "'s primary residence (" .. tostring(selected.guildName or "guild") .. ").")
    local ok = pcall(JumpToHouse, leader)
    if not ok then
        EPC:Print("ESO rejected the house travel request. The leader may not have an accessible primary residence.")
    end
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
