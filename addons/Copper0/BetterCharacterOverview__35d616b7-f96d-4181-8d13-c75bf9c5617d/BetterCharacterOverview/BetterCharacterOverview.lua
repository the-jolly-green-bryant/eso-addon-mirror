--[[
Better Character Overview
Version 1.6.3
PS5 / Update 50 native-list architecture test.

This version registers two dedicated lists through GAMEPAD_INVENTORY:AddList:
  BCOCategory
  BCOItems

It does not replace ESO's categoryList, itemList, or craftBagList.

Commands:
  /bco
  /bcorescan
  /bcoclear
]]

BetterCharacterOverview = {}
local BCO = BetterCharacterOverview

BCO.name = "BetterCharacterOverview"
BCO.version = "1.6.3"
BCO.savedVarVersion = 2

BCO.CATEGORY_DESCRIPTOR = "bcoCategoryList"
BCO.ITEM_DESCRIPTOR = "bcoItemList"
BCO.NATIVE_CATEGORY_DESCRIPTOR = "categoryList"

BCO.defaults = {
    characters = {},
    shared = {
        bank = { items = {}, updated = 0 },
        storage = {},
        currencies = {
            bank = {},
            updated = 0,
        },
    },
    settings = {
        categoryIndex = 1,
    },
}

BCO.categories = {
    { key = "all", name = "ALL ITEMS" },
    { key = "currencies", name = "CURRENCIES" },
    { key = "supplies", name = "SUPPLIES" },
    { key = "slottable", name = "SLOTTABLE ITEMS" },
    { key = "furnishings", name = "FURNISHINGS" },
    { key = "companion", name = "COMPANION ITEMS" },
    { key = "quest", name = "QUEST ITEMS" },
    { key = "weapons", name = "WEAPONS" },
    { key = "apparel", name = "APPAREL" },
    { key = "materials", name = "MATERIALS" },
    { key = "misc", name = "MISCELLANEOUS" },
}

BCO.categoryIcons = {
    -- All Items is a BCO-only category, so it keeps ESO's general inventory bag icon.
    all = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_all.dds",
    currencies = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_currencies.dds",

    -- These paths match ESO's native gamepad Inventory category list.
    supplies = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_all.dds",
    materials = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_materials.dds",
    slottable = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_quickslot.dds",
    furnishings = "EsoUI/Art/Crafting/Gamepad/gp_crafting_menuIcon_furnishings.dds",
    companion = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_companionItems.dds",
    quest = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_quest.dds",
    weapons = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_weapons.dds",
    apparel = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_apparel.dds",

    -- Miscellaneous is a BCO category rather than a native root category,
    -- but ESO provides this matching inventory icon.
    misc = "EsoUI/Art/Inventory/Gamepad/gp_inventory_icon_miscellaneous.dds",
}

BCO.active = false
BCO.installed = false
BCO.installAttempts = 0
BCO.bankOpen = false
BCO.activeBankBag = nil
BCO.scanPending = false
BCO.indexToken = 0
BCO.indexReady = false
BCO.aggregatedItems = {}
BCO.filteredItems = {}
BCO.selectedCategoryKey = "all"
BCO.selectedCategoryName = "ALL ITEMS"
-- ESO's private gamepad inventory action modes currently use 1 for the
-- category/read-only state. Keeping BCO in that state prevents deferred native
-- updates from rebuilding Use/Equip actions while a BCO list is active.
BCO.READ_ONLY_ACTION_MODE = 1
BCO.secureHookState = {}
BCO.searchHookMethodName = nil
BCO.thirdTabEntry = nil
BCO.sceneWatcherInstalled = false
BCO.sceneInstallGeneration = 0
BCO.sceneResumeGeneration = 0
BCO.resumeBCOAfterSceneShow = false
BCO.sceneResumeScheduled = false
BCO.lastInstallStatus = "Waiting for Inventory to open"
BCO.refreshingHeader = false
BCO.headerRefreshGeneration = 0
BCO.tooltipRefreshGeneration = 0
BCO.currencyTooltipGeneration = 0
BCO.indexRebuildGeneration = 0
BCO.searchText = ""
BCO.searchRefreshGeneration = 0
BCO.locationViewExpanded = false
BCO.expandedLocationItemKey = nil
BCO.previewingFurnishingItemLink = nil
BCO.previewingFurnishingItemKey = nil
BCO.previewingFurnishingBagId = nil
BCO.previewingFurnishingSlotIndex = nil
BCO.furnishingPreviewConfirmed = false
BCO.lastFurnishingPreviewPath = "none"
BCO.lastFurnishingPreviewError = nil
BCO.lastSelectedItemData = nil
BCO.firstItemEntryData = nil
BCO.itemSelectionGeneration = 0
BCO.previewSelectionGeneration = 0
BCO.furnishingPreviewSettleMS = 90
BCO.collapsedLocationRows = 2
BCO.collapsedLocationBodyRows = 3

-- Square cycles the source used by the read-only account inventory list.
-- Character Items includes both backpack and equipped locations.
-- Storage includes housing storage chests/coffers and the Furnishing Vault.
BCO.inventoryFilters = {
    {
        key = "all",
        keybindName = "All",
    },
    {
        key = "bank",
        keybindName = "Banked",
    },
    {
        key = "backpack",
        keybindName = "Characters",
    },
    {
        key = "storage",
        keybindName = "Storage",
    },
}
BCO.inventoryFilterIndex = 1

local function Msg(text)
    if d then
        d(string.format(
            "|c66CCFF[Better Character Overview]|r %s",
            tostring(text)
        ))
    end
end

local function Lower(text)
    text = tostring(text or "")
    return zo_strlower and zo_strlower(text) or string.lower(text)
end


local function Trim(text)
    text = tostring(text or "")
    return text:match("^%s*(.-)%s*$") or ""
end

-- ESO item-name APIs can return localization grammar markers such as ^p and
-- ^n. Native inventory screens resolve those markers through the tooltip item
-- name formatter before putting the text into a list entry.
local function FormatItemName(name)
    name = Trim(name)

    if name == "" then
        return "Unknown Item"
    end

    if zo_strformat then
        if SI_TOOLTIP_ITEM_NAME then
            local ok, formattedName = pcall(
                zo_strformat,
                SI_TOOLTIP_ITEM_NAME,
                name
            )

            if ok
                and type(formattedName) == "string"
                and formattedName ~= ""
            then
                return formattedName
            end
        end

        -- This also resolves grammar markers on older API builds where the
        -- tooltip formatter constant is not exposed at addon load time.
        local ok, formattedName = pcall(
            zo_strformat,
            "<<1>>",
            name
        )

        if ok
            and type(formattedName) == "string"
            and formattedName ~= ""
        then
            return formattedName
        end
    end

    return name
end

local function ReadControlText(control)
    if not control or type(control.GetText) ~= "function" then
        return nil
    end

    local ok, value = pcall(control.GetText, control)

    if not ok or type(value) ~= "string" then
        return nil
    end

    return Trim(value)
end

local function ControlName(control)
    if not control or type(control.GetName) ~= "function" then
        return ""
    end

    local ok, value = pcall(control.GetName, control)

    if not ok then
        return ""
    end

    return Lower(value)
end

local function SearchPlaceholder()
    if GetString and SI_GAMEPAD_SEARCH then
        local ok, value = pcall(
            GetString,
            SI_GAMEPAD_SEARCH
        )

        if ok and value then
            return Lower(Trim(value))
        end
    end

    return "search"
end

local function FindTextControl(root)
    if not root then
        return nil
    end

    local bestControl = nil
    local bestScore = -1
    local visited = {}

    local function Visit(control, depth)
        if not control
            or visited[control]
            or depth > 6
        then
            return
        end

        visited[control] = true

        local text = ReadControlText(control)
        local name = ControlName(control)
        local score = 0

        if type(control.GetType) == "function"
            and CT_EDITBOX
        then
            local ok, controlType = pcall(
                control.GetType,
                control
            )

            if ok and controlType == CT_EDITBOX then
                score = score + 200
            end
        end

        if name:find("search", 1, true)
            or name:find("edit", 1, true)
            or name:find("input", 1, true)
        then
            score = score + 75
        end

        if text ~= nil then
            score = score + 10

            if score > bestScore then
                bestScore = score
                bestControl = control
            end
        end

        if type(control.GetNumChildren) == "function"
            and type(control.GetChild) == "function"
        then
            local ok, childCount = pcall(
                control.GetNumChildren,
                control
            )

            if ok and type(childCount) == "number" then
                for childIndex = 1, childCount do
                    local childOk, child = pcall(
                        control.GetChild,
                        control,
                        childIndex
                    )

                    if childOk then
                        Visit(child, depth + 1)
                    end
                end
            end
        end
    end

    Visit(root, 0)
    return bestControl
end

local function Now()
    return GetTimeStamp and GetTimeStamp() or 0
end

local function CharacterId()
    return GetCurrentCharacterId and tostring(GetCurrentCharacterId()) or nil
end

local function CharacterName()
    local name = GetUnitName and GetUnitName("player") or "Unknown Character"
    return zo_strformat and zo_strformat("<<1>>", name) or name
end


-- Account-wide currencies are intentionally excluded. Better Character
-- Overview only aggregates currencies that can differ by character, plus
-- their banked amounts.
local CHARACTER_CURRENCY_DEFINITIONS = {
    {
        constantName = "CURT_MONEY",
        fallbackName = "GOLD",
    },
    {
        constantName = "CURT_ALLIANCE_POINTS",
        fallbackName = "ALLIANCE POINTS",
    },
    {
        constantName = "CURT_TELVAR_STONES",
        fallbackName = "TEL VAR STONES",
    },
    {
        constantName = "CURT_WRIT_VOUCHERS",
        fallbackName = "WRIT VOUCHERS",
    },
}

local function GetCharacterCurrencyDefinitions()
    local definitions = {}

    for index = 1, #CHARACTER_CURRENCY_DEFINITIONS do
        local source = CHARACTER_CURRENCY_DEFINITIONS[index]
        local currencyType = _G[source.constantName]

        if currencyType ~= nil then
            definitions[#definitions + 1] = {
                currencyType = currencyType,
                fallbackName = source.fallbackName,
            }
        end
    end

    return definitions
end

local function ReadCurrencyAmount(
    currencyType,
    currencyLocation
)
    if type(GetCurrencyAmount) ~= "function"
        or currencyType == nil
        or currencyLocation == nil
    then
        return nil
    end

    local ok, amount = pcall(
        GetCurrencyAmount,
        currencyType,
        currencyLocation
    )

    if ok and type(amount) == "number" then
        return amount
    end

    return nil
end

local function ReadBankCurrencyAmount(currencyType)
    local amount = ReadCurrencyAmount(
        currencyType,
        CURRENCY_LOCATION_BANK
    )

    if amount ~= nil then
        return amount
    end

    if type(GetBankedCurrencyAmount) == "function" then
        local ok, bankedAmount = pcall(
            GetBankedCurrencyAmount,
            currencyType
        )

        if ok and type(bankedAmount) == "number" then
            return bankedAmount
        end
    end

    if CURT_MONEY
        and currencyType == CURT_MONEY
        and type(GetBankedMoney) == "function"
    then
        local ok, bankedMoney = pcall(GetBankedMoney)

        if ok and type(bankedMoney) == "number" then
            return bankedMoney
        end
    end

    if CURT_TELVAR_STONES
        and currencyType == CURT_TELVAR_STONES
        and type(GetBankedTelvarStones) == "function"
    then
        local ok, bankedTelvar = pcall(
            GetBankedTelvarStones
        )

        if ok and type(bankedTelvar) == "number" then
            return bankedTelvar
        end
    end

    return 0
end

local function ScanCharacterCurrencies()
    local currencies = {}
    local definitions =
        GetCharacterCurrencyDefinitions()

    for index = 1, #definitions do
        local currencyType =
            definitions[index].currencyType
        local amount = ReadCurrencyAmount(
            currencyType,
            CURRENCY_LOCATION_CHARACTER
        )

        currencies[tostring(currencyType)] =
            amount or 0
    end

    return currencies
end

local function ScanBankCurrencies()
    local currencies = {}
    local definitions =
        GetCharacterCurrencyDefinitions()

    for index = 1, #definitions do
        local currencyType =
            definitions[index].currencyType

        currencies[tostring(currencyType)] =
            ReadBankCurrencyAmount(currencyType)
    end

    return currencies
end

local function SetName(itemLink)
    if not GetItemLinkSetInfo then
        return ""
    end

    local hasSet, name = GetItemLinkSetInfo(itemLink, false)
    return hasSet and (name or "") or ""
end

local function IterateBag(bagId, callback)
    if ZO_IterateBagSlots then
        for slotIndex in ZO_IterateBagSlots(bagId) do
            callback(slotIndex)
        end
        return
    end

    local size = GetBagSize and GetBagSize(bagId) or 0
    for slotIndex = 0, size - 1 do
        callback(slotIndex)
    end
end

local function PackFilterTypes(...)
    local packed = {}
    local count = select("#", ...)

    for index = 1, count do
        local value = select(index, ...)

        if value ~= nil
            and value ~= 0
            and not ZO_IsElementInNumericallyIndexedTable(
                packed,
                value
            )
        then
            packed[#packed + 1] = value
        end
    end

    return packed
end

local function GetFilterData(itemLink, bagId, slotIndex)
    if itemLink
        and itemLink ~= ""
        and GetItemLinkFilterTypeInfo
    then
        local filterData = PackFilterTypes(
            GetItemLinkFilterTypeInfo(itemLink)
        )

        if #filterData > 0 then
            return filterData
        end
    end

    if bagId ~= nil
        and slotIndex ~= nil
        and GetItemFilterTypeInfo
    then
        return PackFilterTypes(
            GetItemFilterTypeInfo(bagId, slotIndex)
        )
    end

    return {}
end

local function GetLinkDisplayQuality(
    itemLink,
    savedQuality
)
    if itemLink and itemLink ~= "" then
        if GetItemLinkDisplayQuality then
            local quality =
                GetItemLinkDisplayQuality(itemLink)

            if quality ~= nil then
                return quality
            end
        end

        if GetItemLinkQuality then
            local quality =
                GetItemLinkQuality(itemLink)

            if quality ~= nil then
                return quality
            end
        end
    end

    return savedQuality
        or ITEM_DISPLAY_QUALITY_NORMAL
end

local function ReadItem(bagId, slotIndex)
    local count = GetSlotStackSize(bagId, slotIndex) or 0
    if count <= 0 then
        return nil
    end

    local itemLink = GetItemLink(
        bagId,
        slotIndex,
        LINK_STYLE_DEFAULT
    ) or ""

    if itemLink == "" then
        return nil
    end

    local itemType, specializedItemType = 0, 0
    if GetItemLinkItemType then
        itemType, specializedItemType =
            GetItemLinkItemType(itemLink)
    end

    return {
        itemLink = itemLink,
        itemId = GetItemLinkItemId and
            GetItemLinkItemId(itemLink) or 0,
        name = FormatItemName(
            GetItemLinkName and
                GetItemLinkName(itemLink) or
                GetItemName(bagId, slotIndex) or
                "Unknown Item"
        ),
        count = count,
        icon = GetItemLinkIcon and
            GetItemLinkIcon(itemLink) or "",
        quality = GetLinkDisplayQuality(
            itemLink,
            ITEM_DISPLAY_QUALITY_NORMAL
        ),
        itemType = itemType or 0,
        specializedItemType = specializedItemType or 0,
        equipType = GetItemLinkEquipType and
            GetItemLinkEquipType(itemLink) or
            EQUIP_TYPE_INVALID,
        filterData = GetFilterData(
            itemLink,
            bagId,
            slotIndex
        ),
        setName = SetName(itemLink),
    }
end

local function ScanBag(bagId)
    local items = {}

    IterateBag(bagId, function(slotIndex)
        local item = ReadItem(bagId, slotIndex)
        if item then
            items[#items + 1] = item
        end
    end)

    return items
end

local function Append(target, source)
    for index = 1, #(source or {}) do
        target[#target + 1] = source[index]
    end
end


local HOUSE_BANK_CONSTANT_NAMES = {
    "BAG_HOUSE_BANK_ONE",
    "BAG_HOUSE_BANK_TWO",
    "BAG_HOUSE_BANK_THREE",
    "BAG_HOUSE_BANK_FOUR",
    "BAG_HOUSE_BANK_FIVE",
    "BAG_HOUSE_BANK_SIX",
    "BAG_HOUSE_BANK_SEVEN",
    "BAG_HOUSE_BANK_EIGHT",
    "BAG_HOUSE_BANK_NINE",
    "BAG_HOUSE_BANK_TEN",
}

local HOUSE_BANK_ORDINALS = {}

for index = 1, #HOUSE_BANK_CONSTANT_NAMES do
    local bagId = _G[HOUSE_BANK_CONSTANT_NAMES[index]]

    if bagId ~= nil then
        HOUSE_BANK_ORDINALS[bagId] = index
    end
end

local function IsFurnitureVaultBag(bagId)
    if bagId == nil then
        return false
    end

    if BAG_FURNITURE_VAULT
        and bagId == BAG_FURNITURE_VAULT
    then
        return true
    end

    if type(IsFurnitureVault) == "function" then
        local ok, result = pcall(
            IsFurnitureVault,
            bagId
        )

        if ok then
            return result == true
        end
    end

    return false
end

local function IsHousingStorageBag(bagId)
    if bagId == nil then
        return false
    end

    if IsFurnitureVaultBag(bagId) then
        return true
    end

    if type(IsHouseBankBag) == "function" then
        local ok, result = pcall(
            IsHouseBankBag,
            bagId
        )

        if ok and result == true then
            return true
        end
    end

    return HOUSE_BANK_ORDINALS[bagId] ~= nil
end

local function TryGetStorageCollectibleId(
    getCollectibleId,
    bagId
)
    if type(getCollectibleId) ~= "function" then
        return 0
    end

    local ok, collectibleId = pcall(
        getCollectibleId,
        bagId
    )

    if ok
        and collectibleId
        and collectibleId ~= 0
    then
        return collectibleId
    end

    return 0
end

local function GetStorageCollectibleId(bagId)
    local collectibleId =
        TryGetStorageCollectibleId(
            GetCollectibleForBag,
            bagId
        )

    if collectibleId ~= 0 then
        return collectibleId
    end

    return TryGetStorageCollectibleId(
        GetCollectibleForHouseBankBag,
        bagId
    )
end

local function FormatStorageName(name)
    name = Trim(name)

    if name == "" then
        return ""
    end

    if zo_strformat then
        return zo_strformat("<<1>>", name)
    end

    return name
end

local function GetStorageBagName(bagId)
    local collectibleId =
        GetStorageCollectibleId(bagId)

    if collectibleId ~= 0 then
        if type(GetCollectibleNickname) == "function" then
            local ok, nickname = pcall(
                GetCollectibleNickname,
                collectibleId
            )

            nickname = ok
                and FormatStorageName(nickname)
                or ""

            if nickname ~= "" then
                return nickname, collectibleId
            end
        end

        if type(GetCollectibleName) == "function" then
            local ok, collectibleName = pcall(
                GetCollectibleName,
                collectibleId
            )

            collectibleName = ok
                and FormatStorageName(collectibleName)
                or ""

            if collectibleName ~= "" then
                return collectibleName, collectibleId
            end
        end
    end

    if IsFurnitureVaultBag(bagId) then
        return "Furnishing Vault", collectibleId
    end

    local ordinal = HOUSE_BANK_ORDINALS[bagId]

    if ordinal then
        return string.format(
            "Housing Storage %d",
            ordinal
        ), collectibleId
    end

    return "Housing Storage", collectibleId
end

function BCO:ScanBank()
    local items = ScanBag(BAG_BANK)

    if BAG_SUBSCRIBER_BANK then
        Append(items, ScanBag(BAG_SUBSCRIBER_BANK))
    end

    self.savedVars.shared.bank = {
        items = items,
        updated = Now(),
    }
end

function BCO:ScanStorageBag(bagId)
    if not IsHousingStorageBag(bagId) then
        return false
    end

    local name, collectibleId =
        GetStorageBagName(bagId)
    local key = tostring(bagId)

    self.savedVars.shared.storage =
        self.savedVars.shared.storage or {}

    self.savedVars.shared.storage[key] = {
        bagId = bagId,
        name = name,
        collectibleId = collectibleId,
        isFurnitureVault =
            IsFurnitureVaultBag(bagId),
        items = ScanBag(bagId),
        updated = Now(),
    }

    return true
end

function BCO:ScanOpenBankLocation()
    if not self.bankOpen then
        return false
    end

    local bagId = self.activeBankBag

    if bagId == nil
        and type(GetBankingBag) == "function"
    then
        local ok, currentBagId = pcall(GetBankingBag)

        if ok then
            bagId = currentBagId
            self.activeBankBag = currentBagId
        end
    end

    if bagId == BAG_BANK then
        self:ScanBank()
        return true
    elseif IsHousingStorageBag(bagId) then
        return self:ScanStorageBag(bagId)
    end

    return false
end

function BCO:ScheduleIndexRebuild(delayMs)
    self.indexRebuildGeneration =
        self.indexRebuildGeneration + 1

    local generation = self.indexRebuildGeneration

    zo_callLater(function()
        if generation ~= BCO.indexRebuildGeneration then
            return
        end

        BCO:StartIndexBuild(function()
            if BCO.active then
                BCO:RefreshActiveBCOList(true)
            end
        end)
    end, delayMs or 0)
end

function BCO:ScanSharedCurrencies()
    self.savedVars.shared =
        self.savedVars.shared or {}

    self.savedVars.shared.currencies = {
        bank = ScanBankCurrencies(),
        updated = Now(),
    }
end

function BCO:ScanCurrentCurrencies()
    local id = CharacterId()

    if not id then
        return false
    end

    local character =
        self.savedVars.characters[id]

    if type(character) ~= "table" then
        character = {
            id = id,
            name = CharacterName(),
            backpack = {},
            worn = {},
            updated = 0,
        }

        self.savedVars.characters[id] =
            character
    end

    character.id = id
    character.name = CharacterName()
    character.currencies =
        ScanCharacterCurrencies()
    character.currencyUpdated = Now()

    self:ScanSharedCurrencies()
    return true
end

function BCO:ScanCurrentCharacter(rebuildIndex)
    local id = CharacterId()
    if not id then
        return false
    end

    local updated = Now()

    self.savedVars.characters[id] = {
        id = id,
        name = CharacterName(),
        backpack = ScanBag(BAG_BACKPACK),
        worn = ScanBag(BAG_WORN),
        currencies = ScanCharacterCurrencies(),
        currencyUpdated = updated,
        updated = updated,
    }

    self:ScanSharedCurrencies()

    if self.bankOpen then
        self:ScanOpenBankLocation()
    end

    if rebuildIndex ~= false then
        self:ScheduleIndexRebuild(50)
    end

    return true
end

function BCO:ScheduleScan()
    if self.scanPending then
        return
    end

    self.scanPending = true

    zo_callLater(function()
        BCO.scanPending = false
        BCO:ScanCurrentCharacter()
    end, 350)
end

local MATERIAL_TYPES = {}
local QUICKslot_TYPES = {}
local FURNISHING_TYPES = {}
local QUEST_TYPES = {}

local function AddType(target, constantName)
    local value = _G[constantName]
    if value ~= nil then
        target[value] = true
    end
end

for _, name in ipairs({
    "ITEMTYPE_BLACKSMITHING_MATERIAL",
    "ITEMTYPE_BLACKSMITHING_RAW_MATERIAL",
    "ITEMTYPE_CLOTHIER_MATERIAL",
    "ITEMTYPE_CLOTHIER_RAW_MATERIAL",
    "ITEMTYPE_WOODWORKING_MATERIAL",
    "ITEMTYPE_WOODWORKING_RAW_MATERIAL",
    "ITEMTYPE_JEWELRYCRAFTING_MATERIAL",
    "ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL",
    "ITEMTYPE_STYLE_MATERIAL",
    "ITEMTYPE_ARMOR_TRAIT",
    "ITEMTYPE_WEAPON_TRAIT",
    "ITEMTYPE_JEWELRY_TRAIT",
    "ITEMTYPE_REAGENT",
    "ITEMTYPE_POTION_BASE",
    "ITEMTYPE_POISON_BASE",
    "ITEMTYPE_ENCHANTING_RUNE_ASPECT",
    "ITEMTYPE_ENCHANTING_RUNE_ESSENCE",
    "ITEMTYPE_ENCHANTING_RUNE_POTENCY",
    "ITEMTYPE_INGREDIENT",
    "ITEMTYPE_RAW_MATERIAL",
}) do
    AddType(MATERIAL_TYPES, name)
end

-- Fallback for old snapshots created before filterType was stored.
for _, name in ipairs({
    "ITEMTYPE_POTION",
    "ITEMTYPE_POISON",
    "ITEMTYPE_FOOD",
    "ITEMTYPE_DRINK",
    "ITEMTYPE_SIEGE",
    "ITEMTYPE_AVA_REPAIR",
    "ITEMTYPE_REPAIR",
    "ITEMTYPE_CROWN_REPAIR",
}) do
    AddType(QUICKslot_TYPES, name)
end

AddType(FURNISHING_TYPES, "ITEMTYPE_FURNISHING")
AddType(QUEST_TYPES, "ITEMTYPE_QUEST_ITEM")

local function IsWeapon(item)
    return _G.ITEMTYPE_WEAPON ~= nil
        and item.itemType == ITEMTYPE_WEAPON
end

local function IsApparel(item)
    return (
        _G.ITEMTYPE_ARMOR ~= nil
        and item.itemType == ITEMTYPE_ARMOR
    ) or (
        _G.ITEMTYPE_COSTUME ~= nil
        and item.itemType == ITEMTYPE_COSTUME
    ) or (
        _G.ITEMTYPE_DISGUISE ~= nil
        and item.itemType == ITEMTYPE_DISGUISE
    )
end

local function IsFilterType(item, filterTypeName)
    local expected = _G[filterTypeName]
    if expected == nil then
        return false
    end

    local filterData = item.filterData or {}

    for index = 1, #filterData do
        if filterData[index] == expected then
            return true
        end
    end

    return false
end

local function IsMaterial(item)
    return IsFilterType(
        item,
        "ITEMFILTERTYPE_CRAFTING"
    ) or MATERIAL_TYPES[item.itemType] == true
end

local function IsSlottable(item)
    return IsFilterType(
        item,
        "ITEMFILTERTYPE_QUICKSLOT"
    ) or QUICKslot_TYPES[item.itemType] == true
end

local function IsFurnishing(item)
    return IsFilterType(
        item,
        "ITEMFILTERTYPE_FURNISHING"
    ) or FURNISHING_TYPES[item.itemType] == true
end

local function IsQuest(item)
    return IsFilterType(
        item,
        "ITEMFILTERTYPE_QUEST"
    ) or QUEST_TYPES[item.itemType] == true
end

local function IsEquipment(item)
    return IsWeapon(item) or IsApparel(item)
end

local function IsCompanion(item)
    return IsFilterType(
        item,
        "ITEMFILTERTYPE_COMPANION"
    )
end

local function IsSupplies(item)
    return item.equipType == EQUIP_TYPE_INVALID
        and not IsSlottable(item)
        and not IsMaterial(item)
        and not IsFurnishing(item)
        and not IsCompanion(item)
        and not IsQuest(item)
end

local function IsSpecificCategory(item)
    return IsSupplies(item)
        or IsMaterial(item)
        or IsSlottable(item)
        or IsFurnishing(item)
        or IsCompanion(item)
        or IsQuest(item)
        or IsEquipment(item)
end

local function MatchesCategory(item, key)
    if key == "currencies" then
        return false
    elseif key == "all" then
        return true
    elseif key == "supplies" then
        return IsSupplies(item)
    elseif key == "slottable" then
        return IsSlottable(item)
    elseif key == "furnishings" then
        return IsFurnishing(item)
    elseif key == "companion" then
        return IsCompanion(item)
    elseif key == "quest" then
        return IsQuest(item)
    elseif key == "weapons" then
        return IsWeapon(item)
    elseif key == "apparel" then
        return IsApparel(item)
    elseif key == "materials" then
        return IsMaterial(item)
    elseif key == "misc" then
        return not IsSpecificCategory(item)
    end

    return false
end

function BCO:CollectSources()
    local sources = {}
    local usedNames = {}

    local function AddSource(
        items,
        preferredName,
        kind,
        updated,
        uniqueSuffix
    )
        preferredName = Trim(preferredName)

        if preferredName == "" then
            preferredName = "Unknown Location"
        end

        local name = preferredName
        local normalizedName = Lower(name)

        if usedNames[normalizedName] then
            local suffix = uniqueSuffix
                or tostring(#sources + 1)

            name = string.format(
                "%s (%s)",
                preferredName,
                suffix
            )
            normalizedName = Lower(name)

            local duplicateIndex = 2

            while usedNames[normalizedName] do
                name = string.format(
                    "%s (%s-%d)",
                    preferredName,
                    suffix,
                    duplicateIndex
                )
                normalizedName = Lower(name)
                duplicateIndex = duplicateIndex + 1
            end
        end

        usedNames[normalizedName] = true
        sources[#sources + 1] = {
            items = items or {},
            name = name,
            kind = kind,
            updated = updated or 0,
        }
    end

    for _, character in pairs(
        self.savedVars.characters
    ) do
        local characterName = character.name
            or "Unknown Character"

        AddSource(
            character.backpack,
            characterName,
            "backpack",
            character.updated
        )

        AddSource(
            character.worn,
            characterName .. " (Equipped)",
            "equipped",
            character.updated
        )
    end

    local bank = self.savedVars.shared.bank or {}

    AddSource(
        bank.items,
        "Bank",
        "bank",
        bank.updated
    )

    local storageRows = {}

    for storageKey, storage in pairs(
        self.savedVars.shared.storage or {}
    ) do
        if type(storage) == "table" then
            local bagId = storage.bagId
                or tonumber(storageKey)
            local ordinal = bagId
                and HOUSE_BANK_ORDINALS[bagId]
            local fallbackName

            if storage.isFurnitureVault
                or IsFurnitureVaultBag(bagId)
            then
                fallbackName = "Furnishing Vault"
            elseif ordinal then
                fallbackName = string.format(
                    "Housing Storage %d",
                    ordinal
                )
            else
                fallbackName = "Housing Storage"
            end

            storageRows[#storageRows + 1] = {
                items = storage.items or {},
                name = storage.name or fallbackName,
                updated = storage.updated or 0,
                bagId = bagId,
                ordinal = ordinal,
                isFurnitureVault =
                    storage.isFurnitureVault == true
                    or IsFurnitureVaultBag(bagId),
            }
        end
    end

    table.sort(storageRows, function(left, right)
        if left.isFurnitureVault
            ~= right.isFurnitureVault
        then
            return not left.isFurnitureVault
        end

        if (left.ordinal or 999)
            ~= (right.ordinal or 999)
        then
            return (left.ordinal or 999)
                < (right.ordinal or 999)
        end

        if Lower(left.name) ~= Lower(right.name) then
            return Lower(left.name) < Lower(right.name)
        end

        return tostring(left.bagId or "")
            < tostring(right.bagId or "")
    end)

    for index = 1, #storageRows do
        local storage = storageRows[index]
        local suffix

        if storage.isFurnitureVault then
            suffix = "Vault"
        elseif storage.ordinal then
            suffix = string.format(
                "Storage %d",
                storage.ordinal
            )
        else
            suffix = string.format(
                "Storage %d",
                index
            )
        end

        AddSource(
            storage.items,
            storage.name,
            "storage",
            storage.updated,
            suffix
        )
    end

    return sources
end

function BCO:StartIndexBuild(onComplete)
    self.indexToken = self.indexToken + 1
    local token = self.indexToken

    local sources = self:CollectSources()
    local sourceIndex = 1
    local itemIndex = 1
    local aggregate = {}

    self.indexReady = false
    self.aggregatedItems = {}

    local function ProcessChunk()
        if token ~= BCO.indexToken then
            return
        end

        local processed = 0
        local maximum = 70

        while processed < maximum and sourceIndex <= #sources do
            local source = sources[sourceIndex]
            local snapshot = source.items[itemIndex]

            if snapshot then
                local key = snapshot.itemLink
                    or tostring(snapshot.itemId or 0)

                local item = aggregate[key]

                if not item then
                    local formattedName = FormatItemName(
                        snapshot.name or "Unknown Item"
                    )

                    item = {
                        key = key,
                        itemLink = snapshot.itemLink or "",
                        itemId = snapshot.itemId or 0,
                        name = formattedName,
                        normalizedName = Lower(formattedName),
                        icon = snapshot.icon or "",
                        quality = GetLinkDisplayQuality(
                            snapshot.itemLink,
                            snapshot.quality
                        ),
                        itemType = snapshot.itemType or 0,
                        specializedItemType =
                            snapshot.specializedItemType or 0,
                        equipType = snapshot.equipType or
                            EQUIP_TYPE_INVALID,
                        filterData = GetFilterData(
                            snapshot.itemLink,
                            nil,
                            nil
                        ),
                        setName = snapshot.setName or "",
                        totalCount = 0,
                        locations = {},
                        locationTimes = {},
                        locationKinds = {},
                    }

                    aggregate[key] = item
                end

                if #item.filterData == 0
                    and snapshot.filterData
                then
                    for filterIndex = 1, #snapshot.filterData do
                        local filterType =
                            snapshot.filterData[filterIndex]

                        if not ZO_IsElementInNumericallyIndexedTable(
                            item.filterData,
                            filterType
                        ) then
                            item.filterData[
                                #item.filterData + 1
                            ] = filterType
                        end
                    end
                end

                local count = snapshot.count or 1
                item.totalCount = item.totalCount + count
                item.locations[source.name] =
                    (item.locations[source.name] or 0) + count
                item.locationTimes[source.name] =
                    source.updated or 0
                item.locationKinds[source.name] =
                    source.kind or "backpack"

                itemIndex = itemIndex + 1
                processed = processed + 1
            else
                sourceIndex = sourceIndex + 1
                itemIndex = 1
            end
        end

        if sourceIndex <= #sources then
            zo_callLater(ProcessChunk, 0)
            return
        end

        BCO.aggregatedItems = aggregate
        BCO.indexReady = true

        if onComplete then
            onComplete()
        end
    end

    ProcessChunk()
end


function BCO:FindSearchTextControl()
    local inventory = GAMEPAD_INVENTORY

    if not inventory then
        return nil
    end

    local candidates = {
        inventory.searchEditBox,
        inventory.textSearchEditBox,
        inventory.textSearchHeaderEditBox,
    }

    local focus = inventory.textSearchHeaderFocus

    if type(focus) == "table" then
        candidates[#candidates + 1] =
            focus.editBox
        candidates[#candidates + 1] =
            focus.editBoxControl
        candidates[#candidates + 1] =
            focus.searchEditBox
        candidates[#candidates + 1] =
            focus.control
    end

    for index = 1, #candidates do
        local candidate = candidates[index]

        if candidate
            and type(candidate.GetText) == "function"
        then
            return candidate
        end
    end

    return FindTextControl(
        inventory.textSearchHeaderControl
    )
end

function BCO:ReadSearchText(callbackText)
    local text

    if type(callbackText) == "string" then
        text = Trim(callbackText)
    else
        text = ReadControlText(
            self:FindSearchTextControl()
        ) or ""
    end

    text = Lower(text)

    if text == SearchPlaceholder() then
        return ""
    end

    return text
end

local function ItemSearchText(item)
    if item.bcoSearchText then
        return item.bcoSearchText
    end

    local parts = {
        item.name or "",
        item.setName or "",
    }

    for locationName in pairs(
        item.locations or {}
    ) do
        parts[#parts + 1] = locationName
    end

    item.bcoSearchText = Lower(
        table.concat(parts, " ")
    )

    return item.bcoSearchText
end

local function ItemMatchesSearch(item, searchText)
    searchText = Trim(searchText)

    if searchText == "" then
        return true
    end

    local itemText = ItemSearchText(item)

    for token in searchText:gmatch("%S+") do
        if not itemText:find(token, 1, true) then
            return false
        end
    end

    return true
end

function BCO:GetInventoryFilter()
    return self.inventoryFilters[
        self.inventoryFilterIndex
    ] or self.inventoryFilters[1]
end

function BCO:GetInventoryFilterKey()
    local filter = self:GetInventoryFilter()
    return filter and filter.key or "all"
end

function BCO:GetInventoryFilterKeybindName()
    local filter = self:GetInventoryFilter()
    return filter and filter.keybindName or "All"
end

local function InferLocationKind(name)
    local lowered = Lower(name)

    if lowered == "bank" then
        return "bank"
    elseif lowered:sub(-11) == " (equipped)" then
        return "equipped"
    end

    return "backpack"
end

local function LocationMatchesInventoryFilter(
    locationKind,
    filterKey
)
    if filterKey == "all" then
        return true
    elseif filterKey == "bank" then
        return locationKind == "bank"
    elseif filterKey == "backpack" then
        return locationKind == "backpack"
            or locationKind == "equipped"
    elseif filterKey == "storage" then
        return locationKind == "storage"
    end

    return true
end

local function BuildInventoryFilteredItem(
    item,
    filterKey
)
    if filterKey == "all" then
        return item
    end

    local locations = {}
    local locationTimes = {}
    local locationKinds = {}
    local totalCount = 0

    for name, count in pairs(item.locations or {}) do
        local locationKind = item.locationKinds
            and item.locationKinds[name]
            or InferLocationKind(name)

        if LocationMatchesInventoryFilter(
            locationKind,
            filterKey
        ) then
            locations[name] = count
            locationTimes[name] = item.locationTimes
                and item.locationTimes[name]
                or 0
            locationKinds[name] = locationKind
            totalCount = totalCount + (count or 0)
        end
    end

    if totalCount <= 0 then
        return nil
    end

    local filteredItem = {}

    for key, value in pairs(item) do
        filteredItem[key] = value
    end

    filteredItem.totalCount = totalCount
    filteredItem.locations = locations
    filteredItem.locationTimes = locationTimes
    filteredItem.locationKinds = locationKinds
    filteredItem.bcoSearchText = nil

    return filteredItem
end

function BCO:HasStorageSnapshots()
    for _, storage in pairs(
        self.savedVars.shared.storage or {}
    ) do
        if type(storage) == "table"
            and (storage.updated or 0) > 0
        then
            return true
        end
    end

    return false
end

function BCO:CategoryHasSearchResult(
    categoryKey,
    searchText
)
    local filterKey = self:GetInventoryFilterKey()

    for _, item in pairs(self.aggregatedItems) do
        local filteredItem =
            BuildInventoryFilteredItem(
                item,
                filterKey
            )

        if filteredItem
            and MatchesCategory(
                filteredItem,
                categoryKey
            )
            and ItemMatchesSearch(
                filteredItem,
                searchText
            )
        then
            return true
        end
    end

    return false
end

function BCO:RefreshSearchResults(
    callbackText
)
    if not self.active
        or not GAMEPAD_INVENTORY
    then
        return
    end

    self.searchText =
        self:ReadSearchText(callbackText)

    local current =
        GAMEPAD_INVENTORY:GetCurrentList()

    if current == self.itemList then
        self:RefreshItemList(true)

        local selectedData =
            self.itemList:GetTargetData()

        self.lastSelectedItemData = selectedData

        self:ScheduleItemTooltip(
            selectedData
        )
    elseif current == self.categoryList then
        self:RefreshCategoryList(true)
    end
end

function BCO:ScheduleSearchRefresh(
    callbackText
)
    self.searchRefreshGeneration =
        self.searchRefreshGeneration + 1

    local generation =
        self.searchRefreshGeneration

    zo_callLater(function()
        if generation
                ~= BCO.searchRefreshGeneration
            or not BCO.active
        then
            return
        end

        BCO:RefreshSearchResults(
            callbackText
        )
    end, 0)
end

function BCO:FilterItems(categoryKey)
    local result = {}
    local searchText =
        self.searchText or ""
    local filterKey =
        self:GetInventoryFilterKey()

    for _, item in pairs(self.aggregatedItems) do
        local filteredItem =
            BuildInventoryFilteredItem(
                item,
                filterKey
            )

        if filteredItem
            and MatchesCategory(
                filteredItem,
                categoryKey
            )
            and ItemMatchesSearch(
                filteredItem,
                searchText
            )
        then
            result[#result + 1] = filteredItem
        end
    end

    table.sort(result, function(left, right)
        if left.normalizedName == right.normalizedName then
            return tostring(left.key) < tostring(right.key)
        end

        return left.normalizedName < right.normalizedName
    end)

    self.filteredItems = result
    return result
end

local function MenuEquality(left, right)
    return left == right
        or (
            left
            and right
            and left.bcoKey == right.bcoKey
        )
end

local function SetupCategoryList(list)
    list:AddDataTemplate(
        "ZO_GamepadItemEntryTemplate",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction,
        MenuEquality
    )

    list:AddDataTemplateWithHeader(
        "ZO_GamepadItemEntryTemplate",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction,
        MenuEquality,
        "ZO_GamepadMenuEntryHeaderTemplate"
    )

    if list.SetReselectBehavior
        and ZO_PARAMETRIC_SCROLL_LIST_RESELECT_BEHAVIOR
    then
        list:SetReselectBehavior(
            ZO_PARAMETRIC_SCROLL_LIST_RESELECT_BEHAVIOR
                .MATCH_OR_RESET_TO_DEFAULT
        )
    end
end

local function SetupItemList(list)
    list:AddDataTemplate(
        "ZO_GamepadItemSubEntryTemplate",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction,
        MenuEquality
    )

    list:AddDataTemplateWithHeader(
        "ZO_GamepadItemSubEntryTemplate",
        ZO_SharedGamepadEntry_OnSetup,
        ZO_GamepadMenuEntryTemplateParametricListFunction,
        MenuEquality,
        "ZO_GamepadMenuEntryHeaderTemplate"
    )
end

local function FormatSectionHeader(sectionName)
    if not sectionName or sectionName == "" then
        sectionName = "Items"
    end

    if zo_strformat and SI_INVENTORY_HEADER then
        return zo_strformat(
            SI_INVENTORY_HEADER,
            sectionName
        )
    end

    return sectionName
end

local function GetEnumString(enumName, enumValue)
    if type(GetString) ~= "function"
        or enumValue == nil
    then
        return nil
    end

    local ok, value = pcall(
        GetString,
        enumName,
        enumValue
    )

    if ok
        and type(value) == "string"
        and value ~= ""
    then
        return value
    end

    return nil
end

local function GetItemLinkWeaponTypeSafe(itemLink)
    if type(GetItemLinkWeaponType) ~= "function"
        or not itemLink
        or itemLink == ""
    then
        return nil
    end

    local ok, weaponType = pcall(
        GetItemLinkWeaponType,
        itemLink
    )

    if ok then
        return weaponType
    end

    return nil
end

-- Mirrors ESO's current gamepad weapon grouping. This deliberately groups
-- individual flame/frost/lightning staves under Destruction Staff and the
-- one-handed weapon types under One-Handed Melee.
local function GetWeaponSectionName(item)
    local weaponType =
        GetItemLinkWeaponTypeSafe(
            item.itemLink
        )

    if not weaponType
        or weaponType == WEAPONTYPE_NONE
    then
        return nil
    end

    local categoryType = nil

    if weaponType == WEAPONTYPE_AXE
        or weaponType == WEAPONTYPE_HAMMER
        or weaponType == WEAPONTYPE_SWORD
        or weaponType == WEAPONTYPE_DAGGER
    then
        categoryType =
            GAMEPAD_WEAPON_CATEGORY_ONE_HANDED_MELEE
    elseif weaponType == WEAPONTYPE_TWO_HANDED_SWORD
        or weaponType == WEAPONTYPE_TWO_HANDED_AXE
        or weaponType == WEAPONTYPE_TWO_HANDED_HAMMER
    then
        categoryType =
            GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_MELEE
    elseif weaponType == WEAPONTYPE_FIRE_STAFF
        or weaponType == WEAPONTYPE_FROST_STAFF
        or weaponType == WEAPONTYPE_LIGHTNING_STAFF
    then
        categoryType =
            GAMEPAD_WEAPON_CATEGORY_DESTRUCTION_STAFF
    elseif weaponType == WEAPONTYPE_HEALING_STAFF then
        categoryType =
            GAMEPAD_WEAPON_CATEGORY_RESTORATION_STAFF
    elseif weaponType == WEAPONTYPE_BOW then
        categoryType =
            GAMEPAD_WEAPON_CATEGORY_TWO_HANDED_BOW
    else
        categoryType =
            GAMEPAD_WEAPON_CATEGORY_UNCATEGORIZED
    end

    if categoryType
        and categoryType
            ~= GAMEPAD_WEAPON_CATEGORY_UNCATEGORIZED
    then
        local categoryName = GetEnumString(
            "SI_GAMEPADWEAPONCATEGORY",
            categoryType
        )

        if categoryName then
            return FormatSectionHeader(
                categoryName
            )
        end
    end

    local weaponName = GetEnumString(
        "SI_WEAPONTYPE",
        weaponType
    )

    return weaponName
        and FormatSectionHeader(weaponName)
        or nil
end

local APPAREL_SECTION_ORDER = {}

local function RegisterApparelOrder(equipType, order)
    if equipType ~= nil then
        APPAREL_SECTION_ORDER[equipType] = order
    end
end

RegisterApparelOrder(EQUIP_TYPE_HEAD, 10)
RegisterApparelOrder(EQUIP_TYPE_SHOULDERS, 20)
RegisterApparelOrder(EQUIP_TYPE_CHEST, 30)
RegisterApparelOrder(EQUIP_TYPE_HAND, 40)
RegisterApparelOrder(EQUIP_TYPE_WAIST, 50)
RegisterApparelOrder(EQUIP_TYPE_LEGS, 60)
RegisterApparelOrder(EQUIP_TYPE_FEET, 70)
RegisterApparelOrder(EQUIP_TYPE_NECK, 80)
RegisterApparelOrder(EQUIP_TYPE_RING, 90)
RegisterApparelOrder(EQUIP_TYPE_COSTUME, 100)

-- ESO's normal Inventory presents worn equipment primarily through equipment
-- slots rather than one combined Apparel page. All Inventories therefore uses
-- those slot names as its own useful Apparel subsections.
local function GetApparelSectionName(item)
    local equipType = item.equipType

    if not equipType
        or equipType == EQUIP_TYPE_INVALID
    then
        return nil, nil
    end

    local sectionName = GetEnumString(
        "SI_EQUIPTYPE",
        equipType
    )

    if sectionName then
        return FormatSectionHeader(sectionName),
            APPAREL_SECTION_ORDER[equipType]
            or 999
    end

    return nil, nil
end

local function GetNativeUtilitySectionName(item)
    if type(
        ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
    ) ~= "function"
    then
        return nil
    end

    local itemData = {
        itemLink = item.itemLink or "",
        name = item.name or "",
        rawName = item.name or "",
        iconFile = item.icon or "",
        stackCount = item.totalCount or 1,
        itemType = item.itemType or 0,
        specializedItemType =
            item.specializedItemType or 0,
        equipType =
            item.equipType
            or EQUIP_TYPE_INVALID,
        displayQuality =
            item.quality
            or ITEM_DISPLAY_QUALITY_NORMAL,
        quality =
            item.quality
            or ITEM_DISPLAY_QUALITY_NORMAL,
    }

    local ok, sectionName = pcall(
        ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription,
        itemData
    )

    if ok
        and type(sectionName) == "string"
        and sectionName ~= ""
    then
        return FormatSectionHeader(
            sectionName
        )
    end

    return nil
end

local function GetFallbackSectionName(item)
    local specializedName = GetEnumString(
        "SI_SPECIALIZEDITEMTYPE",
        item.specializedItemType or 0
    )

    if specializedName then
        return FormatSectionHeader(
            specializedName
        )
    end

    local itemTypeName = GetEnumString(
        "SI_ITEMTYPE",
        item.itemType or 0
    )

    if itemTypeName then
        return FormatSectionHeader(
            itemTypeName
        )
    end

    return FormatSectionHeader("Items")
end

local function GetItemSectionInfo(item, categoryKey)
    local weaponSection =
        GetWeaponSectionName(item)

    if weaponSection then
        return weaponSection, 100
    end

    if categoryKey == "apparel"
        or categoryKey == "companion"
        or item.itemType == ITEMTYPE_ARMOR
    then
        local apparelSection, apparelOrder =
            GetApparelSectionName(item)

        if apparelSection then
            return apparelSection,
                apparelOrder or 200
        end
    end

    local nativeSection =
        GetNativeUtilitySectionName(item)

    if nativeSection then
        return nativeSection, 300
    end

    return GetFallbackSectionName(item), 900
end

local function BuildSectionedItemRows(items, categoryKey)
    local rows = {}

    for index = 1, #items do
        local item = items[index]
        local sectionName, sectionOrder =
            GetItemSectionInfo(
                item,
                categoryKey
            )

        rows[#rows + 1] = {
            item = item,
            sectionName = sectionName,
            sectionOrder = sectionOrder or 999,
            normalizedSection =
                Lower(sectionName),
        }
    end

    table.sort(rows, function(left, right)
        -- Apparel has a natural equipment-slot order. All other sections keep
        -- ESO's familiar alphabetic category ordering.
        if categoryKey == "apparel"
            or categoryKey == "companion"
        then
            if left.sectionOrder
                ~= right.sectionOrder
            then
                return left.sectionOrder
                    < right.sectionOrder
            end
        elseif left.normalizedSection
            ~= right.normalizedSection
        then
            return left.normalizedSection
                < right.normalizedSection
        end

        if left.normalizedSection
            == right.normalizedSection
        then
            if left.item.normalizedName
                == right.item.normalizedName
            then
                return tostring(left.item.key)
                    < tostring(right.item.key)
            end

            return left.item.normalizedName
                < right.item.normalizedName
        end

        return left.normalizedSection
            < right.normalizedSection
    end)

    return rows
end

local function ColorizeLocationRow(text)
    if ZO_SELECTED_TEXT
        and type(ZO_SELECTED_TEXT.Colorize) == "function"
    then
        return ZO_SELECTED_TEXT:Colorize(text)
    end

    return text
end

local function IsCurrentCharacterLocation(name)
    local currentName = Lower(CharacterName())
    local locationName = Lower(name)

    return locationName == currentName
        or locationName == currentName .. " (equipped)"
end

local function BuildSortedLocationRows(item)
    local rows = {}

    for name, count in pairs(item.locations or {}) do
        rows[#rows + 1] = {
            name = name,
            count = count or 0,
            isBank = Lower(name) == "bank",
            isCurrent = IsCurrentCharacterLocation(name),
        }
    end

    table.sort(rows, function(left, right)
        if left.isBank ~= right.isBank then
            return left.isBank
        end

        if left.isCurrent ~= right.isCurrent then
            return left.isCurrent
        end

        if left.count ~= right.count then
            return left.count > right.count
        end

        return Lower(left.name) < Lower(right.name)
    end)

    return rows
end

local function FormatLocationLine(row)
    return ColorizeLocationRow(
        string.format(
            "%s  x%d",
            row.name,
            row.count
        )
    )
end

local function LocationStatusText(item)
    local rows = BuildSortedLocationRows(item)

    if #rows == 0 then
        return ""
    end

    -- Keep a fixed three-row body under ITEM LOCATIONS. Two exact locations
    -- are shown, followed by a summary row when more locations exist. This
    -- keeps the tooltip anchored without reserving an unnecessary fourth
    -- row that would place the item details too high on the screen.
    local lines = { "ITEM LOCATIONS" }
    local visibleCount = math.min(
        #rows,
        BCO.collapsedLocationRows
    )

    for index = 1, visibleCount do
        lines[#lines + 1] =
            FormatLocationLine(rows[index])
    end

    if #rows > visibleCount then
        local hiddenCount = #rows - visibleCount
        local hiddenTotal = 0

        for index = visibleCount + 1, #rows do
            hiddenTotal = hiddenTotal
                + rows[index].count
        end

        local locationWord = hiddenCount == 1
            and "OTHER LOCATION"
            or "OTHER LOCATIONS"

        lines[#lines + 1] = ColorizeLocationRow(
            string.format(
                "%d %s  x%d",
                hiddenCount,
                locationWord,
                hiddenTotal
            )
        )
    end

    while #lines < 1 + BCO.collapsedLocationBodyRows do
        lines[#lines + 1] = " "
    end

    return table.concat(lines, "\n")
end

local function ExpandedLocationText(item)
    local rows = BuildSortedLocationRows(item)
    local lines = {}

    for index = 1, #rows do
        lines[#lines + 1] =
            FormatLocationLine(rows[index])
    end

    return table.concat(lines, "\n"), #rows
end

local function LocationCount(item)
    local count = 0

    for _ in pairs(item and item.locations or {}) do
        count = count + 1
    end

    return count
end

local function ForceTooltipControlVisible(tooltipType)
    local tooltips = GAMEPAD_TOOLTIPS
        and GAMEPAD_TOOLTIPS.tooltips

    local tooltipInfo = tooltips
        and tooltips[tooltipType]

    if not tooltipInfo then
        return
    end

    local control = tooltipInfo.control

    if control and control.SetHidden then
        control:SetHidden(false)
    end

    local container = control and control.container
    if container and container.SetHidden then
        container:SetHidden(false)
    end
end

local function SetLocationTooltipInputEnabled(enabled)
    if GAMEPAD_TOOLTIPS
        and type(GAMEPAD_TOOLTIPS.SetInputEnabled) == "function"
    then
        pcall(
            GAMEPAD_TOOLTIPS.SetInputEnabled,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            enabled
        )
    end
end


local function FormatCurrencyAmount(amount)
    amount = tonumber(amount) or 0

    if type(ZO_CommaDelimitNumber) == "function" then
        local ok, formatted = pcall(
            ZO_CommaDelimitNumber,
            amount
        )

        if ok and formatted then
            return tostring(formatted)
        end
    end

    return tostring(amount)
end

local function CurrencyDisplayName(definition)
    local name

    if type(GetCurrencyName) == "function" then
        local ok, value = pcall(
            GetCurrencyName,
            definition.currencyType,
            false,
            true
        )

        if ok and type(value) == "string" then
            name = Trim(value)
        end
    end

    if not name or name == "" then
        name = definition.fallbackName
    end

    return name
end

local function CurrencyIconMarkup(currencyType)
    local icon

    if type(GetCurrencyGamepadIcon) == "function" then
        local ok, value = pcall(
            GetCurrencyGamepadIcon,
            currencyType
        )

        if ok and type(value) == "string" then
            icon = value
        end
    end

    if (not icon or icon == "")
        and type(GetCurrencyKeyboardIcon) == "function"
    then
        local ok, value = pcall(
            GetCurrencyKeyboardIcon,
            currencyType
        )

        if ok and type(value) == "string" then
            icon = value
        end
    end

    if not icon or icon == "" then
        return ""
    end

    if type(zo_iconFormat) == "function" then
        local ok, markup = pcall(
            zo_iconFormat,
            icon,
            30,
            30
        )

        if ok and markup then
            return " " .. tostring(markup)
        end
    end

    return string.format(
        " |t30:30:%s|t",
        icon
    )
end

local function CurrencyHeading(text)
    if ZO_SELECTED_TEXT
        and type(ZO_SELECTED_TEXT.Colorize) == "function"
    then
        return ZO_SELECTED_TEXT:Colorize(text)
    end

    return text
end

function BCO:GetCurrencyTooltipData()
    local characters = {}
    local missingSnapshot = false

    for _, character in pairs(
        self.savedVars.characters or {}
    ) do
        if type(character) == "table" then
            characters[#characters + 1] = {
                name = character.name
                    or "Unknown Character",
                currencies = character.currencies,
            }
        end
    end

    table.sort(characters, function(left, right)
        return Lower(left.name) < Lower(right.name)
    end)

    local bankCurrencies =
        self.savedVars.shared
        and self.savedVars.shared.currencies
        and self.savedVars.shared.currencies.bank
        or {}
    local definitions =
        GetCharacterCurrencyDefinitions()
    local totals = {}

    for definitionIndex = 1, #definitions do
        local key = tostring(
            definitions[definitionIndex].currencyType
        )
        totals[key] =
            tonumber(bankCurrencies[key]) or 0
    end

    for characterIndex = 1, #characters do
        local currencies =
            characters[characterIndex].currencies

        if type(currencies) == "table" then
            for definitionIndex = 1, #definitions do
                local key = tostring(
                    definitions[definitionIndex].currencyType
                )
                totals[key] = (totals[key] or 0)
                    + (tonumber(currencies[key]) or 0)
            end
        else
            missingSnapshot = true
        end
    end

    return {
        characters = characters,
        bankCurrencies = bankCurrencies,
        definitions = definitions,
        totals = totals,
        missingSnapshot = missingSnapshot,
    }
end

local function CurrencyDisplayNameUpper(definition)
    local name = CurrencyDisplayName(definition)

    if type(zo_strupper) == "function" then
        local ok, upperName = pcall(
            zo_strupper,
            name
        )

        if ok and type(upperName) == "string" then
            return upperName
        end
    end

    return string.upper(name)
end

local function CurrencyTooltipTitle()
    if type(GetString) == "function"
        and SI_INVENTORY_CURRENCIES
    then
        local ok, title = pcall(
            GetString,
            SI_INVENTORY_CURRENCIES
        )

        if ok and type(title) == "string"
            and title ~= ""
        then
            return title
        end
    end

    return "Currencies"
end

local function NativeCurrencyValue(
    definition,
    amount,
    isScanned
)
    if isScanned == false then
        return "NOT SCANNED"
            .. CurrencyIconMarkup(
                definition.currencyType
            )
    end

    amount = tonumber(amount) or 0

    local whiteAmountIconFormat =
        ZO_CURRENCY_FORMAT_WHITE_AMOUNT_ICON
        or ZO_CURRENCY_FORMAT_AMOUNT_ICON

    if type(ZO_Currency_FormatGamepad) == "function"
        and whiteAmountIconFormat
    then
        local options = {
            showCap = false,
        }
        local ok, value = pcall(
            ZO_Currency_FormatGamepad,
            definition.currencyType,
            amount,
            whiteAmountIconFormat,
            options
        )

        if ok and type(value) == "string"
            and value ~= ""
        then
            return value
        end
    end

    return FormatCurrencyAmount(amount)
        .. CurrencyIconMarkup(
            definition.currencyType
        )
end

local function IsCurrencyTooltipObject(candidate)
    return candidate
        and type(candidate.GetStyle) == "function"
        and type(candidate.AcquireSection) == "function"
        and type(candidate.AddSection) == "function"
end

local function GetCurrencyTooltipTip()
    local tooltipInfo =
        GAMEPAD_TOOLTIPS
        and GAMEPAD_TOOLTIPS.tooltips
        and GAMEPAD_TOOLTIPS.tooltips[
            GAMEPAD_LEFT_TOOLTIP
        ]

    if not tooltipInfo then
        return nil
    end

    local control = tooltipInfo.control
    local container = control and control.container
    local scrollTip = container and container.tip

    -- On console, container.tip is the scroll-tooltip wrapper.
    -- The actual ZO_Tooltip object that owns GetStyle(),
    -- AcquireSection(), and AddSection() is wrapper.tooltip.
    -- Some UI versions expose that object directly, so check
    -- every known location and return only a usable tooltip.
    local candidate = tooltipInfo.tooltip
    if IsCurrencyTooltipObject(candidate) then
        return candidate
    end

    candidate = control and control.tooltip
    if IsCurrencyTooltipObject(candidate) then
        return candidate
    end

    candidate = container and container.tooltip
    if IsCurrencyTooltipObject(candidate) then
        return candidate
    end

    candidate = scrollTip and scrollTip.tooltip
    if IsCurrencyTooltipObject(candidate) then
        return candidate
    end

    if IsCurrencyTooltipObject(scrollTip) then
        return scrollTip
    end

    return nil
end

local function AddNativeCurrencyLocationSection(
    tip,
    mainSection,
    heading,
    currencies,
    isScanned,
    definitions
)
    -- Use the same nested sections and styles as ESO's native
    -- gamepad currency overview. The dedicated currency pair
    -- style supplies the smaller fonts, off-white labels,
    -- white values, fixed row width, and right alignment.
    local locationSection = mainSection:AcquireSection(
        tip:GetStyle("currencyLocationSection")
    )

    locationSection:AddLine(
        heading,
        tip:GetStyle("currencyLocationTitle")
    )

    local currenciesSection = locationSection:AcquireSection(
        tip:GetStyle("currencyLocationCurrenciesSection")
    )

    for definitionIndex = 1, #definitions do
        local definition = definitions[definitionIndex]
        local key = tostring(
            definition.currencyType
        )
        local pair = currenciesSection:AcquireStatValuePair(
            tip:GetStyle("currencyStatValuePair")
        )

        pair:SetStat(
            CurrencyDisplayNameUpper(definition),
            tip:GetStyle("currencyStatValuePairStat")
        )
        pair:SetValue(
            NativeCurrencyValue(
                definition,
                currencies and currencies[key],
                isScanned
            ),
            tip:GetStyle("currencyStatValuePairValue")
        )
        currenciesSection:AddStatValuePair(pair)
    end

    locationSection:AddSection(currenciesSection)
    mainSection:AddSection(locationSection)
end

function BCO:LayoutNativeCurrencyTooltip()
    local data = self:GetCurrencyTooltipData()
    local definitions = data.definitions
    local tip = GetCurrencyTooltipTip()

    if #definitions == 0
        or not tip
        or type(tip.GetStyle) ~= "function"
        or type(tip.AcquireSection) ~= "function"
        or type(tip.AddSection) ~= "function"
    then
        return false
    end

    local ok = pcall(function()
        local mainSection = tip:AcquireSection(
            tip:GetStyle("currencyMainSection")
        )

        AddNativeCurrencyLocationSection(
            tip,
            mainSection,
            "TOTAL",
            data.totals,
            true,
            definitions
        )
        AddNativeCurrencyLocationSection(
            tip,
            mainSection,
            "BANKED",
            data.bankCurrencies,
            true,
            definitions
        )

        for characterIndex = 1, #data.characters do
            local character =
                data.characters[characterIndex]
            local isScanned =
                type(character.currencies) == "table"

            AddNativeCurrencyLocationSection(
                tip,
                mainSection,
                character.name,
                character.currencies,
                isScanned,
                definitions
            )
        end

        tip:AddSection(mainSection)
    end)

    return ok
end

function BCO:BuildCurrencyTooltipText()
    local lines = {}
    local data = self:GetCurrencyTooltipData()
    local definitions = data.definitions

    local function AppendSection(
        heading,
        currencies,
        isScanned
    )
        if #lines > 0 then
            lines[#lines + 1] = " "
        end

        lines[#lines + 1] =
            CurrencyHeading(heading)

        for definitionIndex = 1, #definitions do
            local definition =
                definitions[definitionIndex]
            local key = tostring(
                definition.currencyType
            )
            local value

            if isScanned == false then
                value = "NOT SCANNED"
            else
                value = FormatCurrencyAmount(
                    currencies and currencies[key]
                )
            end

            lines[#lines + 1] = string.format(
                "%s  %s%s",
                CurrencyDisplayNameUpper(definition),
                value,
                CurrencyIconMarkup(
                    definition.currencyType
                )
            )
        end
    end

    if #definitions == 0 then
        lines[#lines + 1] =
            "Character currency data is unavailable."
        return table.concat(lines, "\n")
    end

    AppendSection("TOTAL", data.totals, true)
    AppendSection(
        "BANKED",
        data.bankCurrencies,
        true
    )

    for characterIndex = 1, #data.characters do
        local character =
            data.characters[characterIndex]
        local isScanned =
            type(character.currencies) == "table"

        AppendSection(
            character.name,
            character.currencies,
            isScanned
        )
    end

    return table.concat(lines, "\n")
end

function BCO:RenderCurrencyTooltip()
    if not GAMEPAD_TOOLTIPS then
        return false
    end

    GAMEPAD_TOOLTIPS:ClearTooltip(
        GAMEPAD_LEFT_TOOLTIP
    )
    GAMEPAD_TOOLTIPS:ClearTooltip(
        GAMEPAD_RIGHT_TOOLTIP
    )

    local title = CurrencyTooltipTitle()

    if GAMEPAD_TOOLTIPS.SetStatusLabelText then
        pcall(
            GAMEPAD_TOOLTIPS.SetStatusLabelText,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            "",
            title
        )
    elseif GAMEPAD_TOOLTIPS.ClearStatusLabel then
        pcall(
            GAMEPAD_TOOLTIPS.ClearStatusLabel,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP
        )
    end

    local rendered = self:LayoutNativeCurrencyTooltip()

    if not rendered then
        GAMEPAD_TOOLTIPS:ClearTooltip(
            GAMEPAD_LEFT_TOOLTIP
        )

        local text = self:BuildCurrencyTooltipText()

        if GAMEPAD_TOOLTIPS.LayoutTitleAndDescriptionTooltip then
            rendered = pcall(
                GAMEPAD_TOOLTIPS.LayoutTitleAndDescriptionTooltip,
                GAMEPAD_TOOLTIPS,
                GAMEPAD_LEFT_TOOLTIP,
                "CURRENCIES",
                text
            )
        elseif GAMEPAD_TOOLTIPS.LayoutTextBlockTooltip then
            rendered = pcall(
                GAMEPAD_TOOLTIPS.LayoutTextBlockTooltip,
                GAMEPAD_TOOLTIPS,
                GAMEPAD_LEFT_TOOLTIP,
                "CURRENCIES\n\n" .. text
            )
        end
    end

    -- Direct native section layout bypasses the manager's normal layout
    -- wrapper, so explicitly restore the standard gamepad tooltip backdrop.
    if type(GAMEPAD_TOOLTIPS.SetBgType) == "function" then
        pcall(
            GAMEPAD_TOOLTIPS.SetBgType,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            GAMEPAD_TOOLTIP_NORMAL_BG or 1
        )
    end

    if type(GAMEPAD_TOOLTIPS.SetAutoShowBg) == "function" then
        pcall(
            GAMEPAD_TOOLTIPS.SetAutoShowBg,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            true
        )
    end

    if type(GAMEPAD_TOOLTIPS.ShowBg) == "function" then
        pcall(
            GAMEPAD_TOOLTIPS.ShowBg,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP
        )
    end

    ForceTooltipControlVisible(
        GAMEPAD_LEFT_TOOLTIP
    )
    SetLocationTooltipInputEnabled(true)

    if GAMEPAD_TOOLTIPS.ResetScrollTooltipToTop then
        GAMEPAD_TOOLTIPS:ResetScrollTooltipToTop(
            GAMEPAD_LEFT_TOOLTIP
        )
    end

    return rendered
end

function BCO:ScheduleCurrencyTooltip(selectedData)
    self.currencyTooltipGeneration =
        self.currencyTooltipGeneration + 1

    local generation =
        self.currencyTooltipGeneration
    local pendingData = selectedData
    local delays = { 0, 50, 200 }

    for index = 1, #delays do
        zo_callLater(function()
            if generation ~= BCO.currencyTooltipGeneration
                or not BCO.active
                or not GAMEPAD_INVENTORY
                or GAMEPAD_INVENTORY:GetCurrentList()
                    ~= BCO.categoryList
            then
                return
            end

            local currentData =
                BCO.categoryList:GetTargetData()
                or pendingData

            if currentData
                and currentData.bcoKey == "currencies"
            then
                BCO:RenderCurrencyTooltip()
            end
        end, delays[index])
    end
end

function BCO:UpdateCategoryTooltip(selectedData)
    self.currencyTooltipGeneration =
        self.currencyTooltipGeneration + 1

    SetLocationTooltipInputEnabled(false)

    if GAMEPAD_TOOLTIPS then
        GAMEPAD_TOOLTIPS:ClearTooltip(
            GAMEPAD_LEFT_TOOLTIP
        )
        GAMEPAD_TOOLTIPS:ClearTooltip(
            GAMEPAD_RIGHT_TOOLTIP
        )
    end

    if selectedData
        and selectedData.bcoKey == "currencies"
    then
        self:ScheduleCurrencyTooltip(
            selectedData
        )
    end
end

local function GetItemPreviewObject()
    if not SYSTEMS
        or type(SYSTEMS.GetObject) ~= "function"
    then
        return nil
    end

    local ok, previewObject = pcall(
        SYSTEMS.GetObject,
        SYSTEMS,
        "itemPreview"
    )

    if ok then
        return previewObject
    end

    return nil
end

function BCO:SetFurnishingPreviewBuffer(enabled)
    local previewObject = GetItemPreviewObject()

    if not previewObject
        or type(previewObject.SetPreviewBufferMS)
            ~= "function"
    then
        return false
    end

    -- Keep the previous furnishing visible while rapid gamepad selection
    -- changes settle. A non-zero buffer is important on console because a
    -- zero millisecond buffer still commits every transient row on the next
    -- preview update and can expose the character while the model changes.
    local bufferMilliseconds = enabled
        and (self.furnishingPreviewSettleMS or 90)
        or nil

    return pcall(
        previewObject.SetPreviewBufferMS,
        previewObject,
        bufferMilliseconds
    )
end

local function CanPreviewItemLinkAsFurniture(itemLink)
    if not itemLink or itemLink == "" then
        return false
    end

    -- Update 50 can expose either the furniture-specific validator or only
    -- the generic item-link validator, depending on the UI path/platform.
    -- Accept either result so saved links from another character are not
    -- rejected before PreviewItemLink gets a chance to handle them.
    if type(CanItemLinkBePreviewedAsFurniture)
        == "function"
    then
        local ok, canPreview = pcall(
            CanItemLinkBePreviewedAsFurniture,
            itemLink
        )

        if ok and canPreview == true then
            return true
        end
    end

    if type(CanItemLinkBePreviewed) == "function" then
        local ok, canPreview = pcall(
            CanItemLinkBePreviewed,
            itemLink
        )

        if ok and canPreview == true then
            return true
        end
    end

    -- PreviewItemLink is itself the final authority on clients that do not
    -- publish either eligibility helper to insecure addon code.
    return type(PreviewItemLink) == "function"
end

local function ClearPendingPreviewCollection(previewObject)
    if not previewObject
        or type(previewObject.ClearPreviewCollection)
            ~= "function"
    then
        return false
    end

    return pcall(
        previewObject.ClearPreviewCollection,
        previewObject
    )
end

local function CommitPendingPreviewCollection()
    if type(ApplyChangesToPreviewCollectionShown)
        ~= "function"
    then
        return false
    end

    return pcall(ApplyChangesToPreviewCollectionShown)
end

local function TryFurnishingPreviewCall(path, callback, ...)
    BCO.lastFurnishingPreviewPath = path or "unknown"

    local ok, result = pcall(callback, ...)

    if ok then
        BCO.lastFurnishingPreviewError = nil
    else
        BCO.lastFurnishingPreviewError =
            tostring(result or "preview call failed")
    end

    return ok
end

local function FindItemLinkInBag(bagId, itemLink)
    if bagId == nil
        or not itemLink
        or itemLink == ""
        or type(GetItemLink) ~= "function"
    then
        return nil
    end

    local foundSlotIndex = nil

    local ok = pcall(
        IterateBag,
        bagId,
        function(slotIndex)
            if foundSlotIndex ~= nil then
                return
            end

            local liveLink = GetItemLink(
                bagId,
                slotIndex,
                LINK_STYLE_DEFAULT
            ) or ""

            if liveLink == itemLink then
                foundSlotIndex = slotIndex
            end
        end
    )

    if ok then
        return foundSlotIndex
    end

    return nil
end

function BCO:FindLiveFurnishingPreviewSlot(item)
    if not item
        or not item.itemLink
        or item.itemLink == ""
    then
        return nil, nil
    end

    local bags = {}
    local seenBags = {}

    local function AddBag(bagId)
        if bagId ~= nil and not seenBags[bagId] then
            seenBags[bagId] = true
            bags[#bags + 1] = bagId
        end
    end

    -- ESO's native furniture preview path needs a real inventory slot that
    -- the client currently exposes. Check every bag that can legitimately be
    -- available, then let CanInventoryItemBePreviewed reject unloaded bags.
    AddBag(BAG_BACKPACK)
    AddBag(BAG_WORN)
    AddBag(self.activeBankBag)
    AddBag(BAG_BANK)
    AddBag(BAG_SUBSCRIBER_BANK)
    AddBag(BAG_FURNITURE_VAULT)

    for bagId in pairs(HOUSE_BANK_ORDINALS) do
        AddBag(bagId)
    end

    for storageKey, storage in pairs(
        self.savedVars
            and self.savedVars.shared
            and self.savedVars.shared.storage
            or {}
    ) do
        if type(storage) == "table" then
            AddBag(storage.bagId or tonumber(storageKey))
        else
            AddBag(tonumber(storageKey))
        end
    end

    for index = 1, #bags do
        local bagId = bags[index]
        local slotIndex = FindItemLinkInBag(
            bagId,
            item.itemLink
        )

        if slotIndex ~= nil then
            if type(CanInventoryItemBePreviewed)
                == "function"
            then
                local ok, canPreview = pcall(
                    CanInventoryItemBePreviewed,
                    bagId,
                    slotIndex
                )

                if ok and canPreview then
                    return bagId, slotIndex
                end
            else
                return bagId, slotIndex
            end
        end
    end

    return nil, nil
end

function BCO:GetSelectedItemData(fallbackData)
    local targetData = self.itemList
        and self.itemList:GetTargetData()

    if targetData and targetData.bcoItem then
        self.lastSelectedItemData = targetData
        return targetData
    end

    if fallbackData and fallbackData.bcoItem then
        self.lastSelectedItemData = fallbackData
        return fallbackData
    end

    local inventoryData = GAMEPAD_INVENTORY
        and GAMEPAD_INVENTORY.currentlySelectedData

    if inventoryData and inventoryData.bcoItem then
        self.lastSelectedItemData = inventoryData
        return inventoryData
    end

    if self.lastSelectedItemData
        and self.lastSelectedItemData.bcoItem
    then
        return self.lastSelectedItemData
    end

    if self.firstItemEntryData
        and self.firstItemEntryData.bcoItem
    then
        self.lastSelectedItemData =
            self.firstItemEntryData
        return self.firstItemEntryData
    end

    return nil
end

function BCO:ResolveFurnishingPreviewSlot(dataOrItem)
    local data = dataOrItem
        and dataOrItem.bcoItem
        and dataOrItem
        or nil
    local item = data and data.bcoItem or dataOrItem

    if not item then
        return nil, nil
    end

    if data
        and data.bcoPreviewBagId ~= nil
        and data.bcoPreviewSlotIndex ~= nil
    then
        if type(CanInventoryItemBePreviewed)
            ~= "function"
        then
            return data.bcoPreviewBagId,
                data.bcoPreviewSlotIndex
        end

        local ok, canPreview = pcall(
            CanInventoryItemBePreviewed,
            data.bcoPreviewBagId,
            data.bcoPreviewSlotIndex
        )

        if ok and canPreview then
            return data.bcoPreviewBagId,
                data.bcoPreviewSlotIndex
        end

        data.bcoPreviewBagId = nil
        data.bcoPreviewSlotIndex = nil
    end

    local bagId, slotIndex =
        self:FindLiveFurnishingPreviewSlot(item)

    if data and bagId ~= nil and slotIndex ~= nil then
        data.bcoPreviewBagId = bagId
        data.bcoPreviewSlotIndex = slotIndex
    end

    return bagId, slotIndex
end

function BCO:IsFurnishingPreviewActive()
    -- Once ESO has confirmed the initial preview, keep the mode active while
    -- the selected furnishing is being replaced. The native collection can
    -- report false for a frame during that replacement on console.
    if self.furnishingPreviewConfirmed then
        return true
    end

    if type(IsCurrentlyPreviewing) == "function" then
        local ok, active = pcall(IsCurrentlyPreviewing)

        if ok then
            return active == true
        end
    end

    return false
end

function BCO:CanPreviewFurnishing(dataOrItem)
    local item = dataOrItem
        and dataOrItem.bcoItem
        or dataOrItem

    if not item
        or not IsFurnishing(item)
        or not item.itemLink
        or item.itemLink == ""
    then
        return false
    end

    if type(IsCharacterPreviewingAvailable) == "function" then
        local ok, available = pcall(
            IsCharacterPreviewingAvailable
        )

        if ok and not available then
            return false
        end
    end

    local bagId, slotIndex =
        self:ResolveFurnishingPreviewSlot(dataOrItem)

    if bagId ~= nil and slotIndex ~= nil then
        return true
    end

    -- Snapshot-only furnishings do not have a live bag slot. ESO can still
    -- validate and preview their saved item link directly.
    return type(PreviewItemLink) == "function"
        and CanPreviewItemLinkAsFurniture(item.itemLink)
end

function BCO:PreviewFurnishing(
    item,
    resolvedBagId,
    resolvedSlotIndex
)
    if not item
        or not IsFurnishing(item)
        or not item.itemLink
        or item.itemLink == ""
    then
        return false
    end

    if type(IsCharacterPreviewingAvailable) == "function" then
        local ok, available = pcall(
            IsCharacterPreviewingAvailable
        )

        if ok and not available then
            return false
        end
    end

    local bagId = resolvedBagId
    local slotIndex = resolvedSlotIndex

    if bagId == nil or slotIndex == nil then
        bagId, slotIndex =
            self:ResolveFurnishingPreviewSlot(item)
    end

    local previewObject = GetItemPreviewObject()
    if not previewObject then
        return false
    end

    local wasPreviewActive =
        self:IsFurnishingPreviewActive()

    -- Duplicate target callbacks are common in parametric gamepad lists.
    if self.previewingFurnishingItemLink
            == item.itemLink
        and self:IsFurnishingPreviewActive()
    then
        return true
    end

    local previewBufferEnabled =
        self:SetFurnishingPreviewBuffer(true)
    local requested = false
    local usedItemLink = false
    local canUseItemLink =
        type(PreviewItemLink) == "function"
        and CanPreviewItemLinkAsFurniture(item.itemLink)

    local function PreviewActiveItemLink(path)
        usedItemLink = true

        -- The item-link path is the only replacement path observed to keep
        -- the PS5 preview scene continuously rendered. Use it for every
        -- already-open preview, including furnishings that also have a live
        -- backpack, bank, housing-storage, or Furnishing Vault slot.
        if GAMEPAD_INVENTORY then
            GAMEPAD_INVENTORY.currentPreviewBagId = nil
            GAMEPAD_INVENTORY.currentPreviewSlotIndex = nil
        end

        ClearPendingPreviewCollection(previewObject)

        local accepted = TryFurnishingPreviewCall(
            path,
            PreviewItemLink,
            item.itemLink,
            0
        )

        if accepted then
            CommitPendingPreviewCollection()
        end

        return accepted
    end

    if wasPreviewActive and canUseItemLink then
        -- Do not use PreviewInventoryItem while scrolling. Even its direct
        -- pending-collection form briefly exposes the character model for
        -- live slots on PS5. Item-link replacement has already proven
        -- seamless for snapshot-only furnishings, and the same item link is
        -- valid for live items as well.
        requested = PreviewActiveItemLink(
            bagId ~= nil
                and "live-active-item-link"
                or "remote-active-item-link"
        )

        if not requested
            and bagId ~= nil
            and slotIndex ~= nil
            and type(PreviewInventoryItem) == "function"
        then
            -- Keep slot previewing only as a compatibility fallback so an
            -- unusual client API restriction cannot break live previews.
            usedItemLink = false
            ClearPendingPreviewCollection(previewObject)
            requested = TryFurnishingPreviewCall(
                "live-active-slot-fallback",
                PreviewInventoryItem,
                bagId,
                slotIndex
            )

            if requested then
                CommitPendingPreviewCollection()
            elseif type(previewObject.PreviewInventoryItem)
                == "function"
            then
                requested = TryFurnishingPreviewCall(
                    "live-active-shared-fallback",
                    previewObject.PreviewInventoryItem,
                    previewObject,
                    bagId,
                    slotIndex
                )
            end

            if GAMEPAD_INVENTORY then
                GAMEPAD_INVENTORY.currentPreviewBagId =
                    bagId
                GAMEPAD_INVENTORY.currentPreviewSlotIndex =
                    slotIndex
            end
        end
    elseif canUseItemLink then
        -- Open every furnishing preview through the same item-link preview
        -- type used by snapshot-only items. Previously live items opened as
        -- inventory-slot previews, so the first scroll had to change preview
        -- types before later item-link replacements could become seamless.
        usedItemLink = true

        if GAMEPAD_INVENTORY then
            GAMEPAD_INVENTORY.currentPreviewBagId = nil
            GAMEPAD_INVENTORY.currentPreviewSlotIndex = nil
        end

        if type(previewObject.PreviewItemLink)
            == "function"
        then
            requested = TryFurnishingPreviewCall(
                bagId ~= nil
                    and "live-initial-item-link-shared"
                    or "remote-initial-item-link-shared",
                previewObject.PreviewItemLink,
                previewObject,
                item.itemLink,
                0
            )
        end

        if not requested then
            ClearPendingPreviewCollection(previewObject)
            requested = TryFurnishingPreviewCall(
                bagId ~= nil
                    and "live-initial-item-link-direct"
                    or "remote-initial-item-link-direct",
                PreviewItemLink,
                item.itemLink,
                0
            )

            if requested then
                CommitPendingPreviewCollection()
            end
        end

        if not requested
            and bagId ~= nil
            and slotIndex ~= nil
        then
            -- Item-link previewing is expected on Update 50, but preserve a
            -- live-slot escape hatch for console builds that restrict either
            -- item-link entry point to secure code.
            usedItemLink = false

            if GAMEPAD_INVENTORY
                and type(GAMEPAD_INVENTORY.PreviewInventoryItem)
                    == "function"
            then
                requested = TryFurnishingPreviewCall(
                    "live-initial-native-fallback",
                    GAMEPAD_INVENTORY.PreviewInventoryItem,
                    GAMEPAD_INVENTORY,
                    bagId,
                    slotIndex
                )
            elseif type(previewObject.PreviewInventoryItem)
                == "function"
            then
                ClearPendingPreviewCollection(previewObject)
                requested = TryFurnishingPreviewCall(
                    "live-initial-shared-fallback",
                    previewObject.PreviewInventoryItem,
                    previewObject,
                    bagId,
                    slotIndex
                )
            end
        end
    elseif bagId ~= nil and slotIndex ~= nil then
        -- Legacy fallback for clients that expose slot previewing but no
        -- item-link preview API at all.
        if GAMEPAD_INVENTORY
            and type(GAMEPAD_INVENTORY.PreviewInventoryItem)
                == "function"
        then
            requested = TryFurnishingPreviewCall(
                "live-initial-native-legacy",
                GAMEPAD_INVENTORY.PreviewInventoryItem,
                GAMEPAD_INVENTORY,
                bagId,
                slotIndex
            )
        elseif type(previewObject.PreviewInventoryItem)
            == "function"
        then
            ClearPendingPreviewCollection(previewObject)
            requested = TryFurnishingPreviewCall(
                "live-initial-shared-legacy",
                previewObject.PreviewInventoryItem,
                previewObject,
                bagId,
                slotIndex
            )
        end
    end

    if requested then
        self.previewingFurnishingItemLink =
            item.itemLink
        self.previewingFurnishingItemKey = item.key
        self.previewingFurnishingBagId = bagId
        self.previewingFurnishingSlotIndex = slotIndex
        self.previewingFurnishingUsesItemLink =
            usedItemLink

        if wasPreviewActive then
            self.furnishingPreviewConfirmed = true
            self:RefreshItemKeybinds()
        elseif type(zo_callLater) == "function" then
            local requestedItemLink = item.itemLink

            zo_callLater(function()
                if BCO.previewingFurnishingItemLink
                    ~= requestedItemLink
                then
                    return
                end

                local nativeActive = false

                if type(IsCurrentlyPreviewing)
                    == "function"
                then
                    local ok, active = pcall(
                        IsCurrentlyPreviewing
                    )
                    nativeActive = ok and active == true
                else
                    nativeActive =
                        BCO.previewingFurnishingItemLink
                            ~= nil
                end

                if nativeActive then
                    BCO.furnishingPreviewConfirmed = true
                else
                    -- A low-level item-link preview can be accepted before the
                    -- gamepad preview scene is ready. Retry through any shared
                    -- object method that Update 50 exposes, then keep the mode
                    -- only if ESO confirms it.
                    local retried = false
                    local object = GetItemPreviewObject()

                    if usedItemLink
                        and object
                        and type(object.PreviewItemLink)
                            == "function"
                    then
                        retried = TryFurnishingPreviewCall(
                            "item-link-confirmation-retry",
                            object.PreviewItemLink,
                            object,
                            requestedItemLink,
                            0
                        )
                    end

                    if retried then
                        zo_callLater(function()
                            local retryActive = false

                            if type(IsCurrentlyPreviewing)
                                == "function"
                            then
                                local ok, active = pcall(
                                    IsCurrentlyPreviewing
                                )
                                retryActive = ok
                                    and active == true
                            end

                            if retryActive then
                                BCO.furnishingPreviewConfirmed = true
                            else
                                BCO.previewingFurnishingItemLink = nil
                                BCO.previewingFurnishingItemKey = nil
                                BCO.previewingFurnishingBagId = nil
                                BCO.previewingFurnishingSlotIndex = nil
                                BCO.previewingFurnishingUsesItemLink = nil
                                BCO.furnishingPreviewConfirmed = false
                                BCO:SetFurnishingPreviewBuffer(false)
                            end

                            BCO:RefreshItemKeybinds()
                        end, 100)
                        return
                    end

                    BCO.previewingFurnishingItemLink = nil
                    BCO.previewingFurnishingItemKey = nil
                    BCO.previewingFurnishingBagId = nil
                    BCO.previewingFurnishingSlotIndex = nil
                    BCO.previewingFurnishingUsesItemLink = nil
                    BCO.furnishingPreviewConfirmed = false
                    BCO:SetFurnishingPreviewBuffer(false)
                end

                BCO:RefreshItemKeybinds()
            end, 100)
        end
    end

    if not requested
        and not wasPreviewActive
        and previewBufferEnabled
    then
        self:SetFurnishingPreviewBuffer(false)
    end

    return requested
end

function BCO:EndFurnishingPreview()
    self.previewSelectionGeneration =
        self.previewSelectionGeneration + 1

    local hadActivePreview =
        self.previewingFurnishingItemLink ~= nil
        or self:IsFurnishingPreviewActive()

    -- Restore the shared preview object's default unbuffered behavior even
    -- after a failed or externally closed preview.
    self:SetFurnishingPreviewBuffer(false)

    if not hadActivePreview then
        return false
    end

    local endedNatively = false

    if GAMEPAD_INVENTORY
        and type(GAMEPAD_INVENTORY.EndPreview)
            == "function"
    then
        endedNatively = pcall(
            GAMEPAD_INVENTORY.EndPreview,
            GAMEPAD_INVENTORY
        )
    end

    if not endedNatively then
        local previewObject = GetItemPreviewObject()

        if previewObject
            and type(previewObject.ClearPreviewCollection)
                == "function"
        then
            pcall(
                previewObject.ClearPreviewCollection,
                previewObject
            )
        end

        if type(ApplyChangesToPreviewCollectionShown)
            == "function"
        then
            pcall(ApplyChangesToPreviewCollectionShown)
        end
    end

    self.previewingFurnishingItemLink = nil
    self.previewingFurnishingItemKey = nil
    self.previewingFurnishingBagId = nil
    self.previewingFurnishingSlotIndex = nil
    self.previewingFurnishingUsesItemLink = nil
    self.furnishingPreviewConfirmed = false
    self.lastFurnishingPreviewPath = "ended"

    return true
end

function BCO:UpdateActiveFurnishingPreview(selectedData)
    if not self:IsFurnishingPreviewActive() then
        return
    end

    local targetData = self.itemList
        and self.itemList:GetTargetData()
        or selectedData
    local settledData =
        self:GetSelectedItemData(targetData)
    local item = settledData
        and settledData.bcoItem

    if not item or not IsFurnishing(item) then
        return
    end

    local bagId, slotIndex =
        self:ResolveFurnishingPreviewSlot(settledData)

    self:PreviewFurnishing(
        item,
        bagId,
        slotIndex
    )
end

function BCO:ScheduleActiveFurnishingPreview(selectedData)
    if not self:IsFurnishingPreviewActive() then
        return
    end

    self.previewSelectionGeneration =
        self.previewSelectionGeneration + 1

    local generation =
        self.previewSelectionGeneration
    local settleMilliseconds =
        self.furnishingPreviewSettleMS or 90

    if type(zo_callLater) ~= "function" then
        self:UpdateActiveFurnishingPreview(selectedData)
        return
    end

    -- While a stick/d-pad is held, target callbacks arrive faster than a
    -- furnishing can be prepared. Keep the old model visible and request only
    -- the row where scrolling settles instead of flashing through every row.
    zo_callLater(function()
        if generation
                ~= BCO.previewSelectionGeneration
            or not BCO.active
            or not BCO:IsFurnishingPreviewActive()
        then
            return
        end

        BCO:UpdateActiveFurnishingPreview(
            selectedData
        )
    end, settleMilliseconds)
end

function BCO:HandleItemSelectionChanged(selectedData)
    if not self.active
        or not GAMEPAD_INVENTORY
        or GAMEPAD_INVENTORY:GetCurrentList()
            ~= self.itemList
    then
        return
    end

    local targetData = self.itemList
        and self.itemList:GetTargetData()
        or selectedData
    local settledData =
        self:GetSelectedItemData(targetData)

    if settledData and settledData.bcoItem then
        self.lastSelectedItemData = settledData
    end

    -- Keep BCO snapshot rows completely separate from ESO's native
    -- currentlySelectedData field. Native inventory events feed that field
    -- into the protected item-action controller even when the active list is
    -- a custom list.
    self.lastSelectedItemData = settledData

    self:ScheduleActiveFurnishingPreview(
        settledData
    )
    self:RefreshItemKeybinds()
    self:ScheduleItemTooltip(settledData)
end

function BCO:RefreshItemKeybinds()
    if not self.itemKeybinds then
        return
    end

    if KEYBIND_STRIP
        and type(KEYBIND_STRIP.UpdateKeybindButtonGroup)
            == "function"
    then
        pcall(
            KEYBIND_STRIP.UpdateKeybindButtonGroup,
            KEYBIND_STRIP,
            self.itemKeybinds
        )
    end
end

function BCO:ScheduleItemKeybindRefresh()
    self.itemKeybindRefreshGeneration =
        (self.itemKeybindRefreshGeneration or 0) + 1

    local generation =
        self.itemKeybindRefreshGeneration
    local delays = { 0, 50, 200 }

    for index = 1, #delays do
        zo_callLater(function()
            if generation
                    ~= BCO.itemKeybindRefreshGeneration
                or not BCO.active
                or not GAMEPAD_INVENTORY
                or GAMEPAD_INVENTORY:GetCurrentList()
                    ~= BCO.itemList
            then
                return
            end

            -- The first row is selected while the custom list is becoming
            -- active. On PS5 its target data can arrive after the keybind
            -- group was initially evaluated, so refresh it over the same
            -- short settling window used by the tooltip.
            BCO:RefreshItemKeybinds()
        end, delays[index])
    end
end

function BCO:CollapseLocationView(refreshTooltip)
    local wasExpanded = self.locationViewExpanded

    self.locationViewExpanded = false
    self.expandedLocationItemKey = nil

    if wasExpanded then
        SetLocationTooltipInputEnabled(false)
        self:RefreshItemKeybinds()
    end

    if refreshTooltip
        and self.active
        and GAMEPAD_INVENTORY
        and GAMEPAD_INVENTORY:GetCurrentList()
            == self.itemList
    then
        self:ScheduleItemTooltip(
            self.itemList:GetTargetData()
        )
    end
end

function BCO:SetLocationViewExpanded(
    expanded,
    selectedData
)
    local item = selectedData
        and selectedData.bcoItem

    if not item then
        return
    end

    if expanded
        and LocationCount(item)
            <= self.collapsedLocationRows
    then
        return
    end

    self.locationViewExpanded = expanded == true
    self.expandedLocationItemKey =
        self.locationViewExpanded
        and item.key
        or nil

    SetLocationTooltipInputEnabled(
        self.locationViewExpanded
    )

    self.tooltipRefreshGeneration =
        self.tooltipRefreshGeneration + 1

    self:UpdateItemTooltip(selectedData)
    self:RefreshItemKeybinds()
end

function BCO:RenderExpandedLocationTooltip(item)
    local locationText, locationCount =
        ExpandedLocationText(item)

    if locationCount == 0 then
        return false
    end

    if GAMEPAD_TOOLTIPS.ClearStatusLabel then
        pcall(
            GAMEPAD_TOOLTIPS.ClearStatusLabel,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP
        )
    end

    local rendered = false

    if GAMEPAD_TOOLTIPS.LayoutTitleAndDescriptionTooltip then
        rendered = pcall(
            GAMEPAD_TOOLTIPS.LayoutTitleAndDescriptionTooltip,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            "ITEM LOCATIONS",
            locationText
        )
    elseif GAMEPAD_TOOLTIPS.LayoutTextBlockTooltip then
        rendered = pcall(
            GAMEPAD_TOOLTIPS.LayoutTextBlockTooltip,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            "ITEM LOCATIONS\n\n" .. locationText
        )
    end

    if not rendered then
        local tooltipInfo =
            GAMEPAD_TOOLTIPS.tooltips
            and GAMEPAD_TOOLTIPS.tooltips[
                GAMEPAD_LEFT_TOOLTIP
            ]

        local tip = tooltipInfo
            and tooltipInfo.control
            and tooltipInfo.control.container
            and tooltipInfo.control.container.tip

        if tip
            and type(tip.LayoutTitleAndDescriptionTooltip)
                == "function"
        then
            rendered = pcall(
                tip.LayoutTitleAndDescriptionTooltip,
                tip,
                "ITEM LOCATIONS",
                locationText
            )
        elseif tip
            and tip.tooltip
            and type(
                tip.tooltip.LayoutTitleAndDescriptionTooltip
            ) == "function"
        then
            rendered = pcall(
                tip.tooltip.LayoutTitleAndDescriptionTooltip,
                tip.tooltip,
                "ITEM LOCATIONS",
                locationText
            )
        end
    end

    ForceTooltipControlVisible(
        GAMEPAD_LEFT_TOOLTIP
    )

    SetLocationTooltipInputEnabled(true)

    if GAMEPAD_TOOLTIPS.ResetScrollTooltipToTop then
        GAMEPAD_TOOLTIPS:ResetScrollTooltipToTop(
            GAMEPAD_LEFT_TOOLTIP
        )
    end

    return rendered
end

function BCO:UpdateItemTooltip(selectedData)
    if not GAMEPAD_TOOLTIPS then
        return false
    end

    GAMEPAD_TOOLTIPS:ClearTooltip(
        GAMEPAD_LEFT_TOOLTIP
    )
    GAMEPAD_TOOLTIPS:ClearTooltip(
        GAMEPAD_RIGHT_TOOLTIP
    )

    local item = selectedData and selectedData.bcoItem
    if not item
        or not item.itemLink
        or item.itemLink == ""
    then
        SetLocationTooltipInputEnabled(false)
        return false
    end

    if self.locationViewExpanded
        and self.expandedLocationItemKey ~= item.key
    then
        self:CollapseLocationView(false)
    end

    if self.locationViewExpanded then
        return self:RenderExpandedLocationTooltip(item)
    end

    if GAMEPAD_TOOLTIPS.ResetScrollTooltipToTop then
        GAMEPAD_TOOLTIPS:ResetScrollTooltipToTop(
            GAMEPAD_LEFT_TOOLTIP
        )
    end

    local rendered = false

    -- This is the item-link path used by gamepad loot and other screens
    -- where there is no live bag slot available.
    if GAMEPAD_TOOLTIPS.LayoutItemWithStackCount then
        rendered = pcall(
            GAMEPAD_TOOLTIPS.LayoutItemWithStackCount,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            item.itemLink,
            false,                 -- not equipped
            nil,                   -- no creator name
            true,                  -- full durability
            nil,                   -- no preview value
            item.totalCount or 1
        )
    end

    if not rendered
        and GAMEPAD_TOOLTIPS.LayoutItemLink
    then
        rendered = pcall(
            GAMEPAD_TOOLTIPS.LayoutItemLink,
            GAMEPAD_TOOLTIPS,
            GAMEPAD_LEFT_TOOLTIP,
            item.itemLink
        )
    end

    -- Console fallback: call the concrete tooltip control directly.
    if not rendered then
        local tooltipInfo =
            GAMEPAD_TOOLTIPS.tooltips
            and GAMEPAD_TOOLTIPS.tooltips[
                GAMEPAD_LEFT_TOOLTIP
            ]

        local tip = tooltipInfo
            and tooltipInfo.control
            and tooltipInfo.control.container
            and tooltipInfo.control.container.tip

        if tip and type(tip.LayoutItemLink) == "function" then
            rendered = pcall(
                tip.LayoutItemLink,
                tip,
                item.itemLink
            )
        elseif tip
            and tip.tooltip
            and type(tip.tooltip.LayoutItemLink) == "function"
        then
            rendered = pcall(
                tip.tooltip.LayoutItemLink,
                tip.tooltip,
                item.itemLink
            )
        end
    end

    ForceTooltipControlVisible(
        GAMEPAD_LEFT_TOOLTIP
    )

    -- Category mode and scene shutdown disable tooltip input. Item-link
    -- layout does not reliably enable it again on console, so explicitly
    -- restore the standard right-stick scroll handler for ordinary BCO item
    -- tooltips just as the Currencies and expanded Locations views do.
    SetLocationTooltipInputEnabled(true)

    local locationStatusText =
        LocationStatusText(item)

    if locationStatusText ~= ""
        and GAMEPAD_TOOLTIPS.SetStatusLabelText
    then
        GAMEPAD_TOOLTIPS:SetStatusLabelText(
            GAMEPAD_LEFT_TOOLTIP,
            locationStatusText,
            ""
        )
    end

    return rendered
end

function BCO:ScheduleItemTooltip(selectedData)
    self.tooltipRefreshGeneration =
        self.tooltipRefreshGeneration + 1

    local generation = self.tooltipRefreshGeneration
    local pendingData = selectedData
    local delays = { 0, 50, 200 }

    for index = 1, #delays do
        zo_callLater(function()
            if generation ~= BCO.tooltipRefreshGeneration
                or not BCO.active
                or not GAMEPAD_INVENTORY
                or GAMEPAD_INVENTORY:GetCurrentList()
                    ~= BCO.itemList
            then
                return
            end

            local currentData =
                BCO.itemList:GetTargetData()
                or pendingData

            BCO:UpdateItemTooltip(currentData)
        end, delays[index])
    end
end

function BCO:RefreshCategoryList(
    selectDefault,
    preferredCategoryKey
)
    local list = self.categoryList
    list:Clear()

    if not self.indexReady then
        local loading = ZO_GamepadEntryData:New(
            "Building account inventory...",
            nil
        )
        loading.bcoKey = "loading"
        loading.bcoLoading = true

        list:AddEntry(
            "ZO_GamepadItemEntryTemplate",
            loading
        )

        list:Commit()
        return
    end

    if self:GetInventoryFilterKey() == "storage"
        and not self:HasStorageSnapshots()
    then
        if list.SetNoItemText then
            list:SetNoItemText(
                "Open each housing storage container once to add it to All Inventories."
            )
        end

        list:Commit()
        return
    end

    local visibleCategories = {}

    for index = 1, #self.categories do
        local category = self.categories[index]

        if category.key == "currencies"
            or self.searchText == ""
            or self:CategoryHasSearchResult(
                category.key,
                self.searchText
            )
        then
            visibleCategories[
                #visibleCategories + 1
            ] = {
                category = category,
                originalIndex = index,
            }
        end
    end

    for visibleIndex = 1, #visibleCategories do
        local entry =
            visibleCategories[visibleIndex]
        local category = entry.category

        local data = ZO_GamepadEntryData:New(
            category.name,
            self.categoryIcons[category.key]
        )

        data.bcoKey = category.key
        data.bcoCurrencyEntry =
            category.key == "currencies"
        data.bcoCategoryIndex =
            entry.originalIndex
        data.bcoOfflineEntry = true
        data.overrideStatusIndicatorIcons = {}

        if data.SetIconTintOnSelection then
            data:SetIconTintOnSelection(true)
        end

        list:AddEntry(
            "ZO_GamepadItemEntryTemplate",
            data
        )
    end

    if list.SetNoItemText then
        if self.searchText ~= "" then
            list:SetNoItemText(
                "No saved items match this search."
            )
        else
            list:SetNoItemText(
                "No saved inventory data."
            )
        end
    end

    list:Commit()

    if selectDefault
        and list.SetSelectedIndexWithoutAnimation
        and #visibleCategories > 0
    then
        local selectedIndex = 1

        if preferredCategoryKey then
            for index = 1, #visibleCategories do
                if visibleCategories[index]
                    .category.key
                    == preferredCategoryKey
                then
                    selectedIndex = index
                    break
                end
            end
        end

        list:SetSelectedIndexWithoutAnimation(
            selectedIndex
        )
    end
end

function BCO:RefreshItemList(
    selectDefault,
    preferredItemKey
)
    self:CollapseLocationView(false)

    local list = self.itemList
    list:Clear()
    self.firstItemEntryData = nil

    local categoryData = self.categoryList:GetTargetData()

    self.selectedCategoryKey =
        categoryData
        and categoryData.bcoKey
        or self.selectedCategoryKey
        or "all"

    -- Save the selected title before the category list becomes inactive.
    -- On console, GetTargetData() is not guaranteed to remain available after
    -- switching to the dedicated item list.
    self.selectedCategoryName = "ALL INVENTORIES"

    for index = 1, #self.categories do
        local category = self.categories[index]

        if category.key == self.selectedCategoryKey then
            self.selectedCategoryName = category.name
            break
        end
    end

    if categoryData and categoryData.bcoCategoryIndex then
        self.savedVars.settings.categoryIndex =
            categoryData.bcoCategoryIndex
    end

    local items = self:FilterItems(
        self.selectedCategoryKey
    )

    local sectionedRows =
        BuildSectionedItemRows(
            items,
            self.selectedCategoryKey
        )
    local previousSectionName = nil

    for index = 1, #sectionedRows do
        local row = sectionedRows[index]
        local item = row.item

        local data = ZO_GamepadEntryData:New(
            item.name,
            item.icon
        )

        data.displayQuality =
            item.quality
            or ITEM_DISPLAY_QUALITY_NORMAL

        if data.SetNameColors
            and data.GetColorsBasedOnQuality
        then
            data:SetNameColors(
                data:GetColorsBasedOnQuality(
                    data.displayQuality
                )
            )
        elseif data.SetNameColors
            and GetItemQualityColor
        then
            local qualityColor =
                GetItemQualityColor(
                    data.displayQuality
                )

            data:SetNameColors(
                qualityColor,
                qualityColor
            )
        end

        data.bcoKey = item.key
        data.bcoItem = item
        data.bcoOfflineEntry = true
        data.itemLink = item.itemLink
        data.stackCount = item.totalCount
        data.overrideStatusIndicatorIcons = {}
        data.bestItemCategoryName =
            row.sectionName

        if index == 1 then
            self.firstItemEntryData = data
        end

        if row.sectionName ~= previousSectionName then
            previousSectionName =
                row.sectionName

            data:SetHeader(
                row.sectionName
            )

            list:AddEntry(
                "ZO_GamepadItemSubEntryTemplateWithHeader",
                data
            )
        else
            list:AddEntry(
                "ZO_GamepadItemSubEntryTemplate",
                data
            )
        end
    end

    if list.SetNoItemText then
        if self.searchText ~= "" then
            list:SetNoItemText(
                "No items in this category match the search."
            )
        elseif self:GetInventoryFilterKey() == "storage"
            and not self:HasStorageSnapshots()
        then
            list:SetNoItemText(
                "Open each housing storage container once to add it to All Inventories."
            )
        elseif self:GetInventoryFilterKey() == "storage" then
            list:SetNoItemText(
                "No saved storage items in this category."
            )
        else
            list:SetNoItemText(
                "No saved items in this category."
            )
        end
    end

    list:Commit()

    if selectDefault
        and list.SetSelectedIndexWithoutAnimation
        and #items > 0
    then
        local selectedIndex = 1

        if preferredItemKey then
            for index = 1, #sectionedRows do
                if sectionedRows[index].item.key
                    == preferredItemKey
                then
                    selectedIndex = index
                    break
                end
            end
        end

        list:SetSelectedIndexWithoutAnimation(
            selectedIndex
        )
    end

    local targetData = list:GetTargetData()
        or self.firstItemEntryData

    if targetData and targetData.bcoItem then
        self.lastSelectedItemData = targetData
    end
end

function BCO:RefreshActiveBCOList(selectDefault)
    if not self.active or not GAMEPAD_INVENTORY then
        return
    end

    local current = GAMEPAD_INVENTORY:GetCurrentList()

    if current == self.categoryList then
        self:RefreshCategoryList(selectDefault)
    elseif current == self.itemList then
        self:RefreshItemList(selectDefault)
    end
end

function BCO:RefreshBCOHeader(blockCallback)
    if not GAMEPAD_INVENTORY or not GAMEPAD_INVENTORY.header then
        return
    end

    local current = GAMEPAD_INVENTORY:GetCurrentList()
    local data

    if current == self.categoryList then
        data = self.categoryHeaderData
    elseif current == self.itemList then
        data = self.itemHeaderData
    else
        return
    end

    GAMEPAD_INVENTORY.headerData = data

    ZO_GamepadGenericHeader_Refresh(
        GAMEPAD_INVENTORY.header,
        data,
        blockCallback
    )

    -- GenericHeader rebuilds its tab list during every refresh and normally
    -- retains the previously selected native tab index. When BCO is restored
    -- after the Inventory scene reopens, that stale index can point at Craft
    -- Bag while BCO's title is already visible. Re-select BCO's own tab with
    -- callbacks blocked so the title text and divider pip remain in sync.
    if current == self.categoryList then
        self:SyncBCOTabSelection(data)
    end
end

function BCO:ActivateCategoryList(selectDefault)
    self:EndFurnishingPreview()
    self:CollapseLocationView(false)

    local inventory = GAMEPAD_INVENTORY

    self.searchText = self:ReadSearchText()
    if not inventory or not inventory.scene:IsShowing() then
        return
    end

    self.active = true

    if inventory:IsHeaderActive() then
        inventory:RequestLeaveHeader()
    end

    inventory.previousListType =
        inventory.currentListType
    inventory.currentListType =
        self.CATEGORY_DESCRIPTOR

    GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
    GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)

    inventory:SetCurrentList(self.categoryList)
    self:RefreshCategoryList(selectDefault)
    inventory:SetActiveKeybinds(
        self.categoryKeybinds
    )
    self:ApplyReadOnlyInventoryState(inventory)

    self:RefreshBCOHeader(true)
    inventory:ActivateHeader()

    self:UpdateCategoryTooltip(
        self.categoryList:GetTargetData()
    )
end

function BCO:ActivateItemList(selectDefault)
    self:CollapseLocationView(false)

    local categoryData = self.categoryList
        and self.categoryList:GetTargetData()

    if categoryData
        and categoryData.bcoKey == "currencies"
    then
        self:UpdateCategoryTooltip(categoryData)
        return
    end

    local inventory = GAMEPAD_INVENTORY
    if not inventory or not inventory.scene:IsShowing() then
        return
    end

    if inventory:IsHeaderActive() then
        inventory:RequestLeaveHeader()
    end

    inventory.previousListType =
        inventory.currentListType
    inventory.currentListType =
        self.ITEM_DESCRIPTOR

    GAMEPAD_TOOLTIPS:Reset(GAMEPAD_LEFT_TOOLTIP)
    GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)

    self:RefreshItemList(selectDefault)
    inventory:SetCurrentList(self.itemList)

    -- ESO clears its selected inventory data inside SetActiveKeybinds, so the
    -- first row must be assigned after the keybind group has been installed.
    inventory:SetActiveKeybinds(
        self.itemKeybinds
    )
    self:ApplyReadOnlyInventoryState(inventory)

    local selectedData =
        self.itemList:GetTargetData()
        or self.firstItemEntryData

    self.lastSelectedItemData = selectedData

    self:RefreshBCOHeader(true)
    inventory:DeactivateHeader()

    self:HandleItemSelectionChanged(selectedData)
    self:ScheduleItemKeybindRefresh()
end

function BCO:LeaveBCOMode(clearTooltips)
    self:EndFurnishingPreview()
    self:CollapseLocationView(false)
    self.active = false
    self.searchRefreshGeneration =
        self.searchRefreshGeneration + 1
    self.tooltipRefreshGeneration =
        self.tooltipRefreshGeneration + 1
    self.currencyTooltipGeneration =
        self.currencyTooltipGeneration + 1

    SetLocationTooltipInputEnabled(false)

    -- When ESO has already completed a native tab switch, its freshly drawn
    -- native tooltips must be preserved. Scene shutdown and direct BCO cleanup
    -- still use the default clearing behavior.
    if clearTooltips ~= false and GAMEPAD_TOOLTIPS then
        GAMEPAD_TOOLTIPS:ClearTooltip(
            GAMEPAD_LEFT_TOOLTIP
        )
        GAMEPAD_TOOLTIPS:ClearTooltip(
            GAMEPAD_RIGHT_TOOLTIP
        )
    end
end

function BCO:IsBCOListCurrent(inventory)
    inventory = inventory or GAMEPAD_INVENTORY

    if not self.active
        or not inventory
        or type(inventory.GetCurrentList) ~= "function"
    then
        return false
    end

    local current = inventory:GetCurrentList()

    return current == self.categoryList
        or current == self.itemList
end

function BCO:IsBCODescriptor(descriptor)
    return descriptor == self.CATEGORY_DESCRIPTOR
        or descriptor == self.ITEM_DESCRIPTOR
end

function BCO:PrepareForInventorySceneHide(inventory)
    inventory = inventory or GAMEPAD_INVENTORY

    if not inventory then
        return false
    end

    local current

    if type(inventory.GetCurrentList) == "function" then
        local ok, value = pcall(
            inventory.GetCurrentList,
            inventory
        )

        if ok then
            current = value
        end
    end

    local currentDescriptor =
        inventory.currentListType
    local previousDescriptor =
        inventory.previousListType

    local wasBCO = self.active
        or current == self.categoryList
        or current == self.itemList
        or self:IsBCODescriptor(
            currentDescriptor
        )
        or (
            currentDescriptor == nil
            and self:IsBCODescriptor(
                previousDescriptor
            )
        )

    if not wasBCO then
        return false
    end

    -- ESO remembers currentListType as previousListType while the scene hides
    -- and reuses that descriptor the next time Inventory opens. Its native
    -- SwitchActiveList only recognizes categoryList, itemList, and
    -- craftBagList, so persisting a BCO descriptor reopens an unactivated
    -- custom list with an empty All Inventories header.
    self.resumeBCOAfterSceneShow = true

    if self:IsBCODescriptor(
        inventory.previousListType
    ) then
        inventory.previousListType =
            self.NATIVE_CATEGORY_DESCRIPTOR
    end

    -- This also covers callback ordering where BCO receives SCENE_HIDING
    -- before ESO has called SwitchActiveList(nil). Leaving currentListType nil
    -- lets ESO reopen through its normal category-list path.
    if self:IsBCODescriptor(
        inventory.currentListType
    ) then
        inventory.currentListType = nil
        inventory.previousListType =
            self.NATIVE_CATEGORY_DESCRIPTOR
    end

    if self.active then
        self:LeaveBCOMode()
    else
        self:EndFurnishingPreview()
        self:CollapseLocationView(false)
    end

    return true
end

function BCO:ScheduleBCOSceneResume()
    if not self.installed
        or not self.resumeBCOAfterSceneShow
        or self.sceneResumeScheduled
    then
        return false
    end

    self.resumeBCOAfterSceneShow = false
    self.sceneResumeScheduled = true
    self.sceneResumeGeneration =
        self.sceneResumeGeneration + 1

    local generation =
        self.sceneResumeGeneration

    zo_callLater(function()
        if generation ~= BCO.sceneResumeGeneration then
            return
        end

        local inventory = GAMEPAD_INVENTORY
        local scene = inventory and inventory.scene

        if not scene or not scene:IsShowing() then
            BCO.sceneResumeScheduled = false
            BCO.resumeBCOAfterSceneShow = true
            return
        end

        BCO.sceneResumeScheduled = false

        -- ESO has now completed a normal, secure category-list activation.
        -- Re-enter BCO from that known native state rather than asking ESO to
        -- interpret the private BCO descriptor during OnStateChanged.
        BCO:ActivateCategoryList(true)
    end, 0)

    return true
end

function BCO:GetSafeNativeSelection(inventory)
    inventory = inventory or GAMEPAD_INVENTORY

    if not inventory then
        return nil
    end

    local categoryList = inventory.categoryList

    if categoryList
        and type(categoryList.GetTargetData) == "function"
    then
        local ok, data = pcall(
            categoryList.GetTargetData,
            categoryList
        )

        if ok and data and not data.bcoOfflineEntry then
            return data
        end
    end

    local currentData = inventory.currentlySelectedData

    if currentData and not currentData.bcoOfflineEntry then
        return currentData
    end

    -- ESO's currency-update callback expects currentlySelectedData to be a
    -- table while the Inventory scene is visible. This inert category-like
    -- placeholder is never exposed as a BCO row and produces no item actions.
    self.safeNativeSelection = self.safeNativeSelection or {
        isCurrencyEntry = false,
        bcoReadOnlyPlaceholder = true,
    }

    return self.safeNativeSelection
end

function BCO:ApplyReadOnlyInventoryState(inventory)
    inventory = inventory or GAMEPAD_INVENTORY

    if not inventory then
        return
    end

    -- Do not let a pending native action refresh run against a custom list.
    inventory.actionMode = self.READ_ONLY_ACTION_MODE
    inventory.updateItemActions = nil

    -- Keep ESO's field populated with genuine native category data rather
    -- than a BCO snapshot. Native currency/death/inventory events may pass
    -- this field back into SetSelectedInventoryData without checking the list
    -- descriptor first.
    inventory.currentlySelectedData =
        self:GetSafeNativeSelection(inventory)
end

function BCO:RestoreBCOTooltipsAfterNativeUpdate()
    if not self:IsBCOListCurrent() then
        return
    end

    local current = GAMEPAD_INVENTORY:GetCurrentList()

    if current == self.categoryList then
        self:UpdateCategoryTooltip(
            self.categoryList:GetTargetData()
        )
    elseif current == self.itemList then
        self:ScheduleItemTooltip(
            self.itemList:GetTargetData()
                or self.lastSelectedItemData
        )
    end
end

function BCO:RefreshCategoryKeybinds()
    if not self.categoryKeybinds then
        return
    end

    if KEYBIND_STRIP
        and type(KEYBIND_STRIP.UpdateKeybindButtonGroup)
            == "function"
    then
        pcall(
            KEYBIND_STRIP.UpdateKeybindButtonGroup,
            KEYBIND_STRIP,
            self.categoryKeybinds
        )
    end
end

function BCO:RefreshCurrentKeybinds()
    if not GAMEPAD_INVENTORY then
        return
    end

    local current =
        GAMEPAD_INVENTORY:GetCurrentList()

    if current == self.categoryList then
        self:RefreshCategoryKeybinds()
    elseif current == self.itemList then
        self:RefreshItemKeybinds()
    end
end

function BCO:CycleInventoryFilter()
    local filters = self.inventoryFilters

    if not filters or #filters == 0 then
        return
    end

    local inventory = GAMEPAD_INVENTORY
    local current = inventory
        and inventory:GetCurrentList()

    if current == self.categoryList then
        local currentData =
            self.categoryList:GetTargetData()

        if currentData
            and currentData.bcoKey == "currencies"
        then
            return
        end
    end

    self.inventoryFilterIndex =
        (self.inventoryFilterIndex % #filters) + 1

    self:CollapseLocationView(false)
    self.searchText = self:ReadSearchText()

    if current == self.categoryList then
        local selectedData =
            self.categoryList:GetTargetData()
        local preferredCategoryKey = selectedData
            and selectedData.bcoKey

        self:RefreshCategoryList(
            true,
            preferredCategoryKey
        )

        self:UpdateCategoryTooltip(
            self.categoryList:GetTargetData()
        )
    elseif current == self.itemList then
        local selectedData =
            self.itemList:GetTargetData()
        local preferredItemKey = selectedData
            and selectedData.bcoKey

        self:RefreshItemList(
            true,
            preferredItemKey
        )

        local refreshedData =
            self.itemList:GetTargetData()

        self.lastSelectedItemData = refreshedData

        self:ScheduleItemTooltip(
            refreshedData
        )
    end

    self:RefreshCurrentKeybinds()

    if SOUNDS and SOUNDS.DEFAULT_CLICK then
        PlaySound(SOUNDS.DEFAULT_CLICK)
    end
end

local function CreateInventoryFilterKeybind()
    return {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = function()
            return BCO:GetInventoryFilterKeybindName()
        end,
        keybind = "UI_SHORTCUT_SECONDARY",
        visible = function()
            if not GAMEPAD_INVENTORY
                or GAMEPAD_INVENTORY:GetCurrentList()
                    ~= BCO.categoryList
            then
                return true
            end

            local data = BCO.categoryList
                and BCO.categoryList:GetTargetData()

            return not data
                or data.bcoKey ~= "currencies"
        end,
        callback = function()
            BCO:CycleInventoryFilter()
        end,
    }
end

function BCO:InitializeKeybinds()
    self.categoryKeybinds = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,

        {
            name = GetString and
                GetString(SI_GAMEPAD_SELECT_OPTION) or
                "Select",
            keybind = "UI_SHORTCUT_PRIMARY",
            visible = function()
                local data =
                    BCO.categoryList:GetTargetData()

                return data ~= nil
                    and not data.bcoLoading
                    and data.bcoKey ~= "currencies"
            end,
            enabled = function()
                local data =
                    BCO.categoryList:GetTargetData()

                return data ~= nil
                    and not data.bcoLoading
                    and data.bcoKey ~= "currencies"
            end,
            callback = function()
                local data =
                    BCO.categoryList:GetTargetData()

                if not data
                    or data.bcoLoading
                    or data.bcoKey == "currencies"
                then
                    return
                end

                BCO:ActivateItemList(true)
                PlaySound(SOUNDS.GAMEPAD_MENU_FORWARD)
            end,
        },

        CreateInventoryFilterKeybind(),

        KEYBIND_STRIP:GetDefaultGamepadBackButtonDescriptor(),
    }

    self.itemKeybinds = {
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = GetString and
                GetString(SI_GAMEPAD_BACK_OPTION) or
                "Back",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function()
                BCO:ActivateCategoryList(false)
                PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
            end,
        },

        CreateInventoryFilterKeybind(),

        {
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
            name = function()
                if BCO:IsFurnishingPreviewActive() then
                    if GetString
                        and SI_PREVIEW_CLEAR_INVENTORY_PREVIEW
                    then
                        return GetString(
                            SI_PREVIEW_CLEAR_INVENTORY_PREVIEW
                        )
                    end

                    return "End Preview"
                end

                if GetString
                    and SI_CRAFTING_ENTER_PREVIEW_MODE
                then
                    return GetString(
                        SI_CRAFTING_ENTER_PREVIEW_MODE
                    )
                end

                return "Preview"
            end,
            keybind = "UI_SHORTCUT_QUATERNARY",
            order = 2500,
            disabledDuringSceneHiding = true,
            visible = function()
                if BCO:IsFurnishingPreviewActive() then
                    return true
                end

                local data =
                    BCO:GetSelectedItemData()

                return BCO:CanPreviewFurnishing(data)
            end,
            callback = function()
                if BCO:IsFurnishingPreviewActive() then
                    BCO:EndFurnishingPreview()
                else
                    local data =
                        BCO:GetSelectedItemData()
                    local item = data and data.bcoItem
                    local bagId, slotIndex =
                        BCO:ResolveFurnishingPreviewSlot(
                            data
                        )

                    BCO:PreviewFurnishing(
                        item,
                        bagId,
                        slotIndex
                    )
                end

                BCO:RefreshItemKeybinds()
            end,
        },

        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = function()
                return BCO.locationViewExpanded
                    and "Collapse Locations"
                    or "Show All Locations"
            end,
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                if not BCO.itemList then
                    return false
                end

                local data =
                    BCO.itemList:GetTargetData()
                local item = data and data.bcoItem

                return item ~= nil
                    and LocationCount(item)
                        > BCO.collapsedLocationRows
            end,
            callback = function()
                local data =
                    BCO.itemList:GetTargetData()

                if not data or not data.bcoItem then
                    return
                end

                local expanding =
                    not BCO.locationViewExpanded

                BCO:SetLocationViewExpanded(
                    expanding,
                    data
                )

                if SOUNDS then
                    PlaySound(
                        expanding
                        and SOUNDS.GAMEPAD_MENU_FORWARD
                        or SOUNDS.GAMEPAD_MENU_BACK
                    )
                end
            end,
        },
    }
end

local function EnsureThirdTab(headerData)
    if not headerData
        or type(headerData.tabBarEntries) ~= "table"
        or not BCO.thirdTabEntry
    then
        return false
    end

    local entries = headerData.tabBarEntries

    for index = 1, #entries do
        if entries[index].bcoAllInventories then
            -- Keep one stable callback object even if ESO rebuilt the table.
            entries[index] = BCO.thirdTabEntry
            return true
        end
    end

    entries[#entries + 1] = BCO.thirdTabEntry
    return true
end

function BCO:EnsureNativeTabs()
    local inventory = GAMEPAD_INVENTORY
    if not inventory then
        return false
    end

    local categoryReady =
        EnsureThirdTab(inventory.categoryHeaderData)
    local craftReady =
        EnsureThirdTab(inventory.craftBagHeaderData)

    if self.categoryHeaderData then
        self.categoryHeaderData.tabBarEntries =
            inventory.categoryHeaderData
            and inventory.categoryHeaderData.tabBarEntries
            or self.categoryHeaderData.tabBarEntries
    end

    return categoryReady or craftReady
end

function BCO:GetBCOTabIndex(headerData)
    local entries = headerData
        and headerData.tabBarEntries

    if type(entries) ~= "table" then
        return nil
    end

    local visibleIndex = 0

    for index = 1, #entries do
        local entry = entries[index]
        local visible = entry and entry.visible

        if type(visible) == "function" then
            local ok, value = pcall(visible)

            -- ESO itself calls visible() without arguments while rebuilding
            -- the header. If an unrelated tab visibility callback fails here,
            -- preserve the table order rather than shifting BCO's index.
            if ok then
                visible = value
            else
                visible = true
            end
        end

        if visible ~= false then
            visibleIndex = visibleIndex + 1

            if entry and entry.bcoAllInventories then
                return visibleIndex
            end
        end
    end

    return nil
end

function BCO:SyncBCOTabSelection(headerData)
    local inventory = GAMEPAD_INVENTORY

    if not inventory
        or not inventory.header
        or type(
            ZO_GamepadGenericHeader_SetActiveTabIndex
        ) ~= "function"
    then
        return false
    end

    local tabIndex = self:GetBCOTabIndex(
        headerData or self.categoryHeaderData
    )

    if not tabIndex then
        return false
    end

    local ok = pcall(
        ZO_GamepadGenericHeader_SetActiveTabIndex,
        inventory.header,
        tabIndex,
        true,
        true
    )

    return ok
end


function BCO:GetCurrentHeaderData()
    local inventory = GAMEPAD_INVENTORY
    if not inventory then
        return nil
    end

    local current = inventory:GetCurrentList()

    if current == self.categoryList then
        if self.categoryHeaderData then
            self.categoryHeaderData.tabBarEntries =
                inventory.categoryHeaderData
                and inventory.categoryHeaderData.tabBarEntries
                or self.categoryHeaderData.tabBarEntries
        end
        return self.categoryHeaderData
    elseif current == self.itemList then
        return self.itemHeaderData
    elseif current == inventory.craftBagList then
        return inventory.craftBagHeaderData
    elseif current == inventory.categoryList then
        return inventory.categoryHeaderData
    elseif current == inventory.itemList then
        return inventory.itemListHeaderData
    end

    return inventory.headerData
        or inventory.categoryHeaderData
end

function BCO:RedrawCurrentHeader()
    if self.refreshingHeader
        or not self.installed
        or not GAMEPAD_INVENTORY
        or not GAMEPAD_INVENTORY.header
        or not ZO_GamepadGenericHeader_Refresh
    then
        return false
    end

    local scene = GAMEPAD_INVENTORY.scene
    if not scene or not scene:IsShowing() then
        return false
    end

    self:EnsureNativeTabs()

    local headerData = self:GetCurrentHeaderData()
    if not headerData then
        return false
    end

    GAMEPAD_INVENTORY.headerData = headerData

    self.refreshingHeader = true

    local succeeded = pcall(
        ZO_GamepadGenericHeader_Refresh,
        GAMEPAD_INVENTORY.header,
        headerData,
        true
    )

    if succeeded
        and GAMEPAD_INVENTORY:GetCurrentList()
            == self.categoryList
    then
        self:SyncBCOTabSelection(headerData)
    end

    self.refreshingHeader = false
    return succeeded
end

function BCO:ScheduleHeaderRedraw()
    self.headerRefreshGeneration =
        self.headerRefreshGeneration + 1

    local generation = self.headerRefreshGeneration
    local delays = { 0, 50, 250 }

    for index = 1, #delays do
        zo_callLater(function()
            if generation ~= BCO.headerRefreshGeneration then
                return
            end

            BCO:RedrawCurrentHeader()
        end, delays[index])
    end
end


function BCO:SecureHookInventoryMethod(
    methodName,
    callback
)
    self.secureHookState =
        self.secureHookState or {}

    if self.secureHookState[methodName] then
        return true
    end

    local inventory = GAMEPAD_INVENTORY

    if not inventory
        or type(inventory[methodName]) ~= "function"
        or type(SecurePostHook) ~= "function"
    then
        return false
    end

    local ok = pcall(
        SecurePostHook,
        inventory,
        methodName,
        callback
    )

    if ok then
        self.secureHookState[methodName] = true
    end

    return ok
end

function BCO:InstallSecureInventoryHooks()
    local inventory = GAMEPAD_INVENTORY

    if not inventory then
        return false
    end

    -- RefreshHeader is called inside native list switches. A direct wrapper
    -- would make every downstream Use/Equip callback originate from addon
    -- code. SecurePostHook lets ESO finish the native method securely first.
    local headerHooked =
        self:SecureHookInventoryMethod(
            "RefreshHeader",
            function(inv, blockCallback)
                BCO:EnsureNativeTabs()

                if BCO:IsBCOListCurrent(inv) then
                    BCO:RefreshBCOHeader(
                        blockCallback
                    )
                else
                    BCO:ScheduleHeaderRedraw()
                end
            end
        )

    -- The original SwitchActiveList must remain untouched because it securely
    -- rebuilds the native item-action controller. BCO only cleans up after the
    -- completed switch.
    local switchHooked =
        self:SecureHookInventoryMethod(
            "SwitchActiveList",
            function(inv, listDescriptor)
                -- During SCENE_HIDING ESO calls SwitchActiveList(nil), copies
                -- currentListType into previousListType, and reuses it on the
                -- next SCENE_SHOWING. Replace BCO's private descriptor with a
                -- native one before that next activation.
                if listDescriptor == nil then
                    BCO:PrepareForInventorySceneHide(inv)
                    return
                end

                local current = inv:GetCurrentList()

                if current ~= BCO.categoryList
                    and current ~= BCO.itemList
                then
                    if BCO.active then
                        BCO:LeaveBCOMode(false)
                    end

                    if inv.currentlySelectedData
                        and inv.currentlySelectedData.bcoOfflineEntry
                    then
                        inv.currentlySelectedData =
                            BCO:GetSafeNativeSelection(inv)
                    end

                    BCO:EnsureNativeTabs()
                    BCO:ScheduleHeaderRedraw()
                end
            end
        )

    -- API builds have used both spellings. The native search refresh is safe
    -- to run first because native lists gate their rebuilds by list type; BCO
    -- then refreshes its own dedicated list from a secure post-hook.
    local searchMethodName

    if type(inventory.OnUpdatedSearchResults)
        == "function"
    then
        searchMethodName =
            "OnUpdatedSearchResults"
    elseif type(inventory.OnUpdateSearchResults)
        == "function"
    then
        searchMethodName =
            "OnUpdateSearchResults"
    end

    if searchMethodName then
        local searchHooked =
            self:SecureHookInventoryMethod(
                searchMethodName,
                function(_, ...)
                    if not BCO:IsBCOListCurrent() then
                        return
                    end

                    local firstArgument =
                        select(1, ...)

                    BCO:ScheduleSearchRefresh(
                        type(firstArgument) == "string"
                            and firstArgument
                            or nil
                    )
                end
            )

        if searchHooked then
            self.searchHookMethodName =
                searchMethodName
        end
    end

    -- Native update ticks can redraw the category tooltip while BCO uses its
    -- read-only action mode. Restore BCO's item-link/currency tooltip only
    -- after the native function has completed.
    if type(inventory.UpdateCategoryLeftTooltip)
        == "function"
    then
        self:SecureHookInventoryMethod(
            "UpdateCategoryLeftTooltip",
            function()
                BCO:RestoreBCOTooltipsAfterNativeUpdate()
            end
        )
    end

    if type(inventory.UpdateRightTooltip)
        == "function"
    then
        self:SecureHookInventoryMethod(
            "UpdateRightTooltip",
            function()
                if BCO:IsBCOListCurrent()
                    and GAMEPAD_TOOLTIPS
                then
                    GAMEPAD_TOOLTIPS:ClearTooltip(
                        GAMEPAD_RIGHT_TOOLTIP
                    )
                end
            end
        )
    end

    return headerHooked and switchHooked
end

function BCO:GetInstallReadiness()
    local inventory = GAMEPAD_INVENTORY

    if not inventory then
        return false, "GAMEPAD_INVENTORY=nil"
    elseif not inventory.categoryList then
        return false, "categoryList=nil"
    elseif not inventory.itemList then
        return false, "itemList=nil"
    elseif not inventory.craftBagList then
        return false, "craftBagList=nil"
    elseif type(inventory.AddList) ~= "function" then
        return false, "AddList=" .. type(inventory.AddList)
    elseif type(SecurePostHook) ~= "function" then
        return false, "SecurePostHook=" .. type(SecurePostHook)
    elseif type(inventory.SwitchActiveList) ~= "function" then
        return false, "SwitchActiveList=" .. type(inventory.SwitchActiveList)
    elseif type(inventory.RefreshHeader) ~= "function" then
        return false, "RefreshHeader=" .. type(inventory.RefreshHeader)
    elseif not inventory.categoryHeaderData then
        return false, "categoryHeaderData=nil"
    elseif not inventory.craftBagHeaderData then
        return false, "craftBagHeaderData=nil"
    end

    return true, "ready"
end

function BCO:Install()
    if self.installed then
        return true
    end

    self.installAttempts = self.installAttempts + 1

    local ready, status = self:GetInstallReadiness()
    self.lastInstallStatus = status

    if not ready then
        return false
    end

    local inventory = GAMEPAD_INVENTORY

    if not self:InstallSecureInventoryHooks() then
        self.lastInstallStatus =
            "Secure inventory hook installation failed"
        return false
    end

    self.categoryList = inventory:AddList(
        "BCOCategory",
        SetupCategoryList
    )

    self.itemList = inventory:AddList(
        "BCOItems",
        SetupItemList
    )

    if self.categoryList.SetNoItemText then
        self.categoryList:SetNoItemText(
            "No saved inventory data."
        )
    end

    if self.itemList.SetNoItemText then
        self.itemList:SetNoItemText(
            "No saved items in this category."
        )
    end

    self.categoryList:SetOnSelectedDataChangedCallback(
        function(first, second)
            local selectedData = second or first

            -- Category rows are read-only BCO data and must not be stored in
            -- ESO's native selected-inventory field.
            BCO:RefreshCategoryKeybinds()
            BCO:UpdateCategoryTooltip(
                selectedData
            )
        end
    )

    self.itemList:SetOnSelectedDataChangedCallback(
        function(first, second)
            local selectedData = BCO.itemList
                and BCO.itemList:GetTargetData()
                or second
                or first

            BCO:CollapseLocationView(false)
            BCO:HandleItemSelectionChanged(
                selectedData
            )
        end
    )

    self:InitializeKeybinds()

    self.thirdTabEntry = {
        text = "All Inventories",
        bcoAllInventories = true,
        callback = function()
            if BCO.refreshingHeader
                or BCO.resumeBCOAfterSceneShow
                or BCO.sceneResumeScheduled
            then
                return
            end

            if not BCO.active then
                BCO:ActivateCategoryList(true)
            end
        end,
    }

    self:EnsureNativeTabs()

    self.categoryHeaderData = {
        tabBarEntries =
            inventory.categoryHeaderData.tabBarEntries,
        titleText = function()
            return "ALL INVENTORIES"
        end,
    }

    self:EnsureNativeTabs()

    self.itemHeaderData = {
        titleText = function()
            return BCO.selectedCategoryName
                or "ALL INVENTORIES"
        end,
    }

    -- Native inventory methods are deliberately not replaced. Their secure
    -- execution context owns all Use/Equip/Move action construction; BCO is
    -- synchronized exclusively through the secure post-hooks installed above.

    self.installed = true

    if inventory.scene and inventory.scene:IsShowing() then
        self:EnsureNativeTabs()
        self:ScheduleHeaderRedraw()
    end

    self:StartIndexBuild(function()
        if BCO.active then
            BCO:RefreshActiveBCOList(true)
        end
    end)

    Msg("Loaded. Inventory now includes All Inventories.")
    return true
end

function BCO:TryInstallForOpenScene()
    if self.installed then
        self:EnsureNativeTabs()
        self:ScheduleHeaderRedraw()
        return true
    end

    local inventory = GAMEPAD_INVENTORY
    local scene = inventory and inventory.scene

    if not scene or not scene:IsShowing() then
        self.lastInstallStatus = "Inventory scene is not showing"
        return false
    end

    return self:Install()
end

function BCO:ScheduleSceneInstall()
    self.sceneInstallGeneration =
        self.sceneInstallGeneration + 1

    local generation = self.sceneInstallGeneration
    local delays = { 0, 50, 250, 500, 1000 }

    for index = 1, #delays do
        zo_callLater(function()
            if generation ~= BCO.sceneInstallGeneration
                or BCO.installed
            then
                return
            end

            BCO:TryInstallForOpenScene()
        end, delays[index])
    end
end

function BCO:InstallSceneWatcher()
    if self.sceneWatcherInstalled then
        return true
    end

    local scene =
        GAMEPAD_INVENTORY_ROOT_SCENE
        or (
            SCENE_MANAGER
            and SCENE_MANAGER:GetScene(
                "gamepad_inventory_root"
            )
        )

    if not scene then
        zo_callLater(function()
            BCO:InstallSceneWatcher()
        end, 500)
        return false
    end

    scene:RegisterCallback(
        "StateChange",
        function(_, newState)
            if newState == SCENE_SHOWING
                or newState == SCENE_SHOWN
            then
                BCO:ScheduleSceneInstall()

                if BCO.installed then
                    BCO:ScheduleHeaderRedraw()
                    BCO:ScheduleBCOSceneResume()
                end
            elseif newState == SCENE_HIDING then
                BCO:PrepareForInventorySceneHide()
            elseif newState == SCENE_HIDDEN then
                -- Run the normalization again for safety because scene
                -- callback order can differ between console UI builds.
                BCO:PrepareForInventorySceneHide()
                BCO.sceneInstallGeneration =
                    BCO.sceneInstallGeneration + 1
            end
        end
    )

    self.sceneWatcherInstalled = true

    if scene:IsShowing() then
        self:ScheduleSceneInstall()
    end

    return true
end

function BCO:Open()
    self:InstallSceneWatcher()
    SCENE_MANAGER:Show("gamepad_inventory_root")
    self:ScheduleSceneInstall()

    local generation = self.sceneInstallGeneration

    local function TryOpenBCO()
        if generation ~= BCO.sceneInstallGeneration then
            return
        end

        if BCO.installed then
            BCO:ActivateCategoryList(true)
            return
        end

        local inventory = GAMEPAD_INVENTORY
        if inventory
            and inventory.scene
            and inventory.scene:IsShowing()
        then
            zo_callLater(TryOpenBCO, 100)
        end
    end

    zo_callLater(TryOpenBCO, 100)
end

local function RegisterCommands()
    SLASH_COMMANDS = SLASH_COMMANDS or {}

    SLASH_COMMANDS["/bco"] = function()
        BCO:Open()
    end

    SLASH_COMMANDS["/bcorescan"] = function()
        BCO:ScanCurrentCharacter()
        Msg("Current character rescanned.")
    end

    SLASH_COMMANDS["/bcoclear"] = function()
        BCO.savedVars.characters = {}
        BCO.savedVars.shared = {
            bank = { items = {}, updated = 0 },
            storage = {},
            currencies = {
                bank = {},
                updated = 0,
            },
        }
        BCO.aggregatedItems = {}
        BCO.filteredItems = {}
        Msg("Saved inventory snapshots cleared.")
    end


    SLASH_COMMANDS["/bcostatus"] = function()
        local ready, status = BCO:GetInstallReadiness()
        local inventory = GAMEPAD_INVENTORY
        local categoryTabs =
            inventory
            and inventory.categoryHeaderData
            and inventory.categoryHeaderData.tabBarEntries
            and #inventory.categoryHeaderData.tabBarEntries
            or 0
        local craftTabs =
            inventory
            and inventory.craftBagHeaderData
            and inventory.craftBagHeaderData.tabBarEntries
            and #inventory.craftBagHeaderData.tabBarEntries
            or 0
        local liveTabs =
            inventory
            and inventory.headerData
            and inventory.headerData.tabBarEntries
            and #inventory.headerData.tabBarEntries
            or 0

        Msg(string.format(
            "Installed=%s Ready=%s Status=%s Attempts=%d Hooks H/S=%s/%s Search=%s Tabs C/F/L=%d/%d/%d",
            tostring(BCO.installed),
            tostring(ready),
            tostring(status or BCO.lastInstallStatus),
            BCO.installAttempts or 0,
            tostring(
                BCO.secureHookState
                and BCO.secureHookState.RefreshHeader
                or false
            ),
            tostring(
                BCO.secureHookState
                and BCO.secureHookState.SwitchActiveList
                or false
            ),
            tostring(BCO.searchHookMethodName or "none"),
            categoryTabs,
            craftTabs,
            liveTabs
        ))
    end

    SLASH_COMMANDS["/bcopreviewstatus"] = function()
        local selectedData = BCO:GetSelectedItemData()
        local item = selectedData and selectedData.bcoItem
        local bagId, slotIndex = nil, nil
        local furnitureEligible = false
        local genericEligible = false
        local previewObject = GetItemPreviewObject()

        if item then
            bagId, slotIndex =
                BCO:ResolveFurnishingPreviewSlot(selectedData)

            if type(CanItemLinkBePreviewedAsFurniture)
                == "function"
            then
                local ok, value = pcall(
                    CanItemLinkBePreviewedAsFurniture,
                    item.itemLink
                )
                furnitureEligible = ok and value == true
            end

            if type(CanItemLinkBePreviewed) == "function" then
                local ok, value = pcall(
                    CanItemLinkBePreviewed,
                    item.itemLink
                )
                genericEligible = ok and value == true
            end
        end

        Msg(string.format(
            "Preview active=%s path=%s liveSlot=%s/%s linkAPI=%s sharedLink=%s furnitureCheck=%s genericCheck=%s error=%s",
            tostring(BCO:IsFurnishingPreviewActive()),
            tostring(BCO.lastFurnishingPreviewPath or "none"),
            tostring(bagId),
            tostring(slotIndex),
            tostring(type(PreviewItemLink) == "function"),
            tostring(
                previewObject
                and type(previewObject.PreviewItemLink)
                    == "function"
            ),
            tostring(furnitureEligible),
            tostring(genericEligible),
            tostring(BCO.lastFurnishingPreviewError or "none")
        ))
    end

    SLASH_COMMANDS["/bcosnapshots"] = function()
        local rows = {}
        local totalCharacters = 0

        for _, character in pairs(
            BCO.savedVars.characters or {}
        ) do
            totalCharacters = totalCharacters + 1
            rows[#rows + 1] = {
                name = character.name
                    or "Unknown Character",
                backpack = #(character.backpack or {}),
                worn = #(character.worn or {}),
                hasCurrencies =
                    type(character.currencies) == "table",
                updated = character.updated or 0,
            }
        end

        table.sort(rows, function(left, right)
            return Lower(left.name) < Lower(right.name)
        end)

        local storageRows = {}

        for storageKey, storage in pairs(
            BCO.savedVars.shared.storage or {}
        ) do
            storageRows[#storageRows + 1] = {
                name = storage.name
                    or "Housing Storage",
                items = #(storage.items or {}),
                updated = storage.updated or 0,
                key = storageKey,
            }
        end

        table.sort(storageRows, function(left, right)
            return Lower(left.name) < Lower(right.name)
        end)

        Msg(string.format(
            "Saved characters=%d Bank=%d Storage=%d CurrencyBank=%s",
            totalCharacters,
            #(
                BCO.savedVars.shared.bank.items
                or {}
            ),
            #storageRows,
            tostring(
                BCO.savedVars.shared.currencies
                    ~= nil
            )
        ))

        for index = 1, #rows do
            local row = rows[index]

            Msg(string.format(
                "%s backpack=%d worn=%d currencies=%s updated=%d",
                row.name,
                row.backpack,
                row.worn,
                tostring(row.hasCurrencies),
                row.updated
            ))
        end

        for index = 1, #storageRows do
            local row = storageRows[index]

            Msg(string.format(
                "%s items=%d updated=%d",
                row.name,
                row.items,
                row.updated
            ))
        end
    end

end

local function OnCurrencyUpdate()
    BCO:ScanCurrentCurrencies()

    if BCO.active
        and GAMEPAD_INVENTORY
        and GAMEPAD_INVENTORY:GetCurrentList()
            == BCO.categoryList
    then
        local selectedData =
            BCO.categoryList:GetTargetData()

        if selectedData
            and selectedData.bcoKey == "currencies"
        then
            BCO:ScheduleCurrencyTooltip(
                selectedData
            )
        end
    end
end

local function OnInventoryUpdate(_, bagId)
    local openBankBag = BCO.activeBankBag
    local isOpenBankUpdate = false

    if BCO.bankOpen then
        if openBankBag == BAG_BANK then
            isOpenBankUpdate = bagId == BAG_BANK
                or bagId == BAG_SUBSCRIBER_BANK
        elseif openBankBag ~= nil then
            isOpenBankUpdate = bagId == openBankBag
        end
    end

    if bagId == BAG_BACKPACK
        or bagId == BAG_WORN
        or isOpenBankUpdate
    then
        BCO:ScheduleScan()
    end
end

local function OnBankOpen(_, bankBag)
    BCO.bankOpen = true
    BCO.activeBankBag = bankBag

    if BCO.activeBankBag == nil
        and type(GetBankingBag) == "function"
    then
        local ok, currentBagId = pcall(GetBankingBag)

        if ok then
            BCO.activeBankBag = currentBagId
        end
    end

    local expectedBag = BCO.activeBankBag

    zo_callLater(function()
        if BCO.bankOpen
            and BCO.activeBankBag == expectedBag
        then
            BCO:ScanCurrentCharacter()
        end
    end, 350)
end

local function OnBankClose()
    BCO.bankOpen = false
    BCO.activeBankBag = nil
end

local function OnPlayerActivated()
    BCO:InstallSceneWatcher()

    -- Run once shortly after activation and once again after the inventory
    -- has fully settled on slower console loads.
    zo_callLater(function()
        BCO:ScanCurrentCharacter()
    end, 300)

    zo_callLater(function()
        BCO:ScanCurrentCharacter()
    end, 1500)
end

local function OnPlayerDeactivated()
    -- SavedVariables are written as the character unloads. Capture the
    -- current bags synchronously so the next character can see them.
    BCO.scanPending = false
    BCO:ScanCurrentCharacter(false)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= BCO.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(
        BCO.name,
        EVENT_ADD_ON_LOADED
    )

    BCO.savedVars = ZO_SavedVars:NewAccountWide(
        "BetterCharacterOverviewSavedVariables",
        BCO.savedVarVersion,
        nil,
        BCO.defaults
    )

    -- All Inventories intentionally excludes the account-wide Craft Bag.
    -- Remove any snapshot left by an older version so it is not retained in
    -- SavedVariables or accidentally reintroduced into the combined index.
    BCO.savedVars.shared = BCO.savedVars.shared or {}
    BCO.savedVars.shared.bank = BCO.savedVars.shared.bank or {
        items = {},
        updated = 0,
    }
    BCO.savedVars.shared.storage =
        BCO.savedVars.shared.storage or {}
    BCO.savedVars.shared.currencies =
        BCO.savedVars.shared.currencies or {
            bank = {},
            updated = 0,
        }
    BCO.savedVars.shared.currencies.bank =
        BCO.savedVars.shared.currencies.bank or {}
    BCO.savedVars.shared.craftBag = nil

    RegisterCommands()

    EVENT_MANAGER:RegisterForEvent(
        BCO.name,
        EVENT_PLAYER_ACTIVATED,
        OnPlayerActivated
    )


    EVENT_MANAGER:RegisterForEvent(
        BCO.name,
        EVENT_PLAYER_DEACTIVATED,
        OnPlayerDeactivated
    )

    EVENT_MANAGER:RegisterForEvent(
        BCO.name,
        EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        OnInventoryUpdate
    )

    if EVENT_CURRENCY_UPDATE then
        EVENT_MANAGER:RegisterForEvent(
            BCO.name,
            EVENT_CURRENCY_UPDATE,
            OnCurrencyUpdate
        )
    end

    if EVENT_CURRENCY_CAPS_CHANGED then
        EVENT_MANAGER:RegisterForEvent(
            BCO.name,
            EVENT_CURRENCY_CAPS_CHANGED,
            OnCurrencyUpdate
        )
    end

    EVENT_MANAGER:RegisterForEvent(
        BCO.name,
        EVENT_INVENTORY_FULL_UPDATE,
        function()
            BCO:ScheduleScan()
        end
    )

    if EVENT_OPEN_BANK then
        EVENT_MANAGER:RegisterForEvent(
            BCO.name,
            EVENT_OPEN_BANK,
            OnBankOpen
        )
    end

    if EVENT_CLOSE_BANK then
        EVENT_MANAGER:RegisterForEvent(
            BCO.name,
            EVENT_CLOSE_BANK,
            OnBankClose
        )
    end
end

EVENT_MANAGER:RegisterForEvent(
    BCO.name,
    EVENT_ADD_ON_LOADED,
    OnAddOnLoaded
)
