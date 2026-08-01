-- This addon is just modified version of Quality Sort by silvereyes & Randactyl

GearSetsSort_INVENTORY_QUICKSLOT  = 100
GearSetsSort_CRAFTING_DECON       = 200
GearSetsSort_CRAFTING_ENCHANTING  = 201
GearSetsSort_CRAFTING_IMPROVEMENT = 202
GearSetsSort_CRAFTING_REFINEMENT  = 203
GearSetsSort_CRAFTING_RETRAIT     = 204
GearSetsSort_COMPANION            = 205
GearSetsSort_UNIVERSAL_DECON      = 206

GearSetsSort_DIR_DESC = 1
GearSetsSort_DIR_ASC  = 2

GearSetsSort = {
    name    = "GearSetsSort",
    version = "2.0.0.5",
    title   = "Gear Sets Sort",
    author  = "Evangarstorm",
    defaults = {
        automatic = true,
        sortOrder = {
	    "set",
	    "type",
            "name",
	    "slot",
            "quality",
            "level",
	    "equipped",
            "trait",
	    "enchantment",
            "style",
            "id",
            "vouchers",
            "masterWrit",
            "quantity",
        },
        sortDirection = {
            ["enchantment"] = GearSetsSort_DIR_ASC,
            ["equipped"]    = GearSetsSort_DIR_ASC,
            ["id"]          = GearSetsSort_DIR_ASC,
            ["level"]       = GearSetsSort_DIR_ASC,
            ["masterWrit"]  = GearSetsSort_DIR_ASC,
            ["name"]        = GearSetsSort_DIR_ASC,
            ["quality"]     = GearSetsSort_DIR_DESC,
            ["quantity"]    = GearSetsSort_DIR_DESC,
            ["set"]         = GearSetsSort_DIR_DESC,
	    ["type"]         = GearSetsSort_DIR_DESC,
            ["slot"]        = GearSetsSort_DIR_DESC,
            ["style"]       = GearSetsSort_DIR_ASC,
            ["trait"]       = GearSetsSort_DIR_ASC,
            ["vouchers"]    = GearSetsSort_DIR_ASC,
        },
    },
    sortByControls = {
        [ZO_PlayerInventorySortBy]                                      = { INVENTORY_BACKPACK, INVENTORY_QUEST_ITEM },
        [ZO_PlayerBankSortBy]                                           = INVENTORY_BANK,
        [ZO_GuildBankSortBy]                                            = INVENTORY_GUILD_BANK,
--        [ZO_CraftBagSortBy]                                             = INVENTORY_CRAFT_BAG,
        [ZO_HouseBankSortBy]                                            = INVENTORY_HOUSE_BANK,
--        [ZO_QuickSlotSortBy or ZO_QuickSlot_Keyboard_TopLevelSortBy]    = GearSetsSort_INVENTORY_QUICKSLOT,
        [ZO_SmithingTopLevelDeconstructionPanelInventorySortBy]         = GearSetsSort_CRAFTING_DECON,
--        [ZO_EnchantingTopLevelInventorySortBy]                          = GearSetsSort_CRAFTING_ENCHANTING,
        [ZO_SmithingTopLevelImprovementPanelInventorySortBy]            = GearSetsSort_CRAFTING_IMPROVEMENT,
--        [ZO_SmithingTopLevelRefinementPanelInventorySortBy]             = GearSetsSort_CRAFTING_REFINEMENT,
        [ZO_RetraitStation_KeyboardTopLevelRetraitPanelInventorySortBy] = GearSetsSort_CRAFTING_RETRAIT,
--        [ZO_CompanionEquipment_Panel_KeyboardSortBy]                    = GearSetsSort_COMPANION,
        [UNIVERSAL_DECONSTRUCTION.deconstructionPanelControl:GetNamedChild("Inventory"):GetNamedChild("SortBy")] = GearSetsSort_UNIVERSAL_DECON,
    },
    sortByControlOwners = {},
    debugMode = false
}

local addon = GearSetsSort

function addon:Debug(text)
    if not self.debugMode then
        return
    end
    d("GearSetsSort " .. text)
end

GearSetsSort.extendedDataCache = {}
local extendedDataCache = GearSetsSort.extendedDataCache
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
    extendedData.itemType = GetItemLinkItemType(link)
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
        local snam
        if extendedData.masterWrit.writ3 == 0 then 
          snam = "_Prov"
        elseif extendedData.masterWrit.writ4 == 0 then 
          snam = "_Ench"
        elseif extendedData.masterWrit.writ5 == 0 then 
          snam = "_Alch"
        else 
          if not LibSets or not LibSets.checkIfSetsAreLoadedProperly() then 
            snam = "_libsets not yet ready"
          else
            snam = LibSets.GetSetName(extendedData.masterWrit.writ4)  
            if snam == nil then 
              snam = "_unknown"
            end
          end
        end
        extendedData.masterWrit.writ4 = snam  
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
function comparisonFunctions.type(item1, extData1, item2, extData2)
    if extData1.itemType ~= extData2.itemType then
        return NilOrLessThan(extData1.itemType, extData2.itemType)
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

function GearSetsSort.orderByItemGearSet(entry1, entry2, sortKey, sortKeys, sortOrder)
  
    local self = GearSetsSort
    
    if sortOrder ~= ZO_SORT_ORDER_UP then
        local swp = entry1
        entry1 = entry2
        entry2 = swp
    end
    
    if entry1.questIndex or entry2.questIndex then
        return NilOrLessThan(entry1.name, entry2.name)
    end
    
    local extData1 = GetExtendedData(entry1)
    local extData2 = GetExtendedData(entry2)
    
    for optionIndex, option in ipairs(self.defaults.sortOrder) do
        local compare = comparisonFunctions[option]
        if compare then
            local result
            if self.defaults.sortDirection[self.defaults.sortOrder[optionIndex]] == GearSetsSort_DIR_ASC then
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
    
    return NilOrLessThanId64(extData1.uniqueId, extData2.uniqueId)
end

local function Prehook_NameHeader_SetWidth(nameHeader, width)
    return true
end
local function Prehook_TableOrderingFunction()
    local self = GearSetsSort
    local originalTableOrderingFunction = ZO_TableOrderingFunction
    ZO_TableOrderingFunction = function(entry1, entry2, sortKey, sortKeys, sortOrder)
        if sortKey == "gearSet" then
            if sortKeys["gearSet"] == nil then
                sortKeys["gearSet"] = {}
            end
            return self.orderByItemGearSet(entry1, entry2, sortKey, sortKeys, sortOrder)
        end
        return originalTableOrderingFunction(entry1, entry2, sortKey, sortKeys, sortOrder)
    end
end
local function ShiftRightAnchorOffsetX(header, relativeTo, shiftX, gearsetssortHeader)
    if header == relativeTo or header == gearsetssortHeader then
        return
    end
    local isValidAnchor, point, anchorRelativeTo, relativePoint, offsetX, offsetY, anchorConstrains = header:GetAnchor(0)
    if not isValidAnchor or anchorRelativeTo ~= relativeTo then
        return
    end
    if (relativePoint == RIGHT or relativePoint == TOPRIGHT or relativePoint == BOTTOMRIGHT) then
        header:ClearAnchors()

        local leftPoint = offsetX + shiftX
        if point == RIGHT or point == TOPRIGHT or point == BOTTOMRIGHT then
            leftPoint = leftPoint - header:GetWidth()
        end
        
        if leftPoint < gearsetssortHeader:GetWidth() then
            header:SetAnchor(LEFT, gearsetssortHeader, relativePoint, 0, offsetY, anchorConstrains)
        
        else
            header:SetAnchor(point, relativeTo, relativePoint, offsetX + shiftX, offsetY, anchorConstrains)
        end
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
    local self = GearSetsSort
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
    local self = GearSetsSort
    local gearsetssortHeader = GetControl(sortByControl, "Set")
end
function GearSetsSort.addSortByGearSet(flags, sortByControl)
  
    local self = GearSetsSort
  
    local newNameWidth = 80
    local qualityWidth = 80
    local nameHeader = sortByControl:GetNamedChild("Name")
    local nameWidth = nameHeader:GetWidth()
    local shiftX = nameWidth - newNameWidth
    
    nameHeader:SetWidth(newNameWidth)
    
    ZO_PreHook(nameHeader, "SetWidth", Prehook_NameHeader_SetWidth)
    
    local gearsetssortHeader = CreateControlFromVirtual("$(parent)GearSetsName", sortByControl, "ZO_SortHeader")
    
    gearsetssortHeader:SetAnchor(LEFT, nameHeader, RIGHT)
    gearsetssortHeader:SetDimensions(qualityWidth, 20)

    for i=1,sortByControl:GetNumChildren() do
        local child = sortByControl:GetChild(i)
        ShiftRightAnchorOffsetX(child, nameHeader, shiftX, gearsetssortHeader)
    end
    
    ZO_SortHeader_Initialize(gearsetssortHeader, "Set", "gearSet",
                             ZO_SORT_ORDER_UP, TEXT_ALIGN_RIGHT, "ZoFontHeader")
    
    GetSortHeaders(sortByControl):AddHeader(gearsetssortHeader)
    
    ZO_PreHookHandler(sortByControl, "OnEffectivelyShown", OnSortByControlEffectivelyShown)
end

function GearSetsSort.printVersion()
    local self = GearSetsSort
    d(self.name.." version "..self.version)
end

function GearSetsSort.onAddonLoaded(eventCode, addonName)
    local self = GearSetsSort
    if addonName ~= self.name then return end

    EVENT_MANAGER:UnregisterForEvent("GearSetsSort", EVENT_ADD_ON_LOADED, self.onAddonLoaded)
    
    if ZO_QuickSlot then
        ZO_QuickSlot.owner = QUICKSLOT_WINDOW
    else
        ZO_QuickSlot_Keyboard_TopLevel.owner = QUICKSLOT_KEYBOARD
    end
    ZO_CompanionEquipment_Panel_Keyboard.owner = COMPANION_EQUIPMENT_KEYBOARD
    
    Prehook_TableOrderingFunction()
    
    for sortByControl, flags in pairs(self.sortByControls) do
        self.addSortByGearSet(flags, sortByControl)
    end
    
    ZO_PreHook(PLAYER_INVENTORY, "ApplySort", PurgeCacheForInventoryType)
    SLASH_COMMANDS["/gearsetssort"] = self.printVersion
end

EVENT_MANAGER:RegisterForEvent("GearSetsSort", EVENT_ADD_ON_LOADED, GearSetsSort.onAddonLoaded)
