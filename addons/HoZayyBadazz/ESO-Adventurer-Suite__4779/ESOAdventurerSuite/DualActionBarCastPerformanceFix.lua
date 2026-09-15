-- ESO Adventurer Suite
-- v0.29.646 - Dual Action Bar cast-time performance fix + swap-local hard guard.
-- EVENT_ACTION_SLOT_UPDATED can fire during ordinary ability use and in bursts
-- during weapon swaps. Static slot signatures are only scanned when no normal
-- weapon swap is settling, so this file remains safe even if another owner later
-- reinstalls its event handler.

local EPC = ESOProgressionCoach
if not EPC or not EPC.DualActionBar or not EVENT_MANAGER then return end

local D = EPC.DualActionBar
local EM = EVENT_MANAGER

local BASE_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_DualActionBar029189"
local TRANSFORM_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_TransformBar029554"
local PERF_PREFIX = (EPC.name or "ESOAdventurerSuite") .. "_DualBarCastPerf029561"

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
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

local function weaponSwapBlocked()
    local stamp = nowMs()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029635)
        or 0
    return stamp > 0 and stamp < untilMs
end

local function slotSignature(slot, category)
    if slot == nil or category == nil then return "" end
    local bound = tonumber(safe(GetSlotBoundId, 0, slot, category)) or 0
    local used = safe(IsSlotUsed, false, slot, category) == true and 1 or 0
    local icon = tostring(safe(GetSlotTexture, "", slot, category) or "")
    return tostring(bound) .. ":" .. tostring(used) .. ":" .. icon
end

function D:CaptureStaticSlotSignatures029561()
    -- Never scan both bars inside ESO's weapon swap transition.
    if weaponSwapBlocked() and self.layoutMode ~= true then return false end

    self.staticSlotSignatures029561 = self.staticSlotSignatures029561 or {}
    local seen = {}
    for _, row in ipairs(self.rows or {}) do
        local category = row and row.epcCategory
        if category ~= nil and not seen[category] then
            seen[category] = true
            local categoryCache = self.staticSlotSignatures029561[category] or {}
            self.staticSlotSignatures029561[category] = categoryCache
            for _, slot in ipairs(self.slots or {}) do
                categoryCache[slot] = slotSignature(slot, category)
            end
        end
    end
    return true
end

function D:DidStaticSlotDataChange029561()
    -- This is the expensive part: two bars x six slots x several ESO API calls.
    -- A weapon swap never changes the configured slots, so there is nothing to
    -- detect here until the transition is over.
    if weaponSwapBlocked() and self.layoutMode ~= true then return false end

    self.staticSlotSignatures029561 = self.staticSlotSignatures029561 or {}
    local changed = false
    local seen = {}
    for _, row in ipairs(self.rows or {}) do
        local category = row and row.epcCategory
        if category ~= nil and not seen[category] then
            seen[category] = true
            local categoryCache = self.staticSlotSignatures029561[category] or {}
            self.staticSlotSignatures029561[category] = categoryCache
            for _, slot in ipairs(self.slots or {}) do
                local signature = slotSignature(slot, category)
                if categoryCache[slot] ~= signature then
                    categoryCache[slot] = signature
                    changed = true
                end
            end
        end
    end
    return changed
end

function D:ScheduleStaticRefresh029561()
    EM:UnregisterForUpdate(PERF_PREFIX .. "_Static")
    EM:RegisterForUpdate(PERF_PREFIX .. "_Static", 35, function()
        EM:UnregisterForUpdate(PERF_PREFIX .. "_Static")
        if not D or (D.layoutMode ~= true and weaponSwapBlocked()) then return end
        if type(D.InvalidateStyleCache029189) == "function" then D:InvalidateStyleCache029189() end
        if type(D.RefreshStatic029311) == "function" then D:RefreshStatic029311() end
        if type(D.CaptureStaticSlotSignatures029561) == "function" then D:CaptureStaticSlotSignatures029561() end
        if type(D.RefreshDynamic029311) == "function" then D:RefreshDynamic029311(false) end
    end)
end

local function installLightSlotHandler()
    if not rawget(_G, "EVENT_ACTION_SLOT_UPDATED") then return end

    -- Remove both previous heavy handlers. The transformation module still keeps
    -- its dedicated active-hotbar and weapon-pair events for actual form changes.
    EM:UnregisterForEvent(BASE_PREFIX .. "_Slot", EVENT_ACTION_SLOT_UPDATED)
    EM:UnregisterForEvent(TRANSFORM_PREFIX .. "_Slot", EVENT_ACTION_SLOT_UPDATED)
    EM:UnregisterForEvent(PERF_PREFIX .. "_Slot", EVENT_ACTION_SLOT_UPDATED)

    EM:RegisterForEvent(PERF_PREFIX .. "_Slot", EVENT_ACTION_SLOT_UPDATED, function()
        if not D or not EPC.saved or EPC.saved.showDualActionBar029189 ~= true then return end

        -- ESO emits a slot-event burst during Primary/Backup swapping. Never scan
        -- signatures or enter dynamic refresh from those events.
        if D.layoutMode ~= true and weaponSwapBlocked() then return end

        if D:DidStaticSlotDataChange029561() then
            -- Dragging/replacing/morphing a skill changed actual slot metadata.
            D:ScheduleStaticRefresh029561()
        elseif type(D.RefreshDynamic029311) == "function" then
            -- Ordinary cast/cooldown/effect update: no icon/style/hotkey rebuild.
            D:RefreshDynamic029311(false)
        end
    end)
end

-- TransformationFix registers its slot listener at file load, so remove it now.
if rawget(_G, "EVENT_ACTION_SLOT_UPDATED") then
    EM:UnregisterForEvent(TRANSFORM_PREFIX .. "_Slot", EVENT_ACTION_SLOT_UPDATED)
end

-- DualActionBar registers its legacy slot listener inside Initialize(). Wrap that
-- initializer so our lightweight handler becomes authoritative immediately after.
if type(D.Initialize) == "function" and not D._castPerfInitializeWrap029561 then
    local baseInitialize = D.Initialize
    function D:Initialize(...)
        local result = baseInitialize(self, ...)
        self:CaptureStaticSlotSignatures029561()
        installLightSlotHandler()
        return result
    end
    D._castPerfInitializeWrap029561 = true
end

-- Safe for reloads/late loads where the Dual Bar has already initialized.
if D.window then
    D:CaptureStaticSlotSignatures029561()
    installLightSlotHandler()
end
