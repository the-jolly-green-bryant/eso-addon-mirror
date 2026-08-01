local Addon = LarvalTearMod
local ProfileFacade = Addon.UI.QuickSettings.ProfileFacade
local FoodHelper = Addon.Modules.FoodHelper
local QuickslotApply = Addon.Modules.QuickslotApply
local QuickslotFetch = Addon.Modules.QuickslotFetch
local QuickslotProfiles = Addon.Modules.QuickslotProfiles
local QuickslotSnapshot = Addon.Modules.QuickslotSnapshot

local QUICK_SLOT_DISPLAY_SLOT_COUNT = 8
local QUICK_SLOT_FETCH_MODE_MISSING = "missing"
local QUICK_SLOT_FETCH_MODE_REFILL_MAX = "refill_max"

function ProfileFacade:NormalizeFetchMode(mode)
    if mode == QUICK_SLOT_FETCH_MODE_REFILL_MAX then
        return QUICK_SLOT_FETCH_MODE_REFILL_MAX
    end

    return QUICK_SLOT_FETCH_MODE_MISSING
end

local function GetEntryDisplayCount(entry)
    local count = tonumber(entry.currentCount)
    if count == nil then
        count = tonumber(entry.savedCount)
    end
    if count == nil then
        count = 0
    end

    return tostring(count)
end

local function BuildDisplaySlot(entry)
    local slotView = {
        kind = "unsupported",
        icon = type(entry) == "table" and entry.icon or nil,
        itemLink = nil,
        displayCount = "",
        isMissing = false,
    }

    if type(QuickslotSnapshot) ~= "table" then
        return slotView
    end

    if type(QuickslotSnapshot.IsItemEntry) == "function" and QuickslotSnapshot:IsItemEntry(entry) then
        slotView.kind = "item"
        slotView.itemLink = type(entry) == "table" and entry.itemLink or nil
        slotView.displayCount = GetEntryDisplayCount(entry)
        slotView.isMissing = type(entry) == "table" and entry.missing == true
    elseif type(QuickslotSnapshot.IsSimpleActionEntry) == "function" and QuickslotSnapshot:IsSimpleActionEntry(entry) then
        slotView.kind = "simple_action"
    elseif type(QuickslotSnapshot.IsEmptyEntry) == "function" and QuickslotSnapshot:IsEmptyEntry(entry) then
        slotView.kind = "empty"
    end

    return slotView
end

local function GetMissingItemLabel(entry)
    if type(entry) ~= "table" then
        return ""
    end

    return type(entry.name) == "string" and entry.name ~= "" and entry.name
        or type(entry.itemLink) == "string" and entry.itemLink ~= "" and entry.itemLink
        or tostring(entry.itemId or entry.slotIndex)
end

local function BuildMissingItemsText(items)
    local lines = {}
    for _, item in ipairs(items or {}) do
        lines[#lines + 1] = item.text
    end
    return table.concat(lines, "\n")
end

function ProfileFacade:CreateFromCurrent(name)
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.CreateFromCurrent) ~= "function" then
        return nil, "quickslot_profiles_unavailable"
    end

    return QuickslotProfiles:CreateFromCurrent(name)
end

function ProfileFacade:DeleteProfile(profileId)
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.DeleteProfile) ~= "function" then
        return nil, "quickslot_profiles_unavailable"
    end

    return QuickslotProfiles:DeleteProfile(profileId)
end

function ProfileFacade:RenameProfile(profileId, newName)
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.RenameProfile) ~= "function" then
        return nil, "quickslot_profiles_unavailable"
    end

    return QuickslotProfiles:RenameProfile(profileId, newName)
end

function ProfileFacade:GetProfileList()
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.GetProfileList) ~= "function" then
        return {}
    end

    return QuickslotProfiles:GetProfileList()
end

function ProfileFacade:GetQuickSlotLinkOptions()
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.GetProfileLinkOptions) ~= "function" then
        return {}
    end

    return QuickslotProfiles:GetProfileLinkOptions()
end

function ProfileFacade:GetQuickSlotProfileDisplayName(profileId)
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.GetProfileDisplayNameById) ~= "function" then
        return nil
    end

    return QuickslotProfiles:GetProfileDisplayNameById(profileId)
end

function ProfileFacade:HasQuickSlotProfile(profileId)
    return type(QuickslotProfiles) == "table"
        and type(QuickslotProfiles.HasProfile) == "function"
        and QuickslotProfiles:HasProfile(profileId) == true
end

function ProfileFacade:SetActiveProfile(profileId)
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.SetActiveProfile) ~= "function" then
        return nil, "quickslot_profiles_unavailable"
    end

    return QuickslotProfiles:SetActiveProfile(profileId)
end

function ProfileFacade:ClearActiveProfile(profileId)
    if type(QuickslotProfiles) ~= "table" or type(QuickslotProfiles.ClearActiveProfile) ~= "function" then
        return false, "quickslot_profiles_unavailable"
    end

    return QuickslotProfiles:ClearActiveProfile(profileId)
end

function ProfileFacade:GetProfileApplyState(profile)
    local state = {
        canCompare = false,
        needsApply = true,
    }

    if type(QuickslotSnapshot) ~= "table"
        or type(QuickslotSnapshot.CaptureCurrent) ~= "function"
        or type(QuickslotSnapshot.ResolveProfile) ~= "function"
        or type(QuickslotSnapshot.CompareCurrentToProfile) ~= "function" then
        state.reason = "quickslot_snapshot_unavailable"
        return state
    end

    local currentSnapshot, snapshotErr = QuickslotSnapshot:CaptureCurrent()
    if type(currentSnapshot) ~= "table" then
        state.reason = snapshotErr or "quickslot_snapshot_failed"
        return state
    end

    local resolvedSlots = QuickslotSnapshot:ResolveProfile(profile)
    local compare = QuickslotSnapshot:CompareCurrentToProfile(profile, currentSnapshot, resolvedSlots)
    state.canCompare = true
    state.compare = compare
    state.needsApply = type(compare) ~= "table" or (tonumber(compare.mismatched) or 0) > 0
    return state
end

function ProfileFacade:BuildProfileListRefreshContext()
    if type(QuickslotSnapshot) ~= "table" or type(QuickslotSnapshot.BuildInventoryIndex) ~= "function" then
        return {}
    end

    return {
        inventoryIndex = QuickslotSnapshot:BuildInventoryIndex(),
    }
end

function ProfileFacade:BuildProfileDisplayModel(profile, refreshContext)
    local model = {
        slots = {},
        missingCount = 0,
    }

    if type(QuickslotSnapshot) ~= "table" or type(QuickslotSnapshot.ResolveProfile) ~= "function" then
        return model
    end

    local inventoryIndex = type(refreshContext) == "table" and refreshContext.inventoryIndex or nil
    local resolvedSlots = QuickslotSnapshot:ResolveProfile(profile, inventoryIndex) or {}
    for slotIndex = 1, QUICK_SLOT_DISPLAY_SLOT_COUNT do
        local slotView = BuildDisplaySlot(resolvedSlots[slotIndex])
        model.slots[slotIndex] = slotView
        if slotView.isMissing == true then
            model.missingCount = model.missingCount + 1
        end
    end

    return model
end

function ProfileFacade:BuildMissingConfirmModel(profile)
    local model = {
        hasMissing = false,
        missingCount = 0,
        items = {},
        itemsText = "",
    }

    if type(QuickslotSnapshot) ~= "table" or type(QuickslotSnapshot.GetMissingItems) ~= "function" then
        return model
    end

    local missingItems = QuickslotSnapshot:GetMissingItems(profile) or {}
    for _, entry in ipairs(missingItems) do
        local item = {
            text = GetMissingItemLabel(entry),
        }
        model.items[#model.items + 1] = item
    end

    model.missingCount = #model.items
    model.hasMissing = model.missingCount > 0
    model.itemsText = BuildMissingItemsText(model.items)
    return model
end

function ProfileFacade:BeginProfileApply(profile, callback)
    if type(QuickslotApply) ~= "table" or type(QuickslotApply.ApplyProfile) ~= "function" then
        return nil, "quickslot_apply_unavailable"
    end

    return QuickslotApply:ApplyProfile(profile, callback)
end

function ProfileFacade:GetFetchPreferLowCondition()
    return type(Addon) == "table"
        and type(Addon.savedVars) == "table"
        and Addon.savedVars.quickslotFetchPreferLowCondition == true
end

function ProfileFacade:SetFetchPreferLowCondition(enabled)
    if type(Addon) ~= "table" or type(Addon.savedVars) ~= "table" then
        return
    end

    Addon.savedVars.quickslotFetchPreferLowCondition = enabled == true
end

function ProfileFacade:GetFetchMode()
    return self:NormalizeFetchMode(type(Addon) == "table"
        and type(Addon.savedVars) == "table"
        and Addon.savedVars.quickslotFetchMode
        or nil)
end

function ProfileFacade:SetFetchMode(mode)
    if type(Addon) ~= "table" or type(Addon.savedVars) ~= "table" then
        return
    end

    Addon.savedVars.quickslotFetchMode = self:NormalizeFetchMode(mode)
end

function ProfileFacade:BeginProfileFetch(profile, options, callback)
    if type(QuickslotFetch) ~= "table" or type(QuickslotFetch.BeginFetch) ~= "function" then
        return false, "quickslot_fetch_unavailable", nil
    end

    options = type(options) == "table" and options or {}
    return QuickslotFetch:BeginFetch(profile, {
        mode = self:NormalizeFetchMode(options.mode),
        preferLowCondition = options.preferLowCondition == true,
    }, callback)
end

function ProfileFacade:GetFetchAvailability(mode, missingCount)
    local normalizedMode = self:NormalizeFetchMode(mode)
    local busy = type(QuickslotFetch) == "table"
        and type(QuickslotFetch.IsBusy) == "function"
        and QuickslotFetch:IsBusy() == true
    local contextAvailable = type(QuickslotFetch) == "table"
        and type(QuickslotFetch.IsFetchContextAvailable) == "function"
        and QuickslotFetch:IsFetchContextAvailable() == true
    local hasMissing = (tonumber(missingCount) or 0) > 0

    return {
        mode = normalizedMode,
        busy = busy,
        contextAvailable = contextAvailable,
        hasMissing = hasMissing,
        enabled = contextAvailable and not busy and (normalizedMode == QUICK_SLOT_FETCH_MODE_REFILL_MAX or hasMissing),
    }
end

function ProfileFacade:GetFoodAutoEatEnabled()
    return type(FoodHelper) == "table"
        and type(FoodHelper.GetAutoEatEnabled) == "function"
        and FoodHelper:GetAutoEatEnabled() == true
end

function ProfileFacade:SetFoodAutoEatEnabled(enabled)
    if type(FoodHelper) ~= "table" or type(FoodHelper.SetAutoEatEnabled) ~= "function" then
        return false
    end

    return FoodHelper:SetAutoEatEnabled(enabled == true)
end

function ProfileFacade:GetFoodCardList()
    if type(FoodHelper) ~= "table" or type(FoodHelper.GetCardList) ~= "function" then
        return {}
    end

    return FoodHelper:GetCardList()
end

function ProfileFacade:GetFoodLinkOptions()
    if type(FoodHelper) ~= "table" or type(FoodHelper.GetCardLinkOptions) ~= "function" then
        return {}
    end

    return FoodHelper:GetCardLinkOptions()
end

function ProfileFacade:GetFoodCardDisplayName(cardId)
    if type(FoodHelper) ~= "table" or type(FoodHelper.GetCardDisplayNameById) ~= "function" then
        return nil
    end

    return FoodHelper:GetCardDisplayNameById(cardId)
end

function ProfileFacade:HasFoodCard(cardId)
    return type(FoodHelper) == "table"
        and type(FoodHelper.HasCard) == "function"
        and FoodHelper:HasCard(cardId) == true
end

function ProfileFacade:SetActiveFoodCard(cardId)
    if type(FoodHelper) ~= "table" or type(FoodHelper.SetActiveCard) ~= "function" then
        return nil, "food_helper_unavailable"
    end

    return FoodHelper:SetActiveCard(cardId)
end

function ProfileFacade:DeleteFoodCard(cardId)
    if type(FoodHelper) ~= "table" or type(FoodHelper.DeleteCard) ~= "function" then
        return false, "food_helper_unavailable"
    end

    return FoodHelper:DeleteCard(cardId)
end

function ProfileFacade:CreateFoodCardFromBagSlot(bagId, slotIndex)
    if type(FoodHelper) ~= "table" or type(FoodHelper.CreateOrReplaceFromBagSlot) ~= "function" then
        return nil, "food_helper_unavailable"
    end

    return FoodHelper:CreateOrReplaceFromBagSlot(bagId, slotIndex, nil)
end

function ProfileFacade:ReplaceFoodCardFromBagSlot(cardId, bagId, slotIndex)
    if type(FoodHelper) ~= "table" or type(FoodHelper.CreateOrReplaceFromBagSlot) ~= "function" then
        return nil, "food_helper_unavailable"
    end

    return FoodHelper:CreateOrReplaceFromBagSlot(bagId, slotIndex, cardId)
end

function ProfileFacade:RegisterCurrentActiveFood()
    if type(FoodHelper) ~= "table" or type(FoodHelper.RegisterCurrentActiveFood) ~= "function" then
        return nil, "food_helper_unavailable"
    end

    return FoodHelper:RegisterCurrentActiveFood()
end
