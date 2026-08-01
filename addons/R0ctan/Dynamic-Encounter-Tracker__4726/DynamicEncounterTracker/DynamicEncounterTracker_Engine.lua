local DE = DynamicEncounterTracker

local WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST = WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST

local function NormalizeTexturePath(texturePath)
    if type(texturePath) ~= "string" then
        return ""
    end
    return zo_strlower(texturePath)
end

local function NormalizeLocalizedParagraph(text)
    if type(text) ~= "string" then
        return nil
    end
    text = string.gsub(text, "\r", "")
    text = string.gsub(text, "[ \t]*\n[ \t]*", " ")
    text = string.gsub(text, "%s+", " ")
    text = zo_strtrim(text)
    return text ~= "" and text or nil
end


function DE:ClearCurrentStepState()
    self.state.eventName = nil
    self.state.phaseName = nil
    self.state.phaseHintText = nil
    self.state.currentStepDefId = nil
    self.state.currentStepSource = nil
    self.state.currentStepOrdinal = nil
    self.state.currentStepTotal = nil
    self.state.currentMapLocationIndex = nil
    self.state.currentMapLocationSource = nil
    self.state.currentMapLocationHeader = nil
    self.state.currentMapLocationDescription = nil
    self.state.currentMapLocationCandidateCount = 0
    self.state.currentMapLocationScanReason = nil
    self.state.isParticipating = false
    self.state.participatingInstanceId = nil
    self.state.participatingStepDefId = nil
    self.state.currentProgress = nil
    self.state.maxProgress = nil
    self.state.progressSource = nil
    self.state.lastProgressObservedAt = nil
end

function DE:ResetEncounterTransientState()
    self:ClearCurrentStepState()
    self.state.participatedSteps = {}
    self.state.participationDisplayState = self.PARTICIPATION_UNKNOWN
    self.state.triggeredChestRules = {}
    self.state.lastChestRuleId = nil
    self.state.chestCandidateCount = 0
    self.state.chestHintText = nil
    self.state.chestHintUntil = nil
    self.state.centerChestAlertText = nil
    self.state.centerChestAlertUntil = nil
    if self.HideCenterChestAlert then
        self:HideCenterChestAlert()
    end
    self.state.lastChestTriggerKey = nil
    self.state.lastChestTriggeredAt = nil
    self.state.noActiveSince = nil
end

function DE:GetParticipatedStepListText()
    local participatedSteps = self.state.participatedSteps or {}
    local stepIds = {}
    for stepDefId, participated in pairs(participatedSteps) do
        if participated then
            stepIds[#stepIds + 1] = tonumber(stepDefId) or stepDefId
        end
    end
    table.sort(stepIds, function(a, b) return tonumber(a) < tonumber(b) end)

    local parts = {}
    for _, stepDefId in ipairs(stepIds) do
        parts[#parts + 1] = tostring(stepDefId)
    end
    return #parts > 0 and table.concat(parts, ",") or "-"
end

function DE:GetConfiguredChestRules()
    local eventData = self.state.eventData
    if not eventData or type(eventData.chestRules) ~= "table" then
        return nil
    end
    return eventData.chestRules
end

function DE:HasConfiguredChestRules()
    return self:GetConfiguredChestRules() ~= nil
end

function DE:GetConfiguredChestRuleCount()
    local rules = self:GetConfiguredChestRules()
    if not rules then
        return 0
    end

    local count = 0
    for _, rule in pairs(rules.stepStarts or {}) do
        if type(rule) == "table" and rule.id then
            count = count + 1
        end
    end
    if type(rules.encounterEnd) == "table" and rules.encounterEnd.id then
        count = count + 1
    end
    return count
end

function DE:MarkStepParticipation(stepDefId)
    if type(stepDefId) ~= "number" or stepDefId == 0 then
        return false
    end

    self.state.participationDisplayState = self.PARTICIPATION_DETECTED
    self.state.participatedSteps = self.state.participatedSteps or {}
    if self.state.participatedSteps[stepDefId] then
        return false
    end

    self.state.participatedSteps[stepDefId] = true
    return true
end

function DE:TriggerConfiguredChestRule(rule, source)
    if not rule or not rule.id then
        return false
    end

    self.state.triggeredChestRules = self.state.triggeredChestRules or {}
    if self.state.triggeredChestRules[rule.id] then
        return false
    end

    local requiredStep = rule.requiresParticipationInStep
    local participated = requiredStep and self.state.participatedSteps and self.state.participatedSteps[requiredStep]
    if not participated then
        self:RecordDiagnosticSnapshot("chest-rule-not-eligible:" .. tostring(rule.id), true)
        return false
    end

    self.state.triggeredChestRules[rule.id] = true
    self.state.lastChestRuleId = rule.id
    local nextCount = (self.state.chestCandidateCount or 0) + 1
    self.state.chestCandidateCount = zo_max(nextCount, rule.chestNumber or nextCount)

    local isFinal = rule.notificationType == "final"
    local hintText = isFinal
        and self:T("DE_CHEST_HINT_FINAL")
        or self:T("DE_CHEST_HINT_REWARD_FMT", rule.chestNumber or self.state.chestCandidateCount)
    local centerText = isFinal
        and self:T("DE_CHEST_ALERT_FINAL")
        or self:T("DE_CHEST_ALERT_REWARD")

    if self.sv.showChestHints then
        self.state.chestHintText = hintText
        self.state.chestHintUntil = GetTimeStamp() + self.chestHintDurationSeconds
    end
    if self.sv.showChestHints and self.sv.showCenterChestAlert and self.ShowCenterChestAlert then
        self:ShowCenterChestAlert(centerText)
    end

    self.state.lastChestTriggerKey = "configured:" .. tostring(rule.id)
    self.state.lastChestTriggeredAt = GetTimeStamp()
    self:RecordDiagnosticSnapshot(source or ("chest-rule:" .. tostring(rule.id)), true)
    return true
end

function DE:MaybeTriggerConfiguredStepChest(previousStepDefId, newStepDefId)
    local rules = self:GetConfiguredChestRules()
    local rule = rules and rules.stepStarts and rules.stepStarts[newStepDefId]
    if not rule then
        return false
    end

    if rule.requiresPreviousStep and previousStepDefId ~= rule.requiresPreviousStep then
        return false
    end

    return self:TriggerConfiguredChestRule(
        rule,
        string.format(
            "chest-rule:step-start:%s->%s",
            tostring(previousStepDefId or "-"),
            tostring(newStepDefId or "-")
        )
    )
end

function DE:MaybeTriggerConfiguredEndChest()
    local rules = self:GetConfiguredChestRules()
    local rule = rules and rules.encounterEnd
    if not rule then
        return false
    end
    return self:TriggerConfiguredChestRule(rule, "chest-rule:encounter-ended")
end

function DE:ExpireChestHint()
    if self.state.chestHintUntil and GetTimeStamp() >= self.state.chestHintUntil then
        self.state.chestHintUntil = nil
        self.state.chestHintText = nil
        self:RecordDiagnosticSnapshot("chest-hint-expired", true)
        return true
    end
    return false
end

function DE:SetProgressState(currentProgress, maxProgress, source, isParticipating, participatingInstanceId, stepDefId)
    local sourceText = source or "unknown"
    local isParentFallback = string.find(sourceText, ":parent-progress", 1, true) ~= nil
    local preserveKnownProgress = isParentFallback
        and (type(maxProgress) ~= "number" or maxProgress <= 0)
        and type(self.state.maxProgress) == "number"
        and self.state.maxProgress > 0
        and self.state.currentStepDefId ~= nil

    local storedCurrentProgress = preserveKnownProgress and self.state.currentProgress or currentProgress
    local storedMaxProgress = preserveKnownProgress and self.state.maxProgress or maxProgress
    local storedProgressSource = preserveKnownProgress and self.state.progressSource or sourceText

    local changed = self.state.currentProgress ~= storedCurrentProgress
        or self.state.maxProgress ~= storedMaxProgress
        or self.state.isParticipating ~= (isParticipating == true)
        or self.state.participatingInstanceId ~= participatingInstanceId

    self.state.currentProgress = storedCurrentProgress
    self.state.maxProgress = storedMaxProgress
    self.state.progressSource = storedProgressSource
    if not preserveKnownProgress then
        self.state.lastProgressObservedAt = GetTimeStamp()
    end
    self.state.isParticipating = isParticipating == true
    self.state.participatingInstanceId = participatingInstanceId
    self.state.participatingStepDefId = stepDefId

    if self.state.isParticipating then
        self:MarkStepParticipation(stepDefId or self.state.currentStepDefId)
    end

    if changed then
        self:RecordDiagnosticSnapshot(source or "progress-updated", true)
    end
    return changed
end

function DE:RefreshProgressState(source)
    if self.state.status ~= self.STATUS_ACTIVE then
        return false
    end

    local participatingInstanceId, stepDefId = GetParticipatingWorldEventStep()
    if participatingInstanceId ~= 0 and stepDefId ~= 0 and self:IsTrackedInstanceForCurrentZone(participatingInstanceId) then
        self:ObserveWorldEventStep(participatingInstanceId, stepDefId, source or "GetParticipatingWorldEventStep")
        local currentProgress, maxProgress = GetWorldEventCurrentStepProgress(participatingInstanceId)
        self:SetProgressState(
            currentProgress,
            maxProgress,
            source or "GetParticipatingWorldEventStep",
            true,
            participatingInstanceId,
            stepDefId
        )
        return true
    end

    local fallbackCurrent = nil
    local fallbackMax = nil
    local fallbackSource = source or "progress-unavailable"
    local eventData = self.state.eventData
    if eventData and self.state.parentActive then
        local succeeded, currentProgress, maxProgress = pcall(
            GetWorldEventCurrentStepProgress,
            eventData.parentWorldEventInstanceId
        )
        if succeeded then
            fallbackCurrent = currentProgress
            fallbackMax = maxProgress
            fallbackSource = (source or "periodic-scan") .. ":parent-progress"
        end
    end

    self:SetProgressState(fallbackCurrent, fallbackMax, fallbackSource, false, nil, nil)
    return false
end

function DE:GetCurrentObservedPosition()
    local run = self.state.stepRun
    if not run then
        return nil, nil, nil
    end

    if self.state.currentStepDefId then
        for index = #run.sequence, 1, -1 do
            if run.sequence[index].stepDefId == self.state.currentStepDefId then
                return index, #run.sequence, "step"
            end
        end
    end

    if self.state.currentMapLocationIndex then
        for index = #run.mapLocationSequence, 1, -1 do
            if run.mapLocationSequence[index].locationIndex == self.state.currentMapLocationIndex then
                return index, #run.mapLocationSequence, "map"
            end
        end
    end

    return nil, nil, nil
end

function DE:GetConfiguredStepPosition(stepDefId)
    local eventData = self.state.eventData
    local sequence = eventData and eventData.knownStepSequence
    if type(sequence) ~= "table" or type(stepDefId) ~= "number" then
        return nil, nil
    end

    local previousOrdinal = self.state.currentStepOrdinal
    if previousOrdinal and sequence[previousOrdinal] == stepDefId then
        return previousOrdinal, #sequence
    end

    -- Prefer the next matching occurrence. This disambiguates repeated IDs such
    -- as step 27 in Bilsas Lieferung when the run has already progressed.
    if previousOrdinal then
        for index = previousOrdinal + 1, #sequence do
            if sequence[index] == stepDefId then
                return index, #sequence
            end
        end
    end

    local uniqueIndex = nil
    local matchCount = 0
    for index, configuredStepDefId in ipairs(sequence) do
        if configuredStepDefId == stepDefId then
            matchCount = matchCount + 1
            uniqueIndex = index
        end
    end

    if matchCount == 1 then
        return uniqueIndex, #sequence
    end

    return nil, #sequence
end

function DE:RefreshLearnedStepPosition()
    local previousOrdinal = self.state.currentStepOrdinal
    self.state.currentStepOrdinal = previousOrdinal
    self.state.currentStepTotal = nil

    local stepDefId = self.state.currentStepDefId
    local configuredOrdinal, configuredTotal = self:GetConfiguredStepPosition(stepDefId)
    if configuredTotal then
        self.state.currentStepTotal = configuredTotal
        if configuredOrdinal then
            self.state.currentStepOrdinal = configuredOrdinal
            return
        end
    end

    self.state.currentStepOrdinal = nil
    self.state.currentStepTotal = configuredTotal
    if not self:IsDebugEnabled() then
        return
    end

    local stableStepSequence = self:GetStableLearnedSequence(self.state.eventName)
    if stepDefId and stableStepSequence then
        for index, learnedStepDefId in ipairs(stableStepSequence) do
            if learnedStepDefId == stepDefId then
                self.state.currentStepOrdinal = index
                self.state.currentStepTotal = #stableStepSequence
                return
            end
        end
    end

    local locationIndex = self.state.currentMapLocationIndex
    local stableLocationSequence = self:GetStableLearnedLocationSequence(self.state.eventName)
    if locationIndex and stableLocationSequence then
        for index, learnedLocationIndex in ipairs(stableLocationSequence) do
            if learnedLocationIndex == locationIndex then
                self.state.currentStepOrdinal = index
                self.state.currentStepTotal = #stableLocationSequence
                return
            end
        end
    end
end

function DE:ParseLocalizedStepDescription(description)
    if type(description) ~= "string" or description == "" then
        return nil, nil
    end

    local normalized = string.gsub(description, "\r\n", "\n")
    normalized = string.gsub(normalized, "\r", "\n")

    local paragraphs = {}
    for paragraph in string.gmatch(normalized .. "\n\n", "(.-)\n%s*\n") do
        local clean = NormalizeLocalizedParagraph(paragraph)
        if clean then
            paragraphs[#paragraphs + 1] = clean
        end
    end

    if #paragraphs == 0 then
        local clean = NormalizeLocalizedParagraph(normalized)
        return clean, nil
    end

    local sectionText = paragraphs[1]
    local hintParts = {}
    for index = 2, #paragraphs do
        local hint = paragraphs[index]
        -- ESO commonly prefixes secondary paragraphs with a localized label
        -- such as "Hinweis:". The status row already has its own label, so a
        -- short leading paragraph label is removed language-independently.
        local prefix, remainder = string.match(hint, "^([^:]+):%s*(.+)$")
        if prefix and remainder and #prefix <= 32 then
            hint = remainder
        end
        hintParts[#hintParts + 1] = hint
    end

    local hintText = #hintParts > 0 and table.concat(hintParts, " ") or nil
    return sectionText, hintText
end

function DE:SetLocalizedPhaseDescription(description)
    local sectionText, hintText = self:ParseLocalizedStepDescription(description)
    if sectionText then
        self.state.phaseName = sectionText
        self.state.phaseHintText = hintText
        return true
    end
    return false
end

function DE:ObserveWorldEventStep(worldEventInstanceId, stepDefId, source)
    if self.state.status ~= self.STATUS_ACTIVE or not stepDefId or stepDefId == 0 then
        return false
    end
    if not self:GetTrackedWorldEventRole(worldEventInstanceId) then
        return false
    end

    local previousStepDefId = self.state.currentStepDefId
    local previousMapLocationIndex = self.state.currentMapLocationIndex
    local isStepChange = previousStepDefId ~= nil and previousStepDefId ~= stepDefId
    if isStepChange then
        -- No generic step heuristic; chests need explicit configured rules.
        if self:HasConfiguredChestRules() then
            self:MaybeTriggerConfiguredStepChest(previousStepDefId, stepDefId)
        end
        self.state.currentProgress = nil
        self.state.maxProgress = nil
        self.state.progressSource = nil
        self.state.phaseName = nil
        self.state.phaseHintText = nil
    end

    local stepName = GetWorldEventStepName(worldEventInstanceId, stepDefId)
    local stepDescription = GetWorldEventStepDescription(stepDefId)
    stepName = stepName ~= "" and stepName or nil
    stepDescription = stepDescription ~= "" and stepDescription or nil

    self.state.currentStepDefId = stepDefId
    self.state.currentStepSource = source or "unknown"
    if stepName then
        self.state.eventName = stepName
    end
    if stepDescription then
        self:SetLocalizedPhaseDescription(stepDescription)
    end

    if self:IsDebugEnabled() then
        local run = self.state.stepRun
        if not run then
            self:StartStepRun(false, "step-observed-without-start")
            run = self.state.stepRun
        end

        if stepName then
            run.eventName = stepName
        end
        if not run.firstStepObservedAt then
            run.firstStepObservedAt = GetTimeStamp()
        end

        local lastEntry = run.sequence[#run.sequence]
        local isNewStepObservation = not lastEntry or lastEntry.stepDefId ~= stepDefId
        if isNewStepObservation then
            run.sequence[#run.sequence + 1] = {
                stepDefId = stepDefId,
                name = stepName,
                description = stepDescription,
                observedAt = GetTimeStamp(),
                source = source or "unknown",
            }
            run.seen[stepDefId] = (run.seen[stepDefId] or 0) + 1
        end

        local zoneData = self:EnsureStepLearningZone(self.state.zoneId)
        local stepKey = tostring(stepDefId)
        local learnedStep = zoneData.steps[stepKey] or { seenCount = 0 }
        if isNewStepObservation then
            learnedStep.seenCount = (learnedStep.seenCount or 0) + 1
        end
        learnedStep.lastSeenAt = GetTimeStamp()
        learnedStep.lastSource = source or "unknown"
        learnedStep.lastEventName = stepName or learnedStep.lastEventName
        learnedStep.lastDescription = stepDescription or learnedStep.lastDescription
        zoneData.steps[stepKey] = learnedStep
    end

    self:RefreshLearnedStepPosition()
    if isStepChange or previousStepDefId == nil then
        self:RecordDiagnosticSnapshot(source or "step-observed", true)
    end
    return true
end

function DE:GetVisibleDynamicEncounterTrackerMapLocation()
    local playerZoneIndex = GetUnitZoneIndex("player")
    local mapZoneIndex = GetCurrentMapZoneIndex()

    if not playerZoneIndex or playerZoneIndex == 0 then
        return nil, {}, "player-zone-index-unavailable"
    end
    if not mapZoneIndex or mapZoneIndex == 0 then
        return nil, {}, "current-map-zone-index-unavailable"
    end
    if mapZoneIndex ~= playerZoneIndex then
        return nil, {}, string.format("map-zone-mismatch:%d!=%d", mapZoneIndex, playerZoneIndex)
    end

    local candidates = {}
    local expectedIcon = NormalizeTexturePath(self.dynamicEventMapLocationIcon)
    for locationIndex = 1, GetNumMapLocations() do
        if IsMapLocationVisible(locationIndex) then
            local icon, x, y = GetMapLocationIcon(locationIndex)
            if NormalizeTexturePath(icon) == expectedIcon then
                local header = GetMapLocationTooltipHeader(locationIndex)
                header = header ~= "" and header or nil
                local description = nil
                local collectDebugLines = self:IsDebugEnabled()
                local lines = collectDebugLines and {} or nil

                for lineIndex = 1, GetNumMapLocationTooltipLines(locationIndex) do
                    if IsMapLocationTooltipLineVisible(locationIndex, lineIndex) then
                        local lineIcon, name, groupingId, categoryName = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)
                        name = name ~= "" and name or nil
                        categoryName = categoryName ~= "" and categoryName or nil
                        if collectDebugLines then
                            lines[#lines + 1] = {
                                lineIndex = lineIndex,
                                icon = lineIcon,
                                name = name,
                                groupingId = groupingId,
                                categoryName = categoryName,
                            }
                        end

                        -- ESO indents name below categoryName only when they differ;
                        -- that indented name is the localized step description.
                        if not description and name and name ~= categoryName then
                            description = name
                        end
                    end
                end

                candidates[#candidates + 1] = {
                    locationIndex = locationIndex,
                    icon = icon,
                    x = x,
                    y = y,
                    header = header,
                    description = description,
                    lines = lines or {},
                }
            end
        end
    end

    if #candidates == 1 then
        return candidates[1], candidates, "single-visible-dynamic-location"
    end

    if #candidates > 1 then
        if self.state.currentMapLocationIndex then
            for _, candidate in ipairs(candidates) do
                if candidate.locationIndex == self.state.currentMapLocationIndex then
                    return candidate, candidates, "retained-previous-visible-location"
                end
            end
        end
        if self.state.eventName then
            for _, candidate in ipairs(candidates) do
                if candidate.header == self.state.eventName then
                    return candidate, candidates, "matched-current-api-header"
                end
            end
        end
        return nil, candidates, "multiple-visible-dynamic-locations"
    end

    return nil, candidates, "no-visible-dynamic-location"
end

function DE:ObserveMapLocationPhase(locationData, source, candidateCount, scanReason)
    if self.state.status ~= self.STATUS_ACTIVE or not locationData then
        return false
    end

    local previousLocationIndex = self.state.currentMapLocationIndex
    local isLocationChange = previousLocationIndex ~= nil and previousLocationIndex ~= locationData.locationIndex

    -- Map-location changes remain useful for phase detection, but never create
    -- chest notifications. A chest is shown only by explicit zone rules.
    self.state.currentMapLocationIndex = locationData.locationIndex
    self.state.currentMapLocationSource = source or "unknown"
    self.state.currentMapLocationHeader = locationData.header
    self.state.currentMapLocationDescription = locationData.description
    self.state.currentMapLocationCandidateCount = candidateCount or 1
    self.state.currentMapLocationScanReason = scanReason

    if locationData.header then
        self.state.eventName = locationData.header
    end
    if locationData.description and (isLocationChange or not self.state.currentStepDefId or not self.state.phaseName) then
        -- Keep the more specific API step description while the same map phase
        -- remains visible. A real map-location transition may update the fallback
        -- immediately until a new participating step description arrives.
        self:SetLocalizedPhaseDescription(locationData.description)
    end

    if self:IsDebugEnabled() then
        local run = self.state.stepRun
        if not run then
            self:StartStepRun(false, "map-location-observed-without-start")
            run = self.state.stepRun
        end

        if locationData.header then
            run.eventName = locationData.header
        end
        if not run.firstMapLocationObservedAt then
            run.firstMapLocationObservedAt = GetTimeStamp()
        end

        local lastEntry = run.mapLocationSequence[#run.mapLocationSequence]
        local isNewPhaseObservation = not lastEntry or lastEntry.locationIndex ~= locationData.locationIndex
        if isNewPhaseObservation then
            run.mapLocationSequence[#run.mapLocationSequence + 1] = {
                locationIndex = locationData.locationIndex,
                header = locationData.header,
                description = locationData.description,
                observedAt = GetTimeStamp(),
                source = source or "unknown",
            }
            run.mapLocationSeen[locationData.locationIndex] = (run.mapLocationSeen[locationData.locationIndex] or 0) + 1
        end

        local zoneData = self:EnsureStepLearningZone(self.state.zoneId)
        local locationKey = tostring(locationData.locationIndex)
        local learnedLocation = zoneData.mapLocations[locationKey] or { seenCount = 0 }
        if isNewPhaseObservation then
            learnedLocation.seenCount = (learnedLocation.seenCount or 0) + 1
        end
        learnedLocation.lastSeenAt = GetTimeStamp()
        learnedLocation.lastSource = source or "unknown"
        learnedLocation.lastHeader = locationData.header or learnedLocation.lastHeader
        learnedLocation.lastDescription = locationData.description or learnedLocation.lastDescription
        learnedLocation.lastX = locationData.x
        learnedLocation.lastY = locationData.y
        zoneData.mapLocations[locationKey] = learnedLocation
    end

    self:RefreshLearnedStepPosition()
    if isLocationChange or previousLocationIndex == nil then
        self:RecordDiagnosticSnapshot(source or "map-location-observed", true)
    end
    return true
end

function DE:RefreshMapLocationPhase()
    if self.state.status ~= self.STATUS_ACTIVE then
        return false
    end

    local locationData, candidates, reason = self:GetVisibleDynamicEncounterTrackerMapLocation()
    self.state.currentMapLocationCandidateCount = #candidates
    self.state.currentMapLocationScanReason = reason

    if locationData then
        return self:ObserveMapLocationPhase(locationData, "visible-map-location", #candidates, reason)
    end

    -- Keep a confirmed title/step; only the encounter's own end clears it.
    return false
end

function DE:GetZoneEncounterConfigs(zoneId)
    local configs = self.encountersByZoneId[zoneId]
    if type(configs) ~= "table" or #configs == 0 then
        return nil
    end
    return configs
end

function DE:GetCurrentZoneData()
    local zoneIndex = GetUnitZoneIndex("player")
    local zoneId = GetZoneId(zoneIndex)
    local zoneName = zo_strformat(SI_ZONE_NAME, GetZoneNameById(zoneId))
    return zoneId, zoneName, self:GetZoneEncounterConfigs(zoneId)
end

function DE:FindEncounterConfigForInstance(worldEventInstanceId, configs)
    configs = configs or self.state.zoneEncounterConfigs
    if type(configs) ~= "table" then
        return nil, nil
    end

    for _, config in ipairs(configs) do
        if worldEventInstanceId == config.parentWorldEventInstanceId then
            return config, "parent"
        end
        if config.knownChildInstanceIds and config.knownChildInstanceIds[worldEventInstanceId] then
            return config, "child"
        end
    end

    return nil, nil
end

function DE:SetActiveEncounterConfig(config)
    if self.state.eventData == config then
        return false
    end

    self.state.eventData = config
    self.state.currentStepOrdinal = nil
    self.state.currentStepTotal = nil
    return true
end

function DE:FindLinkedPOIForWorldEventInstance(worldEventInstanceId, zoneIndex)
    zoneIndex = zoneIndex or GetUnitZoneIndex("player")
    if not zoneIndex or zoneIndex == 0 then
        return nil, nil
    end

    local numPOIs = GetNumPOIs(zoneIndex)
    for poiIndex = 1, numPOIs do
        if GetPOIWorldEventInstanceId(zoneIndex, poiIndex) == worldEventInstanceId then
            return zoneIndex, poiIndex
        end
    end

    return nil, nil
end

function DE:GetWorldEventPOIIndices(worldEventInstanceId)
    local locationContext = GetWorldEventLocationContext(worldEventInstanceId)
    if locationContext == WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST then
        local zoneIndex, poiIndex = GetWorldEventPOIInfo(worldEventInstanceId)
        if zoneIndex and zoneIndex ~= 0 and poiIndex and poiIndex ~= 0
            and GetPOIWorldEventInstanceId(zoneIndex, poiIndex) == worldEventInstanceId then
            return zoneIndex, poiIndex, "world-event-poi"
        end
    end

    local zoneIndex, poiIndex = self:FindLinkedPOIForWorldEventInstance(
        worldEventInstanceId,
        GetUnitZoneIndex("player")
    )
    if zoneIndex and poiIndex then
        return zoneIndex, poiIndex, "zone-poi-link"
    end

    return nil, nil, nil
end

function DE:GetWorldEventPOIZoneId(worldEventInstanceId)
    local zoneIndex, poiIndex = self:GetWorldEventPOIIndices(worldEventInstanceId)
    if not zoneIndex or not poiIndex then
        return nil, zoneIndex, poiIndex
    end

    return GetZoneId(zoneIndex), zoneIndex, poiIndex
end

function DE:GetTrackedWorldEventRole(worldEventInstanceId)
    local activeConfig = self.state.eventData
    if activeConfig then
        if worldEventInstanceId == activeConfig.parentWorldEventInstanceId then
            return "parent"
        end
        if activeConfig.knownChildInstanceIds and activeConfig.knownChildInstanceIds[worldEventInstanceId] then
            return "child"
        end
    end

    local config, role = self:FindEncounterConfigForInstance(worldEventInstanceId)
    if config and role then
        return role
    end
    return nil
end

function DE:GetEncounterConfigForInstance(worldEventInstanceId)
    local activeConfig = self.state.eventData
    if activeConfig then
        if worldEventInstanceId == activeConfig.parentWorldEventInstanceId
            or (activeConfig.knownChildInstanceIds and activeConfig.knownChildInstanceIds[worldEventInstanceId]) then
            return activeConfig
        end
    end
    local config = self:FindEncounterConfigForInstance(worldEventInstanceId)
    return config
end

function DE:IsTrackedInstanceForCurrentZone(worldEventInstanceId)
    return self:GetTrackedWorldEventRole(worldEventInstanceId) ~= nil
end

function DE:IsParentInstanceForCurrentZone(worldEventInstanceId)
    local config, role = self:FindEncounterConfigForInstance(worldEventInstanceId)
    return config ~= nil and role == "parent"
end

function DE:GetWorldEventPOIName(worldEventInstanceId)
    local _, zoneIndex, poiIndex = self:GetWorldEventPOIZoneId(worldEventInstanceId)
    if not zoneIndex or not poiIndex then
        return nil
    end

    -- GetPOIInfo returns the name in the active game language. No encounter
    -- name is hard-coded or compared as text.
    local poiName = GetPOIInfo(zoneIndex, poiIndex)
    if poiName and poiName ~= "" then
        return zo_strformat(SI_ZONE_NAME, poiName)
    end

    return nil
end

function DE:SetUnknownState(reason)
    self:StopTimerUpdate()
    self.state.status = self.state.zoneEncounterConfigs and self.STATUS_UNKNOWN or self.STATUS_UNSUPPORTED
    self.state.activeWorldEventInstanceId = nil
    self.state.activeWorldEventRole = nil
    self.state.parentActive = false
    self:ResetStepRun(reason or "state set to unknown")
    self.state.earliestRespawnAt = nil
    self.state.respawnAt = nil
    self.state.expectedClockSeconds = nil
    self.state.cooldownStartedAt = nil
    self.state.cooldownStartExact = nil
    self.state.cooldownSource = nil
    self.state.noActiveSince = nil
    self.state.chestCandidateCount = 0
    self.state.chestHintText = nil
    self.state.chestHintUntil = nil
    self.state.centerChestAlertText = nil
    self.state.centerChestAlertUntil = nil
    if self.HideCenterChestAlert then
        self:HideCenterChestAlert()
    end
    self.state.participatedSteps = {}
    self.state.participationDisplayState = self.PARTICIPATION_UNKNOWN
    self.state.triggeredChestRules = {}
    self.state.lastChestRuleId = nil
    self:RecordDiagnosticSnapshot(reason or "state-set-unknown", true)
    self:RefreshUI()
end

function DE:SetActiveState(worldEventInstanceId, role, activationSource, activationExact)
    if not self.state.eventData then
        return
    end

    role = role or self:GetTrackedWorldEventRole(worldEventInstanceId)
    if not role then
        return
    end

    local wasActive = self.state.status == self.STATUS_ACTIVE

    self:StopTimerUpdate()
    self.state.status = self.STATUS_ACTIVE
    self.state.activeWorldEventInstanceId = worldEventInstanceId
    self.state.activeWorldEventRole = role

    self.state.earliestRespawnAt = nil
    self.state.respawnAt = nil
    self.state.expectedClockSeconds = nil
    self.state.cooldownStartedAt = nil
    self.state.cooldownStartExact = nil
    self.state.cooldownSource = nil

    if not wasActive then
        self.state.encounterRunId = (self.state.encounterRunId or 0) + 1
        self:ResetEncounterTransientState()
        self.state.participationDisplayState = activationExact == true
            and self.PARTICIPATION_OPEN
            or self.PARTICIPATION_UNKNOWN
        self:ModuleHook(
            "respawnMeasurement",
            "RecordEncounterActivation",
            self.state.eventData,
            activationExact == true,
            activationSource or "unknown"
        )
        if self:IsDebugEnabled() then
            self:StartStepRun(activationExact == true, activationSource or "unknown")
        end
    end

    -- POI title is a fallback only; GetWorldEventStepName is authoritative.
    if not self.state.eventName then
        local localizedPOIName = self:GetWorldEventPOIName(worldEventInstanceId)
        if localizedPOIName then
            self.state.eventName = localizedPOIName
        end
    end

    self.state.noActiveSince = nil
    self:RefreshParticipatingPhase()
    self:RefreshMapLocationPhase()
    self:RecordDiagnosticSnapshot(activationSource or "active-state", not wasActive)
    self:RefreshUI()
end

function DE:SetCooldownState(deactivationExact, deactivationSource)
    local eventData = self.state.eventData
    if not eventData or self.state.status ~= self.STATUS_ACTIVE then
        return false
    end

    local now = GetTimeStamp()
    -- Encounter-end chest notifications also require an explicit rule for the
    -- current zone. Unconfigured encounters end silently with regard to chests.
    if self:HasConfiguredChestRules() then
        self:MaybeTriggerConfiguredEndChest()
    end
    self:ModuleHook(
        "respawnMeasurement",
        "RecordEncounterDeactivation",
        eventData,
        deactivationExact == true,
        deactivationSource or "unknown"
    )
    if self:IsDebugEnabled() then
        self:FinalizeStepRun(deactivationExact == true, deactivationSource or "unknown")
    end

    self.state.status = self.STATUS_COOLDOWN
    self.state.activeWorldEventInstanceId = nil
    self.state.activeWorldEventRole = nil
    self.state.parentActive = false
    self.state.noActiveSince = nil
    self.state.stepRun = nil
    self:ClearCurrentStepState()
    self.state.cooldownStartedAt = now
    self.state.cooldownStartExact = deactivationExact == true
    self.state.cooldownSource = deactivationSource or "unknown"

    local timing = self:GetRespawnTiming(eventData)
    self.state.earliestRespawnAt = now + timing.earliestSeconds
    self.state.respawnAt = now + timing.expectedSeconds
    self.state.expectedClockSeconds = (GetSecondsSinceMidnight() + timing.expectedSeconds) % ZO_ONE_DAY_IN_SECONDS
    if self.sv.showRespawnTimer ~= false then
        self:StartTimerUpdate()
    end
    self:RecordDiagnosticSnapshot(deactivationSource or "cooldown-state", true)
    self:RefreshUI()
    return true
end

function DE:RefreshParticipatingPhase()
    return self:RefreshProgressState("GetParticipatingWorldEventStep")
end
