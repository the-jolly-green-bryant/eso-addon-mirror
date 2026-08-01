local ADDON_NAME			= "DeconstructAll"
local ADDON_AUTHOR			= "@AwfulDead"
--===============================================================================================--

local ItemList = {}
local IncludeBanked
local keybindButtonGroup
local handler
local stationType = nil
local tabFilter
local itemPassUniversalDeconstructFilter = ZO_UniversalDeconstructionPanel_Shared.DoesItemPassFilter

local function removeDuplicateOfSound(isEnchanting)
    if not isEnchanting then
        SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED = SOUNDS.NONE
    else
        SOUNDS.ENCHANTING_WEAPON_GLYPH_PLACED = SOUNDS.NONE
        SOUNDS.ENCHANTING_ARMOR_GLYPH_PLACED = SOUNDS.NONE
        SOUNDS.ENCHANTING_JEWELRY_GLYPH_PLACED = SOUNDS.NONE
    end
end

local function restoreSound(isEnchanting)
    if not isEnchanting then
        SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED = "Smithing_Item_To_Extract_Placed"
        PlaySound(SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED)
    else
        SOUNDS.ENCHANTING_WEAPON_GLYPH_PLACED = "Enchanting_WeaponGlyph_Placed"
        SOUNDS.ENCHANTING_ARMOR_GLYPH_PLACED = "Enchanting_ArmorGlyph_Placed"
        SOUNDS.ENCHANTING_JEWELRY_GLYPH_PLACED = "Enchanting_JewelryGlyph_Placed"
        PlaySound(SOUNDS.SMITHING_ITEM_TO_EXTRACT_PLACED)
    end
end

local function getControl()
    if IsInGamepadPreferredMode() then
        return stationType == "smithing" and SMITHING_GAMEPAD or stationType == "universal" and UNIVERSAL_DECONSTRUCTION_GAMEPAD or stationType == "enchanting" and GAMEPAD_ENCHANTING or nil
    else
        return stationType == "smithing" and SMITHING or stationType == "universal" and UNIVERSAL_DECONSTRUCTION or stationType == "enchanting" and ENCHANTING or nil
    end
end

local function IsItemInList(item)
    for _, v in ipairs(ItemList) do
        if v.bagId == item.bagId and v.slotIndex == item.slotIndex then
            return true
        end
    end
    return false
end


local function GenerateList(self, bagId, slotIndex, ...)
    if not stationType or (stationType == "enchanting" and getControl():GetEnchantingMode() ~= 2) then return end
    local item = {
        bagId = bagId,
        slotIndex = slotIndex
    }

    if not IsItemInList(item) then
        local itemTrait = GetItemTrait(item.bagId, item.slotIndex)
        local isNotLegendary = GetItemQuality(item.bagId, item.slotIndex) ~= ITEM_QUALITY_LEGENDARY
        if itemTrait ~= ITEM_TRAIT_TYPE_WEAPON_ORNATE
            and itemTrait ~= ITEM_TRAIT_TYPE_ARMOR_ORNATE
            and itemTrait ~= ITEM_TRAIT_TYPE_JEWELRY_ORNATE
            and isNotLegendary then
            table.insert(ItemList, item)
        end
    end
end

local function removeBankedItems()
    for i = #ItemList, 1, -1 do
        local v = ItemList[i]
        if v.bagId == BAG_BANK then
            getControl():RemoveItemFromCraft(v.slotIndex)
            table.remove(ItemList, i)
        end
    end
end

local function RemoveItemFromList(itemToRemove)
    for i, currentItem in ipairs(ItemList) do
        if currentItem.bagId == itemToRemove.bagId and currentItem.slotIndex == itemToRemove.slotIndex then
            table.remove(ItemList, i)
        end
    end
end

local function SelectAll()
    removeDuplicateOfSound(stationType == "enchanting")
    if stationType == "universal" then
        tabFilter = getControl().deconstructionPanel.inventory:GetCurrentFilterType()
    end
    for _, item in ipairs(ItemList) do
        local itemInList = getControl():IsItemAlreadySlottedToCraft(item.bagId, item.slotIndex)
        local shouldAddToCraft = (stationType == "universal" and itemPassUniversalDeconstructFilter(item.bagId, item.slotIndex, tabFilter)) or stationType ~= "universal"
        
        if not (FCOIS and FCOIS.IsDeconstructionLocked and FCOIS.IsDeconstructionLocked(item.bagId, item.slotIndex, nil)) then
            if itemInList and not shouldAddToCraft then
                getControl():RemoveItemFromCraft(item.bagId, item.slotIndex)
            elseif shouldAddToCraft then
                getControl():AddItemToCraft(item.bagId, item.slotIndex)
            end
        end
    end
    restoreSound(stationType == "enchanting")
end

local function OnCheckboxStateChanged(...)
    local checkBox = getControl().deconstructionPanel.inventory.control:GetNamedChild("IncludeBanked")
    handler(...)
    if checkBox:GetState() == 0 then
        removeBankedItems()
    end
end

local function DeconstructorSceneOpen()
    KEYBIND_STRIP:AddKeybindButtonGroup(keybindButtonGroup)
    if stationType and stationType ~= "enchanting" and not IsInGamepadPreferredMode() then
        local checkBox = getControl().deconstructionPanel.inventory.control:GetNamedChild("IncludeBanked")
        if not IncludeBanked then IncludeBanked = checkBox:GetNamedChild("Label") end
        if not handler then handler = IncludeBanked:GetHandler("OnMouseUp") end
        IncludeBanked:SetHandler("OnMouseUp", OnCheckboxStateChanged)
    end
end

local function DeconstructorSceneClose()
    KEYBIND_STRIP:RemoveKeybindButtonGroup(keybindButtonGroup)
    ItemList = {}
    IncludeBanked = nil
    stationType = nil
end

local function CheckForDeconstructor(eventCode, craftingType, sameStation, craftingMode)
    if ZO_Smithing_IsUniversalDeconstructionCraftingMode(craftingMode) then
        stationType = "universal"
        DeconstructorSceneOpen()
    end
end

local function listenForUpdateInventory(eventCode, bagId, slotIndex)
    if stationType ~= "universal" then return end

    local isItemLocked = IsItemPlayerLocked(bagId, slotIndex)
    local stackSize = GetSlotStackSize(bagId, slotIndex)

    if not isItemLocked and stackSize > 0 then return end

    local item = {
        bagId = bagId,
        slotIndex = slotIndex
    }

    if IsItemInList(item) then
        RemoveItemFromList(item)
    end
end

local function initHooks(condition)
    -- Keyboard
    if not condition then
        keybindButtonGroup['alignment'] = KEYBIND_STRIP_ALIGN_CENTER

        ZO_PreHook(UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory, "AddItemData", GenerateList)
        ZO_PreHook(ENCHANTING.inventory, "AddItemData", GenerateList)
        ZO_PreHook(SMITHING.deconstructionPanel.inventory, "AddItemData", GenerateList)
        ZO_PreHook(SMITHING, "SetMode", function(_, mode)
            if mode == SMITHING_MODE_DECONSTRUCTION then
                if stationType ~= "universal" then stationType = "smithing" end
                DeconstructorSceneOpen()
            else
                DeconstructorSceneClose()
            end
        end)
        ZO_PreHook(ENCHANTING.inventory, "ChangeMode", function(_, mode)
            if mode == ENCHANTING_MODE_EXTRACTION then
                if stationType ~= "universal" then stationType = "enchanting" end
                DeconstructorSceneOpen()
            else
                DeconstructorSceneClose()
            end
        end)

    end

    -- Gamepad
    if condition then
        keybindButtonGroup['alignment'] = KEYBIND_STRIP_ALIGN_LEFT

        ZO_PreHook(UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel.inventory, "GenerateCraftingInventoryEntryData", GenerateList)
        ZO_PreHook(GAMEPAD_ENCHANTING.inventory, "GenerateCraftingInventoryEntryData", GenerateList)
        ZO_PreHook(SMITHING_GAMEPAD.deconstructionPanel.inventory, "GenerateCraftingInventoryEntryData", GenerateList)
        ZO_PreHook(UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel, "SetFilterType", function()
            if UNIVERSAL_DECONSTRUCTION_GAMEPAD.deconstructionPanel:GetIncludeBankedItems() == false then
                removeBankedItems()
            end
        end)
        ZO_PreHook(GAMEPAD_ENCHANTING, "SetEnchantingMode", function(_, mode)
            if mode == ENCHANTING_MODE_EXTRACTION then
                if stationType ~= "universal" then stationType = "enchanting" end
                DeconstructorSceneOpen()
            else
                DeconstructorSceneClose()
            end
        end)
        ZO_PreHook(SMITHING_GAMEPAD, "SetMode", function(_, mode)
            if mode == SMITHING_MODE_DECONSTRUCTION then
                if stationType ~= "universal" then stationType = "smithing" end
                DeconstructorSceneOpen()
            else
                DeconstructorSceneClose()
            end
        end)
        ZO_PreHook(SMITHING_GAMEPAD.deconstructionPanel, "SaveFilters", function() zo_callLater(function()
            if SMITHING_GAMEPAD.deconstructionPanel.savedVars.includeBankedItemsChecked == false then
                removeBankedItems()
            end
        end, 0) end)
    end
end

local function GamepadModeChanged(eventCode, isGamepadPreferred)
    zo_callLater(function()
        initHooks(isGamepadPreferred)
    end, 0)
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    keybindButtonGroup = {
        {
            name = "Select All",
            keybind = "UI_SHORTCUT_QUINARY",
            callback = function() SelectAll() end,
        },
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
    }

    EVENT_MANAGER:RegisterForEvent("DeconstructAll_CraftingStationInteract", EVENT_CRAFTING_STATION_INTERACT, CheckForDeconstructor)
    EVENT_MANAGER:RegisterForEvent("DeconstructAll_EndCraftingStationInteract", EVENT_END_CRAFTING_STATION_INTERACT, DeconstructorSceneClose)
    EVENT_MANAGER:RegisterForEvent("DeconstructAll_GamepadModeToggle", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, GamepadModeChanged)
    EVENT_MANAGER:RegisterForEvent("DeconstructAll_InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, listenForUpdateInventory)

    initHooks(IsInGamepadPreferredMode())

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)