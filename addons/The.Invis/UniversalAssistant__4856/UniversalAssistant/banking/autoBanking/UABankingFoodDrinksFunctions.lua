local ua = UAssistant
local autoBanking = ua.Banking.AutoBanking

autoBanking.FoodDrinks = autoBanking.FoodDrinks or {}
local foodDrinks = autoBanking.FoodDrinks

local MAX_AMOUNT = 99999
local SELECTOR_REFERENCE = "UABankingFoodDrinkSelector"
local MINIMUM_REFERENCE = "UABankingFoodDrinkMinimum"
local MAXIMUM_REFERENCE = "UABankingFoodDrinkMaximum"
local MENU_REFERENCE = "UABankingSpecialItemsfoodsDrinks"
local EVENT_NAMESPACE = ua.addonName .. "BankingFoodDrinks"

local function L(key)
    return ua.GetString("BANKING_" .. key)
end

local function CanonicalizeItemLink(itemLink)
    if not itemLink or itemLink == "" then
        return nil
    end

    return string.gsub(itemLink, "^|H%d+:", "|H1:")
end

local function NormalizeAmount(value, fallback)
    return zo_clamp(zo_floor(tonumber(value) or fallback or 0), 0, MAX_AMOUNT)
end

local function NormalizeProfile(profile, itemLink)
    profile.itemLink = itemLink or profile.itemLink
    profile.minimum = NormalizeAmount(profile.minimum, 0)
    profile.maximum = NormalizeAmount(profile.maximum, 0)

    if profile.maximum < profile.minimum then
        profile.maximum = profile.minimum
    end

    return profile
end

function foodDrinks.GetSettings()
    local savedVariables = ua.savedVariables
    savedVariables.banking = savedVariables.banking or {}
    savedVariables.banking.specialItems = savedVariables.banking.specialItems or {}

    local settings = savedVariables.banking.specialItems

    if type(settings.foodsDrinks) ~= "table" then
        settings.foodsDrinks = {}
    end

    settings.foodMode = nil
    settings.drinkMode = nil
    settings.fishMode = nil

    for key, profile in pairs(settings.foodsDrinks) do
        if type(profile) ~= "table" then
            settings.foodsDrinks[key] = nil
        else
            NormalizeProfile(profile, key)
        end
    end

    return settings
end

local function IsSpecialItemsEnabled()
    return ua.savedVariables.banking and ua.savedVariables.banking.specialItemsEnabled == true
end

local function IsFoodDrinkLink(itemLink)
    if not itemLink or itemLink == "" then
        return false
    end

    local itemType = GetItemLinkItemType(itemLink)

    return itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK
end

local function GetFoodDrinkKey(itemLink)
    if not IsFoodDrinkLink(itemLink) then
        return nil
    end

    return CanonicalizeItemLink(itemLink)
end

local function CountFoodDrinkInBag(foodDrinkKey, bagId)
    local amount = 0

    for slotIndex = 0, GetBagSize(bagId) - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)

        if GetFoodDrinkKey(itemLink) == foodDrinkKey then
            amount = amount + (GetSlotStackSize(bagId, slotIndex) or 0)
        end
    end

    return amount
end

local function RegisterFoodDrinkRule(foodDrinkKey, profile)
    autoBanking.RegisterRule("special:foodDrink:" .. foodDrinkKey, function()
        if not IsSpecialItemsEnabled() or (profile.minimum == 0 and profile.maximum == 0) then
            return autoBanking.MODE_NONE
        end

        local currentAmount = CountFoodDrinkInBag(foodDrinkKey, BAG_BACKPACK)

        if currentAmount < profile.minimum then
            return autoBanking.MODE_WITHDRAW
        end

        if currentAmount > profile.maximum then
            return autoBanking.MODE_DEPOSIT
        end

        return autoBanking.MODE_NONE
    end, function(itemLink)
        return GetFoodDrinkKey(itemLink) == foodDrinkKey
    end, function(mode, proposedAmount)
        local currentAmount = CountFoodDrinkInBag(foodDrinkKey, BAG_BACKPACK)
        local requestedAmount = mode == autoBanking.MODE_DEPOSIT and currentAmount - profile.maximum
            or profile.minimum - currentAmount

        return math.min(proposedAmount, math.max(0, requestedAmount))
    end)
end

local function ScanBag(bagId, found)
    for slotIndex = 0, GetBagSize(bagId) - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        local foodDrinkKey = GetFoodDrinkKey(itemLink)

        if foodDrinkKey and not found[foodDrinkKey] then
            found[foodDrinkKey] = itemLink
        end
    end
end

local function GetAvailableFoodDrinks()
    local found = {}

    ScanBag(BAG_BACKPACK, found)
    ScanBag(BAG_BANK, found)

    if IsESOPlusSubscriber() then
        ScanBag(BAG_SUBSCRIBER_BANK, found)
    end

    local entries = {}

    for foodDrinkKey, itemLink in pairs(found) do
        table.insert(entries, {
            key = foodDrinkKey,
            itemLink = itemLink,
            sortName = zo_strformat("<<z:1>>", GetItemLinkName(itemLink)),
        })
    end

    table.sort(entries, function(left, right)
        if left.sortName == right.sortName then
            return left.key < right.key
        end

        return left.sortName < right.sortName
    end)

    return entries
end

local function RefreshValue(reference)
    local control = _G[reference]

    if control and control.UpdateValue then
        control:UpdateValue()
    end

    if control and control.UpdateDisabled then
        control:UpdateDisabled()
    end
end

local function GetSelectedProfile(settings)
    local foodDrinkKey = settings.selectedFoodDrinkKey

    if not foodDrinkKey or foodDrinkKey == "" then
        return nil
    end

    return settings.foodsDrinks[foodDrinkKey]
end

local function BuildChoices(settings)
    local entries = GetAvailableFoodDrinks()
    local choices = {}
    local values = {}
    local available = {}

    for _, entry in ipairs(entries) do
        local profile = settings.foodsDrinks[entry.key]

        if type(profile) ~= "table" then
            profile = {}
            settings.foodsDrinks[entry.key] = profile
        end

        NormalizeProfile(profile, entry.itemLink)
        RegisterFoodDrinkRule(entry.key, profile)
        available[entry.key] = true
        table.insert(choices, entry.itemLink)
        table.insert(values, entry.key)
    end

    if #choices == 0 then
        settings.selectedFoodDrinkKey = nil
        table.insert(choices, L("NO_FOOD_DRINK_FOUND"))
        table.insert(values, "")
    elseif not available[settings.selectedFoodDrinkKey] then
        settings.selectedFoodDrinkKey = values[1]
    end

    return choices, values
end

function foodDrinks.RefreshChoices()
    local settings = foodDrinks.GetSettings()
    local choices, values = BuildChoices(settings)
    local control = _G[SELECTOR_REFERENCE]

    if control and control.UpdateChoices then
        control.data.choices = choices
        control.data.choicesValues = values
        control.data.choicesTooltips = nil
        control:UpdateChoices(choices, values)
        control.dropdown.uaFoodDrinkSelector = true
        control:UpdateValue()
    end

    RefreshValue(MINIMUM_REFERENCE)
    RefreshValue(MAXIMUM_REFERENCE)

    return choices, values
end

local function SetMinimum(settings, value)
    local profile = GetSelectedProfile(settings)

    if not profile then
        return
    end

    profile.minimum = NormalizeAmount(value, profile.minimum)

    if profile.maximum < profile.minimum then
        profile.maximum = profile.minimum
    end
end

local function SetMaximum(settings, value)
    local profile = GetSelectedProfile(settings)

    if not profile then
        return
    end

    profile.maximum = NormalizeAmount(value, profile.maximum)

    if profile.minimum > profile.maximum then
        profile.minimum = profile.maximum
    end
end

local function InstallItemTooltipHook()
    if foodDrinks.tooltipHookInstalled then
        return
    end

    foodDrinks.tooltipHookInstalled = true

    SecurePostHook(ZO_ComboBoxDropdown_Keyboard, "OnEntryMouseEnter", function(rowControl)
        local comboBox = rowControl and rowControl.m_owner

        if not comboBox or not comboBox.uaFoodDrinkSelector then
            return
        end

        local dataEntry = rowControl.dataEntry
        local data = dataEntry and dataEntry.data
        local foodDrinkKey = data and data.value
        local settings = foodDrinks.GetSettings()
        local profile = foodDrinkKey and settings.foodsDrinks[foodDrinkKey]
        local itemLink = profile and profile.itemLink

        if not IsFoodDrinkLink(itemLink) then
            return
        end

        ClearTooltip(InformationTooltip)
        InitializeTooltip(ItemTooltip, rowControl, LEFT, -10, 0, RIGHT)
        ItemTooltip:SetLink(itemLink)
    end)

    SecurePostHook(ZO_ComboBoxDropdown_Keyboard, "OnEntryMouseExit", function(rowControl)
        local comboBox = rowControl and rowControl.m_owner

        if comboBox and comboBox.uaFoodDrinkSelector then
            ClearTooltip(ItemTooltip)
        end
    end)
end

function foodDrinks.Initialize()
    local settings = foodDrinks.GetSettings()

    for foodDrinkKey, profile in pairs(settings.foodsDrinks) do
        RegisterFoodDrinkRule(foodDrinkKey, profile)
    end

    InstallItemTooltipHook()

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", foodDrinks.RefreshChoices)
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", foodDrinks.RefreshChoices)

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(_, bagId)
            if bagId ~= BAG_BACKPACK and bagId ~= BAG_BANK and bagId ~= BAG_SUBSCRIBER_BANK then
                return
            end

            foodDrinks.refreshToken = (foodDrinks.refreshToken or 0) + 1
            local refreshToken = foodDrinks.refreshToken

            zo_callLater(function()
                if refreshToken == foodDrinks.refreshToken then
                    foodDrinks.RefreshChoices()
                end
            end, 150)
        end
    )
end

function foodDrinks.CreateMenuControl()
    local settings = foodDrinks.GetSettings()
    local choices, values = BuildChoices(settings)

    return {
        type = "submenu",
        name = zo_iconFormat("/esoui/art/icons/crafting_bowl_002.dds", 32, 32) .. " " .. L(
            "FOODS_DRINKS"
        ),
        disabled = function()
            return not IsSpecialItemsEnabled()
        end,
        reference = MENU_REFERENCE,
        controls = {
            {
                type = "dropdown",
                name = L("SELECT_FOOD_DRINK"),
                tooltip = L("SELECT_FOOD_DRINK_TOOLTIP"),
                choices = choices,
                choicesValues = values,
                scrollable = 12,
                getFunc = function()
                    return settings.selectedFoodDrinkKey or ""
                end,
                setFunc = function(value)
                    settings.selectedFoodDrinkKey = value ~= "" and value or nil
                    RefreshValue(MINIMUM_REFERENCE)
                    RefreshValue(MAXIMUM_REFERENCE)
                end,
                default = "",
                reference = SELECTOR_REFERENCE,
            },
            {
                type = "editbox",
                name = L("MINIMUM_TO_KEEP"),
                tooltip = L("FOOD_DRINK_MINIMUM_TOOLTIP"),
                width = "half",
                maxChars = 5,
                textType = TEXT_TYPE_NUMERIC,
                getFunc = function()
                    local profile = GetSelectedProfile(settings)
                    return tostring(profile and profile.minimum or 0)
                end,
                setFunc = function(value)
                    SetMinimum(settings, value)
                    RefreshValue(MAXIMUM_REFERENCE)
                end,
                disabled = function()
                    return GetSelectedProfile(settings) == nil
                end,
                default = "0",
                reference = MINIMUM_REFERENCE,
            },
            {
                type = "editbox",
                name = L("MAXIMUM_TO_KEEP"),
                tooltip = L("FOOD_DRINK_MAXIMUM_TOOLTIP"),
                width = "half",
                maxChars = 5,
                textType = TEXT_TYPE_NUMERIC,
                getFunc = function()
                    local profile = GetSelectedProfile(settings)
                    return tostring(profile and profile.maximum or 0)
                end,
                setFunc = function(value)
                    SetMaximum(settings, value)
                    RefreshValue(MINIMUM_REFERENCE)
                end,
                disabled = function()
                    return GetSelectedProfile(settings) == nil
                end,
                default = "0",
                reference = MAXIMUM_REFERENCE,
            },
        },
    }
end
