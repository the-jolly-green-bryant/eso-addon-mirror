local DA = DropAlert

local function GetItemLinkFromSlot(slot)
    if not slot then return nil end
    local data = (slot.dataEntry and slot.dataEntry.data) or slot
    return GetItemLink(data.bagId, data.slotIndex)
end

function DA:CreateMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end

    if not LibCustomMenu then
        d("[DropAlert] LibCustomMenu not found. Context menu disabled.")
    end

    local MENU_ICON_HIRCINE = "|t32:32:DropAlert/art/hunt.dds|t"
    local MENU_ICON_MORA = "|t32:32:DropAlert/art/mora.dds|t"
    local MENU_ICON_GOLD = "|t32:32:DropAlert/art/gold.dds|t"
    local MENU_ICON_QUAL = "|t32:32:DropAlert/art/pure.dds|t"
    local MENU_ICON_ZENITHAR = "|t32:32:DropAlert/art/zenithar.dds|t"
    local MENU_ICON_HYBOREM = "|t32:32:DropAlert/art/hyborem.dds|t"

    local panelData = {
        type = "panel",
        name = "Drop Alert",
        author = "Hyborem & Gemini & DeepSeek",
        version = "1.0.26",
        registerForRefresh = true
    }

    local optionsData = {
        {
            type = "description", 
            text = MENU_ICON_HIRCINE .. " |cADD8E6Hircine's Great Hunt:|r To track items, |cADFF2FRight-Click|r them in your inventory or chat and select '|cADFF2FHunt that item|r'.",
            fontSize = "medium"
        },
        {type = "header", name = MENU_ICON_QUAL .. " |c00FF7FMeridia's Purity (Quality)|r"},
        {
            type = "checkbox", 
            name = "Enable Quality Alerts", 
            getFunc = function() return DA.vars.enableQualityAlerts ~= false end,
            setFunc = function(v) DA.vars.enableQualityAlerts = v end
        },
        {
            type = "dropdown", 
            name = "Minimum Quality to Alert", 
            choices = {"|cFFFFFFWhite|r", "|c2DC50EGreen|r", "|c3A92FFBlue|r", "|cA335EEPurple|r", "|cE6B222Gold|r"},
            getFunc = function() 
                local r = {[1]="|cFFFFFFWhite|r",[2]="|c2DC50EGreen|r",[3]="|c3A92FFBlue|r",[4]="|cA335EEPurple|r",[5]="|cE6B222Gold|r"} 
                return r[DA.vars.minQuality] or "|cA335EEPurple|r" 
            end,
            setFunc = function(v) 
                local m = {["|cFFFFFFWhite|r"]=1,["|c2DC50EGreen|r"]=2,["|c3A92FFBlue|r"]=3,["|cA335EEPurple|r"]=4,["|cE6B222Gold|r"]=5} 
                DA.vars.minQuality = m[v] 
            end,
            disabled = function() return DA.vars.enableQualityAlerts == false end
        },
        {type = "header", name = MENU_ICON_MORA .. " |c00BFFFHermaeus Mora's Knowledge|r"},
        {type = "checkbox", name = "Recipes", getFunc = function() return DA.vars.alertRecipes end, setFunc = function(v) DA.vars.alertRecipes = v end},
        {type = "checkbox", name = "Plans", getFunc = function() return DA.vars.alertPlans end, setFunc = function(v) DA.vars.alertPlans = v end},
        {type = "checkbox", name = "Motifs", getFunc = function() return DA.vars.alertMotifs end, setFunc = function(v) DA.vars.alertMotifs = v end},
        {type = "header", name = MENU_ICON_ZENITHAR .. " |cE066FFZenithar's Labor (Master Writs)|r"},
        {type = "checkbox", name = "Alert on Master Writs", getFunc = function() return DA.vars.alertWrits end, setFunc = function(v) DA.vars.alertWrits = v end},
        {type = "header", name = MENU_ICON_GOLD .. " |c32CD32Clavicus Vile's Bargain (Price)|r"},
        {
            type = "description",
            text = function()
                if LibPriceCache and LibPriceCache.GetPrice then
                    return "|c00FF00LibPriceCache detected. Price alerts active.|r"
                else
                    return "|cFF8800LibPriceCache not detected. Price alerts will not work.|r"
                end
            end,
        },
        {
            type = "checkbox", 
            name = "Enable Price Alerts", 
            getFunc = function() return DA.vars.enableAlerts == true end,
            setFunc = function(v) DA.vars.enableAlerts = v end,
        },
        {
            type = "editbox", 
            name = "Min Price", 
            getFunc = function() return tostring(DA.vars.alertMinPrice) end, 
            setFunc = function(v) DA.vars.alertMinPrice = tonumber(v) or 0 end,
            disabled = function() return not DA.vars.enableAlerts end
        },
        {type = "header", name = MENU_ICON_HYBOREM .. " |cFFFFFFSupport|r"},
        {
            type = "button", 
            name = "Donate", 
            func = function() 
                SCENE_MANAGER:Show('mailSend') 
                zo_callLater(function() 
                    ZO_MailSendToField:SetText("@HyboremInfernal") 
                    ZO_MailSendSubjectField:SetText("DropAlert Support (Manual: 5000g)") 
                end, 250) 
            end
        },
    }

    LAM:RegisterAddonPanel("DropAlert_Menu", panelData)
    LAM:RegisterOptionControls("DropAlert_Menu", optionsData)

    if LibCustomMenu and LibCustomMenu.RegisterContextMenu then
        LibCustomMenu:RegisterContextMenu(function(inventorySlot, slotActions)
            local link = GetItemLinkFromSlot(inventorySlot)
            if not link or link == "" then return end
            local id = GetItemLinkItemId(link)
            if not DA.vars.customItems then DA.vars.customItems = {} end
            AddCustomMenuItem("|cADD8E6Hircine's Great Hunt|r", nil, MENU_ADD_OPTION_LABEL)
            if DA.vars.customItems[id] then
                AddCustomMenuItem("|cFF0000Ignore the Prey|r", function() DA.vars.customItems[id] = nil end)
            else
                AddCustomMenuItem("|cADFF2FHunt that item|r", function() DA.vars.customItems[id] = true end)
            end
        end, LibCustomMenu.CATEGORY_LATE)
    end
end