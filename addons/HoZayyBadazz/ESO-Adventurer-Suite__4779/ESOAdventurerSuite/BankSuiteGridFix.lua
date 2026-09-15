-- ESO Adventurer Suite
-- v0.29.522 - Suite-style bank Withdraw/Deposit grid.
-- Withdraw renders bank + subscriber-bank items; Deposit renders backpack items.
-- Uses protected RequestMoveItem directly and never passes Suite controls into
-- ESO's native inventory callbacks.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER then return end

local M = {}
EPC.BankSuiteGridFix = M

local wm = WINDOW_MANAGER
local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankSuiteGrid029522"
local CELL, GAP, HEADER_H = 46, 5, 28
local MAX_CELLS = 320

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    if a == nil then return fallback end
    return a, b, c, d
end

local function currentInventoryType()
    return safe(GetCurrentInventoryType, nil)
end

local function atBank()
    if type(IsAtBank) == "function" then return safe(IsAtBank, false) == true end
    if SCENE_MANAGER and type(SCENE_MANAGER.IsShowing) == "function" then
        local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, "bank")
        return ok and showing == true
    end
    return false
end

local function mode()
    if not atBank() then return nil end
    local t = currentInventoryType()
    if t == rawget(_G, "INVENTORY_BANK") then return "WITHDRAW" end
    if t == rawget(_G, "INVENTORY_BACKPACK") then return "DEPOSIT" end
    return nil
end

local function sourceListForMode(m)
    if m == "WITHDRAW" then return rawget(_G, "ZO_PlayerBankBackpack") end
    if m == "DEPOSIT" then return rawget(_G, "ZO_PlayerInventoryList") end
    return nil
end

local function getSearchText(m)
    local box
    if m == "WITHDRAW" then
        box = rawget(_G, "ZO_PlayerBankSearchFiltersTextSearchBox") or rawget(_G, "ZO_PlayerBankSearchFiltersTextSearch")
    else
        box = rawget(_G, "ZO_PlayerInventorySearchFiltersTextSearchBox") or rawget(_G, "ZO_PlayerInventorySearchFiltersTextSearch")
    end
    if box and type(box.GetText) == "function" then
        return string.lower(tostring(safe(box.GetText, "", box) or ""))
    end
    return ""
end

local function classify(link, bag, slot)
    local equipType = tonumber(safe(GetItemLinkEquipType, 0, link)) or 0
    local itemType = tonumber(safe(GetItemType, 0, bag, slot)) or 0
    local weapon = rawget(_G, "EQUIP_TYPE_MAIN_HAND")
    local offhand = rawget(_G, "EQUIP_TYPE_OFF_HAND")
    local twohand = rawget(_G, "EQUIP_TYPE_TWO_HAND")
    if equipType == weapon or equipType == offhand or equipType == twohand then return "WEAPONS", 10 end

    local ring, neck = rawget(_G, "EQUIP_TYPE_RING"), rawget(_G, "EQUIP_TYPE_NECK")
    if equipType == ring or equipType == neck then return "JEWELRY", 30 end

    local armorTypes = {
        [rawget(_G, "EQUIP_TYPE_HEAD")] = true, [rawget(_G, "EQUIP_TYPE_CHEST")] = true,
        [rawget(_G, "EQUIP_TYPE_SHOULDERS")] = true, [rawget(_G, "EQUIP_TYPE_WAIST")] = true,
        [rawget(_G, "EQUIP_TYPE_LEGS")] = true, [rawget(_G, "EQUIP_TYPE_FEET")] = true,
        [rawget(_G, "EQUIP_TYPE_HAND")] = true,
    }
    if armorTypes[equipType] then return "ARMOR", 20 end

    local consumables = {
        [rawget(_G, "ITEMTYPE_FOOD")] = true, [rawget(_G, "ITEMTYPE_DRINK")] = true,
        [rawget(_G, "ITEMTYPE_POTION")] = true, [rawget(_G, "ITEMTYPE_POISON")] = true,
        [rawget(_G, "ITEMTYPE_RECIPE")] = true, [rawget(_G, "ITEMTYPE_CONTAINER")] = true,
    }
    if consumables[itemType] then return "CONSUMABLES", 40 end

    local materials = {
        [rawget(_G, "ITEMTYPE_BLACKSMITHING_MATERIAL")] = true,
        [rawget(_G, "ITEMTYPE_CLOTHIER_MATERIAL")] = true,
        [rawget(_G, "ITEMTYPE_WOODWORKING_MATERIAL")] = true,
        [rawget(_G, "ITEMTYPE_ALCHEMY_BASE")] = true,
        [rawget(_G, "ITEMTYPE_REAGENT")] = true,
        [rawget(_G, "ITEMTYPE_ENCHANTING_RUNE_ASPECT")] = true,
        [rawget(_G, "ITEMTYPE_ENCHANTING_RUNE_ESSENCE")] = true,
        [rawget(_G, "ITEMTYPE_ENCHANTING_RUNE_POTENCY")] = true,
        [rawget(_G, "ITEMTYPE_STYLE_MATERIAL")] = true,
        [rawget(_G, "ITEMTYPE_TRAIT_MATERIAL")] = true,
        [rawget(_G, "ITEMTYPE_RAW_MATERIAL")] = true,
    }
    if materials[itemType] then return "MATERIALS", 50 end
    return "OTHER", 90
end

local function qualityColor(q)
    q = tonumber(q) or 0
    if type(GetInterfaceColor) == "function" and rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS") then
        local r, g, b = safe(GetInterfaceColor, nil, INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, q)
        if r then return r, g, b end
    end
    return 0.35, 0.42, 0.50
end

function M:CollectItems(m)
    local bags = m == "WITHDRAW"
        and {rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK")}
        or {rawget(_G, "BAG_BACKPACK")}
    local search = getSearchText(m)
    local items = {}
    for _, bag in ipairs(bags) do
        if bag ~= nil and type(GetBagSize) == "function" then
            local size = tonumber(safe(GetBagSize, 0, bag)) or 0
            for slot = 0, size - 1 do
                local link = tostring(safe(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
                if link ~= "" then
                    local name = tostring(safe(GetItemName, "", bag, slot) or "")
                    if search == "" or string.find(string.lower(name), search, 1, true) then
                        local icon, stack, _, _, locked, _, _, quality = safe(GetItemInfo, nil, bag, slot)
                        stack = tonumber(stack) or tonumber(safe(GetSlotStackSize, 1, bag, slot)) or 1
                        quality = tonumber(quality) or tonumber(safe(GetItemDisplayQuality, 0, bag, slot)) or 0
                        local group, order = classify(link, bag, slot)
                        items[#items + 1] = {
                            bag=bag, slot=slot, link=link, name=name, icon=tostring(icon or ""),
                            stack=stack, quality=quality, locked=locked == true, group=group, order=order,
                        }
                    end
                end
            end
        end
    end
    table.sort(items, function(a,b)
        if a.order ~= b.order then return a.order < b.order end
        if a.quality ~= b.quality then return a.quality > b.quality end
        return string.lower(a.name) < string.lower(b.name)
    end)
    return items
end

local function findDestination(srcBag, srcSlot, targetBags)
    local srcLink = tostring(safe(GetItemLink, "", srcBag, srcSlot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
    local srcCount = tonumber(safe(GetSlotStackSize, 1, srcBag, srcSlot)) or 1
    for _, bag in ipairs(targetBags) do
        if bag ~= nil and type(GetBagSize) == "function" then
            local size = tonumber(safe(GetBagSize, 0, bag)) or 0
            for slot=0,size-1 do
                local link = tostring(safe(GetItemLink, "", bag, slot, rawget(_G, "LINK_STYLE_DEFAULT") or 0) or "")
                if link ~= "" and link == srcLink then
                    local count, maxStack = safe(GetSlotStackSize, nil, bag, slot)
                    count, maxStack = tonumber(count), tonumber(maxStack)
                    if count and maxStack and count < maxStack then
                        return bag, slot, math.min(srcCount, maxStack - count)
                    end
                end
            end
            if type(FindFirstEmptySlotInBag) == "function" then
                local empty = safe(FindFirstEmptySlotInBag, nil, bag)
                if empty ~= nil then return bag, empty, srcCount end
            end
        end
    end
    return nil
end

function M:MoveItem(item)
    if not item or not atBank() then return end
    local m = mode()
    if not m then return end
    local targets = m == "WITHDRAW"
        and {rawget(_G, "BAG_BACKPACK")}
        or {rawget(_G, "BAG_BANK"), rawget(_G, "BAG_SUBSCRIBER_BANK")}
    local dstBag, dstSlot, count = findDestination(item.bag, item.slot, targets)
    if dstBag == nil or dstSlot == nil then
        if type(ZO_Alert) == "function" then pcall(ZO_Alert, UI_ALERT_CATEGORY_ERROR, nil, "No space available.") end
        return
    end
    count = tonumber(count) or item.stack or 1
    local protected = type(IsProtectedFunction) == "function" and safe(IsProtectedFunction, false, "RequestMoveItem") == true
    if protected and type(CallSecureProtected) == "function" then
        pcall(CallSecureProtected, "RequestMoveItem", item.bag, item.slot, dstBag, dstSlot, count)
    elseif type(RequestMoveItem) == "function" then
        pcall(RequestMoveItem, item.bag, item.slot, dstBag, dstSlot, count)
    end
    if type(zo_callLater) == "function" then zo_callLater(function() if M then M:Refresh(true) end end, 80) end
end

function M:Create()
    if self.frame or not wm.CreateControlFromVirtual then return self.frame end
    local frame = wm:CreateControl("EAS_BankSuiteGrid029522", GuiRoot, CT_CONTROL)
    frame:SetHidden(true)
    frame:SetDrawLayer(DL_OVERLAY)
    frame:SetDrawLevel(20)
    self.frame = frame

    local bg = wm:CreateControl(nil, frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.018, 0.025, 0.035, 0.985)
    bg:SetEdgeColor(0.36, 0.46, 0.58, 0.95)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 1)

    local title = wm:CreateControl(nil, frame, CT_LABEL)
    title:SetFont("ZoFontWinH4")
    title:SetColor(1, 0.82, 0.28, 1)
    title:SetAnchor(TOPLEFT, frame, TOPLEFT, 10, 6)
    title:SetDimensions(400, 24)
    self.title = title

    local scroll = wm:CreateControlFromVirtual("EAS_BankSuiteGridScroll029522", frame, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, frame, TOPLEFT, 6, 34)
    scroll:SetAnchor(BOTTOMRIGHT, frame, BOTTOMRIGHT, -6, -6)
    local child = type(ZO_ScrollContainer_GetScrollChild) == "function" and ZO_ScrollContainer_GetScrollChild(scroll) or nil
    self.scroll, self.child = scroll, child
    self.cells, self.headers = {}, {}
    self.collapsed = {WITHDRAW={}, DEPOSIT={}}
    return frame
end

function M:GetCell(index)
    local c = self.cells[index]
    if c then return c end
    c = wm:CreateControl("EAS_BankGridCell029522_"..tostring(index), self.child, CT_BUTTON)
    c:SetDimensions(CELL, CELL)
    local bg = wm:CreateControl(nil, c, CT_BACKDROP)
    bg:SetAnchorFill(c)
    bg:SetCenterColor(0.05,0.06,0.08,0.985)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,2)
    c.bg = bg
    local icon = wm:CreateControl(nil,c,CT_TEXTURE)
    icon:SetAnchor(TOPLEFT,c,TOPLEFT,3,3); icon:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-3,-3)
    icon:SetTextureCoords(0.04,0.96,0.04,0.96); c.icon=icon
    local count=wm:CreateControl(nil,c,CT_LABEL)
    count:SetFont("ZoFontGameSmall"); count:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-2,-1)
    count:SetDimensions(28,14); count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); c.count=count
    c:SetHandler("OnMouseEnter", function(ctrl)
        if ctrl.item and ItemTooltip and type(InitializeTooltip)=="function" then
            InitializeTooltip(ItemTooltip,ctrl,RIGHT,6,0,LEFT)
            if type(ItemTooltip.SetBagItem)=="function" then pcall(ItemTooltip.SetBagItem,ItemTooltip,ctrl.item.bag,ctrl.item.slot) end
        end
    end)
    c:SetHandler("OnMouseExit", function() if ItemTooltip and type(ClearTooltip)=="function" then pcall(ClearTooltip,ItemTooltip) end end)
    c:SetHandler("OnClicked", function(ctrl) if ctrl.item then M:MoveItem(ctrl.item) end end)
    self.cells[index]=c
    return c
end

function M:GetHeader(index)
    local h=self.headers[index]
    if h then return h end
    h=wm:CreateControl("EAS_BankGridHeader029522_"..tostring(index),self.child,CT_BUTTON)
    h:SetHeight(HEADER_H)
    local bg=wm:CreateControl(nil,h,CT_BACKDROP); bg:SetAnchorFill(h)
    bg:SetCenterColor(0.035,0.055,0.075,0.98); bg:SetEdgeColor(0.28,0.48,0.62,0.95)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,1)
    local label=wm:CreateControl(nil,h,CT_LABEL); label:SetAnchor(TOPLEFT,h,TOPLEFT,8,3); label:SetAnchor(BOTTOMRIGHT,h,BOTTOMRIGHT,-6,-3)
    label:SetFont("ZoFontGameBold"); label:SetColor(0.96,0.84,0.30,1); h.label=label
    h:SetHandler("OnClicked",function(ctrl)
        if not ctrl.mode or not ctrl.group then return end
        M.collapsed[ctrl.mode][ctrl.group]=not (M.collapsed[ctrl.mode][ctrl.group]==true)
        M:Refresh(true)
    end)
    self.headers[index]=h
    return h
end

function M:RestoreNative()
    if self.hiddenNative then
        for control, wasHidden in pairs(self.hiddenNative) do
            if control and type(control.SetHidden)=="function" then pcall(control.SetHidden,control,wasHidden==true) end
        end
    end
    self.hiddenNative={}
end

function M:Refresh(force)
    local m=mode()
    if not m then
        if self.frame then self.frame:SetHidden(true) end
        self:RestoreNative()
        self.lastMode=nil
        return
    end
    local native=sourceListForMode(m)
    if not native or type(native.GetLeft)~="function" then return end
    self:Create()
    if not self.frame or not self.child then return end

    if self.lastMode~=m then self:RestoreNative(); self.lastMode=m; force=true end
    self.hiddenNative=self.hiddenNative or {}
    if self.hiddenNative[native]==nil and type(native.IsHidden)=="function" then self.hiddenNative[native]=safe(native.IsHidden,false,native)==true end
    if type(native.SetHidden)=="function" then pcall(native.SetHidden,native,true) end

    self.frame:ClearAnchors()
    self.frame:SetAnchor(TOPLEFT,native,TOPLEFT,0,0)
    self.frame:SetAnchor(BOTTOMRIGHT,native,BOTTOMRIGHT,0,0)
    self.frame:SetHidden(false)
    self.title:SetText(m=="WITHDRAW" and "WITHDRAW - BANK" or "DEPOSIT - BACKPACK")

    local items=self:CollectItems(m)
    local width=math.max(220,tonumber(safe(native.GetWidth,500,native)) or 500)
    local cols=math.max(4,math.floor((width-18)/(CELL+GAP)))
    local grouped, order={},{}
    for _,item in ipairs(items) do if not grouped[item.group] then grouped[item.group]={}; order[#order+1]=item.group end; grouped[item.group][#grouped[item.group]+1]=item end
    table.sort(order,function(a,b) return (grouped[a][1].order or 90)<(grouped[b][1].order or 90) end)

    local y,hi,ci=2,0,0
    for _,group in ipairs(order) do
        hi=hi+1; local h=self:GetHeader(hi); h:SetHidden(false); h:ClearAnchors(); h:SetAnchor(TOPLEFT,self.child,TOPLEFT,2,y); h:SetWidth(width-20)
        h.mode=m; h.group=group; local collapsed=self.collapsed[m][group]==true
        h.label:SetText((collapsed and "+  " or "-  ")..group.."  ("..tostring(#grouped[group])..")")
        y=y+HEADER_H+GAP
        if not collapsed then
            for i,item in ipairs(grouped[group]) do
                ci=ci+1; if ci>MAX_CELLS then break end
                local c=self:GetCell(ci); c:SetHidden(false); c.item=item; c:ClearAnchors()
                local col=(i-1)%cols; local row=math.floor((i-1)/cols)
                c:SetAnchor(TOPLEFT,self.child,TOPLEFT,2+col*(CELL+GAP),y+row*(CELL+GAP))
                c.icon:SetTexture(item.icon~="" and item.icon or "EsoUI/Art/Icons/icon_missing.dds")
                c.count:SetText(item.stack>1 and tostring(item.stack) or "")
                local r,g,b=qualityColor(item.quality); c.bg:SetEdgeColor(r,g,b,1); c.bg:SetCenterColor(0.05+r*0.16,0.06+g*0.16,0.08+b*0.16,0.985)
            end
            y=y+math.ceil(#grouped[group]/cols)*(CELL+GAP)+GAP
        end
    end
    for i=hi+1,#self.headers do self.headers[i]:SetHidden(true) end
    for i=ci+1,#self.cells do self.cells[i]:SetHidden(true); self.cells[i].item=nil end
    self.child:SetHeight(math.max(y+8,100))
end

function M:Start()
    if not EVENT_MANAGER then return end
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME,150,function() M:Refresh(false) end)
    if EVENT_INVENTORY_SINGLE_SLOT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(UPDATE_NAME.."_Slot",EVENT_INVENTORY_SINGLE_SLOT_UPDATE,function() if atBank() then M:Refresh(true) end end)
    end
    if EVENT_CLOSE_BANK then
        EVENT_MANAGER:RegisterForEvent(UPDATE_NAME.."_Close",EVENT_CLOSE_BANK,function() if M.frame then M.frame:SetHidden(true) end; M:RestoreNative(); M.lastMode=nil end)
    end
end

M:Start()
if type(zo_callLater)=="function" then zo_callLater(function() M:Refresh(true) end,500) end
