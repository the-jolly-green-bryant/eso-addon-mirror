-- ESO Adventurer Suite
-- v0.29.638 - allocation-free live effective ability synchronization.
-- Temporary/proc replacements still update on the Dual Action Bar, but the
-- active-bar hot path no longer builds concatenated name/texture signature
-- strings every dynamic tick. Normal weapon swaps never perform a synchronous
-- static bar rebuild; any real effective-ability mutation is coalesced/deferred.

local EPC = ESOProgressionCoach
if not EPC then return end

local D = EPC.DualActionBar
local A = EPC.AbilityOverlays
local EM = EVENT_MANAGER
local EVENT_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_LiveAbilityState029638"
local OLD_EVENT_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_LiveAbilityState029518"

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a, b, c, d
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return tonumber(safe(GetFrameTimeMilliseconds, 0)) or 0
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return tonumber(safe(GetGameTimeMilliseconds, 0)) or 0
    end
    return 0
end

local function getEffectiveId(slot, category, boundId)
    boundId = tonumber(boundId) or 0
    if boundId <= 0 then return 0 end
    if type(GetEffectiveAbilityIdForAbilityOnHotbar) == "function" then
        return tonumber(safe(GetEffectiveAbilityIdForAbilityOnHotbar, boundId, boundId, category)) or boundId
    end
    return boundId
end

local function getSlots()
    if D and type(D.slots) == "table" and #D.slots > 0 then return D.slots end
    if A and type(A.GetSlots) == "function" then
        local ok, slots = pcall(A.GetSlots, A)
        if ok and type(slots) == "table" then return slots end
    end
    local firstBase = tonumber(ACTION_BAR_FIRST_NORMAL_SLOT_INDEX)
    local ultBase = tonumber(ACTION_BAR_ULTIMATE_SLOT_INDEX)
    local first = firstBase and (firstBase + 1) or 3
    local ult = ultBase and (ultBase + 1) or (first + 5)
    local slots = {}
    for i = 0, 4 do slots[#slots + 1] = first + i end
    slots[#slots + 1] = ult
    return slots
end

local function normalCategories()
    local primary = rawget(_G, "HOTBAR_CATEGORY_PRIMARY")
    local backup = rawget(_G, "HOTBAR_CATEGORY_BACKUP")
    if primary == nil then primary = 0 end
    if backup == nil then backup = 1 end
    return primary, backup
end

local function isNormalCategory(category)
    local primary, backup = normalCategories()
    return category == primary or category == backup
end

local function swapCooling()
    local stamp = nowMs()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029635)
        or 0
    return stamp > 0 and stamp < untilMs
end

-- Numeric state cache ---------------------------------------------------------
-- Only ids + used-state determine whether the live slot model is structurally
-- different. Name/texture strings are presentation derived from those ids and
-- are refreshed only after a real mutation is detected. This removes repeated
-- string concatenation/table allocations from the combat timer.
local function scanCategoryState(self, category)
    if not self or category == nil then return false, false end
    self.liveAbilityState029638 = self.liveAbilityState029638 or {}
    local categoryCache = self.liveAbilityState029638[category]
    local firstScan = categoryCache == nil
    if firstScan then
        categoryCache = {}
        self.liveAbilityState029638[category] = categoryCache
    end

    local changed = false
    for _, slot in ipairs(getSlots()) do
        local boundId = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
        local effectiveId = getEffectiveId(slot, category, boundId)
        local used = safe(IsSlotUsed, false, slot, category) == true
        local state = categoryCache[slot]
        if not state then
            categoryCache[slot] = { bound = boundId, effective = effectiveId, used = used }
            if not firstScan then changed = true end
        else
            if state.bound ~= boundId or state.effective ~= effectiveId or state.used ~= used then
                state.bound = boundId
                state.effective = effectiveId
                state.used = used
                changed = true
            end
        end
    end
    return changed, firstScan
end

local function primeNormalState(self)
    if not self then return end
    local primary, backup = normalCategories()
    scanCategoryState(self, primary)
    scanCategoryState(self, backup)
end

local function scheduleStaticRefresh(self, delayMs)
    if not EM or not self then return end
    local key = EVENT_PREFIX .. "_Static"
    EM:UnregisterForUpdate(key)
    EM:RegisterForUpdate(key, math.max(40, tonumber(delayMs) or 80), function()
        EM:UnregisterForUpdate(key)
        if not D then return end
        -- If this refresh was queued during a normal weapon transition, keep it
        -- away from ESO's swap frame. A later mutation/event will queue it again.
        if swapCooling() then
            scheduleStaticRefresh(D, 180)
            return
        end
        if type(D.InvalidateStyleCache029189) == "function" then
            D:InvalidateStyleCache029189()
        end
        if type(D.RefreshStatic029311) == "function" then
            D:RefreshStatic029311()
        end
        if type(D.CaptureStaticSlotSignatures029561) == "function" then
            D:CaptureStaticSlotSignatures029561()
        end
    end)
end

-- Make the Dual Action Bar's cached static model represent ESO's effective live
-- ability, not only the originally slotted base ability.
if D and type(D.GetLightAbilityData029311) == "function" and not D._easLiveAbilityDataWrapped029518 then
    D._easLiveAbilityDataWrapped029518 = true
    local baseGetLightAbilityData = D.GetLightAbilityData029311

    function D:GetLightAbilityData029311(category)
        local data = baseGetLightAbilityData(self, category)
        for _, ability in ipairs(data or {}) do
            local slot = tonumber(ability.slot)
            if slot then
                local baseId = tonumber(ability.abilityId) or tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
                local effectiveId = getEffectiveId(slot, category, baseId)
                ability.baseAbilityId029518 = baseId
                ability.effectiveAbilityId029311 = effectiveId

                if effectiveId > 0 and effectiveId ~= baseId then
                    ability.abilityId = effectiveId
                    local liveIcon = tostring(safe(GetSlotTexture, "", slot, category) or "")
                    if liveIcon == "" and type(GetAbilityIcon) == "function" then
                        liveIcon = tostring(safe(GetAbilityIcon, "", effectiveId) or "")
                    end
                    if liveIcon ~= "" then ability.icon = liveIcon end

                    local liveName = tostring(safe(GetSlotName, "", slot, category) or "")
                    if liveName == "" and type(GetAbilityName) == "function" then
                        liveName = tostring(safe(GetAbilityName, "", effectiveId) or "")
                    end
                    if liveName ~= "" then ability.name = liveName end
                    ability.isTemporaryEffective029518 = true
                end
            end
        end
        return data
    end
end

-- Scan the active bar using the numeric cache on the existing controlled timer.
-- Crucially: detecting a real mutation never calls RefreshStatic synchronously.
if D and type(D.RefreshDynamic029311) == "function" and not D._easLiveSignatureWrapped029638 then
    D._easLiveSignatureWrapped029638 = true
    local baseRefreshDynamic = D.RefreshDynamic029311

    function D:RefreshDynamic029311(force, ...)
        local category = safe(GetActiveHotbarCategory, nil)
        if category ~= nil then
            local previousCategory = self._easLiveActiveCategory029638
            local categoryChanged = previousCategory ~= nil and previousCategory ~= category
            self._easLiveActiveCategory029638 = category

            local changed, firstScan = scanCategoryState(self, category)
            if changed and not firstScan then
                -- Normal bar swaps get the longest defer; proc/mode changes while
                -- staying on the same bar remain responsive without blocking the
                -- combat frame that delivered the state change.
                local delay = (categoryChanged or swapCooling()) and 260 or 70
                scheduleStaticRefresh(self, delay)
            elseif firstScan and not isNormalCategory(category) then
                scheduleStaticRefresh(self, 120)
            end
        end
        return baseRefreshDynamic(self, force, ...)
    end
end

-- Remove obsolete live-state listeners from previous development builds.
if EM then
    local oldEvents = {
        rawget(_G, "EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED"),
        rawget(_G, "EVENT_ACTION_SLOT_UPDATED"),
        rawget(_G, "EVENT_ACTIVE_WEAPON_PAIR_CHANGED"),
        rawget(_G, "EVENT_PLAYER_ACTIVATED"),
    }
    local seen = {}
    for index, eventCode in ipairs(oldEvents) do
        if eventCode ~= nil and not seen[eventCode] then
            seen[eventCode] = true
            EM:UnregisterForEvent(OLD_EVENT_PREFIX .. "_" .. tostring(index), eventCode)
        end
    end
end

-- Prime both normal bars once so switching Primary/Backup never looks like a
-- previously unseen category. No recurring listener is added here.
if EM and rawget(_G, "EVENT_PLAYER_ACTIVATED") then
    local activationName = EVENT_PREFIX .. "_Prime"
    EM:UnregisterForEvent(activationName, EVENT_PLAYER_ACTIVATED)
    EM:RegisterForEvent(activationName, EVENT_PLAYER_ACTIVATED, function()
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                if D then primeNormalState(D) end
            end, 250)
        elseif D then
            primeNormalState(D)
        end
    end)
end

if D then primeNormalState(D) end
