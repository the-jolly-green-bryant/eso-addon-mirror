AutoSeller = {
    name = "AutoSeller",
    default = {
        minPrice = 5000,
        maxPrice = 10000,
        enabledQualities = {
            [0] = false,
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = false,
        },
        lang = "ru",
    },
    isScanning = false,
    queue = {},
    isPosting = false,
}

local AS = AutoSeller
local WM = GetWindowManager()

AS.strings = {
    ["en"] = {
        title = "AutoSeller",
        minGold = "Min Price (Gold):",
        maxGold = "Max Price (Gold):",
        qualities = "Sell Qualities:",
        info = "Undercuts TTC by ~2%",
        startBtn = "Post Items",
        qNames = {
            [0] = "Trash",
            [1] = "White",
            [2] = "Green",
            [3] = "Blue",
            [4] = "Purple",
            [5] = "Gold",
        },
        scanMsg = "Scanning... Found <<1>> items.",
        storeClosed = "Error: Guild Store must be open at a banker!",
        listingMsg = "Listing: <<1>>",
    },
    ["ru"] = {
        title = "AutoSeller",
        minGold = "Мин. цена (Золото):",
        maxGold = "Макс. цена (Золото):",
        qualities = "Качество предметов:",
        info = "Цена ниже TTC на ~2%",
        startBtn = "Выставить предметы",
         qNames = {
            [0] = "Мусор",
            [1] = "Обычное",
            [2] = "Зеленое",
            [3] = "Синее",
            [4] = "Фиолет",
            [5] = "Золотое",
        },
        scanMsg = "Сканирование... Найдено <<1>> предметов.",
        storeClosed = "Ошибка: Магазин гильдии должен быть открыт!",
        listingMsg = "Выставляю: <<1>>",
    }
}

local Q_COLORS = {
    [0] = {0.6, 0.6, 0.6, 1},
    [1] = {1, 1, 1, 1},
    [2] = {0.2, 1, 0.2, 1},
    [3] = {0.2, 0.6, 1, 1},
    [4] = {0.6, 0.2, 1, 1}, 
    [5] = {1, 0.8, 0, 1},  
}

function AutoSeller.OnAddOnLoaded(event, addonName)
    if addonName ~= AutoSeller.name then return end
    EVENT_MANAGER:UnregisterForEvent(AutoSeller.name, EVENT_ADD_ON_LOADED)
    AutoSeller.savedVars = ZO_SavedVars:NewAccountWide("AutoSellerSavedVars", 2, nil, AutoSeller.default)
    if AS.savedVars.enabledQualities == nil then AS.savedVars.enabledQualities = AS.default.enabledQualities end
    
    AutoSeller.CreateUI()
    SLASH_COMMANDS["/autosell"] = AutoSeller.ToggleUI
    
    EVENT_MANAGER:RegisterForEvent(AutoSeller.name, EVENT_OPEN_TRADING_HOUSE, function() AS.ui:SetHidden(false) end)
    EVENT_MANAGER:RegisterForEvent(AutoSeller.name, EVENT_CLOSE_TRADING_HOUSE, function() AS.ui:SetHidden(true) end)
    EVENT_MANAGER:RegisterForEvent(AutoSeller.name, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, AutoSeller.OnTradingHouseResponse)
end

function AutoSeller.GetStr(key)
    local lang = AS.savedVars.lang or "en"
    if not AS.strings[lang] then lang = "en" end
    return AS.strings[lang][key] or key
end

function AutoSeller.CreateEditBox(name, parent, width, height, initialVal, changeCallback)
    local bg = WM:CreateControl(name.."BG", parent, CT_BACKDROP)
    bg:SetDimensions(width, height)
    bg:SetCenterColor(0, 0, 0, 0.5)
    bg:SetEdgeColor(0.5, 0.5, 0.5, 1)
    bg:SetEdgeTexture("", 1, 1, 0)
    
    local edit = WM:CreateControlFromVirtual(name, bg, "ZO_DefaultEdit")
    edit:SetAnchor(TOPLEFT, bg, TOPLEFT, 5, 2)
    edit:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -5, -2)
    edit:SetText(tostring(initialVal))
    edit:SetHandler("OnTextChanged", function(self) changeCallback(self:GetText()) end)
    
    return bg, edit
end

function AutoSeller.CreateUI()
    local tlc = WM:CreateTopLevelWindow("AutoSellerWindow")
    tlc:SetDimensions(500, 480)
    tlc:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    tlc:SetMovable(true)
    tlc:SetMouseEnabled(true)
    tlc:SetHidden(true)
    
    local bg = WM:CreateControl("$(parent)BG", tlc, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.1, 0.1, 0.1, 0.95)
    bg:SetEdgeColor(0.4, 0.4, 0.4, 1)
    bg:SetEdgeTexture("", 8, 1, 0)
    
    -- Header
    local title = WM:CreateControl("$(parent)Title", tlc, CT_LABEL)
    title:SetAnchor(TOPLEFT, tlc, TOPLEFT, 20, 15)
    title:SetFont("ZoFontWinH2")
    title:SetColor(1, 0.8, 0, 1)
    AS.lblTitle = title
    
    local btnLang = WM:CreateControl("$(parent)BtnLang", tlc, CT_BUTTON)
    btnLang:SetDimensions(30, 25)
    btnLang:SetAnchor(LEFT, title, RIGHT, 15, 0)
    btnLang:SetFont("ZoFontGameSmall")
    btnLang:SetNormalFontColor(0.6, 0.6, 0.6, 1)
    btnLang:SetMouseOverFontColor(1, 1, 1, 1)
    btnLang:SetHandler("OnClicked", function() 
        AS.savedVars.lang = (AS.savedVars.lang == "ru") and "en" or "ru"
        AS.RefreshUI()
    end)
    AS.btnLang = btnLang
    
    local btnClose = WM:CreateControl("$(parent)BtnClose", tlc, CT_BUTTON)
    btnClose:SetDimensions(30, 30)
    btnClose:SetAnchor(TOPRIGHT, tlc, TOPRIGHT, -5, 5)
    btnClose:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
    btnClose:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
    btnClose:SetHandler("OnClicked", function() AS.ui:SetHidden(true) end)
    
    local div1 = WM:CreateControl("$(parent)Div1", tlc, CT_TEXTURE)
    div1:SetDimensions(460, 2)
    div1:SetAnchor(TOP, tlc, TOP, 0, 50)
    div1:SetColor(1, 1, 1, 0.3)
    
    AS.lblMin = WM:CreateControl("$(parent)LblMin", tlc, CT_LABEL)
    AS.lblMin:SetAnchor(TOPLEFT, div1, BOTTOMLEFT, 0, 20)
    AS.lblMin:SetAnchor(TOPLEFT, tlc, TOPLEFT, 20, 70)
    AS.lblMin:SetFont("ZoFontGame")
    
    local bgMin, editMin = AS.CreateEditBox("$(parent)EditMin", tlc, 120, 28, AS.savedVars.minPrice, function(txt)
         local val = tonumber(txt)
         if val then AS.savedVars.minPrice = val end
    end)
    bgMin:SetAnchor(LEFT, AS.lblMin, RIGHT, 15, 0)
    
    AS.lblMax = WM:CreateControl("$(parent)LblMax", tlc, CT_LABEL)
    AS.lblMax:SetAnchor(TOPLEFT, AS.lblMin, BOTTOMLEFT, 0, 25) 
    AS.lblMax:SetFont("ZoFontGame")
    
    local bgMax, editMax = AS.CreateEditBox("$(parent)EditMax", tlc, 120, 28, AS.savedVars.maxPrice, function(txt)
         local val = tonumber(txt)
         if val then AS.savedVars.maxPrice = val end
    end)
    bgMax:SetAnchor(LEFT, AS.lblMax, RIGHT, 15, 0)
    
    local div2 = WM:CreateControl("$(parent)Div2", tlc, CT_TEXTURE)
    div2:SetDimensions(460, 2)
    div2:SetAnchor(TOP, tlc, TOP, 0, 180)
    div2:SetColor(1, 1, 1, 0.3)
    
    AS.lblQual = WM:CreateControl("$(parent)LblQual", tlc, CT_LABEL)
    AS.lblQual:SetAnchor(TOPLEFT, tlc, TOPLEFT, 20, 200)
    AS.lblQual:SetFont("ZoFontGame")
    
    local gridAnchor = WM:CreateControl("$(parent)GridAnchor", tlc, CT_CONTROL)
    gridAnchor:SetAnchor(TOPLEFT, AS.lblQual, BOTTOMLEFT, 10, 15)
    gridAnchor:SetDimensions(1,1)
    
    AS.qualityChecks = {}
    
    local colW = 200 
    local rowH = 40
    
    for i=0, 5 do
        local check = WM:CreateControlFromVirtual("$(parent)QCheck"..i, tlc, "ZO_CheckButton")
        local row = math.floor(i / 2)
        local col = i % 2
        
        check:SetAnchor(TOPLEFT, gridAnchor, TOPLEFT, col * colW, row * rowH)
        ZO_CheckButton_SetCheckState(check, AS.savedVars.enabledQualities[i])
        ZO_CheckButton_SetToggleFunction(check, function(control, checked) AS.savedVars.enabledQualities[i] = checked end)
        
        local lbl = WM:CreateControl("$(parent)QLbl"..i, check, CT_LABEL)
        lbl:SetAnchor(LEFT, check, RIGHT, 10, 0)
        lbl:SetFont("ZoFontGame")
        local r,g,b = unpack(Q_COLORS[i])
        lbl:SetColor(r,g,b,1)
        AS.qualityChecks[i] = lbl
    end
    
    AS.lblInfo = WM:CreateControl("$(parent)Info", tlc, CT_LABEL)
    AS.lblInfo:SetAnchor(BOTTOM, tlc, BOTTOM, 0, -70)
    AS.lblInfo:SetFont("ZoFontGameSmall")
    AS.lblInfo:SetColor(0.7,0.7,0.7)
    
    AS.btnStart = WM:CreateControlFromVirtual("$(parent)BtnStart", tlc, "ZO_DefaultButton")
    AS.btnStart:SetAnchor(BOTTOM, tlc, BOTTOM, 0, -20)
    AS.btnStart:SetDimensions(250, 45)
    AS.btnStart:SetHandler("OnClicked", AS.StartPosting)
    
    AS.ui = tlc
    AS.RefreshUI()
end

function AutoSeller.RefreshUI()
    local str = AS.GetStr
    AS.lblTitle:SetText(str("title"))
    AS.btnLang:SetText(string.upper(AS.savedVars.lang))
    AS.lblMin:SetText(str("minGold"))
    AS.lblMax:SetText(str("maxGold"))
    AS.lblQual:SetText(str("qualities"))
    AS.lblInfo:SetText(str("info"))
    AS.btnStart:SetText(str("startBtn"))
    
    local qn = AS.savedVars.lang == "ru" and AS.strings["ru"].qNames or AS.strings["en"].qNames
    for i=0, 5 do
        AS.qualityChecks[i]:SetText(qn[i])
    end
end

function AutoSeller.ToggleUI()
    AS.ui:SetHidden(not AS.ui:IsHidden())
    if not AS.ui:IsHidden() then AS.RefreshUI() end
end

-- Logic
function AutoSeller.GetPrice(itemLink)
    if not TamrielTradeCentrePrice then return nil end
    local info = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    if info and info.SuggestedPrice then return info.SuggestedPrice end
    return nil
end

function AutoSeller.FormatStr(key, ...)
    local str = AS.GetStr(key)
    for i,v in ipairs({...}) do str = string.gsub(str, "<<"..i..">>", tostring(v)) end
    return str
end

function AutoSeller.StartPosting()
    if GetInteractionType() ~= INTERACTION_TRADINGHOUSE then
        d("[AutoSeller] " .. AS.GetStr("storeClosed"))
        return
    end
    
    AS.queue = {}
    local bag = BAG_BACKPACK
    for slot = 0, GetBagSize(bag)-1 do
        local link = GetItemLink(bag, slot)
        if link ~= "" then
            local _, count = GetItemInfo(bag, slot)
            local q = GetItemLinkQuality(link)
            if AS.savedVars.enabledQualities[q] then
                local price = AS.GetPrice(link)
                if price and price >= AS.savedVars.minPrice and price <= AS.savedVars.maxPrice and not IsItemBound(bag, slot) then
                    local unitPrice = math.max(1, math.floor(price * 0.98))
                    table.insert(AS.queue, {bag=bag, slot=slot, count=count, price=unitPrice*count, cleanPrice=unitPrice, name=link})
                end
            end
        end
    end
    d("[AutoSeller] " .. AS.FormatStr("scanMsg", #AS.queue))
    if #AS.queue > 0 then AS.isPosting = true; AS.ProcessQueue() end
end

function AutoSeller.ProcessQueue()
    if not AS.isPosting or GetInteractionType() ~= INTERACTION_TRADINGHOUSE or #AS.queue == 0 then
        AS.isPosting = false
        return
    end
    
    local item = AS.queue[1]
    if GetItemLink(item.bag, item.slot) == "" then
        table.remove(AS.queue, 1)
        AS.ProcessQueue()
        return
    end
    
    d("[AutoSeller] " .. AS.FormatStr("listingMsg", item.name))
    if IsProtectedFunction("RequestPostItemOnTradingHouse") then
        CallSecureProtected("RequestPostItemOnTradingHouse", item.bag, item.slot, item.count, item.price)
    else
        RequestPostItemOnTradingHouse(item.bag, item.slot, item.count, item.price)
    end
end

function AutoSeller.OnTradingHouseResponse(e, type, result)
    if not AS.isPosting then return end
    if type == TRADING_HOUSE_RESULT_POST_SUCCESS then
        table.remove(AS.queue, 1)
        zo_callLater(function() AS.ProcessQueue() end, 1200)
    elseif type ~= TRADING_HOUSE_RESULT_POST_PENDING then
        AS.isPosting = false 
    end
end

EVENT_MANAGER:RegisterForEvent(AutoSeller.name, EVENT_ADD_ON_LOADED, AutoSeller.OnAddOnLoaded)
