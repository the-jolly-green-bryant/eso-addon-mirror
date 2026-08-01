local MARK_TYPE_QUEST = nil
local EVENT_NAMESPACE = 'IMP_CART_CURRENT_QUEST'

local markerToQuestIndex = setmetatable({}, {__mode='k'})

local function onReticleOver(marker)
    return GetJournalQuestInfo(markerToQuestIndex[marker])
end

local CURRENT_QUEST_INDEX = nil
local function addMarkForQuestIndex(questIndex)
    if not questIndex then return end
    CURRENT_QUEST_INDEX = questIndex  -- it was in different order b4 v15, can lead to bugs, check in the future

    local steps = WORLD_MAP_QUEST_BREADCRUMBS.conditionDataToPosition[questIndex]
    if not steps then return end

    local conditions = steps[#steps]
    if not conditions then return end

    for i = 1, #conditions do
        local data = conditions[i]
        if not data then return end

        local color
        if data.insideCurrentMapWorld then
            color = ImperialCartographer.sv.questTracker.markerColor
        else
            color = ImperialCartographer.sv.questTracker.offmapMarkerColor
        end

        local nwX, nwZ = data.xLoc, data.yLoc
        -- df('nwX: %f, nwZ: %f', nwX, nwZ)

        local zoneId, prwX, prwY, prwZ = GetUnitRawWorldPosition('player')
        local convX, convZ = ImperialCartographer.Calculations.GetNWToRNWConversionFunctions(zoneId, prwX, prwY, prwZ)

        local rnwX, rnwZ = convX(nwX), convZ(nwZ)

        local calibration = {ImperialCartographer.Coordinates.GetCalibration(zoneId)}
        local rwX, rwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(rnwX, rnwZ, calibration)
        local rwY = 0

        -- local rwY = IMP_CART_GetApproximateYFromHarvest(rwX, rwZ)  -- TODO 

        local texture = ImperialCartographer.sv.questTracker.texture
        local size = ImperialCartographer.sv.defaultPois.markerSize

        local mark, markIndex = ImperialCartographer.MarksManager:AddMark(MARK_TYPE_QUEST, data, {rwX, rwY, rwZ}, texture, size, color)
        -- mark.questIndex = questIndex
        markerToQuestIndex[mark] = questIndex
        -- mark.distanceLabel:SetFont(('$(BOLD_FONT)|$(KB_%d)|soft-shadow-thick'):format(ImperialCartographer.sv.defaultPois.fontSize or 20))
        mark.control:SetClampedToScreen(true)
        mark.control:SetClampedToScreenInsets(-24, -24, 24, 48)
        -- mark.insideCurrentMapWorld = data.insideCurrentMapWorld  -- TODO: is it possible to add zone name to offmap quest?
    end
end


local INITIALIZED = false  -- TODO: create dedicated class
EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
    if not ImperialCartographer.sv.questTracker.enabled then return end
    local sv = ImperialCartographer.sv.questTracker

    if not INITIALIZED then
        MARK_TYPE_QUEST = ImperialCartographer.MarksManager:AddMarkType(
            function() addMarkForQuestIndex(CURRENT_QUEST_INDEX) end,
            true,
            false,
            onReticleOver,
            sv.fontSize,
            LibImplex.Systems.KeepOnPlayersHeight
        )

        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_LEADER_TO_FOLLOWER_SYNC, function(_, messageOrigin, syncType, currentSceneName, nextSceneName)
            if currentSceneName == 'worldMap' and nextSceneName == 'hud' then
                local zoneId = GetUnitWorldPosition('player')
                local mapIndex = GetMapIndexByZoneId(zoneId)
                ZO_WorldMap_SetMapByIndex(mapIndex)
                WORLD_MAP_QUEST_BREADCRUMBS:RefreshQuest(CURRENT_QUEST_INDEX)
            end
        end)

        ZO_PostHook(WORLD_MAP_QUEST_BREADCRUMBS, 'AddQuestConditionPosition', function(self_, conditionData, positionData)
            local questIndex, stepIndex, conditionIndex = conditionData.questIndex, conditionData.stepIndex, conditionData.conditionIndex
            if questIndex ~= CURRENT_QUEST_INDEX then return end

            ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_QUEST)
        end)

        ZO_PostHook(ZO_Tracker, 'BeginTracking', function(self_, trackType, questIndex)
            if trackType ~= TRACK_TYPE_QUEST then return end
            if CURRENT_QUEST_INDEX == questIndex then return end

            CURRENT_QUEST_INDEX = questIndex
            ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_QUEST)
        end)

        function IMP_CART_UpdateQuestTrackerDistanceLabelFontSize(value)
            ImperialCartographer.MarksManager:SetDistanceLabelFontSize(MARK_TYPE_QUEST, value)
            ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_QUEST)
        end

        INITIALIZED = true
    end

    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.tracked and FOCUSED_QUEST_TRACKER.tracked[1] and FOCUSED_QUEST_TRACKER.tracked[1].arg1 then
        CURRENT_QUEST_INDEX = FOCUSED_QUEST_TRACKER.tracked[1].arg1
        ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_QUEST)
    end
end)
