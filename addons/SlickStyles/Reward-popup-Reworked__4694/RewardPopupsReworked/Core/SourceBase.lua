local RPR = RewardPopupsReworked

RPR.SourceBase = {}

local Base = RPR.SourceBase

function Base:GetSettings()
    local root = RPR.savedVars or RPR.defaults
    return root and root[self.settingsKey] or {}
end

function Base:IsReplacementEnabled()
    if not self.replaceSetting then return false end
    return self:GetSettings()[self.replaceSetting] == true
end

function Base:IsAutoClaimEnabled()
    if not self.autoClaimSetting then return false end
    return self:GetSettings()[self.autoClaimSetting] == true
end

function Base:DetectPending()
    local count = RPR.Utils.FirstNumber(self.api and self.api.pendingCount)
    if count and count > 0 then
        return {
            source = self,
            count = count,
            requiresManual = false,
        }
    end

    local hasPending = RPR.Utils.FirstBoolean(self.api and self.api.hasPending)
    if hasPending == true then
        return {
            source = self,
            count = 1,
            requiresManual = false,
        }
    end

    return nil
end

function Base:IsSafeToAutoClaim(pending)
    return self.safeByDefault == true
end

function Base:CanAttemptManualClaim(pending)
    return self:IsSafeToAutoClaim(pending)
end

function Base:ClaimSafe(pending)
    if RPR.Utils.CallFirst(self.api and self.api.claimSafe) then
        return true
    end

    return RPR.Utils.ClickFirstControl(self.api and self.api.claimControls)
end

function Base:OpenInterface()
    if RPR.Utils.CallFirst(self.api and self.api.open) then
        return true
    end

    return RPR.Utils.ShowFirstScene(self.api and self.api.scenes)
end

function Base:RequiresManualReview(pending)
    return pending and pending.requiresManual == true
end

function Base:ShouldUseWidget(pending)
    return self:RequiresManualReview(pending)
end

function RPR.ApplySourceBase(source)
    if not source then return nil end

    for key, value in pairs(Base) do
        if source[key] == nil then
            source[key] = value
        end
    end

    return source
end