local AA = Archaeology

local function ExtractUnearthedAntiquityId(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)

        if type(value) == "number" and value > 0 then
            return value
        end

        if type(value) == "table" then
            if type(value.GetId) == "function" then
                local ok, antiquityId = pcall(function()
                    return value:GetId()
                end)
                if ok and type(antiquityId) == "number" and antiquityId > 0 then
                    return antiquityId
                end
            end

            if type(value.antiquityId) == "number" and value.antiquityId > 0 then
                return value.antiquityId
            end
        end
    end

    return nil
end

function AA:GetRandomUnearthedMessage()
    local count = #self.unearthedSuccessMessages
    if count == 0 then
        return "Antiquity unearthed!"
    end

    local randomIndex
    if type(zo_random) == "function" then
        randomIndex = zo_random(1, count)
    else
        randomIndex = math.random(count)
    end

    return self.unearthedSuccessMessages[randomIndex]
end

function AA:OnAntiquityUnearthed(_, ...)
    local unearthedAntiquityId = ExtractUnearthedAntiquityId(...)
    local excludedAntiquityIds = nil
    if unearthedAntiquityId then
        excludedAntiquityIds = {
            [unearthedAntiquityId] = true,
        }
    end

    self:Print(self:GetRandomUnearthedMessage())

    -- Give antiquity data a moment to settle before refreshing lead timers.
    zo_callLater(function()
        self:Print("Updated lead timers after excavation:")
        self:PrintExpiringLeads(self.maxDisplayedLeads, false, excludedAntiquityIds)
    end, 1200)
end

function AA:ShowLoginSummary()
    if self.hasShownLoginSummary then
        return
    end

    self.hasShownLoginSummary = true
    self:PrintExpiringLeads(
        self.maxDisplayedLeads,
        true,
        nil,
        self.loginMaxLeadAgeSeconds,
        string.format("No antiquity leads expiring within %d days.", self.loginMaxLeadAgeDays)
    )
end

function AA:OnPlayerActivated()
    local currentZoneId = self:GetCurrentPlayerZoneId()

    if self.autoLoginSummaryEnabled and not self.hasShownLoginSummary then
        zo_callLater(function()
            self:ShowLoginSummary()
        end, 10000)
    end

    if not currentZoneId then
        return
    end

    if self.lastAnnouncedZoneId == nil then
        self.lastAnnouncedZoneId = currentZoneId
        return
    end

    if self.lastAnnouncedZoneId ~= currentZoneId then
        self.lastAnnouncedZoneId = currentZoneId
        if self.autoZoneSummaryEnabled then
            self:ShowCurrentZoneLeadSummary(nil, true)
        end
    end
end

function AA:OnAddonLoaded(_, addonName)
    if addonName ~= self.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)

    self:InitializeSavedVariables()
    self:RegisterAddonMenu()

    SLASH_COMMANDS["/archaeology"] = function(argumentText)
        self:HandleSlashCommand(argumentText)
    end
    SLASH_COMMANDS["/arch"] = function(argumentText)
        self:HandleSlashCommand(argumentText)
    end

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(...)
        self:OnPlayerActivated(...)
    end)

    if type(EVENT_ANTIQUITY_DIGGING_ANTIQUITY_UNEARTHED) == "number" then
        EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ANTIQUITY_DIGGING_ANTIQUITY_UNEARTHED, function(...)
            self:OnAntiquityUnearthed(...)
        end)
    end

    self:Print("Loaded. Use /archaeology (or /arch).")
end

EVENT_MANAGER:RegisterForEvent(AA.name, EVENT_ADD_ON_LOADED, function(...)
    AA:OnAddonLoaded(...)
end)
