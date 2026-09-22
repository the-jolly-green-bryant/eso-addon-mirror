local ua = UAssistant
ua.Merchant = ua.Merchant or {}
local merchant = ua.Merchant

local EVENT_NAMESPACE = "UAMerchant"
local SALE_BATCH_SIZE = 10
local SALE_BATCH_DELAY_MS = 150
local SALE_RECEIPT_TIMEOUT_MS = 5000
local MAX_SALE_TRANSACTIONS = 50

merchant.categoryMatchers = {}
merchant.categoryPreparers = {}
merchant.categoryOrder = {}
merchant.saleQueue = {}
merchant.saleGeneration = 0
merchant.storeOpen = false
merchant.pendingSales = {}
merchant.saleDispatchComplete = true
merchant.soldQuantity = 0
merchant.soldMoney = 0
merchant.saleTransactions = 0
merchant.saleLimitReached = false
merchant.saleFinished = true

merchant.profileDefaultFactories = {}
merchant.profileInitializers = {}

function merchant.RegisterProfile(profileName, defaultsFactory, initializer)
    merchant.profileDefaultFactories[profileName] = defaultsFactory
    merchant.profileInitializers[profileName] = initializer
end

function merchant.GetProfileDefaults(profileName)
    local defaultsFactory = merchant.profileDefaultFactories[profileName]

    if not defaultsFactory then
        return {}
    end

    return defaultsFactory()
end

function merchant.GetProfile(profileName)
    local savedVariables = ua.savedVariables
    savedVariables.merchantProfiles = savedVariables.merchantProfiles or {}

    local profiles = savedVariables.merchantProfiles
    profiles[profileName] = profiles[profileName] or {}

    local profile = profiles[profileName]
    local defaults = merchant.GetProfileDefaults(profileName)

    for field, defaultValue in pairs(defaults) do
        if profile[field] == nil then
            profile[field] = defaultValue
        end
    end

    local qualityFields = {
        "maxQuality",
        "foodDrinkMaxQuality",
        "recipeMaxQuality",
        "housingPatternMaxQuality",
    }

    for _, field in ipairs(qualityFields) do
        if defaults[field] ~= nil and type(profile[field]) ~= "number" then
            profile[field] = ITEM_QUALITY_NORMAL
        end
    end

    local initializer = merchant.profileInitializers[profileName]
    if initializer then
        initializer(profile)
    end

    return profile
end

function merchant.GetItemQuality(bagId, slotIndex)
    local _, _, _, _, _, _, _, _, quality = GetItemInfo(bagId, slotIndex)

    return quality
end

function merchant.GetItemSellPrice(bagId, slotIndex)
    local _, _, sellPrice = GetItemInfo(bagId, slotIndex)

    return sellPrice or 0
end

function merchant.IsOrnate(itemLink, traitInformation)
    local traitType = GetItemLinkTraitType(itemLink)

    return traitInformation == ITEM_TRAIT_INFORMATION_ORNATE
        or traitType == ITEM_TRAIT_TYPE_WEAPON_ORNATE
        or traitType == ITEM_TRAIT_TYPE_ARMOR_ORNATE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_ORNATE
end

function merchant.IsIntricate(itemLink, traitInformation)
    local traitType = GetItemLinkTraitType(itemLink)

    return traitInformation == ITEM_TRAIT_INFORMATION_INTRICATE
        or traitType == ITEM_TRAIT_TYPE_WEAPON_INTRICATE
        or traitType == ITEM_TRAIT_TYPE_ARMOR_INTRICATE
        or traitType == ITEM_TRAIT_TYPE_JEWELRY_INTRICATE
end

function merchant.PassesEquipmentFilters(profile, bagId, slotIndex, itemLink)
    local quality = merchant.GetItemQuality(bagId, slotIndex)

    if not quality or quality > profile.maxQuality then
        return false
    end

    local traitType = GetItemLinkTraitType(itemLink)
    local traitInformation = GetItemTraitInformationFromItemLink(itemLink)

    if traitType == ITEM_TRAIT_TYPE_NONE and not profile.noTrait then
        return false
    end

    if merchant.IsOrnate(itemLink, traitInformation) and not profile.ornate then
        return false
    end

    if merchant.IsIntricate(itemLink, traitInformation) and not profile.intricate then
        return false
    end

    if IsItemBoPAndTradeable(bagId, slotIndex) and not profile.tradable then
        return false
    end

    return true
end

function merchant.IsSafeToSell(bagId, slotIndex)
    if bagId ~= BAG_BACKPACK then
        return false
    end

    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)

    if not itemLink or itemLink == "" then
        return false
    end

    if GetItemLinkSellInformation(itemLink) == ITEM_SELL_INFORMATION_CANNOT_SELL then
        return false
    end

    local stackCount = GetSlotStackSize(bagId, slotIndex) or 0

    if
        stackCount <= 0
        or merchant.GetItemSellPrice(bagId, slotIndex) <= 0
        or IsItemPlayerLocked(bagId, slotIndex)
        or IsItemStolen(bagId, slotIndex)
        or IsItemInArmory(bagId, slotIndex)
    then
        return false
    end

    return true, itemLink, stackCount
end

function merchant.RegisterCategory(categoryName, matcher, preparer)
    if type(matcher) ~= "function" then
        return
    end

    if not merchant.categoryMatchers[categoryName] then
        table.insert(merchant.categoryOrder, categoryName)
    end

    merchant.categoryMatchers[categoryName] = matcher
    merchant.categoryPreparers[categoryName] = preparer
end

function merchant.ShouldSellItem(bagId, slotIndex)
    local safe, itemLink, stackCount = merchant.IsSafeToSell(bagId, slotIndex)

    if not safe then
        return false
    end

    if IsItemJunk(bagId, slotIndex) then
        return merchant.GetProfile("junk").sellEnabled, itemLink, stackCount
    end

    for _, categoryName in ipairs(merchant.categoryOrder) do
        local profile = merchant.GetProfile(categoryName)
        local matcher = merchant.categoryMatchers[categoryName]

        if matcher(profile, bagId, slotIndex, itemLink) then
            return true, itemLink, stackCount
        end
    end

    return false
end

function merchant.BuildSaleQueue()
    if merchant.Junk then
        merchant.Junk.RefreshChoices()
    end
    merchant.saleQueue = {}

    for _, categoryName in ipairs(merchant.categoryOrder) do
        local preparer = merchant.categoryPreparers[categoryName]

        if preparer then
            preparer(merchant.GetProfile(categoryName))
        end
    end

    local bagSize = GetBagSize(BAG_BACKPACK)

    for slotIndex = 0, bagSize - 1 do
        local shouldSell, itemLink, stackCount = merchant.ShouldSellItem(BAG_BACKPACK, slotIndex)

        if shouldSell then
            table.insert(merchant.saleQueue, {
                slotIndex = slotIndex,
                itemLink = itemLink,
                stackCount = stackCount,
            })
        end
    end
end

local function FormatMoney(amount)
    return ZO_Currency_FormatPlatform(CURT_MONEY, amount or 0, ZO_CURRENCY_FORMAT_AMOUNT_ICON)
end

local function Chat(message)
    if ua.savedVariables.merchantChatMessages == false then
        return
    end

    d("|cFFFFFF[|r|c3A92FFU|r|cFFFF00A|r|cFFFFFFMerchant]|r " .. message)
end

local function FinishSelling(expectedGeneration)
    if merchant.saleGeneration ~= expectedGeneration or merchant.saleFinished then
        return
    end

    merchant.saleFinished = true
    merchant.pendingSales = {}
    merchant.saleDispatchComplete = true

    if merchant.soldQuantity > 0 then
        Chat(
            string.format(
                ua.GetString("MERCHANT_CHAT_SUMMARY"),
                merchant.soldQuantity,
                FormatMoney(merchant.soldMoney)
            )
        )
    end

    if merchant.saleLimitReached then
        Chat(ua.GetString("MERCHANT_CHAT_LIMIT_REACHED"))
    end
end

function merchant.StopSelling()
    FinishSelling(merchant.saleGeneration)
    merchant.saleGeneration = merchant.saleGeneration + 1
    merchant.saleQueue = {}
    merchant.pendingSales = {}
    merchant.saleDispatchComplete = true
    merchant.storeOpen = false
end

local ProcessNextBatch

local function TryFinishSelling(expectedGeneration)
    if
        merchant.saleGeneration == expectedGeneration
        and merchant.saleDispatchComplete
        and #merchant.pendingSales == 0
    then
        FinishSelling(expectedGeneration)
    end
end

ProcessNextBatch = function(expectedGeneration)
    if
        not merchant.storeOpen
        or merchant.saleGeneration ~= expectedGeneration
        or GetInteractionType() ~= INTERACTION_VENDOR
    then
        return
    end

    local salesSent = 0

    while
        salesSent < SALE_BATCH_SIZE
        and #merchant.saleQueue > 0
        and merchant.saleTransactions < MAX_SALE_TRANSACTIONS
    do
        if
            GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
            >= GetMaxPossibleCurrency(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
        then
            merchant.saleQueue = {}
            break
        end

        local candidate = table.remove(merchant.saleQueue, 1)
        local shouldSell, currentItemLink, stackCount =
            merchant.ShouldSellItem(BAG_BACKPACK, candidate.slotIndex)

        if shouldSell and currentItemLink == candidate.itemLink then
            table.insert(merchant.pendingSales, {
                generation = expectedGeneration,
                itemLink = currentItemLink,
            })

            SellInventoryItem(BAG_BACKPACK, candidate.slotIndex, stackCount)

            salesSent = salesSent + 1
            merchant.saleTransactions = merchant.saleTransactions + 1
        end
    end

    if merchant.saleTransactions >= MAX_SALE_TRANSACTIONS and #merchant.saleQueue > 0 then
        merchant.saleLimitReached = true
        merchant.saleQueue = {}
    end

    if #merchant.saleQueue > 0 then
        zo_callLater(function()
            ProcessNextBatch(expectedGeneration)
        end, SALE_BATCH_DELAY_MS)
        return
    end

    merchant.saleDispatchComplete = true
    TryFinishSelling(expectedGeneration)

    if not merchant.saleFinished then
        zo_callLater(function()
            if merchant.saleGeneration == expectedGeneration and not merchant.saleFinished then
                merchant.pendingSales = {}
                TryFinishSelling(expectedGeneration)
            end
        end, SALE_RECEIPT_TIMEOUT_MS)
    end
end

function merchant.OnSellReceipt(eventCode, itemName, itemQuantity, money)
    local pendingSale = table.remove(merchant.pendingSales, 1)

    if not pendingSale or pendingSale.generation ~= merchant.saleGeneration then
        return
    end

    local quantity = tonumber(itemQuantity) or 0
    local saleMoney = tonumber(money) or 0

    merchant.soldQuantity = merchant.soldQuantity + quantity
    merchant.soldMoney = merchant.soldMoney + saleMoney

    if quantity > 0 and ua.savedVariables.merchantChatMode == "detailed" then
        Chat(
            string.format(
                ua.GetString("MERCHANT_CHAT_SOLD_ITEM"),
                pendingSale.itemLink,
                quantity,
                FormatMoney(saleMoney)
            )
        )
    end

    TryFinishSelling(pendingSale.generation)
end

function merchant.StartSelling()
    if
        not ua.savedVariables.merchantEnabled
        or GetInteractionType() ~= INTERACTION_VENDOR
        or GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
            == GetMaxPossibleCurrency(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    then
        return
    end

    merchant.saleGeneration = merchant.saleGeneration + 1
    merchant.storeOpen = true
    merchant.pendingSales = {}
    merchant.saleDispatchComplete = false
    merchant.soldQuantity = 0
    merchant.soldMoney = 0
    merchant.saleTransactions = 0
    merchant.saleLimitReached = false
    merchant.saleFinished = false

    merchant.BuildSaleQueue()
    ProcessNextBatch(merchant.saleGeneration)
end

function merchant.Initialize()
    if ua.savedVariables.merchantChatMessages == nil then
        ua.savedVariables.merchantChatMessages = false
    end

    if ua.savedVariables.merchantPurchaseChatMessages == nil then
        ua.savedVariables.merchantPurchaseChatMessages = false
    end

    if
        ua.savedVariables.merchantChatMode ~= "summary"
        and ua.savedVariables.merchantChatMode ~= "detailed"
    then
        ua.savedVariables.merchantChatMode = "summary"
    end

    merchant.GetProfile("weapon")
    merchant.GetProfile("clothing")
    merchant.GetProfile("jewelry")
    merchant.GetProfile("enchanting")
    merchant.GetProfile("consumables")
    merchant.GetProfile("resources")
    merchant.GetProfile("materials")
    merchant.GetProfile("other")
    merchant.GetProfile("junk")
    merchant.GetProfile("autoPurchase")

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Receipt",
        EVENT_SELL_RECEIPT,
        merchant.OnSellReceipt
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "Open", EVENT_OPEN_STORE, function()
        zo_callLater(function()
            merchant.StartSelling()
        end, 100)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "Close", EVENT_CLOSE_STORE, function()
        merchant.StopSelling()
    end)

    merchant.Junk.Initialize()

    if merchant.AutoPurchase and merchant.AutoPurchase.Initialize then
        merchant.AutoPurchase.Initialize()
    end
end
