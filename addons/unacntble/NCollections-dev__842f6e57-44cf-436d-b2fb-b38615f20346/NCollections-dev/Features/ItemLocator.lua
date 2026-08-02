NCollections = NCollections or {}
NCollections.Features = NCollections.Features or {}

local ItemLocator = {}
NCollections.ItemLocator = ItemLocator
NCollections.Features.ItemLocator = ItemLocator

local Codec = NCollections.ItemLocatorCodec
local C = {
    VERSION = 1,
    NAMESPACE = "ItemLocator",
    EVENT_NAMESPACE = "NCollections_ItemLocator",
    FLUSH_UPDATE = "NCollections_ItemLocator_Flush",
    FULL_SCAN_UPDATE = "NCollections_ItemLocator_FullScan",
    BANK_SCAN_UPDATE = "NCollections_ItemLocator_BankScan",
    STORAGE_SCAN_UPDATE = "NCollections_ItemLocator_StorageScan",
    FLUSH_DELAY_MS = 250,
    RESCAN_DELAY_MS = 100,
    SCAN_BUDGET_MS = 2,
    SCAN_MAX_SLOTS_PER_FRAME = 8,
}

local defaults = {
    v = C.VERSION,
    e = false,
    c = {},
    p = {},
    k = { t = 0, p = "" },
    m = { t = 0, p = "" },
    f = { t = 0, p = "" },
    h = {},
    x = {},
}

local savedVariables
local initialized = false
local eventsRegistered = false
local bankOpen = false
local furnitureVaultOpen = false
local houseBankBag
local bankCacheReady = false
local furnitureVaultCacheReady = false
local houseBankCacheReady = false
local catalogLookupReady = false
local unavailableData = false
local catalogHashToIds = {}
local dirty = { b = false, w = false, k = false, m = false, f = false, h = false }
local aggregates = { b = {}, w = {}, k = {}, m = {}, f = {}, h = {} }
local slotIds = {}
local slotCounts = {}
local codecBuffer = {}
local codecIds = {}
local codecFields = {}
local decodeScratch = {}
local remapScratch = {}
local identityParts = {}
local CompactCatalog
local CancelStorageScan
local StartStorageScan
local storageScanJob

local TRACKED_BAGS = {}
local BANK_BAGS = {}

local function Clear(values)
    for key in pairs(values) do values[key] = nil end
end

local function IsTrue(value)
    return value == true and 1 or 0
end

local function Number(value)
    return tonumber(value) or 0
end

local function SafeNumber(api, ...)
    if type(api) ~= "function" then return 0 end
    return Number(api(...))
end

local function SafeBoolean(api, ...)
    if type(api) ~= "function" then return 0 end
    return IsTrue(api(...))
end

local function GetCharacterName(name)
    name = tostring(name or "")
    if zo_strformat and SI_UNIT_NAME then
        name = zo_strformat(SI_UNIT_NAME, name)
    end
    return name
end

local function GetCurrentCharacterKey()
    if GetCurrentCharacterId then
        local characterId = GetCurrentCharacterId()
        if characterId ~= nil and tostring(characterId) ~= "" then
            return tostring(characterId)
        end
    end
    return GetCharacterName(GetUnitName and GetUnitName("player") or "")
end

local function GetCurrentCharacterName()
    return GetCharacterName(GetUnitName and GetUnitName("player") or "")
end

local function GetBankName()
    if GetString and SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BANK then
        local name = GetString(SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_BANK)
        if name and name ~= "" then return name end
    end
    return NCollections.L("item_locator.bank")
end

local function GetCraftBagName()
    if GetString and SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER then
        local name = GetString(SI_GAMEPAD_INVENTORY_CRAFT_BAG_HEADER)
        if name and name ~= "" then return name end
    end
    return NCollections.L("item_locator.craft_bag")
end

local function GetFurnitureVaultName()
    if GetString and SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT then
        local name = GetString(SI_GAMEPAD_INVENTORY_STACK_COUNT_BAG_FURNITURE_VAULT)
        if name and name ~= "" then return name end
    end
    return NCollections.L("item_locator.furniture_vault")
end

local function GetHouseStorageName(bagId)
    local collectibleId = GetCollectibleForBag and Number(GetCollectibleForBag(bagId)) or 0
    local name = ""
    if collectibleId > 0 then
        name = GetCollectibleNickname and tostring(GetCollectibleNickname(collectibleId) or "") or ""
        if name == "" and GetCollectibleName then name = tostring(GetCollectibleName(collectibleId) or "") end
    end
    if name == "" and GetString then name = tostring(GetString("SI_BAG", bagId) or "") end
    return name ~= "" and name or NCollections.L("item_locator.house_storage")
end

local function RequestPrioritySave()
    if not GetAddOnManager then return end
    local manager = GetAddOnManager()
    if manager and manager.RequestAddOnSavedVariablesPrioritySave then
        manager:RequestAddOnSavedVariablesPrioritySave(NCollections.name or "NCollections")
    end
end

local function EnsureSchema()
    if savedVariables.v ~= C.VERSION then
        savedVariables.v = C.VERSION
        savedVariables.e = false
        savedVariables.c = {}
        savedVariables.p = {}
        savedVariables.k = { t = 0, p = "" }
        savedVariables.m = { t = 0, p = "" }
        savedVariables.f = { t = 0, p = "" }
        savedVariables.h = {}
        savedVariables.x = {}
        return
    end
    savedVariables.e = savedVariables.e == true
    if type(savedVariables.c) ~= "table" then savedVariables.c = {} end
    if type(savedVariables.p) ~= "table" then savedVariables.p = {} end
    if type(savedVariables.k) ~= "table" then savedVariables.k = { t = 0, p = "" } end
    savedVariables.k.t = Number(savedVariables.k.t)
    if type(savedVariables.k.p) ~= "string" then savedVariables.k.p = "" end
    if type(savedVariables.m) ~= "table" then savedVariables.m = { t = 0, p = "" } end
    savedVariables.m.t = Number(savedVariables.m.t)
    if type(savedVariables.m.p) ~= "string" then savedVariables.m.p = "" end
    if type(savedVariables.f) ~= "table" then savedVariables.f = { t = 0, p = "" } end
    savedVariables.f.t = Number(savedVariables.f.t)
    if type(savedVariables.f.p) ~= "string" then savedVariables.f.p = "" end
    if type(savedVariables.h) ~= "table" then savedVariables.h = {} end
    for bagId, record in pairs(savedVariables.h) do
        if type(record) ~= "table" then
            savedVariables.h[bagId] = nil
        else
            record.t = Number(record.t)
            if type(record.p) ~= "string" then record.p = "" end
        end
    end
    if type(savedVariables.x) ~= "table" then savedVariables.x = {} end
end

local function BuildBagLists()
    Clear(TRACKED_BAGS)
    Clear(BANK_BAGS)
    if BAG_BACKPACK ~= nil then TRACKED_BAGS[BAG_BACKPACK] = "b" end
    if BAG_WORN ~= nil then TRACKED_BAGS[BAG_WORN] = "w" end
    if BAG_VIRTUAL ~= nil then TRACKED_BAGS[BAG_VIRTUAL] = "m" end
    if BAG_BANK ~= nil then
        TRACKED_BAGS[BAG_BANK] = "k"
        BANK_BAGS[#BANK_BAGS + 1] = BAG_BANK
    end
    if BAG_SUBSCRIBER_BANK ~= nil then
        TRACKED_BAGS[BAG_SUBSCRIBER_BANK] = "k"
        BANK_BAGS[#BANK_BAGS + 1] = BAG_SUBSCRIBER_BANK
    end
    if BAG_FURNITURE_VAULT ~= nil then TRACKED_BAGS[BAG_FURNITURE_VAULT] = "f" end
    if BAG_HOUSE_BANK_ONE ~= nil and BAG_HOUSE_BANK_TEN ~= nil then
        for bagId = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do TRACKED_BAGS[bagId] = "h" end
    end
end

local function AddIdentityPart(value)
    identityParts[#identityParts + 1] = tostring(value or 0)
end

local function BuildVariantIdentity(itemLink, flags)
    Clear(identityParts)
    local itemType, specializedItemType = 0, 0
    if GetItemLinkItemType then itemType, specializedItemType = GetItemLinkItemType(itemLink) end
    local hasSet, setId = false, 0
    if GetItemLinkSetInfo then
        local setResult, _, _, _, _, resultSetId = GetItemLinkSetInfo(itemLink, false)
        hasSet, setId = setResult == true, Number(resultSetId)
    end
    local recipeListIndex, recipeIndex = 0, 0
    if GetItemLinkGrantedRecipeIndices then
        recipeListIndex, recipeIndex = GetItemLinkGrantedRecipeIndices(itemLink)
    end

    AddIdentityPart(SafeNumber(GetItemLinkItemId, itemLink))
    AddIdentityPart(itemType)
    AddIdentityPart(specializedItemType)
    AddIdentityPart(SafeNumber(GetItemLinkDisplayQuality, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkRequiredLevel, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkRequiredChampionPoints, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkTraitType, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkDefaultEnchantId, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkAppliedEnchantId, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkFinalEnchantId, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkItemStyle, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkOutfitStyleId, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkEquipType, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkArmorType, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkWeaponType, itemLink))
    AddIdentityPart(hasSet and setId or 0)
    AddIdentityPart(SafeNumber(GetItemLinkCombinationId, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkFurnitureDataId, itemLink))
    AddIdentityPart(recipeListIndex)
    AddIdentityPart(recipeIndex)
    AddIdentityPart(SafeBoolean(IsItemLinkCrafted, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkBindType, itemLink))
    AddIdentityPart(SafeBoolean(IsItemLinkBound, itemLink))
    AddIdentityPart(SafeBoolean(IsItemLinkStolen, itemLink))
    AddIdentityPart(SafeNumber(GetItemLinkActorCategory, itemLink))
    AddIdentityPart(flags)
    AddIdentityPart(GetItemLinkName and GetItemLinkName(itemLink) or "")
    if ITEMTYPE_MASTER_WRIT and itemType == ITEMTYPE_MASTER_WRIT and GenerateMasterWritBaseText then
        AddIdentityPart(GenerateMasterWritBaseText(itemLink))
    end
    return table.concat(identityParts, "\31")
end

local function HashIdentity(identity)
    local hashA, hashB = 0, 0
    for index = 1, #identity do
        local byte = string.byte(identity, index)
        hashA = (hashA * 131 + byte) % 16777213
        hashB = (hashB * 257 + byte) % 16777199
    end
    return (hashA * 16777216) + hashB
end

local function GetSlotFlags(bagId, slotIndex, itemLink)
    local bindType = SafeNumber(GetItemBindType, bagId, slotIndex)
    local isBound = SafeBoolean(IsItemBound, bagId, slotIndex)
    local isStolen = SafeBoolean(IsItemLinkStolen, itemLink)
    return (bindType * 4) + isBound + (isStolen * 2)
end

local function CatalogIdMatches(catalogId, identity)
    local packed = savedVariables.c[catalogId]
    local itemLink, flags = Codec.UnpackVariant(packed, codecFields)
    return itemLink and BuildVariantIdentity(itemLink, flags) == identity
end

local function FindCatalogId(identity)
    local entry = catalogHashToIds[HashIdentity(identity)]
    if type(entry) == "number" then
        return CatalogIdMatches(entry, identity) and entry or nil
    elseif type(entry) == "table" then
        for index = 1, #entry do
            if CatalogIdMatches(entry[index], identity) then return entry[index] end
        end
    end
    return nil
end

local function AddCatalogLookup(identity, catalogId)
    local hash = HashIdentity(identity)
    local entry = catalogHashToIds[hash]
    if entry == nil then
        catalogHashToIds[hash] = catalogId
    elseif type(entry) == "number" then
        catalogHashToIds[hash] = { entry, catalogId }
    else
        entry[#entry + 1] = catalogId
    end
end

local function RebuildCatalogLookup()
    Clear(catalogHashToIds)
    local catalog = savedVariables and savedVariables.c or nil
    if not catalog then return end

    for catalogId = 1, #catalog do
        local itemLink, flags = Codec.UnpackVariant(catalog[catalogId], codecFields)
        if itemLink then
            local identity = BuildVariantIdentity(itemLink, flags)
            if not FindCatalogId(identity) then AddCatalogLookup(identity, catalogId) end
        end
    end
    catalogLookupReady = true
end

local function GetOrCreateCatalogId(bagId, slotIndex, itemLink)
    if not catalogLookupReady then RebuildCatalogLookup() end
    local flags = GetSlotFlags(bagId, slotIndex, itemLink)
    local identity = BuildVariantIdentity(itemLink, flags)
    local catalogId = FindCatalogId(identity)
    if catalogId then return catalogId end

    local packed = Codec.PackVariant(itemLink, flags, codecBuffer, codecFields)
    if not packed then return nil end
    local catalog = savedVariables.c
    catalogId = #catalog + 1
    catalog[catalogId] = packed
    AddCatalogLookup(identity, catalogId)
    return catalogId
end

local function GetCharacterRecord()
    local characterKey = GetCurrentCharacterKey()
    local record = savedVariables.p[characterKey]
    if type(record) ~= "table" then
        record = { n = GetCurrentCharacterName(), t = 0, b = "", w = "" }
        savedVariables.p[characterKey] = record
    end
    record.n = GetCurrentCharacterName()
    if type(record.b) ~= "string" then record.b = "" end
    if type(record.w) ~= "string" then record.w = "" end
    record.t = Number(record.t)
    return record
end

local function GetHouseBankRecord(bagId)
    local record = savedVariables.h[bagId]
    if type(record) ~= "table" then
        record = { t = 0, p = "" }
        savedVariables.h[bagId] = record
    end
    record.t = Number(record.t)
    if type(record.p) ~= "string" then record.p = "" end
    return record
end

local function AdjustCount(location, catalogId, delta)
    if not catalogId or delta == 0 then return end
    local counts = aggregates[location]
    local nextCount = (counts[catalogId] or 0) + delta
    counts[catalogId] = nextCount > 0 and nextCount or nil
end

local function ClearBagCache(bagId)
    if slotIds[bagId] then Clear(slotIds[bagId]) end
    if slotCounts[bagId] then Clear(slotCounts[bagId]) end
end

local function ReadSlot(bagId, slotIndex)
    local itemLink = GetItemLink and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT) or ""
    if itemLink == "" then return nil, 0 end
    local count = GetSlotStackSize and Number(GetSlotStackSize(bagId, slotIndex)) or 1
    if count <= 0 then return nil, 0 end
    return GetOrCreateCatalogId(bagId, slotIndex, itemLink), count
end

local function ScanBagInto(bagId, location)
    ClearBagCache(bagId)
    local ids = slotIds[bagId] or {}
    local counts = slotCounts[bagId] or {}
    slotIds[bagId], slotCounts[bagId] = ids, counts
    if BAG_VIRTUAL ~= nil and bagId == BAG_VIRTUAL
        and type(GetNextVirtualBagSlotId) == "function" then
        local slotIndex = GetNextVirtualBagSlotId(nil)
        while slotIndex ~= nil do
            local catalogId, count = ReadSlot(bagId, slotIndex)
            if catalogId then
                ids[slotIndex] = catalogId
                counts[slotIndex] = count
                AdjustCount(location, catalogId, count)
            end
            slotIndex = GetNextVirtualBagSlotId(slotIndex)
        end
        return
    end
    if BAG_FURNITURE_VAULT ~= nil and bagId == BAG_FURNITURE_VAULT
        and type(GetNextFurnitureVaultSlotId) == "function" then
        local slotIndex = GetNextFurnitureVaultSlotId(nil)
        while slotIndex ~= nil do
            local catalogId, count = ReadSlot(bagId, slotIndex)
            if catalogId then
                ids[slotIndex] = catalogId
                counts[slotIndex] = count
                AdjustCount(location, catalogId, count)
            end
            slotIndex = GetNextFurnitureVaultSlotId(slotIndex)
        end
        return
    end

    local size = GetBagSize and Number(GetBagSize(bagId)) or 0
    for slotIndex = 0, size - 1 do
        local catalogId, count = ReadSlot(bagId, slotIndex)
        if catalogId then
            ids[slotIndex] = catalogId
            counts[slotIndex] = count
            AdjustCount(location, catalogId, count)
        end
    end
end

local function EncodeLocation(location)
    return Codec.EncodeCounts(aggregates[location], codecBuffer, codecIds)
end

local function NotifyDataChanged()
    if type(ItemLocator.RefreshBrowser) == "function" then ItemLocator.RefreshBrowser() end
end

local function FlushDirty()
    if not savedVariables then return end
    if dirty.b or dirty.w then
        local record = GetCharacterRecord()
        if dirty.b then record.b = EncodeLocation("b") end
        if dirty.w then record.w = EncodeLocation("w") end
    end
    if dirty.k then savedVariables.k.p = EncodeLocation("k") end
    if dirty.m then savedVariables.m.p = EncodeLocation("m") end
    if dirty.f then savedVariables.f.p = EncodeLocation("f") end
    if dirty.h and houseBankBag then GetHouseBankRecord(houseBankBag).p = EncodeLocation("h") end
    dirty.b, dirty.w, dirty.k, dirty.m, dirty.f, dirty.h = false, false, false, false, false, false
    NotifyDataChanged()
end

local function CancelUpdate(name)
    if EVENT_MANAGER and EVENT_MANAGER.UnregisterForUpdate then
        EVENT_MANAGER:UnregisterForUpdate(name)
    end
end

local function OnFlushUpdate()
    CancelUpdate(C.FLUSH_UPDATE)
    FlushDirty()
end

local function ScheduleFlush()
    if not EVENT_MANAGER or not EVENT_MANAGER.RegisterForUpdate then
        FlushDirty()
        return
    end
    CancelUpdate(C.FLUSH_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(C.FLUSH_UPDATE, C.FLUSH_DELAY_MS, OnFlushUpdate)
end

local function ValidatePayloads(liveIds)
    Clear(liveIds)
    for _, record in pairs(savedVariables.p) do
        if type(record) == "table" then
            for _, key in ipairs({ "b", "w" }) do
                local decoded = Codec.DecodeCounts(record[key] or "", decodeScratch)
                if not decoded then unavailableData = true return false end
                for catalogId in pairs(decoded) do liveIds[catalogId] = true end
            end
        end
    end
    local decoded = Codec.DecodeCounts(savedVariables.k.p or "", decodeScratch)
    if not decoded then unavailableData = true return false end
    for catalogId in pairs(decoded) do liveIds[catalogId] = true end
    decoded = Codec.DecodeCounts(savedVariables.m.p or "", decodeScratch)
    if not decoded then unavailableData = true return false end
    for catalogId in pairs(decoded) do liveIds[catalogId] = true end
    decoded = Codec.DecodeCounts(savedVariables.f.p or "", decodeScratch)
    if not decoded then unavailableData = true return false end
    for catalogId in pairs(decoded) do liveIds[catalogId] = true end
    for _, record in pairs(savedVariables.h) do
        decoded = Codec.DecodeCounts(record.p or "", decodeScratch)
        if not decoded then unavailableData = true return false end
        for catalogId in pairs(decoded) do liveIds[catalogId] = true end
    end
    return true
end

local function RemapMap(values, remap)
    Clear(remapScratch)
    for oldId, count in pairs(values) do
        local newId = remap[oldId]
        if newId then remapScratch[newId] = (remapScratch[newId] or 0) + count end
    end
    Clear(values)
    for newId, count in pairs(remapScratch) do values[newId] = count end
end

local function RemapRuntime(remap)
    RemapMap(aggregates.b, remap)
    RemapMap(aggregates.w, remap)
    RemapMap(aggregates.k, remap)
    RemapMap(aggregates.m, remap)
    RemapMap(aggregates.f, remap)
    RemapMap(aggregates.h, remap)
    for _, ids in pairs(slotIds) do
        for slotIndex, oldId in pairs(ids) do ids[slotIndex] = remap[oldId] end
    end
end

CompactCatalog = function()
    local liveIds = {}
    if not ValidatePayloads(liveIds) then return false end

    local identityRecords = {}
    local oldIdentity = {}
    for oldId in pairs(liveIds) do
        local packed = savedVariables.c[oldId]
        local itemLink, flags = Codec.UnpackVariant(packed, codecFields)
        if not itemLink then return false end
        local identity = BuildVariantIdentity(itemLink, flags)
        oldIdentity[oldId] = identity
        local existing = identityRecords[identity]
        if not existing or packed < existing then identityRecords[identity] = packed end
    end

    local identities = {}
    for identity in pairs(identityRecords) do identities[#identities + 1] = identity end
    table.sort(identities)
    local newCatalog, identityToNew, remap = {}, {}, {}
    for newId = 1, #identities do
        local identity = identities[newId]
        newCatalog[newId] = identityRecords[identity]
        identityToNew[identity] = newId
    end
    for oldId, identity in pairs(oldIdentity) do remap[oldId] = identityToNew[identity] end

    for _, record in pairs(savedVariables.p) do
        if type(record) == "table" then
            record.b = Codec.RemapCounts(record.b or "", remap, decodeScratch, remapScratch) or ""
            record.w = Codec.RemapCounts(record.w or "", remap, decodeScratch, remapScratch) or ""
        end
    end
    savedVariables.k.p = Codec.RemapCounts(savedVariables.k.p or "", remap, decodeScratch, remapScratch) or ""
    savedVariables.m.p = Codec.RemapCounts(savedVariables.m.p or "", remap, decodeScratch, remapScratch) or ""
    savedVariables.f.p = Codec.RemapCounts(savedVariables.f.p or "", remap, decodeScratch, remapScratch) or ""
    for _, record in pairs(savedVariables.h) do
        record.p = Codec.RemapCounts(record.p or "", remap, decodeScratch, remapScratch) or ""
    end
    savedVariables.c = newCatalog
    RemapRuntime(remap)
    catalogLookupReady = false
    RebuildCatalogLookup()
    return true
end

local function GetScanTimeMilliseconds()
    if GetGameTimeMilliseconds then return Number(GetGameTimeMilliseconds()) end
    if GetFrameTimeMilliseconds then return Number(GetFrameTimeMilliseconds()) end
    return 0
end

local function IsStorageScanAccessible(job)
    if job.location == "k" then return bankOpen end
    if job.location == "f" then return furnitureVaultOpen end
    return houseBankBag == job.targetBag
end

local function StorageScanContainsBag(job, bagId)
    for index = 1, #job.bags do
        if job.bags[index] == bagId then return true end
    end
    return false
end

local function BeginNextStorageBag(job)
    job.bagIndex = job.bagIndex + 1
    local bagId = job.bags[job.bagIndex]
    if bagId == nil then
        job.currentBag = nil
        return false
    end
    job.currentBag = bagId
    job.slotRefs[bagId] = {}
    job.slotCounts[bagId] = {}
    job.lastSparseSlot = nil
    job.nextSlot = 0
    job.sparse = BAG_FURNITURE_VAULT ~= nil and bagId == BAG_FURNITURE_VAULT
        and type(GetNextFurnitureVaultSlotId) == "function"
    job.bagSize = job.sparse and 0 or (GetBagSize and Number(GetBagSize(bagId)) or 0)
    return true
end

local function GetNextStorageSlot(job)
    while job.currentBag or BeginNextStorageBag(job) do
        local bagId = job.currentBag
        if job.sparse then
            local slotIndex = GetNextFurnitureVaultSlotId(job.lastSparseSlot)
            if slotIndex ~= nil then
                job.lastSparseSlot = slotIndex
                return bagId, slotIndex
            end
        elseif job.nextSlot < job.bagSize then
            local slotIndex = job.nextSlot
            job.nextSlot = slotIndex + 1
            return bagId, slotIndex
        end
        job.currentBag = nil
    end
    return nil
end

local function ProcessStorageSlot(job, bagId, slotIndex)
    local itemLink = GetItemLink and GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT) or ""
    if itemLink == "" then return end
    local count = GetSlotStackSize and Number(GetSlotStackSize(bagId, slotIndex)) or 1
    if count <= 0 then return end
    local flags = GetSlotFlags(bagId, slotIndex, itemLink)
    local identity = BuildVariantIdentity(itemLink, flags)
    local ref = job.identityToRef[identity]
    if not ref then
        ref = #job.identities + 1
        job.identities[ref] = identity
        job.identityToRef[identity] = ref
        job.catalogIds[ref] = FindCatalogId(identity)
        if not job.catalogIds[ref] then
            job.packed[ref] = Codec.PackVariant(itemLink, flags, codecBuffer, codecFields)
        end
        if not job.catalogIds[ref] and not job.packed[ref] then
            job.identities[ref] = nil
            job.identityToRef[identity] = nil
            return
        end
    end
    job.refCounts[ref] = (job.refCounts[ref] or 0) + count
    job.slotRefs[bagId][slotIndex] = ref
    job.slotCounts[bagId][slotIndex] = count
end

local function CommitStorageScan(job)
    local refToCatalogId = {}
    for ref = 1, #job.identities do
        local catalogId = job.catalogIds[ref]
        if not catalogId then catalogId = FindCatalogId(job.identities[ref]) end
        if not catalogId then
            catalogId = #savedVariables.c + 1
            savedVariables.c[catalogId] = job.packed[ref]
            AddCatalogLookup(job.identities[ref], catalogId)
        end
        refToCatalogId[ref] = catalogId
    end

    local location = job.location
    Clear(aggregates[location])
    for ref, count in pairs(job.refCounts) do
        aggregates[location][refToCatalogId[ref]] = count
    end
    for index = 1, #job.bags do
        local bagId = job.bags[index]
        local refs = job.slotRefs[bagId]
        for slotIndex, ref in pairs(refs) do refs[slotIndex] = refToCatalogId[ref] end
        ClearBagCache(bagId)
        slotIds[bagId] = refs
        slotCounts[bagId] = job.slotCounts[bagId]
    end

    local timestamp = GetTimeStamp and Number(GetTimeStamp()) or 0
    if location == "k" then
        savedVariables.k.t = timestamp
        savedVariables.k.p = EncodeLocation("k")
        dirty.k = false
        bankCacheReady = bankOpen
    elseif location == "f" then
        savedVariables.f.t = timestamp
        savedVariables.f.p = EncodeLocation("f")
        dirty.f = false
        furnitureVaultCacheReady = furnitureVaultOpen
    else
        local record = GetHouseBankRecord(job.targetBag)
        record.t = timestamp
        record.p = EncodeLocation("h")
        dirty.h = false
        houseBankCacheReady = houseBankBag == job.targetBag
    end
    RequestPrioritySave()
    NotifyDataChanged()
end

CancelStorageScan = function()
    CancelUpdate(C.STORAGE_SCAN_UPDATE)
    storageScanJob = nil
end

local function OnStorageScanUpdate()
    local job = storageScanJob
    if not job or not savedVariables or not savedVariables.e or not IsStorageScanAccessible(job) then
        CancelStorageScan()
        return
    end

    local startedAt = GetScanTimeMilliseconds()
    local processed = 0
    while processed < C.SCAN_MAX_SLOTS_PER_FRAME do
        local bagId, slotIndex = GetNextStorageSlot(job)
        if not bagId then
            local location, targetBag, needsRescan = job.location, job.targetBag, job.needsRescan
            CancelStorageScan()
            if needsRescan and ((location == "k" and bankOpen) or (location == "f" and furnitureVaultOpen)
                or (location == "h" and houseBankBag == targetBag)) then
                StartStorageScan(location, targetBag)
            else
                CommitStorageScan(job)
            end
            return
        end
        ProcessStorageSlot(job, bagId, slotIndex)
        processed = processed + 1
        if GetScanTimeMilliseconds() - startedAt >= C.SCAN_BUDGET_MS then return end
    end
end

StartStorageScan = function(location, targetBag)
    CancelStorageScan()
    if not savedVariables or not savedVariables.e then return end
    if not catalogLookupReady then RebuildCatalogLookup() end
    local bags = {}
    if location == "k" then
        for index = 1, #BANK_BAGS do bags[index] = BANK_BAGS[index] end
    elseif targetBag ~= nil then
        bags[1] = targetBag
    end
    if #bags == 0 then return end
    storageScanJob = {
        location = location,
        targetBag = targetBag,
        bags = bags,
        bagIndex = 0,
        identities = {},
        identityToRef = {},
        catalogIds = {},
        packed = {},
        refCounts = {},
        slotRefs = {},
        slotCounts = {},
    }
    EVENT_MANAGER:RegisterForUpdate(C.STORAGE_SCAN_UPDATE, 0, OnStorageScanUpdate)
end

local function ScanCharacter()
    if not savedVariables or not savedVariables.e then return end
    Clear(aggregates.b)
    Clear(aggregates.w)
    if BAG_BACKPACK ~= nil then ScanBagInto(BAG_BACKPACK, "b") end
    if BAG_WORN ~= nil then ScanBagInto(BAG_WORN, "w") end
    local record = GetCharacterRecord()
    record.t = GetTimeStamp and Number(GetTimeStamp()) or 0
    record.b = EncodeLocation("b")
    record.w = EncodeLocation("w")
    dirty.b, dirty.w = false, false
    RequestPrioritySave()
    NotifyDataChanged()
end

local function ScanCraftBag()
    if not savedVariables or not savedVariables.e or BAG_VIRTUAL == nil then return end
    Clear(aggregates.m)
    ScanBagInto(BAG_VIRTUAL, "m")
    savedVariables.m.t = GetTimeStamp and Number(GetTimeStamp()) or 0
    savedVariables.m.p = EncodeLocation("m")
    dirty.m = false
    RequestPrioritySave()
    NotifyDataChanged()
end

local function ScanBank()
    if not savedVariables or not savedVariables.e or not bankOpen then return end
    StartStorageScan("k")
end

local function ScanFurnitureVault()
    if not savedVariables or not savedVariables.e or not furnitureVaultOpen
        or BAG_FURNITURE_VAULT == nil then return end
    StartStorageScan("f", BAG_FURNITURE_VAULT)
end

local function ScanHouseBank()
    if not savedVariables or not savedVariables.e or not houseBankBag then return end
    StartStorageScan("h", houseBankBag)
end

local function OnInventorySlotUpdate(_, bagId, slotIndex)
    if not savedVariables.e then return end
    local location = TRACKED_BAGS[bagId]
    if not location or (location == "k" and not bankOpen)
        or (location == "f" and not furnitureVaultOpen)
        or (location == "h" and bagId ~= houseBankBag) then return end
    if storageScanJob and storageScanJob.location == location
        and StorageScanContainsBag(storageScanJob, bagId) then
        storageScanJob.needsRescan = true
        return
    end
    if (location == "k" and not bankCacheReady)
        or (location == "f" and not furnitureVaultCacheReady)
        or (location == "h" and not houseBankCacheReady) then return end

    local ids = slotIds[bagId] or {}
    local counts = slotCounts[bagId] or {}
    slotIds[bagId], slotCounts[bagId] = ids, counts
    local oldId, oldCount = ids[slotIndex], counts[slotIndex] or 0
    if oldId then AdjustCount(location, oldId, -oldCount) end

    local newId, newCount = ReadSlot(bagId, slotIndex)
    ids[slotIndex], counts[slotIndex] = newId, newId and newCount or nil
    if newId then AdjustCount(location, newId, newCount) end
    dirty[location] = true
    ScheduleFlush()
end

local function OnFullScanUpdate()
    CancelUpdate(C.FULL_SCAN_UPDATE)
    ScanCharacter()
    ScanCraftBag()
    if bankOpen then ScanBank() end
    if furnitureVaultOpen then ScanFurnitureVault() end
    if houseBankBag then ScanHouseBank() end
end

local function OnInventoryFullUpdate()
    if not savedVariables.e then return end
    CancelUpdate(C.FULL_SCAN_UPDATE)
    EVENT_MANAGER:RegisterForUpdate(C.FULL_SCAN_UPDATE, C.RESCAN_DELAY_MS, OnFullScanUpdate)
end

local function OnBankScanUpdate()
    CancelUpdate(C.BANK_SCAN_UPDATE)
    if bankOpen then
        ScanBank()
    elseif furnitureVaultOpen then
        ScanFurnitureVault()
    elseif houseBankBag then
        ScanHouseBank()
    end
end

local function IsFurnitureVaultBag(bagId)
    if bagId == nil then return false end
    if type(IsFurnitureVault) == "function" then return IsFurnitureVault(bagId) == true end
    return BAG_FURNITURE_VAULT ~= nil and bagId == BAG_FURNITURE_VAULT
end

local function IsHouseStorageBag(bagId)
    if bagId == nil or IsFurnitureVaultBag(bagId) then return false end
    if type(IsHouseBankBag) == "function" then return IsHouseBankBag(bagId) == true end
    return BAG_HOUSE_BANK_ONE ~= nil and BAG_HOUSE_BANK_TEN ~= nil
        and bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN
end

local function SetOpenBankBag(bankBag)
    bankOpen = bankBag ~= nil and (bankBag == BAG_BANK or bankBag == BAG_SUBSCRIBER_BANK)
    furnitureVaultOpen = IsFurnitureVaultBag(bankBag)
    houseBankBag = IsHouseStorageBag(bankBag) and bankBag or nil
    bankCacheReady, furnitureVaultCacheReady, houseBankCacheReady = false, false, false
end

local function RefreshOpenBankBag()
    if IsBankOpen and IsBankOpen() then
        SetOpenBankBag(GetBankingBag and GetBankingBag() or BAG_BANK)
    else
        bankOpen, furnitureVaultOpen = false, false
        houseBankBag = nil
        bankCacheReady, furnitureVaultCacheReady, houseBankCacheReady = false, false, false
    end
end

local function OnOpenBank(_, bankBag)
    if not savedVariables.e then return end
    CancelStorageScan()
    if dirty.k or dirty.f or dirty.h then FlushDirty() end
    SetOpenBankBag(bankBag)
    CancelUpdate(C.BANK_SCAN_UPDATE)
    if bankOpen or furnitureVaultOpen or houseBankBag then
        EVENT_MANAGER:RegisterForUpdate(C.BANK_SCAN_UPDATE, C.RESCAN_DELAY_MS, OnBankScanUpdate)
    end
end

local function OnCloseBank()
    if not savedVariables.e then return end
    CancelUpdate(C.BANK_SCAN_UPDATE)
    CancelStorageScan()
    if dirty.k or dirty.f or dirty.h then FlushDirty() end
    Clear(aggregates.k)
    Clear(aggregates.f)
    Clear(aggregates.h)
    for index = 1, #BANK_BAGS do ClearBagCache(BANK_BAGS[index]) end
    if BAG_FURNITURE_VAULT ~= nil then ClearBagCache(BAG_FURNITURE_VAULT) end
    if houseBankBag then ClearBagCache(houseBankBag) end
    bankOpen, furnitureVaultOpen = false, false
    houseBankBag = nil
    bankCacheReady, furnitureVaultCacheReady, houseBankCacheReady = false, false, false
end

local function OnPlayerDeactivated()
    CancelStorageScan()
    CancelUpdate(C.FLUSH_UPDATE)
    if dirty.b or dirty.w or dirty.k or dirty.m or dirty.f or dirty.h then FlushDirty() end
    CompactCatalog()
end

local function RegisterEvents()
    if eventsRegistered or not EVENT_MANAGER then return end
    EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
    EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_INVENTORY_FULL_UPDATE, OnInventoryFullUpdate)
    EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_OPEN_BANK, OnOpenBank)
    EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_CLOSE_BANK, OnCloseBank)
    EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)
    eventsRegistered = true
end

local function UnregisterEvents()
    if not eventsRegistered or not EVENT_MANAGER then return end
    EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_INVENTORY_FULL_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_OPEN_BANK)
    EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_CLOSE_BANK)
    EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_PLAYER_DEACTIVATED)
    CancelUpdate(C.FLUSH_UPDATE)
    CancelUpdate(C.FULL_SCAN_UPDATE)
    CancelUpdate(C.BANK_SCAN_UPDATE)
    CancelStorageScan()
    eventsRegistered = false
end

local function ClearRuntime()
    CancelStorageScan()
    Clear(aggregates.b)
    Clear(aggregates.w)
    Clear(aggregates.k)
    Clear(aggregates.m)
    Clear(aggregates.f)
    Clear(aggregates.h)
    for bagId in pairs(slotIds) do ClearBagCache(bagId) end
    Clear(slotIds)
    Clear(slotCounts)
    Clear(catalogHashToIds)
    catalogLookupReady = false
    dirty.b, dirty.w, dirty.k, dirty.m, dirty.f, dirty.h = false, false, false, false, false, false
    bankOpen, furnitureVaultOpen = false, false
    houseBankBag = nil
    bankCacheReady, furnitureVaultCacheReady, houseBankCacheReady = false, false, false
end

local function DecodeLocation(encoded, callback)
    local counts = Codec.DecodeCounts(encoded or "", decodeScratch)
    if not counts then unavailableData = true return false end
    for catalogId, count in pairs(counts) do callback(catalogId, count) end
    return true
end

local function FormatItemName(itemLink)
    local name = GetItemLinkName and GetItemLinkName(itemLink) or ""
    if zo_strformat and SI_TOOLTIP_ITEM_NAME then name = zo_strformat(SI_TOOLTIP_ITEM_NAME, name) end
    return name
end

local function BuildGamepadCategoryIdsByLabel()
    local result = {}
    if not GetString then return result end
    local maximum = tonumber(GAMEPAD_ITEM_CATEGORY_COMPANION_WAIST) or 55
    for categoryId = 0, maximum do
        local label = GetString("SI_GAMEPADITEMCATEGORY", categoryId)
        if type(label) == "string" and label ~= "" then result[label] = categoryId end
    end
    return result
end

local function GetItemCategory(itemLink, categoryIdsByLabel)
    local itemType = 0
    local specializedItemType = 0
    if GetItemLinkItemType then itemType, specializedItemType = GetItemLinkItemType(itemLink) end
    local itemData = {
        itemType = itemType,
        specializedItemType = specializedItemType,
        equipType = SafeNumber(GetItemLinkEquipType, itemLink),
        armorType = SafeNumber(GetItemLinkArmorType, itemLink),
        weaponType = SafeNumber(GetItemLinkWeaponType, itemLink),
        actorCategory = SafeNumber(GetItemLinkActorCategory, itemLink),
        itemLink = itemLink,
    }
    local category
    if ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription then
        category = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
    elseif GetString then
        category = GetString("SI_ITEMTYPE", itemType)
    else
        category = NCollections.L("common.other")
    end
    local categoryId = categoryIdsByLabel[category]
    return category, categoryId ~= nil and ("g" .. tostring(categoryId)) or ("i" .. tostring(itemType))
end

local function AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, characterName, kind, scannedAt)
    if count <= 0 then return end
    local record = recordsById[catalogId]
    if not record then
        local itemLink, flags = Codec.UnpackVariant(savedVariables.c[catalogId], codecFields)
        if not itemLink then unavailableData = true return end
        local name = FormatItemName(itemLink)
        local category, categoryKey = GetItemCategory(itemLink, categoryIdsByLabel)
        record = {
            id = catalogId,
            link = itemLink,
            flags = flags,
            name = name,
            needle = NCollections.Util.Lower(name),
            category = category,
            categoryKey = categoryKey,
            quality = SafeNumber(GetItemLinkDisplayQuality, itemLink),
            total = 0,
            locations = {},
        }
        recordsById[catalogId] = record
    end
    record.total = record.total + count
    local locations = record.locations
    locations[#locations + 1] = characterName
    locations[#locations + 1] = kind
    locations[#locations + 1] = count
    locations[#locations + 1] = Number(scannedAt)
end

function ItemLocator.InitializeSavedVariables()
    savedVariables = ZO_SavedVars:NewAccountWide(
        NCollections.Settings.SAVED_VARIABLES_NAME, 1, nil, defaults, nil, C.NAMESPACE
    )
    EnsureSchema()
end

function ItemLocator.Initialize()
    if initialized then return end
    initialized = true
    BuildBagLists()
    if savedVariables.e then
        RegisterEvents()
        RefreshOpenBankBag()
        ScanCharacter()
        ScanCraftBag()
        if bankOpen then ScanBank() end
        if furnitureVaultOpen then ScanFurnitureVault() end
        if houseBankBag then ScanHouseBank() end
    end
end

function ItemLocator.IsEnabled()
    return savedVariables and savedVariables.e == true
end

function ItemLocator.SetEnabled(value)
    if not savedVariables then return end
    value = value == true
    if savedVariables.e == value then return end
    savedVariables.e = value
    if value then
        BuildBagLists()
        RegisterEvents()
        RefreshOpenBankBag()
        ScanCharacter()
        ScanCraftBag()
        if bankOpen then ScanBank() end
        if furnitureVaultOpen then ScanFurnitureVault() end
        if houseBankBag then ScanHouseBank() end
    else
        CancelUpdate(C.FLUSH_UPDATE)
        if dirty.b or dirty.w or dirty.k or dirty.m or dirty.f or dirty.h then FlushDirty() end
        UnregisterEvents()
        CompactCatalog()
        ClearRuntime()
        NotifyDataChanged()
    end
    RequestPrioritySave()
end

function ItemLocator.ClearData()
    if not savedVariables then return end
    savedVariables.c = {}
    savedVariables.p = {}
    savedVariables.k = { t = 0, p = "" }
    savedVariables.m = { t = 0, p = "" }
    savedVariables.f = { t = 0, p = "" }
    savedVariables.h = {}
    ClearRuntime()
    if savedVariables.e then
        BuildBagLists()
        RegisterEvents()
        RefreshOpenBankBag()
        ScanCharacter()
        ScanCraftBag()
        if bankOpen then ScanBank() end
        if furnitureVaultOpen then ScanFurnitureVault() end
        if houseBankBag then ScanHouseBank() end
    end
    RequestPrioritySave()
    NotifyDataChanged()
end

function ItemLocator.HasData()
    if not savedVariables then return false end
    if type(savedVariables.k) == "table" and savedVariables.k.p ~= "" then return true end
    if type(savedVariables.m) == "table" and savedVariables.m.p ~= "" then return true end
    if type(savedVariables.f) == "table" and savedVariables.f.p ~= "" then return true end
    for _, record in pairs(savedVariables.h) do
        if type(record) == "table" and record.p ~= "" then return true end
    end
    for _, record in pairs(savedVariables.p) do
        if type(record) == "table" and (record.b ~= "" or record.w ~= "") then return true end
    end
    return false
end

function ItemLocator.HasUnavailableData()
    return unavailableData
end

function ItemLocator.GetMarketPriceData(itemLink)
    local priceApi = rawget(_G, "TSCPriceDataAPI")
    if type(priceApi) ~= "table" or type(priceApi.GetItemData) ~= "function" then return nil end
    local succeeded, itemData = pcall(priceApi.GetItemData, priceApi, itemLink)
    if not succeeded or itemData == priceApi.LOADING or type(itemData) ~= "table" then return nil end
    local minimum = tonumber(itemData.commonMin or itemData.legacyMin)
    local average = tonumber(itemData.avgPrice or itemData.legacyAvg)
    local maximum = tonumber(itemData.commonMax or itemData.legacyMax)
    if not minimum or not average or not maximum then return nil end
    return minimum, average, maximum
end

function ItemLocator.IsCategoryVisible(categoryKey)
    return not savedVariables or savedVariables.x[categoryKey] ~= true
end

function ItemLocator.SetCategoryVisible(categoryKey, visible)
    if not savedVariables or type(categoryKey) ~= "string" or categoryKey == "" then return end
    if visible == false then
        savedVariables.x[categoryKey] = true
    else
        savedVariables.x[categoryKey] = nil
    end
    RequestPrioritySave()
    NotifyDataChanged()
end

function ItemLocator.ResetCategoryVisibility()
    if not savedVariables then return end
    savedVariables.x = {}
    RequestPrioritySave()
    NotifyDataChanged()
end

local function FormatRosterDate(timestamp)
    if not GetDateElementsFromTimestamp then
        return GetDateStringFromTimestamp and GetDateStringFromTimestamp(timestamp) or tostring(timestamp)
    end
    local year, month, day = GetDateElementsFromTimestamp(timestamp)
    local monthName = tostring(month or "")
    local monthIndex = 0
    for abbreviation in string.gmatch(NCollections.L("item_locator.date_month_abbreviations"), "[^|]+") do
        monthIndex = monthIndex + 1
        if monthIndex == month then
            monthName = abbreviation
            break
        end
    end
    return NCollections.L("item_locator.roster_date", string.format("%02d", day or 0), monthName, tostring(year or ""))
end

local function AddTooltipScanLine(lines, name, timestamp)
    timestamp = Number(timestamp)
    if timestamp > 0 then
        lines[#lines + 1] = NCollections.L("item_locator.roster_scanned", name, FormatRosterDate(timestamp))
    else
        lines[#lines + 1] = NCollections.L("item_locator.roster_never_scanned", name)
    end
end

function ItemLocator.GetRosterTooltip()
    local lines = { NCollections.L("ui.navigation.item_locator_tooltip"), "" }
    AddTooltipScanLine(lines, GetBankName(), savedVariables and savedVariables.k and savedVariables.k.t)
    AddTooltipScanLine(lines, GetCraftBagName(), savedVariables and savedVariables.m and savedVariables.m.t)

    local storage, storageSeen = {}, {}
    if BAG_HOUSE_BANK_ONE ~= nil and BAG_HOUSE_BANK_TEN ~= nil then
        for bagId = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
            local collectibleId = GetCollectibleForBag and Number(GetCollectibleForBag(bagId)) or 0
            local unlocked = collectibleId > 0
                and (type(IsCollectibleUnlocked) ~= "function" or IsCollectibleUnlocked(collectibleId))
            if unlocked then
                local record = savedVariables and savedVariables.h and savedVariables.h[bagId]
                storage[#storage + 1] = { b = bagId, n = GetHouseStorageName(bagId), t = record and record.t or 0 }
                storageSeen[bagId] = true
            end
        end
    end
    if savedVariables and savedVariables.h then
        for bagId, record in pairs(savedVariables.h) do
            local numericBagId = Number(bagId)
            if numericBagId > 0 and not storageSeen[numericBagId] and type(record) == "table" then
                storage[#storage + 1] = {
                    b = numericBagId,
                    n = GetHouseStorageName(numericBagId),
                    t = record.t,
                }
            end
        end
    end
    table.sort(storage, function(left, right)
        local leftName, rightName = NCollections.Util.Lower(left.n), NCollections.Util.Lower(right.n)
        return leftName == rightName and left.b < right.b or leftName < rightName
    end)
    for index = 1, #storage do
        local entry = storage[index]
        AddTooltipScanLine(lines, entry.n, entry.t)
    end
    AddTooltipScanLine(lines, GetFurnitureVaultName(), savedVariables and savedVariables.f and savedVariables.f.t)
    lines[#lines + 1] = ""

    local roster, seen = {}, {}
    if GetNumCharacters and GetCharacterInfo then
        for index = 1, Number(GetNumCharacters()) do
            local name, _, _, _, _, _, characterId = GetCharacterInfo(index)
            local key = characterId and tostring(characterId) or GetCharacterName(name)
            if key ~= "" then
                roster[#roster + 1] = { k = key, n = GetCharacterName(name), t = 0 }
                seen[key] = roster[#roster]
            end
        end
    end
    if savedVariables then
        for key, record in pairs(savedVariables.p) do
            if type(record) == "table" then
                local entry = seen[tostring(key)]
                if not entry then
                    entry = { k = tostring(key), n = GetCharacterName(record.n), t = 0 }
                    roster[#roster + 1] = entry
                    seen[tostring(key)] = entry
                end
                entry.n = GetCharacterName(record.n and record.n ~= "" and record.n or entry.n)
                entry.t = Number(record.t)
            end
        end
    end
    local currentKey = GetCurrentCharacterKey()
    if currentKey ~= "" and not seen[currentKey] then
        roster[#roster + 1] = { k = currentKey, n = GetCurrentCharacterName(), t = 0 }
    end
    table.sort(roster, function(left, right)
        return NCollections.Util.Lower(left.n) < NCollections.Util.Lower(right.n)
    end)
    for index = 1, #roster do
        local entry = roster[index]
        AddTooltipScanLine(lines, entry.n, entry.t)
    end
    return table.concat(lines, "\n")
end

function ItemLocator.BuildBrowserRecords(output)
    output = output or {}
    Clear(output)
    if not savedVariables then return output end
    unavailableData = false
    local recordsById = {}
    local categoryIdsByLabel = BuildGamepadCategoryIdsByLabel()
    local characters = {}
    for key, record in pairs(savedVariables.p) do
        if type(record) == "table" then
            characters[#characters + 1] = { k = key, r = record, n = GetCharacterName(record.n) }
        end
    end
    table.sort(characters, function(left, right)
        return NCollections.Util.Lower(left.n) < NCollections.Util.Lower(right.n)
    end)
    for index = 1, #characters do
        local character = characters[index]
        DecodeLocation(character.r.b, function(catalogId, count)
            AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, character.n, "b", character.r.t)
        end)
        DecodeLocation(character.r.w, function(catalogId, count)
            AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, character.n, "w", character.r.t)
        end)
    end
    DecodeLocation(savedVariables.k.p, function(catalogId, count)
        AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, "", "k", savedVariables.k.t)
    end)
    DecodeLocation(savedVariables.m.p, function(catalogId, count)
        AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, "", "m", savedVariables.m.t)
    end)
    DecodeLocation(savedVariables.f.p, function(catalogId, count)
        AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, "", "f", savedVariables.f.t)
    end)
    local houseRecords = {}
    for bagId, record in pairs(savedVariables.h) do
        if type(record) == "table" then houseRecords[#houseRecords + 1] = { b = Number(bagId), r = record } end
    end
    table.sort(houseRecords, function(left, right) return left.b < right.b end)
    for index = 1, #houseRecords do
        local house = houseRecords[index]
        if house.b > 0 then
            local storageName = GetHouseStorageName(house.b)
            DecodeLocation(house.r.p, function(catalogId, count)
                AddBrowserLocation(recordsById, categoryIdsByLabel, catalogId, count, storageName, "h" .. tostring(house.b), house.r.t)
            end)
        end
    end
    for _, record in pairs(recordsById) do output[#output + 1] = record end
    table.sort(output, function(left, right)
        if left.category ~= right.category then return left.category < right.category end
        if left.name ~= right.name then return left.name < right.name end
        return left.id < right.id
    end)
    return output
end

function ItemLocator.BuildCategoryList(output)
    output = output or {}
    Clear(output)
    local records = ItemLocator.BuildBrowserRecords({})
    local seen = {}
    for index = 1, #records do
        local record = records[index]
        if not seen[record.categoryKey] then
            seen[record.categoryKey] = true
            output[#output + 1] = { key = record.categoryKey, label = record.category }
        end
    end
    table.sort(output, function(left, right)
        return NCollections.Util.Lower(left.label) < NCollections.Util.Lower(right.label)
    end)
    return output
end

function ItemLocator.Open()
    if type(ItemLocator.OpenBrowser) == "function" then ItemLocator.OpenBrowser() end
end

ItemLocator._CompactCatalog = CompactCatalog
ItemLocator._BuildVariantIdentity = BuildVariantIdentity
ItemLocator._FormatRosterDate = FormatRosterDate
ItemLocator.GetHouseStorageName = GetHouseStorageName
ItemLocator.GetFurnitureVaultName = GetFurnitureVaultName
ItemLocator.GetCraftBagName = GetCraftBagName
