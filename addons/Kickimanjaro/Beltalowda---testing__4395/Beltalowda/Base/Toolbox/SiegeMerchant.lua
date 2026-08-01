-- Beltalowda Siege Merchant
-- Automatically purchases siege equipment from Cyrodiil merchants based on
-- user-configured minimum and maximum stock levels.
-- Ported from RdK Group Tool SiegeMerchant by @s0rdrak, adapted to Beltalowda conventions.

Beltalowda = Beltalowda or {}
Beltalowda.Toolbox = Beltalowda.Toolbox or {}
Beltalowda.Toolbox.SiegeMerchant = Beltalowda.Toolbox.SiegeMerchant or {}

local SM = Beltalowda.Toolbox.SiegeMerchant

local CALLBACK_NAME = "BeltalowdaSiegeMerchant"
local CHAT_PREFIX = "|c4592FF[Beltalowda]|r "

-- ============================================================================
-- Payment constants
-- ============================================================================

local PAYMENT_ONLY_AP     = 1
local PAYMENT_ONLY_GOLD   = 2
local PAYMENT_FIRST_AP    = 3
local PAYMENT_FIRST_GOLD  = 4

local PAYMENT_LABELS = {
    [PAYMENT_ONLY_AP]   = "Alliance Points Only",
    [PAYMENT_ONLY_GOLD] = "Gold Only",
    [PAYMENT_FIRST_AP]  = "AP First, then Gold",
    [PAYMENT_FIRST_GOLD]= "Gold First, then AP",
}

-- Ordered list for dropdown
local PAYMENT_CHOICES = {
    PAYMENT_LABELS[PAYMENT_ONLY_AP],
    PAYMENT_LABELS[PAYMENT_ONLY_GOLD],
    PAYMENT_LABELS[PAYMENT_FIRST_AP],
    PAYMENT_LABELS[PAYMENT_FIRST_GOLD],
}

local PAYMENT_VALUES = {
    PAYMENT_ONLY_AP,
    PAYMENT_ONLY_GOLD,
    PAYMENT_FIRST_AP,
    PAYMENT_FIRST_GOLD,
}

-- ============================================================================
-- Item catalog
-- ============================================================================

-- Item key constants (used for settings storage and state indexing)
local ITEM_KEYS = {
    "repairKit",
    "ballistaFire",
    "ballistaStone",
    "ballistaLightning",
    "trebuchetFire",
    "trebuchetStone",
    "trebuchetIce",
    "catapultMeatbag",
    "catapultOil",
    "catapultScattershot",
    "flamingOil",
    "forwardCamp",
    "batteringRam",
    "keepRecall",
    "potionHealth",
    "potionBattle",
    "potionSpell",
}

-- Display names for settings UI
local ITEM_NAMES = {
    repairKit           = "Cyrodiil Repair Kit",
    ballistaFire        = "Fire Ballista",
    ballistaStone       = "Ballista",
    ballistaLightning   = "Lightning Ballista",
    trebuchetFire       = "Fire Trebuchet",
    trebuchetStone      = "Stone Trebuchet",
    trebuchetIce        = "Ice Trebuchet",
    catapultMeatbag     = "Meatbag Catapult",
    catapultOil         = "Oil Catapult",
    catapultScattershot = "Scattershot Catapult",
    flamingOil          = "Flaming Oil",
    forwardCamp         = "Forward Camp",
    batteringRam        = "Battering Ram",
    keepRecall          = "Keep Recall Stone",
    potionHealth        = "Alliance Health Draught",
    potionBattle        = "Alliance Battle Draught",
    potionSpell         = "Alliance Spell Draught",
}

-- Stack sizes for inventory calculation
local STACK_NORMAL = 100
local STACK_POTS   = 200
local STACK_WEAPONS = 20

-- Max stack size per item key
local ITEM_STACK_SIZE = {
    repairKit           = STACK_NORMAL,
    ballistaFire        = STACK_WEAPONS,
    ballistaStone       = STACK_WEAPONS,
    ballistaLightning   = STACK_WEAPONS,
    trebuchetFire       = STACK_WEAPONS,
    trebuchetStone      = STACK_WEAPONS,
    trebuchetIce        = STACK_WEAPONS,
    catapultMeatbag     = STACK_WEAPONS,
    catapultOil         = STACK_WEAPONS,
    catapultScattershot = STACK_WEAPONS,
    flamingOil          = STACK_NORMAL,
    forwardCamp         = STACK_NORMAL,
    batteringRam        = STACK_WEAPONS,
    keepRecall          = STACK_NORMAL,
    potionHealth        = STACK_POTS,
    potionBattle        = STACK_POTS,
    potionSpell         = STACK_POTS,
}

-- Whether items are stackable (non-stackable = 1 per slot)
local ITEM_STACKABLE = {
    repairKit           = true,
    ballistaFire        = false,
    ballistaStone       = false,
    ballistaLightning   = false,
    trebuchetFire       = false,
    trebuchetStone      = false,
    trebuchetIce        = false,
    catapultMeatbag     = false,
    catapultOil         = false,
    catapultScattershot = false,
    flamingOil          = true,
    forwardCamp         = true,
    batteringRam        = false,
    keepRecall          = true,
    potionHealth        = true,
    potionBattle        = true,
    potionSpell         = true,
}

-- Alliance-specific item IDs
-- Keys: AD, DC, EP
local ITEM_IDS = {
    repairKit           = { AD = 204483, DC = 204483, EP = 204483 },
    ballistaFire        = { AD = 27970,  DC = 27972,  EP = 27971  },
    ballistaStone       = { AD = 36567,  DC = 36569,  EP = 36568  },
    ballistaLightning   = { AD = 27973,  DC = 27975,  EP = 27974  },
    trebuchetFire       = { AD = 27105,  DC = 27115,  EP = 27114  },
    trebuchetStone      = { AD = 44769,  DC = 44772,  EP = 44776  },
    trebuchetIce        = { AD = 44768,  DC = 44771,  EP = 44775  },
    catapultMeatbag     = { AD = 27964,  DC = 27966,  EP = 27965  },
    catapultOil         = { AD = 27967,  DC = 27969,  EP = 27968  },
    catapultScattershot = { AD = 44770,  DC = 44773,  EP = 44777  },
    flamingOil          = { AD = 30359,  DC = 30359,  EP = 30359  },
    forwardCamp         = { AD = 29533,  DC = 29535,  EP = 29534  },
    batteringRam        = { AD = 27136,  DC = 27835,  EP = 27850  },
    keepRecall          = { AD = 141731, DC = 141731, EP = 141731 },
    potionHealth        = { AD = 71071,  DC = 71071,  EP = 71071  },
    potionBattle        = { AD = 71073,  DC = 71073,  EP = 71073  },
    potionSpell         = { AD = 71072,  DC = 71072,  EP = 71072  },
}

-- Priority order for buying (minimums first in this order, then maximums)
local PRIORITY_ORDER = {
    "ballistaStone",
    "ballistaFire",
    "forwardCamp",
    "keepRecall",
    "repairKit",
    "batteringRam",
    "catapultScattershot",
    "catapultMeatbag",
    "flamingOil",
    "trebuchetStone",
    "trebuchetFire",
    "ballistaLightning",
    "trebuchetIce",
    "catapultOil",
    "potionHealth",
    "potionBattle",
    "potionSpell",
}

-- Slider max values per item key (weapons=20, stackable=1000, potions=200)
local SLIDER_MAX = {
    repairKit           = 200,
    ballistaFire        = 100,
    ballistaStone       = 100,
    ballistaLightning   = 100,
    trebuchetFire       = 100,
    trebuchetStone      = 100,
    trebuchetIce        = 100,
    catapultMeatbag     = 100,
    catapultOil         = 100,
    catapultScattershot = 100,
    flamingOil          = 100,
    forwardCamp         = 20,
    batteringRam        = 100,
    keepRecall          = 20,
    potionHealth        = 200,
    potionBattle        = 200,
    potionSpell         = 200,
}

-- ============================================================================
-- Module state
-- ============================================================================

SM.initialized = false
SM.enabled = false

-- Runtime state populated during a buy session
SM.itemIds = {}          -- key → item ID (alliance-specific)
SM.shopState = {}        -- key → { shopEntryGold, shopEntryAP, shopIndexGold, shopIndexAP, stack, buyMin, buyMax, boughtItems, statusCode }
SM.freeSlots = 0

-- ============================================================================
-- Defaults
-- ============================================================================

function SM.GetDefaults()
    local defaults = {
        enabled = false,
        sendChatMessages = true,
        paymentOption = PAYMENT_ONLY_AP,
        items = {},
    }
    for _, key in ipairs(ITEM_KEYS) do
        defaults.items[key] = 0
    end
    return defaults
end

-- ============================================================================
-- Chat helper
-- ============================================================================

local function SendChat(message)
    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.siegeMerchant
    if vars and vars.sendChatMessages then
        CHAT_SYSTEM:AddMessage(CHAT_PREFIX .. message)
    end
end

-- ============================================================================
-- Alliance item ID setup
-- ============================================================================

local function GetAllianceKey()
    local alliance = GetUnitAlliance("player")
    if alliance == ALLIANCE_ALDMERI_DOMINION then return "AD"
    elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then return "DC"
    elseif alliance == ALLIANCE_EBONHEART_PACT then return "EP"
    end
    return "AD" -- fallback
end

function SM.CreateAllianceItemList()
    local allianceKey = GetAllianceKey()
    SM.itemIds = {}
    for _, key in ipairs(ITEM_KEYS) do
        SM.itemIds[key] = ITEM_IDS[key][allianceKey]
    end
end

-- ============================================================================
-- Shop logic
-- ============================================================================

local function ClearShopState()
    SM.shopState = {}
    for _, key in ipairs(ITEM_KEYS) do
        SM.shopState[key] = {
            shopEntryGold = nil,
            shopEntryAP = nil,
            shopIndexGold = nil,
            shopIndexAP = nil,
            stack = 0,
            buyQuantity = 0,
            wantedQuantity = 0,
            boughtItems = 0,
            apSpent = 0,
            goldSpent = 0,
            statusCode = nil,
        }
    end
end

--- Scan current store and map items to our catalog.
--- @return boolean true if at least one siege item was identified
local function UpdateShopList()
    ClearShopState()
    local shopIdentified = false

    -- Build reverse lookup: itemId → key
    local idToKey = {}
    for _, key in ipairs(ITEM_KEYS) do
        if SM.itemIds[key] then
            idToKey[SM.itemIds[key]] = idToKey[SM.itemIds[key]] or key
        end
    end

    for itemIndex = 1, GetNumStoreItems() do
        local icon, name, stack, price, sellPrice, meetsReqBuy, meetsReqUse, quality, questColor,
              currencyType1, currencyQty1, currencyType2, currencyQty2, entryType = GetStoreEntryInfo(itemIndex)
        local _, _, _, rawItemId = ZO_LinkHandler_ParseLink(GetStoreItemLink(itemIndex))
        local itemId = tonumber(rawItemId)

        if itemId then
            local key = idToKey[itemId]
            if key then
                shopIdentified = true
                local state = SM.shopState[key]
                if price and price ~= 0 then
                    state.shopEntryGold = price
                    state.shopIndexGold = itemIndex
                elseif currencyQty1 and currencyQty1 ~= 0 then
                    state.shopEntryAP = currencyQty1
                    state.shopIndexAP = itemIndex
                end
            end
        end
    end
    return shopIdentified
end

--- Scan backpack and count current stock of each tracked item.
local function UpdateInventoryList()
    for _, key in ipairs(ITEM_KEYS) do
        SM.shopState[key].stack = 0
    end

    -- Build reverse lookup once
    local idToKey = {}
    for _, key in ipairs(ITEM_KEYS) do
        if SM.itemIds[key] then
            idToKey[SM.itemIds[key]] = idToKey[SM.itemIds[key]] or key
        end
    end

    for slotIndex = 0, GetBagSize(BAG_BACKPACK) do
        local _, _, _, rawItemId = ZO_LinkHandler_ParseLink(GetItemLink(BAG_BACKPACK, slotIndex))
        local itemId = tonumber(rawItemId)
        if itemId and idToKey[itemId] then
            local stack = GetSlotStackSize(BAG_BACKPACK, slotIndex)
            SM.shopState[idToKey[itemId]].stack = SM.shopState[idToKey[itemId]].stack + stack
        end
    end
end

--- Compute how many items to buy based on current stock vs desired amount.
local function UpdateShoppingList()
    local vars = BeltalowdaVars.toolbox.siegeMerchant
    for _, key in ipairs(ITEM_KEYS) do
        local desired = vars.items[key]
        -- Migration: if old format {minimum=N, maximum=M} treat maximum as desired
        if type(desired) == "table" then
            desired = desired.maximum or desired.minimum or 0
        end
        desired = desired or 0
        SM.shopState[key].buyQuantity = math.max(0, desired - SM.shopState[key].stack)
    end
end

--- Calculate how many we can actually buy given currency and inventory constraints.
--- @return statusCode, quantity, slotsUsed
local function CalculateBuyQuantity(storeEntry, paymentType, requested, key)
    if not storeEntry or not storeEntry.costs or not storeEntry.available then
        return "success", 0, 0
    end
    if requested <= 0 then
        return "success", 0, 0
    end

    local maxAffordable = math.floor(storeEntry.available / storeEntry.costs)
    local maxQuantity = requested
    local statusCode = "success"

    if ITEM_STACKABLE[key] then
        local maxStackSz = ITEM_STACK_SIZE[key]
        local freeSpace = SM.freeSlots * maxStackSz
        if freeSpace < maxQuantity then
            maxQuantity = freeSpace
            statusCode = "inventory_full"
        end
        if maxAffordable < maxQuantity then
            maxQuantity = maxAffordable
            if paymentType == PAYMENT_ONLY_AP then
                statusCode = "no_ap"
            elseif paymentType == PAYMENT_ONLY_GOLD then
                statusCode = "no_gold"
            end
        end

        local slotsUsed = 0
        if maxQuantity > 0 then
            slotsUsed = math.ceil(maxQuantity / maxStackSz)
        end
        return statusCode, math.max(0, maxQuantity), slotsUsed
    else
        -- Non-stackable: each item takes one slot
        if SM.freeSlots < maxQuantity then
            maxQuantity = SM.freeSlots
            statusCode = "inventory_full"
        end
        if maxAffordable < maxQuantity then
            maxQuantity = maxAffordable
            if paymentType == PAYMENT_ONLY_AP then
                statusCode = "no_ap"
            elseif paymentType == PAYMENT_ONLY_GOLD then
                statusCode = "no_gold"
            end
        end
        return statusCode, math.max(0, maxQuantity), maxQuantity
    end
end

--- Buy a specific item up to the requested quantity using the configured payment method.
--- @return statusCode, boughtCount, apSpent, goldSpent
local function BuySpecificItem(key, quantity)
    if quantity <= 0 then return "success", 0, 0, 0 end

    local vars = BeltalowdaVars.toolbox.siegeMerchant
    local state = SM.shopState[key]
    local paymentOption = vars.paymentOption
    local ap = GetAlliancePoints()
    local gold = GetCurrentMoney()
    local totalApSpent = 0
    local totalGoldSpent = 0

    -- Simple payment (AP-only or Gold-only)
    if paymentOption == PAYMENT_ONLY_AP or paymentOption == PAYMENT_ONLY_GOLD then
        local entry = {}
        if paymentOption == PAYMENT_ONLY_AP then
            entry.costs = state.shopEntryAP
            entry.available = ap
            entry.index = state.shopIndexAP
        else
            entry.costs = state.shopEntryGold
            entry.available = gold
            entry.index = state.shopIndexGold
        end

        if not entry.costs or not entry.index then return "success", 0, 0, 0 end

        local status, maxQty, slotsUsed = CalculateBuyQuantity(entry, paymentOption, quantity, key)
        if maxQty > 0 then
            BuyStoreItem(entry.index, maxQty)
            SM.freeSlots = SM.freeSlots - slotsUsed
            state.stack = state.stack + maxQty
            if paymentOption == PAYMENT_ONLY_AP then
                totalApSpent = maxQty * entry.costs
            else
                totalGoldSpent = maxQty * entry.costs
            end
        end
        return status, maxQty, totalApSpent, totalGoldSpent
    end

    -- Dual payment (AP-first or Gold-first)
    local firstEntry, secondEntry = {}, {}
    local firstType, secondType

    if paymentOption == PAYMENT_FIRST_AP then
        firstEntry = { costs = state.shopEntryAP, available = ap, index = state.shopIndexAP }
        secondEntry = { costs = state.shopEntryGold, available = gold, index = state.shopIndexGold }
        firstType = PAYMENT_ONLY_AP
        secondType = PAYMENT_ONLY_GOLD
    else
        firstEntry = { costs = state.shopEntryGold, available = gold, index = state.shopIndexGold }
        secondEntry = { costs = state.shopEntryAP, available = ap, index = state.shopIndexAP }
        firstType = PAYMENT_ONLY_GOLD
        secondType = PAYMENT_ONLY_AP
    end

    local totalBought = 0
    local finalStatus = "success"

    -- First currency
    if firstEntry.costs and firstEntry.index then
        local status, maxQty, slotsUsed = CalculateBuyQuantity(firstEntry, firstType, quantity, key)
        if maxQty > 0 then
            BuyStoreItem(firstEntry.index, maxQty)
            SM.freeSlots = SM.freeSlots - slotsUsed
            state.stack = state.stack + maxQty
            totalBought = maxQty
            if firstType == PAYMENT_ONLY_AP then
                totalApSpent = totalApSpent + maxQty * firstEntry.costs
            else
                totalGoldSpent = totalGoldSpent + maxQty * firstEntry.costs
            end
        end
        if status ~= "success" and status ~= "no_ap" and status ~= "no_gold" then
            finalStatus = status
        end
    end

    -- Second currency for remainder
    local remainder = quantity - totalBought
    if remainder > 0 and secondEntry.costs and secondEntry.index then
        local status, maxQty, slotsUsed = CalculateBuyQuantity(secondEntry, secondType, remainder, key)
        if maxQty > 0 then
            BuyStoreItem(secondEntry.index, maxQty)
            SM.freeSlots = SM.freeSlots - slotsUsed
            state.stack = state.stack + maxQty
            totalBought = totalBought + maxQty
            if secondType == PAYMENT_ONLY_AP then
                totalApSpent = totalApSpent + maxQty * secondEntry.costs
            else
                totalGoldSpent = totalGoldSpent + maxQty * secondEntry.costs
            end
        end
        if status ~= "success" then
            finalStatus = "no_currency"
        end
    elseif remainder > 0 then
        finalStatus = "no_currency"
    end

    return finalStatus, totalBought, totalApSpent, totalGoldSpent
end

--- Single-pass buy: purchase items up to desired amount in priority order.
local function BuyItems()
    SM.freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
    UpdateInventoryList()
    UpdateShoppingList()

    for _, key in ipairs(PRIORITY_ORDER) do
        local wanted = SM.shopState[key].buyQuantity
        SM.shopState[key].wantedQuantity = wanted
        local status, bought, apSpent, goldSpent = BuySpecificItem(key, wanted)
        SM.shopState[key].statusCode = status
        SM.shopState[key].boughtItems = bought
        SM.shopState[key].apSpent = apSpent
        SM.shopState[key].goldSpent = goldSpent
    end
end

--- Format a number with comma separators (e.g. 100000 → "100,000")
local function FormatNumber(n)
    local formatted = tostring(n)
    while true do
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

--- Display summary chat messages after a buy session.
local function DisplayFeedback()
    local hasErrors = false
    local hasSuccess = false
    local totalApSpent = 0
    local totalGoldSpent = 0
    local purchasedParts = {}
    local failedParts = {}
    local errorMessages = {}

    for _, key in ipairs(ITEM_KEYS) do
        local state = SM.shopState[key]
        if state.boughtItems and state.boughtItems > 0 then
            hasSuccess = true
            totalApSpent = totalApSpent + (state.apSpent or 0)
            totalGoldSpent = totalGoldSpent + (state.goldSpent or 0)
            purchasedParts[#purchasedParts + 1] = string.format("%dx %s", state.boughtItems, ITEM_NAMES[key])
        end
        if state.statusCode and state.statusCode ~= "success" then
            hasErrors = true
            local shortfall = (state.wantedQuantity or 0) - (state.boughtItems or 0)
            if shortfall > 0 then
                failedParts[#failedParts + 1] = string.format("%dx %s", shortfall, ITEM_NAMES[key])
            end
            if not errorMessages[state.statusCode] then
                errorMessages[state.statusCode] = true
            end
        end
    end

    -- Build cost string
    local costParts = {}
    if totalApSpent > 0 then
        costParts[#costParts + 1] = FormatNumber(totalApSpent) .. " AP"
    end
    if totalGoldSpent > 0 then
        costParts[#costParts + 1] = FormatNumber(totalGoldSpent) .. " Gold"
    end
    local costStr = #costParts > 0 and (" for " .. table.concat(costParts, " + ")) or ""

    if hasSuccess and not hasErrors then
        SendChat("Restocking complete!")
        SendChat("Purchased: " .. table.concat(purchasedParts, ", ") .. costStr)
    elseif hasSuccess then
        SendChat("Restocking partially complete.")
        SendChat("Purchased: " .. table.concat(purchasedParts, ", ") .. costStr)
        if #failedParts > 0 then
            SendChat("|cFFFF00Unable to buy:|r " .. table.concat(failedParts, ", "))
        end
        if errorMessages["no_ap"] then
            SendChat("|cFFFF00Warning:|r Not enough Alliance Points.")
        end
        if errorMessages["no_gold"] then
            SendChat("|cFFFF00Warning:|r Not enough Gold.")
        end
        if errorMessages["no_currency"] then
            SendChat("|cFFFF00Warning:|r Insufficient currency.")
        end
        if errorMessages["inventory_full"] then
            SendChat("|cFFFF00Warning:|r Not enough inventory slots.")
        end
    else
        -- Nothing purchased at all
        if #failedParts > 0 then
            SendChat("|cFF0000Restocking failed.|r")
            SendChat("|cFFFF00Unable to buy:|r " .. table.concat(failedParts, ", "))
        end
        if errorMessages["no_ap"] then
            SendChat("|cFFFF00Warning:|r Not enough Alliance Points.")
        end
        if errorMessages["no_gold"] then
            SendChat("|cFFFF00Warning:|r Not enough Gold.")
        end
        if errorMessages["no_currency"] then
            SendChat("|cFFFF00Warning:|r Insufficient currency.")
        end
        if errorMessages["inventory_full"] then
            SendChat("|cFFFF00Warning:|r Not enough inventory slots.")
        end
    end
end

-- ============================================================================
-- Event handler
-- ============================================================================

function SM.OnOpenStore(eventCode)
    if eventCode ~= EVENT_OPEN_STORE then return end
    if not IsInCyrodiil() then return end

    if UpdateShopList() then
        BuyItems()
        DisplayFeedback()
    end
end

-- ============================================================================
-- Enable / Disable
-- ============================================================================

function SM.SetEnabled(value)
    if not SM.initialized then return end

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.siegeMerchant
    if not vars then return end

    vars.enabled = value

    if value then
        EVENT_MANAGER:RegisterForEvent(CALLBACK_NAME, EVENT_OPEN_STORE, SM.OnOpenStore)
        SM.enabled = true
    else
        EVENT_MANAGER:UnregisterForEvent(CALLBACK_NAME, EVENT_OPEN_STORE)
        SM.enabled = false
    end
end

-- ============================================================================
-- Initialize
-- ============================================================================

function SM.Initialize()
    if SM.initialized then return end
    SM.initialized = true

    SM.CreateAllianceItemList()

    local vars = BeltalowdaVars and BeltalowdaVars.toolbox and BeltalowdaVars.toolbox.siegeMerchant
    if not vars then return end

    -- Migrate old {minimum, maximum} format to flat desiredAmount
    if vars.items then
        for _, key in ipairs(ITEM_KEYS) do
            local val = vars.items[key]
            if type(val) == "table" then
                vars.items[key] = val.maximum or val.minimum or 0
            end
        end
    end

    SM.SetEnabled(vars.enabled)
end

-- ============================================================================
-- Settings Controls (data-driven, with subcategories and item icons)
-- ============================================================================

-- Subcategory definitions with user-requested ordering
local GENERAL_ITEM_KEYS  = { "keepRecall", "forwardCamp", "repairKit" }
local POTION_ITEM_KEYS   = { "potionHealth", "potionBattle", "potionSpell" }
local SIEGE_ITEM_KEYS    = {
    "batteringRam", "flamingOil",
    "ballistaStone", "ballistaFire", "ballistaLightning",
    "catapultMeatbag", "catapultScattershot", "catapultOil",
    "trebuchetStone", "trebuchetFire", "trebuchetIce",
}

--- Construct a basic item link from an item ID and return its icon texture path.
--- @param key string item key from ITEM_IDS
--- @return string|nil icon texture path, or nil if unavailable
local function GetItemIcon(key)
    local allianceKey = GetAllianceKey()
    local itemId = ITEM_IDS[key] and ITEM_IDS[key][allianceKey]
    if not itemId then return nil end
    local link = string.format("|H1:item:%d:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
    local icon = GetItemLinkInfo(link)
    return icon
end

--- Build the display name with an inline icon prefix.
--- @param key string item key
--- @return string formatted label with icon (or plain name if icon unavailable)
local function GetIconLabel(key)
    local icon = GetItemIcon(key)
    local name = ITEM_NAMES[key] or key
    if icon and icon ~= "" then
        return zo_iconFormat(icon, 24, 24) .. " " .. name
    end
    return name
end

--- Generate a single "Desired Amount" slider for one item, on the same line as the icon label.
local function MakeItemControls(key, sliderMax)
    local label = GetIconLabel(key)
    return {
        {
            type = "slider",
            name = label,
            min = 0,
            max = sliderMax,
            step = 1,
            getFunc = function()
                local val = BeltalowdaVars.toolbox.siegeMerchant.items[key]
                -- Migration: handle old {minimum, maximum} format
                if type(val) == "table" then return val.maximum or val.minimum or 0 end
                return val or 0
            end,
            setFunc = function(value)
                BeltalowdaVars.toolbox.siegeMerchant.items[key] = value
            end,
            width = "full",
            default = 0,
        },
    }
end

--- Build a subcategory submenu containing controls for a list of item keys.
--- @param name string submenu display name
--- @param tooltip string submenu tooltip
--- @param description string description text shown inside the submenu
--- @param keys table ordered list of item keys
--- @return table LAM submenu control
local function MakeSubcategorySubmenu(name, tooltip, description, keys)
    local subControls = {
        { type = "description", text = description, width = "full" },
    }
    for i, key in ipairs(keys) do
        if i > 1 then
            subControls[#subControls + 1] = { type = "divider", width = "full" }
        end
        local itemCtrls = MakeItemControls(key, SLIDER_MAX[key])
        for _, ctrl in ipairs(itemCtrls) do
            subControls[#subControls + 1] = ctrl
        end
    end
    return {
        type = "submenu",
        name = name,
        tooltip = tooltip,
        controls = subControls,
    }
end

function SM.GetSettingsControls()
    local controls = {
        {
            type = "description",
            text = "Automatically purchases items from Cyrodiil merchants when you open a store. Set a desired amount for each item — if your inventory has fewer, the difference is purchased automatically. All defaults are 0 — nothing is purchased until you configure it.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable Restock",
            tooltip = "Automatically buy items when opening a Cyrodiil vendor.",
            getFunc = function()
                return BeltalowdaVars.toolbox.siegeMerchant.enabled
            end,
            setFunc = function(value)
                SM.SetEnabled(value)
            end,
            width = "full",
            default = false,
        },
        {
            type = "checkbox",
            name = "Chat Notifications",
            tooltip = "Show chat messages with purchase results.",
            getFunc = function()
                return BeltalowdaVars.toolbox.siegeMerchant.sendChatMessages
            end,
            setFunc = function(value)
                BeltalowdaVars.toolbox.siegeMerchant.sendChatMessages = value
            end,
            width = "full",
            default = true,
        },
        {
            type = "dropdown",
            name = "Payment Method",
            tooltip = "How to pay for items.",
            choices = PAYMENT_CHOICES,
            choicesValues = PAYMENT_VALUES,
            getFunc = function()
                return BeltalowdaVars.toolbox.siegeMerchant.paymentOption
            end,
            setFunc = function(value)
                BeltalowdaVars.toolbox.siegeMerchant.paymentOption = value
            end,
            width = "full",
            default = PAYMENT_ONLY_AP,
        },
        MakeSubcategorySubmenu("General", "Keep Recall Stones, Forward Camps, and Cyrodiil Repair Kits.", "Set the desired number of each item to keep in your inventory. If you have fewer than this when opening a Cyrodiil vendor, the difference will be purchased automatically.", GENERAL_ITEM_KEYS),
        MakeSubcategorySubmenu("Potions", "Alliance Health, Battle, and Spell Draughts.", "Set the desired number of each potion to keep in your inventory. If you have fewer than this when opening a Cyrodiil vendor, the difference will be purchased automatically.", POTION_ITEM_KEYS),
        MakeSubcategorySubmenu("Siege", "Battering Rams, Ballistas, Trebuchets, Catapults, and Flaming Oil.", "Set the desired number of each siege weapon to keep in your inventory. If you have fewer than this when opening a Cyrodiil vendor, the difference will be purchased automatically.", SIEGE_ITEM_KEYS),
    }

    return {
        {
            type = "submenu",
            name = "|c4592FFRestock|r",
            tooltip = "Automatically restock items from Cyrodiil merchants.",
            controls = controls,
        },
    }
end
