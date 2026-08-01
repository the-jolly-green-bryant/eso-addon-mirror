IBSort = {}

IBSort.name = "IBSort"
IBSort.version = "1.2"

local function NilOrLessThan(value1, value2)
    if value1 == nil then
        return true
    elseif value2 == nil then
        return false
    else
        return value1 < value2
    end
end

-- print version
function IBSort.printVersion()
    d(IBSort.name.." version "..IBSort.version)
end


-- sort function
function IBSort.orderByBank(data1, data2)

    local link1 = GetItemLink(data1.bagId, data1.slotIndex)
    local link2 = GetItemLink(data2.bagId, data2.slotIndex)
    local inventoryCount1, bankCount1, craftBagCount1 = GetItemLinkStacks(link1)
    local inventoryCount2, bankCount2, craftBagCount2 = GetItemLinkStacks(link2)
    return NilOrLessThan(bankCount1,bankCount2)
end


local function sortFunction(entry1, entry2, sortKey, sortOrder)
    local res
    if type(sortKey) == "function" then
        if sortOrder == ZO_SORT_ORDER_UP then
            res = sortKey(entry1.data, entry2.data)
        else
            res = sortKey(entry2.data, entry1.data)
        end
    else
        local sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
        res = ZO_TableOrderingFunction(entry1.data, entry2.data, sortKey, sortKeys, sortOrder)
    end
    return res
end

function IBSort.initCustomInventorySortFn(inventory)
    inventory.sortFn = function(entry1, entry2)
        local sortKey = inventory.currentSortKey
        local sortOrder = inventory.currentSortOrder
        return sortFunction(entry1, entry2, sortKey, sortOrder)
    end
end

function IBSort.addSortByBank()

    local sortByControl = ZO_PlayerInventorySortBy--IBSort.getSortByHeader(INVENTORY_BACKPACK)
    local bankSortWidth = 70
    local newNameWidth = 70
    local nameHeader = sortByControl:GetNamedChild("Name")
    local nameWidth = nameHeader:GetWidth()
    local shiftX = nameWidth - newNameWidth

    local bankSortHeader = CreateControlFromVirtual("$(parent)BankSort", sortByControl, "ZO_SortHeader")

    bankSortHeader:SetAnchor(LEFT, nameHeader, RIGHT)
    bankSortHeader:SetDimensions(bankSortWidth, 20)

    ZO_SortHeader_Initialize(bankSortHeader, "Bank", IBSort.orderByBank,
                             ZO_SORT_ORDER_UP, TEXT_ALIGN_LEFT, "ZoFontHeader")
    
    local inventory = PLAYER_INVENTORY.inventories[INVENTORY_BACKPACK]
    IBSort.initCustomInventorySortFn(inventory)
    inventory.sortHeaders:AddHeader(bankSortHeader)

end

function IBSort.onAddonLoaded(eventCode, addonName)
    if addonName ~= IBSort.name then return end

    EVENT_MANAGER:UnregisterForEvent("IBSort", EVENT_ADD_ON_LOADED, IBSort.onAddonLoaded)

    -- ZO_QuickSlot.owner = QUICKSLOT_WINDOW    
    SLASH_COMMANDS["/ibsort"] = IBSort.printVersion

    -- add sort by presence in the bank
    IBSort.addSortByBank()   

    -- add bank icon for items which are in the bank
    local ToggleMarker = function( control, data )
        local link = GetItemLink(data.bagId, data.slotIndex)
        local inventoryCount, bankCount, craftBagCount = GetItemLinkStacks(link)
        local isBank = false;
        if( bankCount ~= 0) then 
            isBank = true;
        end		
		local marker = control:GetNamedChild(IBSort.name)
		if (not marker) then			
			if (not isBank) then return end		
			marker = WINDOW_MANAGER:CreateControl(control:GetName() .. IBSort.name, control, CT_TEXTURE)
			marker:SetTexture("/esoui/art/tooltips/icon_bank.dds")
			marker:SetColor(1, 1, 1, 1)
			marker:SetDimensions(9, 9)
			marker:SetAnchor(LEFT)
			marker:SetDrawTier(DT_HIGH)
		end
		marker:SetHidden(not isBank)
	end
	SecurePostHook(ZO_ScrollList_GetDataTypeTable(ZO_PlayerInventoryList, 1), "setupCallback", ToggleMarker)

end

EVENT_MANAGER:RegisterForEvent("IBSort", EVENT_ADD_ON_LOADED, IBSort.onAddonLoaded)




