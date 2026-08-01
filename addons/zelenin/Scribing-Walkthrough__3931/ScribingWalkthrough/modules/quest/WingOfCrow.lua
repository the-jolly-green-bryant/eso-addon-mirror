local class = ZO_InitializingObject:Subclass()
scribingWalkthroughQuestWingOfCrow = class

local function calculateDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function findNearestNpc(playerCoords, npcCoords)
    local mapId, x, z = playerCoords.mapId, playerCoords.x, playerCoords.z
    local minDistance = math.huge
    local nearestNpcIndex = -1

    for i = 1, #npcCoords do
        local fMapId, fpx, fpz = npcCoords[i].mapId, npcCoords[i].x, npcCoords[i].z
        if fMapId == mapId then
            local distance = calculateDistance(x, z, fpx, fpz)

            if distance < minDistance and distance < 0.02 then
                minDistance = distance
                nearestNpcIndex = i
            end
        end
    end

    return npcCoords[nearestNpcIndex]
end

function class:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sWingOfCrow", self.owner.name)

    self.npcs = {
        -- Ulfsild's Echo of Mystery
        { mapId = 2541, x = 0.430, z = 0.327, answer = 3 },
        -- Ulfsild's Echo of Charity
        { mapId = 2541, x = 0.514, z = 0.244, answer = 2 },
        -- Ulfsild's Echo of Loyalty
        { mapId = 2541, x = 0.598, z = 0.329, answer = 1 },
    }

    local function unregister()
        EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_CONVERSATION_UPDATED)
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CHATTER_BEGIN, function(eventCode, optionCount, debugSource)
        unregister()

        local mapId = GetCurrentMapId()
        if mapId ~= 2541 or optionCount == 0 then
            return
        end

        local normalizedX, normalizedZ, heading, isShownInCurrentMap = GetMapPlayerPosition("player")
        local playerCoords = { mapId = mapId, x = normalizedX, z = normalizedZ }

        local npc = findNearestNpc(playerCoords, self.npcs)
        if not npc then
            return
        end

        for i = 1, optionCount do
            local optionString, optionType, optionalArgument, isImportant, chosenBefore = GetChatterOption(i)
            if optionType == CHATTER_START_TALK then
                EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CONVERSATION_UPDATED, function(eventCode, conversationBodyText, conversationOptionCount)
                    if conversationOptionCount == 3 then
                        SelectChatterOption(npc.answer)
                    else
                        EndInteraction(INTERACTION_CONVERSATION)
                    end
                end)

                SelectChatterOption(i)
                return
            end
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_INTERACTION_ENDED, function(eventCode, interactType, cancelContext)
        if interactType == INTERACTION_CONVERSATION then
            unregister()
        end
    end)
end