local AA = Archaeology

local function CollectExpiringLeads()
    if type(ANTIQUITY_DATA_MANAGER) ~= "table" or type(ANTIQUITY_DATA_MANAGER.AntiquityIterator) ~= "function" then
        return nil, "Antiquity data is not available yet."
    end

    local leads = {}
    for antiquityId, antiquityData in ANTIQUITY_DATA_MANAGER:AntiquityIterator() do
        if antiquityData and type(antiquityData.GetLeadTimeRemainingS) == "function" and type(antiquityData.GetName) == "function" then
            local secondsRemaining = antiquityData:GetLeadTimeRemainingS()
            if type(secondsRemaining) == "number" and secondsRemaining > 0 then
                local zoneId = nil
                if type(antiquityData.GetZoneId) == "function" then
                    zoneId = antiquityData:GetZoneId()
                end

                local quality = nil
                if type(antiquityData.GetQuality) == "function" then
                    quality = antiquityData:GetQuality()
                end

                local difficulty = nil
                if type(antiquityData.GetDifficulty) == "function" then
                    difficulty = antiquityData:GetDifficulty()
                end

                table.insert(leads, {
                    antiquityId = antiquityId,
                    name = antiquityData:GetName(),
                    secondsRemaining = secondsRemaining,
                    zoneId = zoneId,
                    quality = quality,
                    difficulty = difficulty,
                })
            end
        end
    end

    table.sort(leads, function(left, right)
        if left.secondsRemaining == right.secondsRemaining then
            return left.name < right.name
        end

        return left.secondsRemaining < right.secondsRemaining
    end)

    return leads
end

local function FilterLeadsByExcludedAntiquityIds(leads, excludedAntiquityIds)
    if type(excludedAntiquityIds) ~= "table" then
        return leads
    end

    local filteredLeads = {}
    for _, lead in ipairs(leads) do
        if not excludedAntiquityIds[lead.antiquityId] then
            table.insert(filteredLeads, lead)
        end
    end

    return filteredLeads
end

local function FilterLeadsByMaxSecondsRemaining(leads, maxSecondsRemaining)
    if type(maxSecondsRemaining) ~= "number" or maxSecondsRemaining <= 0 then
        return leads
    end

    local filteredLeads = {}
    for _, lead in ipairs(leads) do
        if type(lead.secondsRemaining) == "number" and lead.secondsRemaining <= maxSecondsRemaining then
            table.insert(filteredLeads, lead)
        end
    end

    return filteredLeads
end

local function FilterLeadsByZoneId(leads, zoneId)
    if type(zoneId) ~= "number" or zoneId <= 0 then
        return leads
    end

    local filteredLeads = {}
    for _, lead in ipairs(leads) do
        if lead.zoneId == zoneId then
            table.insert(filteredLeads, lead)
        end
    end

    return filteredLeads
end

function AA:PrintExpiringLeads(limit, suppressUnavailableMessage, excludedAntiquityIds, maxSecondsRemaining, emptyLeadsMessage, zoneId, headerMessage)
    local leads, errorText = CollectExpiringLeads()
    if not leads then
        if not suppressUnavailableMessage then
            self:Print(errorText or "Unable to load antiquity data.")
        end
        return false
    end

    leads = FilterLeadsByExcludedAntiquityIds(leads, excludedAntiquityIds)
    leads = FilterLeadsByMaxSecondsRemaining(leads, maxSecondsRemaining)
    leads = FilterLeadsByZoneId(leads, zoneId)

    if #leads == 0 then
        if emptyLeadsMessage == false then
            return true
        end
        self:Print(emptyLeadsMessage or "No active antiquity leads found.")
        return true
    end

    local displayCount = math.min(limit or self.maxDisplayedLeads, #leads)
    self:Print(headerMessage or string.format("Top %d expiring antiquity leads:", displayCount))

    -- Print in reverse so the shortest timer appears at the bottom chat line.
    for index = displayCount, 1, -1 do
        local lead = leads[index]
        local leadName = lead.name
        if type(zo_strformat) == "function" then
            leadName = zo_strformat("<<1>>", leadName)
        end

        local zoneSuffix = ""
        if type(lead.zoneId) == "number" and lead.zoneId > 0 and type(GetZoneNameById) == "function" then
            local zoneName = GetZoneNameById(lead.zoneId)
            if zoneName and zoneName ~= "" then
                if type(zo_strformat) == "function" then
                    zoneName = zo_strformat("<<1>>", zoneName)
                end
                zoneSuffix = string.format(" (%s)", zoneName)
            end
        end

        local displayLeadName = leadName
        if type(lead.quality) == "number" and type(GetAntiquityQualityColor) == "function" then
            local qualityColor = GetAntiquityQualityColor(lead.quality)
            if qualityColor and type(qualityColor.Colorize) == "function" then
                displayLeadName = qualityColor:Colorize(leadName)
            end
        end

        local difficultyText = AA.BuildDifficultyText(lead.difficulty)
        local timeText = AA.FormatLeadTime(lead.secondsRemaining)
        self:Print(string.format("%d. %s (%s) - %s%s", index, displayLeadName, difficultyText, timeText, zoneSuffix))
    end

    return true
end
