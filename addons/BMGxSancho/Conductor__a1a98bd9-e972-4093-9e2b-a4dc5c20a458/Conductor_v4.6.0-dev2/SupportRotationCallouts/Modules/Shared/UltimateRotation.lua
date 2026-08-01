local SRC = SupportRotationCallouts
SRC.UltimateRotationFactory = SRC.UltimateRotationFactory or {}
local Factory = SRC.UltimateRotationFactory

local function Normalize(name)
    return SRC:NormalizeAccountName(name or "")
end

function Factory:Create(config)
    local M = { config = config }

    function M:Initialize()
        self:HardReset("initialize")
    end

    function M:IsEnabled()
        return SRC.saved[self.config.enabledKey] == true
    end

    function M:GetCount()
        return zo_clamp(tonumber(SRC.saved[self.config.countKey]) or 1, 1, 4)
    end

    function M:GetRotation()
        return SRC.saved[self.config.rotationKey] or {}
    end

    function M:GetAccountAt(position)
        if not position or position < 1 or position > self:GetCount() then return "" end
        local account = Normalize(self:GetRotation()[position] or "")
        if account == "@" then return "" end
        if Conductor and Conductor.LiveSession then
            local resolved = Conductor.LiveSession:ResolveAccount(account, self.config.key)
            return resolved or ""
        end
        return account
    end

    function M:GetConfiguredPosition(account)
        local normalized = Normalize(account)
        if normalized == "" then return nil end

        for index = 1, self:GetCount() do
            if Normalize(self:GetAccountAt(index)) == normalized then
                return index
            end
        end

        return nil
    end

    function M:IsLocalAssigned()
        return self:GetConfiguredPosition(GetDisplayName()) ~= nil
    end

    function M:GetNextPosition(position)
        return (position % self:GetCount()) + 1
    end

    function M:GetReadinessInfo(account)
        return SRC.GroupStats:GetReadinessInfoFor(self.config.key, account)
    end

    function M:BuildReadinessList()
        local list = {}
        for index = 1, self:GetCount() do
            local info = self:GetReadinessInfo(self:GetAccountAt(index))
            info.position = index
            list[index] = info
        end
        return list
    end

    function M:FindNextReady(startPosition, list)
        list = list or self:BuildReadinessList()
        local count = self:GetCount()

        for offset = 0, count - 1 do
            local position = ((startPosition - 1 + offset) % count) + 1
            if list[position] and list[position].state == SRC.GroupStats.READY then
                return position
            end
        end

        return nil
    end

    function M:Validate()
        local seen = {}
        for index = 1, self:GetCount() do
            local normalized = Normalize(self:GetAccountAt(index))
            if normalized == "" then
                return false, self.config.label .. " " .. tostring(index) .. " IS BLANK"
            end
            if seen[normalized] then
                return false, "DUPLICATE ACCOUNT"
            end
            seen[normalized] = true
        end
        return true
    end

    function M:SelectOpening()
        if not self:IsEnabled() then return nil, {} end

        local valid, message = self:Validate()
        if not valid then
            SRC.Diagnostics:Add(self.config.key, "Configuration invalid: " .. tostring(message))
            return nil, {}
        end

        local list = self:BuildReadinessList()
        return self:FindNextReady(1, list), list
    end

    function M:GetStatusText(remaining, info)
        if remaining then
            if remaining <= 0.5 then return "NOW" end
            if remaining <= 1.0 then return "1" end
            if remaining <= 2.0 then return "2" end
            if remaining <= 3.0 then return "3" end
            return string.format("%.1f", remaining)
        end

        if info.state == SRC.GroupStats.READY then return "READY" end
        if info.percent ~= nil then return tostring(info.percent) .. "%" end
        return "WAIT"
    end

    function M:RefreshDisplay()
        if not self:IsEnabled() then
            SRC.Display:ClearModuleState(self.config.key)
            return
        end

        local position = self.calloutPosition or self.nextPosition or self.openerPosition or 1
        local account = self:GetAccountAt(position)
        local info = self:GetReadinessInfo(account)
        local remaining = nil

        if self.activeEndTime then
            remaining = zo_max(0, self.activeEndTime - GetGameTimeSeconds())
        end

        local followingPosition = self:GetNextPosition(position)
        local followingAccount = self:GetAccountAt(followingPosition)
        local followingInfo = self:GetReadinessInfo(followingAccount)

        SRC.Display:UpdateModuleState(self.config.key, {
            label = self.config.shortLabel,
            position = position,
            account = account,
            remaining = remaining,
            state = info.state,
            percent = info.percent,
            urgent = remaining and remaining <= 3,
            active = self.activeEndTime ~= nil,
            statusText = self:GetStatusText(remaining, info),
            followingPosition = followingPosition,
            followingAccount = followingAccount,
            followingStatusText = self:GetStatusText(nil, followingInfo),
            localAssigned = self:IsLocalAssigned(),
        })
    end

    function M:RefreshOpeningDisplay()
        if not self:IsEnabled() then return end
        local position = self:SelectOpening()
        self.openerPosition = position
        self.calloutPosition = position
        self:RefreshDisplay()
    end

    function M:OnReadinessUpdated()
        if not self.activeEndTime then
            self:RefreshOpeningDisplay()
        else
            self:RefreshDisplay()
        end
    end

    function M:OnBossEncounterStarted()
        self.encounterActive = true
        self.sessionGeneration = Conductor and Conductor.LiveSession and Conductor.LiveSession:GetGeneration() or 0
        self.sessionFingerprint = Conductor and Conductor.LiveSession and Conductor.LiveSession:GetFingerprint() or ""
        self:RefreshOpeningDisplay()
    end

    function M:OnBossTemporarilyUnavailable()
    end

    function M:OnBossEncounterEnded()
        self.encounterActive = false
        self.activeEndTime = nil
        self.calloutPosition = nil
        self:StopUpdateLoop()
        self:RearmThresholds()
        self:RefreshDisplay()
    end

    function M:OnPlayerCombatEnded()
        if not self.activeEndTime then
            self:RefreshDisplay()
        end
    end

    function M:OnUltimateSpendCandidate(candidate)
        if not self:IsEnabled() then return end

        local actualPosition = self:GetConfiguredPosition(candidate.accountName)
        if actualPosition then
            self.lastConfirmedPosition = actualPosition
            self.nextPosition = self:GetNextPosition(actualPosition)
        end

        self.calloutPosition = self:FindNextReady(self.nextPosition or 1)
            or self.nextPosition
            or 1

        local duration = self.config.fallbackDuration or 0
        if duration > 0 then
            self.activeEndTime = GetGameTimeSeconds() + duration
        end

        self:RearmThresholds()

        SRC.Diagnostics:AddFields(self.config.key, "Ultimate used", {
            account = candidate.accountName,
            abilityId = candidate.abilityId,
            abilityCost = candidate.abilityCost,
            observedSpend = candidate.observedSpend,
            actualPosition = actualPosition,
            nextPosition = self.calloutPosition,
            activeWindowSeconds = duration,
        })

        if SRC.Display and SRC.Display.ShowModuleConfirmation then
            SRC.Display:ShowModuleConfirmation(
                self.config.key,
                candidate.accountName,
                self.config.shortLabel or self.config.label,
                SRC.saved.confirmationHoldMs
            )
        end

        self:StartUpdateLoop()
        self:RefreshDisplay()
    end

    function M:OnEffectUpdate(effect)
        if not self:IsEnabled() or not effect or not effect.endTime then return end

        local oldEndTime = self.activeEndTime
        self.activeEndTime = effect.endTime

        if not self.calloutPosition then
            self.calloutPosition = self:FindNextReady(self.nextPosition or 1)
                or self.nextPosition
                or 1
        end

        if not oldEndTime or math.abs(self.activeEndTime - oldEndTime) > 0.075 then
            self:RearmThresholds()
        end

        SRC.Diagnostics:AddFields(self.config.key, "Effect window updated", {
            abilityId = effect.abilityId,
            beginTime = effect.beginTime,
            endTime = effect.endTime,
            remaining = effect.endTime - GetGameTimeSeconds(),
        })

        self:StartUpdateLoop()
        self:RefreshDisplay()
    end

    function M:RearmThresholds()
        self.fired3 = false
        self.fired2 = false
        self.fired1 = false
        self.firedNow = false
    end

    function M:StartUpdateLoop()
        local updateName = SRC.name .. self.config.key .. "Update"
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        EVENT_MANAGER:RegisterForUpdate(updateName, 200, function()
            self:Update()
        end)
    end

    function M:StopUpdateLoop()
        EVENT_MANAGER:UnregisterForUpdate(SRC.name .. self.config.key .. "Update")
    end

    function M:LogThreshold(name, remaining)
        SRC.Diagnostics:AddFields(self.config.key, "Rotation countdown", {
            threshold = name,
            remaining = remaining,
            nextAccount = self:GetAccountAt(self.calloutPosition or 1),
            nextPosition = self.calloutPosition,
        })
    end

    function M:Update()
        if Conductor and Conductor.LiveSession and not Conductor.LiveSession:IsContextCurrent(self.sessionGeneration or 0, self.sessionFingerprint or "") then
            self:HardReset("live group context changed")
            return
        end
        if not self.activeEndTime then
            self:StopUpdateLoop()
            return
        end

        local remaining = self.activeEndTime - GetGameTimeSeconds()

        if remaining <= 0 then
            self.activeEndTime = nil
            self:StopUpdateLoop()
            self:RearmThresholds()
            SRC.Diagnostics:Add(self.config.key, "Active window ended")
            self:RefreshDisplay()
            return
        end

        if remaining <= 0.5 and not self.firedNow then
            self.firedNow = true
            self:LogThreshold("NOW", remaining)
        elseif remaining <= 1.0 and not self.fired1 then
            self.fired1 = true
            self:LogThreshold("1", remaining)
        elseif remaining <= 2.0 and not self.fired2 then
            self.fired2 = true
            self:LogThreshold("2", remaining)
        elseif remaining <= 3.0 and not self.fired3 then
            self.fired3 = true
            self:LogThreshold("3", remaining)
        end

        self:RefreshDisplay()
    end

    function M:HardReset(reason)
        self:StopUpdateLoop()
        self.encounterActive = false
        self.activeEndTime = nil
        self.lastConfirmedPosition = nil
        self.nextPosition = 1
        self.calloutPosition = nil
        self.openerPosition = nil
        self.sessionGeneration = nil
        self.sessionFingerprint = nil
        self:RearmThresholds()
        SRC.Display:ClearModuleState(self.config.key)
        SRC.Diagnostics:Add(self.config.key, "Hard reset: " .. tostring(reason))
    end

    return M
end
