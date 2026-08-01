local SRC = SupportRotationCallouts
SRC.ColossusRotation = SRC.ColossusRotation or {}
local Rotation = SRC.ColossusRotation
local C = SRC.Colossus

function Rotation:Initialize()
    self:HardReset("initialize")
end

function Rotation:GetConfiguredPosition(accountName)
    local normalized = SRC:NormalizeAccountName(accountName)
    if normalized == "" then return nil end
    for index = 1, SRC.saved.rotationCount do
        if SRC:NormalizeAccountName(SRC.saved.rotation[index]) == normalized then
            return index
        end
    end
    return nil
end

function Rotation:GetNextPosition(actualPosition)
    local count = zo_clamp(SRC.saved.rotationCount, 2, 6)
    return (actualPosition % count) + 1
end

function Rotation:GetAccountAt(position)
    local account = SRC:NormalizeAccountName(SRC.saved.rotation[position] or "")
    if Conductor and Conductor.LiveSession then
        local resolved = Conductor.LiveSession:ResolveAccount(account, "COLOSSUS")
        return resolved or ""
    end
    return account
end

function Rotation:BuildReadinessList()
    local list = {}
    for index = 1, SRC.saved.rotationCount do
        local account = self:GetAccountAt(index)
        local info = SRC.GroupStats:GetReadinessInfo(account)
        info.position = index
        info.account = account
        list[index] = info
    end
    return list
end

function Rotation:FindNextReadyPosition(startPosition, readinessList)
    local count = zo_clamp(SRC.saved.rotationCount, 2, 6)
    local start = zo_clamp(startPosition or 1, 1, count)
    local list = readinessList or self:BuildReadinessList()

    for offset = 0, count - 1 do
        local position = ((start - 1 + offset) % count) + 1
        if list[position] and list[position].state == SRC.GroupStats.READY then
            return position
        end
    end
    return nil
end

function Rotation:ResolveCalloutPosition()
    local preferred = self.nextPosition or 1

    -- Dummy mode validates the configured sequence even when no other players
    -- are present to share readiness data.
    if self.isDummyEncounter then
        return preferred, false
    end

    local position = self:FindNextReadyPosition(preferred)
    if not position then
        return nil, false
    end
    return position, position ~= preferred
end

function Rotation:ValidateConfiguration()
    local seen = {}
    for index = 1, SRC.saved.rotationCount do
        local normalized = SRC:NormalizeAccountName(self:GetAccountAt(index))
        if normalized == "" then
            return false, "COLO " .. tostring(index) .. " IS NOT IN GROUP"
        end
        if seen[normalized] then
            return false, "DUPLICATE ACCOUNT"
        end
        seen[normalized] = true
    end
    return true, nil
end

function Rotation:SelectOpeningPosition()
    local valid, message = self:ValidateConfiguration()
    if not valid then
        SRC.Display:ShowConfigurationError(message)
        SRC.Diagnostics:Add("ROTATION", "Configuration invalid: " .. tostring(message))
        return nil, nil
    end

    local readinessList = self:BuildReadinessList()
    local position = self:FindNextReadyPosition(1, readinessList)

    for index = 1, #readinessList do
        local item = readinessList[index]
        SRC.Diagnostics:AddFields("READINESS", "Opener scan", {
            position = index,
            account = item.account,
            state = item.state,
            ultValue = item.value or "?",
            ultCost = item.cost or "?",
            percent = item.percent or "?",
        })
    end

    return position, readinessList
end

function Rotation:RefreshOpeningDisplay()
    if not self.encounterActive or self.activeEffect then return end
    local position, readinessList = self:SelectOpeningPosition()
    if not readinessList then return end
    self.openerPosition = position
    SRC.Display:ShowOpening(position, readinessList)
end

function Rotation:OnReadinessUpdated()
    if self.activeEffect then
        return
    end

    if self.encounterActive and not self.pendingCast then
        self:RefreshOpeningDisplay()
    end
end

function Rotation:OnBossEncounterStarted()
    self.encounterActive = true
    self.isDummyEncounter = false
    self:CloseActiveSession("new boss encounter")
    self:RefreshOpeningDisplay()
end

function Rotation:OnBossTemporarilyUnavailable()
    self:ClearEffectOnly("boss temporarily unavailable")
end

function Rotation:OnBossEncounterEnded(reason)
    self.encounterActive = false
    self.isDummyEncounter = false
    self.openerPosition = nil
    self:CloseActiveSession(reason or "boss encounter ended")
    SRC.Display:Hide()
end

function Rotation:OnPlayerCombatEnded()
    if self.isDummyEncounter then
        self:OnBossEncounterEnded("dummy combat ended")
        return
    end
    self:ClearEffectOnly("player left combat")
end

function Rotation:ApplyCasterToRotation(cast, sourceLabel)
    local actualPosition = self:GetConfiguredPosition(cast.accountName)

    if actualPosition then
        self.lastConfirmedPosition = actualPosition
        self.nextPosition = self:GetNextPosition(actualPosition)
        self.calloutPosition = nil
        SRC.Diagnostics:AddFields("ROTATION", sourceLabel .. " mapped", {
            actualPosition = actualPosition,
            nextPosition = self.nextPosition,
            account = cast.accountName,
            identity = cast.sourceIdentity,
            abilityId = cast.abilityId,
        })
    else
        SRC.Diagnostics:AddFields("ROTATION", sourceLabel .. " caster not mapped", {
            sourceName = cast.sourceName,
            identity = cast.sourceIdentity,
            identityType = cast.sourceIdentityType,
            account = cast.accountName,
            nextPosition = self.nextPosition,
        })
    end

    cast.actualPosition = actualPosition
    return actualPosition
end

function Rotation:IsValidEffectTarget(effect)
    if not effect then return false end
    if effect.isDummy then
        return SRC.saved.dummyMode == true
    end
    return effect.isBoss == true
end

function Rotation:EstablishTimer(effect, correlationSource)
    if not self:IsValidEffectTarget(effect) then
        SRC.Diagnostics:AddFields("TIMER", "Rejected correlated Major Vulnerability target", {
            source = correlationSource,
            unitId = effect and effect.unitId,
            isBoss = effect and effect.isBoss,
            isDummy = effect and effect.isDummy,
        })
        return false
    end

    if effect.isDummy then
        self.encounterActive = true
        self.isDummyEncounter = true
    else
        self.encounterActive = true
        self.isDummyEncounter = false
    end

    self.activeEffect = effect
    self.activeTargetUnitId = effect.unitId
    self.pendingCast = nil
    self.recentEffect = nil
    if not self.lastConfirmedPosition and self.openerPosition then
        self.nextPosition = self:GetNextPosition(self.openerPosition)
    else
        self.nextPosition = self.nextPosition or 2
    end
    self.calloutPosition = nil
    self:RearmThresholds()
    self:StartUpdateLoop()

    SRC.Diagnostics:AddFields("TIMER", "Timer established or replaced", {
        correlationSource = correlationSource,
        targetUnitId = effect.unitId,
        beginTime = effect.beginTime,
        endTime = effect.endTime,
        nextPosition = self.nextPosition,
        isBoss = effect.isBoss,
        isDummy = effect.isDummy,
    })
    return true
end

function Rotation:OnColossusCast(cast)
    self:ApplyCasterToRotation(cast, "Combat event cast")

    if cast.isDummy then
        if not SRC.saved.dummyMode then return end
        self.encounterActive = true
        self.isDummyEncounter = true
    end

    if not cast.isBoss and not cast.isDummy then
        SRC.Diagnostics:Add("ROTATION", "Trash Colo tracked; no boss timer opened")
        return
    end

    self.encounterActive = true
    self.pendingCast = cast
    self.pendingCast.expiresMs = GetGameTimeMilliseconds() + C.CORRELATION_WINDOW_MS
    self.pendingCast.replacesActiveTarget = true
    self.pendingCast.correlationSource = "combat-event"
end

function Rotation:OnUltimateSpendCandidate(candidate)
    -- Caster identification is supplemental. The Major Vulnerability effect
    -- controls the timer and must never wait for an ultimate-spend event.
    self:ApplyCasterToRotation(candidate, "Ultimate spend")

    if SRC.Display and SRC.Display.ShowModuleConfirmation then
        SRC.Display:ShowModuleConfirmation(
            "COLOSSUS",
            candidate.accountName,
            "COLOSSUS",
            SRC.saved.confirmationHoldMs
        )
    end

    if self.activeEffect then
        SRC.Diagnostics:AddFields("CORRELATION", "Caster identified after timer start", {
            account = candidate.accountName,
            abilityId = candidate.abilityId,
            nextPosition = self.nextPosition,
        })
        return
    end

    candidate.expiresMs = GetGameTimeMilliseconds() + C.CORRELATION_WINDOW_MS
    candidate.targetUnitId = 0
    candidate.replacesActiveTarget = true
    candidate.correlationSource = "ultimate-spend"
    self.pendingCast = candidate

    SRC.Diagnostics:AddFields("CORRELATION", "Pending caster from ultimate spend", {
        account = candidate.accountName,
        abilityId = candidate.abilityId,
        abilityCost = candidate.abilityCost,
        observedSpend = candidate.observedSpend,
        expiresMs = candidate.expiresMs,
    })
end

function Rotation:PendingCastMatches(effect)
    if not self.pendingCast then return false end
    if GetGameTimeMilliseconds() > self.pendingCast.expiresMs then
        SRC.Diagnostics:Add("CORRELATION", "Pending Colossus expired before Major Vulnerability")
        self.pendingCast = nil
        return false
    end

    if not self:IsValidEffectTarget(effect) then
        return false
    end

    if self.pendingCast.fromUltimateSpend then
        return true
    end

    if self.pendingCast.targetUnitId ~= 0 and effect.unitId ~= 0 then
        return self.pendingCast.targetUnitId == effect.unitId
    end
    return true
end

function Rotation:OnMajorVulnerabilityUpdate(effect)
    if not self:IsValidEffectTarget(effect) then
        SRC.Diagnostics:AddFields("TIMER", "Ignored Major Vulnerability on invalid target", {
            unitId = effect and effect.unitId,
            isBoss = effect and effect.isBoss,
            isDummy = effect and effect.isDummy,
        })
        return
    end

    -- The live Major Vulnerability effect is authoritative for timing. Start
    -- immediately instead of waiting for caster identification, because
    -- PlayStation may report ultimate values as a stepped stream rather than
    -- a single discrete spend event.
    if not self.activeEffect then
        local source = "effect-authoritative"
        if self.pendingCast and self:PendingCastMatches(effect) then
            source = self.pendingCast.correlationSource or "pending-caster+effect"
        end
        self:EstablishTimer(effect, source)
        return
    end

    if self.activeTargetUnitId ~= 0 and effect.unitId ~= 0 and self.activeTargetUnitId ~= effect.unitId then
        SRC.Diagnostics:AddFields("TIMER", "Ignored secondary target update", {
            activeTargetUnitId = self.activeTargetUnitId,
            updateUnitId = effect.unitId,
        })
        return
    end

    local oldEnd = self.activeEffect.endTime
    local delta = effect.endTime - oldEnd
    self.activeEffect = effect

    if math.abs(delta) > C.ENDTIME_TOLERANCE_SECONDS then
        SRC.Diagnostics:AddFields("TIMER", "Timer end changed", {
            deltaSeconds = string.format("%.3f", delta),
            oldEnd = string.format("%.3f", oldEnd),
            newEnd = string.format("%.3f", effect.endTime),
        })
        if delta > 0 then
            self:RearmThresholds()
        end
    end
end

function Rotation:RearmThresholds()
    self.fired3 = false
    self.fired2 = false
    self.fired1 = false
    self.firedNow = false
    self.nowShownAtMs = nil
end

function Rotation:StartUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(SRC.updateName)
    EVENT_MANAGER:RegisterForUpdate(SRC.updateName, C.UPDATE_INTERVAL_MS, function() self:Update() end)
end

function Rotation:StopUpdateLoop()
    EVENT_MANAGER:UnregisterForUpdate(SRC.updateName)
end

function Rotation:PlayNowSound()
    if SRC.saved.colossusNowSoundEnabled then
        PlaySound(SOUNDS.ABILITY_ULTIMATE_READY)
    end
end

function Rotation:ClearEffectOnly(reason)
    self:StopUpdateLoop()
    self.pendingCast = nil
    self.recentEffect = nil
    self.activeEffect = nil
    self.activeTargetUnitId = nil
    self:RearmThresholds()
    SRC.Display:Hide()
    SRC.Diagnostics:Add("TIMER", "Effect cleared: " .. tostring(reason))
end

function Rotation:CloseActiveSession(reason)
    self:ClearEffectOnly(reason)
end

function Rotation:Update()
    if not SRC.saved.enabled or SRC.saved.colossusEnabled == false or not self.activeEffect then return end

    local remaining = self.activeEffect.endTime - GetGameTimeSeconds()
    local position, skipped = self:ResolveCalloutPosition()

    if position ~= self.calloutPosition then
        self.calloutPosition = position
        self:RearmThresholds()
        SRC.Diagnostics:AddFields("ROTATION", "Active callout selection changed", {
            preferredPosition = self.nextPosition,
            selectedPosition = position or "none",
            skipped = skipped,
        })
    end

    if remaining <= 0 then
        if self.firedNow and self.nowShownAtMs and GetGameTimeMilliseconds() - self.nowShownAtMs < SRC.saved.calloutHoldMs then
            return
        end
        self:ClearEffectOnly("Major Vulnerability expired")
        return
    end

    if not position then
        SRC.Display:ShowNoReady(remaining)
        return
    end

    local account = self:GetAccountAt(position)

    if remaining <= SRC.saved.dropThreshold then
        if not self.firedNow then
            self.firedNow = true
            self.nowShownAtMs = GetGameTimeMilliseconds()
            SRC.Display:ShowNow(account, position, skipped)
            self:PlayNowSound()
            SRC.Diagnostics:AddFields("CALLOUT", "COLO NOW", {
                position = position,
                account = account,
                remaining = string.format("%.3f", remaining),
                skipped = skipped,
            })
        end
        return
    end

    if remaining <= 1.0 then
        if not self.fired1 then
            self.fired1 = true
            SRC.Display:ShowCountdown(account, position, 1, skipped)
        end
        return
    end

    if remaining <= 2.0 then
        if not self.fired2 then
            self.fired2 = true
            SRC.Display:ShowCountdown(account, position, 2, skipped)
        end
        return
    end

    if remaining <= SRC.saved.countdownStart then
        if not self.fired3 then
            self.fired3 = true
            SRC.Display:ShowCountdown(account, position, 3, skipped)
        end
        return
    end

    SRC.Display:ShowNext(account, position, remaining, skipped)
end

function Rotation:HardReset(reason)
    self:StopUpdateLoop()
    self.pendingCast = nil
    self.recentEffect = nil
    self.activeEffect = nil
    self.activeTargetUnitId = nil
    self.encounterActive = false
    self.isDummyEncounter = false
    self.openerPosition = nil
    self.lastConfirmedPosition = nil
    self.nextPosition = 2
    self.calloutPosition = nil
    self:RearmThresholds()
    if SRC.Display then SRC.Display:Hide() end
    if SRC.Diagnostics and SRC.saved then
        SRC.Diagnostics:Add("ROTATION", "Hard reset: " .. tostring(reason))
    end
end
