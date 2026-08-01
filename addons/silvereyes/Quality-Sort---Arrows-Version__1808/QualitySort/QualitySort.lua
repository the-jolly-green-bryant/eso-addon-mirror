-- A very special thanks to merlight for the research done to make this possible!

QUALITYSORT_INVENTORY_QUICKSLOT  = 100
QUALITYSORT_CRAFTING_DECON       = 200
QUALITYSORT_CRAFTING_ENCHANTING  = 201
QUALITYSORT_CRAFTING_IMPROVEMENT = 202
QUALITYSORT_CRAFTING_REFINEMENT  = 203
QUALITYSORT_CRAFTING_RETRAIT     = 204
QUALITYSORT_COMPANION            = 205
QUALITYSORT_UNIVERSAL_DECON      = 206

QUALITYSORT_DIR_DESC = 1
QUALITYSORT_DIR_ASC  = 2

QualitySort = {
    name    = "QualitySort",
    version = "2.6.0",
    title   = "Quality Sort",
    author  = "silvereyes & Randactyl",
    sortOrders = {
        ["enchantment"] = GetString(SI_ITEM_FORMAT_STR_AUGMENT_ITEM_TYPE),
        ["equipped"]    = GetString(SI_ITEM_FORMAT_STR_EQUIPPED),
        ["id"]          = GetString(SI_QUALITYSORT_ID),
        ["level"]       = GetString(SI_QUALITYSORT_LEVEL),
        ["masterWrit"]  = GetString(SI_QUALITYSORT_MASTER_WRIT),
        ["name"]        = GetString(SI_TRADINGHOUSEFEATURECATEGORY0),
        ["quality"]     = GetString(SI_MASTER_WRIT_DESCRIPTION_QUALITY),
        ["quantity"]    = GetString(SI_CRAFTING_QUANTITY_HEADER),
        ["set"]         = GetString(SI_QUALITYSORT_SET),
        ["slot"]        = GetString(SI_QUALITYSORT_EQUIP_SLOT),
        ["style"]       = GetString(SI_SMITHING_HEADER_STYLE),
        ["trait"]       = GetString(SI_SMITHING_HEADER_TRAIT),
        ["vouchers"]    = GetString(SI_QUALITYSORT_VOUCHERS),
    },
    defaults = {
        automatic = true,
        sortOrder = {
            "quality",
            "equipped",
            "set",
            "slot",
            "name",
            "level",
            "trait",
            "enchantment",
            "style",
            "id",
            "vouchers",
            "masterWrit",
            "quantity",
        },
        sortDirection = {
            ["enchantment"] = QUALITYSORT_DIR_ASC,
            ["equipped"]    = QUALITYSORT_DIR_ASC,
            ["id"]          = QUALITYSORT_DIR_ASC,
            ["level"]       = QUALITYSORT_DIR_ASC,
            ["masterWrit"]  = QUALITYSORT_DIR_ASC,
            ["name"]        = QUALITYSORT_DIR_ASC,
            ["quality"]     = QUALITYSORT_DIR_DESC,
            ["quantity"]    = QUALITYSORT_DIR_DESC,
            ["set"]         = QUALITYSORT_DIR_ASC,
            ["slot"]        = QUALITYSORT_DIR_ASC,
            ["style"]       = QUALITYSORT_DIR_ASC,
            ["trait"]       = QUALITYSORT_DIR_ASC,
            ["vouchers"]    = QUALITYSORT_DIR_ASC,
        },
    },
    sortByControls = {
        [ZO_PlayerInventorySortBy]                                      = { INVENTORY_BACKPACK, INVENTORY_QUEST_ITEM },
        [ZO_PlayerBankSortBy]                                           = INVENTORY_BANK,
        [ZO_GuildBankSortBy]                                            = INVENTORY_GUILD_BANK,
        [ZO_CraftBagSortBy]                                             = INVENTORY_CRAFT_BAG,
        [ZO_HouseBankSortBy]                                            = INVENTORY_HOUSE_BANK,
        [ZO_QuickSlotSortBy or ZO_QuickSlot_Keyboard_TopLevelSortBy]    = QUALITYSORT_INVENTORY_QUICKSLOT,
        [ZO_SmithingTopLevelDeconstructionPanelInventorySortBy]         = QUALITYSORT_CRAFTING_DECON,
        [ZO_EnchantingTopLevelInventorySortBy]                          = QUALITYSORT_CRAFTING_ENCHANTING,
        [ZO_SmithingTopLevelImprovementPanelInventorySortBy]            = QUALITYSORT_CRAFTING_IMPROVEMENT,
        [ZO_SmithingTopLevelRefinementPanelInventorySortBy]             = QUALITYSORT_CRAFTING_REFINEMENT,
        [ZO_RetraitStation_KeyboardTopLevelRetraitPanelInventorySortBy] = QUALITYSORT_CRAFTING_RETRAIT,
        [ZO_CompanionEquipment_Panel_KeyboardSortBy]                    = QUALITYSORT_COMPANION,
        [UNIVERSAL_DECONSTRUCTION.deconstructionPanelControl:GetNamedChild("Inventory"):GetNamedChild("SortBy")] = QUALITYSORT_UNIVERSAL_DECON,
    },
    sortByControlOwners = {},
    debugMode = false
}

local addon = QualitySort

function addon:Debug(text)
    if not self.debugMode then
        return
    end
    d("QualitySort " .. text)
end

QualitySort.extendedDataCache = {}
local extendedDataCache = QualitySort.extendedDataCache
local comparisonFunctions = { }
local function GetExtendedData(data)
    local uniqueId = zo_getSafeId64Key(data.uniqueId or GetItemUniqueId(data.bagId, data.slotIndex))
    if extendedDataCache[uniqueId] then
        return extendedDataCache[uniqueId]
    end
    local extendedData = { 
        uniqueId = uniqueId,
        bagId = data.bagId, 
        slotIndex = data.slotIndex,
    }
    local link = GetItemLink(extendedData.bagId, extendedData.slotIndex)
    local _, _, _, itemId, _, _, 
          enchantType, enchantSubType, enchantLevel, writ1, writ2, writ3, writ4, writ5, writ6, 
          itemStyle, _, _, _, charges, _, _, _, vouchers = ZO_LinkHandler_ParseLink(link)
    extendedData.itemId = tonumber(itemId)
    extendedData.link = link
    extendedData.championRank = GetItemLinkRequiredChampionPoints(link)
    extendedData.traitInfo = GetItemLinkTraitInfo(link)
    extendedData.itemStyle = GetItemLinkItemStyle(link)
    extendedData.equipType = GetItemLinkEquipType(link)
    local _, setName, _, _, _, setId = GetItemLinkSetInfo(link)
    extendedData.setId = setId
    extendedData.setName = setName
    if charges and tonumber(charges) > 0 then
        extendedData.enchantment = {
            charges = tonumber(charges),
            type = tonumber(enchantType),
            subType = tonumber(enchantSubType),
            level = tonumber(enchantLevel),
        }
    end
    if data.itemType == ITEMTYPE_MASTER_WRIT and vouchers then
        extendedData.masterWrit = {
            writ1 = tonumber(writ1), 
            writ2 = tonumber(writ2), 
            writ3 = tonumber(writ3), 
            writ4 = tonumber(writ4), 
            writ5 = tonumber(writ5), 
            writ6 = tonumber(writ6),
            vouchers = math.max(2, tonumber(string.format("%.0f", tonumber(vouchers)/10000)))
        }
        -- remosito additions to sort by set station name
        local snam
        if extendedData.masterWrit.writ3 == 0 then -- its a provisioning master writ
          snam = "_Prov"
        elseif extendedData.masterWrit.writ4 == 0 then -- its an enchanting master writ
          snam = "_Ench"
        elseif extendedData.masterWrit.writ5 == 0 then -- its an alchemy master writ
          snam = "_Alch"
        else -- bs/cl/ww/jc master writ
          if not LibSets or not LibSets.checkIfSetsAreLoadedProperly() then -- safety measure in case libset has not finished scanning and loading set info
            snam = "_libsets not yet ready"
          else
            snam = LibSets.GetSetName(extendedData.masterWrit.writ4)  -- get set name
            if snam == nil then -- in case sth went wrong and we get nil back..shouldn't happen
              snam = "_unknown"
            end
          end
        end
        extendedData.masterWrit.writ4 = snam  -- overwrite writ4 with set/station name
    end
    if uniqueId ~= nil then
        extendedDataCache[uniqueId] = extendedData
    end
    return extendedData
end
local function NilOrLessThan(value1, value2)
    if value1 == nil then
        return true
    elseif value2 == nil then
        return false
    else
        return value1 < value2
    end
end
local function NilOrLessThanId64(value1, value2)
    if value1 == nil then
        return true
    elseif value2 == nil then
        return false
    else
        return CompareId64s(value1, value2) == IS_LESS_THAN
    end
end
function comparisonFunctions.enchantment(item1, extData1, item2, extData2)
    if extData1.enchantment == extData2.enchantment then
        return
    end
    local enchant1 = extData1.enchantment
    local enchant2 = extData2.enchantment
    if enchant1 == nil then
        return true
    elseif enchant2 == nil then
        return false
    elseif enchant1.type ~= enchant2.type then
        return NilOrLessThan(enchant1.type, enchant2.type)
    elseif enchant1.subType ~= enchant2.subType then
        return NilOrLessThan(enchant1.subType, enchant2.subType)
    else
        return NilOrLessThan(enchant1.charges, enchant2.charges)
    end
end
function comparisonFunctions.equipped(item1, extData1, item2, extData2)
    if item1.bagId ~= item2.bagId then
        if item1.bagId == BAG_WORN then
            return true
        elseif item2.bagId == BAG_WORN then
            return false
        end
    end
end
function comparisonFunctions.id(item1, extData1, item2, extData2)
    if extData1.itemId ~= extData2.itemId then
        return NilOrLessThan(extData1.itemId, extData2.itemId)
    end
end
function comparisonFunctions.level(item1, extData1, item2, extData2)
    if item1.requiredLevel ~= item2.requiredLevel then
        return NilOrLessThan(item1.requiredLevel, item2.requiredLevel)
    end
    if extData1.championRank ~= extData2.championRank then
        return NilOrLessThan(extData1.championRank, extData2.championRank)
    end
end
function comparisonFunctions.masterWrit(item1, extData1, item2, extData2)
    if extData1.masterWrit == nil or extData2.masterWrit == nil then
        return
    end
    local data1 = extData1.masterWrit
    local data2 = extData2.masterWrit
    if data1.writ4 ~= data2.writ4 then
        return NilOrLessThan(data1.writ4, data2.writ4)
    elseif data1.writ2 ~= data2.writ2 then
        return NilOrLessThan(data1.writ2, data2.writ2)
    elseif data1.writ3 ~= data2.writ3 then
        return NilOrLessThan(data1.writ3, data2.writ3)
    elseif data1.writ1 ~= data2.writ1 then
        return NilOrLessThan(data1.writ1, data2.writ1)
    elseif data1.writ5 ~= data2.writ5 then
        return NilOrLessThan(data1.writ5, data2.writ5)
    else
        return NilOrLessThan(data1.writ6, data2.writ6)
    end
end
function comparisonFunctions.name(item1, extData1, item2, extData2)
    if item1.name ~= item2.name then
        return NilOrLessThan(item1.name, item2.name)
    end
end
function comparisonFunctions.quality(item1, extData1, item2, extData2)
    if item1.quality ~= item2.quality then
        return NilOrLessThan(item1.functionalQuality, item2.functionalQuality)
    end
end
function comparisonFunctions.quantity(item1, extData1, item2, extData2)
    if item1.stackCount ~= item2.stackCount then
        return NilOrLessThan(item1.stackCount, item2.stackCount)
    end
end
function comparisonFunctions.set(item1, extData1, item2, extData2)
    if extData1.setId ~= extData2.setId then
        return NilOrLessThan(extData1.setName, extData2.setName)
    end
end
function comparisonFunctions.slot(item1, extData1, item2, extData2)
    if extData1.equipType ~= extData2.equipType then
        return NilOrLessThan(extData1.equipType, extData2.equipType)
    end
end
function comparisonFunctions.style(item1, extData1, item2, extData2)
    if extData1.itemStyle ~= extData2.itemStyle then
        return NilOrLessThan(extData1.itemStyle, extData2.itemStyle)
    end
end
function comparisonFunctions.trait(item1, extData1, item2, extData2)
    if extData1.traitInfo ~= extData2.traitInfo then
        return NilOrLessThan(extData1.traitInfo, extData2.traitInfo)
    end
end
function comparisonFunctions.vouchers(item1, extData1, item2, extData2)
    if extData1.masterWrit == nil or extData2.masterWrit == nil then
        return
    end
    if extData1.masterWrit.vouchers ~= extData2.masterWrit.vouchers then
        return NilOrLessThan(extData1.masterWrit.vouchers, extData2.masterWrit.vouchers)
    end
end

function QualitySort.orderByItemQuality(entry1, entry2, sortKey, sortKeys, sortOrder)
  
    local self = QualitySort
    
    if sortOrder ~= ZO_SORT_ORDER_UP then
        local swp = entry1
        entry1 = entry2
        entry2 = swp
    end
    
    if entry1.questIndex or entry2.questIndex then
        return NilOrLessThan(entry1.name, entry2.name)
    end
    
    -- Get extended data for the two data slots
    local extData1 = GetExtendedData(entry1)
    local extData2 = GetExtendedData(entry2)
    
    -- Perform comparisons in the configured sort order
    for optionIndex, option in ipairs(self.settings.sortOrder) do
        local compare = comparisonFunctions[option]
        if compare then
            local result
            if self.settings.sortDirection[self.settings.sortOrder[optionIndex]] == QUALITYSORT_DIR_ASC then
                result = compare(entry1, extData1, entry2, extData2)
            else
                result = compare(entry2, extData2, entry1, extData1)
            end
            if result ~= nil then
                self:Debug(option .. " compare " .. extData1.link .. " to " .. extData2.link .. ": " .. tostring(result))
                return result
            end
        end
    end
    
    -- And finally, sort by item unique id, to make sure relative order stays the same on update
    return NilOrLessThanId64(extData1.uniqueId, extData2.uniqueId)
end
local function Prehook_NameHeader_SetWidth(nameHeader, width)
    return true
end
local function Prehook_TableOrderingFunction()
    local self = QualitySort
    local originalTableOrderingFunction = ZO_TableOrderingFunction
    ZO_TableOrderingFunction = function(entry1, entry2, sortKey, sortKeys, sortOrder)
        if sortKey == "quality" then
            if sortKeys["quality"] == nil then
                sortKeys["quality"] = {}
            end
            return self.orderByItemQuality(entry1, entry2, sortKey, sortKeys, sortOrder)
        end
        return originalTableOrderingFunction(entry1, entry2, sortKey, sortKeys, sortOrder)
    end
end
local function GetBagIdForInventoryType(inventoryType)
    for bagId, bagInventoryType in pairs(PLAYER_INVENTORY.bagToInventoryType) do
        if inventoryType == bagInventoryType then
            return bagId
        end
    end
end
local function GetSortHeaders(sortByControl)
    local self = QualitySort
    if self.sortByControlOwners[sortByControl] then
        return self.sortByControlOwners[sortByControl].sortHeaders
    end
    local flag = self.sortByControls[sortByControl]
    if type(flag) == "table" then
        flag = flag[1]
    end
    local inventory = PLAYER_INVENTORY.inventories[flag]
    if inventory then
        return inventory.sortHeaders
    end
    local controlName = sortByControl:GetName()
    inventory = sortByControl:GetParent()
    local owner = inventory.owner
    return owner.sortHeaders
end
local function PurgeCacheForInventoryType(inventoryManager, inventoryType)
    if inventoryType == INVENTORY_QUEST_ITEM then return end
    local bagId = GetBagIdForInventoryType(inventoryType)
    if not bagId then return end
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId)
    local itemsToPurge = {}
    for uniqueId, extendedData in pairs(extendedDataCache) do
        local slotData = bagCache[extendedData.slotIndex]
        if not slotData or zo_getSafeId64Key(slotData.uniqueId) ~= uniqueId then
            table.insert(itemsToPurge, uniqueId)
        end
    end
    for i=1, #itemsToPurge do
        extendedDataCache[itemsToPurge[i]] = nil
    end
end
local function OnSortByControlEffectivelyShown(sortByControl)
    local self = QualitySort
    local qualityHeader = GetControl(sortByControl, "Quality")
    if self.settings.automatic then
        zo_callLater(function()
                         local sortHeaders = GetSortHeaders(sortByControl)
                         sortHeaders:OnHeaderClicked(qualityHeader, false, false, qualityHeader.initialDirection)
                     end, 20)
    end
end
function QualitySort.addSortByQuality(flags, sortByControl)
  
    local self = QualitySort
  
    local nameHeader = sortByControl:GetNamedChild("Name")
    local qualityHeader = CreateControlFromVirtual("$(parent)Quality", sortByControl, "ZO_SortHeaderIcon")

    qualityHeader:SetAnchor(RIGHT, nameHeader, LEFT, -35, 0)
    qualityHeader:SetDimensions(16, 32)
    
    ZO_SortHeader_InitializeArrowHeader(qualityHeader, "quality", ZO_SORT_ORDER_UP) 
    ZO_SortHeader_SetTooltip(qualityHeader, GetString(SI_MASTER_WRIT_DESCRIPTION_QUALITY), BOTTOMRIGHT, 0, 32)
    
    GetSortHeaders(sortByControl):AddHeader(qualityHeader)
    
    ZO_PreHookHandler(sortByControl, "OnEffectivelyShown", OnSortByControlEffectivelyShown)
end


function QualitySort.printVersion()
    local self = QualitySort
    d(self.name.." version "..self.version)
end

function QualitySort.onAddonLoaded(eventCode, addonName)
    local self = QualitySort
    if addonName ~= self.name then return end

    EVENT_MANAGER:UnregisterForEvent("QualitySort", EVENT_ADD_ON_LOADED, self.onAddonLoaded)
    
    self:SetupOptions()

    if ZO_QuickSlot then
        ZO_QuickSlot.owner = QUICKSLOT_WINDOW
    else
        ZO_QuickSlot_Keyboard_TopLevel.owner = QUICKSLOT_KEYBOARD
    end
    ZO_CompanionEquipment_Panel_Keyboard.owner = COMPANION_EQUIPMENT_KEYBOARD
    
    -- Add support for custom tableOrderingFunction in sort keys
    Prehook_TableOrderingFunction()
    
    for sortByControl, flags in pairs(self.sortByControls) do
        self.addSortByQuality(flags, sortByControl)
    end
    
    ZO_PreHook(PLAYER_INVENTORY, "ApplySort", PurgeCacheForInventoryType)
    SLASH_COMMANDS["/qualitysort"] = self.printVersion
end

EVENT_MANAGER:RegisterForEvent("QualitySort", EVENT_ADD_ON_LOADED, QualitySort.onAddonLoaded)
