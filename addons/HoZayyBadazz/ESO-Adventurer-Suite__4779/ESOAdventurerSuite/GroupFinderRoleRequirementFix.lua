-- ESO Adventurer Suite
-- v0.29.696 Group Finder enforced-role reconciliation.
-- ESO validates requested listing roles against the roles already attained by
-- the current group. If the group changes while the create/edit panel is open,
-- the cached spinner minimums can be stale and ESO can reject an otherwise
-- sensible listing with a role-mismatch error. Refresh and rebalance once, only
-- when the player presses Create/Edit; no polling or OnUpdate is used.

local EPC = ESOProgressionCoach
local GF = EPC and EPC.GroupFinderPlus
if not GF then return end
if GF._easRoleRequirementFix029696 then return end
GF._easRoleRequirementFix029696 = true

local ROLE_TANK = rawget(_G, "LFG_ROLE_TANK")
local ROLE_HEAL = rawget(_G, "LFG_ROLE_HEAL")
local ROLE_DPS = rawget(_G, "LFG_ROLE_DPS")
local ROLE_ANY = rawget(_G, "LFG_ROLE_INVALID")
if not ROLE_TANK or not ROLE_HEAL or not ROLE_DPS or ROLE_ANY == nil then return end

local SPECIFIC_ROLES = { ROLE_TANK, ROLE_HEAL, ROLE_DPS }
local ALL_ROLES = { ROLE_TANK, ROLE_HEAL, ROLE_DPS, ROLE_ANY }

local function asCount(value)
    value = tonumber(value) or 0
    if value < 0 then return 0 end
    return math.floor(value + 0.5)
end

local function roleName(roleType)
    if roleType == ROLE_TANK then return "Tank" end
    if roleType == ROLE_HEAL then return "Healer" end
    if roleType == ROLE_DPS then return "Damage" end
    return "Any"
end

local function printMessage(text)
    if EPC and type(EPC.Print) == "function" then
        EPC:Print(text)
    elseif type(d) == "function" then
        d("[ESO Adventurer Suite] " .. tostring(text))
    end
end

-- Remember the role the player changed most recently. If ESO's live attained
-- role counts force a rebalance, preserve that requested role before trimming
-- spare slots from the other roles. This is what lets a player deliberately add
-- a Healer even when another group member's role changed after the panel opened.
if ZO_GroupListingUserTypeData
    and type(ZO_GroupListingUserTypeData.SetDesiredRoleCountAtEdit) == "function"
    and not ZO_GroupListingUserTypeData._easRoleEditTracking029696 then

    ZO_GroupListingUserTypeData._easRoleEditTracking029696 = true
    local baseSetDesiredRoleCountAtEdit = ZO_GroupListingUserTypeData.SetDesiredRoleCountAtEdit
    function ZO_GroupListingUserTypeData:SetDesiredRoleCountAtEdit(roleType, value)
        if not GF._reconcilingRoles029696 and roleType ~= ROLE_ANY then
            GF.lastRoleEdited029696 = roleType
        end
        return baseSetDesiredRoleCountAtEdit(self, roleType, value)
    end
end

function GF:ReconcileCurrentGroupRoles029696(panel)
    local data = panel and panel.userTypeData
    if not data then return false end
    if type(data.DoesGroupEnforceRoles) ~= "function" or data:DoesGroupEnforceRoles() ~= true then
        return false
    end
    if type(data.GetNumRoles) ~= "function" then return false end

    local totalSlots = asCount(data:GetNumRoles())
    if totalSlots <= 0 then return false end

    -- Refresh both the editable cache used by the spinners and ESO's live
    -- attained counts used by the server-side listing validation.
    local attained, desired = {}, {}
    for _, roleType in ipairs(ALL_ROLES) do
        if type(data.UpdateAttainedRoleCountAtEdit) == "function" then
            pcall(data.UpdateAttainedRoleCountAtEdit, data, roleType)
        end
        if type(data.UpdateDesiredRoleCountAtEdit) == "function" then
            pcall(data.UpdateDesiredRoleCountAtEdit, data, roleType)
        end

        local a = 0
        if type(data.GetAttainedRoleCount) == "function" then
            local ok, value = pcall(data.GetAttainedRoleCount, data, roleType)
            if ok then a = asCount(value) end
        end
        attained[roleType] = a

        local dCount = 0
        if type(data.GetDesiredRoleCountAtEdit) == "function" then
            local ok, value = pcall(data.GetDesiredRoleCountAtEdit, data, roleType)
            if ok then dCount = asCount(value) end
        elseif type(data.GetDesiredRoleCount) == "function" then
            local ok, value = pcall(data.GetDesiredRoleCount, data, roleType)
            if ok then dCount = asCount(value) end
        end
        desired[roleType] = dCount
    end

    local original = {
        [ROLE_TANK] = desired[ROLE_TANK],
        [ROLE_HEAL] = desired[ROLE_HEAL],
        [ROLE_DPS] = desired[ROLE_DPS],
    }

    -- Existing group members must fit inside the enforced requested role counts.
    for _, roleType in ipairs(SPECIFIC_ROLES) do
        if desired[roleType] < attained[roleType] then
            desired[roleType] = attained[roleType]
        end
    end

    -- Keep enough Any slots for current members who do not have a specific LFG
    -- role. The remaining capacity can be divided among Tank/Healer/Damage.
    local specificCapacity = math.max(0, totalSlots - attained[ROLE_ANY])
    local specificTotal = desired[ROLE_TANK] + desired[ROLE_HEAL] + desired[ROLE_DPS]
    local excess = math.max(0, specificTotal - specificCapacity)
    local protectedRole = self.lastRoleEdited029696

    -- Remove excess only from slots that are not already occupied. Prefer to
    -- preserve the role the player most recently changed (for example Healer).
    local function reduceOnePass(allowProtected)
        local bestRole, bestSlack = nil, 0
        for _, roleType in ipairs(SPECIFIC_ROLES) do
            if allowProtected or roleType ~= protectedRole then
                local slack = desired[roleType] - attained[roleType]
                if slack > bestSlack then
                    bestRole, bestSlack = roleType, slack
                end
            end
        end
        if not bestRole or bestSlack <= 0 then return false end
        local amount = math.min(excess, bestSlack)
        desired[bestRole] = desired[bestRole] - amount
        excess = excess - amount
        return true
    end

    while excess > 0 and reduceOnePass(false) do end
    while excess > 0 and reduceOnePass(true) do end

    -- A valid group can never have attained roles that exceed its target size,
    -- but if ESO is mid-sync, do not disable role enforcement or submit a bad
    -- request. Let ESO's native role-change state settle instead.
    if excess > 0 then
        printMessage("Group Finder roles are still syncing. Try Confirm again in a moment.")
        return false, true
    end

    local changed = false
    for _, roleType in ipairs(SPECIFIC_ROLES) do
        if desired[roleType] ~= original[roleType] then changed = true break end
    end

    if changed and type(data.SetDesiredRoleCountAtEdit) == "function" then
        self._reconcilingRoles029696 = true
        for _, roleType in ipairs(SPECIFIC_ROLES) do
            pcall(data.SetDesiredRoleCountAtEdit, data, roleType, desired[roleType])
        end
        self._reconcilingRoles029696 = false

        if panel and type(panel.UpdateRoles) == "function" then
            pcall(panel.UpdateRoles, panel)
        end

        local anyCount = math.max(0, totalSlots - desired[ROLE_TANK] - desired[ROLE_HEAL] - desired[ROLE_DPS])
        printMessage(string.format(
            "Group Finder roles updated for the current group: Tank %d, Healer %d, Damage %d, Any %d.",
            desired[ROLE_TANK], desired[ROLE_HEAL], desired[ROLE_DPS], anyCount
        ))
    end

    return changed, false
end

-- Hook the shared submit path so both keyboard and gamepad create/edit flows get
-- the same one-shot reconciliation immediately before ESO's native request.
if ZO_GroupFinder_CreateEditGroupListing_Shared
    and type(ZO_GroupFinder_CreateEditGroupListing_Shared.DoCreateEdit) == "function"
    and not ZO_GroupFinder_CreateEditGroupListing_Shared._easRoleRequirementFix029696 then

    ZO_GroupFinder_CreateEditGroupListing_Shared._easRoleRequirementFix029696 = true
    local baseDoCreateEdit = ZO_GroupFinder_CreateEditGroupListing_Shared.DoCreateEdit
    function ZO_GroupFinder_CreateEditGroupListing_Shared:DoCreateEdit(...)
        local _, blockSubmit = GF:ReconcileCurrentGroupRoles029696(self)
        if blockSubmit then return end
        return baseDoCreateEdit(self, ...)
    end
end

EPC.groupFinderRoleRequirementFix029696 = true
