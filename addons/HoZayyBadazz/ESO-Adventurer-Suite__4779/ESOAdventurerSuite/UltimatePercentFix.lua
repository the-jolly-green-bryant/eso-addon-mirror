-- ESO Adventurer Suite
-- v0.29.668 - authoritative 0..500 Ultimate pool presentation.
-- The Suite displays ESO's stored Ultimate points directly with a percent sign.
-- This file owns one lightweight pulse and final-write guards on the two Suite
-- Ultimate renderers so no later refresh can collapse 500% back to 100%.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER then return end
local A = EPC.AbilityOverlays
local D = EPC.DualActionBar
local EM = EVENT_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_UltimatePresentation029668"
local POST_SWAP_COOLDOWN_MS = 1200
local MAX_ULTIMATE_DISPLAY = 500

local function safe1(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    if type(GetGameTimeMilliseconds) == "function" then return tonumber(GetGameTimeMilliseconds()) or 0 end
    return 0
end

local function swapPresentationBlocked()
    local stamp = nowMs()
    local untilMs = tonumber(EPC.weaponSwapBroadRefreshUntil029636)
        or tonumber(EPC.weaponSwapSettlingUntil029636) or 0
    return stamp > 0 and untilMs > 0 and stamp < (untilMs + POST_SWAP_COOLDOWN_MS)
end

local function activeCategory()
    return safe1(GetActiveHotbarCategory, nil)
end

local function ultimateSlot()
    local base = tonumber(rawget(_G, "ACTION_BAR_ULTIMATE_SLOT_INDEX"))
    if base ~= nil then return base + 1 end
    return 8
end

local COST_CACHE = {}
local function invalidateCostCache()
    COST_CACHE = {}
    local W = EPC.WorldUltimateReadiness029640
    if W and type(W.Invalidate029647) == "function" then W:Invalidate029647() end
end

local function getUltimateCost(slot, category)
    slot = tonumber(slot) or ultimateSlot()
    local key = tostring(category) .. ":" .. tostring(slot)
    local cached = COST_CACHE[key]
    if cached ~= nil then return cached end
    local cost = tonumber(safe1(GetSlotAbilityCost, 0, slot, category)) or 0
    if cost <= 0 then
        local abilityId = tonumber(safe1(GetSlotBoundId, 0, slot, category)) or 0
        local flag = rawget(_G, "COMBAT_MECHANIC_FLAGS_ULTIMATE")
        if abilityId > 0 and flag ~= nil and type(GetAbilityCost) == "function" then
            cost = tonumber(safe1(GetAbilityCost, 0, abilityId, flag, nil, "player")) or 0
        end
    end
    cost = math.max(0, cost)
    COST_CACHE[key] = cost
    return cost
end

-- ESO stores Ultimate as a 0..500 resource pool. The on-icon percentage is
-- intentionally that pool value with a percent sign: 100 Ultimate = 100%,
-- 250 Ultimate = 250%, and a full pool = 500%.
local function getUltimatePercent(slot, category)
    local flag = rawget(_G, "COMBAT_MECHANIC_FLAGS_ULTIMATE")
    if flag == nil then return 0, false, 0, 0 end
    local current = tonumber(safe1(GetUnitPower, 0, "player", flag)) or 0
    local cost = getUltimateCost(slot, category)
    local pct = math.floor(current + 0.5)
    pct = math.max(0, math.min(MAX_ULTIMATE_DISPLAY, pct))
    return pct, cost > 0 and current >= cost, current, cost
end

local function setPctLabel(label, pct, ready)
    if not label then return end
    label:SetText(tostring(pct) .. "%")
    if label.SetColor then
        if ready then label:SetColor(1.00, 0.78, 0.18, 1.00)
        else label:SetColor(0.93, 0.86, 0.36, 1.00) end
    end
end

local function refreshAbilityUltimate()
    if not A or not A.widgets or #A.widgets == 0 or not EPC.saved or EPC.saved.showAbilityOverlays == false then return end
    local widget = A.widgets[#A.widgets]
    if not widget or not widget.epcUltimatePct then return end
    local category = activeCategory()
    local slot = widget.epcSlot or ultimateSlot()
    if safe1(IsSlotUsed, false, slot, category) ~= true then
        widget.epcUltimatePct:SetHidden(true)
        return
    end
    local pct, ready = getUltimatePercent(slot, category)
    setPctLabel(widget.epcUltimatePct, pct, ready)
    widget.epcUltimatePct:SetHidden(false)
end

local function refreshDualUltimates()
    if not D or not D.rows or not EPC.saved or EPC.saved.showDualActionBar029189 ~= true then return end
    local ultOrdinal = #(D.slots or {})
    if ultOrdinal <= 0 then return end
    local slot = D.slots[ultOrdinal] or ultimateSlot()
    for _, row in ipairs(D.rows) do
        local category = row.epcCategory
        local frame = row.slots and row.slots[ultOrdinal]
        if frame and frame.epcUltimate then
            if safe1(IsSlotUsed, false, slot, category) == true then
                local pct, ready = getUltimatePercent(slot, category)
                setPctLabel(frame.epcUltimate, pct, ready)
                -- Keep the Dual Action Bar's text cache synchronized too. If
                -- another dynamic refresh uses the cached setter, it now sees
                -- the same authoritative 0..500 text rather than an old 100%.
                frame.ultimateText029311 = tostring(pct) .. "%"
            else
                frame.epcUltimate:SetText("")
                frame.ultimateText029311 = ""
            end
        end
    end
end

local function refreshPresentation()
    if swapPresentationBlocked() then return end
    local W = EPC.WorldUltimateReadiness029640
    if W and type(W.RefreshPresentation029647) == "function" then
        W:RefreshPresentation029647()
    end
    refreshAbilityUltimate()
    refreshDualUltimates()
end

-- Final-write guards. Both base renderers are already running for other HUD
-- work, so these add only a tiny Ultimate label correction after those normal
-- refreshes; no new high-frequency polling loop is introduced.
local function installAuthoritativeRefreshGuards()
    if A and type(A.RefreshWidget) == "function" and A._easUltimateFinalWrite029668 ~= true then
        A._easUltimateFinalWrite029668 = true
        local baseRefreshWidget = A.RefreshWidget
        function A:RefreshWidget(widget, ...)
            local result = baseRefreshWidget(self, widget, ...)
            if self.widgets and widget == self.widgets[#self.widgets] then
                refreshAbilityUltimate()
            end
            return result
        end
    end

    if D and type(D.RefreshDynamic029311) == "function" and D._easUltimateFinalWrite029668 ~= true then
        D._easUltimateFinalWrite029668 = true
        local baseRefreshDynamic = D.RefreshDynamic029311
        function D:RefreshDynamic029311(...)
            local result = baseRefreshDynamic(self, ...)
            refreshDualUltimates()
            return result
        end
    end
end

local function installPulse()
    EM:UnregisterForUpdate(NAME .. "_Pulse")
    EM:RegisterForUpdate(NAME .. "_Pulse", 500, refreshPresentation)
end

if rawget(_G, "EVENT_ACTION_SLOT_UPDATED") then
    EM:RegisterForEvent(NAME .. "_Slot", EVENT_ACTION_SLOT_UPDATED, invalidateCostCache)
end
if rawget(_G, "EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED") then
    EM:RegisterForEvent(NAME .. "_Bars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, invalidateCostCache)
end
if rawget(_G, "EVENT_POWER_UPDATE") then
    local eventName = NAME .. "_Power"
    EM:RegisterForEvent(eventName, EVENT_POWER_UPDATE, function(_, unitTag, powerIndex, powerType)
        if unitTag == "player" and (powerType == rawget(_G, "POWERTYPE_ULTIMATE") or powerType == rawget(_G, "COMBAT_MECHANIC_FLAGS_ULTIMATE")) then
            -- Defer one frame so any ESO/Suite power-event refresh completes
            -- first, then make the displayed pool value the final write.
            if type(zo_callLater) == "function" then zo_callLater(refreshPresentation, 0)
            else refreshPresentation() end
        end
    end)
    if rawget(_G, "REGISTER_FILTER_UNIT_TAG") then
        EM:AddFilterForEvent(eventName, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    end
    if rawget(_G, "REGISTER_FILTER_POWER_TYPE") and rawget(_G, "POWERTYPE_ULTIMATE") ~= nil then
        EM:AddFilterForEvent(eventName, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, POWERTYPE_ULTIMATE)
    end
end
if rawget(_G, "EVENT_PLAYER_ACTIVATED") then
    EM:RegisterForEvent(NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
        invalidateCostCache()
        installAuthoritativeRefreshGuards()
        if type(zo_callLater) == "function" then zo_callLater(refreshPresentation, 350) end
        installPulse()
    end)
end

installAuthoritativeRefreshGuards()
installPulse()

SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/easultimate"] = function()
    local category = activeCategory()
    local slot = ultimateSlot()
    local pct, ready, current, cost = getUltimatePercent(slot, category)
    local text = string.format("EAS Ultimate | points=%d cost=%d display=%d%% ready=%s",
        math.floor(current + 0.5), math.floor(cost + 0.5), pct, ready and "yes" or "no")
    if type(d) == "function" then d(text) elseif EPC.Print then EPC:Print(text) end
end
