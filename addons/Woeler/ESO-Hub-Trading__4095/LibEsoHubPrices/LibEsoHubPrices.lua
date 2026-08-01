local _

-- Set up Namespace
LibEsoHubPrices = {}

local lib = LibEsoHubPrices
lib.name = "LibEsoHubPrices"
lib.shortname = "LibEHP"
lib.version = "20"
lib.addonVersion = 20
lib.internal = {}
local libint = lib.internal
libint.initialized = false
libint.cannotUseInventoryHooks = false
libint.cannotUseInventoryHooksReasons = {}
libint.dataTimeStamp = 0
local fullPriceData = {}

-- Parameters & Locals
local worldToDataKey = {
    ["EU Megaserver"] = "PriceDataEU",
    ["NA Megaserver"] = "PriceDataNA",
    ["PTS"] = "PriceDataEU",
}

local validCraftingStationPanels = {
    ["deconstructionPanel"] = SMITHING,
    ["improvementPanel"] = SMITHING,
    ["refinementPanel"] = SMITHING,
}

-- Debugging

local logger
local AllowedDebugNames = {

    ["@Solinur"] = true,
    -- [GetDisplayName()] = true, -- if uncommented, everyone sees debug messages

}

local debug = AllowedDebugNames[GetDisplayName()] ~= nil

local LOG_LEVEL_VERBOSE = "V"
local LOG_LEVEL_DEBUG = "D"
local LOG_LEVEL_INFO = "I"
local LOG_LEVEL_WARNING = "W"
local LOG_LEVEL_ERROR = "E"

if LibDebugLogger then  -- only for debugging, no need to add a dependency 

    logger = LibDebugLogger.Create(lib.shortname)

    LOG_LEVEL_VERBOSE = LibDebugLogger.LOG_LEVEL_VERBOSE
    LOG_LEVEL_DEBUG = LibDebugLogger.LOG_LEVEL_DEBUG
    LOG_LEVEL_INFO = LibDebugLogger.LOG_LEVEL_INFO
    LOG_LEVEL_WARNING = LibDebugLogger.LOG_LEVEL_WARNING
    LOG_LEVEL_ERROR = LibDebugLogger.LOG_LEVEL_ERROR

end

local function Print(level, ...)

    if debug ~= true and level ~= LOG_LEVEL_WARNING and level ~= LOG_LEVEL_ERROR then return end

    if logger ~= nil and type(logger.Log)=="function" then

        logger:Log(level, ...)

    elseif level == LOG_LEVEL_WARNING or level == LOG_LEVEL_ERROR then

        df(...)

    end

end

-- price data

local parsedDataCache = {}  -- only parse once per session, parse only itemIds that are needed
if debug then libint.parsedDataCache = parsedDataCache end

local function ParseItemPriceDataString(itemPriceDataString) -- parse a single line from the SV

    local parsedData = {}

    for keyString, valueString in string.gmatch(itemPriceDataString, "(%w+):(%d+)") do

        parsedData[keyString] = tonumber(valueString)

    end

    return parsedData
end

local function ParsePriceData(modItemLink)

    if modItemLink == nil then return end

    local itemPriceDataString = fullPriceData[modItemLink]

    if itemPriceDataString == nil or itemPriceDataString == "" then return end

    if type(itemPriceDataString) ~= "string" then return end

    local parsedData = ParseItemPriceDataString(itemPriceDataString)

    return parsedData
end

local brokenItemLinksCache = {}

local itemLinkReplacePatterns = {
    "%1:50:%2%3",
    "%1:1:%2%3",
    "%1:0:%2%3",
}

-- |H0:item:75365:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h

local function GetItemData(itemLink, bagId, slotIndex)

    if IsInGamepadPreferredMode() and GAMEPAD_INVENTORY.actionMode then bagId = GAMEPAD_INVENTORY and GAMEPAD_INVENTORY.currentlySelectedData and GAMEPAD_INVENTORY.currentlySelectedData.bagId or bagId end

    if itemLink == nil or IsItemLinkBound(itemLink) then return end

    if parsedDataCache[itemLink] ~= nil then return parsedDataCache[itemLink] end

    local modItemLink = string.gsub(itemLink, ".*:item:(%d+:%d+:%d+:)%d+:%d+:%d+:(%d+:%d+:%d+:%d+:%d+:%d+:)%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:(%d+)|h|h.*", "%1%2%3")
    local itemData = ParsePriceData(modItemLink)

    -- Print(LOG_LEVEL_INFO, "Parse item: %s (bag: %s, success: %s)", itemLink, tostring(bagId), tostring(itemData ~= nil))

    if itemData == nil and (bagId == BAG_GUILDBANK or bagId == BAG_VIRTUAL) then

        if bagId == BAG_GUILDBANK then  -- itemLinks from guild bank sometimes miss info in the itemLevel field

            local replacePattern = string.format("%%1:%d:%%2%%3", GetItemLinkRequiredLevel(itemLink))   -- try to replace with item level queried from item link

            modItemLink = string.gsub(itemLink, ".*:item:(%d+:%d+):%d+:%d+:%d+:%d+:(%d+:%d+:%d+:%d+:%d+:%d+:)%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:(%d+)|h|h.*", replacePattern)
            itemData = ParsePriceData(modItemLink)

            if not itemData then -- try to replace with a few common values
                for i, replacePattern in ipairs(itemLinkReplacePatterns) do

                    modItemLink = string.gsub(itemLink, ".*:item:(%d+:%d+):%d+:%d+:%d+:%d+:(%d+:%d+:%d+:%d+:%d+:%d+:)%d+:%d+:%d+:%d+:%d+:%d+:%d+:%d+:(%d+)|h|h.*", replacePattern)
                    itemData = ParsePriceData(modItemLink)

                    if itemData then break end

                end
            end

            if not itemData then return end -- bail if still not successful

        elseif bagId == BAG_VIRTUAL then

            local itemId = GetItemLinkItemId(itemLink)
            modItemLink = libint.fallbackStrings[itemId]

            if not modItemLink then return end
            itemData = ParsePriceData(modItemLink)

        end
    end

    if itemData == nil then return end

    itemData.itemLink = itemLink
    itemData.modItemLink = modItemLink

    parsedDataCache[itemLink] = itemData

    return itemData

end

local function GetItemSlotData(slot)    -- TODO: limit slot types, like MM ?

    local slotType = slot.slotType

    local itemLink

    if slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        itemLink = GetTradingHouseSearchResultItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)
    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        itemLink = GetTradingHouseListingItemLink(slot.slotIndex, LINK_STYLE_BRACKETS)
    else
        itemLink = GetItemLink(slot.bagId, slot.slotIndex, LINK_STYLE_BRACKETS)
    end

    if itemLink and itemLink ~= "" then

        return GetItemData(itemLink, slot.bagId, slot.slotIndex)

    end
end

local function GetPriceData(itemData, useSalesData)

    if itemData == nil then return end

    local priceData = {}

    if useSalesData then

        priceData.suggestedPriceMin = itemData.slsl
        priceData.suggestedPriceMax = itemData.slsm
        priceData.average           = itemData.sla
        priceData.listings          = itemData.sltl
        priceData.priceMax          = itemData.slm
        priceData.priceMin          = itemData.sll

    else

        priceData.suggestedPriceMin = itemData.sl
        priceData.suggestedPriceMax = itemData.sm
        priceData.average           = itemData.a
        priceData.listings          = itemData.tl
        priceData.priceMax          = itemData.m
        priceData.priceMin          = itemData.l

    end

    return priceData
end

function lib.GetSimpleItemPrice(itemLink)   -- TODO: Apply fixes for API queries.

    local itemData = GetItemData(itemLink)
    if itemData == nil then return end

    local price

    price = itemData.slsl or itemData.slsm or itemData.sla or itemData.sl or itemData.sm or itemData.a or nil  -- TODO: Add some logic to pick listings or sales

    return price

end

function lib.GetItemPriceData(itemLink) -- TODO: Apply fixes for API queries.

    local itemData = GetItemData(itemLink)
    if itemData == nil then return end

    local priceData = GetPriceData(itemData, false)

    priceData.suggestedListingPriceMin = itemData.sl
    priceData.suggestedListingPriceMax = itemData.sm
    priceData.averageListing           = itemData.a
    priceData.numberOfListings         = itemData.tl
    priceData.listingPriceMax          = itemData.m
    priceData.listingPriceMin          = itemData.l
    priceData.suggestedSalesPriceMin   = itemData.slsl
    priceData.suggestedSalesPriceMax   = itemData.slsm
    priceData.averageSales             = itemData.sla
    priceData.numberOfSales            = itemData.sltl
    priceData.salesPriceMax            = itemData.slm
    priceData.salesPriceMin            = itemData.sll

    return priceData

end

-- Inventory Slot Update

local modcolor = ZO_ColorDef:New(1, 1, 0, 1)
local textColor = ZO_ColorDef:New(1, 1, 1, 1)
local defaultOptions = {
    showTooltips = false,
    useShortFormat = false,
    font = "ZoFontGame",
    iconSide = RIGHT,
}

local function onItemSellPriceDisplayUpdate(rowControl, slot, options)
    -- if options.overrideSellValue or options.color then d("onItemSellPriceDisplayUpdate not executed") return end

    if libint.sv.showInventoryPrice == "none" or libint.cannotUseInventoryHooks then return end

    local itemData = GetItemSlotData(slot)
    if itemData  == nil then return end

    local stackSize = GetSlotStackSize(slot.bagId, slot.slotIndex) or 1

    local price

    if libint.sv.showInventoryPrice == "sales" then
        price = itemData.slsl or itemData.slsm or itemData.sla or nil
    elseif libint.sv.showInventoryPrice == "listings" then
        price = itemData.sl or itemData.sm or itemData.a or nil
    end

    if price == nil then return end

    local totalPrice = stackSize * price

    local sellPriceControl = rowControl:GetNamedChild("SellPriceText")

    options = options or defaultOptions

    local oldcolor = options.color
    options.color = modcolor

    ZO_CurrencyControl_SetSimpleCurrency(sellPriceControl, CURT_MONEY, totalPrice, options)

    options.color = oldcolor

end

-- ItemTooltip

local titlecolor = ZO_ColorDef:New(1, 1, 0.6, 1)

local function GetValueString(value)

    if IsInGamepadPreferredMode() then
        return zo_strformat(SI_GAMEPAD_TOOLTIP_ITEM_VALUE_FORMAT, ZO_CommaDelimitNumber(value), ZO_Currency_GetGamepadFormattedCurrencyIcon(CURT_MONEY))
    else
        return zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(CURT_MONEY, value, ZO_CURRENCY_FORMAT_AMOUNT_ICON))
    end
end

local function UpdateCustomTooltipSection(sectionControl, itemData, useSalesData)

    local priceData = GetPriceData(itemData, useSalesData)

    if not (priceData and priceData.average and priceData.listings and priceData.priceMax and priceData.priceMin) then return false end

    local titleLabel = sectionControl:GetNamedChild("Label1")
    local row1Label = sectionControl:GetNamedChild("Label2")
    local row2Label = sectionControl:GetNamedChild("Label3")
    local row3Label = sectionControl:GetNamedChild("Label4")

    local font =  IsInGamepadPreferredMode() and "ZoFontGamepad27" or "ZoFontGame"

    titleLabel:SetFont(font)
    row1Label:SetFont(font)
    row2Label:SetFont(font)
    row3Label:SetFont(font)

    if priceData.suggestedPriceMin and priceData.suggestedPriceMax then
        row3Label:SetHidden(false)
        local suggestedMinString = GetValueString(priceData.suggestedPriceMin)
        if priceData.suggestedPriceMin == priceData.suggestedPriceMax then
            row1Label:SetText(textColor:Colorize(zo_strformat(EHP_STRING_TOOLTIP_SUGGESTED_SINGLE, suggestedMinString)))
        else
            local suggestedMaxString = GetValueString(priceData.suggestedPriceMax)
            row1Label:SetText(textColor:Colorize(zo_strformat(EHP_STRING_TOOLTIP_SUGGESTED_RANGE, suggestedMinString, suggestedMaxString)))
        end
    else
        row3Label:SetHidden(true)
        row3Label = row2Label
        row2Label = row1Label
    end

    local avgString = GetValueString(priceData.average)
    local lowestString = GetValueString(priceData.priceMin)
    local maxString = GetValueString(priceData.priceMax)

    local listingsString = useSalesData and GetString(EHP_STRING_SALES) or GetString(EHP_STRING_LISTINGS)
    local titleString = zo_strformat(EHP_STRING_TOOLTIP_TITLE, listingsString)
    if useSalesData then titleString = titleString .. GetString(EHP_STRING_TOOLTIP_TITLE_DURATION) end

    titleLabel:SetText(titlecolor:Colorize(titleString))
    row2Label:SetText(textColor:Colorize(zo_strformat(EHP_STRING_TOOLTIP_AVERAGE, avgString)))
    row3Label:SetText(textColor:Colorize(zo_strformat(EHP_STRING_TOOLTIP_LISTINGS, lowestString, maxString, ZO_CommaDelimitDecimalNumber(tonumber(priceData.listings)), listingsString)))

    return true
end

local function UpdateCustomTooltip(itemData)

    if itemData == nil then return end

    local section1Control = libint.tooltipControl:GetNamedChild("Section1")
    local section2Control = libint.tooltipControl:GetNamedChild("Section2")
    local statusLabel = libint.tooltipControl:GetNamedChild("StatusLabel")

    section2Control:SetHidden(true)

    local currentSection = section1Control

    local toolTipGenerated = false

    if libint.sv.showListingsTooltip then

        toolTipGenerated = UpdateCustomTooltipSection(currentSection, itemData, false)

    end

    if libint.sv.showSalesTooltip then

        if libint.sv.showListingsTooltip and toolTipGenerated then
            currentSection = section2Control
        end

        local success = UpdateCustomTooltipSection(currentSection, itemData, true)
        currentSection:SetHidden(not success)
        currentSection = success and currentSection or section1Control

        toolTipGenerated = toolTipGenerated or success


    end

    if not toolTipGenerated then return end

    libint.tooltipControl:SetHidden(false)

    if libint.dataTimeStamp then

        local date, time = FormatAchievementLinkTimestamp(libint.dataTimeStamp)

        statusLabel:SetText(zo_strformat(EHP_STRING_TOOLTIP_TIMESTAMP, date, time))
        statusLabel:SetAnchor(TOP, currentSection, BOTTOM, 0, 2)
        statusLabel:SetHidden(false)
        statusLabel:SetFont(IsInGamepadPreferredMode() and "ZoFontGamepad20" or "ZoFontGameSmall")

    else

        statusLabel:SetHidden(true)

    end

    libint.tooltipControl:SetResizeToFitDescendents(false)
    libint.tooltipControl:SetResizeToFitDescendents(true)

    return toolTipGenerated

end

local function AddPriceDataToTooltip(tooltipControl, itemData, spacing)

    if libint.tooltipControl == nil then
        libint.tooltipControl = CreateControlFromVirtual("EHP_Tooltip", tooltipControl, "EHP_Tooltip_Template")
    end

    local success = UpdateCustomTooltip(itemData)
    if not success then return end

    if spacing > 0 then tooltipControl:AddVerticalPadding(spacing) end
    ZO_Tooltip_AddDivider(tooltipControl)
    tooltipControl:AddControl(libint.tooltipControl)
    libint.tooltipControl:SetAnchor(CENTER)
end


local function AddPriceDataToTooltip_Gamepad(tooltipContainer, itemData)

    if libint.tooltipControl == nil then
        libint.tooltipControl = CreateControlFromVirtual("EHP_Tooltip", tooltipContainer, "EHP_Tooltip_Template")
    end

    if libint.tooltipControl.GetStyles == nil then
        function libint.tooltipControl.GetStyles() return {} end
    end

    local updated = UpdateCustomTooltip(itemData)

    if not updated then return end

    local section = tooltipContainer:AcquireSection(tooltipContainer:GetStyle("bodySection"))
    section:AddDimensionedControl(libint.tooltipControl)

    libint.tooltipControl:ClearAnchors()
    libint.tooltipControl:SetAnchor(TOP, nil, TOP, 0, -20)

    libint.tooltipControl.tooltipContainer = tooltipContainer

    tooltipContainer:AddSection(section)
end

local lastTooltipMouseoverControl

local function OnTooltipShow(tooltipControl, hidden)

    if not (libint.sv.showListingsTooltip or libint.sv.showSalesTooltip) then return end

    local itemControl = moc()

    -- Print(LOG_LEVEL_INFO, "Tooltip called. Is new: %s", tostring(lastTooltipMouseoverControl ~= itemControl))

    if itemControl and lastTooltipMouseoverControl == itemControl then return end

    lastTooltipMouseoverControl = itemControl
    local itemData

    -- Print(LOG_LEVEL_INFO, "New Tooltip: Has Data: %s", tostring(itemControl and itemControl.dataEntry and itemControl.dataEntry.data ~= nil))

    local spacing = 0

    if itemControl.dataEntry and itemControl.dataEntry.data then

        local slot = itemControl.dataEntry.data
        if slot.bagId and slot.slotIndex then

            itemData = GetItemSlotData(slot)

        elseif slot.itemLink then -- for non inventory

            itemData = GetItemData(slot.itemLink)

        elseif slot.lootId then -- for loot window

            local itemLink = GetLootItemLink(slot.lootId, LINK_STYLE_DEFAULT)
            itemData = GetItemData(itemLink, BAG_GUILDBANK, nil)
            spacing = 10

        end

    elseif itemControl.bagId and itemControl.slotIndex then

        itemData = GetItemSlotData(itemControl)

    elseif TRADE_WINDOW:IsTrading() and itemControl.slotControlType == "listSlot" then

        local buttonControl = itemControl:GetNamedChild("Button")
        if buttonControl == nil then return end

        local slotType = buttonControl.slotType
        local slotIndex = buttonControl.slotIndex
        local who = (slotType == SLOT_TYPE_MY_TRADE and TRADE_ME) or (slotType == SLOT_TYPE_THEIR_TRADE and TRADE_THEM) or nil

        if who == nil or slotIndex == nil then return end

        local itemLink = GetTradeItemLink(who, slotIndex, LINK_STYLE_DEFAULT)
        itemData = GetItemData(itemLink)

    end

    -- Print(LOG_LEVEL_INFO, "Itemdata found: %s", tostring(itemData ~= nil))

    if itemData == nil then return end
    -- format prices
    AddPriceDataToTooltip(tooltipControl, itemData, spacing)
end

local function OnTooltipShow_Gamepad(tooltipControl, itemLink, equipped, creatorName, forceFullDurability, previewValueToAdd, itemName, equipSlot, showPlayerLocked, tradeBoPData, extraData)
    -- Print(LOG_LEVEL_INFO, "2: %s (%s, %s)", tostring(itemLink), tostring(extraData and extraData.bagId), tostring(extraData and extraData.slotIndex))

    local itemData = GetItemData(itemLink, extraData and extraData.bagId, extraData and extraData.slotIndex)

    -- format prices

    if libint.tooltipControl then libint.tooltipControl:SetHidden(true) end

    if itemData == nil then return end

    zo_callLater(function() AddPriceDataToTooltip_Gamepad(tooltipControl, itemData) end, 1)

end

local function OnTooltipHide()
    lastTooltipMouseoverControl = nil
    -- libint.tooltipControl:SetHidden(true)
end

function libint.OnTooltipHide_Gamepad(tooltipContainer)
    if libint.tooltipControl and libint.tooltipControl.tooltipContainer == tooltipContainer then
        libint.tooltipControl:SetHidden(true)
    end
end

local lastPopupTooltipLink

local function OnPopupTooltipShow(tooltipControl, hidden)

    if not (libint.sv.showListingsTooltip or libint.sv.showSalesTooltip) then return end

    local itemLink = tooltipControl.lastLink
    local itemData = GetItemData(itemLink)

    if itemData == nil or lastPopupTooltipLink == itemLink then return end

    lastPopupTooltipLink = itemLink

    AddPriceDataToTooltip(tooltipControl, itemData, 0)

end

local function OnPopupTooltipHide()
    lastPopupTooltipLink = nil
end


local function ReplaceInventorySortHeader(inventory, enableReplacement)

    local sortHeaders = inventory and inventory.sortHeaders

    if sortHeaders then

        local oldKey = enableReplacement and "stackSellPrice" or "EHPStackSellPrice"
        local newkey = enableReplacement and "EHPStackSellPrice" or "stackSellPrice"

        sortHeaders:ReplaceKey(oldKey, newkey)

    end
end

local function CheckForInventoryPriceReplacements()

    local Settings = ArkadiusTradeToolsSalesData and ArkadiusTradeToolsSalesData.settings and ArkadiusTradeToolsSalesData.settings.inventories

    if Settings and Settings.enabled then
        libint.cannotUseInventoryHooks = true
        libint.cannotUseInventoryHooksReasons["Arkadius Trade Tools"] = true
    end

end

local function GetInventoryHooksReasons()

    local reasons = {}

    for newReason, _ in pairs(libint.cannotUseInventoryHooksReasons) do

        reasons[#reasons+1] = newReason
    end

    return table.concat(reasons, ", ")
end

local function ToggleSortHeaderKeyReplacement(enableReplacement)

    local enableReplacement = enableReplacement == nil and (not libint.currentPriceSortHeaderKeyReplaced) or enableReplacement

    CheckForInventoryPriceReplacements()

    if libint.cannotUseInventoryHooks and enableReplacement then
        Print(LOG_LEVEL_WARNING, "Inventory price replacement by %s detected. Aborting activation of own price replacement.", GetInventoryHooksReasons())
        return
    end

    if enableReplacement == libint.currentPriceSortHeaderKeyReplaced then return end

    libint.currentPriceSortHeaderKeyReplaced = enableReplacement

    for _, inventory in pairs(PLAYER_INVENTORY.inventories) do
        ReplaceInventorySortHeader(inventory, enableReplacement)
    end

    for panelName, system in pairs(validCraftingStationPanels) do

        local panel = system and system[panelName]
        local inventory = panel and panel.inventory

        ReplaceInventorySortHeader(inventory, enableReplacement)

    end

    local panel = UNIVERSAL_DECONSTRUCTION["deconstructionPanel"]
    local inventory = panel and panel.inventory

    ReplaceInventorySortHeader(inventory, enableReplacement)
end

local function RefreshInventories()

    SHARED_INVENTORY.refresh:RefreshAll("inventory")

end

-- Settings

local svdefaults = {

    showInventoryPrice = "none",
    showListingsTooltip = true,
    showSalesTooltip = true,
    accountWide = true,
    contextMenuPostToChat = true,
    contextMenuViewOnline = true,
    -- useSalesData = true,

}

local settingMessageStrings = {
    showInventoryPrice = EHP_STRING_SETTING_MESSAGE_INVENTORY,
    showListingsTooltip = EHP_STRING_SETTING_MESSAGE_LISTING_TOOLTIP,
    showSalesTooltip = EHP_STRING_SETTING_MESSAGE_SALES_TOOLTIP,
    accountWide = EHP_STRING_SETTING_MESSAGE_ACCOUNTWIDE,
    -- useSalesData = EHP_STRING_SETTING_MESSAGE_SALES,
    contextMenuPostToChat = EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_POSTTOCHAT,
    contextMenuViewOnline = EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_VIEWONLINE,
}

local function DisplaySettingMessage(settingKey, settingValue)

    local settingValueString = GetString(settingValue == true and EHP_STRING_ON or settingValue == false and EHP_STRING_OFF or settingValue)
    local settingMessageString = GetString(settingMessageStrings[settingKey])

    local message = zo_strformat("[LibEsoHubPrices] <<1>>: <<2>>", settingMessageString, settingValueString)

    CHAT_ROUTER:AddSystemMessage(message)

end

local function ToggleAccountwideSV(settingValue)

    local svChar = libint.svChar
    local svAcc = libint.svAcc
    local oldValue = svChar.accountWide
    local newValue = settingValue

    if type(settingValue) == "string" then
        if settingValue == "on" then newValue = true else newValue = false end
    elseif settingValue == nil then
        newValue = not oldValue
    end

    if newValue == false then
        libint.svChar = ZO_DeepTableCopy(libint.svAcc)
        svChar.accountWide = false
        libint.sv = svChar
    elseif newValue == true then
        svChar.accountWide = true
        libint.sv = svAcc
    end
end

local function toggleSetting(settingKey, settingValue)

    local sv = libint.sv
    local oldValue = sv[settingKey]

    if settingValue == "off" then
        sv[settingKey] = false
    elseif settingValue == "on" then
        sv[settingKey] = true
    elseif settingValue == nil then
        sv[settingKey] = not oldValue
    else
        sv[settingKey] = settingValue or oldValue
    end

    if settingKey == "showInventoryPrice" then
        ToggleSortHeaderKeyReplacement(sv.showInventoryPrice ~= "none")
        RefreshInventories()
    end

    DisplaySettingMessage(settingKey, sv[settingKey])

end

local function MakeMenu(svdefaults)
    -- load the settings->addons menu library
    local lam = LibAddonMenu2
    if not LibAddonMenu2 then return end

    local sv = libint.sv
    local def = svdefaults

    -- the panel for the addons menu
    local panelData = {
        type = "panel",
        name = "LibEsoHubPrices",
        displayName = "LibEsoHubPrices",
        author = "Solinur",
        version = "" .. lib.version,
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.ESO-hub.com",
        -- feedback = FeedbackContextMenu,
        -- donation = DonationContextMenu,
    }

    --this adds entries in the addon menu
    local options = {
        {
            type = "checkbox",
            name = EHP_STRING_SETTING_ACCOUNTWIDE,
            default = false,
            getFunc = function() return libint.svChar.accountWide end,
            setFunc = function(value) ToggleAccountwideSV(value) end,
        },
        -- {
        --     type = "checkbox",
        --     name = EHP_STRING_SETTING_USESALESDATA,
        --     tooltip = EHP_STRING_SETTING_USESALESDATA_TOOLTIP,
        --     default = def.useSalesData,
        --     getFunc = function() return sv.useSalesData end,
        --     setFunc = function(value) sv.useSalesData = value end,
        --     disable = true,
        -- },
        {
            type = "dropdown",
            name = EHP_STRING_SETTING_INVENTORY,
            tooltip = EHP_STRING_SETTING_INVENTORY_TOOLTIP,
            choices = {"None", "Listing Prices", "Sales Prices"},
            choicesValues = {"none", "listings", "sales"},
            default = def.showInventoryPrice,
            getFunc = function()
                return EHP_INVENTORY_HOOK_SETTING.isDisabled and "none" or sv.showInventoryPrice
            end,
            setFunc = function(value)
                sv.showInventoryPrice = value
                ToggleSortHeaderKeyReplacement(sv.showInventoryPrice ~= "none")
                RefreshInventories()
            end,
            disabled = function()
                local tooltipText = libint.cannotUseInventoryHooks and zo_strformat(EHP_STRING_SETTING_INVENTORY_TOOLTIP_DISABLED, GetInventoryHooksReasons()) or GetString(EHP_STRING_SETTING_INVENTORY_TOOLTIP)
                EHP_INVENTORY_HOOK_SETTING.data.tooltipText = tooltipText
                return libint.cannotUseInventoryHooks
            end,
            reference = "EHP_INVENTORY_HOOK_SETTING",
        },
        {
            type = "checkbox",
            name = EHP_STRING_SETTING_LISTINGS_TOOLTIP,
            tooltip = EHP_STRING_SETTING_LISTINGS_TOOLTIP_TOOLTIP,
            default = def.showListingsTooltip,
            getFunc = function() return sv.showListingsTooltip end,
            setFunc = function(value) sv.showListingsTooltip = value end,
        },
        {
            type = "checkbox",
            name = EHP_STRING_SETTING_SALES_TOOLTIP,
            tooltip = EHP_STRING_SETTING_SALES_TOOLTIP_TOOLTIP,
            default = def.showSalesTooltip,
            getFunc = function() return sv.showSalesTooltip end,
            setFunc = function(value) sv.showSalesTooltip = value end,
        },
        {
            type = "checkbox",
            name = EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT,
            tooltip = EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT_TOOLTIP,
            default = def.contextMenuPostToChat,
            getFunc = function() return sv.contextMenuPostToChat end,
            setFunc = function(value) sv.contextMenuPostToChat = value end,
        },
        {
            type = "checkbox",
            name = EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE,
            tooltip = EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE_TOOLTIP,
            default = def.contextMenuViewOnline,
            getFunc = function() return sv.contextMenuViewOnline end,
            setFunc = function(value) sv.contextMenuViewOnline = value end,
        },
    }

    local panel = lam:RegisterAddonPanel("EHP_Options", panelData)
    lam:RegisterOptionControls("EHP_Options", options)

    function libint.OpenSettings()

        lam:OpenToPanel(panel)

    end
end

local function PrintSlashCommandHelp()

    CHAT_ROUTER:AddSystemMessage("----")

    for stringId = 1, 9 do

        CHAT_ROUTER:AddSystemMessage(GetString("EHP_STRING_SLASHCOMMAND_HELP", stringId))

    end

    CHAT_ROUTER:AddSystemMessage("----")

end


local function slashCommandFunction(commandString)

    local commands = {}

    for word in string.gmatch(commandString, "%w+") do
        commands[#commands+1] = word
    end

    local main = commands[1]

    if main == "accountwide" then

        ToggleAccountwideSV(commands[2])
        DisplaySettingMessage("accountWide", libint.svChar.accountWide)

    elseif main == "inventory" then toggleSetting("showInventoryPrice", commands[2])
    elseif main == "listingstooltip" then toggleSetting("showListingsTooltip", commands[2])
    elseif main == "salestooltip" then toggleSetting("showSalesTooltip", commands[2])
    -- elseif main == "usesales" then toggleSetting("useSalesData", commands[2])
    elseif main == "contextmenu" and commands[2] == "chat" then toggleSetting("contextMenuPostToChat", commands[3])
    elseif main == "contextmenu" and commands[2] == "online" then toggleSetting("contextMenuViewOnline", commands[3])
    else PrintSlashCommandHelp()
    end

end

SLASH_COMMANDS["/ehp"] = slashCommandFunction

local function InitPriceData()
    local numData = fullPriceData and NonContiguousCount(fullPriceData) or 0
    if numData == 0 then
        Print(LOG_LEVEL_WARNING, "No price data found. Please make sure to update %s (%d, %d)", lib.name)
        return
    end
    
    local fallbackStrings = {}
    for itemLinkString, _ in pairs(fullPriceData) do
        local _, _, itemId = string.find(itemLinkString, "(%d+):")
        
        itemId = tonumber(itemId) or 0
        if itemId > 0 then
            if fallbackStrings[itemId] == nil then
                fallbackStrings[itemId] = itemLinkString
            else
                fallbackStrings[itemId] = false
            end
        end
    end
    
    libint.fallbackStrings = fallbackStrings
    Print(LOG_LEVEL_WARNING, "Price data loaded (%d items).", numData)
end

local function PostToChat(itemData, useSalesData)

    local priceData = GetPriceData(itemData, useSalesData)

    if not (priceData and priceData.listings and (priceData.suggestedPriceMin or priceData.suggestedPriceMax or priceData.average)) then return end

    local formattedPrice
    if priceData.suggestedPriceMin and priceData.suggestedPriceMax and (priceData.suggestedPriceMin ~= priceData.suggestedPriceMax) then
        formattedPrice = zo_strformat("<<1>> - <<2>>", ZO_CommaDelimitDecimalNumber(tonumber(priceData.suggestedPriceMin)), ZO_CommaDelimitDecimalNumber(tonumber(priceData.suggestedPriceMax)))
    else
        formattedPrice = ZO_CommaDelimitDecimalNumber(tonumber(priceData.suggestedPriceMin or priceData.suggestedPriceMax or priceData.average))
    end

    local listingString = GetString(useSalesData and EHP_STRING_SALES or EHP_STRING_LISTINGS)
    local priceDataString = zo_strformat(EHP_STRING_CONTEXTMENU_POSTTOCHAT_FORMAT, itemData.itemLink, formattedPrice, ZO_CommaDelimitDecimalNumber(tonumber(priceData.listings)), listingString)

    CHAT_SYSTEM.textEntry:SetText(priceDataString)
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()

end

local function OpenItemUrl(itemData)
    RequestOpenUnsafeURL(zo_strformat("https://ESO-Hub.com/<<1>>/trading-addon-redirect/<<2>>", libint.lang, itemData.modItemLink))
end

local function InitContextMenus()

    if LibCustomMenu then
        LibCustomMenu:RegisterContextMenu(
            function(inventorySlot, slotActions)
                local itemData = GetItemSlotData(inventorySlot)
                if not itemData then return end
                if libint.sv.contextMenuPostToChat then
                    slotActions:AddCustomSlotAction(EHP_STRING_CONTEXTMENU_POSTTOCHAT_LISTINGS, function() PostToChat(itemData, false) end)
                    slotActions:AddCustomSlotAction(EHP_STRING_CONTEXTMENU_POSTTOCHAT_SALES, function() PostToChat(itemData, true) end)
                end
                if libint.sv.contextMenuViewOnline then
                    slotActions:AddCustomSlotAction(EHP_STRING_CONTEXTMENU_VIEWONLINE, function() OpenItemUrl(itemData) end)
                end
            end
        )
    else
        SecurePostHook('ZO_InventorySlot_ShowContextMenu', function(inventorySlot)
            local itemData = GetItemSlotData(inventorySlot)
            if not itemData then return end
            if libint.sv.contextMenuPostToChat then
                AddMenuItem(GetString(EHP_STRING_CONTEXTMENU_POSTTOCHAT_LISTINGS), function() PostToChat(itemData, false) end, MENU_ADD_OPTION_LABEL)
                AddMenuItem(GetString(EHP_STRING_CONTEXTMENU_POSTTOCHAT_SALES), function() PostToChat(itemData, true) end, MENU_ADD_OPTION_LABEL)
            end
            if libint.sv.contextMenuViewOnline then
                AddMenuItem(GetString(EHP_STRING_CONTEXTMENU_VIEWONLINE), function() OpenItemUrl(itemData) end, MENU_ADD_OPTION_LABEL)
            end
            ShowMenu(self)
        end)
    end

    LINK_HANDLER:RegisterCallback(
        LINK_HANDLER.LINK_NOT_HANDLED_EVENT,
        function(rawLink, mouseButton, linkText, linkStyle, linkType, ...)
            if linkType ~= ITEM_LINK_TYPE or rawLink == "" or mouseButton ~= MOUSE_BUTTON_INDEX_RIGHT then return end
            local itemData = GetItemData(rawLink)
            if not itemData then return end
            if libint.sv.contextMenuPostToChat then
                AddMenuItem(GetString(EHP_STRING_CONTEXTMENU_POSTTOCHAT_LISTINGS), function() PostToChat(itemData, false) end, MENU_ADD_OPTION_LABEL)
                AddMenuItem(GetString(EHP_STRING_CONTEXTMENU_POSTTOCHAT_SALES), function() PostToChat(itemData, true) end, MENU_ADD_OPTION_LABEL)
            end
            if libint.sv.contextMenuViewOnline then
                AddMenuItem(GetString(EHP_STRING_CONTEXTMENU_VIEWONLINE), function() OpenItemUrl(itemData) end, MENU_ADD_OPTION_LABEL)
            end
            ShowMenu()
        end
    )
end

local function AddModifiedPrice(slotData)

    if slotData and (slotData.sellPrice or slotData.stackSellPrice) then

        local useSalesData = libint.sv.showInventoryPrice == "sales" and true or libint.sv.showInventoryPrice == "listings" and false or nil
        local itemData = GetItemSlotData(slotData)
        local priceData = GetPriceData(itemData, useSalesData)
        local modPrice = priceData and (priceData.suggestedPriceMin or priceData.suggestedPriceMax or priceData.average) or nil
        slotData.EHPSellPrice = modPrice or slotData.sellPrice
        slotData.EHPStackSellPrice = modPrice and (modPrice * slotData.stackCount) or slotData.stackSellPrice

    end
end

local function AddModifiedPriceToSlotData(self, bagCache, bagId, slotIndex, isNewItem, isLastUpdateForMessage)

    if bagCache and slotIndex and libint.sv.showInventoryPrice ~= "none" then AddModifiedPrice(bagCache[slotIndex]) end

end

local function AddModifiedPriceDataInCraftingPanels(self, bagId, slotIndex, totalStack, scrollDataType, data, customDataGetFunction, slotData, levelDataGetFunction)

    if type(data) == "table" and #data > 0 and type(data[#data]) == "table" and libint.sv.showInventoryPrice ~= "none" then AddModifiedPrice(data[#data].data) end

end

local function HookCraftingPanel(system, panelName)

    local panel = system[panelName]
    local scrollList = panel and panel.inventory and panel.inventory.list
    local datatype = scrollList and scrollList.dataTypes and scrollList.dataTypes[1]
    if datatype then SecurePostHook(datatype, "setupCallback", onItemSellPriceDisplayUpdate) end

    SecurePostHook(panel.inventory, "AddItemData", AddModifiedPriceDataInCraftingPanels)

end

local function insertSortKey(entry1, entry2, sortKey, sortKeys, sortOrder)

    if sortKey == "EHPStackSellPrice" and sortKeys["EHPStackSellPrice"] == nil then
        sortKeys["EHPStackSellPrice"] = sortKeys["stackSellPrice"] or { tiebreaker = "name", isNumeric = true }
    end

end
local function DisableInventoryHooks(reason)

    libint.cannotUseInventoryHooks = true
    libint.cannotUseInventoryHooksReasons[reason] = true
    Print(LOG_LEVEL_WARNING, "Inventory price replacement by %s switched on. Disabling activation of own price replacement.", GetInventoryHooksReasons())
    ToggleSortHeaderKeyReplacement(false)

end

local function AddPriceData(key, newdata)
    local world = GetWorldName()
    local worldDataKey = worldToDataKey[world]

    if key ~= worldDataKey then 
        Print(LOG_LEVEL_INFO, "Server Mismatch: Discarding Data for %s", key) 
        return
    end

    Print(LOG_LEVEL_INFO, "Adding %d price data items for %s", NonContiguousCount(newdata.data), key)

    ZO_CombineNonContiguousTables(fullPriceData, newdata.data)
    libint.dataTimeStamp = zo_max(libint.dataTimeStamp, newdata.ts)
end
libint.AddPriceData = AddPriceData


local function applyTooltipHook(tooltip, method, callback)
    local orig = tooltip[method]

    tooltip[method] = function (self, ...)
        callback(self, ...)
        return orig(self, ...)
    end
end 

local initTooltips = {}

local function initTooltipHook(self, tooltipType)
    if initTooltips[tooltipType] then return end
    
    local tooltip = GAMEPAD_TOOLTIPS:GetAndInitializeTooltipContainerTip(tooltipType).tooltip
    -- applyTooltipHook(tooltip, "LayoutBagItem", function(...) logger:Info("LayoutBagItem", ...) end)
    applyTooltipHook(tooltip, "LayoutItem", OnTooltipShow_Gamepad)
    applyTooltipHook(tooltip, "Reset", libint.OnTooltipHide_Gamepad)
    initTooltips[tooltipType] = true
end

local function Initialize(event, addonName)

    if addonName ~= lib.name then return end
    EVENT_MANAGER:UnregisterForEvent(lib.name, EVENT_ADD_ON_LOADED)

    libint.svChar = ZO_SavedVars:NewCharacterIdSettings("LibEsoHubPricesSavedVariables", 1, "Settings", svdefaults)
    libint.svAcc = ZO_SavedVars:NewAccountWide("LibEsoHubPricesSavedVariables", 1, "Settings", svdefaults)

    libint.sv = libint.svChar.accountWide and libint.svAcc or libint.svChar
    libint.lang = GetCVar("language.2")

    if libint.sv.showInventoryPrice == false then libint.sv.showInventoryPrice = "none" elseif type(libint.sv.showInventoryPrice) == "boolean" then libint.sv.showInventoryPrice = "listings" end

    MakeMenu(svdefaults)

    -- add addon compatibility hooks

    if ArkadiusTradeTools then

        local ArkadiusTradeToolsSales = ArkadiusTradeTools and ArkadiusTradeTools.Modules and ArkadiusTradeTools.Modules.Sales
        if not ArkadiusTradeToolsSales then return end

        local ATTInventoryExtensions = ArkadiusTradeToolsSales.InventoryExtensions
        if not ATTInventoryExtensions then return end

        ZO_PreHook(ATTInventoryExtensions, "Enable", function(_, enable) if enable then DisableInventoryHooks("Arkadius Trade Tools") end end)

        CheckForInventoryPriceReplacements()
    end

    -- register inventory hooks

    for _, inventory in pairs(PLAYER_INVENTORY.inventories) do
        local scrollList = inventory.listView
        local datatype = scrollList and scrollList.dataTypes and scrollList.dataTypes[1]
        if datatype then
            SecurePostHook(datatype, "setupCallback", onItemSellPriceDisplayUpdate)
        end
    end

    libint.currentPriceSortHeaderKeyReplaced = false
    if not libint.cannotUseInventoryHooks then ToggleSortHeaderKeyReplacement(libint.sv.showInventoryPrice ~= "none") end

    SecurePostHook(SHARED_INVENTORY, "HandleSlotCreationOrUpdate", AddModifiedPriceToSlotData)

    local SORT_KEYS = ZO_Inventory_GetDefaultHeaderSortKeys()
    SORT_KEYS.EHPStackSellPrice = SORT_KEYS.stackSellPrice

    ZO_PreHook(_G, "ZO_TableOrderingFunction", insertSortKey) -- it had to be done :(

    -- register crafting station hooks

    for panelName, system in pairs(validCraftingStationPanels) do

        HookCraftingPanel(system, panelName)

    end

    HookCraftingPanel(UNIVERSAL_DECONSTRUCTION, "deconstructionPanel")

    -- register tooltip hooks

    ItemTooltip:SetHandler('OnUpdate', OnTooltipShow, CONTROL_HANDLER_ORDER_AFTER)
    ItemTooltip:SetHandler('OnHide', OnTooltipHide, CONTROL_HANDLER_ORDER_AFTER)
    ItemTooltip:SetHandler('OnCleared', OnTooltipHide, CONTROL_HANDLER_ORDER_AFTER)

    PopupTooltip:SetHandler('OnUpdate', OnPopupTooltipShow, CONTROL_HANDLER_ORDER_AFTER)
    PopupTooltip:SetHandler('OnHide', OnPopupTooltipHide, CONTROL_HANDLER_ORDER_AFTER)
    PopupTooltip:SetHandler('OnCleared', OnPopupTooltipHide, CONTROL_HANDLER_ORDER_AFTER)

    SecurePostHook(GAMEPAD_TOOLTIPS, "GetTooltip", initTooltipHook)

    InitContextMenus()
    InitPriceData()

    libint.initialized = true
end

EVENT_MANAGER:RegisterForEvent(lib.name, EVENT_ADD_ON_LOADED, Initialize)
