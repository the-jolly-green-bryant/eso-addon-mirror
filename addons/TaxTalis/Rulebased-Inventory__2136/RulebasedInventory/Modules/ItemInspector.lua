-----------------------------------------------------------------------------------
-- Addon Name: Rulebased Inventory
-- Creator: TaxTalis, demawi
-- Addon Ideal: user-defined rule-based actions for inventory application
-- Addon Creation Date: September 11, 2018
--
-- File Name: ItemInspector.lua
-- File Description: This file contains the implementation for the context menu which provides a button to output all stats of an item
-- Load Order Requirements: after item
-- 
-----------------------------------------------------------------------------------

-- imports
local RbI = RulebasedInventory
local ruleEnv = RbI.Import(RbI.ruleEnvironment)
local utils = RbI.Import(RbI.utils)
local dataTypeHandler = RbI.Import(RbI.dataTypeHandler)

local SEPARATOR = ' | '

local function putKeysTogether(dataTypeName, keys)
    local languageDependentKeys = RbI.collectedData[dataTypeName]
    local all = {}
    if(languageDependentKeys) then
        local ld = {}
        for _, key in pairs(keys) do
            if(dataTypeHandler.isStaticDataTypeKey(dataTypeName, key)) then
                all[#all+1] = RbI.dataKeyFixed("'"..key.."'")
            else
                ld[#ld+1] = RbI.dataKeyLD("'"..utils.TableGetWithLowercasedKey(languageDependentKeys, key).."'")
            end
        end
        utils.tableConcat(all, ld)
    else
        for _, key in pairs(keys) do
            all[#all+1] = RbI.dataKeyFixed("'"..key.."'")
        end
    end
    return utils.ArrayValuesToString(all, SEPARATOR, '')
end

-- deprecated, because we want to use the ruleEnv-functions directly
local function GetKeyForValueDeprecated(dataTypeKey, index, ...)
    local data = RbI.dataType[dataTypeKey]
	local values = {...}
    return utils.ArrayValuesToString(utils.GetKeysForValue(values[index], data), SEPARATOR)
end

local function RunFunctionItemRef(fnNameArgs, itemRef, dataTypeName)
    local functionName
    local args
    if(type(fnNameArgs) == 'string') then
        functionName = fnNameArgs:lower()
        args = {}
    else
        functionName = fnNameArgs[1]:lower()
        table.remove(fnNameArgs, 1)
        args = unpack(fnNameArgs)
    end
    if(dataTypeName ~= nil) then
        functionName = functionName..'getvalue'
    end

    if(ruleEnv.HasTag(functionName, ruleEnv.NEED_BAGSLOT) and itemRef.slot == nil) then
        ruleEnv.error("Need Bag and Slot", nil, true)
    end

    local result = ruleEnv.RunFunctionWithItem(itemRef.bag, itemRef.slot, itemRef.itemLink, functionName, args)
    if(dataTypeName ~= nil) then
        return dataTypeHandler.GetKeysForValues(RbI.dataType[dataTypeName], result)
    end
    return result
end

local function inspectItemSilent(m, itemRef, fnNameArgs, dataTypeName)
    local status, result = pcall(RunFunctionItemRef, fnNameArgs, itemRef, dataTypeName)
    if(not status) then
        if(result.notsupported ~= nil) then
            return -- notsupported => ignore
        else
            error(result)
        end
    end
    return result
end

local function inspectItem(m, itemRef, fnNameArgs, dataTypeName, indent, force)
    local status, result = pcall(RunFunctionItemRef, fnNameArgs, itemRef, dataTypeName)
    if(not status) then
        if(result.notsupported ~= nil) then
            return -- notsupported => ignore
        else
            error(result)
        end
    end
    if(force or (result~=nil and not (type(result) == 'table' and (#result == 0 or result[1] == '')))) then
        local stringValues
        if(type(result) == 'table') then
            if(dataTypeName) then
                stringValues = putKeysTogether(dataTypeName, result)
            else
                stringValues = utils.ArrayValuesToString(result, SEPARATOR)
            end
        elseif(type(result) == 'string') then
            stringValues = RbI.dataKeyLD("'"..result.."'")
        else
            stringValues = tostring(result)
        end
        indent = indent or ""
        m[#m+1] = indent ..fnNameArgs .. ': ' ..stringValues
    end
    return result
end

local INDENT = '   '
-- @return string with all relevant item infos
function RbI.CreateItemDump(bag, slot, itemLink)
    local name
    local status
    local err
    local itemRef = {
        bag = bag,
        slot = slot,
        itemLink = itemLink
    }
    local m = {}
    -- m[#m + 1] = 'ItemLink: ' .. itemLink
    local color = GetItemQualityColor(GetItemLinkQuality(itemLink))
    m[#m + 1] = 'Name: |c'..color:ToHex() .. zo_strformat("<<1>>", GetItemLinkName(itemLink).."|r")
    --m[#m + 1] = 'Bag: ' .. tostring(itemRef.bag)
    --m[#m + 1] = 'Slot: ' .. tostring(itemRef.slot)
    -- general
    inspectItem(m, itemRef, 'instanceId')
    inspectItem(m, itemRef, 'id')
    inspectItem(m, itemRef, 'bag', 'bag')
    inspectItem(m, itemRef, 'bindType', 'bindType')
    inspectItem(m, itemRef, 'quality', 'quality')
    inspectItem(m, itemRef, 'type', 'type')
    inspectItem(m, itemRef, 'filterType', 'filterType')
    inspectItem(m, itemRef, 'sType', 'sType')
    inspectItem(m, itemRef, 'countStack')
    inspectItem(m, itemRef, 'countStackMax')
    --inspectItem(m, itemRef, 'crownStore')
    --inspectItem(m, itemRef, 'crownCrate')
    -- TODO: remove this. Use a correct function
    if(IsItemFromCrownCrate(bag, slot)) then
        local itemsRequired, gemsAwarded  = GetNumCrownGemsFromItemManualGemification(bag, slot)
        m[#m+1] = 'Gemification: '..gemsAwarded..' gems for '..itemsRequired..' items'
    end
    inspectItem(m, itemRef, 'value')
    inspectItem(m, itemRef, 'price')
    --inspectItem(m, itemRef, 'locked')

    -- TODO: for masterwrits: inspect "costPerVoucher"

    -- specials
    inspectItem(m, itemRef, 'soulGemType', 'soulGemType', INDENT)

    -- gear
    local isGear = inspectItemSilent(m, itemRef, 'gear')
    if(isGear) then
        m[#m+1] = 'gear' .. ': true'
    end
    local isCompanion = inspectItemSilent(m, itemRef, 'companion')
    if(isCompanion) then
        m[#m+1] = (isGear and INDENT) .. 'companion' .. ': true'
    end
    inspectItem(m, itemRef, 'equipType', 'equipType', isGear and INDENT)
    if(isGear) then
        inspectItem(m, itemRef, 'armorType', 'armorType', INDENT)
        inspectItem(m, itemRef, 'weaponType', 'weaponType', INDENT)
        if(not isCompanion) then
            inspectItem(m, itemRef, 'traitInfo', 'traitInfo', INDENT)
        end
    end
    inspectItem(m, itemRef, 'trait', 'trait', isGear and INDENT) -- gear + traitmaterials
    inspectItem(m, itemRef, 'traitCategory', 'traitCategory', isGear and INDENT) -- gear + traitmaterials
    if(not isCompanion) then
        inspectItem(m, itemRef, 'style', 'style', isGear and INDENT) -- gear + stylematerials
    end

    if(not isCompanion) then
        local setId = select(6, GetItemLinkSetInfo(itemLink))
        if(isGear) then
            name = 'setId'
            m[#m+1] = INDENT .. name .. ': ' .. setId
            if(setId > 0) then
                inspectItem(m, itemRef, 'setName', nil, INDENT)
                if(LibSets ~= nil and LibSets.checkIfSetsAreLoadedProperly()) then
                    local _, _, setId = LibSets.IsSetByItemLink(itemLink)
                    name = 'setType'
                    m[#m+1] = INDENT .. name .. ': \'' .. RbI.dataKeyLD(LibSets.GetSetTypeName(LibSets.GetSetType(setId))) ..'\''
                end
            end
            inspectItem(m, itemRef, 'level', nil, INDENT)
            inspectItem(m, itemRef, 'cp', nil, INDENT) -- gear(), potion, food, drink, poison, glyph-material, crafting-materials
            inspectItem(m, itemRef, 'reconstructionCost', nil, INDENT)
        end
    end

    local craftingTypeValue = inspectItem(m, itemRef, 'craftingType', 'gearCraftingType')
    local isCrafting = craftingTypeValue[1] ~= 'none'
    if(isCrafting) then
        inspectItem(m, itemRef, 'craftingLevel', nil, INDENT)
        inspectItem(m, itemRef, 'craftingRank', nil, INDENT)
        inspectItem(m, itemRef, 'craftingExtractBonus', nil, INDENT)
        inspectItem(m, itemRef, 'craftingLevelMin', nil, INDENT)
        inspectItem(m, itemRef, 'craftingLevelMax', nil, INDENT)
        inspectItem(m, itemRef, 'craftingRankMin', nil, INDENT)
        inspectItem(m, itemRef, 'craftingRankMax', nil, INDENT)
        inspectItem(m, itemRef, 'craftingRankRequired', nil, INDENT)
        inspectItem(m, itemRef, 'craftingRankCount', nil, INDENT)
    end

    if(isCrafting and not isGear) then -- already printed in gear
        inspectItem(m, itemRef, 'level', nil, INDENT)
        inspectItem(m, itemRef, 'cp', nil, INDENT) -- gear(), potion, food, drink, poison, glyph-material, crafting-materials
    end

    local tags = {}
    for i = 0, GetItemLinkNumItemTags(itemLink) do
        local tag = GetItemLinkItemTagInfo(itemLink, i)
        if(tag ~= nil and tag ~= '') then
            table.insert(tags, zo_strformat("<<1>>", string.lower(tag)))
        end
    end
    m[#m+1] = 'tag: '.. utils.ArrayValuesToString(tags)

    if(AutoCategory ~= nil and bag and slot) then
        local _, category = AutoCategory:MatchCategoryRules(bag, slot)
        m[#m+1] = 'autoCategory: \'' .. tostring(category)..'\''
    end

    if(FCOIS ~= nil) then
        local fcoisMarker = {}
        local isMarked, marker = FCOIS.IsMarked(bag, slot, -1)
        if(isMarked and marker ~= nil) then
            for i, mark in ipairs(marker) do
                if(mark == true) then
                    local id = RbI.fcois.getIdByNr(i)
                    local name = RbI.fcois.getNameByNr(i)
                    if(name) then
                        table.insert(fcoisMarker, RbI.dataKeyFixed("'"..id.."'")..SEPARATOR..RbI.dataKeyLD("'"..name.."'"))
                    else
                        table.insert(fcoisMarker, RbI.dataKeyFixed("'"..id.."'"))
                    end
                end
            end
        end
        if(#fcoisMarker > 0) then
            m[#m+1] = 'fcoisMarker : '..utils.ArrayValuesToString(fcoisMarker, nil, '')
        end
    end

    local fnMarker = {}
    for _, origName in pairs(ruleEnv.GetTagged(ruleEnv.GET_BOOL)) do
        if(inspectItemSilent(m, itemRef, origName:lower())) then
            fnMarker[#fnMarker+1] = origName.."()"
        end
    end
    if(#fnMarker > 0) then
        m[#m+1] = 'true-marker: '.. utils.ArrayValuesToString(fnMarker, nil, '')
    end
    if(bag == nil) then
        m[#m+1] = ''
        m[#m+1] = utils.chatColor('Notice: You\'re inspecting only an itemlink.', 'dbd07a')..'\nBecause some functions rely on concrete slot- and bag-ids, it\'s possible that more informations exists, when you\'re facing the item directly in rule execution or via context menu in a bag.\nFollowing methods rely on bag and slot:'
        m[#m+1] = table.concat(ruleEnv.GetTagged(ruleEnv.NEED_BAGSLOT), ", ")
    end
    return table.concat(m, '\n')
end

local function isValidItemLink(itemLink)
    return type(itemLink) == 'string' and #itemLink > 0 and itemLink ~= ''
end

local function addContextMenu(itemLink, bag, slot)
    if(isValidItemLink(itemLink)) then
        AddCustomMenuItem(RbI.CONTEXT_MENU_ENTRY, function()
            local status, result = pcall(RbI.CreateItemDump, bag, slot, itemLink)
            if(not status) then
                RbI.RuleErrorHandler(nil, result)
            else
                RbI.PrintToClipBoard(result, "RbI - Item Inspector")
            end
        end)
        return true
    end
    return false
end

local function getItemReferenceFromInventorySlot(inventorySlot)
    local slotType = ZO_InventorySlot_GetType(inventorySlot)
    if(slotType == nil) then return end
    local itemLink, bag, slot
    if slotType == SLOT_TYPE_LOOT then
        -- https://esoapi.uesp.net/100035/src/ingame/inventory/inventoryslot.lua.html
        if inventorySlot.lootEntry.currencyType then
            --d("currencyType: "..tostring(inventorySlot.lootEntry.currencyType))
        else
            itemLink = GetLootItemLink(inventorySlot.lootEntry.lootId)
        end
    elseif slotType == SLOT_TYPE_GUILD_SPECIFIC_ITEM then
        itemLink = GetGuildSpecificItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_RESULT then
        itemLink = GetTradingHouseSearchResultItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
    elseif slotType == SLOT_TYPE_TRADING_HOUSE_ITEM_LISTING then
        itemLink = GetTradingHouseListingItemLink(ZO_Inventory_GetSlotIndex(inventorySlot))
    elseif slotType == SLOT_TYPE_MAIL_ATTACHMENT then
        itemLink = GetAttachedItemLink(MAIL_INBOX:GetOpenMailId(), ZO_Inventory_GetSlotIndex(inventorySlot))
    elseif slotType == SLOT_TYPE_STORE_BUY then
        itemLink = GetStoreItemLink(inventorySlot.index)
    else
        bag, slot = ZO_Inventory_GetBagAndIndex(inventorySlot)
        itemLink = GetItemLink(bag, slot)
    end
    return itemLink, bag, slot
end

local function InventorySlot_ShowContextMenu(inventorySlot)
    local itemLink, bag, slot = getItemReferenceFromInventorySlot(inventorySlot)
    addContextMenu(itemLink, bag, slot)
end

--Contextmenu from chat/link handler
local curItemLink -- only once
local function chatLinkRightClick(itemLink, button, _, _, linkType, ...)
    if button == MOUSE_BUTTON_INDEX_RIGHT and linkType == ITEM_LINK_TYPE and curItemLink == nil then
        curItemLink = itemLink
        zo_callLater(function()
            if(addContextMenu(itemLink)) then
                --Show the context menu entries at the itemlink handler now
                ShowMenu()
            end
            curItemLink = nil
        end, 100)
    end
end

-- check for itemlink out of control:
-- supported: Inventory Insight
local function controlRightClick(control)
    if control == nil then return end
    local itemLink = control.itemLink
    if(not itemLink) then
        control = control:GetParent()
        itemLink = control.itemLink
    end
    if(isValidItemLink(itemLink)) then
        zo_callLater(function()
            if(addContextMenu(itemLink)) then
                ShowMenu(control)
            end
        end, 0)
    end
end

function RbI.InitializeContextMenu()
    local lcm = LibCustomMenu
	if(lcm ~= nil and RbI.account.settings.contextMenu) then
        ZO_PreHook('ZO_InventorySlot_ShowContextMenu', controlRightClick)
        --The link handler context menu
        LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, chatLinkRightClick)

        if lcm.RegisterSpecialKeyContextMenu then
            lcm:RegisterSpecialKeyContextMenu(InventorySlot_ShowContextMenu, lcm.CATEGORY_LATE)
        end
        lcm:RegisterContextMenu(InventorySlot_ShowContextMenu, lcm.CATEGORY_LATE)
    end
    RbI.InitializeContextMenu = nil
end
RbI.fileLoadTime = GetGameTimeMilliseconds() - RbI.startTime