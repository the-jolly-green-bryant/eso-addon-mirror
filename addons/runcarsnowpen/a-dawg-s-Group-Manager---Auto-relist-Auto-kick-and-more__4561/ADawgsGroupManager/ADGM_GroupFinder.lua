local ADGM = _G["ADawgsGroupManager"]
local COLOR_WARN = ADGM.COLOR_WARN
local COLOR_BAD = ADGM.COLOR_BAD
local COLOR_RESET = ADGM.COLOR_RESET
local ACTION_NOTIFY = ADGM.ACTION_NOTIFY
local ACTION_AUTO = ADGM.ACTION_AUTO
local GROUP_FINDER_FAILURE_BACKOFF_SECONDS = ADGM.GROUP_FINDER_FAILURE_BACKOFF_SECONDS
local GROUP_FINDER_BLOCKED_RETRY_SECONDS = ADGM.GROUP_FINDER_BLOCKED_RETRY_SECONDS
local GROUP_FINDER_STEP_DELAY_MS = ADGM.GROUP_FINDER_STEP_DELAY_MS
local DEFAULTS = ADGM.DEFAULTS
local Chat = ADGM.Chat
local Debug = ADGM.Debug
local CopySavedVarsTable = ADGM.CopySavedVarsTable
local GetNow = ADGM.GetNow
local GetNowMs = ADGM.GetNowMs
local CanUseLeaderActions = ADGM.CanUseLeaderActions
local CancelGroupFinderRelistRetry = ADGM.CancelGroupFinderRelistRetry
local SetGroupFinderListingActive = ADGM.SetGroupFinderListingActive
local SetGroupFinderListingSleeping = ADGM.SetGroupFinderListingSleeping
local IsGroupFinderListingRuntimeArmed = ADGM.IsGroupFinderListingRuntimeArmed
local ClearGroupFinderListingRuntimeState = ADGM.ClearGroupFinderListingRuntimeState
local ClearLeaderAutomationState = ADGM.ClearLeaderAutomationState
local MarkCustomPreset = ADGM.MarkCustomPreset
local GROUP_FINDER_SIZE_SMALL_VALUE = ADGM.GROUP_FINDER_SIZE_SMALL_VALUE
local GROUP_FINDER_SIZE_STANDARD_VALUE = ADGM.GROUP_FINDER_SIZE_STANDARD_VALUE
local GROUP_FINDER_SIZE_LARGE_VALUE = ADGM.GROUP_FINDER_SIZE_LARGE_VALUE
local GROUP_FINDER_SPECIFIC_ROLE_TYPES = ADGM.GROUP_FINDER_SPECIFIC_ROLE_TYPES
local GROUP_FINDER_ROLE_TYPES = ADGM.GROUP_FINDER_ROLE_TYPES
local GROUP_FINDER_APPLICATION_ROLE_TTL_MS = ADGM.GROUP_FINDER_APPLICATION_ROLE_TTL_MS
local GROUP_FINDER_APPLICATION_APPROVAL_TIMEOUT_MS = ADGM.GROUP_FINDER_APPLICATION_APPROVAL_TIMEOUT_MS
local GetRoleLabel = ADGM.GetRoleLabel
local ScheduleGroupFinderRelistRetry = ADGM.ScheduleGroupFinderRelistRetry

local RelistSavedGroupFinderListing
local WarnRoleGuardAutoAcceptConflict

local GROUP_FINDER_EVENT_NAMES = {
    "EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT",
    "EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT",
    "EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT",
    "EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT",
    "EVENT_GROUP_FINDER_APPLICATIONS_RECEIVED",
    "EVENT_GROUP_FINDER_APPLICATIONS_REMOVED",
    "EVENT_GROUP_FINDER_APPLICATION_RECEIVED",
    "EVENT_GROUP_FINDER_APPLICATION_REMOVED",
    "EVENT_GROUP_FINDER_UPDATE_APPLICATIONS",
    "EVENT_GROUP_FINDER_SEARCH_RESULTS_READY",
    "EVENT_GROUP_FINDER_SEARCH_RESULTS_UPDATED",
    "EVENT_GROUP_FINDER_STATUS_UPDATED",
}

local GROUP_FINDER_ACTION_RESULT_NAMES = {
    "GROUP_FINDER_ACTION_RESULT_FAILED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ACCOUNT_TYPE_BLOCKS_APPLICATION",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ACCOUNT_TYPE_BLOCKS_CREATION",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ALLIANCE_REQUIREMENT",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ALREADY_APPLIED_TO_LISTING",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ALREADY_JOINED_GROUP",
    "GROUP_FINDER_ACTION_RESULT_FAILED_APPLICATION_DECLINED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_APPLICATION_PENDING",
    "GROUP_FINDER_ACTION_RESULT_FAILED_CP_REQUIREMENT",
    "GROUP_FINDER_ACTION_RESULT_FAILED_DISABLED_IN_ZONE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ENTITLEMENT_REQUIREMENT",
    "GROUP_FINDER_ACTION_RESULT_FAILED_GROUP_SIZE_MISMATCH",
    "GROUP_FINDER_ACTION_RESULT_FAILED_HAS_EXISTING_GROUP_LISTING",
    "GROUP_FINDER_ACTION_RESULT_FAILED_HAS_PENDING_GROUP_INVITE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INCORRECT_INVITE_CODE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_LEADER_BUSY",
    "GROUP_FINDER_ACTION_RESULT_FAILED_LEVEL_REQUIREMENT",
    "GROUP_FINDER_ACTION_RESULT_FAILED_LISTING_NOT_AVAILABLE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_MAXIMUM_ATTEMPTS",
    "GROUP_FINDER_ACTION_RESULT_FAILED_NOT_ENABLED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_NOT_LEADER",
    "GROUP_FINDER_ACTION_RESULT_FAILED_NOT_QUALIFIED_FOR_LFG_SET",
    "GROUP_FINDER_ACTION_RESULT_FAILED_PLATFORM_RESTRICTIONS",
    "GROUP_FINDER_ACTION_RESULT_FAILED_QUEUED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_REQUEST_PENDING",
    "GROUP_FINDER_ACTION_RESULT_FAILED_REQUEST_TIMEOUT",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ROLE_MISMATCH",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ROLE_REQUIREMENT",
    "GROUP_FINDER_ACTION_RESULT_FAILED_SOLO_REQUIREMENT",
    "GROUP_FINDER_ACTION_RESULT_SUCCESS",
    -- Older client names kept for compatibility with old saved logs/live builds.
    "GROUP_FINDER_ACTION_RESULT_FAILED_ALREADY_QUEUED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_APPLICATION_EXPIRED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_APPLICATION_IGNORED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_APPLICATION_RESCINDED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_DISABLED",
    "GROUP_FINDER_ACTION_RESULT_FAILED_GROUP_FULL",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INACTIVE_GROUP_LISTING",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INSUFFICIENT_PERMISSION",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_CHAMPION_POINTS",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_GROUP_SIZE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_INVITE_CODE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_PLAYSTYLE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_ROLE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_SEARCH",
    "GROUP_FINDER_ACTION_RESULT_FAILED_INVALID_TITLE",
    "GROUP_FINDER_ACTION_RESULT_FAILED_LISTING_NOT_FOUND",
    "GROUP_FINDER_ACTION_RESULT_FAILED_ON_COOLDOWN",
    "GROUP_FINDER_ACTION_RESULT_FAILED_REQUIRES_LEADER",
    "GROUP_FINDER_ACTION_RESULT_FAILED_TOO_MANY_APPLICATIONS",
    "GROUP_FINDER_ACTION_RESULT_TIMEOUT",
}

local REMOVE_GROUP_LISTING_REASON_NAMES = {
    "REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_DISABLED_IN_ZONE",
    "REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_LEADER_CHANGED",
    "REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_LISTING_FULLFILLED",
    "REMOVE_GROUP_LISTING_REASON_REMOVED_BY_LEADER",
    "REMOVE_GROUP_LISTING_REASON_REMOVED_BY_QUEUE",
    "REMOVE_GROUP_LISTING_REASON_REMOVED_BY_SERVER",
}

local function GetSelectedGroupFinderOptionIndices(userType, countFn, optionFn)
    local selected = {}
    local count = countFn(userType) or 0
    for i = 1, count do
        local _, isSet = optionFn(userType, i)
        if isSet == true then
            selected[#selected + 1] = i
        end
    end
    return selected
end

local function GetSavedGroupFinderOptionIndex(option, countFn, userType)
    local index = tonumber(option)
    if not index then
        Debug("Skipped legacy Group Finder option value \"" .. tostring(option) .. "\". Re-save the template to store option indexes.")
        return nil
    end

    index = math.floor(index)
    if index < 1 then
        return nil
    end

    local count = countFn(userType)
    if count and index > count then
        Debug("Skipped Group Finder option index " .. tostring(index) .. " because only " .. tostring(count) .. " options are available.")
        return nil
    end

    return index
end

local function GetCurrentGroupFinderListingSnapshot(userType)
    userType = userType or GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING
    return {
        savedAt = GetTimeStamp(),
        userType = userType,
        title = GetGroupFinderUserTypeGroupListingTitle(userType) or "",
        description = GetGroupFinderUserTypeGroupListingDescription(userType) or "",
        category = GetGroupFinderUserTypeGroupListingCategory(userType),
        groupSize = GetGroupFinderUserTypeGroupListingGroupSize(userType),
        numRoles = GetGroupFinderUserTypeGroupListingNumRoles(userType),
        playstyle = GetGroupFinderUserTypeGroupListingPlaystyle(userType),
        inviteCode = GetGroupFinderUserTypeGroupListingInviteCode(userType),
        championPoints = GetGroupFinderCreateGroupListingChampionPoints(userType) or 0,
        autoAccept = DoesGroupFinderUserTypeGroupListingAutoAcceptRequests(userType),
        enforceRoles = DoesGroupFinderUserTypeGroupListingEnforceRoles(userType),
        requireChampion = DoesGroupFinderUserTypeGroupListingRequireChampion(userType),
        requireInviteCode = DoesGroupFinderUserTypeGroupListingRequireInviteCode(userType),
        requireVOIP = DoesGroupFinderUserTypeGroupListingRequireVOIP(userType),
        requireDLC = DoesGroupFinderUserTypeGroupListingRequireDLC(userType),
        primaryOptions = {},
        secondaryOptions = {},
        desiredRoles = {},
    }
end

local function GetNativeGroupFinderUserTypeData(userType)
    local draftUserType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    local groupFinderPanel = ADGM.state.nativeGroupFinderPanel
    if userType ~= draftUserType or not groupFinderPanel then
        return nil
    end

    return groupFinderPanel.userTypeData
end

local function TryGetUserTypeDataDesiredRoleCount(userTypeData, roleType)
    if not userTypeData then
        return nil
    end

    local value = userTypeData:GetDesiredRoleCountAtEdit(roleType)
    if value ~= nil then
        return value
    end

    value = userTypeData:GetDesiredRoleCount(roleType)
    if value ~= nil then
        return value
    end

    return nil
end

local function GetStoredDesiredRoleCount(listing, roleType)
    if not listing or not listing.desiredRoles or roleType == nil then
        return nil
    end

    local count = listing.desiredRoles[roleType]
    if count == nil then
        return nil
    end

    return math.floor(tonumber(count) or 0)
end

local function GetListingNumRoles(listing, userType)
    if userType then
        local numRoles = GetGroupFinderUserTypeGroupListingNumRoles(userType)
        if numRoles then
            return numRoles
        end
    end
    return listing and listing.numRoles
end

local function CalculateAnyRoleCount(listing, userType)
    if not listing or not listing.desiredRoles then
        return nil
    end

    local anyCount = GetStoredDesiredRoleCount(listing, LFG_ROLE_INVALID)
    if anyCount ~= nil then
        return anyCount
    end

    local numRoles = GetListingNumRoles(listing, userType)
    if not numRoles then
        return nil
    end

    local specificCount = 0
    for _, roleType in ipairs(GROUP_FINDER_SPECIFIC_ROLE_TYPES) do
        local count = GetStoredDesiredRoleCount(listing, roleType)
        if count == nil then
            return nil
        end
        specificCount = specificCount + count
    end

    return zo_max(0, numRoles - specificCount)
end

local function CaptureDesiredRoleCounts(listing)
    if not listing then
        return
    end

    local userType = listing.userType
    local userTypeData = GetNativeGroupFinderUserTypeData(userType)
    listing.desiredRoles = {}

    for _, roleType in ipairs(GROUP_FINDER_ROLE_TYPES) do
        local desiredCount = TryGetUserTypeDataDesiredRoleCount(userTypeData, roleType)
        if desiredCount == nil then
            desiredCount = GetGroupFinderUserTypeGroupListingDesiredRoleCount(userType, roleType)
        end
        if desiredCount ~= nil then
            listing.desiredRoles[roleType] = math.floor(tonumber(desiredCount) or 0)
        end
    end

    if listing.desiredRoles[LFG_ROLE_INVALID] == nil then
        local anyCount = CalculateAnyRoleCount(listing, userType)
        if anyCount ~= nil then
            listing.desiredRoles[LFG_ROLE_INVALID] = anyCount
        end
    end
end

local function CaptureCurrentGroupFinderListing(silent, userType)
    local listing = GetCurrentGroupFinderListingSnapshot(userType)
    if not listing.category or not listing.groupSize or not listing.playstyle then
        if not silent then
            Chat(COLOR_BAD .. "Could not save listing. Create a Group Finder listing with the normal UI first, then run /adgm gfsave." .. COLOR_RESET, true)
        end
        return false
    end

    local userType = listing.userType
    listing.primaryOptions = GetSelectedGroupFinderOptionIndices(
        userType,
        GetGroupFinderUserTypeGroupListingNumPrimaryOptions,
        GetGroupFinderUserTypeGroupListingPrimaryOptionByIndex)
    listing.secondaryOptions = GetSelectedGroupFinderOptionIndices(
        userType,
        GetGroupFinderUserTypeGroupListingNumSecondaryOptions,
        GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex)

    CaptureDesiredRoleCounts(listing)

    ADGM.vars.groupFinder.savedListing = listing
    WarnRoleGuardAutoAcceptConflict("saved listing", listing)
    if silent then
        Debug("Auto-saved Group Finder listing template: category=" .. tostring(listing.category) .. ", size=" .. tostring(listing.groupSize) .. ", playstyle=" .. tostring(listing.playstyle) .. ".")
    else
        Chat("Saved Group Finder listing template: category=" .. tostring(listing.category) .. ", size=" .. tostring(listing.groupSize) .. ", playstyle=" .. tostring(listing.playstyle) .. ".", true)
    end
    return true
end

local function AutoSaveGroupFinderListing(source)
    if CaptureCurrentGroupFinderListing(true) then
        Debug("Saved Group Finder listing template from " .. tostring(source) .. ".")
    else
        Debug("Auto-save skipped after " .. tostring(source) .. "; active listing data was not readable yet.")
    end
end

local function GetTemplateRoleLabel(roleType)
    if roleType == LFG_ROLE_INVALID then
        return "any"
    end
    return GetRoleLabel(roleType)
end

local function FormatDesiredRoleCounts(listing)
    if not listing or not listing.desiredRoles then
        return nil
    end

    local values = {}
    for _, roleType in ipairs(GROUP_FINDER_ROLE_TYPES) do
        local count = GetStoredDesiredRoleCount(listing, roleType)
        if count ~= nil then
            values[#values + 1] = GetTemplateRoleLabel(roleType) .. "=" .. tostring(count)
        end
    end

    if #values == 0 then
        return nil
    end
    return table.concat(values, ", ")
end

local function PrintSavedGroupFinderListing()
    local listing = ADGM.vars.groupFinder.savedListing
    if not listing then
        Chat("No Group Finder listing template saved yet. Create a listing, then run /adgm gfsave.", true)
        return
    end

    Chat("Saved listing: category=" .. tostring(listing.category) .. ", size=" .. tostring(listing.groupSize) .. ", playstyle=" .. tostring(listing.playstyle) .. ".", true)
    Chat("Title: " .. tostring(listing.title), true)
    Chat("Description: " .. tostring(listing.description), true)
    Chat("Flags: autoAccept=" .. tostring(listing.autoAccept) .. ", enforceRoles=" .. tostring(listing.enforceRoles) .. ", requireCP=" .. tostring(listing.requireChampion) .. ", cp=" .. tostring(listing.championPoints or 0) .. ", voice=" .. tostring(listing.requireVOIP) .. ".", true)
    local roleText = FormatDesiredRoleCounts(listing)
    if roleText then
        Chat("Roles: " .. roleText .. ".", true)
    end
end

local function SetGroupFinderRelistMode(mode)
    if mode == "on" then
        MarkCustomPreset()
        ADGM.vars.groupFinder.relistOnLeave = true
        Chat("Group Finder relist on member leave enabled. Action: " .. tostring(ADGM.vars.groupFinder.mode) .. ".", true)
    elseif mode == "off" then
        MarkCustomPreset()
        ADGM.vars.groupFinder.relistOnLeave = false
        Chat("Group Finder relist on member leave disabled.", true)
    elseif mode == ACTION_NOTIFY then
        MarkCustomPreset()
        ADGM.vars.groupFinder.relistOnLeave = true
        ADGM.vars.groupFinder.mode = ACTION_NOTIFY
        Chat("Group Finder relist set to notify only.", true)
    elseif mode == ACTION_AUTO then
        MarkCustomPreset()
        ADGM.vars.groupFinder.relistOnLeave = true
        ADGM.vars.groupFinder.mode = ACTION_AUTO
        Chat("Group Finder relist set to auto.", true)
    else
        Chat("Usage: /adgm gfrelist [on|off|notify|auto]", true)
    end
end

local function SetDraftValue(fn, ...)
    fn(...)
    return true
end

local function ApplyDesiredRoleCountsToDraft(listing, draftUserType)
    if not listing or not listing.desiredRoles then
        return true
    end

    local ok = true
    for _, roleType in ipairs(GROUP_FINDER_SPECIFIC_ROLE_TYPES) do
        local desiredCount = GetStoredDesiredRoleCount(listing, roleType)
        if desiredCount ~= nil then
            ok = SetDraftValue(SetGroupFinderUserTypeGroupListingRoleCount, draftUserType, roleType, desiredCount) and ok
        end
    end

    local anyCount = CalculateAnyRoleCount(listing, draftUserType)
    if anyCount ~= nil then
        ok = SetDraftValue(SetGroupFinderUserTypeGroupListingRoleCount, draftUserType, LFG_ROLE_INVALID, anyCount) and ok
    end

    return ok
end

local function AddDelayedDraftSetterStep(steps, fn, ...)
    local args = { ... }
    steps[#steps + 1] = function()
        return SetDraftValue(fn, unpack(args))
    end
end

local function AddDelayedDraftOptionsRefreshStep(steps, draftUserType)
    steps[#steps + 1] = function()
        UpdateGroupFinderUserTypeGroupListingOptions(draftUserType)
        SetGroupFinderUserTypeGroupListingSecondaryOptionDefault(draftUserType)
        return true
    end
end

local function AddDelayedDraftOptionSetterStep(steps, setterFn, draftUserType, option, countFn)
    steps[#steps + 1] = function()
        local index = GetSavedGroupFinderOptionIndex(option, countFn, draftUserType)
        if not index then
            return true
        end
        return SetDraftValue(setterFn, draftUserType, index)
    end
end

local function AddDelayedDesiredRoleCountSteps(steps, listing, draftUserType)
    if not listing or not listing.desiredRoles then
        return
    end

    for _, roleType in ipairs(GROUP_FINDER_SPECIFIC_ROLE_TYPES) do
        local desiredCount = GetStoredDesiredRoleCount(listing, roleType)
        if desiredCount ~= nil then
            AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingRoleCount, draftUserType, roleType, desiredCount)
        end
    end

    local anyCount = CalculateAnyRoleCount(listing, draftUserType)
    if anyCount ~= nil then
        AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingRoleCount, draftUserType, LFG_ROLE_INVALID, anyCount)
    end
end

local function BuildDelayedSavedListingDraftSteps(listing)
    local draftUserType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    local steps = {}

    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingCategory, draftUserType, listing.category)
    AddDelayedDraftOptionsRefreshStep(steps, draftUserType)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingTitle, draftUserType, listing.title or "")
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingDescription, draftUserType, listing.description or "")
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingGroupSize, draftUserType, listing.groupSize)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingPlaystyle, draftUserType, listing.playstyle)
    AddDelayedDraftOptionsRefreshStep(steps, draftUserType)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingAutoAcceptRequests, draftUserType, listing.autoAccept == true)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingEnforceRoles, draftUserType, listing.enforceRoles == true)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingRequiresChampion, draftUserType, listing.requireChampion == true)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingRequiresVOIP, draftUserType, listing.requireVOIP == true)
    AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingRequiresInviteCode, draftUserType, listing.requireInviteCode == true)

    if listing.inviteCode and listing.inviteCode ~= 0 then
        AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingInviteCode, draftUserType, listing.inviteCode)
    end

    if listing.requireChampion == true then
        AddDelayedDraftSetterStep(steps, SetGroupFinderUserTypeGroupListingChampionPoints, draftUserType, listing.championPoints or 0)
    end

    AddDelayedDesiredRoleCountSteps(steps, listing, draftUserType)

    if listing.primaryOptions then
        for _, option in ipairs(listing.primaryOptions) do
            AddDelayedDraftOptionSetterStep(steps, SetGroupFinderUserTypeGroupListingPrimaryOption, draftUserType, option, GetGroupFinderUserTypeGroupListingNumPrimaryOptions)
        end
    end

    if listing.secondaryOptions then
        for _, option in ipairs(listing.secondaryOptions) do
            AddDelayedDraftOptionSetterStep(steps, SetGroupFinderUserTypeGroupListingSecondaryOption, draftUserType, option, GetGroupFinderUserTypeGroupListingNumSecondaryOptions)
        end
    end

    return steps
end

local function RunDelayedGroupFinderSteps(steps, token, onComplete)
    local index = 1

    local function finish(ok)
        if ADGM.state.groupFinderRelistToken == token then
            ADGM.state.groupFinderRelistInProgress = false
        end
        if onComplete then
            onComplete(ok)
        end
    end

    local function runNext()
        if ADGM.state.groupFinderRelistToken ~= token then
            return
        end

        local step = steps[index]
        if not step then
            finish(true)
            return
        end

        index = index + 1
        local ok, result = pcall(step)
        if not ok then
            Debug("Group Finder delayed step failed: " .. tostring(result))
            finish(false)
            return
        end
        if result == false then
            finish(false)
            return
        end

        if steps[index] then
            zo_callLater(runNext, GROUP_FINDER_STEP_DELAY_MS)
        else
            runNext()
        end
    end

    runNext()
end

local function ApplyDesiredRoleCountsToUserTypeData(userTypeData, listing)
    if not userTypeData or not listing or not listing.desiredRoles then
        return
    end

    for _, roleType in ipairs(GROUP_FINDER_SPECIFIC_ROLE_TYPES) do
        local desiredCount = GetStoredDesiredRoleCount(listing, roleType)
        if desiredCount ~= nil then
            userTypeData:SetDesiredRoleCountAtEdit(roleType, desiredCount)
        end
    end
end

local function ApplySavedListingToDraft(listing)
    local draftUserType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    local ok = true

    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingCategory, draftUserType, listing.category) and ok
    UpdateGroupFinderUserTypeGroupListingOptions(draftUserType)
    SetGroupFinderUserTypeGroupListingSecondaryOptionDefault(draftUserType)

    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingTitle, draftUserType, listing.title or "") and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingDescription, draftUserType, listing.description or "") and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingGroupSize, draftUserType, listing.groupSize) and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingPlaystyle, draftUserType, listing.playstyle) and ok
    UpdateGroupFinderUserTypeGroupListingOptions(draftUserType)
    SetGroupFinderUserTypeGroupListingSecondaryOptionDefault(draftUserType)
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingAutoAcceptRequests, draftUserType, listing.autoAccept == true) and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingEnforceRoles, draftUserType, listing.enforceRoles == true) and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingRequiresChampion, draftUserType, listing.requireChampion == true) and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingRequiresVOIP, draftUserType, listing.requireVOIP == true) and ok
    ok = SetDraftValue(SetGroupFinderUserTypeGroupListingRequiresInviteCode, draftUserType, listing.requireInviteCode == true) and ok

    if listing.inviteCode and listing.inviteCode ~= 0 then
        ok = SetDraftValue(SetGroupFinderUserTypeGroupListingInviteCode, draftUserType, listing.inviteCode) and ok
    end

    if listing.requireChampion == true then
        ok = SetDraftValue(SetGroupFinderUserTypeGroupListingChampionPoints, draftUserType, listing.championPoints or 0) and ok
    end

    ok = ApplyDesiredRoleCountsToDraft(listing, draftUserType) and ok

    if listing.primaryOptions then
        for _, option in ipairs(listing.primaryOptions) do
            local index = GetSavedGroupFinderOptionIndex(option, GetGroupFinderUserTypeGroupListingNumPrimaryOptions, draftUserType)
            if index then
                ok = SetDraftValue(SetGroupFinderUserTypeGroupListingPrimaryOption, draftUserType, index) and ok
            end
        end
    end

    if listing.secondaryOptions then
        for _, option in ipairs(listing.secondaryOptions) do
            local index = GetSavedGroupFinderOptionIndex(option, GetGroupFinderUserTypeGroupListingNumSecondaryOptions, draftUserType)
            if index then
                ok = SetDraftValue(SetGroupFinderUserTypeGroupListingSecondaryOption, draftUserType, index) and ok
            end
        end
    end

    return ok
end

local function RefreshNativeGroupFinderControlsFromDraft(groupFinderPanel)
    groupFinderPanel:UpdateUserType()
    groupFinderPanel:PopulateCategoryDropdown()
    groupFinderPanel:PopulatePrimaryDropdown()
    groupFinderPanel:PopulateSizeDropdown()
    groupFinderPanel:UpdateEditBoxGroupListingTitle()
    groupFinderPanel:UpdateEditBoxGroupListingDescription()
    groupFinderPanel:PopulatePlaystyleDropdown()
    groupFinderPanel:UpdateCheckStateRequireChampion()
    groupFinderPanel:UpdateCheckStateRequireVOIP()
    groupFinderPanel:UpdateCheckStateInviteCode()
    groupFinderPanel:UpdateCheckStateAutoAcceptRequests()
    groupFinderPanel:UpdateCheckStateEnforceRoles()
    groupFinderPanel:UpdateCreateEditButton()
end

local function ApplyListingToNativeGroupFinderPanel(listing)
    local groupFinderPanel = ADGM.state.nativeGroupFinderPanel
    if not groupFinderPanel or not listing then
        return false
    end

    groupFinderPanel:SetCategory(listing.category)
    groupFinderPanel:UpdateUserType()
    groupFinderPanel:Refresh()
    local ok = ApplySavedListingToDraft(listing)

    local userTypeData = groupFinderPanel.userTypeData
    if userTypeData then
        userTypeData:SetGroupAutoAcceptRequests(listing.autoAccept == true)
        userTypeData:SetGroupEnforceRoles(listing.enforceRoles == true)
        ApplyDesiredRoleCountsToUserTypeData(userTypeData, listing)
        userTypeData:SetGroupRequiresChampion(listing.requireChampion == true)
        userTypeData:SetChampionPoints(tonumber(listing.championPoints) or 0)
        userTypeData:SetGroupRequiresVOIP(listing.requireVOIP == true)
        userTypeData:SetGroupRequiresInviteCode(listing.requireInviteCode == true)
    end

    RefreshNativeGroupFinderControlsFromDraft(groupFinderPanel)
    return ok
end

local function NormalizeGroupFinderListingSize(listing)
    if not listing then
        return
    end

    -- The API enum values overlap with player counts:
    -- SMALL=1, STANDARD=2, LARGE=4. Only raw 12 is unambiguous here.
    if listing.groupSize == 12 then
        listing.groupSize = GROUP_FINDER_SIZE_LARGE_VALUE
    end
end

local function EnsureListingCanCreate(listing)
    if type(listing) ~= "table" then
        return false, "no saved Group Finder template"
    end

    NormalizeGroupFinderListingSize(listing)

    if listing.category == nil then
        return false, "saved template is missing category"
    end

    if listing.groupSize == nil then
        return false, "saved template is missing group size"
    end

    if listing.playstyle == nil then
        return false, "saved template is missing playstyle"
    end

    return true
end

local function GetListingRoleSlotCount(listing, userType)
    local numRoles = GetListingNumRoles(listing, userType)
    if numRoles then
        return numRoles
    end

    if listing and listing.groupSize == GROUP_FINDER_SIZE_LARGE_VALUE then
        return 12
    elseif listing and listing.groupSize == GROUP_FINDER_SIZE_STANDARD_VALUE then
        return 4
    elseif listing and listing.groupSize == GROUP_FINDER_SIZE_SMALL_VALUE then
        return 2
    end

    return ADGM.vars and ADGM.vars.targetGroupSize or DEFAULTS.targetGroupSize
end

local function BuildGroupFinderCreateValidationUserTypeData(listing, userType)
    return {
        GetUserType = function()
            return userType
        end,
        GetNumRoles = function()
            return GetListingRoleSlotCount(listing, userType)
        end,
        DoesGroupRequireInviteCode = function()
            local value = DoesGroupFinderUserTypeGroupListingRequireInviteCode(userType)
            if value ~= nil then
                return value == true
            end
            return listing and listing.requireInviteCode == true
        end,
        GetInviteCode = function()
            return GetGroupFinderUserTypeGroupListingInviteCode(userType) or (listing and listing.inviteCode) or 0
        end,
    }
end

local function BuildGroupFinderTitleValidationControl(listing, userType)
    return {
        GetText = function()
            return GetGroupFinderUserTypeGroupListingTitle(userType) or (listing and listing.title) or ""
        end,
    }
end

local function HasCreatedGroupFinderListing()
    local createdUserType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING
    return HasGroupListingForUserType(createdUserType) == true
end

local function GetGroupFinderCreateBlockedReason(listing)
    local draftUserType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT

    if HasCreatedGroupFinderListing() then
        return "a Group Finder listing already exists"
    end

    local userTypeData = BuildGroupFinderCreateValidationUserTypeData(listing, draftUserType)
    local titleControl = BuildGroupFinderTitleValidationControl(listing, draftUserType)
    local canCreate, disabledString = ZO_GroupFinder_CanDoCreateEdit(userTypeData, titleControl, false)
    if not canCreate then
        return disabledString or "ESO disabled Group Finder create"
    end

    return nil
end

local function ApplyCurrentGroupFinderTemplateToNativeDraft(reason)
    if not ADGM.vars or not ADGM.vars.groupFinder then
        return false
    end

    local listing = ADGM.vars.groupFinder.savedListing
    if not listing then
        return false
    end

    local templateOk, templateError = EnsureListingCanCreate(listing)
    if not templateOk then
        Debug("Skipped applying Group Finder template" .. (reason and " (" .. reason .. ")" or "") .. ": " .. tostring(templateError) .. ".")
        return false
    end

    local ok = ADGM.state.nativeGroupFinderPanel
        and ApplyListingToNativeGroupFinderPanel(listing)
        or ApplySavedListingToDraft(listing)
    Debug("Applied Group Finder template to create draft" .. (reason and " (" .. reason .. ")" or "") .. ".")
    return ok
end

local function IsGroupFinderDraftBlank()
    local draftUserType = GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT
    local title = GetGroupFinderUserTypeGroupListingTitle(draftUserType) or ""
    local description = GetGroupFinderUserTypeGroupListingDescription(draftUserType) or ""
    return zo_strtrim(title) == "" and zo_strtrim(description) == ""
end

function ADGM.MaybeApplyCurrentGroupFinderTemplateToNativeDraft(reason)
    if IsGroupFinderDraftBlank() then
        return ApplyCurrentGroupFinderTemplateToNativeDraft(reason)
    end

    Debug("Skipped applying Group Finder template" .. (reason and " (" .. reason .. ")" or "") .. " because the create draft is not blank.")
    return false
end

local function SendGroupFinderRelistRequest(requestName, requestFn, reason)
    Debug("Calling " .. requestName .. "()" .. (reason and " (" .. reason .. ")" or "") .. ".")
    ADGM.state.lastGroupFinderRequestName = requestName
    ADGM.state.lastGroupFinderRequestReason = reason
    ADGM.state.lastGroupFinderRequestByAddon = true
    requestFn()
    Debug("Relist request sent. Waiting for Group Finder result event.")
    return true
end

RelistSavedGroupFinderListing = function(reason)
    local listing = ADGM.vars.groupFinder.savedListing
    if not listing then
        Chat(COLOR_BAD .. "No saved listing template. Create a listing with ESO UI, then run /adgm gfsave first." .. COLOR_RESET)
        return false
    end

    if not CanUseLeaderActions() then
        Chat(COLOR_BAD .. "Cannot relist because you are not group leader." .. COLOR_RESET)
        return false
    end

    local now = GetNow()
    local backoffRemaining = (ADGM.state.groupFinderBackoffUntil or 0) - now
    if backoffRemaining > 0 then
        Chat(COLOR_WARN .. "Relist skipped. ESO blocked the last Group Finder request; retry in "
            .. tostring(backoffRemaining)
            .. " seconds." .. COLOR_RESET, true)
        return false
    end

    local cooldownSeconds = ADGM.vars.groupFinder.cooldownSeconds or DEFAULTS.groupFinder.cooldownSeconds
    local elapsed = now - (ADGM.state.lastRelistAttempt or 0)
    if elapsed < cooldownSeconds then
        Chat(COLOR_WARN .. "Relist skipped. Cooldown remaining: " .. tostring(cooldownSeconds - elapsed) .. " seconds." .. COLOR_RESET)
        return false
    end

    if ADGM.state.groupFinderRelistInProgress then
        Chat(COLOR_WARN .. "Relist already in progress." .. COLOR_RESET, true)
        return false
    end

    Debug("Applying saved template to Group Finder draft" .. (reason and " (" .. reason .. ")" or "") .. ".")
    listing = CopySavedVarsTable(listing)
    WarnRoleGuardAutoAcceptConflict("relist template", listing)
    local templateOk, templateError = EnsureListingCanCreate(listing)
    if not templateOk then
        Chat(COLOR_BAD .. "Cannot relist: " .. tostring(templateError) .. ". Save a Group Finder template first." .. COLOR_RESET, true)
        return false
    end

    ADGM.state.groupFinderRelistToken = (ADGM.state.groupFinderRelistToken or 0) + 1
    local token = ADGM.state.groupFinderRelistToken
    ADGM.state.groupFinderRelistInProgress = true

    local requestStepReached = false
    local steps = BuildDelayedSavedListingDraftSteps(listing)
    steps[#steps + 1] = function()
        requestStepReached = true
        if not CanUseLeaderActions() then
            Chat(COLOR_BAD .. "Relist cancelled because you are not group leader." .. COLOR_RESET, true)
            return false
        end

        local requestNow = GetNow()
        local requestBackoffRemaining = (ADGM.state.groupFinderBackoffUntil or 0) - requestNow
        if requestBackoffRemaining > 0 then
            Chat(COLOR_WARN .. "Relist skipped. ESO blocked the last Group Finder request; retry in "
                .. tostring(requestBackoffRemaining)
                .. " seconds." .. COLOR_RESET, true)
            return false
        end

        local requestElapsed = requestNow - (ADGM.state.lastRelistAttempt or 0)
        if requestElapsed < cooldownSeconds then
            Chat(COLOR_WARN .. "Relist skipped. Cooldown remaining: " .. tostring(cooldownSeconds - requestElapsed) .. " seconds." .. COLOR_RESET)
            return false
        end

        local blockedReason = GetGroupFinderCreateBlockedReason(listing)
        if blockedReason then
            Chat(COLOR_WARN .. "Group Finder create skipped: " .. tostring(blockedReason) .. "." .. COLOR_RESET)
            return false
        end

        local requestSent = SendGroupFinderRelistRequest("RequestCreateGroupListing", RequestCreateGroupListing, reason)
        if requestSent then
            ADGM.state.lastRelistAttempt = GetNow()
        end
        return requestSent
    end

    RunDelayedGroupFinderSteps(steps, token, function(ok)
        if not ok and not requestStepReached then
            Chat(COLOR_BAD .. "Draft setup had errors. Relist cancelled." .. COLOR_RESET, true)
        end
    end)
    return true
end

local function FormatEventArgs(...)
    local count = select("#", ...)
    local values = {}
    for i = 1, count do
        values[#values + 1] = tostring(select(i, ...))
    end
    return table.concat(values, ", ")
end

local groupFinderEventNameById = {}
local groupFinderActionResultNameById = {}
local removeGroupListingReasonNameById = {}

local function BuildNameMap(names, target)
    for _, name in ipairs(names) do
        local value = _G[name]
        if type(value) == "number" and target[value] == nil then
            target[value] = name
        end
    end
end

local function BuildGroupFinderActionResultNames()
    BuildNameMap(GROUP_FINDER_ACTION_RESULT_NAMES, groupFinderActionResultNameById)
end

local function BuildRemoveGroupListingReasonNames()
    BuildNameMap(REMOVE_GROUP_LISTING_REASON_NAMES, removeGroupListingReasonNameById)
end

local function GetGroupFinderEventName(eventCode)
    if not groupFinderEventNameById[eventCode] then
        for _, eventName in ipairs(GROUP_FINDER_EVENT_NAMES) do
            local eventId = _G[eventName]
            if eventId then
                groupFinderEventNameById[eventId] = eventName
            end
        end
    end
    return groupFinderEventNameById[eventCode] or tostring(eventCode)
end

local function GetGroupFinderActionResultName(result)
    if not next(groupFinderActionResultNameById) then
        BuildGroupFinderActionResultNames()
    end
    return groupFinderActionResultNameById[result]
end

function ADGM.FormatGroupFinderActionResult(result)
    local name = GetGroupFinderActionResultName(result)
    if name then
        return name
    end
    if result == GROUP_FINDER_ACTION_RESULT_SUCCESS then
        return "SUCCESS"
    elseif result == GROUP_FINDER_ACTION_RESULT_FAILED then
        return "FAILED"
    end
    return tostring(result)
end

local function ConstantNameToShortText(name, prefix)
    if not name then
        return nil
    end

    name = string.gsub(name, "^" .. prefix, "")
    name = string.gsub(name, "^FAILED_", "")
    name = string.gsub(name, "_", " ")
    return string.lower(name)
end

local function FormatShortGroupFinderActionResult(result)
    if result == GROUP_FINDER_ACTION_RESULT_SUCCESS then
        return "success"
    elseif result == GROUP_FINDER_ACTION_RESULT_FAILED then
        return "failed"
    end
    local name = GetGroupFinderActionResultName(result)
    local shortNames = {
        GROUP_FINDER_ACTION_RESULT_FAILED_ACCOUNT_TYPE_BLOCKS_CREATION = "account restricted",
        GROUP_FINDER_ACTION_RESULT_FAILED_APPLICATION_PENDING = "application pending",
        GROUP_FINDER_ACTION_RESULT_FAILED_DISABLED_IN_ZONE = "disabled in this zone",
        GROUP_FINDER_ACTION_RESULT_FAILED_GROUP_SIZE_MISMATCH = "group size mismatch",
        GROUP_FINDER_ACTION_RESULT_FAILED_HAS_EXISTING_GROUP_LISTING = "listing already exists",
        GROUP_FINDER_ACTION_RESULT_FAILED_INCORRECT_INVITE_CODE = "bad invite code",
        GROUP_FINDER_ACTION_RESULT_FAILED_LEADER_BUSY = "leader busy",
        GROUP_FINDER_ACTION_RESULT_FAILED_MAXIMUM_ATTEMPTS = "too many attempts",
        GROUP_FINDER_ACTION_RESULT_FAILED_NOT_ENABLED = "not enabled",
        GROUP_FINDER_ACTION_RESULT_FAILED_NOT_LEADER = "not leader",
        GROUP_FINDER_ACTION_RESULT_FAILED_QUEUED = "queued",
        GROUP_FINDER_ACTION_RESULT_FAILED_REQUEST_PENDING = "request pending",
        GROUP_FINDER_ACTION_RESULT_FAILED_REQUEST_TIMEOUT = "request timed out",
        GROUP_FINDER_ACTION_RESULT_FAILED_ROLE_MISMATCH = "role mismatch",
        GROUP_FINDER_ACTION_RESULT_FAILED_ROLE_REQUIREMENT = "role requirement",
        GROUP_FINDER_ACTION_RESULT_FAILED_SOLO_REQUIREMENT = "solo requirement",
        GROUP_FINDER_ACTION_RESULT_FAILED_ON_COOLDOWN = "cooldown",
        GROUP_FINDER_ACTION_RESULT_TIMEOUT = "timed out",
    }
    if name and shortNames[name] then
        return shortNames[name]
    end
    local generated = ConstantNameToShortText(name, "GROUP_FINDER_ACTION_RESULT_")
    if generated then
        return generated
    end
    return tostring(result)
end

local function ListingHasEsoAutoAcceptRequests(listing)
    if listing and listing.autoAccept == true then
        return true
    end
    if ADGM.vars
        and ADGM.vars.groupFinder
        and ADGM.vars.groupFinder.savedListing
        and ADGM.vars.groupFinder.savedListing.autoAccept == true
    then
        return true
    end
    if DoesGroupFinderUserTypeGroupListingAutoAcceptRequests(GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING) == true then
        return true
    end
    return DoesGroupFinderUserTypeGroupListingAutoAcceptRequests(GROUP_FINDER_GROUP_LISTING_USER_TYPE_GROUP_LISTING_DRAFT) == true
end

WarnRoleGuardAutoAcceptConflict = function(source, listing)
    if not ADGM.vars
        or not ADGM.vars.roleGuard
        or ADGM.vars.roleGuard.enabled ~= true
        or not ListingHasEsoAutoAcceptRequests(listing)
    then
        return
    end

    local now = GetNow()
    if now - (ADGM.state.lastRoleGuardAutoAcceptWarningAt or 0) < 30 then
        return
    end

    ADGM.state.lastRoleGuardAutoAcceptWarningAt = now
    Chat(COLOR_WARN
        .. "Role Guard is unreliable with ESO Auto Accept Requests enabled"
        .. (source and (" (" .. tostring(source) .. ")") or "")
        .. ". Turn off ESO Auto Accept Requests or use ADGM auto-accept applications."
        .. COLOR_RESET, true)
end

local function GetGroupFinderRetryDelaySeconds(result)
    local name = GetGroupFinderActionResultName(result)
    if name == "GROUP_FINDER_ACTION_RESULT_FAILED_REQUEST_PENDING"
        or name == "GROUP_FINDER_ACTION_RESULT_FAILED_LEADER_BUSY"
    then
        return GROUP_FINDER_BLOCKED_RETRY_SECONDS
    elseif name == "GROUP_FINDER_ACTION_RESULT_FAILED_REQUEST_TIMEOUT"
        or name == "GROUP_FINDER_ACTION_RESULT_FAILED_ON_COOLDOWN"
        or name == "GROUP_FINDER_ACTION_RESULT_TIMEOUT"
    then
        return GROUP_FINDER_FAILURE_BACKOFF_SECONDS
    end
    return nil
end

local function GetRemoveGroupListingReasonName(reason)
    if not next(removeGroupListingReasonNameById) then
        BuildRemoveGroupListingReasonNames()
    end
    return removeGroupListingReasonNameById[reason]
end

function ADGM.FormatRemoveGroupListingReason(reason)
    return GetRemoveGroupListingReasonName(reason) or tostring(reason)
end

local function FormatShortRemoveGroupListingReason(reason)
    local name = GetRemoveGroupListingReasonName(reason)
    local shortNames = {
        REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_DISABLED_IN_ZONE = "disabled in this zone",
        REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_LEADER_CHANGED = "leader changed",
        REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_LISTING_FULLFILLED = "listing filled",
        REMOVE_GROUP_LISTING_REASON_REMOVED_BY_LEADER = "removed manually",
        REMOVE_GROUP_LISTING_REASON_REMOVED_BY_QUEUE = "queue started",
        REMOVE_GROUP_LISTING_REASON_REMOVED_BY_SERVER = "server removed it",
    }
    if name and shortNames[name] then
        return shortNames[name]
    end
    local generated = ConstantNameToShortText(name, "REMOVE_GROUP_LISTING_REASON_REMOVED_")
    if generated then
        return generated
    end
    return tostring(reason)
end

local function IsGroupListingFulfilledRemoveReason(reason)
    return GetRemoveGroupListingReasonName(reason) == "REMOVE_GROUP_LISTING_REASON_REMOVED_BECAUSE_LISTING_FULLFILLED"
end

local function IsManualGroupListingRemoveReason(reason)
    return GetRemoveGroupListingReasonName(reason) == "REMOVE_GROUP_LISTING_REASON_REMOVED_BY_LEADER"
end

local function GetShortGroupFinderEventAction(eventCode)
    if eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT then
        return "create"
    elseif eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT then
        return "update"
    elseif eventCode == EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT then
        return "remove"
    elseif eventCode == EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT then
        return "application"
    end
    return "event"
end

local function IsGroupFinderActionSuccess(result)
    return result == GROUP_FINDER_ACTION_RESULT_SUCCESS
end

local function PrintShortGroupFinderEvent(eventCode, result, wasAddonRequest)
    if not wasAddonRequest then
        return
    end

    if GetGroupSize() > 0 and not CanUseLeaderActions() then
        return
    end

    local action = GetShortGroupFinderEventAction(eventCode)
    if action == "remove" then
        if ADGM.state.groupFinderListingSleeping or IsGroupListingFulfilledRemoveReason(result) then
            return
        end
        Debug("Group Finder listing removed: " .. FormatShortRemoveGroupListingReason(result) .. ".")
        return
    end

    if IsGroupFinderActionSuccess(result) then
        if action == "application" then
            Debug("Group Finder application resolved.")
        else
            Chat("Group Finder " .. action .. " succeeded.")
        end
    else
        Chat(COLOR_WARN .. "Group Finder " .. action .. " failed: " .. FormatShortGroupFinderActionResult(result) .. COLOR_RESET)
    end
end

local function IsGroupFinderResultEvent(eventCode)
    return eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT
        or eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT
        or eventCode == EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT
        or eventCode == EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT
end

local function CanAutoAcceptGroupFinderApplications()
    return ADGM.vars
        and ADGM.vars.enabled
        and ADGM.vars.groupFinder
        and ADGM.vars.groupFinder.autoAcceptApplications == true
        and CanUseLeaderActions()
        and DoesGroupFinderUserTypeGroupListingAutoAcceptRequests(GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING) ~= true
end

local function ProcessNextGroupFinderApplicationApproval()
    if ADGM.state.groupFinderApplicationApprovalInFlight then
        return
    end
    if not CanAutoAcceptGroupFinderApplications() then
        return
    end

    while #ADGM.state.groupFinderApplicationApprovalQueue > 0 do
        local approval = table.remove(ADGM.state.groupFinderApplicationApprovalQueue, 1)
        if approval.characterId and IsGroupListingApplicationPendingByCharacterId(approval.characterId) ~= false then
            ADGM.state.groupFinderApplicationApprovalToken = (ADGM.state.groupFinderApplicationApprovalToken or 0) + 1
            local token = ADGM.state.groupFinderApplicationApprovalToken
            approval.token = token
            ADGM.state.groupFinderApplicationApprovalInFlight = approval
            RequestResolveGroupListingApplication(RESOLVE_GROUP_LISTING_APPLICATION_REQUEST_APPROVE, approval.characterId)
            Debug("Sent Group Finder approval for " .. tostring(approval.name or "application") .. ".")
            zo_callLater(function()
                if ADGM.state.groupFinderApplicationApprovalInFlight == approval
                    and ADGM.state.groupFinderApplicationApprovalToken == token
                then
                    Debug("Group Finder approval timed out for " .. tostring(approval.name or "application") .. ".")
                    ADGM.state.groupFinderApplicationApprovalInFlight = nil
                    ProcessNextGroupFinderApplicationApproval()
                end
            end, GROUP_FINDER_APPLICATION_APPROVAL_TIMEOUT_MS)
            return
        end
    end
end

local function HandleGroupFinderApplicationReceived(applicantCharacterId)
    if not CanAutoAcceptGroupFinderApplications() then
        return
    end
    if not applicantCharacterId or IsGroupListingApplicationPendingByCharacterId(applicantCharacterId) == false then
        return
    end

    local approvalKey = tostring(applicantCharacterId)
    local nowMs = GetNowMs()
    local pendingUntilMs = ADGM.state.groupFinderApplicationApprovals[approvalKey]
    if pendingUntilMs and pendingUntilMs > nowMs then
        return
    end
    ADGM.state.groupFinderApplicationApprovals[approvalKey] = nowMs + GROUP_FINDER_APPLICATION_ROLE_TTL_MS
    zo_callLater(function()
        if ADGM.state.groupFinderApplicationApprovals[approvalKey]
            and ADGM.state.groupFinderApplicationApprovals[approvalKey] <= GetNowMs()
        then
            ADGM.state.groupFinderApplicationApprovals[approvalKey] = nil
        end
    end, GROUP_FINDER_APPLICATION_ROLE_TTL_MS)

    local displayName, characterName, _classId, _level, _championPoints, role = GetGroupListingApplicationInfoByCharacterId(applicantCharacterId)
    ADGM.StoreGroupFinderApplicationRole(displayName, characterName, role, applicantCharacterId)

    local applicantName = displayName and displayName ~= "" and displayName or characterName
    ADGM.state.groupFinderApplicationApprovalQueue[#ADGM.state.groupFinderApplicationApprovalQueue + 1] = {
        characterId = applicantCharacterId,
        name = applicantName or "application",
    }
    ProcessNextGroupFinderApplicationApproval()
end

local function HandleGroupFinderApplicationsUpdated()
    if not CanAutoAcceptGroupFinderApplications() then
        return
    end

    local applicantCharacterId = nil
    while true do
        applicantCharacterId = GetNextGroupListingApplicationCharacterId(applicantCharacterId)
        if not applicantCharacterId then
            return
        end
        HandleGroupFinderApplicationReceived(applicantCharacterId)
    end
end

function ADGM.OnGroupFinderEvent(eventCode, ...)
    local firstArg = select(1, ...)
    local isResultEvent = IsGroupFinderResultEvent(eventCode)
    local wasAddonRequest = isResultEvent and ADGM.state.lastGroupFinderRequestByAddon == true

    if GetGroupSize() > 0 and not CanUseLeaderActions() then
        ClearLeaderAutomationState("not group leader")
        if eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT
            or eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT then
            ADGM.state.lastGroupFinderRequestName = nil
            ADGM.state.lastGroupFinderRequestReason = nil
            ADGM.state.lastGroupFinderRequestByAddon = false
        end
        return
    end

    if eventCode == EVENT_GROUP_FINDER_APPLICATION_RECEIVED then
        HandleGroupFinderApplicationReceived(firstArg)
    elseif eventCode == EVENT_GROUP_FINDER_UPDATE_APPLICATIONS then
        HandleGroupFinderApplicationsUpdated()
    end

    if isResultEvent then
        ADGM.state.lastGroupFinderEventCode = eventCode
        ADGM.state.lastGroupFinderResult = firstArg
        ADGM.state.lastGroupFinderResultAt = GetNow()
        if eventCode == EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT then
            if IsManualGroupListingRemoveReason(firstArg) then
                ClearGroupFinderListingRuntimeState("removed manually")
            elseif IsGroupFinderListingRuntimeArmed() then
                if IsGroupListingFulfilledRemoveReason(firstArg)
                    or (ADGM.vars
                        and not GetRemoveGroupListingReasonName(firstArg)
                        and GetGroupSize() >= (ADGM.vars.targetGroupSize or DEFAULTS.targetGroupSize))
                then
                    SetGroupFinderListingSleeping("group full")
                else
                    SetGroupFinderListingSleeping(FormatShortRemoveGroupListingReason(firstArg))
                end
            end
        elseif IsGroupFinderActionSuccess(firstArg) then
            ADGM.state.groupFinderBackoffUntil = 0
            if eventCode == EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT then
                local accepted = ADGM.state.groupFinderApplicationApprovalInFlight
                ADGM.state.groupFinderApplicationApprovalInFlight = nil
                ADGM.state.groupFinderApplicationApprovalToken = (ADGM.state.groupFinderApplicationApprovalToken or 0) + 1
                if accepted then
                    Chat("Accepted " .. tostring(accepted.name) .. " from Group Finder.")
                end
            end
            if eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT
                or eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT then
                SetGroupFinderListingActive(GetShortGroupFinderEventAction(eventCode))
            end
            if eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT
                or eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT then
                local source = eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT and "successful create" or "successful update"
                if wasAddonRequest then
                    Debug("Skipped template auto-save after ADGM " .. source .. ".")
                else
                    zo_callLater(function()
                        AutoSaveGroupFinderListing(source)
                    end, 1000)
                end
            end
        elseif eventCode == EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT then
            local failed = ADGM.state.groupFinderApplicationApprovalInFlight
            ADGM.state.groupFinderApplicationApprovalInFlight = nil
            ADGM.state.groupFinderApplicationApprovalToken = (ADGM.state.groupFinderApplicationApprovalToken or 0) + 1
            if failed then
                Debug("Group Finder approval failed for " .. tostring(failed.name) .. ": " .. ADGM.FormatGroupFinderActionResult(firstArg))
            end
        elseif eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT
            or eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT then
            local now = GetNow()
            local retryDelay = GetGroupFinderRetryDelaySeconds(firstArg)
            ADGM.state.groupFinderListingActive = false
            ADGM.state.groupFinderListingSleeping = false
            ADGM.state.groupFinderListingSleepReason = nil
            if retryDelay then
                ADGM.state.groupFinderBackoffUntil = now + retryDelay
                ADGM.ScheduleGroupFinderRelistRetry(retryDelay + 1, "ESO retry", false)
            else
                ADGM.state.groupFinderBackoffUntil = 0
                CancelGroupFinderRelistRetry()
            end

            if ADGM.vars and ADGM.vars.debug then
                Chat(COLOR_WARN .. "Group Finder create failed: "
                    .. ADGM.FormatGroupFinderActionResult(firstArg)
                    .. (retryDelay and (". Auto-relist retry in " .. tostring(retryDelay) .. " seconds.") or ". No automatic retry.")
                    .. COLOR_RESET, true)
                if not retryDelay then
                    Chat(COLOR_WARN .. "Try creating it manually in Group Finder if ESO's UI allows it." .. COLOR_RESET, true)
                end
            end
        end

        if eventCode == EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT
            or eventCode == EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT then
            ADGM.state.lastGroupFinderRequestName = nil
            ADGM.state.lastGroupFinderRequestReason = nil
            ADGM.state.lastGroupFinderRequestByAddon = false
        end

        if eventCode == EVENT_GROUP_FINDER_RESOLVE_GROUP_LISTING_APPLICATION_RESULT then
            ProcessNextGroupFinderApplicationApproval()
        end
    end

    if ADGM.vars and ADGM.vars.debug and ADGM.vars.groupFinder and ADGM.vars.groupFinder.eventLog and isResultEvent then
        local suffix = ""
        if eventCode == EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT then
            suffix = " reason=" .. ADGM.FormatRemoveGroupListingReason(firstArg)
        else
            suffix = " result=" .. ADGM.FormatGroupFinderActionResult(firstArg)
        end
        Chat("GF event " .. GetGroupFinderEventName(eventCode) .. " (" .. tostring(eventCode) .. "): " .. FormatEventArgs(...) .. suffix, true)
    elseif isResultEvent and ADGM.vars and ADGM.vars.debug ~= true then
        PrintShortGroupFinderEvent(eventCode, firstArg, wasAddonRequest)
    end
end

local function SetGroupFinderEventLog(enabled)
    ADGM.vars.groupFinder.eventLog = enabled
    Chat("Group Finder event log " .. (enabled and "enabled." or "disabled."), true)
end

local function RegisterGroupFinderEvents()
    if ADGM.state.gfEventRegistered then
        return
    end

    for _, eventName in ipairs(GROUP_FINDER_EVENT_NAMES) do
        local eventId = _G[eventName]
        if eventId then
            EVENT_MANAGER:RegisterForEvent(ADGM.name .. eventName, eventId, ADGM.OnGroupFinderEvent)
        end
    end

    ADGM.state.gfEventRegistered = true
end

local function RefreshGroupFinderListingRuntimeState()
    if not ADGM.vars or not ADGM.vars.groupFinder or GetGroupSize() == 0 or not CanUseLeaderActions() then
        return
    end

    if HasGroupListingForUserType(GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING) then
        SetGroupFinderListingActive("existing listing")
        Debug("Detected active Group Finder listing.")
    end
end


-- Export locals used by later manifest files.
ADGM.CaptureCurrentGroupFinderListing = CaptureCurrentGroupFinderListing
ADGM.PrintSavedGroupFinderListing = PrintSavedGroupFinderListing
ADGM.ApplyCurrentGroupFinderTemplateToNativeDraft = ApplyCurrentGroupFinderTemplateToNativeDraft
ADGM.SetGroupFinderRelistMode = SetGroupFinderRelistMode
ADGM.RelistSavedGroupFinderListing = RelistSavedGroupFinderListing
ADGM.SetGroupFinderEventLog = SetGroupFinderEventLog
ADGM.RegisterGroupFinderEvents = RegisterGroupFinderEvents
ADGM.RefreshGroupFinderListingRuntimeState = RefreshGroupFinderListingRuntimeState
ADGM.WarnRoleGuardAutoAcceptConflict = WarnRoleGuardAutoAcceptConflict
