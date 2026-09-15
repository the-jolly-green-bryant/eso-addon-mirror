-- ESO Adventurer Suite
-- v0.29.526 - hard bank grid override.
-- Render a Suite-owned icon grid directly over the active bank list rectangle.
-- This avoids depending on ESO/PerfectPixel list ownership or visibility rules.

local EPC = ESOProgressionCoach
if not EPC or not WINDOW_MANAGER or not GuiRoot then return end

local M = {}
EPC.BankGridHardOverride = M

local wm = WINDOW_MANAGER
local UPDATE_NAME = (EPC.name or "ESOAdventurerSuite") .. "_BankGridHardOverride029526"
local CELL, GAP, HEADER_H, MAX_CELLS = 46, 5, 28, 320

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a, b, c, d, e
end

local function isVisible(c)
    return c and type(c.IsHidden) == "function" and safe(c.IsHidden, true, c) == false
end

local function isBankOpen()
    if M.bankOpen == true then return true end
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

local function getInventoryList(invType)
    local inv = rawget(_G, "PLAYER_INVENTORY")
    local data = type(inv) == "table" and type(inv.inventories) == "table" and inv.inventories[invType] or nil
    if type(data) ~= "table" then return nil end
    for _, key in ipairs({"list", "listView", "scrollList"}) do
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
        out[#out + 1] = {mode=mode, control=c}
    end
    add("WITHDRAW", rawget(_G, "ZO_PlayerBankBackpack"))
    add("DEPOSIT", rawget(_G, "ZO_PlayerInventoryList"))
    add("WITHDRAW", getInventoryList(rawget(_G, "INVENTORY_BANK")))
    add("WITHDRAW", getInventoryList(rawget(_G, "INVENTORY_HOUSE_BANK")))
    add("WITHDRAW", getInventoryList(rawget(_G, "INVENTORY_GUILD_BANK")))
    add("DEPOSIT", getInventoryList(rawget(_G, "INVENTORY_BACKPACK")))
    return out
end

local function resolveModeAndRect()
    if not isBankOpen() then return nil end

    local inv = rawget(_G, "PLAYER_INVENTORY")
    local selected = type(inv) == "table" and tonumber(inv.selectedTabType) or nil
    local preferred
    if selected == rawget(_G, "INVENTORY_BACKPACK") then preferred = "DEPOSIT"
    elseif selected == rawget(_G, "INVENTORY_BANK") or selected == rawget(_G, "INVENTORY_HOUSE_BANK") or selected == rawget(_G, "INVENTORY_GUILD_BANK") then preferred = "WITHDRAW" end

    local best
    for _, entry in ipairs(candidateLists()) do
        local c = entry.control
        if isVisible(c) then
            local l, t, r, b = safe(c.GetLeft, nil, c), safe(c.GetTop, nil, c), safe(c.GetRight, nil, c), safe(c.GetBottom, nil, c)
            local w, h = tonumber(r) and tonumber(l) and (r-l) or 0, tonumber(b) and tonumber(t) and (b-t) or 0
            if l and t and w > 250 and h > 150 then
                local score = w*h + ((preferred and preferred == entry.mode) and 100000000 or 0)
                if not best or score > best.score then best={mode=entry.mode, control=c, l=l, t=t, w=w, h=h, score=score} end
            end
        end
    end
    return best
end

local function qualityColor(q)
    q = tonumber(q) or 0
    local ct = rawget(_G, "INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS")
    if type(GetInterfaceColor) == "function" and ct ~= nil then
        local r,g,b = safe(GetInterfaceColor, nil, ct, q)
        if r ~= nil then return r,g,b end
    end
    return 0.35,0.42,0.50
end

local function classify(link, bag, slot)
    local equip = tonumber(safe(GetItemLinkEquipType, 0, link)) or 0
    local itemType = tonumber(safe(GetItemType, 0, bag, slot)) or 0
    if equip == rawget(_G,"EQUIP_TYPE_MAIN_HAND") or equip == rawget(_G,"EQUIP_TYPE_OFF_HAND") or equip == rawget(_G,"EQUIP_TYPE_TWO_HAND") then return "WEAPONS",10 end
    if equip == rawget(_G,"EQUIP_TYPE_RING") or equip == rawget(_G,"EQUIP_TYPE_NECK") then return "JEWELRY",30 end
    local armor = {
        [rawget(_G,"EQUIP_TYPE_HEAD")]=true,[rawget(_G,"EQUIP_TYPE_CHEST")]=true,[rawget(_G,"EQUIP_TYPE_SHOULDERS")]=true,
        [rawget(_G,"EQUIP_TYPE_WAIST")]=true,[rawget(_G,"EQUIP_TYPE_LEGS")]=true,[rawget(_G,"EQUIP_TYPE_FEET")]=true,[rawget(_G,"EQUIP_TYPE_HAND")]=true,
    }
    if armor[equip] then return "ARMOR",20 end
    local cons = {[rawget(_G,"ITEMTYPE_FOOD")]=true,[rawget(_G,"ITEMTYPE_DRINK")]=true,[rawget(_G,"ITEMTYPE_POTION")]=true,[rawget(_G,"ITEMTYPE_POISON")]=true,[rawget(_G,"ITEMTYPE_RECIPE")]=true,[rawget(_G,"ITEMTYPE_CONTAINER")]=true}
    if cons[itemType] then return "CONSUMABLES",40 end
    local mats = {[rawget(_G,"ITEMTYPE_BLACKSMITHING_MATERIAL")]=true,[rawget(_G,"ITEMTYPE_CLOTHIER_MATERIAL")]=true,[rawget(_G,"ITEMTYPE_WOODWORKING_MATERIAL")]=true,[rawget(_G,"ITEMTYPE_REAGENT")]=true,[rawget(_G,"ITEMTYPE_RAW_MATERIAL")]=true,[rawget(_G,"ITEMTYPE_STYLE_MATERIAL")]=true,[rawget(_G,"ITEMTYPE_TRAIT_MATERIAL")]=true,[rawget(_G,"ITEMTYPE_ENCHANTING_RUNE_ASPECT")]=true,[rawget(_G,"ITEMTYPE_ENCHANTING_RUNE_ESSENCE")]=true,[rawget(_G,"ITEMTYPE_ENCHANTING_RUNE_POTENCY")]=true}
    if mats[itemType] then return "MATERIALS",50 end
    return "OTHER",90
end

local function searchText(mode)
    local names = mode == "WITHDRAW" and {"ZO_PlayerBankSearchFiltersTextSearchBox","ZO_PlayerBankSearchFiltersTextSearch"} or {"ZO_PlayerInventorySearchFiltersTextSearchBox","ZO_PlayerInventorySearchFiltersTextSearch"}
    for _, name in ipairs(names) do
        local c = rawget(_G,name)
        if c and type(c.GetText)=="function" then return string.lower(tostring(safe(c.GetText,"",c) or "")) end
    end
    return ""
end

function M:Collect(mode)
    local bags = mode == "WITHDRAW" and {rawget(_G,"BAG_BANK"),rawget(_G,"BAG_SUBSCRIBER_BANK")} or {rawget(_G,"BAG_BACKPACK")}
    local search = searchText(mode)
    local items={}
    for _, bag in ipairs(bags) do
        if bag ~= nil and type(GetBagSize)=="function" then
            local size=tonumber(safe(GetBagSize,0,bag)) or 0
            for slot=0,size-1 do
                local link=tostring(safe(GetItemLink,"",bag,slot,rawget(_G,"LINK_STYLE_DEFAULT") or 0) or "")
                if link~="" then
                    local name=tostring(safe(GetItemName,"",bag,slot) or "")
                    if search=="" or string.find(string.lower(name),search,1,true) then
                        local icon,stack,_,_,locked,_,_,quality=safe(GetItemInfo,nil,bag,slot)
                        stack=tonumber(stack) or tonumber(safe(GetSlotStackSize,1,bag,slot)) or 1
                        quality=tonumber(quality) or tonumber(safe(GetItemDisplayQuality,0,bag,slot)) or 0
                        local group,order=classify(link,bag,slot)
                        items[#items+1]={bag=bag,slot=slot,link=link,name=name,icon=tostring(icon or ""),stack=stack,quality=quality,locked=locked==true,group=group,order=order}
                    end
                end
            end
        end
    end
    table.sort(items,function(a,b) if a.order~=b.order then return a.order<b.order end if a.quality~=b.quality then return a.quality>b.quality end return string.lower(a.name)<string.lower(b.name) end)
    return items
end

local function findDestination(srcBag,srcSlot,targetBags)
    local srcLink=tostring(safe(GetItemLink,"",srcBag,srcSlot,rawget(_G,"LINK_STYLE_DEFAULT") or 0) or "")
    local srcCount=tonumber(safe(GetSlotStackSize,1,srcBag,srcSlot)) or 1
    for _,bag in ipairs(targetBags) do
        if bag~=nil and type(GetBagSize)=="function" then
            local size=tonumber(safe(GetBagSize,0,bag)) or 0
            for slot=0,size-1 do
                local link=tostring(safe(GetItemLink,"",bag,slot,rawget(_G,"LINK_STYLE_DEFAULT") or 0) or "")
                if srcLink~="" and link==srcLink then
                    local count,maxStack=safe(GetSlotStackSize,nil,bag,slot)
                    count,maxStack=tonumber(count),tonumber(maxStack)
                    if count and maxStack and count<maxStack then return bag,slot,math.min(srcCount,maxStack-count) end
                end
            end
            if type(FindFirstEmptySlotInBag)=="function" then
                local empty=safe(FindFirstEmptySlotInBag,nil,bag)
                if empty~=nil then return bag,empty,srcCount end
            end
        end
    end
    return nil
end

function M:Move(item)
    if not item or not isBankOpen() then return end
    if item.locked and self.mode=="DEPOSIT" then return end
    local targets=self.mode=="WITHDRAW" and {rawget(_G,"BAG_BACKPACK")} or {rawget(_G,"BAG_BANK"),rawget(_G,"BAG_SUBSCRIBER_BANK")}
    local db,ds,count=findDestination(item.bag,item.slot,targets)
    if db==nil then if type(ZO_Alert)=="function" then pcall(ZO_Alert,UI_ALERT_CATEGORY_ERROR,nil,"No space available.") end return end
    local protected=type(IsProtectedFunction)=="function" and safe(IsProtectedFunction,false,"RequestMoveItem")==true
    if protected and type(CallSecureProtected)=="function" then pcall(CallSecureProtected,"RequestMoveItem",item.bag,item.slot,db,ds,count or item.stack or 1)
    elseif type(RequestMoveItem)=="function" then pcall(RequestMoveItem,item.bag,item.slot,db,ds,count or item.stack or 1) end
    self.dirty=true
end

function M:Create()
    if self.frame then return end
    local f=wm:CreateControl("EASBankGridHardOverride029526",GuiRoot,CT_CONTROL)
    f:SetHidden(true); f:SetDrawLayer(DL_OVERLAY); f:SetDrawLevel(200); f:SetMouseEnabled(true)
    self.frame=f
    local bg=wm:CreateControl(nil,f,CT_BACKDROP); bg:SetAnchorFill(f); bg:SetCenterColor(0.012,0.018,0.028,1); bg:SetEdgeColor(0.30,0.42,0.56,1); bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,1)
    local scroll=wm:CreateControlFromVirtual("EASBankGridHardScroll029526",f,"ZO_ScrollContainer"); scroll:SetAnchorFill(f)
    self.child=type(ZO_ScrollContainer_GetScrollChild)=="function" and ZO_ScrollContainer_GetScrollChild(scroll) or scroll:GetNamedChild("ScrollChild")
    self.cells={}; self.headers={}; self.collapsed={WITHDRAW={},DEPOSIT={}}
end

function M:GetCell(i)
    local c=self.cells[i]; if c then return c end
    c=wm:CreateControl("EASBankHardCell029526_"..i,self.child,CT_BUTTON); c:SetDimensions(CELL,CELL); c:SetHidden(true)
    local bg=wm:CreateControl(nil,c,CT_BACKDROP); bg:SetAnchorFill(c); bg:SetCenterColor(0.05,0.06,0.08,1); bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,2); c.bg=bg
    local icon=wm:CreateControl(nil,c,CT_TEXTURE); icon:SetAnchor(TOPLEFT,c,TOPLEFT,3,3); icon:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-3,-3); icon:SetTextureCoords(0.05,0.95,0.05,0.95); c.icon=icon
    local count=wm:CreateControl(nil,c,CT_LABEL); count:SetFont("ZoFontGameSmall"); count:SetAnchor(BOTTOMRIGHT,c,BOTTOMRIGHT,-2,-1); count:SetDimensions(28,14); count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT); c.count=count
    c:SetHandler("OnMouseEnter",function(ctrl) if ctrl.item and ItemTooltip and type(InitializeTooltip)=="function" then InitializeTooltip(ItemTooltip,ctrl,RIGHT,6,0,LEFT); if type(ItemTooltip.SetBagItem)=="function" then pcall(ItemTooltip.SetBagItem,ItemTooltip,ctrl.item.bag,ctrl.item.slot) end end end)
    c:SetHandler("OnMouseExit",function() if ItemTooltip and type(ClearTooltip)=="function" then pcall(ClearTooltip,ItemTooltip) end end)
    c:SetHandler("OnClicked",function(ctrl) if ctrl.item then M:Move(ctrl.item) end end)
    self.cells[i]=c; return c
end

function M:GetHeader(i)
    local h=self.headers[i]; if h then return h end
    h=wm:CreateControl("EASBankHardHeader029526_"..i,self.child,CT_BUTTON); h:SetHeight(HEADER_H); h:SetHidden(true)
    local bg=wm:CreateControl(nil,h,CT_BACKDROP); bg:SetAnchorFill(h); bg:SetCenterColor(0.025,0.045,0.065,1); bg:SetEdgeColor(0.26,0.44,0.58,1); bg:SetEdgeTexture("EsoUI/Art/Miscellaneous/white_1x1.dds",1,1,1)
    local label=wm:CreateControl(nil,h,CT_LABEL); label:SetAnchor(TOPLEFT,h,TOPLEFT,8,3); label:SetAnchor(BOTTOMRIGHT,h,BOTTOMRIGHT,-6,-3); label:SetFont("ZoFontGameBold"); label:SetColor(1,0.82,0.26,1); h.label=label
    h:SetHandler("OnClicked",function(ctrl) if ctrl.group and M.mode then M.collapsed[M.mode][ctrl.group]=not (M.collapsed[M.mode][ctrl.group]==true); M.dirty=true end end)
    self.headers[i]=h; return h
end

function M:Render(info)
    self:Create()
    self.mode=info.mode
    self.frame:ClearAnchors(); self.frame:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,info.l,info.t); self.frame:SetDimensions(info.w,info.h); self.frame:SetHidden(false)
    local items=self:Collect(info.mode)
    local grouped,order={},{}
    for _,it in ipairs(items) do if not grouped[it.group] then grouped[it.group]={}; order[#order+1]=it.group end; grouped[it.group][#grouped[it.group]+1]=it end
    table.sort(order,function(a,b) return (grouped[a][1].order or 90)<(grouped[b][1].order or 90) end)
    local cols=math.max(4,math.floor((info.w-14)/(CELL+GAP)))
    local y,hi,ci=2,0,0
    for _,group in ipairs(order) do
        hi=hi+1; local h=self:GetHeader(hi); h:SetHidden(false); h:ClearAnchors(); h:SetAnchor(TOPLEFT,self.child,TOPLEFT,2,y); h:SetWidth(info.w-16); h.group=group
        local collapsed=self.collapsed[info.mode][group]==true; h.label:SetText((collapsed and "+  " or "-  ")..group.."  ("..#grouped[group]..")"); y=y+HEADER_H+GAP
        if not collapsed then
            for i,it in ipairs(grouped[group]) do
                ci=ci+1; if ci>MAX_CELLS then break end
                local c=self:GetCell(ci); c:SetHidden(false); c.item=it; c:ClearAnchors(); local col=(i-1)%cols; local row=math.floor((i-1)/cols); c:SetAnchor(TOPLEFT,self.child,TOPLEFT,2+col*(CELL+GAP),y+row*(CELL+GAP)); c.icon:SetTexture(it.icon~="" and it.icon or "EsoUI/Art/Icons/icon_missing.dds"); c.count:SetText(it.stack>1 and tostring(it.stack) or ""); local r,g,b=qualityColor(it.quality); c.bg:SetEdgeColor(r,g,b,1); c.bg:SetCenterColor(0.04+r*0.16,0.05+g*0.16,0.07+b*0.16,1)
            end
            y=y+math.ceil(#grouped[group]/cols)*(CELL+GAP)+GAP
        end
    end
    for i=hi+1,#self.headers do self.headers[i]:SetHidden(true) end
    for i=ci+1,#self.cells do self.cells[i]:SetHidden(true); self.cells[i].item=nil end
    self.child:SetHeight(math.max(y+8,info.h))
    self.lastSignature=info.mode..":"..math.floor(info.l)..":"..math.floor(info.t)..":"..math.floor(info.w)..":"..math.floor(info.h)..":"..searchText(info.mode)..":"..#items
    self.dirty=false
end

function M:Tick()
    local info=resolveModeAndRect()
    if not info then if self.frame then self.frame:SetHidden(true) end; self.lastSignature=nil; return end
    local sig=info.mode..":"..math.floor(info.l)..":"..math.floor(info.t)..":"..math.floor(info.w)..":"..math.floor(info.h)..":"..searchText(info.mode)
    if self.dirty or not self.lastSignature or string.sub(self.lastSignature,1,#sig)~=sig then self:Render(info) end
end

if EVENT_MANAGER then
    if rawget(_G,"EVENT_OPEN_BANK") then EVENT_MANAGER:RegisterForEvent(UPDATE_NAME.."Open",EVENT_OPEN_BANK,function() M.bankOpen=true; M.dirty=true; if type(zo_callLater)=="function" then zo_callLater(function() M:Tick() end,50) end end) end
    if rawget(_G,"EVENT_CLOSE_BANK") then EVENT_MANAGER:RegisterForEvent(UPDATE_NAME.."Close",EVENT_CLOSE_BANK,function() M.bankOpen=false; if M.frame then M.frame:SetHidden(true) end; M.lastSignature=nil end) end
    if rawget(_G,"EVENT_INVENTORY_SINGLE_SLOT_UPDATE") then EVENT_MANAGER:RegisterForEvent(UPDATE_NAME.."Slot",EVENT_INVENTORY_SINGLE_SLOT_UPDATE,function() if isBankOpen() then M.dirty=true end end) end
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME,120,function() M:Tick() end)
end
