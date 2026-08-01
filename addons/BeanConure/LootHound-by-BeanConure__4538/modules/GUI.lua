LootHound.GUI = {}
local GUI = LootHound.GUI

-- Configuration
local AUTHOR_USERID = "@BeanConure"
local WIN_W, WIN_H, HDR_H, TAB_H = 920, 580, 52, 32
local ICON_S, ICON_P = 46, 6
local CELL = ICON_S + ICON_P

-- Color Palette
local BG_DARK   = { r=0.05, g=0.05, b=0.05, a=0.85 } 
local BORDER    = { r=0.4,  g=0.35, b=0.2,  a=0.6 }  
local TEXT_GOLD = { r=0.9,  g=0.8,  b=0.5,  a=1 }    
local TEXT_WHT  = { r=1,    g=1,    b=1,    a=1 }    

-- These tables define the interactive icons in the "Add Pieces" tab.
-- They map a texture to a specific ESO EQUIP_TYPE requirement.
local ARMOUR_SLOTS = {
    { id="a_head", label="Head", tex="EsoUI/Art/icons/gear_breton_heavy_head_d.dds", equip=EQUIP_TYPE_HEAD },
    { id="a_shld", label="Shld", tex="EsoUI/Art/icons/gear_breton_heavy_shoulders_d.dds", equip=EQUIP_TYPE_SHOULDERS },
    { id="a_chst", label="Chest", tex="EsoUI/Art/icons/gear_breton_heavy_chest_d.dds", equip=EQUIP_TYPE_CHEST },
    { id="a_hnd",  label="Hands", tex="EsoUI/Art/icons/gear_breton_heavy_hands_d.dds", equip=EQUIP_TYPE_HAND },
    { id="a_wst",  label="Waist", tex="EsoUI/Art/icons/gear_breton_heavy_waist_d.dds", equip=EQUIP_TYPE_WAIST },
    { id="a_leg",  label="Legs", tex="EsoUI/Art/icons/gear_breton_heavy_legs_d.dds", equip=EQUIP_TYPE_LEGS },
    { id="a_feet", label="Feet", tex="EsoUI/Art/icons/gear_breton_heavy_feet_d.dds", equip=EQUIP_TYPE_FEET },
    { id="a_shd",  label="Shield", tex="EsoUI/Art/icons/gear_breton_shield_d.dds", weap=WEAPONTYPE_SHIELD, equip=EQUIP_TYPE_OFF_HAND },
}

local WEAPON_SLOTS = {
    { id="w_dag",  label="Dag", tex="EsoUI/Art/icons/gear_breton_dagger_a.dds", weap=WEAPONTYPE_DAGGER, equip=EQUIP_TYPE_ONE_HAND },
    { id="w_sw",   label="Swd", tex="EsoUI/Art/icons/gear_breton_1hsword_a.dds", weap=WEAPONTYPE_SWORD, equip=EQUIP_TYPE_ONE_HAND },
    { id="w_axe",  label="Axe", tex="EsoUI/Art/icons/gear_breton_1haxe_a.dds", weap=WEAPONTYPE_AXE, equip=EQUIP_TYPE_ONE_HAND },
    { id="w_mace", label="Mace", tex="EsoUI/Art/icons/gear_akaviri_mace_c.dds", weap=WEAPONTYPE_MACE, equip=EQUIP_TYPE_ONE_HAND }, 
    { id="w_2hsw", label="2H Sw", tex="EsoUI/Art/icons/gear_breton_2hsword_a.dds", weap=WEAPONTYPE_TWO_HANDED_SWORD, equip=EQUIP_TYPE_TWO_HAND },
    { id="w_2hax", label="2H Ax", tex="EsoUI/Art/icons/gear_breton_2haxe_a.dds", weap=WEAPONTYPE_TWO_HANDED_AXE, equip=EQUIP_TYPE_TWO_HAND },
    { id="w_maul", label="Maul", tex="EsoUI/Art/icons/gear_breton_2hhammer_e.dds", weap=WEAPONTYPE_TWO_HANDED_MAUL, equip=EQUIP_TYPE_TWO_HAND }, 
    { id="w_bow",  label="Bow", tex="EsoUI/Art/icons/gear_breton_bow_a.dds", weap=WEAPONTYPE_BOW, equip=EQUIP_TYPE_TWO_HAND },
    { id="w_fire", label="Fire", tex="EsoUI/Art/icons/gear_breton_staff_a.dds", weap=WEAPONTYPE_FIRE_STAFF, equip=EQUIP_TYPE_TWO_HAND },
    { id="w_shk",  label="Shk", tex="EsoUI/Art/icons/gear_altmer_staff_a.dds", weap=WEAPONTYPE_LIGHTNING_STAFF, equip=EQUIP_TYPE_TWO_HAND },
    { id="w_ice",  label="Ice", tex="EsoUI/Art/icons/gear_nord_staff_a.dds", weap=WEAPONTYPE_FROST_STAFF, equip=EQUIP_TYPE_TWO_HAND },
    { id="w_rest", label="Resto", tex="EsoUI/Art/icons/gear_argonian_staff_a.dds", weap=WEAPONTYPE_HEALING_STAFF, equip=EQUIP_TYPE_TWO_HAND },
}

local JEWEL_SLOTS = {
    { id="j_nck",  label="Neck", tex="EsoUI/Art/icons/gear_breton_neck_d.dds", equip=EQUIP_TYPE_NECK },
    { id="j_rg1",  label="Ring1", tex="EsoUI/Art/icons/gear_breton_ring_d.dds", equip=EQUIP_TYPE_RING },
    { id="j_rg2",  label="Ring2", tex="EsoUI/Art/icons/gear_breton_ring_d.dds", equip=EQUIP_TYPE_RING },
}

-- Tracks what is clicked vs unclicked
local state = { mainTab="build", selected={}, wlSelected={}, setId=nil, setLabel="No Set", groupTraits={ armor=-1, weapon=-1, jewelry=-1 }, groupQuals={ armor=0, weapon=0, jewelry=0 }, armourType=0 }

-- UI Control References
local win, statusLabel, summaryLbl, iconBtns, tabBtns = nil, nil, nil, {}, {}
local buildPanel, wlPanel, wlInner, wlRowPool = nil, nil, nil, {}


-- Generates a Backdrop UI element (Boxes/Backgrounds)
local function BD(p, x, y, w, h, r, g, b, a, et)
    local c = WINDOW_MANAGER:CreateControl(nil, p, CT_BACKDROP)
    c:SetAnchor(TOPLEFT, p, TOPLEFT, x, y)
    c:SetDimensions(w, h)
    c:SetCenterColor(r, g, b, a or 1)
    if et then 
        c:SetEdgeColor(BORDER.r, BORDER.g, BORDER.b, BORDER.a)
        c:SetEdgeTexture("", 8, 1, 1)
    else 
        c:SetEdgeColor(0,0,0,0) 
    end
    return c
end

-- Generates a Label UI element (Text)
local function LBL(p, x, y, w, h, txt, font, r, g, b)
    local c = WINDOW_MANAGER:CreateControl(nil, p, CT_LABEL)
    c:SetAnchor(TOPLEFT, p, TOPLEFT, x, y)
    c:SetDimensions(w, h)
    c:SetText(txt or "")
    c:SetFont(font or "ZoFontGame")
    c:SetColor(r or 1, g or 1, b or 1, 1)
    c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return c
end

-- Generates an interactive Gear Icon with golden highlight toggle logic
local function MakeIconCell(p, x, y, slot)
    local cell = WINDOW_MANAGER:CreateControl(nil, p, CT_BUTTON)
    cell:SetAnchor(TOPLEFT, p, TOPLEFT, x, y)
    cell:SetDimensions(ICON_S, ICON_S)
    
    local b = BD(cell, 0,0, ICON_S, ICON_S, 0.1,0.1,0.1,0.5, true)
    b:SetDrawLevel(1)
    
    local tex = WINDOW_MANAGER:CreateControl(nil, cell, CT_TEXTURE)
    tex:SetAnchor(TOPLEFT, cell, TOPLEFT, 4, 4)
    tex:SetAnchor(BOTTOMRIGHT, cell, BOTTOMRIGHT, -4, -4)
    tex:SetTexture(slot.tex)
    tex:SetDrawLayer(DL_CONTROLS)
    tex:SetDrawLevel(2)
    tex:SetDesaturation(1)
    tex:SetAlpha(0.6)
    
    local frame = BD(cell, 0,0, ICON_S, ICON_S, BG_DARK.r, BG_DARK.g, BG_DARK.b, 0.2, true)
    frame:SetDrawLevel(3)
    
    local glow = BD(cell, 0,0, ICON_S, ICON_S, TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 0.2, true)
    glow:SetEdgeColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
    glow:SetDrawLevel(4)
    glow:SetHidden(true)
    
    cell.glowCtrl = glow -- Save reference so it can be reset later
    
    LBL(cell, -8, ICON_S+2, ICON_S+16, 12, slot.label, "ZoFontGameSmall", 0.7, 0.7, 0.7):SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    cell:SetHandler("OnClicked", function() 
        if statusLabel then statusLabel:SetText("") end
        
        -- Toggle Selection State
        if state.selected[slot.id] then
            state.selected[slot.id] = nil
            glow:SetHidden(true)
        else
            state.selected[slot.id] = true
            glow:SetHidden(false)
        end
        
        -- Update Summary Counter
        local n=0
        for _ in pairs(state.selected) do n=n+1 end
        if summaryLbl then 
            summaryLbl:SetText(n==0 and "|c666666Select Pieces Above|r" or "|cE0BC6BSelected:|r  "..n) 
        end
    end)
    
    return cell
end

-- Generates a subtle, clickable text link for Feedback/Donations
local function MakeTextLink(parent, x, y, w, h, text, fn)
    local btn = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    btn:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    btn:SetDimensions(w, h)
    btn:SetText(text)
    btn:SetFont("ZoFontGameSmall")
    btn:SetNormalFontColor(0.6, 0.6, 0.6, 1)
    btn:SetMouseOverFontColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
    btn:SetHandler("OnClicked", fn)
    return btn
end

-- Opens the native ESO Mail interface for contact
local function OpenMailToAuthor(subject, body)
    if win then win:SetHidden(true) end
    SetGameCameraUIMode(false)
    GUI:ResetForm()
    
    SCENE_MANAGER:Show('mailSend')
    
    -- Slight delay ensures the Mail UI is fully rendered before injecting text
    zo_callLater(function()
        ZO_MailSendToField:SetText(AUTHOR_USERID)
        ZO_MailSendSubjectField:SetText(subject)
        ZO_MailSendBodyField:SetText(body)
        ZO_MailSendBodyField:TakeFocus()
    end, 250)
end

-- Constructs the entire UI dynamically on the first run.
function GUI:_Build()
    -- 1. Main Window Container
    win = WINDOW_MANAGER:CreateTopLevelWindow("LootHoundWin")
    win:SetDimensions(WIN_W, WIN_H)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetMovable(true)
    win:SetMouseEnabled(true)
    win:SetHidden(true)
    BD(win, 0,0,WIN_W,WIN_H, BG_DARK.r, BG_DARK.g, BG_DARK.b, BG_DARK.a, true)
    
    -- Title & Close Button
    local title = LBL(win, 0, 10, WIN_W, 30, "LootHound by BeanConure", "ZoFontWinH1", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    
    local xBtn = WINDOW_MANAGER:CreateControl(nil, win, CT_BUTTON)
    xBtn:SetAnchor(TOPRIGHT, win, TOPRIGHT, -10, 10)
    xBtn:SetDimensions(32,32)
    xBtn:SetNormalTexture("EsoUI/Art/Buttons/closeButton_up.dds")
    xBtn:SetHandler("OnClicked", function() 
        win:SetHidden(true)
        SetGameCameraUIMode(false)
        GUI:ResetForm()
    end)

    -- Bottom Corner Mail Links
    MakeTextLink(win, 20, WIN_H - 30, 150, 20, "> Send Feedback", function()
        OpenMailToAuthor("LootHound Suggestion", "Hey Bean, here is my suggestion for LootHound:\n\n")
    end)
    MakeTextLink(win, WIN_W - 120, WIN_H - 30, 100, 20, "> Donate Gold", function()
        OpenMailToAuthor("LootHound Donation", "Thanks for the awesome addon!")
    end)

    -- 2. Navigation Tabs
    local function Tab(x, txt, fn, id) 
        local bBack = BD(win, x, 45, 180, 36, 0.1, 0.1, 0.1, 0.5, true)
        bBack:SetDrawLevel(2)
        local b = WINDOW_MANAGER:CreateControl(nil, bBack, CT_BUTTON)
        b:SetAnchorFill()
        b:SetText(txt)
        b:SetFont("ZoFontGameBold")
        b:SetNormalFontColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
        b:SetMouseOverFontColor(1, 1, 1, 1)
        b:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        b:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        b:SetNormalTexture("EsoUI/Art/Buttons/ESO_buttonLarge_normal.dds")
        b:SetMouseOverTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseOver.dds")
        b:SetPressedTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseDown.dds")
        b:SetHandler("OnClicked", fn)
        tabBtns[id] = b
        return bBack 
    end
    Tab(20, "Add Pieces", function() GUI:SetMainTab("build") end, "build")
    Tab(220, "Watch List", function() GUI:SetMainTab("watchlist") end, "watchlist")


    buildPanel = WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
    buildPanel:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 80)
    buildPanel:SetDimensions(WIN_W, WIN_H-80)

    -- Inject Gear Icons
    LBL(buildPanel, 20, 15, 100, 20, "Armour", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
    for i,s in ipairs(ARMOUR_SLOTS) do iconBtns[s.id] = MakeIconCell(buildPanel, 20 + (i-1)*CELL, 40, s) end
    
    LBL(buildPanel, 580, 15, 100, 20, "Jewellery", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
    for i,s in ipairs(JEWEL_SLOTS) do iconBtns[s.id] = MakeIconCell(buildPanel, 580 + (i-1)*CELL, 40, s) end
    
    LBL(buildPanel, 20, 115, 100, 20, "Weapons", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
    for i,s in ipairs(WEAPON_SLOTS) do iconBtns[s.id] = MakeIconCell(buildPanel, 20 + (i-1)*CELL, 140, s) end

    summaryLbl = LBL(buildPanel, 20, 205, WIN_W-40, 20, "|c666666Select Pieces Above|r", "ZoFontGameSmall")
    summaryLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    -- Set Searching System
    local dsB = BD(buildPanel, 20, 235, WIN_W-40, 44, 0,0,0,0.5, true)
    LBL(buildPanel, 35, 247, 50, 20, "Set:", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
    
    local cbBack = BD(buildPanel, 70, 243, 400, 28, 0,0,0,0.8, true)
    local dsD = WINDOW_MANAGER:CreateControlFromVirtual("LootHoundDDSet", cbBack, "ZO_ComboBox")
    dsD:SetAnchorFill(cbBack)
    local cbSet = ZO_ComboBox_ObjectFromContainer(dsD)
    cbSet:SetSortsItems(false) 
    
    LBL(buildPanel, 500, 247, 80, 20, "Search:", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
    local searchBack = BD(buildPanel, 560, 243, 240, 28, 0,0,0,0.8, true)
    
    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("LootHoundSearchBox", searchBack, "ZO_DefaultEditForBackdrop")
    searchBox:SetMouseEnabled(true) 
    searchBox:SetHandler("OnMouseUp", function() searchBox:TakeFocus() end)
    
    GUI.cb = { set = cbSet, search = searchBox } -- Track for ResetForm()
    
    -- Dynamically pull ALL sets natively from ESO's database
    if not LootHound.AllSets then
        LootHound.AllSets = {}
        for setId = 1, 1500 do
            local hasSet, setName = GetItemSetInfo(setId)
            if hasSet and setName and setName ~= "" then 
                table.insert(LootHound.AllSets, { setId = setId, label = zo_strformat("<<C:1>>", setName) }) 
            end
        end
        table.sort(LootHound.AllSets, function(a, b) return a.label < b.label end)
    end

    -- Real-time Set Search Filtering
    local function PopulateSets(filterText)
        cbSet:ClearItems()
        cbSet:AddItem(cbSet:CreateItemEntry("- No Set -", function() state.setId=nil; state.setLabel="No Set" end))
        filterText = filterText and string.lower(filterText) or ""
        for _, s in ipairs(LootHound.AllSets) do
            if filterText == "" or string.find(string.lower(s.label), filterText, 1, true) then
                cbSet:AddItem(cbSet:CreateItemEntry(s.label, function() state.setId=s.setId; state.setLabel=s.label end))
            end
        end
        cbSet:SelectItemByIndex(1)
    end

    searchBox:SetHandler("OnTextChanged", function(self) 
        if statusLabel then statusLabel:SetText("") end
        PopulateSets(self:GetText()) 
    end)
    PopulateSets("")

    -- Trait & Quality Dropdowns
    local xoff, cats = { 40, 345, 650 }, { "armor", "weapon", "jewelry" }
    for i,cat in ipairs(cats) do
        local y = 295
        LBL(buildPanel, xoff[i], y, 150, 18, (cat=="jewelry" and "Jewelry" or cat:gsub("^%l", string.upper)).." Trait:", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
        
        local trB = BD(buildPanel, xoff[i], y+20, 240, 24, 0,0,0,0.5, true)
        local trD = WINDOW_MANAGER:CreateControlFromVirtual("LootHoundDDTr"..cat, trB, "ZO_ComboBox")
        trD:SetAnchorFill(trB)
        local cbTr = ZO_ComboBox_ObjectFromContainer(trD)
        cbTr:AddItem(cbTr:CreateItemEntry("Any Trait", function() state.groupTraits[cat]=-1 end))
        for _,tr in ipairs(LootHound.ItemData.TRAITS) do 
            if tr.category==cat then 
                cbTr:AddItem(cbTr:CreateItemEntry(tr.label, function() state.groupTraits[cat]=tr.id end)) 
            end 
        end
        cbTr:SelectItemByIndex(1)
        GUI.cb["tr_"..cat] = cbTr

        LBL(buildPanel, xoff[i], y+55, 150, 18, "Quality:", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
        local qB = BD(buildPanel, xoff[i], y+75, 240, 24, 0,0,0,0.5, true)
        local qD = WINDOW_MANAGER:CreateControlFromVirtual("LootHoundDDQ"..cat, qB, "ZO_ComboBox")
        qD:SetAnchorFill(qB)
        local cbQ = ZO_ComboBox_ObjectFromContainer(qD)
        local qs = {{l="Any",v=0},{l="Fine",v=1},{l="Superior",v=2},{l="Epic",v=3},{l="Legendary",v=4}}
        for _,q in ipairs(qs) do 
            cbQ:AddItem(cbQ:CreateItemEntry(q.l, function() state.groupQuals[cat]=q.v end)) 
        end
        cbQ:SelectItemByIndex(1)
        GUI.cb["q_"..cat] = cbQ

        if cat=="armor" then 
            LBL(buildPanel, xoff[i], y+110, 150, 16, "Type:", "ZoFontGameBold", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
            local tyB = BD(buildPanel, xoff[i], y+130, 240, 24, 0,0,0,0.5, true)
            local tyD = WINDOW_MANAGER:CreateControlFromVirtual("LootHoundDDType", tyB, "ZO_ComboBox")
            tyD:SetAnchorFill(tyB)
            local cbTy = ZO_ComboBox_ObjectFromContainer(tyD)
            cbTy:AddItem(cbTy:CreateItemEntry("Any Type", function() state.armourType=0 end))
            for _,at in ipairs(LootHound.ItemData.ARMOUR_TYPES or {}) do 
                cbTy:AddItem(cbTy:CreateItemEntry(at.label, function() state.armourType=at.id end)) 
            end
            cbTy:SelectItemByIndex(1)
            GUI.cb.ty_armor = cbTy
        end
    end

    -- Submit Button & Status Label
    local abBack = BD(buildPanel, WIN_W/2 - 120, WIN_H - 120, 240, 36, 0.1, 0.1, 0.1, 0.5, true)
    local ab = WINDOW_MANAGER:CreateControl(nil, abBack, CT_BUTTON)
    ab:SetAnchorFill()
    ab:SetText("Add Rule to List")
    ab:SetFont("ZoFontGameBold")
    ab:SetNormalFontColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
    ab:SetMouseOverFontColor(1, 1, 1, 1)
    ab:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ab:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ab:SetNormalTexture("EsoUI/Art/Buttons/ESO_buttonLarge_normal.dds")
    ab:SetMouseOverTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseOver.dds")
    ab:SetPressedTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseDown.dds")
    ab:SetHandler("OnClicked", function() GUI:AddRule() end)

    statusLabel = LBL(buildPanel, 0, 485, WIN_W, 24, "", "ZoFontGameSmall", 0.8, 0.8, 0.8)
    statusLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    wlPanel = WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
    wlPanel:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 85)
    wlPanel:SetDimensions(WIN_W, WIN_H-85)
    wlPanel:SetHidden(true)
    
    local wlS = WINDOW_MANAGER:CreateControlFromVirtual("LootHoundWLScroll", wlPanel, "ZO_ScrollContainer")
    wlS:SetAnchor(TOPLEFT, wlPanel, TOPLEFT, 20, 10)
    wlS:SetAnchor(BOTTOMRIGHT, wlPanel, BOTTOMRIGHT, -20, -70)
    wlInner = WINDOW_MANAGER:GetControlByName("LootHoundWLScrollScrollChild")

    -- Shared bottom button builder for Mass Actions
    local function BottomBtn(parent, x, text, fn)
        local btnBack = BD(parent, x, WIN_H - 140, 180, 36, 0.1, 0.1, 0.1, 0.5, true)
        local btn = WINDOW_MANAGER:CreateControl(nil, btnBack, CT_BUTTON)
        btn:SetAnchorFill()
        btn:SetText(text)
        btn:SetFont("ZoFontGameBold")
        btn:SetNormalFontColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
        btn:SetMouseOverFontColor(1, 1, 1, 1)
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        btn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        btn:SetNormalTexture("EsoUI/Art/Buttons/ESO_buttonLarge_normal.dds")
        btn:SetMouseOverTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseOver.dds")
        btn:SetPressedTexture("EsoUI/Art/Buttons/ESO_buttonLarge_mouseDown.dds")
        btn:SetHandler("OnClicked", fn)
        return btnBack
    end

    BottomBtn(wlPanel, WIN_W/2 - 290, "Select All", function() GUI:ToggleSelectAll() end)
    BottomBtn(wlPanel, WIN_W/2 - 90, "Delete Selected", function() GUI:DeleteSelected() end)
    BottomBtn(wlPanel, WIN_W/2 + 110, "Link to Chat", function() GUI:OutputWatchListToChat() end)

    GUI:SetMainTab("build")
end

-- Re-renders the Watch List tab by pulling rules from memory
function GUI:RefreshWatchList()
    if not wlInner then return end
    
    -- Hide all existing rows for fresh reuse
    for _, r in pairs(wlRowPool) do r:SetHidden(true) end
    
    local list = LootHound.WatchList:GetAll()
    
    -- Display "Empty" message if no rules exist
    if not list or #list == 0 then 
        if not GUI.emptyLbl then 
            GUI.emptyLbl = LBL(wlInner, 0, 40, WIN_W-40, 20, "Watch List is empty.", nil, 0.5, 0.5, 0.5)
            GUI.emptyLbl:SetHorizontalAlignment(TEXT_ALIGN_CENTER) 
        end
        GUI.emptyLbl:SetHidden(false)
        wlInner:SetHeight(100)
        return 
    end
    
    if GUI.emptyLbl then GUI.emptyLbl:SetHidden(true) end
    
    local y = 0
    for i, entry in ipairs(list) do
        local row = wlRowPool[i]
        
        -- Create a new row if we run out of pooled UI elements
        if not row then
            row = BD(wlInner, 0, 0, WIN_W-60, 40, 0.1, 0.1, 0.1, 0.6, true)
            
            -- High Contrast Checkbox Background
            row.chkBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
            row.chkBg:SetAnchor(LEFT, row, LEFT, 15, 0)
            row.chkBg:SetDimensions(20, 20)
            row.chkBg:SetCenterColor(0, 0, 0, 0.8)
            row.chkBg:SetEdgeColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 0.8)
            row.chkBg:SetEdgeTexture("", 1, 1, 1)
            
            -- Checkbox Gold Fill
            row.chkFill = WINDOW_MANAGER:CreateControl(nil, row.chkBg, CT_BACKDROP)
            row.chkFill:SetAnchor(TOPLEFT, row.chkBg, TOPLEFT, 4, 4)
            row.chkFill:SetAnchor(BOTTOMRIGHT, row.chkBg, BOTTOMRIGHT, -4, -4)
            row.chkFill:SetCenterColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
            row.chkFill:SetEdgeColor(0,0,0,0)
            row.chkFill:SetHidden(true)
            
            -- Invisible button overlay for clicking the checkbox
            row.chk = WINDOW_MANAGER:CreateControl(nil, row.chkBg, CT_BUTTON)
            row.chk:SetAnchorFill()
            row.chk:SetHandler("OnClicked", function()
                state.wlSelected[row.entryId] = not state.wlSelected[row.entryId]
                row.chkFill:SetHidden(not state.wlSelected[row.entryId])
            end)
            
            -- Descriptive Label
            row.lbl = LBL(row, 45, 0, WIN_W-185, 40, "", "ZoFontGame", TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b)
            row.lbl:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            row.lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            
            -- Single Delete Button
            row.del = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
            row.del:SetAnchor(RIGHT, row, RIGHT, -10, 0)
            row.del:SetDimensions(24, 24)
            row.del:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
            row.del:SetHandler("OnClicked", function() 
                LootHound.WatchList:Remove(row.entryId)
                state.wlSelected[row.entryId] = nil
                GUI:RefreshWatchList() 
            end)
            
            wlRowPool[i] = row
        end
        
        -- Position the row and bind its ID
        row:SetAnchor(TOPLEFT, wlInner, TOPLEFT, 10, y)
        row.entryId = entry.id
        
        -- Sync checkbox visually to the state manager
        row.chkFill:SetHidden(not state.wlSelected[entry.id])
        
        -- Add prefix depending on rule type
        row.lbl:SetText((entry.mode=="advanced" and "[SET] " or "[PC] ")..entry.label)
        
        row:SetHidden(false)
        y = y + 45
    end
    -- Extend scroll window depth to match items
    wlInner:SetHeight(y + 20)
end

-- Checks or Unchecks every item currently visible in the Watch List
function GUI:ToggleSelectAll()
    local list = LootHound.WatchList:GetAll()
    if not list or #list == 0 then return end
    
    local allSelected = true
    for _, entry in ipairs(list) do
        if not state.wlSelected[entry.id] then
            allSelected = false
            break
        end
    end

    for _, entry in ipairs(list) do
        state.wlSelected[entry.id] = not allSelected
    end
    GUI:RefreshWatchList()
end

-- Safely deletes multiple checked rules at once
function GUI:DeleteSelected()
    local list = LootHound.WatchList:GetAll()
    
    -- Build a hit-list first to prevent array shifting bugs mid-deletion
    local toDelete = {}
    for _, entry in ipairs(list) do
        if state.wlSelected[entry.id] then
            table.insert(toDelete, entry.id)
        end
    end
    
    if #toDelete > 0 then
        for _, id in ipairs(toDelete) do
            LootHound.WatchList:Remove(id)
            state.wlSelected[id] = nil
        end
        GUI:RefreshWatchList()
    end
end

-- Opens the chat input natively and pastes your selected rules for grouped sharing
function GUI:OutputWatchListToChat()
    local list = LootHound.WatchList:GetAll()
    local selectedItems = {}
    
    for _, entry in ipairs(list) do
        if state.wlSelected[entry.id] then
            local prefix = (entry.mode == "advanced") and "[SET] " or "[Piece] "
            table.insert(selectedItems, prefix .. entry.label)
        end
    end
    
    if #selectedItems == 0 then
        d("|cFF4444[LootHound]|r Please check at least one item box to output to chat.")
        return
    end
    
    -- Concatenate into a clean string and push to chat line
    local message = "Hey, I am looking for: " .. table.concat(selectedItems, " | ")
    StartChatInput(message)
end

-- Switches visibility between the Build Panel and Watch List Panel
function GUI:SetMainTab(tab) 
    state.mainTab=tab
    if buildPanel then buildPanel:SetHidden(tab~="build") end
    if wlPanel then wlPanel:SetHidden(tab~="watchlist") end
    
    -- Update Tab Button Text Colors
    for id, btn in pairs(tabBtns) do
        if id == tab then
            btn:SetNormalFontColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
            btn:SetPressedFontColor(TEXT_GOLD.r, TEXT_GOLD.g, TEXT_GOLD.b, 1)
        else
            btn:SetNormalFontColor(1, 1, 1, 1)
            btn:SetPressedFontColor(1, 1, 1, 1)
        end
    end
    
    if tab=="watchlist" then GUI:RefreshWatchList() end 
end

-- Fully clears out all dropdowns, inputs, and selections on the Build Panel
function GUI:ResetForm(isAfterAdd)
    state.selected = {}
    state.wlSelected = {}
    
    -- Turn off gear icon golden highlights natively
    for _, c in pairs(iconBtns) do 
        if c.glowCtrl then c.glowCtrl:SetHidden(true) end 
    end
    
    if summaryLbl then summaryLbl:SetText("|c666666Select Pieces Above|r") end
    
    if GUI.cb then
        GUI.cb.search:SetText("")
        local cats = {"armor", "weapon", "jewelry"}
        for _, cat in ipairs(cats) do
            if GUI.cb["tr_"..cat] then GUI.cb["tr_"..cat]:SelectItemByIndex(1) end
            if GUI.cb["q_"..cat]  then GUI.cb["q_"..cat]:SelectItemByIndex(1) end
        end
        if GUI.cb.ty_armor then GUI.cb.ty_armor:SelectItemByIndex(1) end
        
        state.groupTraits = { armor=-1, weapon=-1, jewelry=-1 }
        state.groupQuals = { armor=0, weapon=0, jewelry=0 }
        state.armourType = 0
    end
    
    -- If closing the window normally, wipe the status label.
    -- If resetting after adding a rule, leave it so the player sees the "Success" message.
    if not isAfterAdd and statusLabel then
        statusLabel:SetText("")
    end
    
    GUI:RefreshWatchList() 
end

-- Reads UI selections, builds the data objects, and commits them to the WatchList memory
function GUI:AddRule()
    local D, sel = LootHound.ItemData, {}
    local grps = {{s=ARMOUR_SLOTS,c="armor"},{s=WEAPON_SLOTS,c="weapon"},{s=JEWEL_SLOTS,c="jewelry"}}
    
    -- Gather all currently clicked gear pieces
    for _,g in ipairs(grps) do 
        for _,sl in ipairs(g.s) do 
            if state.selected[sl.id] then 
                table.insert(sel,{ slotDef=sl, traitId=state.groupTraits[g.c] or -1, quality=state.groupQuals[g.c] or 0, armourType=(g.c=="armor") and state.armourType or nil }) 
            end 
        end 
    end
    
    -- Error check
    if #sel==0 then 
        statusLabel:SetText("|cFF4444Select a piece first.|r")
        local errMsg = statusLabel:GetText()
        zo_callLater(function() if statusLabel and statusLabel:GetText() == errMsg then statusLabel:SetText("") end end, 3500)
        return 
    end
    
    -- Logic block for Advanced Rules (Specific Sets)
    if state.setId then
        -- Automatically split multiple pieces into individual rules for cleaner tracking
        for _,s in ipairs(sel) do 
            local pieces = {}
            table.insert(pieces,{ equipType=s.slotDef.equip, weaponType=s.slotDef.weap, traitId=s.traitId, quality=s.quality, armourType=s.armourType })
            
            -- Format label (e.g. "[Divines]")
            local traitSuffix = ""
            if s.traitId and s.traitId ~= -1 and D and D.GetTraitLabel then
                local tLabel = D:GetTraitLabel(s.traitId)
                if tLabel and tLabel ~= "" and tLabel ~= "Any" and tLabel ~= "Any Trait" then
                    traitSuffix = " [" .. tLabel .. "]"
                end
            end
            
            local lbl = state.setLabel .. " (" .. s.slotDef.label .. traitSuffix .. ")"
            
            LootHound.WatchList:Add({mode="advanced",setId=state.setId, setLabel=state.setLabel, pieces=pieces, label=lbl})
        end
        statusLabel:SetText("|c44FF88Added:|r " .. #sel .. " pieces for " .. state.setLabel)
    
    -- Logic block for Simple Rules (No Set Selected)
    else
        for _,s in ipairs(sel) do 
            local traitSuffix = ""
            if s.traitId and s.traitId ~= -1 and D and D.GetTraitLabel then
                local tLabel = D:GetTraitLabel(s.traitId)
                if tLabel and tLabel ~= "" and tLabel ~= "Any" and tLabel ~= "Any Trait" then
                    traitSuffix = " [" .. tLabel .. "]"
                end
            end
            local lbl = s.slotDef.label .. traitSuffix
            LootHound.WatchList:Add({ mode="simple", equipType=s.slotDef.equip, weaponType=s.slotDef.weap, armourType=s.armourType, traitId=s.traitId, quality=s.quality, label=lbl }) 
        end
        statusLabel:SetText("|c44FF88Success:|r "..#sel.." items added.")
    end
    
    -- Make the success message disappear after 4 seconds
    local successMsg = statusLabel:GetText()
    zo_callLater(function() 
        if statusLabel and statusLabel:GetText() == successMsg then 
            statusLabel:SetText("") 
        end 
    end, 4000)
    
    GUI:ResetForm(true)
end

-- Handles visibility logic when typing /lh or using the keybind
function GUI:Toggle() 
    if not win then GUI:Init() end
    if win:IsHidden() then
        win:SetHidden(false)
        SetGameCameraUIMode(true) -- Free the mouse cursor
    else
        win:SetHidden(true)
        SetGameCameraUIMode(false) -- Lock the mouse cursor back to combat
        GUI:ResetForm() -- Wipe the form so it's clean next time
    end
end

-- Checks if window is built on load, builds it if not
function GUI:Init() 
    local e = WINDOW_MANAGER:GetControlByName("LootHoundWin")
    if e then 
        win = e 
    else 
        GUI:_Build() 
        SetGameCameraUIMode(true)
    end 
end