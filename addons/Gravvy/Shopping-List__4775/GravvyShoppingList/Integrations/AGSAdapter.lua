ShoppingListAGSAdapter = {}

local Adapter = ShoppingListAGSAdapter

function Adapter:New(owner)
    return setmetatable({ owner = owner, api = nil }, { __index = self })
end

function Adapter:Initialize()
    local api = AwesomeGuildStore
    if not api or not api.GetAPIVersion or api:GetAPIVersion() < 4 then
        return false
    end
    if not api.callback or not api.callback.ITEM_PURCHASED then
        return false
    end

    self.api = api
    api:RegisterCallback(api.callback.ITEM_PURCHASED, function(itemData)
        self.owner:RecordPurchase(
            itemData.itemLink,
            itemData.itemName,
            itemData.stackCount,
            {
                quantity = itemData.stackCount,
                totalPrice = itemData.purchasePrice,
                unitPrice = itemData.purchasePricePerUnit,
                sellerName = itemData.sellerName,
                guildName = itemData.guildName,
                currencyType = itemData.currencyType,
                timestamp = GetTimeStamp(),
            }
        )
    end)
    return true
end

function Adapter:IsAvailable()
    return self.api ~= nil
end

local function storeIsReady(owner)
    if not owner.storeOpen or not GetSelectedTradingHouseGuildId then
        return false
    end
    local guildId = GetSelectedTradingHouseGuildId()
    return guildId ~= nil and guildId ~= 0
end

function Adapter:IsStoreReady()
    return storeIsReady(self.owner)
end

local function getExactSearchText(name)
    local feature = ZO_TradingHouseNameSearchFeature_Shared
    if feature and feature.MakeExactSearchText then
        return feature.MakeExactSearchText(name)
    end
    return name
end

local function startSharedSearch(search)
    if IsInGamepadPreferredMode()
        and GAMEPAD_TRADING_HOUSE_BROWSE
        and GAMEPAD_TRADING_HOUSE_BROWSE.ShowAndThenEnterBrowseResults
    then
        GAMEPAD_TRADING_HOUSE_BROWSE:ShowAndThenEnterBrowseResults()
        return
    end
    search:DoSearch()
end

function Adapter:ApplyAGSRule(entry)
    local ids = self.api:GetFilterIds()
    local rule = entry.match or {}

    local textFilter = self.api:GetFilter(ids.TEXT_FILTER)
    if textFilter and textFilter.SetText then
        textFilter:SetText(getExactSearchText(entry.name))
    end

    local qualityFilter = self.api:GetFilter(ids.QUALITY_FILTER)
    if qualityFilter and qualityFilter.Reset then
        qualityFilter:Reset()
        if rule.qualityMode == "exact" and rule.quality then
            qualityFilter:SetValues(rule.quality, rule.quality)
        elseif rule.qualityMode == "minimum" and rule.quality then
            qualityFilter:SetValues(rule.quality, ITEM_QUALITY_LEGENDARY)
        end
    end

    local levelFilter = self.api:GetFilter(ids.LEVEL_FILTER)
    if levelFilter and levelFilter.Reset then
        levelFilter:Reset()
        if rule.levelMode == "exact" then
            local level = rule.level or 1
            if (rule.championPoints or 0) > 0 then
                level = 50 + rule.championPoints
            end
            levelFilter:SetValues(level, level)
        end
    end

    local traitKeys = {
        "WEAPON_TRAIT_FILTER",
        "ARMOR_TRAIT_FILTER",
        "JEWELRY_TRAIT_FILTER",
        "COMPANION_WEAPON_TRAIT_FILTER",
        "COMPANION_ARMOR_TRAIT_FILTER",
        "COMPANION_JEWELRY_TRAIT_FILTER",
    }
    for _, key in ipairs(traitKeys) do
        local filterId = ids[key]
        local filter = filterId and self.api:GetFilter(filterId)
        if filter and filter.Reset then
            filter:Reset()
            if rule.traitType and rule.traitType ~= ITEM_TRAIT_TYPE_NONE then
                local value = filter:GetValue(rule.traitType)
                if value then
                    filter:SetSelected(value, true)
                end
            end
        end
    end
end

function Adapter:ResetAGSFilters()
    local ids = self.api and self.api:GetFilterIds()
    if type(ids) ~= "table" then
        return
    end
    local reset = {}
    for _, filterId in pairs(ids) do
        local idType = type(filterId)
        if (idType == "number" or idType == "string") and not reset[filterId] then
            reset[filterId] = true
            local filter = self.api:GetFilter(filterId)
            if filter and filter.Reset then
                filter:Reset()
            end
        end
    end
end

function Adapter:Search(entry)
    if not storeIsReady(self.owner) then
        return false, GetString(SI_SHOPPING_LIST_SEARCH_OPEN_STORE)
    end

    local search = TRADING_HOUSE_SEARCH
    if entry.itemLink ~= "" and search and search.LoadSearchItem and search.DoSearch then
        if self.api then
            self:ResetAGSFilters()
        end
        search:LoadSearchItem(entry.itemLink)
        if self.api then
            self:ApplyAGSRule(entry)
        end
        startSharedSearch(search)
        return true, zo_strformat(GetString(SI_SHOPPING_LIST_SEARCHING_FOR), entry.name)
    end

    if self.api then
        self:ResetAGSFilters()
        self:ApplyAGSRule(entry)
        if search and search.DoSearch then
            startSharedSearch(search)
            return true, zo_strformat(GetString(SI_SHOPPING_LIST_SEARCHING_FOR), entry.name)
        end
        return false, GetString(SI_SHOPPING_LIST_SEARCH_AGS_NOT_READY)
    end

    if not entry.nameHash then
        return false, GetString(SI_SHOPPING_LIST_SEARCH_CHOOSE_AUTOCOMPLETE)
    end

    if IsInGamepadPreferredMode()
        and search
        and search.LoadSearchTable
        and search.DoSearch
        and GAMEPAD_TRADING_HOUSE_BROWSE
    then
        search:LoadSearchTable({
            NameSearch = getExactSearchText(entry.name),
        })
        startSharedSearch(search)
        return true, zo_strformat(GetString(SI_SHOPPING_LIST_SEARCHING_FOR), entry.name)
    end

    ClearAllTradingHouseSearchTerms()
    SetTradingHouseFilter(TRADING_HOUSE_FILTER_TYPE_NAME_HASH, entry.nameHash)
    local rule = entry.match or {}
    if rule.qualityMode == "exact" and rule.quality then
        SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_QUALITY, rule.quality, rule.quality)
    elseif rule.qualityMode == "minimum" and rule.quality then
        SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_QUALITY, rule.quality, ITEM_QUALITY_LEGENDARY)
    end
    if rule.levelMode == "exact" then
        if (rule.championPoints or 0) > 0 then
            SetTradingHouseFilterRange(
                TRADING_HOUSE_FILTER_TYPE_CHAMPION_POINTS,
                rule.championPoints,
                rule.championPoints
            )
        else
            SetTradingHouseFilterRange(TRADING_HOUSE_FILTER_TYPE_LEVEL, rule.level, rule.level)
        end
    end
    ExecuteTradingHouseSearch(0, TRADING_HOUSE_SORT_SALE_PRICE, true, false)
    return true, zo_strformat(GetString(SI_SHOPPING_LIST_SEARCHING_FOR), entry.name)
end
