local HBW = HyboremBugsWeeds
if not HBW then return end

local function HasLPC()
    return LibPriceCache and type(LibPriceCache.GetPrice) == "function"
end

local function GetItemCount(itemId)
    if not itemId then return 0 end
    local total = 0
    local function scan(bag)
        for s = 0, GetBagSize(bag) - 1 do
            if GetItemId(bag, s) == itemId then
                total = total + GetSlotStackSize(bag, s)
            end
        end
    end
    if HasCraftBagAccess() then
        local s = GetNextVirtualBagSlotId()
        while s do
            if GetItemId(BAG_VIRTUAL, s) == itemId then
                total = total + GetSlotStackSize(BAG_VIRTUAL, s)
            end
            s = GetNextVirtualBagSlotId(s)
        end
    end
    scan(BAG_BACKPACK)
    scan(BAG_BANK)
    return total
end

local function GetItemPrice(itemId)
    if not HasLPC() or not itemId then return nil end
    local fakeLink = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local price = LibPriceCache.GetPrice(fakeLink)
    if price and price > 0 then
        return price
    end
    return nil
end

local function GetLang()
    local l = GetCVar("language.2") or "en"
    if l == "en" and IsAddOnLoaded and IsAddOnLoaded("EsoPL") then
        return "pl"
    end
    return HBW[l] and l or "en"
end

local plantIds = {
    [1] = 30165, [2] = 30158, [3] = 30155, [4] = 30152, [5] = 30162,
    [6] = 30148, [7] = 30149, [8] = 30161, [9] = 30160, [10] = 30154,
    [11] = 30157, [12] = 30151, [13] = 30164, [14] = 30159, [15] = 30163,
    [16] = 30153, [17] = 30156, [18] = 30166, [19] = 77590, [20] = 150672,
}

local goldIcon = "|t16:16:EsoUI/Art/currency/currency_gold.dds|t"

local function FormatPrice(p)
    if not p then return "" end
    return string.format("%s%.2f", goldIcon, p)
end

function HBW.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "HyboremBugsWeeds",
        displayName = "|cFF8800Hyborem's Bugs'n'Weeds|r",
        author = "Hyborem & DeepSeek",
        version = "2.0",
        registerForRefresh = true,
        registerForDefaults = true,
        refreshCallback = function() HBW.RebuildMenu() end,
    }
    LAM:RegisterAddonPanel("HyboremBugsWeeds_Panel", panelData)
    HBW.RebuildMenu()
end

function HBW.RebuildMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local lang = HBW[GetLang()] or HBW["en"]
    local choices = { "My favorites", "Why not", "Unimportant" }
    local vals = { 1, 2, 3 }
    
    local opts = {}
    
    -- Server mode dropdown
    local serverModeOptions = { "Shared (all servers)", "Per Server (EU/NA/PTS)" }
    local serverModeValues = { "Shared", "PerServer" }
    
    table.insert(opts, {
        type = "dropdown",
        name = "Saved Variables Mode",
        choices = serverModeOptions,
        choicesValues = serverModeValues,
        getFunc = function() return HBW.vars.serverMode or "Shared" end,
        setFunc = function(v)
            HBW.vars.serverMode = v
            d("|cFF8800[HBW]|r Saved variables mode changed to: " .. v .. ". Type /reloadui to apply.")
        end,
        width = "full",
    })
    
    table.insert(opts, { type = "colorpicker", name = "Favorite color",
        getFunc = function() return HBW.vars.colors[1].r, HBW.vars.colors[1].g, HBW.vars.colors[1].b, HBW.vars.colors[1].a or 1 end,
        setFunc = function(r, g, b, a) HBW.vars.colors[1] = { r = r, g = g, b = b, a = a } end })
    table.insert(opts, { type = "colorpicker", name = "Liked color",
        getFunc = function() return HBW.vars.colors[2].r, HBW.vars.colors[2].g, HBW.vars.colors[2].b, HBW.vars.colors[2].a or 1 end,
        setFunc = function(r, g, b, a) HBW.vars.colors[2] = { r = r, g = g, b = b, a = a } end })
    table.insert(opts, { type = "colorpicker", name = "Unimportant color",
        getFunc = function() return HBW.vars.colors[3].r, HBW.vars.colors[3].g, HBW.vars.colors[3].b, HBW.vars.colors[3].a or 1 end,
        setFunc = function(r, g, b, a) HBW.vars.colors[3] = { r = r, g = g, b = b, a = a } end })
    
    table.insert(opts, { type = "header", name = lang.plant_selection or "Selection" })

    -- Plants (ID 1-20)
    for id = 1, 20 do
        local name = lang[id]
        local gid = plantIds[id]
        local cnt = gid and GetItemCount(gid) or 0
        local price = gid and GetItemPrice(gid) or nil
        local has = HasLPC()
        
        local coloredName = "|c88FF88" .. name .. "|r"
        local countStr = string.format("[%s]", cnt)
        local priceStr = ""
        if price then
            priceStr = " |cFFD700" .. FormatPrice(price) .. "|r"
        elseif has then
            priceStr = " |c888888...|r"
        end
        
        local displayName = string.format("%s %s%s", coloredName, countStr, priceStr)
        
        table.insert(opts, {
            type = "dropdown",
            name = displayName,
            choices = choices,
            choicesValues = vals,
            tooltip = price and ("Unit price: " .. string.format("%.2f", price)) or (has and "Price after LPC scan" or "Install LibPriceCache"),
            getFunc = (function(i) return function() return HBW.vars.selections[i] or 3 end end)(id),
            setFunc = (function(i) return function(v) HBW.vars.selections[i] = v end end)(id),
            width = "half",
        })
    end

    table.insert(opts, { type = "header", name = "|cFFFF00" .. (lang.insects_header or "Insects") .. "|r" })

    -- Insects (ID 100-104)
    for id = 100, 104 do
        local cat = lang[id][1]
        local drop = lang.dropNames and lang.dropNames[id] or "Unknown"
        local dropId = HBW.InsectDropIds[id]
        local cnt = dropId and GetItemCount(dropId) or 0
        local price = dropId and GetItemPrice(dropId) or nil
        local has = HasLPC()
        
        local coloredCat = "|cFFFF88" .. cat .. "|r"
        local dropStr = "(" .. drop .. ")"
        local countStr = string.format("[%s]", cnt)
        local priceStr = ""
        if price then
            priceStr = " |cFFD700" .. FormatPrice(price) .. "|r"
        elseif has then
            priceStr = " |c888888...|r"
        end
        
        local displayName = string.format("%s %s %s%s", coloredCat, dropStr, countStr, priceStr)
        
        table.insert(opts, {
            type = "dropdown",
            name = displayName,
            choices = choices,
            choicesValues = vals,
            tooltip = price and ("Unit price: " .. string.format("%.2f", price)) or (has and "Price after LPC scan" or "Install LibPriceCache"),
            getFunc = (function(i) return function() return HBW.vars.selections[i] or 3 end end)(id),
            setFunc = (function(i) return function(v) HBW.vars.selections[i] = v end end)(id),
            width = "half",
        })
    end

    if not HasLPC() then
        table.insert(opts, {
            type = "description",
            text = "|cFF0000⚠|r LibPriceCache not installed. Install it to see item prices."
        })
    end

    -- Support section
    table.insert(opts, { type = "header", name = "|cFF8800Support & Donations|r" })
    table.insert(opts, {
        type = "button",
        name = "|t32:32:EsoUI/Art/currency/currency_gold.dds|t Donation for Hyborem's Bugs'n'Weeds",
        tooltip = "Support the developer (opens mail window)",
        func = function()
            SCENE_MANAGER:Show('mailSend')
            zo_callLater(function()
                ZO_MailSendToField:SetText("@HyboremInfernal")
                ZO_MailSendSubjectField:SetText("Donation for Hyborem's Bugs'n'Weeds")
            end, 250)
        end,
        width = "full",
    })
    table.insert(opts, {
        type = "description",
        text = "|cFF8800If you find this addon useful, feel free to send any amount of gold. Much appreciated!|r"
    })

    LAM:RegisterOptionControls("HyboremBugsWeeds_Panel", opts)
end