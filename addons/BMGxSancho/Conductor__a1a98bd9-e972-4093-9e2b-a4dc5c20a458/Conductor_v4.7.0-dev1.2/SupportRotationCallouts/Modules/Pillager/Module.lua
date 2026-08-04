local SRC = SupportRotationCallouts
SRC.PillagerModule = SRC.PillagerModule or {}
local M = SRC.PillagerModule
local EVENT_NAME = SRC.name .. "PillagerCombat"

function M:GetAssignedPlayer()
    local count = zo_clamp(tonumber(SRC.saved.pillagerRotationCount) or 1, 1, 4)
    for i = 1, count do
        local account = SRC:NormalizeAccountName(SRC.saved.pillagerRotation[i] or "")
        if Conductor and Conductor.LiveSession then
            account = Conductor.LiveSession:ResolveAccount(account, "PILLAGER") or ""
        end
        if account ~= "" then return account end
    end
    return ""
end

function M:UpdateDashboard()
    if not SRC.saved or SRC.saved.enabled ~= true then return end
    if not SRC.saved.pillagerEnabled then SRC.Display:ClearModuleState("PILLAGER"); return end
    local remaining = self.cooldownEnd and math.max(0, self.cooldownEnd - GetGameTimeSeconds()) or 0
    SRC.Display:UpdateModuleState("PILLAGER", {
        label = "PILLAGER",
        account = self:GetAssignedPlayer(),
        statusText = remaining > 0 and string.format("%.0f", remaining) or "READY",
        remaining = remaining > 0 and remaining or nil,
        active = remaining > 0,
    })
end

function M:OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not SRC.saved.pillagerEnabled or abilityId ~= SRC.Pillager.PROC_ABILITY_ID then return end
    if SRC.CombatContextEngine and not SRC.CombatContextEngine:CanTrackGroupCombatSource(sourceName, sourceUnitId) then return end
    self.cooldownEnd = GetGameTimeSeconds() + SRC.Pillager.COOLDOWN_SECONDS
    local account = self:GetAssignedPlayer()
    SRC.Diagnostics:AddFields("PILLAGER", "Pillager proc confirmed", { abilityId = abilityId, sourceName = sourceName, targetName = targetName, hitValue = hitValue, cooldownEnd = self.cooldownEnd })
    SRC.Display:ShowModuleConfirmation("PILLAGER", account, "PILLAGER", 1100)
    self:UpdateDashboard()
end

function M:HardReset(reason)
    self.cooldownEnd = nil
    if SRC.Display then SRC.Display:ClearModuleState("PILLAGER") end
    if SRC.Diagnostics then SRC.Diagnostics:Add("PILLAGER", "Hard reset: " .. tostring(reason or "unspecified")) end
end

function M:Initialize()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAME, EVENT_COMBAT_EVENT, function(_, ...) M:OnCombatEvent(...) end)
    EVENT_MANAGER:RegisterForUpdate(SRC.name .. "PillagerUpdate", 500, function() M:UpdateDashboard() end)
    self:UpdateDashboard()
    SRC.Diagnostics:Add("PILLAGER", "Pillager module registered")
end
