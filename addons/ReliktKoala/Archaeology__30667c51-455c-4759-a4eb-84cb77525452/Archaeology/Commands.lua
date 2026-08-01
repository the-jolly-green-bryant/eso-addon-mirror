local AA = Archaeology

function AA:HandleSlashCommand(argumentText)
    local command = AA.NormalizeText(argumentText)

    if command == "" or command == "top" or command == "show" then
        self:PrintExpiringLeads(self.maxDisplayedLeads, false)
        return
    end

    if command == "all" then
        self:PrintExpiringLeads(math.huge, false)
        return
    end

    if command == "zone" or command == "here" then
        self:ShowCurrentZoneLeadSummary(self.maxDisplayedLeads, false)
        return
    end

    local count = tonumber(command)
    if count then
        count = math.floor(count)
        if count <= 0 then
            self:Print("Please provide a positive number.")
            return
        end

        self:PrintExpiringLeads(count, false)
        return
    end

    local keyword, countArg = string.match(command, "^(%S+)%s+(%S+)$")
    if (keyword == "top" or keyword == "show" or keyword == "zone" or keyword == "here") and countArg then
        if keyword == "zone" or keyword == "here" then
            if countArg == "all" then
                self:ShowCurrentZoneLeadSummary(math.huge, false)
                return
            end

            local parsedCount = tonumber(countArg)
            if not parsedCount then
                self:Print(self.usageText)
                return
            end

            parsedCount = math.floor(parsedCount)
            if parsedCount <= 0 then
                self:Print("Please provide a positive number.")
                return
            end

            self:ShowCurrentZoneLeadSummary(parsedCount, false)
            return
        end

        local parsedCount = tonumber(countArg)
        if not parsedCount then
            self:Print(self.usageText)
            return
        end

        parsedCount = math.floor(parsedCount)
        if parsedCount <= 0 then
            self:Print("Please provide a positive number.")
            return
        end

        self:PrintExpiringLeads(parsedCount, false)
        return
    end

    if command == "help" then
        self:Print(self.usageText)
        return
    end

    self:Print(string.format("Unknown option '%s'. Use /archaeology help.", command))
end
