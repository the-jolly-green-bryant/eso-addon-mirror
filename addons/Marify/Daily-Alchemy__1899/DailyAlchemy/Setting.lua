



function DailyAlchemy:CreateMenu()

    self.savedVariables.debugLog = {}
    if self.savedVariables.isAcquireItem == nil then
        self.savedVariables.isAcquireItem = true
    end
    if self.savedVariables.acquireDelay == nil then
        self.savedVariables.acquireDelay = 1
    end
    if self.savedVariables.isLog == nil then
        self.savedVariables.isLog = true
    end
    if self.savedVariables.isDebugQuest == nil then
        self.savedVariables.isDebugQuest = true
    end


    self.savedVariables.showPrice = nil -- Todo: Delete
    self.MAX_ITEM_INDEX = #self:GetMenuItemIdList()


    local panelData = {
        type = "panel",
        reference = "DASettingControl",
        name = self.displayName,
        displayName = self.displayName,
        author = "Marify",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local panel = LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)


    local submenuFunction = LAMCreateControl["submenu"]
    LAMCreateControl["submenu"] = function(parent, submenuData, controlName)
        local control = submenuFunction(parent, submenuData, controlName)
        if (not control) then
            return control
        end
        if parent ~= panel then
            return control
        end
        if submenuData.reference == "PriorityByManual"  then
            control:SetHidden(self.savedVariables.priorityBy ~= self.DA_PRIORITY_BY_MANUAL)
        end
        return control
    end

    local dropdownFunction = LAMCreateControl["dropdown"]
    LAMCreateControl["dropdown"] = function(parent, dropdownData, controlName)
        local control = dropdownFunction(parent, dropdownData, controlName)
        if (not control) then
            return control
        end
        if parent ~= PriorityByManual then
            return control
        end
        if self:Contains(dropdownData.reference, {"Reagent"}) then
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 340, 0)
        end
        return control
    end


    local optionsTable = {
        {
            type = "header",
            name = GetString(DA_PRIORITY_HEADER),
            width = "full",
        },
        self:CreateMenuForPriority(),
        self:CreateMenuForManual(),
        {
            type = "header",
            name = GetString(DA_BULK_HEADER),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(DA_BULK_FLG),
            tooltip = GetString(DA_BULK_FLG_TOOLTIP),
            getFunc = function()
                return self.savedVariables.bulkQuantity
            end,
            setFunc = function(value)
                if value then
                    self.savedVariables.bulkQuantity = 1
                else
                    self.savedVariables.bulkQuantity = nil
                end
            end,
            width = "full",
            default = false,
        },
        {
            type = "slider",
            name = GetString(DA_BULK_COUNT),
            tooltip = GetString(DA_BULK_COUNT_TOOLTIP),
            min = 1,
            max = 100,
            step = 1,
            disabled = function()
                return (not self.savedVariables.bulkQuantity)
            end,
            getFunc = function()
                return self.savedVariables.bulkQuantity
            end,
            setFunc = function(value)
                self.savedVariables.bulkQuantity = tonumber(value)
            end,
            width = "full",
            default = 1,
        },
        {
            type = "header",
            name = GetString(DA_OTHER_HEADER),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(DA_ACQUIRE_ITEM),
            getFunc = function()
                return self.savedVariables.isAcquireItem
            end,
            setFunc = function(value)
                self.savedVariables.isAcquireItem = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "slider",
            name = GetString(DA_DELAY),
            tooltip = GetString(DA_DELAY_TOOLTIP),
            min = 0,
            max = 10,
            step = 0.5,
            disabled = function()
                return (not self.savedVariables.isAcquireItem)
            end,
            getFunc = function()
                return self.savedVariables.acquireDelay
            end,
            setFunc = function(value)
                self.savedVariables.acquireDelay = tonumber(value)
            end,
            width = "full",
            default = 1,
        },
        {
            type = "checkbox",
            name = GetString(DA_AUTO_EXIT),
            tooltip = GetString(DA_AUTO_EXIT_TOOLTIP),
            getFunc = function()
                return self.savedVariables.isAutoExit
            end,
            setFunc = function(value)
                self.savedVariables.isAutoExit = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = GetString(DA_LOG),
            getFunc = function()
                return self.savedVariables.isLog
            end,
            setFunc = function(value)
                self.savedVariables.isLog = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "checkbox",
            name = GetString(DA_DEBUG_LOG),
            getFunc = function()
                return self.savedVariables.isDebug
            end,
            setFunc = function(value)
                self.savedVariables.isDebug = value
                DA_IsDebugSettings:SetHidden(not value)
                DA_IsDebugQuest:SetHidden(not value)
                DA_IsDebugSolvent:SetHidden(not value)
                DA_IsDebugTrait:SetHidden(not value)
                DA_IsDebugReagent:SetHidden(not value)
                DA_IsDebugPriority:SetHidden(not value)
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DA_DEBUG_LOG), GetString(SI_GAME_MENU_SETTINGS)),
            getFunc = function()
                DA_IsDebugSettings:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugSettings
            end,
            setFunc = function(value)
                self.savedVariables.isDebugSettings = value
            end,
            width = "full",
            default = true,
            reference = "DA_IsDebugSettings",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DA_DEBUG_LOG), GetString(SI_QUEST_JOURNAL_MENU_JOURNAL)),
            getFunc = function()
                DA_IsDebugQuest:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugQuest
            end,
            setFunc = function(value)
                self.savedVariables.isDebugQuest = value
            end,
            width = "full",
            default = true,
            reference = "DA_IsDebugQuest",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>/<<3>>)", GetString(DA_DEBUG_LOG),
                                                      GetString(SI_ITEMTYPE33),
                                                      GetString(SI_ITEMTYPE58)),
            getFunc = function()
                DA_IsDebugSolvent:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugSolvent
            end,
            setFunc = function(value)
                self.savedVariables.isDebugSolvent = value
            end,
            width = "full",
            default = false,
            reference = "DA_IsDebugSolvent",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DA_DEBUG_LOG),
                                                GetString(SI_MASTER_WRIT_DESCRIPTION_TRAIT)),
            getFunc = function()
                DA_IsDebugTrait:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugTrait
            end,
            setFunc = function(value)
                self.savedVariables.isDebugTrait = value
            end,
            width = "full",
            default = false,
            reference = "DA_IsDebugTrait",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DA_DEBUG_LOG),
                                                GetString(SI_ITEMTYPE31)),
            getFunc = function()
                DA_IsDebugReagent:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugReagent
            end,
            setFunc = function(value)
                self.savedVariables.isDebugReagent = value
            end,
            width = "full",
            default = false,
            reference = "DA_IsDebugReagent",
        },
        {
            type = "checkbox",
            name = zo_strformat("<<1>>(<<2>>)", GetString(DA_DEBUG_LOG),
                                                GetString(DA_PRIORITY_HEADER)),
            getFunc = function()
                DA_IsDebugPriority:SetHidden(not self.savedVariables.isDebug)
                return self.savedVariables.isDebugPriority
            end,
            setFunc = function(value)
                self.savedVariables.isDebugPriority = value
            end,
            width = "full",
            default = false,
            reference = "DA_IsDebugPriority",
        },
    }

    if FCOIS then
        local tableRow = {
            type = "checkbox",
            name = GetString(DA_ITEM_LOCK),
            getFunc = function()
                return self.savedVariables.useItemLock
            end,
            setFunc = function(value)
                self.savedVariables.useItemLock = value
            end,
            width = "full",
            default = true,
        }
        table.insert(optionsTable, 8, tableRow)
    end
    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)


    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(newPanel)
        if (newPanel == panel) then
            local saveVer = self.savedVariables
            if saveVer.showPriceMM or saveVer.showPriceTTC or saveVer.showPriceATT then
                self:RefreshMenuForManual()
                LibAddonMenu2.util.RequestRefreshIfNeeded(PriorityByManual)
            end
        end
    end)
end




function DailyAlchemy:CreateMenuForPriority()

    local priorityList = {
        {self.DA_PRIORITY_BY_MM, GetString(DA_PRIORITY_BY_MM)},
        {self.DA_PRIORITY_BY_TTC,GetString(DA_PRIORITY_BY_TTC) },
        {self.DA_PRIORITY_BY_ATT, GetString(DA_PRIORITY_BY_ATT)},
        {self.DA_PRIORITY_BY_STOCK, GetString(DA_PRIORITY_BY_STOCK)},
        {self.DA_PRIORITY_BY_MANUAL, GetString(DA_PRIORITY_BY_MANUAL)},
        }

    -- Default
    if (not self.savedVariables.priorityBy) then
        self.savedVariables.priorityBy = self.DA_PRIORITY_BY_STOCK
    end

    -- Low price (When reset, select the next price type)
    local oldPriorityName
    if (not MasterMerchant) then
        priorityList[1] = nil
        if self.savedVariables.priorityBy == self.DA_PRIORITY_BY_MM then
            oldPriorityName = "MasterMerchant"
            self.savedVariables.priorityBy = nil
        end
    end
    if (not TamrielTradeCentre) then
        priorityList[2] = nil
        if self.savedVariables.priorityBy == self.DA_PRIORITY_BY_TTC then
            oldPriorityName = "TamrielTradeCentre"
            self.savedVariables.priorityBy = nil
        end
    end
    if (not ArkadiusTradeTools) or (not ArkadiusTradeTools.Modules) or (not ArkadiusTradeTools.Modules.Sales) then
        priorityList[3] = nil
        if self.savedVariables.priorityBy == self.DA_PRIORITY_BY_ATT then
            oldPriorityName = "ArkadiusTradeTools"
            self.savedVariables.priorityBy = nil
        end
    end

    local values = {}
    local displays = {}
    for key, priority in pairs(priorityList) do
        if priority then
            values[#values + 1] = priority[1]
            displays[#displays + 1] = priority[2]
        end
    end
    if oldPriorityName then
        self.savedVariables.priorityBy = values[1]
        local txt = "|c88aaff" .. self.name .. ":|r "
                    .. zo_strformat(GetString(DA_PRIORITY_CHANGED), GetString(DA_PRIORITY_HEADER), oldPriorityName)
        self:Debug(txt)
    end


    local menu = {
        type = "dropdown",
        name = GetString(DA_PRIORITY_BY),
        choices = displays,
        choicesValues = values,
        getFunc = function()
            return self.savedVariables.priorityBy
        end,
        setFunc = function(value)
            self.savedVariables.priorityBy = value

            local isManual = (value == self.DA_PRIORITY_BY_MANUAL)
            PriorityByManual:SetHidden(not isManual)
            if (isManual) and (PriorityByManual.open) then
                return
            elseif (not isManual) and (not PriorityByManual.open) then
                return
            end
            local laben = PriorityByManual.label
            laben:GetHandler("OnMouseUp")(laben, true)
        end,
        width = "full",
    }
    return menu
end




function DailyAlchemy:GetMenuItemIdList()

    local list = {
        30148,  -- 1:blue entoloma
        30149,  -- 2:stinkhorn
        30151,  -- 3:emetic russula
        30152,  -- 4:violet coprinus
        30153,  -- 5:namira's rot
        30154,  -- 6:white cap
        30155,  -- 7:luminous russula
        30156,  -- 8:imp stool
        30157,  -- 9:blessed thistle
        30158,  -- 10:lady's smock
        30159,  -- 11:wormwood
        30160,  -- 12:bugloss
        30161,  -- 13:corn flower
        30162,  -- 14:dragonthorn
        30163,  -- 15:mountain flower
        30164,  -- 16:columbine
        30165,  -- 17:nirnroot
        30166,  -- 18:water hyacinth
        77581,  -- 19:Torchbug Thorax
        77583,  -- 20:Beetle Scuttle
        77584,  -- 21:Spider Egg
        77585,  -- 22:Butterfly Wing
        77587,  -- 23:Fleshfly Larva||Fleshfly Larvae
        77589,  -- 24:Scrib Jelly
        77590,  -- 25:Nightshade
        77591,  -- 26:Mudcrab Chitin
        139019, -- 27:Powdered Mother of Pearl
        139020, -- 28:Clam Gall
        150731, -- 29:Dragon's Blood
        150789, -- 30:Dragon's Bile
        150671, -- 31:Dragon Rheum
        150669, -- 32:Chaurus Egg
        150670, -- 33:Vile Coagulant
        150672, -- 34:Crimson Nirnroot
    }
    return list
end




function DailyAlchemy:CreateMenuForManual()

    local formatText = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    local itemIdList = self:GetMenuItemIdList()
    local displays = {}
    local values = {}
    for i, itemId in ipairs(itemIdList) do
        local itemLink = zo_strformat(formatText, itemId)
        local icon = GetItemLinkIcon(itemLink)
        displays[#displays + 1] = zo_iconFormat(icon, 18, 18) .. itemLink
        values[#values + 1] = itemId
    end


    if (not self.savedVariables.priorityByManual) then
        self.savedVariables.priorityByManual = {}
        for i, itemId in ipairs(itemIdList) do
            self.savedVariables.priorityByManual[i] = itemId
        end
    end


    local controlList = {}

    if MasterMerchant then
        controlList[#controlList + 1] = {
            type = "checkbox",
            name = zo_strformat(GetString(DA_SHOW_PRICE_MANUAL), "MasterMerchant"),
            getFunc = function()
                return self.savedVariables.showPriceMM
            end,
            setFunc = function(value)
                self.savedVariables.showPriceMM = value
                if value and self.savedVariables.showPriceTTC then
                    self.savedVariables.showPriceTTC = false
                end
                if value and self.savedVariables.showPriceATT then
                    self.savedVariables.showPriceATT = false
                end
                self:RefreshMenuForManual()
                LibAddonMenu2.util.RequestRefreshIfNeeded(PriorityByManual)
            end,
            width = "full",
            default = false,
        }
    else
        self.savedVariables.showPriceMM = false
    end


    if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        controlList[#controlList + 1] = {
            type = "checkbox",
            name = zo_strformat(GetString(DA_SHOW_PRICE_MANUAL), "TamrielTradeCentre"),
            getFunc = function()
                return self.savedVariables.showPriceTTC
            end,
            setFunc = function(value)
                self.savedVariables.showPriceTTC = value
                if value and self.savedVariables.showPriceMM then
                    self.savedVariables.showPriceMM = false
                end
                if value and self.savedVariables.showPriceATT then
                    self.savedVariables.showPriceATT = false
                end
                self:RefreshMenuForManual()
                LibAddonMenu2.util.RequestRefreshIfNeeded(PriorityByManual)
            end,
            width = "full",
            default = false,
        }
    else
        self.savedVariables.showPriceTTC = false
    end


    if ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales then
        controlList[#controlList + 1] = {
            type = "checkbox",
            name = zo_strformat(GetString(DA_SHOW_PRICE_MANUAL), "ArkadiusTradeTools"),
            getFunc = function()
                return self.savedVariables.showPriceATT
            end,
            setFunc = function(value)
                self.savedVariables.showPriceATT = value
                if value and self.savedVariables.showPriceMM then
                    self.savedVariables.showPriceMM = false
                end
                if value and self.savedVariables.showPriceTTC then
                    self.savedVariables.showPriceTTC = false
                end
                self:RefreshMenuForManual()
                LibAddonMenu2.util.RequestRefreshIfNeeded(PriorityByManual)
            end,
            width = "full",
            default = false,
        }
    else
        self.savedVariables.showPriceTTC = false
    end


    for i, itemId in ipairs(itemIdList) do
        local control = {
            type = "dropdown",
            reference = "Reagent".. i,
            choices = displays,
            choicesValues = values,
            name = tostring(i) .. ":",
            getFunc = function()
                return self.savedVariables.priorityByManual[i]
            end,
            setFunc = function(value)
                local oldValue = self.savedVariables.priorityByManual[i]
                for key, reagent in ipairs(self.savedVariables.priorityByManual) do
                    if reagent == value then
                        self.savedVariables.priorityByManual[key] = oldValue
                        break
                    end
                end
                self.savedVariables.priorityByManual[i] = value
            end,
            width = "full",
        }
        controlList[#controlList + 1] = control
    end


    local menu = {
        type = "submenu",
        name = GetString(DA_PRIORITY_BY_MANUAL),
        reference = "PriorityByManual",
        controls = controlList,
    }
    return menu
end




function DailyAlchemy:RefreshMenuForManual()

    self:Debug("[RefreshMenuForManual]")
    local saveVer = self.savedVariables
    self:Debug("　　showPriceMM "  .. tostring(saveVer.showPriceMM))
    self:Debug("　　showPriceTTC " .. tostring(saveVer.showPriceTTC))
    self:Debug("　　showPriceATT " .. tostring(saveVer.showPriceATT))
    local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16)
    local formatText = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    local itemIdList = self:GetMenuItemIdList()
    local list = {}
    local itemLink
    local icon
    local txt
    local price
    for i, itemId in ipairs(itemIdList) do
        itemLink = zo_strformat(formatText, itemId)
        icon = GetItemLinkIcon(itemLink)
        if saveVer.showPriceMM or saveVer.showPriceTTC or saveVer.showPriceATT  then
            price = self:GetAvgPrice(itemLink)
            txt = zo_iconFormat(icon, 18, 18) .. itemLink .. " " .. string.format('%.0f', price) .. goldIcon
            list[#list + 1] = {itemId, txt, price}
        else
            txt = zo_iconFormat(icon, 18, 18) .. itemLink
            list[#list + 1] = {itemId, txt}
        end
    end

    if saveVer.showPriceMM or saveVer.showPriceTTC or saveVer.showPriceATT  then
        table.sort(list, function(a, b)
            return a[3] < b[3]
        end)
    else
        table.sort(list, function(a, b)
            return a[1] < b[1]
        end)
    end

    local displays = {}
    local values = {}
    for i, entry in ipairs(list) do
        values[#values + 1] = entry[1]
        displays[#displays + 1] = entry[2]
    end

    Reagent1:UpdateChoices(displays, values)
    Reagent2:UpdateChoices(displays, values)
    Reagent3:UpdateChoices(displays, values)
    Reagent4:UpdateChoices(displays, values)
    Reagent5:UpdateChoices(displays, values)
    Reagent6:UpdateChoices(displays, values)
    Reagent7:UpdateChoices(displays, values)
    Reagent8:UpdateChoices(displays, values)
    Reagent9:UpdateChoices(displays, values)
    Reagent10:UpdateChoices(displays, values)
    Reagent11:UpdateChoices(displays, values)
    Reagent12:UpdateChoices(displays, values)
    Reagent13:UpdateChoices(displays, values)
    Reagent14:UpdateChoices(displays, values)
    Reagent15:UpdateChoices(displays, values)
    Reagent16:UpdateChoices(displays, values)
    Reagent17:UpdateChoices(displays, values)
    Reagent18:UpdateChoices(displays, values)
    Reagent19:UpdateChoices(displays, values)
    Reagent20:UpdateChoices(displays, values)
    Reagent21:UpdateChoices(displays, values)
    Reagent22:UpdateChoices(displays, values)
    Reagent23:UpdateChoices(displays, values)
    Reagent24:UpdateChoices(displays, values)
    Reagent25:UpdateChoices(displays, values)
    Reagent26:UpdateChoices(displays, values)
    Reagent27:UpdateChoices(displays, values)
    Reagent28:UpdateChoices(displays, values)
    Reagent29:UpdateChoices(displays, values)
    Reagent30:UpdateChoices(displays, values)
    Reagent31:UpdateChoices(displays, values)
    Reagent32:UpdateChoices(displays, values)
    Reagent33:UpdateChoices(displays, values)
    Reagent34:UpdateChoices(displays, values)
end

