-- ESO Adventurer Suite
-- v0.29.667 - Quickslot potion cooldown presentation.
-- Uses ESO's native GetSlotCooldownInfo() and the existing Quickslot refresh pulse.

local EPC = ESOProgressionCoach
local Q = EPC and EPC.QuickslotOverlay
local wm = WINDOW_MANAGER
if not EPC or not Q or not wm then return end
if Q._easCooldownFix029667 then return end
Q._easCooldownFix029667 = true

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function formatCooldown(ms)
    ms = tonumber(ms) or 0
    if ms <= 0 then return "" end
    local seconds = ms / 1000
    if seconds >= 10 then return tostring(math.ceil(seconds)) end
    return string.format("%.1f", seconds)
end

local baseCreate = Q.Create
function Q:Create(...)
    local frame = baseCreate(self, ...)
    if not frame then return frame end
    if not self.cooldownShade029667 then
        local shade = wm:CreateControl("EAS_QuickslotCooldownShade029667", frame, CT_BACKDROP)
        shade:SetAnchor(TOPLEFT, self.icon, TOPLEFT, 0, 0)
        shade:SetAnchor(BOTTOMRIGHT, self.icon, BOTTOMRIGHT, 0, 0)
        shade:SetCenterColor(0, 0, 0, 0.48)
        shade:SetEdgeColor(0, 0, 0, 0)
        shade:SetHidden(true)

        local label = wm:CreateControl("EAS_QuickslotCooldownLabel029667", frame, CT_LABEL)
        label:SetAnchor(TOPLEFT, self.icon, TOPLEFT, 0, 0)
        label:SetAnchor(BOTTOMRIGHT, self.icon, BOTTOMRIGHT, 0, 0)
        label:SetFont("$(BOLD_FONT)|25|soft-shadow-thick")
        label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        label:SetColor(1.00, 0.82, 0.24, 1.00)
        label:SetText("")
        label:SetHidden(true)

        self.cooldownShade029667 = shade
        self.cooldownLabel029667 = label
    end
    return frame
end

function Q:RefreshCooldownPresentation029667(slot)
    self:Create()
    if not self.icon then return end

    local category = rawget(_G, "HOTBAR_CATEGORY_QUICKSLOT_WHEEL")
    local remaining, duration = 0, 0
    if type(GetSlotCooldownInfo) == "function" then
        remaining, duration = safe(GetSlotCooldownInfo, 0, slot, category)
        remaining = tonumber(remaining) or 0
        duration = tonumber(duration) or 0
    end

    local cooling = remaining > 0 and duration > 0
    if type(self.icon.SetDesaturation) == "function" then
        self.icon:SetDesaturation(cooling and 1 or 0)
    end
    if type(self.icon.SetColor) == "function" then
        if cooling then self.icon:SetColor(0.62, 0.62, 0.62, 1)
        else self.icon:SetColor(1, 1, 1, 1) end
    end

    if self.cooldownShade029667 then self.cooldownShade029667:SetHidden(not cooling) end
    if self.cooldownLabel029667 then
        self.cooldownLabel029667:SetText(cooling and formatCooldown(remaining) or "")
        self.cooldownLabel029667:SetHidden(not cooling)
    end
    self.quickslotCooldownActive029667 = cooling
    self.quickslotCooldownRemaining029667 = remaining
end

local baseRefresh = Q.Refresh
function Q:Refresh(...)
    local result = baseRefresh(self, ...)
    local slot = tonumber(safe(GetCurrentQuickslot, 1)) or 1
    if self.frame and not self.frame:IsHidden() then
        self:RefreshCooldownPresentation029667(slot)
    else
        if self.icon and type(self.icon.SetDesaturation) == "function" then self.icon:SetDesaturation(0) end
        if self.icon and type(self.icon.SetColor) == "function" then self.icon:SetColor(1, 1, 1, 1) end
        if self.cooldownShade029667 then self.cooldownShade029667:SetHidden(true) end
        if self.cooldownLabel029667 then self.cooldownLabel029667:SetHidden(true) end
    end
    return result
end

-- Refresh immediately when ESO reports quickslot state/cooldown changes. The
-- existing 650ms visible-overlay pulse remains the fallback countdown owner.
local prefix = (EPC.name or "ESOAdventurerSuite") .. "_QuickslotCooldown029667"
for _, eventName in ipairs({ "EVENT_ACTION_SLOT_STATE_UPDATED", "EVENT_ACTION_SLOT_UPDATED", "EVENT_HOTBAR_SLOT_UPDATED" }) do
    local eventId = rawget(_G, eventName)
    if eventId and EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent(prefix .. eventName, eventId, function()
            if EPC and EPC.QuickslotOverlay then EPC.QuickslotOverlay:Refresh() end
        end)
    end
end
