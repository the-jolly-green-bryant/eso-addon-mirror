local ua = UAssistant
local autoBanking = ua.Banking.AutoBanking

autoBanking.PvP = autoBanking.PvP or {}
local pvp = autoBanking.PvP

local MAX_AMOUNT = 99999

local ALLIANCE_ITEMS = {
    [ALLIANCE_ALDMERI_DOMINION] = {
        siegeWeapons = {
            { key = 1000, itemId = 36567 },
            { key = 1300, itemId = 64515 },
            { key = 2000, itemId = 27964 },
            { key = 4000, itemId = 27136 },
        },
        support = {
            { key = 7000, itemId = 204483 },
            { key = 5000, itemId = 30359 },
            { key = 6000, itemId = 29533 },
        },
    },
    [ALLIANCE_EBONHEART_PACT] = {
        siegeWeapons = {
            { key = 1000, itemId = 36568 },
            { key = 1300, itemId = 64516 },
            { key = 2000, itemId = 27965 },
            { key = 4000, itemId = 27850 },
        },
        support = {
            { key = 7000, itemId = 204483 },
            { key = 5000, itemId = 30359 },
            { key = 6000, itemId = 29534 },
        },
    },
    [ALLIANCE_DAGGERFALL_COVENANT] = {
        siegeWeapons = {
            { key = 1000, itemId = 36569 },
            { key = 1300, itemId = 64517 },
            { key = 2000, itemId = 27966 },
            { key = 4000, itemId = 27835 },
        },
        support = {
            { key = 7000, itemId = 204483 },
            { key = 5000, itemId = 30359 },
            { key = 6000, itemId = 29535 },
        },
    },
}

local SHARED_ITEMS = {
    support = {
        { key = 8000, itemId = 141731 },
        { key = 8100, itemId = 68347 },
    },
}

local CATEGORIES = {
    {
        key = "support",
        nameKey = "PVP_SUPPORT",
        icon = "/esoui/art/icons/u41_ava_unifiedrepairkit.dds",
    },
    {
        key = "siegeWeapons",
        nameKey = "PVP_SIEGE_WEAPONS",
        icon = "/esoui/art/icons/ava_siege_weapon_001.dds",
    },
}

local OBSOLETE_SETTING_KEYS = {
    "1100",
    "1200",
    "2100",
    "2200",
    "3000",
    "3100",
    "3200",
    "3300",
    "3400",
}

local function L(key)
    return ua.GetString("BANKING_" .. key)
end

local function CreateItemLink(itemId)
    return string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
end

local function GetAllianceItems()
    return ALLIANCE_ITEMS[GetUnitAlliance("player")] or ALLIANCE_ITEMS[ALLIANCE_ALDMERI_DOMINION]
end

local function GetCategoryItems(categoryKey)
    local items = {}
    local allianceItems = GetAllianceItems()

    for _, item in ipairs(allianceItems[categoryKey] or {}) do
        table.insert(items, item)
    end

    for _, item in ipairs(SHARED_ITEMS[categoryKey] or {}) do
        table.insert(items, item)
    end

    return items
end

local function GetAllItems()
    local items = {}

    for _, category in ipairs(CATEGORIES) do
        for _, item in ipairs(GetCategoryItems(category.key)) do
            table.insert(items, item)
        end
    end

    return items
end

local function GetItemName(itemId)
    local itemLink = CreateItemLink(itemId)
    local name = GetItemLinkName(itemLink)

    if not name or name == "" then
        name = tostring(itemId)
    else
        name = zo_strformat("<<C:1>>", name)
    end

    local icon = GetItemLinkIcon(itemLink)

    if icon and icon ~= "" then
        return zo_iconFormat(icon, 28, 28) .. " " .. name
    end

    return name
end

local function RefreshControl(reference, method)
    local control = _G[reference]

    if control and control[method] then
        control[method](control)
    end
end

local function RefreshCategoryMenus()
    for _, category in ipairs(CATEGORIES) do
        RefreshControl("UABankingPvP" .. category.key, "UpdateDisabled")
    end
end

local function CountItemInBag(itemId, bagId)
    local amount = 0

    for slotIndex = 0, GetBagSize(bagId) - 1 do
        if GetItemId(bagId, slotIndex) == itemId then
            amount = amount + (GetSlotStackSize(bagId, slotIndex) or 0)
        end
    end

    return amount
end

local function NormalizeAmount(value, fallback)
    return zo_clamp(zo_floor(tonumber(value) or fallback or 0), 0, MAX_AMOUNT)
end

local function SetMinimum(profile, value)
    profile.minimum = NormalizeAmount(value, profile.minimum)

    if profile.maximum < profile.minimum then
        profile.maximum = profile.minimum
    end
end

local function SetMaximum(profile, value)
    profile.maximum = NormalizeAmount(value, profile.maximum)

    if profile.minimum > profile.maximum then
        profile.minimum = profile.maximum
    end
end

function pvp.GetSettings()
    local savedVariables = ua.savedVariables
    savedVariables.banking = savedVariables.banking or {}
    savedVariables.banking.pvp = savedVariables.banking.pvp or {}

    local settings = savedVariables.banking.pvp

    for _, key in ipairs(OBSOLETE_SETTING_KEYS) do
        settings[key] = nil
    end

    for _, item in ipairs(GetAllItems()) do
        local key = tostring(item.key)
        local profile = settings[key]

        if type(profile) ~= "table" then
            profile = {}
            settings[key] = profile
        end

        if profile.minimum == nil or profile.maximum == nil then
            profile.minimum = 0
            profile.maximum = profile.operator == "inventoryMax"
                    and NormalizeAmount(profile.amount, 0)
                or 0
        end

        profile.minimum = NormalizeAmount(profile.minimum, 0)
        profile.maximum = NormalizeAmount(profile.maximum, 0)

        if profile.maximum < profile.minimum then
            profile.maximum = profile.minimum
        end

        profile.operator = nil
        profile.amount = nil
    end

    return settings
end

function pvp.IsEnabled()
    return ua.savedVariables.banking and ua.savedVariables.banking.pvpEnabled == true
end

function pvp.Initialize()
    local settings = pvp.GetSettings()

    for _, item in ipairs(GetAllItems()) do
        local currentItem = item
        local profile = settings[tostring(currentItem.key)]

        autoBanking.RegisterRule("pvp:" .. tostring(currentItem.key), function()
            if not pvp.IsEnabled() then
                return autoBanking.MODE_NONE
            end

            if profile.minimum == 0 and profile.maximum == 0 then
                return autoBanking.MODE_NONE
            end

            local currentAmount = CountItemInBag(currentItem.itemId, BAG_BACKPACK)

            if currentAmount < profile.minimum then
                return autoBanking.MODE_WITHDRAW
            end

            if currentAmount > profile.maximum then
                return autoBanking.MODE_DEPOSIT
            end

            return autoBanking.MODE_NONE
        end, function(itemLink)
            return GetItemLinkItemId(itemLink) == currentItem.itemId
        end, function(mode, proposedAmount)
            local currentAmount = CountItemInBag(currentItem.itemId, BAG_BACKPACK)
            local requestedAmount = mode == autoBanking.MODE_DEPOSIT
                    and currentAmount - profile.maximum
                or profile.minimum - currentAmount

            return math.min(proposedAmount, math.max(0, requestedAmount))
        end)
    end
end

function pvp.CreateEnableControl()
    return {
        type = "checkbox",
        name = L("ENABLE_PVP"),
        tooltip = L("ENABLE_PVP_TOOLTIP"),
        getFunc = function()
            return pvp.IsEnabled()
        end,
        setFunc = function(value)
            ua.savedVariables.banking.pvpEnabled = value
            RefreshCategoryMenus()
        end,
        default = false,
    }
end

function pvp.CreateMenuControls()
    local settings = pvp.GetSettings()
    local controls = {}

    for _, category in ipairs(CATEGORIES) do
        local categoryControls = {}

        for _, item in ipairs(GetCategoryItems(category.key)) do
            local currentItem = item
            local profile = settings[tostring(currentItem.key)]
            local itemName = GetItemName(currentItem.itemId)
            local minimumReference = "UABankingPvPMinimum" .. tostring(currentItem.key)
            local maximumReference = "UABankingPvPMaximum" .. tostring(currentItem.key)

            table.insert(categoryControls, {
                type = "description",
                text = itemName,
            })

            table.insert(categoryControls, {
                type = "editbox",
                name = L("MINIMUM_TO_KEEP"),
                tooltip = string.format(L("MINIMUM_TO_KEEP_TOOLTIP"), itemName),
                width = "half",
                maxChars = 5,
                textType = TEXT_TYPE_NUMERIC,
                getFunc = function()
                    return tostring(profile.minimum)
                end,
                setFunc = function(value)
                    SetMinimum(profile, value)
                    RefreshControl(maximumReference, "UpdateValue")
                end,
                default = "0",
                reference = minimumReference,
            })

            table.insert(categoryControls, {
                type = "editbox",
                name = L("MAXIMUM_TO_KEEP"),
                tooltip = string.format(L("MAXIMUM_TO_KEEP_TOOLTIP"), itemName),
                width = "half",
                maxChars = 5,
                textType = TEXT_TYPE_NUMERIC,
                getFunc = function()
                    return tostring(profile.maximum)
                end,
                setFunc = function(value)
                    SetMaximum(profile, value)
                    RefreshControl(minimumReference, "UpdateValue")
                end,
                default = "0",
                reference = maximumReference,
            })
        end

        table.insert(controls, {
            type = "submenu",
            name = zo_iconFormat(category.icon, 32, 32) .. " " .. L(category.nameKey),
            tooltip = string.format(L("PVP_CATEGORY_TOOLTIP"), L(category.nameKey)),
            disabled = function()
                return not pvp.IsEnabled()
            end,
            reference = "UABankingPvP" .. category.key,
            controls = categoryControls,
        })
    end

    return controls
end
