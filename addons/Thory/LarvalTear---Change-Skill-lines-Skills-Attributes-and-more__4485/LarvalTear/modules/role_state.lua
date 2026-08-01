local Addon = LarvalTearMod
local LTM_ROLE_STATE = Addon.Modules.RoleState

local ROLE_KEY_BY_SELECTED_ROLE = {
    [LFG_ROLE_TANK] = "tank",
    [LFG_ROLE_HEAL] = "healer",
    [LFG_ROLE_DPS] = "dps",
}

function LTM_ROLE_STATE:GetRoleKey(selectedRole)
    return ROLE_KEY_BY_SELECTED_ROLE[tonumber(selectedRole)]
end

function LTM_ROLE_STATE:NormalizeRoleState(roleState)
    if type(roleState) ~= "table" then
        return nil
    end

    local selectedRole = tonumber(roleState.selectedRole)
    local roleKey = self:GetRoleKey(selectedRole)
    if roleKey == nil then
        return nil
    end

    return {
        selectedRole = selectedRole,
        roleKey = roleKey,
    }
end

function LTM_ROLE_STATE:CaptureCurrentRoleState()
    if type(GetSelectedLFGRole) ~= "function" then
        return nil, "get_selected_lfg_role_unavailable"
    end

    local ok, selectedRole = pcall(GetSelectedLFGRole)
    if not ok then
        return nil, "get_selected_lfg_role_failed"
    end

    return self:NormalizeRoleState({ selectedRole = selectedRole })
end

function LTM_ROLE_STATE:ResolveRoleDiff(currentRole, targetRole)
    local normalizedTarget = self:NormalizeRoleState(targetRole)
    if normalizedTarget == nil then
        return {
            hasDiff = false,
            current = self:NormalizeRoleState(currentRole),
            target = nil,
            source = "target_missing",
        }
    end

    local normalizedCurrent = self:NormalizeRoleState(currentRole)
    return {
        hasDiff = type(normalizedCurrent) ~= "table"
            or normalizedCurrent.selectedRole ~= normalizedTarget.selectedRole,
        current = normalizedCurrent,
        target = normalizedTarget,
        source = "current_vs_target_compare",
    }
end
