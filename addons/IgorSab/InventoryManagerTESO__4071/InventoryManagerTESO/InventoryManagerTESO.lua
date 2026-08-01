-- Уникальное имя аддона
local addonName = "InventoryManagerTESO"

-- Таблица для хранения ячеек, их галочек, кнопок и состояния
local inventoryCells = {}
local checkMarks = {}
local clickControls = {}
local cellStates = {}
local draggedItem = nil
local isTrading = false
local updateTimer = nil
local currentSortType = "default"
local cellToSlotMapping = {}
local sortDirection = {default = 1}
local stackLabels = {}
local currentCategory = nil
local categoryButtons = {}
local activeCategory = nil
local searchText = ""
local cooldownOverlays = {}
local cooldownLabels = {}
local lockIcons = {}

local function FormatNumberWithSpaces(number)
    local str = tostring(number)
    local len = str:len()
    local result = ""
    local count = 0
    for i = len, 1, -1 do
        result = str:sub(i, i) .. result
        count = count + 1
        if count % 3 == 0 and i ~= 1 then
            result = " " .. result
        end
    end
    return result
end

local function GetCategoryPriority(itemType, isLocked)
    if (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR) and isLocked then
        return 1
    elseif itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
        return 2
    elseif itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
        return 3
    elseif itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON then
        return 4
    elseif itemType == ITEMTYPE_SIEGE then
        return 5
    elseif itemType == ITEMTYPE_COMPANION_WEAPON or itemType == ITEMTYPE_COMPANION_ARMOR then
        return 6
    elseif itemType == ITEMTYPE_CROWN_ITEM then
        return 7
    elseif itemType == ITEMTYPE_TREASURE then
        return 8
    elseif itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_CLOTHIER_MATERIAL or
           itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_ALCHEMY_BASE or
           itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or
           itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or itemType == ITEMTYPE_REAGENT or
           itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL then
        return 9
    else
        return 10
    end
end

local function UpdateCellAppearance(cellIndex)
    local cell = inventoryCells[cellIndex]
    local checkMark = checkMarks[cellIndex]
    local lockIcon = lockIcons[cellIndex]
    if not cell or not checkMark or not lockIcon then return end

    local slotIndex = cellToSlotMapping[cellIndex]
    local isLocked = slotIndex and IsItemPlayerLocked(BAG_BACKPACK, slotIndex) or false
    if cellStates[cellIndex] == "selected" then
        checkMark:SetHidden(false)
        checkMark:SetColor(0, 1, 0, 1)
        cell:SetAlpha(1.0)
        lockIcon:SetHidden(true)
    elseif isLocked then
        checkMark:SetHidden(true)
        cell:SetAlpha(0.5)
        lockIcon:SetHidden(false)
    else
        checkMark:SetHidden(true)
        cell:SetAlpha(1.0)
        lockIcon:SetHidden(true)
    end
end

local function CheckForMatch(item, searchInput)
    if searchInput == "" then return true end
    searchInput = searchInput:lower()
    local itemLink = GetItemLink(BAG_BACKPACK, item.slotIndex, LINK_STYLE_DEFAULT)
    local itemName = GetItemLinkName(itemLink):lower()
    return itemName:find(searchInput) ~= nil
end

local function UpdateCooldowns()
    for cellIndex = 1, 200 do
        local slotIndex = cellToSlotMapping[cellIndex]
        local overlay = cooldownOverlays[cellIndex]
        local label = cooldownLabels[cellIndex]
        if slotIndex and overlay and label then
            local remaining, duration = GetItemCooldownInfo(BAG_BACKPACK, slotIndex)
            if remaining > 0 then
                overlay:SetHidden(false)
                overlay:SetAlpha(0.7)
                label:SetHidden(false)
                label:SetText(tostring(math.ceil(remaining / 1000)))
            else
                overlay:SetHidden(true)
                label:SetHidden(true)
            end
        end
    end
end

local function UpdateInventoryCells()
    local bagId = BAG_BACKPACK
    local items = {}
    
    for i = 1, 200 do
        cellToSlotMapping[i] = nil
    end
    
    for slotIndex = 0, GetBagSize(bagId) - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local itemType = GetItemType(bagId, slotIndex)
            local championPoints = GetItemRequiredChampionPoints(bagId, slotIndex) or 0
            local level = GetItemRequiredLevel(bagId, slotIndex) or 0
            local quality = GetItemQuality(bagId, slotIndex) or 0
            local isLocked = IsItemPlayerLocked(bagId, slotIndex)
            local includeItem = true
            
            if currentCategory then
                if currentCategory == "weapon" then
                    includeItem = (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_COMPANION_WEAPON)
                elseif currentCategory == "armor" then
                    includeItem = (itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_COMPANION_ARMOR)
                elseif currentCategory == "furnishings" then
                    includeItem = (itemType == ITEMTYPE_FURNISHING)
                elseif currentCategory == "consumables" then
                    includeItem = (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON)
                elseif currentCategory == "crafting" then
                    includeItem = (itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_REAGENT or 
                                   itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
                                   itemType == ITEMTYPE_BLACKSMITHING_BOOSTER or itemType == ITEMTYPE_CLOTHIER_BOOSTER or
                                   itemType == ITEMTYPE_WOODWORKING_BOOSTER or itemType == ITEMTYPE_JEWELRYCRAFTING_BOOSTER or
                                   itemType == ITEMTYPE_ALCHEMY_BASE or itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or 
                                   itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or 
                                   itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or
                                   itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL)
                end
            end
            
            if searchText ~= "" then
                includeItem = includeItem and CheckForMatch({slotIndex = slotIndex}, searchText)
            end
            
            if includeItem then
                table.insert(items, {
                    slotIndex = slotIndex,
                    itemLink = itemLink,
                    itemType = itemType,
                    championPoints = championPoints,
                    level = level,
                    quality = quality,
                    categoryPriority = GetCategoryPriority(itemType, isLocked),
                    isLocked = isLocked
                })
            end
        end
    end
    
    table.sort(items, function(a, b)
        if sortDirection.default == 1 then
            if a.categoryPriority == b.categoryPriority then
                return a.itemLink < b.itemLink
            end
            return a.categoryPriority < b.categoryPriority
        else
            if a.categoryPriority == b.categoryPriority then
                return a.itemLink > b.itemLink
            end
            return a.categoryPriority > b.categoryPriority
        end
    end)
    
    for i = 1, 200 do
        if inventoryCells[i] then
            local item = items[i]
            if item then
                local icon = GetItemLinkInfo(item.itemLink)
                if icon then
                    inventoryCells[i]:SetTexture(icon)
                    inventoryCells[i]:SetDimensions(44, 44)
                    cellToSlotMapping[i] = item.slotIndex
                else
                    inventoryCells[i]:SetTexture("EsoUI/Art/Inventory/inventory_slot.dds")
                    cellToSlotMapping[i] = nil
                end
            else
                inventoryCells[i]:SetTexture("EsoUI/Art/Inventory/inventory_slot.dds")
                cellStates[i] = nil
                cellToSlotMapping[i] = nil
            end
            UpdateCellAppearance(i)
            if stackLabels[i] then
                if item then
                    local stackSize = GetSlotStackSize(BAG_BACKPACK, item.slotIndex)
                    if stackSize > 1 then
                        stackLabels[i]:SetText(tostring(stackSize))
                        stackLabels[i]:SetHidden(false)
                    else
                        stackLabels[i]:SetHidden(true)
                    end
                else
                    stackLabels[i]:SetHidden(true)
                end
            end
        end
    end
    
    UpdateCooldowns()
    
    local bagUsed = GetNumBagUsedSlots(BAG_BACKPACK)
    local bagSize = GetBagSize(BAG_BACKPACK)
    local goldAmount = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
    if _G["InventoryManagerTESOBagInfoLabel"] then
        _G["InventoryManagerTESOBagInfoLabel"]:SetText(bagUsed .. "/" .. bagSize)
    end
    if _G["InventoryManagerTESOGoldLabel"] then
        _G["InventoryManagerTESOGoldLabel"]:SetText("Gold: " .. FormatNumberWithSpaces(goldAmount))
    end
end

local function CreateInventoryWindow()
    if not WINDOW_MANAGER then return end
    
    local window = WINDOW_MANAGER:CreateTopLevelWindow("InventoryManagerTESOWindow")
    if not window then return end
    
    window:SetDimensions(620, 920)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetDrawTier(DT_MEDIUM)
    window:SetHidden(true)
    window:SetAlpha(0.9)
    
    local backdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOBackdrop", window, CT_BACKDROP)
    if not backdrop then return end
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0, 0, 0, 0.9)
    backdrop:SetEdgeColor(1, 1, 1, 1)
    backdrop:SetEdgeTexture("", 8, 1, 1)
    backdrop:SetDrawLevel(0)
    
    local sortPanel = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSortPanel", window, CT_BACKDROP)
    if not sortPanel then return end
    sortPanel:SetDimensions(150, 920)
    sortPanel:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    sortPanel:SetCenterColor(0, 0, 0, 0.9)
    sortPanel:SetEdgeColor(1, 1, 1, 1)
    sortPanel:SetEdgeTexture("", 8, 1, 1)
    sortPanel:SetDrawLevel(1)
    sortPanel:SetAlpha(0.9)

    local function CreateSortButton(name, sortType, icon, yOffset)
        local buttonBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSortBackdrop" .. name, sortPanel, CT_BACKDROP)
        buttonBackdrop:SetDimensions(130, 40)
        buttonBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, yOffset)
        buttonBackdrop:SetCenterColor(0.2, 0.2, 0.2, 1)
        buttonBackdrop:SetEdgeColor(1, 1, 1, 1)
        buttonBackdrop:SetEdgeTexture("", 8, 1, 1)

        local button = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSort" .. name, sortPanel, CT_BUTTON)
        button:SetDimensions(130, 40)
        button:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, yOffset)
        button:SetText(name)
        button:SetFont("ZoFontGameBold")
        button:SetNormalFontColor(1, 1, 0, 1)
        button:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(1, 0.8, 0, 1) end)
        button:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 1, 0, 1) end)
        button:SetHandler("OnClicked", function()
            if currentSortType == sortType then
                sortDirection[sortType] = -sortDirection[sortType]
            else
                currentSortType = sortType
                sortDirection[sortType] = 1
            end
            currentCategory = nil
            activeCategory = nil
            for cat, btn in pairs(categoryButtons) do
                btn:SetHidden(false)
            end
            UpdateInventoryCells()
        end)
        local buttonIcon = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSortIcon" .. name, button, CT_TEXTURE)
        buttonIcon:SetDimensions(30, 30)
        buttonIcon:SetAnchor(LEFT, button, LEFT, 5, 0)
        buttonIcon:SetTexture(icon)
        return button
    end

    CreateSortButton("All", "default", "EsoUI/Art/Inventory/inventory_tabIcon_all_up.dds", 10)

    local searchBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSearchBackdrop", sortPanel, CT_BACKDROP)
    searchBackdrop:SetDimensions(130, 30)
    searchBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 60)
    searchBackdrop:SetCenterColor(0.1, 0.1, 0.1, 1)
    searchBackdrop:SetEdgeColor(1, 1, 1, 1)
    searchBackdrop:SetEdgeTexture("", 8, 1, 1)
    searchBackdrop:SetDrawLevel(100)

    local searchEditBox = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSearchEditBox", sortPanel, CT_EDITBOX)
    searchEditBox:SetDimensions(130, 30)
    searchEditBox:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 60)
    searchEditBox:SetFont("ZoFontGameBold")
    searchEditBox:SetText("")
    searchEditBox:SetColor(1, 1, 1, 1)
    searchEditBox:SetEditEnabled(true)
    searchEditBox:SetMultiLine(false)
    searchEditBox:SetMaxInputChars(50)
    searchEditBox:SetDrawLevel(101)
    searchEditBox:SetMouseEnabled(true)
    searchEditBox:SetHandler("OnMouseDown", function(self)
        self:TakeFocus()
    end)
    searchEditBox:SetHandler("OnTextChanged", function(self)
        searchText = self:GetText()
        UpdateInventoryCells()
    end)
    searchEditBox:SetHandler("OnFocusGained", function(self)
        self:TakeFocus()
    end)
    searchEditBox:SetHandler("OnFocusLost", function(self)
        if self:GetText() == "" then
            searchText = ""
            UpdateInventoryCells()
        end
    end)
    searchEditBox:SetHandler("OnEnter", function(self)
        self:LoseFocus()
        UpdateInventoryCells()
    end)
    searchEditBox:SetHandler("OnEscape", function(self)
        self:SetText("")
        searchText = ""
        self:LoseFocus()
        UpdateInventoryCells()
    end)

    local searchIcon = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSearchIcon", searchEditBox, CT_TEXTURE)
    searchIcon:SetDimensions(20, 20)
    searchIcon:SetAnchor(LEFT, searchEditBox, LEFT, 5, 0)
    searchIcon:SetTexture("EsoUI/Art/Miscellaneous/search_icon.dds")
    searchIcon:SetDrawLevel(102)

    local function CreateCategoryButton(category, icon, tooltipText, xOffset, yOffset)
        local button = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCategory" .. category, sortPanel, CT_BUTTON)
        button:SetDimensions(40, 40)
        button:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, xOffset, yOffset)
        button:SetAlpha(1.0)
        button:SetDrawLevel(10)
        button:SetHandler("OnMouseEnter", function(self)
            if InitializeTooltip and InformationTooltip then
                InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
                InformationTooltip:AddLine(tooltipText, "ZoFontGameBold", 1, 1, 1)
            else
                d("InventoryManagerTESO: InformationTooltip is not available for category button " .. category)
            end
        end)
        button:SetHandler("OnMouseExit", function(self)
            if ClearTooltip and InformationTooltip then
                ClearTooltip(InformationTooltip)
            end
        end)
        button:SetHandler("OnClicked", function()
            if activeCategory == category then
                activeCategory = nil
                currentCategory = nil
                for cat, btn in pairs(categoryButtons) do
                    btn:SetHidden(false)
                end
            else
                activeCategory = category
                currentCategory = category
                for cat, btn in pairs(categoryButtons) do
                    if cat == category then
                        btn:SetHidden(false)
                    else
                        btn:SetHidden(true)
                    end
                end
            end
            UpdateInventoryCells()
        end)
        local buttonIcon = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCategoryIcon" .. category, button, CT_TEXTURE)
        buttonIcon:SetDimensions(40, 40)
        buttonIcon:SetAnchor(CENTER, button, CENTER, 0, 0)
        buttonIcon:SetTexture(icon)
        buttonIcon:SetAlpha(1.0)
        buttonIcon:SetDrawLevel(20)
        categoryButtons[category] = button
    end

    CreateCategoryButton("weapon", "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds", "Weapon", 10, 110)
    CreateCategoryButton("armor", "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds", "Armor", 60, 110)
    CreateCategoryButton("furnishings", "EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds", "Furnishings", 110, 110)
    CreateCategoryButton("consumables", "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds", "Consumables", 10, 160)
    CreateCategoryButton("crafting", "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds", "Crafting", 60, 160)

    local cellSize = 44
    local padding = 1
    for row = 1, 20 do
        for col = 1, 10 do
            local cellIndex = (row-1) * 10 + col
            local cell = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCell" .. cellIndex, window, CT_TEXTURE)
            if not cell then return end
            cell:SetDimensions(cellSize, cellSize)
            cell:SetAnchor(TOPLEFT, window, TOPLEFT, (col-1) * (cellSize + padding) + 10, (row-1) * (cellSize + padding) + 10)
            cell:SetTexture("EsoUI/Art/Inventory/inventory_slot.dds")
            cell:SetDrawLevel(1)
            inventoryCells[cellIndex] = cell
            
            local clickControl = WINDOW_MANAGER:CreateControl("InventoryManagerTESOClickControl" .. cellIndex, window, CT_CONTROL)
            if not clickControl then return end
            clickControl:SetDimensions(cellSize, cellSize)
            clickControl:SetAnchor(TOPLEFT, window, TOPLEFT, (col-1) * (cellSize + padding) + 10, (row-1) * (cellSize + padding) + 10)
            clickControl:SetMouseEnabled(true)
            clickControl:SetDrawLevel(2)
            clickControls[cellIndex] = clickControl
            
            local checkMark = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCheckMark" .. cellIndex, cell, CT_TEXTURE)
            checkMark:SetDimensions(20, 20)
            checkMark:SetAnchor(TOPLEFT, cell, TOPLEFT, 2, 2)
            checkMark:SetTexture("EsoUI/Art/Miscellaneous/check.dds")
            checkMark:SetHidden(true)
            checkMark:SetDrawLevel(3)
            checkMarks[cellIndex] = checkMark

            local stackLabel = WINDOW_MANAGER:CreateControl("InventoryManagerTESOStackLabel" .. cellIndex, cell, CT_LABEL)
            stackLabel:SetFont("ZoFontGameSmall")
            stackLabel:SetColor(1, 1, 1, 1)
            stackLabel:SetAnchor(BOTTOMLEFT, cell, BOTTOMLEFT, 2, -2)
            stackLabel:SetHidden(true)
            stackLabel:SetDrawLevel(3)
            stackLabels[cellIndex] = stackLabel
            
            local cooldownOverlay = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCooldownOverlay" .. cellIndex, cell, CT_TEXTURE)
            cooldownOverlay:SetDimensions(cellSize, cellSize)
            cooldownOverlay:SetAnchor(CENTER, cell, CENTER, 0, 0)
            cooldownOverlay:SetTexture("EsoUI/Art/Miscellaneous/overlay_cooldown.dds")
            cooldownOverlay:SetColor(0, 0, 0, 0.7)
            cooldownOverlay:SetHidden(true)
            cooldownOverlay:SetDrawLevel(4)
            cooldownOverlays[cellIndex] = cooldownOverlay
            
            local cooldownLabel = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCooldownLabel" .. cellIndex, cell, CT_LABEL)
            cooldownLabel:SetFont("ZoFontGameSmall")
            cooldownLabel:SetColor(1, 1, 1, 1)
            cooldownLabel:SetAnchor(CENTER, cell, CENTER, 0, 0)
            cooldownLabel:SetHidden(true)
            cooldownLabel:SetDrawLevel(5)
            cooldownLabels[cellIndex] = cooldownLabel
            
            local lockIcon = WINDOW_MANAGER:CreateControl("InventoryManagerTESOLockIcon" .. cellIndex, cell, CT_TEXTURE)
            lockIcon:SetDimensions(20, 20)
            lockIcon:SetAnchor(TOPRIGHT, cell, TOPRIGHT, -2, 2)
            lockIcon:SetTexture("EsoUI/Art/Miscellaneous/locked.dds")
            lockIcon:SetHidden(true)
            lockIcon:SetDrawLevel(3)
            lockIcons[cellIndex] = lockIcon
            
            clickControl:SetHandler("OnMouseDown", function(self, button, ctrl, alt, shift, command)
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[cellIndex]
                if not slotIndex then return end
                
                if button == 1 then
                    if isTrading and IsItemPlayerLocked(bagId, slotIndex) then return end
                    if cellStates[cellIndex] == "selected" then
                        cellStates[cellIndex] = nil
                    else
                        cellStates[cellIndex] = "selected"
                    end
                    UpdateCellAppearance(cellIndex)
                elseif button == 2 then
                    ClearMenu()
                    
                    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                    local itemType = GetItemType(bagId, slotIndex)
                    local isRespecScroll = (itemType == ITEMTYPE_RECALL_STONE)
                    
                    if not isRespecScroll then
                        if itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_JEWELRY or
                           itemType == ITEMTYPE_COMPANION_WEAPON or itemType == ITEMTYPE_COMPANION_ARMOR then
                            local equipLabel = GetString(SI_ITEM_ACTION_EQUIP)
                            if type(equipLabel) ~= "string" then
                                d("InventoryManagerTESO: GetString(SI_ITEM_ACTION_EQUIP) returned " .. type(equipLabel) .. ", using fallback 'Equip'")
                                equipLabel = "Equip"
                            end
                            AddMenuItem(equipLabel, function()
                                local equipType = GetItemLinkEquipType(itemLink)
                                local equipSlot
                                local activeWeaponPair = GetActiveWeaponPairInfo()
                                
                                if equipType == EQUIP_TYPE_HEAD then
                                    equipSlot = EQUIP_SLOT_HEAD
                                elseif equipType == EQUIP_TYPE_CHEST then
                                    equipSlot = EQUIP_SLOT_CHEST
                                elseif equipType == EQUIP_TYPE_SHOULDERS then
                                    equipSlot = EQUIP_SLOT_SHOULDERS
                                elseif equipType == EQUIP_TYPE_HAND then
                                    equipSlot = EQUIP_SLOT_HAND
                                elseif equipType == EQUIP_TYPE_LEGS then
                                    equipSlot = EQUIP_SLOT_LEGS
                                elseif equipType == EQUIP_TYPE_FEET then
                                    equipSlot = EQUIP_SLOT_FEET
                                elseif equipType == EQUIP_TYPE_WAIST then
                                    equipSlot = EQUIP_SLOT_WAIST
                                elseif equipType == EQUIP_TYPE_NECK then
                                    equipSlot = EQUIP_SLOT_NECK
                                elseif equipType == EQUIP_TYPE_RING then
                                    equipSlot = EQUIP_SLOT_RING1
                                elseif equipType == EQUIP_TYPE_MAIN_HAND or equipType == EQUIP_TYPE_TWO_HAND then
                                    equipSlot = (activeWeaponPair == 1) and EQUIP_SLOT_MAIN_HAND or EQUIP_SLOT_BACKUP_MAIN
                                elseif equipType == EQUIP_TYPE_OFF_HAND then
                                    equipSlot = (activeWeaponPair == 1) and EQUIP_SLOT_OFF_HAND or EQUIP_SLOT_BACKUP_OFF
                                elseif equipType == EQUIP_TYPE_ONE_HAND then
                                    if activeWeaponPair == 1 then
                                        local offHandItem = GetItemLink(EQUIP_SLOT_OFF_HAND, LINK_STYLE_DEFAULT)
                                        equipSlot = (offHandItem == "") and EQUIP_SLOT_OFF_HAND or EQUIP_SLOT_MAIN_HAND
                                    else
                                        local backupOffHandItem = GetItemLink(EQUIP_SLOT_BACKUP_OFF, LINK_STYLE_DEFAULT)
                                        equipSlot = (backupOffHandItem == "") and EQUIP_SLOT_BACKUP_OFF or EQUIP_SLOT_BACKUP_MAIN
                                    end
                                else
                                    return
                                end
                                EquipItem(bagId, slotIndex, equipSlot)
                                zo_callLater(UpdateInventoryCells, 200)
                            end)
                        end
                        
                        if itemType ~= ITEMTYPE_WEAPON and itemType ~= ITEMTYPE_ARMOR and itemType ~= ITEMTYPE_JEWELRY and
                           itemType ~= ITEMTYPE_COMPANION_WEAPON and itemType ~= ITEMTYPE_COMPANION_ARMOR then
                            local useLabel = GetString(SI_ITEM_ACTION_USE)
                            if type(useLabel) ~= "string" then
                                d("InventoryManagerTESO: GetString(SI_ITEM_ACTION_USE) returned " .. type(useLabel) .. ", using fallback 'Use'")
                                useLabel = "Use"
                            end
                            AddMenuItem(useLabel, function()
                                CallSecureProtected("UseItem", bagId, slotIndex)
                                zo_callLater(UpdateInventoryCells, 200)
                            end)
                        end
                        
                        if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_JEWELRY or
                           itemType == ITEMTYPE_COMPANION_ARMOR or itemType == ITEMTYPE_COMPANION_WEAPON then
                            local isLocked = IsItemPlayerLocked(bagId, slotIndex)
                            local lockLabel = isLocked and GetString(SI_ITEM_ACTION_UNLOCK) or GetString(SI_ITEM_ACTION_LOCK)
                            if type(lockLabel) ~= "string" then
                                d("InventoryManagerTESO: GetString(SI_ITEM_ACTION_" .. (isLocked and "UNLOCK" or "LOCK") .. ") returned " .. type(lockLabel) .. ", using fallback '" .. (isLocked and "Unlock" or "Lock") .. "'")
                                lockLabel = isLocked and "Unlock" or "Lock"
                            end
                            AddMenuItem(lockLabel, function()
                                SetItemIsPlayerLocked(bagId, slotIndex, not isLocked)
                                UpdateCellAppearance(cellIndex)
                            end)
                        end
                    end
                    
                    ShowMenu(self)
                end
            end)

            clickControl:SetHandler("OnMouseDoubleClick", function(self, button)
                if button == 1 then
                    local bagId = BAG_BACKPACK
                    local slotIndex = cellToSlotMapping[cellIndex]
                    if slotIndex and SCENE_MANAGER:GetScene("bank"):IsShowing() then
                        local freeSlots = GetNumBagFreeSlots(BAG_BANK)
                        if freeSlots > 0 then
                            local stackSize = GetSlotStackSize(bagId, slotIndex)
                            local destSlot = FindFirstEmptySlotInBag(BAG_BANK)
                            if destSlot then
                                CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BANK, destSlot, stackSize)
                                cellStates[cellIndex] = nil
                                UpdateCellAppearance(cellIndex)
                                zo_callLater(UpdateInventoryCells, 200)
                            end
                        end
                    end
                end
            end)
            
            clickControl:SetHandler("OnMouseEnter", function(self)
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[cellIndex]
                if slotIndex then
                    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                    if itemLink and itemLink ~= "" then
                        if InitializeTooltip and ItemTooltip then
                            InitializeTooltip(ItemTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
                            ItemTooltip:SetLink(itemLink)
                        else
                            d("InventoryManagerTESO: ItemTooltip is not available for item at slot " .. tostring(slotIndex))
                        end
                    end
                end
            end)
            
            clickControl:SetHandler("OnMouseExit", function(self)
                if ClearTooltip and ItemTooltip then
                    ClearTooltip(ItemTooltip)
                end
            end)
        end
    end
    
    local lockBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOLockBackdrop", sortPanel, CT_BACKDROP)
    lockBackdrop:SetDimensions(130, 30)
    lockBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 210)
    lockBackdrop:SetCenterColor(0.2, 0.2, 0.2, 1)
    lockBackdrop:SetEdgeColor(1, 1, 1, 1)
    lockBackdrop:SetEdgeTexture("", 8, 1, 1)

    local lockButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESOLockButton", sortPanel, CT_BUTTON)
    if not lockButton then return end
    lockButton:SetDimensions(130, 30)
    lockButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 210)
    lockButton:SetText("Lock")
    lockButton:SetFont("ZoFontGameBold")
    lockButton:SetNormalFontColor(0, 0, 1, 1)
    lockButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0, 0, 0.8, 1) end)
    lockButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(0, 0, 1, 1) end)
    lockButton:SetHidden(false)
    lockButton:SetDrawLevel(4)
    lockButton:SetHandler("OnClicked", function()
        local lockedCount = 0
        for index, state in pairs(cellStates) do
            if state == "selected" and inventoryCells[index] then
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[index]
                if slotIndex then
                    local itemType = GetItemType(bagId, slotIndex)
                    if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_JEWELRY or
                       itemType == ITEMTYPE_COMPANION_ARMOR or itemType == ITEMTYPE_COMPANION_WEAPON then
                        SetItemIsPlayerLocked(bagId, slotIndex, true)
                        cellStates[index] = nil
                        UpdateCellAppearance(index)
                        lockedCount = lockedCount + 1
                    end
                end
            end
        end
    end)
    
    local unlockBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOUnlockBackdrop", sortPanel, CT_BACKDROP)
    unlockBackdrop:SetDimensions(130, 30)
    unlockBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 250)
    unlockBackdrop:SetCenterColor(0.2, 0.2, 0.2, 1)
    unlockBackdrop:SetEdgeColor(1, 1, 1, 1)
    unlockBackdrop:SetEdgeTexture("", 8, 1, 1)

    local unlockButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESOUnlockButton", sortPanel, CT_BUTTON)
    if not unlockButton then return end
    unlockButton:SetDimensions(130, 30)
    unlockButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 250)
    unlockButton:SetText("Unlock")
    unlockButton:SetFont("ZoFontGameBold")
    unlockButton:SetNormalFontColor(0, 1, 0, 1)
    lockButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0, 0, 0.8, 1) end)
    lockButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(0, 0, 1, 1) end)
    unlockButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0, 0.8, 0, 1) end)
    unlockButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(0, 1, 0, 1) end)
    unlockButton:SetHidden(false)
    unlockButton:SetDrawLevel(4)
    unlockButton:SetHandler("OnClicked", function()
        local unlockedCount = 0
        for index, state in pairs(cellStates) do
            if state == "selected" and inventoryCells[index] and cellToSlotMapping[index] and IsItemPlayerLocked(BAG_BACKPACK, cellToSlotMapping[index]) then
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[index]
                SetItemIsPlayerLocked(bagId, slotIndex, false)
                cellStates[index] = nil
                UpdateCellAppearance(index)
                unlockedCount = unlockedCount + 1
            end
        end
    end)
    
    local selectAllBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSelectAllBackdrop", sortPanel, CT_BACKDROP)
    selectAllBackdrop:SetDimensions(130, 30)
    selectAllBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 290)
    selectAllBackdrop:SetCenterColor(0.2, 0.2, 0.2, 1)
    selectAllBackdrop:SetEdgeColor(1, 1, 1, 1)
    selectAllBackdrop:SetEdgeTexture("", 8, 1, 1)

    local selectAllButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSelectAllButton", sortPanel, CT_BUTTON)
    selectAllButton:SetDimensions(130, 30)
    selectAllButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 290)
    selectAllButton:SetFont("ZoFontGameBold")
    selectAllButton:SetText("Select All")
    selectAllButton:SetNormalFontColor(1, 0.5, 0, 1)
    selectAllButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0.8, 0.4, 0, 1) end)
    selectAllButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 0.5, 0, 1) end)
    selectAllButton:SetDrawLevel(4)
    
    local selectAllIcon = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSelectAllIcon", selectAllButton, CT_TEXTURE)
    selectAllIcon:SetDimensions(20, 20)
    selectAllIcon:SetAnchor(LEFT, selectAllButton, LEFT, 5, 0)
    selectAllIcon:SetTexture("EsoUI/Art/Miscellaneous/check.dds")
    selectAllIcon:SetHidden(true)
    
    local isAllSelected = false
    selectAllButton:SetHandler("OnClicked", function()
        isAllSelected = not isAllSelected
        selectAllIcon:SetHidden(not isAllSelected)
        if isAllSelected then
            for cellIndex = 1, 200 do
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[cellIndex]
                if slotIndex then
                    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                    if itemLink and itemLink ~= "" then
                        if isTrading and IsItemPlayerLocked(bagId, slotIndex) then
                        else
                            cellStates[cellIndex] = "selected"
                            UpdateCellAppearance(cellIndex)
                        end
                    end
                end
            end
        else
            for cellIndex = 1, 200 do
                if cellStates[cellIndex] == "selected" then
                    cellStates[cellIndex] = nil
                    UpdateCellAppearance(cellIndex)
                end
            end
        end
    end)

    -- Кнопка "Deposit to Bank"
    local depositBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESODepositBackdrop", sortPanel, CT_BACKDROP)
    depositBackdrop:SetDimensions(130, 30)
    depositBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 330)
    depositBackdrop:SetCenterColor(0.2, 0.2, 0.2, 1)
    depositBackdrop:SetEdgeColor(1, 1, 1, 1)
    depositBackdrop:SetEdgeTexture("", 8, 1, 1)

    local depositButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESODepositButton", sortPanel, CT_BUTTON)
    depositButton:SetDimensions(130, 30)
    depositButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 330)
    depositButton:SetText("Deposit to Bank")
    depositButton:SetFont("ZoFontGameBold")
    depositButton:SetNormalFontColor(0, 1, 1, 1) -- Бирюзовый цвет
    depositButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0, 0.8, 0.8, 1) end)
    depositButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(0, 1, 1, 1) end)
    depositButton:SetHidden(false)
    depositButton:SetDrawLevel(4)
    depositButton:SetHandler("OnClicked", function()
        if not SCENE_MANAGER:GetScene("bank"):IsShowing() then return end
        local freeSlots = GetNumBagFreeSlots(BAG_BANK)
        local toDeposit = {}
        for index, state in pairs(cellStates) do
            if state == "selected" and inventoryCells[index] then
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[index]
                if slotIndex then
                    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                    if itemLink and itemLink ~= "" then
                        table.insert(toDeposit, { bagId = bagId, slotIndex = slotIndex, cellIndex = index })
                    end
                end
            end
        end
        if #toDeposit > 0 and freeSlots >= #toDeposit then
            local function depositNextItem(index)
                if index > #toDeposit then
                    UpdateInventoryCells()
                    return
                end
                local item = toDeposit[index]
                local stackSize = GetSlotStackSize(item.bagId, item.slotIndex)
                local destSlot = FindFirstEmptySlotInBag(BAG_BANK)
                if destSlot then
                    CallSecureProtected("RequestMoveItem", item.bagId, item.slotIndex, BAG_BANK, destSlot, stackSize)
                    cellStates[item.cellIndex] = nil
                    UpdateCellAppearance(item.cellIndex)
                    zo_callLater(function() depositNextItem(index + 1) end, 200)
                end
            end
            depositNextItem(1)
        end
    end)

    local sellBackdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSellBackdrop", sortPanel, CT_BACKDROP)
    sellBackdrop:SetDimensions(130, 30)
    sellBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 370)
    sellBackdrop:SetCenterColor(0.2, 0.2, 0.2, 1)
    sellBackdrop:SetEdgeColor(1, 1, 1, 1)
    sellBackdrop:SetEdgeTexture("", 8, 1, 1)

    local sellButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESOSellButton", sortPanel, CT_BUTTON)
    if not sellButton then return end
    sellButton:SetDimensions(130, 30)
    sellButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 370)
    sellButton:SetText("Sell")
    sellButton:SetFont("ZoFontGameBold")
    sellButton:SetNormalFontColor(1, 0, 0, 1)
    sellButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0.8, 0, 0, 1) end)
    sellButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 0, 0, 1) end)
    sellButton:SetHidden(false)
    sellButton:SetDrawLevel(4)
    sellButton:SetHandler("OnClicked", function()
        if not isTrading or GetInteractionType() ~= INTERACTION_VENDOR then return end
        local toSell = {}
        for index, state in pairs(cellStates) do
            if state == "selected" and inventoryCells[index] then
                local bagId = BAG_BACKPACK
                local slotIndex = cellToSlotMapping[index]
                if slotIndex then
                    local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
                    if itemLink and itemLink ~= "" then
                        table.insert(toSell, { bagId = bagId, slotIndex = slotIndex, itemLink = itemLink, cellIndex = index })
                    end
                end
            end
        end
        if #toSell > 0 then
            local totalSold = 0
            for i, item in ipairs(toSell) do
                if totalSold >= 50 then break end
                local stackCount = GetSlotStackSize(item.bagId, item.slotIndex)
                if not IsItemPlayerLocked(item.bagId, item.slotIndex) then
                    SellInventoryItem(item.bagId, item.slotIndex, stackCount)
                    totalSold = totalSold + 1
                    cellStates[item.cellIndex] = nil
                    UpdateCellAppearance(item.cellIndex)
                    zo_callLater(UpdateInventoryCells, 100)
                end
                zo_callLater(function() end, 50)
            end
        end
    end)
    
    local goldLabel = WINDOW_MANAGER:CreateControl("InventoryManagerTESOGoldLabel", sortPanel, CT_LABEL)
    goldLabel:SetFont("ZoFontGameBold")
    goldLabel:SetColor(1, 1, 0, 1)
    goldLabel:SetAnchor(BOTTOMRIGHT, sortPanel, BOTTOMRIGHT, -10, -30)
    goldLabel:SetText("Gold: 0")
    goldLabel:SetDrawLevel(5)
    
    local bagInfoLabel = WINDOW_MANAGER:CreateControl("InventoryManagerTESOBagInfoLabel", sortPanel, CT_LABEL)
    bagInfoLabel:SetFont("ZoFontGameBold")
    bagInfoLabel:SetColor(1, 1, 1, 1)
    bagInfoLabel:SetAnchor(BOTTOMRIGHT, sortPanel, BOTTOMRIGHT, -10, -10)
    bagInfoLabel:SetText("0/0")
    bagInfoLabel:SetDrawLevel(5)

    local helpButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESOHelpButton", sortPanel, CT_BUTTON)
    helpButton:SetDimensions(32, 32)
    helpButton:SetAnchor(BOTTOMRIGHT, goldLabel, TOPRIGHT, 0, -10)
    helpButton:SetNormalTexture("EsoUI/Art/Buttons/pointsPlus_up.dds")
    helpButton:SetDrawLevel(10)
    helpButton:SetMouseEnabled(true)
    helpButton:SetHandler("OnMouseEnter", function(self)
        if InitializeTooltip and InformationTooltip then
            InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
            InformationTooltip:AddLine("Instructions in different languages are available in the addon folder.", "ZoFontGameBold", 1, 1, 1)
            InformationTooltip:AddLine("Инструкция на разных языках доступна в папке с аддоном.", "ZoFontGameBold", 1, 1, 1)
        end
    end)
    helpButton:SetHandler("OnMouseExit", function(self)
        if ClearTooltip and InformationTooltip then
            ClearTooltip(InformationTooltip)
        end
    end)
    
    local closeButton = WINDOW_MANAGER:CreateControl("InventoryManagerTESOCloseButton", window, CT_BUTTON)
    if not closeButton then return end
    closeButton:SetDimensions(30, 30)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 10)
    closeButton:SetText("X")
    closeButton:SetFont("ZoFontGameBold")
    closeButton:SetNormalFontColor(1, 0, 0, 1)
    closeButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0.8, 0, 0, 1) end)
    closeButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 0, 0, 1) end)
    closeButton:SetHidden(false)
    closeButton:SetDrawLevel(5)
    closeButton:SetHandler("OnClicked", function()
        window:SetHidden(true)
        for index, state in pairs(cellStates) do
            if state == "selected" then
                cellStates[index] = nil
                UpdateCellAppearance(index)
            end
        end
    end)
end

local function StartPeriodicUpdate()
    if updateTimer then return end
    local function periodicUpdate()
        if _G["InventoryManagerTESOWindow"] and not _G["InventoryManagerTESOWindow"]:IsHidden() then
            UpdateInventoryCells()
        end
        updateTimer = zo_callLater(periodicUpdate, 1000)
    end
    updateTimer = zo_callLater(periodicUpdate, 1000)
end

local function StopPeriodicUpdate()
    if updateTimer then
        updateTimer = nil
    end
end

local function OnInventorySlotUpdated(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
    if bagId ~= BAG_BACKPACK then return end
    if _G["InventoryManagerTESOWindow"] and not _G["InventoryManagerTESOWindow"]:IsHidden() then
        UpdateInventoryCells()
    end
end

local function OnStoreOpened(eventCode)
    isTrading = true
    StartPeriodicUpdate()
    for index, state in pairs(cellStates) do
        if state == "selected" and cellToSlotMapping[index] and IsItemPlayerLocked(BAG_BACKPACK, cellToSlotMapping[index]) then
            cellStates[index] = nil
            UpdateCellAppearance(index)
        end
    end
end

local function OnStoreClosed(eventCode)
    isTrading = false
    StopPeriodicUpdate()
end

local function ToggleInventoryWindow()
    local window = _G["InventoryManagerTESOWindow"]
    if window then
        window:SetHidden(not window:IsHidden())
        if not window:IsHidden() then
            UpdateInventoryCells()
            StartPeriodicUpdate()
        else
            for index, state in pairs(cellStates) do
                if state == "selected" then
                    cellStates[index] = nil
                    UpdateCellAppearance(index)
                end
            end
            StopPeriodicUpdate()
        end
    end
end

local function CreateCustomButton()
    if _G["InventoryManagerTESOButton"] then
        d("InventoryManagerTESO: Custom button already exists, skipping creation")
        return
    end

    local button = WINDOW_MANAGER:CreateTopLevelWindow("InventoryManagerTESOButton")
    if not button then
        d("InventoryManagerTESO: Failed to create custom button")
        return
    end
    
    button:SetDimensions(291, 36)
    button:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 1330, 900)
    button:SetMouseEnabled(true)
    button:SetDrawTier(DT_HIGH)
    button:SetClampedToScreen(true)
    button:SetMovable(false)
    button:SetHidden(true)

    local backdrop = WINDOW_MANAGER:CreateControl("InventoryManagerTESOButtonBackdrop", button, CT_BACKDROP)
    if not backdrop then
        d("InventoryManagerTESO: Failed to create button backdrop")
        return
    end
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0, 0, 0, 0.8)
    backdrop:SetEdgeColor(1, 1, 1, 1)
    backdrop:SetEdgeTexture("", 8, 1, 1)

    local label = WINDOW_MANAGER:CreateControl("InventoryManagerTESOButtonLabel", button, CT_LABEL)
    if not label then
        d("InventoryManagerTESO: Failed to create button label")
        return
    end
    label:SetFont("ZoFontGameBold")
    label:SetColor(0, 1, 0, 1)
    label:SetText("|c00FF00Inventory|r|cFF0000Manager|r|cFFD700TESO|r")
    label:SetAnchor(CENTER, button, CENTER, 0, 0)
    label:SetDrawLevel(1)

    button:SetHandler("OnMouseEnter", function(self)
        label:SetColor(0.8, 1, 0.8, 1)
    end)
    button:SetHandler("OnMouseExit", function(self)
        label:SetColor(0, 1, 0, 1)
    end)
    button:SetHandler("OnMouseUp", function(self, button, upInside)
        if upInside and button == 1 then
            ToggleInventoryWindow()
        end
    end)

    _G["InventoryManagerTESOButton"] = button
    d("InventoryManagerTESO: Custom button created successfully")
end

local function UpdateButtonVisibility()
    local button = _G["InventoryManagerTESOButton"]
    if button then
        local inventoryScene = SCENE_MANAGER:GetScene("inventory")
        local bankScene = SCENE_MANAGER:GetScene("bank")
        local isInventoryOpen = inventoryScene and inventoryScene:IsShowing()
        local isBankOpen = bankScene and bankScene:IsShowing()
        
        if isInventoryOpen or isBankOpen then
            button:SetHidden(false)
        else
            button:SetHidden(true)
        end
    end
end

local function OnAddonLoaded(eventCode, loadedAddonName)
    if loadedAddonName ~= addonName then return end
    
    d("InventoryManagerTESO: Addon loaded")
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_STORE, OnStoreOpened)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_STORE, OnStoreClosed)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdated)
    
    CreateCustomButton()

    local inventoryScene = SCENE_MANAGER:GetScene("inventory")
    if inventoryScene then
        inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
            UpdateButtonVisibility()
        end)
    else
        d("InventoryManagerTESO: Inventory scene not found")
    end
    
    local bankScene = SCENE_MANAGER:GetScene("bank")
    if bankScene then
        bankScene:RegisterCallback("StateChange", function(oldState, newState)
            UpdateButtonVisibility()
        end)
    else
        d("InventoryManagerTESO: Bank scene not found")
    end
end

if EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)
end

zo_callLater(function()
    CreateInventoryWindow()
end, 2000)