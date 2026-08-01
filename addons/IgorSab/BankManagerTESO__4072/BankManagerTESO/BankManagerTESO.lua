-- Уникальное имя аддона
local addonName = "BankManagerTESO"

-- Таблицы для хранения данных
local bankCells = {}
local checkMarks = {}
local clickControls = {}
local cellStates = {}
local cellToSlotMapping = {}
local stackLabels = {}
local lockIcons = {}
local currentCategory = nil
local categoryButtons = {}
local activeCategory = nil
local searchText = ""
local updateTimer = nil
local isBankOpen = false

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
    if itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR then
        return isLocked and 1 or 2
    elseif itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON then
        return 3
    elseif itemType == ITEMTYPE_FURNISHING then
        return 4
    elseif itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_REAGENT or itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or
           itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_ALCHEMY_BASE or itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
           itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL then
        return 5
    else
        return 6
    end
end

local function CheckForMatch(item, searchInput)
    if searchInput == "" then return true end
    searchInput = searchInput:lower()
    local itemLink = GetItemLink(BAG_BANK, item.slotIndex, LINK_STYLE_DEFAULT)
    local itemName = GetItemLinkName(itemLink):lower()
    return itemName:find(searchInput) ~= nil
end

local function UpdateCellAppearance(cellIndex)
    local cell = bankCells[cellIndex]
    local checkMark = checkMarks[cellIndex]
    local lockIcon = lockIcons[cellIndex]
    if not cell or not checkMark or not lockIcon then return end

    local slotIndex = cellToSlotMapping[cellIndex]
    local isLocked = slotIndex and IsItemPlayerLocked(BAG_BANK, slotIndex) or false
    if cellStates[cellIndex] == "selected" then
        checkMark:SetHidden(false)
        checkMark:SetColor(0, 1, 0, 1)
        cell:SetAlpha(1.0)
        lockIcon:SetHidden(not isLocked)
    elseif isLocked then
        checkMark:SetHidden(true)
        cell:SetAlpha(0.5)
        lockIcon:SetHidden(false)
    elseif not slotIndex then
        checkMark:SetHidden(true)
        cell:SetAlpha(0.5)
        lockIcon:SetHidden(true)
    else
        checkMark:SetHidden(true)
        cell:SetAlpha(1.0)
        lockIcon:SetHidden(true)
    end
end

local function ClearSelection()
    for i = 1, 400 do
        cellStates[i] = nil
        UpdateCellAppearance(i)
    end
end

local function UpdateBankCells()
    local bagId = BAG_BANK
    local items = {}
    local maxSlots = GetBagSize(bagId)
    local usedSlots = GetNumBagUsedSlots(bagId)

    for i = 1, 400 do
        cellToSlotMapping[i] = nil
    end

    for slotIndex = 0, maxSlots - 1 do
        local itemLink = GetItemLink(bagId, slotIndex, LINK_STYLE_DEFAULT)
        if itemLink and itemLink ~= "" then
            local itemType = GetItemType(bagId, slotIndex)
            local isLocked = IsItemPlayerLocked(bagId, slotIndex)
            local includeItem = true

            if currentCategory then
                if currentCategory == "weapon" then
                    includeItem = (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_COMPANION_WEAPON)
                elseif currentCategory == "armor" then
                    includeItem = (itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_COMPANION_ARMOR)
                elseif currentCategory == "consumables" then
                    includeItem = (itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON)
                elseif currentCategory == "furnishings" then
                    includeItem = (itemType == ITEMTYPE_FURNISHING)
                elseif currentCategory == "crafting" then
                    includeItem = (itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_REAGENT or
                                   itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_MATERIAL or
                                   itemType == ITEMTYPE_ALCHEMY_BASE or itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
                                   itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or
                                   itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL)
                elseif currentCategory == "different" then
                    includeItem = not (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_FOOD or
                                      itemType == ITEMTYPE_DRINK or itemType == ITEMTYPE_POTION or itemType == ITEMTYPE_POISON or
                                      itemType == ITEMTYPE_FURNISHING or itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_REAGENT or
                                      itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_MATERIAL or
                                      itemType == ITEMTYPE_ALCHEMY_BASE or itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
                                      itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY or
                                      itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or itemType == ITEMTYPE_COMPANION_WEAPON or
                                      itemType == ITEMTYPE_COMPANION_ARMOR)
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
                    categoryPriority = GetCategoryPriority(itemType, isLocked),
                    isLocked = isLocked
                })
            end
        end
    end

    table.sort(items, function(a, b)
        if a.categoryPriority == b.categoryPriority then
            return a.itemLink < b.itemLink
        end
        return a.categoryPriority < b.categoryPriority
    end)

    for i = 1, 400 do
        local cell = bankCells[i]
        if cell then
            if i <= maxSlots then
                local item = items[i]
                if item then
                    local icon = GetItemLinkInfo(item.itemLink)
                    cell:SetTexture(icon or "EsoUI/Art/Inventory/inventory_slot.dds")
                    cell:SetDimensions(36, 36)
                    cellToSlotMapping[i] = item.slotIndex
                else
                    cell:SetTexture("EsoUI/Art/Inventory/inventory_slot.dds")
                    cellToSlotMapping[i] = nil
                end
            else
                cell:SetTexture("EsoUI/Art/Inventory/inventory_slot.dds")
                cellToSlotMapping[i] = nil
                cell:SetAlpha(0.5)
            end
            UpdateCellAppearance(i)
            if stackLabels[i] then
                local item = items[i]
                if item then
                    local stackSize = GetSlotStackSize(bagId, item.slotIndex)
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

    local gold = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_BANK)
    local telvar = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_BANK)
    if _G["BankManagerTESOBankInfoLabel"] then
        _G["BankManagerTESOBankInfoLabel"]:SetText(usedSlots .. "/" .. maxSlots)
    end
    if _G["BankManagerTESOGoldLabel"] then
        _G["BankManagerTESOGoldLabel"]:SetText("Gold: " .. FormatNumberWithSpaces(gold))
    end
    if _G["BankManagerTESOTelvarLabel"] then
        _G["BankManagerTESOTelvarLabel"]:SetText("Tel Var: " .. FormatNumberWithSpaces(telvar))
    end
end

local function SafeWithdrawItem(slotIndex)
    local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
    if freeSlots <= 0 then return false end

    local stackSize = GetSlotStackSize(BAG_BANK, slotIndex)
    if stackSize <= 0 then return false end

    if not SCENE_MANAGER:GetScene("bank"):IsShowing() then return false end

    local destSlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
    if not destSlot then return false end

    local success = CallSecureProtected("RequestMoveItem", BAG_BANK, slotIndex, BAG_BACKPACK, destSlot, stackSize)
    if success then
        for i = 1, 400 do
            if cellToSlotMapping[i] == slotIndex then
                cellStates[i] = nil
                UpdateCellAppearance(i)
                break
            end
        end
        return true
    end
    return false
end

local function CreateBankWindow()
    if not WINDOW_MANAGER then return end

    local window = WINDOW_MANAGER:CreateTopLevelWindow("BankManagerTESOWindow")
    local cellSize = 36
    local padding = 2
    local totalWidth = 20 * (cellSize + padding) - padding + 150 + 20
    local totalHeight = 20 * (cellSize + padding) - padding + 40
    window:SetDimensions(totalWidth, totalHeight)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)
    window:SetDrawTier(DT_MEDIUM)
    window:SetHidden(true)
    window:SetAlpha(0.9)

    local backdrop = WINDOW_MANAGER:CreateControl("BankManagerTESOBackdrop", window, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0, 0, 0, 0.9)
    backdrop:SetEdgeColor(1, 1, 1, 1)
    backdrop:SetEdgeTexture("", 8, 1, 1)

    local sortPanel = WINDOW_MANAGER:CreateControl("BankManagerTESOSortPanel", window, CT_BACKDROP)
    sortPanel:SetDimensions(150, totalHeight)
    sortPanel:SetAnchor(TOPRIGHT, window, TOPRIGHT, 0, 0)
    sortPanel:SetCenterColor(0, 0, 0, 0.9)
    sortPanel:SetEdgeColor(1, 1, 1, 1)
    sortPanel:SetEdgeTexture("", 8, 1, 1)
    sortPanel:SetAlpha(0.9)

    local searchBackdrop = WINDOW_MANAGER:CreateControl("BankManagerTESOSearchBackdrop", sortPanel, CT_BACKDROP)
    searchBackdrop:SetDimensions(130, 30)
    searchBackdrop:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 50)
    searchBackdrop:SetCenterColor(0.1, 0.1, 0.1, 1)
    searchBackdrop:SetEdgeColor(1, 1, 1, 1)
    searchBackdrop:SetEdgeTexture("", 8, 1, 1)
    searchBackdrop:SetDrawLevel(100)

    local searchEditBox = WINDOW_MANAGER:CreateControl("BankManagerTESOSearchEditBox", sortPanel, CT_EDITBOX)
    searchEditBox:SetDimensions(130, 30)
    searchEditBox:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 50)
    searchEditBox:SetFont("ZoFontGameBold")
    searchEditBox:SetText("")
    searchEditBox:SetColor(1, 1, 1, 1)
    searchEditBox:SetEditEnabled(true)
    searchEditBox:SetMultiLine(false)
    searchEditBox:SetMaxInputChars(50)
    searchEditBox:SetDrawLevel(101)
    searchEditBox:SetMouseEnabled(true)
    searchEditBox:SetHandler("OnMouseDown", function(self) self:TakeFocus() end)
    searchEditBox:SetHandler("OnTextChanged", function(self) searchText = self:GetText() UpdateBankCells() end)
    searchEditBox:SetHandler("OnFocusGained", function(self) self:TakeFocus() end)
    searchEditBox:SetHandler("OnFocusLost", function(self) if self:GetText() == "" then searchText = "" UpdateBankCells() end end)
    searchEditBox:SetHandler("OnEnter", function(self) self:LoseFocus() UpdateBankCells() end)
    searchEditBox:SetHandler("OnEscape", function(self) self:SetText("") searchText = "" self:LoseFocus() UpdateBankCells() end)

    local searchIcon = WINDOW_MANAGER:CreateControl("BankManagerTESOSearchIcon", searchEditBox, CT_TEXTURE)
    searchIcon:SetDimensions(20, 20)
    searchIcon:SetAnchor(LEFT, searchEditBox, LEFT, 5, 0)
    searchIcon:SetTexture("EsoUI/Art/Miscellaneous/search_icon.dds")
    searchIcon:SetDrawLevel(102)

    local function CreateCategoryButton(category, icon, tooltip, xOffset, yOffset)
        local button = WINDOW_MANAGER:CreateControl("BankManagerTESOCategory" .. category, sortPanel, CT_BUTTON)
        button:SetDimensions(40, 40)
        button:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, xOffset, yOffset)
        button:SetHandler("OnMouseEnter", function(self) InitializeTooltip(InformationTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT) InformationTooltip:AddLine(tooltip, "ZoFontGameBold", 1, 1, 1) end)
        button:SetHandler("OnMouseExit", function(self) ClearTooltip(InformationTooltip) end)
        button:SetHandler("OnClicked", function()
            if activeCategory == category then
                activeCategory = nil
                currentCategory = nil
                for cat, btn in pairs(categoryButtons) do btn:SetHidden(false) end
            else
                activeCategory = category
                currentCategory = category
                for cat, btn in pairs(categoryButtons) do btn:SetHidden(cat ~= category) end
            end
            UpdateBankCells()
        end)
        local buttonIcon = WINDOW_MANAGER:CreateControl("BankManagerTESOCategoryIcon" .. category, button, CT_TEXTURE)
        buttonIcon:SetDimensions(40, 40)
        buttonIcon:SetAnchor(CENTER, button, CENTER, 0, 0)
        buttonIcon:SetTexture(icon)
        categoryButtons[category] = button
    end

    CreateCategoryButton("weapon", "EsoUI/Art/Inventory/inventory_tabIcon_weapons_up.dds", "Weapon", 10, 90)
    CreateCategoryButton("armor", "EsoUI/Art/Inventory/inventory_tabIcon_armor_up.dds", "Armor", 60, 90)
    CreateCategoryButton("consumables", "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds", "Consumables", 110, 90)
    CreateCategoryButton("furnishings", "EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds", "Furnishings", 10, 140)
    CreateCategoryButton("crafting", "EsoUI/Art/Inventory/inventory_tabIcon_crafting_up.dds", "Crafting", 60, 140)
    CreateCategoryButton("different", "EsoUI/Art/Inventory/inventory_tabIcon_items_up.dds", "Different", 110, 140)

    for row = 1, 20 do
        for col = 1, 20 do
            local cellIndex = (row - 1) * 20 + col
            local cell = WINDOW_MANAGER:CreateControl("BankManagerTESOCell" .. cellIndex, window, CT_TEXTURE)
            cell:SetDimensions(cellSize, cellSize)
            cell:SetAnchor(TOPLEFT, window, TOPLEFT, (col - 1) * (cellSize + padding) + 20, (row - 1) * (cellSize + padding) + 20)
            cell:SetTexture("EsoUI/Art/Inventory/inventory_slot.dds")
            bankCells[cellIndex] = cell

            local clickControl = WINDOW_MANAGER:CreateControl("BankManagerTESOClickControl" .. cellIndex, window, CT_CONTROL)
            clickControl:SetDimensions(cellSize, cellSize)
            clickControl:SetAnchor(TOPLEFT, window, TOPLEFT, (col - 1) * (cellSize + padding) + 20, (row - 1) * (cellSize + padding) + 20)
            clickControl:SetMouseEnabled(true)
            clickControls[cellIndex] = clickControl

            local checkMark = WINDOW_MANAGER:CreateControl("BankManagerTESOCheckMark" .. cellIndex, cell, CT_TEXTURE)
            checkMark:SetDimensions(18, 18)
            checkMark:SetAnchor(TOPLEFT, cell, TOPLEFT, 2, 2)
            checkMark:SetTexture("EsoUI/Art/Miscellaneous/check.dds")
            checkMark:SetHidden(true)
            checkMark:SetDrawLevel(100)
            checkMarks[cellIndex] = checkMark

            local stackLabel = WINDOW_MANAGER:CreateControl("BankManagerTESOStackLabel" .. cellIndex, cell, CT_LABEL)
            stackLabel:SetFont("ZoFontGameSmall")
            stackLabel:SetColor(1, 1, 1, 1)
            stackLabel:SetAnchor(BOTTOMLEFT, cell, BOTTOMLEFT, 2, -2)
            stackLabel:SetHidden(true)
            stackLabels[cellIndex] = stackLabel

            local lockIcon = WINDOW_MANAGER:CreateControl("BankManagerTESOLockIcon" .. cellIndex, cell, CT_TEXTURE)
            lockIcon:SetDimensions(18, 18)
            lockIcon:SetAnchor(TOPRIGHT, cell, TOPRIGHT, -2, 2)
            lockIcon:SetTexture("EsoUI/Art/Miscellaneous/locked.dds")
            lockIcon:SetHidden(true)
            lockIcons[cellIndex] = lockIcon

            clickControl:SetHandler("OnMouseDown", function(self, button)
                local slotIndex = cellToSlotMapping[cellIndex]
                if not slotIndex then return end
                if button == 1 then
                    if cellStates[cellIndex] == "selected" then
                        cellStates[cellIndex] = nil
                    else
                        cellStates[cellIndex] = "selected"
                    end
                    UpdateCellAppearance(cellIndex)
                elseif button == 2 then
                    ClearMenu()
                    AddMenuItem("Withdraw", function()
                        SafeWithdrawItem(slotIndex)
                        zo_callLater(UpdateBankCells, 200)
                    end)
                    ShowMenu(self)
                end
            end)

            clickControl:SetHandler("OnMouseDoubleClick", function(self, button)
                if button == 1 then
                    local slotIndex = cellToSlotMapping[cellIndex]
                    if slotIndex then
                        SafeWithdrawItem(slotIndex)
                        zo_callLater(UpdateBankCells, 200)
                    end
                end
            end)

            clickControl:SetHandler("OnMouseEnter", function(self)
                local slotIndex = cellToSlotMapping[cellIndex]
                if slotIndex then
                    local itemLink = GetItemLink(BAG_BANK, slotIndex, LINK_STYLE_DEFAULT)
                    if itemLink ~= "" then
                        InitializeTooltip(ItemTooltip, self, TOPLEFT, 0, 0, BOTTOMRIGHT)
                        ItemTooltip:SetLink(itemLink)
                    end
                end
            end)

            clickControl:SetHandler("OnMouseExit", function(self)
                ClearTooltip(ItemTooltip)
            end)
        end
    end

    local selectAllButton = WINDOW_MANAGER:CreateControl("BankManagerTESOSelectAllButton", sortPanel, CT_BUTTON)
    selectAllButton:SetDimensions(130, 30)
    selectAllButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 210)
    selectAllButton:SetText("Select All")
    selectAllButton:SetFont("ZoFontGameBold")
    selectAllButton:SetNormalFontColor(1, 0.5, 0, 1)
    selectAllButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0.8, 0.4, 0, 1) end)
    selectAllButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 0.5, 0, 1) end)
    selectAllButton:SetHandler("OnClicked", function()
        local isAllSelected = false
        for i = 1, 400 do
            if cellStates[i] == "selected" then isAllSelected = true break end
        end
        if not isAllSelected then
            for i = 1, 400 do
                local slotIndex = cellToSlotMapping[i]
                if slotIndex then
                    cellStates[i] = "selected"
                    UpdateCellAppearance(i)
                end
            end
        else
            for i = 1, 400 do
                cellStates[i] = nil
                UpdateCellAppearance(i)
            end
        end
    end)

    local withdrawButton = WINDOW_MANAGER:CreateControl("BankManagerTESOWithdrawButton", sortPanel, CT_BUTTON)
    withdrawButton:SetDimensions(130, 30)
    withdrawButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 250)
    withdrawButton:SetText("Withdraw Selected")
    withdrawButton:SetFont("ZoFontGameBold")
    withdrawButton:SetNormalFontColor(1, 1, 0, 1)
    withdrawButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0.8, 0.8, 0, 1) end)
    withdrawButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 1, 0, 1) end)
    withdrawButton:SetHandler("OnClicked", function()
        local freeSlots = GetNumBagFreeSlots(BAG_BACKPACK)
        local selectedCount = 0
        local itemsToWithdraw = {}
        for i = 1, 400 do
            if cellStates[i] == "selected" then
                local slotIndex = cellToSlotMapping[i]
                if slotIndex then
                    selectedCount = selectedCount + 1
                    table.insert(itemsToWithdraw, { cellIndex = i, slotIndex = slotIndex })
                end
            end
        end
        if freeSlots < selectedCount then return end
        local function withdrawNextItem(index)
            if index > #itemsToWithdraw then
                UpdateBankCells()
                return
            end
            local item = itemsToWithdraw[index]
            if SafeWithdrawItem(item.slotIndex) then
                cellStates[item.cellIndex] = nil
                UpdateCellAppearance(item.cellIndex)
            end
            zo_callLater(function() withdrawNextItem(index + 1) end, 200)
        end
        if #itemsToWithdraw > 0 then withdrawNextItem(1) end
    end)

    local lockButton = WINDOW_MANAGER:CreateControl("BankManagerTESOLockButton", sortPanel, CT_BUTTON)
    lockButton:SetDimensions(130, 30)
    lockButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 290)
    lockButton:SetText("Lock")
    lockButton:SetFont("ZoFontGameBold")
    lockButton:SetNormalFontColor(0, 0, 1, 1)
    lockButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0, 0, 0.8, 1) end)
    lockButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(0, 0, 1, 1) end)
    lockButton:SetHandler("OnClicked", function()
        for i = 1, 400 do
            if cellStates[i] == "selected" then
                local slotIndex = cellToSlotMapping[i]
                if slotIndex then
                    SetItemIsPlayerLocked(BAG_BANK, slotIndex, true)
                end
            end
        end
        ClearSelection()
        zo_callLater(UpdateBankCells, 200)
    end)

    local unlockButton = WINDOW_MANAGER:CreateControl("BankManagerTESOUnlockButton", sortPanel, CT_BUTTON)
    unlockButton:SetDimensions(130, 30)
    unlockButton:SetAnchor(TOPLEFT, sortPanel, TOPLEFT, 10, 330)
    unlockButton:SetText("Unlock")
    unlockButton:SetFont("ZoFontGameBold")
    unlockButton:SetNormalFontColor(0, 1, 0, 1)
    unlockButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0, 0.8, 0, 1) end)
    unlockButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(0, 1, 0, 1) end)
    unlockButton:SetHandler("OnClicked", function()
        for i = 1, 400 do
            if cellStates[i] == "selected" then
                local slotIndex = cellToSlotMapping[i]
                if slotIndex and IsItemPlayerLocked(BAG_BANK, slotIndex) then
                    SetItemIsPlayerLocked(BAG_BANK, slotIndex, false)
                end
            end
        end
        ClearSelection()
        zo_callLater(UpdateBankCells, 200)
    end)

    local goldLabel = WINDOW_MANAGER:CreateControl("BankManagerTESOGoldLabel", sortPanel, CT_LABEL)
    goldLabel:SetFont("ZoFontGameBold")
    goldLabel:SetColor(1, 1, 0, 1)
    goldLabel:SetAnchor(BOTTOMRIGHT, sortPanel, BOTTOMRIGHT, -10, -50)
    goldLabel:SetText("Gold: 0")

    local telvarLabel = WINDOW_MANAGER:CreateControl("BankManagerTESOTelvarLabel", sortPanel, CT_LABEL)
    telvarLabel:SetFont("ZoFontGameBold")
    telvarLabel:SetColor(1, 1, 1, 1)
    telvarLabel:SetAnchor(BOTTOMRIGHT, sortPanel, BOTTOMRIGHT, -10, -30)
    telvarLabel:SetText("Tel Var: 0")

    local bankInfoLabel = WINDOW_MANAGER:CreateControl("BankManagerTESOBankInfoLabel", sortPanel, CT_LABEL)
    bankInfoLabel:SetFont("ZoFontGameBold")
    bankInfoLabel:SetColor(1, 1, 1, 1)
    bankInfoLabel:SetAnchor(BOTTOMRIGHT, sortPanel, BOTTOMRIGHT, -10, -10)
    bankInfoLabel:SetText("0/0")

    local closeButton = WINDOW_MANAGER:CreateControl("BankManagerTESOCloseButton", window, CT_BUTTON)
    closeButton:SetDimensions(30, 30)
    closeButton:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 10)
    closeButton:SetText("X")
    closeButton:SetFont("ZoFontGameBold")
    closeButton:SetNormalFontColor(1, 0, 0, 1)
    closeButton:SetHandler("OnMouseEnter", function(self) self:SetNormalFontColor(0.8, 0, 0, 1) end)
    closeButton:SetHandler("OnMouseExit", function(self) self:SetNormalFontColor(1, 0, 0, 1) end)
    closeButton:SetHandler("OnClicked", function() window:SetHidden(true) ClearSelection() end)
end

local function StartPeriodicUpdate()
    if updateTimer then return end
    local function periodicUpdate()
        if _G["BankManagerTESOWindow"] and not _G["BankManagerTESOWindow"]:IsHidden() then
            UpdateBankCells()
        end
        updateTimer = zo_callLater(periodicUpdate, 200)
    end
    updateTimer = zo_callLater(periodicUpdate, 200)
end

local function StopPeriodicUpdate()
    if updateTimer then updateTimer = nil end
end

local function ToggleBankWindow()
    local window = _G["BankManagerTESOWindow"]
    if window then
        window:SetHidden(not window:IsHidden())
        if not window:IsHidden() then
            UpdateBankCells()
            StartPeriodicUpdate()
        else
            ClearSelection()
            StopPeriodicUpdate()
        end
    end
end

local function CreateCustomButton()
    if _G["BankManagerTESOButton"] then return end
    local button = WINDOW_MANAGER:CreateTopLevelWindow("BankManagerTESOButton")
    button:SetDimensions(291, 36)
    button:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 10, -10)
    button:SetMouseEnabled(true)
    button:SetDrawTier(DT_HIGH)
    button:SetClampedToScreen(true)
    button:SetMovable(false)
    button:SetHidden(true)
    local backdrop = WINDOW_MANAGER:CreateControl("BankManagerTESOButtonBackdrop", button, CT_BACKDROP)
    backdrop:SetAnchorFill()
    backdrop:SetCenterColor(0, 0, 0, 0.8)
    backdrop:SetEdgeColor(1, 1, 1, 1)
    backdrop:SetEdgeTexture("", 8, 1, 1)
    local label = WINDOW_MANAGER:CreateControl("BankManagerTESOButtonLabel", button, CT_LABEL)
    label:SetFont("ZoFontGameBold")
    label:SetColor(0, 1, 0, 1)
    label:SetText("|c00FF00Bank|r|cFF0000Manager|r|cFFD700TESO|r")
    label:SetAnchor(CENTER, button, CENTER, 0, 0)
    label:SetDrawLevel(1)
    button:SetHandler("OnMouseEnter", function(self) label:SetColor(0.8, 1, 0.8, 1) end)
    button:SetHandler("OnMouseExit", function(self) label:SetColor(0, 1, 0, 1) end)
    button:SetHandler("OnMouseUp", function(self, button, upInside) if upInside and button == 1 then ToggleBankWindow() end end)
    _G["BankManagerTESOButton"] = button
end

local function UpdateButtonVisibility()
    local button = _G["BankManagerTESOButton"]
    if button then
        local bankScene = SCENE_MANAGER:GetScene("bank")
        if bankScene and bankScene:IsShowing() then
            button:SetHidden(false)
        else
            button:SetHidden(true)
        end
    end
end

local function OnInventoryUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
    if bagId == BAG_BANK and isBankOpen then
        zo_callLater(UpdateBankCells, 200)
    elseif bagId == BAG_BACKPACK and isBankOpen then
        zo_callLater(UpdateBankCells, 200)
    end
end

local function OnBankItemAdded(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
    if bagId == BAG_BANK and isBankOpen then
        zo_callLater(UpdateBankCells, 200)
    end
end

local function OnBankItemRemoved(eventCode, bagId, slotIndex, itemSoundCategory, updateReason)
    if bagId == BAG_BANK and isBankOpen then
        zo_callLater(UpdateBankCells, 200)
    end
end

local function OnBankOpened(eventCode)
    isBankOpen = true
    local window = _G["BankManagerTESOWindow"]
    if window then
        window:SetHidden(false)
        UpdateBankCells()
        StartPeriodicUpdate()
    end
    UpdateButtonVisibility()
end

local function OnBankClosed(eventCode)
    isBankOpen = false
    local window = _G["BankManagerTESOWindow"]
    if window then
        window:SetHidden(true)
        ClearSelection()
        StopPeriodicUpdate()
    end
    UpdateButtonVisibility()
end

local function OnAddonLoaded(eventCode, loadedAddonName)
    if loadedAddonName ~= addonName then return end
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_BANK, OnBankOpened)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_BANK, OnBankClosed)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventoryUpdate)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_BANK_ITEM_ADDED, OnBankItemAdded)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_BANK_ITEM_REMOVED, OnBankItemRemoved)
    CreateCustomButton()
    local bankScene = SCENE_MANAGER:GetScene("bank")
    if bankScene then
        bankScene:RegisterCallback("StateChange", function(oldState, newState) UpdateButtonVisibility() end)
    end
end

if EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, OnAddonLoaded)
end

zo_callLater(function()
    CreateBankWindow()
    CreateCustomButton()
end, 2000)

_G[addonName] = {
    cellStates = cellStates,
    cellToSlotMapping = cellToSlotMapping,
}