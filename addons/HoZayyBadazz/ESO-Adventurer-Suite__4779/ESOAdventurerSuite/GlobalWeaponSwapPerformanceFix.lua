-- ESO Adventurer Suite
-- v0.29.646 - authoritative zero-heavy-work weapon-swap owner.
-- Normal Primary <-> Backup swaps only flip the already-rendered row alpha after
-- ESO settles. Core-wide refresh/snapshot work, ability models, slot signatures,
-- marker re-anchoring, and static bar rebuilds are excluded from the swap path.
-- Special/transformed hotbars retain one deferred structural refresh.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end

local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_WeaponSwapOwner029636"
local BASE_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_DualActionBar029189"
local TRANSFORM_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_TransformBar029554"
local SWAP_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_DualBarSwapPerf029567"
local OLD_GLOBAL_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_GlobalSwapPerf029568"
local OLD_OWNER_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_WeaponSwapOwner029635"
local ABILITY_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_AbilityOverlays"
local READY_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_ReadyAlerts029365"
local ROTATION_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_RotationAssistant"
local CAST_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_DualBarCastPerf029561"

local SETTLE_MS = 260
-- ESO can continue emitting slot/effect/hotbar notifications well after the pair
-- event itself. Keep every heavy Suite action-bar system out until the transition
-- is fully over; active-row alpha still changes immediately.
local BROAD_SUPPRESS_MS = 1200
local APPLY_DELAY_MS = 40
local STRUCTURAL_DELAY_MS = 140
local SLOT_COALESCE_MS = 110
local BROAD_REFRESH_DELAY_MS = 180

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return tonumber(GetFrameTimeMilliseconds()) or 0
    end
    if type(GetGameTimeMilliseconds) == "function" then
        return tonumber(GetGameTimeMilliseconds()) or 0
    end
    return 0
end

local function activeCategory()
    if type(GetActiveHotbarCategory) ~= "function" then return nil end
    local ok, value = pcall(GetActiveHotbarCategory)
    return ok and value or nil
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

local function swapSettling()
    local untilMs = tonumber(EPC.weaponSwapSettlingUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029635) or 0
    local stamp = nowMs()
    return stamp > 0 and stamp < untilMs
end

local function broadRefreshSuppressed()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636) or 0
    local stamp = nowMs()
    return stamp > 0 and stamp < untilMs
end

local function coreRegistration(eventCode)
    if eventCode == nil then return nil end
    return (EPC.name or "ESOAdventurerSuite") .. "_" .. tostring(eventCode)
end

local function removeEventNames(eventCode, names)
    if eventCode == nil then return end
    for i = 1, #names do
        EM:UnregisterForEvent(names[i], eventCode)
    end
end

local function removeLegacyListeners()
    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED ~= nil then
        local coreName = coreRegistration(EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
        local names = {
            BASE_PREFIX .. "_Bar",
            TRANSFORM_PREFIX .. "_Pair",
            SWAP_PREFIX .. "_Pair",
            OLD_GLOBAL_PREFIX .. "_Weapon",
            OLD_OWNER_PREFIX .. "_Pair",
            ABILITY_PREFIX .. "_Weapon",
            READY_PREFIX .. "_Weapon",
            ROTATION_PREFIX .. "_Bar",
        }
        if coreName then names[#names + 1] = coreName end
        removeEventNames(EVENT_ACTIVE_WEAPON_PAIR_CHANGED, names)
    end

    if EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED ~= nil then
        removeEventNames(EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, {
            TRANSFORM_PREFIX .. "_Hotbar",
            SWAP_PREFIX .. "_Hotbar",
            OLD_GLOBAL_PREFIX .. "_Hotbar",
            OLD_OWNER_PREFIX .. "_Hotbar",
            ABILITY_PREFIX .. "_Bar",
            READY_PREFIX .. "_Bar",
        })
    end

    if EVENT_ACTION_SLOT_UPDATED ~= nil then
        removeEventNames(EVENT_ACTION_SLOT_UPDATED, {
            BASE_PREFIX .. "_Slot",
            TRANSFORM_PREFIX .. "_Slot",
            CAST_PREFIX .. "_Slot",
            OLD_OWNER_PREFIX .. "_Slot",
            ABILITY_PREFIX .. "_Slot",
            ROTATION_PREFIX .. "_Slot",
        })
    end

    if EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED ~= nil then
        local coreName = coreRegistration(EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
        if coreName then EM:UnregisterForEvent(coreName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED) end
        EM:UnregisterForEvent(OLD_OWNER_PREFIX .. "_AllHotbars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    end

    EM:UnregisterForUpdate(OLD_GLOBAL_PREFIX .. "_Ability")
    EM:UnregisterForUpdate(TRANSFORM_PREFIX .. "_Deferred")
    EM:UnregisterForUpdate(OLD_OWNER_PREFIX .. "_Apply")
    EM:UnregisterForUpdate(OLD_OWNER_PREFIX .. "_Structural")
    EM:UnregisterForUpdate(OLD_OWNER_PREFIX .. "_SlotCheck")
end

local function clamp(value, low, high)
    value = tonumber(value) or low
    if value < low then return low end
    if value > high then return high end
    return value
end

local function applyNormalSwapVisuals(category)
    local D = EPC.DualActionBar
    if not D or not D.rows or category == nil then return end

    D.lastActiveCategory029311 = category
    D._lastSeenHotbar029554 = category
    D._lastLightSwapCategory029567 = category
    D._easLiveActiveCategory029638 = category

    local inactiveAlpha = clamp(
        ((tonumber(EPC.saved and EPC.saved.dualActionBarInactiveAlpha029189) or 45) / 100),
        0.10, 1.0)

    for _, row in ipairs(D.rows) do
        if row and type(row.SetAlpha) == "function" then
            row:SetAlpha(row.epcCategory == category and 1.0 or inactiveAlpha)
        end
    end
end

local function scheduleStructuralRefresh()
    EM:UnregisterForUpdate(NAME .. "_Structural")
    EM:RegisterForUpdate(NAME .. "_Structural", STRUCTURAL_DELAY_MS, function()
        EM:UnregisterForUpdate(NAME .. "_Structural")
        local D = EPC.DualActionBar
        if not D then return end

        if type(D.ApplyTransformedHotbarLayout029554) == "function" then
            pcall(D.ApplyTransformedHotbarLayout029554, D, true)
        end
        if type(D.InvalidateStyleCache029189) == "function" then
            pcall(D.InvalidateStyleCache029189, D)
        end
        if type(D.RefreshStatic029311) == "function" then
            pcall(D.RefreshStatic029311, D, true)
        end
        if type(D.CaptureStaticSlotSignatures029561) == "function" then
            pcall(D.CaptureStaticSlotSignatures029561, D)
        end

        local category = activeCategory()
        D.lastActiveCategory029311 = category
        D._lastSeenHotbar029554 = category
        D._lastLightSwapCategory029567 = category
        D._easLiveActiveCategory029638 = category

        if type(D.RefreshDynamic029311) == "function" then
            pcall(D.RefreshDynamic029311, D, true)
        end
    end)
end

local function processStableSwap()
    local D = EPC.DualActionBar
    if not D then return end

    local category = activeCategory()
    if category == nil then return end

    local wasTransformed = D._transformed029554 == true
    local transformed = not isNormalCategory(category)
    if type(D.IsSingleTransformedHotbar029554) == "function" then
        local ok, value = pcall(D.IsSingleTransformedHotbar029554, D, category)
        if ok then transformed = value == true end
    end

    if isNormalCategory(category) and not transformed and not wasTransformed then
        applyNormalSwapVisuals(category)
        return
    end

    scheduleStructuralRefresh()
end

local function onSwapNotification()
    local stamp = nowMs()
    EPC.weaponSwapSettlingUntil029636 = stamp + SETTLE_MS
    EPC.weaponSwapSettlingUntil029635 = EPC.weaponSwapSettlingUntil029636
    EPC.weaponSwapBroadRefreshUntil029636 = stamp + BROAD_SUPPRESS_MS

    EM:UnregisterForUpdate(NAME .. "_BroadRefresh")
    EM:UnregisterForUpdate(NAME .. "_SlotCheck")

    -- Kill pending bar-local work that may have been queued just before the
    -- swap event. Those callbacks otherwise execute inside ESO's transition.
    EM:UnregisterForUpdate(CAST_PREFIX .. "_Static")
    EM:UnregisterForUpdate((EPC.name or "ESOAdventurerSuite") .. "_LiveAbilityState029638_Static")
    EM:UnregisterForUpdate(BASE_PREFIX .. "_DynamicRefresh")

    local D = EPC.DualActionBar
    if D then
        D.pendingDynamicRefresh029386 = false
        D.pendingDynamicRefreshForce029386 = false
    end

    EM:UnregisterForUpdate(NAME .. "_Apply")
    EM:RegisterForUpdate(NAME .. "_Apply", APPLY_DELAY_MS, function()
        EM:UnregisterForUpdate(NAME .. "_Apply")
        processStableSwap()
    end)
end

local function onSlotNotification()
    -- Use the full 1.2s suppression window, not only the short pair-settle time.
    if broadRefreshSuppressed() or swapSettling() then return end

    EM:UnregisterForUpdate(NAME .. "_SlotCheck")
    EM:RegisterForUpdate(NAME .. "_SlotCheck", SLOT_COALESCE_MS, function()
        EM:UnregisterForUpdate(NAME .. "_SlotCheck")
        if broadRefreshSuppressed() or swapSettling() then return end

        local D = EPC.DualActionBar
        if not D then return end
        local changed = false
        if type(D.DidStaticSlotDataChange029561) == "function" then
            local ok, value = pcall(D.DidStaticSlotDataChange029561, D)
            changed = ok and value == true
        end

        if changed then
            if type(D.ScheduleStaticRefresh029561) == "function" then
                pcall(D.ScheduleStaticRefresh029561, D)
            elseif type(D.RefreshStatic029311) == "function" then
                pcall(D.RefreshStatic029311, D, true)
            end
        end
    end)
end

local function onAllHotbarsUpdated()
    if broadRefreshSuppressed() or swapSettling() then return end

    EM:UnregisterForUpdate(NAME .. "_BroadRefresh")
    EM:RegisterForUpdate(NAME .. "_BroadRefresh", BROAD_REFRESH_DELAY_MS, function()
        EM:UnregisterForUpdate(NAME .. "_BroadRefresh")
        if broadRefreshSuppressed() or swapSettling() then return end
        if type(EPC.RequestRefresh) == "function" then
            EPC:RequestRefresh("hotbars-updated")
        end
    end)
end

local function installSettlingGuards()
    local D = EPC.DualActionBar
    if D and type(D.RefreshDynamic029311) == "function"
        and not D._easSwapSettlingGuard029635 then
        D._easSwapSettlingGuard029635 = true
        local baseDynamic = D.RefreshDynamic029311
        D.RefreshDynamic029311 = function(self, force, ...)
            if self.layoutMode ~= true and broadRefreshSuppressed() then return nil end
            return baseDynamic(self, force, ...)
        end
    end

    local A = EPC.AbilityOverlays
    if A and type(A.Refresh) == "function" and not A._easSwapSettlingGuard029635 then
        A._easSwapSettlingGuard029635 = true
        local baseRefresh = A.Refresh
        A.Refresh = function(self, ...)
            if self.layoutMode ~= true and broadRefreshSuppressed() then return nil end
            return baseRefresh(self, ...)
        end
    end

    local R = EPC.RotationAssistant
    if R and type(R.Refresh) == "function" and not R._easSwapSettlingGuard029635 then
        R._easSwapSettlingGuard029635 = true
        local baseRefresh = R.Refresh
        R.Refresh = function(self, ...)
            if self.layoutMode ~= true and broadRefreshSuppressed() then return nil end
            return baseRefresh(self, ...)
        end
    end
end

local function installOwnership()
    removeLegacyListeners()
    installSettlingGuards()

    if EVENT_ACTIVE_WEAPON_PAIR_CHANGED ~= nil then
        EM:UnregisterForEvent(NAME .. "_Pair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
        EM:RegisterForEvent(NAME .. "_Pair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, onSwapNotification)
    end
    if EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED ~= nil then
        EM:UnregisterForEvent(NAME .. "_Hotbar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
        EM:RegisterForEvent(NAME .. "_Hotbar", EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, onSwapNotification)
    end
    if EVENT_ACTION_SLOT_UPDATED ~= nil then
        EM:UnregisterForEvent(NAME .. "_Slot", EVENT_ACTION_SLOT_UPDATED)
        EM:RegisterForEvent(NAME .. "_Slot", EVENT_ACTION_SLOT_UPDATED, onSlotNotification)
    end
    if EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED ~= nil then
        EM:UnregisterForEvent(NAME .. "_AllHotbars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
        EM:RegisterForEvent(NAME .. "_AllHotbars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, onAllHotbarsUpdated)
    end

    EPC.weaponSwapOwner029635 = true
    EPC.weaponSwapOwner029636 = true
end

if EVENT_PLAYER_ACTIVATED ~= nil then
    EM:RegisterForEvent(NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        installOwnership()
        if type(zo_callLater) == "function" then
            zo_callLater(installOwnership, 250)
            zo_callLater(installOwnership, 900)
        end
    end)
end

if EPC.DualActionBar and EPC.DualActionBar.window then
    installOwnership()
end

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easswapperf"] = function()
    local category = activeCategory()
    local state = EPC.weaponSwapOwner029636 == true and "OWNED" or "WAITING"
    local text = string.format(
        "ESO Adventurer Suite weapon swap: %s | category=%s | settling=%s | broad=%s",
        state, tostring(category), swapSettling() and "yes" or "no",
        broadRefreshSuppressed() and "blocked" or "clear")
    if type(d) == "function" then d(text) end
end
