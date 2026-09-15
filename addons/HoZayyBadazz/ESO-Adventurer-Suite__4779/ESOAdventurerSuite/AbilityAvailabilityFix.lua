-- ESO Adventurer Suite
-- v0.29.513 - lightweight native action-bar availability feedback.
-- Makes Suite ability icons clearly grey/dim whenever ESO considers the slot
-- unusable (target/range/state/resource/etc.) without forcing native button
-- refresh work on every Suite repaint.

local EPC = ESOProgressionCoach
if not EPC then return end

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function GetSlotAvailability029513(slot, category)
    slot = tonumber(slot)
    if not slot then return true end

    local activeCategory = safe(GetActiveHotbarCategory, nil)

    -- Inactive weapon-bar icons already have their own dim/desaturation state.
    -- Do not run active-useability work on those slots every dynamic tick.
    if category ~= activeCategory then return true end

    local usable = safe(IsSlotUsable, true, slot, category) ~= false

    -- ESO's own ActionButton already refreshes its live failure state when the
    -- player casts, targets, moves in/out of range, etc. Read that state only;
    -- do NOT call UpdateUseFailure() from addon code on every Suite repaint.
    if type(ZO_ActionBar_GetButton) == "function" then
        local button = safe(ZO_ActionBar_GetButton, nil, slot, category)
        if button then
            if button.useFailure == true then
                usable = false
            elseif button.usable ~= nil then
                usable = button.usable == true
            end
        end
    end

    return usable
end

local function ApplyAvailabilityVisual029513(icon, shade, usable, baseDesaturation)
    if not icon then return end
    local unavailable = usable == false
    baseDesaturation = tonumber(baseDesaturation) or 0

    if icon.SetDesaturation then
        icon:SetDesaturation(unavailable and 1 or baseDesaturation)
    end
    if icon.SetAlpha then
        icon:SetAlpha(unavailable and 0.42 or 1.0)
    end
    if shade then
        shade:SetHidden(false)
        shade:SetCenterColor(0, 0, 0, unavailable and 0.62 or 0)
        shade:SetEdgeColor(0, 0, 0, 0)
    end
end

-- Single-row Ability Overlays -------------------------------------------------
local A = EPC.AbilityOverlays
if A and type(A.RefreshWidget) == "function" and not A._easAvailabilityWrapped029513 then
    A._easAvailabilityWrapped029513 = true
    local baseRefreshWidget = A.RefreshWidget

    function A:RefreshWidget(widget, ...)
        local result = baseRefreshWidget(self, widget, ...)
        if not widget or widget:IsHidden() then return result end
        if self.layoutMode then return result end

        local category = safe(GetActiveHotbarCategory, nil)
        local slot = widget.epcSlot
        if safe(IsSlotUsed, false, slot, category) == true then
            local usable = GetSlotAvailability029513(slot, category)
            ApplyAvailabilityVisual029513(widget.epcIcon, widget.epcShade, usable, 0)
            widget.epcUnavailable029513 = not usable
        end
        return result
    end
end

-- Dual Action Bar -------------------------------------------------------------
local D = EPC.DualActionBar
if D and type(D.RefreshDynamic029311) == "function" and not D._easAvailabilityWrapped029513 then
    D._easAvailabilityWrapped029513 = true
    local baseRefreshDynamic = D.RefreshDynamic029311

    local function ApplyDualAvailability029513(self)
        if not self.rows then return end
        local activeCategory = safe(GetActiveHotbarCategory, nil)
        local inactiveDesaturation = math.max(0, math.min(1,
            ((tonumber(EPC.saved and EPC.saved.dualActionBarInactiveDesaturation029189) or 45) / 100)))

        for _, row in ipairs(self.rows) do
            local category = row.epcCategory
            local active = category == activeCategory
            for _, frame in ipairs(row.slots or {}) do
                local ability = frame.epcAbility029311
                if ability and ability.used == true and frame.epcIcon and not frame.epcIcon:IsHidden() then
                    local usable = active and GetSlotAvailability029513(ability.slot, category) or true
                    local baseDesat = active and 0 or inactiveDesaturation
                    ApplyAvailabilityVisual029513(frame.epcIcon, frame.epcShade, usable, baseDesat)
                    frame.epcUnavailable029513 = not usable
                elseif frame.epcShade then
                    frame.epcShade:SetHidden(true)
                end
            end
        end
    end

    function D:RefreshDynamic029311(force, ...)
        local result = baseRefreshDynamic(self, force, ...)
        ApplyDualAvailability029513(self)
        return result
    end

    if type(D.RefreshStatic029311) == "function" then
        local baseRefreshStatic = D.RefreshStatic029311
        function D:RefreshStatic029311(...)
            local result = baseRefreshStatic(self, ...)
            ApplyDualAvailability029513(self)
            return result
        end
    end
end
