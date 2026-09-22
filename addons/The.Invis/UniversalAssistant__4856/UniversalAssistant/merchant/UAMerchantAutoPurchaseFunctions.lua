local ua = UAssistant
local merchant = ua.Merchant

merchant.AutoPurchase = merchant.AutoPurchase or {}

local autoPurchase = merchant.AutoPurchase

local EVENT_NAMESPACE = "UAMerchantAutoPurchase"
local INITIAL_DELAY_MS = 250
local POLL_DELAY_MS = 250
local PURCHASE_TIMEOUT_MS = 8000
local NEXT_PURCHASE_DELAY_MS = 200
local MIN_TARGET = 1
local MAX_TARGET = 200

local SOUL_GEM_ITEM_ID = 33271
local EQUIPMENT_REPAIR_KIT_ITEM_ID = 44879
local TRI_RESTORATION_POTION_ITEM_ID = 217946
local CYRODIIL_REPAIR_KIT_ITEM_ID = 204483
local FLAMING_OIL_ITEM_ID = 30359
local KEEP_RECALL_STONE_ITEM_ID = 141731
local SIGIL_OF_IMPERIAL_RETREAT_ITEM_ID = 68347

local ALLIANCE_ITEM_IDS = {
    [ALLIANCE_ALDMERI_DOMINION] = {
        forwardCamp = 29533,
        ballista = 36567,
        meatbagCatapult = 27964,
        batteringRam = 27136,
    },
    [ALLIANCE_EBONHEART_PACT] = {
        forwardCamp = 29534,
        ballista = 36568,
        meatbagCatapult = 27965,
        batteringRam = 27850,
    },
    [ALLIANCE_DAGGERFALL_COVENANT] = {
        forwardCamp = 29535,
        ballista = 36569,
        meatbagCatapult = 27966,
        batteringRam = 27835,
    },
}

local DEFINITIONS = {
    {
        key = "soulGem",
        category = "consumables",
        itemId = SOUL_GEM_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_SOUL_GEM",
        sourcePrices = {
            {
                amount = 750,
                currencyType = CURT_ALLIANCE_POINTS,
            },
            {
                amount = 500,
                currencyType = CURT_MONEY,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
            [CURT_MONEY] = true,
        },
    },
    {
        key = "repairKit",
        category = "consumables",
        itemId = EQUIPMENT_REPAIR_KIT_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_REPAIR_KIT",
        sourcePrices = {
            {
                amount = 420,
                currencyType = CURT_MONEY,
            },
        },
        acceptedCurrencies = {
            [CURT_MONEY] = true,
        },
    },
    {
        key = "triRestorationPotion",
        category = "consumables",
        itemId = TRI_RESTORATION_POTION_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_TRI_RESTORATION",
        sourcePrices = {
            {
                amount = 1000,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "cyrodiilRepairKit",
        category = "pvp",
        subcategory = "support",
        itemId = CYRODIIL_REPAIR_KIT_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_CYRODIIL_REPAIR",
        sourcePrices = {
            {
                amount = 250,
                currencyType = CURT_ALLIANCE_POINTS,
            },
            {
                amount = 90,
                currencyType = CURT_MONEY,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
            [CURT_MONEY] = true,
        },
        hasCurrencyPriority = true,
    },
    {
        key = "flamingOil",
        category = "pvp",
        subcategory = "support",
        itemId = FLAMING_OIL_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 800,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "forwardCamp",
        category = "pvp",
        subcategory = "support",
        allianceItemKey = "forwardCamp",
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 20000,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "ballista",
        category = "pvp",
        subcategory = "siegeWeapons",
        allianceItemKey = "ballista",
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 1800,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "meatbagCatapult",
        category = "pvp",
        subcategory = "siegeWeapons",
        allianceItemKey = "meatbagCatapult",
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 1200,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "batteringRam",
        category = "pvp",
        subcategory = "siegeWeapons",
        allianceItemKey = "batteringRam",
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 1800,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "keepRecallStone",
        category = "pvp",
        subcategory = "support",
        itemId = KEEP_RECALL_STONE_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 20000,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
    {
        key = "sigilOfImperialRetreat",
        category = "pvp",
        subcategory = "support",
        itemId = SIGIL_OF_IMPERIAL_RETREAT_ITEM_ID,
        sourceKey = "PURCHASE_SOURCE_PVP",
        sourcePrices = {
            {
                amount = 10000,
                currencyType = CURT_ALLIANCE_POINTS,
            },
        },
        acceptedCurrencies = {
            [CURT_ALLIANCE_POINTS] = true,
        },
    },
}

local VALID_PRIORITIES = {
    ap_first = true,
    gold_first = true,
    ap_only = true,
    gold_only = true,
}

autoPurchase.generation = 0
autoPurchase.queue = {}
autoPurchase.purchasedQuantity = 0
autoPurchase.spentByCurrency = {}
autoPurchase.reportFinished = true

local function L(key)
    return ua.GetString("MERCHANT_" .. key)
end

local function ClampTarget(value)
    return zo_clamp(zo_round(tonumber(value) or MIN_TARGET), MIN_TARGET, MAX_TARGET)
end

local function CreateItemDefaults(definition)
    local defaults = {
        enabled = false,
        target = MIN_TARGET,
    }

    if definition and definition.hasCurrencyPriority then
        defaults.priority = "ap_first"
    end

    return defaults
end

local function CreateDefaults()
    local items = {}

    for _, definition in ipairs(DEFINITIONS) do
        items[definition.key] = CreateItemDefaults(definition)
    end

    return {
        items = items,
    }
end

local function InitializeProfile(profile)
    profile.enabled = nil

    if type(profile.items) ~= "table" then
        profile.items = {}
    end

    profile.items.coldFireBallista = nil

    for _, definition in ipairs(DEFINITIONS) do
        local settings = profile.items[definition.key]

        if type(settings) ~= "table" then
            settings = CreateItemDefaults(definition)
            profile.items[definition.key] = settings
        end

        if type(settings.enabled) ~= "boolean" then
            settings.enabled = false
        end

        settings.target = ClampTarget(settings.target)

        if definition.hasCurrencyPriority and not VALID_PRIORITIES[settings.priority] then
            settings.priority = "ap_first"
        end
    end
end

merchant.RegisterProfile("autoPurchase", CreateDefaults, InitializeProfile)

local function GetDefinitionItemId(definition)
    if definition.itemId then
        return definition.itemId
    end

    local allianceItems = ALLIANCE_ITEM_IDS[GetUnitAlliance("player")]
        or ALLIANCE_ITEM_IDS[ALLIANCE_ALDMERI_DOMINION]

    return allianceItems[definition.allianceItemKey]
end

local function CreateItemLink(itemId)
    return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local function FormatCurrency(amount, currencyType)
    return ZO_Currency_FormatPlatform(currencyType, amount or 0, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
end

local function GetItemDisplay(definition)
    local itemLink = CreateItemLink(GetDefinitionItemId(definition))
    local icon = GetItemLinkIcon(itemLink)

    if icon and icon ~= "" then
        return zo_iconFormat(icon, 28, 28) .. " " .. itemLink
    end

    return itemLink
end

local function GetSourceDisplay(definition)
    local prices = {}

    for _, price in ipairs(definition.sourcePrices) do
        table.insert(prices, FormatCurrency(price.amount, price.currencyType))
    end

    return string.format(L(definition.sourceKey), unpack(prices))
end

local function CountBackpackItem(itemId)
    local total = 0
    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        if GetItemId(BAG_BACKPACK, slotIndex) == itemId then
            local _, stackCount = GetItemInfo(BAG_BACKPACK, slotIndex)

            total = total + (stackCount or 0)
        end
    end

    return total
end

local function Chat(message)
    if ua.savedVariables.merchantPurchaseChatMessages == false then
        return
    end

    d("|cFFFFFF[|r|c3A92FFU|r|cFFFF00A|r" .. "|cFFFFFFMerchant]|r " .. message)
end

local function GetStoreEntryPurchaseData(storeIndex, definition)
    local itemLink = GetStoreItemLink(storeIndex, LINK_STYLE_BRACKETS)

    if
        not itemLink
        or itemLink == ""
        or GetItemLinkItemId(itemLink) ~= GetDefinitionItemId(definition)
    then
        return nil
    end

    local _, _, _, price, _, meetsRequirementsToBuy, meetsRequirementsToUse, _, _, currencyType, currencyAmount =
        GetStoreEntryInfo(storeIndex)

    if currencyType == nil or currencyType == 0 then
        currencyType = CURT_MONEY
    end

    if
        not definition.acceptedCurrencies[currencyType]
        or not meetsRequirementsToBuy
        or not meetsRequirementsToUse
    then
        return nil
    end

    currencyAmount = tonumber(currencyAmount) or 0
    price = tonumber(price) or 0

    if currencyAmount <= 0 and price > 0 then
        currencyAmount = price
    end

    return {
        storeIndex = storeIndex,
        itemLink = itemLink,
        currencyType = currencyType,
        unitPrice = currencyAmount,
    }
end

local function GetCurrencyPriority(definition, settings)
    if not definition.hasCurrencyPriority then
        local priority = {}

        for _, sourcePrice in ipairs(definition.sourcePrices) do
            table.insert(priority, sourcePrice.currencyType)
        end

        return priority
    end

    if settings.priority == "gold_first" then
        return { CURT_MONEY, CURT_ALLIANCE_POINTS }
    elseif settings.priority == "ap_only" then
        return { CURT_ALLIANCE_POINTS }
    elseif settings.priority == "gold_only" then
        return { CURT_MONEY }
    end

    return { CURT_ALLIANCE_POINTS, CURT_MONEY }
end

local function FindStoreEntries(definition, settings)
    local entriesByCurrency = {}

    for storeIndex = 1, GetNumStoreItems() do
        local data = GetStoreEntryPurchaseData(storeIndex, definition)

        if data and not entriesByCurrency[data.currencyType] then
            entriesByCurrency[data.currencyType] = data
        end
    end

    local entries = {}

    for _, currencyType in ipairs(GetCurrencyPriority(definition, settings)) do
        if entriesByCurrency[currencyType] then
            table.insert(entries, entriesByCurrency[currencyType])
        end
    end

    return entries
end

local function IsStoreAvailable(expectedGeneration)
    return autoPurchase.generation == expectedGeneration
        and GetInteractionType() == INTERACTION_VENDOR
        and not IsStoreEmpty()
end

local ProcessNextPurchase

local function FormatPurchaseTotal()
    local totals = {}
    local currencyOrder = {
        CURT_MONEY,
        CURT_ALLIANCE_POINTS,
        CURT_TELVAR_STONES,
    }

    for _, currencyType in ipairs(currencyOrder) do
        local amount = autoPurchase.spentByCurrency[currencyType]

        if amount and amount > 0 then
            table.insert(totals, FormatCurrency(amount, currencyType))
        end
    end

    return table.concat(totals, " · ")
end

local function FinishPurchaseQueue()
    if autoPurchase.reportFinished then
        return
    end

    autoPurchase.reportFinished = true

    if autoPurchase.purchasedQuantity > 0 then
        Chat(
            string.format(
                L("CHAT_PURCHASE_SUMMARY"),
                autoPurchase.purchasedQuantity,
                FormatPurchaseTotal()
            )
        )
    end
end

local function FinishPendingPurchase(
    expectedGeneration,
    candidate,
    beforeCount,
    requestedQuantity,
    storeData,
    elapsed
)
    if not IsStoreAvailable(expectedGeneration) then
        return
    end

    local currentCount = CountBackpackItem(GetDefinitionItemId(candidate.definition))
    local purchasedQuantity = currentCount - beforeCount

    if purchasedQuantity > 0 then
        local purchasePrice = storeData.unitPrice * purchasedQuantity

        autoPurchase.purchasedQuantity = autoPurchase.purchasedQuantity + purchasedQuantity
        autoPurchase.spentByCurrency[storeData.currencyType] = (
            autoPurchase.spentByCurrency[storeData.currencyType] or 0
        ) + purchasePrice

        if ua.savedVariables.merchantChatMode == "detailed" then
            Chat(
                string.format(
                    L("CHAT_PURCHASED_ITEM"),
                    storeData.itemLink,
                    purchasedQuantity,
                    FormatCurrency(purchasePrice, storeData.currencyType)
                )
            )
        end

        zo_callLater(function()
            ProcessNextPurchase(expectedGeneration)
        end, NEXT_PURCHASE_DELAY_MS)
        return
    end

    if elapsed < PURCHASE_TIMEOUT_MS then
        zo_callLater(function()
            FinishPendingPurchase(
                expectedGeneration,
                candidate,
                beforeCount,
                requestedQuantity,
                storeData,
                elapsed + POLL_DELAY_MS
            )
        end, POLL_DELAY_MS)
        return
    end

    Chat(string.format(L("CHAT_PURCHASE_FAILED"), storeData.itemLink, requestedQuantity))
    ProcessNextPurchase(expectedGeneration)
end

ProcessNextPurchase = function(expectedGeneration)
    if not IsStoreAvailable(expectedGeneration) then
        return
    end

    local candidate = table.remove(autoPurchase.queue, 1)

    if not candidate then
        FinishPurchaseQueue()
        return
    end

    local definition = candidate.definition
    local settings = candidate.settings
    local currentCount = CountBackpackItem(GetDefinitionItemId(definition))
    local needed = ClampTarget(settings.target) - currentCount
    local storeEntries = FindStoreEntries(definition, settings)

    if needed <= 0 or not settings.enabled or #storeEntries == 0 then
        ProcessNextPurchase(expectedGeneration)
        return
    end

    local storeData = storeEntries[1]
    local quantity = 0

    for _, possibleEntry in ipairs(storeEntries) do
        local maxBuyable = tonumber(GetStoreEntryMaxBuyable(possibleEntry.storeIndex)) or 0
        local possibleQuantity = math.min(needed, maxBuyable)
        local availableCurrency = GetCurrencyAmount(
            possibleEntry.currencyType,
            CURRENCY_LOCATION_CHARACTER
        ) or 0

        if possibleEntry.unitPrice > 0 then
            possibleQuantity =
                math.min(possibleQuantity, math.floor(availableCurrency / possibleEntry.unitPrice))
        end

        possibleQuantity = math.max(0, math.floor(possibleQuantity))

        if possibleQuantity > 0 then
            storeData = possibleEntry
            quantity = possibleQuantity
            break
        end
    end

    if quantity <= 0 then
        Chat(
            string.format(
                L("CHAT_NOT_ENOUGH_CURRENCY"),
                storeData.itemLink,
                FormatCurrency(storeData.unitPrice, storeData.currencyType)
            )
        )
        ProcessNextPurchase(expectedGeneration)
        return
    end

    BuyStoreItem(storeData.storeIndex, quantity)

    zo_callLater(function()
        FinishPendingPurchase(
            expectedGeneration,
            candidate,
            currentCount,
            quantity,
            storeData,
            POLL_DELAY_MS
        )
    end, POLL_DELAY_MS)
end

local function BuildPurchaseQueue()
    autoPurchase.queue = {}
    autoPurchase.purchasedQuantity = 0
    autoPurchase.spentByCurrency = {}
    autoPurchase.reportFinished = false

    local profile = merchant.GetProfile("autoPurchase")

    for _, definition in ipairs(DEFINITIONS) do
        local settings = profile.items[definition.key]

        if settings and settings.enabled then
            table.insert(autoPurchase.queue, {
                definition = definition,
                settings = settings,
            })
        end
    end
end

local function WaitForSelling(expectedGeneration)
    if not IsStoreAvailable(expectedGeneration) then
        return
    end

    if merchant.saleFinished == false then
        zo_callLater(function()
            WaitForSelling(expectedGeneration)
        end, POLL_DELAY_MS)
        return
    end

    BuildPurchaseQueue()
    ProcessNextPurchase(expectedGeneration)
end

local function CreateItemControls(profile, definition)
    local settings = profile.items[definition.key]

    local controls = {
        {
            type = "description",
            text = GetItemDisplay(definition) .. " — " .. GetSourceDisplay(definition),
        },
        {
            type = "checkbox",
            name = L("PURCHASE_ITEM_ENABLE"),
            tooltip = L("PURCHASE_ITEM_ENABLE_TOOLTIP"),
            getFunc = function()
                return settings.enabled
            end,
            setFunc = function(value)
                settings.enabled = value
            end,
            default = false,
        },
    }

    if definition.hasCurrencyPriority then
        table.insert(controls, {
            type = "dropdown",
            name = L("PURCHASE_PRIORITY"),
            tooltip = L("PURCHASE_PRIORITY_TOOLTIP"),
            choices = {
                L("PURCHASE_PRIORITY_AP_FIRST"),
                L("PURCHASE_PRIORITY_GOLD_FIRST"),
                L("PURCHASE_PRIORITY_AP_ONLY"),
                L("PURCHASE_PRIORITY_GOLD_ONLY"),
            },
            choicesValues = {
                "ap_first",
                "gold_first",
                "ap_only",
                "gold_only",
            },
            getFunc = function()
                return settings.priority
            end,
            setFunc = function(value)
                if VALID_PRIORITIES[value] then
                    settings.priority = value
                end
            end,
            disabled = function()
                return not settings.enabled
            end,
            default = "ap_first",
        })
    end

    table.insert(controls, {
        type = "slider",
        name = L("PURCHASE_TARGET"),
        tooltip = L("PURCHASE_TARGET_TOOLTIP"),
        min = MIN_TARGET,
        max = MAX_TARGET,
        step = 1,
        decimals = 0,
        getFunc = function()
            return settings.target
        end,
        setFunc = function(value)
            settings.target = ClampTarget(value)
        end,
        disabled = function()
            return not settings.enabled
        end,
        default = MIN_TARGET,
    })

    return controls
end

local function CreateCategoryControls(profile, category, subcategory)
    local controls = {}
    local firstItem = true

    for _, definition in ipairs(DEFINITIONS) do
        if
            definition.category == category
            and (not subcategory or definition.subcategory == subcategory)
        then
            if not firstItem then
                table.insert(controls, { type = "divider" })
            end

            local itemControls = CreateItemControls(profile, definition)

            for _, control in ipairs(itemControls) do
                table.insert(controls, control)
            end

            firstItem = false
        end
    end

    return controls
end

function autoPurchase.CreateMenuControl()
    local profile = merchant.GetProfile("autoPurchase")
    local consumableControls = CreateCategoryControls(profile, "consumables")
    local pvpControls = CreateCategoryControls(profile, "pvp", "support")
    local siegeWeaponControls = CreateCategoryControls(profile, "pvp", "siegeWeapons")

    local controls = {
        {
            type = "submenu",
            name = zo_iconFormat(
                "/esoui/art/inventory/inventory_tabicon_consumables_up.dds",
                32,
                32
            )
                .. " "
                .. L("AUTO_PURCHASE_CONSUMABLES"),
            tooltip = L("AUTO_PURCHASE_CONSUMABLES_TOOLTIP"),
            controls = consumableControls,
        },
        { type = "divider" },
        {
            type = "submenu",
            name = zo_iconFormat("/esoui/art/lfg/lfg_indexicon_alliancewar_up.dds", 32, 32)
                .. " "
                .. L("AUTO_PURCHASE_PVP"),
            tooltip = L("AUTO_PURCHASE_PVP_TOOLTIP"),
            controls = {
                {
                    type = "submenu",
                    name = zo_iconFormat("/esoui/art/icons/u41_ava_unifiedrepairkit.dds", 28, 28)
                        .. " "
                        .. L("AUTO_PURCHASE_PVP_SUPPORT"),
                    tooltip = L("AUTO_PURCHASE_PVP_SUPPORT_TOOLTIP"),
                    controls = pvpControls,
                },
                { type = "divider" },
                {
                    type = "submenu",
                    name = zo_iconFormat("/esoui/art/icons/ava_siege_weapon_001.dds", 28, 28)
                        .. " "
                        .. L("AUTO_PURCHASE_PVP_SIEGE_WEAPONS"),
                    tooltip = L("AUTO_PURCHASE_PVP_SIEGE_WEAPONS_TOOLTIP"),
                    controls = siegeWeaponControls,
                },
            },
        },
    }

    return {
        type = "submenu",
        name = zo_iconFormat("/esoui/art/vendor/vendor_tabicon_buy_up.dds", 32, 32) .. " " .. L(
            "AUTO_PURCHASE"
        ),
        tooltip = L("AUTO_PURCHASE_TOOLTIP"),
        controls = controls,
    }
end

function autoPurchase.Initialize()
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "Open", EVENT_OPEN_STORE, function()
        autoPurchase.generation = autoPurchase.generation + 1
        local expectedGeneration = autoPurchase.generation

        zo_callLater(function()
            WaitForSelling(expectedGeneration)
        end, INITIAL_DELAY_MS)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "Close", EVENT_CLOSE_STORE, function()
        autoPurchase.generation = autoPurchase.generation + 1
        autoPurchase.queue = {}
    end)
end
