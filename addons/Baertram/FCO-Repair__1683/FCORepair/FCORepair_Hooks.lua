if FCORep == nil then FCORep = {} end
local FCORep = FCORep

--==============================================================================
--===== HOOKS BEGIN ============================================================
--==============================================================================

--==============================================================================
-- Add sort header for equipped items - Begin
--==============================================================================
local INVENTORY_REPAIR = 995
local inventoryToSortHeader = {
    [INVENTORY_REPAIR] 			    = ZO_RepairWindowSortBy,
}
local sortHeaderToControl = {
    [INVENTORY_REPAIR] 		        = REPAIR_WINDOW,
}

--The sort function for the equippe items
local function orderByEquippedStatus(data1, data2)
--d("orderByEquippedStatus")
    --If the item is equipped the bagId will be 0 (BAG_WORN)
    --If we return true the item 1 will be > item 2
    local sortReturn = false
    if (data1.bagId < data2.bagId) then
--d(GetItemLink(data1.bagId, data1.slotIndex))
        sortReturn = true
    end
    return sortReturn
end

local function initializeCustomInventorySortFn(inventory, sortKeysToUse)
    inventory.sortFn = function(entry1, entry2)
        local sortKey = inventory.currentSortKey or inventory.sortKey
        local sortOrder = inventory.currentSortOrder or inventory.sortOrder
        local res
        if type(sortKey) == "function" then
            if sortOrder == ZO_SORT_ORDER_UP then
                res = sortKey(entry1.data, entry2.data)
            else
                res = sortKey(entry2.data, entry1.data)
            end
        else
            local sortKeys
            --Are special sortKeys given?
            if sortKeysToUse ~= nil then
                sortKeys = sortKeysToUse
            --Use the standard inventory sortkeys
            else
                --[[
                    --> File esoui/src/ingame/inventory/inventory.lua.html#143
                    - Item List Sort management
                    local sortKeys =
                    {
                        slotIndex = { isNumeric = true },
                        stackCount = { tiebreaker = "slotIndex", isNumeric = true },
                        name = { tiebreaker = "stackCount" },
                        quality = { tiebreaker = "name", isNumeric = true },
                        stackSellPrice = { tiebreaker = "name", isNumeric = true },
                        age = { tiebreaker = "name", isNumeric = true, reverseTiebreakerSortOrder = true },
                        statValue = { tiebreaker = "name", isNumeric = true },
                    }
                    function ZO_Inventory_GetDefaultHeaderSortKeys()
                        return sortKeys
                    end
                ]]
                sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
            end
            res = ZO_TableOrderingFunction(entry1.data, entry2.data, sortKey, sortKeys, sortOrder)
        end
        return res
    end
end

local function UpdateSortHeader(headerCtrl, name, isEnabled)
    if isEnabled == nil or name == nil or name == "" then return end
    if headerCtrl == nil then
        --d("[UpdateSortHeader] All inventories")
        --All inventories
        for _, sortParent in pairs(inventoryToSortHeader) do
            local header = WINDOW_MANAGER:GetControlByName(sortParent:GetName()..name, "")
            if header then
                --d(">> Header: " .. header:GetName())
                header:SetHidden(not isEnabled)
                header:SetMouseEnabled(isEnabled)
            end
        end

    else
        --d("[UpdateSortHeader] " .. headerCtrl:GetName())
        --Only a special inventory
        headerCtrl:SetHidden(not isEnabled)
        headerCtrl:SetMouseEnabled(isEnabled)
    end
end

--Add a sort header to the inventory sort row
local function HookInventorySortHeader(invType, sortHeaderName, sortHeaderText, alignToControlName, offsetX, isEnabled, callbackSortFunc, sortKeysToUse, sortKeyToUse)
    isEnabled = isEnabled or false
    if not isEnabled or (callbackSortFunc == nil and (sortKeyToUse == nil or sortKeyToUse == "")) or invType == nil or (sortHeaderName == nil or sortHeaderName == "") or (sortHeaderText == nil or sortHeaderText == "") or (alignToControlName == nil or alignToControlName == "") then return end
    offsetX = offsetX or 0
    local invSortByParentControl = inventoryToSortHeader[invType]
    local nameHeader = invSortByParentControl:GetNamedChild(alignToControlName)
    if nameHeader == nil then return end

    local addedSortHeader = CreateControlFromVirtual("$(parent)".. sortHeaderName, invSortByParentControl, "ZO_SortHeader")
    addedSortHeader:SetAnchor(RIGHT, nameHeader, RIGHT, offsetX, 0)
    addedSortHeader:SetDimensions(100, 20)

    local sortKeyOrFunctionToUse
    if callbackSortFunc ~= nil then
        sortKeyOrFunctionToUse = callbackSortFunc
    elseif sortKeyToUse ~= nil and sortKeyToUse ~= "" then
        sortKeyOrFunctionToUse = sortKeyToUse
    end
    ZO_SortHeader_Initialize(addedSortHeader, sortHeaderText, sortKeyOrFunctionToUse, ZO_SORT_ORDER_UP, TEXT_ALIGN_RIGHT, "ZoFontHeader")

    local inventory = sortHeaderToControl[invType]
    initializeCustomInventorySortFn(inventory, sortKeysToUse)
    inventory.sortHeaders:AddHeader(addedSortHeader)
    --d("HookInventorySortByLevel--->")
    UpdateSortHeader(addedSortHeader, sortHeaderName, isEnabled)
end

--PreHook the OnShow function for the repair window to change the sort direction of the "Equipped" sort header
local function PreHookRepairWindowOnShow()
    if FCORep.settingsVars.settings.addEquippedSort and FCORep.settingsVars.settings.defaultEquippedSort ~= 0
        and REPAIR_WINDOW ~= nil and inventoryToSortHeader[INVENTORY_REPAIR] ~= nil then
        --Get the sort header for "Equipment"
        local equippedSortHeaderCtrl = WINDOW_MANAGER:GetControlByName(inventoryToSortHeader[INVENTORY_REPAIR]:GetName(), "Equipped")
        if equippedSortHeaderCtrl ~= nil then
            --Reset the sort order to normal (equipped first)
            REPAIR_WINDOW.sortHeaders:SelectAndResetSortForKey("bagId")
            if FCORep.settingsVars.settings.defaultEquippedSort == 2 then
                --If unequipped schould be first then select the sort header again to reverse the sort
                REPAIR_WINDOW.sortHeaders:SelectHeaderByKey("bagId")
            end
        end
    end
end

--==============================================================================
-- Add sort header for equipped items - End
--==============================================================================


--Create the hooks & pre-hooks
function FCORep.CreateHooks()
    --Create textures in repair window
    local listView = FCORep.zoVars.REPAIR_WINDOW_LIST
    if listView and listView.dataTypes and listView.dataTypes[1] then
        --[[
        local hookedFunctions = listView.dataTypes[1].setupCallback

        listView.dataTypes[1].setupCallback =
        function(rowControl, slot)
            hookedFunctions(rowControl, slot)
            --Do not execute if horse is changed
            if SCENE_MANAGER:GetCurrentScene() ~= STABLES_SCENE then
                --Check the value of the condition and the threshold values and color the condition if needed
                FCORep.checkAndColorizeConditionValue(rowControl, slot)
                --Add the [ ]around the name for the equipped items
                FCORep.addBracketsToName(rowControl, slot)
            end
        end
        ]]
        SecurePostHook(listView.dataTypes[1], "setupCallback", function(rowControl, slot)
            --Do not execute if horse is changed
            if SCENE_MANAGER:GetCurrentScene() ~= STABLES_SCENE then
                --Check the value of the condition and the threshold values and color the condition if needed
                FCORep.checkAndColorizeConditionValue(rowControl, slot)
                --Add the [ ] around the name for the equipped items
                FCORep.addBracketsToName(rowControl, slot)
            end
        end)
    end

    --Add the sort header "Equipped" and preselect it?
    if FCORep.settingsVars.settings.addEquippedSort then
        --Add sort by equipped to repair inventory
        local sortKeysToUse = {
            name = { },
            bagId = { tiebreaker = "name", isNumeric = true },
            condition = { tiebreaker = "name", isNumeric = true },
            repairCost = { tiebreaker = "name", isNumeric = true },
        }
        --Overwrite the ApplySort function for ZO_Repair (REPAIR_WINDOW) to let it know the new sortKey "bagId"
        function REPAIR_WINDOW:ApplySort()
            local function Comparator(left, right)
                return ZO_TableOrderingFunction(left.data, right.data, REPAIR_WINDOW.sortKey, sortKeysToUse, REPAIR_WINDOW.sortOrder)
            end
            local scrollData = ZO_ScrollList_GetDataList(REPAIR_WINDOW.list)
            table.sort(scrollData, Comparator)
            ZO_ScrollList_Commit(REPAIR_WINDOW.list)
        end
        --Add the sort header entry "Equipped" to the repair sort header
        HookInventorySortHeader(INVENTORY_REPAIR, "Equipped", FCORep.localizationVars.FCORep_loc["options_sort_add_sortheader_text"], "Name", 0, FCORep.settingsVars.settings.addEquippedSort, nil, sortKeysToUse, "bagId") -- align to the sort header control "Name" in the inventory; align -30 pixels to the right
        --PreHook the repair window show fragment to preselect the sorting
        REPAIR_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_FRAGMENT_SHOWING then
                PreHookRepairWindowOnShow()
            end
        end)
    end
end