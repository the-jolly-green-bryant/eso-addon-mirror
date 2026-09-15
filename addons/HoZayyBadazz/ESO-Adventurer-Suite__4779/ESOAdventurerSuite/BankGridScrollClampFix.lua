-- ESO Adventurer Suite
-- v0.29.536 - bank grid scroll clamp + manual viewport clipping.
-- The V2 bank grid uses plain controls, so child controls are not automatically
-- clipped by the parent. Clamp scrolling to content height and hide controls
-- outside the visible bank pane.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U then return end

local CELL, GAP, HEADER_H = 48, 5, 28
local TOP_INSET, BOTTOM_INSET = 34, 4

local baseCreateFor = U.CreateFor
local baseRender = U.Render

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function contentHeight(self, info)
    if type(self.Collect) ~= "function" or type(info) ~= "table" then return TOP_INSET end
    local items = self:Collect(info.mode)
    if type(items) ~= "table" then return TOP_INSET end

    local groups, order = {}, {}
    for _, item in ipairs(items) do
        local group = tostring(item.group or "OTHER")
        if not groups[group] then
            groups[group] = {}
            order[#order + 1] = group
        end
        groups[group][#groups[group] + 1] = item
    end
    table.sort(order, function(a, b)
        return (tonumber(groups[a][1] and groups[a][1].order) or 90)
            < (tonumber(groups[b][1] and groups[b][1].order) or 90)
    end)

    local width = self.root and tonumber(first(self.root.GetWidth, info.w or 0, self.root)) or tonumber(info.w) or 0
    local cols = math.max(4, math.floor((width - 16) / (CELL + GAP)))
    local y = TOP_INSET
    local collapsedByMode = self.collapsed and self.collapsed[info.mode] or {}

    for _, group in ipairs(order) do
        y = y + HEADER_H + GAP
        if not (collapsedByMode and collapsedByMode[group] == true) then
            local rows = math.ceil(#groups[group] / cols)
            y = y + rows * (CELL + GAP) + GAP
        end
    end
    return y
end

local function applyWheelHandler(self)
    if not self.root or type(self.root.SetHandler) ~= "function" then return end
    self.root:SetHandler("OnMouseWheel", function(_, delta)
        local maxScroll = tonumber(self.maxScroll029536) or 0
        local current = tonumber(self.scroll) or 0
        local step = 92
        self.scroll = math.max(0, math.min(maxScroll, current - (tonumber(delta) or 0) * step))
    end)
end

function U:CreateFor(info)
    local result = baseCreateFor(self, info)
    applyWheelHandler(self)
    return result
end

local function clipControls(self)
    local root = self.root
    if not root then return end
    local rootTop = tonumber(first(root.GetTop, nil, root))
    local rootBottom = tonumber(first(root.GetBottom, nil, root))
    if not rootTop or not rootBottom then return end

    local clipTop = rootTop + TOP_INSET
    local clipBottom = rootBottom - BOTTOM_INSET

    local function clip(control)
        if not control or type(control.GetTop) ~= "function" or type(control.GetBottom) ~= "function" then return end
        local top = tonumber(first(control.GetTop, nil, control))
        local bottom = tonumber(first(control.GetBottom, nil, control))
        if not top or not bottom then return end
        local outside = bottom <= clipTop or top >= clipBottom or top < clipTop or bottom > clipBottom
        if type(control.SetHidden) == "function" then control:SetHidden(outside) end
        if type(control.SetMouseEnabled) == "function" then control:SetMouseEnabled(not outside) end
    end

    for _, header in ipairs(self.headers or {}) do clip(header) end
    for _, cell in ipairs(self.cells or {}) do clip(cell) end
end

function U:Render(info)
    if type(info) ~= "table" then return false end

    -- Ensure the root exists before calculating viewport/content dimensions.
    self:CreateFor(info)

    local height = self.root and tonumber(first(self.root.GetHeight, info.h or 0, self.root)) or tonumber(info.h) or 0
    local total = contentHeight(self, info)
    self.maxScroll029536 = math.max(0, total - math.max(0, height - BOTTOM_INSET))
    self.scroll = math.max(0, math.min(self.maxScroll029536, tonumber(self.scroll) or 0))

    local shown = baseRender(self, info)
    if shown then
        clipControls(self)
    end
    return shown
end
