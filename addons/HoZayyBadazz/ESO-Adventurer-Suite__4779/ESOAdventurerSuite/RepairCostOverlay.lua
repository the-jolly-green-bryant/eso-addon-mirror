-- ESO Adventurer Suite
-- Copyright (c) 2026 HoZayyBadazz. All Rights Reserved.
-- Proprietary source. Unauthorized redistribution, republication, rebranding,
-- or public distribution of modified/derivative versions is prohibited.
-- Private personal-use modifications are permitted. See LICENSE.txt.

local EPC = ESOProgressionCoach
EPC.RepairCostOverlay = EPC.RepairCostOverlay or {}
local R = EPC.RepairCostOverlay
local wm = WINDOW_MANAGER

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok,a,b,c,d,e,f = pcall(fn,...)
    if not ok then return fallback end
    return a,b,c,d,e,f
end

local function moneyText(value)
    value = math.max(0, math.floor(tonumber(value) or 0))
    if type(ZO_CommaDelimitNumber) == "function" then
        return tostring(ZO_CommaDelimitNumber(value)) .. "g"
    end
    return tostring(value) .. "g"
end

local function cleanItemName(name)
    name = tostring(name or "")
    if name == "" then return "Equipped item" end
    if type(zo_strformat) == "function" and SI_TOOLTIP_ITEM_NAME then
        local ok, formatted = pcall(zo_strformat, SI_TOOLTIP_ITEM_NAME, name)
        if ok and formatted and formatted ~= "" then return formatted end
    end
    return name
end

local function itemName(slot)
    if BAG_WORN == nil then return "" end
    local link = safe(GetItemLink, "", BAG_WORN, slot, LINK_STYLE_DEFAULT or 0)
    if link and link ~= "" and type(GetItemLinkName) == "function" then
        return cleanItemName(safe(GetItemLinkName, "", link))
    end
    return ""
end

function R:GetSlots()
    local slots = {}
    local function add(slot, label)
        if slot ~= nil then slots[#slots + 1] = {slot = slot, label = label} end
    end
    add(EQUIP_SLOT_HEAD, "HEAD")
    add(EQUIP_SLOT_SHOULDERS, "SHOULDERS")
    add(EQUIP_SLOT_CHEST, "CHEST")
    add(EQUIP_SLOT_HAND, "HANDS")
    add(EQUIP_SLOT_WAIST, "WAIST")
    add(EQUIP_SLOT_LEGS, "LEGS")
    add(EQUIP_SLOT_FEET, "FEET")
    add(EQUIP_SLOT_MAIN_HAND, "MAIN HAND")
    add(EQUIP_SLOT_OFF_HAND, "OFF HAND")
    add(EQUIP_SLOT_BACKUP_MAIN, "BACK MAIN")
    add(EQUIP_SLOT_BACKUP_OFF, "BACK OFF")
    return slots
end

function R:Anchor()
    if not self.frame then return end
    self.frame:ClearAnchors()
    local left = tonumber(EPC.saved and EPC.saved.repairCostLeft) or -1
    local top = tonumber(EPC.saved and EPC.saved.repairCostTop) or -1
    if left >= 0 and top >= 0 then
        self.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        self.frame:SetAnchor(RIGHT, GuiRoot, RIGHT, -32, 35)
    end
end

function R:Create()
    local frame = wm:CreateTopLevelWindow("EAS_RepairCostOverlay")
    frame:SetDimensions(410, 98)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)

    local bg = wm:CreateControl("EAS_RepairCostOverlay_BG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.012, 0.015, 0.022, 0.88)
    bg:SetEdgeColor(0.67, 0.51, 0.24, 0.95)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local title = wm:CreateControl("EAS_RepairCostOverlay_Title", frame, CT_LABEL)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 10, 7)
    title:SetAnchor(TOPRIGHT, frame, TOPRIGHT, -10, 7)
    title:SetHeight(22)
    title:SetFont("ZoFontGameBold")
    title:SetColor(0.94, 0.82, 0.44, 1)
    title:SetText("REPAIR / RECHARGE ESTIMATE")

    local subtitle = wm:CreateControl("EAS_RepairCostOverlay_Subtitle", frame, CT_LABEL)
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 0)
    subtitle:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 0)
    subtitle:SetHeight(17)
    subtitle:SetFont("ZoFontGameSmall")
    subtitle:SetColor(0.70, 0.74, 0.80, 1)
    subtitle:SetText("Vendor gold cost by equipped item; weapons recharge with soul gems.")

    local rows = {}
    for i = 1, 11 do
        local row = wm:CreateControl("EAS_RepairCostOverlay_Row" .. tostring(i), frame, CT_CONTROL)
        row:SetAnchor(TOPLEFT, frame, TOPLEFT, 10, 45 + ((i - 1) * 20))
        row:SetDimensions(390, 19)
        row:SetHidden(true)

        local left = wm:CreateControl("EAS_RepairCostOverlay_Row" .. tostring(i) .. "Left", row, CT_LABEL)
        left:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
        left:SetDimensions(276, 19)
        left:SetFont("ZoFontGameSmall")
        left:SetColor(0.91, 0.92, 0.94, 1)
        left:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local right = wm:CreateControl("EAS_RepairCostOverlay_Row" .. tostring(i) .. "Right", row, CT_LABEL)
        right:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, 0)
        right:SetDimensions(110, 19)
        right:SetFont("ZoFontGameSmall")
        right:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        right:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        right:SetColor(0.94, 0.82, 0.44, 1)

        row.epcLeft, row.epcRight = left, right
        rows[i] = row
    end

    local total = wm:CreateControl("EAS_RepairCostOverlay_Total", frame, CT_LABEL)
    total:SetFont("ZoFontGameBold")
    total:SetColor(0.94, 0.82, 0.44, 1)
    total:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local wallet = wm:CreateControl("EAS_RepairCostOverlay_Wallet", frame, CT_LABEL)
    wallet:SetFont("ZoFontGameSmall")
    wallet:SetColor(0.70, 0.74, 0.80, 1)

    local hint = wm:CreateControl("EAS_RepairCostOverlay_Hint", frame, CT_LABEL)
    hint:SetFont("ZoFontGameSmall")
    hint:SetColor(0.94, 0.82, 0.44, 1)
    hint:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    hint:SetText("DRAG TO MOVE")
    hint:SetHidden(true)

    frame:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.repairCostLeft = control:GetLeft()
            EPC.saved.repairCostTop = control:GetTop()
        end
    end)

    self.frame, self.bg, self.title, self.subtitle = frame, bg, title, subtitle
    self.rows, self.total, self.wallet, self.hint = rows, total, wallet, hint
    self:Anchor()
end

function R:BuildRows()
    local result = {}
    local totalCost = 0
    if BAG_WORN == nil then return result, totalCost end

    for _, entry in ipairs(self:GetSlots()) do
        local slot = entry.slot
        local exists = safe(HasItemInSlot, false, BAG_WORN, slot) == true
        if not exists then
            local link = safe(GetItemLink, "", BAG_WORN, slot, LINK_STYLE_DEFAULT or 0)
            exists = link ~= nil and link ~= ""
        end
        if exists then
            local name = itemName(slot)
            local hasDurability = safe(DoesItemHaveDurability, false, BAG_WORN, slot) == true
            local chargeable = safe(IsItemChargeable, false, BAG_WORN, slot) == true
            local condition = hasDurability and (tonumber(safe(GetItemCondition, 100, BAG_WORN, slot)) or 100) or nil
            local repairCost = hasDurability and (tonumber(safe(GetItemRepairCost, 0, BAG_WORN, slot)) or 0) or 0
            if repairCost < 0 then repairCost = 0 end
            totalCost = totalCost + repairCost

            local status = nil
            if hasDurability then
                status = string.format("%d%%  %s", math.max(0, math.min(100, math.floor(condition + 0.5))), moneyText(repairCost))
            elseif chargeable then
                local charge, maxCharge = safe(GetChargeInfoForItem, 0, BAG_WORN, slot)
                charge, maxCharge = tonumber(charge) or 0, tonumber(maxCharge) or 0
                local pct = maxCharge > 0 and math.floor((charge / maxCharge) * 100 + 0.5) or 0
                status = string.format("CHARGE %d%%", math.max(0, math.min(100, pct)))
            else
                -- Keep the overlay focused on repairable armor, shields, and charged weapons.
                status = "0g"
            end

            result[#result + 1] = {
                label = entry.label .. "  " .. (name ~= "" and name or "Equipped item"),
                status = status,
                cost = repairCost,
                durability = hasDurability,
                chargeable = chargeable,
            }
        end
    end

    return result, totalCost
end

function R:IsInventoryOpen()
    if not SCENE_MANAGER or type(SCENE_MANAGER.IsShowing) ~= "function" then return false end
    local scenes = { "inventory", "gamepad_inventory_root" }
    for i = 1, #scenes do
        local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, scenes[i])
        if ok and showing == true then return true end
    end
    return false
end

function R:Refresh()
    if not self.frame or not EPC.saved then return end
    local show = EPC.saved.showRepairCostOverlay ~= false
    if not self.layoutMode then
        local mode = EPC.saved.repairCostVisibility or "INVENTORY"
        if mode == "INVENTORY" then
            show = show and self:IsInventoryOpen()
        else
            show = show
        end
    end
    self.frame:SetHidden(not show)
    if not show then return end

    local data, totalCost = self:BuildRows()
    for i,row in ipairs(self.rows or {}) do
        local item = data[i]
        row:SetHidden(item == nil)
        if item then
            row.epcLeft:SetText(item.label)
            row.epcRight:SetText(item.status)
            if item.cost > 0 then row.epcRight:SetColor(0.94, 0.72, 0.30, 1)
            elseif item.chargeable and not item.durability then row.epcRight:SetColor(0.58, 0.72, 0.96, 1)
            else row.epcRight:SetColor(0.68, 0.76, 0.68, 1) end
        end
    end

    local rowCount = math.max(1, #data)
    local totalY = 45 + (rowCount * 20) + 4
    self.total:ClearAnchors()
    self.total:SetAnchor(TOPRIGHT, self.frame, TOPRIGHT, -10, totalY)
    self.total:SetDimensions(205, 20)
    self.total:SetText("TOTAL REPAIR: " .. moneyText(totalCost))

    local gold = 0
    if CURT_MONEY ~= nil and CURRENCY_LOCATION_CHARACTER ~= nil then
        gold = tonumber(safe(GetCurrencyAmount, 0, CURT_MONEY, CURRENCY_LOCATION_CHARACTER)) or 0
    end
    self.wallet:ClearAnchors()
    self.wallet:SetAnchor(TOPLEFT, self.frame, TOPLEFT, 10, totalY + 1)
    self.wallet:SetDimensions(175, 18)
    self.wallet:SetText("ON HAND: " .. moneyText(gold))

    self.hint:ClearAnchors()
    self.hint:SetAnchor(TOPRIGHT, self.frame, TOPRIGHT, -10, totalY + 22)
    self.hint:SetDimensions(160, 18)

    local height = totalY + 43
    self.frame:SetHeight(math.max(108, height))
    self.frame:SetScale(tonumber(EPC.saved.repairCostScale) or 1.0)

    if self.layoutMode and #data == 0 then
        self.rows[1]:SetHidden(false)
        self.rows[1].epcLeft:SetText("EQUIPPED GEAR")
        self.rows[1].epcRight:SetText("PREVIEW")
    end
end

function R:SetLayoutMode(active)
    self.layoutMode = active == true
    if not self.frame then return end
    self.frame:SetMouseEnabled(self.layoutMode)
    self.frame:SetMovable(self.layoutMode)
    if self.hint then self.hint:SetHidden(not self.layoutMode) end
    self:Refresh()
end

function R:ResetPosition()
    if not EPC.saved then return end
    EPC.saved.repairCostLeft, EPC.saved.repairCostTop = -1, -1
    self:Anchor()
end

function R:Initialize()
    self.layoutMode = false
    self:Create()
    local prefix = EPC.name .. "_RepairCostOverlay"
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then EVENT_MANAGER:RegisterForEvent(prefix .. "_Slot", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId) if bagId == BAG_WORN then self:Refresh() end end) end
    if EVENT_INVENTORY_FULL_UPDATE then EVENT_MANAGER:RegisterForEvent(prefix .. "_Inventory", EVENT_INVENTORY_FULL_UPDATE, function() self:Refresh() end) end
    if EVENT_MONEY_UPDATE then EVENT_MANAGER:RegisterForEvent(prefix .. "_Money", EVENT_MONEY_UPDATE, function() self:Refresh() end) end
    if EVENT_PLAYER_COMBAT_STATE then EVENT_MANAGER:RegisterForEvent(prefix .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function() self:Refresh() end) end
    if EVENT_PLAYER_ACTIVATED then EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function() self:Refresh() end) end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Tick", 1000, function() self:Refresh() end)
    self:Refresh()
end
