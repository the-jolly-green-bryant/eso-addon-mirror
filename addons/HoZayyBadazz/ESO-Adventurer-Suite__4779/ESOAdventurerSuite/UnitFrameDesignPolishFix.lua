-- ESO Adventurer Suite
-- Unit Frame Designs 3-7 final renderer correction.
-- The mature rectangle renderer in UnitFrames.lua paints epcRectBackdropFill029431
-- and owns epcRectLayoutW/H029434. Finish every rectangle update against those
-- actual controls instead of tinting retired experimental renderers.

local EPC = ESOProgressionCoach
local F = EPC and EPC.UnitFrames
if not EPC or not F then return end

local RECT = {
    RECT_STACK = true,
    TRIPLE_BLOCKS = true,
    SIDE_METERS = true,
    CENTER_CORE = true,
    SLIM_LINES = true,
}

local DARK = {
    health  = {0.20, 0.012, 0.020},
    magicka = {0.012, 0.060, 0.175},
    stamina = {0.012, 0.120, 0.038},
}

local LIVE_ALPHA = 0.74

local function currentDesign()
    return EPC.saved and tostring(EPC.saved.unitFrameVisualStyle or "ESO_CLASSIC") or "ESO_CLASSIC"
end

local function isRectDesign()
    return RECT[currentDesign()] == true
end

local function kindFor(bar)
    if not bar then return "health" end
    if bar.epcResourceKind02997 then return bar.epcResourceKind02997 end
    local name = type(bar.GetName) == "function" and string.lower(tostring(bar:GetName() or "")) or ""
    if string.find(name, "magicka", 1, true) then return "magicka" end
    if string.find(name, "stamina", 1, true) then return "stamina" end
    return "health"
end

local function compactNumber(value)
    local n = tonumber(value) or 0
    local sign = n < 0 and "-" or ""
    n = math.abs(n)
    if n >= 1000000 then return sign .. string.format("%.2fm", n / 1000000) end
    if n >= 100000 then return sign .. string.format("%.0fk", n / 1000) end
    if n >= 10000 then return sign .. string.format("%.1fk", n / 1000) end
    return sign .. tostring(math.floor(n + 0.5))
end

local function percentText(current, maximum)
    current, maximum = tonumber(current) or 0, tonumber(maximum) or 0
    if maximum <= 0 then return "--" end
    return tostring(math.floor((current / maximum) * 100 + 0.5)) .. "%"
end

local function tintControl(control, c, alpha)
    if not control then return end
    if type(control.SetCenterColor) == "function" then
        control:SetCenterColor(c[1], c[2], c[3], alpha)
    elseif type(control.SetColor) == "function" then
        control:SetColor(c[1], c[2], c[3], alpha)
    end
    if type(control.SetAlpha) == "function" then control:SetAlpha(alpha) end
end

local function intendedHeight(bar)
    if not bar then return 0 end
    return tonumber(bar.epcRectLayoutH029434) or tonumber(bar:GetHeight()) or 0
end

-- Only the Player/Target rectangle composition owns these explicit layout
-- heights. Raising every roster bar would crowd group/raid rows.
local function correctLayoutHeight(bar)
    if not bar or type(bar.GetParent) ~= "function" then return end
    local parent = bar:GetParent()
    if not parent or (parent.epcKind ~= "player" and parent.epcKind ~= "target") then return end

    local kind = kindFor(bar)
    if kind == "health" then return end

    local design = currentDesign()
    local desired = nil
    if design == "RECT_STACK" then
        desired = 18
    elseif design == "SIDE_METERS" then
        desired = 14
    elseif design == "CENTER_CORE" then
        desired = 16
    elseif design == "SLIM_LINES" then
        desired = 18
    end

    if desired then
        local h = intendedHeight(bar)
        if h < desired then
            bar.epcRectLayoutH029434 = desired
            if type(bar.SetHeight) == "function" then bar:SetHeight(desired) end
            if bar.epcRectPanel02994 and type(bar.epcRectPanel02994.SetHeight) == "function" then
                bar.epcRectPanel02994:SetHeight(desired)
            end
            if bar.epcRectBackdropFill029431 and type(bar.epcRectBackdropFill029431.SetHeight) == "function" then
                bar.epcRectBackdropFill029431:SetHeight(math.max(1, desired - 4))
            end
        end
    end
end

local function formatStableLabel(bar, current, maximum)
    if not bar or not bar.epcLabel then return end
    local label = bar.epcLabel
    local h = math.max(1, intendedHeight(bar))
    local w = math.max(1, tonumber(bar.epcRectLayoutW029434) or tonumber(bar:GetWidth()) or 1)

    if label.SetHorizontalAlignment then label:SetHorizontalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetVerticalAlignment then label:SetVerticalAlignment(TEXT_ALIGN_CENTER) end
    if label.SetMaxLineCount then label:SetMaxLineCount(1) end
    if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end

    -- Keep the glyph box comfortably inside the short rectangle cavity. Do not
    -- re-anchor here: UnitFrames.lua already owns label geometry.
    if h <= 12 then
        label:SetFont("$(BOLD_FONT)|9|soft-shadow-thin")
    elseif h <= 14 then
        label:SetFont("$(BOLD_FONT)|10|soft-shadow-thin")
    elseif h <= 16 then
        label:SetFont("$(BOLD_FONT)|11|soft-shadow-thin")
    elseif h <= 19 then
        label:SetFont("$(BOLD_FONT)|11|soft-shadow-thin")
    elseif h <= 23 then
        label:SetFont("$(BOLD_FONT)|12|soft-shadow-thin")
    else
        label:SetFont("$(BOLD_FONT)|13|soft-shadow-thin")
    end

    current = tonumber(current)
    maximum = tonumber(maximum)
    if current == nil then current = tonumber(bar.epcRectCurrent) or 0 end
    if maximum == nil then maximum = tonumber(bar.epcRectMaximum) or 0 end

    local text
    if maximum <= 0 then
        text = "--"
    elseif currentDesign() == "SLIM_LINES" or w < 170 or h <= 18 then
        text = percentText(current, maximum)
    elseif w < 250 then
        text = compactNumber(current) .. "  " .. percentText(current, maximum)
    else
        text = compactNumber(current) .. " / " .. compactNumber(maximum) .. "  " .. percentText(current, maximum)
    end

    -- Only write text when its displayed value actually changes.
    if label.epcEASStableText029681 ~= text or (type(label.GetText) == "function" and label:GetText() ~= text) then
        label:SetText(text)
        label.epcEASStableText029681 = text
    end
end

local function finalizeBar(bar, current, maximum, layoutPass)
    if not bar or not isRectDesign() then return end
    if layoutPass then correctLayoutHeight(bar) end

    current = tonumber(current)
    maximum = tonumber(maximum)
    if current == nil then current = tonumber(bar.epcRectCurrent) or 0 end
    if maximum == nil then maximum = tonumber(bar.epcRectMaximum) or 0 end

    local c = DARK[kindFor(bar)] or DARK.health

    -- v0.29.434's actual visible live interior.
    tintControl(bar.epcRectBackdropFill029431, c, LIVE_ALPHA)

    -- Keep compatibility controls subdued too in case a client/layout momentarily
    -- exposes one while switching designs.
    tintControl(bar.epcRectStatusFill029429, c, LIVE_ALPHA)
    tintControl(bar.epcRectColorFill029427, c, LIVE_ALPHA)
    tintControl(bar.epcRectColorFill029426, c, LIVE_ALPHA)
    tintControl(bar.epcRectWidthFill029425, c, LIVE_ALPHA)
    tintControl(bar.epcRectLiveFill029424, c, LIVE_ALPHA)
    tintControl(bar.epcRectFill, c, LIVE_ALPHA)

    if bar.epcRectTrack029427 then tintControl(bar.epcRectTrack029427, {c[1] * 0.16, c[2] * 0.16, c[3] * 0.16}, 0.92) end
    if bar.epcRectTrack029429 then tintControl(bar.epcRectTrack029429, {c[1] * 0.16, c[2] * 0.16, c[3] * 0.16}, 0.92) end

    if bar.epcRectPanel02994 then
        bar.epcRectPanel02994:SetCenterColor(c[1] * 0.045, c[2] * 0.045, c[3] * 0.045, 0.98)
        bar.epcRectPanel02994:SetEdgeColor(
            math.min(1, c[1] * 0.58 + 0.045),
            math.min(1, c[2] * 0.58 + 0.045),
            math.min(1, c[3] * 0.58 + 0.045),
            0.72
        )
    end

    formatStableLabel(bar, current, maximum)
    bar.epcEASLastCurrent029681 = current
    bar.epcEASLastMaximum029681 = maximum
end

local function finalizeUnit(frame, layoutPass)
    if not frame or not frame.epcBars then return end
    for _, bar in pairs(frame.epcBars) do
        finalizeBar(bar, bar and bar.epcRectCurrent, bar and bar.epcRectMaximum, layoutPass)
    end
end

local function finalizeRoster(frame, layoutPass)
    if not frame then return end
    for _, row in ipairs(frame.epcRows or {}) do
        if row and row.epcBars and row.epcBars.health then
            local bar = row.epcBars.health
            finalizeBar(bar, bar.epcRectCurrent, bar.epcRectMaximum, layoutPass)
        end
        if row and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
            local bar = row.epcCompanionHealth
            finalizeBar(bar, bar.epcRectCurrent, bar.epcRectMaximum, layoutPass)
        end
    end
end

local function rebuildRosterCache()
    F._easRectRosterCache029681 = {}
    local cache = F._easRectRosterCache029681
    local frames = {F.groupFrame, F.raidFrame}
    for i = 1, 2 do
        local frame = frames[i]
        if frame then
            for _, row in ipairs(frame.epcRows or {}) do
                if row and row.epcUnitTag and row.epcBars and row.epcBars.health then
                    cache[row.epcUnitTag] = row.epcBars.health
                end
            end
        end
    end
end

local function sameValues(bar, current, maximum)
    if not bar then return false end
    current, maximum = tonumber(current), tonumber(maximum)
    if current == nil or maximum == nil then return false end
    return tonumber(bar.epcEASLastCurrent029681) == current and tonumber(bar.epcEASLastMaximum029681) == maximum
end

-- Layout/style wrappers: correct stored v0.29.434 geometry once and establish the
-- final subdued palette/font. Designs 1-2 remain entirely on the base path.
local baseLayout = F.LayoutIntegratedUnitFrame
function F:LayoutIntegratedUnitFrame(frame, ...)
    local result = baseLayout(self, frame, ...)
    if isRectDesign() then finalizeUnit(frame, true) end
    return result
end

-- Full Player/Target refreshes can repaint resources without going through the
-- lightweight direct EVENT_POWER_UPDATE methods. Finish those refreshes too.
local baseUpdate = F.UpdateUnitFrame
function F:UpdateUnitFrame(frame, ...)
    local result = baseUpdate(self, frame, ...)
    if isRectDesign() then finalizeUnit(frame, false) end
    return result
end

local baseGroup = F.RefreshGroupFrames
function F:RefreshGroupFrames(...)
    local result = baseGroup(self, ...)
    if isRectDesign() then
        finalizeRoster(self.groupFrame, false)
        finalizeRoster(self.raidFrame, false)
        rebuildRosterCache()
    end
    return result
end

local baseVisual = F.ApplyVisualStyle
function F:ApplyVisualStyle(...)
    local result = baseVisual(self, ...)
    if isRectDesign() then
        finalizeUnit(self.playerFrame, true)
        finalizeUnit(self.targetFrame, true)
        finalizeRoster(self.groupFrame, false)
        finalizeRoster(self.raidFrame, false)
        rebuildRosterCache()
    end
    return result
end

-- Direct EVENT_POWER_UPDATE paths. These are the hot paths that bypass
-- UpdateUnitFrame(), so finalize the exact bar after the mature renderer paints
-- it. Equal-value player/target events are suppressed to avoid needless text
-- and geometry churn.
if type(F.UpdatePlayerHealthFromEvent) == "function" then
    local base = F.UpdatePlayerHealthFromEvent
    function F:UpdatePlayerHealthFromEvent(unitTag, powerValue, powerMax)
        local bar = self.playerFrame and self.playerFrame.epcBars and self.playerFrame.epcBars.health
        if isRectDesign() and sameValues(bar, powerValue, powerMax) then
            finalizeBar(bar, powerValue, powerMax, false)
            return true
        end
        local result = base(self, unitTag, powerValue, powerMax)
        if isRectDesign() then finalizeBar(bar, powerValue, powerMax, false) end
        return result
    end
end

if type(F.UpdateTargetHealthFromEvent029341) == "function" then
    local base = F.UpdateTargetHealthFromEvent029341
    function F:UpdateTargetHealthFromEvent029341(unitTag, powerValue, powerMax)
        local bar = self.targetFrame and self.targetFrame.epcBars and self.targetFrame.epcBars.health
        if isRectDesign() and sameValues(bar, powerValue, powerMax) then
            finalizeBar(bar, powerValue, powerMax, false)
            return true
        end
        local result = base(self, unitTag, powerValue, powerMax)
        if isRectDesign() then finalizeBar(bar, powerValue, powerMax, false) end
        return result
    end
end

if type(F.UpdatePlayerResourceFromEvent029341) == "function" then
    local base = F.UpdatePlayerResourceFromEvent029341
    function F:UpdatePlayerResourceFromEvent029341(unitTag, powerType, powerValue, powerMax)
        local bars = self.playerFrame and self.playerFrame.epcBars
        local bar = nil
        if bars then
            if powerType == POWERTYPE_MAGICKA then bar = bars.magicka
            elseif powerType == POWERTYPE_STAMINA then bar = bars.stamina end
        end
        if isRectDesign() and sameValues(bar, powerValue, powerMax) then
            finalizeBar(bar, powerValue, powerMax, false)
            return true
        end
        local result = base(self, unitTag, powerType, powerValue, powerMax)
        if isRectDesign() then finalizeBar(bar, powerValue, powerMax, false) end
        return result
    end
end

if type(F.UpdateGroupHealthFromEvent) == "function" then
    local base = F.UpdateGroupHealthFromEvent
    function F:UpdateGroupHealthFromEvent(unitTag, powerValue, powerMax)
        local result = base(self, unitTag, powerValue, powerMax)
        if isRectDesign() then
            local cache = self._easRectRosterCache029681
            if not cache then rebuildRosterCache() cache = self._easRectRosterCache029681 end
            local bar = cache and cache[unitTag]
            if unitTag == "player" and type(GetLocalPlayerGroupUnitTag) == "function" then
                local localTag = GetLocalPlayerGroupUnitTag()
                if localTag and localTag ~= "" and cache and cache[localTag] then bar = cache[localTag] end
            end
            finalizeBar(bar, powerValue, powerMax, false)
        end
        return result
    end
end

if type(F.UpdateCompanionHealthFromEvent) == "function" then
    local base = F.UpdateCompanionHealthFromEvent
    function F:UpdateCompanionHealthFromEvent(unitTag, powerValue, powerMax)
        local result = base(self, unitTag, powerValue, powerMax)
        if isRectDesign() then
            -- Companion power events are comparatively infrequent; finalize only
            -- matching-value companion bars without adding another polling owner.
            local frames = {self.groupFrame, self.raidFrame}
            for i = 1, 2 do
                local frame = frames[i]
                if frame then
                    for _, row in ipairs(frame.epcRows or {}) do
                        if row and row.epcCompanionHealth and row.epcCompanionHealth ~= false then
                            local bar = row.epcCompanionHealth
                            if tonumber(bar.epcRectCurrent) == tonumber(powerValue) and tonumber(bar.epcRectMaximum) == tonumber(powerMax) then
                                finalizeBar(bar, powerValue, powerMax, false)
                            end
                        end
                    end
                end
            end
        end
        return result
    end
end

-- The mature rectangle sync runs every few seconds while visible. Let it update
-- values first, then make the actual final backdrop fill/font authoritative.
if type(F.RefreshRectResourceFills02995) == "function" then
    local baseRectRefresh = F.RefreshRectResourceFills02995
    function F:RefreshRectResourceFills02995(...)
        local result = baseRectRefresh(self, ...)
        if isRectDesign() then
            finalizeUnit(self.playerFrame, false)
            finalizeUnit(self.targetFrame, false)
            finalizeRoster(self.groupFrame, false)
            finalizeRoster(self.raidFrame, false)
        end
        return result
    end
end

EPC.unitFrameDesignPolishFix029679 = nil
EPC.unitFrameDesignPolishFix029680 = nil
EPC.unitFrameDesignPolishFix029681 = true
