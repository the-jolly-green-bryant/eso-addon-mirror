-- ESO Adventurer Suite
-- v0.29.533 - unified bank grid.
-- One owner, one frame, one update loop. Replaces the layered bank override chain.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER or not GuiRoot or not EVENT_MANAGER then return end

local U = { open = false, dirty = true, collapsed = { WITHDRAW = {}, DEPOSIT = {} }, cells = {}, headers = {} }
EPC.BankGridUnified = U

local wm = WINDOW_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankGridUnified029533"
local CELL, GAP, HEADER_H, MAX_CELLS = 48, 5, 28, 320

local function first(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a
end

local function numberFirst(fn, fallback, ...)
    local v = first(fn, fallback, ...)
    return tonumber(v)
end

local function isBankOpen()
    if U.open then return true end
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) == "table" then
        if type(inv.IsBanking) == "function" then
            local ok, v = pcall(inv.IsBanking, inv)
            if ok and v == true then return true end
        end
        if type(inv.IsGuildBanking) == "function" then
            local ok, v = pcall(inv.IsGuildBanking, inv)
            if ok and v == true then return true end
        end
    end
    return false
end

local function inventoryList(invType)
    local inv = rawget(_G, "PLAYER_INVENTORY")
    if type(inv) ~= "table" or type(inv.inventories) ~= "table" or invType == nil then return nil end
    local data = inv.inventories[invType]
    if type(data) ~= "table" then return nil end
    for _, key in ipairs({ "list", "listView", "scrollList" }) do
        local c = data[key]
        if c and type(c.GetLeft) == "function" then return c end
    end
    return nil
end

local function candidateLists()
    local out, seen = {}, {}
    local function add(mode, c)
        if not c or seen[c] or type(c.GetLeft) ~= "function" then return end
        seen[c] = true
        out[#out + 1] = { mode = mode, control = c }
    end
    add("WITHDRAW", rawget(_G, "ZO_PlayerBankBackpack"))
    add("DEPOSIT", rawget(_G, "ZO_PlayerInventoryList"))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_BANK")))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_HOUSE_BANK")))
    add("WITHDRAW", inventoryList(rawget(_G, "INVENTORY_GUILD_BANK")))
    add("DEPOSIT", inventoryList(rawget(_G, "INVENTORY_BACKPACK")))
    return out
end

local function selectedMode()
    local inv = rawget(_G, "PLAYER_INVENTORY")
    local selected = type(inv) == "table" and tonumber(inv.selectedTabType) or nil
    if selected == rawget(_G, "INVENTORY_BACKPACK") then return "DEPOSIT" end
    if selected == rawget(_G, "INVENTORY_BANK") or selected == rawget(_G, "INVENTORY_HOUSE_BANK") or selected == rawget(_G, "INVENTORY_GUILD_BANK") then return "WITHDRAW" end
    return nil
end

local function resolvePane()
    if not isBankOpen() then return nil end
    local preferred = selectedMode()
    local best
    for _, e in ipairs(candidateLists()) do
        local c = e.control
        if c and type(c.IsHidden) == "function" and first(c.IsHidden, true, c) == false then
            local l, t = numberFirst(c.GetLeft, nil, c), numberFirst(c.GetTop, nil, c)
            local r, b = numberFirst(c.GetRight, nil, c), numberFirst(c.GetBottom, nil, c)
            if l and t and r and b then
                local w, h = r - l, b - t
                if w > 250 and h > 150 then
                    local score = w * h + ((preferred == e.mode) and 100000000 or 0)
                    if not best or score > best.score then best = { mode=e.mode, control=c, l=l, t=t, w=w, h=h, score=score } end
                end
            end
        end
    end
    return best
end

local function same(value, ...)
    for i = 1, select("#", ...) do
        local v = select(i, ...)
        if v ~= nil and value == v then return true end
    end
    return false
end

local function classify(link, bag, slot)
    local equip = numberFirst(GetItemLinkEquipType, 0, link) or 0
    local itemType = numberFirst(GetItemType, 0, bag, slot) or 0
    if same(equip, rawget(_G,"EQUIP_TYPE_MAIN_HAND"), rawget(_G,"EQUIP_TYPE_OFF_HAND"), rawget(_G,"EQUIP_TYPE_TWO_HAND"), rawget(_G,"EQUIP_TYPE_ONE_HAND")) then return "WEAPONS", 10 end
    if same(equip, rawget(_G,"EQUIP_TYPE_RING"), rawget(_G,"EQUIP_TYPE_NECK")) then return "JEWELRY", 30 end
    if same(equip, rawget(_G,"EQUIP_TYPE_HEAD"), rawget(_G,"EQUIP_TYPE_CHEST"), rawget(_G,"EQUIP_TYPE_SHOULDERS"), rawget(_G,"EQUIP_TYPE_WAIST"), rawget(_G,"EQUIP_TYPE_LEGS"), rawget(_G,"EQUIP_TYPE_FEET"), rawget(_G,"EQUIP_TYPE_HAND")) then return "ARMOR", 20 end
    if same(itemType, rawget(_G,"ITEMTYPE_FOOD"), rawget(_G,"ITEMTYPE_DRINK"), rawget(_G,"ITEMTYPE_POTION"), rawget(_G,"ITEMTYPE_POISON"), rawget(_G,"ITEMTYPE_RECIPE"), rawget(_G,"ITEMTYPE_CONTAINER")) then return "CONSUMABLES", 40 end
    if same(itemType, rawget(_G,"ITEMTYPE_BLACKSMITHING_MATERIAL"), rawget(_G,"ITEMTYPE_CLOTHIER_MATERIAL"), rawget(_G,"ITEMTYPE_WOODWORKING_MATERIAL"), rawget(_G,"ITEMTYPE_REAGENT"), rawget(_G,"ITEMTYPE_RAW_MATERIAL"), rawget(_G,"ITEMTYPE_STYLE_MATERIAL"), rawget(_G,"ITEMTYPE_TRAIT_MATERIAL"), rawget(_G,"ITEMTYPE_ENCHANTING_RUNE_ASPECT"), rawget(_G,"ITEMTYPE_ENCHANTING_RUNE_ESSENCE"), rawget(_G,"ITEMTYPE_ENCHANTING_RUNE_POTENCY")) then return "MATERIALS", 50 end
    return "OTHER", 90
end

local function qualityColor(q)
    q = tonumber(q) or 0
    local ct = rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS")
    if type(GetInterfaceColor) == "function" and ct ~= nil then
        local ok, r, g, b = pcall(GetInterfaceColor, ct, q)
        if ok and r ~= nil then return r, g, b end
    end
    return 0.35, 0.42, 0.50
end

local function searchText(mode)
    local names = mode == "WITHDRAW"
        and { "ZO_PlayerBankSearchFiltersTextSearchBox", "ZO_PlayerBankSearchFiltersTextSearch" }
        or { "ZO_PlayerInventorySearchFiltersTextSearchBox", "ZO_PlayerInventorySearchFiltersTextSearch" }
    for _, name in ipairs(names) do
        local c = rawget(_G, name)
        if c and type(c.GetText) == "function" then return string.lower(tostring(first(c.GetText, "", c) or "")) end
    end
    return ""
end

function U:Collect(mode)
    local bags = mode == "WITHDRAW" and { rawget(_G,"BAG_BANK"), rawget(_G,"BAG_SUBSCRIBER_BANK") } or { rawget(_G,"BAG_BACKPACK") }
    local search = searchText(mode)
    local items = {}
    for _, bag in ipairs(bags) do
        if bag ~= nil and type(GetBagSize) == "function" then
            local size = numberFirst(GetBagSize, 0, bag) or 0
            for slot = 0, size - 1 do
                local link = tostring(first(GetItemLink, "", bag, slot, rawget(_G,"LINK_STYLE_DEFAULT") or 0) or "")
                if link ~= "" then
                    local name = tostring(first(GetItemName, "", bag, slot) or "")
                    if search == "" or string.find(string.lower(name), search, 1, true) then
                        local icon, stack, _, _, locked, _, _, quality
                        if type(GetItemInfo) == "function" then
                            local ok
                            ok, icon, stack, _, _, locked, _, _, quality = pcall(GetItemInfo, bag, slot)
                            if not ok then icon, stack, locked, quality = nil, nil, false, nil end
                        end
                        stack = tonumber(stack) or numberFirst(GetSlotStackSize, 1, bag, slot) or 1
                        quality = tonumber(quality) or numberFirst(GetItemDisplayQuality, 0, bag, slot) or 0
                        local group, order = classify(link, bag, slot)
                        items[#items+1] = { bag=bag, slot=slot, link=link, name=name, icon=tostring(icon or ""), stack=stack, quality=quality, locked=locked==true, group=group, order=order }
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

local function destination(srcBag, srcSlot, targets)
    local srcCount = numberFirst(GetSlotStackSize, 1, srcBag, srcSlot) or 1
    for _, bag in ipairs(targets) do
        if bag ~= nil and type(FindFirstEmptySlotInBag) == "function" then
            local empty = first(FindFirstEmptySlotInBag, nil, bag)
            if empty ~= nil then return bag, empty, srcCount end
        end
    end
    return nil
end

function U:Move(item)
    if not item or not isBankOpen() then return end
    if item.locked and self.mode == "DEPOSIT" then return end
    local targets = self.mode == "WITHDRAW" and { rawget(_G,"BAG_BACKPACK") } or { rawget(_G,"BAG_BANK"), rawget(_G,"BAG_SUBSCRIBER_BANK") }
    local db, ds, count = destination(item.bag, item.slot, targets)
    if db == nil then return end
    local protected = false
    if type(IsProtectedFunction) == "function" then
        local ok, v = pcall(IsProtectedFunction, "RequestMoveItem")
        protected = ok and v == true
    end
    if protected and type(CallSecureProtected) == "function" then
        pcall(CallSecureProtected, "RequestMoveItem", item.bag, item.slot, db, ds, count or item.stack or 1)
    elseif type(RequestMoveItem) == "function" then
        pcall(RequestMoveItem, item.bag, item.slot, db, ds, count or item.stack or 1)
    end
    self.dirty = true
end

function U:Create()
    if self.root then return end
    local root = wm:CreateControl("EASBankUnifiedRoot029533", GuiRoot, CT_CONTROL)
    root:SetHidden(true)
    root:SetMouseEnabled(true)
    root:SetAlpha(1)
    if root.SetDrawTier and rawget(_G,"DT_HIGH") ~= nil then root:SetDrawTier(DT_HIGH) end
    if root.SetDrawLayer and rawget(_G,"DL_OVERLAY") ~= nil then root:SetDrawLayer(DL_OVERLAY) end
    root:SetDrawLevel(5000)
    self.root = root

    local bg = wm:CreateControl(nil, root, CT_BACKDROP)
    bg:SetAnchorFill(root)
    bg:SetCenterColor(0.015, 0.02, 0.03, 1)
    bg:SetEdgeColor(0.55, 0.42, 0.16, 1)
    bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds", 1, 1, 2)
    bg:SetAlpha(1)
    self.bg = bg

    local title = wm:CreateControl(nil, root, CT_LABEL)
    title:SetAnchor(TOPLEFT, root, TOPLEFT, 8, 5)
    title:SetDimensions(520, 24)
    title:SetFont("ZoFontWinH4")
    title:SetColor(1, 0.82, 0.26, 1)
    title:SetText("ESO ADVENTURER SUITE BANK")
    title:SetAlpha(1)
    self.title = title

    root:SetHandler("OnMouseWheel", function(_, delta)
        self.scroll = math.max(0, (tonumber(self.scroll) or 0) - (tonumber(delta) or 0) * 100)
        self.dirty = true
    end)
end

function U:GetHeader(i)
    local h = self.headers[i]
    if h then return h end
    h = wm:CreateControl("EASBankUnifiedHeader029533_"..i, self.root, CT_BUTTON)
    h:SetHeight(HEADER_H); h:SetMouseEnabled(true); h:SetAlpha(1)
    local bg = wm:CreateControl(nil, h, CT_BACKDROP); bg:SetAnchorFill(h); bg:SetCenterColor(0.035,0.055,0.08,1); bg:SetEdgeColor(0.35,0.45,0.55,1); bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,1); bg:SetAlpha(1); h.bg=bg
    local label = wm:CreateControl(nil, h, CT_LABEL); label:SetAnchor(TOPLEFT,h,TOPLEFT,8,3); label:SetAnchor(BOTTOMRIGHT,h,BOTTOMRIGHT,-4,-3); label:SetFont("ZoFontGameBold"); label:SetColor(1,0.82,0.26,1); label:SetAlpha(1); h.label=label
    h:SetHandler("OnClicked", function(ctrl) if ctrl.group and self.mode then self.collapsed[self.mode][ctrl.group] = not (self.collapsed[self.mode][ctrl.group] == true); self.dirty=true end end)
    self.headers[i] = h
    return h
end

function U:GetCell(i)
    local c = self.cells[i]
    if c then return c end
    c = wm:CreateControl("EASBankUnifiedCell029533_"..i, self.root, CT_BUTTON)
    c:SetDimensions(CELL,CELL); c:SetMouseEnabled(true); c:SetAlpha(1)
    local bg = wm:CreateControl(nil,c,CT_BACKDROP); bg:SetAnchorFill(c); bg:SetCenterColor(0.06,0.07,0.09,1); bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,2); bg:SetAlpha(1); c.bg=bg
    local icon = wm:CreateControl(nil,c,CT_TEXTURE); icon:SetAnchor(TOPLEFT,c,TOPLEFT,3,3); icon:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-3,-3); icon:SetTextureCoords(0.05,0.95,0.05,0.95); icon:SetColor(1,1,1,1); icon:SetAlpha(1); c.icon=icon
    local count = wm:CreateControl(nil,c,CT_LABEL); count:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-2,-1); count:SetDimensions(28,14); count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); count:SetFont("ZoFontGameSmall"); count:SetColor(1,1,1,1); count:SetAlpha(1); c.count=count
    c:SetHandler("OnMouseEnter", function(ctrl) if ctrl.item and ItemTooltip and type(InitializeTooltip)=="function" then InitializeTooltip(ItemTooltip,ctrl,LEFT,-8,0,RIGHT); if type(ItemTooltip.SetBagItem)=="function" then pcall(ItemTooltip.SetBagItem,ItemTooltip,ctrl.item.bag,ctrl.item.slot) end end end)
    c:SetHandler("OnMouseExit", function() if ItemTooltip and type(ClearTooltip)=="function" then pcall(ClearTooltip,ItemTooltip) end end)
    c:SetHandler("OnClicked", function(ctrl) if ctrl.item then self:Move(ctrl.item) end end)
    self.cells[i] = c
    return c
end

local function restoreNative(c)
    if not c then return end
    if type(c.SetAlpha)=="function" then pcall(c.SetAlpha,c,1) end
    if type(c.SetMouseEnabled)=="function" then pcall(c.SetMouseEnabled,c,true) end
end

function U:Render(info)
    self:Create()
    self.mode = info.mode
    self.root:ClearAnchors()
    self.root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, info.l, info.t)
    self.root:SetDimensions(info.w, info.h)
    self.root:SetAlpha(1)
    self.root:SetHidden(false)
    self.title:SetText("ESO ADVENTURER SUITE — " .. info.mode)

    local items = self:Collect(info.mode)
    if #items == 0 then self.root:SetHidden(true); return false end

    local groups, order = {}, {}
    for _, it in ipairs(items) do
        if not groups[it.group] then groups[it.group]={}; order[#order+1]=it.group end
        groups[it.group][#groups[it.group]+1]=it
    end
    table.sort(order,function(a,b) return (groups[a][1].order or 90) < (groups[b][1].order or 90) end)

    local cols = math.max(4, math.floor((info.w - 16) / (CELL + GAP)))
    local y = 34 - (tonumber(self.scroll) or 0)
    local hi, ci = 0, 0
    for _, group in ipairs(order) do
        hi=hi+1
        local h=self:GetHeader(hi); h:SetHidden(false); h:SetAlpha(1); h:ClearAnchors(); h:SetAnchor(TOPLEFT,self.root,TOPLEFT,4,y); h:SetWidth(info.w-12); h.group=group
        local collapsed=self.collapsed[info.mode][group]==true
        h.label:SetText((collapsed and "+  " or "-  ")..group.."  ("..#groups[group]..")")
        y=y+HEADER_H+GAP
        if not collapsed then
            local rowCount=0
            for i,it in ipairs(groups[group]) do
                ci=ci+1; if ci>MAX_CELLS then break end
                local c=self:GetCell(ci); c:SetHidden(false); c:SetAlpha(1); c.item=it; c:ClearAnchors()
                local col=(i-1)%cols; local row=math.floor((i-1)/cols); rowCount=math.max(rowCount,row+1)
                c:SetAnchor(TOPLEFT,self.root,TOPLEFT,4+col*(CELL+GAP),y+row*(CELL+GAP))
                c.icon:SetTexture(it.icon~="" and it.icon or "EsoUI/Art/Icons/icon_missing.dds"); c.icon:SetAlpha(1); c.icon:SetColor(1,1,1,1)
                c.count:SetText(it.stack>1 and tostring(it.stack) or ""); c.count:SetAlpha(1)
                local r,g,b=qualityColor(it.quality); c.bg:SetEdgeColor(r,g,b,1); c.bg:SetCenterColor(0.05+r*0.15,0.06+g*0.15,0.08+b*0.15,1); c.bg:SetAlpha(1)
            end
            y=y+rowCount*(CELL+GAP)+GAP
        end
    end
    for i=hi+1,#self.headers do self.headers[i]:SetHidden(true) end
    for i=ci+1,#self.cells do self.cells[i]:SetHidden(true); self.cells[i].item=nil end
    return hi>0 and ci>0
end

function U:Refresh()
    for _,e in ipairs(candidateLists()) do restoreNative(e.control) end
    if not isBankOpen() then if self.root then self.root:SetHidden(true) end return end
    local info=resolvePane()
    if not info then if self.root then self.root:SetHidden(true) end return end
    local ok, visible=pcall(self.Render,self,info)
    if not ok or visible~=true then if self.root then self.root:SetHidden(true) end return end
    -- Only now hide ESO rows; Suite visuals are already created and shown.
    if type(info.control.SetAlpha)=="function" then pcall(info.control.SetAlpha,info.control,0) end
    if type(info.control.SetMouseEnabled)=="function" then pcall(info.control.SetMouseEnabled,info.control,false) end
    self.dirty=false
end

EVENT_MANAGER:RegisterForUpdate(NAME, 150, function() U:Refresh() end)
if rawget(_G,"EVENT_OPEN_BANK") then EVENT_MANAGER:RegisterForEvent(NAME.."Open",EVENT_OPEN_BANK,function() U.open=true; U.dirty=true; if zo_callLater then zo_callLater(function() U:Refresh() end,50) end end) end
if rawget(_G,"EVENT_CLOSE_BANK") then EVENT_MANAGER:RegisterForEvent(NAME.."Close",EVENT_CLOSE_BANK,function() U.open=false; for _,e in ipairs(candidateLists()) do restoreNative(e.control) end; if U.root then U.root:SetHidden(true) end end) end
if rawget(_G,"EVENT_INVENTORY_SINGLE_SLOT_UPDATE") then EVENT_MANAGER:RegisterForEvent(NAME.."Slot",EVENT_INVENTORY_SINGLE_SLOT_UPDATE,function() if isBankOpen() then U.dirty=true end end) end
