local ISS = {}
ISS.name = "ItemStackSplitter"
ISS.version = "1.0.22"

ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_ACTION", "Split Stack +")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_MODE_TITLE", "Split Options")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_MODE_PROMPT", "Choose how you want to split this stack.")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_MODE_SIZE", "By Stack Size")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_MODE_PIECES", "By Piece Count")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_TITLE", "Split By Stack Size")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_PROMPT", "Choose target size for each new split stack.")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_DONE", "Split complete: <<1>> into stacks of <<2>>")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_FAIL", "Split failed. Try again.")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_INVALID", "Invalid split size.")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_SPACE", "Not enough free bag space.")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_TITLE_PIECES", "Split By Piece Count")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_PROMPT_PIECES", "Choose number of pieces to create.")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_DONE_PIECES", "Split complete: <<1>> into <<2>> pieces")
ZO_CreateStringId("SI_ITEM_STACK_SPLITTER_INVALID_PIECES", "Invalid piece count.")

local SV_DEFAULTS =
{
    lastSplitSize = 3,
    lastPieces = 2,
    chatVerbose = false,
}

local function Clamp(val, minVal, maxVal)
    return zo_min(maxVal, zo_max(minVal, val))
end

local function RoundDownInt(val)
    return zo_floor((val or 0) + 0.0001)
end

function ISS:Chat(text)
    if CHAT_ROUTER and CHAT_ROUTER.AddSystemMessage then
        CHAT_ROUTER:AddSystemMessage(zo_strformat("[Item Stack Splitter] <<1>>", text))
    end
end

function ISS:IsEligibleSlot(inventorySlotControl)
    if not inventorySlotControl or not ZO_Inventory_GetBagAndIndex then
        return false
    end

    local slotData = ZO_Inventory_GetSlotDataForInventoryControl and ZO_Inventory_GetSlotDataForInventoryControl(inventorySlotControl)
    if not slotData then
        return false
    end

    if slotData.locked then
        return false
    end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlotControl)
    if not bagId or not slotIndex then
        return false
    end

    if bagId ~= BAG_BACKPACK then
        return false
    end

    local stackSize = GetSlotStackSize and GetSlotStackSize(bagId, slotIndex) or 0
    if stackSize <= 1 then
        return false
    end

    if ZO_InventorySlot_IsSplittableType and not ZO_InventorySlot_IsSplittableType(inventorySlotControl) then
        return false
    end

    return true, bagId, slotIndex, stackSize
end

function ISS:BuildChunkPlan(totalCount, pieces)
    local chunkPlan = {}
    local base = zo_floor(totalCount / pieces)
    local remainder = totalCount % pieces
    for i = 1, pieces do
        local amount = base
        if i <= remainder then
            amount = amount + 1
        end
        chunkPlan[i] = amount
    end
    return chunkPlan
end

function ISS:ResolveSplitSourceSlot(bagId, slotIndex, itemLink, minStack)
    if GetSlotStackSize and GetSlotStackSize(bagId, slotIndex) > 0 then
        return bagId, slotIndex
    end

    local bestSlot = slotIndex
    local bestCount = 0
    local bagSize = GetBagSize and GetBagSize(bagId) or 0
    for i = 0, bagSize - 1 do
        local count = GetSlotStackSize and GetSlotStackSize(bagId, i) or 0
        if count and count > 0 then
            local match = true
            if itemLink and GetItemLink then
                local link = GetItemLink(bagId, i)
                match = (link == itemLink)
            end
            if match and count >= (minStack or 1) and count > bestCount then
                bestCount = count
                bestSlot = i
            end
        end
    end

    return bagId, bestSlot
end

function ISS:RunSplitQueue()
    local queue = self.splitQueue
    if not queue then
        self.splitInProgress = false
        if self.standaloneWindow and not self.standaloneWindow:IsHidden() then
            self:BuildStandaloneItems()
            self:RefreshStandaloneWindow()
        end
        return
    end
    queue.ops = (queue.ops or 0) + 1
    if queue.ops > 300 then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        self.splitQueue = nil
        self.splitInProgress = false
        return
    end

    local mode = queue.mode or "size"
    local minStack = (queue.mode == "size") and (queue.splitSize or 1) or 1
    local bagId, slotIndex = self:ResolveSplitSourceSlot(queue.bagId, queue.slotIndex, queue.itemLink, minStack)
    local currentStack = GetSlotStackSize and GetSlotStackSize(bagId, slotIndex) or 0

    local amount
    if mode == "pieces" then
        local i = queue.nextIndex or 1
        local maxSplitOps = queue.totalOps or 0
        if i > maxSplitOps then
            self.splitQueue = nil
            self.splitInProgress = false
            if self.standaloneWindow and not self.standaloneWindow:IsHidden() then
                self:BuildStandaloneItems()
                self:RefreshStandaloneWindow()
            end
            return
        end
        amount = queue.chunkPlan and queue.chunkPlan[i]
        if not amount or amount <= 0 or amount >= currentStack then
            self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
            self.splitQueue = nil
            self.splitInProgress = false
            return
        end
        queue.nextIndex = i + 1
    else
        local splitSize = queue.splitSize
        if currentStack <= splitSize then
            self.splitQueue = nil
            self.splitInProgress = false
            if self.standaloneWindow and not self.standaloneWindow:IsHidden() then
                self:BuildStandaloneItems()
                self:RefreshStandaloneWindow()
            end
            return
        end
        amount = splitSize
    end

    if amount <= 0 or amount >= currentStack then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        self.splitQueue = nil
        self.splitInProgress = false
        return
    end

    local targetBag = BAG_BACKPACK
    local emptySlot = FindFirstEmptySlotInBag and FindFirstEmptySlotInBag(targetBag)
    if not emptySlot then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_SPACE))
        self.splitQueue = nil
        self.splitInProgress = false
        return
    end

    local moveOk = false
    if CallSecureProtected then
        local ok, result = pcall(CallSecureProtected, "RequestMoveItem", bagId, slotIndex, targetBag, emptySlot, amount)
        moveOk = ok and (result ~= false)
    elseif RequestMoveItem then
        local ok, result = pcall(RequestMoveItem, bagId, slotIndex, targetBag, emptySlot, amount)
        moveOk = ok and (result ~= false)
    end
    if not moveOk then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        self.splitQueue = nil
        self.splitInProgress = false
        return
    end

    zo_callLater(function()
        if not self.splitQueue then
            self.splitInProgress = false
            return
        end
        local minStackCheck = (queue.mode == "size") and (queue.splitSize or 1) or 1
        local checkBag, checkSlot = self:ResolveSplitSourceSlot(queue.bagId, queue.slotIndex, queue.itemLink, minStackCheck)
        local newStack = GetSlotStackSize and GetSlotStackSize(checkBag, checkSlot) or 0
        if newStack >= currentStack then
            queue.noProgress = (queue.noProgress or 0) + 1
            if queue.noProgress >= 10 then
                self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
                self.splitQueue = nil
                self.splitInProgress = false
                return
            end
        else
            queue.noProgress = 0
        end
        if self.standaloneWindow and not self.standaloneWindow:IsHidden() then
            self:BuildStandaloneItems()
            self:RefreshStandaloneWindow()
        end
        self:RunSplitQueue()
    end, 250)
end

function ISS:StartSplitBySize(bagId, slotIndex, stackSize, splitSize)
    if self.splitInProgress or self.splitQueue then
        return
    end
    splitSize = Clamp(RoundDownInt(splitSize), 1, zo_max(1, stackSize - 1))
    if splitSize < 1 or splitSize >= stackSize then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_INVALID))
        return
    end

    local freeSlots = GetNumBagFreeSlots and GetNumBagFreeSlots(BAG_BACKPACK) or 0
    local needed = zo_ceil(stackSize / splitSize) - 1
    if freeSlots < needed then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_SPACE))
        return
    end

    self.savedVars.lastSplitSize = splitSize
    self.splitQueue =
    {
        mode = "size",
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = GetItemLink and GetItemLink(bagId, slotIndex) or nil,
        originalCount = stackSize,
        splitSize = splitSize,
    }
    self.splitInProgress = true
    self:RunSplitQueue()
end

function ISS:StartSplitByPieces(bagId, slotIndex, stackSize, pieces)
    if self.splitInProgress or self.splitQueue then
        return
    end
    pieces = Clamp(RoundDownInt(pieces), 2, stackSize)
    if pieces < 2 or pieces > stackSize then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_INVALID_PIECES))
        return
    end

    local freeSlots = GetNumBagFreeSlots and GetNumBagFreeSlots(BAG_BACKPACK) or 0
    local needed = pieces - 1
    if freeSlots < needed then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_SPACE))
        return
    end

    local chunkPlan = self:BuildChunkPlan(stackSize, pieces)
    self.savedVars.lastPieces = pieces
    self.splitQueue =
    {
        mode = "pieces",
        bagId = bagId,
        slotIndex = slotIndex,
        itemLink = GetItemLink and GetItemLink(bagId, slotIndex) or nil,
        originalCount = stackSize,
        pieces = pieces,
        chunkPlan = chunkPlan,
        nextIndex = 1,
        totalOps = pieces - 1,
    }
    self.splitInProgress = true
    self:RunSplitQueue()
end

function ISS:RefreshPiecePreview(stackControl)
    local sliderValue = stackControl.spinner and stackControl.spinner:GetValue() or 2
    local amountA, amountB
    if stackControl.mode == "pieces" then
        local pieces = Clamp(RoundDownInt(sliderValue), 2, stackControl.stackSize)
        amountA = zo_floor(stackControl.stackSize / pieces)
        amountB = stackControl.stackSize - amountA
    else
        local splitSize = Clamp(RoundDownInt(sliderValue), 1, zo_max(1, stackControl.stackSize - 1))
        amountA = splitSize
        amountB = stackControl.stackSize - splitSize
    end

    local stackLabelA = GetControl(stackControl, "Destination1StackCount")
    local stackLabelB = GetControl(stackControl, "Destination2StackCount")
    if stackLabelA then
        stackLabelA:SetText(amountA)
    end
    if stackLabelB then
        stackLabelB:SetText(amountB)
    end
end

function ISS:SetupPieceDialog(stackControl, dialogData)
    if not dialogData then
        return
    end

    stackControl.stackSize = dialogData.stackSize
    stackControl.bagId = dialogData.bagId
    stackControl.slotIndex = dialogData.slotIndex
    stackControl.mode = dialogData.mode or "size"

    local itemIcon, _, _, _, _, _, _, _, displayQuality = GetItemInfo(dialogData.bagId, dialogData.slotIndex)
    local itemName = GetItemName(dialogData.bagId, dialogData.slotIndex)
    local qualityColor = GetItemQualityColor(displayQuality)
    local prompt = GetControl(stackControl, "Prompt")
    if prompt then
        local promptText = stackControl.mode == "pieces" and GetString(SI_ITEM_STACK_SPLITTER_PROMPT_PIECES) or GetString(SI_ITEM_STACK_SPLITTER_PROMPT)
        local text = zo_strformat("<<1>>\n<<2>>", promptText, qualityColor:Colorize(itemName))
        prompt:SetText(text)
    end

    local sourceSlot = GetControl(stackControl, "Source")
    local destinationSlot1 = GetControl(stackControl, "Destination1")
    local destinationSlot2 = GetControl(stackControl, "Destination2")
    if sourceSlot then
        ZO_ItemSlot_SetupSlot(sourceSlot, dialogData.stackSize, itemIcon)
        ZO_Inventory_BindSlot(sourceSlot, SLOT_TYPE_STACK_SPLIT, dialogData.slotIndex, dialogData.bagId)
    end
    if destinationSlot1 then
        ZO_ItemSlot_SetupSlot(destinationSlot1, 0, itemIcon)
        ZO_Inventory_BindSlot(destinationSlot1, SLOT_TYPE_STACK_SPLIT, dialogData.slotIndex, dialogData.bagId)
    end
    if destinationSlot2 then
        ZO_ItemSlot_SetupSlot(destinationSlot2, 0, itemIcon)
        ZO_Inventory_BindSlot(destinationSlot2, SLOT_TYPE_STACK_SPLIT, dialogData.slotIndex, dialogData.bagId)
    end

    local minPieces, maxPieces
    local startValue
    if stackControl.mode == "pieces" then
        minPieces, maxPieces = 2, dialogData.stackSize
        startValue = Clamp(self.savedVars.lastPieces or 2, minPieces, maxPieces)
    else
        minPieces, maxPieces = 1, zo_max(1, dialogData.stackSize - 1)
        startValue = Clamp(self.savedVars.lastSplitSize or 3, minPieces, maxPieces)
    end
    if stackControl.spinner then
        stackControl.spinner:SetMinMax(minPieces, maxPieces)
        stackControl.spinner:SetValue(startValue)
    end
    self:RefreshPiecePreview(stackControl)
end

function ISS:ShowPieceDialog(bagId, slotIndex, stackSize, mode)
    self:EnsureRuntimeReady()
    local canShow = (ZO_Dialogs_ShowPlatformDialog ~= nil)
        or (ZO_Dialogs_ShowGamepadDialog ~= nil)
        or (ZO_Dialogs_ShowDialog ~= nil)
    if not canShow then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        return false
    end

    local dialogData =
    {
        bagId = bagId,
        slotIndex = slotIndex,
        stackSize = stackSize,
        mode = mode or "size",
    }
    zo_callLater(function()
        local shown = false
        if ZO_Dialogs_ShowDialog then
            local ok = pcall(ZO_Dialogs_ShowDialog, "ITEM_STACK_SPLITTER_VALUE_DIALOG", dialogData)
            shown = ok and true or false
        end
        if not shown and IsInGamepadPreferredMode and IsInGamepadPreferredMode() and ZO_Dialogs_ShowGamepadDialog then
            local ok = pcall(ZO_Dialogs_ShowGamepadDialog, "ITEM_STACK_SPLITTER_VALUE_DIALOG", dialogData)
            shown = ok and true or false
        end
        if not shown and ZO_Dialogs_ShowPlatformDialog then
            local ok = pcall(ZO_Dialogs_ShowPlatformDialog, "ITEM_STACK_SPLITTER_VALUE_DIALOG", dialogData)
            shown = ok and true or false
        end
        if not shown and self.originalSplitFn and bagId and slotIndex then
            local fallbackName = "ISS_FallbackSlot" .. tostring((GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0)
            local tempControl = WINDOW_MANAGER and WINDOW_MANAGER:CreateControl(fallbackName, GuiRoot, CT_CONTROL)
            if tempControl and ZO_Inventory_BindSlot then
                ZO_Inventory_BindSlot(tempControl, SLOT_TYPE_ITEM, slotIndex, bagId)
                pcall(self.originalSplitFn, tempControl)
                shown = true
            end
        end
        if not shown then
            self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        end
    end, 10)
    return true
end

function ISS:ShowModeDialog(bagId, slotIndex, stackSize)
    self:EnsureRuntimeReady()
    local canShow = (ZO_Dialogs_ShowPlatformDialog ~= nil)
        or (ZO_Dialogs_ShowGamepadDialog ~= nil)
        or (ZO_Dialogs_ShowDialog ~= nil)
    if not canShow then
        self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        return false
    end

    local dialogData =
    {
        bagId = bagId,
        slotIndex = slotIndex,
        stackSize = stackSize,
    }
    zo_callLater(function()
        local shown = false
        if ZO_Dialogs_ShowDialog then
            local ok = pcall(ZO_Dialogs_ShowDialog, "ITEM_STACK_SPLITTER_MODE_DIALOG", dialogData)
            shown = ok and true or false
        end
        if not shown and IsInGamepadPreferredMode and IsInGamepadPreferredMode() and ZO_Dialogs_ShowGamepadDialog then
            local ok = pcall(ZO_Dialogs_ShowGamepadDialog, "ITEM_STACK_SPLITTER_MODE_DIALOG", dialogData)
            shown = ok and true or false
        end
        if not shown and ZO_Dialogs_ShowPlatformDialog then
            local ok = pcall(ZO_Dialogs_ShowPlatformDialog, "ITEM_STACK_SPLITTER_MODE_DIALOG", dialogData)
            shown = ok and true or false
        end
        if not shown then
            -- fallback to a direct value prompt so user always gets a working flow
            self:ShowPieceDialog(dialogData.bagId, dialogData.slotIndex, dialogData.stackSize, "size")
        end
    end, 10)
    return true
end

function ISS:ShowModeForInventorySlot(inventorySlotControl)
    local ok, bagId, slotIndex, stackSize = self:IsEligibleSlot(inventorySlotControl)
    if not ok then
        return false
    end
    return self:ShowModeDialog(bagId, slotIndex, stackSize)
end

function ISS:InjectSplitAction(slotActions)
    if not slotActions or not slotActions.m_inventorySlot then
        return
    end

    local inventorySlot = slotActions.m_inventorySlot
    local ok, bagId, slotIndex, stackSize = self:IsEligibleSlot(inventorySlot)
    if not ok then
        return
    end

    slotActions:AddSlotAction(SI_ITEM_STACK_SPLITTER_ACTION,
    function()
        local opened = self:ShowModeDialog(bagId, slotIndex, stackSize)
        if not opened then
            self:Chat(GetString(SI_ITEM_STACK_SPLITTER_FAIL))
        end
    end,
    "secondary")
end

function ISS:RegisterPieceDialog()
    if self.dialogRegistered then
        return
    end

    if not ZO_StackSplit or not ZO_Dialogs_RegisterCustomDialog then
        return
    end

    ZO_Dialogs_RegisterCustomDialog("ITEM_STACK_SPLITTER_VALUE_DIALOG",
    {
        customControl = ZO_StackSplit,
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        setup = function(stackControl, dialogData)
            self:SetupPieceDialog(stackControl, dialogData)
        end,
        title =
        {
            text = function(dialog)
                local mode = dialog and dialog.data and dialog.data.mode
                if mode == "pieces" then
                    return GetString(SI_ITEM_STACK_SPLITTER_TITLE_PIECES)
                end
                return GetString(SI_ITEM_STACK_SPLITTER_TITLE)
            end,
        },
        buttons =
        {
            [1] =
            {
                control = GetControl(ZO_StackSplit, "Split"),
                text = SI_INVENTORY_SPLIT_STACK,
                callback = function(stackControl)
                    if stackControl.mode == "pieces" then
                        local pieces = stackControl.spinner and RoundDownInt(stackControl.spinner:GetValue()) or 2
                        self:StartSplitByPieces(stackControl.bagId, stackControl.slotIndex, stackControl.stackSize, pieces)
                    else
                        local splitSize = stackControl.spinner and RoundDownInt(stackControl.spinner:GetValue()) or 3
                        self:StartSplitBySize(stackControl.bagId, stackControl.slotIndex, stackControl.stackSize, splitSize)
                    end
                end,
            },
            [2] =
            {
                control = GetControl(ZO_StackSplit, "Cancel"),
                text = SI_DIALOG_CANCEL,
            },
        },
    })

    if ZO_StackSplit.spinner then
        ZO_StackSplit.spinner:RegisterCallback("OnValueChanged", function()
            self:RefreshPiecePreview(ZO_StackSplit)
        end)
    end

    self.dialogRegistered = true
end

function ISS:RegisterModeDialog()
    if self.modeDialogRegistered then
        return
    end

    if not ZO_Dialogs_RegisterCustomDialog then
        return
    end

    ZO_Dialogs_RegisterCustomDialog("ITEM_STACK_SPLITTER_MODE_DIALOG",
    {
        title = { text = SI_ITEM_STACK_SPLITTER_MODE_TITLE },
        mainText = { text = SI_ITEM_STACK_SPLITTER_MODE_PROMPT },
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        buttons =
        {
            [1] =
            {
                text = SI_ITEM_STACK_SPLITTER_MODE_SIZE,
                callback = function(dialog)
                    local data = dialog and dialog.data
                    if data then
                        self:ShowPieceDialog(data.bagId, data.slotIndex, data.stackSize, "size")
                    end
                end,
            },
            [2] =
            {
                text = SI_ITEM_STACK_SPLITTER_MODE_PIECES,
                callback = function(dialog)
                    local data = dialog and dialog.data
                    if data then
                        self:ShowPieceDialog(data.bagId, data.slotIndex, data.stackSize, "pieces")
                    end
                end,
            },
            [3] =
            {
                text = SI_DIALOG_CANCEL,
            },
        },
    })

    self.modeDialogRegistered = true
end

function ISS:HookDefaultSplitAction()
    if self.defaultSplitHooked then
        return
    end
    -- Keep native ESO split flow intact; custom splitter remains available via /iss.
    self.defaultSplitHooked = true
end

function ISS:EnsureRuntimeReady()
    self:RegisterModeDialog()
    self:RegisterPieceDialog()
    self:HookDefaultSplitAction()
end

function ISS:StartRuntimeReadyPoll()
    if self.runtimeReadyPollStarted then
        return
    end
    self.runtimeReadyPollStarted = true

    local pollName = self.name .. "_RuntimeReadyPoll"
    local tries = 0
    EVENT_MANAGER:RegisterForUpdate(pollName, 1000, function()
        tries = tries + 1
        self:EnsureRuntimeReady()
        if self.modeDialogRegistered and self.dialogRegistered then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
        elseif tries >= 30 then
            EVENT_MANAGER:UnregisterForUpdate(pollName)
        end
    end)
end

function ISS:BuildStandaloneItems()
    local items = {}
    local bagSize = GetBagSize and GetBagSize(BAG_BACKPACK) or 0
    for slotIndex = 0, bagSize - 1 do
        local stackSize = GetSlotStackSize and GetSlotStackSize(BAG_BACKPACK, slotIndex) or 0
        if stackSize and stackSize > 1 then
            local stackable = true
            if IsItemStackable then
                local ok, result = pcall(IsItemStackable, BAG_BACKPACK, slotIndex)
                if ok then
                    stackable = result
                end
            end
            if stackable then
                local name = GetItemName and zo_strformat("<<1>>", GetItemName(BAG_BACKPACK, slotIndex)) or ("Slot " .. tostring(slotIndex))
                table.insert(items,
                {
                    bagId = BAG_BACKPACK,
                    slotIndex = slotIndex,
                    name = name,
                    stackSize = stackSize,
                })
            end
        end
    end

    table.sort(items, function(a, b)
        if a.name == b.name then
            return a.slotIndex < b.slotIndex
        end
        return a.name < b.name
    end)

    self.standaloneItemsAll = items
    self:ApplyStandaloneSearchFilter()
end

function ISS:ApplyStandaloneSearchFilter()
    local source = self.standaloneItemsAll or {}
    local filter = (self.standaloneSearchText or ""):lower()
    local filtered = {}
    if filter == "" then
        filtered = source
    else
        for _, item in ipairs(source) do
            local name = (item.name or ""):lower()
            if name:find(filter, 1, true) then
                table.insert(filtered, item)
            end
        end
    end

    self.standaloneItems = filtered
    local items = self.standaloneItems
    if #items == 0 then
        self.standaloneSelectedIndex = 1
        self.standaloneScrollOffset = 0
        return
    end

    self.standaloneSelectedIndex = Clamp(self.standaloneSelectedIndex or 1, 1, #items)
    self.standaloneScrollOffset = zo_max(0, zo_min(self.standaloneScrollOffset or 0, zo_max(0, #items - 12)))
end

function ISS:RefreshStandaloneWindow()
    if not self.standaloneWindow then
        return
    end

    local items = self.standaloneItems or {}
    local selected = items[self.standaloneSelectedIndex or 1]
    local maxRows = 12
    local total = #items

    if selected then
        local maxSplit = zo_max(1, selected.stackSize - 1)
        self.standaloneSplitSize = Clamp(self.standaloneSplitSize or self.savedVars.lastSplitSize or 3, 1, maxSplit)
        self.savedVars.lastSplitSize = self.standaloneSplitSize
    end

    if self.standaloneTitle then
        self.standaloneTitle:SetText("Item Stack Splitter")
    end
    if self.standaloneHint then
        if total == 0 then
            self.standaloneHint:SetText("No stackable items with count > 1 found in backpack.")
        else
            local splitText = selected and tostring(self.standaloneSplitSize or 3) or "-"
            local searchText = self.standaloneSearchText or ""
            if searchText ~= "" then
                self.standaloneHint:SetText("Split size: " .. splitText .. "  |  Items: " .. tostring(total) .. "  |  Search: " .. searchText)
            else
                self.standaloneHint:SetText("Split size: " .. splitText .. "  |  Items: " .. tostring(total))
            end
        end
    end
    if self.standaloneStatus then
        if self.splitInProgress or self.splitQueue then
            self.standaloneStatus:SetText("|cE8C05CSplitting... please wait|r")
        else
            self.standaloneStatus:SetText("|c4CAF50Ready|r")
        end
    end

    for i = 1, maxRows do
        local row = self.standaloneRows[i]
        if row then
            local idx = (self.standaloneScrollOffset or 0) + i
            local item = items[idx]
            if item then
                row:SetHidden(false)
                local marker = (idx == (self.standaloneSelectedIndex or 1)) and "> " or "  "
                row:SetText(marker .. item.name .. " x" .. tostring(item.stackSize))
                if idx == (self.standaloneSelectedIndex or 1) then
                    row:SetColor(0.95, 0.78, 0.36, 1)
                else
                    row:SetColor(1, 1, 1, 1)
                end
            else
                row:SetHidden(true)
            end
        end
    end
end

function ISS:MoveStandaloneSelection(delta)
    local items = self.standaloneItems or {}
    if #items == 0 then
        return
    end
    local maxRows = 12
    local newIndex = Clamp((self.standaloneSelectedIndex or 1) + delta, 1, #items)
    self.standaloneSelectedIndex = newIndex

    local minVisible = (self.standaloneScrollOffset or 0) + 1
    local maxVisible = (self.standaloneScrollOffset or 0) + maxRows
    if newIndex < minVisible then
        self.standaloneScrollOffset = newIndex - 1
    elseif newIndex > maxVisible then
        self.standaloneScrollOffset = newIndex - maxRows
    end
    self.standaloneScrollOffset = zo_max(0, self.standaloneScrollOffset)

    self:RefreshStandaloneWindow()
end

function ISS:AdjustStandaloneSplitSize(delta)
    local items = self.standaloneItems or {}
    local selected = items[self.standaloneSelectedIndex or 1]
    if not selected then
        return
    end
    local maxSplit = zo_max(1, selected.stackSize - 1)
    self.standaloneSplitSize = Clamp((self.standaloneSplitSize or self.savedVars.lastSplitSize or 3) + delta, 1, maxSplit)
    self.savedVars.lastSplitSize = self.standaloneSplitSize
    self:RefreshStandaloneWindow()
end

function ISS:SplitStandaloneSelected()
    if self.splitInProgress or self.splitQueue then
        return
    end

    local items = self.standaloneItems or {}
    local selected = items[self.standaloneSelectedIndex or 1]
    if not selected then
        self:Chat("No stack selected.")
        return
    end
    self:StartSplitBySize(selected.bagId, selected.slotIndex, selected.stackSize, self.standaloneSplitSize or 3)
    self:RefreshStandaloneWindow()
end

function ISS:EnsureStandaloneWindow()
    if self.standaloneWindow then
        return
    end

    local window = WINDOW_MANAGER:CreateTopLevelWindow("ISS_StandaloneWindow")
    window:SetDimensions(1200, 700)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetMouseEnabled(false)
    window:SetMovable(false)
    window:SetHidden(true)

    local bg = WINDOW_MANAGER:CreateControl("ISS_StandaloneWindowBG", window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.04, 0.04, 0.04, 0.95)
    bg:SetEdgeColor(0.92, 0.76, 0.36, 0.8)
    bg:SetEdgeTexture("", 2, 2, 2, 0)

    local title = WINDOW_MANAGER:CreateControl("ISS_StandaloneTitle", window, CT_LABEL)
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 30, 20)
    title:SetDimensions(700, 40)
    title:SetFont("$(BOLD_FONT)|34|soft-shadow-thick")
    title:SetColor(0.95, 0.78, 0.36, 1)

    local hint = WINDOW_MANAGER:CreateControl("ISS_StandaloneHint", window, CT_LABEL)
    hint:SetAnchor(TOPLEFT, window, TOPLEFT, 30, 70)
    hint:SetDimensions(1100, 34)
    hint:SetFont("$(MEDIUM_FONT)|24|soft-shadow-thin")
    hint:SetColor(1, 1, 1, 1)

    local searchBox = WINDOW_MANAGER:CreateControlFromVirtual("ISS_StandaloneSearchBox", window, "ZO_DefaultEditForBackdrop")
    searchBox:ClearAnchors()
    searchBox:SetAnchor(TOPRIGHT, window, TOPRIGHT, -30, 22)
    searchBox:SetDimensions(330, 40)
    searchBox:SetText("")
    searchBox:SetMaxInputChars(60)
    searchBox:SetHidden(false)
    searchBox:SetHandler("OnTextChanged", function(ctrl)
        self.standaloneSearchText = ctrl:GetText() or ""
        self:ApplyStandaloneSearchFilter()
        self:RefreshStandaloneWindow()
    end)
    searchBox:SetHandler("OnEscape", function(ctrl)
        ctrl:SetText("")
        self.standaloneSearchText = ""
        ctrl:LoseFocus()
        self:ApplyStandaloneSearchFilter()
        self:RefreshStandaloneWindow()
    end)
    searchBox:SetHandler("OnFocusLost", function(ctrl)
        self.standaloneSearchText = ctrl:GetText() or ""
        self:ApplyStandaloneSearchFilter()
        self:RefreshStandaloneWindow()
    end)

    local status = WINDOW_MANAGER:CreateControl("ISS_StandaloneStatus", window, CT_LABEL)
    status:SetAnchor(TOPLEFT, window, TOPLEFT, 30, 104)
    status:SetDimensions(1100, 30)
    status:SetFont("$(MEDIUM_FONT)|22|soft-shadow-thin")
    status:SetColor(0.3, 0.9, 0.4, 1)

    local rows = {}
    for i = 1, 12 do
        local row = WINDOW_MANAGER:CreateControl("ISS_StandaloneRow" .. tostring(i), window, CT_LABEL)
        row:SetAnchor(TOPLEFT, window, TOPLEFT, 30, 150 + ((i - 1) * 42))
        row:SetDimensions(1120, 40)
        row:SetFont("$(MEDIUM_FONT)|30|soft-shadow-thin")
        row:SetColor(1, 1, 1, 1)
        rows[i] = row
    end

    self.standaloneWindow = window
    self.standaloneTitle = title
    self.standaloneHint = hint
    self.standaloneSearchBox = searchBox
    self.standaloneStatus = status
    self.standaloneRows = rows
    self.standaloneSelectedIndex = 1
    self.standaloneScrollOffset = 0
    self.standaloneSplitSize = self.savedVars and self.savedVars.lastSplitSize or 3

    local fragment = ZO_SimpleSceneFragment:New(window)
    local scene = ZO_Scene:New("issStandaloneScene", SCENE_MANAGER)
    scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    scene:AddFragment(fragment)

    self.standaloneKeybind =
    {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            keybind = "UI_SHORTCUT_NEGATIVE",
            name = GetString(SI_GAMEPAD_BACK_OPTION),
            callback = function()
                SCENE_MANAGER:HideCurrentScene()
            end,
        },
        {
            keybind = "UI_SHORTCUT_PRIMARY",
            name = function()
                if self.splitInProgress or self.splitQueue then
                    return "Splitting..."
                end
                return "Split Selected"
            end,
            callback = function()
                if not (self.splitInProgress or self.splitQueue) then
                    self:SplitStandaloneSelected()
                end
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_TRIGGER",
            name = "Up",
            callback = function()
                self:MoveStandaloneSelection(-1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
            name = "Down",
            callback = function()
                self:MoveStandaloneSelection(1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            name = "Size -",
            callback = function()
                self:AdjustStandaloneSplitSize(-1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            name = "Size +",
            callback = function()
                self:AdjustStandaloneSplitSize(1)
            end,
        },
        {
            keybind = "UI_SHORTCUT_SECONDARY",
            name = "Refresh",
            callback = function()
                self:BuildStandaloneItems()
                self:RefreshStandaloneWindow()
            end,
        },
        {
            keybind = "UI_SHORTCUT_TERTIARY",
            name = "Search",
            callback = function()
                if self.standaloneSearchBox then
                    self.standaloneSearchBox:TakeFocus()
                end
            end,
        },
    }

    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            self:BuildStandaloneItems()
            if self.standaloneSearchBox then
                self.standaloneSearchBox:SetText(self.standaloneSearchText or "")
            end
            self:RefreshStandaloneWindow()
            self.standaloneLastJoyDir = 0
            self.standaloneLastJoyMs = 0
            KEYBIND_STRIP:AddKeybindButtonGroup(self.standaloneKeybind)
            EVENT_MANAGER:RegisterForUpdate(self.name .. "_StandaloneJoyPoll", 120, function()
                self:PollStandaloneJoystick()
            end)
        elseif newState == SCENE_HIDDEN then
            KEYBIND_STRIP:RemoveKeybindButtonGroup(self.standaloneKeybind)
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "_StandaloneJoyPoll")
        end
    end)
end

function ISS:ShowStandaloneWindow()
    self:EnsureStandaloneWindow()
    SCENE_MANAGER:Show("issStandaloneScene")
end

function ISS:PollStandaloneJoystick()
    if not self.standaloneWindow or self.standaloneWindow:IsHidden() then
        return
    end
    if self.splitQueue then
        return
    end

    local stickY = nil
    if GetGamepadLeftStickY then
        local ok, value = pcall(GetGamepadLeftStickY)
        if ok and type(value) == "number" then
            stickY = value
        end
    end
    if type(stickY) ~= "number" then
        return
    end

    local direction = 0
    if stickY >= 0.5 then
        direction = -1
    elseif stickY <= -0.5 then
        direction = 1
    end

    local nowMs = (GetFrameTimeMilliseconds and GetFrameTimeMilliseconds()) or 0
    if direction == 0 then
        self.standaloneLastJoyDir = 0
        return
    end

    if self.standaloneLastJoyDir ~= direction
        or not self.standaloneLastJoyMs
        or (nowMs - self.standaloneLastJoyMs) >= 180 then
        self:MoveStandaloneSelection(direction)
        self.standaloneLastJoyDir = direction
        self.standaloneLastJoyMs = nowMs
    end
end

function ISS:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide("ItemStackSplitterSV", 1, nil, SV_DEFAULTS)
    self:EnsureRuntimeReady()
    self:StartRuntimeReadyPoll()

    ZO_PreHook(ZO_InventorySlotActions, "Show", function(slotActions)
        self:InjectSplitAction(slotActions)
    end)

    SLASH_COMMANDS["/iss"] = function()
        self:ShowStandaloneWindow()
    end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ISS.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(ISS.name, EVENT_ADD_ON_LOADED)
    ISS:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ISS.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
EVENT_MANAGER:RegisterForEvent(ISS.name .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
    ISS:EnsureRuntimeReady()
end)
