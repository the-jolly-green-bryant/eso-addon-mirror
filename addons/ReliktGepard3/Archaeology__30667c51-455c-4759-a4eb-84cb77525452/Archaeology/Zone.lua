local AA = Archaeology

function AA:GetCurrentPlayerZoneId()
    if type(GetUnitZoneIndex) ~= "function" or type(GetZoneId) ~= "function" then
        return nil
    end

    local zoneIndex = GetUnitZoneIndex("player")
    if type(zoneIndex) ~= "number" or zoneIndex <= 0 then
        return nil
    end

    local zoneId = GetZoneId(zoneIndex)
    if type(zoneId) ~= "number" or zoneId <= 0 then
        return nil
    end

    return zoneId
end

function AA:ShowCurrentZoneLeadSummary(limit, suppressWhenEmpty)
    local zoneId = self:GetCurrentPlayerZoneId()
    if not zoneId then
        return
    end

    local zoneLabel = "current zone"
    if type(GetZoneNameById) == "function" then
        local zoneName = GetZoneNameById(zoneId)
        if zoneName and zoneName ~= "" then
            if type(zo_strformat) == "function" then
                zoneName = zo_strformat("<<1>>", zoneName)
            end
            zoneLabel = zoneName
        end
    end

    local emptyLeadsMessage = false
    if not suppressWhenEmpty then
        emptyLeadsMessage = string.format("No active antiquity leads in %s.", zoneLabel)
    end

    self:PrintExpiringLeads(
        limit or math.huge,
        true,
        nil,
        nil,
        emptyLeadsMessage,
        zoneId,
        string.format("Active antiquity leads in %s:", zoneLabel)
    )
end
