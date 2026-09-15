-- ESO Adventurer Suite
-- v0.29.530 - reliable bank grid canvas + blank-bank fail-safe.
-- Loaded after BankGridVisibilityTakeoverFix so it replaces the hard override
-- render/container while preserving the numeric-safe Collect/Move methods.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER or not GuiRoot then return end
local M = EPC.BankGridHardOverride
if not M then return end

local wm = WINDOW_MANAGER
local CELL, GAP, HEADER_H, MAX_CELLS = 46, 5, 28, 320

local function qualityColor(q)
    q = tonumber(q) or 0
    local colorType = rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS")
    if type(GetInterfaceColor) == "function" and colorType ~= nil then
        local ok, r, g, b = pcall(GetInterfaceColor, colorType, q)
        if ok and r ~= nil then return r, g, b end
    end
    return 0.35, 0.42, 0.50
end

local function ensureFrame(self)
    if self.frame and self.child and self._canvas029530 then return true end

    -- A /reloadui recreates controls, but guard against an earlier implementation
    -- having created the frame first in the same session.
    if self.frame and type(self.frame.SetHidden) == "function" then
        pcall(self.frame.SetHidden, self.frame, true)
    end

    local frame = wm:CreateControl("EASBankGridCanvas029530", GuiRoot, CT_CONTROL)
    frame:SetHidden(true)
    frame:SetMouseEnabled(true)
    if type(frame.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then frame:SetDrawTier(DT_HIGH) end
    if type(frame.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then frame:SetDrawLayer(DL_OVERLAY) end
    frame:SetDrawLevel(2000)

    local bg = wm:CreateControl(nil, frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.012, 0.018, 0.028, 1)
    bg:SetEdgeColor(0.30, 0.42, 0.56, 1)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)

    -- Plain canvas: no ZO_ScrollContainer/PerfectPixel dependency.
    local canvas = wm:CreateControl("EASBankGridCanvasChild029530", frame, CT_CONTROL)
    canvas:SetAnchorFill(frame)
    canvas:SetMouseEnabled(true)

    self.frame = frame
    self.child = canvas
    self.cells = {}
    self.headers = {}
    self.collapsed = self.collapsed or { WITHDRAW = {}, DEPOSIT = {} }
    self.collapsed.WITHDRAW = self.collapsed.WITHDRAW or {}
    self.collapsed.DEPOSIT = self.collapsed.DEPOSIT or {}
    self._canvas029530 = true
    self.scrollOffset029530 = 0

    frame:SetHandler("OnMouseWheel", function(_, delta)
        local maxScroll = tonumber(self.maxScroll029530) or 0
        if maxScroll <= 0 then return end
        self.scrollOffset029530 = math.max(0, math.min(maxScroll, (tonumber(self.scrollOffset029530) or 0) - (tonumber(delta) or 0) * 92))
        self.dirty = true
    end)
    return true
end

function M:Create()
    return ensureFrame(self)
end

function M:Render(info)
    if type(info) ~= "table" then error("EAS bank grid: missing render info") end
    if not ensureFrame(self) then error("EAS bank grid: canvas creation failed") end

    local w, h = tonumber(info.w), tonumber(info.h)
    local l, t = tonumber(info.l), tonumber(info.t)
    if not w or not h or not l or not t or w <= 100 or h <= 100 then
        error("EAS bank grid: invalid bank rectangle")
    end

    self.mode = info.mode
    self.frame:ClearAnchors()
    self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, l, t)
    self.frame:SetDimensions(w, h)
    self.frame:SetHidden(false)

    local items = type(self.Collect) == "function" and self:Collect(info.mode) or nil
    if type(items) ~= "table" or #items == 0 then
        self.frame:SetHidden(true)
        error("EAS bank grid: no items collected; keep native bank visible")
    end

    local grouped, order = {}, {}
    for _, item in ipairs(items) do
        local group = tostring(item.group or "OTHER")
        if not grouped[group] then
            grouped[group] = {}
            order[#order + 1] = group
        end
        grouped[group][#grouped[group] + 1] = item
    end
    table.sort(order, function(a, b)
        local ai = grouped[a] and grouped[a][1]
        local bi = grouped[b] and grouped[b][1]
        return (tonumber(ai and ai.order) or 90) < (tonumber(bi and bi.order) or 90)
    end)

    local cols = math.max(4, math.floor((w - 16) / (CELL + GAP)))
    local contentY = 4
    local layout = {}
    for _, group in ipairs(order) do
        layout[#layout + 1] = { kind = "header", group = group, y = contentY }
        contentY = contentY + HEADER_H + GAP
        local collapsed = self.collapsed[info.mode] and self.collapsed[info.mode][group] == true
        if not collapsed then
            local count = #grouped[group]
            local rows = math.ceil(count / cols)
            layout[#layout + 1] = { kind = "items", group = group, y = contentY }
            contentY = contentY + rows * (CELL + GAP) + GAP
        end
    end

    self.maxScroll029530 = math.max(0, contentY - h + 8)
    self.scrollOffset029530 = math.max(0, math.min(self.maxScroll029530, tonumber(self.scrollOffset029530) or 0))
    local offset = self.scrollOffset029530

    local hi, ci = 0, 0
    for _, block in ipairs(layout) do
        if block.kind == "header" then
            hi = hi + 1
            local header = self:GetHeader(hi)
            header:SetHidden(false)
            header:ClearAnchors()
            header:SetAnchor(TOPLEFT, self.child, TOPLEFT, 2, block.y - offset)
            header:SetWidth(w - 16)
            header.group = block.group
            local collapsed = self.collapsed[info.mode][block.group] == true
            header.label:SetText((collapsed and "+  " or "-  ") .. block.group .. "  (" .. tostring(#grouped[block.group]) .. ")")
        else
            local list = grouped[block.group]
            for i, item in ipairs(list) do
                ci = ci + 1
                if ci > MAX_CELLS then break end
                local cell = self:GetCell(ci)
                cell:SetHidden(false)
                cell.item = item
                cell:ClearAnchors()
                local col = (i - 1) % cols
                local row = math.floor((i - 1) / cols)
                cell:SetAnchor(TOPLEFT, self.child, TOPLEFT,
                    2 + col * (CELL + GAP), block.y - offset + row * (CELL + GAP))
                cell.icon:SetTexture(item.icon ~= "" and item.icon or "EsoUI/Art/Icons/icon_missing.dds")
                cell.count:SetText((tonumber(item.stack) or 1) > 1 and tostring(item.stack) or "")
                local r, g, b = qualityColor(item.quality)
                cell.bg:SetEdgeColor(r, g, b, 1)
                cell.bg:SetCenterColor(0.04 + r * 0.16, 0.05 + g * 0.16, 0.07 + b * 0.16, 1)
            end
        end
    end

    for i = hi + 1, #(self.headers or {}) do self.headers[i]:SetHidden(true) end
    for i = ci + 1, #(self.cells or {}) do self.cells[i]:SetHidden(true); self.cells[i].item = nil end

    -- Critical fail-safe: takeover code suppresses ESO only when Render succeeds.
    -- If no Suite controls are actually visible, throw inside its pcall so the
    -- native bank remains usable instead of becoming blank.
    local visible = false
    for i = 1, hi do
        local c = self.headers[i]
        if c and type(c.IsHidden) == "function" and not c:IsHidden() then visible = true break end
    end
    if not visible then
        for i = 1, ci do
            local c = self.cells[i]
            if c and type(c.IsHidden) == "function" and not c:IsHidden() then visible = true break end
        end
    end
    if not visible then
        self.frame:SetHidden(true)
        error("EAS bank grid: no visible Suite controls; keep native bank visible")
    end

    self.lastSignature = tostring(info.mode) .. ":" .. math.floor(l) .. ":" .. math.floor(t) .. ":" .. math.floor(w) .. ":" .. math.floor(h) .. ":" .. tostring(#items) .. ":" .. tostring(offset)
    self.dirty = false
    return true
end

M.dirty = true
