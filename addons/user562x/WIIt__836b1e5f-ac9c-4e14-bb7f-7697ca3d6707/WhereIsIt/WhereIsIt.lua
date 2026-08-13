WhereIsIt = {}
WhereIsIt.name = "WhereIsIt"

WHEREISIT_ICON_WIDTH     = 80  - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
WHEREISIT_NAME_WIDTH     = 430 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
WHEREISIT_CATEGORY_WIDTH = 200 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
WHEREISIT_LOCATION_WIDTH = 335 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X
WHEREISIT_COUNT_WIDTH    = 180 - ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_HEADER_DOUBLE_PADDING_X

--------------------------------------------------
-- Utility Functions
--------------------------------------------------
local function IsHouseBankUnavailable(bagId)
    return bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN
        and (GetCollectibleForBag(bagId) <= 0 or not IsOwnerOfCurrentHouse())
end

local function IsBankUnavailable(bagId)
    return (bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK) and not IsBankOpen()
end

local function FormatNumber(n)
    if not n then return "0" end
    n = zo_floor(n)
    if ZO_CommaDelimitNumber then return ZO_CommaDelimitNumber(n) end
    return tostring(n)
end

local function Trim(s)
    return (s or ""):match("^%s*(.-)%s*$")
end

local function HexToRGB(hex)
    if not hex or #hex < 6 then return 1, 1, 1 end
    return tonumber(hex:sub(1, 2), 16) / 255,
           tonumber(hex:sub(3, 4), 16) / 255,
           tonumber(hex:sub(5, 6), 16) / 255
end

local function NowMS()
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return GetFrameTimeMilliseconds()
end

--------------------------------------------------
-- Currency Data
--------------------------------------------------
local CURRENCY_KEYS = {
    { key = "gold",           label = "Gold",            color = "FFCC00", currencyType = CURT_MONEY           },
    { key = "alliancePoints", label = "Alliance Points", color = "39FF14", currencyType = CURT_ALLIANCE_POINTS },
    { key = "telVar",         label = "Tel Var Stones",  color = "4499FF", currencyType = CURT_TELVAR_STONES   },
    { key = "writVouchers",   label = "Writ Vouchers",   color = "FFFFFF", currencyType = CURT_WRIT_VOUCHERS   },
}

for _, curr in ipairs(CURRENCY_KEYS) do
    curr.r, curr.g, curr.b = HexToRGB(curr.color)
    curr.searchLower = zo_strlower(curr.label)
end

local CURRENCY_ICON = {
    Gold                = "/esoui/art/currency/gold_mipmap.dds",
    ["Alliance Points"] = "/esoui/art/currency/alliancepoints.dds",
    ["Tel Var Stones"]  = "/esoui/art/currency/telvar_mipmap.dds",
    ["Writ Vouchers"]   = "/esoui/art/icons/icon_writvoucher.dds",
}

local LOCATION_BANK            = "bank"
local LOCATION_CRAFT_BAG       = "craftBag"
local LOCATION_HOUSE           = "house"
local LOCATION_FURNITURE_VAULT = "furnitureVault"

--------------------------------------------------
-- Categories
--------------------------------------------------
local CATEGORY_CURRENCY_ORDER = 1
local CATEGORY_FALLBACK_ORDER = 10

local CATEGORY_ORDER          = {}
local CATEGORY_LABEL_TYPE     = {}
local CATEGORY_LABEL_BY_ORDER = {}

local function RegisterCategory(filterType, order, labelFilterType)
    if filterType == nil then return end
    CATEGORY_ORDER[filterType]      = order
    CATEGORY_LABEL_TYPE[filterType] = labelFilterType or filterType
end

RegisterCategory(ITEMFILTERTYPE_WEAPONS,       2)
RegisterCategory(ITEMFILTERTYPE_ARMOR,         3)
RegisterCategory(ITEMFILTERTYPE_JEWELRY,       3, ITEMFILTERTYPE_ARMOR)
RegisterCategory(ITEMFILTERTYPE_CONSUMABLE,    4)
RegisterCategory(ITEMFILTERTYPE_CRAFTING,      5)
RegisterCategory(ITEMFILTERTYPE_FURNISHING,    6)
RegisterCategory(ITEMFILTERTYPE_COMPANION,     7)
RegisterCategory(ITEMFILTERTYPE_QUEST,         8)
RegisterCategory(ITEMFILTERTYPE_JUNK,          9)
RegisterCategory(ITEMFILTERTYPE_MISCELLANEOUS, CATEGORY_FALLBACK_ORDER)

local function BuildCategoryLabels()
    for filterType, order in pairs(CATEGORY_ORDER) do
        if not CATEGORY_LABEL_BY_ORDER[order] then
            local labelType = CATEGORY_LABEL_TYPE[filterType]
            local label = labelType and GetString("SI_ITEMFILTERTYPE", labelType)
            if label and label ~= "" then CATEGORY_LABEL_BY_ORDER[order] = label end
        end
    end
    CATEGORY_LABEL_BY_ORDER[CATEGORY_FALLBACK_ORDER] = CATEGORY_LABEL_BY_ORDER[CATEGORY_FALLBACK_ORDER] or "Miscellaneous"
    CATEGORY_LABEL_BY_ORDER[CATEGORY_CURRENCY_ORDER] = "Currency"
end
BuildCategoryLabels()

local function CategoryLabelForOrder(order)
    return CATEGORY_LABEL_BY_ORDER[order or CATEGORY_FALLBACK_ORDER] or "Miscellaneous"
end

local function PickCategoryOrder(...)
    local numFilters = select("#", ...)
    for i = 1, numFilters do
        local filterType = select(i, ...)
        local order = CATEGORY_ORDER[filterType]
        if order then return order end
    end
    return CATEGORY_FALLBACK_ORDER
end

local function ResolveCategoryOrder(itemLink)
    if not itemLink or itemLink == "" or not GetItemLinkFilterTypeInfo then
        return CATEGORY_FALLBACK_ORDER
    end
    return PickCategoryOrder(GetItemLinkFilterTypeInfo(itemLink))
end

--------------------------------------------------
-- Quality Colours
--------------------------------------------------
local QUALITY_HEX = {
    [0] = "aaaaaa",
    [1] = "ffffff",
    [2] = "2dc50e",
    [3] = "3a92ff",
    [4] = "a02ee4",
    [5] = "e4c027",
}

local QUALITY_RGB = {}
local function GetQualityRGB(quality)
    quality = quality or 1
    local cached = QUALITY_RGB[quality]
    if cached then return cached[1], cached[2], cached[3] end

    local r, g, b
    if GetItemQualityColor then
        local color = GetItemQualityColor(quality)
        if color and color.UnpackRGB then r, g, b = color:UnpackRGB() end
    end
    if not r then r, g, b = HexToRGB(QUALITY_HEX[quality] or "ffffff") end

    QUALITY_RGB[quality] = { r, g, b }
    return r, g, b
end

--------------------------------------------------
-- Bag Scanner
--------------------------------------------------
local function ScanSlotIntoTable(bagId, slotIndex, tbl, location, index)
    local rawName = GetItemName(bagId, slotIndex)
    if not rawName or rawName == "" then return end

    local count = select(2, GetItemInfo(bagId, slotIndex)) or 0
    if count <= 0 then return end

    local itemName      = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, rawName)
    local itemLink      = GetItemLink(bagId, slotIndex)
    local hasLink       = itemLink and itemLink ~= ""
    local trait         = hasLink and GetItemLinkTraitInfo(itemLink) or 0
    local icon          = hasLink and GetItemLinkIcon(itemLink) or nil
    local quality       = hasLink and GetItemLinkDisplayQuality(itemLink) or nil
    local rawSearchName = hasLink and GetItemLinkName(itemLink) or rawName

    local key = zo_strlower(rawSearchName) .. "|" .. location .. "|" .. tostring(trait)
    if tbl[key] then
        tbl[key].count = tbl[key].count + count
    else
        tbl[key] = {
            displayName = itemName,
            searchName  = rawSearchName,
            count       = count,
            location    = location,
            bagId       = bagId,
            slotIndex   = slotIndex,
            trait       = trait,
            itemLink    = itemLink,
            icon        = icon,
            quality     = quality,
            catOrder    = ResolveCategoryOrder(itemLink),
        }
    end

    if index then
        index[slotIndex] = { key = key, count = count }
    end
end

local function ScanBagIntoTable(bagId, tbl, location, index)
    if not ZO_IterateBagSlots then return end

    local ok, iterator, state, initialIndex = pcall(ZO_IterateBagSlots, bagId)
    if not ok or type(iterator) ~= "function" then return end

    local slotIndex = initialIndex
    while true do
        local nextIndex = iterator(state, slotIndex)
        if nextIndex == nil then break end
        slotIndex = nextIndex
        ScanSlotIntoTable(bagId, slotIndex, tbl, location, index)
    end
end

local SLOT_LOCATION = {}
local function InitSlotLocations()
    SLOT_LOCATION[BAG_BACKPACK]       = "Inventory"
    SLOT_LOCATION[BAG_WORN]           = "Worn"
    SLOT_LOCATION[BAG_COMPANION_WORN] = "Companion Worn"
    SLOT_LOCATION[BAG_VIRTUAL]        = "Craft Bag"
end
InitSlotLocations()

function WhereIsIt:ScanCharacter()
    local charId   = tostring(GetCurrentCharacterId())
    local charName = GetUnitName("player")
    local sv       = self.savedVariables

    sv.characters[charId] = sv.characters[charId] or {}
    local slot = sv.characters[charId]
    slot.name  = charName
    slot.items = {}

    self.slotIndex = {}
    self.slotIndex[BAG_BACKPACK] = {}
    self.slotIndex[BAG_WORN]     = {}

    ScanBagIntoTable(BAG_BACKPACK, slot.items, "Inventory", self.slotIndex[BAG_BACKPACK])
    ScanBagIntoTable(BAG_WORN,     slot.items, "Worn",      self.slotIndex[BAG_WORN])

    slot.companion = {}
    self.slotIndex[BAG_COMPANION_WORN] = {}
    if HasActiveCompanion and HasActiveCompanion() then
        ScanBagIntoTable(BAG_COMPANION_WORN, slot.companion, "Companion Worn", self.slotIndex[BAG_COMPANION_WORN])
    end

    slot.currencies = {
        gold           = GetCurrencyAmount(CURT_MONEY,           CURRENCY_LOCATION_CHARACTER),
        alliancePoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER),
        telVar         = GetCurrencyAmount(CURT_TELVAR_STONES,   CURRENCY_LOCATION_CHARACTER),
        writVouchers   = GetCurrencyAmount(CURT_WRIT_VOUCHERS,   CURRENCY_LOCATION_CHARACTER),
    }
    self:InvalidateSource("char:" .. charId)
end

function WhereIsIt:ScanCraftBag()
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.craftBag = {}

    self.slotIndex = self.slotIndex or {}
    self.slotIndex[BAG_VIRTUAL] = {}

    ScanBagIntoTable(BAG_VIRTUAL, sv.account.craftBag, "Craft Bag", self.slotIndex[BAG_VIRTUAL])
    self:InvalidateSource(LOCATION_CRAFT_BAG)
end

function WhereIsIt:ScanBank()
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    local acct = sv.account
    acct.bank = {}

    self.slotIndex = self.slotIndex or {}
    self.slotIndex[BAG_BANK]            = {}
    self.slotIndex[BAG_SUBSCRIBER_BANK] = {}

    if not IsBankUnavailable(BAG_BANK) then
        ScanBagIntoTable(BAG_BANK,            acct.bank, "Bank", self.slotIndex[BAG_BANK])
        ScanBagIntoTable(BAG_SUBSCRIBER_BANK, acct.bank, "Bank", self.slotIndex[BAG_SUBSCRIBER_BANK])
    end
    self:InvalidateSource(LOCATION_BANK)
    self:InvalidateSource("bankCurrency")
end

function WhereIsIt:UpdateInventorySlot(bagId, slotIndex)
    local location = SLOT_LOCATION[bagId]
    if not location or slotIndex == nil then return false end

    local sv = self.savedVariables
    if not sv then return false end

    local index = self.slotIndex and self.slotIndex[bagId]
    if not index then return false end

    local target, sourceKey
    if bagId == BAG_VIRTUAL then
        target    = sv.account and sv.account.craftBag
        sourceKey = LOCATION_CRAFT_BAG
    elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
        target    = sv.account and sv.account.bank
        sourceKey = LOCATION_BANK
    else
        local charId = tostring(GetCurrentCharacterId())
        local slot   = sv.characters and sv.characters[charId]
        if not slot then return false end
        target    = (bagId == BAG_COMPANION_WORN) and slot.companion or slot.items
        sourceKey = "char:" .. charId
    end
    if not target then return false end

    local previous = index[slotIndex]
    if previous then
        local record = target[previous.key]
        if record then
            record.count = record.count - previous.count
            if record.count <= 0 then target[previous.key] = nil end
        end
        index[slotIndex] = nil
    end

    ScanSlotIntoTable(bagId, slotIndex, target, location, index)
    self:InvalidateSource(sourceKey)
    return true
end

function WhereIsIt:RefreshCharacterCurrencies()
    local sv     = self.savedVariables
    local charId = tostring(GetCurrentCharacterId())
    local slot   = sv and sv.characters and sv.characters[charId]
    if not slot or not slot.currencies then return end

    slot.currencies.gold           = GetCurrencyAmount(CURT_MONEY,           CURRENCY_LOCATION_CHARACTER)
    slot.currencies.alliancePoints = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
    slot.currencies.telVar         = GetCurrencyAmount(CURT_TELVAR_STONES,   CURRENCY_LOCATION_CHARACTER)
    slot.currencies.writVouchers   = GetCurrencyAmount(CURT_WRIT_VOUCHERS,   CURRENCY_LOCATION_CHARACTER)
    self:InvalidateSource("char:" .. charId)
end

function WhereIsIt:ScanHouseChests()
    if not (IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse()) then return end
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.house = {}

    for bagId = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        local collectibleId = GetCollectibleForBag(bagId)
        if collectibleId and collectibleId > 0 and IsCollectibleUnlocked(collectibleId) then
            local chestName = GetCollectibleNickname(collectibleId)
            if not chestName or chestName == "" then chestName = GetCollectibleName(collectibleId) end
            if not chestName or chestName == "" then chestName = "House Chest" end
            ScanBagIntoTable(bagId, sv.account.house, chestName)
        end
    end
    self:InvalidateSource(LOCATION_HOUSE)
end

function WhereIsIt:ScanFurnitureVault()
    if not (IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse()) then return end
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.furnitureVault = {}
    ScanBagIntoTable(BAG_FURNITURE_VAULT, sv.account.furnitureVault, "Furniture Vault")
    self:InvalidateSource(LOCATION_FURNITURE_VAULT)
end

function WhereIsIt:ScanGuildBank()
    local sv   = self.savedVariables
    sv.account = sv.account or {}
    sv.account.guildBanks = sv.account.guildBanks or {}

    local guildId = self.selectedGuildBankId
    if (not guildId or guildId == 0) and GetSelectedGuildBankId then
        guildId = GetSelectedGuildBankId()
    end
    if not guildId or guildId == 0 then return end

    if IsGuildBankOpen and not IsGuildBankOpen() then return end

    local guildName = GetGuildName(guildId)
    if not guildName or guildName == "" then guildName = "Guild Bank" end

    local key  = tostring(guildId)
    local slot = { name = guildName, items = {} }
    ScanBagIntoTable(BAG_GUILDBANK, slot.items, guildName)

    if next(slot.items) == nil then
        local existing = sv.account.guildBanks[key]
        if existing and existing.items and next(existing.items) ~= nil then
            existing.name = guildName
            self:InvalidateSource("guild:" .. key)
            return
        end
    end

    sv.account.guildBanks[key] = slot
    self:InvalidateSource("guild:" .. key)
end

function WhereIsIt:ScanCompanion()
    local charId = tostring(GetCurrentCharacterId())
    local sv     = self.savedVariables
    sv.characters[charId] = sv.characters[charId] or {}
    local slot = sv.characters[charId]
    slot.companion = {}
    self.slotIndex = self.slotIndex or {}
    self.slotIndex[BAG_COMPANION_WORN] = {}

    if HasActiveCompanion and HasActiveCompanion() then
        ScanBagIntoTable(BAG_COMPANION_WORN, slot.companion, "Companion Worn", self.slotIndex[BAG_COMPANION_WORN])
    end
    self:InvalidateSource("char:" .. charId)
end

--------------------------------------------------
-- Stale Data Pruning
--------------------------------------------------
local function BuildAccountCharacterIdSet()
    if not (GetNumCharacters and GetCharacterInfo and GetCurrentCharacterId) then return nil end

    local numCharacters = GetNumCharacters()
    if not numCharacters or numCharacters == 0 then return nil end

    local currentId = tostring(GetCurrentCharacterId() or "")
    if currentId == "" then return nil end

    local numReturns = select("#", GetCharacterInfo(1))
    local idPosition
    for i = 1, numCharacters do
        local values = { GetCharacterInfo(i) }
        for position = 1, numReturns do
            if type(values[position]) == "string" and values[position] == currentId then
                idPosition = position
                break
            end
        end
        if idPosition then break end
    end
    if not idPosition then return nil end

    local ids = {}
    for i = 1, numCharacters do
        local id = select(idPosition, GetCharacterInfo(i))
        if id ~= nil then ids[tostring(id)] = true end
    end

    if not ids[currentId] then return nil end
    return ids
end

function WhereIsIt:PruneDeletedCharacters()
    local sv = self.savedVariables
    if not sv or not sv.characters then return end

    local validIds = BuildAccountCharacterIdSet()
    if not validIds then return end

    for charId in pairs(sv.characters) do
        if not validIds[charId] then
            sv.characters[charId] = nil
            self:InvalidateAllSources()
        end
    end
end

function WhereIsIt:PruneLeftGuilds()
    local sv = self.savedVariables
    if not sv or not sv.account or not sv.account.guildBanks then return end
    if not (GetNumGuilds and GetGuildId) then return end

    local validIds = {}
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if guildId and guildId ~= 0 then
            validIds[tostring(guildId)] = true
        end
    end

    local storedCount, matchCount = 0, 0
    for guildId in pairs(sv.account.guildBanks) do
        storedCount = storedCount + 1
        if validIds[guildId] then matchCount = matchCount + 1 end
    end
    if storedCount > 0 and matchCount == 0 and next(validIds) ~= nil then return end

    for guildId in pairs(sv.account.guildBanks) do
        if not validIds[guildId] then
            sv.account.guildBanks[guildId] = nil
            self:InvalidateAllSources()
        end
    end
end

--------------------------------------------------
-- Entry Builder
--------------------------------------------------
local function BuildGuildOrderMap()
    local map = {}
    if not (GetNumGuilds and GetGuildId) then return map end

    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if guildId and guildId ~= 0 then
            map[tostring(guildId)] = i
        end
    end
    return map
end

local function CompareOrderedLocations(a, b)
    if a.order and b.order then
        if a.order ~= b.order then return a.order < b.order end
        return (a.index or 0) < (b.index or 0)
    elseif a.order then
        return true
    elseif b.order then
        return false
    end

    if a.index and b.index then return a.index < b.index end
    if a.index then return true end
    if b.index then return false end

    return zo_strlower(a.label) < zo_strlower(b.label)
end

local ACCOUNT_LOCATIONS = {
    { field = "bank",           key = LOCATION_BANK,            label = "Bank"            },
    { field = "craftBag",       key = LOCATION_CRAFT_BAG,       label = "Craft Bag"       },
    { field = "house",          key = LOCATION_HOUSE,           label = "House Chests"    },
    { field = "furnitureVault", key = LOCATION_FURNITURE_VAULT, label = "Furniture Vault" },
}

WhereIsIt.entryCache  = {}
WhereIsIt.sourceDirty = {}
WhereIsIt.masterDirty = true

function WhereIsIt:InvalidateSource(sourceKey)
    if not sourceKey then return end
    self.sourceDirty[sourceKey] = true
    self.masterDirty = true
end

function WhereIsIt:InvalidateAllSources()
    self.entryCache  = {}
    self.sourceDirty = {}
    self.masterDirty = true
end

function WhereIsIt:ReleaseCaches()
    self.entryCache      = {}
    self.sourceDirty     = {}
    self.cachedEntries   = nil
    self.cachedLocations = nil
    self.masterDirty     = true
end

local function GetCountText(data)
    local text = data.countText
    if not text then
        text = FormatNumber(data.count)
        data.countText = text
    end
    return text
end

local function GetDisplayLower(data)
    if data.displayLower ~= nil then return data.displayLower end
    if data.displayName == data.searchName then
        data.displayLower = false
        return false
    end
    data.displayLower = zo_strlower(data.displayName)
    return data.displayLower
end

local function MakeItemEntry(item, locationKey, displayLocation)
    local displayName = item.displayName or item.searchName or ""
    local searchName  = item.searchName or displayName
    local r, g, b     = GetQualityRGB(item.quality)

    local catOrder = item.catOrder
    if not catOrder then
        catOrder = ResolveCategoryOrder(item.itemLink)
        item.catOrder = catOrder
    end

    return {
        type          = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_SEARCH_TYPE_NAMES,
        displayName   = displayName,
        searchName    = searchName,
        searchLower   = zo_strlower(searchName),
        count         = item.count or 0,
        sortLocation  = displayLocation,
        locationKey   = locationKey,
        category      = CategoryLabelForOrder(catOrder),
        categoryOrder = catOrder,
        itemLink      = item.itemLink,
        icon          = item.icon,
        nameR         = r,
        nameG         = g,
        nameB         = b,
    }
end

local function MakeCurrencyEntry(curr, amount, locationKey, displayLocation)
    return {
        type          = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_SEARCH_TYPE_NAMES,
        displayName   = curr.label,
        searchName    = curr.label,
        searchLower   = curr.searchLower,
        displayLower  = false,
        count         = amount,
        sortLocation  = displayLocation,
        locationKey   = locationKey,
        category      = "Currency",
        categoryOrder = CATEGORY_CURRENCY_ORDER,
        isCurrency    = true,
        icon          = CURRENCY_ICON[curr.label],
        nameR         = curr.r,
        nameG         = curr.g,
        nameB         = curr.b,
    }
end

--------------------------------------------------
-- Chunked list build
--------------------------------------------------
local BUILD_SLICE_MS    = 6
local BUILD_UPDATE_NAME = "WhereIsIt_Build"

local build = nil

local function StopBuild()
    if not build then return end
    EVENT_MANAGER:UnregisterForUpdate(BUILD_UPDATE_NAME)
    build = nil
end

function WhereIsIt:IsBuilding()
    return build ~= nil
end

function WhereIsIt:CancelBuild()
    StopBuild()
end

local function SnapshotKeys(tbl, out)
    local n = 0
    for key in pairs(tbl) do
        n = n + 1
        out[n] = key
    end
    return n
end

local function FinishBuild()
    local b = build
    build = nil
    EVENT_MANAGER:UnregisterForUpdate(BUILD_UPDATE_NAME)

    WhereIsIt.cachedEntries   = b.entries
    WhereIsIt.cachedLocations = b.locations
    WhereIsIt.masterDirty     = false
    WhereIsIt.generation      = (WhereIsIt.generation or 0) + 1

    for sourceKey in pairs(WhereIsIt.entryCache) do
        if not b.liveSources[sourceKey] then
            WhereIsIt.entryCache[sourceKey]  = nil
            WhereIsIt.sourceDirty[sourceKey] = nil
        end
    end

    if b.onComplete then b.onComplete(b.entries, b.locations) end
end

local TIME_CHECK_INTERVAL   = 50
local MAX_ITEMS_PER_SLICE   = 300

local function RunBuildSlice()
    local b = build
    if not b then return end

    local deadline  = NowMS() + BUILD_SLICE_MS
    local processed = 0

    local function SliceExhausted()
        if processed >= MAX_ITEMS_PER_SLICE then return true end
        return NowMS() >= deadline
    end

    while true do
        local job = b.jobs[b.jobIndex]
        if not job then
            FinishBuild()
            return
        end

        if job.cachedSlice then
            local slice   = job.cachedSlice
            local entries = b.entries
            local count   = b.count
            local i       = job.sliceIndex or 1
            local n       = #slice
            local sinceCheck = 0

            while i <= n do
                count = count + 1
                local entry = slice[i]
                entry.entryOrder = count
                entries[count] = entry
                i = i + 1
                processed = processed + 1
                sinceCheck = sinceCheck + 1
                if processed >= MAX_ITEMS_PER_SLICE or sinceCheck >= TIME_CHECK_INTERVAL then
                    sinceCheck = 0
                    if SliceExhausted() then
                        job.sliceIndex = i
                        b.count = count
                        return
                    end
                end
            end

            b.count = count
            b.jobIndex = b.jobIndex + 1
        else
            if not job.tables then
                job.tables = {}
                if job.tbl       then job.tables[#job.tables + 1] = job.tbl end
                if job.companion then job.tables[#job.tables + 1] = job.companion end
                job.tableIndex = 1
                job.keys       = nil
                job.slice      = {}
            end

            local tbl = job.tables[job.tableIndex]
            if not tbl then
                local slice = job.slice
                if job.currencies then
                    for _, curr in ipairs(CURRENCY_KEYS) do
                        local amount = job.currencies[curr.key] or 0
                        if amount > 0 then
                            slice[#slice + 1] = MakeCurrencyEntry(curr, amount, job.locationKey, job.currencyLabel)
                        end
                    end
                end

                WhereIsIt.entryCache[job.locationKey]  = slice
                WhereIsIt.sourceDirty[job.locationKey] = nil
                job.cachedSlice = slice
                job.sliceIndex  = 1
                job.keys        = nil
                job.tables      = nil
            else
                if not job.keys then
                    job.keys     = {}
                    job.numKeys  = SnapshotKeys(tbl, job.keys)
                    job.keyIndex = 1
                end

                local keys       = job.keys
                local slice      = job.slice
                local prefix     = job.prefix
                local fallback   = job.fallback
                local locKey     = job.locationKey
                local i          = job.keyIndex
                local numKeys    = job.numKeys
                local sinceCheck = 0

                while i <= numKeys do
                    local item = tbl[keys[i]]
                    if item then
                        local where
                        if prefix then
                            where = prefix .. " - " .. (item.location or "")
                        else
                            where = item.location or fallback
                        end
                        slice[#slice + 1] = MakeItemEntry(item, locKey, where)
                    end
                    i = i + 1
                    processed = processed + 1
                    sinceCheck = sinceCheck + 1
                    if processed >= MAX_ITEMS_PER_SLICE or sinceCheck >= TIME_CHECK_INTERVAL then
                        sinceCheck = 0
                        if SliceExhausted() then
                            job.keyIndex = i
                            return
                        end
                    end
                end

                job.tableIndex = job.tableIndex + 1
                job.keys       = nil
            end
        end

        if SliceExhausted() then return end
    end
end

local function PrepareJobs(self)
    local sv    = self.savedVariables
    local acct  = sv.account or {}
    local jobs  = {}
    local locations   = {}
    local liveSources = {}

    local function AddJob(locationKey, label, tbl, fallback, currencies, currencyLabel)
        liveSources[locationKey] = true
        local cached = (not self.sourceDirty[locationKey]) and self.entryCache[locationKey] or nil
        jobs[#jobs + 1] = {
            locationKey   = locationKey,
            fallback      = fallback,
            tbl           = tbl,
            currencies    = currencies,
            currencyLabel = currencyLabel,
            cachedSlice   = cached,
        }
    end

    for _, loc in ipairs(ACCOUNT_LOCATIONS) do
        local tbl = acct[loc.field]
        if tbl and next(tbl) ~= nil then
            locations[#locations + 1] = { key = loc.key, label = loc.label }
            AddJob(loc.key, loc.label, tbl, loc.label)
        end
    end

    local guildOrder     = BuildGuildOrderMap()
    local guildLocations = {}
    for guildId, guild in pairs(acct.guildBanks or {}) do
        if guild.items and next(guild.items) ~= nil then
            guildLocations[#guildLocations + 1] = {
                key   = "guild:" .. guildId,
                label = guild.name or "Guild Bank",
                order = guildOrder[tostring(guildId)],
                index = guildOrder[tostring(guildId)],
                items = guild.items,
            }
        end
    end
    table.sort(guildLocations, CompareOrderedLocations)
    for _, loc in ipairs(guildLocations) do
        locations[#locations + 1] = { key = loc.key, label = loc.label }
        AddJob(loc.key, loc.label, loc.items, loc.label)
    end

    liveSources["bankCurrency"] = true
    local bankCurrency = self.entryCache["bankCurrency"]
    if self.sourceDirty["bankCurrency"] or not bankCurrency then
        bankCurrency = {}
        for _, curr in ipairs(CURRENCY_KEYS) do
            local amount = GetCurrencyAmount(curr.currencyType, CURRENCY_LOCATION_BANK)
            if amount and amount > 0 then
                bankCurrency[#bankCurrency + 1] = MakeCurrencyEntry(curr, amount, LOCATION_BANK, "Bank")
            end
        end
        self.entryCache["bankCurrency"]  = bankCurrency
        self.sourceDirty["bankCurrency"] = nil
    end
    if #bankCurrency > 0 then
        local listed = false
        for _, loc in ipairs(locations) do
            if loc.key == LOCATION_BANK then listed = true break end
        end
        if not listed then
            table.insert(locations, 1, { key = LOCATION_BANK, label = "Bank" })
        end
        jobs[#jobs + 1] = { locationKey = "bankCurrency", cachedSlice = bankCurrency }
    end

    local currentCharId = tostring(GetCurrentCharacterId and GetCurrentCharacterId() or "")
    local charLocations = {}
    for charId, data in pairs(sv.characters or {}) do
        charLocations[#charLocations + 1] = {
            key    = "char:" .. charId,
            label  = data.name or ("Char " .. charId),
            order  = (charId == currentCharId) and 0 or nil,
            charId = charId,
            data   = data,
        }
    end
    table.sort(charLocations, CompareOrderedLocations)
    for _, loc in ipairs(charLocations) do
        locations[#locations + 1] = { key = loc.key, label = loc.label }
        local data = loc.data
        liveSources[loc.key] = true
        local cached = (not self.sourceDirty[loc.key]) and self.entryCache[loc.key] or nil
        jobs[#jobs + 1] = {
            locationKey   = loc.key,
            fallback      = loc.label,
            tbl           = data.items,
            prefix        = loc.label,
            currencies    = data.currencies,
            currencyLabel = loc.label,
            cachedSlice   = cached,
            charName      = loc.label,
            companion     = data.companion,
        }
    end

    return jobs, locations, liveSources
end

function WhereIsIt:BuildEntriesAsync(onComplete, onProgress)
    StopBuild()

    if not self.masterDirty and self.cachedEntries then
        if onComplete then onComplete(self.cachedEntries, self.cachedLocations) end
        return
    end

    local jobs, locations, liveSources = PrepareJobs(self)

    local entries = self.cachedEntries or {}
    ZO_ClearNumericallyIndexedTable(entries)

    build = {
        jobs        = jobs,
        jobIndex    = 1,
        entries     = entries,
        locations   = locations,
        liveSources = liveSources,
        count       = 0,
        done        = 0,
        onComplete  = onComplete,
        onProgress  = onProgress,
    }

    EVENT_MANAGER:RegisterForUpdate(BUILD_UPDATE_NAME, 0, function()
        local ok, err = pcall(RunBuildSlice)
        if not ok then
            StopBuild()
            d("|cFF4444[WhereIsIt] list build failed:|r " .. tostring(err))
            return
        end
        if build and build.onProgress then
            build.onProgress(build.jobIndex, #build.jobs)
        end
    end)

    local ok = pcall(RunBuildSlice)
    if not ok then StopBuild() end
end

--------------------------------------------------
-- Deferred Icon Loading
--------------------------------------------------
local ICON_LOAD_DELAY_MS = 120
local ICON_POLL_MS       = 40
local ICON_UPDATE_NAME   = "WhereIsIt_IconLoader"

local pendingIcons      = {}
local pendingIconCount  = 0
local iconLoaderRunning = false
local knownIconControls = {}

local function StopIconLoader()
    if not iconLoaderRunning then return end
    EVENT_MANAGER:UnregisterForUpdate(ICON_UPDATE_NAME)
    iconLoaderRunning = false
end

local function ProcessPendingIcons()
    local now = GetFrameTimeMilliseconds()
    for iconControl in pairs(pendingIcons) do
        if now >= (iconControl.wiiIconAt or 0) then
            local path = iconControl.wiiIconPath
            pendingIcons[iconControl] = nil
            pendingIconCount = pendingIconCount - 1
            iconControl.wiiIconAt = nil
            if path and path ~= "" then
                iconControl.wiiIconCurrent = path
                iconControl:SetTexture(path)
                iconControl:SetHidden(false)
            end
        end
    end
    if pendingIconCount <= 0 then StopIconLoader() end
end

local function StartIconLoader()
    if iconLoaderRunning then return end
    iconLoaderRunning = true
    EVENT_MANAGER:RegisterForUpdate(ICON_UPDATE_NAME, ICON_POLL_MS, ProcessPendingIcons)
end

local function ReleaseIcon(iconControl)
    if not iconControl then return end
    if pendingIcons[iconControl] then
        pendingIcons[iconControl] = nil
        pendingIconCount = pendingIconCount - 1
    end
    iconControl.wiiIconPath = nil
    iconControl.wiiIconAt   = nil
    if iconControl.wiiIconCurrent then
        iconControl.wiiIconCurrent = nil
        iconControl:SetTexture(nil)
    end
    iconControl:SetHidden(true)
    if pendingIconCount <= 0 then StopIconLoader() end
end

local function RequestIcon(iconControl, path)
    if not path or path == "" then
        ReleaseIcon(iconControl)
        return
    end

    if iconControl.wiiIconCurrent == path then
        if pendingIcons[iconControl] then
            pendingIcons[iconControl] = nil
            pendingIconCount = pendingIconCount - 1
        end
        iconControl.wiiIconPath = nil
        iconControl:SetHidden(false)
        return
    end

    if iconControl.wiiIconCurrent then
        iconControl.wiiIconCurrent = nil
        iconControl:SetTexture(nil)
    end
    iconControl:SetHidden(true)

    iconControl.wiiIconPath = path
    iconControl.wiiIconAt   = GetFrameTimeMilliseconds() + ICON_LOAD_DELAY_MS
    if not pendingIcons[iconControl] then
        pendingIcons[iconControl] = true
        pendingIconCount = pendingIconCount + 1
    end
    StartIconLoader()
end

local function ReleaseAllIcons()
    for i = 1, #knownIconControls do
        ReleaseIcon(knownIconControls[i])
    end
    StopIconLoader()
end

local function RowIconsEnabled()
    local sv = WhereIsIt.savedVariables
    if not sv then return true end
    if sv.rowIcons == nil then sv.rowIcons = true end
    return sv.rowIcons == true
end

--------------------------------------------------
-- Gamepad Screen
--------------------------------------------------
local DATA_TYPE_RESULT = ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_PRIMARY_DATA_TYPE

local SORT_KEYS = {
    ["displayName"]   = { caseInsensitive = true, tiebreaker = "entryOrder"  },
    ["categoryOrder"] = { isNumeric = true,       tiebreaker = "displayName" },
    ["sortLocation"]  = { caseInsensitive = true, tiebreaker = "displayName" },
    ["count"]         = { isNumeric = true,       tiebreaker = "displayName" },
    ["entryOrder"]    = { isNumeric = true },
}

local EMPTY_TEXT = "Nothing scanned yet. Visit a bank, guild bank or house to record its contents."

local WhereIsIt_Screen = ZO_GamepadInteractiveSortFilterList:Subclass()

function WhereIsIt_Screen:New(...)
    return ZO_GamepadInteractiveSortFilterList.New(self, ...)
end

function WhereIsIt_Screen:Initialize(control)
    ZO_GamepadInteractiveSortFilterList.Initialize(self, control)

    self:SetMasterList({})
    self:SetTitle("Where Is It?")
    self:SetEmptyText(EMPTY_TEXT)
    self:SetupSort(SORT_KEYS, "categoryOrder", ZO_SORT_ORDER_UP)

    local scene = ZO_Scene:New("whereIsItGamepad", SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD_OPTIONS)
    scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_2_3_BACKGROUND_FRAGMENT)
    scene:AddFragment(MINIMIZE_CHAT_FRAGMENT)
    scene:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
    scene:AddFragment(self:GetListFragment())
    self.scene = scene
end

function WhereIsIt_Screen:InitializeSortFilterList(...)
    ZO_GamepadInteractiveSortFilterList.InitializeSortFilterList(self, ...)
    ZO_ScrollList_AddDataType(self.list, DATA_TYPE_RESULT, "WhereIsIt_ListRow",
        ZO_GAMEPAD_INTERACTIVE_FILTER_LIST_ROW_HEIGHT,
        function(control, data) self:SetupRow(control, data) end,
        function(control) ReleaseIcon(control.wiiIcon) end)
end

function WhereIsIt_Screen:GetDropdownFilterControl()
    return self.contentHeader:GetNamedChild("LocationFilter")
end

function WhereIsIt_Screen:InitializeDropdownFilter()
    ZO_GamepadInteractiveSortFilterList.InitializeDropdownFilter(self)

    self.locationData = ZO_MultiSelection_ComboBox_Data_Gamepad:New()
    self.filterDropdown:SetSortsItems(false)
    self.filterDropdown:SetNoSelectionText("All Locations")
    self.filterDropdown:SetName("Locations")
    self.filterDropdown:LoadData(self.locationData)
end

function WhereIsIt_Screen:InitializeSearchFilter()
    ZO_GamepadInteractiveSortFilterList.InitializeSearchFilter(self)

    self.searchEdit:SetDefaultText("Search")
    self.searchEdit:SetMaxInputChars(60)
    local searchPending = false
    ZO_PreHookHandler(self.searchEdit, "OnTextChanged", function()
        if searchPending then return end
        searchPending = true
        zo_callLater(function()
            searchPending = false
            self:RefreshFilters()
        end, 200)
    end)
end

function WhereIsIt_Screen:GetBackKeybindCallback()
    return function() SCENE_MANAGER:HideCurrentScene() end
end

function WhereIsIt_Screen:InitializeKeybinds()
    local descriptor = { alignment = KEYBIND_STRIP_ALIGN_LEFT }

    table.insert(descriptor, {
        name     = function()
            return self.tooltipShown and "Hide Details" or "Show Details"
        end,
        keybind  = "UI_SHORTCUT_PRIMARY",
        visible  = function() return self:GetSelectedData() ~= nil end,
        callback = function() self:ToggleDetails() end,
    })

    ZO_Gamepad_AddBackNavigationKeybindDescriptorsWithSound(descriptor, GAME_NAVIGATION_TYPE_BUTTON, self:GetBackKeybindCallback())
    self:SetKeybindStripDescriptor(descriptor)

    ZO_GamepadInteractiveSortFilterList.InitializeKeybinds(self)

    self:AddUniversalKeybind({
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name      = "Reset Filters",
        keybind   = "UI_SHORTCUT_RIGHT_STICK",
        visible   = function() return self:HasActiveFilters() end,
        callback  = function() self:ResetFilters() end,
    })
end

--------------------------------------------------
-- Location Filter
--------------------------------------------------
local NO_OP = function() end

function WhereIsIt_Screen:RefreshLocationFilter(locations)
    local previouslySelected = self.previouslySelectedLocations or {}
    self.previouslySelectedLocations = previouslySelected
    for key in pairs(previouslySelected) do previouslySelected[key] = nil end

    for _, item in ipairs(self.locationData:GetSelectedItems()) do
        previouslySelected[item.locationKey] = true
    end

    self.locationData:Clear()
    for _, loc in ipairs(locations) do
        local entry = ZO_ComboBox_Base:CreateItemEntry(loc.label, NO_OP)
        entry.locationKey = loc.key
        self.locationData:AddItem(entry)
    end
    self.filterDropdown:LoadData(self.locationData)

    for _, item in ipairs(self.locationData:GetAllItems()) do
        if previouslySelected[item.locationKey] then
            self.locationData:SetItemSelected(item, true)
        end
    end
    self.filterDropdown:RefreshSelectedItemText()
end

function WhereIsIt_Screen:GetSelectedLocationKeys()
    if not self.locationData then return nil end
    local selected = self.locationData:GetSelectedItems()
    if #selected == 0 then return nil end

    local keys = self.locationKeyScratch or {}
    self.locationKeyScratch = keys
    for key in pairs(keys) do keys[key] = nil end

    for _, item in ipairs(selected) do
        keys[item.locationKey] = true
    end
    return keys
end

function WhereIsIt_Screen:HasActiveFilters()
    if self:GetSelectedLocationKeys() then return true end
    local search = self:GetCurrentSearch()
    return search ~= nil and search ~= "" and Trim(search) ~= ""
end

function WhereIsIt_Screen:ResetFilters()
    self.locationData:ClearAllSelections()
    self.filterDropdown:RefreshSelectedItemText()
    self.searchEdit:SetText("")
    self:RefreshFilters()
    self:UpdateKeybinds()
end

--------------------------------------------------
-- List Data
--------------------------------------------------
local function BeginsWithTerm(haystack, term)
    if not haystack or haystack == "" then return false end
    local startAt = 1
    while true do
        local foundAt = haystack:find(term, startAt, true)
        if not foundAt then return false end
        if foundAt == 1 then return true end
        local previous = haystack:sub(foundAt - 1, foundAt - 1)
        if previous:find("[%s%p]") then return true end
        startAt = foundAt + 1
    end
end

function WhereIsIt_Screen:MatchesSearch(lowerTerm, data)
    if BeginsWithTerm(data.searchLower, lowerTerm) then return true end
    local displayLower = GetDisplayLower(data)
    if displayLower and BeginsWithTerm(displayLower, lowerTerm) then return true end
    return false
end

function WhereIsIt_Screen:ProcessNames(stringSearch, data, searchTerm, cache)
    return self:MatchesSearch(zo_strlower(searchTerm), data)
end

function WhereIsIt_Screen:BuildMasterList()
end

function WhereIsIt_Screen:GetFilterSignature()
    local parts = self.signatureScratch or {}
    self.signatureScratch = parts
    ZO_ClearNumericallyIndexedTable(parts)

    parts[1] = tostring(WhereIsIt.generation or 0)
    parts[2] = Trim(self:GetCurrentSearch())

    local keys = self:GetSelectedLocationKeys()
    if keys then
        local sorted = self.signatureKeyScratch or {}
        self.signatureKeyScratch = sorted
        ZO_ClearNumericallyIndexedTable(sorted)
        for key in pairs(keys) do sorted[#sorted + 1] = key end
        table.sort(sorted)
        parts[3] = table.concat(sorted, ",")
    else
        parts[3] = "*"
    end

    return table.concat(parts, "\1")
end

function WhereIsIt_Screen:RefreshFilters()
    local signature = self:GetFilterSignature()
    if signature == self.lastFilterSignature then return end
    self.lastFilterSignature = signature
    ZO_GamepadInteractiveSortFilterList.RefreshFilters(self)
end

function WhereIsIt_Screen:FilterScrollList()
    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    local searchTerm      = Trim(self:GetCurrentSearch())
    local searchLower     = searchTerm ~= "" and zo_strlower(searchTerm) or nil
    local activeLocations = self:GetSelectedLocationKeys()

    local pool = self.wrapperPool
    if not pool then
        pool = {}
        self.wrapperPool = pool
    end

    local count = 0
    local masterList = self.masterList
    for i = 1, #masterList do
        local data = masterList[i]
        if not activeLocations or activeLocations[data.locationKey] then
            if not searchLower or self:MatchesSearch(searchLower, data) then
                count = count + 1
                local wrapper = pool[count]
                if not wrapper then
                    wrapper = {}
                    pool[count] = wrapper
                end
                wrapper.typeId     = DATA_TYPE_RESULT
                wrapper.categoryId = nil
                wrapper.data       = data
                data.dataEntry     = wrapper
                scrollData[count]  = wrapper
            end
        end
    end

    for i = count + 1, #pool do
        local wrapper = pool[i]
        if wrapper and wrapper.data then wrapper.data = nil end
    end

    if #pool > count * 2 + 64 then
        for i = #pool, count + 1, -1 do pool[i] = nil end
    end
end

function WhereIsIt_Screen:SortScrollList()
    if self.currentSortKey == "categoryOrder" and self.currentSortOrder ~= nil then
        local scrollData = ZO_ScrollList_GetDataList(self.list)
        self.catSortAscending = self.currentSortOrder == ZO_SORT_ORDER_UP

        local sortFn = self.catSortFunction
        if not sortFn then
            sortFn = function(a, b)
                local left, right = a.data, b.data
                local ascending = self.catSortAscending
                if left.categoryOrder ~= right.categoryOrder then
                    if ascending then return left.categoryOrder < right.categoryOrder end
                    return left.categoryOrder > right.categoryOrder
                end
                if left.searchLower ~= right.searchLower then
                    if ascending then return left.searchLower < right.searchLower end
                    return left.searchLower > right.searchLower
                end
                return left.entryOrder < right.entryOrder
            end
            self.catSortFunction = sortFn
        end

        table.sort(scrollData, sortFn)
        return
    end
    ZO_GamepadInteractiveSortFilterList.SortScrollList(self)
end

--------------------------------------------------
-- Async refresh
--------------------------------------------------
function WhereIsIt_Screen:SetLoadingText(text)
    if self.emptyRowMessage then self.emptyRowMessage:SetText(text) end
end

function WhereIsIt_Screen:RefreshData()
    if self.buildInProgress then return end
    self.buildInProgress = true

    self:SetMasterList({})
    self.lastFilterSignature = nil
    self:RefreshFilters()
    self.lastFilterSignature = nil
    self:SetLoadingText("Reading your bags...")

    WhereIsIt:BuildEntriesAsync(
        function(entries, locations)
            self.buildInProgress = false
            self:SetMasterList(entries)
            self:RefreshLocationFilter(locations)
            self:SetEmptyText(EMPTY_TEXT)
            self:SetLoadingText("Sorting...")

            zo_callLater(function()
                local fragment = self:GetListFragment()
                if fragment and fragment:IsHidden() then return end

                self.lastFilterSignature = nil
                self:RefreshFilters()

                if self:HasEntries() and not self:IsPanelFocused() and not self:AreFiltersFocused() then
                    self:ActivatePanelFocus()
                end
                self:UpdateKeybinds()
            end, 0)
        end,
        function(doneJobs, totalJobs)
            if totalJobs > 0 then
                self:SetLoadingText(string.format("Reading your bags... %d%%",
                    zo_min(99, zo_floor(doneJobs / totalJobs * 100))))
            end
        end)
end

function WhereIsIt_Screen:SetupRow(control, data)
    local iconControl = control.wiiIcon
    if not iconControl then
        ZO_GamepadInteractiveSortFilterList.SetupRow(self, control, data)

        iconControl      = control:GetNamedChild("ItemIcon"):GetNamedChild("Icon")
        control.wiiIcon  = iconControl
        control.wiiName  = control:GetNamedChild("Name")
        control.wiiCat   = control:GetNamedChild("Category")
        control.wiiLoc   = control:GetNamedChild("Location")
        control.wiiCount = control:GetNamedChild("Count")

        knownIconControls[#knownIconControls + 1] = iconControl

        if iconControl.SetTextureReleaseOption and RELEASE_TEXTURE_AT_ZERO_REFERENCES then
            iconControl:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
            WhereIsIt.textureReleaseSupported = true
        else
            WhereIsIt.textureReleaseSupported = false
        end

        control.wiiCat:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
        control.wiiLoc:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
        control.wiiCount:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    end

    if RowIconsEnabled() then
        RequestIcon(iconControl, data.icon)
    else
        ReleaseIcon(iconControl)
    end

    local nameLabel = control.wiiName
    nameLabel:SetText(data.displayName)
    nameLabel:SetColor(data.nameR, data.nameG, data.nameB, 1)

    control.wiiCat:SetText(data.category or "")
    control.wiiLoc:SetText(data.sortLocation or "")
    control.wiiCount:SetText(GetCountText(data))
end

--------------------------------------------------
-- Cheap list movement
--------------------------------------------------
function WhereIsIt_Screen:MoveNext()
    local list  = self.list
    local index = ZO_ScrollList_GetSelectedDataIndex(list)
    if not index or index >= #ZO_ScrollList_GetDataList(list) then return end
    PlaySound(SOUNDS.GAMEPAD_MENU_DOWN)
    ZO_ScrollList_SelectNextData(list)
    self:UpdateKeybinds()
end

function WhereIsIt_Screen:MovePrevious()
    local list  = self.list
    local index = ZO_ScrollList_GetSelectedDataIndex(list)
    if not index or index <= 1 then return end
    PlaySound(SOUNDS.GAMEPAD_MENU_UP)
    ZO_ScrollList_SelectPreviousData(list)
    self:UpdateKeybinds()
end

--------------------------------------------------
-- Tooltip
--------------------------------------------------
function WhereIsIt_Screen:ClearTooltip()
    GAMEPAD_TOOLTIPS:ClearTooltip(GAMEPAD_RIGHT_TOOLTIP)
end

function WhereIsIt_Screen:RefreshTooltip()
    self:ClearTooltip()

    local data = self:GetSelectedData()
    if not data then return end

    if data.isCurrency then
        GAMEPAD_TOOLTIPS:LayoutTitleAndMultiSectionDescriptionTooltip(GAMEPAD_RIGHT_TOOLTIP,
            data.displayName,
            data.sortLocation or "",
            GetCountText(data))
    elseif data.itemLink and data.itemLink ~= "" then
        GAMEPAD_TOOLTIPS:LayoutItemWithStackCountSimple(GAMEPAD_RIGHT_TOOLTIP, data.itemLink, data.count)
    end
end

function WhereIsIt_Screen:HideDetails()
    if not self.tooltipShown then return end
    self.tooltipShown = false
    self:ClearTooltip()
    self:UpdateKeybinds()
end

function WhereIsIt_Screen:ToggleDetails()
    if self.tooltipShown then
        self:HideDetails()
        return
    end

    local data = self:GetSelectedData()
    if not data then return end

    self.tooltipShown = true
    self:RefreshTooltip()
    self:UpdateKeybinds()
end

function WhereIsIt_Screen:OnSelectionChanged(oldData, newData)
    ZO_GamepadInteractiveSortFilterList.OnSelectionChanged(self, oldData, newData)
    self:HideDetails()
end

function WhereIsIt_Screen:Deactivate(...)
    ZO_GamepadInteractiveSortFilterList.Deactivate(self, ...)
    self.tooltipShown = false
    self:ClearTooltip()
end

--------------------------------------------------
-- Screen Lifecycle
--------------------------------------------------
local RELEASE_GRACE_MS = 60000
local RELEASE_NAME     = "WhereIsIt_Release"

local function CancelScheduledRelease()
    EVENT_MANAGER:UnregisterForUpdate(RELEASE_NAME)
end

local function ScheduleRelease()
    CancelScheduledRelease()
    EVENT_MANAGER:RegisterForUpdate(RELEASE_NAME, RELEASE_GRACE_MS, function()
        CancelScheduledRelease()
        WhereIsIt:ReleaseCaches()
    end)
end

function WhereIsIt_Screen:OnShowing()
    CancelScheduledRelease()
    self:Activate()
    if WhereIsIt.masterDirty or not self.masterList or #self.masterList == 0 then
        self:RefreshData()
    end
end

function WhereIsIt_Screen:OnHidden()
    self.tooltipShown = false
    self:ClearTooltip()

    WhereIsIt:CancelBuild()
    self.buildInProgress = false

    ReleaseAllIcons()

    local scrollData = ZO_ScrollList_GetDataList(self.list)
    ZO_ClearNumericallyIndexedTable(scrollData)

    if self.wrapperPool then
        for i = 1, #self.wrapperPool do self.wrapperPool[i] = nil end
    end

    ScheduleRelease()
end

function WhereIsIt_Screen_OnInitialized(control)
    WhereIsIt.screen = WhereIsIt_Screen:New(control)
end

--------------------------------------------------
-- Main Menu Integration
--------------------------------------------------
local function AddToMainMenu()
    for i, v in ipairs(ZO_MENU_ENTRIES) do
        if v.id == 997 then return end
    end

    local ICON = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_activityFinder.dds"
    local entry = ZO_GamepadEntryData:New("|cFFCC00Where Is It?|r", ICON)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry.id   = 997
    entry.data = { name = "|cFFCC00Where Is It?|r", id = 997, scene = "whereIsItGamepad" }

    local insertIndex = nil
    for i, v in ipairs(ZO_MENU_ENTRIES) do
        if v.id == ZO_MENU_MAIN_ENTRIES.INVENTORY then
            insertIndex = i + 1
            break
        end
    end
    if insertIndex then
        table.insert(ZO_MENU_ENTRIES, insertIndex, entry)
    else
        table.insert(ZO_MENU_ENTRIES, entry)
    end

    if MAIN_MENU_GAMEPAD then
        MAIN_MENU_GAMEPAD:RefreshLists()
        MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
    end
end

--------------------------------------------------
-- Diagnostics
--------------------------------------------------
local function CountKeys(tbl)
    local n = 0
    if type(tbl) == "table" then for _ in pairs(tbl) do n = n + 1 end end
    return n
end

local function PrintDiagnostics()
    local poolBefore, poolCap
    if GetTotalUserAddOnMemoryPoolUsageMB then
        poolBefore = GetTotalUserAddOnMemoryPoolUsageMB()
        poolCap    = GetTotalUserAddOnMemoryPoolCapacityMB and GetTotalUserAddOnMemoryPoolCapacityMB() or 0
    end

    local before = collectgarbage("count")
    pcall(collectgarbage, "collect")
    local after = collectgarbage("count")

    local poolAfter = GetTotalUserAddOnMemoryPoolUsageMB and GetTotalUserAddOnMemoryPoolUsageMB() or nil

    local screen  = WhereIsIt.screen
    local entries = WhereIsIt.cachedEntries and #WhereIsIt.cachedEntries or 0
    local rows    = screen and #ZO_ScrollList_GetDataList(screen.list) or 0
    local pool    = screen and screen.wrapperPool and #screen.wrapperPool or 0

    if poolBefore then
        d(string.format("|cFFCC00[WhereIsIt]|r Add-on pool: %.2f MB -> %.2f MB after GC (cap %s MB)",
            poolBefore, poolAfter or poolBefore, tostring(poolCap)))
        if WhereIsIt.poolMark then
            d(string.format("  since mark: %+.2f MB   (mark was %.2f MB)",
                poolBefore - WhereIsIt.poolMark, WhereIsIt.poolMark))
        end
    end
    d(string.format("|cFFCC00[WhereIsIt]|r Lua heap: %.2f MB (was %.2f MB before GC)", after / 1024, before / 1024))
    d(string.format("  master entries: %d   rows in list: %d   wrapper pool: %d", entries, rows, pool))
    d(string.format("  entry-cache sources: %d   pooled icon controls: %d   building: %s",
        CountKeys(WhereIsIt.entryCache), #knownIconControls, tostring(WhereIsIt:IsBuilding())))
    d(string.format("  row icons: %s   texture release option supported: %s",
        RowIconsEnabled() and "ON" or "OFF", tostring(WhereIsIt.textureReleaseSupported)))
end

local function SetPoolMark()
    if not GetTotalUserAddOnMemoryPoolUsageMB then
        d("|cFFCC00[WhereIsIt]|r Pool readout not available here.")
        return
    end
    WhereIsIt.poolMark = GetTotalUserAddOnMemoryPoolUsageMB()
    d(string.format("|cFFCC00[WhereIsIt]|r Mark set at %.2f MB. Scroll, then run /wiimem.", WhereIsIt.poolMark))
end

local function ToggleRowIcons()
    local sv = WhereIsIt.savedVariables
    if not sv then return end

    sv.rowIcons = not RowIconsEnabled()
    ReleaseAllIcons()

    local screen = WhereIsIt.screen
    if screen and screen.list then
        ZO_ScrollList_RefreshVisible(screen.list)
    end

    d(string.format("|cFFCC00[WhereIsIt]|r Row icons %s. Reopen the list to be sure it has taken effect.",
        sv.rowIcons and "ON" or "OFF"))
end

--------------------------------------------------
-- Addon Loaded
--------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= WhereIsIt.name then return end

    WhereIsIt.savedVariables = ZO_SavedVars:NewAccountWide(
        "WhereIsIt_SavedVars", 4, nil,
        { characters = {}, account = { bank = {}, craftBag = {}, guildBanks = {}, house = {}, furnitureVault = {} } }
    )

    WhereIsIt.savedVariables.account = WhereIsIt.savedVariables.account or {}
    WhereIsIt.savedVariables.account.guildBanks = WhereIsIt.savedVariables.account.guildBanks or {}
    WhereIsIt.savedVariables.account.guildBank  = nil

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_Activate",
        EVENT_PLAYER_ACTIVATED,
        function()
            WhereIsIt:ScanCharacter()
            WhereIsIt:ScanCraftBag()
            WhereIsIt:PruneDeletedCharacters()
            AddToMainMenu()
            EVENT_MANAGER:UnregisterForEvent(WhereIsIt.name .. "_Activate", EVENT_PLAYER_ACTIVATED)
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_HouseEnter",
        EVENT_PLAYER_ACTIVATED,
        function()
            if IsOwnerOfCurrentHouse and IsOwnerOfCurrentHouse() then
                WhereIsIt:ScanHouseChests()
                WhereIsIt:ScanFurnitureVault()
            end
        end
    )

    local currencyPending = false
    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_InvUpdate",
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        function(eventCode, bagId, slotIndex)
            if not WhereIsIt:UpdateInventorySlot(bagId, slotIndex) then
                if bagId == BAG_BACKPACK or bagId == BAG_WORN or bagId == BAG_COMPANION_WORN then
                    WhereIsIt:ScanCharacter()
                elseif bagId == BAG_VIRTUAL then
                    WhereIsIt:ScanCraftBag()
                elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
                    WhereIsIt:ScanBank()
                end
                return
            end

            if not currencyPending then
                currencyPending = true
                zo_callLater(function()
                    currencyPending = false
                    WhereIsIt:RefreshCharacterCurrencies()
                end, 3000)
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_Bank",
        EVENT_OPEN_BANK,
        function() WhereIsIt:ScanBank() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_BankClosed",
        EVENT_CLOSE_BANK,
        function()
            if WhereIsIt.slotIndex then
                WhereIsIt.slotIndex[BAG_BANK]            = nil
                WhereIsIt.slotIndex[BAG_SUBSCRIBER_BANK] = nil
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_House",
        EVENT_HOUSING_EDITOR_MODE_CHANGED,
        function()
            WhereIsIt:ScanHouseChests()
            WhereIsIt:ScanFurnitureVault()
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankSelected",
        EVENT_GUILD_BANK_SELECTED,
        function(eventCode, guildId)
            WhereIsIt.selectedGuildBankId = guildId
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankDeselected",
        EVENT_GUILD_BANK_DESELECTED,
        function()
            WhereIsIt.selectedGuildBankId = nil
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildDataLoaded",
        EVENT_GUILD_DATA_LOADED,
        function() WhereIsIt:PruneLeftGuilds() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildLeft",
        EVENT_GUILD_SELF_LEFT_GUILD,
        function(eventCode, guildServerId, characterName, guildId)
            local sv = WhereIsIt.savedVariables
            if sv and sv.account and sv.account.guildBanks and guildId then
                sv.account.guildBanks[tostring(guildId)] = nil
                WhereIsIt:InvalidateAllSources()
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankReady",
        EVENT_GUILD_BANK_ITEMS_READY,
        function() WhereIsIt:ScanGuildBank() end
    )

    local guildScanPending = false
    local function RequestGuildBankScan()
        if guildScanPending then return end
        guildScanPending = true
        zo_callLater(function()
            guildScanPending = false
            WhereIsIt:ScanGuildBank()
        end, 1500)
    end

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankAdded",
        EVENT_GUILD_BANK_ITEM_ADDED,
        RequestGuildBankScan
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_GuildBankRemoved",
        EVENT_GUILD_BANK_ITEM_REMOVED,
        RequestGuildBankScan
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_CompanionOn",
        EVENT_COMPANION_ACTIVATED,
        function() WhereIsIt:ScanCompanion() end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_CompanionOff",
        EVENT_COMPANION_DEACTIVATED,
        function()
            local charId = tostring(GetCurrentCharacterId())
            local sv = WhereIsIt.savedVariables
            if sv.characters[charId] then
                sv.characters[charId].companion = {}
                WhereIsIt:InvalidateSource("char:" .. charId)
            end
        end
    )

    EVENT_MANAGER:RegisterForEvent(
        WhereIsIt.name .. "_Deactivate",
        EVENT_PLAYER_DEACTIVATED,
        function() WhereIsIt:ScanCharacter() end
    )

    SLASH_COMMANDS["/wii"] = function(args)
        local arg = args and Trim(args) or ""
        if arg == "mem" then
            PrintDiagnostics()
            return
        elseif arg == "mark" then
            SetPoolMark()
            return
        elseif arg == "icons" then
            ToggleRowIcons()
            return
        end
        SCENE_MANAGER:Show("whereIsItGamepad")
    end
    SLASH_COMMANDS["/wiimem"]   = PrintDiagnostics
    SLASH_COMMANDS["/wiimark"]  = SetPoolMark
    SLASH_COMMANDS["/wiiicons"] = ToggleRowIcons

    EVENT_MANAGER:UnregisterForEvent(WhereIsIt.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(WhereIsIt.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
