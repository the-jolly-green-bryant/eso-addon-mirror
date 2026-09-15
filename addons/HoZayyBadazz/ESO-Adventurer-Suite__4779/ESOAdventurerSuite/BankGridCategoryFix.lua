-- ESO Adventurer Suite
-- v0.29.655 - bank visible set-name grouping + companion category correctness.
-- Set gear is presented under one collapsible header per set in BOTH Withdraw
-- and Deposit. Companion gear is kept separate from player Weapons/Armor/Jewelry.

local EPC = ESOProgressionCoach
if not EPC then return end
local U = EPC.BankGridUnifiedV2
if not U then return end

local CELL, GAP, HEADER_H, MAX_CELLS = 48, 5, 28, 320
local TOP_INSET, BOTTOM_INSET, SIDE_INSET = 34, 4, 4

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, value = pcall(fn, ...)
    if not ok or value == nil then return fallback end
    return value
end

local function high(control, level)
    if not control then return end
    if type(control.SetAlpha) == "function" then pcall(control.SetAlpha, control, 1) end
    if type(control.SetDrawTier) == "function" and rawget(_G, "DT_HIGH") ~= nil then pcall(control.SetDrawTier, control, DT_HIGH) end
    if type(control.SetDrawLayer) == "function" and rawget(_G, "DL_OVERLAY") ~= nil then pcall(control.SetDrawLayer, control, DL_OVERLAY) end
    if type(control.SetDrawLevel) == "function" then pcall(control.SetDrawLevel, control, level or 900) end
end

local CATEGORY_ORDER = { WEAPONS=110, ARMOR=120, JEWELRY=130, COMPANION=135, CONSUMABLES=140, MATERIALS=150, OTHER=190 }
local CATEGORY_LABELS = { WEAPONS="Weapons (No Set)", ARMOR="Armor (No Set)", JEWELRY="Jewelry (No Set)", COMPANION="Companion Gear", CONSUMABLES="Consumables", MATERIALS="Materials", OTHER="Other" }
local GEAR_FAMILY_ORDER = { WEAPONS=10, ARMOR=20, JEWELRY=30, COMPANION=35 }

local function ensureState(self, mode)
    self.collapsed = self.collapsed or {}
    self.collapsed.WITHDRAW = self.collapsed.WITHDRAW or {}
    self.collapsed.DEPOSIT = self.collapsed.DEPOSIT or {}
    self.collapsed[mode] = self.collapsed[mode] or {}
    return self.collapsed[mode]
end

local function lower(v)
    return string.lower(tostring(v or ""))
end

local function itemLess(a, b)
    local af, bf = GEAR_FAMILY_ORDER[a and a.group] or 90, GEAR_FAMILY_ORDER[b and b.group] or 90
    if af ~= bf then return af < bf end

    if a and b and a.group == "ARMOR" and b.group == "ARMOR" then
        local as = tonumber(a._easArmorSlotOrder029652) or 999
        local bs = tonumber(b._easArmorSlotOrder029652) or 999
        if as ~= bs then return as < bs end
    end

    local aq, bq = tonumber(a and a.quality) or 0, tonumber(b and b.quality) or 0
    if aq ~= bq then return aq > bq end

    return lower(a and a.name) < lower(b and b.name)
end

local function groupItems(items)
    local groups, order, labels, meta = {}, {}, {}, {}

    for _, item in ipairs(items or {}) do
        local groupKey
        local displayName = tostring(item and item._easSetDisplayName029652 or "")
        local setKey = tostring(item and item._easSetName029652 or "")
        local hasSet = item and item._easHasSet029652 == true and setKey ~= "" and item.group ~= "COMPANION"

        if hasSet then
            groupKey = "SET:" .. setKey
            labels[groupKey] = displayName ~= "" and displayName or setKey
            meta[groupKey] = { isSet=true, sortName=setKey, order=10 }
        else
            local category = tostring(item and item.group or "OTHER")
            if not CATEGORY_ORDER[category] then category = "OTHER" end
            groupKey = category
            labels[groupKey] = CATEGORY_LABELS[category] or category
            meta[groupKey] = { isSet=false, sortName=lower(labels[groupKey]), order=CATEGORY_ORDER[category] or 190 }
        end

        if not groups[groupKey] then
            groups[groupKey] = {}
            order[#order + 1] = groupKey
        end
        groups[groupKey][#groups[groupKey] + 1] = item
    end

    table.sort(order, function(a, b)
        local am, bm = meta[a] or {}, meta[b] or {}
        local ao, bo = tonumber(am.order) or 999, tonumber(bm.order) or 999
        if ao ~= bo then return ao < bo end
        return tostring(am.sortName or a) < tostring(bm.sortName or b)
    end)

    for key, list in pairs(groups) do
        if meta[key] and meta[key].isSet == true then
            table.sort(list, itemLess)
        end
    end

    return groups, order, labels
end

local baseGetHeader = U.GetHeader
function U:GetHeader(i)
    local header = baseGetHeader(self, i)
    if header and not header._easCategoryClick029537 then
        header._easCategoryClick029537 = true
        header:SetHandler("OnClicked", function(ctrl)
            local mode, group = self.mode, ctrl.group
            if not mode or not group then return end
            local state = ensureState(self, mode)
            state[group] = not (state[group] == true)
            self.scroll = 0
            self.dirty = true
        end)
    end
    return header
end

local function deactivatePool(self)
    for _, header in ipairs(self.headers or {}) do
        header._easBankActive029543 = false
        if type(header.SetHidden) == "function" then pcall(header.SetHidden, header, true) end
        if type(header.SetMouseEnabled) == "function" then pcall(header.SetMouseEnabled, header, false) end
    end
    for _, cell in ipairs(self.cells or {}) do
        cell._easBankActive029543 = false
        cell.item = nil
        if type(cell.SetHidden) == "function" then pcall(cell.SetHidden, cell, true) end
        if type(cell.SetMouseEnabled) == "function" then pcall(cell.SetMouseEnabled, cell, false) end
    end
end

local function clipToViewport(self)
    local root = self.root
    if not root then return end
    local rootTop = tonumber(first(root.GetTop,nil,root))
    local rootBottom = tonumber(first(root.GetBottom,nil,root))
    local rootLeft = tonumber(first(root.GetLeft,nil,root))
    local rootRight = tonumber(first(root.GetRight,nil,root))
    if not rootTop or not rootBottom or not rootLeft or not rootRight then return end

    local clipTop, clipBottom = rootTop + TOP_INSET, rootBottom - BOTTOM_INSET
    local clipLeft, clipRight = rootLeft + SIDE_INSET, rootRight - SIDE_INSET

    local function geometry(control)
        if not control then return nil end
        local top = type(control.GetTop)=="function" and tonumber(first(control.GetTop,nil,control)) or nil
        local bottom = type(control.GetBottom)=="function" and tonumber(first(control.GetBottom,nil,control)) or nil
        local left = type(control.GetLeft)=="function" and tonumber(first(control.GetLeft,nil,control)) or nil
        local right = type(control.GetRight)=="function" and tonumber(first(control.GetRight,nil,control)) or nil
        return top,bottom,left,right
    end

    for _, header in ipairs(self.headers or {}) do
        if header._easBankActive029543 ~= true then
            if type(header.SetHidden)=="function" then pcall(header.SetHidden,header,true) end
            if type(header.SetMouseEnabled)=="function" then pcall(header.SetMouseEnabled,header,false) end
        else
            local top,bottom,left,right = geometry(header)
            local visible = top and bottom and left and right and bottom > clipTop and top < clipBottom and right > clipLeft and left < clipRight
            if type(header.SetHidden)=="function" then pcall(header.SetHidden,header,not visible) end
            if type(header.SetMouseEnabled)=="function" then pcall(header.SetMouseEnabled,header,visible==true) end
        end
    end

    for _, cell in ipairs(self.cells or {}) do
        if cell._easBankActive029543 ~= true or cell.item == nil then
            if type(cell.SetHidden)=="function" then pcall(cell.SetHidden,cell,true) end
            if type(cell.SetMouseEnabled)=="function" then pcall(cell.SetMouseEnabled,cell,false) end
        else
            local top,bottom,left,right = geometry(cell)
            local contained = top and bottom and left and right and top >= clipTop and bottom <= clipBottom and left >= clipLeft and right <= clipRight
            if type(cell.SetHidden)=="function" then pcall(cell.SetHidden,cell,not contained) end
            if type(cell.SetMouseEnabled)=="function" then pcall(cell.SetMouseEnabled,cell,contained==true) end
        end
    end
end

function U:Render(info)
    if type(info) ~= "table" then return false end
    self:CreateFor(info)
    if not self.root then return false end

    self.mode = info.mode
    local collapsed = ensureState(self, info.mode)
    self.root:SetHidden(false)
    self.root:SetAlpha(1)
    high(self.root,900)
    if self.title then self.title:SetText("ESO ADVENTURER SUITE — " .. tostring(info.mode or "BANK")) end

    deactivatePool(self)

    local items = type(self.Collect)=="function" and self:Collect(info.mode) or {}
    if type(items) ~= "table" or #items == 0 then return true end

    local groups, order, labels = groupItems(items)
    if #order == 0 then return true end

    local width = tonumber(first(self.root.GetWidth,info.w or 0,self.root)) or tonumber(info.w) or 0
    local height = tonumber(first(self.root.GetHeight,info.h or 0,self.root)) or tonumber(info.h) or 0
    local cols = math.max(4, math.floor((width - 16)/(CELL + GAP)))

    local totalY = TOP_INSET
    for _, group in ipairs(order) do
        totalY = totalY + HEADER_H + GAP
        if not collapsed[group] then totalY = totalY + math.ceil(#groups[group]/cols)*(CELL+GAP) + GAP end
    end
    self.maxScroll029536 = math.max(0,totalY - math.max(0,height - BOTTOM_INSET))
    self.scroll = math.max(0,math.min(self.maxScroll029536,tonumber(self.scroll) or 0))

    local y, hi, ci = TOP_INSET - self.scroll, 0, 0
    for _, group in ipairs(order) do
        hi = hi + 1
        local header = self:GetHeader(hi)
        header._easBankActive029543 = true
        header.group = group
        header:ClearAnchors()
        header:SetAnchor(TOPLEFT,self.root,TOPLEFT,SIDE_INSET,y)
        header:SetWidth(width - (SIDE_INSET*2 + 4))
        header:SetHidden(false)
        header:SetMouseEnabled(true)
        high(header,920); high(header.bg,921); high(header.label,922)

        local isCollapsed = collapsed[group] == true
        header.label:SetText((isCollapsed and "+  " or "-  ") .. tostring(labels[group] or group) .. "  (" .. tostring(#groups[group]) .. ")")
        y = y + HEADER_H + GAP

        if not isCollapsed then
            local rows = 0
            for i,item in ipairs(groups[group]) do
                ci = ci + 1
                if ci > MAX_CELLS then break end
                local cell = self:GetCell(ci)
                cell._easBankActive029543 = true
                cell.item = item
                cell:ClearAnchors()
                local col = (i-1)%cols
                local row = math.floor((i-1)/cols)
                rows = math.max(rows,row+1)
                cell:SetAnchor(TOPLEFT,self.root,TOPLEFT,SIDE_INSET + col*(CELL+GAP),y + row*(CELL+GAP))
                cell:SetHidden(false)
                cell:SetMouseEnabled(true)
                high(cell,930); high(cell.bg,931); high(cell.icon,932); high(cell.count,933)
                if cell.icon then cell.icon:SetTexture(item.icon ~= "" and item.icon or "EsoUI/Art/Icons/icon_missing.dds") end
                if cell.count then cell.count:SetText((tonumber(item.stack) or 1) > 1 and tostring(item.stack) or "") end
            end
            y = y + rows*(CELL+GAP) + GAP
        end
    end

    clipToViewport(self)
    return hi > 0
end

U.dirty = true
