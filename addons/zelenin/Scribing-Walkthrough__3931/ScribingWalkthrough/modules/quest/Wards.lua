local class = ZO_InitializingObject:Subclass()
scribingWalkthroughQuestWards = class

local secondEraQuestId = 7104 -- The Second Era of Scribing
local indrikQuestId = 7197 -- The Wing of the Indrik
local dragonQuestId = 7203 -- The Wing of the Dragon
local netchQuestId = 7204 -- The Wing of the Netch
local gryphonQuestId = 7217 -- The Wing of the Gryphon
local crowQuestId = 7220 -- The Wing of the Crow

-- Dragon quest
-- Riddle of Battle - WB in Reaper's March
-- Riddle of War - Haynote Cave, Cracked Wood Cave, Toadstool Hollow delves in Cyro
-- Riddle of Moon 0/4 - Moonmont
-- Riddle of Hunt 0/15 - mobs in Reaper's March
-- Riddle of Rich 0/2 - Luminary's Safeboxes in cities
-- Riddle of Game 0/2 - ToT npc

local ownerDisplayNames = {
    ["@zelenin"] = true,
    ["@zelenin_av"] = true,
}

local function calculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function findNearestFocalPoint(playerCoords, focalPointCoords)
    local mapId, x, z = playerCoords.mapId, playerCoords.x, playerCoords.z
    local minDistance = math.huge
    local nearestFocalPointIndex = -1

    for i = 1, #focalPointCoords do
        local fMapId, fpx, fpz = focalPointCoords[i].mapId, focalPointCoords[i].x, focalPointCoords[i].z
        if fMapId == mapId then
            local distance = calculateDistance(x, z, fpx, fpz)

            if distance < minDistance and distance < 0.05 then
                minDistance = distance
                nearestFocalPointIndex = i
            end
        end
    end

    return focalPointCoords[nearestFocalPointIndex]
end

local function haveQuest(questId)
    local questName = GetQuestName(questId)
    for i = 1, MAX_JOURNAL_QUESTS, 1 do
        if IsValidQuestIndex(i) then
            local name = GetJournalQuestName(i)
            if name == questName then
                return true
            end
        end
    end
    return false
end

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sQuestWards", self.owner.name)

    self.waypoint = Lib3DArrow:CreateArrow({
        depthBuffer = false,
        arrowMagnitude = 5,
        arrowScale = 1,
        arrowHeight = 1,
        arrowColour = "FF0000",

        distanceDigits = 4,
        distanceScale = 25,
        distanceColour = "FFFFFF",

        markerColour = "FF0000",
        markerScale = 1,
    })

    local function questHandler()
        self.isSecondEraActive = haveQuest(secondEraQuestId)
        self.isIndrikActive = haveQuest(indrikQuestId)
        self.isDragonActive = haveQuest(dragonQuestId)
        self.isNetchActive = haveQuest(netchQuestId)
        self.isGryphonActive = haveQuest(gryphonQuestId)
        self.isCrowActive = haveQuest(crowQuestId)
    end

    questHandler()

    local icon1424 = false
    local icon1488 = false
    local icon1291 = false
    local icon999 = false
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(eventCode, initial)
        questHandler()
        self.waypoint:SetTarget(0, 0)

        local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
        local mapId = GetCurrentMapId()
        if self.isGryphonActive and zoneId == 1424 and not icon1424 then
            OSI.CreatePositionIcon(30286, 58813, 22338, self.owner.addonData.resolveFilePath("assets/1.dds"), 256, { 1, 1, 1 }, 0.25)
            OSI.CreatePositionIcon(26010, 58813, 26526, self.owner.addonData.resolveFilePath("assets/2.dds"), 256, { 1, 1, 1 }, 0.25)
            OSI.CreatePositionIcon(22143, 58814, 20014, self.owner.addonData.resolveFilePath("assets/3.dds"), 256, { 1, 1, 1 }, 0.25)
            OSI.CreatePositionIcon(23931, 57358, 23294, self.owner.addonData.resolveFilePath("assets/4.dds"), 256, { 1, 1, 1 }, 0.25)
            icon1424 = true
        end
        if self.isCrowActive and zoneId == 1488 and not icon1488 then
            OSI.CreatePositionIcon(48545, 37842, 99513, self.owner.addonData.resolveFilePath("assets/1.dds"), 256, { 1, 1, 1 }, 0.25)
            OSI.CreatePositionIcon(51548, 37871, 102501, self.owner.addonData.resolveFilePath("assets/2.dds"), 256, { 1, 1, 1 }, 0.25)
            icon1488 = true
        end
        if self.isGryphonActive and zoneId == 1291 and not icon1291 then
            OSI.CreatePositionIcon(59199, 51238, 110204, self.owner.addonData.resolveFilePath("assets/1.dds"), 512, { 1, 1, 1 }, 0.25)
            icon1291 = true
        end
        if self.isGryphonActive and zoneId == 999 and not icon999 then
            OSI.CreatePositionIcon(44536, 30890, 11464, self.owner.addonData.resolveFilePath("assets/1.dds"), 512, { 1, 1, 1 }, 0.25)
            OSI.CreatePositionIcon(23270, 30314, 31097, self.owner.addonData.resolveFilePath("assets/2.dds"), 512, { 1, 1, 1 }, 0.25)
            icon999 = true
        end
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_ADDED, function(eventCode, journalIndex, questName, objectiveName)
        questHandler()
    end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_QUEST_REMOVED, function(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
        questHandler()
    end)

    local trueSightIds = { 203437, 218032 }
    for _, id in ipairs(trueSightIds) do
        local handlerName = string.format("%s-%d-%d", self.name, EVENT_COMBAT_EVENT, id)
        EVENT_MANAGER:RegisterForEvent(handlerName, EVENT_COMBAT_EVENT, function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            if result == ACTION_RESULT_EFFECT_GAINED then
                local mapId = GetCurrentMapId()
                local normalizedX, normalizedZ, heading, isShownInCurrentMap = GetMapPlayerPosition("player")
                local playerCoords = { mapId = mapId, x = normalizedX, z = normalizedZ }
                local focalPoints = {}
                local currentFocalPoint = nil

                if self.isIndrikActive then
                    focalPoints = {
                        { mapId = 143, x = 0.585, z = 0.813, ward = { x = 0.594, z = 0.819 } },
                        { mapId = 143, x = 0.598, z = 0.825, ward = { x = 0.588, z = 0.832 } },
                        { mapId = 143, x = 0.583, z = 0.825, ward = { x = 0.596, z = 0.828 } },
                        { mapId = 179, x = 0.222, z = 0.668, ward = { x = 0.227, z = 0.564 } },
                        { mapId = 179, x = 0.170, z = 0.603, ward = { x = 0.069, z = 0.597 } },
                        { mapId = 179, x = 0.343, z = 0.604, ward = { x = 0.300, z = 0.457 } },
                        { mapId = 143, x = 0.686, z = 0.622, ward = { x = 0.679, z = 0.624 } },
                        { mapId = 143, x = 0.693, z = 0.624, ward = { x = 0.695, z = 0.633 } },
                        { mapId = 143, x = 0.686, z = 0.636, ward = { x = 0.684, z = 0.643 } },
                    }
                end
                if self.isDragonActive then
                    focalPoints = {
                        { mapId = 304, x = 0.180, z = 0.346, ward = { x = 0.091, z = 0.378 } },
                        { mapId = 304, x = 0.476, z = 0.674, ward = { x = 0.563, z = 0.631 } },
                        { mapId = 304, x = 0.735, z = 0.637, ward = { x = 0.731, z = 0.580 } },
                        { mapId = 256, x = 0.258, z = 0.694, ward = { x = 0.263, z = 0.682 } },
                        { mapId = 256, x = 0.249, z = 0.699, ward = { x = 0.238, z = 0.698 } },
                        { mapId = 256, x = 0.235, z = 0.713, ward = { x = 0.243, z = 0.716 } },
                        { mapId = 256, x = 0.267, z = 0.267, ward = { x = 0.274, z = 0.273 } },
                        { mapId = 256, x = 0.273, z = 0.260, ward = { x = 0.283, z = 0.261 } },
                        { mapId = 256, x = 0.235, z = 0.250, ward = { x = 0.235, z = 0.250 } },
                    }
                end
                if self.isNetchActive then
                    focalPoints = {
                        { mapId = 1060, x = 0.764, z = 0.357, ward = { x = 0.760, z = 0.362 } },
                        { mapId = 1060, x = 0.759, z = 0.363, ward = { x = 0.749, z = 0.364 } },
                        { mapId = 1060, x = 0.772, z = 0.362, ward = { x = 0.778, z = 0.364 } },
                        { mapId = 1290, x = 0.483, z = 0.551, ward = { x = 0.539, z = 0.509 } },
                        { mapId = 1290, x = 0.701, z = 0.616, ward = { x = 0.702, z = 0.506 } },
                        { mapId = 1290, x = 0.243, z = 0.505, ward = { x = 0.317, z = 0.432 } },
                        { mapId = 1283, x = 0.514, z = 0.612, ward = { x = 0.523, z = 0.769 } },
                        { mapId = 1283, x = 0.712, z = 0.502, ward = { x = 0.578, z = 0.412 } },
                        { mapId = 1283, x = 0.488, z = 0.553, ward = { x = 0.573, z = 0.520 } },
                    }
                end
                if self.isGryphonActive then
                    focalPoints = {
                        { mapId = 125, x = 0.395, z = 0.478, ward = { x = 0.394, z = 0.490 } },
                        { mapId = 125, x = 0.410, z = 0.466, ward = { x = 0.410, z = 0.477 } },
                        { mapId = 125, x = 0.449, z = 0.472, ward = { x = 0.437, z = 0.478 } },
                        { mapId = 198, x = 0.683, z = 0.508, ward = { x = 0.602, z = 0.515 } },
                        { mapId = 198, x = 0.581, z = 0.564, ward = { x = 0.517, z = 0.498 } },
                        { mapId = 198, x = 0.574, z = 0.356, ward = { x = 0.566, z = 0.456 } },
                        { mapId = 703, x = 0.228, z = 0.345, ward = { x = 0.178, z = 0.329 } },
                        { mapId = 703, x = 0.640, z = 0.767, ward = { x = 0.523, z = 0.652 } },
                        { mapId = 703, x = 0.767, z = 0.637, ward = { x = 0.756, z = 0.566 } },
                    }
                end

                currentFocalPoint = findNearestFocalPoint(playerCoords, focalPoints)
                if currentFocalPoint == nil then
                    return
                end

                self.waypoint:SetTarget(currentFocalPoint.ward.x, currentFocalPoint.ward.z)
            end

            if result == ACTION_RESULT_EFFECT_FADED then
                self.waypoint:SetTarget(0, 0)
            end
        end)
        EVENT_MANAGER:AddFilterForEvent(handlerName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id)
        EVENT_MANAGER:AddFilterForEvent(handlerName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
    end

    if ownerDisplayNames[GetDisplayName()] then
        SLASH_COMMANDS["/scribing-location-data"] = function(cmd)
            local mapId = GetCurrentMapId()
            local normalizedX, normalizedZ, heading, isShownInCurrentMap = GetMapPlayerPosition("player")
            local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition("player")
            self.owner:Log(string.format("map: [%d] %s x: %.03f z: %.03f", mapId, GetMapNameById(mapId), normalizedX, normalizedZ))
            self.owner:Log(string.format("zone: [%d] %s x: %d y: %d z: %d", zoneId, GetZoneNameById(zoneId), worldX, worldY, worldZ))
        end
    end
end