AutoBank_TransferQueue = {}

function AutoBank_TransferQueue:Initialize(core)
    self.core = core
    self.queue = {}
    self.processing = false
    self.recentTransfers = {}
    self.failedTransfers = {}
end

function AutoBank_TransferQueue:Queue(bagId, slotIndex)
    table.insert(self.queue, {
        bagId = bagId,
        slotIndex = slotIndex
    })
end

function AutoBank_TransferQueue:Start()
    if self.processing then return end
    self.processing = true
    self:ProcessNext()
end

function AutoBank_TransferQueue:ProcessNext()
    if #self.queue == 0 then
        self.processing = false
        self.core:Debug("Transfer complete.")

        -- Show a batched alert with counts when enabled, otherwise default message
        if self.core and self.core.savedVars and self.core.savedVars.showPerItemAlerts and next(self.recentTransfers) then
            local lines = {}
            for _, v in pairs(self.recentTransfers) do
                local displayText = tostring(v.display)
                if v.icon then
                    displayText = "|t24:24:" .. tostring(v.icon) .. "|t " .. displayText
                end
                table.insert(lines, displayText .. " (" .. tostring(v.count) .. ")")
            end
            local body = table.concat(lines, "\n")
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "AutoBank: Transfer completed successfully!\n" .. body)
        elseif next(self.recentTransfers) then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "AutoBank: Transfer completed successfully!")
        end

        -- Report any failed transfers
        if next(self.failedTransfers) then
            local failLines = {}
            for _, v in pairs(self.failedTransfers) do
                table.insert(failLines, tostring(v.display) .. " (" .. tostring(v.count) .. ")")
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, "|cFF4444AutoBank: Could not deposit:\n" .. table.concat(failLines, "\n") .. "|r")
        end

        -- clear stored transfers for next run
        self.recentTransfers = {}
        self.failedTransfers = {}
        return
    end

    -- Bank space should have been checked upfront; remove hard stop so stackable items can still deposit
    if GetNumBagFreeSlots(BAG_BANK) <= 0 then
        self.core:Debug("WARNING: No free bank slots; will still attempt transfers for stackable items.")
    end

    local item = table.remove(self.queue, 1)
    
    self.core:Debug("Attempting to transfer item from bag " .. item.bagId .. " slot " .. item.slotIndex)

    local itemLink = nil
    local itemName = nil
    if GetItemLink then
        itemLink = GetItemLink(item.bagId, item.slotIndex)
    end
    if GetItemName then
        itemName = GetItemName(item.bagId, item.slotIndex)
    end
    -- determine stack size and try to capture icon path (guarded)
    local stackSize = 1
    if GetSlotStackSize then
        stackSize = GetSlotStackSize(item.bagId, item.slotIndex) or 1
    end
    local iconPath = nil
    do
        local tryFns = { "GetItemInfo", "GetItemLinkInfo", "GetItemLinkItemInfo" }
        for _, name in ipairs(tryFns) do
            local fn = _G[name]
            if type(fn) == "function" then
                local ok, a, b, c, d, e = pcall(fn, item.bagId, item.slotIndex)
                if ok then
                    for _, v in ipairs({a, b, c, d, e}) do
                        if type(v) == "string" and v:match("%.dds") then
                            iconPath = v
                            break
                        end
                    end
                end
            end
            if iconPath then break end
        end
    end

    -- Find a bank slot: prefer an existing partial stack of the same item
    -- so we stack rather than always opening a new slot.
    local function FindBankSlotForItem(srcBag, srcSlot)
        if GetItemId and GetBagSize then
            local itemId = GetItemId(srcBag, srcSlot)
            if itemId and itemId ~= 0 then
                local bankSize = GetBagSize(BAG_BANK)
                for i = 0, bankSize - 1 do
                    local bankItemId = GetItemId(BAG_BANK, i)
                    if bankItemId == itemId then
                        if GetSlotStackSize then
                            local stack, maxStack = GetSlotStackSize(BAG_BANK, i)
                            if stack and maxStack and stack < maxStack then
                                self.core:Debug("Found partial stack in bank slot " .. i .. " (" .. stack .. "/" .. maxStack .. ")")
                                return i
                            end
                        end
                    end
                end
            end
        end
        -- No partial stack found; fall back to first empty slot
        return FindFirstEmptySlotInBag(BAG_BANK)
    end

    -- Resolve the target bank slot BEFORE picking up the item.
    -- Once PickupInventoryItem is called the source slot is empty and GetItemId returns 0,
    -- which would defeat the partial-stack scan.
    local targetBankSlot = FindBankSlotForItem(item.bagId, item.slotIndex)
    self.core:Debug("Target bank slot resolved to: " .. tostring(targetBankSlot))

    -- Snapshot item identity and stack size BEFORE transfer for post-verification.
    -- pcall only catches Lua errors; ESO silently fails game-level operations (e.g. bank full),
    -- so we verify success by checking whether the slot emptied after the delay.
    local preItemId = GetItemId and GetItemId(item.bagId, item.slotIndex) or 0
    local stackBefore = stackSize  -- already captured above

    if CallSecureProtected then
        pcall(function()
            CallSecureProtected("PickupInventoryItem", item.bagId, item.slotIndex)
            CallSecureProtected("PlaceInInventory", BAG_BANK, targetBankSlot)
        end)
    else
        self.core:Debug("ERROR: CallSecureProtected not available")
    end

    zo_callLater(function()
        -- Verify by checking if the original slot still holds the same item after the transfer window.
        local stackAfter = 0
        if preItemId ~= 0 and GetItemId and GetItemId(item.bagId, item.slotIndex) == preItemId then
            stackAfter = (GetSlotStackSize and GetSlotStackSize(item.bagId, item.slotIndex)) or 0
        end

        local transferred = stackBefore - stackAfter
        local display = itemLink or itemName or "item"
        local key = tostring(display)

        if transferred > 0 then
            self.core:Debug("Transfer verified: " .. transferred .. " of " .. stackBefore .. " moved for " .. key)
            if not self.recentTransfers[key] then
                self.recentTransfers[key] = { display = display, count = transferred, icon = iconPath }
            else
                self.recentTransfers[key].count = self.recentTransfers[key].count + transferred
                if not self.recentTransfers[key].icon and iconPath then
                    self.recentTransfers[key].icon = iconPath
                end
            end
        end

        if stackAfter > 0 then
            self.core:Debug("Transfer failed: " .. stackAfter .. " of " .. stackBefore .. " remaining for " .. key)
            if not self.failedTransfers[key] then
                self.failedTransfers[key] = { display = display, count = stackAfter }
            else
                self.failedTransfers[key].count = self.failedTransfers[key].count + stackAfter
            end
        end

        self:ProcessNext()
    end, 200)
end
