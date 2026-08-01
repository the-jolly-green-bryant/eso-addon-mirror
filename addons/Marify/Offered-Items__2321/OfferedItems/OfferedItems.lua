OfferedItems = {
    displayName = "|c3CB371" .. "Offered Items" .. "|r",
    shortName = "OI",
    name = "OfferedItems",
    version = "0.9.23",

    ONE_DAY = 60 * 60 * 24,
    ONE_HOUR = 60 * 60,
    ONE_MIN = 60,

    SORT_NAME_DOWN = 1,
    SORT_NAME_UP = 2,
    SORT_TIME_DOWN = 3,
    SORT_TIME_UP = 4,
    SORT_PRICE_DOWN = 5,
    SORT_PRICE_UP = 6,

    SCROLL_LIST_MAX = 660,
    SCROLL_LIST_MIN = 200,

    GUILD_NAME_ALL = "ALL",

    guildIndexForKiosk = nil,
    goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 12, 12),
    sortList = nil,
}

-- [ZO_ScrollList]
-- esoui/libraries/zo_sortfilterlist/zo_sortfilterlist.lua
-- esoui/libraries/zo_templates/scrolltemplates.lua
-- esoui/libraries/zo_templates/scrolltemplates.xml
local SortList = ZO_SortFilterList:Subclass()




function OfferedItems:AddInfo(itemLink)

    if itemLink == nil or itemLink == "" then
        return
    end
    itemLink = self:ConvertedItemLink(itemLink)
    self:Debug("[AddInfo] .. " .. tostring(itemLink))

    local guildName
    local items
    local historys
    local nowTime = os.time()
    local saveTime
    local isSold
    local timeRemaining
    local timeRemainingTxt
    local txts = {}
    local txt
    for guildIndex = 1, GetNumGuilds() do
        guildName = GetGuildName(GetGuildId(guildIndex))

        txt = self:IsListings(guildName, itemLink)
        if txt then
            txts[#txts + 1] = txt
        end
    end
    ItemTooltip:AddLine(table.concat(txts, "\n"), "", 1.0, 1.0, 1.0, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_RIGHT, true)


end




function OfferedItems:ConvertedItemLink(itemLink)
    --local itemType = GetItemLinkItemType(itemLink)
    --if self:ContainsNumber(itemType, ITEMTYPE_TROPHY,
    --                                 ITEMTYPE_RACIAL_STYLE_MOTIF,
    --                                 ITEMTYPE_JEWELRY_TRAIT) then
        local key1, key2 = string.match(itemLink, "|H%d:item:(%d+):%d+:%d+:(.*)")
        return zo_strformat("|H0:item:<<1>>:0:0:<<2>>", key1, key2)
    --else
    --    return itemLink
    --end
end




function OfferedItems:CreateGuildDropdown()

    local function OnItemSelect(_, choiceText, choice)
        local guildId
        for guildIndex = 1, GetNumGuilds() do 
            guildId = GetGuildId(guildIndex)
            if GetGuildName(guildId) == choiceText then
                OfferedItems:ShowListings(guildIndex)
                return
            end
        end
        OfferedItems:ShowListings(0)
    end


    local charDropdown = GetControl(OIListings, "DropdownGuild")
    if charDropdown == nil then
        charDropdown = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)DropdownGuild",
                                                               OIListings,
                                                               "ZO_StatsDropdownRow")
        charDropdown:SetWidth(205)
        charDropdown:SetAnchor(TOPLEFT, OIListingsTitle, TOPLEFT, 0, 8)
        charDropdown:GetNamedChild("Dropdown"):SetWidth(200)
        charDropdown.dropdown:SetSortsItems(false)
    end


    local guildName = GetGuildName(GetGuildId(self.guildIndexForKiosk))
    if guildName == nil or guildName == "" then
        guildName = self.GUILD_NAME_ALL
    end
    charDropdown.dropdown:ClearItems()
    charDropdown.dropdown:SetSelectedItem(guildName)

    local guildId
    local entry
    for guildIndex = 1, GetNumGuilds() do
        guildId = GetGuildId(guildIndex)
        guildName = GetGuildName(guildId)

        if self.savedVariables.hideNoTrader then
            if GetGuildOwnedKioskInfo(guildId) then
                entry = charDropdown.dropdown:CreateItemEntry(guildName, OnItemSelect)
                charDropdown.dropdown:AddItem(entry)
            end

        elseif self.savedVariables.isShown[guildName] then
                entry = charDropdown.dropdown:CreateItemEntry(guildName, OnItemSelect)
                charDropdown.dropdown:AddItem(entry)
        end
    end
    entry = charDropdown.dropdown:CreateItemEntry(self.GUILD_NAME_ALL, OnItemSelect)
    charDropdown.dropdown:AddItem(entry)


end




function OfferedItems:CreateMenu()

    self.savedVariables.debugLog = {}
    if self.savedVariables.isLog == nil then
        self.savedVariables.isLog = true
    end
    if self.savedVariables.showTimeRemaining == nil then
        self.savedVariables.showTimeRemaining = true
    end
    if self.savedVariables.showGuildName == nil then
        self.savedVariables.showGuildName = true
    end
    if self.savedVariables.guildNameColor == nil then
        self.savedVariables.guildNameColor = "918955"
    end
    if self.savedVariables.showStack == nil then
        self.savedVariables.showStack = true
    end
    if self.savedVariables.showPrice == nil then
        self.savedVariables.showPrice = true
    end
    if self.savedVariables.showPricePerUnit == nil then
        self.savedVariables.showPricePerUnit = true
    end
    if self.savedVariables.soldNotification == nil then
        self.savedVariables.soldNotification = false
    end
    if self.savedVariables.openStore == nil then
        self.savedVariables.openStore = true
    end
    if self.savedVariables.hideNoTrader == nil then
        self.savedVariables.hideNoTrader = true
    end
    if self.savedVariables.sort == nil then
        self.savedVariables.sort = self.SORT_NAME_DOWN
    end
    if self.savedVariables.listY == nil then
        self.savedVariables.listY = self.SCROLL_LIST_MAX
    end
    if self.savedVariables.offered == nil then
        self.savedVariables.offered = {}
    end
    if self.savedVariables.isShown == nil then
        self.savedVariables.isShown = {}
    end
    for guildIndex = 1, GetNumGuilds() do
        local guildName = GetGuildName(GetGuildId(guildIndex))
        if self.savedVariables.isShown[guildName] == nil then
            self.savedVariables.isShown[guildName] = true
        end
        if self.savedVariables.offered[guildName] == nil then
            self.savedVariables.offered[guildName] = {}
        end
        if self.savedVariables.offered[guildName].saveTime == nil then
            self.savedVariables.offered[guildName].saveTime = os.date("%Y-%m-%d %H:%M:%S[%a]", os.time())
        end
        if self.savedVariables.offered[guildName].items == nil then
            self.savedVariables.offered[guildName].items = {}
        end
        if self.savedVariables.offered[guildName].historys == nil then
            self.savedVariables.offered[guildName].historys = {}
        end
    end
    if self.savedVariables.showMark == nil then
        self.savedVariables.showMark = false
    end
    if self.savedVariables.markSize == nil then
        self.savedVariables.markSize = 32
    end
    if self.savedVariables.markLeft == nil then
        self.savedVariables.markLeft = 0
    end
    if self.savedVariables.markTop == nil then
        self.savedVariables.markTop = 14
    end
    if self.savedVariables.markTexture == nil then
        self.savedVariables.markTexture = "esoui/art/guild/ownership_icon_guildtrader.dds"
    end


    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Marify",
        version = self.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    LibAddonMenu2:RegisterAddonPanel(self.displayName, panelData)


    local optionsTable = {

        {
            type = "header",
            name = GetString(SI_INTERFACE_OPTIONS_TOOLTIPS),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(SI_STAT_GAMEPAD_TIME_REMAINING),
            getFunc = function()
                return self.savedVariables.showTimeRemaining
            end,
            setFunc = function(value)
                self.savedVariables.showTimeRemaining = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(SI_GAMEPAD_GUILD_HUB_GUILD_NAME_HEADER),
            getFunc = function()
                return self.savedVariables.showGuildName
            end,
            setFunc = function(value)
                self.savedVariables.showGuildName = value
            end,
            width = "full",
        },
        {
            type = "colorpicker",
            name = GetString(SI_GUILD_HERALDRY_COLOR)
                    .. "(" .. GetString(SI_GAMEPAD_GUILD_HUB_GUILD_NAME_HEADER) .. ")",
            getFunc = function()
                local rHex, gHex, bHex = string.match(self.savedVariables.guildNameColor, "(..)(..)(..)")
                local r = tonumber(rHex, 16) / 255
                local g = tonumber(gHex, 16) / 255
                local b = tonumber(bHex, 16) / 255
                return r, g, b
            end,
            setFunc = function(r, g, b)
                local colorHex = string.format("%.2x%.2x%.2x", zo_floor(r * 255),
                                                               zo_floor(g * 255),
                                                               zo_floor(b * 255))
                self.savedVariables.guildNameColor = colorHex
            end,
            width = "full",
            disabled = function()
                return (not self.savedVariables.showGuildName)
            end,
        },
        {
            type = "checkbox",
            name = GetString(SI_TRADING_HOUSE_POSTING_QUANTITY),
            getFunc = function()
                return self.savedVariables.showStack
            end,
            setFunc = function(value)
                self.savedVariables.showStack = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(SI_TRADINGHOUSEFEATURECATEGORY6),
            getFunc = function()
                return self.savedVariables.showPrice
            end,
            setFunc = function(value)
                self.savedVariables.showPrice = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(SI_TRADINGHOUSESORTFIELD3),
            getFunc = function()
                return self.savedVariables.showPricePerUnit
            end,
            setFunc = function(value)
                self.savedVariables.showPricePerUnit = value
            end,
            width = "full",
        },


        {
            type = "header",
            name = GetString(OI_MARK) .. "(BETA)",
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(OI_SHOW_MARK),
            requiresReload = true,
            getFunc = function()
                return self.savedVariables.showMark
            end,
            setFunc = function(value)
                self.savedVariables.showMark = value
            end,
            width = "full",
        },
        {
            type = "dropdown",
            name = GetString(OI_CHOICE_MARK),
            requiresReload = true,
            choices = {
                zo_iconFormat("esoui/art/guild/guildhistory_indexicon_guildstore_up.dds", 32, 32),
                zo_iconFormat("esoui/art/guild/tabicon_roster_up.dds", 32, 32),
                zo_iconFormat("esoui/art/inventory/inventory_tabicon_quickslot_up.dds", 32, 32),
                zo_iconFormat("esoui/art/guild/ownership_icon_guildtrader.dds", 32, 32),
                zo_iconFormat("esoui/art/collections/collections_tabicon_housing_up.dds", 32, 32),
                zo_iconFormat("esoui/art/crafting/blueprints_tabicon_up.dds", 32, 32),
                zo_iconFormat("esoui/art/emotes/emotes_indexicon_directions_up.dds", 32, 32),
                zo_iconFormat("esoui/art/guild/guildhistory_indexicon_combat_up.dds", 32, 32),
                zo_iconFormat("esoui/art/guild/guildhistory_indexicon_guild_up.dds", 32, 32),
                zo_iconFormat("esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds", 32, 32),
                },
            choicesValues = {
                "esoui/art/guild/guildhistory_indexicon_guildstore_up.dds",
                "esoui/art/guild/tabicon_roster_up.dds",
                "esoui/art/inventory/inventory_tabicon_quickslot_up.dds",
                "esoui/art/guild/ownership_icon_guildtrader.dds",
                "esoui/art/collections/collections_tabicon_housing_up.dds",
                "esoui/art/crafting/blueprints_tabicon_up.dds",
                "esoui/art/emotes/emotes_indexicon_directions_up.dds",
                "esoui/art/guild/guildhistory_indexicon_combat_up.dds",
                "esoui/art/guild/guildhistory_indexicon_guild_up.dds",
                "esoui/art/tradinghouse/tradinghouse_listings_tabicon_up.dds",
                },
            getFunc = function()
                return self.savedVariables.markTexture
            end,
            setFunc = function(value)
                self.savedVariables.markTexture = value
            end,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(OI_SIZE),
            requiresReload = true,
            min = 16,
            max = 64,
            step = 2,
            getFunc = function()
                return self.savedVariables.markSize
            end,
            setFunc = function(value)
                self.savedVariables.markSize = value
            end,
            disabled = function()
                return (not self.savedVariables.showMark)
            end,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(OI_HORIZONTAL_POS),
            requiresReload = true,
            min = 0,
            max = 520,
            step = 1,
            getFunc = function()
                return self.savedVariables.markLeft
            end,
            setFunc = function(value)
                self.savedVariables.markLeft = value
            end,
            disabled = function()
                return (not self.savedVariables.showMark)
            end,
            width = "full",
        },
        {
            type = "slider",
            name = GetString(OI_VERTICAL_POS),
            requiresReload = true,
            min = 0,
            max = 40,
            step = 1,
            getFunc = function()
                return self.savedVariables.markTop
            end,
            setFunc = function(value)
                self.savedVariables.markTop = value
            end,
            disabled = function()
                return (not self.savedVariables.showMark)
            end,
            width = "full",
        },


        {
            type = "header",
            name = GetString(OI_LISTING),
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(OI_SOLD_NOTIFICATION),
            getFunc = function()
                return self.savedVariables.soldNotification
            end,
            setFunc = function(value)
                self.savedVariables.soldNotification = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(OI_OPEN_STORE),
            getFunc = function()
                return self.savedVariables.openStore
            end,
            setFunc = function(value)
                self.savedVariables.openStore = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = GetString(OI_HIDE_NO_TRADER),
            getFunc = function()
                return self.savedVariables.hideNoTrader
            end,
            setFunc = function(value)
                self.savedVariables.hideNoTrader = value
            end,
            width = "full",
        },
    }


    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        local guildName = GetGuildName(guildId)
        local kioskInfo = ""
        if (not GetGuildOwnedKioskInfo(guildId)) then
            kioskInfo = " (" .. GetString(SI_GUILD_NO_HIRED_TRADER) .. ")"
        end
        
        optionsTable[#optionsTable + 1] = {
            type = "checkbox",
            name = guildName .. kioskInfo,
            getFunc = function()
                return self.savedVariables.isShown[guildName]
            end,
            setFunc = function(value)
                self.savedVariables.isShown[guildName] = value
            end,
            disabled = function()
                return self.savedVariables.hideNoTrader
            end,
            width = "full",
        }
    end

    optionsTable[#optionsTable + 1] = {
        type = "header",
        name = GetString(DA_OTHER_HEADER),
        width = "full",
    }
    optionsTable[#optionsTable + 1] = {
        type = "checkbox",
        name = GetString(OI_LOG),
        getFunc = function()
            return self.savedVariables.isLog
        end,
        setFunc = function(value)
            self.savedVariables.isLog = value
        end,
        width = "full",
        default = true,
    }
    optionsTable[#optionsTable + 1] = {
        type = "checkbox",
        name = GetString(OI_DEBUG_LOG),
        getFunc = function()
            return self.savedVariables.isDebug
        end,
        setFunc = function(value)
            self.savedVariables.isDebug = value
        end,
        width = "full",
        default = false,
    }

    LibAddonMenu2:RegisterOptionControls(self.displayName, optionsTable)
end




function OfferedItems:GetItems(guildName)

    local guildNames = {}
    if guildName and guildName ~= self.GUILD_NAME_ALL then
        table.insert(guildNames, guildName)
    else
        for guildIndex = 1, GetNumGuilds() do
            guildName = GetGuildName(GetGuildId(guildIndex))
            table.insert(guildNames, guildName)
        end
    end
    if #guildNames == 0 then
        return nil
    end


    local itemsAll
    local nowTime = os.time()
    local saveTime
    local items
    local historys
    local isSold
    local timeRemaining
    for _, guildName in ipairs(guildNames) do
        items = self.savedVariables.offered[guildName].items
        historys = self.savedVariables.offered[guildName].historys

        if items and #items > 0 then
            saveTime = self:GetSaveTime(guildName)
            for _, item in ipairs(items) do
                isSold = false
                for i, history in pairs(historys) do
                    if item.itemLink == history.itemLink
                        and item.stackCount == history.stackCount
                        and item.purchasePrice == history.purchasePrice then
                        isSold = true
                        table.remove(historys, i)
                        break
                    end
                end

                timeRemaining = os.difftime(saveTime + item.timeRemaining, nowTime)
                if (not isSold) and (timeRemaining > 0) then
                    if itemsAll == nil then
                        itemsAll = {}
                    end
                    item.timeRemainingTxt = self:GetTimeRemainingTxt(timeRemaining)
                    table.insert(itemsAll, item)
                end
            end
        end
    end
    return itemsAll
end




function OfferedItems:GetSaveTime(guildName)

    local saveTimeTxt = self.savedVariables.offered[guildName].saveTime
    local year, month, day, hour, min, sec = string.match(saveTimeTxt, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+).*")
    local saveTime = os.time({
        ["year"] = tonumber(year),
        ["month"] = tonumber(month),
        ["day"] = tonumber(day),
        ["hour"] = tonumber(hour),
        ["min"] = tonumber(min),
        ["sec"] = tonumber(sec),})
    return saveTime
end




function OfferedItems:GetTimeRemainingTxt(timeRemaining)

    if timeRemaining > self.ONE_DAY then -- 1Day
        return zo_strformat(GetString(SI_TIME_FORMAT_DAYS), math.floor(timeRemaining / self.ONE_DAY + 0.5))

    elseif timeRemaining > self.ONE_HOUR then -- 1H
        return zo_strformat(GetString(SI_TIME_FORMAT_HOURS), math.floor(timeRemaining / self.ONE_HOUR + 0.5))

    elseif timeRemaining > self.ONE_MIN then -- 1Min
        return zo_strformat(GetString(SI_TIME_FORMAT_MINUTES), math.floor(timeRemaining / self.ONE_MIN + 0.5))

    else
        return GetString(SI_TIME_DURATION_NOT_LONG_AGO)
    end
end




function OfferedItems:IsListings(guildName, itemLink)

    if guildName == nil then
        return nil
    end
    if itemLink == nil or itemLink == "" then
        return
    end

    self:Debug("　　[IsListings] (" .. tostring(guildName) .. ")")
    local items = self.savedVariables.offered[guildName].items
    if items == nil then
        self:Debug("　　items is nil")
        return nil
    end


    local historys = self.savedVariables.offered[guildName].historys
    local saveTime = self:GetSaveTime(guildName)
    local isSold
    local nowTime = os.time()
    local timeRemaining
    for _, item in ipairs(items) do
        if item.itemLink == itemLink then
            self:Debug("　　　　item.itemLink=" .. tostring(item.itemLink))

            isSold = false
            for _, history in pairs(historys) do
                if item.itemLink == history.itemLink
                    and item.stackCount == history.stackCount
                    and item.purchasePrice == history.purchasePrice then
                    isSold = true
                    break
                end
            end

            timeRemaining = os.difftime(saveTime + item.timeRemaining, nowTime)
            if (not isSold) and (timeRemaining > 0) then

                local txt = ""
                if self.savedVariables.showTimeRemaining then
                    local timeRemainingTxt = self:GetTimeRemainingTxt(timeRemaining)
                    txt = txt .. zo_strformat("<<1>>　　", timeRemainingTxt)
                end

                if self.savedVariables.showGuildName then
                    txt = txt .. zo_strformat(GetString(OI_GUILD_NAME), self.savedVariables.guildNameColor, guildName)
                else
                    txt = txt .. GetString(OI_IN_SALE)
                end

                if self.savedVariables.showStack then
                    txt = txt .. zo_strformat("<<1>>|cA9A9A9x|r　　", item.stackCount)
                end

                if self.savedVariables.showPrice then
                    txt = txt .. zo_strformat("<<1>><<2>>", item.purchasePrice, self.goldIcon)
                end

                if self.savedVariables.showPricePerUnit and item.stackCount > 1 then
                    txt = txt .. zo_strformat("(@<<1>><<2>>)", item.purchasePricePerUnit, self.goldIcon)
                end

                return txt
            end

        end
    end
    return nil

end




function OfferedItems:OnAddOnLoaded(event, addonName)

    if addonName ~= OfferedItems.name then
        return
    end
    setmetatable(OfferedItems, {__index = LibMarify})


    self.savedVariables = ZO_SavedVars:NewAccountWide("OfferedItemsVariables", 1, nil, {})
    self:CreateMenu()
    ZO_CreateStringId("SI_BINDING_NAME_OI_TOGGLE", GetString(OI_TOGGLE))


    zo_callLater(function()
        self:PostHook(ItemTooltip,       "SetBagItem",             function(obj, ...) self:AddInfo(GetItemLink(...)) end)
        self:PostHook(ItemTooltip,       "SetWornItem",            function(obj, ...) self:AddInfo(GetItemLink(BAG_WORN, ...)) end)
        self:PostHook(ItemTooltip,       "SetStoreItem",           function(obj, ...) self:AddInfo(GetStoreItemLink(...)) end)
        self:PostHook(ItemTooltip,       "SetTradingHouseListing", function(obj, ...) self:AddInfo(GetTradingHouseListingItemLink(...)) end)
        self:PostHookForAGS(ItemTooltip, "SetTradingHouseItem",    function(obj, ...) self:AddInfo(GetTradingHouseSearchResultItemLink(...)) end)
    end, 5000)

    if self.savedVariables.showMark then
        self:PostHook(ZO_PlayerInventoryBackpack.dataTypes[1], "setupCallback",               function(...) self:UpdateInventory(...) end)
        self:PostHook(ZO_StoreWindowList.dataTypes[1],         "setupCallback",               function(...) self:UpdateInventory(...) end)
        self:PostHook(ZO_PlayerBankBackpack.dataTypes[1],      "setupCallback",               function(...) self:UpdateInventory(...) end)
        self:PostHook(ZO_GuildBankBackpack.dataTypes[1],       "setupCallback",               function(...) self:UpdateInventory(...) end)
        self:PostHook(ZO_HouseBankBackpack.dataTypes[1],       "setupCallback",               function(...) self:UpdateInventory(...) end)
        self:PostHook(ZO_CraftBagList.dataTypes[1],            "setupCallback",               function(...) self:UpdateInventory(...) end)
    end

    self:PostHook(TRADING_HOUSE, "RebuildListingsScrollList",                             function(obj, ...) self:Save() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_GUILD_HISTORY_RESPONSE_RECEIVED,      function(...) self:SaveHistory(...) end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_TRADING_HOUSE,                  function(...) self:OnClickedClose() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CLOSE_STORE,                          function(...) self:OnClickedClose() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_TRADING_HOUSE,                   function(...) self:OpenTradingHouse() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_TRADING_HOUSE_SELECTED_GUILD_CHANGED, function(...) self:OpenTradingHouse() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OPEN_STORE,                           function(...) self:OpenStore() end)

end
EVENT_MANAGER:RegisterForEvent(OfferedItems.name, EVENT_ADD_ON_LOADED, function(...) OfferedItems:OnAddOnLoaded(...) end)




function OfferedItems:OnClickedClose()
    self:Debug("[OnClickedClose(" .. tostring(self.guildIndexForKiosk) .. ")]")
    self.guildIndexForKiosk = (self.guildIndexForKiosk or 0) - 1
    self.guildIndexForKiosk = math.max(self.guildIndexForKiosk, - 1)
    OIListings:SetHidden(true)
end




function OfferedItems:OnClickedMinus()

    _, self.savedVariables.listY = OIListingsList:GetDimensions()
    self.savedVariables.listY = math.max(self.savedVariables.listY - 200, self.SCROLL_LIST_MIN)
    self:ShowListings(self.guildIndexForKiosk)
end




function OfferedItems:OnClickedPlus()

    _, self.savedVariables.listY = OIListingsList:GetDimensions()
    self.savedVariables.listY = math.min(self.savedVariables.listY + 200, self.SCROLL_LIST_MAX)
    self:ShowListings(self.guildIndexForKiosk)
end




function OfferedItems:OnClickedSort(sort)

    self.savedVariables.sort = sort
    self:ShowListings(self.guildIndexForKiosk)
end




function OfferedItems:OnMoveListings()

    self.savedVariables.listingsTop = OIListings:GetTop()
    self.savedVariables.listingsLeft = OIListings:GetLeft()
end




function OfferedItems:OpenStore()

    local _, name = GetGameCameraInteractableActionInfo()
    self:Debug("[OpenStore (" .. tostring(name) .. "]")
    if self:Contains(name, self:GetStoreNPC()) then
        if self.savedVariables.openStore then
            self:ShowListings(0)
        end
    end
end




function OfferedItems:OpenTradingHouse()
    self:Debug("[OpenTradingHouse]")
    if self.savedVariables.openStore or (not OIListings:IsHidden()) then
        local guildIndex = 0
        local id = GetSelectedTradingHouseGuildId() or 0
        for idx = 1, GetNumGuilds() do
            if GetGuildId(idx) == id then
                guildIndex = idx
                break
            end
        end
        self:ShowListings(guildIndex)
    end
end




function OfferedItems:Save()

    local guildId, guildName = GetCurrentTradingHouseGuildDetails()
    if guildName == nil then
        return
    end
    self:Debug("[Save(" .. tostring(guildName) .. "]")


    local offered = self.savedVariables.offered[guildName]
    if offered == nil then
        offered = {}
        self.savedVariables.offered[guildName] = offered
    end

    local nowTime = os.time()
    offered.saveTime = os.date("%Y-%m-%d %H:%M:%S[%a]", nowTime)
    offered.items = {}
    offered.historys = {}
    local items = offered.items


    local numListings = GetNumTradingHouseListings()
    if numListings == 0 then
        return
    end
    for index = 1, numListings do
        local icon, name, quality, stackCount, sellerName, timeRemaining, purchasePrice, currencyType, itemUniqueId, purchasePricePerUnit
            = GetTradingHouseListingItemInfo(index)
        local itemLink = GetTradingHouseListingItemLink(index)
        if itemLink then
            local item = {}
            item.icon = icon
            item.name = name
            item.stackCount = stackCount
            item.timeRemaining = timeRemaining
            item.timeLimit = os.date("%Y-%m-%d %H:%M:%S[%a]", nowTime + timeRemaining)
            item.purchasePrice = purchasePrice
            item.purchasePricePerUnit = purchasePricePerUnit
            item.itemLink = self:ConvertedItemLink(itemLink)
            item.itemUniqueId = itemUniqueId
            items[#items + 1] = item
        end
    end
    self:Sort(items)

    if (not OIListings:IsHidden()) then
        zo_callLater(function()
            OfferedItems:ShowListings(self.guildIndexForKiosk)
        end, 1000)
    end
end




function OfferedItems:SaveHistory(eventCode, guildId, category)

    if category ~= GUILD_HISTORY_STORE then
        return
    end

    local guildName = GetGuildName(guildId)
    self:Debug("[SaveHistory]" .. tostring(guildName))
    local saveTime = self.savedVariables.offered[guildName].saveTime
    if saveTime == nil then
        return
    end

    local year, month, day, hour, min, sec = string.match(saveTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+).*")
    local saveSec = os.time({
        ["year"] = tonumber(year),
        ["month"] = tonumber(month),
        ["day"] = tonumber(day),
        ["hour"] = tonumber(hour),
        ["min"] = tonumber(min),
        ["sec"] = tonumber(sec),
        })


    
    local userName = GetDisplayName()
    local eventId
    local eventType, secsSinceEvent, param1, param2, param3, param4, param5, param6
    local eventMsg
    local formatString
    local nowTime = os.time()
    local historys = self.savedVariables.offered[guildName].historys

    for eventIndex = 1, GetNumGuildEvents(guildId, category) do
        eventId = tostring(GetGuildEventId(guildId, category, eventIndex))
        eventType, secsSinceEvent, param1, param2, param3, param4, param5, param6 = GetGuildEventInfo(guildId, category, eventIndex)


        if (historys[eventId] == nil) and (os.difftime(nowTime - secsSinceEvent, saveSec) > 0) then
            if eventType == GUILD_EVENT_ITEM_SOLD then
                if param1 == userName then
                    if self.savedVariables.soldNotification then
                        formatString = GetString("SI_GUILDEVENTTYPE", eventType)
                        eventMsg = zo_strformat(formatString, param1, param2, param3, param4, param5, param6)
                        self:Message(zo_strformat("<<1>>:<<2>>", guildName, eventMsg))
                    end
                    local history = {}
                    history.stackCount = param3
                    history.itemLink = self:ConvertedItemLink(param4)
                    history.purchasePrice = param5
                    historys[eventId] = history
                end
            end
        end

    end


    if (not OIListings:IsHidden()) then
        zo_callLater(function()
            OfferedItems:ShowListings(self.guildIndexForKiosk)
        end, 1000)
    end
end




function OfferedItems:ShowListings(guildIndexDef)

    self:Debug("[ShowListings(" .. tostring(guildIndexDef) .. ")]")
    if GetNumGuilds() == 0 then
        return
    end
    self:Debug("　　self.guildIndexForKiosk=" .. tostring(self.guildIndexForKiosk))


    local guildIndex = guildIndexDef
    if guildIndex == nil then
        if self.guildIndexForKiosk then
            self.guildIndexForKiosk = self.guildIndexForKiosk + 1
            guildIndex = self.guildIndexForKiosk
        else
            guildIndex = 0
            local id = GetSelectedTradingHouseGuildId() or 0
            for idx = 1, GetNumGuilds() do
                if GetGuildId(idx) == id then
                    guildIndex = idx
                    break
                end
            end
            self.guildIndexForKiosk = guildIndex
        end
    else
        self.guildIndexForKiosk = guildIndex
    end
    if guildIndex > GetNumGuilds() then
        OIListings:SetHidden(true)
        self.guildIndexForKiosk = -1
        return
    end


    local guildId = GetGuildId(guildIndex)
    local guildName = GetGuildName(guildId)
    self:Debug("　　guildName=" .. tostring(guildId) .. ":" .. tostring(guildName))
    if guildName and guildName ~= "" then
        if self.savedVariables.hideNoTrader then
            if (not GetGuildOwnedKioskInfo(guildId)) then
                if guildIndexDef then
                    OIListings:SetHidden(true)
                    return
                else
                    self:ShowListings(guildIndexDef)
                    return
                end
            end
        else
            if (not self.savedVariables.isShown[guildName]) then
                if guildIndexDef then
                    OIListings:SetHidden(true)
                    self.guildIndexForKiosk = 0
                    return
                else
                    self:ShowListings(guildIndexDef)
                    return
                end
            end
        end
    else
        guildName = self.GUILD_NAME_ALL
    end
    self:Debug("　　>" .. tostring(guildName))


    OIListings:ClearAnchors()
    OIListings:SetAnchor(TOPLEFT, nil, TOPLEFT, self.savedVariables.listingsLeft, self.savedVariables.listingsTop)
    OIListings:SetDimensions(550, 200)
    self:CreateGuildDropdown()
    if self.sortList == nil then
        self.sortList = SortList:New(OIListings)
    end
    local scrollData = ZO_ScrollList_GetDataList(self.sortList.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local items = self:GetItems(guildName)
    if items == nil then
        OIListingsTotal:SetText("")
        OIListingsMessage:SetText(GetString(OI_CHECK_LISTING))
        OIListingsMessage:SetHidden(false)

        OIListingsNameDown:SetHidden(true)
        OIListingsNameUp:SetHidden(true)
        OIListingsTimeDown:SetHidden(true)
        OIListingsTimeUp:SetHidden(true)
        OIListingsPriceDown:SetHidden(true)
        OIListingsPriceUp:SetHidden(true)

        OIListingsList:SetDimensions(550, self.SCROLL_LIST_MIN)
        self.sortList:RefreshData()
        OIListingsPlus:SetHidden(true)
        OIListingsMinus:SetHidden(true)
        OIListingsList:SetHidden(true)
        OIListings:SetHidden(false)
        return
    end
    self:Sort(items)

    local itemIcon
    local txt
    local data
    for i, item in ipairs(items) do
        data = {}
        itemIcon = zo_iconFormat(item.icon, 20, 20)

        if item.stackCount == 1 then
            txt = zo_strformat("<<1>><<2>>", itemIcon, item.itemLink)
        else
            txt = zo_strformat("<<1>><<2>>　　<<3>>|cA9A9A9x|r", itemIcon, item.itemLink, item.stackCount)
        end
        data.row_item = txt
        data.row_limit = item.timeRemainingTxt

        if item.stackCount == 1 then
            txt = zo_strformat("<<1>><<2>>", item.purchasePrice, self.goldIcon)
        else
            txt = zo_strformat("<<1>><<2>>(@<<3>><<2>>)", item.purchasePrice, self.goldIcon, item.purchasePricePerUnit)
        end
        data.row_price = txt
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
    end


    if #items >= 30 and guildName ~= self.GUILD_NAME_ALL then
        OIListingsTotal:SetText(" |cFF9999".. #items .. "|r ".. GetString(SI_INVENTORY_MODE_ITEMS))
    else
        OIListingsTotal:SetText(#items .. " ".. GetString(SI_INVENTORY_MODE_ITEMS))
    end
    OIListingsMessage:SetHidden(true)

    if self.savedVariables.listY >= self.SCROLL_LIST_MAX then
        OIListingsPlus:SetHidden(true)
        OIListingsMinus:SetHidden(false)
    elseif self.savedVariables.listY <= self.SCROLL_LIST_MIN then
        OIListingsPlus:SetHidden(false)
        OIListingsMinus:SetHidden(true)
    else
        OIListingsPlus:SetHidden(false)
        OIListingsMinus:SetHidden(false)
    end
    OIListings:SetHidden(true)
    OIListingsList:SetHidden(true)
    OIListings:SetDimensions(550, 200)

    OIListingsList:SetDimensions(550, self.savedVariables.listY)
    self.sortList:RefreshData()
    OIListingsList:SetHidden(false)
    OIListings:SetHidden(false)
end




function OfferedItems:Sort(items)

    if items == nil then
        return
    end


    local sort = self.savedVariables.sort
    if sort == self.SORT_NAME_UP then
        table.sort(items, function(A, B)
            return A.name < B.name
        end)
        OIListingsNameDown:SetAlpha(1)
        OIListingsNameDown:SetHidden(true)
        OIListingsNameUp:SetHidden(false)

        OIListingsTimeDown:SetAlpha(0.5)
        OIListingsTimeDown:SetHidden(false)
        OIListingsTimeUp:SetHidden(true)

        OIListingsPriceDown:SetAlpha(0.5)
        OIListingsPriceDown:SetHidden(false)
        OIListingsPriceUp:SetHidden(true)

    elseif sort == self.SORT_TIME_DOWN then
        table.sort(items, function(A, B)
            return A.timeRemaining > B.timeRemaining
        end)
        OIListingsNameDown:SetAlpha(0.5)
        OIListingsNameDown:SetHidden(false)
        OIListingsNameUp:SetHidden(true)

        OIListingsTimeDown:SetAlpha(1)
        OIListingsTimeDown:SetHidden(false)
        OIListingsTimeUp:SetHidden(true)

        OIListingsPriceDown:SetAlpha(0.5)
        OIListingsPriceDown:SetHidden(false)
        OIListingsPriceUp:SetHidden(true)

    elseif sort == self.SORT_TIME_UP then
        table.sort(items, function(A, B)
            return A.timeRemaining < B.timeRemaining
        end)
        OIListingsNameDown:SetAlpha(0.5)
        OIListingsNameDown:SetHidden(false)
        OIListingsNameUp:SetHidden(true)

        OIListingsTimeDown:SetAlpha(1)
        OIListingsTimeDown:SetHidden(true)
        OIListingsTimeUp:SetHidden(false)

        OIListingsPriceDown:SetAlpha(0.5)
        OIListingsPriceDown:SetHidden(false)
        OIListingsPriceUp:SetHidden(true)

    elseif sort == self.SORT_PRICE_DOWN then
        table.sort(items, function(A, B)
            return A.purchasePrice > B.purchasePrice
        end)
        OIListingsNameDown:SetAlpha(0.5)
        OIListingsNameDown:SetHidden(false)
        OIListingsNameUp:SetHidden(true)

        OIListingsTimeDown:SetAlpha(0.5)
        OIListingsTimeDown:SetHidden(false)
        OIListingsTimeUp:SetHidden(true)

        OIListingsPriceDown:SetAlpha(1)
        OIListingsPriceDown:SetHidden(false)
        OIListingsPriceUp:SetHidden(true)

    elseif sort == self.SORT_PRICE_UP then
        table.sort(items, function(A, B)
            return A.purchasePrice < B.purchasePrice
        end)
        OIListingsNameDown:SetAlpha(0.5)
        OIListingsNameDown:SetHidden(false)
        OIListingsNameUp:SetHidden(true)

        OIListingsTimeDown:SetAlpha(0.5)
        OIListingsTimeDown:SetHidden(false)
        OIListingsTimeUp:SetHidden(true)

        OIListingsPriceDown:SetAlpha(1)
        OIListingsPriceDown:SetHidden(true)
        OIListingsPriceUp:SetHidden(false)
    else
        table.sort(items, function(A, B)
            return A.name > B.name
        end)
        OIListingsNameDown:SetAlpha(1)
        OIListingsNameDown:SetHidden(false)
        OIListingsNameUp:SetHidden(true)

        OIListingsTimeDown:SetAlpha(0.5)
        OIListingsTimeDown:SetHidden(false)
        OIListingsTimeUp:SetHidden(true)

        OIListingsPriceDown:SetAlpha(0.5)
        OIListingsPriceDown:SetHidden(false)
        OIListingsPriceUp:SetHidden(true)
    end
end




function OfferedItems:UpdateInventory(control)

    self:Debug("[UpdateInventory]")
    if control == nil then
        self:Debug("　　control is nil")
        return
    end

    local listingsMark = control:GetNamedChild("OI_ListingsMark")
    if listingsMark then
        listingsMark:SetHidden(true)
    end


    local slot = control.dataEntry.data
    if slot == nil then
        self:Debug("　　slot is nil")
        return
    end
    local itemLink
    if slot.bagId == nil then
        itemLink = GetStoreItemLink(slot.slotIndex)
    else
        itemLink = GetItemLink(slot.bagId, slot.slotIndex)
    end
    if itemLink == nil or itemLink == "" then
        self:Debug("　　itemLink is nil (bagId=" .. tostring(slot.bagId) .. ", slotIndex=" .. tostring(slot.slotIndex) .. ")")
        return
    end
    itemLink = self:ConvertedItemLink(itemLink)
    self:Debug("　　itemLink=" .. tostring(itemLink))


    local guildName
    for guildIndex = 1, GetNumGuilds() do
        guildName = GetGuildName(GetGuildId(guildIndex))

        if self:IsListings(guildName, itemLink) then
            if listingsMark == nil then
                local markSize = self.savedVariables.markSize
                local markLeft = self.savedVariables.markLeft
                local markTop = self.savedVariables.markTop
                local markTexture = self.savedVariables.markTexture
                listingsMark = WINDOW_MANAGER:CreateControl(control:GetName() .. "OI_ListingsMark", control, CT_TEXTURE)
                listingsMark:SetDrawLayer(3)
                listingsMark:SetDimensions(markSize, markSize)
                listingsMark:ClearAnchors()
                listingsMark:SetAnchor(LEFT, control:GetNamedChild('Bg'), LEFT, markLeft, markTop - 10)
                listingsMark:SetTexture(markTexture)
            end
            listingsMark:SetHidden(false)
            break
        end
    end

end




function SortList:GetRowColors(data, mouseIsOver, control)
    return ZO_DEFAULT_ENABLED_COLOR, ZO_DEFAULT_ENABLED_COLOR
end




function SortList:New(control)

    OfferedItems:Debug("New()")
    ZO_SortFilterList.InitializeSortFilterList(self, control)

    local sortKeys = {
        ["row_item"]  = {},
        ["row_limit"] = {tiebreaker = "row_item"},
        ["row_price"] = {tiebreaker = "row_limit"},
    }
    ZO_ScrollList_AddDataType(self.list,
                              1,                        -- typeId
                              "OIListingsRowTemplate",  -- templateName
                              22,                       -- height
                              function(control, data) 
                                  self:SetupEntry(control, data)
                              end)
    ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
    return self
end




function SortList:SetupEntry(control, data)

    control.data = data

    control.row_item = GetControl(control, "RowItem")
    control.row_item:SetText(data.row_item)

    control.row_limit = GetControl(control, "RowLimit")
    control.row_limit:SetText(data.row_limit)

    control.row_price = GetControl(control, "RowPrice")
    control.row_price:SetText(data.row_price)

    ZO_SortFilterList.SetupRow(self, control, data)
end

